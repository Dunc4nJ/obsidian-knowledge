---
created: 2026-02-25
type: project-doc
description: "Index of Morph's two code search approaches: WarpGrep (agentic ripgrep subagent, no indexing) and Semantic Search (embedding + reranking RAG pipeline)."
---
# Semantic Code Search — Morph Documentation

Two approaches to AI-powered code search, both available via the Morph MCP server.

## When to Use What

| Scenario | Tool | Why |
|----------|------|-----|
| "How is graph analysis implemented?" | `warp_grep` | Exploratory; don't know where to start |
| "Where is PageRank computed?" | `warp_grep` | Need to understand architecture |
| "Find JWT validation code" | `semantic_search` | Precise retrieval from indexed codebase |
| "Show database error handling" | `semantic_search` | Natural language → exact code matches |
| Quick search, any repo, no setup | `warp_grep` | No indexing required — works instantly |
| Repeated searches on same codebase | `semantic_search` | Indexed once, fast retrieval after |

## Approach 1: Warp Grep (Subagent)

**How it works:** An AI subagent runs ripgrep in a separate context window. No embeddings, no indexing — just intelligent grep + read + list_dir across up to 24 tool calls (8 parallel × 4 turns) in under 6 seconds.

**MCP tool name:** `warpgrep_codebase_search`

```
mcp__morph-mcp__warp_grep(
  repoPath: "/path/to/repo",
  query: "How does the correlation package detect orphan commits?"
)
```

**Docs:**
- [warp-grep/README.md](warp-grep/README.md) — Architecture, 3 internal tools, performance
- [warp-grep/sdk-tool.md](warp-grep/sdk-tool.md) — Anthropic/OpenAI/Gemini/Vercel adapters, remoteCommands, config
- [warp-grep/streaming.md](warp-grep/streaming.md) — `streamSteps` flag, AsyncGenerator, step events
- [warp-grep/custom-providers.md](warp-grep/custom-providers.md) — WarpGrepProvider interface for custom file systems

## Approach 2: Semantic Search (RAG Pipeline)

**How it works:** Push code → embed (morph-embedding-v3, 1024-dim) → HNSW index → vector search (~240ms, top 50) → GPU rerank (morph-rerank-v3, ~630ms, top 10). Total ~1230ms.

**Pipeline:**
```
morph.git.push()  →  Embedding (3-8s background)  →  HNSW Index
                                                        ↓
Query  →  Vector Search (~240ms, top 50)  →  GPU Rerank (~630ms)  →  Top 10 results
```

**Docs:**
- [semantic-search/README.md](semantic-search/README.md) — Two-stage retrieval, query params, response format, SDK examples
- [semantic-search/git-push.md](semantic-search/git-push.md) — `morph.git.push()` prerequisite, triggers embedding pipeline
- [semantic-search/embeddings.md](semantic-search/embeddings.md) — morph-embedding-v3, 1024-dim vectors, OpenAI-compatible API
- [semantic-search/reranking.md](semantic-search/reranking.md) — morph-rerank-v3, Cohere-compatible, relevance scoring 0-1

## MCP Server Setup

**Docs:** [mcp-setup.md](mcp-setup.md) — Full setup for Claude Code, Codex, Cursor, Claude Desktop

**Quick install (Claude Code):**
```bash
claude mcp add morph --scope user -e MORPH_API_KEY=YOUR_API_KEY -- npx -y @morphllm/morphmcp
```

**Environment variables:**
| Variable | Default | Purpose |
|----------|---------|---------|
| `MORPH_API_KEY` | Required | Auth token |
| `ENABLED_TOOLS` | `"edit_file,warpgrep_codebase_search"` | Tools to enable |
| `WORKSPACE_MODE` | `"true"` | Auto workspace detection |
| `MORPH_WARP_GREP_TIMEOUT` | `30000` | Search timeout (ms) |

**Exposed tools:** `edit_file`, `warpgrep_codebase_search`

## Source URLs

- https://docs.morphllm.com/sdk/components/warp-grep
- https://docs.morphllm.com/sdk/components/warp-grep/tool
- https://docs.morphllm.com/sdk/components/warp-grep/streaming
- https://docs.morphllm.com/sdk/components/warp-grep/custom-providers
- https://docs.morphllm.com/sdk/components/repos/semantic-search
- https://docs.morphllm.com/sdk/components/repos/git
- https://docs.morphllm.com/models/embedding
- https://docs.morphllm.com/models/rerank
- https://docs.morphllm.com/mcpquickstart
