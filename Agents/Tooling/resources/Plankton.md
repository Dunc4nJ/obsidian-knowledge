---
created: 2026-03-01
source: https://github.com/alexfazio/plankton
type: resource
tags: [claude-code, hooks, linting, code-quality, write-time-enforcement]
status: unread
---

## What it is

Write-time code quality enforcement system for Claude Code, built on CC hooks. Every file edit triggers automated formatting and linting through fast Rust-based linters, then delegates remaining violations to dedicated Claude subprocesses that reason about each fix. You clone the repo, cd into it, run `claude`, and the hooks activate automatically.

## Why it's interesting

Shifts code quality enforcement from post-hoc (pre-commit, CI) to write-time — the agent is blocked from proceeding until its output passes checks. The author claims this creates a behavioral shift where the model learns from write-time feedback and produces better code during generation. Uses a three-phase pipeline (auto-format → structured linting → Claude subprocess fixes) with tamper-proof config protection so the agent can't weaken the rules.

## How it works

**Phase 1 — Auto-format**: Fast formatters (ruff, shfmt, biome, taplo, markdownlint) silently fix style issues before they're even reported.

**Phase 2 — Lint collection**: 20+ linters (ty for types, vulture for dead code, bandit/Semgrep for security, ShellCheck, hadolint, yamllint, jscpd for duplication, etc.) collect remaining violations as structured JSON.

**Phase 3 — Claude subprocess fixes**: Dedicated Claude instances reason about each remaining violation and fix it. Model routing right-sizes intelligence to problem complexity so tokens aren't wasted on easy fixes.

**Tamper protection**: A PreToolUse hook blocks linter config edits before they happen, preventing the agent from weakening enforcement.

Requires jaq, ruff, and uv for all languages; biome additionally for TypeScript. Currently supports Python and TypeScript, with Swift and Go planned.

## Key links

- [GitHub](https://github.com/alexfazio/plankton)
- [Reference docs](https://github.com/alexfazio/plankton/blob/main/docs/REFERENCE.md)
- [Original writeup (X thread)](https://x.com/alxfazio/status/2024931367612743688)

## Notes

- Research project, depends on undocumented Claude Code internals — can break on CC updates.
- MIT licensed.
- Interesting parallel to our DCG (Destructive Command Guard) — both use hooks to constrain agent behavior, but Plankton focuses on code quality while DCG focuses on safety.
