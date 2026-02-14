+++
author = "Peter Souter"
categories = ["Tech"]
date = 2016-11-24T10:47:00Z
description = ""
draft = false
coverImage = "/images/2016/11/24919340383_4b331f2a0c_k.jpg"
slug = "the-puppet-resource-abstraction-layer-ral-explained-part-3"
tags = ["vDM30in30", "Puppet"]
title = "The Puppet Resource Abstraction Layer (RAL) Explained: Part 3"

+++

#### Day 24 in the #vDM30in30

> Image from https://flic.kr/p/DY38HH

So, we've talked about how the RAL is a getter and setter, but let's talk about a lesser known feature of puppet that uses the RAL: The `puppet resource` command.

The puppet resource command is basically a CLI for the RAL. Hey, it used to even be called ["ralsh"](https://linux.die.net/man/8/ralsh), for RAL Shell.

What it's doing is using that instances method from before, and running it on the system, and returning the current state as valid Puppet code.

Essentially, it's a CLI to the **getter** part of the RAL loop.

## Go-getter!

Running it with a given resource name will return all the instances it can find for that resource:

```
[root@homebox ~]# puppet resource package
package { 'acl':
  ensure => '2.2.51-12.el7',
}
package { 'audit':
  ensure => '2.4.1-5.el7',
}
package { 'audit-libs':
  ensure => '2.4.1-5.el7',
}
package { 'audit-libs-python':
  ensure => '2.4.1-5.el7',
}
package { 'authconfig':
  ensure => '6.2.8-10.el7',
}
... etc
```

The result it returns is valid Puppet code: you could throw it straight into a Puppet file on your master and start enforcing it, or output it to a puppet run and run Puppet apply on it.

If you give a named argument, it'll return the details of just that resource:

```
[root@homebox ~]# puppet resource package sudo
package { 'sudo':
  ensure => '1.8.6p7-17.el7_2',
}
```

## Setter

It's not just reserved for the getter: you can even use the `puppet resource` command to manipulate resources as a setter:

```
[root@homebox ~]# puppet resource package tree ensure=absent
Notice: /Package[tree]/ensure: removed
package { 'tree':
  ensure => 'purged',
}
```

And not just the ensure, but other fields:

```
[root@homebox ~]# puppet resource user tree ensure=present shell=/bin/false
Notice: /User[tree]/shell: shell changed '/bin/bash' to '/bin/false'
user { 'tree':
  ensure => 'present',
  shell  => '/bin/false',
}
```

In Part 4 we'll talk about how to implement your own RAL-layer for a custom type and provider.

## The other posts in this series
* https://petersouter.co.uk/the-puppet-resource-abstraction-layer-ral-explained-part-1/
* https://petersouter.co.uk/the-puppet-resource-abstraction-layer-ral-explained-part-2/
* https://petersouter.co.uk/the-puppet-resource-abstraction-layer-ral-explained-part-4/
