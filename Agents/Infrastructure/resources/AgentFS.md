---
created: 2026-03-08
source: https://github.com/tursodatabase/agentfs
type: resource
tags: [agent-infrastructure, filesystem, sqlite, state-management, turso]
status: unread
---

## What it is

AgentFS is a filesystem designed explicitly for AI agents, built by Turso. It stores an agent's entire runtime — files, key-value state, and tool call history — in a single SQLite database file. It provides SDKs for TypeScript, Python, and Rust, a CLI with FUSE/NFS mounting support, and an open specification.

## Why it's interesting

The core insight is treating agent state as a first-class, queryable artifact rather than ephemeral runtime data. Because everything lives in a single SQLite file, you get auditability (query full history with SQL), reproducibility (snapshot and restore exact states), and portability (move the file anywhere). This is complementary to sandboxing approaches like [[resources/Anthropic Sandbox Runtime|Anthropic Sandbox Runtime]] and [[resources/OpenSandbox|OpenSandbox]] — those handle "how to run safely," while AgentFS handles "what happened and what's the state."

## How it works

AgentFS exposes three interfaces through its SDK, all backed by a single SQLite database:

- **Filesystem** — A POSIX-like filesystem for files and directories, mountable via FUSE (Linux) or NFS (macOS). Agents can read/write files normally, and everything is persisted to the database.
- **Key-Value Store** — A typed key-value store for agent state and context (preferences, session data, etc.).
- **Tool Call Audit Trail** — Every tool invocation is recorded with timestamps, inputs, outputs, and status, creating a queryable timeline for debugging and analysis.

The underlying storage uses the AgentFS SQLite specification, implemented on top of [Turso](https://github.com/tursodatabase/turso) (libSQL). The CLI supports `agentfs init` to create agent databases, `agentfs mount` for filesystem access, and `agentfs run` for sandboxed execution with the agent filesystem mounted at `/agent`.

## Key links

- [GitHub](https://github.com/tursodatabase/agentfs)
- [Specification](https://github.com/tursodatabase/agentfs/blob/main/SPEC.md)
- [User Manual](https://github.com/tursodatabase/agentfs/blob/main/MANUAL.md)
- [Blog Post](https://turso.tech/blog/agentfs)

## Notes

- SDKs available for TypeScript, Python, and Rust
- Examples integrate with Mastra, Claude Agent SDK, OpenAI Agents SDK, Vercel AI SDK, and Cloudflare Workers
- Includes a Firecracker VM example with AgentFS mounted via NFSv3 — relevant for secure agent sandboxing
- Beta software as of March 2026
