---
created: 2026-07-25
description: Shrey Birmiwal and Anish Bhat show that specializing a block-diffusion speculative-decoding drafter (Qwen3-8B DFlash) with rank-16 LoRA lifts acceptance on out-of-distribution languages up to +46% (15.3% wall-clock), but languages interfere so little that one combined LoRA captures nearly all the gain — with real interference and bigger headroom only in fine-grained domains like code and math.
source: https://x.com/shreybirmiwal/status/2080511860235976926
type: paper
authors:
  - Shrey Birmiwal
  - Anish Bhat
---

## Key Takeaways

- A speculative-decoding drafter is an approximation that must *copy* the target (not be externally correct), so it develops long-tail gaps — and a rank-16 LoRA on the block-diffusion drafter (z-lab's Qwen3-8B DFlash 1B) fills exactly those out-of-distribution weak spots. Base DFlash acceptance varies ~4x across 26 WildChat languages (English 12.89% down to Polish 3.57%), and the weakest languages gain most (Hungarian +46% relative / +1.80pp) while already-saturated ones like English can even slow slightly. This is the acceptance-rate-as-distributional-overlap lever from [[Step 04 - Draft models and the acceptance-rate lever (α = distributional overlap)]] applied surgically — LoRA shrinks the drafter-target gap only where it's widest — on the DFlash parallel-drafter family described in [[elie breaks down DeepSeek's DSpark, a semi-parallel speculative decoder that fuses DFlash's parallel head with an Eagle-style Markov step for +50% throughput and up to 80% lower latency in DeepSeek-V4 production]] and [[Hao AI Lab argues DSpark and JetSpec split the speculative-decoding throughput-latency frontier by adding causality to cheap parallel drafting]].
- Per-domain LoRA beats a per-domain full fine-tune on every language tested: tuning all parameters at once is data-starved on the same small dataset, whereas a rank-16 adapter (a tiny slice of parameters) converges much faster. A rank sweep found little difference between rank 4/16/64, which matters because lower rank means fewer adapter weights to move in and out of memory.
- Interference between cleanly separable domains is surprisingly low: a single "combined" LoRA over all 26 languages captures nearly all the specialist gain (specialists +0.85pp vs combined +0.70pp over base — a delta of just +0.15pp; specialists win 19/26 but the combined adapter wins 6, on low-resource languages where cross-lingual transfer helps). Because hidden states separate languages cleanly, a tiny 2-layer MLP router (20480→512→26, 84.7% val / 81.6% test accuracy) can pick adapters at negligible cost — but specialization is only strictly necessary when the model *can't* separate the task in its hidden state, so for languages the first move is just adding more OOD training data.
- Interference becomes real in fine-grained English subdomains (python, sql, legal, medical, financial, math reasoning, summarization): per-domain specialists beat base 7/7, but the combined adapter retains only ~20% of the specialist gain there, versus most of it in the language setting. An interference ladder confirms the trend — gain retained falls 74% → 70% → 67% as you fold 10 → 20 → 40 domains into one adapter — which is exactly where per-workload specialists earn their keep.
- On serving, unmerged hot-swappable LoRAs are unworkable today (vLLM lacks punica-style batched adapter kernels, so hot-swap drops to 0.825x vs base DFlash), while merged-combined (one adapter folded into the drafter, +5.9% wall-clock over base DFlash with a 0.073s one-time merge) and N-merged-own specialists (+6.4%, only ~0.5% more, at the cost of storing N drafters and an MoE-speculation-like memory-pipe hit under heavy batches) both work. Speedups are batch-size-dependent — up to +15.3% (Swedish specialist) and +12% at batch 1, +5-7% on a mixed 16-language stream — and cross break-even around batch 14-16 as serving shifts from memory-bound to compute-bound — the same saturated-fleet regime where [[Red Hat frames prefill-decode disaggregation, KV-cache tiering, and speculative decoding as the three llm-d deployment levers for distributed AI inference]] notes speculative decoding turns into a net loss. The authors frame this as complementary to Modal's and Baseten's per-workload speculators — [[Modal argues speculative decoding is the only inference optimization that matters, and custom DFlash speculators turn acceptance length into 2-3x speedups]] and [[Rachel Rapp explains how Baseten trains speculative-decoding draft models live from inference hidden states, raising accept rates 20%+ with no offline data storage]] — training lightweight LoRAs per workload, then merging or routing them to serve many tenants from one GPU pool.

## External Resources

- [Article: Specialization is (sometimes) all Speculative decoding needs (jwlabs)](https://jwlabs.vercel.app/post/specialization-is-all-speculation-needs) and the [SpecSpec GitHub repo](https://github.com/jwlaboratory/SpecSpec/).
- [Speculative decoding from first principles (jwlabs)](https://jwlabs.vercel.app/post/speculative-decoding-first-principles) — background primer referenced for how spec decoding works.
- Prior/complementary production work cited: [Modal — Introducing Auto-Endpoints](https://modal.com/blog/introducing-auto-endpoints) and [Baseten — Live draft model training for speculative decoding](https://www.baseten.co/blog/live-draft-model-training-for-speculative-decoding/).
- Building blocks: z-lab's Qwen3-8B-DFlash block-diffusion drafter, Qwen/Qwen3-8B target, and the WildChat-4.8M dataset (split by language column).

## Original Content

> @shreybirmiwal (shrey birmiwal) — 2026-07-24
>
> ![[shreybirmiwal-976926-001.png]]
>
> **Article: Specialization is (sometimes) all Speculative decoding needs**
>
> > TLDR: We improved speculative decoding by up to 46% in acceptance rate on out-of-distribution languages, which translated to up to a 15.3% wall-clock speedup on those languages (and up to 7.3% on aggregate), by specializing block diffusion drafter models using LoRA. However, we find languages have low levels of interference and a single combined LoRA captures almost all of the gains. We next hypothesize specialization will perform better in more fine-grained domains (future work) and has room to bring significant speedups.
>
> [Article Link](https://jwlabs.vercel.app/post/specialization-is-all-speculation-needs); GitHub: [jwlaboratory/SpecSpec](https://github.com/jwlaboratory/SpecSpec/); By [@shreybirmiwal](https://x.com/shreybirmiwal) and [@AnishBhat07](https://x.com/AnishBhat07)
>
> ## What and why are we specializing?
>
> Speculative decoding is an inference technique in which a draft model is used to propose multiple tokens for the target model to verify all at once, instead of the target model having to generate one token at a time sequentially. For more information about how speculative decoding works, [read this blog](https://jwlabs.vercel.app/post/speculative-decoding-first-principles).
>
> You can think of the speculator (the drafter) as an approximation for the verifier (the target). An important detail is that the drafter is not trying to be correct in an external sense, but rather trying to copy the verifier.
>
> *The drafter's job is to copy the target, not to be externally correct*
> ![[shreybirmiwal-976926-002.png]]
>
> We hypothesized that since the drafter is a small approximation of the larger verifier, it has to pick and choose what areas to have the best results. While common regions get modeled well, long-tail regions have gaps. If this is true, specializing the drafter should help us where the base drafter is weakest (out of distribution).
>
> *The drafter approximates the target's distribution and misses the long tail — where specialization has headroom*
> ![[shreybirmiwal-976926-003.png]]
>
> People have tried specialization for speculators in the past, but minimal or no work has been done on dynamic speculators, specializing diffusion speculators like DFlash for domain adaptation, benchmarking at larger batch sizes, using unmerged LoRA/NaRA to serve many specializations at once, and comparing with combined/full fine-tunes. Below we experiment with different domains, different routing, and different trained adapters to see if they improve speculators.
>
> ## Speculators are uneven across languages
>
> We first benchmarked the most popular speculator (z-lab/Qwen3-8b-DFlash-b16, a 1B block-diffusion drafter) for Qwen/Qwen3-8B across many languages.
>
> We split WildChat 4.8M by language column and kept 26 languages with at least 1,200 usable prompts/conversations (1,000 train / 100 validation / 100 test split after deduplication). Then, we ran the target model and compared the acceptance rate on the 26 languages, producing the results below.
>
> *Base DFlash acceptance for a subset of languages (Polish 3.57% … English 12.90%, Latin 11.85%)*
> ![[shreybirmiwal-976926-004.png]]
>
> *Base DFlash acceptance across all 26 WildChat languages — ~4x variation, English 12.89% down to Polish 3.57%*
> ![[shreybirmiwal-976926-005.png]]
>
> We found that the speculator is extremely domain sensitive, supporting our hypothesis, having almost 4X variation in accuracy between the highest and lowest accurate languages.
>
> It makes sense that languages such as English and Latin, with the highest concentration of training data, would perform the best, while languages like Polish and Hungarian, with likely less training data, would perform worse.
>
> ## Training Language-Specific LoRAs
>
> LoRA is a process of fine-tuning language models by freezing the original model weights and only training a small slice of the parameters (an additive adapter). This prevents the original model from forgetting information and requires much less data.
>
> We adapt this LoRA for block diffusion models by adding an adapter for all of the attention layers.
>
> Using WildChat-4.8M, we split first-turn prompts by the dataset's language column, used up to 1,000 train / 100 val / 100 test prompts per language, and generated target answers greedily with Qwen/Qwen3-8B.
>
> For each train sequence, we capture the hidden states and the output of the target model. Using this data, we sample random positions (up to 48 times per sequence) in the sequence, and use this to train a rank-16 LoRA for the drafter.
>
> *Swedish rank-16 LoRA converges on held-out validation (val loss down, val accept rate up)*
> ![[shreybirmiwal-976926-006.png]]
>
> The results clearly show that specializing helps the model.
>
> *Own-language LoRA gain over base across languages (Hungarian +1.80pp/+46%; English −0.09pp)*
> ![[shreybirmiwal-976926-007.png]]
>
> *Per-language base vs own-LoRA acceptance, gain, and relative improvement*
> ![[shreybirmiwal-976926-008.png]]
>
> We observed that the weaker languages got the largest gains. For example, Hungarian jumped +46% relative to its base. On the other hand, stronger languages like English actually got slowed down, probably because the base was already so strong. This supports the hypothesis that these models have the largest headroom in out-of-distribution regimes.
>
> ## LoRA beats a full fine-tune
>
> We next wanted to make sure that a full fine-tune does not vastly outperform the LoRA. So we used the same training data to train a full fine-tune of the model. Each domain's full fine-tune performed *worse* than the LoRA.
>
> *Base vs LoRA vs full fine-tune acceptance (LoRA beats the full fine-tune on every domain)*
> ![[shreybirmiwal-976926-009.png]]
>
> *Base vs own-LoRA vs full-fine-tune, with gains*
> ![[shreybirmiwal-976926-010.png]]
>
> We believe this does not show that full fine-tuning is bad or impossible, but rather that tuning all the parameters at once would require a lot more data to avoid being starved, while a limited rank-16 adapter (a small percentage of total parameters) can converge much faster.
>
> ## Training a router between LoRAs
>
> Additionally, we train a tiny router that uses the target-hidden features that DFlash uses anyway. The router is a 2-layer MLP that takes the hidden features (20480) to route between the 26 languages with 10.5M parameters, and since it is so small, its compute/time cost is basically negligible.
>
> *26-way language router training curve (MLP 20480→512→26, early-stop on val acc)*
> ![[shreybirmiwal-976926-011.png]]
>
> It scores very high, with 84.69% validation accuracy and 81.58% test accuracy:
>
> *Router per-language test accuracy (Japanese 97% → Esperanto 27%)*
> ![[shreybirmiwal-976926-012.png]]
>
> (English here contains other stuff as well, like SQL, Latin, etc, which may be dragging down the score)
>
> We wanted to make sure the router would not cause an increase in latency, but because it is so tiny compared to the actual model, the cost fully amortizes to almost nothing.
>
> *Router MLP cost is negligible — 48.5µs (batch 1) / 1.7µs (batch 64) vs 46.6ms target prefill*
> ![[shreybirmiwal-976926-013.png]]
>
> ## Combined LoRA keeps a lot of the gains
>
> Next, we wanted to see if the LoRA specialization was due to each adapter uniquely learning the domain, or just because it was exposed to more specific knowledge. The hint that told us to investigate this was that the hidden states cleanly separated the different languages well when routing between languages.
>
> We also wondered if combining many languages could improve performance. Some languages come from the same family and carry semantic meaning that is complementary.
>
> We tried an experiment of training a single "combined LoRA" over all the languages and compared its performance with the own-language LoRA.
>
> *Acceptance rate by language: base vs own LoRA vs combined LoRA*
> ![[shreybirmiwal-976926-014.png]]
>
> *Analytic speedup by language: base vs own vs combined, with % gain vs base*
> ![[shreybirmiwal-976926-015.png]]
>
> Averaged over the 26 clean languages, the per-language specialists gain +0.85pp over base and the single combined adapter gains +0.70pp, a delta of just +0.15pp. The specialists win on most languages (19/26 languages), but the combined adapter is never far behind, and it actually wins on 6. We guess that the languages the combined model wins at (Esperanto, Yoruba, Tagalog, Malay, Indonesian, and Latin) are low-resource languages where cross-lingual transfer from related languages helps it generalize more than the specialized knowledge.
>
> This implies that for cleanly separable domains, a single combined LoRA is sufficient. Training individual specialists is only necessary when the model cannot cleanly separate the task in its hidden state. Because language is an easily separable task, it is largely first a matter of adding more training data for out-of-distribution languages to improve the quality. When this saturates, then, perhaps our specialization will further shine.
>
> ## Interference gets real in more fine-grained domains
>
> In domains in which the model has a hard time cleanly separating tasks, we experience the "muddling" of combined experts (more training data does not solve this; the small number of parameters means it muddles between 2 experts, and therefore needs specialization).
>
> We tried cursory experiments (but leave the full experiments up for a follow-up blog).
>
> First, we build an interference ladder that shows 10 combined domains vs 20 and 40 combined domains.
>
> *Interference ladder: combined-adapter gap vs own specialist and gain retained at 10/20/40 domains (74% → 70% → 67%)*
> ![[shreybirmiwal-976926-016.png]]
>
> As you can see, as you increase the number of experts, the interference increases and specialists shine further.
>
> Second, to prove that languages are easy and low interference, we try other English subdomains (code_python, code_sql, ood_legal, ood_medical, ood_financial, task_math_reasoning, task_summarization).
>
> *Where specialization helps inside English: own vs combined vs equal-budget combined across code/legal/medical/math/etc.*
> ![[shreybirmiwal-976926-017.png]]
>
> The per-domain specialists beat the base 7/7 as expected, but the key point is that the combined adapter only retains about 20% of the specialist gain. This is completely different from the language setting, where the combined LoRA retains most of the specialist gain.
>
> ## Serving Cost
>
> We first compared all the different ways to serve the specialized drafter. Merging is a process in which you take the low-rank adapter LoRA weights and you mathematically multiply them with the existing weights to create a merged single set of weights as if it was just a new fine-tuned model. The benefit of keeping them unmerged is that you can keep most of the weights the same so you have a lower memory footprint because you just need to swap out your final adapter weights. As soon as you merge, then you need to keep multiple copies that are very similar but to the computer look entirely different.
>
> *Serving modes: base, merged_combined, merged_own, hotswap_own*
> ![[shreybirmiwal-976926-018.png]]
>
> We compared one merged model with the combined LoRAs, compared with multiple N individually merged specialized LoRAs, compared with N unmerged hot‑swappable LoRAs.
>
> Because vLLM does not support hot swapping unmerged LoRAs, we tested this on HF.
>
> *Production wall-clock speedup by LoRA serving mode (merged combined 1.50x, N merged own 1.51x, hot-swap 1.17x)*
> ![[shreybirmiwal-976926-019.png]]
>
> *Serving-mode throughput: tok/s, speedup vs target-only and base DFlash, acceptance, mean accept length*
> ![[shreybirmiwal-976926-020.png]]
>
> This shows us that hotswapping LoRAs without optimizing this (punica styled batch kernels perhaps) is unworkable. On the other hand, merged-combined and N merged-own show promising results. Combined LoRA gives a +5.9% wall-clock gain over base DFlash on this mixed-language serving stream, and the one-time merge setup was only 0.073s. The N-merged-specialist path gives +6.4% over base DFlash, only about +0.5% relative to the merged combined LoRA.
>
> We tried on vLLM at different batch sizes on one of the best performing LoRAs (Swedish), which performed remarkable. Note that the batch size 1 result is different from above because we use vLLM and not HF.
>
> *Swedish vLLM speedup by batch size: merged own / merged combined / base DFlash*
> ![[shreybirmiwal-976926-021.png]]
>
> All numbers below are net wall-clock speedup vs no speculative decoding (target-only).
>
> *Serving speedup vs batch size (Swedish) — crosses break-even ~batch 20*
> ![[shreybirmiwal-976926-022.png]]
>
> At a higher batch size, even naive speculative decoding doesn't help anymore because we're no longer memory bound, but rather compute bound. But the cool thing to observe is that at these lower batch sizes, the Swedish specialist gives up to a 15.3% gain over the base DFlash, and the combined LoRA nearly matches it, plus 12% at batch size 1.
>
> The benefit of merged-combined is that you only need 1 set of weights. It's essentially just the drafter with more knowledge. However, it's not specialized and may have interference (as we've somewhat shown).
>
> The benefit of N-merged LoRAs is that you do not have any intereference and can have extreme specialization. The negative is that you now need to store more weights and this may perform poorly when constantly needing to swap in and out weights with heavy batch sizes. With larger batches (say size B), we will need to pull in potentially N different experts, instead of previously only needing to pull in 1 expert. Similar to the MOE speculation problem, this is bad because in an already memory bound system we are further hurting the memory pipe.
>
> We then benchmarked using vLLM to see at different batch sizes with a "MIXED BAG" of different requests from different languages. This forced the model to use the combined merged LoRA and the speedups are shown below:
>
> *Mixed 16-language stream vLLM speedup by batch size*
> ![[shreybirmiwal-976926-023.png]]
>
> *Serving speedup vs batch size (mixed 16-language stream) — +5-7% over base, break-even ~batch 14*
> ![[shreybirmiwal-976926-024.png]]
>
> Even on a fully mixed stream, one combined adapter holds a +5–7% wall-clock edge over base DFlash across batch sizes (peaking at +7.3% around batch 8), with a single drafter and no routing. As before, the overall speedup still falls with batch, crossing break-even around batch 14.
>
> We leave a future experiment to try to update the vLLM implementation and kernels to test how much slowdown hotswapping adapters or swapping entire drafters would cause within batches.
>
> ## Conclusion
>
> *Inference speeds with DFlash and specialized DFlash: Swedish workload +15.3%, random workload +5.4% at batch 1*
> ![[shreybirmiwal-976926-025.png]]
>
> For languages, specialization is almost all speculation needs. The core result is that a small LoRA can recover much of the drafter's long-tail weakness, and because language domains interfere surprisingly little, one merged combined LoRA captures nearly all of the specialist gain without the serving cost of hot-swapping adapters.
>
> Speculation does indeed work, as we see recent work from @modal [here](https://modal.com/blog/introducing-auto-endpoints) and @baseten [here](https://www.baseten.co/blog/live-draft-model-training-for-speculative-decoding/) showing that production systems are moving toward per-customer or per-workload speculators. Our version is complementary because it trains lightweight LoRAs for each workload, then merges or routes them when useful, allowing you to serve many tenants from the same GPU pool without keeping a separate drafter for everyone.
>
> We also think it is promising to try specializing in more niche domains, such as math and SQL, where it is important to align the drafter to the target model. We hope to post a follow-up blog that explores these niche domains more.
>
> ## Future Ideas
>
> 1. In this research, we try language domains and briefly experiment with more specialized fine‑grained domains within English, which show more interference and higher gains from specializing. We should further try this with more domains that are within more niche groups and see how they perform.
>
> 2. We should try other drafters, for example Eagle3, DSpark, and completely independent drafters, and test across larger models as well, not just 8B models, to see how they perform.
>
> 3. We should also try a quick sweep over low-rank adaptation ranks in other domains. From a brief examination of rank comparisons within languages, we found very little change between rank 16, rank 4, and rank 64 in terms of performance, which may also affect speedups because it reduces the amount of weights that need to be loaded into and from memory.
>
> Engagement: 23 likes | 2 retweets | 3 replies
> [Original post](https://x.com/shreybirmiwal/status/2080511860235976926)
