+++
author = "Peter Souter"
categories = ["vDM30in30", "Tech", "Puppet"]
date = 2016-11-22T17:03:00Z
description = "An explanation of the Puppet Resource Abstraction Layer (RAL): what it is, how it works, and how to write your own interfaces to it"
draft = false
image = "/images/2016/11/turtle.png"
slug = "the-puppet-resource-abstraction-layer-ral-explained-part-1"
tags = ["vDM30in30", "Tech", "Puppet"]
title = "The Puppet Resource Abstraction Layer (RAL) Explained: Part 1"

+++

#### Day 22 in the #vDM30in30

> "All problems in computer science can be solved by another level of indirection, except of course for the problem of too many indirections." - Wheeler

More talk about Puppet, explaining a concept that takes a bit of understanding to get: **The Resource Abstraction Layer**.

## Turtles all the way down

Puppet's secret sauce is **abstraction**. 

When it's all boiled down, Puppet is not doing anything magical: the commands that are being run on the system are the same commands that would be run by a human operator. 

Maybe Puppet has figured out a clever way to do it, and takes into account obscure bugs and gotchas for the platform you're on, or is raising an error because what you're trying to do contains a spelling mistake or similar...

But eventually, the action has to actually be performed **using the systems actual applications and tooling.**

That's where the RAL actually comes in. It's the biggest layer of abstraction in Puppet: turning all interactions with the base system into a consistent interface.

The concept of installing a package is (mostly) the same to pretty much every operating system in at least the last two decades: 

`packagesystemtool keywordforinstall packagename`

Generally, the install keyword is `install`, but there are a few exceptions. BSD's `pkg` which uses `pkg add` for example.

However: the actual attributes that can be managed in that package can vary a lot:

* Can you specify the version?
* Can you downgrade that version?
* If the package is already installed, do you need to specify a different command to upgrade it?
* A huge swath of other optional parameters such as proxy information, error logging level and 

If you were coding this in a shell script, you'd have to write a lot of logic to define the characteristics and figure out if the option given is valid and how to add it to the command correctly.

Plus parameter validation.

Plus error handling.

The RAL does away with all of that. It allows the the user to define the characteristics of a resource regardless of the implementation in a consistent way:

```puppet
type { 'title':
  attribute => 'value',
}
```

Every resource follows the same syntax: 

* A resource type (eg. user, package, service, file)
* Curly braces to define the resource block. 
* A title, separated from the body of the resource with a colon
* A body consisting of attributes and value pairs

So our package declaration looks like this:

```puppet
package {'tree':
  ensure => 'present',
}
```

The RAL can handle that behavior on every platform that has been defined, and support different package features where available, all in a well-defined way, hidden from the user by default.

## Explaining RAL as a Metaphor

The best metaphor I've heard for the RAL is it is the Swan gliding along on the lake on the Lake.

When you look at a swan on a body of water, it looks elegant and graceful, gliding along. It barely looks like it's working at all. 

![](/content/images/2016/11/6Zs0mk.gif)
**Ok, these are duck's feet, but same principle!**

What's hidden from the eye is the activity going on beneath the water’s surface. That swan is kicking it's webbed feet, way less gracefully that it looks up top. 

The actual command is the kicking legs under the water. 

The RAL is the graceful interface on top, gliding around elegantly.

## What makes up the RAL?

The RAL splits all resources on the system into two elements:
 
* Types: High-level Models of the valid attributes for a resource
* Providers: Platform-specific implementation of a type

This lets you describe resources in a way that can apply to any system.

Each resource, regardless of what it is has one or more **providers**. Providers are the interface between the underlying OS and the resource types. 

Generally, there will be a default provider for a type, but you can specify a specific provider if required.

For a package, the default provider will be the default package provider for a system: yum for RHEL, apt for Debian, pkg for BSD etc. 

*But* you might want to install a `pip` package, or a `gem`. For this you would specify the provider, so it would install it with a different command:

```
package {'tree':
  ensure   => 'present',
  provider => 'pip', 
}
```

This would mean we're saying to the RAL: "Hey, I know yum is the default to install a package, but this is a python package I need, so I'm telling you to use `pip` instead"

The most important resources of an attribute type are usually conceptually the same across operating systems, regardless of how the actual implementations differ. 

Like we said, most packages will be installed with `packageinstalelr install packagename`.

So, the description of a resource can be abstracted away from its implementation: 

We don't need to specify that `pkg` requires the `add` keyword instead of install, the provider will figure that out for us.

These two elements: 

* The type with the valid attributes
* The provider with the steps to actually undertake

Form the RAL.

## Getting and setting

Puppet uses the RAL to both **read** and **modify** the state of resources on a system. 

Since it's a declarative system, Puppet starts with an understanding of what state a resource should have.

To sync the resource, it uses the RAL to query the current state, compare that against the desired state, and then use the RAL again to make any necessary changes. It uses the tooling to get the current state of the system and then figures out what it needs to do to change that state to the state defined by the resource.

When Puppet applies the catalog containing the resource, it will read the actual state of the resource on the target system, compare the actual state to the desired state, and, if necessary, change the system to enforce the desired state.

## Conclusion

So that's all the theory of how the RAL works. 

Next, we'll show a detailed example of the RAL in action. We'll see an example of the RAL reading and modifying: getting and setting as part of a Puppet run.