---
created: 2026-04-11
description: Latent Briefing uses task-guided KV cache compaction to share an orchestrator's accumulated reasoning with worker agents, achieving 42-57% worker token reduction with comparable or improved accuracy on LongBench v2.
source: https://x.com/RampLabs/status/2042660310851449223
type: framework
---

## Key Takeaways

- KV cache compaction sidesteps the summarization-vs-RAG dilemma for cross-agent context sharing. Instead of LLM summarization (slow, lossy) or RAG (brittle, misses cross-chunk dependencies), Latent Briefing operates directly on the model's internal representations to identify and retain task-relevant context — achieving ~1.7s median overhead vs 20-60s for summarization. This sits in the same design space as [[training compaction into the model through RL produces better summaries than prompted compaction at one-fifth the tokens]] but works at inference time without RL training.

- Task-guided query vectors make compaction adaptive per worker call. By using the orchestrator's task prompt as the attention query for scoring which KV positions to keep, the same trajectory gets compressed differently depending on what the worker needs. This is a practical realization of the [[multi-agent memory needs computer architecture style hierarchy and consistency models]] insight — the "cache" layer becomes task-aware rather than static.

- Optimal compaction aggressiveness varies inversely with document length and directly with question difficulty. Longer documents need light compaction (t=-1.0, 82% retention) to preserve dispersed information, while hard questions benefit from aggressive compaction (t=2.0, 21% retention) that strips speculative orchestrator reasoning. This threshold-regime finding has implications for any system doing [[context tax compounds through cache misses bloated tools and unbudgeted output tokens|context budget management]].

- Shared global token selection across attention heads enables batched GPU execution, cutting compaction from 30+ seconds to ~1.7s. The original Attention Matching framework required 320 sequential CUDA kernel launches (40 layers x 8 heads); the shared mask collapses these into 2-3 batched tensor operations. Combined with KV prefix caching (90%+ reuse between calls), this makes representation-level context sharing practical for real-time agent loops.

- At optimal thresholds, Latent Briefing achieves +3pp accuracy improvement over baseline RLM while reducing worker tokens 42-57% and total tokens 21-31%. The accuracy gain suggests the orchestrator's raw trajectory contains noise that actively hurts the worker — compaction acts as a relevance filter, not just a cost optimization.

## External Resources

- [Recursive Language Model (RLM) framework](https://arxiv.org/abs/2512.24601) — Zhang et al., 2025. Base multi-agent architecture where a strong orchestrator makes repeated calls to a worker through a REPL environment.
- [Attention Matching (AM) framework](https://arxiv.org/abs/2602.16284) — Zweiger et al., 2026. The KV cache compaction method Latent Briefing builds on, finding compact caches that produce nearly identical attention outputs.
- [LongBench v2](https://arxiv.org/abs/2412.15204) — Reading comprehension benchmark spanning academic papers, legal documents, fiction, and government reports at 0-100k tokens.
- [Ramp Labs careers](https://jobs.ashbyhq.com/ramp) — Hiring across roles at Ramp.

## Original Content

> [!quote]- Source Material
>
> @RampLabs — 2026-04-10
>
> **Latent Briefing: Efficient Memory Sharing for Multi-Agent Systems via KV Cache Compaction**
>
> Multi-agent systems have shown promise in coordination, complex reasoning, and parallel workflows. However, they are often highly token inefficient. In hierarchical architectures, where an orchestrator decomposes tasks and delegates to worker agents, redundant intermediate reasoning can emerge. As the orchestrator's reasoning trajectory expands across numerous calls, token usage compounds rapidly. While these approaches can improve performance, they do so at substantial cost and often share context between agents inefficiently.
>
> Existing approaches to managing this context such as LLM based summarization (slow) or retrieval via RAG (brittle) introduce their own tradeoffs. Instead, we use the model's attention patterns to identify which parts of the context are important and discard the rest at the representation level. This leads to a method for sharing relevant memory between agents by operating directly on the model's KV cache. We refer to this approach as Latent Briefing.
>
> Across 126 questions on the LongBench v2 benchmark (spanning documents from 0–100k tokens), our approach achieved:
>
> - Comparable or improved accuracy relative to the baseline across difficulty and context length conditions
>
> - Up to 49% median token savings on medium length (32k–100k token) documents
>
> - 65% reduction in worker model token consumption
>
> - ~1.7s median compaction overhead, scaling linearly with input length
>
> ---
>
> ## Token Explosion in Recursive Agents
>
> We adopted the Recursive Language Model (RLM) framework [(Zhang et al., 2025)](https://arxiv.org/abs/2512.24601) as our base architecture for multi agent systems. In RLM, a strong orchestrator decomposes a task and makes repeated calls to a worker model through a REPL environment. The orchestrator sends targeted queries to the worker asking it to analyze specific aspects of the document, verify hypotheses, or extract information.
>
> While RLM's have shown strength in their longer context management they are less efficient than traditional LLM's and use significantly more tokens. Additionally, the worker only sees what the orchestrator explicitly passes it: typically a targeted query and the raw document. But the orchestrator has been building up a rich trajectory of reasoning across many calls: hypotheses tested, passages identified, dead ends eliminated, cross references discovered. That accumulated context could help the worker answer more effectively, but passing it all as text inflates input costs with every successive call. The worker ends up working with a narrow view of the problem while the orchestrator's broader understanding sits unused.
>
> Standard solutions all have significant drawbacks:
>
> - LLM Summarization: 20–60s latency per step, lossy, summary may not capture what the sub task needs
>
> - RAG / Retrieval: Requires chunking and embedding, misses cross chunk dependencies
>
> - Pass everything: Expensive, slow, and accuracy can degrade with irrelevant context
>
> We wanted fast and precise cross agent memory to try and reduce this token explosion.
>
> ---
>
> ## Task Guided KV Cache Compaction
>
> **Background: The AM Compaction Framework**
>
> Our approach builds on the Attention Matching (AM) framework for KV cache compaction ([Zweiger et al., 2026](https://arxiv.org/abs/2602.16284)). The core idea is given a KV cache of size S , find a compact cache of size t < S that produces nearly identical attention outputs.
>
> Formally, for each attention head, we seek compacted components (C1, β, C2) such that:
>
> where:
>
> - C1 (compacted keys): a subset of the original key vectors selected for high attention
>
> - β (bias corrections): scalar adjustments that compensate for missing keys, ensuring the softmax distribution over kept keys approximates the original distribution over all keys
>
> - C2 (compacted values): reconstructed value vectors solved via ridge regression
>
> The original AM algorithm processes each (layer, head) pair independently. For Qwen3-14B, that means 40 layers × 8 KV heads = 320 serialized solves, each running three steps:
>
> 1. Token selection: compute attention scores between all queries and all key positions, then select the top t positions with the highest aggregate score.
>
> 2. Beta via NNLS: find bias corrections β so that softmax(q · C1ᵀ + β) approximates softmax(q · Kᵀ) for the kept tokens: solved via projected gradient descent with non-negativity constraints¹.
>
> 3. C2 via ridge regression: solve C2 = (XᵀX + λI)⁻¹XᵀY where X is the compacted softmax matrix and Y is the original attention output, reconstructing value vectors that preserve the attention computation.
>
> **Our Modifications:**
>
> We made three key changes to adapt AM compaction for the inference setting:
>
> **1. Task guided query vectors.** In the original AM framework, the queries used for scoring are sampled from the context itself. We replace these with queries derived from the orchestrator's task prompt for this specific worker call. This enables cache compression that prioritizes information most relevant to the worker task.
>
> The trajectory here is the orchestrator's full context window up to this point: prior worker responses, any REPL outputs, and the chain of thought reasoning.
>
> We forward pass the trajectory and the task prompt through the worker agent. The attention scores between the task prompt and the trajectory keys tell us which parts of the trajectory the worker considers relevant to its current task.
>
> ```
> K = trajectory KV cache keys
> Q = attention queries from the orchestrator's task prompt for this worker call
>
> For each (layer, head):
>     attn_{l,h} = softmax(Q · Kᵀ / √d)               # attention between task and trajectory
>     scores_{l,h}(pos) = RMS_q(attn_{l,h}(:, pos))    # RMS across task queries per position
> ```
>
> **2. Shared token selection via global scoring.** Instead of each head independently selecting its own top t keys, we aggregate scores across all layers and heads into a single per position relevance score:
>
> ```
> weight by head importance (from AM's optimized budget allocations):
>     position_score(pos) = Σ_{l,h} head_weight[l,h] · scores_{l,h}(pos)
> ```
>
> Instead of giving 320 editors their own copy of a manuscript to edit independently, we have them vote on which sections to keep.
>
> In the original AM paper, head importance weights were precomputed via optimization for specific models (e.g., Qwen3-4B). Since we use Qwen3-14B, for which no optimized budgets exist, we default to uniform head weighting. Despite this simplification, the consensus signal remains effective: tokens that many heads agree are worth attending to correspond to task relevant context.
>
> The shared mask allows us to perform batched execution, reducing overhead significantly with minimal performance reduction.
>
> **3. Thresholding with MAD normalization.** Rather than selecting a fixed number of tokens (top k), we keep every position that scores above a statistically derived threshold. MAD normalization provides a robust outlier metric:
>
> ```
> Keep position i if:
>     position_scores[i] > median + threshold · MAD
> ```
>
> The threshold parameter controls aggressiveness:
>
> *Compaction threshold parameter: retention rates and interpretation*
> ![[ramplabs-449223-002.jpg]]
>
> **Making Compaction Real Time:**
>
> The original AM algorithm cannot batch across attention heads because each head selects a different subset of tokens (e.g., head 0 retains positions {12, 45, 89, …} while head 3 retains {7, 45, 102, …}). As a result, the corresponding matrices have incompatible shapes and cannot be stacked into a single tensor operation. This forces sequential execution: for Qwen3-14B, 320 separate CUDA kernel launches are required, leaving the GPU largely underutilized as it waits for each small solve to complete. Although this approach yields high compression quality, it incurs substantial latency (30+ seconds on an A100 GPU) making it impractical for real time agent workloads.
>
> The shared global mask lets us stack all 320 solves into batched tensor operations. An adaptive batch sizer fills GPU memory per batch, typically 2–3 batches for all 40 layers. KV prefix caching reuses 90%+ of representations between calls, so only new tokens need a forward pass.
>
> We optimized GPU memory by applying in-place softmax, running phases sequentially, offloading the KV cache to the CPU, chunking prefills, and automatically halving batch size to recover from OOM errors.
>
> AM compaction goes from 30+ seconds to a median overhead of ~1.7s with these changes and scales linearly with trajectory length, but remains a small fraction of the overall call cost.
>
> *Worker call time breakdown showing compaction overhead (~1.7s) as a fraction of total call time*
> ![[ramplabs-449223-003.jpg]]
>
> ---
>
> ## Experimental Setup
>
> **How Latent Briefing Integrates with RLM**
>
> In the standard RLM setup, the orchestrator sends targeted (context, query) pairs to a worker via llm_query(). The worker receives this, processes it, and returns a response. Each call is independent, the worker has no memory of prior calls.
>
> With Latent Briefing, the worker maintains a persistent KV cache of the orchestrator's trajectory across calls. On each call:
>
> 1. The orchestrator's updated trajectory (including new reasoning and prior worker responses) is forward passed through the worker model, with KV prefix caching, typically 90%+ of tokens are unchanged from the previous call and reused directly
>
> 2. The orchestrator's task prompt for this call generates query vectors via attention to the trajectory
>
> 3. The trajectory's KV cache is compacted using these queries as the relevance signal
>
> 4. The worker agent is initialized with this compacted KV cache and generates its response
>
> The compacted cache preserves the contextual information the worker actually needs from the orchestrator's memory.
>
> **Benchmark**
>
> We evaluate a recursive language model (RLM) with Claude Sonnet 4 as the orchestrator and Qwen-14B as the worker on LongBench v2, a reading comprehension benchmark spanning diverse document types, including academic papers, legal documents, fiction, and government reports. We evaluated across three datasets and 4 compaction thresholds:
>
> *Benchmark dataset conditions*
> ![[ramplabs-449223-004.jpg]]
>
> Compaction thresholds: Baseline (no compaction, vanilla RLM) plus four compaction thresholds (t = −1.0, 0.0, 1.0, 2.0). Each threshold runs all questions with the same orchestrator prompt.
>
> ---
>
> ## Results
>
> **Accuracy: Compaction Matches or Improves Baseline**
>
> At the right threshold, briefing improves accuracy over the baseline, yielding a +3 pp gain across all three conditions. We find that the optimal threshold depends on the input data. Over-compacting discards information the worker needs, reducing accuracy, while under-compacting leaves too much noise relative to signal, diluting attention. As a result, the optimal threshold varies by condition. We discuss this further in the Analysis section.
>
> *LongBench v2 accuracy by compaction level across three dataset conditions*
> ![[ramplabs-449223-005.png]]
>
> *Accuracy results by dataset and compaction threshold*
> ![[ramplabs-449223-006.jpg]]
>
> **Token Efficiency: Significant Savings, Especially on Longer Documents**
>
> Across all three datasets and four thresholds, compaction consistently reduced token usage. At the optimal thresholds, median worker tokens dropped by 42–57% and median total tokens dropped by 21–31% while accuracy improved by 3 pp.
>
> *Total token usage per question across compaction levels*
> ![[ramplabs-449223-007.jpg]]
>
> *Worker model token usage per question across compaction levels*
> ![[ramplabs-449223-008.jpg]]
>
> Median token reduction relative to baseline:
>
> *Median token reduction relative to baseline by dataset and threshold*
> ![[ramplabs-449223-009.jpg]]
>
> Median token savings for best threshold:
>
> *Best threshold per dataset: accuracy change, worker and total token reduction*
> ![[ramplabs-449223-010.jpg]]
>
> ---
>
> ## Analysis: Why Different Thresholds Win in Different Regimes
>
> The best accuracy threshold varies systematically across conditions:
>
> **Longer documents → lighter compaction wins (t=−1.0).** On 32k–100k documents, the best accuracy comes from t=−1.0 (18% compaction). Longer documents contain more dispersed information. Light compaction preserves broad coverage while still achieving 57% worker token savings.
>
> **Harder questions → aggressive compaction wins (t=2.0).** On hard questions, t=2.0 (79% compaction) outperforms the baseline by 3 points. Hard questions lead the orchestrator to explore many hypotheses, generating speculative reasoning in its trajectory. This speculative content dilutes the signal for the worker. Aggressive compaction acts as a relevance filter, stripping away the noise and giving the worker a cleaner, more focused signal.
>
> **Short, easy documents → moderate compaction (t=1.0).** On Easy <32k, t=1.0 (68% compaction) provides the best accuracy. The orchestrator's trajectory is shorter and more focused, so moderate compaction effectively removes redundancy without risking information loss.
>
> Conceptually, this is a bit like taking notes. Sometimes you're trying to build a body of knowledge over time, and the details matter because they accumulate into something larger. In those cases, you want to preserve context rather than compress it too early. With harder problems you're often sketching ideas, exploring directions, following threads that may or may not lead anywhere. Most of what gets written down in that process isn't meant to last.
>
> ---
>
> ## Limitations
>
> **Orchestrator variance.** The Claude Sonnet 4 orchestrator is non deterministic, leading to different decomposition strategies across runs for the same question. With n=42 per condition, individual results are noisy, though the aggregate trends are consistent.
>
> **Single benchmark.** We tested exclusively on LongBench v2. Other task types may have different attention patterns and compaction characteristics, i.e. code generation, multi document synthesis, mathematical reasoning.
>
> ---
>
> ## Conclusion
>
> Latent Briefing reduces token usage in multi-agent systems by operating directly on the worker model's internal representations. In our experiments, it achieves substantial token savings without degrading accuracy, while remaining practical to deploy in agent pipelines.
>
> The approach is:
>
> - Fast: ~1.7s per compaction, ~20× faster than sequential AM, and 10–30× faster than LLM summarization
>
> - Task-adaptive: different queries compress the same context differently
>
> - Effective: maintains or improves accuracy while reducing token usage
>
> - Predictable: MAD-normalized thresholding yields consistent compression rates
>
> As agent architectures grow deeper and wider, cross agent context management becomes a bottleneck. Token usage compounds across agent calls, making efficiency a first order concern in system design. Beyond improving intelligence per token within individual agents, there is increasing value in how efficiently tokens are used across agents in the system as a whole, saving time and money.
>
> ---
>
> ¹ We improved convergence by initializing β to ones (a natural prior for well distributed attention) rather than the default least squares then clamp approach, which often produces many negative values that get clamped to near zero, a poor starting point.
>
> ² A difficulty score is contained within the dataset.
>
> ---
>
> Research author — Ben Geist [@b_geist](https://x.com/b_geist)
>
> Engagement: 384 likes | 31 retweets | 15 replies
> [Original post](https://x.com/RampLabs/status/2042660310851449223)
