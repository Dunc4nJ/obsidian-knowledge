---
created: 2026-09-27
source: https://fsdatalab.github.io/blog/introducing-quail/
via: https://x.com/sh_reya/status/2103207153821688056
author: Shreya Shankar, Charles Frye, Fergus Finn, Arnav Dhariya, Joseph Barrow, Meryem Arik (FS Data Lab / Modal)
published: 2026-09-24
type: knowledge
tags: [data-agents, ai-sql, semantic-operators, inference-engine, kv-cache, prefill, vllm, modal, quail, docetl, lotus, throughput]
description: Quail (QUery-Aware Inference Layer) is an MIT-licensed AI-SQL execution engine from CMU's Full Stack Data Lab and Modal that plans the SQL query and the LLM forward passes as one problem. The diagnosis is that a hand-tuned vLLM baseline running BIO-4 (three AI filters, two AI joins over 5,000 BioDEX medical reports and 4,144 reaction terms) takes 6.84 hours against a 14.91-minute speed-of-light estimate — 27.55x — for two reasons: CPU host overhead leaving the H100 idle between execute_context blocks, and KV regret, 174.6M tokens processed instead of 124.3M (50.3M extra, 40% more work) because vLLM discards KV it needs later. Quail fixes both by ordering operators and join anchors with a roofline cost model, streaming survivors between operators with their KV pinned in HBM, "rewinding" KV to the document prefix after each predicate, and running a depth-one tree attention for joins so one anchor's KV is read once for all partners. Across 29 QUAIL-B queries at scale factor 0.1 it beats stock vLLM on 27, geometric mean 1.84x, max 11.22x on BIO-2; on BIO-4 at scale factor 1.0 it is 14.04x (29.26 minutes vs 6.84 hours) and hits 19.03 million requested input tokens/second, the 1.14 billion tokens per minute of the headline. It loses on the two AGENT queries, 2.32x on AGENT-1, because vLLM's automatic prefix cache reuses matching prefixes across rows of the same agent trace and Quail has no cross-row prefix caching yet — 11.89M KV regret tokens against vLLM's 23,928.
---

## Key Takeaways

- **The thesis is one sentence and it is the right one: "Query plans should control LLM inference."** Every prior system in this lineage — the lab's own [DocETL](https://docetl.org/), Stanford's LOTUS, MIT's Palimpzest, Cornell's ThalamusDB, and the vendor AI functions in Snowflake Cortex, BigQuery and Databricks — reduces AI-SQL cost by *eliminating LLM calls* (cascades, cheaper models, [[BARGAIN routes classification to a small model via a confidence threshold calibrated on 500 oracle labels, cutting costs up to 86 percent more than competing cascades|BARGAIN's calibrated routing]], which is Shankar's own prior work). Quail takes the calls as given and attacks the *execution* of the surviving millions. The insight that makes this tractable is that AI-SQL is a degenerate inference workload in three ways at once: **every request is entirely prefill** (one constrained token, TRUE or FALSE, so there is no decode phase, no sampling, no speculative decoding, no CUDA graph capture), **nearly all requests are known before execution starts** (so eviction is never a guess — "we know exactly when any cache entry is no longer needed, so we can fearlessly evict it"), and **nobody cares about per-request latency**, only total query time. As the thread puts it: "Not like the interactive request setting that general-purpose inference engines are optimized for." This is the concrete engineering answer to [[Berkeley's EPIC Data Lab argues near-free intelligence makes agents the dominant data-systems workload, needing data systems for, of, and by agents|EPIC Data Lab's "data systems for agents" agenda]] and the runtime half of what [[Snowflake, Databricks and ClickHouse preview AI architecture by turning inference into a database operator, the semantic layer into agent infrastructure, and agents into a new database workload|Josh Rosen called inference becoming a database operator]] — Rosen quote-tweeted this thread to make exactly that point: "Quail is a great example of how it's more than finding a new syntax. It's about syntax plus matching runtime."

- **Two numbers are circulating and only one of them is the honest summary — they describe different queries at different scales, and the big one is a prompt-level metric, not a GPU-throughput metric.** The **1.84x geometric mean** is the benchmark result: 29 QUAIL-B queries, scale factor 0.1, Qwen3 4B FP8 on one H100, Quail ahead on 27 of 29, total 1,643.74 s against stock vLLM's 4,451.95 s. The **1.14 billion tokens/minute** is a single query — BIO-4 at scale factor 1.0, where Table 2 reports **19.03 million requested input tokens/second** (×60 = 1.142 B/min, which Modal's chart rounds to 1.14B). Table 1's BIO row, 12,296,410 tokens/s, is the four-query BIO *average at scale factor 0.1* and works out to 738M/min, below the headline. Crucially, the metric is defined as "the total requested input tokens divided by query runtime. **Each evaluated prompt contributes its full input length, including tokens served from KV**" — so on a join where one 3,000-token medical report is compared against thousands of reaction terms, every pair re-counts the whole report. The number is a faithful measure of *logical work avoided*, and it is exactly the metric that rewards the thing Quail is good at, but it is not forward-pass throughput; the 33.4 billion "requested" tokens behind BIO-4 were never all pushed through the model. Modal's framing is the cleanest honest version: "under 6¢ per billion tokens."

- **Quail wins where prefixes repeat *within* a query plan and loses where they repeat *across rows* — and the losing case is the vault's single biggest data-agent workload.** The mechanism is symmetric. Quail knows that the same medical report will be joined against a second reaction-term table, so it pins that report's KV in HBM across both joins and never recomputes it; vLLM does not know and evicts by LRU. But AGENT-1 filters 1,772 *cumulative snapshots* of software-agent runs, where `trace_42_turn_10` literally contains `trace_42_turn_5` as a prefix — different documents, overlapping token prefixes. vLLM's automatic prefix cache catches that for free; Quail "currently reuses KV only when the same document appears again in the query, not across different documents." Result: **11,886,152 KV regret tokens for Quail against 23,928 for vLLM**, 239.12 s against 103.07 s, 2.32x. Shankar published the loss deliberately and Modal says why: "We added this benchmark specifically because we wanted to demonstrate that our system, as we initially constructed it, was making a trade-off, rather than somehow being universally better." That is the right instinct, and it means the honest read for this vault is blunt: **for agent-trace analytics — the workload behind [[agent trace data should live in your data lake not a 30-day SaaS retention window|traces in the lake]], [[Applied Compute freezes a Sol-built 14-label taxonomy so Jev annotates the corpus - ECE 0.051 against Luna's 0.154 and 85 percent recall at 0.20, with every rival left at Jev's threshold|Applied Compute's corpus annotation]] and the repo's own agent-trace-compaction demo — Quail is currently the slower choice.** The fix is named (a radix index over documents; automatic prefix caching) but unbuilt, and the [[LMCache offloads paged KV to system RAM and NVMe, cutting 128K-context time-to-first-token from 68 seconds to 1.4 on 4x DGX Spark|LMCache]] and [[Red Hat frames prefill-decode disaggregation, KV-cache tiering, and speculative decoding as the three llm-d deployment levers for distributed AI inference|llm-d cache-aware routing]] notes are the measure of how much is on the table.

- **The diagnosis of vLLM is the transferable part, and one half of it is the second independent instance of the same finding in this vault.** vLLM 0.26.0 on BIO-4 at scale 1.0 took **6.84 hours against a 14.91-minute speed-of-light estimate — 27.55x**. Cause one is *host overhead*: the PyTorch profiler window in Figure 2 shows the CPU main thread alternating between `vllm.scheduler` work and `execute_context`, with GPU stream 25 active only inside the three `execute_context` blocks and idle in the gaps. That is precisely [[Perplexity serves embeddings by treating them as a CPU-overhead problem - whole-model CUDA graphs and LazyTensors cut p50 from 4.60ms to 1.53ms while throughput stays at parity with vLLM|Perplexity's embedding-serving diagnosis]] arrived at independently on a different workload: many small requests against a small model on a big GPU is a CPU-scheduling problem before it is a kernel problem. Cause two is *KV regret*, which the post defines crisply as "repeated model work: fresh input tokens beyond the minimum needed to compute each reusable prefix once" — **174.6M tokens processed instead of 124.3M, 50.3M extra, 40% more work**. Both are structural consequences of an engine built for arbitrary client-controlled requests, which is the same root cause behind [[paged attention applies OS virtual memory paging to KV cache and unlocks 2-4x LLM serving throughput|PagedAttention's]] and [[Amit Shekhar explains how vLLM packs more LLM users onto one GPU through PagedAttention and continuous batching|continuous batching's]] design choices; Quail's answer is that when the client can only submit a *query*, the engine can stop guessing.

- **Economically this is the open, self-hosted, general-LLM route to the same per-row-classification economics the Jev cluster buys from a vendor — and §5 says so explicitly.** The section title is "Quail brings Jev-like speeds and intelligence to database-scale workloads," and Modal's companion post opens with Karpathy on Jev. The measured comparison: the 100,000-review two-filter quickstart costs **$0.3675 on one H100 at Modal's $3.9492/GPU-hour, including model startup, against about $1.75 at GPT-5 nano's cached-token prices — 4.8x**; the playground's 10,000-review run shows $0.0307 against a gpt-5-nano estimate of $0.174 with prompt caching or $0.224 without. Set that beside [[MotherDuck's prompt_jev labels 100k AG News rows in 40 seconds for 50 cents at 89 percent - a benchmark fine-tuned encoders beat by 5 points, metered at a 25 percent markup over TypeSafe list|prompt_jev's 100k rows in 40 seconds for 50 cents]] and [[pg-jev]]'s ~$6 per million rows: Quail lands in the same price band with an **open-weight general model you control**, at the cost of renting an H100 and running the thing yourself. The trade is real in both directions — [[TypeSafe's Jev trades string generation for parallel-sampled typed decisions with calibrated probabilities at $0.042 per MTok - the 193x and 444x claims come from four self-built workflow evals|Jev gives you calibrated probabilities and a hosted API]] and Quail gives you a Qwen3 or a 26B MoE, your own prompts, and no per-token markup. A replier asked the obvious question — "Do you need an LLM to do this or could we combine this with something like Jev?" — and the repo already contains the experiment: `demos/civil_comments/jev_backend.py` sits next to `quail_backend.py` for a head-to-head on 10,000 Jigsaw Civil Comments rows. **No Jev numbers are published yet**; the docs page shows only the Quail row (85.53 s, 284,022 tokens/s, $0.0938, filter F1 0.413, join F1 0.287 on DiffusionGemma 26B-A4B FP8).

- **Caveats, in the order that would change a decision.** (1) The baseline is a *well-tuned* vLLM — same model, same prompts, same logical plan chosen by Quail's own planner, automatic prefix caching on, 25,305 max batched tokens, 0.91 GPU memory utilization — so the comparison is fair, but Quail is still **3.35x off its own speed-of-light estimate** on the full benchmark and 1.96x on BIO-4, so "beats vLLM" and "efficient" are different claims. (2) **Three models, all FP8, essentially one GPU class**: Qwen3 4B and DiffusionGemma 26B-A4B on H100 SXM, Qwen3 32B on RTX PRO 6000 Blackwell. No MacBook, no Mac Studio (a replier asked), no A100, no consumer card. (3) The 29 queries are **QUAIL-B, authored by the same lab** — the same self-built-benchmark caveat that attaches to [[DAB benchmark exposes frontier data agents at 38 percent pass at 1 with 85 percent of failures in planning or implementation|DAB]] and to nearly every note in this folder — and the benchmark's own README is unusually candid about it: "**Accuracy is not a focus of this benchmark.** Most labels are the answers of one arbitrary model, `Qwen/Qwen3-32B-FP8`, so it is not really meaningful to measure accuracy against them. We provide these fake labels anyway." Only the FEVER and LePaRD joins have real labels. Quail is measured on speed at fixed answers, not on whether the answers are right. (4) The $/query figures price a **rented H100 at Modal's list rate**, which is the right comparison only for sustained throughput; an idle GPU between queries destroys the 4.8x. (5) The sharpest reply is John Rood's, and the post does not answer it: "one mid-query failure that re-issues completed operators eats the whole speedup. key operator outputs by the row that produced them so the plan doubles as the retry graph and a retry only re-runs what changed." A 6.84-hour-class workload compressed to 29 minutes is still 29 minutes of un-checkpointed GPU time; the repo has run-level durability (`quail/server/checkpoint.py` mirrors the SQLite run store to a Modal Volume) but **no operator-level result cache**, so a crash re-runs the query. (6) Mind the version drift already: the blog evaluates **29** queries, `quail-bench`'s README now says **31**.

## The workload - why AI-SQL breaks an interactive inference engine

AI-SQL extends SQL with user-defined functions that take a natural-language prompt and call an LLM per row. The canonical shape, from the thread:

```sql
SELECT * FROM reviews
WHERE AI.IF("the review discusses the ending")
  AND AI.IF("the review recommends the movie")
```

An AI filter is one model call per row; a naive AI join is one call per candidate *pair*, m × n. "One query can generate millions of LLM calls, needing ultra-high throughput!" Snowflake Cortex AISQL, BigQuery `AI.IF`, Databricks AI Functions and now MotherDuck all ship a flavor of this, and the academic line runs through DocETL (Berkeley), LOTUS (Stanford), Palimpzest (MIT) and ThalamusDB (Cornell). Modal's post draws the line that matters for anyone confusing this with text-to-SQL: "This is emphatically *not* prompting AI systems to produce SQL based on natural language inputs — that's NL2SQL... It's actually the other way around! In AI-SQL, we use an extension of SQL to programmatically produce (and consume) prompts for AI systems." Compare the vault's other answers to putting inference inside the pipeline — [[RLMs inline intelligence into data pipelines by giving LLMs symbolic access to DataFrames in a persistent REPL|an LLM with symbolic access to DataFrames in a REPL]] and [[semantic SQL parsing makes data transformations programmatically validatable which is what data agents need underneath them|SQL-as-analyzable-IR]] — Quail is the third position: keep the query as the program, compile it down to the GPU.

Modal's argument for why this workload is *interesting* rather than merely expensive is the best framing in either post. Filters and joins over string equality have arithmetic intensity near zero and no business on a GPU; `AI_FILTER` and `AI_JOIN` subject each loaded byte "to on the order of billions of operations." And because `AI.IF` needs exactly one token, "the final 'prefill' forward pass during input sequence processing emits a prediction for a single token. And for Boolean classification of a sequence, aka `AI.IF`, a single token is all you need — literally." Hence the list of things Quail does *not* implement: prefill/decode disaggregation, sampling, CUDA graph capture, and [[Modal argues speculative decoding is the only inference optimization that matters, and custom DFlash speculators turn acceptance length into 2-3x speedups|speculative decoding]] — Modal's own house optimization, explicitly dropped here because "that accelerates decodes of more than one token."

## The vLLM diagnosis - host overhead and KV regret

BIO-4 is the running example: "Given a dataset of medical reports and a dataset of possible adverse reactions, find serious adverse event reports that mention both a cardiovascular reaction and a neurological reaction." At scale factor 1.0 it is 5,000 long BioDEX reports and 4,144 reaction terms used twice, three AI filters and two AI joins, both joins anchored on the report.

Before measuring, the team computes a **speed-of-light estimate**: count arithmetic work and HBM traffic from token lengths, price each model component against the GPU with a [roofline model](https://modal.com/gpu-glossary/perf/roofline-model) (the same [[Modal's GPU Glossary is a browsable reference that maps the GPU stack from device hardware through the CUDA software layers to performance concepts in ~80 linked terms|GPU Glossary]] that anchors Modal's other performance writing), and assume peak throughput, full CPU/GPU overlap and unlimited KV space. **894.37 seconds, 14.91 minutes.** vLLM 0.26.0 with Qwen3 4B FP8 on one H100 took **6.84 hours — 27.55x**.

| Waste | Evidence | Magnitude |
| --- | --- | --- |
| Host overhead | Figure 2, a 3.5-second PyTorch profiler window from the first join: CPU alternates `vllm.scheduler` and `execute_context`; GPU stream 25 runs only inside three `execute_context` blocks | H100 idle in every gap |
| KV regret | vLLM discards KV it needs again later | 174.6M tokens processed vs 124.3M minimum — 50.3M extra, 40% more work |

"KV regret" is worth adopting as a term: *fresh input tokens beyond the minimum needed to compute each reusable prefix once*. It is a plan-relative metric, not an engine-relative one, which is why it can be computed for both systems and why it drops out of the speed-of-light model directly.

## How Quail plans the query and the inference together

The three stated performance goals, verbatim:

> 1. Minimize KV regret.
> 2. Keep the GPU busy by reducing CPU scheduling overhead.
> 3. Reach high model FLOP/s utilization (MFU) while the GPU is active.

"Our current evaluation focuses on the first two goals. We defer a full MFU study to future work." Architecturally it is a frontend, a planner and an execution engine, "inspired by Apache DataFusion" and extensible at every seam (operators, planning rules, backends, models, hardware).

**Planning.** SQLGlot parses Snowflake `AI_FILTER` or BigQuery `AI.IF` into a logical plan. The planner estimates dataset statistics, computes the forward-pass token budget and fixed KV capacity from model and GPU (reserving HBM for weights plus *two* forward passes — the code's `retention_pages()` makes this literal: `arena_tokens // page_tokens - ceil(2 * chunk_tokens / page_tokens)`), then applies textbook SQL rewrites with an inference-aware cost function: projection and filter pushdown, filter ordering by cost and selectivity per [Hellerstein and Stonebraker](https://dsf.berkeley.edu/jmh/miscpapers/sigmod93.pdf), and a Selinger-style System R search for join order *and anchor*. Modal adds the detail the lab post omits: the join search keeps a **Pareto frontier** — "We eliminate plans only if a new candidate plan has fewer tokens, fewer attention pairs, and fewer cached tokens — it has been 'dominated', in the Pareto sense" — and only then applies the speed-of-light estimate to pick a winner, because a locally bad join may hold KV a later join wants.

**The KV manager** is the mechanism behind goal 1 and the one worth understanding. Quail places the document *before* the predicate-specific question. After a predicate returns TRUE or FALSE it discards the predicate KV and **"rewinds" to the end of the document KV** — retaining only the prefix a future operator can reuse, never the whole prompt. If the row passed and another AI operator needs it, the rewound KV stays pinned in HBM; otherwise it is released immediately. Against this the post lists what a general-purpose engine does: retains *all* of a request's KV including the suffix that will never be reused, keeps KV for rows the query has already filtered out, and evicts by LRU. Eviction in Quail is not LRU and not, despite the prose, simply "shortest first": `quail/cost/retention.py` scores each retained prefix by **probability of reuse × recompute seconds ÷ pages**, where recompute seconds is `linear_seconds × tokens + pair_seconds × triangle(tokens)` — the `triangle` term is attention's quadratic cost, which is what makes long documents expensive to lose. The reuse probability comes from `quail/planner/retention.py`, which walks the join groups and records, at every execution boundary, both the index of each alias's next use and the fraction of its rows expected to survive until then. [[Baseten's STILL perceiver amortizes KV cache compaction into one forward pass, compressing 8x at 85%+ factual retention|Compaction]] and [[LMCache offloads paged KV to system RAM and NVMe, cutting 128K-context time-to-first-token from 68 seconds to 1.4 on 4x DGX Spark|tiering]] are the two levers Quail has not pulled yet; §6 names both.

**Streaming, not staging.** "Drawing inspiration from vectorized query execution, Quail streams intermediate results directly between operators rather than materializing complete datasets." In BIO-4, a batch of reports that passes the first filter pipelines straight into the first join with its KV already resident, and stays resident through the second. The executor is pull-based à la Volcano but batch-at-a-time à la MonetDB; tokenization happens once, up front, with [Gigatoken](https://github.com/marcelroed/gigatoken) (Marcel Rød, Stanford), and token IDs live in memory-mapped Arrow files.

**Three changes to the forward pass**, on top of vLLM's model implementations ("We did not reimplement every model and GPU operation from scratch. That would be silly"):

1. **Fused Triton kernels** — normalization with FP8 quantization, Q/K normalization with RoPE, activation with FP8 quantization. "This is extremely easy to do now with AI agents; it requires no novel kernel design ideas." The [[Ahmad Osman's kernel curriculum - you don't run a model you run kernels, and here are eight mini-projects from RMSNorm in Triton to a custom op profiled inside vLLM|Triton-kernel curriculum]] in the vault is exactly this list of fusions.
2. **Join attention as a depth-one tree.** An AI join compares one anchor with many partners; vLLM treats each pair as its own sequence and re-reads the anchor KV once per partner. Quail groups partners by anchor and computes the anchor KV once, then runs two FlashAttention 3 calls — causal attention within each partner suffix, and all partner queries against the shared anchor KV — merging them with log-sum-exp and the [online softmax](https://arxiv.org/abs/1805.02867) formula for a bit-equivalent result, with one Triton kernel doing the merge and the FP8 conversion for the output projection. The lineage is SpecInfer and Hydragen, and Modal adds FlashInfer's cascade attention and flash-decoding; "Quail applies the same structure, but during prefill." The code confirms the two paths: `FILTER_ATTENTION = "unified"` (one causal paged call after scattering current KV into the arena) and `JOIN_ATTENTION = "merge_quant"` (two calls plus the fused merge-and-quantize kernel). Modal notes the simplification that makes it cheap: "Suffixes' KV are not written to cache — we're doing zero decode, and we never do (N>2)-way joins, so we don't need them!"
3. **An 8-row language-modeling head.** Only TRUE and FALSE scores are needed, so the final unembedding matmul shrinks from `vocab × latent` to `8 × latent`. Eight, not two, because Qwen spells each answer four ways: `TRUE` (20611), `␠TRUE` (8214), `True` (2514), `␠True` (3007), `FALSE` (30351), `␠FALSE` (7833), `False` (4049), `␠False` (3557). Modal calls it "an extreme case of structured outputs."

## Results

**QUAIL-B, 29 queries, scale factor 0.1, Qwen3 4B FP8 with BF16 KV on one H100.** Quail and each vLLM baseline run back to back on the same physical GPU with the same model, prompts and logical plan. Quail wins 27 of 29; geometric mean **1.84x**; maximum **11.22x on BIO-2**. Totals: 1,643.74 s against 4,451.95 s, with a combined speed-of-light estimate of 491.17 s — Quail is 3.35x off its own bound.

| Dataset | Quail | Stock vLLM |
| --- | --- | --- |
| BIO (4 queries) | 12,296,410 tokens/s · 157,995 KV regret · $0.0892/query (1.00x) | 1,420,421 tokens/s · 1,441,816 KV regret · $0.7771/query (8.72x) |
| IMDB (10 queries) | 649,864 tokens/s · 451,917 KV regret · $0.0282/query (1.00x) | 382,818 tokens/s · 1,129,174 KV regret · $0.0467/query (1.66x) |
| FEV (8 queries) | 1,692,276 tokens/s · 408,592 KV regret · $0.0383/query (1.00x) | 724,574 tokens/s · 519,588 KV regret · $0.0820/query (2.14x) |
| LEP (5 queries) | 388,903 tokens/s · 2,147 KV regret · $0.0670/query (1.00x) | 316,617 tokens/s · 70,982 KV regret · $0.0853/query (1.27x) |
| AGENT (2 queries) | 73,006 tokens/s · 11,886,152 KV regret · $0.2616/query (1.00x) | 169,201 tokens/s · 23,928 KV regret · $0.1129/query (0.43x) |

Figure 8 adds the percentages the table omits — every bar as a fraction of that dataset's speed-of-light estimate. BIO 49.9% for Quail against 5.8% for vLLM; IMDB 36.8% / 21.7%; FEV 41.1% / 17.6%; LEP 40.9% / 33.3%; AGENT 20.0% / 46.3%. Nothing clears half of the bound.

**BIO-4 at scale factor 1.0** is the headline query.

| Metric | Quail | Stock vLLM | SoL estimate |
| --- | --- | --- | --- |
| Requested input tokens/s | 19.03 million | 1.36 million | 37.37 million |
| GPU cost per query | $1.93 | $27.03 | $0.98 |
| KV regret | 18.0 million | 50.3 million | 0 (assumed) |

29.26 minutes against 6.84 hours: **14.04x**, or 1.96x the bound against vLLM's 27.55x. Pipelined vLLM still takes 4.00 hours. Modal's chart restates it as 1,755 s / $1.93 / **1.14B tokens per minute** against 24,641 s / $27.03 / 82.6M — though note that chart labels the baseline "pipelined vLLM" while its numbers (24,641 s = 6.845 h, $27.03) are the lab post's **stock** vLLM figures, so the label looks like an error.

**AGENT-1** is the published loss. 1,772 cumulative snapshots of software-agent runs, one filter: "Did the agent recover after trying an approach that did not work?" Stock vLLM finishes in 103.07 s, Quail in 239.12 s — **2.32x** — against a 47.47 s bound. Throughput 73,006 vs 169,201 vs 367,400 tokens/s; cost $0.2623 vs $0.1131 vs $0.0521; KV regret 11,886,152 vs 23,928. The cause is structural and stated plainly: rows share token prefixes because `trace_42_turn_10` contains all of `trace_42_turn_5`, vLLM's automatic prefix cache sees it, Quail's document-identity reuse does not. Worth noting that Quail's *own* speed-of-light model already credits cross-document prefix sharing — `quail/planner/prefixes.py` computes `shared_prefix_lengths` over the corpus — so the bound knows about the reuse the engine cannot yet exploit.

**Pipelining**, Figure 10, isolates how much of the gap is scheduling rather than KV. Letting vLLM submit the next filter for a document as soon as the previous returns TRUE beats stock vLLM on 7 of 8 multi-filter queries, average 1.12x, best 1.27x on IMDB-6 (30.1% → 38.3% of SoL); FEV-6 is the one that does not move (26.3% → 26.2%). Cheap, but a fraction of what joint planning buys.

**Cost and the Jev-class comparison.** Quickstart, 100,000 IMDB reviews, two filters, one H100: 16,057 matches, 277.41 s wall (335.06 s including a 57.65 s cold boot), 32,499,738 fresh tokens, 360.5 documents/second, **$0.3675 at $3.9492/GPU-hour including startup**, against **about $1.75 at GPT-5 nano's cached-token prices — 4.8x**. The live playground run in the video gives the same comparison at 10,000 reviews with the arithmetic exposed: 28.0 s, 156,449 tokens/second, 4.38M requested input tokens (1.11M from KV, 3.27M fresh), 44.4k KV regret, **$0.0307**, against a gpt-5-nano estimate of **$0.174 with prompt caching** (3.27M × $0.05/1M + 1.11M cached × $0.005/1M + 12,744 output × $0.4/1M) or **$0.224 with no cache hits**.

**Intelligence, not just speed.** §5's other result: DiffusionGemma 26B-A4B FP8 (4B active per token) on IMDB-2 at scale 0.1 matched **88.89%** of Qwen3 32B's answers against Qwen3 4B's **76.41%**, at 32.41 s versus 21.20 s — 1.53x the time for a large fraction of the accuracy gap. That is the closest thing in the post to an accuracy-per-dollar curve, and it is one query.

## The Jev bridge

> **5. Put another way: Quail brings Jev-like speeds and intelligence to database-scale workloads.**
>
> Quail also supports DiffusionGemma 26B-A4B FP8, a larger mixture-of-experts model with 4B active parameters per token. This gives Quail a higher-intelligence option that is still extremely fast. On IMDB-2 at scale factor 0.1, DiffusionGemma matched 88.89% of Qwen3 32B's answers, compared with 76.41% for Qwen3 4B. It ran the query in 32.41 seconds, or 1.53x as long as Qwen3 4B's 21.20 seconds, on one H100.
>
> This fits a broader class of workloads that need fast, bounded model decisions instead of long generated responses. Jev has highlighted the demand for this pattern in application backends. Quail targets its batch, online analytical processing (OLAP) version: one query creates thousands or millions of related decisions over a dataset, and Quail plans and runs them together. This makes Quail a good fit for LLM judge workflows, trace compaction, labeling, and other large-scale data transformations.

The division of labour is clean and matches [[Josh Rosen's Jev in the Wild sorts week-one projects into routing, context filtering, tool gating, worker supervision, fast control loops and fuzzy data queries - deterministic only because inference was expensive|Rosen's taxonomy of what Jev got used for in week one]]: Jev serves the OLTP shape (a bounded decision inside a request path, at the JSON layer, as Modal puts it), Quail serves the OLAP shape (millions of related decisions planned as one query). [[MotherDuck's prompt_jev labels 100k AG News rows in 40 seconds for 50 cents at 89 percent - a benchmark fine-tuned encoders beat by 5 points, metered at a 25 percent markup over TypeSafe list|MotherDuck's `prompt_jev`]] sits awkwardly between them — it is the OLAP shape served by the OLTP vendor, metered at a 25% markup — and the thread contains the moment that matters: Hamilton Ulmer of MotherDuck says "this is amazing," Shankar replies "Yes we should collab!! Really exciting to see what you are doing re LLMs in motherduck — I'll send you an email soon :-)". The cost-structure comparison, which is where a reader should actually make a decision:

| Route | What you get | Price signal |
| --- | --- | --- |
| Quail | Open-weight general LLM (Qwen3 4B/32B, DiffusionGemma 26B-A4B), your prompts, MIT, self-hosted on a rented H100 | $0.0892/query BIO average, $0.3675 for 100k two-filter IMDB rows, $3.9492/GPU-hour |
| [[MotherDuck's prompt_jev labels 100k AG News rows in 40 seconds for 50 cents at 89 percent - a benchmark fine-tuned encoders beat by 5 points, metered at a 25 percent markup over TypeSafe list\|`prompt_jev`]] | Vendor Jev inside the warehouse, no infrastructure | ~$0.50 per 100k AG News rows, 25% markup over TypeSafe list |
| [[pg-jev]] | Jev calls from Postgres | ~$6 per million rows at ~148 input tokens/row |
| [[TypeSafe's Jev trades string generation for parallel-sampled typed decisions with calibrated probabilities at $0.042 per MTok - the 193x and 444x claims come from four self-built workflow evals\|Jev direct]] | Typed decisions with calibrated probabilities | $0.042 per MTok |

Quail's answer to "could we combine this with something like Jev?" is already half-written in the repo: `demos/civil_comments/` holds a `quail_backend.py` and a `jev_backend.py` over the same 10,000 Jigsaw Civil Comments rows, the same 30-field join, and the same accuracy harness, with the Jev side batching every question for one comment into a single API request and thresholding Jev's `noul` probability at 0.5. The published results table carries only the Quail row.

## Roadmap and limits

§6 names the gaps, and the two the authors volunteer against themselves are the two that decide adoption. **Prefix caching across rows** is missing, which costs them AGENT-1 and, with it, agent-trace analytics; Modal's version of the fix is "a radix tree index over documents," and Modal goes further, pointing out that the agent benchmark "can be mapped into agent serving — simply store all session histories in the database, then `SELECT` those histories with a new input message and run `AI_COMPLETE`," which would make cross-document sharing the dominant case rather than the exception. **Prefill-only** is the other: Ani Mysore, after Shankar's SF Systems talk, asked "how to schedule projections given this is designed right now for prefill only workloads" — `AI.CLASSIFY` maps onto one token with prompt cleverness, but `AI.EXTRACT` and `AI.MAP` generate, and generation means decode, which means the entire "no decode" simplification stops holding.

The rest of the list: multi-tier KV (host memory, SSD, "perhaps we might feed our LLM from tapes?"), caching *across* queries ("we don't toss Bloom filters or zone maps in the trash so why do it with KV cache?"), larger-than-memory datasets, better kernel overlap (a megakernel or CUDA programmatic dependent launch), tiny hybrid models so Quail runs on a MacBook, training small proxy models to predict selectivity and survivors for the planner, and the genuinely interesting open question: **can an AI join work like a hash join?** — encode every document once, use its KV as a position-independent index entry, and probe rather than recompute, "which may require removing or separating the position information that RoPE adds to KV."

Both posts close on process. "We used AI coding agents heavily to build the current version of Quail... The hard part was no longer execution on ideas, but problem definition and result measurement — taste and quality assurance." Modal generalizes it into a prediction that inference engines will end up "a bit more like databases post-DataFusion: a reusable 'core' that is expressive enough to absorb new techniques but controlled enough to provide guarantees."

## The thread and the replies

Shankar posted eight tweets on 24 Sep 2026 at 19:37 UTC — 221 likes, 31 retweets, 28 replies as captured — leading with a 27.6-second screen recording of the playground running the two-filter IMDB query live. The substantive responses:

- **Josh Rosen** (@JoshARosen) quote-tweeted his own "AI Is Outgrowing Our Programming Languages" article to place Quail: "Quail is a great example of how it's more than finding a new syntax. It's about syntax plus matching runtime." This is the direct continuation of [[Snowflake, Databricks and ClickHouse preview AI architecture by turning inference into a database operator, the semantic layer into agent infrastructure, and agents into a new database workload|his read of Snowflake, Databricks and ClickHouse]].
- **John Rood** (@johnroodepic) raised the failure-cost objection quoted in the takeaways — key operator outputs by producing row so the plan doubles as a retry graph. Unanswered in either post.
- **Yi Casillas** (@YiCasillas), in Chinese: 1B+ tokens/min on one H100 is striking, but what he wants to see is *which rows the planner decides are worth a model call*; if every candidate enters the LLM, high throughput gets eaten by wasted tokens and result checking, and how that denominator is defined says more about Quail's real sweet spot than the peak number does. This is the same question the [[BARGAIN routes classification to a small model via a confidence threshold calibrated on 500 oracle labels, cutting costs up to 86 percent more than competing cascades|BARGAIN]] line of work answers from the other side, and Quail deliberately does not: it optimizes execution of the calls a plan already contains.
- **Anil Pervaiz** (@anilpervaiz): "Publishing the AGENT-1 loss is the most useful part for agent folks. Our traces are exactly that shape. Is cross-row prefix sharing on the roadmap?" Yes, and unbuilt.
- **Ani Mysore** (@ani_mysore) on scheduling projections in a prefill-only engine, above.
- **Hamilton Ulmer** (MotherDuck) and Shankar's collaboration reply; **Meryem Arik** (Doubleword, and a co-author) congratulating; **Ankur Goyal**, **Connor Shorten**, **Ganesh Swami**, **Victor Mota** (who first read it as the problem Stonebraker was describing), and others reacting.
- One reply is simply wrong: "There are no mentions of Github repo or website" — tweet 8 links the blog, the code and the playground.

## External resources

- [Building an Ultra-High Throughput AI-SQL Engine](https://fsdatalab.github.io/blog/introducing-quail/) — the primary post, Full Stack Data Lab (CMU), 24 Sep 2026
- [Hitting a billion tokens per minute on one GPU by combining a query planner and an inference engine](https://modal.com/blog/quail-billion-tpm) — Modal's companion post by Charles Frye and Shreya Shankar, same day, the inference-engineer's view and the source of the 1.14B tokens/minute figure
- [fsdatalab/quail](https://github.com/fsdatalab/quail) — the engine, MIT, Python, 95 stars, created 1 Aug 2026 · resource note at [[Quail]]
- [fsdatalab/quail-bench](https://github.com/fsdatalab/quail-bench) — QUAIL-B, now 31 queries over IMDB, BioDEX, FEVER, LePaRD and SWE-Next agent traces, distributed as Substrait plans with an adapter contract
- [Quail documentation](https://fsdatalab.github.io/quail) · [Quickstart](https://fsdatalab.github.io/quail/docs/user-guide/quickstart) · [physical plans](https://fsdatalab.github.io/quail/docs/architecture/physical-plans) · [Civil Comments demo](https://fsdatalab.github.io/quail/docs/demos/civil-comments)
- [Live playground on Modal](https://fsdatalab--quail-playground-page.modal.run/) — three tabs (Agent trace compaction on DiffusionGemma, IMDB and BIO on Qwen3 4B FP8), running live against an H100
- [Gigatoken](https://github.com/marcelroed/gigatoken) (Marcel Rød) — the tokenizer both Quail and the baselines use · [Hydragen](https://arxiv.org/abs/2402.05099) · [SpecInfer](https://arxiv.org/abs/2305.09781) · [FlashAttention 3](https://arxiv.org/abs/2407.08608) · [online softmax](https://arxiv.org/abs/1805.02867)
- [Modal on host overhead](https://modal.com/blog/host-overhead-inference-efficiency) and [GPU utilization](https://modal.com/blog/gpu-utilization-guide) — the two background posts the diagnosis leans on
- [BioDEX](https://aclanthology.org/2023.findings-emnlp.896/) · [Stanford IMDB](https://huggingface.co/datasets/stanfordnlp/imdb) · [DocETL](https://docetl.org/) · [LOTUS](https://lotus-data.github.io/) · [Palimpzest](https://palimpzest.org/) · [ThalamusDB](https://github.com/itrummer/thalamusdb)

## Related

Sits in [[moc - Data Agent]] as the runtime counterpart to [[Snowflake, Databricks and ClickHouse preview AI architecture by turning inference into a database operator, the semantic layer into agent infrastructure, and agents into a new database workload|inference as a database operator]] and the engineering discharge of [[Berkeley's EPIC Data Lab argues near-free intelligence makes agents the dominant data-systems workload, needing data systems for, of, and by agents|the EPIC Data Lab agenda]]. Shankar is also the author behind [[DAB benchmark exposes frontier data agents at 38 percent pass at 1 with 85 percent of failures in planning or implementation|DAB]] (read for builders in [[Hamel's evals-for-data-agents note reads DAB for builders - agents fail on plans not data selection and stick to plans even when data contradicts them|Hamel's note]]) and [[BARGAIN routes classification to a small model via a confidence threshold calibrated on 500 oracle labels, cutting costs up to 86 percent more than competing cascades|BARGAIN]]. On the inference side it belongs with [[moc - Inference]]: the host-overhead diagnosis matches [[Perplexity serves embeddings by treating them as a CPU-overhead problem - whole-model CUDA graphs and LazyTensors cut p50 from 4.60ms to 1.53ms while throughput stays at parity with vLLM|Perplexity's]], the KV mechanics extend [[paged attention applies OS virtual memory paging to KV cache and unlocks 2-4x LLM serving throughput|PagedAttention]] and [[Amit Shekhar explains how vLLM packs more LLM users onto one GPU through PagedAttention and continuous batching|continuous batching]], the tiering roadmap is [[LMCache offloads paged KV to system RAM and NVMe, cutting 128K-context time-to-first-token from 68 seconds to 1.4 on 4x DGX Spark|LMCache's]] territory and the compaction alternative is [[Baseten's STILL perceiver amortizes KV cache compaction into one forward pass, compressing 8x at 85%+ factual retention|STILL's]], the "one engine, one workload" pattern repeats [[Superlinked's SIE inference engine serves many small models on shared GPUs, fixing the one-model-per-GPU waste of vLLM and TEI|Superlinked's SIE]], the baseline tuning is the recipe in [[vLLM throughput benchmarking on H100 — tensor-parallel sizing, speculative decoding, and FP8 KV-cache economics]], the optimization space is catalogued in [[Ashutosh Maheshwari's sub-second LLM study list catalogs sixteen inference optimizations from KV-caching and speculative decoding to tensor parallelism and memory offloading]], and co-author Joseph Barrow appears in [[Joe Barrow reviews Philip Kiely's Inference Engineering as the reference work he wishes he had in 2023, with a curated what-to-read-next list]]. Economically it is the self-hosted pole of the Jev cluster — [[TypeSafe's Jev trades string generation for parallel-sampled typed decisions with calibrated probabilities at $0.042 per MTok - the 193x and 444x claims come from four self-built workflow evals]], [[MotherDuck's prompt_jev labels 100k AG News rows in 40 seconds for 50 cents at 89 percent - a benchmark fine-tuned encoders beat by 5 points, metered at a 25 percent markup over TypeSafe list]], [[pg-jev]], [[Applied Compute freezes a Sol-built 14-label taxonomy so Jev annotates the corpus - ECE 0.051 against Luna's 0.154 and 85 percent recall at 0.20, with every rival left at Jev's threshold]] — and the losing case, agent traces, is the workload in [[agent trace data should live in your data lake not a 30-day SaaS retention window]]. Compare the two other ways of putting a model inside a pipeline, [[RLMs inline intelligence into data pipelines by giving LLMs symbolic access to DataFrames in a persistent REPL]] and [[semantic SQL parsing makes data transformations programmatically validatable which is what data agents need underneath them]], and the question of what should compile to SQL at all in [[MotherDuck's Simon Spati splits semantic layer from context layer by what compiles to SQL, and argues sophistication is a cost not a default]]. Modal's decision to skip its own favourite optimization is the counterpoint to [[Modal argues speculative decoding is the only inference optimization that matters, and custom DFlash speculators turn acceptance length into 2-3x speedups]], the roofline vocabulary is [[Modal's GPU Glossary is a browsable reference that maps the GPU stack from device hardware through the CUDA software layers to performance concepts in ~80 linked terms]], the kernel fusions are exercises in [[Ahmad Osman's kernel curriculum - you don't run a model you run kernels, and here are eight mini-projects from RMSNorm in Triton to a custom op profiled inside vLLM]], and the tree-attention trick is the prefill cousin of the retrieval-side reuse in [[Agent-ModernColBERT trains late interaction on reasoning traces to reach GPT-5 retrieval accuracy with 149M parameters]].

## Original Content

### Thread

> [!quote]- Shreya Shankar (@sh_reya), thread of 8 tweets, 24 Sep 2026 19:37 UTC - 221 likes, 31 retweets, 28 replies. Verbatim, with the attached video frames and all five photos at position.
> @sh_reya (Shreya Shankar):
> Excited to share Quail, our new open source AI-SQL engine (a collab with Modal)! By planning queries and LLM inference together, it reaches 1B+ input tokens/min on one H100 for one query 😱🚀
>
> AI-powered data operators create a new, interesting inference workload👇 https://t.co/HoJQUyGRi4
> VIDEO: https://pbs.twimg.com/amplify_video_thumb/2103202562895904768/img/FbNZ_BqrVJdijHHa.jpg
>
> *Video attached to the root tweet: a 27.6-second, 3404x2052 screen recording of the Quail playground running the two-filter IMDB query live on one H100. No audio stream, so there is nothing to transcribe. Source: https://video.twimg.com/amplify_video/2103202562895904768/vid/avc1/3404x2052/WaiNlfGlmb5KfVou.mp4?tag=29*
>
> *Frame at 0:02. The playground at `fsdatalab--quail-playground-page.modal.run/#imdb-ending`, `qwen3-4b-fp8: ready on one H100`, POSTing to `/v1/queries` as `q4s1_e845a6d571ed4799bd542b6149c4ef12`, RUNNING at 62.3 s elapsed. The query pane shows the two AI.IF filters with `{'selectivity': 0.25}`; the Plan pane shows the logical plan (SemanticFilter, two PROMPTs at selectivity 25% and 50%) and the physical plan (`backend=quail, model=qwen3-4b-fp8, workers=1`, `KV=bf16`, `chunk budget=110,376 tokens`, `admission budget=362,240 tokens`, AiFilter est. rows 1,250 / est. time 12.5 s, `KV rewind=on`). Live counters: 12.9 s query time on the GPU, $0.0142 GPU cost, 246 passed both, `filter (2 stages) 3,940 / 10,000 documents`, `1.28k passed "discusses the ending", 4.97k / 10.0k finished`.*
>
> ![[sh_reya-688056-vid-01.png]]
>
> *Frame at 0:14. 24.9 s on the GPU, $0.0273, 1,273 passed both, `2.46k passed "discusses the ending", 9.30k / 10.0k finished`. The plan pane now shows the per-predicate rows: predicate 1 over 10,000 rows at 25%, predicate 2 over 2,500 rows at 50%, `Scan reviews as r` 10,000 rows, `tokens=3,011,180, mean_doc_tokens=301.1`, with the caveats "est. time is each node's work alone; node times do not add up to the plan estimate because chunk packing shares forward passes across nodes" and "token counts for 'r' are estimated from a 1024 document sample".*
>
> ![[sh_reya-688056-vid-02.png]]
>
> *Frame at 0:26, the finished run with the cost tooltip open. 28.0 s query time on the GPU, 156,449 tokens/second; 4.38M requested input tokens (1.11M from KV + 3.27M fresh); 1.11M tokens read from KV, 25% of the requested input; 3.27M fresh input tokens computed; 44.4k avoidable recomputed tokens (KV regret); $0.0307 GPU cost on one H100 at $3.9492/h; 1,555 passed both; `2.74k passed "discusses the ending", 10.0k / 10.0k finished`. The gpt-5-nano tooltip reads: "gpt-5-nano: $0.174 with prompt caching. 3.27M input tokens x $0.05/1M + 1.11M cached input tokens x $0.005/1M + 12,744 output tokens x $0.4/1M. All prices are per token. Output is one token per model call (12,744 calls), since each call answers with a single yes/no or score token. $0.224 with no cache hits: all 4.38M requested input tokens at $0.05/1M. This run cost $0.0307 on the H100. The estimate assumes OpenAI's prompt cache hits the same prefixes Quail read from KV, and counts no reasoning tokens."*
>
> ![[sh_reya-688056-vid-03.png]]
> date: Thu Sep 24 19:37:15 +0000 2026
> url: https://x.com/sh_reya/status/2103207153821688056
>
> ---
>
> @sh_reya (Shreya Shankar):
> AI-SQL lets users write queries like: "Find movie reviews that discuss the ending and recommend the movie", as, e.g., SELECT * FROM reviews where AI.IF("the review discusses the ending") AND AI.IF("the review recommends the movie").
>
> Queries are insanely expensive! An AI filter calls an LLM for *every row*; an AI join can call it for every candidate pair (m * n rows). One query can generate millions of LLM calls, needing ultra-high throughput!
> PHOTO: https://pbs.twimg.com/media/HTAPWszbkAAbrQF.jpg
>
> *Screenshot of the Full Stack Data Lab blog post header: "Building an Ultra-High Throughput AI-SQL Engine", Sep 24 2026, by Shreya Shankar, Charles Frye, Fergus Finn, Arnav Dhariya, Joseph Barrow, Meryem Arik. The TL;DR box and the full six-section Contents list are visible, ending at the heading "1. AI-SQL makes unstructured data useful, but it is expensive."*
>
> ![[sh_reya-688056-01.jpg]]
> date: Thu Sep 24 19:37:16 +0000 2026
> url: https://x.com/sh_reya/status/2103207155730149838
>
> ---
>
> @sh_reya (Shreya Shankar):
> We tried running all these LLM calls through hand-tuned vLLM baselines. On several queries, we observed lots of host overhead --- and, vLLM also discarded KV it needed later, causing it to process 50 million extra tokens. The query took 6.84 hours, when speed-of-light estimates suggested only 15 minutes...
> PHOTO: https://pbs.twimg.com/media/HTAPkorbUAAhjpQ.jpg
>
> *Figure 2 from the post: a 3.5-second PyTorch profiler window from the first BIO-4 join under vLLM. Thread 30 of VLLM::EngineCore alternates `vllm.schedu...` blocks with three `execute_context_846(25305)_generation_0(0)`, `execute_context_1001(25305)` and `execute_context_726(25305)` blocks; GPU stream 25 is busy only during those three, leaving the H100 idle in the gaps. Trace duration 3s 500ms, 65,276 spans.*
>
> ![[sh_reya-688056-02.jpg]]
> date: Thu Sep 24 19:37:16 +0000 2026
> url: https://x.com/sh_reya/status/2103207158502613105
>
> ---
>
> @sh_reya (Shreya Shankar):
> AI-SQL is such a special case workload, where you know nearly all requests up front (and can plan KV a lot better), and you care more about throughput, or executing the *entire* query as quickly as possible. And, requests are entirely prefill. Not like the interactive request setting that general-purpose inference engines are optimized for.
>
> Turns out it makes sense to build a specialized inference engine here, motivating Quail.
> date: Thu Sep 24 19:37:17 +0000 2026
> url: https://x.com/sh_reya/status/2103207160905875529
>
> ---
>
> @sh_reya (Shreya Shankar):
> Quail combines good query planning with good inference: e.g., it orders AI operators, pipelines rows so their KV stays in GPU HBM, and batches work to keep the GPU busy. For AI joins, we even use some fun tree attention tricks (c.f. SpecInfer, Hydragen) to reuse forward pass work when comparing one document with many others!
> PHOTO: https://pbs.twimg.com/media/HTAT9MCboAEfy6D.jpg
>
> *Figure 3, the Quail architecture: Query frontend (Arrow table or dataset, AI-SQL or Python API, Model and GPU, into a Logical plan), Query planner (Estimate dataset statistics, Set forward pass token budget, then SQL query rewrites — Projection and filter pushdown, Filter ordering, Join ordering and anchor selection — then Inference rewrites — Lower AI operators, Plan execution and KV reuse — into a Physical plan), Execution engine (CPU and GPU).*
>
> ![[sh_reya-688056-03.jpg]]
> date: Thu Sep 24 19:37:18 +0000 2026
> url: https://x.com/sh_reya/status/2103207163221201370
>
> ---
>
> @sh_reya (Shreya Shankar):
> On 29 benchmark queries, Quail is 1.84x faster than hand-tuned vLLM baselines. On our largest medical reports query, it’s 14x faster (only 29 mins compared to 6.84 hours)! We also have considerably less KV regret. https://t.co/mUJwBKnayX
> PHOTO: https://pbs.twimg.com/media/HTAUDAdaAAAnyt8.jpg
>
> *Figure 8, average requested input tokens per second on QUAIL-B as a percentage of each dataset's speed-of-light estimate, log scale, Qwen3 4B FP8 on one H100 at scale factor 0.1. BIO: Quail 12.3M tok/sec = 49.9%, stock vLLM 5.8%. IMDB: 650k tok/sec = 36.8% vs 21.7%. FEV: 1.69M tok/sec = 41.1% vs 17.6%. LEP: 389k tok/sec = 40.9% vs 33.3%. AGENT: 73k tok/sec = 20.0% vs 46.3% — the only dataset where vLLM's bar is taller.*
>
> ![[sh_reya-688056-04.jpg]]
> date: Thu Sep 24 19:37:18 +0000 2026
> url: https://x.com/sh_reya/status/2103207166782083131
>
> ---
>
> @sh_reya (Shreya Shankar):
> We still have lots more to develop; for example, a use case where vLLM wins is on analyzing agent traces (that have matching prefixes across different rows). Its automatic prefix cache catches those matches; Quail doesn’t yet. vLLM is 2.32x faster on one such query. So automatic prefix caching is definitely on our roadmap.
> PHOTO: https://pbs.twimg.com/media/HTAUlB0bMAAOhPK.jpg
>
> *Screenshot of the AGENT-1 section: the simplified query (`SELECT t.id FROM agent_traces AS t WHERE AI.IF(PROMPT('Did the agent recover after trying an approach that did not work?\n\n{0}', t.trace))`) above Table 4 — requested input tokens/s 73,006 (Quail) vs 169,201 (stock vLLM) vs 367,400 (SoL); GPU cost per query $0.2623 vs $0.1131 vs $0.0521; KV regret 11,886,152 vs 23,928 vs 0 (assumed).*
>
> ![[sh_reya-688056-05.jpg]]
> date: Thu Sep 24 19:37:19 +0000 2026
> url: https://x.com/sh_reya/status/2103207169491677597
>
> ---
>
> @sh_reya (Shreya Shankar):
> Today, Quail supports AI filters and joins -- and we are adding much more. The code is MIT licensed. We'd love to hear what you try with it! This is a really fun collaboration with inference 🐐 @charles_irl from Modal; look out for their post :-)
>
> Our lab's blog post: https://t.co/qjfpQoWqsZ
> Code: https://t.co/tqVVx3CYbo
> Playground demo: https://t.co/rK5LdrBll3
> date: Thu Sep 24 19:37:20 +0000 2026
> url: https://x.com/sh_reya/status/2103207172478062861

### Replies

> [!quote]- All 29 replies in posting order, verbatim, including Shankar's own reply to @hamiltonulmer
> @johnroodepic (John Rood):
> @sh_reya the number i'd put next to the 1.84x is the cost of the re-run: one mid-query failure that re-issues completed operators eats the whole speedup. key operator outputs by the row that produced them so the plan doubles as the retry graph and a retry only re-runs what changed.
> date: Thu Sep 24 19:49:53 +0000 2026
> url: https://x.com/johnroodepic/status/2103210332881887435
>
> ---
>
> @YiCasillas (Yi Casillas):
> @sh_reya 1B+ input tokens/min on one H100 很夸张，但我更想看 planner 把哪些 row 判成“值得调用模型”。如果每个候选都进 LLM，吞吐再高也会被无效 token 和结果校验吃掉；这个分母怎么定义，感觉比峰值更能说明 Quail 的真实甜点区。
> date: Thu Sep 24 20:16:42 +0000 2026
> url: https://x.com/YiCasillas/status/2103217081844158607
>
> ---
>
> @gane5h (Ganesh Swami):
> @sh_reya This is super cool!
> date: Thu Sep 24 20:30:11 +0000 2026
> url: https://x.com/gane5h/status/2103220473257496906
>
> ---
>
> @hamiltonulmer (Hamilton Ulmer):
> @sh_reya this is amazing
> date: Thu Sep 24 20:42:47 +0000 2026
> url: https://x.com/hamiltonulmer/status/2103223643195244990
>
> ---
>
> @MeryemArik9 (Meryem Arik):
> @sh_reya Congrats @sh_reya !
> date: Thu Sep 24 20:56:35 +0000 2026
> url: https://x.com/MeryemArik9/status/2103227118641426892
>
> ---
>
> @sh_reya (Shreya Shankar):
> @hamiltonulmer Yes we should collab!! Really exciting to see what you are doing re LLMs in motherduck — I’ll send you an email soon :-)
> date: Thu Sep 24 20:58:51 +0000 2026
> url: https://x.com/sh_reya/status/2103227686110081025
>
> ---
>
> @egealtan (Ege Altan):
> @sh_reya that's A LOT of tokens/min!
> date: Thu Sep 24 21:15:00 +0000 2026
> url: https://x.com/egealtan/status/2103231754039357830
>
> ---
>
> @ankrgyl (Ankur Goyal):
> @sh_reya super cool
> date: Thu Sep 24 22:30:38 +0000 2026
> url: https://x.com/ankrgyl/status/2103250786872647761
>
> ---
>
> @vimota (Victor Mota):
> @sh_reya Very cool!!
>
> For a second I thought this was the problem/work Stonebraker was talking about here https://t.co/MP6vBhnjud
> date: Thu Sep 24 22:40:02 +0000 2026
> url: https://x.com/vimota/status/2103253152892096955
>
> ---
>
> @CShorten30 (Connor Shorten):
> @sh_reya 🔥🔥
> date: Fri Sep 25 00:27:09 +0000 2026
> url: https://x.com/CShorten30/status/2103280107292869034
>
> ---
>
> @biff_buster (Biff Buster):
> @sh_reya Hell yeah
> date: Fri Sep 25 01:41:57 +0000 2026
> url: https://x.com/biff_buster/status/2103298931350261892
>
> ---
>
> @AlekVectis (Alek):
> @sh_reya 1B tokens/min on one H100 is a serious receipt
> date: Fri Sep 25 02:02:26 +0000 2026
> url: https://x.com/AlekVectis/status/2103304085692952659
>
> ---
>
> @_adiganesh (Adi Ganesh):
> @sh_reya this is really cool, congrats on the release!
> date: Fri Sep 25 05:13:51 +0000 2026
> url: https://x.com/_adiganesh/status/2103352258796871751
>
> ---
>
> @vinaygo (Vinay Goel):
> @sh_reya Congrats @sh_reya. Can’t wait to dig in!
> date: Fri Sep 25 06:16:34 +0000 2026
> url: https://x.com/vinaygo/status/2103368042030026964
>
> ---
>
> @JoshARosen (Josh Rosen):
> @sh_reya Quail is a great example of how it’s more than finding a new syntax. It’s about syntax plus matching runtime:
>
> https://t.co/ahvfXiHdf7
> >  QT @JoshARosen:
> > Article: AI Is Outgrowing Our Programming Languages
> >  https://x.com/JoshARosen/status/2103499788352184446
> date: Fri Sep 25 15:57:21 +0000 2026
> url: https://x.com/JoshARosen/status/2103514201914220598
>
> ---
>
> @anilpervaiz (Anil Pervaiz):
> @sh_reya Publishing the AGENT-1 loss is the most useful part for agent folks. Our traces are exactly that shape. Is cross-row prefix sharing on the roadmap?
> date: Fri Sep 25 16:00:20 +0000 2026
> url: https://x.com/anilpervaiz/status/2103514953005359111
>
> ---
>
> @Maouswawan (RR2):
> @sh_reya There are no mentions of Github repo or website.
> date: Fri Sep 25 16:32:44 +0000 2026
> url: https://x.com/Maouswawan/status/2103523105507332537
>
> ---
>
> @andupoto (Andu):
> @sh_reya @grok does this work with Supabase?
> date: Fri Sep 25 21:15:38 +0000 2026
> url: https://x.com/andupoto/status/2103594298327646441
>
> ---
>
> @tejassaboo (Tejas Saboo):
> @sh_reya Impressive!
> date: Fri Sep 25 22:09:17 +0000 2026
> url: https://x.com/tejassaboo/status/2103607799301476604
>
> ---
>
> @IndigoYogiArt (AiIndigo):
> @sh_reya Any support for Mac Studio?
> date: Sat Sep 26 00:38:08 +0000 2026
> url: https://x.com/IndigoYogiArt/status/2103645258328441225
>
> ---
>
> @ani_mysore (Ani Mysore):
> @sh_reya Great talk yesterday at SF Systems! Will be interesting to see how to schedule projections given this is designed right now for prefill only workloads
> date: Sat Sep 26 01:08:50 +0000 2026
> url: https://x.com/ani_mysore/status/2103652987319271473
>
> ---
>
> @AJChadha (AJ Chadha):
> @sh_reya Very cool! This sounds like a game changer.
> date: Sat Sep 26 02:07:57 +0000 2026
> url: https://x.com/AJChadha/status/2103667862439420043
>
> ---
>
> @patelxneal (Neal Patel):
> @sh_reya Really smart observation by all of you on a class of workload that is definitely going to be a big thing.
> date: Sat Sep 26 02:37:21 +0000 2026
> url: https://x.com/patelxneal/status/2103675262286323852
>
> ---
>
> @wythe_cap (Wythe Capital):
> @sh_reya How does this help me fire people in the Midwest?
> date: Sat Sep 26 02:50:31 +0000 2026
> url: https://x.com/wythe_cap/status/2103678575496863890
>
> ---
>
> @kennfth_ (🔑):
> @sh_reya @_6ess select * from case when like go brrrrrr
> date: Sat Sep 26 07:15:46 +0000 2026
> url: https://x.com/kennfth_/status/2103745328444809726
>
> ---
>
> @aleinboii (vincwx):
> @sh_reya Great read !
>
> so couple of months back I built a knowledge base and the combination of GIN index and to_tsvector helped a lot in fetching queries and this seems like a good place to them in a sync engine as well
>
> it was something like USING GIN (to_tsvector())
> date: Sat Sep 26 14:52:07 +0000 2026
> url: https://x.com/aleinboii/status/2103860169990107538
>
> ---
>
> @zero_01n (o1.):
> @sh_reya Very cool!!
> date: Sat Sep 26 19:16:37 +0000 2026
> url: https://x.com/zero_01n/status/2103926733540061607
>
> ---
>
> @jarrelscy (Jarrel Seah):
> @sh_reya Do you need an LLM to do this or could we combine this with something like Jev?
> date: Sun Sep 27 12:53:42 +0000 2026
> url: https://x.com/jarrelscy/status/2104192758353375395
>
> ---
>
> @prempv (Prem Viswanathan):
> @sh_reya Amazing!!
> date: Sun Sep 27 16:00:08 +0000 2026
> url: https://x.com/prempv/status/2104239674948497604

### Blog

> [!quote]- Full blog post, verbatim - Shreya Shankar, Charles Frye, Fergus Finn, Arnav Dhariya, Joseph Barrow and Meryem Arik, "Building an Ultra-High Throughput AI-SQL Engine", Full Stack Data Lab (CMU), 24 September 2026. All 24 code blocks, all four tables, all ten figures, the eleven numbered notes and the citation block.
> Title: Building an Ultra-High Throughput AI-SQL Engine
>
> URL Source: https://fsdatalab.github.io/blog/introducing-quail/
>
> Markdown Content:
> ---
> title: Building an Ultra-High Throughput AI-SQL Engine
> description: Quail jointly plans AI-SQL queries and model inference. Across 29 QUAIL-B queries, it is 1.84x faster on average than well-tuned vLLM baselines.
> image: https://fsdatalab.github.io/assets/blog/introducing-quail/quail-throughput-by-dataset.png
> ---
>
>  
>
> [Back to blog](/blog/) 
>
> # Building an Ultra-High Throughput AI-SQL Engine
>
> Sep 24, 2026
>
> Shreya Shankar, Charles Frye, Fergus Finn, Arnav Dhariya, Joseph Barrow, Meryem Arik
>
> **TL;DR:** AI functions in SQL, and fast LLM-powered classifiers in general, are having their day in the sun. But they typically rely on costly, closed LLM APIs. We’re building [Quail](https://github.com/fsdatalab/quail), the **QU**ery-**A**ware **I**nference **L**ayer, to jointly optimize query planning and model inference for open-weight models. Across 29 [QUAIL-B](https://github.com/fsdatalab/quail-bench) queries, Quail is 1.84x faster on average than well-tuned vLLM baselines — up to 14x! [Star us on GitHub](https://github.com/fsdatalab/quail), and try it out in our [live demo](https://fsdatalab--quail-playground-page.modal.run/)!
>
> # 1\. AI-SQL makes unstructured data useful, but it is expensive.
>
> Fast LLM classifiers have been taking over the internet lately. [Jev](https://typesafe.ai/blog/introducing-system-one-models-and-jev) is the clearest example: give a model a small, bounded decision and get an answer almost immediately. What better place to run millions of those decisions than… inside the database!
>
> Indeed, database vendors have recently begun to offer this kind of intelligence at scale through AI-SQL, also called AI functions. AI-SQL extends SQL with user-defined functions that invoke LLMs. Users specify each function with a natural-language prompt. A query can look like this:
>
> ```
> SELECT *
> FROM reviews AS r
> WHERE AI.IF(PROMPT('Does this review discuss the ending?\n\n{0}', r.review));
>
> ```
>
> Many database vendors support AI-SQL. For example, [Snowflake Cortex AISQL](https://docs.snowflake.com/en/user-guide/snowflake-cortex/aisql), [BigQuery AI functions](https://cloud.google.com/bigquery/docs/generative-ai-overview), [Databricks AI Functions](https://docs.databricks.com/aws/en/large-language-models/ai-functions), and, recently, [MotherDuck](https://motherduck.com/blog/motherduck-supports-jev/)all support it.
>
> Unfortunately, executing AI-SQL is extremely expensive. An AI function evaluates its prompt row by row, so one SQL query can create hundreds of thousands or millions of model calls. A filter needs one LLM call per row. A naive join needs one LLM call for every pair of rows in its two input tables.
>
> This line of work has become extremely popular in the database research community. A number of open-source academic systems have emerged, including our work on [DocETL](https://docetl.org/) from UC Berkeley, [LOTUS](https://lotus-data.github.io/) from Stanford, [Palimpzest](https://palimpzest.org/) from MIT, and [ThalamusDB](https://github.com/itrummer/thalamusdb) from Cornell. These systems (and database vendors) primarily reduce cost by eliminating as many LLM calls as possible (e.g., [MOAR](https://arxiv.org/abs/2512.02289), [Task Cascades](https://arxiv.org/abs/2601.05536), and [Abacus](https://arxiv.org/abs/2505.14661)) and by using cheaper models when possible (e.g., [BARGAIN](https://arxiv.org/abs/2509.02896)). Even after these optimizations, a query plan may still require hundreds of thousands or millions of LLM calls.
>
> # 2\. Key Idea: Query plans should control LLM inference!
>
> A natural thought is to use a general-purpose inference engine such as vLLM to execute the query plan. However, sending millions of related model calls to vLLM as separate requests has a large cost! We’ll illustrate with the following query:
>
> Given a dataset of medical reports and a dataset of possible adverse reactions, find serious adverse event reports that mention both a cardiovascular reaction and a neurological reaction.[1](#note-1)
>
> We call this query BIO-4 in [QUAIL-B](https://github.com/fsdatalab/quail-bench), a benchmark we are building to evaluate AI-SQL query engines. Its inputs contain 5,000 long reports and 4,144 reaction terms (the latter is used twice, as there are two joins). The logical plan, shown in [Figure 1](#figure-1), works as follows:
>
> *Figure 1. A logical query plan for the BIO-4 query plan filters all three inputs before the joins. Both joins use the medical report as the anchor (i.e., first document in the prompt). Labels, bottom to top: Scan reports / Scan reaction terms as c / Scan reaction terms as n, each into a Filter stage (AI_FILTER: serious adverse event? / cardiovascular reaction? / neurological reaction?), then materialized survivors into the First join (AI_JOIN, cardiovascular reaction experienced?, anchor: report), then materialized join rows into the Second join (AI_JOIN, neurological reaction experienced?, anchor: report).*
>
> ![[sh_reya-688056-blog-01.svg]]
>
> Figure 1\. A logical query plan for the BIO-4 query plan filters all three inputs before the joins. Both joins use the medical report as the anchor (i.e., first document in the prompt).
>
> 1. It filters the reports for serious adverse events.
> 2. It filters the two reaction term dataset inputs (i.e., lists of possible adverse reaction terms) for cardiovascular and neurological reactions.
> 3. It joins the surviving reports with the cardiovascular terms, then with the neurological terms.
>
> How might we execute BIO-4 with vLLM? Following what databases do, we’d render one prompt for each filter input, and, for the join, one prompt for candidate report and reaction _pair_. Each prompt would be a separate inference request.[2](#note-2) For the filters, there’s just one document per prompt; for the join, we’d place the much longer medical report first as the anchor and the reaction term second as the partner to maximize reuse of the prefix’s key and value state (KV) across join prompts. We’d execute one operator at a time and order its LLM requests so requests for the same document are evaluated together, maximizing KV reuse.
>
> **A cost estimate for the query plan.** Before running the vLLM baseline, we first want to estimate the lowest possible runtime for the same plan. We count the model’s arithmetic work and HBM traffic from the token lengths, then use a [roofline model](https://modal.com/gpu-glossary/perf/roofline-model) to estimate the time. The estimate assumes peak GPU throughput, full overlap between CPU and GPU work, and unlimited space for retained KV. No implementation can meet all of these assumptions, so this optimistic lower bound is our _speed of light estimate_, or SoL. For BIO-4, the SoL estimate is 894.37 seconds, or 14.91 minutes.[3](#note-3) The [implementation in Quail](https://github.com/fsdatalab/quail-exploration/blob/0d24478a82100b518d6110f5c1c8cec0c26c6487/quail/planner/sol.py)contains the full calculation (which we’ll discuss in a follow-up blog post).
>
> **How we hoped vLLM would perform.** Each request produces one token constrained to TRUE or FALSE, so all model work is prefill. BIO-4 compiles to millions of requests, so there should always be a large batch ready for the H100\. With a large enough batch, vLLM should keep the H100 busy, and get as close to the SoL estimate as possible.
>
> **How vLLM actually performs.** We run vLLM 0.26.0 with Qwen3 4B FP8 on one H100\. We give it enough batch capacity to use the GPU. At scale factor 1.0, a vLLM baseline takes _6.84 hours_, or 27.55x the SoL estimate! There are two reasons for the inefficiency. [Figure 2](#figure-2) shows a representative 3.5-second window from the first join.
>
> *Figure 2. A 3.5-second window from the first BIO-4 join from a PyTorch profiler trace. The CPU main thread alternates between vLLM scheduler work and execute_context. GPU stream 25 runs during the three execute_context blocks; as you can see, the gaps between them leave the H100 idle. Visible in the trace: VLLM::EngineCore 30 / thread 30 (main thread), execute_context_846(25305)_generation_0(0), execute_context_1001(25305)_generation_0(0), execute_context_726(25305)_generation_0(0), VLLM::EngineCore 0 with stream 13 and stream 25, Spans 65276, Duration 3s 500ms.*
>
> ![[sh_reya-688056-blog-02.jpg]]
>
> Figure 2\. A 3.5-second window from the first BIO-4 join from a PyTorch profiler trace. The CPU main thread alternates between vLLM scheduler work and execute\_context. GPU stream 25 runs during the three execute\_context blocks; as you can see, the gaps between them leave the H100 idle.
>
> * The primary reason is host overhead. The CPU spends long stretches scheduling and tracking requests while the H100 waits, as shown by the gaps in [Figure 2](#figure-2).[4](#note-4)
> * The second is _KV regret:_ vLLM sometimes discards KV that it needs again later. On BIO-4 at scale factor 1.0, it therefore processes 174.6 million tokens instead of 124.3 million: 50.3 million extra tokens, or 40% more work.
>
> We can, and we should, reduce both sources of waste by optimizing inference for AI-SQL!
>
> # 3\. We built Quail to run AI-SQL queries faster.
>
> We will first show you how you can get started. To skip to read about how Quail works, skip to [Section 3.2](#32-quail-jointly-plans-queries-and-inference).
>
> 3.1 You can run your first Quail query in a few lines of code!This part is collapsible, for space reasons. 
>
> We can use Quail to run two AI filters over all 100,000 movie reviews in the [Stanford IMDB dataset](https://huggingface.co/datasets/stanfordnlp/imdb). We first download the reviews from Hugging Face, and load them into an Arrow dataset.
>
> ```
> import pyarrow as pa
> import pyarrow.dataset as ds
> from datasets import concatenate_datasets, load_dataset
> import quail
>
> imdb = load_dataset(
>     "stanfordnlp/imdb",
>     revision="e6281661ce1c48d982bc483cf8a173c1bbeb5d31",
> )
> all_reviews = concatenate_datasets([
>     imdb["train"],
>     imdb["test"],
>     imdb["unsupervised"],
> ])
> reviews = ds.dataset(pa.table({
>     "review_id": pa.array(f"review-{i}" for i in range(len(all_reviews))),
>     "review": all_reviews.data.table.column("text"),
> }))
>
> ```
>
> The query keeps reviews that discuss the movie’s ending, and recommend watching the movie.
>
> ```
> # This Python process has access to one H100.
> config = quail.EngineConfig(
>     gpus=1,
>     model="qwen3-4b-fp8",
>     backend="quail",
>     device="h100-sxm",
> )
> with quail.Session(config) as session:
>     session.register(
>         "reviews",
>         quail.DocumentProvider.from_dataset(reviews, id_col="review_id"),
>     )
>
>     query = session.sql("""
>         SELECT r.review_id
>         FROM reviews AS r
>         WHERE AI.IF(
>             PROMPT(
>                 'Does this review discuss the ending of the movie?\n\n{0}',
>                 r.review
>             ),
>             -- Optional, but helps Quail reorder filters.
>             {'selectivity': 0.25}
>         )
>         AND AI.IF(
>             PROMPT(
>                 'Does the reviewer recommend watching the movie?\n\n{0}',
>                 r.review
>             ),
>             {'selectivity': 0.5}
>         )
>     """, dialect="bq")
>
>     print(query.explain())
>     result = query.run()
>     table = result.collect()
>
> ```
>
> Before running the query, query.explain() prints the logical and physical plans. The output below keeps only the parts that describe the two filters and their execution settings.
>
> ```
> logical:
> Project: r.review_id
> SemanticFilter
> predicate 1: discusses the ending (selectivity=25%)
> predicate 2: recommends the movie (selectivity=50%)
> Scan reviews as r [review, review_id]
>
> physical: backend=quail, model=qwen3-4b-fp8, workers=1
> KV=bf16
> chunk budget=110,376 tokens
> admission budget=362,250 tokens
> Project: r.review_id (est. rows=12,500)
> AiFilter: r (est. rows=12,500; est. time=124 s)
> KV rewind=on
> predicate 1 (input rows=100,000; est. pass=25%)
> predicate 2 (input rows=25,000; est. pass=50%)
> Scan reviews as r (rows=100,000)
> tokens=29,926,924, mean_doc_tokens=299.3
>
> ```
>
> The complete example in [demos/imdb\_ending\_filter.py](https://github.com/fsdatalab/quail/blob/d8d31f14f9d5c40d6cf683a74ba860788ce0d500/demos/imdb%5Fending%5Ffilter.py)prints the following results at the end of the run:
>
> ```
> matching reviews: 16057 of 100000
> stage evaluated 100000 reviews, 0.283 passed
> stage evaluated 28296 reviews, 0.568 passed
> boot_s: 57.65 (cold)
> token_wait_s: 0.0
> wall_s: 277.41
> total_s: 335.06 (boot + query)
> fresh_tokens: 32499738
> documents/second: 360.5
> GPU price: $3.9492/GPU-hour (Modal)
> GPU cost, including startup: $0.3675
>
> ```
>
> The full run costs $0.3675 at [Modal’s H100 price](https://modal.com/pricing), including model startup.[5](#note-5)At current GPT-5 nano prices (including cached token prices), the same two-filter workload would cost about $1.75, or 4.8 times the measured Quail cost![6](#note-6)
>
> **Running on Modal**. If you don’t have a dedicated GPU, you can put the whole query inside a Modal GPU function. The function creates a normal Quail session and runs it:
>
> ```
> import modal
>
> app = modal.App("quail-engine")
> image = (
>     modal.Image.from_registry(
>         "nvidia/cuda:13.0.1-devel-ubuntu24.04",
>         add_python="3.12",
>     )
>     .entrypoint([])
>     .uv_pip_install("quail-engine==0.1.0")
> )
>
> @app.function(image=image, gpu="H100!", memory=32768, timeout=1200)
> def run_query(sql, documents):
>     import quail
>
>     config = quail.EngineConfig(
>         gpus=1,
>         model="qwen3-4b-fp8",
>         backend="quail",
>         device="h100-sxm",
>     )
>     with quail.Session(config) as session:
>         session.register(
>             "docs",
>             quail.DocumentProvider.from_table(documents, id_col="id"),
>         )
>         result = session.sql(sql).run()
>         return result.collect(), result.report
>
> ```
>
> Modal allocates the H100, and Quail plans and runs the query inside the function. A complete example is in [demos/quickstart\_modal.py](https://github.com/fsdatalab/quail/blob/d8d31f14f9d5c40d6cf683a74ba860788ce0d500/demos/quickstart%5Fmodal.py).
>
> Check out the [Quail documentation](https://fsdatalab.github.io/quail)to learn more.
>
> ## 3.2 Quail jointly plans queries and inference.
>
> This section describes Quail’s main design ideas at a high level. We are still actively building Quail, and we will provide the full technical details in a future report.
>
> We have three performance goals for Quail:
>
> 1. Minimize KV regret.
> 2. Keep the GPU busy by reducing CPU scheduling overhead.
> 3. Reach high model FLOP/s utilization (MFU) while the GPU is active.
>
> Our current evaluation focuses on the first two goals. We defer a full MFU study to future work.
>
> As shown in [Figure 3](#figure-3), Quail consists of a query frontend, a query planner, and an execution engine. Through the frontend, the user provides Arrow tables or datasets, an AI-SQL or Python query, and the model and GPU or GPUs to use. The frontend creates a logical plan from the query. The query planner orders the filters and joins, chooses the anchor for each join, and determines how many tokens each model forward pass should process. The planner then lowers the logical plan into a physical operator plan, which the execution engine runs.
>
> *Figure 3. Quail takes Arrow data and an AI-SQL query as input. The frontend creates a logical plan. The planner applies SQL rewrites, lowers the AI operations into physical operators, and plans their execution and KV reuse. The execution engine runs the physical plan and executes its AI operations on the GPU. Boxes: Query frontend (Arrow table or dataset, AI-SQL or Python API, Model and GPU, Logical plan) / Query planner (Estimate dataset statistics, Set forward pass token budget, SQL query rewrites: Projection and filter pushdown, Filter ordering, Join ordering and anchor selection; Inference rewrites: Lower AI operators, Plan execution and KV reuse; Physical plan) / Execution engine (CPU, GPU).*
>
> ![[sh_reya-688056-blog-03.svg]]
>
> Figure 3\. Quail takes Arrow data and an AI-SQL query as input. The frontend creates a logical plan. The planner applies SQL rewrites, lowers the AI operations into physical operators, and plans their execution and KV reuse. The execution engine runs the physical plan and executes its AI operations on the GPU.
>
> Quail is extensible, and its design is inspired by [Apache DataFusion](https://datafusion.apache.org/), an open source, extensible analytical query engine. One can add new query operators, planning rules, execution backends, models, or support for other hardware.
>
> ### 3.2.1 Quail turns AI-SQL into a logical query plan.
>
> Users register data as an in-memory Arrow table or an Arrow dataset. Users can write queries in AI-SQL (we support both Snowflake’s and BigQuery’s spellings, AI\_FILTER and AI.IF), or use a Python query builder similar to pandas. The current release of Quail supports AI filters and joins, along with relational projections and LIMIT.
>
> Users define each [AI operator](https://fsdatalab.github.io/quail/docs/user-guide/sql#ai-operators)with a prompt and can provide optional planning information. The optional selectivity gives the expected fraction of documents or document pairs that will pass; without it, Quail keeps predicates in their written order. For a join, the optional anchor chooses which input comes first in the prompt for KV reuse; without it, the planner chooses the anchor.
>
> Users can specify the model and GPU count. Quail currently supports three models: Qwen3 4B FP8, Qwen3 32B FP8, and DiffusionGemma on H100 GPUs. We plan to add support for more models and hardware through the extension interface.
>
> In Quail, each AI-SQL query is parsed with SQLGlot into a logical plan, which is then passed to the query planner.
>
> ### 3.2.2 Quail plans operator order and KV reuse.
>
> Database query optimizers already use many rules, e.g., pushing down filters, reordering predicates, and choosing join order. AI-SQL adds several new decisions, e.g., which document should be the join anchor, which KV will be needed by a later operator, and how much model work should enter each forward pass. Quail plans both kinds of decisions together.
>
> **Overview.** Given the logical query plan, we do the following:
>
> 1. _Compute dataset statistics._ We estimate the document lengths and basic statistics for each input dataset.
> 2. _Compute forward pass and KV limits._ From the selected model and GPU, we choose how many tokens to process in each model forward pass and calculate the fixed KV capacity.
> 3. _Perform SQL query rewrites_. We push down projections and filters, order the filters, and choose the join order and anchor for each join.
> 4. _Perform Inference-specific query rewrites._ We lower AI operations into physical operators and plan their execution order and KV use.
>
> We describe these steps at a high level, in turn.
>
> **Dataset statistics.** We estimate the row count, average document length, and maximum document length for each input dataset.
>
> **Forward pass and KV limits.** Given the user’s selected model size and GPU memory size, we calculate the maximum number of tokens to compute for each model forward pass. We reserve HBM for the model weights and two forward passes, and leave the rest of the HBM for the KV cache. (This is more conservative than vLLM, which profiles one forward pass to determine how much activation memory to reserve, so we can probably improve on this).
>
> **SQL query rewrites**. We push projections and filters down to the source datasets. We order filters using their estimated cost and selectivity, following extremely well-known prior work ([Hellerstein and Stonebraker](https://dsf.berkeley.edu/jmh/miscpapers/sigmod93.pdf) et al.). For joins, we use a [Selinger-style](https://doi.org/10.1145/582095.582099) search (i.e., System R) to choose the join order and anchor for each join. The cost model uses the speed-of-light estimate from Section 2\. We will explain the calculation in a future post. For now, you can check out the [cost model code](https://github.com/fsdatalab/quail/tree/main/quail/cost).
>
> **Inference-specific query rewrites**. After the SQL rewrites, we translate the logical plan into a DAG of physical operators. You can find the physical operators that Quail currently supports in our [physical plan documentation](https://fsdatalab.github.io/quail/docs/architecture/physical-plans). For example, the AiFilter physical operator evaluates AI predicates over documents, while AiJoin evaluates AI predicates over document pairs that share an anchor. Each AI physical operator also specifies its prompt, model, forward pass token budget, and KV settings (e.g., whether to write KV to HBM because there will be a subsequent operator in the query).
>
> Drawing inspiration from vectorized query execution, Quail streams intermediate results directly between operators rather than materializing complete datasets on disk or in main memory. For example, in BIO-4, as soon as a batch of reports passes the initial filter operator, Quail immediately pipelines it to the first join operator. It maintains the report KV cache in HBM throughout both join operations, allowing direct comparisons against the filtered reaction terms without redundant KV recomputations.
>
> ### 3.2.3 Quail runs the physical query plan.
>
> Overview. The execution engine has three main components:
>
> 1. **Physical plan executor.** On the CPU, Quail pulls document batches through the physical operator DAG and prepares work for the GPU.
> 2. **KV manager.** Quail allocates, pins, “rewinds” (i.e., only persists KV for the prefix we know will appear in a future operator, not the entire LLM prompt which includes the document(s) and some natural language instruction), and releases KV pages according to the physical plan.
> 3. **Inference program.** On the GPU, Quail runs a model forward pass for each input batch.
>
> [Figure 4](#figure-4) shows how these components work together.
>
> *Figure 4. Quail lowers BIO-4 to the physical plan on the left. On the right, one CPU worker runs its physical operators and manages KV. Each AI physical operator invokes Quail's inference program on the GPU. Left, the BIO-4 Physical Plan: Project over AiJoin: n over AiJoin: c over AiFilter: neurological, AiFilter: serious, AiFilter: cardiovascular, over Scan reports / Scan terms as c / Scan terms as n. Right, the Execution Engine: CPU runs Tokenize Documents and the Physical Plan Executor (AiFilter Execution, AiJoin Execution, Other: Project, Limit, Exchange, Recombine) plus the KV Manager; GPU holds the Model Copy, the Quail Inference Program (GPU operator graph) and KV Pages in HBM.*
>
> ![[sh_reya-688056-blog-04.svg]]
>
> Figure 4\. Quail lowers BIO-4 to the physical plan on the left. On the right, one CPU worker runs its physical operators and manages KV. Each AI physical operator invokes Quail’s inference program on the GPU.
>
> We’ll discuss the first two components; then we’ll describe the inference program in [Section 3.2.4](#324-quail-uses-specialized-inference-programs-for-ai-sql).
>
> **Physical plan executor.** Quail uses a pull-based executor, as in [Volcano](https://doi.org/10.1109/69.273032), but processes a batch at a time, as in [MonetDB](https://www.cidrdb.org/cidr2005/papers/P19.pdf). Before execution, Quail tokenizes every document column referenced by an AI filter or join with [Gigatoken](https://github.com/marcelroed/gigatoken)[7](#note-7), then loads one model copy per GPU. During execution, the CPU prepares one input batch while the GPU processes another.
>
> **KV manager.** Each GPU has a fixed pool of KV pages in HBM. After each model evaluation, Quail retains only the KV that a later evaluation can reuse. For a filter, Quail places the document before the predicate-specific question. After the predicate returns TRUE or FALSE, Quail discards the predicate KV and “rewinds” to the end of the document KV. Then, if the predicate returns TRUE and another AI operator uses the document, Quail will retain the “rewinded” KV in HBM; otherwise, Quail will release it. Quail similarly retains “rewinded” KV for joins. If eviction is necessary, Quail evicts the shortest documents, since longer documents take disproportionately longer to recompute, thanks to attention being a quadratic operation.
>
> Note that a general-purpose inference is different in that: (1) it retains _all_ the KV associated with a request (no “rewinding”), even though the suffix KV will never be used again in the query, (2) _all_requests’ KV are wastefully saved in HBM, even if documents are filtered out in the query and never needed again, and (3) documents are evicted with LRU.
>
> **Using multiple GPUs.** Our current multi-GPU support is quite basic. We place one complete model copy and one KV pool on each GPU. We partition filter documents and join anchors randomly and uniformly across the GPUs, run them independently, and combine the results on the CPU.
>
> ### 3.2.4 Quail uses specialized inference programs for AI-SQL.
>
> During planning, Quail chooses which documents or document pairs require model evaluation. During execution, each evaluation follows an _inference program_: e.g., embedding lookup, transformer layers, attention, matrix multiplication, etc.
>
> Here, we first describe how physical operators are expressed as inference programs, then how vLLM represents an inference program (which we adopt), and finally, the changes we make to Quail’s inference program.
>
> **Physical operator interface.** Each AiFilter or AiJoin physical operator is expressed as an inference program. The program takes token IDs and positions, plus the locations of any reusable KV pages. It returns TRUE and FALSE scores for each row or pair of rows. Quail runs the program across all rows or pairs evaluated by the operator.
>
> **vLLM’s inference programs.** vLLM is a general-purpose engine designed to support any inference pattern, across various model architectures and hardware backends. How does vLLM _do it all_? As shown in [Figure 5](#figure-5), given the model choice and GPU, there are two primary paths through which vLLM creates an inference program (i.e., of GPU kernels): (1) PyTorch operations JIT-compiled with [torch.compile](https://docs.vllm.ai/en/stable/design/torch%5Fcompile/)and TorchInductor into generated Triton GPU kernels, and (2) custom operations (such as attention) expressed through highly specialized GPU kernels like, FlashAttention.
>
> *Figure 5. vLLM builds the model's forward pass for the selected model and GPU through two paths: compiling PyTorch operations into GPU kernels and selecting prewritten kernels for specialized operations. Left path: Ordinary PyTorch operations, torch.compile and TorchInductor capture and JIT-compile the graph, Generated GPU kernels (often generated with Triton). Right path: Custom operations including attention, vLLM backend selection chooses an implementation, Specialized GPU kernels (vLLM Triton or CUDA, FlashAttention or CUTLASS). Both reach the GPU.*
>
> ![[sh_reya-688056-blog-05.svg]]
>
> Figure 5\. vLLM builds the model’s forward pass for the selected model and GPU through two paths: compiling PyTorch operations into GPU kernels and selecting prewritten kernels for specialized operations.
>
> **Quail’s inference program.** We did not reimplement every model and GPU operation from scratch. That would be silly. Instead, Quail uses vLLM’s model implementations to obtain the operations required for a forward pass, then runs them with its own scheduler and KV manager. However, Quail makes three small changes to the forward pass:
>
> **First, fuse small operations.** We write [Triton](https://triton-lang.org/) kernels that fuse normalization with FP8 quantization, Q/K normalization with RoPE, and activation with FP8 quantization. This is extremely easy to do now with AI agents; it requires no novel kernel design ideas. By fusing these operations, Quail reduces kernel launches and intermediate HBM traffic.[8](#note-8)
>
> **Second, specialize attention for joins.** An AI join compares one anchor with many partners. Standard vLLM treats each anchor and partner as a separate sequence. Attention therefore reads the same anchor KV again for every partner, as the left side of [Figure 6](#figure-6) shows.
>
> *Figure 6. In vLLM, each anchor and partner pair is a separate sequence, so attention reads the same anchor KV once per partner. Quail groups the partners that share an anchor, so attention reads the anchor KV once. Left, "vLLM: one sequence per pair" - Anchor KV + Partner 1, Anchor KV + Partner 2, Anchor KV + Partner 3, annotated "same anchor KV read 3 times". Right, "Quail: partners share the anchor" - one Anchor KV feeding Partner 1, Partner 2 and Partner 3, annotated "anchor KV read once".*
>
> ![[sh_reya-688056-blog-06.svg]]
>
> Figure 6\. In vLLM, each anchor and partner pair is a separate sequence, so attention reads the same anchor KV once per partner. Quail groups the partners that share an anchor, so attention reads the anchor KV once.
>
> Quail groups all partners that share an anchor and computes the anchor KV once (right side of [Figure 6](#figure-6)). [Figure 7](#figure-7) shows how Quail evaluates attention in two parts. One [FlashAttention 3](https://arxiv.org/abs/2407.08608) call computes causal attention within each partner. A second call applies all partner queries to the shared anchor KV, reducing repeated reads. Quail combines the two results using their log-sum-exp values and the [online softmax formula](https://arxiv.org/abs/1805.02867), producing the same output as attention over each full anchor and partner sequence. This is one level of “tree”-based attention.[9](#note-9) One Triton kernel combines the BF16 outputs and converts them to the FP8 format expected by the output projection.
>
> *Figure 7. Quail evaluates join attention with two FlashAttention 3 calls. One computes attention within each partner suffix. The other applies the suffix queries to the shared anchor KV. A Triton kernel combines both results and converts the output to FP8 before the output projection. Labels: One join attention step - Partner-specific suffix tokens and Shared anchor KV feed "FlashAttention 3 within partner suffix" and "FlashAttention 3 partner suffix -> anchor KV", which meet at "Exact merge + FP8 quantization, one Triton kernel", then DeepGEMM output projection.*
>
> ![[sh_reya-688056-blog-07.svg]]
>
> Figure 7\. Quail evaluates join attention with two FlashAttention 3 calls. One computes attention within each partner suffix. The other applies the suffix queries to the shared anchor KV. A Triton kernel combines both results and converts the output to FP8 before the output projection.
>
> **Third, restrict the output head to** TRUE **and** FALSE. Normally, a model would use its final output head (“language modeling” head, lm\_head) to compute a score for every token in its vocabulary. For AI filters and joins, Quail needs only the scores for token IDs that represent TRUE or FALSE.[10](#note-10) Quail therefore multiplies the final hidden state by only the corresponding rows of the output/language modeling head matrix. By using the smaller matrix, Quail reduces computation and GPU memory use by the output head.
>
> # 4\. We evaluate Quail against vLLM.
>
> At scale factor 0.1, Quail is faster than a “stock” vLLM baseline on 27 of the 29 QUAIL-B queries. The **(geometric) mean speedup is 1.84x**, and the **maximum speedup is 11.22x** on BIO-2\. At scale factor 1.0, we find a query for which Quail is 14.04x faster! The two queries where stock vLLM wins expose one missing feature clearly: Quail does not yet reuse matching prefixes across different rows.
>
> In this section, we first describe our [metrics and baselines](#41-metrics-and-baselines-for-ai-sql-performance), then present the [full QUAIL-B results](#42-overall-quail-is-184x-faster-across-quail-b), and finally examine [BIO-4](#43-quail-dominates-vllm-on-bio-4-1404x-faster)and [AGENT-1](#44-but-vllm-dominates-quail-on-agent-1-quail-takes-232x-as-long)in detail.
>
> ## 4.1 Metrics and baselines for AI-SQL performance.
>
> **Metrics.** We report three metrics for each query: KV regret, $/query, and input tokens/second. KV regret is repeated model work: fresh input tokens beyond the minimum needed to compute each reusable prefix once. $/query is query runtime in hours multiplied by [$3.9492 per H100-hour](https://modal.com/pricing). Input tokens/second is the total requested input tokens divided by query runtime. Each evaluated prompt contributes its full input length, including tokens served from KV. Lower KV regret and cost are better; higher throughput is better.
>
> **QUAIL-B.** We created [QUAIL-B](https://github.com/fsdatalab/quail-bench), a benchmark with 29 AI-SQL queries. It covers IMDB reviews, medical reports, fact-checking claims, legal documents, and software-agent traces. Queries include filters, filter sequences, and one or more joins. Each dataset has scale factors 0.1, 0.5, and 1.0\. We compare all 29 default queries at scale factor 0.1\. We examine BIO-4 at scale factor 1.0 and AGENT-1 in more detail.
>
> **Setup.** Every query uses Qwen3 4B FP8 with BF16 KV on one H100\. Quail and each vLLM baseline run one after the other on the same physical GPU. They use the same model, prompts, and logical query plan.
>
> **vLLM baselines.** Both baselines use the optimal operator ordering chosen by our query planner. For each operator, we prepare its requests and order them to improve KV reuse. We call the operator-at-a-time baseline “stock vLLM.” For QUAIL-B queries with multiple filters or joins, we also report a “pipelined vLLM” baseline. It pipelines requests between consecutive filters and between consecutive joins. For fairness, both baselines use Gigatoken for tokenization, as Quail does, instead of vLLM’s Hugging Face tokenizer.[11](#note-11)
>
> ## 4.2 Overall, Quail is 1.84x faster across QUAIL-B.
>
> [Table 1](#table-1) averages tokens/second, KV regret, and cost per query within each dataset at scale factor 0.1\. Cost multipliers are relative to Quail.
>
> | Dataset           | Quail                                                       | Stock vLLM                                                   |
> | ----------------- | ----------------------------------------------------------- | ------------------------------------------------------------ |
> | BIO (4 queries)   | 12,296,410 tokens/s 157,995 KV regret $0.0892/query (1.00x) | 1,420,421 tokens/s 1,441,816 KV regret $0.7771/query (8.72x) |
> | IMDB (10 queries) | 649,864 tokens/s 451,917 KV regret $0.0282/query (1.00x)    | 382,818 tokens/s 1,129,174 KV regret $0.0467/query (1.66x)   |
> | FEV (8 queries)   | 1,692,276 tokens/s 408,592 KV regret $0.0383/query (1.00x)  | 724,574 tokens/s 519,588 KV regret $0.0820/query (2.14x)     |
> | LEP (5 queries)   | 388,903 tokens/s 2,147 KV regret $0.0670/query (1.00x)      | 316,617 tokens/s 70,982 KV regret $0.0853/query (1.27x)      |
> | AGENT (2 queries) | 73,006 tokens/s 11,886,152 KV regret $0.2616/query (1.00x)  | 169,201 tokens/s 23,928 KV regret $0.1129/query (0.43x)      |
>
> Table 1\. Average QUAIL-B results by dataset at scale factor 0.1\. Cost multipliers are relative to Quail.
>
> [Figure 8](#figure-8) summarizes throughput by dataset, and [Figure 9](#figure-9) reports latency for all 29 queries. The geometric mean of Quail’s per-query speedups over stock vLLM is 1.84x. In total, Quail completes the benchmark in 1,643.74 seconds, compared with 4,451.95 seconds for stock vLLM. Quail takes 3.35x longer than the combined SoL estimate of 491.17 seconds, so there is substantial room to improve.
>
> *Figure 8. Average requested input tokens per second on QUAIL-B, shown as a percentage of the Speed-of-Light estimate (i.e., theoretical hardware limits) for each dataset. We use Qwen3 4B FP8 and one H100. Bar values, Quail then stock vLLM: BIO (4 queries) 12.3M tok/sec = 49.9% vs 5.8%; IMDB (10 queries) 650k tok/sec = 36.8% vs 21.7%; FEV (8 queries) 1.69M tok/sec = 41.1% vs 17.6%; LEP (5 queries) 389k tok/sec = 40.9% vs 33.3%; AGENT (2 queries) 73k tok/sec = 20.0% vs 46.3%.*
>
> ![[sh_reya-688056-blog-08.png]]
>
> Figure 8\. Average requested input tokens per second on QUAIL-B, shown as a percentage of the Speed-of-Light estimate (i.e., theoretical hardware limits) for each dataset. We use Qwen3 4B FP8 and one H100.
>
> *Figure 9. Query latency at scale factor 0.1. Bars show Quail and stock vLLM; horizontal lines show SoL estimates. The vertical axis uses a log scale because the query times span more than three orders of magnitude. All 29 queries along the x-axis: IMDB-1 to IMDB-10, BIO-1 to BIO-4, FEV-1 to FEV-8, LEP-1 to LEP-5, AGENT-1 and AGENT-2. The widest gaps are BIO-2 (Quail ~130 s vs vLLM ~1,400 s) and BIO-3; AGENT-1 and AGENT-2 are the two bars where the orange vLLM bar is shorter than the blue Quail bar.*
>
> ![[sh_reya-688056-blog-09.png]]
>
> Figure 9\. Query latency at scale factor 0.1\. Bars show Quail and stock vLLM; horizontal lines show SoL estimates. The vertical axis uses a log scale because the query times span more than three orders of magnitude.
>
> [Figure 10](#figure-10) focuses on the eight queries where pipelining changes how vLLM submits requests. Pipelined vLLM is faster than stock vLLM on seven of them, by 1.12x on average and up to 1.27x on IMDB-6.
>
> *Figure 10. Requested input tokens per second as a percentage of each query's SoL estimate. Stock vLLM finishes one filter stage before submitting the next. Pipelined vLLM submits the next filter for each document as soon as the previous filter returns TRUE. Stock then pipelined: IMDB-4 27.9% -> 33.3%; IMDB-5 27.2% -> 31.4%; IMDB-6 30.1% -> 38.3%; IMDB-7 28.2% -> 33.7%; FEV-4 25.3% -> 28.4%; FEV-6 26.3% -> 26.2% (the only regression); LEP-4 32.9% -> 33.2%; LEP-5 38.0% -> 38.4%.*
>
> ![[sh_reya-688056-blog-10.png]]
>
> Figure 10\. Requested input tokens per second as a percentage of each query’s SoL estimate. Stock vLLM finishes one filter stage before submitting the next. Pipelined vLLM submits the next filter for each document as soon as the previous filter returns TRUE.
>
> Stock vLLM is faster than Quail only on AGENT-1 and AGENT-2\. Quail does not yet reuse matching prefixes across rows, so it recomputes far more KV tokens on each query. Section 4.4 examines AGENT-1.
>
> ## 4.3 Quail dominates vLLM on BIO-4: 14.04x faster!
>
> BIO-4 contains the kind of reuse Quail currently handles well: long shared documents, two joins, and millions of related model calls whose order is known before execution. At scale factor 1.0, BIO-4 filters 5,000 medical reports and two uses of the same 4,144 reaction terms, then runs two joins over the surviving inputs.
>
> [Table 2](#table-2) reports throughput, cost, and KV regret.
>
> | Metric                   | Quail         | Stock vLLM   | SoL estimate  |
> | ------------------------ | ------------- | ------------ | ------------- |
> | Requested input tokens/s | 19.03 million | 1.36 million | 37.37 million |
> | GPU cost per query       | $1.93         | $27.03       | $0.98         |
> | KV regret                | 18.0 million  | 50.3 million | 0 (assumed)   |
>
> Table 2\. BIO-4 results at scale factor 1.0\. GPU cost excludes model startup. SoL values are estimates.
>
> Quail takes 29.26 minutes, compared with 6.84 hours for stock vLLM. Quail is 14.04x faster. It is 1.96x the SoL estimate, while stock vLLM is 27.55x the estimate. Even with pipelining, vLLM still takes 4.00 hours.
>
> Quail costs $1.93 per query, compared with $27.03 for stock vLLM. The SoL cost estimate is $0.98 per query. Quail processes 19.03 million requested input tokens per second, compared with 1.36 million for stock vLLM.
>
> Quail also recomputes less KV. It recomputes 18.0 million tokens, compared with 50.3 million for stock vLLM.
>
> ## 4.4 But, vLLM dominates Quail on AGENT-1: Quail takes 2.32x as long.
>
> AGENT-1 contains a different kind of reuse. It filters 1,772 cumulative snapshots from software agent runs. Separate rows contain overlapping prefixes from the same agent trace, and stock vLLM’s automatic prefix caching recognizes them. Quail does not yet recognize that relationship, so stock vLLM wins. [Table 3](#table-3) shows two example rows.
>
> | id                  | trajectory\_id | turn\_index | trace                                                                                                        |
> | ------------------- | -------------- | ----------- | ------------------------------------------------------------------------------------------------------------ |
> | trace\_42\_turn\_5  | trace\_42      | 5           | \[USER\] Fix the failing parser. \[ASSISTANT\] Tries approach A. \[TOOL\] The test fails.                    |
> | trace\_42\_turn\_10 | trace\_42      | 10          | <complete trace from turn 5> \[ASSISTANT\] Finds the mistake, and tries approach B. \[TOOL\] The tests pass. |
>
> Table 3\. Two cumulative snapshots from the same software agent trace.
>
> Here is the AGENT-1 query, simplified for this post:
>
> ```
> SELECT t.id
> FROM agent_traces AS t
> WHERE AI.IF(PROMPT(
>     'Did the agent recover after trying an approach that did not work?\n\n{0}',
>     t.trace
> ));
>
> ```
>
> [Table 4](#table-4) reports throughput, cost, and KV regret.
>
> | Metric                   | Quail      | Stock vLLM | SoL estimate |
> | ------------------------ | ---------- | ---------- | ------------ |
> | Requested input tokens/s | 73,006     | 169,201    | 367,400      |
> | GPU cost per query       | $0.2623    | $0.1131    | $0.0521      |
> | KV regret                | 11,886,152 | 23,928     | 0 (assumed)  |
>
> Table 4\. AGENT-1 results. GPU cost excludes model startup. SoL values are estimates.
>
> Stock vLLM finishes AGENT-1 in 103.07 seconds, compared with Quail’s 239.12 seconds. Quail takes 2.32x as long. The SoL estimate is 47.47 seconds, so stock vLLM still takes 2.17x longer than the estimate.
>
> Stock vLLM wins because its automatic prefix caching can reuse KV across rows with matching token prefixes. Quail currently reuses KV only when the same document appears again in the query, not across different documents. As a result, Quail incurs 11.89 million KV regret tokens, while stock vLLM incurs only 23,928.
>
> We plan to add automatic prefix caching to Quail, but the lookup must remain cheap at the request volumes that AI-SQL queries can produce.
>
> # 5\. Put another way: Quail brings Jev-like speeds and intelligence to database-scale workloads.
>
> Quail also supports [DiffusionGemma 26B-A4B FP8](https://huggingface.co/RedHatAI/diffusiongemma-26B-A4B-it-FP8-dynamic), a larger mixture-of-experts model with 4B active parameters per token. This gives Quail a higher-intelligence option that is still extremely fast. On IMDB-2 at scale factor 0.1, DiffusionGemma matched 88.89% of Qwen3 32B’s answers, compared with 76.41% for Qwen3 4B. It ran the query in 32.41 seconds, or 1.53x as long as Qwen3 4B’s 21.20 seconds, on one H100.
>
> This fits a broader class of workloads that need fast, bounded model decisions instead of long generated responses. [Jev](https://typesafe.ai/blog/introducing-system-one-models-and-jev)has highlighted the demand for this pattern in application backends. Quail targets its batch, online analytical processing (OLAP) version: one query creates thousands or millions of related decisions over a dataset, and Quail plans and runs them together. This makes Quail a good fit for LLM judge workflows, trace compaction, labeling, and other large-scale data transformations.
>
> # 6\. We are just getting started with Quail!
>
> Some next steps are obvious. E.g., we want to support more AI-SQL operators, more models, and more hardware. We especially want to support tiny hybrid models, so you can run Quail on a MacBook.
>
> We are also interested many research ideas fusing the database and inference worlds; here are just a few:
>
> **Use the full memory hierarchy for KV.** Quail currently keeps reusable KV in GPU HBM or recomputes it. We want to move KV to host memory or local SSD when it does not fit on the GPU, then bring it back before reuse. We also want automatic prefix caching across rows. Perhaps we will also want to do KV compression (we know it is good to make indexes smaller).
>
> **Improve model FLOP/S utilization.** Quail currently relies on DeepGEMM and FlashAttention for its main GPU kernels. We have not optimized the kernels themselves, and we are stoked to be working with Modal and Doubleword, inference experts, on kernel optimization.
>
> **Train models for execution and planning.** [Google’s work on lightweight proxy models for AI-SQL](https://arxiv.org/abs/2603.15970) suggests small models can evaluate filters cheaply. The same models could predict selectivity and likely survivors for the query planner, helping Quail choose operator order and decide which KV to keep. The big systems question is how to run and train many specialized models alongside a larger model on the same GPU.
>
> **Can an AI join work like a hash join?** Today, Quail reuses an anchor’s KV within one join loop, but it recomputes every partner for each new anchor. The same document is therefore encoded once per pair. Could we instead encode every document once and use its KV as a position-independent index entry? A document from the other relation could then search those entries for matches, like probing a hash table, without recomputing the indexed documents. This may require removing or separating the position information that RoPE adds to KV.
>
> **New methods for using AI agents to build systems.** We used AI coding agents heavily to build the current version of Quail. We expect to keep using agents to build many of the features above. How do we do this correctly? We want better ways to specify what the system must do, and to check that every agent-written change keeps answers correct and runtime close to SoL. It feels inevitable that agents will do the bulk of the coding, and we are excited to build Quail in public and share the meta-learnings from building it with agents.
>
> More blog posts, and eventually a technical report, are coming soon. For now, please try [Quail](https://github.com/fsdatalab/quail)! If these ideas sound interesting, reach out to get involved! And if you want to build an application on top of Quail, such as an LLM judge workflow in AI-SQL, Quail has an MIT license. It is now orders of magnitude cheaper to add intelligence to your data processing workflows, and we would love to see what you build :-)
>
> # Acknowledgements
>
> We thank [Modal](https://modal.com/) for sponsoring the compute used in this research.
>
> # Notes
>
> **1.** The query is based on the [BioDEX dataset](https://aclanthology.org/2023.findings-emnlp.896/). The SQL form of BIO-4 is shown below. In each prompt, `{0}` and `{1}` refer to the first and second arguments.
>
> ```
> SELECT r.id,
>     n.id AS neurological_reaction_id,
>     c.id AS cardiovascular_reaction_id
> FROM reports AS r
> JOIN reaction_terms AS n
>     ON AI.IF(PROMPT(
>         'Does the medical report in {0} describe the reaction in {1} as '
>         'something the patient experienced?',
>         r.report,
>         n.term
>     ))
> JOIN reaction_terms AS c
>     ON AI.IF(PROMPT(
>         'Does the medical report in {0} describe the reaction in {1} as '
>         'something the patient experienced?',
>         r.report,
>         c.term
>     ))
> WHERE AI.IF(PROMPT(
>     'Does {0} describe a serious or life-threatening adverse event?',
>     r.report
> ))
> AND AI.IF(PROMPT(
>     'Is this reaction neurological, affecting the nervous system? {0}',
>     n.term
> ))
> AND AI.IF(PROMPT(
>     'Is this reaction cardiovascular, affecting the heart or blood vessels? {0}',
>     c.term
> ));
>
> ```
>
> **2.** Prompts use numbered placeholders, such as `{0}` and `{1}`, to refer to the arguments after the prompt string in the `PROMPT` call. The SQL call and the model input it produces are shown below.
>
> ```
> AI.IF(PROMPT(
>     'Does {0} mention {1}?',
>     r.report,
>     n.term
> ))
>
> ```
>
> The documents do not have to appear exactly where their placeholders occur in the question. Quail can place the report first so its KV can be reused when the same report is compared with another reaction term.
>
> The model receives the following input:
>
> ```
> DOCUMENT:
> [contents of r.report]
>
> (The document above is DOCUMENT {0}.)
>
> Evaluate TRUE or FALSE for the following question:
> Does {0} mention {1}?
>
> DOCUMENT {1}:
> [contents of n.term]
> ANSWER:
>
> ```
>
> Of course, whether other prompt layouts affect accuracy remains an open question, though we expect this to matter less as models improve.
>
> **3.** The speed of light estimate assumes 100 percent model FLOP/s utilization (MFU), meaning every forward pass sustains the GPU’s peak arithmetic throughput. Real systems cannot reach that rate, so the estimate is an optimistic lower bound.
>
> **4.** Modal provides useful background on [GPU utilization](https://modal.com/blog/gpu-utilization-guide) and [host overhead](https://modal.com/blog/host-overhead-inference-efficiency)in inference engines.
>
> **5.** The IMDB dataset was already on disk, so the measurement excludes the time and cost of downloading it.
>
> **6.** We use OpenAI’s [cached-token price](https://developers.openai.com/api/docs/models/gpt-5-nano) in this estimate and assume an “infinite” cache, so every reusable document token receives that rate.
>
> **7.** Marcel Rød built the fast [Gigatoken](https://github.com/marcelroed/gigatoken) tokenizer; thank you!
>
> **8.** Kernel fusion can substantially improve prefill MFU. In [“Chasing Speed of Light on TPU v6e,”](https://www.sailresearch.com/blog/tpu-v6e-gemma) Sail Research reports increasing Gemma 4 31B prefill MFU from about 32 percent to 63 percent through several optimizations, including folding activation, normalization, and RoPE work into surrounding kernels.
>
> **9.** We follow a long line of “Tree”-based attention approaches, which evaluate several branches that share a prefix without allowing one branch to attend to another. E.g., [SpecInfer](https://arxiv.org/abs/2305.09781) uses a tree mask during speculative decoding to verify several possible continuations at once. Also, [Hydragen](https://arxiv.org/abs/2402.05099) uses shared-prefix attention during decoding to generate several outputs from one input. Quail applies the same structure, but during prefill.
>
> **10.** One might expect two token IDs, one for each answer. For Qwen, Quail scores four spellings of each answer. The TRUE tokens are “TRUE” (20611), “␠TRUE” (8214), “True” (2514), and “␠True” (3007). The FALSE tokens are “FALSE” (30351), “␠FALSE” (7833), “False” (4049), and “␠False” (3557). Here, ␠ marks a leading space.
>
> **11.** Both baselines use vLLM 0.26.0 with automatic prefix caching. We use the largest stable settings: 25,305 maximum batched tokens, 4,096 sequences, GPU memory utilization of 0.91, and one CUDA graph for 8,192 tokens. Larger settings ran out of GPU memory.
>
> # Cite this post
>
> Copy BibTeX
>
> ```
> @misc{shankar2026quail,
>   title = {Building an Ultra-High Throughput AI-SQL Engine},
>   author = {Shankar, Shreya and Frye, Charles and Finn, Fergus and
>             Dhariya, Arnav and Barrow, Joseph and Arik, Meryem},
>   year = {2026},
>   month = sep,
>   url = {https://fsdatalab.github.io/blog/introducing-quail/}
> }
>
> ```
>
> ```json
> {"@context":"https://schema.org","@type":"BlogPosting","author":{"@type":"Person","name":"Shreya Shankar, Charles Frye, Fergus Finn, Arnav Dhariya, Joseph Barrow, Meryem Arik"},"dateModified":"2026-09-24T00:00:00+00:00","datePublished":"2026-09-24T00:00:00+00:00","description":"Quail jointly plans AI-SQL queries and model inference. Across 29 QUAIL-B queries, it is 1.84x faster on average than well-tuned vLLM baselines.","headline":"Building an Ultra-High Throughput AI-SQL Engine","image":{"width":2048,"height":929,"alt":"Quail throughput compared with stock vLLM across five AI-SQL datasets.","url":"https://fsdatalab.github.io/assets/blog/introducing-quail/quail-throughput-by-dataset.png","@type":"imageObject"},"mainEntityOfPage":{"@type":"WebPage","@id":"https://fsdatalab.github.io/blog/introducing-quail/"},"url":"https://fsdatalab.github.io/blog/introducing-quail/"}
> ```

### Modal post

> [!quote]- Full companion post, verbatim - Charles Frye (Modal) and Shreya Shankar (CMU FSD Lab), "Hitting a billion tokens per minute on one GPU by combining a query planner and an inference engine", Modal Blog, 24 September 2026, 15 minute read. This is where the 1.14 billion tokens/minute figure is stated.
> Title: Hitting a billion tokens per minute on one GPU by combining a query planner and an inference engine | Modal Blog
>
> URL Source: https://modal.com/blog/quail-billion-tpm
>
> Markdown Content:
> ---
> description: Maximizing perf on AI-SQL queries with the KV-optimal left-deep join
> title: Hitting a billion tokens per minute on one GPU by combining a query planner and an inference engine | Modal Blog
> image: https://modal.com/docs/social-image.png?title=Hitting+a+billion+tokens+per+minute+on+one+GPU+by+combining+a+query+planner+and+an+inference+engine&amp;socialType=blog
> ---
>
>  
>
> Runtime is almost here: join TypeSafe AI, Cognition, DoorDash and more in SF. Limited seats left. [Register now](/runtime?utm%5Fsource=announcement%5Fbar) 
>
> [ All posts](/blog)
>
> [ Back](/blog) 
>
> Research
>
> September 24, 2026 •15 minute read
>
> # Hitting a billion tokens per minute on one GPU by combining a query planner and an inference engine
>
> ![User avatar](https://modal-cdn.com/charles-frye.jpg) 
>
> [Charles Frye](https://twitter.com/charles%5Firl) 
>
> Member of Technical Staff
>
> [@charles\_irl](https://twitter.com/charles%5Firl)
>
> ![User avatar](https://modal-cdn.com/blog/authors/shreya-shankar.jpg) 
>
> [Shreya Shankar](https://twitter.com/sh%5Freya) 
>
> Asst Professor, CMU FSD Lab
>
> [@sh\_reya](https://twitter.com/sh%5Freya)
>
> > _I see it as a point on the LLM pareto optimal curve in a regime that had a large revealed latent demand (no thinking, single token, low latency acceptable intelligence) that was under-invested into because of a race to higher intelligence._  
> >  
> > \- [Karpathy-san, on Jev](https://x.com/karpathy/status/2102124533729955960?s=20)
>
> While everyone and their cousin is loudly building coding agents and chatbots, there’s a quieter inference revolution going on in the backend. Simple LLM transformations of data can be incredibly powerful, provided the cost-performance is good enough — just scroll social media and catch a few of the eye-popping, [hack-inspiring](https://x.com/mattdesl/status/2100899669802963060?s=20) demos of [TypeSafe AI’](https://typesafe.ai/)s [Jev](https://typesafe.ai/blog/introducing-system-one-models-and-jev) model.
>
> Jev implements these transformations at what you might call the “JSON layer”, Web-style interfaces between clients and services.
>
> [AI-SQL](https://docs.snowflake.com/en/user-guide/snowflake-cortex/aisql) implements it at the analytic SQL layer, at the interface between business intelligence and the database:
>
> ```
> -- get hot leads with AI™
> SELECT customers.id, products.id
> FROM customers JOIN products ON  -- for each row in both tables
> AI.IF(  -- run the prompt below and filter by truthiness
> 		PROMPT("{customers.profile} might buy this: {products.description}")
> )
> ```
>
> Different inference applications produce different [inference workloads](https://modal.com/llm-almanac/workloads), and AI-SQL is no exception. A query like the one above might produce millions of sequences of thousands of tokens — RIP your token budget. These queries often require much less than frontier intelligence, so small open-weights models can crush. But naïvely delivering these sequences directly to an inference engine optimized for agentic inference through interfaces for arbitrary user-controlled requests is inherently and massively inefficient.
>
> So we built an inference engine to fix this: the [QUery-Aware Inference Layer](https://github.com/fsdatalab/quail) (Quail). On one multi-join query where planning is particularly important, Quail hits over a billion tokens processed per minute per H100 GPU (TPM/GPU), >10x faster than our vLLM baseline on the same hardware. On Modal, that comes out to under 6¢ per billion tokens.
>
> *Modal's BIO-4 comparison, three log-scale panels. Seconds: Quail 1,755 vs "pipelined vLLM" 24,641. $/Query: Quail $1.93 vs $27.03. Throughput, tokens per minute: Quail 1.14B vs 82.6M. Note that the baseline's numbers (24,641 s = 6.845 hours, $27.03) match the lab post's *stock* vLLM row, not its pipelined vLLM figure of 4.00 hours, so the x-axis label appears to be an error.*
>
> ![[sh_reya-688056-modal-01.png]]
>
> On [our newly-released benchmark for AI-SQL queries](https://github.com/fsdatalab/quail-bench), Quail runs 1.84x faster than vLLM, geometrically averaged over tasks -- including two queries we designed to demonstrate areas for future improvement in AI-SQL inference.
>
> You can take it for a spin on Modal right now:
>
> ```
> # uvx modal run try_quail.py
>
> import modal
>
> app = modal.App("try-quail")
> image = (
>     modal.Image.from_registry("nvidia/cuda:13.0.1-devel-ubuntu24.04", add_python="3.12")
>     .entrypoint([])
>     .apt_install("git")
>     .uv_pip_install("quail-engine==0.1.0")
> )
>
>
> @app.function(gpu="H100!", image=image, timeout=600)
> def run(sql=None, documents=None):
>     from datasets import load_dataset
>     import pyarrow as pa
>     import quail
>
>     if sql is None:
>         sql = """ // no spoilers!
>                 SELECT r.id
>                 FROM reviews r
>                 WHERE AI_FILTER(PROMPT('Does this review discuss the ending?\n\n{0}', r.review))
>                 """
>
>     if documents is None:
>         imdb = load_dataset("stanfordnlp/imdb")["train"]
>
>         documents = pa.table(
>             {
>                 "id": pa.array(f"review-{i}" for i in range(len(imdb))),
>                 "review": imdb.data.table.column("text"),
>             }
>         )
>
>     config = quail.EngineConfig(
>         gpus=1,
>         model="qwen3-4b-fp8",
>         backend="quail",
>         device="h100-sxm",
>     )
>
>     with quail.Session(config) as session:
>         session.register(
>             "reviews",
>             quail.DocumentProvider.from_table(documents, id_col="id"),
>         )
>         result = session.sql(sql).run()
>
>         print(result.collect())
>         print(result.report)
> ```
>
> In this blog, we’ll give a quick overview of the problem we’re solving and how Quail works today. Spoilers: the big win is that with a structured query in hand, you can order requests to better cache (and evict) KV. This requires a slight revision of [Hydragen](https://arxiv.org/abs/2402.05099)\-style [cascade attention](https://flashinfer.ai/2024/02/02/cascade-inference.html). Large numbers of small requests for small models can also incur lots of [host overhead](https://modal.com/blog/host-overhead-inference-efficiency), aka have low [GPU utilization](https://modal.com/blog/gpu-utilization-guide), which can be avoided when you know the structure of the requests ahead of time.
>
> This was a collaboration between inference researchers at Modal and database researchers Carnegie Mellon University’s [Full Stack Data Lab](https://fsdatalab.github.io/) — call it a “mixture of experts”. We’re sharing what we did because we’d like to make this work more “expert-parallel”, as it were. We believe this is only the beginning for open source performance engineering at the intersection of inference and databases — two of the most important applications of computing.
>
> In this post, we’ll focus more on considerations for inference engineers. You can read more, from a database engineer’s perspective, at [the Full Stack Data Lab blog](https://fsdatalab.github.io/blog/introducing-quail/#43-quail-dominates-vllm-on-bio-4-1404x-faster). You can also check out the code for Quail [here](https://github.com/fsdatalab/quail) or the docs [here](https://fsdatalab.github.io/quail/docs). And if you run AI-SQL queries at scale and are interested in improving performance and cutting costs, [get in touch with us](#).
>
> # What are AI Functions and AI-SQL?
>
> First, a bit more background on the workload.
>
> This is emphatically _not_ prompting AI systems to produce SQL based on natural language inputs — that’s [NL2SQL](https://arxiv.org/html/2408.05109v4). That looks a lot like a traditional chatbot or coding agent workload, so existing inference engines work well.
>
> It’s actually the other way around! In AI-SQL, we use an extension of SQL to programmatically produce (and consume) prompts for AI systems. Prompts are constructed from database entries and produce tables.
>
> Like this:
>
> ```
> -- get hot leads with AI™
> SELECT customers.id, products.id
> FROM customers JOIN products ON  -- for each row in both tables
> AI.IF(  -- run the prompt below and filter by truthiness
> 		PROMPT("{customers.profile} might buy this: {products.description}")
> )
> ```
>
> AI-SQL is primarily used inside of business intelligence (BI) platforms to help data scientists and stakeholders ask more “fuzzy” questions of their semi-structured data, like documents and free-text fields.
>
> There’s not a standard (yet), but major managed analytical database platforms have their own flavor: [Snowflake Cortex AI-SQL](https://docs.snowflake.com/en/user-guide/snowflake-cortex/aisql), [Databricks AI Functions](https://docs.databricks.com/aws/en/large-language-models/ai-functions), [BigQuery AI functions](https://cloud.google.com/blog/products/data-analytics/sql-reimagined-for-the-ai-era-with-bigquery-ai-functions).
>
> # Unlike the rest of SQL, this problem actually needs GPUs.
>
> Consider the following plan for a query over the [BioDEX dataset](https://github.com/KarelDO/BioDEX), which selects reports of serious adverse events in response to drugs that include both a neurological and a cardiovascular component:
>
> *The BIO-4 plan again, Modal's dark rendering of the same graph as Figure 1: three Scans (reports, reaction terms as c, reaction terms as n) into three AI_FILTER filter stages (serious adverse event?, cardiovascular reaction?, neurological reaction?), materialized survivors into the first AI_JOIN (cardiovascular reaction experienced?, anchor: report), materialized join rows into the second AI_JOIN (neurological reaction experienced?, anchor: report).*
>
> ![[sh_reya-688056-modal-02.png]]
>
> If these were normal filters and joins, say based on string matching and logical equality, there’d be no good reason to use a high-throughput numerical accelerator like a GPU, even though this is an analytical query, which seems “throughput-y”. This may be obvious to some, but let’s step through the logic anyway.
>
> Each byte loaded from durable storage to memory (or from memory to registers) would need at most a handful of arithmetic/logic operations to implement comparisons. GPUs are designed for workloads with high [arithmetic intensity](https://modal.com/gpu-glossary/perf/arithmetic-intensity) — many operations per byte loaded. And the latest GPUs have most of their [arithmetic bandwidth](https://modal.com/gpu-glossary/perf/arithmetic-bandwidth) in specialized hardware for large matrix multiplications, aka [Tensor Cores](https://modal.com/gpu-glossary/device-hardware/tensor-core). Normal filtering/joining requires no large matrix multiplications.
>
> But this query plan uses `AI_FILTER` and `AI_JOIN`, which instead pass the inputs through a large language model. An LLM is a sequence of numerical operations, the bottleneck for which is large matrix multiplications. Each byte loaded from durable storage will be subject to on the order of billions of operations before a byte is written to storage.
>
> # Why is this interesting to inference engineers?
>
> Most inference engineering these days is focused on one workload shape in particular: iterative construction of long input sequences by users and tool calls external to the inference service. This is the shape of workloads from chatbots and agents — and of “rollout” inference during the reinforcement learning runs that fine-tune models to be chatbots or agents.
>
> Don’t get us wrong, this is very important work! We’ve written about our approach to it [here](https://modal.com/blog/trillion-tokens-trillion-parameters). But for the hardcore inference engineer, it’s honestly starting to feel a little… played out.
>
> There’s also some work on ultra low-latency inference where speed matters as much as intelligence. We’ve written about our techniques for this [here](https://modal.com/blog/achieve-sota-specdec). In general, these workloads use structured outputs/tool-calling. They end up as something like the “OLTP” of inference, slotting into other computer applications more easily than open-ended agents. The recent popularity of Jev demonstrates the importance of these workloads — and that we are still so early!
>
> AI-SQL workloads haven’t gotten so much attention — yet — but we think they are interesting for inference engineers for a number of fundamental reasons, quite outside their importance to applications. Most intriguingly, they are an incredible fit for transformers (because they enable “perfect” KV cache use) and for transformers-on-GPUs (because they don’t require decode).
>
> ## Manage a KV cache without all the regrets.
>
> In typical inference, requests are client-controlled and arbitrary. This causes [no end of pain](https://modal.com/blog/trillion-tokens-trillion-parameters). But in AI-SQL inference, clients only control SQL queries, which create many requests, and the combined query planner/inference engine has substantial control over the processing of those requests.
>
> This makes it particularly easy to operate a cache that amortizes more work. For instance, we know exactly when any cache entry is no longer needed, so we can fearlessly evict it. We also know quite a bit about what the cache demand will look like, since we get an entire query plan’s worth of requests up front.
>
> And we badly need caching for Transformers, because their forward passes are naïvely quadratic in the sequence length. We can exchange that for linear time and linear storage with KV caching.
>
> KV caches can be tricky to operate for agent workloads, because the time between accesses is completely unknown. But for an AI-SQL query, we control the inference engine requests and so can anticipate future accesses and apply optimizations like prefetching. And furthermore, because we are oriented to token throughput, we care less about latency to retrieve KV entries. This makes, for instance, operating a multi-tier KV cache much more feasible.
>
> ## Look, mom, no decode!
>
> Sequence model inference is split into two phases: “prefill”, when most of the KV cache is generated, and “decode” phase when most of the output tokens are generated.
>
> *Modal's prefill/decode diagram, reused from its speculative-decoding post: a client prompt "Thou shalt not create" enters the server, one prefill box emits "a machine", three successive decode boxes emit "in the likeness", "of a human" and "mind.", all sharing one KV Cache, and the completion "a machine in the likeness of a human mind" returns to the client. Quail's point is that AI-SQL stops after the prefill box.*
>
> ![[sh_reya-688056-modal-03.png]]
>
> Decode is kind of a pain. GPUs aren’t particularly good at it. Decode has low [arithmetic intensity](https://modal.com/gpu-glossary/perf/arithmetic-intensity) so even though GPUs provide lots of [memory bandwidth](https://modal.com/gpu-glossary/perf/memory-bandwidth), it’s tricky to keep the [arithmetic bandwidth](https://modal.com/gpu-glossary/perf/arithmetic-bandwidth) saturated.
>
> Agentic applications skew heavy on the decode — even though there are more input tokens than output tokens, the decode is so much slower that it takes most of the time. This problem is so bad that inference service deployments are often forced to adopt complex solutions like cross-node prefill-decode disaggregation just to get acceptable perf.
>
> But not _all_ tokens are generated during decode. The final “prefill” forward pass during input sequence processing emits a prediction for a single token.
>
> And for Boolean classification of a sequence, aka `AI.IF`, a single token is all you need — literally.
>
> This matters because `AI.IF` isn’t a sideshow. It’s how joins are implemented in AI-SQL (`JOIN ON AI.IF`). With a bit of cleverness in prompt construction, `AI.CLASSIFY` can be mapped onto a single token as well, for a number of classes up to the size of the vocabulary (we’ve left that one for future work!).
>
> Presently, we don’t take much advantage of this, except in what we _don’t_ implement:
>
> * Separate prefill and decode phases (let alone disaggregation), because there is no decode
> * Sampling, because there are no generated tokens, only probabilities
> * CUDA Graph capture, because prefills have long enough durations that launch overhead is negligible, even for small models on big GPUs
> * [Speculative decoding](https://modal.com/blog/spec-is-all-u-need), because that accelerates decodes of more than one token
>
> But we anticipate deeper opportunities to optimize prefill-only inference!
>
> # Quail jointly optimizes a SQL query and an inference workload.
>
> With the shape of the SQL problem and the inference problem in hand, let’s now quickly walk through the architecture of Quail, with a focus on the query planner and execution engine.
>
> ## Architecture overview
>
> You may not have noticed yet, but building databases is easy now (see [Stonebraker & Pavlo, 2024](https://dl.acm.org/doi/10.1145/3685980.3685984) or [this talk on Apache DataFusion by Andrew Lamb](https://www.youtube.com/watch?v=iJhRbDFJjbg)). Specifically, analytical databases are much easier to build because many key components are standardized with extensible open source implementations. And composing open source components is now mad easy, thanks to coding agents.
>
> The key components are, in order from external interface to internal implementation details, the SQL parser, the query planner, the execution engine, and the storage engine.
>
> 1. **SQL Parser**. We use [the Python sqlglot library by @tobymao](https://github.com/tobymao/sqlglot), which has `snowflake` and `bigquery` dialects. AI-SQL is handled via “anonymous” expressions, aka punted to the query planner.
> 2. **Query Planner.** This part is substantively custom, since it is the meat of the work. We describe it below. We use [Substrait](https://substrait.io/) to serialize query plans for benchmarking.
> 3. **Execution Engine.** We forked off of vLLM’s implementation for model forward passes, then modified the kernels as described below (mostly writing Triton to get kernel fusion). We didn’t add full SQL execution support yet, but that’s a fairly straightforward addition with DataFusion.
> 4. **Storage Engine.** We use [pyarrow](https://github.com/apache/arrow) to manage the columnar Arrow format. This an analytical workload, which is write-once/read-many, aka “filesystems on easy mode”. We assume this is fetched up front from object storage like S3 or a distributed filesystem like [Modal Volumes](https://modal.com/docs/guide/volumes).
>
> ## Designing a query planner for an inference engine
>
> The query planner takes a logical plan based on parsing the SQL query and transforms that plan — both across equivalent logical plans and into “physical” plans with concrete operations. The design space for query planners is humongous. They are, after all, essentially compilers!
>
> But our problem set is restricted to filters and joins, and within that we were further able to mostly use well-known techniques. We do predicate push-down past joins, filter ordering based on selectivity a la [Hellerstein and Stonebraker](https://dsf.berkeley.edu/jmh/miscpapers/sigmod93.pdf), and join ordering with dynamic programming on deep trees as in [the classic 1976 System R paper](https://dl.acm.org/doi/10.1145/320455.320457). That’s a very terse overview — more details on the database side on the Full Stack Data Lab blog [here](https://fsdatalab.github.io/blog/introducing-quail/)!
>
> Here, we’ll briefly touch on the Transformer inference/GPU-centric contributions, in the cost model and join ordering algorithm. Specifically, Quail adds speed-of-light estimation to the cost model and KV-awareness to the join order search.
>
> ### KV-aware join-order search
>
> Join ordering is classically based on “divide-and-conquer” dynamic programming. At a high level: select the optimal choice at one step, then search for the optimal sub-plan with that choice fixed.
>
> Our case is not quite as simple as normal join ordering. We additionally track KV state from previous plans just in case what looked like a bad option at first turns out to be useful for a later join that can re-use its KV.
>
> During search, we maintain multiple candidates. We eliminate plans only if a new candidate plan has fewer tokens, fewer attention pairs, and fewer cached tokens — it has been “dominated”, in the Pareto sense. We then select the final plan by applying the speed-of-light cost estimate, described below.
>
> Join ordering is hard! We expect there to be substantial improvements to this technique, and we’d love to work on them with you.
>
> ### Pessimistically estimating the speed of light
>
> Like most databases, our hardware-based cost estimates are fairly crude. We use [Williams, Waterman, & Patterson’s “roofline model”](https://people.eecs.berkeley.edu/~kubitron/cs252/handouts/papers/RooflineVyNoYellow.pdf) of throughput-oriented hardware to estimate the “speed-of-light” based on hardware [peak rates](https://modal.com/gpu-glossary/perf/peak-rate), which has its limitations (cf last paragraph in [our GPU Performance Glossary entry on performance bottlenecks](https://modal.com/gpu-glossary/perf/performance-bottleneck)).
>
> But crude doesn’t mean ineffective! For one, the SoL model was a critical tool for sanity checking results while iterating. For another, it errs on the side of over-estimating peak performance, rather than missing at random or under-estimating. Compare it to the north star: you can never reach it, but it still helps you head north.
>
> Detailed code is [here](https://github.com/fsdatalab/quail/blob/main/quail/cost/sol.py), but the cost model something like this:
>
> ```
> min_latency = 0
> for module in model.modules:
>     latency_bound = module.bytes / hardware.memory_bandwidth
>     compute_bound = module.flops / hardware.compute_bandwidth[module.precision]
>     min_latency += max(latency_bound, compute_bound)
> ```
>
> The calculation is based only on the subset of modules that are high poles in the tent for the target workloads: per-token attention projections and MLP/MoE layers and cross-token attention calculations.
>
> In principle this must be done once per model, but in practice models share a lot of operators. We’ve found that contemporary coding agents are quite good at reading a Hugging Face config and generating a reasonable cost model in this setup — though their output often needs a vibe check. For another application of roofline-SoL-based cost modeling, see [our speculative decoding speedup estimator](https://modal.com/llm-almanac/spec-dec-roofline).
>
> ## An inference engine as an execution engine
>
> Once a final physical plan has been selected, it must be implemented by the execution engine.
>
> But before thinking too much about the GPU side of things, it is important to [get the CPU out of the way](https://modal.com/blog/host-overhead-inference-efficiency). Anyone who has worked on high-performance storage or networking will be familiar with the basic beats here.
>
> In this case, we have lots of sequences (millions) and a small model (billions of parameters) on a big GPU (H100), which is outside of the design space for most tokenizer backends. We used [Gigatoken](https://github.com/marcelroed/gigatoken) from our friend Marcel Rød at Stanford. Side note: this work happens in the query planner, but then gets re-used at execution time. We store token IDs in memory-mapped Arrow files, the same basic technology in our storage engine.
>
> Going down to the GPU layer: we started from the model forward pass implementations in vLLM and then rewrote them with a few custom optimizations. We’re very grateful to be able to build on the work of the community here!
>
> The kernels we use for the core matmul and attention operations are standard: [DeepSeek’s DeepGEMM](https://github.com/deepseek-ai/DeepGEMM) and [Dao et al.’s Flash Attention 3](https://github.com/dao-ailab/flash-attention). These kernels are quite good at high-throughput/prefill-only inference.
>
> The speed-of-light cost model only considers these operations, but there are many others in the forward pass. Their runtimes are in principle negligible, but there are a lot of them and they add up, including host overhead to launch those kernels.
>
> The standard technique here is to combine several smaller kernels into one, aka _kernel fusion_. Luckily it is quite easy now to author a custom kernel in [OpenAI’s Triton](https://github.com/triton-lang/triton) — especially with coding agent assistance and a reference implementation! We fuse the add-RMSNorm with fp8 quantization and we fuse the per-head query/key RMSNorm with rotary embeddings.
>
> We do need to “wrap” FlashAttention in some custom logic. In the join of A and B, many suffix documents from B attend to the same anchor from A. Naïvely mapped onto FlashAttention, that gives you many replications of the anchor during execution.
>
> We avoid this by doing a “recursive” or “combination of partials” attention calculation for joins.
>
> First, we attend from all suffix queries to the anchor, a kind of “cross-attention”. Suffixes then attend to themselves, and results are finally merged with LSE-rescaling, a la [Dao et al.’s flash decoding](https://pytorch.org/blog/flash-decoding/). Suffixes’ KV are not written to cache — we’re doing zero decode, and we never do (N>2)-way joins, so we don’t need them!
>
> This is very similar to [Flash Infer’s cascade attention](https://flashinfer.ai/2024/02/02/cascade-inference.html) or [Scaly/Hazy’s Hydragen](https://arxiv.org/abs/2402.05099). It also looks like [tree attention](https://arxiv.org/abs/2406.17276), but for the special case of a depth-one tree. We have the same motivation as in those techniques: shared re-use of prefixes. But because we know the shared prefixes ahead of time, we can skip a lot of complexity.
>
> Additionally, we make one optimization at the model layer. Because we’re only doing filters and joins, we only need the model to output probabilities for truthy and falsy tokens. That means our vocabulary only has 8 options — an extreme case of structured outputs. This is known at engine boot time, so we just drop those columns from the model’s language-modeling head entirely, cutting the final unembedding matmul from vocab size x latent size to 8 x latent size.
>
> # What is the future of inference engines?
>
> Finally, if you run AI-SQL queries and are interested in improving performance and cutting costs, [get in touch with us](#).
>
> We’ve [worked](https://www.lmsys.org/blog/2026-06-15-next-generation-speculative-decoding-dflash-v2/) a [lot](https://modal.com/blog/boosting-multimodal-inference-performance-by-greater-than-10-with-a-single-python-dictionary) on [SGLang](https://modal.com/blog/host-overhead-inference-efficiency) and built our own custom engines, including Quail, and this has led to us having some _opinions_ about where the field is going. This is both a critical time for inference engine work, because these systems are new (years old, not decades), and for software engineering as a whole, because coding agents are changing the constraints on research and development. A few notes on this below.
>
> ## This is only the beginning for optimized AI-SQL inference.
>
> There are many obvious additional optimizations for Quail and AI-SQL workloads. We could produce better plans and we’re still short of the speed-of-light for the plans we execute.
>
> Here’s a quick ~~flag-planting list so we can Schmidhuber anyone who implements them~~ list of things we’d love to see more work on:
>
> **1\. Add more tiers to the KV cache.**
>
> We only cache KV values in the GPU HBM. But there are more storage layers, and great caches are always multi-layer. Systems like [LMSYS Org’s HiCache](https://www.lmsys.org/blog/2025-09-10-sglang-hicache/) help manage multi-layer caches. [We’ve used it for the workload class it is designed for](https://modal.com/blog/trillion-tokens-trillion-parameters), chatbot/agent inference, but we didn’t apply it here.
>
> Because this workload is quite different, we expect there to be room to improve existing caching systems. In particular, we both know more about and have more control over request ordering, so we can more directly manage the cache, and we are substantively insensitive to latency, so we benefit from even higher, slower tiers of storage, especially with striping. Perhaps we might feed our LLM from tapes?
>
> **2\. Optimize across queries.**
>
> We also only cache KV values during the lifetime of a request. We don’t toss Bloom filters or zone maps in the trash so why do it with KV cache? GPU HBM is too precious to do this, but higher cache tiers are much cheaper.
>
> **3\. Support larger-than-memory datasets.**
>
> As evinced by the success of [antirez’s Redis](https://github.com/redis/redis) and [Mühleisen and Raasveldt’s DuckDB](https://github.com/duckdb/duckdb), you can build a useful database system without a backing durable store. And inference is so computationally intense that dataset sizes are often smaller.
>
> But that’s not an excuse to stop at in-memory processing! Because the KV representation is so much larger than the stored representation, applying this technique will also benefit from tiered KV caching.
>
> **4\. Radix index for better sharing.**
>
> In our benchmark suite, we fall behind vLLM on one case: processing a dataset of agent traces. We added this benchmark specifically because we wanted to demonstrate that our system, as we initially constructed it, was making a trade-off, rather than somehow being universally better than existing engines with far more engineering effort.
>
> In particular, the agent benchmark can be mapped into agent serving — simply store all session histories in the database, then `SELECT` those histories with a new input message and run `AI_COMPLETE`. This creates a lot of cross-document prefix sharing that our current system can’t model or take advantage of.
>
> But we could still make Quail’s performance better here! For instance, we might construct a radix tree index over documents and then look for KV cache re-use opportunities.
>
> **5\. Better overlap across kernels.**
>
> We stuck to relatively simple kernel-level techniques like fusion in Triton, and we know we’re still short of the speed of light. A common cause of shortfall there is overhead or insufficient re-use of resources across kernels. A [throughput-oriented megakernel a la Hazy Research](https://hazyresearch.stanford.edu/blog/2025-09-28-tp-llama-main) or even just [CUDA programmatic dependent launch](https://docs.nvidia.com/cuda/cuda-programming-guide/04-special-topics/programmatic-dependent-launch.html) would improve overlap and might improve performance.
>
> **6\. On-the-fly fine-tuning.**
>
> Lastly, something much more speculative. In modern analytical databases, operators are often optimized mid-execution, e.g. with specialization and JIT compilation — see [Umbra’s “Flying Start” compiler](https://db.in.tum.de/~kersten/Tidy%20Tuples%20and%20Flying%20Start%20Fast%20Compilation%20and%20Fast%20Execution%20of%20Relational%20Queries%20in%20Umbra.pdf). These optimized modules are then swapped in to the query mid-execution.
>
> We might similarly “compile” faster models via quantization, pruning, distillation, and similar techniques, run concurrently with the query and then swapped in once accuracy reaches acceptable levels. And ML training can indeed be operationalized to this degree! See [Anil et al.’s “On the Factory Floor” paper](https://arxiv.org/abs/2209.05310).
>
> ## Vibe-coded inference engines with a shared core.
>
> We did most of this work by prompting coding agents. The hard part was no longer execution on ideas, but problem definition and result measurement — taste and quality assurance.
>
> Is this where software engineering and systems research is going? We don’t know, but it seems likely to us! Whatever happens, it will be weird, and it will require the kind of thoughtful attention to working habits, to community structure, and to incentives [that has been recently admirably demonstrated by the mathematics community](https://mathandai.org/).
>
> More narrowly, we are very aware that there has been a recent efflorescence of custom inference engines, where the engine is developed with a narrower workload or set of workloads in mind. The [VibeServe agentic development system from the SyFI lab](https://arxiv.org/abs/2605.06068) demonstrates that this authoring process can even be generalized, subject to properly defined baselines and goals.
>
> We expect this trend to continue, but we don’t expect all code for inference systems to be written from scratch per application just yet. There is too much benefit from open source collaboration — operational simplicity, increased velocity, “given enough eyeballs, all bugs are shallow”. Coding agents change some of the coefficients, but we don’t think they eliminate the cooperative equilibrium strategy that drives open source contribution.
>
> Instead, we think the inference world will soon look a bit more like databases post-[DataFusion](https://github.com/apache/datafusion): a reusable “core” that is expressive enough to absorb new techniques but controlled enough to provide guarantees. For a proof-of-concept, see [ekzhang’s tweet about an agent-extensible inference engine](https://x.com/ekzhang1/status/2089507697930678419?s=20).
>
> Existing inference engines like vLLM and SGLang might also be adapted to serve better as that core — see the [nano-vllm](https://github.com/GeeeekExplorer/nano-vllm) and [mini-sglang](https://github.com/sgl-project/mini-sglang) projects.
>
> ### Acknowledgements
>
> We thank [Joe Barrow](https://jbarrow.ai/about/) of Adobe and the team at [DoubleWord](https://doubleword.ai/), especially [Fergus Finn](https://fergusfinn.com/), for reviewing and providing feedback on this work.
>
> ## Ship your first app in minutes. 
>
> [Get Started ](/signup) 
>
> $30 / month free compute

### Repository README

> [!quote]- `fsdatalab/quail` README, verbatim - MIT, Python, 95 stars, created 1 August 2026
> # Quail
>
> Quail (QUery Aware Inference Layer) is an open-source, extensible
> execution engine for AI-SQL, being developed at
> [Full Stack Data Lab](https://fsdatalab.github.io/) at CMU.
>
> AI-SQL is a variant of SQL with operators that let you write logic
> in natural language for an LLM to evaluate on every row.
>
> ```sql
> SELECT r.id
> FROM reviews r
> WHERE AI.IF(PROMPT('Does this review discuss the ending?\n\n{0}', r.body))
> ```
>
> [Documentation](https://fsdatalab.github.io/quail) |
> [Quickstart](https://fsdatalab.github.io/quail/docs/user-guide/quickstart) |
> [QUAIL-B](https://github.com/fsdatalab/quail-bench)
>
> ## Install
>
> Install [quail-engine from PyPI](https://pypi.org/project/quail-engine/).
> The package is named `quail-engine`; in Python, import `quail`.
>
> ```bash
> uv pip install quail-engine
> ```
>
> Requires Python 3.12 and a CUDA GPU.
>
> ## Example
>
> ```python
> import pyarrow as pa
> import quail
>
> reviews = pa.table({
>     "id": ["r1", "r2", "r3"],
>     "body": [
>         "A beautiful film with outstanding performances.",
>         "Terrible pacing and a nonsensical plot.",
>         "The cinematography was stunning, though the story dragged.",
>     ],
> })
>
> config = quail.EngineConfig(model="qwen3-4b-fp8", device="h100-sxm")
> with quail.Session(config=config) as session:
>     session.register("reviews", quail.DocumentProvider.from_table(reviews, id_col="id"))
>     result = session.sql("""
>         SELECT r.id
>         FROM reviews r
>         WHERE AI.IF(PROMPT(
>             'Does this review mention a positive aspect of the movie?\n\n{0}',
>             r.body))
>     """, dialect="bq").collect()
>     print(result)
> ```
>
> ## Quail Server
>
> Quail Server is an optional HTTP server that runs on the machine with
> the GPU. You start it once, send queries to it with `endpoint`, and
> the query keeps running after the client disconnects. `submit()`
> returns once the server has saved the record, and `get_run` reads
> that record later.
>
> ```bash
> uv pip install "quail-engine[server]"
> quail-server
> ```
>
> ```python
> import pyarrow as pa
> import quail
>
> reviews = pa.table({
>     "id": ["r1", "r2"],
>     "body": ["The ending was excellent.", "I liked the soundtrack."],
> })
> sql = """
>     SELECT r.id
>     FROM reviews r
>     WHERE AI.IF(PROMPT('Does this discuss the ending? {0}', r.body))
> """
> config = quail.EngineConfig(model="qwen3-4b-fp8", device="h100-sxm")
>
> with quail.Session(
>     config=config,
>     endpoint="http://127.0.0.1:8642",
> ) as session:
>     session.register(
>         "reviews",
>         quail.DocumentProvider.from_table(reviews, id_col="id"),
>     )
>     run = session.sql(sql, dialect="bq").submit()
>     for status in run.watch():
>         print(status.phase["message"])
>     table = run.result().collect()
>     print(table)
> ```
>
> See [Quail Server](https://fsdatalab.github.io/quail/docs/user-guide/server).
>
> ## Supported operators
>
> Quail currently supports AI-powered filters, joins, and
> `EXISTS` / `NOT EXISTS`. We are actively adding more operators
> (`AI.CLASSIFY`, `AI.EXTRACT`, `AI.MAP`).
>
> We support two AI-SQL dialects:
> [Snowflake `AI_FILTER`](https://docs.snowflake.com/en/user-guide/snowflake-cortex/aisql)
> and
> [BigQuery `AI.IF`](https://cloud.google.com/blog/products/data-analytics/sql-reimagined-for-the-ai-era-with-bigquery-ai-functions),
> plus a Python builder API.
>
> ## Supported models and GPUs
>
> | Model | Device |
> | --- | --- |
> | Qwen3 4B fp8 | NVIDIA H100 SXM |
> | Qwen3 32B fp8 | NVIDIA RTX PRO 6000 Blackwell Server Edition |
> | DiffusionGemma 26B-A4B fp8 | NVIDIA H100 SXM |
>
> 1, 2, 4, or 8 GPUs per query. We are actively adding more models
> and hardware.
>
> ## Development
>
> ```bash
> uv run ruff check quail tests experiments tools
> uv run python tools/check_long_strings.py
> uv run vulture
> uv run pytest -q
> ```
>
> ## Contributing
>
> See the [contributing guide](https://fsdatalab.github.io/quail/docs/contributing)
> for how to propose and submit changes.

### QUAIL-B README

> [!quote]- `fsdatalab/quail-bench` README, verbatim - the benchmark, now 31 queries. Note the candid accuracy disclaimer and the scale-factor table.
> # QUAIL-B
>
> QUAIL-B is a benchmark for AI functions in SQL, or AI-SQL. It is actively being
> developed. **Currently we only support AI-powered filters and joins in the
> benchmark; we will expand to AI-powered classify, extract, map, and groupby.**
>
> For example, query IMDB-4 finds the movie aspects that each review discusses,
> for reviews that praise the movie and discuss its ending:
>
> ```sql
> SELECT r.id AS r, a.id AS a
> FROM reviews AS r
> JOIN aspects AS a
>   ON AI.IF(('Does this review discuss this movie aspect? Review: ', r.body,
>             ' Aspect: ', a.aspect))
> WHERE AI.IF(('This review mentions a positive aspect of the movie: ', r.body))
>   AND AI.IF(('This review discusses the ending of the movie: ', r.body));
> ```
>
> The query is written with BigQuery's
> [`AI.IF`](https://cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-ai-if)
> function, and its prompts are shortened. QUAIL-B publishes each query as a
> Substrait plan with the exact prompt text.
>
> The benchmark contains 31 such queries over five document collections: movie
> reviews, adverse drug reaction reports, claims and evidence for fact
> verification, legal citations, and software agent trajectories. Each collection
> comes at three scale factors, with reference answers for every filter and join.
>
> To benchmark your engine, you write an adapter: a Python function that receives
> one query and its input tables, runs the query on your engine, and returns the
> result rows. QUAIL-B
>
> - supplies each query as a [Substrait](https://substrait.io/) plan, with its
>   prompts and [PyArrow](https://arrow.apache.org/docs/python/) input tables,
> - validates your results and scores them against the reference answers, and
> - writes a report of runtime, accuracy, and, if your adapter records them,
>   token and KV metrics.
>
> ## Contents
>
> - [Getting started](#getting-started)
> - [Running the benchmark](#running-the-benchmark)
> - [Queries](#queries)
> - [Scale factors](#scale-factors)
> - [Metrics](#metrics)
> - [Results](#results)
> - [Development](#development)
>
> The [reference](docs/reference.md) specifies the full adapter contract,
> including the optional predicate answers and token data, and the exact rules
> for each metric.
>
> ## Getting started
>
> QUAIL-B requires Python 3.12:
>
> ```sh
> uv add "quail-b @ git+https://github.com/fsdatalab/quail-bench.git"
> ```
>
> Write an adapter and run IMDB-4 at the smallest scale factor:
>
> ```python
> import pyarrow as pa
> import quail_b
>
>
> def run_query(query: quail_b.QuerySpec, tables: dict[str, pa.Table]):
>     # query.plan is the Substrait plan; tables maps table names to data
>     rows, runtime_s = my_engine.execute(query.plan, tables)
>     return quail_b.RunOutput(
>         filter_answers=None,  # optional: the answer for each document
>         join_answers=None,    # optional: the answer for each pair
>         rows=rows,
>         runtime_s=runtime_s,
>     )
>
>
> quail_b.run(
>     run_query,
>     queries=["IMDB-4"],
>     scale_factor=0.1,
>     output_dir="results/imdb_4",
>     metadata={"engine": "my_engine", "model": "Qwen/Qwen3-4B-FP8"},
> )
> ```
>
> `my_engine.execute` represents a call to your own engine code, which you
> write. Typically it translates the Substrait plan into your engine's AI SQL
> dialect, such as
> [BigQuery AI SQL](https://cloud.google.com/bigquery/docs/generative-ai-overview),
> and runs it. It returns the result rows and the query execution time, measured
> once all model and GPU work has finished. Engine startup and model loading
> stay outside the timer.
>
> `tables` is keyed by the physical table names in the plan, such as `reviews`
> and `aspects`. `rows` holds document IDs, with one column for each alias in the
> `SELECT` list. IMDB-4 selects `r.id` and `a.id`, so its rows look like:
>
> ```python
> pa.table({"r": ["rv17", "rv17", "rv42"], "a": ["as0", "as6", "as6"]})
> ```
>
> When the run finishes, `results/imdb_4/report.md` lists the query's runtime and
> the precision and recall of its rows against the reference result.
>
> ## Running the benchmark
>
> A full call to `quail_b.run` looks like:
>
> ```python
> quail_b.run(
>     run_query,
>     queries=None,                        # None runs all 31 queries
>     scale_factor=0.1,                    # 0.1, 0.5, or 1.0
>     output_dir="results/vllm_qwen3_4b",  # must be a new directory
>     metadata={"engine": "vllm", "model": "Qwen/Qwen3-4B-FP8"},
>     gpu_count=1,
>     gpu_hourly_rate_usd=3.9492,
> )
> ```
>
> QUAIL-B calls `run_query` once per query, in the order given. After each query
> it saves the output, scores it, and updates `run.json`. At the end it writes
> `report.md` and `measurements.parquet`, and returns the run record.
>
> | Parameter | Default | Meaning |
> | --- | --- | --- |
> | `run_query` | required | Your adapter |
> | `queries` | `None` | Query IDs to run; `None` runs all 31 |
> | `scale_factor` | `0.1` | Published scale factor: `0.1`, `0.5`, or `1.0` |
> | `output_dir` | required | New directory for this run's results |
> | `metadata` | `None` | JSON object saved with the run: engine, model, settings |
> | `gpu_count` | `1` | GPUs used by each query, for cost |
> | `gpu_hourly_rate_usd` | `None` | Price per GPU hour; `None` leaves cost unreported |
> | `collection_id` | `None` | Reference collection; `None` uses the published one |
> | `cache_dir` | `None` | Download cache; `None` uses `~/.cache/quail-b` |
> | `data_dir` | `None` | Local input Parquet files, used in place of the download |
> | `root` | `None` | Local mirror of the published data, for offline runs |
>
> Record everything that affects performance in `metadata`: engine version,
> model, batch sizes, cache settings, and warmup. The report shows only QUAIL-B's
> measurements, so `metadata` is how you tell two runs apart later.
>
> ### Data and caching
>
> The first run downloads the input tables and reference answers for the selected
> queries from the public `s3://quail-bench` bucket. Later runs read them from
> `~/.cache/quail-b`. Set `QUAIL_B_CACHE_DIR` or pass `cache_dir` to use another
> location. QUAIL-B checks every loaded table against the published corpus
> identity, so local files that differ from the published data fail the run.
>
> Each reference answer takes about 25 bytes in memory. Loading every answer at
> scale factor 0.1, 1.21 million answers, takes about 2 seconds from the cache
> and peaks at 0.62 GiB, input tables included. At scale factor 1.0, 51.8 million
> answers, budget about 3 GiB.
>
> ### Inspecting queries and tables
>
> You can load any query or table directly while writing an adapter:
>
> ```python
> query = quail_b.get_query("IMDB-4")
> print(query.description)  # F1 -> F4 -> J1, 2 filters then 1 join
> plan = query.plan         # a substrait.plan_pb2.Plan
>
> reviews = quail_b.load_table("reviews", scale_factor=0.1)
> print(reviews.num_rows)   # 5000
> ```
>
> ## Queries
>
> The queries use two AI functions, declared as Substrait extensions in
> [`quail_b/substrait_extensions.yaml`](quail_b/substrait_extensions.yaml):
>
> ```text
> ai_filter(prompt, document) -> boolean
> ai_join(prompt, left_document, right_document) -> boolean
> ```
>
> The plans combine them with scans, equality conditions, conjunction, and
> projection.
>
> | Dataset | Queries | Tables | Task |
> | --- | --- | --- | --- |
> | IMDB | IMDB-1 to IMDB-10 | `reviews`, `aspects` | Review aspects and sentiment |
> | BioDEX | BIO-1 to BIO-4 | `reports`, `terms` | Adverse drug reactions |
> | FEVER | FEV-1 to FEV-10 | `claims`, `evidence` | Fact verification |
> | LePaRD | LEP-1 to LEP-5 | `citation_contexts`, `citation_passages` | Legal citations |
> | SWE-Next | AGENT-1 to AGENT-2 | `agent_traces` | Software agent trajectories |
>
> Within each dataset, the first queries have a single filter or join. Later
> queries chain filters, filter both join inputs, scan one table under two
> aliases, and chain three joins. The plans are stored as Substrait
> ProtoJSON in [`quail_b/plans/`](quail_b/plans/), with their order and
> descriptions in [`catalog.json`](quail_b/plans/catalog.json).
>
> ### Example: IMDB-4
>
> IMDB-4, the query at the top of this page, has this operator tree:
>
> ```text
> Project [r.id, a.id]
> └── AI Join J1                   join-1
>     ├── AI Selection F4          filter-2
>     │   └── AI Selection F1      filter-1
>     │       └── Scan reviews AS r
>     └── Scan aspects AS a
> ```
>
> `F1`, `F4`, and `J1` name the three prompts in the SQL above: positive aspect,
> ending, and review discusses aspect. The plan stores them as string literals.
> `filter-1`, `filter-2`, and `join-1` are operator IDs. The prompt text
> comes from [`quail_b/prompts.py`](quail_b/prompts.py) and
> [`quail_b/rendering.py`](quail_b/rendering.py). Every prompt starts with a
> document, followed by a question that begins "Evaluate TRUE or FALSE for the
> following question:", so an engine can reuse a document's KV across questions.
>
> ### Developing an adapter
>
> The 31 queries have several different shapes: how many filters and joins they
> have, and how those operators are arranged in the plan. The table below lists
> one query for each distinct shape, from simplest to most complex. Test your
> adapter on these queries first, then run it on all 31.
>
> | Query | Shape | What it tests |
> | --- | --- | --- |
> | IMDB-1 | One filter | Scans, prompt rendering, and result IDs |
> | IMDB-2 | One join | Pair evaluation and two output columns |
> | IMDB-4 | Two filters, then one join | Operator order |
> | FEV-5 | Filters on both join inputs | Filters on each side of a join |
> | IMDB-8 | Two joins sharing one input | Two aliases of one table |
> | FEV-8 | Chain of three joins | Multiple joins |
> | FEV-10 | Filtered join with equality | Equality and AI conditions together |
> | BIO-4 | Three filters, two joins | Filters on two aliases of one table |
>
> ## Scale factors
>
> Scale factors 0.1, 0.5, and 1.0 sample 10%, 50%, and 100% of each dataset's
> target size. Each corpus is sampled with a fixed seed from pinned upstream
> revisions, listed in [`quail_b/data.py`](quail_b/data.py). The queries are the
> same at every scale factor. Use 0.1 while developing an adapter.
>
> | Dataset | Table | 0.1 | 0.5 | 1.0 |
> | --- | --- | ---: | ---: | ---: |
> | IMDB | `reviews` | 5,000 | 25,000 | 50,000 |
> | IMDB | `aspects` | 12 | 12 | 12 |
> | BioDEX | `reports` | 500 | 2,500 | 5,000 |
> | BioDEX | `terms` | 1,127 | 2,934 | 4,144 |
> | FEVER | `claims` | 500 | 2,500 | 5,000 |
> | FEVER | `evidence` | 287 | 1,037 | 1,478 |
> | LePaRD | `citation_contexts` | 500 | 2,496 | 4,972 |
> | LePaRD | `citation_passages` | 433 | 1,756 | 2,991 |
> | SWE-Next | `agent_traces` | 1,772 | 8,859 | 17,711 |
>
> ### Reference answers
>
> QUAIL-B scores every run against reference answers: one TRUE or FALSE label
> for each document or document pair each AI predicate can be asked about.
>
> **Accuracy is not a focus of this benchmark.** Most labels are the answers of
> one arbitrary model, `Qwen/Qwen3-32B-FP8`, so it is not really meaningful to
> measure accuracy against them. We provide these fake labels anyway.
>
> Two datasets have real labels for join operations. First, the join that asks
> whether a FEVER passage supports a claim uses the claim annotations from
> [FEVER](https://huggingface.co/datasets/fever/fever) where they exist. Second,
> the LePaRD citation join uses the citation links from
> [LePaRD](https://huggingface.co/datasets/rmahari/LePaRD).
>
> The input tables and labels live in the public S3 bucket `s3://quail-bench`,
> under `ground_truth/quailb/schema_v1/`:
>
> | Path | Contents |
> | --- | --- |
> | `corpora/<corpus_id>/` | Input tables of one scale factor, as Parquet |
> | `label_sets/<dataset>/<predicate>/<label_set_id>/` | Labels of one predicate |
> | `collections/<collection_id>/` | Which label set each predicate uses |
>
> The IDs are content hashes. A corpus ID names the exact input tables, and a
> collection ID names one complete set of labels for that corpus, so any change
> to the data or labels produces new IDs. These are the published IDs:
>
> | Scale factor | Corpus ID | Collection ID |
> | --- | --- | --- |
> | 0.1 | `c_1aa2c4f0d0b6c816fd37aa5748c33341` | `gt_cd3ebdb784f64b9e028e50ea73cdedd0` |
> | 0.5 | `c_6773c85b3754908434661c1dadfad0fa` | `gt_68f9ce9439bd7615de92b33d576dff9e` |
> | 1.0 | `c_81a95887a650aaa1a343e0d688b81bef` | `gt_e87691add604b02c4e43f0ff5bf0cc4f` |
>
> `quail_b.run` loads the matching collection for you and records both IDs in
> `run.json`. Compare results only across runs with the same IDs.
>
> To look at the labels or score answers yourself, load them with the query's
> input tables:
>
> ```python
> from quail_b.scoring import agreement, expected_rows
>
> benchmark = quail_b.load_benchmark(["IMDB-4"], scale_factor=0.1)
> labels = benchmark.ground_truth           # the collection for these queries
> query = benchmark.queries[0]
>
> expected = expected_rows(query, labels, benchmark.tables)  # reference result
> for key, predicate in labels.predicates.items():
>     print(key, predicate.table.num_rows)  # left_id, right_id, answer
>
> # compare your answers for F4 (filter-2) with its labels
> ending = labels.predicates["quailb.imdb.review.discusses_ending"]
> counts = agreement(your_filter_table, ["r"], ending)
> print(counts.correct, counts.evaluated)
> ```
>
> ## Metrics
>
> Every run reports query time and output quality. The other metrics appear when
> the adapter returns the data they need; the
> [reference](docs/reference.md#metric-requirements) lists what each one
> requires. A metric that lacks its data shows as `unavailable`; QUAIL-B never
> reports it as zero.
>
> | Metric | Definition |
> | --- | --- |
> | Query time | `runtime_s`, in seconds |
> | Output precision and recall | Returned rows compared with the reference result |
> | Predicate-level accuracy | Share of filter and join answers that match the labels |
> | Document throughput | Input documents per second, for queries with zero joins |
> | Join throughput | Evaluated document pairs per second |
> | GPU cost | `runtime_s / 3600 * gpu_count * gpu_hourly_rate_usd` |
> | Input tokens | Full length of every evaluated prompt, including KV hits |
> | Fresh tokens | Positions processed by model forward passes |
> | Minimum tokens | Positions needed with an unlimited prefix KV cache |
> | KV regret | Fresh tokens above the minimum, as a percentage of fresh tokens |
> | Input token throughput | Input tokens per second |
> | Cost per million input tokens | GPU cost divided by input tokens, times one million |
>
> ## Results
>
> Each run writes to its `output_dir`:
>
> ```text
> results/vllm_qwen3_4b/
> ├── report.md             # summary table of every metric
> ├── run.json              # configuration, data IDs, status, and metrics
> ├── measurements.parquet  # one row of metrics per query
> └── IMDB-4/
>     ├── plan.substrait    # the exact plan that ran
>     ├── rows.parquet      # the result rows
>     ├── filters-0.parquet # optional filter answers
>     ├── joins-0.parquet   # optional join answers
>     └── prompt_pieces.json
> ```
>
> The run stops at the first adapter or scoring error and records it in
> `run.json`. Outputs are saved before scoring, so you can rescore a run from its
> saved files:
>
> ```sh
> quail-b report results/vllm_qwen3_4b
> ```
>
> ## Development
>
> To work on QUAIL-B itself:
>
> ```sh
> git clone https://github.com/fsdatalab/quail-bench.git
> cd quail-bench
> uv sync
> uv run pytest -q
> ```

### Playground

*The live playground at `fsdatalab--quail-playground-page.modal.run`, landing state on the default Agent trace compaction tab. Three tabs: Agent trace compaction (running `diffusion-gemma-26b-a4b-fp8: ready on one H100`, POSTing to `fsdatalab--quail-playground-gemmaserver0-web.modal.run/v1/queries`), IMDB and BIO. The default query joins `conversations` to `tool_questions` on `AI.IF(PROMPT('Using the compaction state in DOCUMENT {0}, evaluate whether the retention statement in DOCUMENT {1} is true.', c.state, q.statement))` over agent traces from the NVIDIA SWE-Zero OpenHands trajectories dataset: 100 traces with 3,577 tool calls, each call scored keep / truncate to 300 chars / drop, with the last 3 calls of each trace pinned. The counter reads 1.89M to 1.89M tool output tokens, 0% removed, before a run. Queries run live on Modal H100s and results are downloadable; an unlimited query is capped at LIMIT 1000.*

![[sh_reya-688056-playground.png]]
