+++
author = "Peter Souter"
categories = ["Tech"]
date = 2016-11-02T23:38:49Z
description = ""
draft = false
coverImage = "/images/2016/11/Screenshot-2016-11-02-23.38.22.png"
slug = "some-thoughts-on-maintaining-oss-that-has-an-official-competitor"
tags = ["Tech", "Open-Source", "vDM30in30"]
title = "Some thoughts on maintaining OSS that has an official \"competitor\""

+++

#### Day 2 in the #vDM30in30

I've been maintaining and merging PR's on the
[Tugboat](https://github.com/pearkes/tugboat/) repo since about 2013. I was looking to play around with DigitalOcean, as I'd heard it was a cool upstart alternative to AWS, with cheap, SSD cloud machines, very cool for someone like me who likes tweaking and playing with new operating systems.

I cut my teeth on a lot of new Ruby testing and techniques, like
[webmock](https://github.com/pearkes/tugboat/commit/8d9d16abf8c9b8a76a236ff2c7bc60ed2915563b),
[aruba](https://github.com/pearkes/tugboat/commit/94f334796e7806167202653129ec0adf6e6837df) for command line testing and
[how to DRY-up repetitive methods to make code easier to maintain](https://github.com/pearkes/tugboat/commit/6dffb2aa66c2b4df249ce03c837e7ef8000596b0).

Apparently over 3 years I've made 8,109 additions, 2,550 removals and 188 commits. It's probably the most work longest I've worked on any single project in my open-source career, and I'm proud of the amount of people who I've helped.

![Commits](/images/2016/11/Screenshot-2016-11-02-23.23.53.png)

However, I've not had much chance to contribute recently. I've been busy with work and other things, and since then there's been a lot of hiring over at DigitalOcean recently and tooling up. In fact, they've actually got a "competitor" tool as it were:
[doctl](https://github.com/digitalocean/doctl).

So, with the fact that there was an "official" command-line tool for DigitalOcean, I wasn't doing much work on Tugboat. Someone ended up asking [what the future of Tugboat was](https://github.com/pearkes/tugboat/issues/251).

Funnily enough, after a long period of not working on Tugboat, I had been recently inspired to pick up tugboat work again because someone said
[it was actually helpful accessibility-wise](https://github.com/pearkes/tugboat/issues/248):

> However tugboat for me is an easier interface as I can control my droplet on my mac with out using digital ocean's less then stellar website for screen readers. I should add I used homebrew to install tugboat, so hope that helps a bit.

This actually inspired me to help out, as to me, if at least one person is using my code, and it helps them with a unique use-case then I'm happy to help.

So I ended up going back to the original user who asked about the future of Tugboat and ended up answering:

> tl;dr: If you want the best support and the latest features, doctl is always going to be the bleeding edge. But as long as there is at least one user out there that finds Tugboat useful I will keep tinkering and maintaining 😄

> I'm going to write a longer screed and add it to the README for context, I actually hadn't worked on Tugboat for a while, but when @marrie mentioned in #248 that she preferred Tugboat over Doctl for accessibility reasons, that was a good enough reason for me to come back and start hacking.

I ended up adding the following to the README.md:

> ## History

> When Tugboat was created, DigitalOcean was an extremely new cloud provider. They'd only released their public beta back in [2012](https://whoapi.com/blog/1497/fast-growing-digitalocean-is-fueled-by-customer-love/), and their new SSD backed machines only primiered in early [2013](https://techcrunch.com/2013/01/15/techstars-graduate-digitalocean-switches-to-ssd-for-its-5-per-month-vps-to-take-on-linode-and-rackspace/).

> Tugboat started out life around that time, [back in April 2013](https://github.com/pearkes/tugboat/commit/f0fbc1f438cce81c286f0e60014dc4393ac95cb6). Back then, there were no official libraries for DigitalOcean, and the 1.0 API was a bit unstable and occasionally flakey.

> Since then, DigitalOcean has expanded rapidly and has started offering official libraries.

> They now have an officially maintained command-line client called [doctl](https://github.com/digitalocean/doctl).

> Some people have asked, **where does that leave Tugboat?**

> If you want the bleeding edge of new features and official support from DigitalOcean engineers, **Doctl is the way to go**. However, **as long as there is one other user out there who likes Tugboat and it's workflow, I will try my darnedest to maintain this project, investigate bugs, implement new features and merge pull-requests.**

I thought this was enough of a buyer-beware for people, and in OSS there's no "competitors" really. We're all on the same team; trying to make things better!

Since then I've had a few ideas, and possibly using DigitalOceans new officially maintained Gem as a library, so in summary: yes, technically the official CLI tool will always be more up to date and maintained by way more active people, but as long as people are interested I will keep maintaining and helping with open source software I maintain.
