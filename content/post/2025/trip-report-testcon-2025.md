---
title: "Trip Report: Speaking at Testcon 2025"
date: 2025-11-03T04:02:56Z
draft: true
categories:
- conferences
tags:
- testcon
- speaking
- conferences
keywords:
- testcon 2025
- conference talk
#thumbnailImage: //example.com/image.jpg
---

## Event Summary

> TestCon Europe 2025 is a four-day software testing conference held in Vilnius, Lithuania in October 2025. The event brought together QA engineers, test automation specialists, and engineering leaders from across Europe for a mix of full-day hands-on workshops, 45-minute talks, and keynote sessions. Spanning tracks on AI-powered testing, security testing, performance and load, test strategy and methodology, tools and frameworks, and teams and culture, the conference featured speakers from major enterprises like ING Bank, Nord Security, and Zebra Technologies alongside testing tool vendors such as BrowserStack, LambdaTest, and Inflectra.

## Takeaways

* AI-dominated agenda: AI-powered testing was by far the most frequent topic, with dedicated tracks across all days covering LLM evals, agentic AI testing, AI-driven QA, Large Action Models, red-teaming, and MCP-enabled AI workflows. Roughly half of all talks had an AI angle.
* Testing AI systems requires fundamentally new approaches: Several talks distinguished between using AI for testing vs. testing AI itself — covering hallucination detection, bias measurement, adversarial/red-team testing, behavioral validation of agentic systems, and model comparison. The message was clear: traditional deterministic test assertions don't work for probabilistic AI outputs.
* EU regulatory compliance emerging as a major concern: Multiple sessions covered DORA, the AI Act, NIS2, and CSA — signaling that European testers are grappling with how new legislation impacts testing strategies, especially around AI systems and operational resilience.
* Playwright as the go-to automation framework: Playwright appeared repeatedly — in dedicated talks, workshops (visual regression testing), and AI-assisted test generation sessions (GitHub Copilot + Playwright). It has clearly become the dominant tool in the test automation space, overtaking older frameworks like Selenium.
* Quality culture and team dynamics featured prominently: A dedicated "Teams & Culture" track ran across multiple days, with talks on mentorship for new testers, game theory in teamwork, building QA communities, remote QA team management, and global testing transformation at ING — showing the industry recognizes that tooling alone isn't enough.
* Test-first and spec-driven development making a comeback: Multiple speakers advocated for writing tests before code, now supercharged by AI pair programming. Chris Harbert's talks on test-first development and Haim Michael's Spec-Driven Development with Kiro both pushed back against the "generate code first, test later" trend that AI coding tools have encouraged.
* Observability and CI/CD shifting left into testing: My talk and several others highlighted that monitoring shouldn't stop at production — DORA metrics, CI/CD observability, and pipeline performance are becoming first-class concerns for QA teams, not just DevOps.
* The "role of the tester" identity crisis: A recurring undercurrent across talks — from "The Fear of Becoming Irrelevant" to "Beyond Bugs: How AI Turns QA into Full-Cycle Engineers" to the keynote on digital disaster — the conference grappled with how AI is reshaping what it means to be a tester, with speakers split between alarm and opportunity.

## Scuttlebutt and Travel

* Funnily enough, I actually got accepted for this talk in 2024, but I got sick at the last minute and had to cancel.
* Did my EITA thumbprint and photo, worked fine, will make traveling a bit easier in the future
* Lithuania continues to be a bit of a dark horse tech hub - Lot of tech companies here, Uber still has a big office here
* Scooters everywhere!
* Pistachio McFlurry gooooood

## Day 1 (22nd October 2025)

### **Keynote | Code Without Caution: AI's Path to the Next Digital Disaster - Leigh Rathbone**

* **09:00 (EET) / 07:00 (GMT) - 1 hour**
  * Track: AI-Powered Testing | Hall 5
  * [Session Link](https://events.pinetool.ai/3498/#sessions/110794)
  * [Video](https://www.youtube.com/watch?v=NSYbs7iVaMc)
* **Talk Summary**
  * Rathbone frames the talk as a warning + call to action: AI isn’t a Terminator-style takeover story; it’s “here to stay,” and people in quality/testing can “go back to work on Monday and change the world” by shaping how it’s used.
  * He builds credibility by tracing 27 years at the edge of tech + QA trends: from MMS and early touchscreen smartphones/smartwatches to DRM + progressive download (leading to streaming), plus shifts like test automation, exploratory/combinatorial testing, agile adoption, QE over QA, and “testers do glue work.”
  * The “next digital disaster” won’t be AI’s fault—it’ll be ours: we’ll ship more code than ever in the next 5 years, automate more processes, put agents into decision-making, and risk trusting AI too much—especially under exec pressure to move fast—while losing deep “tacit knowledge” of systems we can no longer repair when they fail.
  * What accelerates disaster is human behavior, not technology: capitalism chasing profit, unethical service-provider practices (billing “AI work” as human work), sprinting without safeguards, and—most of all—lack of governance, caution, care, and quality.
  * His prescription: “Governance, Caution, Care, Quality” + empower question-askers: treat governance as a steering wheel (invisible when it works), insist on kill-switch thinking, use care/ethics as AI’s “compass,” and make quality the team’s superpower—using practical habits like pairing/peer review for AI output and aligning with standards/regulation (he cites ISO/AI governance frameworks and EU regulation), because “you are the next trend.”

### **Large Action Models Are Coming For Your Testing Frameworks! - Adam Sandman**

* **10:10 (EET) / 08:10 (GMT) - 45 minutes**
  * Track: Performance & Load | Hall 2
  * [Session Link](https://events.pinetool.ai/3498/#sessions/110577)
  * [Video](https://www.youtube.com/watch?v=kkbMCe98GUE)
* **Talk Summary**
  * AI is reshaping software testing in waves: we’ve moved from “LLMs as helpers” (content/code generation) → agentic AI (autonomous decision-making) → an emerging era of “digital teams” where multiple agents collaborate to deliver outcomes, raising major safety/quality questions.
  * Large Action Models change what “automation” means: vision + action models can operate computers like humans (inferring UI actions from screens), enabling new kinds of testing—but also introducing scary failure modes and accountability gaps when agents make non-deterministic decisions.
  * Vibe coding boosts speed but breaks testability: letting tools build whole apps quickly is great for throwaway/low-risk work, but small changes can regenerate different UIs/DOMs and invalidate test suites—making reliability and edge cases hard to manage.
  * The “return of requirements” via spec-based development: putting requirements/design/tests into structured markdown specs enables more maintainable AI-built software; the feedback loop shifts from fixing code to fixing requirements, with AI regenerating the app + rerunning tests.
  * QA must evolve into quality supervision: AI increases code volume and risk (more vulnerabilities, more missed edge cases), so humans shift from manual testing to risk/architecture/fit-for-purpose oversight, using AI for smoke testing, test generation/data, flaky-test analysis, and “self-healing” UI tests—while acknowledging AI outputs are drafts, not inherently reliable.

### **Defining "DevExT", the Developer Experience in Testing - Thomas Schoemaecker**

* **11:20 (EET) / 09:20 (GMT) - 45 minutes**
  * Track: Teams & Culture | Hall 1
  * [Session Link](https://events.pinetool.ai/3498/#sessions/113429)
  * [Video](https://www.youtube.com/watch?v=dIkj-4w8swA)
* **Talk Summary**
  * DevEx in testing is both technical and emotional: It’s the sum of a tester/developer’s interactions and feelings while building, running, debugging, and maintaining tests—tools, processes, culture, and psychological safety all matter.
  * Foundation: shift-left + automation + empathy: Clear shared responsibilities between devs and testers (e.g., good handovers, solid unit tests, clean bug reports, low-flake suites) create the baseline for a healthy testing experience.
  * Avoid “basement testing” anti-patterns: Toxic pressure, slow builds, messy/unsafe test setups, unreliable logs, poor environments, and constant context switching destroy DevExT and trust in quality.
  * Practical “commandments” to improve DevExT: Prefer mature open-source over fragile custom frameworks, invest in proper test/pre-prod infrastructure (don’t bypass security like SSO/MFA), use strong APIs, automate repetitive work, and aggressively debug/deflake to keep suites trustworthy.
  * People and purpose amplify quality: Good leadership and meaning (linking QA work to business outcomes) drive engagement; AI can be a “superpower” for productivity, but testers remain key “human anchors” with strong business/industry understanding.

### **Break and Practise**

* I missed on the ignites because I wanted to grab lunch, practise my talk and double check slides
* I went up to my room early to watch the talks before my slot and to scope out the setup and location

### **My Talk - CI/CD Observability, Metrics and DORA: Shifting Left and Cleaning Up! - Peter Souter**

* **14:10–14:55 (EET) / 12:10–12:55 (GMT) - 45 minutes**
  * Track: Performance & Load | Hall 2
  * [Session Link](https://events.pinetool.ai/3498/#sessions/112207)
  * [Video](https://www.youtube.com/watch?v=DfYBdBl1LcM)
* **Talk Summary**
  * **Core principle:** Across SDLC/Agile/DevOps, the recurring theme is **small batch sizes \+ tight feedback loops**; "waterfall" is framed as a misread of Royce's original warning rather than the intended best practice.
  * **The CI/CD ownership gap:** Modern orgs monitor production well, but CI/CD often has "no one / everyone" owning it—creating a governance smell and "tragedy of the commons." The talk argues CI/CD should be treated like a **product** with clear ownership and SLOs.
  * **Measure to improve (qual \+ quant):** Use **surveys** to find pain points, but rely on **systems data** for real progress—e.g., build queue time (p95), pipeline success rate, and lead time from laptop → production—so you can turn "vibes" into actionable priorities and investment cases.
  * **Case studies & GenAI tradeoffs:** GenAI boosts perceived individual productivity but can reduce overall delivery throughput/stability ("productivity paradox"), reinforcing the need for small batches. Examples include Slack's structured flaky-test workflow (moving CI success from \~20% to \~98%) and Datadog's CI visibility/test impact analysis and dashboards (saving significant CI time), culminating in using **DORA metrics** (deploy freq, lead time, change fail rate, time to restore) as system-level outcomes—not individual KPIs.
* **My Personal Notes:**
  * Went well overall I think, been such a long time I was a bit nervous at first, but once the talk started going, I eased back into it.

### **The Fear of Becoming Irrelevant - Jonas Hermansson**

* **15:05–15:50 (EET) / 13:05–13:50 (GMT) - 45 minutes**
  * Track: AI-Powered Testing | Hall 5
  * [Session Link](https://events.pinetool.ai/3498/#sessions/111172)
  * [Video](https://www.youtube.com/watch?v=pX1zx7v1n6E)
* **Talk Summary**
  * Career arc into testing: Jonas starts as a Java developer, then gets moved into project leadership and business unit leadership (during the dot-com crash), before “tricking” his way into a tester role at the Swedish pension authority—and ends up loving software testing.
  * What he dislikes about classic testing: Over time, the “boring parts” of testing (test data management, long test reports, manual test scripts) became frustrating—even though he still enjoys figuring out what to test and how to test for real user needs.
  * AI as a force-multiplier for testers: Using tools like ChatGPT/Claude helped him automate or accelerate many tedious tasks (test strategies, test data, test cases, bug-fixing), and later enabled “vibe coding” into rapid prototyping and building test tools/simulators.
  * Shift to “AI engineering” with agent teams + TDD wrapper: His company evolved from vibe coding to a more structured setup: multiple AI agents (backend dev, UI testing, requirements, code review, etc.) working like a vertical team, with test-driven practices to keep regenerated code consistent and reliable—plus some manual exploratory testing at the end.
  * Core thesis: resistance comes from fear of lost status (and how to manage it): He argues much of the AI backlash in testing is driven by “experts” fearing loss of social status/income as old expertise becomes less valuable; his advice is to focus change energy on early adopters, educate skeptics, then reintegrate them so they can remain valued contributors rather than exiting.
* **My Personal Notes:**
  * TBC

### **Keynote | Zen-Driven Development: Protect Your Sanity - Csaba Szokocs**

* **16:10–17:10 (EET) / 14:10–15:10 (GMT) - 1 hour**
  * Track: Strategy & Methodology | Hall 5
  * [Session Link](https://events.pinetool.ai/3498/#sessions/112204)
  * [Video](https://www.youtube.com/watch?v=C6_yWT1gjNo)
* **Talk Summary**
  * Zen camp wake-up call: Csaba shares how a Zen retreat’s strict, early routine revealed how much can be achieved with structure—and inspired him to rethink stress and productivity in daily work.
  * Root problem: nobody protects your time but you: Meetings and “urgent” requests will fill every gap unless you set boundaries and actively defend focus and sanity.
  * Protect your time with your calendar: Put important work on your calendar (not just meetings), leave ~20% free for others, treat time like a budget, and plan 1–2 weeks ahead to work with busy stakeholders.
  * Protect your focus by removing distractions: Single-tasking beats multitasking (which increases stress and errors); put your phone away, close non-essential apps (email/Slack/Teams), tidy your workspace, and use techniques like Pomodoro to sustain deep work.
  * Protect your sanity with micro-breaks and better meeting habits: Short breaks between meetings (even 5 minutes) reduce stress; hold shorter meetings, start meetings 5 minutes late (“Zen break”), and use systems like GTD (capture → clarify → organize → reflect → engage) to keep your mind clear.

## Day 2 (23rd October 2025)

### **Keynote | How to Steal AI's Job - Filip Hric**

* **09:00–10:00 (EET) / 07:00–08:00 (GMT) - 1 hour**
  * Track: AI-Powered Testing
  * [Session Link](https://events.pinetool.ai/3498/#sessions/112125)
  * [Video](https://www.youtube.com/watch?v=irhDY3hgY1w)
* **Talk Summary**
  * AI "took my job," but not the way people think: Filip explains his layoff at Replay as part of a pivot to "AI," driven by weak sales/positioning and market pressure—not a robot literally replacing him—then uses that story to frame common emotions (fear, confusion, pessimism).
  * Zoom out: layoffs are a "perfect storm," not just AI: He argues job-market pain is strongly tied to macro factors (especially higher interest rates and post-COVID hiring normalization), with AI hype/investor pressure accelerating pivots and org downsizing.
  * Demystify AI with a practical mental model: LLMs are "next token predictors" that get powerful through scale; much of ChatGPT usage is non-programming (writing, guidance, tutoring), and the best antidote to fear is understanding what AI is and isn't good at.
  * There's a path for testers: your skills become more valuable, not less: He maps tester strengths to the AI era—building reliable test automation loops for AI-built apps, doing evals for non-deterministic systems, and focusing on AI/security validation (guardrails, prompt-injection defenses, layered checks).
  * Win by "context engineering" + disciplined workflows: The differentiator isn't prompting magic, it's providing crisp problem definitions, constraints, rules, and workflows (e.g., IDE rules/commands, agents/sub-agents, summarizing context to stay within limits) so AI produces higher-quality output—leading to his conclusion: embrace learning, stay human-in-the-loop, and you can "take your job back."

### **Navigating the Testing Wilderness: Mind Maps and AI as Your Trusted Compass - Igor Goldshmidt**

* **10:10–10:55 (EET) / 08:10–08:55 (GMT) - 45 minutes**
  * Track: Strategy & Methodology
  * [Session Link](https://events.pinetool.ai/3498/#sessions/112108)
  * [Video](https://www.youtube.com/watch?v=8Ee9JckkFMg)
* **Talk Summary**
  * Testing in fast-moving teams often feels like being "lost in the wilderness" due to constant scope changes, context-switching, and mismatched expectations between product, dev, and QA.
  * Mind maps act as a practical navigation tool: they visualize context, expose connections, and make it faster to understand/communicate test scope than text-heavy docs or checklists.
  * Mind maps are especially useful for test planning/design and team alignment (e.g., "test plan reviews"), helping teams focus on one branch/area at a time and collaborate more effectively.
  * Common pitfalls: going too deep into details, spending time on visual styling over substance, and building maps alone instead of using them as a shared team artifact/snapshot.
  * AI can be used as a "compass" to speed up mind map creation and maintenance (e.g., generating a draft from PRDs/docs into formats like Markdown for XMind), but outputs must be reviewed—use AI in small building blocks rather than asking it to do the entire testing lifecycle end-to-end.

### **Testing Documentation: Why So Technical? - Ana Duarte**

* **11:20–12:05 (EET) / 09:20–10:05 (GMT) - 45 minutes**
  * Track: Strategy & Methodology
  * [Session Link](https://events.pinetool.ai/3498/#sessions/112645)
  * [Video](https://www.youtube.com/watch?v=CC8KQaVZrSs)
* **Talk Summary**
  * Most testing documentation is too "how"-focused and misses the "why". Good docs should explain context, benefits, and the reasons a feature works the way it does—not just steps.
  * Documentation is essential for scalability, but only if it's useful and up to date. Outdated or incomplete docs can be worse than none because they create confusion.
  * Write for an unknown audience by default. Don't assume reader expertise; make docs understandable for both "5 minutes in" beginners and "5 years in" power users.
  * Make docs more relatable with examples and visuals. Use real-life scenarios, concrete language, screenshots, step-by-step guides, and avoid abstract jargon.
  * Docs are a "living beast" and need ongoing maintenance. The ideal fix is making documentation part of the Definition of Done, plus staying close to product/dev teams so changes get reflected.

## Conclusion

* Left after lunch on Day 2/23rd as I had family commitments
