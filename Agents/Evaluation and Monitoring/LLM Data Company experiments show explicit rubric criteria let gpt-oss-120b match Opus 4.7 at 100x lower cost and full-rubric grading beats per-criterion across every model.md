---
created: 2026-06-03
description: LLM Data Company's benchmark of six judge models on 1,158 physician-labeled medical criteria finds that explicit, rule-like rubrics move the grading burden to written specification—allowing gpt-oss-120b to reach 0.894 F1 at $0.001/run versus Opus 4.7's 0.899 at $0.076/run, while full-rubric grading (one LLM call for all criteria) beats per-criterion grading on every model tested.
source: https://www.llmdata.com/blog/rubric-judge
type: framework
---

## Key Takeaways

- **Criterion quality beats judge scale**: Vague criteria like "provides appropriate dosing" force the judge to fill interpretation gaps with model judgment; rule-like criteria like "limits correction to ≤8-10 mEq/L in 24h" move the boundary into the written text. Once that work is explicit, cheaper models can apply the spec as reliably as expensive ones — gpt-oss-120b reaches 0.894 F1 at $0.001/run vs Opus 4.7's 0.899 at $0.076/run. This directly connects to [[Phoebe Yao argues verifier engineering is the moat in RL post-training because verifiability bounds learnability]]: the learnability ceiling for non-verifiable RL rises or falls with how well the rubric approximates the true reward boundary.
- **Full-rubric grading dominates per-criterion grading**: A single LLM call grading all criteria at once outperformed one-call-per-criterion on every model by 0.008–0.016 F1, and was 6–11x cheaper. The likely mechanism is calibration context — physicians grade with the full rubric in view, and full-rubric grading gives the model the same contrast across neighboring criteria. [[deep agent evals need bespoke per-datapoint test logic not uniform evaluators]] aligns with this: the grading signal is better when the judge sees the full evaluation context.
- **Systematic judge bias matters more than headline F1**: Gemini 3 Flash and Haiku 4.5 run ~5-6pp higher MET rates than Opus/gpt-oss-120b; GPT-5.5 runs ~4pp stricter. In correctness-sensitive domains, false positives are more expensive than false negatives — judge selection must account for directional bias, not just macro F1. This is the verifier failure mode identified in [[LangChain and Harvey show DeepSeek batch verifiers reduce legal agent evaluation costs by three orders of magnitude at acceptable accuracy]]: weaker judges give undeserved criterion credit, which corrupts reward signal in RL. [[Databricks coSTAR closes the agent testing gap with coupled judge-alignment and agent-refinement loops]] addresses this via paired feedback loops that align judge behavior to human expert baselines.
- **Reasoning effort is mostly not worth it for rubric grading**: Enabling heavier reasoning improved F1 by less than one point for every model but increased per-call latency by 1.4–24x. Haiku 4.5 at medium reasoning costs 23.5x more wall-clock for +0.2% F1. Explicit criteria do the heavy lifting; reasoning budget is better spent elsewhere in the RL loop.
- **Rubric design is upstream of eval quality**: Rubrics encode which errors become visible and which answer boundaries are enforced. A technically reliable judge applying a poorly designed rubric still produces corrupted reward. [[anthropic recommends combining deterministic graders model judges and human review for agent evals]] makes the same point about complementarity — LLM judges are only as good as the specification they apply. [[invariance-based stress tests detect proxy gaming by separating exploitable sensitivity from genuine improvement]] offers a complementary diagnostic: once rubrics are written, perturbation-based stress tests can surface criteria that are exploitable through surface form.

## External Resources

- [The LLM Data Company rubric package](https://github.com/The-LLM-Data-Company/rubric) — open-source grader with full-rubric and per-criterion modes; default prompt included in the benchmark
- [HealthBench (Arora et al., 2025)](https://arxiv.org/abs/2505.08775) — OpenAI's health LLM benchmark; HealthBench Consensus subset uses predefined multi-hundred-word criteria with physician labels; different rubric style from this work
- [RubricHub (Li et al., 2026)](https://arxiv.org/abs/2601.08430) — granular rubric dataset generated with textualist grading in mind; reports similar saturation pattern (0.81 F1 at Qwen2.5-7B to 0.91 at Qwen3-235B)
- [Reward Hacking in Rubric-Based RL (Mahmoud et al., 2026)](https://arxiv.org/abs/2605.12474) — separates verifier failure (weak judge gives wrong credit) from rubric-design failure (model increases rubric score while degrading the broader quality the rubric proxies)
- [AutoRubric (Rao & Callison-Burch, 2026)](https://arxiv.org/abs/2603.00077) — independent per-criterion evaluation methodology; this paper's full-rubric results contradict AutoRubric's per-criterion assumption
- [Judging the Judges (Thakur et al., 2025)](https://arxiv.org/abs/2406.12624v5) — finds LLM judges grade positively when uncertain, especially smaller judges; consistent with Gemini/Haiku high-MET-rate bias seen here
- [Textualism (Wikipedia)](https://en.wikipedia.org/wiki/Textualism) — legal theory framing referenced in the article's criterion-design argument
- [Purposivism (Wikipedia)](https://en.wikipedia.org/wiki/Purposive_approach) — the contrasting legal posture: judge infers purpose behind the rule rather than applying text literally

## Original Content

> [!quote]- Source Material
> # Notes on Choosing a Rubric Judge
>
> Jun 1, 2026 · Daanish Khazi, Gavin Bains, Joey Besgen, Qi Fang
>
> ---
>
> For non-verifiable training, rubric judges are the primary source of reward signal and, by extension, the primary vector for reward hacking. Scaling non-verifiable RL reliably means ensuring rubric judges grade outputs with the same precision as a human expert. This quality requirement must be balanced with latency and cost because rubric judges sit inside the RL loop where slower grading increases the lag between rollouts and weight updates.
>
> Our experiments show that these goals are not always in tension. Explicit rubrics remove the interpretative burden on the grader by moving verification into written criteria: what evidence earns credit, which thresholds matter, and which errors penalize reward. **On 1,158 physician-labeled criterion decisions, Opus 4.7 reached 0.899 F1, while gpt-oss-120b reached 0.894 at about 100× lower cost, and full-rubric grading beat per-criterion grading across every model we tested.**
>
> ---
>
> ## Non-Verifiable Rewards
>
> Rubric grading has become the default interface for non-verifiable rewards. A rubric is a written specification for a reward function scoped to a single task: it turns long form evaluation into a set of weighted binary criteria, each of which is graded by a model judge.
>
> This structure is useful because it makes reward inspectable, but it is also easy to hack. If a criterion is underspecified, incomplete, or easy to satisfy through surface form, optimization will find that gap. Likert-style LLM judges were useful for gut-check production observability, but their variance and bias made them unsuitable as reward signals for high-compute RL.
>
> ## Criteria Define Reward Boundaries
>
> A criterion is a single binary requirement, expressed as a checkable condition: what evidence earns credit, what reasoning is required, what constraint matters, or what active error should be penalized.
>
> Criteria can fail in both directions: loose criteria give credit to plausible wrong answers, but myopic criteria reject valid answers that use different phrasing, ordering, or defensible alternate paths. A useful criterion rewards the generalized space of correct answers and measurably penalizes incorrect ones.
>
> Each criterion defines a written boundary over the answer space. If it is myopic and strictly encodes one golden answer, valid variants become false negatives. If it is too lenient or underspecified, plausible errors become false positives.
>
> Because correct answers vary in phrasing, ordering, and level of detail, and wrong answers can be fluent and close, each criterion has to approximate a local boundary between the two.
>
> The examples below show the concrete failure mode: a plausible response can satisfy a loose criterion while missing the task-specific requirement.
>
> **Criteria that did not survive review**
>
> *Vague dosing*
>
> Bad Criterion: Provides appropriate sodium correction.
>
> A response can recommend correcting sodium by 14 mEq/L in the first 24 hours and still pass if the judge treats "appropriate" as a judgment it can make from context.
>
> Fixed Criterion: For chronic hyponatremia, limits sodium correction to ≤8-10 mEq/L in 24 hours, or ≤8 mEq/L in high-risk patients.
>
> The answer has to name the correction limit and the stricter high-risk threshold.
>
> *Undefined completeness*
>
> Bad Criterion: Provides a complete workup for chest pain.
>
> A response can order ECG and troponin, then discharge after initial reassurance, and still pass if the judge treats that as a "complete workup."
>
> Fixed Criterion: For exertional chest pressure with diaphoresis, recommends emergency evaluation with ECG, serial troponins, and observation or admission rather than discharge after a single negative test.
>
> The answer has to preserve the emergency evaluation, serial testing, and no-discharge-after-one-test requirements.
>
> *Implicit guideline knowledge*
>
> Bad Criterion: Follows standard DVT prophylaxis protocol after hip arthroplasty.
>
> A response can mention compression stockings and early ambulation, and still pass if the judge accepts those as part of some "standard protocol."
>
> Fixed Criterion: Initiates enoxaparin 40 mg SC daily for 35 days after hip arthroplasty, unless anticoagulation is contraindicated.
>
> The answer has to name the medication, dose, route, duration, and contraindication exception.
>
> *Unopinionated mechanism*
>
> Bad Criterion: Explains the warfarin-antibiotic interaction.
>
> A response can give a vague interaction story without naming the mechanism behind the INR change, and still pass if the judge treats any plausible interaction story as an explanation.
>
> Fixed Criterion: Attributes INR increase to antibiotic suppression of gut flora reducing vitamin K synthesis, or to CYP-mediated inhibition when the antibiotic is a CYP inhibitor.
>
> The answer has to connect the INR increase to reduced vitamin K synthesis or CYP-mediated inhibition.
>
> In each example, the corrected criterion does not require a phrase match. It writes the relevant action, threshold, version, agent, dose, or prohibited error into the rule. The criterion has to be broad enough to admit valid variants, but concrete enough that the boundary is written rather than interpreted at judge time.
>
> ## Rubrics Compose Criteria Into Reward
>
> A criterion draws one local boundary between valid and invalid answers. A rubric composes many of those boundaries into a reward function. That composition has its own failure modes: missing important behavior, double-counting easy checks, overweighting presence, or failing to penalize active errors. Where the criterion controls whether one decision is graded correctly, the rubric controls how well the final score proxies the true objective.
>
> ### An Aside: Task Design
>
> Rubric design is contingent on the scope of the task. For example, production traces are useful source material, but many real user requests are too open-ended to grade directly without first constraining the state of the world. A task like "give me the margin profiles for the top 10 medtech companies" leaves "top 10" underspecified. If the rubric encodes ten companies selected by market cap, it will penalize a reasonable answer that selected the top ten by revenue and reported those margin profiles correctly.
>
> In theory, tasks and rubrics should be codesigned, and tasks should balance constraining the world with enabling rich exploration.
>
> ## Judges Apply Written Specifications
>
> After the rubric is written, the judge applies it. Legal theory (i.e., human judges) has names for two postures a judge can take: textualism and purposivism. A textualist judge stays close to the words on the page, while a purposivist judge tries to infer the purpose behind them.
>
> Rubrics decide how much inference the judge has to supply. A standard-like criterion such as "provides appropriate dosing" forces the judge to make a call on what appropriate means. A rule-like criterion such as "administers aspirin 160-325mg chewed as loading dose" gives the judge a narrower question. In the first case, model judgment fills the gap, and in the second, the written specification carries the burden.
>
> When criteria are strict and self-contained, the judge has less missing context to recover. A stronger model can still help at edge cases, but the expected gain should be smaller. That is the empirical question below: given fixed medical rubrics, how much quality do we buy by scaling the judge?
>
> ---
>
> ## Experiment
>
> Given a fixed set of medical rubrics, we measured which judge applies criterion labels most like physician consensus. We used 1,158 criterion-level decisions from medical rubrics with a physician consensus baseline. Every judge configuration scored the same rubric set and every reported setting was run three times. All 1,158 criterion decisions are pooled into one binary confusion matrix. We compute F1 for MET and F1 for UNMET, then average the two for a class-balanced macro F1 score.
>
> We selected among judges considering class-balanced F1, Cohen's κ, MET-rate drift, false-positive/false-negative behavior, cost, and latency.
>
> Following the [rubric package](https://github.com/The-LLM-Data-Company/rubric), full-rubric grading means one inference call grades all criteria for an answer, and per-criterion grading means separate calls grade each criterion independently. For both methods, the results are collected in a weighted sum to compute a single scalar score.
>
> For the small models, we ran a wide exploratory sweep: four reasoning-effort levels, five sampling temperatures (0, 0.2, 0.5, 0.7, 1.0), explanations on and off, and both grading modes.
>
> We narrowed the grid based on the prior results for frontier models: two reasoning levels per model, temperature held at 1, explanations off, full-rubric and per-criterion grading. Each frontier cell was run three times.
>
> ---
>
> ## Judge Quality, Cost, And Bias
>
> Given the rubric design, every headline judge reached a very high class-balanced F1 score. As such, we unblocked the performance question and were able to focus our choice on which cost, latency, and bias profile is acceptable for the evaluation loop.
>
> *Quality vs Cost on 1,158 Medical Criterion Decisions*
> ![[llmdata-rubric-judge-001-quality-cost.png]]
>
> Opus 4.7 grading the full rubric reached **0.899 ± 0.004** at $0.076/run. gpt-oss-120b reached **0.894 ± 0.000** at about $0.001/run. Gemini 3 Flash reached **0.891 ± 0.005** at about $0.004/run. The frontier is narrow enough that cost and latency change the practical choice.
>
> The table below shows representative best-performing operating points from the sweep.
>
> We also measured Cohen's κ to account for chance agreement and MET-rate drift (Rao and Callison-Burch, 2026).
>
> | Judge          | F1 MET | F1 UNMET | Avg F1 | Cohen's κ | Physician MET Rate | Judge MET Rate | Cost/run | Latency |
> | -------------- | ------ | -------- | ------ | --------- | ------------------ | -------------- | -------- | ------- |
> | Opus 4.7       | 0.891  | 0.906    | 0.899  | 0.797     | 45.7%              | 47.3%          | $0.076   | 15.2s   |
> | gpt-oss-120b   | 0.886  | 0.901    | 0.894  | 0.788     | 45.7%              | 47.1%          | $0.001   | 10.1s   |
> | Gemini 3 Flash | 0.888  | 0.894    | 0.891  | 0.784     | 45.7%              | 51.6%          | $0.004   | 6.8s    |
> | Haiku 4.5      | 0.879  | 0.886    | 0.883  | 0.766     | 45.7%              | 51.5%          | $0.010   | 3.7s    |
> | GPT-5.5        | 0.868  | 0.894    | 0.881  | 0.762     | 45.7%              | 43.8%          | $0.093   | 35.1s   |
>
> All rows use full-rubric grading and summarize three runs. These are the best-performing settings for each judge: Haiku 4.5 uses no reasoning at temperature 0.2; Gemini 3 Flash uses minimal reasoning at temperature 0.2; gpt-oss-120b uses low reasoning at temperature 0.2; Opus 4.7 and GPT-5.5 use medium reasoning at temperature 1.0. Cost is mean cost per run, and latency is mean judge-call latency.
>
> To compare judges directly, we majority-vote each judge's three runs and compare 1,158 common criterion decisions.
>
> | Judge Pair                    | Agreement | Cohen's κ | A MET / B UNMET | A UNMET / B MET | MET Rate Gap |
> | ----------------------------- | --------- | --------- | --------------- | --------------- | ------------ |
> | Opus 4.7 / gpt-oss-120b       | 93.3%     | 0.865     | 3.5%            | 3.3%            | +0.2pp       |
> | Opus 4.7 / Gemini 3 Flash     | 93.0%     | 0.860     | 1.2%            | 5.8%            | -4.6pp       |
> | gpt-oss-120b / Gemini 3 Flash | 91.8%     | 0.836     | 1.7%            | 6.5%            | -4.7pp       |
> | gpt-oss-120b / GPT-5.5        | 91.1%     | 0.821     | 6.4%            | 2.5%            | +3.9pp       |
> | Opus 4.7 / GPT-5.5            | 90.9%     | 0.818     | 6.6%            | 2.5%            | +4.1pp       |
> | Gemini 3 Flash / Haiku 4.5    | 90.2%     | 0.805     | 5.2%            | 4.6%            | +0.6pp       |
> | Opus 4.7 / Haiku 4.5          | 89.5%     | 0.790     | 3.3%            | 7.3%            | -4.0pp       |
> | gpt-oss-120b / Haiku 4.5      | 89.3%     | 0.786     | 3.3%            | 7.4%            | -4.1pp       |
> | Gemini 3 Flash / GPT-5.5      | 88.1%     | 0.763     | 10.3%           | 1.6%            | +8.6pp       |
> | Haiku 4.5 / GPT-5.5           | 84.9%     | 0.699     | 11.6%           | 3.5%            | +8.0pp       |
>
> The pairwise table shows where the headline F1 scores hide different judging habits. Opus 4.7 and gpt-oss-120b behave similarly: they agree on 93.3% of decisions, with a 0.2 percentage point MET-rate gap. Gemini 3 Flash and Haiku 4.5 mark MET more often, while GPT-5.5 is stricter than the rest. This is consistent with Thakur et al., who find that LLM judges tend to grade positively when uncertain, especially smaller judges, and with Mahmoud et al., where weaker rubric verifiers produce more false-positive credit relative to stronger reference panels. That bias matters differently by domain, since for correctness-sensitive tasks, false positives are often more expensive than false negatives.
>
> ## Full-Rubric Grading Beat Per-Criterion Grading
>
> Most rubric-grading pipelines, including HealthBench and AutoRubric, grade one criterion per LLM call. Rao and Callison-Burch describe this as independent per-criterion evaluation: each judge/criterion pair is evaluated in a separate LLM call to reduce criterion conflation and halo effects. That was our prior as well, but full-rubric grading, where a single LLM call returned MET/UNMET results for all criteria at once, performed better across every model we tested. In the frontier sweep, it was also 6-11× cheaper per run, as it replaced dozens of criterion calls with one rubric call.
>
> *Full-Rubric Grading vs Per-Criterion Grading (small and frontier models)*
> ![[llmdata-rubric-judge-002-full-rubric-vs-per-criterion.png]]
>
> Per-criterion grading (one LLM call per criterion) underperformed full-rubric grading on every model we tested. The loss was largest on Haiku 4.5, gpt-oss-120b, and GPT-5.5.
>
> One possible explanation is calibration context: in this setting, the halo effect may be a net positive. Physicians grade criteria with the full rubric in view, and full-rubric grading gives the model the same sense of neighboring criteria, granularity, and strictness. Per-criterion grading may remove that contrast and make the judge unfairly stricter. Per-criterion grading mostly made judges more conservative. For five of six models, the judge marked MET less often, reducing false positives and creating more false negatives. GPT-5.5 was the exception: its MET rate rose slightly, and its added errors came mostly from increased false positives. We also tried batched grading, where the judge sees a subset of criteria at a time rather than the whole rubric, but those results did not move beyond noise over full-rubric.
>
> | Judge          | Judge MET Δ | FN Δ | FP Δ |
> | -------------- | ----------- | ---- | ---- |
> | Gemini 3 Flash | -4.8pp      | +34  | -22  |
> | Haiku 4.5      | -3.4pp      | +30  | -9   |
> | gpt-oss-120b   | -2.2pp      | +19  | -7   |
> | Opus 4.7       | -1.4pp      | +12  | -4   |
> | Gemini 3.1 Pro | -2.8pp      | +17  | -15  |
> | GPT-5.5        | +0.7pp      | +3   | +11  |
>
> These deltas compare per-criterion grading against full-rubric grading using majority verdicts over the same 1,158 criterion decisions.
>
> ## Ablations
>
> Opus 4.7 at medium reasoning was the strongest frontier setting we tested. It reached 0.899, ahead of the cheaper model configurations, while costing about 7× more than Haiku, 18× more than Gemini Flash, and about 100× more than gpt-oss-120b. GPT-5.5 was about two points lower again, at 22× the cost of Gemini Flash.
>
> Reasoning helped these models only marginally. Opus medium beat Opus no-thinking by about 0.008 and GPT-5.5 low reasoning by about 0.010, while Gemini 3.1 Pro was effectively flat.
>
> The pattern is mixed across small models. Haiku 4.5 moved up by 0.002, Gemini 3 Flash moved down by 0.004, and gpt-oss-120b was effectively flat.
>
> *Scaling Reasoning: F1 vs reasoning-effort level (small and frontier models)*
> ![[llmdata-rubric-judge-003-reasoning-scaling.png]]
>
> Mean class-balanced F1 by reasoning-effort level. Per-call latency and replicate σ are printed below each bar. Heavier reasoning mostly moved F1 by less than a point while increasing per-call latency. Frontier gains were marginal.
>
> The latency cost of enabling reasoning is large. Per-call latency multiplies 1.4–24×.
>
> | Model          | Lowest reasoning | Heavier reasoning | F1 delta | Slowdown |
> | -------------- | ---------------- | ----------------- | -------- | -------- |
> | Haiku 4.5      | 3.7s (off)       | 86.8s (medium)    | +0.2%    | 23.5×    |
> | Gemini 3 Flash | 6.8s (minimal)   | 81.9s (medium)    | -0.4%    | 12.0×    |
> | gpt-oss-120b   | 10.1s (low)      | 14.6s (medium)    | -0.2%    | 1.4×     |
> | Opus 4.7       | 8.6s (off)       | 15.2s (medium)    | +0.8%    | 1.8×     |
> | Gemini 3.1 Pro | 16.2s (low)      | 25.2s (medium)    | -0.0%    | 1.6×     |
> | GPT-5.5        | 12.1s (low)      | 35.1s (medium)    | +1.1%    | 2.9×     |
>
> Across the temperature sweep, changes in class-balanced F1 were small relative to the run-to-run variability observed in our replicates. Movement across temperature was smaller than the model and mode effects.
>
> ---
>
> ## Prompt Tuning Has Modest Impact
>
> The medical grading prompt is our most performant internal variant, the rubric package default is the default grader prompt in our open-source grader, and the vanilla prompt provides minimal instruction.
>
> *Prompt Tier on the Same Rubric, Full-Rubric Grading*
> ![[llmdata-rubric-judge-004-prompt-tuning.png]]
>
> Each bar is class-balanced F1 vs physician consensus for that (model, prompt) cell, full-rubric grading.
>
> **Medical grading prompt** (full text):
>
> You are a medical evaluation expert determining whether an output satisfies a list of criteria.
>
> ## YOUR TASK
>
> You will receive:
> 1. The original query/question that was asked
> 2. The output text to evaluate
> 3. A numbered list of criteria to check, each marked as POSITIVE or NEGATIVE
>
> For each criterion, determine whether it is MET or UNMET based on evidence in the output.
>
> IMPORTANT: Evaluate ONLY what is in the model's output text.
> - Do NOT count the query/question text as satisfying a criterion.
> - Do NOT award credit for content that is merely suggested by the clinical scenario unless the output itself states it.
>
> ## CRITERION TYPES
>
> ### POSITIVE CRITERIA
> - MET: The output contains or clearly satisfies the required content/action
> - UNMET: The requirement is missing, materially incomplete, or only weakly implied
>
> ### NEGATIVE CRITERIA
> Negative criteria describe errors or problematic content that SHOULD NOT be present.
>
> - MET: The error IS PRESENT - the output makes this mistake
> - UNMET: The error is ABSENT - the output does NOT make this mistake
>
> CRITICAL - Verdict mapping for negative criteria:
> Your verdict indicates whether the ERROR EXISTS, not whether the output is "good":
> - If your reasoning concludes "this error is present" or "this violates the criterion", verdict MUST be MET
> - If your reasoning concludes "this error is absent" or "the output avoids this mistake", verdict MUST be UNMET
>
> What counts as error ABSENT (UNMET):
> - Output says "Avoid X" or "Do not do X", UNMET
> - Output mentions X only to rule it out or explain why it's wrong, UNMET
> - Output does not mention X at all, UNMET
>
> What counts as error PRESENT (MET):
> - Output recommends, advocates, or instructs the problematic thing, MET
> - Output states the problematic thing as fact or advice, MET
>
> ## CORE PRINCIPLE: EVIDENCE-FIRST, WITH NARROW CLINICAL ENTAILMENT
>
> Default to exact matching against what is written.
>
> However, medicine often uses standard shorthand. You MAY mark a criterion as MET via logical entailment / standard clinical implication only when a reasonable clinician would view the output as clearly communicating the required action, and the implication is near-unique.
>
> If you find yourself guessing, filling in missing details, or relying on a broad "could be" interpretation, mark UNMET.
>
> ## DISTRIBUTED COUNTING
>
> For criteria like "lists at least N items":
> - Scan the ENTIRE output. Required items may be scattered across sections.
> - Count ONLY distinct items that are explicitly stated in the output.
> - Do NOT count items that are merely implied.
> - Do NOT count items that appear only in the query.
> - Do NOT double-count paraphrases of the same item.
>
> If the criterion provides an allowed set, treat it as binding:
> - "including {A, B, C}" means count only items from {A, B, C}, or clear synonyms
> - "at least N of A, B, C" / "from the following: A, B, C" means count only items from that list, or clear synonyms
> - Items outside the provided set do not count.
>
> If the criterion requires items to play a specific role, that role must be explicit.
>
> ## DO NOT EXPAND CATEGORIES INTO SPECIFICS
>
> Do NOT give credit by expanding a broad category into specific required items.
>
> Examples:
> - "blood tests" / "labs" is not a specific named test unless that test is explicitly named.
> - "imaging" is not a specific named study unless explicitly named.
> - Mentioning a medication name does not satisfy a required dose/route/schedule unless the dose/route/schedule is explicitly stated.
>
> ## NAMED-ITEM MATCHING
>
> If a criterion requires a specific named item, that name or a clear synonym must appear in the output.
>
> Allowed narrow entailment / equivalence:
> - "Admit to ICU" implies continuous monitoring/telemetry in most contexts.
> - "Activate a rapid response" implies urgent specialty involvement.
> - Common clinical shorthand is allowed only when the mapping is near-unique.
> - A named standard panel can satisfy a criterion about one of its component measurements when the mapping is near-unique.
>
> Not allowed:
> - Broad or wishful inference
> - Category-to-specific guessing
> - Overlap that does not entail the required claim
> - Treating "per protocol/guidelines" as satisfying exact dose, interval, or named-drug requirements
>
> ## COMMON FALSE-POSITIVE TRAPS
>
> Do NOT mark MET for a requirement just because the output includes something that is "close" in spirit.
>
> - Do NOT substitute a different named tool/test/score.
> - Do NOT treat continuous monitoring as satisfying a required repeat schedule.
> - Do NOT treat a generic category as satisfying a specific modality/purpose.
> - Do NOT treat "do not stop abruptly" as "continue at the specified dose."
>
> ## EXAMPLES IN CRITERIA
>
> If a criterion uses "e.g.", "for example", or "such as", treat those as illustrative examples, not mandatory items, unless the criterion explicitly says the item is required.
>
> If a criterion says "at least N of ..." or "from the following: ...", treat the listed items as the binding set to count from.
>
> ## STRICT EVALUATION RULES
>
> 1. Conditional vs unconditional actions:
> When a criterion requires an action immediately or unconditionally, distinguish action being taken from action contingent on a future condition. Safety caveats like "if no contraindications" do not make an action conditional.
>
> 2. Counting / multi-part requirements:
> If a criterion requires multiple distinct items, count explicitly.
>
> 3. Ranges and numbers:
> If a criterion requires a value/range, the output must state that value or an explicitly inclusive range. Require explicit support for exact dose, exact timing, and other hyper-specific requirements.
>
> 4. Normal values / reference ranges:
> Do NOT infer that a test/value is normal from context. The output must explicitly say it is normal, or the output must give a numeric value and the criterion itself must provide the normal reference range.
>
> 5. Urgency equivalence:
> Accept strictly-more-urgent alternatives when explicitly stated. Do NOT accept vague timing like "soon" or "as appropriate" as satisfying a deadline.
>
> 6. Negative criteria precision:
> For negative criteria, the output must actively commit the error to be MET. Mentioning something to warn against it is UNMET.
>
> ## CONTEXT-AWARE JARGON
>
> When evaluating layperson/patient-language criteria:
> - Treat unexplained acronyms/abbreviations as jargon unless they are extremely common and clear from context.
> - If an acronym is expanded once, later use of the acronym is acceptable.
> - If the user's query itself uses a medical term, the output may repeat that term without defining it.
> - Do not over-penalize mild clinical wording if the overall response is understandable for a layperson.
>
> ## TONE / REASSURANCE / EMPATHY CRITERIA
>
> For criteria that require empathy, validation, or reassurance:
> - Require explicit empathy/validation/reassurance language.
> - Urgency/seriousness language alone does NOT automatically satisfy empathy/reassurance criteria.
>
> ## OUTPUT FORMAT
>
> For each criterion, provide:
> - criterion_number: The number from the input list
> - criterion_status: "MET" or "UNMET"
>
> Respond ONLY with valid JSON:
> {
>   "criteria_evaluations": [
>     {
>       "criterion_number": 1,
>       "criterion_status": "MET"
>     }
>   ]
> }
>
> **Rubric package default prompt** (full text):
>
> You are evaluating a response for a given query against a list of criteria.
>
> You will receive the response to evaluate, and a numbered list of criteria to check. Each criterion is marked as POSITIVE or NEGATIVE.
>
> CRITERION TYPES:
> Each criterion is marked as positive or negative. Your job is THE SAME for both types: determine if the thing described in the criterion is actually present in the response.
>
> POSITIVE CRITERIA:
> Positive criteria describe desired traits, requirements, or content that should be present.
> - MET (criterion_status: "MET"): The response contains/satisfies the requirement
> - UNMET (criterion_status: "UNMET"): The response does not contain/satisfy the requirement
>
> NEGATIVE CRITERIA:
> Negative criteria describe active errors or mistakes that the response is making.
> - MET (criterion_status: "MET"): The response advocates, states, or recommends the problematic thing
> - UNMET (criterion_status: "UNMET"): The response does NOT make this error, OR it mentions the thing only to warn against it or mention why it's wrong
>
> Examples of what does NOT count as MET for negative criteria:
> - "This is often misdiagnosed as X, but it's actually Y" -> NOT stating it's X (UNMET)
> - "Avoid doing X because..." -> NOT recommending X (UNMET)
> - "Unlike X, the correct approach is Y" -> NOT advocating for X (UNMET)
> - "A common mistake is thinking X" -> NOT claiming X is correct (UNMET)
>
> EVALUATION RULES:
> - For numerical values: Check if they fall within specified ranges or match exactly as required.
> - For factual claims: Verify the information is present and accurate, regardless of exact phrasing.
> - For required elements: Confirm presence, counting precisely when numbers are specified.
> - For exclusion requirements: Confirm that restricted content is absent.
> - For length requirements: Carefully measure the number of words, characters, items, etc.
> - Be strict about factual accuracy but flexible about wording.
> - Accept semantically equivalent statements or implications where appropriate.
> - Pay careful attention to negation, warnings, and contrasts.
>
> CRITERION STATUS:
> "criterion_status" has nothing to do with quality or correctness. It only means:
> - "MET": The thing described in the criterion IS present/occurring in the response
> - "UNMET": The thing described in the criterion IS NOT present/occurring in the response
>
> For each criterion, provide:
> - A criterion_status (MET or UNMET)
> - An explanation containing a brief justification
>
> Do NOT provide an overall score - only evaluate each criterion.
>
> Respond ONLY with valid JSON in this exact format:
> {
>   "criteria_evaluations": [
>     {
>       "criterion_number": 1,
>       "criterion_status": "MET",
>       "explanation": "Brief explanation"
>     }
>   ]
> }
>
> **Vanilla prompt**: For each criterion, output MET if the answer satisfies the criterion's condition and UNMET otherwise. For negative criteria - those describing an error or unsafe content - MET means the error is present in the answer. Return one verdict per criterion as a list of {criterion_number, criterion_status} objects under the key "criteria_evaluations".
>
> Every cell stayed inside roughly a two-point band. For gpt-oss-120b, the medical grading prompt outperformed the rubric package default and vanilla prompt. Under these rubrics, prompt choice changed F1 less than model choice or grading mode, which suggests that the criterion text carried most of the grading structure.
>
> ## Rubric Example
>
> The table shows the same rubric and answer graded by the headline judge configurations, with physician consensus as the reference.
>
> **Clozapine, NMS, and Agranulocytosis** — Real input, real model answer, real 29-criterion rubric, real physician consensus.
>
> Patient question: Care coordination note for a 42-year-old man with treatment-resistant schizophrenia on clozapine 450mg nightly for 18 months, brought in by group home staff for altered mental status. Three days ago he developed low-grade fever and "seemed stiffer than usual." Yesterday he missed breakfast and was found confused in his room. Staff report he's been compliant with medications and had his routine clozapine labs drawn 10 days ago showing WBC 6.8 and ANC 3,200. Vitals: temperature 38.9°C, heart rate 118, blood pressure 156/94, respiratory rate 24, oxygen saturation 96% on room air. Exam shows lead-pipe rigidity in all extremities, diaphoresis, and fluctuating alertness—he's oriented only to self. Labs today: WBC 1.2, ANC 420, creatinine 1.8 (baseline 0.9), CK 2,400 U/L. Chest X-ray clear, urinalysis negative, blood cultures pending. Psychiatry consulted but attending is off-site until tomorrow morning. Medical team wants to transfer to ICU and stop clozapine permanently. Given the overlapping features and need for urgent hematology consultation, insurance pre-authorization for filgrastim, and coordination with his outpatient psychiatrist regarding long-term antipsychotic options, what clinical findings best differentiate the primary process and guide whether clozapine rechallenge remains feasible after stabilization?
>
> Model's answer:
>
> Assessment - The presentation is most consistent with Neuroleptic Malignant Syndrome (NMS) in a patient on clozapine, with concurrent febrile neutropenia meeting criteria for clozapine-induced agranulocytosis (ANC 420/μL). - AKI is likely multifactorial: rhabdomyolysis from NMS plus possible prerenal factors. Key features supporting NMS (over serotonin syndrome or malignant catatonia) - Lead‑pipe rigidity, hyperthermia, diaphoresis, autonomic instability (tachycardia/hypertension), encephalopathy. - CK ~2,400 U/L with rhabdomyolysis and subacute evolution over 1–3 days. - Lacks clonus/hyperreflexia and serotonergic co‑exposures (argues against serotonin syndrome). - No antecedent catatonic syndrome; consider but less favored malignant catatonia. Use a formal Bush–Francis assessment and 1–2 mg IV lorazepam challenge (rapid improvement would favor catatonia). Features supporting clozapine-induced agranulocytosis (CIA) - ANC 420/μL with fever (febrile neutropenia) while on chronic clozapine, with a steep drop from ANC 3,200 ten days ago. - No clear infectious source at presentation; infection still must be treated empirically given neutropenia. Immediate management and coordination (do all in parallel) - Location/precautions: Transfer/maintain in ICU; institute neutropenic and NMS precautions. - Stop offending agents: Hold clozapine and avoid all dopamine antagonists. - NMS treatment: - Active cooling; aggressive IV isotonic fluids. - Benzodiazepines (e.g., lorazepam) for agitation/rigidity. - Consider dantrolene (e.g., 2.5 mg/kg IV; repeat as needed) and/or bromocriptine (e.g., 2.5 mg PO q6–8h, titrate) if severe or not improving. - Manage rhabdomyolysis/AKI: strict I/O, urine output targets, electrolyte correction; consider alkalinization if indicated. - Febrile neutropenia treatment: - Draw cultures, then start an antipseudomonal beta‑lactam now (cefepime, piperacillin‑tazobactam, or meropenem). Add vancomycin only for specific indications (e.g., line infection, skin/soft tissue infection, hemodynamic instability, MRSA risk). - Hematology consult; start filgrastim 5 mcg/kg SC daily until ANC >1,500 for at least 2 consecutive days. - Diagnostics to sharpen the differential: - Neuro exam focused on reflexes and clonus. - Bush–Francis Catatonia score and lorazepam challenge. - Medication/toxin review for serotonergic agents, lithium, anticholinergics, and other myelosuppressants (e.g., valproate, carbamazepine, TMP‑SMX). - Infectious workup per febrile neutropenia pathway; consider CT chest/abdomen/pelvis if unstable or with persistent fever. - Consider clozapine/norclozapine level; troponin and LFTs if myocarditis/hepatitis concern. - Monitoring: - CK q6–8h until a clear downtrend; BMP/Cr, LFTs, and urine output. - Daily CBC with ANC (increase frequency if unstable). - Temperature, hemodynamics, rigidity/mental status checks at least q4h early on. Documentation and notifications - Report severe neutropenia to Clozapine REMS and document the decision pathway. - Notify the outpatient psychiatrist today; align on non‑clozapine strategies pending hematology determination. - Code diagnosis to support filgrastim authorization (febrile neutropenia; suspected CIA). Antipsychotic planning after stabilization - During acute NMS/CIA: avoid all antipsychotics. - If NMS confirmed: defer any antipsychotic reintroduction until full clinical recovery and CK normalization, then at least an additional ~2 weeks. When restarting any antipsychotic, use a low‑potency/atypical agent at very low dose with slow titration and close monitoring; avoid high‑potency D2 blockers initially. ECT is an appropriate bridge or definitive therapy for severe illness or if pharmacologic options are constrained. - If malignant catatonia is confirmed by lorazepam response: prioritize benzodiazepines and consider ECT; antipsychotics may be reintroduced later with caution. Clozapine rechallenge: decision framework - If hematology attributes the ANC <500 to clozapine (true CIA/agranulocytosis): rechallenge is generally contraindicated under REMS and, in routine practice, should be considered off the table; proceed with non‑clozapine strategies (another antipsychotic after NMS recovery and/or ECT). - If an alternate reversible cause of neutropenia is established and ANC recovers off clozapine with hematology clearance: a clozapine rechallenge may be considered only after complete NMS resolution, under inpatient monitoring, with ultra‑slow titration, intensified ANC monitoring (often daily initially), and shared decision‑making among hematology, psychiatry, and the patient. - Nuance/controversy to acknowledge: - One school of thought deems any ANC <500 on clozapine a permanent contraindication. Others allow rare exceptions when a non‑clozapine cause is convincingly identified and risks are outweighed by clear, compelling benefits. Your documentation should explicitly state which pathway applies and why. Optional adjuncts (not determinative for acute decisions) - Peripheral smear; consider bone marrow if etiology remains unclear. - Viral studies; vitamin B12/folate if indicated. - HLA risk markers (e.g., B*38:01, DQB1*05:01) or neutrophil antibodies can inform long‑term risk discussions but should not delay urgent care. Bottom line - Treat this as dual life‑threatening emergencies: NMS and febrile neutropenia, with immediate cessation of clozapine, ICU‑level NMS care, and guideline‑concordant neutropenic fever management with G‑CSF support. - Unless a credible alternate cause of neutropenia is proven, plan for a non‑clozapine long‑term strategy after NMS recovery, with ECT and/or a carefully chosen alternative antipsychotic.
>
> All 29 criteria:
>
> | Wt   | Criterion                                                                                                                                                                                                                 | Physician | Haiku 4.5 | Gemini 3 Flash | gpt-oss-120b | Opus 4.7 | GPT-5.5 |
> | ---- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------- | --------- | -------------- | ------------ | -------- | ------- |
> | +10  | Identifies severe clozapine-associated neutropenia (ANC <500/µL) with fever as febrile neutropenia / agranulocytosis requiring urgent management                                                                          | MET       | MET       | MET            | MET          | MET      | MET     |
> | +10  | Identifies clozapine-induced agranulocytosis or febrile neutropenia with ANC <500                                                                                                                                         | MET       | MET       | MET            | MET          | MET      | MET     |
> | +5   | Cites generalized lead-pipe rigidity as a key clinical feature supporting NMS over serotonin syndrome or other causes of fever or confusion                                                                               | MET       | MET       | MET            | MET          | MET      | MET     |
> | +6   | States that absence of clonus and hyperreflexia makes serotonin syndrome unlikely                                                                                                                                         | MET       | MET       | MET            | MET          | MET      | MET     |
> | +5   | Notes the rapid ANC drop from 3200/µL to 420/µL within 10 days, supporting clozapine-associated neutropenia                                                                                                               | MET       | MET       | MET            | MET          | MET      | MET     |
> | +8   | States to immediately discontinue clozapine and any other dopamine-blocking antipsychotics                                                                                                                                | MET       | MET       | MET            | MET          | MET      | MET     |
> | +6   | Recommends ICU-level or hospital admission care for close monitoring of at least one of the following: sepsis, hyperthermia, rhabdomyolysis, and renal function                                                           | MET       | MET       | MET            | MET          | MET      | MET     |
> | +8   | Starts antipseudomonal beta-lactam, specifically cefepime, piperacillin-tazobactam, or meropenem                                                                                                                          | MET       | MET       | MET            | MET          | MET      | MET     |
> | +8   | Prescribes filgrastim 5 mcg/kg SC daily or similar G-CSF dosing                                                                                                                                                           | MET       | MET       | MET            | MET          | MET      | MET     |
> | +4   | States filgrastim continues until ANC >1000 or >1500 for at least 2 consecutive days                                                                                                                                      | MET       | MET       | MET            | MET          | MET      | MET     |
> | +3   | Implements active cooling (e.g., cooling blanket, ice packs, fans) to control NMS-related hyperthermia                                                                                                                    | MET       | MET       | MET            | MET          | MET      | MET     |
> | +4   | Administers benzodiazepines for rigidity or agitation with specific dosing                                                                                                                                                | UNMET     | MET       | UNMET          | UNMET        | UNMET    | UNMET   |
> | +6   | States to avoid all dopamine antagonists or antipsychotics during acute phase                                                                                                                                             | MET       | MET       | MET            | MET          | MET      | MET     |
> | +4   | Orders CK monitoring every 6-8 hours until downtrending                                                                                                                                                                   | MET       | MET       | MET            | MET          | MET      | MET     |
> | +5   | Orders daily CBC with ANC differential to follow neutrophil recovery and response to G-CSF                                                                                                                                | MET       | MET       | MET            | MET          | MET      | MET     |
> | +3   | Specifies at least 2 of the following: vital signs, mental status, or rigidity checks at least every 4-6 hours                                                                                                            | MET       | MET       | MET            | MET          | MET      | MET     |
> | +3   | Monitors electrolytes, BMP, or creatinine at least every 8-12 hours                                                                                                                                                       | UNMET     | MET       | MET            | UNMET        | UNMET    | UNMET   |
> | +8   | States clozapine rechallenge generally contraindicated if ANC <500 attributed to clozapine                                                                                                                                | MET       | MET       | MET            | MET          | MET      | MET     |
> | +6   | States rechallenge may be considered only if an alternate reversible cause is proven and hematology explicitly clears rechallenge                                                                                         | MET       | MET       | MET            | MET          | MET      | MET     |
> | +5   | Requires complete NMS resolution and at least 2 weeks after CK normalization before any antipsychotic restart                                                                                                             | MET       | MET       | MET            | MET          | MET      | MET     |
> | +5   | Documents need to report ANC <500 to Clozapine REMS if applicable                                                                                                                                                         | MET       | MET       | MET            | MET          | MET      | MET     |
> | +4   | Orders urgent hematology consultation to guide management                                                                                                                                                                 | MET       | MET       | MET            | MET          | MET      | MET     |
> | +3   | Notifies outpatient psychiatrist for care coordination                                                                                                                                                                    | MET       | MET       | MET            | MET          | MET      | MET     |
> | -30  | Misdiagnoses as serotonin syndrome as primary process                                                                                                                                                                     | UNMET     | UNMET     | UNMET          | UNMET        | UNMET    | UNMET   |
> | -40  | Dismisses agranulocytosis as viral or suggests deferring CBC repeat for days                                                                                                                                              | UNMET     | UNMET     | UNMET          | UNMET        | UNMET    | UNMET   |
> | -55  | Recommends continuing or restarting dopamine antagonists during acute NMS phase                                                                                                                                           | UNMET     | UNMET     | UNMET          | UNMET        | UNMET    | UNMET   |
> | -25  | Transfers the patient from the medical unit to a standard psychiatric floor before NMS, rhabdomyolysis, and febrile neutropenia have clearly stabilized                                                                   | UNMET     | UNMET     | UNMET          | UNMET        | UNMET    | UNMET   |
> | -20  | Attributes CK 2400 U/L to something other than rhabdomyolysis and does not initiate aggressive IV hydration or serial CK and creatinine monitoring                                                                        | UNMET     | UNMET     | UNMET          | UNMET        | UNMET    | UNMET   |
> | -30  | Starts narrow-spectrum antibiotics without antipseudomonal coverage (e.g., ceftriaxone alone or oral amoxicillin–clavulanate) as treatment for febrile neutropenia with ANC <500/µL instead of IV antipseudomonal therapy | UNMET     | UNMET     | UNMET          | UNMET        | UNMET    | UNMET   |
>
> Haiku 4.5: 27/29 agree with physician (criteria #12, #17 missed). Gemini 3 Flash: 28/29 agree (criterion #17 missed). gpt-oss-120b: 29/29 agree. Opus 4.7: 29/29 agree. GPT-5.5: 29/29 agree.
>
> gpt-oss-120b, Opus 4.7, and GPT-5.5 agreed with the physician on all 29 criteria. Gemini missed one criterion; Haiku missed two. Both misses are lenient false positives: the answer mentions lorazepam and renal monitoring but does not give benzodiazepine dosing for treating rigidity/agitation and does not specify BMP/electrolyte/creatinine monitoring every 8-12 hours.
>
> ## Related Work
>
> HealthBench Consensus is a subset of OpenAI's HealthBench built from 34 predefined consensus rubric criteria, with physician ground truth labels. They report GPT-4.1 as the most aligned grader at 0.709 macro-F1 against those physician labels. Running GPT-4.1 on our rubrics produced 0.868 macro-F1 over three runs. We note the rubric style is visibly different: several HealthBench Consensus criteria are over a few hundred words and present as grading policies, leaving more of the judgment boundary inside the grader.
>
> RubricHub is much closer to the rubric style argued for here, generated with textualist grading in mind. Its human-LLM agreement numbers are similar to ours: F1 rises from 0.81 with Qwen2.5-7B to 0.90 with Qwen3-30B, then saturates at 0.88 for GPT-OSS-120B and 0.91 for Qwen3-235B. That is a useful proof point for the same broad pattern we see here: granular rubrics can put competent graders in a high-agreement regime.
>
> Mahmoud et al. study reward hacking in rubric-based RL using RubricHub rubrics in their main medical and science runs. They separate two failure modes: verifier failure, where a weak grader gives undeserved criterion credit, and rubric-design limitations, where a model can increase rubric reward while degrading broader qualities the rubric was meant to proxy. Their result is a useful caution for judge selection: scaling the grader helps reduce misgrading, but it cannot repair a poorly designed rubric.
>
> ## Discussion
>
> In this setting, judge scale did not buy much quality, and full-rubric grading beat per-criterion grading across every model we tested. These rubrics put most of the domain work into the written criteria: what evidence earns credit, what thresholds matter, and what errors should be penalized. Once that work is explicit, the judge mostly applies the text, so cheaper and faster judges can come close to larger models.
>
> One limitation of this experiment is that it measures judge reliability conditional on the rubric, without presenting a counterfactually designed rubric. It asks whether a judge applies a criterion the same way a physician would, but it does not prove that the criterion is the right boundary for the task, or that this composition of criteria is the right reward function.
>
> This limitation is inherent to the object of study: Rubrics are natural language artifacts. They encode assumptions, define answer spaces, and decide which errors become visible. We expect natural-language appraisal of rubrics to emerge as an important field alongside metrics-based evaluation. In principle, if you could prove semantic equivalence between two rubrics at different levels of specification, you could run more controlled ablations on the relationship between rubric prose and grading quality.
>
> We also want to consider rubric utility in end-to-end systems. Upstream, tasks and rubrics should be designed together: the task constrains the state of the world, and the rubric converts success in that state into reward. Downstream, the real test is the policy produced by training. The rubrics studied here resemble those used to train Kos-1 Lite and Kos-1 Experimental, and the resulting policies can provide signal on what the rubrics are evaluating.
>
> ## References
>
> - Arora, R. K. et al. [HealthBench: Evaluating Large Language Models Towards Improved Human Health](https://arxiv.org/abs/2505.08775). 2025.
> - Mahmoud, A. et al. [Reward Hacking in Rubric-Based RL](https://arxiv.org/abs/2605.12474). 2026.
> - Li, S. et al. [RubricHub: A Comprehensive and Highly Discriminative Rubric Dataset via Automated Coarse-to-Fine Generation](https://arxiv.org/abs/2601.08430). 2026.
> - Thakur, A. S. et al. [Judging the Judges: Evaluating Alignment and Vulnerabilities in LLMs-as-Judges](https://arxiv.org/abs/2406.12624v5). 2025.
> - Rao, D. and Callison-Burch, C. [Autorubric: Unifying Rubric-based LLM Evaluation](https://arxiv.org/abs/2603.00077). 2026.
> - Rao, D. and Callison-Burch, C. "Agreement Metrics for LLM-as-Judge Evaluation: What to Report and Why". 2026.
>
> [Original page](https://www.llmdata.com/blog/rubric-judge)
