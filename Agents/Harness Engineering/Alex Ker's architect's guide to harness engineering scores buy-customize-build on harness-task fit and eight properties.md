---
created: 2026-07-14
description: Alex Ker's decision framework for choosing, customizing, or building an AI agent harness — buy-vs-customize-vs-build by role, three composability categories, two fit questions (harness-task fit and fluency) diagnosed by eight timeless properties, and a future of dynamic model routing plus performance-aware serving folded into the harness.
source: https://x.com/thealexker/status/2076741193367761378
type: framework
---

## Key Takeaways

- Buy/customize/build splits by role, not preference. Non-engineers (GTM, ops, most knowledge workers) should *buy* the best AI-native app (Harvey for legal, Clay for GTM, Descript for video) and focus on being good context engineers, because maintaining evals and guardrails is infeasible for an end-user. Engineers get bring-your-own-model setups and should learn harness internals to take high-leverage actions. Only frontier teams with real user trajectories plus evals should post-train/fine-tune a harness jointly with a model (Cursor, OpenCode) — everyone else should exhaust out-of-the-box and customization first. This is the buyer-side complement to [[Shortcut beats Claude for Excel with a leaner vertical harness, model-slinging, and a real-workflows-to-benchmarks loop]].
- Harnesses fall into three categories by composability: Frameworks/SDKs (Vercel AI SDK, Anthropic Agent SDK, Mastra — building blocks, "Django doesn't give you an app"), Extensible (Pi, Deep Agents — base tool-loop only, the vanilla vim/emacs of harnesses, per [[coding agents should be personal canvases not uniform tools]]), and Turnkey (Claude Code, Codex, Cursor agent, OpenCode — batteries-included, often proprietary). Pick the category before the product.
- Harness choice reduces to two questions: harness-task fit (is it post-trained with the models/tools you need, at the right abstraction?) and fluency (can you actually drive it?). The fit question is diagnosed by eight timeless properties — context/state, memory, MCP/tool support, standard adherence, model-selection flexibility, remote access, observability, and hackability — offered as questions rather than recommendations because harnesses change weekly. The fit question is why [[Model-Harness-Fit means tool surfaces and citation tags are post-trained into the model, not interchangeable]] and why [[agent harnesses are the product not the model]].
- The hackability property is the opinionated-vs-composable tradeoff, and it's the key question for a technical decision-maker choosing for a team. Opinionated harnesses (Copilot) have less friction and easier enterprise adoption but stifle creativity; highly malleable ones (OpenClaw) have uncapped ceilings but security and token-consumption pitfalls. The sweet spot: failure troughs that aren't critical, productivity ceiling as uncapped as possible — the same thin-vs-thick-as-a-slider idea as [[iii engine decomposes the agent harness into fourteen swappable workers on a shared bus making thin-versus-thick a config slider not a framework fork]].
- The future is dynamic model routing folded into the harness as table stakes: a lightweight classifier routes each task to a cheap OSS default, a latency/throughput-tuned fine-tune, or a frontier closed model for review passes — cache-aware so model switches don't cost warm-cache hits, with read-only research handed to smaller/faster subagents that also fight context rot through modularization (OOP-style encapsulation). Serving is part of harness-task fit: BYO-model or self-hosting is how you control caching, batching, rate limits, and uptime, exactly what [[LangChain Deep Agents adds per-model harness profiles because each provider's prompting guide demands different tools and middleware]] operationalizes.

## External Resources

- [How to optimize your harness](https://x.com/thealexker/status/2045203785304232162) — Ker's earlier companion article on maximizing your experience inside an existing harness through context engineering.
- [Smart zone / dumb zone (AI Hero)](https://www.aihero.dev/ai-coding-dictionary/smart-zone) — definition of the degraded "dumb zone" agents fall into after too many failed recovery loops and compactions.
- [LangChain Harness Profiles](https://x.com/Vtrivedy10/status/2049535740233523600) — Viv Trivedy's declarative per-model harness override layer, cited as the mechanism for choosing the best model-harness combination per task.

## Original Content

> @thealexker (Alex Ker) — 2026-07-13
>
> *Article hero: a minimalist architectural elevation of layered, interlocking structures wired together with fine connecting lines — the "architect's guide" motif*
> ![[thealexker-761378-001.png]]
>
> **Article: The architect's guide to harness engineering: How to choose or build the one for you.**
>
> "We shape our tools, and thereafter our tools shape us." – McLuhan. The next generation of trillion-dollar opportunities will come from choosing the best model for your harness, and the best harness for your model. Models and harnesses need co-optimization and co-evolution.
>
> We've seen firsthand how frontier teams at OpenEvidence, Notion, and Cursor mold and deliver intelligence to doctors, thinkers, and developers. But as an individual or organization, choosing or customizing a harness is personal and situational; it's often a topic of endless debate amongst the frustration of choice paralysis.
>
> So we wrote a guide to help you think through this decision of choosing your AI harness. We start from the practical question of which harness fits your role. Then, from first principles, we discuss the must-have primitives behind what makes a harness useful, presenting a framework that you can use to evaluate if simply a vanilla option will suffice, or if it's worth investing in your own bells and whistles. Finally, we wrap up with some musings on where we think harness engineering is heading, so you can build with those constructs in mind.
>
> ## Buy, customize, or build?
>
> Non-Engineers (GTM, Ops, most knowledge workers):
>
> You probably shouldn't customize your harness… most of the time. You should be focused on finding and buying the best harness. Identify the best AI-native applications (Harvey for Legal, Clay for GTM, Descript for Video), learn the constraints and strengths, understand how their scaffolding plugs into your workflow and removes part of the work.
>
> This is because out-of-the-box, less customized experiences provide strong guardrails to prevent degenerate behaviors in sensitive, mission-critical use cases. And constantly gathering and maintaining your evals is infeasible for you as the end-user. The central focus is populating these existing harnesses with the right context, meaning your real job is to be a good context engineer. I've suggested some things to maximize your experience inside the harness in a previous how to optimize your harness [article](https://x.com/thealexker/status/2045203785304232162?s=46&t=qLTUK63eMdrw2KTz3cCnrg).
>
> Engineers (including the non-technical, technical tinkerers):
>
> Here the picture is completely different. The bring-your-own-model setup lets you use a mix of frontier open-source, closed, or even self-hosted models to run harnesses that are both performant and cost-effective. As we move towards a world with long-running and self-managing (i.e. autoresearch) agents, you can spin up subagents in parallel to handle both high-quality deep work and frequent, routine, shallow work.
>
> To get the most out of the harness, you will want to understand how harnesses work under the hood, so you can take the highest leverage actions.
>
> Generally, if you catch error cases or rough edges, you can document them in a file so as to prevent the harness from falling to the same pitfalls and recovery loop, which is a reason behind frequent compactions as well as entering the "[dumb zone](https://www.aihero.dev/ai-coding-dictionary/smart-zone)". Repeated operations like grep and explorations can be avoided if you encode the structure of a huge codebase into a .md file at the root of the codebase and instruct the harness to look there first. Unused tools can be disconnected to save additional context windows. By doing these practices, you are effectively polishing the final mile performance of the harness, systematically reducing the probability of slop generated and saving on tokens for computations where they are needed.
>
> To take it a step further, if you have a set of user trajectories and a set of evaluations of what "good" looks like, consider post-training or fine-tuning a harness jointly with your model to produce the optimal outputs. For example, in coding, teams like Cursor and OpenCode have created harnesses optimized for specific models oriented against evaluations. That involves shaping system prompts, tool formats, etc., according to online and offline metrics to maximize user delight and retention. In enterprise, RL and SFT are the start of building a differentiated intelligence and moat. But since this is the frontier, most teams are not here by definition and don't need to be. Exhaust the out-of-the-box and customization approaches first.
>
> ## Properties of a useful harness
>
> In general, when we're talking about harnesses, we think there are 3 categories of harnesses (from least to most composable). Depending on your use case, you will likely want to focus on one category over another:
>
> 1. Frameworks and SDKs: These are for building harnesses. Similar to how Django doesn't give you an app, but instead the building blocks for building an app. Examples include Vercel AI SDK, Anthropic Agent SDK, and Mastra.
>
> 2. Extensible: Ship with few to no built-in features beyond the base tool-use loop. Analogous to vanilla emacs or vim in the text editor space. Pi and Deep Agents are the best examples in this category.
>
> 3. Turnkey: Batteries-included harnesses with lots of features, often tied to paid or proprietary APIs. This category includes OpenCode, Codex, Claude Code, and Cursor agent.
>
> To think about what harness to use, we can reduce it down to two main components:
>
> 1. Harness-task fit. Is it post-trained with the models and tools you need? Does it offer the right features and level of abstraction for what you're trying to do?
>
> 2. Fluency. Is it a harness you actually know and understand how to drive?
>
> The eight properties that follow are the diagnostic for question one. There are no concrete recommendations here. As harnesses are updated weekly, we focus on timeless principles instead. Score your candidate against these eight; the gaps tell you whether vanilla is sufficient or you need to build. Read them as questions to ask yourself. Overall, they cluster into how the harness manages context, how it connects to the outside world, and how it behaves in production.
>
> Context and State (within a task)
>
> - Does the harness maintain stateful context across turns? How does it handle interruptions and continuations? What's the compaction mechanism over long horizons, how lossy is it, and can you mitigate that? How does it spin up subagents to fight context rot? Can it parallelize workstreams, whether interwoven or independent?
>
> Memory (across tasks)
>
> - What persists between sessions, and how — local cache, database, or remote? When is that memory retrieved and used?
>
> MCP/Tool Support
>
> - Does the harness have an extensible integration with Model Context Protocol servers? For example, can it be configured to be enriched with Clay data, to output directly to Grafana dashboards, or to ingest from your Notion pages? How faithfully does it interact with other applications? How does the harness let the model take actions? Is it compatible with your desired group of tool calls?
>
> Standard Adherence
>
> - How much does the harness follow an open spec vs. a proprietary structure? OpenCode relies on an SQLite store and open conventions for where tools, MCPs, and skills get installed; Claude Code uses a Claude-specific structure (claude.md, a dedicated Claude directory, its own way of structuring session history in files). Open standards mean portability and less lock-in; proprietary structures can mean tighter integration but harder migration if you decide to share context across harnesses.
>
> Model Selection Flexibility
>
> - How easy is it to try new model endpoints? Can you easily override settings, config files, and environment variables to point to non-native endpoints? As new cutting-edge open source models are released every month, can you try them out in your existing harness setup, or do you need to try them in a different harness? Do all models work equally well in the harness?
>
> Remote Access
>
> - Can you access sessions remotely? Does the harness have built-in features (e.g. Claude Code's /remote-control), or do you need to install a third-party or community-sourced plugin or wrapper? Will the session still be accessible if you close your laptop?
>
> Observability/Debugging Surface
>
> - How is logging and tracing tracked? Can you catch failure modes when something breaks? Is there an early signal when it's heading the wrong way? Does the harness have operations that let you roll back to an earlier state and course-correct, or, better yet, can it fix itself if it lands in a bad state?
>
> Hackability Spectrum
>
> - This is the key question to ask if you are a technical decision-maker making a harness decision for your team or company.
>
> - You can also see this as the opinionated vs. composable tradeoffs. If a harness has more opinions, it will likely have less friction and will be easily adopted in enterprise—think Copilot. But if it is not opinionated and highly malleable, there are many ways to push the harness to its potential, but also run into pitfalls (like security vulnerabilities and extreme token consumption)—think OpenClaw.
>
> - If you live in a mature organization, finding an opinionated option with guardrails for your team is the way to go, even though it will inevitably stifle some creativity. The sweet spot is finding and/or customizing a harness where the troughs of failure are not critical, but the ceiling of productivity is as uncapped as possible. The composable and hackable harness will empower you, the user, to smooth out what's not working instead of waiting for the harness maintainer to maybe make that change, upstream.
>
> ## The future
>
> As we phase out of the era of prototyping with intelligence and into years of pushing AI across different contexts in production, the hallmark of this shift is a harness that can support, route, and orchestrate many models. Whether you're an individual, a team adopting a standardized harness, or even a company creating a new one, it comes down to two linked decisions: how you route and how you serve.
>
> Routing across subagents
>
> Karpathy noted that one quirk of LLMs is their jagged edges of intelligence. They might be superhuman in some domains while fumbling hard in others. So the corollary to this is that specialization will become the dominant paradigm: it makes sense to employ multiple models and route each task to the appropriate model using independent subagents.
>
> An increasingly common and strategic pattern is creating dynamic routing inside the harness: have a lightweight classifier to decide if you should route to good open-source defaults to save on costs, a fine-tuned model that maximizes performance metrics such as latency or throughput, or a frontier closed model for a review pass. It's important to keep an eye on cache reuse. Within a multi-turn session, routing to different models can incur a cache hit. For optimal speed and cost, the harness architecture should also be cache-aware, such that requests hit the warm cache associated with a given model whenever possible.
>
> For read-only tasks like investigations or research, subagents can use smaller, faster models. This subagent (or many copies) can be spun up to handle focused, parallelizable tasks, like reading from many sources and collating information on a topic. We see the setup of this subagent layer also being beneficial for modularization. Just like object-oriented programming oriented itself around classes and encapsulation, subagents are a pattern that increases efficiency and compartmentalizes work. And since context rot is one of the primary causes of degradation in output quality and hallucination, operating many models independently will keep the context clean.
>
> Serving for performance
>
> Once routing is in place and each workload is matched to the right kind of intelligence, the performance of the models themselves is tied directly to user experience. The experience is determined by the infrastructure around the inference itself.
>
> It's not only important to choose the right harness but equally critical to choose the right model for agentic use cases that meet your requirements. For example, GLM 5.2 is a stellar candidate for both quality and performance. Additionally, the bring-your-own-model harness, or a proxy, gives you the flexibility to choose the best model-harness combination for tasks. Our friends at LangChain have created Harness Profiles specifically for this purpose that you can read about [here](https://x.com/Vtrivedy10/status/2049535740233523600).
>
> The principle worth keeping regardless of vendor: performance is part of harness-task fit, and BYO-model is how you control it. If you need guaranteed rate limits, burst handling, and uptime, hosting your own open or custom models is how you get there. Dedicated infrastructure is what lets you control caching, batching, and disaggregation to squeeze out responsiveness without giving up quality. We expect mature builders to serve harnesses with performance in mind and continue to find ways to optimize along this vector.
>
> ## Final thoughts
>
> Harnesses are not a one-size-fits-all solution and should not be treated as such. We walked through how to approach harness engineering from both the technical and non-technical sides: when to buy, when to customize, and when to build from scratch.
>
> Rather than concrete recommendations that will age poorly as harnesses are added and deprecated, we shared a set of timeless questions to help you understand and guide your decision. To a large extent, the best harness properties will be standardized, and eventually commoditized, which makes all harnesses intuitive to use. And my bet is that routing the intelligence towards the right models and having performant inference will fold into the harness itself and be table stakes as it evolves.
>
> The takeaway should be to choose your non-negotiables (e.g. strong compaction because you have huge contexts, operability across multiple models, remote access, etc) and become fluent at using one particular harness. And with fluency come the ways to fork, modify, or command the harness to do precisely what you want.
>
> Engagement: 237 likes | 31 retweets | 11 replies
> [Original post](https://x.com/thealexker/status/2076741193367761378)
