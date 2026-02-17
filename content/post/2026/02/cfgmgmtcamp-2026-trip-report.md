+++
author = "Peter Souter"
categories = ["Conference"]
date = 2026-02-17T09:00:00Z
description = "A trip report from CfgMgmtCamp 2026 in Ghent, Belgium."
draft = true
slug = "cfgmgmtcamp-2026-trip-report"
tags = ["Config Management", "Conferences", "CfgMgmtCamp"]
title = "CfgMgmtCamp 2026 Trip Report"
keywords = ["cfgmgmtcamp", "config management", "conferences", "ghent"]
+++

| Location | Hogent University, Gent (Ghent), Belgium |
| :---- | :---- |
| **Dates** | to |
| **Videos** | [https://www.youtube.com/watch?v=8ukj56T50kw\&list=PLBZBIkixHEich2-s0PRncozYzaBQNBXyw\&index=28](https://www.youtube.com/watch?v=8ukj56T50kw&list=PLBZBIkixHEich2-s0PRncozYzaBQNBXyw&index=28) |
| **Website** | [https://cfgmgmtcamp.org/ghent2026/](https://cfgmgmtcamp.org/ghent2026/) |

# **Event Summary**

**CfgMgmtCamp** (short for **Configuration Management Camp**) is a **community-run, free (registration-required) conference** focused on **open-source infrastructure automation / “ops tooling”** \- configuration management, provisioning, orchestration, containers, and adjacent DevOps/CD topics. It’s traditionally held **in Ghent, Belgium right after FOSDEM**, so many people “extend” their FOSDEM trip into the following days.

# **Takeaways**

* **AI/LLMs dominated the conversation**  
  * AI was the single most recurring theme across tracks \- from Adam Jacob's keynote on AI-native infrastructure with Claude, to MCP (Model Context Protocol) appearing in multiple talks (Ansible, monitoring, IaC), to workshops on agentic AI for operations.  
  * Nearly every track had at least one AI-related talk, signaling it's no longer a niche topic but a central concern for infrastructure engineers. Notably, several talks also pushed back on AI hype, questioning its impact on mentorship and learning (Bernd Erk's "Automation Without Apprentices").  
* **The Puppet fork aftermath was a major storyline**  
  * The OpenVox project (the open-source Puppet successor born from Perforce's decision to close Puppet's source) had significant presence \- a dedicated track both days, community day workshops, and talks covering migration, CI pipelines across implementations, and even whether to rewrite the server in plain Ruby.  
    * NB: Makes sense as the Vox Pupuli are sponsors  
    * The event started out as a Puppetcamp back in the day (2013)  
      * A sign of the times there were 0 Puppet employees attending  
  * Vox Pupuli's community organizing was clearly a galvanizing force, with Ben Ford and Tim Meusel leading multiple sessions.  
* **Open source sustainability and sovereignty were recurring themes**  
  * Multiple keynotes tackled the economics and politics of open source \- Richard Fontana on the "exploitation paradox," Joe Brockmeier declaring "The Gilded Age of Open Source is over," Martin Alfke on community vs. business, and a full panel on European sovereign computing etc  
  * The conference reflected genuine anxiety about corporate rug-pulls, vendor lock-in, and the need for digital autonomy in the current geopolitical landscape  
* **The tooling landscape was broad but Ansible-heavy**  
  * Ansible had the largest footprint with 2-3 dedicated tracks per day plus a full contributor summit on Day 3\. Red Hat's presence was felt throughout (Ansible, Foreman/Katello, Pulp, bootc).  
    * NB: Ansible **and** Redhat are sponsors so makes sense [https://cfgmgmtcamp.org/ghent2026/sponsors/](https://cfgmgmtcamp.org/ghent2026/sponsors/)  
  * Other well-represented ecosystems included OpenTofu (with its own track), Nix/NixOS, Kubernetes, Foreman, and mgmt config.  
  * Notably absent or minimal: Chef, Saltstack (only via Uyuni), and Pulumi.  
    * NB: Pulumi is one of the sponsers also… strange they didn’t have any sessions or workshops  
  * Cfgmgmtcamp continues to line up with FOSDEM-ish ways, where talk mix skewed toward practitioner talks and live demos over vendor pitches.  
* **Observability, CI/CD, and platform engineering emerged as crosscutting concerns**  
  * Beyond traditional config management, the conference showed the field expanding into CI/CD observability (OpenTelemetry in pipelines, DORA metrics, CDEvents), platform engineering  
    principles, and "Day Two" operational challenges.  
  * Tools like OpenTelemetry, Grafana, and VictoriaMetrics appeared across multiple tracks, reflecting a maturing understanding that managing infrastructure now means managing the entire delivery and operational lifecycle \- not just the initial provisioning.  
  * Would be nice to have more of a Datadog prescence at Cfgmgmtcamp  
    * But aware we also had folks working at FOSDEM and on the oTel Unconfernce on the Monday  
    * [https://kakkoyun.me/talks/how-to-instrument-go-without-changing-code/](https://kakkoyun.me/talks/how-to-instrument-go-without-changing-code/)  
    * [https://kakkoyun.me/talks/how-to-reliably-measure-software-performance/](https://kakkoyun.me/talks/how-to-reliably-measure-software-performance/)  
    * [https://opentelemetry.io/blog/2025/otel-unplugged-fosdem/](https://opentelemetry.io/blog/2025/otel-unplugged-fosdem/)

# **Detailed Breakdown**

## **Scuttlebutt and General Observations**

* It was good to be back in Ghent\!  
  * It'd been 6 years since I was last here for Cfgmgmtcamp, just before lockdown…  
    * [https://www.youtube.com/watch?v=wYEffa1q6eU](https://www.youtube.com/watch?v=wYEffa1q6eU)  
    * [https://cfp.cfgmgmtcamp.org/2020/speaker/39MQMY/](https://cfp.cfgmgmtcamp.org/2020/speaker/39MQMY/) a  
  * But the memories flooded back quick\!  
* Walking over to Hogent University from the station, all the memories came flooding back.  
  * So many bikes\!  
  * The big Art Nevaeau owl for the Opticians  
  * The big Pepsi can that's the front awning for a cafe  
* And finally, the entrance to Hogent itself…  
* My colleague Benjamin Fuhrmann was speaking
  * [https://cfp.cfgmgmtcamp.org/ghent2026/talk/USPZHD/](https://cfp.cfgmgmtcamp.org/ghent2026/talk/USPZHD/)  
  * But unfortunatly *at the exact same time as my talk*  
  * Luckily we had some other folks from Datadog attending so they cheered him on!

## **Day 1**

### **Intro and Logistics**

* Show of hands for “For who is this their first cfgmgmgtcamp?” was very high, maybe 70% of the main room\!  
* Show of hands for people coming since the first meetup beginning was about \~10, myself included\!

### **We Built for Predictability; the Workloads Didn’t Care \- Micheal Stahnke**

* **2026-02-02, 09:30–10:20, D.Aud**  
  * Link: [https://cfp.cfgmgmtcamp.org/ghent2026/talk/AGSYJ3/](https://cfp.cfgmgmtcamp.org/ghent2026/talk/AGSYJ3/)  
  * Video: [https://youtu.be/pq3Qxb26Nwo?si=YX3F9FeFpRPNp8RE](https://youtu.be/pq3Qxb26Nwo?si=YX3F9FeFpRPNp8RE)  
* **Talk Summary**  
  * **“Desired state” is a myth:** Config management chased certainty (idempotency, hermeticity), but real systems never stay “finished” or static—users and ongoing change disrupt them.  
  * **Shift to probabilistic workloads:** AI/LLMs don’t produce identical outputs from identical inputs, so engineers must reason in probabilities, not guarantees.  
  * **Statistical validation replaces pass/fail tests:** Instead of unit tests expecting one correct answer, use boundary checks and distribution/CI-based acceptance (SLO-like).  
  * **Hermetic, immutable environments are essential:** Lock the infrastructure (e.g., Nix, pinned containers) so repeated runs measure workload variance—not environment drift.  
  * **Ops regains control:** Unpredictable, AI-generated code needs containment and guardrails, increasing the importance of operations in providing stable foundations and control points.  
* **My Personal Notes:**  
  * Was great to see Stahnke again, we worked together at Puppet many years ago

### **The Exploitation Paradox in Open Source \- Richard Fontana**

* **2026-02-02, 10:20–11:10, D.Aud**  
  * Link: [https://cfp.cfgmgmtcamp.org/ghent2026/talk/KP9YPK/](https://cfp.cfgmgmtcamp.org/ghent2026/talk/KP9YPK/)  
  * Slides: [Link](https://cfp.cfgmgmtcamp.org/media/ghent2026/submissions/KP9YPK/resources/slides-fontana-cfgmgmtcamp2026_GW81j66.pdf)  
* **Talk Summary:**  
  * **Static definitions vs. changing reality:** Classic open-source definitions (FSF/OSI) are fixed, while today’s software environment (SaaS, cloud, AI) keeps shifting—creating repeated crises when old rules don’t fit new contexts.  
  * **Leverage points create asymmetry:** Infrastructure changes introduce new ways for certain actors to gain power (e.g., proprietary licensing via object code, dual licensing, CLAs), often giving vendors advantages the community doesn’t share.  
  * **Licenses aren’t a durable fix:** The community keeps responding with new licenses (AGPL, ethical licenses), but Fontana argues licensing is too brittle for modern structural problems; “source available” exploits open-source branding while adding restrictions.  
  * **AI “open washing”:** In AI, “open” is used even more loosely—models often lack transparency (especially training data) and don’t fit open-source definitions, but the label is used to signal virtue without real freedom.  
  * **“Mobile freedoms” framework:** He proposes shifting to adaptable freedoms—**Reproduce, Verify, Participate, Exit**—grounded in **Stewardship**, to keep power negotiable and prevent lock-in.  
* **My Personal Notes**  
  * When Richard specifically mentioned the Terraform BPL fork, and even asked how many HashiCorp employees were attending (0 hands up, sad times)  
  * Interesting topic overall but I have to admit Richard’s delivery was a little dry and slow

### **AI Native Infrastructure Automation: How I learned to stop worrying and love Claude \- Adam Jacob**

* **2026-02-02, 11:30–12:20, D.Aud**  
  * Link: [https://cfp.cfgmgmtcamp.org/ghent2026/talk/UGTUYH/](https://cfp.cfgmgmtcamp.org/ghent2026/talk/UGTUYH/)  
  * Video: [https://youtu.be/g1R71Wbxlkk?si=Wj6bk01RyQb9Urha](https://youtu.be/g1R71Wbxlkk?si=Wj6bk01RyQb9Urha)  
* **Talk Summary:**  
  * **AI is inevitable in dev:** The productivity jump is too big to ignore; with tens of thousands of lines of working code generated daily, **ops/deploy** becomes the main bottleneck.  
  * **Build speed is extreme:** His team rebuilt a better, “AI-native” version of a six-year product in **3 days**, suggesting technical moats are shrinking fast.  
  * **Engineers shift to architecture:** When AI output exceeds human review capacity, the job moves from writing code to setting **system design, constraints, and validation rules**.  
  * **AI-native automation principles:** Tools should be designed for **agents first**—transparent, extensible, closely mirroring real APIs—with **policy/validation checks** at every step due to real-world side effects.  
  * **Agent autonomy demo:** In a live prototype (“Swamp”), an agent built a **Proxmox provider in \~10 minutes**, extending its own code to authenticate, discover infra, and manage VM workflows.  
* **My Personal Notes:**  
  * This was probably the biggest AI booster talk at the conference.

## **Break and Practise**

* I missed on the ignites because I wanted to grab lunch, practise my talk and double check slides  
* I went up to my room early to watch the talks before my slot and to scope out the setup and location

### **Getting started with CI/CD using Forgejo Actions and why this is important AF \- Jeroen Baten**

* **2026-02-02, 14:00–14:50, B.1.011**  
  * Link: [https://cfp.cfgmgmtcamp.org/ghent2026/talk/PQUPEQ/](https://cfp.cfgmgmtcamp.org/ghent2026/talk/PQUPEQ/)  
  * Slides: [Slides](https://cfp.cfgmgmtcamp.org/media/ghent2026/submissions/PQUPEQ/resources/cfgmgtcamp-2026-forgejo_Dxzq5oT.pdf)  
* **Talk Summary:**  
  * **Forgejo** is a lightweight, self-hostable Git forge (repos, issues, PRs, releases, wiki) that’s easy to run and maintain.  
  * **Forgejo Actions** provide CI/CD similar to GitHub Actions: workflows live in .forgejo/workflows/ and are near-compatible with GitHub’s syntax.  
  * **Runners** execute jobs by polling the server; you can run many runners across Docker, OSes, and hardware, and target them using **labels**.  
  * Workflows can do real pipelines: checkout code, run tests, spin up services (e.g., Postgres), upload **artifacts**, and publish **releases** (often using tokens/secrets).  
  * The “important AF” argument: moving off GitHub reduces dependence on a single for-profit vendor and supports digital autonomy; the speaker encourages mirroring a repo, porting a workflow, and supporting the Forgejo/Codeberg ecosystem.  
* **My Personal Notes:**  
  * I’ve never heard a conference speaker swear so much in a talk 😅

### **My Talk \- CI/CD Observability, Metrics and DORA: Shifting Left and Cleaning Up\! \- Peter Souter**

* **2026-02-02, 14:50–15:40, B.1.011**  
  * Link: [https://cfp.cfgmgmtcamp.org/ghent2026/talk/98XRKP/](https://cfp.cfgmgmtcamp.org/ghent2026/talk/98XRKP/)  
  * Slides: [Link](https://cfp.cfgmgmtcamp.org/media/ghent2026/submissions/98XRKP/resources/CI_CD_Observability-Metrics_and_DORA__Shifting_Le_1Anewor.pdf)  
* **Talk Summary**  
  * **Core principle:** Across SDLC/Agile/DevOps, the recurring theme is **small batch sizes \+ tight feedback loops**; “waterfall” is framed as a misread of Royce’s original warning rather than the intended best practice.  
  * **The CI/CD ownership gap:** Modern orgs monitor production well, but CI/CD often has “no one / everyone” owning it—creating a governance smell and “tragedy of the commons.” The talk argues CI/CD should be treated like a **product** with clear ownership and SLOs.  
  * **Measure to improve (qual \+ quant):** Use **surveys** to find pain points, but rely on **systems data** for real progress—e.g., build queue time (p95), pipeline success rate, and lead time from laptop → production—so you can turn “vibes” into actionable priorities and investment cases.  
  * **Case studies & GenAI tradeoffs:** GenAI boosts perceived individual productivity but can reduce overall delivery throughput/stability (“productivity paradox”), reinforcing the need for small batches. Examples include Slack’s structured flaky-test workflow (moving CI success from \~20% to \~98%) and Datadog’s CI visibility/test impact analysis and dashboards (saving significant CI time), culminating in using **DORA metrics** (deploy freq, lead time, change fail rate, time to restore) as system-level outcomes—not individual KPIs.  
* **My Personal Notes:**  
  * Went well, had a few peeps ask about FOSS/self-deployed options  
  * Had a talk afterwards about CVEvent OSS stuff

### **Event-Driven CI/CD Observability: Infrastructure as Observable Events \- David Bernard**

* **2026-02-02, 16:00–16:25, B.1.011**  
  * Link: [https://cfp.cfgmgmtcamp.org/ghent2026/talk/M993WU/](https://cfp.cfgmgmtcamp.org/ghent2026/talk/M993WU/)  
  * Slides: [Slides](https://cfp.cfgmgmtcamp.org/media/ghent2026/submissions/M993WU/resources/cfgmgmtcamp2026-cdviz_tQUBdLq.odp)  
* **Talk Summary:**  
  * CI/CD observability is hard today because delivery data is fragmented across many tools, making simple questions (what’s deployed where, what changed, was it signed, which pipeline produced it) require manual correlation.  
  * The proposed fix is to treat the software delivery lifecycle as **observable events** and build a **single unified view** across environments and tools.  
  * Key principle: **don’t replace teams’ tools/workflows**—instead “observe what exists,” integrate with current systems, and provide end-to-end visibility of “what happened.”  
  * Use a standard event model (consistent identity \+ type \+ context) so artifacts, deployments, tests, and pipeline runs can be linked and queried reliably across systems.  
  * Implement via a collector/connector pipeline (mini-ETL, like an OTel collector) that pulls/pushes from sources, transforms into CD events, stores them, and powers dashboards \+ automation/reactions.  
* **My Personal Notes:**

### **Beyond SHA Pinning: Security for CI/CD Pipelines \- Andoni Alonso & Paco Sanchez**

* **2026-02-02, 16:25–16:50, B.1.011**  
  * Link: [https://cfp.cfgmgmtcamp.org/ghent2026/talk/E9ANZ8/](https://cfp.cfgmgmtcamp.org/ghent2026/talk/E9ANZ8/)  
  * Slides: [Slides](https://cfp.cfgmgmtcamp.org/media/ghent2026/submissions/E9ANZ8/resources/Beyond_SHA_Pinning__Security_for_CI_CD_Pipelines__a7Smty9.pdf)  
* **Talk Summary:**  
  * **CI/CD pipelines are high-value targets** because they hold privileged access to source code, infrastructure, and secrets—so pipeline security must be treated as core SDLC security, not an afterthought.  
  * **Supply-chain incidents (e.g., tj-actions)** show that basic hygiene like “pin actions by SHA” helps but isn’t sufficient on its own; you need layered defenses and continuous verification.  
  * **Common failure modes** covered include secrets leakage, over-permissioned tokens/runners, and unsafe dependency/action usage—each turning small mistakes into large blast-radius compromises.  
  * **Lesser-known attack vectors** include “living off the pipeline” (abusing trusted tool configs) and **event-context/injection risks** (PR titles, branch names, commit messages) that can trigger unintended execution downstream.  
  * **Actionable defenses** focus on least privilege, safer PR workflow patterns (preventing PR-open → RCE paths), protecting workflow/config directories with stronger review controls, and carefully constraining **OIDC claims** to avoid role-assumption bypasses.  
* **My Personal Notes:**
  * 

## **Day 2**

### **Beyond Static Files: Dynamic Configurations for a Future-Proof World \- Marcel van Lohuizen & Roger Peppe**

* **2026-02-03, 09:30–10:20, D.Aud**  
  * Link: [https://cfp.cfgmgmtcamp.org/ghent2026/talk/S93BW8/](https://cfp.cfgmgmtcamp.org/ghent2026/talk/S93BW8/)  
* **Talk Summary:**  
  * **Configuration failure repeats:** The industry cycles every 10–15 years between IaC, static data, and templating; DRY breaks under variation, WET doesn’t scale.  
  * **Configuration is a process:** It spans siloed systems with hidden dependencies (Terraform, Kubernetes, schemas, app code), and outages happen when conflicts aren’t correlated.  
  * **CUE’s core value:** CUE is a logical constraint system (commutative, idempotent, hermetic, monotonic) that composes config safely and predictably.  
  * **CUE Hub control plane:** A central coordinator between sources (Git) and sinks (Terraform/OpenTofu) to validate intent, enforce policy, and provide audit trails.  
  * **Shift-left \+ impact analysis:** Catch policy issues in PRs and preview the real blast radius by grouping related changes across envs/repos before production.  
* **My Personal Notes:**
  * 

### **The Gilded Age of Open Source is over \- Joe Brockmeier**

* **2026-02-03, 10:20–11:10, D.Aud**  
  * Link: [https://cfp.cfgmgmtcamp.org/ghent2026/talk/QV7JPB/](https://cfp.cfgmgmtcamp.org/ghent2026/talk/QV7JPB/)  
* **Talk Summary:**  
  * **The Gilded Age Metaphor** Brockmeier draws a parallel between the US Gilded Age (1870s-1890s)—characterized by rapid railroad expansion, wealth inequality, and robber barons—and the last 20 years of open source, which saw the rapid expansion of the internet and the accumulation of corporate power.  
  * **Sanitization for Business** While open source began with volunteers and free software ideals, it was eventually "sanitized" to make it palatable for capitalists; the term "open source" was adopted specifically to distinguish it from "free software" and encourage business adoption.  
  * **The "Convenience or Death" Culture** Despite preaching openness, developers frequently chose convenience over freedom, adopting proprietary tools like Slack, Jira, and GitHub for their workflows, which centralized control and gave corporations leverage over open source infrastructure.  
  * **The Rise of Single-Vendor Projects** The ecosystem shifted from community-driven projects (like the LAMP stack) to single-vendor, VC-funded projects; this model often led to "rug pulls" where companies changed licenses (e.g., Redis, MongoDB) after failing to monetize effectively against public clouds.  
  * **The Public Cloud Paradox** Major cloud providers like AWS utilized open source software to build massive businesses without contributing back proportionately, forcing smaller open source vendors to abandon open licenses to protect their revenue.  
  * **Supply Chain Fragility** The Log4Shell vulnerability exposed the cracks in the open source foundation, highlighting how the entire internet relies on unpaid, burnt-out maintainers who are often treated as suppliers rather than volunteers.  
  * **Erosion of Trust and Geopolitics** Recent events have damaged the trust required for collaboration, including the XZ backdoor attack on supply chains and the removal of Russian maintainers from the Linux kernel due to sanctions, signaling the intrusion of geopolitics into code.  
  * **The Threat of AI** The speaker argues that AI is displacing open source as the primary target for VC investment and is actively harming the ecosystem by scraping code without permission and flooding maintainers with low-quality, machine-generated pull requests.  
  * **Decline of General Purpose Computing** There is a growing hostility toward general-purpose computing, exemplified by "walled gardens" like the Apple App Store and Google's restrictions on side-loading in Android, which limits user freedom and control.  
  * **Call for a Progressive Era** Brockmeier concludes that while the "Gilded Age" is over, a "Progressive Era" is possible if the community returns to core values, mentors the next generation, and moves beyond being passive consumers to active participants who prioritize rights over convenience.  
* **My Personal Notes:**  
  * Probably my favourite talk of the conference\!

### **Sovereign Computing: Panel**

* **2026-02-03, 11:25–12:15, D.Aud**  
  * Link: [https://cfp.cfgmgmtcamp.org/ghent2026/talk/AURM7P/](https://cfp.cfgmgmtcamp.org/ghent2026/talk/AURM7P/)  
* **Session Summary:**  
  * **Sovereignty as a Spectrum of Choice** The panelists defined digital sovereignty not as a binary state, but as a multi-dimensional "spectrum" centered on the freedom to choose and the independence from "big tech" and "big money",. They emphasized that achieving sovereignty involves making calculated trade-offs between convenience, cost, and control, noting that true independence prevents organizations from being beholden to the whims of specific billionaires or foreign jurisdictions,.  
  * **Critique of European Cloud Initiatives** There was significant criticism of EU-funded projects like "Gaia X," which panelists argued spent hundreds of millions of euros to produce documents rather than usable technology. Some argued that to compete with US hyperscalers, Europe must stop acting solely as infrastructure companies and start operating as software companies that prioritize "developer experience," as this is the primary reason users choose platforms like AWS.  
  * **The Fallacy of "Global Scale"** The panel debated the necessity of hyperscalers, with some arguing that the requirement for "global scale" is often a false narrative used to justify locking into American cloud providers,. Speakers cited real-world examples, such as *The Moscow Times* and international judicial institutes, that were forced to build sovereign infrastructure to avoid political censorship and de-platforming, proving that global operations are possible without big tech,.  
  * **The Knowledge and Generational Gap** A major hurdle identified is the "knowledge gap" among decision-makers who lack the technical understanding to realize that non-public cloud solutions are viable for 90% of use cases. Furthermore, the panel noted a lack of younger engineers (20-40 years old) involved in the sovereignty space, emphasizing the need for education to prevent knowledge about independent infrastructure from being lost,.  
  * **Standardization Over Reinvention** Rather than trying to build a direct one-to-one competitor to AWS, panelists suggested that Europe should focus on defining a common "API standard". By mandating that providers comply with a shared specification, the industry could achieve interoperability similar to "cars and gas stations," allowing users to switch providers freely without having to rewrite their automation code,  
* **My Personal Notes:**  
  * asdfasdf

## **Ignites**

### **Prompt engineering is just Stack Overflow \- Micheal Stahnke**

* **Video:** [https://youtu.be/FdIItDpEtUw?si=YTRdbEvVlqTmC84A](https://youtu.be/FdIItDpEtUw?si=YTRdbEvVlqTmC84A)  
* **Talk Summary:**  
  * **The Shift to Probabilistic Workloads** Stahnke explains that the industry has entered an era of "probabilistic workloads" where inputs do not guarantee exact outputs (e.g., asking for three items and getting five). This requires engineers to accept uncertainty and verify that outcomes fall within an acceptable range rather than relying on strict deterministic success,.  
  * **The Manager vs. Contributor Divide** Interviews with engineering leaders revealed that managers generally favor AI more than individual contributors (ICs). Managers are accustomed to unplanned but acceptable outcomes, whereas ICs often reject AI-generated solutions simply because the code style differs from how they would personally write it.  
  * **Replacement via Competence** Addressing fears of job loss, Stahnke shares a key insight from his peers: while AI itself may not replace an engineer, "the person that uses AI better than you will replace you," highlighting the necessity of adapting to these new tools.  
  * **Personality and Sandboxing** Because AI models are trained on internet data like Reddit and Stack Overflow, agents can sometimes exhibit "hostile" attitudes or create code that makes reviewers feel "uncomfortable." Stahnke notes that current safety measures often rely on "sandboxing," though many users blindly trust these sandboxes without fully understanding their architecture,,.  
* **My Personal Notes:**
  * asdfa

### **Dopamine, Dunning-Kruger, and a Life in Technology: Why We're All Confidently Wrong About Everything (And That's Okay) \- James Freeman**

* **2026-02-03, 12:25–12:30, D.Aud**  
  * Link: [https://cfp.cfgmgmtcamp.org/ghent2026/talk/MGVWWM/](https://cfp.cfgmgmtcamp.org/ghent2026/talk/MGVWWM/)  
  * Video: [https://youtu.be/1TwA-qXIElM?si=Csjomm5p8NOm719W](https://youtu.be/1TwA-qXIElM?si=Csjomm5p8NOm719W)  
* **Talk Summary:**  
  * **The Dunning-Kruger Effect** Freeman opens with the story of a bank robber who believed lemon juice made him invisible to illustrate the Dunning-Kruger effect: the cognitive bias where people with low ability at a task overestimate their ability. He explains that humans are generally poor at judging their own competence levels.  
  * **Oscillating Self-Perception** The speaker describes how tech workers tend to oscillate between two extremes: the overconfidence of thinking a new task looks easy, and the "imposter syndrome" of the "valley of despair," where they believe everyone else is smarter than they are.  
  * **The Dopamine Driver** Freeman connects these psychological states to dopamine, noting that the brain's chemical reward system drives engineers to addictively seek out problems to fix or features to add. He notes that corporate targets and performance reviews often reinforce this cycle.  
  * **The Trap of Perfectionism** This dopamine-fueled cycle can lead to negative outcomes, such as the "relentless pursuit of perfection" and massive over-engineering. Freeman uses the example of a complex, AI-generated kettle to show how people often over-complicate solutions rather than accepting that "good" is sufficient.  
  * **A Message of Reassurance** The talk concludes by addressing the audience's internal fears, reminding them that despite the noise of the industry and their own self-doubt, they are "always enough" and are likely doing much better than they think they are.  
* **My Personal Notes:**
  * sdfasdf

### **How We Treat Each Other At Work \- Richard W Bown**

* **2026-02-03, 12:30–12:35, D.Aud**  
  * Link: [https://cfp.cfgmgmtcamp.org/ghent2026/talk/TKV8RR/](https://cfp.cfgmgmtcamp.org/ghent2026/talk/TKV8RR/)  
  * Video: [https://youtu.be/sJD-Rlmylok?si=VIRlbgT6PWXeIIbM](https://youtu.be/sJD-Rlmylok?si=VIRlbgT6PWXeIIbM)  
* **Talk Summary:**  
  * **The Stagnation of Work Culture** Reflecting on his 30-year career, Bown argues that despite the industry's adoption of Agile, new frameworks, and endless meetings, engineers are ultimately "still doing the same shit" they were doing decades ago.  
  * **Critique of Business Novels** While he acknowledges enjoying books like *The Phoenix Project* and *The Unicorn Project*, he categorizes them as "business books" that teach frameworks rather than stories that accurately reflect the often "miserable" reality of the day-to-day job.  
  * **The Fallacy of "Work is Family"** Bown pushes back against the corporate narrative that "work is a family," asserting that forced bonding events and mandates to have fun are fake, as genuine team chemistry cannot be manufactured by management.  
  * **Management Pressure and Tech Debt** He highlights the "pressure cooker" nature of the job where bosses frequently override quality controls to "just get it into production," forcing engineers to knowingly build up technical debt to meet arbitrary deadlines.  
  * **A Call for Basic Kindness** Viewing the current AI hype as just "another pill" the workforce is forced to swallow, Bown concludes that the solution isn't another complex strategy, but simply going "back to basics" and being nicer to one another.  
* **My Personal Notes:**  
  * asdfasdf

### **My Ignite: Untangling Strings: Getting CI Visibility for Vox Pupuli Tests \- Peter Souter**

* **2026-02-03, 12:15–12:20, D.Aud**  
  * Schedule Link[https://cfp.cfgmgmtcamp.org/ghent2026/talk/UTCKK9/](https://cfp.cfgmgmtcamp.org/ghent2026/talk/UTCKK9/)  
  * Stream Recording \- [https://www.youtube.com/watch?v=0WzoLHT3hZI](https://www.youtube.com/watch?v=0WzoLHT3hZI)  
* **Talk Summary:**  
  * **Managing Massive Scale** Souter introduces Vox Pupuli as the gatekeepers for over 300 Puppet repositories containing 46,000 pull requests. He notes that managing the Continuous Integration (CI) for this volume of activity is highly complex due to the sheer number of interactions.  
  * **Solving for "Known Unknowns"** The talk focuses on resolving "known unknowns" in CI infrastructure—instances where maintainers know certain builds are slow or problematic but lack the data to identify exactly which ones are causing the bottlenecks.  
  * **Rapid Integration for Visibility** Leveraging Datadog’s open source program, the team was able to integrate CI visibility directly into GitHub Actions with a "one-click" setup. This provided immediate insights, such as an 87% pipeline success rate, without requiring extensive configuration.  
  * **The "Hall of Shame" Dashboard** Souter demonstrated how they built custom dashboards featuring a "Hall of Shame" to isolate the slowest pipelines (such as the Rocky tests). This allowed the team to distinguish between legitimate code failures and platform-level API errors.  
  * **Data-Driven Debugging** The visibility tool successfully replaced "gut feelings" with hard data. In one specific example, the team identified a spike where a CI run time doubled, allowing them to visually trace the regression back to a specific commit and fix the issue immediately.  
* **My Personal Notes:**  
  * My first ever ignite\!  
  * Was a fun format

### **Every day I’m Hustlin' \- Ben Ford**

* **2026-02-03, 12:20–12:25, D.Aud**  
  * Schedule Link: [https://cfp.cfgmgmtcamp.org/ghent2026/talk/MFY3SB/](https://cfp.cfgmgmtcamp.org/ghent2026/talk/MFY3SB/)  
  * Stream Recording \- [https://youtu.be/32wugqip7Ms?si=no4UmPt4ytvsW8YV](https://youtu.be/32wugqip7Ms?si=no4UmPt4ytvsW8YV)  
* **Talk Summary:**  
  * **The Reality of Enterprise Bootstrapping** Ford shares that his plan to bootstrap the company using a massive support contract with a well-known enterprise company proved difficult because the negotiations were far slower and more tedious than anticipated, though the company is finally approaching its first million in revenue.  
  * **Rejection of the Unicorn Model** The speaker expresses a moral opposition to Venture Capital, stating he has no interest in becoming a "10x hockey stick unicorn" or being tied to shareholders. Instead, his goal is simply to make a living, pay his staff, and do good work without the need to "ride a giant dick rocket into space".  
  * **The Founder as Administrator** He describes the reality of running a small business as dealing with "administrative bullshit" and constant context switching. The founder's role effectively becomes picking up every piece of work \- from legal to project management—that does not have a dedicated engineer assigned to it.  
  * **The Power of Slowing Down** Using an anecdote about a photographer who was overwhelmed by sudden popularity, Ford argues for the necessity of "putting on the brakes." He suggests using tools to intentionally slow down customer intake to a pace where the team can actually deliver quality.  
  * **Sustainability Over Speed** The core lesson of the talk is to prioritize sustainability over rapid growth. By lowering expectations and refusing external funding, the company avoids the "rat race" and ensures they can manage the workload without burning out.  
* **My Personal Notes:**
  * asdfasdf

## **Conclusion**

* Unfortunately I had to leave early from here (Around 2pm on the 2nd Day)  
* Which is a shame because there were some talks later on that seemed super relevant to me now I’m at Datadog and observability is top of mind:  
  * [https://cfp.cfgmgmtcamp.org/ghent2026/talk/CE9YF8/](https://cfp.cfgmgmtcamp.org/ghent2026/talk/CE9YF8/)  
  * [https://cfp.cfgmgmtcamp.org/ghent2026/talk/QLFDWN/](https://cfp.cfgmgmtcamp.org/ghent2026/talk/QLFDWN/)  
  * [https://cfp.cfgmgmtcamp.org/ghent2026/talk/VM78AU/](https://cfp.cfgmgmtcamp.org/ghent2026/talk/VM78AU/)  
  * [https://cfp.cfgmgmtcamp.org/ghent2026/talk/88YNP8/](https://cfp.cfgmgmtcamp.org/ghent2026/talk/88YNP8/)  
  * [https://cfp.cfgmgmtcamp.org/ghent2026/talk/GQYAVR/](https://cfp.cfgmgmtcamp.org/ghent2026/talk/GQYAVR/)  
  * [https://cfp.cfgmgmtcamp.org/ghent2026/talk/88YNP8/](https://cfp.cfgmgmtcamp.org/ghent2026/talk/88YNP8/)  
* But I definitely loved being back, and will be planning on attending (and likely submitting again\!) for 2027 as well 