+++
author = "Peter Souter"
categories = ["Tech"]
date = 2015-02-27T14:16:00Z
description = ""
draft = false
coverImage = "/images/2016/10/15944989872_b958dc5552_z.jpg"
slug = "migrating-ghost-blogs-with-puppet"
tags = ["Puppet", "Nginx", "Gandi", "Ghost"]
title = "Migrating my blog to new Ghost and enabling HTTPS"

+++

So I originally set up this blog way, way back in 2013. I'd been using [Octopress](http://octopress.org/) and a Github hosted page. But it made it look like every other Jekyll blog out there. I had attended [TwilioCon 2013](http://www.twilio.com/conference/2013), and [Hannah Wolfe](https://twitter.com/ErisDS) gave a presentation on Ghost. It sounded pretty cool, and DigitalOcean had just created a Ghost image to play around with.

So I booted one up and it worked pretty well! The problem was, since it was an image, it was pretty annoying to maintain. I was stuck with Ghost 0.3 for a while. I remember looking into how hard it would be to automate with Puppet, but the only Ghost module on the forge at the time wasn't working for me. So I put it in my to-do pile to automate with Puppet, and left it.

So I recently saw it on my to-do list and had some spare time, so I set to work on the Ghost module, and released it as a new `0.3.0` version. I even added in some Beaker tests to check it fully worked!

I also made a basic Ghost profile to cut out a lot of the steps required. My profile looked something like this:

```puppet
class ghost_blog_profile::basic (
  $blog_name   = 'my_blog',
  $url         = $fqdn,
  $ssl_enabled = false,
)
{
  case $::osfamily {
    redhat: {
      $supervisor_path_bin = '/usr/bin'
    }
    debian: {
      $supervisor_path_bin = '/usr/local/bin'
    }
    default: {
      fail("ERROR: ${::osfamily} based systems are not supported!"  )
    }
  }

  class { 'nodejs':
    manage_repo => true,
  }
  ->
  class { ghost:}
  ->
  ghost::blog{ $blog_name:
    url    => $url,
    socket => false,
    use_supervisor => false,
  }
  ->
  exec { "chown -R ghost:ghost /home/ghost/${blog_name}/":
    path   => '/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/local/sbin',
    unless  => "test $(stat -c %U:%G /home/ghost/${blog_name}/) = ghost:ghost",
  }
  ->
  Class['::supervisor']
  ->
  supervisor::program { "ghost_${blog_name}":
    command        => "node /home/ghost/${blog_name}/index.js",
    autorestart    => true,
    user           => ghost,
    group          => ghost,
    directory      => "/home/ghost/${blog_name}/",
    stdout_logfile => "/var/log/ghost_${blog_name}.log",
    stderr_logfile => "/var/log/ghost_${blog_name}_err.log",
    environment    => 'NODE_ENV="production"',
  }
  ->
  exec { 'supervisor::update':
    command     => "${supervisor_path_bin}/supervisorctl reread && ${path_bin}/supervisorctl update",
    logoutput   => on_failure,
    refreshonly => true,
    require     => Service['supervisord'],
  }

  class { 'nginx':}

  nginx::resource::upstream { "ghost_blog_${blog_name}":
    members => [
      'localhost:2368',
    ],
  }

  nginx::resource::vhost { $fqdn:
    proxy       => "http://ghost_blog_${blog_name}",
    ssl         => $ssl_enabled,
    ssl_cert    => "/etc/nginx/ssl/${fqdn}.crt",
    ssl_key     => "/etc/nginx/ssl/${fqdn}.key",
  }

}
```

I made a module for this profile [here](https://github.com/petems/petems-ghost_blog_profile). I need to clean it up a bit, but it worked with a few modifications on my server.

This profile meant I could easily create a role for the server that would look something like this:

```puppet
node /petersouter.co.uk/{
  class { 'ghost_blog_profile::basic':
    blog_name => 'petersouter.co.uk',
    url       => 'http://petersouter.co.uk',
  }
}
```

Which worked like a charm.

With this success I moved on to my second idea: SSL.

My original SSL blocker was that it was going to be a lot of manual steps to set it up, and I only would enable SSL when I could configure it with Puppet. Now I had a puppet-ized the server server, it was easy enough to generate the certs, put them on the server, and make a small change to the role to enable them:

```puppet
node /petersouter.co.uk/{
  class { 'ghost_blog_profile::basic':
    blog_name   => 'petersouter.co.uk',
    url         => 'http://petersouter.co.uk',
    ssl_enabled => true,
  }
}
```

I used Gandi for the certs, and followed [this tutorial](https://benjeffrey.com/setting-up-gandi-ssl-on-nginx) on how to set it up. Copied them up to the server in the correct location and boom: I had fresh 0.5.8 Ghost blog, running through nginx with SSL enabled.
