---
created: 2026-02-27
source: https://github.com/steipete/mcporter
type: resource
tags: [mcp, typescript, cli, code-generation]
status: unread
---

## What it is

MCPorter is a TypeScript runtime, CLI, and code-generation toolkit for the Model Context Protocol. It auto-discovers MCP servers already configured in Cursor, Claude Code, Codex, and others, letting you call tools directly, compose automations in TypeScript, and generate single-purpose CLIs from any MCP server definition — all without boilerplate or schema spelunking.

## Why it's interesting

It collapses the gap between "I have MCP servers configured" and "I can actually call them programmatically." Zero-config discovery, typed client generation (`emit-ts`), and one-command CLI minting (`generate-cli`) make it a practical bridge for agents and scripts that need to consume MCP tools without hand-wiring transports or auth flows.

## Key links

- [GitHub](https://github.com/steipete/mcporter)
- [npm](https://www.npmjs.com/package/mcporter)
- [CLI Reference](https://github.com/steipete/mcporter/blob/main/docs/cli-reference.md)
- [Ad-hoc Connections](https://github.com/steipete/mcporter/blob/main/docs/adhoc.md)

## Notes

- Supports HTTP, SSE, and stdio transports from the same interface
- Built-in OAuth caching and auto-detection for hosted MCPs (Supabase, Vercel, etc.)
- `npx mcporter` works without installation — good for quick exploration
