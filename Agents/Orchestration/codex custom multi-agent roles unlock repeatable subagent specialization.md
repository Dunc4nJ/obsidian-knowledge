---
created: 2026-02-19
description: Codex 0.102.0 introduced custom multi-agent roles with configurable models, reasoning, permissions, system prompts, and thread limits — enabling repeatable subagent specialization beyond the three built-in roles.
source: https://x.com/LLMJunky/status/2024152021436121220
type: learning
---

## Key Takeaways

Custom multi-agent roles in Codex let you define **repeatable, specialized subagents** with their own model, reasoning level, permissions, system prompt, and even MCP servers — moving beyond the three built-in roles (default, explorer, worker). This is a significant step toward the kind of [[orchestration architecture determines multi-agent investment quality|orchestration architecture]] that determines output quality more than raw agent count.

The configuration is hierarchical (global `~/.codex/` → project `.codex/` → subfolder), mirroring how AGENTS files already work. Each custom role gets two pieces: a `config.toml` entry with a description (so Codex knows *when* to call it) and a separate `role_config.toml` with the full definition (loaded only when invoked, saving parent session tokens). This lazy-loading pattern aligns with the principle that [[simple financial agents outperform complex ones when tool routing is tight|tight tool routing beats monolithic exposure]].

Key configuration levers:
- **Model and reasoning**: Each role can run a different model at a different reasoning level (e.g., Spark for fast implementation, 5.3 High for orchestration)
- **developer_instructions**: The role's system prompt — defines behavior, constraints, output format
- **sandbox_mode**: Per-role read-only vs read/write permissions
- **Features**: Toggle memory, shell access per role
- **MCP servers and ChatGPT Apps**: Per-role tool access (Linear, Notion, etc.)
- **Thread limit**: Hidden `max_threads` config can go beyond the default 6 parallel agents

The [[2 to 5 worker agents per lead is the sweet spot for multi agent orchestration|2-5 workers per lead sweet spot]] applies here — you'd want a high-reasoning orchestrator (5.3 High) dispatching to focused Spark workers, each with constrained permissions and clear instructions.

Pro patterns from the article:
- Skills can call subagents and subagents can call skills — composable specialization
- Structured output templates in developer_instructions get reliable (though not enforced) formatting
- Natural language invocation works, but explicit naming is more reliable

## External Resources

- [Codex custom agent role pack (GitHub)](https://github.com/am-will/codex-skills/tree/main/agents) — drop-in config.toml entries and role definition files
- [Codex subagent fundamentals (Part 0)](https://x.com/LLMJunky/status/2014521564864110669) — intro covering the three built-in roles

## Original Content

> [!quote]- Full tweet by @LLMJunky (Feb 18, 2026) — 452 likes, 43 RTs
>
> **CODEX MULTI-AGENT PLAYBOOK PART 1: SETUP GUIDE**
>
> With update 0.102.0, Codex received a brand new configuration setup for subagents, now officially dubbed "multi agents" by the OpenAI team. Custom multi-agent roles are user-defined subagents designed for repeatable tasks, highly configurable with model, reasoning, permissions, system prompts, MCP servers, and more.
>
> Key config options: model/reasoning level, global vs project scope, developer_instructions (role prompt), per-role permissions, feature toggles (memory, shell), MCP servers, ChatGPT Apps, verbosity/personality. Hidden `max_threads` setting can exceed the default 6 parallel agents.
>
> Setup: Add entries to `config.toml` with description + config_file path, then create detailed role definitions in `.codex/agents/`. Values not defined inherit from parent agent.
>
> Part 2 will cover orchestration strategies, Spark as a subagent worker, plan file structuring, and prompt patterns.
>
> [Original tweet](https://x.com/LLMJunky/status/2024152021436121220)
