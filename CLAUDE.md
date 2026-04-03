# CLAUDE.md

See [AGENTS.md](AGENTS.md) for all project instructions, commands, architecture, and content conventions.

This file adds Claude Code-specific notes only.

## Claude Code Notes

- The site uses `hugo.yaml` for all configuration
- Use `hugo server` to preview changes locally (http://localhost:1313)
- Use `hugo server --buildDrafts` to include draft content
- Posts with UTC timezone dates (Z suffix) can appear as "future" during BST — use explicit offset or date-only format
- Prefix Terraform commands with `OTEL_TRACES_EXPORTER=` to avoid conflicts with Claude Code's environment variables
