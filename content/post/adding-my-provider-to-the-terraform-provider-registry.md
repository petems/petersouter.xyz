+++
author = "Peter Souter"
categories = ["Tech", "Blog", "Terraform", "Golang"]
date = 2020-09-17T13:28:00Z
description = ""
draft = false
thumbnailImage = "/images/2018/07/golang_http_750.png"
coverImage = "/images/2018/07/golang_http.png"
slug = "adding-my-provider-to-the-terraform-provider-registry"
tags = ["Tech", "Blog", "Terraform", "Golang"]
title = "Adding my Provider to the Terraform Provider Registry"
+++

# Adding my Provider to the Terraform Provider Registry

I've blogged previously about my tinkering with my own Terraform provider for fetching external IPs: extip

One of the more fiddly parts of using a custom provider is how to use it with the rest of your Terraform code. You could either bundle it with terraform-bundle, or add it as git submodules to the repo you run your code in. B

## Terraform Provider Registry

Luckily the good folks on the Terraform Engineering team have thought of this, and have now extended the Terraform Registry to host Providers as well as modules.

## Step 1: Upgrade

It'd been a while since I'd tinkered on my repo, so there were some cleanup tasks I needed to get around to. First was to update it to use Terraform 0.12.


There were some changes required if you had complex data structures, but since I didn't, all I needed to do was move to newer Terraform:

```
go get github.com/hashicorp/terraform@v0.12.0
go mod tidy
go mod vendor
```

Then run my tests. I had a few failures as the error messages had changed between versions, but that was easily resolved:

```diff
- ExpectError: regexp.MustCompile("invalid or unknown key: this_doesnt_exist"),
+ ExpectError: regexp.MustCompile("An argument named \"this_doesnt_exist\" is not expected here."),
```

## Step 2: Validation and Cleanup

Freshly moved to 0.12, I was looking to add some clenaup and some validation for parameters. For example, I knew that there were helper methods for common validation steps for parameters, so why not validate that the URL being given for the resolver is a real URL?

Terraform has a ValidateFunc parameter for checking data, which you can provide a method to check it.

So for my resolver URL, we can use `IsURLWithHTTPorHTTPS`:

`func IsURLWithHTTPorHTTPS(i interface{}, k string) (_ []string, errors []error)`
> IsURLWithHTTPorHTTPS is a SchemaValidateFunc which tests if the provided value is of type string and a valid HTTP or HTTPS URL
> https://godoc.org/github.com/hashicorp/terraform-plugin-sdk/helper/validation#IsURLWithHTTPorHTTPS

We can then add that to the "resolver" schema in the provider:

```golang
  resolver": &schema.Schema{
    Type:        schema.TypeString,
    Optional:    true,
    Default:     "https://checkip.amazonaws.com/",
    Description: "The URL to use to resolve the external IP address\nIf not set, defaults to https://checkip.amazonaws.com/",
    Elem: &schema.Schema{
      Type: schema.TypeString,
    },
    ValidateFunc: validation.IsURLWithHTTPorHTTPS,
  },
```

All good right? Wrong!

```
==> Checking that code complies with gofmt requirements...
go test -i $(go list ./... |grep -v 'vendor') || exit 1
echo $(go list ./... |grep -v 'vendor') | \
    xargs -t -n4 go test  -timeout=30s -parallel=4
go test -timeout=30s -parallel=4 github.com/petems/terraform-provider-extip github.com/petems/terraform-provider-extip/extip
?     github.com/petems/terraform-provider-extip  [no test files]
panic: gob: registering duplicate types for "*tfdiags.rpcFriendlyDiag": *tfdiags.rpcFriendlyDiag != *tfdiags.rpcFriendlyDiag

goroutine 1 [running]:
encoding/gob.RegisterName(0x1cc98dd, 0x18, 0x1e1cae0, 0x0)
  /usr/local/opt/go/libexec/src/encoding/gob/type.go:820 +0x558
encoding/gob.Register(0x1e1cae0, 0x0)
  /usr/local/opt/go/libexec/src/encoding/gob/type.go:874 +0x123
github.com/hashicorp/terraform/tfdiags.init.0()
  /Users/petersouter/projects/terraform-provider-extip/vendor/github.com/hashicorp/terraform/tfdiags/rpc_friendly.go:58 +0x36
FAIL  github.com/petems/terraform-provider-extip/extip  1.393s
FAIL
make: *** [test] Error 1
```

Uh... what? 

I only found reference in this Github issue: https://github.com/hashicorp/terraform-plugin-sdk/issues/268

Essentially you're not able to import both Terraform core and the SDK validator.

That's when I rememebered that the Terraform team released the Terraform SDK late last year, and you no longer need to import Terraform itself

## Step 3: Moving to the SDK

> As of September 2019, Terraform provider developers importing the Go module github.com/hashicorp/terraform, known as Terraform Core, should switch to github.com/hashicorp/terraform-plugin-sdk, the Terraform Plugin SDK, instead.
> https://www.terraform.io/docs/extend/plugin-sdk.html

Luckily, it's super easy to move to the SDK with the migration tool:

```
$ go install github.com/hashicorp/tf-sdk-migrator
$ tf-sdk-migrator check
Checking Go runtime version ...
Go version 1.14: OK.
Checking whether provider uses Go modules...
Go modules in use: OK.
Checking version of github.com/hashicorp/terraform-plugin-sdk to determine if provider was already migrated...
Checking version of github.com/hashicorp/terraform used in provider...
Terraform version 0.12.7: OK.
Checking whether provider uses deprecated SDK packages or identifiers...
No imports of deprecated SDK packages or identifiers: OK.

All constraints satisfied. Provider can be migrated to the new SDK.
```

It actually simplfies the go.mod file a lot as well:

```diff
go 1.14

require (
-  github.com/hashicorp/go-hclog v0.8.0 // indirect
   github.com/hashicorp/hcl v1.0.0 // indirect
-  github.com/hashicorp/hil v0.0.0-20190212132231-97b3a9cdfa93 // indirect
-  github.com/hashicorp/terraform v0.12.0
-  github.com/mitchellh/go-homedir v1.1.0 // indirect
+  github.com/hashicorp/terraform-plugin-sdk v1.7.0
)
```

After that everyhing works fine. We also have the benefit of slimming the `vendor/` folder a lot, as Terraform has a lot of library bloat that you dont need in a provider.

## Step 4: Cleaning up the last features

I'd been meaning to add a few features,

* Add configuration of the consensus timing (ie. how long it will wait to resolve)
* Add option of getting ipv6 or ipv4 ipaddress Validate if returned address is a valid IP 

I ended up simplifying this a lot into two features: Client timeout and address validation.

### Client Tiemout 

Client timeout was pretty simple, just needed to add an extra option and then add a timeout to the http client:

```golang
var netClient = &http.Client{
    Timeout: time.Duration(clientTimeout) * time.Millisecond,
  }

  rsp, err := netClient.Get(service)
  if err != nil {
    return "", err
  }
```

It's actually pretty important because by default Go's HTTP Client [has an unlimited timeout if not specified](https://medium.com/@nate510/don-t-use-go-s-default-http-client-4804cb19f779).

### IP Validation

Again, mostly a pretty simple option: add a boolean option to check if the response given from the resolver is a real IP:

```golang
  if v, ok := d.GetOkExists("validate_ip"); ok {
    if v.(bool) {
      ipParse := net.ParseIP(ip)
      if ipParse == nil {
        return fmt.Errorf("validate_ip was set to true, and information from resolver was not valid IP: %s", ip)
      }
    }
  }
```

## Step 5: Additional Testing

I refactored the tests and made sure I had 100% test coverage. I already was using httptest, so it was mostly just adding additional paths to my `httptest.Server`:

```golang
func setUpMockHTTPServer() *httptest.Server {
  Server := httptest.NewServer(
    http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {

      w.Header().Set("Content-Type", "text/plain")
      if r.URL.Path == "/meta_200.txt" {
        w.WriteHeader(http.StatusOK)
        w.Write([]byte("127.0.0.1"))
      } else if r.URL.Path == "/meta_404.txt" {
        w.WriteHeader(http.StatusNotFound)
      } else {
        w.WriteHeader(http.StatusNotFound)
      }
    }),
  )

  return Server
}
```

So we can just add extra pathing for our new test cases

### Client Timeout Testing

Just needed to add a response that sleeps and set the timeout limit lower than 2000ms

```golang
} else if r.URL.Path == "/meta_timeout.txt" {
  time.Sleep(2000 * time.Millisecond)
  w.WriteHeader(http.StatusOK)
  w.Write([]byte("127.0.0.1"))
}
```

### Hijack Testing

This one wasn't a use case I needed, but hijacking seems to fail in different ways, so it was nice to add a bit of fuzz

```golang
  w.WriteHeader(http.StatusNotFound)
  } else if r.URL.Path == "/meta_hijack.txt" {
    w.WriteHeader(100)
    w.Write([]byte("Hello3"))
    hj, _ := w.(http.Hijacker)
    conn, _, _ := hj.Hijack()
    conn.Close()
  }
```

### Failed Response Testing

This was so I could hit 100% test coverage by testing the body read happening in `buf, err := ioutil.ReadAll(rsp.Body)`

With some help from a StackOverflow answer:

> The easiest way is to generate an invalid HTTP response from the test handler.
> How to do that? There are many ways, a simple one is to "lie" about the content length:
> ```
> handler := func(w http.ResponseWriter, r *http.Request) {
>    w.Header().Set("Content-Length", "1")
> }
> ```
> This handler tells it has 1 byte body, but actually it sends none. So at the other end (the client) when attempting to read 1 byte from it, obviously that won't succeed, and will result in the following error:
> `Unable to read from body unexpected EOF`

So, just adding this was enough to get 100% test coverage:

```
bodyErrorServer := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
  w.Header().Set("Content-Length", "1")
}))

defer bodyErrorServer.Close()
```

(For some reason, when I put it as a response from a path it won't error, but when setting it as a response to any request it does)

## Step 6: Registry Pipeline Steps

So at this point, I think the provider is as ready as it'll ever be, feature and testing-wise, so we just need to get ready for the Terraform Registry.

Based on the steps from the Publishing Providers guide, I needed to do the following:

https://www.terraform.io/docs/registry/providers/publishing.html

### Add documentation

* Add a Github action to publish it to the registry

Adding documentation was fairly simple (although I ended up forgetting)

### Create a Github release 

Creating a Github release was also fairly straightforward, as Github automatically creates a release when you create a git tag:

```
git tag v0.1.0
git push --tags
```

### Push the Release with a GitHub Action

Again, mostly fairly simple, first we add a action config file:

```
# This GitHub action can publish assets for release when a tag is created.
# Currently its setup to run on any tag that matches the pattern "v*" (ie. v0.1.0).
#
# This uses an action (paultyng/ghaction-import-gpg) that assumes you set your 
# private key in the `GPG_PRIVATE_KEY` secret and passphrase in the `PASSPHRASE`
# secret. If you would rather own your own GPG handling, please fork this action
# or use an alternative one for key handling.
#
# You will need to pass the `--batch` flag to `gpg` in your signing step 
# in `goreleaser` to indicate this is being used in a non-interactive mode.
#
name: release
on:
  push:
    tags:
      - 'v*'
jobs:
  goreleaser:
    runs-on: ubuntu-latest
    steps:
      -
        name: Checkout
        uses: actions/checkout@v2
      -
        name: Unshallow
        run: git fetch --prune --unshallow
      -
        name: Set up Go
        uses: actions/setup-go@v2
        with:
          go-version: 1.14
      -
        name: Import GPG key
        id: import_gpg
        uses: paultyng/ghaction-import-gpg@v2.1.0
        env:
          GPG_PRIVATE_KEY: ${{ secrets.GPG_PRIVATE_KEY }}
          PASSPHRASE: ${{ secrets.PASSPHRASE }}
      -
        name: Run GoReleaser
        uses: goreleaser/goreleaser-action@v2
        with:
          version: latest
          args: release --rm-dist
        env:
          GPG_FINGERPRINT: ${{ steps.import_gpg.outputs.fingerprint }}
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### Signing the release

We need to add a GPG key to the repository and Registry so we can sign the release.

I ended up generating a new key via Keybase and using that (via the steps given [in this blog](https://blog.scottlowe.org/2017/09/06/using-keybase-gpg-macos/))

From there we add in the `GPG_PRIVATE_KEY` value to the repo under it's "Secrets" so we can sign the release

And then add the public key from the Private key we used earlier on to our repo on the Registry so it can verify the signing is valid:

![](/images/2020/09/provider-signing-keys.png)

### Push a release

I actually forgot to do the documentation, but I cut a release and it pushed with no issues.

You can see it builds a release for several different Operating Systems and architectures:

![](/images/2020/09/github-release-page.png)

From there, it'll be in the registry no issues:

![](/images/2020/09/registry-page.png)

## Step 6: Use the new Provider link in Terraform code

Now for the final test: Actually using it in our code!

From Terraform 0.13 onward, we can now specify:

```terraform
terraform {
  required_providers {
    extip = {
      source = "petems/extip"
      version = "0.1.0"
    }
  }
}

data "extip" "external_ip_from_aws" {
  resolver = "https://checkip.amazonaws.com/"
}

output "external_ip_from_aws" {
  value = data.extip.external_ip_from_aws.ipaddress
}
```

Then when we do a terraform init...

```

Initializing the backend...

Initializing provider plugins...
- Finding petems/extip versions matching "0.1.0"...
- Installing petems/extip v0.1.0...
- Installed petems/extip v0.1.0 (self-signed, key ID 1E81AE5659BD2F20)

Partner and community providers are signed by their developers.
If you'd like to know more about provider signing, you can read about it here:
https://www.terraform.io/docs/plugins/signing.html

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

We can see we're downloading the binary from the Registry and checking it was signed correctly

Then we run the code to see that everythings good:

```
data.extip.external_ip_from_aws: Refreshing state...

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
 <= read (data resources)

Terraform will perform the following actions:

  # data.extip.external_ip_from_aws will be read during apply
  # (config refers to values not yet known)
 <= data "extip" "external_ip_from_aws"  {
        client_timeout = 1000
      ~ id             = "2020-09-17 20:54:40.923151 +0000 UTC" -> "2020-09-17 20:54:41.511612 +0000 UTC"
        ipaddress      = "158.146.25.170"
        resolver       = "https://checkip.amazonaws.com/"
    }

Plan: 0 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

data.extip.external_ip_from_aws: Reading... [id=2020-09-17 20:54:40.923151 +0000 UTC]
data.extip.external_ip_from_aws: Read complete after 0s [id=2020-09-17 20:54:41.511612 +0000 UTC]

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

external_ip_from_aws = 158.146.25.170
```

So there we have it: A fully released provider avaliable on the public registry. 