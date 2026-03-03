---
created: 2026-03-02
description: "Cognee — open-source knowledge engine that builds persistent, dynamic AI memory using knowledge graphs + vector search"
source: https://github.com/topoteretes/cognee
docs: https://docs.cognee.ai
type: tool
tags:
  - ai-memory
  - knowledge-graph
  - vector-search
  - rag
---

# Cognee — Knowledge Engine for AI Agent Memory

Cognee is an open-source knowledge engine that transforms raw data into **persistent, dynamic AI memory** for agents. It goes beyond plain vector search by combining **semantic embeddings** with **knowledge graphs**, so your data is both searchable by meaning and connected by relationships.

## Key Takeaways

- **Beyond vector search**: Plain RAG retrieves semantically similar chunks but loses structural relationships between concepts. Cognee adds a knowledge graph layer — entities, relationships, and ontologies — on top of vector embeddings, enabling both similarity search *and* graph traversal/reasoning.
- **The pipeline**: `add → cognify → memify → search`
  - **Add** — Ingest data from 30+ sources (text, files, images, audio transcriptions, past conversations)
  - **Cognify** — Extract entities & relationships, build a knowledge graph
  - **Memify** — Optional semantic enrichment / memory algorithms on the graph
  - **Search** — Query via semantic similarity, graph traversal, or hybrid
- **Modular building blocks**: DataPoints (structured data units → graph nodes), Tasks (processing units), and Pipelines (orchestrated workflows). Users can define custom tasks and pipelines for domain-specific logic.
- **Self-improving**: The graph evolves as new data is added; relationships update and enrich over time.

### Comparison with related approaches

| Approach | Storage | Relationships | Notes |
|---|---|---|---|
| **Cognee** | Vector DB + Graph DB + Relational DB | Explicit KG edges + semantic similarity | Full pipeline, 30+ data sources, modular |
| [[mem0 knowledge graph\|mem0]] | Vector + Knowledge Graph | KG edges + vector similarity | Simpler API, focused on conversation memory |
| [[Obsidian as Agentic Memory]] | Markdown files + wikilinks | Implicit graph via `[[wikilinks]]` | File-based, human-readable, no embeddings |
| Plain RAG | Vector DB only | None (chunk-level only) | Fast but loses structural context |

Cognee is the most infrastructure-heavy of these but also the most capable for production agent memory where you need graph reasoning, ontology grounding, and multi-source ingestion.

## Architecture

### Three storage systems

1. **Relational store** (SQLite / Postgres) — Tracks documents, chunks, provenance
2. **Vector store** — Embeddings for semantic similarity search
   - Supported: LanceDB, PGVector, Qdrant, Redis, ChromaDB, FalkorDB, Neptune Analytics
3. **Graph store** — Entities & relationships as a knowledge graph
   - Supported: Kuzu, Kuzu-remote, Neo4j, Neptune, Neptune Analytics, Memgraph

### LLM & Embedding providers

- **LLMs**: OpenAI, Azure OpenAI, Google Gemini, Anthropic, Ollama, custom (vLLM)
- **Embeddings**: OpenAI, Azure OpenAI, Gemini, Mistral, Ollama, Fastembed, custom
- **Structured output**: LiteLLM + Instructor or BAML

### Pipeline stages

```
Raw Data → [Add] → Chunked Documents
         → [Cognify] → Knowledge Graph (entities + relationships)
         → [Memify] → Enriched Memory Graph
         → [Search] → Results (semantic / graph / hybrid)
```

Ships with lightweight local defaults (SQLite, LanceDB, Kuzu) and can scale to production backends.

## Quick Start

```python
import cognee
import asyncio

async def main():
    await cognee.add("Cognee turns documents into AI memory.")
    await cognee.cognify()
    await cognee.memify()
    results = await cognee.search("What does Cognee do?")
    for r in results:
        print(r)

asyncio.run(main())
```

Install: `pip install cognee` — requires Python 3.10–3.13 and an LLM API key.

CLI alternative:
```bash
cognee-cli add "text"
cognee-cli cognify
cognee-cli search "query"
```

## Further reading

- [Docs](https://docs.cognee.ai)
- [Core concepts](https://docs.cognee.ai/core-concepts/overview)
- [GitHub](https://github.com/topoteretes/cognee)
- [Colab walkthrough](https://colab.research.google.com/drive/12Vi9zID-M3fpKpKiaqDBvkk98ElkRPWy)
- Research paper: "Optimizing the Interface Between Knowledge Graphs and LLMs for Complex Reasoning" (arXiv:2505.24478)

## Related

- [[Obsidian as Agentic Memory]]
- [[mem0 knowledge graph]]
