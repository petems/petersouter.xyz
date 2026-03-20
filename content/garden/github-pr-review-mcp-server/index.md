---
title: "GitHub PR Review MCP Server"
date: 2026-03-20T00:00:00Z
description: "An MCP server for extracting PR review comments."
garden_topic: "Sideprojects"
status: "Seedling"
---

[GitHub PR Review MCP Server](https://github.com/petems/github-pr-review-mcp-server) is a Python-based MCP server that takes the comments from a GitHub pull request reviewer and returns them as structured markdown or JSON.

The goal is to make it easy for both humans and AI agents to consume PR feedback in a structured way. You point it at a PR, and it extracts all the review comments into a format that's easy to act on — either manually or by feeding it into an agentic workflow that can automatically address the feedback.
