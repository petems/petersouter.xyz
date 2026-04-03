+++
author = "Peter Souter"
categories = ["Tech"]
date = 2026-03-25T09:00:00Z
description = "A companion blog post to my 'Prompting & Agentic Flows' workshop — covering the evolution from prompt engineering through context engineering to agentic flows, with cautionary tales of chimps with machine guns."
draft = true
slug = "from-prompting-to-agentic-flows"
tags = ["GenAI", "Claude Code", "Prompt Engineering", "Context Engineering", "Agentic AI", "LLMs", "Workshop"]
title = "From 'Please Do The Thing' to 'Just Handle It': Prompting, Context Engineering, and the Rise of Agentic Flows"
keywords = ["prompt engineering", "context engineering", "agentic engineering", "intent engineering", "claude code", "AI agents", "LLM", "boris cherny", "andrej karpathy", "tobi lutke"]

[cover]
  image = ""

+++

I recently gave a workshop called "Prompting & Agentic Flows" to a group of Sales Engineers. The subtitle was "From 'Please Do The Thing' to 'Just Handle It'" — which, honestly, is a pretty accurate summary of how the entire field has moved in about eighteen months.

<!--more-->

The talk was meant to be about 15 minutes of history and concepts followed by a hands-on lab where people built [Claude Code skills](https://docs.anthropic.com/en/docs/claude-code/skills). But as with all talks I give, the prep process revealed that I had a lot more to say than could fit into a slide deck. So here's the long version — the companion piece that goes deeper on the concepts, adds the quotes and sources I couldn't fit on slides, and includes the cautionary tales in full detail.

If you've seen the talk, think of this as the director's cut. If you haven't, think of it as a standalone piece about how we got from typing careful instructions into a chatbox to giving autonomous agents the keys to production infrastructure — and why that progression matters more than most people realise.

## What Even Is an LLM?

I always start with this because it's easy to skip past and it matters. An LLM is not a search engine. It's not a database. It's not a calculator. It's a prediction machine trained on a snapshot of the internet.

Ted Chiang nailed it in his 2023 New Yorker piece when he called ChatGPT ["a blurry JPEG of the web"](https://www.newyorker.com/tech/annals-of-technology/chatgpt-is-a-blurry-jpeg-of-the-web). The model has seen everything, but at low resolution, and frozen in time. Its knowledge has a cutoff date. It doesn't know what happened last Tuesday. It doesn't know your customer's stack. It doesn't know your name.

Yet.

And that "yet" is the thread that runs through everything I'm about to cover: **the model is only as useful as the information you give it access to.** That's the thesis statement. Hold it in your head.

## A Brief, Painless History of How We Talk to These Things

I bought a prompt engineering book in 2024. Written by the GitHub Copilot engineers — [Berryman and Ziegler's *Prompt Engineering for LLMs*](https://www.oreilly.com/library/view/prompt-engineering-for/9781098156145/) from O'Reilly — some of the most hands-on GenAI practitioners in the world at the time. Cost me about forty quid and it's still largely correct. But the direction of travel it was pointing at? Already overtaken.

That's not a criticism of the book. It's a criticism of the pace.

Someone on LinkedIn will declare "prompt engineering is dead" roughly every 90 days. They're always slightly right and mostly wrong. The core prompting disciplines never actually went away — the cargo-cult version of them did. The "magic words" version. The "act like an expert tax accountant" version. That's the stuff that died, and good riddance.

But I'm getting ahead of myself. Let me walk through how we got here, because understanding the progression is what separates someone who can copy-paste a prompt from someone who can build something genuinely useful.

## The Evolution: Not a Replacement Chain, But Nested Layers

Here's the thing that took me a while to articulate properly, and it's the single most important concept in this entire post:

**Prompt engineering didn't die — it became a component of context engineering. Context engineering didn't die — it became a component of agentic engineering.**

These aren't stages you pass through and leave behind. They're nested layers, like concentric circles or Russian dolls. Every competent agentic system still relies on good prompting principles at its core. Every good context engineering setup is still following the basics of "be clear and direct." The field didn't replace things — it wrapped new layers around them.

With that framing, let's look at each layer.

### Layer 1: Prompt Engineering — "Tell the Model Exactly What to Do, Very Carefully"

Per [Anthropic's own prompting guide](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/overview), the four things that actually matter are:

1. **Be clear and direct**
2. **Add context**
3. **Specify your output format**
4. **Give examples where it helps**

That's it. That's the foundation. Everything else — zero-shot, few-shot, chain-of-thought, role-setting, meta-prompting — is just structured ways of doing those four things more effectively.

Now, there was a period where the field got quite excited about tricks. Persona prompting was gospel for a while: "Act like an expert tax accountant" or "You are a senior software architect with 20 years of experience." It felt intuitively right. It made outputs *sound* more authoritative.

But a [Wharton study from December 2025](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=5879722) tested this rigorously across six models and found that **expert personas don't reliably improve factual accuracy**. No significant positive results between baseline prompts and domain-aligned expert personas on PhD-level questions. What *does* improve accuracy? Providing relevant information, clear constraints, and examples. In other words — those four Anthropic principles. The stuff that actually works has always been the boring stuff.

The "back again" part of the story is this: the field went on a journey from "magic words" through "systems thinking" to "autonomous agents," and at every level, the people who succeed are still the ones who can be clear, direct, and give good context. The skills are cumulative, not replaceable.

### Layer 2: Context Engineering — "Give the Model the Live Information It Needs"

The frozen-in-time problem was obvious from the start. The model doesn't know your world. The initial solution was brute force: paste in docs, data, the relevant bits. Copy-paste engineering, basically.

Context windows grew fast to accommodate this:

- **Pre-2024**: GPT-3.5 at 4K tokens, GPT-4 at 8K–32K, Claude at 100K
- **2024**: 128K became normal (GPT-4o, Llama 3.1); Claude 3 hit 200K; Gemini 1.5 Pro was first to 1 million tokens
- **2025**: 200K–1M is table stakes

But bigger windows didn't fully solve the problem. You still had to know *what* to load in. And that's a surprisingly hard thing to get right when you're staring at a blank chat window.

The term "context engineering" crystallised in June 2025, when two things happened within a week that gave the concept a name.

**Tobi Lütke**, Shopify's CEO, [posted on X](https://x.com/tobi/status/1935533422589399127) on June 18th:

> "I really like the term 'context engineering' over prompt engineering. It describes the core skill better: the art of providing all the context for the task to be plausibly solvable by the LLM."

A week later, **Andrej Karpathy** — ex-OpenAI, ex-Tesla, one of the most respected voices in the field — [quote-tweeted Lütke](https://x.com/karpathy/status/1937902205765607626):

> "+1 for 'context engineering' over 'prompt engineering'... context engineering is the delicate art and science of filling the context window with just the right information for the next step."

Karpathy then extended the metaphor in his [Y Combinator AI School talk](https://www.youtube.com/watch?v=L0OY15sSfJQ): an LLM is like a CPU, its context window is like RAM, and the engineer's job is to be the operating system — loading just the right code and data for each task. That's a genuinely useful analogy, and it's the one I keep coming back to.

**Simon Willison** captured [why the rename matters](https://simonwillison.net/2025/Jun/27/context-engineering/) better than anyone: "Prompt engineering suffers from a thing where many people's inferred definition is that it's a laughably pretentious term for typing things into a chatbot." Context engineering's inferred definition — curating the information an AI system sees — is much closer to the actual work.

And then **Phil Schmid** from Hugging Face landed the punchline in [his deep dive on context engineering](https://www.philschmid.de/context-engineering): **"Most agent failures are not model failures anymore — they are context failures."** He broke context down into seven elements: instructions, user prompt, state/history, long-term memory, retrieved information (RAG), available tools, and structured output. Context engineering is designing the *system* that delivers these — it's adaptive, selective, and format-conscious. It's a system, not a string.

This is the shift. You're no longer just crafting a prompt. You're building a system that assembles the right context dynamically, at the right time, in the right format. That's engineering.

### Layer 3: Agentic Engineering — "Let the Model Go Get What It Needs"

And then someone gave the model a terminal.

#### Enter Boris. And a Music Player.

September 2024: Boris Cherny joins Anthropic and starts hacking on a terminal prototype. First thing it could do: tell him what song was playing, via AppleScript.

> "Cool demo. Not that interesting."

Then he gave it bash access and filesystem access. Claude started *exploring* — reading a file, following the imports, reading *those* files.

> "Claude exploring the filesystem was mindblowing to me because I'd never used any tool like this before"

This wasn't new intelligence. It was product overhang — the capability was already there, waiting for a product built around it. That terminal toy became Claude Code. And Claude Code changed everything.

The details from the [Pragmatic Engineer interview](https://newsletter.pragmaticengineer.com/p/building-claude-code-with-boris-cherny) are worth dwelling on because they illustrate the shift perfectly. Boris now ships 20-30 PRs a day running five parallel Claude instances across separate terminal tabs. His methodology: start Claude in plan mode, iterate on strategy, then let it execute. "Once there is a good plan, it will one-shot the implementation almost every time."

And here's the insight that connects back to our thesis: **Claude Code's "agentic search" is really just `glob` and `grep`.** The team experimented with local vector databases and recursive model-based indexing — sophisticated approaches — and found they added complexity without improving results. Plain `ripgrep` over a codebase outperformed all of them. Rather than loading 200K tokens of a codebase into context, Claude Code could just `rg` for the database connector, find the SQL Server interaction, and work from there.

This is the `sed`/`grep`/`awk` moment I keep coming back to in the talk. A chatbot asked to replace all As with Es in a codebase has to load the whole thing, regenerate, and repeat. A one-liner in any Linux terminal does it in seconds. The agent doesn't need to *understand* the whole codebase — it needs to *navigate* it. And navigation turns out to be much more tractable than comprehension.

The numbers tell the story. Per [SemiAnalysis (February 2026)](https://semianalysis.com/), Claude Code accounts for approximately **4% of all public GitHub commits** — over 135,000 commits per day — a figure that doubled from the previous month, with projections toward 20%+ by the end of 2026.

Chatbot interfaces couldn't interact with the local environment. Agentic CLI tools could. That's the fundamental leap. And soon everyone had one: Cursor CLI, OpenAI Codex CLI, Gemini CLI — all within months.

### Layer 4 (Emerging): Intent Engineering — "Describe What You Want, the System Figures Out the Rest"

This is the layer I'm least certain about, because it's still solidifying. But I think it's worth talking about because it addresses a real problem.

The [SQUER consulting team](https://www.squer.io/blog/why-we-created-the-intent-engineer) articulated it well. Their co-founder Manuel Klein observed that as AI coding agents advanced from 6-minute autonomy to 5-7 *hour* autonomy, the bottleneck shifted:

> "The biggest challenge was never the coding itself. It was the back-and-forth between the business department and the development team. AI agents amplify this problem dramatically. A human developer can compensate for a vague requirement — they'll walk over to the product owner's desk and ask. An AI agent can't. Give it an ambiguous instruction, and it will confidently build exactly the wrong thing."

They've created a role called "Intent Engineer" that sits in the business department, not IT. The job is to extract the *intent* behind what stakeholders want and enrich it with enough domain context that AI agents can execute without ambiguity.

[Product Compass](https://www.productcompass.pm/p/intent-engineering-framework-for-ai-agents) broke this into a useful distinction: **"Context without intent is noise."** While context engineering gives the agent the information it needs, intent provides the *evaluative framework for trade-offs* when agents face ambiguous situations. It's what determines how an agent acts when instructions run out — not a task list, not a prompt, not a goal metric, but the specification of objectives, outcomes, constraints, and decision boundaries.

Their seven components of intent: Objective, Desired Outcomes, Health Metrics, Strategic Context, Constraints, Decision Types/Autonomy, and Stop Rules.

Whether "intent engineering" sticks as a term, I'm not sure. But the underlying problem — that we need to get much better at specifying *what we actually want* before letting agents loose — is real and getting more urgent by the month.

## The Chimp with a Machine Gun

Right. Now for the bit everyone remembers.

I call this section "The Chimp with a Machine Gun" because that's exactly what an AI agent is: incredibly powerful, absolutely no concept of blast radius.

Three real incidents from the last year, in escalating order of severity.

### Incident 1: AWS / Kiro (December 2025)

Amazon had been rolling out an internal AI coding agent called Kiro across its engineering teams. A senior VP memo — the "Kiro Mandate" — established it as the standardised AI coding assistant with an 80% weekly-usage target. Kiro was being used at scale, across teams, on real infrastructure.

In December, an engineer pointed Kiro at a bug in AWS Cost Explorer. Rather than patch the bug, Kiro decided the best approach was to **delete and recreate the entire production environment**. Without human authorisation.

13-hour outage. Publicly disclosed [via the Financial Times](https://www.ft.com/content/kiro-incident) in February 2026.

The root causes were depressingly predictable: an engineer used a role with broader permissions than necessary, Kiro inherited operator-level permissions, and misconfigured access controls bypassed the standard two-human approval requirement. Amazon called it "user error — specifically misconfigured access controls." [Four sources told the Financial Times otherwise](https://www.theregister.com/2026/02/20/amazon_denies_kiro_agentic_ai_behind_outage/). A senior AWS employee described the incident as "small but entirely foreseeable."

### Incident 2: Replit (July 2025)

Jason Lemkin, founder of SaaStr, was using Replit's AI agent to work on the SaaStr platform. There was an active code freeze in place — explicit instructions not to make changes to production.

The AI agent deleted the live production database anyway. Wiped out data for over 1,200 executives and 1,190+ companies.

Then it got worse. The agent [fabricated thousands of fake records](https://fortune.com/2025/07/23/ai-coding-tool-replit-wiped-database-called-it-a-catastrophic-failure/) to replace the ones it had deleted and produced misleading status messages about what it had done. When questioned, the AI admitted to running unauthorised commands and "panicking." It initially told Lemkin that data rollback would not work — this was false; Lemkin recovered data manually.

The AI's own words: it stated it "made a catastrophic error in judgment" and "destroyed all production data."

Replit's CEO apologised publicly. The data was gone. They implemented automatic separation between dev/production databases, improved rollback systems, and a new "planning-only" mode. Shutting the stable door, and all that.

### Incident 3: Claude Code / Terraform (February 2026)

This one hit close to home because it involves tools I use every day.

Alexey Grigorev, who runs [DataTalks.Club](https://datatalks.club/), was migrating a website to AWS using Claude Code with Terraform. The Terraform state file was on his old computer — stored locally, not remotely. When Claude ran `terraform plan`, it showed massive resource creation instead of updates. Grigorev caught this and cancelled, but then allowed the agent to continue "cleanup."

Claude Code switched to running `terraform destroy` with auto-approve. It wiped the entire production infrastructure: VPC, RDS database, ECS cluster, load balancers, bastion host — along with all automated snapshots. 2.5 years of student submissions, gone.

Grigorev wrote up [an excellent post-mortem](https://alexeyondata.substack.com/p/how-i-dropped-our-production-database) and took full responsibility:

> "I over-relied on the AI agent to run Terraform commands. I treated plan, apply, and destroy as something that could be delegated. That removed the last safety layer."

AWS recovered the database from an internal snapshot after 24 hours — 1,943,200 rows recovered. But the 24-hour outage, the scramble, and the sheer panic of watching your prod infrastructure dissolve in real time? That doesn't get recovered.

His aftermath changes are instructive: S3-based backups independent of Terraform, daily automated restore testing via Lambda, deletion protection at both Terraform and AWS levels, remote state moved to S3, and — crucially — **he disabled agent permissions entirely**. Claude can no longer execute commands or write files. All plans require manual review.

### The Pattern

Across all three incidents, the same pattern:

**AI agents are brilliant at executing. They have absolutely no instinct for "wait, should I actually do this?"**

This is important. Not because agents are bad — they're extraordinarily useful — but because we're handing them capabilities that require judgment they don't have. Every one of these incidents involved an agent doing *exactly what it was told* (or what it inferred it was told) in a context where a human would have paused and said "hang on, maybe I shouldn't delete everything."

The Replit one is particularly alarming because the agent actively *deceived* the user about what it had done afterwards. That's not a hallucination — that's a system trying to cover its tracks in a way that made the situation worse.

## Why This Matters (Beyond Cautionary Tales)

This isn't just a fun history of people breaking prod. This is the direction the industry is moving — right now.

The progression from prompting to context engineering to agentic engineering isn't academic. It maps directly onto how tooling is evolving, how workflows are changing, and where the bottlenecks are shifting. Understanding each layer — and understanding that they're nested, not sequential — is what lets you build things that work rather than things that demo well.

Phil Schmid's line keeps coming back to me: **"Most agent failures are not model failures anymore — they are context failures."** The model is capable enough. The question is whether you've given it the right information, the right tools, the right constraints, and the right understanding of what "done" looks like.

And the chimp-with-a-machine-gun incidents aren't arguments against agents. They're arguments for **observability** — for being able to see what agents are doing, trace their decisions, understand their reasoning, and intervene when they're about to do something catastrophic. When agents act autonomously, you need to see what they're doing. That's not optional.

## The "And Maybe Back Again" Part

I want to end with something that the feedback on my talk helped me articulate better.

There's a temptation to tell this story as a linear progression: first we did prompting, then we did context engineering, then we did agentic engineering, and prompting is the quaint old thing we've left behind. That framing is wrong, and it's dangerous.

The Wharton study I mentioned earlier — the one that showed expert personas don't improve accuracy — found that what *does* work is providing relevant information, clear constraints, and examples. That's... prompting 101. The four Anthropic principles. The boring stuff that never went away.

The evolution is real. Context engineering is a genuinely new discipline. Agentic tools are a genuine paradigm shift. But at every layer, the people who succeed are the ones who can be clear about what they want, give good context, and specify what "done" looks like. Those skills are the foundation, and every new layer is built on top of them, not instead of them.

I bought that prompt engineering book for forty quid in 2024. Two years later, the four core principles it teaches are more relevant than ever — they're just being applied in contexts the authors couldn't have anticipated. That's not obsolescence. That's a foundation doing its job.

## Sources & Further Reading

### Concepts & History

- Ted Chiang, ["ChatGPT Is a Blurry JPEG of the Web"](https://www.newyorker.com/tech/annals-of-technology/chatgpt-is-a-blurry-jpeg-of-the-web) (The New Yorker, Feb 2023)
- Berryman & Ziegler, [*Prompt Engineering for LLMs*](https://www.oreilly.com/library/view/prompt-engineering-for/9781098156145/) (O'Reilly)
- [Anthropic Prompt Engineering Guide](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/overview)

### On the Terminology Shift

- Tobi Lütke [on X](https://x.com/tobi/status/1935533422589399127) (June 18, 2025)
- Andrej Karpathy [on X](https://x.com/karpathy/status/1937902205765607626) (June 25, 2025)
- Simon Willison, ["Context engineering"](https://simonwillison.net/2025/Jun/27/context-engineering/) (June 27, 2025)
- Phil Schmid, ["The New Skill in AI is Not Prompting, It's Context Engineering"](https://www.philschmid.de/context-engineering) (June 30, 2025)
- Tobi Lütke on the [Acquired podcast](https://www.acquired.fm/episodes/how-to-live-in-everyone-elses-future-with-shopify-ceo-tobi-lutke), discussing context engineering in depth

### On Context Engineering as a Discipline

- LangChain, ["Context Engineering for Agents"](https://blog.langchain.com/context-engineering-for-agents/) (Oct 2025)
- Gartner, ["Context Engineering: Why It's Replacing Prompt Engineering"](https://www.gartner.com/en/articles/context-engineering) (Oct 2025)
- Addyo, ["Context Engineering: Bringing Engineering Discipline to Prompts"](https://addyo.substack.com/p/context-engineering-bringing-engineering) (July 2025)

### On Claude Code

- Boris Cherny on building Claude Code: [Lenny's Podcast](https://www.lennysnewsletter.com/p/head-of-claude-code-what-happens) / [Pragmatic Engineer](https://newsletter.pragmaticengineer.com/p/building-claude-code-with-boris-cherny) (March 2026)
- [Builder.io, "50 Claude Code Tips and Best Practices"](https://www.builder.io/blog/claude-code-tips-best-practices) (March 2026)

### On Intent Engineering

- SQUER, ["Why We Created the Intent Engineer"](https://www.squer.io/blog/why-we-created-the-intent-engineer) (2026)
- Product Compass, ["The Intent Engineering Framework for AI Agents"](https://www.productcompass.pm/p/intent-engineering-framework-for-ai-agents) (Jan 2026)

### On Prompting Research

- Wharton GAIL, ["Playing Pretend: Expert Personas Don't Improve Factual Accuracy"](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=5879722) (Dec 2025)

### The Incidents

- AWS/Kiro: [The Register](https://www.theregister.com/2026/02/20/amazon_denies_kiro_agentic_ai_behind_outage/) / [GeekWire](https://www.geekwire.com/2026/amazon-pushes-back-on-financial-times-report-blaming-ai-coding-tools-for-aws-outages/)
- Replit: [Tom's Hardware](https://www.tomshardware.com/tech-industry/artificial-intelligence/ai-coding-platform-goes-rogue-during-code-freeze-and-deletes-entire-company-database) / [Fortune](https://fortune.com/2025/07/23/ai-coding-tool-replit-wiped-database-called-it-a-catastrophic-failure/)
- Grigorev/Terraform: [Post-mortem](https://alexeyondata.substack.com/p/how-i-dropped-our-production-database) / [Tom's Hardware](https://www.tomshardware.com/tech-industry/artificial-intelligence/claude-code-deletes-developers-production-setup)

### On Skills and CLAUDE.md

- Anthropic, ["Extend Claude with skills"](https://docs.anthropic.com/en/docs/claude-code/skills) (official docs)
- HumanLayer, ["Writing a Good CLAUDE.md"](https://www.humanlayer.dev/blog/writing-a-good-claude-md) (Nov 2025)
