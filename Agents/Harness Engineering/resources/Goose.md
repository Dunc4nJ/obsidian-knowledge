---
created: 2026-03-04
source: https://github.com/block/goose
description: Open-source extensible AI coding agent by Block that goes beyond code suggestions — installs, executes, edits, and tests with any LLM
type: resource
tags: [agent-harness, coding-agent, open-source, mcp, block]
status: unread
---

## What it is

Goose is an open-source, on-machine AI coding agent by Block (formerly Square). It goes beyond code suggestions — it can build entire projects from scratch, write and execute code, debug failures, orchestrate workflows, and interact with external APIs autonomously. Available as both a desktop app and CLI.

## Why it's interesting

It's one of the more polished open-source coding agents with real flexibility: works with any LLM, supports multi-model configuration (optimize perf vs cost), and integrates natively with MCP servers for extensibility. Block also supports custom distributions — you can build your own branded goose distro with preconfigured providers, extensions, and settings. The MCP-first extensibility model is notable compared to agents that use proprietary tool systems.

## How it works

- **Multi-LLM:** Configurable to use any LLM provider, with multi-model setups for routing different tasks to different models
- **MCP integration:** Extends capabilities through MCP (Model Context Protocol) servers rather than a proprietary plugin system
- **Desktop + CLI:** Ships as both a desktop app and a command-line tool
- **Custom distros:** Organizations can fork and build branded distributions with their own defaults ([CUSTOM_DISTROS.md](https://github.com/block/goose/blob/main/CUSTOM_DISTROS.md))
- **Responsible AI guide:** Ships with an explicit [responsible AI-assisted coding guide](https://github.com/block/goose/blob/main/HOWTOAI.md)

## Key links

- [GitHub](https://github.com/block/goose)
- [Documentation](https://block.github.io/goose/docs/category/getting-started)
- [Quickstart](https://block.github.io/goose/docs/quickstart)
- [Discord](https://discord.gg/goose-oss)
- [Twitter/X](https://x.com/goose_oss)

## Notes

- Apache 2.0 licensed
- Built in Rust
- MCP-first extensibility is the differentiator vs other coding agents
- Custom distro support is unusual — enables enterprise white-labeling
