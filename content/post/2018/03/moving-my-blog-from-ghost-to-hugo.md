+++
author = "Peter Souter"
categories = ["Tech", "Blog"]
date = 2018-03-02T12:47:00Z
description = "Moving from Ghost to Hugo"
draft = false
thumbnailImage = "/images/2018/03/ghost-export-750.png"
coverImage = "/images/2018/03/ghost-export.png"
slug = "moving-my-blog-from-ghost-to-hugo"
tags = ["Tech", "Blog", "Terraform", "Hugo"]
title = "Migrating my blog from Ghost to Hugo"

+++

The main piece of tech that I maintain myself is this blog, so I usually find
time to play with it, try new technology such as Docker.

Unsurprisingly, this has led it to be a little over-engineered, and I wanted something
simpler. Why was I trying to figure out how to configure a database in a container
for a blog that only I was maintaining? I didn't need CMS-like functionality, if anything
I needed a static site.

Enter [Hugo.](https://gohugo.io/)

Hugo is a way of generating a static site from markdown files, so it can be deployed
without having to worry about configuring a lot of moving parts.

I'm looking into how I can easily move my old blogs content to a new Hugo instance,
and I've discovered there's already a lot of existing work to do so. In fact, the official Hugo docs have a migrations page that has a list of ways of
[migrating from other blogging platforms to Hugo (eg. Jekyl, Wordpress, Octopress).](https://gohugo.io/tools/migrations/)

So I've been playing with using [ghostToHugo](https://github.com/jbarone/ghostToHugo) to pull my old data out and move it to
a new location, as well as playing with some Terraform to setup the whole thing in
AWS, with S3 as a storage backend, fronted by CloudFront. Not only will this make the
ongoing maintenance a lot easier, from what I've seen online it'll save a big of money,
as the storage costs of CloudFront fronted static sites is a few cents.
