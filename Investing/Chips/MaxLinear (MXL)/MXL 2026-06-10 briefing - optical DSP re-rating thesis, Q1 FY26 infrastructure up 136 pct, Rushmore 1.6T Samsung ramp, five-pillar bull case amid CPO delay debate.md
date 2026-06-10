---
created: 2026-06-10
description: Current-state briefing on MaxLinear (MXL) — Q1 2026 optical inflection (+136% infrastructure YoY), Samsung-fabbed Rushmore 1.6T DSP ramping 2H26, Washington SiGe TIA, Panther/LANL validation, stock ~$69 after pullback from ~$106 May peak.
source: internal
type: analysis
---

# MXL 2026-06-10 briefing — optical DSP re-rating thesis, Q1 FY26 infrastructure +136%, Rushmore 1.6T Samsung ramp, five-pillar bull case amid CPO delay debate

Status snapshot as of **2026-06-10**. This is an orientation note; a claim-by-claim evaluation of the circulating bull case (with verdicts and captured primary sources) lives in the companion synthesis note in this folder.

## What MaxLinear is

MaxLinear (NASDAQ: MXL) is a fabless analog/mixed-signal and RF semiconductor company, historically known for broadband access silicon (cable modems, Wi-Fi/connectivity SoCs, telecom infrastructure — much of it acquired via Intel's Home Gateway Platform Division in 2020). The 2025–2026 re-rating is driven by a newer business: **PAM4 optical DSPs and analog front-ends for AI data-center interconnect**, where it is the third merchant PAM4 DSP supplier behind [[Marvell Technology (MRVL)]] and [[Broadcom (AVGO)]], with [[Credo Technology (CRDO)]] adjacent in lower-power/shorter-reach niches.

Key product tracks in the AI interconnect story:

- **Keystone** — 400G/800G PAM4 DSP family (Samsung 5nm), currently ramping at multiple hyperscalers in the US and Asia. This is what drove the Q1 FY26 inflection.
- **Rushmore** — 1.6T (200G/lane) PAM4 DSP family on Samsung's leading-edge process (4nm per company materials), demoed at OFC 2025 and showcased live at OFC 2026; sub-25W 1.6T module target; production ramps slated to begin late 2026. Notable as the first major high-speed optical DSP fabbed entirely at Samsung — a deliberate second-source position vs. the TSMC-centric supply chains of MRVL/AVGO.
- **Washington** — 200G/lane transimpedance amplifier (TIA), 4-channel, SiGe BiCMOS, ~750mW typical for four channels, announced available 2026-04-30 with mass production scheduled 2H 2026. Supports fully retimed, LRO/LPO, NPO, and CPO architectures — i.e., it is the analog front-end that rides *every* optical architecture outcome.
- **Panther** — storage accelerator (compression/checksum/crypto offload). On 2026-06-03, MaxLinear and Los Alamos National Laboratory announced hardware-accelerated OpenZFS integration: 57 GB/s reads and 47 GB/s writes with GZIP-L9 vs ~8.1/1.2 GB/s software baseline — ~7x read / ~39x write speedup with near-zero host CPU involvement.
- **Legacy/diversified**: broadband, connectivity, 5G wireless infrastructure (including transport/backhaul), Ethernet PHY — stabilizing-to-recovering after a brutal 2023–2025 downcycle.

## Where it sits in the interconnect stack

In AI clusters, GPUs connect through optical transceiver modules. The signal chain inside a module is roughly: optics (laser/photodiode — supplied by [[Lumentum (LITE)]], [[Coherent (COHR)]], [[Applied Optoelectronics (AAOI)]] et al.) ↔ analog front-end (TIA/driver — [[Semtech (SMTC)]], [[MACOM Technology (MTSI)]], now MXL's Washington) ↔ **DSP retimer** (MRVL, AVGO, MXL) ↔ host ASIC. The DSP is the power-hungry digital brain of the pluggable module; alternative architectures (LPO = remove the DSP entirely; NPO/CPO = move optics toward/into the switch ASIC package) all attack that power budget. MXL is unusual in holding positions on **both sides** of that architectural fight: it sells the DSP (Keystone/Rushmore) *and* the high-linearity analog parts (Washington TIA) that LPO/NPO/CPO architectures require.

Foundry positioning: digital DSPs at Samsung Foundry (5nm/4nm) — sidestepping the [[TSMC (TSM)]] leading-edge/CoWoS queue that MRVL, AVGO, [[Nvidia (NVDA)]], and [[Advanced Micro Devices (AMD)]] compete within. Analog (Washington) on mature SiGe BiCMOS capacity (the [[Tower Semiconductor (TSEM)]]/[[GlobalFoundries (GFS)]]-class specialty fabs), which is structurally uncontested by the AI logic boom. MXL's broadband legacy silicon is largely at [[UMC (UMC)]] and other mature nodes.

## Current state (point-in-time, 2026-06-10)

Point-in-time market data below stays inline per vault convention (not capture-worthy):

- **Stock**: ~$69 (2026-06-09 close), down from a previous close of ~$79 and a May peak above ~$106; still up ~350% YTD ([Yahoo Finance quote](https://finance.yahoo.com/quote/MXL/), [TradingView](https://www.tradingview.com/news/zacks:891d9a55b094b:0-maxlinear-up-354-ytd-is-the-stock-still-worth-considering/)). Market cap crossed ~$9B at the highs; ~$6–7B at current levels (verify in synthesis).
- **Q1 FY2026** (reported 2026-04-23): revenue $137.2M, +43% YoY; infrastructure category +136% YoY, now the largest revenue line, led by optical data-center ramps ([Q1 transcript](https://www.fool.com/earnings/call-transcripts/2026/04/23/maxlinear-mxl-q1-2026-earnings-transcript/)). Stock gapped up ~76–84% on the print.
- **Guidance**: Q2 FY26 revenue $160–170M; FY2026 optical data-center revenue target raised by $30–40M to **$150–170M** ([Seeking Alpha](https://seekingalpha.com/news/4579167-maxlinear-outlines-160m-170m-q2-revenue-outlook-as-it-lifts-2026-optical-data-center-target)).
- **Supply commitments**: 10-Q (as of 2026-03-31) discloses **$180.3M** future minimum inventory purchase obligations, $129.6M due within the remaining nine months of 2026 ([10-Q](https://www.sec.gov/Archives/edgar/data/0001288469/000128846926000029/mxl-20260331.htm)). Note: the circulating bull case cites "$210M" — discrepancy flagged for the synthesis note.
- **Recent pressure**: early-June ~8% drop attributed in coverage to an auditor switch (Grant Thornton → KPMG) plus expanded equity-plan shelf registrations ([Simply Wall St](https://simplywall.st/stocks/us/semiconductors/nasdaq-mxl/maxlinear/news/maxlinear-mxl-is-down-81-after-auditor-switch-and-stock-plan)); broader optical complex also sold off on a SemiAnalysis report of CPO rollout delays — which NVIDIA disputed ([Seeking Alpha](https://seekingalpha.com/news/4601927-applied-optoelectronics-leads-networking-stocks-down-following-report-on-cpo-rollout-delay)).

## The bull case being circulated (five pillars, condensed)

As advanced by retail/X commentators and a Temple 8 Research note (2026-06-09) — **treated as opinion until verified in the synthesis note**:

1. **DSP runway extension**: CPO mass production slipping to 2028/29 (per SemiAnalysis) extends the 800G/1.6T pluggable+DSP window by 2–3 years; hyperscalers must connect Vera Rubin-generation clusters with DSPs today.
2. **Supply moat**: Rushmore on Samsung 4nm allegedly makes MXL the only 1.6T DSP vendor with uncontested fab capacity through ~2H27, while MRVL/AVGO sit in the TSMC/CoWoS queue.
3. **Analog optionality**: Washington TIA + linear architectures (LPO/LRO/NPO) mean MXL wins even if DSPs lose share to analog approaches; SiGe capacity is structurally available.
4. **Panther/storage**: LANL OpenZFS validation positions Panther as a CPU-offload standard for the "agentic era" storage bottleneck.
5. **Sandbagging**: $150–170M FY26 optical guidance is conservative vs. management's own "accelerating ramps through 2027" language and inventory/die-bank build.

Each pillar, plus the counter-evidence (NVIDIA's dispute of the CPO-delay framing, the $180.3M vs $210M discrepancy, the 4nm vs "3nm GAA" confusion, customer concentration, and the structural bear case that LPO/CPO both shrink DSP content long-term), is evaluated with primary-source citations in the companion synthesis note.

## Open questions carried into the synthesis

- Exact Rushmore node: company says Samsung "leading-edge"/4nm; some bull threads claim 3nm GAA — material because the power-efficiency claims differ.
- Whether "only guaranteed 1.6T silicon supply until late 2028" is supportable from any primary source, or is inference.
- True optical revenue mix/customer concentration (hyperscaler count, module-maker intermediaries).
- Competitive response timing: MRVL (Ara/1.6T), AVGO (Sian3), CRDO at 1.6T.
- Valuation: what is priced in at ~25–30x FY26 EV/S on the optical line vs. the legacy business's cyclicality.

## Companion notes

- Claim-by-claim verdicts: [[MXL bull case evaluated claim-by-claim 2026-06 - extended pluggable window real but MXL-specific moats unsourced, 1.6T supplier count is 4 not 3, analog optionality genuine]]
- Modes-of-reasoning analysis (asymmetric upside 6–12mo): _pending — this folder_
