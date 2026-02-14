+++
author = "Peter Souter"
categories = ["Tech"]
date = 2016-11-03T23:49:00Z
description = ""
draft = false
coverImage = "/images/2016/11/Screenshot-2016-11-04-01.07.59.png"
slug = "how-i-accidentally-helped-find-a-showstopper-bug-in-ruby-2"
tags = ["Tech", "Open-Source", "vDM30in30"]
title = "How I accidentally helped find a showstopper bug in Ruby"

+++

#### Day 3 in the #vDM30in30

It all started with a hanging build...

https://travis-ci.org/voxpupuli/puppet-nginx/builds/166701701

We were having an issue with a hanging build with mocked tests for Facter in the Nginx module for Vox Pupuli. Since I was the last person who touched it, I took responsibility for the issue and dug in.

The code was a basic unit test for checking Ruby code to determine the version of nginx installed:

```ruby
require 'spec_helper'

describe Facter::Util::Fact do
  before { Facter.clear }

  describe 'nginx_version' do

    before do
      Facter::Util::Resolution.stubs(:exec)
    end

    context 'neither nginx or openresty in path' do
      before do
        Facter::Util::Resolution.stubs(:which).with('nginx').returns(false)
        Facter::Util::Resolution.stubs(:which).with('openresty').returns(false)
      end
      it { expect(Facter.fact(:nginx_version).value).to eq(nil) }
    end
    context 'nginx in path' do
      context 'with current version output format' do
        before do
          Facter::Util::Resolution.stubs(:which).with('nginx').returns(true)
          Facter::Util::Resolution.stubs(:exec).with('nginx -v 2>&1').returns('nginx version: nginx/1.8.1')
        end
        it { expect(Facter.fact(:nginx_version).value).to eq('1.8.1') }
      end
      context 'with old version output format' do
        before do
          Facter::Util::Resolution.stubs(:which).with('nginx').returns(true)
          Facter::Util::Resolution.stubs(:exec).with('nginx -v 2>&1').returns('nginx: nginx version: nginx/0.7.0')
        end
        it { expect(Facter.fact(:nginx_version).value).to eq('0.7.0') }
      end
    end
    context 'openresty in path' do
      context 'with current version output format' do
        before do
          Facter::Util::Resolution.stubs(:which).with('nginx').returns(false)
          Facter::Util::Resolution.stubs(:which).with('openresty').returns(true)
          Facter::Util::Resolution.stubs(:exec).with('openresty -v 2>&1').returns('nginx version: openresty/1.11.2.1')
        end
        it { expect(Facter.fact(:nginx_version).value).to eq('1.11.2.1') }
      end
      context 'with old version output format' do # rubocop:disable RSpec/EmptyExampleGroup
      # Openresty never used the old format as far as I can find, no point testing
      end
    end
  end
end
```

However, I couldn't reproduce it locally. Regardless of Ruby version, it seemed fine for me.

Eventually I realised the gem had been updated, and as the gem wasn't pinned in the Gemfile and Travis installs gems from a clean state. There had been a recent release in `v1.2.0` that caused the failure.

However, it didn't look like an issue with our code. The test was written in the same way as all the tests I'd written. In fact, it looked like a bug with the mocking tool itself: mocha.

So I did a bit of digging. I'd seen a blog post about
[ruby-stacktrace](https://github.com/jvns/ruby-stacktrace), a Rust tool that allows you to do a stacktrace on a Ruby process. Seemed like a perfect fit. With a bit of debugging with ruby-stacktrace, I could see the following where the hang was happening in Ruby:

```
 self | tot  | method
 100.0% | 33.3% | hide_original_method : /root/.rbenv/versions/2.3.1/lib/ruby/gems/2.3.0/gems/mocha-1.2.0/lib/mocha/class_method.rb
```

Looking through the code, mocha had changed the `hide_original_method` in the 1.2.0 release. So looked like a mocha issue.

So I logged as much info as I could to the mocha ticket, and left it to the experts, ie. the Mocha author James Mead.

To my surprise, James ended up figuring out the issue: it was a live one, a real life bug in Ruby! And not just a small one, a biggie:

> I can reproduce this. Seems like a infinite loop inside `ofrb_callable_method_entry_without_refinements`. I think this is a showstopper bug.

https://bugs.ruby-lang.org/issues/12832

Now identified, the issue was fixed in both Mocha and Ruby itself, and all was well.

Honestly, I didn't understand the actual cause or issues why it happened, but I'm glad that I was a small part of helping fix a bug in Ruby!
