# Refactor Feedback from PaperMod Migration PR Review

Feedback collected from automated reviewers (CodeRabbit, Gemini Code Assist) during the `petems/migrate-to-papermod` PR. These are not PaperMod-specific issues but pre-existing code quality items surfaced by the large diff.

## Image Path Consistency

### 1. Inline image path inconsistency in Docker post
- **File:** `content/post/2015/12/switching-to-hosting-ghost-on-docker/index.md`
- **Issue:** Cover image uses absolute path `/images/2016/10/Compose.png`, but inline image at line 20 still uses relative path `Engine.png`. The file `static/images/2016/10/Engine.png` exists.
- **Fix:** Update inline image reference from `Engine.png` to `/images/2016/10/Engine.png` for consistency.
- **Source:** CodeRabbit comment #5

### 2. Image path date mismatch in Beaker post
- **File:** `content/post/2016/06/testing-windows-puppet-with-beaker/index.md`
- **Issue:** June 2016 post references cover image at `/images/2016/10/108487-1.png`, but the same image also exists at `/images/2016/08/108487-1.png`. Possible duplication or migration artifact.
- **Fix:** Decide on canonical image location and deduplicate.
- **Source:** CodeRabbit comment #6

### 3. Cover image wrong date directory in fitness post
- **File:** `content/post/2016/07/90-day-fitness-challenge-week-1-first-check-in/index.md`
- **Issue:** Cover image uses `/images/2016/10/swing-time-500-axis-tooltip.png` but the post is dated July 2016. The image exists at `/images/2016/07/swing-time-500-axis-tooltip.png` which matches the post date.
- **Fix:** Update path to `/images/2016/07/swing-time-500-axis-tooltip.png`.
- **Source:** CodeRabbit comment #7

## Configuration

### 4. Language code not RFC 5646 compliant
- **File:** `hugo.yaml`
- **Issue:** `languageCode` and `defaultContentLanguage` use `"en-uk"` which is non-standard. RFC 5646 / BCP 47 canonical form for British English is `"en-GB"`.
- **Fix:** Change both values from `"en-uk"` to `"en-GB"`.
- **Source:** CodeRabbit comment #8

## Frontmatter Format Consistency

### 5. Archetype uses TOML but PR describes YAML migration
- **File:** `archetypes/post.md`
- **Issue:** The archetype was converted from YAML (`---`) to TOML (`+++`), but all existing posts use TOML frontmatter. The PR description mentions "YAML format" which is contradictory.
- **Fix:** Clarify that posts use TOML frontmatter. Update PR description to match reality.
- **Source:** Gemini comment #9

### 6. CLAUDE.md should clarify frontmatter format expectations
- **File:** `CLAUDE.md`
- **Issue:** Instructions say to create posts with TOML frontmatter, but new pages like `archives.md` and `search.md` use YAML frontmatter (`---`). This is confusing.
- **Fix:** Clarify in CLAUDE.md that blog posts use TOML (`+++`) while standalone pages may use YAML (`---`).
- **Source:** Gemini comment #10

## CSS Quality

### 7. Remove `!important` from talks-list.html styles
- **File:** `layouts/partials/talks-list.html`
- **Lines:** 74, 132, 133, 148
- **Issue:** Four uses of `!important` in CSS declarations. These make debugging harder and indicate specificity issues.
- **Fix:** Remove `!important` from:
  - Line 74: `font-size: 1.9rem !important;` → `font-size: 1.9rem;`
  - Line 132: `margin-top: 0 !important;` → `margin-top: 0;`
  - Line 133: `font-size: 2.95rem !important;` → `font-size: 2.95rem;`
  - Line 148: `font-size: 1.65rem !important;` → `font-size: 1.65rem;`
- **Note:** Test after removal — `!important` may have been needed to override PaperMod theme styles. If so, restructure CSS specificity instead.
- **Source:** Gemini comments #11-14
