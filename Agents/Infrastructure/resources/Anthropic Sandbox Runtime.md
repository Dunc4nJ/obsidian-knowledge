---
created: 2026-03-03
source: https://github.com/anthropic-experimental/sandbox-runtime
description: OS-level process sandboxing for AI agents, MCP servers, and bash commands using sandbox-exec (macOS) and bubblewrap (Linux)
type: resource
tags: [sandboxing, agent-infrastructure, mcp, claude-code, process-isolation]
status: unread
---

## What it is

Anthropic Sandbox Runtime (`srt`) is a lightweight sandboxing CLI/library that enforces filesystem and network restrictions on arbitrary processes at the OS level — no container or VM required. Built for Claude Code and released as an open-source research preview. Install via `npm install -g @anthropic-ai/sandbox-runtime`, then prefix any command with `srt`.

## Why it's interesting

It's the lightest-weight option in the agent sandboxing space — no VMs ([[SmolVM]]), no containers ([[OpenSandbox]]), just OS-native primitives. The killer use case is wrapping MCP servers: swap `"command": "npx"` for `"command": "srt", "args": ["npx", ...]` in your `.mcp.json` and the server is sandboxed. Secure-by-default philosophy: processes start with minimal access, you explicitly poke holes. Developed by the Claude Code team at Anthropic.

## How it works

**Dual isolation model** — both filesystem and network isolation are required (without file isolation, exfiltrate SSH keys; without network isolation, escape the sandbox):

- **Filesystem**: Read is allow-all by default (deny specific paths like `~/.ssh`). Write is deny-all by default (explicitly allow paths like `.`, `/tmp`).
- **Network**: All network access denied by default. Explicitly allow domains. Traffic routed through host-side proxy servers (Linux uses Unix domain sockets with network namespace removed entirely).
- **macOS**: Uses `sandbox-exec` with dynamically generated Seatbelt profiles
- **Linux**: Uses bubblewrap for containerization with network namespace isolation
- **Violation monitoring**: On macOS, taps into system sandbox violation log store for real-time alerts

Configuration via `~/.srt-settings.json`:
```json
{
  "filesystem": {
    "denyRead": [],
    "allowWrite": ["."],
    "denyWrite": ["~/sensitive-folder"]
  },
  "network": {
    "allowedDomains": [],
    "deniedDomains": []
  }
}
```

## Key links

- [GitHub](https://github.com/anthropic-experimental/sandbox-runtime)

## Notes

- Research preview — APIs and config formats may evolve.
- Contrast with VM-based approaches ([[isolating the entire agent in a sandbox is more secure than isolating just the tool|Browser Use's full agent isolation]]): `srt` is process-level, not VM-level. Weaker isolation boundary (shared kernel) but zero overhead and trivial to adopt.
- Particularly relevant for sandboxing MCP servers which are a growing attack surface.
