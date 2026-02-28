---
created: 2026-02-28
description: Map of Content for the Agents knowledge tree — defines each subfolder's scope and placement criteria.
type: moc
---

# Agents

Knowledge about building, running, and improving AI agents. Each subfolder covers a distinct concern. Notes should land in exactly one subfolder based on the primary topic — if a note spans multiple concerns, place it where the core insight lives.

## Subfolders

### Agentic Memory
How agents store, retrieve, and evolve knowledge across sessions. Memory architectures, vault-as-memory patterns, state persistence, context survival across compaction. If the note is about *what agents remember and how*, it goes here. If it's about *how agents selectively load context into a prompt*, that's Tooling (context engineering).

### Codebase Search
Code search, semantic code retrieval, embedding-based code indexing, grep-vs-RAG tradeoffs, and tools that help agents navigate large codebases. The overlap with Tooling is tight — place it here if the core topic is *finding code*, in Tooling if it's about *general agent tool design*.

### Continual Learning
Agents that improve over time — RL from conversations, self-improvement loops, memory systems that compound knowledge across sessions, skill acquisition. The key test: *does the agent get better at its job over time?* If yes, it belongs here. If it just has good static context architecture, that's Tooling.

### Evaluation & Monitoring
Measuring agent quality, observability, regression testing, LLM-as-judge, eval pipelines, drift detection, production monitoring. If the note is about *knowing whether the agent is doing well*, it goes here.

### Extra
Roundups, digests, survey notes, and multi-topic captures that don't fit cleanly into one subfolder. Use sparingly — prefer placing notes in a specific subfolder when possible.

### Harness Engineering
Designing the scaffolding around agents — system prompts, AGENTS.md patterns, soul files, tool descriptions, prompt engineering techniques, middleware between the model and the world. If the note is about *shaping agent behavior through its harness*, it goes here.

### Infrastructure
Production engineering for agents — security, reliability, sandboxing, deployment, distributed systems patterns, authentication, cost management. If the note is about *keeping agents running safely in production*, it goes here.

### MCP
Model Context Protocol — servers, tool definitions, transport patterns, and the MCP ecosystem specifically. If it's about MCP as a protocol or MCP-based tools, it goes here. General tool design goes in Tooling.

### OpenClaw
Notes specific to the OpenClaw platform — architecture, features, configuration, skills, and resources related to OpenClaw itself.

### Orchestration
Multi-agent coordination — delegation patterns, lead/worker ratios, communication between agents, state machines, planning-based orchestration, squad architectures. If the note is about *how multiple agents work together*, it goes here. Single-agent architecture decisions usually belong in Harness Engineering or Infrastructure.

### Tooling
Agent tool design, context engineering, prompt caching, skill architectures, search strategies, progressive disclosure, and general patterns for how agents interact with tools and manage context. The broadest subfolder — if a note is about *how agents use tools or manage their context window*, it goes here.

## Placement Rules

1. Read the note's Key Takeaways, not just the title. Titles can mislead.
2. Ask: "What is the **primary insight**?" Place based on that, even if the note touches other areas.
3. When genuinely ambiguous between two subfolders, prefer the more specific one.
4. One note, one subfolder. No duplicates. Use `[[wiki links]]` to connect across subfolders.
5. If nothing fits, use **Extra** temporarily and revisit when the vault grows.
