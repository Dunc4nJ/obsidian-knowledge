---
created: 2025-07-27
description: "Chroma Context-1 is a 20B parameter agentic search model that achieves frontier-level retrieval by decomposing queries, iteratively searching, and selectively pruning its own context window to stay within a bounded token budget."
source: "https://www.trychroma.com/research/context-1"
type: research
---

## Key Takeaways

Chroma's Context-1 demonstrates that you don't need a frontier-scale model for multi-hop agentic search — a purpose-trained 20B model reaches the Pareto frontier on both cost and latency. The core trick is **self-editing context**: rather than letting the context window fill with noise over multiple search turns, the agent actively prunes irrelevant chunks to free capacity for further exploration. This directly addresses the [[context agents should navigate heterogeneous sources natively instead of flattening everything into vector search|context rot problem]] that degrades retrieval quality as agents accumulate documents.

The training methodology is a staged curriculum that shifts from recall-focused to precision-focused rewards. Early in RL training, the agent is rewarded for broad exploration (recall weighted 16x over precision); as training progresses, the reward anneals toward precision, teaching selective retention. This is trained via CISPO (a GRPO variant that prevents entropy collapse) on synthetically generated multi-hop tasks across web, finance, legal, and email domains. Despite only training on three domains, the model generalizes to the held-out email domain and public benchmarks — suggesting that [[searching more and thinking less improves agentic efficiency and generalization|query decomposition and iterative refinement are transferable skills]].

The agent harness uses a deduplication mechanism that tracks every chunk ID seen across prior searches, forcing each new search to surface fresh information. Combined with a soft/hard token budget and the prune tool, this creates a natural curriculum during inference: early turns allow unrestricted search, then pressure builds to prune, and eventually only pruning or concluding is allowed. Context-1 achieves 0.941 prune accuracy (up from 0.824 in the base model) and averages 2.56 parallel tool calls per turn vs 1.52 for the base.

The [[mixedbread search v3 nearly closes the oracle gap on agentic retrieval benchmarks using late interaction multimodal encoding|late interaction]] direction mentioned in future work is notable: jointly training a ColBERT-style retrieval model alongside the search policy could let the embedding model co-adapt with the agent's actual query patterns, rather than treating retrieval as a fixed black box. This connects to the broader trend of [[ColBERT-style semantic search beats grep 70 percent of the time for coding agents while using fewer tokens|ColBERT-style approaches]] showing strong results in agentic settings.

The 4x parallel rollout configuration (running 4 independent searches and fusing via RRF) is particularly clever — it remains cheaper than a single frontier model call while matching or exceeding their retrieval quality. On BrowseComp-Plus, Context-1 (4x) hits 0.96 final answer found vs 0.87-0.99 for frontier models.

The synthetic data pipeline uses extraction-based verification rather than opinion-based relevance scoring, achieving >80% alignment with human labels. The key insight: reduce human verification to checking whether extracted document quotes support extracted clue quotes, rather than reading entire documents.

## External Resources

- [Context-1 Model Weights (Apache 2.0)](https://huggingface.co/chromadb/context-1)
- [Data Generation Pipeline](https://github.com/chroma-core/context-1-data-gen)
- [gpt-oss-20B Base Model](https://arxiv.org/abs/2508.10925)
- [CISPO / ScaleRL](https://arxiv.org/abs/2510.13786)
- [WebExplorer](https://arxiv.org/abs/2509.06501) — 8B web agent trained via SFT+RL
- [SWE-grep (Cognition)](https://cognition.ai/blog/swe-grep) — small model RL for parallel agentic code search
- [Search-R1](https://arxiv.org/abs/2503.09516) — RL-only multi-turn search without SFT warmup
- [BrowseComp-Plus](https://arxiv.org/abs/2508.06600) — reproducible deep research benchmark
- [Context Rot (Chroma Research)](https://research.trychroma.com/context-rot)

> [!quote]- Original Content
>
> **Chroma Context-1: Training a Self-Editing Search Agent**
>
> *Source: <https://www.trychroma.com/research/context-1>*
>
> *Pareto frontier charts — latency and cost vs retrieval performance*
> ![[chroma-context1-001.png]]
> ![[chroma-context1-002.png]]
>
> ## Introduction
>
> Using search systems in conjunction with a large language model (LLM) is a common paradigm for enabling language models to access data beyond their training corpus. This approach, broadly known as retrieval-augmented-generation (RAG), has traditionally relied on single-stage retrieval pipelines composed of vector search, lexical search, or regular expression matching, optionally followed by a learned reranker. While effective for straightforward lookup queries, these pipelines are fundamentally limited: they assume that the information needed to answer a question can be retrieved in a single pass.
>
> In practice, many real-world queries are not satisfiable in a single-stage. Answering a question often requires a chain of intermediate searches in which the output of one search informs the next, a process known as a multi-hop retrieval.
>
> To solve this, leveraging LLMs for multi-turn agentic search has become a viable approach to answering multi-hop retrieval queries. Rather than issuing a single query, an LLM agent iteratively decomposes a high-level question into subqueries, retrieves evidence, and refines its search strategy across multiple turns. Concurrently, it has been shown that smaller-parameter language models, trained on moderate-scale corpora, can serve as effective search agents with performance comparable to substantially larger models. Running frontier-scale models for multi-turn search incurs high cost and latency, which motivates offloading this task to a smaller, purpose-trained model.
>
> A key factor driving the cost and latency of agentic search is the growth of the context window. As the agent gathers information over multiple turns, its context window fills rapidly with retrieved documents, many of which may be tangential or redundant. This bloated context not only increases computational cost but can also degrade downstream performance due to increasing the presence of distracting information. One promising direction to address this is self-editing context, in which the agent actively decides which retrieved information to retain and which to discard, allowing it to continue long-horizon search tasks more efficiently and more accurately within a bounded context window.
>
> Building on these insights, we trained Chroma Context-1, a 20B parameter agentic search model on over eight thousand synthetically generated tasks. Context-1 achieves retrieval performance comparable to frontier LLMs at a fraction of the cost and up to 10x the inference speed. Context-1 operates as a retrieval subagent: rather than answering questions directly, it returns a ranked set of supporting documents to a downstream answering model, cleanly separating search from generation. The model is trained to decompose a high-level query into subqueries and iteratively search a corpus across multiple turns. As the agent's context window fills, it selectively discards irrelevant results to free capacity and reduce noise for further exploration.
>
> In this work we present our synthetic data generation pipeline, agent harness, and training methodology alongside a comprehensive evaluation of Context-1 across a range of retrieval benchmarks. Our results demonstrate that a purpose-trained 20B model can reach the Pareto frontier of retrieval performance with respect to cost and latency, matching or exceeding frontier models that are orders of magnitude larger at a fraction of the compute.
>
> ## Key Techniques
>
> - A staged training curriculum that first optimizes for recall before shifting toward precision, training the agent to progressively narrow from broad retrieval to selective retention. Weights released under Apache 2.0.
> - A context management strategy in which the agent selectively edits its own context during search, discarding irrelevant passages to free context capacity for further exploration and to reduce the effects of context rot.
> - A scalable synthetic task generation pipeline that uses a human-aligned LLM judge to minimize the need for human annotation while maintaining task quality. Full codebase released.
>
> ## Related Work
>
> The limitations of single-shot retrieval have driven substantial exploration into agentic search systems, in which reasoning is interleaved with retrieval to resolve queries that require satisfying multiple constraints jointly or following a chain of dependent clues across documents. These systems vary in their termination strategy: some run for a fixed number of turns, while others terminate dynamically based on a learned sufficiency signal. Benchmarks such as InfoDeepSeek evaluate agentic information seeking in dynamic web environments. However, most existing agentic search systems rely on frontier-scale models to drive the retrieval loop, making them expensive and latency-intensive to deploy at scale.
>
> Anthropic's multi-agent research system uses an orchestrator that spawns parallel subagents to explore different facets of a query; their internal evaluations showed the multi-agent approach outperforming single-agent Claude Opus 4 by 90% on research tasks, with token usage alone explaining 80% of the performance variance.
>
> A key practical challenge for any multi-turn search agent is managing the context that accumulates over successive retrieval steps — a phenomenon known as context rot. In MemGPT, the agent uses tools to page information between a fast main context and slower external storage. SWE-Pruner trains a lightweight 0.6B neural skimmer to perform task-aware line selection from source code context. Approaches such as ReSum periodically summarize accumulated context. Recursive Language Models (RLMs) treat the prompt as a variable in an external REPL environment. Anthropic's Opus-4.5 leverages context awareness — making agents cognizant of their own token usage as well as clearing stale tool call results.
>
> These approaches demonstrate the necessity of active context management, but do not address the specific problem of selectively retaining or discarding retrieved documents based on evolving relevance judgments, without compressing evidence into lossy summaries.
>
> One promising direction is to replace frontier models with smaller, purpose-trained alternatives. WebExplorer trains an 8B web agent via SFT+RL that outperforms substantially larger models on BrowseComp. Cognition's SWE-grep trains small models with RL to perform highly parallel agentic code search. Search-R1 demonstrates that RL alone can teach multi-turn search without SFT warmup. However, none of these incorporate context management into the search policy itself.
>
> ## Synthetic Task Generation
>
> End-to-end search builds on two core capabilities: planning (decomposing goals into query sequences) and evaluation (identifying relevant information amongst noise).
>
> Tasks are generated in the style of BrowseComp across four domains: web, finance, legal, and email. All follow a shared structure:
> 1. Gather supporting documents containing unique facts
> 2. Generate clues (obfuscated references to facts), a question, and the answer
> 3. Verify that the task is valid
> 4. Optionally collect distractors
> 5. Optionally recursively chain tasks
>
> ### Task Verification and LLM Judge Alignment
>
> For each supporting document, an LLM extracts document_quotes (verbatim spans from source text) and clue_quotes (corresponding spans from generated clues). Quotes are normalized and confirmed to actually appear in the source document. This reduces human verification to checking whether each document quote supports its paired clue quote. Across all domains, >80% alignment accuracy is achieved.
>
> ### Task Definition & Evaluation
>
> Each task consists of clues, a question, an answer, and supporting documents. Metrics:
> - **Final answer found:** binary — does the output contain the answer
> - **Recall:** fraction of positive documents returned
> - **Precision:** fraction of returned documents that are relevant
> - **F1:** harmonic mean of recall and precision
> - **Trajectory recall:** fraction of target documents encountered at any point during search
>
> ## Agent Harness
>
> Context-1 operates in an observe-reason-act loop with four tools:
>
> | Tool | Description |
> |------|-------------|
> | search_corpus(query) | Hybrid BM25 + dense vector search via RRF, top 50 candidates reranked |
> | grep_corpus(pattern) | Regex search, up to 5 matching chunks |
> | read_document(doc_id) | Full document read, reranked and truncated to fit budget |
> | prune_chunks(chunk_ids) | Removes specified chunks from conversation context |
>
> **Deduplication:** The harness tracks every chunk ID seen across prior searches and excludes them from subsequent searches, forcing each search to surface new information.
>
> **Token budget management:**
> - Continuous visibility — token usage appended after every turn
> - Soft threshold — injected message suggesting pruning or concluding
> - Hard cutoff — all tools except prune_chunk rejected beyond this point
>
> **Pruning:** When chunks are pruned, the harness preserves the full unpruned trajectory for reward computation.
>
> ## Model Training
>
> ### SFT
>
> SFT trajectories generated by running the full agent loop with large models (Kimi K2.5) as inference backend. Filtered by recall quality: high-recall trajectories retained in full, lower-recall included at diminishing rates, up to 5% zero-recall as negative examples. Trajectories where exploration exceeded output quality are excluded.
>
> *SFT trajectory distribution*
> ![[chroma-context1-003.png]]
>
> ### RL
>
> Trained fully on-policy using CISPO (Clipped Importance-Sampled Policy Optimization), a variant of GRPO. Base model: gpt-oss-20b with LoRA. 128 queries per step, 8 rollouts each = 1,024 trajectories per step. Training converges around step 230 of ~300 total.
>
> *Training reward curve*
> ![[chroma-context1-007.png]]
>
> CISPO clips importance sampling weights rather than the surrogate objective, ensuring all tokens contribute to learning. This was critical for preventing entropy collapse.
>
> *Policy entropy during training*
> ![[chroma-context1-006.png]]
>
> **Reward design:**
> - F-beta score (recall weighted 16x over precision initially)
> - Trajectory recall component (credits exploration even when documents are later pruned)
> - Final answer bonus (+1.0 for retrieving a chunk containing the answer)
> - Repeated pruning penalty (discourages one-at-a-time pruning)
> - Turn count penalty (increases linearly from 64 to 128 turns)
>
> **Curriculum:**
> 1. Difficulty curriculum: easier tasks first, harder multi-hop tasks later
> 2. Reward curriculum: F-beta annealed from recall-focused (16x) toward precision-focused (4x)
>
> ## Model Behavior
>
> *Tool calls per turn, turns per trajectory, and prune accuracy*
> ![[chroma-context1-004.png]]
> ![[chroma-context1-005.png]]
> ![[chroma-context1-008.png]]
>
> - **Parallel tool calling:** 2.56 calls/turn (vs 1.52 for base model)
> - **Prune accuracy:** 0.941 (vs 0.824 for base)
> - **Turns per trajectory:** 5.2 (vs 6.7 for base)
>
> Comparison with base model:
>
> | | Traj recall | Output Recall | F1 | Final Answer Found |
> |---|---|---|---|---|
> | gpt-oss-20b (base) | 0.640 | 0.361 | 0.307 | 0.541 |
> | Context-1 | 0.739 | 0.641 | 0.487 | 0.798 |
>
> ## Results — Generated Benchmarks
>
> Context-1 (4x) achieves comparable or superior performance to frontier models across all generated benchmark domains.
>
> | Model | Web (Diff. 2+) | Finance (Diff. 1+) | Legal | Email |
> |---|---|---|---|---|
> | Context-1 (4x) | 0.97 | 0.82 | 0.95 | 0.98 |
> | Context-1 (1x) | 0.88 | 0.64 | 0.89 | 0.92 |
> | gpt-oss-20b | 0.58 | 0.42 | 0.58 | 0.75 |
> | gpt-5.2 | 0.95 | 0.65 | 0.92 | 0.93 |
> | gpt-5.4 | 0.97 | 0.67 | 0.95 | 0.97 |
> | sonnet-4.5 | 0.97 | 0.76 | 0.92 | 0.98 |
> | opus-4.5 | 0.99 | 0.82 | 0.90 | 0.98 |
> | opus-4.6 | 0.98 | 0.84 | 0.94 | 0.98 |
> | gemini-3.1-pro | 0.97 | 0.82 | 0.88 | 0.94 |
> | kimi-k2.5 | 0.94 | 0.72 | 0.98 | 0.97 |
>
> *Web domain tool calls and document counts*
> ![[chroma-context1-012.png]]
> ![[chroma-context1-011.png]]
>
> ## Results — Public Benchmarks
>
> | Model | BrowseComp+ | LongSeal | Seal0 | FRAMES | HotpotQA |
> |---|---|---|---|---|---|
> | Context-1 (4x) | 0.96 | 0.79 | 0.52 | 0.96 | 0.99 |
> | Context-1 (1x) | 0.87 | 0.65 | 0.32 | 0.87 | 0.97 |
> | gpt-oss-20b | 0.66 | 0.41 | 0.21 | 0.58 | 0.60 |
> | gpt-5.2 | 0.82 | 0.85 | 0.48 | 0.95 | 0.98 |
> | opus-4.5 | 0.87 | 0.81 | 0.62 | 0.97 | 0.99 |
> | opus-4.6 | 0.91 | 0.83 | 0.53 | 0.97 | 0.99 |
>
> ### HLE Results
>
> *HLE accuracy with different search subagents vs no-search baseline*
> ![[chroma-context1-009.png]]
>
> ## Future Directions
>
> - **Task diversity:** Breadth queries, abstention tests, ambiguous/underspecified requests
> - **Code generation for search:** SQL, pandas, regex pipelines over structured data
> - **Schema and metadata discovery:** Leveraging corpus metadata for filtered queries
> - **Late interaction joint training:** Jointly training a ColBERT-style model alongside the search policy so embeddings co-adapt with the agent's query patterns
> - **Self-play:** Adversarial curriculum where one agent generates questions while another searches
> - **Scratchpad and selective retention:** Compressed working memory rather than binary keep/discard
>
> ## Domain-Specific Appendix Results
>
> *Web domain difficulty breakdown*
> ![[chroma-context1-010.png]]
>
> *Finance domain final answer found*
> ![[chroma-context1-014.png]]
>
> *Legal domain final answer found*
> ![[chroma-context1-015.png]]
>
> *Email domain final answer found*
> ![[chroma-context1-013.png]]
>
> ## Citation
>
> ```
> @techreport{bashir2026context1,
>   title = {Chroma Context-1: Training a Self-Editing Search Agent},
>   author = {Bashir, Hammad and Hong, Kelly and Jiang, Patrick and Shi, Zhiyi},
>   year = {2026},
>   month = {March},
>   institution = {Chroma},
>   url = {https://trychroma.com/research/context-1},
> }
> ```
