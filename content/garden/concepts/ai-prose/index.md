---
title: "Store Bought Cake: Using LLMs For Prose Without Burning Credibility"
date: 2026-04-17T00:00:00+00:00
description: "Why AI prose tastes like purple, the rules I hold to, and the tooling I use to keep my own voice intact."
garden_topic: "Concepts"
status: "Budding"
---

## Store-Bought Cake

{{< bluesky link="https://bsky.app/profile/gracekind.net/post/3mg6hi4yfgk2u" >}}

[Grace's](https://bsky.app/profile/gracekind.net) store-bought-cake metaphor has stuck with me since I saw it on BSky and I've been thinking about it a lot recently. There's a lot of guidance, tooling and processes for using LLM's to write code. But writing for humans? It feels like that's still a bit of a minefield.

I'm in Technical Solutions, specifically as a Sales Engineer. That means, every paragraph I send a customer is an ask for trust. As much as LLM's help me wear all the hats I need to wear (remember we're talking to customers about 30+ products, 1000+ integrations and 4 clouds etc, AI is super helpful!), it's made me pause to think about when and how I use LLMs to help me with prose.

## "That Tasted Like Purple!"

{{< youtube MlDkxToyrBk >}}

To stretch the original cake metaphor, the next problem outside of the credibility of pretending you hand-baked your cake is its "taste". LLM output drifts toward [purple prose](https://en.wikipedia.org/wiki/Purple_prose), and it's so widespread now it's become [memefied](https://knowyourmeme.com/memes/delve). Out of the box, an LLM will give you a bunch of writing where everything "stands as a testament", every topic is "nuanced", every tool is "robust" and "seamless".

It all "tastes like purple" and ultimately it gives a bit of a sickly feeling to read.

Now, I'm talking beyond the problem of hallucinations in LLM prose. That's still important, but to me, that is table stakes in terms of credibility. And frankly, people were sending incorrect information well before LLM's existed (albeit, it's way easier now!)

It's more the language itself: grandiose, self-important and robotic.

Also... I've found this stuff tends to leak. Even when I hand-write something from scratch, sometimes LLM-shaped tendencies can bleed in. Maybe because the sources I'm quoting are themselves AI-assisted, or even some of the patterns are now so widespread they feel normal.

{{< info >}}Look how many products have the word "Delve" in them these days!{{< /info >}}

Em-dashes are another example, they've become an unfortunate casualty of the AI prose world. I'll apologise to anyone out there who loves them, but at this point I treat any em-dash or en-dash in my own prose as an AI smell, rightly or wrongly.

For me, I'd rather play it safe, and I stick with good ol' fashioned hyphens, parentheses, commas, and colons. Sorry e(n/m)-dashes, you're a casualty to the slop-industrial-complex.

## Why This Burns Credibility

An SE's whole job runs on trust. You're building the technical credibility that a customer should use Datadog for their organisation's observability challenges. If a customer reads a note from me and immediately gets that prickling in their thumbs that I'm winging it with AI, that can burn a relationship and, in worse cases, scuttle a whole conversation. If that paragraph reads like a vendor landing page, I've already lost ground I can't easily get back, even if the technical content underneath is solid.

Even for non-customer facing roles, the overall consequences are lessened but the credibility loss is the same. If I send a colleague a long rambling AI output that I've not properly edited and worked on myself, they're likely going to clock it as AI slop, and really the subtext for them is "I didn't respect you enough to check this and write it myself".

So much of working in a large organisation across different disciplines involves communication and respect for other's time and effort. If one side notices the other has outsourced its half to Claude with no disclosure or initial checking, it's not a great feeling for the other person, even when it's unintentional.

There's also a self-trap I've walked into more than once. If I let the LLM do the first pass and then lightly edit, the underlying "shape" of the message is still the model's, and not my own. I've posted a few of those when I first started using GenAI last year and cringe a bit reading back on them now.

I'd rather write something rougher and more honest, even if ultimately it takes longer, or I even decide not to use AI at all.

## The Rules I Hold To

These are my personal smell tests:

1. **If A Sentence Sounds Like A Vibe-Coded Landing Page, Bin It.** "Seamlessly leverage our robust platform" is slop even if a human wrote it. Replace it with what you actually mean: which tool, which action, which user.
2. **If I Can't Say The Sentence Out Loud Without Cringing, Bin It.** Reading aloud is a basic but useful self-check. Try saying "stands as a testament" out loud and think if that really means anything, or is it just words-for-words' sake.
3. **If I Feel Weird Defending Every Word Of A Paragraph As My Own, Bin It.** Ask yourself "Would I sign my name to this sentence if a customer pushed back on it?". If the answer's not a passionate yes, then it's a no, and keep working on it.

## When To Use AI For Prose, When To Skip It

Let's be honest: sometimes the right move is to skip the model entirely and write from a blank page. Or just be human: go talk to the person directly!

I've often found especially if the thing I'm writing is a personal point of view, even with some of the tooling I'll discuss later, I find the LLM flattens it out too much and I end up rewriting most of it anyway.

In those cases the model isn't saving me time and costs me my personal voice.

Where AI genuinely earns its keep for me:

- **Drafting Structure.** "Here are the five things I want to cover. Lay out a skeleton and I'll write the prose." The scaffolding is easy to audit, and I fill in the voice-heavy parts.
- **Unblocking.** When I'm stuck, a quick LLM pass often surfaces angles I hadn't considered. By the time I've fully edited, I rarely keep the original words, but the overall angle sticks.
- **Proof Reading.** Asking the model to scan my draft for AI tells, vendor phrasing, or unsupported claims, and even find relevant references to add in, like blog posts or documentation links.
- **Summarising Source Material.** A meeting transcript, a long doc, a PR diff. Summarise first for my own consumption, then if needed I write the takeaway in my own voice.

Basically the way I see AI works best: LLM for structure and review, human for the actual sentences a customer or colleague will read.

## Tooling That Keeps Me Honest

The rules above are mental checklists, but I've now started weaving them in to any AI tooling I'm using to actually make them stick. It's nothing super advanced from an engineering perspective, it's basically just more context and prompting, via just a few static markdown files that Claude Code (other agentic tools are available™) loads before drafting anything I'll put my name on.

Here's an example setup I've been using that works for me:

### A Captured Voice Guide

The first file is a voice guide document, a description of how I write: first-person, British spellings, heavy on parenthetical asides, allergic to em-dashes.

I built the first pass by running my [personal blog](https://petersouter.xyz) through an agent, then hand-edited it over a few months as I noticed things the model missed. The idea is an agent will load this before drafting, so I don't have to constantly add to a prompt to say "use British spellings, write in first person" etc.

```markdown
# Peter Souter's Writing Style and Tone Guide

Captured from analyzing posts at petersouter.xyz

## Core Voice

Conversational, self-aware, and technically grounded with a strong
emphasis on humility. Peter writes as a pragmatic practitioner
("Just some guy y'know?") rather than positioning himself as an
authority. He prioritizes reader accessibility and intellectual
honesty over signalling expertise.

## Voice and Perspective

### First-Person, Conversational, Personal
- Write from personal experience: "I've been", "I was tinkering",
  "I thought"
- Heavy use of personal anecdotes and memoir-style storytelling
- Deliberately unpretentious: bio is literally "Just some guy
  y'know?"
- Balance technical authority with self-deprecation: "I didn't
  really get how it was working..."

[...]
```

The actual file lives at [`.claude/context/writing-style.md`](https://github.com/petems/petersouter.xyz/blob/master/.claude/context/writing-style.md).

### A Wikipedia-Derived AI-Tells Checklist

The second file is a self-review checklist, built from the [Wikipedia "Signs of AI Writing" page](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing). This is where all the "tastes like purple" vocabulary lives: `delve`, `crucial`, `multifaceted`, `tapestry`, `stands as a testament`, trailing `-ing` phrases, the rule-of-three-every-time habit.

We don't want to just banish every AI-ism, sometimes `crucial` is fine to use! Five `crucial`'s? Bin it!

```markdown
# AI Writing Tells - Self-Review Checklist

Adapted from [Wikipedia: Signs of AI writing]
(https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing),
which catalogs patterns statistically overrepresented in LLM output.
Use this as a final pass to catch robotic phrasing that slipped
through into blog drafts.

This checklist is **descriptive, not prescriptive**. A few of these
patterns appear naturally in good human writing. The signal is
density: one "pivotal" is fine; five AI vocabulary words in two
paragraphs is a rewrite.

[...]
```

The agent runs this checklist against its own draft before doing whatever output it's doing, generally to markdown locally so I can review it in a visual tool like [Macdown](https://macdown.uranusjr.com/), and then use that as a starter-for-10 in a Word Doc, Email or blog page. The actual file lives at [`.claude/context/ai-writing-tells.md`](https://github.com/petems/petersouter.xyz/blob/master/.claude/context/ai-writing-tells.md).

### Personal Overrides

This is more of a personal preference part, but you need to capture what personal styling you keep that might sometimes be an AI tell.

For me it's:

- **Title Case On Every Heading.** Sure, LLMs overuse Title Case but... I don't care, I just prefer the aesthetic!
- **Title Case On Bold Prefixes In Bullets.** The `**Term:** description` pattern you're reading right now. Same reason.

{{< info >}}I later found out that these are part of [Chicago Style formatting](https://en.wikipedia.org/wiki/The_Chicago_Manual_of_Style), but I'd never sat down and specifically went "I should write in Chicago Style formatting". So in a human way I'd kind of absorbed that formatting subconsciously from the prose I'd read over the years, in the same way LLM's do, fun huh?{{< /info >}}

- **Zero Em-Dashes And Zero En-Dashes.** This is an example where I'm actually stricter than the Wikipedia guide, which only flags "overuse". My take is to ban them outright, even in number ranges (`5-10 minutes`, not `5 to 10 minutes` with an en-dash). Too strong? Maybe, but maybe that's something that you tweak personally to not be as strict on.

```markdown
## Personal Style Overrides

A few patterns in this checklist are genuine AI tells, but Peter
prefers them in his own writing. These overrides are deliberate:
do not "correct" them during drafting or review.

- **Title Case for All Headings (H1, H2, H3).** LLMs overuse Title
  Case (see Formatting tells below). Peter uses it anyway: it reads
  cleaner on his site and matches his aesthetic preference.
  Sentence case is not the house style.
- **Title Case for Bold Prefixes in Headline-Style Bullets.**
  Bullets of the shape `**Term:** description` use Title Case on
  the term (Chicago style: capitalize principal words; lowercase
  articles, short prepositions, coordinating conjunctions). Plain
  prose bullets keep natural sentence case.
- **Zero Em-Dashes and Zero En-Dashes in Prose.** LLMs overuse
  em-dashes. Peter's rule is stricter than the checklist: none at
  all in published content. Use a hyphen (-), parentheses, a
  comma, or a colon. Applies even to number ranges. Verbatim quotes
  from external sources are exempt.

When editing or reviewing Peter's content: do not flag Title Case
headings or `**Term:**` bullet prefixes as AI tells. Do flag every
em-dash and en-dash as a hard error, stricter than the general
"overuse" framing below.

[...]
```

I found this list of personal preferences is important: without your voice and personal style being encoded as overrides, you can end up over-correcting and flattening your own style.

### An Example Skill That Wires It All Together

So those are just reference files at the end of the day, we need something to hook them all together for our agent. That's where a [skill](https://docs.claude.com/en/docs/claude-code/skills) comes in!

I wrote one specifically for Confluence pages to help me write posts like this (at the time I wanted to share this with colleagues in our internal wiki), as Confluence's frankenstein mix of markdown and other bits was a pain to figure out, so I let the MCP do the work.

It takes the voice baseline that I distilled from my blog like I mentioned earlier, but adds an additional layer: `professional-voice-adjustments.md`. This dials the public-voice down for a workplace audience, removing some of the more casual flavour that I'd avoid in a work wiki page. Anyone who knows me knows I'm generally more of an informal kinda-guy, but putting "DO THE DARN THING" as a closer on a post in a work wiki is probably a bit *too* informal.

```markdown
## What To Reach For

- **Colleague-to-colleague tone.** Write like a DM to a teammate:
  warm, specific, peer-level. Assume the reader is a technical
  equal with limited time.
- **Stakeholder awareness.** A wiki page may be read by a manager,
  a partner team's engineer at 3am during an incident, or a new
  hire six months from now. Write for that audience without
  flattening the voice.
- **Actionable closers instead of rallying cries.** End with what
  the reader can do or what the author will do.
  - "Happy to discuss in #channel-name if anyone has feedback."
  - "Next step: I'll kick off the migration on staging week of
    YYYY-MM-DD."
  - "If you're running into this, DM me or drop a comment."
  - "Open questions I'd welcome input on: [...]"
- **Specific attribution.** Name the colleagues and teams who
  helped. A specific "@Jane pointed out that X" beats a generic
  "thanks to the team".
- **Structured recaps.** A TL;DR or "Key Takeaways" list at the
  top or bottom carries the energy of a rallying cry without the
  caps.
- **Decisions framed as decisions.** "We're going to do X" (with
  rationale linked) is clearer than "I reckon X might be the
  move?". Confidence is fine when the thinking is shown; the
  uncertainty belongs in a dedicated "Open questions" section,
  not diffused through every sentence.

[...]
```

### How It Comes Together

By the end, I have a skill that:

- Loads my captured voice guide
- Checks against the Wikipedia-derived checklist of AI-isms
- Tweaks with a set of personal overrides
- Then uses the Confluence MCP (or just outputs markdown, for blog posts like this one) to render the result, suggest labels and post it to my personal space

The [blog post skill](https://github.com/petems/petersouter.xyz/blob/master/.claude/skills/new-generated-blog-post/SKILL.md) works the same way but outputs Hugo-flavoured markdown instead.

It's not bulletproof: ultimately any output from a model is a reflection of its parameters and training set. Prompts and harnesses aren't magic, purple prose can still slip through, and this very post needed multiple editing passes before I was happy signing my name to it.

If you could see a full-detailed diff of the first AI draft suggestion versus what you see now, the main thing that stayed was the structure. The rest is a ship of Theseus situation: it's still something that I consider as "me" writing it, even though I had structural guidance from an LLM.

But it catches far more slop than any editor-pass I've done by hand, and it's been significantly more useful than a bare "help me write a page about X" prompt.

## Non-AI Based Prose Critique

One of the areas I've been meaning to add in is building on some of the work I've seen folks like the Docs team use for a while, way before LLM's were the cool thing.

After all, what better way to avoid AI-isms than not using AI at all?

Right now I've been tinkering with [Vale](https://vale.sh/), as many teams at Datadog use that internally. So far, I've found it's a little hard to get set up and used to, but I've been tinkering to add it to my personal blog as another CI/CD step so I don't have to burn tokens all the time on review.

Since there's plenty of prior art on using it elsewhere, it makes sense to add it to my flows, so I've got it on my backlog to add in the future.

## The Disclosure Play

For me, at the end of the day: **I'd rather be explicit about AI assistance than sneak it in.**

With customers I think it's just too much of a credibility risk to go "hey here's some Claude output to start, I'll give a proper response later", it just feels too disrespectful to me. But the nature of an SE's role is we're constantly jumping from call-to-call, and sometimes I get a quick Slack ping from an AE in the middle of a quick 5 minute leg-stretch break or in the middle of a call: "what do you know about X?".

Sometimes, I've not had the chance to properly research it, and I want to give a pointer or some food for thought. For that, I'll probably write something like:

> "I've not had the chance to dig into this yet, so here's a quick summary I had Claude sketch out with links. Happy to get more specific once you've had a butchers, throw some time on my calendar if you want to dig deeper 👍"

That framing does two things: my colleague knows what they're reading, and when I follow up with the real answer it means both of us have had that follow-up land with more weight, not less. Disclosing the AI help up front costs me nothing, whereas just copypasta-ing some LLM output is a paper-cut of trust in the relationship.

## Closer

None of this is a rallying cry to hand-write everything or [smash the spinning-jenny](https://en.wikipedia.org/wiki/Spinning_jenny). I use LLMs every day and they've genuinely helped me a lot. But I think having the right processes in place and centering the human as part of the flow of any writing is still key.

To close the loop on the original metaphor from Grace's post:

**The cake is fine, I just want to be honest about who baked it, and I want it to taste good!**
