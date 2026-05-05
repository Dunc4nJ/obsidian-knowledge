---
created: 2026-02-27
description: Navigation hub for agent infrastructure — databases, sandboxing, file systems, runtime failures, and protocol design for production AI agents.
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
- [[databases are becoming the runtime layer for AI agents as application logic collapses into the data layer]] — as agents bypass application layers and operate directly on data, databases evolve from storage into the execution substrate for intelligence
- [[Cloudflare Dynamic Workers sandbox AI-generated code in V8 isolates 100x faster than containers]]
- [[LangChain deep agents require persistent memory scoped sandboxes and guardrails to move from prototype to production]] — production checklist covering memory scoping, sandbox lifecycle, middleware guardrails, and frontend streaming for LangChain Deep Agents
- [[Harvey Spectre makes durable runs the core primitive while workers stay ephemeral and sandboxes enforce explicit boundaries]] — Harvey's internal cloud coding agent platform treats the run record (not the worker process) as the durable object, enforces explicit capability injection at run start, and unifies Slack/web/CLI surfaces over a single run
- [[Palantir Ontology gives enterprise agents a decision-centric substrate by surfacing data logic and action as tools governed by one security model]] — Palantir's platform thesis: enterprise agents need a decision-centric (not data-centric) substrate that fuses Data, Logic, Action, and Security into one Ontology so agents call ML models/optimizers/business logic as tools, stage writebacks as scenarios, and learn from full decision lineage; Onyx supplier-disruption walkthrough shows the four-layer (data → logic → action → learning) decision loop in practice
- [[Opencomputer reframes harness-vs-sandbox debate as git branches for VMs via hibernation egress proxies and checkpoints]] — Utpal Nadiger rebuts Mendral's "harness outside the sandbox" thesis: egress-proxy credential tokenization (Vault/Tokenizer/IMDS pattern) is a 15-year-old solved primitive, 25ms VM hibernation invalidates the cost argument, and checkpoint-fork durability creates a third option beyond cattle-vs-pets — but the rebuttal sidesteps the multi-user shared-state problem and surfaces the real fault line between runtime-level and VM-level durability

## File Systems

File systems as agent infrastructure — virtual filesystems, storage-as-compute, file semantics over object stores, and the emerging pattern of embedding compute into the storage layer.

- [[Bash is the SQL for file systems and Archil proves it with serverless execution that sends instructions not data]] — Archil embeds bash execution into the file system so clients send instructions instead of transferring raw data, eliminating egress costs and positioning file systems as queryable substrates for agent state
- [[Amazon S3 Files ends the object-file split for AI agents]] — turns S3 buckets into a shared file-system workspace for AI agents, removing local/object synchronization layers in multi-agent pipelines
- [[a virtual filesystem over Chroma replaces sandboxes for agent doc exploration at 100ms instead of 46 seconds]] — ChromaFS layers Unix file semantics over a vector database, giving agents grep/cat/ls access to document collections at 100ms session creation
