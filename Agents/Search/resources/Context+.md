---
created: 2026-02-28
source: https://github.com/ForLoopCodes/contextplus
type: resource
tags: [code-search, mcp, tree-sitter, spectral-clustering, semantic-search, ast]
status: unread
---

## What it is

Context+ is an MCP server that turns large codebases into searchable, hierarchical feature graphs. It combines tree-sitter AST parsing (43 language extensions), Ollama-powered semantic embeddings with disk caching, and spectral clustering to group semantically related files. Also features Obsidian-style wikilink "feature hubs" — `.md` files with `[[wikilinks]]` that map features to code files. Runs via `npx`/`bunx` with zero install, supports Claude Code, Cursor, VS Code, and Windsurf.

## Why it's interesting

Three things stand out: (1) spectral clustering for grouping related files by meaning rather than directory structure — most code search tools stop at embeddings, this adds a graph-theoretic layer; (2) the Obsidian-style feature hub concept bridges human-readable documentation and code navigation in a way agents can traverse; (3) the "blast radius" tool traces every file and line where a symbol is imported/used, which is useful for safe refactoring. Also has a shadow restore point system — every AI-written change creates a checkpoint you can undo without touching git.

## How it works

**Three-layer architecture in TypeScript over stdio using the MCP SDK:**

**Core layer** — Multi-language AST parsing via tree-sitter (43 extensions), gitignore-aware file traversal, Ollama vector embeddings (nomic-embed-text by default) cached to disk, and a wikilink hub graph for feature navigation.

**Tools layer** — 10 MCP tools split across discovery (`get_context_tree` for structural AST with token-aware pruning, `get_file_skeleton` for API surface, `semantic_code_search` for meaning-based search, `semantic_navigate` for spectral clustering), analysis (`get_blast_radius` for symbol usage tracing, `run_static_analysis` for native linters), code ops (`propose_commit` with shadow restore points, `get_feature_hub` for wikilink navigation), and version control (`list_restore_points`, `undo_change`).

**Git layer** — Shadow restore point system that captures file state before any AI change. Undo rolls back to pre-change state without touching actual git history.

**Embedding pipeline:** File headers and symbol names are embedded via Ollama (configurable model, default nomic-embed-text), stored in a disk cache. Semantic search queries against these embeddings. Spectral clustering uses the embedding similarity matrix to group files into labeled clusters (cluster labeling via a chat model, default gemma2:27b).

## Key links

- [GitHub](https://github.com/ForLoopCodes/contextplus)
- [npm](https://www.npmjs.com/package/contextplus)

## Notes

- Requires Ollama for embeddings — heavier dependency than pure grep tools but enables semantic search.
- Interesting comparison with [[resources/TLDR|TLDR]] which also uses tree-sitter + embeddings but builds 5 analysis layers (call graph, data flow, program dependence). Context+ goes wider (spectral clustering, feature hubs, blast radius) while TLDR goes deeper (data flow, program slicing).
- The feature hub concept (`.md` files with wikilinks mapping features to code) connects to [[Obsidian wikilink resolution can be replicated on plain filesystems with an index and atomic rename tool]] — same linking pattern applied to code navigation.
- `propose_commit` as the only write path is a nice safety pattern — all code changes go through validation + shadow checkpoint.
