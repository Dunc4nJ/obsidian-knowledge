---
created: 2026-05-13
published: 2026-04-22
description: Marvell's acquisition of ETH Zurich plasmonics spinoff Polariton revives a decade-old plasmonic-organic-hybrid (POH) modulator path whose EO polymer fill is supplied externally by Lightwave Logic's Perkinamine, structurally linking MRVL to LWLG for the 3.2T+ roadmap.
source: https://x.com/PhotonCap/status/2047077702168133900
type: research
authors: ["Photon Capital (@PhotonCap)"]
---

# PhotonCap 2026-04-22 - Marvell day-of acquires Polariton plasmonics ETH spinoff with LWLG Perkinamine inside the POH stack for 3.2T roadmap

Day-of analysis (April 22, 2026) of [[Marvell Technology (MRVL)]]'s acquisition of Polariton Technologies — a Swiss ETH Zurich plasmonics spinoff — and what it implies for [[Lightwave Logic (LWLG)]] as the external supplier of the EO polymer (Perkinamine) inside Polariton's plasmonic-organic-hybrid (POH) modulator stack.

## Key Takeaways

- Polariton is the **first Marvell optical acquisition that targets device-level modulation physics**, not DSP (Inphi 2021), switch silicon (Innovium 2021), or interconnect architecture (Celestial AI 2025). Press-release language names the target generation as **"3.2T and beyond"**, with coherent and DCI (ZR/ZR+) applications called out specifically — i.e., this is a technology grab for the generation beyond [[Marvell Technology (MRVL)]]'s already-guided 1.6T.
- Polariton's **plasmonic-organic-hybrid (POH) modulators do not work without an EO polymer filler** — and the lead supplier of high-bandwidth EO polymer is [[Lightwave Logic (LWLG)]]'s Perkinamine, which recently demonstrated 200 Gbps/lane and passed Telcordia 85/85 reliability. PhotonCap's framing: Marvell internalized the plasmonic slot device but the polymer inside it remains an external dependency, creating a structural MRVL → LWLG link the acquisition does not eliminate.
- **Plasmonics was written off ~2017-2018** when NSF/DARPA funding shrank over the metal-loss problem (compressing photons into nanometer-scale metal slots costs insertion loss). The ETH Zurich Leuthold group quietly kept pushing through that decade and brought POH from tens-of-dB into single-digit-dB insertion loss, then hit a **1.1 THz EO bandwidth record in Optica (early 2025)** — a result Cignal AI's Optical Component Startup Tracker says rivals TFLN above 145 GHz and exceeds current SiPho and InP. The Marvell deal validates that the quiet 15-year grind paid off.
- Side-by-side across six modulator platforms (SiPho carrier, InP, TFLN, BTO, EO Polymer standalone, POH), **POH wins on energy and footprint by orders of magnitude**: Polariton's plasmonic IQ modulator runs 0.07 fJ/bit at 50 Gbit/s and 2 fJ/bit at 400 Gbit/s in a 4×25 µm × 3 µm active section, versus tens-of-mm and pJ-scale for standard silicon. Vπ·L of ~0.013 V·cm vs ~50 V·cm for SiPho carrier-based. The platform trade-off remains insertion loss vs efficiency-and-footprint.
- This acquisition stacks on top of the **Celestial AI deal (Dec 2025, $3.25B + $2.25B milestones)** — Celestial gave Marvell scale-up Photonic Fabric architecture, Polariton gives device-level modulation. Different layers of the same optical stack, both pointed at 3.2T+. Related public-ticker exposure called out by the author: [[Marvell Technology (MRVL)]], [[Broadcom (AVGO)]], [[Coherent (COHR)]], [[Lumentum (LITE)]], [[Lightwave Logic (LWLG)]].

## External Resources

- ETH Zurich + Polariton 1.1 THz plasmonic modulator record — published Optica, early 2025 ([8] in source). Cited as the demonstration that POH bandwidth scales into the THz regime.
- Cignal AI Optical Component Startup Tracker ([9]) — describes Polariton as rivaling TFLN above 145 GHz and exceeding current SiPho and InP capabilities.
- PhotonCap's earlier polymer-EO-modulator analysis: "The Next Materials War in Silicon Photonics: Polymer EO Modulators, Who Wins?" ([22]) — covers Lightwave Logic vs NLM Photonics in standalone EO polymer.
- Substack (paywalled continuation of this article, beyond section 4): https://substack.com/home/post/p-195175274

## Original Content

*Polariton (ETH Zurich spinoff) and Marvell logos paired above the "Marvell's Optical Acquisition Arc" timeline diagram — Inphi (2021, $10B, Optical DSP + SiPho), Innovium (2021, $1.1B, Ethernet Switch), Celestial AI (2025, $3.25B, Photonic Fabric), Polariton (2026, undisclosed, POH Modulator). A dashed callout under Polariton labels "LWLG Perkinamine (supplied externally)" — captioned "The one piece Marvell could not acquire."*
![[photoncap-133900-000.jpg]]

> [!quote]- @PhotonCap (Photon Capital) — 2026-04-22 (likes 66, retweets 8, replies 7)
>
> **Article: Marvell Acquires Swiss Plasmonics Startup Polariton: A Decade-Old Promise Returns, and LWLG is Inside**
>
> *Plasmonics was written off eight years ago. It just landed at the center of Marvell's 3.2T roadmap, with LWLG's Perkinamine inside*
>
> **Abstract**
>
> On April 22, 2026, Marvell (NASDAQ: MRVL) announced the acquisition of Polariton Technologies, a Swiss spinoff from ETH Zurich. Financial terms were not disclosed. This article traces how plasmonics, a field that swept academia in the 2010s and seemed to quietly disappear, found its way back to the center of a major semiconductor company's optical roadmap in 2026, and how this acquisition creates a structural link between Marvell and Lightwave Logic (LWLG). Related tickers: $MRVL, $AVGO, $COHR, $LITE, $LWLG.
>
> **Contents**
>
> 1. Marvell's Optical Acquisition Timeline
> 2. Who Polariton Is
> 3. A Decade of Plasmonics: Hype, Cooldown, and Quiet Commercialization
> 4. Six Modulator Platforms, Side by Side
> 5. So Marvell Now Has Indirect Exposure to LWLG (paid)
> 6. Celestial AI vs Polariton: Different Layers
> 7. Connection to the 3.2T Roadmap
> 8. Closing: A Photonics Engineer's Surprise
>
> ## 1. Marvell's Optical Acquisition Timeline
>
> Marvell has made four optical-related acquisitions over the past five years.
>
> - **2021: Inphi** ($10B), coherent DSP and silicon photonics full stack [1]
> - **2021: Innovium** ($1.1B), Ethernet switch silicon [2]
> - **2025.12: Celestial AI** ($3.25B + $2.25B milestones), Photonic Fabric, scale-up optical interconnect [3]
> - **2026.4: Polariton Technologies** (undisclosed), plasmonic modulator [4]
>
> Here is what stands out. The Inphi deal put Marvell at the top of the optical DSP industry. The Celestial AI deal secured a scale-up architecture position. Polariton is different. It is the first acquisition where Marvell bets on device-level modulation technology itself. The direction is clearly distinct.
>
> The press release names the explicit target as "3.2T and beyond," with coherent and DCI applications like ZR/ZR+ called out specifically [4]. In other words, this is a technology grab for the generation beyond the already-guided 1.6T.
>
> ## 2. Who Polariton Is
>
> Polariton Technologies is a Swiss company that spun out of Prof. Jürg Leuthold's group at ETH Zurich in 2019 [5]. The company holds the distinction of being the first in the world to commercialize plasmonics-based electro-optic products [6].
>
> All three co-founders were PhDs from Leuthold's group: CEO Claudia Hoessbacher (measurement and characterization), co-CTO Wolfgang Heni (devices), and Benedikt Bäuerle (system engineering). Leuthold himself worked at Bell Labs from 1999 to 2004 on III-V and silicon photonics high-speed communication devices, and currently leads the Institute of Electromagnetic Fields (IEF) at ETH Zurich [7].
>
> The product line consists of PICs (Photonic Integrated Circuits) implementing plasmonic Mach-Zehnder and ring resonator modulators on a silicon photonics platform. They support both 1310nm and 1550nm, and also offer a custom design service [5]. In 2024, the company characterized MZMs and IQ modulators up to 145 GHz [6], and in early 2025, together with ETH Zurich, they published a record of EO bandwidth measured up to 1.1 THz in Optica [8].
>
> Cignal AI's Optical Component Startup Tracker describes Polariton as rivaling TFLN at bandwidths above 145 GHz, and exceeding current SiPho and InP capabilities [9].
>
> ## 3. A Decade of Plasmonics: Hype, Cooldown, and Quiet Commercialization
>
> Personally, this is the most interesting part of the story, so I will spend a bit more space here.
>
> **Early-to-Mid 2010s, Plasmonics Was Genuinely Hot**
>
> I remember the atmosphere when UC Berkeley's Xiang Zhang group published their hyperlens paper in Science in 2007 [10]. The idea of stacking metal thin films to break the optical diffraction limit. The following year the same group published 3D negative-index metamaterials in Nature, and Discover and Time picked it as one of the innovations of the year [11]. Caltech's Harry Atwater proposed plasmonic solar cells in Nature Materials around the same time [12], and Stanford's Mark Brongersma was working on plasmonic waveguides.
>
> [Image — screenshot of *Nature Materials* review article landing page; transcribed verbatim below]
>
> > **Review Article | Published: 19 February 2010**
> > **Plasmonics for improved photovoltaic devices**
> > Harry A. Atwater & Albert Polman
> > *Nature Materials* 9, 205–213 (2010)
> > 67k Accesses · 7901 Citations · 54 Altmetric
> >
> > **Abstract**
> > The emerging field of plasmonics has yielded methods for guiding and localizing light at the nanoscale, well below the scale of the wavelength of light in free space. Now plasmonics researchers are turning their attention to photovoltaics, where design approaches based on plasmonics can be used to improve absorption in photovoltaic devices, permitting a considerable reduction in the physical thickness of solar photovoltaic absorber layers, and yielding new options for solar-cell design. In this review, we survey recent advances at the intersection of plasmonics and photovoltaics and offer an outlook on the future of solar cells based on these principles.
>
> *Berkeley News piece on the 2007 UC Berkeley hyperlens demonstration (Xiang Zhang group), with a schematic of an optical hyperlens magnifying and projecting sub-diffraction-limit features through a conventional lens into a far-field image.*
> ![[photoncap-133900-002.jpg]]
>
> Half the keynotes at every conference were about plasmonics. Surface plasmon polaritons, the spaser (plasmonic laser), metamaterial cloaks, negative refraction, hyperlenses, plasmonic solar cells, sub-diffraction imaging. Just reading the titles, it felt like the world was about to change within ten years.
>
> Leuthold's group was part of this wave too. Starting at KIT and later moving to ETH Zurich, the group published a plasmonic absorption modulator in Optics Express in 2011 [13], then in 2014 published a "29 µm long, 65 GHz bandwidth" phase modulator in Nature Photonics [14]. Christian Haffner from the same group published a 10 µm all-plasmonic Mach-Zehnder modulator in Nature Photonics in 2015 [15], followed by a "low-loss plasmon-assisted" modulator in Nature in 2018 [16]. Polariton was founded in 2019 on top of this technology stack.
>
> *Melikyan et al, "High-speed plasmonic phase modulators," Nature Photonics 8, 229–233 (published online 16 February 2014). Figure 1 shows PPM field distributions and a schematic of the plasmonic phase modulator — the modulator structure consists of a sub-wavelength-cross-section plasmonic slot waveguide filled with EO polymer, sandwiched between two metal electrodes that double as the optical mode confinement boundary.*
> ![[photoncap-133900-006.jpg]]
>
> **Then the Funding Dried Up**
>
> Around 2017 to 2018, the mood shifted. Plasmonics got pegged as "attractive in principle but unclear as a commercial path." The reason came down to one thing: metal loss. Compressing light into nanometer scales requires using collective electron oscillations at a metal surface, but that means photons get absorbed into the metal, adding significant insertion loss. Over tens of centimeters of fiber link, this is fatal.
>
> NSF and DARPA plasmonics grants shrank meaningfully, and many researchers pivoted toward metasurfaces, topological photonics, quantum plasmonics, and 2D materials. By the early 2020s, the industry perception had settled on "plasmonics is a technology that ended at the research stage." Xiang Zhang himself moved to become Vice-Chancellor of the University of Hong Kong, so his academic position shifted as well.
>
> [Image — screenshot of Xiang Zhang's UC Berkeley Mechanical Engineering faculty page; transcribed verbatim below]
>
> > **Xiang Zhang**
> > Professor Emeritus of Mechanical Engineering
> > Ernest S. Kuh Endowed Chair, in the Department of Mechanical Engineering (2009-2019)
> > Email: xzhang@me.berkeley.edu
> > Office: University of California, Berkeley, CA 94720-1740
> >
> > Professor Xiang Zhang is the inaugural Ernest S. Kuh Endowed Chaired Professor of UC Berkeley and the Director of NSF Nano-scale Science and Engineering Center (NSEC). He is the Director of the Materials Sciences Division at Lawrence Berkeley National Laboratory (LBNL), as well as a member of the Kavli Energy Nano Science Institute.
> >
> > Professor Zhang is an elected member of US National Academy of Engineering (NAE), Academia Sinica (National Academy in Republic of China), and Fellow of five scientific societies: APS (The American Physical Society), OSA (The Optical Society of America), AAAS (The American Association for the Advancement of Science), SPIE (The International Society of Optical Engineering), and ASME (The American Society of Mechanical Engineers).
>
> **But the ETH Zurich Group Kept Going**
>
> This is the part I personally find most admirable. The Leuthold group took the metal loss problem head-on, combined it with polymer-based Pockels effect into a POH (plasmonic-organic hybrid) path, and kept pushing. Melikyan 2014, Haffner 2015, Ayata 2017 (Science, single metal layer), Haffner 2018 (Nature, low-loss), Heni 2019 (Nature Communications, attojoule IQ modulator) [17]. Each paper pushed bandwidth up, reduced power, cut loss, shrank footprint.
>
> Polariton was founded in 2019. MZMs and IQ modulators were characterized up to 145 GHz in the early-to-mid 2020s. In 2025, the 1.1 THz measurement with ETH came [8]. While the community thought the technology was done, one group in Switzerland quietly kept breaking bandwidth records.
>
> [Image — Polariton / ETH Zurich press release dated March 4, 2025, Zurich, Switzerland; transcribed verbatim below, with the source's yellow highlight on "1.1 THz" rendered as **bold**]
>
> > **Press Release: ETH Zurich and Polariton Technologies Achieve Record-Breaking Electro-Optic Bandwidth with Plasmonic Modulators**
> >
> > March 4, 2025 — Zurich, Switzerland
> >
> > Polariton Technologies AG, an ETH Zurich spin-off, together with ETH Zurich have set a new benchmark in the field of electro-optic (EO) modulators with their latest innovation.
> >
> > **"Ultra-Wideband MHz to THz Plasmonic Electro-Optic Modulator"** — this study by Yannik Horst et al. showcases state-of-the-art plasmonic modulators that achieve an EO bandwidth extending into the terahertz (THz) range.
> >
> > The team at ETH Zurich, led by Juerg Leuthold, has successfully demonstrated the frequency response up to **1.1 THz**, with a 3-dB bandwidth of 997 GHz and a 6-dB bandwidth above 1 THz. These results of devices, manufactured by Polariton and characterized by ETH Zurich, showcase the team's commitment to pushing the boundaries of technology.
> >
> > Dr. Yannik Horst, first author of the study, comments, "This achievement confirms the potential of plasmonic modulators to bring THz frequencies to photonic integrated circuits (PICs). For many years, its capability beyond 500 GHz was just theory." Building on the results of Burla et al. (APL Photonics, 2019), measurements up to 1.1 THz are now possible thanks to an optimized modulator design and improved electronics.
> >
> > Dr. Wolfgang Heni, co-CTO of Polariton, adds, "These results show the vast usability of plasmonic modulators, from high-data-rate fiber communications to simple, linear, ultra-broadband THz receivers. The linear DC-to-THz bandwidth within a single device enables broadband field detection over a wide frequency range. Consequently, these devices open up numerous new applications in THz imaging, sensing, and wireless communications."
> >
> > Key highlights:
> >
> > - **Unprecedented EO Bandwidth**: Plasmonic modulators achieve an EO bandwidth ranging from 10 MHz to 1.1 THz, surpassing previous records and expanding the accessible EO frequency range to more than double that of earlier measurements.
> > - **Future-proof solution for 400G/lane and beyond**: Polariton's ultra-broadband EO modulators offer a technology for silicon photonics-based optical communication at and beyond 400G/lane.
> > - **Applications in THz Technology**: The modulators' unique suitability for THz PICs paves the way for advancements in wireless communication, …
>
> ## 4. Six Modulator Platforms, Side by Side
>
> To understand what the Polariton acquisition really means, you need to see the current high-speed optical modulator landscape. No single platform is outright best. Each carries different trade-offs.
>
> [Image — Korean-language six-platform comparison table; transcribed verbatim and translated below]
>
> | Platform | Underlying principle | Representative bandwidth | Vπ·L | Foundry maturity | Representative players |
> |---|---|---|---|---|---|
> | **SiPho carrier-based** | plasma dispersion | ~50 GHz (MRM), ~110 GHz (optimized MZM) | several V·cm | highest | TSMC, GlobalFoundries, Tower |
> | **InP** | Franz-Keldysh / QCSE | 67+ GHz | – | medium | Coherent, Lumentum |
> | **TFLN** | Pockels (r₃₃ ~30 pm/V) | 100-170 GHz | ~1 V·cm | medium | HyperLight, academia (Harvard / Columbia) |
> | **BTO** | Pockels (r₄₂ ~900 pm/V) | lab ~30-50 GHz | ~0.2 V·cm | low | Lumiphase (IBM spinoff) |
> | **EO Polymer standalone** | Pockels (r₃₃ ~several hundred pm/V) | 60-200+ GHz | ~0.1 V·cm | medium | Lightwave Logic ($LWLG) |
> | **POH (Polymer + Plasmonic)** | Pockels + SPP field compression | 145 GHz ~ 1.1 THz | ~0.013 V·cm | low → medium | Polariton (Marvell acquired) |
>
> Let me walk through each.
>
> Silicon carrier-based is the workhorse for AI data center optical modules today. It relies on the plasma dispersion effect (free-carrier density shifts change both refractive index and absorption), but this is not pure phase modulation, so chirp is intrinsic. That said, mature CMOS foundry infrastructure and 200mm / 300mm wafer ecosystems make it the cheapest platform to produce.
>
> InP is a III-V semiconductor platform where EAMs are built on Franz-Keldysh or quantum-well (QCSE) effects. It has the advantage of native integration with lasers, but heterogeneous integration with silicon photonics is process-heavy. Coherent and Lumentum have used this technology for many years.
>
> TFLN (thin-film lithium niobate) is a platform where a LiNbO₃ thin film is bonded onto silicon via "smart-cut" processing. It allows pure phase modulation through the Pockels effect, and achieves both wide bandwidth and CMOS-compatible drive voltage. This is why it has been the most watched next-gen candidate in recent years. However, smart-cut wafer supply is still stuck at 6 inch (NanoLN, Partow, NGK, SRICO), and foundry integration still needs time.
>
> BTO (barium titanate) has a Pockels coefficient r₄₂ around 900 pm/V, roughly 30 times that of LiNbO₃ (30 pm/V). In principle, it is one of the most attractive EO materials available [18]. IBM Zurich has studied it for years, and the spinoff Lumiphase was founded in 2020 [19]. However, epitaxial growth of BTO films on silicon is complex (it requires a SrTiO₃ buffer layer and careful crystallographic orientation control). BTO Mach-Zehnder modulators have reached Vπ·L of 0.2 V·cm [20], but foundry maturity is still early.
>
> EO Polymer standalone applies organic chromophores with extremely high Pockels coefficients via spin coating on silicon. It is compatible with back-end-of-line processing, and with Vπ·L around 0.1 V·cm, sub-volt drive is possible. The lead player is Lightwave Logic (NASDAQ: LWLG). The company's Perkinamine polymer recently demonstrated 200 Gbps per lane and passed Telcordia 85/85 (85℃, 85% humidity) reliability testing [21]. Polymers historically had weaknesses in thermal, moisture, and photo stability, but as these have improved, 2025 marks the year the technology entered a commercialization path. The broader polymer EO modulator ecosystem and the competitive landscape (NLM Photonics and others) were analyzed in detail in our earlier article *The Next Materials War in Silicon Photonics: Polymer EO Modulators, Who Wins?* [22].
>
> POH (Plasmonic-Organic Hybrid) is today's main character. At the physics level, it is an EO polymer injected into a plasmonic slot. A metal-organic-metal slot compresses the electromagnetic field down to nanometer scale, and the EO polymer inside the slot shifts the phase with extreme efficiency. The analogy: take an already powerful EO polymer and confine it inside a very narrow nozzle, so the same input produces a much larger output. Polariton's plasmonic IQ modulator has an active section of 4×25 µm × 3 µm [17], with 0.07 fJ/bit at 50 Gbit/s and 2 fJ/bit at 400 Gbit/s. Considering that standard silicon modulators need tens of mm of active section and pJ-scale energy, the orders of magnitude are different.
>
> Metal loss remains a real issue. Insertion loss is larger than for standard silicon modulators or TFLN. That said, the Leuthold group has spent 15 years bringing it down from tens of dB into the single-digit dB range, and it has now entered the practical range.
>
> *Marvell's Optical Acquisition Arc — Inphi (2021, $10B, Optical DSP + SiPho), Innovium (2021, $1.1B, Ethernet Switch), Celestial AI (2025, $3.25B, Photonic Fabric), Polariton (2026, undisclosed, POH Modulator). A dashed callout under Polariton labels "LWLG Perkinamine (supplied externally)" — captioned "The one piece Marvell could not acquire."*
> ![[photoncap-133900-007.jpg]]
>
> There is one more variable worth calling out here. Marvell's Polariton acquisition does not fully internalize the POH modulator stack. One critical piece remains outside what Marvell could buy, and because of that piece, this acquisition quietly repositions another publicly traded company. Let me unpack it below.
>
> ---
>
> 🔒 *For the full in-depth analysis, subscribe on Substack. A condensed summary will be shared on X.*
>
> https://substack.com/home/post/p-195175274

---

Source: <https://x.com/PhotonCap/status/2047077702168133900>
