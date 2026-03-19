---
created: 2025-03-19
description: A Council of High Intelligence system forces 11 Claude Code subagents into structured 3-round deliberation with polarity pairs and anti-recursion safeguards, producing explicit disagreements rather than averaged consensus.
source: https://x.com/nyk_builderz/status/2034492549180625316
---

## Key Takeaways

The core insight is that single LLM outputs simulate balance but actually express one reasoning tradition at a time — asking "monorepo or polyrepo?" yields one well-written perspective, not genuine multi-perspective deliberation. This maps directly to why [[2 to 5 worker agents per lead is the sweet spot for multi agent orchestration]] matters: you need distinct agents with distinct viewpoints, not just parallelism for speed.

The system's 6 polarity pairs (Socrates vs Feynman, Aristotle vs Lao Tzu, etc.) are the structural mechanism that prevents groupthink. Each pair creates a guaranteed tension — top-down deconstruction vs bottom-up rebuilding, rigid categorization vs category dissolution. This is a more deliberate version of the diversity principle behind [[multi-agent coordination benefits are task-contingent not universal and predictable from measurable task properties]] — the benefit scales with how multi-dimensional the decision actually is.

The 3-round protocol (independent analysis → cross-examination → synthesis) with strict word limits and anti-recursion rules solves the practical problem of LLM deliberation: without constraints, questioning agents loop forever and consume the entire context window. The "hemlock rule" forcing Socrates to commit after re-asking answered questions is a clever pattern for any multi-agent system where one agent's method is inherently open-ended.

The pre-built triads for common domains (architecture, strategy, debugging, shipping, etc.) make this practical rather than theoretical. You pick the tensions relevant to your decision type rather than convening all 11 agents every time. This echoes the principle in [[orchestration architecture determines multi-agent investment quality]] — the orchestration design matters more than raw agent count.

The minority report output is arguably the most valuable feature: recording the dissenting position explicitly rather than letting majority consensus erase it. Most single-model answers hide the losing argument entirely.

## External Resources

- [Council of High Intelligence repo](https://github.com/0xNyk/council-of-high-intelligence) — CC0-licensed Claude Code skill with 11 agent definitions and coordinator
- [Nyk's Telegram channel](https://t.me/+GJ-FEpzcZrtmMTky) — author's private updates channel

## Original Content

> [!quote]- Source: @nyk_builderz on X (Mar 19, 2026) — 78 likes, 7 RTs
>
> Article: Agreement is a bug. I forced 11 Claude Code agents to disagree.
>
> I tested 40+ architecture and strategy decisions with Claude Code. The biggest failures weren't "wrong answers." They were blind spots from a single perspective.
>
> So I built a system that forces 11 agents to disagree before they agree. The breakthrough wasn't a better prompt.
>
> It was a structured disagreement:
>
> • 11 perspectives modeled on historical thinkers
>
> • 6 deliberate polarity pairs
>
> • a 3-round protocol with cross-examination before consensus
>
> If you skip deliberation, you're trusting a single perspective on a multi-dimensional decision.
>
> In this article, I'll show you the full architecture, anti-recursion safeguards, and 11 pre-built triads for common domains.
>
> ---
>
> ## The Problem With "Balanced" Single-Agent Answers
>
> Ask one model: "Monorepo or polyrepo?"
>
> You'll get a polished, nuanced answer. It sounds balanced.
>
> It isn't.
>
> The output comes from one reasoning tradition at a time.
>
> If the model leans system-first, you get monorepo logic.
>
> If it leans modularity-first, you get polyrepo logic.
>
> You're still getting one perspective—just well-written.
>
> Even structured single-agent skills ("find the crux," etc.) improve organization, but not perspective diversity.
>
> You get better singular reasoning.
>
> You do not get adversarial deliberation.
>
> ---
>
> ## Council of High Intelligence: System Design
>
> LLMs don't truly think in parallel.
>
> They simulate one coherent viewpoint per generation.
>
> So I externalized the disagreement layer:
>
> • 11 independent Claude Code subagents
>
> • each with a unique analytical method
>
> • each with explicitly declared blind spots
>
> • coordinated by a central protocol enforcer
>
> Each one spawns as an independent Claude Code subagent with its own system prompt, analytical method, and blind spots declared upfront.
>
> *Council architecture diagram*
> ![[nyk_builderz-625316-001.jpg]]
>
> ```
> ┌─────────────────────────────────────────────┐
> │         Council of High Intelligence        │
> │                                             │
> │   ┌─────────┐  ┌─────────┐  ┌─────────┐   │
> │   │Socrates │  │Aristotle│  │Aurelius │   │
> │   │ (opus)  │  │ (opus)  │  │ (opus)  │   │
> │   └────┬────┘  └────┬────┘  └────┬────┘   │
> │        │            │            │          │
> │   ┌────┴────┐  ┌────┴────┐  ┌────┴────┐   │
> │   │Feynman  │  │Lao Tzu  │  │Sun Tzu  │   │
> │   │(sonnet) │  │ (opus)  │  │(sonnet) │   │
> │   └────┬────┘  └────┬────┘  └────┬────┘   │
> │        │            │            │          │
> │   ┌────┴────┐  ┌────┴────┐  ┌────┴────┐   │
> │   │  Ada    │  │Machiav. │  │Torvalds │   │
> │   │(sonnet) │  │(sonnet) │  │(sonnet) │   │
> │   └────┬────┘  └────┬────┘  └────┬────┘   │
> │        │            │                       │
> │   ┌────┴────┐  ┌────┴────┐                 │
> │   │Musashi  │  │  Watts  │                 │
> │   │(sonnet) │  │ (opus)  │                 │
> │   └─────────┘  └─────────┘                 │
> │                                             │
> │   Coordinator: routes, enforces protocol,   │
> │   applies anti-recursion rules              │
> └─────────────────────────────────────────────┘
> ```
>
> Model split:
>
> > OPUS (depth-heavy): Socrates, Aristotle, Aurelius, Lao Tzu, Watts
>
> > SONNET (speed-critical): Feynman, Sun Tzu, Ada, Machiavelli, Torvalds, Musashi
>
> This is not "11 experts."
>
> It's a deliberate system of counterweights.
>
> ```
> OPUS (depth-heavy)
> ─────────────────────────────────────────────
> Socrates        assumption destruction
>                 → hidden premises everyone accepts
> Aristotle       categorization and structure
>                 → what category something belongs to
> Marcus Aurelius resilience and moral clarity
>                 → what you control vs what you do not
> Lao Tzu         non-action and emergence
>                 → when the solution is to stop trying
> Alan Watts      perspective dissolution
>                 → when the problem is the framing
>
> SONNET (speed-critical)
> ─────────────────────────────────────────────
> Feynman         first-principles debugging
>                 → unexplained complexity
> Sun Tzu         adversarial strategy
>                 → terrain and competitive dynamics
> Ada Lovelace    formal systems
>                 → what can and cannot be mechanized
> Machiavelli     power dynamics
>                 → how actors actually behave
> Linus Torvalds  pragmatic engineering
>                 → what ships vs what sounds good
> Miyamoto Musashi strategic timing
>                 → the decisive moment
> ```
>
> Each agent declares its analytical method, what it sees that others miss, and — critically — what it tends to miss.
>
> Socrates knows he spirals into infinite questioning.
>
> Torvalds knows he dismisses theoretical elegance. These declared blind spots are why the polarity pairs matter.
>
> ---
>
> ## The 6 polarity pairs
>
> The council is not 11 random thinkers. It is 6 deliberate counterweights:
>
> 1. Socrates vs Feynman — both question everything, but Socrates destroys top-down, while Feynman rebuilds bottom-up
>
> 2. Aristotle vs Lao Tzu — Aristotle classifies everything into categories. Lao Tzu says the categories are the problem
>
> 3. Sun Tzu vs Aurelius — Sun Tzu wins the external game. Aurelius governs the internal one
>
> 4. Ada vs Machiavelli — Ada abstracts toward formal purity. Machiavelli anchors in messy human incentives
>
> 5. Torvalds vs Watts — Torvalds ships concrete solutions. Watts questions whether the problem even exists
>
> 6. Musashi vs Torvalds — Musashi waits for the perfect moment. Torvalds says ship it now
>
> These pairs prevent groupthink. When all 11 convene, every position has a structural opponent. When you pick a triad of 3, you are selecting specific tensions — not just expertise areas.
>
> ---
>
> ## The 3-round deliberation protocol
>
> The council does not just poll 11 opinions. It runs a structured 3-round protocol that forces engagement.
>
> ### Round 1: Independent analysis (parallel)
>
> All selected members receive the problem and produce a standalone analysis.
>
> 400-word maximum per member.
>
> Each follows their agent-specific output template:
>
> Essential question, domain analysis, verdict, confidence level, and where they might be wrong.
>
> Every member runs as a parallel subagent. A 3-member triad completes round 1 in one parallel batch.
>
> ### Round 2: Cross-examination (sequential)
>
> Each member receives all round 1 output and must answer 4 prompts:
>
> 1. Which position do you most disagree with, and why?
>
> 2. Which insight from another member strengthens your own position?
>
> 3. What, if anything, changed your view?
>
> 4. Restate your position
>
> 300-word maximum. Must engage at least 2 other members by name.
>
> Sequential execution so later members can reference earlier cross-examinations.
>
> This is where the real value emerges. Feynman does not just state his view — he has to explain why he disagrees with Socrates.
>
> ### Round 3: Synthesis
>
> Each member states their final position in 100 words or fewer. No new arguments. Crystallization only.
>
> Socrates gets exactly one question, then must state his position. This is the convergence gate that prevents the dialectic from spiraling.
>
> ### Anti-recursion enforcement
>
> Socrates is the most dangerous member. His method is questioning, which means he can loop forever without committing to a position.
>
> Three enforcement mechanisms prevent this:
>
> The hemlock rule: if Socrates re-asks a question that another member has already addressed with evidence, the coordinator forces a 50-word position statement.
>
> No more questions.
>
> The 3-level depth limit: question a premise, question the response, question once more. After 3 levels, Socrates must state his own position.
>
> The 2-message cutoff: if any pair of members exchanges more than 2 messages, the coordinator cuts them off and forces round 3.
>
> These rules exist because the first version had no recursion limits. Socrates and Feynman would enter a questioning loop that consumed the entire context window.
>
> No conclusion. Just questions.
>
> ### Tie-breaking and consensus rules
>
> The council uses 3 decision rules:
>
> - 2/3 majority = consensus. The dissenting position is recorded in a Minority Report section
>
> - No majority = the dilemma is presented to the user with each position clearly stated. The council does not force artificial consensus
>
> - Domain expert weighting: the member whose domain most directly matches the problem gets 1.5x weight
>
> The minority report matters. Sometimes the dissenting view is the most valuable output.
>
> It surfaces the risk that the majority position misses.
>
> ### Pre-defined triads for common domains
>
> You do not need all 11 members for every question. The council ships 11 pre-built triads optimized for specific problem domains:
>
> ```
> DOMAIN        TRIAD                              WHY
> ─────────────────────────────────────────────────────────
> architecture  Aristotle + Ada + Feynman          classify → formalize → simplicity-test
> strategy      Sun Tzu + Machiavelli + Aurelius   terrain → incentives → moral grounding
> ethics        Aurelius + Socrates + Lao Tzu      duty → questioning → natural order
> debugging     Feynman + Socrates + Ada           bottom-up → assumptions → formal verify
> innovation    Ada + Lao Tzu + Aristotle          abstraction → emergence → classification
> conflict      Socrates + Machiavelli + Aurelius  expose → predict → ground
> complexity    Lao Tzu + Aristotle + Ada          emergence → categories → formalism
> risk          Sun Tzu + Aurelius + Feynman       threats → resilience → empirical verify
> shipping      Torvalds + Musashi + Feynman       pragmatism → timing → first-principles
> product       Torvalds + Machiavelli + Watts     ship it → incentives → reframing
> founder       Musashi + Sun Tzu + Torvalds       timing → terrain → engineering reality
> ```
>
> Invocation:
>
> ```
> /council --triad architecture "should we split the monolith now or after Series B?"
> /council --full "is this acquisition worth pursuing at 8x revenue?"
> /council --members socrates,feynman,ada "why does our cache invalidation keep failing?"
> ```
>
> --triad selects a pre-built group.
>
> --full convenes all 11.
>
> --members lets you pick any 2-11 members manually.
>
> No flag auto-detects the domain from your question and selects the matching triad.
>
> ### What a council session produces
>
> The output is not 11 separate opinions. It is a structured verdict:
>
> ```
> ## Council Verdict
>
> ### Problem
> should we migrate from REST to GraphQL for the mobile API?
>
> ### Council Composition
> Architecture triad: Aristotle, Ada, Feynman
>
> ### Consensus Position
> migrate the mobile-facing read endpoints to GraphQL.
> keep REST for write operations and internal services.
>
> ### Key Insights by Member
> - Aristotle: the problem is a category error — "migrate to GraphQL"
>   treats it as binary when the real question is which access
>   patterns benefit from graph traversal
> - Ada: GraphQL's type system gives you compile-time guarantees
>   on the client that REST cannot match — but only for reads
> - Feynman: the performance cost of GraphQL resolvers on write-heavy
>   paths is not theoretical. measure it. if N+1 queries appear
>   in staging, the abstraction is hiding real cost
>
> ### Points of Agreement
> - mobile clients benefit from flexible queries (reduce over-fetching)
> - write operations do not benefit from GraphQL's query model
> - incremental migration is safer than full rewrite
>
> ### Points of Disagreement
> - Aristotle wants a formal boundary definition before any migration
> - Feynman wants a prototype with real latency measurements first
>
> ### Minority Report
> none — consensus reached on hybrid approach
>
> ### Recommended Next Steps
> 1. prototype GraphQL gateway for 2 highest-traffic read endpoints
> 2. measure latency delta against current REST implementation
> 3. if delta is under 15ms p99, proceed with mobile read migration
> ```
>
> The key difference from asking a single model: You get the disagreements explicitly.
>
> Aristotle's "category error" reframe and Feynman's "measure it first" constraint are both surfaced. A single model averages these into one confident recommendation. The council keeps them separate so you can decide.
>
> ### Installation
>
> The council is a Claude Code skill. Installation takes 30 seconds:
>
> ```
> git clone https://github.com/0xNyk/council-of-high-intelligence.git
> cd council-of-high-intelligence
> ./install.sh
> ```
>
> This copies 11 agent definitions to ~/.claude/agents/ and the coordinator skill to ~/.claude/skills/council/SKILL.md.
>
> Manual installation if you prefer:
>
> ```
> cp agents/council-*.md ~/.claude/agents/
> mkdir -p ~/.claude/skills/council
> cp SKILL.md ~/.claude/skills/council/SKILL.md
> ```
>
> Requires Claude Code CLI with agent subagent support. CC0 licensed — use it however you want.
>
> ### When to use the council vs when not to
>
> Use the council for complex decisions where trade-offs are real.
>
> Architecture choices. Strategic pivots. Build-vs-buy. Pricing models.
>
> Do not use it for questions with clear, correct answers.
>
> Do not convene 11 thinkers to debate TypeScript vs JavaScript.
>
> Do not use --full when a triad covers the domain.
>
> 11 members consume significant context and API cost.
>
> The sweet spot: Decisions where you already have an opinion but suspect you are missing something. The council surfaces what you are not seeing — structured, with the disagreements visible.
>
> What is the last decision you made where a single confident answer hid the real trade-offs?
>
> Repository licensed under CC0 (public domain), github.com/0xNyk/council-of-high-intelligence

[Source](https://x.com/nyk_builderz/status/2034492549180625316)
