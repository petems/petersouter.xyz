# Spec 009: Image Processing Pipeline

## Summary

Leverage Hugo's built-in image processing to automatically optimize images and generate modern formats (WebP, AVIF) at build time, replacing the manual `optipng`/`jpegoptim` workflow.

## Motivation

The current image optimization workflow uses external tools via the Makefile:

```makefile
opt-png:
    find ./static/ -iname '*.png' -print0 | xargs -0 optipng -o7 -preserve
opt-jpg:
    find ./static/ -iname '*.jpg' -print0 | xargs -0 jpegoptim --max=90 --preserve --totals --all-progressive
```

This approach:
- Requires `optipng` and `jpegoptim` to be installed locally
- Must be run manually before committing
- Only produces JPEG and PNG -- no modern formats
- Doesn't generate responsive image sizes
- Optimizes source files in-place (modifying committed assets)

Hugo Pipes (v0.43+) can process images at build time to:
- Convert to **WebP** (25-34% smaller than JPEG) and **AVIF** (50%+ smaller)
- Generate **responsive sizes** for different screen widths
- Apply **quality optimization** without modifying source files
- **Cache results** in `resources/_gen/` for fast rebuilds

## Current State

- Images live in `static/images/` organized by year/month (e.g., `static/images/2016/10/`)
- Blog posts reference images via absolute paths (e.g., `/images/2016/10/screenshot.png`)
- Cover images are set in frontmatter: `coverImage = "/images/2016/10/screenshot.png"`
- The `Makefile` has `opt-png` and `opt-jpg` targets
- No `assets/` directory exists

## Proposed Changes

This is a multi-phase migration that can be done incrementally.

### Phase 1: Move images to assets/ directory

Hugo Pipes can only process resources in `assets/`, not `static/`. Images must be relocated:

```bash
mkdir -p assets/images
mv static/images/* assets/images/
```

**Symlink for backwards compatibility:**
```bash
# Optional: keep static/images as a symlink during migration
# ln -s ../assets/images static/images
```

### Phase 2: Create an image processing partial

**`layouts/partials/img.html`:**

```html
{{ $src := .src }}
{{ $alt := .alt | default "" }}
{{ $class := .class | default "" }}

{{ $img := resources.Get $src }}
{{ if $img }}
  {{ $jpg := $img.Resize "800x q85" }}
  {{ $webp := $img.Resize "800x webp q85" }}

  <picture>
    <source srcset="{{ $webp.RelPermalink }}" type="image/webp">
    <img
      src="{{ $jpg.RelPermalink }}"
      alt="{{ $alt }}"
      width="{{ $jpg.Width }}"
      height="{{ $jpg.Height }}"
      loading="lazy"
      decoding="async"
      {{ with $class }}class="{{ . }}"{{ end }}
    />
  </picture>
{{ else }}
  <!-- Fallback for images not found in assets/ -->
  <img src="{{ $src }}" alt="{{ $alt }}" loading="lazy" {{ with $class }}class="{{ . }}"{{ end }} />
{{ end }}
```

### Phase 3: Create responsive image variant

**`layouts/partials/img-responsive.html`:**

```html
{{ $src := .src }}
{{ $alt := .alt | default "" }}

{{ $img := resources.Get $src }}
{{ if $img }}
  {{ $sizes := slice 400 600 800 1200 }}
  {{ $webpSrcset := slice }}
  {{ $jpgSrcset := slice }}

  {{ range $sizes }}
    {{ if le . $img.Width }}
      {{ $resized := $img.Resize (printf "%dx q85" .) }}
      {{ $webp := $img.Resize (printf "%dx webp q85" .) }}
      {{ $jpgSrcset = $jpgSrcset | append (printf "%s %dw" $resized.RelPermalink .) }}
      {{ $webpSrcset = $webpSrcset | append (printf "%s %dw" $webp.RelPermalink .) }}
    {{ end }}
  {{ end }}

  {{ $default := $img.Resize "800x q85" }}

  <picture>
    <source
      srcset="{{ delimit $webpSrcset ", " }}"
      sizes="(max-width: 800px) 100vw, 800px"
      type="image/webp">
    <source
      srcset="{{ delimit $jpgSrcset ", " }}"
      sizes="(max-width: 800px) 100vw, 800px"
      type="image/jpeg">
    <img
      src="{{ $default.RelPermalink }}"
      alt="{{ $alt }}"
      width="{{ $default.Width }}"
      height="{{ $default.Height }}"
      loading="lazy"
      decoding="async" />
  </picture>
{{ end }}
```

### Phase 4: Update the image render hook

Extend the render hook from Spec 008 to process images through Hugo Pipes:

**`layouts/_default/_markup/render-image.html`:**

```html
{{ $src := .Destination }}
{{ $alt := .Text }}
{{ $title := .Title }}

{{ $img := resources.Get $src }}
{{ if $img }}
  {{ $default := $img.Resize "800x q85" }}
  {{ $webp := $img.Resize "800x webp q85" }}
  <figure>
    <picture>
      <source srcset="{{ $webp.RelPermalink }}" type="image/webp">
      <img
        src="{{ $default.RelPermalink }}"
        alt="{{ $alt }}"
        width="{{ $default.Width }}"
        height="{{ $default.Height }}"
        loading="lazy"
        decoding="async"
        {{ with $title }}title="{{ . }}"{{ end }} />
    </picture>
    {{ with $title }}<figcaption>{{ . }}</figcaption>{{ end }}
  </figure>
{{ else }}
  <figure>
    <img src="{{ $src }}" alt="{{ $alt }}" loading="lazy" {{ with $title }}title="{{ . }}"{{ end }} />
    {{ with $title }}<figcaption>{{ . }}</figcaption>{{ end }}
  </figure>
{{ end }}
```

### Phase 5: Update frontmatter image paths

Blog post frontmatter references need to be updated to use paths relative to `assets/`:

```diff
- coverImage = "/images/2016/10/screenshot.png"
+ coverImage = "images/2016/10/screenshot.png"
```

The leading `/` must be removed for `resources.Get` to find files in `assets/`.

### Phase 6: Update the Makefile

```diff
- opt-png:
-     @find ./static/ -iname '*.png' -print0 | xargs -0 optipng -o7 -preserve | tee optipng.log
-
- opt-jpg:
-     @find ./static/ -iname '*.jpg' -print0 | xargs -0 jpegoptim --max=90 --preserve --totals --all-progressive | tee jpegoptim.log
+ # Image optimization is now handled by Hugo Pipes at build time.
+ # Source images in assets/images/ are converted to WebP/AVIF automatically.
+ # To preview processed images:
+ #   hugo server
+ #   hugo --destination public && ls public/images/
```

### Phase 7: Configure image processing defaults

Add to Hugo config:

```toml
[imaging]
  quality = 85
  resampleFilter = "Lanczos"
  anchor = "Smart"

  [imaging.exif]
    disableDate = false
    disableLatLong = true
    includeFields = ""
    excludeFields = ""
```

## Files Affected

| File | Change |
|---|---|
| `static/images/*` | Move to `assets/images/` |
| `layouts/partials/img.html` | New file |
| `layouts/partials/img-responsive.html` | New file (optional) |
| `layouts/_default/_markup/render-image.html` | New or updated render hook |
| `hugo.toml` (or `config.toml`) | Add `[imaging]` config |
| `Makefile` | Remove `opt-png` and `opt-jpg` targets |
| `content/post/*.md` | Update image paths in frontmatter (67 files) |
| `resources/_gen/` | Auto-generated cache (add to `.gitignore`) |

## Effort Estimate

High -- this is the largest change in the improvement set. It touches:
- Directory structure (moving images)
- Templates (new partials and render hook)
- Content (67 posts' frontmatter)
- Build configuration

Recommend doing this incrementally:
1. Start with Phase 1-2 (move images, create partial)
2. Add the render hook (Phase 4) for new posts
3. Migrate existing posts' frontmatter over time (Phase 5)

## Risks

- **Build time increase**: Processing hundreds of images adds build time. Hugo caches results in `resources/_gen/`, so subsequent builds are fast, but the first build after migration may take several minutes.
- **Image path breakage**: Moving from `static/` to `assets/` requires updating all image references. A missing update means a broken image.
- **Cover image handling**: The tranquilpeak theme has its own cover image rendering in `layouts/partials/post/header-cover.html`. This template must also be updated to use `resources.Get` instead of direct paths.
- **Gallery images**: Posts using the `gallery` frontmatter field need special handling since galleries reference multiple images.
- **Disk space**: Generated image variants are stored in `resources/_gen/`. For 67 posts with multiple images each, this could be 100MB+. Add `resources/_gen/` to `.gitignore`.

## Validation

```bash
# After moving images
hugo server
# Check that images display correctly on the homepage and individual posts

# Check generated files
ls resources/_gen/images/

# Compare file sizes
du -sh static/images/    # Before (should be empty after migration)
du -sh assets/images/    # Source images
du -sh resources/_gen/   # Generated variants

# Check WebP output
file resources/_gen/images/**/*.webp | head

# Run Lighthouse audit
# Score should improve for "Serve images in next-gen formats" and "Properly size images"
```

## References

- [Hugo Image Processing Docs](https://gohugo.io/content-management/image-processing/)
- [Hugo Pipes Docs](https://gohugo.io/hugo-pipes/)
- [Perfect Image Processing with Hugo](https://rb.ax/blog/perfect-image-processing-with-hugo/)
- [WebP and AVIF Images on a Hugo Website](https://pawelgrzybek.com/webp-and-avif-images-on-a-hugo-website/)
- [Responsive Images with Hugo](https://harrycresswell.com/writing/responsive-images-next-gen-formats/)
