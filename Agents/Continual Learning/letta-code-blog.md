---
created: 2026-02-21
description: Letta Code is a coding agent built around persistent, long-lived agents with memory-first architecture rather than independent sessions — the top model-agnostic OSS harness on TerminalBench.
source: https://www.letta.com/blog/letta-code
type: reference
---

# Letta Code: A Memory-First Coding Agent

**Source:** https://www.letta.com/blog/letta-code
**Published:** December 16, 2025

## Overview

Letta Code is a coding agent built around persistent, long-lived agents rather than independent sessions. It's described as "the #1 model-agnostic OSS harness on TerminalBench."

---

## Core Features

### Memory & Continual Learning
- **`/init` command** -- triggers deep codebase research, forming memories and rewriting the system prompt via memory blocks
- **`/remember` command** -- manually triggers agent reflection and learning
- Agents accumulate context over time, improving with each session

### Skill Learning
Agents can learn reusable skills from past experiences (stored as `.md` files), such as:
- DB migration generation
- PostHog dashboard creation
- API best-practice documentation

Skills are git-manageable and portable across compatible agents.

### Persisted State & Search
The built-in `/search` command enables hybrid vector/full-text search across past messages and conversations via the Letta API.

---

## Benchmark Performance

Letta Code achieves comparable results to provider-specific harnesses (Claude Code, Gemini CLI, Codex CLI) on their respective models, while being fully model-agnostic.

---

## Installation

```bash
npm install -g @letta-ai/letta-code
```

Full docs: [docs.letta.com/letta-code](https://docs.letta.com/letta-code)
