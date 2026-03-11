---
created: 2026-03-11
description: SkillCraft benchmark and Skill Mode protocol show that LLM agents can autonomously discover, compose, verify, and cache reusable tool skills at test time via four MCP primitives, cutting token usage by up to 80% and cost by 75%.
source: https://x.com/shiqi_chen17/status/2031023010141081708
type: learning
---

## Key Takeaways

SkillCraft introduces a benchmark of 126 tasks across 6 domains specifically designed to test whether LLM agents can go beyond atomic tool calls and acquire **compositional skills** — reusable chains of tool invocations that transfer across tasks. This directly extends the idea that [[ProcMEM learning reusable procedural memory from experience via non-parametric PPO for LLM agents|procedural memory from experience]] can be formalized without parameter updates, but SkillCraft focuses on tool composition rather than general decision-making.

The Skill Mode protocol defines four MCP primitives (`save_skill`, `list_skills`, `get_skill`, `execute_skill`) that let agents store, retrieve, and invoke reusable skills in a persistent library. This is a lightweight, standards-aligned approach compared to heavier frameworks — similar in spirit to how [[code execution with MCP cuts tool token overhead 98 percent by presenting servers as filesystem APIs instead of upfront definitions|MCP-based code execution]] reduces overhead by restructuring how tools are presented.

A critical finding: **skill creator quality matters more than executor capability**. Claude-generated skills achieved 100% success across all executor models with 54–81% token savings. Poorly designed skills increased cost regardless of which model ran them. This suggests investment should go into the skill authoring process, not just the runtime model.

Flat, well-tested skill compositions consistently outperform hierarchical nesting. GPT-5.2 dropped from 90% → 79% success when moving from flat to hierarchical composition, because deeper nesting amplifies error propagation even when execution rates stay high (95-99%). This echoes patterns seen in [[Continual Learning Implementations Across Letta, Scout, and Serena|continual learning implementations]] where simpler memory structures prove more robust.

The efficiency gains correlate with model capability (r=0.53) — stronger models compose flexibly while weaker models over-apply skills rigidly. GPT-5.2 went from 1.23M → 0.26M tokens per task ($1.77 → $0.43).

## External Resources

- [SkillCraft Paper](https://t.co/Vg7MPJy4FO) — full research paper
- [SkillCraft Code](https://t.co/ZRez74QvgQ) — benchmark implementation
- [SkillCraft Project Page](https://t.co/ukGYi5Itjr) — overview and results

## Original Content

> [!quote]- Source Material
>
> **@shiqi_chen17 (Shiqi Chen)** — Mon Mar 09 2026 · Thread (7 tweets)
> Source: https://x.com/shiqi_chen17/status/2031023010141081708
>
> Can LLMs discover, abstract, and reuse higher-level tool skills across tasks?
>
> Existing tool-use benchmarks test solving tasks with fixed tools. But real workflows contain recurring structures where efficiency comes from reusable tool compositions, not isolated calls.
>
> We introduce SkillCraft: 126 tasks across 6 domains designed to test whether LLM agents can acquire compositional skills, not just call atomic tools.
>
> We also propose Skill Mode, a lightweight protocol with four MCP primitives that let agents compose, verify, cache, and reuse tool chains at test time.
>
> Our Key findings across evaluating 8 SOTA models:
>
> ⚡Skill Mode enables agents to self-discover and reuse skills, leading to higher success and efficiency than agents without it. The gains are larger for stronger models.
>
> 🧠 Stronger models (e.g., Claude) discover more generalizable skills, which transfer across tasks and even across models.
>
> 🔍 Deeper composition ≠ better — shallow, well-tested skills generalize best.
>
> 🔗 Paper: https://t.co/Vg7MPJy4FO
> 💻 Code: https://t.co/ZRez74QvgQ
> 🏠 Page: https://t.co/ukGYi5Itjr
>
> (1/7)
>
> ---
>
> How do we benchmark compositional tool use?
> Real tool workflows are long-horizon and repetitive: the same procedures repeat across entities.
>
> SkillCraft mirrors this structure:
> → multi-step reasoning across tools
> → repeated workflows over multiple entities
> Difficulty scales naturally with more entities (3→4→5) and longer tool chains (3→4→5).
> → 126 tasks across 21 families and 6 domains.
>
> *SkillCraft benchmark structure*
> ![[shiqi_chen17-081708-001.jpg]]
>
> (2/7)
>
> ---
>
> How we evaluate LLM agents on such tool-composition tasks?
>
> We design an evaluation protocol to assess LLM agents' ability on SkillCraft.
>
> The protocol operates in a plug-and-play setting with four MCP primitives: save_skill, list_skills, get_skill, and execute_skill, which allow agents to store, retrieve, and invoke reusable skills.
>
> The evaluation pipeline follows an iterative loop:
> Explore → Compose → Verify → Cache → Reuse.
>
> Through this process, agents can expand their action space at test time by discovering, validating, and accumulating reusable skills in a persistent Skill Library while solving tasks.
>
> *Skill Mode evaluation protocol*
> ![[shiqi_chen17-081708-002.jpg]]
>
> (3/7)
>
> ---
>
> What do we find through evaluation?
>
> 📊 Evaluating 8 SOTA models:
>
> Key finding: Skill Mode is a capability amplifier.
> → Token usage reduced by up to 80%, cost by 75%.
> → Efficiency gains correlate with model capability (r=0.53).
> → Stronger models compose flexibly; weaker models over-apply rigidly.
>
> SkillCraft reveals a clear capability spectrum: compositional tool use separates strong agents from weak ones.
> GPT-5.2: 1.23M → 0.26M tokens, $1.77 → $0.43 per task.
>
> *Evaluation results across 8 models*
> ![[shiqi_chen17-081708-003.jpg]]
>
> (4/7)
>
> ---
>
> What makes a good skill composition?
> (1) Composition structure
>
> Hierarchical skill nesting amplifies error propagation.
>
> Example: GPT-5.2 drops from 90% → 79% success when moving from flat skills to hierarchical composition.
>
> In practice, flat, well-tested skill libraries are more robust and generalize better across tasks.
>
> *Flat vs hierarchical composition results*
> ![[shiqi_chen17-081708-004.jpg]]
>
> (5/7)
>
> ---
>
> What makes a good skill composition?
> (2) Abstraction quality
>
> Better models discover more generalizable skills.
>
> Claude-generated skills:
> → 100% success across all executor models
> → 54–81% token savings
>
> Poorly designed skills can even increase cost regardless of executor.
> Skill creator quality > executor capability.
>
> (6/7)
>
> ---
>
> Great collaboration with @gai_jz @ruochenz1018 @jinghan23 @tongyao_zhu @lockonlvange @James_KKW @wzenus @ZhengyuChen @klarakaleb @Miaow_Lab @SiyangGao @cong_ml @ManlingLi_ @junxian_he @yeewhye on this work!!
>
> (7/7)
>
> ---
>
> **Notable replies:**
>
> @shiqi_chen17 (in reply to a question about recursive skill invocation):
> "Great observation! we have tested this. Our Hierarchical Mode supports recursive skill invocation up to depth 10 (most settle at 3–4 in practice). Results are cautionary: GPT-5.2 dropped from 90% → 79% success with tokens rising from 0.26M to 0.60M. Exec rates stay high (95-99%) — skills run, they just propagate wrong results. Shallow + well-verified consistently beats deep + auto-generated."
>
> @shiqi_chen17 (in reply to @0xfffCrypto mentioning SkillHub):
> "SkillHub manages predefined skills, while SkillCraft studies whether agents can form, adapt, and reuse skills during task solving. Our focus is skill acquisition and evolution, not skill management."
>
> @anirudhg9119 shared related work on turning past experiences to reusable skills and conditioning model behaviour to drive learning.
>
> @Alex4Changes: "LLMs autonomously discovering tool abstraction is the real AGI signal. Building my own AI agents showed me how hierarchical skills emerge naturally when you let models iterate—game changer for complex workflows."
