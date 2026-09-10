---
created: 2026-09-08
description: Part two of Daniel Ching's series written after four months at Datacurve during the DeepSWE release - novelty alone gives any environment minimal training value, but real construction starts from having seen enough model behaviour to recognise a consistent failure mode; he gives five ex ante task-design metrics drawn from DeepSWE (prompt-verifier bijectivity, prompt realism, task realism, graded rather than binary reward, vertical constraint), an ex post rollout-analysis loop that treats the verifier as a binary classifier with measurable false-positive and false-negative rates, and defines eval-quality data as the same bar plus extreme expert consensus.
source: https://x.com/danielchingwq/status/2097361993120227640
type: framework
---

## Key Takeaways

- **The reusable artifact is the five-part ex ante checklist, drawn from DeepSWE's task design — reproduced here in full because the list *is* the piece.** (1) **Prompt-verifier bijectivity**: "does the prompt and verifier map one-to-one? Does the task test exactly what the prompt asks, without hidden assumptions? Put simply: does the grading by the verifier actually match the task?" (2) **Prompt realism**: "is the prompt unambiguous and written naturally, as a practitioner in the field might frame it?" (3) **Task realism**: "is this a task that a practitioner in the field might actually complete?" (4) **Graded reward**: "could the agent receive graded rewards between 0 and 1, rather than a purely binary score?" (5) **Vertical constraint**: does the subdomain actually constrain what a valid task and evaluation look like — "if domain-specific terminology and artifacts were replaced with generic equivalents, would the agent still use essentially the same reasoning and implementation approach? If so, the task may not meaningfully test the claimed vertical." The graded-reward criterion is the same shaping lever [[Harvey's Tenet post-trains Kimi K3 with GSPO in rubric-graded legal environments, doubling LAB hold-out completions while co-optimizing cost via reward shaping]] uses in production, and criterion (1) is the failure [[Phoebe Yao argues verifier engineering is the moat in RL post-training because verifiability bounds learnability]] argues bounds what a model can learn at all.

- **Bijectivity is not an abstraction, and the vault holds a measured instance of it breaking.** [[Mercor's SkyRL recipe post-trains a 397B on 1928 expert tasks for 70 percent relative Pass@1 - and spends Steps 1-3 de-risking before any real compute]] ran a deliberate 32-task overfitting probe; the run's *failure to overfit* is what exposed a low-fidelity file-diff verifier — a task the model could solve while the grader said otherwise. That is Ching's thesis demonstrated with compute rather than asserted: the environment was wrong in exactly the prompt-verifier direction, and only an empirical probe surfaced it. Ching's own version of the same instinct is his split between ex ante and ex post quality control — "task design and review provide an ex ante quality filter... But inspection alone cannot establish that an environment behaves as intended once an agent begins interacting with it."

- **The quality bar is defined against a baseline he explicitly calls low-hanging fruit, which sharpens the claim.** Any data with sufficient novelty — a blog post past a model's cutoff, repackaged into a Prime Intellect environment — "has at least some (however minimal) training value." The real bar is different: "if one were to create an environment from scratch (not a trivial task) they would presumably begin with some prior intuition about where language agents still fail. One has to have seen enough model behavior to recognize that agents consistently struggle with some task and then turn that failure mode into an environment." That is a claim about *who* can build good environments — it requires accumulated observation of model behaviour, not a corpus and a Dockerfile. It is the constructive counterpart to [[Charlie O'Neill's LONG REAL YOURS thesis - horizon length is the only thing RL generalises, and what you distil from matters more than how well you distil]], which from inside the same market calls most RL-env startups "Goodhart machines... apparatus for converting conviction into tonnage" — the polemical version of the argument Ching makes procedurally, and the two agree on the diagnosis while disagreeing on whether the procedure fixes it.

- **Discriminative power is the ex post criterion worth stealing: solvable and correctly graded is the floor, separating model tiers is the bar.** "Does performance meaningfully distinguish agents of differing capabilities, rather than producing pass rates that collapse near zero or one across all of them? Is there a clear step difference between Fable-class and Opus-class models?" Aggregate pass rates give the first view; the trajectories explain why. This is the same band-gating [[Prime Intellect general-agent self-evolves a tool-use corpus through a synthesizer-solver game gated on empirical pass-rate bands]] automates and the edge-of-ability synthesis in [[AgentFrontier synthesizes training data at the boundary of what LLMs can and cannot do]], and it is why [[benchmarks are measurement instruments not question collections - regulargio's first-principles guide to claims, graders, coverage, and uncertainty]] treats a saturated benchmark as a broken instrument rather than a solved problem.

- **Treating the verifier as a binary classifier is the most concrete methodological move in the piece.** Following METR's SWE-bench false-negative work, take the verifier and its task as a classifier over the corpus, build a confusion matrix, and estimate false-positive and false-negative rates — a number, not an intuition. Around it sits a four-question failure-analysis loop borrowed from DeepSWE's qualitative analysis: where did the agent fail, was the failure legitimate, how should failure categories be classified, and can the environment reproduce them across runs. Post-run analysis then "should feed back into upstream environment construction," which at corpus scale yields global pass and failure rates, recurring failure modes, and representative traces. The tooling shape for exactly this loop is [[LangSmith Engine turns production agent traces into issues evaluators and regression examples by separating screening from investigation]] and [[LangChain's Eval Engineering Skill builds Harbor-format evals from repo context and agent traces by interviewing the user]]; the grader-mix version of the same question is [[anthropic recommends combining deterministic graders model judges and human review for agent evals]]; the rubric-granularity evidence is [[LLM Data Company experiments show explicit rubric criteria let gpt-oss-120b match Opus 4.7 at 100x lower cost and full-rubric grading beats per-criterion across every model]]; and the reason error analysis comes before infrastructure is [[agent eval readiness starts with error analysis and simple end-to-end tests not sophisticated infrastructure]].

- **The strongest normative claim is anti-delegation, and Ching draws the line at his own agents.** Spinning up subagents to classify trajectories is "the most efficient but lossy route," valid only if the classification you supplied is defensible, or if you trust the agent to infer categories you never specified. His conclusion: "I don't think there is a substitute for sitting down and scrutinizing individual datapoints," and expert opinion on data exists only when "I – not my agent – have examined the datapoints myself." Four questions define it: what good data in the domain looks like and whether you have any, what bad data looks like and how often it occurs, whether you have curated `n` known-good ground-truth samples and can say what makes them good, and whether your intuition on each new environment survives cross-examination by other reviewers. [[Nova Escola's lesson-planner evals worked only after error analysis rewrote the rubric - annotators agreed worse than chance until experts defined good]] is what that costs when skipped — annotators agreeing worse than chance until domain experts defined the target.

- **Eval-quality data is defined as training quality plus extreme consensus, and the definition is a thought experiment rather than a measurement.** "If I gave the same datapoint to the top ~10-20 experts in a subfield and a fixed amount of time to examine it, an eval-quality datapoint should be distinctly recognizable as a strong assessment of their abilities" — those experts should independently reach roughly the same judgement, and since the probability of unanimity falls as the group grows, consensus that *survives* scaling is the stronger evidence. Eval quality is thus a strict superset of training quality: everything ex ante and ex post, plus agreement. Both are ultimately verification: "if eval-quality represents the upper bound of what a datapoint can be, then the natural goal for data-producing teams is to find ways of reaching that bar repeatedly and at scale."

- **Read this as a practitioner's first-hand account with a conflict on the page, not as a study.** There are no experiments and no measurements of Ching's own — every metric is a criterion to apply, not a result, and the only numbers in the piece are the hypothetical "~10-20 experts" and the 0-to-1 reward range. He wrote it after four months at Datacurve, one of the vendors in the market he is grading, drawing on DeepSWE's task design; that is the source of the specificity and also the reason the checklist should be read as vendor-side craft knowledge rather than an independent standard. Part one, [[Daniel Ching's On Data I argues the post-training datapoint has become an executable environment not a corpus row]], sets up the object being graded; part three is promised on what this means for data vendors and the market's structure — a market mapped in [[data is a great place to start an AI company and a dangerous place to stop - Etna Labs maps the training-signal supplier market]], historically situated in [[Sergio Paniego traces RL environments from OpenAI Universe to OpenEnv - the idea barely changed while five missing pieces arrived separately]], with the engineering roadmap in [[RL environments are the new unit of progress in agentic AI training]], the harness-side timeout result in [[Prime Intellect's fine-tune-last doctrine - 5x task timeouts lifted Terminal-Bench 14.7 points with no model change]], and the reward-gaming detection in [[invariance-based stress tests detect proxy gaming by separating exploitable sensitivity from genuine improvement]].

## External Resources

- [Part I: On Data, I: When Data Becomes an Environment](https://x.com/danielchingwq/status/2095920878907543621) — the previous piece, on why RL environments are valuable
- [DeepSWE](http://deepswe.datacurve.ai/) — the Datacurve project the task-design metrics are drawn from; its [qualitative analysis section](https://deepswe.datacurve.ai/blog/deepswe#qualitative-analysis) is the model for the failure-analysis questions
- [Prime Intellect Environments Hub](https://app.primeintellect.ai/dashboard/environments?ex_sort=by_sections) — where novel content gets repackaged into environments
- [METR: many SWE-bench passing PRs would not be merged into main](https://metr.org/notes/2026-03-10-many-swe-bench-passing-prs-would-not-be-merged-into-main/#appendix-a3-false-negative-correction) — the false-negative correction that motivates treating the verifier as a binary classifier
- [Casper Hansen on graded rewards between 0 and 1](https://x.com/casper_hansen_/status/2092918283603214698)
- [Daniel Rupawalla on the nuance in "properly"](https://x.com/danielrupawalla/status/2087631885669478717?s=20)
- Cross-posted at [danielcwq.com/posts/data-learning-2](https://www.danielcwq.com/posts/data-learning-2)

## Original Content

Source: [On Data, II: Quality is a Verification Problem](https://x.com/danielchingwq/status/2097361993120227640) — X Article by @danielchingwq (Daniel Ching), 8 Sep 2026. 28 likes, 2 retweets, 2 replies.

> [!quote]- On Data, II: Quality is a Verification Problem — full X Article text
>
> @danielchingwq (Daniel Ching):
> Article: On Data, II: Quality is a Verification Problem
>
> The [previous piece](https://x.com/danielchingwq/status/2095920878907543621) argued why RL environments are valuable. But that value depends on whether an environment actually produces the specific post-training signal that it claims to. This piece (also cross posted [here](https://www.danielcwq.com/posts/data-learning-2))  aims to answer the question: what does a good environment look like?
>
> ## Defining Quality
>
> How, then, should we define quality for RL environments? I find it useful to distinguish between two classifications of data quality; this distinction frames the rest of the piece.
>
> The first classification of data quality would be that of training data. To some extent, any data that is properly curated and packaged for post-training should contain training signal. This is especially true of novel information (for instance, this recently released blog post beyond a model’s post-training cutoff) can be repackaged into [some form of environment](https://app.primeintellect.ai/dashboard/environments?ex_sort=by_sections) from which the model receives reward. Any data with sufficient novelty has at least some (however minimal) training value.
>
> On environment construction
>
> Novelty, however, is the obvious low-hanging fruit. If one were to create an environment from scratch (not a trivial task) they would presumably begin with some prior intuition about where language agents still fail. One has to have seen enough model behavior to recognize that agents consistently struggle with some task and then turn that failure mode into an environment.
>
> Drawing from the task design of [DeepSWE](http://deepswe.datacurve.ai/) and my experience working on similar projects, the following are metrics that I pay particular attention to when assessing an environment:
>
> - Prompt–verifier bijectivity: does the prompt and verifier map one-to-one? Does the task test exactly what the prompt asks, without hidden assumptions? Put simply: does the grading by the verifier actually match the task?
>
> - Prompt realism: is the prompt unambiguous and written naturally, as a practitioner in the field might frame it?
>
> - Task realism: is this a task that a practitioner in the field might actually complete?
>
> - Could the agent receive graded rewards[ between 0 and 1](https://x.com/casper_hansen_/status/2092918283603214698), rather than a purely binary score?
>
> - Beyond these design considerations, what constraints are specific to the vertical? Does the subdomain constrain what a valid task and evaluation can look like? If the terminology changed, would the method the agent applies still be specific to that vertical? If domain-specific terminology and artifacts were replaced with generic equivalents, would the agent still use essentially the same reasoning and implementation approach? If so, the task may not meaningfully test the claimed vertical.
>
> *The task at the centre, with the four assessment dimensions radiating out: prompt realism, task realism, domain specificity, and prompt-to-verifier mapping*
> ![[danielchingwq-227640-001.png]]
>
> At its core, a well designed RL environment that clears the quality bar for training seeks to answer the main question: does this environment properly test an agent’s ability to perform? What counts as “properly”, of course, contains an [incredible amount of nuance](https://x.com/danielrupawalla/status/2087631885669478717?s=20).
>
> On empirical analysis
>
> Task design and review provide an ex ante quality filter. They can catch obvious problems before any rollouts are generated. But inspection alone cannot establish that an environment behaves as intended once an agent begins interacting with it. Quality must therefore also be validated ex post, through empirical analysis of completed rollouts and their outcomes.
>
> *Ex ante quality control (task creation: prompt/verifier, realism, domain specificity) feeds rollouts, which feed ex post quality control (empirical analysis: pass rates, agent trajectories, verifier false positives and false negatives), which informs task creation via failure analysis and repeated occurrences*
> ![[danielchingwq-227640-002.jpg]]
>
> At minimum, this analysis should confirm that the environment is solvable and correctly graded. A higher bar is whether it possesses useful discriminative power: does performance meaningfully distinguish agents of differing capabilities, rather than producing pass rates that collapse near zero or one across all of them? Is there a clear step difference between Fable-class and Opus-class models? Eyeballing aggregate pass rates provide an initial view; studying the underlying trajectories reveals why those differences arise.
>
> A surprising amount of insight can be unlocked by inspecting agent traces. With pass rates in hand, we can ask a (non-exhaustive) list of questions (similar to [failure analysis](https://deepswe.datacurve.ai/blog/deepswe#qualitative-analysis)):
>
> 1. Where did the agent fail?
>
> 2. Was its failure legitimate?
>
> 3. How should these failure categories be classified?
>
> 4. Can the environment reproduce them (failures) across runs?
>
> Having a well thought-out post run analysis on the solver agent’s trajectories should feed back into upstream environment construction.  Repeated trace analysis reveals recurring patterns that can then be prevented. Across a sufficiently large collection, it also provides a corpus-level view of the data, such as understanding global pass and failure rates, recurring failure modes. Representative traces can also reveal the broad shape of the collection.
>
> Individual traces that are representative of agent behavior across the corpus can also be selected.  Classical ML methods can also be applied to verifier design by treating the verifier (and its corresponding task) as a binary classifier and constructing a [confusion matrix across ](https://metr.org/notes/2026-03-10-many-swe-bench-passing-prs-would-not-be-merged-into-main/#appendix-a3-false-negative-correction)the corpus. This makes it possible to estimate false-positive and false-negative rates [1].
>
> Once the collection reaches sufficient scale, there are several ways to approach post-run analysis. The most efficient but lossy route would be to spin up multiple subagents to analyze trajectories and corresponding tasks on a human’s behalf. This can yield useful generalizations, but only under a few assumptions:
>
> 1. That any said classification that you have provided to the agent is defensible: you can justify why a particular datapoint or trajectory belongs in that category.
>
> 2. If no classification is provided, you trust the agent to generalize and infer classifications that were not specified beforehand.
>
> Ultimately, scaling granular analysis across a critical mass of environments is non-trivial. To form a defensible opinion of the data, I don’t think there is a substitute for sitting down and scrutinizing individual datapoints. If the goal is to ultimately justify the value of a curated dataset, the following questions need answers:
>
> 1. What does good data in my specified domain look like? Are there such samples in my collection?
>
> 2. What does bad data in the same domain look like? What characteristics define it? How often does it occur?
>
> 3. Have I curated `n` ground truth samples that I know are good? Why are they good and what makes them good?
>
> 4. Do I have an intuition about each new environment that I examine, and can I defend that intuition coherently under cross-examination against other reviewers or experts who would have examined the same datapoint?
>
> If I can own the judgment of why a datapoint is inherently good or bad, and others reach the same conclusion after applying that level of rigor, then I have developed an expert opinion on that data. But this is conditioned on the fact that I – not my agent – have examined the datapoints myself.
>
> Eval-quality data
>
> This leads me to the second classification of data quality: eval data. Eval data should satisfy all of the above characteristics of both task creation (pre-run) and empirical analysis (post-run). Beyond these principles, however, it pushes the idea of consensus to the extreme.
>
> *Eval-quality data as the outer box: strong expert consensus wrapped around training-quality data, which is ex ante task quality plus ex post empirical validation*
> ![[danielchingwq-227640-003.png]]
>
> Consider the following thought experiment. If I gave the same datapoint to the top ~10-20 experts in a subfield and a fixed amount of time to examine it, an eval-quality datapoint should be distinctly recognizable as a strong assessment of their abilities. In other words, those experts should independently reach roughly the same judgement.
>
> Of course, basic statistical intuition suggests that, as the number of experts increases, the probability of unanimous agreement falls. If consensus persists as the group scales, however, then one has a stronger case that the result is a globally great datapoint.
>
> Ultimately, defining data quality is a problem of verification. If eval-quality represents the upper bound of what a datapoint can be, then the natural goal for data-producing teams is to find ways of reaching that bar repeatedly and at scale. What that means for data vendors (and for the structure of the market around them) is what I’ll focus on in the last piece.
>
> date: Tue Sep 08 16:30:40 +0000 2026
> url: https://x.com/danielchingwq/status/2097361993120227640
> likes: 28  retweets: 2  replies: 2
