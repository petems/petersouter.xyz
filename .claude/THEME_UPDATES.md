# Theme Update Guide

## Problem: Hardcoded Asset Paths

When you fully override core theme partials like `head.html` or `script.html`, you copy the entire file including hardcoded asset filenames:

```html
<link rel="stylesheet" href="/css/style-OLD-HASH.min.css" />
<script src="/js/script-OLD-HASH.min.js"></script>
```

When the theme updates, it generates new hashed filenames, but your overrides still point to the old files → **404 errors**.

## Solution: Use Extension Points

The tranquilpeak theme provides specific hooks for customization. **Always use these instead of full overrides:**

### Available Extension Points

| Extension Point | Location | Purpose |
|----------------|----------|---------|
| `head_start.html` | Start of `<head>` | Early head customizations |
| `head_end.html` | End of `<head>` | Late-loading CSS, custom meta tags |
| `foot_start.html` | Start of `<body>` close | Before theme scripts load |
| `foot_end.html` | End of `<body>` close | After theme scripts, custom JS |
| `params.customCSS` | Config | Additional stylesheets |
| `params.customJS` | Config | Additional JavaScript files |

### Current Customizations

**`layouts/partials/head_end.html`:**
- Custom Font Awesome kit (overrides theme's CDN version)
- Modern web standards (manifest, icons)

**`layouts/partials/foot_end.html`:**
- Terraform language for highlight.js (needs manual registration)
- Gherkin language for highlight.js (auto-registers)

**`layouts/_internal/google_analytics_async.html`:**
- Hugo compatibility shim for theme's GA template

## Updating the Theme

### With Git Subtree (Current Setup)

```bash
# Update theme to latest version
git subtree pull --prefix themes/tranquilpeak \
  https://github.com/kakawait/hugo-tranquilpeak-theme/ \
  master --squash

# Test the build
hugo --quiet

# Check for asset loading errors
hugo server
# Visit http://localhost:1313 and check browser console for 404s

# If build succeeds and no errors, commit
git add themes/tranquilpeak
git commit -m "chore: update tranquilpeak theme to latest version"
```

### What to Check After Updates

1. **Build succeeds**: `hugo --quiet` exits with code 0
2. **Assets load**: No 404s in browser console for CSS/JS
3. **Syntax highlighting works**: Test posts with code blocks (Terraform, Gherkin)
4. **Font Awesome works**: Icons render correctly
5. **Comments work**: Disqus loads on posts

### If Something Breaks

1. Check if theme added new extension points
2. Look for renamed/moved partials
3. Check CHANGELOG.md in theme for breaking changes
4. Search theme's GitHub issues for similar problems

## Rules for Customization

### ✅ DO

- Use extension points (`head_end.html`, `foot_end.html`)
- Use config-based customization
- Override specific, small partials when necessary
- Document WHY you're overriding something

### ❌ DON'T

- Copy entire core partials (`head.html`, `script.html`)
- Hardcode asset filenames with hashes
- Override internal theme logic unless absolutely necessary
- Make changes without documenting them

## Language Registration Reference

When adding custom highlight.js languages:

**Needs Manual Registration:**
- Terraform (third-party plugin)
- Any custom language with external definition

**Auto-Registers:**
- Gherkin (official highlight.js language)
- Any official highlight.js language
- Languages loaded from CDN's `languages/` directory

Example:
```javascript
// Manual registration required
hljs.registerLanguage('terraform', window.hljsDefineTerraform);

// Auto-registers, just load the script
<script src=".../languages/gherkin.min.js"></script>
```
