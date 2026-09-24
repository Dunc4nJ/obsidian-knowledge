---
created: 2026-09-24
source: https://contrastive-lm.notion.site
via: https://x.com/jackyk02/status/2102905335925424285
author: Jacky Kwok et al. (Stanford, Hazy Research, NVIDIA Research)
published: 2026-09-23
type: knowledge
tags: [jev, clm, contrastive, system-one-models, bi-encoder, verifier, best-of-n, scaling-laws, deepswe, terminal-bench, stanford, hazy-research, open-weights]
cite: "Kwok, Jacky; Kang, Hangoo; Suresh, Tarun; Saad-Falcon, Jon; Pavone, Marco; Ré, Christopher; Mirhoseini, Azalia. Contrastive Language Models - A System One Model for Fast and Generalizable Decision-Making. 2026, Notion Blog. https://contrastive-lm.notion.site"
description: CLM-8B puts two 20M-parameter projection heads on a frozen Qwen3-8B and trains them with bidirectional InfoNCE, so state and action embeddings cache independently and a softmax over their cosine is the answer distribution - the 9x and 13x speedups over Jev are structural, the zero-shot parity is a tie on saturated tasks, and the headline verifier result clears random selection by three of thirty-eight DeepSWE tasks while Jev falls one below it.
---

# Stanford's CLM-8B is an open bi-encoder System One model caching actions apart from state

## Key Takeaways

- **The mechanism is a bi-encoder, and that is what buys the speed.** A state encoder and an action encoder, each a frozen Qwen3-8B plus a ~20M-parameter MLP head, are trained with bidirectional InfoNCE; scoring is `exp(logit_scale) * cos(z_s, z_a)` and a softmax over those scores *is* the answer distribution. Because the two towers are separate, the candidate embeddings survive a change of state, so a loop with a fixed action menu pays one encoder pass per step instead of N+1. This is the structural difference from Jev, which per the authors caches state only, and it is why the advantage grows with candidate count rather than sitting at a constant. It is also the reason CLM cannot do what a cross-attention design like [[jevlike]] does — options never see each other or the context.

- **"On par with Jev zero-shot" is a tie on the saturated tasks and a loss on the two that discriminate.** T-Rex and Super Mario are both 5/5 for both models, which measures nothing. On the two benchmarks with room to separate, CLM is behind: BFCL v4 tool calling 95.2% against Jev's 99.2%, and WikiRacing 26/30 against 30/30. The honest reading is that CLM trades roughly four points of accuracy for a large latency win, not that it matches quality. Contrast [[Cua keeps the candidate menu in application code so Jev only picks an ID - CUA-S1-FORMS is a 706K-parameter form specialist at 99.7 percent against hosted Jev's 83.6, and neither model sees pixels]], where a task-specific small model beat hosted Jev outright.

- **"Jev fails as a verifier, below pass@1" is a one-task deficit.** On DeepSWE that dashed line is random selection at 73.7% (28 of 38); Jev scores 71.1%, which is 27 of 38. One task, on a 38-task held-out set. Terminal-Bench 2.1 is the same shape: 83.1% against an 84.0% baseline. The claim is directionally true and it is also inside the noise a single task can produce. What is robust is the other bar: CLM's 81.6% is 31 of 38, three tasks clear of random and better than half the distance to the 89.5% oracle. The verifier half of the comparison is also not like-for-like — CLM was fine-tuned on DeepSWE trajectories while Jev was zero-shot.

- **The latency comparison is a local GPU against a hosted API, and the blog says so once you expand its toggles.** The collapsed "Click to View More Experimental Details" block states the protocol verbatim: "All experiments use a 200-token state on a single 4090 GPU with 5 trials", with Jev "accessed through the TypeSafe API"; the agentic footnote adds "Latency is measured on an H100 GPU." So CLM runs on hardware the authors control while Jev answers over the network. Crucially, the Jev figures here (125–225 ms zero-shot, 131–449 ms agentic) sit inside TypeSafe's published 70–500 ms, and nowhere near the 14.69 s median that [[Praneeth Paikray measures Jev's calibration for the first time - ECE 0.173 and Brier 0.156 lose to a TF-IDF baseline, and GEPA nearly halves the probability error]] observed client-side. Whatever path these authors had to Jev was a good one, so the multiple is not inflated by a bad connection. But the floor of the comparison is still deployment: the blog's own numbers put CLM at 36 ms and Jev at 131 ms with a single candidate, 3.6x apart before any caching advantage exists. The growth from 3.6x to 13x is the part the architecture earns. Note also the sample size the same sentence admits — five trials, which is exactly the 5/5 scores in the zero-shot table.

- **Nobody has checked whether these probabilities are calibrated.** A softmax over scaled cosines with a learned `logit_scale` produces a distribution, and the playground renders it to one decimal place, but the blog reports no ECE, Brier or reliability curve. The standing vault finding is that Jev itself is worse calibrated than a three-second TF-IDF logistic regression, so inheriting Jev's API shape inherits the open question. The head architecture makes it worse, not better: probabilities are relative to the candidate set, which `@latent_node` spotted in the replies when asking how you express "none of these fit".

- **Context is the unexamined variable on both sides.** The blog never says how a DeepSWE or Terminal-Bench trajectory was fed to Jev, and Jev's documented limit is 64k per request with 32k for state plus the longest question, under a vendor page that admits "Jev suffers from context rot" — see [[Annabell frames TypeSafe's Jev as a savant for eval verdicts and routing - three question types, 255 choices, 10 score levels, and a Noul with no confidence field]]. If long trajectories were truncated, "fails as a verifier" is a context-window result. CLM sidesteps this by never scoring a whole trajectory: `bon_eval.py` scores each step and averages the last twelve. And CLM has its own ceiling — the documented encoder launch caps the state at 2048 tokens, with separate 8k heads for the agentic benchmarks.

- **Encoder size has the steepest scaling exponent, fit on three points.** The four power laws are clean and the ranking is the paper's headline claim: encoder 0.172, compute 0.144, data 0.117, head 0.061. But the encoder curve is Qwen3-1.7B, 4B and 8B — three models — and the strongest recommendation in the work rests on it. The iso-FLOP work underneath is sturdier: four token budgets, a parabola in log-parameter space each, optima tracking `N* ∝ D^1.02` at about 310 tokens per parameter.

- **This is the first Jev reimplementation with a training recipe, published weights, and a compatibility play.** [[Featherless's Simple Jev reproduces Jev's API on stock open models by remapping every answer to a single-token letter and softmaxing only those logits - no classifier head, and the code stamps every answer calibrated False]] used stock logits with no training; [[jevlike]] trained a cross-attention option head; [[Varun Mathur's jevcache memoizes Jev decisions by sha256 of model, schema and redacted canonical state - the 60 to 80 percent repeat rate is asserted and dropping user_id collides two subjects]] cached around the API; [[Sutro's jev-align uses GEPA to rewrite Jev's decision criteria from five labeled examples - the demo moves labeled-set ambiguity 49.6 points but full-pool certainty only 0.5]] tuned the prompt. CLM is the first to ship scaling laws, 1 TB of pre-training embeddings, and an endpoint literally named `/v1/systemone`. Its zero-shot task list — WikiRacing, T-Rex — is TypeSafe's own demo set re-run.

**Authorship.** The blog byline reads "Jacky Kwok†, Hangoo Kang, Tarun Suresh, Jon Saad-Falcon, Marco Pavone, Christopher Ré, Azalia Mirhoseini — Stanford University, NVIDIA Research", with the † footnote defined as **Project Lead**. Pavone holds the NVIDIA affiliation; the thread credits @HazyResearch. Posted Sep 23, 2026.

## What CLM Is

A **Contrastive Language Model** is two encoders into one shared space. Each is a frozen LLM backbone whose final-token hidden state is L2-normalised and pushed through a trainable MLP projection head; only the head trains, and it is about 20M parameters. The score of a state-action pair is the cosine of their projections, scaled by a learned `logit_scale`.

The blog gives the head's exact shape in a collapsed note: "a three-layer MLP that maps the 4,096-dimensional Qwen3-8B hidden state to a 512-dimensional embedding through a width of 1,536 (4096 → 1536 → 1536 → 512, GELU activations and a LayerNorm on the hidden layer)." That matches the defaults in `evaluation/bon_eval.py` — width 1536, depth 3, `layernorm` true, `projection_dim` 512.

*The encoder side: a frozen LLM, last-token hidden state, L2 norm, and an MLP projection head as the only trainable part*
![[jackyk02-424285-blog-01.png]]

At deployment the two encoders are a zero-shot action classifier. A typed question is a state plus a closed set of candidate actions, and the softmax over CLM's scores is the answer. The same primitive ranks best-of-N trajectories, routes tools and shortlists retrieval pools.

*The full picture: contrastive state-action pre-training with a B x B similarity matrix, action candidates built from a template, and zero-shot classification by softmax over dot products*
![[jackyk02-424285-001.jpg]]

**Training objective.** Bidirectional InfoNCE over a batch of B matched pairs, optimising retrieval in both directions:

```math
L_{\mathrm{CLM}} = -\frac{1}{2B}\sum_i \left[ \log \frac{\exp\left(s_i^\top a_i/\tau\right)} {\sum_j \exp\left(s_i^\top a_j/\tau\right)} + \log \frac{\exp\left(a_i^\top s_i/\tau\right)} {\sum_j \exp\left(a_i^\top s_j/\tau\right)} \right]
```

Mid-training extends the state-to-action direction with hard negatives `h_ik`:

```math
L_{s \rightarrow a}^{\mathrm{hard}}=-\frac{1}{B}\sum_i\log\frac{\exp\left(s_i^\top a_i / \tau\right)}{\exp\left(s_i^\top a_i / \tau\right)+\sum_k\exp\left(s_i^\top h_{ik}^{(a)} / \tau\right)}.
```

**Why disaggregation matters.** Because the towers are separate, action embeddings are computed once and reused across every subsequent state. In Super Mario the four action embeddings are precomputed before play; each step re-encodes only the frame. Five forward passes become one.

*Action caching in Super Mario: four precomputed action embeddings, a fresh state encoding per step, and one forward pass instead of five*
![[jackyk02-424285-blog-02.png]]

**Serving.** `clm-serve` runs the heads on CPU at port 8700 and exposes `POST /v1/systemone` — TypeSafe's own endpoint name, so a request written for Jev replays unchanged — plus `POST /v1/rank`, `GET /v1/models`, `GET /health` and the playground at `/`. A vLLM Qwen3-8B pooling server holds the encoder on GPU at port 8090. The served head alias is `clm-latest`; heads hot-reload on file change, and a vector arena reserved at start-up caches both states and actions. Full code-level detail is in [[CLM]].

*The playground: three typed questions against one state, with server latency at 10.1 ms, round trip at 1046 ms, and encoder tokens at 0 on a warm cache*
![[jackyk02-424285-007.jpg]]

That playground screenshot is worth a second look. Server-side latency is 10.1 ms and the round trip is 1046 ms — a hundredfold gap on a local box, and a reminder that every millisecond figure in this release is server-side.

## Data Recipe

Three stages, each a harder form of state-action alignment.

*Pre-training on Nemotron DQA, mid-training on Gemini-generated hard negatives, post-training on Agent Data Protocol trajectories*
![[jackyk02-424285-002.jpg]]

| Stage | Data | Scale | What it teaches |
|---|---|---|---|
| Pre-training | Nemotron DQA question-answer pairs, question as state, answer as action | ~60M | Broad semantic representations |
| Mid-training | Synthetic hard negatives from Gemini 2.5 Flash-Lite, semantically similar but wrong | ~30M | Fine-grained discrimination between plausible actions |
| Post-training | Agent Data Protocol trajectories plus Endless-Terminals and LiteCoder-Terminal-SFT traces | ~1M | Action classification in agentic environments |

A full pre-training run takes about an hour on a single RTX 4090, because the frozen encoder's embeddings are precomputed once and reused across head configurations. That is what makes the scaling sweep affordable, and it is also why the released pre-training artifact is 1,023.5 GB of embeddings rather than text.

**Pre-training alone already reshapes the space.** Asked who wrote Romeo and Juliet, raw Qwen3-8B embeddings rank "Romeo and Juliet wrote it together" first at 60.1% and put Shakespeare third at 19.8%. After pre-training CLM-8B ranks Shakespeare first at 54.2%.

*Raw Qwen3-8B ranks the correct answer third; CLM-8B after pre-training ranks it first at 54.2 percent*
![[jackyk02-424285-blog-04.png]]

**Replay stops catastrophic forgetting.** The post-training mixture is 40% Nemotron DQA replay and 60% agentic. Over 5,000 steps, replay holds Nemotron hard-negative top-1 at 68.4% against a 69% starting point; agentic data alone collapses it to 56.2%. The chart labels the gap +12.2 points; the prose rounds the replay endpoint to 68.5%.

*With replay, Nemotron hard-negative top-1 holds at 68.4 percent over 5,000 steps; without it, 56.2 percent*
![[jackyk02-424285-blog-05.png]]

**Hard negatives are a refinement, not a substitute.** On ~100K held-out questions with one gold answer and ten hard negatives each, pre-training alone reaches 52.1% top-1 without ever seeing a hard negative. A short mid-training stage lifts that to 69.2%. Training on hard negatives from the start climbs faster but plateaus at 62.4% and then declines. At fixed compute the two-stage recipe is about 7 points better.

*Pre-train 52.1 percent, hard negatives from the start 62.4 percent and overfitting, pre-train plus mid-train 69.2 percent*
![[jackyk02-424285-blog-06.png]]

This is the release's most transferable finding and it does not depend on the Jev comparison at all. It also sits directly against the vault's note on [[scaling embedding models requires LLM-labeled deduplication to fix the fake negative problem]]: CLM's negatives are Gemini-synthesized rather than mined, which removes the fake-negative hazard and introduces a generator-distribution one instead. `@lastinline98` put the finger on it in the replies.

## Scaling Laws

Test InfoNCE loss follows `L(X) ≈ (X_c / X)^α_X` in each of four variables, fit Kaplan-style on Nemotron DQA with a held-out set.

*Four power-law fits: compute, dataset size, projection-head parameters, and encoder size across Qwen3-1.7B, 4B and 8B*
![[jackyk02-424285-003.jpg]]

| Variable | Fitted law | Exponent | Fit points |
|---|---|---|---|
| Compute C, FLOPs | L = (C / 7.34 x 10^13)^-0.144 | 0.144 | 5 |
| Dataset D, state and action tokens | L = (D / 2.12 x 10^9)^-0.117 | 0.117 | 6 |
| Projection head N | L = (N / 3.60 x 10^5)^-0.061 | 0.061 | 6 |
| Encoder N_enc, LLM parameters | L = (N_enc / 4.18 x 10^9)^-0.172 | 0.172 | 3 |

Encoder size has the steepest exponent, which is the paper's stated recommendation and the justification for the forthcoming CLM-35B. It is also the shortest curve: three backbones. The authors note the dimensions must be scaled jointly, and the compute and data curves both bend below their fitted lines at the high end, which is the usual sign that another factor is binding.

**Data against optimal head size.** At fixed compute, test loss against head size is a parabola in log-parameter space, and its minimum moves right as the token budget grows. Across 2B, 4B, 8B and 16B training tokens the optima track `N* ∝ D^1.02` — almost exactly linear — at roughly **310 tokens per parameter**.

*Iso-FLOP curves for 2B, 4B, 8B and 16B training tokens, with the optimal projection-head size marked on each*
![[jackyk02-424285-blog-03.png]]

For comparison with the vault's other power-law methodology note, [[ScaleRL proves clipped importance sampling prevents entropy collapse in large-scale agentic RL]] fits saturating curves early and extrapolates to a target budget; CLM fits straight Kaplan power laws and does not report an extrapolation error bar.

## Zero-Shot vs Jev

Four tasks, CLM-8B on a 4090 against hosted Jev.

| Task | CLM-8B latency | Jev latency | Speedup | CLM-8B success | Jev success |
|---|---|---|---|---|---|
| T-Rex Game | 16.5 ms | 149.8 ms | 9.1x | 5/5 | 5/5 |
| Tool calling, BFCL V4 | 76.8 ms | 125.5 ms | 1.6x | 95.2% | 99.2% |
| WikiRacing | 79.8 ms | 225 ms | 2.8x | 26/30 | 30/30 |
| Super Mario | 33.5 ms | 132.6 ms | 4.0x | 5/5 | 5/5 |

*Zero-shot latency and success rate across T-Rex, BFCL v4 tool calling, WikiRacing and Super Mario*
![[jackyk02-424285-005.png]]

The "9x" of the headline is the T-Rex column. The two tasks where both models are 5/5 are the two with the biggest speedups, and the two where CLM trails are the two where the gap narrows. Sample sizes are small: 5 trials for the games, 30 for WikiRacing.

**How the latency was actually measured.** This is in a collapsed toggle on the blog, and it is the single most important methodological sentence in the release: "All experiments use a 200-token state on a single 4090 GPU with 5 trials." The two baselines are constrained decoding on the same Qwen3-8B — "a single prefill over the state and all candidate options, followed by a softmax over option labels" — and "Jev, accessed through the TypeSafe API." Agentic latency is separately stated as measured on an H100.

**Where the speedup actually comes from.** The scaling plot separates the two effects cleanly, and the expanded blog gives the endpoints in prose.

| Sweep | CLM | Jev | Constrained decoding | Stated gap |
|---|---|---|---|---|
| 1 candidate, 15 tokens each | 36 ms | 131 ms | ~49 ms | 3.6x, deployment only |
| 1,024 candidates, 15 tokens each | 44 ms | 579 ms | 4,285 ms | 13x over Jev, ~97x over constrained decoding |
| 5 candidates, 1 token each | ~36 ms | ~110 ms | 49 ms | flat baseline |
| 5 candidates, 2,048 tokens each | 36 ms | 333 ms | 3,402 ms | 9x over Jev, ~95x over constrained decoding |

*Latency against number of candidates and against candidate length, with CLM flat and Jev and constrained decoding climbing*
![[jackyk02-424285-004.jpg]]

There is no crossover: CLM is faster everywhere on this plot. But the left edge is the deployment gap — a local 4090 against a hosted API, 36 ms against 131 ms with no caching benefit in play — and only the climb from 3.6x to 13x is attributable to the architecture. Report the multiple with its candidate count attached, as `@YionxpYi` asked in the replies. The genuinely large number is the one against constrained decoding, roughly 97x, and that is an apples-to-apples comparison on the same backbone and the same GPU.

## Agentic Verification

For each task, several candidate solutions are sampled from a generator and CLM or Jev picks the best. `bon_eval.py` scores every trajectory step and takes the mean of the final twelve as the trajectory score.

| | DeepSWE | Terminal-Bench 2.1 |
|---|---|---|
| Candidate generator | Opus 5 | Fable 5 |
| Held-out tasks | 38 | 30 |
| Candidate budget | Bo4 | Bo5 |
| Random selection, charted as "Pass@1" | 73.7% (28/38) | 84.0% |
| Jev | 71.1% (27/38) | 83.1% |
| CLM, fine-tuned | 81.6% (31/38) | 87.6% |
| Oracle, any of N | 89.5% (34/38) | not published |
| CLM verifier latency | 79 ms | 32 ms |
| Jev verifier latency | 449 ms | 131 ms |
| Speedup | 5.7x | 4.1x |

*DeepSWE and Terminal-Bench 2.1 success rate and verifier latency, with the random-selection baseline as a dashed line*
![[jackyk02-424285-006.jpg]]

The pass@1 and oracle figures are not in the blog or the thread. They come from the `deepswe-clm-heads-8k` model card, which also documents the split: seed 42, stratified by candidate count and pass count, 75 training tasks against 38 held-out and task-disjoint, 66 training tasks with successful trajectories, trained from `CLM_v0.1-8B.pt` at batch 512, seed 1234, up to 20 epochs, patience 5.

Read against those numbers, CLM captures three of the six tasks available between random selection and the oracle — it closes half the best-of-4 headroom. That is a real result. Jev's 27 of 38 is one task under random, which is the whole basis for "fails to serve as a verifier".

Two asymmetries to carry forward. CLM was fine-tuned on DeepSWE training trajectories and Jev was not, so this is a tuned specialist against a zero-shot generalist. And the blog never states how trajectories reached Jev — I expanded all four of the page's collapsed toggles and the expanded footnote covers the generators, the task counts and the H100, but says nothing about how a long trajectory was presented to a model with a 32k state limit and documented context rot. Truncation is the obvious confound and it is unaddressed. Nor is a pass@N ceiling published for Terminal-Bench, so only the DeepSWE headroom is knowable. The step-level scoring CLM uses is exactly the design that [[process reward models that verify each reasoning step outperform outcome-only scoring]] argues for, and the dataset card's own title calls these "DeepSWE PRM training embeddings" — the verifier is a process reward model wearing the CLM name.

"SOTA on Terminal-Bench 2.1" should be read narrowly: 30 held-out tasks with a Fable 5 generator and best-of-5, not the public leaderboard, which [[Terminal-Bench leaderboard requires five full runs with raw logs to enforce reproducibility over cherry-picked results]] says demands five full runs with raw logs. The vault's nearest comparator, [[DeepSeek-V4.1-Flash runs at 200 tok-s on 4x RTX PRO 6000 Max-Q with only 64GB RAM because its 203GB Engram lives on NVMe - true for a 384GB-VRAM box, not for two cards]], carries Terminal-Bench 2.1 at 90.6 and DeepSWE at 74.2 for a single model with no verifier at all. And [[Prime Intellect's fine-tune-last doctrine - 5x task timeouts lifted Terminal-Bench 14.7 points with no model change]] is the standing reminder that harness changes move this benchmark more than models do.

On the economics, [[LangChain and Harvey show DeepSeek batch verifiers reduce legal agent evaluation costs by three orders of magnitude at acceptable accuracy]] and [[LangChain's Jev-as-a-Judge bench puts Jev's quality-score variance 92 to 913x below three LLM judges at $0.34 against Claude's $28.17 - five weather traces, one human oracle, provider-default sampling]] are the two places the vault has priced verification; CLM's contribution is that the verifier is now a 75 MB file you host yourself. [[Phoebe Yao argues verifier engineering is the moat in RL post-training because verifiability bounds learnability]] is the reason that matters, and [[reward model ensembles mitigate overoptimization in RLHF by combining conservative objectives with uncertainty weighting]] is the standing warning about what a single learned scorer does under pressure.

## Where It Sits

CLM is a pure bi-encoder, the weakest and fastest point on the interaction spectrum. Every candidate is embedded in isolation, which is precisely what makes the cache work and precisely what caps the ceiling. The vault's retrieval notes map the tradeoff: [[late interaction lets a 150M ColBERT model outperform 7B dense retrievers on reasoning-intensive retrieval]] and [[ColBERT MaxSim is a submodular facility location objective and that is why it generalizes]] describe what a late-interaction model buys over a single-vector one, and CLM has deliberately given that up. [[GLIE finds ColPali page embeddings have only ~5 degrees of freedom, so k stored vectors plus a 415K-parameter decoder can regenerate all 1,031]] is the closest precedent for a tiny trainable head over frozen multivector embeddings.

Against the other Jev work in this vault:

| Project | Approach | Trained | Caches actions | Open weights |
|---|---|---|---|---|
| Jev (TypeSafe) | Hosted, proprietary | Yes | No, state only | No |
| [[jevlike]] | Cross-attention option head | Yes | No, options attend over context | Yes |
| [[Featherless's Simple Jev reproduces Jev's API on stock open models by remapping every answer to a single-token letter and softmaxing only those logits - no classifier head, and the code stamps every answer calibrated False]] | Single-token letter logits on stock LMs | No | Not applicable | Base models |
| CLM-8B | Bi-encoder, InfoNCE | Yes | Yes, independently | Yes, Apache-2.0 |

It also inherits TypeSafe's question taxonomy wholesale — `noul`, `choice`, `score`, described in [[Annabell frames TypeSafe's Jev as a savant for eval verdicts and routing - three question types, 255 choices, 10 score levels, and a Noul with no confidence field]] and extended in [[TypeSafe's Advanced structure page makes instructions and criteria arbitrary JSON via EntryType's open key map - field, inspect, focus and not_for are convention, and the page quantifies nothing]]. Anything built on Jev's decision layer can point at CLM instead: the middleware pattern in [[LangChain's Sydney Runkle puts Jev inside the agent loop as classifier middleware - ModelRouterMiddleware picks the model from the latest user message and AutoModeMiddleware reproduces closed harnesses' dangerous-action gate]], the candidate-menu discipline of [[Cua keeps the candidate menu in application code so Jev only picks an ID - CUA-S1-FORMS is a 706K-parameter form specialist at 99.7 percent against hosted Jev's 83.6, and neither model sees pixels]], the grep-then-score shape of [[Can Bölük's jegrep turns Jev into a semantic grep by scoring grep-ranked candidates with one Noul per file and a Choice for the line range - $0.004 a query, and the Gemini-lite comparison is nowhere in the repo]], the escalation gate in [[TypeSafe's SDE cascade gates escalation on any per-field Noul above 0.7 - the chart's y-axis is mean llm_judge and the frontier dominates only the two middle models]], and the confidence ladders of [[Daniel Ch's How to master Jev prescribes a 0.85 and 0.55 confidence-gate ladder under an LLM that still writes - the decision-layer architecture is additive but every number and all three charts are TypeSafe's own]]. The one pattern CLM cannot absorb unchanged is the one that needs a calibrated absolute probability rather than a set-relative one.

For the category as a whole, [[Josh Rosen's Jev in the Wild sorts week-one projects into routing, context filtering, tool gating, worker supervision, fast control loops and fuzzy data queries - deterministic only because inference was expensive]] is the hub, and [[TypeSafe's Jev trades string generation for parallel-sampled typed decisions with calibrated probabilities at $0.042 per MTok - the 193x and 444x claims come from four self-built workflow evals]] is the original. CLM's contrastive-over-frozen-Qwen3 recipe has one near-precedent in the vault outside the Jev section: the behaviour-aligned router in [[memento-skills turns executable skill folders into evolving non-parametric memory that lets frozen LLMs learn continuously from deployment]]. The step-scoring half has two: [[automatic process annotation eliminates the need for human labeling in step-level math verification]] and, as the counter-argument, [[reasoning-driven process reward models generate interpretable step evaluations that surpass direct scoring]] — which holds that generating explicit reasoning before judging beats direct scoring, the one thing a cached dot product can never do.

- [[moc - Jev]] for the whole Jev cluster

## The Videos

Four videos, none with speech; the root explainer has music only and the demos are silent.

**Root explainer**, 80.8 s, 1920x1080. An animated restatement of the blog figures: title card, architecture, data recipe, scaling laws, zero-shot chart, agentic chart. One frame carries a number the static figures do not, the per-action softmax in the Mario loop.

*Zero-shot action classification with the action cache: left 4 percent, jump 78 percent, right run 6 percent, right jump 12 percent, one forward pass instead of five*
![[jackyk02-424285-vid-01.png]]

**Dino Run**, 9.5 s, 1920x1080. A split screen racing CLM against Jev on the Chrome dinosaur game. The overlay states the terms of the whole release: "Zero-Shot on 4090 GPU", CLM at 16 ms average latency with a score of 00066, Jev at 150 ms with 00013.

*The Dino Run race, labelled Zero-Shot on 4090 GPU, CLM at 16 ms and score 00066 against Jev at 150 ms and 00013*
![[jackyk02-424285-vid-02.png]]

**Super Mario**, 50 s, 1616x820. Side by side with live decision latency. At the 30-second mark CLM has progress 2644 with a 34.6 ms decision time; Jev has 1948 at 131.8 ms. The action set is the four fixed controls, which is the best case for action caching.

*Super Mario at 30 seconds: CLM progress 2644 with decision latency 34.6 ms against Jev progress 1948 at 131.8 ms*
![[jackyk02-424285-vid-03.png]]

**WikiRacing**, 20.6 s, 1280x800. The head probabilities over outgoing links are drawn on screen, which is the clearest illustration of why this task shows a large speedup: the overlay reads "click 6/6 · on Fluorescence · 296 links", so the action set is nearly three hundred candidates per step. CLM ranks Bioluminescence at 92.6%, Luminescence 3.0%, Chromatophore 1.2%, Photophore 1.0%, Aphotic zone 1.0%, Green fluorescent protein 0.4%, Chemiluminescence 0.2%, Aequorea victoria 0.1%. The path taken was Plate tectonics, Submarine, Underwater diving, Night diving, Dive light, Fluorescence.

*WikiRacing with 296 candidate links on one page and the head's probability distribution over the top eight*
![[jackyk02-424285-vid-04.png]]

## Replies

The post showed 22 replies at fetch; 20 were retrievable, 19 from other people and one from the author, so three are unaccounted for. A root-URL thread fetch returns only 17 of them — it silently caps at 31 tweets — and `bird replies --all` recovered @Douglas_Schon and @latent_node on top. The substantive ones:

- **@johnroodepic** named the mechanism before anyone else and got the only author reply: "the disaggregation is the part builders should steal: a loop scores the same state against many candidate actions, so the state embedding caches perfectly and each candidate collapses to a cheap dot product. that's the economics that makes per-turn decisions affordable." Kwok replied "Exactly!"
- **@YionxpYi** asked the right question about the headline: "9× over Jev is a bold claim. Curious which workload they used for that number." Unanswered. The answer is T-Rex, and 13x is 1,024 candidates of 15 tokens.
- **@latent_node** found the architectural limit: "Since the probabilities are relative to the candidate set, how do you handle a 'none of these fit' case, or an absolute yes/no you want to threshold?" Unanswered, and it is the calibration question in applied form. The model card concedes the premise: "its probabilities are relative to that set."
- **@lastinline98** aimed at the training data: "The claim to check is variance under shift. Contrastive objectives are only as good as the negatives they were trained against." The negatives are Gemini 2.5 Flash-Lite generations against Nemotron DQA questions, so the untested axis is exactly this.
- **@0elsyn** proposed a middle ground the API does not yet have: "For tool routing, have you tried a two-stage version—cache tool selection, then generate the arguments? That seems a useful middle ground between four fixed game moves and entirely fresh action candidates."
- **@schemaevolves** asked "What does as a response to jev or something you have been working in private?" Unanswered, but the artifacts answer it partly: the DeepSWE dataset card describes itself as process-reward-model training data under a personal namespace, and `clm-latest` carries a release date of 2026-09-19.
- **@serqetaa**: "caching state and action embeddings separately is the clever bit. huge for tool routing."
- **@AlekVectis** asked what latency CLM-8B hit on Terminal-Bench; unanswered in thread, though the chart says 32 ms.
- **@Douglas_Schon** wants it measured elsewhere: "We gotta get it numbers on decision bench and jev bench."
- **@SFourdrinier** asked Grok to compare it with Jev, which is the note you are reading.

The remaining nine are reactions: **@raw_works** "impressive stuff!", **@brandon_xyzw** "More bookmarks than likes. That's how you know someone cooked here", **@xzhang_billy** "Contrastive learning is back again!", **@cordobasunset** "Finally, this is what I call real research", **@akatzzzzz** "King", **@kamisamapapa** "文艺复兴!", **@ItsCuthulhu** "adding to the benchmark" with a link, **@testt1234567891** a bare mention of another account, and **@JustLingonberry** "sounds like bullshit tbh".

## Links

- [Thread](https://x.com/jackyk02/status/2102905335925424285) - Jacky Kwok, 2026-09-23 23:37 UTC, 540 likes and 57 reposts at fetch
- [Blog](https://contrastive-lm.notion.site) - the primary write-up
- [GitHub](https://github.com/Contrastive-LM/CLM) - Apache-2.0, 33 stars at capture
- [Discord](https://discord.gg/5dAQEDJBs)
- [Hugging Face org](https://huggingface.co/Contrastive-LM)
- [CLM-v0.1-8B](https://huggingface.co/Contrastive-LM/CLM-v0.1-8B) - Apache-2.0 on Qwen3-8B, the 75,557,149-byte reference head, 6 likes
- [deepswe-clm-heads-8k](https://huggingface.co/Contrastive-LM/deepswe-clm-heads-8k) - MIT, the fine-tuned DeepSWE head with pass@1 and oracle figures
- [deepswe-clm-train-embeddings-8k](https://huggingface.co/datasets/Contrastive-LM/deepswe-clm-train-embeddings-8k) - MIT, 6.20 GB, 405,919 steps across 4,701 trajectories and 113 tasks, 40 downloads
- [CLM-v0.1-Pretrain-Nemotron](https://huggingface.co/datasets/Contrastive-LM/CLM-v0.1-Pretrain-Nemotron) - 1,875 files, 1,023.5 GB, no model card
- [examples/t_rex](https://github.com/Contrastive-LM/CLM/blob/main/examples/t_rex/README.md) - the CLM-vs-Jev runner
- Contact: jackykwok@stanford.edu
- Root video mp4: `https://video.twimg.com/amplify_video/2102904945213358080/vid/avc1/1920x1080/C4ZqK83w5HQLC945.mp4`
- Dino Run mp4: `https://video.twimg.com/amplify_video/2102910060783628288/vid/avc1/1920x1080/nj0_kP7ljPmrNLn7.mp4`
- Super Mario mp4: `https://video.twimg.com/amplify_video/2102910133001129984/vid/avc1/1616x820/xZj15eF1sInizrEv.mp4`
- WikiRacing mp4: `https://video.twimg.com/amplify_video/2102910277708832768/vid/avc1/1280x800/tX22ioYfKaoMXsU2.mp4`
- Resource note: [[CLM]]

## Original Content

> [!quote]- Thread by @jackyk02 (Jacky Kwok), 2026-09-23 to 2026-09-24 - 13 tweets, 540 likes, 57 reposts
>
> **@jackyk02 (Jacky Kwok)** · Wed Sep 23 23:37:56 +0000 2026 · [link](https://x.com/jackyk02/status/2102905335925424285)
>
> Introducing Contrastive Language Model (CLM): an ultra-fast System One Model trained with a contrastive learning objective that connects states and actions.
>
> CLM-8B is pre-trained on internet-scale data and delivers up to 9× faster inference than Jev ⚡ while achieving comparable performance across computer-use, gaming, and tool-calling tasks.
>
> With lightweight fine-tuning, CLM-8B sets a new SOTA on challenging agentic coding benchmarks, such as DeepSWE (81.6%) and Terminal-Bench 2.1 (87.6%). In contrast, Jev fails to serve as an effective verifier for these long-horizon tasks.
>
> We also build an efficient training and serving infra for CLMs by disaggregating states and actions, allowing their embeddings to be cached and reused independently. This substantially reduces inference latency in settings where the state evolves continuously while the action set remains fixed.
>
> Finally, we establish scaling laws for CLMs and show that the test contrastive loss decreases predictably as a power law in training compute, model size, and dataset size.
>
> 📄 Blog: https://t.co/zwi9JOHKGx
> 💻 Code: https://t.co/rsHRYCGR8I
> 🗣️ Discord: https://t.co/Uqtdefvo3J
> 🤗 Data & Models: https://t.co/wdSWGGO3hu
>
> More details on CLM's architecture, data recipe, and scaling laws in the thread below 🧵
>
> VIDEO (80.8 s, 1920x1080, music only, no speech):
> *Zero-shot action classification with the action cache and the per-action softmax*
> ![[jackyk02-424285-vid-01.png]]
>
> ---
>
> **@jackyk02 (Jacky Kwok)** · Wed Sep 23 23:42:03 +0000 2026 · [link](https://x.com/jackyk02/status/2102906369162822006)
>
> 🧵(1) Model Architecture
>
> CLM first trains a state encoder and an action encoder on a large-scale dataset with a contrastive objective, so that each state is pulled toward the ground-truth action and pushed away from all others. The two encoders then serve directly as a zero-shot action classifier.
>
> *Contrastive state-action pre-training, action candidate construction, and zero-shot action classification*
> ![[jackyk02-424285-001.jpg]]
>
> ---
>
> **@jackyk02 (Jacky Kwok)** · Wed Sep 23 23:42:53 +0000 2026 · [link](https://x.com/jackyk02/status/2102906578966122595)
>
> 🧵(2) Data Recipe
>
> We release CLM-8B, which is pre-trained on 60M Nemotron Q&A pairs, mid-trained on 30M synthetic hard negatives, and post-trained on 1M agentic trajectories.
>
> *The three training stages with example items from each*
> ![[jackyk02-424285-002.jpg]]
>
> ---
>
> **@jackyk02 (Jacky Kwok)** · Wed Sep 23 23:43:32 +0000 2026 · [link](https://x.com/jackyk02/status/2102906743558902101)
>
> 🧵(3) Scaling Laws for Verification
>
> We find that the test InfoNCE loss scales as a power law with training compute, dataset size, projection-head size, and encoder size. These dimensions must be scaled jointly to achieve optimal performance. Notably, scaling the encoder size yields the strongest gains.
>
> *The four power-law fits with their exponents*
> ![[jackyk02-424285-003.jpg]]
>
> ---
>
> **@jackyk02 (Jacky Kwok)** · Wed Sep 23 23:51:01 +0000 2026 · [link](https://x.com/jackyk02/status/2102908627304751476)
>
> 🧵(4) Latency vs. Jev and Constrained Decoding
>
> The key difference between CLM and Jev is that Jev only supports state caching, whereas CLM's dual-encoder architecture allows state and action embeddings to be cached independently.
>
> This is particularly useful in applications such as tool calling, computer use, and games, where the action space is predefined and remains fixed.
>
> By caching the action embeddings, CLM substantially reduces inference cost, with the efficiency gains becoming even larger as the number and length of candidate actions grow. At ~1K candidates, CLM is 13× faster than Jev ⚡
>
> *Latency against candidate count and candidate length for CLM, Jev and constrained decoding*
> ![[jackyk02-424285-004.jpg]]
>
> ---
>
> **@jackyk02 (Jacky Kwok)** · Wed Sep 23 23:52:34 +0000 2026 · [link](https://x.com/jackyk02/status/2102909017257558395)
>
> 🧵(5) Zero-Shot Evaluation
>
> Across computer-use, gaming, and tool-calling tasks, CLM-8B performs on par with Jev while running up to 9× faster. The speedups are most pronounced when the number of candidates is large (e.g., WikiRacing) or when actions can be reused frequently across states (e.g., T-Rex Game).
>
> CLM-35B, with improved generalization and even greater speedups, will be released early next month.
>
> *Zero-shot latency and success rate on four tasks*
> ![[jackyk02-424285-005.png]]
>
> ---
>
> **@jackyk02 (Jacky Kwok)** · Wed Sep 23 23:55:32 +0000 2026 · [link](https://x.com/jackyk02/status/2102909765068484694)
>
> 🧵(6) Agentic Benchmarks
>
> We find that Jev fails to serve as a verifier for long-horizon tasks, performing below the random-selection (Pass@1) baseline.
>
> In contrast, with lightweight fine-tuning, CLM achieves SOTA performance on challenging agentic benchmarks, including DeepSWE (81.6%) and Terminal-Bench 2.1 (87.6%), while delivering 4–6× faster inference than Jev.
>
> *DeepSWE and Terminal-Bench 2.1 success rate and verifier latency against the random-selection baseline*
> ![[jackyk02-424285-006.jpg]]
>
> ---
>
> **@jackyk02 (Jacky Kwok)** · Wed Sep 23 23:56:47 +0000 2026 · [link](https://x.com/jackyk02/status/2102910077363683504)
>
> 🧵(7) Dino Run Demo https://t.co/qSybmYJ4P0
>
> VIDEO (9.5 s, 1920x1080, no audio):
> *CLM at 16 ms and score 00066 against Jev at 150 ms and 00013, labelled Zero-Shot on 4090 GPU*
> ![[jackyk02-424285-vid-02.png]]
>
> ---
>
> **@jackyk02 (Jacky Kwok)** · Wed Sep 23 23:57:09 +0000 2026 · [link](https://x.com/jackyk02/status/2102910172389933179)
>
> 🧵(8) Super Mario Demo https://t.co/fWpWBn0VJ5
>
> VIDEO (50 s, 1616x820, no audio):
> *CLM progress 2644 at 34.6 ms decision latency against Jev progress 1948 at 131.8 ms*
> ![[jackyk02-424285-vid-03.png]]
>
> ---
>
> **@jackyk02 (Jacky Kwok)** · Wed Sep 23 23:57:40 +0000 2026 · [link](https://x.com/jackyk02/status/2102910301087936846)
>
> 🧵(9) WikiRacing Demo https://t.co/kokUhH25zZ
>
> VIDEO (20.64 s, 1280x800, no audio):
> *296 candidate links on one page and the head's probability distribution over the top eight*
> ![[jackyk02-424285-vid-04.png]]
>
> ---
>
> **@jackyk02 (Jacky Kwok)** · Wed Sep 23 23:59:47 +0000 2026 · [link](https://x.com/jackyk02/status/2102910833550659937)
>
> CLM comes with an interactive playground on GitHub: https://t.co/fWh59EG7ME https://t.co/eo6yH5Gd75
>
> *The playground with three typed questions and their answer distributions*
> ![[jackyk02-424285-007.jpg]]
>
> ---
>
> **@jackyk02 (Jacky Kwok)** · Thu Sep 24 00:00:44 +0000 2026 · [link](https://x.com/jackyk02/status/2102911073653494209)
>
> CLM-8B is part of our scaling ladder, where we train models across multiple scales to establish scaling laws and predict performance at larger scales. A multimodal CLM-35B is now in training with more data, compute, and parameters. Stay tuned for the release early next month 🚀
>
> ---
>
> **@jackyk02 (Jacky Kwok)** · Thu Sep 24 00:01:49 +0000 2026 · [link](https://x.com/jackyk02/status/2102911343640940966)
>
> Joint work with @hangoo_kang @TarunSures41845 @JonSaadFalcon @drmapavone @Azaliamirh and @HazyResearch

> [!quote]- Replies - all 20 retrievable of 22 shown on the post, verbatim, in time order
>
> **@johnroodepic (John Rood)** · Thu Sep 24 00:19:39 +0000 2026 · [link](https://x.com/johnroodepic/status/2102915831936266319)
> @jackyk02 the disaggregation is the part builders should steal: a loop scores the same state against many candidate actions, so the state embedding caches perfectly and each candidate collapses to a cheap dot product. that's the economics that makes per-turn decisions affordable.
>
> **@AlekVectis (Alek)** · Thu Sep 24 00:25:46 +0000 2026 · [link](https://x.com/AlekVectis/status/2102917371338039544)
> @jackyk02 jacky - what latency did CLM-8B hit on Terminal-Bench?
>
> **@ItsCuthulhu (Cuth)** · Thu Sep 24 00:33:35 +0000 2026 · [link](https://x.com/ItsCuthulhu/status/2102919339750101172)
> @jackyk02 adding to the benchmark https://t.co/usUtcKzpTR
>
> **@YionxpYi (yi)** · Thu Sep 24 00:34:53 +0000 2026 · [link](https://x.com/YionxpYi/status/2102919666117021752)
> @jackyk02 9× over Jev is a bold claim. Curious which workload they used for that number.
>
> **@raw_works (Raymond Weitekamp)** · Thu Sep 24 00:41:40 +0000 2026 · [link](https://x.com/raw_works/status/2102921372041183261)
> @jackyk02 impressive stuff!
>
> **@serqetaa (Suraj)** · Thu Sep 24 00:43:39 +0000 2026 · [link](https://x.com/serqetaa/status/2102921873264886100)
> @jackyk02 caching state and action embeddings separately is the clever bit. huge for tool routing
>
> **@schemaevolves (Gradient Notes)** · Thu Sep 24 00:44:35 +0000 2026 · [link](https://x.com/schemaevolves/status/2102922108099494136)
> @jackyk02 What does as a response to jev or something you have been working in private?
>
> **@kamisamapapa (kamisama)** · Thu Sep 24 00:48:46 +0000 2026 · [link](https://x.com/kamisamapapa/status/2102923159423041845)
> @jackyk02 文艺复兴！
>
> **@0elsyn (智0elsyn)** · Thu Sep 24 01:13:44 +0000 2026 · [link](https://x.com/0elsyn/status/2102929444260196676)
> The independent action cache is the appealing part for me: a changing state doesn't force you to re-encode the same menu of actions. For tool routing, have you tried a two-stage version—cache tool selection, then generate the arguments? That seems a useful middle ground between four fixed game moves and entirely fresh action candidates.
>
> **@brandon_xyzw (Brandon)** · Thu Sep 24 01:20:54 +0000 2026 · [link](https://x.com/brandon_xyzw/status/2102931248054431943)
> @jackyk02 More bookmarks than likes. That's how you know someone cooked here
>
> **@xzhang_billy (Xuan (Billy) Zhang)** · Thu Sep 24 01:28:42 +0000 2026 · [link](https://x.com/xzhang_billy/status/2102933208996388911)
> @jackyk02 Contrastive learning is back again!
>
> **@testt1234567891 (jmp_0x0)** · Thu Sep 24 01:36:01 +0000 2026 · [link](https://x.com/testt1234567891/status/2102935053080649972)
> @jackyk02 @ErickSky
>
> **@JustLingonberry (Just_Lingonberry_352)** · Thu Sep 24 01:40:46 +0000 2026 · [link](https://x.com/JustLingonberry/status/2102936247379677390)
> @jackyk02 sounds like bullshit tbh
>
> **@cordobasunset (Omar Ramadan)** · Thu Sep 24 01:41:13 +0000 2026 · [link](https://x.com/cordobasunset/status/2102936359652778017)
> @jackyk02 Finally, this is what I call real research
>
> **@akatzzzzz (R-E)** · Thu Sep 24 01:47:52 +0000 2026 · [link](https://x.com/akatzzzzz/status/2102938031288140157)
> @jackyk02 King
>
> **@jackyk02 (Jacky Kwok)** · Thu Sep 24 01:56:43 +0000 2026 · [link](https://x.com/jackyk02/status/2102940261261386081) — AUTHOR REPLY, to @johnroodepic
> @johnroodepic Exactly!
>
> **@lastinline98 (lastinline)** · Thu Sep 24 01:59:39 +0000 2026 · [link](https://x.com/lastinline98/status/2102940999341248702)
> @jackyk02 The claim to check is variance under shift. Contrastive objectives are only as good as the negatives they were trained against.
>
> **@SFourdrinier (Stephane)** · Thu Sep 24 02:00:20 +0000 2026 · [link](https://x.com/SFourdrinier/status/2102941168699117792)
> @jackyk02 @grok explain exactly what this is, and how can I use it, for what. Compare with Jev from typesafeAi
>
> **@latent_node (Latent Node)** · Thu Sep 24 02:05:17 +0000 2026 · [link](https://x.com/latent_node/status/2102942415250424076)
> @jackyk02 Congrats, the state and action caching is the part I haven't seen elsewhere. Since the probabilities are relative to the candidate set, how do you handle a "none of these fit" case, or an absolute yes/no you want to threshold?
>
> **@Douglas_Schon (Douglas Schonholtz)** · Thu Sep 24 02:08:30 +0000 2026 · [link](https://x.com/Douglas_Schon/status/2102943227342971378)
> @jackyk02 We gotta get it numbers on decision bench and jev bench

#### Blog (contrastive-lm.notion.site)

> [!quote]- Full blog text, verbatim, with all four collapsed toggles expanded - 2,330 words
>
> Skip to content
> Contrastive Language Models
> Get Notion free
> Contrastive Language Models
> A System One Model for Fast and Generalizable Decision-Making
> Jacky Kwok
> †
> †
> , Hangoo Kang, Tarun Suresh, Jon Saad-Falcon, Marco Pavone
> Christopher Ré, Azalia Mirhoseini Stanford University  NVIDIA Research
> †
> †
>  Project Lead
>  Posted: Sep 23, 2026
> New Architecture, Data Recipe, and Scaling Laws
> We introduce Contrastive Language Models (CLMs), a new class of System One model trained with a contrastive learning objective that connects states and actions.
> We release CLM-8B, which is pre-trained on 60M Nemotron Q&A pairs, mid-trained on 30M synthetic hard negatives, and post-trained on 1M agentic trajectories.
> CLM-8B delivers performance comparable to Jev across computer-use, gaming, and tool-calling tasks, while achieving up to 9× lower latency. With lightweight fine-tuning, CLM-8B also sets a new SOTA on challenging agentic coding benchmarks, including DeepSWE (81.6%) and Terminal Bench 2.1 (87.6%).
> We build an ultra-efficient training and serving infra for CLM by disaggregating states and actions, allowing their embeddings to be cached and reused independently.
> We establish scaling laws for CLMs and show that the test contrastive loss decreases predictably as a power law in training compute, model size, and dataset size.
> Try CLM on GitHub:
> Overview
> CLM first trains a state encoder and an action encoder on a large-scale dataset with a contrastive objective (InfoNCE), so that each state is pulled toward the ground truth action that was taken and pushed away from all others. The two encoders then serve directly as a zero-shot action classifier.
> At deployment, given the current state and a set of candidate actions, CLM scores each action by how well its embedding aligns with the state embedding and selects the highest-scoring action.
> Dino Run (CLM vs. Jev)
> Super Mario Demo
>                  CLM  (~4x Faster than Jev)                                                                Jev
> WikiRacing Demo
> Starting from the Wikipedia page on plate tectonics, can a CLM navigate to the destination page on bioluminescence?
> Zero-shot Evaluation
> Across computer-use, gaming, and tool-calling tasks, CLM-8B performs on par with Jev while running up to 9× faster. The speedups are most pronounced when the number of candidate actions is large (e.g., WikiRacing) or when actions can be frequently reused across states (e.g., T-Rex Game).
> Agentic Benchmarks
> We find that Jev fails to serve as a verifier for long-horizon tasks, performing below the random-selection (Pass@1) baseline. In contrast, with lightweight fine-tuning, CLM achieves SOTA performance on challenging agentic benchmarks, including DeepSWE (81.6%) and Terminal-Bench 2.1 (87.6%), while delivering 4–6× faster inference than Jev.
> Click to View More Experimental Details
> For each task, we sample multiple candidate solutions using Opus 5 for DeepSWE and Fable 5 for Terminal-Bench 2.1. CLM or Jev then serves as the verifier, selecting the best solution from the candidate set. We evaluate performance on 38 held-out DeepSWE tasks and 30 held-out Terminal-Bench 2.1 tasks. Latency is measured on an H100 GPU.
> Model Architecture
> A CLM consists of a state encoder and an action encoder, as illustrated in Figure 1. Both encoders map their respective inputs into a shared embedding space, where the score of a state–action pair is computed as the cosine similarity between their embeddings.
> Each encoder consists of a frozen LLM backbone followed by a trainable projection head. We take the hidden state of the final token, normalize it, and pass it through a MLP projection head. Only the 20M-parameter projection head is trained; the LLM remains frozen and never receives gradients. This design makes our scaling experiments inexpensive to run. We precompute the LLM embeddings once, then reuse them to train projection heads across different setups. A full pre-training run on the Nemotron DQA dataset takes about an hour on a single RTX 4090 GPU.
> Most importantly, since states and actions are disaggregated, their embeddings can be cached independently. In settings where the state evolves continuously (e.g., Super Mario) while the action set remains fixed, we only need to recompute the state embedding at each step and can reuse the cached action embeddings. This substantially reduces inference cost, with the efficiency gains becoming increasingly significant as the number of candidate actions and context length grows. At ~1k candidates, CLM is 13x faster than Jev.
> Click to View More Experimental Details
> Since candidate action embeddings are cached, each CLM query requires only a single forward pass over the state followed by cosine-similarity computation against the cached candidate embeddings. We measure the practical efficiency gains against two baselines: constrained decoding using the same Qwen3-8B backbone (a single prefill over the state and all candidate options, followed by a softmax over option labels) and Jev, accessed through the TypeSafe API. All experiments use a 200-token state on a single 4090 GPU with 5 trials.
> Scaling the number of candidates. With 15 tokens per candidate, CLM latency increases only slightly, from 36 ms with 1 candidate to 44 ms with 1,024 candidates. Constrained decoding must process every candidate on every query, reaching 4.3 s and making it roughly 97× slower than CLM at 1k candidates. Jev increases from 131 ms to 579 ms, making CLM roughly 13× faster at 1,024 candidates.
> Scaling candidate length. With the number of candidates fixed at 5, CLM latency remains essentially flat at ~36 ms as candidate length increases from 1 to 2,048 tokens. In contrast, constrained decoding grows from 49 ms to 3.4 s, making it approximately 95× slower than CLM. Jev reaches 333 ms, approximately 9× slower than CLM.
> Note: The projection head is a three-layer MLP that maps the 4,096-dimensional Qwen3-8B hidden state to a 512-dimensional embedding through a width of 1,536 (4096 → 1536 → 1536 → 512, GELU activations and a LayerNorm on the hidden layer).
> How does “Action Caching” work for CLM in Super Mario?
> The 4 action embeddings are precomputed before gameplay begins. At each step, only the new game state passes through the state encoder. Its embedding
> 𝑧
> 𝑠
> z
> s
> 	​
>
>  is then scored against the cached action embeddings
> 𝑧
> 𝑎
> z
> a
> 	​
>
>  , and the highest-scoring action is executed. This reduces the cost from 5 forward passes to just 1 per step.
> Training Algorithm
> CLM is trained with a bidirectional InfoNCE loss. Given a batch of
> 𝐵
> B matched state-action pairs, we compute a
> 𝐵
> ×
> 𝐵
> B×B similarity matrix. For each positive pair
> (
> 𝑠
> 𝑖
> ,
> 𝑎
> 𝑖
> )
> (s
> i
> 	​
>
> ,a
> i
> 	​
>
> ), we optimize retrieval in both directions:
> 𝑠
> 𝑖
> →
> 𝑎
> 𝑖
> s
> i
> 	​
>
> →a
> i
> 	​
>
>  and
> 𝑎
> 𝑖
> →
> 𝑠
> 𝑖
> a
> i
> 	​
>
> →s
> i
> 	​
>
> :
> 𝐿
> C
> L
> M
> =
> −
> 1
> 2
> 𝐵
> ∑
> 𝑖
> [
> log
> ⁡
> exp
> ⁡
> (
> 𝑠
> 𝑖
> ⊤
> 𝑎
> 𝑖
> /
> 𝜏
> )
> ∑
> 𝑗
> exp
> ⁡
> (
> 𝑠
> 𝑖
> ⊤
> 𝑎
> 𝑗
> /
> 𝜏
> )
> +
> log
> ⁡
> exp
> ⁡
> (
> 𝑎
> 𝑖
> ⊤
> 𝑠
> 𝑖
> /
> 𝜏
> )
> ∑
> 𝑗
> exp
> ⁡
> (
> 𝑎
> 𝑖
> ⊤
> 𝑠
> 𝑗
> /
> 𝜏
> )
> ]
> L
> CLM
> 	​
>
> =−
> 2B
> 1
> 	​
>
> i
> ∑
> 	​
>
> [log
> ∑
> j
> 	​
>
> exp(s
> i
> ⊤
> 	​
>
> a
> j
> 	​
>
> /τ)
> exp(s
> i
> ⊤
> 	​
>
> a
> i
> 	​
>
> /τ)
> 	​
>
> +log
> ∑
> j
> 	​
>
> exp(a
> i
> ⊤
> 	​
>
> s
> j
> 	​
>
> /τ)
> exp(a
> i
> ⊤
> 	​
>
> s
> i
> 	​
>
> /τ)
> 	​
>
> ]
> For mid-training, we extend the bidirectional InfoNCE objective with hard negatives. Let
> ℎ
> 𝑖
> 𝑘
> (
> 𝑎
> )
> h
> ik
> (a)
> 	​
>
>  denote a hard negative action for state
> 𝑠
> 𝑖
> s
> i
> 	​
>
> . For the state-to-action direction, the loss is:
> 𝐿
> 𝑠
> →
> 𝑎
> h
> a
> r
> d
> =
> −
> 1
> 𝐵
> ∑
> 𝑖
> log
> ⁡
> exp
> ⁡
> (
> 𝑠
> 𝑖
> ⊤
> 𝑎
> 𝑖
> /
> 𝜏
> )
> exp
> ⁡
> (
> 𝑠
> 𝑖
> ⊤
> 𝑎
> 𝑖
> /
> 𝜏
> )
> +
> ∑
> 𝑘
> exp
> ⁡
> (
> 𝑠
> 𝑖
> ⊤
> ℎ
> 𝑖
> 𝑘
> (
> 𝑎
> )
> /
> 𝜏
> )
> .
> L
> s→a
> hard
> 	​
>
> =−
> B
> 1
> 	​
>
> i
> ∑
> 	​
>
> log
> exp(s
> i
> ⊤
> 	​
>
> a
> i
> 	​
>
> /τ)+∑
> k
> 	​
>
> exp(s
> i
> ⊤
> 	​
>
> h
> ik
> (a)
> 	​
>
> /τ)
> exp(s
> i
> ⊤
> 	​
>
> a
> i
> 	​
>
> /τ)
> 	​
>
> .
> Scaling Laws for Verification
> We find that the test InfoNCE loss
> 𝐿
> L scales as a power law with training compute
> 𝐶
> C, dataset size
> 𝐷
> D, projection-head size
> 𝑁
> N, and encoder size
> 𝑁
> e
> n
> c
> N
> enc
> 	​
>
> . These dimensions must be scaled jointly to achieve the optimal verification performance. When each scale factor is not bottlenecked by the others, the dependence on each variable
> 𝑋
> ∈
> 𝐶
> ,
> 𝐷
> ,
> 𝑁
> ,
> 𝑁
> e
> n
> c
> X∈C,D,N,N
> enc
> 	​
>
>  can be described as:
> 𝐿
> (
> 𝑋
> )
> ≈
> (
> 𝑋
> 𝑐
> 𝑋
> )
> 𝛼
> 𝑋
> ,
> L(X)≈(
> X
> X
> c
> 	​
>
> 	​
>
> )
> α
> X
> 	​
>
> ,
> where
> 𝑋
> 𝑐
> X
> c
> 	​
>
>  is a fitted scale constant and
> 𝛼
> 𝑋
> α
> X
> 	​
>
>  is the corresponding scaling exponent following Kaplan et al. Notably, scaling the encoder size yields the strongest gains. Experiments are conducted on the Nemotron DQA dataset and evaluated on a held-out dataset.
> Data vs. Optimal Model Size
> We fix a compute budget
> 𝐶
> C and plot the test loss against the parameter count of the projection head
> 𝑁
> N, with each curve corresponding to a different data budget
> 𝐷
> D. In log-parameter space, each iso-FLOP curve is well approximated by a parabola, and its minimum identifies the optimal head size for that data budget. As the budget grows, the optimum shifts steadily toward larger heads. Specifically, the optimal size grows almost exactly linearly with the number of training tokens
> 𝑁
> ∗
> ∝
> 𝐷
> 1.02
> N
> ∗
> ∝D
> 1.02
> , at roughly 310 tokens per parameter.
> Data Recipe
> CLM is trained in three stages, with each stage introducing a progressively harder form of state–action alignment. Pre-training learns broad semantic representations, mid-training develops fine-grained discrimination, and post-training adapts the representation space for action classification.
> Stage 1 — Pre-training. We first pre-train CLM on an internet-scale question–answer dataset containing ~60M pairs from Nemotron DQA. We treat each question as the state and its answer as the corresponding action. This stage learns broad semantic representations from a diverse corpus.
> Stage 2 — Mid-training. We then introduce ~30M synthetic hard negatives generated by Gemini 2.5 Flash-Lite. For a subset of Nemotron DQA questions, we construct semantically similar but incorrect answers. These negatives are precomputed and incorporated into the InfoNCE loss using Equation 2, enabling more fine-grained discrimination between plausible actions.
> Stage 3 — Post-training. Finally, we post-train CLM on ~1M agent trajectories from the Agent Data Protocol (ADP) dataset, supplemented by terminal traces from Endless-Terminals, LiteCoder-Terminal-SFT. Each trajectory step is represented as a state–action pair, where the state contains the agent’s current context and the action corresponds to the decision taken at that step. This adapts the learned representation space for action classification in agentic environments.
> Evaluating CLM after Pre-training
> We first evaluate CLM-8B immediately after pre-training. As illustrated above, when asked “Who wrote the play Romeo and Juliet?”, the Qwen3-8B embeddings assign the highest probability to an incorrect answer and ranks “William Shakespeare” third.
> In contrast, CLM-8B correctly ranks “William Shakespeare” first with 54.2%. This suggests that pre-training reshapes the model’s representations into a useful decision space.
> Data Mixture for Post-Training
> To preserve the general representations learned during pre-training, we use co-training with data replay rather than fine-tuning exclusively on agentic traces. Specifically, 40% of the post-training mixture consists of the Nemotron DQA examples, while the remaining 60% are agentic trajectories.
> This replay substantially mitigates catastrophic forgetting. With replay, the Nemotron hard-negative top-1 accuracy decreases slightly from 69% to 68.5%. In contrast, when training on agentic data alone for the same number of agentic steps, the accuracy drops to 56.2%.
> Why Not Train on Hard Negatives from the Start?
> We compare two training strategies under a fixed compute budget:
> Pre-train + Mid-train: pre-train on the full Nemotron DQA corpus with bidirectional InfoNCE, then briefly mid-train on hard negatives using Equation 2.
> Hard negatives from scratch: train on Nemotron DQA and hard negatives jointly from the beginning.
> We evaluate on ~100K held-out questions, each with one gold answer and 10 hard negatives. The top-1 accuracy measures whether the gold answer ranks highest. We find that pre-training alone reaches 52.1% without seeing any hard negatives. A short mid-training stage then boosts accuracy to 69.2%. In contrast, training with hard negatives from the start improves quickly but peaks at 62.4% before overfitting. The two-stage recipe achieves 7% higher accuracy at fixed budget.
> Takeaway: Hard negatives work best as a refinement signal on top of pre-training, rather than as a substitute for it.
> CLM Playground
> CLM comes with a playground on GitHub. Write a state, add typed questions, and see CLM's full probability distribution over the answers in milliseconds.
> Join us!
>  We call on the community to join us in this effort, either by providing your feedback or contributing to the project!
> Please don’t hesitate to get in touch:
> Github Repo: https://github.com/Contrastive-LM/CLM
> Join Discord: https://discord.gg/5dAQEDJBs
> Contact: jackykwok@stanford.edu
> Conclusion
> CLM opens up a new direction for scalable, reliable, and fast verification. Moving forward, we plan to explore several key directions:
> Scaling Experiments: Extend our scaling-law experiments to substantially larger backbones and study how verification performance can be further scaled
> Vision and multimodal support: Extend CLM to include images, video, and other modalities for robotics and computer-use tasks.
> Scaling the data recipe: Expand pre-training, hard-negative mining, and agentic post-training.
> …and more to come.
> CLM-8B is part of our scaling ladder, where we train models across multiple scales to establish scaling laws and predict performance at larger scales. A multimodal CLM-35B is now in training with more data, compute, and parameters. Stay tuned for the release early next month ​
> Citation
> If you find CLM useful, please consider citing it:
> @misc{kwok2026contrastivelanguagemodels,
>   title={Contrastive Language Models: A System One Model for Fast and Generalizable Decision-Making},
>   author={Jacky Kwok and Hangoo Kang and Tarun Suresh and Jon Saad-Falcon and Marco Pavone and Christopher Ré and Azalia Mirhoseini},
>   year={2026},
>   note={Notion Blog}
> }
>
> ​

#### README (github.com/Contrastive-LM/CLM)

> [!quote]- Full README, verbatim - 2,837 words
>
> <!-- markdownlint-disable MD001 MD041 -->
> <p align="center">
>   <picture>
>     <img alt="CLM v0.1" src="assets/logo.png" width=45%>
>   </picture>
> </p>
>
> <h3 align="center">
> Contrastive Language Models
> </h3>
>
> <p align="center">
> <i>A System One Model for Fast and Generalizable Decision-Making</i>
> </p>
>
> <p align="center">
> | 📄 <a href="https://contrastive-lm.notion.site"><b>Blog</b></a> | 🗣️ <a href="https://discord.gg/5dAQEDJBs"><b>Discord</b></a> | 🤗 <a href="https://huggingface.co/Contrastive-LM"><b>Data &amp; Models</b></a> | 📚 <a href="#api-reference"><b>API Reference</b></a> | 🛠️ <a href="#fine-tuning-clm-on-your-own-data"><b>Fine-Tuning Tutorial</b></a> |
> </p>
>
> 🔥 **Contrastive Language Models (CLMs)** are a new class of **System One
> model** trained with a **contrastive learning** objective that connects
> **states and actions**. This repo serves **CLM-8B** behind a
> TypeSafe-compatible API.
>
> - **CLM-8B** is pre-trained on **60M Nemotron Q&A pairs**, mid-trained on
>   **30M synthetic hard negatives**, and post-trained on **1M agentic
>   trajectories**.
> - It performs on par with **Jev** across computer-use, gaming and tool-calling
>   tasks with up to **9× lower latency**. With lightweight fine-tuning it sets a
>   new SOTA as a verifier on agentic coding benchmarks: **Terminal-Bench 2.1
>   (87.6%)** and **DeepSWE (81.6%)**.
> - **States and actions are disaggregated**, so their embeddings are cached and
>   reused independently, which makes training and serving cheap and blazing fast!
>
> We invite the community to plug it into their own agents and benchmarks!
>
> ---
>
> ## Installation
>
> ```bash
> git clone https://github.com/Contrastive-LM/CLM.git && cd CLM
> pip install -r requirements.txt
> ```
>
> Requires Python 3.10+, Linux and an NVIDIA GPU. Installs everything, including PyTorch and vLLM.
>
> ---
>
> ## Quickstart
>
> ### Serve
>
> ```bash
> # 1. encoder: Qwen3-8B, last-token pooling (what the reference head was trained against)
> vllm serve Qwen/Qwen3-8B --served-model-name qwen3-8b --runner pooling \
>      --enable-prefix-caching --max-model-len 2048 --gpu-memory-utilization 0.35 --port 8090
>
> # 2. API — downloads the reference head (Contrastive-LM/CLM-v0.1-8B, 75 MB) on first run
> clm-serve --port 8700 --emb-url http://127.0.0.1:8090/v1/embeddings
> ```
>
> ### Ask typed questions about a state
>
> ```python
> from clm import CLMClient, Choice, Noul, Score
>
> client = CLMClient()                          # CLM_BASE_URL (default http://127.0.0.1:8700), CLM_API_KEY
> r = client.system_one(
>     state="Customer: my invoice was charged twice and nobody answers the phone!",
>     questions={
>         "urgency": Noul(instructions="Is this urgent?"),
>         "department": Choice(instructions="Which team should handle this?",
>                              criteria={"billing": "Charges, invoices, refunds",
>                                        "technical": "Bugs and outages"}),
>         "frustration": Score(instructions="How frustrated is the customer?",
>                              criteria=["Calm", "Frustrated", "Very angry"]),
>     },
> )
> print(r.answers["urgency"].noul)                # 0.41022     probability the statement is true
> print(r.answers["department"].choice)           # billing
> print(r.answers["department"].probabilities)    # {'billing': 0.93878, 'technical': 0.06122}
> print(r.answers["frustration"].score)           # 1.98386     expected level, 0..2
> print(r.usage.input_tokens, r.latency_ms)       # 38 58.1     (106 tokens on a cold cache: option texts are embedded once)
> ```
>
> Questions may be `Noul` / `Choice` / `Score` objects or plain wire-format
> dicts, so a request written for TypeSafe replays as
> `client.system_one(state, questions)`.
>
> ### Rank candidates directly
>
> `system_one` is built on one primitive: score a candidate against a state.
> For free-form candidates (best-of-N answers, tool names, next moves) use the
> in-process engine's `rank`:
>
> ```python
> from clm import Engine
>
> engine = Engine(emb_url="http://127.0.0.1:8090/v1/embeddings")     # reference head, downloaded if missing
> engine.rank("What causes tides on Earth?",
>             ["The Moon's gravitational pull.", "Photosynthesis in plants.", "Because the Earth is round."])
> # [{'rank': 1, 'candidate': "The Moon's gravitational pull.", 'prob': 0.997}, ...]
>
> engine.answer(state, questions)      # the same dict the HTTP endpoint returns, no server needed
> ```
>
> ---
>
> ## Playground
>
> `clm-serve` also serves a web UI at `/` (`http://localhost:8700/` by default).
> Write a state, add typed questions, and see CLM's answer distributions; every
> request is also shown as JSON, `curl` and Python. A **Rank** tab ranks any
> candidate set, and links are shareable.
>
> <p align="center">
>   <picture>
>     <img alt="The CLM playground: a state on the left with three typed questions, their answer distributions on the right"
>          src="assets/playground.png" width=100%>
>   </picture>
>   <br>
>   <sub>Captured against a real <code>clm-serve</code> (<code>clm-latest</code>, Qwen3-8B encoder on one RTX 4090).</sub>
> </p>
>
> Remote server? `ssh -L 8700:localhost:8700 <host>`. API only: `clm-serve --no-ui`.
>
> ---
>
> ## Results
>
> ### Zero-shot evaluation
>
> <p align="center">
>   <img alt="Zero-shot latency and success rate, CLM-8B vs Jev, on T-Rex, BFCL v4 tool calling, WikiRacing and Super Mario" src="assets/zero-shot.png" width=100%>
> </p>
>
> Across **computer-use, gaming and tool-calling tasks**, CLM-8B performs on par
> with Jev while running **up to 9× faster**. The speedups are largest when the
> number of candidate actions is large (WikiRacing) or when actions are reused
> across states (the T-Rex game). The T-Rex benchmark ships in this repo:
> see [examples/t_rex](examples/t_rex/README.md).
>
> ### Agentic benchmarks: CLM as a verifier
>
> <p align="center">
>   <img alt="DeepSWE and Terminal-Bench 2.1: success rate and verifier latency, CLM vs Jev" src="assets/agentic.png" width=100%>
> </p>
>
> For each task we sample several candidate solutions (**Opus 5** for DeepSWE,
> **Fable 5** for Terminal-Bench 2.1), and CLM or Jev acts as the verifier that
> picks the best one. Evaluated on **38 held-out DeepSWE tasks** and **30
> held-out Terminal-Bench 2.1 tasks**; latency on an H100. Jev fails to serve as
> a verifier for these long-horizon tasks, scoring below pass@1. With lightweight
> fine-tuning, CLM reaches SOTA on both (**81.6%** and **87.6%**) while running
> **4.1–5.7× faster than Jev**.
>
> ---
>
> ## Fine-tuning CLM on Your Own Data
>
> See [docs/FINETUNING.md](docs/FINETUNING.md).
>
> ```bash
> # reproduce the task-disjoint DeepSWE heldout-38 result (31/38 = 81.6%)
> hf download Contrastive-LM/deepswe-clm-heads-8k --local-dir heads/deepswe
> python evaluation/bon_eval.py --hf-dataset Contrastive-LM/deepswe-clm-embeddings-8k \
>     --checkpoint heads/deepswe/best_head.pt \
>     --tasks-file heads/deepswe/heldout_tasks.json --n 4 --window 12
>
> # fine-tune the matching DeepSWE head
> hf download Contrastive-LM/CLM-v0.1-8B CLM_v0.1-8B.pt --local-dir ckpts
> python train/finetune.py --task clm --hf-dataset Contrastive-LM/deepswe-clm-train-embeddings-8k \
>     --init-ckpt ckpts/CLM_v0.1-8B.pt --out-dir runs/deepswe \
>     --holdout-tasks heads/deepswe/heldout_tasks.json --batch 512 --seed 1234
>
> # typed decisions
> python train/finetune.py --task choice --data LocalLLaMA/typed-decisions --workflow all \
>     --init-ckpt ckpts/CLM_v0.1-8B.pt --out-dir runs/typed
> ```
>
> ---
>
> ## How it works
>
> ### About
>
> CLM first trains a **state encoder** and an **action encoder** on a
> large-scale dataset with a contrastive objective (InfoNCE), so that each state
> is pulled toward the ground-truth action that was taken and pushed away from
> all others. The two encoders then serve directly as a zero-shot action
> classifier: at deployment, given the current state and a set of candidate
> actions, CLM scores each action by how well its embedding aligns with the
> state embedding and selects the highest-scoring action.
>
> That is what this package serves. A typed question is a state plus a closed
> set of candidate actions (the options and their descriptions); a softmax over
> CLM's scores *is* the answer distribution, and the same call ranks best-of-N
> trajectories, routes tools, shortlists retrieval pools and answers typed
> decisions with no per-task setup.
>
> **Architecture, data recipe and scaling laws:**
>
> - Each encoder is a frozen LLM backbone plus a 20M-parameter trainable
>   projection head, so inference is one
>   embedding per fresh text and a dot product per cached candidate.
> - CLM is **pre-trained** on internet-scale Q&A, **mid-trained** on synthetic
>   hard negatives, **post-trained** on agentic traces, and can be easily
>   fine-tuned on downstream tasks ([data recipe](#data-recipe)).
> - The InfoNCE loss **decreases predictably as a power law** in training
>   compute, model size and dataset size ([details](#scaling-laws-for-verification)).
>
> ```
> browser ──► clm-serve  (CPU, :8700)   GET / (playground)
> client  ──►                          POST /v1/systemone · GET /v1/models · GET /health
>                │       state head + action head (20M params, hot-reloaded), embedding cache
>                ▼
>           vLLM Qwen3-8B pooling server (GPU, :8090)   /v1/embeddings
> ```
>
> ### Training Algorithm
>
> CLM is trained with a bidirectional InfoNCE loss. Given a batch of $B$
> matched state–action pairs, we compute a $B \times B$ similarity matrix and,
> for each positive pair $(s_i, a_i)$, optimize retrieval in both directions
> ($s_i \rightarrow a_i$ and $a_i \rightarrow s_i$):
>
> ```math
> L_{\mathrm{CLM}} = -\frac{1}{2B}\sum_i \left[ \log \frac{\exp\left(s_i^\top a_i/\tau\right)} {\sum_j \exp\left(s_i^\top a_j/\tau\right)} + \log \frac{\exp\left(a_i^\top s_i/\tau\right)} {\sum_j \exp\left(a_i^\top s_j/\tau\right)} \right]
> ```
>
> For mid-training, the objective is extended with hard negatives. Let
> $h_{ik}^{(a)}$ denote a hard negative action for state $s_i$; the
> state-to-action direction becomes
>
> ```math
> L_{s \rightarrow a}^{\mathrm{hard}}=-\frac{1}{B}\sum_i\log\frac{\exp\left(s_i^\top a_i / \tau\right)}{\exp\left(s_i^\top a_i / \tau\right)+\sum_k\exp\left(s_i^\top h_{ik}^{(a)} / \tau\right)}.
> ```
>
> ### Scaling Laws for Verification
>
> The test InfoNCE loss $L$ scales as a power law with training compute $C$,
> dataset size $D$, projection-head size $N$ and encoder size
> $N_{\mathrm{enc}}$. These dimensions must be scaled jointly for the best
> verification performance; when a scale factor is not bottlenecked by the
> others, the dependence on each variable $`X \in \{C, D, N, N_{\mathrm{enc}}\}`$
> is
>
> ```math
> L(X) \approx \left(\frac{X_c}{X}\right)^{\alpha_X},
> ```
>
> where $X_c$ is a fitted scale constant and $\alpha_X$ the corresponding
> scaling exponent, following Kaplan et al. Scaling the encoder size yields the
> strongest gains. Experiments are conducted on the Nemotron DQA dataset and
> evaluated on a held-out set; the fits and figures are in the
> [blog post](https://contrastive-lm.notion.site).
>
> **Data vs. optimal model size.** At a fixed compute budget, each iso-FLOP
> curve of test loss against head size is well approximated by a parabola in
> log-parameter space, and its minimum gives the optimal head size for that data
> budget. The optimum grows almost exactly linearly with the number of training
> tokens, $N^* \propto D^{1.02}$, at roughly **310 tokens per parameter**.
>
> ### Data Recipe
>
> CLM is trained in three stages, each a progressively harder form of
> state–action alignment:
>
> 1. **Pre-training** on **~60M Nemotron DQA question–answer pairs**, each
>    question the state and its answer the action. This learns broad semantic
>    representations.
> 2. **Mid-training** on **~30M synthetic hard negatives** generated by Gemini
>    2.5 Flash-Lite: semantically similar but incorrect answers to Nemotron DQA
>    questions, added to the InfoNCE loss as above. This develops fine-grained
>    discrimination between plausible actions.
> 3. **Post-training** on **~1M agent trajectories** from the Agent Data
>    Protocol (ADP) dataset, plus terminal traces from Endless-Terminals and
>    LiteCoder-Terminal-SFT. Each trajectory step is a state–action pair: the
>    agent's current context and the decision it took.
>
> **Replay during post-training.** 40% of the post-training mixture is Nemotron
> DQA replay and 60% agentic trajectories. With replay, Nemotron hard-negative
> top-1 accuracy only moves from 69% to 68.5%; training on agentic data alone for
> the same number of agentic steps drops it to 56.2%.
>
> **Why not train on hard negatives from the start?** On ~100K held-out
> questions (one gold answer, 10 hard negatives each), pre-training alone reaches
> **52.1%** top-1 without seeing a hard negative, and a short mid-training stage
> lifts it to **69.2%**. Training with hard negatives from the start improves
> quickly but peaks at **62.4%** before overfitting, so the two-stage recipe is
> **7 points better** at a fixed budget: hard negatives work best as a refinement
> on top of pre-training, not a substitute for it.
>
> The reference head served as `clm-latest` is
> [Contrastive-LM/CLM-v0.1-8B](https://huggingface.co/Contrastive-LM/CLM-v0.1-8B)
> (`CLM_v0.1-8B.pt`, Qwen3-8B backbone, last-token pooling). Any head in
> the same checkpoint format — a `torch.save` dict with `state_head` /
> `action_head` state dicts, `logit_scale` and `cfg` (`width`, `depth`,
> `projection_dim`, `activation`, `layernorm`, `residual`) — can be served with
> `--ckpt`; a head only makes sense with the encoder and pooling it was trained
> against.
>
> ---
>
> ## Roadmap
>
> 1. **Scaling experiments:** larger backbones, and how far verification
>    performance keeps scaling.
> 2. **Vision and multimodal support:** images, video and other modalities for
>    robotics and computer-use tasks.
> 3. **Scaling the data recipe:** more pre-training, hard-negative mining and
>    agentic post-training.
>
> ---
>
> ## Citation
>
> If you find CLM useful, please consider citing it:
>
> ```bibtex
> @misc{kwok2026contrastivelanguagemodels,
>   title={Contrastive Language Models: A System One Model for Fast and Generalizable Decision-Making},
>   author={Jacky Kwok and Hangoo Kang and Tarun Suresh and Jon Saad-Falcon and Marco Pavone and Christopher Ré and Azalia Mirhoseini},
>   year={2026},
>   note={Notion Blog},
>   url={https://contrastive-lm.notion.site}
> }
> ```
>
> ---
>
> ## Directory Structure
>
> ```
> .
> ├── pyproject.toml               # the clm package (installed editable by requirements.txt)
> ├── serve_qwen3_8b.sh            # launch the Qwen3-8B pooling encoder on a GPU
> ├── download_head.sh             # fetch the released head (`clm-download` does the same)
> ├── assets/                      # logo + the playground screenshot used above
> ├── src/clm/                     # inference: the package `clm-serve` and `clm` ship
> │   ├── __init__.py              #   from clm import CLMClient, Noul, Choice, Score, Engine
> │   ├── client.py                #   CLMClient + question / answer types (no torch needed)
> │   ├── schema.py                #   question -> (state text, candidate texts); logits -> Answer
> │   ├── engine.py                #   Engine.answer(...) / Engine.rank(...): the inference engine
> │   ├── heads.py                 #   head architecture, checkpoint load / hot-reload / download
> │   ├── embedder.py              #   /v1/embeddings client + LRU cache of normalised embeddings
> │   ├── cache.py                 #   the reserved vector arena behind --action-cache
> │   ├── server.py                #   FastAPI app, `clm-serve`
> │   └── static/                  #   the playground: index.html + app.css + app.js, no build step
> ├── tools/playground_mock.py     # serve the playground without a GPU (fake encoder)
> ├── train/                       # fine-tuning
> │   ├── finetune.py              #   trains the projection heads on a frozen encoder
> │   ├── adapters.py              #   dataset adapters: agentic traces, typed decisions
> │   └── embed_utils.py           #   encoder embeddings with the training token recipe
> ├── evaluation/bon_eval.py            # unified best-of-N evaluation
> ├── preprocessing/hf_embeddings.py    # embedding dir <-> Hugging Face dataset
> ├── requirements.txt             # pip install -r requirements.txt  (clm + torch + vLLM + example deps)
> ├── examples/                    # CLM vs Jev on the T-Rex runner (examples/t_rex/README.md)
> │   ├── common.py                #   one client for both endpoints: retries, latency, cache
> │   └── t_rex/                   #   Chrome dinosaur game in real time (run.py --model clm|jev)
> └── docs/FINETUNING.md           # the fine-tuning guide
> ```
>
> This branch carries the inference package, the playground, the fine-tuning script,
> the T-Rex example.
> The scaling experiments, data pipelines and paper figures
> live in the research repo's `main` branch.
>
> ---
>
> ## API Reference
>
> ### `POST /v1/systemone`
>
> | field | |
> | --- | --- |
> | `state` | string, object or array (objects are rendered as `key: value` text, arrays as `- item` lines; never JSON, the heads are trained on prose) |
> | `model` | `clm-latest` (default), `clm-raw`, or any model from `GET /v1/models` |
> | `questions` | `{id: Question}`, at least one |
> | `temperature` | optional, `(0, 100]`, default 1; divides the logits before the softmax |
>
> | question | required | answer |
> | --- | --- | --- |
> | `noul` | `instructions`; optional `criteria: {"true": …, "false": …}` | `{"noul": p_true}` |
> | `choice` | `instructions` (the question), `criteria: {option: description}` (each option is embedded as its description, or its key when the description is empty) | `{"choice", "confidence", "probabilities"}` |
> | `score` | `instructions`, `criteria: [level0, level1, …]` (ordered, ≥2) | `{"score", "confidence", "legend", "probabilities"}` |
>
> - `confidence` = top probability minus the mean of the others.
> - `score` = expected level index; `legend` maps indices back to the rubric.
> - `usage.input_tokens` counts encoder tokens spent on cache misses;
>   `billing_units` is the number of questions.
> - Errors: `401` bad key · `422` malformed request or unknown model · `502`
>   embedder unreachable. `X-CLM-Latency-Ms` carries the server-side time.
>
> ### `POST /v1/rank`
>
> The same primitive in its plain form: `{"context": ..., "question": ..., "answers": [...]}`
> returns `{"model", "ranked": [{"rank", "candidate", "prob"}, ...]}`, best first. The
> state head sees `context + question`, the action head sees each answer verbatim.
> `CLMClient.rank(context, question, answers)` and `Engine.rank(context, answers, question)`
> are the client and in-process forms.
>
> ### `GET /`
>
> The playground (see [above](#playground)), unless `clm-serve --no-ui`. Static
> files only; every API route above shadows it.
>
> ### `GET /v1/models`
>
> ```json
> {"models": [{"name": "clm-latest", "description": "...", "release_date": "2026-09-19"},
>             {"name": "clm-raw", "description": "Ablation: cosine in the raw encoder space", ...}]}
> ```
>
> ### `clm-serve` options
>
> ```
> clm-serve [--port 8700] [--emb-url http://127.0.0.1:8090/v1/embeddings] [--emb-model qwen3-8b]
>           [--max-tokens 2048] [--ckpt PATH] [--ckpt-dir DIR] [--model NAME=PATH ...] [--device cpu|cuda]
>           [--action-cache 0.02|512MiB|0] [--no-ui] [--cors]
> ```
>
> `--ckpt PATH` serves your own head as `clm-latest` (default: the reference
> head in `~/.cache/clm/`, downloaded if missing); `--ckpt-dir DIR` serves every
> `*.pt` there under its file stem; `--model NAME=PATH` adds one more.
> The heads run on the GPU when torch sees one, else on the CPU; `--device` (or
> `CLM_DEVICE`) forces one. Checkpoints hot-reload when the file changes. Set `CLM_API_KEY` to require
> `Authorization: Bearer <key>` (the playground has a field for it). Environment
> equivalents: `CLM_PORT`, `CLM_EMB_URL`, `CLM_EMB_MODEL`, `CLM_CKPT`,
> `CLM_DEVICE`, `CLM_ACTION_CACHE`.
>
> `--no-ui` drops the playground and serves the API alone. `--cors` allows browser
> requests from any origin and is off by default, because an API key otherwise
> travels in a header any page would then be free to send.
>
> #### The vector cache
>
> An agent asks about a changing state but a mostly fixed set of actions, and it
> revisits states it has already seen. Neither their embeddings nor their
> projections change while the head does not, so `clm-serve` reserves a slab of
> device memory at start-up — the way vLLM claims its KV cache — and keeps them in
> it:
>
> ```
> [clm] vector cache 505.0 MB reserved on cuda (215,764x512d + 3,852x4096d)
> ```
>
> `--action-cache` takes a fraction of the device (`0.02`, the default), an
> absolute size (`512MiB`), or `0` to switch it off; `CLM_ACTION_CACHE` does the
> same. It covers states and actions on every served head, and `clm-raw` in the
> encoder's own space — the two widths are pools carved from the one allocation,
> which never grows, so a long-running server cannot drift into an out-of-memory
> kill. Entries are keyed by head and generation, so several heads share the arena
> and a hot-reloaded head stops matching rows its previous weights produced;
> eviction is least-recently-used. `GET /health` reports occupancy and hit rate.
>
> A hit skips the encoder call, the host-to-device copy and the head's forward
> pass. Measured on one RTX 4090, server-side p50, against a fixed action set:
>
> | | 3 actions | 50 actions |
> |---|---|---|
> | new state every call | 28.6 → 28.0 ms | 28.8 → 28.1 ms |
> | revisited states (20 rooms) | 1.7 → 0.6 ms | 2.0 → 0.7 ms |
> | one repeated state | 1.7 → 0.6 ms | 2.0 → 0.7 ms |
>
> So a loop that revisits states answers about 2.8x faster, and a loop that never
> repeats itself pays the encoder either way. A cached vector costs no encoder
> tokens, so `usage.input_tokens` counts only what the encoder actually did.

#### HF: Contrastive-LM/CLM-v0.1-8B

> [!quote]- Model card, verbatim - 580 words
>
> ---
> license: apache-2.0
> base_model: Qwen/Qwen3-8B
> pipeline_tag: text-ranking
> language:
>   - en
> tags:
>   - contrastive-learning
>   - verifier
>   - reranker
>   - agents
>   - clm
> ---
>
> <p align="center">
>   <img alt="CLM v0.1" src="https://raw.githubusercontent.com/Contrastive-LM/CLM/main/assets/logo.png" width="45%">
> </p>
>
> <h3 align="center">CLM-v0.1-8B</h3>
>
> <p align="center">
> | 📄 <a href="https://contrastive-lm.notion.site"><b>Blog</b></a>
> | 💻 <a href="https://github.com/Contrastive-LM/CLM"><b>Code</b></a>
> | 🗣️ <a href="https://discord.gg/5dAQEDJBs"><b>Discord</b></a> |
> </p>
>
> **Contrastive Language Model (CLM)** is a new class of **System One model**
> trained with a **contrastive learning** objective that connects **states and
> actions**. **CLM-8B** consists of two small projection heads (a state head and
> an action head) on top of a frozen **Qwen3-8B** encoder trained with a
> bidirectional InfoNCE loss.
>
> - **Training:** pre-trained on ~60M Nemotron Q&A pairs, mid-trained on ~30M
>   synthetic hard negatives, post-trained on ~1M agentic trajectories.
> - **Zero-shot:** on par with Jev on computer-use, gaming and tool-calling tasks,
>   with **up to 9× lower latency**.
> - **Fine-tuned as a verifier:** SOTA on **DeepSWE (81.6%)** and
>   **Terminal-Bench 2.1 (87.6%)**, 4–6× faster than Jev.
> - **State & Action Caching:** states and actions are encoded separately, so action
>   embeddings can be reused. **With ~1k candidates, CLM is 13× faster than Jev.**
>
> ## Usage
>
> ### With the `clm` package
>
> ```bash
> git clone https://github.com/Contrastive-LM/CLM.git && cd CLM
> pip install -r requirements.txt
>
> # 1. encoder: Qwen3-8B, last-token pooling
> vllm serve Qwen/Qwen3-8B --served-model-name qwen3-8b --runner pooling \
>      --enable-prefix-caching --max-model-len 2048 --gpu-memory-utilization 0.35 --port 8090
>
> # 2. API + playground at http://localhost:8700/ (fetches CLM_v0.1-8B.pt into ~/.cache/clm/)
> clm-serve --port 8700 --emb-url http://127.0.0.1:8090/v1/embeddings
> ```
>
> Ask typed questions about a state:
>
> ```python
> from clm import CLMClient, Choice, Noul, Score
>
> client = CLMClient()  # http://127.0.0.1:8700 by default
> r = client.system_one(
>     state="Customer: my invoice was charged twice and nobody answers the phone!",
>     questions={
>         "urgency": Noul(instructions="Is this urgent?"),
>         "department": Choice(instructions="Which team should handle this?",
>                              criteria={"billing": "Charges, invoices, refunds",
>                                        "technical": "Bugs and outages"}),
>         "frustration": Score(instructions="How frustrated is the customer?",
>                              criteria=["Calm", "Frustrated", "Very angry"]),
>     },
> )
> print(r.answers["department"].choice)         # billing
> print(r.answers["department"].probabilities)  # {'billing': 0.93878, 'technical': 0.06122}
> ```
>
> Or rank free-form candidates (best-of-N solutions, tool names, next moves):
>
> ```python
> from clm import Engine
>
> engine = Engine(emb_url="http://127.0.0.1:8090/v1/embeddings")
> engine.rank("What causes tides on Earth?",
>             ["The Moon's gravitational pull.", "Photosynthesis in plants.", "Because the Earth is round."])
> # [{'rank': 1, 'candidate': "The Moon's gravitational pull.", 'prob': 0.993}, ...]
> ```
>
> ### Fine-tuning
>
> Only the heads are trained, so fine-tuning is cheap. This checkpoint is the
> starting point for the DeepSWE and Terminal-Bench heads.
>
> ```bash
> hf download Contrastive-LM/CLM-v0.1-8B CLM_v0.1-8B.pt --local-dir ckpts
> python train/finetune.py --task clm --hf-dataset Contrastive-LM/deepswe-clm-train-embeddings-8k \
>     --init-ckpt ckpts/CLM_v0.1-8B.pt --out-dir runs/deepswe \
>     --holdout-tasks heads/deepswe/heldout_tasks.json --batch 512 --seed 1234
> ```
>
> See the [fine-tuning guide](https://github.com/Contrastive-LM/CLM/blob/main/docs/FINETUNING.md).
>
> ### Playground
>
> `clm-serve` also serves a web playground at `http://localhost:8700/`.
>
> <p align="center">
>   <img alt="The CLM playground: a state with three typed questions on the left, their answer distributions on the right" src="https://huggingface.co/Contrastive-LM/CLM-v0.1-8B/resolve/main/assets/playground.png" width="100%">
> </p>
>
> ## Limitations
>
> - **Encoder-locked:** the heads require Qwen3-8B last-token-pooled embeddings.
> - **No generation:** CLM only scores the candidates you give it, and its
>   probabilities are relative to that set.
> - **Verifier results need fine-tuning:** the SOTA agentic-benchmark numbers
>   come from fine-tuned heads, not this checkpoint zero-shot.
> - **Generalization:** CLM-8B is one rung of our scaling ladder. A multimodal
>   **CLM-35B**, trained with more data, compute and parameters for stronger
>   generalization, is coming in early October.
>
> ## Citation
>
> ```bibtex
> @misc{kwok2026contrastivelanguagemodels,
>   title={Contrastive Language Models: A System One Model for Fast and Generalizable Decision-Making},
>   author={Jacky Kwok and Hangoo Kang and Tarun Suresh and Jon Saad-Falcon and Marco Pavone and Christopher Ré and Azalia Mirhoseini},
>   year={2026},
>   note={Notion Blog},
>   url={https://contrastive-lm.notion.site}
> }
> ```
>
> ## License
>
> The CLM-8B weights are released under the [Apache 2.0 License](LICENSE). The base encoder [Qwen3-8B](https://huggingface.co/Qwen/Qwen3-8B) is also Apache 2.0.

#### HF: Contrastive-LM/deepswe-clm-heads-8k

> [!quote]- Model card, verbatim - 169 words
>
> ---
> license: mit
> library_name: pytorch
> tags:
> - contrastive-learning
> - verifier
> - best-of-n
> - swe-agent
> - deepswe
> - clm
> ---
>
> # DeepSWE CLM fixed-split head (Qwen3-8B, 8K)
>
> This repository contains the single CLM projection-head checkpoint used for the
> DeepSWE panel in the release chart.
>
> - Split: seed 42, stratified by candidate count and pass count
> - Training/evaluation tasks: 75/38, task-disjoint
> - Training tasks with successful trajectories: 66 (59 train, 7 validation)
> - Candidate budget: Bo4
> - Trajectory score: mean of the final 12 available step scores
> - Heldout result: 31/38 = 81.579%
> - Heldout pass@1: 28/38 = 73.684%
> - Heldout oracle: 34/38 = 89.474%
> - Checkpoint SHA-256: `554989fe88635606cb978dc45a1ce083be1990c4a51e551ea3b6055ead1a029a`
> - Heldout-list SHA-256: `d4e2e7639f9eace09fba50318a266111c080d591bfbe39d213c3ea611e7b65c1`
>
> ## Reproduce
>
> From the `release` branch of
> [`jackyk02/contrastive_learning`](https://github.com/jackyk02/contrastive_learning):
>
> ```bash
> hf download Contrastive-LM/deepswe-clm-heads-8k --local-dir heads/deepswe
> python evaluation/bon_eval.py \
>   --hf-dataset Contrastive-LM/deepswe-clm-embeddings-8k \
>   --checkpoint heads/deepswe/best_head.pt \
>   --tasks-file heads/deepswe/heldout_tasks.json \
>   --n 4 --window 12
> ```
>
> The checkpoint was initialized from
> `Contrastive-LM/CLM-v0.1-8B/CLM_v0.1-8B.pt` and trained with the unified
> `train/finetune.py` CLM path using batch size 512, seed 1234, up to 20 epochs,
> and patience 5.

#### HF: Contrastive-LM/deepswe-clm-train-embeddings-8k

> [!quote]- Dataset card, verbatim - 195 words
>
> ---
> license: mit
> task_categories: [feature-extraction]
> tags: [deepswe, swe-agent, embeddings, process-reward-model]
> pretty_name: DeepSWE PRM training embeddings (Qwen3-8B, 8k)
> size_categories: [100K<n<1M]
> configs:
> - config_name: default
>   data_files: data/*.parquet
> ---
>
> # DeepSWE PRM training embeddings (Qwen3-8B, 8k)
>
> Frozen **Qwen3-8B** last-token-pooled embeddings (4096-d, float16) of every step of the
> DeepSWE training-pool rollouts: **405,919 steps · 4,701 trajectories · 113 tasks**.
> This is the data the released DeepSWE PRM heads
> ([`tarsur385/deepswe-prm-heads-8k`](https://huggingface.co/tarsur385/deepswe-prm-heads-8k)) were fine-tuned on.
> Embedded with `preprocessing/deepswe/embed_shard.py` at `max_model_len 8192`: the state is the
> chat-templated step context truncated to its last 8191 tokens; the action is the raw action text.
>
> | column | description |
> |---|---|
> | `trajectory_id` | rollout id |
> | `step_idx` | step order within the rollout (rows are in step order) |
> | `task_id` | DeepSWE task |
> | `reward` | rollout outcome (1 = passed) |
> | `model`, `config` | policy model / rollout config |
> | `state_embedding`, `action_embedding` | 4096-d float16 |
>
> Load into the repository's embedding-dir format and fine-tune:
>
> ```bash
> python preprocessing/hf_embeddings.py download tarsur385/deepswe-prm-train-embeddings-8k --out data/deepswe_train
> python train/finetune.py --task prm --emb-dir data/deepswe_train --init-ckpt qwen3_8b_midtrained_head.pt \
>     --holdout-folds heads/folds/fold0.json heads/folds/fold1.json heads/folds/fold2.json --out-dir runs/deepswe
> ```
>
> The evaluation rollouts (Claude-Opus-5, 4 per task) are a separate dataset:
> [`tarsur385/deepswe-prm-embeddings-8k`](https://huggingface.co/datasets/tarsur385/deepswe-prm-embeddings-8k).

#### HF: Contrastive-LM/CLM-v0.1-Pretrain-Nemotron

> [!quote]- Dataset card
>
> No card. `https://huggingface.co/datasets/Contrastive-LM/CLM-v0.1-Pretrain-Nemotron/raw/main/README.md` returns "Entry not found". The repository itself holds 1,875 files across six shards totalling 1,023.5 GB — `chunk_NNNN_q.npy` and `chunk_NNNN_a.npy` pairs of 819,200,128 bytes each plus `chunk_NNNN_meta.parquet` — last modified 2026-09-24T01:24:49Z, 0 downloads, 0 likes at capture.
