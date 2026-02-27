---
created: 2026-02-27
description: Navigation hub for agent tooling — tool design, search strategies, prompt caching, skill architecture, and context management for AI agents.
source: internal
type: moc
---

# Agent Tooling

How to design, describe, and orchestrate tools that agents actually use well.

## Notes

- [[agent-first engineering replaces coding with environment design scaffolding and feedback loops]] — shifting from writing code to designing agent environments
- [[agentic image generation loop]] — iterative image generation with agent-in-the-loop
- [[agentic search with grep and full-file loading replaces RAG when context windows are large enough]] — grep+load vs RAG tradeoffs at scale
- [[capturing internal APIs can replace most agent browser automation]] — API capture as a faster alternative to browser agents
- [[context tax compounds through cache misses bloated tools and unbudgeted output tokens]] — hidden costs of poor context management
- [[prompt caching is the foundational constraint for building long-running agents]] — caching as the key architectural constraint
- [[rewriting tool descriptions with curriculum learning improves agent tool use without execution traces]] — curriculum-based tool description optimization
- [[skill graphs outperform single skill files by letting agents traverse linked domain knowledge on demand]] — graph-structured skills vs flat skill files
- [[skill workflows]] — workflow patterns for agent skills
