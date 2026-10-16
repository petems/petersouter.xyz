# Terraform setup

This configuration is what I use to manage my website. It is currently using
the following AWS tech stack:

* CloudFront (CF) - CDN
* S3 - object storage
* Route53 - DNS
* Certificate Manager - Free SSL certs

If you have ever used AWS you will know the options are limitless. For
consistency of this setup I am using Terraform to manage my infrastructure.

## Usage

### Create your backend terraform storage

State for both stacks (`s3-website` and `github-actions-oidc`) lives in the
`petersouter.xyz-terraform-state` S3 bucket in `eu-west-1`, keyed as
`<stack>/terraform.tfstate`. Locking uses S3-native lock files
(`use_lockfile = true`), so no DynamoDB table is needed.

The bucket was bootstrapped once by hand, since Terraform can't store its own
backend in itself:

```sh
export AWS_PROFILE=petems-personal-aws
B=petersouter.xyz-terraform-state
aws s3api create-bucket --bucket $B --region eu-west-1 \
  --create-bucket-configuration LocationConstraint=eu-west-1 \
  --object-ownership BucketOwnerEnforced
aws s3api put-public-access-block --bucket $B --public-access-block-configuration \
  BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
aws s3api put-bucket-versioning --bucket $B --versioning-configuration Status=Enabled
aws s3api put-bucket-encryption --bucket $B --server-side-encryption-configuration \
  '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"},"BucketKeyEnabled":true}]}'
aws s3api put-bucket-policy --bucket $B --policy '{"Version":"2012-10-17","Statement":[{
  "Sid":"DenyInsecureTransport","Effect":"Deny","Principal":"*","Action":"s3:*",
  "Resource":["arn:aws:s3:::'$B'","arn:aws:s3:::'$B'/*"],
  "Condition":{"Bool":{"aws:SecureTransport":"false"}}}]}'
```

Versioning is on, so a bad state write can be rolled back by restoring a
previous object version.

### Create your website resources

All actions should take place at root of this README.md file

* The SSL certificate (apex + www) is created in ACM (us-east-1) and
  DNS-validated via Route53 by Terraform. `www` is 301-redirected to the apex
  by a CloudFront Function (`functions/www-redirect.js`).
* Modify the `vars.tf` file with your settings.
* `terraform init`
* `terraform plan`
* `terraform apply`

No seriously keep waiting. Building a CF distribution point takes a while...

## DNS Notes

Route53 has a $0.50 charge per month just for hosting a domain. This cost,
while nominal, can add up overtime. Many other DNS providers
(Namecheap, Google Domains, etc.) are more than sufficient for most sites
and do not have a monthly charge.

This configuration requires Route53, though: the ACM certificate is
DNS-validated by records Terraform writes into the Route53 zone, and the apex
and `www` aliases point at CloudFront. To use another provider you'd need to
remove the `aws_route53_*` resources, create the ACM validation CNAMEs and
the CloudFront aliases at that provider, and drop `aws_acm_certificate_validation`
(or point it at the externally-created records).

## (Pretty) URL Notes

CloudFront has no way to rewrite `/path/index.html` to `/path`, also
known as "PrettyUrls", therefore I'm sharing the site using the AWS S3
"static website hosting" feature which supports rewrites. Then CloudFront in
front of this S3 hosting for lower cost and faster speeds.

Because CloudFront talks to the S3 website endpoint over HTTP, the built-in
origin access identity/control can't be used to restrict S3 access. The
bucket is therefore publicly readable via a bucket policy
(`aws_s3_bucket_policy.public_read`), with ACLs disabled
(`BucketOwnerEnforced`). The raw S3 website endpoint is reachable directly,
which is fine for a public static site.

S3 server access logs go to the separate `petersouter.xyz-logs` bucket under
`s3-access/`.

### Using ugly urls

In your hugo `hugo.yaml`

    uglyURLs: true

Then in the `main.tf`, look for the origin blocks encapsulated with
`START` or `END` comments. Comment out the 'pretty' block and uncomment
the 'ugly' block. You'd also need an `aws_cloudfront_origin_access_control`
and to swap the public bucket policy for one that only grants CloudFront.

## Resources

* [https://github.com/ringods/terraform-website-s3-cloudfront-route53][]
* [https://lustforge.com/2016/02/27/hosting-hugo-on-aws/][]
