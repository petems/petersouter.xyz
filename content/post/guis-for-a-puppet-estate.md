+++
author = "Peter Souter"
categories = ["vDM30in30", "Puppet", "open-source"]
date = 2016-11-16T14:34:00Z
description = ""
draft = false
coverImage = "/images/2016/11/dashboard-1.png"
slug = "guis-for-a-puppet-estate"
tags = ["vDM30in30", "Puppet", "open-source"]
title = "GUI's for a Puppet estate"

+++

#### Day 16 in the #vDM30in30

I actually wrote a [Stack Overflow answer to this](https://stackoverflow.com/questions/37270804/dashboard-for-puppet-4/37284454#37284454), but I thought I'd formalise and update it a bit.

## How do the GUI's work?

So, most Puppet GUI's and Dashboards use reporting from PuppetDB, so as long as you have PuppetDB in your infra they will work, regardless of your Puppet version. It simply takes reports from PuppetDB and performs queries again PuppetDB for searches about information.

The exception to this is Foreman, which has it's own ENC that processes reports rather than using PuppetDB

> How does Foreman work with PuppetDB?
Foreman does not use PuppetDB, nor does PuppetDB use Foreman. While they can both be used at the same time if you wish, there is no integration between these two tools.

Source: **https://projects.theforeman.org/projects/foreman/wiki/FAQ**

So Foreman is it's own beast, but works broadly in the same way.

## Puppet Enterprise:
**Commercial - Free for up to 10 nodes**

Obviously, full disclosure I work at Puppet, so I'm going to have a little bias here.

But honestly, Puppet Enterprise is really good. Even from when I began at Puppet 2 years ago, Puppet Enterprise has come leaps and bounds. There's some really cool features such as code manager and the console for classification.

I even run it at home, so that's a real endorsement!

![Puppet Enterprise](/images/2016/11/Screenshot-2016-11-22-17.28.47.png)

https://puppet.com/download-puppet-enterprise

## The Foreman:
**Open Source - GPL 3**
![](/images/2016/11/TheForemanOverview.png)

https://www.theforeman.org/

The Foreman is RedHat's open-source core behind Satellite, and it's way more than just a Puppet dashboard really. It's more of a provisioning platform with a bunch of plugins, and it can do things like OpenSCAP scanning, provisioning cloud instances and the like.

## PuppetBoard
![Puppetboard Screenshot](/images/2016/11/puppetboard.png)
https://github.com/voxpupuli/puppetboard

This is probably the most commonly used dashboard for Puppet I've seen after Foreman and PE. It's used by Openstack's infra team for example.


## Puppet Explorer:
**Open Source - Apache License**
![](/images/2016/11/dashboard.png)

http://puppetexplorer.io/

This was a pretty cool project by Dalen, [Puppet MVP 2014](https://puppet.com/blog/contributor-summit-puppetconf-2014-edition).

It has a pretty neat live search function using puppetdbquery. So you can do searches accross your estate with information from PuppetDB, so like `processorcount=4 or processorcount=8 and kernel=Linux` to get all your 4 and 8 core Linux machines, and show the latest runs and such.

Side-node: Puppet ended up rolling the core concept of ideas from puppetdbquery into Puppet internally into the [Puppet Query Language (PQL)](https://docs.puppet.com/puppetdb/4.0/api/query/v4/pql.html)
