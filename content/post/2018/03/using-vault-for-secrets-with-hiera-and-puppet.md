+++
author = "Peter Souter"
categories = ["Tech"]
date = 2018-03-19T17:07:00Z
description = "How to use Vault with Hiera 5 for secret management with Puppet"
draft = false
thumbnailImage = "/images/2018/03/hiera-vault-750.png"
coverImage = "/images/2018/03/hiera-vault.png"
slug = "using-vault-for-secrets-with-hiera-and-puppet"
tags = ["Vagrant", "Vault", "Puppet"]
title = "How to use Vault with Hiera 5 for secret management with Puppet"

+++

# EDIT:

> So, this blog was linked by DevOps Weekly #379, and seems to have climbed the SEO ranking
for Hiera and Vault, but I've learn a lot and have some general changes since then.

> I did a [webinar on the subject](https://www.hashicorp.com/resources/hashicorp-vault-with-puppet-hiera-5-for-secret-management) I'll be writing an updated version of how to use Vault and Hiera soon, and link it here.

Although I don't work at Puppet anymore, it's still my favourite config management
software, and I use it for the management of machines under my control, including
my home storage server and several MacBooks.

One of the most annoying pieces of this configuration is the management of secrets.
A long time ago, someone created hiera-eyaml. This was a way of encrypting secrets,
putting them in a YAML file encrypted, then configuring the Puppet master to use
the secret key to unencrypt them when compiling a catalog.

This works fine, but it's a hassle. What if we could keep them in a dedicated secrets
management tool.

Enter Vault.

Vault is HashiCorp's tool for managing secrets. What better way of aquanting myself better with HashiCorp's stack
then learning how to integrate it with something I already understand?

So, I created a basic Vagrant repo to configure an example proof of concept.

To start with, Vault gets installed and started by default on the Puppetserver node.

In the real world, you'd want this on a separate dedicated instance, but I'm keeping things simpler.

The local port 8200 gets forwarded to the Vagrant VM to port 8200.

After the initial provisioning is done, we initialise vault:

```
$ VAULT_ADDR='http://127.0.0.1:8200' vault init

Unseal Key 1: qduQtx3VNgLN/9WP1ZRzCq1ZB709DZ3TS/D52YS6yLzr
Unseal Key 2: YSXO2hST8+FHoBrn1SgI6yn+ApriQpqiDKhrnLXH9ojP
Unseal Key 3: o+Og63B2/cJiX/8VoshTlBIb/dkCoeGrgSv2bPLQzBjE
Unseal Key 4: lfNiq0/B5V1IXyKzivjDRXqetHtcXqaHj8prF9RclL08
Unseal Key 5: DL3Xf4FSxIv6+NEYdZCZaskf0jcJ0bowe34r7Gdl7Y+9
Initial Root Token: 677b88e3-300c-3a5a-ea2f-72ba70be5516

Vault initialized with 5 keys and a key threshold of 3. Please
securely distribute the above keys. When the vault is re-sealed,
restarted, or stopped, you must provide at least 3 of these keys
to unseal it again.

Vault does not store the master key. Without at least 3 keys,
your vault will remain permanently sealed.
```

Take note of the token. We then replace the string `<REPLACE-ME>` in the `hiera.yaml-after-provision` file

This file configures how Hiera uses the Vault backend to talk to Vault.

This is one of the cooler new features of Hiera 5: per branch and easier to configure
Hiera backends. We're using https://github.com/davealden/hiera-vault for the backend.

Ours looks like this:

```yaml
---
version: 5
hierarchy:
  - name: "Hiera-vault lookup"
    lookup_key: hiera_vault
    options:
      confine_to_keys:
        - '^vault_.*'
        - '^.*_password$'
        - '^password.*'
      ssl_verify: false
      address: http://puppet:8200
      token: 97402490-eeb0-6530-13f6-fc0525503f23
      default_field: value
      mounts:
        generic:
          - secret/puppet/%{::trusted.certname}/
          - secret/puppet/common/
```

So, we're only performing lookups on keys that:
* Match a regex using the word `password`
* Contain the word Vault

This means we aren't slowing down compilation time by looking up every bit of
data within vault, which would slow down compilation a lot, as well as polluting
our Vault logs with a huge number of useless lookups.

Note: We're also disabling `ssl_verify`, as we're not running on SSL in our demo instance.
Obviously dont do this in your real deployment!

We then unseal Vault:

```
$ VAULT_ADDR='http://127.0.0.1:8200' vault unseal
Key (will be hidden):
```

Use 3 of the unseal keys from above.

There is a short piece of Puppet code on the node1 machine that will output a string
taken from the Hiera lookup, in this case talking to Vault:

```puppet
class profile::vault_message {

  $vault_notify = lookup({"name" => "vault_notify", "value_type" => String, "default_value" => "No Vault Secret Found", "merge" => "first"})
  notify { "testing vault ${vault_notify}":}

}
```

The key contains the word vault, so as mentioned previously, the plugin will do a Vault lookup.

So when Puppet runs, we'll see the string from Vault. If it can't find anything,
it'll return "No Vault Secret Found"

Then add a secret to the key given (`puppet/common/vault_notify`) to demonstrate the Vault Hiera backend using the token you were given:

```
$ VAULT_TOKEN=677b88e3-300c-3a5a-ea2f-72ba70be5516 VAULT_ADDR='http://127.0.0.1:8200' vault write secret/puppet/common/vault_notify value=hello_123
Success! Data written to: secret/puppet/common/vault_notify
```

Then, we run a Puppet run on our test node:

```
$ puppet agent -t
Info: Using configured environment 'production'
Info: Retrieving pluginfacts
Info: Retrieving plugin
Info: Retrieving locales
Info: Loading facts
Info: Caching catalog for node1.home
Info: Applying configuration version '1521467005'
Notice: testing vault hello_123
Notice: /Stage[main]/Profile::Vault_message/Notify[testing vault hello_123]/message: defined 'message' as 'testing vault hello_123'
Notice: Applied catalog in 0.14 seconds
[root@node1 vagrant]# exit
```

Now we change it, to prove it picks up changes from Vault:

```
$ VAULT_TOKEN=677b88e3-300c-3a5a-ea2f-72ba70be5516 VAULT_ADDR='http://127.0.0.1:8200' vault write secret/puppet/common/vault_notify value=gbye_123
Success! Data written to: secret/puppet/common/vault_notify
```

And see the message change:

```
$ puppet agent -t
Info: Using configured environment 'production'
Info: Retrieving pluginfacts
Info: Retrieving plugin
Info: Retrieving locales
Info: Loading facts
Info: Caching catalog for node1.home
Info: Applying configuration version '1521467005'
Notice: testing vault gbye_123
Notice: /Stage[main]/Profile::Vault_message/Notify[testing vault gbye_123]/message: defined 'message' as 'testing vault gbye_123'
Notice: Applied catalog in 0.14 seconds
[root@node1 vagrant]# exit
```

Neat huh? We can then move out secrets into Vault.

There's a few more changes I'd like to add to make it better:

* [Write Terraform code as an example of how to configure the Puppet secrets](https://www.terraform.io/docs/providers/vault/index.html)
* [Create a PupperServer AppRole, rather than using the master key
](https://www.vaultproject.io/docs/auth/approle.html)
* Try other secret backends to see if they create a better workflow

Check it out here: https://github.com/petems/puppet-hiera-vault-vagrant
