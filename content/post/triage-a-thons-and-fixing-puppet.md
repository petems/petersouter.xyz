+++
author = "Peter Souter"
categories = ["Puppet", "Tech", "config management", "open-source"]
date = 2014-06-02T22:52:25Z
description = ""
draft = false
image = "/images/2016/10/triage_a_thon.png"
slug = "triage-a-thons-and-fixing-puppet"
tags = ["Puppet", "Tech", "config management", "open-source"]
title = "Triage-a-thons and Fixing Puppet"

+++

Every 3-4 months, Puppetlabs has a [Triage-a-thon.](http://puppetlabs.com/community/triage-a-thon)

It's a cool opertunity to get your hands dirty looking at the puppet source code, help fix some outstanding issues and generally help out the community.

Everyone jumps on IRC, and you can fish through the [Puppetlabs Jira](http://tickets.puppetlabs.com) and find out what you can fix, and sometimes just do a bit of janitor-ing removing old tickets that are resolved or nudging people for reviews and the like.

I've ended up doing attending most of the Triages that have happened, as it's easy enough to just have a quick look in the evening after work and do a bit of working away. There's also a bit of self-interest because it's a good way to get some input on potential bug-fixes for issues that affect projects you've been working on.

Plus there's normally cool prizes or t-shirts, which I'm a sucker for!

![](/content/images/2016/10/triage.png)

The white whale issue that I'm still fiddling with is probably [an issue with duplicate package names in puppet.](https://tickets.puppetlabs.com/browse/PUP-1073). 

It's a live issue with Puppet that's affecting one of the projects I'm on, because we have two packages with the same name, one a pip package, the other an RPM installed by Yum. If you try to have a package with the same name as another, even with the different providers, Puppet throws a wobbly.

The Jira ticket is actually a duplicate of a Redmine ticket that goes [all the way back to 2008](https://projects.puppetlabs.com/issues/973). Like any big project, there are times when a fix like this goes unnoticed for a long time until someone has a crack at it. I've got a [basic work-in-progress branch for it](https://github.com/petems/puppet/tree/PUP-1073/duplicate-package-names), but it's a bit of a head-scratcher and something that'll probably need a lot of review time to get merged. Hopefully I'll get it fixed soon!