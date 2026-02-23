---
created: 2026-02-05
description: Skills work best as modular, folder-based workflows that combine deterministic scripts and LLM steps via progressive disclosure, enabling reliable multi-skill automation pipelines.
source: https://x.com/llmjunky/status/2019439161560695197
type: framework
---

# skill workflows

## Core claim
Skills are most useful when treated as **folder-based workflow modules** (scripts + templates + nested skills), not as "just prompts/markdown," because this structure makes complex LLM automations repeatable and token-efficient via progressive disclosure.

## Key takeaways

- **A skill is a folder (a mini product), not a single markdown file.** The SKILL.md is more like a README/docstring: it describes what's inside and when to run which pieces; the real value lives in the scripts, templates, and sub-skills.

- **Combine determinism and LLM flexibility deliberately.** Put exact steps (API calls, file ops, formatting) into scripts, and use the LLM for synthesis/writing/creative decisions. This echoes the "use the right substrate for the job" pattern in [[capturing internal APIs can replace most agent browser automation]].

- **Progressive disclosure improves token efficiency and reliability.** The agent should load only what it needs, step-by-step, instead of dumping an entire repo/skill into context. This aligns with [[progressive disclosure filters force agent selectivity over what enters context]] and the broader separation of memory layers described in [[four memory layers serve different knowledge types]].

- **Nested composition is the scaling trick.** Skills can call subagents, which can call other skills; treated like functions with clear inputs/outputs, you can compose 10+ skills into one repeatable pipeline. This connects to orchestration ideas in [[multi-agent squads work when independent sessions share a mission control system]].

- **Templates are the quality control layer.** Templates inside skill folders make outputs consistent across runs and across subagents (e.g., consistent article format, consistent email HTML structure).

## Original Content

> [!quote]- Full Article by @LLMJunky (am.will) — 2026-02-05
>
> **You're Wrong About Skills**
>
> I often see a take so bad that I can't help but facepalm. Experienced devs turning their noses up at skills as though they are some kind of novelty toy made up by frontier labs to sell subscriptions.
>
> "I don't need any of that. I've been coding for 15 years." "I don't use skills. I just write good prompts." "They're just markdown files."
>
> They brag that they can do it all without them. And fair enough. But that doesn't mean you shouldn't. This is very short-sighted. And it's holding people back from what is, in my opinion, a perfect framework to get the most out of an LLM.
>
> **Let Me Set the Record Straight.** Skills are not markdown files. Skills are folders. And inside those folders you can host a variety of subfolders, scripts, templates, and even sub-skills. The SKILL.md is just the README for the agent. It outlines how the agent should explore the folder, what to use, and when. Calling a skill "just a markdown file" is like calling a repo "just a README." SKILL.md tells you how to use what's inside. The folder is the actual product. And as a bonus: your coding agent will ONLY load into context what it actually needs, one step at a time, so it's HIGHLY token efficient.
>
> **Why This Matters.** With this approach, you can build powerful, repeatable automations. You can use scripts where pure determinism shines, and LLMs where non-determinism shines. You're not choosing between rigid automation and flexible AI. You're combining both in a single orchestrated system. The SKILL.md tells your agent when and where to use the contents of the folder in a step-by-step nature, with progressive disclosure. It only sees what it needs, when it needs it.
>
> **A Real-World Example** — a workflow running an entire newsletter pipeline:
>
> Step 1: Price Data — The skill runs a script to call an API and pull seven days of price data. Deterministic. No LLM needed.
>
> Step 2: Article Generation — Launches three subagents, one per URL. Each subagent calls a blog writing skill, scrapes the story, performs three adjacent web searches for additional context, and writes using a template inside the skill folder.
>
> Step 3: Image Generation — Articles written, then another skill calls a deterministic script to generate blog cover images.
>
> Step 4: WordPress Publishing — Another skill automatically posts everything to WordPress. Each subagent returns a summary plus filepaths back to the parent agent.
>
> Step 5: Newsletter Assembly — The parent agent crafts a newsletter using the three articles, written with a specific template, summarizing and linking to WordPress.
>
> Step 6: Email Output — Newsletter written to file and generates HTML email according to template, ready for review and sending.
>
> **The Anatomy of This Workflow:** 10 skills working together, 3 subagents running in parallel, 9 scripts handling deterministic tasks, 4 templates ensuring consistent output, one command to kick it all off. All folders compartmentalized and called in a deterministic fashion. Modular, yet working in unison. 100% repeatable. Reliable.
>
> **The Architecture That Makes It Work.** The key concept is nesting. A skill can call a subagent. That subagent can call another skill. That skill has its own readme, templates, scripts. Each layer is self-contained but designed to plug into the layer above it. Think of it like functions in code. Each skill is a function with clear inputs and outputs. The SKILL.md is the docstring. The folder contents are the implementation. Scripts handle exact work (API calls, file operations, data formatting). LLMs handle flexible work (writing, research, synthesis, creative decisions). The skill folder is where these two worlds meet.
>
> **You Can Get Very Sophisticated With This.** The same architecture applies to any repeatable workflow: content pipelines, code generation, data analysis, report building, client deliverables. The devs who understand this are building systems. The devs who dismiss skills as "just markdown files" are still doing the work by hand.
>
> Welcome to the club. I've automated huge chunks of my job. You can too.
>
> *80 likes · 5 retweets · 7 replies*

[Original post](https://x.com/llmjunky/status/2019439161560695197)
