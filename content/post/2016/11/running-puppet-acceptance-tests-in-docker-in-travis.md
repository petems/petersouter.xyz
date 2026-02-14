+++
author = "Peter Souter"
categories = ["Tech"]
date = 2016-11-04T22:17:00Z
description = ""
draft = false
coverImage = "/images/2016/11/instacode.png"
slug = "running-puppet-acceptance-tests-in-docker-in-travis"
tags = ["Puppet", "Testing", "Beaker", "Open-Source", "vDM30in30"]
title = "Running Puppet acceptance tests in Docker in Travis"

+++

#### Day 4 in the #vDM30in30

One of the things that comes up a lot with Puppet code is testing, particularly acceptance testing. Just like with regular code, you want to make sure that changes to Puppet are not going to break the standard use-case for your module.

Travis has been a boon for open-source testing. For a while, Travis was only for the syntax, linting and rspec tests. But in the last year they've added the ability to have Docker running in a Travis job.

Docker containers aren't VMs, so you're not going to test everything you can do in Puppet (for example, I can't test my swapfile module with Docker as containers don't have swap). But for most modules, the standard Linux userspace stuff will work: installing packages, starting services, putting files on disk etc.

So I've been doing this with all my new modules, for example my Cockpit module: https://github.com/petems/petems-cockpit

It's pretty simple to setup overall. You just need to add the docker service to a job in your Travis build matrix:

```yaml
---
sudo: false
language: ruby
bundler_args: --without system_tests
script: "bundle exec rake validate && bundle exec rake lint && bundle exec rake spec SPEC_OPTS='--format documentation'"
matrix:
  fast_finish: true
  include:
  - rvm: 1.9.3
    env: PUPPET_GEM_VERSION="~> 3.0" STRICT_VARIABLES="yes" ORDERING="random"
  - rvm: 2.0.0
    env: PUPPET_GEM_VERSION="~> 3.0" STRICT_VARIABLES="yes" ORDERING="random"
  - rvm: 2.1.6
    env: PUPPET_GEM_VERSION="~> 4.0" STRICT_VARIABLES="yes" ORDERING="random"
  - rvm: '2.1'
    sudo: required
    services: docker
    env: PUPPET_INSTALL_VERSION="1.5.2" PUPPET_INSTALL_TYPE=agent BEAKER_set="centos-7-docker"
    script: bundle exec rake acceptance
    bundler_args: --without development
  - rvm: '2.1'
    sudo: required
    services: docker
    env: PUPPET_INSTALL_VERSION="1.5.2" PUPPET_INSTALL_TYPE=agent BEAKER_set="fedora-22-docker"
    script: bundle exec rake acceptance
    bundler_args: --without development
  - rvm: '2.1'
    sudo: required
    services: docker
    env: PUPPET_INSTALL_VERSION="1.5.2" PUPPET_INSTALL_TYPE=agent BEAKER_set="ubuntu-1604-docker"
    script: bundle exec rake acceptance
    bundler_args: --without development
```

In this case, I'm testing it against the three main platforms I'm supporting for my Cockpit module: Ubuntu 16.04, Fedora 22 and CentOS 7.

Then, add a Docker SUI yaml file for the platforms you've defined:

```yaml
HOSTS:
  centos-7-x64:
    platform: el-7-x86_64
    hypervisor : docker
    image: centos:7
    docker_preserve_image: true
    docker_cmd: '["/sbin/init"]'
    docker_preserve_image: true
CONFIG:
  type: foss
  log_level: debug

HOSTS:
  fedora-22-x64:
    platform: fedora-22-x86_64
    hypervisor: docker
    image: fedora:22
    docker_image_commands:
      - dnf clean all
      - dnf -y update
      - dnf -y install findutils hostname
    docker_cmd: '["/sbin/init"]'
    docker_preserve_image: true
CONFIG:
  type: foss
  log_level: debug

HOSTS:
  ubuntu-16-04:
    platform: ubuntu-16.04-amd64
    image: ubuntu:16.04
    hypervisor: docker
    docker_cmd: '["/sbin/init"]'
    docker_image_commands:
      - 'apt-get install -y net-tools wget curl'
      - 'locale-gen en_US.UTF-8'
    docker_preserve_image: true
CONFIG:
  type: foss
  log_level: debug
```

You normally have to add a few extra setup steps for your `docker_image_commands`, as Docker images from the registry are designed to be more minimal. You could also save time by making your own Docker images with all the Puppet and Beaker prerequisites already installed, but I haven't got round to doing that yet.

Then, as long as I have some beaker acceptance tests setup, whenever a PR is opened against the repo, or I push a change, the whole module is tested against the 3 tested platforms.

The output looks something like this:

```
Beaker::Hypervisor, found some docker boxes to create
get
/v1.16/version
{}
Provisioning docker
provisioning centos-7-x64
Creating image
Dockerfile is           FROM centos:7
            RUN yum clean all
            RUN yum install -y sudo openssh-server openssh-clients curl ntpdate
            RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key
            RUN ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key
          RUN mkdir -p /var/run/sshd
          RUN echo root:root | chpasswd
          RUN sed -ri 's/^#?PermitRootLogin .*/PermitRootLogin yes/' /etc/ssh/sshd_config
          RUN sed -ri 's/^#?PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
          EXPOSE 22
          CMD ["/sbin/init"]
post
/v1.16/build
{:rm=>true}
Dockerfile0000640000000000000000000000110412742244430013302 0ustar00wheelwheel00000000000000          FROM centos:7
            RUN yum clean all
            RUN yum install -y sudo openssh-server openssh-clients curl ntpdate
            RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key
            RUN ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key
          RUN mkdir -p /var/run/sshd
          RUN echo root:root | chpasswd
          RUN sed -ri 's/^#?PermitRootLogin .*/PermitRootLogin yes/' /etc/ssh/sshd_config
          RUN sed -ri 's/^#?PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
          EXPOSE 22
          CMD ["/sbin/init"]
Creating container from image f98fee4f4de5
post
/v1.16/containers/create
{}
{"Image":"f98fee4f4de5","Hostname":"centos-7-x64"}
Starting container bef684386c7fc5fe76821adf90b368251c17bf399661e91db543585ec720bb96
post
/v1.16/containers/bef684386c7fc5fe76821adf90b368251c17bf399661e91db543585ec720bb96/start
{}
{"PublishAllPorts":true,"Privileged":true}
get
/v1.16/containers/bef684386c7fc5fe76821adf90b368251c17bf399661e91db543585ec720bb96/json
{}
Using docker server at 0.0.0.0
get
/v1.16/containers/bef684386c7fc5fe76821adf90b368251c17bf399661e91db543585ec720bb96/json
{}
node available as  ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@0.0.0.0 -p 32768
get
/v1.16/containers/bef684386c7fc5fe76821adf90b368251c17bf399661e91db543585ec720bb96/json
{}
centos-7-x64 20:36:02$ cat /etc/resolv.conf
  Attempting ssh connection to 0.0.0.0, user: root, opts: {:password=>"root", :port=>"32768", :forward_agent=>false}
  Warning: Try 1 -- Host 0.0.0.0 unreachable: Net::SSH::Disconnect - connection closed by remote host
  Warning: Trying again in 3 seconds
  Attempting ssh connection to 0.0.0.0, user: root, opts: {:password=>"root", :port=>"32768", :forward_agent=>false, :user=>"root"}
  # Dynamic resolv.conf(5) file for glibc resolver(3) generated by resolvconf(8)
  #     DO NOT EDIT THIS FILE BY HAND -- YOUR CHANGES WILL BE OVERWRITTEN
  nameserver 169.254.169.254
  search c.travis-ci-prod-4.internal google.internal
centos-7-x64 executed in 3.44 seconds
centos-7-x64 20:36:05$ echo '127.0.0.1  localhost localhost.localdomain
172.17.0.9  centos-7-x64.c.travis-ci-prod-4.internal centos-7-x64
' >> /etc/hosts
centos-7-x64 executed in 0.02 seconds
centos-7-x64 20:36:05$ rpm -q curl
  curl-7.29.0-25.el7.centos.x86_64
centos-7-x64 executed in 0.06 seconds
centos-7-x64 20:36:05$ rpm -q ntpdate
  ntpdate-4.2.6p5-22.el7.centos.2.x86_64
centos-7-x64 executed in 0.06 seconds
setting local environment on centos-7-x64
centos-7-x64 20:36:06$ getent passwd root
  root:x:0:0:root:/root:/bin/bash
centos-7-x64 executed in 0.02 seconds
centos-7-x64 20:36:06$ mktemp -dt .XXXXXX
  /tmp/.YzB28r
centos-7-x64 executed in 0.02 seconds
centos-7-x64 20:36:06$ chown root:root /tmp/.YzB28r
centos-7-x64 executed in 0.02 seconds
centos-7-x64 20:36:06$ echo 'PermitUserEnvironment yes' | cat - /etc/ssh/sshd_config > /tmp/.YzB28r/sshd_config.permit
centos-7-x64 executed in 0.02 seconds
centos-7-x64 20:36:06$ mv /tmp/.YzB28r/sshd_config.permit /etc/ssh/sshd_config
centos-7-x64 executed in 0.02 seconds
centos-7-x64 20:36:06$ systemctl restart sshd.service
centos-7-x64 executed in 0.03 seconds
centos-7-x64 20:36:06$ mkdir -p ~/.ssh
centos-7-x64 executed in 0.02 seconds
centos-7-x64 20:36:06$ chmod 0600 ~/.ssh
centos-7-x64 executed in 0.02 seconds
centos-7-x64 20:36:06$ touch ~/.ssh/environment
centos-7-x64 executed in 0.02 seconds
centos-7-x64 20:36:06$ grep ^PATH=.*\$PATH ~/.ssh/environment
centos-7-x64 executed in 0.02 seconds
Exited: 1
centos-7-x64 20:36:06$ grep ^PATH ~/.ssh/environment
centos-7-x64 executed in 0.02 seconds
Exited: 1
centos-7-x64 20:36:06$ echo "PATH=$PATH" >> ~/.ssh/environment
centos-7-x64 executed in 0.02 seconds
will not mirror environment to /etc/profile.d on non-sles/debian platform host
centos-7-x64 20:36:06$ echo "/usr/bin"
  /usr/bin
centos-7-x64 executed in 0.02 seconds
centos-7-x64 20:36:06$ echo "/opt/puppet-git-repos/hiera/bin"
  /opt/puppet-git-repos/hiera/bin
centos-7-x64 executed in 0.02 seconds
centos-7-x64 20:36:06$ grep ^PATH=.*\/usr\/bin:\/opt\/puppet\-git\-repos\/hiera\/bin ~/.ssh/environment
centos-7-x64 executed in 0.02 seconds
Exited: 1
centos-7-x64 20:36:06$ grep ^PATH ~/.ssh/environment
  PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin
centos-7-x64 executed in 0.02 seconds
centos-7-x64 20:36:06$ sed -i -e "s/^PATH=/PATH=\/usr\/bin:\/opt\/puppet\-git\-repos\/hiera\/bin:/" ~/.ssh/environment
centos-7-x64 executed in 0.02 seconds
will not mirror environment to /etc/profile.d on non-sles/debian platform host
centos-7-x64 20:36:06$ grep ^PATH=.*PATH ~/.ssh/environment
centos-7-x64 executed in 0.03 seconds
Exited: 1
centos-7-x64 20:36:06$ grep ^PATH ~/.ssh/environment
  PATH=/usr/bin:/opt/puppet-git-repos/hiera/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin
centos-7-x64 executed in 0.02 seconds
centos-7-x64 20:36:06$ sed -i -e "s/^PATH=/PATH=PATH:/" ~/.ssh/environment
centos-7-x64 executed in 0.02 seconds
will not mirror environment to /etc/profile.d on non-sles/debian platform host
Warning: ssh connection to centos-7-x64 has been terminated
centos-7-x64 20:36:06$ cat ~/.ssh/environment
  Attempting ssh connection to 0.0.0.0, user: root, opts: {:password=>"root", :port=>"32768", :forward_agent=>false, :user=>"root"}
  PATH=PATH:/usr/bin:/opt/puppet-git-repos/hiera/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin
centos-7-x64 executed in 0.11 seconds
Disabling updates.puppetlabs.com by modifying hosts file to resolve updates to 127.0.0.1 on centos-7-x64
centos-7-x64 20:36:06$ echo '127.0.0.1  updates.puppetlabs.com
' >> /etc/hosts
centos-7-x64 executed in 0.02 seconds
centos-7-x64 20:36:06$ rpm --replacepkgs -Uvh http://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
  warning:   /var/tmp/rpm-tmp.pKpDgh: Header V4 RSA/SHA1 Signature, key ID 4bd6ec30: NOKEY
  Retrieving http://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
  Preparing...                            ########################################
  Updating / installing...
  puppetlabs-release-pc1-1.0.0-2.el7      #################################  ####  ###
centos-7-x64 executed in 0.35 seconds
centos-7-x64 20:36:06$ echo "/opt/puppetlabs/bin"
  /opt/puppetlabs/bin
centos-7-x64 executed in 0.02 seconds
centos-7-x64 20:36:06$ echo "/opt/puppet-git-repos/hiera/bin"
  /opt/puppet-git-repos/hiera/bin
centos-7-x64 executed in 0.02 seconds
centos-7-x64 20:36:06$ grep ^PATH=.*\/opt\/puppetlabs\/bin:\/opt\/puppet\-git\-repos\/hiera\/bin ~/.ssh/environment
centos-7-x64 executed in 0.02 seconds
Exited: 1
centos-7-x64 20:36:06$ grep ^PATH ~/.ssh/environment
  PATH=PATH:/usr/bin:/opt/puppet-git-repos/hiera/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin
centos-7-x64 executed in 0.03 seconds
centos-7-x64 20:36:07$ sed -i -e "s/^PATH=/PATH=\/opt\/puppetlabs\/bin:\/opt\/puppet\-git\-repos\/hiera\/bin:/" ~/.ssh/environment
centos-7-x64 executed in 0.02 seconds
will not mirror environment to /etc/profile.d on non-sles/debian platform host
centos-7-x64 20:36:07$ grep ^PATH=.*PATH ~/.ssh/environment
  PATH=/opt/puppetlabs/bin:/opt/puppet-git-repos/hiera/bin:PATH:/usr/bin:/opt/puppet-git-repos/hiera/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin
centos-7-x64 executed in 0.03 seconds
centos-7-x64 20:36:07$ yum -y  install puppet-agent-1.5.2
  Loaded plugins: fastestmirror, ovl
  Loading mirror speeds from cached hostfile
   * base: mirror.beyondhosting.net
   * extras: mirrors.liquidweb.com
   * updates: centos.firehosted.com
  Resolving Dependencies
  --> Running transaction check
  ---> Package puppet-agent.x86_64 0:1.5.2-1.el7 will be installed
  --> Finished Dependency Resolution

  Dependencies Resolved

  ================================================================================
   Package            Arch         Version             Repository            Size
  ================================================================================
  Installing:
   puppet-agent       x86_64       1.5.2-1.el7         puppetlabs-pc1        23 M

  Transaction Summary
  ================================================================================
  Install  1 Package
  Total download size: 23 M
  Installed size: 23 M
  Downloading packages:
  warning: /var/cache/yum/x86_64/7/puppetlabs-pc1/packages/puppet-agent-1.5.2-1.el7.x86_64.rpm: Header V4 RSA/SHA512 Signature, key ID 4bd6ec30: NOKEY
  Public key for puppet-agent-1.5.2-1.el7.x86_64.rpm is not installed
  Retrieving key from file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs-PC1
  Importing GPG key 0x4BD6EC30:
   Userid     : "Puppet Labs Release Key (Puppet Labs Release Key) <info@puppetlabs.com>"
   Fingerprint: 47b3 20eb 4c7c 375a a9da e1a0 1054 b7a2 4bd6 ec30
   Package    : puppetlabs-release-pc1-1.0.0-2.el7.noarch (installed)
   From       : /etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs-PC1
  Running transaction check
  Running transaction test
  Transaction test succeeded
  Running transaction
  Warning: RPMDB altered outside of yum.
    Installing : puppet-agent-1.5.2-1.el7.x86_64                              1/1
    Verifying  : puppet-agent-1.5.2-1.el7.x86_64                              1/1

  Installed:
    puppet-agent.x86_64 0:1.5.2-1.el7
  Complete!
centos-7-x64 executed in 7.29 seconds
centos-7-x64 20:36:14$ echo "/opt/puppetlabs/bin"
  /opt/puppetlabs/bin
centos-7-x64 executed in 0.02 seconds
centos-7-x64 20:36:14$ echo "/opt/puppet-git-repos/hiera/bin"
  /opt/puppet-git-repos/hiera/bin
centos-7-x64 executed in 0.02 seconds
centos-7-x64 20:36:14$ grep ^PATH=.*\/opt\/puppetlabs\/bin:\/opt\/puppet\-git\-repos\/hiera\/bin ~/.ssh/environment
  PATH=/opt/puppetlabs/bin:/opt/puppet-git-repos/hiera/bin:PATH:/usr/bin:/opt/puppet-git-repos/hiera/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin
centos-7-x64 executed in 0.03 seconds
centos-7-x64 20:36:14$ grep ^PATH=.*PATH ~/.ssh/environment
  PATH=/opt/puppetlabs/bin:/opt/puppet-git-repos/hiera/bin:PATH:/usr/bin:/opt/puppet-git-repos/hiera/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin
centos-7-x64 executed in 0.02 seconds
centos-7-x64 20:36:14$ puppet config set show_diff true
centos-7-x64 executed in 1.05 seconds
centos-7-x64 20:36:15$ facter operatingsystem
  CentOS
centos-7-x64 executed in 0.07 seconds
centos-7-x64 20:36:15$ puppet config set show_diff true
centos-7-x64 executed in 1.16 seconds
centos-7-x64 20:36:16$ echo /etc/puppetlabs/code/modules
  /etc/puppetlabs/code/modules
centos-7-x64 executed in 0.03 seconds
Using scp to transfer /home/travis/build/petems/petems-cockpit to /etc/puppetlabs/code/modules/cockpit
localhost $ scp /home/travis/build/petems/petems-cockpit centos-7-x64:/etc/puppetlabs/code/modules {:ignore => [".bundle", ".git", ".idea", ".vagrant", ".vendor", "vendor", "acceptance", "bundle", "spec", "tests", "log", ".", ".."]}
going to ignore (?-mix:((\/|\A)\.bundle(\/|\z))|((\/|\A)\.git(\/|\z))|((\/|\A)\.idea(\/|\z))|((\/|\A)\.vagrant(\/|\z))|((\/|\A)\.vendor(\/|\z))|((\/|\A)vendor(\/|\z))|((\/|\A)acceptance(\/|\z))|((\/|\A)bundle(\/|\z))|((\/|\A)spec(\/|\z))|((\/|\A)tests(\/|\z))|((\/|\A)log(\/|\z))|((\/|\A)\.(\/|\z))|((\/|\A)\.\.(\/|\z)))
centos-7-x64 20:36:18$ rm -rf /etc/puppetlabs/code/modules/cockpit
centos-7-x64 executed in 0.04 seconds
centos-7-x64 20:36:18$ mv /etc/puppetlabs/code/modules/petems-cockpit /etc/puppetlabs/code/modules/cockpit
centos-7-x64 executed in 0.03 seconds
centos-7-x64 20:36:18$ facter osfamily
  RedHat
centos-7-x64 executed in 0.07 seconds
centos-7-x64 20:36:18$ puppet module install puppetlabs-stdlib -v 4.11.0
  Notice: Preparing to install into /etc/puppetlabs/code/environments/production/modules ...
  Notice: Downloading from https://forgeapi.puppetlabs.com ...
  Notice: Installing -- do not interrupt ...
  /etc/puppetlabs/code/environments/production/modules
  └── puppetlabs-stdlib (v4.11.0)
centos-7-x64 executed in 3.25 seconds
centos-7-x64 20:36:21$ puppet module install puppetlabs-inifile -v 1.5.0
  Notice: Preparing to install into /etc/puppetlabs/code/environments/production/modules ...
  Notice: Downloading from https://forgeapi.puppetlabs.com ...
  Notice: Installing -- do not interrupt ...
  /etc/puppetlabs/code/environments/production/modules
  └── puppetlabs-inifile (v1.5.0)
centos-7-x64 executed in 1.92 seconds
centos-7-x64 20:36:23$ puppet module install puppetlabs-apt -v 2.2.2
  Notice: Preparing to install into /etc/puppetlabs/code/environments/production/modules ...
  Notice: Downloading from https://forgeapi.puppetlabs.com ...
  Notice: Installing -- do not interrupt ...
  /etc/puppetlabs/code/environments/production/modules
  └─┬ puppetlabs-apt (v2.2.2)
    └── puppetlabs-stdlib (v4.11.0)
centos-7-x64 executed in 3.67 seconds
cockpit class
  default parameters
centos-7-x64 20:36:27$ mktemp -t apply_manifest.pp.XXXXXX
  /tmp/apply_manifest.pp.aKcekp
centos-7-x64 executed in 0.02 seconds
localhost $ scp /tmp/beaker20160715-15866-1tggasj centos-7-x64:/tmp/apply_manifest.pp.aKcekp {:ignore => }
centos-7-x64 20:36:27$ puppet apply --verbose --detailed-exitcodes /tmp/apply_manifest.pp.aKcekp
  Info: Loading facts
  Info: Loading facts
  Notice: Compiled catalog for centos-7-x64.c.travis-ci-prod-4.internal in environment production in 0.36 seconds
  Info: Applying configuration version '1468614990'
  Notice: /Stage[main]/Cockpit::Repo::Centos/Yumrepo[extras]/enabled: defined 'enabled' as '1'
  Notice: /Stage[main]/Cockpit::Install/Package[cockpit]/ensure: created
  Notice: /Stage[main]/Cockpit::Config/Ini_setting[Cockpit LoginTitle]/ensure: created
  Notice: /Stage[main]/Cockpit::Config/Ini_setting[Cockpit MaxStartups]/ensure: created
  Notice: /Stage[main]/Cockpit::Config/Ini_setting[Cockpit AllowUnencrypted]/ensure: created
  Info: Class[Cockpit::Config]: Scheduling refresh of Class[Cockpit::Service]
  Info: Class[Cockpit::Service]: Scheduling refresh of Service[cockpit]
  Notice: /Stage[main]/Cockpit::Service/Service[cockpit]/ensure: ensure changed 'stopped' to 'running'
  Info: /Stage[main]/Cockpit::Service/Service[cockpit]: Unscheduling refresh on Service[cockpit]
  Info: Creating state file /opt/puppetlabs/puppet/cache/state/state.yaml
  Notice: Applied catalog in 34.82 seconds
centos-7-x64 executed in 37.93 seconds
Exited: 2
centos-7-x64 20:37:05$ mktemp -t apply_manifest.pp.XXXXXX
  /tmp/apply_manifest.pp.yilB0O
centos-7-x64 executed in 0.03 seconds
localhost $ scp /tmp/beaker20160715-15866-mz0p36 centos-7-x64:/tmp/apply_manifest.pp.yilB0O {:ignore => }
centos-7-x64 20:37:05$ puppet apply --verbose --detailed-exitcodes /tmp/apply_manifest.pp.yilB0O
  Info: Loading facts
  Info: Loading facts
  Notice: Compiled catalog for centos-7-x64.c.travis-ci-prod-4.internal in environment production in 0.43 seconds
  Info: Applying configuration version '1468615029'
  Notice: Applied catalog in 0.10 seconds
centos-7-x64 executed in 4.57 seconds
    should work idempotently with no errors
    Package "cockpit"
centos-7-x64 20:37:10$ /bin/sh -c ls\ /etc/arch-release
  ls: cannot access /etc/arch-release  : No such file or directory
centos-7-x64 executed in 0.03 seconds
Exited: 2
centos-7-x64 20:37:10$ /bin/sh -c ls\ /etc/alpine-release
  ls: cannot access /etc/alpine-release: No such file or directory
centos-7-x64 executed in 0.02 seconds
Exited: 2
centos-7-x64 20:37:10$ /bin/sh -c uname\ -s
  Linux
centos-7-x64 executed in 0.02 seconds
centos-7-x64 20:37:10$ /bin/sh -c uname\ -sr
  Linux 3.19.0-30-generic
centos-7-x64 executed in 0.02 seconds
centos-7-x64 20:37:10$ /bin/sh -c ls\ /etc/coreos/update.conf
  ls:   cannot access /etc/coreos/update.conf  : No such file or directory
centos-7-x64 executed in 0.06 seconds
Exited: 2
centos-7-x64 20:37:10$ /bin/sh -c ls\ /etc/debian_version
  ls: cannot access /etc/debian_version: No such file or directory
centos-7-x64 executed in 0.03 seconds
Exited: 2
centos-7-x64 20:37:10$ /bin/sh -c ls\ /etc/gentoo-release
  ls: cannot access /etc/gentoo-release: No such file or directory
centos-7-x64 executed in 0.05 seconds
Exited: 2
centos-7-x64 20:37:10$ /bin/sh -c uname\ -sr
  Linux 3.19.0-30-generic
centos-7-x64 executed in 0.03 seconds
centos-7-x64 20:37:10$ /bin/sh -c vmware\ -v
  /bin/sh: vmware: command not found
centos-7-x64 executed in 0.03 seconds
Exited: 127
centos-7-x64 20:37:10$ /bin/sh -c ls\ /usr/lib/setup/Plamo-\*
  ls: cannot access /usr/lib/setup/Plamo-*  : No such file or directory
centos-7-x64 executed in 0.02 seconds
Exited: 2
centos-7-x64 20:37:10$ /bin/sh -c uname\ -sr
  Linux 3.19.0-30-generic
centos-7-x64 executed in 0.02 seconds
centos-7-x64 20:37:10$ /bin/sh -c ls\ /var/run/current-system/sw
  ls: cannot access /var/run/current-system/sw  : No such file or directory
centos-7-x64 executed in 0.03 seconds
Exited: 2
centos-7-x64 20:37:10$ /bin/sh -c ls\ /etc/fedora-release
  ls: cannot access /etc/fedora-release  : No such file or directory
centos-7-x64 executed in 0.02 seconds
Exited: 2
centos-7-x64 20:37:10$ /bin/sh -c ls\ /etc/redhat-release
  /etc/redhat-release
centos-7-x64 executed in 0.02 seconds
centos-7-x64 20:37:10$ /bin/sh -c cat\ /etc/redhat-release
  CentOS Linux release 7.2.1511 (Core)
centos-7-x64 executed in 0.02 seconds
centos-7-x64 20:37:10$ /bin/sh -c uname\ -m
  x86_64
centos-7-x64 executed in 0.02 seconds
centos-7-x64 20:37:10$ /bin/sh -c rpm\ -q\ cockpit
  cockpit-0.108-1.el7.centos.x86_64
centos-7-x64 executed in 0.05 seconds
      should be installed
    Service "cockpit"
centos-7-x64 20:37:10$ /bin/sh -c systemctl\ is-active\ cockpit
  active
centos-7-x64 executed in 0.03 seconds
      should be running
    Cockpit should be running on the default port
      Command "sleep 15 && echo "Give Cockpit time to start""
        exit_status
centos-7-x64 20:37:10$ /bin/sh -c sleep\ 15\ \&\&\ echo\ \"Give\ Cockpit\ time\ to\ start\"
  Give Cockpit time to start
centos-7-x64 executed in 15.03 seconds
          should eq 0
      Command "curl 0.0.0.0:9090/"
        stdout
centos-7-x64 20:37:25$ /bin/sh -c curl\ 0.0.0.0:9090/
centos-7-x64 executed in 0.07 seconds
          should match /Cockpit/
  different port again
centos-7-x64 20:37:50$ mktemp -t apply_manifest.pp.XXXXXX
  /tmp/apply_manifest.pp.vwCIJz
centos-7-x64 executed in 0.02 seconds
localhost $ scp /tmp/beaker20160715-15866-7pfxw6 centos-7-x64:/tmp/apply_manifest.pp.vwCIJz {:ignore => }
centos-7-x64 20:37:50$ puppet apply --verbose --detailed-exitcodes /tmp/apply_manifest.pp.vwCIJz
  Info: Loading facts
  Info: Loading facts
  Notice: Compiled catalog for centos-7-x64.c.travis-ci-prod-4.internal in environment production in 0.50 seconds
  Info: Applying configuration version '1468615073'
  Notice: /Stage[main]/Cockpit::Config/File[/etc/systemd/system/cockpit.socket.d/listen.conf]/content:
  --- /etc/systemd/system/cockpit.socket.d/listen.conf  2016-07-15 20:37:30.285583194 +0000
  +++ /tmp/puppet-file20160715-1448-1yaw5k6 2016-07-15 20:37:54.353668005 +0000
  @@ -1,4 +1,4 @@
   [Socket]
   # This is not a typo, it's how systemd resets the ListenStream setting
   ListenStream=
  -ListenStream=7777
  +ListenStream=7776
  Info: Computing checksum on file /etc/systemd/system/cockpit.socket.d/listen.conf
  Info: /Stage[main]/Cockpit::Config/File[/etc/systemd/system/cockpit.socket.d/listen.conf]: Filebucketed /etc/systemd/system/cockpit.socket.d/listen.conf to puppet with sum a1416ab4248e67b69953333ef50c5bbd
  Notice: /Stage[main]/Cockpit::Config/File[/etc/systemd/system/cockpit.socket.d/listen.conf]/content: content changed '{md5}a1416ab4248e67b69953333ef50c5bbd' to '{md5}1934281790bdce76c6b20c304fccfe56'
  Info: /Stage[main]/Cockpit::Config/File[/etc/systemd/system/cockpit.socket.d/listen.conf]: Scheduling refresh of Exec[Cockpit systemctl daemon-reload]
  Notice: /Stage[main]/Cockpit::Config/Exec[Cockpit systemctl daemon-reload]: Triggered 'refresh' from 1 events
  Info: Class[Cockpit::Config]: Scheduling refresh of Class[Cockpit::Service]
  Info: Class[Cockpit::Service]: Scheduling refresh of Service[cockpit]
  Notice: /Stage[main]/Cockpit::Service/Service[cockpit]: Triggered 'refresh' from 1 events
  Notice: Applied catalog in 0.26 seconds
centos-7-x64 executed in 4.37 seconds
Exited: 2
centos-7-x64 20:37:54$ mktemp -t apply_manifest.pp.XXXXXX
  /tmp/apply_manifest.pp.tnzgUu
centos-7-x64 executed in 0.03 seconds
localhost $ scp /tmp/beaker20160715-15866-fonx1g centos-7-x64:/tmp/apply_manifest.pp.tnzgUu {:ignore => }
centos-7-x64 20:37:54$ puppet apply --verbose --detailed-exitcodes /tmp/apply_manifest.pp.tnzgUu
  Info: Loading facts
  Info: Loading facts
  Notice: Compiled catalog for centos-7-x64.c.travis-ci-prod-4.internal in environment production in 0.60 seconds
  Info: Applying configuration version '1468615079'
  Notice: Applied catalog in 0.11 seconds
centos-7-x64 executed in 5.42 seconds
    should work idempotently with no errors
    Package "cockpit"
centos-7-x64 20:38:00$ /bin/sh -c rpm\ -q\ cockpit
  cockpit-0.108-1.el7.centos.x86_64
centos-7-x64 executed in 0.06 seconds
      should be installed
    Service "cockpit"
centos-7-x64 20:38:00$ /bin/sh -c systemctl\ is-active\ cockpit
  active
centos-7-x64 executed in 0.03 seconds
      should be running
    Cockpit should be running on the 7776 port
      Command "sleep 15 && echo "Give Cockpit time to start""
        exit_status
centos-7-x64 20:38:00$ /bin/sh -c sleep\ 15\ \&\&\ echo\ \"Give\ Cockpit\ time\ to\ start\"
  Give Cockpit time to start
centos-7-x64 executed in 15.03 seconds
          should eq 0
      Command "curl 0.0.0.0:7776/"
        stdout
centos-7-x64 20:38:15$ /bin/sh -c curl\ 0.0.0.0:7776/
centos-7-x64 executed in 0.06 seconds
          should match /Cockpit/
Warning: ssh connection to centos-7-x64 has been terminated
Cleaning up docker
stop container bef684386c7fc5fe76821adf90b368251c17bf399661e91db543585ec720bb96
post
/v1.16/containers/bef684386c7fc5fe76821adf90b368251c17bf399661e91db543585ec720bb96/stop
{}
{}
delete container bef684386c7fc5fe76821adf90b368251c17bf399661e91db543585ec720bb96
delete
/v1.16/containers/bef684386c7fc5fe76821adf90b368251c17bf399661e91db543585ec720bb96
{}
Finished in 2 minutes 25.9 seconds (files took 41.09 seconds to load)
20 examples, 0 failures
The command "bundle exec rake acceptance" exited with 0.
Done. Your build exited with 0.
```

So with this, I'm getting a full-acceptance test of my module continuously, across multiple operating systems.
