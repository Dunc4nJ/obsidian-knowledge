---
created: 2026-02-28
description: Navigation hub for multi-agent orchestration — delegation, coordination, communication, and squad architectures.
type: moc
---

# Orchestration

Multi-agent coordination — delegation patterns, lead/worker ratios, communication between agents, state machines, and squad architectures.

## Canonical

- [[Anthropic's multi-agent Research system - orchestrator-worker subagents scale token spend past one context window for a 90 percent lift over single-agent Opus]] — the June 2025 engineering post most of this folder argues with. Why multi-agent works (token spend explains 80% of BrowseComp variance; parallel subagent context windows scale it; Opus-lead + Sonnet-subs +90.2% over single Opus), when it doesn't (~15x chat tokens; shared-context/dependency-heavy tasks like coding), eight delegation-prompting principles (explicit effort-scaling rules, tool-testing agents that rewrite tool descriptions for a 40% speedup, start-wide-then-narrow, two-layer parallelism for up to 90% time cuts), outcome-not-path evals (~20 queries to start; one LLM judge with a five-axis rubric beats a judge panel), and production lessons (durable resume, rainbow deployments, decision-pattern tracing, subagent-outputs-to-filesystem to avoid the game of telephone); 3 diagrams
- [[Cognition finds multi-agent systems work only when writes stay single-threaded and additional agents contribute intelligence not actions]] — the counterpoint pole of the 2025 multi-agent debate ("don't build multi-agents"): parallel *reads* fine, parallel *writes* conflict; context must flow through one authoritative thread

## Notes

- [[2 to 5 worker agents per lead is the sweet spot for multi agent orchestration]]
- [[Athena is a vault librarian agent that maintains structure links and capture workflows]]
- [[agents should coordinate via push messaging not through a human copying context between terminals]]
- [[background agents shift alerting from reactive keyword matching to proactive semantic discovery]]
- [[codex custom multi-agent roles unlock repeatable subagent specialization]]
- [[intelligent AI delegation requires trust accountability and adaptive monitoring not just task decomposition]]
- [[multi-agent squads work when independent sessions share a mission control system]]
- [[orchestration architecture determines multi-agent investment quality]]
- [[planner-worker hierarchies outperform flat coordination for scaling multi-agent coding]]
- [[multi-agent coordination benefits are task-contingent not universal and predictable from measurable task properties]]
- [[simple financial agents outperform complex ones when tool routing is tight]]
- [[every agentic system needs three sub-agent patterns sync async and scheduled]]
- [[structured multi-agent disagreement surfaces hidden trade-offs that single-model reasoning averages away]]
