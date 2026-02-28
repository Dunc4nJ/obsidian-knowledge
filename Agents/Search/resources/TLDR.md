---
created: 2026-02-28
source: https://github.com/parcadei/llm-tldr
type: resource
tags: [code-search, context-window, static-analysis, semantic-search, tree-sitter]
status: unread
---

## What it is

TLDR is a Python CLI that builds a 5-layer static analysis index of a codebase (AST, call graph, control flow, data flow, program dependence) and combines it with semantic embeddings (bge-large-en-v1.5 via FAISS) so LLMs can query exactly the code they need. Claims 95% token savings and 155x faster queries versus dumping raw source. Supports 16 languages via tree-sitter.

## Why it's interesting

Most codebase context tools stop at grep or AST-level structure. TLDR goes deeper — layers 3-5 (control flow, data flow, program dependence) let an LLM answer "what affects line 42?" or "where does this value flow?" without reading the entire file. The daemon keeps indexes in memory for ~100ms queries, which makes it practical as a live coding companion rather than a batch tool.

## How it works

**Layer 1 (AST):** tree-sitter parses source files into syntax trees — extracts functions, classes, signatures. **Layer 2 (Call Graph):** resolves who calls what across the project. **Layer 3 (Control Flow):** builds CFGs, computes complexity metrics. **Layer 4 (Data Flow):** tracks where values originate and propagate. **Layer 5 (Program Dependence):** computes slices — "only the lines relevant to this variable."

**Semantic Index:** Each function's multi-layer metadata (signature, callers, callees, complexity, dependencies, first ~10 lines of code) gets encoded into 1024-dim vectors with bge-large-en-v1.5 and stored in a FAISS index. This lets you search by behavior ("validate JWT") rather than exact text.

**Daemon:** Keeps indexes in memory, auto-rebuilds after 20 file changes. Integrates via git hooks or editor save hooks for freshness.

## Key links

- [GitHub](https://github.com/parcadei/llm-tldr)
- [PyPI](https://pypi.org/project/llm-tldr/)

## Notes

- Requires embedding model dependencies (sentence-transformers, faiss-cpu) — heavier install than pure grep tools.
- Would be interesting to compare against [[resources/CASS|CASS]] for session search vs. TLDR for codebase structure — complementary tools.
- The 5-layer approach could pair well with [[semantic-search]] techniques already in the vault.
