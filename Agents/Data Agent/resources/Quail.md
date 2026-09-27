---
created: 2026-09-27
source: https://github.com/fsdatalab/quail
type: resource
tags: [data-agents, ai-sql, semantic-operators, inference-engine, kv-cache, prefill, vllm, modal, quail, triton, flash-attention, arrow, substrait]
status: exploring
---

## What it is

Quail (QUery-Aware Inference Layer) is an MIT-licensed, extensible execution engine for AI-SQL, built at CMU's [Full Stack Data Lab](https://fsdatalab.github.io/) in collaboration with Modal. It takes Arrow tables and a SQL query containing LLM-backed predicates — Snowflake's `AI_FILTER`, BigQuery's `AI.IF`, or a pandas-like Python builder — plans the relational operators and the GPU forward passes as one problem, and executes the whole query on local GPUs with an open-weight model.

Python, requires Python 3.12 and a CUDA GPU, published to PyPI as `quail-engine` (imported as `quail`). 95 stars, created 1 August 2026. Paired with the knowledge note [[Quail jointly plans AI-SQL queries and LLM inference - 1.84x over tuned vLLM on 29 queries and 1.14 billion tokens a minute on one H100, but 2.32x slower on agent traces]] and the benchmark repo `fsdatalab/quail-bench`.

```bash
uv pip install quail-engine
```

```python
import pyarrow as pa
import quail

reviews = pa.table({"id": ["r1", "r2", "r3"], "body": [...]})
config = quail.EngineConfig(model="qwen3-4b-fp8", device="h100-sxm")
with quail.Session(config=config) as session:
    session.register("reviews", quail.DocumentProvider.from_table(reviews, id_col="id"))
    result = session.sql("""
        SELECT r.id FROM reviews r
        WHERE AI.IF(PROMPT('Does this review mention a positive aspect of the movie?\n\n{0}', r.body))
    """, dialect="bq").collect()
```

## Why it's interesting

It is the only engine in the vault that treats the query plan and the inference schedule as a single optimization target, and it publishes the case where that loses. Every other AI-SQL system in this lineage (DocETL, LOTUS, Palimpzest, ThalamusDB, and the vendor AI functions) attacks cost by *eliminating* model calls; Quail assumes the calls are already minimal and attacks the execution of the surviving millions, on the grounds that AI-SQL is a degenerate inference workload — pure prefill, one constrained output token, nearly every request known before execution starts, and no per-request latency requirement.

The second draw is that the repo answers questions the blog post leaves at the prose level. The post says eviction prefers "the shortest documents"; the code shows a reuse-probability-weighted recompute-cost score. The post says the planner reserves room for "two forward passes"; `retention_pages()` is that sentence as arithmetic. And `demos/civil_comments/` contains a `jev_backend.py` sitting next to `quail_backend.py` over the same 10,000 rows, which is the head-to-head against [[pg-jev]] and [[TypeSafe's Jev trades string generation for parallel-sampled typed decisions with calibrated probabilities at $0.042 per MTok - the 193x and 444x claims come from four self-built workflow evals|hosted Jev]] that nobody has published numbers for yet.

## How it works

Three stated performance goals, verbatim from the post:

> 1. Minimize KV regret.
> 2. Keep the GPU busy by reducing CPU scheduling overhead.
> 3. Reach high model FLOP/s utilization (MFU) while the GPU is active.

Goals 1 and 2 are what the current evaluation measures; MFU is deferred. The design is DataFusion-shaped — a frontend, a planner and an execution engine, each extensible with new operators, planning rules, backends, models or hardware.

**Frontend** (`quail/frontend/`, `quail/logical/`). SQLGlot parses the `bq` or `snowflake` dialect; AI predicates arrive as anonymous expressions and are lowered by the planner. Users may attach optional planning hints per operator: a `selectivity` (the expected pass fraction; without it predicates stay in written order) and, for a join, an `anchor` (which side goes first in the prompt; without it the planner picks). Data registers as an in-memory Arrow table or an Arrow dataset through `DocumentProvider`.

**Planner** (`quail/planner/`, `quail/cost/`). Four phases: estimate dataset statistics (row count, mean and max document length); compute the forward-pass token budget and fixed KV capacity from the model and GPU specs in `quail/specs/`; run SQL rewrites (projection and filter pushdown, filter ordering by cost × selectivity per Hellerstein and Stonebraker, Selinger/System R search for join order *and* anchor); then run inference-specific rewrites that lower the logical plan into a DAG of physical operators (`AiFilter`, `AiJoin`, `HashJoin`, `Barrier`, `Exchange`, `Recombine`, `Project`, `Limit`) each carrying its prompt, model, token budget and KV settings. Modal's post adds the detail that the join search keeps a **Pareto frontier** over (tokens, attention pairs, cached tokens) and eliminates a candidate only when it is dominated on all three, because a locally worse join may hold KV a later join wants; the speed-of-light estimate then breaks the tie.

**Cost model** (`quail/cost/sol.py`, `roofline.py`, `work.py`, `dense_decoder_cost.py`). The workload code counts tokens, attention pairs and KV movement; `dense_decoder_components` turns those counts into named model components; `roofline.py` prices each component independently as `max(flops / device.arithmetic_bandwidth(precision), bytes_moved / device.hbm_bw)` and reports whether it is compute- or memory-bound; `speed_of_light()` sums the component times in execution order with `passes = ceil(tokens / chunk_tokens)`. The result carries an `explain()` breakdown (tokens, pairs, KV written, KV read, forward passes, bytes moved, per-component compute and memory seconds, and the final bound). This is the "speed of light" the blog compares everything against — 894.37 s for BIO-4 at scale factor 1.0 — and it is deliberately optimistic: 100% MFU, full CPU/GPU overlap, unlimited KV. Notably `quail/planner/prefixes.py` computes `shared_prefix_lengths` across documents, so the *bound* credits cross-row prefix sharing that the engine does not yet implement, which is why the AGENT queries look so far off it.

**KV manager** (`quail/backends/quail/retention.py`, `quail/cost/retention.py`, `quail/planner/retention.py`, `executor/arena.py`). Each GPU holds a fixed pool of KV pages in an arena. The engine puts the document *before* the predicate question, so after a predicate answers TRUE or FALSE it discards the predicate's KV and **"rewinds" to the end of the document KV** — retaining only the prefix a later operator can reuse, never the full prompt. A rewound prefix stays pinned if the row survived and another AI operator needs it; otherwise it is freed immediately. Joins retain their anchor the same way through `retain_after_join()`.

Eviction is neither LRU nor, despite the prose, literally shortest-first. `RetentionPolicy.priority` scores each retained prefix as

```python
seconds = (linear_seconds * tokens
           + pair_seconds * triangle(tokens)
           + sliding_pair_seconds * triangle(tokens, sliding_window))
return (probability * seconds / pages, -next_use, -document)
```

— the expected recompute cost per page, where `triangle(tokens)` is attention's quadratic term (this is what makes long documents expensive to lose) and `probability`/`next_use` come from `planner/retention.py`, which walks the join groups and records at every execution boundary the index of each alias's next use and the fraction of its rows expected to survive until then. `retention_pages()` fixes the cap by reserving two execution chunks up front: `arena_tokens // page_tokens - ceil(2 * chunk_tokens / page_tokens)`.

**Executor** (`quail/execution/`, `quail/backends/quail/`). Pull-based like Volcano but batch-at-a-time like MonetDB, streaming intermediate results directly between operators rather than materializing them — a batch of documents that passes a filter pipelines straight into the next join with its KV already resident. Tokenization happens once up front with [Gigatoken](https://github.com/marcelroed/gigatoken) into memory-mapped Arrow files, and one model copy is loaded per GPU. The CPU prepares the next batch while the GPU processes the current one. Multi-GPU support is deliberately basic: one full model copy and one KV pool per GPU, filter documents and join anchors partitioned randomly and uniformly, results combined on the CPU. 1, 2, 4 or 8 GPUs per query.

**Inference program** (`quail/backends/quail/executor/attention.py`, `model.py`, `moe.py`, `pack.py`, `score.py`, `readout.py`). Quail borrows vLLM's model implementations for the forward pass and runs them under its own scheduler and KV manager, with three changes:

1. **Fused Triton kernels** — add-RMSNorm with FP8 quantization, per-head Q/K RMSNorm with RoPE, activation with FP8 quantization — cutting kernel launches and intermediate HBM traffic. Matmuls are DeepGEMM, attention is FlashAttention 3 (FlashAttention 4 for head dims above 256).

2. **Join attention as a depth-one tree.** `attention.py` declares two paths: `FILTER_ATTENTION = "unified"` (one causal paged attention call after scattering current KV into the arena) and `JOIN_ATTENTION = "merge_quant"` (two calls merged by a fused kernel). In the join path, partners sharing an anchor are grouped so the anchor KV is computed and read **once** instead of once per pair. One FlashAttention 3 call computes causal attention within each partner suffix; a second applies all partner queries to the shared anchor KV; the two are combined exactly using their log-sum-exp values and the online-softmax formula, and one Triton kernel does the merge plus FP8 conversion for the output projection. The lineage is SpecInfer and Hydragen (and FlashInfer's cascade attention), applied during prefill rather than decode. Modal notes the simplification that makes it cheap: suffix KV is never written to cache, because there is no decode and no join deeper than two-way.

3. **An 8-row output head.** Only TRUE/FALSE scores are needed, so the final hidden state is multiplied by only the corresponding rows of the LM head. Eight rather than two because Qwen spells each answer four ways — `TRUE` (20611), `␠TRUE` (8214), `True` (2514), `␠True` (3007), `FALSE` (30351), `␠FALSE` (7833), `False` (4049), `␠False` (3557).

**Server** (`quail/server/`). An optional HTTP server (`uv pip install "quail-engine[server]"`, then `quail-server`) that runs on the GPU machine; clients pass `endpoint=` to `quail.Session`, `submit()` returns once the run record is saved, and the query keeps running after the client disconnects, with `run.watch()` and `get_run` for status and results. `checkpoint.py` mirrors the live SQLite store to a Modal Volume after each state change because Volumes have no file locking and only publish on `commit()`. Worth noting for the failure-cost objection raised in the thread: this is **run-level** durability, not operator-level — there is no cache of completed operator outputs keyed by row, so a crash mid-query re-runs the query.

## Supported surface

| | |
| --- | --- |
| Operators | AI filters, AI joins, `EXISTS` / `NOT EXISTS`, relational projection and `LIMIT`. `AI.CLASSIFY`, `AI.EXTRACT` and `AI.MAP` are in progress |
| Dialects | Snowflake `AI_FILTER`, BigQuery `AI.IF`, plus a Python builder API |
| Qwen3 4B fp8 | NVIDIA H100 SXM |
| Qwen3 32B fp8 | NVIDIA RTX PRO 6000 Blackwell Server Edition |
| DiffusionGemma 26B-A4B fp8 | NVIDIA H100 SXM |
| GPUs per query | 1, 2, 4 or 8 |

## Repository layout

`quail/` splits into `frontend/` (SQLGlot parsing, Python builder), `logical/` and `physical/` (plan nodes), `planner/` (`decide.py` is the 946-line entry point; `joins.py`, `leftdeep.py`, `prefixes.py`, `retention.py`, `live_rows.py`, `logical_rules.py`, `physical_optimizer.py`), `cost/` (the roofline and SoL model plus `budgets.py` and `retention.py`), `execution/` (session, runner, pairs, tokens, reranker), `backends/` (`quail/` is the custom engine with its `executor/`, `graph.py`, `retention.py`, `worker.py`, `coordinator.py`, `distributed.py`; `vllm.py` and `sglang.py` are comparison backends), `specs/` (per-model and per-device specs, including two Qwen3 reranker specs not yet mentioned in the docs), `server/`, `bench/` (the QUAIL-B adapter), and `explain.py`.

`demos/` holds `quickstart.py`, `quickstart_modal.py`, `imdb_ending_filter.py` (the blog's 100,000-review two-filter example), `plan_walkthrough.py`, `agent_trace_compaction.py` (+ a Modal variant), and `civil_comments/` with `quail_backend.py`, `jev_backend.py` and `quail_modal.py`. `experiments/` holds the profiling harnesses behind the blog's Figure 2 (`profile_vllm_join.py`, `profile_cpu_timeline.py`, `profile_gpu_timeline.py`, `analyze_blog_profiles.py`) plus SGLang equivalents. `docs/` is a Next.js site that also serves `llms.txt` and `llms-full.txt`.

## QUAIL-B

`fsdatalab/quail-bench` is the companion benchmark: **31 queries** (the blog evaluates 29) over five document collections — IMDB movie reviews, BioDEX adverse-drug-reaction reports, FEVER claims and evidence, LePaRD legal citations, and SWE-Next software-agent trajectories — each at scale factors 0.1, 0.5 and 1.0. Queries ship as Substrait plans with exact prompt text; you write an adapter that takes a `QuerySpec` and input tables and returns rows plus `runtime_s`, and the harness scores precision and recall against reference answers and writes `report.md`, `run.json` and `measurements.parquet`. Metrics include query time, predicate-level accuracy, document and join throughput, GPU cost, input tokens, fresh tokens, **minimum tokens**, **KV regret** (fresh tokens above the minimum) and cost per million input tokens; a metric without its data reports `unavailable`, never zero. Data lives in the public `s3://quail-bench` bucket, addressed by content-hash corpus and collection IDs so runs are only comparable when the IDs match.

The accuracy caveat is stated by the authors and matters for how the numbers are read: "**Accuracy is not a focus of this benchmark.** Most labels are the answers of one arbitrary model, `Qwen/Qwen3-32B-FP8`, so it is not really meaningful to measure accuracy against them. We provide these fake labels anyway." Only two joins have real labels — FEVER's claim-support join uses FEVER's own annotations, and the LePaRD citation join uses LePaRD's citation links.

## Key links

- [GitHub](https://github.com/fsdatalab/quail) · [PyPI `quail-engine`](https://pypi.org/project/quail-engine/)
- [Documentation](https://fsdatalab.github.io/quail) · [Quickstart](https://fsdatalab.github.io/quail/docs/user-guide/quickstart) · [Quail Server](https://fsdatalab.github.io/quail/docs/user-guide/server) · [physical plans](https://fsdatalab.github.io/quail/docs/architecture/physical-plans) · [Civil Comments demo](https://fsdatalab.github.io/quail/docs/demos/civil-comments) · [contributing](https://fsdatalab.github.io/quail/docs/contributing)
- [QUAIL-B benchmark](https://github.com/fsdatalab/quail-bench)
- [Launch post](https://fsdatalab.github.io/blog/introducing-quail/) (Full Stack Data Lab) · [Modal's companion post](https://modal.com/blog/quail-billion-tpm)
- [Live playground on Modal](https://fsdatalab--quail-playground-page.modal.run/)

## Notes

- The Civil Comments demo is the one published head-to-head shape against a Jev-class vendor, and the published results table has only one row: Quail on DiffusionGemma 26B-A4B fp8, one H100, 85.53 s, 284,022 tokens/s, $0.0938, filter F1 0.413, join F1 0.287 on 10,000 Jigsaw rows with no selectivity hints. `jev_backend.py` exists, batches every question for one comment into a single API request, thresholds Jev's `noul` probability at 0.5, and checkpoints so it can resume — but no Jev row is published. Running it is the obvious next experiment.
- `quail/reranker.py`, `quail/planner/reranker.py`, `quail/execution/reranker.py` and two Qwen3 reranker specs (0.6B and 4B) exist in the tree with no mention in the README, the docs index or either blog post. Something reranker-shaped is being built.
- `quail/backends/sglang.py` and the `experiments/profile_sglang_*` harnesses mean SGLang was profiled as a baseline too; only vLLM numbers were published.
- The project is explicit that most of the code was written by coding agents, and both posts treat "how do we specify and verify what agent-written systems must do" as an open research question rather than an aside.
