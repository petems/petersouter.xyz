# AGENTS.md

Shared instructions for all coding agents working on this repository.

## Critical Rules

- Never modify files under `themes/PaperMod/` directly — it's a git submodule
- Prefix all Terraform commands with `OTEL_TRACES_EXPORTER=` to avoid conflicts with agent environment variables
- Use Conventional Commits format for all commit messages
- Posts with UTC timezone dates (`Z` suffix) can appear as "future" during BST — use explicit offset (e.g., `+01:00`) or date-only format

## Tools & Commands

### Hugo

```sh
hugo                          # Build site to public/
hugo server                   # Dev server at http://localhost:1313
hugo server --buildDrafts     # Dev server including drafts
hugo --buildDrafts            # Build including drafts
hugo list all                 # List all content
```

Configuration: `hugo.yaml`

### Terraform

Run from `terraform/s3-website/`:

```sh
OTEL_TRACES_EXPORTER= terraform init
OTEL_TRACES_EXPORTER= terraform plan
OTEL_TRACES_EXPORTER= terraform apply
OTEL_TRACES_EXPORTER= terraform show
```

### Makefile

```sh
make opt-png      # Optimize PNGs in static/ (optipng)
make opt-jpg      # Optimize JPGs in static/ (jpegoptim)
make spellcheck   # Fix spelling in content/ (Docker + misspell)
```

### GitHub Actions / Deployment

```sh
gh run list --workflow=deploy.yml    # List recent deploys
gh run view <run-id>                 # View specific run
gh run view <run-id> --log           # View run logs
gh run watch <run-id>                # Watch active run
```

Deploys automatically on push to `master`. Monitor at: https://github.com/petems/petersouter.xyz/actions

## Content Management — Blog Posts

Posts use **page bundles**. Each post is a directory containing `index.md` and its images:

```
content/post/YYYY/MM/post-slug/
├── index.md
├── inline-image.png
└── another-image.jpg
```

### Creating a New Post

Create the directory and `index.md` file directly:

```sh
mkdir -p content/post/YYYY/MM/post-slug
touch content/post/YYYY/MM/post-slug/index.md
```

### Frontmatter (TOML with `+++` delimiters)

```toml
+++
author = "Peter Souter"
categories = ["Tech"]
date = 2026-03-02T19:08:19+00:00
description = "Short description of the post"
draft = false
slug = "post-slug"
tags = ["Tag1", "Tag2"]
title = "Post Title"
keywords = ["keyword1", "keyword2"]

[cover]
  image = "/images/YYYY/MM/cover-image.jpg"
+++
```

### Images in Posts

- **Inline images**: Place in the post bundle directory, reference by filename: `![alt text](image.png)`
- **Cover images**: Use the `[cover]` section with a path under `/images/` (stored in `static/images/`)

## Content Management — Garden

The garden is a digital garden sub-site at `/garden/`. Entries use **page bundles** organized by topic:

```
content/garden/
├── _index.md                          # Garden hub page (has cascade settings)
├── cooking/
│   └── italian-penicillin/
│       └── index.md
├── baseball/
│   ├── _index.md                      # Topic listing page
│   ├── dodgers/
│   │   └── index.md
│   └── how-baseball/
│       └── index.md
├── books/
├── eating/
├── links/
├── traveling/
└── about/
```

### Creating a New Garden Entry

```sh
mkdir -p content/garden/topic-name/entry-name
touch content/garden/topic-name/entry-name/index.md
```

### Frontmatter (YAML with `---` delimiters)

```yaml
---
title: "Entry Title"
date: 2026-03-20T00:00:00+00:00
description: "Short description."
garden_topic: "Topic Name"
status: "Seedling"
---
```

### Garden Conventions

- **Status values**: `Seedling` (new/incomplete) or `Evergreen` (mature/stable)
- **Topics**: Each topic is a directory under `content/garden/` — add a `_index.md` for a topic listing page
- **Cascade settings** in `content/garden/_index.md` hide garden pages from the home list and disable reading time, share buttons, post nav links, and comments

## Project Structure

```
content/
├── post/              # Blog posts (page bundles by year/month)
├── garden/            # Digital garden (page bundles by topic)
├── about.md           # About page
├── archives.md        # Archives page
├── talks.md           # Talks/speaking page
├── search.md          # Search page
├── site-info.md       # Site info/tech stack
└── license.md         # License page

static/                # Static assets (images, files)
themes/PaperMod/       # Hugo theme (git submodule)
layouts/               # Custom layout overrides and partials
terraform/             # AWS infrastructure (S3, CloudFront, Route53)
.github/workflows/     # CI/CD (deploy.yml, deploy-vercel-preview.yml)
public/                # Generated site (not in git)
```

## Architecture

- **Hosting**: S3 (eu-west-1) + CloudFront CDN + Route53 DNS, managed via Terraform in `terraform/s3-website/`
- **Deployment**: GitHub Actions on push to `master` using OIDC auth (no static AWS keys). Vercel previews for PRs.
- **Theme**: PaperMod (git submodule). Custom partials in `layouts/partials/`. Extension hook: `layouts/partials/extend_head.html`
- **URLs**: PrettyURLs via S3 static website hosting + Hugo permalink config (`/:title/`). Blog post URLs resolve to `https://petersouter.xyz/<slug>/` where `<slug>` is the `slug` frontmatter field (no date path segments). To change URL style, update both `hugo.yaml` and `terraform/s3-website/main.tf`
- **Custom functionality**: Talks page filter (`layouts/partials/talks-list.html` + `static/js/talks-filter.js`)

## Git Workflow

- **Main branch**: `master`
- **Commit style**: Conventional Commits
- **Deploy**: Automatic on push to `master` via GitHub Actions
- **Previews**: PRs trigger Vercel preview deployments

### Branch Naming

All work happens on topic branches. Use one of these prefixes so `git branch -r` stays scannable:

- `feat/blog/<slug>` — new blog posts or rewrites of existing posts. `<slug>` is a short kebab-case slug derived from the post title (not necessarily the full Hugo `slug` field — keep it under ~40 chars). Examples: `feat/blog/fosdem-2026`, `feat/blog/moneyball-problem`, `feat/blog/rip-terrance-gore`.
- `feat/garden/<page-name>` — new garden pages (see `.claude/skills/new-garden-page/SKILL.md`).
- `feat/<topic>` — other features (theme, tooling, infra, CI).
- `fix/<topic>` — bug fixes.
- `chore/<topic>` — deps, config, non-functional cleanup.
- `refactor/<topic>` — code restructuring with no behaviour change.
- `docs/<topic>` — documentation-only changes.

Agent-generated prefixes (`claude/*`, `cursor/*`, `codex/*`) are acceptable for short-lived scratch branches, but rename to one of the above before pushing work you want to come back to.

## Cursor Cloud specific instructions

### Prerequisites

Hugo v0.155.3 extended must be installed. It is not available via `apt`; install the binary from the GitHub release (see `.devcontainer/Dockerfile` for the exact download pattern). The update script handles this automatically.

### Running services

- **Dev server**: `hugo server --buildDrafts` at http://localhost:1313 (add `--bind 0.0.0.0` if testing from outside the container)
- **Tests**: `npm test` runs Jest tests for `static/js/talks-filter.js` (34 tests)
- **Build**: `hugo` builds the full site to `public/`
- No databases, backend services, or Docker containers are needed for development

### Gotchas

- The PaperMod theme is a git submodule — always run `git submodule update --init --recursive` before building if `themes/PaperMod/` is empty
- There is no lockfile (`package-lock.json` / `pnpm-lock.yaml`) in the repo; `npm install` will resolve latest versions within the ranges in `package.json`
- The `make spellcheck` target requires Docker; skip it in environments without Docker unless you install it yourself
