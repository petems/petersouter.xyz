+++
author = "Peter Souter"
categories = ["Tech", "AWS", "Observability"]
date = 2026-02-03T09:49:30+01:00
description = "A journey through implementing distributed tracing in Amazon Managed Service for Apache Flink within AWS's managed service constraints"
draft = false
thumbnailImage = "/images/2026/02/msf-tracing-architecture.png"
coverImage = "/images/2026/02/msf-tracing-architecture-cover.png"
slug = "bringing-distributed-tracing-to-amazon-msf"
tags = ["AWS", "Flink", "Distributed Tracing", "OpenTelemetry", "Datadog", "MSF", "Observability"]
title = "Implementing distributed tracing in Amazon Managed Service for Apache Flink (MSF)"
+++

As a Sales Engineer at Datadog, I'm often asked to look into the sharp edges and unknowns of Datadog and how it works with other platforms.

So, when a customer reached out asking how to get distributed tracing working in their Amazon Managed Service for Apache Flink (MSF) applications, I had to go look up two things.

One... what is Flink?

Two... what is MSF?

## TL;DR: The Challenge

If you're running streaming workloads on Amazon Managed Service for Apache Flink and need distributed tracing, you'll quickly discover that **all the standard approaches don't work**:

- ❌ **No Java agent attachment** - MSF controls the JVM startup, so you can't inject `-javaagent` flags
- ❌ **No sidecar containers** - AWS manages the runtime environment completely
- ❌ **No flink-conf.yaml access** - Configuration changes require opening support tickets, not quick iteration
- ❌ **No native tracing** - CloudWatch gives you basic metrics and logs, but no way to follow a record's journey through your pipeline

For teams processing millions of events across multiple operators, this visibility gap makes debugging performance bottlenecks nearly impossible. You can see *that* something is slow, but not *why* or *where*.

**The solution?** Manual instrumentation with OpenTelemetry, a centralized ADOT Collector on ECS Fargate, and creative workarounds for log-trace correlation. It requires more upfront work than a typical integration, but it's the only path to real observability in MSF's constrained environment.

This post walks through the journey of implementing distributed tracing in MSF, including working code examples from the [msf-flink-aws-datadog-sandbox repository](https://github.com/petems/msf-flink-aws-datadog-sandbox).

## Background: What Are We Even Working With?

### Flink

Apache Flink is an open-source distributed processing engine for stateful computations over unbounded and bounded data streams. It is designed for high-throughput, low-latency, and exactly-once processing guarantees, making it a popular choice for real-time analytics applications. Flink can run in a variety of environments, including cloud-managed services like Amazon MSF, and is known for its scalability and fault tolerance.

It already has support for a number of different tool options, including Datadog for metrics, OpenTelemetry (OTel) tracing, and a bunch of other options. That all seems great; there are existing Datadog integrations for it, and everything's documented.

The standard pattern for Flink observability is well-established: configure your metrics reporters and trace exporters in flink-conf.yaml, maybe add a sidecar OpenTelemetry Collector, attach a Java agent, and you're done.

### MSF (Amazon Managed Service for Apache Flink)

Ok, so Amazon has a SaaS-ified version of Flink that is a lot more specific. So what does that offer out of the box?

AWS's native MSF tooling provides basic CloudWatch metrics (throughput, latency, checkpoints) and log collection, but both are limited compared to what you'd expect from a modern observability stack. You can tune [metrics reporting levels](https://docs.aws.amazon.com/managed-flink/latest/java/cloudwatch-logs-levels.html) and emit [custom metrics](https://docs.aws.amazon.com/managed-flink/latest/java/monitoring-metrics-custom.html), but there's no distributed tracing by default—you can see that records are flowing through your pipeline, but you have no way to follow a single record's journey from source to sink or understand how long each operator takes to process it.

The metrics lack the dimensionality needed for deep performance analysis; you get aggregate numbers but can't slice by custom tags or business dimensions. Log correlation with traces is non-existent, so when something goes wrong, you're left manually searching through CloudWatch logs trying to piece together what happened. For a complex streaming application processing millions of events across multiple operators, this visibility gap makes debugging performance issues or understanding request flows nearly impossible. The native tooling tells you that something is slow, but not why or where in your pipeline the bottleneck exists. My customer needed real observability, not just basic monitoring.

## The Problem

What I quickly discovered was that MSF's fully-managed nature imposes strict constraints that make traditional Flink observability patterns impractical: no direct access to `flink-conf.yaml`, no sidecar containers, and no easy way to attach Java agents. You can [view configured settings](https://docs.aws.amazon.com/managed-flink/latest/java/viewing-modifiable-settings.html) and request changes through support, but that isn't the same as editing configs locally and iterating quickly. Every standard approach I tried hit a wall built by AWS's managed service architecture.

## Getting Started: A "Hello World" MSF App

So if I was going to get started figuring out where to go, I needed a getting started app. Amazon has a GitHub repo with some examples here: https://github.com/aws-samples/amazon-managed-service-for-apache-flink-examples/tree/main/java

So I grabbed the getting started version of this to start with, so I had a known quantity of MSF as a baseline. Then I looked at some of the approaches it has to see if there's any prior art I could use for metrics and traces. Nothing specific came up, but it did have a Prometheus sink, so clearly it was possible, so I kept that up my sleeve as a backup option.

## The Datadog Java Agent Approach (Spoiler: It Didn't Work)

Let's start with my initial approach, sticking with the company line: Datadog's native Java APM tracing.  

However, [the Datadog Java tracer requires](https://docs.datadoghq.com/tracing/trace_collection/dd_libraries/java/) using the `-javaagent:/path/to/dd-java-agent.jar` flag at JVM startup, before the `-jar` argument. Added to this, the Datadog agent [is typically added as a sidecar in containerized environments](https://docs.datadoghq.com/tracing/guide/tutorial-enable-java-containers/), enabling automatic tracing without code changes.

Normally this is fine, as a lot of Java applications allow some form of modifying the JVM launch parameters, but in MSF, _AWS completely manages the Flink runtime including how the JVM is started_. 

This means there's no way to inject the `-javaagent` flag into the startup command, and you can't bundle the agent into your application JAR in a way that works properly. Datadog explicitly warns never to add dd-java-agent to your classpath as it causes unexpected behavior, so this approach was another dead end.

## oTel Is A First Class Citizen

The next approach was obvious: OTel instrumentation. OTel is a first class citizen for Datadog, and we can easily get it into Datadog. Plus we already have prior art within Flink on how to do OTel instrumentation.

So, I implemented tracing and enhanced metrics directly in the application code using the OpenTelemetry Java SDK. I manually initialize the OpenTelemetry SDK within the Flink operators, configured an OTLP gRPC exporter and did some quick local testing to make sure the spans and traces were being sent.

### Adding OpenTelemetry Dependencies

First, I added the necessary OpenTelemetry dependencies to the project's `pom.xml`:

```xml
<!-- OpenTelemetry Core -->
<dependency>
    <groupId>io.opentelemetry</groupId>
    <artifactId>opentelemetry-api</artifactId>
    <version>1.34.1</version>
</dependency>
<dependency>
    <groupId>io.opentelemetry</groupId>
    <artifactId>opentelemetry-sdk</artifactId>
    <version>1.34.1</version>
</dependency>

<!-- OTLP Exporter -->
<dependency>
    <groupId>io.opentelemetry</groupId>
    <artifactId>opentelemetry-exporter-otlp</artifactId>
    <version>1.34.1</version>
</dependency>

<!-- Semantic Conventions -->
<dependency>
    <groupId>io.opentelemetry.semconv</groupId>
    <artifactId>opentelemetry-semconv</artifactId>
    <version>1.23.1-alpha</version>
</dependency>
```

The next thing I thought of was trace and log correlation: making sure that the logs contained trace IDs so we can easily correlate logs with any traces that are created. Since MSF is locked down, we can't do anything fancy and it uses CloudWatch natively, and [logging levels have performance implications](https://docs.aws.amazon.com/managed-flink/latest/java/cloudwatch-logs.html). 

Luckily OTel has already thought of this, and there is an `AwsXrayIdGenerator` to make trace IDs compatible with AWS X-Ray. This is only necessary if you want traces to appear in X-Ray/ServiceLens. For Datadog correlation, you just need to inject the trace IDs you generate into your logs. Also, X-Ray now accepts W3C trace IDs when using a recent ADOT Collector or CloudWatch agent, which can simplify this decision. See [AWS X-Ray W3C trace ID support](https://aws.amazon.com/about-aws/whats-new/2023/10/aws-x-ray-w3c-format-trace-ids-distributed-tracing/) for details.

## Claude does the heavy lifting

Honestly, I'm not a Java expert (last time I was serious about it I was in university about 16 years ago!) so I booted up trusty Claude Code and let it rip.

The main things I would guide it along with were making sure it was locally testable, and making sure the configuration to deploy things was quickly done and repeatable with Terraform.

### Implementation Details

Here's how we actually implemented the tracing. The full code is available in the [msf-flink-aws-datadog-sandbox repository](https://github.com/petems/msf-flink-aws-datadog-sandbox).

#### Initializing OpenTelemetry

The `TracingModule` class handles OpenTelemetry SDK initialization with the OTLP gRPC exporter:

```java
public class TracingModule {
    private static final Logger LOGGER = LoggerFactory.getLogger(TracingModule.class);

    public static TracingModule create() {
        String otlpEndpoint = System.getenv("OTEL_EXPORTER_OTLP_ENDPOINT");
        String serviceName = System.getenv("OTEL_SERVICE_NAME");

        // Configure OTLP gRPC exporter
        OtlpGrpcSpanExporter spanExporter = OtlpGrpcSpanExporter.builder()
            .setEndpoint(otlpEndpoint)
            .build();

        // Build tracer provider with batch span processor
        SdkTracerProvider tracerProvider = SdkTracerProvider.builder()
            .addSpanProcessor(BatchSpanProcessor.builder(spanExporter).build())
            .setResource(Resource.create(Attributes.of(
                ResourceAttributes.SERVICE_NAME, serviceName
            )))
            .build();

        // Initialize OpenTelemetry SDK with W3C trace context propagation
        OpenTelemetry openTelemetry = OpenTelemetrySdk.builder()
            .setTracerProvider(tracerProvider)
            .setPropagators(ContextPropagators.create(
                W3CTraceContextPropagator.getInstance()
            ))
            .build();

        LOGGER.info("TracingModule initialized with endpoint: {}", otlpEndpoint);
        return new TracingModule(openTelemetry, tracerProvider);
    }
}
```

In your Flink job's main method, you configure the OTLP settings from application properties and initialize the tracing module:

```java
public class BasicStreamingJob {
    public static void main(String[] args) throws Exception {
        // Load application properties
        ParameterTool applicationProperties = loadApplicationProperties(args);

        // Configure OTLP settings from properties
        configureOtelFromProperties(applicationProperties);

        // Initialize tracing module
        TracingModule tracingModule = TracingModule.create();
        LOGGER.info("Application started with tracing enabled: {}",
                    tracingModule.isEnabled());

        // ... rest of Flink job setup
    }

    private static void configureOtelFromProperties(ParameterTool properties) {
        // Set system properties for OTLP configuration
        String endpoint = properties.get("otel.exporter.otlp.endpoint");
        String serviceName = properties.get("otel.service.name");

        System.setProperty("OTEL_EXPORTER_OTLP_ENDPOINT", endpoint);
        System.setProperty("OTEL_SERVICE_NAME", serviceName);
    }
}
```

#### Creating Spans for Each Record

The `TracedProcessFunction` wraps your Flink processing logic with automatic span creation:

```java
public abstract class TracedProcessFunction<I, O>
        extends ProcessFunction<I, O> {

    private final Tracer tracer;

    @Override
    public void processElement(I record, Context ctx, Collector<O> out)
            throws Exception {
        // Create span for this record
        Span span = tracer.spanBuilder(getSpanName())
            .setSpanKind(SpanKind.INTERNAL)
            .startSpan();

        try (Scope scope = span.makeCurrent()) {
            // Add attributes
            span.setAttribute("job.name", getRuntimeContext().getJobName());
            span.setAttribute("operator.name",
                            getRuntimeContext().getTaskName());

            // Call your processing logic
            processRecord(record, ctx, out);

            span.setStatus(StatusCode.OK);
        } catch (Exception e) {
            span.recordException(e);
            span.setStatus(StatusCode.ERROR);
            throw e;
        } finally {
            span.end();
        }
    }

    protected abstract void processRecord(I record, Context ctx,
                                         Collector<O> out) throws Exception;
    protected abstract String getSpanName();
}
```

#### Log-Trace Correlation

Since MSF uses a fixed JSON log format that excludes custom MDC fields, we inject trace context directly into log messages:

```java
import io.opentelemetry.api.trace.Span;
import io.opentelemetry.api.trace.SpanContext;

protected void logWithTraceContext(String message, Object... args) {
    Span currentSpan = Span.current();
    SpanContext spanContext = currentSpan.getSpanContext();

    if (spanContext.isValid()) {
        // Append trace identifiers to log message
        LOGGER.info(message + " [trace_id={} span_id={}]",
                    ArrayUtils.addAll(args,
                                     spanContext.getTraceId(),
                                     spanContext.getSpanId()));
    } else {
        LOGGER.info(message, args);
    }
}

// Usage in your operator:
logWithTraceContext("Processing record with key: {}", key);
// Output: Processing record with key: 12345 [trace_id=abc123... span_id=def456...]
```

On the Datadog side, configure a log pipeline with a grok parser to extract the trace_id from the message field, and Datadog will automatically correlate logs with traces.

### Final Architecture Overview

Here's the complete architecture showing how distributed tracing flows from MSF through to Datadog:

![MSF Tracing Architecture](/images/2026/02/msf-tracing-architecture.png)

The architecture diagram shows two critical paths:
- **Trace/Metrics Path** (red solid lines): OpenTelemetry data flows from the Flink application through DNS resolution and the Network Load Balancer to the ADOT Collector, which then exports to Datadog
- **Log Path** (green dashed lines): Application logs with injected trace context flow through CloudWatch Logs and Kinesis Firehose to Datadog for automatic correlation

But here's the critical architectural piece: the OpenTelemetry exporter can't send to localhost because there's no local collector—remember, no sidecars in MSF. Instead, I deployed a centralized AWS Distro for OpenTelemetry (ADOT) Collector as an ECS Fargate service running in the same VPC as the Flink application. The Fargate deployment gives us a stable, scalable collector that can handle traces from multiple Flink jobs without requiring EC2 instance management.

I configured a private DNS entry (e.g., `otel-collector.local`) in Route 53 pointing to the Fargate service's Network Load Balancer, and ensured the security groups allow traffic on port 4317 (OTLP gRPC) from the MSF application's security group to the Fargate collector's security group. The ADOT Collector is configured with the Datadog exporter, so traces flow from Flink → ADOT Collector (Fargate) → Datadog, giving us full distributed tracing without any agent attachment.

For log-trace correlation, I inject trace context directly into log messages since we can't provide a custom root log4j configuration, and then use CloudWatch Logs forwarding via Kinesis Firehose to send logs to Datadog where they automatically correlate with traces.

### Infrastructure as Code: Terraform Configuration

Since Claude helped me iterate quickly, I made sure everything was deployable via Terraform. Here are the key pieces:

#### ADOT Collector on ECS Fargate

The ADOT Collector runs as an ECS Fargate task with the official AWS image:

```hcl
resource "aws_ecs_task_definition" "otlp_collector" {
  family                   = "otlp-collector"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([{
    name  = "otel-collector"
    image = "public.ecr.aws/aws-observability/aws-otel-collector:latest"

    portMappings = [
      { containerPort = 4317, protocol = "tcp" },  # OTLP gRPC
      { containerPort = 4318, protocol = "tcp" },  # OTLP HTTP
      { containerPort = 13133, protocol = "tcp" }  # Health check
    ]

    environment = [
      {
        name  = "DD_API_KEY"
        valueFrom = aws_secretsmanager_secret.datadog_api_key.arn
      }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.otlp_collector.name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])
}

resource "aws_ecs_service" "otlp_collector" {
  name            = "otlp-collector"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.otlp_collector.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.private[*].id
    security_groups  = [aws_security_group.otlp_collector.id]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.otlp_collector.arn
  }
}
```

#### Service Discovery with AWS Cloud Map

Instead of a Network Load Balancer, we use AWS Cloud Map for service discovery, which provides a simpler DNS-based approach:

```hcl
resource "aws_service_discovery_private_dns_namespace" "local" {
  name        = "local"
  description = "Private DNS namespace for service discovery"
  vpc         = aws_vpc.main.id
}

resource "aws_service_discovery_service" "otlp_collector" {
  name = "otel-collector"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.local.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}
```

This creates the `otel-collector.local` DNS name that our Flink application uses to reach the collector.

#### Security Groups

The security groups are straightforward - allow OTLP gRPC traffic from Flink to the collector:

```hcl
# Allow inbound OTLP gRPC on collector
resource "aws_vpc_security_group_ingress_rule" "otlp_collector_grpc_from_flink" {
  security_group_id = aws_security_group.otlp_collector.id
  description       = "Allow OTLP gRPC from Flink application"

  from_port                    = 4317
  to_port                      = 4317
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.flink_app.id
}

# Allow outbound OTLP gRPC from Flink
resource "aws_vpc_security_group_egress_rule" "flink_to_otlp" {
  security_group_id = aws_security_group.flink_app.id
  description       = "Allow OTLP gRPC to collector"

  from_port                    = 4317
  to_port                      = 4317
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.otlp_collector.id
}

# Allow collector to reach Datadog
resource "aws_vpc_security_group_egress_rule" "otlp_collector_to_internet" {
  security_group_id = aws_security_group.otlp_collector.id
  description       = "Allow HTTPS to Datadog"

  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"
}
```

#### MSF Application Configuration

The MSF application receives the OTLP endpoint through application properties:

```hcl
resource "aws_kinesisanalyticsv2_application" "flink_app" {
  name                   = var.application_name
  runtime_environment    = "FLINK-1_20"
  service_execution_role = aws_iam_role.flink_app.arn

  application_configuration {
    application_code_configuration {
      code_content {
        s3_content_location {
          bucket_arn = aws_s3_bucket.flink_app.arn
          file_key   = aws_s3_object.app_jar.key
        }
      }
      code_content_type = "ZIPFILE"
    }

    environment_properties {
      property_group {
        property_group_id = "OtelConfig"

        property_map = {
          "otel.exporter.otlp.endpoint"  = "http://otel-collector.local:4317"
          "otel.service.name"            = var.application_name
          "otel.deployment.environment"  = var.environment
        }
      }
    }

    vpc_configuration {
      security_group_ids = [aws_security_group.flink_app.id]
      subnet_ids         = aws_subnet.private[*].id
    }
  }
}
```

The application code loads these properties at startup and configures the OpenTelemetry SDK accordingly.

## Known Unknowns: The Trade-offs

While this architecture solves the visibility gap, it's important to acknowledge that it introduces new variables into your streaming pipeline:

### Performance Overhead

Manual instrumentation via the OTel SDK is generally efficient, but in a high-throughput Flink environment, every microsecond counts. I haven't performed extensive benchmarking to see how much backpressure the OTLP gRPC export might introduce under extreme load (e.g., millions of events per second).

### The "Double-Serialization" Tax

Because we are manually creating spans within the operator code rather than using a bytecode-level agent, there is a slight CPU cost associated with trace generation and serialization that Flink isn't "aware" of.

### Network Reliability

By sending traces to an external Fargate-hosted collector via a Load Balancer, we've added a network hop. If the collector becomes a bottleneck, you risk either losing traces or—depending on your OTel configuration—slowing down your Flink operators.

### Maintenance Burden

Unlike a native integration, you now own the lifecycle of the ADOT Collector and the custom instrumentation code. When Flink or OTel versions upgrade, you'll need to test for breaking changes manually.

## Lessons Learned

Looking back, this project taught me an important lesson about working with fully-managed services: sometimes the path forward isn't about finding the "right" configuration, but about understanding the fundamental constraints and adapting your approach accordingly. The solution requires more upfront work than simply attaching an agent or modifying a config file—you're now managing infrastructure (the Fargate collector), networking (VPC peering, security groups, DNS), and manual instrumentation in your code.

But for teams running production workloads on MSF, the visibility gained is essential for maintaining reliable streaming applications. The repository we built became a reference architecture for doing observability the "MSF way"—not through external tooling or configuration magic, but through deliberate instrumentation within the application itself, paired with purpose-built infrastructure that respects AWS's managed service boundaries.

If you're facing similar challenges with MSF observability, I hope this journey helps you avoid some of the dead ends I encountered and points you toward a solution that actually works within AWS's managed environment.

---

**Sources:**
- [msf-flink-aws-datadog-sandbox GitHub Repository](https://github.com/petems/msf-flink-aws-datadog-sandbox) - Complete working implementation with Terraform infrastructure
- [Datadog Java Tracer Documentation](https://docs.datadoghq.com/tracing/trace_collection/dd_libraries/java/)
- [Tutorial: Enable Tracing for a Java Application in Containers](https://docs.datadoghq.com/tracing/guide/tutorial-enable-java-containers/)
- [AWS Managed Service for Apache Flink Examples](https://github.com/aws-samples/amazon-managed-service-for-apache-flink-examples)
