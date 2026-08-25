---
created: 2026-08-25
description: 0xSero reports running DeepSeek-V4-Flash (284B) on ~$4.7K of hardware at 47 tok/s with 400K context, by stacking EXL3 3-bit quantization with an ~18.5% expert prune to fit 128GB VRAM (context + activations included) — with the broader point that stacking pruning on top of quantization is how the hardware floor for frontier-class local models keeps dropping.
source: https://x.com/0xSero/status/2091216418599514159
author: "@0xSero"
type: post
tags: [local-inference, hardware, quantization, pruning, exl3, deepseek, moe, vram, cost]
---

## Key Takeaways

- **Frontier-class local inference at ~$4.7K: DeepSeek-V4-Flash (284B) at 47 tok/s with 400K context in 128GB VRAM.** The recipe is a *stack*, not a single technique: **EXL3 3-bit quantization** plus an **~18.5% expert prune**, with the 128GB figure including context and activations — the practical demonstration that a 284B MoE is a consumer-adjacent workload once you attack both the weight precision *and* the expert count.

- **The transferable insight: stack pruning on top of quantization.** "Stacking pruning on quantising is important if we want to push the floor even lower" — the two levers are largely orthogonal (bits per weight vs. how many experts you keep), so composing them lowers the VRAM floor faster than pushing either alone. MoE architectures are what make the second lever available at all: pruning experts is a structural cut unavailable to dense models, and it targets exactly the parameters that dominate a modern MoE's footprint ([[NVIDIA's hardware-friendly LLM design guide - near-square tile-aligned dimensions, width over depth, NVFP4, and wide expert parallelism|wide-expert-parallel designs]] are the serving-side mirror of the same fact).

- **Context: same model, much lower price point than the rack-scale self-host.** [[camelAI self-hosts DeepSeek V4 Flash on 4x RTX PRO 6000 Blackwell for a fixed-cost free tier, with KV cache as the real bottleneck|camelAI runs the same DeepSeek-V4-Flash on 4x RTX PRO 6000 Blackwell]] at ~$4-6K/month spot for a production free tier; this is the single-box floor of that same curve — and 400K context is notable because [[Step 01 - Decode is memory-bandwidth-bound (the roofline)|decode is memory-bandwidth-bound]] and the KV cache, not the weights, is usually what breaks long-context local setups.

## External Resources

- Original post: [@0xSero, 2026-08-22](https://x.com/0xSero/status/2091216418599514159) — links the repo enabling the setup
- Techniques: EXL3 (ExLlamaV3 quantization) · MoE expert pruning · DeepSeek-V4-Flash

## Original Content

> [!quote]- Full post (@0xSero, 2026-08-22)
> This awesome repo allows you to run Deepseek-v4-flash on 4.7k USD or even less @ 47 tok/s and 400k context. 
>
> The way I got this to work was exl3 3 bit quantisation along with an 18.5% prune.
>
> Stacking pruning on quantising is important if we want to push the floor even lower https://t.co/YzJ51XlU1v
>
> *The compression stack: 284B → EXL3 3-bit → ~18.5% experts pruned → 128GB VRAM (context + activations included), 47 tok/s at 400K context for $4.7K or less:*
> ![[0xsero-deepseek-001.jpg]]
