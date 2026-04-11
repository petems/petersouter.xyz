---
title: "Windows Code Signing"
date: 2026-03-20T00:00:00Z
description: "Figuring out code signing certificates for Windows EXE installers."
garden_topic: "Windows"
status: "Seedling"
---

I'm trying to figure this out and it seems expensive.

Getting proper code signing certificates for Windows EXE installers costs real money - the kind of money that makes you pause and think about whether it's worth it for a side project.

The cheaper and easier route seems to be using the Windows Store, but I don't want to be locked into the store ecosystem. I want people to be able to download a binary from a website and run it without Windows Defender losing its mind.

I need to figure this out. It's the same problem as the [macOS signing situation](/garden/osx-developer-signing/) - I just want to distribute software that people can actually install.
