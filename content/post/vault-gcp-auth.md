+++
author = "Peter Souter"
categories = ["Tech", "Blog", "Vault"]
date = 2018-08-12T22:10:09Z
description = "Demonstrating the GCE Auth method for Vault"
draft = false
thumbnailImage = "/images/2018/07/vault_gcp_iam_750.png"
coverImage = "/images/2018/07/vault_gcp_iam.jpg"
slug = "gcp-auth-for-vault"
tags = ["Tech", "GCE", "Vault"]
title = "Demonstrating the GCE Auth method for Vault"
+++

# Demonstrating the GCE Auth method for Vault

So, I discussed in my previous blog post how I was trying to automate my Vault and GCE demo, so lets talk about that!

## Understanding Vault

As I've been working with customers and the community on the HashiCorp stack, I've been beginning to understand the core philosophies behind a lot of the products.

Mitchell gave a great presentation on Vault's 0.10 release at the London HashiCorp User Group a few months ago, and there was a slide in there that really helped me understand how Vault works:

![Vault Explained](/images/2018/07/jwt_gcp_explanation.png)

And that's ultimately how Vault works: it's trust is setup by trusting another authentication method, be that something human friendly, like an Okta or Github login, or an API like a clouds IAM.

For the demo Mitchell gave, he focused on the new GCE Auth method, so I thought I'd start with that as he explained it so well, then work on AWS and Azure afterward.

If you want to see that original demo, here's the recording from the Paris HashiCorp User Group: https://www.hashicorp.com/resources/secrets-in-the-cloud-with-vault-and-vault-0-10

## GCE Auth - How does it work?

The Vault authentication workflow for GCE instances is as follows:

  1. A client logins into a GCE instances and [obtains an instance identity metadata token](https://cloud.google.com/compute/docs/instances/verifying-instance-identity).
  2. The client requests to login using this token (a JWT) and gives a role name to Vault.
  3. Vault uses the `kid` header value, which contains the ID of the key-pair used to generate the JWT, to find the OAuth2 public cert to verify this JWT.
  4. Vault authorizes the confirmed instance against the given role. See the [authorization section](#authorization-workflow) to see how each type of role handles authorization.
    - Taken from https://www.vaultproject.io/docs/auth/gcp.html

And there's a helpful diagram of how this looks:

![Vault Explained](/images/2018/07/jwt_gcp_explanation.png)

## GCE Auth - What does it look like?

For Mitchell's demo, he did the whole thing using [ngrok](https://ngrok.com/) with a local instance of Vault running in dev mode. Which is fine, but I thought let's make this a little more flashy.

So I wrote some Terraform code to create all the pieces I needed for a demo.

It looks like this:

* Vault-server - A GCE instance running Vault
* Vault-happy  - A GCE instance in the bound region - This should be able to get a token from Vault
* Vault-sad    - A GCE instance not in the bound region - This should not be able to get a token from Vault
* vault-auth-checker - A Service Account with the Compute Viewer and Security Viewer permissions - Vault will use these credentials for the GCE backend

So, we run a `terraform plan` and make sure everything makes sense:

```
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

data.http.current_ip: Refreshing state...

------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create
 <= read (data resources)

Terraform will perform the following actions:

 <= data.google_iam_policy.vault_policy
      id:                                                  <computed>
      binding.#:                                           "2"
      binding.~1288767549.members.#:                       <computed>
      binding.~1288767549.role:                            "roles/iam.securityReviewer"
      binding.~3959788026.members.#:                       <computed>
      binding.~3959788026.role:                            "roles/compute.viewer"
      policy_data:                                         <computed>

 <= data.template_file.requester_bootstrap
      id:                                                  <computed>
      rendered:                                            <computed>
      template:                                            "#!/bin/bash -v\n\napt-get update -y\n\napt-get install curl jq -y\n\ncat <<EOF >> /root/.vault_credentials\nfunction set_vault_credentials {\n  VAULT_ADDR=${vault_addr}\n\n  JWT=\\$(curl -H \"Metadata-Flavor: Google\"\\\n  -G \\\n  --data-urlencode \"audience=$VAULT_ADDR/vault/web\"\\\n  --data-urlencode \"format=full\" \\\n  \"http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/identity\")\n\n  check_errors=\\$(curl \\\n    --request POST \\\n    --data \"{\\\"role\\\": \\\"web\\\", \\\"jwt\\\": \\\"\\$JWT\\\"}\" \\\n    \"${vault_addr}/v1/auth/gcp/login\" | jq -r \".errors\")\n\n  if [ \"\\$check_errors\" == \"null\" ]\n  then\n    VAULT_TOKEN=\\$(curl \\\n    --request POST \\\n    --data \"{\\\"role\\\": \\\"web\\\", \\\"jwt\\\": \\\"\\$JWT\\\"}\" \\\n    \"${vault_addr}/v1/auth/gcp/login\" | jq -r \".auth.client_token\")\n  else\n    echo \"Error from vault: \\$check_errors\"\n    exit 1\n  fi\n\n  export VAULT_ADDR\n  export VAULT_TOKEN\n}\n\nset_vault_credentials\n\necho 'VAULT_ADDR and VAULT_TOKEN exported to environment'\nEOF\n"
      vars.%:                                              <computed>

  + google_compute_firewall.allow_vault_access
      id:                                                  <computed>
      allow.#:                                             "2"
      allow.1367131964.ports.#:                            "0"
      allow.1367131964.protocol:                           "icmp"
      allow.654300761.ports.#:                             "2"
      allow.654300761.ports.0:                             "22"
      allow.654300761.ports.1:                             "8200"
      allow.654300761.protocol:                            "tcp"
      destination_ranges.#:                                <computed>
      direction:                                           <computed>
      name:                                                "allow-vault-access"
      network:                                             "${google_compute_network.vault_gcp_demo_network.self_link}"
      priority:                                            "1000"
      project:                                             "${google_project.vault_gcp_demo.project_id}"
      self_link:                                           <computed>
      source_ranges.#:                                     <computed>
      target_tags.#:                                       "2"
      target_tags.385064633:                               "vault-requester"
      target_tags.3859817612:                              "vault-server"

  + google_compute_instance.vault_happy
      id:                                                  <computed>
      boot_disk.#:                                         "1"
      boot_disk.0.auto_delete:                             "true"
      boot_disk.0.device_name:                             <computed>
      boot_disk.0.disk_encryption_key_sha256:              <computed>
      boot_disk.0.initialize_params.#:                     "1"
      boot_disk.0.initialize_params.0.image:               "debian-cloud/debian-8"
      boot_disk.0.initialize_params.0.size:                <computed>
      boot_disk.0.initialize_params.0.type:                <computed>
      can_ip_forward:                                      "false"
      cpu_platform:                                        <computed>
      create_timeout:                                      "4"
      deletion_protection:                                 "false"
      guest_accelerator.#:                                 <computed>
      instance_id:                                         <computed>
      label_fingerprint:                                   <computed>
      machine_type:                                        "f1-micro"
      metadata_fingerprint:                                <computed>
      metadata_startup_script:                             "${data.template_file.requester_bootstrap.rendered}"
      name:                                                "vault-requester-happy"
      network_interface.#:                                 "1"
      network_interface.0.access_config.#:                 "1"
      network_interface.0.access_config.0.assigned_nat_ip: <computed>
      network_interface.0.access_config.0.nat_ip:          <computed>
      network_interface.0.access_config.0.network_tier:    <computed>
      network_interface.0.address:                         <computed>
      network_interface.0.name:                            <computed>
      network_interface.0.network:                         "default"
      network_interface.0.network_ip:                      <computed>
      network_interface.0.subnetwork_project:              <computed>
      project:                                             "${google_project.vault_gcp_demo.project_id}"
      scheduling.#:                                        <computed>
      self_link:                                           <computed>
      service_account.#:                                   "1"
      service_account.0.email:                             <computed>
      service_account.0.scopes.#:                          "6"
      service_account.0.scopes.1632638332:                 "https://www.googleapis.com/auth/devstorage.read_only"
      service_account.0.scopes.172152165:                  "https://www.googleapis.com/auth/logging.write"
      service_account.0.scopes.316356861:                  "https://www.googleapis.com/auth/service.management.readonly"
      service_account.0.scopes.3663490875:                 "https://www.googleapis.com/auth/servicecontrol"
      service_account.0.scopes.3859019814:                 "https://www.googleapis.com/auth/trace.append"
      service_account.0.scopes.4177124133:                 "https://www.googleapis.com/auth/monitoring.write"
      tags.#:                                              "1"
      tags.385064633:                                      "vault-requester"
      tags_fingerprint:                                    <computed>
      zone:                                                "europe-west2-a"

  + google_compute_instance.vault_sad
      id:                                                  <computed>
      boot_disk.#:                                         "1"
      boot_disk.0.auto_delete:                             "true"
      boot_disk.0.device_name:                             <computed>
      boot_disk.0.disk_encryption_key_sha256:              <computed>
      boot_disk.0.initialize_params.#:                     "1"
      boot_disk.0.initialize_params.0.image:               "debian-cloud/debian-8"
      boot_disk.0.initialize_params.0.size:                <computed>
      boot_disk.0.initialize_params.0.type:                <computed>
      can_ip_forward:                                      "false"
      cpu_platform:                                        <computed>
      create_timeout:                                      "4"
      deletion_protection:                                 "false"
      guest_accelerator.#:                                 <computed>
      instance_id:                                         <computed>
      label_fingerprint:                                   <computed>
      machine_type:                                        "f1-micro"
      metadata_fingerprint:                                <computed>
      metadata_startup_script:                             "${data.template_file.requester_bootstrap.rendered}"
      name:                                                "vault-requester-sad"
      network_interface.#:                                 "1"
      network_interface.0.access_config.#:                 "1"
      network_interface.0.access_config.0.assigned_nat_ip: <computed>
      network_interface.0.access_config.0.nat_ip:          <computed>
      network_interface.0.access_config.0.network_tier:    <computed>
      network_interface.0.address:                         <computed>
      network_interface.0.name:                            <computed>
      network_interface.0.network:                         "default"
      network_interface.0.network_ip:                      <computed>
      network_interface.0.subnetwork_project:              <computed>
      project:                                             "${google_project.vault_gcp_demo.project_id}"
      scheduling.#:                                        <computed>
      self_link:                                           <computed>
      service_account.#:                                   "1"
      service_account.0.email:                             <computed>
      service_account.0.scopes.#:                          "6"
      service_account.0.scopes.1632638332:                 "https://www.googleapis.com/auth/devstorage.read_only"
      service_account.0.scopes.172152165:                  "https://www.googleapis.com/auth/logging.write"
      service_account.0.scopes.316356861:                  "https://www.googleapis.com/auth/service.management.readonly"
      service_account.0.scopes.3663490875:                 "https://www.googleapis.com/auth/servicecontrol"
      service_account.0.scopes.3859019814:                 "https://www.googleapis.com/auth/trace.append"
      service_account.0.scopes.4177124133:                 "https://www.googleapis.com/auth/monitoring.write"
      tags.#:                                              "1"
      tags.385064633:                                      "vault-requester"
      tags_fingerprint:                                    <computed>
      zone:                                                "europe-west1-b"

  + google_compute_instance.vault_server
      id:                                                  <computed>
      boot_disk.#:                                         "1"
      boot_disk.0.auto_delete:                             "true"
      boot_disk.0.device_name:                             <computed>
      boot_disk.0.disk_encryption_key_sha256:              <computed>
      boot_disk.0.initialize_params.#:                     "1"
      boot_disk.0.initialize_params.0.image:               "debian-cloud/debian-8"
      boot_disk.0.initialize_params.0.size:                <computed>
      boot_disk.0.initialize_params.0.type:                <computed>
      can_ip_forward:                                      "false"
      cpu_platform:                                        <computed>
      create_timeout:                                      "4"
      deletion_protection:                                 "false"
      guest_accelerator.#:                                 <computed>
      instance_id:                                         <computed>
      label_fingerprint:                                   <computed>
      machine_type:                                        "n1-standard-1"
      metadata_fingerprint:                                <computed>
      metadata_startup_script:                             "#!/bin/bash -v\n\napt-get update -y\n\napt-get install unzip wget -y\n\nwget https://releases.hashicorp.com/vault/0.10.3/vault_0.10.3_linux_amd64.zip\nunzip -j vault_*_linux_amd64.zip -d /usr/local/bin\n\nuseradd -r -g daemon -d /usr/local/vault -m -s /sbin/nologin -c \"Vault user\" vault\n\nmkdir /etc/vault /etc/ssl/vault /mnt/vault\nchown vault.root /etc/vault /etc/ssl/vault /mnt/vault\nchmod 750 /etc/vault /etc/ssl/vault\nchmod 700 /usr/local/vault\n\ncat <<EOF | sudo tee /etc/vault/config.hcl\nlistener \"tcp\" {\n  address = \"0.0.0.0:8200\"\n  tls_disable = 1\n}\nbackend \"file\" {\n  path = \"/mnt/vault/data\"\n}\ndisable_mlock = true\nui = true\nEOF\n\ncat <<EOF | sudo tee /etc/systemd/system/vault.service\n[Unit]\nDescription=Vault service\nAfter=network-online.target\n\n[Service]\nUser=vault\nGroup=daemon\nPrivateDevices=yes\nPrivateTmp=yes\nProtectSystem=full\nProtectHome=read-only\nSecureBits=keep-caps\nCapabilities=CAP_IPC_LOCK+ep\nCapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK\nNoNewPrivileges=yes\nExecStart=/usr/local/bin/vault server -config=/etc/vault/config.hcl\nKillSignal=SIGINT\nTimeoutStopSec=30s\nRestart=on-failure\nStartLimitInterval=60s\nStartLimitBurst=3\n\n[Install]\nWantedBy=multi-user.target\nEOF\n\nsudo chmod 0644 /etc/systemd/system/vault.service\n\nservice vault start\n"
      name:                                                "vault-server"
      network_interface.#:                                 "1"
      network_interface.0.access_config.#:                 "1"
      network_interface.0.access_config.0.assigned_nat_ip: <computed>
      network_interface.0.access_config.0.nat_ip:          <computed>
      network_interface.0.access_config.0.network_tier:    <computed>
      network_interface.0.address:                         <computed>
      network_interface.0.name:                            <computed>
      network_interface.0.network:                         "${google_compute_network.vault_gcp_demo_network.self_link}"
      network_interface.0.network_ip:                      <computed>
      network_interface.0.subnetwork_project:              <computed>
      project:                                             "${google_project.vault_gcp_demo.project_id}"
      scheduling.#:                                        <computed>
      self_link:                                           <computed>
      service_account.#:                                   "1"
      service_account.0.email:                             <computed>
      service_account.0.scopes.#:                          "6"
      service_account.0.scopes.1632638332:                 "https://www.googleapis.com/auth/devstorage.read_only"
      service_account.0.scopes.172152165:                  "https://www.googleapis.com/auth/logging.write"
      service_account.0.scopes.316356861:                  "https://www.googleapis.com/auth/service.management.readonly"
      service_account.0.scopes.3663490875:                 "https://www.googleapis.com/auth/servicecontrol"
      service_account.0.scopes.3859019814:                 "https://www.googleapis.com/auth/trace.append"
      service_account.0.scopes.4177124133:                 "https://www.googleapis.com/auth/monitoring.write"
      tags.#:                                              "1"
      tags.3859817612:                                     "vault-server"
      tags_fingerprint:                                    <computed>
      zone:                                                "europe-west2-a"

  + google_compute_network.vault_gcp_demo_network
      id:                                                  <computed>
      auto_create_subnetworks:                             "true"
      gateway_ipv4:                                        <computed>
      name:                                                "vault-gcp-demo"
      project:                                             "${google_project.vault_gcp_demo.project_id}"
      routing_mode:                                        <computed>
      self_link:                                           <computed>

  + google_project.vault_gcp_demo
      id:                                                  <computed>
      auto_create_network:                                 "true"
      billing_account:                                     "01DAE5-1D93E8-6D3B02"
      folder_id:                                           <computed>
      name:                                                "vault-gcp-demo"
      number:                                              <computed>
      org_id:                                              "622235425790"
      policy_data:                                         <computed>
      policy_etag:                                         <computed>
      project_id:                                          "${random_id.id.hex}"
      skip_delete:                                         <computed>

  + google_project_iam_policy.vault_policy
      id:                                                  <computed>
      etag:                                                <computed>
      policy_data:                                         "${data.google_iam_policy.vault_policy.policy_data}"
      project:                                             "${google_project.vault_gcp_demo.project_id}"
      restore_policy:                                      <computed>

  + google_project_services.vault_gcp_demo_services
      id:                                                  <computed>
      disable_on_destroy:                                  "true"
      project:                                             "${google_project.vault_gcp_demo.project_id}"
      services.#:                                          "4"
      services.1560437671:                                 "iam.googleapis.com"
      services.1568433289:                                 "oslogin.googleapis.com"
      services.2240314979:                                 "compute.googleapis.com"
      services.3604209692:                                 "iamcredentials.googleapis.com"

  + google_service_account.vault_auth_checker
      id:                                                  <computed>
      account_id:                                          "vault-auth-checker"
      display_name:                                        "Vault Auth Checker"
      email:                                               <computed>
      name:                                                <computed>
      project:                                             "${google_project.vault_gcp_demo.project_id}"
      unique_id:                                           <computed>

  + google_service_account_key.vault_auth_checker_credentials
      id:                                                  <computed>
      key_algorithm:                                       "KEY_ALG_RSA_2048"
      name:                                                <computed>
      private_key:                                         <computed>
      private_key_encrypted:                               <computed>
      private_key_fingerprint:                             <computed>
      private_key_type:                                    "TYPE_GOOGLE_CREDENTIALS_FILE"
      public_key:                                          <computed>
      public_key_type:                                     "TYPE_X509_PEM_FILE"
      service_account_id:                                  "${google_service_account.vault_auth_checker.name}"
      valid_after:                                         <computed>
      valid_before:                                        <computed>

  + local_file.vault_service_account_cred_file
      id:                                                  <computed>
      content:                                             "${base64decode(google_service_account_key.vault_auth_checker_credentials.private_key)}"
      filename:                                            "/Users/psouter/projects/vault-gcp-demo/vault-auth-checker-credentials.json"

  + random_id.id
      id:                                                  <computed>
      b64:                                                 <computed>
      b64_std:                                             <computed>
      b64_url:                                             <computed>
      byte_length:                                         "4"
      dec:                                                 <computed>
      hex:                                                 <computed>
      prefix:                                              "vault-gcp-demo-"


Plan: 12 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------
```

Then, we apply!

For the next steps, we need some manual intervention

## Initializing and Unsealing Vault

The cloud-init script for Vault will install the binary, but Vault still needs to be initialized and unsealed. We've already exported the `VAULT_ADDR` command we need to run from the Terraform output, so we can initialize this pretty easily! Either locally or on the machine itself.

```
$ vault operator init
```

Then unseal Vault:

```
$ vault operator unseal
```

## Enabling GCE Auth in Vault

This is a bit I think we could probably do more with Terraform in the future, but I haven't figured it out yet.

We CD into the `vault/` folder, and run terraform:

```
vault_policy.reader: Refreshing state... (ID: reader)
vault_generic_secret.demo_secret: Refreshing state... (ID: secret/demo)

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create
  ~ update in-place

Terraform will perform the following actions:

  + vault_generic_secret.demo_secret
      id:           <computed>
      data_json:    "{\"location\":\"London\"}"
      disable_read: "false"
      path:         "secret/demo"

  ~ vault_policy.reader
      policy:       "" => "path \"secret/demo\" {\n\n  capabilities = [\"read\"]\n}\n"


Plan: 1 to add, 1 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

vault_generic_secret.demo_secret: Creating...
  data_json:    "" => "{\"location\":\"London\"}"
  disable_read: "" => "false"
  path:         "" => "secret/demo"
vault_policy.reader: Modifying... (ID: reader)
  policy: "" => "path \"secret/demo\" {\n\n  capabilities = [\"read\"]\n}\n"
vault_generic_secret.demo_secret: Creation complete after 0s (ID: secret/demo)
vault_policy.reader: Modifications complete after 0s (ID: reader)

Apply complete! Resources: 1 added, 1 changed, 0 destroyed.
```

We then cd back to the main directory, and take the `vault-auth-checker-credentials.json` create by Terraform and use it for GCP auth:

```
$ cd ..
$ vault auth enable gcp
$ vault write auth/gcp/config \
credentials=@../vault-auth-checker-credentials.json
```

Create a role using the reader policy that Terraform has created, that only has access to get that one secret.

We use the output of the project we made earlier in Terraform as the project to bind it to.

```
$ vault write auth/gcp/role/web \
type=gce \
policies=reader \
project_id="$(terraform output project_id)" \
bound_region="europe-west2"
```

## The finished Vault Auth Setup

There we go. We now have:

* An initialized vault instance
* One secret in the K/V store
* A policy for access to that one secret called `reader`
* An auth policy tied to that `reader` policy that uses GCP IAM tied to a particular region

## SSH onto the Vault Happy and get a token

Vault happy is an instance that's in europe-west2. So we can access the secret!

We've created a file on disk with Terraform that set's the Vault credentials:

```
function set_vault_credentials {
  VAULT_ADDR=http://11.22.33.44:8200

  JWT=$(curl -H "Metadata-Flavor: Google"  -G   --data-urlencode "audience=/vault/web"  --data-urlencode "format=full"   "http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/identity")

  check_errors=$(curl     --request POST     --data "{\"role\": \"web\", \"jwt\": \"$JWT\"}"     "http://11.22.33.44:8200/v1/auth/gcp/login" | jq -r ".errors")

  if [ "$check_errors" == "null" ]
  then
    VAULT_TOKEN=$(curl     --request POST     --data "{\"role\": \"web\", \"jwt\": \"$JWT\"}"     "http://11.22.33.44:8200/v1/auth/gcp/login" | jq -r ".auth.client_token")
  else
    echo "Error from vault: $check_errors"
    exit 1
  fi

  export VAULT_ADDR
  export VAULT_TOKEN
}

set_vault_credentials

echo 'VAULT_ADDR and VAULT_TOKEN exported to environment'
```

So we can ssh in, ever manually or using the helpful `gcloud` command:

```
export instance_id=$(terraform output vault_happy_instance_id)
export project_id=$(terraform output project_id)

gcloud compute ssh ${instance_id} --project ${project_id}
```

So we can just source that file:

```
root@vault-requester-happy:~# source ~/.vault_credentials
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  1061  100  1061    0     0  16850      0 --:--:-- --:--:-- --:--:-- 17112
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  1875  100   788  100  1087    361    499  0:00:02  0:00:02 --:--:--   499
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  1875  100   788  100  1087    650    897  0:00:01  0:00:01 --:--:--   897
VAULT_ADDR and VAULT_TOKEN exported to environment
root@vault-requester-happy:~# env | grep VAULT
VAULT_ADDR=http://11.22.33.44:8200
VAULT_TOKEN=41aee9a1-0869-41ca-6b79-a34e73fbe071
```

We can then use that token to fetch out secret:

```
root@vault-requester-happy:~# curl     --header "X-Vault-Token: $VAULT_TOKEN"     $VAULT_ADDR/v1/secret/demo | jq "."
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   185  100   185    0     0  36779      0 --:--:-- --:--:-- --:--:-- 46250
{
  "location": "London"
}
```

And to prove our bindings work, we can do the same with our sad path (Our machine not on `europe-west2`:

```
export instance_id=$(terraform output vault_sad_instance_id)
export project_id=$(terraform output project_id)

gcloud compute ssh ${instance_id} --project ${project_id}
```

Try to source our Vault credentials:

```
source .vault_credentials
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  1058  100  1058    0     0  28697      0 --:--:-- --:--:-- --:--:-- 29388
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  1165  100    81  100  1084    157   2103 --:--:-- --:--:-- --:--:--  2104
Error from vault: [
  "instance zone europe-west1-b is not in role region 'europe-west2'"
]
```

## Conclusion

So I learnt some GCP and Terraform along the way, as well as Vault. I'm trying to add this to the official guide for Vault and GCP in the future.
