---
created: 2026-05-13
published: 2026-04-30
description: Crux's read of the 2026-Q1 hyperscaler earnings batch — MSFT/GOOGL/META/AMZN collectively guiding to ~$700B+ of 2026 AI infrastructure capex, with the gating constraint being supply-side capacity (optics, networking, power) rather than customer demand.
source: https://cruxcapitalgroup.substack.com/p/ai-capex-boom-or-doom
type: framework
authors: ["Crux Capital Group (@cruxcapitalgroup)"]
---

## Key Takeaways

- **The 2026-Q1 hyperscaler print is unambiguously bullish for the photonics/networking buildout — ~$700B+ tracking capex across the big four, all framed as "demand exceeds supply".** [[Microsoft (MSFT)]] ~$190B 2026 capex with demand > supply, [[Alphabet (GOOGL)]] raised guide to $180-190B with 2027 expected to step up significantly, [[Meta Platforms (META)]] raised to $125-145B (from $115-135B), [[Amazon (AMZN)]] $43.2B Q1 cash capex on AWS+GenAI. The "supply constrained" framing is the same language [[Lumentum (LITE)]], [[Applied Optoelectronics (AAOI)]], and [[Corning (GLW)]] have been using on their calls — top-down hyperscaler language now matches bottom-up supplier language.
- **Backlog/contract growth — not raw guide $$ — is the load-bearing signal that this is funded buildout, not vibes.** MSFT RPO $627B incl. OpenAI; GOOG cloud backlog "nearly doubled sequentially" to $462B; META multi-year cloud + infra agreements drove a $107B step-up in contractual commitments in the quarter. Customers are committing capital before the capacity exists — that asymmetric pre-commitment is what protects the optics suppliers if a near-term digestion period hits.
- **AWS's "6-to-24 month build-ahead" frames the photonics opportunity window.** AWS has to spend on land, power, buildings, chips, servers, and networking gear 6-24 months before billing — meaning suppliers benefit before cloud revenue shows up in the print. This is the explicit timing-arb argument for owning the picks-and-shovels names ahead of cloud-revenue acceleration.
- **Inference is now the steady-state workload, not training.** Every search answer, copilot, agent, recommendation, video gen, ad optimization creates an always-on compute pull that doesn't switch off between training runs. AMZN explicitly called out agentic workloads, real-time reasoning, code gen, RL, and multi-step orchestration as "driving massive CPU demand" — confirming inference pulls heavily on CPUs as well as accelerators. META framed it as "building inference capacity to serve agents to *billions* of people."
- **Custom silicon is broadening, not narrowing, the supplier set.** AMZN Trainium/Graviton, GOOG TPU/Axion, MSFT Maia/Cobalt, META custom silicon with [[Broadcom (AVGO)]]. The takeaway is NOT that NVDA loses — it's that AI demand is large enough that hyperscalers need every viable compute option, so the supply chain (and meaningful-exposure name list) is expanding rather than concentrating.
- **The bottleneck migrates to network and validation as gigawatts get added.** Crux's read-through: every additional GW of compute → networking problem → optics/fiber/coherent transport/photonic integration. And the faster the network moves (800G→1.6T→3.2T), the more validation is required — name-checks [[Viavi (VIAV)]] as the proof layer that converts capex into working AI capacity.
- **Risks called out but framed as second-order:** (a) lower-end optics can face digestion even while high-end stays tight; (b) hyperscaler custom silicon shifts economics across the supplier base; (c) capex committed long before supplier revenue appears (cash-out / revenue-in mismatch); (d) data centers can be delayed by power/permitting/construction; (e) memory-cost-driven capex re-rates can pressure cloud margin/FCF; (f) "stocks can move before revenue arrives" — even the right thesis is a bad entry if priced in too far.

## Capex stack — where the $700B+ is going (Crux taxonomy)

| Layer | Recipients of the spend | Supplier example called out |
|---|---|---|
| Compute & custom silicon | NVDA accelerators + hyperscaler ASICs (Trainium/Graviton, TPU/Axion, Maia/Cobalt, META+Broadcom) | [[Broadcom (AVGO)]] |
| Memory & components | DRAM, HBM, NAND — META explicitly pointed to "higher memory pricing" as a CAPEX driver | — |
| Power & data centers | Land, buildings, power, substations, transformers, switchgear, cooling, grid | — |
| Networking, optics, fiber | High-speed optics, coherent transport, switching, fiber density, optical components, photonic integration | [[Corning (GLW)]] (multi-year multi-billion deals with ≥2 additional hyperscalers) |
| Test, validation, monitoring | 800G/1.6T/future 3.2T link cert, monitoring, deployment risk reduction | [[Viavi (VIAV)]] |
| Manufacturing & deployment scale | Server, switch, optical-module, power-system, rack, network-gear assembly + integration | Sanmina |

## Original Content

> [!quote]- Source Material
> Crux Capital Group (@cruxcapitalgroup) — 2026-04-30 — free Substack post
>
> # AI CAPEX - Boom or Doom?
> ### We got lots of signals
>
> I want to share what I took away from yesterday's hyerpscaler earnings because I think the signal is massive. I didn't have a chance to listen to them live and write notes (I was too busy on the Viavi call) so I plugged them all into NotebookLM and gathered all the signal for the capex angle.
>
> Microsoft, Alphabet, Meta, and Amazon all basically said the same thing in slightly different ways. AI demand is running ahead of capacity. Infrastructure is constrained. The physical buildout has years left. And they are all spending more, not less, because they cannot build fast enough to keep up with what customers are asking for.
>
> This is exactly what we were wanting to hear! And we got it.
>
> Also, we recently had Corning (GLW) tell us that they have at least 2 new additional hyperscalers with multi-billion dollar, long term deals. Then we have VIAVI yesterday telling us about massive demand and widespread customer bases. I think so far the picture is really strong for our sector.
>
> ---
>
> ## The Numbers Are Staggering
>
> Microsoft expects roughly **$190 billion** of calendar 2026 capex and said **demand** continues to **exceed** available **supply**. Alphabet raised its 2026 capex guide to **$180 to $190** billion and said 2027 **capex** should **increase** significantly from 2026. Meta raised 2026 capex guidance to **$125 to $145** billion, up from the prior range of $115 to $135 billion. Amazon reported **$43.2** billion of Q1 cash capex tied primarily to AWS and generative AI.
>
> Using Microsoft, Alphabet, and Meta's 2026 guides, plus Amazon's Q1 cash capex run-rate, the four largest hyperscaler AI infrastructure spenders are tracking toward roughly **$700 billion-plus** of guidance and run-rate capex.
>
> That is a massive number. And it flows all the way down stream.
>
> Physical demand. Capacity demand. Power demand. Networking demand.
>
> ---
>
> ## The Language Was Consistent
>
> Microsoft is adding capacity as fast as it can and still seeing demand exceed supply. Sounds like all of the last earnings calls we got from companies like Lumentum, Applied Opto etc.
>
> Alphabet is raising capex because AI compute demand is coming from both internal products and external Google Cloud customers, with backlog nearly doubling sequentially to $462 billion.
>
> Meta is increasing infrastructure spend because compute is becoming more central across recommendations, ads, agents, AI glasses, and future products.
>
> Amazon is spending heavily because AWS growth is accelerating and generative AI demand is pulling more infrastructure spend forward, with customer commitments for a substantial portion of 2026 AWS capex already in place.
>
> Microsoft's remaining performance obligation (RPO) increased to $627 billion including OpenAI.
>
> Meta's multi-year cloud deals and infrastructure purchase agreements drove a $107 billion step-up in contractual commitments during the quarter.
>
> The backlog and customer commitment language tells us the spending is tied to real demand. This is a funded buildout, with customers committing capital before the capacity exists.
>
> ---
>
> ## Widespread Spend
>
> AWS has to spend on land, power, buildings, chips, servers, and networking gear six to 24 months before it can bill a customer for that capacity. That is a direct investment implication where suppliers can benefit from the buildout well before cloud revenue fully shows up.
>
> Microsoft talked about optimizing every layer of the stack from data center design to silicon, systems software, model architecture, and fleet efficiency. It added another gigawatt of capacity during the quarter and is on track to double its footprint in two years.
>
> This is also why free cash flow can look pressured during the build phase even if the underlying investment is rational. The cash goes out before the revenue arrives. Data centers have very long useful lives while chips, servers, and networking gear have shorter ones, which means the upfront capex burden is real but the monetization window is extended.
>
> ---
>
> ## Inference
>
> Inference is a hot topic over the last few months and many investors are trying to position themselves accordingly. We got some nice bits from these companies to support this idea.
>
> Every search answer, enterprise copilot, coding assistant, business agent, recommendation model, customer service workflow, video generation request, and ad optimization loop creates a recurring pull on compute. That is an always-on demand pattern. It does not turn off between model training runs.
>
> Amazon's CPU commentary stood out to me specifically. The company said agentic workloads, real-time reasoning, code generation, reinforcement learning, and multi-step task orchestration are driving massive CPU demand. As AI systems shift from answering questions to taking actions, the workload pulls heavily on CPUs as well as accelerators.
>
> Because this always-on inference demand is so heavy, managing the cost of it is becoming a primary focus. Amazon expects its custom Trainium chips to save 'tens of billions' in CapEx annually just on inference. We are also seeing massive software optimization, like Meta's 'adaptive ranking model' that only deploys heavy inference compute when an ad is highly likely to convert. Ultimately, the infrastructure must be built to support incredible scale with Meta explicitly stated they are building the inference capacity required to serve agents to *billions* of people globally. That's huge!
>
> ---
>
> ## Every Extra Gigawatt Becomes A Networking Problem
>
> This is the read-throug for the names I follow.
>
> When Microsoft adds another gigawatt of capacity, that capacity has to be connected. When Google Cloud backlog nearly doubles, that demand has to move through physical infrastructure. When Meta builds inference capacity for agents serving billions of people, that demand has to move through data centers, servers, switches, optics, and fiber. When Amazon says AWS capex is being spent on chips, servers, and networking gear six to 24 months before billing starts, that is a direct read-through to the companies that help convert capex into usable AI capacity.
>
> More compute creates more network traffic. Inside clusters, accelerators need to move data across racks and systems. Between facilities, AI workloads need data-center interconnect. Across regions, hyperscalers need scale-across architecture to move workloads and balance capacity.
>
> The AI buildout can only scale if the network scales with it. That is why I remain focused on optics and network.
>
> ---
>
> ## What The Capex Cycle Is Funding
>
> Working through each layer of the stack:
>
> **Compute and custom silicon.** Hyperscalers are still buying enormous accelerator capacity, but they are also building their own silicon. Amazon has Trainium and Graviton. Google has TPUs and Axion. Microsoft has Maia and Cobalt. Meta is rolling out custom silicon with Broadcom. AI demand is large enough that hyperscalers need every viable compute option available. The supply chain is getting more complex and the number of companies with meaningful exposure is expanding.
>
> **Memory and components.** Meta specifically pointed to higher memory pricing as a major driver of its higher capex outlook. When hyperscalers raise capex because component costs are moving higher, it tells you demand is strong enough to absorb pricing pressure. That can create margin pressure for the hyperscalers while supporting suppliers tied to constrained components.
>
> **Power and data centers.** The companies are spending on land, buildings, power, and long-lived infrastructure before capacity can be monetized. Power availability, permitting, construction speed, cooling, substations, transformers, switchgear, backup power, and grid infrastructure are all part of the investment story. The more AI capacity gets built, the more important this layer becomes.
>
> **Networking, optics, and fiber.** AI clusters need more bandwidth. Inference needs reliable and scalable connectivity. Data centers need denser fiber. The network becomes a strategic bottleneck as compute scales. High-speed optics, coherent transport, switching, fiber density, optical components, and photonic integration all sit in this layer. This is where the AI capex cycle flows directly into the photonics thesis. We saw this with Corning on Monday.
>
> **Test, validation, and monitoring.** The faster the network moves, the more validation is required. 800G, 1.6T, and future 3.2T systems have tighter tolerances, higher complexity, and greater deployment risk. Hyperscaler capex has to be converted into working AI capacity, which means links, modules, switches, fiber, and systems have to be tested, certified, monitored, and optimized. This is the network proof layer, and it becomes more valuable as the infrastructure gets faster and denser. We saw this with VIAVI yesterday.
>
> **Manufacturing and deployment scale.** The physical products still have to be assembled, tested, shipped, integrated, and supported. Servers, switches, optical modules, power systems, racks, and network equipment all require manufacturing capacity and operational execution. The winners here include suppliers that help hyperscalers convert capex dollars into deployed capacity. We saw this with Sanmina on Tuesday.
>
> ---
>
> ## What Could Go Wrong
>
> A few things we should still keep in mind.
>
> AI demand can be real while certain products still go through digestion periods. Lower-end optics can face pressure while higher-end components remain tight. Hyperscalers are designing more of their own silicon, which shifts economics away from some suppliers and toward others. Capex can be committed long before supplier revenue appears, and data centers can be delayed by power, permitting, construction, or equipment lead times. Higher component costs can pressure cloud margins and free cash flow. And stocks can move before revenue fully arrives, which means the best thesis can still become a poor entry if the market prices in too much upfront.
>
> The top-down signal is bullish for the infrastructure buildout though. I think that is becoming more and more evident.
>
> ---
>
> *Disclosure: I own positions in several companies connected to the AI infrastructure and photonics supply chain. This is research and commentary only. Please do your own diligence. This is not a recommendation to purchase any shares. Nor is this financial advice.*
