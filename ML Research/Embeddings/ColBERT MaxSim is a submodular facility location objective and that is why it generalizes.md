---
created: 2026-03-21
description: Igor Carron argues that ColBERT's MaxSim scoring is mathematically a submodular facility location objective, which explains its superior out-of-domain generalization over single-vector dense retrievers
source: https://x.com/IgorCarron/status/2035159036224487657
type: synthesis
---

## Key Takeaways

MaxSim's per-token scoring — where each query token finds its best-matching document token and scores are summed — is structurally identical to a facility location objective from combinatorial optimization. The query tokens are "facilities," document tokens are "clients," and the total score measures semantic coverage. This submodular structure exhibits diminishing marginal returns: redundant matches are naturally discounted while diverse evidence is rewarded. This is a deeper explanation for why ColBERT-style retrieval generalizes across domains than simply "more parameters" — the scoring function itself encodes the right inductive bias for coverage problems. This connects to the broader insight that [[scaling embedding models requires LLM-labeled deduplication to fix the fake negative problem]], since training data quality interacts with the scoring objective.

Single-vector dense retrieval compresses all document facets into one embedding, creating a linear scoring function with no submodular structure. Scaling model parameters (1B, 4B, 8B) hits diminishing returns in the wrong place — the architectural bottleneck of one vector hasn't changed. ColBERT-Zero proved this empirically: training in the multi-vector objective from scratch on public data beat proprietary data in the dense setting by 2.4 nDCG@10 points. The training paradigm matters more than the data when the objective function is correct. This resonates with [[agentic search with grep and full-file loading replaces RAG when context windows are large enough]] — the retrieval architecture matters more than brute-force scaling.

LightOn's full stack — ModernBERT (encoder backbone), PyLate (training library), FastPlaid/NextPlaid (multi-vector search), BM25X (lexical complement), LightOnOCR-2 (document ingestion), and OriOn (long-context reading after retrieval) — demonstrates that making MaxSim production-viable required solving every layer from token quality through serving infrastructure. The 149M-parameter Reason-ModernColBERT outperforming 7B models on BRIGHT, and the system achieving 87.59% on BrowseComp-Plus (7.59 points above previous best), are the empirical validation. This matters for anyone building RAG systems, as explored in [[coding agents are bottlenecked by search not coding ability]] — better retrieval architecture compounds across all downstream tasks.

The Ettin experiments (encoder vs decoder at six scales on identical data) settled the bidirectional-vs-causal debate for token embeddings: a 150M encoder beat a 400M decoder. For MaxSim's facility location objective, bidirectional attention produces strictly more informed token representations since every token sees full document context. This architectural insight connects to the broader transformer landscape surveyed in [[twenty-six papers capture ninety percent of the alpha behind modern LLMs from attention through reasoning and mixture of experts]].

## External Resources

- [LightOn Models on HuggingFace](https://huggingface.co/lightonai) — all released models including Reason-ModernColBERT, LateOn-Code, ColBERT-Zero
- [LightOn GitHub](https://github.com/lightonai) — PyLate, FastPlaid, NextPlaid, ColGrep source code
- [LightOn Blog](https://lighton.ai/blog) — technical deep dives on the stack
- [LightOn Enterprise](https://lighton.ai) — on-prem sovereign deployment

## Original Content

> @IgorCarron — 2026-03-21
>
> Article: You just witnessed an AlexNet moment in RAG because MaxSim is a Submodular Norm
>
> You may wonder how we get here. Fasten your seat belt. It's going to be a fun bumpy friday night reading!
>
> The Mathematical Object Everyone Overlooked
>
> There's a class of functions in combinatorial optimization called submodular functions. Their defining property is diminishing marginal returns: adding an element to a small set gives you more than adding it to a large set. Formally, for any sets A ⊆ B and any element x:
>
> f(A ∪ {x}) − f(A) ≥ f(B ∪ {x}) − f(B)
>
> This isn't an analogy. It's a mathematical structure with forty years of theory behind it. Submodular maximization has known greedy approximation guarantees (1 − 1/e ≈ 0.63 for monotone submodular functions under a cardinality constraint). Facility location, max-coverage, sensor placement, document summarization, they are all instances of the same structure.
>
> MaxSim is an instance of this structure.
>
> In ColBERT's late-interaction scoring, a query has Q token embeddings and a document has D token embeddings. The relevance score is:
>
> Score = Σᵢ maxⱼ sim(qᵢ, dⱼ)
>
> Each query token finds the document token it matches best. The document score is the sum of these per-token best matches.
>
> This is a facility location objective. The query tokens are "facilities." The document tokens are "clients." Each client is served by its nearest facility. The total score measures how well the query covers the document's semantic content. And this coverage function is submodular — adding a new query token to the scoring provides diminishing marginal improvement as more tokens already cover the document's semantic space.
>
> The diminishing returns here aren't a bug. They're the reason MaxSim works.
>
> Why Submodularity Is the Right Norm for Retrieval
>
> Retrieval is fundamentally a coverage problem. A query expresses an information need. A relevant document covers that need across multiple facets — facts, context, reasoning chains, supporting evidence. The scoring function's job is to measure how well the document covers the query.
>
> Submodular functions are the mathematical tool for coverage. Their diminishing-returns property encodes exactly what you want:
>
> Early matches are high-value. The first query token that finds a strong document match contributes a lot to the score. This captures the dominant signal.
>
> Redundant matches are naturally discounted. If two query tokens match the same region of a document, the second match adds less. MaxSim doesn't double-count.
>
> Diverse evidence is rewarded. A document that matches different query tokens across different facets scores higher than one that matches the same facet repeatedly.
>
> This is why MaxSim exhibits strong out-of-domain generalization. The submodular structure doesn't depend on the domain, it depends on the geometry of coverage. A legal document covers a legal query the same way a biomedical paper covers a biomedical query: by matching diverse facets of the information need.
>
> The Single-Vector Mistake
>
> Now contrast this with dense single-vector retrieval. A document is compressed into one embedding. Similarity is a dot product or cosine between the query vector and the document vector.
>
> This is a linear scoring function. There's no submodular structure. No diminishing returns in the matching because there's only one match. No coverage because there's only one point.
>
> The entire document is projected through a single bottleneck, and all facets of meaning must coexist in one vector. When the query is simple, this works.
>
> When the query requires reasoning across multiple facets — the kind of query that matters in enterprise search, in Deep Research, in agentic retrieval, the single vector doesn't have the representational capacity to capture what's needed.
>
> The industry response: make the model bigger. 1B. 4B. 8B parameters. Each increase improves the quality of the single embedding, but the improvement curve flattens. This is diminishing returns in the wrong place: in the scaling law of the model, where each additional parameter buys less accuracy because the architectural bottleneck (one vector) hasn't changed.
>
> Submodularity tells you exactly why this fails.
>
> Coverage problems require a coverage objective. You can't solve a submodular problem with a linear scoring function by making the linear function more expensive to compute.
>
> LightOn's Stack: Engineering the Right Mathematical Object
>
> Knowing that MaxSim is the right scoring function is the easy part. The hard part is making it trainable, servable, and deployable at enterprise scale. LightOn built that infrastructure layer by layer, each solving a specific engineering barrier.
>
> The token representations: ModernBERT (December 2024)
>
> MaxSim's quality is determined by the quality of the individual token embeddings. Each token is a point in the semantic space; MaxSim computes coverage in that space. Better points, better coverage.
>
> ModernBERT (co-developed with AnswerAI) modernized the encoder: 8,192-token context, Flash Attention 2, rotary positional embeddings, 2 trillion training tokens. The atomic unit of MaxSim improved across the board.
>
> The architectural proof: Ettin (July 2025)
>
> A natural objection: maybe the encoder-only architecture isn't actually better for retrieval. Maybe a sufficiently large decoder can match it. After all, projects like LLM2Vec proposed converting decoders into retrievers.
>
> Ettin, a collaboration between Johns Hopkins University and LightOn, settled this with the first controlled experiment. Six model sizes from 17M to 1B parameters, trained on identical data (2T tokens of fully open data), identical recipes (the ModernBERT training pipeline), identical architecture shapes. The only difference: encoder (bidirectional attention, MLM objective) vs. decoder (causal attention, CLM objective).
>
> The results were unambiguous. A 150M encoder (89.2 on MNLI) outperformed a 400M decoder (88.2). On retrieval tasks, the gap was even larger. Cross-objective training — continuing to train a decoder with the encoder's MLM objective — still trailed native encoders.
>
> This matters for the submodularity argument. MaxSim computes coverage in the space of token embeddings. Bidirectional attention lets each token see the full document context, producing richer representations at every position. Causal attention restricts each token to its left context — the first token sees nothing, the second sees one token, and so on. For a facility location objective where every token is a potential facility, bidirectional representations are strictly more informed.
>
> Ettin proved this isn't a theory — it's a measurable architectural advantage that holds across six model scales, on identical data, with identical training. Encoders are fundamentally better at producing the token representations MaxSim needs.
>
> Two practical consequences followed.
>
> First, the Ettin encoders beat ModernBERT across all sizes while using entirely open, reproducible training data — validating that the recipe, not proprietary data, is what matters.
>
> Second, the 17M Ettin encoder became the backbone for LateOn-Code-edge, the ultra-fast code retrieval model that runs locally inside ColGrep. The smallest point on the Ettin scale turned out to be exactly the right size for a single-binary semantic search tool.
>
> The training: PyLate (2024–2025)
>
> ColBERT training required bespoke pipelines. PyLate (accepted at #CIKM2025) reduced it to ~80 lines of code and under 2 hours on a single GPU. The first peer-reviewed library for late-interaction model training. Submodular retrieval became as easy to ship as a bi-encoder.
>
> The multi-vector search: FastPlaid → NextPlaid (2025–2026)
>
> MaxSim requires storing and searching per-token embeddings. FastPlaid, a Rust rewrite of Stanford's PLAID engine, delivered 554% throughput improvements. NextPlaid packaged it as a local-first multi-vector database with REST API, Docker, and ONNX INT8 quantization.
>
> The cost of computing a submodular scoring function at scale dropped to production-viable levels.
>
> The lexical complement: BM25X (2025–2026)
>
> Submodular doesn't mean universal. BM25 handles exact keyword matching, acronyms, identifiers, cases where the semantic space isn't where the action is. LightOn's Rust BM25 engine provides streaming mutations, mmap indices, and pre-filtered search up to 600× faster. BM25X and MaxSim cover different failure modes. The full stack uses both.
>
> The document pipeline: LightOnOCR-2 (January 2026)
>
> MaxSim needs tokens. The most valuable enterprise documents are locked in scanned PDFs. LightOnOCR-2 — 1B parameters, SOTA on OlmOCR-Bench, 9× smaller and 3.3× faster than Chandra-9B — converts them to text. On-prem, behind the firewall.
>
> No tokens, no coverage. OCR is the front door.
>
> The proof on standard retrieval: GTE-ModernColBERT (May 2025)
>
> First model to beat ColBERT-small on BEIR — 18 heterogeneous datasets covering biomedical search, open QA, argument analysis, forums, and scientific knowledge bases. Token-level coverage, powered by a modern encoder, outperformed dense models on cross-domain generalization.
>
> But GTE-ModernColBERT was built the way everyone builds ColBERT models: take a strong dense (single-vector) pre-trained model, bolt on a knowledge distillation step in the multi-vector setting at the very end. The submodular objective was an afterthought: the last fine-tuning phase, not the training paradigm.
>
> This left an obvious question hanging.
>
> Training in the submodular objective from day zero: ColBERT-Zero (February 2026)
>
> If MaxSim is the right scoring function that is if submodular coverage is the right mathematical structure for retrieval, then why are we training models in the wrong objective for 95% of the pipeline and only switching to the right one at the end?
>
> ColBERT-Zero, a collaboration between Ecole Polytechnique Fédérale de Lausanne (EPFL) and LightOn, answered this by performing contrastive pre-training directly in the multi-vector setting from the very first phase. Not as a final distillation step. From zero.
>
> The result was striking. A dense baseline trained on GTE's proprietary data scored 55.33 nDCG@10 on BEIR. A dense baseline trained on Nomic's public data scored 52.89 (a 2.4-point data quality gap.) ColBERT-Zero, trained entirely on public data but in the multi-vector objective from scratch, reached 55.43 (closing and surpassing the proprietary-data gap.)
>
> Read that again. Public data, worse by 2.4 points in the dense setting, beats proprietary data when you train in the submodular objective from the start.
>
> This is the purest evidence for the submodularity thesis. The conventional pipeline: dense pre-training → dense supervised → multi-vector distillation — treats MaxSim as a post-hoc refinement. ColBERT-Zero shows it's a training paradigm. When the encoder learns token-level importance signals from the first gradient, through PyLate's GradCache (scaling to ~16K effective batch size without VRAM constraints) and cross-GPU gathering, it develops representations that are fundamentally different from what dense pre-training produces. The tokens learn to be good at being facility locations, not good at being compressed into a single point.
>
> The practical finding was equally important: performing a supervised contrastive step before distillation closes most of the gap at a fraction of the cost. And prompt alignment between pre-training and fine-tuning is non-negotiable (stripping asymmetric prompts degrades performance significantly.)
>
> All models, intermediate checkpoints, and training scripts were released under Apache 2.0. Including the SOTA on BEIR for models under 150M parameters.
>
> The proof on reasoning: Reason-ModernColBERT (May 2025)
>
> Fine-tuned for reasoning-intensive retrieval. 149M parameters. Outperformed every model up to 7B on BRIGHT, including ReasonIR-8B trained on identical data.
>
> This is where the submodular argument bites hardest. Reasoning queries have multiple implicit facets: preconditions, intermediate steps, conclusions. A single vector can capture the dominant facet. MaxSim captures the coverage across facets. Same data, same task: the model with the submodular scoring function won, at 54× fewer parameters.
>
> The proof on code: LateOn-Code + ColGrep (February 2026)
>
> Code retrieval requires matching function signatures, variable names, docstrings, and structural patterns simultaneously. This is a multi-facet coverage problem. LateOn-Code (17M and 130M params) topped the MTEB Code leaderboard. ColGrep brought MaxSim to the terminal, beating grep 70% of the time while cutting agent token usage.
>
> The deep reader after retrieval: OriOn (February 2026)
>
> MaxSim solves the coverage problem: which documents address the facets of the query? But coverage is the first step. Once the retriever surfaces the right documents, an agentic system needs to read them — deeply, across hundreds of pages, without losing coherence.
>
> This is a fundamentally different problem from retrieval. Retrieval is submodular coverage over a large corpus. Deep reading is long-context reasoning over a small, retrieved set. The two are complementary, and an enterprise pipeline needs both.
>
> OriOn is LightOn's family of long-context visual language models. The 32B-parameter model processes up to 250 pages at full visual resolution in a single pass, matching or exceeding models 7× its size on the most challenging long-document benchmarks. On MMLBD-C — LightOn's manually corrected version of MMLongBenchDoc, the hardest benchmark for long-context visual document understanding — OriOn-Qwen-32B achieved 57.3, surpassing even its 235B teacher model (56.2). For context: expert human accuracy on this benchmark is roughly 65.8%, and GPT-4o scores 46.3%.
>
> The connection to MaxSim is direct. In an agentic RAG pipeline, MaxSim's submodular scoring retrieves the right pages from millions of documents. OriOn then ingests those pages, not as extracted text chunks, but as rendered visual documents, preserving tables, charts, formatting, and layout, and reasons across them in a single forward pass. Thanks to prefix caching, each subsequent turn in an agentic loop is near-instant.
>
> The training insights were released openly (50+ ablation experiments), and several challenged prevailing assumptions: training on genuinely long contexts that exceed your evaluation distribution can hurt performance; visual long-context training transfers strongly to text-only benchmarks (+11.5 points on HELMET from visual-only training); and a novel recursive answer generation pipeline enables self-improvement without a stronger teacher model.
>
> OriOn completes the pipeline that MaxSim starts. Submodular coverage finds the evidence. Long-context deep reading reasons over it. Both deploy on sovereign infrastructure, on-prem, behind the firewall.
>
> *LightOn's full retrieval and reading stack*
> ![[IgorCarron-487657-001.jpg]]
>
> The AlexNet Moment: BrowseComp-Plus (March 2026)
>
> BrowseComp-Plus is the ultimate coverage problem. 830 queries, each requiring 2+ hours for a human. Fixed 100K-document corpus. Paired with a reasoning LLM (GPT-5), the retriever's job is to find the documents that cover every facet of a complex information need, often across multiple rounds of search.
>
> Reason-ModernColBERT + GPT-5: 87.59% accuracy. 7.59 points above the previous best. First place on accuracy, recall, calibration, and search efficiency (13.27 calls vs. 21+).
>
> The efficiency gain is a direct consequence of the submodular structure. MaxSim gives the LLM token-level evidence about which parts of a document match which parts of the query. The LLM reads this signal and decides which documents deserve a full read before committing tokens. One additional function, get_document(id), is enough. No reranker. No oracle chunking.
>
> Dense retrievers provide a single similarity score. The LLM has to guess what the document contains. Guessing takes more rounds. More rounds cost more tokens. Diminishing returns in the wrong place.
>
> Making Sense of it all
>
> Submodular functions are the mathematical formalization of diminishing marginal returns. MaxSim is a submodular norm — specifically, a facility location objective where query tokens cover document tokens. This structure is inherently suited to retrieval and RAG because retrieval is a coverage problem: does this document address the diverse facets of my information need?
>
> Single-vector models replace this submodular structure with a linear scoring function and try to compensate with scale, hitting diminishing returns in model size instead of harnessing diminishing returns in the scoring function where they belong. ColBERT-Zero proved that training in the submodular objective from scratch, not as an afterthought, is what unlocks the full ceiling: public data beating proprietary data when the training paradigm is right.
>
> LightOn built the infrastructure to make MaxSim production-ready: modern encoder, native multi-vector training, Rust search engines, OCR pipeline, and OriOn for deep reading after retrieval, and the result is a 149M-parameter retriever leading the hardest benchmark in the world, paired with a 32B deep reader that matches models 7× its size, all deployable on sovereign infrastructure. The math was always right. The engineering caught up.
>
> And we are not done yet!
>
> For more
>
> Models: http://huggingface.co/lightonai
>
> Code: http://github.com/lightonai
>
> Enterprise: http://lighton.ai
>
> Blog: https://lighton.ai/blog
>
> Engagement: 31 likes | 5 retweets | 1 reply
> [Original post](https://x.com/IgorCarron/status/2035159036224487657)
