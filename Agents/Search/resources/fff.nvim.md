---
created: 2026-03-12
source: https://github.com/dmtrKovalenko/fff.nvim
type: resource
tags: [search, neovim, mcp, fuzzy-finder, file-search]
status: unread
---

## What it is

FFF (Freakin Fast Fuzzy file finder) is a file search tool for Neovim and AI agents (via MCP). It provides fuzzy file matching, grepping, globbing, and multigrepping with built-in memory that learns from usage patterns — frecency, git status, file size, and definition matches all factor into ranking.

## Why it's interesting

It's purpose-built for AI coding agents as well as humans. The MCP integration gives agents a file search tool with built-in memory, reducing token usage and roundtrips by surfacing better results on the first try. The frecency-based scoring means the more an agent works in a codebase, the better the search gets.

## How it works

FFF ships as a Rust binary (prebuilt or compiled from source) with both a Neovim plugin interface and an MCP server. For agents, you install via a one-liner bash script and point your agent config (CLAUDE.md, etc.) at the fff tools. The scoring engine combines multiple signals: **fuzzy matching** for typo-resistant queries, **frecency** tracking (frequency × recency of file access), **git status** awareness (modified files rank higher), **file size** penalties (smaller files preferred), and **definition matching** (files containing symbol definitions get boosted). For Neovim, it provides `find_files` and `live_grep` pickers with preview, multi-select to quickfix, and configurable grep modes (plain, regex, fuzzy).

## Key links

- [GitHub](https://github.com/dmtrKovalenko/fff.nvim)
- [Install script](https://dmtrkovalenko.dev/install-fff-mcp.sh)

## Notes

- Claims significant token/roundtrip savings for AI agents via the memory-augmented search — worth benchmarking against standard ripgrep MCP tools.
- Supports Claude Code, Codex, OpenCode out of the box.
