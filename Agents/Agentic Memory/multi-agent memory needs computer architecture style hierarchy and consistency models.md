---
created: 2026-03-14
description: Position paper from UCSD/Georgia Tech arguing that multi-agent LLM memory should be framed as a computer architecture problem, with shared vs distributed paradigms, a three-layer hierarchy (I/O, cache, memory), and formal consistency models.
source: https://arxiv.org/abs/2603.10062
type: framework
---

## Key Takeaways

This paper makes a compelling analogy: as LLM agents move from single-agent to multi-agent systems, the memory bottleneck they hit looks structurally identical to what computer architects solved decades ago with [[moc - Agentic Memory|memory hierarchies]], cache coherence protocols, and consistency models.

The authors distinguish two fundamental paradigms — **shared memory** (all agents read/write a common pool like a vector store) and **distributed memory** (each agent owns local memory, syncs selectively). Most real systems sit between these extremes, which maps well to how [[context engineering is the new prompt engineering|context engineering]] works in practice: local working memory plus selectively shared artifacts.

Their three-layer hierarchy — I/O layer (ingestion/emission), cache layer (KV caches, compressed context, recent tool calls), and memory layer (full history, vector DBs, graph DBs) — reframes agent performance as an **end-to-end data movement problem**. If relevant information is stuck in the wrong layer, reasoning degrades regardless of model capability. This echoes the practical lessons from [[OpenAI cookbook demonstrates state-based long-term memory with structured profiles and session scoping|OpenAI's memory patterns]] where scoping (session vs global) determines what's accessible.

Two protocol gaps stand out. First, there's no principled protocol for **cache sharing across agents** — one agent's cached results should be transformable and reusable by another, analogous to cache transfers in multiprocessors. Second, **memory access control** is under-specified even in frameworks that support shared state: who can read what, read-only vs read-write, and what's the unit of access (document, chunk, key-value record, trace segment)?

The deepest challenge they identify is **multi-agent memory consistency** — the agent equivalent of memory consistency models in hardware. For a single agent, consistency means temporal coherence (new info integrates without contradicting established facts). For multiple agents reading and writing concurrently, you get classical problems of visibility, ordering, and conflict resolution, made harder because memory artifacts are heterogeneous (evidence, tool traces, plans) and conflicts are often semantic rather than bitwise. This connects to how [[Continual Learning Implementations Across Letta, Scout, and Serena|continual learning systems]] handle memory drift and reconciliation.

## External Resources

- [arXiv paper](https://arxiv.org/abs/2603.10062) — original position paper
- [MCP (Model Context Protocol)](https://modelcontextprotocol.io/docs/getting-started/intro) — referenced as the agent context I/O layer
- [DroidSpeak](https://arxiv.org/abs/2411.02820) — KV cache sharing for cross-LLM communication
- [MemGPT](https://arxiv.org/abs/2310.08560) — LLMs as operating systems with memory management
- [A-Mem](https://arxiv.org/abs/2502.12110) — agentic memory for LLM agents
- [Mem0](https://arxiv.org/abs/2504.19413) — production-ready scalable long-term memory

## Original Content

> [!quote]- Source Material

> # Multi-Agent Memory from a Computer Architecture Perspective: Visions and Challenges Ahead
>
> Zhongming Yu, Wentao Ni, Naicheng Yu, Mingrui Yin, Hejia Zhang, Jiaying Yang, Yujie Zhao, Jishen Zhao
> University of California, San Diego & Georgia Institute of Technology
>
> ## Abstract
>
> As LLM agents evolve into collaborative multi-agent systems, their memory requirements grow rapidly in complexity. This position paper frames multi-agent memory as a computer architecture problem. We distinguish shared and distributed memory paradigms, propose a three-layer memory hierarchy (I/O, cache, and memory), and identify two critical protocol gaps: cache sharing across agents and structured memory access control. We argue that the most pressing open challenge is multi-agent memory consistency. Our architectural framing provides a foundation for building reliable, scalable multi-agent systems.
>
> ## 1 Introduction
>
> Large language model (LLM) agents are quickly moving from "single agent" tools to multi-agent systems: tool-using agents, planner–orchestrator stacks, debate teams, and specialized sub-agents that collaborate to solve tasks. At the same time, the context these agents operate within is becoming more complex: longer histories, multiple modalities, structured traces, and customized environments. This combination creates a bottleneck that looks surprisingly familiar to computer architects: memory.
>
> In computer systems, performance and scalability are often limited not by compute but by memory hierarchy, bandwidth, and consistency. Multi-agent systems are heading toward the same wall—except their "memory" is not raw bytes, but semantic context used for reasoning. This position paper frames multi-agent memory as a computer architecture problem and highlights key protocol and consistency gaps.
>
> ## 2 Why Memory Matters: Context Is Changing
>
> LLM evaluations show that "real" context ability involves more than simple retrieval; it requires multi-hop tracing, aggregation, and sustained reasoning as context length scales. Multimodal benchmarks add images, diagrams, and videos. Structured tasks introduce executable traces and schemas. Interactive environments make environment state + execution part of the memory problem. The result is not a static prompt but a dynamic, multi-format, partially persistent memory system.
>
> - Longer context windows: Suites like RULER emphasize reasoning over long histories, not just retrieval.
> - Multimodal inputs: Benchmarks such as MMMU and VideoMME require joint reasoning over images and videos.
> - Structured data & traces: Text-to-SQL datasets like Spider and BIRD show that agents increasingly operate over structured, executable traces.
> - Customized environments: Evaluations such as SWE-bench and OSWorld stress long-horizon state tracking and grounded actions.
>
> As such, context is no longer a static prompt; it is a dynamic memory system with bandwidth, caching, and coherence constraints.
>
> *Two fundamental multi-agent memory architectures*
> ![[multi-agent-memory-arch-001.jpeg]]
>
> ## 3 Shared vs. Distributed Agent Memory
>
> Here we name two basic prototypes that mirror classical memory systems. In shared memory, all agents access a shared pool (e.g., a shared vector store or document database). In distributed memory, each agent owns local memory and synchronizes selectively.
>
> Shared memory makes knowledge reuse easy but requires coherence support; without coordination, agents overwrite each other, read stale information, or rely on inconsistent versions of shared facts. Distributed memory improves isolation and scalability but requires explicit synchronization; state divergence becomes common unless carefully managed. Most real systems sit between these extremes: local working memory with selectively shared artifacts.
>
> ## 4 An Architecture-Inspired Memory Hierarchy
>
> Computer architecture teaches a practical lesson: systems are not designed around "one memory." Instead, they are built as memory hierarchies with layers optimized for latency, bandwidth, capacity, and persistence. A useful mapping for agents is as follows:
>
> Agent I/O layer: Interfaces that ingest and emit information (audio, text documents, images, network calls). Agent cache layer: fast, limited-capacity memory for immediate reasoning (compressed context, recent tool calls, short-term latent storage such as KV caches and embeddings). Agent memory layer: large-capacity, slower memory optimized for retrieval and persistence (full dialogue history, vector DBs, graph DBs, and document stores).
>
> This framing emphasizes a key principle: agent performance is an end-to-end data movement problem. If relevant information is stuck in the wrong layer (or never loaded), reasoning accuracy and efficiency degrade. As in hardware, caching is not optional.
>
> *Agent memory hierarchy and protocol framing*
> ![[multi-agent-memory-arch-002.jpeg]]
>
> ## 5 Protocol Extensions for Multi-Agent Scenarios
>
> Architecture layers need protocols. Many systems rely on connectivity protocols, but inter-agent bandwidth remains limited by message passing. This layer is best viewed as agent context I/O, e.g. MCP. That is necessary—but not sufficient. Two missing pieces stand out.
>
> Missing piece 1: Agent cache sharing protocol. Recent work explores KV cache sharing, but we lack a principled protocol for sharing cached artifacts across agents. The goal is to enable one agent's cached results to be transformed and reused by another, analogous to cache transfers in multiprocessors.
>
> Missing piece 2: Agent memory access protocol. Agentic memory frameworks propose many strategies for maintaining and optimizing LLM agents' memory. Yet even when some frameworks support shared state, the standard access protocol (permissions, scope, granularity) remains under-specified. Key questions include: Can one agent read another's long-term memory? Is access read-only or read-write? What is the unit of access: a document, a chunk, a key-value record, or a trace segment?
>
> *Consistency model comparison from traditional memory architecture to multi-agent memory*
> ![[multi-agent-memory-arch-003.jpeg]]
>
> ## 6 The Next Frontier: Multi-Agent Consistency
>
> The largest conceptual gap is consistency. In computer architecture, consistency models specify which updates are visible to a read and in what order concurrent updates may be observed. We argue that agent memory systems require an analogous notion. For a single LLM agent, consistency demands that its memory remains temporally coherent — new information must be integrated without contradicting established facts, and retrievals must reflect the most current state. Here, consistency is a stateful property of persistent, evolving knowledge. When we move to multi-agent settings, the problem compounds: multiple agents now read from and write to shared memory concurrently, raising classical challenges of visibility, ordering, and conflict resolution.
>
> For agent memory systems, multi-agent memory consistency decomposes into two requirements: read-time conflict handling under iterative revisions, where records evolve across versions and stale artifacts may remain visible, and update-time visibility and ordering that determines when an agent's writes become observable to others and how concurrent writes may be observed in a permissible order. This is harder than classical settings because memory artifacts are heterogeneous (evidence, tool traces, plans), and conflicts are often semantic and coupled to environment state. A practical direction is to make versioning, visibility, and conflict-resolution rules explicit, so agents agree on what to read and when updates take effect.
>
> ## 7 Conclusion
>
> Many agent memory systems today resemble human memory: informal, redundant, and hard to control. To move from ad-hoc prompting to reliable multi-agent systems, we need better hierarchies, explicit protocols for cache sharing and memory access, and principled consistency models that keep shared context coherent. We believe this architecture framing is a foundational research direction for next-generation agent systems.

[Source: arxiv.org/abs/2603.10062](https://arxiv.org/abs/2603.10062)
