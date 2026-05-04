---
created: 2026-05-04
description: Long thesis on Bloom Energy (BE) arguing solid-oxide fuel cells displace gas turbines for AI data center power on capability (10 features), economics, and unconstrained TAM.
source: https://x.com/jasons_chips/status/2051038747865849962
type: thesis
authors: ["Jason's Chips (@jasons_chips)"]
---

# Bloom Energy thesis (Jason's Chips, free Substack release)

> Released for free as an example of paid-tier research. Substack: <https://jasonschips.ai>.
> Disclaimer: not financial advice.

## Contents

1. Why We Need Bloom Energy — failures of the grid and the turbine; the new requirements
2. Ten Features of Bloom Boxes
3. The Unconstrained TAM
4. Other Energy Solutions (solar+storage, non-scalable renewables, SMRs, datacenters in space)
5. Conclusion

---

# Why We Need Bloom Energy

## The Failure of the Grid

The grid was built a century ago and expects predictable 1-2%/yr demand growth. AI wants to double capacity; the old infrastructure is not built for it.

Power cannot be stored. At any moment total supply must match total demand, so before a load is added the grid operator must figure out how to add equivalent supply without breaking the grid. Enter system studies — voltage stability, frequency response, contingency scenarios, load flow under fault conditions for each new data center. These studies assume a fixed grid, but the grid is constantly changing — when topology changes faster than studies complete, studies go stale.

This is why new interconnections take five years. The logistics of adding data centers to the grid is terrible. We must bypass the grid and go behind the meter.

## The Failure of the Turbine

The classical behind-the-meter solution is the gas turbine. Three main types:

**Combined cycle** — combines two cycles. Cycle 1 converts natural gas to energy via turbining; Cycle 2 converts the heat byproduct from Cycle 1 to energy via steam. Maximum extraction from natural gas, but very complicated and slow to build. Preferred for grid supply, not behind-the-meter.

**Aeroderivative** — literally a jet engine strapped to the ground. ~$2,000/kW. Majority of the market. Made by GE Vernova, Siemens, etc. Problem: the 1990s/2000s gas turbine oligopoly suffered a massive boom-bust cycle, so the aero guys got "PTSD" (Post Traumatic Supply Disorder) and refuse to build new factories despite demand. Great for GEV stock; bad for customers. GEV is fully sold out through 2030.

**Reciprocating engine** — literally car engines. Cheaper per kW but insane maintenance. Smaller, less power per unit — a 1 GW deployment requires 100–400 of them. Basically a 24/7 auto repair shop on the data center campus.

**Pollution** — all gas turbines release NOx and SOx, harmful particulates causing public health problems. Every deployment is subject to stringent permitting and exposure to environmental lawsuits.

# The Requirements of the New Solution

## Regulatory Landscape: Capital vs. Permission

Building a data center requires capital and permission.

- **2024–2025**: capital scarce (chatbot ROI uncertain), permission abundant (chatbots didn't need many data centers, no job loss fears).
- **Today**: completely flipped. AI agents are extremely capable. Anthropic at $30B ARR by end of Q1 effectively answers the ROI question. AI compute demand is parabolic. Data centers are now political and environmental issues. **Capital abundant. Permission scarce.**

We are transitioning from a regime where solutions requiring low capital + high permission are attractive to one where high capital + low permission wins. To be successful as a power equipment vendor in the future, you must help your customers get permission FAST and avoid regulatory stupidity.

## Compute Shortage Necessitates Time to Power

H100 prices rose 33% in 2026 (an unprecedented massive compute shortage) — the opposite of the expected obsolescence-driven decline.

AI cloud revenue is ~$10–12M per megawatt per year, so a 100MW deployment delayed by a month costs ~$100M. Failing to consider time-to-power means your secured compute supply can't address the shortage and collect scarcity pricing.

# Ten Features of Bloom Boxes

Bloom Energy makes fuel cells — "Magic Energy Boxes." Natural gas in, magic, electricity out. Bloom's CCO frames them as a platform — like a phone where you can download many apps. Yes, $5k/kW capex (down to $3k after the investment tax credit), much more than aero or reciprocating. The author argues the ten features below way more than offset the upfront cost.

## 1. Native 800V Direct Current

Electricity moves through the grid in AC because AC is easy to step voltage up and down. But chips only use DC, so AC must be converted at the rack.

Today's racks: 480V AC enters the data center and converts to ~54V DC near the rack. Easy enough — cheap-ish transformers, modest heat losses.

But racks are getting power-hungry. P = I × V. Increasing current means thicker copper (not scalable), so we increase voltage instead — arriving at 800V DC for Rubin Kyber racks and onwards.

Going from 480V AC to 800V DC is hard — expensive transformers, lots of energy lost as heat. The ideal is to intake **native DC**. Bloom's fuel cells produce **800V DC natively**. No gas turbine does this; turbines all produce AC by physics. Bloom saves millions in transformer capex and heat-loss energy. Adapters are available if you don't need 800V DC yet.

## 2. Dynamic Load Following

Common misconception: "Bloom takes 12 hours to heat up to 850°C internal temperature, so it's inflexible base-load — can't be turned off."

Partially correct: slow to start/stop. **But once on, it can ramp from 20% to 100% output in seconds.** Dynamic load following.

Why this matters: training workloads have variable loads. Normally you'd build massive storage to smooth them. With Bloom, you just ramp up and down.

## 3. Supercapacitors

AI workloads have sub-second transients — thousands of GPUs simultaneously finish a compute step and wait for gradient exchange. Power draw drops by tens of MW in milliseconds, then spikes back. A 1GW cluster can swing 500MW in milliseconds, thousands of times per training run, faster than any combustion-based generator can respond.

Without something to absorb the shocks, gas turbines serving AI workloads would trip continuously. Standard fix: a **$500M battery bank bolted onto every gigawatt of turbine deployment**, sized solely to compensate.

Bloom uses **built-in supercapacitors** — store energy like static electricity rather than chemically (lithium-ion). Erase the entire battery bank. Capital efficiency and reliability win.

## 4. Modularity

Bloom boxes stack like Legos. 100 MW? 5 GW? Just scale.

This matters because of **over-provisioning** for "five nines" (99.999% uptime) reliability:
- Gas turbines: must over-provision **20–40%**.
- Bloom: only **0–8%**.

## 5. Absorption Chilling

Bloom fuel cells produce a high-quality steam byproduct. Data centers need cooling, which normally comes out of your energy budget. With this high-quality steam plus PV=nRT thermodynamics, you can use pressure to turn that steam into liquid, then boil it again to act as coolant.

## 6. Carbon Capture

Traditional gas turbines produce dirty waste: CO2, NOx, SOx, particulates. Bloom produces almost purely CO2 + water vapor — extremely pure exhaust. Carbon capture economics become dramatically more favorable.

In a future climate-focused regulatory regime where hyperscalers must be net zero, Bloom + cheap carbon capture becomes far more economical than any gas turbine. Underrated angle: this also makes Bloom a direct competitor in the **clean energy market** (solar, wind, hydro) — not all energy buyers need 5-9s reliability.

Hydrogen bonus: Bloom fuel cells are fuel-agnostic. The electrochemistry uses the hydrogens in CH4 anyway, so they support pure hydrogen with no redesign.

## 7. Quick Deployment

Behind-the-meter power is slow because of three things:
- **Manufacturing the widget** — slow.
- **Putting it onsite** — heavy turbines need foundations + switchgear.
- **Permitting/regulatory clearance** — slow.

Bloom solves all three:
- Capital-light, more assembly than metal-bending.
- Lighter than gas turbines, drops directly on-site.
- Clean → easy permitting.

Industry norm: 18 months purchase-to-deployment. Bloom claims 90 days; recent Oracle deployment hit **55 days**.

## 8. Low Latency Inference

Author isn't a big believer in low-latency inference, but includes it for completeness. Low-latency inference must sit near population centers; population centers don't tolerate noisy/polluting gas turbines. Bloom is clean, modular, stackable, low-NIMBY.

## 9. High Efficiency

Gas turbines: gas → heat → mechanical → electricity. Fuel cells skip the scenic route, converting natural gas directly to electricity via electrochemistry.

- **Bloom: 60–66%** — matches combined cycle (which is big, complex, slow to build).
- Reciprocating / aeroderivative: 35–45%.

## 10. Data Analytics

CEO K.R.: "We have a few trillion cell hours of field operation. More than 6 billion data points come from our field every single day. We are using AI to our benefit. We have a digital twin associated to every single fuel cell stack and data from the real field is feeding the digital twin and making our models better and better."

Tesla parallel: a professor missed Tesla in 2018 because he saw a car company; his son pointed out it was a data company. Bloom is the only player with a fuel-cell installed base. Digital twin = simulation of every deployed stack, predicting failures before they cause problems, optimizing service economics, improving stack life via fleet learning, accelerating manufacturing process optimization through field telemetry.

# The Unconstrained TAM

Most high-growth AI infrastructure companies grow because their market is growing fast.

**Bloom is different**: Bloom grows because its technology is actively displacing an already-massive market — the entire energy generation market. Each capability improvement unlocks new use cases and converts new marginal customers. Market growth is irrelevant; the market is already huge. **Theoretically, the TAM is unconstrained — the stock has no real ceiling.**

To capture that TAM, you need scalability + improving tech + dominant share. Bloom has all three.

## Infinite Scalability

Bloom isn't a manufacturing business; it's an **assembly business**. Like semi-caps — they have fabs, but the fabs assemble parts from a supplier chain rather than working raw materials. Their moat is IP. Capex ~3% of revenue, gigawatts of capacity built with tens to hundreds of millions of capex generating billions of revenue.

## Fuel Cells are a Technology

Gas turbines are an **industrial product** — centuries old, lived out the S-curve, slow to change.

Fuel cells are a **technology** — costs decline 10–20% per year. Their own Moore's-Law-like curve. Bottom of the S-curve, far from saturated. When you frame fuel cells as a technology, you stop asking *if* they'll be adopted and start asking *when*.

If costs keep falling, why limit Bloom to data centers? Why won't utilities buy them as the cheapest, most elegant power source? Why not power the world?

## Bloom is a Monopoly on Fuel Cells

Today nobody calls Bloom a monopoly. One day they will. Today it looks like one entrant in a crowded market. If Bloom's niche solution becomes the dominant one, fuel cells themselves become a market — and Bloom Energy has **100% market share in commercially deployed fuel cells**. Not a single other vendor is at volume.

Bloom has been making fuel cells since 2008 — a **20-year tech lead**. Legacy turbine OEMs may try to pivot but Bloom isn't worried. CCO Aman Joshi (EnergySense podcast, Feb 2026):

> "It's natural as Bloom succeeds that there will be other companies who'll try to get into the fuel cell business. Both myself and our chairman love competition because it only inspires us to become even better. Fuel cells have been around — the technology has been around for fifty years. GE in early 2000s had a fuel cell division. Siemens had a similar division. They've all tried, invested hundreds of millions of dollars, but weren't able to make it work and go beyond lab scale. Bloom's got roughly a twenty year technology lead. So we wish everyone all the best."

# Other Energy Solutions

There's a reason hyperscalers default to natural gas behind the meter. Address the hype:

## Solar & Storage

Seems realistic because it's scalable — unlike wind/hydro, solar isn't constrained by the Earth's resources.

Problem: data centers need 24/7 power. Storage only partially solves it. Utility-scale solar runs at **20–25% capacity factor**, so 1GW continuous baseload requires **4–5GW of nameplate capacity plus 12–16 hours of storage** for nighttime and **24–48 hours** for weather events. Compare: gas needs ~25% over-provisioning, Bloom barely any.

Biggest issue: solar still needs the grid for backup. The whole point of going behind the meter was to escape the grid. Solar forces us backwards. That's why it's rarely discussed for serious AI deployments.

## Non-Scalable Renewables

- **Hydro / geothermal** — Earth-resource limited. Most usable hydro is already tapped. Geothermal works only in narrow bands of the Earth's crust.
- **Wind** — same intermittency problem as solar but worse: needs more land and is less predictable than the sun (which at least rises and sets on schedule).

## SMRs & Datacenters in Space

Maybe one day. Today, SMR timelines are completely misaligned with AI's buildout window. **2026–2035** is the key period — not 2035+.

# Conclusion

(End of free-tier piece. Full Substack: <https://jasonschips.ai>.)
