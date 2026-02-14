# Spec 006: Migrate Theme to Hugo Module

## Summary

Replace the vendored tranquilpeak theme directory with a Hugo Module dependency, enabling proper version management and reducing repository size.

## Motivation

The tranquilpeak theme currently lives as a full directory at `themes/tranquilpeak/` -- not a git submodule (`.gitmodules` doesn't exist) but a vendored copy of the entire theme. The deployment workflow still sets `submodules: true` unnecessarily.

Hugo Modules (introduced v0.56.0, July 2019) use Go Modules under the hood to manage theme dependencies. This provides:

- **Version pinning** with cryptographic checksums (`go.sum`)
- **Easy updates** via `hugo mod get -u`
- **Smaller repository** -- the theme source is fetched at build time, not stored in git
- **Override support** -- layout files in `layouts/` automatically override theme equivalents (this already works, but becomes cleaner when the theme isn't vendored)

## Current State

- Theme directory: `themes/tranquilpeak/` (~thousands of files including source SCSS, Grunt configs, example site)
- No `.gitmodules` file
- `config.toml:5`: `theme = "tranquilpeak"`
- `deploy.yml:47`: `submodules: true` (unnecessary)
- Custom layout overrides in `layouts/` (8 files)

## Proposed Changes

### 1. Initialize the project as a Hugo Module

```bash
hugo mod init github.com/petems/petersouter.xyz
```

This creates `go.mod` and `go.sum` in the project root.

### 2. Update Hugo config

```diff
- theme = "tranquilpeak"

+ [module]
+   [[module.imports]]
+     path = "github.com/kakawait/hugo-tranquilpeak-theme"
```

### 3. Remove the vendored theme

```bash
rm -rf themes/tranquilpeak/
```

The `themes/` directory can remain (Hugo still checks it) but will be empty.

### 4. Vendor the module (recommended for reproducible builds)

```bash
hugo mod vendor
```

This creates a `_vendor/` directory with the fetched module, ensuring builds work without network access. The `_vendor/` directory should be committed.

Alternatively, skip vendoring and let CI fetch the module at build time (faster git clones, but requires network during build).

### 5. Update GitHub Actions workflow

```diff
      - name: Checkout code
        uses: actions/checkout@v6
        with:
-         submodules: true
          fetch-depth: 0
+
+     - name: Setup Go
+       uses: actions/setup-go@v5
+       with:
+         go-version: 'stable'
```

Hugo Modules require Go to be installed (for `go mod` operations). If vendoring, Go is not needed at build time.

### 6. Update Vercel build

If using Hugo Modules without vendoring, the Vercel build environment also needs Go. With vendoring, no changes are needed.

## Files Affected

| File | Change |
|---|---|
| `hugo.toml` (or `config.toml`) | Replace `theme` with `[module]` import |
| `themes/tranquilpeak/` | Delete entire directory |
| `go.mod` | New file (auto-generated) |
| `go.sum` | New file (auto-generated) |
| `_vendor/` | New directory (if vendoring) |
| `.github/workflows/deploy.yml` | Remove `submodules: true`, optionally add Go setup |
| `.github/workflows/deploy-vercel-preview.yml` | May need updates if not vendoring |

## Effort Estimate

Medium -- the migration itself is straightforward, but testing is important to ensure all layout overrides continue to work correctly.

## Risks

- **Theme compatibility**: The upstream `kakawait/hugo-tranquilpeak-theme` may have diverged from the vendored copy. The vendored copy is version 0.4.8-BETA. If upstream has breaking changes, you'd need to pin to a specific commit.
- **Build-time network dependency**: Without vendoring, CI builds require fetching the module from GitHub. Vendoring eliminates this risk.
- **Go dependency**: Hugo Modules require Go to be installed for module management commands. This is only needed during development and CI (not for simple builds with vendored modules).
- **Deprecated patterns**: The theme uses `.Scratch` (120 occurrences) and `.UniqueID` (2 occurrences). These deprecations exist in both the vendored copy and upstream -- this spec doesn't address them (see Spec 007).

## Validation

```bash
# Initialize the module
hugo mod init github.com/petems/petersouter.xyz

# Fetch the theme
hugo mod get github.com/kakawait/hugo-tranquilpeak-theme

# Verify the module graph
hugo mod graph

# Build and test
hugo server

# Check that layout overrides still work
# Visit pages that use custom layouts (single posts, sidebar, about page)

# Optionally vendor
hugo mod vendor
```

## Migration Checklist

- [ ] Verify upstream theme version compatibility
- [ ] Initialize Hugo Module (`go.mod`)
- [ ] Update config to use module import
- [ ] Remove vendored theme directory
- [ ] Vendor the module (optional)
- [ ] Update CI workflow
- [ ] Test all custom layout overrides
- [ ] Test Vercel preview builds
- [ ] Verify the site renders identically

## References

- [Hugo Modules Docs](https://gohugo.io/hugo-modules/)
- [Migrating from git submodules to Hugo Modules](https://jh123x.com/blog/2025/migrating-hugo-from-submodules-to-hugo-modules/)
- [Hugo Modules vs Git Submodules](https://drmowinckels.io/blog/2025/submodules/)
- [hugo-tranquilpeak-theme on GitHub](https://github.com/kakawait/hugo-tranquilpeak-theme)
