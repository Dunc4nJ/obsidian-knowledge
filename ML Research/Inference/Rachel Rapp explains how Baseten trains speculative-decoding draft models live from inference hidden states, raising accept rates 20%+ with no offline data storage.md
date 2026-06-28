---
created: 2026-06-26
description: Rachel Rapp (Baseten) walks through a distributed pipeline that trains speculative-decoding draft models (EAGLE-3, DFlash) "on the fly" by extracting hidden states directly from the live inference path, rather than saving them offline. Built into the Baseten Inference Stack's Speculation Engine, it sidesteps storage (a single Kimi K2 sample can exceed 2GB), compute, alignment-drift, and zero-data-retention bottlenecks at once. Reported result: median accept-rate +20%, with some constrained traffic seeing 100%+ gains in accept length — directly larger SpecDec speedups in production. Credits the work to engineer Mahmoud Hassan.
source: https://x.com/rachelrapp/status/2070493769690910913
type: learning
---

## Key Takeaways

- **The core idea: train the draft model from hidden states *as inference happens*, never writing them to disk.** Speculative decoding speedups depend on the draft model's **accept rate** — how often its cheap draft tokens survive the target model's verification step. Keeping that draft aligned with diverse base models and shifting traffic is the hard, ongoing engineering problem. Baseten's answer is a distributed training pipeline that extracts hidden states *directly from the live inference path* and trains the draft model continuously, eliminating offline data storage entirely. This is the "train task-specific speculators on representative traffic" idea from [[Philip Kiely details how Baseten built the world's fastest GLM-5.2 API by stacking NVFP4 quantization, KV-aware routing, prefill-decode disaggregation, and MTP speculation]] turned into a standing, automated system.

- **It kills four production bottlenecks at once — and the storage number is the headline.** (1) **Storage**: saving hidden states offline doesn't scale — a *single sample on Kimi K2 can exceed 2GB*, and full draft training needs millions of them. (2) **Compute**: regenerating those hidden states is prohibitively expensive for large models at long context. (3) **Alignment drift**: fine-tuning or RL on the base model degrades the draft's accept rate unless the draft is retrained alongside it. (4) **Data compliance**: offline storage is a non-starter in **zero-data-retention (ZDR)** environments. Training on live hidden states removes the stored-data dependency that causes all four.

- **The reported payoff is concrete: median accept-rate +20%, some constrained traffic +100% in accept length.** Higher accept rate / longer accepted drafts translate *directly* into larger speculative-decoding speedups and better serving efficiency — speculative decoding is already a 2–3x throughput/latency lever (see [[LLM optimization interview prep maps Flash Attention, ZeRO, speculative decoding, and MoE across training and inference]]), and accept rate is the multiplier on top of it. Continuous retraining also cuts the time to stand up a draft model for a *new* base model and lets existing drafts keep adapting to custom traffic.

- **The hard part is doing this without slowing inference — solved by pushing all I/O off the serving thread.** The pipeline lives natively inside the **Baseten Inference Stack's Speculation Engine**, on top of the same optimized serving engine, and stays compatible with existing perf features (single-CUDA graphs, the overlap scheduler). To avoid latency spikes, *all network comms and data buffering are offloaded to a dedicated background process*, with careful **CUDA-event synchronization** on the overlap-scheduler loop so hidden-state extraction never stalls the main execution thread.

- **Memory discipline: cost scales with `max_num_tokens_per_iter`, not `max_sequence_length`.** On the inference side, raw *unfiltered* iteration data is shipped and only aggregated on the receiver — so the extra footprint is proportional to per-iteration token count, *not* sequence length, preserving room for long-context inference. The same invariant holds on the training side. This "bound the overhead to the iteration, not the request" principle echoes the KV-cache memory management in [[paged attention applies OS virtual memory paging to KV cache and unlocks 2-4x LLM serving throughput]].

- **The training path is fully decoupled from inference, using `mmap`-backed paged memory and late pinning.** Data loaders are split out from the core training loop; training data is buffered into **paged memory via `mmap`-backed arrays**. Rather than materializing a full request in device or pinned memory, the request is assembled in *pageable* memory and **only pinned just before it enters the training loop** — minimizing scarce pinned/GPU memory while keeping the loop fed.

- **Two infrastructure choices do the heavy lifting: UCXX for transport, Trio for fault tolerance.** **UCXX** (Python bindings) handles asynchronous **RDMA** transfers of large tensors between nodes. **Trio** (structured concurrency) builds retry/recovery paths so that at tens-to-hundreds of nodes, routine hardware failures and preemptions stay contained instead of disrupting inference. A neat detail: they run Trio's **guest-loop mode** integrated with PyTorch sync points like `torch.cuda.synchronize()`, getting an async loop *without spawning new threads* — minimizing **GIL contention**. A reminder that frontier inference performance is as much a distributed-systems and concurrency problem as an ML one.

- **Attribution:** Rachel Rapp credits the engineering to **Mahmoud Hassan** (no X account; findable via the Baseten blog / LinkedIn).

## External Resources

- [The Baseten Inference Stack](https://www.baseten.co/resources/guide/the-baseten-inference-stack/) — the serving runtime / Speculation Engine this pipeline is built into
- [Boosting MTP acceptance rates in Baseten's speculation engine](https://www.baseten.co/blog/boosting-mtp-acceptance-rates-in-baseten-speculation-engine/) — Baseten's prior work on the same accept-rate objective
- [EAGLE / EAGLE-3 (SafeAILab)](https://github.com/SafeAILab/EAGLE) — the draft-model architecture referenced
- [Fast Inference from Transformers via Speculative Decoding (Leviathan et al., 2023)](https://arxiv.org/abs/2211.17192) — foundational speculative-decoding paper; defines the draft-and-verify scheme accept rate sits on top of
- [UCXX (RAPIDS)](https://github.com/rapidsai/ucxx) — Python bindings for asynchronous RDMA tensor transfers used here
- [Trio — structured concurrency for Python](https://trio.readthedocs.io/) — the async framework used for retry/recovery and guest-loop integration

## Original Content

> [!quote]- Source Material — @rachelrapp (Rachel Rapp), X Article "Live draft model training for speculative decoding", Jun 26 2026 · 13 likes
>
> Live draft model training for speculative decoding
>
> Draft models, such as EAGLE-3 and DFlash, have become a widely adopted technique for accelerating large language model (LLM) inference, leading to 2-3x higher throughput and lower latency. However, keeping these draft models aligned with diverse base models and dynamic traffic patterns remains a significant engineering challenge.
>
> We built a distributed training pipeline to address this. The pipeline extracts hidden states directly from live inference and uses them to train the draft model on the fly, eliminating the need to store data offline.
>
> Where rolled out, it has produced a median increase in accept rate of 20%, with some constrained traffic patterns seeing 100%+ increases. These gains translate directly into larger speculative decoding speedups and better serving efficiency.
>
> Note: Shout out to Mahmoud Hassan, who does not have an X account, for the work here. He's both an incredible engineer and a lovely person to work with. Find him on the Baseten blog or LinkedIn!
>
> # Eliminating traditional bottlenecks
>
> Traditional approaches to training draft models are bottlenecked by several pain points:
>
> 1. Storage overhead: Saving hidden states for offline training is unscalable at production volumes. A single sample on Kimi K2 can exceed 2GB, and full draft training requires millions of them.
>
> 2. Compute bottlenecks: Generating the hidden states required for draft model inputs can be prohibitively expensive, particularly for massive models operating at long context lengths.
>
> 3. Alignment drift: Fine-tuning or reinforcement learning (RL) on the base model often degrades the draft model's accept rate unless it is retrained alongside it.
>
> 4. Data compliance: Storing data for offline training can be difficult in zero data retention (ZDR) environments.
>
> To overcome each of these bottlenecks, we built a distributed training pipeline that uses real-time hidden states directly from inference to train draft models on the fly, while adding minimal overhead to the serving path.
>
> This architecture bypasses the need for data storage entirely. It has significantly reduced the time required to train draft models for new base models, while also allowing those models to continuously adapt to custom traffic.
>
> Where incorporated, we observed a median accept rate increase of 20%, with some constrained traffic patterns seeing a 100%+ increase in accept length, leading to even faster SpecDec in production and more efficient workloads.
>
> # Engineering draft model training for minimal overhead
>
> ## Optimizing the inference path: GPU execution, memory, and networking
>
> We built the training pipeline natively within the Baseten Inference Stack as part of our Speculation Engine, so it runs directly on top of the same highly optimized inference engine that powers our serving path. This was essential, since the system needed to continuously extract training data without slowing down inference. The training pipeline is fully compatible with our existing performance features, including single-CUDA graphs and the overlap scheduler.
>
> To avoid latency spikes during inference, we offload all network communication and data buffering to a dedicated background process. Paired with careful CUDA event synchronization on the overlap scheduler loop, this allows us to continuously extract hidden states without stalling the main execution thread.
>
> To save memory, the inference side sends unfiltered iteration data, which is only aggregated on the receiver side. The added space usage is proportional to max_num_tokens_per_iter, not max_sequence_length, which preserves valuable space for long context inference.
>
> ## Optimizing the training path
>
> On the training side, we completely decoupled the data loaders from the core training loop. The pipeline uses mmap-backed arrays to buffer training data directly into paged memory.
>
> Similar to the inference side, the added GPU and pinned memory usage is proportional to max_num_tokens_per_iter, which preserves valuable space for the training process. Instead of materializing full request data in device or pinned memory, the full request is assembled in pageable memory and only pinned just before it enters the training loop.
>
> ## Additional tools for infrastructure handling
>
> We also want to highlight a few frameworks that we used in this project:
>
> - UCXX: Moving large tensors between nodes requires specialized networking infrastructure. We used UCXX Python bindings to handle asynchronous RDMA transfers efficiently.
>
> - Trio (structured concurrency): At the scale of tens or hundreds of nodes, hardware failures and preemptions are part of normal operation. We used Trio to build retry and recovery paths that contain those failures, preventing a few dropped nodes or transient network failures from disrupting inference. Furthermore, we integrated Trio's guest loop mode with PyTorch synchronization points such as torch.cuda.synchronize() to run an async loop without creating new threads, thereby minimizing GIL contention.
>
> If you want to leverage live draft model training for your inference workloads, reach out!

---

*Source: [Live draft model training for speculative decoding](https://x.com/rachelrapp/status/2070493769690910913) — X article by [@rachelrapp](https://x.com/rachelrapp) (Rachel Rapp, Baseten), Jun 26 2026. Engineering work credited to Mahmoud Hassan.*
