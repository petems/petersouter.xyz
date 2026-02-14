+++
author = "Peter Souter"
categories = ["Tech"]
date = 2016-11-26T21:20:00Z
description = ""
draft = false
coverImage = "/images/2016/11/Screenshot-2016-11-29-21.30.40-1.png"
slug = "quick-testing-with-dply"
tags = ["vDM30in30", "Tech"]
title = "Quickly testing with dply.co"

+++

#### Day 26 in the #vDM30in30

A quick one this time, talking about a fairly recent service,
https://dply.co/

## What is it?

![](/images/2016/11/Screenshot-2016-11-29-21.30.40.png)

dply is a pretty cool service for creating free temporary Linux servers.

Essentially, it's just a GUI in front of DigitalOcean. It  allows you to quickly create a temporary droplet server (1CPU , 512MB RAM, 20GB SSD).

Servers are free for 2 hours and expire after that time (you can add a Credit Card to keep them around for longer)

You login with your GitHub account, which then takes your public key, then you ssh into the created server using the matching private key from your Github account's public key.

It's a pretty cool service for quickly testing out something on a live server.

So far I've been using it to quickly test out scripts or Puppet code in a disposable instance.

## The Button

Another cool part of it is the ability to create a Button:

https://dply.co/button

It's basically a widget you can add to a web page where you specify the cloud-init/user-data script to setup an install.

Pretty useful if you want an easy way to demo an application or app for someone for free.

## API Access

Unsurprisingly, with the ability to create servers on the public internet for free, this thing is ripe for abuse (spamming, bitcoin mining etc.) so you can't deploy servers with an API:

> No. While we love services with robust APIs and their ability to integrate into our projects, the nature of the dply service and it's offer of free temporary servers means that offering an API would be inviting abuse. We may offer an API at some point in the future but it would only allow the creation of servers on paid accounts in order to prevent abuse or automatic re-creation of servers on the free plan.

*Source: https://dply.co/help/faq*

Understandable, but a shame because it'd be an awesome tool for acceptance testing.
