---
created: 2026-09-04
description: Jake's beginner primer on running MoE models on ordinary gaming PCs. The argument is that in a Mixture-of-Experts model the stored-weight share and the active-weight share diverge — Qwen3.6-35B-A3B holds ~32.3B of its 35B weights as experts but activates only 8 of 256 routed experts per layer — so cold experts can sit in slow system RAM while the always-active backbone stays in VRAM. His weighted-bandwidth arithmetic on an RTX 5070 (672 GB/s) plus dual-channel DDR5-5600 (~90 GB/s) yields 257 GB/s blended for MoE offload against 122 GB/s for the equivalent dense offload. Every number in the article is a vendor spec or his own arithmetic; the "within 5% of my M4 Max" figure is a separate, unmethodologised claim from a reply thread a month later.
source: https://x.com/JakeKAllDay/status/2059310445798797748
author: "@JakeKAllDay"
type: article
tags: [local-inference, hardware, moe, offload, ddr5, vram, gguf, llama-cpp, qwen, mtp, quantization, consumer-hardware]
---

## Key Takeaways

> [!info]- Dated context (article 2026-05-26, read 2026-09-04) — the model axis moved further his way, the RAM axis moved hard against him
> The primer predates the Aug-2026 wave. Its archetype, **Qwen3.6-35B-A3B, is 8.6% active** (3B of 35B); the models that now define the local frontier are far sparser — **Qwen3.8-Flash-Next 180B/4.6B (2.6%)**, **GLM-5.3-Flash 321B/15.9B (4.9%)**, **DeepSeek-V4-Flash 304B/17.0B (5.6%)** — so the mechanism he describes has strengthened, not aged. What inverted is the premise underneath it. He writes that "you can often add 64GB, 96GB, or 128GB of system RAM without replacing the entire machine" and puts the whole build under $1,000 used. Measured consumer pricing: a **64GB DDR5-5600 kit went $191 (Aug 2025) → $1,118 (Aug 2026), +485% YoY**, with server RDIMM at $32–37/GB and still climbing ~1.2%/week. The cheap-capacity pool that makes the argument work is the line item that repriced most. His follow-up "<$5K" 5080 + 64GB DDR5-7200 build (2026-06-26) was costed before that showed up in retail.
> Evidence: `/data/projects/hardware/research/hw-alternatives.md` §1, §2.5; `benchmarks-matrix.md` §1.4.

- **The mechanism, stated more precisely than most write-ups manage: in a dense model stored-weight share ≈ active-weight share, and in an MoE they diverge.** That single sentence is the whole case for offload. Qwen3.6-35B-A3B stores ~**32.3B expert weights out of 35B total**, yet a token activates **8 of 256 routed experts plus 1 shared expert per layer (3.125% of the routed pool)** and only ~**1.1B of its ~3B active parameters are expert weights** — the other ~1.8–1.9B is always-active backbone. So under 10% of the model can sit in VRAM while a majority of the *active* token path still lives there. Dense offload has no equivalent move: offloaded dense layers are on the critical path every token, which is why [[Step 01 - Decode is memory-bandwidth-bound (the roofline)|decode collapses toward the slow tier's bandwidth]]. This is the same structural fact that makes [[EXL3 3-bit plus an 18.5 percent expert prune runs DeepSeek-V4-Flash 284B at 47 tok-s on 4.7K of hardware|expert pruning]] a lever dense models cannot pull, and that our own matrix records as MoE-vs-dense throughput on identical silicon (RTX PRO 4500: **240.8 t/s on a 20B MoE vs 37.9 t/s on a 32B dense**).

*Why MoE offload survives what dense offload does not — the stored-versus-active divergence, with the Qwen3.6-35B-A3B parameter split:*
![[jakekallday-797748-003.jpg]]

- **The load-bearing number is arithmetic, not a benchmark, and he is careful to say so — 257 GB/s blended for MoE against 122 GB/s dense.** His formula is `effective BW ≈ 1 / ((VRAM_frac / VRAM_BW) + (RAM_frac / RAM_BW))`, fed with vendor specs: **RTX 5070 at 672 GB/s**, dual-channel **DDR5-5600 at ~89.6 GB/s** (Kingston's 44.8 GB/s per module, doubled). A dense model pulling **70% of its active bytes from RAM** lands at **122 GB/s — 18% of the all-VRAM path**; an MoE arrangement pulling **25%** lands at **257 GB/s**. Read it as a sizing intuition, because it has no term for prefill compute, PCIe transfer, kernel launch, CPU dispatch or KV traffic — and those are exactly the terms that dominate agent workloads. Our measured analogue on the CPU-plus-one-GPU tier is blunt about it: on **EPYC 9355 + DDR5-6400 + one RTX PRO 6000** running Kimi-K2.6 Q4_X (543.6 GiB) with all routed experts in RAM, simulating a **32GB RTX 5090-class card instead dropped prefill 273 → 177 t/s and left decode unchanged at ~20 t/s**. On this topology the GPU buys prefill batch size, not decode speed.

- **His one performance claim is not in the article, carries no methodology, and is the number our tier actually cares about.** A month later, replying to [[matmuls are parallel memory reads - Roy's bandwidth ladder puts a 1K RTX 3090 at 936 GB-s above a 5K Mac or DGX Spark, but it has no capacity or prefill column|Roy's bandwidth ladder]], he wrote that partial MoE expert offload on a **5070 + DDR5-5600 + a 2024 Ryzen** gets him "**within 5% of my M4 Max**", and projected a **5080 + 64GB DDR5-7200** would "absolutely outrun an M4 Max and might M5 Max (on decode, probably not prefill)" at "easily a <$5K setup". No model, quant, engine, context length or absolute tok/s is given on either side, so this is `[CLAIM]`, not a measurement — and the comparison is against an M4 Max, a generation behind the Macs the ladder was arguing about. It is nonetheless directionally consistent with our EPYC-plus-one-GPU band of **15–33 t/s decode** on 200–800B MoEs regardless of tuning, the best of those being MiniMax-M2.1 on **2× EPYC 9355 plus one RTX 5090 at 2,540 t/s prefill and 27.6 t/s decode at 32K context**. His own parenthetical concedes the axis that decides the purchase: prefill, where a hybrid box falls from **729 t/s at zero context to 237 t/s at 131K** while a [[Qwen3.8-27B with NVFP4 plus DFlash2 decodes at 358.8 tok-s peak and 220-240 sustained on one RTX 5090 - Roy's Opus-4.6-at-home claim|5090 on a resident model]] is three orders of magnitude clear.

- **MTP is probably doing more of the work in that claim than the offload is, and he half-says it.** He calls multi-token prediction "another detail" and tucks it into §9, but his reply thread leans on it twice ("MTP lets you deflect some CPU based slowdown too"). Our measurements put [[Modal argues speculative decoding is the only inference optimization that matters, and custom DFlash speculators turn acceptance length into 2-3x speedups|speculative decoding]] at **2.25–3.8× on the same box, same day, same user** — Strix Halo on Flash-Next 16.8 → 47.1 t/s, a DGX Spark on Qwen3.8-27B 10.8–12.4 → 39.7–47.1 t/s. That is larger than most hardware-tier gaps, which means an M4 Max running mainline MLX without MTP against a 5070 running llama.cpp with it is not a memory-architecture comparison at all. His setup block is right to gate it on runtime support (`--max-draft-tokens 2`, skip if unsupported); the honest reading is that the engine, not the memory topology, is carrying the 5%.

- **What generalizes past Qwen3.6: the technique is "keep bytes with sparse access patterns off the fast tier", and experts are only the first instance.** His 4-bit floor rule holds up — "exotic quantizations that claim really high tok/s… are prone to rambling/over-thinking, causing their time to completion to explode" matches our perplexity ladder exactly (**IQ3 nearly free, IQ2 and below degrade badly**), and cheating with fewer experts is worse than it looks (**dropping 1 of 8 costs 7.2 points of top-1 agreement on real code**). The 2026 extension he could not have written: **51.2B of Flash-Next's 180B parameters are an n-gram embedding table read by a row gather, ~26% of the Q4 file**, and file-backing it to NVMe drops the resident set from ~105 GiB to ~78 GiB — a 128GB machine becomes a 96GB machine. Same principle, different tensor. The complement on the KV side is [[LMCache offloads paged KV to system RAM and NVMe, cutting 128K-context time-to-first-token from 68 seconds to 1.4 on 4x DGX Spark|paging KV out to RAM and NVMe]], and his §6 explanation of why [[From GPT-2 to Kimi K3 - a visual worklog on how attention architecture evolved to fix the KV cache with linear attention, DeltaNet, gating, and hybrid retrieval|Gated DeltaNet keeps a fixed-size running state instead of a growing cache]] is the clearest beginner-level version of that argument I have read.

## External Resources

- Original article: [@JakeKAllDay, 2026-05-26](https://x.com/JakeKAllDay/status/2059310445798797748) — 70 likes, 10 reposts, 11 replies
- The measured claim: [@JakeKAllDay, 2026-06-26](https://x.com/JakeKAllDay/status/2070564289786581337) — "within 5% of my M4 Max" on a 5070 with partial MoE offload, in reply to Roy's bandwidth ladder
- [Qwen3.6-35B-A3B model card](https://huggingface.co/Qwen/Qwen3.6-35B-A3B) — 35B total / 3B active, 40 layers, 256 experts, 8 routed + 1 shared
- [Qwen3.6-27B model card](https://huggingface.co/Qwen/Qwen3.6-27B) — the dense counterpart: 27B, hidden 5,120, 64 layers
- [Unsloth Qwen3.6-35B-A3B UD-Q4_K_M GGUF](https://huggingface.co/unsloth/Qwen3.6-35B-A3B-GGUF/blob/main/Qwen3.6-35B-A3B-UD-Q4_K_M.gguf) — 22.1 GB, against 16.8 GB for the 27B dense Q4_K_M
- [Qwen llama.cpp local guide](https://qwen.readthedocs.io/en/latest/run_locally/llama.cpp.html) and the [Qwen3.6 GitHub repository](https://github.com/QwenLM/Qwen3.6) — the runtime path the article assumes
- [Qwen3.6 MTP/turbo KV analysis](https://huggingface.co/datasets/sjakek/qwen36-mtp-turbo-kv-analysis) — Jake's own dataset on multi-token prediction, cited in §9
- Jake's saliency datasets: [MoE coding expert saliency](https://huggingface.co/datasets/sjakek/qwen36-moe-coding-expert-saliency) · [Q4_K_M saliency vs attention residency](https://huggingface.co/datasets/sjakek/qwen36-q4km-saliency-vs-attention-residency-100) · [SWE-bench Lite saliency layer compare](https://huggingface.co/datasets/sjakek/qwen36-q4km-swebench-lite-saliency-overfit-layercompare) · [coding layer bottleneck profiles](https://huggingface.co/datasets/sjakek/qwen36-coding-layer-bottleneck-profiles) — the empirical work behind the residency advice
- Background the article links: [Hugging Face MoE explainer](https://huggingface.co/blog/moe) · [NVIDIA MoE architecture explainer](https://developer.nvidia.com/blog/applying-mixture-of-experts-in-llm-architectures/) · [Attention Is All You Need](https://arxiv.org/abs/1706.03762) · [Qwen3 Technical Report](https://arxiv.org/abs/2505.09388)
- Bandwidth sources he cites: [NVIDIA RTX 5070 family](https://www.nvidia.com/en-us/geforce/graphics-cards/50-series/rtx-5070-family/) (672 GB/s) · [RTX 5090](https://www.nvidia.com/en-us/geforce/graphics-cards/50-series/rtx-5090/) (1,792 GB/s) · [Kingston DDR5 population rules](https://www.kingston.com/en/memory/memory-population-rules) (44.8 GB/s per DDR5-5600 module) · [JEDEC GDDR7 standard summary](https://pcdandf.com/pcdesign/index.php/editorial/menu-news/fab-news/17940-jedec-publishes-gddr7-graphics-memory-standard)
- [Simon Willison's Qwen3.6-27B local run note](https://simonwillison.net/2026/apr/22/qwen36-27b/)

## Original Content

> [!quote]- Full article (@JakeKAllDay, 2026-05-26) — A Beginner Primer on Using MoE Models on Consumer Hardware
>
> Why ordinary gaming PCs, system RAM, and sparse expert models are becoming a surprisingly useful local AI stack
>
> Reader assumption
>
> This article assumes zero background in large language models. Every first-use technical term is defined in plain English, either inline or in a short parenthetical note. Parts of it, however, are written assuming the user is using an Nvidia or similar graphics card with dedicated VRAM.
>
> # 1. Why consumer hardware suddenly matters
>
> There are two trends that make local artificial intelligence feel confusing right now. The first trend is that developers, writers, researchers, hobbyists, and small businesses are being told that they should experiment with local AI. This is appealing because it can be private, cheap at the margin, available offline, and easier to integrate into personal workflows. The second trend is economic: the hardware that looks “obvious” for local AI keeps getting more expensive. High-end GPUs can cost multiple times the typical computer.
>
> That creates a strange investment problem. If you are not running AI workloads constantly, it can feel irrational to buy a massive GPU just to experiment. But if you avoid local hardware entirely, you miss the point of local experimentation: control, iteration speed, privacy, and the ability to test models without paying an API (application programming interface, meaning a remote software service you call over the internet) for every token.
>
> But fear not! There is a secret third option. You do not always need a monster graphics card. You often need a decent graphics card, enough ordinary system RAM (the main memory installed on your motherboard), and a model architecture that can use that memory intelligently. But these are the sort of specs you can find in a used PC for <$1000. This is where MoE (Mixture of Experts, a model design where only selected expert sub-networks activate for each token) becomes important. MoE lets a computer keep a large model available while using only a smaller active slice of it at a time. A consequence of this is that system RAM can become a useful pressure-release valve for models that would otherwise require far more VRAM (video random access memory, the high-bandwidth memory physically attached to a GPU), in a way that older (dense architectures that use every single part of the model for every token generated) could not.
>
> # 2. RAM versus VRAM: why the speed and price gap exists
>
> System RAM and GPU VRAM are both memory, but they are built for different jobs. AI inference is often memory-bandwidth-bound, meaning the limiting factor is not just how many math units the chip has, but how quickly it can feed model weights into those math units.
>
> VRAM is much faster than system RAM. For example, NVIDIA lists the mid-tier RTX 5070 at 672 GB/s (gigabytes per second, a measure of memory bandwidth) of GDDR7 memory bandwidth, while the RTX 5090 is listed at 1,792 GB/s. Commodity DDR5 (Double Data Rate 5, the current mainstream desktop/laptop system RAM) is far slower: Kingston lists DDR5-5600 at 44.8 GB/s per module, which means a two-channel desktop configuration is roughly 89.6 GB/s before real-world overhead. This makes typical DDR5 as much as 95% slower compared to high end graphics cards (your bandwidth is what determines how quickly the LLM’s operations can be performed).
>
> That sounds like a crushing loss for RAM, and in pure bandwidth terms it is. But capacity and cost change the decision. You can often add 64GB, 96GB, or 128GB of system RAM without replacing the entire machine. You cannot usually add 64GB of VRAM to a consumer GPU. You buy VRAM by buying a different GPU, and that GPU includes the chip, board, cooling, power delivery, and market scarcity. Even when DDR5 prices rise, system RAM remains the more flexible capacity pool.
>
> The local AI hardware trade: VRAM is fast but scarce. RAM is slower but larger and easier to expand. MoE models are interesting because they can make slow, large RAM more useful than it would be for a dense model.
>
> As with anything else, we want to maximize the utility of our most scarce resource and substitute with other options where we can. Dense models more or less need to fit entirely in VRAM. But newer MoE do not. By putting experts in RAM, and leaving the more regularly used layers in VRAM, the resulting speed can be very useful, effectively letting you ‘blend up’ your speed.
>
> *The three paths: cloud API, professional-grade local, and the practical consumer stack of a decent GPU plus lots of RAM with sparse expert activation:*
> ![[jakekallday-797748-001.jpg]]
>
> # 3 . Minimal vocabulary before the model discussion
>
> An LLM (large language model, a neural network trained to predict and generate text-like token sequences) does not read words exactly the way people do. It reads tokens (small chunks of text, such as a word, part of a word, punctuation mark, or code symbol). Inference (running the model to produce an answer) means repeatedly feeding tokens through the model to predict the next token.
>
> The model itself is mostly weights or parameters (learned numbers stored in memory). If a model has 27 billion parameters, that means it stores roughly 27 billion learned numerical values. The exact memory footprint depends on precision (how many bits are used to store each number). BF16 (bfloat16, a 16-bit floating-point format) uses far more memory than 4-bit quantization. Quantization (storing model weights with fewer bits than the original training format) is why large models can fit on consumer machines at all. A model that is impossible to fit at BF16 may be usable in a 4-bit format such as Q4_K_M (a common GGUF quantization type used by llama.cpp-compatible local runners). Quantization was one of the main reasons we have seen models become drastically more usable on consumer hardware the last couple of years.
>
> GGUF (GPT-Generated Unified Format, a model file format used by llama.cpp and many local AI applications) is one of the dominant practical formats for running open-weight models locally. llama.cpp is a C++ inference engine (a fast local program for running language models) that supports Qwen models and is used underneath many local apps. Qwen’s own local-running documentation (the family of models we’ll use as archetypes) points users toward GGUF and llama.cpp for local inference (see [Qwen llama.cpp local guide](https://qwen.readthedocs.io/en/latest/run_locally/llama.cpp.html))
>
> Plain-English shortcut: A local model is mostly a giant file of learned numbers. Running the model means repeatedly moving the right numbers through CPU, GPU, RAM, and VRAM fast enough to generate useful text.
>
> # 4. Dense models: the normal “every token uses the whole path” design
>
> A dense model is the easier design to understand. Dense means that, for each token, the model activates the same major parameter path through every layer. A layer is one repeated processing block inside the model. Modern transformer models (the dominant architecture family introduced by the “Attention Is All You Need” paper) are built by stacking many layers. Each layer transforms the token representation a little more until the model is ready to predict the next token. (see [Attention Is All You Need](https://arxiv.org/abs/1706.03762) for the seminal paper).A “transformer” is a processing step that repeatedly takes a piece of text from raw tokens (numbers the computer uses to represent a part of a word or punctuation) and performs math operations on it to generate richer internal representations that better capture its meaning. It does this by letting each token compare itself against the other tokens around it, decide what context matters, and then update its meaning before the next layer repeats the process.
>
> A dense transformer layer usually contains an attention block and a feed-forward block. Attention (a mechanism that lets a token look at other tokens in the context) helps the model understand relationships across the prompt. The feed-forward network, often shortened to FFN (feed-forward network, the per-token transformation block inside a transformer layer) or MLP (multi-layer perceptron, another name for a small stack of linear transformations and nonlinearities), does a large amount of the model’s learned computation. In dense models, every token goes through the same FFN path.
>
> Qwen3.6-27B is the dense reference model for this article. According to the Qwen3.6-27B model card, it has 27 billion parameters, a hidden dimension of 5,120, and 64 layers. The “hidden dimension” is the size of the model’s internal working representation for each token. In plain English, after text is converted into tokens, the model does not keep thinking about each token as a word. It represents each token as a long list of numbers, and that list gets repeatedly updated as the token moves through the model. A hidden dimension of 5,120 means each token is represented internally by 5,120 numbers at each major processing step. These numbers are called “hidden” not because they are magical or unknowable, but because they are internal features the model learns for itself rather than plain-English labels like “noun,” “verb,” “topic,” or “tone.”
>
> The model’s 64 layers follow a repeated pattern: 16 groups of four layers each. In each group, three layers use Gated DeltaNet (we’ll get to this in just a second) plus a FFN, and the fourth uses Gated Attention plus an FFN. Both types of layers have two broad jobs. First, they use a sequence-mixing mechanism to let tokens exchange information with the rest of the text. Then, they use an FFN to work on each token individually, reshaping that token’s internal number pattern into a more useful representation for the next layer.
>
> *Dense processing: every token walks the same 64-layer path through Qwen3.6-27B, with no gate choosing among experts:*
> ![[jakekallday-797748-002.jpg]]
>
> The important distinction is in the sequence-mixing mechanism. In plain English, sequence mixing is the step where the model updates each token based on the other tokens around it. A token should not be interpreted in isolation. For example, the word “bank” means something different in “river bank” than it does in “bank account.” Sequence mixing is the part of the layer that helps the model use surrounding context to update what each token seems to mean (see [Qwen3.6-27B model card](https://huggingface.co/Qwen/Qwen3.6-27B))
>
> # 5. MoE models: many experts, few active per token
>
> MoE, or Mixture of Experts, changes the feed-forward part of the model. Instead of one FFN block per layer, an MoE layer contains many expert FFNs. An expert is a specialized sub-network, usually shaped like a feed-forward block. An “expert” in a Mixture-of-Experts model is not usually a human-style subject-matter expert (though some new architectures are exploring ideas like this!). It is a specialized pattern-processing pathway. Experts often specialize in lower-level patterns, such as grammar structures, code syntax, numbers, punctuation-heavy text, lists, formatting, or recurring phrase shapes. The router chooses which expert pathways to use for each token based on mathematical patterns in the model’s internal representation, not because it has a plain-English label like “science expert” or “law expert.” A router, also called a gate (a small learned decision equation/function), scores the experts and chooses which ones should process the current token. The most common routing style is top-k routing (choose the top k # of highest-scoring experts for a token, e.g., top 8).
>
> The key distinction is total parameters versus active parameters. Total parameters means all the learned weights stored in the model file. Active parameters means the subset used for one token’s forward pass. MoE lets a model have a large total parameter count without activating all of it for every token. The [Hugging Face MoE explainer](https://huggingface.co/blog/moe) and [NVIDIA MoE architecture explainer](https://developer.nvidia.com/blog/applying-mixture-of-experts-in-llm-architectures/) are good general introductions to this idea.
>
> Qwen3.6-35B-A3B is the MoE discussion archetype for this article. Its model card lists 35B total parameters and 3B activated parameters, which is what the “A3B” label means: approximately 3 billion active parameters per token. It has 40 layers, a hidden dimension of 2048 (remember: 2048 numbers that it uses to represent each token), 256 experts, and each token activates 8 routed experts plus 1 shared expert. A routed expert is selected by the router; a shared expert is a common expert path that is used alongside the routed experts. [Qwen3.6-35B-A3B model card](https://huggingface.co/Qwen/Qwen3.6-35B-A3B). A key detail: of the ~3B active parameters, 1.9B of them are not experts. There are roughly 32.3B experts weights in the model, but only ~1.1B of them selected in the course of generating a given token.
>
> That gives us the basic math. In each MoE layer, the token does not use all 256 routed experts. It uses 8 routed experts, or 8/256 = 3.125% of the routed expert pool in that layer, plus the shared expert. In this model with 40 layers, one generated token can involve 40 router decisions and 320 routed expert selections, but it still avoids activating the full expert pool. This is where MoE offload differs sharply from dense-model offload and why it is attractive for offloading. In a dense model, the weights stored outside VRAM are usually still part of the active path for every token, so offload quickly makes generation RAM-bound. In an MoE model, stored weight share and active weight share diverge: more than 90% of Qwen3.6-35B-A3B’s total weights are expert weights, but only a small slice of those experts is active for any one token. That means a MOE system can keep less than 10% of the total model in VRAM while still keeping a majority of the active token path in VRAM: the always-used backbone plus the selected experts. The result is a much faster blended bandwidth profile than the total RAM/VRAM split would imply.
>
> *The divergence that makes offload work — Qwen3.6-35B-A3B: ~35B total, ~32.3B expert weights, ~3B active, of which only ~1.1B are experts and ~1.8-1.9B non-expert backbone:*
> ![[jakekallday-797748-003.jpg]]
>
> # 6. Detailed primer on layers: attention, KV Cache, DeltaNet
>
> A layer is one stage in the model’s processing pipeline. If a model has 40 layers, a token representation is transformed 40 times before the model produces logits (raw prediction scores for possible next tokens). You do not need to know the math to understand the systems issue: every layer has some weights, and those weights must be read from memory quickly enough to get usable speed.
>
> “Attention” is the mechanism that lets tokens communicate across positions in the prompt. If the prompt says “the dog chased the ball because it was excited,” attention helps the model connect “it” to the right earlier word.
>
> Full attention works by letting each token compare itself against the other relevant tokens in the sequence. The model turns each token’s internal representation into comparison patterns, often described as queries, keys, and values. A query is roughly what the current token is looking for. A key is roughly what another token offers for comparison. A value is the information that can be pulled from that other token if the model decides it matters.
>
> At a high level, each token asks: “Which earlier tokens are most relevant to understanding me?” The model scores those relationships, gives higher weight to the tokens that seem more relevant, and then blends information from those tokens into the current token’s updated representation. This is how a model connects a pronoun back to the noun it refers to, links a technical term to its earlier definition, or recognizes that a phrase later in a sentence changes how an earlier word should be understood.
>
> The reason full attention is powerful is that it allows rich token-to-token comparison. Each token can, in principle, directly check many other tokens and decide which ones matter most. The drawback is that this becomes expensive as the context gets longer. If a passage has many tokens, full attention has to perform a large number of token comparisons. That is why full attention is highly expressive, but also extremely costly for long-context workloads.
>
> Linear attention takes a different approach from full attention. Instead of asking every token to build a detailed comparison map against many other tokens, it tries to compress the sequence into a more compact running representation. A useful non-technical analogy is a rolling set of working notes. As the model reads through the text, it keeps updating those notes with information from earlier tokens. New tokens can then draw from the current notes instead of directly checking every earlier token one by one. This is why linear-attention-style systems are attractive for long contexts: the model’s sequence memory does not have to grow in the same expensive way as a full attention map. The tradeoff is that the memory is compressed. Linear attention can carry forward broad context efficiently, but it may be less precise when the model needs to retrieve a very specific relationship between two distant tokens.
>
> *Full attention's KV cache grows with context (64 MB at 1K tokens to 64 GB at 1M) while a linear/recurrent running state stays fixed — illustrative sizes, not measurements:*
> ![[jakekallday-797748-004.jpg]]
>
> KV cache means key/value cache: it is important to store attention memory from earlier tokens, so the model does not need to recompute the entire previous context from scratch on every new token. Long context windows can make the KV cache a major memory consumer. The reason key-value caches exist is that text generation happens one token at a time. After the model has read a prompt and starts generating an answer, it produces the first new token, then the second, then the third, and so on. Each new token still needs to attend (pay attention to/’think’) back to the earlier prompt and to the tokens already generated. Without a cache, the model would have to repeatedly recompute the key and value patterns for all earlier tokens every time it generated one more token. That would be wasteful, because the earlier tokens have not changed (and it would be incredibly slow).
>
> A KV cache solves this by storing the key and value patterns for previous tokens. When the model generates the next token, it only needs to compute the new token’s query, key, and value, then compare the new query against the stored keys from earlier tokens and retrieve information from the stored values. In plain English, the model keeps a reusable understanding of what it has already processed instead of rebuilding that memory from scratch for every new word.
>
> Qwen uses multiple attention styles in its 3.6 models, and we’ll review the two main concepts below.
>
> The first version of attention Qwen uses is called “Gated Attention”, which is similar to the familiar full-attention mechanism used in standard transformer models. The “gated” part means the model has learned control valves inside the layer. These gates help decide how much information should pass through, how much should be suppressed, and how much should be blended into the token’s updated internal representation. The difference is not that Gated Attention stops doing attention. It still performs attention-style token-to-token lookup. The difference is that the model gets an extra learned filtering step, allowing it to preserve, suppress, or blend contextual information more selectively than a plain attention layer.
>
> Gated DeltaNet is the other sequence-mixing mechanism in this architecture. It is a version of linear attention. Instead of having every token directly compare itself against many other tokens one by one, Gated DeltaNet works more like a compact running memory system. The “DeltaNet” part refers to the way this memory is updated over time. What Gated DeltaNet adds over a simpler linear-attention design is more deliberate memory management. Basic linear attention can be thought of as “naively” accumulating information into a running memory. Gated DeltaNet makes that memory update more selective. The “gated” part means the model has learned control valves that help decide how strongly to erase, preserve, or write information as the memory is updated. So the gate is doing for the linear-attention memory what gated attention does for attention output: it gives the model finer control over how much new information should change the current internal representation.
>
> *Gated DeltaNet as the bridge between full attention and linear attention, and the 3:1 DeltaNet-to-attention rhythm Qwen3.6 uses:*
> ![[jakekallday-797748-005.jpg]]
>
> That makes Qwen3.6 a hybrid design rather than a plain stack of conventional attention layers. Most of its layers use Gated DeltaNet, a more long-context-friendly sequence mixer. But every fourth layer uses Gated Attention, giving the model periodic checkpoints where it can perform richer, more conventional token-to-token comparisons. This lets it strike a reasonable balance between conserving memory on long context while still attending to the full details periodically.
>
> # 7. The simple bandwidth math behind why MoE offload can work
>
> Here is a simplified model. Suppose a GPU has 672 GB/s of VRAM bandwidth, like the RTX 5070, and the system has about 90 GB/s of dual-channel DDR5 bandwidth. If every byte of active model weight came from VRAM, the memory path would be very fast. If most active bytes came from RAM, the memory path would collapse toward system-RAM speed.
>
> For a rough weighted-bandwidth intuition, use this formula:
>
> Effective bandwidth ≈ 1 / ((active_VRAM_fraction / VRAM_bandwidth) + (active_RAM_fraction / RAM_bandwidth))
>
> This is not a perfect simplification, because real inference also includes compute kernels (small math functions that transform data), caching, batching, PCIe transfers (moving data between main memory and GPU over a connection), CPU execution, scheduling overhead, and KV-cache traffic. But it is a useful first-order intuition.
>
> Dense offload is harsh because dense models use the same active path for every token. If 70% of the active dense path is effectively coming from RAM and only 30% from VRAM, the simplified bandwidth is:
>
> 1 / ((0.30 / 672) + (0.70 / 90)) ≈ 122 GB/s
>
> That is only about 18% of the all-VRAM 672 GB/s path. The dense model does not get to say, “Most of my offloaded weights are inactive today.” If those dense layers are part of the active path, they are hit every token.
>
> MoE changes the denominator. In Qwen3.6-35B-A3B, each MoE layer has 256 routed experts, but each token activates only 8 routed experts plus 1 shared expert. The routed-expert activation ratio is 8/256 = 3.125% per layer. That does not mean RAM is free. It means the amount of offloaded expert storage can be much larger than the amount of offloaded expert weight touched by one token.
>
> For example, imagine that the runtime keeps the non-expert machinery, routing path, attention/DeltaNet components, and selected resident layers in VRAM, while many expert tensors remain in RAM. If only 25% of the active byte path for a generated token comes from RAM, the simplified bandwidth becomes:
>
> 1 / ((0.75 / 672) + (0.25 / 90)) ≈ 257 GB/s
>
> That is still slower than all-VRAM, but it is more than twice the dense example above. The reason is not that DDR5 became fast. The reason is that MoE makes the active path smaller than the stored model. Offloading inactive or rarely touched expert capacity is much less damaging than offloading dense weights that every token must use.
>
> # 8. Qwen3.6 case study: 27B dense versus 35B-A3B MoE
>
> Qwen3.6 is a useful case study because the family gives us two clean archetypes from the same generation: a dense 27B model and a sparse 35B-A3B MoE model. Both are open-weight Qwen3.6 models, both are built for modern agentic coding use cases, and both use the hybrid DeltaNet/attention rhythm. But they make different hardware tradeoffs.
>
> *The two archetypes side by side: 27B dense (64 layers, no expert pool) versus 35B-A3B MoE (40 layers, 256 experts, 8 routed plus 1 shared per token):*
> ![[jakekallday-797748-006.jpg]]
>
> The dense 27B model is attractive when you want a simpler memory story and can fit the quantized file plus context overhead comfortably (e.g. a 24 GB card like the RTX 3090 or 3090 ti). The MoE 35B-A3B model is attractive when you want the behavior of a larger total-capacity model while relying on only a smaller active parameter path per token. This makes is usable on 16, 12, or even 8 GB cards (which unlocks more than a dozen different RTX cards over the last 3 generations). In local AI, that difference can decide whether a model is merely technically runnable or actually useful.
>
> For file-size intuition, the Unsloth (one of the most popular groups quantizing models) Qwen3.6-35B-A3B UD-Q4_K_M GGUF file is listed at 22.1 GB, compared to a 16.8 GB Qwen3.6-27B Q4_K_M GGUF. Those file sizes are not total runtime memory requirements; the KV cache, context length, runtime buffers, and operating-system overhead still matter. [Unsloth Qwen3.6-35B-A3B GGUF Q4_K_M](https://huggingface.co/unsloth/Qwen3.6-35B-A3B-GGUF/blob/main/Qwen3.6-35B-A3B-UD-Q4_K_M.gguf).
>
> # 9. Practical setup guidance for readers
>
> A beginner should think in this order: model, quantization, context, residency, then benchmark.
>
> 1. The model determines the architecture.
>
> 2. Quantization determines the base file size.
>
> 3. Context length determines how much conversation, code, or document history the model can hold, but it also increases memory pressure through the KV cache.
>
> 4. Residency determines which (or how many) layers or tensors stay in VRAM.
>
> 5. Benchmarking tells you whether the configuration is actually usable.
>
> A practical first experiment for a consumer PC is not to chase the largest possible model. It is to find a quantized model that fits with breathing room, then test how much offload hurts. For Qwen3.6-35B-A3B, a user can start from a GGUF quantization such as Q4_K_M and run it through a llama.cpp-compatible application. If you’re using 8 GB cards, try offloading all expert layers and then experiment adding 1 by 1 depending on your context needs. If you have 12 GB, for the example model recommended, compare a first-six-layers and scale up from there (for 16 GB cards, start at 10). Qwen’s GitHub page notes that llama.cpp supports Qwen3.6 and that users should look for models ending in GGUF for local use (see [Qwen3.6 GitHub repository](https://github.com/QwenLM/Qwen3.6) for more).
>
> One very important piece of nuance: the key measurement is not just “tokens per second” in the abstract. It is possible to find more exotic quantizations that claim really high tok/s, or are amazingly small. But these quantizations often show lower performance and are prone to rambling/over-thinking, causing their time to completion to explode. As a rule of thumb 4 bit quants are a good floor (with a possible exception being 3 K XL).
>
> A common question from some users: what if I’m not on Nvidia hardware? If you are using another dedicated GPU (e.g., AMD), the general offload concept still applies, but you should use a coding agent to help you diagnose the specifics of your hardware. If you are using a Mac, or another system with unified memory: this offloading concept doesn’t apply to you! But, the general idea that MoE = faster is still true, and unified memory systems are virtually always slower than VRAM, meaning their speed can be roughly similar to this approach.
>
> One last thing: MTP, or multi-token prediction, is another detail in Qwen3.6, and is an important consideration. MTP means there is an extra, tiny model trained to support predicting multiple future tokens for speculative decoding (for the larger/main model). Speculative decoding more broadly is a speed technique where a draft path proposes tokens and the main model verifies them. If you’d like to read more about this, I have a separate analysis here: [Qwen3.6 MTP/turbo KV analysis](https://huggingface.co/datasets/sjakek/qwen36-mtp-turbo-kv-analysis).
>
> *The full 40-layer Qwen3.6-35B-A3B stack: 10 rhythm blocks of three Gated DeltaNet layers plus one Gated Attention layer, each followed by MoE routing:*
> ![[jakekallday-797748-007.jpg]]
>
> # 10. Instructions to give your coding agent of choice to get started
>
> The easiest way to get started is not to memorize every local inference command yourself. A better approach is to use a coding agent that can operate on your computer, read documentation, inspect your hardware, install a runtime, and run careful benchmarks. Examples include OpenAI Codex CLI or Codex app, Google Antigravity, OpenCode, or any comparable agent that can use the terminal, read files, and modify scripts. At the time of writing all of them have some level of free tier available
>
> The point is not that the agent knows the perfect configuration in advance. The point is that it can do the boring, careful work: identify your GPU and system RAM, download the right model file, install or build the runtime, check which flags your exact binary supports, run small tests, and only then try more aggressive offload strategies. The following is written as a copy-paste instruction block you can give to that agent.
>
> ---
>
> > You are my local AI inference setup agent. I do not want a long discussion. I want a simple one-shot setup. Your job is to inspect my computer, install or use a llama.cpp-compatible GGUF runtime, download or locate a Qwen3.6-35B-A3B-MTP GGUF model, create one conservative working command, run a quick smoke test, and then give me the local browser URL and API endpoint if server mode works.
>
> > Goal: set up Qwen3.6-35B-A3B-MTP local inference using consumer hardware with a simple first-X-layers GPU offload strategy.
>
> > Important assumptions:
>
> > - Model target: Qwen3.6-35B-A3B-MTP GGUF, preferably Q4_K_M or similar 4-bit quantization.
>
> > - The model has 40 layers total.
>
> > - Use only the standard “load the first X layers into VRAM” offload strategy.
>
> > - Do not attempt arbitrary layer placement.
>
> > - Do not attempt attention-layer-only placement.
>
> > - Do not attempt tensor override placement.
>
> > - Do not attempt MoE-specific keep-layer placement.
>
> > - Do not run a long benchmark.
>
> > - Do not tune many settings.
>
> > - Prioritize a stable first run.
>
> > First, inspect hardware:
>
> > 1. Detect operating system.
>
> > 2. Detect CPU.
>
> > 3. Detect total system RAM.
>
> > 4. Detect GPU model.
>
> > 5. Detect GPU VRAM.
>
> > 6. Detect GPU backend: NVIDIA CUDA, Apple Metal, AMD ROCm/Vulkan, or CPU-only.
>
> > 7. Detect free disk space.
>
> > 8. Save a short report to hardware_report.md.
>
> > Use these starting rules for first-X-layers GPU offload:
>
> > - If VRAM is 8 GB or less: start with 0 GPU layers.
>
> > - If VRAM is around 12 GB: start with 6 GPU layers.
>
> > - If VRAM is around 16 GB: start with 10 GPU layers.
>
> > - If VRAM is 24 GB or more: start with 10 GPU layers.
>
> > - If VRAM is 32 GB or more: start with 20 GPU layers.
>
> > - If VRAM is 48 GB or more: start with 32 GPU layers.
>
> > - Never push VRAM to 100%. Leave headroom for KV cache, runtime buffers, and desktop/display overhead.
>
> > Use these starter inference settings:
>
> > - Context length: 16000 tokens.
>
> > - Flash attention: ON if supported by this runtime and hardware.
>
> > - KV cache type: use Q8 KV cache if supported, such as q8_0 for both K and V cache. If Q8 KV is not supported, use the runtime default.
>
> > - MTP/speculative decoding: use only if the installed runtime clearly supports Qwen3.6-MTP. Keep it simple: max draft tokens = 2. If unsupported, skip MTP and run normal decoding.
>
> > - Temperature: 0.6.
>
> > - Top-p: 0.95 if supported.
>
> > - Top-k: 20 if supported.
>
> > - Output length for smoke test: 300 to 500 tokens.
>
> > - Use runtime defaults for batch and ubatch.
>
> > Install or locate runtime:
>
> > 1. Prefer llama.cpp or a llama.cpp-compatible runtime that supports GGUF.
>
> > 2. If NVIDIA GPU is present, use or build CUDA support.
>
> > 3. If Apple Silicon is present, use or build Metal support.
>
> > 4. If AMD GPU is present, try Vulkan or ROCm only if supported.
>
> > 5. If no good GPU backend exists, use CPU mode.
>
> > 6. Run:
>
> > llama-cli --help > llama_help.txt
>
> > llama-server --help > llama_server_help.txt if server exists
>
> > 7. Use only flags that appear in the local runtime’s help output.
>
> > 8. Keep the offload strategy limited to “load the first X layers into VRAM.”
>
> > Model selection:
>
> > 1. Check whether a Qwen3.6-35B-A3B-MTP GGUF file already exists on the machine.
>
> > 2. If not, download one reasonable GGUF file, preferably Q4_K_M or similar 4-bit quantization.
>
> > 3. Do not download multiple huge model files without asking.
>
> > 4. Save model path and file size to model_report.md.
>
> > Create the starter command:
>
> > 1. Use the detected VRAM rule above to choose the first GPU layer count.
>
> > 2. Set context length to 16000.
>
> > 3. Turn flash attention on if supported.
>
> > 4. Use Q8 KV cache if supported.
>
> > 5. Use MTP/speculative decoding only if supported, with max draft tokens set to 2.
>
> > 6. Use temperature 0.6, top-p 0.95, top-k 20 if supported.
>
> > 7. The only offload variable is the number of first layers loaded into VRAM.
>
> > Example command template. Adapt only to flags supported by the installed runtime:
>
> > llama-cli \
>
> > -m "/path/to/Qwen3.6-35B-A3B-MTP-Q4_K_M.gguf" \
>
> > -p "Explain in plain English what a Mixture-of-Experts model is and why it can help with local AI inference on consumer hardware." \
>
> > -c 16000 \
>
> > -n 400 \
>
> > --n-gpu-layers STARTING_LAYER_COUNT \
>
> > --flash-attn on \
>
> > --cache-type-k q8_0 \
>
> > --cache-type-v q8_0 \
>
> > --temp 0.6 \
>
> > --top-p 0.95 \
>
> > --top-k 20
>
> > If the runtime uses -ngl instead of --n-gpu-layers, use -ngl.
>
> > If the runtime uses -fa instead of --flash-attn on, use -fa.
>
> > If the runtime does not support Q8 KV flags, remove them.
>
> > If the runtime does not support top-k or top-p flags, remove them.
>
> > If the runtime supports Qwen3.6-MTP/speculative decoding, add only the standard max-draft-token setting, for example:
>
> > --max-draft-tokens 2
>
> > If the runtime uses a different name for the same concept, use the equivalent flag shown in --help.
>
> > Run one quick smoke test:
>
> > 1. Run the starter command.
>
> > 2. Confirm the model loads.
>
> > 3. Confirm it generates coherent text.
>
> > 4. Record:
>
> > - prompt processing speed / prefill speed if printed
>
> > - decode tokens per second if printed
>
> > - total generated tokens
>
> > - peak VRAM usage
>
> > - peak system RAM usage
>
> > - whether there are errors or warnings
>
> > 5. Save output to smoke_test_output.txt.
>
> > Simple fallback rules:
>
> > - If out of VRAM: reduce GPU layers by 2 and try once more.
>
> > - If system RAM is exhausted: reduce context from 16000 to 8192 and try once more.
>
> > - If flash attention crashes: disable flash attention and try once more.
>
> > - If MTP/speculative decoding crashes: disable MTP and try normal decoding.
>
> > - If output is nonsense because chat formatting is wrong: inspect runtime documentation for Qwen chat-template support and fix the prompt/chat template.
>
> > - Do not run a long benchmark. Stop once one stable command works.
>
> > If server mode is available:
>
> > 1. Create a server command using the stable settings.
>
> > 2. Start the local server.
>
> > 3. Give me the browser URL, usually:
>
> > http://127.0.0.1:8080
>
> > 4. Give me the local API endpoint for other applications, usually:
>
> > http://127.0.0.1:8080/v1/chat/completions
>
> > 5. Confirm whether the endpoint is OpenAI-compatible.
>
> > Example server command template. Adapt only to supported flags:
>
> > llama-server \
>
> > -m "/path/to/Qwen3.6-35B-A3B-MTP-Q4_K_M.gguf" \
>
> > -c 16000 \
>
> > --n-gpu-layers BEST_STABLE_LAYER_COUNT \
>
> > --flash-attn on \
>
> > --cache-type-k q8_0 \
>
> > --cache-type-v q8_0 \
>
> > --temp 0.6 \
>
> > --top-p 0.95 \
>
> > --top-k 20 \
>
> > --host 127.0.0.1 \
>
> > --port 8080
>
> > Final deliverables:
>
> > 1. hardware_report.md
>
> > 2. model_report.md
>
> > 3. smoke_test_output.txt
>
> > 4. final_recommended_command.md
>
> > In final_recommended_command.md, give me:
>
> > - safest working command
>
> > - server command, if server mode works
>
> > - browser URL, if server mode works
>
> > - OpenAI-compatible endpoint URL, if server mode works
>
> > - whether flash attention worked
>
> > - whether Q8 KV worked
>
> > - whether MTP/speculative decoding worked
>
> > - GPU layer count used
>
> > - whether the model is practical on this hardware
>
> > - one recommended next step
>
> > Keep explanations short. Prioritize a stable working setup.
>
> # 12. Conclusion: the useful middle ground
>
> The consumer-hardware story is not “everyone needs a $4,000 GPU.” It is also not “ordinary RAM is just as good as VRAM.” The useful middle ground is that modern sparse models make mixed-memory inference more plausible. A decent GPU gives you fast local compute and fast resident memory. System RAM gives you capacity. MoE gives you an architecture where not every stored expert has to be active for every token.
>
> Dense models are simpler, and they remain excellent when the quantized model fits comfortably. But when the total model capacity begins to exceed VRAM, dense offload is punishing because dense active weights are hit every token. MoE offload can be more forgiving because the expert pool is large, but the token touches only selected experts. That is the core reason Qwen3.6-35B-A3B is such a good teaching example.
>
> The practical recommendation is straightforward: treat MoE offload as a configuration experiment. The broader lesson is that local AI is becoming useful not because consumer hardware suddenly became datacenter hardware, but because model architecture, quantization, and offload are giving ordinary PCs a new set of tradeoffs. The best setup may not be the biggest GPU you can buy. It may be the best balance of GPU, RAM, model sparsity, and carefully chosen residency.
>
> # Appendix: sources + references
>
> - [Qwen3.6-35B-A3B model card](https://huggingface.co/Qwen/Qwen3.6-35B-A3B)
>
> - [Qwen3.6-27B model card](https://huggingface.co/Qwen/Qwen3.6-27B)
>
> - [Qwen3.6 GitHub repository](https://github.com/QwenLM/Qwen3.6)
>
> - [Qwen llama.cpp local guide](https://qwen.readthedocs.io/en/latest/run_locally/llama.cpp.html)
>
> - [Qwen3 Technical Report](https://arxiv.org/abs/2505.09388)
>
> - [Hugging Face MoE explainer](https://huggingface.co/blog/moe)
>
> - [NVIDIA MoE architecture explainer](https://developer.nvidia.com/blog/applying-mixture-of-experts-in-llm-architectures/)
>
> - [Attention Is All You Need](https://arxiv.org/abs/1706.03762)
>
> - [NVIDIA RTX 5070 family specs](https://www.nvidia.com/en-us/geforce/graphics-cards/50-series/rtx-5070-family/)
>
> - [NVIDIA RTX 5090 specs](https://www.nvidia.com/en-us/geforce/graphics-cards/50-series/rtx-5090/)
>
> - [Kingston DDR5 bandwidth note](https://www.kingston.com/en/memory/memory-population-rules)
>
> - [JEDEC GDDR7 standard summary](https://pcdandf.com/pcdesign/index.php/editorial/menu-news/fab-news/17940-jedec-publishes-gddr7-graphics-memory-standard)
>
> - [Qwen3.6 MoE coding expert saliency](https://huggingface.co/datasets/sjakek/qwen36-moe-coding-expert-saliency)
>
> - [Qwen3.6 Q4_K_M saliency vs attention residency](https://huggingface.co/datasets/sjakek/qwen36-q4km-saliency-vs-attention-residency-100)
>
> - [Qwen3.6 SWE-bench Lite saliency layer compare](https://huggingface.co/datasets/sjakek/qwen36-q4km-swebench-lite-saliency-overfit-layercompare)
>
> - [Qwen3.6 coding layer bottleneck profiles](https://huggingface.co/datasets/sjakek/qwen36-coding-layer-bottleneck-profiles)
>
> - [Qwen3.6 MTP/turbo KV analysis](https://huggingface.co/datasets/sjakek/qwen36-mtp-turbo-kv-analysis)
>
> - [Unsloth Qwen3.6-35B-A3B GGUF Q4_K_M](https://huggingface.co/unsloth/Qwen3.6-35B-A3B-GGUF/blob/main/Qwen3.6-35B-A3B-UD-Q4_K_M.gguf)
>
> - [Simon Willison Qwen3.6-27B local run note](https://simonwillison.net/2026/apr/22/qwen36-27b/)
>
> [Original article](https://x.com/JakeKAllDay/status/2059310445798797748) — 70 likes | 10 reposts | 11 replies
