---
created: 2025-03-22
description: Supermemory's ASMR technique uses parallel agentic search agents instead of vector databases for memory retrieval, hitting 99% on LongMemEval by replacing embedding similarity with active cognitive reasoning over structured knowledge extractions.
source: https://x.com/DhravyaShah/status/2035517012647272689
type: learning
---

## Key Takeaways

The headline result — ~99% on LongMemEval — is striking, but the architectural insight matters more: **replacing vector search with agentic retrieval agents** was the single biggest unlock. This directly validates [[agentic search with grep and full-file loading replaces RAG when context windows are large enough|the broader thesis that agentic search displaces traditional RAG]], now extended to the memory domain specifically. When the problem is temporal reasoning over contradictory information across sessions, semantic similarity matching fundamentally cannot distinguish an old fact from a new correction.

The ASMR (Agentic Search and Memory Retrieval) architecture is refreshingly simple: no vector database, no embeddings, entirely in-memory. Three parallel observer agents ingest sessions and extract structured knowledge across six vectors (Personal Info, Preferences, Events, Temporal Data, Updates, Assistant Info). Three parallel search agents then actively reason over these findings when a query arrives — one for direct facts, one for contextual implications, one for temporal reconstruction. This parallels [[context agents should navigate heterogeneous sources natively instead of flattening everything into vector search|the context-agent pattern of navigating native data structures rather than flattening into vectors]].

The answering stage uses ensemble specialization: 8 specialized prompt variants (Precise Counter, Time Specialist, Context Deep Dive, etc.) running in parallel achieved 98.60%, while a 12-variant Decision Forest with majority voting hit 97.20%. The key difference: the 8-variant approach counts success if *any* path finds the answer (oracle), while the 12-variant approach produces a single authoritative answer via aggregation. Both massively outperform single-prompt approaches, reinforcing that [[Everything is Context - Agentic File System Abstraction for Context Engineering|specialization beats generalization]] for complex retrieval tasks.

Important caveats the author is transparent about: this is experimental, not yet in production Supermemory. The LongMemEval benchmark (115k+ token conversation histories) is rigorous but still synthetic. Latency implications are acknowledged but not detailed. The real test will be translating these pure-agent retrieval techniques into production at scale. The connection to [[Cognee - Knowledge Engine for AI Agent Memory|knowledge-graph-based memory systems like Cognee]] is worth watching — structured extraction (what ASMR does) vs graph construction may converge.

The claim "agent memory is now probably a solved problem" is bold. LongMemEval tests retrieval accuracy but not the harder problems: knowing *when* to remember, managing memory growth over months/years, and privacy-aware forgetting. Still, 99% on a benchmark designed to be hard is a meaningful signal that the retrieval bottleneck may be cracking.

## External Resources

- Supermemory GitHub: <https://github.com/supermemoryai>
- LongMemEval benchmark (referenced in the post)
- Open-source release promised for early April 2026

## Original Content

> [!quote]- Source Material
>
> **@DhravyaShah (Dhravya Shah)** — Sun Mar 22, 2026
> 3,279 likes · 346 retweets · 218 replies
>
> *Article header: We broke the frontier in agent memory*
> ![[dhravyashah-272689-001.jpg]]
>
> Agent memory might be completely solved now.
>
> In a few years, BILLIONS of agents will be highly personalized and specialized per user - constantly learning and evolving on everything we do. This is why we've been researching about AI memory for years now. What happens when we finally perfect it?
>
> A few months ago, we published our first research report showing Supermemory achieving ~85% on LongMemEval-s result that put us ahead of every publicly benchmarked memory system at the time. Today, we're publishing a new result: ~99% on LongMemEval_s.
>
> To be absolutely clear upfront: this is not in our main production Supermemory engine (yet). Rather, this blog covers a new, highly experimental agentic flow we built to see exactly how far we could push the absolute limits of memory retrieval and reasoning, independent of our core production constraints. A few months of research got us here.
>
> This is how we got there. Introducing our new technique: ASMR (Agentic Search and Memory Retrieval)
>
> This technique is:
> - Really easy to implement
> - Does not require a Vector Database OR embeddings and can be done completely in-memory
> - This means it can be embedded into other systems, even things like robots.
>
> **Introduction**
>
> LongMemEval is one of the most rigorous publicly available benchmarks for long-term memory. Unlike benchmarks that test simple retrieval over short contexts, LongMemEval is designed to simulate the chaos of real production environments: 115k+ token conversation histories, contradictory information, events spread across multiple sessions, and questions that require reasoning about time.
>
> The reason most memory systems score poorly is usually retrieval — not reasoning. Even when recall is high, if there's a lot of noise with retrieval, the LLM might struggle to use it. The problem is getting only the right information into the context window in the first place, and harder still: knowing when a retrieved fact is stale and a newer version supersedes it.
>
> To solve this, we stepped away from traditional RAG and built a multi-agent orchestrated pipeline.
>
> **Setup and Experimental Architecture**
>
> *Architecture diagram showing parallel observer and search agents*
> ![[dhravyashah-272689-002.jpg]]
>
> Standard vector search is good in general. However, it falls apart when dealing with the nuance of dense, multi-session temporal data. Semantic similarity matching cannot reliably distinguish between an old fact and a new correction. To tackle the complexities of LongMemEval, we had to rethink our ingestion and retrieval pipeline from the ground up, replacing vector math with active agentic reasoning.
>
> 1. **Parallel Orchestration and Ingestion (Observer Agents)**
>
> Instead of chunking and embedding user sessions, we deployed an agent orchestrator utilizing 3 parallel reader (observer) agents (powered by Gemini 2.0 Flash). These agents read through raw sessions concurrently (e.g., Agent 1 takes sessions 1, 3, 5; Agent 2 takes 2, 4, 6).
>
> Their goal is targeted knowledge extraction across six vectors: Personal Information, Preferences, Events, Temporal Data, Updates, and Assistant Info. These structured findings are then stored natively and mapped to their source sessions.
>
> 2. **Active Agentic Retrieval (Search Agents)**
>
> When a question arrives, we do not query a vector database. Instead, we deploy 3 parallel search agents. These agents actively read and reason over the stored findings, each with a specialized focus:
> - Agent 1: Searches for direct facts and explicit statements.
> - Agent 2: Looks for related context, social cues, and implications.
> - Agent 3: Reconstructs temporal timelines and relationship maps.
>
> The orchestrator compiles the findings from all three search agents, pulling verbatim session excerpts for detail verification.
>
> 3. **The Agent-Orchestrated Answering Ensembles**
>
> *Results comparison table*
> ![[dhravyashah-272689-003.png]]
>
> Run 1: The 8-Variant Ensemble (98.60% Accuracy) — routed retrieved context through 8 highly specialized prompt variants running in parallel. If any of the 8 distinct reasoning paths successfully arrived at the ground truth, the question was marked correct.
>
> Run 2: The 12-Variant Decision Forest (97.20% Accuracy) — 12 specialized agents independently answered the prompt, then an Aggregator LLM synthesized using majority voting, domain trust, and conflict resolution.
>
> *Benchmark comparison chart*
> ![[dhravyashah-272689-004.jpg]]
>
> **What we learnt and What's Next**
>
> 1. Agentic Retrieval Beats Vector Search: Ditching vector embeddings for active search agents was the single biggest unlock. Agents actively searching for context eliminated the semantic similarity trap that causes traditional RAG to fail on temporal changes and updates.
>
> 2. Parallel Processing is Critical: Splitting the ingestion and retrieval workloads across multiple dedicated agents dramatically improved both the speed and granularity of fact extraction.
>
> 3. Specialization Beats Generalization: Routing context through dedicated specialist agents vastly outperforms any single master prompt.
>
> We will be open-sourcing the complete code for this experimental agentic flow soon. In exactly 11 days (beginning of April), we will be publishing and open sourcing everything about this new agent memory system.
>
> Check out our github https://github.com/supermemoryai

[Source: https://x.com/DhravyaShah/status/2035517012647272689](https://x.com/DhravyaShah/status/2035517012647272689)
