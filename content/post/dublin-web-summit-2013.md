+++
author = "Peter Souter"
date = 2013-11-14T12:00:00Z
description = ""
draft = false
coverImage = "/images/2016/10/10226806236_2915beec76_z.jpg"
slug = "dublin-web-summit-2013"
title = "Dublin Web Summit 2013"

+++

A month ago I had the pleasure of going to the Dublin Web Summit. Unfortunately, I managed to get Conference Flu that took me out of commision for a few days, followed by a busy few weeks of work (and other conferences!) so I didn't get a chance to talk about my time there. There was a crazy amount of stuff to see and do, so I'll see if I can get down as much as I remember over a month later!

Jumped on a flight after work on the Tuesday and arrived fairly late to Dublin airport. They actually had a stand for the summit in the arrivals area to the event, and the taxi driver who took me to the hotel said he'd been taking fare's all day from people. Really showed the size of the event!

Met up with fellow Kainos-er [James Hughes](https://twitter.com/kouphax), who showed me some of the sights of Dublin and took me to a restaurant where I ate my bodyweight in buffalo wings. Some rough plans were made and we agreed on an early wake up the next day to go in.

# Day 1
After a quick walk down from our hotel, we pick up our badges and go in, and I was promptly blown away by the massive showfloor...

![](/images/2016/10/10580850365_4c1eff1a80_z.jpg)
https://flic.kr/p/h7ZCbz

The noise, the people, everyone trying to catch your eye to tell you about their startup, people dressed up, videos playing everywhere, people trying to give you free stuff... all a bit overwhelming for 9am!

And there was a lot to see and do: 5 stages, over 1000 startups and various booths and open-sessions. So we started off wandering around the floor, talking to the different vendors and grabbing the first of many free coffees...

## Startup Floor

I quickly learnt that this is the main focus of the event: an insanely busy weekend for startups from around europe to demo their products and services, entice investors and potential customers and network. I even spotted the [LE SmartLight](http://www.kickstarter.com/projects/l8smartlight/l8-smartlight-the-soundless-speaker), which a friend of mine had backed on Kickstarter.

The startups on show were pretty awesome, a lot of variety and everyone keen to show off their tech.

![](/images/2016/10/10707930065_d214c01075.jpg)
https://flic.kr/p/hjdWxT

I talked to a few people and signed up for a few things, but it made me glad I was there as an attendee rather than an exhibitor, it looked pretty stressful!

Some I can remember off the top of my head:

### Fitbook

<iframe width="560" height="315" src="//www.youtube-nocookie.com/embed/LnDQUnEXmho?rel=0" frameborder="0" allowfullscreen></iframe>
An app to encourage healthy habits. I mentioned [Fitocracy](http://fitocracy.com) to him and he said he'd check it out.

### Detectify

<iframe width="560" height="315" src="//www.youtube-nocookie.com/embed/1Kj9bnbmGnA?rel=0" frameborder="0" allowfullscreen></iframe>
Which is like a mini pen-test for your web-app.

### Enthuse.me

<iframe src="//player.vimeo.com/video/78255184" width="500" height="281" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>
A personal brand management tool/portfolio sort of thing.

## Vendors and Sponsers

Wandered the floor a bit and talked to the various vendors:

* EngineYard - Talked about challenges in the startup world, possible plans for Scala support in the future

* Basho - Talked about Riak, which I've heard a lot of buzz about. Whilst it's another NoSQL database, it's key-value rather than document based. They had a demo of it on display; a pretty cool visual of weather patterns, handling gigabytes of meteorological data in real-time.

* Atlassian - Talked about about HipChat. I've mainly used Campfire in the past, but Hipchat seems pretty cool. And it's free for teams of 5 or less, which is always good.

## Away in the clouds...

The cloud stage was a little disappointing, it was a lot of "Rar-rar, cloud solves all your problems" without a huge amount of discussion of:

* a) How? - How to transition into cloud services.
* b) Why? - Why is this better than a standard sever-farm?
* c) What? - "Cloud makes it better!" Erm, which provider, what services?

It was a lot of the sizzle and not much steak...

The exceptions to this was probably Johann Butting, who seemed pretty genuine about the challenges Dropbox faced and talked about their new Dublin Office. It's crazy to think that Dropbox was only funded from Y Combinator in 2007 (to realise how wrong Hacker News comments can be, [check out peoples response to the company back in 2007](https://news.ycombinator.com/item?id=8863))

So after that, I mainly stuck to the developer stage, with occasional breaks to talk to the guys on the startup floor.

## Developer Stage

All the talks from the Development stage were [streamed and archived](http://new.livestream.com/websummit/DeveloperStage2013/videos/33616803) and I'd recomend checking them out.

### Microservice Architecture

One of the best talks was [Fred George's](https://twitter.com/fgeorge52) talk on [MicroService Architecture](http://www.slideshare.net/fredgeorge/micro-service-architecure). I'd heard use of the term micro-services before, but mainly in the context of lightweight frameworks like Sinatra and Finagle. I'd never heard the implementation of them in a full system. The talk dealt with real-life application of a micro-service architecture on several large banking projects.

![1 Million Dollars...](/images/2016/10/microservice.jpg)

Microservices as a concept really struck a chord with me. It felt similar to the unix philosophy: well-defined, small and de-coupled components building into a complex machine. You don't have to 'touch' too much of the application to make a change and it lets you iterate a lot faster. It seems like a really neat approach to manage the complexity of an application.

Fred also mentioned this increases development speed, as it normally removes the need to write unit tests for each service. As he put it: *"If you need to write unit-tests for 5 or 6 lines of code, you've got bigger issues than tests"*

But, what was really interesting was how microservices can be used on top of legacy systems, basically giving an arbitration level that allows you to build features quickly on top of a huge monolith without having to touch delicate legacy code that no-one really knows how to change.

In fact, James did an excellent [blog post](http://yobriefca.se/blog/2013/04/29/micro-service-architecture/) about it that explains it a lot better than I can!

### Falling in Love with Technical Debt

[Richard Rodgers](https://twitter.com/rjrodger) talk on falling in love with technical debt was also extremely good. Whilst it had a bit of a bait of a troll-bait title, it was more of the reality of how to deal with technical debt.

![Microservice Architecture](/images/2016/10/falling_in.jpg)

It's always a dream of devs dealing with a large and creaking codebase to say: "I wish I could throw all of this away and start again!". It's one of those things that sounds great, but if you do you quickly realise it's a bit of a Rose Tinted view to have. Technical debt normally spins out of all the edge cases you needed to fix to get your application working with real users, and you'll probably end up just shifting that debt back in as you write them all again.

Worse, you quickly realise you're pretty close to where you started, the old code wasn't that bad, and you've just wasted (sometimes years) re-writing code you already had. ([It's one of the things that killed Netscape](http://www.joelonsoftware.com/articles/fog0000000069.html))

Anyway, the focus of the talk was that you couldn't avoid technical debt, so better to mitigate debt, rather than the impossible task of avoiding it. And one of the suggested methods? Microservices.

![Technical debt microservices](/images/2016/10/technical_debt_micro.jpg)

James also showed how his Node.js microservice framework [he developed](http://senecajs.org/) worked, which looks pretty cool and reminded me that Node was one of those things I have on my to-do list of things to learn...

There were some other great talks that I missed but heard good things about, like **Chad Fowlers** talk on Disposable Components (services are like cells in a body: constantly dying and being replaced, yet the whole system continues to run) and Andreea Wade's talk **Developing Communities - a Coder, a Painter and a Builder Walk into a Bar about** increasing diversity on tech teams, in terms of both people and ideas.

After that, I drifted toward the main stage for some of the keynotes and interviews. The biggest was probably Tony Hawk, the grandfather of mainstream skating, interviewed by Kevin Rose.

![Tony Hawk](/images/2016/10/tony_hawk.jpg)

Sadly, no ["LATE 360 SHOVE-IT TO BONELESS"](http://www.homestarrunner.com/tgs5.html) but, Tony Hawk talked about his life, his [charity work and foundation](http://tonyhawkfoundation.org/), and how the original concept of the PS1 Tony Hawk game had digitally modeled Bruce Willis skating around a post-apocalyptic wasteland...so a bit different from the final product really!

The day drew to an end, and so on to the night summit. This consisted of a whole street of bars and pubs that had been taken over in the name of the summit, providing free drinks all night to attendees.

![Night Summit Inside](/images/2016/10/night_summit.jpg)

Needless to say, it was insanely busy...

![Night Summit Outside](/images/2016/10/night_summit_inside.jpg)

## Day 2

So, after a little worse-for-wear after the drinks the night before, I managed to drag myself out of bed for a 9:30 talk.

## Practicing Failure: Gamedays on the Obama Campaign

![](/images/2016/10/gamedays.png)

Dylan Richard explained how he got his systems (and in the process, his team!) battle-hardened, and able to handle the technical challenges of Barack Obama's 2012 re-election. As he put it *“Technology does not win an election, but you can lose because of it.”*.

Regardless of your political leanings, Obama's tech-team knocked it out of the park compared to Mitt Romney's [failure to launch.](http://arstechnica.com/information-technology/2012/11/inside-team-romneys-whale-of-an-it-meltdown/).

Dylan came up with two tenants to avoiding failure on a project:

* Don’t let it fail
* When it does, [deal with it](/images/2013/Nov/CupiM.gif)

The first one sounds obvious, but it's more about avoiding failure in the first place. He said the biggest issue was to get the shareholders to explain what mattered the most. He basically summed it up to the stakeholders as: *"No features are cool enough to not have a working app"*

These are the basic tennants of the [lean metholodolgy](http://theleanstartup.com/principles): get an minimum viable product out, and build on features later as demand occurs. It's pretty refreshing to see this kind of mentality on a large Government project, especially one the size of a re-election campaign!

So, the first one dealt with, the next issue is to deal with failure as it happens. And what's the best way to do that: Break it and add resilience before the fact, rather than having to pick up the pieces when it falls apart on the big day.

To do this, they had a Game Day: the campaign team built a staging environment that mirrored production as much as possible.

Then they tried to break it. Hard.

They were basically running a personalised [chaos-monkey](http://techblog.netflix.com/2012/07/chaos-monkey-released-into-wild.html). They simulated the potential traffic of the main day of an election, and fixed the failures as they occurred. By doing this, they managed to see what sort of errors would occur, where the pain points were, and how to make them more resilient for the real thing. By this combination of ensuring that the key features of the project are defined, and then made resilient enough to withstand a large spike in users, you end up with a system that should be fairly bulletproof when it comes show-time.

There was also the idea of a run-book of what issues happened for other people to pick-up and learn from. I'm not such a huge fan of run-books though. In this case it makes sense, since the game-day was only a few weeks before launch. But in the real world a run-book becomes out-of-date fairly quickly.

But overall, it was a great talk and game-days seem like a really awesome tool to add resilience to a project and , At the end of the day, the only real way of testing your product is going to work in the real world is to simulate the real world as much as possible, not just get pen-testers to check it every once in a while. This is the technologic version of a literal smoke-test: force smoke through a pipe and see where it leaks. Fix the leaks, and try again.

##Roaming Free - Adapting to the cloud at the BBC

Immediately after was Gary O’Connor from the BBC.

So in 2012 and the Olympics coming, the BBC had a mandate to move a number of services into the cloud. They started off with several pilot projects as a proof of concept and after they got all the major stakeholders on board, adopt it as a standard practise going forward.

![](/images/2016/10/bbc.png)

It was kind of interesting that apparently there wasn't much of a scala footprint at the BBC team, but one person thought he could improve the approach taken on CBeebies, went away, spiked it in Play and proved that it was a good approach and got it signed off. It's always nice when someone can trial and approach, prove it's business value and get it implemented.

He then talked a little about why they chose CouchDB over MongoDB and the general architectural approaches the team took in projects.

Now, stop me if you've heard this before: the BBC dev team's main approach was to decoupling events and let smaller components handle single purposes. Smaller, might even be called micro...

So by this point, 2 days of free coffee, drinks the night before and rich food, combined with conference flu (Mental note: Use anti-bacterial hand gel next time, way too many handshakes going on...) were taxing my ability to take notes, but a few other great talks I saw were **Building a World-Class Dev Ops Team in Dublin** by Rich Archibold ("DevOps is Sysdmin's agile") and **Why Semantic Web, Open and Linked Data Will Take Over The World** by John O’Donovan ("Content is worthless without context: data is useless without human analysis").

After that, I mainly did a bit of networking with some of the people I recognised from the night before and wrote up a draft of my notes. Little did I know it would take me almost a month to get this all written up...

## Take-aways

* Microservices definitely seem like the Next Big Thing&trade;

* Whilst I think a lot of the Web Summit was focused on things way over my head in terms of startups, entrepreneurs and big-business, I did learn a lot from the developer talks, and it was really interesting to talk to the people from the various startups.

* Guinness _does_ taste better from Dublin.

* It's hard writing a month after the fact!

But I hope you enjoyed my write-up, and look forward to getting more done in the future.

