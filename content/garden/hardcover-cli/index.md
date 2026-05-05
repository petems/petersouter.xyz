---
title: "Hardcover CLI"
date: 2026-03-20T00:00:00Z
description: "A Go CLI for the Hardcover.app API."
garden_topic: "Sideprojects"
status: "Seedling"
---

[Hardcover CLI](https://github.com/petems/hardcover-cli) is a Go command-line interface for interacting with the [Hardcover.app](https://hardcover.app) GraphQL API. Hardcover is a book tracking platform (think Goodreads but modern), and this CLI lets you search for books, look up users, and manage your profile from the terminal.

It uses a custom type generation approach to work around GraphQL introspection schema issues while keeping things type-safe at compile time. Currently read-only — you can search and browse but not update your shelves yet.
