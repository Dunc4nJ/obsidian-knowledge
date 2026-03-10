---
created: 2026-07-11
source: https://github.com/snoglobe/helios
type: resource
tags: [ml-research, autonomous-agents, experiment-automation]
status: unread
---

## What it is

An autonomous ML research agent inspired by Andrej Karpathy's autoresearch. You give it a goal (e.g. "train a 125M parameter GPT on TinyStories to loss < 1.0") and it writes training scripts, launches runs, parses metrics from stdout, monitors progress, compares experiments, and iterates — all without human intervention. Built as a Node.js CLI with a TUI.

![[helios-screenshot.png]]

## Why it's interesting

Designed for overnight, unattended ML research runs where the agent keeps iterating instead of stopping to ask questions. Operates seamlessly over SSH to remote GPU machines, has built-in metric visualization (sparklines in the TUI), run comparison tools, session resume, and a memory system. Supports both Claude (via Agent SDK or API) and OpenAI as backends.

## How it works

**Goal decomposition** — the agent breaks a natural-language research goal into concrete experiments. **Remote execution** — training scripts are launched via `remote_exec_background` on SSH-connected machines (GPU boxes preferred for heavy compute, local for lightweight tasks). **Live metric parsing** — stdout is captured and metrics are parsed in real time, displayed as sparklines in the UI. **Monitoring** — `start_monitor` sets up periodic check-ins to review training progress. **Comparison** — `compare_runs` evaluates experiments against each other, keeping improvements and discarding regressions. **Iteration** — the agent plans the next experiment based on results and loops until the goal is met or interrupted. Sessions can be resumed, and a `/writeup` command generates an experiment report from the conversation history.

## Key links

- [GitHub](https://github.com/snoglobe/helios)
- [Karpathy's autoresearch](https://github.com/karpathy/autoresearch) — the inspiration

## Notes

- No permissions/security model yet — runs unrestricted. Use in a container or with backups.
- The autoresearch prompt works well inside Helios with minor tuning.
- Pairs naturally with [[autoresearch lets an AI agent run ML experiments autonomously overnight]] — Helios is essentially a production-hardened, multi-machine version of the same idea.
