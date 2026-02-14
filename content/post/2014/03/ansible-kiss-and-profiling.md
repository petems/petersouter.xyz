+++
author = "Peter Souter"
categories = ["Tech"]
date = 2014-03-08T13:57:37Z
description = ""
draft = false
coverImage = "/images/2016/10/8505316460_78d0abaf5b_z.jpg"
slug = "ansible-kiss-and-profiling"
tags = ["Tech", "Config Management", "Ansible"]
title = "Ansible: Keep it Simple!"

+++

It started with a few temporary bash scripts.

I think of Bash scripts as basically technical debt a lot of the time. "Hmm, when I get some spare time I'll fix those" things that niggle in the back of my mind. The ones on this project were pretty hard to maintain and took way too long. Mostly they were used to log onto a given array of servers and perform some actions, so they ran everything in sequence, and if anything broke along the way, it would block everything else from being run. But we'd been pretty busy and other stories have taken precidence, so I've tried to put them out of mind.

However:

<blockquote class="twitter-tweet" lang="en"><p>Make time for continuous improvement every day. <a href="https://twitter.com/search?q=%23Lean&amp;src=hash">#Lean</a> <a href="https://twitter.com/search?q=%23LEGO&amp;src=hash">#LEGO</a> <a href="http://t.co/GtW7OdSIWa">pic.twitter.com/GtW7OdSIWa</a></p>&mdash; Håkan Forss (@hakanforss) <a href="https://twitter.com/hakanforss/statuses/437244738249297921">February 22, 2014</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

So, I pulled in the work to fix up the scripts into another story and I found the perfect solution: Ansible.

I'd heard about Ansible before, but like Salt and Chef, I just assumed it was just another config management tool. But it's not. Ansible is to Puppet what what Sinatra is to Rails: a much more lightweight alternative with a different usecase. For smaller tasks like scp-ing over keys or running quick tasks, Ansible seems to fit the bill nicely.

## Getting Started

It's super simple. From the command line, if you want to quickly scp some files over you can run a simply command against an iventory file of servers:

```
ansible all -m copy -a "src=/etc/hosts dest=/tmp/hosts"
```

Or you can create playbooks of multiple commands.

A simple playbook like this:

```
---
- hosts: all
  tasks:
  - name: sleep 1
    shell: sleep 1
  - name: sleep 5
    shell: sleep 5
  - name: sleep 10
    shell: sleep 10
```

Run it against a hostfile of 10 servers, I'll get an output that looks like this:

```
PLAY [all] ********************************************************************

GATHERING FACTS ***************************************************************
ok: [server1]
ok: [server2]
ok: [server3]
ok: [server4]
ok: [server5]
ok: [server6]
ok: [server7]
ok: [server8]
ok: [server9]
ok: [server10]
ok: [server11]

TASK: [sleep 1] ***************************************************************
changed: [server1]
changed: [server2]
changed: [server3]
changed: [server4]
changed: [server5]
changed: [server6]
changed: [server7]
changed: [server8]
changed: [server9]
changed: [server10]
changed: [server11]

TASK: [sleep 5] ***************************************************************
changed: [server1]
changed: [server2]
changed: [server3]
changed: [server4]
changed: [server5]
changed: [server6]
changed: [server7]
changed: [server8]
changed: [server9]
changed: [server10]
changed: [server11]

TASK: [sleep 10] **************************************************************
changed: [server1]
changed: [server2]
changed: [server3]
changed: [server4]
changed: [server5]
changed: [server6]
changed: [server7]
changed: [server8]
changed: [server9]
changed: [server10]
changed: [server11]

PLAY RECAP ********************************************************************
sleep 10 -------------------------------------------------------------- 139.87s
sleep 5 ---------------------------------------------------------------- 69.04s
sleep 1 ---------------------------------------------------------------- 20.90s
server10  : ok=4    changed=3    unreachable=0    failed=0
server11  : ok=4    changed=3    unreachable=0    failed=0
server6   : ok=4    changed=3    unreachable=0    failed=0
server5   : ok=4    changed=3    unreachable=0    failed=0
server8   : ok=4    changed=3    unreachable=0    failed=0
server9   : ok=4    changed=3    unreachable=0    failed=0
server2   : ok=4    changed=3    unreachable=0    failed=0
server7   : ok=4    changed=3    unreachable=0    failed=0
server1   : ok=4    changed=3    unreachable=0    failed=0
server4   : ok=4    changed=3    unreachable=0    failed=0
server3   : ok=4    changed=3    unreachable=0    failed=0
```

(The `PLAY RECAP` section isn't native, I've installed the I've installed the [ansible-profile](https://github.com/jlafon/ansible-profile), which profiles how long playbook commands are taking.)

So it's taking about about 2 seconds to run each command, which is pretty much how long running a bash script would've taken. However, if I use the --fork option, or define a fork number in ansible.cfg, it'll run the commands in parallel, giving a much needed speed boost:

```
PLAY [all] ********************************************************************

GATHERING FACTS ***************************************************************
ok: [server1]
ok: [server2]
ok: [server3]
ok: [server4]
ok: [server5]
ok: [server6]
ok: [server7]
ok: [server8]
ok: [server9]
ok: [server10]
ok: [server11]

TASK: [sleep 1] ***************************************************************
changed: [server1]
changed: [server2]
changed: [server3]
changed: [server4]
changed: [server5]
changed: [server6]
changed: [server7]
changed: [server8]
changed: [server9]
changed: [server10]
changed: [server11]

TASK: [sleep 5] ***************************************************************
changed: [server1]
changed: [server2]
changed: [server3]
changed: [server4]
changed: [server5]
changed: [server6]
changed: [server7]
changed: [server8]
changed: [server9]
changed: [server10]
changed: [server11]

TASK: [sleep 10] **************************************************************
changed: [server1]
changed: [server2]
changed: [server3]
changed: [server4]
changed: [server5]
changed: [server6]
changed: [server7]
changed: [server8]
changed: [server9]
changed: [server10]
changed: [server11]

PLAY RECAP ********************************************************************
sleep 10 --------------------------------------------------------------- 12.18s
sleep 1 ---------------------------------------------------------------- 11.74s
sleep 5 ----------------------------------------------------------------- 7.75s
server5   : ok=4    changed=3    unreachable=0    failed=0
server10  : ok=4    changed=3    unreachable=0    failed=0
server8   : ok=4    changed=3    unreachable=0    failed=0
server9   : ok=4    changed=3    unreachable=0    failed=0
server7   : ok=4    changed=3    unreachable=0    failed=0
server6   : ok=4    changed=3    unreachable=0    failed=0
server1   : ok=4    changed=3    unreachable=0    failed=0
server4   : ok=4    changed=3    unreachable=0    failed=0
server3   : ok=4    changed=3    unreachable=0    failed=0
server2   : ok=4    changed=3    unreachable=0    failed=0
server11  : ok=4    changed=3    unreachable=0    failed=0
```

So far it's looking pretty good: a bash script being run on our CI server was taking anywhere from 15-20 minutes. With this new playbook, it takes 3-5 minutes, and is non-blocking.

I can probably even improve that There's also a few speed tweaks you can make, such as the [accelerate mode](http://docs.ansible.com/playbooks_acceleration.html), and the new implementation of the ssh wrappers in 1.5 (you just have to make sure the `pipelining = True` option is enabled and disable tty if you're running sudo commands).

I'm looking forward to delving deeper into custom providers and plugins in the future, but I'll need to learn Python first...
