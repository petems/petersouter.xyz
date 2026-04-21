---
title: "Campsite Coding"
date: 2026-04-21T00:00:00+00:00
description: "Leave the code (and the docs) a bit better than you found them. Mostly for future you."
garden_topic: "Concepts"
status: "Seedling"
---

There's a habit I try to stick to whenever I'm in a codebase, or even just passing through some tool's internals to fix a bug: leave it a bit better than I found it.

Campsite rule, basically. Take your rubbish with you on the way out, and if you've got space in the bag, pick up a bit more.

## The Fancy Name For It

The formal term is **Opportunistic Refactoring**, and [Martin Fowler wrote about it way back in 2011](https://martinfowler.com/bliki/OpportunisticRefactoring.html):

> Whenever I do a piece of work on a team code base, I always feel it's my responsibility to leave the code behind in a better state than I found it.
>
> Martin Fowler, November 2011

He actually uses the camp site framing himself in that post, so I can't claim I invented the name.

## It's Not Just Code

The bit I've added for myself is that it's not just about refactoring code. When I hit an issue that properly ruined my day (the kind where I have to dig through GitHub issues, old Stack Overflow answers, and random Discord messages just to work out what's going on), I try to make sure the docs are updated too.

Sometimes that's a PR to the project's README. Sometimes it's a comment on a years-old issue with the workaround I landed on. Sometimes it's just a note in my own `dotfiles` repo so I don't forget.

## Thanks, Old Me

Here's the bit that honestly motivates me the most: a lot of the time, I'm not doing it just to be a good community citizen. I'm doing it for future me as well!

Multiple times over the years, I've come back to a problem months (or years!) later, Googled it, and found... my own PR. My own issue comment. A note I'd left for myself and completely forgotten about.

And I get to do a little salute to past Peter: *thanks old me, you actually helped out here*.

That's the quiet value nobody really pitches you on when they talk about campsite coding as a team virtue. It's nice for your colleagues, it's nice for the open source project, but it's also a little time machine for yourself.

## Within Reason

I do keep the "within reason" caveat. Fowler warns about this in the original post too: don't go down rabbit holes. If you're fixing a typo in a comment, that's not the moment to rewrite the module.

The informal test I use is, if I were reviewing my own PR, would I think *"Oh nice, tidy!"* or *"Why is this in here?"*

 If it's the second one, it probably belongs in a separate change.

But the docs update? That one almost never hurts.
