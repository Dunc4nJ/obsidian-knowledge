---
created: 2026-02-21
description: Letta Code is a coding agent built around persistent, long-lived agents with memory-first architecture rather than independent sessions — the top model-agnostic OSS harness on TerminalBench.
source: https://www.letta.com/blog/letta-code
type: reference
---

# Letta Code: A Memory-First Coding Agent

**Source:** https://www.letta.com/blog/letta-code
**Published:** December 16, 2025

## Overview

Letta Code is a coding agent built around persistent, long-lived agents rather than independent sessions. It's described as "the #1 model-agnostic OSS harness on TerminalBench."

---

## Core Features

### Memory & Continual Learning
- **`/init` command** -- triggers deep codebase research, forming memories and rewriting the system prompt via memory blocks
- **`/remember` command** -- manually triggers agent reflection and learning
- Agents accumulate context over time, improving with each session

### Skill Learning
Agents can learn reusable skills from past experiences (stored as `.md` files), such as:
- DB migration generation
- PostHog dashboard creation
- API best-practice documentation

Skills are git-manageable and portable across compatible agents.

### Persisted State & Search
The built-in `/search` command enables hybrid vector/full-text search across past messages and conversations via the Letta API.

---

## Benchmark Performance

Letta Code achieves comparable results to provider-specific harnesses (Claude Code, Gemini CLI, Codex CLI) on their respective models, while being fully model-agnostic.

---

## Installation

```bash
npm install -g @letta-ai/letta-code
```

Full docs: [docs.letta.com/letta-code](https://docs.letta.com/letta-code)
## Original Content

> [!quote]- Source Material
> Letta Code is a memory-first coding agent, designed for working with agents that learn over time. When working with coding agents today, interactions happen in independent sessions. Letta Code is built around long-lived agents that persist across sessions and improve with use. Rather than working in independent sessions, each session is tied to a persisted agent that learns. Letta Code is also the #1 model-agnostic OSS harness on TerminalBench, and achieves comparable performance to harnesses built by LLM providers (Claude Code, Gemini CLI, Codex CLI) on their own models.
> 
> ## Continual Learning & Memory for Coding Agents
> Agents today accumulate valuable experience: they receive the user's preferences and feedback, review significant parts of code, and observe the outcomes of taking actions like running scripts or commands. Yet today this experience is largely wasted. Letta agents learn from experience through agentic context engineering, long-term memory, and skill learning. The more you work with an agent, the more context and memory it accumulates, and the better it becomes. 
> 
> ### Memory Initialization
> When you get started with Letta Code, you can run an `/init` command to encourage your agent to learn about your existing project. This will trigger your agent to run deep research on your local codebase, forming memories and rewriting its system prompt (through memory blocks) as it learns.
> ‍
> ‍
> Your agent will continue to learn automatically, but you can also explicitly trigger your agent to reflect and learn with the `/remember` command. 
> 
> ### Skill Learning
> Many tasks that we work on with coding agents are repeated or follow similar patterns - for example API patterns or running DB migrations. Once you've worked with an agent to coach it through a complex task, you can trigger it to learn a skill from its experience, so the agent itself or other agents can reference the skill for similar tasks in the future. Skill learning can dramatically improve performance on future similar tasks, as we showed with recent results on TerminalBench.
> On our team, some skills that agents have contributed (with the help of human engineers) are: 
> 
> - Generating DB migrations on schema changes
> - Creating PostHog dashboards with the PostHog CLI
> - Best practices for API changes
> Since skills are simply .md files, they can be managed in git repositories for versioning - or even used by other coding agents that support skills. 
> 
> ### Persisted State
> Agents can also lookup past conversations (or even conversations of other agents) through the Letta API. The builtin `/search` command allows you to easily search through messages, so you can find the agent you worked on something with. The Letta API supports vector, full-text, and hybrid search over messages and available tools.
> 
> ## Letta Code is the #1 model-agnostic OSS coding harness
> Letta Code adds statefulness and learning to coding agents, but is the #1 model-agnostic, OSS harness on Terminal-Bench. Letta Code's performance is comparable to provider-specific harnesses (Gemini CLI, Claude Code, Codex) across model providers, and significantly outperforms the previous leading model-agnostic harness, Terminus 2.
> 
> This means that even without memory, you can expect Letta Code agents to work just as well with a frontier model as they would with a specific harness built by the model provider. 
> 
> ## Getting Started with Letta Code
> To try out Letta Code, you can install it with npm install -g @letta-ai/letta-code (see the full documentation).
