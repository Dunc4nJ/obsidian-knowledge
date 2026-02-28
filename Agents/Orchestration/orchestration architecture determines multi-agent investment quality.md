---
created: 2026-02-19
description: A multi-agent investment committee using five orchestration patterns and three-layer knowledge shows how architecture choice shapes output quality more than agent count.
source: https://x.com/ashpreetbedi/status/2024293702001135648
type: framework
---

## Key Takeaways

The core thesis is that **orchestration pattern selection matters more than agent sophistication**. The same seven agents produce vastly different output quality depending on whether they're routed, broadcast, coordinated, tasked, or pipelined — a principle directly applicable to how [[plutus|Plutus]] could evolve beyond single-agent analysis.

**Five architecture patterns map to different question types:**
- **Route** — quick expert lookup ("What's AAPL's P/E?"), lowest cost
- **Broadcast** — independent parallel votes then synthesis, best for consensus decisions
- **Coordinate** — chair-led discussion, best for exploratory analysis
- **Task Mode** — PM decomposes into parallel workstreams with dependencies, best for complex portfolio construction
- **Workflow** — deterministic five-step pipeline, best for auditable repeatable reviews

**Three-layer knowledge architecture** prevents the classic "everything in a vector store" failure:
1. **Static context** (system prompt) — risk limits, mandate rules. Never searched, always present. Critical constraints must be unavoidable, not discoverable.
2. **Research library** (PgVector RAG) — company profiles, sector analysis. Large corpus where semantic search works well.
3. **Memo archive** (filesystem, read whole files) — past investment memos. Structured documents lose meaning when chunked; find the right one and read all of it.

**Institutional learning** is the differentiator between "agents" and "an institution." Agents save patterns, corrections, and insights to a shared knowledge base after each session. Session 2 starts further ahead than Session 1 because it retrieves past learnings before pulling fresh data. This maps closely to the [[plutus-plan|Plutus plan]]'s vision of persistent analytical memory.

The **model allocation strategy** is practical: Sonnet for specialist analysts (fast, cheap, focused), Opus for the Chair (better reasoning for synthesizing conflicting perspectives). Cost-effective tiering rather than max-model everywhere.

The system uses **Agno** (Python framework) with YFinance for market data and Exa MCP for web search. All seven agents share committee context via system prompt injection and a shared learning namespace.

## External Resources

- [Investment Committee repo](https://github.com/agno-agi/investment-committee) — full open-source implementation
- [Agno framework](https://github.com/agno-agi/agno) — Python multi-agent framework powering the system
- [Agno docs: Teams & Modes](https://docs.agno.com/teams) — orchestration patterns documentation
- [Agno docs: Learning Machines](https://docs.agno.com/learning) — institutional learning feature

## Original Content

> [!quote]- Full tweet by @ashpreetbedi (Feb 19, 2026) — 373 likes, 35 RTs
> 
> **Investment Committee: 5 Multi-Agent Architectures in Action**
> 
> Most multi-agent tutorials show you one orchestration pattern applied to a toy problem. Four agents chat about the weather, agree with each other, and produce an answer that one agent could have written alone.
> 
> This post builds an investment committee with seven specialist agents orchestrated across five distinct architectures: Route, Broadcast, Coordinate, Task Mode, and Workflow. Each pattern maps to a different question type.
> 
> The system manages a $10M vehicle investing in US public equities against live market data via YFinance and Exa web search. Seven agents: Market Analyst, Financial Analyst, Technical Analyst, Risk Officer, Knowledge Agent, Memo Writer, and Committee Chair (Opus).
> 
> Three-layer knowledge: (1) static context in system prompt for critical rules, (2) PgVector RAG for research library, (3) filesystem browsing for structured memos.
> 
> Institutional learning via LearningMachine: agents save patterns and corrections to shared knowledge after each session, so the committee accumulates wisdom over time.
> 
> Source: https://x.com/ashpreetbedi/status/2024293702001135648
