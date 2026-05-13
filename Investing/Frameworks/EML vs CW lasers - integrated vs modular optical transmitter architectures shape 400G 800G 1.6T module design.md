---
created: 2026-05-13
published: 2026-03-16
description: EMLs integrate laser+modulator on InP for compact 100G/400G modules; CW lasers feed silicon-photonics modulators in 800G/1.6T/CPO designs — the architecture split drives which optics names benefit from each speed transition.
source: https://cruxcapitalgroup.substack.com/p/eml-vs-cw-lasers
type: framework
authors: ["Crux Capital Group (@cruxcapitalgroup)"]
---

# EML vs CW Lasers — integrated vs modular optical transmitter architectures shape 400G 800G 1.6T module design

## Key Takeaways

- **Two transmitter architectures.** An EML (electro-absorption modulated laser) integrates the laser and modulator on a single InP chip. A CW (continuous-wave) laser produces a steady light beam and pairs with a *separate* modulator — typically on a silicon-photonics die.
- **Speed transition drives architecture mix.** 100G/400G was largely EML-based. 800G is where the industry began diverging. **At 1.6T the optical-engine architecture conversation becomes much more visible** — CW + silicon photonics gains share because each part can be optimized independently.
- **Silicon photonics is the unlock for CW.** Silicon manipulates light well but cannot generate it efficiently — every silicon-photonic system needs an external CW laser. As silicon photonics adoption grows, external CW laser TAM grows with it.
- **Co-packaged optics (CPO) amplifies CW demand.** CPO moves optics next to switch ASICs, which generates heat that laser diodes can't tolerate. CPO designs therefore separate the laser into a remote, thermally-managed *external laser source (ELS)* module — OIF is standardizing these.
- **Module lane counts × WDM-vs-parallel-fiber influences which architecture fits.** 400G = 4 lanes; 800G = 4 or 8; 1.6T = 8. WDM systems align with integrated EML transmitters; parallel-fiber systems align with separated CW+modulator architectures.
- **Investment implication.** Names exposed to EMLs (InP-laser specialists) and names exposed to CW + silicon photonics (substrate, external laser source, silicon-photonics engines) ride different rails of the same overall optical ramp. The next post in the series breaks down [[Lumentum (LITE)]], [[Coherent (COHR)]], [[Applied Optoelectronics (AAOI)]], [[Sivers Semiconductors (SIVE.ST)]], and $MTSI on each side of this shift.

## Architecture diagram

*EML (integrated laser + modulator on one InP chip) vs CW laser + silicon-photonics modulator (separate light source feeding an external modulator), as built into data-center optical transmitters.*
![[cruxcapitalgroup-eml-vs-cw-lasers-001.png]]

## Original Content

This is going to be a really simplified breakdown of two types of lasers that you need to understand. This is the foundation for knowing where the companies that we are invested in will capture dollars and how they are positioned in future architectures.

---

# How does an optical transceiver put data onto light?

![[cruxcapitalgroup-eml-vs-cw-lasers-001.png]]

Inside an AI data center, thousands of GPUs have to communicate with each other. They do that through high-speed optical links. Every one of those links relies on a transmitter that converts electrical data into light signals.

To do that job, the transmitter needs two things:

1- a light source
2- a way to encode data onto that light

Today there are two main ways the industry builds that transmitter.

One approach uses an EML, or electro-absorption modulated laser.

The other uses a CW laser, or continuous-wave laser, paired with a separate modulator.

That design decision shapes how optical modules are built at 400G, 800G, and 1.6T, and it connects directly to major technology trends you are hearing about like silicon photonics and co-packaged optics.

A really simple way to understand the difference:

An EML combines the light source and the modulator in one device.
A CW architecture separates the light source from the modulator.

---

# What an EML is

An EML combines two components inside a single semiconductor device.

The first part is a laser that generates light.
The second part is a modulator that places data onto that light.

Both are built together on an indium phosphide (InP) chip.

When electrical data arrives from the switch or GPU, the modulator rapidly changes how much light passes through the device. Those changes represent digital data that can then travel through optical fiber.

Because the laser and modulator are integrated into one component, EML transmitters are compact and deliver very strong signal quality.

That is why EMLs have been widely used across high-speed optical networking for years.

At speeds like 100G and 400G, many optical modules rely on EML transmitters to generate clean optical signals for data center and telecom links.

---

# What a CW laser architecture is

A CW laser does something simpler.

It produces a continuous stream of light.

It does not encode data itself. Instead, the data modulation happens somewhere else.

In many modern designs, the modulation function sits on a silicon photonics chip.

So the transmitter architecture becomes:

CW laser → silicon photonics modulator → optical fiber

The CW laser supplies the light and the silicon photonics chip performs the modulation and other optical functions.

This separation allows engineers to optimize each part independently.

The laser focuses on producing stable optical power whereas the silicon photonics chip focuses on routing and modulating the light.

---

# Why both architectures exist

Both approaches exist because they solve different engineering problems.

An EML integrates everything into one device. That makes the transmitter compact and delivers excellent signal performance.

A CW architecture separates the light source from the modulation function. That provides more flexibility when designing larger optical systems.

This difference becomes more important as data center networking speeds increase.

At 400G, most modules followed similar design patterns.

At 800G, the industry began using more varied architectures.

At 1.6T, the physical design of the optical engine becomes much more important, and that is where the architecture conversation becomes more visible.

---

# How optical lanes influence the design

High-speed optical modules move data through multiple optical lanes.

Each lane carries a portion of the total bandwidth.

For example:

• 400G modules often use 4 optical lanes
• 800G modules may use 4 or 8 lanes
• 1.6T modules typically use 8 lanes

Some systems rely on parallel fiber, where each lane uses its own fiber.

Other systems rely on wavelength division multiplexing (WDM), where multiple wavelengths travel through the same fiber.

These design choices influence which transmitter architecture makes the most sense.

WDM systems often align well with integrated transmitters like EMLs.

Parallel-fiber systems often align well with architectures that separate the light source from the modulator.

---

# Where silicon photonics fits in

One of the biggest reasons CW architectures have become more important is the rise of silicon photonics.

Silicon photonics allows engineers to build optical circuits on silicon wafers.

Those circuits can include modulators, waveguides, multiplexers and photodetectors.

Because silicon manufacturing scales extremely well, silicon photonics offers a path toward large-scale optical integration.

But silicon has a limitation. I know you hear this point over and over again, but for those that haven't, silicon is very good at manipulating light, but it is not efficient at generating light.

That means most silicon photonics systems rely on external lasers.

CW lasers provide that external light source.

As silicon photonics adoption grows, the role of external CW lasers becomes more important.

---

# Why external laser sources matter

As optical systems grow more complex, engineers sometimes move the lasers into a separate module.

These are called external laser sources.

Instead of placing lasers inside every optical engine, a centralized module generates optical power and distributes that light to multiple photonic devices.

This approach offers several advantages.

It improves thermal management, because lasers operate more reliably in cooler environments.

It also improves serviceability, since the laser module can be replaced independently of the optical engines.

Industry groups such as the OIF have introduced standards for these types of modules, reflecting growing interest in this architecture.

---

# The role of co-packaged optics

Another reason the CW conversation is becoming more important is co-packaged optics (CPO).

In traditional networking systems, optical transceivers sit at the front panel of a switch.

In CPO systems, optical engines move much closer to the switching silicon itself.

This reduces electrical signal loss and improves power efficiency.

But placing optics next to large switch ASICs introduces new challenges, especially heat.

High-performance switches generate enormous amounts of heat, and lasers are sensitive to temperature.

That is one reason many CPO designs separate the laser source from the optical engines and rely on external laser modules.

As a result, CPO architectures often increase the importance of high-power CW lasers.

---

# TLDR;

The most important takeaway is simple.

EMLs and CW architectures both play important roles in modern optical systems.

EMLs remain very important in many high-performance optical modules today.

CW-laser-based architectures are becoming more visible as the industry expands silicon photonics, external laser sources, and co-packaged optics.

As AI infrastructure continues to scale, optical networking is evolving along multiple paths.

Some systems will continue using tightly integrated transmitters built around EMLs.

Others will increasingly rely on architectures where CW lasers provide the light and silicon photonics handles the modulation.

---

In the next post, I want to take this one step further.

Once you understand the architecture, the next question becomes:

Which companies are actually positioned on each side of this shift?

That is where things start to get more interesting for investors.

Some companies are heavily exposed to EMLs.
Some are building around CW lasers and the rise of silicon photonics.
Some sit in the middle and have exposure to both.

So next I'm going to break down how names like [[Lumentum (LITE)]] [[Coherent (COHR)]] [[Applied Optoelectronics (AAOI)]] [[Sivers Semiconductors (SIVE.ST)]] $MTSI fit into this evolving optical stack, where they have advantages, and what investors should really be watching as 800G, 1.6T, silicon photonics, and CPO all continue to ramp.
