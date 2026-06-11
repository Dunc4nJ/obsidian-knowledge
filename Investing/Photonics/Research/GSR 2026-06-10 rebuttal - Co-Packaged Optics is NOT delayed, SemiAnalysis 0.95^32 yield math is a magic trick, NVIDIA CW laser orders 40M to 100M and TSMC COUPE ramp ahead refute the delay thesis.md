---
created: 2026-06-11
published: 2026-06-10
description: Global Semi Research's same-day rebuttal to the June 9 SemiAnalysis "Powered Down, Lights Off" CPO-delay report argues the delay thesis is a positioning call in supply-chain costume — the 0.95^32 system-yield argument is a "magic trick," TSMC COUPE is ramping ahead of expectations, and NVIDIA's CW-laser order escalation from ~40M to ~100M units proves CPO demand is pulling forward, not sliding to 2029.
source: https://globalsemiresearch.substack.com/p/co-packaged-optics-is-not-delayed
type: research
authors: ["Global Semi Research (GSR)"]
subsectors: [Optical components & engines, Foundries]
---

# GSR 2026-06-10 rebuttal — Co-Packaged Optics is NOT delayed, SemiAnalysis is "just wrong"

This is the explicit **counter-position** to the June 9 [[SemiAnalysis CPO book argues co-packaged optics is central to scale-up not scale-out, with Nvidia CPO endpoints injected at Feynman ~2028 not Rubin Ultra|SemiAnalysis "Powered Down, Lights Off" delay report]] (institutional-only, not capturable) and slots directly into the [[2026-06-09 CPO-delay dispute - SemiAnalysis report sinks optical names (AAOI -14pct COHR -11pct LITE -8pct) then NVIDIA Shainer rebuts Spectrum-X switch delays but leaves GPU-endpoint CPO thesis intact|June 9 CPO-delay dispute]]. With this capture, **BOTH sides of the dispute now exist in the vault**: delay (SemiAnalysis Jan + Jun) vs no-delay ([[2026-06-09 CPO-delay dispute - SemiAnalysis report sinks optical names (AAOI -14pct COHR -11pct LITE -8pct) then NVIDIA Shainer rebuts Spectrum-X switch delays but leaves GPU-endpoint CPO thesis intact|NVIDIA's Shainer]], GSR here). Captured as a bull-side rebuttal to balance the file — but framed neutrally: GSR is a paid Substack and the body below is the **free preview only** (see caveat).

> [!warning] Capture is the free preview only — full paid post not retrievable
> This is a paid-only ("only_paid") Substack post. The vault's Substack auth cookies **expired 2026-06-04** and could not be refreshed headlessly by this capture worker (refresh requires manual Chrome DevTools interaction). The Original Content below is the complete **free preview** (everything Substack renders before the paywall), which cuts off mid-way through the "Follow the substrates" section after the laser-order argument. The preview nonetheless contains the four load-bearing claims (COUPE ramp, laser-order escalation, the 0.95^32 rebuttal, the dispute framing). When cookies are refreshed, re-capture to append the paywalled remainder (substrate/EMIB/CoWoS color, downstream pluggable-DSP implications, and GSR's price/position call if any).

## Key Takeaways

- **The headline rebuttal: the delay thesis is "a positioning call wearing a supply-chain costume."** GSR refuses to hedge — not "SA is half-right," not "scale-up murky / scale-out fine." It claims the delay narrative collapses "the instant you stop reading spreadsheets and start calling the people who actually build this stuff." This is the no-delay pole of the dispute, opposite the SemiAnalysis revision (scale-out down through 2027, scale-up pushed to 2029).
- **(c) The SemiAnalysis yield-math argument, addressed head-on.** SA's case rests on assuming **95% optical-engine attach yield, compounded across 32 COUPEs per Spectrum-6 ASIC: 0.95^32 ≈ 19% system yield.** GSR calls this "a magic trick" — it "freezes yield at one pessimistic snapshot and raises it to the 32nd power as though yield never improves," ignoring screening, binning, and redundancy. GSR notes SA *refutes its own number*: SA admits NVIDIA's Quantum-X (3 COUPEs/module) is "in comparatively better shape" because modules can be screened — proving 0.95^32 is "an artifact of module granularity, not a law of physics." And [[Nvidia (NVDA)]]'s Spectrum-X carries **redundant engines (32 active plus spares)**, so one bad coupling does not brick the switch. GSR grants the legitimate concerns: a soldered switch substrate has **no rework path**, and Spectrum 6 reportedly showed **>3.5 dB insertion loss** in system-level testing (enough to eat the entire optical channel budget), root cause not yet pinned by NVIDIA or [[TSMC (TSM)]].
- **(a) TSMC COUPE ramp "running ahead of expectations."** "TSMC has thrown enormous resources at COUPE; per our own checks the ramp is running ahead of expectations, not behind." Directly contradicts the delay revision.
- **(b) NVIDIA laser-order escalation as CPO evidence — the supply-chain "smoking gun."** NVIDIA's guidance to [[Coherent (COHR)]] and [[Lumentum (LITE)]] for high-power CW (continuous-wave) lasers climbed **from ~40M units in January to ~100M units by April-May** — "very likely pulls some 2027-2028 demand forward." GSR translates: ~10M+ ELSFP external-laser units, back-solving to **CPO shipments in the hundreds of thousands — ~200,000-300,000 switches in 2027 scaling toward 600,000-800,000 in 2028**, squaring with TSMC's COUPE production plan. [[Lumentum (LITE)]] has announced its largest ELSFP purchase order ever; both LITE and [[Coherent (COHR)]] say they expect to ship into scale-up hardware **by 2027** (not 2029). The argument: you don't book out an FA production line for a technology "delivering meaningfully below prior expectations."
- **(d) What the dispute means for the pluggable-DSP window.** [The free preview cuts off before GSR's explicit downstream conclusion.] The structural read: SemiAnalysis's delay (scale-up to 2029) would *extend* the pluggable-optics + standalone optical-DSP runway, a tailwind for [[MaxLinear (MXL)]], [[Marvell Technology (MRVL)]], [[Broadcom (AVGO)]], [[Credo Technology (CRDO)]] and LPO names like [[MACOM Technology (MTSI)]] / [[Semtech (SMTC)]]. GSR's no-delay rebuttal cuts the *other* way for the optical-transceiver/laser names (COHR, LITE, AAOI, GLW, MRVL that sold off June 9) — if CPO is on time, those names are oversold; but the *implied pluggable window is shorter than the delay camp assumes*. Both poles are now documented so the pluggable-vs-CPO timing debate can be reasoned from primary positions rather than one side's framing.

## Original Content

> [!quote]- Source Material — Global Semi Research, "Co-Packaged Optics Is Not Delayed. SemiAnalysis Is Just Wrong" (published June 10, 2026). FREE PREVIEW ONLY — paywalled remainder not captured (see caveat above).
>
> # Co-Packaged Optics Is Not Delayed. SemiAnalysis Is Just Wrong
>
> > **Follow the capacity commitments.** Nvidia does not scale high-power laser orders from 40 million to 100 million units, and Lumentum does not book out an entire FA production line, for a technology that is supposedly delivering "meaningfully below prior expectations."
>
> On June 9, SemiAnalysis published "Powered Down, Lights Off" and told investors that co-packaged optics is going to be late — scale-out CPO shipments revised down through 2027, scale-up pushed to 2029, the whole photonics "bottleneck trade" overcrowded and due for a violent unwind. Within hours, Lumentum, Coherent, Applied Optoelectronics, Corning and Marvell sold off. The note was elegant, confident, and forwarded everywhere. It is also wrong about the one thing it most wants to be right about: CPO is not being delayed.
>
> *[Image — header chart; not retrievable behind paywall, omitted]*
>
> Let us not hedge, because the moment calls for none. We are not going to tell you SA is half-right, that scale-up is murky while scale-out is fine, that "it's complicated." On CPO, the delay thesis is not a supply-chain finding. It is a positioning call wearing a supply-chain costume — and it falls apart the instant you stop reading spreadsheets and start calling the people who actually build this stuff.
>
> ## The 19% that gives the game away
>
> Start with the number doing all the work. SA's CPO-is-late case rests on a single arithmetic flourish: assume 95% optical-engine attach yield, compound it across 32 COUPEs per Spectrum-6 ASIC, and 0.95^32 lands at roughly 19% system yield. Devastating, if you take it at face value. It is also a magic trick. The calculation freezes yield at one pessimistic snapshot and raises it to the 32nd power as though yield never improves, as though there is no screening, no binning, no redundancy, and as though all 32 engines must be flawless forever at exactly that rate.
>
> Let's first acknowledge the legitimate concerns, because the underlying worry is real. A soldered switch substrate has no rework path. Spectrum 6 reportedly showed more than 3.5 dB of insertion loss in system-level testing, enough to eat the entire optical channel budget. Integration at 32 engines is genuinely hard, and neither Nvidia nor TSMC had pinned the root cause at the time of writing. Granted, all of it.
>
> But here is the problem: SA's own report refutes its own scary number a few paragraphs later. They observe that Nvidia's Quantum-X, with just three COUPEs per module, is "in comparatively better shape" precisely because you can screen modules and select the good ones — which is an admission that the 0.95^32 framing is an artifact of module granularity, not a law of physics. They also know Spectrum-X carries redundant engines, 32 active plus spares, so a single bad coupling does not brick the switch. Yield is a point on a learning curve, not a constant of nature, and TSMC has thrown enormous resources at COUPE; per our own checks the ramp is running ahead of expectations, not behind. Taking 0.95 to the 32nd power and presenting the output as a forecast is not analysis. It is conjecture — a frightening figure reverse-engineered to fit a bearish headline.
>
> ## Follow the substrates
>
> Now the question SA never answers, the one that detonates the whole thesis: if CPO is sliding to 2029, why is the entire upstream supply chain in the most violent shortage it has ever seen, right now?
>
> Start at the laser. Nvidia's guidance to Coherent and Lumentum for high-power CW (continuous-wave) lasers climbed from roughly 40 million units in January to about 100 million units by April and May — a jump that very likely pulls some 2027–2028 demand forward. Translate it: that is on the order of ten-million-plus ELSFP external-laser units, which back-solves to CPO shipments in the hundreds of thousands — call it 200,000–300,000 switches in 2027 scaling toward 600,000–800,000 in 2028 — and it squares with TSMC's COUPE production plan. This is not a forecast hanging in mid-air; Lumentum has already announced its largest ELSFP purchase order ever, with both it and Coherent stating they expect to ship into scale-up hardware by 2027.
>
> *[Free preview ends here. The "Follow the substrates" section and everything after — substrate/packaging detail, downstream pluggable-DSP implications, and any GSR position call — are behind the paywall and were not retrievable at capture time.]*

Source: <https://globalsemiresearch.substack.com/p/co-packaged-optics-is-not-delayed>
