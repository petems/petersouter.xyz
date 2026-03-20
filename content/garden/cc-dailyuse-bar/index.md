---
title: "CC Daily Use Bar"
date: 2026-03-20T00:00:00Z
description: "A system tray app for tracking daily Claude Code cost usage."
garden_topic: "Sideprojects"
status: "Seedling"
---

[CC Daily Use Bar](https://github.com/petems/cc-dailyuse-bar) is a Go system tray application that monitors your daily Claude Code usage and displays real-time cost information in your menu bar. Inspired by [sivchari/ccowl](https://github.com/sivchari/ccowl), but optimised for enterprise plans where spend is tracked per day rather than five-hour windows.

It shows a colour-coded indicator in your tray — green, yellow, or red — based on configurable spend thresholds, so you can keep an eye on how much you're burning through without having to check the dashboard. It polls `ccusage` on a configurable interval and caches results to avoid hammering it too often.
