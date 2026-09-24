---
created: 2026-09-24
source: https://gepa-ai.github.io/gepa/blog/2026/09/17/bridging-the-subjectivity-gap/
via: https://x.com/sethkimmel3/status/2102876652820930944
author: Sutro (Seth Kimmel) on the GEPA blog
published: 2026-09-17
type: knowledge
tags: [gepa, prompt-optimization, subjectivity, lead-scoring, model-selection, consistency, sutro, dspy, evals]
description: A Sutro case study on the GEPA blog optimizes a three-way lead-scoring prompt for eleven models using 30 human annotations, raising mean held-out accuracy from 35.2 to 78.1 percent and every model above 90 percent consistency, with peak accuracy reached 79 percent cheaper on GPT-5.6 Luna than on Gemini 3.5 Flash.
---

# Sutro's GEPA lead scorer lifts eleven models 42.9 points from 30 annotations - but the held-out set is also 30, so gpt-oss-120b beating Claude Sonnet 4.5 is a one-item difference

Seth Kimmel and the Sutro team published this as a community guest post on the GEPA project's own blog on 2026-09-17, and Kimmel announced it on X six days later. It is the applied, multi-model version of the argument the vault already holds in [[GEPA prompt optimizer beats reinforcement learning with 35x fewer rollouts by reflecting on natural-language execution traces]], and the second Sutro run of the same idea after [[Sutro's jev-align uses GEPA to rewrite Jev's decision criteria from five labeled examples - the demo moves labeled-set ambiguity 49.6 points but full-pool certainty only 0.5]].

## Key Takeaways

- **The mechanism is real and the vault already predicted the size of the win.** Mean held-out accuracy across eleven models went from 35.2 to 78.1 percent, which reproduces the post's headline +42.9pp exactly. But five of the eleven default prompts scored at or below the 33.3 percent chance level for a three-way label, and one scored zero. That is precisely the condition [[dspy-agent-skills shows GEPA only improves when there is failure signal - 1.2B models gain 25 points where 8B+ no-op]] identifies as the prerequisite for a large GEPA lift: abundant failure signal in the minibatches. Gemini 3.5 Flash, the strongest default at 57 percent, gained the least (+20pp). The lift is a function of how broken the starting prompt was, not of how much capability the optimizer added.
- **Both the training set and the eval set are 30 items, which puts the eleven-model ranking inside the noise.** Every reported accuracy is a multiple of 1/30, so a model at 73 percent got 22 of 30. The 95 percent interval on 22/30 runs from 54 to 88 percent. The tweet's sharpest claim, that open-weight models beat the frontier, rests on gpt-oss-120b at 23/30 against Claude Sonnet 4.5 at 22/30, a single item, Fisher exact p = 1.000. Even GPT-5.6 Luna at 27/30 against gpt-oss-120b at 23/30 is p = 0.299. The optimized ceiling of 90 percent is the interesting number; the ordering below it is not measured.
- **Cost, not the optimizer, is where the result has teeth.** Reading the scatter, optimized GPT-5.6 Luna reaches 90 percent at about $0.52 per 1,000 records against Gemini 3.5 Flash's $2.48 at 77 percent, which is the post's 79 percent figure, and optimized Claude Sonnet 4.5 costs about $8.76 for the same 73 percent that optimized gpt-oss-20b delivers near $0.19. A 40x spread in serving cost across models that are statistically tied is a decision you can act on even when the accuracy ranking is not. This is the same shape as [[LLM Data Company experiments show explicit rubric criteria let gpt-oss-120b match Opus 4.7 at 100x lower cost and full-rubric grading beats per-criterion across every model]], arrived at from the optimizer side rather than the rubric side.
- **Consistency above 90 percent is a repeatability claim, not a correctness claim.** Consistency here is the modal answer rate over ten runs of the same prompt, so a model can sit at 97 percent consistent and 77 percent accurate, which GPT-5.6 Luna and Gemini 3.5 Flash both roughly do. The post reports the two metrics side by side without ever claiming one implies the other, but the tweet's "+31%" reads as a quality gain. [[LangChain's Jev-as-a-Judge bench puts Jev's quality-score variance 92 to 913x below three LLM judges at $0.34 against Claude's $28.17 - five weather traces, one human oracle, provider-default sampling]] makes the same warning explicit: low variance can mean consistently wrong.
- **The protocol sits between Sutro's own prior demo and the vault's rigor benchmark, and reports no calibration.** [[Sutro's jev-align uses GEPA to rewrite Jev's decision criteria from five labeled examples - the demo moves labeled-set ambiguity 49.6 points but full-pool certainty only 0.5]] used five labels and no held-out set at all, so a genuine 30-item held-out eval is a real upgrade. But [[Praneeth Paikray measures Jev's calibration for the first time - ECE 0.173 and Brier 0.156 lose to a TF-IDF baseline, and GEPA nearly halves the probability error]] runs 100 train, 100 validation and 300 fresh test with a SHA-256-frozen candidate and reports Brier and ECE, and his headline caution applies directly here: he improved probabilities and F1 by ten points while the actual screening policy got worse. Accuracy on 30 items is not a deployment green light.
- **The fair baseline is missing.** The post compares GEPA against "a short prompt that briefly described what Sutro does," and lists manual prompt engineering only as a costly alternative it did not run. Nobody disputes that an optimizer beats an unengineered stub. The open question, which this study does not answer, is whether 30 annotations plus GEPA beats a competent engineer with the same 30 annotations and an afternoon.

## The Task and Protocol

| Element | Value |
| --- | --- |
| Task | Lead scoring, Sutro's own: classify a lead as a strong, medium, or weak fit |
| Label cardinality | Three-way, so chance accuracy is 33.3 percent |
| Starting prompt | "a short prompt that briefly described what Sutro does" |
| Annotations for optimization | 30 |
| Held-out eval set | 30 (confirmed by both chart subtitles reading "30 judgments", and by every accuracy being a multiple of 1/30) |
| Total human labels | 60 across the two sets |
| Models | Eleven, each optimized separately |
| Optimizer | GEPA, an open-source reflective optimizer; the post credits its `optimize_anything` abstraction but states no version and shows no code |
| Accuracy metric | Agreement with held-out human labels |
| Consistency metric | Modal answer rate over ten independent runs with the same prompt |
| Cost axis | Extrapolated inference cost to process 1,000 records; the post does not name the price source or token basis |

Sutro's platform materializes a stream of hard lead-scoring cases for annotation. The post's footnote is explicit that curating that stream, not writing the starting prompt, is the scarce step. The post calls both 30-item sets "held-out", which is loose for the one GEPA trained on; the eval set is genuinely held out from optimization.

Two things the protocol does not include: a separate validation split for GEPA candidate selection, and any calibration measure. GEPA's Pareto candidate selection therefore ran against the same 30 training labels it optimized on.

## Results

*A two-axis diagram categorizing AI tasks by how often they repeat and whether correctness is objective or organization-specific. AI Functions, such as judging whether a company is a good lead, occupy the highly repeated and organization-specific quadrant.*
![[sutro-gepa-subjectivity-01.png]]

### Accuracy, all eleven models

| Model | Default prompt | Optimized prompt | Gain |
| --- | --- | --- | --- |
| gpt-oss-120b | 23% | 77% | +54pp |
| gpt-oss-20b | 20% | 73% | +53pp |
| nemotron-3-nano | 0% | 73% | +73pp |
| nemotron-3-super | 37% | 90% | +53pp |
| claude-haiku-4-5 | 30% | 83% | +53pp |
| claude-sonnet-4-5 | 47% | 73% | +26pp |
| gemini-3.5-flash | 57% | 77% | +20pp |
| gemma-4-26b-a4b | 43% | 73% | +30pp |
| gemma-4-31b | 30% | 77% | +47pp |
| openai-gpt-5.6-luna | 57% | 90% | +33pp |
| openai-gpt-5.6-terra | 43% | 73% | +30pp |

Mean default 35.2 percent, mean optimized 78.1 percent, difference +42.9pp, which reproduces the post's headline figure and confirms the table is complete.

The scatter's own per-arrow labels disagree with this table twice, because the table subtracts rounded percentages while the chart rounds the true k/30 difference: the chart reads Claude Sonnet 4.5 as +27pp where the table says +26, and gpt-oss-120b as +53pp where the table says +54. Both charts also carry a "30 judgments" subtitle, which is the clearest statement anywhere in the post of the eval set size.

### Consistency across ten runs, all eleven models

| Model | Default prompt | Optimized prompt | Gain |
| --- | --- | --- | --- |
| gpt-oss-120b | 53% | 93% | +40pp |
| gpt-oss-20b | 41% | 91% | +50pp |
| nemotron-3-nano | 35% | 92% | +57pp |
| nemotron-3-super | 60% | 91% | +31pp |
| claude-haiku-4-5 | 62% | 92% | +30pp |
| claude-sonnet-4-5 | 65% | 95% | +30pp |
| gemini-3.5-flash | 77% | 97% | +20pp |
| gemma-4-26b-a4b | 80% | 94% | +14pp |
| gemma-4-31b | 59% | 95% | +36pp |
| openai-gpt-5.6-luna | 91% | 97% | +6pp |
| openai-gpt-5.6-terra | 72% | 95% | +23pp |

The dumbbell chart carries one more decimal place than the table: +57.3, +49.3, +40.7, +35.7, +30.3, +30.3, +29.7, +23.3, +20.0, +14.3, +5.7, and an all-model average of +30.6pp.

*Scatter plot of held-out lead-scoring accuracy against estimated inference cost for eleven models. Arrows connect each model's default-prompt accuracy to its optimized-prompt accuracy, showing gains of 20 to 73 percentage points.*
![[sutro-gepa-subjectivity-02.png]]

### Scatter transcription: cost per 1,000 records

The cost axis appears nowhere in the prose except as the 79 percent and 54 percent ratios, so the chart is the only source for per-model cost. Values below were read off the plot by locating each marker against the $0 / $2.37 / $4.73 / $7.10 / $9.47 ticks. Two independent checks land: optimized Luna at $0.52 against optimized Gemini 3.5 Flash at $2.48 is 79 percent lower, and optimized Nemotron 3 Super at $1.10 is 56 percent lower, matching the post's stated 79 percent and 54 percent.

| Model | Default acc | Default cost | Optimized acc | Optimized cost |
| --- | --- | --- | --- | --- |
| nemotron-3-nano | 0% | $0.10 | 73% | $0.11 |
| gpt-oss-20b | 20% | $0.13 | 73% | ~$0.19 |
| gemma-4-26b-a4b | 43% | $0.15 | 73% | $0.23 |
| gemma-4-31b | 30% | $0.18 | 77% | $0.26 |
| gpt-oss-120b | 23% | $0.34 | 77% | $0.46 |
| openai-gpt-5.6-luna | 57% | $0.43 | 90% | $0.52 |
| nemotron-3-super | 37% | $0.90 | 90% | $1.10 |
| gemini-3.5-flash | 57% | $2.43 | 77% | $2.48 |
| claude-haiku-4-5 | 30% | $2.46 | 83% | $3.07 |
| openai-gpt-5.6-terra | 43% | $3.94 | 73% | $4.68 |
| claude-sonnet-4-5 | 47% | $7.86 | 73% | $8.76 |

The gpt-oss-20b optimized marker is drawn underneath the gemma-4-26b-a4b marker, so its position is inferred from its arrow shaft rather than read directly. Below about $0.50 the markers are only a few pixels apart, so those figures carry perhaps 10 percent relative error; the four models above $2 are precise.

*Dumbbell chart comparing default-prompt and optimized-prompt consistency for eleven models over ten runs. Every optimized prompt exceeds 90 percent consistency, and the all-model average rises by 30.6 percentage points.*
![[sutro-gepa-subjectivity-03.png]]

### What the numbers support at N=30

| Comparison | Counts | Fisher exact p |
| --- | --- | --- |
| gpt-oss-120b vs claude-sonnet-4-5 | 23/30 vs 22/30 | 1.000 |
| GPT-5.6 Luna vs gpt-oss-120b | 27/30 vs 23/30 | 0.299 |
| GPT-5.6 Luna vs claude-sonnet-4-5 | 27/30 vs 22/30 | 0.181 |
| claude-haiku-4-5 vs claude-sonnet-4-5 | 25/30 vs 22/30 | 0.532 |

Clopper-Pearson 95 percent intervals: 27/30 is [73.5, 97.9], 25/30 is [65.3, 94.4], 23/30 is [57.7, 90.1], 22/30 is [54.1, 87.7]. Every optimized model's interval overlaps every other's. The claim the data does support is the one the post leads with, that optimization moved every model a long way from a broken baseline, and that after it the cheap models are in the same band as the expensive ones.

## Cost and Model Choice

The post's own framing is that serving cost is dominated by which model you pick once prompts are adapted, not by prompt-length overhead, and the transcription supports that: the prompt-length penalty moves each model a little to the right, while switching from Claude Sonnet 4.5 to GPT-5.6 Luna moves you 17x left at equal or better accuracy.

The stated prompt-length penalty is 15.4 percent higher cost per lead on average. The per-model dollar shifts I read off the scatter are larger than that for the cheapest models, roughly 2 percent for Gemini 3.5 Flash up to around 40 percent for the small open-weight models. Given the pixel precision at the low end this is a soft observation rather than a contradiction, but it suggests the 15.4 percent figure is an average over a different basis, most likely tokens rather than dollars. The post notes the extra context is often cacheable.

## Why Not the Alternatives

The post rules out three alternatives without running any of them:

- **Manual prompt engineering.** Rejected on cost, not on outcome: gathering hard samples by hand, building tooling to track quality per iteration, reading failed cases and appending rules, then repeating for every candidate model. This is the load-bearing omission, since it is the only baseline that would isolate the optimizer's contribution.
- **Model-written prompts.** Asking Claude or another auto-grader to populate the annotations "defeats the purpose of learning our subjective rules." This is the strongest of the three arguments and the one that justifies paying for human labels at all.
- **Fine-tuning or reinforcement learning.** Conceded to be powerful given sufficient data and verifiable rewards, but reflective optimization got substantial improvement from 30 annotations with no weight updates, so the AI Function runs on off-the-shelf serverless inference and re-optimizing when new labels arrive is trivial. This is the applied form of the rollout-efficiency argument in [[GEPA prompt optimizer beats reinforcement learning with 35x fewer rollouts by reflecting on natural-language execution traces]], and it echoes how [[Predict-RLM with RLM-GEPA achieves new AppWorld SOTA by optimizing the skill instead of the harness]] and [[predict-RLM uses GEPA to recursively optimize agent skills reaching SpreadsheetBench top-5 as open source]] both buy frontier-tier results by optimizing the prompt artifact rather than the weights.

The thesis section, "Own the eval, then pick the model," is the part worth keeping: build the annotated eval that encodes your judgment first, give every candidate model a chance to adapt to it, and let your own measurement rather than a public benchmark choose the deployment. That is the same order of operations as [[targeted evals shape agent behavior more effectively than large benchmark suites]] and the precondition [[agent skills need eval harnesses not vibe checks to ship reliably]] argues for, and it is the operational form of the ownership argument in [[Harrison Chase argues companies must own their intelligence by controlling the model-harness-context system its governance and the compounding feedback loop]]. [[Quarq Labs frames GEPA and RLM as complementary context layers - GEPA optimizes static prompts before inference while RLM decomposes context at runtime]] places this kind of pre-inference adaptation in the wider stack, and GEPA itself ships inside the optimizer family described in [[DSPy is a framework for programming—not prompting—language models through typed signatures and metric-driven optimizers]].

Two notes on the annotation step itself. [[Nova Escola's lesson-planner evals worked only after error analysis rewrote the rubric - annotators agreed worse than chance until experts defined good]] is the failure mode lurking behind "30 annotations that encode your judgment": annotators can disagree worse than chance until someone defines what good means. [[the Error Discovery skill builds a failure-mode taxonomy while you annotate, using active learning to pick the next traces]] is the same active-learning loop Sutro's platform automates, and [[BARGAIN routes classification to a small model via a confidence threshold calibrated on 500 oracle labels, cutting costs up to 86 percent more than competing cascades]] is the contrast case for how many labels a distribution-free guarantee actually costs: 500, not 30.

## Limitations

The post's Limitations section, verbatim and complete:

> - Selecting and maintaining hard, representative annotation sets remains the main bottleneck (see above). That is the workflow [Sutro](https://sutro.sh/) is built around.
> - Reflective optimizers like GEPA still need good scorers. Sometimes a simple label match is enough; other times you need meta-judges or richer objectives.

Both are honest and both are narrow. Neither mentions the 30-item eval set, the absence of a hand-tuned baseline, or calibration.

## The Jev Bridge

The post's own "Related: aligning structured judges" section, verbatim:

> A related line of work applies the same subjectivity-gap idea to structured judgment models (for example TypeSafe's Jev): align the judge to human labels with reflective optimization rather than treating zero-shot judgment as fixed. See [sutro-sh/jev-align](https://github.com/sutro-sh/jev-align) for an open example of that loop.

This is the same author pointing at his own adjacent work, and it makes the two runs directly comparable. [[jev-align]] rewrites Jev's decision criteria; this post rewrites an LLM's system prompt. The protocols differ sharply:

| | This post (2026-09-17) | [[jev-align]] demo (2026-09-19) | Paikray (2026-09-20) |
| --- | --- | --- | --- |
| Labels for optimization | 30 human annotations | 5 per round | 100 train |
| Validation split | none | none | 100 |
| Held-out test | 30 | none | 300 fresh |
| Primary metric | label-match accuracy | batch-global F1 | Brier |
| Calibration reported | no | no | yes, ECE and Brier |
| Candidate frozen before test | not stated | n/a | yes, SHA-256 and timestamp |
| Models | eleven | jev-1.13.0 | jev-1.13.0 |

So: this study is a clear methodological upgrade on Sutro's own September demo, which had no held-out set by construction and reported "Latest fit 1.000 (training labels)". It remains well below the bar [[Praneeth Paikray measures Jev's calibration for the first time - ECE 0.173 and Brier 0.156 lose to a TF-IDF baseline, and GEPA nearly halves the probability error]] set three days later. Neither Sutro run reports calibration, which matters more here than it looks: a three-way fit score that feeds a routing or prioritization decision needs to be right about its own confidence, and nothing in this post measures that. [[moc - Jev]] holds the rest of that cluster, including [[TypeSafe's Jev trades string generation for parallel-sampled typed decisions with calibrated probabilities at $0.042 per MTok - the 193x and 444x claims come from four self-built workflow evals]].

The judge-alignment move itself is not unique to Sutro. [[Databricks coSTAR closes the agent testing gap with coupled judge-alignment and agent-refinement loops]] aligns a judge to a handful of human labels on subjective quality in the same way, and [[LangChain and Fireworks fine-tune Qwen as a 100x cheaper trace judge that beats frontier models on unseen perceived-error domains]] reaches the "small adapted model beats frontier" conclusion by fine-tuning instead of prompt optimization. [[Databricks Genie pushes data agents past coding-agent baselines via specialized knowledge search, parallel thinking, and multi-LLM design]] applies GEPA per pipeline stage rather than per model.

## The Post and Replies

Seth Kimmel, founder of Sutro, announced the post on X on 2026-09-23 at 21:43 UTC. At capture it had 35 likes, 6 reposts and 2 replies.

The tweet restates the blog's numbers in units the blog does not use. It says accuracy improved "by +43%" and consistency "by +31%" where the blog reports +42.9 and +30.6 percentage **points**. Those are not the same claim: going from 35.2 to 78.1 percent accuracy is +42.9 points but a +122 percent relative increase. The tweet also says costs were cut "by ~5x", which corresponds to the blog's "79% cheaper at peak accuracy", since 1/(1 - 0.79) is about 4.8x. The unit slip runs in the conservative direction for cost and the flattering direction for accuracy.

The two replies could not be captured. A single `bird replies --all` attempt returned no output and was not retried.

## Links

- Blog post: https://gepa-ai.github.io/gepa/blog/2026/09/17/bridging-the-subjectivity-gap/
- Announcement: https://x.com/sethkimmel3/status/2102876652820930944
- GEPA: https://gepa-ai.github.io/gepa/
- GEPA `optimize_anything`: https://gepa-ai.github.io/gepa/api/optimize_anything/optimize_anything/
- sutro-sh/jev-align: https://github.com/sutro-sh/jev-align
- Sutro: https://sutro.sh/
- Contact for the guest post: team@sutro.sh
- GEPA community Slack: https://join.slack.com/t/gepa-ai/shared_invite/zt-3o352xhyf-QZDfwmMpiQjsvoSYo7M1_w

## Original Content

### The announcement post

> **@sethkimmel3 (Seth Kimmel)** - Founder @sutro_sh
> Wed Sep 23 21:43:58 +0000 2026 - 35 likes, 6 retweets, 2 replies
> https://x.com/sethkimmel3/status/2102876652820930944
>
> GEPA is an incredible tool for optimizing AI decision models on subjective tasks.
>
> Using just 30 annotations, we improved a lead scorer's average accuracy by +43%, answer consistency by +31%, and cut frontier-grade inference costs by ~5x.
>
> And the best performing models were far from the most "generally" intelligent on public benchmarks.
>
> https://t.co/cafoHQvYyn

Replies: 2 at capture, not retrieved.

### The blog post

> [!quote]- Source Material - "Bridging the Subjectivity Gap: How Automated Prompt Optimization Helps Teams Build Expert-Aligned AI Functions", Seth Kimmel / Sutro Team, GEPA Community Blog, 2026-09-17 (complete, verbatim)
> Title: GEPA: Bridging the Subjectivity Gap: How Automated Prompt Optimization Helps Teams Build Expert-Aligned AI Functions
>
> URL Source: https://gepa-ai.github.io/gepa/blog/2026/09/17/bridging-the-subjectivity-gap/
>
> Markdown Content:
> ---
> description: A case study by Sutro showing how automated prompt optimization aligns repeated AI decisions with organization-specific judgment using only 30 annotations.
> title: GEPA: Bridging the Subjectivity Gap: How Automated Prompt Optimization Helps Teams Build Expert-Aligned AI Functions
> image: https://gepa-ai.github.io/gepa/blog/2026-09-17-bridging-the-subjectivity-gap/images/accuracy-lift.png
> ---
>
> <!doctype html>
>
> [Skip to content ](#bridging-the-subjectivity-gap-how-automated-prompt-optimization-helps-teams-build-expert-aligned-ai-functions)
>
> * [ Becoming model-agnostic ](#becoming-model-agnostic)
> * [ Alternatives ](#alternatives)
> * [ Own the eval, then pick the model ](#own-the-eval-then-pick-the-model)
> * [ Limitations ](#limitations)
> * [ Related: aligning structured judges ](#related-aligning-structured-judges)
> * [ Reach out ](#reach-out)
> * [ Appendix: per-model results ](#appendix-per-model-results)
> * [ Confidence-Aware Prompt Optimization for LLM Classification ](../../../03/17/confidence-adapter-benchmark/)
> * Archive
> * [ Guides ](../../../../../guides/)
> * [ Tutorials ](../../../../../tutorials/)
> * [ API Reference ](../../../../../api/)
> * GEPA Engine
> * Core
> * Callbacks
> * Stop Conditions
> * Adapters
> * [ Proposers ](../../../../../api/proposers/)
> * Logging
> * Strategies
>
> * [ Becoming model-agnostic ](#becoming-model-agnostic)
> * [ Alternatives ](#alternatives)
> * [ Own the eval, then pick the model ](#own-the-eval-then-pick-the-model)
> * [ Limitations ](#limitations)
> * [ Related: aligning structured judges ](#related-aligning-structured-judges)
> * [ Reach out ](#reach-out)
> * [ Appendix: per-model results ](#appendix-per-model-results)
>
> # Bridging the Subjectivity Gap: How Automated Prompt Optimization Helps Teams Build Expert-Aligned AI Functions[¶](#bridging-the-subjectivity-gap-how-automated-prompt-optimization-helps-teams-build-expert-aligned-ai-functions "Permanent link")
>
> **30** **annotations**
>
> **+42.9pp** **average accuracy increase**
>
> **+30.6pp** **average consistency increase**
>
> **79%** **cheaper at peak accuracy**
>
> Most applied AI organizations build systems for recurring tasks, often taking the form of scorers, judges, classifiers, summarizers, matchers, and more. These tasks are typically subjective in nature, and the goal is to align the judgment of a model with that of a domain expert.
>
> While foundation models have a lot of general world knowledge, they don't know how _your organization_ wants a particular decision made. That gap between general intelligence and organization-specific judgment is the **subjectivity gap**.
>
> We refer to models that make repeated decisions as **AI Functions**. They make up a less-visible category of intelligence relative to agentic coding, world models, and robotics - but are perhaps just as important, if not more so.
>
>
> *A two-axis diagram categorizing AI tasks by how often they repeat and whether correctness is objective or organization-specific. AI Functions, such as judging whether a company is a good lead, occupy the highly repeated and organization-specific quadrant.*
> ![[sutro-gepa-subjectivity-01.png]]
>
> AI Functions are repeated tasks whose correct output depends on organization-specific judgment rather than a universal answer.
>
> Building AI Functions is easy, but calibrating them to your judgment remains difficult. Common options include hand-tuning prompts, having a coding agent scan a dataset and write a prompt that encodes its own judgment, or collecting labeled data and fine-tuning your own model.
>
> Reflective prompt optimization is a better fit for this setting, for two reasons:
>
> * **It works well in sparse-data environments.** You only need to capture enough representative samples to demonstrate the general decision procedure, not thousands of "easy" cases that are already in-distribution for a foundation model.
> * **Modern foundation models are adept at instruction following.** They can follow a well-defined, in-context decision policy. Instead of encoding that policy in model weights through fine-tuning or reinforcement learning, reflective optimization can encode it in context - through prompts and, optionally, tools - so the resulting AI Function can run on off-the-shelf inference.
>
> It's like teaching a new employee or intern how work gets done at your company. If you can give them the right context, instructions, and a handful of tricky examples plus their solutions, they can be surprisingly effective at carrying out specific organizational tasks right out of the gate.
>
> For this work we used [GEPA](https://gepa-ai.github.io/gepa/), an open-source reflective optimizer whose flexibility, speed, and abstractions such as [_optimize\_anything_](https://gepa-ai.github.io/gepa/api/optimize%5Fanything/optimize%5Fanything/) make it practical to adapt to new scenarios.
>
> ## A simple demonstration[¶](#a-simple-demonstration "Permanent link")
>
> The loop is: build a reference set that encodes _your_ judgment, evaluate models against it, then optimize prompts so each model adapts to those labels. The hard part is the first step—finding cases that are both difficult and representative enough to teach the decision policy. Easy examples are already in-distribution for frontier models; they do not surface the subjectivity gap. In this study, the Sutro platform materializes a stream of hard lead-scoring cases for annotation; we used two held-out sets of 30 labels each (one for eval, one for GEPA).[1](#fn:hard-cases)
>
> We started from a short prompt that briefly described what Sutro does and asked models to classify leads as _strong_, _medium_, or _weak_ fits, then evaluated eleven frontier models on the eval set. Separately, GEPA optimized each model's system prompt against the training set. Results below are plotted against extrapolated cost to process 1,000 records.
>
>
> *Scatter plot of held-out lead-scoring accuracy against estimated inference cost for eleven models. Arrows connect each model's default-prompt accuracy to its optimized-prompt accuracy, showing gains of 20 to 73 percentage points.*
> ![[sutro-gepa-subjectivity-02.png]]
>
> GEPA improved held-out accuracy for every model. The chart plots default and optimized prompts against the estimated inference cost per 1,000 records.
>
>
> *Dumbbell chart comparing default-prompt and optimized-prompt consistency for eleven models over ten runs. Every optimized prompt exceeds 90 percent consistency, and the all-model average rises by 30.6 percentage points.*
> ![[sutro-gepa-subjectivity-03.png]]
>
> Optimization also made model judgments substantially more repeatable. Every model exceeded 90% consistency after optimization, measured as modal answer rate over ten runs.
>
> Every model gained accuracy (mean **+42.9pp**); several open-weight models matched or beat larger proprietary ones after optimization. Consistency, measured as modal answer rate over ten runs, rose above **90%** for all eleven. Per-model numbers are in the [Appendix](#appendix-per-model-results).
>
> ### Cost[¶](#cost "Permanent link")
>
> Optimized prompts averaged **15.4%** higher cost per lead (longer context). After adaptation, though, Nemotron 3 Super and GPT 5.6 Luna hit the study's peak accuracy (**90%**) at **54%** and **79%** lower cost than Gemini 3.5 Flash (optimized peak **77%**). Serving cost is dominated by which model you pick once prompts are adapted—not by the modest prompt-length overhead (often cacheable).
>
> ## Becoming model-agnostic[¶](#becoming-model-agnostic "Permanent link")
>
> It's worth reiterating that we treated this task as model-agnostic. We created an annotation set of hard cases, gave each model the opportunity to adapt to the task with reflective optimization, and then let our own evaluation tell us which models were best suited for the job. We used our own data, representing our own decision criteria, to make an informed choice about which model to deploy.
>
> This becomes particularly important when there are real deployment constraints. If a team needs to use an open-weight model for security reasons or stay below a particular inference cost, a task-specific evaluation like this can show which models actually satisfy those constraints **after adaptation**, rather than forcing the team to infer suitability from general-purpose benchmarks.
>
> ## Alternatives[¶](#alternatives "Permanent link")
>
> **Manual prompt engineering.** If we were to do the same exercise with manual prompt engineering, it would require the time-intensive process of:
>
> * Gathering hard and representative samples by hand and setting up tooling to track performance quality on each iteration.
> * Manually looking for error modes in failed cases and appending them as new rules to the prompt. This could take hours, days, or weeks, depending on quality needs.
> * Repeating this for every model we want to test - or hoping a single prompt generalizes well to all of them.
>
> **Model-written prompts.** We could ask Claude or another auto-grader to populate our annotations instead of humans, but this defeats the purpose of learning our subjective rules.
>
> **Fine-tuning or reinforcement learning.** Weight-based adaptation can be powerful, particularly when sufficient training data and verifiable rewards are available. For this task, however, reflective optimization produced substantial improvement from only 30 annotations and required no weight updates.
>
> In our case, 30 annotations earned us an average of **42.9** percentage points of task accuracy.
>
> Because reflective optimization doesn't require weight updates, it's easy to run AI Functions using off-the-shelf, serverless inference providers. It also becomes trivial to re-optimize whenever labeled data arrives.
>
> ## Own the eval, then pick the model[¶](#own-the-eval-then-pick-the-model "Permanent link")
>
> As more public benchmarks become saturated and the frontier landscape fragments, more applied AI teams are asking:
>
> * Is this model performant on _our task_, not just a public benchmark?
> * How can we have greater sovereignty over the models that run _our tasks_ on _our data_?
> * How can we become _model-agnostic_ and adapt our tasks to the best model for the job?
>
> We used GEPA to answer those questions for our lead scorer. Many enterprise tasks look like this: the last mile is subjective judgment.
>
> Reflective optimization is also a way to lift open-weight models to or above proprietary ones on a given task, without training custom weights. As more models become available, cheap, inspectable adaptation starts to matter alongside fine-tuning and RL.
>
> ## Limitations[¶](#limitations "Permanent link")
>
> * Selecting and maintaining hard, representative annotation sets remains the main bottleneck (see above). That is the workflow [Sutro](https://sutro.sh/) is built around.
> * Reflective optimizers like GEPA still need good scorers. Sometimes a simple label match is enough; other times you need meta-judges or richer objectives.
>
> ## Related: aligning structured judges[¶](#related-aligning-structured-judges "Permanent link")
>
> A related line of work applies the same subjectivity-gap idea to structured judgment models (for example TypeSafe's Jev): align the judge to human labels with reflective optimization rather than treating zero-shot judgment as fixed. See [sutro-sh/jev-align](https://github.com/sutro-sh/jev-align) for an open example of that loop.
>
> ## Reach out[¶](#reach-out "Permanent link")
>
> Questions about this guest post are welcome at [team@sutro.sh](mailto:team@sutro.sh). For GEPA itself, join the community on [Slack](https://join.slack.com/t/gepa-ai/shared%5Finvite/zt-3o352xhyf-QZDfwmMpiQjsvoSYo7M1%5Fw).
>
> ## Appendix: per-model results[¶](#appendix-per-model-results "Permanent link")
>
> Held-out accuracy and consistency for each of the eleven models. Consistency is the modal answer rate over ten independent runs with the same prompt.
>
> **Accuracy**
>
> | Model                    | Default prompt | Optimized prompt | Gain      |
> | ------------------------ | -------------- | ---------------- | --------- |
> | **gpt-oss-120b**         | 23%            | 77%              | +54pp     |
> | **gpt-oss-20b**          | 20%            | 73%              | +53pp     |
> | **nemotron-3-nano**      | 0%             | 73%              | **+73pp** |
> | **nemotron-3-super**     | 37%            | **90%**          | +53pp     |
> | **claude-haiku-4-5**     | 30%            | 83%              | +53pp     |
> | **claude-sonnet-4-5**    | 47%            | 73%              | +26pp     |
> | **gemini-3.5-flash**     | **57%**        | 77%              | +20pp     |
> | **gemma-4-26b-a4b**      | 43%            | 73%              | +30pp     |
> | **gemma-4-31b**          | 30%            | 77%              | +47pp     |
> | **openai-gpt-5.6-luna**  | **57%**        | **90%**          | +33pp     |
> | **openai-gpt-5.6-terra** | 43%            | 73%              | +30pp     |
>
> **Consistency across 10 runs**
>
> | Model                    | Default prompt | Optimized prompt | Gain      |
> | ------------------------ | -------------- | ---------------- | --------- |
> | **gpt-oss-120b**         | 53%            | 93%              | +40pp     |
> | **gpt-oss-20b**          | 41%            | 91%              | +50pp     |
> | **nemotron-3-nano**      | 35%            | 92%              | **+57pp** |
> | **nemotron-3-super**     | 60%            | 91%              | +31pp     |
> | **claude-haiku-4-5**     | 62%            | 92%              | +30pp     |
> | **claude-sonnet-4-5**    | 65%            | 95%              | +30pp     |
> | **gemini-3.5-flash**     | 77%            | **97%**          | +20pp     |
> | **gemma-4-26b-a4b**      | 80%            | 94%              | +14pp     |
> | **gemma-4-31b**          | 59%            | 95%              | +36pp     |
> | **openai-gpt-5.6-luna**  | **91%**        | **97%**          | +6pp      |
> | **openai-gpt-5.6-terra** | 72%            | 95%              | +23pp     |
>
> ---
>
> 1. Sutro's platform materializes hard examples for annotation and optimization. Curating that stream—not writing the starting prompt—is the scarce step. [↩](#fnref:hard-cases "Jump back to footnote 1 in the text")
>
> Back to top
>
> ```json
> {
>   "@context": "https://schema.org",
>   "@type": ["BlogPosting", "Article"],
>   "headline": "GEPA: Bridging the Subjectivity Gap: How Automated Prompt Optimization Helps Teams Build Expert-Aligned AI Functions",
>   "url": "https://gepa-ai.github.io/gepa/blog/2026/09/17/bridging-the-subjectivity-gap/",
>   "description": "A case study by Sutro showing how automated prompt optimization aligns repeated AI decisions with organization-specific judgment using only 30 annotations.",
>   "image": "https://gepa-ai.github.io/gepa/blog/2026-09-17-bridging-the-subjectivity-gap/images/accuracy-lift.png",
>   "datePublished": "2026-09-17T00:00:00+00:00",
>   "dateModified": "2026-09-17T00:00:00+00:00",
>
>   "publisher": {
>     "@type": "Organization",
>     "name": "GEPA",
>     "url": "https://gepa-ai.github.io/gepa/",
>     "logo": {
>       "@type": "ImageObject",
>       "url": "https://gepa-ai.github.io/gepa/static/img/gepa_logo.png"
>     }
>   },
>   "mainEntityOfPage": {
>     "@type": "WebPage",
>     "@id": "https://gepa-ai.github.io/gepa/blog/2026/09/17/bridging-the-subjectivity-gap/"
>   }
> }
> ```
>
