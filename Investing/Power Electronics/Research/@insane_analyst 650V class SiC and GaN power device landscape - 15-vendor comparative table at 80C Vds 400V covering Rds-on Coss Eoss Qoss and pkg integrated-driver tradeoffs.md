---
created: 2026-05-18
published: 2026-05-16
description: Irrational Analyst's 15-vendor comparative landscape of 650V-class SiC and GaN power discrete devices, all values normalized at 80C and Vds = 400V, covering Rds-on, Coss/Ciss/Crss, Eoss, Qoss, integrated-driver availability, and package format — plus per-vendor structural notes on portfolio gaps (no SiC, no 650V class, foundry-only, etc.).
source: https://x.com/insane_analyst/status/2055727877593923946
type: research
authors: ["Irrational Analysis (@insane_analyst)"]
---

# 650V Class SiC + GaN Power Device Landscape

@insane_analyst (Irrational Analysis) published a hand-built comparative landscape table covering 650V-class SiC and GaN power discrete devices across 15+ vendors. All values normalized at **80°C** and **Vds = 400V**. Source post is a screenshot of the table — full source dataset lives at the irrationalanalysis.substack.com watermark.

## Key takeaways

1. **Coverage is bimodal**: most vendors are present in either SiC or GaN, rarely both — the table's most striking column is the "Comment" field flagging "No GaN offering" or "No 650V class SiC. Only has 1200V class" or "GaN foundry only?" across half the vendors.
2. **Integrated-driver is still rare at 650V**: only Infineon (IMLT65R015SAD1), Novitas (G3FZ5MTOHL), Innoscience (NN650TA030AH), and CGD (CGD650D25P2) ship parts with integrated gate driver in this landscape — the rest require external gate-driver design.
3. **Package format is highly fragmented**: TOLT, TOLL, TOLL-BN, TO-247, TO-247X, QFNX9, BIBHEPN-9 — discrete-FET package proliferation creates application-specific design lock-in beyond pure device specs.
4. **Wolfspeed pulled out of SiC discrete loss-leader** ("They existed SiC due to losses. Have a deal with Wolfspeed" — author's annotation in the table reds row, between Renesas and STM, suggesting an OEM/partnership context). Wolfspeed's own listed part (C4WV01506ST) is the only Wolfspeed-direct SiC TOLT in the table.
5. **Power Integrations (POWI) is opaque by design**: author's closing annotation — "Highly integrated. I have no idea how to properly compare or evaluate these devices. Datasheets missing all the info I am looking for." POWI's integrated power conversion ICs don't fit the discrete-FET comparison frame.

## Original Content

> [!quote]- @insane_analyst (Irrational Analysis) — 2026-05-16
> Does this table look painful to make?
> It was painful.

*Source table — 650V Class SiC+GaN Power Device Landscape, watermarked irrationalanalysis.substack.com:*
![[irrationalanalysis-923946-001.png]]

### Transcribed table

All values at 80°C. Assume Vds = 400V. `?` cells preserved from source where author marked unknown. Long structural-note rows (color-coded in original) flagged as **NOTE** rows.

| Vendor | Part# | Package | Tech | Integrated Driver? | Vds_max (V) | Rds_on (mΩ) | Max Power Dissipation (W) | Crss (pF) | Coss (pF) | Ciss (pF) | Eoss (μJ) | Qoss (nC) | Comment |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Infineon | IGLT65R025SQ | TOLT | GaN | No | 650 | 35 | 1300 | 2 | 105 | 800 | 12 | 82 | |
| Infineon | IMLT65R015SAD1 | TOLT | GaN | Yes | 650 | 17.5 | 380 | 2 | 200 | 3000 | 20 | 215 | |
| Novitas | NV6524 | TOLL | SiC | No | 650 | 28 | 240 | ? | ? | ? | ? | ? | |
| Novitas | G3FZ5MTOHL | TOLL | SiC | Yes | 650 | 25 | 800 | ? | ? | ? | ? | ? | |
| Renesas | TP65H03064PRS | TOLL | GaN | No | 650 | 35 | 160 | 5 | 140 | 1800 | 15 | 175 | Wrong package |
| **NOTE** | colspan | — | — | — | — | — | — | — | — | — | — | — | "They existed SiC due to losses. Have a deal with Wolfspeed" — LOL |
| STM | SGT03R7DFTP | TOLT | GaN | No | 700 | 30? | 200-250? | ? | 233 | 218 | ? | 190 | In development |
| STM | SCT011T065G3 | TOLL | SiC | No | 650 | 14 | 400 | 20 | 250 | 3000 | ? | ? | |
| **NOTE** | TI | — | — | — | — | — | — | — | — | — | — | — | "Vertical GaN is gone be amazing if it works. Right now its just hopes and dreams." |
| TI | NV8GO15N065SC1 | TO-263-7G | GaN | No | 650 | 15 | 250 | ? | 40 | 4000 | ? | ? | |
| Onsemi | LMG365xR025 | TOLL | GaN | No | 650 | 17 | 540 | 35 | 160 | 7000 | ? | ? | Very smooth pkg |
| **NOTE** | Wolfspeed | — | — | — | — | — | — | — | — | — | — | — | No GaN offering |
| Wolfspeed | C4WV01506ST | TOLT | SiC | No | 650 | 17 | 257 | 20 | 200 | 5000 | 28 | ? | |
| Innoscience | NN650TA030AH | TOLL | GaN | Yes | 650 | 36 | 255 | 4 | 300 | 1700 | 25 | ? | Wrong package |
| Innoscience | GANC035-650UTH | TOLT | GaN | No | 650 | ? | 1690 | ? | ? | ? | ? | ? | No charts |
| **NOTE** | Nexperia | — | — | — | — | — | — | — | — | — | — | — | "No 650V class SiC. Only has 1200V class." |
| ROHM | GNP2025TLR | TOLL-BN | GaN | No | 650 | 15 | 160 | 11 | 150 | 400 | 17 | 138 | |
| ROHM | SCT3017ALHR | TOLT | SiC | No | 650 | 17 | 270 | 25 | 120 | 280 | 3000 | 27 | |
| Toshiba | QFNX9 | TOLL | GaN | No | 650 | > 54 | ? | ? | ? | ? | ? | ? | |
| Toshiba | TW015N65C | TO-247X | SiC | No | 650 | 17 | 540 | 35 | 160 | 7000 | ? | ? | Very smooth pkg |
| **NOTE** | Fuji Electric | — | — | — | — | — | — | — | — | — | — | — | "Their website is very confusing. I cannot find datasheets for discrete FETs." |
| **NOTE** | Semiq | — | — | — | — | — | — | — | — | — | — | — | "No GaN device offering. Foundry only?" |
| **NOTE** | Semiq | — | — | — | — | — | — | — | — | — | — | — | "No 650V class SiC. Only has >= 1200V class." |
| **NOTE** | Microchip | — | — | — | — | — | — | — | — | — | — | — | "Portfolio focuses on GaN power amplifiers for RF and communications. Different class of chip. Not for power conversion." |
| Microchip | MSC015AAA070B | TO-247 | SiC | No | 650 | ? | ? | ? | ? | 40 | 5000 | ? | a foundry only? |
| **NOTE** | Sanan | — | — | — | — | — | — | — | — | — | — | — | "GaN foundry only?" |
| Sanan | SM5W83807YJ | TOLL | GaN | No | 650 | 27 | ? | 28 | ? | ? | ? | ? | Website so slow I can't download datasheet |
| **NOTE** | CGD | — | — | — | — | — | — | — | — | — | — | — | "No SiC offering" |
| CGD | CGD650D25P2 | BIBHEPN-9 | GaN | Yes | 650 | 60 | 40 | 200 | ? | ? | ? | 125 | |
| Power Integ. | — | — | — | — | — | — | — | — | — | — | — | — | "Highly integrated. I have no idea how to properly compare or evaluate these devices. Datasheets missing all the info I am looking for." |

### Author thread context

The thread tail picked up reader pushback on visual style — "It's even more painful that it is in comic sans" (@MajorOcelot45), "can you use easier fonts and paler colors? the chart is painful to read lol" (@mattmtxsc). Irrational Analyst replied with 😈 emoji, signaling intentional aesthetic. The substance is the dataset, not the rendering.

## Vendor → ticker mapping

All public-market vendors now have vault folders scaffolded under either `Power Electronics/` (canonical) or `Chips/` (cross-sector when broader analog/MCU thesis dominates):

**Power Electronics canonical home:**
- [[Infineon Technologies (IFX.DE)]] — #1 in power semis; 2 GaN parts incl integrated-driver IMLT65R015SAD1
- [[Navitas Semiconductor (NVTS)]] — pure-play GaN (the "Novitas" entries: NV6524 + G3FZ5MTOHL)
- [[STMicroelectronics (STM)]] — analog + power; SiC SCT011T065G3 + GaN SGT03R7DFTP in development
- [[Onsemi (ON)]] — SiC focus; LMG365xR025 GaN annotated "very smooth pkg"
- [[Wolfspeed (WOLF)]] — pure-play SiC; only direct SiC TOLT in landscape (C4WV01506ST)
- [[Innoscience (2577.HK)]] — Chinese pure-play GaN; 2 parts (NN650TA030AH + GANC035-650UTH)
- [[ROHM (6963.T)]] — Japanese SiC + GaN; GNP2025TLR + SCT3017ALHR
- [[Fuji Electric (6504.T)]] — Japanese power; vertical GaN R&D angle
- [[Sanan Optoelectronics (600703.SH)]] — Chinese GaN foundry-style positioning
- [[Power Integrations (POWI)]] — integrated power-conversion ICs (author flagged as opaque)
- [[Toshiba (6502.T)]] — TW015N65C SiC; conglomerate post-Kioxia spinoff

**Chips canonical home (cross-sector exposure to Power Electronics):**
- [[Texas Instruments (TXN)]] — analog + embedded dominant; NV8GO15N065SC1 GaN
- [[Renesas (6723.T)]] — MCU + analog + automotive dominant; TP65H03064PRS GaN
- [[Microchip Technology (MCHP)]] — RF/comms GaN amplifiers (different class); SiC MSC015AAA070B

**Private / not scaffolded:**
- Nexperia — Wingtech subsidiary
- Semiq — private foundry
- CGD — Cambridge GaN Devices, private UK

## Methodology note (how this transcription was built)

Source is a single 1115×850 PNG of a hand-styled table in Comic Sans. Tesseract OCR returned mostly garbage on this font + dense-table layout. Multimodal vision rendering of the full image was too downsampled to read row-by-row. The working path: ImageMagick crop into top/bottom halves + 2× upscale, then multimodal read of each half separately. The upscaled halves were clear enough to transcribe directly without OCR.
