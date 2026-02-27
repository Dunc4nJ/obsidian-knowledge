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
