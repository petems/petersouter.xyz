+++
author = "Peter Souter"
categories = ["Tech"]
date = 2016-11-14T16:57:00Z
description = ""
draft = false
coverImage = "/images/2016/11/45-0.png"
slug = "the-story-of-errata-for-centos"
tags = ["vDM30in30", "Tech", "SysAdmin"]
title = "The Story of Errata for CentOS"

+++

#### Day 14 in the #vDM30in30

**Image taken from [Implementing Spacewalk into Company Infrastructure](http://theseus.fi/bitstream/handle/10024/62222/Implementing_Spacewalk_into_Company_Infrastructure_Joonas_Lehtimaki.pdf)**

I've done a bunch of work with customers around patch management and packaging errata for CentOS, so I thought I'd talk about it a bit.

## What is errata?

In the context of packaging, errata is basically listings from the package manager upstreams with updates for when CVE's and vulnerabilities are found.

So for official RHEL systems, this is available by default from the upstream, and the whole managed with Red Hat's Satellite tool, which gets the information directly from RedHat's infrastructure with your official paid login.

This information is kept in the `UPDATEINFO.XML` file for each repository upstream.

You can then use the `yum-plugin-security` plugin, to list all vulnerable packages:

```
$ yum list-sec cves:
CVE-2007-5964 security autofs - 1:5.0.1-0.rc2.55.el5.1.i386
CVE-2007-5503 security cairo - 1.2.4-3.el5_1.i386
CVE-2007-5393 security cups - 1:1.2.4-11.14.el5_1.3.i386
CVE-2007-5392 security cups - 1:1.2.4-11.14.el5_1.3.i386
CVE-2007-4352 security cups - 1:1.2.4-11.14.el5_1.3.i386
CVE-2007-5393 security cups-libs - 1:1.2.4-11.14.el5_1.3.i386
CVE-2007-5392 security cups-libs - 1:1.2.4-11.14.el5_1.3.i386
CVE-2007-4352 security cups-libs - 1:1.2.4-11.14.el5_1.3.i386
```

and even update any package that has listed errata with `yum update --security`

This is documented in the [RedHat knowledge base article (paywall)](https://access.redhat.com/solutions/10021) or the [Fedora docs (no paywall)](https://docs.fedoraproject.org/en-US/Fedora/17/html/Security_Guide/sect-Security_Guide-CVE-yum_plugin-using_yum_plugin_security.html).

## The problem with CentOS

However, CentOS does not have official errata: the CentOS upstream repos do not have an `UPDATEINFO.XML`.

There have been a few mailing list posts about it (such as [here](https://lists.centos.org/pipermail/centos-devel/2015-January/012600.html) and [here](https://lists.centos.org/pipermail/centos/2015-January/148839.html)), but the long story short is there seems to be a difference in opinion whether this is a technical or legal problem from the mailing lists, but regardless: it's not there, and probably won't ever be for the foreseeable future.

So, how do we do this then?

Well, there are workarounds

## Solutions for Errata on CentOS

There appear to be four solutions to get errata on CentOS:

* [Spacewalk (with CEFS)](https://cefs.steve-meier.de/)
* [generate_updateinfo script](http://blog.vmfarms.com/2013/12/inject-little-security-in-to-your.html)
* [centos-package-cron](https://github.com/wied03/centos-package-cron)
* [vulns](https://github.com/future-architect/vuls)

### Spacewalk

The most complete solution is to setup Spacewalk. Spacewalk is actually the open-source core that powers RedHat's satellite solution, so it makes sense that it'd work for CentOS.

It's probably the heaviest handed method, as you have to setup an entire dedicated application that will require maintenance.

But it also gives you the other features that Spacewalk has like showing what servers have versions of packages, what errata is currently installed in your estate and so on.

How does Spacewalk help with Errata? Well, by default it doesn't: it's just for managing `yumrepos` from a central location.

However, with a bit of tooling, it has a process for errata:

1. Setup Spacewalk
2. Mirror CentOS repos in Spacewalk that sync from the upstream
3. Get the information on vulnerabilities from somewhere
4. Inject that information into the Spacewalk repos, so that they have a `UPDATEINFO.XML` file
5. Point your CentOS machines from the upstream repos to the Spacewalk repos
6. CentOS machines will now be pointing to SpaceWalk yumrepos, that have security information

The difficult bit is Step 4.

How do we get that information?

The main approach seems to be:

1. Go through CentOS mail archives, digests and mailing list websites for CentOS errata
2. Push them to the Spacewalk server

The main issue is that the main way to do that is download the the gzipped archive from the mailing list, which is only available at the end of every month from the CentOS lists.

You may have to wait a little while to get that information...

Regardless, the main project to do this is Steve Meier's CEFS Project [CentOS Errata for Spacewalk](http://cefs.steve-meier.de/)

Steve provides a parsed `errata.xml` file generated from the centos-announce mailing lists and the scripts you need to import them in to your spacewalk server. His script will download the information directly from CEFS and then inject it into Spacewalk

There's a similar script by David Nutter that does the scraping itself (rather than get it from CEFS) called `centos-errata.py`. available [here](http://www.bioss.ac.uk/people/davidn/spacewalk-stuff/0.7/).

Regardless of how you do it, there's a number of blogs showing how they get Errata into CentOS using the scripts:

* http://www.stankowic-development.net/?p=5653&lang=en
* http://www.devops-blog.net/spacewalk/configuring-errata-for-ubuntu-with-spacewalk
* http://missingsmth.com/centos-7-spacewalk-features/
* http://wiki.nikhil.io/#syncing-errata
* [Implementing Spacewalk into Company Infrastructure](http://theseus.fi/bitstream/handle/10024/62222/Implementing_Spacewalk_into_Company_Infrastructure_Joonas_Lehtimaki.pdf)

After that, CentOS machines pointing to the Spacewalk server should have available errata.

### Generate updateinfo.xml with security information

This uses the CEFS information, but runs it against a local copy rather than Spacewalk. Same concept, less moving parts.

This is best documented in the [`generate_updateinfo`](https://github.com/vmfarms/generate_updateinfo) script Github project and the [original blogpost by VMFarms](http://blog.vmfarms.com/2013/12/inject-little-security-in-to-your.html)

You're doing something like this:

```bash
wget -q -N -P/security http://cefs.steve-meier.de/errata.latest.xml

generate_updateinfo.py /security/errata.latest.xml

/usr/bin/modifyrepo /security/updateinfo-6/updateinfo.xml /repositories/CentOS-6-Updates/repodata
```

### centos-package-cron

These is the simplest of solutions, and doesn't actually involve `UPDATEINFO.XML` at all.

Instead of messing with your actual `yumrepos` or setting up Spacewalk, it simply grabs the security announcements, compares with what you have installed locally, then sends the message to STDOUT or emails you.

It's available [here](https://github.com/wied03/centos-package-cron).

### vulns

Vulns is a fairly new approach, which is a go application that scans upstreams and gets vulnerability information. It then can send email or Slack alerts when it finds issues.

For CentOS, it's basically a wrapper around the `yum-changelog-plugin`. Essentially it runs `yum update --changelog`, grabs the output from that and compares it against it's vulnerability database.

I played around with it, but it's a fairly complex app and it's fairly new (open-sourced in 2016) so I'm not so sure about it yet... but from my basic testing it did what it said on the tin.

It's available [here](https://github.com/future-architect/vuls)
