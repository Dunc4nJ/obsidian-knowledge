---
created: 2026-03-01
source: https://github.com/alibaba/OpenSandbox
type: resource
tags: [sandboxing, agent-infrastructure, code-execution, alibaba]
status: unread
---

## What it is

OpenSandbox is a general-purpose sandbox platform from Alibaba for AI applications. It provides multi-language SDKs (Python, Java/Kotlin, TypeScript, C#/.NET, Go), unified sandbox lifecycle and execution APIs, and runtimes backed by Docker or Kubernetes. It targets coding agents, GUI agents, agent evaluation, AI code execution, and RL training.

## Why it's interesting

It's a serious attempt at a universal sandbox abstraction layer — one API surface for spinning up isolated environments regardless of whether you're running locally on Docker or at scale on Kubernetes. The multi-language SDK coverage is unusually broad, and the built-in support for browser automation (Chrome, Playwright) and desktop environments (VNC, VS Code) inside sandboxes makes it relevant for GUI agent work, not just code execution.

## How it works

**Sandbox Protocol** defines lifecycle management (create, start, stop, destroy) and execution APIs (run commands, access filesystem, interpret code) as a standard interface, so custom runtimes can be plugged in.

**Sandbox Runtime** handles the actual container orchestration — Docker for local development, a high-performance Kubernetes runtime for distributed scheduling at scale.

**Sandbox Environments** are pre-built configurations layered on top: command execution, filesystem access, code interpreters, browser automation (Chrome/Playwright), and full desktop environments (VNC/VS Code). These compose into the scenarios (coding agent, GUI agent, eval harness, etc.).

**Network Policy** provides a unified ingress gateway with multiple routing strategies plus per-sandbox egress controls for security isolation.

## Key links

- [GitHub](https://github.com/alibaba/OpenSandbox)
- [Chinese docs](https://github.com/alibaba/OpenSandbox/blob/main/docs/README_zh.md)
- [Kubernetes runtime](https://github.com/alibaba/OpenSandbox/tree/main/kubernetes)

## Notes

- Compare with E2B, Daytona, and other sandbox-as-a-service platforms. OpenSandbox is self-hosted rather than SaaS.
- The Kubernetes runtime could be relevant if we ever need to scale agent sandboxing beyond single-machine Docker.
