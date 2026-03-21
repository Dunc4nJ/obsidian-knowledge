---
created: 2026-03-20
description: Framing auto-research as a multi-player game where an Eval Agent and Optimizer compete in a GAN-like loop, with curriculum learning to prevent reward hacking.
source: https://x.com/Vtrivedy10/status/2034802115021840829
type: synthesis
---

## Key Takeaways

The core idea is structuring automated research as a **generative adversarial loop** between two agents: an Eval Agent that designs progressively harder evaluations, and an Optimizer that hill-climbs against them. This mirrors GAN dynamics — the generator (Optimizer) improves while the discriminator (Eval Agent) raises the bar. A separate Judge gates acceptance to catch [[intelligent AI delegation requires trust accountability and adaptive monitoring not just task decomposition|reward hacking]], which is flagged as the hardest unsolved piece.

The follow-up thread adds a **curriculum learning** angle: treat each new set of evals as a curriculum stage. As the Optimizer saturates a difficulty level, the Eval Agent adapts — creating an easy-to-hard progression that maps to composable skill acquisition along the current learnable frontier. This connects to ideas in [[MemSkill learning and evolving memory skills for self-evolving agents|self-evolving agent memory]], where agents consolidate experience into reusable principles.

The discussion highlights a real tension: multi-agent game-theoretic optimization is powerful for forcing robustness, but reward design is critical. The expectation is that agents will find adversarial exploits — one agent may "nuke the setup" — and that's partly the point. The adversarial pressure is what drives genuine capability rather than metric gaming.

Community replies suggest extending this to personal game-theory boards where each player runs its own auto-research loop before each turn, and using self-awareness as the feedback signal for eval design iteration.

## External Resources

- [Original thread by @Vtrivedy10](https://x.com/Vtrivedy10/status/2034802115021840829) — the multi-player auto-research game concept
- [Curriculum learning follow-up](https://x.com/Vtrivedy10/status/2034862482750095666) — adding curriculum and composable skills angle
- [@saxenauts reply with game-theory board demo](https://x.com/saxenauts/status/2034816933502361818) — extending to personal game-theory boards with bounded auto-research loops

## Original Content

> **@Vtrivedy10 (Viv)** — Mar 20, 2026 · 24 likes · 1 RT · 3 replies
>
> idea for one of these nights: 
> auto-research as a multi-player game
>
> - Eval Agent generates a set of evals for user specified goal
> - Optimizer hill climbs evals until threshold reached
> - Optimizer acceptance is gated by "number go up" + Judge that tries to prevent reward hacking (this is hard)
> - Once threshold passed, Eval Agent generates harder evals
> - Loop
>
> - Evals are a grounded way of adapting agent behavior
> - Getting agents to not reward hack is very hard, I'm curious to see 
> - Reward design is really important, the above isn't perfect.  I imagine I'll see some behavior where one agent adversarially nukes the setup
>
> but still optimization with multi-player games, self-play, etc is interesting

> **@Vtrivedy10 (Viv)** [Quote Tweet] — Mar 20, 2026 · 15 likes · 2 RT · 1 reply
>
> hmmm there's also a nice curriculum learning angle
>
> - treat additional evals as curricula 
> - Eval Agent should adapt evals as Optimizer saturates them 
> - Easy to Hard learning, Composable skills over time based on current learnable frontier
>
> lots of actual research mental models map onto multi-player auto-research
>
> this sounds fun enough to have codex take a crack

---

**Replies:**

> **@mstockton (Matt Stockton):**
> @Vtrivedy10 I'm just forwarding this tweet to my OpenAutoResearchClaw and I will let you know what happens

> **@Vtrivedy10 (Viv):**
> @mstockton 🐐 excited to see this either create AGI or some hilarious adversarial reward hacking
> also "OpenAutoResearchClaw" is 🔥

> **@saxenauts (utkarsh):**
> or how about autoresearch on your personal game theory board with autoresearch happening for all players in the game before each turn is played and every agent ready, bounded loop ofc, but I ask it to update its own validation skill.
> designing eval is one thing, so I just iterate with my own awareness as feedback.

> **@Vtrivedy10 (Viv):**
> @saxenauts 😦 does this work?

> **@MingtaKaivo (Mingta Kaivo 明塔 开沃):**
> @Vtrivedy10 Multi-agent game theory reward hacking — this is how we force robustness. Elegant.

[Source thread](https://x.com/Vtrivedy10/status/2034802115021840829)
