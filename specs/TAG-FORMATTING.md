# Tag System Improvements for petersouter.xyz

## Context

Tags on the /tags/ archives page look messy due to inconsistent capitalization (mix of `docker`, `Docker`, `personal`, `Personal`, etc.). Additionally, tags and categories are duplicated across nearly all posts, making both taxonomies redundant. This plan fixes tag display by standardizing casing in frontmatter, differentiates categories from tags, adds missing tags to 2 untagged posts, and creates layout overrides to protect customizations from theme updates.

---

## Phase 1: Standardize Tag Casing in Frontmatter (All 60 tagged posts)

Capitalize all tags to Title Case in frontmatter, preserving acronyms. Since we're already touching every post for category differentiation (Phase 2), this adds minimal overhead.

**Canonical tag list (45 tags, Title Cased):**

| Current | Canonical | Notes |
|---|---|---|
| `ansible` | `Ansible` | |
| `AWS` | `AWS` | Acronym, keep |
| `BDD` | `BDD` | Acronym, keep |
| `beaker` | `Beaker` | |
| `blog`/`Blog` | `Blog` | Fix inconsistency |
| `cfgmgmtcamp` | `CfgMgmtCamp` | Event name |
| `conferences` | `Conferences` | |
| `config management` | `Config Management` | |
| `cygwin` | `Cygwin` | |
| `data` | `Data` | |
| `devops` | `DevOps` | Standard casing |
| `docker` | `Docker` | |
| `fitness` | `Fitness` | |
| `FOSDEM` | `FOSDEM` | Acronym, keep |
| `gandi` | `Gandi` | Brand name |
| `GCE` | `GCE` | Acronym, keep |
| `ghost` | `Ghost` | Platform name |
| `Golang` | `Golang` | Already correct |
| `gym` | `Gym` | |
| `HashiCorp` | `HashiCorp` | Already correct |
| `health` | `Health` | |
| `hiera` | `Hiera` | Puppet tool name |
| `Hugo` | `Hugo` | Already correct |
| `kettlebells` | `Kettlebells` | |
| `meetup`/`meetups` | `Meetups` | Standardize to plural |
| `metrics` | `Metrics` | |
| `monitoring` | `Monitoring` | |
| `New Year` | `New Year` | Already correct |
| `nginx` | `Nginx` | |
| `open-source` | `Open-Source` | |
| `performance` | `Performance` | |
| `Puppet` | `Puppet` | Already correct |
| `ruby`/`Ruby` | `Ruby` | Fix inconsistency |
| `S3` | `S3` | Acronym, keep |
| `sysadmin` | `SysAdmin` | |
| `sysops` | `SysOps` | |
| `systemd` | `Systemd` | |
| `Talks` | `Talks` | Already correct |
| `TDD` | `TDD` | Acronym, keep |
| `Terraform` | `Terraform` | Already correct |
| `Testing` | `Testing` | Already correct |
| `Vagrant` | `Vagrant` | Already correct |
| `Vault` | `Vault` | Already correct |
| `vDM30in30` | `vDM30in30` | Keep original - hashtag |
| `windows` | `Windows` | |

**Files to modify:** All 60 posts with tags in `content/post/`

---

## Phase 2: Differentiate Categories from Tags

Currently tags and categories are identical in ~55 of 60 posts. Change categories to broad groupings while keeping tags as specific topics.

**Category set:** `Tech`, `Personal`, `Career`, `Cooking`, `Travel`, `Music`

**Non-duplication rule:** A post's tags must not duplicate any of its categories. Tags should be more specific than broad category names. The five category names (`Tech`, `Personal`, `Cooking`, `Travel`, `Music`) have been removed from the canonical tag list in Phase 1 for this reason. If a post previously used one of these as a tag, it should either be dropped (when covered by the category) or replaced with a more specific tag.

**Category assignment by post:**

| Post | Categories | Tags (keep/update per Phase 1) |
|---|---|---|
| Posts about Puppet, Terraform, Docker, testing, tools, systems, monitoring, etc. | `Tech` | Keep specific tech tags |
| Posts about fitness, health, gym, kettlebells | `Personal` | Keep specific fitness/health tags |
| `an-eventful-2017.md`, `end-of-an-era.md` | `Career` | Keep existing tags |
| `kasespatzle-making.md` | `Cooking` | _(none — covered by category)_ |
| `dublin-web-summit-2013.md`, conference travel posts | `Tech`, `Travel` | Conference-related tags |
| `travelling-consultant-hardware-essentials.md` | `Personal`, `Travel` | Keep existing tags |
| `musical-tastes.md` | `Personal`, `Music` | `vDM30in30` |
| `fosdem-survival-guide.md` | `Tech`, `Travel` | FOSDEM, Conferences, etc. |

**Detailed mapping (all 62 posts):**

- **Tech** (sole category): Most technical posts (~45 posts) - Puppet, Terraform, Golang, testing, Docker, monitoring, sysadmin, tools posts
- **Personal**: Fitness posts (4), keyboard-geekery, fitter-and-healthier
- **Career**: an-eventful-2017 (new year reflections), end-of-an-era (job change)
- **Cooking**: kasespatzle-making
- **Travel**: travelling-consultant, dublin-web-summit
- **Music**: musical-tastes
- **Multi-category**: Conference posts get `Tech` + `Travel`; travelling-consultant gets `Personal` + `Travel`; musical-tastes gets `Personal` + `Music`

---

## Phase 3: Add Missing Tags to Untagged Posts

Two posts have no tags or categories:

1. **`day-30-vdm30in30-is-over.md`**
   - Tags: `["vDM30in30", "Blog"]`
   - Categories: `["Personal"]`

2. **`dublin-web-summit-2013.md`**
   - Tags: `["Conferences", "Meetups", "DevOps"]`
   - Categories: `["Tech", "Travel"]`

---

## Phase 4: Create Layout Overrides

Copy theme templates to root `layouts/` so theme updates don't overwrite customizations.

**Files to create:**
- `layouts/taxonomy/tag.terms.html` (copy from `themes/tranquilpeak/layouts/taxonomy/tag.terms.html`)
- `layouts/partials/post/tag.html` (copy from `themes/tranquilpeak/layouts/partials/post/tag.html`)

No functional changes to these templates — they serve as a protective override layer. The tag display improvement comes from the frontmatter fixes in Phase 1.

---

## Implementation Order

1. **Phases 1 + 2 + 3 together** — Edit all 62 posts: fix tag casing, set proper categories, add missing tags. Single commit.
2. **Phase 4** — Create layout overrides. Separate commit.

---

## Key Files

- `content/post/*.md` — All 62 blog posts (frontmatter edits)
- `themes/tranquilpeak/layouts/taxonomy/tag.terms.html` — Source for layout override
- `themes/tranquilpeak/layouts/partials/post/tag.html` — Source for layout override
- `config.toml` — Taxonomy config (no changes needed)

## Verification

1. Run `hugo server` locally and check:
   - `/tags/` page — all tags should display in consistent Title Case
   - `/categories/` page — should show only broad categories (Tech, Personal, Career, Cooking, Travel, Music)
   - Individual post pages — tags display correctly, tag links work
   - Click through several tag links to verify posts are grouped correctly
2. Verify no broken links by checking that tag URLs resolve (Hugo generates from lowercase slugs, so casing changes don't affect URLs)
3. Check that the layout overrides in `layouts/` take precedence by verifying the /tags/ page still renders correctly

## Risk

- **URL stability**: Hugo's `urlize` lowercases tag names for URLs. Changing `docker` to `Docker` in frontmatter still produces `/tags/docker/`. No URL breakage.
- **Exception**: Changing `meetup` to `Meetups` changes the URL from `/tags/meetup/` to `/tags/meetups/`. Only 1 post affected, low risk for a personal blog.
- **Layout overrides**: If the Tranquilpeak theme is updated with breaking template changes, the overrides will need manual reconciliation.
