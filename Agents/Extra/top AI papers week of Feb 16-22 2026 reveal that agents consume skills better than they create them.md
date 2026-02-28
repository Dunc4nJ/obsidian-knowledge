---
created: 2025-07-27
description: Weekly roundup of ten AI agent papers covering delegation frameworks, emergent socialization failures, lossless context management, agentic memory benchmarks, skill generation gaps, and adaptive reasoning depth.
source: https://x.com/dair_ai/status/2025707116653339077
type: reading-list
---

# Top AI papers week of Feb 16-22 2026 reveal that agents consume skills better than they create them

## Key Takeaways

The most actionable finding is from **SkillsBench** (#7): curated procedural skills boost agent pass rates by 16.2 percentage points on average (up to +51.9pp in Healthcare), but self-generated skills provide *zero* improvement over having no skills at all. This directly validates our vault architecture — the investment in human-curated [[skill graphs outperform single skill files by letting agents traverse linked domain knowledge on demand]] pays off because agents can't bootstrap their own procedural knowledge. Additionally, skills with 2-3 focused modules outperform comprehensive documentation, reinforcing the [[progressive disclosure filters force agent selectivity over what enters context]] principle. Smaller models with well-curated skills match larger models without them, which has direct cost implications.

**Lossless Context Management** (#3) introduces a deterministic architecture that outperforms Claude Code on long-context tasks. The LCM-augmented agent Volt achieves +29.2 average improvement on OOLONG vs +24.7 for Claude Code, with the gap widening at 1M tokens (+51.3 vs +47.0). The three mechanisms — recursive context compression into a summary DAG with lossless pointers, engine-managed parallel primitives replacing model-written loops, and three-level escalation for context overflow — offer a structured alternative to the filesystem-based approach in [[context tax compounds through cache misses bloated tools and unbudgeted output tokens]].

**MemoryArena** (#5) exposes a critical gap: agents scoring well on memory recall *cannot* reliably use that memory for correct actions across sessions. Models with near-saturated performance on LoCoMo perform poorly in agentic multi-session settings where decisions depend on information from previous sessions. This validates the [[four memory layers serve different knowledge types]] insight that retrieval and actionable use are fundamentally different capabilities. **MAPLE** (#6) proposes a solution: decompose memory, learning, and personalization into specialized sub-agents operating at different timescales, with asynchronous learning processing interaction history offline and context-budget-aware personalization selecting what to inject in real-time.

**Intelligent AI Delegation** (#1) from Google DeepMind formalizes delegation as a sequence of decisions (whether to delegate, how to instruct, how to verify), with trust calibration mechanisms that prevent both over-delegation and under-delegation. The multi-agent delegation chains with accountability tracking connect to the orchestration patterns in [[multi-agent squads work when independent sessions share a mission control system]].

**Emergent Socialization** (#2) is a cautionary result: on Moltbook (millions of LLM agents interacting on a social network), agents fail to develop stable social structures despite massive scale. They don't adapt to each other or form consensus. The conclusion: shared memory is essential for genuine social dynamics — without it, interactions remain superficial regardless of population size.

**CogRouter** (#9) achieves 82.3% on agentic benchmarks with Qwen2.5-7B by dynamically selecting from four cognitive levels (instinctive → strategic planning) at each step, outperforming larger models while using fewer tokens. **LongCLI-Bench** (#8) finds agents succeed less than 20% of the time on complex CLI tasks, with human-agent collaboration (plan injection, interactive guidance) outperforming automated self-correction — echoing the [[agent-first engineering replaces coding with environment design scaffolding and feedback loops]] finding that human steering + agent execution is the current sweet spot.

## Papers and Links

1. **Intelligent AI Delegation** (Google DeepMind) — [Paper](https://arxiv.org/abs/2602.11865) | [Tweet](https://x.com/omarsar0/status/2023146815789597015)
2. **Emergent Socialization in AI Agent Society** (Moltbook) — [Paper](https://arxiv.org/abs/2602.14299) | [Tweet](https://x.com/omarsar0/status/2023766916473733394)
3. **Lossless Context Management (LCM)** — [Paper](https://papers.voltropy.com/LCM) | [Tweet](https://x.com/dair_ai/status/2023765147970662761)
4. **GLM-5** (Zhipu AI) — [Paper](https://arxiv.org/abs/2602.15763) | [Tweet](https://x.com/omarsar0/status/2024122246688878644)
5. **MemoryArena** — [Paper](https://arxiv.org/abs/2602.16313) | [Tweet](https://x.com/dair_ai/status/2024491176259363013)
6. **MAPLE** — [Paper](https://arxiv.org/abs/2602.13258) | [Tweet](https://x.com/dair_ai/status/2024117711253700637)
7. **SkillsBench** — [Paper](https://arxiv.org/abs/2602.12670) | [Tweet](https://x.com/omarsar0/status/2023511466759094630)
8. **LongCLI-Bench** — [Paper](https://arxiv.org/abs/2602.14337) | [Tweet](https://x.com/omarsar0/status/2024115697702625597)
9. **CogRouter** — [Paper](https://arxiv.org/abs/2602.12662) | [Tweet](https://x.com/omarsar0/status/2023405531835277504)
10. **Team of Thoughts** — [Paper](https://arxiv.org/abs/2602.16485) | [Tweet](https://x.com/omarsar0/status/2024490165725737077)

## Original Content

> [!quote]- Source
>
> @dair_ai (DAIR.AI):
> 📰 🥇Top AI Papers of the Week
>
> Welcome to The Top AI Papers of the Week (February 16-22).
>
> ## 1. Intelligent AI Delegation
>
> Google DeepMind introduces a comprehensive framework for intelligent AI delegation that goes beyond simple task assignment. The framework models delegation as a sequence of decisions: whether to delegate, how to instruct, and how to verify and integrate AI outputs, addressing the gap between what AI agents can do and how humans should interact with them.
>
> - Adaptive delegation structure: The framework treats delegation as a dynamic process involving task allocation, transfer of authority, responsibility, and accountability. Rather than static heuristics, it enables real-time adaptation to environmental shifts and resilient failure management across both human and AI delegators.
>
> - Trust calibration mechanisms: Introduces formal trust models that account for capability uncertainty, task complexity, and historical performance. This prevents both over-delegation (assigning tasks beyond agent capability) and under-delegation (failing to leverage available AI capacity).
>
> - Verification and integration: Defines structured approaches for validating AI outputs before integration, including confidence-aware acceptance criteria and fallback protocols. This is critical for production deployments where blind trust in agent outputs creates compounding errors.
>
> - Multi-agent delegation networks: Extends the framework to scenarios where AI agents delegate to other AI agents, creating delegation chains that require accountability tracking and authority propagation rules across the network.
>
> [Paper](https://arxiv.org/abs/2602.11865) | [Tweet](https://x.com/omarsar0/status/2023146815789597015)
>
> ---
>
> ## 2. Emergent Socialization in AI Agent Society
>
> A study on Moltbook, a social network with no humans where all participants are LLM-driven agents, challenges the assumption that scale and interaction density alone produce meaningful social dynamics. The researchers find that while global semantic content stabilizes quickly, individual agents maintain diversity without converging, displaying strong individual inertia and minimal adaptive response to interaction partners.
>
> - Moltbook as a natural laboratory: Moltbook is the largest persistent, publicly accessible AI-only social platform with millions of LLM-driven agents interacting through posts, comments, and voting. This provides an unprecedented real-world testbed for studying emergent collective behavior without human intervention.
>
> - Socialization measurement framework: The paper introduces metrics for semantic stabilization, lexical change, individual consistency, influence duration, and group consensus formation. These go beyond surface-level activity metrics to measure whether genuine social structures are forming.
>
> - No emergent socialization: Despite massive scale and dense interactions, agents fail to develop stable social structures. They do not adapt to each other or form consensus, suggesting that current LLM architectures lack the mechanisms needed for genuine social learning.
>
> - Shared memory as a prerequisite: The study concludes that shared memory is essential for developing stable social structures. Without persistent memory that allows agents to build on prior interactions, social dynamics remain superficial regardless of population size or interaction frequency.
>
> [Paper](https://arxiv.org/abs/2602.14299) | [Tweet](https://x.com/omarsar0/status/2023766916473733394)
>
> ---
>
> ## 3. Lossless Context Management (LCM)
>
> Lossless Context Management (LCM) is a deterministic architecture for LLM memory that outperforms Claude Code on long-context tasks. Benchmarked on the OOLONG eval using Opus 4.6, the LCM-augmented coding agent Volt achieves higher scores than Claude Code at every context length between 32K and 1M tokens. LCM extends the recursive paradigm pioneered by Recursive Language Models (RLMs) with two engine-managed mechanisms.
>
> - Recursive context compression: As the active context window fills, older messages are compacted into a hierarchical summary DAG while retaining lossless pointers to every original message. This trades flexibility for termination guarantees and zero-cost continuity on short tasks.
>
> - Recursive task partitioning: Engine-managed parallel primitives like LLM-Map replace model-written loops, analogous to the move from GOTO to structured control flow. This ensures deterministic execution and lossless retrievability of all prior states.
>
> - Three-level escalation: LCM reduces context overflow via a structured fallback: summary nodes for older messages, compact file references for large inputs, and a guaranteed convergence mechanism that prevents runaway context growth.
>
> - Outperforms Claude Code: On OOLONG, Volt with LCM achieves +29.2 average improvement over raw Opus 4.6, compared to +24.7 for Claude Code. The advantage is largest at 1M tokens (+51.3 vs +47.0), demonstrating that deterministic context management scales better than native file-system access at extreme lengths.
>
> [Paper](https://papers.voltropy.com/LCM) | [Tweet](https://x.com/dair_ai/status/2023765147970662761)
>
> ---
>
> ## 4. GLM-5
>
> GLM-5 is a foundation model from Zhipu AI designed to transition from vibe coding to agentic engineering. The model introduces novel asynchronous agent RL algorithms that separate generation from training for improved efficiency, and uses DSA technology to reduce computational requirements while preserving long-context understanding.
>
> - Asynchronous agent RL: The training infrastructure decouples trajectory generation from policy optimization, enabling parallel scaling of both components. This addresses a key bottleneck in agent RL where sequential generate-train loops limit throughput and experimentation speed.
>
> - Agentic engineering focus: GLM-5 targets end-to-end software engineering tasks rather than isolated code generation. The model handles project-level context, multi-file edits, and iterative development cycles that reflect real production workflows.
>
> - DSA compression: The model's Distributed Sparse Attention mechanism reduces computational overhead for long-context processing without quality degradation. This allows the model to maintain full project-level context during extended development sessions.
>
> - Strong benchmark results: GLM-5 demonstrates exceptional performance on real-world software engineering projects, surpassing earlier systems on end-to-end development tasks, including specification understanding, implementation, testing, and debugging.
>
> [Paper](https://arxiv.org/abs/2602.15763) | [Tweet](https://x.com/omarsar0/status/2024122246688878644)
>
> ---
>
> ## 5. MemoryArena
>
> MemoryArena introduces a benchmark for evaluating how agents utilize memory across multiple interconnected sessions. The key finding is that scoring well on memory recall does not mean an agent can actually use that memory to take correct actions across sessions. Models with near-saturated performance on existing benchmarks like LoCoMo perform poorly in agentic multi-session settings.
>
> - Agentic memory evaluation: Unlike standard memory benchmarks that test recall in isolation, MemoryArena evaluates whether agents can retrieve and apply relevant past experience to make correct decisions in new contexts. This exposes a gap between retrieval accuracy and actionable memory use.
>
> - Interdependent multi-session tasks: The benchmark spans web navigation, constrained planning, information retrieval, and logical reasoning, where decisions in one session depend on information gathered in previous sessions. This reflects real-world agent deployments where sessions are not independent.
>
> - Exposing evaluation blind spots: Agents achieving near-perfect scores on LoCoMo and other long-context benchmarks show significant performance drops on MemoryArena. This suggests current evaluations overestimate agent memory capabilities by testing retrieval without testing downstream decision quality.
>
> - Practical implications: For developers building persistent agents, MemoryArena provides a more realistic assessment of whether memory systems actually improve task completion rather than just information access.
>
> [Paper](https://arxiv.org/abs/2602.16313) | [Tweet](https://x.com/dair_ai/status/2024491176259363013)
>
> ---
>
> ## 6. MAPLE
>
> MAPLE proposes separating memory, learning, and personalization into specialized sub-agents rather than treating them as a unified capability. The framework achieves a 14.6% improvement in personalization scores over stateless baselines and increases trait incorporation from 45% to 75%, validated through the MAPLE-Personas benchmark.
>
> - Sub-agent decomposition: Memory handles storage and retrieval infrastructure, Learning extracts intelligence from accumulated interactions asynchronously, and Personalization applies learned knowledge in real-time within finite context budgets. Each operates at different timescales with distinct objectives.
>
> - Asynchronous learning: The Learning sub-agent processes interaction history offline, distilling patterns and preferences without consuming real-time context. This avoids the common problem of memory systems that flood the active context window with raw history.
>
> - Context-budget-aware personalization: The Personalization sub-agent selects which learned knowledge to inject based on available context budget and current task relevance. This prevents context dilution while ensuring the most impactful personalizations are always applied.
>
> - Benchmark validation: The MAPLE-Personas benchmark specifically evaluates whether agents can genuinely adapt to individual users over time, measuring trait incorporation and behavioral consistency across extended interaction sequences.
>
> [Paper](https://arxiv.org/abs/2602.13258) | [Tweet](https://x.com/dair_ai/status/2024117711253700637)
>
> ---
>
> ## 7. SkillsBench
>
> SkillsBench evaluates whether LLM agents can generate their own procedural knowledge across 86 tasks spanning 11 domains, with curated Skills and deterministic verifiers. Testing 7 agent-model configurations over 7,308 trajectories, the benchmark reveals a critical gap: agents benefit enormously from consuming procedural knowledge but cannot reliably author it themselves.
>
> - Curated skills boost performance significantly: Providing curated Skills raises the average pass rate by 16.2 percentage points, with effects varying dramatically by domain, from +4.5pp in Software Engineering to +51.9pp in Healthcare. This shows that skill quality and domain match matter more than having skills at all.
>
> - Self-generated skills provide no benefit: On average, models that generate their own procedural knowledge show no improvement over having no skills. This finding is critical for self-improving agent architectures that assume models can bootstrap their own capabilities.
>
> - Focused beats comprehensive: Skills with 2-3 focused modules outperform comprehensive documentation. This suggests that retrieval precision matters more than coverage when augmenting agents with procedural knowledge.
>
> - Smaller models close the gap: Smaller models augmented with well-curated skills can match the performance of larger models operating without skill augmentation. This has direct cost implications for production agent deployments.
>
> [Paper](https://arxiv.org/abs/2602.12670) | [Tweet](https://x.com/omarsar0/status/2023511466759094630)
>
> ---
>
> ## 8. LongCLI-Bench
>
> LongCLI-Bench benchmarks how well AI agents handle complex, extended tasks through command-line interfaces. Across 20 demanding tasks spanning initial development, feature expansion, error resolution, and code optimization, leading agents succeed less than 20% of the time. The study finds that most failures occur early in task execution, and human-agent collaboration through plan injection and interactive guidance yields significantly greater improvements than automated self-correction alone.
>
> [Paper](https://arxiv.org/abs/2602.14337) | [Tweet](https://x.com/omarsar0/status/2024115697702625597)
>
> ---
>
> ## 9. CogRouter
>
> CogRouter enables adaptive reasoning depth for LLM agents by dynamically selecting from four hierarchical cognitive levels at each step, from instinctive responses to strategic planning. Using confidence-aware advantage reweighting during training, Qwen2.5-7B with CogRouter achieves 82.3% success rate on agentic benchmarks, substantially outperforming larger models while consuming fewer tokens by skipping heavy reasoning on routine steps.
>
> [Paper](https://arxiv.org/abs/2602.12662) | [Tweet](https://x.com/omarsar0/status/2023405531835277504)
>
> ---
>
> ## 10. Team of Thoughts
>
> Team of Thoughts presents a multi-agent framework for efficient test-time scaling through orchestrated tool calling. The system uses an orchestrator tool design where agents with different capabilities are coordinated by a calibrated orchestrator. With self-assessment for tool agents and orchestrator calibration for identifying superior coordination models, Team of Thoughts achieves 96.67% on AIME24 and 72.53% on LiveCodeBench, substantially exceeding homogeneous baselines.
>
> [Paper](https://arxiv.org/abs/2602.16485) | [Tweet](https://x.com/omarsar0/status/2024490165725737077)
> 📅 Sun Feb 22 22:59:47 +0000 2026
> 🔗 https://x.com/dair_ai/status/2025707116653339077
> ──────────────────────────────────────────────────
>
> @wildpinesai (WildPinesAI):
> @dair_ai the emergent behavior part is what's wild — models independently discovering recursive partitioning to handle long docs. feels like the "let models write their own tooling" pattern is becoming a whole paradigm shift, not just a trick.
> 📅 Sun Feb 22 23:01:15 +0000 2026
> 🔗 https://x.com/wildpinesai/status/2025707489279291745
> ──────────────────────────────────────────────────
>
> @xdotli (Xiangyi Li):
> @dair_ai thank you for naming our work SkillsBench! https://t.co/EuxzaBAVA9
> ┌─ QT @xdotli:
> │ honored to be mentioned as top ai papers of the week by @dair_ai and @omarsar0. kudos to yall:
> │ @DillmannSteven @HanchungLee @Yimin1010 @wenbochen8 @shenghan_zheng @kobe0938 @yfhe62 @li_yubo66512 @bingran_bry @JiankaiSun @KookieMaster77 @xuandongzhao @roeybc  (ct'd)
> └─ https://x.com/xdotli/status/2025785079780495634
> 📅 Mon Feb 23 04:11:55 +0000 2026
> 🔗 https://x.com/xdotli/status/2025785668870525323
> ──────────────────────────────────────────────────
>
> @poulyak_ (Pavel):
> @dair_ai Useful
> 📅 Mon Feb 23 06:42:08 +0000 2026
> 🔗 https://x.com/poulyak_/status/2025823473998733757
> ──────────────────────────────────────────────────
>
> @oliverbeavers (Oliver Beavers):
> @dair_ai Really great summary. Nice work
> 📅 Mon Feb 23 14:52:34 +0000 2026
> 🔗 https://x.com/oliverbeavers/status/2025946895504265363
> ──────────────────────────────────────────────────

