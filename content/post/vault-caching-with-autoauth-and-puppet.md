+++
author = "Peter Souter"
categories = ["Tech", "Blog", "Terraform", "Puppet"]
date = 2020-02-12T12:07:00Z
description = ""
draft = false
thumbnailImage = "/images/2020/02/Vault-Agent-Auto-Auth_750.png"
coverImage = "/images/2020/02/Vault-Agent-Auto-Auth.png"
slug = "vault-caching-with-autoauth-and-puppet"
tags = ["Tech", "Blog", "Terraform", "Puppet"]
title = "Vault Caching with Auto-Auth and Puppet"
+++

# Vault Caching with Auto-Auth and Puppet

So I've done a lot of work with Vault and Puppet and how they integrate with each other.

I was recenlty posed the question:

> How would these Puppet runs calling out for secrets affect the performance of Vault, and if it was possible to cache the results?

So I did a little digging and the answer is **Yes, it's possible!**

## Vault Caching

In the [1.1.0](https://www.hashicorp.com/blog/vault-1-1/) release of Vault, we added the ability to run `vault agent` as a caching proxy.

> Vault Agent Caching: Vault Agent can now be configured to act as a caching proxy to Vault. Clients can send requests to Vault Agent and the request will be proxied to the Vault server and cached locally in Agent. Currently Agent will cache generated leases and tokens and keep them renewed. The proxy can also use the Auto Auth feature so clients do not need to authenticate to Vault, but rather can make requests to Agent and have Agent fully manage token lifecycle.

So, you run `vault agent` as a deamon on your system, and instead of having to point to the Vault cluster and provide a token for authentication, that all happens transparently via the proxy.

> In my examples I'm running the vault agent in the background so we can see the logs (eg. `vault agent -config=./vault_agent_config.hcl &`), but normally this would be run as a service with something like a systemd service file

So, we can set `VAULT_AGENT_ADDR` and have no token set and it will still authenticate using the token from the auto-auth configuration:

```
[root@node1 vagrant]# export VAULT_AGENT_ADDR=http://127.0.0.1:8200
[root@node1 vagrant]# export VAULT_TOKEN=
[root@node1 vagrant]# vault kv get kv/test
2020-02-12T20:45:14.305Z [INFO]  cache: received request: method=GET path=/v1/sys/internal/ui/mounts/kv/test
2020-02-12T20:45:14.305Z [INFO]  cache.apiproxy: forwarding request: method=GET path=/v1/sys/internal/ui/mounts/kv/test
2020-02-12T20:45:14.339Z [INFO]  cache: received request: method=GET path=/v1/kv/test
2020-02-12T20:45:14.339Z [INFO]  cache.apiproxy: forwarding request: method=GET path=/v1/kv/test
=== Data ===
Key    Value
---    -----
foo    bar
```

## vault_lookup

In Puppet 6, Puppet added the ability to run functions on agents, via the new [Deferred functions](https://puppet.com/docs/puppet/6.0/write_a_puppet_function_to_store_secrets.html) call.

Since the Puppet agent system will have certificates as part of the configuration with the puppeserver, we can use this certificate chain to authenticate to a Vault backend and retrive secrets.

This is implemented in the [vault_lookup](https://github.com/voxpupuli/puppet-vault_lookup/) function:

```ruby
def lookup(path, vault_url = nil)
    if vault_url.nil?
      Puppet.debug 'No Vault address was set on function, defaulting to value from VAULT_ADDR env value'
      vault_url = ENV['VAULT_ADDR']
      raise Puppet::Error, 'No vault_url given and VAULT_ADDR env variable not set' if vault_url.nil?
    end

    uri = URI(vault_url)
    # URI is used here to just parse the vault_url into a host string
    # and port; it's possible to generate a URI::Generic when a scheme
    # is not defined, so double check here to make sure at least
    # host is defined.
    raise Puppet::Error, "Unable to parse a hostname from #{vault_url}" unless uri.hostname

    use_ssl = uri.scheme == 'https'
    connection = Puppet::Network::HttpPool.http_instance(uri.host, uri.port, use_ssl)

    token = get_auth_token(connection)

    secret_response = connection.get("/v1/#{path}", 'X-Vault-Token' => token)
    unless secret_response.is_a?(Net::HTTPOK)
      message = "Received #{secret_response.code} response code from vault at #{uri.host} for secret lookup"
      raise Puppet::Error, append_api_errors(message, secret_response)
    end

    begin
      data = JSON.parse(secret_response.body)['data']
    rescue StandardError
      raise Puppet::Error, 'Error parsing json secret data from vault response'
    end

    Puppet::Pops::Types::PSensitiveType::Sensitive.new(data)
  end
```

We then call this deffered function in our Puppet code:

```puppet
class profile::vault_message {

  $vault_lookup = {
    'vault' => Deferred('vault_lookup::lookup',
                    ["kv/test", 'http://vault.vm:8200']),
  }

  notify { 'Secret from Vault':
    message => Deferred('inline_epp',
               ['<%= $vault.unwrap %>', $vault_lookup]),
  }

}
```

And when the puppet agent run happens, we can see the secret:

```
[root@node1 vagrant]# puppet agent -t
Notice: {foo => bar}
Notice: /Stage[main]/Profile::Vault_message/Notify[Secret from Vault]/message: defined 'message' as '{foo => bar}'
Notice: Applied catalog in 0.22 seconds
```

However, every time it runs it creates a new token from the certs:

```
  def get_auth_token(connection)
    response = connection.post('/v1/auth/cert/login', '')
    unless response.is_a?(Net::HTTPOK)
      message = "Received #{response.code} response code from vault at #{connection.address} for authentication"
      raise Puppet::Error, append_api_errors(message, response)
    end

    begin
      token = JSON.parse(response.body)['auth']['client_token']
    rescue StandardError
      raise Puppet::Error, 'Unable to parse client_token from vault response'
    end

    raise Puppet::Error, 'No client_token found' if token.nil?

    token
  end
```

Creating this lease and tokens is a more expensive task:

> But outside of that, all the regular tokens—not batch tokens; we call them "service tokens" now—that is expensive. The reason I call it expensive is because, when a token is created, it needs to store itself. And it has multiple indexes along with it. It has something called "a parent index," and it has a token accessor. If replication is in play, all the data will also be replicated in the Write-Ahead Logs that we use for replication to work. So it gets replicated there.

So, we can try and make things more lightweight, but running the vault agent as a proxy, and letting that handle the cert authentication instead:

With a little experimentation, I got a basic `vault agent` working:


```hcl
exit_after_auth = false
pid_file = "./pidfile"

auto_auth {
  method "cert" {

  }

  sink "file" {
    config = {
      path = "/tmp/vault-cert-token-via-agent"
    }
  }
}

cache {
  use_auto_auth_token = true
}

listener "tcp" {
  address = "127.0.0.1:8200"
  tls_disable = true
}

vault {
  tls_disable = false
  client_key  = "/etc/puppetlabs/puppet/ssl/private_keys/node1.vm.pem"
  client_cert = "/etc/puppetlabs/puppet/ssl/certs/node1.vm.pem"
  ca_cert     = "/etc/puppetlabs/puppet/ssl/certs/ca.pem"
  address     = "https://vault.vm:8200"
}

```

When we run the daemon, we can see that it's renewed the token and will handle the lifecycle for certificates:

```
[root@node1 vagrant]# vault agent -config=./vault_agent_config.hcl &
==> Vault server started! Log data will stream in below:

==> Vault agent configuration:

           Api Address 1: http://127.0.0.1:8200
                     Cgo: disabled
               Log Level: info
                 Version: Vault v1.3.2

2020-02-10T20:55:34.348Z [INFO]  sink.file: creating file sink
2020-02-10T20:55:34.349Z [INFO]  sink.file: file sink configured: path=/tmp/vault-cert-token-via-agent mode=-rw-r-----
2020-02-10T20:55:34.350Z [INFO]  auth.handler: starting auth handler
2020-02-10T20:55:34.350Z [INFO]  auth.handler: authenticating
2020-02-10T20:55:34.351Z [INFO]  sink.server: starting sink server
2020-02-10T20:55:34.351Z [INFO]  template.server: starting template server
2020-02-10T20:55:34.351Z [INFO]  template.server: no templates found
2020-02-10T20:55:34.351Z [INFO]  template.server: template server stopped
2020-02-10T20:55:34.384Z [INFO]  auth.handler: authentication successful, sending token to sinks
2020-02-10T20:55:34.384Z [INFO]  auth.handler: starting renewal process
2020-02-10T20:55:34.384Z [INFO]  sink.file: token written: path=/tmp/vault-cert-token-via-agent
2020-02-10T20:55:34.417Z [INFO]  auth.handler: renewed auth token
```


Since we no longer need to lookup the token, we then remove token logic from the `vault_lookup` function, then point the `vault_lookup` function to the local Vault agent (`localhost:8200`)

```
class profile::vault_message {

  $vault_lookup = {
    'vault' => Deferred('vault_lookup::lookup',
                    ["kv/test", 'http://localhost:8200']),
  }

  notify { 'Secret from Vault':
    message => Deferred('inline_epp',
               ['<%= $vault.unwrap %>', $vault_lookup]),
  }

}
```

We then run the And now we're running against the proxy and not generating a new token each time:

```
Info: Retrieving locales
Info: Loading facts
2020-02-12T21:07:11.016Z [INFO]  cache: received request: method=GET path=/v1/kv/test
2020-02-12T21:07:11.017Z [INFO]  cache.apiproxy: forwarding request: method=GET path=/v1/kv/test
Info: Caching catalog for node1.vm
Info: Applying configuration version '1581541630'
Notice: {foo => bar}
Notice: /Stage[main]/Profile::Vault_message/Notify[Secret from Vault]/message: defined 'message' as '{foo => bar}'
Notice: Applied catalog in 0.25 seconds
```

This reduces the overhead of leases (as it will auto-renew the cert auth only when it expires).

## Caching

You might notice that for the KV secret itself, it's not actually caching:

```
[root@node1 vagrant]# VAULT_AGENT_ADDR=http://127.0.0.1:8200 vault kv get kv/test
2020-02-10T20:03:21.496Z [INFO]  cache: received request: method=GET path=/v1/sys/internal/ui/mounts/kv/test
2020-02-10T20:03:21.496Z [DEBUG] cache: using auto auth token: method=GET path=/v1/sys/internal/ui/mounts/kv/test
2020-02-10T20:03:21.496Z [DEBUG] cache.leasecache: forwarding request: method=GET path=/v1/sys/internal/ui/mounts/kv/test
2020-02-10T20:03:21.496Z [INFO]  cache.apiproxy: forwarding request: method=GET path=/v1/sys/internal/ui/mounts/kv/test
2020-02-10T20:03:21.527Z [DEBUG] cache.leasecache: pass-through response; secret not renewable: method=GET path=/v1/sys/internal/ui/mounts/kv/test
```

This is because right now, Vault agent is only designed to cache secrets that are long-lived and have an expiration. Right now, that's dynamic credential generation: DB passwords, AWS credentials and the like.

KV is not included but it might be in the future:

> Reading KV secrets are also not cached because it does not create tokens and leases. But we have plans to make sure that this can also be supported. There are some underpinnings that we are working on that can enable this. But right now Agent cannot do it.

Want to know more?

* https://www.hashicorp.com/resources/client-side-response-caching-using-vault-agent
* https://www.vaultproject.io/docs/agent/autoauth/methods/cert/
