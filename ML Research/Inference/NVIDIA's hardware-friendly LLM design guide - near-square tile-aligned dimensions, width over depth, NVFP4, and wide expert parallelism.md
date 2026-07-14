---
created: 2026-07-14
description: NVIDIA's model-hardware co-design primer gives seven guidelines for designing LLMs that saturate Blackwell GPUs — near-square linear layers aligned to GPU tile sizes, width over depth, NVFP4-quantizable layers, and MoE served with wide expert, chunked-pipeline, and Helix parallelism.
source: https://developer.nvidia.com/blog/ai-model-co-design-hardware-friendly-llm-design/
type: framework
---

## Key Takeaways

- Inference is a three-way tension — accuracy, throughput, and interactivity — and once accuracy is held fixed, throughput vs interactivity becomes a Pareto frontier that hardware-aligned model design pushes outward. The discipline is Amdahl's law applied to the serving regime: in long-context throughput-oriented serving attention can be 77% of runtime, so effort only pays where the time actually goes. Knowing your quadrant (short/long context × throughput/latency) tells you what to optimize.
- Arithmetic intensity and tile geometry, not just batch size, decide whether a linear layer is compute- or memory-bound. Favor near-square weight matrices and never let the projection (N) or reduction (K) dimension get too small — a tiny H′ keeps a GEMM memory-bound even at large token counts. And make every dimension a multiple of 128 (ideally 256 for clusterMMA, 512 for CGA) so it maps cleanly onto Tensor Core tiles; misalignment triggers tile quantization where edge tiles run a full tile's compute on padding. This is the model-design flip side of the GPU-execution details in [[MLC's Modern GPU Programming for MLSys is a Blackwell-era book that builds from the GPU execution model through TMA, tensor cores, and TMEM to a SOTA GEMM and Flash Attention 4 in the TIRx Python DSL]], and it operationalizes the roofline/arithmetic-intensity vocabulary catalogued in [[Modal's GPU Glossary is a browsable reference that maps the GPU stack from device hardware through the CUDA software layers to performance concepts in ~80 linked terms]].
- Wider beats deeper for a fixed parameter budget: greater weight reuse raises arithmetic intensity while a shorter sequential critical path lowers latency, helping both service goals at once. The caveat is a width-to-depth band — depth carries representational power — so favor width only as far as accuracy holds rather than stripping layers to game the shape.
- NVFP4 is the central performance lever: hierarchical scaling (an FP8 E4M3 scale per 16-value micro-block plus an FP32 per-tensor scale) buys 4-bit compute speed (≈15 PFLOPS FP4 vs 5 FP8 vs 2.5 FP16/BF16 on GB300) while staying within ~1 point of FP8 accuracy on DeepSeek-R1, and NVIDIA's TensorRT Model Optimizer + LLM Compressor make PTQ/QAT to NVFP4 routine. Design expensive layers to be quantizable — the same production bet as [[Philip Kiely details how Baseten built the world's fastest GLM-5.2 API by stacking NVFP4 quantization, KV-aware routing, prefill-decode disaggregation, and MTP speculation]].
- Parallelism strategy follows the regime. Throughput-oriented MoE wants wide expert parallelism — data-parallel attention (avoiding tensor-parallel's AllReduce) plus experts sharded across GPUs, since concurrency drives GEMM-M and per-GPU concurrency is KV-cache-capped — with Wide-EP kernels and an adaptive load balancer in TensorRT-LLM. Disaggregated prefill wants Chunked Pipeline Parallelism (which needs regular, repeatable layer patterns for balanced stages, avoiding pipeline bubbles), and latency-oriented serving decouples attention and FFN parallelization, with Helix Parallelism sharding the KV cache across the sequence to beat the KV-head ceiling that caps tensor parallelism on MQA/GQA/MLA models. This is the model-design substrate under [[Red Hat frames prefill-decode disaggregation, KV-cache tiering, and speculative decoding as the three llm-d deployment levers for distributed AI inference]] and the KV-cache economics of [[paged attention applies OS virtual memory paging to KV cache and unlocks 2-4x LLM serving throughput]], and it sits alongside the broader optimization catalog in [[Ashutosh Maheshwari's sub-second LLM study list catalogs sixteen inference optimizations from KV-caching and speculative decoding to tensor parallelism and memory offloading]].

## External Resources

- [TensorRT Model Optimizer](https://github.com/NVIDIA/Model-Optimizer) — NVIDIA's toolkit for PTQ, QAT, and calibration to quantize models to NVFP4 with minimal accuracy loss.
- [LLM Compressor](https://github.com/vllm-project/llm-compressor) — vLLM-project quantization library supporting the same NVFP4 post-training and quantization-aware workflows.
- [Pretraining Large Language Models with NVFP4](https://arxiv.org/abs/2509.25149) — NVIDIA Research (2025) on training directly in low bit-width.
- [Scaling Large MoE Models with Wide Expert Parallelism on NVL72](https://developer.nvidia.com/blog/scaling-large-moe-models-with-wide-expert-parallelism-on-nvl72-rack-scale-systems/) — the Wide-EP feature: high-performance all-to-all kernels and the adaptive expert load balancer.
- [Beyond the Buzz: A Pragmatic Take on Inference Disaggregation](https://arxiv.org/abs/2506.05508) — NVIDIA Research (2025) analysis of when to split prefill and decode.
- [Helix Parallelism](https://arxiv.org/abs/2507.07120) — NVIDIA Research (2025) KV-cache sequence sharding for multi-million-token decode, [supported in TensorRT-LLM](https://github.com/NVIDIA/TensorRT-LLM).

## Original Content

> [!quote]- Source Material — NVIDIA Technical Blog, Jul 10 2026 (Ritika Borkar, Nidhi Bhatia, Bhargava Gopireddy, Nick Comly, Brian Pharris, Julien Demouth, Bita Darvish Rouhani)
> # AI Model Co-Design: Hardware-Friendly LLM Design
>
> *Title graphic: LLM → Optimize → Deploy pipeline stages*
> ![[nvidia-codesign-hero.png]]
>
> **AI-Generated Summary**
> - Hardware-aware transformer model design for high-throughput, low-latency LLM inference requires near-square linear layer dimensions, alignment to GPU tile sizes (multiples of 128, ideally 256 or 512), and a width-over-depth aspect ratio to maximize arithmetic intensity and GPU utilization.
> - NVFP4 quantization, supported by NVIDIAs end-to-end tooling (TensorRT Model Optimizer and LLM Compressor), delivers high throughput and minimal accuracy loss across linear layers, enabling both compute-bound and memory-bound workloads to fully utilize Blackwell GPUs.
> - Expert parallelism (EP) and hybrid parallel strategies such as pipeline parallelism and Helix Parallelism in TensorRT-LLM allow large Mixture-of-Experts models to scale across multi-node Blackwell NVLink systems, balancing throughput and interactivity while mitigating communication and load imbalance bottlenecks.
>
> AI performance comes down to three dimensions:
>
> 1. **Accuracy:** How well the model reasons and produces outputs
> 2. **Throughput:** How many tokens per second a datacenter can generate
> 3. **Interactivity:** How responsive the model feels to a user, dominated by latency
>
> Deployments must balance all three: High accuracy is wasted if responses are slow, and raw throughput means little if each user's experience is laggy. Practical systems therefore optimize accuracy, throughput, and interactivity together.
>
> This post focuses on throughput and interactivity, and how model-design choices shape both without sacrificing accuracy (we flag accuracy trade-offs where they arise).
>
> Holding accuracy fixed, the problem becomes a two-dimensional Pareto frontier: improving one usually costs the other. The goal is to push the whole frontier outward, maximizing the area under the curve (see Figure 1, below).
>
> *Line chart showing system throughput (tokens/s) falling as interactivity (tokens/s/user) rises, with the goal of pushing the trade-off curve outward.*
> ![[nvidia-codesign-fig1.png]]
>
> _Figure 1. System throughput versus interactivity Pareto frontier_
>
> We will start with LLMs, today's most prominent AI workload. The trade-off has two perspectives: the **system deployer,** who prioritizes fleet throughput (tokens/sec), and the **user**, who values lower first-token and inter-token latency. The inverse of inter-token latency is tokens/sec/user, where higher means greater responsiveness.
>
> A single response looks like: prompt → [first-token latency] → first token → [inter-token latency] → next token, and so forth.
>
> This is a practical primer for model developers who want their models to run well on modern hardware. The idea is simple: models that align with the hardware don't just run faster; they scale better, cost less, and reach wider adoption.
>
> First, consider the deployment landscape, which varies along two axes (see Figure 2, below).
>
> *Four pie charts showing how LLM execution time splits across GEMM, attention, communication, and other layers, varying by context length and by latency- vs throughput-oriented serving.*
> ![[nvidia-codesign-fig2.png]]
>
> _Figure 2. Latency breakdown across different workload regimes (horizontal axis) and service goals (vertical axis)_
>
> Workloads range from short to long context, and service goals from throughput-oriented (maximize tokens/sec) to latency-oriented (minimize response time); many fall in between.
>
> Each quadrant needs different optimizations: long-context, throughput-oriented serving spends most of its time in attention, while latency-oriented serving adds model parallelism to shorten attention and FFN, at the cost of communication and fixed overheads. Short-context, throughput-oriented serving splits time more evenly across attention and FFN, and can benefit from parallelism (such as expert parallelism) at scale.
>
> Amdahl's law applies: optimizing one part helps only as much as the time it occupies. If attention is 77% of runtime, tuning the feed-forward layers yields only marginal gains; the attention path is where effort pays off. Knowing your regime tells you where to focus.
>
> This post gives simple rules of thumb to make these decisions early, for anyone who wants the most from the hardware without being a systems engineer. Each subsequent chapter of the series will target a different dimension of hardware-aware design, helping you avoid compute bottlenecks, deploy frictionlessly at datacenter scale, match design to your use case, and scale in practice.
>
> Design smarter. Deploy faster. Scale wider. Let's begin.
>
> ## Hardware-friendly dimensioning of linear layers in LLMs
>
> A key transformer design choice is its aspect ratio: the balance between model width and number of layers (\\(L\\)). In decoder-style models, these factors dominate how computation and memory are distributed across the stack. Width itself is set by two dimensions, the hidden dimension (\\(H\\)) and the intermediate projection dimension (\\(H'\\)) in the MLP layers.
>
> Together, \\(H\\), \\(H'\\), and \\(L\\) also shape how cleanly the model maps onto parallelism strategies and how well it scales across GPUs. This post looks at how these three choices affect throughput, interactivity, and scalability, with a close focus on the linear layers.
>
> ### Role of arithmetic intensity
>
> On any hardware, achievable performance is bounded by the roofline model. Where a workload lands depends on its arithmetic intensity, defined as the number of compute operations performed per byte of memory moved.
>
> Workloads with low arithmetic intensity are capped by memory bandwidth (memory-bound); those with high arithmetic intensity are capped by the device's peak compute throughput, in FLOPS (compute-bound). When the goal is maximum throughput (tokens per second), you want to drive the workload into the compute-bound region so the hardware's full math capacity is used.
>
> Latency-sensitive decoding is the opposite, it runs at low concurrency and is memory-bound, so reducing memory-access time is what lowers response latency.
>
> *Roofline plot where performance rises with arithmetic intensity in the memory-bound region, then flattens at the compute-bound peak past the ridge point.*
> ![[nvidia-codesign-fig3.jpg]]
>
> _Figure 3. The roofline model. Below the ridge point, a workload is limited by memory bandwidth; above it, by the device's peak compute throughput. A workload's arithmetic intensity (operations per byte) determines which regime it falls in_
>
> One straightforward way to raise operations per byte is to increase batch size, but model shape matters too. Let's look at how \\(H\\) and \\(H'\\) decide whether a GEMM is compute-bound or memory-bound. When running on a single device, \\(H\\) and \\(H'\\) set the shape of a GEMM of the form:
>
> \\(C = AB\\)
>
> Following the convention used in typical linear-algebra libraries, \\(A\\) is a matrix of size \\(M \\times K\\) (\\(M\\) rows, \\(K\\) columns) and \\(B\\) is \\(K \\times N\\). The product \\(C\\) has \\(M \\times N\\) outputs, each a dot product of length \\(K\\), requiring \\(M \\times N \\times K\\) fused multiply-adds (FMAs). Since each FMA is 2 FLOPs (one multiply, one add), the costs are:
>
> \\(\\text{FLOPs} = 2 \\times M \\times N \\times K\\)
>
> \\(\\text{Read Bytes} = M \\times K \\times \\text{bytes}\_A + N \\times K \\times \\text{bytes}\_B\\)
>
> \\(\\text{Write Bytes} = M \\times N \\times \\text{bytes}\_C\\)
>
> where \\(\\text{bytes}\_{A,B,C}\\) are the per-element byte counts set by the precision used. Taking \\(A\\) as the inputs and \\(B\\) as the weights, Table 1, below, maps the token count (\\(\\text{Tokens} = \\text{concurrency} \\times \\text{sequence length}\\)), \\(H\\), and \\(H'\\) to a GEMM's \\(M\\), \\(N\\), and \\(K\\) for each linear layer.
>
> | **Layer Name**          | **Projection(in → out)** | **GEMM M** | **GEMM N** | **GEMM K** |
> | ----------------------- | ------------------------ | ---------- | ---------- | ---------- |
> | Q/K/V input linear\*    | _H_ → 3_H_               | Tokens     | 3_H_       | _H_        |
> | Attention output linear | _H_ → _H_                | Tokens     | _H_        | _H_        |
> | FFN-1 (up-projection)   | _H_ → _H_′               | Tokens     | _H_′       | _H_        |
> | FFN-2 (down-projection) | _H_′ → _H_               | Tokens     | _H_        | _H_′       |
>
> _Table 1. GEMM dimensions (M, N, K) of the linear layers in a transformer block, expressed in terms of Tokens, H, and H′_
>
> Consider a case where every GEMM is "square," \\(\\text{Tokens} = H' = H\\). A single GEMM then performs \\(2H^{3}\\) FLOPs while moving about \\(3H^{2}\\) elements of memory, so arithmetic intensity grows with \\(H\\). The practical consequence: when either \\(H\\) or \\(H'\\) is small, the GPU spends proportionally more time moving data than doing math, even when the token dimension is large.
>
> As a concrete example, take FFN-2 with a deliberately small \\(H'=512\\) and \\(H=8192\\), using 4-bit inputs and 8-bit outputs on GB300. As Table 2 shows, below, even at large token counts (high GEMM-M) this layer stays memory-bound, dominated by data movement; the write cost dominates because the output is FP8 while the inputs are FP4, and the small reduction dimension keeps the GEMM memory-bound.
>
> | M (Tokens) | \\(N\\) | \\(K\\) | math (µs) | FP4 read (µs) | FP8 write (µs) |
> | ---------- | ------- | ------- | --------- | ------------- | -------------- |
> | 256        | 8192    | 512     | 0.14      | 0.30          | 0.26           |
> | 2048       | 8192    | 512     | 1.15      | 0.37          | 2.10           |
> | 16384      | 8192    | 512     | 9.16      | 0.89          | 16.8           |
>
> _Table 2. Theoretical per-GEMM durations for FFN-2 (\\(N\\) = 8192, \\(K\\) = 512) on GB300, assuming 15 PFLOPS peak FP4 compute and 8 TB/s peak memory bandwidth. Memory time exceeds math time at every token count, so the layer stays memory-bound throughout_
>
> The plots in Figure 4, below, show this on GB300 silicon. With NVFP4 GEMMs and the token dimension (GEMM-M) fixed at a large 8192, we sweep the reduction dimension (GEMM-K) (shown on the left) and the projection dimension (GEMM-N) (shown on the right). In both cases throughput falls sharply when the swept dimension is small, confirming that a small \\(N\\) or \\(K\\) leaves the hardware underutilized. (\\(N\\) and \\(K\\) correspond to \\(H\\) or \\(H'\\) depending on the layer; see Table 1, above.)
>
> *Two line charts showing NVFP4 GEMM throughput on GB300 rising and saturating as the K (left) and N (right) dimensions grow, and falling sharply when they are small.*
> ![[nvidia-codesign-fig4.png]]
>
> _Figure 4 (Left). NVFP4 GEMM throughput on GB300 vs the reduction dimension \\(K\\) (\\(M\\) = 8192, \\(N\\) = 9728 fixed). Saturates near \\(K\\) ≈ 6144; reaching 80% of sustained throughput requires \\(K\\) > 3072. Figure 4 (Right). NVFP4 GEMM throughput on GB300 vs the projection dimension \\(N\\) (\\(M\\) = 8192, \\(K\\) = 8448 fixed). Saturates near \\(N\\) ≈ 6144; reaching 80% of sustained throughput requires \\(N\\) > 2560_
>
> This is an important point for model designers: model dimensions matter just as much as batch size for saturating compute.
>
> **_Guideline 1:_** _For a fixed-parameter model, favor near-square weight matrices and avoid making either the projection or reduction dimension too small._
>
> But size alone isn't enough. To reach high Tensor Core utilization, a GEMM's dimensions must also map cleanly onto the underlying tiling geometry; poor alignment causes tile quantization, which reduces throughput even when arithmetic intensity is high.
>
> ## How GPUs execute GEMMs
>
> GPUs execute GEMMs by splitting the output matrix into tiles, each computed by a streaming multiprocessor (SM). On recent GPUs, SMs don't have to work alone; they can cooperate on a single, larger tile: with clusterMMA, two neighboring SMs join forces on one tile, and a Cooperative Grid Array (CGA) lets a whole group of SMs work together as one cluster.
>
> Cooperation improves data reuse, but it also enlarges the effective tile, so dimensions must be a multiple of a larger value to stay aligned. When a dimension is not a multiple of that effective tile, the edge tiles are only partially filled yet still launch and run a full tile's worth of compute; the unused (padded) portion does no useful work, wasting cycles and lowering throughput. Figure 5 illustrates this: with a 256×128 base tile, clusterMMA, and a 4×2 CGA, sweeping GEMM-N in fine-grained steps produces local throughput maxima when N is a multiple of 256 (2×128 from clusterMMA) or 512 (2×256 from CGA).
>
> *Sawtooth chart showing NVFP4 GEMM throughput on GB300 peaking when GEMM-N is a multiple of 256 or 512 and dipping in between.*
> ![[nvidia-codesign-fig5.png]]
>
> _Figure 5. Tile-quantization effect on delivered throughput on GB300, measured with a kernel forced to use 256×128 tiles with clusterMMA and a 4×2 CGA over the M×N output matrix_
>
> To avoid this waste, choose model dimensions that are large multiples of the tile size and aligned with GPU cache-line widths. A multiple of **128** is a safe, portable floor; multiples of 256 (clusterMMA) or 512 (CGA) align with the larger cooperative tiles and capture the most throughput.
>
> **_Guideline 2:_** _Make model dimensions multiples of 128 at minimum to align with GPU tile sizes and cache-line widths, and prefer 256 or 512 to match the larger tiles formed by clusterMMA and CGA._
>
> ## Wider models are more hardware-friendly than deeper models
>
> For a fixed-parameter budget, wider models offer higher arithmetic intensity and lower latency than deeper models through greater weight reuse and a shorter sequential critical path. This makes wider models advantageous for both throughput- and latency-oriented service goals.
>
> That said, aspect ratio also affects model quality: depth contributes to representational power, so there is a useful width-to-depth band rather than "wider is always better." Favor width only as far as accuracy holds, rather than stripping out layers just to make the model wider.
>
> **_Guideline 3:_** _When given a choice, prefer fewer, larger operations over many smaller ones; this maximizes arithmetic intensity and improves hardware utilization, benefiting both throughput and interactivity. In other words, wider transformer models are more hardware-friendly than deeper ones._
>
> ## Quantization as a performance lever
>
> Quantization helps both compute-bound and memory-bound work, by raising math throughput and reducing memory traffic at once. Blackwell systems support NVFP4 along with other bit-width formats such as FP8 and FP16/BF16 (see Figure 6, below).
>
> *Bar chart of dense Tensor Core throughput on GB300: about 2.5 PFLOPS for FP16/BF16, 5 for FP8, and 15 for FP4.*
> ![[nvidia-codesign-fig6.jpg]]
>
> _Figure 6. Dense Tensor Core throughput across data types_
>
> NVFP4 is designed specifically for balancing model accuracy and speed; it applies a fine-grained FP8 (E4M3) scale to each 16-value micro-block, plus a second-level FP32 scale per tensor. This hierarchical scaling sharply reduces quantization error while keeping the speed of 4-bit computation, letting NVFP4 closely match higher-precision accuracy across a wide range of LLM workloads (see Figure 7, below, DeepSeek-R1).
>
> *Grouped bar chart showing DeepSeek-R1 accuracy under NVFP4 staying within about one point of the FP8 baseline across seven benchmarks.*
> ![[nvidia-codesign-fig7.png]]
>
> _Figure 7. DeepSeek-R1 accuracy under NVFP4 closely matches the FP8 baseline, staying within about one point on most benchmarks and matching or exceeding FP8 on SciCode, Math-500, and AIME 2024_
>
> NVIDIA provides end-to-end tooling to make this practical: [TensorRT Model Optimizer](https://github.com/NVIDIA/Model-Optimizer) and [LLM Compressor](https://github.com/vllm-project/llm-compressor) support post-training quantization (PTQ), quantization-aware training (QAT), and advanced calibration, quantizing models to NVFP4 with minimal accuracy loss.
>
> As a result, most matrix-multiplication-heavy operations, such as the linear layers, can fully exploit NVFP4 for higher throughput while keeping model fidelity. To learn more about training with lower bit-width, check out [Pretraining Large Language Models with NVFP4](https://arxiv.org/abs/2509.25149) (NVIDIA Research, 2025).
>
> **_Guideline 4:_** _When introducing computationally expensive operations into a network, consider whether they can be quantized at deployment. Designing layers that benefit from low-precision execution is key to getting the most out of modern GPUs._
>
> ## Large expert parallelism boosts throughput
>
> In throughput-oriented serving the goal is simple: Serve as many users as possible, as fast as possible, on the fewest GPUs. Since most state-of-the-art LLMs are now Mixture-of-Experts (MoE), a highly effective way to do this is expert parallelism (EP): run attention data parallel and distribute the FFN experts across GPUs.
>
> Using data parallelism (DP) for attention avoids a key limitation of tensor parallelism (TP), the expensive AllReduce needed to combine partial results. That overhead grows with concurrency and drags down throughput, making TP a poor fit here. DP attention scales more naturally: adding GPUs directly raises global concurrency, and higher concurrency means a larger GEMM-M in the MoE FFNs.
>
> Assuming uniform token routing:
>
> \\(\\text{GEMM-}M = \\frac{\\text{global concurrency} \\times \\text{top-}k}{\\#\\text{experts}}\\)
>
> where global concurrency is concurrent tokens per GPU × number of GPUs, top-k is theexperts activated per token (8 for DeepSeek-R1), and #experts is thetotal number of experts (256 for DeepSeek-R1). Because GEMM-M grows with concurrency and shrinks with model sparsity, pushing concurrency is the key to high GEMM utilization in sparse MoE models, and since per-GPU concurrency is capped by the KV cache footprint, widening EP across more GPUs is the main lever for raising it.
>
> Even when each expert's effective batch (its GEMM-M) is small, whether from limited concurrency or imbalanced token routing, widening EP still helps in two ways:
>
> 1. Faster execution via aggregate bandwidth: Distributing experts across more GPUs increases the effective memory bandwidth available for loading expert weights, reducing end-to-end FFN latency.
> 2. Reduced per-GPU memory footprint: Each GPU stores only a subset of experts, freeing memory to increase effective concurrency per GPU and better saturate compute.
>
> EP does bring two challenges, all-to-all communication overhead and expert load imbalance, but NVIDIA's [Wide-EP](https://developer.nvidia.com/blog/scaling-large-moe-models-with-wide-expert-parallelism-on-nvl72-rack-scale-systems/) feature in TensorRT-LLM addresses both:
>
> * High-performance all-to-all kernels that scale EP across Blackwell multi-node NVLink systems, and
> * An adaptive load balancer that redistributes expert traffic based on real-time load patterns to stay stable under skewed token and expert distributions.
>
> For details, see the TensorRT-LLM [documentation](https://nvidia.github.io/TensorRT-LLM/features/parallel-strategy.html#id3) on expert parallel scaling. For throughput-oriented MoE deployments, the key lever is expert parallelism.
>
> **_Guideline 5:_** _Complex, sparse MoE models with large numbers of experts can still deliver high throughput when deployed with the right parallelism strategy, most notably by scaling expert parallelism wide._
>
> ## Design for pipeline parallelism
>
> Pipeline parallelism becomes relevant when you disaggregate prefill and decode, which can be an effective serving strategy for certain model sizes, traffic patterns, and latency targets, as we analyzed in [Beyond the Buzz: A Pragmatic Take on Inference Disaggregation](https://arxiv.org/abs/2506.05508) (NVIDIA Research, 2025): running prefill and decode with different model-partitioning lets each be optimized and scaled on its own, raising overall throughput.
>
> For prefill, maintaining high throughput while reducing first-token latency (FTL), especially on long contexts, takes aggressive parallelization. Chunked Pipeline Parallelism (CPP) is well suited here: it splits both the model layers across GPUs and the input context into chunks that flow through the pipeline (see Figure 8, below).
>
> *Diagram of a two-stage pipeline where input token chunks flow through the stages over time, so layers and chunks process in parallel.*
> ![[nvidia-codesign-fig8.jpg]]
>
> _Figure 8. Chunked Pipeline Parallelism splits tokens and layers across GPUs for pipeline execution_
>
> This lets prefill workers handle long sequences within tight FTL budgets without resorting to wide tensor parallelism (see Figure 9, below).
>
> *Chart showing that as pipeline-parallel size grows from 1 to 32, first-token latency drops steadily while tokens/s/GPU stays roughly constant.*
> ![[nvidia-codesign-fig9.jpg]]
>
> _Figure 9. Chunked Pipeline Parallelism reduces FTL without sacrificing throughput. Example: DeepSeek-R1 prefill at 256K input length, increasing pipeline parallel size reduces FTL while tokens/s/GPU stays roughly constant_
>
> CPP only pays off if the pipeline stages are balanced; imbalanced stages introduce pipeline bubbles that leave some GPUs idle. An effective way to keep stages balanced is to build the model with repeatable layer patterns that partition evenly.
>
> **_Guideline 6:_** _Design models with regular, repeatable layer patterns that are easy to split into balanced pipeline stages. This makes the model well suited for Chunked Pipeline Parallelism, enabling higher throughput while meeting tight first-token latency targets._
>
> ## Hybrid parallel strategies to meet latency-oriented service goals
>
> So far we have focused on throughput; latency-oriented serving follows different constraints. Lower latency requires less work per GPU (lower concurrency) or more GPUs. However, shrinking the batch eventually only reduces attention latency: FFN latency becomes memory-bound because the GEMM-N and GEMM-K dimensions remain large as GEMM-M shrinks, making weight reads of the \\(N \\times K\\) matrix the bottleneck.
>
> In this low-concurrency regime, attention and FFNs should be parallelized independently. FFNs accelerate by spreading weights across GPUs with TP, EP, or TP×EP. TP favors coarse MoE models with large experts, while EP is better suited to fine-grained MoE models, whose smaller \\(H'\\) would otherwise produce inefficiently small GEMMs under TP.
>
> Attention, by contrast, benefits from TP and KV parallelism. However, TP scales only up to the number of KV heads; beyond that, the KV cache must be replicated, introducing redundant work. Because modern MQA/GQA/MLA models have few KV heads, this quickly becomes a bottleneck. [Helix Parallelism](https://arxiv.org/abs/2507.07120) (NVIDIA Research, 2025) overcomes this by sharding the KV cache across the sequence dimension during attention, then reusing the same GPUs for TPxEP in the FFNs. Helix is [supported in TensorRT-LLM](https://github.com/NVIDIA/TensorRT-LLM/blob/main/docs/source/blogs/tech_blog/blog22_Helix_Parallelism_Scaling_Multi_Million_Token_Decoding_with_KV_Cache_Sharding.md). Although these hybrid schemes introduce additional communication, Blackwell NVL72's high-bandwidth NVLink fabric absorbs much of the cost, while the remainder can be overlapped with computation.
>
> **_Guideline 7:_** _Design models and deployments to decouple attention and FFN parallelization, so that scaling GPUs improves interactivity by strategically targeting the dominant bottlenecks._
>
> ## Next steps
>
> As you design your next model, treat these guidelines as a design checklist:
>
> * Keep dimensions near-square and aligned to 128 (ideally 256)
> * Favor width over depth
> * Design models for low-precision (NVFP4) execution
> * Use regular, repeatable layer patterns that map cleanly onto pipeline parallelism
>
> Small choices like these can meaningfully raise GPU utilization, delivering faster inference, higher throughput, and better interactivity from the same hardware.
>
> To put them into practice, explore [NVIDIA TensorRT Model Optimizer](https://developer.nvidia.com/blog/introducing-nvfp4-for-efficient-and-accurate-low-precision-inference/) for NVFP4 quantization and [TensorRT-LLM](https://nvidia.github.io/TensorRT-LLM/) for expert, pipeline, and [Helix parallelism](https://developer.nvidia.com/blog/asking-an-encyclopedia-sized-question-how-to-make-the-world-smarter-with-multi-million-token-real-time-inference/).
>
> [Original article](https://developer.nvidia.com/blog/ai-model-co-design-hardware-friendly-llm-design/)
