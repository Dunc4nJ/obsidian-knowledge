---
created: 2026-06-23
description: Philip Kiely (author of "Inference Engineering") walks through how Baseten built the world's fastest API for GLM-5.2 — 280+ tok/s on NVIDIA Blackwell — by stacking five inference optimizations: shared-DSA architecture support, an in-house NVFP4 quantization from FP8 (quality-neutral on BFCL), KV-aware routing and prefill/decode disaggregation via NVIDIA Dynamo (2x TPS), and Multi-Token Prediction speculation. The framing: open weights now match the closed frontier on quality and price, so the moat moved to inference engineering.
source: https://x.com/philipkiely/status/2069212319746506968
type: learning
---

## Key Takeaways

- **The thesis: open weights have matched the closed frontier on quality *and* price, so the differentiator moved to inference engineering.** GLM-5.2 delivers performance comparable to GPT-5.5 and Opus 4.8 at 70–80% lower token cost, which Kiely calls the biggest open-model news since DeepSeek-R1. But "smart and inexpensive" isn't sufficient — a production model also has to be fast, reliable, and available at scale, and "delivering on the promise of frontier open intelligence requires exceptional inference." Baseten's claim to that exceptional inference is the world's fastest GLM-5.2 API at 280+ tok/s (Artificial Analysis). This is the same argument as [[Open models now match closed frontier models on core agent harness tasks at a fraction of the cost]], and it's notable that the author is Philip Kiely, who literally wrote the book reviewed in [[Joe Barrow reviews Philip Kiely's Inference Engineering as the reference work he wishes he had in 2023, with a curated what-to-read-next list]] — this post is that book's "Techniques" chapter executed in production.

- **The speedup is a *stack* of five independent levers, not one trick.** (1) Updating Baseten's custom inference engine to support GLM-5.2's **shared DSA** weights; (2) an in-house **NVFP4 quantization** from the original FP8 weights; (3) **KV-aware routing** for high cache-hit rates and lower prefill burden; (4) **prefill/decode disaggregation** for 2x TPS; (5) **Multi-Token Prediction (MTP)** speculation. These map almost one-to-one onto the day-to-day inference levers catalogued in [[LLM optimization interview prep maps Flash Attention, ZeRO, speculative decoding, and MoE across training and inference]] — quantization, KV cache, speculative decoding, and MoE serving.

- **The model itself: GLM-5.2 is a 744B-parameter MoE (40B active), MIT-licensed, 1M-token context, with thinking and non-thinking modes.** It's architecturally close to GLM-5.1 but now uses **shared DSA weights**, which Baseten had to add support for in its customized runtime. Like other modern frontier models it's a sparse mixture-of-experts — the same architectural family surveyed in [[twenty-six papers capture ninety percent of the alpha behind modern LLMs from attention through reasoning and mixture of experts]]. Kiely's caveat is the now-standard one: benchmark scores are necessary but not sufficient; in practice GLM-5.2 "meets or exceeds" them for coding and agentic work.

- **NVFP4 is positioned as a quality-neutral speedup, not a quality/speed trade.** Baseten quantized from FP8 down to **NVFP4** (a 4-bit float format with *dual scale factors* to preserve dynamic range) using NVIDIA ModelOpt, targeting NVIDIA Blackwell tensor cores. Calibration focused on agentic patterns: on the **BFCL** function-calling benchmark, FP8 and NVFP4 scored within the benchmark's margin of error. The win is on *both* axes — faster tensor cores (better TPS) and reduced VRAM-bandwidth pressure (better TTFT). The same NVFP4-on-Blackwell low-precision recipe shows up on the *training* side in [[Cursor Composer 2]], which uses MXFP8 and NVFP4 for its MoE layers.

- **For reasoning models the metric that matters is TTFAT, not TTFT — and the breakdown is striking.** Time-to-first-*answer*-token combines prefill latency with the TPS of the reasoning trace. Baseten's chart shows that of a 7.9s average to the first answer token, **7.1s was generating reasoning tokens and only 0.8s was processing the input sequence.** Implication: for thinking models, decode throughput (and thus speculation) dominates perceived latency far more than prefill does. KV-aware routing — built on NVIDIA Dynamo to send requests to replicas that already hold the relevant prefix in cache — still matters, cutting TTFT to ~800ms by skipping redundant prefill on shared sequences. This is the production-routing complement to the KV-cache memory management in [[paged attention applies OS virtual memory paging to KV cache and unlocks 2-4x LLM serving throughput]].

- **Prefill/decode disaggregation is called out as the single highest-impact optimization (2x TPS).** The two phases have opposite resource profiles: **prefill is compute-bound** (processes the input, builds KV cache, emits the first token → sets TTFT); **decode is memory-bound** (generates subsequent tokens → sets TPS). Running them on the same node forces them to compete. Disaggregating onto separate engines lets you (a) provision asymmetrically — usually more prefill engines than decode; (b) tune each engine's config independently; and (c) eliminate contention. KV reuse still applies, so prefill workers only handle genuinely novel input. The hard part is low-overhead cross-engine communication; NVIDIA Dynamo supplies the plumbing — a prefill queue for saturation, conditional-disaggregation thresholds on post-cache input length and queue depth, and NIXL-based KV transfer with a kernel that transposes KV blocks when prefill and decode run different tensor-parallel configs.

- **MTP speculation is lossless throughput, and the production knobs beat the benchmark.** GLM-5.2 ships an improved Multi-Token Prediction layer that lowers draft-token cost and raises acceptance; because every speculation method has a verification step, it's a *lossless* TPS optimization. Baseten swept draft-sequence lengths to balance long drafts against acceptance rate. Crucially, dedicated single-tenant deployments can exceed the public benchmark by training **task-specific speculators** on representative traffic, getting more consistent cache hits, tuning the prefill:decode ratio to the actual traffic profile, and tuning parallelism/batching for the desired latency/throughput point. (In the thread's lone author follow-up, Kiely notes MTP work is still iterating and points to Z.ai's launch blog for implementation detail.)

## External Resources

- [GLM-5.2 on Baseten Model APIs](https://www.baseten.co/library/glm-52/) — the deployed model API discussed in the post
- [GLM-5.2 by Z.ai — launch blog](https://z.ai/blog/glm-5.2) — architecture and MTP implementation detail (Kiely's pointer for MTP stats)
- [The Baseten Inference Stack](https://www.baseten.co/resources/guide/the-baseten-inference-stack/) — the runtime/engine context for these optimizations
- [Boosting MTP acceptance rates in Baseten's speculation engine](https://www.baseten.co/blog/boosting-mtp-acceptance-rates-in-baseten-speculation-engine/) — prior MTP work referenced
- [Baseten savings calculator](https://www.baseten.co/resources/calculator/) — estimate the 70–80% cost delta on your workload
- [Talk to Baseten](https://www.baseten.co/talk-to-us/) — dedicated high-volume deployments

## Original Content

> [!quote]- Source Material — @philipkiely (Philip Kiely), X Article "How we built the world's fastest API for GLM-5.2", Jun 23 2026 · 18 likes
>
> ## Article: How we built the world's fastest API for GLM-5.2
>
> *Cover*
> ![[philipkiely-506968-001.jpg]]
>
> [GLM-5.2](https://www.baseten.co/library/glm-52/) is the biggest news in open models since DeepSeek-R1.
>
> It's easy to see why. GLM-5.2 delivers comparable performance to GPT 5.5 and Opus 4.8 at a fraction of the cost, generally 70-80% less expensive on a pure token basis (use our [calculator to estimate savings for your workload](https://www.baseten.co/resources/calculator/)).
>
> But a model has to be more than just smart and inexpensive. To be useful in production, a model needs to be fast, reliable, and available at scale. Delivering on the promise of frontier open intelligence requires exceptional inference.
>
> Accordingly, we built the world's fastest API for GLM-5.2, currently serving over 280 tokens per second as measured by Artificial Analysis.
>
> *GLM-5.2 runs at SOTA speeds on Baseten model APIs, measured by Artificial Analysis June 22, 2026*
> ![[philipkiely-506968-002.jpg]]
>
> *Performance is excellent across both TTFT and TPS, measured by Artificial Analysis June 22, 2026*
> ![[philipkiely-506968-005.jpg]]
>
> We achieved this performance by leveraging a number of techniques across the entire inference process by:
>
> - Updating our custom inference engine to implement shared DSA for the GLM-5.2 architecture.
>
> - Running and calibrating an in-house NVFP4 quantization from the original FP8 weights that demonstrates equivalent quality on agentic benchmarks like BFCL.
>
> - Ensuring high KV cache hit rates via KV-aware routing built with NVIDIA Dynamo tools for lower prefill burden and improved TTFT on requests with repeated prefixes.
>
> - Achieving a 2x higher TPS for observed workload shapes by running disaggregated inference built with the NVIDIA Dynamo toolkit.
>
> - Improving TPS further via speculation by implementing support for GLM-5.2 Multi-Token Prediction heads.
>
> You can experience this performance for yourself with [GLM-5.2 on Baseten Model APIs](https://www.baseten.co/library/glm-52/). We also have GLM-5.2 available as a dedicated deployment for high-volume workloads.
>
> ## GLM-5.2 Overview
>
> [GLM-5.2 by Z.ai](https://z.ai/blog/glm-5.2) is a 744B parameter frontier LLM that excels at agentic tasks (especially coding) and supports up to a 1 million token context window. It uses a similar architecture to its predecessor, GLM-5.1: mixture of experts (40B active parameters), non-thinking and thinking modes, and a fully open MIT license. While GLM-5.2 shares a lot in common with GLM-5.1, it now uses shared DSA weights, which we implemented support for in our customized runtime engine.
>
> *GLM-5.2 offers frontier performance across tasks. Image from Z AI.*
> ![[philipkiely-506968-003.jpg]]
>
> GLM-5.2 has great benchmark scores, but by now AI builders know that there is more to a model's utility than its performance on standard evals. In practice, GLM-5.2 meets or exceeds the capabilities suggested by its benchmarks. It's a genuinely great model for writing code, operating agents, and other frontier language model tasks.
>
> *Tech leaders are embracing GLM-5.2 as a new high water mark of frontier intelligence on open models*
> ![[philipkiely-506968-004.jpg]]
>
> *Notion offers GLM-5.2 via Baseten*
> ![[philipkiely-506968-009.jpg]]
>
> ## High-quality NVFP4 quantization for Blackwell GPUs
>
> We run our model APIs on NVIDIA Blackwell GPUs with a customized inference engine within the [Baseten Inference Stack](https://www.baseten.co/resources/guide/the-baseten-inference-stack/). The selected runtime uses NVFP4 weights for maximum performance. From the original FP8 weights, we performed an in-house quantization to NVFP4 using NVIDIA ModelOpt. NVFP4 is a 4-bit floating point data format by NVIDIA that uses dual scale factors to retain high dynamic range and preserve model quality.
>
> In our calibration and testing of the quantized model, we focused on ensuring that GLM-5.2 performs faithfully on common patterns for agents. On the BFCL function calling benchmark, we observed roughly equivalent performance between the native FP8 weights and our NVFP4 quantization, with scores across runs within the margin of error for the benchmark.
>
> NVFP4 quantization improves performance on both time to first token and tokens per second by unlocking faster tensor cores and reducing burden on VRAM bandwidth.
>
> ## Cache-aware routing with NVIDIA Dynamo
>
> GLM-5.2 is particularly well suited for long context requests and complex agentic tasks. These workloads generally have very long input sequences. By re-using KV cache between requests, we can skip expensive prefill for shared sequences.
>
> We generally talk about KV cache re-use in the context of time to first token (TTFT). However, reasoning models like GLM-5.2 generally care more about time to first answer token (TTFAT), which combines TTFT with some TPS for the reasoning sequence.
>
> This chart shows that of the 7.9 second average to generate the first answer token, 7.1 of those seconds were spent generating reasoning tokens versus only 0.8 seconds spent processing the input sequence.
>
> *Time to First Answer Token for GLM-5.2, measured by Artificial Analysis June 22, 2026*
> ![[philipkiely-506968-006.jpg]]
>
> Still, bringing the TTFT down to 800 ms is important for the overall responsiveness and throughput of the system. In large-scale production deployments, KV cache is split across various independent replicas. We use tools from NVIDIA Dynamo to route incoming requests.
>
> *KV-aware routing sends requests to replicas that already have relevant context cached, saving time by avoiding redundant prefill computation.*
> ![[philipkiely-506968-007.jpg]]
>
> Exact cache hit rates on a multi-tenant API depend on the exact traffic profile at any given time. Thus far, we're observing high hit rates across fairly heterogeneous traffic, which reduces load on prefill and improves end-to-end performance.
>
> ## Prefill-decode disaggregation with NVIDIA Dynamo
>
> One of the highest-impact optimizations we made to our performance is disaggregating prefill and decode for GLM-5.2.
>
> There are two distinct phases of LLM inference:
>
> - Prefill: The compute-bound process that processes the input sequence, builds the KV cache, and generates the first output token. Prefill performance determines TTFT.
>
> - Decode: The memory-bound process of generating subsequent output tokens. Decode performance determines TPS.
>
> Traditionally, a single GPU node handles both prefill and decode. With disaggregation, these workloads are run on separate engines.
>
> *Disaggregated inference uses separate prefill and decode workers*
> ![[philipkiely-506968-008.png]]
>
> This provides several benefits:
>
> - Prefill and decode run independently without competing for resources
>
> - We can allocate unequal resources between prefill and decode as needed (generally, we provision more prefill engines than decode engines)
>
> - The inference engines running prefill and decode can run with different configurations optimized for the demands of their specific piece of the inference pipeline.
>
> KV cache is still re-used whenever possible, meaning that prefill workers are only used to process novel input sequences.
>
> Much of the challenge in implementing PD disaggregation is in reliable, low-overhead communication between and orchestration of the prefill and decode engines. NVIDIA Dynamo provides a developer toolkit for implementing essential components of disaggregation:
>
> - A prefill queue to hold requests when all prefill engines are saturated.
>
> - Robust support for conditional disaggregation, with prefill routing based on configurable thresholds for input sequence lengths after prefix cache and prefill queue size.
>
> - Efficient NIXL-based KV transfer from prefill to decode engines with a kernel to transpose KV blocks between layouts when the engines have different TP configurations.
>
> In head-to-head benchmarks between aggregated and disaggregated deployments of GLM-5.2, we observed 2x higher tokens per second on disaggregated inference.
>
> ## Higher TPS with Multi-Token Prediction
>
> GLM-5.2 shipped with an improved Multi-Token Prediction (MTP) layer that reduces the cost of generating draft tokens and increases the acceptance rate of these tokens.
>
> As a review, MTP is one of several methods for speculation. Speculation is the process of generating more than one token per forward pass through the model with the goal of improving TPS. Thanks to the verification step in all algorithms, speculation methods are lossless performance optimizations.
>
> Using these MTP layers to generate draft tokens, we tested a variety of sequence lengths to find the right balance between generating long sequences and maintaining high acceptance rates. We've done [a lot of work on MTP over the last few months](https://www.baseten.co/blog/boosting-mtp-acceptance-rates-in-baseten-speculation-engine/), and there is still headroom to unlock in the speculation we're using for GLM-5.2.
>
> ## Running GLM-5.2 in production
>
> The natural question when looking at these kinds of benchmark results is whether or not the same performance can actually be maintained in production.
>
> In fact, not only can we deliver this performance in production, but we can achieve even better workload-specific performance for large-scale dedicated deployments of GLM-5.2. Levers include:
>
> - Using task-specific speculators trained on input and output sequences representative of expected production data.
>
> - Achieving more consistent cache hits from single-tenant traffic.
>
> - Tuning disaggregation configuration to match the ratio of prefill and decode engines to traffic profile.
>
> - Configuring parallelism and batching settings to achieve desired tradeoff between latency and throughput.
>
> [Get in touch with our team](https://www.baseten.co/talk-to-us/) for dedicated deployments of GLM-5.2, or get started testing the model today with our [model API](https://www.baseten.co/library/glm-52/).
>
> All credit for this work goes to Alex Korte, Magdy Saleh, Tri Dao, Anant Desai, Bryce Dubayah, Abu Qader, and the rest of the incredible engineering team at Baseten. I'm just the guy who is lucky enough to write about their hard work.
>
> ---
>
> **Replies**
>
> > **@thealexker (Alex Ker 🔭):** @philipkiely W article with the best OSS model on the market
>
> > **@YusufAfifi3 (Yusuf):** @philipkiely Great to see how the different layer optimizations stack up would love to see stats on MTP
>
> > **@philipkiely (Philip Kiely) — reply to @YusufAfifi3:** @YusufAfifi3 We are still iterating there but the Z AI launch blog has a lot of great info on its implementation

---

Source: [Philip Kiely (@philipkiely) — "How we built the world's fastest API for GLM-5.2"](https://x.com/philipkiely/status/2069212319746506968) · X Article, Jun 23 2026
