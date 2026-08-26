---
created: 2026-08-25
description: Navigation hub for running models on hardware you own — desk and workstation builds, quantization/pruning to fit VRAM, throughput and concurrency behavior, and the buy-vs-rent unit economics of owned inference.
type: moc
---

# Local Inference and Hardware

Running frontier-class models on hardware you own or control: DGX Sparks and Stations, consumer/prosumer GPU builds, quantization and pruning to fit VRAM budgets, throughput-vs-concurrency behavior, and the ownership math that decides buy-vs-rent. The practitioner counterpart to [[moc - Inference]] (serving engines, KV cache, speculative decoding at provider scale).

**The cost ladder so far** — all four notes below run essentially the same DeepSeek-V4-Flash class of model at very different price points, and the deciding variable in every case is duty cycle and concurrency, not peak TPS: ~$4.7K single box → ~2x DGX Spark desk cluster → $100K DGX Station → rented multi-GPU (camelAI, in the Inference folder).

## Buying & Comparison

- [[at 15-20K with 512GB the real gap is bandwidth not compute - Mac Studio M5 Ultra vs 4x DGX Spark vs 4x Ryzen AI Halo]] — @tomgreenwald: three matched ~$15-20K/512GB builds compared. Mac M5 Ultra ~135 TFLOPS / **1.2 TB/s** / ~270W silent; 4x DGX Spark ~300 TFLOPS / 273 GB/s / ~960W (200GbE links fast enough to combine compute, native FP4); 4x Ryzen AI Halo ~100 TFLOPS / 256 GB/s / ~560W (10GbE too slow to share work). The trap: multi-box setups split the model and pass tokens sequentially, so **4 boxes still generate at 1 box's speed** — bandwidth, not aggregate compute or pooled memory, sets interactive speed. Next-gen won't change the ranking unless bandwidth does
- [[buy 2x 256GB Mac Studios instead of one 512GB - two boxes give 2x 1.2 TB-s parallel instances and can still be linked, but a 512GB box can never be split]] — @MikeBradleyAI's counterpoint to the 512GB Studio: two 256GB boxes keep *two* full 1.2 TB/s buses, so you can multi-instance two models with genuine parallel throughput, and still link them for a single oversized model — while a 512GB box can never be split back. The asymmetry (two can become one; one can never become two) decides it whenever the configs cost about the same; the test is whether your biggest model fits in 256GB. His 25-50% per-GB price-hike claim is an unsourced forecast, flagged as such

## Builds & Setup

- [[two DGX Sparks run a 304B model at 40 TPS - install Tailscale first and every other non-obvious gotcha]] — @vectal_labs' field notes from a first two-Spark setup: install Tailscale *before* anything else so you finish over SSH instead of at the desk (bootstrap the commands via a browser messenger + phone QR); wired keyboard/mouse and a USB-C hub or your Spark is "an expensive brick"; plug order (hub → internet → NAS → Spark-link last, same side on both boxes); the `/etc/nvidia/cx7-hotplug-enabled` file that makes fast ports vanish after a reboot and looks like dead hardware; same Linux login name on both; and use the MiaAI-Lab recipe + Anemll vLLM image rather than building the server from scratch

## Compression & Fitting Models

- [[EXL3 3-bit plus an 18.5 percent expert prune runs DeepSeek-V4-Flash 284B at 47 tok-s on 4.7K of hardware]] — @0xSero: stacking EXL3 3-bit quantization with an ~18.5% MoE expert prune fits a 284B model into 128GB VRAM (context + activations included) at 47 tok/s and 400K context. The transferable point is that the two levers are orthogonal — bits-per-weight and expert-count — so composing them lowers the hardware floor faster than pushing either alone

## Caching & Serving

- [[LMCache offloads paged KV to system RAM and NVMe, cutting 128K-context time-to-first-token from 68 seconds to 1.4 on 4x DGX Spark]] — @0xSero: store paged KV outside the GPU (system memory + NVMe) so long contexts reload instead of recompute. Same prompt/model on 4x DGX Spark, TTFT 68.1s → 1.4s at 128K and 38.3s → 0.69s at 64K; recompute climbs steeply with context while reload stays near-flat. The local answer to the fixed-prefix tax agents pay every turn — the *offload* strategy, complementary to compressing the cache or changing the architecture

## Economics & Throughput

- [[a 100K DGX Station pays back in 19 months at 30 percent duty - but only if you can keep 64 requests concurrent]] — @digitalix (Alex Ziskind): $100K GB300 amortizes to $2,778/mo over 3 years; peak 6,726 t/s = 17.4B output tokens/month, giving $1.59/$0.53/$0.32/$0.16 per 1M output tokens at 10/30/50/100% duty and a 19-month payback at 30% duty vs $1/M API pricing — *but* all of it assumes 64 concurrent requests; at 8 concurrent it's 1,778 t/s, 3.8x less throughput and ~4x the payback. Includes the concurrency sweep showing aggregate throughput peaks at 64 clients and then falls off a cliff
