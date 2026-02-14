# Spec 010: Content Organization with Page Bundles

## Summary

Restructure blog content to use Hugo's page bundle format, co-locating each post with its associated images and resources for better organization and enabling page-level resource processing.

## Motivation

The current content structure separates posts from their images:

```
content/post/my-great-post.md           # Content here
static/images/2016/10/screenshot.png    # Images there
static/images/2016/10/diagram.png       # ...and there
```

Hugo page bundles (available since v0.32, December 2017) allow co-locating a post with all its resources:

```
content/post/my-great-post/
  index.md                               # Content
  screenshot.png                         # Image lives next to the post
  diagram.png                            # All resources together
```

**Benefits:**
- **Self-contained posts**: Each post is a directory with everything it needs
- **Page resources API**: Images are accessible via `.Resources` in templates, enabling Hugo Pipes processing
- **Easier content management**: No need to remember the `static/images/YYYY/MM/` path convention
- **Portable content**: A post directory can be moved, copied, or archived as a unit
- **Cleaner git diffs**: Changes to a post and its images are in the same directory

## Current State

- **67 blog posts** as flat `.md` files in `content/post/`
- **Images** in `static/images/` organized by year/month
- **Top-level pages** (`about.md`, `talks.md`, etc.) in `content/`
- Frontmatter references images via absolute paths: `coverImage = "/images/2016/10/screenshot.png"`

### Example current structure

```
content/
  post/
    90-day-fitness-challenge.md
    adding-my-provider-to-the-terraform-provider-registry.md
    ...
  about.md
  talks.md
static/
  images/
    2016/
      10/
        Screenshot-2016-06-16-23.11.34-1.png
    2019/
      03/
        terraform-provider.png
```

## Proposed Changes

### Phase 1: Define the target structure

```
content/
  post/
    90-day-fitness-challenge/
      index.md                    # Was: 90-day-fitness-challenge.md
      screenshot-fitness.png      # Was: static/images/2016/10/Screenshot-2016-06-16-23.11.34-1.png
    adding-my-provider-to-the-terraform-provider-registry/
      index.md
      terraform-provider.png
    ...
  about/
    index.md                      # Optional: convert top-level pages too
  talks.md                        # Can remain as-is (no associated images)
```

### Phase 2: Create a migration script

```bash
#!/bin/bash
# migrate-to-bundles.sh

for post in content/post/*.md; do
  slug=$(basename "$post" .md)
  dir="content/post/$slug"

  # Skip if already a bundle
  [ -d "$dir" ] && continue

  # Create the bundle directory
  mkdir -p "$dir"

  # Move the post
  mv "$post" "$dir/index.md"

  echo "Migrated: $slug"
done
```

Image migration requires mapping each post's frontmatter image paths to the correct source files, which is more complex and may need to be done semi-manually or with a more sophisticated script.

### Phase 3: Update frontmatter image references

**Before (absolute path to `static/`):**
```toml
+++
coverImage = "/images/2016/10/screenshot.png"
thumbnailImage = "/images/2016/10/screenshot-thumb.png"
+++
```

**After (relative path to co-located resource):**
```toml
+++
coverImage = "screenshot.png"
thumbnailImage = "screenshot-thumb.png"
+++
```

### Phase 4: Update templates to use page resources

Templates that reference cover images and thumbnails need to use the `.Resources` API:

```html
{{ $cover := .Resources.GetMatch (.Params.coverImage) }}
{{ if $cover }}
  {{ $resized := $cover.Resize "1200x q85" }}
  <img src="{{ $resized.RelPermalink }}" alt="{{ .Title }}">
{{ end }}
```

This integrates with Spec 009 (image processing) -- page resources can be processed through Hugo Pipes.

### Phase 5: Handle shared images

Some images may be used across multiple posts. These should remain in `assets/images/` (global resources) rather than being duplicated into each bundle:

```
assets/
  images/
    misc/
      side-banner.jpg            # Used as cover image site-wide
    shared/
      logo.png                   # Used in multiple posts
content/
  post/
    my-post/
      index.md
      post-specific-image.png    # Only used in this post
```

### Phase 6: Add section list pages

Create `_index.md` files (branch bundles) for sections that need custom list page content:

```
content/
  post/
    _index.md                    # Optional: customize the blog post listing page
```

```yaml
---
title: "Blog Posts"
description: "Technical articles about DevOps, Terraform, and infrastructure"
---
```

## Files Affected

| File | Change |
|---|---|
| `content/post/*.md` | Convert to `content/post/*/index.md` (67 posts) |
| `static/images/*` | Move post-specific images into bundles |
| `assets/images/` | Retain shared/global images |
| Theme templates | Update to use `.Resources` API for page-level images |
| `layouts/partials/post/header-cover.html` | Update cover image resolution |
| `layouts/_default/summary.html` | Update thumbnail resolution |

## Effort Estimate

High -- this is a significant restructuring:
- 67 posts to migrate
- Hundreds of images to map and relocate
- Template updates for resource resolution
- Manual verification of each migrated post

### Recommended incremental approach

1. **Start with new posts**: Write all new posts as page bundles immediately
2. **Migrate recent posts**: Convert the most recent 5-10 posts as a pilot
3. **Automate**: Build/refine the migration script based on lessons learned
4. **Batch migrate**: Convert remaining posts in batches, verifying each batch

## Risks

- **Broken image links**: Every image reference must be updated. A single missed reference means a broken image.
- **URL changes**: Post URLs should NOT change if the directory name matches the original slug. Hugo uses the directory name for page bundles. Verify: `content/post/my-post/index.md` produces the same URL as `content/post/my-post.md`.
- **Theme compatibility**: The tranquilpeak theme's templates may expect images at specific paths. Templates that resolve cover images, thumbnails, and gallery images must all be updated.
- **Git history**: Moving files in git loses per-file history unless using `git mv`. The migration should use `git mv` where possible.
- **Duplicate images**: If the same image is referenced by multiple posts, it should remain in `assets/images/` rather than being duplicated.
- **Build time**: Page bundles with large images may increase build time, especially if combined with image processing (Spec 009).

## Validation

```bash
# After migrating a batch of posts
hugo server

# Verify URLs haven't changed
curl -s http://localhost:1313/sitemap.xml | grep -c "<url>"
# Should match the pre-migration count

# Check a migrated post
curl -s http://localhost:1313/90-day-fitness-challenge/ | grep -c "<img"
# Images should render correctly

# Verify page resources are accessible
hugo list all | head -20
# Posts should appear with correct paths

# Check that no images are 404
hugo --destination public
grep -roh 'src="[^"]*"' public/ | sort -u | while read src; do
  file=$(echo "$src" | sed 's/src="//;s/"//')
  [ -f "public$file" ] || echo "Missing: $file"
done
```

## Interaction with Other Specs

- **Spec 009 (Image Processing)**: Page bundles enable per-page image processing via `.Resources`. These two specs are complementary and most powerful when combined.
- **Spec 008 (Render Hooks)**: The image render hook can be enhanced to look for page resources first, falling back to global resources.
- **Spec 006 (Hugo Modules)**: Page bundles work identically whether the theme is vendored or managed via Hugo Modules.

## References

- [Hugo Page Bundles Docs](https://gohugo.io/content-management/page-bundles/)
- [Hugo Page Resources Docs](https://gohugo.io/content-management/page-resources/)
- [Hugo Leaf and Branch Bundles](https://scripter.co/hugo-leaf-and-branch-bundles/)
- [Introduction to Hugo Bundles](https://www.ii.com/hugo-bundles/)
