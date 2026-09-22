---
created: 2026-09-22
source: https://motherduck.com/blog/motherduck-supports-jev/
via: https://x.com/motherduck/status/2102077291081896307
author: MotherDuck (page byline is the company, no individual author credited)
published: 2026-09-21
type: knowledge
tags: [jev, motherduck, duckdb, sql, text-classification, inference-as-operator, ag-news, system-one-models, typesafe]
description: MotherDuck ships prompt_jev(), a first-party SQL function that routes a text column to TypeSafe's Jev and returns a typed decision with calibrated probabilities. The launch benchmark labels 100,000 AG News articles in 40 seconds for $0.50 at 89 percent accuracy against gpt-5.6-terra's 31m59s, $37.58 and 88 percent - 48x faster and 75x cheaper. The benchmark is the weak point (AG News is a 2015 four-class topic task fine-tuned encoders clear at 94-95 percent) and the pricing page, which the blog never cites, meters Jev at 1 AI Unit per 19M input tokens, a 25 percent markup on TypeSafe's own $0.042 per MTok list, under a default 10 AI Unit daily soft cap that the post's own 10M-row test would exceed fivefold.
---

# MotherDuck's prompt_jev labels 100k AG News rows in 40 seconds for 50 cents at 89 percent - a benchmark fine-tuned encoders beat by 5 points, metered at a 25 percent markup over TypeSafe list

*The launch card, also the blog's og:image. Note the "classify a million rows" claim, which appears nowhere in the tweet text or the benchmark table.*
![[motherduck-896307-001.jpg]]

## Key Takeaways

- **The headline numbers hold, and the benchmark they rest on is the easiest one in text classification.** 100,000 rows in 40 seconds for $0.50 at 89 percent, against gpt-5.6-terra at 31m59s, $37.58 and 88 percent, works out to 48x faster and 75x cheaper - close enough to the "~50x faster at ~1% of the cost" framing. The dataset is where it gets thin. AG News is the 2015 four-class news-topic set from Zhang, Zhao and LeCun, and a fine-tuned DistilBERT or RoBERTa sits around 94-95 percent on it at near-zero marginal inference cost. Both Jev (89) and the frontier LLM (88) land five to six points *below* that bar. So "matched frontier LLM accuracy" is true and unimpressive, and the post's own "LLM-style ergonomics with encoder-style efficiency" line invites exactly the encoder comparison the table omits. The defensible claim is about the cost of getting there - no labeled set, no fine-tuning loop, no model to maintain - not about the accuracy reached.
- **"It exceed existing models by >25x across cost, accuracy, and speed dimensions" does not survive the table it sits under.** Cost clears it at 75x over gpt-5.6-terra. Speed clears it at 48x. Accuracy moved one point, 88 to 89, against the strongest baseline and nine points against the weakest. The sentence bundles a one-point delta into a multiplier earned entirely by two other columns.
- **MotherDuck's retail carries a roughly 25 percent markup over TypeSafe list, and the blog never mentions it.** The pricing page meters Jev at 1 AI Unit, which is $1.00, per 19,000,000 input tokens with output free - $0.0526 per MTok against the $0.042 per MTok list price recorded in [[TypeSafe's Jev trades string generation for parallel-sampled typed decisions with calibrated probabilities at $0.042 per MTok - the 193x and 444x claims come from four self-built workflow evals]]. Working the "Retail cost/100k" column backwards: $0.50 is half an AI Unit, so 9.5M input tokens across 100,000 rows, about 95 input tokens per row, and $5 per million rows. That is MotherDuck's own retail, not TypeSafe's and not the LLM vendors' - and whether MotherDuck compute time is billed on top of it is not stated in the post or on the function page.
- **The docs contradict the blog on availability, and the post's own scale claim breaks the default spend cap.** The blog closes with "available on all paid MotherDuck plans." The function page says preview, restricted to organizations in `us-east-1` and `us-west-2`, with the name, parameters and return types subject to change. The pricing page adds a default soft limit of 10 AI Units per day on both Lite and Business. At $5 per million rows the 10M-row test the post mentions in passing costs about 50 AI Units, five times the default daily ceiling, so it cannot run without a support request. The "tests at 1m and 10m rows yielded similar performance (and in some cases even faster)" line also ships without a single number attached.
- **The function is far more typed than the blog's one example shows, and it confirms a quirk the vault had already flagged.** This is not a single-string classifier. `noul` returns a bare calibrated `DOUBLE` probability, `choice` returns `STRUCT(choice, probabilities[], confidence)`, and `score` returns a weighted position on an ordered rubric between 0 and `length-1` alongside its own distribution and confidence. That is TypeSafe's Noul/Choice/Score trio mapped onto SQL return types, plus a `questions` mode that asks many of them against one input in a single request. It also corroborates [[Annabell frames TypeSafe's Jev as a savant for eval verdicts and routing - three question types, 255 choices, 10 score levels, and a Noul with no confidence field]] from a second, independent source: the `noul` path really does return only the probability, with no confidence field beside it, while `choice` and `score` both get one.
- **2,484 rows/s is a batching number, and the docs make batching an accuracy knob rather than a free lunch.** Default `batch_size` is 32 input rows per request, tunable 1 to 64, and MotherDuck warns that "batching can introduce extra variance from sharing a context window across multiple rows," recommending `batch_size := 1` for strict per-row isolation - which its own AI Unit table prices at roughly 4.3x the cost per row. The community Postgres extension in [[pg-jev]] measured this same tradeoff independently and settled on 20, having found batches of 40 falling to 92-98 percent correct and batches of 80 to 77-94. MotherDuck ships a default 60 percent larger than the number pg-jev's author measured his way to, and publishes no accuracy-versus-batch-size curve of its own.
- **Priced against the community extension, the first-party function wins on tokens and hands most of it back on markup.** pg-jev measured about $6 per million rows paying TypeSafe list directly at ~148 input tokens per row; MotherDuck reaches $5 per million at ~95 tokens per row while charging 25 percent more per token. Token efficiency is doing the work, and part of that is simply that AG News articles are shorter than pg-jev's test rows. The strategic point is the one [[Josh Rosen's Jev in the Wild sorts week-one projects into routing, context filtering, tool gating, worker supervision, fast control loops and fuzzy data queries - deterministic only because inference was expensive]] filed under fuzzy data queries: he listed `duckdb-jev`, a community DuckDB extension, and a week later the vendor shipped the same primitive first-party with a bind-time validated signature and a billing meter. That is the warehouse absorbing the extension, exactly the trajectory [[Snowflake, Databricks and ClickHouse preview AI architecture by turning inference into a database operator, the semantic layer into agent infrastructure, and agents into a new database workload]] forecast.
- **The company arguing sophistication is a cost is now shipping inference inside the query plan.** [[MotherDuck's Simon Spati splits semantic layer from context layer by what compiles to SQL, and argues sophistication is a cost not a default]] ran on this same blog three weeks earlier. `prompt_jev` is defensible on exactly those grounds - a scalar function with a typed return is about as unsophisticated as this gets, and it compiles to SQL - but it also plants a model call where a `WHERE` clause can invoke it once per predicate evaluation unless you remember `AS MATERIALIZED`. The docs flag that twice, which is a good sign about the docs and a fair warning about the cost model. Read alongside [[Berkeley's EPIC Data Lab argues near-free intelligence makes agents the dominant data-systems workload, needing data systems for, of, and by agents]], whose thesis this launch is a direct data point for.

## The Function

`prompt_jev` sends a text value and a question to a TypeSafe Jev model and returns a typed decision with calibrated probabilities. It answers closed questions only and never returns free text; MotherDuck's separate `prompt()` function covers generated text, open-ended extraction and model-filled schemas. It runs against the `jev-latest` model alias, with no model parameter.

**Signature.** Five forms. `input` and `instructions` are positional, everything else is named:

```sql
prompt_jev(input, instructions)
prompt_jev(input, instructions, noul := criteria)
prompt_jev(input, instructions, choice := criteria)
prompt_jev(input, instructions, score := criteria)
prompt_jev(input, questions := questions)
```

`choice`, `score` and `noul` are mutually exclusive and none combine with `questions`. Omitting all three runs a `noul` question. Every argument except `input` must be a query constant - MotherDuck validates them and resolves the return type while binding the query, before the first row is read.

**Parameters.** `input` (`VARCHAR`, required, the only argument that can vary per row, must come first). `instructions` (`VARCHAR`, a non-empty constant, required unless `questions` is supplied). `noul` (yes/no; if supplied must contain exactly the labels `true` and `false`). `choice` (between 2 and 255 unique non-empty labels). `score` (between 2 and 10 ordered levels; array position defines the scale, lowest to highest). `questions` (`STRUCT` or `JSON`, several questions against the same input in one request). `batch_size` (`INTEGER` 1 to 64, default 32, single-question mode only). Criteria accept either a plain label array or `STRUCT(label VARCHAR, description VARCHAR)[]`; descriptions are input metadata that help the model separate similar labels and never change the returned value.

**Return shapes.** This is the part the blog post skips entirely:

| Question type | Returns |
|---|---|
| `noul` | `DOUBLE` between 0 and 1 - the calibrated probability the statement in `instructions` holds. No confidence field. |
| `choice` | `STRUCT(choice VARCHAR, probabilities STRUCT(value VARCHAR, probability DOUBLE)[], confidence DOUBLE)` |
| `score` | `STRUCT(score DOUBLE, probabilities STRUCT(index UINTEGER, value VARCHAR, probability DOUBLE)[], confidence DOUBLE)` |

A `score` rubric of `['low','medium','high']` returns a weighted position between 0 and 2, so 1.4 sits between medium and high. TypeSafe's six task categories map onto the three types: classification to `choice`; detection and verification to `noul`; scoring to `score`; ranking to `score` or `noul`; structured extraction to one `choice` or `score` per field via `questions`, but only where the possible values are known up front. For extraction with unknown values, the docs send you to `prompt` with a struct or JSON schema instead.

**The blog's example**, pulling a main complaint out of a table of support transcripts:

```sql
SELECT
    conversation_id,
    prompt_jev(
        transcript,
        'Identify the customer''s main complaint',
        choice := [
{label: 'billing', description: 'Payments, invoices, and refunds'},
{label: 'technical', description: 'Errors, outages, and integrations'},
{label: 'sales', description: 'Pricing and upgrades'},
{label: 'account', description: 'Cancellations and account administration'}
	  ]
    ) AS classification
FROM customer_conversations;
```

**Multi-question mode.** `questions` asks several things about one input in a single request and returns a named `STRUCT` with one field per question, each in its own type's normal return shape. The tradeoff is explicit in the docs: the request carries `input` once for the whole set, "so asking twenty things at once costs far fewer input tokens than twenty single-question queries over the same table, at the price of losing row batching." A JSON escape hatch passes arbitrary nested criteria straight through to TypeSafe, at the cost of `score` probabilities coming back as `JSON` rather than the native struct.

**Error behavior.** Argument problems fail the query at bind time, before any row is processed - including the plan gate, `AI functions are not available for your organization.`, which fires on the Free plan or with AI functions disabled. Per-row failures return `NULL` rather than failing the query: a `NULL` input sends no request, and a request that still fails after retries or hits the AI function timeout yields `NULL`. The exception is a `questions` call that fails TypeSafe validation, including an HTTP 422, which errors the whole query.

## The Benchmark

MotherDuck benchmarked 100,000 articles sampled from the training split of [AG News](https://huggingface.co/datasets/fancyzhx/ag_news), the four-class news-topic dataset introduced by [Zhang, Zhao & LeCun (2015)](https://arxiv.org/abs/1509.01626), scoring each model against the ground truth. The four classes are World, Sports, Business and Sci/Tech.

| model | rows/s | accuracy | Retail cost/100k | wall time at 100k rows |
| :---- | ----: | ----: | ----: | ----: |
| **Jev** | **2,484** | **89%** | **$0.50** | **40s** |
| gpt-4o-mini | 84 | 80% | $1.93 | 19m 45s |
| gpt-5-nano | 94 | 83% | $1.58 | 17m 49s |
| gpt-5.6-luna | 61 | 84% | $3.53 | 27m 25s |
| gpt-5.6-terra | 52 | 88% | $37.58 | 31m 59s |

Verbatim on the scaling claim: "What really excited us was that it exceed existing models by >25x across cost, accuracy, and speed dimensions. Furthermore, tests at 1m and 10m rows yielded similar performance (and in some cases even faster than our baseline presented above)." No numbers accompany the 1m and 10m runs.

Derived from the table: 48.0x wall-clock speedup and 75.2x cost reduction against gpt-5.6-terra; 29.6x speedup and 3.9x cost reduction against gpt-4o-mini, the cheapest baseline. The accuracy spread across all five models is nine points, and across Jev and the two strongest baselines it is five.

**Reproduction SQL**, verbatim from the post's collapsed appendix. It loads AG News straight from Hugging Face over `hf://`, samples 100k with a seeded reservoir, classifies, then scores accuracy, per-class precision/recall/F1 and a confusion matrix. Note `result.choice` and `result.confidence` - the `choice` struct fields - and that NULLs are "reported separately, never scored as wrong":

```sql
-- 1) Load AG News (train split) straight from Hugging Face and draw the 100k sample
CREATE TABLE ag_train AS
SELECT row_number() OVER () AS id, text, label
FROM 'hf://datasets/fancyzhx/ag_news/data/train-00000-of-00001.parquet';

CREATE TABLE sample_100k AS
SELECT * FROM ag_train USING SAMPLE 100000 ROWS (reservoir, 43);

-- 2) Classify every row with prompt_jev
CREATE TABLE preds AS
SELECT id, label,
       prompt_jev(text,
                  'Classify the topic of this news article.',
                  choice := ['World', 'Sports', 'Business', 'Sci/Tech']) AS result
FROM sample_100k;

-- 3) Score against the dataset labels
CREATE MACRO ag_name(l) AS ['World', 'Sports', 'Business', 'Sci/Tech'][l + 1];

-- overall accuracy (NULLs reported separately, never scored as wrong)
SELECT count(*)                                              AS n,
       count(*) FILTER (WHERE result.choice IS NULL)         AS nulls,
       round(avg((result.choice = ag_name(label))::INT), 4)  AS accuracy,
       round(avg(result.confidence), 3)                      AS mean_confidence
FROM preds;
```

The appendix continues with per-class precision/recall/F1 and a `PIVOT` confusion matrix, both reproduced in full in the Original Content section below.

**What the benchmark does not report.** No encoder baseline, despite the post naming BERT three times as the alternative it is displacing. No confusion matrix or per-class numbers for the actual run, only the SQL that would produce them. No NULL rate, though the scoring query is built to track one and NULLs are excluded from the accuracy denominator. No batch size for the Jev row and no concurrency figure behind 2,484 rows/s. No statement of whether the LLM baselines were batched or parallelised at all, which matters a great deal: 52 to 94 rows/s is consistent with modestly parallel calls, and the speed multiplier is only meaningful if both sides were tuned.

## Pricing and Availability

**The blog's claim, verbatim:** "`prompt_jev()` is available on all paid MotherDuck plans. Pick a question you've been putting off and try it on your own data!"

**The function docs, verbatim:** "`prompt_jev` is in preview. It is available only to organizations in the `us-east-1` and `us-west-2` regions. The function name, parameters, and return types may change."

**The meter.** Consumption is measured in AI Units, and 1 AI Unit = $1.00. Jev appears on the pricing page under Classification Models at 1 AI Unit per 19,000,000 input tokens, output free, with the note "Only input tokens are metered." That works out to $0.0526 per MTok against TypeSafe's own $0.042 per MTok list price - about a 25 percent markup. Lite and Business plans carry a default soft limit of 10 AI Units per day on Advanced AI Functions, which support can raise or remove.

The function docs express the same meter as rows per AI Unit, assuming 40-character instructions and four 10-character labels:

| Question | Input length | Rows per AI Unit |
|---|---|---|
| `noul` | 50 characters | ~345,000 |
| `choice` | 50 characters | ~260,000 |
| `choice`, `batch_size := 1` | 50 characters | ~60,000 |
| `choice` | 1,000 characters | ~60,000 |
| `score` | 1,000 characters | ~60,000 |

Two things fall out of that table. Dropping to `batch_size := 1` costs roughly 4.3x more per row than the default 32, which puts a price on the "strict per-row isolation" recommendation. And the benchmark's implied ~200,000 rows per AI Unit sits between the 50-character and 1,000-character `choice` rows, which is consistent with AG News article lengths. That is the one internal cross-check available on the cost claim, and it passes.

## Replies

Seven replies, matching the seven the post reports. A cursor for an eighth page was returned but the follow-up fetch hit an HTTP 429, so the count is complete against the reported total rather than against the cursor. **No reply from @motherduck, MotherDuck staff, or @typesafeai appears in the thread** - including under the one question that deserved an answer.

**The substantive ones:**

- **Matt Berg (@mberg)** asks the question the launch leaves hanging: "Are you releasing this as a Duckdb extension too? I know your team was working on it. I've built a similar extension but would prefer to use yours if it will become available to duckdb too." This is the community-versus-first-party tension in one sentence. `prompt_jev` is a MotherDuck cloud function, not open-source DuckDB, so the local-DuckDB story is still `duckdb-jev` and Berg's own extension. It went unanswered.
- **Steven (@witwall)** posts a competing shape from `duckdb_luajit`, decomposing the single struct-returning call into separate scalar accessors so confidence becomes a plain predicate: `SELECT id, jev_choice(raw,'team') AS team, jev_p(raw,'team','billing') AS p_billing, jev_conf(raw,'team') AS conf FROM decisions WHERE jev_ok(raw) AND jev_conf(raw,'team') >= 0.8;`. Worth contrasting with MotherDuck's design, where one call returns a struct and you reach into `.confidence` - and where the docs have to warn you to say `AS MATERIALIZED` so the model is not re-invoked per field read. The decomposed form makes that hazard structural rather than a documentation note.
- **Buswe (@buswe_com)** offers the migration check the post does not: "Running it on a 1k-row sample next to your existing LLM labels gives a quick agreement check before classifying the full table." That is the right move given the benchmark's single easy dataset.
- **Gursers (@0xGurs)** replies only "@motherduck @heyjevbook is this accurate?", tagging a Jev-focused account rather than asking anything specific. No answer.

**Low-signal reactions, captured verbatim below but not summarized here:** @The1Broom ("about to quietly replace a lot of CASE WHEN statements"), @razaaitech, and @bensicard - three in total, all approving one-liners with no technical content.

## Related

**Jev ecosystem.** [[moc - Jev]] is the hub. The model itself is [[TypeSafe's Jev trades string generation for parallel-sampled typed decisions with calibrated probabilities at $0.042 per MTok - the 193x and 444x claims come from four self-built workflow evals]]. The closest sibling is [[pg-jev]], the community Postgres extension that built the same operator from outside the engine and published far more measurement than this launch does. [[jegrep]] is the same shape applied to code search, and [[Grep AI's AgentRun runs an AML alert once on a Pi agent, then compiles the trace into a DSL program whose decisions are typed Jev questions - 826 tool calls and 51 minutes become 30 and 3 minutes]] compiles agent traces into typed Jev questions much as this compiles a classification pass into a scalar function. [[Daniel Ch's How to master Jev prescribes a 0.85 and 0.55 confidence-gate ladder under an LLM that still writes - the decision-layer architecture is additive but every number and all three charts are TypeSafe's own]] names the "giant dataset job" archetype that `prompt_jev` productizes, and its confidence-gate ladder is directly implementable here now that `choice` and `score` return a `confidence` field.

**Data systems.** [[Snowflake, Databricks and ClickHouse preview AI architecture by turning inference into a database operator, the semantic layer into agent infrastructure, and agents into a new database workload]] and [[Josh Rosen's Jev in the Wild sorts week-one projects into routing, context filtering, tool gating, worker supervision, fast control loops and fuzzy data queries - deterministic only because inference was expensive]] both predicted this function, the latter by name via `duckdb-jev`. [[Berkeley's EPIC Data Lab argues near-free intelligence makes agents the dominant data-systems workload, needing data systems for, of, and by agents]] supplies the underlying thesis. [[MotherDuck's Simon Spati splits semantic layer from context layer by what compiles to SQL, and argues sophistication is a cost not a default]] is the same publisher's own framing, three weeks earlier. [[Databricks Genie pushes data agents past coding-agent baselines via specialized knowledge search, parallel thinking, and multi-LLM design]] is the competing warehouse betting on an agent rather than an operator.

**Classification economics.** [[BARGAIN routes classification to a small model via a confidence threshold calibrated on 500 oracle labels, cutting costs up to 86 percent more than competing cascades]] is the calibrated-cascade alternative to paying for every row, and it is close to what a `noul` threshold plus a second LLM pass would build on top of this function. [[Bridgewater and Thinking Machines fine-tune Qwen3-235B to replicate expert investor judgment, beating frontier LLMs on financial information-filtering at 13.8x lower cost]] is the fine-tuning path this post argues against, with numbers on the other side. [[LangChain's Jev-as-a-Judge bench puts Jev's quality-score variance 92 to 913x below three LLM judges at $0.34 against Claude's $28.17 - five weather traces, one human oracle, provider-default sampling]] is the same cost-per-verdict comparison run by a third party rather than a vendor. [[Featherless's Simple Jev reproduces Jev's API on stock open models by remapping every answer to a single-token letter and softmaxing only those logits - no classifier head, and the code stamps every answer calibrated False]] is the open reimplementation, and the contrast is sharp: MotherDuck sells calibrated probabilities as the product, while Simple Jev stamps every answer `calibrated: False`.

## Links

- [Introducing prompt_jev(): bringing Jev to Motherduck SQL](https://motherduck.com/blog/motherduck-supports-jev/) - the launch post
- [@motherduck announcement tweet](https://x.com/motherduck/status/2102077291081896307) - 2026-09-21
- [MotherDuck docs on prompt_jev](http://motherduck.com/docs/sql-reference/motherduck-sql-reference/ai-functions/prompt-jev/) - the full function reference
- [Example text classification how-to](https://motherduck.com/docs/key-tasks/ai-and-motherduck/classify-text-with-prompt-jev/) - linked from the post's Further Reading
- [MotherDuck AI Functions index](https://motherduck.com/docs/sql-reference/motherduck-sql-reference/ai-functions/) - siblings are SQL Assistant, EMBEDDING and PROMPT
- [MotherDuck pricing, AI function section](https://motherduck.com/docs/about-motherduck/billing/pricing) - the AI Unit meter and the 10-unit daily soft limit
- [TypeSafe: Introducing system one models and Jev](https://typesafe.ai/blog/introducing-system-one-models-and-jev) - the model launch this post integrates
- [AG News on Hugging Face](https://huggingface.co/datasets/fancyzhx/ag_news) - the benchmark dataset
- [Zhang, Zhao & LeCun (2015)](https://arxiv.org/abs/1509.01626) - the paper that introduced it
- [github.com/colliber/duckdb-jev](https://github.com/colliber/duckdb-jev) - the community DuckDB extension this function supersedes

## Original Content

> [!quote]- Source Material - tweet, blog post, docs page, and replies (verbatim)
>
> #### Tweet: @motherduck, 2026-09-21
>
> @motherduck (MotherDuck):
> Text classification in MotherDuck just got ~50x faster at ~1% of the cost.
>
> prompt_jev() is a SQL function powered by Jev, TypeSafe's new system one model. 100k rows: 40s, $0.50, frontier-LLM accuracy. The LLM took 32 min and $37.
>
> Read on:
>
> https://t.co/XIE2cw6rUS https://t.co/CdP1q8OwDe
> PHOTO: https://pbs.twimg.com/media/HSwUH3TbAAAdWbK.jpg
> date: Mon Sep 21 16:47:35 +0000 2026
> url: https://x.com/motherduck/status/2102077291081896307
> likes: 183  retweets: 16  replies: 7
>
> The two `t.co` links resolve to https://motherduck.com/blog/motherduck-supports-jev/ and to the attached photo.
>
> *The attached photo, 1600x893. It is the same asset as the blog's og:image (`prompt_jev_1600x893_10f1baca62.jpg`, identical dimensions), so one file is stored for both sources rather than two. It reads: "INTRODUCING PROMPT_JEV()" over "CLASSIFY A MILLION ROWS IN SQL. 50X FASTER AT 1% THE COST.", on a teal ground, with the MotherDuck duck stamping coloured labels into one column of a six-column table of grey placeholder rows, a yellow lightning bolt beside it, and a yellow footer band repeating "AI ENGINEERING". Every number on the card is the tweet's; the "a million rows" framing is not, and appears in neither the tweet text nor the benchmark table, which tops out at 100,000 rows.*
> ![[motherduck-896307-001.jpg]]
>
> ---
>
> #### Blog: Introducing prompt_jev() - bringing Jev to Motherduck SQL
>
> Title: Introducing prompt_jev(): bringing Jev to Motherduck SQL
>
> URL Source: https://motherduck.com/blog/motherduck-supports-jev/
>
> Markdown Content:
> ---
> title: "Introducing prompt_jev(): bringing Jev to Motherduck SQL"
> canonical: "https://motherduck.com/blog/motherduck-supports-jev/"
> ---
>
> # Introducing prompt_jev(): bringing Jev to Motherduck SQL
>
> Text classification in MotherDuck just got about 50x faster at about 1% of the cost. Today we're shipping an integration with [Jev](https://typesafe.ai/blog/introducing-system-one-models-and-jev), a new kind of AI model from TypeSafe AI. On a 100,000-row benchmark it matched frontier LLM accuracy in 40 seconds for fifty cents. The comparable LLM took more than half an hour and cost $37. When price gets that low and performance is this good, entire tables that were too expensive to handle are easily within reach. 
>
> TypeSafe describes the state of AI today as "databases before SQL”, where we first need to understand the database before we can build the universal language on top. Their pitch for Jev is a frontier-intelligence function call: unstructured state goes in, typed probabilistic decisions come out. We read that and thought, well, this fits right into the universal language of SQL. It can be framed as a function that takes a text column and hands back a label, a score, or a yes/no with a confidence score - exactly how scalar functions today. There is no need to parse the response, and so it's immediately ready to filter, join, and aggregate in the same statement.
>
> This combination of speed, accuracy, and cost together is what makes new workloads viable. LLMs can already classify text, but running it across a million rows is slow enough and expensive enough it is hard to see the value. The alternative, training an encoder like BERT, means collecting labeled examples and maintaining your own model. This is a big bet for something that may not work until it’s close to prod ready. `prompt_jev()` is configured with a few sentences, runs at analytics speed, and is extremely cost effective for the rows it labels. Below, it pulls the main complaint out of a table of support transcripts:
>
>
> ```sql
> SELECT
>     conversation_id,
>     prompt_jev(
>         transcript,
>         'Identify the customer''s main complaint',
>         choice := [
> {label: 'billing', description: 'Payments, invoices, and refunds'},
> {label: 'technical', description: 'Errors, outages, and integrations'},
> {label: 'sales', description: 'Pricing and upgrades'},
> {label: 'account', description: 'Cancellations and account administration'}
> 	  ]
>     ) AS classification
> FROM customer_conversations;
> ```
>
> We think this is a very big deal for analytics. A database is, after all, an excellent place to store your million customer conversations. But it’s still really hard to figure out what your customers are complaining about. Before you can track which problems are getting worse, someone or something has to read those conversations and label them. Encoder models like BERT can efficiently classify over a large dataset, but first you have to collect labeled examples, fine-tune the model, and improve the model as new data comes in. This takes patience and expertise. On the other hand, LLMs enable you to just prompt for what you want instead, but running one across a meaningfully large dataset is slow, expensive, and error-prone.
>
> `prompt_jev()` gives you LLM-style ergonomics with encoder-style efficiency, all at analytics scale. Here are some comparisons that made us excited:
>
> | model | rows/s | accuracy | Retail cost/100k | wall time at 100k rows | 
> | :---- | ----: | ----: | ----: | ----: |
> | **Jev** | **2,484** | **89%** | **$0.50** | **40s** |
> | gpt-4o-mini | 84 | 80% | $1.93 | 19m 45s |
> | gpt-5-nano | 94 | 83% | $1.58 | 17m 49s |
> | gpt-5.6-luna | 61 | 84% | $3.53 | 27m 25s |
> | gpt-5.6-terra | 52 | 88% | $37.58 | 31m 59s |
>
>
> _We benchmarked on 100,000 articles sampled from the training split of [AG News](https://huggingface.co/datasets/fancyzhx/ag_news), the four-class news topic dataset introduced by [Zhang, Zhao & LeCun (2015)](https://arxiv.org/abs/1509.01626), scoring each model against the ground truth._
>
> What really excited us was that it exceed existing models by >25x across cost, accuracy, and speed dimensions. Furthermore, tests at 1m and 10m rows yielded similar performance (and in some cases even faster than our baseline presented above).
>
> >   
> `prompt_jev()` is available on all paid MotherDuck plans. Pick a question you’ve been putting off and try it on your own data\!
>
> ## Further Reading
>
> * [MotherDuck docs on `prompt_jev`](http://motherduck.com/docs/sql-reference/motherduck-sql-reference/ai-functions/prompt-jev/)
> * [Example test classification](https://motherduck.com/docs/key-tasks/ai-and-motherduck/classify-text-with-prompt-jev/)
>
> <details>
>
> <summary>   And if you need some inspiration - run the benchmark yourself!</br></summary>
>
> ```sql
> -- 1) Load AG News (train split) straight from Hugging Face and draw the 100k sample
> CREATE TABLE ag_train AS
> SELECT row_number() OVER () AS id, text, label
> FROM 'hf://datasets/fancyzhx/ag_news/data/train-00000-of-00001.parquet';
>
> CREATE TABLE sample_100k AS
> SELECT * FROM ag_train USING SAMPLE 100000 ROWS (reservoir, 43);
>
> -- 2) Classify every row with prompt_jev
> CREATE TABLE preds AS
> SELECT id, label,
>        prompt_jev(text,
>                   'Classify the topic of this news article.',
>                   choice := ['World', 'Sports', 'Business', 'Sci/Tech']) AS result
> FROM sample_100k;
>
> -- 3) Score against the dataset labels
> CREATE MACRO ag_name(l) AS ['World', 'Sports', 'Business', 'Sci/Tech'][l + 1];
>
> -- overall accuracy (NULLs reported separately, never scored as wrong)
> SELECT count(*)                                              AS n,
>        count(*) FILTER (WHERE result.choice IS NULL)         AS nulls,
>        round(avg((result.choice = ag_name(label))::INT), 4)  AS accuracy,
>        round(avg(result.confidence), 3)                      AS mean_confidence
> FROM preds;
>
> -- per-class precision, recall, F1
> WITH c AS (
>   SELECT ag_name(label) AS truth, result.choice AS pred FROM preds WHERE result.choice IS NOT NULL
> ), k AS (SELECT unnest(['World', 'Sports', 'Business', 'Sci/Tech']) AS class)
> SELECT class,
>        count(*) FILTER (WHERE truth = class AND pred = class) AS tp,
>        count(*) FILTER (WHERE truth <> class AND pred = class) AS fp,
>        count(*) FILTER (WHERE truth = class AND pred <> class) AS fn,
>        round(tp / (tp + fp), 4) AS "precision",
>        round(tp / (tp + fn), 4) AS recall,
>        round(2 * tp / (2 * tp + fp + fn), 4) AS f1
> FROM k CROSS JOIN c GROUP BY class ORDER BY class;
>
> -- confusion matrix
> PIVOT (SELECT ag_name(label) AS truth, result.choice AS pred FROM preds)
> ON pred USING count(*) GROUP BY truth ORDER BY truth;
> ```
>
> ---
>
> #### Docs: prompt_jev
>
> Title: PROMPT_JEV
>
> URL Source: http://motherduck.com/docs/sql-reference/motherduck-sql-reference/ai-functions/prompt-jev/
>
> Markdown Content:
> # PROMPT_JEV
> > Classify, score, and test text in SQL with the prompt_jev function and calibrated probabilities.
> ## prompt_jev function
>
> The `prompt_jev` function sends a text value and a question to a [TypeSafe](/integrations/data-science-ai/typesafe/) Jev model and returns a typed decision: a probability, a choice from a fixed list, or a position on an ordered scale. Every answer carries calibrated probabilities, so you can act on the decision and on how certain the model is about it.
>
> `prompt_jev` answers closed questions. It never returns free text. Use [`prompt`](/sql-reference/motherduck-sql-reference/ai-functions/prompt/) when you need generated text, open-ended extraction, or a schema the model fills in itself.
>
> :::info[Preview]
> `prompt_jev` is in [preview](/about-motherduck/feature-stages/). It is available only to organizations in the `us-east-1` and `us-west-2` [regions](/about-motherduck/cloud-regions/). The function name, parameters, and return types may change.
> :::
>
> Consumption is measured in [AI Units](/about-motherduck/billing/pricing#ai-function-pricing). One AI Unit covers approximately:
>
> | **Question** | **Input length** | **Rows per AI Unit** |
> |---|---|---|
> | `noul` | 50 characters | ~345,000 |
> | `choice` | 50 characters | ~260,000 |
> | `choice`, `batch_size := 1` | 50 characters | ~60,000 |
> | `choice` | 1,000 characters | ~60,000 |
> | `score` | 1,000 characters | ~60,000 |
>
> These estimates assume 40-character instructions and four 10-character labels for `choice` and `score`.
>
> ## Syntax
>
> ```sql
> prompt_jev(input, instructions)
> prompt_jev(input, instructions, noul := criteria)
> prompt_jev(input, instructions, choice := criteria)
> prompt_jev(input, instructions, score := criteria)
> prompt_jev(input, questions := questions)
> ```
>
> `input` and `instructions` are positional. `choice`, `score`, `noul`, `questions`, and `batch_size` must be named:
>
> ```sql
> SELECT prompt_jev(
>     message,
>     'Which team should handle this?',
>     choice := ['billing', 'technical', 'sales']
> )
> FROM support_messages;
> ```
>
> `choice`, `score`, and `noul` are mutually exclusive, and none of them can be combined with `questions`. Omitting all of `choice`, `score`, and `noul` runs a `noul` question.
>
> ### Parameters
>
> | **Parameter** | **Type** | **Required** | **Description** |
> |---|---|---|---|
> | `input` | `VARCHAR` | Yes | The text to evaluate. This is the only argument that can vary per row. Must be the first argument. |
> | `instructions` | `VARCHAR` | Conditional | The question the model answers. A non-empty constant. Required unless `questions` is supplied. |
> | `noul` | `VARCHAR[]` or `STRUCT(label VARCHAR, description VARCHAR)[]` | No | Runs a yes/no question. The default when `choice`, `score`, and `noul` are all omitted. If supplied, must contain exactly the labels `true` and `false`. |
> | `choice` | `VARCHAR[]` or `STRUCT(label VARCHAR, description VARCHAR)[]` | Conditional | Between 2 and 255 unique, non-empty labels to pick from. |
> | `score` | `VARCHAR[]` or `STRUCT(label VARCHAR, description VARCHAR)[]` | Conditional | Between 2 and 10 unique, non-empty levels. Array position defines the order, lowest to highest. |
> | `questions` | `STRUCT` or `JSON` | Conditional | Runs several questions against the same `input` in one request. See [Multiple questions](#multiple-questions). Not combined with `instructions`, `choice`, `score`, or `noul`. |
> | `batch_size` | `INTEGER` | No | How many non-`NULL` input rows to send per request, from 1 to 64. Defaults to 32. Only valid in single-question mode. See [Automatic batching](#automatic-batching). |
>
> Every argument except `input` must be a constant for the query. MotherDuck validates them and resolves the return type while binding the query, before the first row is read.
>
> Labels must be unique and non-empty. Descriptions may be `NULL` or a non-empty string:
>
> ```sql
> -- Labels only
> ['low', 'medium', 'high']
>
> -- Labels with optional descriptions
> [
>     {label: 'low', description: 'Can wait several days'},
>     {label: 'medium', description: NULL},
>     {label: 'high', description: 'Requires immediate action'}
> ]
> ```
>
> Descriptions are input metadata that helps the model tell similar labels apart. They don't change the returned `value`, which is always the label.
>
> ### Question types
>
> Each question type has its own return type.
>
> #### noul
>
> Answers "is this true?" and returns a `DOUBLE` between 0 and 1: the calibrated probability that the statement in `instructions` holds for `input`.
>
> ```sql
> SELECT prompt_jev(
>     'The payment has failed for three days and nobody has replied.',
>     'Does this describe an urgent problem?'
> ) AS urgency;
> ```
>
> ```text
> 0.93
> ```
>
> Pass `noul` with explicit labels only to attach descriptions to `true` and `false`; the labels-only form `noul := ['true', 'false']` is equivalent to omitting `noul` entirely:
>
> ```sql
> SELECT prompt_jev(
>     message,
>     'Does this request a refund?',
>     noul := [
>         {label: 'true', description: 'The customer asks for money back'},
>         {label: 'false', description: 'No refund is requested'}
>     ]
> ) AS refund_probability;
> ```
>
> #### choice
>
> Answers "which of these options?" and returns a `STRUCT`:
>
> ```text
> STRUCT(
>     choice        VARCHAR,
>     probabilities STRUCT(value VARCHAR, probability DOUBLE)[],
>     confidence    DOUBLE
> )
> ```
>
> - `choice` is one of the labels you passed in `choice`.
> - `probabilities` has one entry per label, in the order you supplied them.
> - `confidence` is between 0 and 1 and describes how certain the model is about the winning option.
>
> ```sql
> SELECT prompt_jev(
>     'I was charged twice for last month and the invoice does not match.',
>     'Which team should handle this?',
>     choice := ['billing', 'technical', 'sales']
> ) AS routing;
> ```
>
> ```text
> {'choice': billing, 'probabilities': [{'value': billing, 'probability': 0.94}, {'value': technical, 'probability': 0.04}, {'value': sales, 'probability': 0.02}], 'confidence': 0.91}
> ```
>
> Descriptions help the model disambiguate labels that read as similar:
>
> ```sql
> SELECT prompt_jev(
>     message,
>     'Which team should handle this?',
>     choice := [
>         {label: 'billing', description: 'Payments, invoices, and refunds'},
>         {label: 'technical', description: 'Errors, outages, and integrations'},
>         {label: 'sales', description: 'Pricing, trials, and upgrades'}
>     ]
> ) AS routing
> FROM support_messages;
> ```
>
> #### score
>
> Answers "which level?" against an ordered rubric and returns a `STRUCT`:
>
> ```text
> STRUCT(
>     score         DOUBLE,
>     probabilities STRUCT(index UINTEGER, value VARCHAR, probability DOUBLE)[],
>     confidence    DOUBLE
> )
> ```
>
> - `score` is a weighted position on the scale, between `0` and `length(score) - 1`. A rubric of `['low', 'medium', 'high']` returns a value between 0 and 2, and a value of `1.4` sits between `medium` and `high`.
> - `probabilities` has one entry per level, ordered by `index`, with `index` the zero-based position of the level and `value` its label.
> - `confidence` is between 0 and 1.
>
> Order the levels from lowest to highest. The array position defines the scale.
>
> ```sql
> SELECT prompt_jev(
>     'The product is unusable and we are considering cancelling.',
>     'Rate the severity of this message.',
>     score := ['low', 'medium', 'high']
> ) AS severity;
> ```
>
> ```text
> {'score': 1.82, 'probabilities': [{'index': 0, 'value': low, 'probability': 0.02}, {'index': 1, 'value': medium, 'probability': 0.14}, {'index': 2, 'value': high, 'probability': 0.84}], 'confidence': 0.88}
> ```
>
> ### Which type to use
>
> TypeSafe groups decisions into six task categories. Each maps onto one of the three question types.
>
> | **Task** | **Type** | **Example** |
> |---|---|---|
> | Classification | `choice` | Route a ticket to a team, label a topic, pick a risk category |
> | Detection | `noul` | Flag spam, fraud, or a prompt injection attempt |
> | Scoring | `score` | Rate severity, content quality, or customer frustration |
> | Ranking | `score` or `noul` | Order candidates by semantic fit using the returned number |
> | Verification | `noul` | Check a citation, a policy rule, or an answer for a known failure mode |
> | Structured extraction | `choice` or `score` per field | One [`questions`](#multiple-questions) call per row, where the possible values are known up front |
>
> For extraction where the values are not known up front, use [`prompt`](/sql-reference/motherduck-sql-reference/ai-functions/prompt/) with a `struct` or `json_schema` instead.
>
> ## Multiple questions
>
> Ask several questions about the same `input` in a single request with `questions`. Every question needs a non-empty `instructions` string, a `type` of `noul`, `choice`, or `score`, and valid `criteria` when its type requires them:
>
> ```sql
> SELECT prompt_jev(
>     message,
>     questions := {
>         refund: {
>             type: 'noul',
>             instructions: 'Does this request a refund?'
>         },
>         category: {
>             type: 'choice',
>             instructions: 'Classify the primary subject.',
>             criteria: ['billing', 'technical', 'other']
>         },
>         urgency: {
>             type: 'score',
>             instructions: 'How urgent is this?',
>             criteria: ['low', 'medium', 'high']
>         }
>     }
> ) AS answer
> FROM support_messages;
> ```
>
> The result is a named `STRUCT` with one field per question, each in its question type's normal return shape:
>
> ```sql
> SELECT
>     answer.refund,
>     answer.category.choice,
>     answer.category.confidence,
>     answer.urgency.score
> FROM classified;
> ```
>
> `batch_size` is only available in single-question mode; `questions` calls send one request per input row. That request carries `input` once for the whole set, so asking twenty things at once costs far fewer input tokens than twenty single-question queries over the same table, at the price of losing row batching.
>
> ### JSON escape hatch
>
> Pass `questions` as a `JSON` string to reach parts of the TypeSafe API that the native `STRUCT` form doesn't cover, such as structured or omitted `instructions`, or criteria described with arbitrary nested JSON:
>
> ```sql
> SELECT prompt_jev(
>     message,
>     questions := '{
>       "category": {
>         "type": "choice",
>         "instructions": {
>           "question": "Classify the primary subject",
>           "focus": ["primary intent", "requested action"]
>         },
>         "criteria": {
>           "billing": {
>             "description": "Charges and invoices",
>             "examples": ["duplicate charge", "missing invoice"]
>           },
>           "technical": "Bugs and integrations"
>         }
>       }
>     }'::JSON
> ) AS answer
> FROM support_messages;
> ```
>
> MotherDuck inspects the constant JSON only to determine the SQL return type; the question configuration itself is passed to TypeSafe for validation. For `score` criteria described as arbitrary JSON, `probabilities` comes back as `JSON` rather than the native `STRUCT(index, value, probability)[]` shape. Native `score` criteria — a plain array of labels or label/description structs — always return `probabilities` in the native shape with labels as `VARCHAR`.
>
> A TypeSafe validation failure, including an HTTP 422 response, fails the query as an error rather than returning `NULL` for the row.
>
> ## Automatic batching
>
> Native single-question calls automatically batch input rows into fewer requests. The default is 32 rows per request. The optional `batch_size` argument can be used to adjust the batch size:
>
> ```sql
> SELECT prompt_jev(
>     message,
>     'Does this request a refund?',
>     batch_size := 16
> )
> FROM messages;
> ```
>
> `batch_size` must be between 1 and 64; MotherDuck may still send a smaller batch when a request would otherwise exceed TypeSafe's request-size limit.
>
> Larger batches improve throughput and lower cost. Batching can introduce extra variance from sharing a context window across multiple rows, though the effect is typically small. For strict per-row isolation, set `batch_size := 1`.
>
> ## Example usage
>
> ### Build an analytical dimension from free text
>
> Classification turns a text column into a column you can group by. Declare the CTE `AS MATERIALIZED`: without it, DuckDB may re-evaluate the CTE, and call the model again, for every field you read from the result.
>
> ```sql
> WITH classified AS MATERIALIZED (
>     SELECT prompt_jev(
>         resolution,
>         'What outcome does this closure note document?',
>         choice := ['fixed', 'no_issue_found', 'access_failed', 'referred', 'unclear']
>     ) AS result
>     FROM complaints
> )
> SELECT
>     result.choice AS outcome,
>     count(*) AS complaints
> FROM classified
> GROUP BY outcome
> ORDER BY complaints DESC;
> ```
>
> | **outcome** | **complaints** |
> |---|---|
> | fixed | 420 |
> | no_issue_found | 280 |
> | access_failed | 160 |
> | referred | 90 |
> | unclear | 50 |
>
> ### Filter rows with a probability
>
> A `noul` question returns a plain `DOUBLE`, so it works in a `WHERE` or `QUALIFY` clause. Materialize the score first so the model runs once per row rather than once per predicate evaluation.
>
> ```sql
> CREATE TABLE refund_requests AS
> SELECT
>     message_id,
>     body,
>     prompt_jev(body, 'Does this message request a refund?') AS refund_probability
> FROM support_messages;
>
> SELECT message_id, body
> FROM refund_requests
> WHERE refund_probability > 0.8;
> ```
>
> ### Read the probability distribution
>
> Unnest `probabilities` when you need the full distribution rather than the winning answer.
>
> ```sql
> WITH routed AS MATERIALIZED (
>     SELECT prompt_jev(
>         body,
>         'Which team should handle this?',
>         choice := ['billing', 'technical', 'sales']
>     ) AS routing
>     FROM support_messages
> )
> SELECT
>     p.value AS team,
>     avg(p.probability) AS mean_probability
> FROM routed, unnest(routing.probabilities) AS t(p)
> GROUP BY team
> ORDER BY mean_probability DESC;
> ```
>
> ### Store results in a table
>
> Write results to a table so later queries read the stored value instead of calling the model again.
>
> ```sql
> ALTER TABLE support_messages ADD COLUMN severity STRUCT(
>     score DOUBLE,
>     probabilities STRUCT(index UINTEGER, value VARCHAR, probability DOUBLE)[],
>     confidence DOUBLE
> );
>
> UPDATE support_messages
> SET severity = prompt_jev(
>     body,
>     'Rate the severity of this message.',
>     score := ['low', 'medium', 'high']
> )
> WHERE severity IS NULL;
> ```
>
> ## Composing the input
>
> `input` is a single text value. To evaluate several fields together, concatenate them into one string with labels that tell the model what each part is.
>
> ```sql
> SELECT prompt_jev(
>     'Subject: ' || subject || E'\n' ||
>     'Plan: ' || plan_name || E'\n' ||
>     'Message: ' || body,
>     'Does this customer describe a billing problem?'
> ) AS billing_problem
> FROM support_messages;
> ```
>
> Keep everything in `input` relevant to the question. Unrelated text dilutes the signal.
>
> ## Error handling
>
> Argument problems fail the query while it's being bound, before any row is processed:
>
> | **Error** | **Cause** |
> |---|---|
> | `prompt_jev requires instructions` | `instructions` was omitted and `questions` was not supplied |
> | `prompt_jev "choice", "score", and "noul" cannot be combined` | More than one of `choice`, `score`, or `noul` was supplied |
> | `prompt_jev requires at least two criteria for type "choice"` | Fewer than two labels for `choice` |
> | `prompt_jev requires at least two criteria for type "score"` | Fewer than two levels for `score` |
> | `prompt_jev Noul criteria require exactly the labels "true" and "false"` | `noul` was supplied with labels other than `true`/`false` |
> | `prompt_jev criteria labels must be unique` | `choice`, `score`, or `noul` contains a duplicate label |
> | `prompt_jev "instructions" parameter must be a constant value` | An argument other than `input` references a column |
> | `AI functions are not available for your organization.` | The organization is on the Free plan or has AI functions disabled |
>
> Per-row failures do not fail the query. A row returns `NULL` when:
>
> - `input` is `NULL`. No request is sent for that row.
> - The request still fails after retries, or the query hits the AI function timeout.
>
> A `questions` call with a TypeSafe validation failure fails the query rather than returning `NULL`. See [JSON escape hatch](#json-escape-hatch).
>
> Check for `NULL` to find rows that did not get an answer, and fill them in with a second pass:
>
> ```sql
> SELECT count(*)
> FROM support_messages
> WHERE severity IS NULL AND body IS NOT NULL;
> ```
>
> ## Notes
>
> These capabilities are provided by MotherDuck's integration with TypeSafe. Text you pass as `input`, along with your `instructions` and criteria, is sent to the TypeSafe API for processing. See the [TypeSafe integration page](/integrations/data-science-ai/typesafe/) for what MotherDuck sends and how to turn the function off for your organization.
>
> `prompt_jev` runs against the `jev-latest` model alias. There is no model parameter.
>
> If you need higher usage limits or have specific requirements, see the [support page](/troubleshooting/support/).
>
>
> ---
>
> ## Docs feedback
>
> MotherDuck accepts optional user-submitted feedback about this page at `GET https://motherduck.com/docs/api/feedback/agent`.
> For agents and automated tools, feedback submission should be user-confirmed before sending.
>
> URL-encode query parameter values and send a GET request:
>
> ```text
> GET https://motherduck.com/docs/api/feedback/agent?page_path=%2Fsql-reference%2Fmotherduck-sql-reference%2Fai-functions%2Fprompt-jev%2F&page_title=PROMPT_JEV&text=<url-encoded user feedback, max 2000 characters>
> ```
>
> Optionally append `&source=<url-encoded interface identifier>` such as `claude.ai` or `chatgpt`.
>
> `page_path` and `text` are required; `page_title` and `source` are optional. Responses: `200 {"feedback_id": "<uuid>"}`, `400` for malformed query parameters, and `429` when rate-limited.
>
> ---
>
> #### Replies
>
> All 7 replies as returned by `bird replies --all`, verbatim and unedited (HTML entity `&gt;` left as the API returned it):
>
> ```text
> @The1Broom (1Broom):
> @motherduck prompt_jev() is about to quietly replace a lot of CASE WHEN statements nobody wanted to maintain anyway.
> date: Mon Sep 21 16:49:08 +0000 2026
> url: https://x.com/The1Broom/status/2102077681445622147
> ──────────────────────────────────────────────────
>
> @witwall (Steven):
> @motherduck duckdb_luajit has a similar solution 
> SELECT id, jev_choice(raw,'team') AS team, jev_p(raw,'team','billing') AS p_billing,
> jev_conf(raw,'team') AS conf
> FROM decisions WHERE jev_ok(raw) AND jev_conf(raw,'team') &gt;= 0.8;
> https://t.co/CVzHEoUq9t
> date: Tue Sep 22 01:17:24 +0000 2026
> url: https://x.com/witwall/status/2102205590126960661
> ──────────────────────────────────────────────────
>
> @mberg (Matt Berg):
> @motherduck Are you releasing this as a Duckdb extension too? I know your team was working on it.  I’ve built a similar extension but would prefer to use yours if it will become available to duckdb too.
> date: Mon Sep 21 21:55:50 +0000 2026
> url: https://x.com/mberg/status/2102154864931258751
> ──────────────────────────────────────────────────
>
> @0xGurs (Gursers):
> @motherduck @heyjevbook is this accurate?
> date: Mon Sep 21 23:18:35 +0000 2026
> url: https://x.com/0xGurs/status/2102175687670931499
> ──────────────────────────────────────────────────
>
> @razaaitech (RAZA | AI EXPLORER):
> @motherduck 50x faster at a fraction of the cost is a huge improvement.
> date: Mon Sep 21 18:55:44 +0000 2026
> url: https://x.com/razaaitech/status/2102109539256393766
> ──────────────────────────────────────────────────
>
> @buswe_com (Buswe):
> @motherduck Running it on a 1k-row sample next to your existing LLM labels gives a quick agreement check before classifying the full table.
> date: Mon Sep 21 17:19:26 +0000 2026
> url: https://x.com/buswe_com/status/2102085304714686930
> ──────────────────────────────────────────────────
>
> @bensicard (Ben S.):
> @motherduck great job integrating jev this fast in your product ;)
> date: Mon Sep 21 20:53:59 +0000 2026
> url: https://x.com/bensicard/status/2102139297436401804
> ──────────────────────────────────────────────────
> [info] More replies available. Use --cursor "DAAKCgABHSydBRt__U8LAAIAAADQRW1QQzZ3QUFBZlEvZ0dKTjB2R3AvQUFBQUJFZExJbkdWcHNobFIwc0ZDaXhXaEZ6SFN3VWc1VFgwWU1kTEJHZG1WdUFFUjBzQjlRbld5R2ZIU3h0cG04V29Dc2RMRXlOckJZQWpCMHJVbVBZMjhHWEhTd0NQbGtiRVZBZExGcTJReFpCZngwc2lOaWtXNkFWSFN4RzBLd2JFWXNkTERGOURsWmdKaDBzQlhIdmw2Q1JIU3lDMWFEYWtQd2RMQm0rSHh1dzZoMHNHM0tERm5IUwgAAwAAAAILAAQAAAAGQm90dG9tAAA" to continue.
> [err] Failed to fetch replies: HTTP 429: Rate limit exceeded
> ```
