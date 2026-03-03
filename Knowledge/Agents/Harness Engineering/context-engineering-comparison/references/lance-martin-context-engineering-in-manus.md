---
created: 2026-03-02
description: Lance Martin's analysis of Manus's context engineering distills their approach into three strategies — reduce (compact stale results), isolate (sub-agents for context separation), and offload (push tools and results to sandbox filesystem) — with a Bitter Lesson warning that agent harnesses can limit performance as models improve.
source: https://rlancemartin.github.io/2025/10/15/manus/
type: framework
---

## Key Takeaways

Lance Martin's framing organizes [[manus-context-engineering|Manus's six principles]] into three clean strategies: reduce context (compact stale tool results into references, summarize when compaction plateaus), isolate context (use sub-agents with their own windows to prevent context pollution), and offload context (push tool definitions and results to the sandbox filesystem). This is more actionable than Manus's original blog post because it maps their techniques to general patterns other teams can adopt.

The multi-agent design philosophy is pragmatic rather than anthropomorphic: Manus avoids dividing labor by human roles (designer, engineer, PM) because LLMs don't share human cognitive limitations. Instead, sub-agents exist to isolate context. The planner-executor pattern — a planner assigns tasks, a knowledge manager tracks filesystem state, executors perform work — mirrors how [[anthropic-effective-harnesses|Anthropic's multi-agent researcher]] uses subagents with isolated contexts. The key decision is whether to share full context with sub-agents (complex tasks) or just pass instructions (simple tasks).

The Bitter Lesson warning is the most important takeaway: if your agent harness is getting more complex while models get better, something is wrong. Manus tests across model strengths to ensure their harness doesn't limit performance. Peak suggested that if performance doesn't improve with stronger models, your harness may be hobbling the agent. This is exactly the dynamic the thread author identifies as the industry pattern — "the teams shipping the best agents keep simplifying."

## External Resources

- [Manus webinar with Peak Ji](https://youtu.be/6_BcCthVvb8) — Full discussion video
- [Lance Martin's slides](https://drive.google.com/file/d/1QGJ-BrdiTGslS71sYH4OJoidsry3Ps9g/view) — Presentation slides
- [Peak Ji's slides](https://docs.google.com/presentation/d/1Z-TFQpSpqtRqWcY-rBpf7D3vmI0rnMhbhbfv01duUrk/edit) — Manus architecture slides
- [Chroma context rot study](https://research.trychroma.com/context-rot) — Research on performance degradation with growing context

## Original Content

> [!quote]- Source Material
> **Context Engineering in Manus**
> Lance Martin — October 15, 2025
>
> Manus is one of the most popular general-purpose consumer agents. The typical Manus task uses 50 tool calls. Without context engineering, these tool call results would accumulate in the LLM context window. As the context window fills, many have observed that LLM performance degrades.
>
> **Context Engineering Approaches:**
> Each Manus session uses a dedicated cloud-based virtual machine, giving the agent a virtual computer with a filesystem, tools to navigate it, and the ability to execute commands.
>
> Three primary strategies: Reduce Context, Offload Context, Isolate Context.
>
> **Context Reduction:** Tool calls have "full" and "compact" representations. Full version stored in filesystem, compact version (reference/file path) in context. Compaction swaps older tool results for compact versions. When compaction reaches diminishing returns, apply schema-based summarization using full results. Similar to Anthropic's context editing feature.
>
> **Context Isolation:** Manus avoids anthropomorphized divisions of labor. Primary goal of sub-agents is to isolate context. Uses planner (assigns tasks), knowledge manager (reviews conversations, determines what to save), and executor sub-agents. For simple tasks: planner passes instructions via function call. For complex tasks: planner shares full context with sub-agent. Sub-agents have a submit_results tool with constrained decoding.
>
> **Context Offloading — Tools:** Manus uses < 20 atomic functions. Rather than bloating function calling, Manus offloads most actions to the sandbox layer via Bash tool. MCP tools exposed through CLI. Similar to Claude's skills feature.
>
> **Context Offloading — Tool Results:** Tool results offloaded to filesystem. Uses basic utilities (glob, grep) to search without vectorstores.
>
> **Model Choice:** Task-level routing (Claude for coding, Gemini for multimodal, OpenAI for math/reasoning). KV cache efficiency is central to cost. Distributed KV cache infrastructure challenging with open source but well-supported by frontier providers.
>
> **Build with the Bitter Lesson in Mind:** The agent's harness can limit performance as models advance. Run agent evaluations across varying model strengths. If performance doesn't improve with stronger models, your harness may be hobbling the agent. Manus has been refactored 5 times since launch. Simple, unopinionated designs adapt better to model improvements.
>
> [Original post](https://rlancemartin.github.io/2025/10/15/manus/)
