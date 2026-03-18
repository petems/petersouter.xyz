# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Hugo-based static blog hosted on AWS S3 with CloudFront CDN and Route53 DNS management. The site is built using Hugo's "PaperMod" theme and deployed via GitHub Actions.

## Hugo Commands

### Build and Development

- **Build the site**: `hugo` or `hugo --destination public`
  - Generates static files in the `public/` directory
  - The site uses `hugo.yaml` for all Hugo configuration

- **Local development server**: `hugo server`
  - Starts a live-reloading development server
  - Usually runs on `http://localhost:1313`

- **Build with drafts**: `hugo --buildDrafts` or `hugo server --buildDrafts`
  - Includes content marked as draft

### Content Management

- **Create new post**: `hugo new content/post/YYYY/MM/post-slug.md` or create the file directly in `content/post/` with TOML frontmatter (`+++` delimiters). Cover images use the `[cover]` section with `image` field.

- **List all content**: `hugo list all`

## Terraform Commands

The `terraform/s3-website/` directory contains AWS infrastructure definitions for hosting the site.

**IMPORTANT**: Prefix all Terraform commands with `OTEL_TRACES_EXPORTER=` to avoid conflicts with Claude Code's environment variables.

- **Initialize Terraform**: `OTEL_TRACES_EXPORTER= terraform init`
- **Plan changes**: `OTEL_TRACES_EXPORTER= terraform plan`
- **Apply changes**: `OTEL_TRACES_EXPORTER= terraform apply`
- **Show current state**: `OTEL_TRACES_EXPORTER= terraform show`

All Terraform operations should be run from the `terraform/s3-website/` directory.

## Makefile Utilities

The project includes several utility targets in the Makefile:

- **Optimize PNG images**: `make opt-png`
  - Uses optipng to compress PNG files in `static/`
  - Logs output to `optipng.log`

- **Optimize JPG images**: `make opt-jpg`
  - Uses jpegoptim to compress JPEG files in `static/`
  - Logs output to `jpegoptim.log`

- **Spellcheck content**: `make spellcheck`
  - Runs misspell autofix on content files using Docker
  - Automatically fixes common spelling errors in `content/` directory

## GitHub Actions Commands

The site deploys automatically via GitHub Actions when code is pushed to `master`.

### Viewing Deployments

- **List recent workflow runs**: `gh run list --workflow=deploy.yml`
- **View specific run**: `gh run view <run-id>`
- **View run logs**: `gh run view <run-id> --log`
- **Watch active run**: `gh run watch <run-id>`
- **Open Actions in browser**: `gh run view <run-id> --web`

### Manual Deployment Trigger

The workflow automatically runs on push to `master`. To manually trigger a deployment:

1. Push changes to `master`: `git push origin master`
2. Monitor at: https://github.com/petems/petersouter.xyz/actions

### Deployment Secrets

Required GitHub repository secrets (already configured):
- `AWS_ROLE_ARN`: IAM role for OIDC authentication

### Authentication

The deployment uses AWS OIDC for secure, temporary credentials:
- No static AWS access keys required
- Temporary credentials generated per workflow run
- IAM role: `petersouter-website-github-actions-role`
- Terraform config: `terraform/github-actions-oidc/`

## Architecture

### AWS Infrastructure

The site uses the following AWS services (managed via Terraform):

1. **S3**: Hosts the static website files
   - Bucket name: `petersouter.xyz`
   - Region: `eu-west-1`
   - Uses S3 static website hosting for PrettyURLs support

2. **CloudFront**: CDN for faster global delivery
   - Sits in front of S3 for lower costs and better performance
   - Uses a custom User-Agent restriction to ensure traffic goes through CloudFront

3. **Route53**: DNS management
   - Manages both root domain and www subdomain

4. **Certificate Manager**: Free SSL/TLS certificates
   - Pre-created certificate ARN stored in `vars.tf`

### URL Handling

The site uses PrettyURLs (e.g., `/path/` instead of `/path/index.html`). This is implemented through:
- S3 static website hosting with routing rules
- CloudFront configuration that points to the S3 website endpoint
- Hugo's permalink configuration in `hugo.yaml`

If switching to ugly URLs, modify both `hugo.yaml` and `terraform/s3-website/main.tf` (see comments in the Terraform file).

### Deployment Pipeline

**GitHub Actions** (Primary):
- Workflow defined in `.github/workflows/deploy.yml`
- Triggers on push to `master` branch
- Uses Hugo v0.155.3 for building
- Deploys to S3 using `go3up` with MD5 caching
- Authentication via OIDC (no static AWS keys)
- View deployments: https://github.com/petems/petersouter.xyz/actions

**Vercel Previews**:
- Preview deployments for pull requests
- Configured in `.github/workflows/deploy-vercel-preview.yml`

### Content Structure

- `content/post/`: Blog posts (primary content)
- `content/`: Top-level pages (about, talks, archives, search, etc.)
- `static/`: Static assets (images, files)
- `themes/PaperMod/`: Hugo theme (git submodule)
- `public/`: Generated static site (not in git)

### Theme Configuration

- Uses the "PaperMod" theme (https://github.com/adityatelange/hugo-PaperMod)
- Theme is a git submodule in `themes/PaperMod/`
- Configuration is in `hugo.yaml`
- Syntax highlighting uses Hugo's built-in Chroma (not highlight.js)
- Navigation is header-based (not sidebar)
- Dark/light mode toggle is built-in (`defaultTheme: auto`)
- PaperMod extension hooks: `layouts/partials/extend_head.html`
- Custom functionality: talks page (`layouts/partials/talks-list.html` + `static/js/talks-filter.js`)

## Git Workflow

- **Main branch**: `master`
- Use Conventional Commits format for commit messages
- GitHub Actions deploys all changes pushed to `master`
- Pull requests trigger Vercel preview deployments
