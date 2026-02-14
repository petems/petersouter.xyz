+++
author = "Peter Souter"
categories = ["Tech"]
date = 2018-07-01T12:07:00Z
description = ""
draft = false
thumbnailImage = "/images/2018/07/golang_http_750.png"
coverImage = "/images/2018/07/golang_http.png"
slug = "writing-and-playing-with-custom-terraform-providers"
tags = ["Blog", "Terraform", "Golang"]
title = "Writing and playing with custom Terraform Providers"
+++

# Writing and playing with custom Terraform Providers

I’ve been digging deeper on Terraform. It’s something I’ve tinkered with in the past, but I’ve not really sat down to really use it in anger and try and tie a large project together.

So, I picked something that I recently was doing manually: the configuration of a demo of Vault with the GCP backend. Right now I was doing most of the steps for that manually, and I wanted to automate the entire process, and have a fully reproducible demo environment created in GCP. That’s a larger project I’m going to blog about later, but for now I’m going to concentrate on one thing that came up that led me down a rabbit whole of creating a provider.

## What’s my IP?

One of the things that I realised was that as part of my setup for the Demo, I had a Vault instance available on the public internet, before it got initialized. The initialization step is extremely quick, but I always feel a little paranoid that someone might mess with it whilst it’s getting ready.

No problem: I can write some Terraform code to configure a GCP firewall:

```
resource "google_compute_firewall" "allow_vault_access" {
  project = "${google_project.vault_gcp_demo.project_id}"
  name    = "allow-vault-access"
  network = "${google_compute_network.vault_gcp_demo_network.self_link}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "8200"]
  }

  source_ranges = [
    ["0.0.0.0/24"]
  ]
  target_tags   = ["vault-server", "vault-requester"]

}
```

Right now, this is accepting 0.0.0.0, so anyone on the internet can access it. How can I make it use my current IP address?

But how do I do get my current IP to load in in the Terraform code? I went digging and found a thread that suggested using a Datasource resource:

```
data "http" "icanhazip" {
   url = "http://icanhazip.com"
}

resource "aws_security_group_rule" "ssh" {
  source_ip = "${data.http.icanhazip.body}"
}
```

Which worked like a charm, as long as you check the response from the URL and make sure it’s a valid string, no newlines and such.

But, I thought this would give me the perfect chance to play with some Golang and try writing a provider myself: a datasource that returns the current IP of the system.
Getting started

As someone who’s mainly dabbled in Ruby and Java, the go dependency system is super weird. Eventually it seemed to boil down to adding this to my dotfiles:

```
export GOPATH=$HOME/golang
export GOBIN=$GOPATH/bin
export GOROOT=/usr/local/opt/go/libexec
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:$GOROOT/bin
```

Then my repo I’m working on being inside the GOPATH folder:

```
~/golang/src/github.com/petems/terraform-provider-extip
```

Now here I cheated a bit. I’d already played with the Writing Custom Providers doc earlier this year, and got the demo setup working fine. But I realised I could get setup a lot faster if I re-used a lot of the existing http provider work. Ultimately the data source would look very similar, and it would already have a lot of the more difficult stuff pre-done, such as mocking out the calls to a web address. So I used the original http provider as a base and added new things into it.
Getting an external address.

I toyed with a few different ways of doing this. First I found an existing Golang library for fetching external IPs - https://github.com/GlenDC/go-external-ip

It had a lot of cool features, such as a built in logger, a pre-built list of external IP resolving websites, as well as a cool feature of a quorum of multiple websites with weighted voting.

Ultimately I got the code working using the library, but it was a little overkill. Adding a library for something I could do in way less lines?

So I ended up pulling it out and switching to a much more simpler option using the example code from the net/http library https://golang.org/pkg/net/http/:

```
resp, err := http.Get("http://example.com/")
if err != nil {
	// handle error
}
defer resp.Body.Close()
body, err := ioutil.ReadAll(resp.Body)
Then, we’re going to raise an error if the response is not 200:

if rsp.StatusCode != 200 {
  return "", fmt.Errorf("HTTP request error. Response code: %d", rsp.StatusCode)
}
```

Then, we wrap that in a function getExternalIPFrom() function, that takes a string of a url to get the external IP from:

```
func getExternalIPFrom(service string) (string, error) {
  rsp, err := http.Get(service)
  if err != nil {
    return "", err
  }

  defer rsp.Body.Close()

  if rsp.StatusCode != 200 {
    return "", fmt.Errorf("HTTP request error. Response code: %d", rsp.StatusCode)
  }

  buf, err := ioutil.ReadAll(rsp.Body)
  if err != nil {
    return "", err
  }

  return string(bytes.TrimSpace(buf)), nil
}
```


From there, we just need to write a schema for a parameter specifying what resolver url you want to use:

```
"resolver": &schema.Schema{
				Type:        schema.TypeString,
				Optional:    true,
				Default:     "https://checkip.amazonaws.com/",
				Description: "The URL to use to resolve the external IP address\nIf not set, defaults to https://checkip.amazonaws.com/",
				Elem: &schema.Schema{
					Type: schema.TypeString,
				},
			},
```

Then get that value:

```
resolver := d.Get("resolver").(string)
```

Then in our dataSourceRead, run that function with the resolver string, and bam working data source!

```
func dataSourceRead(d *schema.ResourceData, meta interface{}) error {

	resolver := d.Get("resolver").(string)

	ip, err := getExternalIPFrom(resolver)

	if err == nil {
		d.Set("ipaddress", string(ip))
		d.SetId(time.Now().UTC().String())
	} else {
		return fmt.Errorf("Error requesting external IP: %d", err)
	}

	return nil

}
```

And since the behaviour we were looking to test was very similar to the HTTP mocking of the original http provider, we could reuse a lot of the tests:

```
func TestDataSource_http404(t *testing.T) {
  testHttpMock := setUpMockHttpServer()

  defer testHttpMock.server.Close()

  resource.UnitTest(t, resource.TestCase{
    Providers: testProviders,
    Steps: []resource.TestStep{
      resource.TestStep{
        Config:      fmt.Sprintf(testDataSourceConfig_basic, testHttpMock.server.URL, 404),
        ExpectError: regexp.MustCompile("HTTP request error. Response code: 404"),
      },
    },
  })
}

func setUpMockHttpServer() *TestHttpMock {
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

  return &TestHttpMock{
    server: Server,
  }
}
```

## Visual Studio Code

I ended up using VSC over Sublime when writing this, since I’d read the Golang and Terraform support is miles ahead of Sublime, and they weren’t wrong.

It was great at setting up autosuggestions for code, highlighting compilation mistakes and helping run tests by adding little clickable “Run test” links for test cases:



I think this will be the main push I have to transfer fully from Sublime to Visual Studio Code.

## Vendoring, oh my!

Oh man, vendoring.

As I mentioned, I’m a Ruby person. So I’m used to some sort of Gemfile or something, but Golang has a vendoring model, which downloads everything and puts it into the repo.

It seems most of the Terraform providers out there are using govendor, so I thought I’d stick to conventions. I asked around internally, and HashiCorp standardized around govendor sometime in 2015. `govendor` was probably one of the better early-day managers (ie: out of the ones released not so long after Go 1.5, which is when dependency vendoring was initially introduced), but has been showing its age for quite a while. After that, `dep` was going to be Go's native upstream package manager, but is now being superseded by `vgo`. Go's got a bit of a problem right now with not being able to hold all of its dependency managers.

For background I suggest reading these posts which seem to summarize the situation well:

https://sdboyer.io/blog/vgo-and-dep/
https://blog.golang.org/versioning-proposal
https://github.com/golang/go/wiki/vgo

## Using in Anger

Anyways, we’ve got all the dependencies inside, and it’s compiling. So we built it: how do I actually use it?

So, we need to have the binary built and in the gobin path. So the easiest way I found was to do this:

```
make build
ln -s $GOPATH/bin/terraform-provider-extip ~/.terraform.d/plugins/
```

Then we write some Terraform to get the external IP:

```
data "extip" "external_ip_from_aws" {
  resolver = "https://checkip.amazonaws.com/"
}

output "external_ip_from_aws" {
  value = "${data.extip.external_ip_from_aws.ipaddress}"
}
```

We need to initialize the repo otherwise we get this:

```
Plugin reinitialization required. Please run "terraform init".
Reason: Could not satisfy plugin requirements.

Plugins are external binaries that Terraform uses to access and manipulate
resources. The configuration provided requires plugins which can't be located,
don't satisfy the version constraints, or are otherwise incompatible.

1 error(s) occurred:

* provider.extip: new or changed plugin executable

Terraform automatically discovers provider requirements from your
configuration, including providers used in child modules. To see the
requirements and constraints from each module, run "terraform providers".


Error: error satisfying plugin requirements
```

We initialize the folder so it knows to look for the extip provider:

```
$ terraform init

Initializing provider plugins...

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

Then we apply it:

```
$ terraform apply
data.extip.external_ip_from_aws: Refreshing state...

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

external_ip_from_aws = 87.55.253.10
```

Great, all working and good!

https://github.com/petems/terraform-provider-extip

I’ll be blogging further about how I used this in my Google demo setup.
