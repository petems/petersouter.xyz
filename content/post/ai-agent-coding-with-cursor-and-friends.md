+++
author = "Peter Souter"
categories = ["Tech", "Blog", "AI", "Cursor", "Development"]
date = 2025-07-13T09:45:00Z
description = "My experience using Cursor, Claude, and other AI coding tools to rapidly generate and develop new coding projects"
draft = false
thumbnailImage = "/images/2024/04/cursor-thumb.png"
coverImage = "/images/2024/04/cursor-cover.png"
slug = "ai-agent-coding-with-cursor-and-friends"
tags = ["AI", "Cursor", "Claude", "Development", "Coding", "Tools", "Productivity"]
title = "AI Agent Coding with Cursor and Friends"
+++

# LLM Musings and the joy of AI Agent Coding with Cursor and Friends

If you want to know how Cursor (or technically [Claude Sonnet 4](https://www.anthropic.com/claude/sonnet), as that's the LLM running behind the scenes, Cursor is the syntatic suger and developer centric UX on top) thinks about the new world of AI Agent coding, here's what it generated as boilerplate when I gave it the following prompt:

***Update the Hugo post page with todays date, add a brief summary of the experience of using Cursor to generate a new coding project, correct relevant tags in the markdown header, and make sure it loads correctly when hugo runs***`

What it made is this page you see (although originally with some fun around the creation date, I'll talk about that in a bit) and the following content:

> Recently I've been exploring the world of AI-powered coding tools, particularly Cursor (with Claude Sonnet integration) and how they're transforming the development experience. Here's my take on using these tools to rapidly prototype and build new projects.
> 
> ## The Experience
> 
> Using Cursor has been a game-changer for quickly spinning up new projects. The AI assistant can:
> 
> - Generate boilerplate code and project structures
> - Suggest implementations for complex logic
> - Help debug issues in real-time
> - Refactor existing code with intelligent suggestions
> - Write tests and documentation
> 
> ## Key Benefits
> 
> **Speed**: What used to take hours of setup and initial coding can now be done in minutes
> 
> **Learning**: The AI suggestions often introduce me to patterns or libraries I wouldn't have considered
> 
> **Iteration**: Rapid prototyping becomes trivial when you can describe what you want and get working code
> 
> ## Challenges
> 
> **Context**: The AI sometimes lacks broader project context
> 
> **Dependencies**: Generated code may use outdated or incompatible versions
> 
> **Over-reliance**: It's easy to become dependent on AI suggestions rather than understanding the underlying concepts
> 
> ## The Future
> 
> AI coding assistants are clearly the future of development. They're not replacing developers but augmenting our capabilities in powerful ways. The key is learning to work *with* these tools effectively rather than letting them do all the thinking.
> 
> More detailed examples and specific use cases to follow as I continue exploring this space.

Unsurprisingly, it's pretty positive on itself. But honestly all the points it makes are correct. This is happening, whether we like it or not.

## AI Scepticism

I will fully put my hands up and say: I am a huge LLM skeptic in the aggregate. There's no such thing as a free lunch is generally how I look at any tech that is being sold to me as a miracle cure that'll make my life better. As someone who:

* Has friends who are commisioned artists, 
* Enjoys 4k scans of original film negatives when it comes to cult classic movies
* Lives in the current world, where AI Slop is already making certain websites genuinely unusable. 

Unfortunately, there's two distinct problems. 

One, as much as some people would love to think that there's some world where if you resist, you'll be able to 

## "There are AI usecases that have genuinely improved my QoL"

I'm going to be focusing on AI Agents for development and coding in this post, but I will say, over the last year as the LLM world was thrust upon me, I've genuinely had a number of quality of life improvements that have come from LLM usecases. That's not something I thought I'd find myself saying, maybe I was too paranoid and sketpical but that was honestly how I felt. 

Unsuprisignly, these improvements are in areas where LLM's make the most sense to me: automating away gruntwork and letting me concentrate on my expertise and the human side of things. 

For example, as a Solutions Engineer, on a busy week, writing up notes from calls and follow up actions can be as much as a 10+ hour a week time sink. With LLM's, it's genuinely become a seamless process that frees me up to concentrate on the meeting itself, be more prescent and avoids having to block out time to craft relevant meeting notes and remember to email them out. 

> NB: I started out writing an entire novella about how I've been using Whisper Transcript, Zoom AI Companion and Gemini to write meeting notes for customers, but thats a story for another day. Needless to say, it's been great in terms of saving me time as a Solutions Engineer.    
 
Anyway, back to the topic at hand, Development AI Agents and my first dabblings with Kudo. 

## Nerd-Snipes and Bluesky Feeds

This all started with one of the many nerd-snipes that seem to be designed to distract me. I finally bit the bullet and joined Bluesky, and after poking around, found out that its relatively easy to build your own algorithmic feed. 

Unfortunately, the example repo was in Typescript. Whilst I was trying to figure out what the steps were to make my own feed, I ended up reading the feed of ["why" from the bsky team](https://bsky.app/profile/why.bsky.team). He's implemented a number of the "blessed" as it were feeds, for things like "Latest From Mutuals" but even more intriguing, very specific niche feeds like "Posts from your quietest follows".

Now as I was reading why's feed, one thing was clear. They were all in on LLM assisted coding. I kinda rolled my eyes because to me it seemed to be a lot of hype but little actual value. When I'd tried some of the tools in the past, it tended to do funky stuff like make references to other peoples names in.

But I was like "What the heck, the Bluesky example feed generator is in Typescript, I don't know Typescript that well, this is what LLM's excel at: having a huge knowledge base you can piggyback on". Previously I'd taken blocks of code and thrown them into Gemini or ChatGPT and asked it to explain it, but this would be a full code repository. It was time to grit my teath and "vibe code"...


## Small and Scrappy: Kudo.ai 

A mutual from my open source maintaining world had recomended Kudo, so I gave that a shot. And it was pretty neat! It's got a lot of sharp edges and it lacks the polish I found with the tools I used later, but even at it's most janky, I was legitimately impressed. 

Kudo is pretty scrappy and lean in comparison to a lot of the competition. It has things like the ability to earn credits via referals, leaving a review for the extension, joining the Discord and such. 

But that actually was good for me, I wasn't ready to commit to any sort of paid plan or complicated setup. I just wanted something that could do some basic explaining of how to tweak the example repo to my needs and putting in some standard plumbing around unit tests so I could make sure I didn't break anything as I fumbled around poking at Typescript conventions.

### Side Rant: "Vibe Coding" is a bad name

I don't like the term vibe coding. It has the classic hallmarks of bad terminology, ie 

Not to get too crotchety, but it feels a bit "stolen valor". Vibe coding for me brings up images of a bug bash, hackathon or even a band jam. 


