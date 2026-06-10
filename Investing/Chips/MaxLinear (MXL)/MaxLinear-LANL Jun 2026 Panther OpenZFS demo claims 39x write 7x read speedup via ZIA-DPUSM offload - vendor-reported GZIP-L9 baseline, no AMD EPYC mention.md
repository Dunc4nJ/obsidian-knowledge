---
created: 2026-06-10
published: 2026-06-03
description: MaxLinear and Los Alamos National Laboratory announce hardware-accelerated OpenZFS via Panther storage accelerator SoCs integrated as a DPUSM provider through LANL's ZIA framework, claiming 57 GB/s reads and 47 GB/s writes with GZIP L9 (~39x write, ~7x read over software baseline) — a vendor-reported demo with no CPU-platform validation and no production timeline.
source: https://www.maxlinear.com/news/press-releases/2026/maxlinear-and-los-alamos-national-laboratory-jointly-advance-high-performance-file-system-accelerati
type: research
---

## Key Takeaways

- **Headline numbers (verbatim)**: "Achieved for the first time **57 GB/s read**, and **47 GB/s** write with GZIP L9 at ~1.3:1 compression, representative of high-entropy scientific data... Without Panther™, ZFS is limited to ~1.2 GB/s writes and 8.1 GB/s reads—delivering ~39x write and **~7x read speedup** via hardware offload." The software-only baseline is the denominator that makes the multiple — see the caveat bullet below before quoting the 39x. This is the Panther/LANL pillar cited in the [[MXL 2026-06-10 briefing - optical DSP re-rating thesis, Q1 FY26 infrastructure up 136 pct, Rushmore 1.6T Samsung ramp, five-pillar bull case amid CPO delay debate|MXL five-pillar bull case briefing]] for [[MaxLinear (MXL)]].
- **Integration path is pre-existing open-source plumbing, not an upstream merge**: Panther "is integrated with ZFS as a Data Processing Unit Services Module (DPUSM) provider" through LANL's ZIA (ZFS Interface for Accelerators) framework. Both are LANL-maintained projects that predate this collaboration — ZIA lives as openzfs/zfs PR #13628 and DPUSM at github.com/hpc/dpusm. ZIA is a LANL-maintained extension that has NOT been merged into upstream OpenZFS mainline; "hardware-accelerated OpenZFS" here means a patched ZFS stack, not stock OpenZFS.
- **LANL's quote is carefully hedged**: Gary Grider (Senior Director for Computing Technologies) says "MaxLinear **demonstrated** hardware-offloaded ZFS operations with **reported** speedups of approximately 39x for writes and 7x for reads. These results **illustrate the potential** for accelerator-based approaches..." — the lab attributes the measurements to MaxLinear rather than independently certifying them. The word "reported" is doing real work in that sentence.
- **Benchmark caveats**: GZIP L9 is among the slowest software compression baselines available (maximally flattering to the 39x multiple — a zstd or lz4 baseline would compress the gap dramatically); ~1.3:1 is modest compression (honest for high-entropy scientific data, but it means the capacity-savings story is thin); and this is a vendor/lab joint demo, not an independent benchmark.
- **Critical absence — what the press release does NOT say**: zero occurrences of AMD, EPYC, Xeon, or Intel (verified by word-boundary grep against both the MaxLinear page and the BusinessWire mirror; the only loose hits are "intel" inside "intellectual property" boilerplate), and no production-availability or deployment timeline anywhere. Circulating bull threads claiming this PR contains "[[Advanced Micro Devices (AMD)|AMD]] EPYC validation" are attributing language that appears nowhere in the document. The host platform of the demo system is simply not disclosed.
- **Scaling claim**: "Multiple Panther™ Storage Accelerators can be deployed in parallel through ZIA, enabling scalable performance without introducing serialization or centralized bottlenecks" — plus "Scales further with additional accelerators" appended to the bandwidth bullet. Multi-accelerator parallelism is asserted, but no multi-card numbers are given; the 57/47 GB/s figure's accelerator count is unspecified.
- **Generation detail only in the banner image**: the press-release art shows a chip render labeled "MXL **Panther V**" — the body text never specifies which Panther generation produced the numbers (see embedded banner below).

## External Resources

- [MaxLinear Panther product page](https://www.maxlinear.com/panther) — referenced in the PR for accelerator details
- [openzfs/zfs PR #13628](https://github.com/openzfs/zfs/pull/13628) — LANL's ZIA (ZFS Interface for Accelerators) pull request; open against upstream, not merged
- [github.com/hpc/dpusm](https://github.com/hpc/dpusm) — LANL's Data Processing Unit Services Module, the provider interface Panther plugs into
- [BusinessWire mirror](https://www.businesswire.com/news/home/20260603338003/en/) — identical body plus standard forward-looking-statements safe-harbor section (which flags "risks related to the collaboration between MaxLinear and LANL" and the terminated Silicon Motion merger arbitration) not shown on the MaxLinear page
- [MaxLinear IR mirror](https://investors.maxlinear.com/press-releases/detail/615/) — investor-relations copy of the same release

## Original Content

> [!quote]- Source Material
> # MaxLinear and Los Alamos National Laboratory Jointly Advance High-Performance File System Acceleration for HPC Storage
>
> June 03, 2026
>
> * _Pioneering Hardware-Accelerated ZFS to Improve Throughput, Efficiency, and Scalability in HPC Storage_
>
> *Press-release banner — "MaxLinear + LANL Collaborate on Hardware-Accelerated ZFS for HPC Storage / Improves throughput, efficiency, scalability", with a render of a chip package labeled "MXL Panther V" over a datacenter backdrop; MaxLinear and Los Alamos National Laboratory logos at bottom*
> ![[maxlinear-panther-lanl-001.jpg]]
>
> **MaxLinear, Inc**. (NASDAQ: MXL), a leading provider of high-performance storage accelerator SoCs, and **Los Alamos National Laboratory (LANL)** today announced a collaboration to enable **hardware-accelerated OpenZFS File System** storage for large scale, high-performance computing (HPC) environments.
>
> Los Alamos National Laboratory and MaxLinear have jointly developed a hardware-accelerated OpenZFS storage architecture designed to improve performance and storage capacity for next-generation NVMe flash-based storage infrastructure.
>
> "Los Alamos' Direct I/O support and Z.I.A. (ZFS Interface for Accelerators) work were developed to accelerate performance for the ZFS-using community," said Gary Grider, Senior Director for Computing Technologies at the Laboratory. "In this collaboration, MaxLinear demonstrated hardware-offloaded ZFS operations with reported speedups of approximately 39x for writes and 7x for reads. These results illustrate the potential for accelerator-based approaches to reduce host CPU involvement while maintaining the data-protection benefits associated with ZFS."
>
> "Los Alamos National Laboratory has been at the forefront of advancing storage architectures for high-performance computing," said Vikas Choudhary, Executive Vice President of Connectivity & Storage at MaxLinear. "By enabling hardware-accelerated ZFS with Panther™ Storage Accelerators, we deliver deep data compression, data protection services, and multi-hundred gigabit scalability—while preserving the data integrity guarantees that ZFS is known for."
>
> LANL has decades of experience in operating ZFS at scale and has led to the development of key filesystem extensions, including **Direct I/O** support and ZIA **(ZFS Interface for Accelerators)**—a structured framework for introducing hardware acceleration into the ZFS data path without modifying core filesystem semantics.
> MaxLinear contributes the **Panther™ family of Storage Accelerator SoCs** and **Storage Software Development Kits**, providing high throughput, low latency execution of ZFS data path services using a domain-specific high-performance SoC architecture. Panther™ provides **deep data compression, encryption, deduplication, and data protection services** executed inline in hardware, delivering high throughput and low latency while significantly reducing host CPU overhead.
>
> Through this collaboration, Panther is integrated with ZFS as a Data Processing Unit Services Module (DPUSM) provider, enabling inline hardware acceleration of selected CPU‑intensive operations such as data compression and checksum generation to increase storage capacity, improve file I/O performance, and reduce host CPU utilization. This combined hardware‑software approach preserves ZFS ordering, consistency, and data integrity guarantees while enabling efficient compute offload and scalable acceleration.
> This collaboration integrates LANL's advancement in Direct I/O and ZIA framework with MaxLinear's Panther™ Storage Accelerator.
>
> **Key capabilities include:**
> * **Hardware-assisted ZFS services enabling deep data compression**: offload compression reduces host CPU involvement on high throughput I/O paths, enabling high I/O performance with minimal impact on CPU utilization.
> * **Scalable accelerator integration:** Multiple Panther™ Storage Accelerators can be deployed in parallel through ZIA, enabling scalable performance without introducing serialization or centralized bottlenecks.
> * **High bandwidth operation:** Achieved for the first time **57** **GB/s read**, and **47** **GB/s** write with GZIP L9 at ~1.3:1 compression, representative of high-entropy scientific data. Achieving this compression requires compute intensive algorithms like GZIP. Without Panther™, ZFS is limited to ~1.2 GB/s writes and 8.1 GB/s reads—delivering ~39x write and **~7x read speedup** via hardware offload. Scales further with additional accelerators.
>
> For more information on MaxLinear's Panther™ Storage Accelerator, visit <https://www.maxlinear.com/panther>
>
> **About MaxLinear, Inc.**
> MaxLinear, Inc. (Nasdaq: MXL) is a leading provider of radio frequency (RF), analog, digital, and mixed-signal integrated circuits for access and connectivity, wired and wireless infrastructure, and industrial and multimarket applications. MaxLinear is headquartered in Carlsbad, California. For more information, please visit <https://www.maxlinear.com/>.
>
> MaxLinear, the MaxLinear logo, any other MaxLinear trademarks are all property of MaxLinear, Inc. or one of MaxLinear's subsidiaries in the U.S.A. and other countries. All rights reserved.
>
> All third-party marks and logos are trademarks or registered trademarks of their respective holders/owners.
>
> **About Los Alamos National Laboratory**
> Los Alamos National Laboratory is a federally funded research and development center with priorities set by the Department of Energy's National Nuclear Security Administration (DOE NNSA) and key national strategy guidance. We execute work across all of DOE's missions: national security, science, energy, and environmental management. Scientific and engineering capabilities developed through LANL's stockpile research are part of what makes DOE and NNSA a science, technology, and engineering powerhouse for the nation.
>
> Tags: data center, panther, storage
>
> [Original page](https://www.maxlinear.com/news/press-releases/2026/maxlinear-and-los-alamos-national-laboratory-jointly-advance-high-performance-file-system-accelerati)
