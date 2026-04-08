---
created: 2026-02-27
description: Navigation hub for agent infrastructure — databases, sandboxing, runtime failures, and protocol design for production AI agents.
source: internal
type: moc
---

# Agent Infrastructure

Patterns and pitfalls for running AI agents in production: storage, isolation, protocols, and failure modes.

## Notes

- [[agents need a database because stateless reasoning cores require stateful storage]] — why agents need persistent storage beyond in-context memory
- [[isolating the entire agent in a sandbox is more secure than isolating just the tool]] — full-agent sandboxing vs tool-level isolation tradeoffs
- [[seven runtime failures emerge when demo agents meet production distributed systems]] — common failure modes when scaling agent demos to production
- [[the Codex App Server turns a CLI agent harness into a stable bidirectional JSON-RPC protocol for any client]] — turning CLI agents into stable protocol-based services
- [[agentic software engineering requires six pillars beyond the agent itself to survive production]] — durability, isolation, governance, persistence, scale, and composability as the engineering foundation for production agents
- [[production AI agents require five security dimensions from model access to runtime observability]]
- [[databases are becoming the runtime layer for AI agents as application logic collapses into the data layer]] — as agents bypass application layers and operate directly on data, databases evolve from storage into the execution substrate for intelligence — Palantir's framework for securing agents: model access, orchestration isolation, memory policy enforcement, governed tools with provenance-based security, and observability
- [[Cloudflare Dynamic Workers sandbox AI-generated code in V8 isolates 100x faster than containers]]
- [[LangChain deep agents require persistent memory scoped sandboxes and guardrails to move from prototype to production]] — production checklist covering memory scoping, sandbox lifecycle, middleware guardrails, and frontend streaming for LangChain Deep Agents — V8 isolate-based sandboxing with millisecond startup for AI-generated code execution, plus Code Mode libraries for TypeScript-native agent tool APIs
- [[a virtual filesystem over Chroma replaces sandboxes for agent doc exploration at 100ms instead of 46 seconds]]
- [[Amazon S3 Files ends the object-file split for AI agents]] — turns S3 buckets into a shared file-system workspace for AI agents, removing local/object synchronization layers in multi-agent pipelines.
- [[Harvey Spectre makes durable runs the core primitive while workers stay ephemeral and sandboxes enforce explicit boundaries]] — Harvey's internal cloud coding agent platform treats the run record (not the worker process) as the durable object, enforces explicit capability injection at run start, and unifies Slack/web/CLI surfaces over a single run
