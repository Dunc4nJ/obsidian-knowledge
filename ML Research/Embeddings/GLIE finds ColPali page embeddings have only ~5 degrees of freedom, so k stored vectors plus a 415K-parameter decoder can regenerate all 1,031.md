---
created: 2026-09-12
description: Author thread announcing the GLIE preprint — ColPali stores 1,031 unit vectors per page but their intrinsic dimension is only ~5 (TwoNN; Gaussian control reads 32, noise 61), so normalizing k-means centroids back to the sphere buys +0.093 nDCG@5 for free and a 415K-param projection/decoder pair can store k anchors per page and regenerate the full set for the top-20 only
source: https://x.com/mohammad2012191/status/2098283778909012011
author: Mohamed (@mohammad2012191), KAUST Academy
type: thread
tags: [embeddings, late-interaction, colbert, colpali, maxsim, visual-document-retrieval, compression, vidore, preprint]
---

## Key Takeaways

- **The storage problem is stated precisely, and the geometry says it is mostly illusory.** ColPali stores 1,031 vectors × 128 dims per page, so a million pages is roughly a quarter terabyte — the concrete visual-document instance of the 10-100x storage penalty [[SMVE makes billion-doc multivector retrieval practical - sparse random projections gate exact MaxSim to survivors at p99 under 100ms|Marek Galovic put on multivector retrieval generally]]. The measurement that reframes it: across ColPali, ColQwen2 and Nemotron v2 the per-token vectors sit *exactly* on the unit sphere (token norm 1.000) and their TwoNN intrinsic dimension is only 4.9–6.1. The estimator control is what makes this credible rather than an artifact — a Gaussian with the same covariance reads 32, pure noise reads 61. A page is a ~5-dimensional object wearing 1,031×128 numbers, which is a different diagnosis from the usual one: the cost of late interaction is not that [[single-vector dense models have a fundamental dimension-bound ceiling on retrieval combinations|one vector cannot hold enough]], nor that [[late interaction lets a 150M ColBERT model outperform 7B dense retrievers on reasoning-intensive retrieval|token-level scoring is intrinsically expensive]], but that the stored object is enormously redundant.

- **The centroid-norm identity is the whole free win, and it is a statement about coverage.** For unit vectors with mean c, `(1/n) Σ ‖xᵢ − c‖² = 1 − ‖c‖²` — the centroid's norm *is* the cluster's spread, inverted. k-means centroids are averages of sphere points, so they fall strictly inside the sphere; every centroid is shorter than a unit vector and therefore every MaxSim score computed against them is systematically depressed. Renormalizing to the surface recovers +0.093 nDCG@5 with no training at all. The reason the discarded information is safely discardable is exactly the [[ColBERT MaxSim is a submodular facility location objective and that is why it generalizes|facility-location reading of MaxSim]]: the objective scores *coverage* of query tokens by document tokens, and coverage is a question about direction, not about how tightly a cluster's clients huddle around their facility. Normalization throws away the record of how well each cluster was covered because retrieval never asked.

- **GLIE is the two-stage retrieval pattern with the second stage's inputs synthesized rather than stored.** Offline: encode once with a frozen encoder, compress 1,031 → k. Online: MaxSim over the k stored vectors for every page. Online: expand only the top-20 back to 1,031 with a shared decoder and rescore exactly. That is structurally the same cheap-gate-then-exact-MaxSim split as [[SMVE makes billion-doc multivector retrieval practical - sparse random projections gate exact MaxSim to survivors at p99 under 100ms|SMVE]] — but the two attack different costs, and the difference matters. SMVE keeps every original vector on disk and builds a sparse random-projection sketch purely as an inverted-index prefilter, so its survivor rescoring is *exact by construction*; it buys compute, not storage. GLIE deletes the originals, so its survivors have nothing exact to be rescored against and the second stage has to hallucinate its own inputs. Everything hard about GLIE lives in that substitution.

- **The monotonicity guarantee is what makes synthesizing the second stage's inputs safe, and it is structural rather than empirical.** The decoder emits every stored vector unchanged among its 1,031 outputs; MaxSim is a max over document tokens, so regeneration can only add candidate matches, never remove one. The regeneration stage therefore cannot score below the stored-vector stage for any query — a property proven from the architecture, not observed on a benchmark. In facility-location terms this is plain monotonicity of the coverage objective under adding facilities, which is the same structure the [[ColBERT MaxSim is a submodular facility location objective and that is why it generalizes|submodular reading]] identifies. Mechanically it is also the [[Baseten's STILL perceiver amortizes KV cache compaction into one forward pass, compressing 8x at 85%+ factual retention|STILL move]] applied to retrieval indexes: amortize a per-item reconstruction into one learned forward pass, here at 415K total encoder+decoder parameters and ~3 GPU-minutes of adaptation.

- **The claim to hold onto is "beats every prior *post-hoc* method"; the encoder-retraining line is argued around, not beaten outright.** GLIE tops post-hoc baselines on ViDoRe v1 and v2 and, at matched training source and budget on ViDoRe v1, LoRA-fine-tuned Light-ColPali (0.523 at k=2 → 0.701 at k=64) trails even free normalized k-means (0.552 → 0.809), with GLIE ahead of both (0.597 → 0.811). Against MetaEmbed the argument is about *cost of ownership*, not score: retraining the encoder reaches low budgets successfully but invalidates every embedding already computed — the same re-indexing tax that [[PorTAL amortizes fine-tuning across model releases by porting a frozen base-agnostic task latent to new bases with a thin per-base converter|PorTAL pays to avoid on the fine-tuning side]], and the reason a frozen backbone is the interesting constraint at all. The stated future direction — stacking GLIE on quantization engines like PLAID — is orthogonal and plausible, though [[Hornet tunes 100M-doc ANN search and finds instruction prefixes, graph connectivity, and quantization ceilings interact in ways benchmarks miss|quantization ceilings interact with index structure in ways that are hard to predict from either side alone]].

- **@benmodev's reply names the real ceiling, and the paper's own framing concedes it in more flattering language.** The shortlist sweep shows more candidates barely moving GLIE while the oracle keeps improving — evidence that the bottleneck is decoder fidelity, not reranking depth, so buying more shortlist compute is the wrong lever. Figure 7 in the thread makes this quantitative: at k=8 there is 0.090 of "decode headroom" left below the 0.836 uncompressed ceiling versus a thin sliver of shortlist headroom. The author's "the decoder is its main design surface, with huge headroom" is the same fact stated as opportunity. The honest reading is that GLIE's published numbers are the *floor* of a simple decoder, and that the diminishing return from candidate count is the standard reranking-depth ceiling [[LATTICE uses LLM-guided semantic tree traversal with calibrated scoring to achieve logarithmic-complexity retrieval that outperforms reranking on reasoning-intensive benchmarks|LATTICE documents for retrieve-then-rerank pipelines generally]].

**Evidence status:** unreviewed arXiv preprint, announced by its own first author, all numbers self-reported by the team; no third-party reproduction. The comparison set is post-hoc compression methods on ViDoRe v1/v2 — a narrower claim than "state of the art in visual document retrieval," and the [[mixedbread search v3 nearly closes the oracle gap on agentic retrieval benchmarks using late-interaction multimodal encoding|oracle-gap framing]] both this thread and that one use should be read as a headroom diagnostic rather than a leaderboard. Two of the geometry claims — the ~5 degrees of freedom with its estimator control, and the regeneration monotonicity — are the kind that stand or fall on argument and are checkable independently of the benchmark table. Public feedback from @lateinteraction (Omar Khattab, ColBERT's author) and @antoine_chaffin is credited in the thread; that is a signal about the work having been read by people who would notice a broken geometry argument, not a substitute for peer review.

## External Resources

- [GLIE: Generative Late-Interaction Embeddings for Visual Document Retrieval (arXiv 2609.11808)](https://arxiv.org/abs/2609.11808) — the preprint itself; not captured here, this note covers the announcement thread only
- [mohammad2012191/GLIE (GitHub)](https://github.com/mohammad2012191/GLIE) — reference implementation
- [GLIE project page](https://mohammad2012191.github.io/GLIE/) — interactive walkthrough of the sphere geometry
- [ColPali](https://huggingface.co/vidore/colpali) / [ViDoRe benchmark](https://huggingface.co/collections/vidore) — the encoder and benchmark suite GLIE compresses and is evaluated on
- [PLAID](https://arxiv.org/abs/2205.09707) — the late-interaction quantization/pruning engine the thread proposes stacking with

## Original Content

> [!quote]- Full thread — @mohammad2012191, 11 Sep 2026 (10 tweets + 1 reply)
>
> **@mohammad2012191 (Mohamed)** — Fri Sep 11 05:33:31 +0000 2026 · [status/2098283778909012011](https://x.com/mohammad2012191/status/2098283778909012011)
>
> 🚨 New preprint
> GLIE: Generative Late-Interaction Embeddings for Visual Document Retrieval
>
> 🔵 TL;DR: Late-interaction retrievers store ~1,000 vectors per page. Turns out those ~1,000 vectors have only ~5 degrees of freedom, so a handful of stored vectors plus a tiny shared decoder can carry a page. So: store those projected vectors, use them as an index, and regenerate the full embedding set for the top candidates only, then rerank :)
>
> *The three-stage inference pipeline: offline indexing encodes N pages to 1,031 vectors each and projects them down to k stored vectors; retrieval scores every page by MaxSim over those k; only the top-L candidates are decoded back to 1,031 vectors and re-ranked for the final rank.*
> ![[mohammad2012191-012011-001.png]]
>
> ---
>
> **@mohammad2012191 (Mohamed)** — Fri Sep 11 05:33:32 +0000 2026 · [status/2098283783120179300](https://x.com/mohammad2012191/status/2098283783120179300)
>
> Late interaction is the state of the art for visual document search, but it pays for it in storage.
>
> ColPali: 1,031 vectors × 128 dims per page. One million pages = a quarter terabyte of embeddings.
>
> Prior fixes compress the stored set using:
>
> ➡️Pooling / pruning / merging: keep a subset or local average of the vectors.
> ➡️ Retraining the encoder (MetaEmbed): reaches low budgets successfully, but invalidates embeddings you already computed.
>
> So....
> We asked a different question....
>
> What IS the stored object, geometrically?
>
> *Method comparison table: only GLIE keeps a frozen backbone while being effective at ≤16 vectors, budget-elastic with no re-encode, and offering a generative read-out. Adapt cost per budget is ~72 GPU-h for Light-ColPali and ~192 GPU-h for MetaEmbed, versus 0 for GLIE's training-free stage and ~3 GPU-min for GLIE full.*
> ![[mohammad2012191-012011-002.png]]
>
> ---
>
> **@mohammad2012191 (Mohamed)** — Fri Sep 11 05:33:33 +0000 2026 · [status/2098283786718839211](https://x.com/mohammad2012191/status/2098283786718839211)
>
> Across three encoders, we found that:
>
> 🔵 The vectors sit exactly on the unit sphere.
> 🔴 Those 1,031 vectors have only ~5 degrees of freedom.
> (We checked it's not the estimator: a Gaussian with the same covariance reads 32. Noise reads 61.)
>
> Sooooo:
>
> k-means centroids are averages of points on a sphere. So they fall INSIDE it. Every centroid is shorter than a unit vector, so every MaxSim score is systematically too low.
>
> Normalize them back to the surface and u get +0.093 nDCG@5 for free :)
>
> Normalized K-Means is already a powerful training-free baseline!
>
> *Table 2, per-page geometry medians for three encoders: ambient dimension D is 128 for ColPali and ColQwen2 and 3,072 for Nemotron v2, token norm is exactly 1.000 in all three, and the TwoNN intrinsic dimension is 4.9, 5.1 and 6.1 respectively (per-corpus ranges 4.7–5.1, 4.9–5.5, 5.6–8.1).*
> ![[mohammad2012191-012011-003.png]]
>
> ---
>
> **@mohammad2012191 (Mohamed)** — Fri Sep 11 05:33:34 +0000 2026 · [status/2098283790216909073](https://x.com/mohammad2012191/status/2098283790216909073)
>
> Why does that work?
>
> For unit vectors with mean c:
>
> (1/n) Σ ‖xᵢ − c‖² = 1 − ‖c‖²
>
> The centroid's norm IS the cluster's spread. Normalizing throws away the exact record of how well each cluster was covered.
> ➡️Turns out retrieval only needed the direction :)
>
> 🤔But wait a minute.... if a page is really low dimensional... then probably i can project it down to few vectors and train a decoder to get back the full vectors!👀
>
> ---
>
> **@mohammad2012191 (Mohamed)** — Fri Sep 11 05:33:35 +0000 2026 · [status/2098283792758681980](https://x.com/mohammad2012191/status/2098283792758681980)
>
> Say welcome to:
> GLIE: Generative Late-Interaction Embeddings, where we store k vectors per page then regenerate the rest when it matters.
>
> At training time:
>
> 1️⃣ Projection: k-means → normalize → a tiny refiner reads and nudges these anchors.
> 2️⃣ Regeneration: a shared decoder expands the k stored vectors back to all 1,031.
>
> 🔵We initialize the refiner output using the normalized k-means..
> 🔵and we have our losses defined over both the anchors and the regenerated vectors to ensure both are retrievable...
>
> *Training-time architecture: a frozen visual document encoder emits X (1,031 vectors); projection runs k-means for spherical anchors (inside the sphere, unanchored), normalizes them onto the sphere, then an MHA refiner nudges them to C (4 vectors); a decoder regenerates X̂ (1,031 vectors). Five objective components — MaxSim MSE on scores, listwise KL on ranking, a negative-overshoot penalty, Chamfer for set shape, and a support function for fixed directions — draw on the original, projected and regenerated vectors, with the first three over all candidates and the last two over gold pages only.*
> ![[mohammad2012191-012011-004.png]]
>
> ---
>
> **@mohammad2012191 (Mohamed)** — Fri Sep 11 05:33:36 +0000 2026 · [status/2098283797116498156](https://x.com/mohammad2012191/status/2098283797116498156)
>
> At query time:
>
> 🗂️ Offline (index): each page is encoded once by the frozen encoder, and its 1,031 vectors are compressed to k stored vectors.
> 📍 Online (retrieve): every page is scored by MaxSim over its k stored vectors.
> 🎯 Online (regenerate & rerank): only the top-20 candidates get expanded back to all 1,031 vectors by a shared decoder, then rescored exactly.
>
> And a guarantee for free: the decoder emits every stored vector unchanged among its outputs. MaxSim is a max, so regeneration can add evidence but structurally cannot destroy it.
>
> and a FYI, the encoder+decoder params count is 415K, so u can train that while preparing your morning coffee :)
>
> *The same inference-time diagram re-posted alongside the query-path description — offline indexing, retrieval over the projected vectors, decode top-L and re-rank.*
> ![[mohammad2012191-012011-001.png]]
>
> ---
>
> **@mohammad2012191 (Mohamed)** — Fri Sep 11 05:33:36 +0000 2026 · [status/2098283800446767615](https://x.com/mohammad2012191/status/2098283800446767615)
>
> ✔️Beats every prior post-hoc method on both ViDoRe v1 and v2.
> ✔️At a matched training budget, fine-tuning the encoder (Light-ColPali) doesn't even reach free normalized k-means.
> ✔️Requires only few thousands of pages to train, and works zero-shot across corpora https://t.co/3OTWuMCqBG
>
> *nDCG@5 gain over the best baseline as a function of vectors stored per page, on ViDoRe v1 and v2. Stage 1 (stored code) alone already leads; the shaded band is the extra gain from generative read-out. Both curves peak at k=4 (+0.048 on v1, +0.055 on v2) and compress toward zero by k=64 — the advantage is largest exactly where storage is tightest.*
> ![[mohammad2012191-012011-005.png]]
>
> *Table 5, matched training source and budget on ViDoRe v1 across ten subsets: Light-ColPali (LoRA fine-tune) reads 0.523/0.544/0.586/0.632/0.661/0.701 at k=2..64, free normalized k-means reads 0.552/0.605/0.684/0.736/0.784/0.809, and GLIE with a frozen backbone reads 0.597/0.657/0.718/0.759/0.791/0.811 — the fine-tuned encoder loses to the training-free baseline at every budget.*
> ![[mohammad2012191-012011-006.png]]
>
> ---
>
> **@mohammad2012191 (Mohamed)** — Fri Sep 11 05:33:37 +0000 2026 · [status/2098283804351754300](https://x.com/mohammad2012191/status/2098283804351754300)
>
> 🔵 We think GLIE opens a new axis for storage-efficient retrieval, and the decoder is its main design surface.
>
> We employ a simple decoder design as a baseline, which still has huge headroom to explore, suggesting that more sophisticated architectures could yield further performance gains.
>
> Plus, if this can be combined with quantization engines like PLAID, we might just solve the storage problem once and for all :)
>
> *Headroom decomposition against the 0.836 uncompressed ceiling: each bar splits achieved nDCG@5 into stage 1, the read-out increment, remaining decode headroom (0.156 at k=2 down to 0.023 at k=64) and remaining shortlist headroom. Decode headroom dominates the gap at every budget — the figure @benmodev's reply reads as a decoder problem rather than a reranking-compute problem.*
> ![[mohammad2012191-012011-007.png]]
>
> ---
>
> **@mohammad2012191 (Mohamed)** — Fri Sep 11 05:33:40 +0000 2026 · [status/2098283814631928105](https://x.com/mohammad2012191/status/2098283814631928105)
>
> 📄 Paper: https://t.co/MYMLTxdLvF
> 💻 Code: https://t.co/NMB7A8wwL5
> Huge thanks to the great team: Talal Aloushan, Rose @Quantumleap___ , Jana Shatta, Mohammed Alhassan, Leen Alrehaili, and supervisors Dr. Tanveer Hussain & Prof. @ProfNaeemKhan.
> Special thanks to @KAUST_Academy & @Dr_S_Albarakati for their absolute incredible support🫡
> and special thanks to @lateinteraction and @antoine_chaffin for their continuous feedback!
>
> *(Resolved links: paper → https://arxiv.org/abs/2609.11808 · code → https://github.com/mohammad2012191/GLIE)*
>
> ---
>
> **@mohammad2012191 (Mohamed)** — Fri Sep 11 05:41:06 +0000 2026 · [status/2098285684616245277](https://x.com/mohammad2012191/status/2098285684616245277)
>
> @Quantumleap___ @ProfNaeemKhan @KAUST_Academy https://t.co/Uuk8nmuqRG https://t.co/rNEq2NXxZk
>
> *(Resolved links: project page → https://mohammad2012191.github.io/GLIE/ · quote of the results tweet)*
>
> *Three spheres from the project page: the original embeddings (N = 1,031 unit vectors) form a structured cloud of arcs on the sphere; the compressed code (k = 32 refined anchors, via raw k-means → normalize → refine) keeps one point per arc; the regenerated embeddings reproduce the arcs from the refined code, with the exact stored anchors ringed and the decoded children filling in around them.*
> ![[mohammad2012191-012011-008.jpg]]
>
> ---
>
> **@benmodev (Ben Mo)** — Fri Sep 11 18:27:09 +0000 2026 · [status/2098478467780354099](https://x.com/benmodev/status/2098478467780354099)
>
> @mohammad2012191 The shortlist sweep is a useful reality check. More candidates barely moved GLIE while the oracle kept improving. It points to a decoder problem you can work on, rather than just throwing more reranking compute at it.

Source thread: [x.com/mohammad2012191/status/2098283778909012011](https://x.com/mohammad2012191/status/2098283778909012011)

Neighbouring notes in the vault's retrieval cluster: the application-side counterpart where [[ColBERT-style semantic search beats grep 70 percent of the time for coding agents while using fewer tokens|late interaction earns its keep for coding agents]] and the opposite conclusion when context is cheap in [[agentic search with grep and full-file loading replaces RAG when context windows are large enough]]; the practitioner's ledger of storage levers in [[embedding model selection is a cost-quality tradeoff MTEB cannot see - and fine-tuning the embedder is the overlooked high-impact lever|INT8, binary vectors and Matryoshka truncation]], which GLIE's k-anchor compression is orthogonal to and stackable with; [[Agent-ModernColBERT trains late interaction on reasoning traces to reach GPT-5 retrieval accuracy with 149M parameters|Agent-ModernColBERT]] on the model-quality axis and [[scaling embedding models requires LLM-labeled deduplication to fix the fake negative problem|LLM-labeled deduplication]] on the training-data axis of the same late-interaction stack; [[OBLIQ-Bench shows that scalable retrievers fail to surface oblique queries that reasoning LLMs can verify|OBLIQ-Bench]] as the reminder that a better-compressed index does nothing for queries no scalable retriever can surface; and [[DeepSeek-V4.1-Flash cuts global KV cache to 890 bytes per token - a quarter of V4-Flash and 437x below V1 - by stacking cross-layer CSA2 reuse, FP4 caching, and a causal encoder-decoder|the KV-cache side of the same "store less, reconstruct on demand" argument]], alongside [[Auto-Dreamer learns offline region rewriting to shrink language-agent memory 12x while improving task success|offline rewriting of agent memory]].
