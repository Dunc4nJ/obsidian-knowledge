---
created: 2026-03-10
source: https://github.com/nteract/nteract
type: resource
tags: [notebooks, jupyter, mcp, agents, collaboration]
status: unread
---

## What it is

nteract is an MCP (Model Context Protocol) server that connects AI assistants like Claude to Jupyter notebooks. It enables persistent code execution, real-time collaboration between humans and agents in a shared notebook, and automatic Python environment management.

## Why it's interesting

It bridges the gap between AI coding agents and interactive data exploration. Instead of agents generating code in a chat window, they work directly in a notebook where you can watch execution in real time, share kernel state across multiple agents, and collaborate on the same document. One-line setup with Claude Code (`claude mcp add nteract -- uvx --prerelease allow nteract`).

## How it works

**MCP server** — nteract runs as a local MCP server that exposes ~18 tools (create/open/save notebooks, create/execute/delete cells, kernel management, code completion, queue state). An agent connects via MCP and manipulates notebooks programmatically.

**Persistent kernel** — a Jupyter kernel runs in the background with full state. Agents can execute cells, stream tokens into cells via `append_source`, and check execution queues. Multiple agents can connect to the same notebook session.

**Desktop app** — the companion [nteract/desktop](https://github.com/nteract/desktop) app (native, instant startup) renders the notebook in real time so you see the agent's work as it happens. The legacy Electron app is archived; the new one uses a realtime system (`runtimed`).

## Key links

- [GitHub (MCP server)](https://github.com/nteract/nteract)
- [Desktop app](https://github.com/nteract/desktop)
- [Archived legacy desktop app](https://github.com/nteract/archived-desktop-app)

## Notes

- Agent-in-the-loop notebooks could be interesting for data exploration workflows — especially paired with data agents that need to iterate on SQL/Python.
- Shared kernel state across multiple agents is a differentiator vs. typical code execution sandboxes.
