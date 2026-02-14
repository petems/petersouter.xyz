+++
author = "Peter Souter"
categories = ["Tech"]
date = 2016-06-09T17:06:00Z
description = "How to test Puppet on Windows machines (particularly Windows 2008/2012) with Beaker, using Bitvise instead of Cygwin"
draft = false
coverImage = "/images/2016/10/108487-1.png"
slug = "testing-windows-puppet-with-beaker"
tags = ["Puppet", "Testing", "Tech", "Beaker", "Windows", "Cygwin"]
title = "Testing Windows with Beaker without Cygwin"

+++

> Edit: I've edited this post a few times since it was originally written in November, but now everything's all dandy and working I thought I'd republish it as a new post!

## Testing Puppet on Windows

So as someone who's been doing way more work on Windows recently,  I've become super interested in how to do systems acceptance testing on Windows.

I ended up pairing with Liam at the Contributor Summit at  Config Management Camp 2015 about this, as Liam's behind a lot of the original work to get cygwin-less Beaker working for testing. Go read [his](http://tech.opentable.co.uk/blog/2014/04/04/testing-puppet-with-beaker/) [blog](http://tech.opentable.co.uk/blog/2014/09/01/testing-puppet-with-beaker-pt-dot-2-the-windows-story/) [posts](http://tech.opentable.co.uk/blog/2014/09/01/testing-puppet-with-beaker-pt-dot-3-testing-roles/) over on the OpenTable, he knows way more about the background than I do!

So, there were just a few cygwin Windows hold-overs that were left that were causing some issues.

A few pull-requests later at the contributor summit, and we got Beaker working with the OpenTable Windows VM's, which have Bitvise installed on them already. So basically, as long as Vagrant had a way to ssh onto the machine and be in a Powershell like environment, the tests would work.

The main canary we were using was the [windows_feature](https://github.com/voxpupuli/puppet-windowsfeature) module, which was the inspiration to enable cygwin-less Windows testing, as it was literally impossible to test with cygwin:

> Installing Windows features requires elevated permissions. What this meant is that when Beaker attempted to SSH into our Windows box and our Puppet module ran its underlying PowerShell we were faced with a harsh and non-descriptive “Access is denied error”.

&mdash;<cite>http://tech.opentable.co.uk/blog/2014/09/01/testing-puppet-with-beaker-pt-dot-2-the-windows-story/</cite>

The [windows_feature](https://github.com/puppet-community/puppet-windowsfeature/) module has a pretty simple set of tests that looks like this:

```ruby
require 'spec_helper_acceptance'

describe 'windowsfeature' do
  context 'windows feature should be installed' do
    it 'should install .net 3.5 feature' do

      pp = <<-PP
        windowsfeature { 'as-net-framework': }
      PP

      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    describe windows_feature('as-net-framework') do
      it { should be_installed.by('powershell') }
    end
  end
end
```

Pretty simple test, but we can actually refactor it further:
```ruby
apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
```

can be translated to:

```ruby
apply_manifest(pp, :catch_failures => true)
apply_manifest(pp, :catch_changes  => true)
```

There's also the issue that some Windows boxes might have [out-dated SSL certificates](http://security.stackexchange.com/questions/76189/why-does-windows-ship-with-expired-ssl-certificates), meaning that you get an SSL fail when trying to install modules from the forge.

You can solve this with some code that looks like this:

```ruby
GEOTRUST_GLOBAL_CA = <<-EOM
-----BEGIN CERTIFICATE-----
MIIDVDCCAjygAwIBAgIDAjRWMA0GCSqGSIb3DQEBBQUAMEIxCzAJBgNVBAYTAlVT
MRYwFAYDVQQKEw1HZW9UcnVzdCBJbmMuMRswGQYDVQQDExJHZW9UcnVzdCBHbG9i
YWwgQ0EwHhcNMDIwNTIxMDQwMDAwWhcNMjIwNTIxMDQwMDAwWjBCMQswCQYDVQQG
EwJVUzEWMBQGA1UEChMNR2VvVHJ1c3QgSW5jLjEbMBkGA1UEAxMSR2VvVHJ1c3Qg
R2xvYmFsIENBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA2swYYzD9
9BcjGlZ+W988bDjkcbd4kdS8odhM+KhDtgPpTSEHCIjaWC9mOSm9BXiLnTjoBbdq
fnGk5sRgprDvgOSJKA+eJdbtg/OtppHHmMlCGDUUna2YRpIuT8rxh0PBFpVXLVDv
iS2Aelet8u5fa9IAjbkU+BQVNdnARqN7csiRv8lVK83Qlz6cJmTM386DGXHKTubU
1XupGc1V3sjs0l44U+VcT4wt/lAjNvxm5suOpDkZALeVAjmRCw7+OC7RHQWa9k0+
bw8HHa8sHo9gOeL6NlMTOdReJivbPagUvTLrGAMoUgRx5aszPeE4uwc2hGKceeoW
MPRfwCvocWvk+QIDAQABo1MwUTAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBTA
ephojYn7qwVkDBF9qn1luMrMTjAfBgNVHSMEGDAWgBTAephojYn7qwVkDBF9qn1l
uMrMTjANBgkqhkiG9w0BAQUFAAOCAQEANeMpauUvXVSOKVCUn5kaFOSPeCpilKIn
Z57QzxpeR+nBsqTP3UEaBU6bS+5Kb1VSsyShNwrrZHYqLizz/Tt1kL/6cdjHPTfS
tQWVYrmm3ok9Nns4d0iXrKYgjy6myQzCsplFAMfOEVEiIuCl6rYVSAlk6l5PdPcF
PseKUgzbFbS9bZvlxrFUaKnjaZC2mqUPuLk/IH2uSrW4nOQdtqvmlKXBx4Ot2/Un
hw4EbNX/3aBd7YdStysVAq45pmp06drE57xNNB6pXE0zX5IJL4hmXXeXxx12E6nV
5fEWCRE11azbJHFwLJhWC9kXtNHjUStedejV0NxPNO3CBWaAocvmMw==
-----END CERTIFICATE-----
EOM

create_remote_file(host, 'C:\Windows\Temp\geotrustglobal.pem', GEOTRUST_GLOBAL_CA)
on host, 'cmd /c certutil -v -addstore Root C:\Windows\Temp\geotrustglobal.pem'
```

However, Liam went the extra mile and turned this into a helper method, so you can just do this with a simpler `install_cert_on_windows` method:

```ruby
GEOTRUST_GLOBAL_CA = <<-EOM
-----BEGIN CERTIFICATE-----
MIIDVDCCAjygAwIBAgIDAjRWMA0GCSqGSIb3DQEBBQUAMEIxCzAJBgNVBAYTAlVT
MRYwFAYDVQQKEw1HZW9UcnVzdCBJbmMuMRswGQYDVQQDExJHZW9UcnVzdCBHbG9i
YWwgQ0EwHhcNMDIwNTIxMDQwMDAwWhcNMjIwNTIxMDQwMDAwWjBCMQswCQYDVQQG
EwJVUzEWMBQGA1UEChMNR2VvVHJ1c3QgSW5jLjEbMBkGA1UEAxMSR2VvVHJ1c3Qg
R2xvYmFsIENBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA2swYYzD9
9BcjGlZ+W988bDjkcbd4kdS8odhM+KhDtgPpTSEHCIjaWC9mOSm9BXiLnTjoBbdq
fnGk5sRgprDvgOSJKA+eJdbtg/OtppHHmMlCGDUUna2YRpIuT8rxh0PBFpVXLVDv
iS2Aelet8u5fa9IAjbkU+BQVNdnARqN7csiRv8lVK83Qlz6cJmTM386DGXHKTubU
1XupGc1V3sjs0l44U+VcT4wt/lAjNvxm5suOpDkZALeVAjmRCw7+OC7RHQWa9k0+
bw8HHa8sHo9gOeL6NlMTOdReJivbPagUvTLrGAMoUgRx5aszPeE4uwc2hGKceeoW
MPRfwCvocWvk+QIDAQABo1MwUTAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBTA
ephojYn7qwVkDBF9qn1luMrMTjAfBgNVHSMEGDAWgBTAephojYn7qwVkDBF9qn1l
uMrMTjANBgkqhkiG9w0BAQUFAAOCAQEANeMpauUvXVSOKVCUn5kaFOSPeCpilKIn
Z57QzxpeR+nBsqTP3UEaBU6bS+5Kb1VSsyShNwrrZHYqLizz/Tt1kL/6cdjHPTfS
tQWVYrmm3ok9Nns4d0iXrKYgjy6myQzCsplFAMfOEVEiIuCl6rYVSAlk6l5PdPcF
PseKUgzbFbS9bZvlxrFUaKnjaZC2mqUPuLk/IH2uSrW4nOQdtqvmlKXBx4Ot2/Un
hw4EbNX/3aBd7YdStysVAq45pmp06drE57xNNB6pXE0zX5IJL4hmXXeXxx12E6nV
5fEWCRE11azbJHFwLJhWC9kXtNHjUStedejV0NxPNO3CBWaAocvmMw==
-----END CERTIFICATE-----
EOM

install_cert_on_windows(host, 'geotrust', GEOTRUST_GLOBAL_CA)
```

For a while it was hard to keep cadence with the rapid releases of Beaker and make sure the non-cygwin logic was working. For a while we were pinning to forked versions of the Gems:

```ruby
gem "beaker",
    :git => 'https://github.com/petems/beaker-windows.git',
    :ref => '38227e3bec946dbd52ac4aece8d28af360a33cc4'
gem "beaker-rspec",
    :git => 'https://github.com/petems/beaker-rspec-windows.git',
    :ref => 'd96cff5fc937efe1dca03c6ea3c236bf4c7337ab'
```

Obviously this is kinda bad, as it led to a maintence headache as we've basically got code that will be out of date with upstream, and it'll be hard to rebase with any new features. But it was a workaround until we could cherry-pick the changes back upstream.

After that I was engaged on other projects and lost track of things, until a tweet popped up to remind me:

<blockquote class="twitter-tweet" lang="en"><p lang="en" dir="ltr"><a href="https://twitter.com/liamjbennett">@liamjbennett</a> Any pointers or examples for using <a href="https://twitter.com/hashtag/Beaker?src=hash">#Beaker</a> with Windows? I&#39;m trying to use <a href="https://twitter.com/puppetlabs">@Puppetlabs</a> 2.30.1, and it&#39;s been a rough ride.</p>&mdash; Sparrow (@Sparrow9of8) <a href="https://twitter.com/Sparrow9of8/status/674628614432813058">December 9, 2015</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

Josh was super helpful in getting a few of the main issues fixed, particularly the serverspec tests that required WinRM working. So thank you for that Josh!

But they were still on the fork, and I was still busy so it dropped to the bottom of my to-do list...

## Someone picks up the mantle!

Eventually, James picked up the mantle, squashed mine and Josh's commits into a nice PR and submitted it back.

https://github.com/puppetlabs/beaker/pull/1113

Followed by Oskar doing the same for Beaker-rspec:

https://github.com/puppetlabs/beaker-rspec/pull/77

## The Proof in the Pudding:

So now both were merged in and tagged, I could just update the Gemfile to pin to the specific tags in the Windows feature module:

```ruby
group :system_tests do
  gem 'winrm', '1.8.1'
  gem 'beaker', '2.43.0'
  gem 'beaker-rspec', '5.3.0'
  gem 'beaker-puppet_install_helper',  :require => false
end
```

Then run the acceptance tests and see if it worked...

```bash
bundle exec rake acceptance
/opt/rubies/2.0.0-p451/bin/ruby -I/opt/rubies/2.0.0-p451/lib/ruby/gems/2.0.0/gems/rspec-core-3.4.4/lib:/opt/rubies/2.0.0-p451/lib/ruby/gems/2.0.0/gems/rspec-support-3.4.1/lib /opt/rubies/2.0.0-p451/lib/ruby/gems/2.0.0/gems/rspec-core-3.4.4/exe/rspec spec/acceptance
/opt/rubies/2.0.0-p451/lib/ruby/gems/2.0.0/gems/beaker-rspec-5.4.0/lib/beaker-rspec/helpers/serverspec.rb:43: warning: already initialized constant Module::VALID_OPTIONS_KEYS
/opt/rubies/2.0.0-p451/lib/ruby/gems/2.0.0/gems/specinfra-2.59.0/lib/specinfra/configuration.rb:4: warning: previous definition of VALID_OPTIONS_KEYS was here
Hypervisor for win-2012R2-std is vagrant
Beaker::Hypervisor, found some vagrant boxes to create
==> win-2012R2-std: VM not created. Moving on...
created Vagrantfile for VagrantHost win-2012R2-std
Bringing machine 'win-2012R2-std' up with 'virtualbox' provider...
==> win-2012R2-std: vagrant-r10k not configured; skipping
==> win-2012R2-std: Importing base box 'opentable/win-2012r2-standard-amd64-nocm'...
Progress: 10%Progress: 90%==> win-2012R2-std: Matching MAC address for NAT networking...
==> win-2012R2-std: Checking if box 'opentable/win-2012r2-standard-amd64-nocm' is up to date...
==> win-2012R2-std: Setting the name of the VM: defaultyml_win-2012R2-std_1465485759479_33932
==> win-2012R2-std: vagrant-r10k not configured; skipping
==> win-2012R2-std: vagrant-r10k not configured; skipping
==> win-2012R2-std: vagrant-r10k not configured; skipping
==> win-2012R2-std: Clearing any previously set network interfaces...
==> win-2012R2-std: Preparing network interfaces based on configuration...
    win-2012R2-std: Adapter 1: nat
    win-2012R2-std: Adapter 2: hostonly
==> win-2012R2-std: Forwarding ports...
    win-2012R2-std: 22 (guest) => 2222 (host) (adapter 1)
    win-2012R2-std: 3389 (guest) => 3389 (host) (adapter 1)
    win-2012R2-std: 5985 (guest) => 5985 (host) (adapter 1)
    win-2012R2-std: 5986 (guest) => 55986 (host) (adapter 1)
==> win-2012R2-std: Running 'pre-boot' VM customizations...
==> win-2012R2-std: Booting VM...
==> win-2012R2-std: Waiting for machine to boot. This may take a few minutes...
    win-2012R2-std: WinRM address: 127.0.0.1:5985
    win-2012R2-std: WinRM username: vagrant
    win-2012R2-std: WinRM execution_time_limit: PT2H
    win-2012R2-std: WinRM transport: plaintext
==> win-2012R2-std: Machine booted and ready!
==> win-2012R2-std: Checking for guest additions in VM...
    win-2012R2-std: The guest additions on this VM do not match the installed version of
    win-2012R2-std: VirtualBox! In most cases this is fine, but in rare cases it can
    win-2012R2-std: prevent things such as shared folders from working properly. If you see
    win-2012R2-std: shared folder errors, please make sure the guest additions within the
    win-2012R2-std: virtual machine match the version of VirtualBox you have installed on
    win-2012R2-std: your host and reload your VM.
    win-2012R2-std:
    win-2012R2-std: Guest Additions Version: 4.3.12
    win-2012R2-std: VirtualBox Version: 5.0
==> win-2012R2-std: Setting hostname...
==> win-2012R2-std: Configuring and enabling network interfaces...
==> win-2012R2-std: Mounting shared folders...
    win-2012R2-std: /vagrant => /Users/petersouter/projects/voxpupuli-windowsfeature/.vagrant/beaker_vagrant_files/default.yml
configure vagrant boxes (set ssh-config, switch to root user, hack etc/hosts)
Give root a copy of current user's keys, on win-2012R2-std

win-2012R2-std 16:24:27$ if exist .ssh (xcopy .ssh C:\Users\Administrator\.ssh /s /e)
  Attempting ssh connection to 10.255.33.129, user: vagrant, opts: {:config=>"/var/folders/nn/408ddhln26s1b356ry19q6yr0000gp/T/win-2012R2-std20160609-75482-1yi5prh"}

win-2012R2-std executed in 1.59 seconds
Update /etc/ssh/sshd_config to allow root login
Warning: Attempting to enable root login non-supported platform: win-2012R2-std: windows-server-amd64
Warning: Attempting to update ssh on non-supported platform: win-2012R2-std: windows-server-amd64
Warning: ssh connection to win-2012R2-std has been terminated

win-2012R2-std 16:24:34$ type C:\Windows\System32\drivers\etc\hosts
  Attempting ssh connection to 10.255.33.129, user: vagrant, opts: {:config=>"/var/folders/nn/408ddhln26s1b356ry19q6yr0000gp/T/win-2012R2-std20160609-75482-19ije0y"}
  # Copyright (c) 1993-2009 Microsoft Corp.
  #
  # This is a sample HOSTS file used by Microsoft TCP/IP for Windows.
  #
  # This file contains the mappings of IP ad  dresses to host names. Each
  # entry should be kept on an individual line. The IP address should
  # be placed in the first column followed by the corresponding   host name.
  # The IP address and the host name should be separated by at least one
  # space.
  #
  # Additionally, comments (such as these) may be inserted on individual
  # lines or following th  e machine name denoted by a '#' symbol.
  #
  # For example:
  #
  #      102.54.94.97     rhino.acme.com          # source server
  #       38.25.63.10     x.acme.com              # x client host

  # localhost name resolution is handled within   DNS itself.
  #	127.0.0.1       localhost
  #	::1             localhost

win-2012R2-std executed in 1.15 seconds

win-2012R2-std 16:24:35$ echo '127.0.0.1	localhost localhost.localdomain
10.255.33.129	win-2012R2-std. win-2012R2-std
' >> C:\Windows\System32\drivers\etc\hosts
  '127.0.0.1	localhost localhost.localdomain

win-2012R2-std executed in 0.38 seconds
setting local environment on win-2012R2-std

win-2012R2-std 16:24:35$ echo "C:\Program Files (x86)\Puppet Labs\Puppet\bin";"C:\Program Files\Puppet Labs\Puppet\bin"
  "C:\Program Files (x86)\Puppet Labs\Puppet\bin";"C:\Program Files\Puppet Labs\Puppet\bin"

win-2012R2-std executed in 0.04 seconds

win-2012R2-std 16:24:35$ echo C:\opt\puppet-git-repos\hiera\bin
  C:\opt\puppet-git-repos\hiera\bin

win-2012R2-std executed in 0.02 seconds
Warning: ssh connection to win-2012R2-std has been terminated

win-2012R2-std 16:24:35$ set PATH
  Attempting ssh connection to 10.255.33.129, user: vagrant, opts: {:config=>"/var/folders/nn/408ddhln26s1b356ry19q6yr0000gp/T/win-2012R2-std20160609-75482-19ije0y", :user=>"vagrant"}
  Path=C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0\
  PATHEXT=.COM;.EXE;.BAT;.CMD;.VBS;.VBE;.JS;.JSE;.WSF;.WSH;.MSC

win-2012R2-std executed in 0.05 seconds

win-2012R2-std 16:24:35$ powershell.exe -ExecutionPolicy Bypass -InputFormat None -NoLogo -NoProfile -NonInteractive -Command [Environment]::SetEnvironmentVariable('PATH', '"C:\Program Files (x86)\Puppet Labs\Puppet\bin";"C:\Program Files\Puppet Labs\Puppet\bin";C:\opt\puppet-git-repos\hiera\bin;C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0\', 'Machine')

win-2012R2-std executed in 0.62 seconds
Warning: ssh connection to win-2012R2-std has been terminated

win-2012R2-std 16:24:36$ set PATH
  Attempting ssh connection to 10.255.33.129, user: vagrant, opts: {:config=>"/var/folders/nn/408ddhln26s1b356ry19q6yr0000gp/T/win-2012R2-std20160609-75482-19ije0y", :user=>"vagrant"}
  Path=C:\Program Files (x86)\Puppet Labs\Puppet\bin;C:\Program Files\Puppet Labs\Puppet\bin;C:\opt\puppet-git-repos\hiera\bin;C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0\
  PATHEXT=.COM;.EXE;.BAT;.CMD;.VBS;.VBE;.JS;.JSE;.WSF;.WSH;.MSC

win-2012R2-std executed in 0.04 seconds

win-2012R2-std 16:24:36$ powershell.exe -ExecutionPolicy Bypass -InputFormat None -NoLogo -NoProfile -NonInteractive -Command [Environment]::SetEnvironmentVariable('PATH', 'PATH;C:\Program Files (x86)\Puppet Labs\Puppet\bin;C:\Program Files\Puppet Labs\Puppet\bin;C:\opt\puppet-git-repos\hiera\bin;C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0\', 'Machine')

win-2012R2-std executed in 0.19 seconds
Warning: ssh connection to win-2012R2-std has been terminated

win-2012R2-std 16:24:36$ SET
  Attempting ssh connection to 10.255.33.129, user: vagrant, opts: {:config=>"/var/folders/nn/408ddhln26s1b356ry19q6yr0000gp/T/win-2012R2-std20160609-75482-19ije0y", :user=>"vagrant"}
  ALLUSERSPROFILE=C:\ProgramData
  APPDATA=C:\Users\vagrant\AppData\Roaming
  CommonProgramFiles=C:\Program Files\Common Files
  CommonProgramFiles(x86)=C:\Program Files (x86)\Common Files
  CommonProgramW6432=C:\Program Files\Common Files
  COMPUTERNAME=WIN-2012R2-STD
  ComSpec=C:\Windows\system32\cmd.exe
  FP_NO_HOST_CHECK=NO
  HOME=C:\Users\vagrant
  HOMEDRIVE=C:
  HOMEPATH=\Users\vagrant
  LOCALAPPDATA=C:\Users\vagrant\AppData\Local
  LOGONSERVER=\\WIN-2012R2-STD
  NUMBER_OF_PROCESSORS=1
  OS=Windows_NT
  Path=PATH;C:\Program Files (x86)\Puppet Labs\Puppet\bin;C:\Program Files\Puppet Labs\Puppet\bin;C:\opt\puppet-git-repos\hiera\bin;C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0\
  PATHEXT=.COM;.EXE;.BAT;.CMD;.VBS;.VBE;.JS;.JSE;.WSF;.WSH;.MSC
  PROCESSOR_ARCHITECTURE=AMD64
  PROCESSOR_IDENTIFIER=Intel64 Family 6 Model 70 Stepping 1, GenuineIntel
  PROCESSOR_LEVEL=6
  PROCESSOR_REVISION=4601
  ProgramData=C:\ProgramData
  ProgramFiles=C:\Program Files
  ProgramFiles(x86)=C:\Program Files (x86)
  ProgramW6432=C:\Program Files
  PROMPT=$P$G
  PSModulePath=C:\Windows\system32\WindowsPowerShell\v1.0\Modules\
  PUBLIC=C:\Users\Public
  SSH_CLIENT=10.0.2.2 51723 22
  SSH_CONNECTION=10.0.2.2 51723 10.0.2.15 22
  SSHSESSIONID=1005
  SSHWINGROUP=EVERYONE
  SystemDrive=C:
  SystemRoot=C:\Windows
  TEMP=C:\Users\vagrant\AppData\Local\Temp
  TMP=C:\Users\vagrant\AppData\Local\Temp
  USERDOMAIN=WIN-2012R2-STD
  USERDOMAIN_ROAMINGPROFILE=WIN-2012R2-STD
  USERNAME=vagrant
  USERPROFILE=C:\Users\vagrant
  windir=C:\Windows
  WINSSHDGROUP=EVERYONE

win-2012R2-std executed in 0.05 seconds
Disabling updates.puppetlabs.com by modifying hosts file to resolve updates to 127.0.0.1 on win-2012R2-std

win-2012R2-std 16:24:36$ echo '127.0.0.1	updates.puppetlabs.com
' >> C:\Windows\System32\drivers\etc\hosts
  '127.0.0.1	updates.puppetlabs.com

win-2012R2-std executed in 0.02 seconds

win-2012R2-std 16:24:37$ wmic os get osarchitecture
  OSArchitecture
  64-bit


win-2012R2-std executed in 0.25 seconds

win-2012R2-std 16:24:37$ powershell.exe -ExecutionPolicy Bypass -InputFormat None -NoLogo -NoProfile -NonInteractive -Command $webclient = New-Object System.Net.WebClient;  $webclient.DownloadFile('http://downloads.puppetlabs.com/windows/puppet-3.8.3-x64.msi','C:\Windows\Temp\puppet-3.8.3-x64.msi')

win-2012R2-std executed in 19.42 seconds

win-2012R2-std 16:24:56$ cmd.exe /c sc query BvSshServer

  SERVICE_NAME: BvSshServer
          TYPE               : 10  WIN32_OWN_PROCESS
          STATE              : 4  RUNNING
                                  (STOPPABLE, NOT_PAUSABLE, ACCEPTS_PRESHUTDOWN)
          WIN32_EXIT_CODE    : 0  (0x0)
          SERVICE_EXIT_CODE  : 0  (0x0)
          CHECKPOINT         : 0x0
          WAIT_HINT          : 0x0

win-2012R2-std executed in 0.10 seconds
windows.rb:determine_ssh_server: determined ssh server: 'bitvise'
localhost $ scp /var/folders/nn/408ddhln26s1b356ry19q6yr0000gp/T/install-puppet-msi-2016-06-09_16.24.56.bat20160609-75482-128vtd8 win-2012R2-std:C:/Windows/Temp/install-puppet-msi-2016-06-09_16.24.56.bat {:ignore => }

win-2012R2-std 16:24:57$ "C:\Windows\Temp/install-puppet-msi-2016-06-09_16.24.56.bat"

  C:\Users\vagrant>  start /w msiexec.exe /i "C:\Windows\Temp\puppet-3.8.3-x64.msi" /qn /L*V C:\Windows\Temp\install-puppet-2016-06-09_16.24.56.log PUPPET_AGENT_STARTUP_MODE=Manual

  C:\Users\vagrant>  exit /B 0

win-2012R2-std executed in 6.78 seconds
Warning: ssh connection to win-2012R2-std has been terminated

win-2012R2-std 16:25:03$ sc query puppet || sc query pe-puppet
  Attempting ssh connection to 10.255.33.129, user: vagrant, opts: {:config=>"/var/folders/nn/408ddhln26s1b356ry19q6yr0000gp/T/win-2012R2-std20160609-75482-19ije0y", :user=>"vagrant"}

  SERVICE_NAME: puppet
          TYPE               : 10  WIN32_OWN_PROCESS
          STATE              : 1  STOPPED
          WIN32_EXIT_CODE    : 1077  (0x435)
          SERVICE_EXIT_CODE  : 0  (0x0)
          CHECKPOINT         : 0x0
          WAIT_HINT          : 0x0

win-2012R2-std executed in 0.17 seconds

win-2012R2-std 16:25:04$ if exist "%ProgramFiles%\Puppet Labs\puppet\misc\versions.txt" type "%ProgramFiles%\Puppet Labs\puppet\misc\versions.txt"

win-2012R2-std executed in 0.01 seconds

win-2012R2-std 16:25:04$ if exist "%ProgramFiles(x86)%\Puppet Labs\puppet\misc\versions.txt" type "%ProgramFiles(x86)%\Puppet Labs\puppet\misc\versions.txt"

win-2012R2-std executed in 0.03 seconds

win-2012R2-std 16:25:04$ echo "C:\Program Files (x86)\Puppet Labs\Puppet\bin";"C:\Program Files\Puppet Labs\Puppet\bin"
  "C:\Program Files (x86)\Puppet Labs\Puppet\bin";"C:\Program Files\Puppet Labs\Puppet\bin"

win-2012R2-std executed in 0.02 seconds

win-2012R2-std 16:25:04$ echo C:\opt\puppet-git-repos\hiera\bin
  C:\opt\puppet-git-repos\hiera\bin

win-2012R2-std executed in 0.02 seconds
Warning: ssh connection to win-2012R2-std has been terminated

win-2012R2-std 16:25:04$ set PATH
  Attempting ssh connection to 10.255.33.129, user: vagrant, opts: {:config=>"/var/folders/nn/408ddhln26s1b356ry19q6yr0000gp/T/win-2012R2-std20160609-75482-19ije0y", :user=>"vagrant"}
  Path=PATH;C:\Program Files (x86)\Puppet Labs\Puppet\bin;C:\Program Files\Puppet Labs\Puppet\bin;C:\opt\puppet-git-repos\hiera\bin;C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0\
  PATHEXT=.COM;.EXE;.BAT;.CMD;.VBS;.VBE;.JS;.JSE;.WSF;.WSH;.MSC

win-2012R2-std executed in 0.04 seconds
Warning: ssh connection to win-2012R2-std has been terminated

win-2012R2-std 16:25:04$ set PATH
  Attempting ssh connection to 10.255.33.129, user: vagrant, opts: {:config=>"/var/folders/nn/408ddhln26s1b356ry19q6yr0000gp/T/win-2012R2-std20160609-75482-19ije0y", :user=>"vagrant"}
  Path=PATH;C:\Program Files (x86)\Puppet Labs\Puppet\bin;C:\Program Files\Puppet Labs\Puppet\bin;C:\opt\puppet-git-repos\hiera\bin;C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0\
  PATHEXT=.COM;.EXE;.BAT;.CMD;.VBS;.VBE;.JS;.JSE;.WSF;.WSH;.MSC

win-2012R2-std executed in 0.03 seconds

win-2012R2-std 16:25:04$ if not exist C:\ProgramData\PuppetLabs\puppet\etc\modules (md C:\ProgramData\PuppetLabs\puppet\etc\modules)

win-2012R2-std executed in 0.02 seconds

win-2012R2-std 16:25:04$ echo "C:\Program Files (x86)\Puppet Labs\Puppet\bin";"C:\Program Files\Puppet Labs\Puppet\bin"
  "C:\Program Files (x86)\Puppet Labs\Puppet\bin";"C:\Program Files\Puppet Labs\Puppet\bin"

win-2012R2-std executed in 0.02 seconds

win-2012R2-std 16:25:04$ echo C:\opt\puppet-git-repos\hiera\bin
  C:\opt\puppet-git-repos\hiera\bin

win-2012R2-std executed in 0.02 seconds
Warning: ssh connection to win-2012R2-std has been terminated

win-2012R2-std 16:25:04$ set PATH
  Attempting ssh connection to 10.255.33.129, user: vagrant, opts: {:config=>"/var/folders/nn/408ddhln26s1b356ry19q6yr0000gp/T/win-2012R2-std20160609-75482-19ije0y", :user=>"vagrant"}
  Path=PATH;C:\Program Files (x86)\Puppet Labs\Puppet\bin;C:\Program Files\Puppet Labs\Puppet\bin;C:\opt\puppet-git-repos\hiera\bin;C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0\
  PATHEXT=.COM;.EXE;.BAT;.CMD;.VBS;.VBE;.JS;.JSE;.WSF;.WSH;.MSC

win-2012R2-std executed in 0.05 seconds
Warning: ssh connection to win-2012R2-std has been terminated

win-2012R2-std 16:25:04$ set PATH
  Attempting ssh connection to 10.255.33.129, user: vagrant, opts: {:config=>"/var/folders/nn/408ddhln26s1b356ry19q6yr0000gp/T/win-2012R2-std20160609-75482-19ije0y", :user=>"vagrant"}
  Path=PATH;C:\Program Files (x86)\Puppet Labs\Puppet\bin;C:\Program Files\Puppet Labs\Puppet\bin;C:\opt\puppet-git-repos\hiera\bin;C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0\
  PATHEXT=.COM;.EXE;.BAT;.CMD;.VBS;.VBE;.JS;.JSE;.WSF;.WSH;.MSC

win-2012R2-std executed in 0.04 seconds

win-2012R2-std 16:25:04$ if not exist "C:\Program Files (x86)\Puppet Labs\Puppet\etc";"C:\Program Files\Puppet Labs\Puppet\etc" (md "C:\Program Files (x86)\Puppet Labs\Puppet\etc";"C:\Program Files\Puppet Labs\Puppet\etc")
  '"C:\Program Files\Puppet Labs\Puppet\etc"' is not recognized as an internal or external command,
  operable program or batch file.

win-2012R2-std executed in 0.03 seconds
Exited: 1
localhost $ scp /var/folders/nn/408ddhln26s1b356ry19q6yr0000gp/T/beaker20160609-75482-o7x4jl win-2012R2-std:C:/Windows/Temp/geotrustglobal.pem {:ignore => }

win-2012R2-std 16:25:04$ certutil -v -addstore Root C:\Windows\Temp\geotrustglobal.pem
  Root "Trusted Root Certification Authorities"
  Signature matches Public Key
  Certificate "GeoTrust Global CA" added to store.
  CertUtil: -addstore command completed successfully.

win-2012R2-std executed in 0.92 seconds

win-2012R2-std 16:25:05$ puppet module install puppetlabs-stdlib
  Notice: Preparing to install into C:/ProgramData/PuppetLabs/puppet/etc/modules ...
  Notice: Downloading from https://forgeapi.puppetlabs.com ...
  Notice: Installing -- do not interrupt ...
  C:/ProgramData/PuppetLabs/puppet/etc/modules
  └── puppetlabs-stdlib (v4.12.0)

win-2012R2-std executed in 11.27 seconds

win-2012R2-std 16:25:16$ echo C:\ProgramData\PuppetLabs\puppet\etc\modules
  C:\ProgramData\PuppetLabs\puppet\etc\modules

win-2012R2-std executed in 0.03 seconds
Using scp to transfer /Users/petersouter/projects/voxpupuli-windowsfeature to C:\ProgramData\PuppetLabs\puppet\etc\modules\windowsfeature
localhost $ scp /Users/petersouter/projects/voxpupuli-windowsfeature win-2012R2-std:C:/ProgramData/PuppetLabs/puppet/etc/modules {:ignore => [".bundle", ".git", ".idea", ".vagrant", ".vendor", "vendor", "acceptance", "bundle", "spec", "tests", "log", ".", ".."]}
going to ignore (?-mix:((\/|\A)\.bundle(\/|\z))|((\/|\A)\.git(\/|\z))|((\/|\A)\.idea(\/|\z))|((\/|\A)\.vagrant(\/|\z))|((\/|\A)\.vendor(\/|\z))|((\/|\A)vendor(\/|\z))|((\/|\A)acceptance(\/|\z))|((\/|\A)bundle(\/|\z))|((\/|\A)spec(\/|\z))|((\/|\A)tests(\/|\z))|((\/|\A)log(\/|\z))|((\/|\A)\.(\/|\z))|((\/|\A)\.\.(\/|\z)))

win-2012R2-std 16:25:17$ del /s /q C:\ProgramData\PuppetLabs\puppet\etc\modules\windowsfeature

win-2012R2-std executed in 0.02 seconds

win-2012R2-std 16:25:17$ move /y C:\ProgramData\PuppetLabs\puppet\etc\modules\voxpupuli-windowsfeature C:\ProgramData\PuppetLabs\puppet\etc\modules\windowsfeature
          1 dir(s) moved.

win-2012R2-std executed in 0.02 seconds

windowsfeature
  lots of features at once

win-2012R2-std 16:25:17$ powershell.exe -ExecutionPolicy Bypass -InputFormat None -NoLogo -NoProfile -NonInteractive -Command [System.IO.Path]::GetTempFileName()
  C:\Users\vagrant\AppData\Local\Temp\tmpDED2.tmp

win-2012R2-std executed in 3.06 seconds
localhost $ scp /var/folders/nn/408ddhln26s1b356ry19q6yr0000gp/T/beaker20160609-75482-p6cd22 win-2012R2-std:C:/Users/vagrant/AppData/Local/Temp/tmpDED2.tmp {:ignore => }

win-2012R2-std 16:25:20$ puppet apply --verbose --detailed-exitcodes C:\Users\vagrant\AppData\Local\Temp\tmpDED2.tmp
  Info: Loading facts
  Notice: Compiled catalog for win-2012r2-std.wireless.local in environment production in 0.06 seconds
  Info: Applying configuration version '1465485928'
  Notice: /Stage[main]/Main/Windowsfeature[Web-Filtering]/ensure: created
  Notice: /Stage[main]/Main/Windowsfeature[Web-Http-Errors]/ensure: created
  Notice: /Stage[main]/Main/Windowsfeature[Web-Net-Ext]/ensure: created
  Notice: /Stage[main]/Main/Windowsfeature[Web-Mgmt-Tools]/ensure: created
  Notice: /Stage[main]/Main/Windowsfeature[Web-ISAPI-Ext]/ensure: created
  Notice: /Stage[main]/Main/Windowsfeature[Web-Default-Doc]/ensure: created
  Notice: /Stage[main]/Main/Windowsfeature[Web-Stat-Compression]/ensure: created
  Notice: /Stage[main]/Main/Windowsfeature[Web-Http-Logging]/ensure: created
  Notice: /Stage[main]/Main/Windowsfeature[Web-Mgmt-Console]/ensure: created
  Notice: /Stage[main]/Main/Windowsfeature[Web-ISAPI-Filter]/ensure: created
  Notice: /Stage[main]/Main/Windowsfeature[Web-Static-Content]/ensure: created
  Notice: /Stage[main]/Main/Windowsfeature[Web-Request-Monitor]/ensure: created
  Notice: /Stage[main]/Main/Windowsfeature[Web-Dyn-Compression]/ensure: created
  Info: Creating state file C:/ProgramData/PuppetLabs/puppet/var/state/state.yaml
  Notice: Finished catalog run in 456.41 seconds

win-2012R2-std executed in 471.46 seconds
Exited: 2

win-2012R2-std 16:33:12$ powershell.exe -ExecutionPolicy Bypass -InputFormat None -NoLogo -NoProfile -NonInteractive -Command [System.IO.Path]::GetTempFileName()
  C:\Users\vagrant\AppData\Local\Temp\tmp1438.tmp

win-2012R2-std executed in 0.69 seconds
localhost $ scp /var/folders/nn/408ddhln26s1b356ry19q6yr0000gp/T/beaker20160609-75482-1xi44kv win-2012R2-std:C:/Users/vagrant/AppData/Local/Temp/tmp1438.tmp {:ignore => }

win-2012R2-std 16:33:13$ puppet apply --verbose --detailed-exitcodes C:\Users\vagrant\AppData\Local\Temp\tmp1438.tmp
  Info: Loading facts
  Notice: Compiled catalog for win-2012r2-std.wireless.local in environment production in 0.08 seconds
  Info: Applying configuration version '1465486402'
  Notice: Finished catalog run in 1.05 seconds

win-2012R2-std executed in 16.23 seconds
    should be installed and not take too long

windowsfeature
  windows feature should be installed

win-2012R2-std 16:33:29$ powershell.exe -ExecutionPolicy Bypass -InputFormat None -NoLogo -NoProfile -NonInteractive -Command [System.IO.Path]::GetTempFileName()
  C:\Users\vagrant\AppData\Local\Temp\tmp5567.tmp

win-2012R2-std executed in 0.21 seconds
localhost $ scp /var/folders/nn/408ddhln26s1b356ry19q6yr0000gp/T/beaker20160609-75482-1tuy6ys win-2012R2-std:C:/Users/vagrant/AppData/Local/Temp/tmp5567.tmp {:ignore => }

win-2012R2-std 16:33:29$ puppet apply --verbose --detailed-exitcodes C:\Users\vagrant\AppData\Local\Temp\tmp5567.tmp
  Info: Loading facts
  Notice: Compiled catalog for win-2012r2-std.wireless.local in environment production in 0.05 seconds
  Info: Applying configuration version '1465486414'
  Notice: /Stage[main]/Main/Windowsfeature[as-net-framework]/ensure: created
  Notice: Finished catalog run in 8.16 seconds

win-2012R2-std executed in 19.48 seconds
Exited: 2

win-2012R2-std 16:33:49$ powershell.exe -ExecutionPolicy Bypass -InputFormat None -NoLogo -NoProfile -NonInteractive -Command [System.IO.Path]::GetTempFileName()
  C:\Users\vagrant\AppData\Local\Temp\tmpA25E.tmp

win-2012R2-std executed in 0.21 seconds
localhost $ scp /var/folders/nn/408ddhln26s1b356ry19q6yr0000gp/T/beaker20160609-75482-shjp4t win-2012R2-std:C:/Users/vagrant/AppData/Local/Temp/tmpA25E.tmp {:ignore => }

win-2012R2-std 16:33:49$ puppet apply --verbose --detailed-exitcodes C:\Users\vagrant\AppData\Local\Temp\tmpA25E.tmp
  Info: Loading facts
  Notice: Compiled catalog for win-2012r2-std.wireless.local in environment production in 0.05 seconds
  Info: Applying configuration version '1465486434'
  Notice: Finished catalog run in 1.06 seconds

win-2012R2-std executed in 12.41 seconds
    should install .net 3.5 feature
  Windows feature "as-net-framework"

win-2012R2-std 16:34:01$ del script.ps1
  Could Not Find C:\Users\vagrant\script.ps1

win-2012R2-std executed in 0.02 seconds
localhost $ scp /var/folders/nn/408ddhln26s1b356ry19q6yr0000gp/T/beaker20160609-75482-1f35ck0 win-2012R2-std:script.ps1 {:ignore => }

win-2012R2-std 16:34:02$ powershell.exe -File script.ps1 < NUL
  Exiting with code: 0

win-2012R2-std executed in 2.06 seconds
    should be installed by "powershell"
Warning: ssh connection to win-2012R2-std has been terminated
removing temporory ssh-config files per-vagrant box
Destroying vagrant boxes
==> win-2012R2-std: Forcing shutdown of VM...
==> win-2012R2-std: Destroying VM and associated drives...

Finished in 8 minutes 55 seconds (files took 3 minutes 40.1 seconds to load)
3 examples, 0 failures
```

Wohoo! All set!

## The Future

[Microsoft are bringing OpenSSH to Windows officially](http://blogs.msdn.com/b/powershell/archive/2015/06/03/looking-forward-microsoft-support-for-secure-shell-ssh.aspx). Hopefully with this, having to use proprietary software such as Bitvise to log in will be a thing of the past. Heck, the new [Ubuntu on Windows](https://blogs.windows.com/buildingapps/2016/03/30/run-bash-on-ubuntu-on-windows/) might even mean that Linux flavor code could be ported over too!
