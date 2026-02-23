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

> [!quote]- Full Article by @dair_ai (DAIR.AI) — Feb 22, 2026
>
> **Top AI Papers of the Week (February 16-22)**
>
> *1. Intelligent AI Delegation*
> ![[dairai-339077-001.jpg]]
>
> Google DeepMind introduces a comprehensive framework for intelligent AI delegation that goes beyond simple task assignment. The framework models delegation as a sequence of decisions: whether to delegate, how to instruct, and how to verify and integrate AI outputs. Introduces formal trust models accounting for capability uncertainty, task complexity, and historical performance. Extends to multi-agent delegation networks with accountability tracking and authority propagation rules.
>
> ---
>
> *2. Emergent Socialization in AI Agent Society*
> ![[dairai-339077-002.jpg]]
>
> Study on Moltbook, the largest persistent AI-only social platform with millions of LLM agents. Despite massive scale and dense interactions, agents fail to develop stable social structures. They do not adapt to each other or form consensus. Shared memory identified as essential prerequisite for genuine social dynamics.
>
> ---
>
> *3. Lossless Context Management (LCM)*
> ![[dairai-339077-003.png]]
>
> Deterministic architecture for LLM memory that outperforms Claude Code on OOLONG eval using Opus 4.6. Volt with LCM achieves +29.2 average improvement over raw Opus 4.6 vs +24.7 for Claude Code. Advantage largest at 1M tokens (+51.3 vs +47.0). Three mechanisms: recursive context compression into summary DAG with lossless pointers, engine-managed parallel primitives (LLM-Map), and three-level escalation for context overflow.
>
> ---
>
> *4. GLM-5*
> ![[dairai-339077-004.jpg]]
>
> Foundation model from Zhipu AI targeting transition from vibe coding to agentic engineering. Novel asynchronous agent RL algorithms separating generation from training. DSA (Distributed Sparse Attention) compression for long-context without quality degradation. Handles project-level context, multi-file edits, and iterative development cycles.
>
> ---
>
> *5. MemoryArena*
> ![[dairai-339077-005.jpg]]
>
> Benchmark revealing that scoring well on memory recall does not mean an agent can use that memory for correct actions across sessions. Models with near-saturated performance on LoCoMo perform poorly in agentic multi-session settings. Spans web navigation, constrained planning, information retrieval, and logical reasoning with interdependent sessions.
>
> ---
>
> *6. MAPLE*
> ![[dairai-339077-006.jpg]]
>
> Separates memory, learning, and personalization into specialized sub-agents. Memory handles storage/retrieval, Learning extracts intelligence asynchronously from interaction history, Personalization applies learned knowledge in real-time within context budgets. 14.6% improvement in personalization scores, trait incorporation from 45% to 75%.
>
> ---
>
> *7. SkillsBench*
> ![[dairai-339077-007.jpg]]
>
> Evaluates whether LLM agents can generate their own procedural knowledge across 86 tasks, 11 domains, 7,308 trajectories. Curated skills boost pass rate by +16.2pp average (+51.9pp in Healthcare). Self-generated skills provide zero improvement over no skills. Skills with 2-3 focused modules outperform comprehensive docs. Smaller models with curated skills match larger models without.
>
> ---
>
> *8. LongCLI-Bench*
> ![[dairai-339077-008.jpg]]
>
> Leading agents succeed less than 20% on complex CLI tasks. Most failures occur early in task execution. Human-agent collaboration (plan injection, interactive guidance) yields greater improvements than automated self-correction alone.
>
> ---
>
> *9. CogRouter*
>
> Adaptive reasoning depth via four hierarchical cognitive levels. Qwen2.5-7B with CogRouter achieves 82.3% on agentic benchmarks, outperforming larger models while consuming fewer tokens by skipping heavy reasoning on routine steps.
>
> ---
>
> *10. Team of Thoughts*
>
> Multi-agent framework for test-time scaling through orchestrated tool calling. Calibrated orchestrator coordinates agents with different capabilities. 96.67% on AIME24, 72.53% on LiveCodeBench.
>
> *51 likes · 13 retweets · 2 replies*

[Original thread](https://x.com/dair_ai/status/2025707116653339077)
