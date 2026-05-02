---
created: 2026-05-02
description: Quarq Labs (building a personal-agent harness) frames GEPA and Recursive Language Models as complementary context-management layers — GEPA optimizes the static prompt ahead of inference, RLM decomposes context dynamically at runtime — together replacing the "longer windows" paradigm with active curation.
source: https://x.com/quarqlabs/status/2048802002877251600
type: synthesis
---

# Quarq Labs frames GEPA and RLM as complementary context layers - GEPA optimizes static prompts before inference while RLM decomposes context at runtime

## Key Takeaways

- **The shared diagnosis: LLMs are passive consumers of context, and longer windows don't fix passivity.** Quarq names three failure modes of the "stuff everything in" paradigm — lost-in-the-middle degradation, quadratic attention cost, and zero in-model ability to filter or reorganize what arrives. Industry's answer (bigger windows) addresses *capacity*, not the underlying inability of the model to *manage* what it has been given. This reframes context engineering as an active-curation problem rather than a context-length problem, dovetailing with [[Letta Context Constitution frames context as the substrate of agent identity memory and continuity beyond model weights|Letta's "context as substrate" doctrine]] and [[autonomous context compression lets agents choose when to compact rather than hitting fixed token limits|autonomous compression]].

- **GEPA and [[The Mismanaged Geniuses Hypothesis argues the next AI leap comes from training LMs to decompose not from scaling|RLM]] sit at different layers of the same stack — pre-inference vs runtime.** GEPA evolves the *static* part of the system (instructions, retrieval queries, agent scaffolding) ahead of time so each token entering context is intentional and task-specific; RLM lets the model decide *at runtime* what to load, when, and how, instead of consuming a fixed text block. The Quarq framing is that you optimize-before-inference *and* decompose-at-runtime — both, not either. Same intuition the [[predict-RLM uses GEPA to recursively optimize agent skills reaching SpreadsheetBench top-5 as open source|predict-RLM team operationalized]] when they used an RLM as the GEPA proposer.

- **[[GEPA prompt optimizer beats reinforcement learning with 35x fewer rollouts by reflecting on natural-language execution traces|GEPA's]] sample-efficiency wedge comes from keeping feedback in natural language ("Actionable Side Information") rather than collapsing trajectories into a scalar reward.** The article's distillation of the paper: traditional optimizers (RL, evolutionary) tell you something failed but not why; GEPA's evaluator returns structured textual diagnostics that play the role of a gradient expressed in text. Headline efficiency numbers reproduced — outperforms GRPO by 6pp average / 19pp peak using up to 35× fewer rollouts; beats MIPROv2 by 10pp+ including +12 on AIME-2025; practical with 20–100 examples vs GRPO's 100k–512k rollouts.

- **GEPA generalizes beyond system prompts via adapters — MCP, DSPy, RAG.** The article highlights three concrete extensions: an MCP adapter that optimizes tool descriptions and server prompts; a DSPy adapter that evolves entire programs (signatures, modules, control flow) reaching 93% on MATH vs 67% with basic DSPy; and a generic RAG adapter optimizing query reformulation, context synthesis, and document reranking. The Pareto-front mechanism — keep multiple non-dominated candidates instead of collapsing to one optimum — is what enables this generalization without local-minimum collapse.

- **The strategic prediction: the next architecture wave is "selectivity, not size."** Quarq's parting note positions context curation as a first-class problem for personal-agent harnesses, with their own product pitching the framing. The broader implication for harness builders: if static optimization (GEPA) and dynamic decomposition (RLM) compose, the product surface shifts from "ship long-context models" to "ship harnesses that curate". Aligned with [[Cursor strips guardrails and adds dynamic context as models improve, inverting the harness's job|Cursor's harness-inversion thesis]] (delete guardrails, push dynamic context to the model itself) and the [[the harness layer is the next hundred billion dollar AI infrastructure market not the model|harness-as-platform argument]].

## External Resources

- [Prior Quarq RLM piece](https://x.com/quarqlabs/status/2047936241078059067) — the companion article on RLMs alone, referenced as background
- [Alex Zhang's RLM blog (alexzhang13.github.io)](https://alexzhang13.github.io/blog/2025/rlm/) — the canonical RLM primer, cited in the references block
- [arXiv:2507.19457 — GEPA paper](https://arxiv.org/abs/2507.19457) — Agrawal/Khattab et al., already deeply captured at [[GEPA prompt optimizer beats reinforcement learning with 35x fewer rollouts by reflecting on natural-language execution traces]]
- [GEPA docs site (gepa-ai.github.io)](https://gepa-ai.github.io/gepa/) — official documentation, MCP/DSPy/RAG adapter guides
- [github.com/gepa-ai/gepa](https://github.com/gepa-ai/gepa) — official repo, MIT licensed
- [OpenReview: RQm2KQTM5r](https://openreview.net/forum?id=RQm2KQTM5r) — peer-review thread on the GEPA paper
- [Decagon: Optimizing GEPA for Production](https://decagon.ai/blog/optimizing-gepa-for-production) — production deployment writeup
- [Quarq Labs waitlist](https://quarq.io/#waitlist) — early-beta signup for the personal agent

## Original Content

> [!quote]- Source Material — full @quarqlabs article (Mon Apr 27 2026)
>
> @quarqlabs (Quarq):
> Article: Exploring GEPA
>
> There's been a spike in discussion around Recursive Language Models (RLMs) and GEPA on this platform.
>
> Both of these are trying to address the same underlying limitation: today's LLM systems don't manage context well.
>
> This piece focuses on GEPA. What it is, how it works, and where it fits if you're exploring this space.
>
> If you are curious about RLMs alone we have covered this topic before. You can read about it [here](https://x.com/quarqlabs/status/2047936241078059067?s=20)
>
> *Header image — "Gentle Introduction to GEPA" with the GEPA optimization loop diagram (initialize → propose → minibatch eval → keep-or-discard against a Pareto front of candidates).*
> ![[quarqlabs-251600-001.jpg]]
>
> ## RLM + GEPA and Context Management
>
> These are two distinct yet complementary research thrusts, both attacking the same fundamental problem — LLMs are passive consumers of context
>
> The classical paradigm is "stuff everything into the context window and hoping that the model pays attention to the right parts".
>
> This breaks in many ways :
>
> - "Lost in the middle" degradation,
>
> - Quadratic attention costs at scale,
>
> - Model having zero ability to reorganize or filter what it's been given.
>
> Context length scaling has been the industry's answer, but longer windows don't fix the fundamental passivity problem.
>
> ## GEPA: Evolving the Context You Feed In
>
> Where RLM focuses on runtime behavior, GEPA operates before inference.
>
> It's about improving the prompts, instructions, and system setup ahead of time, rather than relying on the model to handle everything at runtime.
>
> GEPA (Genetic-Pareto) is a prompt optimizer that learns from trial and error using natural language feedback.
>
> Given a system with one or more LLM prompts, it runs the system end-to-end, sampling reasoning steps, tool calls, and outputs.
>
> It then reflects on these traces to identify failure modes, propose prompt updates, and test improvements.
>
> Over time, it accumulates and combines useful changes, keeping multiple high-performing variants instead of collapsing to a single solution.
>
> Below is an example of how this optimization loop works in practice.
>
> *Seed prompt for the second hop of a multi-hop QA system, alongside the GEPA-optimized prompt for GPT-4.1 Mini — note how the optimizer turned a one-line directive into a structured set of observations, query-construction guidance, and a practical strategy.*
> ![[quarqlabs-251600-002.jpg]]
>
> Traditional optimizers like RL or evolutionary strategies reduce everything to a single number i.e a reward.
>
> They can tell that something failed, but not why it failed.
>
> GEPA takes a different approach. Instead of collapsing execution into a score, it keeps the feedback in natural language.
>
> Evaluators return Actionable Side Information (ASI), a structured diagnostic feedback about what went wrong and what could be improved.
> This plays a role similar to a gradient, but expressed in text rather than numbers.
>
> An LLM reads this feedback, identifies failure modes, and proposes targeted fixes.
>
> To avoid converging too early on a single solution, GEPA doesn't just optimize for one "best" prompt.
>
> It maintains a Pareto front, a set of high-performing prompts that trade off different strengths. Instead of collapsing to a single optimum, it keeps exploring multiple directions.
>
> This diversity helps it generalize better and reduces the risk of getting stuck in local minima.
>
> The efficiency numbers.
>
> *Qwen3-8B benchmark table from the GEPA paper — GEPA reaches +9.62 aggregate over Baseline (and +5.94 over GRPO) using 1,839–7,051 rollouts versus GRPO's 24,000 across HotpotQA / IFBench / Hover / PUPA / AIME-2025 / LiveBench-Math.*
> ![[quarqlabs-251600-003.png]]
>
> Across six tasks, GEPA outperforms GRPO by 6 percentage points on average and up to 19 points, while using up to 35x fewer rollouts. It also outperforms the leading prompt optimizer MIPROv2 by over 10 percentage points, including +12 points on AIME-2025.
>
> In practical terms: GEPA's reflection-based approach means prompts can be optimized with just 20–100 examples, making it practical for production scenarios where labeled data is expensive or domain-specific.
>
> GRPO-style RL methods, by contrast, have consistently required anywhere from 100,000 to 512,000 rollouts in practice.
>
> It also generalizes beyond simple system prompts.
>
> There's an MCP adapter that optimizes tool descriptions and system prompts for Model Context Protocol servers
>
> There's also a DSPy adapter that evolves entire programs including signatures, modules, and control flow (achieving 93% on MATH vs. 67% with basic DSPy), and a generic RAG adapter that optimizes query reformulation, context synthesis, and document reranking. [[source]](https://github.com/gepa-ai/gepa)
>
> RLM ♥️ GEPA
>
> These operate at different layers of the same stack.
>
> 1. GEPA focuses on what goes into the context i.e instructions, retrieval queries, agent scaffolding. Making each token more intentional and task-specific.
>
> 2. RLM focuses on what happens at runtime, letting the model decide what to load, when, and how, instead of consuming a fixed block of text.
>
> Together, they suggest a shift in how context is handled.
>
> The static part of the system is optimized ahead of time (GEPA), while the dynamic part is managed during execution through recursive decomposition (RLM).
>
> Instead of relying on ever-larger context windows, the direction here is toward selectivity — models that are better at deciding what matters and when.
>
> The broader implication is a move away from "add more context" toward systems that actively curate and manage it.
>
> This shift toward better context management isn't just theoretical. It directly shapes how agent systems need to be built.
>
> Parting note
>
> We're building a personal agent at @quarqlabs where the harness sits at the center.
>
> The goal is straightforward: an agent that works out of the box, without requiring users to assemble infrastructure around it. That means treating context as a first-class problem. We'll be opening an early beta soon.
>
> If you want to see how this approach performs in practice, including benchmark results, you can join the [waitlist](https://quarq.io/#waitlist).
>
> References
>
> https://alexzhang13.github.io/blog/2025/rlm/
> https://arxiv.org/abs/2507.19457
> https://gepa-ai.github.io/gepa/
> https://arxiv.org/pdf/2507.19457
> https://openreview.net/forum?id=RQm2KQTM5r
> https://decagon.ai/blog/optimizing-gepa-for-production
>
> *Posted Mon Apr 27 16:30:37 +0000 2026 · [original article](https://x.com/quarqlabs/status/2048802002877251600)*
>
> ---
>
> Reply (@curlysaarthak, Tue Apr 28 2026):
> > @quarqlabs good work was about to read on this @smykx 🫡🫡
>
> Reply (@tanishqk, Sat May 02 2026):
> > @quarqlabs how do you avoid overfitting with this approach? I tried something like this, but I just burned a ton of tokens and got an overfitted system prompt for the task. Seems hard to pick a general set of tasks
