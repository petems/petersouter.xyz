+++
author = "Peter Souter"
categories = ["Meta", "Blogging"]
date = 2026-03-17T00:37:28Z
description = "How I built custom Claude Code skills to act as editorial reviewers for my blog posts, and what I learned about getting AI back into a useful proof-reader role."
draft = true
slug = "using-claude-skills-to-review-blog-posts"
tags = ["Claude Code", "GenAI", "Blogging", "Writing", "Skills"]
title = "Using Claude Code Skills to Review My Blog Posts"
keywords = ["claude code", "claude skills", "blog editor", "AI writing review", "claude code slash commands", "editorial review", "hugo blog"]
thumbnailImage = ""
coverImage = ""
+++

In my [last post]({{< relref "post/2026/03/i-failed-but-feel-good/index.md" >}}), I talked about trying to find a healthier balance with AI in my writing process. The gist was: I'd been letting LLMs do too much of the actual *writing*, and it was sucking the joy out of blogging. My conclusion was that the AI needed to move back into more of a "proof-reader-y role."

Well, I've been experimenting with exactly that, and I think I've landed on something that works pretty well.

<!--more-->

## The Problem: I'm a Terrible Self-Editor

Here's the thing — I'm not a professional writer. I'm a DevOps engineer who blogs. My posts tend to be conversational, rambling, and full of the kind of typos and structural issues that happen when you're writing at 11pm after getting the kids to bed.

I've always known I needed an editor, but I don't have one. I've tried asking friends to review drafts, but that's a big ask for a personal blog. I've tried reading my own posts aloud, which helps but doesn't catch everything. And I've tried various grammar tools, but they either miss the big-picture stuff (is this section redundant? does this post actually have a point?) or they try to sand down all the personality out of my writing.

What I actually wanted was something that could give me a proper editorial review — the kind where someone reads your whole piece and comes back with "this section drags, this paragraph repeats what you said three paragraphs ago, and your conclusion doesn't land" — but without taking 45 minutes of a human's time.

## Enter Claude Code Skills

If you haven't come across [Claude Code skills](https://code.claude.com/docs/en/skills) yet, the short version is: they're reusable prompt templates that live in your project's `.claude/skills/` directory. Each skill has a `SKILL.md` file with instructions, and you can invoke them with a slash command like `/tech-blog-editor`.

The key thing that makes skills different from just pasting a long prompt is that they're *contextual* — they live alongside your code, they can reference other files, and Claude loads them automatically when they're relevant. Skills follow the [Agent Skills](https://agentskills.io) open standard, so they aren't even locked to Claude specifically.

For my blog, I created two editorial skills: one for [technical posts](#the-technical-editor) and one for [personal/non-technical posts](#the-non-technical-editor). They share a similar structure but have different priorities.

## The Technical Editor

My `/tech-blog-editor` skill is built to review technical blog posts across multiple dimensions:

- **Content analysis**: verbosity, repetition, flow, structure, length
- **Technical accuracy**: code examples, claims, terminology, API usage
- **Writing quality**: grammar, tone, clarity, jargon
- **Blog-specific concerns**: frontmatter, intro hooks, conclusions, SEO
- **Engagement**: reader value, pacing, examples, actionability

When I invoke it on a post, it generates a full editorial review document in my `scratch/` directory. The review follows a structured format: executive summary, major issues, section-by-section feedback, strengths, and a prioritised recommendations summary broken into must-address, should-address, and nice-to-have.

The bit I'm most proud of is the calibration guidance. Early versions of the skill were... enthusiastic. They'd flag *everything*. Passive voice in a conversational blog post? Error. Sentence fragment used for effect? Error. A section that's fine but could theoretically be slightly better? Three paragraphs of suggestions.

So I added explicit instructions about what *not* to do:

> **Over-flagging style**: Don't flag passive voice, sentence fragments, or informal tone as errors if they're consistent and intentional

> **Inventing problems**: If a section is clean, write "No issues found" — do not manufacture feedback to seem thorough

That last one was important. Without it, the reviews would always find exactly the same amount of stuff to flag regardless of the post's actual quality. It's the AI equivalent of a mechanic who always finds something wrong with your car.

## The Non-Technical Editor

The `/non-tech-blog-editor` skill is similar in structure but tuned for personal essays, trip reports, and opinion pieces. The big difference is it adds a **Storytelling & Narrative** dimension:

- Opening hook: does the first paragraph draw the reader in?
- Narrative arc: is there setup, development, payoff?
- Show vs tell: vivid details and anecdotes, or just stated flatly?
- Sensory details: for trip reports, enough concrete details to put the reader there?
- Stakes: is it clear why this matters?

And critically, it has stronger guardrails against stripping the author's voice:

> **Stripping the author's voice**: Personal posts are personal. Don't suggest rewrites that make the prose generic or formal. Preserve quirks, humour, and personality

> **Tone-policing opinions**: The author's opinions and perspectives are not errors

That second one matters a lot to me. I had early experiments where Claude would suggest softening any strong opinion with hedging language. "This tool is rubbish" would get flagged with a suggestion to say "This tool may not be the best fit for all use cases." No! That's not my voice, and the whole point of a personal blog is having opinions.

## What a Review Actually Looks Like

Rather than showing you a made-up example, here's what happened when I ran `/non-tech-blog-editor` on my [previous post]({{< relref "post/2026/03/i-failed-but-feel-good/index.md" >}}) — the one about missing my blogging deadline. That post was written in a genuine rush, so it was a proper stress test.

The review landed in `scratch/i-failed-but-feel-good-editorial-review.md` and you can [read the full thing here](/files/2026/03/i-failed-but-feel-good-editorial-review.md) if you're curious. But let me walk through what it caught, because I think it shows the range pretty well.

### The Trivial Stuff

The post was riddled with typos — I'd written it at speed and it showed. The review caught about 20 spelling and grammar errors: "spining" → "spinning", "recurgitate" → "regurgitate", "vexiology" → "vexillology", "from-the-heard" → "from-the-heart", "hussle slop" → "hustle slop". Classic stuff that I'd missed because I was too close to it.

It also spotted a broken link — I'd referenced `[Terrance Gore]` with no URL, just bare brackets — and an unclosed parenthetical that would've looked sloppy to anyone reading carefully.

These are the kinds of things a normal spell-checker would partially catch, but having them all in one prioritised list made the fix-up pass much quicker.

### The Structural Stuff

This is where it gets more interesting. The review flagged three things I genuinely hadn't noticed:

1. **Two incomplete sentences.** I'd written "who had tragically passed in the middle of my" and just... stopped. And another sentence about an "ouroboros of more work" that trailed off mid-thought. I'd been writing so fast I didn't realise I'd left unfinished thoughts dangling.

2. **A flow problem in the back half.** The review pointed out that my "Third Blog" section jumped between the deadline scramble, a tangent about my Zheleznogorsk flag t-shirt, a vexillology meta-point, a git-commit-yolo moment, and an HBR research quote — all within about 30 lines. It described this as reading "like a braindump (which is honest and charming!) but a reader might lose the thread." Fair cop.

3. **A couple of sentences that read too polished.** This one surprised me. The review flagged "never reaching the tangible, satisfying deliverable bits" as having "a slight polish compared to the surrounding rawness" and suggested "never actually finishing anything" as more in my voice. It was right — that phrase had been quietly smoothed by an earlier Claude drafting pass and stuck out against the rougher prose around it.

That last one is genuinely useful. Having a reviewer that can spot where AI-assisted prose jars against your natural voice is exactly the kind of thing a human editor would catch but a grammar tool never would.

### The Prioritised Summary

The review ends with a recommendations summary that separates the wheat from the chaff:

- **Must Address**: the incomplete sentences and broken link (things that would genuinely confuse readers)
- **Should Address**: the ~20 typos, cleaning tracking params from a URL, tightening a tangent
- **Nice to Have**: giving a key thesis question more visual emphasis, splitting an 85-word sentence

This is the real gold. I can scan that summary in 30 seconds and know exactly what needs fixing before I publish vs. what's just polish I can do if I have the energy.

## Writing Is Thinking Out Loud

There's a deeper thing going on here that I didn't expect when I started this experiment.

I've always loved blogging because it's basically thinking out loud. My process, if you can call it that, is to open a blank file and just go — from the dome, stream of consciousness, whatever comes out comes out. The result is usually a rambling mess, but it's *my* rambling mess, and somewhere in that mess is the thing I'm actually trying to say.

The problem is I'm terrible at seeing the shape of my own thoughts. I'll write 2,000 words and not realise I've made the same point three times, or that my actual thesis is buried in paragraph six, or that a whole section is just me warming up and could be cut entirely. Having the editorial skills give me a second opinion has genuinely helped me clear my head and prioritise. It's like having someone read your braindump and say "right, *this* is the interesting bit — lead with that."

But it does make me think about something: how much imperfection is part of the voice?

Take misspellings. My "I Failed" post had about 20 of them. That's objectively sloppy, and the review was right to flag them. But there's a part of me that almost wants to leave some in — like deliberately leaving thumbprints on a sculpture to prove a human was involved. When everything is perfectly spell-checked and grammatically pristine, it can start to feel... processed. And processed is exactly the thing I'm trying to avoid.

I know, I know — there's a difference between "charming imperfection" and "didn't bother to proof-read." And I do specifically call out in the skills that things like passive voice and informal tone aren't errors when they're consistent and intentional. The skill respects that a personal blog should *feel* personal. But it's an interesting line to walk — how much polish is too much before you sand away the humanity?

For now, my workflow has settled into something like this: I do the brain dump first, completely unfiltered, no AI anywhere near it. That's the fun bit — the actual thinking-out-loud part. Then I run the editorial skill, which gives me a structured view of what I've actually produced. Then I fix the genuine problems (incomplete sentences, structural issues, broken links) and make a judgement call on the rest.

Or maybe I just don't like being called out for my sloppy grammar by an LLM. That's also possible.

## Lessons Learned

### 1. Calibration Is Everything

The hardest part wasn't writing the skill — it was tuning it to give *useful* feedback rather than *comprehensive* feedback. Comprehensive sounds good until you're staring at a 40-item list of suggestions for a 1,500-word blog post and none of them are weighted by importance.

The calibration section of my skills explicitly says: "A post with no major structural problems should have ≤3 Must Address items. If every section yields a high-priority item, recalibrate — you may be over-flagging."

### 2. Tell It What NOT to Do

This is maybe the most important lesson. LLMs are people-pleasers by nature — they want to give you *something* for every section. If you have a "Grammar & Style" section in your review template, Claude will find grammar issues even if there aren't any meaningful ones.

The "Failure Modes to Avoid" section of my skills was the single biggest improvement to review quality. Being explicit about anti-patterns ("don't manufacture feedback to seem thorough") made the reviews dramatically more useful.

### 3. Two Skills > One Generic Skill

My first attempt was a single "blog editor" skill. But the priorities for a technical tutorial and a personal essay are genuinely different. A tech post needs code review and accuracy checking; a personal post needs narrative arc assessment and voice preservation. Splitting them meant each could be properly tuned.

### 4. The Scratch Directory Pattern Works Well

Having reviews land in `scratch/` rather than being dumped into the conversation keeps things clean. I can refer back to the review while editing, compare reviews across drafts, and the review doesn't clutter my git history since `scratch/` is in `.gitignore`.

## The Broader Pattern

What I like about this approach is that it keeps the AI in a role where it genuinely adds value without taking over the creative work. I still write the posts. I still decide the structure, the voice, the opinions. But I get a thoughtful second pair of eyes that catches the stuff I'm too close to see.

It also scratches a different itch than the "AI writes your first draft" approach. With the editor skills, I get the satisfaction of writing something, *and then* the satisfaction of making it better based on good feedback. It's closer to how professional writers work with editors — the editor doesn't write the book, but the book is better because of them.

This maps pretty directly to what I was saying in my [previous post]({{< relref "post/2026/03/i-failed-but-feel-good/index.md" >}}) about wanting the AI in a "proof-reader-y role." Skills gave me a structured way to make that happen, and the slash-command interface means it's literally two keystrokes to get a review.

## Want to Try It?

If you're running [Claude Code](https://claude.ai/code) and want to set up something similar, the basics are:

1. Create `.claude/skills/your-skill-name/SKILL.md` in your project
2. Add YAML frontmatter with `name` and `description`
3. Write your editorial instructions in markdown
4. Invoke with `/your-skill-name` followed by the file path

The [official skills docs](https://code.claude.com/docs/en/skills) cover the full feature set, including things like supporting files, dynamic context injection, and running skills in subagents.

There's also a growing community around sharing skills — the [awesome-claude-skills](https://github.com/travisvn/awesome-claude-skills) repo on GitHub is a good starting point if you want inspiration.

My main advice: spend the time on calibration. The difference between "reviews everything with equal urgency" and "reviews with proportional feedback" is the difference between a tool you use once and a tool you use on every post.

## What's Next

I'm still iterating on these skills. Some things I'm thinking about:

- **A comparison mode**: run the review on two drafts and highlight what improved
- **Style drift detection**: flag when my writing voice shifts mid-post (usually a sign I got tired and started leaning on Claude for prose)
- **Internal linking suggestions**: surface related posts from my archive that I should cross-link

But honestly, the current setup is already the most useful editorial feedback loop I've had on this blog in eight years. And the best part? I'm writing more, because the editing phase went from "ugh, I should really re-read this but I'm tired" to "let me just run `/tech-blog-editor` and see what comes back."

That feels like AI doing what it should be doing — making the boring bits easier so I can focus on the fun bits.
