---
title: "PR Wrangler"
date: 2026-03-20T00:00:00Z
description: "A TUI for triaging and acting on GitHub pull requests."
garden_topic: "Sideprojects"
status: "Seedling"
---

[PR Wrangler](https://github.com/petems/pr-wrangler) is a terminal UI written in Go for triaging and acting on GitHub pull requests. 

Right now, it uses the `gh` CLI to discover PRs, classifies each one into actionable states like "Fix CI", "Address feedback", or "Resolve Conflicts", and launches task-focused tmux sessions for follow-up work.

The idea is to have a single dashboard where you can see all your open PRs and quickly fire off agentic flows to deal with them - fixing broken CI, addressing reviewer comments, resolving merge conflicts - without leaving the terminal.

Eventually the idea would be to use proper API calls, OAuth flow and all that jazz. But it's a quick way to fire off various repeatable tasks
