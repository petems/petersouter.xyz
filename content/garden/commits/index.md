---
title: "Commits"
date: 2026-03-20T00:00:00Z
description: "My opinions on writing good git commit messages."
garden_topic: "Git"
status: "Seedling"
---

I'm a [Conventional Commits](https://www.conventionalcommits.org/) person. The format is simple: `<type>(<scope>): <description>`, and the types (`feat`, `fix`, `docs`, `chore`, etc.) give you a scannable git log without any extra tooling.

## The non-negotiables

These aren't my rules, they're git's rules. I just happen to agree with all of them:

* **50 characters max for the title.** GitHub truncates anything longer, and `git log --oneline` looks terrible when titles wrap. This one comes from [tpope's classic 2008 post](https://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html) and it's stuck around because it works.
* **Imperative mood.** "Add feature", not "Added feature". Git itself does this ("Merge branch...", "Revert..."), so your commits should match. This is part of the [Conventional Commits spec](https://www.conventionalcommits.org/en/v1.0.0/#summary) and matches [git's own conventions](https://git-scm.com/book/en/v2/Distributed-Git-Contributing-to-a-Project#_commit_guidelines).
* **No trailing period on the title.** It's a title, not a sentence.
* **Blank line between title and body.** Skip this and tools will get confused. Just do it.
* **Body lines wrap at 72 characters.** Again, `git log` and `git format-patch` assume this width. Fight the urge to let lines run long.
* **Use `Closes #123` or `Fixes #123` for issue refs.** GitHub will auto-close the issue when the commit lands. Free automation.

## My personal quirks

On top of the standard stuff, I have some preferences that are just... mine:

* **Bullets use `*` not `-`.** No real reason. I just like how it looks.
* **I lean toward always including a scope.** The spec says it's optional, but `fix(auth):` tells you so much more than just `fix:` at a glance.
* **Body bullets explain "why", not "what".** The diff already shows what changed. Tell me *why* you changed it.
* **Stage files by name, never `git add .` or `git add -A`.** I've been burned by accidentally committing `.env` files and fat binaries. Naming each file forces you to think about what you're actually committing.
* **AI-assisted commits get a `Co-Authored-By` footer.** If Claude helped write the code, the commit says so. Transparency is good.

## The template

```
feat(scope): imperative description under 50 chars

* Why thing one was changed
* Why thing two was changed

Closes #N

Co-Authored-By: Claude <noreply@anthropic.com>
```

Nothing fancy. Just enough structure to keep things readable six months from now when you're doing `git blame` at 2am trying to figure out why something broke.
