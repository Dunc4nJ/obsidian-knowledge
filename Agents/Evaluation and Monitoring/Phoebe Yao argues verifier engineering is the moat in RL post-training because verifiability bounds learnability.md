---
created: 2026-05-22
description: Phoebe Yao argues that in RL post-training, the frontier of verifiability is the frontier of learnability, and that crafting new verification methodologies — including five quality properties and ten failure modes — is the binding constraint on translating expert judgment into trainable RL signal.
source: https://x.com/phoebeyao/status/2057544029479502187
type: synthesis
---

# Phoebe Yao argues verifier engineering is the moat in RL post-training because verifiability bounds learnability

## Key Takeaways

- **Verifier quality is the binding constraint on RL learnability, not algorithm or compute.** Yao reframes the post-training stack around a single thesis: "the frontier of verifiability is the frontier of learnability." This sharpens claims already in the vault — see [[agentic RL training converges on outcome rewards inside production harnesses across Kimi Cursor and Chroma]] where Kimi, Cursor, and Chroma each had to redesign rewards iteratively to escape reward hacking, and [[Perplexity post-trains Qwen3.5 search agents with two-stage SFT+RL and gated reward aggregation to prevent hacking]] where atomic-objective-necessary rubrics gate the entire training pipeline. The capability that is hardest to verify is the capability hardest to train, regardless of how good your sampler is.

- **Verifier design decomposes into five distinct quality properties that rarely co-maximize.** Yao breaks quality into consistency, calibration, coverage, robustness, and auditability — and explicitly notes no single verifier maximizes all five, so the design choice is *which mix of modalities* fits the capability. This is the missing vocabulary in earlier vault notes on graders. The Anthropic guide ([[anthropic recommends combining deterministic graders model judges and human review for agent evals]]) recommends layering code/model/human graders but doesn't decompose *why* each is needed. Yao's framework supplies the why: programmatic checks deliver consistency and auditability but fail coverage on subjective tasks; judges deliver coverage but lose robustness under optimization pressure.

- **Roughly 70% of expert-built rubrics get weighting wrong on the first attempt, and the failure modes are systematic.** Yao's "10 failure modes" list operationalizes verifier review: rubric weighting (formatting points can dominate reasoning points), gameable defaults (flag-everything strategies), brittle tolerance, binary-vs-partial-credit gradients, redundant correlated checks, grading non-determinism, over-instrumented paths, multi-output averaging masking critical failures, agentic-grader reference discipline (grader overriding ground truth), and solution leakage. This is the most concrete failure-mode catalogue in the vault — pairs naturally with [[rl environment creation is becoming a distributed marketplace that could 10x cost efficiency over contracting firms]] which proposes LLM-adversarial pipelines to surface these defects programmatically.

- **The economic gradient runs from cheap programmatic checks to expensive agentic grading, so verifier design is fundamentally a values question, not just an engineering one.** Yao notes agentic grading over 10,000 long-horizon tasks costs orders of magnitude more than programmatic verification, and quality has no real ceiling — so the real question is "what is worth verifying well." This is why [[process reward models that verify each reasoning step outperform outcome-only scoring]] doesn't always pay off in production: the marginal verifier cost outpaces the marginal learnability gain on most tasks. The capabilities that advance a field — legal reasoning, emotional intelligence, multi-step research — happen to be the ones where verification is most expensive, which is exactly why building those verifiers constitutes the moat.

- **Verification is the encoding of taste, making it hard-to-replicate non-transferable alpha at both the lab and data-provider level.** For frontier labs, better verifiers translate directly to faster capability gains; for data providers like Yao's company, verifier methodology is the durable offering that survives commoditization of raw data and compute. This recasts the data-vendor narrative: the moat isn't volume of labels, it's the per-domain verification IP. Compare with [[auto-research as a multi-agent GAN with curriculum learning prevents reward hacking]] (adversarial Eval-vs-Optimizer setup) and [[prover-verifier games train legible chain-of-thought by iteratively pitting adversarial provers against small verifiers]] — both treat the verifier as a learned object worth competing against.

## External Resources

- [Original X post](https://x.com/phoebeyao/status/2057544029479502187) — Phoebe Yao's "Verifier Engineering is the Moat" article posted on X
- [Christian Catalini's referenced thesis](https://x.com/ccatalini/status/2057595041758281811) — reply linking a thesis Yao says is "word for word on verification" regarding the measurability gap
- Credits: Cody Cooper, Vignesh Radhakrishnan, @Dimitris_Chavou, @FArefin — contributors whose work shaped the piece

## Original Content

> **@phoebeyao (Phoebe Yao) — Thu May 21 19:28:18 +0000 2026**
>
> Article: Verifier Engineering is the Moat
>
> All good verifiers are alike. Each bad verifier is bad in its own way.
>
> In RL post-training, the frontier of verifiability is the frontier of learnability. Crafting new verification methodologies is the binding constraint on translating expert judgment into trainable RL signal. Building that verification signal for frontier labs is a fascinating part of what we do as a data provider. This is how we think about the work.

*Header illustration: Verifiers as the gateway between rollouts and trained capability — four modality cards (Programmatic Checks, Judges, Reward Models, Agentic Grading)*
![[phoebeyao-502187-001.jpg]]

> ## What is a Verifier?
>
> A verifier is a mechanism that evaluates rollouts against a standard and produces verdicts suitable for optimization.
>
> In reward-based training, the verdict serves as, or feeds into, the reward function. Verdicts are also used to drive quality control and failure-mode analysis.
>
> In production, verifiers are usually a hybrid of modalities:
>
> - A programmatic check verifies exact outputs where it can, and falls back to an LLM judge with a rubric for the subjective parts.
>
> - Programmatic scoring handles the outcome while a judge grades the process.
>
> - An agent runs programmatic checks from its own toolset to verify parts of a task.

*Verifier pipeline: Rollout → Verifier (verdict against stated/learned standard) → Aggregation (weighted sum, critical-item gating) → Shaping (length penalties, format bonuses, intermediate-step bonuses) → Reward (scalar)*
![[phoebeyao-502187-002.png]]

> The most common building blocks:

*Modality comparison table: Programmatic, LLM-as-judge, Agentic grading, and Reward model — each with standard type, mechanism, best-for use case, and main risk*
![[phoebeyao-502187-003.png]]

> The more sophisticated the capability, the more sophisticated the verification method needed to deliver the highest-fidelity verdict. Programmatic checks for code are straightforward, but mechanisms that define successful legal reasoning or emotional intelligence need careful, focused R&D.
>
> ## Designing a High-Quality Verifier
>
> What does it take to build verifiers with low false-positive and false-negative rates? We break quality down into five properties:
>
> - Consistency. Does the verifier produce stable verdicts across repeated rollouts?
>
> - Calibration. Do verdicts track actual task success as a domain expert would judge it? This is the verifier's construct validity.
>
> - Coverage. Does the rubric check the material requirements of the task, without omitting necessary criteria or adding unsupported ones?
>
> - Robustness. Does the verifier stay reliable under optimization pressure, or can it be reward-hacked?
>
> - Auditability. Can the verifier's behavior be inspected, reproduced, and calibrated?
>
> No single verifier maximizes all quality dimensions, so it comes down to choosing the methodology and mix of modalities that best fit the pipeline, which depends on the attributes of the capability being verified:
>
> 1. Ground-truth structure. What makes the output correct, a binary decision or a judgment call? This decides whether a programmatic check is even possible.
>
> 2. Output shape. A single number or structured JSON has different verification properties than a tool-call sequence, a mutated environment state, or a free-text summary.
>
> 3. Stakes. For safety-critical evals, false negatives cause real harm and must be avoided, which changes how the rubric is weighted.
>
> ## 10 Common Failure Modes
>
> Nearly every verifier is imperfect, and the difference between good and bad is subtle enough that catching it takes careful review even for experienced teams. After a year building verifiers for frontier labs, here are the 10 failure modes we see most often.
>
> 1. Rubric weighting
>
> In our experience, about 70% of experts get rubric weighting wrong on their first attempts. To illustrate, here's a real task we reviewed, with eight criteria summing to 10 points:

*Rubric weighting example: 8 criteria summing to 10 points, where "correctly identifies 4 leaking features" is worth 3 but most points come from formatting checks*
![[phoebeyao-502187-004.png]]

> A model can score 9 out of 10 by writing valid JSON, listing every feature as leaking, and just dropping a single point for excluding non-leaks, which happens to be the only reasoning criterion that checks discrimination.
>
> Fix: make the reasoning criteria gating, or rebalance so a rollout can't pass on formatting alone.
>
> 2. Gameable problems
>
> Gameable problems have a default answer the model can guess without reasoning, or a rubric that doesn't penalize lazy strategies.
>
> Example: the leakage example above rewards the model for flagging features as leaky but doesn't penalize wrongly including non-leaky ones, so naming every feature scores highly. Outlier-detection tasks have the same shape: if the answer is most often "none," guessing it becomes a cheap default way to score without completing the actual task.
>
> Fix: score both directions, so over-flagging is penalized as much as missing, and defaults aren't rewarded.
>
> 3. Tolerance
>
> Tolerance is about what counts as equivalent. A verifier that doesn't allow for natural variation in correct answers will reject good trajectories.
>
> Example: a type mismatch, where a string, an int, and a double for the same value aren't equal under a naive programmatic check.

*Tolerance example: strict comparison treats "1" ≠ 1 ≠ 1.0 as three different values*
![[phoebeyao-502187-005.png]]

> Decimal precision is another: whether 1.0 equals 1.001 depends on the task. When tolerance is too tight, false negatives pile up and good trajectories go unrewarded. Programmatic checks fail here more than judges, since a script compares literally where a grader can rule on equivalence.
>
> Fix: define equivalence explicitly for the task, or use a grader for criteria where valid answers vary.
>
> 4. Binary vs partial credit
>
> Binary scoring throws away signal on near-misses:

*Binary vs partial credit: a near-solution scores 0/1 on binary but 0.5/1 on partial credit (steps 1, 3, 5, 7 correct = made progress)*
![[phoebeyao-502187-006.png]]

> This collapses the gradient with a brittle verifier that can't distinguish a near-solution from a non-starter, or a shortcut from a genuine solution. The weakness in calibration and robustness compounds in long-horizon agent tasks.
>
> Final outcomes can also benefit from partial credit. For instance, the task "train a classifier and report accuracy" has no single right number, so a verifier could grade the approach (the EDA, the model choice) alongside a banded score on the result (1.0 if R² > 0.9, 0.7 if R² > 0.6, and so on).
>
> Fix: award partial credit for intermediate steps, and for final outcomes where correctness is tolerance-based.
>
> 5. Redundant checks
>
> Redundant checks happen when two criteria pass or fail together because one condition drives both, so the verifier double-counts a single capability.
>
> Example: a rubric that scores "query parses" and "query references valid tables" as separate criteria is scoring well-formed SQL twice.
>
> Fix: check which criteria are statistically correlated across production rollouts, and collapse the ones that always move together.
>
> 6. Grading non-determinism
>
> Real tasks have real ambiguity. Professionals reason from incomplete information using expert judgment, and verifying that reasoning is the hardest problem we face. Rigid rubrics that expect one solution penalize valid alternatives; lenient rubrics fail to check whether the reasoning was sound at all.
>
> Approach: agentic grading against a rubric that specifies what counts as valid reasoning across multiple correct paths. The burden shifts to rubric design.
>
> 7. Over-instrumented rubrics
>
> The opposite of missing coverage: too many intermediate or method-specific checks bias the score toward one expected solution path, even when other valid approaches solve the task.
>
> Example: a rubric for a data-summary task that scores specific column values, exact subtotals, metadata fields, source choices, and sort order, all on top of the final answer. It rewards the expected method instead of judging whether the result is correct.
>
> Fix: check the final outcome and the genuinely load-bearing steps; drop checks that only encode one path.
>
> 8. Multi-output aggregation
>
> When a task requires several final outputs, averaging rubric scores lets a wrong answer pass.
>
> Example: a prompt asks for total, max_id, and count, equally weighted. The solver gets max_id wrong but still passes because the average clears the threshold.
>
> Fix: gate pass/fail on all critical outputs, and use partial credit only for diagnosis.
>
> 9. Agentic grader reference discipline
>
> An agentic grader should grade against the rubric and the provided ground truth, not substitute its own answer.
>
> Example: the reference says 573, but the grader recomputes the answer under its own assumptions, lands on 640, and passes the run, overriding the ground truth it was supposed to enforce.
>
> Fix: constrain the grader to the reference. Let it recompute only when explicitly told to verify the reference through a deterministic procedure.
>
> 10. Solution leakage
>
> A verifier should detect and penalize answers that came from information the solver shouldn't have.
>
> Example: a solver prints the expected answer after reading a hidden solution.md or expected_output.txt, instead of computing it. The output is correct, but it should fail.
>
> Fix: inspect trajectory and file-access logs, and penalize any use of hidden answers, verifier logic, or expected outputs.
>
> ## Why this is the moat
>
> By now it should be obvious: verification is the encoding of taste. Anyone building verifiers is building hard-to-replicate, non-transferable alpha. For a lab, that alpha is faster capability gains. For a data provider, it's a durable offering.
>
> Quality has no real ceiling, so cost is what gates verifier development. Agentic grading over 10,000 long-horizon tasks costs orders of magnitude more than near-free programmatic verification. The real art isn't "how do we verify this well" but "what is worth verifying well," a question that's as much about values as economics.
>
> The capabilities that advance a field often aren't the easiest to verify. We think we can accelerate that work through a virtuous cycle, humans teaching models and models helping humans take on harder work, powered by novel verification methodologies that keep pushing the frontier of what's learnable.
>
> Thanks to Cody Cooper, Vignesh Radhakrishnan, @Dimitris_Chavou, @FArefin for sharing the insights from their work that shaped this piece.

---

### Replies and author follow-ups (verbatim)

> **@henrytdowling (Henry Dowling) — Thu May 21 22:40:41 +0000 2026**
>
> @phoebeyao this was a great read! what domains do you think are the hardest to produce a verifier for rn? something like ai therapy?

> **@ccatalini (Christian Catalini) — Thu May 21 22:51:00 +0000 2026**
>
> @phoebeyao Consistent with our take here: https://t.co/QHey0hqY5f

> **@phoebeyao (Phoebe Yao) — Thu May 21 23:09:05 +0000 2026** *(reply to @henrytdowling)*
>
> @henrytdowling thanks! therapy is a great example. any domain where it's difficult to measure success. therapy specifically requires understanding the response the specific user wants in context. funnily we actually have a benchmark on this coming out next week.

> **@essamsleiman (Essam Sleiman) — Fri May 22 00:32:33 +0000 2026**
>
> @phoebeyao great read! lots of alpha in this

> **@phoebeyao (Phoebe Yao) — Fri May 22 00:36:52 +0000 2026** *(reply to @ccatalini)*
>
> @ccatalini beautiful thesis! we're word for word on verification. how do you see data vendors like us affecting the measurability gap? we drive down cost to automate and cost to verify at the same time, so i can't tell if we net narrow or widen it.

> **@phoebeyao (Phoebe Yao) — Fri May 22 00:38:09 +0000 2026** *(reply to @essamsleiman)*
>
> @essamsleiman thank you! 🙏

> **@advaith_sridhar (Advaith Sridhar) — Fri May 22 01:35:38 +0000 2026**
>
> Great article. We think the impact of AI on science will also be driven by the quality of verifiers. Some of these verifiers will be computational (such as physics based Density Functional Theory calculations), but many of them will be experiments done in a real lab, based on the model's ideas

> **@aloobhujiyan (shashank) — Fri May 22 01:54:21 +0000 2026**
>
> @phoebeyao This is so important, verifier engineering is just making sure, agents don't reward themselves for bad outputs.
>
> Verification -> On policy distillation / or better model choice ~> Better outcomes
>
> Thanks for writing this 🙏

---

[Source: @phoebeyao on X — Thu May 21 19:28:18 +0000 2026](https://x.com/phoebeyao/status/2057544029479502187)
