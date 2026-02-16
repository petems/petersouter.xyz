+++
author = "Peter Souter"
categories = ["Meta", "Blogging"]
date = 2026-02-16T00:00:00Z
description = "The full journey of upgrading an 8-year-old Hugo blog: CI/CD migration, Hugo version bumps, theme overhaul, content reorganization, and more."
draft = true
slug = "upgrading-the-blog"
tags = ["Blogging", "Hugo", "AWS", "GitHub Actions", "Terraform", "CI/CD"]
title = "Upgrading the Blog"
keywords = ["hugo", "blog", "aws", "github actions", "terraform", "ci/cd", "tranquilpeak", "s3", "cloudfront"]
+++

In my [2026 blogging plans](/my-2026-blogging-plans/) post I mentioned wanting to do a deep-dive into the infrastructure behind this blog. Well, here it is. This site has been running for about 8 years now, and like any long-lived project, it had accumulated a fair amount of infrastructure debt. Things worked, but they were creaky. Updating them had been on my to-do list for ages, and honestly it was one of the things that kept me from posting more - "I should fix the pipeline before I write anything new" is a great way to never write anything.

So over the course of mid-2025 and early 2026, I finally worked through the backlog. Here's what changed, roughly in the order it happened.

## Bluesky Verification

A small one to start. I added an [AT Protocol DID file](https://github.com/petems/petersouter.xyz/pull/49) to the site so my domain can be verified as my Bluesky handle. If you're on Bluesky, you can verify a custom domain as your handle by hosting a `/.well-known/atproto-did` file - simple but easy to forget.

## Vercel Preview Deploys

Before touching the main deployment pipeline, I added [Vercel preview deployments](https://github.com/petems/petersouter.xyz/pull/51) for pull requests. This turned out to be really valuable for everything that followed - being able to review layout changes, theme fixes, and new posts on a real URL before merging made the whole upgrade process much less nerve-wracking.

## Renovate for Dependency Management

I set up [Renovate](https://github.com/petems/petersouter.xyz/pull/52) to keep dependencies up to date automatically. The theme has a `package.json` with various frontend dependencies (jQuery, highlight.js, Grunt, etc.), and they were all years out of date. Renovate opened PRs for each one, which I could review and merge at my own pace. This knocked out a pile of dependency updates across June-August 2025 including security fixes for Grunt and jQuery.

## CircleCI to GitHub Actions

The big one. The original CI/CD for this blog was on CircleCI. It worked fine for years, but as GitHub Actions matured it became harder to justify maintaining a separate CI system for what is essentially "build Hugo site, upload to S3."

The [migration PR](https://github.com/petems/petersouter.xyz/pull/90) covered both the workflow and the underlying infrastructure:

- Created a new GitHub Actions [deploy workflow](https://github.com/petems/petersouter.xyz/blob/master/.github/workflows/deploy.yml) that checks out the repo, builds with Hugo, and uploads to S3 using [go3up](https://github.com/petems/go3up) with MD5 caching
- Replaced the CircleCI IAM user and static access keys with a **GitHub OIDC provider** and IAM role (`petersouter-website-github-actions-role`)
- Updated the Terraform in `terraform/github-actions-oidc/` to manage the whole thing

The biggest win was the OIDC authentication. No more static keys sitting in CI secrets - each deployment gets short-lived temporary credentials that expire automatically. It's the right way to do it.

A couple of follow-up fixes landed directly on master the same day. First, the go3up cache file (`.go3up.txt`) wasn't being persisted between workflow runs, which meant every deployment was [re-uploading all 813 files](https://github.com/petems/petersouter.xyz/commit/f9339a9) even when only one had changed - adding GitHub Actions caching fixed that. Then I [cleaned out the old `.circleci/` directory](https://github.com/petems/petersouter.xyz/commit/327fd0c) and updated the README to remove the CircleCI badge and references.

## Quick Content Cleanup

While I was in migration mode, I also [updated my about page](https://github.com/petems/petersouter.xyz/commit/770cf23) to reflect my current role (Senior Sales Engineer at Datadog, adding HashiCorp to the previous employers list), and [modernized the site-info page](https://github.com/petems/petersouter.xyz/commit/efce3e4) - fixing the repo link from the original template's `clburlison.com` to `petersouter.xyz`, updating the descriptions to reference GitHub Actions and Terraform instead of the old CircleCI setup, and generally tidying up the copy.

## Modern Web Standards

While I had momentum, I added a batch of [modern website standards](https://github.com/petems/petersouter.xyz/pull/93):

- **security.txt** (RFC 9116 compliant) for security vulnerability disclosure
- **humans.txt** for credits and tech stack
- A proper **SVG favicon** with dark mode support
- **Apple touch icon** and 512px PWA icon
- A default **Open Graph image** for social media sharing
- An enhanced **manifest.json** for PWA support

Small things individually, but they add up to a more professional and standards-compliant site.

## Hugo v0.54.0 to v0.152.2

This was a big one. The initial GitHub Actions migration ([PR #90](https://github.com/petems/petersouter.xyz/pull/90)) kept Hugo at v0.54.0 to match what CircleCI had been using - one thing at a time. But v0.54.0 was from early 2019, so the gap was enormous.

The [upgrade to v0.152.2](https://github.com/petems/petersouter.xyz/pull/94) required fixing several deprecated APIs that the Tranquilpeak theme relied on:

- `paginate` config → `pagination.pagerSize` (deprecated in Hugo v0.128.0)
- `.Site.DisqusShortname` → `.Site.Params.disqusShortname` (deprecated in Hugo v0.124.0)
- `.Site.Author` → `.Site.Params.author` (deprecated in recent versions)
- Removed the deleted `_internal/google_analytics_async.html` template

The nice thing about Hugo's override system is that none of these required modifying the theme itself - layout files in the project root take precedence. The Vercel config was also updated to use v0.152.2 so preview deployments matched production.

## Filterable Talks Page

Not strictly a blog infrastructure change, but part of the same refresh: I [rebuilt the talks page](https://github.com/petems/petersouter.xyz/pull/96) from a static markdown file into a data-driven, interactive page. All 22 talks (2014-2026) are now in a structured YAML file with collapsible filters for year, conference, and topic. Check it out at [/talks](/talks/).

## Gherkin Syntax Highlighting

A small fix - highlight.js was configured with Terraform support but was missing [Gherkin/Cucumber language support](https://github.com/petems/petersouter.xyz/pull/97). The "Testing CLI apps with Aruba" post uses Gherkin code blocks, and they were throwing console errors instead of getting highlighted. Also cleaned up a duplicate script tag while I was in there.

## Theme: Submodule to Subtree

The [Tranquilpeak theme](https://github.com/kakawait/hugo-tranquilpeak-theme) has been effectively abandoned since [2022](https://github.com/kakawait/hugo-tranquilpeak-theme/commit/3b5676afca7e667fc0d5c7f012c2ad00ca6dd9f0). It was vendored as a git submodule, which meant every clone needed `--recursive`, CI needed submodule checkout configuration, and Vercel previews needed special setup.

I [converted it to a git subtree](https://github.com/petems/petersouter.xyz/pull/102) instead. The theme code now lives directly in the repository. Cloning is simpler, CI is simpler, and local modifications are easier since the files are just... there. No submodule indirection.

## Theme Bug Fixes

With the theme now living directly in the repo, I could actually fix things. Two PRs tackled a comprehensive list of issues:

[PR #110](https://github.com/petems/petersouter.xyz/pull/110) fixed critical issues:
- **Security**: Removed an exposed OAuth `clientSecret` from the Gitalk integration
- **Font Awesome icons**: Updated weights from 600 to 900 for FA5 Free compatibility (fixing missing icon glyphs)
- **JSON-LD schema**: Complete rewrite to generate valid structured data
- **Gallery shortcode**: Added bounds checking to prevent index errors
- **Sidebar animation**: Fixed a processing guard to prevent concurrent animations
- Translation fixes across 10 language files

[PR #108](https://github.com/petems/petersouter.xyz/pull/108) continued with:
- Fixed template context bugs where `.Title` was used inside `{{ with }}` blocks (should be `$.Title`)
- Made cover image paths work correctly with `baseURL` subpaths
- Restricted Vercel URL override to preview deployments only
- Added `mainSections` fallbacks across 6 taxonomy templates to prevent empty pages

## Content Reorganization

The `content/post/` directory had all 62 posts in a single flat directory. I [reorganized them](https://github.com/petems/petersouter.xyz/pull/116) into `YYYY/MM/` subdirectories based on their front matter date. This makes the source tree much easier to navigate without changing any published URLs. The theme's list template needed a small update to use `.RegularPagesRecursive` to discover posts in the nested directories.

## Tag Standardization

The tagging across 8 years of posts was inconsistent - mixed casing, tags duplicating category names, missing tags on some posts. Two PRs cleaned this up:

- [PR #120](https://github.com/petems/petersouter.xyz/pull/120) refined the canonicalization rules, reducing the tag list from 55 to 45 by removing tags that duplicated category names
- [PR #121](https://github.com/petems/petersouter.xyz/pull/121) applied the rules across all 63 posts: Title Case standardization (preserving acronyms like AWS, BDD, TDD), removed duplicate category tags from 49 posts, and added layout overrides for tag templates

## Hugo v0.152.2 to v0.155.3

With the big version jump behind me and the theme in good shape, the [second Hugo bump to v0.155.3](https://github.com/petems/petersouter.xyz/pull/122) was much simpler - just updating the version across the GitHub Actions workflow, Vercel config, dev container, and documentation. The main breaking change in v0.155.0 affects multilingual alias paths, which doesn't apply to this single-language site. So in total, Hugo went from v0.54.0 (2019) to v0.155.3 (2026) across two steps.

## Image Housekeeping

Finally, two PRs ([#127](https://github.com/petems/petersouter.xyz/pull/127), [#129](https://github.com/petems/petersouter.xyz/pull/129)) renamed historical screenshots from generic names like `screenshot-2016-11-01.png` to descriptive filenames that actually indicate what's in the image. Small but it makes the `static/images/` directory much more navigable.

## What's Next

There's a [set of improvement specs](https://github.com/petems/petersouter.xyz/pull/119) queued up for the next round of work:

- Rename `config.toml` to `hugo.toml` (Hugo v0.110.0+ convention)
- Add `--minify` to the production build
- Replace client-side highlight.js with Hugo's built-in Chroma syntax highlighter
- Replace go3up with Hugo's native `hugo deploy` command
- Migrate the vendored theme to a Hugo Module
- Add Markdown render hooks for links, images, and headings
- Implement Hugo's image processing pipeline for WebP/AVIF and responsive sizes
- Restructure content to use Hugo page bundles

And beyond the specs, there's the [Garden section idea](/my-2026-blogging-plans/#adding-a-garden-section) I mentioned in my blogging plans - a place for notes and living documents that don't fit the blog post format.
