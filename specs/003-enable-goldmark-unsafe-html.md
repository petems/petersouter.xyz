# Spec 003: Enable Goldmark Unsafe HTML Rendering

## Summary

Properly configure Goldmark to render raw HTML in Markdown files, replacing the current warning suppression approach.

## Motivation

When Hugo switched from Blackfriday to Goldmark (v0.60.0), raw HTML in Markdown files was stripped by default for security. The current config suppresses the warning about this:

```toml
ignoreLogs = ['warning-goldmark-raw-html']
```

This hides the symptom but doesn't fix the underlying issue. Any raw HTML blocks in blog posts (e.g., `<iframe>`, `<video>`, `<div>` wrappers, embedded widgets) are silently stripped from the rendered output. Since this is a personal blog where the author controls all content, enabling raw HTML rendering is the correct approach.

## Current State

- `config.toml:7` suppresses the Goldmark raw HTML warning
- No `[markup]` section exists in the config
- Blog posts likely contain raw HTML (the warning was being triggered, hence the suppression)

## Proposed Changes

### Update Hugo config

```diff
- ignoreLogs = ['warning-goldmark-raw-html']
+ [markup.goldmark.renderer]
+   unsafe = true
```

Remove the `ignoreLogs` line entirely and replace it with the proper Goldmark configuration. With `unsafe = true`, raw HTML is rendered correctly and no warning is generated.

## Files Affected

| File | Change |
|---|---|
| `hugo.toml` (or `config.toml`) | Remove `ignoreLogs`, add `[markup.goldmark.renderer]` section |

## Effort Estimate

Trivial -- a config change of 2-3 lines.

## Risks

- **Security**: Enabling `unsafe = true` means any HTML in Markdown is rendered as-is. Since this is a personal blog where only the author writes content, this is acceptable.
- **If the warning was a false positive**: If no posts actually contain raw HTML, removing `ignoreLogs` without adding `unsafe = true` would simply re-surface the warning. Adding `unsafe = true` is harmless in that case.

## Validation

```bash
# Search for posts that contain raw HTML
grep -rn '<iframe\|<video\|<div\|<table\|<script\|<style' content/post/ | head -20

# Build the site and verify HTML blocks render
hugo server
# Manually check posts known to contain HTML blocks

# Verify no warnings in build output
hugo 2>&1 | grep -i "goldmark\|raw"
```

## References

- [Hugo Goldmark Configuration](https://gohugo.io/configuration/markup/#goldmark)
- [Goldmark Raw HTML Documentation](https://gohugo.io/configuration/markup/#rendererunsafe)
- Hugo v0.60.0 changelog (Goldmark became default)
- Hugo v0.100.0 changelog (Blackfriday removed entirely)
