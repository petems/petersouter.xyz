---
title: "Agentic Learning"
date: 2026-04-17T00:00:00+00:00
description: "Two lesser-known Claude Code output styles that turn the agent from autopilot coder into a patient teacher."
garden_topic: "GenAI"
status: "Seedling"
---

One of the things that bothers me about agentic coding is the "Just press enter and watch it work" loop. Sometimes, yes, I just want to vibe-out a quick spike and Get It Done. But most of the time, I want to actually learn something so I'm not just a token-jockey!

I found out Claude Code has a lesser-known feature that helps: [Output Styles](https://code.claude.com/docs/en/output-styles). They swap out bits of the system prompt so the agent behaves like something other than a ship-fast pair programmer.

Two of the built-in ones are worth knowing about if one is trying to learn whilst Claude is wracking up tokens.

## Explanatory

Still completes the task, but throws in some "**Insights**" that explain implementation choices, codebase patterns, and why it went with this approach over another.

For me, this is more for a mid-point, where it's a language/tool/framework where I'm fairly up to speed but always want to know more.

## Learning

This is the one that properly surprised me!

Instead of writing all the code itself, Claude Code drops `TODO(human)` markers in the spots where it wants *you* to fill in the logic. You write the tricky bits, it handles the scaffolding, and it still chimes in with "**Insights**" while you work.

Essentially, it turns the session into a mini pair-programming exercise where you're the junior and the agent is the patient sensei who refuses to just do it for you.

## Turning Them On

Run `/config`, pick one from the Output style menu. Or set it directly in `.claude/settings.local.json`:

```json
{
  "outputStyle": "Learning"
}
```

I've found that setting it locally is a lot better for me than globally, as it's probably overkill for a lot of the things I work on where I'm fairly up to speed.

{{< info >}}
Like with most Claude setting changes, it takes effect on the next session. Output styles get baked into the system prompt at session start, so prompt caching keeps working.
{{< /info >}}

## Why I Like Them

A lot of my "GenAI is eating my brain" anxiety comes from watching the agent solve something and realising I learnt nothing from it. Learning mode flips that. Progress is slower, but it's my progress.

You can also write [custom output styles](https://code.claude.com/docs/en/output-styles#create-a-custom-output-style) if you want a tweaked variant. Haven't gone there yet, but it's filed away for the next time I'm poking at a new language.
