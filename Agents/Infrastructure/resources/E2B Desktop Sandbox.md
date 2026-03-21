---
created: 2026-03-21
source: https://github.com/e2b-dev/desktop
type: resource
tags: [sandbox, computer-use, desktop, e2b, virtual-environment]
status: unread
---

## What it is

E2B Desktop Sandbox is an open-source virtual desktop environment designed for LLM computer use. It provides isolated, customizable sandboxes with a full graphical desktop that agents can control programmatically via Python or JavaScript SDKs — including mouse, keyboard, screenshots, and live streaming of the desktop or individual application windows.

## Why it's interesting

This solves the secure execution environment problem for computer-use agents: each sandbox is fully isolated, can run real GUI applications (Chrome, VS Code, Firefox), and exposes a clean API for mouse/keyboard control and screenshots. The streaming capability lets you watch agents work in real-time, which is valuable for debugging and demos. It's the infrastructure layer behind E2B's open-source computer-use examples like Surf (OpenAI CUA agent) and Open Computer Use (open-source LLM agent).

## How it works

**Sandbox creation** — The SDK spins up an isolated virtual desktop environment on E2B's infrastructure via API. Each sandbox gets its own display server and can launch arbitrary GUI applications.

**Application control** — The SDK provides programmatic mouse control (click, drag, scroll, move), keyboard control (type, hotkeys), and screenshot capture. Agents use these primitives to interact with applications the same way a human would.

**Streaming** — Sandboxes can stream their desktop or individual application windows via authenticated URLs. Streams support view-only mode and auth-key-based access control. Only one stream per sandbox at a time.

**Window management** — The SDK can enumerate open windows, get the current active window, and target streams to specific application windows rather than the full desktop.

## Key links

- [GitHub](https://github.com/e2b-dev/desktop)
- [E2B Platform](https://e2b.dev)
- [E2B Docs](https://e2b.dev/docs)
- [Open Computer Use](https://github.com/e2b-dev/open-computer-use) — 100% open-source LLM computer use
- [Surf](https://github.com/e2b-dev/surf) — OpenAI CUA agent using E2B Desktop

## Notes

- Python SDK: `pip install e2b-desktop` / JS SDK: `npm install @e2b/desktop`
- Requires E2B API key (hosted infrastructure, not self-hosted)
- Competing approaches: Anthropic's computer use with Docker, Browserbase for browser-only sandboxing
