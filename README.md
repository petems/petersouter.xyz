# petersouter.xyz

A Hugo-based static blog hosted on AWS S3 with CloudFront CDN and Route53 DNS management. The site uses the Tranquilpeak theme and features automatic deployment via GitHub Actions with OIDC authentication.

## Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Local Development](#local-development)
- [Content Management](#content-management)
- [Deployment](#deployment)
- [Infrastructure Management](#infrastructure-management)
- [Configuration](#configuration)
- [Utilities](#utilities)

## Features

- Static site generation with Hugo
- Responsive Tranquilpeak theme
- CloudFront CDN for global performance
- AWS S3 hosting with PrettyURLs support
- Automatic SSL/TLS via AWS Certificate Manager
- CI/CD with GitHub Actions and OIDC authentication
- Vercel preview deployments for pull requests
- Image optimization utilities
- Spell checking automation

## Architecture

### AWS Infrastructure

The site uses the following AWS services (managed via Terraform in `terraform/s3-website/`):

1. **S3** - Static website hosting
   - Configured for PrettyURLs support

2. **CloudFront** - CDN for content delivery
   - Reduces costs and improves performance
   - Custom User-Agent restriction for security
   - SSL/TLS termination

3. **Route53** - DNS management
   - Root domain and www subdomain routing

4. **Certificate Manager** - Free SSL/TLS certificates
   - Certificate ARN stored in Terraform variables

### Deployment Pipeline

**Production: GitHub Actions**
- Workflow: `.github/workflows/deploy.yml`
- Triggers on push to `master` branch
- Uses Hugo v0.152.2 (extended) for builds
- Deploys via `go3up` with MD5 caching
- OIDC authentication (no static AWS keys)
- View deployments: https://github.com/petems/petersouter.xyz/actions

**Pull Request Previews: Vercel**
- Workflow: `.github/workflows/deploy-vercel-preview.yml`
- Automatic preview deployments for PRs

### URL Structure

The site uses PrettyURLs (e.g., `/path/` instead of `/path/index.html`) implemented through:
- S3 static website hosting with routing rules
- CloudFront pointing to S3 website endpoint
- Hugo's permalink configuration

## Prerequisites

- [Hugo](https://gohugo.io/) (v0.152.2 extended or later)
- [Git](https://git-scm.com/) (for cloning and submodules)
- [Terraform](https://www.terraform.io/) (for infrastructure changes)
- [AWS CLI](https://aws.amazon.com/cli/) (optional, for manual S3 operations)
- [Go](https://golang.org/) (if building deployment tools)

## Local Development

### Initial Setup

1. Clone the repository:
```bash
git clone https://github.com/petems/petersouter.xyz.git
cd petersouter.xyz
```

2. Initialize the theme submodule:
```bash
git submodule update --init --recursive
```

3. Start the development server:
```bash
hugo server
```

The site will be available at `http://localhost:1313` with live reloading.

### Building the Site

Generate static files for production:
```bash
hugo
```

Build with draft content:
```bash
hugo --buildDrafts
```

The generated site will be in the `public/` directory.

## Content Management

### Creating New Posts

```bash
hugo new post/my-post-title.md
```

This creates a new post in `content/post/` using the archetype template.

### Content Structure

```
content/
├── post/           # Blog posts
├── about.md        # About page
└── talks.md        # Talks page

static/             # Static assets (images, files)
themes/tranquilpeak/  # Hugo theme (git submodule)
public/             # Generated static site (not in git)
```

### Post Front Matter

```yaml
---
title: "Post Title"
date: 2024-01-01T12:00:00Z
categories: ["category"]
tags: ["tag1", "tag2"]
draft: false
---
```

## Deployment

### Automatic Deployment

All pushes to the `master` branch automatically trigger deployment via GitHub Actions:

1. Push changes:
```bash
git push origin master
```

2. Monitor deployment:
```bash
gh run list --workflow=deploy.yml
gh run watch <run-id>
```

### Authentication

The deployment uses AWS OIDC for secure, keyless authentication:
- No static AWS access keys in repository
- Temporary credentials generated per workflow run
- IAM role: `petersouter-website-github-actions-role`
- OIDC configuration: `terraform/github-actions-oidc/`

### Required GitHub Secrets

- `AWS_ROLE_ARN`: IAM role ARN for OIDC authentication (already configured)

### Viewing Deployment Status

```bash
# List recent deployments
gh run list --workflow=deploy.yml

# View specific deployment
gh run view <run-id>

# View deployment logs
gh run view <run-id> --log

# Open in browser
gh run view <run-id> --web
```

## Infrastructure Management

All infrastructure is defined as code using Terraform.

### Terraform Commands

**IMPORTANT**: Prefix all Terraform commands with `OTEL_TRACES_EXPORTER=` to avoid conflicts with environment variables.

```bash
cd terraform/s3-website/

# Initialize Terraform
OTEL_TRACES_EXPORTER= terraform init

# Preview changes
OTEL_TRACES_EXPORTER= terraform plan

# Apply changes
OTEL_TRACES_EXPORTER= terraform apply

# View current state
OTEL_TRACES_EXPORTER= terraform show
```

### Infrastructure Components

- **S3 Bucket**: Website hosting with static website configuration
- **CloudFront Distribution**: CDN with custom caching rules
- **Route53 Records**: DNS A records for apex and www domains
- **IAM Roles**: GitHub Actions OIDC authentication role

## Configuration

### Hugo Configuration

All Hugo settings are in `config.toml`:

- **Base URL**: `https://petersouter.xyz/`
- **Theme**: Tranquilpeak
- **Language**: English (UK)
- **Permalinks**: Pretty URLs enabled
- **Author**: Peter Souter
- **Social Links**: GitHub, LinkedIn, Twitter

### Theme Customization

The Tranquilpeak theme is configured via `config.toml` parameters. Custom overrides can be placed in:
- `layouts/` - Layout overrides
- `static/css/` - Custom CSS
- `static/js/` - Custom JavaScript

### Menu Configuration

Menus are defined in `config.toml`:
- **Main Menu**: Home, Categories, Tags, Archives, About
- **Links Menu**: GitHub, LinkedIn, Twitter, Talks
- **Misc Menu**: RSS feed

## Utilities

### Image Optimization

Optimize PNG images:
```bash
make opt-png
```

Optimize JPEG images:
```bash
make opt-jpg
```

Output is logged to `optipng.log` and `jpegoptim.log` respectively.

### Spell Checking

Automatically fix common spelling errors:
```bash
make spellcheck
```

Runs `misspell` on content files using Docker.

### List All Content

```bash
hugo list all
```

## Development Workflow

1. Create a new branch for changes
2. Make content or code changes
3. Test locally with `hugo server`
4. Commit using Conventional Commits format
5. Push and create a pull request
6. Review Vercel preview deployment
7. Merge to `master` for automatic production deployment

## Contributing

This is a personal blog, but if you notice issues:

1. Check existing issues at https://github.com/petems/petersouter.xyz/issues
2. Create a new issue with details
3. Submit a pull request if you have a fix

## Acknowledgements

This project was heavily inspired by [clburlison.com](https://github.com/clburlison/clburlison.com).