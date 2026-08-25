---
created: 2026-08-25
description: Navigation hub for running models on hardware you own — desk and workstation builds, quantization/pruning to fit VRAM, throughput and concurrency behavior, and the buy-vs-rent unit economics of owned inference.
type: moc
---

# Local Inference and Hardware

Running frontier-class models on hardware you own or control: DGX Sparks and Stations, consumer/prosumer GPU builds, quantization and pruning to fit VRAM budgets, throughput-vs-concurrency behavior, and the ownership math that decides buy-vs-rent. The practitioner counterpart to [[moc - Inference]] (serving engines, KV cache, speculative decoding at provider scale).

**The cost ladder so far** — all four notes below run essentially the same DeepSeek-V4-Flash class of model at very different price points, and the deciding variable in every case is duty cycle and concurrency, not peak TPS: ~$4.7K single box → ~2x DGX Spark desk cluster → $100K DGX Station → rented multi-GPU (camelAI, in the Inference folder).

## Builds & Setup

- [[two DGX Sparks run a 304B model at 40 TPS - install Tailscale first and every other non-obvious gotcha]] — @vectal_labs' field notes from a first two-Spark setup: install Tailscale *before* anything else so you finish over SSH instead of at the desk (bootstrap the commands via a browser messenger + phone QR); wired keyboard/mouse and a USB-C hub or your Spark is "an expensive brick"; plug order (hub → internet → NAS → Spark-link last, same side on both boxes); the `/etc/nvidia/cx7-hotplug-enabled` file that makes fast ports vanish after a reboot and looks like dead hardware; same Linux login name on both; and use the MiaAI-Lab recipe + Anemll vLLM image rather than building the server from scratch

## Compression & Fitting Models

- [[EXL3 3-bit plus an 18.5 percent expert prune runs DeepSeek-V4-Flash 284B at 47 tok-s on 4.7K of hardware]] — @0xSero: stacking EXL3 3-bit quantization with an ~18.5% MoE expert prune fits a 284B model into 128GB VRAM (context + activations included) at 47 tok/s and 400K context. The transferable point is that the two levers are orthogonal — bits-per-weight and expert-count — so composing them lowers the hardware floor faster than pushing either alone

## Economics & Throughput

- [[a 100K DGX Station pays back in 19 months at 30 percent duty - but only if you can keep 64 requests concurrent]] — @digitalix (Alex Ziskind): $100K GB300 amortizes to $2,778/mo over 3 years; peak 6,726 t/s = 17.4B output tokens/month, giving $1.59/$0.53/$0.32/$0.16 per 1M output tokens at 10/30/50/100% duty and a 19-month payback at 30% duty vs $1/M API pricing — *but* all of it assumes 64 concurrent requests; at 8 concurrent it's 1,778 t/s, 3.8x less throughput and ~4x the payback. Includes the concurrency sweep showing aggregate throughput peaks at 64 clients and then falls off a cliff
