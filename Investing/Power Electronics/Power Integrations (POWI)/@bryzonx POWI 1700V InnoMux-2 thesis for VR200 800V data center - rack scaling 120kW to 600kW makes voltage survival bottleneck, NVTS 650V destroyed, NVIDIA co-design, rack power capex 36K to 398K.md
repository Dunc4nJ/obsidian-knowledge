---
created: 2026-05-22
published: 2026-05-22
description: BryzonX argues Power Integrations is better positioned than Navitas for NVIDIA's VR200 800V data-center power transition because rack power scaling from 120kW to 600kW makes voltage survival, not switching speed, the key bottleneck.
source: https://x.com/bryzonx/status/2057915519496531981
type: thesis
authors: ["bryan (@BryzonX)"]
---

# @bryzonx POWI 1700V InnoMux-2 thesis for VR200 800V data center - rack scaling 120kW to 600kW makes voltage survival bottleneck, NVTS 650V destroyed, NVIDIA co-design, rack power capex 36K to 398K

## Key takeaways

- The thesis is that [[Power Integrations (POWI)]] is an under-owned power-semiconductor beneficiary of [[Nvidia (NVDA)]] VR200 / Vera Rubin 800V data-center architecture because rack power scales from 120kW to 600kW and the bottleneck shifts from switching speed to raw voltage survival.
- BryzonX frames [[Navitas Semiconductor (NVTS)]] as the wrong kind of GaN exposure for this use case: GaNFast/GaNSafe tops out at 650V, which he says is a consumer and lower-voltage profile that cannot natively survive an 800V data-center rail without stacked workaround complexity.
- POWI's differentiator is the InnoMux-2 / PowiGaN high-voltage stack: the thread claims it is the only 1700V switch on single silicon globally, creating a 900V buffer at 800V and still leaving a safety buffer if NVIDIA moved to 1200V DC.
- The numerical capex bridge is the artifact: Morgan Stanley's AI server power roadmap shows current GB200 rack power value at $36K, Vera Rubin at $76K in 2026, and Vera Rubin CPX / Ultra-Kyber moving toward $398K+ or over 10x as power infrastructure becomes a larger rack-cost line item.
- The thread claims POWI's 1700V chip was not originally built for AI; it was built for unstable grids and EV architectures, then became relevant when NVIDIA shifted Vera Rubin to an 800V DC baseline and needed single-chip high-voltage reliability for fans, liquid pumps, and logic controllers.
- The peer map extends [[@insane_analyst 650V class SiC and GaN power device landscape - 15-vendor comparative table at 80C Vds 400V covering Rds-on Coss Eoss Qoss and pkg integrated-driver tradeoffs]] into the next voltage tier, alongside [[Infineon Technologies (IFX.DE)]], [[STMicroelectronics (STM)]], [[Onsemi (ON)]], [[Wolfspeed (WOLF)]], [[ROHM (6963.T)]], and [[Innoscience (2577.HK)]].
- Companion NVDA/rack-cycle notes: [[@ren_aramb ARM CPU-cycle thesis - Vera 200B TAM and 20B FY CPU visibility, first deliveries to Anthropic OpenAI SpaceXAI Oracle, GPU-CPU rack ratio 1-1 to 1-4, ARM server share 15pct to 40-45pct by 2030]], [[@aaronwei3n MS VR200 NVL72 BoM - PCB content up 233 pct to $116730 per rack, TTMI read-through, memory up 435 pct and ABF up 82 pct]], [[@hypertechinvest Stocks to Play Rubin Rack Manufacturing - 5 categories from memory equipment PCB MLCC networking substrate with 75 plus names mapped to NVL72 VR200 BOM where memory cost jumps 435 pct PCB 233 pct MLCC 182 pct vs GB300]], [[Crux Capital 2026-05-20 - Nvidia just told us something important for Nokia, Jensen says every base station becomes AI-powered radio network, $1B NVDA investment in NOK validates AI-RAN three-layer taxonomy near-term rerate plus long-term option]], and [[@ren_aramb PCB AI beneficiaries - NVL72 BoM PCB +233pct second-largest jump after memory, 9 names ranked Unimicron Zhen Ding Tripod Compeq TTMI Victory Giant WUS Shennan Elite]].
- Prior BryzonX captures in the vault: [[@bryzonx CLFD AI DC interconnect thesis - 1mm bend stalls 800G cluster, NOVA HD Panel 384 LC ports in 4U at 0.2dB insertion loss, Q2 26 book-to-bill 1.3 backlog +39pct, ELS hot-swap socket for CPO]], [[PENG Optical Memory Appliance unlocks 1000TB cluster pool vs 11TB copper KV cache, 70pct cost-per-query reduction - BryzonX thesis]], and [[HLIT vCMTS monopoly enables broadband Distributed AI Grid as Comcast and Charter deploy Blackwell at neighborhood hubs - BryzonX thesis]].

## Original Content

@BryzonX (bryan):
Today I added to my $POWI (Power Integrations) position, planting my flag in what I believe will be a massive Capex wave transforming the entire power semi space

Currently, $NVTS is getting all the love which is fair, however...

With the release of the specs for the upcoming architecture of the 800V Data center for VR200 it is quite clear that there will be a huge demand for high voltage GaN rather than high speed integration GaN in which NVTS provides 

The server rack will be scaling from 120 kW to 600 kW (!) 

The core issue isn't going to be how fast a chip can switch, it will be about how much raw voltage can actually survive

Navitas flagship GaN tech (GaNFast and GaNSafe) maxes out at 650V

It was originally designed for high speed switching in consumer electronics and lower volt apps not not megawatt scale AI infrastructure

A 800V data center will instantly destroy a lone 650v chip. To participate, NVTS has to combine lower voltage components in a highly complex stacked build which creates clunky workarounds, wastes physical space, and introduces severe points of failure

POWI's chips doesn't require these unnecessary  workarounds 

Their InnoMux-2 is the ONLY chip on earth that features a 1700v switch on a single piece of silicon

When NVDA starts to roll out these high power racks, a single PowiGaN chip will be able to handle it natively with an integrated safety buffer to spare 

Which is IMPORTANT because in the case of power spikes, POWI's voltage leaves a 900v buffer that is built to handle the power spikes without creating a power failure 

Let me put this into context for you guys 

If NVDA said F it let's skip 800v and go straight to 1200v DC POWI's 1700v chips are still able to handle the power consumption TODAY still with a SAFETY BUFFER 

Here is why $POWI is still undervalued:

They didn't build the 1700v chip for AI

They originally built it to handle unstable power grids in developing markets and heavy electric vehicle architectures

When $NVDA shifted the Vera Rubin architecture to an 800V DC baseline, their engineers realized they needed a battle tested SINGLE chip solution to safely drive the background cooling infrastructure (fans, liquid pumps, and logic controllers)

POWI was the only company in the world that had spent decades perfecting single chip high volt integration.

That deep reliability is why they are co-designing power blueprints alongside NVIDIA TODAY

If you track the projected power infrastructure spend per AI rack, the metrics are going vertical:

Current (GB200): $36,000 per rack

2026 (Vera Rubin): $76,000 per rack

2027 (Vera Rubin Ultra / Kyber): >10x increase (Over $360,000 to $398,000+ per rack)

POWI's TAM is literally multiplying right before our eyes

Currently, their entire business is still being dragged down by legacy 

When you look at $POWI at surface level, you see flat YoY revenue, lower GAAP margins, and a high P/E ratio

but don't be fooled, their PowiGaN product division is growing at over 40% annually and will continue to accelerate as the VR is deployed 

In February 2026, POWI even did a 7% workforce reduction to reallocate that money toward scaling DC revenue

You are essentially paying a cyclical multiple for a boring legacy appliance business, and getting a structurally protected, high voltage AI pure play for free even after the initial move

From a TA perspective, just look how coiled it is. Currently trading under it's HTF downtrend line while simultaneously allowing moving averages to play catch up

It's only a matter of when not if imo this breaks out  

NFA. Research purposes only.
PHOTO: https://pbs.twimg.com/media/HI8vQeWbEAA-Wmf.jpg

[Image - Morgan Stanley roadmap table transcribed below; source image deleted after transcription]

**Exhibit 7: AI server power solution roadmap to 800 VDC architecture**

Source: Morgan Stanley Research

| Server power supply design | Current | Current | Current | 2026 | 2026 | 2027 |
|---|---:|---:|---:|---:|---:|---:|
|  | Power shelf | Power shelf | Power shelf | Power shelf | HVDC Standalone power rack | HVDC Standalone power rack |
| AC-DC conversion | 400V AC >> 50V DC | 400V AC >> 50V DC | 400V AC >> 50V DC | 400V AC >> 50V DC | 400V AC >> 800V DC | 400V AC >> 800V DC |
| Nvidia AI GPU generation | GB200 | GB300 | GB300 | Vera Rubin | Vera Rubin CPX version | Vera Rubin Ultra |
| Nvidia AI server rack architecture | Oberon | Oberon | Oberon | Oberon | Oberon | Kyber |
| Power wattage per server rack | 120kW | 140kW | 140kW | 200kW+ | 380kW+ | 600kW |
| Power wattage per PSU | 5.5kW | 8kW | 12kW | 18.3kW | 18.3kW | 30kW |
| Power value per AI server rack (x) | US$36,000 (x) | US$57,600 | US$69,120 | US$76,000 | US$398,160 | >10x |
| Power value per watt | US$0.3 | US$0.41 | US$0.49 | US$0.38 | US$1.05 | -- |

PHOTO: https://pbs.twimg.com/media/HI8vQehaYAAdpo-.jpg

[Image - Power Integrations call excerpt transcribed below; source image deleted after transcription]

Our high-power business, which sits in the industrial category, continues to grow at a healthy pace, driven by a diverse set of verticals, including electric rail, renewables, oil and gas, and power grid applications, including DC transmission and power quality. Key design wins in Q1 included a design for 6 MW wind turbines at a European customer and at STATCOM power conditioning design for an Indian customer. **Lastly, turning to everybody's favorite topic, data center, we continue to pursue multiple paths to growth with our unique PowiGaN technology. Our ongoing collaboration with NVIDIA includes a variety of sockets utilizing our 1,250 V and 1,700 V GaN technologies in the forthcoming 800 V DC architectures. We continue to gain share in aux power supplies for today's data centers, winning two new designs in Q1 at Taiwan customers serving U.S. equipment makers.**

PHOTO: https://pbs.twimg.com/media/HI8u8NBbkAEB8E8.jpg

*Power Integrations one-week chart attached by BryzonX; visible labels include Power Integrations, Inc. 1W NASDAQ, 5.16M volume, price marker 70.86, moving averages around 64.48, 60.67, 57.36, 55.33, and 52.29, with a descending trendline break setup.*
![[bryzonx-531981-003.jpg]]

>  QT @BryzonX:
> One of my fav new finds is $POWI 
> 
> An Energy + Data Center company with an existing $NVDA partnership/design win for the Rubin deployment 
> 
> PHOTO: https://pbs.twimg.com/media/HEH2FO6aIAIg7B4.jpg

*Earlier BryzonX POWI chart from the quoted tweet; visible labels include Power Integrations, Inc. 1M NASDAQ, price marker 47.58, volume 16.76M, and a long-term support trendline.*
![[bryzonx-531981-004.jpg]]

>  https://x.com/BryzonX/status/2036190827689762835
date: Fri May 22 20:04:28 +0000 2026
url: https://x.com/BryzonX/status/2057915519496531981
──────────────────────────────────────────────────

@its_moonberries (moon🎴):
@BryzonX Placed a starter in this midday. I agree with your thesis.
date: Fri May 22 20:07:01 +0000 2026
url: https://x.com/its_moonberries/status/2057916161459699941
──────────────────────────────────────────────────

@BryzonX (bryan):
I tried so hard to get this out to you guys before market close but it took a lot of research (sorry)
date: Fri May 22 20:08:59 +0000 2026
url: https://x.com/BryzonX/status/2057916655536349653
──────────────────────────────────────────────────

@pminvest288 (PMInvest):
@BryzonX Have a look on $FPS, I think $FPS +73% YoY =&gt;83%YoY is much faster! As $FPS ramp up 5B Production Line All in US to meet Grid +Transformer shortage (Lead time 6 months) + $FPS increase more products focus on Renewable Connections, then 2X Revenue +Margin Up in 26,27!
date: Fri May 22 20:11:52 +0000 2026
url: https://x.com/pminvest288/status/2057917380597293125
──────────────────────────────────────────────────

@UltrasGux (S):
@BryzonX Yes I remember being in this back in April, great pick! Maybe ill join back in again.
date: Fri May 22 20:12:01 +0000 2026
url: https://x.com/UltrasGux/status/2057917420187324729
──────────────────────────────────────────────────

@BryzonX (bryan):
@pminvest288 I'm a fan of FPS, but I've done quite a bit of work on POWI for the longest and my strategy comes from conviction and execution. 

I really like how the story of POWI is shaping up over the past few quarters with their unique positioning in what i'm looking for.
date: Fri May 22 20:14:53 +0000 2026
url: https://x.com/BryzonX/status/2057918140546465956
──────────────────────────────────────────────────

@kcna12 (krishna):
@BryzonX Impressive DD. 

Any idea by when this new architecture hits adoption and profits materialize!?
date: Fri May 22 20:30:02 +0000 2026
url: https://x.com/kcna12/status/2057921951813833056
──────────────────────────────────────────────────

@CaptainCookx100 (Captain_Cook10000x):
@BryzonX Legacy business floor with AI buildout upside, sounds a lot like $RELL
date: Fri May 22 20:39:17 +0000 2026
url: https://x.com/CaptainCookx100/status/2057924281896407369
──────────────────────────────────────────────────

@BryzonX (bryan):
Their power GaN segment is growing 40% YoY alone today so they’re already seeing growth from smaller early adopters like T2 server players, EV platforms, and industrial grid applications 

Basically proving to investors & engineers that it works 

But once Vera drops its going to be full scale production
date: Fri May 22 20:43:47 +0000 2026
url: https://x.com/BryzonX/status/2057925412760752489
──────────────────────────────────────────────────

@Live_2_Dooj (Andrew):
@BryzonX No joke I love that the InnoMux datasheet's first typical application is an LED driver. They don't need to add a new revision in the product highlights to shill that they are positioned for the 800V AI datacenter market like other ICs. The specs speak for themselves. Great work!
date: Fri May 22 20:47:59 +0000 2026
url: https://x.com/Live_2_Dooj/status/2057926468274180473
──────────────────────────────────────────────────
