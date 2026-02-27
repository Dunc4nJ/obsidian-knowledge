---
created: 2026-02-27
source: https://github.com/openclaw/lobster
type: resource
tags: [openclaw, workflows, pipelines, automation]
status: unread
---

## What it is

Lobster is an OpenClaw-native workflow shell — a typed, JSON-first pipeline engine with jobs, approval gates, and composable macros. It lets you define multi-step workflows as YAML/JSON files with conditions and approval gates, then invoke them in a single step. Pipelines pass structured objects (not text), with built-in data shaping commands like `where`, `pick`, `head`, and renderers like `json` and `table`.

## Why it's interesting

It solves the re-planning problem: instead of an agent spending tokens figuring out each step every time, you codify the workflow once and Lobster executes it deterministically with resumability. No new auth surface (it doesn't own tokens), local-first execution, and the approval gate integrates with OpenClaw's TTY or emits events for agent-driven approval. Ships as an optional OpenClaw plugin.

## Key links

- [GitHub](https://github.com/openclaw/lobster)
- [OpenClaw integration PR](https://github.com/openclaw/openclaw/pull/1152)

## Notes

- Built-in workflow: `github.pr.monitor` for tracking PR state changes
- Workflow files use `.lobster` extension with YAML syntax
- Pipeline commands: `exec`, `where`, `pick`, `head`, `json`, `table`, `approve`
- `exec --stdin raw|json|jsonl` feeds pipeline input into subprocesses
