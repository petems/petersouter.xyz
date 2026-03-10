+++
author = "Peter Souter"
categories = ["Tech"]
date = 2026-03-04T17:00:00Z
description = "How a BDD renaissance in the age of AI-generated code inspired me to resurrect a decade-old Puppet testing tool using agentic coding, for the grand total of thirteen dollars."
draft = true
slug = "resurrecting-a-13-year-old-oss-project-for-13-bucks"
tags = ["BDD", "Puppet", "Testing", "GenAI", "Ruby", "Cucumber", "Open Source"]
title = "Resurrecting a 13-Year-Old OSS Project for 13 Bucks"
keywords = ["cucumber-puppet", "BDD", "behaviour driven development", "Puppet", "AI code generation", "agentic coding", "vibe coding", "spec-driven development", "Gherkin", "testing"]
thumbnailImage = ""
coverImage = ""
+++

With the rise of agentic coding bots pumping out 10,000+ lines of code per session, there's been a lot of discussion, navel-gazing, and outright panicking about the nature of the software development lifecycle. AI agents don't just suggest code anymore, they actually ship it. And there appears to be a rise in — whisper it — code getting merged with no actual human review.

<!--more-->

Honestly? I'm still super, super sceptical about all of that. Simon Willison [put it well](https://simonwillison.net/2025/Mar/19/vibe-coding/): his golden rule is "I won't commit any code to my repository if I couldn't explain exactly what it does to somebody else." I'm firmly in that camp.

But for me, on the positive side, this wave of AI-generated code has kicked off some genuinely interesting conversations about *how* you test these huge blobs of LLM-crafted code. And people are starting to talk about BDD again.

Which both makes me feel incredibly old and oddly vindicated, because the last time I was seriously writing Gherkin spec tests and running `bundle exec cucumber` was about thirteen years ago.

## BDD Is Having a Moment (Again)

If you're not familiar, [Behaviour-Driven Development](https://cucumber.io/docs/bdd/) is an approach where you write human-readable specifications that double as executable tests. The classic format is Given/When/Then:

```gherkin
Given a user is logged in
When they click the "Delete Account" button
Then they should see a confirmation dialog
```

It turns out that when you've got AI agents generating enormous volumes of code, having a structured, human-readable specification that both defines what the code *should do* and can verify that it *actually does* is... well, it's exactly what you need, isn't it?

The argument goes something like this: BDD specs are written in structured natural language. LLMs are, at their core, language models. [Gherkin's syntax](https://cucumber.io/docs/gherkin/) with its clear rules and concrete examples is essentially a structured prompt. As Thoughtworks [pointed out](https://www.thoughtworks.com/en-us/insights/blog/agile-engineering-practices/spec-driven-development-unpacking-2025-new-engineering-practices), "the spec-by-example used in BDD is essentially the few-shot prompt technique."

There's been a proper wave of this thinking. Hung Doan wrote about how ["LLMs are making BDD & Gherkin rise again"](https://hungdoan.com/2025/04/25/llms-are-making-bdd-gherkin-rise-again/). [OpenSpec](https://github.com/Fission-AI/OpenSpec), a spec-driven development framework designed specifically for AI coding assistants, has racked up over 25,000 GitHub stars. GitHub released their own [Spec Kit](https://github.blog/ai-and-ml/generative-ai/spec-driven-development-with-ai-get-started-with-a-new-open-source-toolkit/). Even Martin Fowler [weighed in](https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html), analysing three levels of spec-driven development from "spec-first" to "spec-as-source." There's academic papers on it. Conference talks. The whole shebang.

The irony isn't lost on me. We spent years watching BDD slowly fall out of fashion in many circles — too much ceremony, too much overhead, Gherkin felt clunky compared to just writing good unit tests. And now suddenly, the ceremony is the *point*. The structure is the feature, not the bug.

## My BDD Origin Story

I've got history with this stuff. [Back in 2015]({{< relref "post/2015/02/tddbdd-with-puppet-code.md" >}}), I wrote about TDD/BDD with Puppet code, and even before that, I was tinkering with [cuke4duke](https://github.com/cucumber/cuke4duke), a JVM Cucumber package, before I'd even properly got into Rails.

I loved writing Cucumber features. There was something deeply satisfying about expressing what your infrastructure *should do* in plain English, then watching the framework turn that into executable tests. The Red-Green-Refactor loop but with actual sentences that non-developers could read and nod along to.

I did a ton of [rspec-puppet](https://rspec-puppet.com/) work too, which was more TDD than BDD, but the philosophy was the same: write the spec first, watch it fail, write the minimum code to make it pass. I even [wrote about drying up RSpec with shared_examples]({{< relref "post/2016/11/drying-up-rspec-with-shared_examples.md" >}}) and [testing Windows Puppet with Beaker]({{< relref "post/2016/06/testing-windows-puppet-with-beaker.md" >}}).

But honestly? BDD felt like it went a bit quiet for a while. Not dead exactly, just... not where the energy was. I moved on to other things. [Golang CLI testing with Aruba]({{< relref "post/2024/04/testing-cli-apps-with-aruba.md" >}}). Terraform. Vault. The usual ops-person-who-codes trajectory.

## The Project That Got Away

Which brings me to [cucumber-puppet](https://github.com/petems/cucumber-puppet).

Cucumber-puppet was originally created by Nikolay Sturm back in 2010 as a proper BDD framework for Puppet. The idea was brilliant: write Cucumber features that describe how your Puppet catalogs should behave, and the framework provides the glue code to actually compile and inspect those catalogs. Real Given/When/Then for your infrastructure-as-code.

Lindsay Holmwood had pioneered [Behaviour Driven Infrastructure](https://fractio.nl/2009/11/09/behaviour-driven-infrastructure-through-cucumber/) with cucumber-nagios, and cucumber-puppet was the natural extension of that thinking into the config management world. There was even [an InfoQ talk about it](https://www.infoq.com/presentations/BDD-with-Puppet-Cucumber/).

Nikolay [discontinued the project](https://github.com/petems/cucumber-puppet/commit/6035b68) in June 2012, and I ended up with it donated to me sometime around 2013. I had such high hopes at the time. I was going to learn how the guts of Ruby and the meta-DSL of Cucumber wired into Puppet's internals, understand how catalog compilation actually worked under the hood, maybe even modernise it and get people excited about BDD for infrastructure again.

Yeah... that never happened. It's such a specific niche — the intersection of Cucumber, Puppet, and Ruby metaprogramming — that it kept falling to the bottom of the priority list. I got it running on Travis CI, added some [Appraisal](https://github.com/thoughtbot/appraisal) support for multi-version testing, fixed a deprecated `Puppet.parse_config` call, and then... nothing. For over a decade.

The last real commit was November 2013. The project was pinned to Puppet 2.x, Cucumber 1.x, and Ruby 1.9. Properly gathering dust.

## But That Was 2013. This Is 2026.

And in 2026, the entire concept of what "software engineering" even means is being questioned on a daily basis. So when I saw all this BDD renaissance discussion, and kept thinking about cucumber-puppet just sitting there on my GitHub profile with its 100 stars and its decade of cobwebs, I thought: what if?

What if I could use these very same agentic coding tools that everyone's debating about to breathe life back into a project that predates most of the debate?

I made a plan. And crucially, I scoped it with a very low bar. The goal wasn't "make cucumber-puppet work with Puppet 8 and Ruby 3.3." The goal was:

**Move up one semantic version on each side: Puppet 2.x to 3.x and Cucumber 1.x to 2.x.**

That's it. One SemVer bump per dependency. Sounds modest, right?

Except "one version" in a Ruby ecosystem from 2013 means dealing with Bundler changes, C-extension binding updates, deprecated APIs across multiple gems, and the general entropy that accumulates when a project sits untouched for a decade. Not to mention the Puppet 2-to-3 transition was one of the bigger breaking changes in Puppet's history.

## Planning, Prompting, and Peripheral Vision

So I planned, and I prompted, and I set goals and expectations. I've got tools like [Conductor](https://addyosmani.com/blog/future-agentic-coding/) that allow me to fire-and-forget with these agentic flows. Normally when I'm using Claude Code, I fire off two or three tasks and leave the terminal in the background, occasionally checking in. Standard stuff. I talked a bit about my agentic workflow in my [email drafting assistant post]({{< relref "post/2026/03/building-an-email-drafting-assistant-with-claude-code-skills.md" >}}).

But this time? I'm not going to lie, I was watching this one out the corner of my eye. Like a sports fan dad who can't help but keep the big game on in his peripheral vision while pretending to read the paper.

The agent was grinding through dependency resolution, hitting walls with gem incompatibilities, figuring out that `puppet-lint` needed a different version, discovering that the `facter` gem's C bindings didn't play nice with the newer Ruby, working around deprecation warnings that had become hard errors. All the stuff that would've taken me hours of frustrating Googling and Stack Overflow trawling.

And yeah, it got stuck sometimes. There were moments where it went down the wrong path and I had to nudge it. Agentic coding isn't magic — it's more like having a very enthusiastic junior developer who's incredibly fast at trying things but occasionally needs a "no, not that way, try *this*" from someone who's seen the error before.

## The Moment

When it worked — when `bundle exec cucumber` actually ran and the features went green — it was genuinely a really good moment.

I managed to resurrect an open source project that I hadn't touched since Obama was president. That's wild. The project was created when the iPad was brand new. When I inherited it, "Docker" was still just a word that meant someone who works at a dock.

And the total API cost for the whole exercise? About thirteen dollars.

Thirteen years of dormancy. Thirteen bucks to wake it up. You couldn't script a better title if you tried. Well, OK, I clearly did try, because it's the title of this post.

## Why This Actually Matters (To Me, At Least)

Beyond the fun novelty of it, this little exercise crystallised something I've been thinking about since [my recent reflections on AI and motivation]({{< relref "post/2026/03/i-failed-but-feel-good.md" >}}).

The AI burnout loop I talked about — where you get more started but less finished, where the doing gets outsourced but the satisfaction doesn't transfer — that's real, and I still feel it sometimes. But this was different. This had a clear, scoped goal. A tangible deliverable. An actual green test suite at the end. And crucially, I understood what was happening at every step, even when the agent was doing the tedious bits.

It's the difference between vibe coding and what Karpathy [now calls](https://thenewstack.io/vibe-coding-is-passe/) "agentic engineering" — you're still the one driving, even if the AI is doing the gear changes.

## What's Next: Puppet for macOS in the Cloud

But I'm not stopping here, because what's the point of resurrecting a Puppet BDD tool if we don't actually use it to test some Puppet?

I've got a backlog plan to deploy a macOS-in-the-cloud setup. It needs a lot of scripts to install things: GitHub Runner, Homebrew, packages, config files, dotfiles, SSH hardening, the works. I've [written before]({{< relref "post/2024/04/bootstrapping-a-new-osx-device.md" >}}) about bootstrapping new macOS devices, and this is the natural evolution of that.

It's time to go old school and write some Puppet. And oh yeah, you know I'll be testing it with cucumber-puppet.

Watch this space.

## Links and Further Reading

If the BDD renaissance angle interests you, here are some of the articles that got me thinking:

* [LLMs are making BDD & Gherkin rise again](https://hungdoan.com/2025/04/25/llms-are-making-bdd-gherkin-rise-again/) — Hung Doan
* [Is BDD Dying?](https://automationpanda.com/2025/03/06/is-bdd-dying/) — Andrew Knight (spoiler: no)
* [Spec-driven development: Unpacking one of 2025's key new AI-assisted engineering practices](https://www.thoughtworks.com/en-us/insights/blog/agile-engineering-practices/spec-driven-development-unpacking-2025-new-engineering-practices) — Thoughtworks
* [AI for better BDD](https://www.humanizingwork.com/ai-for-better-bdd/) — Richard Lawrence
* [Understanding SDD: Kiro, spec-kit, and Tessl](https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html) — Martin Fowler
* [Behavior-driven development with LLMs](https://memo.mx/posts/bdd-with-llms/) — Memo Garcia
* [OpenSpec](https://github.com/Fission-AI/OpenSpec) — Spec-driven framework for AI coding assistants
* [cucumber-puppet](https://github.com/petems/cucumber-puppet) — The patient, now off life support
