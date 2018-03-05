+++
author = "Peter Souter"
categories = ["vDM30in30", "open-source", "systemd"]
date = 2016-11-28T15:20:00Z
description = ""
draft = false
image = "/images/2016/11/21010813392_4ff8e6b7e2_o.png"
slug = "dealing-with-var-run-in-systemd-unit-files"
tags = ["vDM30in30", "open-source", "systemd"]
title = "Dealing with /var/run in systemd unit files"

+++

#### Day 28 in the #vDM30in30

> Image source: https://flic.kr/p/y1DUPj

So previously I blogged about about [how to ensure a `/var/run` directory exists before a systemd service starts, using the `ExecStartPre` steps to ensure the directory exists.](https://petersouter.co.uk/jmxtrans-what-is-it-and-how-to-configure-it/#systemdstrikesagain)

```
ExecStartPre=-/usr/bin/mkdir /run/jmxtrans/
ExecStartPre=/usr/bin/chown -R jmxtrans:jmxtrans /run/jmxtrans/
```

I took the idea from a blog by [Jari Turkia](https://blog.hqcodeshop.fi/archives/93-Handling-varrun-with-systemd.html).
 
However, I made the rookie mistake of not checking the comments to see if things had changed and there was a better way, since the original post was written in 2013. 

[In March 2014](https://github.com/systemd/systemd/commit/e66cf1a3f94fff48a572f6dbd19b43c9bcf7b8c7), there was a new new `RuntimeDirectory` setting. It was made exactly for this use-case:

> System daemons frequently require private runtime directories below /run to place communication sockets and similar in. For these, consider declaring them in their unit files using RuntimeDirectory= (see systemd.exec(5) for details), if this is feasible.

**Source:https://freedesktop.org/software/systemd/man/tmpfiles.d.html#Description**

This has been available since systemd 211.

So the systemd service file will actually be much easier:

```
[Unit]
Description=JMX Transformer - more than meets the eye
After=syslog.target network.target

[Service]
Type=forking
User=jmxtrans
Group=jmxtrans
RuntimeDirectory=jmxtrans
PIDFile=/var/run/jmxtrans/jmxtrans.pid
ExecStart=/usr/share/jmxtrans/bin/jmxtrans start

[Install]
WantedBy=multi-user.target
```

As we only have to specify the `RuntimeDirectory` setting.

Funnily enough this also happened in the Redis module I was working on.

I found that the Beaker tests would sometimes fail with Debian 8 (Jessie), which was using a redis package.

It was using the `dotdeb-redis` package which had a systemd file that looked like this:

```
[Unit]
Description=Advanced key-value store
After=network.target
Documentation=http://redis.io/documentation, man:redis-server(1)

[Service]
Type=forking
ExecStart=/usr/bin/redis-server /etc/redis/redis.conf
PIDFile=/var/run/redis/redis-server.pid
TimeoutStopSec=0
Restart=always
User=redis
Group=redis

ExecStartPre=-/bin/run-parts --verbose /etc/redis/redis-server.pre-up.d
ExecStartPost=-/bin/run-parts --verbose /etc/redis/redis-server.post-up.d
ExecStop=-/bin/run-parts --verbose /etc/redis/redis-server.pre-down.d
ExecStop=/bin/kill -s TERM $MAINPID
ExecStopPost=-/bin/run-parts --verbose /etc/redis/redis-server.post-down.d

PrivateTmp=yes
LimitNOFILE=65535
PrivateDevices=yes
ProtectHome=yes
ReadOnlyDirectories=/
ReadWriteDirectories=-/var/lib/redis
ReadWriteDirectories=-/var/log/redis
ReadWriteDirectories=-/var/run/redis
CapabilityBoundingSet=~CAP_SYS_PTRACE

# redis-server writes its own config file when in cluster mode so we allow
# writing there (NB. ProtectSystem=true over ProtectSystem=full)
ProtectSystem=true
ReadWriteDirectories=-/etc/redis

[Install]
WantedBy=multi-user.target
Alias=redis.service
```

So this service file would have the same issue: if the directory for the pid was missing, it would refuse to start:

```
root@debian-redis-test:~# systemctl stop redis-server

root@debian-redis-test:~# rm -rf /var/run/redis/

root@debian-redis-test:~# systemctl start redis-server
Job for redis-server.service failed. See 'systemctl status
redis-server.service' and 'journalctl -xn' for details.

root@debian-redis-test:~# journalctl -u redis-server --no-pager | grep pid
Nov 30 13:29:04 debian-redis-test systemd[1]: PID file
/var/run/redis/redis-server.pid not readable (yet?) after start-post.
```

I would assume this would affect the upstream debian package, but for some reason it's not... but I thought it would be a good idea to add that field to the systemd unit file anyways. Plus it gives me an excuse to open my first Debian bug: 

https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=846350