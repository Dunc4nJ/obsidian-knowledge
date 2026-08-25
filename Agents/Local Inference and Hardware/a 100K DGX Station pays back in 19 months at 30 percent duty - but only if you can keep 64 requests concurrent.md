---
created: 2026-08-25
description: Alex Ziskind's ownership math on a $100K DGX Station GB300 running DeepSeek-V4-Flash under vLLM + DSpark — peak 6,726 t/s = 17.4B output tokens/month at full duty, $2,778/mo amortized over 3 years, giving $1.59 / $0.53 / $0.32 / $0.16 per 1M output tokens at 10/30/50/100% duty and a 19-month payback at 30% duty vs $1/M API pricing. The critical dependency: those numbers assume 64 concurrent requests; at 8 concurrent you get 1,778 t/s — 3.8x less throughput and roughly 4x the payback.
source: https://x.com/digitalix/status/2091491916625875163
author: "@digitalix (Alex Ziskind)"
type: post
tags: [local-inference, hardware, dgx-station, gb300, cost-analysis, throughput, concurrency, vllm, deepseek, unit-economics]
---

## Key Takeaways

- **The ownership math, stated cleanly: a $100K DGX Station GB300 amortizes to $2,778/month over 3 years, and cost per 1M output tokens is purely a duty-cycle question.** At peak 6,726 t/s the box can emit 17.4B output tokens/month at 100% duty. Cost per 1M output tokens: **$1.59 at 10% duty → $0.53 at 30% → $0.32 at 50% → $0.16 at 100%**. Payback at 30% duty is **19 months against $1/M API pricing, 10 months against $2/M**. Hardware only — no power, cooling, or staff.

- **The caveat that carries the whole analysis: it assumes 64 concurrent requests.** At 8 concurrent you get 1,778 t/s — "3.8x less throughput and roughly 4x the payback." Owning inference hardware is only cheap if you can *keep it saturated*, which is a workload-shape question, not a hardware question. Anyone doing this math for a personal or single-team setup should assume the low-concurrency column, not the headline. This is the same batching economics that make [[Amit Shekhar explains how vLLM packs more LLM users onto one GPU through PagedAttention and continuous batching|vLLM's continuous batching]] matter and that [[Superlinked's SIE inference engine serves many small models on shared GPUs, fixing the one-model-per-GPU waste of vLLM and TEI|shared-GPU serving]] exists to fix — providers bill whole-card wall-clock, and so does your own depreciation schedule.

- **The concurrency sweep shows a cliff, not a curve — aggregate throughput peaks at 64 clients and collapses past it.** The companion sweep (DeepSeek-V4-Flash 0731 on GB300, vLLM + DSpark) runs 1 client → 263 t/s aggregate/per-client, climbing to the 6,726 t/s peak at 64 concurrent, then falling off sharply beyond it while per-client throughput degrades toward single digits. Finding *your* box's cliff is the whole capacity-planning exercise — the practical companion to [[vLLM throughput benchmarking on H100 — tensor-parallel sizing, speculative decoding, and FP8 KV-cache economics|H100 throughput sweeps]] and the DSpark [[DSpark (DeepSeek paper) couples a semi-autoregressive drafter with a hardware-aware confidence scheduler to raise accepted length 16-31% offline and shift DeepSeek-V4's serving Pareto frontier|speculative decoding]] in the stack.

- **Where this sits in the buy-vs-rent picture.** It's the $100K rung of a ladder the vault now spans end to end: [[EXL3 3-bit plus an 18.5 percent expert prune runs DeepSeek-V4-Flash 284B at 47 tok-s on 4.7K of hardware|$4.7K single box]] → [[two DGX Sparks run a 304B model at 40 TPS - install Tailscale first and every other non-obvious gotcha|~2x DGX Spark desk cluster]] → this $100K workstation → [[camelAI self-hosts DeepSeek V4 Flash on 4x RTX PRO 6000 Blackwell for a fixed-cost free tier, with KV cache as the real bottleneck|camelAI's ~$4-6K/month rented 4x RTX PRO 6000]] — all running essentially the same DeepSeek-V4-Flash model. The decision variable across all four is duty cycle and concurrency, not peak TPS.

## External Resources

- Original post: [@digitalix (Alex Ziskind), 2026-08-23](https://x.com/digitalix/status/2091491916625875163) · [concurrency sweep thread](https://x.com/digitalix/status/2091489668030140518)
- Stack: NVIDIA DGX Station GB300 · vLLM + DSpark · DeepSeek-V4-Flash 0731

## Original Content

> [!quote]- Full post + quoted concurrency sweep (@digitalix, 2026-08-23)
> Ownership math on the $100k DGX Station. (Hardware only, no power.)
>
> Peak 6726 t/s = 17.4B output tokens/month at full duty. Amortized over 3 years that’s $2778/mo.
>
> Cost per 1M output tokens:
> 10% duty → $1.59
> 30% duty → $0.53
> 50% duty → $0.32
> 100% duty → $0.16
>
> Payback at 30% duty: 19 months at $1/M, 10 months at $2/M.
>
> Assumes 64 concurrent requests (as per thread below). At 8 concurrent you only get 1778 t/s, so 3.8x less throughput and roughly 4x the payback.
> *Cost per 1M output tokens and payback period vs duty cycle, $100K DGX Station GB300:*
> ![[digitalix-dgx-station-001.jpg]]
> >  QT @digitalix:
> > Ran the full concurrency sweep. deepseek-v4-flash 0731 on the DGX Station GB300, vLLM + dspark.
> > 
> > clients → aggregate → per client
> > 1 → 263 → 263 t/s
> > *Concurrency scaling and the cliff at 64 clients — aggregate throughput peaks at 6,726 t/s then collapses; per-client degrades throughout:*
> > ![[digitalix-dgx-station-002.jpg]]
> >  https://x.com/digitalix/status/2091489668030140518
