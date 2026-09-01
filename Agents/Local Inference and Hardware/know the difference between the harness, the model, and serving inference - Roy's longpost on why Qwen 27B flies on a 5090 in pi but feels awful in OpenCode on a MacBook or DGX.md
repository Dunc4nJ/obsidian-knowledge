---
created: 2026-09-01
description: Roy's (@usr_bin_roygbiv) 694-like longpost separating the three things people conflate when they say "I'm using Claude" — the harness (Claude Code, Codex, pi, omp, OpenCode…), the model (the weights), and serving (whose silicon, what quant, what time of day). His claim is that most "model takes" are harness or serving takes in disguise — Claude Code or Codex can burn 8x the tokens of pi/omp on the same job, Codex compaction needs 1/4 the context, and the same Qwen 3.6 27B "feels awful in OpenCode on a MacBook or DGX but flies at 10x the speed with no tool calls or thinking in pi with NVFP4 and MTP on a 5090." For a home lab the durable part is the serving layer: bandwidth and Blackwell first, then kernels, config, parallelism — and the decoupling rule that any harness can talk to any provider, including your own box.
source: https://x.com/usr_bin_roygbiv/status/2063420146174119991
author: "@usr_bin_roygbiv (Roy)"
type: post
tags: [local-inference, hardware, agent-harness, serving, quantization, memory-bandwidth, blackwell, nvfp4, mtp, opinion]
---

## Key Takeaways

> [!warning]- Dated context — posted 2026-06-07, captured 2026-09-01
> The model list is three months stale (GPT 5.5 / Gemini 3.5 Flash / Kimi K2.6 / DeepSeek V4 Pro; today it is GPT 5.6 Sol, Gemini 3.7 Flash, Kimi K3, GLM-5.3 and GLM-5.3-Flash of 2026-08-26, Qwen3.8 of August). The local example is Qwen 3.6 27B on an RTX 5090; Roy's own follow-up on 2026-08-23 was Qwen3.8-27B with NVFP4 + DFlash2 at 358.8 tok/s peak on the same card ([[Qwen3.8-27B with NVFP4 plus DFlash2 decodes at 358.8 tok-s peak and 220-240 sustained on one RTX 5090 - Roy's Opus-4.6-at-home claim|captured separately]]). The post predates the M5 Ultra (2026-08-25) and the mid-2026 doubling of RTX 5090 / RTX PRO 6000 prices ([[matmuls are parallel memory reads - Roy's bandwidth ladder puts a 1K RTX 3090 at 936 GB-s above a 5K Mac or DGX Spark, but it has no capacity or prefill column|his bandwidth ladder]] carries the price check). The framework is unchanged. Evidence: `/data/projects/hardware/research/roygbiv-profile.md`, `00-synthesis.md`.

- **The three-layer split is the useful, verifiable part; the vendor scorecard is opinion.** Harness = the software that calls the API (tool calls, system prompt, MCP, skills, subagents, compaction); model = the weights; serving = whose hardware runs them, at what quant, under what load. Two people reporting opposite experiences of "the same model" are usually comparing different harnesses or different serving paths, so any benchmark that does not pin all three is not a model benchmark — the same reason this folder tags every number with its engine, quant and context. The "GPT great / Google unmatched infra / Anthropic shit everything" summary is a prior, not a finding; treat it the way you would treat any single practitioner's vendor ranking.

- **The harness is a hardware multiplier, and this is where his argument meets the prefill problem head-on.** His claims — Claude Code or Codex "can use 8x the tokens in certain contexts" versus pi/omp "purely due to hashline editing and tool calls in the system prompt", and Codex compaction letting the model "need 1/4 the context" — are unverified magnitudes, but the direction is real (a third-party token-per-task comparison Roy amplified on 2026-07-29 had Claude Code at ~6x Kimi Code). For a local box every extra token is prefill time and KV memory: the research found effective long-prompt prefill spans **37 t/s on an M3 Ultra to ~10,000 t/s on an RTX 5090**, so a harness that halves context does more for a Mac than any SKU upgrade, while a bloated one makes even a CUDA card feel slow. Roy's own rule elsewhere is "needing anything over 256K context is a bad harness issue" — the lean-harness practice is how he never pays the prefill tax the research worries about.

- **For serving, his ordering matches the roofline: silicon first, then kernels, config, parallelism.** "Newer generation gpus or gpus with higher memory bandwidth or blackwell hardware are the single largest determinant of how fast a model will run, followed by custom kernels, serving configuration, parallelism" — that is [[Step 01 - Decode is memory-bandwidth-bound (the roofline)|the roofline]] restated, and the Qwen example (awful "in opencode on a macbook or dgx", 10x faster "in pi with nvfp4 and MTP on a 5090") bundles all three layers into one anecdote: a leaner harness, a Blackwell card, and a speculative decoder. What the post omits is that "AMD/Apple significantly slower" is mostly a *prefill and utilization* story — measured dense decode on an M5 Max reaches 74–85% of its bandwidth, big-MoE decode on Ultra dies only 28–45% — and that NVFP4 is a throughput feature, not a quality one ([[GLM-5.3-Flash FP8 really is 306GB and really fits in 512GB - but 60 t-s is 80-90 percent of the roofline on a machine that does not ship until October|the Mac-side roofline note]]).

- **"Quantization … which claude does during peak hours in some locations" is asserted, not shown — and it is still an argument for owning a box.** Anthropic denies load-dependent quantization (a replier raised this; Roy: "Anth insists on a lot of things"), and nothing in the thread substantiates it. But the underlying point does not need the accusation to be true: a hosted route can change quant, speed and availability without telling you, whereas a model you serve yourself is deterministic in weights, quant and drafter — which is what matters for running evals, RL loops or anything you want reproducible. The home-lab research lists privacy, unmetered loops and uncensored weights as ownership motives; *consistency* belongs on that list.

- **Decoupling is the practical instruction: "You can use ANY harness you want with ANY provider if you're willing to set it up."** A local rig only has to expose an OpenAI-compatible endpoint (SGLang, vLLM, llama-server, mlx_lm.server all do), after which harness choice is orthogonal to hardware choice — and the same harness can point at an API by day and the box by night. Roy's own ops pattern is exactly that: API-primary with the GPUs as failover ("I know when I'm out of DeepSeek credits because it fails over to my GPUs and the UPS starts beeping"). This is the software-side reason the research's "two composable units" shape works.

## Roy's replies to commenters

- To "Anthropic insists there's no varying quant based on load": **"Anth insists on a lot of things."**
- To "a lot of model takes are really harness takes in disguise": **"99% — I made this post so I can just link it to people in the future."** And: "people conflate the 3. It's the same reason apple products are so popular, most people just know 'computer' they don't know os, hardware, userspace etc."
- To "how does xAI own its stack if it doesn't own the chip IP": "they physically possess gpus that they legally own. anthropic and openai rent their compute from other people."
- To a reader whose omp + Gemini 3.1 Pro attempt failed where Claude Code succeeded: "gemini 3.5 is what I'm talking about through antigravity, 3.1 is old now."
- To "I built my own agentic OS, so much better than a harness": "no it isn't" — with the omp link (omp.sh). Asked what omp is, and told "just make your own harness", the answer both times is the same link: "just use omp it has literally everything."

## External Resources

- Original post: [@usr_bin_roygbiv, 2026-06-07](https://x.com/usr_bin_roygbiv/status/2063420146174119991)
- [omp.sh](https://omp.sh/) — the "OMP ❤️" harness (oh-my-pi, by @_can1357) Roy uses and recommends throughout the thread; the Qwen-on-a-5090 example runs in base pi
- [roybench.org](https://roybench.org/) — Roy's own Terminal Bench 2.1 (Full 88) leaderboard "by provider route, model, effort, and OMP harness", i.e. the eval infrastructure behind his "terminalbench is king" line
- Research cross-reference: `/data/projects/hardware/research/roygbiv-profile.md` (full time-ordered digest of the account), `fundamentals-software.md` §1.4 (prefill), §1.9 (speculative decoding), §2 (engines)

## Original Content

> [!quote]- Full post (@usr_bin_roygbiv, 2026-06-07)
> Longpost about the biggest misconception I see people having by FAR on LLMs right now.
>
> Know the difference between the harness, the model, and serving inference.
>
> Vast majority of problems I see people having right now are due to the harness. Each provider has it's own unique thing that's wrong with it. Claude is unique like the state of California in that it taxes/is bad at everything.
>
> Harness: This is the traditional software that calls the model api from the provider. This is what you install on your computer or the website you visit to access the LLM.
> Common harnesses:
> - Claude Code
> - Codex
> - Droid
> - Pi
> - OpenCode
> - OMP ❤️
> - Antigravity
> - Copilot
> - https://t.co/CfYrRYJlyx, https://t.co/P87Pigjt4m, or https://t.co/opgE1H0qlh in a web browser could technically be considered a harness
> Harnesses are most people's bottleneck because things like tool calls, system prompts, mcp servers, skills, subagents, change the way the api is called and its actually used for gathering information and your day to day work dramatically. Claude code or codex can use 8x the tokens in certain contexts when programming compared to pi or omp purely due to hashline editing and tool calls in the system prompt. Planning and subagent management also makes work significantly faster for larger tasks. Compaction in codex is so good the model needs 1/4 the context that claude or gemini does to achieve better results which allows them to serve more users simultaneously with available vram.
>
> Model: This is the actual LLM. The weight values which were trained and deployed somewhere which you access from the harness on your machine via an api. This is what people are benchmarking and typically talking about when they post evals.
> Common Models:
> - Claude Opus 4.8
> - GPT 5.5
> - Gemini 3.5 Flash
> - Deepseek V4 Pro
> - Qwen 3.7 Max
> - Kimi K2.6
> - Composer 2.5
> People run evals to determine model quality for different tasks. Most engineers are using them for agentic coding, where terminalbench is king, and swebench to a lesser extent currently. For academic research and "white collar work" (i've written about this gimmick previously) there are other evals people target.
>
> Serving and Inference: This is the actual computer and infrastructure network the model is running and being served on remotely. This can vary wildly depending on the provider.
> - Google and XAI are the only ones that own their full stack vertically right now. Google has vertically integrated all of their models to use in house TPUs rather than GPUs to run on their cloud network (GCP, which they also own) extremely reliably and quickly.
> - OpenAI has secured deals with Microsoft and now AWS and others to have guaranteed compute capacity until 2030 or so and preplanned most of their capacity already. They have deals with nvidia and cerebras directly now for datacenter buildouts.
> - Anthropic didn't buy nearly enough compute the last few years. Now they are desperately selling off equity and turning into corporate frankenstein to meet demand. They are currently splitting the inference they give you between: GPUs, TPUs, AWS, GCP, SpaceX, bunch of other random crap. This is completely unmanageable in any reasonable period of time given the current growth of the space.
>
> Chinese models are open source. Most of the chinese infrastructure is completely jank and slow, but great news! There's places hosting it for you like firworks, GMI, and others on the latest blackwell gpus to run it at 5x the speed you get through the official chinese apis. Or you can host them yourself! The chinese models are also a fraction of the price because power and the older hardware they have is so cheap. DSV4 flash performs the same as sonnet for actual pennies, or you can pay the same prices as the western providers on fireworks or gmi to get something that absolutely flies like gemini does. Kimi charges PER TURN rather than per token so you get 14x the tokens weekly on their chinese sub that you would get on gpt pro for something at gpt 5.4 xhigh's intelligence level.
>
> There are different techniques people use to serve the models more effectively as well to more customers:
> - Quantization truncates the weight values in memory to use less vram at the expense of the model getting "dumber" which claude does during peak hours in some locations and local hosters often use to take advantage of weaker gpus for personal use
> - Smaller models can perform better than larger ones on actual task evals in some cases or be trained or fine tuned to be more token efficient to use less compute while performing similarly from a user's perspective
> - Things like MOE allow models like deepseek or qwen to get split across lots of smaller/cheaper gpus at once and split off smaller more specialized models for research and specialized use cases
> - Specialized silicon like Google's TPUs, Trainium, Cerebras, Groq, allow the models to be hosted at much much higher speeds at higher cost due to the specialized silicon and software stack
> - Newer generation gpus or gpus with higher memory bandwidth or blackwell hardware are the single largest determinant in how fast a model will run that you are hosting followed by custom kernels, serving configuration, parallelism etc. However everything revolves around the silicon. Nvidia is still king because of Cuda and blackwell gpus have minimum 2x the memory bandwidth of any other gpus on the market. TPUS are faster still but far more specialized and difficult to get/set up. AMD/Apple chips are significantly slower albeit cheaper in some cases.
>
> Why all of this is important:
> Many of the issues people experience with claude for example, or reasons you see wildly different experiences from two people using the same model are ACTUALLY because of issues with the harness or serving. Some examples
> - Opus 4.8 works okay on bedrock in opencode at 2am BUT Opus 4.8 on a $20/mo sub during peak business hours served at fp8 quant god knows where on medium thinking in claude code Is completely useless.
> - Gemini 3.5 Flash or 3.1 Pro feels completely useless in gemini cli and gets stuck in loops constantly BUT in OMP it's as good as 5.5 is at 10 times the speed
> - Qwen 3.6 27b locally feels awful in opencode on a macbook or dgx but absolutely flies at 10x the speed with no tool calls or thinking in pi with nvfp4 and MTP on a 5090 using raw bash and web search.
>
> Why gpt is so uniquely good at the above:
> Even if it's slow during the day from the massive userbase, it's the only one that just fucking works 24/7. It's not the fastest or the prettiest, but it's the most reliable and consistent out of the box with the least setup by far.
> Why claude is so uniquely bad at the above:
> The default harness is bad, the user experience is flashy, but it's the most expensive by far, you get wildly different quantizations, speeds, and answer quality depending where it's being hosted, and they have one nine of uptime https://t.co/WaiXeAQreA. This is largely due to organizational issues at the company which will *never* be resolved due to the cap table being so split now and internal politics.
>
> Be extremely wary when someone says "I'm using claude" "I'm using deepseek" "I'm using gemini" two different people could be having wildly different results depending on what harness they're using, what model, thinking, and where it's being served at what time of day.
>
> To summarize:
> GPT -  Slow Harness - Great model - Great Infra
> Google - Shit Harness - Great model - UNMATCHED infra
> Anthropic - Shit Harness - Okay model - Shit Infra - Great marketing and sales team
> (hence California Income/Property/Sales tax analogy)
> Chinese models - It's like linux, here's the parts, build it yourself! or use the hosts in china for dirt cheap or expensive western hosts for extremely fast infra
>
> You can use ANY harness you want with ANY provider if you're willing to set it up
>
> Engagement: 694 likes | 59 replies
> [Original post](https://x.com/usr_bin_roygbiv/status/2063420146174119991)

> [!quote]- Replies and Roy's answers (2026-06-07 to 2026-07-01)
> @lyc_aon (lycaon) — date: Sun Jun 07 00:41:10 +0000 2026 · url: https://x.com/lyc_aon/status/2063420970644504973
> Bro going to blow up with infoslop
> > @usr_bin_roygbiv (Roy) — date: Sun Jun 07 00:42:34 +0000 2026 · url: https://x.com/usr_bin_roygbiv/status/2063421324471529970
> > I'M SICK OF PEOPLE BEING WRONG ON THE INTERNET
>
> @garybasin (Gary Basin) — date: Sun Jun 07 00:55:06 +0000 2026 · url: https://x.com/garybasin/status/2063424476193120667
> Good post but I thought Anth continues to insist that there's no varying quant based on load
> > @usr_bin_roygbiv (Roy) — date: Sun Jun 07 01:13:14 +0000 2026 · url: https://x.com/usr_bin_roygbiv/status/2063429038606082326
> > Anth insists on a lot of things
>
> @stackedlol (stacked) — date: Sun Jun 07 00:57:34 +0000 2026 · url: https://x.com/stackedlol/status/2063425097851949441
> better than any cs class ive taken
> > @usr_bin_roygbiv (Roy) — date: Sun Jun 07 00:59:30 +0000 2026 · url: https://x.com/usr_bin_roygbiv/status/2063425585955697006
> > funny how that works
>
> @868efx (lo) — date: Sun Jun 07 01:04:40 +0000 2026 · url: https://x.com/868efx/status/2063426883329433963
> I took the Gemini 3.5 pill today thanks man it's really great. I didn't know I even had it as a part of my Google One plan lmfao
> > @usr_bin_roygbiv (Roy) — date: Sun Jun 07 01:14:13 +0000 2026 · url: https://x.com/usr_bin_roygbiv/status/2063429287638655216
> > most people already have or are using the google models and don't even realize it
>
> @JustJerry121 (JustJerry) — date: Sun Jun 07 01:05:54 +0000 2026 · url: https://x.com/JustJerry121/status/2063427193183838477
> A lot of "model takes" are really harness takes in disguise.
> > @usr_bin_roygbiv (Roy) — date: Sun Jun 07 01:13:48 +0000 2026 · url: https://x.com/usr_bin_roygbiv/status/2063429182370029893
> > 99% I made this post so I can just link it to people in the future.
>
> @JustJerry121 (JustJerry) — date: Sun Jun 07 04:24:48 +0000 2026 · url: https://x.com/JustJerry121/status/2063477250021065067
> That harness/model split is the part most agent discourse skips. Once tools, system prompts, compression, and MCP policy differ, you're comparing the wrapper as much as the model.
> > @usr_bin_roygbiv (Roy) — date: Sun Jun 07 04:26:12 +0000 2026 · url: https://x.com/usr_bin_roygbiv/status/2063477603390923181
> > people conflate the 3. It's the same reason apple products are so popular most people just know "computer" they don't know os, hardware, userspace etc.
>
> @_asyncio (realityserf) — date: Wed Jun 10 17:13:19 +0000 2026 · url: https://x.com/_asyncio/status/2064757817299386647
> I read this and it motivated me to try omp with Gemini 3.1 pro. I pointed it at a small-scoped task and it totally failed while Opus 4.8 with Claude Code nailed it. My prompt was underspecified because I didn't fully understand the problem, but Opus figured it out.
> > @usr_bin_roygbiv (Roy) — date: Wed Jun 10 17:14:02 +0000 2026 · url: https://x.com/usr_bin_roygbiv/status/2064757997444718638
> > gemini 3.5 is what i'm takling about through antigravity 3.1 is old now
>
> @themmyleke (Them Leke) — date: Wed Jun 10 20:19:23 +0000 2026 · url: https://x.com/themmyleke/status/2064804643687796812
> First thing to note here: how does XAI own its stack if it doesn't own either the IP for the chips it uses to train or serve models compared to Google who actually owns the architecture for TPUs. I think you are wrong here
> > @usr_bin_roygbiv (Roy) — date: Wed Jun 10 20:21:33 +0000 2026 · url: https://x.com/usr_bin_roygbiv/status/2064805189207420978
> > they physically possess gpus that they legally own. anthropic and openai rent their compute from other people
>
> @themmyleke (Them Leke) — date: Wed Jun 10 20:27:08 +0000 2026 · url: https://x.com/themmyleke/status/2064806594311807263
> Okay one more thing, what is omp? I would like to try 3.5 in it because if Gemini 3.5 is not retarded and is that fast oh my goodness
> > @usr_bin_roygbiv (Roy) — date: Wed Jun 10 20:34:38 +0000 2026 · url: https://x.com/usr_bin_roygbiv/status/2064808481354391989
> > https://t.co/bPsrLQE7zT
>
> @cpjet64 (Curt) — date: Fri Jun 12 16:31:26 +0000 2026 · url: https://x.com/cpjet64/status/2065472052127993968
> pretty decent writeup... at least you hit the nail on the head where most problems come from. i have told so many people to just make their own harness specific to their workflow to get the full power of each model and only the rare handful actually listen lol
> > @usr_bin_roygbiv (Roy) — date: Fri Jun 12 16:32:14 +0000 2026 · url: https://x.com/usr_bin_roygbiv/status/2065472252045332519
> > just use https://t.co/bPsrLQE7zT it has literally everything
>
> @bchap1n (brrrock) — date: Tue Jun 16 01:22:12 +0000 2026 · url: https://x.com/bchap1n/status/2066692786024522049
> so omp is like the California of harnesses because it has everything and is awesome.
> > @usr_bin_roygbiv (Roy) — date: Tue Jun 16 01:23:19 +0000 2026 · url: https://x.com/usr_bin_roygbiv/status/2066693070088028467
> > its the texas of harnesses
>
> @Kyle99338388 (Kyle) — date: Tue Jun 30 09:09:26 +0000 2026 · url: https://x.com/Kyle99338388/status/2071883802373497056
> I built my own agentic op system :)
> So much better than a ""harness
> > @usr_bin_roygbiv (Roy) — date: Tue Jun 30 12:34:41 +0000 2026 · url: https://x.com/usr_bin_roygbiv/status/2071935455650513398
> > no it isn't https://t.co/bPsrLQE7zT
>
> @0xZhao888 (Zhao) — date: Wed Jul 01 23:01:48 +0000 2026 · url: https://x.com/0xZhao888/status/2072455660001017962
> the california line got me lmao but yes
> > @usr_bin_roygbiv (Roy) — date: Wed Jul 01 23:06:13 +0000 2026 · url: https://x.com/usr_bin_roygbiv/status/2072456774079172961
> > hits way harder since the partnership announcement
