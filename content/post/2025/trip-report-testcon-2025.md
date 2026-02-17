---
title: "Trip Report: Speaking at Testcon 2025"
date: 2026-02-17T04:02:56Z
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
  * FOO
  * BAR
  * BAZ

### **Large Action Models Are Coming For Your Testing Frameworks! - Adam Sandman**

* **10:10 (EET) / 12:10 (GMT) - 45 minutes**
  * Track: Performance & Load | Hall 2
  * [Session Link](https://events.pinetool.ai/3498/#sessions/110577)
  * [Video](https://www.youtube.com/watch?v=kkbMCe98GUE)
* **Talk Summary**
  * FOO
  * BAR
  * BAZ

### **Defining "DevExT", the Developer Experience in Testing - Thomas Schoemaecker**

* **11:20 (EET) / 12:10 (GMT) - 45 minutes**
  * Track: Teams & Culture | Hall 1
  * [Session Link](https://events.pinetool.ai/3498/#sessions/113429)
  * [Video](https://www.youtube.com/watch?v=dIkj-4w8swA)
* **Talk Summary**
  * FOO
  * BAR
  * BAZ

### Break and Practise

* I missed on the ignites because I wanted to grab lunch, practise my talk and double check slides
* I went up to my room early to watch the talks before my slot and to scope out the setup and location

### **My Talk - CI/CD Observability, Metrics and DORA: Shifting Left and Cleaning Up! - Peter Souter**

* **14:10–14:55 - 45 minutes**
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

* **15:05–15:50 - 45 minutes**
  * Track: AI-Powered Testing | Hall 5
  * [Session Link](https://events.pinetool.ai/3498/#sessions/111172)
  * [Video](https://www.youtube.com/watch?v=pX1zx7v1n6E)
* **Talk Summary**
  * FOO
  * BAR
  * BAZ
* **My Personal Notes:**
  * Went well overall I think, been such a long time I was a bit nervous at first, but once the talk started going, I eased back into it.

### **Keynote | Zen-Driven Development - Protect Your Sanity**

* **16:10–17:10 (EET) / 14:10–15:10 (GMT) - 1 hour**
  * Track: Strategy & Methodology | Hall 5
  * [Session Link](https://events.pinetool.ai/3498/#sessions/112204)
  * [Video](https://www.youtube.com/watch?v=C6_yWT1gjNo)
* **Talk Summary**
  * FOO
  * BAR
  * BAZ

## Day 2 (23rd October 2025)

### **Keynote | How to Steal AI's Job**

* **09:00–10:00 (EET) / 07:00–08:00 (GMT) - 1 hour**
  * Track: AI-Powered Testing
  * [Session Link](https://events.pinetool.ai/3498/#sessions/112125)
  * [Video](https://www.youtube.com/watch?v=irhDY3hgY1w)
* **Talk Summary**
  * FOO
  * BAR
  * BAZ

### **Navigating the Testing Wilderness: Mind Maps and AI as Your Trusted Compass**

* **10:10–10:55 (EET) / 08:10–08:55 (GMT) - 45 minutes**
  * Track: Strategy & Methodology
  * [Session Link](https://events.pinetool.ai/3498/#sessions/112108)
  * [Video](https://www.youtube.com/watch?v=8Ee9JckkFMg)
* **Talk Summary**
  * FOO
  * BAR
  * BAZ

### **Testing Documentation: Why So Technical?**

* **11:20–12:05 (EET) / 09:20–10:05 (GMT) - 45 minutes**
  * Track: Strategy & Methodology
  * [Session Link](https://events.pinetool.ai/3498/#sessions/112645)
  * [Video](https://www.youtube.com/watch?v=CC8KQaVZrSs)
* **Talk Summary**
  * FOO
  * BAR
  * BAZ

## **Conclusion**

* Left after lunch on Day 2/23rd as I had family commitments
*
