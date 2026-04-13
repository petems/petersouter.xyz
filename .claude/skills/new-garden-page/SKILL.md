---
name: new-garden-page
description: "Create a new digital garden page for petersouter.xyz. Gathers the idea, picks a garden topic, writes a concise page in Peter's voice, validates the build, and creates a feat/garden/* branch. Use this skill whenever the user mentions garden content, garden pages, garden ideas, seedlings, adding to the garden, digital garden, or wants to capture a short idea/note that isn't a full blog post. If the user has a quick thought, link collection, or half-formed idea they want to publish, this is the right skill — not the blog post writer."
user_invocable: true
---

# Garden Page Creator for petersouter.xyz

The digital garden is a public scratchpad — short, honest, low-pressure pages for ideas that aren't full blog posts (and some that never will be). Garden pages are concise by design. They don't need an introduction, a conclusion, or a narrative arc. They just need to capture the idea clearly.

## Garden Conventions

- **Site URL**: https://petersouter.xyz/garden/
- **Hugo theme**: PaperMod
- **Page structure**: Page bundles at `content/garden/<topic>/<page-name>/index.md`
- **Images**: Local to the page bundle (same directory as `index.md`)
- **Frontmatter**: YAML (`---` delimiters, NOT TOML `+++`)
- **Language**: British English (`en-uk`)

---

## Execution Flow

### Step 0: Gather the Idea

Ask the user:

1. **What's the idea?** A sentence or two is fine — this is a garden page, not an essay proposal.
2. **Any source material?** Links, images, notes, files (optional).

If the user has already provided this, move on.

### Step 1: Create the Branch

Garden pages always get their own branch. Create it early so all work happens on the branch from the start.

#### Branch Safety Checks

Before creating the branch:

1. Check current branch: `git branch --show-current`
2. Check for uncommitted changes: `git status --short`
3. If there are uncommitted changes, **stop and warn the user**. Don't create a branch with dirty state — ask them to commit or stash first.
4. If already on a `feat/garden/*` branch, ask the user if they want to add to the current branch or create a new one.

#### Create the Branch

You'll need a page name first (see Step 2), so determine the topic and page name, then:

```bash
git checkout master
git pull origin master
git checkout -b feat/garden/<page-name>
```

Use the page name (not the topic) for the branch: `feat/garden/cold-brew`, `feat/garden/terrance-gore`, `feat/garden/pile-of-shame`.

### Step 2: Determine Topic and Page Name

#### Existing Garden Topics

List the current topics dynamically — don't rely on a hardcoded list, as topics get added over time:

```bash
ls -d content/garden/*/  | xargs -I{} basename {}
```

Read the `_index.md` in each topic directory if you need to understand what goes where, and look at existing pages in candidate topics for tone and content cues.

Try to fit the page into an existing topic first. If nothing fits, suggest a new topic to the user and confirm before creating it. New topics need a `_index.md` in the new directory:

```yaml
---
title: "Topic Name"
---
```

#### Page Name

- Lowercase, hyphenated: `cold-brew`, `pile-of-shame`, `terrance-gore`
- Short and descriptive
- Check for collisions: `ls content/garden/<topic>/` to ensure no duplicate

#### File Path

```
content/garden/<topic>/<page-name>/index.md
```

### Step 2: Research (Light Touch)

Garden pages are informal, but accuracy still matters.

- If the user provided links, read them with WebFetch
- If the topic references tools, commands, or facts — verify them
- Check existing garden pages in the same topic for tone and format consistency: `ls content/garden/<topic>/`
- Check existing blog posts for potential cross-links: `find content/post/ -name "*.md" | sort`

Don't over-research. The garden is a scratchpad, not a research paper.

### Step 3: Create the Page

#### Frontmatter (YAML)

```yaml
---
title: "Page Title"
date: YYYY-MM-DDT00:00:00+00:00
description: "One sentence describing the page."
garden_topic: "Topic Name"
status: "Seedling"
---
```

Field rules:
- `date`: Use today's date with `T00:00:00+00:00` (NOT the `Z` suffix — `Z` can cause posts to appear as "future" during BST. Use explicit offset instead.)
- `garden_topic`: Must match the topic directory name but title-cased (e.g., directory `cooking` → `"Cooking"`)
- `status`: One of three values:
  - **Seedling** — Half-formed idea, early notes, just planted (this is the default for new pages)
  - **Budding** — Has substance and structure but still growing, not yet a definitive reference
  - **Evergreen** — Mature, stable, a page you'd confidently link someone to
- No `author`, `slug`, `tags`, `keywords`, `draft`, `thumbnailImage`, or `coverImage` fields — garden pages don't use these

#### Writing Style

Peter's voice applies here just as much as in blog posts, but the format is different. Garden pages are short and direct.

Read `.claude/context/writing-style.md` for the full voice guide. The key points for garden content:

- **First-person, conversational**: "I learnt about...", "I've been using..."
- **British English**: recognised, organised, colour, favourite
- **No preamble**: Jump straight into the idea. No "In this page, I'll discuss..."
- **Short paragraphs**: 1-3 sentences each. White space is your friend.
- **Honest and casual**: Incomplete thoughts are fine. "I'm not sure about this yet" is valid garden content.
- **Links are generous**: Link to sources, tools, people, other garden pages, blog posts

#### Content Guidelines

Garden pages come in many shapes. Match the format to the idea:

- **A quick thought**: A few paragraphs, maybe a link or two
- **A recipe or how-to**: Steps with photos, no narrative needed
- **A list**: Links, books, recommendations — just the list with brief context
- **A quote collection**: Blockquotes with attribution
- **A reference page**: Structured with headers, code blocks, examples

What they all have in common: they're concise. If you're writing more than ~500 words, consider whether this should be a blog post instead.

#### Linking

- **Internal garden links**: `[link text](/garden/<topic>/<page-name>/)`
- **Internal blog links**: `[link text]({{< relref "post/YYYY/MM/slug.md" >}})`
- **External links**: Inline markdown `[link text](url)`

### Step 4: Handle Images

Garden pages use page bundles, so images live alongside the markdown.

1. Place images in the same directory as `index.md`: `content/garden/<topic>/<page-name>/`
2. Use descriptive kebab-case filenames: `hario-mizudashi-cold-brew-pot.webp`
3. Reference locally in markdown: `![descriptive alt text](filename.ext)`
4. No need for `static/images/` paths — everything is local to the bundle

If the user provides images, copy them into the page bundle directory.

### Step 5: Pre-Publication Check

#### Frontmatter Validation

- [ ] Uses YAML format with `---` delimiters (NOT `+++`)
- [ ] `date` is valid ISO 8601
- [ ] `garden_topic` matches an existing topic (or a new one the user confirmed)
- [ ] `status` is one of: Seedling, Budding, Evergreen
- [ ] No blog-post-only fields present (no `author`, `slug`, `tags`, `draft`, etc.)

#### AI Writing Tells

Review the draft against `.claude/context/ai-writing-tells.md`. Garden pages are short, so even a small cluster stands out. Watch for:

- AI vocabulary ("delve", "crucial", "landscape", "foster") — replace with plain language
- Inflated significance — garden pages are casual; nothing needs to "stand as a testament"
- Formulaic transitions — in a short page, "moreover" and "furthermore" stick out badly
- Promotional tone — no "stunning", "groundbreaking", "renowned"

The signal is density. One instance in a long page is fine. In a 100-word garden page, one is already a cluster.

#### Content Quality

- [ ] British English spelling throughout
- [ ] No AI writing tell clusters
- [ ] Links work (internal paths exist, external URLs are valid)
- [ ] Tone matches existing garden pages (casual, direct, personal)
- [ ] Page is concise — if it's getting long, flag to the user that it might be a blog post

#### Hugo Build Verification

```bash
hugo --buildDrafts --quiet
```

The page is only considered complete after confirming no build errors.

### Step 6: Stage and Next Steps

After creating the page, stage the files and suggest a commit:

```bash
git add content/garden/<topic>/<page-name>/
```

If a new topic `_index.md` was created, include it in the staged files.

Suggest commit message format:
```
feat(garden): add <page-name> page
```

#### Tell the user

- The page path: `content/garden/<topic>/<page-name>/index.md`
- The branch: `feat/garden/<page-name>`
- Preview command: `hugo server` then visit the garden URL
- That the page is live (no draft status) — garden pages publish immediately once merged
