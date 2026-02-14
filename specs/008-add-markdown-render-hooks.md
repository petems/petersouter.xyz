# Spec 008: Add Markdown Render Hooks

## Summary

Add Goldmark render hooks to customize how links, images, and headings are rendered in Markdown, improving security, accessibility, and user experience without modifying existing content.

## Motivation

Hugo's Goldmark renderer (default since v0.60.0) supports render hooks -- templates that intercept and customize how specific Markdown elements are rendered to HTML. This allows site-wide behavior changes without editing any blog posts.

**Current gaps the site has:**
1. **External links**: Open in the same tab, no `rel="noopener noreferrer"` for security
2. **Images**: No lazy loading, no width/height attributes (causes layout shift), no alt text enforcement
3. **Headings**: No anchor links for deep linking / sharing specific sections

Render hooks fix all of these declaratively.

## Current State

- No `layouts/_default/_markup/` directory exists
- Links, images, and headings use Goldmark's default rendering
- The theme handles some rendering via its own templates, but does not implement render hooks

## Proposed Changes

### 1. Create the render hooks directory

```bash
mkdir -p layouts/_default/_markup/
```

### 2. Add link render hook

**`layouts/_default/_markup/render-link.html`:**

```html
<a href="{{ .Destination | safeURL }}"
  {{- with .Title }} title="{{ . }}"{{ end }}
  {{- if strings.HasPrefix .Destination "http" }} target="_blank" rel="noopener noreferrer"{{ end }}>
  {{- .Text | safeHTML -}}
</a>
```

**What this does:**
- External links (starting with `http`) open in a new tab
- `rel="noopener noreferrer"` prevents tab-napping attacks
- Internal links behave normally
- Link titles are preserved

### 3. Add image render hook

**`layouts/_default/_markup/render-image.html`:**

```html
<figure>
  <img src="{{ .Destination | safeURL }}"
    {{- with .Title }} title="{{ . }}"{{ end }}
    alt="{{ .Text }}"
    loading="lazy"
    decoding="async" />
  {{- with .Title }}
  <figcaption>{{ . }}</figcaption>
  {{- end }}
</figure>
```

**What this does:**
- Wraps images in semantic `<figure>` elements
- Adds `loading="lazy"` for deferred loading of off-screen images
- Adds `decoding="async"` to prevent image decoding from blocking rendering
- Renders image titles as `<figcaption>` for better semantics
- Preserves alt text for accessibility

### 4. Add heading render hook

**`layouts/_default/_markup/render-heading.html`:**

```html
<h{{ .Level }} id="{{ .Anchor }}">
  {{- .Text | safeHTML -}}
  <a class="heading-anchor" href="#{{ .Anchor }}" aria-label="Anchor">#</a>
</h{{ .Level }}>
```

**What this does:**
- Adds anchor links to all headings (`#` suffix)
- Enables deep linking (e.g., `https://petersouter.xyz/my-post/#my-heading`)
- Uses `aria-label` for screen reader accessibility
- The anchor link can be styled via CSS (e.g., hidden until hover)

### 5. Add CSS for heading anchors

Add to `static/css/` or inline in a partial:

```css
.heading-anchor {
  text-decoration: none;
  opacity: 0;
  font-size: 0.8em;
  margin-left: 0.25em;
  color: #999;
  transition: opacity 0.2s;
}

h1:hover .heading-anchor,
h2:hover .heading-anchor,
h3:hover .heading-anchor,
h4:hover .heading-anchor {
  opacity: 1;
}
```

## Files Affected

| File | Change |
|---|---|
| `layouts/_default/_markup/render-link.html` | New file |
| `layouts/_default/_markup/render-image.html` | New file |
| `layouts/_default/_markup/render-heading.html` | New file |
| CSS (location TBD) | New heading anchor styles |

## Effort Estimate

Medium -- creating the hook templates is quick, but visual testing across all 67 posts is needed to catch edge cases.

## Risks

- **Image rendering changes**: Posts that embed images with specific HTML structure may look different when wrapped in `<figure>`. Posts using raw HTML for images (not Markdown `![]()` syntax) are unaffected by the hook.
- **Theme CSS conflicts**: The tranquilpeak theme has its own styling for images, links, and headings. The new `<figure>` wrapper and heading anchors may need CSS adjustments to integrate with the theme's visual design.
- **External link detection**: The `strings.HasPrefix .Destination "http"` check catches most external links but not protocol-relative URLs (`//example.com`). These are rare in practice.
- **RSS feed impact**: Render hooks apply to RSS output too. The anchor links in headings and lazy loading attributes will appear in the feed. This is generally desirable but should be verified.

## Validation

```bash
# Build the site
hugo server

# Check external links open in new tab
# Visit a post with external links, verify target="_blank" in HTML source

# Check images have lazy loading
# View page source, search for loading="lazy"

# Check heading anchors work
# Click a heading anchor, verify URL updates with #fragment
# Verify the anchor link is visible on hover

# Check RSS feed
curl -s http://localhost:1313/feed.xml | grep -A2 '<figure>'

# Spot-check posts with many images
# /90-day-fitness-challenge/
# /adding-my-provider-to-the-terraform-provider-registry/
```

## Future Enhancements

Once render hooks are in place, they can be extended to support:

- **Hugo image processing** (Spec 009): The image hook can process images through Hugo Pipes to generate WebP/AVIF variants
- **Responsive images**: Generate multiple sizes via `srcset`
- **Broken link detection**: Log warnings for broken internal links at build time
- **Code block hooks**: `render-codeblock.html` can customize code block rendering (e.g., adding copy buttons, language labels)

## References

- [Hugo Render Hooks Docs](https://gohugo.io/render-hooks/)
- [Hugo Link Render Hook](https://gohugo.io/render-hooks/links/)
- [Hugo Image Render Hook](https://gohugo.io/render-hooks/images/)
- [Hugo Heading Render Hook](https://gohugo.io/render-hooks/headings/)
