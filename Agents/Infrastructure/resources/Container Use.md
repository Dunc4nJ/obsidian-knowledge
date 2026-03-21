---
created: 2026-03-21
source: https://github.com/dagger/container-use
type: resource
tags: [agents, infrastructure, containers, mcp, isolation]
status: unread
---

## What it is

Container Use is an open-source MCP server (and CLI tool) by Dagger that gives coding agents isolated, containerized development environments. Each agent gets a fresh container on its own git branch, enabling multiple agents to work in parallel on the same repo without conflicts.

## Why it's interesting

The core problem it solves is agent parallelism and safety: instead of babysitting one agent at a time, you can spin up multiple agents that each work in isolation. It also provides real-time visibility into what agents actually did (command history, logs) and lets you drop into any agent's terminal for direct intervention. Works with Claude Code, Cursor, and any MCP-compatible agent — no vendor lock-in.

## How it works

**Environment provisioning** — When an agent needs to work, Container Use spins up a fresh container with its own git branch via the Dagger engine. The agent operates inside this container with full access to the repo's stack.

**MCP integration** — The tool exposes itself as a standard MCP stdio server (`container-use stdio`), so any MCP-compatible agent can use it without custom integration. Agent rules can optionally be appended to guide behavior.

**Git-based workflow** — Each container maps to a git branch, so reviewing or discarding an agent's work uses standard git operations (`git checkout`, `git diff`). Failed experiments can be discarded instantly.

**Observability and intervention** — Complete command history and logs are captured per container. Operators can drop into any running agent's terminal to inspect state or take over manually.

## Key links

- [GitHub](https://github.com/dagger/container-use)
- [Docs](https://container-use.com)
- [Discord](https://container-use.com/discord)
- [Quickstart](https://container-use.com/quickstart)

## Notes

- Install via Homebrew (`brew install dagger/tap/container-use`) or curl script.
- CLI alias `cu` available as shortcut for `container-use`.
- Early/experimental stage — actively evolving.
- Powered by the Dagger engine under the hood.
