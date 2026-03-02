---
name: blog-post-writer
description: "Write a new blog post for petersouter.xyz. Gathers requirements, researches source material, creates the post with correct Hugo frontmatter and site conventions, and verifies the build. Use when the user wants to write, draft, or start a new blog post."
user_invocable: true
---

# Blog Post Writer for petersouter.xyz

## Blog Conventions

- **Site URL**: https://petersouter.xyz/
- **Hugo theme**: tranquilpeak
- **Post files**: `content/post/YYYY/MM/slug.md` (flat files, NOT page bundles)
- **Image files**: `static/images/YYYY/MM/` (separate from content)
- **Frontmatter**: TOML (`+++` delimiters, NOT YAML `---`)
- **Permalinks**: `/:title/` (title-based, no dates in URLs)
- **Language**: British English (`en-uk`)

---

## Mandatory Execution Flow

Each step must be completed before proceeding to the next. No steps may be skipped.

---

### Step 0: Gather Requirements

Before starting any work, confirm the following with the user:

1. **Topic**: What is the post about?
2. **Source material** (optional): Reference URLs, documents, notes, GitHub repos
3. **Target keywords** (optional): SEO keywords for discoverability

If the user has already provided this information, proceed directly to Step 1.

---

### Step 1: Determine Category, Slug, and File Path

#### Category Standards

Select a category based on article content. Only use established categories from the blog:

| Category | Applicable Content |
|----------|-------------------|
| **Tech** | Technical posts, tutorials, tools, programming, DevOps |
| **Personal** | Personal reflections, life updates, non-technical |
| **Conference** | Trip reports, event coverage, conference summaries |
| **Meta, Blogging** | Posts about the blog itself, writing process |
| **Career** | Career advice, professional development |
| **Cooking** | Recipes, food-related |
| **Tech, Travel** | Technical content with a travel component |

Multiple categories can be combined as an array: `categories = ["Meta", "Blogging"]`

#### File Path

1. Use the `date` command to get the current date
2. Generate a slug: lowercase, hyphenated, descriptive (e.g. `getting-started-with-terraform-modules`)
3. Check for slug collisions: `ls content/post/` recursively to ensure uniqueness
4. Post file: `content/post/YYYY/MM/slug.md`
5. Image directory (if needed): `static/images/YYYY/MM/`

---

### Step 2: Research Source Material

#### 2.1 Read User-Provided Material

If the user provided reference links, read them thoroughly using WebFetch. Do not guess based on titles alone. For GitHub links, use the `gh` CLI or access raw content.

#### 2.2 Proactive Research

Always perform the following:

- Use `WebSearch` to find the latest developments and authoritative sources on the topic
- Check for official documentation, best practices, or canonical references
- Search for contrasting viewpoints or common misconceptions
- If the topic involves tools/frameworks, find official docs and GitHub repositories

#### 2.3 Check Existing Posts (for Internal Linking)

Run the following to get the blog's existing article list:

```bash
find content/post/ -name "*.md" | sort
```

Record existing posts for use in adding internal links during Step 3. Look for topical overlap with the new post.

---

### Step 3: Create the Post File

**Do NOT use `hugo new`** — the archetype uses YAML frontmatter but all posts use TOML. Create the file directly.

#### Frontmatter Template (TOML)

```toml
+++
author = "Peter Souter"
categories = ["Tech"]
date = YYYY-MM-DDTHH:MM:SSZ
description = "A concise SEO description of the post (one sentence)."
draft = true
slug = "post-slug-here"
tags = ["Tag1", "Tag2", "Tag3"]
title = "Post Title Here"
keywords = ["keyword1", "keyword2"]
thumbnailImage = ""
coverImage = ""
+++
```

Field rules:
- `author` is always `"Peter Souter"`
- `draft` is always `true` (user publishes manually)
- `date` uses ISO 8601 with UTC timezone suffix `Z` (not `+00:00` or `+08:00`)
- `slug` must be unique across all existing posts
- `description` should be filled for SEO, but can be `""` if unclear
- `thumbnailImage` and `coverImage` are `""` if no images provided (see Step 4)

#### Writing Style

Peter's voice is:
- **Conversational and first-person**: Uses "I", "you", personal anecdotes
- **Informal**: Contractions ("I've", "it'd"), colloquialisms, rhetorical questions
- **Honest and self-deprecating**: Admits mistakes, acknowledges limitations
- **British English spelling**: recognised, organised, colour, favourite, humour
- **Link-heavy**: Both internal cross-links to other posts and external references
- **Uses `<!--more-->`**: Place after the first paragraph or opening hook to set the excerpt boundary

#### Content Structure

For technical posts, follow a logical structure:
```
Opening hook / why this matters
<!--more-->
## Background / Context
## The core content (concepts, tutorial, walkthrough)
## Practical examples or real-world experience
## Gotchas / things I learned the hard way
## Wrap-up
```

For personal/meta posts, a more narrative flow is fine.

#### Linking

- **Internal links**: Link to existing blog posts where relevant using `(/slug-name/)` format
- **External links**: Link to authoritative sources (official docs, GitHub repos, RFCs)
- Use inline markdown links: `[link text](url)`

#### Available Shortcodes

- YouTube: `{{< youtube VIDEO_ID >}}`
- Bluesky: `{{< bluesky link="URL" >}}`
- Standard Hugo shortcodes: `figure`, `gist`, `highlight`

---

### Step 4: Handle Images

No image generation. If the user provides images:

1. Create directory: `mkdir -p static/images/YYYY/MM/`
2. Place images there with descriptive kebab-case names
3. Naming convention:
   - Thumbnail: `descriptive-name.jpg`
   - Cover (wider version): `descriptive-name-cover.jpg`
4. Set frontmatter paths:
   - `thumbnailImage = "/images/YYYY/MM/descriptive-name.jpg"`
   - `coverImage = "/images/YYYY/MM/descriptive-name-cover.jpg"`
5. In-body images: `![descriptive alt text](/images/YYYY/MM/filename.ext)`

If no images are available, leave `thumbnailImage` and `coverImage` as `""`.

GitHub Actions will automatically optimise images on commit — no manual compression needed.

---

### Step 5: Pre-Publication Check

#### Frontmatter Validation
- [ ] Uses TOML format with `+++` delimiters (NOT `---`)
- [ ] `author = "Peter Souter"` is present
- [ ] `draft = true`
- [ ] `date` is valid ISO 8601 with `Z` suffix
- [ ] `slug` is unique (no collision with existing posts)
- [ ] `categories` uses established values only
- [ ] Image paths point to real files or are `""`

#### Content Quality
- [ ] `<!--more-->` is present after opening paragraph
- [ ] British English spelling used throughout
- [ ] Internal links to existing posts where relevant
- [ ] External links to authoritative sources
- [ ] No broken markdown links or image references
- [ ] Shortcode syntax is correct (if used)

#### Hugo Build Verification

Run build verification:

```bash
hugo --buildDrafts --quiet
```

The post is only considered complete after confirming there are no build errors.

#### Next Steps (suggest to user)

- Preview: `hugo server --buildDrafts` then visit `http://localhost:1313/slug-name/`
- Commit: `git add content/post/YYYY/MM/slug.md static/images/YYYY/MM/` (if images added)
- Commit message: `feat: add draft blog post about [topic]`
