---
title: "Human PR Reviews"
date: 2026-05-01T00:00:00+00:00
description: "On the creeping loop where agentic code gets agentically reviewed and agentically fixed, and why that makes me nervous."
garden_topic: "GenAI"
status: "Seedling"
---

There's a loop that's starting to bother me.

Agentic tooling writes the code. A bot does the review. The agent reads the review comments and fixes them automatically. Nobody ever actually looked at the diff.

I get why it happens. PR review is slow and uncomfortable. Giving feedback is awkward. Receiving it can be worse. So if you can outsource the whole thing to a chain of agents, why wouldn't you?

The problem is that the friction is doing something.

When a real person reviews code, they have to actually read it. They have to form an opinion. They put their name on the comments. If they get something wrong, or miss something important, that's on them. When the person whose code got reviewed disagrees, they have to push back out loud rather than silently re-running the agent.

That back-and-forth is where a lot of the actual decision-making happens. "Should we do it this way or that way?" isn't always resolved by the first person who suggests something, it gets resolved by argument. Agentic review short-circuits that.

## What I Built

I made a [Claude Code skill](https://github.com/petems/human-pr-review-skill) that tries to keep a human in the loop without killing the agentic convenience.

The skill collects all the PR context, runs the analysis, and drafts the review. But it won't post anything until you've actually opened the review file in your IDE. There's a sentinel file check: if you haven't done the `/show` step, `/send` refuses to run.

It's a small piece of friction. You have to physically look at the draft before it goes out. But that moment of opening the file is enough to force engagement: "Wait, I wouldn't have said it that way" or "Actually that nit is wrong" or just "Yeah, this looks right, I'm happy to put my name on it."

Putting your name on it is the point. If the review goes out with your name attached, you own it.

## The Broader Worry

I'm honestly not sure where the right line is here. I use agentic tooling heavily and I'm not about to stop. I'm also aware that I'm building tools to gatekeep *other* agentic tools, which is a bit funny.

But I think the code review case is worth being careful about. Reviews aren't just about catching bugs (automated tests do that). They're about shared understanding. About conventions being argued into existence. About someone saying "I've seen this pattern cause problems before" and the person on the other end actually hearing it. That stuff doesn't survive if nobody's actually reading the diffs.

Maybe I'm out of step with where this is all going. But for now I'd rather slow down the review loop than fully automate my way out of understanding my own codebase.
