---
created: 2026-05-20
published: 2026-05
description: Pennycheck Research OSINT-compiled inventory of Ouster (OUST) LiDAR integrations across 17+ NATO-aligned defense primes and 5 autonomous platform classes (UGV, UAV, USV, counter-UAS DEW, security infrastructure); analyst quoted "no autonomous defense vehicle seen without Ouster."
source: https://smallpdf.com/file#s=41640b9b-1b86-4f6c-b67a-de429dcd7713&r=read
type: thesis
authors: ["Pennycheck Research"]
---

# Pennycheck OUST defense applications OSINT (May 2026)

## Key takeaways

- **"No autonomous defense vehicle seen without Ouster"** — direct quote from the OSINT analyst behind this compilation. [[Ouster (OUST)]] LiDAR has achieved de facto standardization across autonomous defense platforms operated by or developed for U.S. and NATO-aligned forces.
- **17+ defense integrators, 5 platform classes, 10+ NATO-aligned nations**, plus classified programs believed material but beyond OSINT visibility.
- **Confirmed prime/integrator base**: [[Rheinmetall (RHM.DE)]] (Mission Master SP UGV, Autonomous PATH kit), Milrem Robotics (THeMIS, HAVOC, VECTOR, MRCV UGVs — Ukraine, Netherlands, Japan), Iveco Defence Vehicles (Viking UGV — UK British Army), Anduril Industries (Ghost / Ghost X UAVs, OS1 sensor — official OUST partner, Blue UAS certified), Shield AI (H145 helicopter, Hivemind autonomy — USMC Aerial Logistics Connector), Kodiak Robotics (Epirus Leonidas AGV for counter-UAS — defense-only, switches off Hesai), Overland AI (USMC ROGUE Fires), [[General Dynamics (GD)]] (Leonidas AGV / Epirus DEW), [[BAE Systems (BAESY)]] (ATLAS CCV 8x8 UGV "Combat Wingman"), Skydio (X10D drone, US Army order), AIM/Scale Earth (USAF RADR program, $4.9M contract), Quantum Drones (MOSAIC Ground Autonomy Kit on Daimler platforms), Constellis (LEXSO AI security platform with Ouster Gemini), Maritime Robotics (USVs), French Military 17e RGP (Vision 60 / Terrang MP-SEC robot dog), [[Textron (TXT)]] (general military UGV programs), LPP (Ukraine UGV procurement pipeline).
- **Defense-grade qualification preference is the moat**: platform switching pattern documented for Kodiak Robotics — uses [[Hesai (HSAI)]] commercially but Ouster *exclusively* for defense. Pennycheck reads this as deliberate defense-grade qualification preference, not interchangeable LiDAR.
- **Five platform categories and key sensor models**: UGVs → OS0/OS1/OS1 Max (360° coverage, perception backbone for autonomy stack). UAVs/drones → OS1 (Anduril Ghost/Ghost X, Skydio X10D). Manned autonomous aircraft → OS1 front/rear (Shield AI Hivemind on H145). Counter-UAS / directed energy → Epirus Leonidas AGV. USVs → Maritime Robotics. Security/physical AI infrastructure → Ouster Gemini (Constellis LEXSO).
- **Direct U.S. military programs with Ouster as perception layer**: X-MAV / M-MAV / L-MAV (autonomous missile launchers/vehicles), DeepFires (autonomous fires vehicle), Infantry Squad Vehicle (ISV) unmanned conversions by multiple contractors, USMC Aerial Logistics Connector (H145 + Shield AI Hivemind, front/rear Ouster sensors), USMC ROGUE Fires (Overland AI AGVs, JRTC demonstrated), USAF RADR (AIM/Scale Earth autonomous construction for rapid airfield damage recovery), US Army Drone Order (Skydio X10D, official Ouster defense customer, Blue UAS certified).
- **Methodology**: OSINT via open-source visual analysis, Ouster's disclosed customer/partner lists, defense contracts via SAM.gov, partner announcements, earnings-call disclosures. Pennycheck explicitly flags that classified programs are believed to be a significant additional share not captured in the open-source compilation.

## Original Content

# OUSTER LiDAR

## Defense & Autonomous Systems Applications

Known Integrations Across NATO-Aligned UGV, UAV, USV, and Directed-Energy Programs

OSINT Compiled - May 2026 | Pennycheck Research

## EXECUTIVE SUMMARY

[[Ouster (OUST)]] (OUST) LiDAR sensors have achieved broad de facto standardization across autonomous defense platforms operated by or developed for U.S. and NATO-aligned forces. Sensor integrations span unmanned ground vehicles (UGVs), unmanned aerial vehicles (UAVs), unmanned surface vessels (USVs), and counter-UAS directed-energy systems. The install base spans prime contractors, autonomy specialists, and Tier-1 integrators - with significant classified programs likely not captured in open-source data. OSINT analysts covering OUST have observed: "No autonomous defense vehicle seen without Ouster."

| 17+ Defense Integrators | 5 Platform Classes | 10+ NATO-Aligned Nations | CLASSIFIED Programs Beyond OSINT |
|---|---|---|---|

## KNOWN DEFENSE INTEGRATORS & APPLICATIONS

| COMPANY / PRIME | PLATFORM / PROGRAM | APPLICATION | STATUS / GEOGRAPHY |
|---|---|---|---|
| [[Rheinmetall (RHM.DE)]] / American Rheinmetall | Mission Master SP UGV; Autonomous PATH kit | Autonomous UGVs - combat support, logistics, robot gun turrets | US Marines, Japan trials; Talisman Sabre / Apollo Shield |
| Milrem Robotics | THeMIS, HAVOC, VECTOR, MRCV UGVs | Combat, logistics, and reconnaissance UGVs | Ukraine, Netherlands, Japan (NATO-aligned) |
| Iveco Defence Vehicles | Viking UGV | Logistics resupply, CASEVAC, ISTAR operations | UK British Army demonstration |
| Anduril Industries | Ghost / Ghost X UAVs (OS1 sensor) | AI-powered tactical recon/strike drones; ISR in contested environments | US DoD; Blue UAS certified; official OUST partner |
| Shield AI | H145 helicopter; Hivemind autonomy | Autonomous aircraft perception, obstacle avoidance; USMC Aerial Logistics Connector | USMC program; Blue UAS certified |
| Kodiak Robotics | Defense vehicles (Epirus Leonidas AGV) | Counter-UAS autonomy; tactical logistics; defense-specific (vs. commercial: non-Ouster) | General Dynamics Land Systems (GDLS) |
| Overland AI | Autonomous Ground Vehicles (AGVs) | Off-road convoy autonomy; USMC ROGUE Fires program | US Army JRTC; USMC program |

| COMPANY / PRIME | PLATFORM / PROGRAM | APPLICATION | STATUS / GEOGRAPHY |
|---|---|---|---|
| [[General Dynamics (GD)]] Land Systems | Leonidas AGV (Epirus microwave DEW) | Autonomous truck platform for counter-UAS directed energy | US DoD |
| [[BAE Systems (BAESY)]] | ATLAS CCV 8x8 UGV ("Combat Wingman") | 360° LiDAR - autonomy, obstacle avoidance, target detection/classification in combat | NATO |
| Skydio | X10D drone (US Army order) | Military drone payloads; OS1 Max for sensor integration | Official OUST defense customer; Blue UAS |
| AIM / Scale Earth | Autonomous heavy construction machinery | DoD/USAF RADR program; zero-entry sites; swarm ops in GPS-denied environments | $4.9M USAF contract; harsh terrain focus |
| Quantum Drones | MOSAIC Ground Autonomy Kit | Modular autonomy kits for military trucks (Daimler platforms) | Multi-platform; NATO supply chain |
| Constellis | LEXSO AI security platform (Ouster Gemini) | Threat detection and physical AI for airports, ports, gov't facilities | Security/defense infrastructure |
| Maritime Robotics | Unmanned Surface Vessels (USVs) | Defense and maritime security operations | NATO-aligned nations |
| French Military (17e RGP) | Vision 60 / Terrang MP-SEC robot dog | Military robotics for reconnaissance and operations | French Army; Active deployment |
| [[Textron (TXT)]] | Autonomous UGVs | General military UGV programs; autonomy stack | US DoD |
| LPP (lpp-soft.cz) | Military UGVs | Potential major beneficiary of Ukraine's large-scale UGV procurement program | Ukraine procurement pipeline |

## PLATFORM CATEGORIES & KEY SENSOR MODELS

| Category | Detail |
|---|---|
| **UNMANNED GROUND VEHICLES (UGV)** | OS0, OS1, OS1 Max - 360° coverage standard. Integration as perception backbone for autonomy stack. Confirmed: Rheinmetall Mission Master, Milrem THeMIS/HAVOC/VECTOR, BAE ATLAS, Kodiak, Overland AI, LPP, Textron. |
| **UNMANNED AERIAL VEHICLES (UAV / DRONE)** | OS1 - spotted on Anduril Ghost/Ghost X. Skydio X10D (US Army). CEO-noted interest in OS1 Max for sensor payloads. Applications: ISR, strike support, contested-environment navigation. |
| **MANNED AUTONOMOUS AIRCRAFT** | OS1 front/rear - Shield AI Hivemind on H145 helicopter. USMC Aerial Logistics Connector program. Obstacle avoidance and perception in GPS-denied/contested environments. |
| **COUNTER-UAS / DIRECTED ENERGY** | Ouster on Epirus Leonidas AGV (Kodiak/GDLS). Directed microwave anti-drone system. Autonomous targeting and platform navigation - critical dual function in counter-UAS role. |
| **UNMANNED SURFACE VESSELS (USV)** | Maritime Robotics. Defense and maritime security missions for NATO-aligned nations. Applications include mine countermeasures, ISR, and port/harbor security. |
| **SECURITY / PHYSICAL AI INFRASTRUCTURE** | Ouster Gemini LiDAR - Constellis LEXSO platform. Airports, ports, government facilities. AI-driven threat detection and perimeter analytics. |

## U.S. MILITARY PROGRAMS - DIRECT INTEGRATION

| PROGRAM | DETAIL |
|---|---|
| X-MAV / M-MAV / L-MAV | Autonomous missile launchers/vehicles - Ouster confirmed as perception layer |
| DeepFires | Autonomous fires vehicle - Ouster integration observed |
| Infantry Squad Vehicle (ISV) | Unmanned conversions by multiple contractors - Ouster standard |
| USMC Aerial Logistics Connector | H145 helicopter w/ Shield AI Hivemind - front/rear Ouster sensors |
| USMC ROGUE Fires Program | Overland AI off-road autonomous ground vehicles - JRTC demonstrated |
| USAF RADR Program | AIM/Scale Earth autonomous construction for rapid airfield damage recovery |
| US Army Drone Order | Skydio X10D - official Ouster defense customer, Blue UAS certified |

## METHODOLOGY & SOURCE NOTE

All integrations compiled via OSINT: open-source visual analysis, Ouster's disclosed customer/partner lists, defense contracts (SAM.gov), partner announcements, and earnings call disclosures. A significant portion of Ouster's defense penetration is believed to be in classified programs not visible to public sources. The analyst behind this compilation notes that "no autonomous defense vehicle" encountered in open-source review has been observed without Ouster LiDAR. Platform switching (e.g., Kodiak using [[Hesai (HSAI)]] commercially but Ouster exclusively for defense) suggests deliberate defense-grade qualification preference.

Pennycheck Research | For informational purposes only. Not investment advice. All data derived from publicly available sources. May 2026.
