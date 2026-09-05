---
created: 2026-09-05
description: Perplexity Engineering's under-the-hood account of the serving stack behind pplx-embed — Ivy (Rust HTTP gateway doing tokenization, templating and batch splitting), Tulip (Rust/tokio/tonic gRPC scheduler), and ROSE (the Python LLM engine reused for embeddings). The central bet is that embedding inference is CPU-overhead-bound rather than GPU-bound at the sizes that matter, so the wins come from whole-model CUDA graphs captured lazily per token/sequence bucket, and a LazyTensor abstraction that lets Rust enqueue the next batch while the previous one is still on the device. Batch embedding is treated as compute-bound prefill and online embedding as memory-bound decode, so both reuse the LLM kernels with no KV cache and ragged attention. Benchmarked against vLLM v0.22.0 on one H200 in BF16, the latency gains are large and the throughput gains are not — BGE-M3 at 128 tokens goes 4.60ms to 1.53ms p50 and 7.96ms to 1.67ms p99, while indexing throughput is roughly at parity and marginally behind on pplx-embed at long sequences.
source: https://www.perplexity.ai/hub/blog/fast-embeddings-on-gpus
author: Perplexity Engineering
published: 2026-09-04
type: article
tags: [inference, embeddings, cuda-graphs, gpu-kernels, rust, vllm, flashattention, flashinfer, serving, latency, retrieval, perplexity]
---

## Key Takeaways

- **The whole architecture follows from one observation: for small embedding models the CPU, not the GPU, is the bottleneck.** "For high-throughput workloads such as training and reindexing, CPU-side overheads are negligible because batch sizes and GPU-side latency are both large. However, on smaller batch sizes, CPU-side work can outweigh GPU-side work." They track a per-model **inflection point** — the minimum token count at which GPU execution costs more than CPU-side kernel launch — and note that because embedding models are small, it lands at "batches of thousands of tokens and tens of sequences." Nearly everything else in the post is a consequence: whole-model CUDA graphs to collapse launch cost, a LazyTensor to keep the CPU busy during device execution, and a Rust gateway to keep tokenization off the inference box. It is the concrete, measured version of [[Ahmad Osman's kernel curriculum - you don't run a model you run kernels, and here are eight mini-projects from RMSNorm in Triton to a custom op profiled inside vLLM|"you don't run a model, you run kernels"]] — except the finding here is that at this scale you are not even running kernels, you are *launching* them, and that is what costs. The vault's closest empirical twin is from an entirely different domain: [[CUDA game kernels beat JAX RL environments 7x because PyTorch dispatch overhead dominates tiny networks not simulation|a CUDA rewrite of an RL environment ran 7x faster because dispatch overhead, not the math, dominated tiny networks]] — same diagnosis, same fix, no LLM in sight.

- **The benchmark table tells a more honest story than the framing does: this is a latency win, not a throughput win.** Against vLLM v0.22.0 on a single H200 in BF16, BGE-M3 at 128 tokens goes from **4.60ms to 1.53ms p50** and **7.96ms to 1.67ms p99** — roughly 3x median and ~4.8x tail. But the advantage compresses monotonically with sequence length (at 4096 it is 9.57 vs 11.71), which is exactly what the CPU-overhead thesis predicts: longer sequences mean more GPU work per launch, so the fixed launch cost stops mattering. And on **indexing throughput the gains largely vanish** — BGE-M3 picks up ~11% at 512 tokens, while pplx-embed-1-0.6b is 926.7 vs 902.3 emb/s at 512 and then *marginally behind* the baseline at 1024 (422.8 vs 423.3) and 4096 (72.2 vs 73.5). To their credit the charts are published rather than summarized away. The most valuable panel is the concurrency one, where Tulip's **p99 tracks at or below the baseline's median** through most of the range — tail compression, which is what an online search path actually cares about.

- **Reusing the LLM engine for embeddings is the highest-leverage decision and the one most teams could copy.** "Batch embeddings are similar to compute-bound prefill, whereas online embeddings, which often run on a few tokens, are computationally similar to memory-bound decode" — so both reuse the existing prefill and decode kernels, and "pplx-embed serving and Qwen3.5 LLM decoding all go through the same kernels." Dense layers are identical because token vectors are processed independently; the deltas are confined to attention, where they add ragged-input support, skip instantiating a KV cache entirely, and dispatch to ragged kernel variants to avoid padding. The prefill/decode framing is the same duality [[Step 01 - Decode is memory-bandwidth-bound (the roofline)|the decode roofline]] formalizes, and the throughput side inherits the machinery documented in [[Amit Shekhar explains how vLLM packs more LLM users onto one GPU through PagedAttention and continuous batching|PagedAttention and continuous batching]] — minus the KV cache, which is the one piece an embedding model does not need. The prefill/decode split is the same axis [[Red Hat frames prefill-decode disaggregation, KV-cache tiering, and speculative decoding as the three llm-d deployment levers for distributed AI inference|Red Hat treats as a deployment lever]], and the economics of packing several small models onto shared accelerators is the problem [[Superlinked's SIE inference engine serves many small models on shared GPUs, fixing the one-model-per-GPU waste of vLLM and TEI|Superlinked's SIE attacks from the other direction]].

- **Two implementation details are the genuinely transferable engineering.** First, **lazy CUDA graph capture**: a graph is needed per (sequence count, token count) configuration, and even after padding token counts to buckets of 64 or 256 that leaves "thousands of graphs that might take multiple minutes to capture." Rather than pay it at startup, each configuration gets an eager warmup on first hit and graph capture on the second, so "multiple minutes of eager work" spreads "across multiple hours" — the tradeoff being p99 damage during startup, in exchange for deployments that scale quickly. Second, **LazyTensor**: a page-locked host buffer plus a `cudaMemcpyAsync` tracked by an event, so `step()` returns a handle rather than blocking, and the single event signals both forward-pass completion *and* result availability on the CPU. Together they mean the CPU enqueues batch N+1 while batch N is still on the device. Also worth noting the scheduler is deliberately dumb — plain FCFS — justified by the measurement that "the linear cost of dense layers is dominant over the quadratic cost of attention," so latency scales with tokens rather than sequences and packing more sequences past GPU saturation (~512 tokens under 1B params) buys nothing.

- **The kernel section quietly reports a result worth keeping: FlashAttention 4 is not uniformly best.** They carry FlashInfer 2, FlashInfer 3 and FlashAttention 4 for ragged attention, and while "in general, we observe that FlashAttention 4 is faster... FlashInfer 3 outperforms it on Qwen-based models at very long sequence lengths," because performance varies with the number and dimension of attention heads. Hence multiple backends maintained and a case-by-case choice at serving time — the practical rebuttal to picking one attention kernel and standardizing. This is [[vLLM throughput benchmarking on H100 — tensor-parallel sizing, speculative decoding, and FP8 KV-cache economics|benchmarking attention backends against each other]] as standing policy rather than a one-off, and it echoes [[agentic kernel development ships to production by profiling the whole model first - 42.3 percent latency cut on Qwen-Image|profiling the whole model before choosing]]. They also mention upstreaming changes to kernels whose dynamic host-side launch inputs were blocking full-model CUDA graph capture.

- **What to hold back on: it is a vendor post benchmarking its bespoke stack against a general-purpose one, and the comparison is not apples to apples.** vLLM serves arbitrary models with arbitrary shapes; Tulip/ROSE serve a handful of known small encoders whose configurations can be enumerated, bucketed, and graph-captured ahead of time. Much of the 3-4x is bought by *specialization*, which the post says outright — "by focusing on specific models and taking ownership of the entire stack" — and the throughput parity is the tell that once you are genuinely GPU-bound the two converge. No cost figures, no multi-GPU numbers, and the CUDA-graph startup penalty is acknowledged but not quantified. The strategic claim is nonetheless the interesting one: vLLM, SGLang and TokenSpeed are all pulling Rust and C++ into their stacks, and Perplexity's two-year Rust bet is offered as evidence the boundary between "engine" and "harness" is where the remaining latency lives — which is where [[agents are the perfect slow searchers because LLM inference cost dominates per-query retrieval latency|the slow-searcher argument]] gets interesting, since millisecond-scale embedding latency only matters when it is *not* dwarfed by downstream LLM inference. On the model side, [[Agent-ModernColBERT trains late interaction on reasoning traces to reach GPT-5 retrieval accuracy with 149M parameters|late-interaction retrieval at 149M parameters]] and [[ColBERT-style semantic search beats grep 70 percent of the time for coding agents while using fewer tokens|ColGREP]] are what these serving numbers are ultimately in service of; [[Philip Kiely details how Baseten built the world's fastest GLM-5.2 API by stacking NVFP4 quantization, KV-aware routing, prefill-decode disaggregation, and MTP speculation|Baseten's GLM-5.2 stack]] is the same own-the-whole-stack argument made for LLM serving.

## External Resources

- Source: [Fast Embeddings on GPUs](https://www.perplexity.ai/hub/blog/fast-embeddings-on-gpus) — Perplexity Engineering, 4 Sep 2026
- Referenced by the post: [Architecting and Evaluating an AI-First Search API](https://www.perplexity.ai/hub/blog/architecting-and-evaluating-an-ai-first-search-api) · [pplx-embed: State-of-the-Art Embedding Models for Web-Scale Retrieval](https://www.perplexity.ai/hub/blog/pplx-embed) · [Improving Unigram Tokenizer CPU Performance](https://www.perplexity.ai/hub/blog/improving-unigram-tokenizer-cpu-performance)
- Baseline and kernels: [vLLM](https://github.com/vllm-project/vllm) (v0.22.0) · [FlashInfer](https://github.com/flashinfer-ai/flashinfer) (2 and 3) · [FlashAttention](https://github.com/Dao-AILab/flash-attention) (4)
- Stack: Rust · [tokio](https://tokio.rs/) · [tonic](https://github.com/hyperium/tonic) gRPC · CUDA graphs · page-locked host memory + `cudaMemcpyAsync`
- Models benchmarked: `pplx-embed-1-0.6b` and [BGE-M3](https://huggingface.co/BAAI/bge-m3), 1x H200, BF16

## Original Content

> [!quote]- Full blog post (Perplexity Engineering, "Fast Embeddings on GPUs", 4 Sep 2026)
> Fast Embeddings on GPUs
>
> This article presents an under-the-hood view of Perplexity's serving infrastructure for this special class of models.
>
> SEP 4, 2026
> AUTHORS: Perplexity Engineering
>
> Fast and accurate search is vital to all of Perplexity, from Search and Computer to our API Platform. Behind the scenes, the heavy lifting is done by embedding and ranking models, which help our systems identify the most relevant results for a given query. We achieve state-of-the-art quality and latency by training and serving our own models, such as pplx-embed.
>
> This article presents an under-the-hood view of Perplexity's serving infrastructure for this special class of models. We discuss our techniques to efficiently address the inference needs of AI-native search, enabling quick prototyping and evaluation of models while powering our exabyte-scale search index. These techniques collectively expand the Pareto frontier of search quality and efficiency, enabling us to serve agents and users with the best possible results at the lowest cost and latency.
>
> ## Embeddings for Search
>
> In a typical search setup, indexed documents are mapped to a high-dimensional vector space using an embedding model and stored in a vector database. By embedding a query using the same model, similar documents can be located by finding the vectors closest to that of the query. This gives rise to two different traffic patterns for an inference engine to serve:
>
> Batch Embedding: when building, expanding or re-indexing the database, bulk documents must be embedded into the vector space, maximizing throughput to minimize cost.
>
> Following vector search, large batches of documents must be scored, striking a balance between throughput and latency.
>
> Online Embedding: when querying the database, a short query must be embedded for lookups, minimizing latency.
>
> We built out our inference infrastructure to leverage as many common components as possible across use cases. Since we typically use small Transformer models to produce embeddings, we share the bulk of the implementation with our LLM inference code: batch embeddings are similar to compute-bound prefill, whereas online embeddings, which often run on a few tokens, are computationally similar to memory-bound decode. We thus reuse our optimized prefill and decode kernels to serve embedding models. As a result, we can achieve massive batch inference throughput with minimal additional engineering work, while preserving low latency for online embeddings workloads.
>
> ## Tulips, Roses, and some Ivy
>
> We expose inference through standardized APIs, both internally and externally through our API Platform. Under the hood, multiple services are involved in the processing of an embedding request:
>
> Ivy is a Rust HTTP gateway that Perplexity services call.
>
> It handles the CPU-side work for requests such as JSON parsing, tokenization, input templating and batch splitting, translating requests to a custom gRPC protocol for downstream servers. This separation allows us to configure certain parameters around tokenization and input formatting without having to touch the heavier inference instances.
>
> Tulip is the inference server interface.
>
> It is a gRPC server implemented with Rust, tokio, and tonic. Tulip receives gRPC inference requests, handling scheduling and batching. It then sends the batches to the ROSE engine, returning completed responses to clients.
>
> ROSE (Runtime-Optimized Serving Engine) implements model inference.
>
> It is primarily defined in Python, providing kernels, layers and definitions for a wide variety of models. ROSE implements the forward passes through models, also providing CUDA graph management specialized for embeddings. It is bridged to Tulip via a step() function, which takes a batch and returns a reference to the computation it performs on the accelerator.
>
> **Fig. 01** — *Serving architecture: an embeddings request enters through Ivy (Rust HTTP gateway, tokenization and batch splitting), is scheduled and batched by Tulip (gRPC, Rust/tokio/tonic), and executed by ROSE on the accelerator.*
> ![[pplx-fast-embeddings-001.png]]
>
> ## Paying Attention Beyond the Kernel
>
> Both Transformer-based models and the underlying Hopper/Blackwell architectures are mature technologies, so embedding inference on the GPU side has converged to a largely optimal implementation across various inference engines. Even so, we discovered additional opportunities for improvement in runtimes and harnesses that expose the models end-to-end to a client. In particular, we found that we can improve latencies by carefully managing CUDA graphs and by building a LazyTensor abstraction to asynchronously track a GPU-side result in the native Rust engine. We implemented these features in Tulip, so it could effectively interface with the model implementations of ROSE.
>
> ## Tulip
>
> We designed Tulip to be as lightweight of an interface over our model serving as possible. It handles incoming requests in Tokio async tasks, maintaining a pool of requests it tracks and schedules batches from to dispatch to the accelerator. The scheduling mechanism in Tulip is very simple: requests accumulate while Tulip is dispatching work or waiting for results. From the accumulated requests, sequences are picked on a first-come, first-served basis to be run through the model.
>
> The simple scheduling mechanism is motivated by an observation on model performance. For small embedding models, at the sequence lengths we serve for, we noticed that the linear cost of dense layers is dominant over the quadratic cost of attention. Thus, latency is mostly proportional to the number of tokens, not the number of sequences. Consequently, once a batch is large enough to saturate the GPU, which is around 512 tokens on a model under one billion parameters, packing more sequences into it does not improve efficiency.
>
> To effectively interface with the model, Tulip relies on CUDA graphs and lazy result tracking to overlap GPU and CPU work and fully utilize the available resources.
>
> ### CUDA Graph Management
>
> Running the forward pass of a model involves both CPU-side and GPU-side work. The CPU is responsible for scheduling batches and launching kernels with the appropriate parameters, while the GPU executes the relevant matrix multiplication, attention, norm or activation kernels. For high-throughput workloads such as training and reindexing, CPU-side overheads are negligible because batch sizes and GPU-side latency are both large. However, on smaller batch sizes, CPU-side work can outweigh GPU-side work.
>
> **Fig. 02** — *Eager forward pass — host invocations interleaved with device kernels. On small batches the CPU-side launch work outweighs the GPU work.*
> ![[pplx-fast-embeddings-002.png]]
>
> To mitigate overheads, instead of launching independent kernels, a CUDA graph can be built to capture the metadata required to launch all the kernels of a forward pass with a single call to the CUDA driver. This eliminates the need to re-run expensive Python and PyTorch code for the configurations CUDA graphs can be captured for.
>
> Across each model, we track an inflection point, determining the minimum number of tokens at which GPU execution is more expensive than CPU-side kernel launch. Because embedding models are small, we observe that this inflection point comes at batches of thousands of tokens and tens of sequences. Some attention implementations rely on dynamic host-side inputs to configure kernel launches, preventing full-model prefill/dense CUDA graphs. We upstreamed changes to relevant kernels to enable them in our inference engine.
>
> To address overheads, we build whole-model CUDA graphs for all embedding models and overlap CPU work with GPU work. Since CUDA graphs minimize the CPU-side overheads, once a graph is launched, we have free time to kick off and enqueue the execution of the next batch whenever it is available. The results of the pending batch are tracked with a LazyTensor, which allows an async task in Rust to block until the previous batch finishes execution. CUDA graphs help low-latency serving by ensuring we are not held back by the cost of kernel launches and facilitate improved scheduling in the high-throughput case as they free up the CPU to do work on the next batch sooner.
>
> **Fig. 03** — *The same forward pass captured as a CUDA graph: all kernel launches issued with a single call to the CUDA driver, eliminating the per-launch Python and PyTorch cost.*
> ![[pplx-fast-embeddings-003.png]]
>
> CUDA graphs must be captured for each distinct configuration, which for embeddings means a graph per sequence count and token count combination. Since this grid is expansive, we pad token counts to buckets that are multiples of 64 or 256. This still results in thousands of graphs that might take multiple minutes to capture for a typical model. The cost of capture comes from two sources: an eager forward pass that must be executed to compile kernels and set up buffers for various kernels that need them, followed by the capture run which re-executes Python code.
>
> We mitigate startup costs by capturing CUDA graphs lazily as the engine serves. We keep track of each configuration and ensure that it goes through an eager warmup run before triggering graph capture and replay on the second hit. All subsequent executions of the same graph configuration then go through CUDA graph replay. Lazy graph capture has an impact on p99 latencies during startup; however, it is valuable in spreading multiple minutes of eager work across multiple hours. Quicker startup times allow us to better scale and manage embedding deployments.
>
> ### Lazy Tensors
>
> Through CUDA, GPU work is asynchronous. Since launching a kernel asynchronously enqueues it on a stream, host code must explicitly synchronize to read out the resulting vectors. To facilitate a higher degree of parallelism and to be able to kick off future batches while waiting for the previous one to complete on the device, we rely on a LazyTensor abstraction to track values.
>
> The LazyTensor tracks a host buffer in page-locked memory and a cudaMemcpyAsync operation via an event copying data from the device. It is kicked off after the launch of the forward pass on the same stream. Since the copy operation must wait for all prior kernels on the stream to execute, the associated event tracks both the completion of the forward pass and the availability of the result on the CPU.
>
> **Fig. 04** — *LazyTensor execution — a page-locked host buffer plus a `cudaMemcpyAsync` tracked by an event, so the event signals both forward-pass completion and result availability on the CPU.*
> ![[pplx-fast-embeddings-004.png]]
>
> We leverage LazyTensors in our ROSE encoder engine to overlap GPU and CPU work. Instead of each step() call running the CUDA graph and waiting for it to finish, step() returns a LazyTensor to asynchronously track its result. Coupled with CUDA graphs, this helps us achieve low latencies and better throughput.
>
> **Fig. 05** — *CPU preparation and synchronization overlapping successive batches: with the graph launched and the result tracked lazily, the CPU is free to enqueue the next batch immediately.*
> ![[pplx-fast-embeddings-005.png]]
>
> ## ROSE
>
> We adapted our ROSE engine, which we originally built for LLM serving, to also handle the execution of embedding models. To minimize the effort needed to support embedding models, ROSE aggressively reuses code between LLMs and embeddings. For instance, pplx-embed serving and Qwen3.5 LLM decoding all go through the same kernels. This sharing allows us to easily serve an embedding model that was originally fine-tuned from an LLM for prototyping, evaluation, and production inference.
>
> For dense layers, embedding and LLM inference are identical since token vectors are processed independently. In attention layers, differences are handled by adding support for ragged inputs, alongside the paged prefill and decode setups required by LLMs. When serving an embedding model, we do not instantiate a KV cache and dispatch to variations of attention kernels which support the ragged format to avoid padding. The supporting conversion and calibration routines are also shared with the LLMs.
>
> ## Ivy
>
> Ivy, our inference HTTP proxy layer, also plays an important role in performance. Because request payloads vary in production, routing individual requests to individual replicas can cause load imbalance. Ivy splits large-batch requests into chunks and load-balances them between replicas, improving utilization and smoothing latency. Our recent work on in-house unigram tokenization, fully rolled out in Ivy, drastically improves latencies over off-the-shelf tokenizers.
>
> ## ...but the Kernels Still Matter
>
> ROSE supports a variety of attention backends. Different kernels may be suited to specific problem sizes. Over time, we integrated FlashInfer 2, FlashInfer 3 and FlashAttention 4 kernels to implement ragged attention.
>
> **Fig. 06** — *Attention kernel performance by model shape and problem size across FlashInfer 2, FlashInfer 3 and FlashAttention 4 — the basis for keeping multiple backends and choosing case by case.*
> ![[pplx-fast-embeddings-006.png]]
>
> In general, we observe that FlashAttention 4 is faster. However, FlashInfer 3 outperforms it on Qwen-based models at very long sequence lengths. Since performance and tuning can vary with the number and dimension of attention heads, we maintain support for multiple configurations and make a case-by-case decision when serving.
>
> ## Benchmarks
>
> We benchmark against vLLM v0.22.0, running inference on BF16 precision on actual model weights and inputs derived from evaluation datasets. All timing runs were preceded by warmup runs which verified that the divergence in cosine similarity is within 0.1%.
>
> ### Low-Latency Embeddings (p50 / p90 / p99 / max ms)
>
> We report runtimes for pre-tokenized request batch size 1, fully sequential requests, sequence lengths of 128, 512, and 4096 tokens.
>
> **Fig. 07** — ***Embeddings request latencies** (batch size 1, sequential, 10K requests, 1x H200, BF16). BGE-M3 at 128 tokens: Tulip p50 **1.53ms** vs baseline 4.60ms and p99 **1.67ms** vs 7.96ms — roughly 3x on median and ~4.8x on tail. The advantage compresses as sequences grow: at 4096 it is 9.57 vs 11.71 (p50). pplx-embed-1-0.6b shows the same shape, 1.88 vs 4.94 at 128 narrowing to 15.41 vs 16.15 at 4096.*
> ![[pplx-fast-embeddings-007.png]]
>
> ### Low-Latency Scoring (p50 / p90 / p99 / max ms)
>
> Pre-tokenized request batch sizes 5, 25, and 50, sequence length of 512 tokens.
>
> **Fig. 08** — ***Scoring latencies** at batch sizes 5, 25 and 50, sequence length 512.*
> ![[pplx-fast-embeddings-008.png]]
>
> ### High-Throughput Embeddings (emb/s)
>
> Request batch size 100, four concurrent processes submitting requests, sequence lengths of 512, 1024, and 4096 tokens.
>
> **Fig. 09** — ***Indexing throughput** (batch size 100, 4 concurrent requests). The honest result: BGE-M3 gains ~11% at 512 (1499.3 vs 1342.2 emb/s) and ~7.5% at 4096, while pplx-embed is effectively at parity — 926.7 vs 902.3 at 512, then 422.8 vs 423.3 at 1024 and 72.2 vs 73.5 at 4096, i.e. marginally *behind* the baseline once sequences are long.*
> ![[pplx-fast-embeddings-009.png]]
>
> ### High-Concurrency Embeddings (p50 / p90 / p99 / max ms)
>
> Sequence length 512, batch size 1, but we send 1, 2, 4, 8, and 16 concurrent requests. This benchmark also includes tokenization costs through Ivy, alongside the networking overhead between Ivy and Tulip.
>
> **Fig. 10** — ***Concurrent-workload latencies** (seq len 512, batch size 1, 1→16 concurrent requests, including Ivy tokenization and network overhead). Tail compression is the clearest win: on pplx-embed at 16 concurrent, baseline p99 reaches ~50ms while Tulip p99 sits near 35ms and Tulip p50 near 25ms — Tulip's p99 tracks at or below the baseline's *median* through most of the range.*
> ![[pplx-fast-embeddings-010.png]]
>
> ## Conclusion and Future Work
>
> The serving infrastructure composed of Ivy, Tulip and ROSE allows us to serve embeddings for Perplexity with lower latency and better throughput, resulting in more accurate search at a reduced cost compared to off-the-shelf solutions.
>
> By focusing on specific models and taking ownership of the entire stack, we obtain the freedom necessary to strike an effective balance between performance and flexibility, mixing highly re-usable and performant Rust primitives alongside more generic Python modeling code. Many open-source inference engines, such as vLLM, SGLang, and TokenSpeed, are integrating languages like Rust and C++ into their stack. We've invested in Rust over the past two years and have reaped great rewards in both performance and maintainability. By sharing most of the embedding implementation with our LLM serving stack, we derive gains in throughput as well, without requiring significant engineering effort to be spent on the maintenance of embedding models.
>
> As models evolve, we will continue to improve each layer of our stack to reduce both CPU-bound and GPU-bound latencies. Our custom gRPC-based protocols within Ivy and Tulip allow us to tweak communication to reduce network latencies, while ROSE provides a foundation to improve computational throughput. Additionally, as support for free-threaded Python grows throughout the ecosystem, we will be able to further improve Python-Rust interoperability to reduce overheads.
>
> ## References
>
> - Architecting and Evaluating an AI-First Search API
> - pplx-embed: State-of-the-Art Embedding Models for Web-Scale Retrieval
> - Improving Unigram Tokenizer CPU Performance
> - vLLM
> - FlashInfer
> - FlashAttention
