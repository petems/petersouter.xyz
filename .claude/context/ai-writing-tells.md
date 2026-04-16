# AI Writing Tells - Self-Review Checklist

Adapted from [Wikipedia: Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing), which catalogs patterns statistically overrepresented in LLM output. Use this as a final pass to catch robotic phrasing that slipped through into blog drafts.

This checklist is **descriptive, not prescriptive**. A few of these patterns appear naturally in good human writing. The signal is density - one "pivotal" is fine; five AI vocabulary words in two paragraphs is a rewrite.

## Personal Style Overrides

A few patterns in this checklist are genuine AI tells, but Peter prefers them in his own writing. These overrides are deliberate - do not "correct" them during drafting or review:

- **Title Case for All Headings (H1, H2, H3).** LLMs overuse Title Case (see Formatting tells below). Peter uses it anyway: it reads cleaner on his site and matches his aesthetic preference. Sentence case is not the house style.
- **Title Case for Bold Prefixes in Headline-Style Bullets.** Bullets of the shape `**Term:** description` use Title Case on the term (Chicago style: capitalize principal words; lowercase articles, short prepositions, coordinating conjunctions). Plain prose bullets keep natural sentence case.
- **Zero Em-Dashes and Zero En-Dashes in Prose.** LLMs overuse em-dashes (see Em dash overuse below). Peter's rule is stricter than the checklist: none at all in published content. Use a hyphen (-), parentheses, a comma, or a colon. Applies even to number ranges (`5-10 minutes`, not `5–10 minutes`). Verbatim quotes from external sources are exempt.

When editing or reviewing Peter's content: do not flag Title Case headings or `**Term:**` bullet prefixes as AI tells. Do flag every em-dash and en-dash as a hard error, stricter than the general "overuse" framing below.

## Overused AI vocabulary

Words that spiked in frequency after 2023, corroborated by peer-reviewed studies. Scan for clusters of these:

> additionally, align with, crucial, delve, emphasizing, enduring, enhance, fostering, garner, highlight (verb), interplay, intricate/intricacies, key (adjective), landscape (abstract), multifaceted, nuanced, pivotal, realm, showcase, tapestry (abstract), testament, underscore (verb), valuable, vibrant

One or two in a full post is fine. A cluster of 3+ in a section means the LLM was on autopilot.

**Blog-specific note:** Tech blog posts are particularly susceptible to "leverage", "robust", "seamless", "cutting-edge", and "best-in-class". These are vendor cliches even without AI involvement, but LLMs reach for them reflexively.

## Inflated significance

LLMs inflate importance with a small repertoire of phrases. Scan for:

- "stands as a testament"
- "plays a vital/significant/crucial/pivotal role"
- "underscores its importance"
- "watershed moment" / "key turning point"
- "indelible mark"
- "setting the stage for"
- "evolving landscape"
- "deeply rooted"
- "enduring/lasting legacy"

**The fix:** Say what actually happened. Specific facts beat vague significance. In blog posts, concrete details and real experiences are always more compelling than inflated language.

## Superficial -ing analysis

LLMs tack present participle phrases onto sentences as fake depth:

- "...ensuring a seamless experience"
- "...highlighting its importance"
- "...emphasizing the need for"
- "...reflecting broader trends"
- "...contributing to the ecosystem"
- "...fostering a sense of community"

**The fix:** If the -ing clause adds no information the reader didn't already have, cut it. Blog posts should be concise - trailing participle phrases pad length without adding value.

## Promotional language

Words that read like a travel brochure or sales deck:

> breathtaking, stunning, nestled, in the heart of, boasts a, vibrant, rich (figurative), profound, groundbreaking (figurative), renowned, showcasing, exemplifies, commitment to, natural beauty, rich cultural tapestry/heritage

Good blog writing is enthusiastic but specific. "I cut the deploy time from 8 minutes to 45 seconds" beats "this groundbreaking approach delivers a profound improvement in deployment performance."

## Vague authority

LLMs attribute claims to phantom experts:

- "Industry reports suggest..."
- "Observers have cited..."
- "Experts argue..."
- "Some critics contend..."
- "Several publications have noted..."

**The fix:** Name the source or drop the attribution. Link to the actual documentation, blog post, or case study. Readers trust specificity over anonymous authority.

## Formulaic transitions

These transitions read like a five-paragraph essay:

> moreover, furthermore, in addition, on the other hand, in contrast, it's important to note, it is worth mentioning, no discussion would be complete without

Good blog writing uses direct transitions or none at all. A line break between topics is often better than a forced connector.

## Negative parallelism overuse

The "not X, it's Y" construction:

- "It's not just about X, it's about Y"
- "Not only... but also..."
- "It isn't X - it's Y"

**Nuance:** This pattern works sparingly for genuine emphasis. The tell is when every other paragraph uses it, or when it creates false profundity from obvious contrasts. One instance per post section is the maximum before it becomes a tic.

## Rule of three

LLMs default to grouping things in threes:

- "convenient, efficient, and innovative"
- "keynote sessions, panel discussions, and networking opportunities"

When every list has exactly three items, it's suspicious. Vary the count. Two items is fine. Four is fine. One is fine.

**Blog-specific note:** Lists in blog posts should contain exactly as many items as are relevant - no padding to hit three, no trimming to avoid four.

## Copula avoidance

LLMs replace "is" with fancier verbs:

- "serves as" instead of "is"
- "stands as" instead of "is"
- "represents" instead of "is"
- "marks" instead of "is"
- "boasts" instead of "has"
- "features" instead of "has"

Sometimes the fancy verb is right. Usually "is" is better. In blog writing, directness builds trust.

## Elegant variation

LLMs use increasingly elaborate synonyms to avoid repeating a word:

> the tool - the solution - the platform - the offering - the ecosystem

If you're talking about Hugo, just say Hugo again. If you're talking about Terraform, say Terraform. Readers don't mind repetition of concrete nouns. They notice when you cycle through thesaurus entries.

## Em dash overuse

**Personal override applies - see Personal Style Overrides at the top of this file.** Peter bans em-dashes and en-dashes entirely in his content.

LLMs use em dashes at 2-3x the rate of human writers. They substitute them for commas, parentheses, and colons in a formulaic, "punched up" style. In Peter's writing, replace every em-dash (—) and en-dash (–) with one of: a hyphen (-), parentheses, a comma, or a colon. Applies to number ranges too (`5-10 minutes`, not `5–10 minutes`). Verbatim quotes from external sources are exempt.

## Formatting tells

- **Excessive boldface**: bolding every key term mechanically, "key takeaways" style
- **Title case in every heading**: genuine AI tell in most contexts, but Peter's personal override (see top of file) keeps Title Case for all H1/H2/H3 headings and for bold prefixes in headline-style bullets. Do not flag these in his content.
- **Bullet + bold header + colon**: the "**Term:** Description of term" pattern in every list
- **Emoji decoration**: emoji before every section heading or bullet point

**Blog-specific note:** Blog posts should use formatting sparingly. A wall of bold text and bullet points can feel like a product datasheet rather than a personal post. Use formatting to aid scanning, not to decorate.

## Challenges-and-future formula

The rigid "Despite its success, X faces challenges... Despite these challenges, X continues to thrive" sandwich. If you catch yourself writing "despite" twice in a paragraph, restructure.

## How to use this checklist

1. Finish the draft first - don't self-censor while writing
2. Read through once scanning for vocabulary clusters
3. Read through again checking structural patterns (parallelism density, list uniformity, transition formality)
4. For each hit: Is this a deliberate rhetorical choice, or did the LLM default to it? If you can't articulate why the fancy version is better, use the plain one
5. When in doubt, read it aloud. If it sounds like a press release, rewrite it. If it sounds like something you'd actually say in a conversation, keep it
