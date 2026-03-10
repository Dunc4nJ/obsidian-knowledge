---
created: 2026-03-10
description: Memex introduces indexed experience memory for LLM agents — compact in-context summaries with stable indices pointing to a full-fidelity external archive, trained via RL to learn when to compress, what to index, and when to retrieve.
source: https://arxiv.org/abs/2603.04257
type: paper
authors:
  - Zhenting Wang
  - Huancheng Chen
  - Jiayun Wang
  - Wei Wei
arxiv: "2603.04257"
---

## Abstract

Large language model (LLM) agents are fundamentally bottlenecked by finite context windows on long-horizon tasks. As trajectories grow, retaining tool outputs and intermediate reasoning in-context quickly becomes infeasible. Existing solutions typically shorten context through truncation or running summaries, but these methods are fundamentally lossy because they compress or discard past evidence itself. We introduce Memex, an indexed experience memory mechanism that instead compresses context without discarding evidence. Memex maintains a compact working context consisting of concise structured summaries and stable indices, while storing full-fidelity underlying interactions in an external experience database under those indices. The agent can then decide when to dereference an index and recover the exact past evidence needed for the current subgoal. We optimize both write and read behaviors with our reinforcement learning framework MemexRL, using reward shaping tailored to indexed memory usage under a context budget. Empirically, on challenging long-horizon tasks, Memex agent trained with MemexRL improves task success while using a significantly smaller working context.

## Key Takeaways

The core insight is that existing memory approaches for long-horizon agents fall into a false dichotomy: either keep everything in context (which overflows) or summarize lossy (which discards evidence). Memex escapes this by maintaining a compact *indexed summary* in context — a pointer-heavy state with stable keys — while archiving full-fidelity artifacts in an external key-value store. This mirrors how humans use bookmarks and file names as retrieval cues without holding entire documents in working memory, echoing the [[four memory layers serve different knowledge types]] principle where different storage tiers serve different retrieval patterns.

The RL training framework (MemexRL) is what makes this work in practice rather than remaining a hand-engineered heuristic. They treat CompressExperience and ReadExperience as first-class tool calls in the same action space as environment tools, then train with GRPO using three memory-specific penalties: context overflow, redundant tool calls, and format errors. The key training innovation is *segmented trajectory processing* — when compression happens, the trajectory is split at compression boundaries and each segment trains independently but shares the terminal reward. This preserves credit assignment across compression events, so the model can learn that a well-structured index map at step 10 enabled a precise retrieval at step 50. This connects to the [[AMA-Bench evaluates long-horizon memory for agentic applications using real and synthetic trajectories]] finding that memory systems need evaluation on real agentic trajectories, not just chatbot dialogues.

The automatic compression triggering is a soft mechanism rather than a hard cutoff — the system injects context status indicators (token counts and threshold warnings) into observations, and the agent learns *when* to compress as a skill rather than following a fixed rule. Through RL, agents learn to compress proactively at natural semantic boundaries rather than waiting until forced truncation degrades performance. This approach is complementary to the strategies described in the [[openai-session-memory-cookbook|OpenAI session memory cookbook]] where trimming and compression are system-imposed rather than agent-learned.

The theoretical analysis establishes two key properties: (1) if the indexed summary is B-bounded decision-sufficient, a Memex policy can match a full-context optimal policy using at most B dereferences per step, and (2) the working context stays bounded even as full message history grows without bound, yielding unbounded compression ratios. While the theory doesn't guarantee MemexRL always learns such summaries, it characterizes when the architecture is sufficient.

Empirically, on a modified (harder) ALFWorld benchmark, MemexRL improved task success from 24% to 86% while reducing peak working context from ~17K to ~9.6K tokens — a 3.5x success improvement with 43% less context. The learned behavior is telling: after training, compress calls decreased from 6.5 to 3 per episode while retrieve calls increased from 1 to 6-7. The agent learned to compress selectively and rely heavily on precise retrieval rather than repeatedly rewriting context.

*Figure 1: Memex agent loop overview*
![[memex-rl-_page_1_Figure_1.jpeg]]

## External Resources

- [Slime RL framework](https://github.com/THUDM/slime) — the open-source LLM RL framework used for MemexRL training
- [ALFWorld](https://arxiv.org/abs/2010.03768) — the household environment benchmark used for evaluation (modified harder version)
- [MemGPT](https://arxiv.org/abs/2310.08560) — earlier work on LLM memory as an OS-like system, cited as inspiration
- [SUPO](https://arxiv.org/abs/2510.06727) — concurrent work on summarization in multi-turn tool-use pipelines
- [FoldGRPO](https://arxiv.org/abs/2510.11967) — concurrent work on structured context folding for long-horizon agents

## Original Content

> [!quote]- Full Paper Text (GPU-extracted via marker-pdf)
>
> *Figure 1: Memex agent loop overview — CompressExperience replaces a long tool-use trajectory with a compact indexed summary, while ReadExperience dereferences an index to retrieve exact content*
> ![[memex-rl-_page_1_Figure_1.jpeg]]
>
> **1. Introduction**
>
> Large language model (LLM) agents are increasingly deployed as general-purpose problem solvers that plan, call tools, and interact with users over extended periods. Unlike single-shot prompting or short multi-turn chats, long-horizon agents are asked to execute workflows spanning dozens to hundreds of steps and tool calls, often producing large volumes of intermediate observations, tool outputs, and reasoning traces along the way.
>
> This creates a fundamental bottleneck for long-horizon agents. Although modern LLMs support increasingly large context windows, those windows remain finite, while agent trajectories naturally keep growing as observations, tool outputs, and intermediate reasoning are appended over time. Existing systems mostly address this pressure through static context engineering, such as large rolling prompts, heuristic summarization, or related memory heuristics. These approaches can reduce active working context, but they usually do so by either truncating substantial portions of past interactions or compressing them into lossy summaries that are difficult to faithfully recover later.
>
> A natural alternative is to log everything into an external memory and retrieve past content by semantic similarity when needed. However, in long-horizon tool use, this design is often brittle. When memory consists of a large pool of noisy, near-duplicate fragments, retrieval becomes ambiguous, and the model must repeatedly re-parse loosely structured history. More fundamentally, similarity-based retrieval does not specify how the agent should organize its own experience.
>
> In this work, we argue that long-horizon LLM agents need a memory mechanism that *compresses* context without discarding evidence. We instantiate this idea with Memex, whose core component is Indexed Experience Memory.
>
> **3. Memex Agent**
>
> **3.1. Overview**
>
> The key component of Memex agent is the Indexed Experience Memory, which keeps a compact in-context state while preserving full-fidelity artifacts in an external experience store under stable indices. The agent periodically rewrites its working context into a short, actionable indexed summary and accesses archived evidence only through explicit index dereferencing when needed.
>
> **3.2. Indexed Experience Memory**
>
> We maintain the agent context window M and an external experience store D: index → content, a key–value database accessed by explicit index dereferencing.
>
> **Definition 1** (Indexed Summary): Given an external experience store D, an Indexed Experience Summary σ is an in-context state σ = (s, I), where s is a compact, actionable progress state, and I is a finite set of pairs I ≜ {(index, description)}, where index ∈ dom(D) is a stable index and description is a summarized descriptor.
>
> **Definition 2** (Indexed Experience Memory): Let M denote the agent's context window. An Indexed Experience Memory is a pair (IndexedSummary, D) with:
> - (i) In-context indexed summary recording actionable progress and an index map binding descriptions to indices in D
> - (ii) External Store D: index → content mapping stable indices to archived content blocks
> - (iii) Compression Operation CompressExperience(IndexedSummary, MemoryBlocks) — archives content into D and rewrites working context to M ← [m₀, u, IndexedSummary]
> - (iv) Read Operation ReadExperience(index) — dereferences archived block o ← D[index] and appends to working context
>
> The content in each memory block supports two modes: (a) explicit authoring, where the model writes content directly; and (b) anchor-based extraction, where the model specifies three short text anchors (start_anchor, mid_anchor, end_anchor) that uniquely identify a span within the current conversation.
>
> **Algorithm 1: Memex Agent Loop**
> - Initialize M ← [m₀, u], D ← ∅
> - At each step: append ContextStatus(M, τ), agent emits thinking and tool call
> - If CompressExperience: archive blocks to D, rewrite M ← [m₀, u, IndexedSummary]
> - If ReadExperience(index): retrieve o ← D[index], append to M
> - If Finish: return answer
> - Otherwise: execute tool, append observation
>
> **3.3. MemexRL: Learning Indexed Experience Memory with RL**
>
> We learn memory behaviors jointly with task-solving behaviors using reinforcement learning. The reward design combines task success with three memory-efficiency penalties:
>
> R = R_task − P_context − P_redundancy − P_format
>
> - Context overflow penalty: accumulates overflow tokens beyond threshold τ across all T steps
> - Redundant tool call penalty: counts identical (tool name, arguments) tool calls
> - Format error penalty: counts malformed tool calls
>
> **Segmented Trajectory Processing**: When compression occurs, the trajectory is segmented at compression boundaries. Each segment is processed as an independent training sample while all segments share the same terminal reward R, preserving credit assignment through GRPO advantage estimation.
>
> **Automatic Compression Triggering**: A soft mechanism that monitors context status and prompts the agent to compress voluntarily, transforming context management from a system-enforced constraint into a learnable skill.
>
> **4. Theoretical Analysis**
>
> **Proposition 1** (Memex can match a full-context optimal policy): If σ_t is B-bounded decision-sufficient for every step t, there exists a Memex policy π_IEM using at most B ReadExperience calls per step such that J(π_IEM) = J(π*).
>
> **Proposition 2** (Memex keeps working context bounded): Under summary length ≤ τ_σ, dereferenced indices ≤ B, and block length ≤ L: C_t^work ≤ τ_σ + BL. The compression ratio ρ_t grows without bound as full history grows.
>
> *Figure 2: Task success rates during training — improves from ~20% to over 90%*
> ![[memex-rl-_page_10_Figure_1.jpeg]]
>
> *Figure 3: Total penalty during training — decreases from -0.4 to ~-0.1*
> ![[memex-rl-_page_10_Figure_3.jpeg]]
>
> **5. Empirical Results**
>
> Model: Qwen3-30B-A3B-Thinking-2507 (MoE, ~30B total params, ~3B active per token)
>
> Environment: Modified harder ALFWorld with hidden admissible commands, hidden initial observation, limited look (once per episode), and summary truncation (300 tokens forcing use of db_blocks).
>
> Training: INT4 quantization for inference, QAT for backward pass, context window 32K, penalty threshold 8K, batch size 32, GRPO group size 8.
>
> *Figure 4: MemexRL effectiveness — (a) success rate 24.2% → 85.6%, (b) peak working context 16,934 → 9,634 tokens*
> ![[memex-rl-_page_11_Figure_1.jpeg]]
>
> *Figure 4b: Peak working context reduction*
> ![[memex-rl-_page_11_Figure_2.jpeg]]
>
> *Figure 5: Memory tool usage — (a) Compress calls decrease 6.5 → 3, (b) Retrieve calls increase 1 → 6-7*
> ![[memex-rl-_page_12_Figure_1.jpeg]]
>
> ![[memex-rl-_page_12_Figure_2.jpeg]]
>
> The behavioral shift shows MemexRL does not merely encourage more frequent compression. The learned policy compresses more selectively and increasingly relies on explicit retrieval from the external experience store. RL shifts the agent from repeatedly rewriting context toward building a reusable indexed memory that can be dereferenced precisely when needed.
>
> [Source: Memex(RL): Scaling Long-Horizon LLM Agents via Indexed Experience Memory](https://arxiv.org/abs/2603.04257)
