+++
author = "Peter Souter"
categories = ["Tech"]
date = 2018-12-22T12:07:00Z
description = ""
draft = false
thumbnailImage = "/images/2018/12/misspell_750.png"
coverImage = "/images/2018/12/misspell.png"
slug = "fixing-common-spelling-errors-with-misspell"
tags = ["Tech", "Blog"]
title = "Fixing common spelling errors with misspell"
+++

# Fixing common spelling errors with misspell

I've been writing a lot of documentation recently, so I've been looking at ways of detecting spelling mistakes.

The main spelling tool you'll find is [Aspell](http://aspell.net/), and it works fine.

With a little bit of shell scripting, you can generally point it at some text and it'll find mispellings: `find ./content/source/ -maxdepth 5 -name "*.md" -exec aspell -x -c {} \;`

You'll see something like this:

![Aspell Behaviour](/images/2018/12/aspell-behaviour.png)

The problem with this is... you're going to have to spend a lot of time adding custom words to a dictionary with your avergage documentation repo. It's going to have code examples, acronyms and a lot of proper nouns. Aspell allows you to add the words to a custom dictionary that's kept at ` ~/.aspell.en.pws`

I started running it through the terraform-website repo and started adding words as I went, but it seemed to be an unending task:

```
$ cat ~/.aspell.en.pws
personal_ws-1.1 en 157
thumbnailImage
MPL
urls
uglyurls
javascript
SSL
uncomment
ACM
AWS
vDM
md
PrettyUrls
CDN
HashiCorp
Hacky
toml
systemd
hugo
MERCHANTABILITY
xyz
html
terraform
showPagination
sublicense
petersouter
showActions
showDate
showMeta
coverImage
```

This was taking a long time, and it was taking forever to add in all the excepts

What if instead of trying to correct everything that looks like a mispelt word, we only look for common mispellings of words?

## The alternative approach with `mispell`

This is the approach [misspell](https://github.com/client9/misspell) uses: it takes a list of common misspelling of words, then replaces them with the correct spelt word.

```
abandonned->abandoned
aberation->aberration
abilityes->abilities
abilties->abilities
abilty->ability
abondon->abandon
```
> https://en.wikipedia.org/wiki/Wikipedia:Lists_of_common_misspellings/For_machines

This a lot more efficient than having to add all the exceptions: there is a lot of existing data on mispellings, and we can even add in new ones we find in the future.

It's also a lot more performant as we're doing a simple substituation from a list, rather than having to do any sort of word comparison:

> Misspell is easily 100x to 1000x faster than other spelling correctors. You should be able to check and correct 1000 files in under 250ms.
> This uses the mighty power of golang's strings.Replacer which is a implementation or variation of the Aho–Corasick algorithm. This makes multiple substring matches simultaneously.
> In addition this uses multiple CPU cores to work on multiple files.
> https://github.com/client9/misspell#performance

And it's a lot better for documentation repos as we don't have a bunch of false positives for proper nouns, acronyms and technology terms.

I did a quick run against the terraform-website repo and it worked like a charm:

```
$ docker run \
   -v $(pwd):/scripts \
   --workdir=/scripts \
   nickg/misspell:latest \
   misspell -w -source=text content/
docker run \
>    -v $(pwd):/scripts \
>    --workdir=/scripts \
>    nickg/misspell:latest \
>    misspell -w -source=text content/
content/source/docs/enterprise/api/modules.html.md:74:89: corrected "Conection" to "Connection"
content/source/docs/enterprise/api/oauth-tokens.html.md:11:100: corrected "assocaited" to "associated"
content/source/docs/enterprise/api/workspaces.html.md:308:110: corrected "Conection" to "Connection"
content/source/docs/enterprise/getting-started/policies.html.md:9:65: corrected "sucessfully" to
```

So I added a quick target to the Makefile, replacing `$(pwd)` with Make's `$(CURDUR)`:

```
spellcheck:
  @echo "==> Spell checking website and running fixes..."
  @docker run \
   -v $(CURDIR):/scripts \
   --workdir=/scripts \
   nickg/misspell:latest \
   misspell -w -source=text content/
  @echo "==> Spell check complete"
```

But this threw up some errors with the simlinks in the repo from the submodules:

```
2018/12/22 11:06:48 Unable to stat "content/source/docs/backends": stat content/source/docs/backends: no such file or directory
2018/12/22 11:06:48 Unable to stat "content/source/docs/commands": stat content/source/docs/commands: no such file or directory
2018/12/22 11:06:48 Unable to stat "content/source/docs/configuration": stat content/source/docs/configuration: no such file or directory
```

So, with a bit of experimenting, a `find` and some `xargs`, I found a better solution.

`find . -type f` only returns files, not simlinks. So we can send this to the docker command with `xargs` and hey-presto: We have a working spellcheck!

```
spellcheck:
  @echo "==> Spell checking website and running fixes..."
  @find content/ -type f | xargs docker run \
   -v $(CURDIR):/scripts \
   --workdir=/scripts \
   nickg/misspell:latest \
   misspell -w -source=text
  @echo "==> Spell check complete"
```

Task complete, I [opened up a PR](https://github.com/hashicorp/terraform-website/pull/595) with the new make task and the spelling fixes. Job's a goodun!
