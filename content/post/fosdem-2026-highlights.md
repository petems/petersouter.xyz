---
title: "FOSDEM 2026: The Talks I Missed (But Wish I Hadn't)"
date: 2026-02-11T16:56:21Z
categories:
- conferences
- open-source
tags:
- fosdem
- conferences
- kubernetes
- cicd
- package-management
- observability
- security
keywords:
- fosdem 2026
- cfgmgmtcamp
- open source conferences
- kubernetes
- observability
#thumbnailImage: //example.com/image.jpg
---

Another year, another FOSDEM I couldn't attend in person. This time it was the travel schedule that got me—I'd been on the road so much leading up to the conference that I just couldn't justify another trip to Brussels. The upside? I did get to speak at [Config Management Camp](https://cfgmgmtcamp.eu/) right after FOSDEM, which was a great consolation prize.

But that doesn't mean I wasn't keeping an eye on the schedule. FOSDEM 2026 had some absolutely stellar talks—honestly, the hardest part about writing this post was choosing which ones to highlight. The sheer breadth and quality of content across observability, CI/CD, package management, virtualization, and security tracks made it nearly impossible to narrow down. Now that the recordings are up, I've been working through my watchlist. Here are the talks that stood out to me, though I could easily have picked dozens more.

<!--more-->

## The Missing Tracks: Observability and IaC

One thing that surprised me about FOSDEM 2026 was the absence of dedicated observability and infrastructure as code rooms.

The lack of an observability track is particularly puzzling given how vibrant the open source observability ecosystem has become. With projects like OpenTelemetry, Prometheus, Grafana, and various tracing and metrics platforms all thriving in the OSS space, you'd think there would be enough content to fill a dedicated room. The fact that there's an [OpenTelemetry unconference](https://opentelemetry.io/community/events/) happening on the Monday right after FOSDEM makes the absence even more noticeable—clearly there's community interest and plenty to discuss.

Infrastructure as code not having a room is more understandable, though still a bit disappointing. IaC seems to be in an awkward phase where it's no longer the shiny new thing that attracts the cutting-edge crowd, but it also doesn't have the prestige and established history of areas like databases or networking that warrant permanent track status. Terraform, Ansible, Pulumi, and friends are just... infrastructure now. Critical, widely used, but not particularly exciting to dedicate conference space to. It's the victim of its own success in a way.

Still, it meant that observability and IaC content was scattered across various tracks—you had to hunt for it in Testing and Continuous Delivery, Virtualization and Cloud Infrastructure, and even the Go devroom. Not ideal, but at least the talks were there if you knew where to look.

## Observability from the Datadog Team

I have to give a shout-out to my colleagues at Datadog who delivered two exceptional talks on observability and performance measurement. Both tackle fundamental challenges in production systems and offer practical, battle-tested solutions.

### How to Reliably Measure Software Performance

[How to Reliably Measure Software Performance](https://fosdem.org/2026/schedule/event/8AS3XD-how-to-reliably-measure-software-performance/) by Kemal Akkoyun and Augusto de Oliveira addressed something that every performance-focused engineer has struggled with: creating benchmarks you can actually trust.

The core problem they identify is that benchmarks are often treated as an afterthought, and even when teams do write them, they're frequently noisy, non-repeatable, and impossible to act on confidently. You run the same benchmark twice and get wildly different results. You make an optimization that should help, but the benchmark says it got slower. Sound familiar?

Drawing from their experience at Datadog working on performance-critical systems, they demonstrate practical, reproducible solutions. The talk covers environmental noise control—the kind of stuff that actually matters in production environments—and walks through how proper environment tuning cut their benchmark variance by 100x. That's not a typo. They also discuss benchmark design principles that transform unreliable measurements into dependable tools for making architectural decisions.

What I appreciate most about this talk is that it's not theoretical. These are lessons learned from real systems processing massive amounts of telemetry data, where performance regressions have real business impact. The statistical analysis methods they present are immediately applicable to any project where performance matters.

**Key takeaways:**
- Environmental factors cause massive benchmark variance—control them systematically
- Proper benchmark design is as important as the code being measured
- Statistical analysis methods can distinguish real performance changes from noise
- Real-world example: environment tuning reducing variance by 100x

### How to Instrument Go Without Changing a Single Line of Code

[How to Instrument Go Without Changing a Single Line of Code](https://fosdem.org/2026/schedule/event/7SP8BL-how_to_instrument_go_without_changing_a_single_line_of_code/) by Kemal Akkoyun and Hannah Kim explores the holy grail of observability: getting telemetry without modifying source code.

They provide a comprehensive comparison of multiple approaches—eBPF-based auto-instrumentation, compile-time binary manipulation, runtime injection techniques, and USDT probes. But this isn't just a feature matrix. They evaluate each strategy across three critical dimensions: performance overhead (latency, allocations, CPU impact), robustness across different Go versions, and operational complexity.

The talk examines emerging runtime features and proposals that could improve future instrumentation capabilities, and uses benchmarks from realistic services to demonstrate when to choose eBPF, compile-time rewriting, runtime injection, or USDT-based approaches. They also cover how OpenTelemetry's Go auto-instrumentation fits into this landscape.

What makes this talk valuable is the practical, reproducible approach using publicly available open-source tools. This isn't vendor magic—it's techniques you can implement today.

**Key takeaways:**
- Multiple viable approaches exist for zero-touch Go instrumentation, each with tradeoffs
- eBPF, compile-time rewriting, runtime injection, and USDT probes each excel in different scenarios
- Performance overhead varies significantly—benchmarking across latency, allocations, and CPU is essential
- OpenTelemetry's auto-instrumentation provides standardized integration across these approaches

## CI/CD and Testing

### Testing on Hardware with Claude AI

One talk that immediately jumped out at me was [Testing on Hardware with Claude AI](https://fosdem.org/2026/schedule/event/9SZVST-testing-on-hardware-with-claude-ai/) by Andreea Daniela Andrisan. As someone who works with both CI/CD systems and embedded hardware, this hit right in my wheelhouse.

The presentation covered a hardware-in-the-loop testing framework that uses a universal testing harness to automatically detect target hardware platforms. The clever bit? Claude AI helps adapt generic testing scripts to board-specific configurations. This means you can use the same testing codebase across different hardware platforms by using configuration files that define board-specific parameters.

What really impressed me was the GitHub Actions integration—automated matrix-based testing across multiple platforms, including hardware-specific feature validation. It's exactly the kind of automation that makes hardware testing less painful.

**Key takeaways:**
- Universal testing harness automatically detects target hardware platforms
- Claude AI adapts generic testing scripts to board-specific configurations
- GitHub Actions integration enables automated matrix-based testing across multiple platforms
- Single testing codebase validates different hardware capabilities through configuration files

## Zero-Touch Observability for Go

[How to Instrument Go Without Changing a Single Line of Code](https://fosdem.org/2026/schedule/event/7SP8BL-how_to_instrument_go_without_changing_a_single_line_of_code/) by Kemal Akkoyun and Hannah Kim explored something I've been thinking about a lot lately: how do we get observability without forcing developers to instrument their code?

They compared multiple approaches—eBPF-based auto-instrumentation, compile-time binary manipulation, runtime injection, and USDT probes—evaluating each across performance overhead, robustness across Go versions, and operational complexity. The fact that they provided actual benchmarks and guidance on when to choose each approach makes this immediately actionable. This is the kind of practical, no-nonsense content that makes FOSDEM talks so valuable.

### CI/CD with Gerrit, AI-Enhanced Review, and Hardware-in-the-Loop Testing in Jenkins

[CI/CD with Gerrit, AI-Enhanced Review, and Hardware-in-the-Loop Testing in Jenkins](https://fosdem.org/2026/schedule/event/89X8KV-cicd_with_gerrit_ai-enhanced_review_and_hardware-in-the-loop_testing_in_jenkins_/) by Michael Nazzareno Trimarchi demonstrates advanced CI strategies for embedded systems development.

**Key takeaways:**
- Integrates unit and integration testing into Jenkins Declarative Pipelines with automatic Gerrit Code Review triggering
- Uses Labgrid (open-source tool) for managing remote embedded boards, enabling Jenkins to reserve, provision, and execute system-level tests on physical devices
- Includes AI-powered error explanation component that translates complex Jenkins failures into actionable insights
- Warnings Next Generation Plugin aggregates static analysis outputs to enforce quality gates

### Your Cluster is Lying to ArgoCD (And How to Catch It)

Graziano Casto's talk, [Your Cluster is Lying to ArgoCD (And How to Catch It)](https://fosdem.org/2026/schedule/event/UFFUHQ-your_cluster_is_lying_to_argocd_and_how_to_catch_it/), addresses a problem that anyone doing GitOps has definitely encountered: what happens when someone makes an emergency fix directly in production, and then ArgoCD comes along and overwrites it?

The solution presented—Cluster-Scoped Snapshotting using a tool called [Kalco](https://github.com/disaster37/kalco)—captures live cluster state into a separate repository. This lets you create a "pre-flight diff" in your CI pipeline, comparing your intended changes against the actual cluster state. No more accidentally destroying someone's emergency hotfix at 3am.

**Key takeaways:**
- Addresses conflict between Git as source of truth and actual cluster state divergence
- Cluster-Scoped Snapshotting captures live cluster state into separate repository using Kalco
- Enables pre-flight diffs in CI pipelines comparing intended changes against actual conditions
- Facilitates bootstrapping existing clusters and maintains audit trails

### Bringing Automatic Detection of Backdoors to the CI Pipeline

[Bringing Automatic Detection of Backdoors to the CI Pipeline](https://fosdem.org/2026/schedule/event/BYACG8-automatic-backdoor-detection-in-ci/) by Michaël Marcozzi and Dimitri Kokkonis tackled one of the scariest problems in open source: backdoors. After the xz utils incident, this topic has been on everyone's mind.

They discussed ROSA, a tool that demonstrates large-scale backdoor detection can be automated. The challenge they're tackling is adapting this for CI environments—balancing resource constraints, reducing false alarms, and providing practical detection within typical CI job time windows. It's a hard problem, but exactly the kind of shift-left security we need.

**Key takeaways:**
- Backdoors hide behind valid behaviors, unlike crashes that fuzzing tools detect
- ROSA demonstrates large-scale backdoor detection automation for post-release analysis
- Adapting for CI pipelines requires balancing resource constraints and false alarm reduction
- Goal is shift-left security with practical detection within typical CI job time windows

### AI-Based Failure Aggregation

[AI-Based Failure Aggregation](https://fosdem.org/2026/schedule/event/GCG83H-ai-based_failure_aggregation/) by Lukasz Towarek presents a clever solution to test result overload.

**Key takeaways:**
- Test environments produce enormous volumes of results, complicating failure analysis as failures increase
- Uses text embeddings and semantic similarity to efficiently organize and examine distinct failures
- Combines open-source pretrained models (Sentence Transformers) for text embedding
- PostgreSQL's pgvector enables scalable vector similarity searching with low-barrier adoption

### Building CDviz: Lessons from Creating CI/CD Observability Tooling

[Building CDviz](https://fosdem.org/2026/schedule/event/ATTMUV-building_cdviz_lessons_from_creating_cicd_observability_tooling/) by David Bernard shares the builder's perspective on creating interoperability tooling.

**Key takeaways:**
- Built open source CI/CD observability platform on CDEvents despite limited ecosystem adoption
- Covers technical hurdles converting events from various tools into unified formats
- Uses PostgreSQL/TimescaleDB and Grafana for architecture
- Candid reflections on standardization challenges when building before ecosystem readiness

## Virtualization and Cloud Infrastructure

### How I Turned a Raspberry Pi into an Open-Source Edge Cloud with OpenNebula

[How I Turned a Raspberry Pi into an Open-Source Edge Cloud](https://fosdem.org/2026/schedule/event/ZHE7VJ-raspberry-into-open-source-edge-cloud/) by Pablo del Arco demonstrates cloud platforms on modest hardware.

**Key takeaways:**
- Shows how Raspberry Pi can function as complete open-source cloud platform using OpenNebula with MiniONE and KVM
- Runs virtual machines, containerized workloads, and lightweight Kubernetes clusters exclusively with open-source software
- Practical demonstration of VM launching on Pi-based setup
- Platform maintains consistency across different hardware scales

### Your Workloads Can Lose Some Weight: WebAssembly on Kubernetes

[Your Workloads Can Lose Some Weight: WebAssembly on Kubernetes](https://fosdem.org/2026/schedule/event/Y9JJBX-wasm-on-kubernetes/) by Fabrizio Lazzaretti and Linus Basig showed how WebAssembly modules can reduce container images from hundreds of megabytes down to just a few.

The integration happens through containerd shims like runwasi, and they demonstrated improvements in both image size and boot speed. Where WASM really shines, according to the presenters, is in plugin architectures and event-driven systems. If you're looking at ways to optimize resource usage or explore alternative isolation methods, this talk is worth your time.

**Key takeaways:**
- WebAssembly modules reduce container images from hundreds of megabytes to just a few
- Integration through containerd shims like runwasi with improvements in image size and boot speed
- Excels in plugin architectures and event-driven systems that scale efficiently
- Real-world examples from Cloud-Native Compute Foundation projects

### Lima v2.0: Expanding the Focus to Hardening AI

[Lima v2.0: Expanding the Focus to Hardening AI](https://fosdem.org/2026/schedule/event/RGCTDY-lima/) by Akihiro Suda explores running AI coding agents safely.

**Key takeaways:**
- Lima launches local Linux VMs focused on running containers and AI coding agents in isolated environments
- v2.0 updates include plugin infrastructure, GPU acceleration, MCP server support, and CLI enhancements
- Confines potential security risks from malicious AI instructions to VM or specific mounted directories
- Protects host systems from compromised AI agents during development experiments

### Go BGP or Go Home: Simplifying KubeVirt VM's Ingress

[Go BGP or go home](https://fosdem.org/2026/schedule/event/DB8BTE-go-bgp-or-go-home/) by Miguel Duarte, Or Mergi, and team explores networking for KubeVirt VMs.

**Key takeaways:**
- Traditional Kubernetes NAT-based networking creates complex, opaque, and brittle setups for VMs
- BGP enables Kubernetes nodes to dynamically exchange routes with provider networks
- Exposes workloads via actual IPs, eliminating NAT and manual configurations
- Enhances network design clarity, accelerates debugging, and maintains reliable connectivity

## Package Management and Supply Chain Security

### Name Resolution in Package Management Systems

[Name Resolution in Package Management Systems - A Reproducibility Perspective](https://fosdem.org/2026/schedule/event/BJCN93-name-resolution-in-package-managers/) by Gábor Boskovits examines dependency resolution approaches.

**Key takeaways:**
- Surveys various package management approaches including language-specific managers with lock files (Cargo)
- Compares traditional Linux distributions (Debian) and declarative package managers (Nix/Guix)
- Analyzes solutions through lens of reproducible builds
- Explores how different strategies impact consistent, reproducible build outputs across ecosystems

### Trust Nothing, Trace Everything: Auditing Package Builds at Scale

[Trust Nothing, Trace Everything: Auditing Package Builds at Scale with OSS Rebuild](https://fosdem.org/2026/schedule/event/EP8AMW-oss-rebuild-observability/) by Matthew Suozzo goes beyond artifact verification.

**Key takeaways:**
- Examines build processes beyond final artifact verification, not treating builds as black boxes
- OSS Rebuild instruments build environments to identify suspicious activity in real-time
- Open-source observability toolkit with transparent network proxy for uncovering hidden remote dependencies
- eBPF-based system analyzer examines build behavior in fine detail to prevent supply chain attacks

### PURL: From FOSDEM 2018 to International Standard

[PURL: From FOSDEM 2018 to International Standard](https://fosdem.org/2026/schedule/event/P8AAT3-purl/) by Philippe Ombredanne traces Package-URL's evolution.

**Key takeaways:**
- PURL matured from FOSDEM 2018 debut into international standard for identifying software packages
- Integrated into CVE formats, security tools, and package registries for vulnerability management
- Key applications include supply chain security workflows, SBOMs, and VEX documents
- Positioned as foundational infrastructure for polyglot dependency visibility

### Package Management Learnings from Homebrew

[Package Management Learnings from Homebrew](https://fosdem.org/2026/schedule/event/FGBYKV-package_management_learnings_from_homebrew/) by Mike McQuaid covers Homebrew v5.0.0.

**Key takeaways:**
- Explores Homebrew's v5.0.0 release from November 2025 with major updates
- Examines expectations Homebrew aims to enhance by drawing from other package managers
- Highlights lessons other package management systems could adopt from Homebrew's methodology
- Discusses evolution of user expectations and package manager design

### The Economics of Package Registries

Finally, [The Terrible Economics of Package Registries and How to Fix Them](https://fosdem.org/2026/schedule/event/8WJKEH-package-registry-economics/) by Michael Winser covered something we don't talk about enough: how do we keep critical infrastructure running when it's funded by grants and donations while costs keep escalating?

The talk explored how the Alpha-Omega project is addressing this through security funding and investigating revenue approaches with major registries. It's a sobering look at the sustainability challenges facing open source infrastructure, and a reminder that "free as in beer" software still costs someone money to maintain.

**Key takeaways:**
- Package registries face mounting financial pressures despite being essential infrastructure
- Most operate on constrained grants/donations while experiencing escalating operational costs
- Alpha-Omega project addresses challenges through funding security enhancements
- Examines current revenue-generating experiments across the ecosystem

## Config Management Camp

While I missed FOSDEM itself, I did make it to [Config Management Camp](https://cfgmgmtcamp.eu/) in Ghent the following week. It was great to see the configuration management community still going strong, and the hallway track was phenomenal as always. If you're into infrastructure automation, puppet, ansible, terraform, or any of the modern config management tools, CfgMgmtCamp is absolutely worth attending.

Speaking at CfgMgmtCamp was a great experience, and it helped ease the sting of missing FOSDEM. There's something special about the focused nature of a single-track conference where everyone is deeply invested in configuration management and infrastructure as code.

## Final Thoughts

FOSDEM remains one of the best open source conferences out there. The breadth of topics, the quality of speakers, and the fact that it's completely free (including all the recordings) makes it an incredible resource for the community. Even when I can't make it in person, I know I can catch up on the talks later.

What continues to impress me is the sheer volume of high-quality content. I've highlighted nearly 20 talks here, and I could have easily picked 20 more. The Testing and Continuous Delivery track alone had enough compelling content for its own blog post. The Package Management track brought together critical discussions about sustainability and security. The Virtualization and Cloud Infrastructure track showcased innovation from edge computing to WebAssembly.

If you haven't explored the [FOSDEM 2026 schedule](https://fosdem.org/2026/schedule/) yet, I highly recommend taking a look. There's something for everyone, whether you're into embedded systems, cloud infrastructure, package management, testing, observability, or just about any other aspect of open source software development.

Maybe next year I'll actually make it to Brussels. But until then, at least we have the recordings—and there are plenty to work through.
