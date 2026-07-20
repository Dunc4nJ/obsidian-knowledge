---
created: 2026-07-20
published: 2026-03-21
description: Concentrated Vicor bull Joe (@joedab12) gives the foundational physics explainer of VICR's moat — AI accelerators draw 600–1,000+A at sub-1V so PDN losses scale as I²R, making the "last inch" between VRM and die the binding constraint, which Vicor's VPD current multipliers placed directly under the processor solve with a claimed ~20x lower PDN resistance, tied to Cerebras's 23kW WSE-3 wafer-scale engines.
source: https://x.com/joedab12/status/2035386576008822814
type: thesis
authors: ["Joe (@joedab12)"]
---

# VICR moat is last-inch PDN physics — 600–1,000A at sub-1V make I²R loss the binding constraint, under-die VPD current multipliers cut PDN resistance ~20x

This is Joe (@joedab12)'s single best "why the thesis works" explainer — a multi-paragraph electrical-physics walkthrough of Vicor's edge, framed off Cerebras's IPO and the 23kW CS-3 wafer-scale system. The argument: as accelerator current climbs into the hundreds-to-thousands of amps at sub-1V, power-delivery-network (PDN) losses grow with the square of current, so the physical "last inch" between the voltage regulator and the die becomes the constraint on how fast the chip can actually run. Vicor's Vertical Power Delivery (VPD) puts current multipliers directly beneath the processor to collapse that impedance. The tail replies add the competitive rebuttal (vs [[Monolithic Power (MPWR)]] and in-package OSAT integration) and a demand-side tell (Fab 1 already full, a hyperscaler/OEM ramping, 3rd-party capacity being shopped).

## Key Takeaways

- **The moat is physics, not a feature.** Power loss in the PDN scales as P = I²R, so doubling current quadruples losses. At a modern AI accelerator's 0.75–0.85V and 600–1,000+A, a few milliohms of resistance in PCB copper, solder joints, and sockets between the VRM and die means kilowatts dumped as heat before power reaches the chip. Vicor's VPD places current multipliers directly under the processor rather than lateral on the motherboard, claiming **up to ~20x lower PDN resistance** and cutting 50+W of waste per accelerator — powering [[Cerebras (CBRS)]]'s 23kW WSE-3, and relevant to a 2.3kW [[Nvidia (NVDA)]] Rubin GPU or a 230kW NVL72 rack.
- **Transient response caps sustainable clocks.** Billions of transistors switching simultaneously create huge di/dt spikes; if the PDN can't respond fast enough, voltage droops below the chip's minimum operating voltage and it either errors out or must downclock. So a 50-PFLOP chip can't hold peak clocks if power delivery can't keep up — proximity (lower impedance) directly minimizes droop and unlocks performance already paid for.
- **Signal integrity is the second axis.** Traditional multiphase VRMs with inductor banks emit broadband EM noise that interferes with high-speed I/O and memory; Vicor's SAC (Sine Amplitude Converter) topology produces narrowband, low-frequency emissions — which matters more as processors pack tighter, exactly what [[Cerebras (CBRS)]] does with wafer-scale integration and [[Nvidia (NVDA)]] does with NVLink clusters.
- **Scale turns small efficiency points into large dollars, and it's US-made.** At 23kW (WSE-3), 2.3kW (Rubin), or 230kW (NVL72), even a few points of PDN-efficiency improvement compounds into meaningful electricity, cooling, and rack-density savings. Vicor designs and manufactures the VPD current multipliers 100% in Andover, Massachusetts.
- **Competitive rebuttal + demand tell (tail replies).** To @semiDL's objection that [[Monolithic Power (MPWR)]] and others have similar solutions and OSATs are integrating VRM into the package, Joe counters MPWR's approach is "architecturally different and inferior," and drops a demand signal: Fab 1 is **already full — and not just from Cerebras** — with at least one major hyperscaler or OEM ramping VPD and Vicor shopping 3rd-party manufacturing capacity for the overflow; he argues ITC rulings will make VICR "hard for [[Nvidia (NVDA)]] to ignore."

## External Resources

- [@andrewdfeldman quoted tweet](https://x.com/andrewdfeldman/status/2035341908835221616) — Cerebras CEO Andrew Feldman: exclusively American design/manufacturing, 120,000 sq ft of new capacity coming online.
- [@semiDL reply](https://x.com/semiDL/status/2035556908141269435) — Tapa Ghosh's competitive pushback (MPWR + in-package OSAT integration).
- [@joedab12 reply](https://x.com/joedab12/status/2035584071456444557) — Joe's rebuttal (Fab 1 full, hyperscaler/OEM ramp, ITC rulings).

## Original Content

### Seed thread — Joe (@joedab12), Sat Mar 21 2026 16:02 UTC

> **@joedab12 (Joe)** — Sat Mar 21 16:02:30 +0000 2026
> [https://x.com/joedab12/status/2035386576008822814](https://x.com/joedab12/status/2035386576008822814)
>
> Cerebras IPO likely comes in q2 and should do well as they have recently announced deals with $AMZN and OpenAI.
>
> But here's the part the market is sleeping on: every CS-3 system consuming 23kW needs world class power delivery. That is exactly what $VICR is providing for Cerebras.
>
> Vicor designs and manufactures the VPD (Vertical Power Delivery) current multipliers that sit directly beneath these wafer-scale processors in Andover, Massachusetts. 100% American-made. Cerebras building the biggest chips ever made, Vicor is solving the "last inch" power delivery problem that makes them actually work. Why does last inch power and smooth power delivery matter so much? Grab a cup of coffee and read this-
>
> It comes down to basic electrical physics. As processor current requirements increase, every milliohm of resistance in the power delivery network (PDN) becomes exponentially more costly - because power loss scales with the square of current (P = I²R). Double the current, quadruple the losses. That's why the "last inch"  the physical distance between the voltage regulator and the processor's power pins - becomes a major bottleneck as these chips scale up.
>
> Here's how it plays out practically. A modern AI accelerator might run at 0.75–0.85V and draw 600–1,000+ amps of continuous current. At those levels, even tiny resistances in the PCB copper traces, solder joints, and socket interconnects between the VRM and the processor create massive voltage drops and waste heat. A few milliohms of PDN resistance at 1,000A means kilowatts of power just being dumped as heat into the motherboard before the electricity even reaches the processor. Thats wasted power that does nothing useful, it just makes your cooling problem worse and starves the chip of clean voltage.
>
> It gets worse because these processors need extremely stable voltage. The chip is switching billions of transistors on and off simultaneously, creating huge transient current spikes (di/dt). If the power delivery can't respond fast enough, you get voltage droops -momentary sags below the processor's minimum operating voltage. When that happens, the chip either errors out or has to be clocked lower to maintain stability. So you've built a chip capable of, say, 50 PFLOPS, but it can't actually sustain peak clocks because the power delivery can't keep up with transient demands. You're leaving performance on the table.
>
> ***This is why physical proximity matters so much. The closer the current multiplier sits to the processor's power pins, the lower the PDN impedance, the smaller the voltage droop under transients, and the less power wasted as heat. Vicor's VPD architecture puts the current multiplier directly underneath the processor rather than off to the side on the motherboard.***
>
> Their numbers claim this reduces PDN resistance by up to 20x compared to lateral placement, cutting losses from potentially 50+ watts per accelerator down dramatically.
>
> At the Cerebras WSE-3 scale (23kW, entire wafer), or an $NVDA Rubin GPU at 2.3kW, or a full NVL72 rack at 230kW, even a few percentage points of improved power delivery efficiency translates into enormous savings in electricity costs, cooling requirements, and rack density.
>
> The other dimension is signal integrity. At these power levels and switching frequencies, traditional multiphase VRMs with banks of inductors create broadband electromagnetic noise that can interfere with high-speed I/O and memory signals. Vicor's SAC (Sine Amplitude Converter) topology produces narrowband, low-frequency emissions by comparison, which matters more as you pack processors tighter together (exactly what Cerebras does with wafer-scale integration, and what Nvidia does with NVLink-connected GPU clusters).
>
> So in short: higher power doesn't just mean "more electricity." It means the physics of delivering that power cleanly over even millimeters of copper become the binding constraint on how fast the chip can actually run. That's Vicor's entire moat.
>
> $MU $RMBS $AMD $AVGO $GOOG $INTC $SNDK $COHR $LITE $AAOI $BE

**Quoted tweet in the seed post:**

> **QT @andrewdfeldman** — [https://x.com/andrewdfeldman/status/2035341908835221616](https://x.com/andrewdfeldman/status/2035341908835221616)
>
> .@cerebras designs and manufactures exclusively in America.
>
> 120,000 sq ft of new manufacturing capacity is coming online in the next few months.

*Cerebras manufacturing capacity (photos attached to @andrewdfeldman's quoted tweet): CS-3 systems with liquid-cooling manifolds racked on the line, plus new floor space and equipment coming online*
![[joedab12-822814-001.jpg]]

### In-thread replies

> **@semiDL (Tapa Ghosh)** — Sun Mar 22 03:19:20 +0000 2026
> [https://x.com/semiDL/status/2035556908141269435](https://x.com/semiDL/status/2035556908141269435)
>
> @joedab12 Good tweet but mps and others have similar solutions now, and vrm is being integrated into package now by OSATs- unclear how long vicors advantage continues

> **@joedab12 (Joe)** — Sun Mar 22 05:07:16 +0000 2026
> [https://x.com/joedab12/status/2035584071456444557](https://x.com/joedab12/status/2035584071456444557)
>
> Mps is definitely trying but their solution is architecturally different and inferior. Did you notice Vicors first fab is already full and its not just from cerebras. Theres at least one major hyperscaler or oem ramping vicor vpd and theyre looking for 3rd party manufacturing capacity to meet excess demand. Its going to be hard for nvidia to ignore VICR given the ITC rulings, pay close attention.

---

Original source: <https://x.com/joedab12/status/2035386576008822814>
