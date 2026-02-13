+++
author = "Peter Souter"
categories = ["Puppet", "Tech", "vDM30in30", "hiera"]
date = 2016-11-01T21:48:11Z
description = ""
draft = false
coverImage = "/images/2016/11/screenshot-1.png"
slug = "an-omnibus-install-for-hiera_explain"
tags = ["Puppet", "Tech", "vDM30in30", "hiera"]
title = "An Omnibus package for hiera_explain"

+++

#### Day 1 in the #vDM30in30

So, recently I was working with someone who was having issues with hiera lookups not working. Debugging hiera can be a bit of a pain, because it's not super good at explaining what's going wrong.

Luckily, Ben Ford, former PSE, now Education person at Puppet and generally awesome dude has made an awesome tool to do just that:

# [hiera_explain](https://github.com/binford2k/hiera_explain)

![hiera_explain in action](/images/2016/11/screenshot.png)

It's a way more verbose and explanatory way of doing everything, and the person I was working it loved it when I showed it on my test machine.

However, the tool itself had a few issues that made it not so suitable for them:

- The Customer was on CentOS 6, which still has Ruby 1.8.7. Meaning the code would have to have the backports gem added and/or a bunch of code fixed to work with 1.8.7
- Since 1.8.7 is super, super EOL, you have to go through all the gems pinning them to versions that work with 1.8.7
- Since the gem itself installs hiera and puppet as part of its tooling, it's easy to accidentally overwrite the (especially if you're using pre-AIO packages which have a standard bin path)
- It makes a number of assumptions that you have a newer version of Puppet installed so has a few issues with older Puppet (I opened an issue to remind myself to go back and fix the things I found: https://github.com/binford2k/hiera_explain/issues/7)

I tried a few solutions, like vendoring the gems into the repository and playing around with bundler gemstubs. This was a pretty dull process that sucked up way more of my time than I'd like to admit.

Eventually I just pulled the nuclear option: making an Omnibus package.

## Omnibus

Omnibus is Chef's solution for dependency hell with Ruby projects. Build a package that vendors _everything_. You end up with a fairly chunky package, but crucially: you don't have to worry about worrying about upstream Ruby versions and issues with gem management. It just installs everything to a given path.

So, that's what I did:

### https://github.com/petems/omnibus-hiera_explain/

There are a number of existing Omnibus Gem repos, but a lot of them are using the old Omnibus syntax, and there's been a bunch of breaking changes recently so it was hard to follow tutorials.

Eventually I found a fairly recent repository and copied it's steps (https://github.com/Misenko/omnibus-oneacct-export).


I forked it, and made a note of all the dependencies the build required, with an intention to go back later to automate the build server later. This gave me a setup that looked like this:


```ruby
./omnibus-hiera_explain/config/projects/hiera_explain.rb
name 'hiera_explain'
maintainer 'Peter Souter <root@localhost>'
homepage 'https://github.com/petems/omnibus-hiera_explain'
description 'A tool for explaining hiera'

install_dir     '/opt/hiera_explain'
build_version   "0.0.3"
build_iteration 1

override :rubygems, :version => '2.4.4'
## WARN: do not forget to change RUBY_VERSION in the postinst script
##       when switching to a new minor version
override :ruby, :version => '2.1.5'

# creates required build directories
dependency 'preparation'

dependency 'patch'

# hiera_explain dependencies/components
dependency 'hiera_explain'

# version manifest file
dependency 'version-manifest'

# tweaking package-specific options
package :deb do
  license 'Apache'
end

package :rpm do
  license 'Apache'
end

exclude '\.git*'
exclude 'bundler\/git'
```

```ruby
# ./omnibus-hiera_explain/config/software/hiera_explain.rb
name "hiera_explain"

default_version "0.0.3"

dependency "ruby"
dependency "rubygems"

build do
  gem "install hiera_explain -n #{install_dir}/bin --no-rdoc --no-ri -v #{version}"
  delete "#{install_dir}/embedded/docs"
  delete "#{install_dir}/embedded/share/man"
  delete "#{install_dir}/embedded/share/doc"
  delete "#{install_dir}/embedded/ssl/man"
  delete "#{install_dir}/embedded/info"
end
```

I banged my head up against a pretty weird looking bug for a long time:

```ruby
       [Builder: openssl] I | 2016-10-26T20:33:21+00:00 | $ patch -p1 -i /usr/lib64/ruby/gems/2.3.0/bundler/gems/omnibus-software-02b070d484a1/config/patches/openssl/openssl-1.0.1f-do-not-build-docs.patch
       [Builder: openssl] I | 2016-10-26T20:33:21+00:00 | Apply patch `openssl-1.0.1f-do-not-build-docs.patch': 0.0067s
       [Builder: openssl] I | 2016-10-26T20:33:21+00:00 | Build openssl: 0.0074s
/usr/lib64/ruby/gems/2.3.0/gems/mixlib-shellout-2.2.6/lib/mixlib/shellout/unix.rb:338:in `exec': No such file or directory - patch (Errno::ENOENT)
    from /usr/lib64/ruby/gems/2.3.0/gems/mixlib-shellout-2.2.6/lib/mixlib/shellout/unix.rb:338:in `block in fork_subprocess'
    from /usr/lib64/ruby/gems/2.3.0/gems/mixlib-shellout-2.2.6/lib/mixlib/shellout/unix.rb:316:in `fork'
```

I even opened an issue for it https://github.com/chef/omnibus/issues/730

It was really strange, I could see that patch file existed, but for some reason it couldn't find it when trying to build the package!

Eventually I realised it was a red-herring error: it wasn't saying it couldn't find the patch file... the patch command itself was missing from my build box!

So `yum install patch` later and everything was fine.

### What it does

Basically, `hiera_explain` the gem, plus it's various dependencies and it's own copy of Ruby (2.1.5 for now, as that's what Puppet 4 is using) under `/opt/hiera_explain`, from there you can treat it like normal.

For example, trying to debug an issue with a hierarchy containing `osfamily` and a testing environment settings:

```
$ /opt/hiera_explain/bin/hiera_explain -c /etc/puppet/hiera.yaml osfamily=RedHat environment=testing
Backend data directories:
  * yaml: /etc/puppetlabs/code/hieradata
  * json: /etc/puppetlabs/code/hieradata

Expanded hierarchy:
  * overrides
  * environments/testing/hieradata/RedHat
  * environments/testing/hieradata/defaults
  * classroom
  * tuning
  * common
  * defaults

File lookup order:
  [ ] /etc/puppetlabs/code/hieradata/overrides.yaml
  [X] /etc/puppetlabs/code/hieradata/environments/testing/hieradata/RedHat.yaml
  [ ] /etc/puppetlabs/code/hieradata/environments/testing/hieradata/defaults.yaml
  [ ] /etc/puppetlabs/code/hieradata/classroom.yaml
  [ ] /etc/puppetlabs/code/hieradata/tuning.yaml
  [ ] /etc/puppetlabs/code/hieradata/common.yaml
  [ ] /etc/puppetlabs/code/hieradata/defaults.yaml
  [ ] /etc/puppetlabs/code/hieradata/overrides.json
  [ ] /etc/puppetlabs/code/hieradata/environments/testing/hieradata/RedHat.json
  [ ] /etc/puppetlabs/code/hieradata/environments/testing/hieradata/defaults.json
  [ ] /etc/puppetlabs/code/hieradata/classroom.json
  [ ] /etc/puppetlabs/code/hieradata/tuning.json
  [ ] /etc/puppetlabs/code/hieradata/common.json
  [ ] /etc/puppetlabs/code/hieradata/defaults.json

Priority lookup results:
   * hiera('common') => hello

Array lookup results:
   * hiera_array('common') => ["hello"]

Hash lookup results:
   * hiera_hash('common') => Not a hash datatype in ["environments/testing/hieradata/RedHat.yaml"]
```

From there, you can easily install the package temporarily on a test server. Since all of the gem and ruby requirements are kept under the `/opt/hiera_explain` path, you dont have to worry about conflicts.

Then when you're finished, you can simply remove the package (or keep it for future debugging!)

