# Spec 002: Add --minify to Production Build

## Summary

Add the `--minify` flag to the Hugo build command in the GitHub Actions deployment workflow to reduce output size.

## Motivation

Hugo's built-in minification (available since v0.47) minifies HTML, CSS, JS, JSON, SVG, and XML output at build time with zero configuration. The Vercel build script (`build.sh`) already uses `--minify`, but the primary production deployment via GitHub Actions (`deploy.yml:57`) does not.

This is a single-character change that reduces page sizes and improves load times for free.

## Current State

**GitHub Actions build (`.github/workflows/deploy.yml:57`):**
```yaml
- name: Build site
  run: hugo --destination "$SOURCE_DIR"
```

**Vercel build (`build.sh:10,14`) -- already minified:**
```bash
hugo --minify --baseURL "https://$VERCEL_URL"
hugo --minify
```

The production deployment is the only build path missing minification.

## Proposed Changes

### Update `.github/workflows/deploy.yml`

```diff
      - name: Build site
-       run: hugo --destination "$SOURCE_DIR"
+       run: hugo --destination "$SOURCE_DIR" --minify
```

### Optional: Fine-tune minification settings in `hugo.toml`

If needed, minification behavior can be customized per format:

```toml
[minify]
  [minify.tdewolff]
    [minify.tdewolff.html]
      keepWhitespace = false
    [minify.tdewolff.css]
      keepCSS2 = true
```

The defaults are sensible and no customization should be needed initially.

## Files Affected

| File | Change |
|---|---|
| `.github/workflows/deploy.yml` | Add `--minify` flag to build step |

## Effort Estimate

Trivial -- one flag added to one line.

## Risks

- **Very low**: Hugo's minifier is mature and widely used. It preserves correctness of HTML, CSS, and JS.
- If any edge case is found (e.g., minification breaking inline `<script>` in a specific post), individual formats can be excluded via config.

## Expected Impact

Typical HTML minification savings are 10-20% of file size. CSS and JS savings vary. The cumulative effect across all 67 posts and associated pages should be measurable in total deployment size.

## Validation

```bash
# Compare output sizes before and after
hugo --destination public-unminified
du -sh public-unminified

hugo --destination public-minified --minify
du -sh public-minified

# Verify the site renders correctly
hugo server --minify
```

## References

- [Hugo Minification Docs](https://gohugo.io/getting-started/configuration/#configure-minify)
- Hugo uses the [tdewolff/minify](https://github.com/tdewolff/minify) library
