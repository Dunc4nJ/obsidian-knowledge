---
created: 2026-03-02
source: https://github.com/vectorize-io/hindsight
description: Biomimetic long-term memory system for AI agents that learns from past interactions
type: resource
tags: [agent-memory, learning, biomimetic, long-term-memory]
status: unread
---

## What it is

Hindsight is an agent memory system by Vectorize that focuses on making agents *learn* rather than just recall conversation history. It uses biomimetic data structures (world facts, experiences, and mental models) instead of plain vector search or knowledge graphs, and claims state-of-the-art performance on the LongMemEval benchmark — independently reproduced by Virginia Tech and The Washington Post.

## Why it's interesting

Most memory systems are glorified RAG — store embeddings, retrieve by similarity. Hindsight's three-layer architecture (world facts, experiences, mental models formed by reflection) mirrors how human memory consolidates over time. The "disposition-aware" reflect API is a genuinely different interface from the usual store/retrieve pattern. It also ships as a self-contained Docker image with an embedded Postgres option, Python embedded mode (no server), and 2-line LLM wrapper integration — low friction to try.

## How it works

**Retain** — new information (user inputs, tool calls) is ingested into a memory bank. Hindsight classifies it as either a world fact ("the stove gets hot") or an experience ("I touched the stove and it hurt"). Custom metadata can tag memories per-user for isolation.

**Reflect** — a background process consolidates raw memories into mental models: higher-order learned understanding formed by reflecting on accumulated facts and experiences. This is the "learning" step that distinguishes it from simple retrieval.

**Recall** — queries retrieve relevant memories (raw and mental models) via the biomimetic structures, filtered by metadata. A separate `reflect` API generates disposition-aware responses that incorporate learned understanding, not just matched documents.

Supports OpenAI, Anthropic, Gemini, Groq, Ollama, and LM Studio as LLM backends. Python and Node.js SDKs available, plus an LLM wrapper that drops into existing agent code with minimal changes.

## Key links

- [GitHub](https://github.com/vectorize-io/hindsight)
- [Docs](https://hindsight.vectorize.io)
- [Docker Image](https://ghcr.io/vectorize-io/hindsight)
- [Python Client](https://pypi.org/project/hindsight-client/)
- [Node.js Client](https://www.npmjs.com/package/@vectorize-io/hindsight-client)

## Notes

- Benchmark numbers look impressive but are self-reported by all vendors except Hindsight (Virginia Tech reproduced theirs). Worth checking [[AMA-Bench evaluates long-horizon memory for agentic applications using real and synthetic trajectories]] for comparison methodology.
- The mental models concept maps well to our vault's approach in [[four memory layers serve different knowledge types]] — world facts ≈ reference layer, experiences ≈ episodic layer, mental models ≈ synthesized knowledge notes.
- Could be worth exploring for [[cognee-knowledge-engine-for-ai-agent-memory|Cognee]] comparison — different philosophical approach (biomimetic vs knowledge graph).
