+++
author = "Peter Souter"
categories = ["Tech"]
date = 2026-04-12T10:00:00Z
description = "How I wired up full OpenTelemetry observability (traces and metrics) for a Flink job running on AWS Managed Service for Apache Flink, and the architectural gotchas I hit along the way."
draft = true
slug = "flink-aws-datadog-opentelemetry-observability"
tags = ["Flink", "AWS", "Datadog", "OpenTelemetry", "Observability", "Terraform", "Java"]
title = "Getting proper observability into AWS Managed Service for Apache Flink"
keywords = ["Apache Flink", "AWS Managed Service for Apache Flink", "MSF", "Datadog", "OpenTelemetry", "OTLP", "observability", "tracing", "metrics"]
thumbnailImage = ""
coverImage = ""
+++

I've been building a sandbox to figure out how to get proper observability into [AWS Managed Service for Apache Flink (MSF)](https://aws.amazon.com/managed-service-apache-flink/). By "proper", I mean traces *and* metrics, both flowing into Datadog, without hacking around with the Flink runtime itself.

The repo is at [petems/msf-flink-aws-datadog-sandbox](https://github.com/petems/msf-flink-aws-datadog-sandbox), and this post is me documenting what I figured out and, more importantly, *why* I had to do things the way I did.

<!--more-->

## What is AWS Managed Service for Apache Flink?

MSF is Amazon's managed wrapper around [Apache Flink](https://flink.apache.org/). You package your Flink job as a JAR, upload it to S3, point MSF at it, and it takes care of the cluster. No Kubernetes, no Flink cluster management, no capacity planning headaches — you just tell it how many KPUs (Kinesis Processing Units) you want and it runs.

It's genuinely good at its job. The operational overhead compared to self-managing a Flink cluster is much lower. But it comes with constraints, and one of those constraints is what made observability unexpectedly tricky.

## Why the native Datadog integration wasn't enough

Datadog has an [Apache Flink integration](https://docs.datadoghq.com/integrations/flink/). At first glance, it looks like it does everything you'd want. In practice, it's a metrics reporter: it fires Flink's internal JVM and job metrics to Datadog's HTTP API via Flink's metrics reporter system. That's useful for cluster health — heap usage, checkpoint latency, that sort of thing.

What it doesn't give you is:

- **Distributed tracing** — no spans, no trace IDs, nothing you can correlate with downstream services
- **Custom application metrics** — the reporter covers Flink's own metrics, not anything you instrument inside your operators
- **Events or service checks** — the Datadog docs explicitly list these as unsupported

If you want to know "how long is this specific operator taking to process a record, end-to-end, for this particular event type" — you're on your own.

The approach I went with is full [OpenTelemetry](https://opentelemetry.io/): an OTel SDK inside the Flink job itself, exporting traces and metrics via OTLP gRPC to a collector, which then forwards everything to Datadog.

## The architecture

The overall flow looks like this:

```
Kinesis Stream (source)
  → Flink Job (MSF)
      → ObservedProcessFunction (OTel SDK)
          → OTLP gRPC export
              → OpenTelemetry Collector (ECS Fargate)
                  → Datadog
  → Kinesis Stream (sink)
```

The OTel Collector runs on ECS Fargate with service discovery via [AWS Cloud Map](https://aws.amazon.com/cloud-map/), which gives it a stable DNS name. Flink jobs can resolve that name to connect to the collector without hardcoding IPs. All the infrastructure is Terraform — VPC, private subnets, NAT gateway, ECS cluster, Cloud Map namespace, the works.

## The hard bit: Task Managers run in separate JVMs

Here's the thing that took me a while to properly internalise.

A Flink job has two types of components: the **Job Manager** and one or more **Task Managers**. The Job Manager orchestrates the job — it decides how to break it into tasks, handles checkpointing, manages restarts. The Task Managers actually execute your operator code.

In a standard Flink deployment, these are separate processes, typically on separate machines. In MSF, they're separate JVM processes managed by the service. You don't control how they start; MSF does.

This creates a problem for any configuration you'd normally pass via environment variables or system properties. If you set `OTEL_EXPORTER_OTLP_ENDPOINT` in your job code or read it from a system property at job submission time, that value lives in the Job Manager's JVM. The Task Managers don't inherit it. They start their own JVM, load your JAR, and initialise your operators — but without any of the runtime environment you might have assumed would carry over.

I saw a few approaches to this problem that don't really work well in MSF:

- Hardcoding the endpoint in the JAR — works, but you'd have to rebuild and redeploy every time anything changes
- Reading from environment variables in each operator — MSF doesn't give you a reliable way to inject env vars into Task Manager JVMs
- Using Flink's `flink-conf.yaml` — MSF only allows you to modify a subset of Flink configuration properties, and OTLP endpoint configuration isn't one of them

The solution that actually works is **Flink's `GlobalJobParameters`**.

## GlobalJobParameters: the right way to pass config to Task Managers

`GlobalJobParameters` is Flink's mechanism for distributing user-defined key-value configuration to all components of a running job. When the job starts, Flink serialises the GlobalJobParameters and ships them to every Task Manager. Your operator code can then read them from the `RuntimeContext`.

In practice it looks like this. At job submission:

```java
ExecutionEnvironment env = ExecutionEnvironment.getExecutionEnvironment();
ExecutionConfig.GlobalJobParameters params = new ExecutionConfig.GlobalJobParameters() {
    // your OTLP endpoint, batch interval, etc.
};
env.getConfig().setGlobalJobParameters(params);
```

And then inside your operator, on `open()`:

```java
@Override
public void open(Configuration parameters) throws Exception {
    GlobalJobParameters globalParams = getRuntimeContext()
        .getExecutionConfig()
        .getGlobalJobParameters();
    
    String otlpEndpoint = globalParams.toMap().get("otlp.endpoint");
    // initialise OTel SDK with this endpoint
}
```

This works because `open()` is called once when the operator initialises on the Task Manager, which is the right time to set up any stateful resources like an OTel exporter.

## The ObservedProcessFunction pattern

The sandbox wraps this all up in an abstract base class called `ObservedProcessFunction`. Any operator that extends it gets automatic instrumentation:

- A **span** per record processed, with attributes for the job name, operator name, and record metadata
- A **counter** for records processed
- A **histogram** for processing duration (in milliseconds)
- A **gauge** for records currently in-flight

The attribute design is deliberately low-cardinality. High-cardinality attributes on every span — like per-record IDs or payload values — would make the metrics explosively expensive in Datadog and make traces noisy. The attributes I picked (job, operator, a few stable event properties) stay manageable even at stream-processing volumes.

The OTel exporter is configured with a 10-second batch interval. That's a balance between latency (you don't want spans showing up 5 minutes after the fact) and cost (you don't want one export per record).

When observability is disabled — which you can do via a flag in GlobalJobParameters — the SDK initialises a no-op implementation, so there's zero overhead in production if you've decided you don't need it for a particular job.

## Running it locally

One thing I wanted to make sure of: you can run this locally in IntelliJ without any AWS account. The job reads from and writes to Kinesis by default, but there's a local mode that swaps in in-memory sources. The OTel exporter just points to `localhost:4317`, so if you've got an OTel Collector running locally (or Jaeger, which accepts OTLP), you can see traces immediately.

This matters a lot for iteration speed. The deploy cycle for MSF — upload JAR to S3, update the application, wait for it to restart — is long. Being able to develop and verify the instrumentation locally first saved a lot of time.

## Infrastructure

Everything is in Terraform. The main resources:

- **Kinesis** — source and sink streams
- **ECS Fargate** — running the OTel Collector
- **Cloud Map** — service discovery so the collector has a stable DNS name
- **Secrets Manager** — the Datadog API key lives here, not in source control or environment variables
- **CloudWatch Logs** — both the Flink job logs and the collector logs go here, useful when things go wrong

The collector configuration is straightforward: accept OTLP gRPC on port 4317, export to Datadog using the API key from Secrets Manager.

The estimated running cost of the ECS Fargate piece is around $52/month for a minimal setup. That's not nothing, but it's also not outrageous for a persistent observability pipeline.

## What I'd do differently

If I were starting from scratch, I'd spend less time on the ECS Fargate collector and more time on the GlobalJobParameters setup earlier. The collector architecture is actually fairly standard once you've done it once — the Flink-specific challenge is entirely about how you get configuration *into* the Task Managers, and that took me longer to figure out than I expected because most documentation assumes you control the whole Flink runtime.

The other thing I'd think harder about is the attribute design. I got to a reasonable place, but metrics cardinality in Datadog can get expensive fast if you're not careful. I'd probably add a validation step that logs a warning if any attribute value looks like it might be high-cardinality (long strings, IDs, etc.).

## Links

- [msf-flink-aws-datadog-sandbox on GitHub](https://github.com/petems/msf-flink-aws-datadog-sandbox)
- [AWS Managed Service for Apache Flink documentation](https://aws.amazon.com/managed-service-apache-flink/)
- [Datadog's Flink integration docs](https://docs.datadoghq.com/integrations/flink/) — useful for what it covers, even if it's not the whole picture
- [OpenTelemetry Java SDK](https://opentelemetry.io/docs/languages/java/)
- [Flink GlobalJobParameters docs](https://nightlies.apache.org/flink/flink-docs-master/docs/dev/datastream/application_parameters/)
