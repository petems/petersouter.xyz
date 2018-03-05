+++
author = "Peter Souter"
categories = ["vDM30in30", "Puppet", "Tech"]
date = 2016-11-25T20:29:00Z
description = ""
draft = false
image = "/images/2016/11/61864434_df8782cdb2_o.jpg"
slug = "the-puppet-resource-abstraction-layer-ral-explained-part-4"
tags = ["vDM30in30", "Puppet", "Tech"]
title = "The Puppet Resource Abstraction Layer (RAL) Explained: Part 4"

+++

#### Day 25 in the #vDM30in30

> Image from https://flic.kr/p/6t59b

So, we've talked about the RAL, getters, setters and the `resource` command.

Now let's talk about implementing a RAL interface of our own.

## swap_file type and provider

I ended up implementing a RAL layer in my [swap_file](https://github.com/petems/petems-swap_file) module, mainly as an exercise in figuring out how types and providers work.

It looks like this:

```ruby
Puppet::Type.type(:swap_file).provide(:linux) do

  desc "Swap file management via `swapon`, `swapoff` and `mkswap`"

  confine  :kernel   => :linux
  commands :swapon   => 'swapon'
  commands :swapoff  => 'swapoff'
  commands :mkswap   => 'mkswap'

  mk_resource_methods

  def initialize(value={})
    super(value)
    @property_flush = {}
  end

  def self.get_swap_files
    swapfiles = swapon(['-s']).split("\n")
    swapfiles.shift
    swapfiles.sort
  end

  def self.prefetch(resources)
    instances.each do |prov|
      if resource = resources[prov.name]
        resource.provider = prov
      end
    end
  end

  def self.instances
    get_swap_files.collect do |swapfile_line|
      new(get_swapfile_properties(swapfile_line))
    end
  end

  def self.get_swapfile_properties(swapfile_line)
    swapfile_properties = {}

    # swapon -s output formats thus:
    # Filename        Type    Size  Used  Priority

    # Split on spaces
    output_array = swapfile_line.strip.split(/\s+/)

    # Assign properties based on headers
    swapfile_properties = {
      :ensure => :present,
      :name => output_array[0],
      :file => output_array[0],
      :type => output_array[1],
      :size => output_array[2],
      :used => output_array[3],
      :priority => output_array[4]
    }

    swapfile_properties[:provider] = :swap_file
    Puppet.debug "Swapfile: #{swapfile_properties.inspect}"
    swapfile_properties
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    @property_flush[:ensure] = :present
  end

  def destroy
    @property_flush[:ensure] = :absent
  end

  def create_swap_file(file_path)
    mk_swap(file_path)
    swap_on(file_path)
  end

  def mk_swap(file_path)
    Puppet.debug "Running `mkswap #{file_path}`"
    output = mkswap([file_path])
    Puppet.debug "Returned value: #{output}`"
  end

  def swap_on(file_path)
    Puppet.debug "Running `swapon #{file_path}`"
    output = swapon([file_path])
    Puppet.debug "Returned value: #{output}"
  end

  def swap_off(file_path)
    Puppet.debug "Running `swapoff #{file_path}`"
    output = swapoff([file_path])
    Puppet.debug "Returned value: #{output}"
  end

  def set_swapfile
    if @property_flush[:ensure] == :absent
      swap_off(resource[:name])
      return
    end

    create_swap_file(resource[:name]) unless exists?
  end

  def flush
    set_swapfile
    # Collect the resources again once they've been changed (that way `puppet
    # resource` will show the correct values after changes have been made).
    @property_hash = self.class.get_swapfile_properties(resource[:name])
  end

end

```

Now, there's a bunch of weird stuff in there, that to be honest even know I only vaguely understand...

I'd recommend reading [Gary's blog on the subject](http://garylarizza.com/blog/2013/12/15/seriously-what-is-this-provider-doing/). He explains a lot of the idea behind things like the `initialize` and `prefetch` stuff.

Basically, don't worry about it for now, lets stick to the bit we've talked about, the "setter": `self.instances`

## `self.instances`

So, just like the `rpm` provider, we need to implement a `self.instances` method.

So here we are:

```ruby
def self.instances
  get_swap_files.collect do |swapfile_line|
    new(get_swapfile_properties(swapfile_line))
  end
end
```

To make the code easier to read, I'm breaking down the process into easier to manage methods:

* Get current swap files as an output on the command line
* Take those lines and turn them into a hash

## `get_swap_files`

Getting those current swapfiles on a Linux machine is fairly simple: `swapon -s`.

```ruby
def self.get_swap_files
  swapfiles = swapon(['-s']).split("\n")
  swapfiles.shift
  swapfiles.sort
end
```

We `.shift` the first result, which removes the element of the lines, which is the column lines.

```
swapon -s
Filename				Type		Size	Used	Priority
/swapfile                               file		262140	0	-1
```

So we're left with just
```
/swapfile                               file		262140	0	-1
```

## `get_swapfile_properties`

We then take those lines and break up the chunks and turn them into a valid swapfile resource (as we've defined the valid parameters in our type)

```ruby
def self.get_swapfile_properties(swapfile_line)
    swapfile_properties = {}

    # swapon -s output formats thus:
    # Filename        Type    Size  Used  Priority

    # Split on spaces
    output_array = swapfile_line.strip.split(/\s+/)

    # Assign properties based on headers
    swapfile_properties = {
      :ensure => :present,
      :name => output_array[0],
      :file => output_array[0],
      :type => output_array[1],
      :size => output_array[2],
      :used => output_array[3],
      :priority => output_array[4]
    }

    swapfile_properties[:provider] = :swap_file
    Puppet.debug "Swapfile: #{swapfile_properties.inspect}"
    swapfile_properties
  end
```

So, let's test that out.

Here's the `swapon -s` command:

```
Filename				Type		Size	Used	Priority
/mnt/swap.1             file	     500732	   0	-1
```

And here's our RAL command:

```
[root@homebox ~]# puppet resource swap_file
swap_file { '/mnt/swap.1':
  ensure   => 'present',
  priority => '-1',
  size     => '500732',
  type     => 'file',
  used     => '0',
}
```

And we can even test that with an rspec test:

```ruby
require 'spec_helper'

describe Puppet::Type.type(:swap_file).provider(:linux) do

  let(:resource) { Puppet::Type.type(:swap_file).new(
    {
    :name     => '/tmp/swap',
    :size     => '1024',
    :provider => described_class.name
    }
  )}

  let(:provider) { resource.provider }

  let(:instance) { provider.class.instances.first }

  swapon_s_output = <<-EOS
Filename                        Type            Size    Used    Priority
/dev/sda2                       partition       4192956 0       -1
/dev/sda1                       partition       4454542 0       -2
  EOS

  swapon_line = <<-EOS
/dev/sda2                       partition       4192956 0       -1
  EOS

  mkswap_return = <<-EOS
Setting up swapspace version 1, size = 524284 KiB
no label, UUID=0e5e7c60-bbba-4089-a76c-2bb29c0f0839
  EOS

  swapon_line_to_hash = {
    :ensure => :present,
    :file => "/dev/sda2",
    :name => "/dev/sda2",
    :priority => "-1",
    :provider => :swap_file,
    :size => "4192956",
    :type => "partition",
    :used => "0",
  }

  before :each do
    Facter.stubs(:value).with(:kernel).returns('Linux')
    provider.class.stubs(:swapon).with(['-s']).returns(swapon_s_output)
  end

  describe 'self.instances' do
    it 'returns an array of swapfiles' do
      swapfiles      = provider.class.instances.collect {|x| x.name }
      swapfile_sizes = provider.class.instances.collect {|x| x.size }

      expect(swapfiles).to      include('/dev/sda1','/dev/sda2')
      expect(swapfile_sizes).to include('4192956','4454542')
    end
  end
```

So I'm mocking out the results of the various commands, and then I'm making sure that if I feed my provider that input, I get a collection of instances (`provider.class.instances`), which I then do some basic tests to see if it matches my mock.

## Further reading

Ok, so that's 4 blog posts about the RAL, hopefully you've got a better understanding of how all this stuff works.

It's quite a deep concept in the Puppet world, and hopefully it gives you a bit of insight into how Puppet works under the hood.

### The Docs
* https://docs.puppet.com/puppet/latest/reference/man/resource.html
* https://docs.puppet.com/puppet/latest/reference/lang_resources.html

### Developing types and providers

* [The Type and Providers Book](http://shop.oreilly.com/product/0636920026860.do)
* http://garylarizza.com/blog/2013/11/25/fun-with-providers/
* http://garylarizza.com/blog/2013/12/15/seriously-what-is-this-provider-doing/

### Further reading on the RAL
* http://somethingsinistral.net/blog/puppet-ral-an-introduction/
* https://docs.oracle.com/cd/E53394_01/html/E77676/gqqnd.html

## The other posts in this series
* https://petersouter.co.uk/the-puppet-resource-abstraction-layer-ral-explained-part-1/
* https://petersouter.co.uk/the-puppet-resource-abstraction-layer-ral-explained-part-2/
* https://petersouter.co.uk/the-puppet-resource-abstraction-layer-ral-explained-part-3/