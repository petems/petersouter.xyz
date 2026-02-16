+++
author = "Peter Souter"
categories = ["Tech"]
date = 2016-11-27T21:44:00Z
description = ""
draft = false
coverImage = "/images/2016/11/sublime-text-editor-with-tugboat-code.png"
slug = "sublime-plugins"
tags = ["vDM30in30", "Open-Source"]
title = "Sublime Plugins"

+++

#### Day 27 in the #vDM30in30

I started off as a Java developer, so I was used to Eclipse and Intelij, quite heavy IDE's with lots of assistance.

After moving away from Java and into Ruby, I noticed one of the other developers was using TextMate, and it seemed much nimbler and easier to get things done.

However, there were a few annoying things that about Textmate at the time (circa 2012~), such as Textmate crashing when you looked at large files. At the time we had a few larger JSON fixtures (not massive, 50-100kb or so) we were using for testing. A bit of a pain.

So, eventually, I ended up moving to Sublime Text, which seemed like a better, faster Textmate.

I've split my time since then between Sublime and Vim, but I normally end up going back to Sublime.

Over my years of using it, I've ended up with some settings and plugins that I've stuck with.

## Preferences

```JSON
{
	"color_scheme": "Packages/User/SublimeLinter/brogrammer (SL).tmTheme",
	"ensure_newline_at_eof_on_save": true,
	"font_options":
	[
		"gray_antialias"
	],
	"font_size": 13,
	"ignored_packages":
	[
		"SublimeLinter-shellcheck",
		"Vintage"
	],
	"tab_size": 2,
	"translate_tabs_to_spaces": true,
	"trim_trailing_white_space_on_save": true
}
```

Nothing super interesting here.

The main interesting parts:

### `ensure_newline_at_eof_on_save`

Makes sure that files have a proper EOF

https://robots.thoughtbot.com/no-newline-at-end-of-file

### `translate_tabs_to_spaces`

space > tabs! FIGHT ME!

### `trim_trailing_white_space_on_save`

Trailing whitespace in files is a pain...

http://www.dinduks.com/why-are-trailing-whitespaces-bad/

## Keybindings

Nothing super interesting, but you can see my habit from Intelij coming in: `CMD + ALT + [` to indent is a habit from then.

The other is just an easy way to close multiple tabs at once.

```python
[
  { "keys": ["super+alt+["], "command": "reindent" },
  {"keys": ["super+alt+]"], "command": "close_all"}
]
```

## Plugins

### DashDoc

I already mentioned this in my Dash blog post, basically ou can press `Ctrl+H` in a file with Sublime, and it will do a context search using the type of code in the file plus a search for that entry.

[](/images/2016/11/dash_sublime-1.gif)

https://github.com/farcaller/DashDoc

### GitGutter

>A sublime text 2/3 plugin to show an icon in the gutter area indicating whether a line has been inserted, modified or deleted.

Really useful for a quick visual indicator what's new Git-wise.

This is actually built into most new editors these days, such as Atom and Visual Studio Code.

![](/images/2016/11/sublime_gitgutter.gif)

https://github.com/jisaacks/GitGutter

### GitCommitMsg

> Shows the git commit history for one or more lines of code. Essentially it performs a git blame on the selected line(s) of code, and then performs a git show on the resulting commit(s).

![](/images/2016/11/sublime_commit_msg-1.gif)

### JSONLint

JSON-linting with sublime, highlighting invalid JSON.

Really useful for catching those trailing commas or forgotten quotes.

![](/images/2016/11/sublime_json_lint.gif)

https://bitbucket.org/hmml/jsonlint

### SideBarEnhancements

> Provides enhancements to the operations on Sidebar of Files and Folders for Sublime Text

Adds a bunch of much-needed options to the sidebar, expands search options and adds features like the ability to "Open With.." with a specified list of applications

![](/images/2016/11/dash-docsets-downloads-tab.png)

https://github.com/SideBarEnhancements-org/SideBarEnhancements/

### yardgen

Automatically generates yardoc for Ruby

![](/images/2016/11/sublime_yardgen.gif)

You just click over your method, press `Ctrl+Enter` and it'll automatically generate documentation for your Ruby code.

https://bitbucket.org/fappelman/yardgen/
