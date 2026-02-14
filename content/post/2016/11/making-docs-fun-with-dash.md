+++
author = "Peter Souter"
categories = ["Tech"]
date = 2016-11-19T12:47:00Z
description = ""
draft = false
coverImage = "/images/2016/11/Screenshot-2016-11-26-14.07.25-1.png"
slug = "making-docs-fun-with-dash"
tags = ["vDM30in30", "Tech"]
title = "Making Docs fun with Dash"

+++

#### Day 19 in the #vDM30in30

I can't remember who recommended it to me, but I'm loving Dash for documentation on a Mac.

## What is it?

From the horses mouth:

> Dash is an API Documentation Browser and Code Snippet Manager. Dash stores snippets of code and instantly searches offline documentation sets for 150+ APIs (for a full list, see below). You can even generate your own docsets or request docsets to be included.

So I load up my Dash with docs for most of the things I'll be using in my day to day work:

* Puppet
* Facter
* Ruby
* Git

It also has "Cheat Sheets" which are basic summaries of what you need to know for tools out there, which is useful if you quickly need to lookup the correct `openssl` command, or how to do that find and replace in Vim that you want.

I have:

* NGINX
* Apache
* OpenSSL
* VIM
* HTTP Codes
* RSpec Expectations

There's also a bunch of User Contributed docs from the community:

![](/images/2016/11/Screenshot-2016-11-26-14.07.25.png)

I have:

* Serverspec
* HAProxy


Using Dash for documentation is great for a bunch of reasons:

## Documentation search isn't always great

Depending on the stack used for hosting the docs, finding what you want isn't always great.

The indexing for Dash seems top-notch, you can search for the documentation in seconds.

## Able to search offline

There have been times when I've not been able to get online. Maybe I don't have the public wifi key, or I'm on a plane

## Integrations with other apps

The most useful thing for me is that Dash has a ton of integrations with other applications.

![](/images/2016/11/Screenshot-2016-11-26-14.00.22.png)

The ones I use the most in my work are...

### Sublime Text integration

You can press `Ctrl+H` in a file with Sublime, and it will do a context search using the type of code in the file plus a search for that entry.

For example, if I wanted to know about a package in Puppet:
![](/images/2016/11/dash_sublime-1.gif)

https://github.com/farcaller/DashDoc

### Alfred Workflow

If you quickly want to search, there's an official Alfred workflow.

So searching is as quick as `CMD+Space+"dash..."`

![](/images/2016/11/dash_alfred.gif)

https://github.com/Kapeli/Dash-Alfred-Workflow

### Terminal Integration

You can search from a terminal using the uri form `open dash://`

![](/images/2016/11/dash_terminal.gif)

The format is: dash://{query}.

You can also include an optional keyword: dash://{keyword}:{query}.

Example: `open dash://ruby:puts`

![](/images/2016/11/dash_terminal_2-1.gif)

https://kapeli.com/dash_guide#dashURLScheme

## Not got a Mac?

So, **Dash is OSX only**, but the developer has happily said [he'll make the core doc artifacts available for other platforms:](https://blog.kapeli.com/dash-for-ios-android-windows-or-linux)

> I get asked a lot to bring Dash to other platforms. That won’t happen, because:

> * I’ve got a lot to add to Dash on macOS and I can’t focus on any other platform
> * I’m a complete novice when it comes to developing for any other platform, so I wouldn’t do a great job
>
I am actively looking for developers of other platforms (iOS, Android, Windows or Linux) that would like to work on a Dash-like app, as their own project and for their own profit.

Which is pretty cool, as you can get the same workflows on non-OSX platforms.

There's Zeal, which works on Linux, BSDs and Windows.

https://zealdocs.org/

There's also Velocity, which is Windows only:

http://velocity.silverlakesoftware.com/

And, you can similar for Tablets and Phones:

* iOS - https://kapeli.com/dash_ios
* Android - http://lovelydocs.io/
