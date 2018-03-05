+++
author = "Peter Souter"
categories = ["vDM30in30", "Tech", "Puppet"]
date = 2016-11-23T07:55:00Z
description = ""
draft = false
image = "/images/2016/11/7275336890_35ebd02683_k.jpg"
slug = "the-puppet-resource-abstraction-layer-ral-explained-part-2"
tags = ["vDM30in30", "Tech", "Puppet"]
title = "The Puppet Resource Abstraction Layer (RAL) Explained: Part 2"

+++

#### Day 23 in the #vDM30in30

> Image from https://flic.kr/p/c5U1bW

So, previously we talked about the RAL as a Swan.

Let's look at those legs kicking below the water.

## RAL with a package installation

Let's continue with our example of a resource on a system, a package called tree.

```puppet
package {'tree':
  ensure => present,
}
```

Let's look at how the RAL will manage this:

* We've given the type as package.
* I'm running this on a RHEL7 system, so the default provider is yum.
* yum is a "child" provider of rpm: it uses the RPM command to check if the package is installed on the system. 
* This is a lot faster than running "yum info", as it doesn't make any internet calls, and won't fail if a yumrepo is failing.
* The install command however, will be `yum install`.

So previously we talked about how Puppet uses the RAL to both read and modify the state of resources on a system. 

Both getting and setting.

## Getting

The "getter" of the RAL is the `self.instances` method in the provider.

Depending on the resource type, this is generally done in one of two ways:

* Read a file on disk, iterate through the lines in a file and turn those into resources
* Run a command on the terminal, break the stdout into lines, turn those into hashes which become resources

the `rpm` instances step goes with the latter. It runs `rpm -qa` with some given flags to check what packages are on the system:

```ruby
def self.instances
    packages = []

    # list out all of the packages
    begin
      execpipe("#{command(:rpm)} -qa #{nosignature} #{nodigest} --qf '#{self::NEVRA_FORMAT}'") { |process|
        # now turn each returned line into a package object
        process.each_line { |line|
          hash = nevra_to_hash(line)
          packages << new(hash) unless hash.empty?
        }
      }
    rescue Puppet::ExecutionFailure
      raise Puppet::Error, "Failed to list packages", $!.backtrace
    end

    packages
  end
```

So it's running `/usr/bin/rpm -qa --nosignature --nodigest --qf '%{NAME} %|EPOCH?{%{EPOCH}}:{0}| %{VERSION} %{RELEASE} %{ARCH}\n'`, then taking the stdout from that command, looping through each line of output from that, and using the `nevra_to_hash` method to turn the lines of STDOUT it into a hash.

```
self::NEVRA_REGEX  = %r{^(\S+) (\S+) (\S+) (\S+) (\S+)$}
self::NEVRA_FIELDS = [:name, :epoch, :version, :release, :arch]

private
  # @param line [String] one line of rpm package query information
  # @return [Hash] of NEVRA_FIELDS strings parsed from package info
  # or an empty hash if we failed to parse
  # @api private
  def self.nevra_to_hash(line)
    line.strip!
    hash = {}

    if match = self::NEVRA_REGEX.match(line)
      self::NEVRA_FIELDS.zip(match.captures) { |f, v| hash[f] = v }
      hash[:provider] = self.name
      hash[:ensure] = "#{hash[:version]}-#{hash[:release]}"
      hash[:ensure].prepend("#{hash[:epoch]}:") if hash[:epoch] != '0'
    else
      Puppet.debug("Failed to match rpm line #{line}")
    end

    return hash
  end
```

So basically it's a regex on the output, then turns those bits from the regex into the given fields. 

These hashes become the current state of the resource.

We can run `--debug` to see this in action:

```
Debug: Prefetching yum resources for package
Debug: Executing: '/usr/bin/rpm --version'
Debug: Executing '/usr/bin/rpm -qa --nosignature --nodigest --qf '%{NAME} %|EPOCH?{%{EPOCH}}:{0}| %{VERSION} %{RELEASE} %{ARCH}\n''
Debug: Executing: '/usr/bin/rpm -q tree --nosignature --nodigest --qf %{NAME} %|EPOCH?{%{EPOCH}}:{0}| %{VERSION} %{RELEASE} %{ARCH}\n'
Debug: Executing: '/usr/bin/rpm -q tree --nosignature --nodigest --qf %{NAME} %|EPOCH?{%{EPOCH}}:{0}| %{VERSION} %{RELEASE} %{ARCH}\n --whatprovides'
```

So it uses the RAL to fetch the current state:

* Hmm, this is a package resource titled 'tree' on a RHEL system, so I should use RPM
* Let's get the current state of the RPM packages installed (eg. the instances method
* Tree isn't here...
* So we need tree to be installed

The Yum provider then specifies the command required to install. 

There's a lot of logic here:

```ruby
def install
    wanted = @resource[:name]
    error_level = self.class.error_level
    update_command = self.class.update_command
    # If not allowing virtual packages, do a query to ensure a real package exists
    unless @resource.allow_virtual?
      execute([command(:cmd), '-d', '0', '-e', error_level, '-y', install_options, :list, wanted].compact)
    end

    should = @resource.should(:ensure)
    self.debug "Ensuring => #{should}"
    operation = :install

    case should
    when :latest
      current_package = self.query
      if current_package && !current_package[:ensure].to_s.empty?
        operation = update_command
        self.debug "Ensuring latest, so using #{operation}"
      else
        self.debug "Ensuring latest, but package is absent, so using #{:install}"
        operation = :install
      end
      should = nil
    when true, false, Symbol
      # pass
      should = nil
    else
      # Add the package version
      wanted += "-#{should}"
      if wanted.scan(ARCH_REGEX)
        self.debug "Detected Arch argument in package! - Moving arch to end of version string"
        wanted.gsub!(/(.+)(#{ARCH_REGEX})(.+)/,'\1\3\2')
      end

      current_package = self.query
      if current_package
        if rpm_compareEVR(rpm_parse_evr(should), rpm_parse_evr(current_package[:ensure])) < 0
          self.debug "Downgrading package #{@resource[:name]} from version #{current_package[:ensure]} to #{should}"
          operation = :downgrade
        elsif rpm_compareEVR(rpm_parse_evr(should), rpm_parse_evr(current_package[:ensure])) > 0
          self.debug "Upgrading package #{@resource[:name]} from version #{current_package[:ensure]} to #{should}"
          operation = update_command
        end
      end
    end

    # Yum on el-4 and el-5 returns exit status 0 when trying to install a package it doesn't recognize;
    # ensure we capture output to check for errors.
    no_debug = if Facter.value(:operatingsystemmajrelease).to_i > 5 then ["-d", "0"] else [] end
    command = [command(:cmd)] + no_debug + ["-e", error_level, "-y", install_options, operation, wanted].compact
    output = execute(command)

    if output =~ /^No package #{wanted} available\.$/
      raise Puppet::Error, "Could not find package #{wanted}"
    end

    # If a version was specified, query again to see if it is a matching version
    if should
      is = self.query
      raise Puppet::Error, "Could not find package #{self.name}" unless is

      # FIXME: Should we raise an exception even if should == :latest
      # and yum updated us to a version other than @param_hash[:ensure] ?
      vercmp_result = rpm_compareEVR(rpm_parse_evr(should), rpm_parse_evr(is[:ensure]))
      raise Puppet::Error, "Failed to update to version #{should}, got version #{is[:ensure]} instead" if vercmp_result != 0
    end
  end
```

This is some serious Swan leg kicking. There's a lot of logic here, for the more complex use case of a package on Yum, but making sure it works on the various versions of Yum avaliable, including RHEL 4 and 5.

The logic is broken down thusly: We haven't specified a version, so we don't need to check what version to install. Simply run `yum install tree` with the default options specified

```
Debug: Package[tree](provider=yum): Ensuring => present
Debug: Executing: '/usr/bin/yum -d 0 -e 0 -y install tree'
Notice: /Stage[main]/Main/Package[tree]/ensure: created
```

Ta-dah, installed. 

## Another example

So, let's show how this would work with a different system. Let's try with the `pip` provider.

So, the `self.instances` method runs `pip freeze` and gets the version of all the packages on the system:

```ruby
# Return an array of structured information about every installed package
  # that's managed by `pip` or an empty array if `pip` is not available.
  def self.instances
    packages = []
    pip_cmd = self.pip_cmd
    return [] unless pip_cmd
    execpipe "#{pip_cmd} freeze" do |process|
      process.collect do |line|
        next unless options = parse(line)
        packages << new(options)
      end
    end

    # Pip can also upgrade pip, but it's not listed in freeze so need to special case it
    # Pip list would also show pip installed version, but "pip list" doesn't exist for older versions of pip (E.G v1.0)
    if version = self.pip_version
      packages << new({:ensure => version, :name => File.basename(pip_cmd), :provider => name})
    end

    packages
  end
```

So, it is iterating through the list provided by `pip freeze` and seeing if the package listed is installed.

It can see that the pip package `tree` isn't in the list (getter), so it needs to install it (setter):

```ruby
  # Install a package.  The ensure parameter may specify installed,
  # latest, a version number, or, in conjunction with the source
  # parameter, an SCM revision.  In that case, the source parameter
  # gives the fully-qualified URL to the repository.
  def install
    args = %w{install -q}
    args +=  install_options if @resource[:install_options]
    if @resource[:source]
      if String === @resource[:ensure]
        args << "#{@resource[:source]}@#{@resource[:ensure]}#egg=#{
          @resource[:name]}"
      else
        args << "#{@resource[:source]}#egg=#{@resource[:name]}"
      end
    else
      case @resource[:ensure]
      when String
        args << "#{@resource[:name]}==#{@resource[:ensure]}"
      when :latest
        args << "--upgrade" << @resource[:name]
      else
        args << @resource[:name]
      end
    end
    lazy_pip *args
  end
```

So, it knows to run `/usr/bin/pip install -q tree`, installing the package:

```
Debug: Prefetching pip resources for package
Debug: Executing '/usr/bin/pip freeze'
Debug: Executing '/usr/bin/pip --version'
Debug: Executing '/usr/bin/pip freeze'
Debug: Executing '/usr/bin/pip --version'
Debug: Executing: '/usr/bin/pip install -q tree'
Notice: /Stage[main]/Main/Package[tree]/ensure: created
Debug: Finishing transaction 23198860
Debug: Storing state
Debug: Stored state in 0.01 seconds
```

## Conclusion

As we can see, the RAL is used for getting the current state, then setting the current state, all using the correct commands for given provider.

We're pulling the curtain back because we want to see the RAL in action. Normally the average user doesn't need to think about this: let Puppet do the hard work.

Next, we'll talk about the `puppet resource` command, and how it uses the RAL in the CLI.

## The other posts in this series
* https://petersouter.co.uk/the-puppet-resource-abstraction-layer-ral-explained-part-1/
* https://petersouter.co.uk/the-puppet-resource-abstraction-layer-ral-explained-part-3/
* https://petersouter.co.uk/the-puppet-resource-abstraction-layer-ral-explained-part-4/