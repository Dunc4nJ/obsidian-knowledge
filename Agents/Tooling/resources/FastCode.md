---
created: 2026-02-27
source: https://github.com/HKUDS/FastCode
type: resource
tags: [code-understanding, token-efficiency, mcp, graph-navigation]
status: unread
---

## What it is

FastCode is a token-efficient framework for code understanding and analysis from HKU Data Science. It builds a structural representation of codebases using AST parsing, hybrid search (semantic embeddings + BM25), and three interconnected graphs (call, dependency, inheritance), then navigates them surgically — reading function signatures and type hints instead of full files, traversing code connections up to 2 hops, and using budget-aware stopping to minimize token spend.

## Why it's interesting

The core trick is avoiding the brute-force "dump files into context" approach that Cursor and Claude Code use. By building a structural index first and then skimming code at the signature level, it claims 3-4x faster, 44-55% cheaper, and higher accuracy than both. Ships as an MCP server so existing coding agents can use it directly. Supports 8+ languages and local models (Qwen3 Coder 30B). Benchmarked on SWE-QA, LongCodeQA, LOC-BENCH, and GitTaskBench.

## Key links

- [GitHub](https://github.com/HKUDS/FastCode)
- [Demo Video](https://youtu.be/NwexLWHPBOY)

## How it works

**Phase 1 — Semantic-Structural Code Representation:** Parses codebases using AST across 8+ languages into hierarchical code units (files → classes → functions → docs). Builds a hybrid index combining semantic embeddings + BM25 keyword search. Constructs three interconnected graphs: Call Graph, Dependency Graph, Inheritance Graph.

**Phase 2 — Lightning-Fast Navigation:** Two-stage search (find candidates, then rank/filter). Code skimming reads function signatures, class definitions, and type hints instead of full files — like reading chapter titles instead of every page. Graph traversal follows code connections up to 2 hops to trace dependencies.

**Phase 3 — Cost-Efficient Context Management:** Budget-aware decision making weighs confidence level, query complexity, codebase size, resource cost, and iteration count before deciding what to fetch. Adaptive stopping reassesses whether it has enough context. Value-first selection prioritizes high-impact, low-cost information.

## Notes

- MCP server integration for Cursor, Claude Code, Windsurf
- Web UI + CLI + API
- Could be useful for our own coding agent workflows — the graph-based navigation approach is worth exploring
