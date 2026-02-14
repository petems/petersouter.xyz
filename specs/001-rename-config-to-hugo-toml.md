# Spec 001: Rename config.toml to hugo.toml

## Summary

Rename the Hugo configuration file from `config.toml` to `hugo.toml` to follow the convention introduced in Hugo v0.110.0.

## Motivation

Since Hugo v0.110.0 (December 2022), `hugo.toml` is the preferred configuration filename. While `config.toml` still works as a fallback, the new naming convention is the standard used in all Hugo documentation, tutorials, and `hugo new site` scaffolding. Adopting it keeps the project aligned with the ecosystem and reduces confusion for contributors.

## Current State

- Configuration lives at `/config.toml` (222 lines)
- `build.sh` references `config.toml` in a comment on line 13
- `CLAUDE.md` references `config.toml` in multiple places

## Proposed Changes

### 1. Rename the config file

```bash
git mv config.toml hugo.toml
```

No changes to the file contents are required -- this is purely a rename.

### 2. Update `build.sh` comment

```diff
-  # Production or local build - use production URL from config.toml
+  # Production or local build - use production URL from hugo.toml
```

### 3. Update `CLAUDE.md` references

Replace all references to `config.toml` with `hugo.toml` throughout the documentation.

## Files Affected

| File | Change |
|---|---|
| `config.toml` | Rename to `hugo.toml` |
| `build.sh` | Update comment on line 13 |
| `CLAUDE.md` | Update documentation references |

## Effort Estimate

Trivial -- a single rename plus comment/doc updates.

## Risks

- **None**: Hugo fully supports both filenames. If both exist, `hugo.toml` takes precedence.
- The Vercel build, GitHub Actions workflow, and local `hugo server` all auto-discover the config file by convention -- no path is hardcoded in any of them.

## Validation

```bash
# Verify Hugo picks up the renamed config
hugo config | head -5

# Verify the site builds correctly
hugo --destination public
```

## References

- [Hugo Configuration Docs](https://gohugo.io/configuration/introduction/)
- Hugo v0.110.0 changelog
