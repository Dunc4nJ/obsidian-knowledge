---
created: 2026-08-14
description: Hamel Husain's summary of Radu Gheorghe's session — how to choose an embedding model: start at MTEB but know it ranks quality and says nothing about cost; then work the tradeoffs (INT8 ~3x faster than FP32 on CPU; binary vectors = 32x storage cut, bfloat16 = 2x with no measurable loss; Matryoshka truncation) and always test on your own domain (multilingual and context length are the common gaps). When a model falls short, fine-tune the embedder — far easier than fine-tuning an LLM and often higher impact — via VespaEmbed, an Apache-2.0 no-code tool.
source: https://hamel.dev/notes/llm/ai-product-engineering/context-embedding-models.html
author: Hamel Husain (summarizing Radu Gheorghe's session)
type: article
tags: [embeddings, model-selection, quantization, matryoshka, fine-tuning, mteb, vespa, ai-product-engineering, hamel]
---

## Key Takeaways

- **MTEB is a starting point, not a decision — it ranks quality and says nothing about cost, and rankings shuffle on specialized domains.** The selection tradeoffs that actually decide deployments: **model quantization** (INT8 ≈3x faster than FP32 on CPU with most quality kept; FP16 on GPU), **vector precision** (FP32→binary = 32x storage cut; bfloat16 = 2x with *no measurable quality loss*), **Matryoshka truncation** (drop later dimensions, keep most quality), and **performance on your own data** — multilingual support and context length are the common leaderboard blind spots. The same benchmark-vs-your-distribution caution as [[benchmarks are measurement instruments not question collections - regulargio's first-principles guide to claims, graders, coverage, and uncertainty|benchmarking science]], and the interaction effects are exactly what [[Hornet tunes 100M-doc ANN search and finds instruction prefixes, graph connectivity, and quantization ceilings interact in ways benchmarks miss|Hornet's 100M-doc tuning]] documents at scale.

- **The overlooked lever: fine-tune the embedder.** Far easier than fine-tuning an LLM and often bigger impact — embedders are small, the training signal is pairs, and the failure mode (domain vocabulary the base model never saw) is precisely what tuning fixes. **VespaEmbed** makes it no-code: pick a base model from HF, upload pairs, choose a loss, train (Apache 2.0, hosted Space available).

## External Resources

- Original note: [Choose and Fine-Tune an Embedding Model — Hamel Husain](https://hamel.dev/notes/llm/ai-product-engineering/context-embedding-models.html) ([AI Product Engineering series](https://hamel.dev/notes/llm/ai-product-engineering/))
- [Radu Gheorghe's talk](https://maven.com/p/fef4e1) · [deck](https://notpptx.com/vespaai/choosing-finetuning-embedder) · [MTEB leaderboard](https://huggingface.co/spaces/mteb/leaderboard) · [Vespa embedding-tradeoffs-quantified post](https://blog.vespa.ai/embedding-tradeoffs-quantified/) · [VespaEmbed repo](https://github.com/vespaai-playground/vespaembed) / [HF Space](https://huggingface.co/spaces/vespa-engine/vespaembed)

## Original Content

> [!quote]- Full note — "Choose and Fine-Tune an Embedding Model" (Hamel Husain; session by Radu Gheorghe)
> _This note covers Radu Gheorghe’s session in the [AI Product Engineering series](../../../notes/llm/ai-product-engineering/index.html)._
>
> Radu Gheorghe walks through how to pick an embedding model for retrieval. He starts on the [MTEB leaderboard](https://huggingface.co/spaces/mteb/leaderboard), then warns that it ranks quality and says little about costs. He then walks through several [trade-offs](https://blog.vespa.ai/embedding-tradeoffs-quantified/) worth considering. Here are important ones:
>
> * **Model quantization** (the precision of the model weights): on a CPU, an INT8 model runs about 3x faster than FP32 while keeping most of the quality. On a GPU, use FP16 instead.
> * **Vector precision** (how you store the output vectors): going from FP32 to binary cuts storage by 32x, and bfloat16 gives you a 2x cut with no measurable quality loss.
> * **Matryoshka models** (embedders you can truncate): these models let you drop later dimensions and keep most of the quality, which saves storage and speeds up search.
> * **Performance on your data** (what the leaderboard cannot show): test on your own data, because rankings shuffle on specialized domains. The common gaps are multilingual support and context length.
>
> When a model still falls short on your domain, an overlooked optimization is to fine-tune it. Fine-tuning an embedder is far easier than fine-tuning an LLM, and it often has a bigger impact. My favorite part of the talk was [VespaEmbed](https://github.com/vespaai-playground/vespaembed), Radu’s open source fine-tuning tool. VespaEmbed is Apache 2.0 and needs no code. Pick a base model from Hugging Face, upload your pairs, choose a loss, hit train. The setup screen below shows those steps.
>
> ![[hamel-vespaembed-001.png]]
>
> The VespaEmbed setup screen for a new run.
>
> You can try VespaEmbed [here](https://huggingface.co/spaces/vespa-engine/vespaembed).
>
> You can watch Radu’s full talk [here](https://maven.com/p/fef4e1) and his deck is available [here](https://notpptx.com/vespaai/choosing-finetuning-embedder).
