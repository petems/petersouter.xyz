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

As a Sales Engineer at Datadog, often times I'm asked to look into the sharp edges and unknowns of Datadog. How it works with.

So, when a customer reached out asking how to get distributed tracing working in their Amazon Managed Service for Apache Flink (MSF) applications, I had to go look up two things. 

One... what is Flink?

Two... what is MSF?

## Flink

Apache Flink is an open-source distributed processing engine for stateful computations over unbounded and bounded data streams. It is designed for high-throughput, low-latency, and exactly-once processing guarantees, making it a popular choice for real-time analytics applications. Flink can run in a variety of environments, including cloud-managed services like Amazon MSF, and is known for its scalability and fault tolerance.

It already has support for a number of different tool options, including Datadog for metrics, OTel Tracing and a bunch of other options. Ok, that seems all great, nothing too unusual there, there's existing Datadog integrations for it, everythings documented.

The standard pattern for Flink observability is well-established: configure your metrics reporters and trace exporters in flink-conf.yaml, maybe add a sidecar OpenTelemetry Collector, attach a Java agent, and you're done.

## MSF (Amazon Managed Service for Apache Flink)

Ok, so Amazon have a SaaS-ified version of Flink that is a lot more specific. So what does that offer out of the box?

AWS's native MSF tooling provides basic CloudWatch metrics (throughput, latency, checkpoints) and log collection, but both are severely limited compared to what you'd expect from a modern observability stack. There's no distributed tracing at all—you can see that records are flowing through your pipeline, but you have no way to follow a single record's journey from source to sink or understand how long each operator takes to process it.

The metrics lack the dimensionality needed for deep performance analysis; you get aggregate numbers but can't slice by custom tags or business dimensions. Log correlation with traces is non-existent, so when something goes wrong, you're left manually searching through CloudWatch logs trying to piece together what happened. For a complex streaming application processing millions of events across multiple operators, this visibility gap makes debugging performance issues or understanding request flows nearly impossible. The native tooling tells you that something is slow, but not why or where in your pipeline the bottleneck exists. My customer needed real observability, not just basic monitoring.

## The Problem

What I quickly discovered was that MSF's fully-managed nature imposes strict constraints that make traditional Flink observability patterns impossible: no access to `flink-conf.yaml`, no sidecar containers, and no easy way to attach Java agents. Every standard approach I tried hit a wall built by AWS's managed service architecture.

## Getting Started: A "Hello World" M SF App

So if I was going to get started figuring out where to go, I needed a getting started app. Amazon have a github repo with some examples here: https://github.com/aws-samples/amazon-managed-service-for-apache-flink-examples/tree/main/java

So I grabbed the getting started version of this to start with, so I had a known quantity of MSF as a baseline. Then I looked at some of the approaches it has to see if there's any prior-art I could use for metrics and traces. Nothing specific came up, but it did have a Prometheus sink, so clearly it was possible, so I kep that up my sleeve as a backup option specifically.

## The Datadog Java Agent Approach (Spoiler: It Didn't Work)

Lets start by my initial approach, sticking with the company line: Datadog's native Java APM tracing.  

However, [the Datadog Java tracer requires](https://docs.datadoghq.com/tracing/trace_collection/dd_libraries/java/) using the `-javaagent:/path/to/dd-java-agent.jar` flag at JVM startup, before the `-jar` argument. Added to this, the Datadog agent [is typically added as a sidecar in containerized environments](https://docs.datadoghq.com/tracing/guide/tutorial-enable-java-containers/), enabling automatic tracing without code changes.

Normally this is fine, as a lot of Java applications allow some form of modifying the JVM launch parameters, but in MSF, _AWS completely manages the Flink runtime including how the JVM is started_. 

This means there's no way to inject the `-javaagent` flag into the startup command, and you can't bundle the agent into your application JAR in a way that works properly. Datadog explicitly warns never to add dd-java-agent to your classpath as it causes unexpected behavior, so this approach was another dead end.

## oTel Is A First Class Citizen

The next approach was obivous: oTel instrumentation. oTel is a first class citizen for Datadog anyways, and we can easily get it into Datadog anyways. Plus we already have prior art within Flink on how to to oTel instrumentation anyways.

So, I implemented tracing and enhanced metrics directly in the application code using the OpenTelemetry Java SDK. I manually initialize the OpenTelemetry SDK within the Flink operators, configured an OTLP gRPC exporter and did some quick local testing to make sure the spans and traces were being sent.

The next thing I thought of was Trace and Log correlation: Making sure that the logs contained trace_id's so we can easily sync up the logs to any traces that are created. Since MSF is a locked down version, we can't do anything fancy and it uses Cloudwatch natively. 

Luckily oTel has already thought of this, and there is a an `AwsXrayIdGenerator` method to ensure trace IDs are compatible with AWS X-Ray for CloudWatch correlation.

## Claude does the heavy lfiting

Honestly here, I'm not a Java expert (last time I really was serious about it I was In unversity about 16 years ago!) so I booted up trusty Claude Code and let it rip. 

The main things I would guide it along with, was making sure it was locally testable, but also making sure the configuration to deploy things was quickly done and repeatable with Terraform.

### Final Architecture Overview

Here's the complete architecture showing how distributed tracing flows from MSF through to Datadog:

![MSF Tracing Architecture](/images/2026/02/msf-tracing-architecture.png)

The architecture diagram shows two critical paths:
- **Trace/Metrics Path** (red solid lines): OpenTelemetry data flows from the Flink application through DNS resolution and the Network Load Balancer to the ADOT Collector, which then exports to Datadog
- **Log Path** (green dashed lines): Application logs with injected trace context flow through CloudWatch Logs and Kinesis Firehose to Datadog for automatic correlation

But here's the critical architectural piece: the OpenTelemetry exporter can't send to localhost because there's no local collector—remember, no sidecars in MSF. Instead, I deployed a centralized AWS Distro for OpenTelemetry (ADOT) Collector as an ECS Fargate service running in the same VPC as the Flink application. The Fargate deployment gives us a stable, scalable collector that can handle traces from multiple Flink jobs without requiring EC2 instance management.

I configured a private DNS entry (e.g., `otel-collector.local`) in Route 53 pointing to the Fargate service's Network Load Balancer, and ensured the security groups allow traffic on port 4317 (OTLP gRPC) from the MSF application's security group to the Fargate collector's security group. The ADOT Collector is configured with the Datadog exporter, so traces flow from Flink → ADOT Collector (Fargate) → Datadog, giving us full distributed tracing without any agent attachment.

For log-trace correlation, I inject trace context directly into log messages since we can't modify the root log4j configuration, and then use CloudWatch Logs forwarding via Kinesis Firehose to send logs to Datadog where they automatically correlate with traces.

## Lessons Learned

Looking back, this project taught me an important lesson about working with fully-managed services: sometimes the path forward isn't about finding the "right" configuration, but about understanding the fundamental constraints and adapting your approach accordingly. The solution requires more upfront work than simply attaching an agent or modifying a config file—you're now managing infrastructure (the Fargate collector), networking (VPC peering, security groups, DNS), and manual instrumentation in your code.

But for teams running production workloads on MSF, the visibility gained is essential for maintaining reliable streaming applications. The repository we built became a reference architecture for doing observability the "MSF way"—not through external tooling or configuration magic, but through deliberate instrumentation within the application itself, paired with purpose-built infrastructure that respects AWS's managed service boundaries.

If you're facing similar challenges with MSF observability, I hope this journey helps you avoid some of the dead ends I encountered and points you toward a solution that actually works within AWS's managed environment.

---

**Sources:**
- [Datadog Java Tracer Documentation](https://docs.datadoghq.com/tracing/trace_collection/dd_libraries/java/)
- [Tutorial: Enable Tracing for a Java Application in Containers](https://docs.datadoghq.com/tracing/guide/tutorial-enable-java-containers/)
