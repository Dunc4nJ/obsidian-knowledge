---
created: 2026-08-14
description: Hamel Husain's summary of Marek Galovic's session — multivector/late-interaction retrieval (one vector per token, MaxSim scoring) escapes the single-vector bottleneck but costs ~2,000x the arithmetic of a dot product and 10-100x the storage. SMVE makes it practical: project each token onto random directions, keep top-8 values, sum into one sparse vector per document for an inverted index, and run exact MaxSim only on survivors — p99 under 100ms at one billion documents. Plus Iso-ModernColBERT, a corrected GTE-ModernColBERT-v1 whose geometry works with SMVE and runs ~3x faster at bf16.
source: https://hamel.dev/notes/llm/ai-product-engineering/context-multivector-retrieval.html
author: Hamel Husain (summarizing Marek Galovic's session)
type: article
tags: [embeddings, multivector, late-interaction, colbert, maxsim, retrieval, sparse-index, ai-product-engineering, hamel]
---

## Key Takeaways

- **Why multivector: the single-vector bottleneck is real, and MaxSim is the escape.** Compressing a document into one vector is an information bottleneck — the ceiling [[single-vector dense models have a fundamental dimension-bound ceiling on retrieval combinations|proven formally elsewhere in this folder]]. Multivector retrieval stores one vector per token for query and document; each query token matches its best document token and the scores sum (MaxSim) — the operator whose generalization power the vault's [[ColBERT MaxSim is a submodular facility location objective and that is why it generalizes|submodular-facility-location analysis]] explains, and whose quality-per-parameter is why [[late interaction lets a 150M ColBERT model outperform 7B dense retrievers on reasoning-intensive retrieval|150M ColBERT models beat 7B dense retrievers]].

- **Why it stayed in research papers: ~2,000x the arithmetic of a dot product, 10-100x the storage.** Marek's estimates put honest numbers on the tradeoff that kept late interaction out of production at scale.

- **SMVE is the trick that makes it deployable: sparse pre-filtering, exact MaxSim only on survivors.** Project each token onto a large set of random directions, keep the top-8 values, sum per document into one mostly-empty sparse vector, and put *that* in an inverted index — documents sharing no entries with the query are never scored at all. Result: **p99 latency under 100ms at one billion documents.** It's the classic candidate-generation/re-ranking split, executed inside the embedding geometry itself.

- **Iso-ModernColBERT: the model correction that makes the trick safe.** A fixed GTE-ModernColBERT-v1 whose embedding geometry is compatible with SMVE's random projections, running ~3x faster at bf16 with almost no ranking loss — sibling work to the reasoning-trace-trained [[Agent-ModernColBERT trains late interaction on reasoning traces to reach GPT-5 retrieval accuracy with 149M parameters|Agent-ModernColBERT]] in the vault's search cluster.

## External Resources

- Original note: [An Intro to Multivector Retrieval — Hamel Husain](https://hamel.dev/notes/llm/ai-product-engineering/context-multivector-retrieval.html) ([AI Product Engineering series](https://hamel.dev/notes/llm/ai-product-engineering/))
- [Marek Galovic's talk](https://maven.com/p/6544a2) · [SMVE blog post (topk.io)](https://www.topk.io/blog/20260311-smve-multi-vector-retrieval) · [Iso-ModernColBERT (HF)](https://huggingface.co/topk-io/Iso-ModernColBERT) · [Hamel's late-interaction notes](https://hamel.dev/notes/llm/rag/p4_late_interaction.html)

## Original Content

> [!quote]- Full note — "An Intro to Multivector Retrieval" (Hamel Husain; session by Marek Galovic)
> _This note covers Marek Galovic’s session in the [AI Product Engineering series](../../../notes/llm/ai-product-engineering/index.html)._
>
> Most retrieval systems compress each document into a single vector, which becomes an information bottleneck. Multivector retrieval avoids this bottleneck (but incurs a cost) by storing one vector per token for both the query and the document. Each query token is matched against its best document token, and those token scores are summed to score the document. This scoring operator is called MaxSim. My [notes on late interaction](../../../notes/llm/rag/p4%5Flate%5Finteraction.html) cover why this approach is something you should try.
>
> This slide from Marek’s talk shows the idea. Each cell compares one query token to one document token, and the shaded cells are the best matches that MaxSim sums.
>
> ![[hamel-multivector-001.jpg]]
>
> Marek’s slide on the intuition for multivector embeddings.
>
> However, there is a tradeoff. Since you are storing and comparing vectors for every token in both the query and the document, compute and storage costs grow fast. Marek estimates MaxSim costs roughly 2,000x the arithmetic of a single dot product and 10 to 100x the storage, which is why it stayed in research papers.
>
> Marek discusses a set of optimizations that bring those costs down enough to run at scale. The main one is [SMVE](https://www.topk.io/blog/20260311-smve-multi-vector-retrieval). SMVE projects each token onto a large set of random directions and keeps only the top eight values. Summing those per document produces one mostly empty vector, which goes into an inverted index. Documents that share no entries with the query are never scored, and exact MaxSim runs only on the survivors. Marek reported p99 latency under 100 ms at one billion documents.
>
> His team also released [Iso-ModernColBERT](https://huggingface.co/topk-io/Iso-ModernColBERT), a corrected version of GTE-ModernColBERT-v1 whose embedding geometry works with SMVE’s random projections. It also runs about 3x faster at bf16 precision with almost no loss in ranking quality.
>
> You can watch Marek’s full talk [here](https://maven.com/p/6544a2).
