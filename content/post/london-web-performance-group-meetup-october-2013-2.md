+++
author = "Peter Souter"
categories = ["Tech", "meetup", "performance"]
date = 2013-10-15T11:00:00Z
description = ""
draft = false
image = "/images/2016/10/web_perf_oct-4.jpeg"
slug = "london-web-performance-group-meetup-october-2013-2"
tags = ["Tech", "meetup", "performance"]
title = "London Web Performance Group meetup - October 2013"

+++

![London Web Performance Group meetup - October 2013](/content/images/2016/10/global_18959598-1.jpeg)

So, I've just come back from the October London Web Performance Group meetup, and I thought I'd write up some notes, as I've found it to be one of the best tech meetup groups in London. There's been a nice line-up of speakers, it's a pretty good location to get to and, last but not least free beer and food!

They're not exhaustive notes, as there was a lot of specific references and diagrams, which will be better served by the slides themselves, which I'll link if I can get a copy.

So, the theme for the October was High performance infrastructure, run by David Mytton from Server Density. I thought the name rang a bell, and it just occured to me I remember reading many moons ago his blog posts about Mongo (particularly about the changes from 2.0 to 2.2) on the [Server Density blog](https://blog.serverdensity.com)

## Where do performance issues come from in Infrastructure?

- In the Cloud, there's always going to get spikes of latency, and it's hard to diagnose packet loss.Especially because infrastructure performance issues are largely transient, so it's hard to pin-down  what the issue is.

This is a recurring theme of performance testing a full-stack application: Yes, it's slow. But what's causing the slowness?

- A lot of times you'll get more issues with a large amount of small updates than with less frequent larger network traffic spikes.

MongoDB replicating to a slave for example...

- Using ping to diagnose latency is not the answer. Too lightweight, you need to see the routing overhead.

Write a script, or live-fire the app in the wild: It's the only real way to diagnose the issue.

##MongoDB

- Write concern, the balance between performance and consistency (all slaves are eventually consistent)

This is something that's been talked about a lot with regard to Mongo. I actually remember the original blog post that [highlighted this](http://hackingdistributed.com/2013/01/29/mongo-ft/). Since then there's been a lot of changes, and now most mongo drivers have changed the write concern up a few steps.

- Field names

Field Names are replicated in nosql (otherwise how would you know what's what?),and can cause overhead when you get into the millions and billions of record level. One solution is to use 1 character field names. Not exactly developer friendly, but can solve by having an abstraction level on top.

# How to improve performance of infrastructure

The hierarchy to improve database performance is

* RAM
* SSD
* Faster Spinning HDD

The higher up on the list, the more effective it is. But, the higher up it is, the more expensive it is....

# Only use Cloud for...

- Elastic workload
- Demand spikes
- Uncertain requirements ie. Startups

I agree with this totally and this is probably the biggest misconception about cloud services that people have. Cloud isn't a magical fix for operations. It's more that cloud servers are the most flexible solution.

Just got out of incubation and have no idea what your infrastructure will look like in the future? Or need to pivot? Or you've just been linked on Hacker News everythings creaking? Spin up some more servers, kill them when it's over, easy peasy.

However, if your load is fairly static, it's a lot better to have a dedicated servers in the long-term. Blippex did a [pretty good write-up](http://blippex.github.io/updates/2013/09/23/why-we-moved-away-from-aws.html) about their move from AWS to dedicated servers.

# Alternatives to Cloud Servers

### Dedicated 
- Full control
- Inexpensive disk space
- Bandwidth is cheap
- High performance (generally, very wide pipes!)

### Colo
- Most expensive
- DIY
- Costs the most, but generally best performance

A lot of detail about Server Density's initial trial's of setting up, was quite cool to get pretty granular with the companies choices and the comparisons in cost.

But the general take-away was: the more DIY you put in and more you pay up front in purchase costs, the less you pay in the long term. 

# Backups

- You should determine what's your use-case for backups is:
* If it's user error, they need to be very frequent! If a customer accidentally deletes their account, they need the restore to be as fresh as possible.
* If it's for point in time restores, how stale is the data, and how many issues is it going to cause when you restore it.
* If it's for disaster recovery, it needs to be stored off-site! Otherwise, what's the point...

# Humans on call

Some discussions about being on-call for incidents. Interesting that at Server Density, everyone is on call after a certain level of escalation and the CEO gets all emails.

Also, PagerDuty will keep ringing someone every minute for 20 minutes before it goes onto the next person in the chain. Try sleeping through that!

# Internal communication when issues occurring.

I particularly like the reference to a "sterile cockpit". A concept from the aerospace industry, when pilots ban all non-essential chatter during critical moments in flight like take-off.

From personal experience it's a bit distracting when you're in the guts of a server in your terminal, trying to diagnose what's caused mongo to fall over in the middle of an important test and everyone on Campfire is posting gifs...

# Uptime

They use New Relic Reports of uptime, and have post-mortems for downtime. Bottom line is, whilst you aim for 100% uptime, you can never avoid outages (even google and AWS go down!)

# Simulations and drills. 

Something not often discussed, but needs to be done.

It's too common of a pattern to have a load of fail-safes that are never tested until an incident actually occurs. 

# Questions

There was also some good debate about how to encourage those on call. Then to justify the extra costs by comparing how expensive it is to _not_ have people on-call, either by looking at churn caused by (not super reliable) or even Google analytics to see how many people were lost. The old "We just lost X amount of money on Google Ads when the server went down, and it only costs Y to have someone on call to check it out when it happens"

I asked a question which always seems to be the biggest issue with performance: figuring out where the issue is. Its easy to write some performance tests and then say "My app is slow"...but is it the choice of technologies for your stack that's the culprit? The code itself and it's architecture? Or is it on the infrastructure?

Unfortunately (as I suspected) there is no silver bullet. Best bet is to use someone like New Relic or Serverdensity which you can add into the apps themselves, which can see the internals of the app and figure out pain points, combined with monitoring and performance scripting to narrow down the suspects.

Looking forward to the next meetup, [WebPerfDays London 2013!](http://webperfdayslondon2013.eventbrite.com/)