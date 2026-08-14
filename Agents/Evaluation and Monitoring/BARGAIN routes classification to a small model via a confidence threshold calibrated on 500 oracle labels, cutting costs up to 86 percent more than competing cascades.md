---
created: 2026-08-14
description: Hamel Husain's summary of Shreya Shankar's session on BARGAIN — route classification records to a small proxy model when its label confidence clears a threshold, escalate to the large oracle model when it doesn't. Calibrate by labeling ~500 records with the large model and picking the cheapest observed confidence threshold that meets your accuracy target (accuracy = agreement with the large model, not human labels). Up to 86% more cost reduction than competing methods; the Task Cascades follow-up (surrogate questions, chunk-level reading, cascade search) cuts a further 48.5%.
source: https://hamel.dev/notes/llm/ai-product-engineering/evals-model-cascades.html
author: Hamel Husain (summarizing Shreya Shankar's session)
type: article
tags: [eval, model-cascade, classification, cost-optimization, confidence-routing, bargain, ai-product-engineering, hamel]
---

## Key Takeaways

- **The cascade: small model when confident, large model when not — with a measured threshold, not a vibe.** Classification at LLM scale gets expensive fast. BARGAIN's recipe: sample ~500 records, label them with your large model, then test *every observed confidence value* of the small model as a routing threshold and pick the cheapest one that still meets your accuracy target. The same sample doubles as a viability check — it shows whether the small model's logits correlate with the large model's labels strongly enough for the cascade to work at all. Across eight datasets the paper reports **up to 86% more cost reduction** than competing methods. Serving many small models cheaply is its own problem — the [[Superlinked's SIE inference engine serves many small models on shared GPUs, fixing the one-model-per-GPU waste of vLLM and TEI|shared-GPU serving]] complement.

- **The subtle honesty clause: the target measures agreement with the large model, not with truth.** The technique mimics the oracle model's answers — "measuring agreement with human labels is a different exercise." That's the instrument-vs-construct distinction from [[benchmarks are measurement instruments not question collections - regulargio's first-principles guide to claims, graders, coverage, and uncertainty|benchmarking science]] in miniature: know exactly what your accuracy number is a claim *about*.

- **Task Cascades pushes past model-swapping into task-rewriting.** The follow-up paper adds: rewrite the prompt into *simpler surrogate questions* a cheap model can answer, read only the most relevant chunks instead of full documents, and *search over candidate cascades* for the cheapest sequence meeting the target — a further **48.5% average cost cut** over BARGAIN-style cascades. The cascade becomes a compiled plan over models and sub-questions, not just a two-tier router.

## External Resources

- Original note: [Cut Classification Costs With a Model Cascade — Hamel Husain](https://hamel.dev/notes/llm/ai-product-engineering/evals-model-cascades.html) ([AI Product Engineering series](https://hamel.dev/notes/llm/ai-product-engineering/))
- [Shreya Shankar's talk](https://youtu.be/FWFjLF_VoVI) · [BARGAIN repo](https://github.com/ucbepic/BARGAIN) · [BARGAIN paper (arXiv 2509.02896)](https://arxiv.org/abs/2509.02896) · [Task Cascades paper (arXiv 2601.05536)](https://arxiv.org/abs/2601.05536)

## Original Content

> [!quote]- Full note — "Cut Classification Costs With a Model Cascade" (Hamel Husain; session by Shreya Shankar)
> _This note covers Shreya Shankar’s session in the [AI Product Engineering series](../../../notes/llm/ai-product-engineering/index.html)._
>
> Many LLM workloads are classification tasks, a problem that predates generative AI. LLMs are so easy to use that it is tempting to throw your largest model at everything. However, when you classify at scale this becomes expensive.
>
> Shreya’s final talk teaches [BARGAIN](https://github.com/ucbepic/BARGAIN), a method for shifting classification work to a smaller model while meeting an accuracy target you choose. The method uses the probability the small model emits with each label to route each record. You sample about 500 records and label them with your large model. Then you test every observed confidence value as a routing threshold and choose the cheapest threshold that still meets your target. The same sample also shows whether the small model’s logits are correlated strongly enough with the large model’s labels for the approach to work.
>
> Important note: the accuracy target measures agreement with the large model, not human labels, because this technique is about mimicking a large model’s answers. Measuring agreement with human labels is a different exercise.
>
> ![[hamel-cascades-001.png]]
>
> A model cascade routes records between a smaller proxy model and a larger oracle model.
>
> Across eight datasets, the [BARGAIN paper](https://arxiv.org/abs/2509.02896) reports up to 86% more cost reduction than competing methods.
>
> The follow-up [Task Cascades paper](https://arxiv.org/abs/2601.05536) adds more optimizations, such as:
>
> * Rewriting the prompt into simpler surrogate questions a cheap model can answer.
> * Reading the most relevant chunks of each document instead of the full text.
> * Searching over candidate cascades to find the cheapest sequence that meets the accuracy target.
>
> These optimizations cut costs a further 48.5% on average over BARGAIN-style cascades.
>
> You can watch the full talk [here](https://youtu.be/FWFjLF%5FVoVI).
