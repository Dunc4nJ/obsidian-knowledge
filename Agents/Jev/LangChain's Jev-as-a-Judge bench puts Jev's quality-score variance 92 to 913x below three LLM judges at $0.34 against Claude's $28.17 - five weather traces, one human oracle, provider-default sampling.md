---
created: 2026-09-20
description: LangChain's Daniel Shea and Seán Roche froze five weather-agent traces, had one human reviewer label them, then ran Jev and three LLM judges 100 times each on a continuous quality score and a binary does_pass - Jev matched the oracle on all 500 binary decisions with mean per-case quality variance 92 to 913x below the LLM judges, at $0.00035 and 0.44s per call, but the LLM judges ran on provider-default sampling with no seed and accuracy was never measured on the continuous score.
source: https://x.com/LangChain/status/2101454284927959080
via: https://x.com/sydneyrunkle/status/2101470551340421321
author: Daniel Shea and Seán Roche (LangChain)
published: 2026-09-19
type: knowledge
tags: [jev, evals, llm-as-judge, langchain, langsmith, online-evals, system-one-models, typesafe]
---

# LangChain's Jev-as-a-Judge bench puts Jev's quality-score variance 92 to 913x below three LLM judges at $0.34 against Claude's $28.17 - five weather traces, one human oracle, provider-default sampling

An X Article published 19 September 2026, four days after [[TypeSafe's Jev trades string generation for parallel-sampled typed decisions with calibrated probabilities at $0.042 per MTok - the 193x and 444x claims come from four self-built workflow evals|TypeSafe launched Jev]] and one day after [[LangChain's Sydney Runkle puts Jev inside the agent loop as classifier middleware - ModelRouterMiddleware picks the model from the latest user message and AutoModeMiddleware reproduces closed harnesses' dangerous-action gate|LangChain shipped the langchain-typesafe integration]]. 57 likes, 10 retweets, 16 replies, 3,888 views at capture. This is the first note in the vault where someone outside TypeSafe runs Jev against named LLM judges on a shared task and publishes per-model numbers.

## Key Takeaways

- **This is the first Jev comparison in the vault with a human oracle rather than an LLM reference, and it is five examples.** The ground truth is one human reviewer scoring five frozen weather-agent responses against the eval rubric. Every accuracy figure is agreement with those five labels, replayed 100 times. The article reports it as "all 500 repeated decisions" and "99.8% of decisions", but 100 repetitions of the same five cases do not make 500 independent trials — they measure repeatability twice and correctness once. Claude Sonnet 4.6's 80.0% is the cleanest illustration: its `does_pass` line is perfectly flat across all 100 repetitions, so it is not noisy at all, it simply disagrees with the human on exactly one of the five cases, every single time. That is the failure mode the article itself names ("a judge can still be consistently wrong") and then does not apply to its own accuracy column. [[benchmarks are measurement instruments not question collections - regulargio's first-principles guide to claims, graders, coverage, and uncertainty]] is the vault's standing argument for why the effective N and not the row count governs the uncertainty here, and [[Nova Escola's lesson-planner evals worked only after error analysis rewrote the rubric - annotators agreed worse than chance until experts defined good]] is why a single unreplicated annotator is the weakest part of the design.

- **The 92-913x variance spread runs the wrong way for the headline, and the article is honest about why.** The multiplier is per model, and the ordering is the inverse of accuracy: GPT-5.6 Terra, the second most accurate judge at 99.8%, has the worst variance at 913x, while Claude Sonnet 4.6, the least accurate at 80.0%, has the best of the three at 92x. Low variance is a property of a judge that keeps returning the same number, which a consistently wrong judge does perfectly. The article states this ("Lower variance does not automatically mean higher accuracy") and adds that the experiment "cannot tell us why Jev's scores varied less", calling the result "observational, not evidence that its training objective caused the lower variance". That is more restraint than [[TypeSafe's Jev trades string generation for parallel-sampled typed decisions with calibrated probabilities at $0.042 per MTok - the 193x and 444x claims come from four self-built workflow evals|TypeSafe's own launch numbers]] carry.

- **Accuracy was measured only on the binary signal and variance only on the continuous one, so "accurate and precise" splices two different measurements.** Each judge produced two outputs per run: `quality`, a scalar 0-1, and `does_pass`, binary. The accuracy table compares only `does_pass` to the human oracle. The variance table covers only `quality`. Nobody reports how close Jev's quality score sits to the human reviewer's rubric score, which is the number that would say whether the flat line is flat in the right place. Figure 9 shows Jev's quality pinned near 0.90 while Claude sits near 0.86 and Luna near 0.95 — three different answers to the same question, with no statement of which one the human gave.

- **Against the nearest competitor the cost story is 11%, not 83x.** The $0.34-against-$28.17 headline is Jev versus the most expensive judge tested. Jev cost $0.00035 per call and GPT-5.6 Luna $0.00039 — an 11% gap, for a judge with 96.4% oracle agreement against Jev's 100%. The real separation is latency (0.44s against 2.50s) and the tail: Terra at 8x and Claude at 80x Jev's per-call price. This is the same economic shape as [[LangChain and Fireworks fine-tune Qwen as a 100x cheaper trace judge that beats frontier models on unseen perceived-error domains]] and [[BARGAIN routes classification to a small model via a confidence threshold calibrated on 500 oracle labels, cutting costs up to 86 percent more than competing cascades]], both of which reach a cheap reliable judge without a new model class, and both of which calibrate against more than five labels.

- **Calibration is invoked as the explanation and never measured.** The article's hypothesis for Jev's low variance is that "TypeSafe describes Jev as a decision model trained to return calibrated probabilities" — a quote of the vendor's claim, offered as a candidate cause and immediately disclaimed. There is no Brier score, no reliability curve, no check that a 0.88 from Jev means 88%. That leaves the vault's standing gap exactly where it was: [[Sutro's jev-align uses GEPA to rewrite Jev's decision criteria from five labeled examples - the demo moves labeled-set ambiguity 49.6 points but full-pool certainty only 0.5|jev-align tunes prompt criteria and publishes no calibration metric]], TypeSafe's own jaggedness page says Jev cannot abstain, and [[Daniel Ch's How to master Jev prescribes a 0.85 and 0.55 confidence-gate ladder under an LLM that still writes - the decision-layer architecture is additive but every number and all three charts are TypeSafe's own|Daniel Ch's 0.85 and 0.55 gate ladder]] picks thresholds with no calibration evidence underneath them. A judge whose scores are used as a continuous quality signal needs that curve more than a router does.

- **Every LLM judge ran on provider defaults with no temperature, top-p, seed, or max-tokens set.** The authors disclose this in the Reproducibility section. It is the single largest confound in a variance comparison: the standard mitigation for a non-deterministic judge is temperature 0 and a fixed seed, and it was not applied. Whether the judges ran with reasoning on or off is not stated either. The honest reading is that this measures default-configuration LLM judges against Jev, not the best-case LLM judge, and the 433x and 913x figures would shrink under seeded greedy decoding by an unknown amount.

- **The sharpest reply asks whether the comparison is about model class at all.** @ethereaglehq: "did the LLM judge get a typed schema like Jev, or score free text while Jev returned structured answers? if the cases are yes/no, the repeatability gap might just be the output format". The article never says how the LLM judges' outputs were constrained, and figure 2 draws the LLM judge as text reasoning that is afterwards mapped into a score, which is exactly the step that would introduce parse-level noise. If the judges scored free text while Jev returned a typed value, the experiment compares output formats rather than System One models against autoregressive ones. Nobody from LangChain or TypeSafe answered. The repo would settle it and the article does not.

- **The vendor-adjacency is thorough and mostly disclosed.** LangChain built the target agent with its own Deep Agents, stored the frozen examples in its own LangSmith, ran the LLM judges through its own LangSmith Gateway, published the result four days after shipping a Jev integration, and closed the article with a signup link for a livestream it is co-hosting with TypeSafe three days later. None of that makes the numbers wrong, and the repo is public. It does mean the comparison chose which LLM judges to run, at which settings, on a task LangChain designed. Compare [[Annabell frames TypeSafe's Jev as a savant for eval verdicts and routing - three question types, 255 choices, 10 score levels, and a Noul with no confidence field|the Good Start Labs bench Annabell relays]]: 6,003 rubric checks rather than five, where Jev agreed with Fable 5.1 91.5% of the time at $160 per million answers and DeepSeek V4.1 Flash beat it at 93.5% for $260. The larger bench does not put Jev first on agreement. This one does, on five cases.

- **The article's own description of the three question types has Choice and Noul swapped.** The Choice bullet gives the example "Is the final answer grounded in the retrieved evidence?" returning "a float from 0.0 to 1.0" — that is a Noul. The Noul bullet gives "Which search outcome best describes this run?" returning one of `searched_appropriately`, `searched_unnecessarily`, or `failed_to_search` — that is a Choice. Figure 4 has the primitives right. [[Annabell frames TypeSafe's Jev as a savant for eval verdicts and routing - three question types, 255 choices, 10 score levels, and a Noul with no confidence field|Annabell's note]] is the reliable reference for the primitives and their limits.

## Experimental Design

**Target agent.** A weather agent built with Deep Agents, LangChain's open-source agent harness, with Tavily search. The agent is not the object of study; it exists to produce traces.

**Dataset.** Five weather requests, defined as a LangSmith dataset so every evaluator ran against identical questions and expected behavior.

| Request type | Location | User need |
| --- | --- | --- |
| Current conditions | Seattle | What is the weather right now? |
| Weekend forecast | Austin | What weather should I expect this weekend? |
| Decision support | Dublin | Should I bring an umbrella? |
| Longer-range forecast | Tokyo | What does the extended forecast show? |
| Ambiguous location | Springfield | Handle a request without a uniquely specified place |

**Freezing.** Each request was run once through the agent, and the full output stored as a fixed example in LangSmith. Every judge then scored the same five captured responses. Agent behavior is held constant so that all remaining variation is the judge's.

**Signals.** Two evaluators per run.

| Evaluator | What it measures | Score |
| --- | --- | --- |
| `quality` | A combined score for grounding in the search results, appropriate search behavior, and usefulness of the response | Scalar (0-1) |
| `does_pass` | A simple pass or fail decision | Binary (0,1) |

**Oracle.** One human reviewer labeled each of the five fixed responses against the same rubric. Accuracy is agreement with those labels. The article does not report a second annotator, an agreement statistic, or who the reviewer was.

**Judges and repetitions.** Jev against GPT-5.6 Luna, GPT-5.6 Terra, and Claude Sonnet 4.6, each repeated 100 times per case. That is 5 cases x 100 repetitions = 500 decisions per judge per signal, and 1,000 evaluator calls per judge in total, which is what the total-cost column divides by.

**Settings.** LLM judges ran through LangSmith Gateway with no temperature, top-p, seed, or max tokens set, so provider defaults applied. Jev was accessed through `langchain-typesafe==0.0.1a2`; its service version was not captured in the experiment metadata.

## Results

**Accuracy** — agreement with the human oracle on the binary `does_pass` decision, over 500 repeated decisions each.

| Judge | Human-oracle pass/fail accuracy |
| --- | --- |
| Jev | 100.0% |
| GPT-5.6 Terra | 99.8% |
| GPT-5.6 Luna | 96.4% |
| Claude Sonnet 4.6 | 80.0% |

**Precision** — observed mean per-case variance of the continuous `quality` score across 100 repetitions.

| Evaluator | Mean quality variance | Relative to Jev |
| --- | --- | --- |
| Jev | 0.0000149 | 1x |
| GPT-5.6 Luna | 0.00647 | 433x |
| GPT-5.6 Terra | 0.01364 | 913x |
| Claude Sonnet 4.6 | 0.00137 | 92x |

**Cost and latency** — per evaluator call, and total across the 1,000 calls each judge made.

| Judge | Average cost per call | Average latency | Total evaluator cost |
| --- | --- | --- | --- |
| Jev | $0.00035 | 0.44 s | $0.34 |
| GPT-5.6 Luna | $0.00039 | 2.50 s | $0.39 |
| GPT-5.6 Terra | $0.00289 | 2.83 s | $2.90 |
| Claude Sonnet 4.6 | $0.02811 | 2.16 s | $28.17 |

The bubble chart carries one number the tables do not: Jev's unrounded per-call cost is $0.0003453, against Claude's $0.02811, an 81x spread. Bubble size encodes average total tokens per call, and Claude's is visibly the largest.

**What the oscillation plots actually show.** Two figures plot the mean across the five frozen cases for each of the 100 repetitions, on a shared zoomed y-axis.

- On `quality` (figure 9), Jev is a near-flat line just above 0.87. Luna swings roughly 0.83 to 0.97 with repeated dips. Terra is the noisiest, swinging about 0.77 to 0.97. Claude oscillates in a narrow band around 0.86.
- On `does_pass` (figure 10), Jev is perfectly flat at the 0.8 level and Claude is perfectly flat at the 0.6 level. Terra is flat at 0.8 with a single dip around repetition 31, which is the one flip behind its 99.8%. Luna is the only genuinely unstable one, stepping between 0.6, 0.8, and 1.0 roughly a dozen times.

Claude's perfectly flat but lower line is the whole argument against reading variance as quality. It is the most repeatable LLM judge on the binary signal and the least accurate one.

## What "Online Evals at Scale" Means Here

The article extrapolates to a production agent producing 10,000 traces per day, and defines **signal value** as binary oracle agreement multiplied by binary repeatability, where repeatability is the chance that two independent calls on the same trace return the same verdict.

| Judge | Signal value (accuracy x repeatability) | Daily cost at 10,000 traces | 30-day cost |
| --- | --- | --- | --- |
| Jev | 100.0% | $3.45 | $103.59 |
| GPT-5.6 Luna | 90.1% | $3.91 | $117.24 |
| GPT-5.6 Terra | 99.4% | $28.89 | $866.61 |
| Claude Sonnet 4.6 | 80.0% | $281.14 | $8,434.08 |

Three things about this table. The daily figure is a straight multiply of per-call cost by 10,000 — one judge call per trace, no batching, no caching, no volume pricing, and no rerun for the "repeat judgments when confidence matters" behavior the article recommends elsewhere. The cost of the human labels that made any of these judges trustworthy is not in it, and neither is the judge-alignment work that [[Databricks coSTAR closes the agent testing gap with coupled judge-alignment and agent-refinement loops]] treats as the actual expense of running LLM judges in production. And the signal-value column is displayed next to the cost columns but never multiplied into them, so the table invites a cost-per-unit-signal reading it does not perform: on that reading Luna at $3.91 for 90.1% is within a few percent of Jev, and Terra buys 99.4% for $28.89.

The genuine finding underneath the extrapolation is the one [[the agent improvement loop is traces enriched with evals and human feedback converted into validated fixes]] and [[LangChain's Harrison Chase argues agent observability needs feedback attached to traces to power learning]] both depend on: a judge at a third of a cent per thousand calls changes what fraction of production traces you can afford to score at all. That claim survives the narrowness of the test, because it is a claim about price rather than about accuracy.

## Sydney Runkle's Framing

The user's entry point was Sydney Runkle's quote-tweet, posted 65 minutes after the article, carrying the Jev Judge diagram (figure 3) as its image:

> jev as a Judge proves to be a cheaper and more precise alternative to LLM as a judge for online evals.
>
> great guide from Sean and Daniel on why Jev is great for evals, an experiment vs other LLMs, and how to try this out for your agents!

**"More precise" is the article's own word and it is supported.** The article defines precision explicitly as "whether it produces the same quality score when the agent behavior is unchanged", measures it as observed variance, and Jev wins that by 92x at minimum. Runkle is using the term the authors defined, not overreaching into accuracy.

**"Proves" is doing more work than five examples can bear.** The article's own final key takeaway is "The results are promising, but early. Despite this being a narrow test…", and its closing section says "We still need to see whether the results in this experiment carry over to other agents and production workflows." The quote-tweet drops that hedge. Runkle also writes an earlier [[LangChain's Sydney Runkle puts Jev inside the agent loop as classifier middleware - ModelRouterMiddleware picks the model from the latest user message and AutoModeMiddleware reproduces closed harnesses' dangerous-action gate|LangChain post on the same model]], so this is in-house amplification of in-house work.

**On accuracy, which she does not claim, Jev also came first** — 100.0% against 99.8%, 96.4%, and 80.0%. The gap over the runner-up is one decision in five cases. Nothing in the article separates "Jev is the better judge" from "Jev and Terra both agree with this particular human on these particular five weather answers".

## Replies

16 replies on the host tweet, none on the quote-tweet. Four of them are methodological and worth keeping; the rest are approval, a request for the repo link the article already contains, and one off-topic post. No LangChain or TypeSafe account answered any of the questions below.

- **@ethereaglehq asks the question that could dissolve the whole variance result.** "did the LLM judge get a typed schema like Jev, or score free text while Jev returned structured answers? if the cases are yes/no, the repeatability gap might just be the output format". The article never states how the LLM judges' outputs were constrained — whether they used structured outputs, a parsed scalar from free text, or a tool-call schema — and figure 2 depicts the LLM judge as generating text reasoning that is then mapped into a score. If that mapping is the noisy step, the comparison is structured-output versus text-then-parse rather than System One versus autoregressive. The repo would settle it.

- **@ryanndngg lands independently on the N problem.** "five weather traces is enough to prove the plumbing, not the judge. the real test is adversarial near-misses: right tool, wrong source freshness; correct answer, unsupported evidence; task complete, bad side effect. low variance on easy labels can hide a consistently wrong grader." The suggested case families are the ones the weather dataset does not contain — four of its five rows are straightforward retrieval, with only the ambiguous-Springfield row testing anything adversarial.

- **@johnroodepic names the version-pinning gap the article discloses and does not close.** "Cheap judges get dangerous when the evaluator version isn't pinned to every trace. If the score moves, you need to know whether the agent regressed or the judge changed before that signal touches the feedback loop." The Reproducibility section states outright that "The Jev service version was not available in the experiment metadata", so this run cannot be re-pinned. [[Annabell frames TypeSafe's Jev as a savant for eval verdicts and routing - three question types, 255 choices, 10 score levels, and a Noul with no confidence field|Annabell's Langfuse script pins jev-1.13.0]] for exactly this reason.

- **@dhinnaship_ico asks whether prompt caching is in the cost comparison.** It is not mentioned anywhere in the article. Caching the frozen trace across 100 repetitions would cut the LLM judges' input cost substantially, and the 10,000-traces-per-day extrapolation assumes no caching for anyone.

- **@OMID_0909 extends the point to the evaluated state**: "if the underlying context isn't versioned and traceable, you can have a highly consistent judge evaluating an unreproducible state." Here the state was deliberately frozen in LangSmith, so the criticism lands on production use rather than on this experiment.

Sydney Runkle also replied in-thread with "my fav use case thus far". @KeithZhai credits the paper for scoring latency and cost rather than accuracy alone, @jatingargiitk, @ragzoi and @irastech all volunteer repeatability as the axis that actually bites in production, @Sagarvd01 frames the typed return as the real split, and @bullbear_info offers the one flat contradiction without evidence: "System One models usually struggle with the nuance required for multi-step evaluation benchmarks." @fauxsocialapp asks for the benchmark repo, which is linked in the article's Reproducibility section.

## Related

Jev primary and siblings: [[moc - Jev]], [[TypeSafe's Jev trades string generation for parallel-sampled typed decisions with calibrated probabilities at $0.042 per MTok - the 193x and 444x claims come from four self-built workflow evals]], [[LangChain's Sydney Runkle puts Jev inside the agent loop as classifier middleware - ModelRouterMiddleware picks the model from the latest user message and AutoModeMiddleware reproduces closed harnesses' dangerous-action gate]], [[Annabell frames TypeSafe's Jev as a savant for eval verdicts and routing - three question types, 255 choices, 10 score levels, and a Noul with no confidence field]], [[Sutro's jev-align uses GEPA to rewrite Jev's decision criteria from five labeled examples - the demo moves labeled-set ambiguity 49.6 points but full-pool certainty only 0.5]], [[Featherless's Simple Jev reproduces Jev's API on stock open models by remapping every answer to a single-token letter and softmaxing only those logits - no classifier head, and the code stamps every answer calibrated False]], [[Daniel Ch's How to master Jev prescribes a 0.85 and 0.55 confidence-gate ladder under an LLM that still writes - the decision-layer architecture is additive but every number and all three charts are TypeSafe's own]].

Jev tooling: [[jev-align]], [[pg-jev]], [[jevlike]], [[simple-jev]].

Judges, rubrics, and cost: [[anthropic recommends combining deterministic graders model judges and human review for agent evals]], [[LLM Data Company experiments show explicit rubric criteria let gpt-oss-120b match Opus 4.7 at 100x lower cost and full-rubric grading beats per-criterion across every model]], [[BARGAIN routes classification to a small model via a confidence threshold calibrated on 500 oracle labels, cutting costs up to 86 percent more than competing cascades]], [[LangChain and Fireworks fine-tune Qwen as a 100x cheaper trace judge that beats frontier models on unseen perceived-error domains]], [[LangChain and Harvey show DeepSeek batch verifiers reduce legal agent evaluation costs by three orders of magnitude at acceptable accuracy]], [[Databricks coSTAR closes the agent testing gap with coupled judge-alignment and agent-refinement loops]], [[Nova Escola's lesson-planner evals worked only after error analysis rewrote the rubric - annotators agreed worse than chance until experts defined good]], [[benchmarks are measurement instruments not question collections - regulargio's first-principles guide to claims, graders, coverage, and uncertainty]].

Eval design and the online loop: [[the agent improvement loop is traces enriched with evals and human feedback converted into validated fixes]], [[LangChain's Harrison Chase argues agent observability needs feedback attached to traces to power learning]], [[deep agent evals need bespoke per-datapoint test logic not uniform evaluators]], [[LangSmith Engine turns production agent traces into issues evaluators and regression examples by separating screening from investigation]], [[a working offline eval turns vibes into repeatable measurement in 10 steps]].

## Links

- [Jev-as-a-Judge for Agent Evals](https://x.com/LangChain/status/2101454284927959080) — the X Article, by Daniel Shea and Seán Roche
- [Sydney Runkle's quote-tweet](https://x.com/sydneyrunkle/status/2101470551340421321) — the framing post
- [danielgshea/jev-as-a-judge](https://github.com/danielgshea/jev-as-a-judge) — the experiment repository, linked from the Reproducibility section
- [Introducing System One Models and Jev](https://typesafe.ai/blog/introducing-system-one-models-and-jev) — TypeSafe's launch post
- [TypeSafe state concept docs](https://docs.typesafe.ai/concepts/state) — what a System One model evaluates
- [LangSmith LLM-as-judge docs](https://docs.langchain.com/langsmith/llm-as-judge) — the baseline approach being compared against
- [Deep Agents](https://www.langchain.com/deep-agents) — the harness the target weather agent was built with
- [LangSmith](https://www.langchain.com/langsmith-platform) — where the dataset, fixed examples, and gateway calls lived
- [Building a Harness with Jev livestream](https://events.langchain.com/webinar/building-a-harness-with-jev/) — LangChain and TypeSafe, Tuesday 22 September 2026

Pinned versions from the Reproducibility section: `langchain-typesafe==0.0.1a2`, Deep Agents 0.7.15, LangChain OpenAI 1.6.2, LangSmith 0.12.6, Tavily Python 0.8.3.

## Original Content

> [!quote]- Source Material — "Jev-as-a-Judge for Agent Evals" by Daniel Shea and Seán Roche (LangChain), X Article 2101448785255907328, published 2026-09-19, captured verbatim with all 13 figures at their original positions
> # Jev-as-a-Judge for Agent Evals
>
> *By LangChain (@LangChain), article created 2026-09-19T23:31:59.000Z, tweet https://x.com/LangChain/status/2101454284927959080, article id 2101448785255907328*
>
> *By Daniel Shea and Seán Roche*
>
> Key takeways:
>
> - **Jev is a fundamentally different kind of evaluator.** It returns typed answers directly instead of generating text like an LLM judge.
>
> - **Jev was dramatically more consistent on continuous scoring.** Its quality-score variance was 92–913x lower than GPT-5.6 Luna, Terra, and Claude Sonnet 4.6.
>
> - **Jev was also the fastest and cheapest.** It averaged 0.44s and $0.00035/call ($0.34 total vs. $28.17 for Claude).
>
> - **The results are promising, but early.** Despite this being a narrow test, Jev's performance points to a compelling new direction for agent evals.
>
> Today, agent evals come in two flavors: code-based and LLM-as-judge. Both have their own limitations: code-based evaluators can only be used for a narrow set of problems with set inputs, while LLM judges can be slow, expensive, and unreliable. With the popular release of [TypeSafe AI’s Jev](https://typesafe.ai/blog/introducing-system-one-models-and-jev), we wanted to see whether the “System One” model might be a new third form of agent evaluator, and the impact it could have on agent engineering.
>
> ## What is Jev?
>
> Jev is a new model released by TypeSafe AI. Jev is actually not a traditional LLM; it doesn’t generate text. It’s what the TypeSafe AI team calls a “System One” model:
>
> > 📖 System One models are a class of AI models built to make fast, structured decisions that software can use directly. A System One model evaluates a [**state**](https://docs.typesafe.ai/concepts/state) and returns typed answers and probabilities.
>
> *How an autoregressive LLM and a System One Model (Jev) answer the same question*
> ![[langchain-959080-001.jpg]]
>
> According to TypeSafe AI, this makes Jev faster and cheaper than LLMs, up to **200x faster inference and 400x lower cost** than comparable LLMs on classification tasks.
>
> ## Why might Jev be a good agent evaluator?
>
> Agent evals today are either code-based or LLM-as-a-judge, each with its own set of benefits, limitations, and tradeoffs.
>
> Code-based evaluation has existed for as long as code has. Cheap, quick, and reliable, its main disadvantage is in its narrower abilities. Given a traditional function’s need for set deterministic inputs, its ability to evaluate the stochastic world of agent behavior is limited. For example, while a traditional function *could* evaluate whether an agent called a tool in its first run, it would have a harder time evaluating if the agent then used the tool result to successfully answer the user’s question. In an open-ended task, there can be several valid ways to use the same tool result, so encoding every acceptable answer as deterministic logic quickly runs into the narrow-scope limitation of code-based evaluation.
>
> Enter [LLM-as-a-judge](https://docs.langchain.com/langsmith/llm-as-judge), which uses an LLM to reason through the unstructured input of an agent’s trace and score it. An LLM judge can accept the question, trace, and evidence as unstructured input, then use a prompt to evaluate whether the response addressed the user’s request.
>
> *How an LLM Judge generates structured results for an eval*
> ![[langchain-959080-002.jpg]]
>
> As any agent engineer will attest though, the LLM judge is not a perfect solution. They are inherently non-deterministic systems, which are not a solid foundation for a trustworthy testing apparatus. They are also slower and more expensive to run than traditional code-based evaluation.
>
> Agent evaluation is a decision task: given an agent’s state and behavior, assign a score that provides feedback. Jev is designed for this pattern. It evaluates typed questions against structured state and returns typed answers with probabilities. Autoregressive models, on the other hand, reach a judgment through token-by-token generation. In our experiment, that decision-first design coincided with lower latency, lower cost, and lower variance.
>
> *How a Jev Judge generates results for an eval, note that structured output comes natively to the model*
> ![[langchain-959080-003.jpg]]
>
> Jev supports three types of questions:
>
> *Choice* selects one option and returns probabilities and confidence.
>
> - Example: “Is the final answer grounded in the retrieved evidence?”
>
> - Response: A float from 0.0 to 1.0, where 1.0 means fully grounded
>
> *Score* rates an answer against an ordered rubric and returns probabilities and confidence.
>
> - Example: “How useful is the answer?”
>
> - Response: A rubric score from 1 (unhelpful) to 5 (highly useful), plus probabilities and confidence
>
> *Noul* returns the probability that a yes/no judgment is true.
>
> - Example: “Which search outcome best describes this run?”
>
> - Response: One of searched_appropriately, searched_unnecessarily, or failed_to_search, plus probabilities and confidence
>
> Multiple atomic questions can be evaluated in parallel against the same state.
>
> *The three types of questions Jev can answer and how they could be applied to an eval*
> ![[langchain-959080-004.jpg]]
>
> Comparing judges is difficult when the agent behavior, retrieved data, or trace context changes between runs. [Deep Agents](https://www.langchain.com/deep-agents) and [LangSmith](https://www.langchain.com/langsmith-platform?utm_campaign=evergreen_langsmith_branded_cv&utm_campaign_id=23553472535&utm_ad_group_id=198810166528&utm_ad_id=797108559068&utm_network=g&utm_term=langsmith&utm_campaign=evergreen_evaluation_cv&utm_source=google&utm_medium=cpc&hsa_acc=7906965105&hsa_cam=23553472535&hsa_grp=198810166528&hsa_ad=797108559068&hsa_src=g&hsa_tgt=kwd-2174781825802&hsa_kw=langsmith&hsa_mt=e&hsa_net=adwords&hsa_ver=3&gad_source=1&gad_campaignid=23553472535&gbraid=0AAAAA-PkietYkJqgIHVlwo2UlqyTQ7bGY&gclid=Cj0KCQjw5bjVBhCiARIsAJzMVnS-CMMHOqW_r5uwOa8HniET34GlYQuRJpCxQuzo5bk9U1THPps3chsaApDfEALw_wcB) let us capture a single agent run as a dataset and replay it across each model.
>
> ## Evaluation with Jev
>
> In order to put Jev to the test, we needed an agent to score. We built a target agent with Deep Agents, our open source agent harness. We then defined a test set as a LangSmith dataset so each evaluator ran against the same questions and expected behavior. The test set consists of five weather requests:
>
> *Figure: the five-request test set - Seattle current conditions, Austin weekend forecast, Dublin decision support, Tokyo longer-range forecast, and an ambiguous Springfield.*
> ![[langchain-959080-005.jpg]]
>
> For each example in the dataset, we captured the weather agent’s response and stored the full output as a fixed example in LangSmith. Each judge evaluated the five captured runs with two signals: *quality*, a continuous score; and *does_pass*, a binary decision.
>
> *Figure: the two evaluators - quality, a scalar 0-1 combining grounding in search results, appropriate search behavior and usefulness; and does_pass, a binary pass or fail.*
> ![[langchain-959080-006.jpg]]
>
> To measure correctness separately from repeatability, we had a human reviewer label each fixed response against the same rubric. Using the human reviewers labels as the oracle score enabled a richer analysis on the affects of precision and correctness on overall evaluator effectiveness.
>
> Accuracy measures agreement with the human oracle. Variance measures whether a judge reaches the same judgment consistently on identical agent behavior. Lower variance does not automatically mean higher accuracy: a judge can still be consistently wrong. But when a judge is accurate, ***lower variance makes that accuracy more dependable in production***.
>
> We compared Jev with GPT-5.6 Luna, GPT-5.6 Terra, and Claude Sonnet 4.6, calculating per-case variance across 100 repetitions and agreement with the human oracle.
>
> ## Evaluation Results
>
> ***Accuracy***
>
> Using the human reviewer’s labels as the oracle for this comparison, we calculated accuracy for the binary pass/fail decision.
>
> For the binary *does_pass* score, Jev matched the oracle on all 500 repeated decisions. Terra matched on 99.8% of decisions, Luna on 96.4%, and Claude on 80.0%.
>
> *Figure: human-oracle pass/fail accuracy, the share of all repeated judgments matching the fixed human label - Jev 100.0%, GPT-5.6 Terra 99.8%, GPT-5.6 Luna 96.4%, Claude Sonnet 4.6 80.0%.*
> ![[langchain-959080-007.jpg]]
>
> ***Precision***
>
> Accuracy tells us whether a judge agreed with the human oracle. Precision asks whether it produces the same quality score when the agent behavior is unchanged. We measured precision with the observed variance of each judge’s scores.
>
> Jev had the lowest observed mean per-case variance: 0.0000149. Luna was 433× higher, Terra was 913× higher, and Claude was 92× higher.
>
> This experiment cannot tell us why Jev’s scores varied less. One hypothesis is that the models are optimized for different kinds of output. TypeSafe describes Jev as a decision model trained to return calibrated probabilities and typed answers, while an autoregressive LLM judge generates text before the evaluator maps that output into a score. That difference may make Jev a better fit for this bounded evaluation task, but the result is observational, not evidence that its training objective caused the lower variance.
>
> *Figure: mean quality variance per evaluator - Jev 0.0000149 at 1x, GPT-5.6 Luna 0.00647 at 433x, GPT-5.6 Terra 0.01364 at 913x, Claude Sonnet 4.6 0.00137 at 92x.*
> ![[langchain-959080-008.jpg]]
>
> *Figure: evaluator-returned quality score across 100 repetitions, mean over the five frozen cases on a shared zoomed y-axis - Jev a near-flat line just above 0.87, Luna swinging roughly 0.83 to 0.97, Terra the noisiest at roughly 0.77 to 0.97, Claude oscillating narrowly around 0.86.*
> ![[langchain-959080-009.jpg]]
>
> *Figure: does_pass across 100 repetitions on the same shared axis - Jev perfectly flat at the 0.8 level and Claude perfectly flat at the 0.6 level, so Claude is fully repeatable while disagreeing with the human on one of the five cases every time; Terra flat at 0.8 with a single dip near repetition 31; Luna the only unstable judge, stepping between 0.6, 0.8 and 1.0 about a dozen times.*
> ![[langchain-959080-010.jpg]]
>
> ***Cost and latency***
>
> *Figure: cost and latency per judge - Jev $0.00035 per call at 0.44s for $0.34 total, GPT-5.6 Luna $0.00039 at 2.50s for $0.39, GPT-5.6 Terra $0.00289 at 2.83s for $2.90, Claude Sonnet 4.6 $0.02811 at 2.16s for $28.17.*
> ![[langchain-959080-011.jpg]]
>
> Low cost means running agent evaluations at scale can be practical. When evaluator calls are expensive, teams have to decide between coverage and their budget. At $0.00035 per call in this experiment, Jev makes that tradeoff less severe. Teams can afford more repeated judgments and more frequent regression checks. This matters even more for online evaluation, where lower per call cost lets teams run more judges across a larger share of production traces, producing a denser feedback signal.
>
> *Figure: cost per evaluator call on a log x-axis against average latency, bubble size showing average total tokens - Jev alone in the lower left at $0.0003453 and roughly 0.44s, Luna at 2.50s, Terra highest at 2.83s, Claude farthest right at $0.02811 with the largest bubble.*
> ![[langchain-959080-012.jpg]]
>
> ## Online evals unlocked at scale
>
> For a production agent that produces 10,000 traces per day, the observed per-call costs translate into a meaningful operating difference.
>
> To account for whether a low-cost call is useful, we define **signal value** as binary oracle agreement multiplied by binary repeatability. Repeatability is the chance that two independent calls on the same trace return the same verdict. This rewards judges that are both accurate and stable, while penalizing a judge that is consistently wrong.
>
> *Figure: signal value, defined as binary oracle agreement times binary repeatability, with the extrapolated online-eval cost at 10,000 traces per day - Jev 100.0% for $3.45 daily and $103.59 over 30 days, GPT-5.6 Luna 90.1% for $3.91 and $117.24, GPT-5.6 Terra 99.4% for $28.89 and $866.61, Claude Sonnet 4.6 80.0% for $281.14 and $8,434.08.*
> ![[langchain-959080-013.jpg]]
>
> A high-signal, low cost judge like Jev could unlock better value in online evaluators. Teams could  generate feedback on more production traces, spot changes in quality sooner, and set alerts when that feedback starts to trend in the wrong direction.
>
> ## A new type of agent evals
>
> Today, every agent eval carries a tradeoff. Score more agent runs, evaluate more dimensions, or test more changes, and the cost of your testing grows. That pushes teams to evaluate less that they would like.
>
> In our experiment, a Jev judgment cost $0.00035. In addition to its low cost, Jev offered high accuracy and low variance, meaning the judge results were reliable and high-signal. A quality judge at that price means builders can evaluate each agent run against several focused criteria, measure every agent change, and repeat judgments when confidence matters.
>
> This matters because building great agents requires substantial testing and monitoring. The more often you evaluate an agent, the more useful feedback enters the development cycle.
>
> We still need to see whether the results in this experiment carry over to other agents and production workflows. Additionally, low cost can amplify mistakes - a consistently wrong evaluator can produce bad feedback at scale. Engineers still need to incorporate human review and judge alignment into their workflows.
>
> The new System One style of models could make high quality evaluation abundant. That can speed up the entire agent development lifecycle. Agent engineers can turn more traces into feedback, catch regressions sooner, and move faster as they build, test, monitor, and deploy agents. The unlock is not just cheaper evals, but a tighter feedback loop for building reliable agents.
>
> ## Reproducibility
>
> This project’s GitHub repository is available [here](https://github.com/danielgshea/jev-as-a-judge).
>
> We ran the LLM judges through LangSmith Gateway: GPT-5.6 Luna, GPT-5.6 Terra, and Claude Sonnet 4.6. We accessed Jev through langchain-typesafe==0.0.1a2.
>
> For reproducibility, the run used Deep Agents 0.7.15, LangChain OpenAI 1.6.2, LangSmith 0.12.6, and Tavily Python 0.8.3. We did not set temperature, top-p, seed, or max tokens for the LLM judges, so each provider’s defaults applied. The Jev service version was not available in the experiment metadata.
>
> ## Learn more
>
> If you want to learn more about building agents with Jev, LangChain is hosting a [livestream with the TypeSafe AI](https://events.langchain.com/webinar/building-a-harness-with-jev/) team on Tuesday, Sep 22nd.
>
> ---
>
> ### Host tweet
>
> **@LangChain** · 2026-09-19 23:31 UTC · 57 likes · 10 retweets · 16 replies · 3,888 views
>
> We tested Jev against LLM judges on accuracy, repeatability, latency, and cost to see whether System One models could offer a new approach to agent evaluation. https://x.com/i/article/2101448785255907328
>
> *Cover image for the Article (1500x600): a title card reading "Jev-as-a-Judge for Agent Evals" with the LangChain wordmark and a decorative concentric-circle motif. No data, not embedded.*
>
> ---
>
> ### Quote-tweet (the entry point)
>
> **Sydney Runkle (@sydneyrunkle)** · 2026-09-20 00:36 UTC · 3 likes · 0 retweets · 0 replies
>
> jev as a Judge proves to be a cheaper and more precise alternative to LLM as a judge for online evals.
>
> great guide from Sean and Daniel on why Jev is great for evals, an experiment vs other LLMs, and how to try this out for your agents!
>
> *Her attached photo is byte-identical to the article's Jev Judge diagram, embedded above as figure 3 (langchain-959080-003.jpg). No second copy saved.*
>
> ---
>
> ### Replies
>
> All 16 replies on the host tweet, verbatim, fetched 2026-09-20 00:52 UTC. The quote-tweet had none.
>
> **@sydneyrunkle (Sydney Runkle)** · Sun Sep 20 00:47:26 +0000 2026
>
> @LangChain my fav use case thus far
>
> https://x.com/sydneyrunkle/status/2101473271472373774
>
> ---
>
> **@KeithZhai (Keith Zhai)** · Sat Sep 19 23:44:30 +0000 2026
>
> @LangChain glad someone scored the judges on latency and cost too, not just accuracy
>
> https://x.com/KeithZhai/status/2101457436192149921
>
> ---
>
> **@johnroodepic (John Rood)** · Sun Sep 20 00:07:29 +0000 2026
>
> @LangChain Cheap judges get dangerous when the evaluator version isn't pinned to every trace. If the score moves, you need to know whether the agent regressed or the judge changed before that signal touches the feedback loop.
>
> https://x.com/johnroodepic/status/2101463218615197894
>
> ---
>
> **@ryanndngg (Ryan)** · Sun Sep 20 00:06:14 +0000 2026
>
> @LangChain five weather traces is enough to prove the plumbing, not the judge. the real test is adversarial near-misses: right tool, wrong source freshness; correct answer, unsupported evidence; task complete, bad side effect. low variance on easy labels can hide a consistently wrong grader
>
> https://x.com/ryanndngg/status/2101462905854349775
>
> ---
>
> **@Sagarvd01 (Sagar Tanur 🇮🇳)** · Sun Sep 20 00:06:43 +0000 2026
>
> @LangChain This is the useful split: an evaluator should return a decision the pipeline can act on, not another paragraph to parse. The 100-repeat variance check is exactly what makes “reliable” mean something in an agent CI loop.
>
> https://x.com/Sagarvd01/status/2101463026033442984
>
> ---
>
> **@ragzoi (Raghu)** · Sat Sep 19 23:53:54 +0000 2026
>
> @LangChain repeatability is the axis that decides whether your accuracy number is signal or judge drift
>
> https://x.com/ragzoi/status/2101459803167977886
>
> ---
>
> **@bullbear_info (BullBear.News)** · Sun Sep 20 00:03:37 +0000 2026
>
> @LangChain System One models usually struggle with the nuance required for multi-step evaluation benchmarks.
>
> https://x.com/bullbear_info/status/2101462246929166406
>
> ---
>
> **@jatingargiitk (Jatin Garg)** · Sat Sep 19 23:45:04 +0000 2026
>
> @LangChain Repeatability is where LLM judges fail hardest. You can't build a deterministic eval pipeline when the same input returns different verdicts across runs.
>
> https://x.com/jatingargiitk/status/2101457579100758027
>
> ---
>
> **@irastech (Deep)** · Sat Sep 19 23:48:59 +0000 2026
>
> @LangChain i stopped trusting llm judges as my only check. they drift between runs, so now i log every score and compare. repeatability is the part that bites.
>
> https://x.com/irastech/status/2101458562127945889
>
> ---
>
> **@Hershal0_0 (Hershal Rao)** · Sun Sep 20 00:38:45 +0000 2026
>
> @LangChain anything to save us from the API bill of using GPT-4 as a judge 💀
>
> https://x.com/Hershal0_0/status/2101471087116816606
>
> ---
>
> **@dhinnaship_ico (dhinna ship .ico)** · Sun Sep 20 00:48:16 +0000 2026
>
> @LangChain Does the cost comparison factor in the prompt caching for repeated runs?
>
> https://x.com/dhinnaship_ico/status/2101473482890522714
>
> ---
>
> **@fauxsocialapp (Faux Social)** · Sun Sep 20 00:37:02 +0000 2026
>
> @LangChain drop the benchmark repo plsss
>
> https://x.com/fauxsocialapp/status/2101470657221460107
>
> ---
>
> **@neel_sh_ (Neel)** · Sun Sep 20 00:14:05 +0000 2026
>
> @LangChain evals that dont burn money. rare
>
> https://x.com/neel_sh_/status/2101464878649155959
>
> ---
>
> **@ethereaglehq (ethereagle · building)** · Sun Sep 20 00:18:38 +0000 2026
>
> @LangChain did the LLM judge get a typed schema like Jev, or score free text while Jev returned structured answers? if the cases are yes/no, the repeatability gap might just be the output format
>
> https://x.com/ethereaglehq/status/2101466024100966728
>
> ---
>
> **@OMID_0909 (EKOS _ AGI 🦊 🇮🇷)** · Sun Sep 20 00:28:31 +0000 2026
>
> @LangChain @hwchase17 This makes Jev much more interesting as an eval layer. The next question is what the judge is actually evaluating against — if the underlying context isn’t versioned and traceable, you can have a highly consistent judge evaluating an unreproducible state.
> Right?
>
> https://x.com/OMID_0909/status/2101468512032080231
>
> ---
>
> **@robinhodl69 (Robin)** · Sun Sep 20 00:18:47 +0000 2026
>
> @LangChain justo y necesario
>
> https://x.com/robinhodl69/status/2101466063200247879
