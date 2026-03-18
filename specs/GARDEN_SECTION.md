# Spec: Garden Section

## Summary

Add a dedicated `/garden/` section to the Hugo site that behaves more like a curated knowledge garden than a chronological blog archive.

The section should borrow the key interaction pattern from <https://www.danielcorin.com/garden/>:

- a short landing page intro
- a highlighted phrase such as "A place for thoughts, ideas and essays I tend to"
- grouped links by topic instead of a date-first list

The recommended implementation is a first-class Hugo section at `content/garden/` with a custom section template and per-note metadata for grouping.

## Reference Page Notes

The referenced page is simple and editorial rather than app-like:

- URL: `/garden/`
- Heading: `Garden`
- Short intro sentence under the heading
- Notes grouped into topic buckets such as `Language Models` and `Software Eng`
- Each group shows a count and then a flat list of links
- The page feels like a subsection of the site, not a separate product

That is a good fit for Hugo. There is no need for a separate app, database, or client-side filtering to get the same effect.

## Goals

- Create a clear home for shorter, evolving ideas that do not fit full blog posts
- Keep the Garden visually distinct from normal post archives
- Preserve Hugo simplicity and keep content authoring Markdown-first
- Support curated topic grouping on the `/garden/` landing page
- Keep note URLs stable and readable

## Non-Goals

- Building a separate SPA or JavaScript-heavy knowledge base
- Replacing the main blog post flow
- Implementing bidirectional linking or graph visualisation in the first version

## Approaches

### 1. Taxonomy-driven Garden

Model Garden entries as normal posts and group them via a taxonomy such as `garden_topic`.

**Pros**
- Minimal new content structure
- Reuses existing list pages and taxonomy features

**Cons**
- Weak editorial control over landing page ordering
- Harder to make `/garden/` feel like a distinct subsection
- Taxonomies are better for metadata than for primary IA

### 2. Dedicated Hugo section

Create `content/garden/` with its own `_index.md`, custom layouts, and note pages stored under that section.

**Pros**
- Best fit for Hugo's content model
- Natural `/garden/` URL space
- Easy to give the section its own hero, grouping, styling, and menu entry
- Keeps notes separate from blog posts without creating a separate site

**Cons**
- Requires custom templates
- Introduces one more content type to maintain

### 3. Separate mini-site mounted into Hugo

Build the Garden as a second Hugo site, module, or heavily isolated content tree and mount it under `/garden/`.

**Pros**
- Maximum isolation
- Useful only if the Garden later becomes a substantially different product

**Cons**
- Unnecessary complexity today
- More build and config overhead
- Harder to share theme, menus, feeds, and styling

## Recommendation

Use **Approach 2: a dedicated Hugo section**.

This gives the site a real Garden subsection while keeping everything inside the current Hugo/PaperMod setup. Topic grouping should be handled by a frontmatter param on each note, not by nested directories or taxonomies.

Recommended content model:

```text
content/
  garden/
    _index.md
    building-with-ai/
      index.md
    ongoing-thoughts/
      index.md
    helpful-habits/
      index.md
```

Each Garden note should use page bundles from the start so images and attachments can live beside the note if needed.

## Proposed Content Model

### Section landing page

`content/garden/_index.md`

Example frontmatter:

```yaml
---
title: "Garden"
description: "A place for thoughts, ideas and essays I tend to"
layout: "garden"
showReadingTime: false
---
```

The body can optionally explain what the Garden is and how it differs from blog posts.

### Individual notes

Example `content/garden/building-with-ai/index.md`:

```yaml
---
title: "Building With AI"
date: 2026-03-18T10:00:00Z
type: "garden"
layout: "garden-note"
garden_topic: "Language Models"
summary: "Working notes on using LLMs in software projects."
status: "evergreen"
---
```

Recommended frontmatter fields:

- `garden_topic`: the landing-page bucket label
- `status`: optional values like `seedling`, `growing`, `evergreen`
- `summary`: short link description if needed later

The critical field is `garden_topic`. It allows grouped rendering on `/garden/` while keeping note URLs flat as `/garden/<slug>/`.

## Template Plan

### Landing page template

Add a section-specific list template, for example:

- `layouts/garden/list.html`

Expected behaviour:

- render the section title
- render a custom hero sentence with one highlighted phrase
- group `.Pages` by `garden_topic`
- sort groups alphabetically or by an explicit weight map
- show the topic name and note count
- list note titles as links under each group

Hugo supports this cleanly with `GroupByParam "garden_topic"`.

Pseudo-template shape:

```go-html-template
{{ define "main" }}
  <header class="garden-hero">
    <h1>{{ .Title }}</h1>
    <p class="garden-tagline">
      A place for <span class="garden-highlight">thoughts, ideas and essays</span> I tend to.
    </p>
  </header>

  {{ range .Pages.GroupByParam "garden_topic" }}
    <section class="garden-group">
      <h2>{{ .Key }} <span>{{ len .Pages }}</span></h2>
      <ul>
        {{ range .Pages.ByTitle }}
          <li><a href="{{ .RelPermalink }}">{{ .Title }}</a></li>
        {{ end }}
      </ul>
    </section>
  {{ end }}
{{ end }}
```

### Note template

Garden notes can initially reuse the default single-page template if desired, but a small override is likely useful:

- `layouts/garden/single.html` or `layouts/_default/single.html` with a `type == "garden"` branch

Differences from blog posts:

- lighter metadata
- optional status badge
- less emphasis on publish date and reading time
- optional "Back to Garden" affordance

## Visual Treatment

The Garden should feel adjacent to the blog, but not identical.

Recommended styling choices:

- a compact hero at the top of `/garden/`
- highlighted phrase using a marker-style background or underline
- tighter grouped lists with low visual noise
- slightly more notebook-like feel than the main blog archive

Implementation path in this repo:

- add custom CSS through a PaperMod extension path such as `assets/css/extended/garden.css`
- include only the styles needed for the Garden section

Suggested highlight treatment:

```css
.garden-highlight {
  background: linear-gradient(transparent 55%, #f6e27a 55%);
  padding: 0 0.15em;
}
```

This reproduces the "highlighted phrase" feel without requiring inline HTML in content beyond a simple span in the template.

## Navigation and Discovery

Add `Garden` to the main menu in `hugo.yaml`:

```yaml
menu:
  main:
    - identifier: "garden"
      name: "Garden"
      url: "/garden/"
      weight: 5
```

Weights for existing items will need to shift accordingly.

Optional later enhancements:

- homepage callout linking to `/garden/`
- dedicated RSS feed for Garden notes
- status-based styling for `seedling` vs `evergreen`

## Files Affected

| File | Change |
|---|---|
| `hugo.yaml` | Add menu entry and any section-specific params if needed |
| `content/garden/_index.md` | New landing page content |
| `content/garden/*/index.md` | New Garden notes |
| `layouts/garden/list.html` | Custom grouped landing page |
| `layouts/garden/single.html` | Optional note template override |
| `assets/css/extended/garden.css` | Garden-specific styling |

## Rollout Plan

### Phase 1: Structural setup

- Add the `Garden` menu entry
- Create `content/garden/_index.md`
- Add the custom list template
- Add CSS for hero, highlight, and grouped note lists

### Phase 2: Seed content

- Create 3-5 initial Garden notes from existing idea fragments
- Assign each note a `garden_topic`
- Verify grouped rendering and URL structure

### Phase 3: Refine authoring workflow

- Add a Garden archetype if note creation becomes frequent
- Decide whether Garden notes should appear in global archives/search
- Add note status styling if it adds value

## Risks

- **Overlapping with blog posts**: If the distinction between `post` and `garden` is vague, authoring will drift. A short rule of thumb should be documented.
- **Theme coupling**: PaperMod may require layout overrides to make the section feel distinct; keep overrides narrow and local.
- **Group ordering**: Alphabetical grouping may be fine at first, but a manual weight map may be needed once topics grow.
- **Search/archive behaviour**: Garden notes may appear in the main archives unless explicitly excluded or separately styled.

## Validation

```bash
# Build the site
hugo

# Run locally
hugo server

# Check the new landing page
open http://localhost:1313/garden/

# Verify note URLs resolve
open http://localhost:1313/garden/building-with-ai/
```

Manual checks:

- the `/garden/` page has a distinct intro and highlighted phrase
- notes are grouped by topic, not date
- note links render correctly
- the section still feels consistent with the rest of the site

## Recommendation Summary

Build the Garden as a custom Hugo section, not as a taxonomy trick and not as a separate site. That gives the cleanest implementation, matches the reference page's editorial structure, and leaves room to evolve the section later without introducing unnecessary complexity.
