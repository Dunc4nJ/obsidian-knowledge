---
created: 2026-06-28
description: Map of Content for ML inference — model serving engines, runtime optimization, KV cache, speculative decoding, quantization, and serving economics.
type: moc
---

# Inference

Model serving and runtime: the engines, optimizations, and economics of running trained models in production. (Formerly `Infrastructure and Serving/`.) Taxonomy lives in each note's `topic:` frontmatter; promote these clusters to sub-folders if the folder grows past ~15–20 notes.

**Start here:** [[Joe Barrow reviews Philip Kiely's Inference Engineering as the reference work he wishes he had in 2023, with a curated what-to-read-next list]] — the orientation note: engine selection, quantization, speculative decoding, disaggregation, and a curated reading path into the rest of the folder.

## Serving engines & runtimes

- [[Amit Shekhar explains how vLLM packs more LLM users onto one GPU through PagedAttention and continuous batching]] — vLLM fundamentals: PagedAttention KV paging, prefix/beam sharing, continuous batching, OpenAI-compatible serving
- [[Philip Kiely details how Baseten built the world's fastest GLM-5.2 API by stacking NVFP4 quantization, KV-aware routing, prefill-decode disaggregation, and MTP speculation]] — production case study stacking four serving optimizations for SOTA TPS/TTFT
- [[Joe Barrow reviews Philip Kiely's Inference Engineering as the reference work he wishes he had in 2023, with a curated what-to-read-next list]] — review of the *Inference Engineering* reference + what-to-read-next list

## Speculative decoding

- [[Modal argues speculative decoding is the only inference optimization that matters, and custom DFlash speculators turn acceptance length into 2-3x speedups]] — acceptance length, DFlash speculators, roofline modeling, SGLang/vLLM speedups
- [[Rachel Rapp explains how Baseten trains speculative-decoding draft models live from inference hidden states, raising accept rates 20%+ with no offline data storage]] — Baseten's Speculation Engine: draft models trained live from serving hidden states

## KV cache

- [[paged attention applies OS virtual memory paging to KV cache and unlocks 2-4x LLM serving throughput]] — PagedAttention: OS-style virtual-memory paging of the KV cache; the canonical serving-throughput result
- [[Ramp Labs Latent Briefing compacts KV caches for efficient cross-agent memory sharing]] — KV-cache compaction technique (Attention Matching, NNLS/ridge solves, batched CUDA kernels, prefix caching, GPU↔CPU offload)

## Serving economics & throughput

- [[vLLM throughput benchmarking on H100 — tensor-parallel sizing, speculative decoding, and FP8 KV-cache economics]] — two-tier parameter sweep across 18 models; when `tp` vs speculative decoding pays off; the $/H100-hour math
- [[HuggingFace OCRed 30K arXiv papers with Chandra-OCR 2 on parallel L40S GPU jobs for 850 dollars]] — batch-inference economics: vLLM on L40S vs A10G, papers/hr, $850 vs $1,841 API

## Related / cross-linked elsewhere

Notes whose primary subject lives in another folder but that carry a heavy inference theme — kept in place, surfaced here for the inference lens:

- [[prompt design is the single biggest lever for synthetic pretraining data]] — synthetic-data study (ML Research); parent of the H100 throughput note above
- [[LLM optimization interview prep maps Flash Attention, ZeRO, speculative decoding, and MoE across training and inference]] — interview guide; substantial inference-optimization half (Learning Resources)
- [[Xiuyu Li's 35 RL interview questions span Actor-Critic, PPO/GRPO variants, MoE infrastructure, and async rollout frameworks]] — RL interview set; infra half probes serving (KV transfer, batching, vLLM/SGLang, INT8/FP8)
- [[technmak's AI-ML Engineer Interview Guide for 2026 Part 1 spans classical ML, multimodal systems, and preference optimization across six domains]] — broad ML guide; light inference coverage
- [[Cursor Composer 2]] — training report with heavy inference secondary (MTP speculative decoding, NVFP4 quant for fast inference, serving Pareto)
- [[twenty-six papers capture ninety percent of the alpha behind modern LLMs from attention through reasoning and mixture of experts]] — LLM-fundamentals reading list; FlashAttention + MoE-for-inference-cost threads
- [[autoresearch loops cheat when guardrails are loose but converge on real findings when tightly scoped]] — autoresearch methodology; one track is REAP expert pruning + INT4 (717GB→92GB) for consumer-GPU MoE inference
- [[autoresearch agents exploit unconstrained metrics and need multi-objective gates with regular human steering]] — companion; MoE expert paging/routing + throughput/VRAM gates
- [[agent swarms topped OpenAI parameter golf by combining human steering with autonomous sweeps]] — weight quantization (int4-6, GPTQ-lite, QAT) for artifact size, not serving latency
- [[Hornet tunes 100M-doc ANN search and finds instruction prefixes, graph connectivity, and quantization ceilings interact in ways benchmarks miss]] — embedding-index serving at scale (binary-quant recall ceilings, HNSW)
- [[agents are the perfect slow searchers because LLM inference cost dominates per-query retrieval latency]] — LLM-inference-cost argument applied to agentic search
- [[auto-caching with Claude eliminates manual breakpoint management for multi-turn agents]] — prompt/KV prefix-cache mechanics (prefill/decode, cached-token pricing) framed as a harness feature
- [[Context-1 proves agentic search can be 20B-scale and retrieval-dominant without frontier models]] — MXFP4 quantization-aware distillation + vLLM serving a 20B MoE on B200
- [[Open models now match closed frontier models on core agent harness tasks at a fraction of the cost]] — model-serving cost/latency/throughput economics across providers (Baseten/Groq/Fireworks)
