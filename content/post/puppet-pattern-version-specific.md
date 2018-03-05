+++
author = "Peter Souter"
categories = ["vDM30in30", "Puppet", "open-source"]
date = 2016-11-29T15:30:00Z
description = ""
draft = false
image = "/images/2016/11/17340332605_b13cf471ad_h.jpg"
slug = "puppet-pattern-version-specific"
tags = ["vDM30in30", "Puppet", "open-source"]
title = "A Puppet pattern for version specific config settings"

+++

#### Day 29 in the #vDM30in30

> Image from https://flic.kr/p/sqiJKP 

Let's talk about the lifecycle of a Puppet run.

* The Puppet agent process collects information about the host it is running on including facts, which it passes to the server.
* The parser uses that system information and Puppet modules on local disk to compile a configuration for that particular host and returns it to the agent.
* The agent applies that configuration locally, thus affecting the local state of the host, and files the resulting report with the server, including the facts from the system

Essentially, Puppet runs in an atomic fashion: Information it has is locked at the start of the run, and is not changed. At the end of the run, facts might be different, but the catalog stays the same.

## So, what's the problem?


Lets say we have a module to configure a particular application.

However, some of the configuration settings are only valid in a newer version of the app.

If the new configuration settings are used with an older version of the application, it refuses to start.

Catch-22.

## POLA

> The Principle of Least Astonishment states that the result of performing some operation should be obvious, consistent, and predictable, based upon the name of the operation and other clues.
Source: http://wiki.c2.com/?PrincipleOfLeastAstonishment

According to POLA, if someone downloads the module and applies it, it should Just Work(TM). They shouldn't need to know about the different configuration settings for the version their running if they're using the defaults.

The easiest solution would be to just put a note in the `README` saying "Make sure you use the latest version, otherwise this setting won't work". 

But that's not very friendly or good for new users, plus it breaks POLA.

So how can we fix this?

## Facter version fact, plus a default assumed version

A pattern I've seen to solve this is a combination of two things:

* A custom fact that reads the current version of the application
* An assumed version parameter, set with the assumed version of an application from the operating system's default package manager

## A Collectd example

The collectd was having this issue, as there were plugin settings that were only avaliable in collectd 5.5 onward.

So, they added a custom fact to get the collectd version if installed. 

Then they added parameter `$minimum_version` which defaulted to the minimum version in the package repository.

```puppet
$collectd_version_real = pick($::collectd_version, $minimum_version)
```

It then uses the `pick` function between the custom fact of the version of the package, and the minimum version:

> From a list of values, returns the first value that is not undefined or an empty string. Takes any number of arguments, and raises an error if all values are undefined or empty.

So, this `$collectd_version_real` parameter can then be compared to the minimum version required for any configuration settings.

This goes something like this:
```
<% if scope.lookupvar('collectd::collectd_version_real') and (scope.function_versioncmp([scope.lookupvar('collectd::collectd_version_real'), '5.5']) >= 0) -%>
```

So this configuration setting will only be set if the version of collectd is 5.5 or above:

* If the package wasn't installed on the run, then the `minimum_version` parameter is used and compared to see if greater or equal to 5.5
* If the package is installed, the fact is avaliable and that is compared to see if greater or equal to 5.5

## Redis

This problem is affecting the redis approved module I have push rights to, so I'm going to use this pattern to lock off the Redis 3+ only parameters, avoiding the failure message with older redis: https://github.com/arioch/puppet-redis/issues/111

## Conclusion

It's a bit convoluted, but the atomic nature of catalog compilations means this is the best way to do this.