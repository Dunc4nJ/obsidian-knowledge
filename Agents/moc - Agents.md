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

### Search
Agentic search strategies — code search, semantic retrieval, embedding-based indexing, grep-vs-RAG tradeoffs, long-horizon search behavior, search-vs-reasoning tradeoffs, and tools that help agents find information in codebases or broader environments. The overlap with Tooling is tight — place it here if the core topic is *search strategy or retrieval*, in Tooling if it's about *general agent tool design*.

### Continual Learning

- [[Letta Code agents can move across machines without losing memory]]
- [[stable agentic RL requires sequence-level clipping and environment-aware advantages to prevent training collapse]]

Agents that improve over time — RL from conversations, self-improvement loops, memory systems that compound knowledge across sessions, skill acquisition. The key test: *does the agent get better at its job over time?* If yes, it belongs here. If it just has good static context architecture, that's Tooling.

### Data Agent
AI agents that query databases, write SQL, answer data questions, and do data analysis. Text-to-SQL, discovery and context layers over warehouses, data assistant architectures, RL for SQL tool use. If the note is about *agents interacting with structured data to answer questions*, it goes here.

- [[OpenAI internal data agent succeeds through six layers of context not model capability alone]]
- [[context management replaces the semantic layer for data agents because it adapts from corrections]]
- [[the hard problem in text-to-SQL is discovery not generation and hybrid search over existing metadata solves it]]
- [[Prime Intellect duckdb-qa - RL reward shaping for SQL tool use]]
- [[multi-task RL on heterogeneous search behaviors produces knowledge agents that generalize across grounded reasoning tasks]]

### Evaluation and Monitoring
Measuring agent quality, observability, regression testing, LLM-as-judge, eval pipelines, drift detection, production monitoring. If the note is about *knowing whether the agent is doing well*, it goes here.

- [[Agno native tracing keeps agent observability data in your own database]]

### Extra
Roundups, digests, survey notes, and multi-topic captures that don't fit cleanly into one subfolder. Use sparingly — prefer placing notes in a specific subfolder when possible.

### Harness Engineering
Designing the scaffolding around agents — system prompts, AGENTS.md patterns, soul files, tool descriptions, prompt engineering techniques, middleware between the model and the world. If the note is about *shaping agent behavior through its harness*, it goes here.

- [[agents need a harness not a framework because durable event-driven infrastructure already solves retry routing and state]]
- [[OpenAI built a million-line product with zero manually-written code by making the repo legible to agents]]
- [[LLM agents need a typed execution layer beyond bash]]
- [[autonomous context compression lets agents choose when to compact rather than hitting fixed token limits]]
- [[the harness layer is the next hundred billion dollar AI infrastructure market not the model]]
- [[Slate's thread-based episodic memory solves long-horizon agent tasks]]

### Infrastructure
Production engineering for agents — security, reliability, sandboxing, deployment, distributed systems patterns, authentication, cost management. If the note is about *keeping agents running safely in production*, it goes here.

### MCP
Model Context Protocol — servers, tool definitions, transport patterns, and the MCP ecosystem specifically. If it's about MCP as a protocol or MCP-based tools, it goes here. General tool design goes in Tooling.

### OpenClaw
Notes specific to the OpenClaw platform — architecture, features, configuration, skills, and resources related to OpenClaw itself.

### Orchestration
Multi-agent coordination — delegation patterns, lead/worker ratios, communication between agents, state machines, planning-based orchestration, squad architectures. If the note is about *how multiple agents work together*, it goes here. Single-agent architecture decisions usually belong in Harness Engineering or Infrastructure.

- [[separating cognitive blueprints from runtime engines enables portable auditable agent systems]]

### Skills
Agent skill design, authoring, testing, and lifecycle management. SKILL.md patterns, eval frameworks for skills, skill triggering and description optimization, capability uplift vs. encoded preference, and the skill-as-specification thesis. If the note is about *how skills are built, tested, or managed*, it goes here.

- [[skill-creator now brings software testing rigor to agent skill authoring without requiring code]]
- [[agent skills need eval harnesses not vibe checks to ship reliably]]
- [[repo-local skills and AGENTS.md turn recurring engineering work into repeatable agent workflows]]
- [[LLMs can discover and reuse compositional tool skills via MCP primitives reducing token usage up to 80 percent]]
- [[agent skills should self-improve through observed failures not stay as static prompt files]]

### Tooling
Agent tool design, context engineering, prompt caching, skill architectures, search strategies, progressive disclosure, and general patterns for how agents interact with tools and manage context. The broadest subfolder — if a note is about *how agents use tools or manage their context window*, it goes here.

- [[Everything is Context: Agentic File System Abstraction for Context Engineering]]

## Placement Rules

1. Read the note's Key Takeaways, not just the title. Titles can mislead.
2. Ask: "What is the **primary insight**?" Place based on that, even if the note touches other areas.
3. When genuinely ambiguous between two subfolders, prefer the more specific one.
4. One note, one subfolder. No duplicates. Use `[[wiki links]]` to connect across subfolders.
5. If nothing fits, use **Extra** temporarily and revisit when the vault grows.
