---
created: 2026-09-01
description: Hesamation's claim that GLM-5.3-Flash "pushed the Pareto frontier" — 57 on Artificial Analysis Intelligence Index v4.1.1 at $0.045 per task, matching Opus 4.8 at ~45x less. The index scores check out against AA directly (Flash 57, GLM-5.3 60), but the chart's own label reads "(discounted)" and the price is a 50 percent launch promo; AA lists Flash at Z.ai standard $0.15/$0.50 per 1M and does not rank Opus 4.8 at all, so the Opus-parity claim traces to Z.ai's own launch chart, where Flash reaches parity by spending more output tokens. The durable part is the architecture — 320B-A18B, MIT, 1M context, 3.01x less per-layer attention compute and 4.44x smaller per-layer KV cache than GLM-5.3.
source: https://x.com/Hesamation/status/2092622370183729553
author: "@Hesamation (hesam)"
type: post
tags: [local-inference, glm, open-weights, pareto-frontier, artificial-analysis, kv-cache, sparse-attention, moe, inference-pricing, benchmarks]
---

## Key Takeaways

- **The intelligence numbers are real and independently checkable; the price on the chart is not the price you pay.** Artificial Analysis's own model pages confirm both halves of the comparison exactly: **GLM-5.3-Flash scores 57** and **GLM-5.3 (max) scores 60** on Intelligence Index v4.1.1 (9 evals: GDPval-AA v2, τ³-Banking, Terminal-Bench v2.1, SciCode, HLE, GPQA Diamond, CritPt, AA-Omniscience, AA-LCR). But the highlighted point in the chart is labelled, in the chart's own text, **"GLM-5.3-Flash (discounted)"** — and a reply thread supplies the receipt: LLMPriceIndex shows the OpenRouter launch listing at **$0.075/M input, $0.25/M output**, which is exactly half the **$0.15/$0.50** standard rate that Z.ai published in its own launch thread and that AA lists on the model page. At standard pricing the $0.045 point roughly doubles and slides a full tick right on a log axis. AA's own totals corroborate the direction: evaluating the index cost **$138.02 for Flash vs $1,238.50 for GLM-5.3 (max)** — a **9.0x** spread, not the 15.1x that $0.045-vs-$0.68 implies. Casey's reply ("I need to reproduce that $0.045 per task before I believe the Opus comparison") is the correct instinct.

- **"Matches Opus 4.8 on AA's intelligence score" is not an AA claim — AA does not rank Opus 4.8.** Searching AA's model index, the only occurrence of the string is inside a *configuration name*: "Claude Fable 5 (Adaptive Reasoning, Max Effort, **Opus 4.8 Fallback**)". AA's current top of the index is Claude Opus 5 (max) and (xhigh) at **63**, Claude Fable 5 (with fallback) at **62**, Claude Opus 5 (high) and GPT-5.6 Sol (max) at **61**. Flash's 57 ties Qwen3.8 Max and sits below GLM-5.3's 60 — genuinely strong for the price, and genuinely not frontier-matching. The Opus-parity claim actually originates in **Z.ai's own launch chart**, and even there it is narrower than the headline: on Z.ai Code Bench v1.0 (run through Claude Code 2.1.207), GLM-5.3-Flash at Max effort reaches **~29.0% at ~138K output tokens per task** against Claude Opus 4.8 at **~29.5% at ~120K** — parity with a superseded model, bought with ~15% more output tokens, while Claude Fable 5 at Max sits at **~39.5%**. AA separately flags Flash as verbose (**150M output tokens** on the index vs a 110M median), which is why per-task cost and per-token price tell different stories.

- **Strip the promo and the durable claim is architectural — and it is the one that matters for a box you own.** Z.ai's architecture chart substantiates hesamation's third bullet precisely: **3.01x lower per-layer attention compute** and **4.44x smaller per-layer KV cache at 1M context**, both measured against GLM-5.3. The mechanism is a hybrid stack — three blocks of Linear Attention to one block of Sparse Attention, the sparse path routed through an Indexer with 4x pooling and TopK KV-block selection, over an MoE body with mHC layers, an MTP layer, and a ViT tower for image input. Read the same chart honestly, though, and **DeepSeek-V4 and Kimi-K3 both sit *below* Flash on per-layer KV cache** — the 4.44x is a win over its own sibling, not over the field. OussPoly's reply gets the emphasis right: "the KV cache reduction at long context is the real story, that is where inference costs actually compound" — the same pressure that [[LMCache offloads paged KV to system RAM and NVMe, cutting 128K-context time-to-first-token from 68 seconds to 1.4 on 4x DGX Spark|LMCache attacks by offloading]] and that [[camelAI self-hosts DeepSeek V4 Flash on 4x RTX PRO 6000 Blackwell for a fixed-cost free tier, with KV cache as the real bottleneck|camelAI hit as the binding constraint on a self-hosted deployment]].

- **Why a model release belongs in a hardware folder: 320B total, 18B active, MIT license, 1M context — the active-parameter count is what your memory bus actually pays for.** Z.ai's launch thread gives the shape (**320B-A18B**, natively multimodal, MIT, previously previewed as "Ox Alpha", and notably **"running entirely on Chinese AI chips"**), Unsloth replied the same day that local quants were in progress, and AA measures Z.ai's own API at **44.6 tok/s**. Eighteen billion active parameters is a decode workload a single fast bus can serve, which puts this model squarely in the regime the rest of this folder sizes hardware for — the same MoE arithmetic behind [[EXL3 3-bit plus an 18.5 percent expert prune runs DeepSeek-V4-Flash 284B at 47 tok-s on 4.7K of hardware|stacking 3-bit quantization with an expert prune to fit a 284B model in 128GB]], with the caveat from [[buy the RAM that holds the model - a SKU-by-SKU M5 Mac guide with the CUDA tax and separate decode-prefill predictions|the M5 SKU guide]] that MoE realizes only ~28% of theoretical bandwidth against 70-90% for dense models, so nominal TB/s overstates what a 320B-A18B model will actually see. [[GLM-5.3-Flash FP8 really is 306GB and really fits in 512GB - but 60 t-s is 80-90 percent of the roofline on a machine that does not ship until October|The model-card fact-check of running this specific model locally]] lands exactly there: 305.8 GiB of FP8 weights do fit a 512GB Studio and the hybrid stack keeps the cache near-free (~0.7 GiB at 128K), but the circulating ~60 tok/s figure assumes 80-90% of the 1.2 TB/s roofline against a measured ~28-40%.

- **The buy-vs-rent baseline moved, which is the practical consequence for anyone pricing owned hardware.** [[a 100K DGX Station pays back in 19 months at 30 percent duty - but only if you can keep 64 requests concurrent|The DGX Station payback model]] is computed against $1/M output tokens of API pricing; an open-weights model at **$0.50/M output standard, $0.25/M promotional** moves that denominator by 2-4x and lengthens every payback horizon built on it. Two caveats on that being permanent, both opinion rather than fact: hesamation's own framing ("intelligence is getting cheaper brutally fast") is an extrapolation from a launch-week price, and a reply asserts Chinese token rates are "heavily subsidised by CCP in a bid for market takeover" — an unevidenced claim, but it names the live question, which is whether these prices reflect a cost curve or a customer-acquisition budget. The MIT weights are the hedge that makes the question less urgent: if the API price moves, the model is still yours to host.

*Pareto frontier of AA Intelligence Index v4.1.1, all 59 models, cost per task on a log axis — note the highlighted point's own label, "GLM-5.3-Flash (discounted)":*
![[hesamation-729553-001.jpg]]

## External Resources

- Original post: [@Hesamation, 2026-08-26](https://x.com/Hesamation/status/2092622370183729553) — quote-tweeting the launch
- Launch thread: [@Zai_org, 2026-08-26](https://x.com/Zai_org/status/2092616204787626030) — specs, pricing, benchmarks
- [GLM-5.3-Flash blog post](https://z.ai/blog/glm-5.3-flash) — Z.ai's own writeup
- [zai-org/GLM-5.3-Flash on Hugging Face](https://huggingface.co/zai-org/GLM-5.3-Flash) — MIT-licensed weights
- [Z.ai API docs](https://docs.z.ai/guides/vlm/glm-5.3-flash) — VLM guide for the multimodal path
- [Artificial Analysis: GLM-5.3-Flash](https://artificialanalysis.ai/models/glm-5-3-flash) — independent index score, pricing, and eval cost (used to verify the claims above)
- [Artificial Analysis: GLM-5.3 (max)](https://artificialanalysis.ai/models/glm-5-3) — the 60-point sibling used as the comparison baseline
- [Artificial Analysis Intelligence Index methodology](https://artificialanalysis.ai/evaluations/artificial-analysis-intelligence-index) — the 9 evaluations behind the score
- [@LLMPriceIndex on the OpenRouter listing](https://x.com/LLMPriceIndex/status/2092620781997982093) — $0.075/M input, $0.25/M output at launch

## Original Content

> [!quote]- Full post (@Hesamation, 2026-08-26)
> BRO… GLM 5.3 Flash (ox alpha) pushed the Pareto frontier.
>
> it matches Opus 4.8 on AA's intelligence score but is ~45x cheaper:
>
> > 57 intelligence vs 60 for GLM-5.3
> > $0.045/task vs $0.68 for GLM-5.3
> > 3x lower attention compute + 4.4x smaller KV cache at 1M context
>
> Intelligence is getting cheaper brutally fast.
>
> *Pareto frontier of the Artificial Analysis Intelligence Index v4.1.1 — all 59 models, cost per Intelligence Index task:*
> ![[hesamation-729553-001.jpg]]
>
> QT @Zai_org:
> > Introducing GLM-5.3-Flash
> >
> > - Leading capabilities at a highly competitive price
> > - Natively multimodal with a 1M-token context window
>
> [Original post](https://x.com/Hesamation/status/2092622370183729553)

> [!quote]- Quoted launch thread (@Zai_org, 2026-08-26)
> Introducing GLM-5.3-Flash
>
> - Leading capabilities at a highly competitive price
> - Natively multimodal with a 1M-token context window
> - A 320B-A18B model released under the MIT License
> - Previously previewed as Ox Alpha, running entirely on Chinese AI chips
>
> Blog: https://z.ai/blog/glm-5.3-flash
>
> Available now across all official platforms:
>
> Weights: https://huggingface.co/zai-org/GLM-5.3-Flash
> API: https://docs.z.ai/guides/vlm/glm-5.3-flash
> Coding Plan · ZCode · Chat: https://chat.z.ai/ · AutoClaw
>
> *Six-benchmark evaluation against GLM-5.2, DeepSeek-V4-Vision-Exp, Claude Opus 4.8, GPT-5.6 Terra, and Gemini 3.7 Flash:*
> ![[zaiorg-626030-001.jpg]]
>
> ---
>
> Standard API Pricing for GLM-5.3-Flash (per 1M tokens)
>
> - Input: $0.15
> - Output: $0.50
> - Cached input: $0.03
>
> ---
>
> On the Z.ai Code Bench, which measures real-world coding performance, GLM-5.3-Flash clearly outperforms GLM-5.2 at every effort level and performs on par with Claude Opus 4.8.
>
> *Z.ai Code Bench v1.0, evaluated on Claude Code 2.1.207 — accuracy vs average output tokens per task, by effort level:*
> ![[zaiorg-626030-003.jpg]]
>
> ---
>
> Architectural enhancements, combined with an optimized pre-training corpus, enable GLM-5.3-Flash to deliver greater intelligence with less compute.
>
> *GLM-5.3-Flash architecture, with per-layer KV-cache size and per-layer attention compute versus GLM-5.3, Kimi-K3, and DeepSeek-V4:*
> ![[zaiorg-626030-002.jpg]]
>
> [Original thread](https://x.com/Zai_org/status/2092616204787626030)

> [!quote]- Substantive replies
> @OussPoly (Oussama) — 2026-08-26:
> GLM 5.2 is already surprisingly capable for the price. The KV cache reduction at long context is the real story, that is where inference costs actually compound.
>
> @mylifenthestack (Casey) — 2026-08-27:
> I need to reproduce that $0.045 per task before I believe the Opus comparison.
> > QT @LLMPriceIndex: GLM 5.3 Flash is live on OpenRouter. Z.ai's new Flash model lands at $0.075/M input, $0.25/M output.
>
> @UndefinedDzx (Undefined) — 2026-08-27:
> You are beyond foolish if you think Chiense token rates aren't heavily subsidised by CCP in a bid for market takeover. Like literally every single other thing made in China.
>
> @AGTPinsights (AGTP) — 2026-08-26:
> The efficiency is stunning - we actually broke down what's in this model and why it matters here:
> > QT @AGTPinsights: Ox Alpha just got unmasked today. Here's what you need to know. OpenCode said Ox Alpha, the free stealth model, hit 42 trillion tokens processed in just 6 days, making it the most-used model on the platform after DeepSeek Flash's 56-day run.
>
> @notjazii (J A Z I I) — 2026-08-26:
> anthropic is getting cooked by everyone atp
>
> @UnslothAI (in the launch thread) — 2026-08-26:
> Huge congrats Z ai team once again and thank you for open-source! We are working hard on making GLM-5.3-Flash available for you all to run locally hopefully later today/early tomorrow!
