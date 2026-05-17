---
created: 2026-05-17
published: 2026-05-17
description: Gaetano (Crux Capital) argues Corning ($GLW) is one of the most durable AI optical holdings — customer-backed hyperscaler LTAs (Meta plus two more similar in size/duration), Springboard raised from $24B/2028 to $30B/2028 and extended to $40B/2030, optical content per GPU 1.3–1.5x by 2028, scale-up 10x fiber math (16 → 160 fibers/GPU), $10B Photonics MAP by 2030, NVIDIA $500M warrant + multi-billion prepayment funding 10x US optical capacity expansion.
source: https://cruxcapitalgroup.substack.com/p/one-of-the-most-durable-optics-companies
type: thesis
authors: ["Gaetano (Crux Capital Group)"]
subsectors: [Optical components & engines]
---

# Crux Capital 2026-05-17 — One of the most durable optics companies ([[Corning (GLW)]])

> Sister notes in the [[Corning (GLW)]] folder: Crux's Q1 2026 earnings breakdown ([[Corning (GLW) 2026-Q1 earnings - two more Meta-template hyperscaler optical deals signed, Optical sales up 36 pct and net income up 93 pct, May 6 Springboard extension to 2030 and Photonics MAP teased per Crux]]) and the prior fiber-density piece ([[Crux Capital 2026-04-09 - A Physical Constraint, GLW fiber-density story - micro cable multicore hollow-core CPO, Meta $6B and similar size deals in negotiation]]).

## Key Takeaways

- **Customer-backed LTA model is the durability spine.** Q1 disclosed that two ADDITIONAL hyperscalers signed long-term agreements "similar in size and duration" to the Meta deal. Agreements include funding, guaranteed revenue, pricing structures, and risk-sharing mechanisms — capacity expansion without naked exposure.
- **Springboard plan moved up substantially.** From Q4'23 baseline of ~$13B annualized → January 2026 plan of $24B by 2028 → New plan of **$30B by 2028 and $40B by 2030**. Risk-adjusted high-confidence plan: **$27B by 2028 and $35B by 2030**. Phase 1 CAGR was 15%; Phase 2 (entering 2027) is expected to accelerate to **19% CAGR**.
- **Optical content per GPU expected to rise 1.3–1.5x by 2028.** Three drivers: (1) larger clusters add a third optical switching layer above ~130K GPU threshold = +50% more content; (2) bandwidth growth that outpaces SerDes adds lanes/fibers (Hopper 8 fibers → Blackwell 16 fibers as bandwidth doubled but SerDes stayed at 100G); (3) scale-up moves from copper to optical inside the GPU domain.
- **10x fiber math from scale-up.** Scale-out bandwidth ~1.6 Tbps/GPU vs scale-up at 14.4 Tbps/GPU. Corning's example: 16 fibers scale-out + 144 fibers scale-up = **160 total fibers/GPU = 10x current**. Vera Rubin Ultra NVL576 (576 GPUs across 8 racks) is the architecture cited.
- **New $10B Photonics Market-Access Platform (MAP) by 2030.** Inside-the-box passive photonics for CPO / near-package optics / scale-up — historically Corning had zero inside-the-box content.
- **NVIDIA validates the direction.** $500M warrant investment (up to 15M shares at $180 + 3M pre-funded), multi-billion-dollar prepayment to fund US manufacturing expansion. Corning expanding US optical connectivity capacity by **10x** and US fiber capacity by **50%+** (new advanced manufacturing in NC and TX).
- **Cash flow framework supports the plan.** Capex rising from ~$1.7B 2026 baseline through 2027–2028, but CFO says operating cash flow growth will exceed capex growth → FCF still grows. Operating margin target 20% (already above ex-solar). ROIC target into high teens. EPS continues growing faster than sales.
- **Solar raised from $2.5B/2028 to >$3B/2028.** Polysilicon and modules performing; wafers more complex ramp.
- **Risks called out by Gaetano:** (1) scale-up adoption could be slower than market now expects; (2) CPO/NPO timing variance by customer; (3) 400G SerDes could absorb bandwidth without requiring more lanes, reducing fiber content upside; (4) capex outrunning customer funding/revenue conversion.
- **Sector read-through:** [[Lumentum (LITE)]] talking about major scale-across demand; [[Nokia (NOK)]] talking about fiber counts moving from hundreds to thousands between data centers; [[Applied Optoelectronics (AAOI)]] flagged as the more "hyphy" forward-guidance contrast to Corning's traditionally reserved tone. Same physical problem from different angles.

---

## Original Content

*Crux Capital Group — Gaetano — 2026-05-17 — One of the most durable optics companies in the AI supercycle. Position disclosed: long $GLW shares.*

I have been thinking a lot about what the most durable, long term companies are in the optical supercycle.

There are a lot of exciting AI companies. Some are early. Some are speculative. Some can go up a lot if everything breaks right. I like those setups in the right size of course. But the longer I spend in this market, the more I come back to one question.

Which companies are the most durable, long term holdings that I feel the most comfortable having a heavy position?

I want:

- Companies tied to multi-year infrastructure demand.
- Companies with customer depth.
- Companies with physical or technical capabilities that are hard to replicate.
- Companies that can benefit as the architecture changes, rather than depending on one narrow product cycle to carry the thesis.

I want to do a multi part series on the companies that I belive fit this bill the best.

The framework I am using:

- Does the company sit at a real bottleneck?
- Do the largest customers need it for years?
- Does the business gain content as the architecture scales?
- Does the company have manufacturing or technical depth that competitors struggle to copy?
- Can it invest through the cycle while still protecting cash flow?
- Does it have multiple ways to win if the market evolves differently than expected?

The company I am writing about today checks a lot of those boxes. It sits in the physical layer of AI infrastructure. It is tied to a bottleneck that gets harder as AI scales. It has long relationships with the biggest customers in the world. It has manufacturing scale. It has a real cash flow profile. It has customer-backed capacity agreements. And after its most recent releases the opportunity looks much larger than it did a few weeks ago.

What follows is the full breakdown: the customer-backed capacity model that changes the risk profile, the architecture explanation that shows why this is more than a fiber story, the math for the future, why inference is what actually pulls optical into scale-up, and why the financial model supports ownership through the cycle rather than just the current trade.

If you want to understand why I think this name belongs in the durable AI infrastructure bucket, it is all below.

---

# The Company Is Corning, $GLW

I know. That may sound boring at first.

I like companies that sound boring. It means that if you do the deep research that others might glaze over, you can find asymmetry. (See Nokia).

The market has historically viewed Corning through older buckets. Glass, fiber, display, materials, automotive, life sciences, industrial manufacturing.

Fun fact is that you have a Corning product in a piece of tech that (most of you) use every single day, hundreds of times a day. Any guesses?

Those pieces are still there. But the AI buildout has completely changed the way the market sees and values them.

The durability in this company comes from the fact that the role is physical, customer-backed, manufacturing-intensive, and increasingly tied to multiple parts of the AI architecture.

---

## Why Q1 Was A Big Deal

The Q1 call was a major signal.

Read my full breakdown here:

> **Corning ($GLW) Earnings Breakdown** — Gaetano · Apr 28 — [Read full story](https://cruxcapitalgroup.substack.com/p/corning-glw-earnings-breakdown) (sister note in this folder: [[Corning (GLW) 2026-Q1 earnings - two more Meta-template hyperscaler optical deals signed, Optical sales up 36 pct and net income up 93 pct, May 6 Springboard extension to 2030 and Photonics MAP teased per Crux]])

I was listening to the call live with subscribers and taking notes. I ended up adding to my position in the 140's because the stock sold off on the headline numbers way more than I thought was justified and the call was bullish.

*[Image — Discord screenshot of Gaetano's live Q1 call notes; transcribed verbatim below]*

> everythign is very positive so far across teh board
>
> will be upgrading sales plan through 2030 at inestor even next week due to optical
>
> they keep hinting at alot of news to share next week???
>
> significant upgrade to springboard plan. mentioned again
>
> they are teasing something big for their investor event next week
>
> 👍 2
>
> i took some shares in the 147-148 range
>
> not a reccomendation. just stating my actions

They hinted hard at their investor event the following week. They made it sound like a really big deal and I had strong confidence that that day was going to be a major catalyst.

*[Image — X (Twitter) post by Gaetano (@crux_capital_) dated May 3, 2026, 6:39 PM, 44.4K views; transcribed verbatim below]*

> **Gaetano** ✅ @crux_capital_
>
> **$GLW Do we think they hit ATH after Wednesday?**
>
> I am expecting a significant TAM expansion
>
> > Gaetano ✅ @crux_capital_ · Apr 28
> > $GLW Just finished up the call
> >
> > Some notes
> >
> > >2 new hyperscaler deals (similar in size + duration as Meta)…
>
> 6:39 PM · May 3, 2026 · 44.4K Views

More on that later, back to the Q1 report.

- Corning's Optical Communications segment grew 36% year over year.
- Optical net income grew 93% year over year.
- Enterprise and Carrier both grew 36% year over year. Enterprise was driven by GenAI products. Carrier growth came from both data-center interconnect and fiber-to-the-home.

That told us optical demand was real no doubt, but the bigger signal was the customer structure.

Corning had already signed the Meta deal, then came back and told us it had concluded **TWO MORE** large, long-term hyperscaler agreements similar in size and duration.

This is a massive deal.

Look at where the inflection point for GLW was. Guess what news they dropped on that day?

*GLW TradingView chart Dec–May with Jan 27 Meta news annotation marking the 2nd-highest volume day in 2 years*
![[cruxcapitalgroup-one-of-the-most-durable-optics-companies-004.png]]

Jan 27th, META. 2nd highest volume day in 2 years.

So this recent news really pushed forward my thesis. This became a broader customer-backed capacity story.

What's also nice and was very insightful from the call was that these agreements share risk and reward. They can include funding, guaranteed revenue, pricing structures, and other mechanisms that help Corning expand capacity while protecting returns. That is a very different model than building capacity and hoping demand shows up. For a long-term holder, that kind of visibility matters enormously.

---

## Why I was leaning hard into May 6

The clues were sitting in plain sight.

*[Image — X (Twitter) post by Gaetano (@crux_capital_) dated May 5, 2026, 12:46 PM, 54.5K views; transcribed verbatim below]*

> **Gaetano** ✅ @crux_capital_
>
> **My hopes are up $GLW**
>
> Is anyone else heavy in here going into tomorrow?
>
> > Gaetano ✅ @crux_capital_ · May 3
> > $GLW Do we think they hit ATH after Wednesday?
> >
> > I am expecting a significant TAM expansion x.com/crux_capital_/…
>
> 12:46 PM · May 5, 2026 · 54.5K Views
>
> 💬 15  🔁 3  ❤️ 66  🔖 14

The first clue was Q1 itself. Corning had already told us Meta had become repeatable. Two more hyperscaler agreements had been signed and management kept saying May 6 would include a major Springboard update and a new Photonics Market-Access Platform. It was clear that they were really excited to share the updates.

The second clue was the sector read-through. [[Lumentum (LITE)]] was talking about major scale-across demand. [[Nokia (NOK)]] was talking about the industry moving from hundreds to thousands of fibers between data centers. Those comments pointed to the same physical problem. AI networks need more optical density, more links, more fiber, and more physical infrastructure. That is exactly where Corning plays.

The third clue was Corning's own tone. This did not sound like a company with one lucky Meta win. It sounded like a company entering a much larger capacity cycle, with customers helping fund and de-risk the required expansion. Also to note, this is a traditionally very reserved forward speaking company. There are some companies that I track that are VERY hyphy (looking at you [[Applied Optoelectronics (AAOI)]]) where they are very quick to put out massive projections. But when a company like Corning does, it especially makes you excited.

Here is a snippet from my earnings dive:

*[Image — excerpt from the sister Crux note "Corning ($GLW) Earnings Breakdown" titled "May 6 Is The Real Catalyst"; transcribed verbatim below]*

> ## May 6 Is The Real Catalyst
>
> Management mentioned the May 6 investor event repeatedly, and the emphasis was deliberate. They talked about it A LOT!
>
> Corning plans to share a significant upgrade to Springboard, extend the framework through 2030, and introduce a new Photonics Market-Access Platform in Optical Communications aimed at Gen AI OEM customers. The January upgrade had already targeted $11B of incremental annualized sales by end of 2028. Now they are preparing another upgrade with a longer time horizon and a new photonics-specific platform on top of it.

So my setup going into May 6 was simple. Corning had a real chance to expand the AI optics thesis beyond fiber buildout into a much larger architecture story. That is exactly what happened.

*[Image — X (Twitter) reply thread May 5–6 between Banshee (@DeNebulord) and Gaetano (@crux_capital_); transcribed verbatim below]*

> 🌅 **Banshee** ✅ @DeNebulord · May 5
>
> What's tomorrow? They already had earnings
>
> 💬 1  🔁  ❤️  📊 1.5K  🔖  ⤴️
>
> 👤 **Gaetano** ✅ @crux_capital_ · May 5
>
> On their call last week they kept teasing their investor event that's taking place tomorrow
>
> They were holding back a good bit of information
>
> investor.corning.com/news-and-event…
>
> 💬 1  🔁 1  ❤️ 6  📊 3.3K  🔖  ⤴️
>
> 🌅 **Banshee** ✅ @DeNebulord · May 6
>
> **Thanks bro! I bought a yolo $170C expiring this week for $3. Now it's worth $20!**
>
> ```
> GLW
> Corning
> $189.30 ➔
> ▲ $27.20 (16.78%)  Pre-market
> 24 Hour Market
> ```

Congrats to this Banshee. I also wanted short term calls but I ended up just sizing heavy in shares.

I can put out all the information possible, but at the end of the day it's up to all of us to actually make that decision for ourselves and pull the trigger!

---

## The Investor Day changed the size of the story

Before earmings, my question was whether Meta was a one-off or the first example of a broader customer-backed model. Corning answered that by signing two more hyperscaler agreements of similar size and duration.

At Investor Day, the question changed. The new question became: how large can Corning's AI optical opportunity become as AI systems move from scale-out fiber networks toward scale-up optical links and inside-the-box photonics?

Before May 6, NVIDIA played a minimal role in the Corning thesis.

After May 6, NVIDIA became the architecture validation point for the Photonics roadmap.

Before May 6, scale-up was mostly a call option.

After May 6, scale-up moved into the modeled opportunity.

Before May 6, Corning's AI story centered on fiber, cable, and connectivity around data centers.

After May 6, Corning introduced a new Photonics Market-Access Platform with a potential $10 billion revenue opportunity by 2030.

That is setup we are now facing. More on NVIDIA later.

---

## The numbers got a lot bigger

The Springboard plan moved up substantially.

The January framework already looked strong.

*Original Springboard plan from January 2026: Q4'23 baseline ~$13B → $24B annualized run rate by Q4'28*
![[cruxcapitalgroup-one-of-the-most-durable-optics-companies-008.png]]

Corning was targeting a $24 billion annualized sales run rate by 2028.

At the Investor Day, the company raised the internal plan to $30 billion by 2028 and extended the framework to $40 billion by 2030.

*"Accelerating Springboard Growth" — internal plan raised to $30B by Q4'28 and extended to $40B by Q4'30; Phase 1 CAGR 15% accelerating to Phase 2 CAGR 19%*
![[cruxcapitalgroup-one-of-the-most-durable-optics-companies-009.png]]

The risk-adjusted version targets $27 billion by 2028 and $35 billion by 2030.

*"Upgraded High-Confidence Plan" — $35B by Q4'30 with a $5B gap to the $40B internal plan, representing scale-up + Photonics timing uncertainty*
![[cruxcapitalgroup-one-of-the-most-durable-optics-companies-010.png]]

Look at that graph!

To put that in context. Q4 2023 starting point was around $13 billion annualized. January 2026 internal plan was $24 billion by 2028. New internal plan is $30 billion by 2028 and $40 billion by 2030. High-confidence plan is $27 billion by 2028 and $35 billion by 2030.

Corning also said the first phase of Springboard delivered a 15% CAGR, and the next phase entering 2027 is expected to accelerate to a 19% CAGR.

The spread between the internal plan and the high-confidence plan is also important to understand.

The internal plan is the actual business plan.

The high-confidence plan is the risk-adjusted investor version.

That gap exists because timing is still hard to call, especially around scale-up and Photonics adoption. If those ramp faster, Corning tracks closer to the internal plan. If adoption takes longer, the high-confidence plan becomes the more realistic path.

Either way, the company is telling us the opportunity is much bigger than it looked a few months ago.

---

## Optical content per GPU

This is one of the biggest take aways from their investor event.

**Corning can grow faster than GPU growth if optical content per GPU rises.**

> "We calculate that the demand for optical content per GPU in our enterprise map will increase by 1.3 to 1.5 times by 2028."

*"Enterprise: opportunity to grow faster than GPU Growth" — Corning's table of three drivers for content/GPU expansion (more switching layers, more lanes, scale-up optical)*
![[cruxcapitalgroup-one-of-the-most-durable-optics-companies-011.png]]

Let's unpack that a bit.

A basic AI fiber thesis says more GPUs require more data centers, and more data centers require more fiber. Linear relationship.

Corning's Investor Day added a second layer: each GPU can require **more** optical content over time.

That happens for three reasons:

- Larger clusters add more optical switching layers
- Bandwidth growth can add more fiber lanes.
- Scale-up creates a new optical network entirely.

This is the difference between a standard AI infrastructure read-through and a content-per-GPU thesis.

This plays into my durability thesis.

---

## Scale-out: more clusters, more optical layers

Scale-out is the network that connects all the GPUs in a large AI cluster.

This is the part of the network that lets thousands, hundreds of thousands, or eventually millions of GPUs work together on the same massive AI workload. As the cluster gets bigger, the network has to do more work because every GPU needs a path to communicate across the system.

In smaller or more standard clusters, the network can often be built with two optical switching layers. Think of this as a two-step connection path. GPUs connect up to one layer of switches, and those switches connect into another layer that ties the cluster together.

*"Over Time Clusters Require a Third Layer" — diagram showing two-layer scale-out network architecture for smaller clusters*
![[cruxcapitalgroup-one-of-the-most-durable-optics-companies-012.png]]

But Corning's point is that once the cluster gets large enough, the two-layer design runs out of scale. Their threshold was roughly 130,000 GPUs, assuming a 512-port switch radix. Above that level, the network needs a third optical switching layer to connect the entire cluster in a non-blocking architecture.

We don't really need to get too in the weeds here. So the investment takeaway is that a large clusters not only means more GPUs, it can also mean more optical layers per GPU.

Management put it this way:

> "When a cluster grows beyond this, it forces a third layer in a non-blocking architecture."

*"Third Switch Layer to Connect all the GPUs in a Cluster >130K" — comparison of two-layer (left) vs three-layer (right) network; punchline at bottom: **50% more content in very large clusters***
![[cruxcapitalgroup-one-of-the-most-durable-optics-companies-013.png]]

The slide here helps make the point visually. On the left, Corning shows the two-layer network. On the right, once the cluster moves above the 130,000 GPU breakpoint, the network adds a third layer. Corning's punchline is at the bottom: **50% more content in very large clusters**.

That is the first way Corning can grow faster than GPU deployments.

If the number of GPUs rises, that is already good for optical demand. But if the cluster architecture also moves from two layers to three layers, Corning gets a second benefit: more fiber, cable, connectivity, and optical infrastructure per GPU.

Tying it back to the durability thesis, Corning is not only tied to the number of AI data centers being built. It is tied to how complex those AI data centers become as the clusters scale.

---

## Bandwidth growth and the SerDes question

The second driver is bandwidth.

Every new GPU and switch generation needs to move more data. That part is obvious. The less obvious part is that there are different ways to move that extra data, and only some of them increase Corning's content.

Think of each optical link like a highway.

If traffic doubles, you have two choices. You can make each lane faster, or you can add more lanes.

That is basically the SerDes question.

*"We increase bandwidth by increasing lane rate (SerDes) or quantity of lanes" — Corning's table mapping Hopper / Blackwell / Rubin / Feynman generations to fiber counts per GPU and SerDes lane speed*
![[cruxcapitalgroup-one-of-the-most-durable-optics-companies-014.png]]

SerDes is the technology that moves data across high-speed links. If SerDes improves fast enough, the system can move more bandwidth through the same number of lanes. That means more data, but not necessarily more fiber.

The better setup for Corning is when bandwidth rises faster than SerDes. Then the system needs more lanes. More lanes can mean more fibers, more connections, and more optical infrastructure.

Corning used Hopper to Blackwell as the example. Hopper needed **8 fibers**. Blackwell doubled bandwidth, but SerDes stayed at **100G**, so the system needed **16 fibers**. Same lane speed, more total bandwidth, more fibers.

That is the content-per-GPU point.

Looking forward, the question becomes whether future platforms can absorb bandwidth growth with faster SerDes. If 400G SerDes is ready and reliable, fiber-content growth could be more muted. If the system stays at 200G while bandwidth doubles again, more lanes may be needed, and fiber content can rise again.

This also applies beyond GPUs. Wendell specifically talked about future GPU platforms like Feynman and future switch ASIC platforms like Tomahawk 7. The same idea applies to both: more bandwidth creates more opportunity for Corning when it requires more lanes.

So to summarize this, bandwidth growth is most valuable for Corning when it turns into lane growth.

On durability, Corning is exposed to the way chips get connected as bandwidth requirements rise.

---

*"Brand new large optical network opportunity" — the 10x reality: scale-out 16 fibers + scale-up 144 fibers = 160 total fibers per GPU, anchored on NVIDIA's Vera Rubin Ultra NVL576 architecture (576 GPUs across 8 racks)*
![[cruxcapitalgroup-one-of-the-most-durable-optics-companies-015.png]]

---

## Scale-up is the real step-up

Scale-up is where the Corning story gets much bigger.

A quick refresher, Scale-out connects many GPU racks into a large cluster. Scale-up is the network that makes multiple GPUs act more like one giant accelerator, typically thought of being within a rack.

Scale-up is much more sensitive to latency. The GPUs need to communicate extremely fast, and delays can reduce how efficiently the whole system works.

Currently, scale-up has copper because the distances are short enough. Copper works well inside a rack. It can be fast, cheap, reliable, and familiar.

The problem starts when the GPU domain gets larger.

If the industry wants to connect more GPUs across more racks while keeping latency low, copper starts to struggle. The distances get longer, bandwidth goes up, power becomes more important, and the system starts moving toward what Corning discusses as the electrical-to-optical divide.

So this is where optical enters the scale-up discussion.

The example Corning focused on was NVIDIA's Vera Rubin Ultra NVL576 platform. That system connects 576 GPUs across 8 racks, with 72 Rubin Ultra GPUs per rack. The important detail is that rack-to-rack scale-up starts using direct optical links.

Let's look at the bandwidth numbers.

Scale-out bandwidth per GPU is **1.6 Tbps**.

Scale-up bandwidth per GPU is **14.4 Tbps**.

That means the scale-up network has far more bandwidth to support than the scale-out network. If even part of that scale-up network moves from copper to optical, the fiber opportunity can expand quickly.

This is why scale-up is a massive step up for Corning (and most of the other companies we discuss)

The prior Corning AI thesis was mostly about optical links around data centers and GPU clusters. The new thesis adds a much larger question: what happens if optical starts moving deeper into the GPU domain itself?

---

## The 10x fiber math

This is where the scale-up opportunity becomes easier to understand.

Corning's current scale-out example starts with **16 fibers per GPU**. That is the baseline.

Then Corning shows what happens if scale-up becomes fully optical. Because scale-up bandwidth per GPU is much larger than scale-out bandwidth, the fiber count can rise dramatically.

In Corning's example:

- **16 fibers** support scale-out
- **144 fibers** support scale-up
- **160 total fibers** support both

> "When we combine these demands, we get a total fiber content of 160 fibers per GPU, which is 10 times the amount of fibers of the current scale-out network."

That is the 10x fiber math.

But Corning is not saying every GPU immediately goes from 16 fibers to 160 fibers. The real world will be hybrid. Some scale-up links remain copper. Some become optical. Customers will adopt different architectures at different speeds.

The key point is the new range of outcomes.

Before scale-up, the conversation was mostly about scale-out fiber. After scale-up enters the model, Corning can participate in another optical network with much higher bandwidth requirements.

Corning does not need the full 10x scenario for this to be significant. Even partial optical scale-up can increase optical content per GPU.

On durability, Corning is tied to how the architecture around those chips changes over time.

---

## Why inference is what pushes scale-up forward

Inference is when the model is actually being used. It is the chatbot response, the agentic workflow, the reasoning step, the code generation, the search result, the customer-support interaction, the enterprise query.

*"AI Scaling Laws Drive Need for More Intelligence" — Corning's framing of how mixture-of-experts, reasoning models, test-time scaling, and agentic systems drive the inference workload toward larger low-latency GPU domains*
![[cruxcapitalgroup-one-of-the-most-durable-optics-companies-017.png]]

As inference becomes more advanced, the workload gets more demanding. Corning pointed to mixture-of-experts models, reasoning models, test-time scaling, and agentic systems as examples. These workloads need more memory, more bandwidth, and lower latency across a larger group of GPUs.

This is where the conversation around nodes comes in.

*"AI Node Today: 72 GPUs" — single rack with copper scale-up connecting 72 GPUs as one node; today's baseline before optical scale-up*
![[cruxcapitalgroup-one-of-the-most-durable-optics-companies-018.png]]

A node is a group of GPUs acting like one larger accelerator. Today, Corning says a node can be confined to a single rack of 72 GPUs connected through copper scale-up. That works because the distances are short.

But if inference pushes node sizes beyond one rack, the system needs to connect more GPUs while still keeping latency low. That is generally where copper starts to struggle and optical becomes more attractive.

So the chain is:

- More advanced inference needs larger low-latency GPU domains.
- Larger low-latency GPU domains require better scale-up.
- Better scale-up starts pulling in optical links.
- Optical scale-up creates a new Corning content opportunity.

*"The Solution: Add Optical to the Scale-Up Network" — Corning's vision of multi-rack optical scale-up extending node size beyond a single rack*
![[cruxcapitalgroup-one-of-the-most-durable-optics-companies-019.png]]

So AI usage will change the physical architecture of the cluster. And that plays into Corning's durability.

---

## Scale-across: connecting the AI campus

This is about connecting data centers, buildings, campuses, or nearby regions so they can function as part of a larger AI infrastructure footprint. AI buildouts are running into physical constraints. Power, land, cooling, permitting, and construction timelines do not always line up perfectly in one location.

So the infrastructure spreads out.

A hyperscaler may build across multiple buildings on the same campus. Or across nearby campuses. Or across regional data centers that need to share workloads, storage, training data, inference traffic, and model updates.

That creates another optical problem.

Those facilities still need to move huge amounts of data between each other quickly and reliably. That is data-center interconnect, or DCI.

This is where scale-across fits the Corning thesis. Corning already benefits when more fiber is needed inside the data center. But scale-across adds demand between data centers and buildings too.

That means more fiber routes, more high-density cable, more conduit density, more connectivity, and more physical optical infrastructure between facilities.

As AI infrastructure spreads across buildings and campuses, the links between those facilities become more valuable.

This also ties into what we are hearing across the sector. [[Lumentum (LITE)]] is talking about major scale-across demand. [[Nokia (NOK)]] is talking about fiber counts moving from hundreds to thousands between data centers. Corning is talking about data-center interconnect inside Carrier.

Same signal just from different angles.

That gives Corning another way to win. Scale-out increases content inside the cluster. Scale-across increases optical demand between facilities. Scale-up can pull optics deeper into the GPU domain. Photonics can move Corning content inside the box.

That is why I like the durability of the setup.

---

## Enterprise versus Photonics

Enterprise is the more optical links around the AI factory story. This includes fiber, cable, and connectivity for scale-out, scale-across, data-center interconnect, and early optical scale-up links. This is the business investors already understand well. Corning sells the physical optical layer around AI data centers and campuses.

Photonics is the Corning content moves inside the AI system story. This is the new Market-Access Platform tied to co-packaged optics (CPO), near-package optics (NPO), and passive photonics that move and manage light inside the box.

*Enterprise vs Photonics — Corning's bifurcation of the AI optical opportunity into outside-the-box (Enterprise) and inside-the-box (Photonics)*
![[cruxcapitalgroup-one-of-the-most-durable-optics-companies-020.png]]

Passive photonics means the pieces that guide, route, split, connect, and manage light rather than generate or modulate it. Corning is focused on supplying the physical optical pieces that make those systems work as light moves deeper into the box, rather than competing in the GPU or switch ASIC layer.

So to distill it, Enterprise is outside the box and around the cluster. Photonics is inside the box. Both are tied to AI, but they have different timing, different customers, and different content economics. This distinction is why this presentation was so important. Corning was raising the existing Optical Communications story while adding a new Photonics platform on top of it.

*"New 'Inside the Box' Optical functions create opportunity for Corning Passive Photonics to manage light" — diagram showing ELS / PMF / FAU / PIC / SerDes / ASIC layout inside a multi-ASIC switch, with bullets noting light creation, modulation, and delivery move "inside the box" at the Silicon Photonic Optical Engine, and that tomorrow all passive photonics move and manage light "inside the box"*
![[cruxcapitalgroup-one-of-the-most-durable-optics-companies-021.png]]

"Historically, we've had no inside-the-box content. This creates an opportunity for Corning to supply all the passive photonics required to move and manage the light."

---

## The $10 billion Photonics opportunity

Corning sized the Photonics MAP at a potential $10 billion revenue opportunity by 2030 if its assumptions are correct.

*"New Photonics MAP Creates Opportunity Twice the Size of Today's Enterprise Business" — annualized sales run rate Q4'23 → Q4'30 area chart with Photonics (blue, ramping ~$10B by Q4'30) layered on top of Enterprise (gray, ~$30B by Q4'30); callouts: wide variety in predictions for annual growth rates, external consensus of adoption rate 10%-50%, $10B opportunity by 2030*
![[cruxcapitalgroup-one-of-the-most-durable-optics-companies-022.png]]

The opportunity depends on several variables: when CPO launches, how quickly CPO scales, how much of scale-up becomes optical, which switch architectures win, how much passive photonics Corning captures inside the box, and how quickly OEM customers adopt these architectures.

They were clear that this is hard to model with traditional techniques. Timing remains uncertain. But they are now giving us a framework for a new $10 billion revenue opportunity that was absent from the older Corning thesis.

---

## NVIDIA

Corning announced a long-term technology and commercial partnership with NVIDIA, and this was one of the highest-signal parts of the Investor Day.

Corning is expanding U.S.-based optical connectivity manufacturing capacity by **10x** and expanding U.S. fiber production capacity by **more than 50%** to support next-generation AI infrastructure. The expansion includes new advanced manufacturing capacity in North Carolina and Texas. NVIDIA also made a $500 million warrant investment in Corning, with warrants tied to Corning shares, including up to 15 million shares at $180 per share and a pre-funded warrant for up to 3 million shares. Reuters also said that NVIDIA is making a multi-billion-dollar prepayment to help fund Corning's U.S. manufacturing expansion.

NVIDIA is helping fund the manufacturing expansion and taking equity-linked exposure to Corning's role in the AI optical supply chain. That is a really big deal.

This relationship is also the bridge between Corning's historical optical infrastructure business and the new inside-the-box Photonics MAP. Corning is getting closer to the future system roadmap around GPUs, switch ASICs, scale-up, CPO, near-package optics, and passive photonics inside the box.

> "The way to think about NVIDIA here is it really underpins our Photonics map."
>
> "You can expect us to be working to fundamentally reinvent the optical systems here as we go forward through the coming generations of product."

NVIDIA validates the direction of the Photonics opportunity. Exact revenue details remain undisclosed, and individual NVIDIA architectures may vary in how they flow to Corning. But the company is now working with the most important AI compute company on the optical systems required for future architectures.

There is also an important nuance on customer disclosure.

> "We're going to let our customers lead in talking about that piece."

They also said:

> "What you can count on us to do is turn their publicly disclosed information into an easy rubric for you to be able to understand what it means for us."

This creates ambiguity now and future catalysts later. Every NVIDIA, hyperscaler, OEM, or Gen AI architecture announcement can become a Corning read-through.

---

## Manufacturing scale is part of the durability case

The demand signal was obvious, but Corning also spent time explaining why it thinks it can actually win.

Corning is vertically integrated across fiber, cable, and connectivity. Management emphasized cost position, capacity, product differentiation, and customer engineering support. They highlighted that they operate the largest optical fiber factory in the world and are building what they described as the largest cable manufacturing facility in the world, both in North Carolina.

Corning also said it already has the densest inside-plant cables in the industry by 20-30%, and expects to more than double that lead with new fiber and ribbon innovations.

That fits perfectly with the broader thesis. AI networks are fighting for space, density, installation efficiency, and reliability. If Corning can give customers more optical capacity in less space, that becomes more valuable as networks scale. This is part of what makes the company durable. Not only do they have massive demand, but they also have the ability to manufacture and deliver at scale.

I also liked the way management talked about pricing. The better model is to invent products that lower the customer's total cost, then share in that value. That is different from exploiting a short-term supply-demand squeeze in bare fiber. The upside comes from better systems, higher density, lower installed cost, more reliable optical performance, and more Corning content. That is a much better business model if it works long term, as it helps strengthen customer relationships.

---

## The cash flow question

A much larger opportunity requires more investment.

The CFO confirmed capex could rise from the 2026 level of roughly $1.7 billion in 2027 and 2028. But the critical part is the cash flow framework.

> "We expect operating cash flow growth to exceed that capital spending. We expect free cash flow to continue to grow even as our CapEx goes up."

This ties directly back to the customer-backed capacity model from Q1. Corning is using long-term customer agreements to share cost and risk. Those agreements can include funding, guaranteed revenue, pricing structures, accelerating share agreements, and other risk-sharing tools. The Meta-like agreements serve a dual purpose. They are demand signals, but they are also financial tools that allow Corning to expand while protecting returns.

On margins, the official operating margin target stays at 20% for now, but management's tone was clear about the direction. The CFO said Corning is already above 20% excluding solar drag. EPS should continue growing faster than sales. ROIC is expected to improve into the high teens.

> "With a mid-teens ROIC and a 19% sales CAGR, we will create a significant amount of value."

Revenue growth is awesome, but ROIC and free cash flow growth are what make the massive plan credible.

---

## Solar and Carrier

Solar received an upgrade. The prior $2.5 billion solar target by 2028 was raised to exceed $3 billion within the Springboard window. Polysilicon and modules are performing well. Wafers remain the more complex ramp. Solar adds to the company-level growth plan, but Enterprise and Photonics changed the AI infrastructure thesis.

*"We shared by MAP where our growth would come from" — Q4'23 baseline $13B → $18B by Q4'26 → $21B by Q4'28 stacked area chart broken down by MAP: Optical (blue, dominant), Display, Automotive, MCE, Life Sciences Vessels, Emerging Growth, Solar*
![[cruxcapitalgroup-one-of-the-most-durable-optics-companies-023.png]]

Carrier also still supports the scale-across story. Data-center interconnect is included in the Carrier business. As AI infrastructure scales across buildings, regions, and linked facilities, DCI demand grows. So Corning now has several AI optical channels running simultaneously: Enterprise hyperscaler data-center networks, Carrier data-center interconnect, scale-up optical networks, and passive photonics inside the box.

---

## Where I could be early

The thesis improved, but the bar also moved higher.

The biggest risk is that scale-up adoption takes longer than the market now wants. Copper and hybrid systems could last longer than expected, delaying the optical scale-up content ramp.

The second risk is CPO and near-package optics timing. These architectures could take longer to ramp, vary widely by customer, or give Corning less content than the framework implies.

The third risk is SerDes. If 400G SerDes absorbs bandwidth growth without requiring more lanes, some of the fiber content upside gets pushed out or reduced.

The fourth risk is capex. Corning is telling investors that operating cash flow will grow faster than capital spending. That has to be proven quarter by quarter. If capex rises faster than customer funding or revenue conversion, the model gets harder.

---

## Why I think this can be a durable holding

I want to own companies that can compound through multiple stages of the AI buildout.

That means more than a one-product trade. I want a company attached to a durable bottleneck, with customer depth, manufacturing scale, and the ability to adapt as the architecture changes. Corning fits that better today than it did before May 6.

The company already had the customer-backed capacity story from Q1. Now it has a bigger architecture story from Investor Day. Scale-out adds layers as clusters grow. Scale-up adds an entirely new optical network. Photonics moves Corning inside the box for the first time. NVIDIA validates the direction. The Springboard plan gives us a larger financial framework. Customer agreements help protect the investment cycle.

That is why this belongs in one of the top positions in my durable AI infrastructure bucket.

---

*I currently own shares of $GLW. This report reflects my personal research and opinion. It is general information, not individualized investment advice. I may buy, sell, trim, or add to any position discussed at any time without prior notice. Nothing in this post should be treated as a recommendation to buy, sell, or hold any security. Position size, risk tolerance, time horizon, and overall portfolio context should drive every investment decision.*

---

## Source

- Crux Capital Group (Gaetano) — Substack — 2026-05-17 — <https://cruxcapitalgroup.substack.com/p/one-of-the-most-durable-optics-companies>
