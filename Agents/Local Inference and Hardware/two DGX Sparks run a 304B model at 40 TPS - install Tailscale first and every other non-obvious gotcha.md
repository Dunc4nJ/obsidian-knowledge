---
created: 2026-08-25
description: Vectal Labs' field notes from setting up two NVIDIA DGX Sparks and running a 304B model across them at 40 TPS before any optimization — the non-obvious physical and setup gotchas (install Tailscale FIRST so you never sit at the desk, wired peripherals, USB-C hub, plug order, the cx7-hotplug file that makes the fast ports vanish after reboot) plus the software path (MiaAI-Lab 2x-Spark recipe + Anemll vLLM image, don't build the server from scratch).
source: https://x.com/vectal_labs/status/2092212858478043228
author: "@vectal_labs (Vectal Labs)"
type: article
tags: [local-inference, hardware, dgx-spark, nvidia, homelab, vllm, deepseek, tailscale, setup-guide]
---

## Key Takeaways

- **The headline result and the framing: two DGX Sparks ran a 304B model at 40 TPS *before any optimization*.** This is a practitioner's "what I wish I knew" guide, not a benchmark post — written as what you'd tell a friend before their first two-box setup, with commands in a companion repo. It's the desk-level counterpart to the rack-level economics in [[camelAI self-hosts DeepSeek V4 Flash on 4x RTX PRO 6000 Blackwell for a fixed-cost free tier, with KV cache as the real bottleneck|camelAI's 4x RTX PRO 6000 self-host]], and part of the same open-weights-at-home thesis as [[Open models now match closed frontier models on core agent harness tasks at a fraction of the cost]].

- **The single highest-leverage tip: install Tailscale *first*, before anything else.** Get both boxes online, install Tailscale, log in, then walk back to your laptop and finish everything over SSH with the agents you already have. Skip this and "you will spend hours at the desk copying commands by hand." The bootstrapping trick for getting commands onto a Spark before SSH works: open Discord or WhatsApp in the browser, log in via phone QR, and message the commands to yourself. Once Tailscale is up, remote agents can fix the box from anywhere — which is how the hardware gotcha below gets solved without physically being there.

- **Physical gotchas that cost hours: wired peripherals, a hub, and plug order.** Bluetooth keyboards/mice "fail to pair a lot, especially with two Sparks in the same room" — and with no touchpad, an unpaired keyboard makes a Spark "an expensive brick." Get a USB-C hub (2+ ports and HDMI) so you can swap the whole desk setup between boxes; a USB-C→ethernet adapter if a NAS occupies the single RJ45. Plug order that avoids a dead screen with no internet: hub (screen/keyboard/mouse) → internet (WiFi may be needed for the first firmware update) → NAS ethernet → **the Spark-to-Spark link last**, both boxes already on, hook-side up, listen for the click, and both ends must be on the *same* side (left or right).

- **The gotcha that looks like dead hardware but isn't: `/etc/nvidia/cx7-hotplug-enabled`.** After a reboot the fast interconnect ports vanished on one box — a known software issue, not a failure: delete that file and reboot. Also mundane but real: terminal copy/paste is Ctrl+Shift+C/V (not Ctrl+C/V), and **choose the same Linux login name on both Sparks** — required to link them, so do it during install rather than redoing it later.

- **Software: use the recipes, don't build from scratch.** MiaAI-Lab's 2x DGX Spark recipe + the Anemll vLLM image ([[Amit Shekhar explains how vLLM packs more LLM users onto one GPU through PagedAttention and continuous batching|vLLM]] under the hood, with DSpark-style [[DSpark (DeepSeek paper) couples a semi-autoregressive drafter with a hardware-aware confidence scheduler to raise accepted length 16-31% offline and shift DeepSeek-V4's serving Pareto frontier|speculative decoding]] in the DeepSeek-V4-Flash lineage). Copy identical model files to the internal disk of *both* boxes. Keep the server private to the box — **there is no password** — and reach it over Tailscale instead, which also means "as long as the Sparks are running, you can use your own inference wherever you are." That last line is the real payoff: personally-owned inference as always-available infrastructure ([[Harrison Chase argues companies must own their intelligence by controlling the model-harness-context system its governance and the compounding feedback loop|own-your-intelligence]] at the individual scale).

## External Resources

- Original article: [What I wish I knew before setting up 2 DGX Sparks — @vectal_labs](https://x.com/vectal_labs/status/2092212858478043228)
- Companion repo: [vectal-labs/2x-dgx-spark](https://github.com/vectal-labs/2x-dgx-spark)
- Credited upstream: [MiaAI-Lab's DeepSeek-v4-Flash DSpark 2x DGX Spark recipe](https://github.com/MiaAI-Lab/DeepSeek-v4-Flash-DSpark-2x-DGX-Spark) ([@MiaAI_lab](https://x.com/MiaAI_lab)) · [Anemll dspark-vllm-gx10 image](https://github.com/Anemll/dspark-vllm-gx10)

## Original Content

> [!quote]- Full X Article — "What I wish I knew before setting up 2 DGX Sparks" (@vectal_labs, 2026-08-25)
> Article: What I wish I knew before setting up 2 DGX Sparks
>
> I set up two DGX Sparks and ran a 304B model on them at 40TPS before any optimization.
>
> *The two-Spark stack:*
> ![[vectal-dgx-spark-001.jpg]]
>
> Here is a guide with all the non-obvious things you should know before doing this yourself the first time from someone who just went through it.
>
> The commands are in a repo. Link at the bottom. This is just what I would tell a friend before they start.
>
> ---
>
> ## Install Tailscale first
>
> Do not do the setup sitting at the Sparks.
>
> Get both boxes on the internet, install Tailscale, log in, and go back to your laptop.
>
> From there you can connect and finish the rest with the agents you already have set up.
>
> If you skip this, you will spend hours at the desk copying commands by hand (and run into a lot of issues if you aren't a linux user).
>
> To get the Tailscale install commands onto the Spark before SSH works, open Discord or WhatsApp in the browser, log in with a QR code on your phone, and send the commands to yourself. Then paste them on the Spark (there might be a better way to do this, but this one works)
>
> ## Quick tips
>
> Get a keyboard and mouse that plug in with a cable. Bluetooth-only ones fail to pair a lot, especially with two Sparks in the same room. And since there isn't a touchpad on a Spark, you will just have an expensive brick unless you connect a keyboard to it.
>
> ---
>
> The Sparks have 4 USB-C ports, HDMI and RJ45.
>
> I would recommend getting a USB-C hub with at least 2 USB-A/USB-C ports and HDMI.
>
> That way you can connect the keyboard, mouse and monitor into it and easily swap your setup from one Spark to the other (totally not necessary, but convenient)
>
> If you have a NAS and you use ethernet, also get a USB-C to ethernet adapter (USB 3 if your network is fast). The Sparks only have one RJ45 port, so you will lack one spot if you connect the NAS and the Spark with an ethernet cable.
>
> ---
>
> Plug things in this order. Not mandated, but saves you from sitting there with no screen and no internet.
>
> 1. USB-C hub with screen, wired keyboard, wired mouse.
>
> 2. Internet. If you have the USB-C ethernet adapter, plug that in now (you might still need WiFi at first, I didn't manage to connect ethernet for the initial firmware update)
>
> 3. Ethernet cable between NAS and Spark if you have one (You only need to connect 1 Spark with the NAS)
>
> 4. The cable between the two Sparks last. Both boxes should already be on. The hook thing goes on top, if the whole plug doesn't go in and you don't hear a click, it's probably the wrong way around. Make sure to plug both into the left or the right. Needs to be same on both.
>
> ---
>
> Copy and paste is different in a Linux terminal than in a browser.
>
> In the terminal: Ctrl+Shift+C and Ctrl+Shift+V (if it doesn't work, try holding shift while selecting what to copy, sometimes needed)
>
> In a browser or a normal app: Ctrl+C and Ctrl+V.
>
> ---
>
> Choose the same Linux login name on both sparks. You will need to do this anyways if you want to connect the Sparks so do it now.
>
> ---
>
> If the link doesn't work, check this: On one of my boxes the fast ports vanished after a reboot. It looked like broken hardware but was a software setting. Delete the file `/etc/nvidia/cx7-hotplug-enabled` and reboot. It's a known issue (by this point an agent should be able to do this from your own device through tailscale)
>
> ## Running the model
>
> Use the MiaAI-Lab 2x DGX Spark recipe and the Anemll image. Do not build the server from scratch (instructions for your agent in repo below).
>
> Copy the model files onto the disk inside both boxes. Same files on both.
>
> Keep the server private to the box. There is no password.
>
> Tailscale lets you SSH from anywhere, so as long as the Sparks are running, you can use your own inference wherever you are.
>
> ## The rest
>
> The full setup is here: https://github.com/vectal-labs/2x-dgx-spark
>
> Credit:
> MiaAI-Lab for the 2x DGX Spark recipe: [https://x.com/MiaAI_lab](https://x.com/MiaAI_lab) | https://github.com/MiaAI-Lab/DeepSeek-v4-Flash-DSpark-2x-DGX-Spark
> Anemll for the vLLM image: [https://github.com/Anemll/dspark-vllm-gx10](https://github.com/Anemll/dspark-vllm-gx10)
