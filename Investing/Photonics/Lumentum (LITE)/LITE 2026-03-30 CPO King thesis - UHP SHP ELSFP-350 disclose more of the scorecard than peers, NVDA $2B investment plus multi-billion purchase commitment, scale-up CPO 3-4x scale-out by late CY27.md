---
created: 2026-05-13
published: 2026-03-30
description: Crux Capital argues [[Lumentum (LITE)]] is the strongest CPO laser story in the public record — UHP (350 mW @ 50°C, 1311 nm, >20% PCE, <500 kHz linewidth, RIN <-147 dB/Hz), SHP (>1.0 W @ 25°C, >800 mW @ 50°C, <100 kHz linewidth, SMSR >40 dB), and ELSFP-350 module (24 dBm/wavelength, dual-TEC); UHP sole-sourced with [[Nvidia (NVDA)]] agreement of $2B investment + multi-billion purchase commitment + future capacity access; ~85% CAGR InP optical lane demand; San Jose initial + UK late summer 2027 + Greensboro NC early 2028 capacity; multi-hundred-million CY27 UHP revenue capacity; scale-up CPO Phase 1 sized 3-4x scale-out, first shipments late CY27; ELS modules ~2-2.5x chip revenue content.
source: https://cruxcapitalgroup.substack.com/p/lumentum-the-cpo-king
type: thesis
authors: ["Crux Capital Group (@cruxcapitalgroup)"]
---

# LITE 2026-03-30 CPO King thesis — UHP/SHP/ELSFP-350 disclose more of the scorecard than peers, NVDA $2B investment plus multi-billion purchase commitment, scale-up CPO 3-4x scale-out by late CY27

## Key Takeaways

- **Core claim**: in CPO, "value may eventually concentrate into a smaller group of companies than the market expects" — [[Lumentum (LITE)]] looks like the clearest example. The bottleneck few peers can credibly address is the **external laser source** (ELS).
- **Three disclosed pieces of the CPO position** — author's framing of why LITE separates itself by disclosing the *scorecard that counts* (output power, linewidth, RIN, temperature behavior, module path), not just a hero power figure:
  - **UHP** (current commercial foundation): 1311 nm, up to 350 mW @ 50°C / 235 mW @ 70°C; >20% power-conversion efficiency; linewidth <500 kHz; RIN <-147 dB/Hz. "Unusually thorough disclosure" relative to peers.
  - **SHP** (next step up, OFC 2026): 1310 nm, >1.0 W @ 25°C / >800 mW @ 50°C; linewidth <100 kHz; SMSR >40 dB. Positions LITE in a higher-power class of ELS.
  - **ELSFP-350** (module): 1311 nm, up to 24 dBm optical output per wavelength, dual-TEC thermal control — the device and packaging path that makes it deployable inside a CPO system.
- **Systems-level proof point**: at OFC 2026 LITE demonstrated a 16-channel DWDM UHP setup using two ELSFP modules on a 200 GHz grid with ~24 dBm/channel into fiber. UHP framing covers pluggable transceivers, ELS for CPO optical engines, and **shared laser pools**; SHP framing extends toward 800G/1.6T+ optical interconnects.
- **Why disclosure breadth matters**: CPO is "a usable-light problem, not just a chip performance exercise." Many competitors leave holes in the public record (strong power figure with no noise profile; module concept without serious characterization; "adjacent" architecture talk without integration evidence). LITE has addressed several on the record.
- **Economic ladder** (chip → module): LITE's OFC 2026 deck frames future expansion into ELS as ~2x opportunity above UHP chips alone; earlier earnings commentary framed ELS modules at ~2x-2.5x the revenue content of individual laser sales. Moving from selling UHP chips to turnkey ELS support materially expands the wallet share.
- **Pricing power setup** (early-ramp leverage):
  - LITE has described itself as a **primary / sole-sourced** UHP supplier, disclosing the **largest purchase commitment in company history** for UHP.
  - [[Nvidia (NVDA)]] agreement: **$2 billion investment + multi-billion purchase commitment + future capacity access rights**. Nonexclusive, but the setup supports "firmer pricing and better commercial leverage" during the early qualification window. Longer arc = broader participation, more competitive pressure.
- **Capacity roadmap** ("supply is part of the moat"):
  - ~85% CAGR in InP optical lane demand across EML, CW and UHP lasers.
  - Initial UHP supply from **San Jose**; incremental shipments from the **UK fab begin late summer 2027**; new **Greensboro, NC** fab targeted to begin UHP ramp by **early 2028**.
  - Existing capacity sufficient to support **multi-hundred-million USD UHP revenue in CY27**.
  - Working to **presell remaining capacity to a small handful of customers** — disposition that supports tight allocation and pricing.
  - Tight supply can become a revenue ceiling even when demand is robust → key question is qualified, shippable volume, not just product advantage.
- **Size of the prize evolving**: scale-out CPO is the anchor for the UHP platform (multi-hundred-million CY27); **scale-up CPO Phase 1** is framed as **3x-4x larger** than scale-out, with **first scale-up shipments expected late CY27** and multi-wavelength variants being integrated into the UHP platform.
- **What still needs proving**: (1) product-level reliability/qualification evidence specifically for UHP, SHP and ELSFP-350; (2) measurement clarity on SHP figures from OFC 2026; (3) fuller module-level behavior / qualification detail for ELSFP-350.
- **Author posture**: "Lumentum currently looks like the strongest CPO laser story in the market" on the basis of disclosed material; lead in public disclosure doesn't hand it the entire CPO market, but positions it to capture disproportionate share of the highest-value merchant layer early on. References primer post "So much to learn...CPO" (Mar 29).

## Tickers & Companies

- [[Lumentum (LITE)]] — subject; UHP/SHP indium-phosphide laser platform; ELSFP-350 module; scale-out and scale-up CPO ELS supplier
- [[Nvidia (NVDA)]] — UHP customer; $2B investment + multi-billion purchase commitment + capacity access rights

## Cross-references

- See also: [[POET Technologies (POET)]] which positions its Optical Interposer as the passive-alignment alternative for ELS packaging and partners with [[Sivers Semiconductors (SIVE.ST)]] on a competing ELS for CPO architecture.
- Primer companion: "So much to learn...CPO" (Crux, 2026-03-29) — referenced as the prerequisite reading for this thesis.

## Original Content

*Verbatim from <https://cruxcapitalgroup.substack.com/p/lumentum-the-cpo-king>*

Everyone invested photonics long term should be paying attention to CPO.

This is one of the places where value may eventually concentrate into a smaller group of companies than the market expects.

Lumentum is one of the clearest examples of that.

So let's dig into all of it.

If you haven't read my primer for this CPO series, please read it here: [So much to learn...CPO](https://cruxcapitalgroup.substack.com/p/so-much-to-learncpo) (Gaetano, Mar 29).

This report draws entirely from public information like product pages, press releases, conference materials, papers, earnings commentary, and Lumentum's OFC 2026 investor deck. Private channels may carry additional detail, but on the basis of what is disclosed today, Lumentum currently looks like the strongest CPO laser story in the market.

### Why Lumentum stands out

The easiest mistake in CPO is assigning every company in the theme equal credit.

Doing so usually obscures where the real bottlenecks sit.

Few bottlenecks in this architecture are more consequential than the external laser source and that is precisely where Lumentum separates itself. Lumentum has a working UHP laser platform, a newer SHP device, and an ELSFP-350 module built around that platform. The significance goes beyond a strong chip announcement. It extends into a credible external-light-source architecture with real deployment geometry.

CPO is about more than producing a powerful laser. It is about producing enough usable light to survive packaging, coupling, routing, and module-level losses, while fitting into a system that can actually be deployed and serviced. That is the bar Lumentum is building toward.

### What Lumentum has actually shown

Lumentum's CPO position rests on three pieces: UHP, SHP, and ELSFP-350.

UHP is the current commercial foundation. Lumentum's UHP product page describes a laser operating at 1311 nm, delivering up to 350 mW at 50°C and 235 mW at 70°C, with power-conversion efficiency above 20%, linewidth below 500 kHz, and RIN below -147 dB/Hz. That is an unusually thorough disclosure. Most companies in this space share far less in a single place.

SHP is the next step up in output. At OFC 2026, Lumentum presented a 1310 nm device delivering more than 1.0 W at 25°C and more than 800 mW at 50°C, with linewidth below 100 kHz and SMSR above 40 dB. That is a significant jump, positioning Lumentum in a clearly higher-power class of external light source.

ELSFP-350 is where the narrative becomes commercially tangible. Lumentum's disclosed materials describe the module operating at 1311 nm with up to 24 dBm optical output per wavelength and dual-TEC thermal control. Lumentum is showing the device and the packaging path that makes it useful inside an actual CPO system.

There is also a broader systems dimension in the disclosed materials that I ahve found. At OFC 2026, Lumentum described a 16-channel DWDM UHP demonstration using two ELSFP modules on a 200 GHz grid, with approximately 24 dBm per channel into fiber. The product framing around UHP explicitly includes pluggable transceivers, ELS for CPO optical engines, and shared laser pools, while the SHP framing extends toward 800G, 1.6T and beyond optical interconnects. That gives useful context for how Lumentum envisions scaling these sources into a broader external laser pool / multi-channel architecture.

### What this all means

The strongest part of the Lumentum case is more than just the raw power that is easy to fixate on.

It is that Lumentum has disclosed more of the scorecard that actually counts. Output power is one variable. Linewidth, RIN, temperature behavior, and the gap between a raw device and a usable module are extremely important and frequently absent from competitor disclosures. Lumentum is one of the few names to have addressed several of them on the record, which makes the case substantially easier to evaluate.

The distinction is between a powerful flashlight and a light source engineered for the messy realities of CPO like packaging losses, thermal stress, multiple channels, and the requirement that the laser stay outside the hottest part of the switch. That is the problem ELSFP-350 is visibly solving. It signals that Lumentum understands this as a usable-light problem, not just a chip performance exercise.

It also helps explain the gap with much of the peer group. In the public record, many competitors leave meaningful holes. They may show a strong power figure with no noise profile. They may describe a module concept without serious characterization. Or they may sound adjacent to the external-light-source architecture without demonstrating how they fit inside it.

Lumentum still has more to prove. But the disclosed evidence is more complete than rest of the field.

### What this strength could actually mean

This is where the economic side starts to get interesting.

Lumentum's lead in public disclosure does not automatically hand it the entire CPO market of coruse. CPO is still a full system with room for silicon photonics engines, packaging players, module vendors, and additional laser suppliers over time. The more realistic implication is that Lumentum may be in one of the best positions to capture a disproportionate share of the highest-value merchant layer early on, being high-power external laser sources, and eventually the higher-content ELS module layer that sits on top of them.

Selling the UHP chip is already valuable. Moving further into turnkey ELS support expands the opportunity materially. In the OFC 2026 deck, management said future expansion into ELS could increase the opportunity by roughly 2x above UHP chips alone, and earlier earnings commentary framed ELS modules at approximately 2x to 2.5x the revenue content of individual laser sales. That does not lock in the outcome, but it does show why the packaging layer has economic significance beyond the chip itself.

This is also where pricing power enters the conversation.

Lumentum's strongest case for pricing leverage comes from a combination of technical position, ecosystem position, and supply tightness. Lumentum has perviously described itself as a primary supplier in UHP, saying it was "sole sourced", disclosing the largest purchase commitment in company history for UHP, and subsequently filing the NVIDIA agreement which included a $2 billion investment plus a multibillion-dollar purchase commitment and future capacity access rights. That is the kind of setup that typically supports firmer pricing and better commercial leverage, especially during the early qualification window.

The longer-term picture is more balanced. The NVIDIA agreement is nonexclusive, and hyperscalers will always pursue supply assurance, optionality, and negotiating leverage. So I think the cleanest framing for pricing is therefore that Lumentum likely has its strongest leverage in the early ramp, particularly where supply is scarce and qualification is narrow, while the longer arc of the market will bring broader participation and more competitive pressure.

OFC made clear that Lumentum sees demand ramping hard. Management describes ~85% CAGR in InP optical lane demand for EML, CW, and UHP lasers, notes the company is scaling from the industry's largest InP wafer-fab baseline, and outlines a dedicated UHP capacity build plan. Existing capacity is described as sufficient to support multi-hundred-million UHP revenue in CY27. Initial supply comes out of San Jose, incremental shipments from the UK fab begin in late summer 2027, and the new Greensboro, NC fab is expected to start ramping UHP production by early 2028. The same deck indicates Lumentum is working to presell remaining capacity to a small handful of customers.

Tight supply can support stronger pricing, tighter customer relationships, and more selective allocation. It can also become the ceiling on revenue even when demand is robust. So one of the key questions facing Lumentum is not just whether it has the best product but it is how quickly that product advantage can translate into qualified, shippable volume.

The volume ramp also changes the size of the prize. Management frames scale-out CPO as the anchor for the UHP platform, with a multi-hundred-million-dollar ramp in CY27. It then frames scale-up CPO Phase 1 as 3x to 4x larger than scale-out CPO, with first scale-up shipments expected by late CY27 and multi-wavelength variants being integrated into the UHP platform. The implication is significant. The early scale-out story may be meaningful on its own terms, but management clearly views scale-up as the much larger opportunity.

### What still needs proving

For all of Lumentum's disclosed strength there are still details that would be useful.

If anyone has any insight into any of these, please do share and I will amend

The main area is qualification. Lumentum clearly has reliability heritage across its broader laser family. Product-level evidence for UHP, SHP, and ELSFP-350 would make the case more complete.

The second area is measurement clarity, especially around SHP. The OFC 2026 figures are impressive, and a little more detail around how those numbers are measured would sharpen the public record.

The third area is module-level detail. For ELSFP-350 a fuller picture around module behavior and qualification would strengthen the deployment case.
