---
title: "AI Prose"
date: 2026-04-17T00:00:00+00:00
description: "Why AI prose tastes like purple, the rules I hold to, and the tooling I use to keep my own voice intact."
garden_topic: "Concepts"
status: "Budding"
---

{{< bluesky link="https://bsky.app/profile/gracekind.net/post/3mg6hi4yfgk2u" >}}

[Grace's](https://bsky.app/profile/gracekind.net) store-bought-cake metaphor has stuck with me since I first saw it, and I think about it every time I reach for an LLM to help me write something for humans.

To stretch the metaphor, my complaint goes beyond the store-bought part: it's the flavour.

## Tastes Like Purple

{{< youtube MlDkxToyrBk >}}

LLM output drifts toward [purple prose](https://en.wikipedia.org/wiki/Purple_prose). Everything "stands as a testament", every topic is "nuanced", every tool is "robust" and "seamless". Nothing is small or messy or tentative. Reading it just feels...fuzzy? 

I'm not even talking about hallucinations. To me, that's table stakes when it comes to writing in the first place, and people have been confidently wrong about things since long before LLMs made it easier. It's the language itself: grandiose, self-important and robotic.

It also leaks. Even when I hand-write something from scratch, LLM-shaped tendencies bleed in. Maybe because half the things I'm reading are themselves AI-assisted, or because the patterns are now so widespread they feel normal.

## Why It Burns Credibility

Any piece of writing posted or sent to another person is, on some level, an ask for trust. The reader is being asked to take what you've said seriously and put weight on it. If they clock that the words came from a model (that prickling-thumbs feeling of "hang on, this sounds like Claude"), that trust takes a real hit, even when what's underneath is factually solid. If the paragraph reads like a vendor landing page, you've lost ground you can't easily get back.

The other half of it is respect. If I send someone a long bit of writing and they can tell it's AI slop, the subtext is "I didn't respect you enough to write this myself". So much of working with other people (a colleague, a collaborator, someone reading a post like this one) is an implicit exchange of attention and effort. If one side has outsourced their half to a model, the other side tends to notice, whether they call it out or not.

## The Rules I Hold To

These are my personal smell tests:

1. **If A Sentence Sounds Like A Vibe-Coded Landing Page, Bin It.** "Seamlessly leverage our robust platform" is slop even if a human wrote it. Replace it with what I actually mean: which tool, which action, which user.
2. **If I Can't Say It Out Loud Without Cringing, Bin It.** Reading aloud is a basic but brutal check. Try saying "stands as a testament" out loud and ask if it actually means anything, or if it's just words for the sake of words.
3. **If I'd Feel Weird Defending Every Word As My Own, Bin It.** Would I sign my name to this sentence if someone pushed back on it? If it's not a passionate yes, it's a no, and I keep working on it.

There's a self-trap I've walked into more than once: if I let the LLM do the first pass and then lightly edit, the underlying shape of the message is still the model's, not mine. I published a few of those when I first started using GenAI last year, and I cringe a bit reading them back now. I'd rather write something rougher and more honest.

## When I Use AI For Prose, When I Skip It

Sometimes the right move is to skip the model entirely and write from a blank page. Especially when it's a personal point of view, I find the LLM flattens it and I end up rewriting most of it anyway. In those cases the model isn't saving me time, it's costing me my voice.

Where LLMs genuinely earn their keep for me:

- **Drafting Structure.** "Here are the five things I want to cover, lay out a skeleton and I'll write the prose." The scaffolding is easy to audit, and I fill in the voice-heavy parts.
- **Unblocking.** When I'm stuck, a quick LLM pass often surfaces angles I hadn't considered. By the time I've edited, I rarely keep the original words, but the angle sticks.
- **Proof Reading.** Asking the model to scan my draft for AI tells, vendor phrasing, and unsupported claims, and to suggest references worth adding in.
- **Summarising Source Material.** A long doc, a PR diff, a transcript. Summarise for my own consumption first, then I write the takeaway in my voice.

Basically: LLM for structure and review, human for the actual craft of writing.

## Tooling That Keeps Me Honest

The rules above are mental checklists, but I've started weaving them into the AI tooling I use so they actually stick. Nothing fancy, just a few static markdown files that Claude Code loads before drafting anything I'll put my name on.

**A Voice Guide** ([`.claude/context/writing-style.md`](https://github.com/petems/petersouter.xyz/blob/master/.claude/context/writing-style.md)). A description of how I write: first-person, British, heavy on parenthetical asides, allergic to em-dashes. First pass came from an agent analysing this blog, and I've been hand-editing it since as I notice things it missed.

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

[...]
```

**A Wikipedia-Derived AI-Tells Checklist** ([`.claude/context/ai-writing-tells.md`](https://github.com/petems/petersouter.xyz/blob/master/.claude/context/ai-writing-tells.md)). Based on the [Wikipedia "Signs of AI writing" page](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing). This is where all the "tastes like purple" vocabulary lives: `delve`, `crucial`, `multifaceted`, `tapestry`, `stands as a testament`, trailing `-ing` phrases, the rule-of-three-every-time habit. The signal is density: one `crucial` is fine, five is a rewrite.

```markdown
# AI Writing Tells - Self-Review Checklist

Adapted from [Wikipedia: Signs of AI writing], which catalogs
patterns statistically overrepresented in LLM output. Use this as
a final pass to catch robotic phrasing that slipped through into
blog drafts.

This checklist is **descriptive, not prescriptive**. A few of
these patterns appear naturally in good human writing. The signal
is density: one "pivotal" is fine; five AI vocabulary words in
two paragraphs is a rewrite.

[...]
```

**Personal Overrides** (same file, top section). Important bit. Without these you over-correct and flatten your own style. Mine are Title Case on headings, Title Case on bold bullet prefixes (which overlaps with [Chicago style](https://en.wikipedia.org/wiki/The_Chicago_Manual_of_Style), absorbed from years of reading without ever sitting down and choosing it deliberately), and a stricter em-dash/en-dash ban than the Wikipedia guide: none at all, even for number ranges.

```markdown
## Personal Style Overrides

A few patterns in this checklist are genuine AI tells, but Peter
prefers them in his own writing. These overrides are deliberate:
do not "correct" them during drafting or review.

- **Title Case for All Headings (H1, H2, H3).** LLMs overuse Title
  Case (see Formatting tells below). Peter uses it anyway: it
  reads cleaner on his site and matches his aesthetic preference.
- **Title Case for Bold Prefixes in Headline-Style Bullets.**
  Bullets of the shape `**Term:** description` use Title Case on
  the term (Chicago style). Plain prose bullets keep natural
  sentence case.
- **Zero Em-Dashes and Zero En-Dashes in Prose.** LLMs overuse
  em-dashes. Peter's rule is stricter: none at all in published
  content. Applies even to number ranges. Verbatim quotes from
  external sources are exempt.
```

These files don't do anything on their own, they're just reference documents. The thing that wires them together is a [skill](https://github.com/petems/petersouter.xyz/blob/master/.claude/skills/new-generated-blog-post/SKILL.md) that Claude Code loads before drafting. It points at both files and runs the checklist as a self-review pass before handing me a draft to read.

(The snippets above are lightly sanitised, mostly swapping em-dashes for parens so this page stays clean. The real files are the linked ones.)

It's not bulletproof. Purple prose still slips through, and this very page needed a few editing passes before I was happy signing my name to it. But it catches more slop than any hand-edit I used to do, and it's a lot more useful than a bare "help me write a post about X" prompt.

Even with the tooling in place though, there's one more rule I try to hold to: be honest about when AI is in the mix at all.

## The Disclosure Play

I'd rather be explicit about AI assistance than sneak it in.

If I've asked Claude to sketch something out and I'm sharing it before I've had time to edit, I say so. A quick "here's a rough Claude draft, I'll give a proper take later" costs me nothing, and the person on the other end knows what they've got. Just copypasta-ing LLM output as if I'd written it is a paper-cut of trust in the relationship, even if nobody calls it out.

## Closer

None of this is a rallying cry to hand-write everything or [smash the spinning-jenny](https://en.wikipedia.org/wiki/Spinning_jenny). I use LLMs every day and they've genuinely helped me a lot.

The cake is fine. I just want to be honest about who baked it, and I want it to taste like something I'd actually bake myself.
