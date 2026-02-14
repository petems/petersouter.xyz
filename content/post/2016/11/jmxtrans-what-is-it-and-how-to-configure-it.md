+++
author = "Peter Souter"
categories = ["Tech"]
date = 2016-11-12T11:30:00Z
description = ""
draft = false
coverImage = "/images/2016/11/3248419938_768ee915bf_o-1.png"
slug = "jmxtrans-what-is-it-and-how-to-configure-it"
tags = ["vDM30in30", "Tech", "Puppet", "Monitoring", "Metrics"]
title = "jmxtrans: What is it and how to configure it"

+++

#### Day 12 in the #vDM30in30

I've been investigating getting metrics from the Java parts of Puppet.

Puppetserver actually has a [dedicated endpoint now](https://docs.puppet.com/puppetserver/2.6/status-api/v1/services.html), but if you're on an earlier version you can actually extract the information straight from JMX.

I've been working on a Vagrant stack to demonstrate this, but I've not got it fully working yet, but I've made some good progress. I think there're just a few tweaks left.

In the meantime, let's talk JMX and jmxtrans.

## What is JMX?

So JMX stands for [Java Management Extensions](https://en.wikipedia.org/wiki/Java_Management_Extensions), a well-established, but not widespread technology allowing to monitor and manage any JVM.

At it's most basic level, it provides CPU, thread and memory monitoring. You can also configure custom metrics for it in the MBeanServer class.

It's actually been around for a long time, Sun opened JSR 318 with the JMX spec in [December 1998](http://www.jcp.org/jsr/detail/3.jsp).

## Why it's good?

Since is in every Java version for over a decade and a half, you've basically got built in metrics and monitoring in any Java application.

All you need to do is configure the `JAVA_ARGS` to enable the JMX port to be open, and bam: you've got metrics.

This is usually done with something like:

```
-Dcom.sun.management.jmxremote
-Dcom.sun.management.jmxremote.authenticate=false
-Dcom.sun.management.jmxremote.ssl=false
-Dcom.sun.management.jmxremote.port=1099
```

The base tools for reading JMX are pretty crude but effective...such as JConsole:

![](/images/2016/11/3248419938_768ee915bf_o.png)
> Source: https://flic.kr/p/5X415j

However, I'm more interested in getting those logs into monitoring, specifically a Graphite/Grafana stack.

## Where does jmxtrans fit in?

I think the README explains it best:

> This is effectively the missing connector between speaking to a JVM via JMX on one end and whatever logging / monitoring / graphing package that you can dream up on the other end.

> ...

> The core engine is very solid and there are writers for Graphite, StatsD, Ganglia, cacti/rrdtool, OpenTSDB, text files, and stdout. Feel free to suggest more on the discussion group or issue tracker.
###### Source: https://github.com/jmxtrans/jmxtrans/blob/master/README.md

I was introduced to the [jmxtrans](https://github.com/jmxtrans/jmxtrans) when I was looking into puppet-server monitoring, as the operations team at Puppet already use it to monitor the various Java systems that we run: Jira, Confluence and the Puppet stack itself: PuppetDB, PuppetServer and the console-services app.
## How to configure it

Luckily the InfraCore team at Puppet had made a module to install it, and had some profiles they were using internally that I could test a little. I got most of the setup done without too much work.

## Systemd strikes again...

However, in my tests, I couldn't get it to work on CentOS 7. The culprit: a missing service file. The package only contained the older format with an init file located at `/etc/init.d/jmxtrans`.

There's already an issue open asking
[how to get it working on CentOS 7 and systemd systems](https://github.com/jmxtrans/jmxtrans/issues/485), and the user had posted the unit file they were using:

```
[Unit]
Description=JMX Transformer - more than meets the eye
After=syslog.target network.target

[Service]
Type=forking
PIDFile=/run/jmxtrans/jmxtrans.pid
EnvironmentFile=/etc/sysconfig/jmxtrans
User=jmxtrans
ExecStart=/usr/share/jmxtrans/bin/jmxtrans start

[Install]
WantedBy=multi-user.target
```

This seemed to work at first, but I usually check my Puppet code with a few common issues that pop-up like rebooting and enabling the service. On reboot, the service didn't run.

This appears to be because

Jaria explains it well:

> To my surprise, my contraption from the previous article didn't survive a reboot. WTF?! It turned out that in Fedora 19 the /var/run/ is a symlink into /run/ which has been turned into tmpfs. Goddamnit! It literally means, that it is pointless to create `/var/run/<the daemon name here>/` with correct permissions in RPM spec-file. Everything will be wiped clean on next reboot anyway.

So I ended up going with something similar to what he posted in the blog post, adding an `ExecStartPre` section:

```
[Unit]
Description=JMX Transformer - more than meets the eye
After=syslog.target network.target

[Service]
Type=forking
User=jmxtrans
Group=jmxtrans
# Run ExecStartPre with root-permissions
PermissionsStartOnly=true
ExecStartPre=-/usr/bin/mkdir /run/jmxtrans/
ExecStartPre=/usr/bin/chown -R jmxtrans:jmxtrans /run/jmxtrans/
PIDFile=/var/run/jmxtrans/jmxtrans.pid
ExecStart=/usr/share/jmxtrans/bin/jmxtrans start

[Install]
WantedBy=multi-user.target
```

This seems to work in my tests, even after a reboot.

I opened a PR to get that merged into the InfraCore team module, and have a few other ideas for PR's to merge.

Hopefully, I can get my Vagrant stack working and I can actually get the stats from `jmxtrans` into graphite and show off some graphs in a future blog post!
