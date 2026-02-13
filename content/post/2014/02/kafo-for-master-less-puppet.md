+++
author = "Peter Souter"
categories = ["Puppet", "Tech"]
date = 2014-02-08T23:08:33Z
description = ""
draft = false
coverImage = "/images/2016/10/3241979402_cf45705f7d_o.png"
slug = "kafo-for-master-less-puppet"
tags = ["Puppet", "Tech"]
title = "Irssi, Mosh and Kafo: An awesome IRC combo"

+++

Last week I went to [FOSDEM](https://fosdem.org/2014/), followed by [CfgMgmtCamp](http://cfgmgmtcamp.eu/). It was an amazing experience, I met a lot of cool people and learnt a lot... but I'll talk more about those later in a dedicated blog post. For now, I want to talk about IRC.

One of the things I came away from 4 days of open-source and configuration management talks was: "The decision was made on IRC" or "A broad consensus was made on Freenode" and the like.

"I need to get back into IRC", I thought.

But I didn't want to just download mIRC. I wanted to do it the cool ops way! So I asked [Rob](https://twitter.com/lazzurs), who was the person who recommended FOSDEM to me in the first place ([and spoke at it in 2009](https://www.youtube.com/watch?v=OvnruVIXQEY)) and showed me his preferred pattern to get IRC working:

* Set up a server as a bouncebox, something fairly disposable: this means your personal IP isn't on display when you connect/disconnect from channels
* Install [Irssi](http://www.irssi.org/), [screen](http://www.gnu.org/software/screen/) and [mosh](http://mosh.mit.edu/)
* Start a screen session and start Irrsi in it: you'll be able to jump back to the screen session if you get disconnected
* Use mosh to connect to the server

I can't sing mosh's praises highly enough, it's awesome. It queues your keystrokes, allowing you to continue typing, even if your connection is flaky. It even has a little underscore underneath any input, showing where your input is in relation to the remote system. And when you disconnect, it has a little notification saying how long the disconnection has been, and will re-connect seamlessly as soon as your connection is restored. So far (my record so far being 4 days) it has a 100% reconnection record. The long and the short of it is: use it, it's awesome.

So, with this idea in mind I span up a lightweight server on DigitalOcean, and started configuring stuff by hand. Then I did a double take and realised I was provisioning this server by hand... not very devops-y of me...

Since the server would be fairly disposable, I didn't want to have to setup a puppet master, and configure all the required network settings. So I decided to setup a masterless puppet config for the box. Normally, I'd just clone over a repo with some [basic puppet manifests in it](https://github.com/petems/headless-puppe), and run a `puppet apply` through the terminal, perhaps adding a cron to do this automatically every hour or so, simulating an agent trigger.

Then I remembered a talk from Configmanagmentcamp by Marek Hulán about [Kafo](https://github.com/theforeman/kafo). Kafo was a tool the guys from Foreman put together to install Foreman. Since Foreman starts puppet, there's a bit of a chicken and egg situation around setting up a foreman server with puppet, but also requiring puppet to set it up. So they made Kafo to make this process easier.

As the readme says, Kafo is basically some nice wrappers around:

```
echo "include some_modules" | puppet apply
```

So I gave it a try to create a basic setup for my bounce box.

You install the Kafo gem, then you run an initialisation task that creates you a directory with everything you need setup in it.

From there, you can add the modules you require and setup your options in the answers.yaml file, which basically automatically fills in parameters in your manifest files. [Here's the repo I was using on my machine](https://github.com/petems/bouncebox-installer).

Mine is extremely simple, with no config options to speak of really. Check out the [foreman-installer](https://github.com/theforeman/foreman-installer/) for an example of a more complicated example.

Here's a look at it in action:

![Kafo installer in action](/images/2016/10/resized_terminal.gif)

So, that works pretty well, and I have a repo that I can give to someone else to run on their machine. What's cool is they wouldn't even need to know anything about puppet to setup the server, they can just run the shell script and everything's done. Pretty, pretty cool.
