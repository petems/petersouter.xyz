# Spec 007: Fix Deprecated Template Patterns

## Summary

Update templates to replace deprecated Hugo functions and methods with their modern equivalents, ensuring forward compatibility with future Hugo releases.

## Motivation

The site's templates (both custom overrides in `layouts/` and the vendored tranquilpeak theme) use several deprecated Hugo APIs. While these still function in Hugo v0.152.2, they will be removed in future versions and generate deprecation warnings during builds. Fixing them proactively avoids breakage on future upgrades.

## Current State

### Deprecated patterns found

| Pattern | Occurrences | Severity | Replacement |
|---|---|---|---|
| `.Scratch` | ~120 total (8 custom, ~112 theme) | High (most widespread) | `.Store` |
| `.UniqueID` | 2 (theme only) | Medium | `.File.ContentBaseName` or custom ID |
| `.Page.TableOfContents` | 1 (theme shortcode) | Low | `.TableOfContents` |

### Patterns NOT found (already clean)

- `.Hugo` (use `hugo` function) -- not present
- `.RSSLink` -- not present
- `.Site.IsServer` -- not present
- `.Site.Social` -- not present
- `resources.ToCSS` -- not present
- `getJSON` / `getCSV` -- not present
- `blackfriday` references -- not present

## Proposed Changes

### Phase 1: Fix custom layout overrides (8 files)

These are the files under the project's `layouts/` directory that override theme templates.

#### `layouts/_default/single.html` (2 occurrences)

```diff
- data-behavior="{{ .Scratch.Get "sidebarBehavior" }}"
+ data-behavior="{{ .Store.Get "sidebarBehavior" }}"
```

Lines 7 and 42 both reference `.Scratch.Get "sidebarBehavior"`.

#### `layouts/partials/sidebar.html` (2 occurrences)

```diff
- {{ .Scratch.Set "sidebarBehavior" .Site.Params.sidebarBehavior }}
+ {{ .Store.Set "sidebarBehavior" .Site.Params.sidebarBehavior }}
```

Lines 1 and 3.

#### `layouts/partials/about.html` (1 occurrence)

```diff
- {{ if .Scratch.Get "gravatarEmail" }}
+ {{ if .Store.Get "gravatarEmail" }}
```

Line 6.

#### `layouts/partials/meta.html` (3 occurrences)

```diff
- {{ if .Scratch.Get "gravatarEmail" }}
-   <meta property="og:image" content="https://www.gravatar.com/avatar/{{ (md5 (.Scratch.Get "gravatarEmail")) | urlize }}?s=640">
-   <meta property="twitter:image" content="https://www.gravatar.com/avatar/{{ (md5 (.Scratch.Get "gravatarEmail")) | urlize }}?s=640">
+ {{ if .Store.Get "gravatarEmail" }}
+   <meta property="og:image" content="https://www.gravatar.com/avatar/{{ (md5 (.Store.Get "gravatarEmail")) | urlize }}?s=640">
+   <meta property="twitter:image" content="https://www.gravatar.com/avatar/{{ (md5 (.Store.Get "gravatarEmail")) | urlize }}?s=640">
```

Lines 76-78.

### Phase 2: Fix vendored theme templates (~112 occurrences)

If the theme remains vendored (not migrated to Hugo Modules per Spec 006), these changes must be made in `themes/tranquilpeak/layouts/`. The most impacted files are:

| File | `.Scratch` count |
|---|---|
| `shortcodes/codeblock.html` | 20 |
| `shortcodes/tabbed-codeblock.html` | 20 |
| `_default/summary.html` | 24 |
| `shortcodes/image.html` | 15 |
| `taxonomy/category.terms.html` | 14 |
| `partials/head.html` | 9 |
| `partials/schema.html` | 4 |
| Other files | ~6 |

**If migrating to Hugo Modules (Spec 006)**, these fixes should be contributed upstream to `kakawait/hugo-tranquilpeak-theme` or maintained in a fork.

### Phase 3: Fix `.UniqueID` usage (2 occurrences, theme only)

#### `themes/tranquilpeak/layouts/partials/post/gallery.html`

```diff
- data-fancybox="gallery-{{ $.File.UniqueID }}"
+ data-fancybox="gallery-{{ $.File.ContentBaseName }}"
```

#### `themes/tranquilpeak/layouts/taxonomy/category.terms.html`

```diff
- {{ $.Scratch.SetInMap (printf "%s" (delimit (first (add $index 1) $categories) "/")) $page.File.UniqueID $page }}
+ {{ $.Store.SetInMap (printf "%s" (delimit (first (add $index 1) $categories) "/")) $page.RelPermalink $page }}
```

### Phase 4: Fix `.Page.` prefix (1 occurrence, theme only)

#### `themes/tranquilpeak/layouts/shortcodes/toc.html`

```diff
- {{ .Page.TableOfContents }}
+ {{ .TableOfContents }}
```

## Files Affected

### Custom layouts (Phase 1 -- project-owned)

| File | Changes |
|---|---|
| `layouts/_default/single.html` | 2 `.Scratch` -> `.Store` |
| `layouts/partials/sidebar.html` | 2 `.Scratch` -> `.Store` |
| `layouts/partials/about.html` | 1 `.Scratch` -> `.Store` |
| `layouts/partials/meta.html` | 3 `.Scratch` -> `.Store` |

### Theme layouts (Phase 2-4 -- vendored theme)

~20 files across `themes/tranquilpeak/layouts/`

## Effort Estimate

- **Phase 1** (custom layouts): Low -- 8 straightforward replacements
- **Phase 2** (theme `.Scratch`): Medium-High -- 112 replacements across 20 files, requires careful testing
- **Phase 3-4** (theme other): Low -- 3 replacements

## Risks

- **`.Scratch` vs `.Store` behavioral difference**: `.Scratch` and `.Store` are functionally identical except that `.Store` is not reset on rebuilds during `hugo server`. For this site, the difference is immaterial.
- **Theme breakage**: The theme's shortcodes (`codeblock`, `tabbed-codeblock`, `image`) make heavy use of `.Scratch` for state management. Each replacement must be verified to produce identical output.
- **Upstream divergence**: If fixing the vendored theme, these changes create a divergence from upstream. Consider contributing a PR to the theme repository.

## Validation

```bash
# Build with verbose deprecation warnings
hugo --logLevel warn 2>&1 | grep -i "deprecat\|scratch"

# Compare output before and after
hugo --destination public-before
# ... make changes ...
hugo --destination public-after
diff -rq public-before public-after

# Test specific pages
hugo server
# Check: posts with code blocks (codeblock shortcode)
# Check: posts with images (image shortcode)
# Check: category pages (category.terms.html)
# Check: sidebar behavior on desktop and mobile
```

## References

- [Hugo Deprecation Notices](https://gohugo.io/troubleshooting/deprecation/)
- [Hugo .Store Method](https://gohugo.io/methods/page/store/)
- [Hugo .Scratch Method (deprecated)](https://gohugo.io/methods/page/scratch/)
