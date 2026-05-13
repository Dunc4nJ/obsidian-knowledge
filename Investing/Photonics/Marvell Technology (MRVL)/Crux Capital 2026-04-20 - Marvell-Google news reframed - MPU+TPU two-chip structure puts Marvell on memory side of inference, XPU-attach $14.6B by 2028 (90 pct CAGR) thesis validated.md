---
created: 2026-05-13
published: 2026-04-20
description: Crux reframes the Reuters report that [[Alphabet (GOOGL)]] is in talks with [[Marvell Technology (MRVL)]] to develop two new AI chips — a TPU plus a memory processing unit (MPU) — as architectural validation of Marvell's XPU-attach thesis (custom XPU attach $0.6B 2023 → $14.6B 2028, 90 pct CAGR). The deeper read: Google is investing serious engineering effort on the memory side of inference and Marvell has spent the past year positioning around that exact pressure point.
source: https://cruxcapitalgroup.substack.com/p/marvell-google-news-is-it-time
type: analysis
authors: ["Crux Capital Group (@cruxcapitalgroup)"]
---

# Crux Capital 2026-04-20 — Marvell/Google news: what's going on?

Reuters: [[Alphabet (GOOGL)]] is in talks with [[Marvell Technology (MRVL)]] to develop **two new AI chips** — a new TPU built for inference efficiency plus a memory processing unit (MPU) designed to work with Google's TPU. Crux's deeper read: Google may be evaluating Marvell for a role in the architecture AROUND the chip — memory, pooling, packaging, data movement — where efficiency at scale is decided. The opportunity sits in a broader system layer than markets currently assign to MRVL.

## Key Takeaways

- **Two-chip structure is the key detail.** One chip = core AI processing job (next-gen TPU). Second chip = MPU (memory-processing unit), aimed at the memory side of the system. Reuters says Google aims to finalize the memory-chip design as soon as next year before handing off for test production.
- **Inference, not training.** Project targets AI "inferencing" — processing workloads, not training models like Gemini. Google's Ironwood TPU (April 2025, gen-7) was already framed as **first TPU designed specifically for inference**, scaling to 9,216 chips with focus on HBM capacity, HBM bandwidth, and pod-scale system design.
- **Why memory becomes first-order in inference.** Training draws attention to raw compute; inference still needs compute but also turns **memory and data movement into first-order constraints**. KV-cache (model's stored working context during a conversation) grows with longer context windows and richer conversations — Marvell has called out exploding model sizes, expanding context windows, and growing KV-cache as major memory-demand drivers across AI infrastructure.
- **Marvell's positioning maps the news exactly.**
  - **XPU vs XPU attach framing** (2025 Custom AI event): XPU = main AI processor; XPU attach = memory-related hardware, scale-up fabric, networking, host-management functions, memory poolers, expanders. Accelerated custom compute = XPU + XPU attach.
  - **Custom silicon to 25% share of accelerated compute market by 2028.** Custom XPU attach: **$0.6B (2023) → $14.6B (2028), 90% CAGR.** Data center TAM: $21B (2023) → $94B (2028), accelerated custom compute fastest-growing category.
  - **Custom HBM compute architecture** (Dec 2024 announcement): up to 25% more compute, 33% more memory, up to 70% lower memory-interface power via redesigned HBM subsystem, interfaces, packaging.
  - **Next-gen CXL switch** (March 2026 launch) built entirely around the AI memory wall — true memory pooling across the rack, higher memory utilization, improved data-flow efficiency, lower TCO.
- **The alpha — broader layer of the system than currently assigned.** A lot of coverage will frame this as "Google working with Marvell on a chip program." Crux's deeper read: Google may be evaluating Marvell for a larger role in the architecture around the chip — memory, pooling, packaging, data movement. **Signal is architectural before revenue shows up.**
- **Fits Google's multi-vendor custom silicon strategy.** Earlier in April [[Broadcom (AVGO)]] signed long-term agreement with Google **through 2031** to co-develop and supply future generations of custom AI chips for Google's next-gen AI racks. Pattern: one supplier on main accelerator path, another on memory-side bottlenecks, others elsewhere in rack. Broader and more distributed custom silicon landscape than a one-winner narrative.
- **Supply-chain read-through.** Momentum can flow up and down. If you invest in [[POET Technologies (POET)]] or [[Sivers Semiconductors (SIVE.ST)]], positive movement in Marvell may drive action in these names too — though whether justified depends on the actual news. Crux flagged the related deep-dives:
  - POET Tech Deep Dive (Apr 12): https://cruxcapitalgroup.substack.com/p/poet-tech-deep-dive
  - $SIVE Deep Dive (Apr 6): https://cruxcapitalgroup.substack.com/p/sive-deep-dive

## Original Content

Reuters reported that Google is in talks with Marvell to develop two new AI chips.

[Image — Reuters/Funda AI news clip screenshot; transcribed verbatim below]

> Google-parent **Alphabet** (**GOOGL**) is in talks with **Marvell Technologies** (**MRVL**) to produce new versions of its artificial intelligence chips, according to reports. Wall Street analysts view sales of AI accelerator chips as a fast-growing business for Google stock.
>
> According to the **Information** and Funda AI, the Google/Marvell partnership would target AI "inferencing" — processing workloads, not training AI models such as Gemini. Also, Marvell would reportedly produce an AI memory chip designed to work with Google processors.

One is a memory processing unit designed to work with Google's TPU. The other is a new TPU built specifically to run AI models more efficiently. Reuters also said Google aims to finalize the memory-chip design as soon as next year before handing it off for test production. Google has been pushing TPUs as an alternative to Nvidia GPUs, and Reuters noted TPU sales have become a key driver of Google Cloud growth.

The key detail is the two-chip structure. One chip handles the core AI processing job. The second appears aimed at the memory side of the system. That suggests Google may be spending considerably more effort on the part of AI infrastructure that helps a processor get data in and out quickly and efficiently.

---

### Why inference is the backdrop

Training is the phase where an AI model learns from massive data sets. Inference is the phase where a finished model is actually used. Every time a model answers a prompt, writes code, summarizes a document, or generates an image, that is inference.

Google has already been steering its TPU story in this direction. In April 2025, it introduced Ironwood as its seventh-generation TPU and said it was the first TPU designed specifically for inference. Google described it as its most powerful, capable, and energy-efficient TPU yet, scaling up to 9,216 chips.

Inference shifts where the pressure lands inside a system. Training draws attention to raw compute. Inference still needs plenty of compute, but heavy real-world usage also turns memory and data movement into first-order constraints. The system has to keep key data close to the processor, move that data quickly, and do it at a cost and power profile that works at scale. Google's own Ironwood launch highlighted HBM capacity, HBM bandwidth, and pod-scale system design right alongside compute performance.

One reason memory demand rises so quickly during inference is KV-cache. KV-cache is the model's stored working context during a conversation. As context windows get longer and the conversation gets richer, that stored context grows with it. Marvell has highlighted exploding model sizes, expanding context windows, and growing KV-cache requirements as major drivers of memory demand across AI infrastructure.

The takeaway is that Google appears to be trying to make inference faster, cheaper, and more efficient by redesigning the memory side of the system rather than relying only on a stronger main accelerator.

---

**Who Should Care About This News?**

Obviously if you invest in Marvell, this is a significant development to watch.

But in the market today we are seeing lot's off momentum up and down supply chains. So if you invest in POET technologies or Sivers Semiconductors, positive movement in Marvell could drive action in these stocks as well. Whether movement in those companies is justified or not really depends on the news being made, but it's important to keep in mind market dynamics.

If you want to learn more about POET or Sivers or their connection to Marvell, read these:

[Image — share card thumbnail for "POET Tech Deep Dive" by Gaetano, Apr 12 — link: https://cruxcapitalgroup.substack.com/p/poet-tech-deep-dive]

[Image — share card thumbnail for "$SIVE Deep Dive" by Gaetano, Apr 6 — link: https://cruxcapitalgroup.substack.com/p/sive-deep-dive]

*The rest of this post covers why Marvell fits this architectural shift so precisely, an additional alpha angle, and what the Broadcom context tells us about where Google's broader silicon strategy may be heading.*

### Why Marvell fits

Marvell has spent the last year telling us that the AI opportunity extends well beyond the main processor.

Marvell uses the term XPU for the main AI processor. It uses XPU attach for the silicon around that processor: memory-related hardware, scale-up fabric, networking, host-management functions, memory poolers, expanders, and other components that help the full system run efficiently. At its 2025 Custom AI event, Marvell framed accelerated custom compute as XPU plus XPU attach.

The numbers behind that framing are significant. Marvell says custom silicon is on track for 25% share of the accelerated compute market by 2028. Within that, custom XPU attach grows from roughly $0.6 billion in 2023 to $14.6 billion in 2028, a 90% CAGR. Marvell also places its data center TAM at $21 billion in 2023 and $94 billion in 2028, with accelerated custom compute as the fastest-growing category.

Marvell has also been building products around that thesis with real specificity. In December 2024, Marvell announced a custom HBM compute architecture that it said can enable up to 25% more compute, 33% greater memory, and up to 70% lower memory-interface power by redesigning the HBM subsystem, interfaces, and packaging around the AI processor. That architecture is available to custom silicon customers to improve performance, efficiency, and total cost of ownership.

Then in March 2026, Marvell launched its next-generation CXL switch and built the entire announcement around the AI memory wall. CXL, or Compute Express Link, allows processors and accelerators to access pooled memory resources across the rack rather than relying only on memory physically attached to a single server. Marvell said its CXL switch enables true memory pooling across the rack, raising memory utilization, improving data-flow efficiency, and lowering total cost of ownership.

Reuters is describing a Google project centered on inference efficiency and memory architecture. Marvell has spent months telling us that a growing share of AI value will come from solving exactly that class of problem.

---

### A little alpha

A lot of coverage will frame this as Google working with Marvell on a chip program.

I think the deeper framing is that Google may be evaluating Marvell for a larger role in the architecture around the chip, where memory, pooling, packaging, and data movement decide efficiency at scale. If that interpretation holds, the opportunity sits in a broader layer of the system than is currently assigned to Marvell.

That also helps explain why this could become significant before revenue shows up in a meaningful way. Reuters said the MPU could be finalized next year before moving into test production. The first signal here is architectural. Google appears willing to invest serious engineering effort on the memory side of inference, and Marvell has already positioned itself around that exact pressure point.

---

### The broader context

This report fits a larger pattern inside Google's silicon strategy.

Earlier this month, Broadcom signed a long-term agreement with Google through 2031 to co-develop and supply future generations of custom AI chips for Google's next-generation AI racks. Taken together, the pattern suggests Google is building a multi-vendor custom silicon strategy across different layers of the stack as these systems get more specialized.

One supplier can help on the main accelerator path. Another can help on memory-side bottlenecks. Others can help elsewhere in the rack. That creates a broader and more distributed custom silicon landscape than a simple one-winner narrative, and this Marvell report fits neatly into that picture.

---

*The information provided is for informational purposes only and does not constitute investment advice, a recommendation, or an offer to buy or sell any securities. The author may hold a position in the securities mentioned. Readers should conduct their own due diligence and consult with a financial advisor before making investment decisions.*
