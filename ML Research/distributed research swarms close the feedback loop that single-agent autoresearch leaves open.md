---
created: 2026-03-13
description: A PoC extending Karpathy's autoresearch into a distributed swarm where a coordinator summarizes results and feeds guidance back to research agents, closing the feedback loop and drawing on SakanaAI's ShinkaEvolve pipeline.
source: https://x.com/bertcmiller/status/2031375618684731740
type: learning
---

## Key Takeaways

bertcmiller built a proof-of-concept that extends [[autoresearch lets an AI agent run ML experiments autonomously overnight|Karpathy's autoresearch]] from a single-agent loop into a distributed swarm. Multiple research agents independently optimize training, submit results to a coordinator, and receive synthesized guidance back — closing the feedback loop that a solo agent can't close on its own.

The results-to-summaries-to-insights-to-guidance pipeline is borrowed from SakanaAI's ShinkaEvolve, which uses evolutionary approaches to avoid local optima. This is a key design choice: always picking the "best" result greedily can get stuck, so an evolutionary selection strategy could yield better long-term outcomes.

A critical open question is trust and identity in open swarms. In a closed system you control whose results influence your agent. Opening it up requires some form of agent reputation or identity — the equivalent of weighing a colleague's input by their track record. Without this, a median random contributor's noise could degrade the swarm's optimization.

Future directions include improving code selection for optimization (evolutionary over greedy), giving agents visibility into peers' active experiments to reduce duplicated effort, and scaling to see what breaks at larger compute budgets.

## External Resources

- [bertcmiller's swarm PoC code](https://t.co/CqgBEVTSNy) — the implementation referenced in the thread
- [Karpathy's original autoresearch tweet](https://x.com/karpathy/status/2030705271627284816) — the vision of massively collaborative async agent research (SETI@home style)
- SakanaAI's ShinkaEvolve — evolutionary approach to research agent guidance pipelines

## Original Content

> [!quote]- Source Material

> **@bertcmiller** · Tue Mar 10, 2026 · ♡ 6
>
> Here's a PoC of a swarm:
> - Distributed research agents optimizing training
> - Training results submitted to a "coordinator"
> - Coordinator summarizes results and provides guidance to research agents, closing the feedback loop
>
> Link below! https://t.co/gg2nuUQXJy
>
> *Swarm architecture diagram*
> ![[bertcmiller-731740-001.jpg]]
>
> QT @karpathy:
> The next step for autoresearch is that it has to be asynchronously massively collaborative for agents (think: SETI@home style). The goal is not to emulate a single PhD student, it's to emulate a research community of them.
>
> ---
>
> **@bertcmiller** · Tue Mar 10, 2026
>
> Main diffs between this and what I think @karpathy envisioned are:
> - It's a closed system. Not on Git.
> - It closes the feedback loop, so that agents' results turn into guidance that influences their next optimization attempts.
>
> ---
>
> **@bertcmiller** · Tue Mar 10, 2026
>
> The pipeline of: results -> summaries -> insights -> guidance comes from @SakanaAILabs and their ShinkaEvolve. I think it applies well here!
>
> Also, I chose a closed system because I didn't see a way to solve the problem of how to choose whose results you listen to in order to influence your own agent's optimizations.
>
> Yes, you can trust what Karpathy posts on Github, but can you trust the median random person? In real life you'd weigh their input given your context, relationship, their background, etc. Perhaps we need some agent identity or reputation equivalent here?
>
> ---
>
> **@bertcmiller** · Tue Mar 10, 2026
>
> Anyway some code here:
> https://t.co/CqgBEVTSNy
>
> Some directions to explore imo:
> - Improve how code is selected to be optimized. Always choosing the best probably leads to local optima. Could use an evolutionary approach (a la Shinka)
> - Give researchers visibility into what their peers are actively doing or some way to coordinate experiments, otherwise you get repetition and that wastes effort
> - Scale it up and see what breaks (anyone got some H100s laying around :)?)
> - Explore how to open this up to more parties

[Source](https://x.com/bertcmiller/status/2031375618684731740)
