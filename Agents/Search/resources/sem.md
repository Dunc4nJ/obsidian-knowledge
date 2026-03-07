---
created: 2026-03-07
source: https://github.com/Ataraxy-Labs/sem
description: Semantic version control CLI — entity-level diff, blame, graph, and impact analysis on top of Git. 16 languages via tree-sitter.
type: resource
tags: [code-search, semantic-diff, tree-sitter, git, impact-analysis, blame, rust]
status: unread
---

# sem — Semantic Version Control

CLI that replaces line-level diffs with **entity-level diffs** on top of Git. Instead of "line 43 changed", sem tells you "function validateToken was added in src/auth.ts".

## Key Commands

- `sem diff` — semantic diff (working, staged, commit, range)
- `sem blame <file>` — entity-level blame
- `sem graph` — entity dependency graph
- `sem impact <entity>` — what breaks if this entity changes?
- `sem diff --format json` — JSON output for AI agents / CI

## Language Support

16 languages via tree-sitter: TypeScript, JavaScript, Python, Go, Rust, Java, C, C++, C#, and more. Extracts functions, classes, interfaces, structs, enums, traits, etc.

## Install

```bash
# From source (Rust)
git clone https://github.com/Ataraxy-Labs/sem
cd sem/crates
cargo install --path sem-cli

# Or grab a binary from GitHub Releases
```

## Why It's Interesting

- Entity-aware diffs are far more useful for code review and AI agent context
- Impact analysis answers "what breaks if I change X?" — useful for blast radius in agentic workflows
- JSON output mode makes it composable with other tools
- No setup required — works in any Git repo
