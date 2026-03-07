---
created: 2026-03-07
description: Contextual AI optimized search agents along two axes — retrieval tool configuration (reranker matters most) and planner training (on-policy distillation + CLP reward shaping) — achieving 60.7% on BrowseComp-Plus with a trained planner matching an untrained one on stronger retrieval at half the latency.
source: https://contextual.ai/blog/making-search-agents-faster-and-smarter
type: synthesis
---

## Key Takeaways

Search agents are bottlenecked by their research phase — the iterative query-search-reason loop. Contextual AI attacked this from two angles: making each search call better (tool optimization) and making the planner smarter about when and what to search (training). Both compound, and neither substitutes for the other. This resonates with the KARL finding that [[reproducing KARL requires a closed-corpus rollout stack with synthetic frontier tasks and compression-aware RL|multi-task RL over different search regimes creates better out-of-distribution grounded reasoning]] — the search environment and the training recipe are co-dependent.

On the retrieval side, the reranker is the single most important component: removing it drops nDCG@5 from 0.203 to 0.089. A 2B reranker delivers 79% of the 6B's quality at half the per-call latency. Hybrid retrieval (ANN + BM25) adds another 11% quality. MRL embeddings at 512 dimensions keep indexes 8x smaller with only ~10% nDCG loss that the reranker absorbs — useful for scale. This echoes how [[coding agents are bottlenecked by search not coding ability]] — retrieval quality is often the binding constraint, not generation.

On the planner side, they combined two training recipes: on-policy distillation from a 235B teacher (dense per-token signal via reverse KL divergence) followed by GRPO with a novel Conditional Log-Penalty (CLP) reward. CLP shapes efficiency: R = em × max(0, 1 - ε·log(1+tc)), where wrong answers always score 0 and the log gives diminishing marginal cost per additional search call. This is conceptually similar to [[stable agentic RL requires sequence-level clipping and environment-aware advantages to prevent training collapse|sequence-level clipping for stable agentic RL]] — both address the challenge of shaping rewards for multi-step agent trajectories without collapse.

They also propose Cumulative Evidence Recall (CER-C), a trajectory-level metric measuring how quickly an agent accumulates relevant evidence per token of context. A trained planner on the fastest retrieval config gathers evidence more efficiently (AUC=0.340) than an untrained planner with the strongest tool (AUC=0.332). This kind of efficiency metric matters for [[async RL from real conversations lets agents continuously improve without blocking inference|practical RL training loops]] where token budget directly impacts cost.

The key result: a trained Fast planner (50.1% at 13s) matches an untrained Strong planner (50.0% at 26s) at half the latency. The best combo (trained Max) reaches 60.7%. Training against the weakest tool forces better query decomposition and reflection, then transfers to stronger retrieval stacks — the planner is a single checkpoint that improves every config it's paired with. This parallels [[custom RL on enterprise agents matches frontier models at a fraction of cost and latency|KARL's finding]] that custom RL can match frontier models at lower cost.

## External Resources

- [BrowseComp-Plus](https://github.com/texttron/BrowseComp-Plus) — ~100K human-verified documents with QA pairs derived from OpenAI's BrowseComp
- [Wiki-DPR](https://huggingface.co/datasets/facebook/wiki%5Fdpr) — ~21M passage index for training and OOD evaluation
- [Search-R1](https://arxiv.org/abs/2503.09516) — RL training for search agents with binary outcome reward
- [GRPO](https://arxiv.org/pdf/2402.03300) — Group Relative Policy Optimization
- [On-policy distillation](https://thinkingmachines.ai/blog/on-policy-distillation/) — student learns from teacher on its own policy distribution
- [Tinker](https://tinker-docs.thinkingmachines.ai/) — training framework used for all runs
- [MRL (Matryoshka Representation Learning)](https://arxiv.org/abs/2205.13147) — truncatable embeddings at any prefix length
- [SePer](https://arxiv.org/abs/2503.01478) and [IGPO](https://arxiv.org/abs/2510.14967) — LLM-based retrieval step scoring

## Original Content

> [!quote]- Source Material
>
> # Making Search Agents Faster and Smarter
>
> March 4, 2026 | 15 min read
>
> Search agents - the iterative query-search-reason loop inside deep research and agentic RAG pipelines - are bottlenecked by their research phase. Faster, more accurate research lets agents answer harder questions at lower cost.
>
> Two design axes control the research phase: the search tool and the planner. On the tool side, we swept embedding dimensions, retrieval methods, and rerankers, finding the reranker matters most. On the planner side, we combined on-policy distillation with RL shaped by a novel efficiency reward (CLP). To measure trajectory-level efficiency, we also propose Cumulative Evidence Recall (CER-C), a metric for how quickly an agent accumulates evidence per token of context.
>
> *Figure 1: Tool config × planner training on BrowseComp-Plus. Hollow squares are untrained, filled circles are trained. Every arrow points up and to the left, higher accuracy at lower latency.*
> ![[contextual-search-agents-001.png]]
>
> Both axes help, and they compound (Figure 1). A trained planner on our fastest retrieval config (50.1%, 13s) matches an untrained planner on a stronger config (50.0%, 26s) at half the latency. The best combination reaches 60.7%. The trained planner is a single checkpoint, trained only against the fastest config, yet it improves every retrieval stack. This post walks through both axes: first the search tool, then the planner. Background on the search pipeline, evaluation corpora, and metrics (including the full CER-C definition) is in Setup below.
>
> ## Setup: Search Environment and Evaluation
>
> Search agents retrieve information iteratively: formulate a query, call a search tool, read the results, reason, and repeat. You'll find them inside deep research products and as the retrieval backbone in RAG pipelines that need more than one shot to find the answer.
>
> *Figure 2: Research phase (iterative search and reasoning) vs generation phase (final answer from accumulated evidence). This post focuses on the research phase.*
> ![[contextual-search-agents-002.png]]
>
> A search agent has two phases (Figure 2). The research phase is where the planner queries, retrieves, and reasons across multiple turns. The generation phase produces a final answer from the accumulated evidence. In most deployments, the research phase dominates latency and cost. We optimize the research phase along two axes: (1) improve each search call (retrieval and reranking), and (2) train the planner to search less wastefully.
>
> ### The Search Environment
>
> When the planner issues a search call, three factors contribute to the total search latency for a single search call:
>
> ![[contextual-search-agents-003.png]]
>
> The query is embedded, candidates are retrieved from an ANN index, and a reranker selects the top candidates. The tool returns raw text chunks, no metadata, no titles. The planner decides whether to search again or answer. There's no separation between reasoning and tool use; it all happens in one LLM call. The planner can also issue parallel tool calls, multiple queries in one turn, executed concurrently. This matters for latency and for how we measure efficiency.
>
> T\_search measures a single call. The research phase spans multiple calls plus the planner's reasoning between them, we report this end-to-end time as research phase latency (**Research P50**). It's what the user actually waits for.
>
> We want to understand how each component (embedding dimension, retrieval method, reranker size) affects single-call quality and end-to-end agent performance. To do that, we sweep tool configs while holding the planner fixed, then later sweep planner training while holding the tool fixed. Two corpora give us the evaluation surface:
>
> [BrowseComp-Plus](https://github.com/texttron/BrowseComp-Plus) is our primary benchmark: a corpus of ~100K human-verified documents with QA pairs derived from OpenAI's BrowseComp. The questions require iterative search and multi-step reasoning. We use it for all end-to-end evaluations.
>
> [Wiki-DPR](https://huggingface.co/datasets/facebook/wiki%5Fdpr) (~21M passages) is used as an index for training and out-of-distribution evaluation. It hosts 5 benchmarks: TriviaQA, PopQA (single-hop), 2WikiMultihopQA, Bamboogle (2-hop), and MuSiQue (up to 4-hop).
>
> Both corpora are indexed identically: [MRL](https://arxiv.org/abs/2205.13147) embeddings at 512 or 4096 dimensions, hybrid retrieval with ANN + [BM25](https://www.staff.city.ac.uk/~sbrp622/papers/robertson%5Fwalker%5Fsigir94.pdf), and either a small fast 2B reranker or more capable 6B reranker. Documents are chunked to fit the reranker's context window. The planner sees one tool:
>
> ```
> search(query_list) → chunks
> ```
>
> ### From Single Calls to Trajectories: Measuring Search Efficiency
>
> What does it mean for a search agent to be efficient? Accuracy alone doesn't tell you, two agents can both answer correctly, but one burns 50K tokens of context getting there while the other finds the evidence in 20K.
>
> For individual search calls, standard IR metrics work well: nDCG@K measures ranking quality, Recall@K measures coverage, and P50/P95 measure latency. We use these to ablate tool configurations in the next section. To track accuracy-efficiency tradeoffs across configurations, we use Pareto plots throughout, we want points that move up and to the left.
>
> But these metrics are blind to the trajectory. They can't capture how an agent's understanding builds across multiple search calls. [SePer](https://arxiv.org/abs/2503.01478) and [IGPO](https://arxiv.org/abs/2510.14967) address this by scoring each retrieval step through the LLM, measuring how much the model's uncertainty drops after each call. Effective, but LLM-based evaluation adds cost and noise. We wanted something you can compute from ground-truth relevance labels alone.
>
> We propose **Cumulative Evidence Recall (CER-C)**, a single scalar that captures how quickly an agent accumulates relevant evidence per token of context. After each 10K-token bucket of context consumed, CER-C records the fraction of known relevant documents the agent has found so far. We measure by tokens, not turns, because a single turn can batch multiple queries and consume variable context. The area under this curve is the score: higher is better.
>
> For example, if an agent finds 3 of 5 relevant documents within its first 10K tokens, a 4th by 20K, and all 5 by 30K, the CER-C curve reads [0.6, 0.8, 1.0, ...] and the AUC captures the total area. An agent that front-loads evidence early scores higher than one that finds the same documents later, a difference that per-call metrics like nDCG@5 are blind to.
>
> ## Search Tool Optimization
>
> The search tool has three knobs: embedding dimension, retrieval method, and reranker. We varied all three on BrowseComp-Plus (Table A and Figure 3). The takeaway: invest in the reranker first, everything else is a second-order effect.
>
> ### Embedding dimension
>
> Embedding models typically have a fixed output dimension, say 4096. [MRL (Matryoshka Representation Learning)](https://arxiv.org/abs/2205.13147) trains the model so that you can truncate the embedding to any prefix length at inference time and still get useful representations. No retraining, no separate models. You just slice the vector. The tradeoff is clean:
>
> *Table A: MRL dimensionality, pure ANN search, fixed 2B reranker.*
> ![[contextual-search-agents-004.png]]
>
> Going from 512 to 4096 buys +13% recall and +11% nDCG. Retrieve latency jumps 7x (0.04s to 0.27s), but that's misleading: the reranker takes 1.5s+ either way, so search is under 15% of total latency. The embedding dimension barely moves the needle on end-to-end speed. Where 512 does help is at scale: 8x smaller index, lower memory, higher throughput, with a 13% recall tradeoff that the reranker largely absorbs.
>
> ### The full configuration space
>
> With the embedding dimension settled, we now vary the retrieval method (ANN vs hybrid ANN+BM25) and the reranker (none, 2B, 6B). We also include a ceiling config: 4096-dim, hybrid, 6B reranker, top-200. For each config we measure pre-reranker recall, reranked nDCG@5 and Recall@5, and end-to-end search latency (P50). All numbers are single-call on BrowseComp-Plus.
>
> *Figure 3: Single-call search quality (nDCG@5) vs median latency (P50) on BrowseComp-Plus. All configs use top-50 chunks unless noted*
> ![[contextual-search-agents-005.png]]
>
> Figure 3 shows the quality-latency tradeoff across configs. Three things stand out:
>
> 1. The reranker matters most. Without it, nDCG@5 drops from 0.203 to 0.089. That single component accounts for more quality than any other knob.
> 2. Scaling the reranker has diminishing returns. The 6B scores 0.258 vs 0.203 for the 2B, a 27% gain, but at nearly 2x the latency (795ms vs 421ms).
> 3. Hybrid retrieval trades latency for coverage. Adding BM25 lifts nDCG@5 from 0.203 to 0.226 at ~2x the per-call latency (421ms → 781ms). Lexical matching catches what embeddings miss, and the cost is modest relative to the reranker and LLM reasoning time.
>
> The top config (4096-dim, 6B reranker, top-200) reaches 0.380 nDCG@5 at ~4s P50, compared to ~400ms for the cheapest reranker setup. Whether that tradeoff is worth it depends on your application.
>
> Since hybrid retrieval improves quality at a modest per-call cost, small relative to the full research phase, we use it across the board. For the rest of this post, we carry forward **three** configs that span this tradeoff:
>
> 1. **Fast**: 512-dim, 2B reranker, hybrid, top-50
> 2. **Strong**: 512-dim, 6B reranker, hybrid, top-50
> 3. **Max**: 4096-dim, 6B reranker, hybrid, top-200
>
> **Does better single-call quality translate to better agentic performance?**
>
> We ran all three configs through the full agentic pipeline (planner + multi-turn search) on BrowseComp-Plus:
>
> *Table B: Agentic Retrieval Quality vs Latency, All configs use Qwen3-30B-A3B as planner with hybrid search (ann=0.6, bm25=0.4).*
> ![[contextual-search-agents-006.png]]
>
> The 6B reranker pays off end-to-end. Strong hits 50.0% accuracy vs 45.5% for Fast, with the same number of tool calls. Better search results let the planner terminate earlier without increasing tool calls.
>
> Max only adds 1.6 points over Strong (51.6 vs 50.0) at 2x the latency. Beyond the 6B reranker, retrieval quality alone shows diminishing returns.
>
> ## Planner Optimization
>
> The untrained planner already does something useful: it searches, reads results, reasons, and potentially searches again. But it wasn't trained to use search tools. Post-training teaches it when to search, what to query, and when to stop.
>
> We tried two training recipes, both starting from Qwen3-30B-A3B, training on [NQ + HotpotQA](https://huggingface.co/datasets/PeterJinGo/nq%5Fhotpotqa%5Ftrain) (~170K questions) against the Wiki-DPR index, using [Tinker](https://tinker-docs.thinkingmachines.ai/) for all training runs. We trained against the **Fast** config (512-dim, 2B reranker, top-50), the fastest retrieval stack. Training against a weak tool forces the planner to write better search queries through decomposition, reformulation, and reflection, rather than relying on retrieval quality alone.
>
> ### Recipe 1: RL with outcome reward (SearchR1-style)
>
> Most agentic search systems use prompting (ReAct-style) to interleave reasoning and tool calls. [Search-R1](https://arxiv.org/abs/2503.09516) goes further: it uses RL to train the model to decide what to search, how to reason over results, and when to stop. The model runs a full search episode (query, read, reason, repeat) and receives a single binary reward: 1 if the final answer is correct, 0 otherwise. No per-step rewards, no process supervision. We used [GRPO](https://arxiv.org/pdf/2402.03300) to handle the policy optimization.
>
> One key detail: Search-R1 masks tool output tokens during backprop, so the model only receives training signal for the tokens it generates. It learns from its own decisions, not from retrieved content.
>
> ### Recipe 2: On-policy distillation
>
> The alternative is to skip outcome rewards entirely and learn from a stronger model. [On-policy distillation](https://thinkingmachines.ai/blog/on-policy-distillation/) has the student generate trajectories under its own policy, then a teacher (here, Qwen3-235B-A22B) provides dense per-token supervision via reverse KL divergence. No exact-match reward, the only signal is "what would the teacher have done in this situation?"
>
> ![[contextual-search-agents-007.svg]]
>
> The key insight is _on-policy_: the student learns from states it actually visits, not from expert demonstrations it would never reproduce. RL with outcome rewards gives one signal per episode (good/bad). Per-token distillation gives a signal at every token through the trajectory. When a planner makes 2–5 search decisions per query, that density matters.
>
> We trained for 50 steps. Teacher KL dropped 39% (the student converged toward the teacher), and search calls per episode rose from 1.4 to 2.06. The student learned to calibrate its search effort: more calls when the question requires multi-hop reasoning, fewer when the answer is straightforward. The next section adds an explicit efficiency signal.
>
> ### Shaping the reward for efficiency
>
> Both recipes improve accuracy, but neither explicitly optimizes for efficiency. A model that gets the right answer in 2 tool calls is better than one that takes 6, but the reward doesn't say that.
>
> We want R = f(correctness, tool\_calls) where wrong answers always score 0 and correct answers are discounted by how many calls they needed. Three options:
>
> **Additive:** R = em + α/(1+tc). Breaks the separation between correct and incorrect, a wrong answer that fails fast gets positive reward. The model learns "if you're wrong, be wrong quickly."
>
> **Linear multiplicative:** R = em × max(0, (1 - ε·tc)). Separation preserved (wrong = 0), but the positive range is tiny. At ε=0.25, the reward hits zero at just tc=4. Beyond that, the clamp is doing all the work, the model gets no gradient signal to distinguish a 5-call correct answer from a 10-call one.
>
> **Conditional log-penalty (CLP):** R = em × max(0, 1 - ε·log(1+tc)).
>
> CLP has three nice properties. Wrong answers always get 0 (the em × prefix). Correct answers always get ≥ 0 (the max clamp). And the log gives diminishing marginal cost, the first search call is expensive (skip it on easy questions), but additional calls are cheap (keep going on hard ones). At ε=0.25, CLP stays positive until tc=54, compared to tc=4 for the linear version, 13.4× more headroom. We used ε=0.15, which is even more forgiving.
>
> *Figure 4: Reward vs tool calls for linear multiplicative (left) and CLP (right) shaping. At every ε, the log penalty stays positive across a wider range of tool calls, giving the model more room to search before the reward hits zero. Both formulas include a max(0, ...) clamp in practice; the figure shows unclamped curves to illustrate why CLP gives the model more room to search.*
> ![[contextual-search-agents-008.png]]
>
> #### Putting it together: two-stage training
>
> Our best checkpoint came from combining both recipes:
>
> 1. On-policy distillation (50 steps): Learn search behavior from the 235B teacher via per-token KL. No outcome reward.
> 2. GRPO with CLP reward (30 steps): Continue from the distilled checkpoint, now with outcome-based RL shaped by the efficiency penalty. No teacher.
>
> The intuition: distillation gives you a strong starting point, the model already knows _when_ and _what_ to search. RL with CLP then fine-tunes the efficiency, teaching the model to be disciplined about unnecessary calls.
>
> *Figure 5: Without CLP (green), the model learns to search more over time, tool calls climb steadily; but each additional search yields diminishing returns. With CLP (blue, red), tool calls stay flat while accuracy rises: the model learns to reason more carefully between searches rather than reflexively reaching for the tool*
> ![[contextual-search-agents-009.png]]
>
> ## Results
>
> We evaluate on 5 OOD benchmarks, ordered from hardest to easiest: BrowseComp-Plus (deep iterative research), MuSiQue (2-4 hop compositional), Bamboogle and 2WikiMultiHop (2-hop), and TriviaQA/PopQA (single-hop factoid). We train on NQ and HotpotQA (1-2 hop), so all five benchmarks test generalization, and BC+ tests a fundamentally harder environment.
>
> *Table C: Planner training results across 5 OOD benchmarks (hardest to easiest, left to right) plus BrowseComp-Plus. Tool Calls: OOD avg / BC+ avg (planner decisions per query).*
> ![[contextual-search-agents-010.png]]
>
> Every trained variant beats untrained. The separation shows up on the hard benchmarks: on BC+, on-policy + CLP leads at .501, with SearchR1 variants at .464-.465. On easier benchmarks the gap narrows, but those are closer to saturation.
>
> CLP consistently reduces tool calls without hurting accuracy: SearchR1 + CLP uses 1.6 OOD calls vs 1.9 without it. The penalty teaches selectivity. That said, CLP's efficiency gains were clearest on 1-2 hop tasks similar to our training data. On BC+, most of the improvement came from distillation, not efficiency shaping.
>
> Our best checkpoint: on-policy distillation + CLP. It wins on the hard end and stays efficient.
>
> ## Putting It Together
>
> We've optimized the tool and the planner separately. Now we cross them: take our best trained checkpoint (on-policy + CLP) and evaluate it across all three retrieval configs on BrowseComp-Plus.
>
> *Table D: BrowseComp-Plus accuracy (%). Trained planner was only trained against the fast config.*
> ![[contextual-search-agents-011.png]]
>
> Training improves every config. Fast gains +4.9 points, Strong +3.9, and Max +9.1. The biggest jump is on Max, where better retrieval gives the trained planner more to work with. All three trained planners converge to ~3 tool calls, regardless of the retrieval stack underneath.
>
> The Pareto plot in Figure 1 tells the full story. Every trained point sits above and to the left of its untrained counterpart. Trained Fast (50.1% at 12.9s) matches untrained Strong (50.0% at 26.0s) at half the latency. Training and retrieval compound: Trained Max reaches 60.7%, far above either improvement alone.
>
> *Figure 6: Cumulative Evidence Recall vs context budget (kilo-tokens) on BrowseComp-Plus. Solid lines are trained, dashed are untrained. Each color is a retrieval config.*
> ![[contextual-search-agents-012.png]]
>
> The CER-C curves show how quickly each configuration accumulates evidence as context grows. Trained **Fast** (AUC=0.340) outperforms untrained **Max** (AUC=0.332): a planner trained on the fastest tool gathers evidence more efficiently than an untrained planner with the strongest tool. The gap opens early, within the first 10K tokens, where trained models issue better initial queries and waste less budget on dead ends. Trained Max (AUC=0.443) combines both improvements and pulls ahead of all other configurations.
>
> ## Parting Notes
>
> We started with two questions: can we make the tool faster, and can we make the planner smarter? Here's what we'd tell someone building a search agent today.
>
> **On the tool side**, the reranker mattered most; without it, nDCG@5 dropped from 0.203 to 0.089. Between rerankers, the 2B delivered 79% of the 6B's quality at half the per-call latency. Hybrid retrieval (ANN + BM25) added another 11% quality on top of the 2B at roughly double the per-call cost, still modest relative to the planner's reasoning time. MRL embeddings at 512 dimensions kept indexes 8x smaller with a ~10% nDCG tradeoff that the reranker largely absorbs, a useful knob for throughput at scale.
>
> **On the planner side**, SearchR1-style RL was the simplest recipe to get running: no teacher model, no distillation infrastructure, just GRPO with a binary reward. It trained in 25-30 steps and we saw gains across model sizes from 4B to 235B. On-policy distillation added denser signal per step when we had a strong teacher in the same tokenizer family. CLP reward shaping reduced tool calls without hurting accuracy. Combining distillation with CLP gave us our best checkpoint.
>
> **Together**, they compound. A trained planner on the Fast retrieval config matched an untrained planner on a stronger config at half the research latency. But training doesn't replace good retrieval, and good retrieval doesn't replace training. The best results came from both.
>
> **Future work**. A few directions we think matter: prompt tuning as a lighter-weight alternative to RL, cross-tokenizer distillation for using teachers from different model families, and scaling CLP to harder environments where the search-to-reasoning ratio is less compressible.
>
> We hope the metrics (CER-C), training recipes, and design choices here are useful for anyone building search agents. If you try any of this on your own setup, we'd love to hear what works.
>
> [Original article](https://contextual.ai/blog/making-search-agents-faster-and-smarter)
