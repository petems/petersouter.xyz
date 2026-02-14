+++
author = "Peter Souter"
categories = ["Tech"]
date = 2016-11-17T11:46:00Z
description = ""
draft = false
coverImage = "/images/2016/11/Screenshot-2016-11-30-13.57.59.png"
slug = "drying-up-rspec-with-shared_examples"
tags = ["vDM30in30", "Testing", "Puppet", "Ruby"]
title = "Drying up rspec with shared_examples"

+++

#### Day 17 in the #vDM30in30

**Header image taken from https://www.relishapp.com/rspec/rspec-core/docs/example-groups/shared-examples**

One of the areas where it's easy to have WET (We Enjoy Typing) code that you want to DRY (Don't Repeat Yourself) up, is tests.

When writing tests for similar areas of code, it's easy to end up copy and pasting. You have to pieces of functionality that need to be tested in the same way, so why not copy and paste the testing code?

## Why duplication is bad...

What's the problem with copy-pasted code? It makes editing more difficult due to unnecessary increases in complexity and length.

Duplication comes with an increased maintenance cost: duplication means more places to be updated when a change occurs, meaning a higher chance of human error when changing, and duplicated code often ends up forgotten or overlooked.

[There's a good summary of the issue here](http://wiki.c2.com/?DontRepeatYourself)

## Meta-programming in Specs

So WET code is bad...how can we fix this in specs?

One solution I'd seen commonly was to just use standard array iteration to fix this:

```ruby
require 'spec_helper'

describe ReminderMailer, type: :mailer do

  # Half the code yay! :D
  ['daily','weekly'].each do |time_format|
    describe time_format do
      let(:time_format) { time_format }
      let(:user) do
        mock_model(User, nickname:           'David',
                         email:              'david@example.com',
                         languages:          ['Ruby'],
                         skills:             [],
                         pull_requests:      double(:pull_request, year: []),
                         suggested_projects: [])
      end

      # How do I do this bit better?
      let(:mail) {
        if time_format == 'daily'
          ReminderMailer.daily(user)
        else
          ReminderMailer.weekly(user)
        end
      }

end
```

However, this isn't super easy to maintain: I have to change the array and add more logic when new things get created. And what if I want to use this in multiple spec files?

It's not ideal.

## How to do it properly

I actually opened [a question on the Code Review Stack Exchange page about a different issue I was having with the spec](http://codereview.stackexchange.com/questions/72161/dry-ing-up-some-rspec), and I got the best kind of answer: not only the solution to the question I asked, but a better way of abstracting the test!

[tokland](http://codereview.stackexchange.com/users/2607/tokland) gave me a better answer:

```ruby
describe ReminderMailer, type: :mailer do
  let(:user) { ... }

  shared_examples "a reminder mailer" do |subject:, body:|
    it 'renders the subject' do
      expect(mail.subject).to eq(subject)
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq([user.email])
    end

    it 'renders the sender email' do
      expect(mail['From'].to_s).to eq('24 Pull Requests <info@24pullrequests.com>')
    end

    it 'uses nickname' do
      expect(mail.body.encoded).to match(user.nickname)
    end

    it 'contains periodicity in body' do
      expect(mail.body.encoded).to match(body)
    end
  end

  describe 'daily' do
    let(:mail) { ReminderMailer.daily(user) }

    it_behaves_like "a reminder mailer",
      subject: '[24 Pull Requests] Daily Reminder',
      body: 'today'
  end

  describe 'weekly' do
    let(:mail) { ReminderMailer.weekly(user) }

    it_behaves_like "a reminder mailer",
      subject: '[24 Pull Requests] Weekly Reminder',
      body: 'week'
  end
end
```

This is using the [shared_examples](https://www.relishapp.com/rspec/rspec-core/docs/example-groups/shared-examples) helper, which is a way of making an abstracted spec that you can re-use.

What's great about this is, if a new email reminder for monthly was implemented, the spec could be extended fairly easily:

```ruby
describe 'monthly' do
  let(:mail) { ReminderMailer.monthly(user) }

  it_behaves_like "a reminder mailer",
    subject: '[24 Pull Requests] Monthly Reminder'
    body: 'monthly'
  end
end
```


## An rspec-puppet example

rspec-puppet uses rspec core code under the hood, so it can also used shared_examples.

For example, a pattern I use often is to create a shared_example for the standard checks for a Puppet class, then use a `it_behaves_like` loop with [rspec-puppet-facts,](https://github.com/mcanevet/rspec-puppet-facts) which creates an array from all the platforms you say you support in the `metadata.json` file.

Essentially it means you can test your base code works on all your platforms you say you support with one block of code, rather than having to copy and paste specs for each platform.

[An example from my Cockpit module:](https://github.com/petems/petems-cockpit/blob/635d0c68179f975522f1c93afea250049b0ece69/spec/classes/cockpit_spec.rb)
```
require 'spec_helper'

describe 'cockpit' do

  shared_examples 'no parameters' do
    let(:params) {{ }}

    it { should compile.with_all_deps }

    it { should create_class('cockpit') }

    it { should contain_class('cockpit::params') }
    it { should contain_class('cockpit::repo').that_comes_before('Class[cockpit::install]') }
    it { should contain_class('cockpit::install').that_comes_before('Class[cockpit::config]') }
    it { should contain_class('cockpit::config') }
    it { should contain_class('cockpit::service').that_subscribes_to('Class[cockpit::config]') }

    it { should contain_ini_setting('Cockpit LoginTitle').with(
      :ensure    => 'present',
      :path      => '/etc/cockpit/cockpit.conf',
      :section   => 'WebService',
      :setting   => 'LoginTitle',
      :value     => facts[:fqdn],
      :show_diff => true,
      ) }

    it { should contain_ini_setting('Cockpit LoginTitle').with(
      :ensure    => 'present',
      :path      => '/etc/cockpit/cockpit.conf',
      :section   => 'WebService',
      :setting   => 'LoginTitle',
      :value     => facts[:fqdn],
      :show_diff => true,
      ) }

    it { should contain_ini_setting('Cockpit MaxStartups').with(
      :ensure    => 'present',
      :path      => '/etc/cockpit/cockpit.conf',
      :section   => 'WebService',
      :setting   => 'MaxStartups',
      :value     => '10',
      :show_diff => true,
      ) }

    it { should contain_ini_setting('Cockpit AllowUnencrypted').with(
      :ensure    => 'present',
      :path      => '/etc/cockpit/cockpit.conf',
      :section   => 'WebService',
      :setting   => 'AllowUnencrypted',
      :value     => false,
      :show_diff => true,
      ) }

    it { should contain_service('cockpit').with(
      :ensure => 'running',
      # :enable => 'true'
      )}
    it { should contain_package('cockpit').with_ensure('installed') }

    context 'with custom parameters' do
      context 'package name' do
        let(:params) {{ 'package_name' => 'custom-package' }}
        it { should contain_package("#{params['package_name']}") }
      end
      context 'package version' do
        let(:params) {{ 'package_version' => 'latest' }}
        it { should contain_package('cockpit').with_ensure('latest') }
      end
      context 'manage service' do
        let(:params) {{ 'manage_service' => false }}
        it { should_not contain_service("cockpit") }
      end
      context 'service name' do
        let(:params) {{ 'service_name' => 'custom-service' }}
        it { should contain_service("#{params['service_name']}") }
      end
      context 'port' do
        let(:params) {{ 'port' => '7777' }}
        it {
          should contain_file('/etc/systemd/system/cockpit.socket.d/listen.conf').
            with(:ensure    => 'file')
          should contain_file('/etc/systemd/system/cockpit.socket.d/listen.conf').
            with_content(/ListenStream=7777/)
          should contain_file('/etc/systemd/system/cockpit.socket.d/').
            with(:ensure    => 'directory')
          should contain_exec('Cockpit systemctl daemon-reload').with(
            :command     => 'systemctl daemon-reload',
            :refreshonly => true,
            :path => facts[:path],
          )
        }
      end
    end
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge({
          :fqdn => 'cockpit.example.com',
          :path => '/usr/lib64/qt-3.3/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/opt/puppetlabs/bin:/root/bin'
        })
      end

      it_behaves_like 'no parameters'
    end
  end

end
```

## An example from the Puppet codebase

For example, the `dnf` application in the new Fedora builds, is almost exactly the same as the `yum` applications, but there are a few small differences, such as the error level required to run it, and the command for upgrading packages, but everything else is the same.

So, in the Puppet codebase, there were two unit tests to test this, largely with the same content:

```
#! /usr/bin/env ruby
require 'spec_helper'

provider_class = Puppet::Type.type(:package).provider(:yum)

describe provider_class do
  include PuppetSpec::Fixtures

  let(:name) { 'mypackage' }
  let(:resource) do
    Puppet::Type.type(:package).new(
      :name     => name,
      :ensure   => :installed,
      :provider => 'yum'
    )
  end

  let(:provider) do
    provider = provider_class.new
    provider.resource = resource
    provider
  end

  before do
    provider_class.stubs(:command).with(:cmd).returns('/usr/bin/yum')
    provider.stubs(:rpm).returns 'rpm'
    provider.stubs(:get).with(:version).returns '1'
    provider.stubs(:get).with(:release).returns '1'
    provider.stubs(:get).with(:arch).returns 'i386'
  end

  describe 'provider features' do
    it { is_expected.to be_versionable }
    it { is_expected.to be_install_options }
    it { is_expected.to be_virtual_packages }
  end

  # provider should repond to the following methods
   [:install, :latest, :update, :purge, :install_options].each do |method|
     it "should have a(n) #{method}" do
       expect(provider).to respond_to(method)
    end
  end

  describe 'when installing' do
    before(:each) do
      Puppet::Util.stubs(:which).with("rpm").returns("/bin/rpm")
      provider.stubs(:which).with("rpm").returns("/bin/rpm")
      Puppet::Util::Execution.expects(:execute).with(["/bin/rpm", "--version"], {:combine => true, :custom_environment => {}, :failonfail => true}).returns("4.10.1\n").at_most_once
      Facter.stubs(:value).with(:operatingsystemmajrelease).returns('6')
    end

    it 'should call yum install for :installed' do
      resource.stubs(:should).with(:ensure).returns :installed
      Puppet::Util::Execution.expects(:execute).with(['/usr/bin/yum', '-d', '0', '-e', '0', '-y', :install, 'mypackage'])
      provider.install
    end

    context 'on el-5' do
      before(:each) do
        Facter.stubs(:value).with(:operatingsystemmajrelease).returns('5')
      end

      it 'should catch yum install failures when status code is wrong' do
        resource.stubs(:should).with(:ensure).returns :installed
        Puppet::Util::Execution.expects(:execute).with(['/usr/bin/yum', '-e', '0', '-y', :install, name]).returns("No package #{name} available.")
        expect {
          provider.install
        }.to raise_error(Puppet::Error, "Could not find package #{name}")
      end
    end

    it 'should use :install to update' do
      provider.expects(:install)
      provider.update
    end

    it 'should be able to set version' do
      version = '1.2'
      resource[:ensure] = version
      Puppet::Util::Execution.expects(:execute).with(['/usr/bin/yum', '-d', '0', '-e', '0', '-y', :install, "#{name}-#{version}"])
      provider.stubs(:query).returns :ensure => version
      provider.install
    end

    it 'should handle partial versions specified' do
      version = '1.3.4'
      resource[:ensure] = version
      Puppet::Util::Execution.expects(:execute).with(['/usr/bin/yum', '-d', '0', '-e', '0', '-y', :install, 'mypackage-1.3.4'])
      provider.stubs(:query).returns :ensure => '1.3.4-1.el6'
      provider.install
    end

    it 'should be able to downgrade' do
      current_version = '1.2'
      version = '1.0'
      resource[:ensure] = '1.0'
      Puppet::Util::Execution.expects(:execute).with(['/usr/bin/yum', '-d', '0', '-e', '0', '-y', :downgrade, "#{name}-#{version}"])
      provider.stubs(:query).returns(:ensure => current_version).then.returns(:ensure => version)
      provider.install
    end

    it 'should accept install options' do
      resource[:ensure] = :installed
      resource[:install_options] = ['-t', {'-x' => 'expackage'}]

      Puppet::Util::Execution.expects(:execute).with(['/usr/bin/yum', '-d', '0', '-e', '0', '-y', ['-t', '-x=expackage'], :install, name])
      provider.install
    end

    it 'allow virtual packages' do
      resource[:ensure] = :installed
      resource[:allow_virtual] = true
      Puppet::Util::Execution.expects(:execute).with(['/usr/bin/yum', '-d', '0', '-e', '0', '-y', :list, name]).never
      Puppet::Util::Execution.expects(:execute).with(['/usr/bin/yum', '-d', '0', '-e', '0', '-y', :install, name])
      provider.install
    end
  end

  describe 'when uninstalling' do
    it 'should use erase to purge' do
      Puppet::Util::Execution.expects(:execute).with(['/usr/bin/yum', '-y', :erase, name])
      provider.purge
    end
  end

  # [...] Even more tests that aren't being specifically tested in DNF

end
```

However, we had a duplicated spec for DNF:

```ruby
# puppet/spec/unit/provider/package/dnf_spec.rb
require 'spec_helper'

# Note that much of the functionality of the dnf provider is already tested with yum provider tests,
# as yum is the parent provider.

provider_class = Puppet::Type.type(:package).provider(:dnf)

describe provider_class do
  let(:name) { 'mypackage' }
  let(:resource) do
    Puppet::Type.type(:package).new(
      :name => name,
      :ensure => :installed,
      :provider => 'dnf'
    )
  end

  let(:provider) do
    provider = provider_class.new
    provider.resource = resource
    provider
  end

  before do
    provider_class.stubs(:command).with(:cmd).returns('/usr/bin/dnf')
    provider.stubs(:rpm).returns 'rpm'
    provider.stubs(:get).with(:version).returns '1'
    provider.stubs(:get).with(:release).returns '1'
    provider.stubs(:get).with(:arch).returns 'i386'
  end

  describe 'provider features' do
    it { is_expected.to be_versionable }
    it { is_expected.to be_install_options }
    it { is_expected.to be_virtual_packages }
  end

  describe "default provider" do
    before do
      Facter.expects(:value).with(:operatingsystem).returns("fedora")
    end

    it "should be the default provider on Fedora 22" do
      Facter.expects(:value).with(:operatingsystemmajrelease).returns('22')
      expect(described_class.default?).to be_truthy
    end

    it "should be the default provider on Fedora 23" do
      Facter.expects(:value).with(:operatingsystemmajrelease).returns('23')
      expect(described_class.default?).to be_truthy
    end
  end

  # provider should repond to the following methods
   [:install, :latest, :update, :purge, :install_options].each do |method|
     it "should have a(n) #{method}" do
       expect(provider).to respond_to(method)
    end
  end

  describe 'when installing' do
    before(:each) do
      Puppet::Util.stubs(:which).with("rpm").returns("/bin/rpm")
      provider.stubs(:which).with("rpm").returns("/bin/rpm")
      Puppet::Util::Execution.expects(:execute).with(["/bin/rpm", "--version"], {:combine => true, :custom_environment => {}, :failonfail => true}).returns("4.10.1\n").at_most_once
      Facter.stubs(:value).with(:operatingsystemmajrelease).returns('22')
    end

    it 'should call dnf install for :installed' do
      resource.stubs(:should).with(:ensure).returns :installed
      Puppet::Util::Execution.expects(:execute).with(['/usr/bin/dnf', '-d', '0', '-e', '1', '-y', :install, 'mypackage'])
      provider.install
    end

    it 'should be able to downgrade' do
      current_version = '1.2'
      version = '1.0'
      resource[:ensure] = '1.0'
      Puppet::Util::Execution.expects(:execute).with(['/usr/bin/dnf', '-d', '0', '-e', '1', '-y', :downgrade, "#{name}-#{version}"])
      provider.stubs(:query).returns(:ensure => current_version).then.returns(:ensure => version)
      provider.install
    end

    it 'should accept install options' do
      resource[:ensure] = :installed
      resource[:install_options] = ['-t', {'-x' => 'expackage'}]

      Puppet::Util::Execution.expects(:execute).with(['/usr/bin/dnf', '-d', '0', '-e', '1', '-y', ['-t', '-x=expackage'], :install, name])
      provider.install
    end
  end

  describe 'when uninstalling' do
    it 'should use erase to purge' do
      Puppet::Util::Execution.expects(:execute).with(['/usr/bin/dnf', '-y', :erase, name])
      provider.purge
    end
  end

  describe "executing yum check-update" do
    it "passes repos to enable to 'yum check-update'" do
      Puppet::Util::Execution.expects(:execute).with do |args, *rest|
        expect(args).to eq %w[/usr/bin/dnf check-update --enablerepo=updates --enablerepo=fedoraplus]
      end.returns(stub(:exitstatus => 0))
      described_class.check_updates(%w[updates fedoraplus], [], [])
    end
  end
end
```

So, what we can do is take all the tests from the yum spec, and turn them into a shared_example, which is exactly what I did:

```
shared_examples "RHEL package provider" do |provider_class, provider_name|
  describe provider_name do

    let(:name) { 'mypackage' }
    let(:resource) do
      Puppet::Type.type(:package).new(
        :name     => name,
        :ensure   => :installed,
        :provider => provider_name
      )
    end
    let(:provider) do
      provider = provider_class.new
      provider.resource = resource
      provider
    end
    let(:arch) { 'x86_64' }
    let(:arch_resource) do
      Puppet::Type.type(:package).new(
        :name     => "#{name}.#{arch}",
        :ensure   => :installed,
        :provider => provider_name
      )
    end
    let(:arch_provider) do
      provider = provider_class.new
      provider.resource = arch_resource
      provider
    end

    case provider_name
    when 'yum'
      let(:error_level) { '0' }
    when 'dnf'
      let(:error_level) { '1' }
    when 'tdnf'
      let(:error_level) { '1' }
    end

    case provider_name
    when 'yum'
      let(:upgrade_command) { 'update' }
    when 'dnf'
      let(:upgrade_command) { 'upgrade' }
    when 'tdnf'
      let(:upgrade_command) { 'upgrade' }
    end

    before do
      provider_class.stubs(:command).with(:cmd).returns("/usr/bin/#{provider_name}")
      provider.stubs(:rpm).returns 'rpm'
      provider.stubs(:get).with(:version).returns '1'
      provider.stubs(:get).with(:release).returns '1'
      provider.stubs(:get).with(:arch).returns 'i386'
    end
    describe 'provider features' do
      it { is_expected.to be_versionable }
      it { is_expected.to be_install_options }
      it { is_expected.to be_virtual_packages }
    end
    # provider should repond to the following methods
     [:install, :latest, :update, :purge, :install_options].each do |method|
       it "should have a(n) #{method}" do
         expect(provider).to respond_to(method)
      end
    end
    describe 'when installing' do
      before(:each) do
        Puppet::Util.stubs(:which).with("rpm").returns("/bin/rpm")
        provider.stubs(:which).with("rpm").returns("/bin/rpm")
        Puppet::Util::Execution.expects(:execute).with(["/bin/rpm", "--version"], {:combine => true, :custom_environment => {}, :failonfail => true}).returns("4.10.1\n").at_most_once
        Facter.stubs(:value).with(:operatingsystemmajrelease).returns('6')
      end
      it "should call #{provider_name} install for :installed" do
        resource.stubs(:should).with(:ensure).returns :installed
        Puppet::Util::Execution.expects(:execute).with(["/usr/bin/#{provider_name}", '-d', '0', '-e', error_level, '-y', :install, 'mypackage'])
        provider.install
      end

      if provider_name == 'yum'
        context 'on el-5' do
          before(:each) do
            Facter.stubs(:value).with(:operatingsystemmajrelease).returns('5')
          end
          it "should catch #{provider_name} install failures when status code is wrong" do
            resource.stubs(:should).with(:ensure).returns :installed
            Puppet::Util::Execution.expects(:execute).with(["/usr/bin/#{provider_name}", '-e', error_level, '-y', :install, name]).returns("No package #{name} available.")
            expect {
              provider.install
            }.to raise_error(Puppet::Error, "Could not find package #{name}")
          end
        end
      end
      it 'should use :install to update' do
        provider.expects(:install)
        provider.update
      end
      it 'should be able to set version' do
        version = '1.2'
        resource[:ensure] = version
        Puppet::Util::Execution.expects(:execute).with(["/usr/bin/#{provider_name}", '-d', '0', '-e', error_level, '-y', :install, "#{name}-#{version}"])
        provider.stubs(:query).returns :ensure => version
        provider.install
      end
      it 'should handle partial versions specified' do
        version = '1.3.4'
        resource[:ensure] = version
        Puppet::Util::Execution.expects(:execute).with(["/usr/bin/#{provider_name}", '-d', '0', '-e', error_level, '-y', :install, 'mypackage-1.3.4'])
        provider.stubs(:query).returns :ensure => '1.3.4-1.el6'
        provider.install
      end
      it 'should be able to downgrade' do
        current_version = '1.2'
        version = '1.0'
        resource[:ensure] = '1.0'

# etc etc
```

As you can see, there's a lot of duplication there between DNF and YUM.

So, I abstracted the tests into a `shared_example`, then in our specs for both `yum` and `dnf` I could simply refer to the shared_example abstraction with `behaves_like`:

```
describe provider_class do
  it_behaves_like 'RHEL package provider', provider_class, 'dnf'
end
```

```
describe provider_class do
  it_behaves_like 'RHEL package provider', provider_class, 'yum'
end
```

All of this, [I did in the PR I did to fix another issue.](https://github.com/puppetlabs/puppet/pull/4973).

Basically a bit of [campsite coding aka. opportunistic refactoring](http://martinfowler.com/bliki/OpportunisticRefactoring.html), in the hopes that this helped someone in the future.

And, strangely enough, it did end up helping someone...

## Helping others

In another PR, a few months after I did that refactoring, [Maggie opened a PR to add the `tdnf` provider to Puppet.](https://github.com/puppetlabs/puppet/pull/5070)

[`tdnf` is the package provider for PhotoOS containers. It's almost virtually identical to `dnf`.](https://github.com/vmware/tdnf/wiki)

So, what's great about that was, for her PR Maggie only had to add the following spec for `tdnf`:

```ruby
require 'spec_helper'

# Note that much of the functionality of the tdnf provider is already tested with yum provider tests,
# as yum is the parent provider, via dnf

provider_class = Puppet::Type.type(:package).provider(:tdnf)

context 'default' do
  it 'should be the default provider on PhotonOS' do
    Facter.stubs(:value).with(:osfamily).returns(:redhat)
    Facter.stubs(:value).with(:operatingsystem).returns("PhotonOS")
    expect(provider_class).to be_default
  end
end

describe provider_class do
  it_behaves_like 'RHEL package provider', provider_class, 'tdnf'
end
```

So instead of a third copy-pasted spec test, that would add to the maintenance cost, she only had to add a few extra lines to the shared_example and reference that in her spec test, plus add a PhotonOS specific test inside there.

## Conclusion

Hopefully this gave you some ideas on DRYing up some of your rspec code with shared_examples.
