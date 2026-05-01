---
title: "Doc MCPs for Validating AI Code"
date: 2026-05-01T00:00:00+00:00
description: "How I use documentation MCPs to keep AI generated code grounded in canonical sources."
garden_topic: "GenAI"
status: "Seedling"
---

One trap with agentic coding is that the model's training cut-off lags behind the libraries you're actually using. It'll happily generate code against an API that changed six months ago and tell you it's correct.

The fix I've fallen into the habit of: point the agent at canonical documentation through an MCP, so it pulls the *current* docs instead of leaning on whatever it remembered during training.

## What I Actually Use

I lean on Context7 the most. Easy to set up, decent coverage, just works.

But there's a whole ecosystem now:

- [Ref](https://ref.tools/), search across docs, GitHub, and blog posts
- [Nia](https://docs.trynia.ai/welcome), indexes docs and your own repos
- DeepCon, another doc indexer in the same space
- DocFork, same idea, different flavour
- RTFMBro, possibly the best-named tool I've used this year

They all do roughly the same thing: scrape docs, make them queryable, and hand the results to your agent so it stops guessing.

## The Local Option

I dusted off my Dash license recently because it now has an MCP. Dash has been my go-to Mac doc mirror for years (offline, fast, indexes basically everything), and being able to query that from Claude Code feels like the offline-first version of all the cloud tools above.

## Fully OSS

If you want to run the whole thing yourself, [docs-mcp-server](https://github.com/arabold/docs-mcp-server) is an OSS equivalent. Scrape docs into a local index, query them via MCP. No SaaS, no signups, your machine, your docs.

## Why Bother

The model is a starting point, not an authority. Pulling from canonical docs at request time means the API actually exists in the version you're using, deprecated patterns get flagged, and the edge cases the model never saw can end up in context.

It's the difference between "I think this is how it works" and "here's what the docs say it does". I'd rather know which one I'm getting.
