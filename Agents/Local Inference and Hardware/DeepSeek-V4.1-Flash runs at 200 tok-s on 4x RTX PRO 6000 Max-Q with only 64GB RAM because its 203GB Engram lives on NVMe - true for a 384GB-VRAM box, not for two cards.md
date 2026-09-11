---
created: 2026-09-11
description: "@0x0SojalSec reposts Fraser Price's localmaxxing run of DeepSeek-V4.1-Flash (552B backbone + 196B Engram, shipped as 510 GB) on 4x RTX PRO 6000 Max-Q with a 64 GB-RAM Threadripper host - 197.6 tok/s decode and 5,665 tok/s prefill on a 28K prompt - and frames it as 'you don't need 256 GB RAM'; verified against the run record, the HF checkpoint and the tech report, the claim holds only because 384 GB of VRAM holds the backbone and the 203 GB Engram tables stream from disk."
source: https://x.com/0x0SojalSec/status/2098193131762242018
author: "@0x0SojalSec"
type: post
tags: [local-inference, hardware, deepseek, v4.1-flash, engram, nvme, offloading, rtx-pro-6000, localmaxxing, dspark, opinion-verified]
---

## Key Takeaways

- **The benchmark is real but it is not the poster's, and the hardware is the whole story.** The screenshot is localmaxxing run `cmtvotj3u00a2ps01mw2s9hzf` by Fraser Price: 197.6 tok/s decode, 5,665 tok/s prefill on a 28,031-token prompt, vLLM tensor-parallel 4 with DSpark speculative decoding, on **4x RTX PRO 6000 Blackwell Max-Q (384 GB VRAM)**, a Threadripper 9960X and **64 GB RAM**. Later runs the same day with a custom `b12x` MoE backend reach 290-312 tok/s. A reply in the thread says it plainly: "you don't need 256GB RAM, you need 384GB VRAM." Compare the same class of box in [[camelAI self-hosts DeepSeek V4 Flash on 4x RTX PRO 6000 Blackwell for a fixed-cost free tier, with KV cache as the real bottleneck]].

- **Why 64 GB of host RAM is enough here: the 203 GB Engram is a lookup table, not a matmul.** The shipped checkpoint is 510 GB in 48 files: about 307 GB of backbone (FP8 attention, FP4 experts) plus two 101.5 GB files holding the 196B-parameter Engram embedding tables. Engram addresses depend only on the input tokens, so the tech report prefetches them from host memory; with 64 GB of RAM they can only be streamed from NVMe, which is what the poster describes. Mechanism and full report in [[DeepSeek-V4.1-Flash cuts global KV cache to 890 bytes per token - a quarter of V4-Flash and 437x below V1 - by stacking cross-layer CSA2 reuse, FP4 caching, and a causal encoder-decoder]]; an expert's reading of the same architecture in [[stochasm reads DeepSeek-V4.1-Flash's causal encoder-decoder as per-layer YOCO on the global CSA2 branch only - self-attention with prefilled KVs, not cross-attention]].

- **The "Flash" tier just grew 1.9x and stopped fitting two cards.** DeepSeek-V4-Flash shipped at 160-167 GB and fit 2x RTX PRO 6000 or a 256 GB Mac; V4.1-Flash's 307 GB backbone does not, and its experts are already FP4 so NVFP4 re-quants save little. The two-card paths are expert offload to host RAM (bandwidth-bound, so populate all memory channels - the arithmetic in [[sparse experts turn cheap DDR5 into usable inference memory - Jake's MoE offload primer computes 257 GB-s blended for Qwen3.6-35B-A3B vs 122 dense]] applies) or pruned/2-bit community quants that nobody has verified yet (compare [[EXL3 3-bit plus an 18.5 percent expert prune runs DeepSeek-V4-Flash 284B at 47 tok-s on 4.7K of hardware]]). A four-slot host is the durable answer.

- **The model is built for input-heavy agent loops, which is where GPU compute already wins.** 8B active parameters at prefill versus 16B at decode, a global KV cache of 890 bytes per token (about 0.9 GB for a full 1M-token agent), and persistent KV designed to live on SSD or host RAM (the tier [[LMCache offloads paged KV to system RAM and NVMe, cutting 128K-context time-to-first-token from 68 seconds to 1.4 on 4x DGX Spark]] describes). Concurrency is bounded by weights and compute, not KV, so continuous batching on Blackwell cards compounds. Engine support arrived CUDA-first: SGLang merged V4.1 fixes within a day and has sm120 (RTX PRO 6000) patches open; vLLM has a tracking issue; llama.cpp's converter PR is open; MLX has nothing.

- **Quality: strong on ordinary agentic coding, not a new intelligence frontier.** Artificial Analysis Intelligence Index v4.3 scores it 40, below GLM-5.3-Flash (42), Kimi K3 (44) and GLM-5.3 (45), and above DeepSeek V4-Flash (35). DeepSeek's own table claims DeepSWE 74.2 (Opus-5 74.0) and Terminal-Bench 2.1 90.6, but trails badly on Terminal-Bench 3.0/4.0 and HLE. It is MIT-licensed and multimodal. For a home lab the lesson is the direction of the memory curve, not this model's score - the bet described in [[buying local hardware isn't cope, it's a bet that open models beat the labs and that no more PCIe GPUs are coming - Roy's ownership thesis]] now needs four slots, not two.

*The localmaxxing run card the post reproduces - DeepSeek-V4.1-Flash, batch 1, 28,031-token input, 197.6 tok/s output, 5,665.5 tok/s prefill:*
![[0x0sojalsec-242018-001.jpg]]

## External Resources

- [DeepSeek-V4.1-Flash on Hugging Face](https://huggingface.co/deepseek-ai/DeepSeek-V4.1-Flash) - official weights (510 GB, MIT), model card, config, and the tech report PDF.
- [localmaxxing model page](https://www.localmaxxing.com/en/models/deepseek-ai/DeepSeek-V4.1-Flash) - the four Fraser Price runs (197.6 to 312.5 tok/s) with hardware and command lines.
- [vLLM tracking issue #56400](https://github.com/vllm-project/vllm/issues/56400), [SGLang sm120 PR #38970](https://github.com/sgl-project/sglang/pull/38970), [llama.cpp convert PR #28696](https://github.com/ggml-org/llama.cpp/pull/28696) - engine support status as of 2026-09-11.
- [Artificial Analysis: DeepSeek V4.1 Flash](https://artificialanalysis.ai/models/deepseek-v4-1-flash) - Intelligence Index v4.3 score 40, $0.30/$1.20 per M tokens.

## Original Content

> @0x0SojalSec (Md Ismail Šojal 🕷️) - 2026-09-10
>
> You don’t need 256GB+ RAM to run a DeepSeek-V4.1-Flash 763B model locally,
>
> - Only need 64GB system RAM.
> - offloaded a 200GB Engram to NVMe and hit 200 TPS full precision on 4 Max-Q cards with only 64GB system memory.
>
> DeepSeek 4.1 Flash + DSpark. https://t.co/r1mitHE9ch
> PHOTO: https://pbs.twimg.com/media/HR5GX5ja4AAdCvT.jpg
> *(run card - embedded above)*
> date: Thu Sep 10 23:33:19 +0000 2026
> url: https://x.com/0x0SojalSec/status/2098193131762242018
> likes: 570  retweets: 26  replies: 28
>
> Engagement: 570 likes | 26 retweets | 28 replies
> [Original post](https://x.com/0x0SojalSec/status/2098193131762242018)

> @0x0SojalSec (Md Ismail Šojal 🕷️) - 2026-09-10 (second post in the thread)
>
> Official weights: - https://t.co/WGFFHhQcZA
> date: Thu Sep 10 23:33:20 +0000 2026
> url: https://x.com/0x0SojalSec/status/2098193135210037358
> likes: 13  retweets: 0  replies: 0
>
> Engagement: 13 likes | 0 retweets | 0 replies
> [Original post](https://x.com/0x0SojalSec/status/2098193135210037358) - the link resolves to https://huggingface.co/deepseek-ai/DeepSeek-V4.1-Flash
