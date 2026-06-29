---
created: 2026-06-29
description: A first-principles course on LLM inference, built step-by-step from Dmytro Dzhulgakov's (@dzhulgakov, Fireworks AI) 10-idea DSpark thread — from why decode is memory-bound up to DeepSeek's DSpark speculative decoder.
type: moc
---

# Course — Inference from First Principles

A guided, first-principles walk through LLM **inference** (model serving), built from [Dmytro Dzhulgakov's 10-idea DSpark thread](https://x.com/dzhulgakov/status/2070922887595499930). The arc: one hardware fact (decode is memory-bandwidth-bound) forces everything else — batching, speculative decoding, EAGLE/MTP, DFlash, and finally DeepSeek's **DSpark**. Each note is a self-contained review with diagrams, formulas, and the key things to understand.

Related folder MOC: [[moc - Inference]].

## Steps

1. [[Step 01 - Decode is memory-bandwidth-bound (the roofline)]] — why one token reads the whole model; the two clocks; arithmetic intensity & the ridge point `B*≈295`; precision/bytes; the MAC; rate-capping.
2. Step 02 — Continuous batching (spending the free compute along the *batch* axis) — _coming next_
3. Step 03 — Speculative decoding core (guess-then-verify; why it's lossless)
4. Step 04 — Draft models & the acceptance-rate lever (α = distributional overlap)
5. Step 05 — The economics of speculation (the cost formula, the net-negative zone, the ceilings)
6. Step 06 — EAGLE / MTP (drafter as an extra layer on the last hidden state)
7. Step 07 — DFlash (diffusion: all N draft tokens in one pass)
8. Step 08 — DSpark = parallel block + cheap sequential correction
9. Step 09 — Variable-length drafting & the hardware-aware scheduler
10. Step 10 — Online drafter calibration; putting it all together

## The through-line (one paragraph)

Everything flows from ONE hardware fact: decoding is **memory-bandwidth-bound** — each token forces a full read of the model's weights out of HBM while the tensor cores sit ~99% idle. That fixed-cost "weight sweep" creates a slab of free compute you can fill two ways: with tokens from many **requests** (continuous batching → throughput) or with **guessed future tokens** of one request (speculative decoding → latency). Speculation is provably lossless, so the drafter only ever changes *speed*, never *correctness*; speed is then governed by acceptance rate and a cost formula with hard ceilings. The rest of the course is a march to beat those ceilings: EAGLE/MTP make the drafter nearly free, DFlash makes it parallel, and DSpark fuses them and turns draft-length into a calibrated, load-aware scheduling knob — for 1.5×–5× production throughput, still provably exact.
