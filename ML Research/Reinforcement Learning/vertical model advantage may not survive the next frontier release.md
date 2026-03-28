---
created: 2026-03-28
description: Vertical AI companies shipping fine-tuned models face a recurring cycle where frontier model releases erode post-training advantages, making the durability of vertical model moats uncertain.
source: https://x.com/JayaGup10/status/2037627844571045989
type: synthesis
---

## Key Takeaways

The central tension in the vertical model debate is whether domain-specific post-training creates durable advantage or merely temporary positioning that resets with each frontier release. Jaya Gupta frames this as a cycle: AI-native apps disrupt legacy SaaS, frontier labs leapfrog the AI apps, then vertical fine-tunes outperform the frontier at specific tasks — and the loop repeats. This resonates with how [[cursor composer 2 uses continued pretraining and RL to build a production coding model]] — Cursor's investment in Composer 2 is exactly the kind of bet whose durability this thread questions.

The flywheel argument is compelling on paper: millions of interactions generate proprietary evals, which train better models, which produce better outcomes, which generate more data. The moat is the eval infrastructure and accumulated data, not the weights themselves. Intercom's Apex replacing Sonnet 4.0 with a 22% reduction in unresolved conversations is one of the cleaner examples. But the attribution problem is real — isolating post-training impact from harness improvements, retrieval, and prompt engineering remains unsolved.

The economics cut against durability. Each training run must be amortized before the next retrain, and if the window between frontier releases keeps shrinking, the math deteriorates. This connects to the broader question of where value accrues in the stack — [[a purpose-trained 20B search agent matches frontier models at 10x less cost by self-editing its context]] shows that smaller specialized models can match frontier performance, but the thread asks whether that advantage persists across model generations.

Three competing explanations for the current wave: narrative positioning (every company needs a moat story), a genuine inflection where pre-training commoditizes and frontier improvements plateau, or demand-side pull from cost/latency/compliance constraints at scale. The honest question is which explanation dominates. If it's mostly narrative, the wave recedes with the next frontier release. If it's structural demand, vertical models persist regardless.

The thread also highlights a dependency risk: if your strategy is fine-tuning on open-weight models, you're betting on continued improvement from Meta and Chinese labs like DeepSeek — a supply chain with obvious regulatory and geopolitical risk. This tension between [[mid-training builds the reasoning foundation that RL amplifies not replaces]] and pure post-training approaches suggests the most durable strategies may combine multiple training stages rather than relying on fine-tuning alone.

## External Resources

- [Intercom Fin Apex](https://www.intercom.com/) — Intercom's custom model replacing Sonnet 4.0 for customer service resolution
- [Cursor Composer 2](https://cursor.com/) — Cursor's in-house coding model shipped alongside frontier options
- [Cognition SWE 1.5](https://cognition.ai/) — Cognition's specialized software engineering model

## Original Content

> @JayaGup10 — 2026-03-27
>
> Article: The Half-Life of a Vertical Model?
>
> There's a strange dynamic playing out in AI right now. An AI-native app disrupts a legacy SaaS company. A frontier lab releases a new model and leapfrogs the AI app. Then a SaaS company with a vertical model outperforms the frontier lab at the specific job. And so it goes — each layer of the stack keeps eating and getting eaten, and nobody stays on top for long.
>
> This week, the conversation around specialized models and the economics of post-training has exploded. Seemingly overnight, every serious vertical AI company shipped or announced their own model: Cognition with SWE 1.5, Cursor with Composer 2, Decagon with an unnamed model, Hippocratic with Polaris 3, Intercom with Fin Apex 1, EvenUp with Piai.
>
> The bull case, as these companies tell it: General-purpose models are simultaneously over-serving verticals — more raw intelligence than customer service or code review actually needs — and under-serving them, not tuned for the domain-specific qualities that matter for the job. Tone. Judgment. Attentiveness. Task completion. Domain-specific post-training on proprietary evals closes that gap, and it closes it fast!
>
> Intercom just shipped Apex, replacing Sonnet 4.0 as Fin's core answering model. One gaming customer saw resolution rates jump overnight from 68% to 75% — a 22% reduction in unresolved conversations from a single model swap. They've never seen a jump that large. Importantly, this is not a "save money" story. It's a "better results" story. Faster, fewer hallucinations, and cheaper but the lead pitch is performance, not cost. (this used to be more cost)
>
> And the flywheel story is real. Millions of interactions become proprietary evals, which train a fine-tuned model, which produces better resolutions, which generates more data, which sharpens the evals. The moat isn't the model weights. It's the eval infrastructure and the proprietary data underneath aka the accumulated record of what worked and what did not.
>
> The bear case, as the naysayers see it: The hard part isn't building a better model. It's staying better + It's keeping it better. What's the half-life of the advantage? If the next frontier release leapfrogs your fine-tune in three to six months, and retraining takes two to three, you're running in place. Every company that claims "we trained our own model" has to answer a harder question: will it still be better next month?
>
> This has actually happened multiple times in the last few years after the models get closer to the application layer. Waves of companies announce their own fine-tuned models, and every single time, the next frontier update wipes out the advantage. So when six companies ship vertical models in the same week, you have to ask why now — and whether this time is actually different.
>
> I can think of three competing explanations. First, narrative positioning: everyone needs a moat story — not just for investors, but for customers evaluating vendors, for employees deciding where to work, for the market at large. "We trained our own model" is the most compelling version of that story right now.
>
> Second, a genuine inflection point in the underlying technology. Pre-training is increasingly commoditized and frontier model improvements are plateauing. The open-weight base models and post-training tooling have gotten good enough that the gap between a fine-tuned vertical model and the frontier is narrow enough for domain-specific training to close it. If the frontier isn't pulling away as fast as it used to, the post-training advantage has a longer shelf life.
>
> Third, demand-side pull. Companies running these models at scale, millions of API calls a month, are hitting real constraints: latency requirements for real-time customer interactions, cost structures that don't work at volume, compliance and data residency needs that require running models in their own infrastructure. When you're spending seven figures a year on API calls and your SLAs depend on response time, "good enough and within our control" starts winning over "best available but dependent on someone else's infrastructure and pricing."
>
> The honest question is how much of this wave is really the first explanation versus the third. If it's mostly narrative positioning, the wave recedes with the next frontier release. If customers are genuinely changing procurement behavior because of cost, latency, and control at scale, that's structural demand that persists regardless of what the labs ship.
>
> Even if the thesis is right, there's an attribution problem the clean flywheel narrative glosses over. Intercom's 68% to 75% resolution rate jump is one of the cleaner before-and-after examples out there. But for most businesses, isolating the impact of post-training from everything else in the system — the harness, the retrieval, the prompt engineering, the product changes shipping alongside it — is genuinely difficult. Realistic benchmarks that connect model improvement to business outcomes are still an unsolved problem. The "better results" pitch is compelling in specific cases, but harder to verify broadly than the narrative suggests.
>
> Then there's the economics. Every training run has to be amortized across the window before you retrain. Cursor has to pay off Composer 1 in the period between its launch and the Composer 2 release. If that window keeps shrinking as base models improve, the math gets worse, not better. And when you retrain on the next open-weight base — does any of the initial post-training investment transfer? Maybe the data doesn't need reprocessing, but it's unclear whether training is cheap enough yet for this to be dismissible. If Opus 5 is substantially better than the current open-weight options, does the fine-tuned model become obsolete? The cost of the training run doesn't disappear just because the model did.
>
> Cursor is an interesting case to watch here. They shipped Composer 2 with sizeable revenue and real product love. The open question is whether users actually adopt the in-house model for their core workflows or default to frontier options when it matters most. That answer will tell us a lot about how durable the vertical model advantage really is in practice.
>
> I think we've seen this movie before. Fine-tuning has come in and out of favor multiple times over the past few years. Every time the frontier models pull ahead, the narrative shifts to "just use the best model and build around it." Every time the gap narrows — DeepSeek isn't bad, Kimi isn't far behind — the narrative swings back to "open-weight plus post-training is the way." A few months ago, fine-tuning was extremely out of fashion. Now it's the hottest strategy in the industry again (is it for the month or is it structural?). The pendulum has a short arc.
>
> And if your strategy is "fine-tune on open-weight models," you're implicitly betting on the continued improvement and availability of base models from Meta & other open source friends, which at this point, God knows WHAT Alex Wang and Zuck are doing? OR Chinese labs like DeepSeek & friends, which face obvious regulatory and supply chain risk. That's a shaky foundation for a multi-billion dollar company!
>
> Meanwhile, there's the counter-position: sophisticated prompting, retrieval architectures, agentic systems, and evals layered on top of whatever the best frontier model is at any given moment. Each new model generation makes those techniques more powerful. You surf on top of the LLM waves, not against them. And you never find yourself defending a depreciating asset.
>
> The honest answer is it's probably not either/or???? The custom model is an additional layer of advantage, not a replacement for product and systems work. Intercom's Fin engine was already a sophisticated multi-model system before Apex (from the blogs I saw) The custom model sits on top of all of that. But the layer alone doesn't constitute a moat - it has to be the kind of layer that widens with each iteration regardless of which base model sits underneath.
>
> Will there be vertical models, or will the big labs engulf it all? Or will there always be harnesses that allow vertical models to outperform generic ones? Customer service — where data is abundant, tasks are well-defined, and resolution outcomes are clearly measurable — may be one of the better domains for this bet. Verticals where evals are fuzzier and data is sparser will be much harder to defend.
>
> "We trained our own model" is becoming the new "we have a data moat." Every company is starting to claim it. Very early signs or any proof that it's durable yet. So the question worth sitting with: are we watching the emergence of genuinely new platform companies with compounding intelligence — or are we watching the latest turn of a cycle that resets every time the labs ship a new frontier model?
>
> Engagement: 125 likes | 20 retweets | 19 replies
> [Original post](https://x.com/JayaGup10/status/2037627844571045989)
