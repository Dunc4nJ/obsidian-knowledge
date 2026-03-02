---
created: 2026-03-02
description: Factory.ai compresses LLM conversation context using persistent anchored summaries that update incrementally, avoiding the redundancy and cost of naive full-conversation re-summarization.
source: https://factory.ai/news/compressing-context
---

## Key Takeaways

Factory's approach to context compression centers on a key insight: re-summarizing the entire conversation prefix each time you hit the context limit is wasteful. Instead, they maintain a **persistent, anchored summary** that gets incrementally updated — only the newly dropped span of messages is summarized and merged into the existing summary. This is directly relevant to the broader [[how top ai companies handle context engineering|context engineering landscape]] where different companies take distinct approaches to the compress category that [[langchain-context-engineering-for-agents|LangChain's taxonomy]] identifies.

Their dual-threshold system (T_max as the "fill line" and T_retained as the "drain line") creates a hysteresis buffer that controls compression frequency. The gap between these thresholds is a tunable tradeoff: narrow gaps mean frequent compression with better recent-context preservation but more summarization overhead; wide gaps reduce compression frequency but risk aggressive truncation.

A particularly useful framing is "minimize tokens per task, not per request." Over-compressing can create a false economy where the agent must re-fetch artifacts it previously summarized away, adding more inference calls than the compression saved. This is especially true in iterative workflows like code review.

Factory identifies four categories of information that must survive compression in coding sessions: session intent, high-level play-by-play, artifact trail, and breadcrumbs (file paths, function names). This maps well to structured memory approaches seen across the industry.

The article closes by arguing that reactive compression (triggered by token thresholds) should evolve toward **proactive memory curation** — agents recognizing natural breakpoints and compressing completed phases before being forced to. Sub-agent architectures where parent agents retain only final results from child agents are one form of this.

## External Resources

- [Factory.ai](https://factory.ai/) — AI-powered software development platform

## Original Content

> [!quote]- Source Material
>
> By Theo Luan - July 21, 2025 - 4 minute read
>
> Engineering / Research
>
> LLMs attend only to the tokens in their current prompt. Because every model enforces a finite context window, extended conversations and multi-step workflows eventually exceed that limit. Our strategy for retaining, selecting, and compressing prior turns is a major lever on inference quality, latency, and cost.
>
> ## Compressing Context
>
> LLMs attend only to the tokens in their current prompt. Because every model enforces a finite context window, extended conversations and multi-step workflows eventually exceed that limit. Our strategy for retaining, selecting, and compressing prior turns is a major lever on inference quality, latency, and cost.
>
> Factory maintains a lightweight, persistent conversation state: a rolling summary of the information that actually matters. We persist anchored summaries of earlier turns and, when compression is needed, summarize only the newly dropped span and merge it into the persisted summary.
>
> ## Naive Approach
>
> A simple way to stay within an LLM's context window is to compress the conversation on-the-fly with a summarization model.
>
> Whenever we need to make an inference call for the top-level agent:
>
> 1. Check whether the full conversation exceeds our compression threshold.
> 2. If it does, determine how many messages we are able to keep from the end, keep this suffix, and summarize the rest.
>
> Though seemingly straightforward, this method has significant limitations in practice:
>
> - Redundant re-summarization: each request triggers a full re-summarization of the entire conversation prefix once we reach the compression threshold, even though most of it was already summarized in the previous turn.
> - Growing cost: the span requiring summarization grows with each turn, causing summarization cost and latency to increase linearly with conversation length.
> - Forces hierarchical summarization: current SOTA context length is ~1M tokens. Past this threshold, a single-pass summary is impossible - forcing us to use a multi-stage chunking approach, which further compounds latency and cost.
> - Perpetual edge-of-limit: once we start summarizing, we run permanently near max context, which empirically degrades response quality.
>
> ## Our Approach
>
> Rather than regenerating the entire summary per request, Factory systematically maintains a persistent summary, updating it incrementally whenever we truncate old messages. Each summary update is anchored to a specific message (we will call these anchor messages), and captures the conversation up to that message.
>
> Our iterative approach uses two main thresholds:
>
> - T_max: When the total context reaches this count, we compress. Think of it as "fill line", or the compression pre-threshold.
> - T_retained: Max tokens retained during the compression process. Always lower than T_max - this is the "drain line", or the compression post-threshold.
>
> ### Procedure
>
> For the sake of simplicity, we will reason only over the conversation tokens. In practice, everything else that must go into the prompt each turn (system prompts, tool schemas, metadata, and any reserved output budget) must be factored in.
>
> We represent the conversation as an ordered sequence of messages [m₁, m₂, …, mₙ]. We maintain anchor points a_j marking messages m_{a_j} that correspond to persisted summaries S_{a_j}.
>
> We also define T_summary to be the maximum token size of any given summary S, enforced by our summarize and update functions.
>
> *Steps to compress context*
> ![[factory-compressing-context-001.png]]
>
> ### Tuning Our Thresholds
>
> The two thresholds create a classic tradeoff between performance and quality, with some additional complexity around compression frequency.
>
> (T_max): Higher compression thresholds preserve more context but impose linear cost scaling:
>
> - Quality: More tokens provide richer context for reasoning, reducing the likelihood of redundant actions or context loss. However, empirical evidence suggests diminishing returns beyond certain limits, with some models showing degraded performance at maximum context lengths.
> - Cost & Latency: Every token costs money and time. A 50% increase in average context length translates directly to 50% higher inference costs.
>
> (T_retained): The gap between T_max and T_retained controls how often compression occurs, creating a secondary tradeoff:
>
> - Narrow gaps (T_retained ≈ T_max) trigger frequent compression, causing:
>   - Higher summarization overhead (more inference calls)
>   - Frequent prompt cache invalidation as message history is truncated
>   - But better preservation of recent context
> - Wide gaps (T_retained ≪ T_max) reduce compression frequency but risk aggressive truncation of potentially relevant information
>
> The optimal configuration depends heavily on the shape of your task. Debugging sessions benefit from higher thresholds due to intricate state dependencies, while simple Q&A can operate effectively with more aggressive compression.
>
> ### The False Economy of Over-Compression
>
> Cutting context too aggressively can backfire. Once key artifacts are summarized away, the agent must re-fetch them, adding extra inference calls and latency. In workflows that revisit the same information (e.g., iterative code review, implementations within complex systems), those round-trips can outweigh the token savings.
>
> Our aim is to minimize tokens per task, not per request. Ideally, we keep just enough context to avoid repeated work while still respecting the model's effective limits.
>
> ### Prompting: What Must Survive
>
> Certain information is obviously more important to retain. "Important" varies by context and domain.
>
> For Factory's synchronous chat-based coding sessions, for example, we must preserve:
>
> - Session Intent: What did the user create the session for? What requirements have been stated? What is our ideal outcome
> - High Level Play-By-Play: "User requests refactor → Assistant calls CLI … → Refactors files A,B,C to … → User requests clarification …"
> - Artifact Trail: Which files were created, modified, or deleted? What were the key changes? When a test suite was run, what passed and what failed?
> - Breadcrumbs, or references for reconstructing context for truncated artifacts. File paths, function names, and key identifiers, which the agent can query to re-access outputs from previous actions.
>
> ## Proactive Memory Curation
>
> The compression strategy we've outlined is fundamentally reactive. Our agent scaffolding mechanically shrinks history based on token thresholds. While necessary and effective, this approach doesn't scale with advancing model capabilities.
>
> Consider an agent that has just completed a complex debugging session. As soon as the error is resolved, much of the intermediate trial-and-error becomes noise for future turns. Rather than waiting to hit a token threshold, the agent should proactively compress its work.
>
> The future lies in proactive memory management, where agents intelligently choose when and what to compress. This takes several forms:
>
> 1. Self-directed compression: Agents can recognize natural breakpoints in their work and summarize completed phases.
> 2. Structured working memory: Agents maintain persistent, structured artifacts like task lists or decision logs.
> 3. Sub-agent architectures: Retrieval agents gather inputs, parent agents retain only final results.
>
> These capabilities already exist in modern AI systems. The key is recognizing them as part of a broader memory strategy. As models improve at self-reflection and planning, we expect proactive curation to become the norm - shifting from "compress when forced" to "compress when optimal."
>
> [Source](https://factory.ai/news/compressing-context)
