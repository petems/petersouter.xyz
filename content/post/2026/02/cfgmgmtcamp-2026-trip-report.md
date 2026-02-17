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

# **Introduction**

* <INTRODUCTION>

# **Event Summary**

* <EVENT SUMMARY>

# **Takeaways**

* <TAKEAWAYS>

## **Scuttlebutt and General Observations**

* It was good to be back in Ghent\! It'd been 6 years since I was last here for Cfgmgmtcamp, but the memories flooded back quick  
* Walking over to Hogent University from the station, all the memories came flooding back.  
  * So many bikes\!  
  * The big Art Nevaeau owl for the Opticians  
  * The big Pepsi can that's the front awning for a cafe  
* And finally, the entrance to Hogent itself…
* My colleague Benjamin Fuhrmann was also speaking, but unfortunatly *at the exact same time as my talk*  
  * [https://cfp.cfgmgmtcamp.org/ghent2026/talk/USPZHD/](https://cfp.cfgmgmtcamp.org/ghent2026/talk/USPZHD/)  
  * Luckily another of my colleagues, Brice Figureau, was attending and could cheer them on\! 

## **Day 1**

### **Intro and Logistics**

* Show of hands for first cfgmgmgtcamp was very high, maybe 70% of the main room  
* Show of hands for people coming since the beginning was about \~10, myself included\!

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

### **Break and Practise**

* I missed on the ignites because I wanted to grab lunch, practise my talk and double check slides  
* Went up to my room early to watch the talks before my slot and to scope out the setup and location

### **Getting started with CI/CD using Forgejo Actions and why this is important AF**

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
  * I’ve never heard a conference speaker swear so much in a talk

### **My Talk \- CI/CD Observability, Metrics and DORA: Shifting Left and Cleaning Up\!**

* **2026-02-02, 14:50–15:40, B.1.011**  
  * Link: [https://cfp.cfgmgmtcamp.org/ghent2026/talk/98XRKP/](https://cfp.cfgmgmtcamp.org/ghent2026/talk/98XRKP/)  
  * Slides: [Link](https://cfp.cfgmgmtcamp.org/media/ghent2026/submissions/98XRKP/resources/CI_CD_Observability-Metrics_and_DORA__Shifting_Le_1Anewor.pdf)  
* Went well, had a few peeps ask about FOSS/self-deployed options  
* Had a talk afterwards about CVEvent OSS stuff

### **Event-Driven CI/CD Observability: Infrastructure as Observable Events**

* **2026-02-02, 16:00–16:25, B.1.011**  
  * Link: [https://cfp.cfgmgmtcamp.org/ghent2026/talk/M993WU/](https://cfp.cfgmgmtcamp.org/ghent2026/talk/M993WU/)  
  * Slides: [Slides](https://cfp.cfgmgmtcamp.org/media/ghent2026/submissions/M993WU/resources/cfgmgmtcamp2026-cdviz_tQUBdLq.odp)  
* **Talk Summary:**  
  * CI/CD observability is hard today because delivery data is fragmented across many tools, making simple questions (what’s deployed where, what changed, was it signed, which pipeline produced it) require manual correlation.  
  * The proposed fix is to treat the software delivery lifecycle as **observable events** and build a **single unified view** across environments and tools.  
  * Key principle: **don’t replace teams’ tools/workflows** — instead “observe what exists,” integrate with current systems, and provide end-to-end visibility of “what happened.”  
  * Use a standard event model (consistent identity \+ type \+ context) so artifacts, deployments, tests, and pipeline runs can be linked and queried reliably across systems.  
  * Implement via a collector/connector pipeline (mini-ETL, like an OTel collector) that pulls/pushes from sources, transforms into CD events, stores them, and powers dashboards \+ automation/reactions.  
* **My Personal Notes:**

### **Beyond SHA Pinning: Security for CI/CD Pipelines**

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

## **Day 2**

  ### **Beyond Static Files: Dynamic Configurations for a Future-Proof World**

* **2026-02-03, 09:30–10:20, D.Aud**  
  * Link: [https://cfp.cfgmgmtcamp.org/ghent2026/talk/S93BW8/](https://cfp.cfgmgmtcamp.org/ghent2026/talk/S93BW8/)

  ### **The Gilded Age of Open Source is over**

* **2026-02-03, 10:20–11:10, D.Aud**  
  * Link: [https://cfp.cfgmgmtcamp.org/ghent2026/talk/QV7JPB/](https://cfp.cfgmgmtcamp.org/ghent2026/talk/QV7JPB/)

  ### **Sovereign Computing: Panel**

* **2026-02-03, 11:25–12:15, D.Aud**  
  * Link: [https://cfp.cfgmgmtcamp.org/ghent2026/talk/AURM7P/](https://cfp.cfgmgmtcamp.org/ghent2026/talk/AURM7P/)

  ### **Ignites**

  ### **Prompt engineering is just Stack Overflow**

* **Video:** [https://youtu.be/FdIItDpEtUw?si=YTRdbEvVlqTmC84A](https://youtu.be/FdIItDpEtUw?si=YTRdbEvVlqTmC84A)  
* **Talk Summary:**  
  * asdfasf  
* **My Personal Notes:**

  ### **Dopamine, Dunning-Kruger, and a Life in Technology: Why We're All Confidently Wrong About Everything (And That's Okay)**

* Link: [https://cfp.cfgmgmtcamp.org/ghent2026/talk/MGVWWM/](https://cfp.cfgmgmtcamp.org/ghent2026/talk/MGVWWM/)  
* Video: [https://youtu.be/1TwA-qXIElM?si=Csjomm5p8NOm719W](https://youtu.be/1TwA-qXIElM?si=Csjomm5p8NOm719W)  
* **Talk Summary:**  
  * sdfad  
* **My Personal Notes:**  
  * asdfasdf

  ### **How We Treat Each Other At Work**

* Link: [https://cfp.cfgmgmtcamp.org/ghent2026/talk/TKV8RR/](https://cfp.cfgmgmtcamp.org/ghent2026/talk/TKV8RR/)  
* Video: [https://youtu.be/sJD-Rlmylok?si=VIRlbgT6PWXeIIbM](https://youtu.be/sJD-Rlmylok?si=VIRlbgT6PWXeIIbM)  
* **Talk Summary:**  
  * sdfad  
* **My Personal Notes:**  
  * asdfasdf

  ### **My Ignite: Untangling Strings: Getting CI Visibility for Vox Pupuli Tests**

* Schedule Link[https://cfp.cfgmgmtcamp.org/ghent2026/talk/UTCKK9/](https://cfp.cfgmgmtcamp.org/ghent2026/talk/UTCKK9/)  
* Stream Recording \- [https://www.youtube.com/watch?v=0WzoLHT3hZI](https://www.youtube.com/watch?v=0WzoLHT3hZI)  
* **Talk Summary:**  
  * sdfad  
* **My Personal Notes:**  
  * My first ever ignite\!  
  * Was a fun format