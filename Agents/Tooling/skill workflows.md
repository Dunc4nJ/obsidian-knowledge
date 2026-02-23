---
created: 2026-02-05
description: Skills work best as modular, folder-based workflows that combine deterministic scripts and LLM steps via progressive disclosure, enabling reliable multi-skill automation pipelines.
source: https://x.com/llmjunky/status/2019439161560695197
type: framework
---

# skill workflows

## Core claim
Skills are most useful when treated as **folder-based workflow modules** (scripts + templates + nested skills), not as “just prompts/markdown,” because this structure makes complex LLM automations repeatable and token-efficient via progressive disclosure.

## Key takeaways

- **A skill is a folder (a mini product), not a single markdown file.** The SKILL.md is more like a README/docstring: it describes what’s inside and when to run which pieces; the real value lives in the scripts, templates, and sub-skills.

- **Combine determinism and LLM flexibility deliberately.** Put exact steps (API calls, file ops, formatting) into scripts, and use the LLM for synthesis/writing/creative decisions. This echoes the “use the right substrate for the job” pattern in [[capturing internal APIs can replace most agent browser automation]].

- **Progressive disclosure improves token efficiency and reliability.** The agent should load only what it needs, step-by-step, instead of dumping an entire repo/skill into context. This aligns with [[progressive disclosure filters force agent selectivity over what enters context]] and the broader separation of memory layers described in [[four memory layers serve different knowledge types]].

- **Nested composition is the scaling trick.** Skills can call subagents, which can call other skills; treated like functions with clear inputs/outputs, you can compose 10+ skills into one repeatable pipeline. This connects to orchestration ideas in [[multi-agent squads work when independent sessions share a mission control system]].

- **Templates are the quality control layer.** Templates inside skill folders make outputs consistent across runs and across subagents (e.g., consistent article format, consistent email HTML structure).

## Original content

> **@LLMJunky (am.will)** — Thu Feb 05 2026
>
> “You’re Wrong About Skills” argues that dismissing skills as “just markdown files” misses the point: a skill is a folder that can contain scripts, templates, and even sub-skills. The thread gives an end-to-end newsletter pipeline example where multiple skills and subagents orchestrate deterministic scripts (data pulls, posting) with LLM steps (writing, synthesis), producing repeatable output via stepwise instructions.
>
> Source: https://x.com/LLMJunky/status/2019439161560695197
>
> Engagement at capture time: 31 likes, 2 reposts, 3 replies
