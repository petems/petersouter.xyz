+++
author = "Peter Souter"
categories = ["Tech"]
date = 2016-11-05T20:55:00Z
description = ""
draft = false
coverImage = "/images/2016/11/Screenshot-2016-11-06-20.10.42-1.png"
slug = "system-administration-with-cockpit"
tags = ["Puppet", "Open-Source", "vDM30in30"]
title = "System Administration with Cockpit"

+++

#### Day 5 in the #vDM30in30

Cockpit is RedHat's GUI for system administration. It's actually installed on Fedora by default now, but it can run on most operating systems (there's repos for Arch, Debian, CentOS and Ubuntu).

RedHat are already using it as the main [way of interacting with RHEV](http://rhelblog.redhat.com/2016/05/11/viewing-the-horizon-from-the-cockpit/), their libVirt virtualization platform and it's installed as a part of [OpenShift, their **PaaS** for container orchestration](https://blog.openshift.com/monitoring-openshift-cluster-using-cockpit/).

It includes a bunch of tooling for your standard sysadmin tasks:

#### Restarting Services:
![](/images/2016/11/Screenshot-2016-11-06-19.08.08.png)

#### Monitoring Disks:
![](/images/2016/11/Screenshot-2016-11-06-19.14.32.png)

#### Monitoring Network:
![](/images/2016/11/Screenshot-2016-11-06-19.13.19.png)
(You can see the spike where I downloaded a test file (`wget http://ipv4.download.thinkbroadband.com/100MB.zip`)

#### Reading Logs:
![](/images/2016/11/Screenshot-2016-11-06-19.09.24.png)
(You can see where I forgot to add sudo rules to my petems account)

You even have a terminal to run commands on the system with:
![](/images/2016/11/Screenshot-2016-11-06-19.12.11.png)

And on top of all that, it's login is based on SSH, with optional 2FA with tools like Google Authenticator, so it's fairly plug-in-and-play for most systems.

You can even create new accounts for users from the Cockpit interface:

![](/images/2016/11/Screenshot-2016-11-06-19.12.25.png)

#### Upcoming

The development and feature planning for Cockpit is open (
[they have a Trello board with a full roadmap](https://trello.com/b/mtBhMA1l/cockpit), and there's some interesting looking things coming up, such as built in container scanning with atomic:

![](/images/2016/11/image-scanning.png)
[Taken from the preview for the next Cockpit release](http://cockpit-project.org/blog/cockpit-122.html)

Or debugging issues with Selinux:

![](/images/2016/11/Screenshot-2016-11-06-20.10.42.png)
[SELinux Troublshooting feature page](https://github.com/cockpit-project/cockpit/wiki/Feature:-SELinux-Troubleshooting)

But one of the most exciting elements is going to be it's integrations with containers. I can already see

### Try it yourself

So I've made a Cockpit module for Puppet, it's fairly simple:

```
$ puppet module install petems-cockpit
$ puppet apply -e 'include cockpit'
Info: Loading facts
Info: Loading facts
Notice: Compiled catalog for centos-7-x64.local in environment production in 1.43 seconds
Info: Applying configuration version '1478461853'
Notice: /Stage[main]/Cockpit::Repo::Centos/Yumrepo[extras]/enabled: defined 'enabled' as '1'
Notice: /Stage[main]/Cockpit::Install/Package[cockpit]/ensure: created
Notice: /Stage[main]/Cockpit::Config/Ini_setting[Cockpit LoginTitle]/ensure: created
Notice: /Stage[main]/Cockpit::Config/Ini_setting[Cockpit MaxStartups]/ensure: created
Notice: /Stage[main]/Cockpit::Config/Ini_setting[Cockpit AllowUnencrypted]/ensure: created
Info: Class[Cockpit::Config]: Scheduling refresh of Class[Cockpit::Service]
Info: Class[Cockpit::Service]: Scheduling refresh of Service[cockpit]
Notice: /Stage[main]/Cockpit::Service/Service[cockpit]/ensure: ensure changed 'stopped' to 'running'
Info: /Stage[main]/Cockpit::Service/Service[cockpit]: Unscheduling refresh on Service[cockpit]
Info: Creating state file /opt/puppetlabs/puppet/cache/state/state.yaml
Notice: Applied catalog in 248.63 seconds
```

Cockpit runs by default on 9090, but you can configure it with a parameter in the Cockpit service file:

```
class { '::cockpit':
  port => '443',
}
```

As new configuration settings come up, I'll add them to the module, but for now I'm going for the most basic use-case: package repo, package, config file and service.

I'm looking forward to new Cockpit releases, and the roadmap looks super interesting.
