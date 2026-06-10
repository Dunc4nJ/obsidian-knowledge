---
created: 2026-06-10
published: 2026-04-30
description: MaxLinear's Washington four-lane 200G/lane SiGe TIA for 1.6T AI datacenter optics samples now at ~750mW typical, interoperates with all major PAM4 DSP vendors (not MXL-exclusive), with mass production scheduled for H2 2026.
source: https://www.maxlinear.com/news/press-releases/2026/maxlinear-announces-availability-of-washington-200g-tia-for-next-generation-ai-data-center-connectiv
type: research
---

## Key Takeaways

- **Product (a)**: Washington is "a four-lane, 200G/lane transimpedance amplifier designed for 1.6T optical transceiver modules for AI data center applications," "built in a robust, high-yielding SiGe process technology." This is [[MaxLinear (MXL)]]'s entry into the merchant TIA market dominated by [[Semtech (SMTC)]] and [[MACOM Technology (MTSI)]]; the release does not name a foundry, but SiGe BiCMOS optical front-ends are the core franchise of [[Tower Semiconductor (TSEM)]]. The release also claims Washington "is pad-compatible with other leading TIAs and most flip-chip high-speed photodetectors on the market" — explicit drop-in-replacement positioning against incumbent TIAs.
- **Power (b)**: "Power consumption: \~750mW typical for four channels" — i.e. roughly 187mW per 200G channel for the linear analog front end.
- **Schedule (c)**: "Samples of Washington are available now. Mass production is scheduled for the second half of 2026." This is a forward-looking statement — the BusinessWire version's Cautionary Note explicitly lists "potential delays to the timing of the sample of the 16-lane, 3.2T Makalu on-board scale-up retimer and the timing and our ability to mass produce Washington" among risk factors. Mass-production timing is a company projection, not a fact.
- **Architecture coverage (d)**: Washington is "the first product in a planned family of low-noise TIAs designed to support next-generation fully retimed, half-retimed, and linear interfaces, including LRO/LPO, NPO, XPO, and CPO applications" — the TIA content claim spans every contested optics architecture, including the co-packaged-optics endgame, which matters for the CPO-delay debate covered in [[MXL 2026-06-10 briefing - optical DSP re-rating thesis, Q1 FY26 infrastructure up 136 pct, Rushmore 1.6T Samsung ramp, five-pillar bull case amid CPO delay debate]].
- **CRITICAL — not MXL-exclusive (e)**: "Washington interoperates with PAM4 DSPs from all major PAM4 DSP vendors." The TIA is a vendor-agnostic merchant part, NOT locked to MaxLinear's own DSPs. Pairing with MaxLinear's Rushmore DSP only "enables additional system-level optimization through close analog-digital co-optimization across the receive signal chain" — an incremental benefit, not a bundling requirement. Any bull thesis assuming Washington pulls through Rushmore attach (or vice versa) overreads this release.
- **NO 30% energy claim (f)**: The release contains **no "30%" figure of any kind, and the word "energy" does not appear anywhere in the text** (verified mechanically by grep against the full source). Circulating bull threads claiming a "30% energy consumption advantage" for Washington are unsourced from this press release — the only quantified power claim is the ~750mW figure in (b).
- **Market sizing (g)**: Per SVP/GM Rajneesh Gaur: "Industry analysts project the fully retimed pluggable optics market with TIAs to exceed 150 million units by 2030, with the LPO and LRO segments surpassing 20 million units." The analysts are unnamed, and these projections are explicitly captured by the forward-looking-statements boilerplate.
- **Portfolio cadence (h)**: "The 16-lane, 3.2T Makalu on-board scale-up retimer is scheduled to sample in the fourth quarter of 2026." Context from same paragraph: Keystone DSP "is in volume production for 400G and 800G applications"; the "1.6T Rushmore family of optical DSPs with integrated drivers and the Annapurna copper DSP for active electrical cables are sampling today."

## External Resources

- [BusinessWire mirror](https://www.businesswire.com/news/home/20260430079710/en/MaxLinear-Announces-Availability-of-Washington-200G-TIA-for-Next-Generation-AI-Data-Center-Connectivity) — wire version of the same release; includes the Cautionary Note About Forward-Looking Statements and press contact omitted from MaxLinear's Newscenter page (both reproduced in the addendum below).
- [MaxLinear](https://www.maxlinear.com/) — company site, linked from the release.

## Original Content

> [!quote]- Source Material — MaxLinear Newscenter press release (2026-04-30)
>
> # MaxLinear Announces Availability of Washington 200G TIA for Next-Generation AI Data Center Connectivity
>
> April 30, 2026
>
> _Four-channel, 200G/lane high-speed transimpedance amplifier enables cost-effective, power-efficient, fully retimed PAM4 optical signaling for next-generation 1.6T optical interconnects_
>
> *Press-release banner (mixed image: marketing card with chip package render labeled "MxL Washington 4x200G" over a datacenter-aisle backdrop). Text in image: "Washington 200G TIA — Enabling Cost-Effective, Power-Efficient 1.6T Optical Connectivity for AI Data Centers", MaxLinear logo bottom-left.*
> ![[maxlinear-washington-001.jpg]]
>
> **CARLSBAD, CA** – (BUSINESS WIRE)– April 30, 2026 – MaxLinear, Inc. (Nasdaq: MXL), a leading provider of high‑speed interconnect ICs for data center, metro, and wireless transport networks, today announced availability of its Washington TIA, a four-lane, 200G/lane transimpedance amplifier designed for 1.6T optical transceiver modules for AI data center applications. As hyperscale data centers scale bandwidth and reach to support larger AI clusters, Washington delivers a low-power, low-noise linear analog front end tailored for next-generation optical architectures.
>
> Washington is the first product in a planned family of low-noise TIAs designed to support next-generation fully retimed, half-retimed, and linear interfaces, including LRO/LPO, NPO, XPO, and CPO applications. As the latest addition to MaxLinear’s expanding data center portfolio, Washington complements the company’s comprehensive set of building blocks, including DSPs, TIAs, drivers, and SERDES, enabling customers to architect systems optimized for their specific performance, power, and reach requirements.
>
> As data center networks evolve from today’s 800G connectivity toward next generation 1.6T and beyond, data center operators and module vendors face increasing pressure to scale bandwidth while tightly managing power consumption, signal integrity, and total cost of ownership (TCO). Washington is designed to address these challenges with a high-bandwidth analog front end optimized for power efficiency and noise performance, built in a robust, high-yielding SiGe process technology.
>
> Washington interoperates with PAM4 DSPs from all major PAM4 DSP vendors, delivering system-level advantages in efficiency and signal quality across a broad range of system architectures. When paired with MaxLinear’s Rushmore PAM4 DSP, Washington enables additional system-level optimization through close analog‑digital co‑optimization across the receive signal chain. Its flat frequency response helps minimize and overcome the impact of high-frequency system parasitics to deliver robust system-level signal integrity, reach, and performance.
> Washington is pad-compatible with other leading TIAs and most flip-chip high-speed photodetectors on the market, simplifying integration into existing 1.6T module designs.
>
> **Washington TIA Key Features**
> * Power consumption: \~750mW typical for four channels
> * Four-channel TIA with 750µm lane spacing
> * Low noise, low group delay, excellent linearity
> * Integrated, programmable automatic gain control (AGC)
> * Integrated photodiode bias and per-channel received signal strength indicator (RSSI)
> * I2C control and monitoring
> * Advanced SiGe process node
>
> “The TIA market for AI data center connectivity represents a significant growth opportunity for MaxLinear,” said Rajneesh Gaur, SVP & GM, Data Center Connectivity Business Unit at MaxLinear. “Industry analysts project the fully retimed pluggable optics market with TIAs to exceed 150 million units by 2030, with the LPO and LRO segments surpassing 20 million units. Washington and next generation TIA products position MaxLinear to capture meaningful share across all three segments with a versatile product family.”
>
> Washington expands MaxLinear’s growing portfolio of connectivity solutions for AI-driven scale-up and scale-out architectures, across both optical and copper interconnects. MaxLinear’s Keystone DSP platform is in volume production for 400G and 800G applications. The 1.6T Rushmore family of optical DSPs with integrated drivers and the Annapurna copper DSP for active electrical cables are sampling today. The 16-lane, 3.2T Makalu on-board scale-up retimer is scheduled to sample in the fourth quarter of 2026.
>
> Samples of Washington are available now. Mass production is scheduled for the second half of 2026.
>
> **About MaxLinear, Inc.**
> MaxLinear, Inc. (Nasdaq: MXL) is a leading provider of radio frequency (RF), analog, digital, and mixed-signal integrated circuits for access and connectivity, wired and wireless infrastructure, and industrial and multimarket applications. MaxLinear is headquartered in Carlsbad, California. For more information, please visit <https://www.maxlinear.com/>.
>
> MaxLinear, the MaxLinear logo, any other MaxLinear trademarks are all property of MaxLinear, Inc. or one of MaxLinear's subsidiaries in the U.S.A. and other countries. All rights reserved.
>
> All third-party marks and logos are trademarks or registered trademarks of their respective holders/owners.
>
> Tags: AI Infrastructure · Data Center · TIA
>
> [Original page](https://www.maxlinear.com/news/press-releases/2026/maxlinear-announces-availability-of-washington-200g-tia-for-next-generation-ai-data-center-connectiv)

> [!quote]- Addendum — sections present only in the BusinessWire wire version (omitted from MaxLinear's Newscenter page)
>
> **Cautionary Note About Forward-Looking Statements**
>
> This press release contains forward-looking statements within the meaning of Section 27A of the Securities Act of 1933, as amended, and Section 21E of the Securities Exchange Act of 1934, as amended. Forward-looking statements include, among others, statements relating to MaxLinear’s Washington and next generation TIA products and the functionality, performance and benefits of such product, statements relating to MaxLinear’s ability to grow its portfolio; statements about the potential market opportunity for such product and the market for the fully retimed pluggable optics market, the scaling of hyperscale data centers, the ability of MaxLinear to capture share across all three segments the timing of the sample of the 16-lane, 3.2T Makalu on-board scale-up retimer, the timing of the commencement of mass production of Washington and statements by MaxLinear’s SVP & GM, Data Center Connectivity Business Unit. These forward-looking statements involve known and unknown risks, uncertainties, and other factors that may cause actual results to be materially different from any future results expressed or implied by the forward-looking statements and our future financial performance and operating results forecasts generally. Forward-looking statements are based on management’s current, preliminary expectations and are subject to various risks and uncertainties. In particular, our future operating results are substantially dependent on our assumptions about market trends and conditions. Additional risks and uncertainties affecting our business, future operating results and financial condition include, without limitation; risks relating to: the development, testing, and commercial introduction of new products and product functionalities; the capabilities of our technology; potential delays to the timing of the sample of the 16-lane, 3.2T Makalu on-board scale-up retimer and the timing and our ability to mass produce Washington; our ability to capture share across all three segments with the Washington and next generation TIA products; factors impacting our ability to grow our portfolio; the development of the market for our Washington and next generation TIA products; our terminated merger with Silicon Motion and related arbitration and class action complaint and the risks related to potential payment of damages; the effect of intense and increasing competition; increased tariffs, export controls or imposition of additional trade barriers; impacts of global economic conditions; the cyclical nature of the semiconductor industry; a significant variance in our operating results and impact on volatility in our stock price, and our ability to sustain our current level of revenue, which has previously declined, and/or manage future growth effectively, and the impact of excess inventory in the channel on our customers’ expected demand for certain of our products and on our revenue; escalating trade wars, military conflicts and other geopolitical and economic tensions among the countries in which we conduct business; international geopolitical and military conflicts; our ability to obtain or retain government authorization to export certain of our products or technology; the loss of, or a significant reduction in orders from major customers; legal proceedings or potential violations of regulations; information technology failures; a decrease in the average selling prices of our products; failure to penetrate new applications and markets; development delays and consolidation trends in our industry; inability to make substantial and productive research and development investments; delays or expenses caused by undetected defects or bugs in our products; substantial quarterly and annual fluctuations in our revenue and operating results; failure to timely develop and introduce new or enhanced products; order and shipment uncertainties and differences between our estimates of customer demand and product mix and our actual results; failure to accurately predict our future revenue and appropriately budget expenses; lengthy and expensive customer qualification processes; customer product plan cancellations; failure to maintain compliance with government regulations; failure to attract and retain qualified personnel; any adverse impact of rising interest rates on us, our customers, and our distributors and related demand; risks related to compliance with privacy, data protection and cybersecurity laws and regulations; risks related to conforming our products to industry standards; risks related to business acquisitions and investments; claims of intellectual property infringement; our ability to protect our intellectual property; security vulnerabilities of our products; use of open source software in our products; failure to manage our relationships with, or negative impacts from, third parties; and future decisions relating to our stock repurchase program.
>
> In addition to these risks and uncertainties, investors should review the risks and uncertainties contained in our filings with the Securities and Exchange Commission, including our Current Reports on Form 8-K, as well as the information to be set forth under the caption "Risk Factors" in MaxLinear's Annual Report on Form 10-K for the year ended December 31, 2025. All forward-looking statements are based on the estimates, projections and assumptions of management as of the date of this press release, and MaxLinear is under no obligation (and expressly disclaims any such obligation) to update or revise any forward-looking statements whether as a result of new information, future events, or otherwise.
>
> **Contacts**
>
> MaxLinear Press Contact:
> Debbie Brandenburg
> Sr. Marketing Communications Manager
> Tel: +1 669.265.6083
> dbrandenburg@maxlinear.com
>
> [BusinessWire version](https://www.businesswire.com/news/home/20260430079710/en/MaxLinear-Announces-Availability-of-Washington-200G-TIA-for-Next-Generation-AI-Data-Center-Connectivity)
