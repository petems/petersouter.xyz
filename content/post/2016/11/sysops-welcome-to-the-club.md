+++
author = "Peter Souter"
categories = ["vDM30in30", "sysops", "sysadmin", "devops"]
date = 2016-11-06T15:42:00Z
description = ""
draft = false
coverImage = "/images/2016/11/472028910_ec8f1fde23_z.jpg"
slug = "sysops-welcome-to-the-club"
tags = ["vDM30in30", "sysops", "sysadmin", "devops"]
title = "SysOps: Welcome to the Club"

+++

#### Day 6 in the #vDM30in30

Header Source: https://flic.kr/p/HHgKu

#### What is this?

This is a post I wrote a year or so ago for SysAdvent 2015, but some issues came up and it didn't get published.

It's basically about about welcoming new people to the world of SysOps and Sysadmin-ing, avoiding imposter syndrome and general tips about things to read and do to get used to the world of sysadmin-ing.

# SysOps: Welcome to the Club!

Let's talk about the old days.

In the old days, system administration was in a dark place. Shell scripts roamed the land, the IT department was seen as a facility which only seemed to consume money, and the common image of a sysadmin was the
[BOFH](https://en.wikipedia.org/wiki/Bastard_Operator_From_Hell) who hated users and wanted to be left to the blinding LED's of the barren wasteland of the cold server room.

Have things changed? Hopefully the cultural shift to DevOps has fixed things up, new and shiny tools have helped automate old boring tasks away and the operations team is seen as part of the team, just as important as engineering, management, or any other department.

With this shift, there are a bunch of people who are working more closely with sysadmins or maybe even making a more permanent shift to system operations. And there are probably a bunch of existing sysadmins who are now working alongside or even mentoring these new sysadmins.

Whatever your origins, wherever you're from, whether you want to dip your toe or jump in, I welcome you to the world of System Administration.

I made this switch a few years ago, so want to talk about a bunch of things I've learned and seen done to try and make learning operations easier.

## What should I know?

Like in many specialisations, in operations there are a ton of idiosyncrasies with how to do things. Ask 5 sysadmins how to remove a file line from a config file and you'll probably end up with 5 different ways of doing it.

As a newbie, you probably have a ton of questions on what is the best way to do something. Since we're 50+ years into computer science and we still argue about tabs vs spaces, don't worry too much about fighting over the best technique, generally there are advantages and disadvantages to every approach and tool.

With that said, there are something that are pretty universally good to know:

* `sed, grep, awk` - The trifecta. As archimedes once said "Give me a long enough awk command and a file system on which to run it and I shall move the world." These are common *nix low level commands that exist across most distributions of Operating Systems.
* Networking basics - Depending on your background, your network knowledge might be a little bit lacking with what you'd need to know as a sysadmin. There are a few good sites on where to brush up on the basics (see Books). After that, you probably want to talk about the networking equivalent swiss army knife. These aren't nearly so ubiquitous as `sed, grep and awk` depending on the operating system you're on, but `netstat`, `nmap`, `telnet`, `nslookup` and `traceroute` are a good start.
* What's going on - It's always good to know what is currently happening on a system. What programs are running? How much memory is being used? How much space do you have left? Again, depending on your system there’s a number of ways to find out this information, but du, top and ps commands can help with this.
* Getting around. `cd`, `ll`, `cp`, `mkdir`, `rm`
* Artifacts and packages - How do I install things?
* Configuration management - Seems like it’s going to be a lot of work to run these commands all the time? Lots of people agreed, and there are tools for that too. These are tools that let you write instructions and figure out what commands need to run for you. Depending on your environment, you might be using one of these tools (or even multiple!) or you might not be, but they’re really good to learn - Puppet, Chef, Salt, Ansible.
(Full disclosure I work at Puppet - the company behind one of those tools, guess which one!)

# Learning

A lot to learn already huh? Probably wondering if there's some sort of classes or guides for this stuff.

Sysadmin-ing is often seen as more of a vocation or a trade. For someone like me, who was used to being able to have a a "How to program in X" book on my lap and do a bit of reading, it was hard to know where to start.

## Books

Whilst not as many, there are some existing books that might help out. These are the ones I’ve seen recommended the most:

* The Practice of System and Network Administration, Second Edition
* UNIX and Linux System Administration Handbook (4th Edition)
* TCP/IP Illustrated, Volume 1: The Protocols
* Devops Troubleshooting - Linux Server Best Practises
* Windows Server 2008/2012 R2 Unleashed (Shout out to all the Windows sysadmins out there, you’re often forgotten in all this new devops stuff!)

## Training

One of the best ways of learning is being taught directly. Don't be afraid to ask your organisation about training, either internal or external. If you work for a larger company, there's normally a use-it-or-lose-it training budget, and generally it's easy to ask, especially if you can justify how it will benefit your day-to-day work. Sometimes your company might already have existing contacts with vendors, so you might already have voucher or discount systems with companies you’re already working with. Ask around!

For smaller companies or those without a training budget, see if you can organise informal training sessions or brown bags.

## Shoulders of giants

Outside of training, the best way of learning is watching someone doing it live.

As someone used to an agile/XP background, one of my favourite things to do was to pair up when someone was working on an operations feature. I remember at standup there was an issue with performance on a production server that needed investigating. Sitting next to my paired sysadmin, watching how they effortlessly navigated the filesystem, watching what commands they used to diagnose the issue, how they looked through both official documentation, pinged others on chat or read serverfault answer pages, made a rough implementation of a solution, made a pull-request to change some of the Puppet code to fix the problem and got feedback. It was a pretty awesome process and I learnt a lot from that.

If it's something like a super-high priority must-be-fixed-now problem, see if you can ask someone to do a post-mortem of what they did and ask questions on what tools and approaches they took. Maybe even on a more informal chat over coffee.

[Just remember to make sure that any post-mortem events are blameless!](https://codeascraft.com/2012/05/22/blameless-postmortems/)

## Experimenting in the lab

Ok, so you've done some courses, you're getting familiar with a lot of sysadmin day-to-day tasks, you’ve watched someone and think you’re pretty fly, now you want to go out and try. As we said, the best way of learning is doing, but you probably don't want to be left to your own devices on live production servers, even with good backups!

### Sandboxes

See if you can setup a lab-like sandbox environment in a cloud provider or virtualisation tool.

If you want to play in the sandbox, you're going to need some toys. The ones that are probably going to be the best are Vagrant and Docker:

#### Vagrant

Vagrant is a tool to run popular virtualization programs, such as VMWare Fusion (commercial) or Virtualbox (free). It allows you to find existing Vagrant environments that people have configured with a `Vagrantfile`, allowing you to make a similar environment locally. From there you can mess around, try some of your new knowledge in a disposable environment, then destroy it and retry it if something goes wrong. It’s extremely popular as a tool to make repeatable testing environments, it’s also free!

#### Docker

Docker is the seen as the next step after virtualisation. It’s a little more complex to understand and a lot of the practises and tooling is still settling, but once you get the hang of it, you can create containers of environments in seconds, rather than the minutes that virtualization takes.

## Pay it forward

Don’t forget to pay it forward! If you have a feedback process in your company, use it to say how much people have helped you. Try writing about what you’ve learned or update existing documentation for the next person. If you feel confident enough, you could present a brown-bag, or even try to present at an external meetup or conference.

If you’ve made the jump from another department, there are a number of ways you can  bring over some of the knowledge you have from your background. Some concepts are fairly new to the world of system administration, and with the rise of infrastructure as code and configuration as code, you can often translate programming practises straight into relevant operations practises.

## Version control for Sysadmins

Give nice explanatory version control messages for the next person to look at. A good commit message explains exactly why the change occurred, any gotchas or tricks, and links to any relevant further reading. If you’re fixing an issue that has a public bug tracker, throw in a link to the bug ticket. Always make sure that you’re making things easy for the next person who’s investigating. Especially because that next person could be you!


## BDD for Sysadmins

Testing and concepts such as BDD are also becoming more relevant to operations tools these days, so if you have previous knowledge of this you might be able to use it. Tools such as serverspec allow you to write unit-tests for full systems, so you can check that changes you’ve made haven’t introduced any regressions. And depending on your configuration management tool of choice, there are often tools to abstract unit testing for your configuration management tool of choice, with libraries such as rspec-puppet and chefspec.

# Conclusion

Hopefully you're on the right track to becoming a great sysadmin, helping your company keep its uptime up, its customers and/or users happy and learning a lot as you do.

Remember to pay it forward and remember that empathy shown to you when you get pinged with a request from one of the other newbies.

“Now what's the argument for reverse regex in grep? Was it -i for inverse, or -v…”

# Further Reading and viewing

## Books
* [The Phoenix Project](https://www.amazon.co.uk/Phoenix-Project-DevOps-Helping-Business-ebook/dp/B00AZRBLHO)
* [Effective DevOps](https://www.amazon.co.uk/Effective-DevOps-Building-Collaboration-Affinity/dp/1491926309)
* [Time Management for System Administrators](http://shop.oreilly.com/product/9780596007836.do)
* For a big ol' list: [unixorn/sysadmin-reading-list](https://github.com/unixorn/sysadmin-reading-list)

## Blogs
* https://codeascraft.com/
* http://itrevolution.com/devops-blog/
* https://theagileadmin.com/

## Mailing Lists
* http://www.devopsweekly.com/
* https://blog.serverdensity.com/devops-newsletter/
* https://www.cronweekly.com/
