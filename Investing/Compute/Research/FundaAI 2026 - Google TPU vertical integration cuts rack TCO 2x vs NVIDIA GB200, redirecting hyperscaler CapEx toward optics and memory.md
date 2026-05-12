---
created: 2026-05-12
published: 2026-04-14
description: Anthropic's multi-gigawatt TPU expansion plus a 2x rack-BOM advantage for TPU v7 over NVIDIA GB200 NVL72 frees CSP CapEx to scale the optics, memory, and high-dimensional networking that AI Agents now demand.
source: https://fundaai.substack.com/p/deepai-infra-2026-shifting-from-brain
type: research
authors: ["FundaAI (@fundaai)"]
---

# FundaAI 2026 - Google TPU vertical integration cuts rack TCO 2x vs NVIDIA GB200, redirecting hyperscaler CapEx toward optics and memory

## Key Takeaways

- **Networking has overtaken raw FLOPS as the binding constraint on Agent Scaling.** MoE All-to-All traffic alone leaves chips idle >1/3 of the time when networking lags, and GShard data shows All-to-All's share of execution time jumps from 16% to 36% as experts scale 128 → 2,048. The bull case for [[Alphabet (GOOGL)]] is that TPU's full-stack co-design (silicon → ICI → OCS → DCN) attacks this exact bottleneck — pushing OCS port-to-chip ratio from 1.5:1 toward 10:1 and migrating from 3D Torus to 4D+ topologies, which explicitly grows networking's wallet share at compute's expense.
- **Anthropic moving its training core to TPU is the loudest endorsement yet of ASIC-vs-GPGPU economics.** The April-2026 Anthropic/[[Alphabet (GOOGL)]]/[[Broadcom (AVGO)]] expansion adds multiple gigawatts on top of the previously-announced 1mn TPU plan, with Claude Mythos reportedly trained on TPU and pushing exploit success on extreme cybersecurity tests from ~0% (Opus) to 72.4%. Two of the world's top three frontier models (Gemini, Claude) now run on TPU — directly contradicting the "[[Nvidia (NVDA)]] CUDA moat is unbreachable" frame at the training-CapEx layer.
- **TPU v7 rack BOM is ~$1.5mn vs ~$3.2mn for GB200 NVL72, with [[Nvidia (NVDA)]] gross profit alone accounting for $1.7mn (>50% of the GB200 rack cost).** Vertical integration compresses the chip-vendor margin layer from $1.7mn → ~$0.4mn (Brcm gross profit on TPU v7), unlocking ~$1.7mn per rack of CSP CapEx headroom that flows into optics, memory, and networking — i.e., the segments where Agent inference is actually constrained. This is the structural mechanism by which the ASIC threat manifests as topline upside for the Photonics + Memory supply chain rather than as deflation in the overall AI infra TAM.
- **Supply, not demand, will set 2027 TPU shipments — and the constraint is CoWoS at [[TSMC (TSM)]] plus EMIB-T substrates at [[Intel (INTC)]].** FundaAI estimates 2027 TPU demand at 12mn units against a current supply check of ~7mn (CoWoS-bound). v8x ramps Q4 2026 at $4,500 ASP / 40% GM via MediaTek; v8e (9.5x reticle, 12 HBM4e) stays on EMIB-T and ramps Q4 2027 at $10,000 ASP, with Intel pre-paying [[Unimicron (3037.TW)]] and Ibiden for substrate capacity. The marginal beneficiary if [[TSMC (TSM)]]/MediaTek secure more CoWoS is everyone downstream — including HBM4e suppliers and OCS/optical-component vendors whose attach rate scales with TPU rack count.
- **The "LPU" inference architecture and Marvell as a second design partner signal where the TPU roadmap is defending and where it's diversifying.** Google is building a dedicated LLM-inference accelerator (its Groq-equivalent) explicitly to counter [[Nvidia (NVDA)]]'s post-Groq inference push, and is negotiating with [[Marvell (MRVL)]] as a MediaTek-style design service partner specifically for high-speed interconnect IP. Read this as: Google views training as defended (TPU + Anthropic captive), and is now hardening the inference layer where general-purpose GPUs are weakest on perf-per-watt for long-context Agent workloads.

## External Resources

- Original post: <https://fundaai.substack.com/p/deepai-infra-2026-shifting-from-brain> (paid)
- Cross-references: GShard MoE scaling experiments; Anthropic-Google 2026-04 multi-gigawatt agreement; OpenBSD browser-vulnerability exploit benchmark (Claude Mythos, 72.4% success)

## Original Content

> [!quote]- Source Material — FundaAI, "Deep|AI Infra 2026: Shifting from 'Brain Power' Competition to 'Whole-Body' Evolution" (2026-04-14)
>
> In 2026, the focus of AI development has pivoted from chasing high benchmark scores to pursuing AI Agents capable of multi-step reasoning and autonomous action. This infrastructure arms race is undergoing a transformation akin to biological evolution. If an AI system is viewed as an evolving organism: the GPU/TPU represents the calculating brain; Memory and Storage serve as the memory carriers for experience and context; the CPU acts as the hands coordinating tasks; while Optics and Networking function as the limbs supporting systemic data flow and response sensitivity. Under the framework of the Agent Scaling Law, the core bottleneck is no longer just the FLOPS of a single chip (brain power), but rather the communication efficiency (limbs), the memory wall (memory), and the Total Cost of Ownership (TCO).
>
> - **The "Brain" Idle Crisis:** Even with the most powerful compute cores, if the "limbs" (communication) are underdeveloped, chips will sit idle for over 1/3 of the time waiting for data.
> - **The "Memory" Retrieval Bottleneck:** Long-sequence reasoning for Agents imposes rigorous demands on KV Cache management; the performance of memory and storage components has become the deciding factor for an Agent's logical depth.
> - **Dimensional Evolution of "Limbs":** To overcome the communication bottlenecks inherent in MoE architectures, infrastructure is moving from 3D Torus toward high-dimensional topologies (up to 10D). Networking investment weight is now matching or even surpassing that of compute chips.
>
> This report outlines the bottlenecks facing AI Agents and recent TPU progress, specifically exploring how Google TPU optimizes "whole-body" coordination through vertical integration. We argue that:
>
> 1. **Networking is the new core battlefield:** To solve MoE All-to-All bottlenecks, Google is significantly expanding scale-out bandwidth and shifting from 3D Torus to higher dimensions.
> 2. **Unlocking TCO and Allocation Efficiency:** Through proprietary architecture and vertical integration, the TPU v7 rack cost is significantly lower than the NVIDIA GB200. This efficiency gain frees up CapEx for growth in optical communications and memory.
>
> ---
>
> ## Agent Scaling Law
>
> #### **Networking as the "Invisible Processor": MoE and All-to-All Bottlenecks**
>
> As AI Agents increasingly adopt MoE architectures, model operations frequently trigger "expert dispatch" and "expert aggregation". This shifts communication patterns from traditional All-Reduce to All-to-All modes that are extremely dependent on bisection bandwidth. GShard experimental data shows that when the number of experts scales from 128 to 2,048, the proportion of All-to-All communication in total execution time jumps from 16% to 36%. Consequently, even with the fastest XPU, chips remain idle for over one-third of the time if networking lags. Furthermore, traditional 3D Torus bisection bandwidth only grows at N^(2/3) during node expansion, leading to congestion at the intermediate network layers as scale increases.
>
> To break this bottleneck, we expect Google is enhancing Networking and Optics bandwidth across two dimensions: increasing DCN scale-out bandwidth in the 1-2 year term, and pushing from 3D Torus to 4D or higher dimensions in the longer term, raising the OCS port-to-chip ratio from 1.5:1 to as high as 10:1. This underscores that networking investment is now equal to or greater than compute.
>
> #### **The Memory Wall and KV Cache: "Long-term and Short-term Memory"**
>
> The Agent Scaling Law emphasizes long-duration, multi-step reasoning, placing stringent requirements on KV Cache management. To support massive compute expansion, CSPs are aggressively procuring memory and optical components. Notably, Google is developing high-performance inference accelerators (similar to LPUs) to counter NVIDIA's market expansion following its acquisition of Groq technology. This suggests that general-purpose GPUs may no longer be the optimal solution for the performance-per-watt requirements of frequent, long-context Agent inference.
>
> #### **Cost Structure and Vertical Integration Efficiency**
>
> Under the economic scale of Agent Scaling, simply stacking expensive GPUs lacks CapEx allocation efficiency. This massive cost disparity has led top-tier teams like Anthropic to shift their core training focus toward the TPU architecture. When models (such as Claude Mythos) demonstrate significantly stronger performance in complex logic tests than their predecessors, it validates that optimizing TCO via proprietary architecture and vertical integration drives Agent performance leaps more effectively than relying solely on flagship GPUs.
>
> #### **System-level "Goodput" as the True Metric**
>
> Success under the Agent Scaling Law is defined by Data-center-level Goodput (effective throughput). In massive clusters, a single point of failure (e.g., fiber failure) can interrupt training in traditional architectures. Next-generation TPU networks provide multi-path redundancy via DCN Clos topologies and support traffic failover to DCN if ICI links fail. Because Agent iteration depends on all "experts" completing their computation, high-dimensional networks shorten the worst-case path (Tail Latency), preventing individual slow nodes (Stragglers) from bottlenecking the entire system.
>
> #### **Summary**
>
> In 2026, compute is no longer the sole variable limiting AI evolution. Breakthroughs in Dimensionality, Bisection Bandwidth, and the Memory Wall are the true keys to achieving Agentic capabilities. As shown by the Anthropic-Google partnership, future competition will be defined by full-stack collaborative optimization rather than a mere war of chip specifications.
>
> ---
>
> ## TPU Dynamics
>
> #### **Anthropic Expands TPU Utilization**
>
> In early April 2026, Anthropic signed a new agreement with Google and Broadcom to procure multiple gigawatts of next-generation TPU compute, expected to go online starting in 2027. This expands upon Anthropic's previous plan for 1 million TPUs announced last October. For Anthropic, this move supports their push past $30 billion in ARR. By leveraging the vertical integration of Google Cloud infra and Broadcom's custom silicon capabilities, Anthropic gains advantages in compute stability and cost-performance, signaling a decisive shift of their training core toward the TPU architecture.
>
> The TPU advantage is already evident in top-tier model competition. We believe Claude Mythos was trained on TPU architecture, meaning two of the world's top three models (Gemini and Claude) now utilize TPU as their core compute foundation. Mythos' performance in complex logic validates this: in extreme cybersecurity testing, its exploit success rate jumped from nearly 0% (Opus) to 72.4%, accurately identifying deep-seated browser vulnerabilities that had remained hidden in OpenBSD for 27 years.
>
> #### **TPU v8x (Zebrafish): On Track for Q4 2026 Ramp**
>
> TPU v8x faced several months of delay in 2025H2 due to a tape-out failure, but is now in risk production with a ramp expected in 2026Q4. We currently project 400k units of v8x shipments for 2026. For 2027, while CoWoS supply (allocation to be confirmed mid-2026) suggests a baseline of 2.5mn units, our supply chain checks indicate Google/MediaTek are targeting 4-5mn TPUs worth of CoWoS allocation. Feedback from cooling vendors even slightly exceeds these figures; thus, if MediaTek secures more CoWoS capacity, 2027 v8x shipments could see further upward revisions.
>
> - ASP: v8x pricing has been revised upward to $4,500/unit.
> - Gross Margin: Estimated at 40%.
>
> #### **TPU v8e (Humufish): Utilizing EMIB-T; Intel Actively Securing Substrates**
>
> Despite rumors in Taiwan of a switch to CoWoS, we believe TPU v8e will remain on EMIB-T. The market likely confused v8e with MediaTek's CoWoS-based backup design; v8x and v8e are the finalized designs. We view a switch as highly unlikely due to: 1) The massive die size (9.5x reticle size: 4 compute dies, 4 IO dies, 12 HBM4e) currently necessitates EMIB-T. 2) Google's prepayments to Intel to secure capacity. We project 300k units in 2027Q4 and 2.2mn units for full-year 2028.
>
> - ASP: Estimated at $10,000/unit.
> - Supply Chain: Substrate remains the primary bottleneck; Intel is actively securing capacity from Unimicron and Ibiden.
>
> #### **New Design Vendor: Marvell**
>
> Google is actively negotiating TPU development projects with Marvell, who would play a design service role similar to MediaTek. Google's intent is to diversify its vendor base and leverage Marvell's strengths in high-speed interconnects to optimize cost and performance. These projects are currently in early-stage specification definition.
>
> Additionally, Google is accelerating a dedicated inference architecture (Google's version of an LPU) optimized for LLMs to counter NVIDIA's push into the high-performance inference market via Groq. This new inference accelerator is also within the scope of discussions with Marvell.
>
> #### **TPU Shipment Update**
>
> For 2027, we estimate TPU demand at 12mn units. However, the supply side (particularly total CoWoS capacity) remains a significant gap, with current supply chain checks suggesting shipments closer to 7mn units. This massive supply-demand imbalance means that despite Google's strong pull-in intent, critical component bottlenecks will ultimately dictate final shipment levels.
>
> *[Image — Google TPU MP schedule and shipment table; transcribed verbatim below]*
>
> **Google TPU MP Schedule**
>
> | Generation | Code name | Design | Compute die node | # of Compute die | Compute die size (mm²) | 2025 | 2026 | 2027 | 2028 |
> |---|---|---|---|---|---|---|---|---|---|
> | TPU v7 | Ironwood | BRCM | 3nm | 2 | 600 | MP | | | |
> | TPU v8x | Zebrafish | MTK | 3nm | 1 | 400 | | MP in H2 | | |
> | TPU v8ax (or v8p) | Sunfish | BRCM | 3nm | 4 | 490 | | MP | | |
> | TPU v8e | Humufish | MTK | 2nm | 4 | 490 | | | MP in H2 | |
> | TPU v9p | Pumafish | BRCM | 2nm | 8 | 510 | | | MP | |
> | TPU v9e | | MTK | 2nm | 12 | 500? | | | | MP |
>
> **Google TPU shipment (mn)**
>
> | Generation | Design | Node | # Compute die | Die size (mm²) | 2026 | 2027 | 2028 |
> |---|---|---|---|---|---|---|---|
> | TPU v7 | BRCM | 3nm | 2 | 600 | 2.0 | | |
> | TPU v8x | MTK | 3nm | 1 | 400 | 0.4 | 2.5 | |
> | TPU v8ax (or v8p) | BRCM | 3nm | 4 | 490 | 1.0 | 4.2 | |
> | TPU v8e | MTK | 2nm | 4 | 490 | | 0.3 | 2.2 |
> | **Total** | | | | | **3.4** | **7.0** | |
>
> Source: Company documents, FundaAI
>
> #### **Rack-Level Cost Analysis: NVIDIA GPU vs. TPU**
>
> Analysis of Rack-level BOM reveals that the NVIDIA GB200 NVL72 costs approximately $3.2 million, with NVIDIA's GPGPU gross profit accounting for $1.7 million (over half the rack cost). In contrast, a Google TPU v7 rack costs roughly $1.5 million, with design partner margins totaling only about $0.4 million. This highlights how TPU's self-developed architecture and vertical integration significantly optimize TCO. This cost disparity will likely force GPGPU vendors to face margin pressure and ultimately improve CSP CapEx allocation efficiency. CSPs can reallocate the excess premiums previously paid to chip vendors toward critical components for scaling—specifically optical networking and storage essential for AI Agents—making the AI infrastructure supply chain more resilient with further upside potential.
>
> *[Image — GB200 NVL72 vs TPU v7 rack-level BOM comparison; transcribed verbatim below]*
>
> **GB200 NVL72 Rack Level BOM ($k)**
>
> | Component | NVIDIA GB200 NVL72 |
> |---|---|
> | CPU Wafer Cost | 90 |
> | CPU DRAM | 150 |
> | **CPU (36 Grace CPUs)** | **240** |
> | HBM | 180 |
> | GPU Wafer Cost | 160 |
> | Nv Gross Profit | 1,728 |
> | Others | 236 |
> | **GPU (72 B200s)** | **2,304** |
> | Networking | 500 |
> | Others | 200 |
> | **Rack Total BOM ($k)** | **3,244** |
>
> **TPU v7 Rack Level BOM ($k, take 64-TPU rack as example)**
>
> | Component | Google TPU v7 (Ironwood) |
> |---|---|
> | CPU Cost | 40 |
> | Others (DRAM, …) | 144 |
> | **CPU (16 CPUs)** | **184** |
> | HBM | 160 |
> | GPU Wafer Cost | 51 |
> | Brcm Gross Profit | 422 |
> | Others | 134 |
> | **TPU (64 TPUs)** | **768** |
> | Networking | 400 |
> | Others | 150 |
> | **Total Internal BOM ($k)** | **1,502** |
>
> Source: Company documents, FundaAI
>
> #### **Risk Factor: Execution Risks for New Entrants**
>
> Despite high expectations for TPU v8x, initial execution risks must be monitored. As this is MediaTek's first foray into the AI ASIC space, there is a "running-in" period for architectural optimization and hardware-software coordination; performance may initially miss benchmarks. Given the 2025H2 tape-out delays, investors should closely track real-world feedback following the 2026Q4 volume ramp.
>
> ---
>
> ## Next-Generation TPU Network Topology Evolution and Optics Implications
>
> Networking is TPU's primary competitive advantage. Since the first-generation TPU, Google has prioritized cost, energy, and performance, later focusing on performance per TCO during productization. Interconnect is the main driver: TPU v4 introduced OCS reconfigurable interconnect to improve scale, availability, and utilization. As workloads like MoE increased communication demands, Google enabled near-linear scaling from a single pod to hundreds of thousands of TPU chips using Multislice and Pathways. TPU's advantage lies in full-stack co-optimization, from silicon and interconnect to runtime and datacenter network, with a consistent focus on data-center-level goodput, scalability, and cost-efficiency.
>
> This section examines the next stage of TPU network topology evolution and its impact on optics demand.
>
> *[Note: Original post terminates here for non-paying readers with a "Subscribe" CTA. The substack auth used to fetch this post returned the same truncation point — i.e., the "Next-Generation TPU Network Topology Evolution and Optics Implications" section preview is the full extent of the public/visible content as of 2026-04-14. Charts, supplemental tables, and the body of this final section appear to be paywalled below the visible boundary or were not rendered for the fetched session.]*
