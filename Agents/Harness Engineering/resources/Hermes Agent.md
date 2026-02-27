---
created: 2026-02-27
source: https://github.com/NousResearch/hermes-agent
type: resource
tags: [agent-harness, persistent-agent, open-source, nous-research]
status: unread
---

## What it is

Hermes Agent is a fully open-source personal agent runtime by Nous Research. You install it on a server and it becomes a persistent agent — connecting to Telegram, Discord, Slack, and WhatsApp via a single gateway process, running scheduled tasks via built-in cron, spawning isolated subagents for parallel work, and accumulating memory and skills across sessions. It supports any model provider (Nous Portal, OpenRouter, or self-hosted VLLM/SGLang endpoints).

## Why it's interesting

It's a complete agent harness with real infrastructure opinions: five sandboxing backends (local, Docker, SSH, Singularity, Modal), a skill system compatible with the agentskills.io open standard, trajectory generation for RL training, and cross-platform message mirroring. The architecture is the same one Nous uses internally for batch data generation and RL training environments, which gives it a dual identity as both a consumer agent and a research tool.

## Key links

- [GitHub](https://github.com/NousResearch/hermes-agent)
- [Nous Research](https://nousresearch.com)
- [Nous Portal](https://portal.nousresearch.com)
- [DeepWiki](https://deepwiki.com/NousResearch/hermes-agent)

## Notes

- TUI-first interface, not a web UI
- Skill system is searchable, shareable, and publishable to a community hub
- Batch runner + Atropos RL environments for training tool-calling models
- Architecture very similar to OpenClaw — worth comparing design decisions
