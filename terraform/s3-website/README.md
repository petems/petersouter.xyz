# S3 Website Hosting with CloudFront

This Terraform configuration sets up a complete static website hosting solution using AWS S3 and CloudFront with Route53 DNS management.

## Architecture

- **S3 Bucket**: Stores static website files with versioning enabled
- **CloudFront Distribution**: Provides global CDN with HTTPS
- **Route53**: DNS management for custom domain
- **ACM Certificate**: SSL/TLS certificate for HTTPS

## Features

- ✅ Modern Terraform syntax (>= 1.0)
- ✅ Latest AWS provider (>= 5.0)
- ✅ S3 bucket versioning for backup
- ✅ CloudFront caching with optimized policies
- ✅ SPA routing support (404 → index.html)
- ✅ HTTPS enforcement
- ✅ IPv6 support
- ✅ Resource tagging for cost management
- ✅ Secure S3 bucket access (CloudFront only)

## Changes from Original

### Security Improvements
- Removed deprecated `acl = "public-read"` 
- Implemented proper S3 bucket public access blocking
- Used Origin Access Identity for secure CloudFront → S3 communication
- Removed insecure content-secret approach

### Modern Terraform Patterns
- Updated to Terraform >= 1.0
- Added AWS provider version constraints
- Used `jsonencode()` instead of heredoc syntax
- Implemented proper resource dependencies
- Added comprehensive resource tagging

### CloudFront Improvements
- Replaced deprecated `forwarded_values` with modern cache/request policies
- Updated TLS minimum version to 1.2_2021
- Improved SPA routing with proper error handling
- Optimized cache settings for static content

## Prerequisites

1. **AWS CLI configured** with appropriate permissions
2. **ACM Certificate** in us-east-1 region with your domain(s)
3. **Route53 hosted zone** for your domain
4. **Terraform >= 1.0** installed

## Usage

### 1. Configure Variables

Edit `vars.tf` or create a `terraform.tfvars` file:

```hcl
region         = "eu-west-1"
s3_bucket_name = "your-domain.com"
ssl_cert_arn   = "arn:aws:acm:us-east-1:ACCOUNT:certificate/CERT-ID"
dns_zone       = "your-domain.com"
dns_record     = "your-domain.com"
alt_dns_record = "www.your-domain.com"
```

### 2. Initialize and Apply

```bash
terraform init
terraform plan
terraform apply
```

### 3. Deploy Website

Upload your Hugo build output to the S3 bucket:

```bash
aws s3 sync public/ s3://your-bucket-name/ --delete
```

## Outputs

- `cloudfront_domain_name`: CloudFront distribution URL
- `s3_bucket_name`: S3 bucket name
- `website_endpoint`: Direct S3 website endpoint

## Security Notes

- S3 bucket is not publicly accessible
- All traffic goes through CloudFront with HTTPS
- Origin Access Identity restricts S3 access to CloudFront only
- TLS 1.2+ enforced

## Cost Optimization

- Uses PriceClass_100 (North America and Europe only)
- Optimized cache settings reduce origin requests
- S3 versioning can be disabled if not needed

## Maintenance

### Updating Website
```bash
hugo --minify
aws s3 sync public/ s3://your-bucket-name/ --delete
aws cloudfront create-invalidation --distribution-id DISTRIBUTION-ID --paths "/*"
```

### Terraform Updates
```bash
terraform plan
terraform apply
```

## Troubleshooting

### Common Issues

1. **Certificate not found**: Ensure ACM certificate is in us-east-1 region
2. **DNS not resolving**: Check Route53 zone and record configuration
3. **403 errors**: Verify S3 bucket policy and CloudFront OAI
4. **404 on routes**: Check SPA routing configuration in CloudFront

### Validation

```bash
terraform validate
terraform fmt
```
