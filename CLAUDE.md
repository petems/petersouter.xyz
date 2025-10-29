# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Hugo-based static blog hosted on AWS S3 with CloudFront CDN and ACM SSL certificates. The site uses the Tranquilpeak theme and deploys via GitHub Actions.

- **URL**: https://petersouter.xyz
- **Hugo Version**: 0.54.0 (CI/CD) / 0.148.1+ (local development)
- **Theme**: tranquilpeak
- **Hosting**: AWS S3 + CloudFront + Route53
- **Deployment**: GitHub Actions + go3up tool

## Common Commands

### Hugo Site Operations

```bash
# Build the site (output to ./public)
hugo

# Build with specific destination
hugo --destination ./public

# Local development server
hugo server

# Local development with drafts
hugo server -D
```

### Image Optimization

```bash
# Optimize PNG files in static directory
make opt-png

# Optimize JPEG files (preserves EXIF)
make opt-jpg

# Run spellcheck with auto-fix
make spellcheck
```

### Terraform Infrastructure Management

**Important**: Terraform commands must be run with `envchain` to manage AWS credentials and require clearing `OTEL_TRACES_EXPORTER` due to environment variable conflicts:

```bash
# Navigate to the infrastructure directory
cd terraform/s3-website

# Initialize Terraform
OTEL_TRACES_EXPORTER="" envchain aws_petersouterxyz terraform init

# Plan changes
OTEL_TRACES_EXPORTER="" envchain aws_petersouterxyz terraform plan

# Apply changes
OTEL_TRACES_EXPORTER="" envchain aws_petersouterxyz terraform apply

# Import existing resources
OTEL_TRACES_EXPORTER="" envchain aws_petersouterxyz terraform import <resource> <id>
```

The envchain profile is `aws_petersouterxyz` for this project.

## Architecture

### Deployment Pipeline

**GitHub Actions** (`.github/workflows/deploy.yml`) triggers on push to `master`:
1. Build job: Hugo compiles site to `./public`
2. Upload job: go3up syncs to S3 bucket with intelligent diffing

CircleCI configuration (`.circleci/config.yml`) exists but is superseded by GitHub Actions.

### AWS Infrastructure (Terraform)

Managed in `terraform/s3-website/`:

**S3 Configuration**:
- Bucket configured for static website hosting with "Pretty URLs" support
- Logging enabled (logs to same bucket with `log/` prefix)
- Custom User-Agent header restriction (`content-secret` variable) to force CloudFront access

**CloudFront**:
- Custom origin config pointing to S3 website endpoint (not bucket endpoint)
- Price class: PriceClass_100 (US, Canada, Europe)
- Custom error response: 404 → 200 with /404.html
- Cache TTL: min 2min, default 2min, max 5min
- Aliases: petersouter.xyz and www.petersouter.xyz

**Route53**:
- Hosted zone: petersouter.xyz
- A record aliased to CloudFront distribution

**Key Architecture Decision**: The site uses S3 static website hosting (not direct S3 bucket) as CloudFront origin to enable Pretty URLs (`/path/` vs `/path/index.html`). This prevents using CloudFront Origin Access Identity, so access control is enforced via a secret User-Agent header.

### Terraform Resource Structure (Modern AWS Provider 6.x)

The configuration was recently updated to use separate resources instead of deprecated inline blocks:
- `aws_s3_bucket` - Core bucket resource only
- `aws_s3_bucket_website_configuration` - Website hosting settings
- `aws_s3_bucket_logging` - Access logging configuration
- `aws_s3_bucket_acl` - ACL with grant blocks (public-read equivalent)
- `aws_s3_bucket_policy` - Bucket policy (User-Agent restriction)

### Content Structure

- `content/post/` - Blog posts in markdown
- `content/about.md` - About page
- `content/talks.md` - Talks/presentations
- `static/` - Static assets (images, etc.)
- `themes/tranquilpeak/` - Git submodule for theme

### Hugo Configuration

`config.toml` defines:
- Site metadata and author info
- Permalink structure: `/:title/`
- Pagination: 1 post per page
- Menu structure (main, links, misc)
- Theme parameters (sidebar behavior, cover images, sharing options)
- RSS feed basename: `feed.xml`

## Git Workflow

- **Main branch**: `master`
- **Deployment**: Automatic on push to `master`
- **Commit format**: Use Conventional Commits format for commit messages

## Infrastructure Notes

### Pretty URLs vs Ugly URLs

The site currently uses Pretty URLs. To switch to Ugly URLs:
1. Set `uglyurls = true` in `config.toml`
2. In `terraform/s3-website/main.tf`, swap commented blocks marked with `START/END: For PrettyURLS` and `START/END: For UglyURLS`

### CloudFront Distribution Updates

CloudFront distributions take significant time to provision/update (often 15-30 minutes). Be patient when applying Terraform changes that modify the distribution.

### S3 Bucket Policy

The bucket policy uses a custom User-Agent header (defined in `vars.tf` as `content-secret`) to restrict direct S3 access. Only CloudFront with the matching User-Agent can retrieve objects.

## Terraform Subdirectories

- `terraform/s3-website/` - Main website infrastructure (current working directory)
- `terraform/circle-ci-credentials/` - CircleCI credentials management (legacy, not actively used)
