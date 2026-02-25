# The Research Is Clear: Coding Agents Are Bottlenecked by Search, Not Coding Ability

> A survey of recent research on why AI coding agents fail — and why the answer is almost always retrieval, not generation.

**Author:** Tejas Bhakta
**Date:** February 18, 2026
**Source:** [morphllm.com/blog/code-search-bottleneck](https://www.morphllm.com/blog/code-search-bottleneck)

---

There's a common assumption in AI coding: if you want better agents, train better models. Bigger context windows. Smarter reasoning. More parameters.

The research says otherwise.

Across dozens of papers published between 2024 and early 2026 — from Anthropic, Google DeepMind, Cognition, Stanford, and independent researchers — the same finding keeps showing up: coding agents don't fail because they can't code. They fail because they can't find the right code to work with.

This post compiles the evidence.

## 60% of Agent Time Is Spent Searching, Not Coding

Cognition — the team behind Devin and Windsurf — published the most direct measurement. When they analyzed agent trajectories across both products, they found that [agents were spending over 60% of their first turn just retrieving context](https://cognition.ai/blog/swe-grep). Not editing. Not reasoning. Just searching.

This wasn't a pathological case. It was the median behavior across production workloads.

Traditional agentic search — where the model issues sequential grep and file-read calls — takes 10-20 serial turns to build enough context for a task. That's 10-20 round trips of the model reading results, deciding what to search next, and reading more results. Each turn adds tokens to the context window that the model will carry for the rest of the session.

Cerebras [confirmed the pattern](https://x.com/CerebrasSystems/status/1978874694825840679): "Context retrieval has been one of the biggest bottlenecks in agentic coding. When you ask an agent to work on a large codebase, it can spend 60% of its time just searching for relevant files."

An [OpenReview study](https://openreview.net/forum?id=1bUeVB3fov) on token consumption in coding agents found that input tokens dominate overall cost — even with token caching. Some runs consumed up to 10x more tokens than others on similar tasks, with the variance driven almost entirely by how efficiently the agent searched. The study also found that predicting total token consumption before execution has a Pearson's r below 0.15 — nearly random — because search efficiency varies so wildly between runs.

The implication: the majority of what you pay for when running a coding agent is search. Not code generation. Search.

## Context Rot: More Context Makes Models Worse

You might think the fix is simple: just give the model a bigger context window and dump everything in. The research emphatically disagrees.

### The Lost-in-the-Middle Problem

Liu et al.'s foundational [Stanford paper](https://arxiv.org/abs/2307.03172) (published in TACL 2024 and widely cited since) showed that LLM performance degrades by more than 30% when relevant information shifts from the start or end of the context to the middle. Performance follows a U-shaped curve — models attend strongly to the first and last tokens, and poorly to everything in between.

For coding agents, this is devastating. An agent that greps for a function name, reads 8 files, and finds the relevant code in file #4 has effectively hidden that code in the model's blind spot.

### Chroma's 18-Model Study

Chroma's research team [tested 18 LLMs](https://research.trychroma.com/context-rot) — including GPT-4.1, Claude 4, Gemini 2.5, and Qwen 3 — across 8 input lengths and 11 needle positions. Their findings:

- Models do not use their context uniformly. Performance grows increasingly unreliable as input length grows, even on simple tasks.
- Performance non-uniformity increases with context length.
- Factors like needle-question similarity, distractors, and haystack structure all cause degradation.
- Claude Opus 4 exhibited a 2.89% task refusal rate at longer context lengths.

Their conclusion: "What matters more than whether relevant information is _present_ is how that information is _presented_."

### The Quadratic Attention Problem

The mechanism behind context rot is architectural. At 10,000 tokens, the transformer must track 100 million pairwise relationships. At 100,000 tokens, that's 10 billion. The attention mechanism doesn't scale linearly — it scales quadratically. More context doesn't just dilute relevance; it makes the model physically worse at attending to what matters.

The practical takeaway: search quality determines reasoning quality. Give the agent the right 50 lines and it writes correct code. Give it 500 lines of maybe-relevant results and it hallucinates.

## Where Agents Actually Fail on SWE-Bench

SWE-bench is the standard benchmark for evaluating coding agents on real GitHub issues. Recent papers have dissected _where_ in the pipeline agents fail — and the answer consistently points to retrieval.

### File Localization: Better Than You'd Think (But Not Good Enough)

Majgaonkar et al.'s [analysis of agent trajectories](https://arxiv.org/abs/2511.00197) (accepted at ICSE 2026) found that agents correctly identified the problematic file in 72-81% of failed attempts. The agent knew roughly where to look. But "roughly" isn't enough — it found the right file but not the right lines, or found one of three files that needed changing.

Failed trajectories were consistently longer and exhibited higher variance than successful ones. The agents didn't fail because they couldn't code a fix. They failed because they spent too many turns searching, polluted their context with wrong results, and then made bad edits based on bad context.

### Better Localization = Better Resolution

LocAgent ([ACL 2025](https://aclanthology.org/2025.acl-long.426/)) proved this directly. Using graph-guided search with a fine-tuned Qwen-2.5-Coder-32B, they achieved 92.7% file-level localization accuracy and improved downstream GitHub issue resolution by 12% — without changing the code generation model at all.

Caumartin et al.'s [query reformulation paper](https://arxiv.org/abs/2512.07022) (December 2025) found that simply reformulating the search query — not improving the coding model — produced 35% better first-file retrieval and 22% better file retrieval than SWE-agent. Again: same coding model, better search, better outcomes.

### 23% Improvement From Search Alone

The SWE-Search paper ([ICLR 2025](https://arxiv.org/abs/2410.20285)) applied Monte Carlo Tree Search to the exploration of the solution space and achieved a 23% relative improvement across five models on SWE-bench. Their key finding: you can improve coding agent performance by 23% "without requiring larger models or additional training data." Just better search.

### Agentless Proved Localization Is the Differentiator

Xia et al.'s [Agentless approach](https://arxiv.org/abs/2407.01489) achieved 32% on SWE-Bench Lite at only $0.70 per issue using a simple three-phase pipeline: localize → repair → validate. The hierarchical localization step (file → class/function → edit location) was the entire innovation. The repair step was a basic diff generator. The system that invested most of its architecture in search, not generation, set the performance bar.

## Why RAG Doesn't Work for Code

If search is the bottleneck, why not use retrieval-augmented generation — embed the codebase, embed the query, find nearest neighbors?

### DeepMind Proved a Mathematical Ceiling

Weller et al. from Google DeepMind [proved a fundamental limitation](https://arxiv.org/abs/2508.21038) (August 2025): for any given embedding dimension, there is a hard cap on the number and complexity of query-document relationships a model can represent. This is connected to "sign-rank" from communication complexity theory.

The practical consequences:

- Embeddings of size 512 break down around 500K documents
- Dimension 1024 extends to approximately 4M documents
- On the LIMIT benchmark (50K documents), recall@100 often fell below 20% for state-of-the-art embedding models
- BM25 (keyword search) outperformed neural embedding models by a massive margin on the same benchmark

This isn't an engineering problem to be solved with better models. It's a mathematical ceiling.

### Code Is Structurally Adversarial for Embeddings

Code search queries are fundamentally different from text search queries. "Where does the auth middleware check JWT expiration?" requires understanding call graphs, import chains, middleware registration patterns, and framework conventions. A single embedding vector cannot capture these multi-hop relationships.

The RAGFlow team's [2025 year-end analysis](https://ragflow.io/blog/rag-review-2025-from-rag-to-context) identified the structural conflict: larger chunks (1024+ tokens) are needed for context understanding, while smaller chunks (100-256 tokens) are needed for precise matching. Code forces a trade-off between "precise but fragmented" and "complete but vague" — a function body needs to be retrieved whole but matched on specific identifiers.

### Embeddings Go Stale in Active Codebases

Production codebases change constantly. Embeddings computed yesterday may not reflect today's code. Research shows that stale embeddings [cause performance declines of up to 20%](https://medium.com/@yashtripathi.nits/when-embeddings-go-stale-detecting-fixing-retrieval-drift-in-production-778a89481a57) in downstream LLM tasks. For active repos with multiple developers pushing daily, the maintenance burden of re-indexing is significant — and the performance penalty of not re-indexing is real.

An [exploratory study of code retrieval techniques](https://www.preprints.org/manuscript/202510.0924) (October 2025) noted that "indexing an entire codebase with embeddings is seen as not only potentially unnecessary but also a security risk, leading some of the most prominent agent development teams to abandon RAG in favor of more direct, exploratory methods."

### Even Anthropic Chose Grep Over RAG

Claude Code — Anthropic's flagship coding agent — uses no RAG at all. It searches by grepping repositories line by line. This is a strong signal: the team with arguably the best models in the world chose grep over embeddings for their own coding agent.

## Sub-Agent Architecture: The Emerging Consensus

If search is the bottleneck, and RAG doesn't work for code, what does? The research points to a clear answer: dedicated search sub-agents with isolated context windows.

### Anthropic's 90% Improvement

Anthropic's [multi-agent research system](https://www.anthropic.com/engineering/multi-agent-research-system) (June 2025) provides the strongest evidence. Their system — Opus 4 lead agent + Sonnet 4 sub-agents — outperformed single-agent Opus 4 by 90.2% on their internal research evaluation.

The lead agent spawns 3-5 sub-agents in parallel, each with its own clean context window. The sub-agents search, filter, and return only relevant results. The lead agent reasons over the distilled findings.

Their key insight: "Multi-agent systems work mainly because they help spend enough tokens to solve the problem" — but crucially, those tokens are spent in _separate context windows_. The lead agent's reasoning context stays clean.

### Cognition Built a Dedicated Search Model

After measuring the 60% search overhead, Cognition didn't build a bigger coding model. They built [SWE-grep](https://cognition.ai/blog/swe-grep) — a specialized search sub-agent trained specifically for code retrieval. It runs at 2,800 tokens/second (20x faster than Haiku), achieves frontier-model retrieval accuracy, and uses only 4 serial turns with 8 parallel tool calls per turn.

Their architectural insight: "Context retrieval sub-agents are the perfect hand-off point between a smart model and a fast model." The smart model decides what to search for. The fast model does the searching.

[WarpGrep v2](https://www.morphllm.com/products/warpgrep) takes this further. It outperforms SWE-grep, Haiku, and Sonnet 4.6 on code retrieval, and when paired with frontier coding models (Opus, Minimax, Kimi) it reaches #1 on SWE-bench Pro — the benchmark that evaluates agents on production-scale codebases, not toy repos.

### The Pattern Is Universal

The GrepRAG paper ([ISSTA 2026](https://arxiv.org/abs/2601.23254)) showed that adding lightweight post-processing to agentic grep — identifier-weighted re-ranking, structure-aware deduplication — outperforms state-of-the-art methods by 7-15% in code exact match on CrossCodeEval. The key is not a fancier retrieval model, but a smarter search pipeline.

Augment Code [reached the top of SWE-Bench Verified](https://jxnl.co/writing/2025/09/11/why-grep-beat-embeddings-in-our-swe-bench-agent-lessons-from-augment/) using grep and find — no embeddings at all. The agent's persistence (multi-turn iterative search) compensated for less sophisticated tools. But their caveat is important: SWE-bench repos are small. Real-world enterprise codebases are fundamentally different.

## What This Means for Agent Infrastructure

The research converges on a clear thesis:

1. **Search eats 60%+ of agent resources.** This is not an estimate — it's measured across production workloads at Cognition and confirmed by independent researchers.

2. **Context rot is the primary failure mode.** Not model capability. Models that can solve the problem in a clean context fail when their context is polluted with irrelevant search results.

3. **RAG has a mathematical ceiling for code.** DeepMind proved that embedding-based retrieval fundamentally cannot scale to the complexity of code search queries.

4. **Sub-agent isolation is the fix.** Anthropic's 90% improvement from multi-agent architecture, Cognition's SWE-grep, WarpGrep v2 reaching #1 on SWE-bench Pro, and the ICLR SWE-Search paper's 23% improvement from better search alone all point to the same conclusion.

5. **Better search directly improves code generation.** LocAgent's 12% downstream improvement, query reformulation's 35% first-file improvement, and Agentless's competitive performance with a simple localize-then-repair pipeline all demonstrate that investing in search yields proportional improvements in output quality.

The frontier of AI coding isn't bigger models. It's better search.

---

This is why we built [WarpGrep](https://www.morphllm.com/products/warpgrep) — a search sub-agent that runs in its own context, uses RL-trained parallel search to find relevant code in 3.8 steps, and returns only the precise file spans your coding model needs. No embeddings. No indexing. No context rot.

[WarpGrep v2](https://www.morphllm.com/products/warpgrep) (released February 23, 2026) outperforms SWE-grep, Haiku, and Sonnet 4.6 on code retrieval — and improves model performance on [SWE-bench Pro](https://www.swebench.com/) (production-scale codebases) across the board. Paired with Opus, Minimax, and Kimi, it reaches #1 on SWE-bench Pro.

The models are already good enough to code. They just need to find the right code first.

---

## References (15 papers)

1. Cognition AI. "Introducing SWE-grep and SWE-grep-mini." [cognition.ai/blog/swe-grep](https://cognition.ai/blog/swe-grep), 2025.
2. Liu et al. "Lost in the Middle: How Language Models Use Long Contexts." TACL, 2024. [arxiv.org/abs/2307.03172](https://arxiv.org/abs/2307.03172).
3. Hong, Troynikov, Huber (Chroma). "Context Rot: How Increasing Input Tokens Impacts LLM Performance." [research.trychroma.com/context-rot](https://research.trychroma.com/context-rot), 2025.
4. Anthropic. "How We Built Our Multi-Agent Research System." [anthropic.com/engineering/multi-agent-research-system](https://www.anthropic.com/engineering/multi-agent-research-system), 2025.
5. Weller, Boratko, Naim, Lee (Google DeepMind). "On the Theoretical Limitations of Embedding-Based Retrieval." [arxiv.org/abs/2508.21038](https://arxiv.org/abs/2508.21038), 2025.
6. Majgaonkar et al. "Understanding Code Agent Behaviour: An Empirical Study of Success and Failure Trajectories." ICSE 2026. [arxiv.org/abs/2511.00197](https://arxiv.org/abs/2511.00197).
7. Chen et al. "LocAgent: Graph-Guided LLM Agents for Code Localization." ACL 2025. [aclanthology.org/2025.acl-long.426](https://aclanthology.org/2025.acl-long.426/).
8. Caumartin et al. "Reformulate, Retrieve, Localize: Agents for Repository-Level Bug Localization." [arxiv.org/abs/2512.07022](https://arxiv.org/abs/2512.07022), 2025.
9. "SWE-Search: Enhancing Software Agents with Monte Carlo Tree Search." ICLR 2025. [arxiv.org/abs/2410.20285](https://arxiv.org/abs/2410.20285).
10. Xia et al. "Agentless: Demystifying LLM-based Software Engineering Agents." [arxiv.org/abs/2407.01489](https://arxiv.org/abs/2407.01489), 2024.
11. Wang et al. "GrepRAG: An Empirical Study and Optimization of Grep-Like Retrieval for Code Completion." ISSTA 2026. [arxiv.org/abs/2601.23254](https://arxiv.org/abs/2601.23254).
12. Flaherty/Liu (Augment Code). "Why Grep Beat Embeddings in Our SWE-Bench Agent." [jxnl.co](https://jxnl.co/writing/2025/09/11/why-grep-beat-embeddings-in-our-swe-bench-agent-lessons-from-augment/), 2025.
13. "How Do Coding Agents Spend Your Money?" OpenReview. [openreview.net/forum?id=1bUeVB3fov](https://openreview.net/forum?id=1bUeVB3fov), 2025.
14. Hrubec. "Reducing Token Usage of Software Engineering Agents." TU Wien, 2025.
15. "An Exploratory Study of Code Retrieval Techniques in Coding Agents." [preprints.org/manuscript/202510.0924](https://www.preprints.org/manuscript/202510.0924), 2025.

---

## All Links Referenced in This Article

### Papers (arXiv / Academic)
- [Lost in the Middle (Liu et al., TACL 2024)](https://arxiv.org/abs/2307.03172)
- [Agentless (Xia et al., 2024)](https://arxiv.org/abs/2407.01489)
- [SWE-Search (ICLR 2025)](https://arxiv.org/abs/2410.20285)
- [Agent Trajectories Analysis (Majgaonkar et al., ICSE 2026)](https://arxiv.org/abs/2511.00197)
- [Query Reformulation (Caumartin et al., 2025)](https://arxiv.org/abs/2512.07022)
- [Theoretical Limitations of Embedding-Based Retrieval (Weller et al., DeepMind 2025)](https://arxiv.org/abs/2508.21038)
- [GrepRAG (Wang et al., ISSTA 2026)](https://arxiv.org/abs/2601.23254)
- [LocAgent (Chen et al., ACL 2025)](https://aclanthology.org/2025.acl-long.426/)
- [Token Consumption in Coding Agents (OpenReview)](https://openreview.net/forum?id=1bUeVB3fov)
- [Exploratory Study of Code Retrieval Techniques](https://www.preprints.org/manuscript/202510.0924)

### Blog Posts & Articles
- [Cognition: Introducing SWE-grep](https://cognition.ai/blog/swe-grep)
- [Anthropic: Multi-Agent Research System](https://www.anthropic.com/engineering/multi-agent-research-system)
- [Chroma: Context Rot Research](https://research.trychroma.com/context-rot)
- [RAGFlow: RAG Review 2025](https://ragflow.io/blog/rag-review-2025-from-rag-to-context)
- [Augment Code: Why Grep Beat Embeddings](https://jxnl.co/writing/2025/09/11/why-grep-beat-embeddings-in-our-swe-bench-agent-lessons-from-augment/)
- [Cerebras on Search Bottleneck (X/Twitter)](https://x.com/CerebrasSystems/status/1978874694825840679)
- [Embedding Staleness & Retrieval Drift](https://medium.com/@yashtripathi.nits/when-embeddings-go-stale-detecting-fixing-retrieval-drift-in-production-778a89481a57)

### Products & Tools
- [Morph WarpGrep](https://www.morphllm.com/products/warpgrep)
- [Morph Fast Apply](https://www.morphllm.com/products/fastapply)
- [Morph Glance](https://www.morphllm.com/products/glance)
- [Morph MCP](https://www.morphllm.com/mcp)
- [Morph SDK Docs](https://docs.morphllm.com)
- [SWE-bench Pro](https://www.swebench.com/)
