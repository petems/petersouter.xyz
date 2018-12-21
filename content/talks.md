---
title: Talks
modified: 07-20-2016
comments:       false
showMeta:       false
showActions:    false
showPagination: false
showSocial:     false
showDate:       false
---

# Talks I've given

## 2016

### Hardening Your Config Management - Security and Attack Vectors in Config Management

* FOSDEM 2016 - January 30-31
* https://puppetconf2016.sched.com/event/6fjZ/nice-and-secure-good-opsec-hygiene-with-puppet-peter-souter-puppet

Configuration management is a great tool for helping with hardening and securing servers. But with any addition of new technology comes a new attack vector: Who watches the watchers?

Security is painful. Luckily the invention of configuration management tools has made this process easier, by allowing repeatable configuration for common hardening. However there comes a catch-22: How do we harden the configuration management itself?

When you have a tool that enables you to change systems at a fundamental level, it's a fairly tempting target for malicious agents, and one that would cause a lot of problems if compromised.

We'll be discussing some general patterns we can use to mitigate these problems: - Whitelisting "master" API's - Encrypting sensitive data - Adding a security element to code review

And we'll talk about some application specific options for some of most popular tools out there, such as Puppet, Chef, Ansible, cfengine and Salt.

<a href="https://www.slideshare.net/petems/hardening-your-config-management-security-and-attack-vectors-in-config-management" target="_blank">Slides</a>, <a href="http://video.fosdem.org/2016/ua2220/hardening-your-config-management.mp4" target="_blank">Video</a>

### Lock it Down - Securing your Puppet Infrastructure

* Config Management Camp 2016 - Febuary 2-3
* https://www.slideshare.net/petems/lock-it-down

Puppet is an awesome tool to automate the configuration of your infrastructure, but it's also a potential attack vector. In this talk, we'll discuss some common patterns and changes you can make to harden your Puppet infrastructure, from the basic good practises such as data abstraction in modules, to some advanced customisation you might need in a high-security setup.

### Nice and Secure: Good OpSec Hygiene With Puppet!

* PuppetConf 2016 - Oct 17-21
* https://www.devopsdays.org/events/2017-amsterdam/program/peter-souter/

Puppet is a great first step to making your environment more secure. Evolving your system setup into infrastructure as code allows a clear audit trail and more inspection of your current state, allowing you to shine a light on any problem areas in your estate. But how do we make sure our Puppet setup doesn't make things less secure whilst making it easier to automate? We're going to talk about:
* Making sure security is part of your workflow, rather than an afterthought.
* Best practise with hardening your Puppet architecture.
* Secrets management with the Puppet toolchain.
* Keeping your code clear of plaintext passwords.

<a href="https://www.slideshare.net/PuppetLabs/puppetconf-2016-nice-and-secure-good-opsec-hygiene-with-puppet-peter-souter-puppet" target="_blank">Slides</a>, <a href="https://www.youtube.com/watch?v=JwuXUxSCDGY" target="_blank">Video</a>

## 2017

### Compliance and auditing with Puppet

* Config Management Camp 2016 - Feb 6-7

Puppet is a perfect fit for compliance: you model desired compliant state, continually enforce it and have a full audit path of when changes occur and what lead to the drift. But what are the best practises for using Puppet for compliance, what are the caveats, how do you scan for issues and how can you keep the auditors happy?

If you work with or at a Telco, Financial Institution or a Government entity, you probably already know about compliance and the various acronyms and headaches it can bring.

How can we make this less of a painful process?

Well, if you think about it: compliance is a set of rules that someone has given you to enforce and prove that they're being enforced.

What is Puppet? A series of rules for systems that need to be enforced.

So compliance is the perfect use-case for configuration management.

We'll be discussing:

* How you can enforce compliance in your estate with Puppet
* The difference between using dedicated compliance Puppet modules and leveraging your current modules
* Using the baseline_compliance catalog terminus
* Custom facts for compliance checking
* What tools for scanning work well with Puppet

<a href="http://www.slideshare.net/petems/compliance-and-auditing-with-puppet">Slides</a><h4>

### Knee deep in the undef: Tales from refactoring old Puppet codebases

* Config Management Camp 2016 - Feb 6-7

As Puppet pushes into it’s second decade, there are several organisations out there that have been using Puppet for a long time.

With the EOL announcement of the 3.X release, there are a number of people looking to upgrade, both community and customers. Normally the upgrade of the architecture is ok, it’s the code base that gives the biggest challenge, especially those with multiple years of organic growth.

You quickly learn what hacky solutions that seemed good at the time will come back to bite you.

We’ll be talking about how Hiera is both the best and worst thing to happen to Puppet, marvel at how people were happily running 0.25.4 in Puppet in production in 2016.

By the end of this, you’ll hopefully have learnt how to make sure that your Puppet code is healthy for the next decade\*

\*No guarantees!

### Maintaining Level 8

* HumanOps London 2017, 4 April
* https://www.meetup.com/HumanOps-London/events/238066537/

Your most important piece of equipment is yourself, so I will be taking us through the basics of good ergonomics at our desks and how I have put this into practice throughout his career.

https://www.slideshare.net/petems/maintaining-layer-8-75196679

### Keeping Secrets in your Infrastructure as Code

* Continuous Lifecycle London 2017 - May 17

Managing your infrastructure with a configuration management can be a boon for both automation and security: you get a clear audit trail of changes, inspection of infrastructure’s current state, and shines a light on any problem areas in your estate. But how do we make sure our configuration management setup doesn’t make things less secure whilst making it easier to automate?

In this sponsored session, we’re going to talk about best practices for keeping your secrets in infrastructure as code, detecting plaintext credentials in your code, how Puppet handles secrets and what to do when credentials get leaked.

– Dealing with Secrets with tools like Puppet

– Detecting leaked credentials

– Keeping your code clear of plaintext passwords

– Making security part of your code review process

https://www.youtube.com/watch?v=-zCcIulWxWE

### Secret Management in the world of Infrastructure as Code

* DevOpsDays Amsterdam 2017 - June 28-30

https://www.devopsdays.org/events/2017-amsterdam/program/peter-souter/

Config management tools have revolutionized how machines are managed, making it easy to keep your estate in infrastructure-as-code form. People can write code to modify your estate, and that can be treated in the same way as your regular code: CI, code review, and have unit and acceptance testing.

Seems great right? However, IaC is not a free lunch: having all your infrastructure information in one place can lead to some uncomfortable security pitfalls: There’s potentially a lot of sensitive information in there, such as SSH keys, API tokens and passwords. Have you ever asked yourself the awkward question: What’s the worst that could happen?

Let’s find out! - What are the risks of leaking secrets in your infrastructure? - How can we both prevent leaks from your Infrastructure as code? - What parts of the DevOps toolchain can help you? - How do you detect leaks and what can you do when they happen?

<a href="https://assets.devopsdays.org/events/2017/amsterdam/presentations/Peter_Souter-Secret_Management_in_the_world_of_Infrastructure_as_Code.pdf" target="_blank">Slides</a>, <a href="https://youtu.be/N_FpvLcdUpw" target="_blank">Video</a>

## 2018

### Provisioning vs Configuration Management Deployment vs Orchestration - A rose by any other name...

* FOSDEM 2018, February 3-4
* https://archive.fosdem.org/2018/schedule/event/deployment_provisioning_orchestration/

There's a lot of confusion around the differences between the various terms used when talking about configuring systems. Is Jenkins an orchestration tool or a deployment tool? Can Puppet provision systems? Is Ansible config management or and orchestration?

In this talk, we're going to boil down the core of each term and talk about the approaches used and where things cross over.

Names, as we know, are one of the hardest things in computer science. And in the DevOps space, we frequently see 4 terms come up again and again, and people often blur the lines between what each one is doing:

Deployment vs Provisioning vs Orchestration vs Configuration Management

It's easy to get mixed up between the terms, especially as a lot of the vendors who specialised in one area have started expanding into other areas to diversify their offerings and create a one-stop solution.

In this talk, we're going to discuss the differences between each term, what tools and approaches work well for each, how the lines have blurred in the container world and what the future might hold.

### Monitoring Consul and Vault

* HashiCorp London User Group, May 24th
* https://www.meetup.com/London-HashiCorp-User-Group/events/250577901/

Vault is an open source solution for identity and secrets management. Vault is well suited for both public cloud and private datacenter usage, but a common challenge is securely running Vault and accessing secrets in public cloud. This talk will show how to securely run Vault in the cloud, and be able to access those secrets securely from multiple differing cloud platforms. Additionally, the Vault 0.10 release is right around the corner and includes some major changes to improve the lives of both beginners and advanced users of Vault. We’ll spend some time looking at the latest features in Vault, and use these throughout the talk.

https://www.slideshare.net/petems/monitoring-a-vault-and-consul-cluster-24th-may-2018

### How to Use HashiCorp Vault with Hiera 5 for Secret Management with Puppet

* Webinar, May 23rd
* https://www.hashicorp.com/resources/hashicorp-vault-with-puppet-hiera-5-for-secret-management

Puppet is one of the most mature and widely used config management tools out there. But one question comes up time and again: where and how do I store secrets in Puppet code? HashiCorp Vault safely manages your secrets in an automated and secure way.

In this webinar, Peter Souter demonstrates how to use HashiCorp Vault for secrets management while using Puppet as the configuration management software.

Watch to learn how to:

* How to install and configure Vault using Puppet
* How to use the custom Hiera backend to communicate with Vault
* Best practices to ensure secrets are kept in your Puppet runs
* When to manage secret information with Puppet and when to do manage secrets natively with tools such as * consul-env or consul-template

### Consul Connect - Modern Service Networking with Service Mesh

* EPAM SEC 2018, September 24
* https://events.epam.com/events/sec-2018/talks/6945

A service mesh is necessary for organizations adopting microservices and dynamic cloud-native infrastructure. Traditional host-based network security must be replaced with modern service-based security to accommodate the highly dynamic nature of modern runtime environments.   In this talk, we will look at Connect a significant new feature in Consul that provides secure service-to-service communication with automatic TLS encryption and identity-based authorization.   We will look at the features of Connect, how to enable Connect in an existing Consul cluster and how easy it is to secure service-to-service communication using Connect.

https://www.slideshare.net/petems/consul-connect-epam-sec-22nd-september-2018
