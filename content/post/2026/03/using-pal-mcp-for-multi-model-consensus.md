+++
author = "Peter Souter"
categories = ["Tech"]
date = 2026-03-02T12:00:00Z
description = "Why I've started assembling a 'Council of AIs' to review my code, my writing, and my own AI-assisted conclusions — using PAL MCP Server's consensus tool."
draft = true
slug = "using-pal-mcp-for-multi-model-consensus"
tags = ["MCP", "GenAI", "Claude Code", "Code Review", "Tooling", "Consensus"]
title = "Council of AIs: Using Multi-Model Consensus to Keep Your AI Honest"
keywords = ["PAL MCP server", "model consensus", "multi-model AI", "code review", "MCP", "Claude Code", "Gemini", "GPT", "council of AIs", "consensus", "second opinion"]
thumbnailImage = ""
coverImage = ""
+++

I've been on a bit of an MCP kick lately. After [building my own GitHub PR Review MCP server]({{< relref "post/2026/02/my-2026-blogging-plans.md" >}}) to scratch a very specific itch, I found myself wondering: what happens when you stop asking *one* AI model for its opinion and start getting multiple models to argue with each other?

<!--more-->

## Why a Council of AIs Matters

Here's the thing that's been nagging me about AI-assisted development: when you ask a single model to review something, you're getting one perspective shaped by one set of training data, one RLHF process, and one set of built-in assumptions. And that model has a subtle but real incentive to tell you your work is fine.

This isn't a controversial take — sycophancy in language models is well-documented. Models are trained on human feedback that rewards being helpful and agreeable. That's great for brainstorming and pair programming. It's terrible for review tasks where you actually *need* someone to tell you you're wrong.

I've noticed this pattern repeatedly: ask Claude to review code that Claude helped write, and you get a suspiciously positive assessment. The model recognises its own patterns and tends to rubber-stamp them. Same thing happens with GPT reviewing GPT-assisted work, or Gemini reviewing Gemini output. It's not that they *can't* find issues — it's that the default behaviour leans toward agreement.

So what if you bring in models from different providers? Different training data, different RLHF priorities, different default assumptions about what "good" looks like. A pattern that one model's training normalised, another might flag as a red flag.

And what if you go further and explicitly assign stances? Tell one model to advocate, another to critique, a third to stay neutral. Now you've got something closer to a genuine review process — not just "what do you think?" but a structured debate with at least one participant whose job is to find problems.

That's the "Council of AIs" idea. To be clear: this isn't a replacement for human review. Models can all be wrong together, and they'll consistently miss domain-specific context that a teammate would catch immediately. But as a first pass — something to run before you involve another human — it's been genuinely useful for code, for writing, and honestly for questioning any conclusion I've arrived at with AI assistance.

## Enter PAL

[PAL MCP Server](https://github.com/BeehiveInnovations/pal-mcp-server) (Provider Abstraction Layer) is an MCP server that lets your AI CLI of choice — Claude Code, Gemini CLI, Codex CLI, whatever you're using — orchestrate *multiple* AI models within a single workflow. It ships with a whole suite of tools — code review, debugging, planning, pre-commit validation — but the one I want to focus on here is `consensus`, because it's the tool that formalises this Council of AIs approach.

Two things make PAL's consensus particularly powerful beyond just "ask multiple models the same question":

**The context flows between tools.** When you run a consensus review, those findings don't just vanish — they feed into PAL's other tools. A consensus finding can inform the `planner`, which feeds into implementation, and the `precommit` review at the end has the full context from the debate. It's not a one-shot second opinion; it's a persistent thread that other tools in the workflow can build on.

**It can shell out to agentic CLIs via `clink`.** This is the bit that surprised me. PAL's `clink` tool can launch isolated sub-agents in other CLIs — so you can, say, have Codex CLI do a deep-dive code review with its own specialised role, and feed those findings back into the consensus. I've found Codex particularly good at blog criticism, oddly enough — it tends to be blunter than Claude about structural issues. The point is you're not limited to simple API calls; you can go genuinely deep with full agentic workflows as part of the consensus process.

### How Consensus Works

You pose a question or decision, assign models with stances, and PAL manages the structured debate and synthesises the results.

Here's a practical example. I was trying to decide on an approach for a caching layer and ran:

```
Use consensus with gemini-2.5-pro and gpt-5.2 to evaluate:
should we use Redis or an in-memory LRU cache for this service?
```

What you get back isn't just "Model A says X, Model B says Y." PAL runs each model through a structured analysis, lets them consider each other's points, and produces a synthesised recommendation. It's more useful than asking a single model, because each model tends to have different default assumptions and priorities.

Is it perfect? No. Sometimes the models violently agree and you get a consensus that just reinforces whatever the obvious answer was. But when they disagree — that's where it gets interesting, because the *reasons* for disagreement often surface things you hadn't considered.

So I thought: why not point this at something I actually have in front of me?

## Let's Get Meta

I've been working on this very blog post — the first draft was auto-generated by Claude Code — and it occurred to me that the obvious thing to do was to point the consensus tool at it and see what happened. (If you're going to write about a tool, you might as well use it on the thing you're writing, right?)

Here's a generic prompt you can use against pretty much any change on a branch:

```
Get consensus from gpt5.2, gemini pro 3, and o3 on the implementation here.
Concentrate on the git diff between this branch and master and all the work
within this branch.

Critique where necessary, capture any areas we've missed or not thought about.
```

### Why This Model Stack?

I picked GPT-5.2, Gemini 3 Pro, and O3 deliberately:

- **GPT-5.2** is OpenAI's flagship — strong on structured reasoning, thorough in its analysis, tends to be comprehensive
- **Gemini 3 Pro** is Google's flagship — massive context window, good at document-level coherence, trained on different data than the OpenAI models
- **O3** is OpenAI's reasoning model — slower and more deliberate, good at catching logical gaps and inconsistencies

Crucially, you've got two different *providers* here (OpenAI and Google), which means genuinely different training assumptions. And I assigned them stances: GPT-5.2 as advocate (find the strengths), Gemini 3 Pro as critic (find every weakness), O3 as neutral (balanced editorial feedback). That stance rotation means at least one model is *actively looking for problems* rather than defaulting to "looks good to me."

### The Raw Consensus Report

Here's what came back. I'm including the full output because I think showing the raw results is more honest than cherry-picking the highlights. (Eventually I'll figure out a way to link to the full report rather than embedding it inline — consider that a TODO.)

```markdown
## Three-Model Consensus Review: Blog Post Draft

**Models consulted:** GPT-5.2 (advocate, 7/10), Gemini 3 Pro (critic, 9/10), O3 (neutral, 7/10)

### Unanimous Agreement (all 3 flagged)

| Issue | Detail |
|-------|--------|
| **Tool list inconsistency** | Intro lists `thinkdeep`, `debug`, `planner` but never explains them; `challenge` gets a section but wasn't in the intro |
| **Config example mismatch** | Text recommends OpenRouter but JSON snippet only shows `GEMINI_API_KEY` |
| **MCP governance claims unverified** | "Agentic AI Foundation" / Wikipedia link is the biggest credibility risk — needs primary sources or softening |
| **Missing cost/privacy section** | Multi-vendor model use has real cost, latency, and data governance implications that aren't addressed |
| **Setup prerequisites missing** | No mention of Python 3.10+, `uv`, or client config locations |
| **Voice is strong but has brochure-y spots** | "panel of experts" metaphor (line 23) and "structured analysis" (line 40) read slightly generic |

### Majority Agreement (2 of 3)

- **Context threading overclaimed** (GPT-5.2, O3) — PAL threads outputs/summaries into subsequent prompts, not shared internal state. The post makes it sound more magical than it is
- **Needs a concrete anecdote** (GPT-5.2, Gemini) — a real example of PAL catching something would make it feel less like a product overview
- **Title too long** (O3, Gemini) — over 60 chars, will truncate in Google results

### Notable Disagreements

- **O3** claims `codereview` is currently single-pass only (multi-pass is roadmap) — the other two didn't flag this. Worth verifying against PAL docs
- **O3** says `challenge` is a `thinkdeep` flag, not standalone — others treated it as separate
- **Gemini** was most positive on voice match (9/10); GPT-5.2 and O3 were more critical (7/10) about AI-generated tells ("genuinely" repeated, "Honestly?" pattern)

### Priority Action Items

**P0 — Must fix before publishing:**
1. Fix config example to match OpenRouter recommendation
2. Align tool lists (either explain `thinkdeep`/`debug`/`planner` briefly or trim from intro; add `challenge` to intro)
3. Soften or properly source MCP governance claims — link to modelcontextprotocol.io instead of Wikipedia

**P1 — Should fix:**
4. Add a "Costs and Caveats" section (API costs, latency, data privacy with multi-vendor)
5. Add one concrete anecdote of PAL catching something
6. Soften context threading language — clarify it's prompt/output passing
7. Add setup prerequisites (Python 3.10+, `uv`)
8. Tone down `precommit` description (it flags patterns, doesn't run test suites)

**P2 — Nice to have:**
9. Shorten title for SEO (e.g. "Multi-Model Consensus with PAL MCP Server")
10. Add more external links (MCP spec, OpenRouter docs)
11. Address empty `thumbnailImage`/`coverImage` fields (may cause theme issues)
12. Prune one instance of "genuinely" and "Honestly?" to reduce AI tells
```

### What the Consensus Caught

Right, so let's unpack what actually came out of this.

**The config example mismatch.** The first draft recommended [OpenRouter](https://openrouter.ai/) as a good starting point for API keys, then showed a JSON config snippet with `GEMINI_API_KEY`. A reader copying that config would've been confused immediately. This is *exactly* the kind of thing you miss when you've been staring at your own draft — and it's exactly the kind of thing a model reviewing its own output tends to gloss over. Gemini caught it. Boom.

**Tool list inconsistency.** The intro listed seven PAL tools (`chat`, `thinkdeep`, `consensus`, `codereview`, `precommit`, `debug`, `planner`) but the post only explained three of them, and then mentioned `challenge` later without having introduced it. All three models flagged this independently — it reads like documentation copy rather than a practitioner's account.

**MCP governance claims.** I'd written a confident sentence about Anthropic donating MCP to the Linux Foundation's "Agentic AI Foundation" and linked to Wikipedia. GPT-5.2 was the sharpest on this: "Wikipedia is a weak source for a protocol governance claim... this is exactly the sort of thing technical readers will pounce on." Fair point. Either source it properly or hedge it.

**Brochure-y passages.** Two of the three models flagged phrases like "panel of experts" and "structured analysis... synthesised recommendation" as reading like product marketing rather than personal experience. This is a real risk with AI-assisted first drafts — the model defaults to the kind of language it's seen in product pages, not blog posts.

**The interesting disagreement.** O3 claimed that `codereview` is currently single-pass only, with multi-pass being roadmap. The other two models didn't flag this. That's a genuine ambiguity — I'd described a multi-pass workflow, and it's worth verifying against the actual PAL docs whether that's how it works today or how it *will* work. The fact that models disagreed here is itself useful information.

### Why Multi-Model Beat Single-Model Here

This is the bit I find most compelling. Claude Code generated the first draft of this post. If I'd asked Claude to review it, I'd have gotten... well, a polite assessment of its own work. The sycophancy problem cuts both ways — the model that wrote something is the worst possible reviewer of that same thing.

Instead, what happened:

- **Gemini caught the config mismatch** — something Claude had written and wouldn't have flagged in its own output
- **The brochure-y passages** that felt natural to the generating model got called out by models with different calibration for what "sounds like a person"
- **The governance claim** got flagged because different models have different thresholds for "this needs a source" — Claude's training apparently normalised the claim, while GPT-5.2 was more sceptical
- **Stance assignment made it work.** Telling Gemini "be the tough critic — find every weakness" produced sharper feedback than asking "what do you think of this draft?" would have. You're not relying on the model's default agreeableness; you're explicitly routing around it

None of this would've come out of running the same prompt through the same Claude session that wrote the draft. The value isn't just "more models" — it's *different* models with *assigned roles*, which is a fundamentally different review dynamic.

## Other Tools in This Space

PAL is the most full-featured option I've found for this workflow, but if you're specifically interested in the multi-model consensus idea without the broader tool suite, there are a couple of lighter-weight alternatives worth knowing about:

**[Second Opinion MCP Server](https://github.com/politwit1984/second-opinion-mcp-server)** takes a different approach — rather than model-vs-model debate, it synthesises answers from Gemini, Stack Overflow, and Perplexity AI into a single report. It's more "get multiple sources" than "get models to argue," but for coding problems specifically it's a useful lightweight option. You get AI analysis *plus* real community answers from Stack Overflow, which grounds things in actual human experience.

**[Consulting Agents MCP](https://github.com/matthewpdingle/consulting-agents-mcp)** is closer to the Council of AIs idea. It gives your primary CLI access to a roster of named "consultant" agents — each backed by a different model with a specific speciality. There's a reasoning-focused one (O3), a general-purpose one (GPT-4o with web search), a large-context one (Gemini 2.5 Pro for whole-repo analysis), and an extended-thinking one (Claude Sonnet). The nice thing is each consultant has a defined role, so you're not just asking the same question three times — you're getting genuinely different perspectives.

If you just want the core "get a second opinion from a different model" workflow without setting up PAL's full ecosystem, either of these is a solid starting point. The tradeoff is that neither has PAL's context threading between tools or the `clink` agentic bridging — so you get the multi-model perspective but not the persistent workflow integration.

## Setting It Up

Getting PAL running is relatively painless. You'll need Python 3.10+ and `uv` installed, then:

```bash
git clone https://github.com/BeehiveInnovations/pal-mcp-server.git
cd pal-mcp-server
./run-server.sh
```

You'll need API keys for whichever providers you want to use — [OpenRouter](https://openrouter.ai/) is a good starting point since it gives you access to multiple models through a single key. Gemini, OpenAI, Grok, and even local models via [Ollama](https://ollama.ai/) are all supported.

The setup script handles wiring everything into Claude Code, Gemini CLI, or whatever client you're using. There's also a `uvx` one-liner if you don't want to clone the repo:

```json
{
  "mcpServers": {
    "pal": {
      "command": "bash",
      "args": ["-c", "uvx --from git+https://github.com/BeehiveInnovations/pal-mcp-server.git pal-mcp-server"],
      "env": {
        "OPENROUTER_API_KEY": "your-key-here"
      }
    }
  }
}
```

One thing to be aware of: multi-model workflows mean your code and diffs are being sent to multiple API providers. If you're working on something sensitive, consider using local models via Ollama, or be deliberate about which providers you're comfortable sharing code with. The token costs also add up — running a three-model consensus isn't free, and debate patterns can balloon tokens quickly.

## What I've Learned So Far

A few observations from using this:

**Model selection matters, but not as much as you'd think.** I started out agonising over which model to pair with which for each task. After a while, I've settled on "use what's good enough and move on." The biggest gains come from having *any* second perspective from a different provider, not from optimising the specific pairing.

**It's not a replacement for human review.** I want to be clear about this. Multi-model consensus is useful for catching things you might miss, surfacing considerations you hadn't thought of, and doing a first pass before you involve another human. It's not a substitute for having a colleague look at your code. The models can agree on something that's wrong, or miss domain-specific context that a teammate would catch immediately.

**The real value is in the disagreements.** When all three models agree on something, that's useful but unsurprising. When they *disagree* — that's when you learn something. The disagreement about `codereview` being single-pass vs multi-pass told me more about the ambiguity in my own writing than any amount of agreement would have.

## Where MCP Is Going

It's worth stepping back and noting how much the [MCP ecosystem](https://modelcontextprotocol.io/) has grown. The protocol has been moving toward open governance, and the 2026 direction seems to be heading toward agent-to-agent communication — MCP servers that can act as agents themselves. Tools like PAL are early examples of what that multi-agent future looks like in practice.

I wrote in my [2026 blogging plans]({{< relref "post/2026/02/my-2026-blogging-plans.md" >}}) that I wanted to explore GenAI tooling more deeply this year, and multi-model consensus has been one of the more interesting discoveries so far. It's not flashy, it doesn't generate your code for you — it just makes the models you're already using hold each other accountable.

And sometimes the most useful thing is just having two AI models disagree with each other. Forces you to actually think about which one's right.
