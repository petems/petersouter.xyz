+++
author = "Peter Souter"
categories = ["Tech"]
date = 2016-11-13T19:12:00Z
description = ""
draft = false
coverImage = "/images/2016/11/usr1.png"
slug = "triggering-a-daemonized-puppet-agent-run-immediately-2"
tags = ["vDM30in30", "Puppet", "Tech", "SysAdmin"]
title = "Triggering a daemonized puppet agent with SIGUSR1"

+++

#### Day 13 in the #vDM30in30

Pretty quick one, but I thought I'd write it up because I hadn't heard about it before.

So, normally when trying to diagnose a puppet issue, one normally runs `puppet agent -t` or `puppet agent --test`. However, the `--test` flag comes with a set of predefined flags:

> **--test**

>Enable the most common options used for testing. These are 'onetime', 'verbose', 'no-daemonize', 'no-usecacheonfailure', 'detailed-exitcodes', 'no-splay', 'show_diff', and 'no-use_cached_catalog'.

**Source: https://docs.puppet.com/puppet/latest/reference/man/agent.html#OPTIONS**

At the time, we were trying to diagnose an issue with cached catalogs and how they worked on failure. However, we couldn't reproduce it with `puppet agent -t` because it explicitly disabled using the cache on failure and using the cached catalog at all.

At first we just set the `runinterval` to a minute and waited for the run to happen, but it turns out there's a way of actually triggering a proper daemonized agent run immediately, running a kill with `SIGUSR1`.

## Unix Signals

What is `SIGUSR1`? It's a reserved [unix signal](https://en.wikipedia.org/wiki/Unix_signal).

If you're less familiar with core unix processes, you've probably ran a unix signal without knowing it:

```
Typing certain key combinations at the controlling terminal of a running process causes the system to send it certain signals:

Ctrl-C (in older Unixes, DEL) sends an INT signal ("interrupt", SIGINT); by default, this causes the process to terminate.
Ctrl-Z sends a TSTP signal ("terminal stop", SIGTSTP); by default, this causes the process to suspend execution.
Ctrl-\ sends a QUIT signal (SIGQUIT); by default, this causes the process to terminate and dump core.
```
**Source: https://en.wikipedia.org/wiki/Unix\_signal#Sending_signals**

Like a lot of people, I knew to run Ctrl-C in a terminal if I wanted to jump out of a process, but I had never really thought about how it works until someone told be about unix signals.

So what about `SIGUSR1`? Well, basically SIGUSR1 and SIGUSR2 are reserved for the developer to define the behaviour:

```
The SIGUSR1 and SIGUSR2 signals are set aside for you to use any way you want. They’re useful for simple interprocess communication, if you write a signal handler for them in the program that receives the signal.
```
**Source: http://www.gnu.org/software/libc/manual/html_node/Miscellaneous-Signals.html**

OK, so basically it's up to the developers to define what the behaviour is.

For Puppet, these are defined as the following:

> **SIGUSR1**
Immediately retrieve and apply configurations from the puppet master.
**SIGUSR2**
Close file descriptors for log files and reopen them. Used with logrotate.
###### Source: https://docs.puppet.com/puppet/latest/reference/man/agent.html#DIAGNOSTICS

So, we can trigger a "fresh" puppet agent run just using `pkill -SIGUSR1 puppet-agent`

We can see that in action here:

1. Send the puppet process the `SIGUSR1` signal:
```
[root@homebox centos]# pkill -SIGUSR1 puppet
```

3. Watch `/var/log/messages` and see a deamonised puppet run is immediately triggered by the signal:
```
Nov 20 19:10:40 homebox puppet-agent[20817]: Caught USR1; storing reload
Nov 20 19:10:41 homebox puppet-agent[20817]: Processing reload
Nov 20 19:11:16 homebox puppet-agent[21582]: Applied catalog in 16.12 seconds
```
