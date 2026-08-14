---
created: 2026-08-14
description: Index of Hamel Husain's AI Product Engineering series — 13 session summaries organized by theme (Evals, Context, Systems), his improvement ladder (evals → retrieval/context → systems/harness → post-training last), with wiki-links to the 11 sessions captured as vault notes and one-liners for the two indexed-only.
source: https://hamel.dev/notes/llm/ai-product-engineering/
author: Hamel Husain
type: reference
tags: [index, ai-product-engineering, evals, context-engineering, systems, hamel, learning-resources]
---

# Hamel's AI Product Engineering series

Hamel Husain hosted 13 sessions on AI product engineering and condensed them into short notes ("9.5 hours of sessions comes out to about 20 minutes of reading"). His framing is an **improvement ladder**: evals set the foundation → the lowest-hanging fruit is retrieval and context → then improve systems and harness → consider post-training your own model only after other approaches are exhausted.

Eleven sessions are captured as full vault notes (linked below); two are indexed here only.

## Evals

- [[Hamel's evals-for-data-agents note reads DAB for builders - agents fail on plans not data selection and stick to plans even when data contradicts them]] — Shreya Shankar on the Data Agent Benchmark; plan-rigidity as the headline failure mode → *Agents/Data Agent*
- [[BARGAIN routes classification to a small model via a confidence threshold calibrated on 500 oracle labels, cutting costs up to 86 percent more than competing cascades]] — Shreya Shankar on measured model cascades; Task Cascades cuts a further 48.5% → *Evaluation and Monitoring*
- [[the Error Discovery skill builds a failure-mode taxonomy while you annotate, using active learning to pick the next traces]] — Shreya Shankar; error analysis before rubrics, with the bookkeeping automated → *Evaluation and Monitoring*
- [[Nova Escola's lesson-planner evals worked only after error analysis rewrote the rubric - annotators agreed worse than chance until experts defined good]] — Lucas Machado Rocha's production case study; daily evals on 2% of traffic → *Evaluation and Monitoring*

## Context

- [[SMVE makes billion-doc multivector retrieval practical - sparse random projections gate exact MaxSim to survivors at p99 under 100ms]] — Marek Galovic; MaxSim ~2,000x dot-product cost tamed; Iso-ModernColBERT → *ML Research/Embeddings*
- [[BrowseComp-Plus isolates the search-agent ceiling - GPT-4.1 scores 14.6 percent finding documents with BM25 vs 93.5 percent when handed them]] — Nandan Thakur; ORBIT synthetic evals + Hawkeye trajectory analytics; the retriever is the ceiling → *Agents/Search/Agentic Search*
- [[embedding model selection is a cost-quality tradeoff MTEB cannot see - and fine-tuning the embedder is the overlooked high-impact lever]] — Radu Gheorghe; quantization/precision/Matryoshka tradeoffs; VespaEmbed no-code fine-tuning → *ML Research/Embeddings*
- [[choosing an OCR model is a 2x2 of structure and hosting with seven PDF failure modes - and only 5 percent of teams should self-host]] — Joe Barrow; the price ladder ($0.60/1k → $20/1k), seven PDF failure modes, license chains → *ML Research/Inference*
- [[Subtext attaches per-sentence metadata to prose so agent rewrites cannot lose the decisions embedded in investment memos]] — Bryan Bischof & Adam Conway (Theory Ventures); "footnotes for agents" → *Agents/Harness Engineering*

## Systems

- **Debugging Inference Latency** (Abi Aryan) — *indexed only*: prefill is parallel and ~an order of magnitude faster per token than sequential decode; profile your request shape (long-in/short-out is prefill-dominated and friendly, short-in/long-out is decode-bound and worst); if output dominates, cut response length first, then speculative decoding. The vault's [[Step 01 - Decode is memory-bandwidth-bound (the roofline)|Inference-from-First-Principles course]] covers this ground in depth. [Talk](https://youtu.be/CKamabikBNs)
- **Open Weight Model Economics** (Zach Mueller) — *indexed only*: the durable bit is the memory rule **Weights (GB) = Params (B) × N × 0.5** (N = 1/2/4/8 for 4/8/16/32-bit; a 27B at 4-bit ≈ 13.5GB fits a 16GB card); plus warnings against third-party routers (privacy, mid-session provider switches invalidating caches) and preferring one top-tier node over multi-node H100 clusters. Model recommendations age fast — see [[camelAI self-hosts DeepSeek V4 Flash on 4x RTX PRO 6000 Blackwell for a fixed-cost free tier, with KV cache as the real bottleneck|camelAI's self-host case study]] for current practice. [EleutherAI transformer-math](https://blog.eleuther.ai/transformer-math/)
- [[don't build agents, build environments - Ramp bakes machine images every 30 minutes so agents go from cold to working in under a second]] — Adam Azzam (Modal); CI/CD is the wrong substrate; separate agents from tools → *Agents/Harness Engineering*
- [[Prime Intellect's fine-tune-last doctrine - 5x task timeouts lifted Terminal-Bench 14.7 points with no model change]] — Will Brown & Florian Brand; the eval-infra footgun list and the two-condition post-training gate → *Evaluation and Monitoring*

## External Resources

- [The series index](https://hamel.dev/notes/llm/ai-product-engineering/) · [Hamel's evals writing](https://hamel.dev/notes/llm/evals/) · the series ran as a [Maven course](https://maven.com/lls/21f487)
