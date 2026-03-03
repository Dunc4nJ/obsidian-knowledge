---
created: 2026-03-01
source: https://github.com/peteromallet/desloppify
type: resource
tags: [code-quality, agent-harness, tree-sitter, static-analysis, linting, refactoring]
status: unread
description: Agent harness that combines mechanical detection and LLM-powered subjective review to systematically improve codebase quality with anti-gaming scoring.
---

## What it is

Desloppify is a Python agent harness that combines mechanical code detection (dead code, duplication, complexity) with subjective LLM review (naming, abstractions, module boundaries) to systematically improve codebase quality. It assigns a composite score designed to resist gaming, persists state across sessions so it can chip away incrementally, and supports 28 languages via tree-sitter.

## Why it's interesting

Most linting tools produce scores you can game to 100 by suppressing warnings. Desloppify's anti-gaming design means the only way to improve the score is to actually improve the code. It also bridges the gap between mechanical checks (which miss structural rot) and full LLM review (which lacks persistence). The agent workflow loop — scan, next, fix, resolve, repeat — gives coding agents a structured quality improvement protocol rather than open-ended "make this better" prompts. A score above 98 should correlate with code a senior engineer would respect.

## How it works

**Scan phase:** Runs all detectors across the codebase — both mechanical (dead imports, duplication, cyclomatic complexity) and subjective (LLM evaluates naming, abstractions, module boundaries, error handling consistency). Results persist to state so subsequent sessions pick up where the last left off. **Prioritization:** Issues are ranked and clustered. `plan` lets you reorder priorities or group related fixes. **Fix loop:** `next` tells the agent exactly what to fix, which file, and the resolve command to run when done. The agent fixes, resolves, and loops until the target score is reached. **Scoring:** Composite score with anti-gaming measures — suppressing warnings or cosmetic changes don't move the needle.

## Key links

- [GitHub](https://github.com/peteromallet/desloppify)
- [PyPI](https://pypi.org/project/desloppify/)
- [Discord community](https://discord.gg/aZdzbZrHaY)

## Notes

- Shares the tree-sitter foundation with [[TLDR]] and [[Context+]], but focuses on quality improvement rather than code search/navigation.
- Installs agent-specific workflow guides: `desloppify update-skill claude|cursor|codex|copilot|windsurf|gemini`.
- Full plugin depth for TypeScript, Python, C#, Dart, GDScript, Go; generic linter + tree-sitter for 22 more languages.
