---
created: 2026-05-14
published: 2026-04-21
description: Long-form thesis arguing OUST's digital-lidar architecture creates a Moore's-law-style cost curve, with Hesai's IP license + Stereolabs acquisition ($35.4M cash + 1.85M shares, closed Feb 4 2026) validating the platform extension into broader Physical AI sensing.
source: https://x.com/snmart/status/2046545856917098836
type: thesis
authors: ["Nicolas (@snmart)"]
---

# @snmart OUST thesis Apr 2026 — digital-lidar architecture rides chip cost curve, Hesai licenses IP, Stereolabs acquisition extends into cameras + edge AI compute (Physical AI platform)

## Key takeaways

- **Architecture-as-moat claim**: [[Ouster (OUST)]] integrates lasers + detectors + signal processing into silicon (L3 current, L4 in validation, Chronos next for flash lidar), arguing each chip generation improves range/resolution/reliability on a Moore's-law-style cost curve instead of via more discrete components. [[Hesai (HSAI)]] — world's largest lidar manufacturer by volume — chose to *license* OUST's digital-lidar IP rather than design around it, the author's strongest commercial-value tell.

- **2025 reported revenue is noisy; the comparable baseline is ~$162M, not $169M**: $22.8M of 2025 royalty revenue included $16.1M of *deferred* royalty (recognized only when uncertainty around the license contract resolved). Management explicitly guided 2026 royalties to <$5M (mostly back-half). For 2026 framework math, anchor to $146M core product revenue + ~$16M Stereolabs pro-forma = ~$162M baseline → 30-50% framework implies **$211M-$243M 2026 revenue range**.

- **Software-attach is the compounding lever, not a hardware story**: Software-attached bookings >2x in 2025, software now attached to >15% of sensors shipped (Ouster shipped 25,000+ sensors in 2025), Gemini/BlueCity AI models running at 1,200+ sites. Gemini is "optimized exclusively for Ouster's digital lidar sensors" per 10-K — every deployment increases switching costs. Ouster does not yet break out software revenue separately.

- **Stereolabs deal terms and strategic logic**: Closed Feb 4 2026 for **$35.4M cash + 1.85M newly issued shares**. Adds (1) cameras as a second sensor modality enabling sensor-fusion sales neither side could make alone, (2) Stereolabs' existing developer community (thousands of devs on ZED cameras), (3) edge AI compute hardware (likely Jetson-based), (4) narrative coherence — "unified sensing and perception platform for Physical AI" vs "lidar sensors with some software." Stereolabs did ~$16M revenue 2025, ~60% back-half weighted.

- **Q1 2026 guide implies mid-30s % growth in core lidar business**: Q1 revenue guide $45M-$48M *includes* ~7 weeks of Stereolabs (~$1.5M-$2M contribution), so core Ouster Q1 ≈ $43M-$46M vs $41M product revenue in Q4 2025. Balance sheet: $211.2M cash/equivalents/short-term investments at YE 2025, no debt; management says ~4-5 years runway to operating cash flow positivity *after* Stereolabs.

- **Author's caution flags**: Pacala was deliberately *cautious* on defense and humanoids as 2026 revenue drivers (medium-term opportunity). DF series (automotive ADAS / Chronos chip) is still prototype-stage, not commercial. Confidence concentrated in smart infrastructure (BlueCity in TN/UT/NJ, Europe + Middle East pilots planned), industrial automation, and the post-Stereolabs lidar+cameras+compute platform.

- **Manufacturing**: majority of products built through **Benchmark and Fabrinet in Thailand** — credibility-at-scale claim, but author flags this is table stakes, not a deep moat.

- **Note**: The X Article body is a free preview; the full piece (including Financials, Valuation via multiples/reverse-DCF/peers, Risks, Catalysts & Timeline, Conclusion) is on Substack ([link](https://open.substack.com/pub/snmart/p/ouster-oust-why-this-is-no-longer)).

## Original Content

*Cover image — Ouster sensor with robotics scene (warehouse robot arm, AMR with packages, drone) signaling multi-vertical Physical AI framing*
![[snmart-098836-001.jpg]]

**Article: Ouster ($OUST): Why This Is No Longer Just a Lidar Bet**

Ouster is getting a lot more attention lately. But with that attention has come a lot of noise, bad takes, and lazy interpretations of both the filings and management commentary. That is why I decided to write this piece.

The goal here is simple: separate the noise from what the company is actually saying.

In this article, I will break down why $OUST is no longer just a lidar company, why the latest results need to be normalized, where the business is heading, and what the filings really tell us about its customers, competitors, catalysts, valuation, and overall setup.

If you have only followed the headlines, you are probably missing the real story.

**Table of Contents**

1. The Business

2. Competitors

3. Guidance

4. Moat

5. The Financials

6. Valuation (Multiples, reverse DFC and peer comparison)

7. Risks

8. Catalysts & Timeline

9. Conclusion

*Q4 2025 results & 2026 outlook summary card — Revenue $62M (+107% YoY), Product revenue $41M (+36% YoY), 8,100+ sensors shipped (record quarter), GAAP gross margin 60% (vs 44% Q4 2024). Quarter included ~$21M of royalties, mostly one-time. 2026 outlook: Q1 revenue $45M-$48M; long-term framework reiterated 30%-50% annual revenue growth, 35%-40% GAAP gross margin, GAAP opex growth 5%-8% in 2026*
![[snmart-098836-002.jpg]]

## 1. The Business

Ouster designs and sells digital lidar sensors, perception software, stereo cameras and edge AI compute through the Stereolabs acquisition. The company positions itself as "Physical AI's first unified sensing and perception platform."

Translated from marketing, that means: Ouster wants to be the one-stop-shop for the sensor stack and low-level perception software that runs on autonomous machines in four verticals.

To understand what Ouster does, you have to understand what makes "digital lidar" different from what most of the industry still builds. Every lidar sensor does essentially the same job: emit light pulses, measure how long they take to bounce back off objects, and convert those time-of-flight measurements into a 3D point cloud the machine can use to perceive its surroundings. The differences are in how the emitting and detecting hardware is built.

Traditional analog lidar is built from many separate components, so improving resolution usually means adding more parts, more complexity, and more cost.

Ouster's approach is different.

Instead of improving the sensor by adding more separate hardware, Ouster tries to improve it by putting more of the system into the chip itself. The lasers, the detectors, and part of the signal processing are more tightly integrated into silicon. The idea is simple: rather than making the product better by adding more pieces, Ouster wants to make it better by building a better chip.

That matters because each chip generation can improve range, resolution, and reliability without requiring a completely new architecture. L3 is the current generation, L4 is now in validation, and Chronos is the next step for flash lidar. So the real advantage is not just better sensors today. It is the possibility of improving performance over time on a more efficient cost curve.

*Ouster product stack diagram — L4 chip (top), ZED Stereo Cameras (Stereolabs), BlueCity (traffic/infrastructure), DF Series (solid-state flash lidar, automotive) all overlaid on a city street scene*
![[snmart-098836-003.jpg]]

That distinction matters because, if Ouster is right, the advantage is not just a better product today. It is a better architecture that can keep improving with each chip cycle. And if the advantage really sits at the architecture level, then the IP should matter too.

*"Ouster Silicon — Riding the Wave of Moore's Law" chip-generation progression chart: L1 → L2 → L2X → L3 (current) → L4 (in development); performance axis = range × points per second; OS line powered by L4, DF line powered by Chronos*
![[snmart-098836-004.jpg]]

That is where the Hesai example becomes important. [[Hesai (HSAI)]] is one of the biggest lidar manufacturers in the world by volume, especially in automotive. Instead of designing around Ouster's digital lidar patents, it chose to license the technology. That does not prove Ouster's advantage will last forever, but it does suggest the architecture has real commercial value

The new piece is Stereolabs. Ouster closed that acquisition on February 4, 2026 for $35.4 million in cash plus 1.85 million newly issued shares. Management says Stereolabs is a high-growth, high-margin business that should be accretive to consolidated results and expands Ouster into camera vision, AI compute, sensor fusion, and foundational AI model training.

## Product lines

Ouster does not sell just one product. It has several product lines, and each one plays a different role in the business.

OS product line (the core business): Four models, all built on the same digital architecture but with different optical configurations for different use cases.

- OSDome: for indoor or ceiling-mounted applications, like buildings and infrastructure

- OS0: short range, useful for robots, warehouses, and small autonomous vehicles

- OS1: the most versatile model, used across many industrial applications

- OS2: long range, for mining, highways, and long-distance mapping

DF series. This is Ouster's automotive product for ADAS and autonomous driving. It is the part of the story that sounds exciting because investors always like large automotive opportunities. But the reality is that it is still early. The product is not yet a meaningful commercial business. Ouster has prototypes, and the Chronos chip is still being tested. So for now, DF is best understood as future upside, not as something driving results today.

The software layer, which is where the re-rating story really starts:

This is the part of the business that makes Ouster more interesting than a pure hardware company.

Gemini is Ouster's perception software for smart infrastructure. It handles tasks like detection, classification, tracking, and monitoring. That matters because customers are not really paying for raw point clouds. They are paying for outcomes. They want to know what is moving, where it is moving, and whether something needs attention. Gemini helps turn Ouster's hardware into a usable system rather than just a sensor.

It matters for another reason too. Gemini is built specifically for Ouster lidar. So every Gemini deployment makes the customer more tied to Ouster hardware. That is what makes the software layer strategically important. It adds value, but it also makes the relationship stickier.

Then there is BlueCity, which is basically Gemini adapted for traffic operations and road safety. It is the same broader idea, but focused on a very specific use case. Think intersections, traffic flow, pedestrian safety, signal timing, and near-miss detection. Management has already talked about deployments in Tennessee, Utah, and New Jersey, with additional pilots planned for Europe and the Middle East in 2026. BlueCity is important because it shows how Ouster can package the same underlying technology into a clearer, more valuable end-market solution.

*Physical AI Solutions — Cutting-Edge AI Models (proprietary models leveraging real-world data to iterate, retrain, improve); Ouster Gemini (perception platform for security, crowd analytics, logistics, ITS — detects, classifies, tracks people and objects); Ouster BlueCity (turnkey real-time traffic management with advanced cloud-based analytics)*
![[snmart-098836-005.jpg]]

The platform extension through Stereolabs

The February 2026 Stereolabs acquisition adds something Ouster simply did not have before.

With ZED cameras and AI Compute, Ouster now has a first-party camera and compute offering alongside lidar. That means stereo vision, neural depth perception, and edge inference hardware all become part of the portfolio. Before this deal, Ouster could talk about perception. After the deal, it can offer more of the perception stack directly.

That is a meaningful shift. Cameras are a core sensor in many robotics and physical AI applications, and compute is what makes sensor fusion useful in the real world. So Stereolabs does more than just add another product line. It broadens what Ouster can actually sell to customers.

*Post-acquisition product portfolio photo — next-generation digital lidar sensors, next-generation ZED stereo cameras + AI compute (Jetson-style enclosure), all unified with plug-and-play sensor fusion*
![[snmart-098836-006.jpg]]

In addition, the TAM for lidar and the broader sensing and perception market is enormous, especially now that Ouster is no longer just a lidar company:

*Diversified Strategy to Capture Multi-Billion Market Opportunity — four end-markets:*
*— Robotics: Last-mile delivery robots, humanoids, robotic arms & manipulators; drones, mapping, inspection, military and defense*
*— Industrial: Warehouse automation, inspection, and global supply chain; off-road vehicles for mining, construction, and agriculture; millions of forklifts, tractors, and earth movers manufactured each year*
*— Smart Infrastructure: Perimeter security, crowd analytics, logistics, volumetric detection; Intelligent Transportation Systems (ITS), signal actuation, urban planning*
*— Automotive: L2+, L3, L4 passenger & commercial ADAS; L5 autonomous vehicles (AVs), robotrucking, and robotaxis*
![[snmart-098836-007.jpg]]

## What Stereolabs actually changes for Ouster:

1. Adds the second major sensor modality (cameras) to complement lidar, enabling sensor-fusion-based solutions that neither company could sell alone. Multi-sensor AI training (lidar + cameras fused) is a technical lever Pacala flagged as "the obvious next step" on the Q4 call.

2. Brings a ready developer community. Stereolabs has had a developer-first distribution model since founding, thousands of software developers are actively using ZED cameras in production systems. Ouster couldn't build this organically.

3. Adds edge AI compute hardware. The Stereolabs AI Compute platform (likely Jetson-based) extends Ouster's offering from sensors-only to sensor-and-compute, which matters because customers increasingly want integrated solutions.

4. Creates narrative coherence. "Unified sensing and perception platform for Physical AI" is a stronger marketing position than "lidar sensors with some software." The narrative coherence matters for multiple expansion even if underlying unit economics evolve more slowly.

[Image — Ouster IR slide quote; transcribed verbatim below]

> Looking to 2026, our Stereolabs acquisition positions Ouster as a world-leading sensing and perception company for Physical AI. Our roadmap is built on strategic priorities designed to compound our combined competitive advantages and drive us to profitability.

## If Ouster is a lidar company, why did it buy Stereolabs?

Lidar is very good at measuring distance, shape, and position in 3D, especially in low light or difficult conditions. Cameras add something different: color, texture, and visual context. In simple terms, lidar tells you where something is and what shape it has. Cameras help you understand what it is.

That is why the strategy makes sense. Ouster did not buy Stereolabs because lidar is not enough. It bought Stereolabs to move up the stack. Instead of selling only a lidar sensor, Ouster now wants to sell lidar, cameras, compute, software, and sensor fusion as one integrated perception system.

The customer benefit is simple: less integration work. Many customers do not want to buy lidar from one company, cameras from another, compute from another, and then spend months putting everything together. Ouster wants to make that easier by offering more of the stack itself.

Strategically, this helps most in markets like industrial robotics, automation, humanoids, visual inspection, and smart infrastructure, where using multiple sensors together is often better than relying on just one.

So the real goal is not to replace lidar with cameras. The goal is to make Ouster more than a lidar company. Lidar is still the core, but cameras and compute let Ouster sell more per customer, make the product harder to replace, and strengthen the shift from sensor vendor to platform supplier.

## How the business makes money

This is where the deep dive has to be careful, because Ouster reports revenue in a way that obscures the real operating picture. I'll break out the actual decomposition.

[Image — 2025 revenue decomposition table; transcribed below]

| Component | Amount ($M) | % of total | Quality / nature |
|---|---|---|---|
| Product revenue (sensors + solutions) | 146.6 | 87% | Core ongoing business |
| Royalty revenue (IP licensing) | 22.8 | 13% | Mostly one-time (Hesai settlement) |
| Services revenue | immaterial | <1% | Warranty extensions, custom development |
| **Total** | **169.4** | **100%** |  |

Royalty revenue was unusually high because Ouster was finally allowed to recognize revenue that had been sitting on the balance sheet from earlier periods. The 10-K says Ouster recognized $22.8 million of royalty revenue in 2025, and $16.1 million of that was old deferred royalty revenue that could only be recognized once the uncertainty around the license contract was resolved. Then on the earnings call, Ken Gianella said 2026 royalty revenue should be less than $5 million.

Ouster does not break out product revenue into "hardware revenue" and "Gemini/BlueCity software revenue" in the 10-K. So we cannot know the exact software revenue number from the financial statements alone. What we do know from the call is that software-attached bookings more than doubled in 2025 and represented over 15% of sensors shipped. Ouster also shipped 25,000+ sensors in 2025.

So the rough interpretation is:

- software is clearly growing

- more customers are buying software together with the sensor

- but software is still not large enough for Ouster to report it as a separate revenue line

## The business flow:

*Ouster Business Model "How Money Flows" diagram — four revenue streams: (1) Hardware Sales (lidar sensors, customers buy OS-series; manufactured by Benchmark or Fabrinet in Thailand; ASP $2,500-$15,000+, blended average ~$4,400; ~87% of 2025 mix), (2) Software Subscriptions (Gemini / BlueCity; enterprise Gemini $1M+/year, single BlueCity intersection a few thousand $/year; recurring, higher margin, customer stickiness; ~5-10% growing fast), (3) IP Licensing / Royalties (other companies license Ouster/Velodyne patents; main source Hesai; 2025 $22.8M including $16.1M catch-up, 2026 ~<$5M expected; <3% small declining), (4) Services (warranty extensions, custom development; <1% non-strategic). Direction: from a sensor company to a complete sensing & perception platform with recurring software at the core*
![[snmart-098836-010.jpg]]

1) Hardware sales. Customers buy lidar sensors, and Ouster records that revenue when the unit ships. This is still the main business today.

2) Software through Gemini and BlueCity. Customers buy the hardware, but they can also pay for software licenses on top. This part matters because software is recurring, higher margin, and makes customers more tied to Ouster's system.

3) Royalties. This comes from other companies licensing Ouster or legacy Velodyne technology. It helped revenue in 2025, but management has already said this should be a much smaller line in 2026.

4) Services, like support or custom work. This is a very small part of the business and not strategically important.

So the simple picture is:

> The software is what turns lidar data into something useful. On its own, the sensor just produces a 3D point cloud. That is raw data. Most customers do not want raw data. They want answers. They want to know if a person entered a restricted area, if traffic is backing up at an intersection, or if two objects almost collided.

That is what Ouster's software does. Products like Gemini and BlueCity take the lidar data, detect what is happening, classify objects, track movement, and turn all of that into alerts, analytics, and real-world actions.

The big shift is that Ouster no longer wants to be just a sensor company. It wants hardware to bring customers in, and software to make the business more recurring and more valuable over time.

## 2. Competitors

Before getting into the explicit moat analysis, it's worth mapping where Ouster sits in the broader lidar/sensing industry. The competitive field has been reshuffled significantly over the past 18 months.

- [[Innoviz Technologies (INVZ)]]: $55M revenue 2025, auto-focused, recent Daimler Truck L4 win, struggling balance sheet.

- [[Aeva Technologies (AEVA)]]: $18M revenue FY25 ($30 FY26 est), newly announced Nvidia partnership, FMCW technology approach (different from Ouster).

- [[MicroVision (MVIS)]]: Sub-scale, recently bought Luminar's assets, remains in transition.

- [[AEye (LIDR)]]: Very small scale, structurally marginal.

The private and Chinese:

- [[Hesai (HSAI)]]: By volume the world's largest lidar company, public on NASDAQ (HSAI). Approximately $350M revenue 2025. Now confirmed Ouster IP licensee.

- RoboSense, Seyond: Large Chinese players.

- [[Koito Manufacturing (7276.T)]]: Japanese Tier 1 with lidar business.

Ouster's position in this field is unique: it has real scale (25,000+ sensors/year, top 3-5 by US-based public company volume), a legitimate balance sheet, a broad multi-vertical product portfolio (most competitors are 1-2 verticals), and now with Stereolabs a multi-modal sensing offering. Not the largest by volume (Hesai dominates that), but arguably the highest-quality public pure-play left standing.

## 3. GUIDANCE

The Q4 call gave a much clearer picture of 2026 than the headline numbers suggest.

Ouster guided Q1 2026 revenue to $45 million to $48 million, and that already includes about seven weeks of Stereolabs revenue after the February 4 close. Since Stereolabs did about $16 million of revenue in 2025 and management said roughly 60% of that business is weighted to the second half, the Q1 contribution from Stereolabs is probably only around $1.5 million to $2 million. That implies the core Ouster business is guiding to roughly $43 million to $46 million of Q1 revenue, compared with $41 million of product revenue in Q4 2025.

In other words, the underlying lidar business still looks like it is growing at roughly a mid-30s rate, which is consistent with what Gianella later suggested on the call.

Management also reiterated its broader 2026 framework. The company is still targeting 30% to 50% annual revenue growth and 35% to 40% GAAP gross margin, but importantly, that framework is being measured against a 2025 pro forma baseline excluding royalties. Using Ouster's $146 million of core product revenue plus roughly $16 million from Stereolabs, the relevant starting point is about $162 million, which implies a 2026 revenue range of roughly $211 million to $243 million. That is the number investors should anchor to, not the inflated reported 2025 revenue that included one-time royalty catch-up.

That normalization matters because management was very explicit that 2026 royalties should be less than $5 million, with most of that landing in the second half. So one of the biggest differences between 2025 and 2026 is that the royalty line should shrink sharply. At the same time, GAAP operating expenses are expected to grow 5% to 8% in 2026, slightly above the original long-term framework because of Stereolabs integration costs. Management also disclosed something important on liquidity: even after the acquisition, Ouster believes it still has roughly four to five years of runway until it reaches operating cash flow breakeven.

## What the call really tells us

The simplest way to read the call is this: the core lidar business still looks healthy, Stereolabs adds growth on top, but reported 2026 numbers will look noisier because the royalty benefit largely disappears and because Stereolabs is seasonally back-half weighted, which means Q1 and Q2 may look softer than the full-year story.

The most useful signal from management was not the formal framework, but the tone around the underlying business. Gianella effectively pointed investors toward mid-30s growth in the core product line, while Pacala kept reinforcing that the bigger story is no longer just lidar units. Software-attached bookings more than doubled in 2025, software was attached to more than 15% of sensors shipped, and management said customers are already asking to buy the full hardware and software stack from one supplier. That is the strategic message underneath the numbers.

The other important part of the call was what management did not hype. Pacala was fairly cautious on defense and humanoids, suggesting both are still more of a medium-term opportunity than a 2026 revenue driver. By contrast, management sounded much more confident on smart infrastructure, industrial automation, and the combined lidar plus cameras plus compute platform after Stereolabs.

So if you strip the call down to its essentials, the message was simple:

Normalize out the royalties, assume the core business is still growing around the mid-30s, expect Stereolabs to help more in the back half, and recognize that the platform story is becoming more important than the pure hardware story.

## 4. MOAT

The Business section above covers what Ouster is and the competitive landscape it sits in. This section asks the harder question: how durable is the competitive advantage, and which specific sources of moat will compound versus erode over the next 5-10 years?

The long-term bull case depends far more on software and integration than on hardware alone.

1) Underlying technology and IP. Management clearly sees the digital lidar architecture and custom silicon roadmap as core differentiators. But patents mainly protect against direct copying. They do not stop competitors from reaching the same market through different technical approaches. So the IP is valuable, but it is not a permanent shield.

2) Manufacturing and scale. Ouster believes its digital design helps on cost, yields, and production efficiency, and the company already manufactures the majority of its products through Benchmark and [[Fabrinet (FN)]] in Thailand. That matters because customers buying into multi-year programs want proof that the product can actually be built and delivered at scale.

Still, this is better understood as table stakes than as a deep moat. Manufacturing credibility matters, but it is not the part of the business that should command a premium multiple on its own.

3) The real MOAT: Software. Gemini is not just an add-on. The 10-K says it is optimized exclusively for Ouster's digital lidar sensors, which means every Gemini deployment strengthens the bond between the customer and Ouster hardware. BlueCity extends that idea into traffic and road safety, turning the same underlying technology into a more specialized solution. And the company is already seeing real traction here: software-attached bookings more than doubled in 2025, software was attached to more than 15% of sensors shipped, and Ouster's AI models are now running at more than 1,200 Gemini and BlueCity sites.

This is the closest thing Ouster has to a compounding moat, because it creates switching costs, improves the product with more real-world data, and adds recurring revenue on top of hardware.

That is also why Stereolabs matters strategically. Ouster is no longer trying to sell only a lidar sensor. Management is now clearly presenting the company as a unified sensing and perception platform that combines lidar, cameras, AI compute, sensor fusion, and perception software. The more of that stack Ouster can sell, the more valuable the customer relationship becomes. A company that sells one sensor can be replaced. A company that sells the sensor, the software, the camera layer, and the compute layer is much harder to dislodge.

4) The balance sheet, which in a sector like this does function as an advantage. At year-end, Ouster had $211.2 million of cash, cash equivalents, restricted cash, and short-term investments, with no debt outstanding. Management went further on the call and said the company still has roughly four to five years of runway to operating cash flow positivity even after the Stereolabs acquisition. The balance sheet is not a classic moat in the way software can be, but it is still a real commercial asset today.

So the clean conclusion is this: Ouster's moat is not primarily about having the best sensor forever. The stronger version of the thesis is that the company is using hardware as the entry point, software as the lock-in layer, and platform integration as the long-term value driver. The IP helps. Manufacturing helps. The cash balance helps.

But the part that can truly compound over time is the software and perception stack. If that keeps scaling, Ouster can become harder to replace and more valuable than a pure hardware vendor. If it does not, then the company risks remaining a solid but ultimately more replaceable sensor supplier.

Ouster's real moat is not the sensor by itself. It is the combination of software, integration, and balance-sheet credibility built around that sensor.

Once you understand the business, the guidance, and the moat, the story starts to sound compelling. The next question is the only one that matters: what is all of that actually worth?

The business is interesting. The moat is real. The guidance is better than the headlines suggest. Now comes the part that separates narrative from investment: the financials, the valuation, and the risk-reward at today's price.

By this point, the story should be clear. What is not obvious, and what really matters, is whether the market is still mispricing it. That is where the financials and valuation do the heavy lifting.

The qualitative story can get your attention. The next section is where the thesis either holds up or falls apart.

We will look at the financials, the valuation through the lens of multiples, peer comparison, and reverse DCF, as well as the key risks, catalysts, and the final conclusion.

## The full article is available on Substack.

Please refer to the link below.

<https://open.substack.com/pub/snmart/p/ouster-oust-why-this-is-no-longer?r=lnv10&utm_campaign=post&utm_medium=web&showWelcomeOnShare=true>
