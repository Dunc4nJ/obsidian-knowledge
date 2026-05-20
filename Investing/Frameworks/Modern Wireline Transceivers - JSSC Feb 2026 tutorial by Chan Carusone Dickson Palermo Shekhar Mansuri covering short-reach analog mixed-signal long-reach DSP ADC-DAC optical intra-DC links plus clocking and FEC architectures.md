---
created: 2026-05-20
published: 2026-02-01
description: Comprehensive IEEE JSSC tutorial by Chan Carusone (U Toronto / Alphawave Semi CTO) and co-authors at IBM Research, Texas A&M, UBC, and Intel on modern serial-link transceiver architectures — short-reach analog/mixed-signal (PAM4 CTLE, DFE, FFE), long-reach DSP with high-speed ADCs/DACs (>30 dB Nyquist loss), optical intra-DC links (TIAs, drivers, EMLs, MZMs), low-jitter clocking, and FEC roadmap toward 200+ Gb/s per lane. Foundational reference layer for vault theses on AAOI/COHR/LITE/MTSI/SMTC/CRDO/MRVL/AVGO/ALAB/MXL/AWE.L.
source: https://ieeexplore.ieee.org/document/11311714
type: framework
authors: ["Tony Chan Carusone", "Timothy O. Dickson", "Samuel Palermo", "Sudip Shekhar", "Mozhgan Mansuri"]
---

# Modern Wireline Transceivers — IEEE JSSC Feb 2026 tutorial

*Published in IEEE Journal of Solid-State Circuits, Vol. 61, No. 2, February 2026, pp. 395+. DOI: 10.1109/JSSC.2025.3642231. Received 31 July 2025; accepted 2 December 2025; date of publication 23 December 2025.*

## Why this paper matters for investing

This is the academic-reference layer beneath the vault's investment-framework notes on optical and SerDes infrastructure. The investing question — which companies own which slot in the optical and electrical wireline stack — depends on understanding *what the slot actually is*: what equalization a CTLE versus a DFE versus an ADC-DSP receiver actually solves; why analog/mixed-signal links dominate <10 dB Nyquist-loss channels and DSP/ADC-DAC links dominate >30 dB loss channels; how PAM4 modulation, FEC, and CDR architectures determine which IC vendors can credibly sell into 224 Gb/s and 400 Gb/s lane-rate buildouts. Read this paper *before* re-reading the 7-layer optical investment maps because it grounds the "where is the bottleneck" question in actual silicon physics.

Five direct read-acrosses:

1. **Lead author Tony Chan Carusone is CTO of [[Alphawave Semi (AWE.L)]]** (Toronto SerDes IP company). His co-author Timothy O. Dickson is at IBM Research Yorktown. Samuel Palermo is at Texas A&M. Sudip Shekhar is at UBC. Mozhgan Mansuri is at Intel Hillsboro. This author roster is the actual current frontier of academic+industry SerDes design — what they describe is what AWE.L / [[Credo Technology (CRDO)]] / [[Astera Labs (ALAB)]] / [[Broadcom (AVGO)]] / [[Marvell Technology (MRVL)]] / [[MaxLinear (MXL)]] all ship.
2. **The analog↔DSP boundary** the paper draws (and where it's moving) maps directly to revenue concentration: short-reach (XSR/VSR <15 dB loss) is the analog/mixed-signal CTLE-DFE-FFE regime; long-reach (LR 30+ dB loss) is the ADC-DSP-FEC regime. Companies investing today in analog-only IP face structural compression as channel-loss budgets continue to grow.
3. **Optical interface circuits (Section IV)** detail the TIA/driver/EML/MZM stack that [[MACOM Technology (MTSI)]], [[Semtech (SMTC)]], and [[Sivers Semiconductors (SIVE.ST)]] (analog) plus [[Coherent (COHR)]] / [[Lumentum (LITE)]] / [[Applied Optoelectronics (AAOI)]] (modules) deliver. The "Classifying Various E/O Modulators" section provides the SiPh MZM vs TFLN vs EAM vs LiNbO3 reference taxonomy that informs the [[Lightwave Logic (LWLG)]] and Chinese TFLN-modulator theses.
4. **Forward Error Correction (Section III.D)** sits beneath every modern 100G+ link. FEC moves from hard-decision toward soft-decision concatenated codes (LDPC + BCH, Turbo + Reed-Solomon) in the future-directions section — feeds the DSP-IC value capture (CRDO, MRVL, AVGO) at the expense of pure-PHY vendors.
5. **Test & qualification implications** (paper doesn't cover test explicitly but the high-speed ADC, DAC, eye-diagram, and BER characterization burdens described all imply heavy spend on [[Keysight (KEYS)]], [[Viavi (VIAV)]], [[FormFactor (FORM)]], [[Aehr Test Systems (AEHR)]] gear at every node transition).

## Key takeaways for investors

- **The 200+ Gb/s/lane roadmap is here.** Future Directions explicitly targets 400 Gb/s serial as the obvious next step, with 6-PAM/8-PAM as enabling modulation formats. This is the demand frame for SerDes IP licensors ([[Alphawave Semi (AWE.L)]], [[Credo Technology (CRDO)]]) over the next 3-5 years.
- **CMOS scaling disproportionately benefits DSP architectures over analog ones.** SAR ADCs in particular became energy-efficient at <28 nm and now anchor the receive path. This explains why DSP-IC names ([[Marvell Technology (MRVL)]], [[Credo Technology (CRDO)]], [[MaxLinear (MXL)]]) capture an increasing share of long-reach link revenue.
- **The 28 nm inflection point.** "A key inflection point arose at 28 nm CMOS, which coincided with the increasing use of 4-PAM at 56 Gb/s and DSP equalization." This is the silicon-economic boundary that separated 50G NRZ from 100G+ PAM4 — and it's a fixed anchor for thinking about 224G/448G transitions at 5 nm and below.
- **Energy efficiency is the new bottleneck.** State-of-the-art 112 Gb/s PAM4 transceivers can be below 3 pJ/bit on very short channels; longer-reach 56-224 Gb/s links with heavy DSP demand 5 pJ/bit or more. "Interconnect power can dominate in AI training racks and switches" — a direct citation of the AI-buildout thesis driving spend on SerDes IP + optical modules.
- **Co-packaged copper interconnects are emerging as a near-term alternative** to "copper escape" problems at multi-hundred-Gb/s speeds, alongside (not replacing) optical CPO. This is the underappreciated nuance to the CPO debate captured in the vault's photonics-stack notes.
- **The DFE/CTLE/FFE equalization toolbox is mature for analog short-reach** but the DSP toolbox (FFE + DFE + MLSD + soft-decision FEC) is the long-reach answer. ADC-DSP receivers exist commercially and the paper describes their architecture in detail (Section III.B) — but the "function:" subsection [docling artifact — likely the heading "Functions of an ADC-DSP RX"] discusses the BW/jitter/INL/DNL specs that gate adoption.
- **CDR and clocking** (Section V) is the silent bottleneck on jitter-limited links. State-of-the-art designs achieve sub-ps RMS jitter via injection-locked oscillators, LC-PLL with very high reference frequencies, and multi-phase generator/phase-interpolator structures — heavy R&D investment.
- **Chiplet-based systems-in-package will partition compute and connectivity across multiple dies** (Future Directions). This is the architectural axis on which [[Astera Labs (ALAB)]] (PCIe/CXL retimers as die-to-die), [[Broadcom (AVGO)]] (SerDes IP), and [[Credo Technology (CRDO)]] (active electrical cables, retimers) all compete.

## Paper structure overview

Section headings as captured (use these as navigation anchors when re-reading the verbatim body below):

- **Abstract** + **Index Terms** (Clocking, connectivity, data centers, DSP, equalization, optical, PAM, SerDes, wireline)
- **I. Introduction**
  - A. Background (Channel Characteristics and Signaling; Key Performance Metrics; XSR/VSR/MR/LR taxonomy; Energy efficiency; BW density)
- **II. Analog/Mixed-Signal Wireline Circuits**
  - A. RX Termination
  - B. CTLE and VGA Circuits
  - C. Decision Feedback Equalization
  - D. Transmitters
- **III. DSP-Based Transceivers**
  - A. DSP-DAC TX
  - B. ADC-DSP RX
  - C. Digital Baud-Rate CDR
  - D. Forward Error Correction
- **IV. Optical Interface Circuits**
  - Classifying Various E/O Modulators
  - A. E/O Transmitter Front-End
  - B. O/E Receivers
- **V. Clocking**
  - A. Clocking Architectures
  - B. Clock Generation
  - C. Clock Distribution
  - D. Multi-Phase Generator (MPG)
  - E. Phase Interpolator
  - F. Clock Calibration
- **VI. Future Directions**
- **References**

## Related framework notes

This paper anchors the technical claims used by the vault's investment-framework notes on the same topic:

- [[Photonics 101 - foundational primer on light-based data transmission lasers transceivers and the AI optical stack]]
- [[The Photonics Stack - layered map of where laser substrate transceiver DSP and switch companies sit and which layers are bottleneck vs commodity]]
- [[Vertical integration in optical transceivers - AAOI deepest in light engines, Lumentum focused on optical core, Coherent broadest stack]]
- [[EML vs CW lasers - integrated vs modular optical transmitter architectures shape 400G 800G 1.6T module design]]
- [[LPO NPO CPO optical placement architectures explain power latency and serviceability tradeoffs as optics migrate toward the ASIC - Crux Capital primer]]
- [[Photonics solves AI datacenter bandwidth power heat latency and distance bottlenecks copper cannot - Crux Capital primer]]

Cross-link to the vault's structural maps that name companies per layer:

- [[@damnang2 optical investment map v1.0 - 7 layers L1 Materials to L7 Test plus FRO LRO LPO NPO CPO axis with 50 names and 22-company vertical integration matrix]] — Damnang's Layer 3 (Electro-Optical Connectivity IC) and Layer 6-A (Optical Engine & Module) are exactly the circuit territories this paper covers in Sections III and IV.
- [[Goldman 2026 AI optical cheat sheet maps EPS upside across lasers PCBs and CCL manufacturers]]
- [[Sancet 2026 - Goldman optical cheat sheet omits substrate epi equipment and laser layers (IQE Soitec Tower Aixtron AEHR LPKF SIVE)]]

## Note on extraction

This paper's Original Content section below was extracted via docling (Granite-vision-based PDF-to-markdown), with `--image-export-mode referenced` and CPU runtime. 53 figures were extracted as raster PNGs and embedded inline below at their source positions. Equations appear as raster figures rather than inline LaTeX (the `--enrich-formula` flag was attempted but ran past 30 minutes on CPU before being killed in favor of the faster pure-layout extraction). Readers needing LaTeX equation source should refer to the original PDF or IEEEXplore HTML view at `https://ieeexplore.ieee.org/document/11311714`.

---

## Original Content

## Modern Wireline Transceivers

Tony Chan Carusone , Fellow, IEEE , Timothy O. Dickson , Senior Member, IEEE , Samuel Palermo , Senior Member, IEEE , Sudip Shekhar , Senior Member, IEEE , and Mozhgan Mansuri , Member, IEEE

Abstract -Over the past two decades, ever-increasing network bandwidth (BW) demands in data centers and high-performance computing systems have fueled exponential growth in per-lane serial link data rates. To keep up with this demand and enable faster communication over BW-limited electrical channels, wireline transceiver architectures and circuit topologies have rapidly evolved over this timeframe to support sophisticated modulation and equalization. This tutorial paper presents an overview of modern serial links. Application background is described, motivating the link energy e ciency and bit error rate (BER) requirements. Transmit and receive circuits and architectures are described for both short-reach and long-reach electrical interconnects. The former tends to rely on powere cient analog / mixed-signal techniques to equalize relatively low-loss channels with reach up to a few cm, while the latter requires sophisticated digital signal processing (DSP) along with high-speed ADCs and DACs to compensate channels with loss greater than 30 dB at Nyquist. Optical links are reviewed in the context of intra-data center applications where they are increasingly used. Low-jitter, high-phase-accuracy clock generation and distribution techniques are examined. Finally, future directions for modulation, equalization, and error correction to support links exceeding 200 Gb / s are discussed.

Index Terms -Clocking, connectivity, data centers, digital signal processing (DSP), equalization, optical, pulse amplitude modulation (PAM), SerDes, wireline.

## I. INTRODUCTION

H IGH-SPEED serial transmitter and receiver (transceiver) circuits form the backbone of modern data communication over copper cables and optical fibers. They enable chip-to-chip, board-level, and rack-level interconnects in data centers, networking equipment, and computer systems. In recent years, the demand for I / O bandwidth (BW) has skyrocketed due to data-intensive applications and AI workloads, pushing per-lane data rates well beyond 50 Gb / s.

Received 31 July 2025; revised 8 November 2025; accepted 2 December 2025. Date of publication 23 December 2025; date of current version 30 January 2026. This article was approved by Associate Editor Dennis Sylvester. (Corresponding author: Tony Chan Carusone.)

Tony Chan Carusone is with Alphawave Semi, Toronto, ON M5J 2M4, Canada, and also with the Department of Electrical and Computer Engineering, University of Toronto, Toronto, ON M5S 3G4, Canada (e-mail: tony.chan.carusone@isl.utoronto.ca).

Timothy O. Dickson is with the IBM Thomas J. Watson Research Center, Yorktown Heights, NY 10598 USA.

Samuel Palermo is with the Department of Electrical and Computer Engineering, Texas A&M University, College Station, TX 77843 USA.

Sudip Shekhar is with the Department of Electrical and Computer Engineering, University of British Columbia, Vancouver, BC V6T 1Z4, Canada. Mozhgan Mansuri is with Intel, Hillsboro, OR 97124 USA.

Color versions of one or more figures in this article are available at https: // doi.org / 10.1109 / JSSC.2025.3642231.

Digital Object Identifier 10.1109 / JSSC.2025.3642231

Fig. 1. (a) Connectivity between high-performance computing and AI accelerators. (b) Plot of published serial link data rates versus year with trendline.

![[ieee-jssc-wireline-tutorial-2026-001.png]]

Fig. 1(a) illustrates the connectivity in a network of processors, and AI accelerators (CPUs and xPUs) combining copper interconnect over circuit board (PCB) traces, copper cables of varying lengths, and optical fiber. This array of interconnects gives rise to a wide variety of research challenges. A principal impairment in such wireline links is the frequency-dependent channel loss of copper interconnect (printed wiring and vias, connectors and cables) and analog circuits.

As data rates increased over the past two decades [Fig. 1(b)], the channels' BW limitations introduced increasing signal attenuation and dispersion, making it challenging to simply scale traditional two-level pulse amplitude modulation (2-PAM 1 ) signaling. To address this, links have evolved from using 2-PAM modulation to 4-PAM. By encoding

1 Two-level PAM is often referred to as NRZ signaling, although strictly speaking NRZ refers simply to any signaling that maintains a constant amplitude throughout each symbol interval.

2 bits per symbol, the change e ectively halved the BW required for a given data rate. This shift allowed 56-112 Gb / s links to operate within the BW constraints of existing channels. However, generally 4-PAM can be more sensitive to noise, nonlinearity, intersymbol interference (ISI), and timing jitter, and necessitate more complex transceiver design.

In spite of early implementations of analog receivers for 4-PAM [1], it was long understood that digital signal processing (DSP)-based equalization o ered potential benefits for 4-PAM signaling [2]. To achieve the high sampling rates required, time-interleaving data converters are required. The earlier work on time-interleaved (TI) flash or pipelined ADC converters was in technology nodes where the required DSP was large and power-hungry.

A combination of ongoing CMOS technology scaling and the emergence of power-e cient ADC architectures was needed for the widespread use of DSP-based transceivers. First, CMOS technology scaling a orded tremendous improvements in the power and performance of digital logic, and lesser improvements for analog circuits, thereby disproportionately benefiting DSP architectures over analog ones. Second, SAR ADCs emerged as a very energy-e cient architecture for SNDRs of 25-35 dB, reasonable values for wireline receivers. Much of the energy in SAR converters is consumed by digital circuits (a comparator and state machine), and their accuracy is heavily influenced by the matching of small capacitors, both of which improve with CMOS technology scaling. Finally, the mismatches inherent between the parallelized SARs can be corrected for digitally [3], the cost of which also decreases with technology scaling.

Thus arose a trend toward the use of high-speed data converters and DSP to perform equalization, whereas earlier transceivers relied exclusively on analog equalizers to combat ISI; modern designs increasingly incorporate highspeed ADCs and DSP to implement sophisticated equalization and error correction in the digital domain. These DSP-based transceivers, often combined with forward error correction (FEC), are e ectively complete digital modems communicating reliably at serial rates above 100 Gb / s over channels where analog transceivers fail to operate. Hence, modern wireline links employ a combination of analog and DSP architectures to cover a wide range of applications, with trade-o s in speed, robustness, power, area, and latency.

This tutorial overview paper focuses on transmitter (TX), receiver (RX), and clocking circuit techniques for high-speed serial communication links over copper and optical media. We specifically exclude ultra-short, parallel interfaces between co-packaged dies, which have unique design considerations. Instead, our emphasis is on wireline links such as those between packaged chips, from a chip to an optical module, within a rack over a PCB or cabled backplane, and between racks of networking or computing equipment over optical fiber. In the introduction, we introduce key concepts and terminology, and survey important applications and standards that drive design requirements.

Fig. 2. General block diagram of a wireline transceiver and link.

![[ieee-jssc-wireline-tutorial-2026-002.png]]

Fig. 3. Illustration of the relationship between channel loss and pulse response.

![[ieee-jssc-wireline-tutorial-2026-003.png]]

## A. Background

1) Channel Characteristics and Signaling: A wireline link consists of a TX, a physical communication channel (PCB traces, cables, or optical fiber), and a RX, as in Fig. 2. Typically, the data is transmitted at baud rates far exceeding the clock frequency of digital logic, thus necessitating serialization at the TX and deserialization at the RX, giving rise to the colloquial use of 'SerDes' to refer to the overall transceiver circuits. The channel and circuits attenuate and distort signals, especially at high frequencies, leading to ISI in which each transmitted bit's response spills into neighboring symbol intervals. The channel's response to a unit pulse (its pulse response) provides a useful characterization of ISI (Fig. 3): a broad or long-tailed pulse response means significant energy extends beyond one unit interval (UI), causing symbols to interfere. Relatively long copper channels (such as those between servers over PCB traces or twinaxial cables) often have insertion loss (IL) of tens of decibels at their Nyquist frequencies. 2 Optical RXs work with smaller amplitude input signals and are, therefore, even more sensitive to noise and jitter. Although they generally su er from less ISI than long copper links, they can face BW limitations due to optical dispersion in the fiber and limitations in optoelectronic and analog circuit BW.

To mitigate ISI, transceivers employ equalization. TXs use pre-emphasis to shape their output spectrum (e.g., boosting high-frequency or de-emphasizing low-frequency content), while RXs use amplifiers and analog or digital filters to do the same. In both cases, the e ect is to cancel ISI. Because 4-PAM RXs must resolve more closely-spaced voltage levels, the equalization must more precisely eliminate ISI, a motivation for the use of DSP.

2 Since wireline receivers generally (although not always) sample their input at the symbol rate, the Nyquist frequency of a wireline link is considered to be one-half its symbol rate.

Fig. 4. Plots of published wireline (electrical) link data rates and energy e ciencies versus CMOS process node [4]. Only publications reporting over 20 dB loss compensation are included.

![[ieee-jssc-wireline-tutorial-2026-004.png]]

Fig. 4 illustrates the trend toward increasing per-lane data rates and improving energy e ciency, measured by the total power consumed in transceiver circuits divided by the data rate, measured in picojoules per bit (pJ / bit). A key inflection point arose at 28 nm CMOS, which coincided with the increasing use of 4-PAM at 56 Gb / s and DSP equalization. A wide range of energy e ciencies is evident in the plot. The trend toward improved energy e ciency was even reversed by some designs; these were the first works to adopt DSP [5]. But the transition to DSP unlocked further speed and energy e ciency improvements evident in the plot's forthcoming 22-4 nm designs that operate over lossy (more than 20-dB Nyquist frequency loss) channels.

The use of DSP in the RX also allows for maximumlikelihood sequence detection (MLSD), which can provide performance improvements beyond equalization for particularly lossy and / or noisy channels. Alongside progress on both analog and DSP equalization techniques, FEC has also now become commonplace in wireline links. FEC encoding and decoding is handled digitally, e ectively trading an increase in latency, area, and power for significant improvements in link reliability.

- 2) Key Performance Metrics: Several metrics quantify the performance of wireline transceivers. For example, the raw data rate per lane [in gigabit per second (Gb / s)] and the bit error rate (BER) before and after FEC are fundamental specs. Typical target error rates range from around 10 12 to 10 15 , but much higher error rates (e.g., up to 10 4 ) are tolerable when FEC is used. A useful visualization of signal integrity is the eye diagram, a plot of many PAM waveforms synchronously overlayed, capturing the impact of di erent combinations of ISI and noise.

Transceivers are often categorized by the maximum channel loss they can tolerate while still maintaining a target BER. Common designations include extra-short reach (XSR), very short reach (VSR), medium reach (MR), and long reach (LR), which roughly correspond to increasing channel lengths and losses. For instance, an XSR link (e.g., less than 100 mm) might allow approximately 10 dB electrical channel loss at the Nyquist frequency, while a VSR chip-to-module link (e.g., 10-15 cm PCB trace + one connector) might target 15 dB loss. LR backplane or cable links may need to tolerate 30-40 dB loss at Nyquist, with additional margin desirable to ensure robustness. Note that although these designations are a useful shorthand, channels with similar Nyquist loss may require very di erent equalization. The wide diversity of channel responses encountered in real-world applications is a significant and ongoing challenge in specifying the design of wireline transceivers.

As the aggregate I / O BW demands of large processors and networking chips have increased, the power consumption of transceivers has emerged as a critical metric. First, communication circuits are significant contributors to data centers' energy consumption, which adds cost and leaves an environmental footprint. Second, the power consumption of transceiver circuits generates heat that can be di cult to dissipate in dense computing and networking equipment. Third, the delivery of power to large chips housing many transceivers is a di cult challenge that can be mitigated by lowering the power of transceiver circuits.

Energy e ciency is measured in milliwatts / Gb / s (mW / Gb / s) or equivalently pJ / bit (1 mW / Gb / s = 1 pJ / bit). Allowing for many parallel transceivers, this metric enables a quick comparison of the power required to communicate a targeted aggregate BW using two di erent transceivers, even if they operate at di erent data rates. State-of-the-art 112 Gb / s 4-PAM transceivers can be below 3 pJ / bit e ciency on very short channels [13]. Longer-reach 56-224 Gb / s links with heavy DSP equalization might demand 5 pJ / bit or more [108]. Improving energy e ciency is paramount for scaling system BW, as interconnect power can dominate in AI training racks and switches.

BWdensity measures the aggregate data rate communicated per unit chip edge length or area. Since transceiver circuits occupy significant silicon area, there is a practical limit to how many high-speed lanes can be placed side by side on a chip's periphery. Their total BW is often quantified in Gb / s / mm of die edge ('beachfront' or 'shoreline' BW) or Gb / s / mm 2 of I / O area. BW density is a key criterion for high-performance systems where high-cost cooling and power delivery subsystems are acceptable, leaving raw performance as the primary consideration.

- 3) Applications and Standards: Wireline transceivers find use in a range of applications, many with distinct requirements. On the shorter end, chip-to-chip and module-to-chip copper links on a PCB (such as between a switch ASIC and an optical module, or between a CPU and a network interface card on a motherboard) typically span tens of centimeters at most. These XSR / VSR links are governed by standards like optical interworking forum-common electrical I / O (OIF-CEI)

![[ieee-jssc-wireline-tutorial-2026-005.png]]

Year

Fig. 5. Timeline of wireline transceiver standards (ISSCC Press Kit, 2025).

definitions and portions of Ethernet specs (e.g., attachment unit interface, AUI). Backplane and midplane links (MR / LR class) are longer copper routes (up to 1 m) over backplane PCBs or passive copper cables (e.g., direct-attach copper cables up to 2-3 m for top-of-rack connections). These channels have high loss and require robust equalization; standards like IEEE 802.3 Ethernet backplane PHYs (e.g., KR for backplane, CR for copper cable) specify operation over such media with FEC.

Over longer distances, optical fiber links are employed. Short-reach optical interconnects (SR or 'datacenter reach') use inexpensive vertical-cavity surface-emitting lasers (VCSELs) and multimode fiber, which are common for reaches up to 100-200 m. Longer reaches (e.g., 500 m to 10 km) use single-mode fiber with directly modulated or externally modulated lasers. For example, two-letter postfixes denote the reach of relevant optical Ethernet standards: DR (up to 500 m), FR (up to 2 km), and LR (up to 10 km) are examples of optical channels of 100 Gb / s per wavelength. Beyond about 10 km, coherent optical transceivers employing advanced modulation (QAM and polarization multiplexing) and more power-hungry DSP are utilized (examples include 400ZR for 80 km datacenter interconnect, DCI, links). These coherent systems are beyond the scope of this tutorial.

All applications have progressed toward higher data rates (Fig. 5). Two ubiquitous standard families highlight the evolution of transceiver design: Ethernet and PCI Express (PCIe). Both have evolved toward higher data rates and transitioned to 4-PAM modulation beyond 50 Gb / s. However, PCIe prioritizes lower latency, driving di erent requirements for equalization, timing recovery, and FEC.

The remainder of this article covers analog / mixed-signal and DSP-based architectures, followed by specific consideration of optical transceivers and clocking circuits.

Fig. 6. Short-reach analog / mixed-signal wireline RX architecture.

![[ieee-jssc-wireline-tutorial-2026-006.png]]

Fig. 7. Short-reach TX architecture with analog FFE.

![[ieee-jssc-wireline-tutorial-2026-007.png]]

## II. ANALOG/MIXED-SIGNAL WIRELINE CIRCUITS

Data center and high-performance compute systems have a large number of links covering shorter distances to support in-drawer or even in-package communication. These electrical links cover distances as short as a few centimeters and demand excellent transceiver energy e ciency. Thus, designs employing low-power analog / mixed-signal transceiver architectures are resurging to support communication over channels with loss below 15 dB. The RX and TX data paths for a typical short-reach transceiver are illustrated in Figs. 6 and 7, respectively. On the RX side, the analog front-end (AFE) usually consists of a wide BW impedance matching network, a continuous-time linear equalizer (CTLE), and variable gain amplifier (VGA). These continuous-time analog amplifiers condition the signal for delivery to analog comparators (slicers) to sample the waveform and make symbol decisions. In some designs, the slicers are embedded within a decision feedback equalizer (DFE) that may consist of 1 or 2 taps to further eliminate post-cursor ISI. Sampling can occur using both rising and falling edges of a clock with a frequency of one-half the symbol rate (i.e., a 'half-rate' clock), although most recent designs make use of four phases of a quarter-rate clock. Short-reach TXs are often segmented to facilitate analog modulation in the case of 4-PAM transmission and waveform shaping via a preceding FIR filter serving as a feed-forward equalizer (FFE). Each segment is associated with a particular FFE tap to enable coarse filter coe cient control. At high speeds, the final stage of data serialization to produce symbol-rate data is the most challenging aspect of the design. Careful management of the fan-out between the final 2:1 or 4:1 MUX, predriver, and driver is required to deliver this high-speed data to the driver stage that must interface with a 100di erential wireline channel. In this section, circuit design details of critical blocks in the RX and TX AFE will be described.

## A. RX Termination

Serial RXs must be impedance matched to the characteristic impedance of the wireline channel to prevent signal integrity impairments due to reflections. At the same time, the input of a serial RX must incorporate ESD diodes capable of protecting against 1-2 kV human body model (HBM) and 90-250 V charged device model (CDM) ESD events. These large ESD diodes introduce considerable parasitic capacitance that will

Fig. 8. Rx broadband input matching network employing a bridged T-coil to mitigate BW loss from ESD capacitance.

![[ieee-jssc-wireline-tutorial-2026-008.png]]

Fig. 9. Rx broadband input matching network with distributed ESD.

![[ieee-jssc-wireline-tutorial-2026-009.png]]

degrade the RX's high-frequency return loss. To mitigate these parasitics and improve high-frequency matching, passive coil networks are often employed. One such approach employs a bridged-T-coil as seen in Fig. 8 [6]. Intuitively, the inductive and bridged capacitive paths provide low-impedance paths to the termination resistor at low and high frequencies, respectively. The BW of the matching network can theoretically improve by 2.7 × while achieving uniform group delay [6]. More recent RX designs from 25 to 56 GBaud have included additional peaking coils (L3) to further mitigate BW loss from the RX input capacitance and / or parasitic capacitance associated with the termination resistor [7], [8]. It has been noted that all three coils can be stacked to save area [8]. Recent designs at 112 Gb / s have further modified the matching network to distribute the ESD capacitance across an artificial LC -transmission line structure, as seen in Fig. 9 [9]. Evidence suggests that such a structure can also improve ESD performance [10].

## B. CTLE and VGA Circuits

Both analog-based short-reach as well as DSP-based longreach wireline RXs require analog continuous-time equalizers, which boost high-frequency gain relative to low-frequency gain in order to compensate for frequency-dependent channel loss. Since these circuits and TX FFEs generally lower the dc gain, variable or programmable gain amplifiers (VGAs or PGAs) are also required in the Rx AFE to increase signal amplitude prior to symbol detection.

Fig. 10 shows a simple but e ective passive CTLE, which can be placed after the input matching network and before any active amplification or equalization. At low and high frequencies, the first-order RC circuit behaves as a resistive and capacitive voltage divider, respectively. The circuit introduces

Fig. 10. Passive RC CTLE topology.

![[ieee-jssc-wireline-tutorial-2026-010.png]]

Fig. 11. Alternative passive RC CTLE topology [12], [13].

![[ieee-jssc-wireline-tutorial-2026-011.png]]

a left-half-plane pole and zero given by

<!-- formula-not-decoded -->

<!-- formula-not-decoded -->

Controllable peaking can be achieved by introducing programmability into the series RC paths [11]. As the passive CTLE loads the input matching network, its input impedance must be large enough to not degrade the RX return loss. Consequently, large resistor values are needed, which in turn demand small capacitors to realize high-frequency pole or zero values. This condition can prove di cult to satisfy, especially if C 2 represents the input capacitance to any loading active circuitry. An alternative passive equalizer structure, shown in Fig. 11, has been seen in recent 112G XSR publications using ac coupling capacitors to mitigate this loading concern [12], [13]. By employing a large ac coupling capacitor C 1, the capacitive divider circuit C 1 and C 2 can achieve nearly unity gain at high frequencies, with C 2 and R 2 introducing a programmable left-half-plane zero to control the frequency response. Pattern-dependent baseline wander introduced by the lack of a dc path in Fig. 11 must be mitigated; solutions can be found in the literature [13], [14] Variable gain amplification is commonly implemented using a topology similar to that of Fig. 12, where the di erential gain is controlled by varying the amount of source degeneration resistance. BW limitations due to capacitive loading can be mitigated by adding the crosscoupled structure on the right of the circuit, which produces a negative e ective capacitance to o set any loading from CL . This approach is more area e cient than inductive shunt peaking, but adds power and noise. Moreover, one must ensure that the positive feedback does not introduce instability across PVT corners.

The degeneration network of Fig. 12 can be modified to yield a popular CTLE topology, as seen in Fig. 13(a). At low frequencies, the circuit behaves like the source-degenerated

Fig. 12. VGA.

![[ieee-jssc-wireline-tutorial-2026-012.png]]

VGA described above. At high frequencies, CS / 2 lowers the impedance of the degeneration network, ideally increasing the CTLE gain to that of a di erential pair without source degeneration. Neglecting capacitive loading at the output, the circuit response is

<!-- formula-not-decoded -->

with a left-half-plane zero and pole given by

<!-- formula-not-decoded -->

<!-- formula-not-decoded -->

As seen from the frequency response in Fig. 13(b), increasing the degeneration resistance lowers the dc gain, reduces the zero frequency, and enhances the relative gain boosting at high frequencies. At even higher frequencies, the load capacitance cannot be neglected, and a second high-frequency pole is introduced

<!-- formula-not-decoded -->

It is, therefore, critical that ! p 2 &gt; ! p 1 to avoid reduced gain boosting due to premature gain roll-o . The negative capacitance technique of Fig. 12 can also be applied to a CTLE, as can shunt inductive peaking. However, complex highQ poles and ringing in the step response must be avoided, particularly for short-reach transceivers that do not have the luxury of RX DSP with dozens of FIR filter taps for equalization. For example, a Bessel response may be targeted, particularly in 4-PAM applications where link margins are especially vulnerable to uncompensated ISI.

Active inductors [15] have also been employed in the load of CTLEs and VGAs to increase the frequency associated with the output pole [16]. As depicted in Fig. 14, a diode-connected PMOS load presents a load of approximately 1 / gmp to the NMOS transconductor network at low frequencies. The lowpass filter formed by gate resistor R G and the C gs of the PMOS curtails the gate-to-drain connection as frequency increases, ultimately resulting in a load of rop being presented to the NMOS RC -degenerated transconductor at high frequencies.

Extending the active load approach, a transimpedance amplifier (TIA) load can a ord additional gain. The technique borrows from the Cherry-Hooper topology, which has been used for decades to provide wide BW amplification [17]. Fig. 15 illustrates this transadmittance-transimpedance ('TASTIS') 2-stage CTLE, which sums currents from the two input stages into the TIS load [18]. The two input transadmittance (TAS) stages have di erent RC degeneration networks tailored to equalize di erent frequency ranges, giving flexibility to introduce peaking at high frequencies while also permitting low-frequency long-tail equalization to combat losses from conductor skin e ect [19], [20]. Some works have made use of CMOS inverters as the GM stages in the topology of Fig. 15, benefitting from the transconductance of both NMOS and PMOS devices [21], [22]. These works have demonstrated inverter-based VGAs and CTLEs with su cient linearity for 4-PAM AFEs. Moreover, the use of CMOS inverters allows for compact amplifier layout in FinFET technologies and eases portability to more advanced technology nodes [21].

## C. Decision Feedback Equalization

DFEs are a powerful mixed-signal equalizer for canceling post-cursor ISI. In this structure, previous bit or symbol decisions stored in digital flip-flops or latches are fed back to the input. With appropriate analog weighting, their ISI contributions can be subtracted from the input analog signal prior to data slicing. Unlike analog CTLEs or FFEs which boost high-frequency signal content, DFEs can provide equalization without amplifying high-frequency noise or crosstalk.

Fig. 16 depicts a full-rate two-tap DFE architecture for use in a 2-PAM serial RX. While such an architecture is rarely, if ever, implemented in practice, it is instructive to examine its critical timing and limitations. The two decisions are stored in edge-triggered D-type flip-flops clocked at the data symbol rate. They are fed back to an input summing amplifier via weighting elements h 1 and h 2 ; which define the DFE tap coe cients and should correspond to the first two post-cursor ISI terms in the channel response h [ n ], expressed in the z-domain as

<!-- formula-not-decoded -->

For a transmitted symbol sequence xT [ n ], after ISI removal by the summing amplifier, the slicer sees an input xD = h 0 xT . Assuming a passive channel with a dc gain close to unity h 0 + h 1 + h 2 1 and a large h 1 + h 2, the slicer input can have a small amplitude, necessitating an o set-compensated low-noise slicer. The full-rate DFE also has a critical timing path associated with the feedback of the first post-cursor decision. The decisions from the slicer must be weighted and their ISI contributions removed at the output of the summer, with su cient setup time before the slicer makes its next decision. The sum of all the timing delays in the feedback loop, including the clock-toQ delay of the slicer, must be less than one symbol period

<!-- formula-not-decoded -->

In many implementations, the DFE tap weighting is implemented as part of the summing amplifier, thus reducing or

![[ieee-jssc-wireline-tutorial-2026-013.png]]

Fig. 13. Active CTLE. (a) Topology and (b) frequency response.

Fig. 14. CTLE with active inductor PMOS load.

![[ieee-jssc-wireline-tutorial-2026-014.png]]

Fig. 15. TAS-Transimpedance (TIS) 2-stage CTLE [18].

![[ieee-jssc-wireline-tutorial-2026-015.png]]

eliminating th 1. Nonetheless, the aforementioned small input amplitude to the comparator is notorious for degrading its clock-toQ delay, making timing closure a severe challenge.

To overcome the described architecture limitations, two common DFE architecture enhancements are illustrated in Fig. 17. The first is the use of time interleaving, which lowers the required clock frequency by using multiple clock edges to sample the data. The figure depicts a two-way time interleaved (or 'half-rate') architecture where decisions are

Fig. 16. Full-rate DFE architecture.

![[ieee-jssc-wireline-tutorial-2026-016.png]]

Fig. 17. Two-way time interleaved DFE architecture with first post-cursor speculation.

![[ieee-jssc-wireline-tutorial-2026-017.png]]

made by samplers triggered on the rising and falling edges of the half-rate C2 clock. Flip-flops in the full-rate architecture of Fig. 16 are replaced with latches. At today's speeds of 100 + Gb / s, timing closure for half-rate architectures can still be challenging. Consequently, four-way time interleaved implementations with samplers triggered on four phases of a quarter-rate clock have been reported (see [18]). The second

Fig. 18. 4-PAM 1-tap DFE speculative decision thresholds when a 1-D + 0.5-D response is imposed.

![[ieee-jssc-wireline-tutorial-2026-018.png]]

Fig. 19. CML summing amplifier for a 2-tap DFE.

![[ieee-jssc-wireline-tutorial-2026-019.png]]

architectural modification in Fig. 17 is the use of decision speculation, whereby two analog summing amplifiers are employed in each of the interleaved paths, each speculating as to whether the previous 2-PAM symbol decision was + 1 or 1. The correct speculative path is selected based on the preceding symbol decision. In this architecture, the speculative path selection represents the critical timing path and must still close within 1UI. It comprises the clock-toQ delay of latches L1 / L2, which can be much faster than the decision-making comparators since the digital data should have a reasonable amplitude at the input to these latches. The decision-making comparators do contribute to the second post-cursor timing path, but this path has a relaxed 2-UI timing budget.

The complexity of speculative DFE architectures increases exponentially with the number of signaling levels. For example, in a 4-PAM 1-tap speculative DFE, each sampler needs to speculate which one of four possible previous symbols had been received, leading to a total of 12 samplers in each TI path. Constraining the DFE tap coe cient so that h 1 = 0 : 5 h 0 can reduce the required number of samplers [18]. As shown in Fig. 18, this (1 + 0 : 5z 1 ) response causes some comparator thresholds to coincide when the 1-tap speculation is applied, saving one third of the samplers. Such an approach requires adaptation of any TX FFE and / or Rx CTLE so that their responses convolved with the wireline channel response are (1 + 0 : 5z 1 ).

A typical CML-based summing amplifier for a 2-tap DFE is depicted in Fig. 19 where ISI from the input signal is subtracted in the current domain. Tap weights can be controlled via programmable current sources. The schematic in Fig. 19 implements a fixed (negative) h 1 tap coe cient, while tap sign polarity for the second post cursor is determined by making either I h 1p or I h 2 n non-zero. The RC time constant at the output

Fig. 20. Integrating summing amplifier for a 2-tap DFE.

![[ieee-jssc-wireline-tutorial-2026-020.png]]

summation node limits the summer settling time, which can be a bottleneck in closing feedback timing loops. While inductive peaking can improve BW, the area penalty is often prohibitive when time interleaving and / or speculation is employed.

An alternative approach is to use current integration to avoid RC settling limitations, as seen in Fig. 20 [23]. A di erential output voltage is developed by discharging parasitic load capacitances using currents derived from the input voltage and previous decisions (either speculative or fed back). At the end of the integration period, the voltage is reset to the supply via PMOS pull-up devices. It is desirable to hold the input voltage constant via a sample-and-hold circuit to avoid frequencydependent loss associated with a resettable integrator [24]. As compared to the resistive summation approach in Fig. 19, a current integrating summer can operate with approximately 3 × lower bias current. As a final note, in a 1-tap speculative DFE architecture, the summing amplifier can be eliminated altogether, and the speculative DFE tap weight can be added as an o set to the sampler [11].

While this section has focused on the DFE data path, it must be noted that additional circuitry is required to enable both clock and data recovery (CDR) functionality as well as DFE coe cient adaptation in a fully-integrated serial RX. The former usually involves a slicer sampling data transitions (or 'edges') and requires a separate clock phase that is nominally o set by 90 from the DFE data sampling phase. These edge samples can then be deserialized and sent to the RX logic, which can qualify against data samples to determine if the sampling phase is earlier or later than optimal. This approach can limit the CDR BW, since RX logic running at a fraction of the RX baud rate will take time to accumulate su cient statistics and determine how to adjust the sampling phase. DFE adaptation may be implemented using a sign-sign least mean square (SS-LMS) algorithm, which requires a third sampling path to monitor both horizontal and vertical eye margins. Independent phase interpolators, which will be discussed in Section V-E, are also needed on all three paths. Examples of fully-adaptive DFE-based RX can be found in the literature (see [8], [12], [13], [14]).

## D. Transmitters

The design of a wireline TX begins with the selection of a driver topology. Fig. 21 depicts half-circuit schematics for the (a) current-mode logic (CML) [25] and (b) source-series terminated (SST) [26] driver topologies that are commonly found in high-speed TXs operating above 50 GBaud. Recent designs have employed a tailless CML topology as seen in

Fig. 21. Common wireline driver topologies. (a) Tailless CML and (b) SST.

![[ieee-jssc-wireline-tutorial-2026-021.png]]

the figure, where the current level in a driver segment is set based on a gate bias voltage V BIAS applied to NMOS N 1. The source of the N 1 is connected to logic switch N 2, which permits current conduction in the driver segment when input data DIN is logically high. PMOS switch P1 disables current flow in the driver by pulling the source of N 1 to the supply voltage when DIN is logically low. The tailless variety of CML driver requires only N 1 to remain in the saturation region, thereby alleviating headroom concerns due to numerous stacked devices in a conventional CML driver. Recently reported conventional CML driver designs require a 1.5 V driver supply voltage V DD ; DRV to achieve 1.0 V ppd output swing [27], whereas tailless CML designs have achieved the same voltage swing with a 1.2 V driver supply [25].

The voltage mode, or SST, driver topology of Fig. 21(b) o ers several benefits. The circuit does not require analog bias voltages, making it amenable to integration with CMOS high-speed logic. It is well known that, depending on RX termination conditions, voltage mode drivers require a factor of 2 × or 4 × lower static termination current than a CML driver to produce the same voltage swing. However, although such considerations were paramount in power-e cient designs operating at lower speeds, the termination current is usually a small fraction of the overall current consumption of a modern 100 + Gb / s TX whose power is typically dominated by that of clocking circuitry.

To minimize reflections, the driver must be impedance matched to the channel's characteristic impedance. CML designs employ a pull-up load resistor, usually implemented with low-parasitic back-end-of-line (BEOL) resistors. In contrast, the output impedance matching of an SST driver is accomplished via a series network consisting of a linear passive resistor R linear, high-speed switching pull-up or pull-down FETs, and tunable header and footer devices. The latter is often tuned digitally to meet the target impedance across PVT variations. The passive resistors are typically BEOL resistors, but a recent compact implementation used front-end-of-line metal gate resistors in advanced CMOS nodes [28]. Assuming matched conditions, the peak-to-peak di erential output swing of an SST driver is limited to the driver supply voltage. Increasing this voltage swing becomes a challenge for SST designs as higher supply voltages can lead to voltage stress issues in the high-speed switching devices. Higher output voltage swing can be accomplished in a CML design by simply

Fig. 22. Transmission gate 4:1 MUX topology.

![[ieee-jssc-wireline-tutorial-2026-022.png]]

Fig. 23. CML 4:1 MUX topology.

![[ieee-jssc-wireline-tutorial-2026-023.png]]

increasing the bias current, assuming headroom conditions discussed earlier are satisfied. In both cases, high-frequency impedance matching is degraded due to parasitic capacitances associated with the driver, output pad, and ESD protection devices. Passive BW extension circuits such as the T-coils or high-order LC -networks described earlier are often required to meet return loss specifications up to tens of gigahertz [27], [29], [30].

There are a few other considerations worth mentioning regarding the driver topology choice. SST topologies o er better protection against CDM ESD events, as the linear resistor helps to attenuate the ESD pulse prior to reaching active devices in the driver. As these active devices do not directly connect to the flip-chip output pad, the SST driver is less susceptible to latch-up. Guard rings are often required around CML driver devices to prevent latch-up, increasing driver parasitics. Most of the highest-speed 200 + Gb / s wireline TXs reported in the literature employ CML-based TXs [27], [31], [32], [33], although a recent 300-Gb / s PAM-4 TX employs a voltage-mode SST driver in 5-nm CMOS [34].

Producing symbol-rate data at 100 + Gb / s poses considerable challenges for the final stage of TX multiplexing. While 2:1 multiplexing was common in designs up to 28GBaud, TXs operating at or above 50GBaud have almost exclusively relied on variations of two 4:1 multiplexer topologies as the final serialization stage: the transmission gate MUX of Fig. 22 and the CML MUX of Fig. 23. In the transmission gate architecture, one of four transmission gates is enabled for 1 UI to permit one of the four quarter-rate inputs to pass through to the output. NSEL and PSEL selection signals, with 25% and 75% duty cycle, respectively, are applied to corresponding NMOS and PMOS gates to enable the transmission gate.

Fig. 24. DAC / ADC-DSP-based wireline transceiver.

![[ieee-jssc-wireline-tutorial-2026-024.png]]

The selection signals are generated through logical AND / OR operations of two phases of the input quadrature quarter-rate clocks, thus e ectively creating the 1-UI enable pulse. Quarterrate data should be selected on the third UI after its transition to maximize setup time. Large parasitic capacitance at the node where the four transmission gate outputs are connected often presents a speed bottleneck for this MUX topology and can introduce data-dependent jitter at the TX output. Some designs have employed active peaking to overcome this, either in the MUX or in an inverter-based predriver [26], [35]. The CMOS logic levels obtained at the MUX output node make this topology well-suited for integration with an SST driver.

Recently reported high-speed TXs using CML drivers have opted for the CML-based 4:1 MUX topology of Fig. 23 [25], [27], [36], [37]. In this MUX architecture, one of four NMOS pull-down devices are enabled by data bits D0' through D3'. These data are preconditioned to be logically high for one out of four UI, usually by ANDing two phases of quadrature quarter-rate clocks. The CML 4:1 MUX often doubles as a predriver circuit and directly drives a CML driver stage, which does not require rail-to-rail input swing, unlike an SST driver. Since the pull-up PMOS device of Fig. 23 is always conducting, its pull-up strength is adjusted relative to the pulldown strength of the NMOS devices (e.g., via the PMOS gate voltage VBP) to provide appropriate CML levels at the driver input. Very high-speed TX designs have incorporated active peaking into the MUX pull-up network, similar to the network of Fig. 14 [27]. Some designs have merged the CML 4:1 MUX directly into the CML driver stage [31], [36], thus saving power by eliminating the need to produce full-rate data in a separate stage.

For TX architectures with either CML or SST drivers, tap weights for analog FFEs are coarsely controlled by associating TX segments in Fig. 7 with a particular FFE tap [25], [36], [37], [38]. Fine control of the tap weight is permitted in CMLbased TX by independent adjustment in CML driver segment bias current levels [25], [37]. TX FFE data delays can be implemented via a digital shift register (see [8]). Alternatively, this shift register can be implemented reconfigurably using clock phase selection. For example, a TX segment can be configured to drive an FFE pre or post-cursor by selecting the input quarter-rate data in the second or fourth UI, respectively, instead of the third UI [25], [37], [38]. Setup time limitations prevent selection on the first UI; thus, clock phase selection can only permit the realization of a 3-tap FFE. Techniques combining clock phase selection with digital shift registers have extended this to 4 or 5 taps for 112G XSR applications [13], [37].

Finally, note that the TX driver circuits described thus far are applicable to both short-reach TX employing analog FFE techniques as well as a long-reach DAC-based TX with DSP modulation and equalization.

## III. DSP-BASED TRANSCEIVERS

To support operation over channels with loss exceeding 40 dB at the Nyquist frequency, transceivers that employ DSP equalization at both the TX and RX and utilize DACbased drivers and ADC-based frontends are the dominant architecture (Fig. 24). The TX has a DSP operating at a low parallel rate, often 32-64 UI, that receives parallel binary input data, maps this to the desired modulation format (4 / 6 / 8-PAM), implements the TX FFE, and produces parallel quantized outputs at the DAC resolution R DAC. These parallel outputs are serialized and passed to the output driver that interfaces to the channel through a matching network that was discussed in Section II. An ADC-DSP-based RX has an input matching network that is followed by an AFE consisting of CTLE and VGA blocks, which may utilize the same topologies discussed in Section II or alternative architectures that provide higher Nyquist-rate peaking in a more e cient manner [39], [40], [41], [42], [43]. This is followed by a TI ADC, with typical TI factors ranging from 36 to 128, that quantizes the AFE output to feed a DSP that often performs FFE followed by either DFE or MLSD. Depending on the DSP operation clock, there may be additional deserialization after the TI-ADC. This DSP also includes adaptation engines for the digital equalization, ADC

Fig. 25. 7b DAC-based quarter-rate TX example with seven thermometer and four binary output segments.

![[ieee-jssc-wireline-tutorial-2026-025.png]]

calibration, and AFE settings, as well as the digital clockand-data recovery (CDR) phase detection and loop filter. The CDR is typically either based on a digital phase-locked loop (PLL), with a digitally-controlled oscillator (DCO), or phase interpolator (PI) architectures.

## A. DSP-DAC TX

A DSP-DAC TX uses digital adders and multipliers to implement the FFE arithmetic with an output commensurate with the DAC resolution. Due to the lack of any feedback in the FFE, the DSP power can be lowered with parallelism and pipelining techniques. This allows for more FFE tap with few, if any, constraints on the tap values, unlike analog symbol-spaced architectures, at the cost of a small amount of quantization noise for typical 7-bit DACs. A DAC-based TX also has simpler predriver circuitry, as no tap selection logic is required to interface with the output driver. These reasons make DAC-based architectures the dominant choice for TXs with five or more FFE taps.

1) DAC Output Driver: DAC output drivers often utilize the same tailless CML and high-swing SST cells discussed in Section II that are segmented based on the DAC resolution. As shown in Fig. 25, these segments generally include the final serialization stage, often the same as shown in Figs. 22 and 23, that is followed by [7], [27], [28], [33], [35], [42], [44], [45], [46], [47], [48], and [49] or integrated into [41], [50], and [51] the final output driver due to the tight integration necessary to support full data rate signals. A straightforward implementation would use only binary-weighted segments. However, cell matching requirements, large MSB:LSB ratios, and the potential for large dynamic glitches motivate the use of segmented architectures. For example, three thermometer-weighted MSBs (comprising seven segments) and binary-weighted segments for the remaining four LSBs a ord a maximum 16:1 segment ratio with 11 total segments in a 224 Gb / s design [50]. Alternatively, three binary-weighted LSB segments and a modified thermometer coding with 3 8-LSB segments and 8 12-LSB segments results in a maximum 12:1 ratio with 14 total segments in [41]. High-speed SST DACs have also used higher-impedance LSB segments to achieve a reduced unit cell count, with an 8 b 72 GS / s DAC applying this to 4 LSBs to reduce the unit cell count to 23 [35] and a 7 b 150 GS / s DAC applying this to two LSBs to reduce the unit cell count to 34 [34]. At the final output similar T-coil and LC networks that were discussed in Section II-A are used to distribute the termination, driver, ESD diodes, and bump capacitances and provide BW extension.

2) Digital TX FFE: Digital TX FFEs are often implemented with look-up tables (LUTs) in order to eliminate multipliers and reduce adder count. A fully LUT-based implementation has an N -tap filter span computation stored in an LUT with a N log 2 ( M )-bit address (for M -PAM modulation) and an output word width equal to the DAC resolution. For example, Fig. 26(a) 2-PAM 4-tap FFE with 6 b DAC resolution would have 16 rows of 6 columns for a total of 96 registers or memory cells [52]. As all rows can be independently programmed, this provides the potential for non-linear equalization and predistortion. However, this architecture does not scale well for 4-PAM systems, as a 7-tap FFE with 7 b resolution would require 114 688 registers. Instead, a more e cient 4-PAM architecture in Fig. 26(b) uses per-tap LUTs to eliminate the multipliers, and digital adders to combine the tap values [53]. This allows for simple 4-row LUTs per tap. Given the dramatic reduction in row count, the internal DSP resolution can also be increased to 8 b to reduce quantization noise in the subsequent adders that combine the tap values before finally quantizing the output to the 7 b DAC resolution. Using this approach, a 4-PAM 7-tap FFE can be implemented with a reasonable 224 registers.

## B. ADC-DSP RX

1) Analog Front-End: The AFE in a long-reach ADCDSP RX includes CTLE stages to partially equalize the channel and VGA stages to set the output to fill the ADC full-scale range. Often, an initial passive CTLE provides lowfrequency equalization, followed by the main active CTLE that is first in the signal chain due to linearity considerations [54]. However, the CTLE designs discussed previously in Section II-B have some limitations in achieving the &gt; 20 dB peaking required for high-loss channels. Fig. 13 simple RC -degeneration topology has limited flexibility to match the channel loss profile due to the single zero transfer function and has limited peaking due to the simple RC output pole. While adding active inductive loads (Fig. 14) and utilizing 2-stage TAS-TIS (Fig. 15) topologies can provide additional flexibility and improved BW, as data rates climb above 100 Gb / s passive BW extension techniques are generally required to achieve the necessary high peaking levels in a power e cient manner. Increased Nyquist-frequency peaking gain is possible with the Q -shaping CTLE shown in Fig. 27, which adjusts the passive inductive shunt-peaking load Q -factor. CTLEs have been implemented that exclusively utilize Q -shaping [39] or

Fig. 26. Digital TX FFE implementations. (a) Fully LUT-based 2-PAM 4-tap FFE with 6b output resolution and (b) 4-PAM 7-tap FFE with tap-based LUTs and 7b output resolution.

![[ieee-jssc-wireline-tutorial-2026-026.png]]

![[ieee-jssc-wireline-tutorial-2026-027.png]]

Fig. 27. Hybrid CTLE with both RC degeneration and Q -shaping load.

![[ieee-jssc-wireline-tutorial-2026-028.png]]

hybrid topologies that combine RC degeneration to better match the channel loss profile and provide improved linearity [40], [41]. Fig. 27 hybrid CTLE, which is implemented with a complementary-gm topology, has the following transfer

Fig. 28. TI ASAR ADC.

![[ieee-jssc-wireline-tutorial-2026-029.png]]

## function:

<!-- formula-not-decoded -->

The RC degeneration allows for control of the midfrequency slope, while the Nyquist peaking is provided with the shunt inductor Q shaping. A similar version of this hybrid CTLE has also been implemented with an inverter-based topology [41].

2) TI ADCs: As shown in Fig. 28, TI ADCs are utilized to quantize the AFE output at the required high sample rates. Asynchronous SAR (ASAR) ADCs are the dominant architecture for the typical 6 b and 7 b resolution used in 4-PAM RXs due to their low comparator count, simple digital logic, and capacitive DACs allowing for energy-e cient operation [55]. The most common interleave factor for 112 Gb / s-class RXs is 64, with the ASAR sub-ADCs operating near 875 MS / s [39], [44], [45], [46], [47], [56], [57]. Higher interleave factors ranging from 64 to 128 are found in the 224 Gb / s-class RXs, with the sub-ADCs operating from 830 MS / s [33] to 1.75 GS / s [40]. The ADC sampling operation is typically performed in two stages or ranks due to the di culty associated with generating a large number of low-jitter clock phases and to reduce AFE loading. This clock partitioning requires only the Rank 1 clocks that switch the input track-and-hold (T / H ) circuit to be designed with minimal jitter and skew. The Rank 1 TI factor ranges from 4 to 16 for &gt; 100 Gb / s RXs, with eight being typical.

Parallel bu ers are often used at the AFE output to drive the T / H circuits. For example, with 25% duty cycle Rank 1 clocks these bu ers drive groups of 4 T / H circuits (Fig. 28). This allows for only one T / H switch to be on at a time to minimize bu er loading and crosstalk between the ADC channels. The performance of these Rank 1 T / H circuits is critical, as they must sample the full-BW input signal. While bootstrapped switch T / Hs o er signal independent sampling instances [58], these topologies are generally not fast enough for &gt; 50 GS / s ADCs without speed-enhancement modifications [39], [59]. Instead, most designs use single-transistor T / Hs [Fig. 29(a)] and extremely fast edge-rate Rank 1 clocks to achieve the necessary high-frequency linearity [33], [40], [42]. After the Rank 1 T / Hs, bu ers drive parallel ASAR sub-ADCs with the

Fig. 29. Key interleaver circuits. (a) Rank 1 T / H and (b) combined flippedvoltage and super-source follower Rank 2 bu er [40].

![[ieee-jssc-wireline-tutorial-2026-030.png]]

Fig. 30. Asynchronous SAR ADC.

![[ieee-jssc-wireline-tutorial-2026-031.png]]

Rank 2 sample-and-hold switches. Improved settling time is achieved in these Rank 2 bu ers using flipped-voltage follower [33], [47] and combined super-source follower topologies [39], [40] [Fig. 29(b)]. VGA stages may also be embedded in the Rank 2 bu ers to allow for gain calibration [40].

The SAR sub-ADC performs a binary search process over several conversion cycles, with the simplest implementations using a single comparator. As shown in Fig. 30, ASAR ADCs operate in a self-clocked manner to provide more time for the cycle with the smallest di erential comparator input while the other bits are rapidly resolved providing a significant speedup over a fixed clock period designs [55]. Since the ASAR ADC sequentially converts from MSB to LSB, the impact of comparator metastability errors is minimized [60]. Increased sample rates can be achieved with a dedicated comparator

Fig. 31. Skew correction circuits. (a) Phase interpolator [40] and (b) phaseshifting bu er [41].

![[ieee-jssc-wireline-tutorial-2026-032.png]]

for each conversion cycle, which simplifies the feedback logic and removes the comparator precharge delay [40], [61]. Improved noise performance is also possible with calibration that configures the comparator input stage tail device to be as small as possible, while still providing su cient speed to perform the LSB conversion [62].

Mismatches between the sub-ADCs can result in TI gain, skew, BW, and o set errors that degrade SNDR. As wireline RXs generally have uniform input statistics across the subADC channels, gain mismatch can be monitored in the DSP by calculating the normalized di erence in average power of a given channel with respect to whichever of the sub-ADCs is designated as [63]. This error signal can be scaled and integrated to produce the per-channel ADC gain code for correction either in the DSP with additional multipliers [41], [42] or in the analog domain with additional capacitors in the SAR ADC reference DAC [63], programmable reference bu ers [59], or with interleaver VGA stages [40]. Skew mismatch can be estimated digitally with filters that average the absolute di erence between equally-spaced channels [64]. As shown in Fig. 31, this is generally corrected in the analog domain with either dedicated phase interpolators [40] or phase-shifting bu ers [41] for the Rank 1 clocks. The impact of BW mismatches can be minimized by designing for su ciently high BW with the use of BW extension techniques, such as inductive peaking and neutralization capacitors in the interleaver bu ers [33]. Partial correction of phase shift errors caused by BW mismatches is possible with the previously discussed skew correction techniques. Finally, o set mismatch can be monitored in the DSP by calculating the di erence in o set of a given ADC channel with respect to a chosen reference channel. This can then be corrected in the digital domain with additional adders [41], [42] or in the analog domain with various comparator o set correction techniques [63].

3) RX DSP: The first major DSP block is the FFE that performs symbol-by-symbol linear equalization. These FFE blocks can exceed 40 taps to su ciently cancel residual ISI and condition the signal for subsequent DFE or MLSD. While TX-FFE implementations are limited by the maximum output swing constraint that results in the signal-to-noise ratio (SNR) degrading proportional to the sum of the absolute FFE tap values, known as the L -1 norm k ~ c k 1, this is not the case in the RX-FFE [65]. Instead, the RX-FFE will amplify the incoming noise by the root sum of the squares of the FFE tap values, known as the L 2 norm k ~ c k 2. As k ~ c k 2 k ~ c k 1, the SNR with a RX-FFE is generally better and at worst equal

to with a TX-FFE. RX-FFEs are implemented in a parallel manner, with P parallel slices that often match or exceed the ADC TI factor. Due to the lack of feedback, timing constraints can easily be met through pipelining and power e ciency can be improved with techniques such as power supply scaling, employing canonical signed digit (CSD) representation, and tapering the coe cient range for taps far from the main tap [66], [67]. CSD representation utilizes the minimal amount of ones and improves power e ciency by reducing the required partial product additions when performing multiplications with a constant number [68].

While the subsequent digital DFE is also implemented in a parallel manner, its feedback topology poses unique timing challenges. The same speculative technique discussed in Section II can be applied in the digital domain [69] to allow for pipelining in the speculative precomputations. The critical timing path is now transferred to the speculative decision selection mux chain. For example, a 4-PAM 1-tap DFE involves closing timing through a chain of P 4:1 muxes. This is unfortunately still di cult to achieve at high sample rates. Thus, a look-ahead technique can be employed by expressing the current symbol decision as a function of the decision made a look-ahead factor before, rather than the immediate previous decision [70]. This e ectively reduces the number of muxes in the feedback critical path by roughly the look-ahead factor at the cost of additional muxes in the lookahead precomputation block, which can be pipelined. As the logic complexity of both the loop-unrolling and look-ahead techniques grows rapidly with tap count, conventional 4-PAM digital DFE implementations are limited to 1 or 2 taps [7], [33], [39], [40], [41], [42], [43], [44], [46], [47], [48], [53], [56], [62], [71]. To address this, a sliding block DFE has been developed that has no feedback and enables pipelining to implement longer tap-count designs [72]. This architecture uses a T -tap decisor block that implements the T DFE taps and slicing function of a single symbol decision for a signal sample. A decisor runway of length h is implemented with the decision reliability improving consecutively through the blocks. These first h decisions are only used internally and can be limited to less than 10 with a short seeding FFE that improves the estimate of prior symbols.

Additional SNR gains can be achieved with MLSD that involves picking the sequence of symbols, or path through a trellis diagram (Fig. 32), with the minimum Euclidian distance from the MLSD input. For reasonable complexity, the preceding FFE generally conditions the MLSD input to have a 1 + z 1 partial response. MLSD allows for large values of , and commensurately lower noise amplification, than a DFE which exhibits burst errors with large . The Viterbi algorithm allows for e cient MLSD implementations [73]. This consists of three main steps: branch metric computation, selecting the minimum metrics for each state, and updating the survivor sequence. The branch metric is computed by taking the squared di erence between the observed channel output zk and the ideal channel output xk for each possible transition between states in the trellis diagram. Each branch metric is then added to the corresponding previous state metrics to find the candidate new state metrics. These values are compared

Fig. 32. Maximum-likelihood sequence detector.

![[ieee-jssc-wireline-tutorial-2026-033.png]]

Fig. 33. Baud-rate MMPD that detects the di erence in pre- and post-cursor ISI for a symmetric pulse response.

![[ieee-jssc-wireline-tutorial-2026-034.png]]

to find the smallest one terminating in each state that is the most likely branch to that state. This is selected and stored as the new minimum metric for each state. Based on this, the sequence of most likely preceding states is then stored as the survivor sequence for each state. Further reduction in complexity and power is possible with a reduced-state MLSD implementation that, for example, considers only the four most likely (out of the 16 possible) 4-PAM symbol pairs based on preselection by a DFE output [41].

## C. Digital Baud-Rate CDR

A large portion of the clock-and-data recovery (CDR) system, such as the digital phase detector and loop filter, are also generally implemented in the RX DSP. Given the challenges in designing high sample rate ADCs, almost all DSP-based RXs employ baud-rate phase detection that require only one sample per symbol. Fig. 33 details the commonly implemented Mueller-Muller phase detector (MMPD) [74] that assumes a

symmetric pulse response h ( t ). The MMPD objective is to shift the sampling phase so that the first pre- and post-cursor ISI terms are equal. The di erence between them is the error signal driving a timing correction loop and is approximated by

<!-- formula-not-decoded -->

where yk is a digital signal sample sequence and ˆ dk is the symbol decision sequence. If this expression is positive, then the e ective pre-cursor ISI h 1 from ˆ dk is too high and the system is sampling late. Conversely, the expression is negative if the e ective post-cursor ISI h 1 from ˆ dk 1 is too high and the system is sampling early. In order to generate the phase correction, this error information can then be processed by a standard digital proportional / integral loop filter [75] to control either a DCO for a digital PLL-based CDR [40] or a phase interpolator for CDRs that use an external clock generation PLL [41].

The MMPD performs best when dh ± 1 = dt is large and all other ISI taps are zero [76]. These considerations often motivate the use of a parallel shorter timing path FFE t after the ADC that drives the MMPD with a pulse response with enhanced SNR, relative to the raw ADC outputs, at reduced latency [7], [41]. Note that this is di erent criteria than the main FFE / DFE equalization path that seeks to minimize all the ISI terms. Latency through the MMPD and CDR loop filter can exceed 500UI. This excessive CDR path latency can cause limit cycle behavior, degraded phase margin, and undesired jitter tolerance peaking [76]. These considerations often motivate the use of a parallel shorter timing path FFE t after the ADC that drives the MMPD with a properly conditioned pulse response at reduced latency [7], [41]. Note that the BER performance of this FFE t output is not critical, as its only objective is to generate a reliable input signal for the MMPD, and it can thus be made much shorter than the main signal path FFE.

Current state-of-the-art ADC-DSP RXs are achieving JTOL BWs between roughly 5 and 15 MHz with high-frequency JTOL timing margin near 0.1 UIpp [33], [40], [42]. The overall clock performance requirements to achieve this performance should be set considering the DSP equalization impact on the overall SNDR performance at the symbol detection point. Statistical simulation approaches that utilize the equalized pulse response at the digital slicer point and the RX clock jitter pdf are e ective in determining the tolerable random and deterministic jitter (DJ) specifications to achieve a given highfrequency jitter tolerance performance [77], [78]. An e ective jitter-induced noise pdf can be constructed by calculating the ISI pdf from the equalized pulse response at a given timing o set, weighting this by the jitter pdf value at that o set, and integrating over the timing o set span. TI skew errors can also be included by utilizing periodic time-varying pulse responses [78].

## D. Forward Error Correction

It is very di cult to achieve low system BER targets without FEC [79] due to bursts of errors propagating in the RX DSP

Fig. 34. (a) Simplified representation of E / O TX leveraging direct modulation (top) or external modulation (bottom) and (b) O / E RX.

![[ieee-jssc-wireline-tutorial-2026-035.png]]

DFE and MLSD blocks that compensate for high electrical channel loss [80], [81] and random errors in optical links due to low SNR levels [82]. An example is the Reed-Solomon (RS) KP4 FEC code that is commonly used for 100 Gb / s 4-PAM electrical transceivers due to its e ectiveness in correcting burst-mode errors [83]. As shown in Fig. 24, it is configured in an end-to-end fashion with the FEC encoding / decoding occurring before / after the main equalization blocks in the TX / RX DSPs. The RS(544,514,15) code encodes 514 10-bit information symbols into 544 10-bit encoded symbols and can correct up to 15 of these encoded symbols, even if all the bits in those symbols are wrong. However, bit errors would result if there were only 16 random single bit errors spread amongst 16 symbols. In systems that have outer electrical SERDES transceivers interfacing with inner optical modules for longdistance transmission, a concatenated FEC architecture with an internal Hamming code implemented in the optical modules' DSP can e ectively compensate for the optical link random errors [84]. While these FEC codes allow for su ciently low error rates, it does come at the expense of significant latency. For example, assembling a 5440-bit frame at 100 Gb / s takes 54.4 ns and an additional 1-2 frames worth of time is required in the decoding process.

## IV. OPTICAL INTERFACE CIRCUITS

To increase the reach of a link without the losses of a copper channel, optical fibers are used to transport data. High-speed serial data is converted from the electrical to optical (E / O) domain in the TX. Fig. 34(a) shows two kinds of E / O TX. In either of them, the data is first processed before being fed to the driver. In linear implementations, this processing may involve compensating for the loss of the short electrical

TABLE I

## CLASSIFYING VARIOUS E/O MODULATORS

traces via an equalizer (e.g., CTLE) and a pre-driver. Longer traces and higher data rates may even require a CMOS ASIC for CDR, DSP, and DAC before the pre-driver. Fig. 34(b) shows the RX. The front-end handles the optical-to-electrical (O / E) conversion and amplification using a TIA. In linear implementations, a TIA is followed by linear amplification stages (called post-amplifiers or main amplifiers), and linear equalization. Other implementations may include clock recovery, digital equalization or DSP. There are many similarities to the corresponding blocks for electrical links discussed in Sections II and III. Here, we focus on the front-end circuits unique to optical links (highlighted by the gray dotted box in Fig. 34).

## A. E / O Transmitter Front-End

An electrical signal can be used to directly modulate the intensity of a laser, such as in VCSELs [Fig. 34(a), (top)]. The alternative is to treat the output of a laser as a continuous wave (CW) and add electro-optical circuits for external modulation of the CW [Fig. 34(a), (bottom)]. Electro-absorption modulators (EAMs) modulate the intensity via absorption [85], [86]. Other modulators (see Table I) first modulate the phase via carrier injection or depletion of p-i-n or p-n modulators [87], field-e ect in MOS capacitors [88], or Pockels e ect in thin-film lithium niobate (TFLN) [89]. Additional photonic circuits, such as interferometers or resonators, are then added to convert the phase modulation to intensity modulation. The most common examples are the Mach-Zehnder Interferometer (MZI) and microring resonator (MRR) [90]. Electrically, at dc, all junction-based devices require proper biasing (forward or reverse). Both VCSELs and modulators present a parallel combination of R and C as loads. To estimate their E / O BW, optical dynamics must also be taken into account.

Fig. 34(a) shows a simplistic TX where a high-speed driver provides the dc bias and ac swing to the E / O device. The voltage or current levels at the driver output map to intensity levels at the E / O device output. A large optical modulation amplitude (OMA), defined as the di erence between the minimum (PL) and maximum (P H ) transmitted output powers P H -PL, requires a large electrical swing at the output of the driver, from 100's of millivolts to several Volts. The combined swing and BW requirements make the driver design challenging, without exposing transistors to terminal voltages exceeding maximum ratings. For 4-PAM, the driver must also

![[ieee-jssc-wireline-tutorial-2026-036.png]]

Vcathode

Fig. 35. (a) CML driver for a common-cathode VCSEL, (b) the power versus current plot for the VCSEL.

provide adequate linearity; even when a DSP and DAC are included, using them for nonlinearity compensation places additional burden. Finally, all external modulators introduce optical IL even in their most transmissive state, penalizing the optical link budget [91].

Multiple techniques exist to provide a large electrical output swing from the driver. A CML driver can be used to provide a voltage swing proportional to its tail current and the load resistance. Since the latter cannot be increased arbitrarily due to BW constraints, the tail current can be increased at the expense of power consumption. However, the proportional increase in the IR drop across the load requires the driver supply voltage to be increased. Cascode transistors, stacked FETs, and voltage doublers can be employed [92], [93], [94] to reduce the transistor stress. If the E / Omodulator permits, we can drive it in a di erential or push-pull manner to double the voltage swing [86], [92]. Finally, we can also use level shifters and multiple supply voltages to e ectively quadruple the voltage swing [95], [96], [97]. We next provide representative examples for various driver and modulator circuits.

Fig. 35 shows an E / O TX front-end with a CML driver directly modulating a common-cathode VCSEL. The top current source provides the necessary bias current ( I Bias) to keep the diode forward-biased and in the ON state, just above its threshold current to initiate lasing. Turning o a VCSEL is avoided since the turn-on delay is significant and inhibits highspeed operation. The CML circuit provides the necessary I Mod to generate the PAM optical outputs. To increase the OMA, I Mod is increased. The increase is limited by voltage headroom requirements across the current sources, VCC, and transistor breakdown voltages. When I Mod is steered to the left branch of the driver, it is e ectively being wasted in the dummy resistor, R Dummy, whose value is close to the load resistance of the VCSEL. If a nanoscale CMOS process is used, voltage-mode drivers can be considered to enhance energy e ciency [97], [98], [99]. With an increase in the data rates, VCSELs require a separate FFE for their rising and falling edges to compensate for the asymmetric E / O response (dynamic nonlinearity) on those edges (see [101]). Besides FFE, a complex-zero CTLE has also been used in the TX to compensate for the limited BW of the VCSEL and its complex-pole pair response [101], [110].

An EAM is also a diode. Although biased in reverse mode, it generates a large photocurrent due to its absorptive state of

Fig. 36. Di erential dc-coupled CML driver for an EAM.

![[ieee-jssc-wireline-tutorial-2026-037.png]]

Fig. 37. (a) Microring modulator (MRM) circuit with p-n junction-based phase shifters and a heater for biasing and control. (b) Transfer function of the MRM (transmission versus wavelength).

![[ieee-jssc-wireline-tutorial-2026-038.png]]

operation. Consider EAM in place of the VCSEL in Fig. 35. If the top current source is replaced by another resistor, R Dummy, with V Cathode &gt; V DD, then the EAM can be reverse-biased, and its photocurrent can be sunk into R Dummy. A common-anodebased counterpart can also be used. Fig. 36 shows a di erential driver with V Cathode &gt; V Anode [86], which doubles the voltage swing for the same tail current, but su ers from twice the diode capacitive loading (which is often acceptable since an EAM has small capacitance and resistance). It also has di erent collector voltages in the two half-circuits, which leads to a current di erence between the two arms and duty cycle distortion. A current sink, I S , can be added to compensate for both.

For high-speed pn junction modulators in silicon photonics, reverse-bias operation is primarily used for carrier-depletion induced phase modulation [87], [90]. The driver applies voltage to cause a phase shift in the pn junction-laden waveguide. Fig. 37 shows how an MRR modulator (MRM) can be used to convert phase to intensity. A portion of the CW optical light gets coupled into the ring and then couples back out into the through waveguide, with the help of directional couplers (not explicitly shown). The coupled light interferes with the light in the through waveguide. At wavelengths where a round-trip phase shift of 2 radians is accrued in the ring waveguide, destructive interference arises at the output. Thus, a notch wavelength response is seen with minimum transmission at the resonance wavelength. The driver changes the phase shift in the ring with its output voltage, shifting the resonance

Fig. 38. VM driver providing 4VDD swing to the reverse-biased p-n junction in the MRM.

![[ieee-jssc-wireline-tutorial-2026-039.png]]

Fig. 39. (a) CML driver for a traveling-wave MZM and (b) along with the transfer function of the MZM (transmission versus phase di erence between the two arms).

![[ieee-jssc-wireline-tutorial-2026-040.png]]

wavelength. In other words, a phase-dependent optical filter is realized. Thus, at a given wavelength, this optical filter can be made to adjust its transmission, thereby realizing output intensity modulation.

Fig. 38 shows an MRM driver that quadruples its input voltage swing [96]. After feeding the input signal through an inverter, the signal is ac-coupled using a bias-T and levelshifted using inverters operating at di erent voltage supplies. These level-shifted voltages are then combined in a VM driver with cascode devices (for reliability) to obtain 2 × the input swing. Two copies of the driver drive both the anode and cathode out of phase, thereby realizing 4 × the input swing across the diode. A similar circuit could drive VCSELs and EAMs as well, but the larger resistance in the former and the relatively larger photocurrent (versus MRM) in the latter introduce challenges [86]. Non-linear predistortion and FFE are needed to compensate for the static and dynamic nonlinearities of MRM (see [97]).

So far, we have discussed various mechanisms to increase the voltage swing of the driver, thereby realizing a large OMA. However, there is a limit to increasing the voltage swing of the driver while simultaneously achieving a large E / O BW. The MZI a ords another degree of freedom to relax the constraint: the length L of the two arms of the MZI. As shown in Fig. 39, the input CW light is split equally (in intensity) and travels on the two arms of the MZI. The two waveguides are loaded with distributed, reverse-bias pn junctions and are then combined at the optical output. Modulating signals are launched as traveling electric waves

from the CML driver along transmission-line electrodes. The transmission lines are terminated at the near and far ends with resistors that are equal to the characteristic impedance of the line. This impedance matching prevents reflections and absorbs the diode capacitances into the transmission line, significantly boosting the electrical BW. The optical and electrical waveguides are designed such that their corresponding waves travel together. Thus, the e ect of the driver voltage is seen by the optical wave over the length L of the line, accumulating the phase shift. Therefore, the voltage swing required from the driver can be reduced by designing a long modulator. When the accrued phase shift in the two arms are the same, constructive interference arises at the output, and the net output intensity (PH) remains identical to the input intensity minus the IL inherent to the pn junction-laden waveguides. When the accrued phase shifts give rise to destructive interference, a minimum output optical intensity (PL) results. The voltage required to introduce a relative phase shift is V . Hence, a net voltage-to-intensity (nonlinear) modulation is realized, with the modulation e ciency dependent on V × L . Realistically, there is a limit to increasing L due to area, optical and RF IL. Moreover, di erences in propagation velocity along the electrodes and optical waveguides accrue along their length introducing BW limitations. In practice, only a fraction of V is delivered by the driver, which also limits the extent of the nonlinearity. With a pair of waveguides, the MZM naturally lends itself to a di erential drive. However, the presence of both near-end and far-end terminations halves the e ective voltage swing. By co-packaging the driver circuits with the MZM device, the near-end termination may be rendered unnecessary.

The bias voltages for the MZM diodes must be controlled to compensate for PVT variations. Phase-to-intensity modulators such as MRRs and MZIs also require proper phase biasing [see Figs. 37(b) and 39(b)] and control, as the refractive index of silicon waveguides varies with temperature. The phase biasing for both MRR and MZI is typically achieved in silicon photonics using heaters, which are essentially resistors that utilize Ohmic heating to modify the phase of the optical wave. The resonant nature of the MRM makes their sensitivity to PVT significantly worse, requiring extremely accurate temperature and wavelength controllers [96], [102].

Table I also includes other phase modulators, such as MOS capacitors and TFLNs, that can be configured in an MZI or MRR to realize intensity modulation. The MOS cap-based modulators have limited BW, whereas TFLN-based devices promise lower IL and V and higher BW than silicon MZIs but have not yet been manufactured in high volume [103].

## B. O / E Receivers

TIAs in optical RXs must e ciently convert the small unipolar current output of photodetectors into a larger, lownoise voltage signal with appropriate dc cancellation and amplification. The minimum OMA needed at the RX is determined by the TIA's noise characteristics, the photodetector's responsivity, and the extinction ratio. Thus, the noise and gain of a TIA directly impact the TX and optoelectronic device requirements. Generally, to achieve a target SNR and BER, TIAs require low input-referred noise, including both

Fig. 40. Shunt-feedback TIAs: (a) Common-emitter amplifier with emitterfollower and (b) inverter-based.

![[ieee-jssc-wireline-tutorial-2026-041.png]]

thermal noise and power-supply noise. In a di erential TIA architecture connected to both the anode and cathode of the PD via anode and cathode bias-Ts (coupling capacitors and bias resistors), the signal is doubled, but the noise is increased by only (2) 1 = 2 × [104]. However, the required supply regulation requirements for such a di erential PD topology often limits the SNR improvement - a low output resistance of the regulator is needed for higher load / line regulation and power supply noise rejection, which mandates a large coupling capacitor to prevent baseline wander [105]. However, the parasitic capacitance of the coupling capacitor shunts the PD current and deteriorates the TIA gain [105]. If the power supply is regulated at the PD such that the bias-T is not needed at the anode and a smaller coupling capacitor can be used, and the successive TIA stages are also regulated, the singleended-to-di erential conversion can be deferred to later stages [106], [107].

Di erent TIA topologies are used depending on the target gain and phase response, BW, input-referred noise, linearity, and power consumption, as well as the fabrication technology (BiCMOS generally o ering high f T and f max, lower noise, and higher supply voltage versus advanced CMOS o ering options for dense DSP implementations). The classical GMboosted common-gate amplifiers, known as the regulated gate cascode [109], typically provide a large BW, but also exhibit higher noise. Therefore, most modern TIAs leverage shuntfeedback topologies for lower noise. These include resistor shunt feedback across a common-emitter (source) amplifier with emitter (source)-follower output [104], [108], as shown in Fig. 40(a), or across a CMOS inverter, as shown in Fig. 40(b). The inverter-based TIA is particularly suited for low supply voltages in scaled CMOS processes. With pMOS and nMOS device transconductance and parasitic capacitance similar in such processes, both pMOS and nMOS can provide comparable transconductance with the same bias current. The resistor feedback self-biases the inverter at its threshold voltage, where the gain is large. However, the lack of current sources makes inverter-TIAs sensitive to PVT and supply noise, and they must be used in conjunction with supply regulation [111].

Ultimately, the performance of shunt-feedback TIAs su er at high data rates because both the noise and BW scale inversely with RF , while the gain requires increasing the R F [112]. Several designs, therefore, adopt a multistage approach, where the first-stage TIA is deliberately designed to have higher gain, lower BW, and lower noise, and succeeding stages use linear equalization to increase the overall BW [113]. Since linear equalizers can also amplify high-frequency noise, this

Fig. 41. Inverter-based O / E RX with multistage design approach to relax the gain-noise-BW tradeo (top). Illustrative response from [96]: Stage 1 has a BW of 10 GHz with a relatively slow roll-o (bottom). Stages 2 and 3 provide up to 4 dB boost at 25 GHz and 7 dB boost at 30 GHz, respectively, to realize an overall transimpedance (ZT) BW of 39 GHz.

![[ieee-jssc-wireline-tutorial-2026-042.png]]

multistage approach requires careful design [106], [115]. The use of a DFE can ameliorate noise amplification [112], [114], but requires a mixed-signal implementation and necessitates clock recovery. T-coils are used at the PD-TIA input and the output bu er-pad interfaces. Many of the same techniques used in electrical transceivers can also extend BW, improve phase response, and reduce group delay variation in high-speed E / O TX and O / E RX front-ends, including inductive peaking [6], [106], [107], [116], [117], CTLE and Cherry-Hooper (CH) stages [115]. Peaking techniques can also reduce the input-referred noise in the TIA by attaining a noise-matching condition [108].

Fig. 41 shows an illustrative inverter-based multistage RX front-end [106], [107], [115]. Stage 1 is a high-gain, lowBW TIA, whose BW is then recovered via CTLE boosting in stages 2 and 3. Stage 2 is a CH design consisting of a GM stage followed by a TIA. Stage 3 has the largest BW and the largest high-frequency boost, and is also composed of a GM-TIA combination followed by a single-to-di erential (S2D) converter where the output is out of phase with the input (although, at high frequency, the TIA3 delay can lead to a significant phase and amplitude mismatch). A dc o set cancellation (DCOC) loop is implemented by a low-pass filter formed by a resistor and a capacitor across an inverter.

## V. CLOCKING

In this section, we will discuss clocking architectures and design considerations, followed by clock generation, distribution, multi-phase generation (MPG), phase interpolation circuits, and clock calibration techniques.

## A. Clocking Architectures

To enable ultrahigh-speed data links, clocking requirements such as random jitter (RJ), DJ, operating frequency, and

Fig. 42. Example of clocking architecture and building blocks for a multitransceiver system.

![[ieee-jssc-wireline-tutorial-2026-043.png]]

multi-phase clock generation with high accuracy become more stringent. Frequency synthesizers such as PLLs and injectionlocked oscillators (ILOs) generate the high-frequency clock at the output of a voltage-controlled oscillator (VCO) from a low-frequency reference clock (CKref). A global / common PLL can generate the IO clock for multiple TX and RX lanes [32], [118]. Alternatively, a dedicated PLL per TX / RX lane can enable flexible clocking schemes, such as supporting multiple standard specifications by allowing independent data rates [7], [33], [48]. Fig. 42 conforms to a typical floorplan of multiple transceivers (TRXs), with a global PLL output clock distributed through the center, tapped o to the clocking circuits for the RX and TX lanes located on either side, and passed on to the next TRX.

Compact and low-power PLLs are key to enabling multiple PLLs. Electromagnetic (EM) coupling between inductors in LC -VCO PLLs that are in close proximity to each other degrades performance. Increasing the spacing between inductors suppresses the coupling at the cost of area. An areae cient solution, introduced in [7], suppresses the coupling through the feedback loop where the noise shaping is set by the PLL BW and the coupling strength [119]. Eight-shaped inductors can cancel mutual coupling between inductors and hence enable overlapping between LC -VCO PLLs to save area [120]. Pulling and unwanted injection locking among VCOs through EM coupling or substrate need to be modeled [121], [122].

Fig. 43. (a) PLL block diagram, (b) PLL jitter transfer and generation, and (c) schematic of a typical high-performance PLL.

![[ieee-jssc-wireline-tutorial-2026-044.png]]

Another design consideration is the relationship between the IO clock frequency and data rate. To double the data rate with the same modulation, two scenarios can be considered: 1) doubling the clock frequency, which consumes higher power in the clock distribution to minimize jitter amplification (JA); 2) doubling the time-interleaving, for instance, from a quarter-rate ( N or K = 4) to eighth-rate ( N or K = 8) clocking system in Fig. 42, which maintains the same PLL clock frequency, hence it consumes lower power in the clock distribution by relaxing the number of stages (i.e., higher fanout), but requires more complex multi-phase clock generation (MPG) with high accuracy. For an N -rate ( N &gt; 2) clocking architecture (e.g., the RX architecture in Fig. 42), an N -clock MPG is typically implemented whose outputs are distributed locally to each data lane, and whose inputs are M clock phases generated by a PLL / ILO globally or locally [7], [32], [33], [42], [49], [118]. TX and RX lanes might have the same ( K = N ) or di erent sub-rate clocking architectures ( K , N ).

## B. Clock Generation

VCOs are one of the key building blocks in PLLs [Fig. 43(a)] and ILOs. LC -VCOs are widely used due to their superior jitter or phase noise (PN) performance. The PN performance of an LC -VCO is limited by the LC -tank quality factor ( Q ). As clock frequency increases, achieving a high Q , especially over a wide tuning range, becomes more challenging due to the limited Q of a varactor or a switchedcapacitor (SW-CAP) [123]. A two-way coupled oscillator, composed of two identical LC -VCOs, improves the PN by 3 dB but at the cost of doubling area and power consumption [124], [125], [126], and hence there is no benefit in figure-ofmerit (FOM). A frequency doubler in [123] achieves 1.25 dB better PN, by coupling between f0 and 2f0 LC -VCOs, than the conventional two-way coupled oscillator and frequency doubler. By stacking two oscillators through the transformer [123], the current is reused, reducing power consumption by 30%-50% and achieving a 3-4.75 dB improvement in FOM compared to conventional LC -VCOs.

Compared to LC -VCOs, ring oscillators (ROs) o er a compact area and wider operating frequency range; however, they su er from higher RJ and DJ due to excessive device noise and supply noise sensitivity inherent to ROs, respectively. To mitigate DJ, low-dropout regulators (LDOs) are used to supply the RO and LC -VCO with high power supply noise rejection (PSRR) [33], [123]. To meet stringent RJ requirements ( &lt; 100 fs), ROs typically consume much higher power [127], [128] than LC -VCOs.

The VCO jitter will further be suppressed by the PLL loop through the jitter generation profile [Fig. 43(b)]. The PLL BW is typically less than one-tenth of the CKref. To widen the BW, a sub-harmonic injection-locked PLL in [129] extends the BW to one-sixth of the CKref. A frequency-tracking loop (FTL) is necessary to achieve low jitter across a wide range of frequencies. Sub-sampling (SS) PLLs [130], [131] can achieve a higher BW where the CKref sub-samples the VCO and eliminates the divider in the feedback loop, helping suppress the jitter due to the loop filter. By using both the rising and falling edges of the CKref, the ping-pong sampling phase detector (PP-SPD) in [132] can further extend the loop BW. Similar to ILOs, the SS-PLLs require FTLs to avoid harmonic locking.

Another approach to widen the PLL BW is to increase the CKref [33], [129], [131], for instance by employing a cascaded PLL architecture (Fig. 42). In the cascaded architecture, the first PLL, also referred to as a jitter-cleanup (JC) PLL, is designed with low BW to multiply and filter the CKref, which may originate from a low-cost noisy crystal oscillator, through its jitter transfer profile [Fig. 43(b)]. The second PLL is designed with high BW to suppress its VCO jitter [Fig. 43(b)].

When the IO clock frequency is not an integer multiple of the CKref, a fractionalN PLL employing a multi-modulus divider (MMD) generates the desired clock frequency [123], [130], [133]. To filter the quantization noise generated by the dithered MMD, a delta-sigma modulator ( M) in the feedback loop shapes the dither to high frequencies, where it is then filtered by the limited BW of the PLL loop. Hence, there is a tradeo in setting the PLL BW to minimize the VCO versus dither jitter. Fig. 43(c) shows a 23.9-29.4 GHz digital LC -PLL architecture [123] with a coupled frequency doubler for 224 Gb / s 4-PAM TX clocking [27].

## C. Clock Distribution

Once sub-rate clock signals are generated, they need to be distributed to multiple TX / RX lanes with minimum power

Fig. 44. Frequency, jitter impulse, and jitter transfer responses for (a) lowpass, (b) highpass, and (c) bandpass systems.

![[ieee-jssc-wireline-tutorial-2026-045.png]]

consumption and jitter generation (Fig. 42). The distribution network also requires adequate BW to minimize JA, especially at high frequencies as shown in Fig. 44(a) [134]. Various clock distribution architectures reported in the literature can be mainly categorized into repeater-based or repeaterless architectures.

In a repeater-based architecture, multiple bu ers along each interconnect are used [Fig. 45(a)-(c)]. CML repeater-based clock distribution [Fig. 45(a)] delivers a low-swing clock that needs to be converted to a full CMOS level to drive TX serializer or RX slicers [135]. CML clock bu ers experience higher RJ due to degraded SNR in low-swing signals. CML bu ers also require bias current, making them less process and power supply scaling friendly. In addition, they consume static power, which degrades energy e ciency, especially at lower clock frequencies. While CML bu ers provide good PSRR, the overall DJ is higher due to the poor PSRR of the level converters.

CMOS clock distribution [Fig. 45(b)] delivers a full-swing clock using scaling-friendly inverter circuits whose power consumption scales with clock frequency [125]. CMOS inverters have high supply noise sensitivity. The DJ can be minimized by using fewer and larger bu ers with correspondingly longer interconnect lengths per stage [125]. An LDO can further improve the DJ by filtering the supply noise at the cost of additional power [33]. To reduce RJ and JA, the number of inverter stages is chosen large enough to ensure fast rise-fall transition times but small enough to avoid jitter accumulation [125]. As clock frequency increases, however, the number of inverters exponentially increases, which results in high power consumption, degrading both RJ and DJ. In such cases, halving the sub-rate clock frequency can improve jitter and power at the cost of doubling the number of clock phases.

Fig. 45. Repeater-based (a) CML, (b) CMOS, (c) CMOS clock bu ers with tuned loads, and repeaterless (d) R -terminated, (e) far-end, and (f) center LC -terminated TL-based clock distribution.

![[ieee-jssc-wireline-tutorial-2026-046.png]]

A CMOS clock bu er with a tuned load [101] as shown in Fig. 45(c), or a series-shunt configuration in [27] introduces a zero or bandpass characteristic [Fig. 44(c)] in the transfer function which attenuates high-frequency jitter of the input clock. The BW extension also results in sharper rise-fall transition times, which reduces the bu er jitter generation as less intrinsic voltage noise is converted into RJ. The presence of a zero also provides a phase lead, which results in a smaller delay, and hence, less DJ. The LC resonance network reduces the amount of current to be sourced through the clock bu er to reach rail-to-rail swings. Better jitter and power performance trade o with the limited operating frequency range of the resonance network, which can be tuned by a varactor or SWCAP array.

Repeaterless transmission (TL)-based clock distribution [Fig. 45(d)-(f)] benefits from the wire inductance, maintaining a sharp clock edge without repeaters [136]. The conventional resistively-terminated TL-based clock distribution [Fig. 45(d)] operates over a wide range of frequencies similar to CMOS inverter-based repeaters, while achieving lower jitter, especially as the distribution length approaches a fraction of the clock wavelength ( ) [101], [136]. Compared to an unterminated TL [137], the TL with resistive termination avoids

uncontrolled reflection and signal distortion (for long-range distribution) at the cost of higher power.

Resonant LC -termination at the far end of the TL-based distribution [Fig. 45(e)] improves power and jitter through standing-wave-based resonance [138], [139]; however, it has significant gain variation across the distribution [140]. Center termination [Fig. 45(f)] with a similar area as far-end termination improves amplitude matching across the distribution [101]. A higher-order harmonic filter at the input / drive side of the network [Fig. 45(f)] reduces clock distortion by providing a low-impedance path for the higher (specifically, the third) harmonic current [101]. To support a wider range of clock frequencies, the resonance frequencies of the distribution network and the harmonic filter can be tuned by a varactor or SWCAP array. Using amplitude detectors, the capacitor settings and driver slices (to compensate for the SW-CAP's lowQ at low-frequency) are set for the maximum swing [101].

Quadrature locked loops (QLLs) are also used to drive quadrature clock phases to a TX / RX lane local ILO without any repeaters in [141]. While this architecture can improve power and benefit from injection lock jitter filtering, scaling it to higher clock frequencies can be challenging, mainly due to the QLL interconnect loading.

## D. Multi-Phase Generator (MPG)

To support N -rate ( N &gt; 2) clocking architectures, N clock phases ultimately need to be generated (Fig. 42). Frequency dividers in each TX / RX lane can generate quadrature clock phases from a di erential clock [137], [142] but require clock generation (and distribution) at twice the desired frequency where it can be challenging to meet jitter and power targets.

Passive polyphase filters (PPFs) [143] can generate samefrequency quadrature clock phases but su er from higher-order harmonics when driven by CMOS inverters, resulting in quadrature error and signal integrity degradation. As frequency scales, high signal-path loss of the PPF limits power and jitter performance. Active PPFs [144], on the other hand, can provide gain at low swing but are less process and power supply scaling friendly, similar to CML bu ers.

The coupled-resonator-based quadrature hybrid (CRQH), using a single coupled inductor [Fig. 46(a)], introduces a 90 phase shift between the signals at the 'drive-port' and 'coupled-port' at a frequency of interest, tunable by capacitor C [145]. Unlike PPFs, the frequency selectivity in CRQH provides high gain only at the operating frequency, which mitigates harmonic distortion and filters the jitter [Fig. 44(c)]. The frequency-tuning range is further enhanced in [101] by introducing a Q -factor tuning scheme where a tunable resistor R in the coupled port is added [Fig. 46(a)].

By coupling two LC VCOs, an LC PLL can generate quadrature clocks at the cost of area and jitter degradation [146], [147], [148]. Ring PLLs can generate multiple clock phases, but the number of delay stages and hence N reduces as the clock frequency increases. A dual-feedback VCO architecture that couples two 2-stage ROs [Fig. 46(b)], can break these tradeo s where eight clock phases are generated up to 28 GHz [128].

Fig. 46. Multi-phase generator. (a) CRQH, (b) DLL + ILO with dual feedback VCO, and (c) Q -path with tunable delay stages.

![[ieee-jssc-wireline-tutorial-2026-047.png]]

Similar to ring PLLs, delay locked loops (DLLs) can generate N clock phases; however, they su er from RJ due to jitter accumulation and higher power to meet the minimum delay per stage (tdmin) as clock frequency increases. Reducing the number of DLL stages relaxes the tdmin and reduces power, but at the cost of JA. Alternatively, an architecture with a separate Q -path [Fig. 46(c)], which uses tunable delay stages, controlled by a background calibration loop, is used to generate quadrature clock phases [27], [33], [42]. While this architecture can reduce power, it requires careful design of tunable delay stages to reduce jitter and JA in the Q -path.

Ring ILOs can be used to generate the N clock phases [32], [141], [149], [150]. In [32], eight phases up to 14 GHz clock frequency are generated where a digital feedback loop comprising phase-shifting bu ers at the ILO output and timeto-digital converters (TDCs), mitigates the phase errors caused by the injection. Alternatively, DLL + ILO architectures [Fig. 46(b)] are employed to improve the phase accuracy of the ILO clock phases [128], [150].

Fig. 47. (a) CMPI, (b) VMPI, (c) IMPI, and (d) IMPI with dual-edge interpolation.

![[ieee-jssc-wireline-tutorial-2026-048.png]]

## E. Phase Interpolator

A PI or rotator is another key clocking circuit that receives multiple phases ( 4) from the MPG and generates N rotated clock phases to optimally sample the data in an N -rate RX architecture (Fig. 42) or align the TX serializer clocks [27]. In plesiochronous systems, the RX needs to recover its clock from the data while compensating for the frequency di erence between the TX and the RX. The clock-and-data recovery (CDR), as discussed in Section III-C, is typically either based on a digital PLL or PI architecture. In a PI-based architecture, the CDR loop rotates the PI to compensate for the frequency mismatch. The PI quantization error, combined with its di erential and integral nonlinearity (DNL and INL), results in DJ that needs to be minimized.

Fig. 47 shows di erent PI architectures, which receive two clock phases (CK ' 1in and CK ' 2in ), typically selected by a multiplexer from multiple output clock phases of an MPG, and generate a rotated output clock (CKPIout). The PI code sets the weights (M and K ) and hence the PI output clock phase. Current-mode PIs (CMPIs) [Fig. 47(a)] can achieve high linearity but at the cost of digital overhead to generate sinusoidal weights. CMPIs are also less suitable for railto-rail CMOS clocking and advanced process nodes [150]. Voltage mode PIs (VMPIs) [Fig. 47(b)] consist of weighted tri-stated inverters, which are shorted at the output and driven by the overlapping input clock phases (CK ' 1in and CK ' 2in ) [149]. VMPIs are scalable but require more input phases and slew-rate control circuitry to improve nonlinearity, but jitter degrades due to device noise from clock bu ers and power supply noise.

In integrating-mode PIs (IMPIs) [151], [152], [153], [154], a weighted current source charges a capacitor during the timeseparation of the input clock phases (CK ' 1in and CK ' 2in ) to produce a variable slope followed by a constant slope voltage ramp [Fig. 47(c)]. A discharge signal (CKdischarge) performs the reset operation. In [154], the constant and variable voltage slopes are generated by current sources / sinks which are driven by CK ' 1in, CK ' 2in , and their complementary clock phases [Fig. 47(d)], achieving dual-edge interpolation with improved duty-cycle distortion characteristics, compared to the IMPIs in [152]. [153]. [154]. The IMPIs can achieve good linearity, but level converters are required to generate full CMOS levels at the PI output [Fig. 47(c) and (d)], which may incur a DJ penalty.

A twin-PI architecture where the outputs from two PIs are combined can improve the linearity but roughly doubles the power and area [155]. Employing a pre-distortion lookup table (LU) can improve INL while slightly degrading DNL and area e ciency [142]. The PI in [48] is embedded within the Rx lane PLL, where the PLL loop enhances linearity using 45 clock phases from the RO. The embedded PI architecture also improves power consumption as only a single PI (as opposed to four) can rotate all quadrature clock phases. PIs can also be used as an MPG to both generate and rotate N &gt; 4 (e.g., N = 8 in [142]) clock phases for N -rate clock architectures.

## F. CLOCK CALIBRATION

As data rates increase, clock timing errors become a larger fraction of the symbol period. With the continuation of process scaling, variations and hence clock errors may tend to increase due to smaller device feature size / area. Increasing the interleaving ( N ) to mitigate process limitations demands variation-tolerant circuit and clock calibration techniques such as duty-cycle and multi-phase detection and correction with high accuracy ( &lt; 100 fs).

The accuracy of detector circuits is essential where their self-induced error needs to be minimized. The duty-cycle error can be measured by comparing the accumulated number of ones when sub-sampling the complementary clocks with a low-frequency asynchronous clock, such as a free-running VCO [156]. By increasing the number of accumulations in this average-based measurement, better accuracy can be achieved. The multi-phase error can be detected similarly by measuring the overlap between the two clocks [156]. The correction circuits are typically composed of programmable delay cells with independently adjustable rising / falling edges and variable capacitive loads to cover the variation range while meeting the accuracy target ( &lt; 100 fs).

## VI. FUTURE DIRECTIONS

Looking ahead, wireline transceivers will continue pushing toward higher baud rates to support single-lane speeds above 200 Gb / s, with 400 Gb / s serial data rates being an obvious next step. Higher-order modulation formats (e.g., 6-PAM and / or

8-PAM) will be tools to maximize spectral e ciency. The e cient implementation of DSP to perform the equalization and detection will be an important research topic. At the same time, forward-error correction engines are evolving from simple hard-decision schemes to sophisticated soft-decision architectures, often built from concatenated and interleaved codes (e.g., LDPC + BCH or Turbo + Reed-Solomon) to squeeze out every last bit of coding gain.

Higher data rates are straining copper's ability to escape the package at multihundred gigabit speeds. Thus, copackaged copper interconnects-where copper connects directly to the top of package substrates - are emerging as an attractive option to ameliorate the impedance discontinuities presented by large package designs. Meanwhile, research into novel optoelectronic devices is pushing optical interconnect toward low power, high bandwidth links that may be tightly integrated alongside transceiver circuits. More generally, the increasing prevalence of advanced packaging technologies enabling chiplet-based systems-in-package is opening new possibilities to partition compute and connectivity systems across multiple dies. Finally, if (when) higher serial data rates prove impractical, an obvious alternative is to add more lanes, making dense transceiver design important.

## REFERENCES

- [1] R. Farjad-Rad, C.-K. K. Yang, M. A. Horowitz, and T. H. Lee, 'A 0.4 CMOS 10-Gb / s 4-PAM pre-emphasis serial link transmitter,' IEEE J. Solid-State Circuits , vol. 34, no. 5, pp. 580-585, May 1999.
- [2] W. Ellersick, C.-K. Ken Yang, M. Horowitz, and W. Dally, 'GAD: A 12-GS / s CMOS 4-bit A / D converter for an equalized multi-level link,' in Proc. Symp. VLSI Circuits. Dig. Papers , Jun. 1999, pp. 49-52.
- [3] P. Schvan et al., 'A 24GS / s 6b ADC in 90nm CMOS,' in Proc. IEEE Int. Solid-State Circuits Conf.-Dig. Tech. Papers , San Francisco, CA, USA, Feb. 2008, pp. 544-634.
- [4] T. Anand. Wireline Link Performance Survey . Accessed: Jul. 30, 2025. [Online]. Available: https: // web.engr.oregonstate.edu /
- [5] K. Gopalakrishnan et al., '3.4 A 40 / 50 / 100Gb / s PAM-4 Ethernet transceiver in 28 nm CMOS,' in IEEE Int. Solid-State Circuits Conf. (ISSCC) Dig. Tech. Papers , San Francisco, CA, USA, Jan. 2016, pp. 62-63.
- [6] S. Galal and B. Razavi, 'Broadband esd protection circuits in CMOS technology,' IEEE J. Solid-State Circuits , vol. 38, no. 12, pp. 2334-2340, Dec. 2003.
- [7] H. Park et al., 'A 4.63pJ / b 112Gb / s DSP-based PAM-4 transceiver for a large-scale switch in 5 nm FinFET,' in IEEE Int. Solid-State Circuits Conf. (ISSCC) Dig. Tech. Papers , Feb. 2023, pp. 110-111.
- [8] J. F. Bulzacchelli et al., 'A 28-Gb / s 4-tap FFE / 15-tap DFE serial link transceiver in 32-nm SOI CMOS technology,' IEEE J. Solid-State Circuits , vol. 47, no. 12, pp. 3232-3248, Dec. 2012.
- [9] Y. Segal et al., 'A 1.41pJ / b 224Gb / s PAM-4 SerDes receiver with 31dB loss compensation,' in IEEE Int. Solid-State Circuits Conf. (ISSCC) Dig. Tech. Papers , Feb. 2022, pp. 114-115.
- [10] M. Drallmeier and E. Rosenbaum, 'Distributed protection for highspeed wireline receivers,' in Proc. 45th Annu. EOS / ESD Symp. (EOS / ESD) , Oct. 2023, pp. 1-9.
- [11] J. E. Proesel and T. O. Dickson, 'A 20-Gb / s, 0.66-pJ / bit serial receiver with 2-stage continuous-time linear equalizer and 1-tap decision feedback equalizer in 45nm SOI CMOS,' in Proc. Symp. VLSI Circuits-Dig. Tech. Papers , Jun. 2011, pp. 206-207.
- [12] R. Shivnaraine et al., 'A 26.5625-to-106.25Gb / s XSR SerDes with 1.55pJ / b e ciency in 7 nm CMOS,' in IEEE Int. Solid-State Circuits Conf. (ISSCC) Dig. Tech. Papers , Feb. 2021, pp. 182-183.
- [13] G. Gangasani et al., 'A 1.6Tb / s chiplet over XSR-MCM channels using 113Gb / s PAM-4 transceiver with dynamic receiver-driven adaptation of TX-FFE and programmable roaming taps in 5nm CMOS,' in IEEE Int. Solid-State Circuits Conf. (ISSCC) Dig. Tech. Papers , Feb. 2022, pp. 122-123.
- [14] G. Gangasani et al., 'A 32 Gb / s backplane transceiver with on-chip ACcoupling and low latency CDR in 32 nm SOI CMOS technology,' IEEE J. Solid-State Circuits , vol. 49, no. 11, pp. 2474-2489, Nov. 2014.
- [15] Y. Oh, S. Lee, and H. H. Park, 'A 2.5Gb / s CMOS transimpedance amplifier using novel active inductor load,' in Proc. 27th IEEE Eur. Solid State Circuits Conf. (ESSCIRC) , Sep. 2001, pp. 178-181.
- [16] P. A. Francese et al., 'Continuous-time linear equalization with programmable active-peaking transistor arrays in a 14 nm FinFET 2mW / Gb / s 16Gb / s 2-tap speculative DFE receiver,' in IEEE Int. Solid-State Circuits Conf. (ISSCC) Dig. Tech. Papers , Oct. 2015, pp. 186-187.
- [17] E. M. Cherry and D. E. Hooper, 'The design of wide-band transistor feedback amplifiers,' Proc. Inst. Electr. Eng. , vol. 110, no. 2, pp. 375-389, Feb. 1963.
- [18] A. Cevrero, 'A 100Gb / s 1.1pJ / b PAM-4 RX with dual-mode 1-tap PAM4 / 3-tap NRZ speculative DFE in 14 nm CMOS FinFET,' in IEEE Int. Solid-State Circuits Conf. (ISSCC) Dig. Tech. Papers , Feb. 2021, pp. 1-3.
- [19] J. Savoj et al., 'A wide common-mode fully-adaptive multi-standard 12.5Gb / s backplane transceiver in 28 nm CMOS,' in Proc. Symp. VLSI Circuits (VLSIC) , Jun. 2012, pp. 104-205.
- [20] S. Parikh et al., 'A 32Gb / s wireline receiver with a low-frequency equalizer, CTLE and 2-tap DFE in 28 nm CMOS,' in Proc. IEEE Int. Solid-State Circuits Conf. Dig. Tech. Papers , Feb. 2013, pp. 28-29.
- [21] K. Zheng, Y. Frans, K. Chang, and B. Murmann, 'A 56 Gb / s 6 mW 300 2 inverter-based CTLE for short-reach PAM2 applications in 16 nm CMOS,' in Proc. IEEE Custom Integr. Circuits Conf. (CICC) , Apr. 2018, pp. 1-4.
- [22] K. Zheng et al., 'An inverter-based analog front end for a 56 GB / S PAM4 wireline transceiver in 16NMCMOS,' in Proc. IEEE Symp. VLSI Circuits , Jun. 2018, pp. 269-270.
- [23] M. Park, J. Bulzacchelli, and D. Friedman, 'A 7 Gb / s 9.3 mW 2tap current-integrating DFE receiver,' in IEEE Int. Solid-State Circuits Conf. (ISSCC) Dig. Tech. Papers , Feb. 2018, pp. 106-108.
- [24] T. O. Dickson, J. F. Bulzacchelli, and D. J. Friedman, 'A 12-Gb / s 11-mW half-rate sampled 5-tap decision feedback equalizer with current-integrating summers in 45-nm SOI CMOS technology,' IEEE J. Solid-State Circuits , vol. 44, no. 4, pp. 1298-1305, Apr. 2009.
- [25] Z. Toprak-Deniz et al., 'A 128-Gb / s 1.3-pJ / b PAM-4 transmitter with reconfigurable 3-tap FFE in 14-nm CMOS,' IEEE J. Solid-State Circuits , vol. 55, no. 1, pp. 19-26, Jan. 2020.
- [26] C. Menolfi et al., 'A 112Gb / S 2.6pJ / b 8-tap FFE PAM-4 SST TX in 14 nm CMOS,' in IEEE Int. Solid-State Circuits Conf. (ISSCC) Dig. Tech. Papers , Feb. 2018, pp. 104-105.
- [27] J. Kim et al., 'A 224-Gb / s DAC-based PAM-4 quarter-rate transmitter with 8-tap FFE in 10-nm FinFET,' IEEE J. Solid-State Circuits , vol. 57, no. 1, pp. 6-20, Jan. 2022.
- [28] M. Kossel, 'An 8b DAC-based SST TX using metal gate resistors with 1.4pJ / b e ciency at 112Gb / s PAM-4 and 8-tap FFE in 7 nm CMOS,' in IEEE Int. Solid-State Circuits Conf. (ISSCC) Dig. Tech. Papers , Feb. 2020, pp. 128-130.
- [29] M. Kossel et al., 'A T-coil-enhanced 8.5 Gb / s high-swing SST transmitter in 65 nm bulk CMOS with &lt; -16 dB return loss over 10 GHz bandwidth,' IEEE J. Solid-State Circuits , vol. 43, no. 12, pp. 2905-2920, Dec. 2008.
- [30] J. Kim et al., 'A 112 Gb / s PAM-4 56 Gb / s NRZ reconfigurable transmitter with three-tap FFE in 10-nm FinFET,' in Proc. IEEE J. Solid-State Circuits , Jan. 2018, vol. 54, no. 1, pp. 29-42.
- [31] M. Cusmai, 'A 224Gb / s sub pJ / b PAM-4 and PAM-6 DAC-based transmitter in 2 nm FiNFET,' in IEEE Int. Solid-State Circuits Conf. (ISSCC) Dig. Tech. Papers , Feb. 2023, pp. 152-154.
- [32] D. Pfa , 'A 224Gb / s 3pJ / b 40dB insertion loss transceiver in 3 nm FinFET CMOS,' in IEEE Int. Solid-State Circuits Conf. (ISSCC) Dig. Tech. Papers , Feb. 2024, pp. 105-107.
- [33] E.-H. Chen et al., 'A 212.5Gb / s DSP-based PAM-4 transceiver with 50dB loss compensation for large AI system interconnects in 4nm FinFET,' in IEEE Int. Solid-State Circuits Conf. (ISSCC) Dig. Tech. Papers , Feb. 2025, pp. 136-137.
- [34] B. Moeneclaey et al., 'A 7-bit 150-GSa / s DAC in 5 nm FinFET CMOS,' in Proc. Symp. VLSI Technol. Circuits (VLSI Technol. Circuits) , Jun. 2025, pp. 1-3.
- [35] T. O. Dickson et al., 'A 72GS / s, 8-bit DAC-based wireline transmitter in 4 nm FinFET CMOS for 200 + Gb / s serial links,' IEEE J. Solid-State Circuits , vol. 58, no. 4, pp. 28-29, Apr. 2022.

- [36] M. Choi et al., '8 An output-bandwidth-optimized 200Gb / s PAM-4 100Gb / s NRZ transmitter with 5-tap FFE in 28 nm CMOS,' in IEEE Int. Solid-State Circuits Conf. (ISSCC) Dig. Tech. Papers , Feb. 2021, pp. 128-129.
- [37] Z. Toprak-Deniz et al., 'A 0.88pJ / bit 112Gb / s PAM4 transmitter with 1Vppd output swing and 5-tap analog FFE in 7 nm FinFET CMOS,' in Proc. IEEE Symp. VLSI Technol. Circuits (VLSI Technol. Circuits) , Jun. 2024, pp. 1-2.
- [38] T. O. Dickson, H. A. Ainspan, and M. Meghelli, 'A 1.8pJ / b 56Gb / s PAM-4 transmitter with fractionally spaced FFE in 14 nm CMOS,' in IEEE Int. Solid-State Circuits Conf. (ISSCC) Dig. Tech. Papers , Feb. 2017, pp. 118-119.
- [39] Y. Krupnik et al., '112-Gb / s PAM4 ADC-based SERDES receiver with resonant AFE for long-reach channels,' IEEE J. Solid-State Circuits , vol. 55, no. 4, pp. 1077-1085, Apr. 2020.
- [40] A. Khairi et al., 'A 1.41-pJ / b 224-Gb / s PAM4 6-bit ADC-based SerDes receiver with hybrid AFE capable of supporting long reach channels,' IEEE J. Solid-State Circuits , vol. 58, no. 1, pp. 8-18, Jan. 2023.
- [41] D. Pfa et al., 'A 224 Gb / s 3 pJ / bit 40 dB insertion loss transceiver in 3-nm FinFET CMOS,' IEEE J. Solid-State Circuits , vol. 60, no. 1, pp. 9-22, Jan. 2025.
- [42] A. Mostafa, 'A 2.2pJ / b 212.5Gb / s PAM-4 transceiver with &gt; 46dB reach in 5 nm FinFET,' in Proc. IEEE Int. Solid-State Circuits Conf. (ISSCC) Dig. Tech. Papers , Feb. 2025, pp. 198-200.
- [43] H. Park et al., 'A 112Gb / s DSP-based PAM-4 receiver with an LCresonator-based CTLE for &gt; 52dB loss compensation in 4nm FinFET,' in Proc. IEEE Int. Solid-State Circuits Conf. (ISSCC) Dig. Tech. Papers , Feb. 2025, pp. 90-92.
- [44] M.-A. LaCroix et al., '8.4 A 116Gb / s DSP-based wireline transceiver in 7 nm CMOS achieving 6pJ / b at 45dB loss in PAM-4 / duo-PAM-4 and 52dB in PAM-2,' in IEEE Int. Solid-State Circuits Conf. (ISSCC) Dig. Tech. Papers , Feb. 2021, pp. 132-133.
- [45] P. Mishra et al., '8.7 A 112Gb / s ADC-DSP-based PAM-4 transceiver for long-reach applications with &gt; 40dB channel loss in 7 nm FinFET,' in IEEE Int. Solid-State Circuits Conf. (ISSCC) Dig. Tech. Papers , Feb. 2021, pp. 138-139.
- [46] D. Xu et al., '8.5 A scalable adaptive ADC / DSP-based 1.25-to56Gbps / 112Gbps high-speed transceiver architecture using decisiondirected MMSE CDR in 16nm and 7nm,' in IEEE Int. Solid-State Circuits Conf. (ISSCC) Dig. Tech. Papers , Feb. 2021, pp. 134-135.
- [47] Z. Guo et al., 'A 112.5Gb / s ADC-DSP-based PAM-4 long-reach transceiver with &gt; 50dB channel loss in 5nm FinFET,' in IEEE Int. Solid-State Circuits Conf. (ISSCC) Dig. Tech. Papers , vol. 65, Feb. 2022, pp. 116-118.
- [48] A. Varzaghani et al., 'A 1-to-112Gb / s DSP-based wireline transceiver with a flexible clocking scheme in 5nm FinFET,' in Proc. IEEE Symp. VLSI Circuits , Jun. 2022, pp. 26-27.
- [49] B. Zhang et al., 'A 112-Gb / s serial link transceiver with three-tap FFE and 18-tap DFE receiver for up to 43-dB insertion loss channel in 7nm FinFET technology,' IEEE J. Solid-State Circuits , vol. 59, no. 1, pp. 8-18, Jan. 2024.
- [50] M. Cusmai et al., 'A 0.92-pJ / b PAM-4 and 0.61-pJ / b PAM-6 224-Gb / s DAC-based transmitter in 3-nm FinFET,' IEEE J. Solid-State Circuits , vol. 60, no. 1, pp. 23-34, Jan. 2025.
- [51] B. Zhang et al., 'A 200-Gb / s PAM-4 transmitter with 1.6-VPPD output swing and clock skew correction in 12-nm FinFET,' in Proc. IEEE Symp. VLSI Technol. Circuits (VLSI Technol. Circuits) , Jun. 2024, pp. 1-2.
- [52] B. Casper et al., 'A 20Gb / s forwarded clock transceiver in 90 nm CMOS,' in Proc. IEEE Int. Solid-State Circuits Conf. (ISSCC) Dig. Tech. Papers , Feb. 2005, pp. 268-269.
- [53] E. Groen et al., '10-to-112-Gb / s DSP-DAC-based transmitter in 7-nm FinFET with flex clocking architecture,' IEEE J. Solid-State Circuits , vol. 56, no. 1, pp. 30-42, Jan. 2021.
- [54] K. Yadav, P.-H. Hsieh, and A. Chan Carusone, 'Linearity analysis of source-degenerated di erential pairs for wireline applications,' IEEE Open J. Circuits Syst. , vol. 6, pp. 26-37, 2025.
- [55] S.-W.-M. Chen and R. W. Brodersen, 'A 6-bit 600-MS / s 5.3-mW asynchronous ADC in 0.13m CMOS,' IEEE J. Solid-State Circuits , vol. 41, no. 12, pp. 2669-2680, Dec. 2006.
- [56] J. Hudner et al., 'A 112GB / S PAM4 wireline receiver using a 64-way time-interleaved SAR ADC in 16NM FinFET,' in Proc. IEEE Symp. VLSI Circuits , Jun. 2018, pp. 47-48.
- [57] C. Loi et al., 'A 400Gb / s transceiver for PAM-4 optical direct-detect application in 16nm FinFET,' in IEEE Int. Solid-State Circuits Conf. (ISSCC) Dig. Tech. Papers , Feb. 2019, pp. 120-121.
- [58] M. Dessouky and A. Kaiser, 'Input switch configuration suitable for rail-to-rail operation of switched opamp circuits,' Electron. Lett. , vol. 35, no. 1, pp. 8-10, Jan. 1999.
- [59] Y. Zhu et al., 'A 38-GS / s 7-bit pipelined-SAR ADC with Speedenhanced bootstrapped switch and output level shifting technique in 22-nm FinFET,' IEEE J. Solid-State Circuits , vol. 58, no. 8, pp. 2300-2313, Aug. 2023.
- [60] S. Cai, A. Shafik, S. Kiran, E. Z. Tabasy, S. Hoyos, and S. Palermo, 'Statistical modeling of metastability in ADC-based serial I / O receivers,' in Proc. IEEE 23rd Conf. Electr. Perform. Electron. Packag. Syst. , Oct. 2014, pp. 39-42.
- [61] T. Jiang, W. Liu, F. Y. Zhong, C. Zhong, K. Hu, and P. Y. Chiang, 'A single-channel, 1.25-GS / s, 6-bit, 6.08-mW asynchronous successiveapproximation ADC with improved feedback delay in 40-nm CMOS,' IEEE J. Solid-State Circuits , vol. 47, no. 10, pp. 2444-2453, Oct. 2012.
- [62] T. Ali et al., 'A 460 mW 112Gb / s DSP-based transceiver with 38dB loss compensation for next-generation data centers in 7 nm FinFET technology,' in IEEE Int. Solid-State Circuits Conf. (ISSCC) Dig. Tech. Papers , Feb. 2022, pp. 144-146.
- [63] E. Martens, N. Markulic, J. L. Benites, and J. Craninckx, 'Calibration techniques for optimizing performance of high-speed ADCs,' in Proc. IEEE Custom Integr. Circuits Conf. (CICC) , Apr. 2023, pp. 1-8.
- [64] H. Wei, P. Zhang, B. D. Sahoo, and B. Razavi, 'An 8 bit 4 GS / s 120 mW CMOS ADC,' IEEE J. Solid-State Circuits , vol. 49, no. 8, pp. 1751-1761, Aug. 2014.
- [65] K. Zheng, 'System-driven circuit design for ADC-based wireline data links,' Stanford Univ., Stanford, CA, USA, Tech. Rep., 2018.
- [66] T. Toifl et al., 'A 3.5pJ / bit 8-tap-feed-forward 8-tap-decision feedback digital equalizer for 16Gb / s I / Os,' in Proc. 40th Eur. Solid State Circuits Conf. (ESSCIRC) , France, Sep. 2014, pp. 455-458.
- [67] S. Kiran, S. Cai, Y. Zhu, S. Hoyos, and Samuel Palermo, 'Digital equalization with ADC-based receivers,' IEEE Microwave Magazine , vol. 20, no. 5, pp. 62-79, May 2019.
- [68] R. M. Hewlitt and E. S. Swartzlantler, 'Canonical signed digit representation for FIR digital filters,' in Proc. IEEE Workshop Signal Process. Syst. (SiPS) , Oct. 2002, pp. 416-426.
- [69] S. Kasturia and J. H. Winters, 'Techniques for high-speed implementation of nonlinear cancellation,' IEEE J. Sel. Areas Commun. , vol. 9, no. 5, pp. 711-717, Jun. 1991.
- [70] K. K. Parhi, 'Design of multigigabit multiplexer-loop-based decision feedback equalizers,' IEEE Trans. Very Large Scale Integr. (VLSI) Syst. , vol. 13, no. 4, pp. 489-493, Apr. 2005.
- [71] J. Im et al., 'A 112-Gb / s PAM-4 long-reach wireline transceiver using a 36-way time-interleaved SAR ADC and inverter-based RX analog front-end in 7-nm FinFET,' IEEE J. Solid-State Circuits , vol. 56, no. 1, pp. 7-18, Jan. 2021.
- [72] J. Bailey et al., 'A 112-Gb / s PAM-4 low-power nine-tap sliding-block DFE in a 7-nm FinFET wireline receiver,' IEEE J. Solid-State Circuits , vol. 57, no. 1, pp. 32-43, Jan. 2022.
- [73] G. D. Forney, 'The Viterbi algorithm,' Proc. IEEE , vol. 61, no. 3, pp. 268-278, Mar. 1973.
- [74] K. Mueller and M. M¨ uller, 'Timing recovery in digital synchronous data receivers,' IEEE Trans. Commun. , vol. C-24, no. 5, pp. 516-531, May 1976.
- [75] J. L. Sonntag and J. Stonick, 'A digital clock and data recovery architecture for multi-gigabit / s binary links,' IEEE J. Solid-State Circuits , vol. 41, no. 8, pp. 1867-1875, Aug. 2006.
- [76] K. Yadav, P.-H. Hsieh, and A. C. Carusone, 'Loop dynamics analysis of PAM-4 Mueller-M¨ uller clock and data recovery system,' IEEE Open J. Circuits Syst. , vol. 3, pp. 216-227, 2022.
- [77] A. Sanders, M. Resso, and J. D'Ambrosia, 'Channel compliance testing utilizing novel statistical eye methodology,' in Proc. DesignCon , Feb. 2004.
- [78] S. Kiran et al., 'Modeling of ADC-based serial link receivers with embedded and digital equalization,' IEEE Trans. Compon., Packag., Manuf. Technol. , vol. 9, no. 3, pp. 536-548, Mar. 2019.
- [79] R. Barrie, M. Yang, H. Shakiba, and A. C. Carusone, 'An FPGAaccelerated platform for post-FEC BER analysis of 200 Gb / s wireline systems,' IEEE Trans. Circuits Syst. II, Exp. Briefs , vol. 72, no. 8, pp. 978-982, Aug. 2025.
- [80] C. A. Belfiore and J. H. Park, 'Decision feedback equalization,' Proc. IEEE , vol. 67, no. 8, pp. 1143-1156, Aug. 1979.
- [81] H. Shakiba, Error Propagation Analysis of MLSE, Standard IEEE Standard 802.3dj, Apr. 2023.

- [82] K. Wu, G. Liga, J. Riani, and A. Alvarado, 'Low-complexity softdecision detection for combating DFE burst errors in IM / DD links,' J. Lightw. Technol. , vol. 42, no. 5, pp. 1395-1408, Mar. 1, 2024.
- [83] IEEE Standard for Ethernet Amendment 4: Physical Layer Specifications and Management Parameters for 100 Gb / s, 200 Gb / s, and 400 Gb / s Electrical Interfaces Based on 100 Gb / s Signaling, Standard 802.3ck-2022, Dec. 2022.
- [84] Concatenated FEC Baseline Proposal for 200Gb / s Per Lane IM-DD Optical PMD, Standard 802.3dj, Jan. 2023.
- [85] J. Verbist et al., 'Real-time 100 Gb / s NRZ and EDB transmission with a GeSi electroabsorption modulator for short-reach optical interconnects,' J. Lightw. Technol. , vol. 36, no. 1, pp. 90-96, Jan. 2018.
- [86] H. Ramon et al., '70 Gb / s low-power DC-coupled NRZ differential electro-absorption modulator driver in 55 nm SiGe BiCMOS,' J. Lightw. Technol. , vol. 37, no. 5, pp. 1504-1514, Mar. 2019.
- [87] G. T. Reed and C. E. Jason Png, 'Silicon optical modulators,' Mater. Today , vol. 8, no. 1, pp. 40-50, Jan. 2005.
- [88] X. Wu et al., 'A 20Gb / s NRZ / PAM-4 1V transmitter in 40 nm CMOS driving a Si-photonic modulator in 0.13 m CMOS,' in Proc. IEEE Int. Solid-State Circuits Conf. Dig. Tech. Papers , Feb. 2013, pp. 128-129.
- [89] C. Wang et al., 'Integrated lithium niobate electro-optic modulators operating at CMOS-compatible voltages,' Nature , vol. 562, no. 7725, pp. 101-104, Oct. 2018.
- [90] S. Shekhar, 'Silicon photonics: A brief tutorial,' IEEE Solid StateCircuits Mag. , vol. 13, no. 3, pp. 22-32, Summer. 2021.
- [91] A. H. Ahmed, A. Sharkia, B. Casper, S. Mirabbasi, and S. Shekhar, 'Silicon-photonics microring links for datacenters-Challenges and opportunities,' IEEE J. Sel. Topics Quantum Electron. , vol. 22, no. 6, pp. 194-203, Nov. 2016.
- [92] B. Analui, D. Guckenberger, D. Kucharski, and A. Narasimha, 'A fully integrated 20-Gb / s optoelectronic transceiver implemented in a standard 0.13m CMOS SOI technology,' IEEE J. Solid-State Circuits , vol. 41, no. 12, pp. 2945-2955, Dec. 2006.
- [93] T. Chen, H.-M. Su, T.-H. Lee, and S. S. H. Hsu, 'A 64-Gb / s 4.2VPP modulator driver using stacked-FET distributed amplifier topology in 65-nm CMOS,' in Proc. IEEE Int. Microw. Symp. , Jan. 2019, pp. 730-733.
- [94] A. H. Ahmed, A. E. Moznine, D. Lim, Y. Ma, A. Rylyakov, and S. Shekhar, 'A dual-polarization silicon-photonic coherent transmitter supporting 552 Gb / s / wavelength,' IEEE J. Solid-State Circuits , vol. 55, no. 9, pp. 2597-2608, Sep. 2020.
- [95] S. Palermo and M. Horowitz, 'High-speed transmitters in 90 nm CMOS for high-density optical interconnects,' in Proc. 32nd Eur. Solid-State Circuits Conf. , Sep. 2006, pp. 508-511.
- [96] H. Li et al., 'A 3-D-integrated silicon photonic microring-based 112-Gb / s PAM-4 transmitter with nonlinear equalization and thermal control,' IEEE J. Solid-State Circuits , vol. 56, no. 1, pp. 19-29, Jan. 2021.
- [97] A. S. Ramani, S. Nayak, and S. Shekhar, 'A di erential push-pull voltage mode VCSEL driver in 65-nm CMOS,' IEEE Trans. Circuits Syst. I, Reg. Papers , vol. 66, no. 11, pp. 4147-4157, Nov. 2019.
- [98] V. Kozlov and A. Chan Carusone, 'Capacitively-coupled CMOS VCSEL driver circuits,' IEEE J. Solid-State Circuits , vol. 51, no. 9, pp. 2077-2090, Sep. 2016.
- [99] M. Mansuri et al., 'A scalable 32-56 Gb / s 0.56-1.28 pJ / b voltage-mode VCSEL-based optical transmitter in 28-nm CMOS,' IEEE J. SolidState Circuits , vol. 57, no. 3, pp. 757-766, Mar. 2022.
- [100] M. Raj, M. Monge, and A. Emami, 'A modelling and nonlinear equalization technique for a 20 Gb / s 0.77 pJ / b VCSEL transmitter in 32 nm SOI CMOS,' IEEE J. Solid-State Circuits , vol. 51, no. 8, pp. 1734-1743, Aug. 2016.
- [101] S. Mondal et al., 'A 4-Ch × 64 Gb / s / Ch NRZ VCSEL-based copackaged fiber-terminated optical TX and 80-Gb / s optical driver,' IEEE J. Solid-State Circuits , early access, May 1, 2025, doi: 10.1109 / JSSC.2025.3563073.
- [102] C. Sun et al., 'A 45 nm CMOS-SOI monolithic photonics platform with bit-statistics-based resonant microring thermal tuning,' IEEE J. SolidState Circuits , vol. 51, no. 4, pp. 893-907, Apr. 2016.
- [103] R. O. Ananev, 'Roadmapping the next generation of silicon photonics,' Nature Commun. , vol. 15, p. 751, Jan. 2024.
- [104] J. Lambrecht et al., '90-Gb / s NRZ optical receiver in silicon using a fully di erential transimpedance amplifier,' J. Lightw. Technol. , vol. 37, no. 9, pp. 1964-1973, May 2019.
- [105] K. Lakshmikumar et al., 'A 7 pA / p Hz asymmetric di erential TIA for 100Gb / s PAM-4 links with -14dBm optical sensitivity in 16nm CMOS,' in IEEE Int. Solid-State Circuits Conf. (ISSCC) Dig. Tech. Papers , San Francisco, CA, USA, Feb. 2023, pp. 206-208.
- [106] D. Patel, A. Sharif-Bakhtiar, and T. C. Carusone, 'A 112-Gb / s-8.2dBm sensitivity 4-PAM linear TIA in 16-nm CMOS with co-packaged photodiodes,' IEEE J. Solid-State Circuits , vol. 58, no. 3, pp. 771-784, Mar. 2023.
- [107] S. Daneshgar, H. Li, T. Kim, and G. Balamurugan, 'A 128 Gb / s, 11.2 mW single-ended PAM4 linear TIA with 2.7 Arms input noise in 22 nm FinFET CMOS,' IEEE J. Solid-State Circuits , vol. 57, no. 5, pp. 1397-1408, May 2022.
- [108] E. Sackinger, Analysis and Design of Transimpedance Amplifiers for Optical Receivers . Hoboken, NJ, USA: Wiley, 2018.
- [109] S. M. Park and H.-J. Yoo, '1.25-Gb / s regulated cascode CMOS transimpedance amplifier for gigabit Ethernet applications,' IEEE J. Solid-State Circuits , vol. 39, no. 1, pp. 112-121, Jan. 2004.
- [110] A. Sharif-Bakhtiar, M. G. Lee, and A. C. Carusone, 'A 40-gbps 0.5pJ / bit VCSEL driver in 28nm CMOS with complex zero equalizer,' in Proc. IEEE Custom Integr. Circuits Conf. (CICC) , Austin, TX, USA, Apr. 2017, pp. 1-4.
- [111] K. R. Lakshmikumar et al., 'A process and temperature insensitive CMOS linear TIA for 100 Gb / s / PAM-4 optical links,' IEEE J. SolidState Circuits , vol. 54, no. 11, pp. 3180-3190, Nov. 2019.
- [112] M. G. Ahmed et al., 'A 12-Gb / s -16.8-dBm OMA sensitivity 23-mW optical receiver in 65-nm CMOS,' IEEE J. Solid-State Circuits , vol. 53, no. 2, pp. 445-457, Feb. 2018.
- [113] D. Li et al., 'A low-noise design technique for high-speed CMOS optical receivers,' IEEE J. Solid-State Circuits , vol. 49, no. 6, pp. 1437-1447, Jun. 2014.
- [114] A. Sharif-Bakhtiar and A. Chan Carusone, 'A 20 Gb / s CMOS optical receiver with limited-bandwidth front end and local feedback IIRDFE,' IEEE J. Solid-State Circuits , vol. 51, no. 11, pp. 2679-2689, Nov. 2016.
- [115] S. Krishnamurthy et al., 'A 0.9pJ / b 108Gb / s PAM-4 VCSEL-based direct-drive optical engine,' in IEEE Int. Solid-State Circuits Conf. (ISSCC) Dig. Tech. Papers , Feb. 2025, pp. 592-593.
- [116] S. Shekhar, J. S. Walling, and D. J. Allstot, 'Bandwidth extension techniques for CMOS amplifiers,' IEEE J. Solid-State Circuits , vol. 41, no. 11, pp. 2424-2439, Nov. 2006.
- [117] D. Li et al., 'Low-noise broadband CMOS TIA based on multistage stagger-tuned amplifier for high-speed high-sensitivity optical communication,' IEEE Trans. Circuits Syst. I, Reg. Papers , vol. 66, no. 10, pp. 3676-3689, Oct. 2019.
- [118] B. Zhang et al., 'A 112Gb / s serial link transceiver with 3-tap FFE and 18-tap DFE receiver for up to 43dB insertion loss channel in 7nm FinFET technology,' in IEEE Int. Solid-State Circuits Conf. (ISSCC) Dig. Tech. Papers , San Francisco, CA, USA, Feb. 2023, pp. 5-7.
- [119] C.-J. Li, C.-H. Hsiao, F.-K. Wang, T.-S. Horng, and K.-C. Peng, 'A rigorous analysis of a phase-locked oscillator under injection,' IEEE Trans. Microw. Theory Techn. , vol. 58, no. 5, pp. 1391-1400, May 2010.
- [120] L. Fanori, T. Mattsson, and P. Andreani, 'A 2.4-to-5.3GHz dual-core CMOS VCO with concentric 8-shaped coils,' in IEEE Int. Solid-State Circuits Conf. (ISSCC) Dig. Tech. Papers , San Francisco, CA, USA, Feb. 2014, pp. 370-371.
- [121] B. Hong and A. Hajimiri, 'A general theory of injection locking and pulling in electrical oscillators-Part I: Time-synchronous modeling and injection waveform design,' IEEE J. Solid-State Circuits , vol. 54, no. 8, pp. 2109-2121, Aug. 2019.
- [122] A. Mirzaei and H. Darabi, 'Mutual pulling between two oscillators,' IEEE J. Solid-State Circuits , vol. 49, no. 2, pp. 360-372, Feb. 2014.
- [123] D. Shin, H. S. Kim, C.-C. Liu, P. Wali, S. K. Murthy, and Y. Fan, 'A fractional-N digital LC-PLL using coupled frequency doubler with frequency-tracking loop for wireline applications,' IEEE J. Solid-State Circuits , vol. 57, no. 6, pp. 1736-1748, Jun. 2022.
- [124] D. Murphy and H. Darabi, 'A 27-GHz quad-core CMOS oscillator with no mode ambiguity,' IEEE J. Solid-State Circuits , vol. 53, no. 11, pp. 3208-3216, Nov. 2018.
- [125] W. Wu et al., 'A 14nm analog sampling fractional-N PLL with a digital-to-time converter range-reduction technique achieving 80fs integrated jitter and 93fs at near-integer channels,' in IEEE Int. SolidState Circuits Conf. (ISSCC) Dig. Tech. Papers , San Francisco, CA, USA, Feb. 2021, pp. 444-446.

- [126] H. Jia, W. Deng, P. Guan, Z. Wang, and B. Chi, 'A 60 GHz 186.5dBc / Hz FoM quad-core fundamental VCO using circular triplecoupled transformer with no mode ambiguity in 65nm CMOS,' in IEEE Int. Solid-State Circuits Conf. (ISSCC) Dig. Tech. Papers , San Francisco, CA, USA, Feb. 2021, pp. 1-3.
- [127] M. A. Khalil et al., 'A 69.3fs ring-based sampling-PLL achieving 6.8 GHz-14G Hz and -54.4dBc spurs under 50 mV supply noise,' in IEEE Int. Solid-State Circuits Conf. (ISSCC) Dig. Tech. Papers , San Francisco, CA, USA, Feb. 2024, pp. 138-139.
- [128] Y. Tian, 'An 8-to-28GHz 8-phase clock generator using dual-feedback ring oscillator in 28 nm CMOS,' in IEEE Int. Solid-State Circuits Conf. (ISSCC) Dig. Tech. Papers , San Francisco, CA, USA, Feb. 2025, pp. 154-155.
- [129] T.-H. Tsai, R.-B. Sheen, S.-Y. Hsu, Y.-T. Chang, C.-H. Chang, and R. B. Staszewski, 'A cascaded PLL (LC-PLL + RO-PLL) with a programmable double realignment achieving 204fs integrated jitter (100 kHz to 100MHz) and -72dB reference spur,' in IEEE Int. SolidState Circuits Conf. (ISSCC) Dig. Tech. Papers , Feb. 2022, pp. 1-3.
- [130] W. Wu et al., 'A 28-nm 75-fsrms analog fractionalN sampling PLL with a highly linear DTC incorporating background DTC gain calibration and reference clock duty cycle correction,' IEEE J. SolidState Circuits , vol. 54, no. 5, pp. 1254-1265, May 2019.
- [131] Y. Jo, J. Kim, Y. Shin, C. Hwang, H. Park, and J. Choi, 'A 135fsrmsjitter 0.6-to-7.7GHz LO generator using a single LC-VCO-based subsampling PLL and a ring-oscillator-based sub-integer-N frequency multiplier,' in IEEE Int. Solid-State Circuits Conf. (ISSCC) Dig. Tech. Papers , San Francisco, CA, USA, Feb. 2023, pp. 76-77.
- [132] Y. Huang, '0.027 mm 2 5.6-7.8 GHz ring-oscillator-based ping-pong sampling PLL scoring 220.3fs rms jitter and -74.2dBc reference spur,' in IEEE Int. Solid-State Circuits Conf. (ISSCC) Dig. Tech. Papers , San Francisco, CA, USA, Feb. 2024, pp. 130-131.
- [133] C. Hwang, H. Park, T. Seong, and J. Choi, 'A 188fs rms -jitter and -243d8-FoMjitter 5.2 GHz-ring-DCO-based fractional-N digital PLL with a 1 / 8 DTC-range-reduction technique using a quadruple-timingmargin phase selector,' in IEEE Int. Solid-State Circuits Conf. (ISSCC) Dig. Tech. Papers , San Francisco, CA, USA, Feb. 2022, pp. 378-380.
- [134] B. Casper and F. O'Mahony, 'Clocking analysis, implementation and measurement techniques for high-speed data links-A tutorial,' IEEE Trans. Circuits Syst. I, Reg. Papers , vol. 56, no. 1, pp. 17-39, Jan. 2009.
- [135] X. Mo, J. Wu, N. Wary, and T. C. Carusone, 'Design methodologies for low-jitter CMOS clock distribution,' IEEE Open J. Solid-State Circuits Soc. , vol. 1, pp. 94-103, 2021.
- [136] F. O'Mahony, M. Mansuri, B. Casper, J. E. Jaussi, and R. Mooney, 'A low-jitter PLL and repeaterless clock distribution network for a 20Gb / s link,' in Proc. Symp. VLSI Circuits, Dig. Tech. Papers. , Honolulu, HI, USA, 2006, p. 29.
- [137] M. Mansuri et al., 'A scalable 0.128-1 Tb / s, 0.8-2.6 pJ / bit, 64-lane parallel I / O in 32-nm CMOS,' IEEE J. Solid-State Circuits , vol. 48, no. 12, pp. 3229-3242, Dec. 2013.
- [138] S. Kundu and J. Paramesh, 'A compact, supply-voltage scalable 45-66 GHz baseband-combining CMOS phased-array receiver,' IEEE J. Solid-State Circuits , vol. 50, no. 2, pp. 527-542, Feb. 2015.
- [139] J. Q. Wang, 'A 2.69pJ / b 212Gb / s DSP-based PAM-4 transceiver for optical direct-detect application in 5nm FinFET,' in IEEE Int. SolidState Circuits Conf. (ISSCC) Dig. Tech. Papers , San Francisco, CA, USA, Feb. 2024, pp. 124-125.
- [140] G. Li, W. Lee, D. Cui, B. Zhang, A. Momtaz, and J. Cao, 'Standing wave based clock distribution technique with application to a 10 × 11 Gbps transceiver in 28 nm CMOS,' in Proc. IEEE Asian Solid-State Circuits Conf. (A-SSCC) , Xiamen, China, Nov. 2015, pp. 1-4.
- [141] M. Raj, S. Saeedi, and A. Emami, 'A wideband injection locked quadrature clock generation and distribution technique for an energyproportional 16-32 Gb / s optical receiver in 28 nm FDSOI CMOS,' IEEE J. Solid-State Circuits , vol. 51, no. 10, pp. 2446-2462, Oct. 2016.
- [142] B. Ye et al., 'A 1.11pJ / b 224Gb / s XSR receiver with slice-based CTLE and PI-based clock generator in 12nm CMOS,' in IEEE Int. Solid-State Circuits Conf. (ISSCC) Dig. Tech. Papers , San Francisco, CA, USA, Feb. 2025, pp. 140-141.
- [143] F. Behbahani, Y. Kishigami, J. Leete, and A. A. Abidi, 'CMOS mixers and polyphase filters for large image rejection,' IEEE J. Solid-State Circuits , vol. 36, no. 6, pp. 873-887, Jun. 2001.
- [144] W.-C. Chen et al., 'A 4-to-18GHz active poly phase filter quadrature clock generator with phase error correction in 5nm CMOS,' in Proc. IEEE Symp. VLSI Circuits , Honolulu, HI, USA, Jun. 2020, pp. 1-2.
- [145] R. Singh, S. Mondal, and J. Paramesh, 'A compact digitally-assisted merged LNA vector modulator using coupled resonators for integrated beamforming transceivers,' IEEE Trans. Microw. Theory Techn. , vol. 67, no. 7, pp. 2555-2568, Jul. 2019.
- [146] A. Mirzaei, M. E. Heidari, R. Bagheri, S. Chehrazi, and A. A. Abidi, 'The quadrature LC oscillator: A complete portrait based on injection locking,' IEEE J. Solid-State Circuits , vol. 42, no. 9, pp. 1916-1932, Sep. 2007.
- [147] X. Chen, Y. Hu, T. Siriburanon, J. Du, R. B. Staszewski, and A. Zhu, 'A 30-GHz class-F quadrature DCO using phase shifts between drain-gate-source for low flicker phase noise and I / Q exactness,' IEEE J. Solid-State Circuits , vol. 58, no. 7, pp. 1945-1958, Jul. 2023.
- [148] A. Agrawal et al., 'A 128-Gb / s D-Band receiver with integrated PLL and ADC achieving 1.95-pJ / b e ciency in 22-nm FinFET,' IEEE J. Solid-State Circuits , vol. 58, no. 12, pp. 3364-3379, Dec. 2023.
- [149] S. Chen et al., 'A 4-to-16GHz inverter-based injection-locked quadrature clock generator with phase interpolators for multi-standard I / Os in 7nm FinFET,' in IEEE Int. Solid-State Circuits Conf. (ISSCC) Dig. Tech. Papers , San Francisco, CA, USA, Feb. 2018, pp. 390-391.
- [150] Z. Wang, Y. Zhang, Y. Onizuka, and P. R. Kinget, 'Multi-phase clock generation for phase interpolation with a multi-phase, injection-locked ring oscillator and a quadrature DLL,' IEEE J. Solid-State Circuits , vol. 57, no. 6, pp. 1776-1787, Jun. 2022.
- [151] A. Agrawal, J. Bulzacchelli, T. Dickson, Y. Liu, J. Tierno, and D. Friedman, 'A 19Gb / s serial link receiver with both 4-tap FFE and 5-tap DFE functions in 45nm SOI CMOS,' in IEEE Int. Solid-State Circuits Conf. (ISSCC) Dig. Tech. Papers , San Francisco, CA, USA, Feb. 2012, pp. 134-136.
- [152] J. Z. Ru, C. Palattella, P. Geraedts, E. Klumperink, and B. Nauta, 'A high-linearity digital-to-time converter technique: Constant-slope charging,' IEEE J. Solid-State Circuits , vol. 50, no. 6, pp. 1412-1423, Jun. 2015.
- [153] S. Sievert et al., 'A 2 GHz 244 fs-resolution 1.2 ps-peak-INL edge interpolator-based digital-to-time converter in 28 nm CMOS,' IEEE J. Solid-State Circuits , vol. 51, no. 12, pp. 2992-3004, Dec. 2016.
- [154] A. K. Mishra, Y. Li, P. Agarwal, and S. Shekhar, 'Improving linearity in CMOS phase interpolators,' IEEE J. Solid-State Circuits , vol. 58, no. 6, pp. 1623-1635, Jun. 2023.
- [155] Z. Wang and P. R. Kinget, 'A very high linearity twin phase interpolator with a low-noise and wideband delta quadrature DLL for high-speed data link clocking,' IEEE J. Solid-State Circuits , vol. 58, no. 4, pp. 1172-1184, Apr. 2023.
- [156] T. Musah et al., 'A 4-32 Gb / s bidirectional link with 3-tap FFE / 6-tap DFE and collaborative CDR in 22 nm CMOS,' IEEE J. Solid-State Circuits , vol. 49, no. 12, pp. 3079-3090, Dec. 2014.

![[ieee-jssc-wireline-tutorial-2026-049.png]]

Tony Chan Carusone (Fellow, IEEE) received the Ph.D. degree from the University of Toronto, Toronto, ON, Canada, in 2002.

He has been a Professor with the Department of Electrical and Computer Engineering, University of Toronto. He has also been a Consultant to industry in the areas of integrated circuit design and digital communication, since 1997. He is currently the Chief Technology O cer of Alphawave Semi, Toronto. He has co-authored the popular textbooks Analog Integrated Circuit Design (along with D. Johns and

- K . Martin) and Microelectronic Circuits , 8th edition (along with A. Sedra, K. C. Smith, and V. Gaudet).

Prof. Chan Carusone co-authored the Best Student Papers at the 2007, 2008, 2011, and 2022 Custom Integrated Circuits Conferences, the Best Invited Paper at the 2010 Custom Integrated Circuits Conference, the Best Paper at the 2005 Compound Semiconductor Integrated Circuits Symposium, the Best Young Scientist Paper at the 2014 European Solid-State Circuits Conference, and Best Papers at DesignCon 2021, 2023, and 2025. He has been a Distinguished Lecturer of IEEE Solid-State Circuits Society from 2015 to 2017 and in 2025, and has served on the Technical Program Committee of several IEEE conferences, including the International SolidState Circuits Conference from 2016 to 2021. He was the Editor-in-Chief for IEEE TRANSACTIONS ON CIRCUITS AND SYSTEMS-II: EXPRESS BRIEFS in 2009 and IEEE SOLID-STATE CIRCUITS LETTERS from 2021 to 2023, and an Associate Editor of IEEE JOURNAL OF SOLID-STATE CIRCUITS from 2010 to 2017.

![[ieee-jssc-wireline-tutorial-2026-050.png]]

Timothy O. Dickson (Senior Member, IEEE) received the dual B.Sc. degree (Hons.) in electrical and computer engineering and the M.Eng. degree in electrical engineering from the University of Florida, Gainesville, FL, USA, in 1999 and 2002, respectively, and the Ph.D. degree from the University of Toronto, Toronto, ON, Canada, in 2006.

In 2006, he joined the IBM Thomas J. Watson Research Center, Yorktown Heights, NY, USA, where he is currently a Principal Research Scientist. He is also an Adjunct Professor at Columbia Univer- sity, New York, NY, USA, where he has been teaching graduate level courses in analog and mixed-signal integrated circuit design, since 2007. He has authored or co-authored more than 50 papers in IEEE journals or conferences. He holds 21 issued U.S. patents. His research focuses on the design of highspeed and low-power serial transceivers for electrical and optical links.

Dr. Dickson was a member of the Technical Program Committee (TPC) of IEEE Compound Semiconductor Integrated Circuit Symposium from 2007 to 2009. He was a recipient or co-recipient of several best paper awards, including the Best Paper Award for the 2009 IEEE Journal of Solid-State Circuits, the Beatrice Winner Award for Editorial Excellence at the 2009 IEEE International Solid-State Circuits Conference (ISSCC), the Best Paper Award from the 2015 IEEE Custom Integrated Circuits Conference (CICC), the Best Invited Paper Award at the 2024 IEEE CICC, and the Best Student Paper Award at the 2004 Symposium on VLSI Circuits. From 2017 to 2023, he served on the CICC TPC where he chaired the Wireline Subcommittee. From 2019 to 2020 and 2024 to 2025, he served as a Distinguished Lecturer for IEEE Solid-State Circuits Society. He was a Guest Editor of the October 2010 Issue of IEEE JOURNAL OF SOLID-STATE CIRCUITS. From 2018 to 2023, he was an Associate Editor of IEEE SOLID-STATE CIRCUITS LETTERS. Since 2024, he has been an Associate Editor of IEEE OPEN JOURNAL OF THE SOLID-STATE CIRCUITS.

![[ieee-jssc-wireline-tutorial-2026-051.png]]

Samuel Palermo (Senior Member, IEEE) received the B.S. and M.S. degrees in electrical engineering from Texas A&M University, College Station, TX, USA, in 1997 and 1999, respectively, and the Ph.D. degree in electrical engineering from Stanford University, Stanford, CA, USA, in 2007.

From 1999 to 2000, he was with Texas Instruments, Dallas, TX, USA, where he worked on the design of mixed-signal integrated circuits for highspeed serial data communication. From 2006 to 2008, he was with Intel Corporation, Hillsboro, OR,

USA, where he worked on high-speed optical and electrical I / O architectures. In 2009, he joined the Department of Electrical and Computer Engineering, Texas A&M University, where he is currently the J. W. Runyon Jr. Professor. His research interests include high-speed electrical and optical interconnect architectures, RF photonics, radiation-hardened electronics, and AI computing hardware.

Dr. Palermo is a member of Eta Kappa Nu. He was a recipient of the 2013 NSF-CAREER Award. He was a co-author of the Jack Raper Award for Outstanding Technology-Directions Paper at the 2009 International Solid-State Circuits Conference, the Best Student Paper at the 2014 Midwest Symposium on Circuits and Systems, an Outstanding Student Paper Award from the 2018 Custom Integrated Circuits Conference, and the Best Student Paper Award at the 2024 Opto-Electronics and Communications Conference. He received the Texas A&M University Department of Electrical and Computer Engineering Outstanding Professor Award in 2014 and the Engineering Faculty Fellow Award in 2015. He has also previously served as a Distinguished Lecturer for the IEEE Solid-State Circuits Society and the IEEE CASS Board of Governors. He is currently an Associate Editor of IEEE JOURNAL OF SOLID-STATE CIRCUITS and has previously served in this role of IEEE SOLID-STATE CIRCUITS LETTERS and IEEE TRANSACTIONS ON CIRCUITS AND SYSTEM-II: EXPRESS BRIEFS.

![[ieee-jssc-wireline-tutorial-2026-052.png]]

Sudip Shekhar (Senior Member, IEEE) received the B.Tech. degree from Indian Institute of Technology Kharagpur, Kharagpur, India, in 2003, and the Ph.D. degree from the University of Washington, Seattle, WA, USA, in 2008.

From 2008 to 2013, he was with the Circuits Research Laboratory, Intel Corporation, Hillsboro, OR, USA, where he worked on high-speed I / O architectures. He is now a Professor of electrical and computer engineering with The University of British Columbia, Vancouver, BC, Canada. His cur- rent research interests include electrical and optical circuits for high-speed communication, frequency synthesis, and wireless transceivers.

Dr. Shekhar was a recipient of the 2025 UBC Killam Award for Excellence in Mentoring, the 2022 Schmidt Science Polymath Award, the 2022 UBC Killam Teaching Prize, and the 2019 Young Alumni Achiever Award by IIT Kharagpur. He was a co-recipient of the Best Paper Awards from IEEE Transactions on Circuit and Systems, Custom IC Conference (CICC) and the Radio frequency IC Symposium. He currently serves as the Tutorials Chair for the IEEE International Solid-State Circuits Conference (ISSCC), and a member of the Technical Program Committee (TPC) for OFC. Previously, he served on the TPC of ISSCC, IEEE Custom Integrated Circuits Conference (CICC), and Optical Interconnects (OI) Conference, as a Guest Editor for IEEE JOURNAL OF SOLID-STATE CIRCUITS (JSSC), and as a Distinguished Lecturer for IEEE Solid-State Circuits Society from 2021 to 2022.

![[ieee-jssc-wireline-tutorial-2026-053.png]]

Mozhgan Mansuri (Member, IEEE) received the B.S. and M.S. degrees in electronics engineering from the Sharif University of Technology, Tehran, Iran, in 1995 and 1997, respectively, and the Ph.D. degree in electrical engineering from the University of California, Los Angeles, CA, USA, in 2003.

She joined Intel, in 2003, where she is currently a Senior Principal Engineer. Her research interests include low-power low-jitter clock synthesis / recovery circuits (PLLs and DLLs), variation- tolerant circuits, and high-speed, low-power optical / electrical as well as memory I / O links.

Dr. Mansuri was a recipient of the Transactions on Circuits and Systems Darlington Best Paper Award in 2010 and the Journal of Solid-State Circuits Best Paper Award in 2015. She served on the technical program committee (TPC) of several IEEE conferences including the International Solid-State Circuits Conference (ISSCC) from 2021 to 2025, the Custom Integrated Circuits Conference (CICC) from 2019 to 2023, and the Radio Frequency Integrated Circuits Symposium (RFIC) from 2014 to 2018.