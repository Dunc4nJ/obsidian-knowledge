---
created: 2026-03-08
source: https://github.com/lightonai/next-plaid/tree/main/colgrep
type: resource
tags: [search, semantic-search, code-search, colbert, rust, cli]
status: unread
---

## What it is

ColGREP is a semantic code search tool for the terminal, built on LightOn's NextPlaid engine. It combines regex filtering with semantic ranking using LateOn-Code-edge multi-vector (ColBERT-style) embeddings — a single Rust binary, no server, no API, 100% local.

## Why it's interesting

Bridges the gap between dumb grep and full-blown code intelligence servers. The hybrid search mode (regex narrows candidates, semantics ranks them) is a practical sweet spot for coding agents that need to find relevant code by meaning without spinning up an LSP. Ships with agent integrations for Claude Code, Codex, and OpenCode out of the box.

## How it works

**Parsing** — Tree-sitter parses source files into structured code units (functions, methods, classes) with signature, params, calls, docstring, and code body extracted separately.

**Embedding** — Each code unit is embedded using LateOn-Code-edge (17M param ColBERT model) into multi-vector representations. Runs on CPU; macOS gets Apple Accelerate + CoreML acceleration. Supports INT8 quantization and configurable pool-factor for index size vs accuracy tradeoff.

**Indexing** — NextPlaid (Rust engine) stores the multi-vector index locally. `colgrep init` builds it; subsequent searches auto-detect file changes and incrementally update before returning results.

**Search** — Three modes: pure semantic (natural language queries), pure regex (ERE syntax, grep-compatible flags), and hybrid (regex pre-filter → semantic re-ranking). Supports glob-based file filtering, code-only mode, JSON output for scripting, and full-content display.

**Agent integration** — Install hooks inject colgrep instructions into agent system prompts and propagate to sub-agents via task hooks. Health checks skip activation if the index is stale or too large to rebuild inline.

## Key links

- [GitHub](https://github.com/lightonai/next-plaid/tree/main/colgrep)
- [NextPlaid (parent project)](https://github.com/lightonai/next-plaid)

## Notes

- Could be worth installing on the VPS for coding agent workflows — the Claude Code integration hook is particularly interesting since it auto-injects into system prompts.
- Model is only 17M params so CPU inference should be fast even on the VPS.
- Competes with [[resources/sem|sem]] in the local semantic code search space but takes a different approach (ColBERT multi-vector vs single-vector embeddings).
- See [[ColBERT-style semantic search beats grep 70 percent of the time for coding agents while using fewer tokens]] for the full announcement thread with benchmarks and context.
