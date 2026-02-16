+++
author = "Peter Souter"
categories = ["Meta", "Blogging"]
date = 2026-02-16T00:00:00Z
description = "My content roadmap for 2026: conference speaking, GenAI topics, blog infrastructure updates, and personal goals."
draft = false
slug = "my-2026-blogging-plans"
tags = ["Blogging", "Conferences", "Speaking", "GenAI", "Hugo", "Obsidian"]
title = "My 2026 Blogging Plans"
keywords = ["blogging", "2026", "conferences", "testcon", "cfgmgmtcamp", "fosdem", "genai", "mcp", "hugo", "obsidian"]
thumbnailImage = "/images/2026/02/long-exposure-new-york-skyline.jpg"
coverImage = "/images/2026/02/long-exposure-new-york-skyline-cover.jpg"
+++

I've got a lot of ideas of what I want to post about in 2026, a mix of plans for the future and catching up on the things I was meant to be posting about in 2025.

So here's a bunch of things I did in 2025 and 2026 I've been meaning to go back and talk on, and you can think of this as a sneak preview of all the things I'll eventually blog about in some capacity this year.

## Speaking and Conferences

Looking back over my blog for the last 8 years, I forgot how much I was attending and speaking at conferences. Unsurprisingly the pandemic put a bit of a kibosh on that, combined with being busy in general, but I finally got back on the horse in 2025 and again in 2026 already, so I thought it'd be good to put in my trip reports of what I saw, a meta-post about what I spoke about and enhance and level up my existing `/talks` section.

### TestCon 2025

I finally got back on the horse of conference speaking, after a 5 year break! Specifically, I spoke at TestCon 2025 with a talk of ["CI/CD Observability, Metrics and DORA: Shifting Left and Cleaning Up!"](https://events.pinetool.ai/3498/#sessions/112207). I want to talk about the conference, how it felt to speak again after such a big break, and what to do better next time.

### FOSDEM 2026

I actually missed out on FOSDEM this year as I was already doing so much travel, I didn't want to use up another weekend, especially when I was going to Cfgmgmtcamp 2026 immediately after, but there are always a bunch of super interesting talks that come out of it so I wanted to go through the talks I liked and post about that.

### Cfgmgmtcamp 2026

I spoke at [Cfgmgmtcamp](https://cfgmgmtcamp.org/) again, which was great, as I realise this is about the 10-year anniversary of the first time I spoke there in 2016, and it was great to be back there after my last talk was February 2020 (literally weeks before UK went into lockdown.)

I did an updated version of my TestCon 2025 talk ["CI/CD Observability, Metrics and DORA: Shifting Left and Cleaning Up"](https://cfp.cfgmgmtcamp.org/ghent2026/talk/98XRKP/) and also did my first Ignite talk, speaking about my work with the VoxPupuli with Datadog - ["Untaggling Strings: Getting CI Visibility for Vox Pupuli Tests"](https://cfp.cfgmgmtcamp.org/ghent2026/talk/UTCKK9/)

### Enhancing My `/talks` Sub-Site

Adding all the talks I've given, giving links to the event pages, the slides and recordings where possible. I then wanted to make things a bit more user friendly so I did some Claude Code front-end work to add in some filtering and search to all the topics. I've actually done a first pass at that already, [go check out the first iteration now](/talks/).

## Tech and GenAI

I know, I know, blogging about GenAI, how original, and it's funny! It's a double-edged sword, it's something that's allowed me to go back and work on a number of projects I'd been stuck on, start new side projects and fix old backlog issues... but also I've had a lot of thoughts around the practicalities of that. It also lead me down a burnout road, and I think GenAI discussion is frequently frustrating for multiple reasons.

### Building a GitHub PR Review MCP

After getting frustrated with the [official GitHub MCP](https://github.com/github/github-mcp-server) for its size for what I was doing (plus getting spooked by some of the [security vulnerabilities](https://invariantlabs.ai/blog/mcp-github-vulnerability) it'd had), I found myself making a basic one for my specific use case: An MCP flow to just get the comments left on a pull request for an agentic coding flow to review and implement.

* <https://github.com/petems/github-pr-review-mcp-server>

It was a good learning experience, and helped me understand what MCP is good and not good for, as well as something I find personally very useful and continue to use for my own personal projects.

### GenAI Burnout

A lot of people are talking about the GenAI burnout effect:

- <https://steve-yegge.medium.com/the-ai-vampire-eda6e4f07163>
- <https://theunisdk.medium.com/ai-adhd-the-cost-of-infinite-possibility-fc4d447583a7>

<blockquote class="bluesky-embed" data-bluesky-uri="at://did:plc:ckaz32jwl6t2cno6fmuw2nhn/app.bsky.feed.post/3mevhhd4lbs2b" data-bluesky-cid="bafyreiav7tlrkksxa75h6u3vn6xozk2wuimbgch37qogsmqy4cmd6mg7u4" data-bluesky-embed-color-mode="system"><p lang="en">Token Anxiety

i think i mostly echo this for myself. with so much that can be done, i often feel like i *should* be doing something, always<br><br><a href="https://bsky.app/profile/did:plc:ckaz32jwl6t2cno6fmuw2nhn/post/3mevhhd4lbs2b?ref_src=embed">[image or embed]</a></p>&mdash; Tim Kellogg (<a href="https://bsky.app/profile/did:plc:ckaz32jwl6t2cno6fmuw2nhn?ref_src=embed">@timkellogg.me</a>) <a href="https://bsky.app/profile/did:plc:ckaz32jwl6t2cno6fmuw2nhn/post/3mevhhd4lbs2b?ref_src=embed">15 February 2026 at 11:44</a></blockquote><script async src="https://embed.bsky.app/static/embed.js" charset="utf-8"></script>

It's definitely an area where I think people in the tech industry, especially neurodiverse people like myself are most vulnerable to getting into a bad headspace. In fact I have personal experience with this from 2025 specifically, so I wanted to research this and talk about it as well.

### LLM for Dummies

Understanding a lot of the underlying core fundamentals was a big boon for me in breaking through the hype and FUD about GenAI, so I wanted to give a 101 on what GenAI is and the biggest changes that are coming, as well as [recommending the books I read](https://www.oreilly.com/library/view/prompt-engineering-for/9781098156145/) that helped on that topic.

## Blog Infra Updates

This blog is 8 years old now, and I've not done a big refresh of the underlying hosting tech and the pipelines in place for it for a while. It was one of the blockers for me to post sometimes, because I'd think "I should be fixing that stuff before I do any new posts."

### Upgrading the Building Blocks

Moving away from CircleCI, updating the Hugo version, double-checking the current AWS S3 hosting approach, there's a number of things I've tweaked or thought about fixing in the future.

### Tranquilpeak Refresh

The theme I'm using has been effectively [abandoned since 2022](https://github.com/kakawait/hugo-tranquilpeak-theme/commit/3b5676afca7e667fc0d5c7f012c2ad00ca6dd9f0), I'm trying to figure out how I handle that. Do I fork? If I do, is there value on maintaining it "officially"? Do I switch over to something new?

### Using New Hugo Features

Since I'm using such an old Hugo version, there's been a lot of enhancements around [asset pipes](https://gohugo.io/hugo-pipes/introduction/), [render hooks](https://gohugo.io/render-hooks/introduction/) and [deployment in the app itself](https://gohugo.io/host-and-deploy/deploy-with-hugo-deploy/). I need to research all that and see what makes sense to pickup.

### Adding a Garden Section

I have a lot of "Misc" ideas that I've been trying to figure out how to host. I've seen this as a "Garden" style concept such as on Daniel Corin's site: <https://www.danielcorin.com/garden/>

## My Love of Obsidian

I've switched to [Obsidian](https://obsidian.md/) as my main to-do list, scratchpad, research platform... basically my swiss army knife for anything involving writing. I want to talk about my workflows I've developed, what [plugins](https://obsidian.md/plugins) are worth the time to understand, and how it's been a boon for me as a daily driver.

## Personal

I've also got other non-tech specific topics I've been thinking about, a lot are too general to commit to, but I do specifically want to continue with my commitment to public accountability of targets.

### General 2026 Goals

Personal things I want to do, like gym and powerlifting targets, reading more, watching more movies, and my ideas to write a book about baseball!

## Wrapping Up

This is an ambitious list I'll admit, and I'm sure it'll evolve throughout the year. Some of these posts might merge together, some might not happen at all, and I'm sure new ideas will emerge. If any of these topics particularly interest you, let me know - it might help me prioritize what to write next.
