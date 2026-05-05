---
created: 2026-05-05
published: 2025-07-18
description: Celestial AI technical paper detailing the Photonic Fabric Platform - 16-XPU shared-memory appliance with up to 32TB unified address space, 115Tbps all-to-all photonic switching at radix-16, and 7.2Tbps optical port bandwidth per Photonic Fabric Module.
source: https://arxiv.org/abs/2507.14000
type: research
authors: ["Jing Ding (Celestial AI)", "Trung Diep (Celestial AI)"]
---

# Celestial Photonic Fabric Platform for AI Accelerators

This is the technical primary source from Celestial AI engineers Jing Ding and Trung Diep describing the Photonic Fabric Module (PFM) and Photonic Fabric Appliance (PFA) — the architecture underlying the [[Penguin Solutions (PENG) is the named chassis builder for the Marvell-Celestial AI photonic memory appliance shipping late 2026 - Pennycheck thesis]] for [[Penguin Solutions (PENG)]] and [[Marvell Technology (MRVL)]]. Every quantitative claim in the photonic-memory thesis — 32 TB shared memory, 115 Tbps all-to-all switching, radix-16 across 16 XPUs, 7.2 Tbps optical-port bandwidth per module, GeSi EAM modulators, HBM3E + DDR5 two-tier memory — is sourced here. The paper's headline simulation results (3.66x throughput / 1.40x latency at 405B params, 7.04x throughput / 1.41x latency at 1T params, 60-90% energy savings on collective operations, 22.8x DLRM speedup) are simulated via Celestial's own analytical model CelestiSim, validated against H100/H200 microbenchmarks but not yet against PFA silicon — an important caveat the paper itself flags in Section 9.

## Key Takeaways

- **The headline spec is "up to 32 TB" of shared memory across 16 XPUs, not 33 TB.** The Pennycheck/Gazettabyte thesis cites 33 TB; the paper consistently states "up to 32 TB of shared memory capacity at full HBM3E bandwidth." Each Photonic Fabric Module carries 2x HBM3E stacks of 36 GB plus up to 2 TB of external DDR5, with 16 modules per appliance — so 16 x 2 TB = 32 TB ceiling. The 33 TB figure in the thesis appears to be a rounding/quotation discrepancy worth flagging when re-reading the [[Penguin Solutions (PENG) is the named chassis builder for the Marvell-Celestial AI photonic memory appliance shipping late 2026 - Pennycheck thesis]].
- **115 Tbps all-to-all switching at radix-16 with 7.2 Tbps optical port bandwidth per PFM.** The PFA is a single rack-mountable scale-up domain joining 16 XPUs via photonic crossbar; each Photonic Fabric Module exposes 7.2 Tbps of optical-port bandwidth (this is the per-module, per-direction figure quoted in [[Marvell Technology (MRVL)]] CPO commentary). Multiple PFAs can tier to 128 or 256 XPUs. Next-gen roadmap quadruples per-link bandwidth from 7.2 to 28.8 Tbps via PAM4 + 8-wavelength WDM and expands ports from 16 to 64.
- **The paper claims qualitative "low latency" but does not publish a sub-250ns remote-memory figure.** The latency claims in the paper are *speedup ratios* (1.40x at 405B, 1.41x at 1T) versus DGX-H100 baselines — not absolute nanosecond latencies. The "sub-250ns" number repeated in third-party coverage of the photonic-memory thesis is NOT directly stated in this arxiv paper; it must come from a Celestial press release, OFC presentation, or analyst note. Worth tracking down a primary source for that specific figure before relying on it in the [[Penguin Solutions (PENG)]] thesis.
- **GeSi EAMs over Mach-Zehnder and micro-rings is the core technical differentiator.** Germanium-Silicon Electro-Absorption Modulators give Celestial sub-100μm device sizes with thermal stability that micro-ring resonators lack. This lets the PIC act as carrier for a co-packaged ASIC fabricated in 4-5nm CMOS, eliminating DSP and drastically cutting power versus Long-Reach SerDes. Energy assumptions baked into the simulations: 5 pJ/bit for photonic transceivers and 25 pJ/bit for photonic switches versus 65/35/50 pJ/bit for generic adapters/switches/NVLink — that ~3-7x per-bit advantage drives the 60-90% communication-energy savings claim.
- **The architecture's economic punch is collapsing tensor parallelism.** PFA's MFU on a (128, 4096) workload at 405B reaches 49.7% versus 13.6% for DGX-H100 because the unified shared memory eliminates TP-induced redundant memory accesses and all-reduce overhead. All-reduce alone accounts for 37-50% of decode-phase overhead at TP=2/4/8 in the H100 baseline. This is what enables [[Penguin Solutions (PENG)]] to be sold as a memory-tier product rather than a compute product — the unit-of-sale thesis.

## External Resources

- [arXiv abstract page (canonical source)](https://arxiv.org/abs/2507.14000)
- [arXiv PDF](https://arxiv.org/pdf/2507.14000)
- Megatron-LM (Shoeybi et al. 2019) — base programming model assumed by CelestiSim: <https://doi.org/10.48550/ARXIV.1909.08053>
- NVIDIA ConnectX-6/-7 user manuals — power-cost references (65 pJ/bit adapter assumption)
- NVIDIA Spectrum-3 SN4000 / QM9700-9790 InfiniBand switch manuals — switch power-cost references (35 pJ/bit assumption)
- Calculon (Isaev et al. 2023), vTrain (Bang et al. 2024), ASTRA-sim (Rashidi et al. 2020), DeepFlow (Ardalani et al. 2024), LLMServingSim (Cho et al. 2024), Vidur (Agrawal et al. 2024) — prior simulator art that CelestiSim builds upon

## Original Content

> [!quote]- Source Material — arXiv 2507.14000 (Ding & Diep, Celestial AI)
>
> ## ABSTRACT
>
> This paper presents the Photonic Fabric TM and the Photonic Fabric Appliance TM (PFA), a photonic-enabled switch and memory subsystem that delivers low latency, high bandwidth, and low per-bit energy. By integrating high-bandwidth HBM3E memory, an on-module photonic switch, and external DDR5 in a 2.5D electro-optical system-in-package, the PFA offers up to 32 TB of shared memory alongside 115 Tbps of all-to-all digital switching. The Photonic Fabric TM enables distributed AI training and inference to execute parallelism strategies more efficiently.
>
> The Photonic Fabric removes the silicon beachfront constraint that limits the fixed memory-to-compute ratio observed in virtually all current XPU accelerator designs. Replacing a local HBM stack on an XPU with a chiplet that connects to the Photonic Fabric increases its memory capacity and correspondingly its memory bandwidth by offering a flexible path to scaling well beyond the limitations of on-package HBM alone.
>
> We introduce CelestiSim, a lightweight analytical simulator validated on NVIDIA H100 and H200 systems. It is used to evaluate the performance of LLM reference and energy savings on PFA, without any significant change to the GPU core design. With the PFA, the simulation results show that up to 3.66x throughput and 1.40x latency improvements in LLM inference at 405B parameters, up to 7.04x throughput and 1.41x latency improvements at 1T parameters, and 60-90% energy savings in data movement for heavy collective operations in all LLM training scenarios. While these results are shown for NVIDIA GPUs, they can be applied similarly to other AI accelerator designs (XPUs) that share the same fundamental limitation of fixed memory to compute.
>
> ## CCS CONCEPTS
>
> - Hardware · Emerging technologies · Analysis and design of emerging devices and systems · Emerging architectures
>
> ## KEYWORDS
>
> Interconnect, photonics, memory, machine learning system performance
>
> ## Photonic Fabric Platform for AI Accelerators
>
> Jing Ding — Celestial AI, Santa Clara CA — jding@celestial.ai
>
> Trung Diep — Celestial AI, Santa Clara CA — tdiep@celestial.ai
>
> ## 1 Introduction
>
> Over the past decade, rapid advancements in Artificial Intelligence (AI), particularly Generative AI (GenAI), have highlighted significant challenges in current hardware's ability to keep pace with model scaling. While the model sizes have grown exponentially with many open-source and proprietary models now exceeding multiple-trillion parameters, hardware capabilities remain limited by comparatively linear scaling laws. Photonics is widely viewed as a promising technology for the next generation of high-speed, high-bandwidth interconnects, and its comparative benefits over more traditional electronic solutions are forcing substantial changes in production-scale environments.
>
> In this paper, we address the critical overheads introduced by interconnects in data center AI workloads, including large language model (LLM) training and inference as well as deep learning recommendation model (DLRM) inference. We introduce the Photonic Fabric Appliance™ (PFA), a rack-mountable cluster-scale storage system with up to 32 TB of shared memory capacity at full HBM3E bandwidth, complemented by 115 Tbps of all-to-all digital switching with a radix of 16. This appliance integrates with the Photonic Fabric TM to overcome the silicon beachfront constraint that limits the fixed memory-to-compute ratio in conventional XPU accelerators.
>
> To demonstrate these benefits, we use NVIDIA H100 and H200 GPUs as a case study by developing a parameterized analytical simulator tailored for high-level software-hardware co-design studies, tailored to model LLM training and inference processes. The simulator also incorporates energy and power estimates based on data transfer calculations. With this simulator, we demonstrate PFA's performance improvements across AI workloads. Compared to conventional NVLink with NVSwitch networking, the PFA is projected to achieve up to 3.66x throughput and 1.40x latency improvements in inference for a 405-billion parameter model, and up to 7.04x throughput and 1.41x latency improvements for a 1-trillion parameter model. For heavy collective operations in training using scale-out networking technology such as InfiniBand, the PFA can reduce energy consumption by 60-90%. Additionally, the PFA achieves 22.8x higher performance than GPUs with NVLink for DLRM inference. These results indicate the PFA's potential to overcome memory bottlenecks, scale efficiently, and enable next-generation AI deployments on a broad range of AI accelerators. While these results are shown for NVIDIA GPUs, they can be applied similarly to other AI accelerator designs that share the same fundamental limitation of fixed memory to compute.
>
> ## 2 Background
>
> Balancing between compute intensity and sufficient memory performance to feed data to the compute units is key to achieving peak efficiency. In this section, we explore the balancing act that takes place to coordinate between compute and memory demands especially across multiple networked nodes and provide motivations for current state-of-the-art networking strategies.
>
> ### 2.1 Current Scale-out and Scale-up Networks
>
> Historically, two primary strategies have been used to handle the growing scale of AI workloads: scale-up architectures, which concentrate resources in more capable single-node systems; and scale-out architectures, which distribute workloads across multiple interconnected nodes. Both approaches now face increasing pressure due to the rapid growth in model size and training corpora.
>
> In *scale-up* systems, one equips individual servers with high performance accelerators (XPUs, TPUs, or custom ASICs) and large pools of high-bandwidth memory (HBM), along with substantial CPU-attached DRAM. This design reduces latency for parameter retrieval and activation storage by placing more memory and compute resources on a single node. However, even sophisticated node-level memory hierarchies — leveraging HBM stacks, large on-die caches, and NUMA-balanced DRAM configurations — have inherent scaling and efficiency limitations. Similar constraints apply to near-memory or in-memory compute, or packaging techniques like 3D stacking and chiplets. Ultimately, the scale of modern AI workloads pushes beyond the feasible capacity, bandwidth, and cost-effectiveness of the most advanced single-node architectures.
>
> For these tasks, a single node, even a heavily provisioned one, just cannot hold all parameters, activations, and cached artifacts. For this, one requires *scale-out* architectures, which partition the model and data across many nodes interconnected through high-performance fabrics, such as InfiniBand and RoCE-based Ethernet. The cost of this increased capacity is the introduction of complex memory access patterns and significant inter-node communication overhead. Models with large attention mechanisms, or large embedding tables, generate bursty, high-bandwidth traffic that can overwhelm network links and switches. Ensuring sustained performance at scale requires careful coordination between memory placement, parallelization strategies, and routing algorithms that mitigate congestion and load imbalance. Techniques such as hierarchical parallelism by combining tensor, data, pipeline, or expert (agent) partitioning become essential. Software-managed caching and compression schemes can reduce per-node memory footprints and network load, while integrated collective libraries co-tuned with the network stack minimize synchronization overheads.
>
> ### 2.2 Illusion of a Scale-up Network
>
> As shown in Table 1, scale-out and scale-up networks serve fundamentally different operational goals. Using remote direct memory access (RDMA) semantics (implemented over InfiniBand or Ethernet RoCE) to emulate a scale-up environment on top of a scale-out architecture has limitations. InfiniBand's two-sided verbs (e.g., send and receive) require both communication end points, while RDMA's one-sided verbs (e.g., read and write) require only the source communication point, retrieving or placing data in remote memory without notifying or involving the target. RDMA verbs follow a non-blocking, asynchronous I/O model by issuing a completion signal in the completion queue. The capability to implement RDMA verbs on InfiniBand or Ethernet is made possible by introducing custom software into the RDMA-enabled NIC (RNIC). Much of the networking software that is traditionally executed in a kernel on a CPU can be bypassed by adding data buffers in the RNICs to transfer data without involving the CPUs nor the GPUs to remove network software stack overhead. In a Clos-style, multi-stage, non-blocking networks, overall throughput typically scales with the number of active bandwidth-sensitive traffic flows, yet congestion remains a concern: latency-sensitive traffic is not intrinsically protected from bulk bandwidth-intensive traffic. The use of virtual lane and virtual lane arbitration help to provide per-flow performance differentiation, but multiple factors as well as the imbalance between bandwidth and latency sensitive traffic can pose fairness issues that make achieving low latency and high bandwidth at the same time difficult.
>
> *Table 1: Scale-up vs. scale-out networking characteristics.*
>
> | Characteristics | Scale-out Network | Scale-up Network     |
> |-----------------|-------------------|----------------------|
> | Scalability     | Many millions     | Hundreds             |
> | Latency         | Higher            | Lower (flit-based)   |
> | Bandwidth       | Lower             | Higher               |
> | Data Delivery   | Best effort       | Deterministic        |
> | Reliability     | Lossless          | Retry possible       |
> | Distance        | Long distance     | Short point to point |
> | Software        | Ubiquitous        | Custom               |
> | Cost            | Cheaper           | More expensive       |
>
> ### 2.3 Memory Demands of AI Workloads
>
> Training LLMs involves frequent collective operations that synchronize parameters and gradients across thousands of XPUs. These operations generate bursty, high-bandwidth traffic patterns that can saturate memory and network resources, making consistent performance and throughput difficult to sustain. The challenges of scaling up LLMs to tens of thousands of XPUs, as demonstrated in large-scale deployments like Meta's RoCE-based backend clusters, underscore the complexity of routing and congestion control. Load imbalances, microburst, and low-entropy traffic patterns all demand careful codesign of hardware and software stacks.
>
> Although inference does not involve gradient updates, it still requires rapid access to large parameter sets, can struggle with latency and bandwidth constraints, and requires adaptable load balancing. Hardware like the NVIDIA H100 GPU provides 989 TFLOPS of dense FP16 compute and a memory bandwidth of 3350 GB/s, implying a peak arithmetic intensity near 295 FLOPS/byte. Balancing compute and memory operations here is complicated by how arithmetic intensity fluctuates with batch size, context length, and the prefill or decoding phases of LLM inference.
>
> Figure 1 characterizes the arithmetic intensity of LLaMA-70B inference in FP16 precision, demonstrating the contrasting behaviors between the prefill and decode phases. In the prefill phase (left), arithmetic intensity scales with batch size and initially increases with input length, reflecting higher compute requirement as workloads grow. However, beyond an input length of ~10,000 tokens, arithmetic intensity begins to decline. This is due to the growing dominance of memory-bound operations in the attention mechanism, which cannot be fully mitigated by memory access optimizations. In the decode phase (right), arithmetic intensity is significantly lower and exhibits a different trend. It increases with batch size but decreases as the key-value (KV) cache length grows. This is driven by the rising cost of KV memory accesses, which scale with sequence length, and quickly dominate the execution time, exhibiting the memory bandwidth bottlenecks in this phase.
>
> These trends emphasize a key systems challenge: the arithmetic intensity of LLM inference workloads varies significantly across phases and input configurations, making it difficult to align with the fixed operational intensity of XPUs. This variability complicates resource provisioning and motivates the need for adaptive runtime scheduling, memory hierarchy design, and architectural support to maintain high utilization across diverse LLM inference workloads.
>
> *Figure 1: Arithmetic intensity in prefill phase (left graph) and decode phase (right graph).*
> ![[celestial-pfa-arxiv-001.png]]
>
> ## 3 Photonic Fabric Appliance TM
>
> As both scale-up and scale-out solutions push their practical limits, new interconnect technologies like Celestial AI's Photonic Fabric TM provide a path forward. By providing higher bandwidth densities, more flexible interfacing with compute units, and lower energy per bit transferred, these interconnects can mitigate the complexity of multiple communication collective patterns. On-node photonic integration also provides flexible options for interfacing with larger pools of memory, in turn making it easier to balance performance and avoid capacity-related bottlenecks.
>
> ### 3.1 The Need for Photonics Connectivity
>
> The Photonic Fabric Appliance TM (PFA) unlocks a much larger pool of memory and bypasses the memory wall. It is a memory and compute interconnectivity and disaggregation platform operating at 56 Gbps line-rate and providing up to 32 TB of shared memory capacity at full HBM3e bandwidth across a scale-up network of 16 XPUs. The main building block of PFA is the Photonic Fabric Module TM (PFM), shown in 2, which comprises an active photonic interposer codesigned with an advanced Application-Specific Integrated Circuit (ASIC) and two HBM3e stacks and an in-built 8 Tbps network switch in a 2.5D package. Interconnected together, 16 PFMs form a PFA, supporting all-to-all digital switching capability with a radix of 16. The front fiber ports serve as an interface for up to 16 XPUs, as shown in Figure 3, providing all-to-all networking capability along with a unified shared memory address space.
>
> *Figure 2: A module in a PFA.*
> ![[celestial-pfa-arxiv-002.png]]
>
> ### 3.2 Active Photonic Interposer
>
> The advantage of PFM compared to other solutions relying on photonics for interconnectivity is its exceptional thermal stability, bandwidth density and energy efficiency. The choice of Germanium-Silicon (GeSi) Electro-Absorption Modulators (EAMs) as opposed to Micro-Ring Resonators allows the Photonic Integrated Circuit (PIC) to act as a carrier for a custom ASIC without the link being compromised by thermal dissipation and/or variable temperature gradients. In addition, unlike Mach-Zehnder Modulators, which are also thermally stable, EAMs offer the benefit of compact sub-100μm sizes, thereby providing extremely high package bandwidths. The use of a separate PIC and ASIC that are co-packaged using standard 2.5D/3D assembly techniques, allows the use of advanced 4- and 5nm CMOS nodes for state-of-the-art co-designed Analog/Mixed Signal (AMS) macros and enables the inclusion of the Serializer/De-serializer (SerDes) within the fabric. It also eliminates the need for Digital Signal Processing (DSP) and drastically reduces overall power consumption when compared to Long-Reach (LR) SerDes.
>
> The second generation of our system demonstrator relying on Photonic Fabric™ remains architecturally the same as the first one, reported in [10] and [11], but comes with several performance improvements obtained from a series of upgrades at all layers of abstraction, including devices, subsystems and control schemes.
>
> ### 3.3 PFA Specifications
>
> The Celestial AI PFA is a rack-mountable cluster-scale appliance that supports up to 32 TB of shared memory capacity at full HBM3 bandwidths along with 115 Tbps of all-to-all digital switching capability with a radix of 16. Each PFA incorporates 16 PF modules, as shown in Figure 2. The PF module is a memory fabric & switch ASIC packaged in a 2.5D electro-optical systems-in-package (SIP) with 2x HBM3E stacks of 36 GBs on a photonic IC (PIC) interposer. Each PF module supports up to 2 TB of DDR5 memory capacity with HBM3E acting as write-through cache for the DDR5.
>
> For the purposes of this work, the PFA is configured as an 8 or 16 XPU Cluster, as shown in Figure 3. The PFA has optical port bandwidth of 7.2 Tbps per Photonic Fabric Module, with all-to-all switching totaling 115Tbps per PFA. Additionally, the PFA has embedded memory with each of the 16 attached XPUs having access to the 32 TB of shared DDR5 capacity at HBM3e bandwidths. Additionally, multiple PFAs can be tiered to expand the cluster size to 128 or 256 XPUs with a corresponding increase in the shared memory capacity.
>
> *Figure 3: Connectivity of XPUs with PFA*
> ![[celestial-pfa-arxiv-003.png]]
>
> ### 3.4 Memory Subsystem Architecture
>
> A key benefit of the Photonic Fabric TM is its ability to expand the available memory capacity for each XPU or GPU optically connected to a Photonic Fabric Module TM. This overcomes the rigid memory-to-compute ratio observed in most current accelerator designs. For example, while an H100 SXM GPU features a highly capable FP8 tensor core (3,958 TFLOPS) paired with only 80 GB of HBM, its successor, the H200 SXM GPU, increases the HBM capacity to 141 GB due to the limited amount of silicon beachfront available. By contrast, replacing a local HBM stack on an XPU or GPU with a chiplet that connects to a Photonic Fabric Module TM increases its memory capacity to 2 TB without necessarily consuming silicon beachfront. As additional modules are added, each accelerator can seamlessly grow its memory capacity to 4TB or 6TB and correspondingly its memory bandwidth, offering a flexible path to scaling well beyond the limitations of on-package HBM alone.
>
> Another important Photonic Fabric TM implication is the ability to share memory across multiple XPUs or GPUs. As shown in Figure 4, combining 16 Photonic Fabric TM modules along with a crossbar in a Photonic Fabric Appliance TM that can support any connection from any of the Photonic Fabric TM port to any of the Photonic Fabric TM ICs that are directly connected to their respective HBMs, which can provide data at HBM bandwidth while backed by the bigger DDR memory. The ability to share memory across multiple XPUs or GPUs simplifies many of the collective operations required for communicating data that are distributed and stored in individual XPUs or GPUs. For example, in an all-reduce communication collective which aggregates data from multiple XPUs or GPUs and subsequently scatters across the XPUs or GPUs in multiple synchronized steps can be implemented easily by allowing the memory to be locally addressable by each and all XPUs or GPUs that would make up the communication collective.
>
> *Figure 4: Memory architecture of the PFA*
> ![[celestial-pfa-arxiv-004.png]]
>
> ## 4 Simulation Framework: CelestiSim
>
> Accurately modeling LLM workloads on emerging architectures particularly those with disaggregated memory and non-traditional interconnects — requires a simulator that is both hardware-aware and fast enough for iterative co-design exploration. To this end, we developed CelestiSim, a lightweight analytical simulator tailored for transformer-based LLMs running on distributed systems with advanced memory subsystems such as PFA. CelestiSim builds upon foundational analytical modeling techniques [12,14,17] but introduces three key contributions to enable accurate performance and energy prediction for next-generation AI systems:
>
> 1. **Support for multi-tier disaggregated memory**: CelestiSim models interactions between on-module HBM3E and photonic-connected DDR5 memory. It incorporates a configurable caching strategy to capture the impact of memory hierarchy depth, latency, and bandwidth on LLM execution.
> 2. **Unified support for both training and inference modeling**: Unlike most simulators that focus on only one mode, CelestiSim models both LLM training and inference. It captures the compute- and memory-bound phases of inference, as well as the interplay of parallelism, communication overlap, and memory access patterns in training — enabling comprehensive analysis of hardware-software interactions across the full LLM lifecycle.
> 3. **Integrated power and energy modeling**: CelestiSim incorporates analytical energy models to estimate the cost of memory movement, compute operations, and interconnect communication — extending beyond performance prediction to evaluate system-level energy efficiency in LLM operations. This provides insight into the architectural trade-offs of designs like PFA.
>
> CelestiSim enables rapid, yet realistic, exploration of how performance and efficiency scale under novel architectures, including those with photonic switching fabrics. It is validated against empirical measurements on both NVIDIA H100 and H200 GPUs.
>
> ### 4.1 Framework Overview
>
> The simulator is a Python-based lightweight analytical performance model designed for high-level co-design of transformer-based LLMs and the hardware systems. It captures interactions among LLM specifications, system configurations, parallelization schemes, and operational modes (training, inference, or power), as shown in Figure 5.
>
> *Figure 5: CelestiSim Framework.*
> ![[celestial-pfa-arxiv-005.png]]
>
> The simulator adopts the flexible model structure of Megatron [1], compatible with architectures like GPT-2 [18], GPT-3 [19], GPT-4 [20], and LLaMA [21]. Transformer-based models are specified through parameters such as hidden size, attention heads, input sequence length, batch size, micro-batch size, and transformer blocks.
>
> System configurations specify distributed processor systems for matrix operations (e.g., general matrix multiplication) and vector operations. These configurations include FLOPs, input, weight, and output tensor sizes, as well as memory capacities, bandwidths, and efficiencies for different tiers of memory. To match real-world efficiency, we incorporated results from memory access microbenchmark and FLOPs utilization microbenchmark on H100 and H200 GPUs. Since the two GPUs share identical peak compute throughput, we treat their FLOPS utilization as equivalent. These benchmarks reveal fixed latencies for small message sizes and reduced FLOP efficiencies for smaller general matrix multiply (GEMM) operations, as shown in Figure 6. We also observed slightly lower memory bandwidth utilization on H200, likely due to memory controller buffer limitations. These empirical findings are integrated into CelestiSim to support realistic and architecture-aware performance modeling.
>
> *Figure 6: Memory access bandwidth utilization using different memory transfer sizes (left graph); FLOPS utilization of matrix multiplication on fp16/bf16 (right graph).*
> ![[celestial-pfa-arxiv-006.png]]
>
> The simulation framework incorporates data parallelism, pipeline parallelism, and tensor parallelism, configured in arbitrary combinations, and incorporates many strategies like data parallelism overlap, 1Forward-1Backward scheduling, sequence parallelism, and decomposing collectives to better hide latency. These optimizations are integrated into synchronous mini-batch stochastic gradient descent with an Adam optimizer. Importantly, CelestiSim factors its analysis out from each layer and ignores scheduling differences between layers. CelestiSim then provides detailed performance estimates and identifies novel hardware-software configurations for efficient LLM execution. It evaluates total efficiency as a function of system and computational efficiencies, enabling comprehensive exploration of design spaces at minimal computational cost.
>
> ### 4.2 Power Modeling
>
> The modeling formulates energy consumption as an average over all possible routes in the network, recognizing two main categories of hardware contributors: (1) adapters, such as network interface cards (NICs), GPU or CPU storage adapters, internal PCIe switches, NVLink adapters, and other endpoint interfaces; (2) switches and routers that process, forward, and buffer packets. Each transfer's total per-bit energy is the sum of the source adapter, intermediate switch, and destination adapter costs:
>
> $$E_{total} = E_{s.adapter} + \sum_{i=1}^{N} E_{switch_i} + E_{d.adapter}$$
>
> where N denotes the number of switches on a particular path. We assume a Clos network architecture comprising multiple racks, each comprising multiple trays, which in turn comprise multiple GPUs.
>
> Within this framework, there are three principal node-to-node communication scenarios: communication within a single tray (minimal switching), communication within a single rack (inter-tray but intra-rack routing), and inter-rack communication (involving multiple switches, commonly three). There are also two principal offloading communication scenarios: offloading to tray memory (involving GPU, CPU adapters, and potentially internal PCIe or NVLink switches) and offloading to an external data store via a frontend network, typically requiring 4 to 12 switches in the path (e.g., multiple ToR, aggregation, core, and SAN switches). Beyond these five communication scenarios, the path average allows quite general ad hoc adjustments for additional routing complexity or network heterogeneity.
>
> We assume that adapters and switch energies are parameterized by estimated per-bit costs: 65 pJ/bit for generic adapters, 35 pJ/bit for generic switches, and 50 pJ/bit for internal NVLink communication [28, 29, 30, 31]. Similarly, we assume energy costs of 5 pJ/bit for photonic transceivers, 25 pJ/bit for photonic switches, and 10 pJ/bit for intra-tray photonic communication.
>
> CelestiSim integrates the above energy modeling into its high-level analytic performance modeling. It simulates training at scale (e.g. tera- to peta-parameter LLMs) across clusters with thousands of GPUs, providing MFU-optimal parallelism strategies (including sizes of all tensor, pipeline, data parallelism clusters) and the bit counts of each data transfer associated with each of the five communication scenarios. By merging this data with the stochastic power model, we estimate cluster layout distributions as well as the resulting network-level probability distributions that enable aggregations of expected energy costs for entire workloads.
>
> ### 4.3 Performance Validations
>
> We proceed to verify the accuracy and effectiveness of the CelestiSim particularly for LLM inference in this section. This verification is conducted by comparing the simulator's predictions with empirical data obtained from running the TensorRT-LLM inference engine in a static batch setting on a cluster of eight NVIDIA H100 GPUs or H200 GPUs interconnected using NVLink and NVSwitch in a DGX box.
>
> We validate simulation framework with the LLaMA-3.1 70B model. For H100, we examine tensor parallel (TP) sizes of 4 and 8; for H200, due to its larger memory capacity, we examine TP sizes of 2, 4 and 8. We consider batch sizes of 1, 16, 32, and 64. To evaluate the impact of sequence lengths, we ran two sets of experiments for each model and TP and batch size configuration:
>
> *Variable Input Length*: The input sequence length varies over eight values — 1, 32, 64, 128, 256, 512, 1024, and 2048 tokens — while the output sequence length is fixed at 32 tokens.
>
> *Variable Output Length*: The output sequence length varies over seven values — 32, 64, 128, 256, 512, 1024, and 2048 tokens — while the input sequence length is fixed at 512 tokens. In total, we consider 180 configurations for the 70B model.
>
> *Figure 7: Validation of CelestiSim predictions using the LLaMA-3.1 70B model.*
> ![[celestial-pfa-arxiv-007.png]]
>
> For each configuration, we measure the end-to-end execution times of the inference process with both the prefill and decoding phases and use CelestiSim to predict execution times. Figure 7 presents these results. Across all tested batch sizes, input sequence lengths, and output sequence lengths, CelestiSim achieves a mean absolute percentage error (MAPE) of 7.57% and an R² value of 0.99, indicating strong predictive accuracy and consistency. The simulator also faithfully captures the performance impact of varying TP sizes, including communication delays and synchronization overheads typical in multi-GPU systems. While predictions for the H200 GPU tend to slightly underestimate execution time compared to H100, this trend aligns with the microbenchmark results in Figure 6. Specifically, H200 exhibits marginally lower effective memory bandwidth. These architectural differences are reflected in CelestiSim's performance modeling, validating its ability to capture hardware-level characteristics.
>
> ## 5 Power Savings of LLM Pre-training
>
> Power modeling with the CelestiSim demonstrates that migrating from conventional Ethernet-based Clos topologies to the Photonic Fabric TM can significantly diminish energy consumption in large-scale pretraining workloads. Across a spectrum of model and cluster configurations, the analyses consistently indicate approximately 60-90% reductions in communication-related power expenditures. These gains appear robust to variations in model size, cluster scale, and the specific blend of parallelization techniques employed.
>
> Bandwidth-intensive tensor parallelism (TP) is critical to achieving high arithmetic utilization for very large models. As model sizes increase, TP communication overheads and associated energy costs grow proportionally. In these scenarios, the Photonic Fabric TM curbs this energy usage by up to an order of magnitude, facilitating more cost-effective scaling to the trillion-parameter regime and beyond.
>
> *Table 2: Tensor Parallelism Energy Costs (kJ, batch size = 3072), with percentages relative to NVIDIA baseline.*
>
> | Model Size | NVIDIA Baseline | PFMM 2TB only |       | PFMM 4TB only |       | PFMM 6TB only |       |
> |------------|-----------------|---------------|-------|---------------|-------|---------------|-------|
> | 1T         | 1026.05         | 190.46        | 18.6% | 190.46        | 18.6% | 190.46        | 18.6% |
> | 2T         | 1710.08         | 391.43        | 22.9% | 391.43        | 22.9% | 317.44        | 18.6% |
> | 4T         | 2565.12         | 952.32        | 37.1% | 952.32        | 37.1% | 587.15        | 22.9% |
> | 7T         | 3665.98         | 1361.02       | 37.1% | 1361.02       | 37.1% | 1361.02       | 37.1% |
> | 11T        | 6299.83         | 1872.9        | 29.7% | 1872.9        | 29.7% | 1872.9        | 29.7% |
> | 18T        | 8288.55         | 3038.49       | 36.7% | 2464.13       | 29.7% | 2464.13       | 29.7% |
> | 26T        | 23381.3         | 4266.67       | 18.2% | 3914.32       | 16.7% | 3174.4        | 13.6% |
> | 37T        | 29577.4         | 7573.27       | 25.6% | 4951.62       | 16.7% | 4951.62       | 16.7% |
> | 53T        | 46470.4         | 18678.7       | 40.2% | 13312         | 28.6% | 6106.34       | 13.1% |
> | 72T        | 62655.2         | 25996.6       | 41.5% | 22764.7       | 36.3% | 8112          | 12.9% |
> | 96T        | 75548.7         | 31346.3       | 41.5% | 27449.3       | 36.3% | 9781.33       | 12.9% |
>
> Memory offloading is another key bottleneck as per-GPU memory remains finite while model parameters and batch sizes increase. Photonic networks reduce the energy cost per bit for offloaded data transfers, enabling more efficient sharding and storage to global memory. One consequence of this is higher training efficiencies for larger models without incurring steep energy penalties that would otherwise be imposed by conventional networking infrastructures. Note that memory offloading costs can drop when a larger model's mean FLOPS utilization benefits from larger tensor parallelism clusters.
>
> *Table 3: Memory Offloading Power Costs (kJ, batch size = 3072).*
>
> | Model Size | NVIDIA Baseline | PFMM 2TB only |       | PFMM 4TB only |       | PFMM 6TB only |       |
> |------------|-----------------|---------------|-------|---------------|-------|---------------|-------|
> | 1T         | 4032.15         | 1008.04       | 25.0% | 1008.04       | 25.0% | 1008.04       | 25.0% |
> | 2T         | 8258.63         | 2064.66       | 25.0% | 2064.66       | 25.0% | 2064.66       | 25.0% |
> | 4T         | 14681.5         | 6996.85       | 47.7% | 6996.85       | 47.7% | 3670.37       | 25.0% |
> | 7T         | 24696.5         | 10543.8       | 42.7% | 10543.8       | 42.7% | 10543.8       | 42.7% |
> | 11T        | 97405.8         | 21435.3       | 22.0% | 15357.3       | 15.8% | 15357.3       | 15.8% |
> | 18T        | 139942          | 24864.8       | 17.8% | 21397         | 15.3% | 21397         | 15.3% |
> | 26T        | 135843          | 33960.8       | 25.0% | 12240.3       | 9.0%  | 29280.5       | 21.6% |
> | 37T        | 280530          | 45671.1       | 16.3% | 45671.1       | 16.3% | 17312.8       | 6.2%  |
> | 53T        | 375054          | 64211.2       | 17.1% | 47187.5       | 12.6% | 59717.2       | 15.9% |
> | 72T        | 496517          | 82891.1       | 16.7% | 31714         | 6.4%  | 77414.1       | 15.6% |
> | 96T        | 901349          | 137423        | 15.2% | 74409         | 8.3%  | 99312         | 11.0% |
>
> While pipeline parallelism (PP) typically involves fewer total data movement than TP or offloading operations, these communication patterns still benefit. Table 4 shows that the Photonic Fabric still delivers non-trivial efficiency savings, consistently near 80%.
>
> *Table 4: Pipeline Parallelism Power Costs (kJ, batch size = 3072).*
>
> | Model Size | NVIDIA Baseline | PFMM 2TB only |       | PFMM 4TB only |       | PFMM 6TB only |       |
> |------------|-----------------|---------------|-------|---------------|-------|---------------|-------|
> | 1T         | 64.13           | 11.90         | 18.6% | 11.90         | 18.6% | 11.90         | 18.6% |
> | 2T         | 106.88          | 24.46         | 22.9% | 24.46         | 22.9% | 19.84         | 18.6% |
> | 4T         | 160.32          | 29.76         | 18.6% | 29.76         | 18.6% | 36.70         | 22.9% |
> | 7T         | 229.12          | 42.53         | 18.6% | 42.53         | 18.6% | 42.53         | 18.6% |
> | 11T        | 393.74          | 58.53         | 14.9% | 58.53         | 14.9% | 58.53         | 14.9% |
> | 18T        | 518.03          | 94.95         | 18.3% | 77.00         | 14.9% | 77.00         | 14.9% |
> | 26T        | 730.67          | 133.33        | 18.2% | 122.32        | 16.7% | 99.20         | 13.6% |
> | 37T        | 924.29          | 236.66        | 25.6% | 154.74        | 16.7% | 154.74        | 16.7% |
> | 53T        | 1452.20         | 291.86        | 20.1% | 208.00        | 14.3% | 190.82        | 13.1% |
> | 72T        | 1957.97         | 406.20        | 20.7% | 355.70        | 18.2% | 253.50        | 12.9% |
> | 96T        | 2360.90         | 489.79        | 20.7% | 428.90        | 18.2% | 305.67        | 12.9% |
>
> Overall, this power modeling indicates that the Photonic Fabric TM can facilitate balancing performance goals against power constraints in the next generation of large-scale AI training systems.
>
> ## 6 Performance Evaluation of LLM Inference with PFA
>
> Inference experiments with the CelestiSim indicate that the PFA can significantly boost LLM inference throughput and reduce latency compared to conventional GPU-based clusters. Across a range of batch sizes and sequence lengths, we see throughput gains of up to 3.66x for LLaMA 405B parameter models and up to 7.04x for the projected 1T parameter models. These benefits hold even as model sizes increase beyond the memory capacity of a single DGX system.
>
> ### 6.1 Experiments Setup
>
> We evaluated two hardware configurations (see Table 5):
>
> - **H100-DGX**: A single NVIDIA DGX box with eight H100 GPUs, each offering 80 GB of memory, 1979 TFLOPS at fp8 precision, and 3350 GB/s of HBM bandwidth, and
> - **H100 GPUs with Photonic Fabric Appliance TM (PFA)**: A novel architecture featuring 32 TB of photonically-accessible memory, and 26800 GB/s of interconnect bandwidth.
>
> *Table 5. Experimental System Configurations*
>
> | System    | Num procs | TFLOPs (fp8) | HBM BW (GB/s) | Network        | Memory |
> |-----------|-----------|--------------|---------------|----------------|--------|
> | H100-DGX  | 8         | 1979         | 3350          | NVLink 900GB/s | 80 GB  |
> | PFA       | 1         | 1979×        | 26800         | -              | 32 T   |
>
> For the 405B parameter model, we considered a range of batch sizes and four input-output token lengths, 128 or 4096 tokens each, simulating typical production workloads. On the DGX, we enabled tensor parallelism (cluster size 8) and disabled data and pipeline parallelism (cluster sizes 1). On the PFA, we ran a single configuration with no tensor parallelism.
>
> For the more demanding 1T parameter model, which requires two interconnected DGX-H100 boxes even with fp8 quantization, we enabled both tensor parallelism (cluster size 8) and pipeline parallelism (cluster size 2). We used InfiniBand (100 GB/s bidirectional transfer) for the interconnect, and configured the PFA cluster identically, with both tensor and pipeline parallelism.
>
> ### 6.2 Results
>
> Figure 8 presents throughput performance for the LLaMA3.1-405B model, examining four combinations of input-output token lengths across various batch sizes on both DGX-H100 and PFA configurations. Generally, throughput increases with batch size before plateauing as workloads shift from memory-bound to compute-bound conditions. Notably, for DGX-H100, this plateau primarily results from restricted maximum microbatch sizes due to GPU memory capacity limitations, and the overhead associated with distributed computing. In contrast, the PFA demonstrates substantially higher throughput, benefiting from ample memory capacity and a disaggregated memory pool design that eliminates overhead from tensor parallelism (TP). This advantage is further highlighted in the Model FLOPs Utilization (MFU); for instance, the DGX-H100 reaches only 13.6% MFU at its maximum batch size for the (128, 4096) token scenario, whereas the PFA achieves 49.7% MFU.
>
> Across all tested scenarios, the PFA consistently delivers higher throughput than the DGX-H100. However, throughput gains vary significantly based on the nature of workloads. Specifically, input-output pairs with longer outputs, such as (128, 4096) and (4096, 4096), exhibit larger performance improvements compared to shorter output scenarios like (128, 128) and (4096, 128). This variation occurs because prefill stages are predominantly compute-bound, whereas decode stages are memory-bound. Hence, workloads with shorter outputs, heavily reliant on GPU compute capabilities, show relatively smaller throughput improvements on PFA. Conversely, memory-bound workloads experience significant benefits due to PFA's capability to manage larger batch sizes, eliminate inter-GPU communication overhead, and remove memory access overhead associated with tensor parallelism.
>
> *Figure 8: Throughput results on DGX-H100 and PFA with respect to batch size across different input and output length.*
> ![[celestial-pfa-arxiv-008.png]]
>
> Figure 9 illustrates throughput and latency speedups provided by the PFA compared to the DGX-H100 across varying compute resource levels, where full compute power is represented by 8 GPUs. We specifically analyze both throughput and latency since both metrics critically influence the overall efficiency and responsiveness of large language model deployments. The PFA achieves notable throughput gains, particularly for memory-bound workloads (e.g., pairs (128, 4096) and (4096, 4096)), demonstrating better throughput even with just a quarter of DGX-H100's compute resources. Regarding latency at batch size 1, the PFA consistently shows improvements at full compute power. When using only one GPU (one-eighth of the total compute power), the input-output pair (4096,128) exhibits limited latency improvement. This is due to the prefill stage significantly dominating the inference time at reduced compute capacity, overshadowing the decoding-time improvements provided by the PFA. On the other hand, even with much smaller compute power, pairs of (4096, 4096) and (128,128) continue to exhibit strong latency improvements because the reductions in decoding times substantially outweigh the marginal increases in prefill durations. In summary, the PFA exhibits throughput improvements of up to 3.66x and latency reductions of up to 1.40x for the 405B parameter model compared to DGX-H100 (Figure 9).
>
> Expanding to larger models, Figure 10 demonstrates even greater benefits, with the PFA achieving throughput improvements of up to 7.04x and latency reductions of up to 1.41x compared to two interconnected DGX-H100 systems for the 1T parameter model. These results underline the scalability and substantial performance advantage of the PFA architecture for large-scale LLM inference workloads.
>
> *Figure 9: Left: Throughput speedup and Right: latency speedup, using PFA on LLaMA3.1-405B model over DGX-H100.*
> ![[celestial-pfa-arxiv-009.png]]
>
> *Figure 10: Left: Throughput speedup and Right: latency speedup, using PFA on 1T model over 2 DGX-H100.*
> ![[celestial-pfa-arxiv-010.png]]
>
> ### 6.3 Discussion
>
> To understand the underlying advantages provided by the Photonic Fabric Appliance (PFA), we analyze the detailed breakdown of latency for key operations during the decoding phase at a batch size of one (Figure 11). The operations listed under "Other" include primarily layer normalization and residual computations. The PFA reduces latency across all operation categories, particularly in communication overhead and layernorm operations. In GPU-based systems like the DGX-H100, the necessity of employing tensor parallelism (TP) contributes significantly to latency overhead. As LLM models scale beyond the memory capacity of individual GPUs, tensor parallelism is essential for partitioning and distributing computations and model parameters. However, this partitioning strategy inherently introduces additional communication and synchronization overhead, negatively affecting overall inference latency.
>
> *Figure 11: Operation latency breakdown during decoding phase comparing the DGX-H100 and the PFA.*
> ![[celestial-pfa-arxiv-011.png]]
>
> Tensor parallelism [1] divides model layers across multiple GPUs, allowing simultaneous computations on separate segments of activations and weights. Subsequently, these GPUs must synchronize and aggregate partial results, often via collective communication operations such as all-reduce. These collective communications introduce fixed latency penalties for small message sizes and bandwidth limitations for large messages, exacerbating overhead as TP scales.
>
> We further illustrate this overhead by profiling the decoding phase of LLM inference under varying TP levels (Figure 12). We use a fixed batch size of 16 tokens, with both input and output sequence lengths set to 128 tokens, evaluating performance across TP sizes of 1, 2, 4, and 8 GPUs. The experiments employed TensorRT-LLM inference engine profiling via NVIDIA Nsight Systems.
>
> *Figure 12: Breakdown of overhead percentage during decode phase for different TP sizes.*
> ![[celestial-pfa-arxiv-012.png]]
>
> We calculate 'Overhead%' as the fraction of added execution time, relative to a single GPU baseline, normalized by the tensor parallelism (TP) size. Profiling results indicates that overhead% increases as TP size grows. Specifically, all-reduce operations account for 37.68%, 40.10%, 50.02% of total overhead for TP sizes of 2, 4, and 8 respectively. Synchronization further amplifies this penalty, hampering overall performance. Operations like layer normalization, which do not reduce memory access time through partitioning, exhibit elevated overhead.
>
> Besides communication overhead, tensor parallelism inherently induces redundant memory accesses because each GPU must access replicated copies of input/output tensors (illustrated in Figure 13). Such redundancy substantially increases memory access overhead and reduces computational efficiency. Thus, while TP enables deployment of large-scale LLMs, its benefits can diminish due to overhead in communication, redundant memory accesses, and inefficient compute utilization from smaller partitioned workloads.
>
> *Figure 13: Illustration of memory access overhead using tensor parallelism for feedforward.*
> ![[celestial-pfa-arxiv-013.png]]
>
> In summary, the core advantages of the PFA architecture for LLM inference arise from two principal factors:
>
> **Larger Memory Capacity**: Enables efficient utilization of compute resources during memory-bound LLM inference phases, significantly enhancing throughput.
>
> **Reduced Communication and TP Overhead**: By providing a disaggregated memory pool, the PFA drastically lowers communication overhead and redundant memory accesses, thus greatly improving latency-sensitive operations.
>
> In this paper, we specifically highlighted tensor parallelism, as it constitutes a crucial deployment strategy in large-scale LLM inference scenarios and is associated with significant overhead challenges. It is important to note that the advantages of PFA also extend naturally to pipeline parallelism and iterative batching scenarios, particularly those involving memory offloading. Detailed analysis of these additional benefits is deferred to future work.
>
> ## 7 Scalability of DLRM Embedding Pooling
>
> For recommendation systems with massive embedding tables, the PFA likewise demonstrates order-of-magnitude performance and efficiency advantages. The Deep Learning Recommendation Models (DLRM) that often drive these systems blend neural networks with often massive embedding tables that can scale into the tens of trillions of parameters [32]. This combination lends itself to exceptionally low arithmetic intensity, as well as complex and often unpredictable communication patterns that underutilize data center infrastructure and lead to subpar performance. The experiments with TorchRec confirm that the PFA can alleviate bottlenecks arising from embedding pooling, one of the main bottlenecks in DLRM inference.
>
> We evaluate against DGX-H100 systems. Our approach partitions the embeddings across multiple GPUs using row-wise parallelism, varying both the number of embedding tables (1, 2, 4, 8, 16, 32, 64) and the batch size (128, 1024, 4096). We fix the embedding dimension at 32 and use pooling factors of 32 or 64. Because each H100 GPU offers 80 GB of HBM, very large embedding tables require distributed storage across tens or even hundreds of GPUs. For example, a 10 TB embedding table occupies 128 GPUs. Under these conditions, the PFA's shared storage — which allows embeddings to be executed entirely in locally addressable memory — and low per-bit photonic energy costs translate into substantial speedups. The simulations indicate an average improvement of 22.8x in comparison to GPUs linked via NVLink, and 28.3x over those connected by PCIe (Figure 14).
>
> *Figure 14: Embedding performance speedup for a 10 TB embedding table*
> ![[celestial-pfa-arxiv-014.png]]
>
> ## 8 Related Work
>
> The pragmatic integration of photonics into computing systems has shifted focus toward photonic interconnects. Established semiconductor companies, including NVIDIA [7], have announced interest in on-module silicon photonics for data communication in its high-performance systems, though the company noted the technology is not yet mature for all products. These early-stage efforts validate the growing importance of photonics for memory and interconnect scaling, especially for large language models (LLMs) that demand fast and energy-efficient movement of petabyte-scale key-value data across distributed systems.
>
> However, evaluating such co-designed architectures — especially for LLM inference workloads — poses significant modeling challenges. While hardware-oriented simulators can be very accurate, they also tend to be prohibitively slow; system-level GPU simulators such as NVArchSim [8] or network simulators such as SuperSim [9,10] and SST [11] may requires an entire day of computation to model just one second of real-time execution. This makes them impractical for investigating the many parallelization and optimization strategies in modern LLM deployment. Compiler-based models like ParaGraph [9] can be faster but often target only existing hardware and demand extensive engineering to account for the many LLM-specific optimizations. These limitations make them poorly suited for rapid co-design and architectural prototyping — particularly for novel memory systems or inference-heavy scenarios.
>
> To address these challenges, several frameworks have been proposed. Tools like Calculon [12], vTrain [13], and ASTRA-sim [14] provide performance models and simulators to optimize LLM training configurations, focusing on minimizing cost and training time. Other frameworks, such as DeepFlow [17], focus on analytical performance modeling by integrating technology parameters, system architectures, and workload characteristics. DeepFlow utilizes a hierarchical roofline model to predict performance, particularly for matrix multiplication operations, a core component of LLM training workloads. However, these tools often fall short in addressing the dynamic nature of LLM inference. More recent tools incorporate iteration-level simulation and detailed memory modeling to provide better insights into LLM inference performance. LLMServingSim [15], for instance, employs demand paging schemes and computation reuse techniques to achieve feasible simulation times for large-scale inference systems. Vidur [16] combined experimental profiling and predictive modeling to evaluate the end-to-end inference performance for different workloads. Despite significant advancements in tools for LLM performance modeling, accurately capturing the complex interaction between hardware and software in training, inference, and energy costs remains challenging, highlighting the need for precise memory bandwidth utilization models, network simulators for communication overheads, and comprehensive energy analyses.
>
> ## 9 Scope of Work and Limitations
>
> While this work demonstrates compelling performance and energy efficiency benefits from integrating the PFA with GPUs for large-scale LLM inference workloads, several limitations and assumptions remain in the current simulation and evaluation framework.
>
> ### PFA Hardware Validation and Assumptions
>
> The evaluation of the PFA relies on predictive modeling using CelestiSim, rather than empirical hardware results. While CelestiSim is validated using microbenchmark data from NVIDIA H100 and H200 GPUs, we apply the same bandwidth utilization and FLOP efficiency models to estimate PFA performance. This assumes comparable compute characteristics and conservative scaling of interconnect bandwidth, rather than modeling novel microarchitectural differences that may exist in the photonic memory interfaces. As physical prototypes of the PFA and its chiplet interface become available, we plan to further validate and refine these assumptions.
>
> ### Exclusion of H200 Results in Benchmarking
>
> Although CelestiSim was validated using both H100 and H200 GPUs, the primary baseline comparison uses H100. This choice reflects a tighter match to the simulation models and greater relevance to current production-scale infrastructure. Including H200 does not change the overall performance trends and may be included in future versions for completeness.
>
> ### System-level Modeling Scope
>
> CelestiSim is designed to capture the dominant hardware-software interactions that influence LLM performance: compute utilization, memory bandwidth saturation, communication latency, and energy costs. However, it does not explicitly model system-level features such as coherence protocols, runtime scheduling semantics, or compiler-specific behaviors. To maintain generality and simulation speed, we make several design-time assumptions:
>
> - **Memory Consistency & Coherency**: We assume that XPUs connected to PFA access memory in a non-coherent manner akin to existing data-parallel or tensor-parallel frameworks (e.g., PyTorch DDP, MegatronLM). The simulator assumes explicit memory partitioning between compute nodes, with collective communication used to synchronize state.
> - **Programming Model**: We follow the Megatron-style programming stack with explicit model parallelism and standard training loop semantics, assuming minimal changes to framework behavior.
> - **Scheduling & Workload Coordination**: The simulator decouples per-layer execution and communication, implicitly modeling common scheduling patterns such as 1F1B pipeline parallelism and overlapping mechanisms.
>
> The first generation of the Celestial AI Photonic Fabric products provides a compelling rack-mountable cluster-scale appliance that supports up to 32 TB of shared memory capacity at full HBM3 bandwidths along with 115 Tbps of all-to-all digital switching capability with 16 PF ports. The next generation of the Photonic Fabric products is expected to increase the number of PF ports from 16 to 64 as well as the number of WDM wavelengths from 4 to 8. Using PAM4 signaling, the per link data bandwidth is expected to quadruple from 7.2 Tbps to 28.8 Tbps.
>
> An important implication of the Photonic Fabric is the memory disaggregation that it provides by decoupling the memory from the compute. In addition to the expansion of the memory capacity and the flexible scaling of the memory bandwidth, the Photonic Fabric Appliance mitigates the technology risk from transition of one generation of memory technologies to another. In particular, the support for HBM4 in the next generation of the PFA enables the AI accelerators to continue to achieve higher performance without significant redesign.
>
> ## 10 Conclusions
>
> The Photonic Fabric Appliance described in this paper aims to expand the memory and bandwidth resources available to AI accelerators. By integrating high-bandwidth HBM3E memory, an on-module photonic switch, and external DDR5 in a 2.5D electro-optical system-in-package, the PFA offers up to 32 TB of shared memory alongside 115 Tbps of all-to-all digital switching. The simulation results show significant performance speedup and substantially lower energy consumption when the PFA is used in combination with conventional XPUs, particularly for large language models and recommendation workloads. These findings indicate that optical integration and memory disaggregation can help mitigate scaling challenges in AI deployments and can serve as a basis for continued research into more efficient hardware-software co-design for large-scale machine learning.
>
> ## ACKNOWLEDGMENTS
>
> We would like to thank the reviewers of this paper. In addition, this work would not have been possible without the many teams at Celestial AI including Photonics group, Packaging group, ASIC design group, ASIC design verification group, Product Marketing group, and the rest of the ML Engineering group. We would like to thank Jonathan Sparling for the work on the LLM pretraining analysis about energy savings.
>
> ## REFERENCES
>
> 1. Mohammad Shoeybi, Mostofa Patwary, Raul Puri, Patrick LeGresley, Jared Casper, and Bryan Catanzaro. 2019. Megatron-LM: Training Multi-Billion Parameter Language Models Using Model Parallelism. <https://doi.org/10.48550/ARXIV.1909.08053>
> 2. Xiao, B., & Su, L. (2024). ISO: Overlap of Computation and Communication within Sequence For LLM Inference. arXiv preprint arXiv:2409.11155.
> 3. Wang, S., Wei, J., Sabne, A., Davis, A., Ilbeyi, B., Hechtman, B., ... & Zhou, Z. (2022, December). Overlap communication with dependent computation via decomposition in large deep learning models. In Proceedings of the 28th ACM International Conference on Architectural Support for Programming Languages and Operating Systems, Volume 1 (pp. 93-106).
> 4. Shen, Y., Harris, N. C., Skirlo, S., Prabhu, M., Baehr-Jones, T., Hochberg, M., Sun, X., Zhao, S., Larochelle, H., Englund, D., & Soljačić, M. (2017). Deep Learning with Coherent Nanophotonic Circuits. Nature Photonics, 11(7), 441-446.
> 5. Feldmann, J., Youngblood, N., Wright, C. D., Bhaskaran, H., & Pernice, W. H. P. (2021). Parallel Convolutional Processing Using an Integrated Photonic Tensor Core. Nature, 589(7840), 52-58.
> 6. Ashtiani, F., Geers, A. J., & Aflatouni, F. (2022). An On-Chip Photonic Deep Neural Network for Image Classification. Nature, 606(7912), 501-506.
> 7. NVIDIA (2025), A New Era in Data Center Networking with NVIDIA Silicon Photonics-based Network Switching.
> 8. Oreste Villa, Daniel Lustig, Zi Yan, Evgeny Bolotin, Yaosheng Fu, Niladrish Chatterjee, Nan Jiang, and David Nellans. 2021. Need for Speed: Experiences Building a Trustworthy System-Level GPU Simulator. In 2021 IEEE International Symposium on High-Performance Computer Architecture (HPCA). 868-880. <https://doi.org/10.1109/HPCA51647.2021.00077>
> 9. Mikhail Isaev, Nic McDonald, Jeffrey Young, and Richard Vuduc. 2022. ParaGraph: An application-simulator interface and toolkit for hardware-software co-design. In 51th International Conference on Parallel Processing (Bordeaux, France) (ICPP 2022). Association for Computing Machinery, New York, NY, USA, Article 61, 10 pages. <https://doi.org/10.1145/3545008.3545069>
> 10. Nic McDonald, Adriana Flores, Al Davis, Mikhail Isaev, John Kim, and Doug Gibson. 2018. SuperSim: Extensible Flit-Level Simulation of Large-Scale Interconnection Networks. In 2018 IEEE International Symposium on Performance Analysis of Systems and Software (ISPASS). 87-98. <https://doi.org/10.1109/ISPASS.2018.00017>
> 11. Jeremiah J. Wilke, Joseph P. Kenny, Samuel Knight, and Sebastien Rumley. 2018. Compiler-Assisted Source-to-Source Skeletonization of Application Models for System Simulation. In High Performance Computing, Rio Yokota, Michèle Weiland, David Keyes, and Carsten Trinitis (Eds.). Springer International Publishing, Cham, 123-143.
> 12. Isaev, M., McDonald, N., Dennison, L., & Vuduc, R. (2023, November). Calculon: a methodology and tool for high-level co-design of systems and large language models. In Proceedings of the International Conference for High Performance Computing, Networking, Storage and Analysis (pp. 1-14).
> 13. Bang, J., Choi, Y., Kim, M., Kim, Y., & Rhu, M. (2024, November). vtrain: A simulation framework for evaluating cost-effective and compute-optimal large language model training. In 2024 57th IEEE/ACM International Symposium on Microarchitecture (MICRO) (pp. 153-167). IEEE.
> 14. Rashidi, S., Sridharan, S., Srinivasan, S., & Krishna, T. (2020, August). Astra-sim: Enabling sw/hw co-design exploration for distributed dl training platforms. In 2020 IEEE International Symposium on Performance Analysis of Systems and Software (ISPASS) (pp. 81-92). IEEE.
> 15. Cho, J., Kim, M., Choi, H., Heo, G., & Park, J. (2024, September). LLMServingSim: A HW/SW Co-Simulation Infrastructure for LLM Inference Serving at Scale. In 2024 IEEE International Symposium on Workload Characterization (IISWC) (pp. 15-29). IEEE.
> 16. Agrawal, A., Kedia, N., Mohan, J., Panwar, A., Kwatra, N., Gulavani, B., ... & Tumanov, A. (2024). Vidur: A Large-Scale Simulation Framework For LLM Inference. Proceedings of Machine Learning and Systems, 6, 351-366.
> 17. Ardalani, N., Pal, S., & Gupta, P. (2024). DeepFlow: A cross-stack pathfinding framework for distributed ai systems. ACM Transactions on Design Automation of Electronic Systems, 29(2), 1-20.
> 18. Radford, A., Wu, J., Child, R., Luan, D., Amodei, D., Sutskever, I., 2019. Language models are unsupervised multitask learners.
> 19. Brown, T.B., Mann, B., Ryder, N., Subbiah, M., Kaplan, J., Dhariwal, P., Neelakantan, A., Shyam, P., Sastry, G., Askell, A., Agarwal, S., Herbert-Voss, A., Krueger, G., Henighan, T., Child, R., Ramesh, A., Ziegler, D.M., Wu, J., Winter, C., Hesse, C., Chen, M., Sigler, E., Litwin, M., Gray, S., Chess, B., Clark, J., Berner, C., McCandlish, S., Radford, A., Sutskever, I., Amodei, D., 2020. Language models are few-shot learners, in: Proceedings of the 34th International Conference on Neural Information Processing Systems (NIPS'20), Curran Associates Inc., Red Hook, NY, USA. pp. Article 159, 25 pages.
> 20. OpenAI, 2023. Gpt-4 technical report.
> 21. Touvron, H., Lavril, T., Izacard, G., Martinet, X., Lachaux, M.A., Lacroix, T., Rozière, B., Goyal, N., Hambro, E., Azhar, F., Rodriguez, A., Joulin, A., Grave, E., Lample, G., 2023. Llama: Open and efficient foundation language models. <https://arxiv.org/abs/2302.13971>
> 22. Vaswani, A., Shazeer, N., Parmar, N., Uszkoreit, J., Jones, L., Gomez, A.N., Łukasz Kaiser, Polosukhin, I., 2017. Attention is all you need, in: Proceedings of the 34th International Conference on Neural Information Processing Systems (NIPS'17), Curran Associates Inc., Red Hook, NY, USA. pp. 6000-6010.
> 23. Sunwoo Lee, Dipendra Jha, Ankit Agrawal, Alok Choudhary, and Weikeng Liao. 2017. Parallel Deep Convolutional Neural Network Training by Exploiting the Overlapping of Computation and Communication. In 2017 IEEE 24th International Conference on High Performance Computing (HiPC). 183-192. <https://doi.org/10.1109/HiPC.2017.00030>
> 24. Narayanan, D., Shoeybi, M., Casper, J., LeGresley, P., Patwary, M., Korthikanti, V., Vainbrand, D., Kashinkunti, P., Bernauer, J., Catanzaro, B., Phanishayee, A., Zaharia, M., 2021. Efficient large-scale language model training on gpu clusters using megatron-lm, in: Proceedings of the International Conference for High Performance Computing, Networking, Storage and Analysis (SC '21), Association for Computing Machinery, New York, NY, USA. pp. Article 58, 15 pages.
> 25. Vijay Korthikanti, Jared Casper, Sangkug Lym, Lawrence McAfee, Michael Andersch, Mohammad Shoeybi, and Bryan Catanzaro. 2022. Reducing Activation Recomputation in Large Transformer Models. <https://doi.org/10.48550/ARXIV.2205.05198>
> 26. Rasley, J., Rajbhandari, S., Ruwase, O., He, Y., 2020. Deepspeed: System optimizations enable training deep learning models with over 100 billion parameters, in: Proceedings of the 26th ACM SIGKDD International Conference on Knowledge Discovery and Data Mining (KDD '20), Association for Computing Machinery, New York, NY, USA. pp. 3505-3506.
> 27. Dao, T., Fu, D., Ermon, S., Rudra, A., & Ré, C. (2022). Flash-attention: Fast and memory-efficient exact attention with io-awareness. Advances in Neural Information Processing Systems, 35, 16344-16359.
> 28. NVIDIA. 'Nvidia ConnectX-6 User Manual.' Manualslib, 2022, <https://www.manualslib.com/manual/2957118/Nvidia-Connectx-6.html>
> 29. NVIDIA, 'Nvidia ConnectX-7 User Manual.' Manualslib, 2023, <https://www.manualslib.com/manual/3356680/Nvidia-Connectx-7.html>
> 30. NVIDIA. 'Nvidia Spectrum-3 SN4000 Series Switch Manuals.' Manualslib, 2023, <https://www.manualslib.com/products/Nvidia-Spectrum-3-Sn4000-Series-13172939.html>
> 31. NVIDIA. 'QM9700/QM9790 1U NDR 400Gb/s InfiniBand Switch Systems User Manual.' Sysgen, 2022, <https://www.sysgen.de/media/pdf/6a/98/91/QM9700_QM9790_User_Manual.pdf>
> 32. Mudigere, D., Hao, Y., Huang, J., Jia, Z., Tulloch, A., Sridharan, S., ... & Rao, V. (2022, June). Software-hardware co-design for fast and scalable training of deep learning recommendation models. In Proceedings of the 49th Annual International Symposium on Computer Architecture (pp. 993-1011).

---

Source: <https://arxiv.org/abs/2507.14000>
