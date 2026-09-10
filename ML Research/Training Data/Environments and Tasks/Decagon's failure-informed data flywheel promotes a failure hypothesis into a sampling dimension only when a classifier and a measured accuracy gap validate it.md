---
created: 2026-09-09
description: Cyrus (Decagon) lays out a continuous post-training loop whose optimization target is the dataset rather than the checkpoint - a council of debating LLM judges calibrated against a human golden set produces labels, failures are mined from the exact checkpoint under evaluation and clustered into hypotheses, a hypothesis is promoted into a sampling dimension only when a classifier can label any example and held-out accuracy measurably varies across strata (weight proportional to the gap), upsampling targets the intersection of undercovered and hard, pass@k with k=5-10 locates the GRPO productive-advantage band and schedules a curriculum, synthetic generation fills regions real traffic cannot, and a frozen real-data benchmark sits outside the flywheel as an iteration gate.
source: https://x.com/cyrusasg/status/2097358742950207767
type: framework
---

## Key Takeaways

- **The promotion criterion is the reusable idea: a failure hypothesis is not a sampling dimension until it has a classifier and a measured accuracy gap, and its weight is the size of that gap.** Clustering failures yields "concrete claims about input properties that correlate with failure" — the model breaks when relevant context is buried in a tool output rather than stated directly, or when candidate options share surface features — but a hypothesis earns entry to the sampler only with "a classifier (programmatic or LLM-based) that can label any example with the relevant value" *and* empirical validation, meaning that stratifying a held-out sample by the dimension actually moves accuracy across strata. "Bigger gap, higher priority." The contrast he draws is the load-bearing part: conventional diversity sampling takes inverse-frequency weights over hand-picked axes (language, topic, length, channel), which "beats random sampling, but variety doesn't guarantee coverage of where the model fails. A rare language might be hard, or it might be trivially easy; a common input pattern might be exactly where the current checkpoint is silently broken." The same accept-only-on-measurement discipline is the gate in [[Self-Harness lets a fixed LLM rewrite its own agent harness from clustered failure traces, lifting Terminal-Bench held-out pass rates up to 21 points]], and the ranking analogue already in the vault is [[OpenAI macro evals cookbook turns population-level trace clustering into a ranked inspection queue for multi-agent systems]], which orders its inspection queue by prevalence times severity rather than by a measured accuracy delta.

- **The council of LLMs is a deliberate rejection of two-model agreement filtering, whose bias is that it keeps exactly the examples worth least.** "The standard setup samples two frontier models and keeps the examples where they agree. That carries a quiet bias: strict agreement only retains examples where both models are aligned on the first pass, which are the easier ones. The hard examples, which are the most valuable for training, get discarded." His council resolves disagreement instead of discarding it — each model generates with reasoning, sees the others' generations, is asked to critique or defend, and an arbitrator renders a verdict — and the payoff claim is that this "provides a mechanism for generating training data that exceeds frontier-model first-attempt accuracy." **This is the one claim he hedges himself**, and correctly: "Debate can surface correct answers on cases where no individual model succeeds at pass@1, although results depend heavily on the protocol," citing Du et al. and Smit et al., the second of which is a survey of when multi-agent debate strategies *fail*. Treat "exceeds frontier pass@1" as protocol-contingent, not as a property of councils. The vault's nearest formal cousin is [[reward model ensembles mitigate overoptimization in RLHF by combining conservative objectives with uncertainty weighting]]; the countervailing measurement is [[LLM Data Company experiments show explicit rubric criteria let gpt-oss-120b match Opus 4.7 at 100x lower cost and full-rubric grading beats per-criterion across every model]], where criterion specificity beat judge scale and single-call full-rubric grading beat decomposing the judgment — a reason to suspect that a sharper rubric may buy more than a bigger council.

- **Calibration against a human-annotated golden set is stated as a precondition, not a nicety, because every later stage inherits the judge's error.** "A miscalibrated judge corrupts the signal at the source, and that error cascades through every later stage" — the council has to be calibrated "before its verdicts drive anything." The vault holds the measured instance: [[Mercor's SkyRL recipe post-trains a 397B on 1928 expert tasks for 70 percent relative Pass@1 - and spends Steps 1-3 de-risking before any real compute]] ran a 32-task overfitting probe whose *failure* to overfit exposed a low-fidelity file-diff verifier before the hero run — grader error found empirically rather than by inspection. It also holds the cost of skipping it: in [[Nova Escola's lesson-planner evals worked only after error analysis rewrote the rubric - annotators agreed worse than chance until experts defined good]] the human annotators agreed *worse than chance* until domain experts defined the target, which is what "human-annotated golden set" actually buys and prices. The grader-mix question underneath is [[anthropic recommends combining deterministic graders model judges and human review for agent evals]], and the structural point that you cannot improve the model faster than you improve the grader is [[Databricks coSTAR closes the agent testing gap with coupled judge-alignment and agent-refinement loops]] — the same bound [[Phoebe Yao argues verifier engineering is the moat in RL post-training because verifiability bounds learnability]] draws around learnability itself.

- **The curriculum section is where the piece becomes concrete, and its argument is a compute argument about GRPO rather than a pedagogy argument.** Complexity is measured as pass@k with k = 5-10: sample k completions, score each with the council verifier, read difficulty off the pass rate. The reason to bother is that "under group-relative policy-gradient methods such as GRPO, the learning signal for a prompt comes from the spread of rewards across its sampled rollouts. If every rollout for a prompt succeeds, or every one fails, the advantages are all zero. The prompt contributes no gradient, and the compute spent rolling it out is wasted." Pass@k is the instrument that locates the intermediate band, so scheduling does two jobs — it concentrates training inside the productive-advantage zone, and as easy prompts saturate toward pass@k ≈ 1 the curriculum advances into prompts that have just entered the band, keeping "advantages flowing throughout training instead of collapsing as the model improves." Prompts at pass@k = 0 are unlearnable under a binary group-relative reward but may be recoverable via on-policy self-distillation from a privileged teacher. This is exactly the zero-variance-group filtering in [[Arjun Kocher's RL algorithm Q&A traces PPO, GRPO, DAPO, and the DeepSeek R1-to-V4 training arc]] and [[stable agentic RL requires sequence-level clipping and environment-aware advantages to prevent training collapse]], turned from a sampling trick into a dataset-construction target; the automated version is the calibrated pass-rate banding of [[Prime Intellect general-agent self-evolves a tool-use corpus through a synthesizer-solver game gated on empirical pass-rate bands]], the theoretical ancestor is [[PLR improves RL generalization by prioritizing training levels with high estimated learning potential]], and the "clear step difference between Fable-class and Opus-class models" discriminative-power test in [[Daniel Ching's On Data II makes environment quality a verification problem - prompt-verifier bijectivity, realism, and ex post trace analysis]] is the same band read as an environment-quality criterion instead of a scheduling one.

- **Upsampling is an explicit three-way blend, and the structural floor exists to guard against the judge, which is the subtle move.** The bulk of the sample comes from validated failure regions "weighted by the size of the accuracy gap and preferring examples the model is uncertain on"; a steady floor across always-on axes (language, channel, length) supplies baseline stratification and "guards against blind spots in the judge"; and a uniform-random remainder preserves coverage of the production distribution. Because "a perfectly diverse dataset can still be dominated by trivial cases the model already gets right," the target is the intersection of rarity and difficulty rather than rarity alone. Where real traffic cannot fill a region — genuinely sparse, or legally outside the trainable subset — a generator LLM synthesizes into it behind three checks: an independent judge for realism, dimension match and label ("so the generator never grades its own work"), a per-example comparison against real examples in the same region, and an aggregate drift check on the whole synthetic subset. That is the coverage-first framing of [[AgentFrontier synthesizes training data at the boundary of what LLMs can and cannot do]] with an explicit anti-drift harness bolted on, and the vault's measured caution is [[prompt design is the single biggest lever for synthetic pretraining data]] — the generator matters less than the specification handed to it.

- **The only lived evidence in the piece is a short qualitative report, and its most useful line is a reward-hacking observation that justifies keeping evaluation outside the flywheel.** Applied internally at Decagon to evidence-bound response verification — deciding whether a response contains a consequential claim unsupported by conversation history, policies, retrieved knowledge, metadata, or tool calls — initial task training "improved evidence coverage but left systematic false positives," and mining those errors from the current checkpoint into "targeted hard negatives and contrast pairs" sharpened the decision boundary better than adding broad or positive-heavy data. Then: "We observed runs where training reward continued to improve while performance on a frozen real-data benchmark regressed," so the benchmark became a gate on every intermediate checkpoint and failures were re-mined after each accepted one "since each stage produced a different error distribution." That divergence is precisely what [[invariance-based stress tests detect proxy gaming by separating exploitable sensitivity from genuine improvement]] is built to detect and why [[benchmarks are measurement instruments not question collections - regulargio's first-principles guide to claims, graders, coverage, and uncertainty]] insists the gate be an instrument rather than a question pile; the deploy-side sibling of the same loop is [[every deploy should trigger a monitor-triage-fix loop that dispatches a coding agent to fix regressions before users notice]]. **Read the whole thing as a design document: there are no numbers, no ablations, no benchmark, no named model and no reported deltas anywhere in it** — every quantity is a knob (k = 5-10, pass@k ≈ 1) rather than a result, and the applied section reports direction without magnitude. It is a coherent operationalisation of the *ex post* half of [[Daniel Ching's On Data II makes environment quality a verification problem - prompt-verifier bijectivity, realism, and ex post trace analysis]] as a standing loop rather than a review pass, sitting on the datapoint-as-environment framing of [[Daniel Ching's On Data I argues the post-training datapoint has become an executable environment not a corpus row]], answering the "what you distil *from* matters more than how well you distil" claim of [[Charlie O'Neill's LONG REAL YOURS thesis - horizon length is the only thing RL generalises, and what you distil from matters more than how well you distil]] with machinery for choosing the source, and bounded above by [[mid-training builds the reasoning foundation that RL amplifies not replaces]]. Its practical neighbours are [[the Error Discovery skill builds a failure-mode taxonomy while you annotate, using active learning to pick the next traces]] and [[LangSmith Engine turns production agent traces into issues evaluators and regression examples by separating screening from investigation]] for the mining stage, [[agent eval readiness starts with error analysis and simple end-to-end tests not sophisticated infrastructure]] for the ordering constraint, [[on-policy distillation plus conditional log-penalty RL cuts search agent latency 44 percent while boosting accuracy]] for the behavior-anchoring direction he flags as exploratory, and [[agentic RL training converges on outcome rewards inside production harnesses across Kimi Cursor and Chroma]] for the training regime this dataset feeds.

## External Resources

- [Du et al., "Improving Factuality and Reasoning in Language Models through Multiagent Debate"](https://proceedings.mlr.press/v235/du24e.html) — ICML 2024; citation [1] behind the debate-beats-pass@1 claim
- [Smit et al., "Should we be going MAD? A Look at Multi-Agent Debate Strategies for LLMs"](https://proceedings.mlr.press/v235/smit24a.html) — ICML 2024; citation [2], the survey of when debate protocols do and do not help
- [Shao et al., "DeepSeekMath: Pushing the Limits of Mathematical Reasoning in Open Language Models"](https://arxiv.org/abs/2402.03300) — 2024; citation [3], the GRPO source for zero-advantage prompts wasting rollout compute
- [Zhao et al., "Self-Distilled Reasoner: On-Policy Self-Distillation for Large Language Models"](https://arxiv.org/abs/2601.18734) — 2026; citation [4], OPSD as denser supervision for prompts stuck at pass@k = 0
- [Davidson et al., "Reasoning-Driven Synthetic Data Generation and Evaluation"](https://arxiv.org/abs/2603.29791) — TMLR 2026; citation [5], synthetic-data construction as dataset-level mechanism design over coverage, complexity and quality
- [Google Research: Designing synthetic datasets for the real world](https://research.google/blog/designing-synthetic-datasets-for-the-real-world-mechanism-design-and-reasoning-from-first-principles/) — the accessible overview of [5]
- [Lu, "On-Policy Distillation"](https://thinkingmachines.ai/blog/on-policy-distillation/) — Thinking Machines Lab, 2025; citation [6], the basis for the exploratory behavior-anchoring direction
- [Original article](https://x.com/cyrusasg/status/2097358742950207767) — X Article by @cyrusasg (Cyrus), Decagon

## Original Content

Source: [A Failure-Informed Data Flywheel for Post-Training](https://x.com/cyrusasg/status/2097358742950207767) — X Article by @cyrusasg (Cyrus), 8 Sep 2026. 61 likes, 10 retweets, 9 replies.

> [!quote]- A Failure-Informed Data Flywheel for Post-Training — full X Article text
> @cyrusasg (Cyrus):
> Article: A Failure-Informed Data Flywheel for Post-Training
>
> For any model that's fine-tuned and deployed against live traffic, the quality ceiling is often less constricted by the optimizer or the architecture, but rather by the dataset. Much of the leverage in post-training lives in a few properties of the data and how it's scheduled:
>
> - Quality: are the target outputs/graders perfectly executed and high-signal, or is the model quietly internalizing subtle errors, hallucinations from noisy labels?
>
> - Diversity: does the dataset cover the inputs the model actually sees in production, especially the inputs where it fails?
>
> - Complexity: are the examples hard enough to be worth training on, or is the set dominated by cases the model already gets right?
>
> - Scheduling: is the data constructed once and frozen, or is it rebuilt each cycle against the currently deployed model and fed back into the training loop?
>
> Getting all four right, with a construction process tightly coupled to the training loop, unlocks gains that a one-shot pipeline can't reach. What ties them together is failure. Mining the current checkpoint's own failures, building datasets targeted at where it's breaking, and feeding those corrections back into the next training cycle allows gains to compound across cycles.
>
> Most models that are fine-tuned and deployed face the same trajectory. The training distribution is a snapshot, frozen at one moment. The alternative is to treat training as a continuous loop, and to make data curation the thing that loop optimizes. The rest of this post walks through that loop: how golden labels/graders are produced (a council of LLMs), how failures are surfaced (mining and clustering), how the dataset is rebalanced toward them (upsampling), how the complexity of each example is measured and turned into a training schedule (curriculum), how gaps that real data can't fill are closed (synthetic generation), and how the whole pipeline couples to the training loop to produce a model that is robust across all discovered failure modes.
>
> *The failure-informed data flywheel: deploy the model live or replayed, mine failures with the council of LLMs, cluster and validate failure modes, construct the failure-informed dataset, task train with SFT / RL / OPSD, repeat*
> ![[cyrusasg-207767-001.png]]
>
> ## The council of LLMs
>
> Everything downstream depends on graders/labels, so the scoring method is where the loop starts. The standard setup samples two frontier models and keeps the examples where they agree. That carries a quiet bias: strict agreement only retains examples where both models are aligned on the first pass, which are the easier ones. The hard examples, which are the most valuable for training, get discarded.
>
> A council of models, with protocols that resolve disagreement rather than throw it away, flips this. Each model generates a response with reasoning, sees the others' generations, and is asked to critique or defend. An arbitrator renders a verdict. Debate can surface correct answers on cases where no individual model succeeds at pass@1, although results depend heavily on the protocol [1, 2]. When it works, this provides a mechanism for generating training data that exceeds frontier-model first-attempt accuracy.
>
> Because so much downstream signal flows from these judgments, the council has to be calibrated against a human-annotated golden set before its verdicts drive anything. A miscalibrated judge corrupts the signal at the source, and that error cascades through every later stage.
>
> ## Failure mode mining and clustering
>
> With a calibrated council in hand, each cycle begins by finding where the current checkpoint is breaking.
>
> We pull a stratified sample of representative traffic and run the council of judges over it to score the current checkpoint’s performance. Then group the failures into thematic clusters, either by handing failure cases to a strong LLM and asking what the inputs have in common, or by embedding and clustering at larger scales. The output is a set of failure hypotheses: concrete claims about input properties that correlate with failure. For example, the model might fail when the relevant context is buried in a tool output instead of stated directly, or when multiple candidate options have overlapping surface features.
>
> A failure hypothesis isn't yet usable as a sampling dimension. To become one it needs two things: a classifier (programmatic or LLM-based) that can label any example with the relevant value; and empirical validation, meaning that when you stratify a held-out sample by the dimension, the model's accuracy actually varies across strata. Here a dimension is only promoted into the sampler if it shows a measured accuracy gap across its values, and the size of that gap is correlated to its weight: bigger gap, higher priority.
>
> The distinction from conventional diversity sampling matters. The default approach samples for variety across language, topic, length, and channel, using inverse-frequency weights over hand-picked dimensions. That beats random sampling, but variety doesn't guarantee coverage of where the model fails. A rare language might be hard, or it might be trivially easy; a common input pattern might be exactly where the current checkpoint is silently broken.
>
> ## Failure mode upsampling
>
> We map current coverage across the validated dimensions (for each region, roughly how much training data exists and how the current checkpoint performs there), then rebalance toward the regions that are underrepresented or where the model is weak. Sampling blends three things. The bulk comes from those failure regions, weighted by the size of the accuracy gap and preferring examples the model is uncertain on. A steady structural floor across always-on axes like language, channel, and length handles some baseline stratification and guards against blind spots in the judge. And a smaller uniform-random share ensures we maintain full coverage of our production distribution.
>
> Coverage isn't the whole story, though. A perfectly diverse dataset can still be dominated by trivial cases the model already gets right. So upsampling doesn't target rarity alone; it targets the intersection of rarity and difficulty, meaning examples that sit in undercovered regions and that the model also finds hard. The next section covers how we measure that difficulty and feed it into the training schedule.
>
> ## Measuring complexity and scheduling a curriculum
>
> Diversity tells you what kinds of examples you have, complexity tells you which are particularly worth training on within those clusters.
>
> Measuring complexity: The default measure is pass@k with k = 5–10: sample k completions for an example, score each with the council verifier, and read complexity off the pass rate. The fewer of the k attempts that succeed, the harder the example. Combined with the coverage picture from the previous section, this is what lets upsampling target the genuine high-signal region, the intersection of undercovered and hard regions.
>
> Where this matters most: Under group-relative policy-gradient methods such as GRPO, the learning signal for a prompt comes from the spread of rewards across its sampled rollouts. If every rollout for a prompt succeeds, or every one fails, the advantages are all zero. The prompt contributes no gradient, and the compute spent rolling it out is wasted [3]. The prompts that actually move the policy are the ones in the intermediate band, where some rollouts succeed and some don't. Pass@k is the measurement that locates that band. Prompts with pass@k near 0 or near 1 yield little signal, and prompts in between are where advantages are nonzero. Scheduling by complexity therefore does two jobs in RL. It keeps training concentrated on prompts inside the productive-advantage zone, and as the policy improves and easy prompts saturate toward pass@k ≈ 1, the curriculum advances into harder prompts that have just entered that zone. The result is a frontier that keeps advantages flowing throughout training instead of collapsing as the model improves.
>
> *Advantage as a function of pass@k: prompts where all rollouts fail or all pass yield no gradient, and the productive-advantage zone in between shifts right as the policy improves*
> ![[cyrusasg-207767-002.jpg]]
>
> While prompts with pass@k of 0 may be unlearnable for the current checkpoint under a binary group-relative reward, methods such as on-policy self-distillation (OPSD) can make these examples learnable by providing denser supervision from a privileged teacher [4].
>
> ## Synthetic data for underrepresented failure modes
>
> Some regions of the input space can't be filled from real production data. Either the traffic is genuinely sparse there, or the data exists but sits outside the subset we are permitted to train on. Those constraints don't make the failure mode any less real, they just make it impossible to address with real collected data. Synthetic generation allows us to close the gap. Recent work similarly frames synthetic-data construction as dataset-level mechanism design over coverage, complexity, and quality [5].
>
> This probably warrants a post of its own, but in short a generator LLM produces new examples for an underfilled region. Quality control is what separates useful synthetic data from drift, so every synthetic example passes three checks:
>
> - Independent judge validation. A different model or prompt verifies realism, dimension match, and label, so the generator never grades its own work.
>
> - Per-example distribution check. Each example is compared against real examples in the same region.
>
> - Aggregate distribution check. The full synthetic subset is checked for drift that individual examples wouldn't reveal.
>
> ## Closing the loop: iteration cycles
>
> Data curation and training form a continuous cycle. Each checkpoint changes where the model fails, so a round of mining should run against the exact checkpoint being evaluated.
>
> Each cycle has the same shape:
>
> Internal or shadow exposure → Mine failures from the current checkpoint
>                             → Construct a failure-informed dataset
>                             → Train on the new dataset
>                             → Evaluate against frozen benchmarks and regression suites
>                             → Update the internal candidate if accepted → repeat
>
> Exposure can come from internal users, offline replays, or shadow traffic, the loop does not require serving the candidate checkpoint directly to production users. Evaluation is an iteration gate, and a checkpoint that does not clear that gate does not advance to broader testing.
>
> Exploratory direction: behavior anchoring. Repeated task-specific training may eventually degrade capabilities outside the target distribution. We are exploring how on-policy distillation from an earlier checkpoint on broader datasets could act as a behavioral anchor between cycles [6].
>
> ## What we learned applying the loop
>
> Credit to @roaring_doggie for helping with exploration and testing here.
>
> We initially applied this approach internally to evidence-bound response verification: deciding whether a response contains a consequential claim unsupported by the available conversation history, policies, retrieved knowledge, metadata, or tool calls. Initial task training improved evidence coverage but left systematic false positives. Mining those errors from the current checkpoint and constructing targeted hard negatives and contrast pairs helped sharpen the decision boundary more effectively than adding broad or positive-heavy data.
>
> The application also reinforced the need for independent evaluation. We observed runs where training reward continued to improve while performance on a frozen real-data benchmark regressed. We therefore treated that benchmark as a gate for every intermediate checkpoint and re-mined failures after each accepted checkpoint, since each stage produced a different error distribution.
>
> ## Takeaways
>
> - Mine the checkpoint you are trying to improve. Internal evaluation, offline replays, and shadow traffic can surface useful failures without requiring a production deployment.
>
> - Let measured failures shape the dataset. Promote a sampling dimension only when it predicts an accuracy gap, then prioritize regions that are both undercovered and difficult.
>
> - Treat disagreement as signal. Resolve contested labels with additional judgment rather than discarding the hardest examples.
>
> - Use synthetic data to fill coverage gaps. Validate examples independently and check both per-example quality and aggregate drift.
>
> - Keep evaluation outside the flywheel. Every candidate checkpoint should clear frozen real-data benchmarks before advancing to broader testing.
>
> At Decagon, this failure-informed data flywheel is one building block of a broader model factory turning each checkpoint’s failures into better training data for the next.
>
> ## References
>
> [1] Du et al. [“Improving Factuality and Reasoning in Language Models through Multiagent Debate.”](https://proceedings.mlr.press/v235/du24e.html) ICML, 2024.
>
> [2] Smit et al. [“Should we be going MAD? A Look at Multi-Agent Debate Strategies for LLMs.”](https://proceedings.mlr.press/v235/smit24a.html) ICML, 2024.
>
> [3] Shao et al. [“DeepSeekMath: Pushing the Limits of Mathematical Reasoning in Open Language Models.”](https://arxiv.org/abs/2402.03300) 2024.
>
> [4] Zhao et al. [“Self-Distilled Reasoner: On-Policy Self-Distillation for Large Language Models.”](https://arxiv.org/abs/2601.18734) 2026.
>
> [5] Davidson et al. [“Reasoning-Driven Synthetic Data Generation and Evaluation.”](https://arxiv.org/abs/2603.29791) TMLR, 2026. See also the [Google Research overview](https://research.google/blog/designing-synthetic-datasets-for-the-real-world-mechanism-design-and-reasoning-from-first-principles/).
>
> [6] Lu. [“On-Policy Distillation.”](https://thinkingmachines.ai/blog/on-policy-distillation/) Thinking Machines Lab, 2025.
> date: Tue Sep 08 16:17:46 +0000 2026
> url: https://x.com/cyrusasg/status/2097358742950207767
> likes: 61  retweets: 10  replies: 9


## Replies

> **@alexdong (Alex Dong)** — 8 Sep 2026
> @cyrusasg Did you read the HeaPA paper? This sounds very similar?

> **@cyrusasg (Cyrus)** — 8 Sep 2026
> @alexdong hadnt seen it until you shared, thanks! just skimmed and seems pretty aligned, especially on moving the capability frontier
