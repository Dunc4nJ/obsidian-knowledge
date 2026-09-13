---
created: 2026-09-11
description: "@net_termina (Killy) posts a 'max optimized' DeepSeek-V4.1-Flash deployment on four RTX PRO 6000 Blackwell Workstation cards with a Threadripper PRO 9985WX and 639 GB of DDR5 - 165/328/331 tok/s single stream, 1,415-3,081 tok/s aggregate at 32 concurrent agents, 16,300 tok/s cold prefill at 60K tokens, the 203 GB Engram tables pinned in host RAM - and publishes the whole recipe (SGLang preview image, two sm_120 patches, eleven tuned block-FP8 GEMM tables, receipts) under Apache-2.0; every number here was checked against the repo's logs."
source: https://x.com/net_termina/status/2098437949331230748
author: "@net_termina"
type: post
tags: [local-inference, hardware, deepseek, v4.1-flash, rtx-pro-6000, sglang, sm120, dspark, engram, concurrency, agentic-coding, recipe, opinion-verified]
---

## Key Takeaways

- **This is the four-card end state of a home CUDA engine, measured, with the recipe published.** Four RTX PRO 6000 Blackwell Workstation Edition cards (600 W parts, water-cooled, running at 300-460 W), a Threadripper PRO 9985WX, 639 GB of DDR5 and one NVMe. The 307 GB backbone (FP8 attention, the checkpoint's own FP4 experts) is tensor-and-expert-parallel across the four cards; the 203 GB Engram lookup tables (189 GiB pinned) live in host RAM at "zero measured cost" because a token reads only a few KB of them. Single stream: 165 tok/s prose, 328 code, 331 JSON, first token in 0.1 s. Thirty-two agents in flight: 1,415 to 3,081 tok/s aggregate, 47 to 100 per stream. Cold prefill 14,400 tok/s at 15.6K tokens and 16,300 at 60K. Same GPU class as [[DeepSeek-V4.1-Flash runs at 200 tok-s on 4x RTX PRO 6000 Max-Q with only 64GB RAM because its 203GB Engram lives on NVMe - true for a 384GB-VRAM box, not for two cards]], bigger host, better numbers.

- **The recipe is three sm_120-specific fixes on top of SGLang's day-0 preview, and it is reproducible from the repo.** A launch flag forces the FP4 indexer's DeepGEMM plan back on (the preview's hardware hook turns it off for workstation Blackwell and warmup dies); a patch re-tiles V4.1's candidate KV cache into the 64-token pages FlashInfer's sm_120 sparse-MLA prefill kernel accepts; and eleven block-FP8 GEMM tuning tables keyed to the card's device name lift single-stream decode from 120/248/239 to 161/331/321 tok/s with no other change. The repo (`killy-netsphere/dsv41-flash-rtx-pro-6000`, Apache-2.0) carries the patches, the tables, the launch script and the logs. The Max-Q reports a different device name, so it needs the tables renamed or re-tuned, minutes per shape.

- **The ablation ladder settles several arguments this vault has been carrying.** Without DSpark the model decodes at 36.9 tok/s; with block-5 drafting it is 3.2x faster on prose and 6.6x on code, confirming that speculative decoding is the largest software lever (the finding in [[Qwen3.8-27B with NVFP4 plus DFlash2 decodes at 358.8 tok-s peak and 220-240 sustained on one RTX 5090 - Roy's Opus-4.6-at-home claim]]). Decoder SWA bounded replay is a free +41% prefill. NCCL protocol, P2P level, custom versus NCCL all-reduce and CUDA-graph caps are all within noise, so the PCIe interconnect is not the bottleneck for TP4/EP4 on this model. Pure tensor parallel fails the MXFP4 kernel's 128-multiple rule, so expert parallel across exactly four cards is mandatory; the recipe does not shrink to two.

- **Host RAM is now a first-class inference tier, which changes what "enough RAM" means.** Engram resident needs about 189 GiB plus headroom; 0xSero's prior-art repo runs the same checkpoint on a 128 GB host by streaming Engram rows from NVMe through a bounded cache, at lower throughput (721 tok/s aggregate on seven 400K-token requests). Between them they bracket the choice for anyone specifying a host: 256 GB works but tight, 512 GB is comfortable, 128 GB means NVMe. The design that makes this possible is described in [[DeepSeek-V4.1-Flash cuts global KV cache to 890 bytes per token - a quarter of V4-Flash and 437x below V1 - by stacking cross-layer CSA2 reuse, FP4 caching, and a causal encoder-decoder]].

- **The operator does not write code; Claude built and measured the whole thing.** The README says so plainly. That is the operating model for a home lab run over SSH and a BMC console, and it is the strongest evidence so far that the "build it with Claude" plan is realistic at this level of complexity, patches and kernel tuning included. Same conclusion as the ownership thesis in [[buying local hardware isn't cope, it's a bet that open models beat the labs and that no more PCIe GPUs are coming - Roy's ownership thesis]], with receipts.

*The results panel from the post - single-stream, concurrency and prefill numbers for the release configuration:*
![[net_termina-230748-001.jpg]]

## External Resources

- [killy-netsphere/dsv41-flash-rtx-pro-6000](https://github.com/killy-netsphere/dsv41-flash-rtx-pro-6000) - the recipe: `serve.sh`, two patches, eleven tuned FP8 tables, ladder and storm logs, agentic summaries, image digest.
- [0xSero/deepseek-v4.1-flash-4x-rtx-pro-6000](https://github.com/0xSero/deepseek-v4.1-flash-4x-rtx-pro-6000) - prior art on the same GPU class with a 128 GB host and an NVMe Engram reader.
- [SGLang day-0 post for DeepSeek V4.1](https://www.lmsys.org/blog/2026-09-10-deepseek-v41) - the preview image the recipe pins by digest.
- [DeepSeek-V4.1-Flash on Hugging Face](https://huggingface.co/deepseek-ai/DeepSeek-V4.1-Flash) - the checkpoint (FP4 routed experts, FP8 Engram, DSpark bundled, MIT).

## Original Content

> [!quote]- Full thread (@net_termina / Killy, 11 Sep 2026)
> @net_termina (Killy) - 2026-09-11
>
> Deepseek V4.1 Flash Max Optimized
>
> 365 code / 163 prose / 333 json
> 3081 toks 32 concurrency
> 131k context, 3.7mil KV, 16k prefill at 60k
>
> 203GB engram on RAM
> Tuned block-FP8 GEMM table
>
> Annihilated all my agentic tasks https://t.co/pmOEusWUw3
> VIDEO: https://pbs.twimg.com/amplify_video_thumb/2098437749355253762/img/qBSMogt01CNA8pqR.jpg
> PHOTO: https://pbs.twimg.com/media/HR8mA9cWoAo8c8m.jpg
> *(results panel - embedded above; the video is a screen recording of the agentic run and is not captured)*
> date: Fri Sep 11 15:46:08 +0000 2026
> url: https://x.com/net_termina/status/2098437949331230748
> likes: 12  retweets: 0  replies: 2
>
> Engagement: 12 likes | 0 retweets | 2 replies
> [Original post](https://x.com/net_termina/status/2098437949331230748)
>
> @net_termina (Killy) - 2026-09-11 (second post in the thread)
>
> https://t.co/hZRVddFw2u
>
> 60% of the model is experts and attention, 307 GB, resident across 4× 96 GB. The other 40% is Engram: n-gram lookup tables read a few KB per token, so they sit in host RAM (639 GB here) at zero measured cost. V4.1 was built for exactly this split.
> date: Fri Sep 11 15:46:10 +0000 2026
> url: https://x.com/net_termina/status/2098437954808996045
> likes: 2  retweets: 0  replies: 0
>
> Engagement: 2 likes | 0 retweets | 0 replies
> [Original post](https://x.com/net_termina/status/2098437954808996045) - the link resolves to https://github.com/killy-netsphere/dsv41-flash-rtx-pro-6000
