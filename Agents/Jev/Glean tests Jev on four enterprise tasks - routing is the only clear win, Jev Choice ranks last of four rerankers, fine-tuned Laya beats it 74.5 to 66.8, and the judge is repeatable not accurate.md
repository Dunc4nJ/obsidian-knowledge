---
created: 2026-09-29
description: Glean ran Jev against real production baselines on four bounded decisions - query classification, model routing, reranking and citation-support judging - and the results split three ways. Model routing is the one clean win (any-expert recall 64.6 to 80.5, precision 54.6 to 88.0, median per-entry speedup 8.1x), but it rests on 82 positive transfers inside 751 replayed golden entries, one expert with six of them, and a 40-entry latency sample, and Jev strictly adds a serial call on the roughly 89 percent non-transfer path. Query classification is scored as agreement with an LLM-based production system rather than accuracy, and a Laya fine-tune that trains locally in a few hours beats zero-shot Jev 74.5 to 66.8. Reranking is the buried result - the chart shows Jev Choice last on all four metrics behind Glean production and two frontier-LLM rerankers, and it assigned identical scores to about 37 of 41 candidates, so production tie-breaking lifted Recall@6 from 40.2 to 44.3. The citation judge changed its verdict on 1 of 28 paragraphs against Luna's 7 and 5, which the authors are explicit is repeatability and not accuracy on a single 1,448-word response with no human labels.
source: https://x.com/tonygentilcore/status/2104639390266036251
author: Eddie Zhou, mr_cheu, Mat Zhao, Aviral Singh, Manav Agrawal (Glean); posted by Tony Gentilcore
published: 2026-09-28
type: knowledge
tags: [jev, typesafe, glean, classification, model-routing, reranking, llm-as-judge, citation-judging, laya, kev, system-one, enterprise-search]
---

# Glean tests Jev on four enterprise tasks - routing is the only clear win, Jev Choice ranks last of four rerankers, fine-tuned Laya beats it 74.5 to 66.8, and the judge is repeatable not accurate

## Key Takeaways

- **This is the first note in the vault where a company with a real production baseline ran Jev against it on four tasks at once, and the headline is how unevenly it lands.** Glean's own summary is honest about the spread: the results "ranged from materially worse than production to both faster and more accurate than an LLM-based router." What makes the post unusually useful is that the four tasks are the four categories the vault has been collecting separately - classification, routing, reranking, judging - measured by one team, on one stack, in one week. Read against [[Josh Rosen's Jev in the Wild sorts week-one projects into routing, context filtering, tool gating, worker supervision, fast control loops and fuzzy data queries - deterministic only because inference was expensive|Rosen's taxonomy of week-one projects]], which named twenty-five projects and reported not one measurement, this is the measurement pass over the same categories.

- **The cost and latency wins are declared priors, not findings, and the article says so in its own setup.** "Most of these baselines are LLM-based systems, so for those experiments we know to expect two orders of magnitude improvement on cost and latency." Everything Jev is being tested for here is therefore quality delta. That framing is the correct one and it is rarely stated this plainly - it is the same correction Parallel put in its own TL;DR ("the headline cost and speed comparisons are against autoregressive LLMs, not dedicated classifiers"), and it is what the vault's cost-focused notes keep having to reconstruct after the fact.

- **Query classification does not measure accuracy. It measures agreement with an LLM, and the open fine-tune beats Jev on that metric by 7.7 points.** The table is Jev zero-shot 66.8%, base Laya 35.9%, fine-tuned Laya 74.5% - the authors are explicit that they "focus on gauging Jev's agreement against our production / baseline predictions, which is LLM-based" and that they "report agreement as an easy proxy for quality." There is no ground truth anywhere in this experiment, so a model could in principle be more accurate and score lower. The `Perf` column is likewise not a latency comparison: Jev's "~12min (concurrency of 4)" is offline throughput under an API concurrency cap, while Laya's "~90s (local dev machine)" is local inference with no cap. The durable finding is the one the authors draw - a few hours of local fine-tuning buys 7.7 points over hosted zero-shot, and Jev's remaining edge is that it needs no labels when the taxonomy is still moving.

- **Model routing is the strongest result in the post and it is also the thinnest sample.** Any-expert recall goes 64.6% to 80.5% and precision 54.6% to 88.0%, which is a large, real delta. But the per-expert chart the prose never walks through shows where it comes from: the 751 replayed golden entries are 34 + 42 + 6 + 669, so only **82 entries (10.9%) are positive transfers at all**, and Expert 3's baseline precision of 12.5% is one hit in eight. The latency sample is 40 entries. And the authors flag the structural cost themselves - Jev "will strictly add a call in the event of a non-transfer," a serial ~0.3 s tax on the ~89% of requests that do not transfer, where the production baseline folds the decision into the first LLM call it was going to make anyway. Their argument is that the accuracy delta may pay for that tax, which is a judgement, not a measurement. This is the shipped, measured version of [[LangChain's Sydney Runkle puts Jev inside the agent loop as classifier middleware - ModelRouterMiddleware picks the model from the latest user message and AutoModeMiddleware reproduces closed harnesses' dangerous-action gate|LangChain's ModelRouterMiddleware]], and the first routing number in the vault that is not a vendor's own.

- **Reranking is the result the prose soft-pedals: Jev Choice finishes last on every metric, behind two frontier-LLM rerankers the text never names.** The chart has four bars, not two. Against Glean production / GPT-6-Luna-high / GPT-6-Sol-high / Jev Choice, Recall@1 is 35.7 / 30.7 / 31.5 / **24.4**, Recall@3 45.8 / 39.2 / 40.1 / 33.7, Recall@6 51.2 / 45.1 / 46.8 / **40.2**, Evaluator MAP 42.9 / 37.7 / 38.6 / **32.0**. The prose compares Jev only with production, so a reader who does not open the figure will miss that both frontier rerankers also beat it. The mechanism is degenerate scoring - Jev "assigned identical scores to roughly 37 of the 41 candidates in an average query," which is why production tie-breaking alone lifted Recall@6 from 40.2 to 44.3 and flattered the uncorrected number. At $0.00044 per query and 0.195 s at p50 over 4,855 paired queries it is a cheap baseline; it is not a ranker. This is the same failure mode [[Applied Compute freezes a Sol-built 14-label taxonomy so Jev annotates the corpus - ECE 0.051 against Luna's 0.154 and 85 percent recall at 0.20, with every rival left at Jev's threshold|Applied Compute measured as low resolution]] - Jev hedges, its scores bunch, and bunched scores cannot rank.

- **The citation judge is more repeatable, not more accurate, and the authors refuse the stronger claim in writing.** Jev changed a verdict on 1 of 28 paragraphs and disagreed with itself on 2 of 84 pairwise comparisons, against Luna no-reasoning at 7 of 28 and 15 of 84 and Luna xhigh at 5 of 28 and 10 of 84. Their own caveat is the important sentence: "the systems applied different support criteria and scoring denominators, and we didn't have time to do independent human labels." Sample size is **one** 1,448-word response, three runs per judge. The timing table is not like-for-like either - Jev's 6.6 s is sequential client wall time while the Luna rows sum model-call durations, and costs "include observed caching." This is the second independent measurement of the same property: [[LangChain's Jev-as-a-Judge bench puts Jev's quality-score variance 92 to 913x below three LLM judges at $0.34 against Claude's $28.17 - five weather traces, one human oracle, provider-default sampling|LangChain's judge bench]] found Jev's score variance 92 to 913x below three LLM judges on five traces. Both studies found repeatability; neither found accuracy, and a judge that is perfectly consistent about the wrong criterion is a well-behaved thermometer pointed at the wrong room.

- **A purpose-built or fine-tuned classifier beating zero-shot Jev on classification is now the fourth independent instance in the vault, and it is starting to look like the rule.** Fine-tuned Laya beats Jev 74.5 to 66.8 here; [[MotherDuck's prompt_jev labels 100k AG News rows in 40 seconds for 50 cents at 89 percent - a benchmark fine-tuned encoders beat by 5 points, metered at a 25 percent markup over TypeSafe list|MotherDuck's AG News run]] lands 5 points under fine-tuned encoders; the Cribl result inside [[Josh Rosen's JevOps survey puts Jev at seventeen DevOps decision points - SREGym's 20 to 24 of 50 is the only controlled number, and Jev Logs' 99 percent recall comes from forwarding 99 percent|Rosen's JevOps survey]] has Jev at 84.76% against a purpose-built classifier's 92.38% on a 28-way log-type task; and Parallel lost both of its classification tasks to internal models. [[Cua keeps the candidate menu in application code so Jev only picks an ID - CUA-S1-FORMS is a 706K-parameter form specialist at 99.7 percent against hosted Jev's 83.6, and neither model sees pixels|Cua's 706K-parameter form specialist at 99.7 against Jev's 83.6]] is the extreme version. Glean's own closing rule concedes the pattern: "if the task and labels are stable and volume is high, benchmark a fine-tuned classifier too."

## The four experiments

### Query classification - agreement, not accuracy

The task maps a request to a broad downstream task. Glean's stated reason for liking it as a Jev workload is taxonomy churn: the label space is fixed per request, but "the taxonomy can still change faster than a fine-tuned classifier can be retrained."

| Experiment | Broad task agreement | Reported perf |
| :---- | ----: | :---- |
| Jev zero-shot | 66.8% | ~12 min at concurrency of 4 |
| Base Laya | 35.9% | ~90 s on a local dev machine |
| Fine-tuned Laya | 74.5% | ~90 s on a local dev machine |

Two things do not survive a close read. The metric is agreement with an LLM-based production system, so it cannot distinguish "Jev is wrong" from "Jev disagrees with an LLM that is wrong" - there are no ground-truth labels in this experiment at all. And the perf column compares a rate-limited hosted API against unmetered local inference, which is a throughput artifact rather than a latency result. What is left standing is the comparison Glean actually draws, and it is the interesting one: a fine-tune that "was able to run locally in a few hours" on a model "small enough to be served on a developer machine" beats the hosted zero-shot model by 7.7 points.

**What Laya is**, since the article never says: `NandhaKishorM/laya` on GitHub, Apache-2.0, Python, created 2026-09-18 and at roughly 27.8k stars. Its README describes it as a "multilingual, non-autoregressive System 1 decision engine" giving "typed decisions over 100+ languages in a single forward pass - 33 ms - trained with reinforcement learning against strictly proper scoring rules (RLCD), with a router that picks the right checkpoint per request." It exposes the same three primitives as Jev under the same names - `choice`, `score`, `noul` - and ships an ecosystem (`laya-ts`, HTTP server, MCP server, LangChain / LlamaIndex / CrewAI integrations, ONNX). RLCD is the same training-objective name TypeSafe uses in [[TypeSafe's Jev trades string generation for parallel-sampled typed decisions with calibrated probabilities at $0.042 per MTok - the 193x and 444x claims come from four self-built workflow evals|the Jev launch post]]. It belongs with [[Stanford's CLM-8B is an open bi-encoder System One model caching actions apart from state - 13x over Jev at 1K candidates and 3 of 38 DeepSWE tasks over random where Jev loses 1|CLM-8B]], [[jevlike]], [[simple-jev]] and Kev as the open System One family, and it is the first of them the vault has seen beat Jev on a real internal task.

### Model routing - the win, and its denominators

*Any-expert quality, LLM routing against Jev.*
![[tonygentilcore-036251-003.jpg]]

*Per-expert quality, showing the entry counts the prose omits.*
![[tonygentilcore-036251-004.jpg]]

The aggregate is unambiguous: recall 64.6% to 80.5%, precision 54.6% to 88.0%. The per-expert chart is where the denominators live.

| Bucket | Entries | Baseline precision | Jev precision | Baseline recall | Jev recall |
| :---- | ----: | ----: | ----: | ----: | ----: |
| Expert 1 | 34 | 70.2% | 86.8% | 97.1% | 97.1% |
| Expert 2 | 42 | 47.1% | 86.7% | 38.1% | 61.9% |
| Expert 3 | 6 | 12.5% | 85.7% | 33.3% | 100% |
| No Expert | 669 | 95.6% | 97.6% | 93.4% | 98.7% |

The buckets sum to 751, matching the replayed golden set, so **82 entries (10.9%) are positive transfers and 669 (89.1%) are not**. Expert 3's baseline precision of 12.5% is one correct call in eight; its Jev recall of 100% is six of six. The largest bucket, No Expert, was already at 95.6 / 93.4 and moves two to five points. Most of the aggregate gain therefore comes from Expert 2 (42 entries) and from not over-transferring on the 669.

*Latency on the 40 entries where the existing path actually made a transfer call.*
![[tonygentilcore-036251-005.jpg]]

| Statistic | LLM call | Jev |
| :---- | ----: | ----: |
| Mean | 2.551 s | 0.306 s |
| Median | 2.276 s | 0.290 s |
| p90 | 3.783 s | 0.431 s |
| p95 | 5.083 s | 0.448 s |
| Maximum | 5.252 s | 0.526 s |

Note which statistic is which: the ratio of the two medians is 7.85x, while the prose's "median per-entry speedup was 8.1x" is the median of the per-entry ratios. Both are defensible, they are not the same number, and only the second is quoted. The structural caveat is the authors' own and it is the one that decides whether this ships - on the ~89% non-transfer path Jev adds a serial call that the LLM baseline does not need, because that baseline "can begin the tool-calling work via the same single first LLM call." Roughly 0.3 s of blocking tax on nine requests in ten, bought with a large precision gain on the one. Glean's position is that "the magnitude of the delta implies that the 'blocking' tax ... may be a good tradeoff," and they are clear that this is still "an offline golden-set comparison."

### Reranking - last of four

*Reranker quality. The prose names two of these four systems.*
![[tonygentilcore-036251-006.jpg]]

| Metric | Glean | GPT-6-Luna-high | GPT-6-Sol-high | Jev Choice |
| :---- | ----: | ----: | ----: | ----: |
| Recall@1 | 35.7% | 30.7% | 31.5% | 24.4% |
| Recall@3 | 45.8% | 39.2% | 40.1% | 33.7% |
| Recall@6 | 51.2% | 45.1% | 46.8% | 40.2% |
| Evaluator MAP | 42.9% | 37.7% | 38.6% | 32.0% |

Four formulations were tried - pointwise Noul, shared-state Noul, Score, and Choice - which map exactly onto the three primitives catalogued in [[Annabell frames TypeSafe's Jev as a savant for eval verdicts and routing - three question types, 255 choices, 10 score levels, and a Noul with no confidence field|Annabell's breakdown of Jev's question types]], with shared-state Noul as the one formulation that gives the model the whole candidate set as context. Choice won among them and still lost to everything else on the chart. Setup: up to 50 candidates per query, 4,855 paired queries, tie-breaking from production removed, on an internal evalset where the user lacks access to all canonicals - so the absolute numbers are deliberately not production-representative and only the relative ordering is claimed.

The degeneracy is the finding. Identical scores on "roughly 37 of the 41 candidates in an average query" means Jev Choice is, on most queries, expressing an opinion about four documents and shrugging at the rest; restoring production order over those ties moved Recall@6 from 40.2 to 44.3. Glean's conclusion - "a cheap, efficient baseline, not a replacement for Glean's production ranker" - is the right one at $0.00044 and 0.195 s p50. Compare [[Can Bölük's jegrep turns Jev into a semantic grep by scoring grep-ranked candidates with one Noul per file and a Choice for the line range - $0.004 a query, and the Gemini-lite comparison is nowhere in the repo|jegrep]], which uses Jev the same way but over a candidate set that `grep` has already pruned to something small and high-precision, and [[reranking]] for the classical framing.

### Citation-support judging - n = 1

| Judge | Time per response | Cost per response |
| :---- | ----: | ----: |
| Jev | 6.6 s | $0.014 |
| GPT-5.6 Luna, no reasoning | 81.3-85.5 s | $0.030-$0.047 |
| GPT-5.6 Luna, xhigh | 227.4-259.7 s | $0.047-$0.060 |

| Judge | Paragraphs with a changed recall verdict | Pairwise recall disagreements |
| :---- | ----: | ----: |
| Jev | 1 of 28 (3.6%) | 2 of 84 (2.4%) |
| GPT-5.6 Luna, no reasoning | 7 of 28 (25.0%) | 15 of 84 (17.9%) |
| GPT-5.6 Luna, xhigh | 5 of 28 (17.9%) | 10 of 84 (11.9%) |

One response, 1,448 words, 28 paragraphs, three runs per judge, response and citation evidence held fixed. Jev's single change was "whether one paragraph counted as needing a citation," and its raw recall category never moved. The authors then decline the obvious over-claim: they are "not concluding that this makes Jev the more accurate judge," because the judges applied different support criteria and different scoring denominators and no human labels were collected. The timing rows are also measured differently on each side. So the honest reading is narrow and still useful - for a *narrow, fixed* citation policy, Jev gives the same answer twice, cheaply. Jev also produces no rationale, which the authors name as a usability risk since they use rationales for error analysis; that is the same abstention-and-explanation gap Annabell identified. For the alternative route to a cheap, consistent judge see [[LangChain and Fireworks fine-tune Qwen as a 100x cheaper trace judge that beats frontier models on unseen perceived-error domains|the fine-tuned Qwen trace judge]], and for the standing advice on judge design [[anthropic recommends combining deterministic graders model judges and human review for agent evals]].

## Parallel's external test, and whether it conflicts

Glean cites Parallel's post in one clause: "Parallel's external tests likewise found Jev competitive on reranking, while specialized models still won two classification tasks." Parallel's actual numbers are thinner than "competitive" suggests and point the other way from Glean's own reranking result.

- **Reranking**: Jev "matched at least one of our custom rerankers on NDCG@10," reported as "NDCG@10 of 0.7: comparable to internal system," and "performed competitively on latency against our larger models." It "had a materially higher cost per document," because Parallel owns its inference infrastructure.
- **Classification**: topic classification (a large label set) and query freshness classification both went to Parallel's internal models. Parallel's diagnosis is specific and matches Glean's - a large label set "was a weakness in our tests," and freshness is likely out of Jev's training distribution.

**Do the two reranking results conflict?** Not formally, but they do not corroborate each other the way Glean's sentence implies. Parallel's claim is that Jev tied *the weakest of several* custom rerankers on NDCG@10 over web-scale search; Glean's is that Jev Choice finished behind a full production enterprise-search stack *and* two frontier-LLM rerankers on Recall@1/3/6 and MAP over an internal evalset with restricted canonical access. Different baselines, different metrics, different corpora, and Parallel never says which Jev formulation it used. The one place they agree exactly is the framing: Parallel's TL;DR that "the headline cost and speed comparisons are against autoregressive LLMs, not dedicated classifiers" is the same point Glean makes in its own setup, and Parallel's cost finding - Jev more expensive per document than self-hosted rerankers - is a live counterexample to the two-orders-of-magnitude prior for anyone who already runs inference at scale.

## What Glean says it will do

Ship, after operational work: "after a few more steps (mainly, operational readiness like data residency and guarantees) we plan to ship Jev into some of these use cases," plus an internal hackathon the same week. The closing rule is the most portable thing in the post:

> if the output can be listed in advance, benchmark Jev. If the task and labels are stable and volume is high, benchmark a fine-tuned classifier too. If the call needs to generate a query, explanation, or other dynamic text, keep a generative model in the loop.

Tool calling is their worked example of the third clause: Jev can pick the tool, but most Glean tools still need dynamically generated arguments. That is the [[Cua keeps the candidate menu in application code so Jev only picks an ID - CUA-S1-FORMS is a 706K-parameter form specialist at 99.7 percent against hosted Jev's 83.6, and neither model sees pixels|application-mints-the-menu pattern]] with its limit stated, and it is the boundary [[TypeSafe's SDE cascade gates escalation on any per-field Noul above 0.7 - the chart's y-axis is mean llm_judge and the frontier dominates only the two middle models|TypeSafe's own SDE cascade]] and [[Daniel Ch's How to master Jev prescribes a 0.85 and 0.55 confidence-gate ladder under an LLM that still writes - the decision-layer architecture is additive but every number and all three charts are TypeSafe's own|Daniel Ch's confidence-gate ladder]] both draw with thresholds instead of prose. Author context: Tony Gentilcore is a Glean co-founder in product engineering, ex-Google web search and the Chrome speed team, and previously argued in [[Glean argues enterprise indexing is necessary but not sufficient - the real unit is a unified permission-aware index inside a system of context of indexes, graphs, memory, connectors, and tools|Glean's system-of-context post]] that the unit of enterprise AI is a permission-aware index rather than a model. Filed alongside the rest of [[moc - Jev]].

## External Resources

- [Jev / System One Models launch post (TypeSafe)](https://typesafe.ai/blog/introducing-system-one-models-and-jev) - the primary source the article links on first mention.
- [Parallel, "Testing out Jev: real-world developer experience"](https://parallel.ai/blog/testing-jev) - the external test Glean cites; reproduced in full below.
- [github.com/ekzhang/openjev-sglang](https://github.com/ekzhang/openjev-sglang) - Jev-compatible API endpoint on open models, prefill-only (Qwen and SGLang); 333 stars, no license.
- [github.com/mmastrac/djev-spark](https://github.com/mmastrac/djev-spark) - DiffusionGemma with vLLM, NVFP4 on a DGX Spark; 219 stars, no license.
- [github.com/jaredpalmer/kev](https://github.com/jaredpalmer/kev) - open decision models, LoRA plus pointer head on Qwen3 bases, Apache-2.0, 7,667 stars, created 2026-09-17.
- [github.com/NandhaKishorM/laya](https://github.com/NandhaKishorM/laya) - the open-weight decision model Glean fine-tuned; Apache-2.0, ~27.8k stars, created 2026-09-18.
- [David Arias, "Is Jev efficient for RAG?"](https://x.com/Davidariasfin/status/2104338858121060580) - linked from his reply; a 10-K test against four LLMs.

## Not Yet Captured

- David Arias' X Article "Is Jev efficient for RAG? A test on 10-Ks from Apple, Microsoft, Nvidia and Amazon" (`https://x.com/Davidariasfin/status/2104338858121060580`, 27 September, 65 blocks, 3 images).
- Resource notes for `jaredpalmer/kev`, `NandhaKishorM/laya`, `ekzhang/openjev-sglang` and `mmastrac/djev-spark` - all four are named in this article and none has one.
- Mikhail Parakhin's 18 September tweet and Eddie Zhou's quote-tweet of the `@identityTorn` bell-curve meme (both shown in the first figure).

## Original Content

The host tweet carries only the article link. The article's cover image - a Rick and Morty still of Morty gaping at a routing dashboard - is decorative and is not reproduced here. Six body figures are embedded at their positions with transcriptions, and the five tables are the article's own MARKDOWN entities, verbatim.

> [!quote]- Original Content: host tweet, full article, replies, and Parallel's post
> ### Host tweet
>
> **@tonygentilcore** (Tony Gentilcore) - 28 September 2026, 18:28 UTC - 6 replies, 193 likes, 20 reposts, 80,354 views
>
> > https://x.com/i/article/2104627177396588544
>
> Article id 2104627177396588544. Title: **Is Jev overhyped? We tested it on 4 real enterprise tasks.**
>
> ### Article, verbatim
>
> # Is Jev overhyped? We tested it on 4 real enterprise tasks.
>
> *Authors: @eddiedzhou, @mr_cheu,* [@MatZhao](https://x.com/@MatZhao)*, Aviral Singh, Manav Agrawal*
>
> [Jev](https://typesafe.ai/blog/introducing-system-one-models-and-jev) is a model for making typed decisions. You send it context plus a fixed set of questions and options, then it returns choices, scores, and probabilities instead of generating text.  It’s a “System One” model!
>
> But classification is not new, and neither are structured outputs, small models, or reading probabilities from logits. That history explains some of the split reaction to Jev...
>
> *Figure transcription. The split reaction. Mikhail Parakhin (@MParakhin), Sep 18: "Jev model is very polarizing in my social vicinity: people who got exposed to AI after ChatGPT are positively giddy with excitement, like they have literally just discovered fire. Pre-GPT ML people are baffled how that could've made news at all :-)" - 151 replies, 123 reposts, 2.8K likes, 268K views. Eddie Zhou (@eddiedzhou) replies "best summarized as" and quotes @identityTorn (Sep 17): "the mid-curvoors need to do their mid-curving, the graph dont paint itself", over the bell-curve meme with "jev brrr" at both tails and "GLiNER / ModernBERT" crying in the middle.*
> ![[tonygentilcore-036251-001.jpg]]
>
> The skeptics have a real point, but Jev has a real place in this ecosystem.  To understand more, we should lay out the full solution space.
>
> ## What are the alternatives?
>
> When a system needs a label, score, or yes-or-no answer, there are four reasonable options:
>
> | Approach | Why use it | Tradeoff |
> | :---- | :---- | :---- |
> | A general-purpose LLM | Zero-shot, flexible, can also generate arguments or explanations.  Arguably “higher intelligence” via inference-time compute (reasoning). | Paying autoregressive-model latency and cost for a small decision |
> | An open zero-shot classifier | Cheap, local, and controllable | Variable quality; you own model selection and serving |
> | A fine-tuned classifier | Usually the best bet for a stable, high-volume task with good labels | Data collection, training, deployment, drift, and a less flexible taxonomy |
> | Jev | Zero-shot flexibility behind a clean, hosted API | Task-dependent quality, no generated text, and provider dependency |
>
>
> The case for Jev: a team can change the question and options without collecting a new training set, while avoiding the work of serving a model well. No one should turn their nose up at that. “We could build it ourselves” is true of most infrastructure products.
>
> Open reproductions keep the novelty claim in check. Implementations using [Qwen and SGLang](https://github.com/ekzhang/openjev-sglang), [DiffusionGemma and vLLM](https://github.com/mmastrac/djev-spark), and [Kev](https://github.com/jaredpalmer/kev) recreate much of the API or model shape.
>
> Caption: 85.7% for Jev and 79.6% for Kev-8B on n=764
> *Figure transcription. "Kev: open decision models, measured against Jev. Typed questions in, calibrated probabilities out, one forward pass, no text generation. LoRA + pointer head on Qwen3 bases." Accuracy on data Kev never trained on: Jev (TypeSafe, hosted) 85.7%, Kev-8B (Qwen3-8B) 79.6%, Kev-4B (Qwen3-4B) 79.0%, Qwen3-8B untrained base 72.6%, Qwen3-30B-A3B untrained base 70.7%, Kev-0.6B 62.0%, Kev-0.5B (Qwen2.5-0.5B, prototype) 56.1%. Side panel: Kev-8B out of domain 79.6%; Kev-8B in distribution, locked test 87.0% with Jev at 84.5% on the same items; +23 pp since the Kev-0.5B prototype, 56.1% to 79.6% with 46M trained parameters (LoRA r=16 + pointer head on a frozen base). Footnotes: "764 frozen out-of-domain records: QNLI, SciQ, PAWS, MMLU, Emotion, TweetEval and held-out policy rules; the same items for every row"; "Untrained bases are read zero-shot from next-token letter logits"; github.com/jaredpalmer/kev, huggingface.co/jaredpalmer, Apache-2.0.*
> ![[tonygentilcore-036251-002.jpg]]
>
> [Parallel’s external tests](https://parallel.ai/blog/testing-jev) likewise found Jev competitive on reranking, while specialized models still won two classification tasks.
>
> ## What we’ve seen at Glean
>
> That leaves a practical question: when does Jev’s combination of zero-shot flexibility and hosted inference actually beat the alternatives? We tested four bounded decisions at Glean where we already had a baseline and could compare real enterprise quality.  Most of these baselines are LLM-based systems, so for those experiments we know to expect two orders of magnitude improvement on cost and latency. The results ranged from materially worse than production to both faster and more accurate than an LLM-based router.
>
> ### Query classification
>
> Query classification maps a request to a broad task used by downstream systems. It is a natural Jev workload because while on a per-request basis, the label space is known in advance, the taxonomy can still change faster than a fine-tuned classifier can be retrained.
>
> For this experiment, we focus on gauging Jev’s agreement against our production / baseline predictions, which is LLM-based. We expect and observed a large speedup in offline throughput with Jev, so we report agreement as an easy proxy for quality.  We also baselined against Laya, an open-weight decision model as well as a fine-tuned Laya.  This fine-tuning was able to run locally in a few hours, and the model is also small enough to be served on a developer machine.
>
> | Experiment | Broad Task Agreement | Perf |
> | :---- | :---- | :---- |
> | Jev zero-shot | 66.8% | \~12min (concurrency of 4\) |
> | Base Laya | 35.9% | \~90s (local dev machine) |
> | Fine-tuned Laya | 74.5% | \~90s (local dev machine) |
>
> As a convenient, no-training off-the-shelf model, Jev clearly outperforms Laya, but somewhat unsurprisingly, fine-tuning makes Laya shine, especially given the performance numbers.  The tradeoff is the effort to get good labels and set up training. Jev likely remains more attractive when a task is new or its labels are changing.
>
> ### Model routing: expert transfer
>
> Model routing is a related problem to query classification.  Here, we frame model routing as expert transfer, where our system chooses which expert / model should handle the request. Our production baseline currently asks an LLM to make that decision natively inside the harness's agentic loop. While this is a natural test of whether Jev can replace a generative call with a bounded decision, an important technical limitation is that Jev will strictly *add* a call in the event of a non-transfer.  This is in contrast to the production baseline, which in non-transfer cases, can begin the tool-calling work via the same single first LLM call.
>
> *Figure transcription. "Jev vs. LLM-Based Routing: Quality". Any-expert recall: LLM routing 64.6%, Jev 80.5%. Any-expert precision: LLM routing 54.6%, Jev 88.0%.*
> ![[tonygentilcore-036251-003.jpg]]
>
> We used a simplified version of our production routing with only 3 experts, replayed 751 comparable golden entries through the updated Jev router and compared its chosen route with our existing prompt-based router (powered by a traditional LLM), and measuring the accuracy against golden label.
>
> *Figure transcription. "Jev vs. LLM-Based Routing: Per-Expert Quality", as baseline precision / Jev precision / baseline recall / Jev recall. Expert 1 (34 entries) 70.2% / 86.8% / 97.1% / 97.1%. Expert 2 (42 entries) 47.1% / 86.7% / 38.1% / 61.9%. Expert 3 (6 entries) 12.5% / 85.7% / 33.3% / 100%. No Expert (669 entries) 95.6% / 97.6% / 93.4% / 98.7%. The four buckets sum to 751, so only 82 of the golden entries - 10.9% - are positive transfers.*
> ![[tonygentilcore-036251-004.jpg]]
>
> We also isolated 40 entries where the existing path made an actual expert-transfer call (smaller n) and compared call latency on those same entries.
>
> *Figure transcription. "Jev vs. LLM-Based Routing: Latency", LLM call against Jev. Mean 2.551 s vs 0.306 s. Median 2.276 s vs 0.290 s. p90 3.783 s vs 0.431 s. p95 5.083 s vs 0.448 s. Maximum 5.252 s vs 0.526 s. The ratio of the medians is 7.85x; the prose's 8.1x is the median of the per-entry ratios.*
> ![[tonygentilcore-036251-005.jpg]]
>
> The median per-entry speedup was 8.1×. This is one of the strongest internal Jev results so far: on this bounded routing task, **Jev was both more accurate and substantially faster**. The magnitude of the delta implies that the “blocking” tax we incur on non-expert-routed requests may be a good tradeoff. Note that it is still an offline golden-set comparison, and the latency sample contains only 40 positive transfers, so there's a lot more to derisk and test!
>
> ### Reranking
>
> A problem near and dear to Glean! Below, our production baseline is the order produced by Glean’s existing search stack. This experiment then asked Jev to reorder up to 50 results.
>
> We tried four ways to express relevance through Jev’s typed outputs:
>
> | Formulation | How it expresses relevance |
> | :---- | :---- |
> | Pointwise Noul | Ask a separate yes-or-no relevance question for each result, then sort by the probability of “yes.” |
> | Shared-state Noul | Show Jev the full candidate set as shared context, then ask the same yes-or-no question for each result. |
> | Score | Ask Jev to assign each candidate a numerical relevance score. |
> | Choice | Treat all candidates as alternatives in one decision, then rank them by their resulting probabilities. |
>
> We ran this on an internal evalset where the user does not have access to all canonicals, so the absolute numbers are not reflective of our production ranking – but the relative numbers are of interest.
>
> Jev “Choice” was the strongest formulation. On a paired control of 4,855 captured search queries, with production-based tie-breaking removed, the result was:
>
> *Figure transcription. "Reranker Quality", four systems of which the prose names two - Glean, GPT-6-Luna-high, GPT-6-Sol-high, Jev Choice. Recall@1 35.7% / 30.7% / 31.5% / 24.4%. Recall@3 45.8% / 39.2% / 40.1% / 33.7%. Recall@6 51.2% / 45.1% / 46.8% / 40.2%. Evaluator MAP 42.9% / 37.7% / 38.6% / 32.0%. Jev Choice is last on every metric, behind both frontier-LLM rerankers as well as production.*
> ![[tonygentilcore-036251-006.jpg]]
>
> Jev Choice cost roughly $0.00044 per query and took 0.195 seconds at p50 in the offline test. But it assigned identical scores to roughly 37 of the 41 candidates in an average query. Using production order to resolve those ties raised Recall@6 from 40.2% to 44.3%, making the uncorrected result look stronger than Jev’s scores alone warranted. There are many caveats here as per usual, but directionally, **Jev is a cheap, efficient baseline, not a replacement for Glean’s production ranker.**
>
> ### Citation-support judging
>
> Citation judging asks two related questions: do claims that need evidence have adequate citations (**citation recall**), and do the cited sources actually support the claims attributed to them (**citation precision**)? At first glance, because the output / label space is bounded (similar to most judge settings) this seems like an obvious fit for Jev.  The rubric is complex, however, and may require decomposing several claims – in addition, Jev doesn’t produce the rationale that we often use for error analysis, so there is some risk to both quality and usability.
>
> We tested Jev on a real 1,448-word production-eval response, holding the response and citation evidence fixed. We compared its shared precision-and-recall pass with GPT-5.6 Luna using no reasoning and xhigh reasoning. To reduce variance, we ran each judge three times.
>
> | Judge | Original measured time per response | Original measured cost per response |
> | :---- | ----: | ----: |
> | Jev | 6.6 s | \$0.014 |
> | GPT-5.6 Luna, no reasoning | 81.3–85.5 s | \$0.030–\$0.047 |
> | GPT-5.6 Luna, `xhigh` | 227.4–259.7 s | \$0.047–\$0.060 |
>
> Note that the timing is directional rather than end-to-end: Jev reports sequential client wall time, while the Luna rows sum model-call durations. Costs include observed caching.
>
> We also compared **consistency** on the same 28 paragraphs. A changed item means the judge changed its verdict on whether a paragraph had adequate citation coverage in at least one of three identical-input runs. Pairwise disagreement counts each paragraph across the three run pairs, for 84 comparisons per judge.
>
> | Judge | Paragraphs with a changed recall verdict | Pairwise recall disagreements |
> | :---- | ----: | ----: |
> | Jev | 1 of 28 (3.6%) | 2 of 84 (2.4%) |
> | GPT-5.6 Luna, no reasoning | 7 of 28 (25.0%) | 15 of 84 (17.9%) |
> | GPT-5.6 Luna, `xhigh` | 5 of 28 (17.9%) | 10 of 84 (11.9%) |
>
> Jev’s only change was whether one paragraph counted as needing a citation; its raw recall category did not change. Jev’s paragraph-level citation-coverage verdicts were therefore **more repeatable** than either Luna configuration.
>
> We're not concluding that this makes Jev the more accurate judge (the systems applied different support criteria and scoring denominators, and we didn't have time to do independent human labels). But even with xhigh reasoning (which roughly tripled Luna’s model time), it remained less consistent than Jev. The result supports **Jev as a fast, inexpensive, and comparatively repeatable way to implement a narrow citation policy.**
>
> ## Experiment Takeaways and Practical Guide
>
> In some cases, Jev shines as a low-friction alternative to both traditional LLMs and fine-tuned classifiers.  When the baseline is strong (reranking), or it’s easy to fine-tune a smaller model (query classification), the upside is weaker. There are signs of stronger quality for some tasks (model routing) as well as indications of better consistency and stability (citation judge). In some of our most important workloads, it delivers the expected cost and latency wins against traditional LLMs.
>
> The above results give good directional leads, and at Glean, we’re very excited about Jev. After a few more steps (mainly, operational readiness like data residency and guarantees) we plan to ship Jev into some of these use cases. Also, Jev will play a big role in our internal hackathon this week and we’re excited to share more results!
>
> Some general advice to conclude – if the output can be listed in advance, benchmark Jev. If the task and labels are stable and volume is high, benchmark a fine-tuned classifier too. If the call needs to generate a query, explanation, or other dynamic text, keep a generative model in the loop. Tool calling is a good example: Jev can help choose a tool, but most Glean tools still need dynamically generated arguments (like search queries).
>
> Jev does not change the fact that classifiers already existed. It makes a good zero-shot classifier much easier to use. That’s a solid product, even if it’s not a new foundation for every AI system.
>
>
> ### Replies
>
> 4 of 6 replies retrieved in a single call; the other two were not returned.
>
> @founder_talk (Isaac):
> @tonygentilcore And to think this is v1 of Jev.
> date: Mon Sep 28 22:49:20 +0000 2026
> url: https://x.com/founder_talk/status/2104705045015241045
> ---
>
> @Davidariasfin (David Arias, CFA):
> @tonygentilcore Amazing article, specially the tests you did in comparison with a frontier model. In case you are interesting in Rag methods, I've also tested Jev in comparison with 4 LLMs: 
>
> https://t.co/2nktUS2X0s
> >  QT @Davidariasfin:
> > Article: Is Jev efficient for RAG? A test on 10-Ks from Apple, Microsoft, Nvidia and Amazon
> >  https://x.com/Davidariasfin/status/2104338858121060580
> date: Mon Sep 28 23:02:47 +0000 2026
> url: https://x.com/Davidariasfin/status/2104708429080367467
> ---
>
> @cata_fps (confluxi):
> @tonygentilcore @theo task 2
> date: Mon Sep 28 21:13:30 +0000 2026
> url: https://x.com/cata_fps/status/2104680925749784666
> ---
>
> @coopslarhette (hmmmm):
> @tonygentilcore well written article, thanks!
> date: Mon Sep 28 21:31:47 +0000 2026
> url: https://x.com/coopslarhette/status/2104685525890449580
> ---
>
> ### Supporting sources
>
> #### Parallel, "Testing out Jev"
>
> Source: https://parallel.ai/blog/testing-jev - reproduced in full.
>
> Title: Testing out Jev: real-world developer experience
>
> URL Source: https://parallel.ai/blog/testing-jev
>
> Markdown Content:
> # Testing out Jev: real-world developer experience
>
> We got kind of tired of seeing all the Jev hype around [people organizing their inboxes](https://minutes.substack.com/p/tool-shaped-objects), so we decided to test how it would perform on tasks we run billions of times a day. Overall, we were surprised to see Jev deliver impressive zero-shot performance across a range of tasks.
>
> ## First, if you’re not perennially online: what is Jev?
>
> Jev is a [new model from TypeSafe AI](https://docs.typesafe.ai/introduction), marketed as a “[System One](https://docs.typesafe.ai/concepts/system-one)” model for fast, structured decisions. You give it context and questions; it returns categories, scores, and probabilities instead of generating text.
>
> If you’ve used BERT with a classification head, the idea should feel familiar: feed in text, and get scores over labels. Jev lets you specify the question and labels at request time, without fine-tuning a separate classifier for each task.
>
> ![](https://cdn.sanity.io/images/5hzduz3y/production/648f7baea6d0fed94ae7b0cfea2890fe6c3a5795-2880x1200.png)
>
> ## Tests we ran
>
> We mainly tested Jev on search reranking: ordering candidate documents by their relevance to a query. Reranking is one of the core problems in search. We wanted to see how Jev would perform against the fine-tuned rerankers we operate internally.
>
> ![](https://cdn.sanity.io/images/5hzduz3y/production/61cdf8a6a56f934f0cc69459bde61e0e03926594-2880x1200.png)
>
>
>
> Impressively, Jev matched at least one of our custom rerankers on NDCG@10, which measures how well the top 10 results prioritize relevant documents according to our human labels. It also performed competitively on latency against our larger models. Jev had a materially higher cost per document, but we own and maintain much of the inference infrastructure our rerankers run on, giving us meaningful economies of scale. For teams without that infrastructure or scale, Jev is much more likely to be cost competitive once serving costs are included.
>
> We also tested Jev on two common tasks: topic classification (is this document about sports, news, finance, and so on) and query freshness classification (does a search query require recent information?). In both cases, Jev performed less well than our specialized internal models. Topic classification requires choosing from a large set of labels, which was a weakness in our tests. We suspect the freshness task is relatively out of distribution of Jev’s training data.
>
> ---
>
> | Task | What it tests | Performance vs. internal systems |
> | --- | --- | --- |
> | Search reranking | Query–document relevance | NDCG@10 of 0.7: comparable to internal system |
> | Topic classification | Choosing from a large label set | Internal “wins” |
> | Query freshness classification | Whether a query requires recent information | Internal “wins” |
>
> ---
>
> Overall, we were impressed by how close Jev came without task-specific tuning. For teams without a trained classifier, it’s a very strong starting point.
>
> ## What we liked about Jev
>
> If you need a classifier and haven’t already collected data and trained one for your use case, this model is worth a try. It might even be the best place to start. You will still need to check quality on your own examples, but if it works for you, you get to skip model selection, training, hosting, and scaling a model yourself. This is a big win.
>
> Overall, we are excited for Jev. Despite all the talk about LLMs, plenty of useful AI work still comes down to classification and scoring. Those tasks don’t always get much attention. It’s good to see Jev getting people interested in them again.
>
>
> **TL;DR**
>
> - Jev’s strength is useful zero-shot classification and scoring, without task-specific training. It matched or exceeded our trained models in some cases.
> - The headline cost and speed comparisons are against autoregressive LLMs, not dedicated classifiers. Specialized classifiers will still often outperform Jev on cost and speed.
> - Getting useful results out of the box is valuable. Collecting data, training, and serving your own model is real work.
