---
created: 2026-09-21
description: TypeSafe's SDE cascade cookbook extracts with gpt-5.4-mini in plain text mode, verifies every field with a battery of Jev Noul questions each returning P(something is wrong), and escalates to gpt-5.5 when any per-field probability exceeds a hard 0.7 - a max gate, not a mean, so one confident flag cannot be averaged into silence; the worked example's cheap-rung error is hand-fabricated rather than sampled, the verifier is pinned to jev-1.12 while the docs' own jaggedness page documents 1.13, and the 100-prompt Pareto chart turns out to measure mean llm_judge with plus or minus one SEM error bars that make the cascade statistically indistinguishable from the top model, which the chart places at $0.0443 per extraction where the prose says $0.10.
source: https://docs.typesafe.ai/cookbooks/sde_cascade
author: TypeSafe AI (docs)
type: knowledge
tags: [jev, cookbook, cascade, structured-data-extraction, verifier, escalation-gate, noul, typesafe, system-one-models]
---

# TypeSafe's SDE cascade gates escalation on any per-field Noul above 0.7 - the chart's y-axis is mean llm_judge and the frontier dominates only the two middle models

A first-party TypeSafe cookbook, filed under Extraction in the docs navigation between the Guardrails and Date extraction cookbooks. It walks one structured-data-extraction item end-to-end through a two-rung cascade, then shows a cost/quality sweep over 100 prompts. Prices are stamped "standard rates checked September 15, 2026". This is the vault's first note where TypeSafe itself publishes the full verifier prompt battery rather than describing it, and the first where the escalation threshold, the aggregation rule, and the plotted sweep all appear together in one place.

## Key Takeaways

- **The gate is the contribution, and it is one line of code: escalate if any per-field `P(wrong)` exceeds 0.7.** Not a mean, not a weighted composite, not the holistic head. The cookbook is explicit that `max` is the point ("one confident red flag is enough instead of being averaged into silence"), and it deliberately computes a whole-record `__overall__::judge` head only to *contrast* it against the per-field battery, leaving it out of the gate. That contrast is the cookbook's real argument and the chart cannot test it: the holistic head scored 0.56 on the worked example, below the 0.7 line, so the blunt judge would have accepted the fabrication that two per-field heads caught at 0.95 and 0.85. That is a single anecdote standing in for the comparison, and the 100-prompt sweep plots only `any_flag` — the legend confirms one strategy, so the decomposed-versus-holistic claim is never measured at N=100. [[Annabell frames TypeSafe's Jev as a savant for eval verdicts and routing - three question types, 255 choices, 10 score levels, and a Noul with no confidence field|Annabell's read]] that a Noul returns no confidence field is what forces this shape: with no confidence axis, a raw probability against a hard constant is the only gate available, which is exactly the lever [[Daniel Ch's How to master Jev prescribes a 0.85 and 0.55 confidence-gate ladder under an LLM that still writes - the decision-layer architecture is additive but every number and all three charts are TypeSafe's own|Daniel Ch's 0.85/0.55 ladder]] reaches for instead.

- **A max gate over uncalibrated per-field probabilities with a fixed threshold is the design the cascade literature warns about, and Appendix A asks for exactly the property nobody has shown Jev has.** The appendix's fifth rule is "Separating / calibrated", and the Step 3 prose asserts flatly that "TypeSafe returns a calibrated `noul`" and "Our results are calibrated". The vault's standing finding is that no calibration measurement for Jev has been published: [[LangChain's Jev-as-a-Judge bench puts Jev's quality-score variance 92 to 913x below three LLM judges at $0.34 against Claude's $28.17 - five weather traces, one human oracle, provider-default sampling|LangChain's bench]] measured repeatability across 100 replays of five cases, not calibration; [[Sutro's jev-align uses GEPA to rewrite Jev's decision criteria from five labeled examples - the demo moves labeled-set ambiguity 49.6 points but full-pool certainty only 0.5|jev-align]] optimizes criteria without reporting a calibration metric; and [[Featherless's Simple Jev reproduces Jev's API on stock open models by remapping every answer to a single-token letter and softmaxing only those logits - no classifier head, and the code stamps every answer calibrated False|Featherless's Simple Jev]] stamps `calibrated: False` on every answer it returns. The contrast with [[BARGAIN routes classification to a small model via a confidence threshold calibrated on 500 oracle labels, cutting costs up to 86 percent more than competing cascades|BARGAIN]] is the sharpest one available: BARGAIN calibrates its routing threshold on 500 oracle labels and ships a statistical guarantee on the result. This cookbook sweeps its threshold across the same 100 items it then plots, so every point on the frontier is an in-sample fit with no held-out set and no guarantee.

- **The worked example's cheap-rung error is hand-written, not sampled, and the cookbook says so in a note most readers will skip.** Step 2 hard-codes `mini_record` and explains why: `gpt-5.4-mini` "is very stochastic on this input -- even at `temperature=0` it invents a different `description` on nearly every run", so the authors froze "the one canonical fabrication the rest of this notebook explains (and that the verifier flags at P(wrong) > 0.8)". Read plainly, the demo is a demonstration of the gate's mechanics on an input chosen to fire it, not evidence that the mini model produces that error at any particular rate. The genuinely valuable idea survives the fabrication intact and is worth the note on its own: the record is schema-valid and still wrong, because "schema validation is necessary but not sufficient: it catches structural errors, never semantic ones. That gap is the whole point." The schema's own `description` field ships an example value that the mini model then parrots back as an extraction, which is a real and underrated failure mode of schema-guided extraction.

- **Reading the chart's axes overturns the headline claim: the frontier dominates the two middle models and is dominated at both ends.** The y-axis is labelled `mean llm_judge`, which the prose never mentions — so "quality" is an LLM judge's mean score, the exact instrument the neighbouring [[LangChain's Jev-as-a-Judge bench puts Jev's quality-score variance 92 to 913x below three LLM judges at $0.34 against Claude's $28.17 - five weather traces, one human oracle, provider-default sampling|Jev-as-a-Judge note]] found to vary 92 to 913x more than Jev. The prose says the frontier "sits up-and-left of every single model"; the pixels say otherwise. `gpt-5.4-mini` alone sits at $0.0042 for 0.7015, while the cheapest cascade point costs $0.0057 for 0.7012 — same quality, 36% more money, because at a threshold that never fires you pay the verifier for nothing. At the top, `gpt-5.5-reasoning` alone gets 0.8198 at $0.0443 while the frontier plateaus at 0.8185 for $0.0463 and up. The cascade's real and defensible win is the middle of the lineup: it beats `gpt-5.5` ($0.0250, 0.7821) with a point at $0.0163 scoring 0.7877, which is 35% cheaper and marginally better. Every single-model diamond also carries a ±1 SEM bar the prose never mentions, and the top model's spans 0.789 to 0.850 — wide enough to swallow every cascade point above $0.018, so essentially no frontier point is statistically distinguishable from just paying for the big model.

- **Deliberately refusing structured outputs is the cookbook's best-argued choice, and it quietly narrows what Jev is doing here.** Both extraction rungs use plain OpenAI text mode, and the reasoning is sound: a schema-following mistake "is not the mistake we expect an LLM to make (it's easy to make synthetic data for this)", and when a model does break schema "it's almost always very confused, so constrained decoding doesn't fix the underlying issue". The failure worth spending money on is semantic, so spend the money on a semantic verifier. That makes this a narrower use of TypeSafe than [[TypeSafe's Jev trades string generation for parallel-sampled typed decisions with calibrated probabilities at $0.042 per MTok - the 193x and 444x claims come from four self-built workflow evals|the launch note's "zero type errors" framing]] implies: Jev never produces the extracted record, it only grades one, and the typed-output guarantee applies to the nine yes/no probabilities rather than to the data the pipeline ships. It is the worker-supervision pattern [[Josh Rosen's Jev in the Wild sorts week-one projects into routing, context filtering, tool gating, worker supervision, fast control loops and fuzzy data queries - deterministic only because inference was expensive|Josh Rosen catalogued in week one]], run against an OpenAI extractor. The cookbook also pins `jev-1.12` while the same docs site publishes a jaggedness page for `jev-1.13`, so the published numbers come from a verifier one minor version behind the one the docs document.

## The Cascade

Three rungs, two of them OpenAI text-mode calls and one a TypeSafe verifier. Prices are dollars per 1M tokens, input / output, "standard rates checked September 15, 2026".

| Rung | Model | Input | Output | Role |
|---|---|---|---|---|
| 0 (mini) | `gpt-5.4-mini` | $0.75 | $4.50 | extract, cheap and fast |
| verifier | `jev-1.12` (TypeSafe) | $0.042 | $0.00 | per-field P(wrong); output tokens free |
| 1 (reasoning) | `gpt-5.5` | $5.00 | $30.00 | re-extract, `reasoning_effort="high"` |

The page puts the reasoning rung at "roughly 7x the mini". On input tokens that is 6.67x; on output, 6.67x. The verifier is ~18x cheaper than the mini on input and free on output, which is what makes a verify-everything-then-escalate-some design arithmetically plausible at all.

The stated algorithm is three steps:

1. **Extract** with a cheap/small model.
2. **Verify** with TypeSafe primitives: a per-field yes/no Noul question, for example "is this value absent from the source?" or "was it lifted from unrelated text?", each returning P(something is wrong).
3. **Escalate** to an expensive reasoning model if a verifier signal fires; otherwise keep the cheap answer.

Both extraction rungs deliberately use text mode. The cookbook does not use structured outputs, tool calls, or JSON mode, for two stated reasons: a schema-following mistake is not the mistake an LLM is expected to make and is easy to generate synthetic data for, and a model that does break schema is usually so confused that constrained decoding will not fix the underlying problem. It closes with "we encourage you to try them though!". A malformed reply is caught in code and turned into `{}`, described as "the record-level analog of NaN": every field then reads as absent, the verifier flags it, and the gate escalates, which the comment calls "the safe direction".

The data is one row of the `scrapegraphai/scrapegraphai-100k` HuggingFace dataset, revision `4bb9fba1dff9181c5acdb60a5a26fea62fa54fe9`, index 516. It is a scrape of an NYU events-calendar page that captured only navigation and boilerplate, against a two-field schema asking for `registration_open_date` and `description`. There is no registration date and no description anywhere in the scraped text, so "a well-behaved extractor should *decline* to invent the fields the page doesn't contain". The schema's `description` field ships an example value in its own field description, which is the trap.

Every LLM and TypeSafe call is memoized through a `JsonCache` decorator writing `json_cache.json`, which the page says "ships with the cookbook, so re-rendering reproduces the published results with no API spend". See the Links section on the availability of that file.

## The Verifier Battery

For each field the cookbook builds a `Noul` question framed so that `true` means something is wrong and the record should escalate. Non-empty fields get the full seven-head battery; empty fields (`None`, `""`, `[]`) get only `absence_wrong`. `type_mismatch` is skipped when the schema type resolves to `unknown`. One holistic head is added per record. Every question ships an explicit `NoulCriteria` pair naming what `true` and `false` mean, and the whole battery for a record goes out in a single `system_one` call.

The instructions for each per-field head are a JSON object, not a string: `{"field_spec": {...}, "extracted_field": value, "main_question": question}`, where `field_spec` carries `path`, `type`, `description` and `required` pulled from the schema. Question ids are keyed `field::metric`.

| Metric | Question | `true` means | `false` means |
|---|---|---|---|
| `name_desc_mismatch` | Does the `extracted_field` fail to match the field at `path` or the `description` in the `field_spec`? If the `description` is empty, judge against the `path` alone. | the `extracted_field` does not match the field name or its `description` | the `extracted_field` matches the field name and `description` |
| `type_mismatch` | Does the `extracted_field` violate the `type` declared in the `field_spec`? | the `extracted_field` violates the declared `type` | the `extracted_field` conforms to the declared `type` |
| `unreasonable` | Is the `extracted_field` one that a reasonable person would not have extracted for this `field_spec`? | a reasonable person would not have extracted this value | the extraction is reasonable |
| `hallucinated` | Is the `extracted_field` unsupported by, or absent from, the source text? | the `extracted_field` is a hallucination -- not supported by, or absent from, the source text | the `extracted_field` is supported by the source text |
| `off_target` | Does the source text fail to genuinely report the thing the `field_spec` describes, so the value was pulled from incidental text? | the source does not genuinely provide this field -- the value was pulled from incidental text | the source genuinely reports this field |
| `incomplete` | Does the `extracted_field` fail to capture a value the source supports (note whether the `field_spec` is `required`)? | the field is wrongly empty, null, or missing a value the source supports | the field captures the value the source supports |
| `format_violation` | Does the `extracted_field` violate the format or constraints implied by the `description`, the schema `type`, and the extraction instructions (e.g. date format, units, enum membership)? | the `extracted_field` violates the implied format or constraints | the `extracted_field` satisfies the format and constraints |
| `absence_wrong` (empty fields only) | The `extracted_field` is empty, null, or an empty collection. Does the source text contain the information the `field_spec` describes, making the empty result wrong? | a value was wrongly omitted | returning nothing is correct |
| `__overall__::judge` (whole record, not gated) | Is this extracted record an incorrect extraction -- some value unsupported by the source or not conforming to the schema, required information missing or wrong, or some field hallucinated -- so it should be escalated to a smarter model? | the record is an incorrect extraction | the record is a correct extraction |

The page notes two heads it runs in the full pipeline but omits here to keep the walkthrough to the two gating heads: a `spurious` head for whole containers, and an overall `difficulty` score.

Run over the hard-coded mini extraction, the battery produced nine probabilities. `<== FIRES` marks anything above `FIRE_T`:

| Question id | P(wrong) | |
|---|---|---|
| `description::hallucinated` | 0.95 | `<== FIRES` |
| `description::off_target` | 0.85 | `<== FIRES` |
| `description::unreasonable` | 0.58 | |
| `__overall__::judge` | 0.56 | |
| `description::incomplete` | 0.16 | |
| `registration_open_date::absence_wrong` | 0.14 | |
| `description::format_violation` | 0.10 | |
| `description::name_desc_mismatch` | 0.08 | |
| `description::type_mismatch` | 0.02 | |

The page reads this as concentration of signal: "high on the field that is wrong, low on the field that is correct, medium on a field that looks off without being clearly wrong", and calls it "what a typesafe verifier buys you over a blunt 'is this whole thing good?' judge". Note that the blunt judge it is being compared against is its own `__overall__::judge` head at 0.56, which would not have fired.

Step 3 also carries the cookbook's stated design philosophy, headed "The TypeSafe Way: Decomposition": "Notice how everything is *programmatically decomposed*, this is TypeSafe way. Decomposition maximizes the intelligence of every prompt, and makes the algorithm tunable and interpretable." It is illustrated with a small Mandalorian "this is the way" meme.

## The Escalation Gate

This is Step 4, the part the cookbook's own anchor points at. The rule in prose:

> now we gate on **`any_flag`**: escalate if *any* field flag exceeds `FIRE_T` (0.7, set above and shared with the `<== FIRES` marker in Step 3)
>
> this is a `max`-style gate (escalate if *any* field fires), not a mean, so one confident red flag is enough instead of being averaged into silence

`FIRE_T = 0.7` is defined once in the setup cell with the comment "escalate if any per-field P(wrong) exceeds this; also the `<== FIRES` display marker", so the display threshold and the decision threshold are the same constant by construction. The comparison is strict (`p > FIRE_T`), so exactly 0.7 does not fire.

The whole gate:

```python
# any_flag is a per-field gate: the holistic __overall__ head is shown above but not part of it
fired = {
    qid: p
    for qid, p in checks.items()
    if not qid.startswith("__overall__") and p > FIRE_T
}
escalate = bool(fired)
```

Three properties worth naming, because they are the design:

- **Max, not mean.** `bool(fired)` over a filtered dict is a max gate. Averaging the nine probabilities above would give roughly 0.38, less than half the threshold, and the fabrication would have been accepted. This is the cookbook's strongest mechanical argument and it survives every criticism of the surrounding evidence.
- **The holistic head is excluded by an explicit string check.** `not qid.startswith("__overall__")` drops `__overall__::judge` from the gate. It is computed, printed, and then deliberately ignored. On this example that exclusion is load-bearing in the opposite direction from what you might expect: the holistic head was below threshold, so including it would not have changed the decision, but relying on it *alone* would have.
- **One threshold for every field and every metric.** There is no per-metric threshold, no per-field weighting, and no separate treatment for `absence_wrong` versus `hallucinated`, even though those heads are asking structurally different questions on different populations of fields. Appendix A asks for signals that are "separating / calibrated" so "a single threshold cleanly splits accept vs escalate"; a single constant across nine differently-framed heads is the strongest form of that assumption.

The output on the worked example:

```
any_flag gate (threshold 0.7): ESCALATE
  fired: description::hallucinated  (P=0.95)
  fired: description::off_target  (P=0.85)
```

Step 5 then pays for `gpt-5.5` at `reasoning_effort="high"` and the reasoning model drops the fabricated `description`, returning `""` for both fields. The page's summary: "The cascade turned a confident, schema-valid fabrication into an honest empty field. And it only spent reasoning-model dollars on this one item *because the verifier told it to*."

## Results on 100 Prompts

The page is explicit up front: "**These are internal TypeSafe results**", produced with the same `extract → verify → escalate` loop over 100 scrapegraphai prompts, `gpt-5.4-mini → gpt-5.5-reasoning`, `any_flag` gate over the per-field heads. The gate threshold ("cut") is swept 0 to 1 and every resulting config is plotted in (cost, quality) space. It also warns that "the chart is a historical snapshot; its costs have not been recalculated at the current Jev rate listed above".

*Internal TypeSafe results: cost/quality frontier over 100 scrapegraphai prompts. Title "Pareto frontier - color = strategy, marker = #rungs (up-left is better)". X axis mean cost in dollars per extraction, gridlines at 0.01/0.02/0.03/0.04. Y axis "mean llm_judge", gridlines every 0.025 from 0.675 to 0.850. Legend: blue dots "any_flag", dashed line "Pareto frontier", black diamond "single models (plus or minus 1 SEM)".*
![[typesafe-sde-cascade-001.png]]

The four black diamonds, measured off the image (the label text gives only `gpt-5.5-reasoning` a number in the prose):

| Single model | Mean cost/extraction | Mean `llm_judge` | Quality ±1 SEM | Cost ±1 SEM |
|---|---|---|---|---|
| `gpt-5.4-mini` | $0.0042 | 0.7015 | 0.662 to 0.741 | $0.0037 to $0.0047 |
| `gpt-5.4` | $0.0127 | 0.7112 | 0.672 to 0.750 | $0.0117 to $0.0137 |
| `gpt-5.5` | $0.0250 | 0.7821 | 0.749 to 0.815 | $0.0231 to $0.0269 |
| `gpt-5.5-reasoning` | $0.0443 | 0.8198 | 0.789 to 0.850 | $0.0413 to $0.0473 |

42 distinguishable blue cascade points span $0.0057 to $0.0473 and 0.7012 to 0.8185. The dashed frontier rises almost vertically from 0.702 to 0.771 between $0.0074 and $0.0104, then flattens for the remaining four-fifths of the x-range, gaining only 0.047 more quality for four times the cost. Selected frontier points: $0.0078/0.7175, $0.0081/0.7433, $0.0091/0.7578, $0.0104/0.7713, $0.0163/0.7877, $0.0261/0.8060, $0.0324/0.8116, $0.0431/0.8179, $0.0473/0.8185.

What the chart supports, and what it does not:

- **"Quality" is `mean llm_judge`.** The axis label says so; the prose never does. It is an LLM judge's mean score over 100 items, with no statement anywhere of which model judges, what rubric it uses, or whether it saw a gold record. Nothing on the page ties it to exact-match or field-level F1 against ground truth. The whole chart spans 0.70 to 0.82 on this instrument.
- **The prose and the chart disagree on the top model's cost by 2.3x.** The text says `gpt-5.5-reasoning` "sits top-right at ≈0.81 quality for ≈\$0.10/extraction". The chart's x-axis stops at about $0.048 and places that diamond at $0.0443. The quality is roughly right (0.8198 rounds to 0.82); the cost is not.
- **"Up-and-left of every single model" holds for two of the four.** The cascade cleanly dominates `gpt-5.4` and `gpt-5.5`. It does not dominate `gpt-5.4-mini`, which is cheaper at identical quality, nor `gpt-5.5-reasoning`, which is both cheaper and marginally better than the frontier's right end. The cheap end of the sweep is the verifier tax with the gate never firing, and the expensive end is the gate always firing plus the verifier on top.
- **±1 SEM on the single models, nothing on the cascade.** The diamonds carry error bars in both axes; the blue points carry none. `gpt-5.5-reasoning` spans 0.789 to 0.850, which contains every cascade point from $0.0183 upward; only the two points at $0.0163 (0.7877) and $0.0178 (0.7884) fall below it, and then by less than 0.0012. At N=100 and one standard error, essentially no frontier point is statistically distinguishable from simply paying for the big model.
- **The sweep is in-sample.** The threshold is swept across the same 100 items the chart plots, so each point is a fit rather than a prediction. [[BARGAIN routes classification to a small model via a confidence threshold calibrated on 500 oracle labels, cutting costs up to 86 percent more than competing cascades|BARGAIN]] is the contrast: calibrate the threshold on labeled data, then ship a guarantee.
- **Cost accounting is asserted, not shown.** No cost computation appears anywhere in the cookbook's code, so whether the plotted per-extraction cost includes the verifier's input tokens cannot be checked from the page. The `verify` function sends `state` containing the full `row["content"]` scrape plus the schema and the extraction, and issues the entire battery in one `system_one` call, so the page is re-sent to Jev once per record rather than once per question. At $0.042 per MTok with free output that is cheap, but it is not free, and the page separately says the chart's costs were never recalculated at the current Jev rate.
- **The title promises comparisons the figure does not contain.** "color = strategy, marker = #rungs" implies several strategies and rung counts, but the legend lists one strategy (`any_flag`) and one marker for the cascade. Whatever else was tried is not in this figure.

## What Makes a Good Verifier Signal

Appendix A, reproduced faithfully. The framing: "the cascade is only as good as its verifier; what separates a useful signal from a useless one".

- **Narrow and grounded.** One checkable yes/no about one field against the source (e.g. "is this value absent from the source?"), not a vague "is this extraction good?". Vague questions give mushy, uncalibrated scores.
- **Bad = TRUE, with explicit criteria.** Frame each question so the *escalate* case is the `true` case, and state what `true`/`false` mean.
- **Per-field, then aggregate with `max`.** A per-field flag localizes the error and stays sparse and strong. `max` ("any flag fires") ensures one confident red flag escalates, instead of being averaged into silence.
- **Independent and cheap.** A dedicated verifier (here, TypeSafe) judging the output catches the extractor's own blind spots. It has to be cheap, or there are no savings left to capture.
- **Separating / calibrated.** A good signal is high on real errors and low on correct ones, so a single threshold cleanly splits accept vs escalate. That separation is what pushes the pareto curve up-and-left.

The first four are design advice that this cookbook follows visibly. The fifth is a property of the model rather than the prompt, and it is the one the page assumes rather than measures. It is also the one every other note in this folder has failed to find published evidence for.

## Sibling Cookbooks

The docs index at `https://docs.typesafe.ai/llms.txt` lists 18 cookbooks including this one. Descriptions are the index's own, trimmed to one line. None are captured in the vault yet.

| Cookbook | URL | What it does |
|---|---|---|
| Self-consistency: nouls | https://docs.typesafe.ai/cookbooks/consistency_noul_cookbook | Routes uncertain probabilities to human review while keeping the underlying noul values visible. |
| Self-consistency: choices | https://docs.typesafe.ai/cookbooks/consistency_choice_cookbook | Adds an uncertain outcome to moderation decisions and compares label agreement with the share of automatic actions. |
| Parallel questions | https://docs.typesafe.ai/cookbooks/parallel_questions | 13-question regulatory briefing over the GDPR Wikipedia article; batching every question into one call is 12.2x cheaper and 10.0x faster with no change in answers. |
| Re-ranking | https://docs.typesafe.ai/cookbooks/rerank_typesafe | 30-passage BM25 shortlists for 40 CLERC legal queries; one question per query-candidate pair raises top-1 from 5% to 18% and top-10 from 38% to 62%. |
| Line-by-line search | https://docs.typesafe.ai/cookbooks/semantic_find | Semantic search over GitHub's Terms of Service: scores 218 line ids with a Choice, plus a Noul for whether the document answers at all. |
| Structure recovery | https://docs.typesafe.ai/cookbooks/autoformat | Reconstructs Markdown from unformatted text in two requests: one restitches hard-wrapped lines, one classifies every block. |
| Function calling | https://docs.typesafe.ai/cookbooks/function_calling | Turns natural-language trading requests into typed function calls by mapping names and closed-set arguments to confidence-aware questions. |
| Skill suggestion | https://docs.typesafe.ai/cookbooks/skill_suggestion | Picks at most one skill from the 182 in Nous Research's Hermes catalog; one request ranks all of them, a second reads the top three and can reject all. |
| Knowledge graph entity alignment | https://docs.typesafe.ai/cookbooks/entity_alignment | Decides which of 450 candidate pairs from two beer catalogues match, using one Score whose three levels are merge, leave, or escalate to a curator. No threshold to fit. |
| Classifying RAG passages | https://docs.typesafe.ai/cookbooks/classifying_rag_passages | Scores each retrieved passage, then decides in code which reach the answering model; drops passages carrying prompt injections. |
| Double-checking citations | https://docs.typesafe.ai/cookbooks/citation_check | Catches wrong or hallucinated citations against the source; one Choice decides whether context supports the claim, confidence flags for review. |
| Guardrails for LLMs | https://docs.typesafe.ai/cookbooks/llm_guardrails | Screens messages in and out of an LLM app with one request describing hazards and scoring severity; threshold to pass, review, block, or route. |
| **SDE cascade** (this note) | https://docs.typesafe.ai/cookbooks/sde_cascade | 2-stage extraction cascade: mini, verify, reasoning. |
| Date extraction | https://docs.typesafe.ai/cookbooks/date_extraction_cookbook | Extracts absolute and relative dates by asking for the parts named in a document, then resolving and validating in code. |
| Pre-parsed value extraction | https://docs.typesafe.ai/cookbooks/pre_parsed_value_extraction_cookbook | Regexes find candidate emails, phones, and amounts; TypeSafe selects the requested span so code can normalize a verbatim value. |
| Hierarchical classification | https://docs.typesafe.ai/cookbooks/hierarchical_classification | Classifies through deep patent, retail, biomedical, and source-code hierarchies using parallel beam search over Choice probabilities. |
| Autoresearch feature discovery | https://docs.typesafe.ai/cookbooks/autoresearch_feature_discovery | Autoresearch loop that proposes questions, converts free text into numeric features, and uses model errors to improve a CatBoost regressor. |
| Classification using confidence | https://docs.typesafe.ai/cookbooks/classification_using_confidence | Classifies SEC annual reports into 75 industry groups with one Choice each, reading confidence to decide whether to report the group or the division above it. |

Four of these bear directly on this note's open questions: the two self-consistency cookbooks are the closest thing TypeSafe publishes to a calibration story, "Classification using confidence" uses the confidence axis this cookbook cannot, and "Entity alignment" explicitly avoids a fitted threshold by encoding the three actions as Score levels.

## Related

- [[moc - Jev]] - the folder map.
- [[TypeSafe's Jev trades string generation for parallel-sampled typed decisions with calibrated probabilities at $0.042 per MTok - the 193x and 444x claims come from four self-built workflow evals]] - the launch note whose $0.042 per MTok price and "zero type errors" framing this cookbook uses, with Jev as verifier only.
- [[Daniel Ch's How to master Jev prescribes a 0.85 and 0.55 confidence-gate ladder under an LLM that still writes - the decision-layer architecture is additive but every number and all three charts are TypeSafe's own]] - a two-level confidence ladder against this cookbook's single 0.7 probability gate.
- [[Annabell frames TypeSafe's Jev as a savant for eval verdicts and routing - three question types, 255 choices, 10 score levels, and a Noul with no confidence field]] - the missing Noul confidence field that forces a raw-probability threshold here.
- [[LangChain's Jev-as-a-Judge bench puts Jev's quality-score variance 92 to 913x below three LLM judges at $0.34 against Claude's $28.17 - five weather traces, one human oracle, provider-default sampling]] - repeatability measured, calibration not; and the LLM judge that turns out to be this chart's y-axis.
- [[LangChain's Sydney Runkle puts Jev inside the agent loop as classifier middleware - ModelRouterMiddleware picks the model from the latest user message and AutoModeMiddleware reproduces closed harnesses' dangerous-action gate]] - AutoModeMiddleware is a thresholded Jev gate of the same shape, on tool calls instead of fields.
- [[Josh Rosen's Jev in the Wild sorts week-one projects into routing, context filtering, tool gating, worker supervision, fast control loops and fuzzy data queries - deterministic only because inference was expensive]] - this cookbook is the worker-supervision pattern from that taxonomy.
- [[Sutro's jev-align uses GEPA to rewrite Jev's decision criteria from five labeled examples - the demo moves labeled-set ambiguity 49.6 points but full-pool certainty only 0.5]] - optimizing the `NoulCriteria` strings this cookbook hand-writes.
- [[jev-align]] and [[simple-jev]] - the resource notes for those two tools.
- [[BARGAIN routes classification to a small model via a confidence threshold calibrated on 500 oracle labels, cutting costs up to 86 percent more than competing cascades]] - the same cascade shape with a threshold calibrated on held-out oracle labels and a statistical guarantee, against this cookbook's in-sample sweep.
- [[Featherless's Simple Jev reproduces Jev's API on stock open models by remapping every answer to a single-token letter and softmaxing only those logits - no classifier head, and the code stamps every answer calibrated False]] - the hardest evidence in the vault that the calibration Appendix A requires is unproven.
- [[Can Bölük's jegrep turns Jev into a semantic grep by scoring grep-ranked candidates with one Noul per file and a Choice for the line range - $0.004 a query, and the Gemini-lite comparison is nowhere in the repo]] - a four-tier Jev cascade with a 0.45 cutoff per tier, and a README honest that its Pareto marking is "a candidate set, not proof of an optimum".
- [[Cua keeps the candidate menu in application code so Jev only picks an ID - CUA-S1-FORMS is a 706K-parameter form specialist at 99.7 percent against hosted Jev's 83.6, and neither model sees pixels]] - escalates on an event rather than a probability, on the argument that "a high score alone isn't an answer".
- [[LangChain and Harvey show DeepSeek batch verifiers reduce legal agent evaluation costs by three orders of magnitude at acceptable accuracy]] - verifier-stage economics, and why false-pass rate rather than cost should set an escalation threshold.
- [[LangChain and Fireworks fine-tune Qwen as a 100x cheaper trace judge that beats frontier models on unseen perceived-error domains]] - a small tuned verifier matching the frontier model it would escalate to.
- [[LLM Data Company experiments show explicit rubric criteria let gpt-oss-120b match Opus 4.7 at 100x lower cost and full-rubric grading beats per-criterion across every model]] - direct evidence against the per-field decomposition this cookbook treats as self-evident.
- [[Varun Mathur's jevcache memoizes Jev decisions by sha256 of model, schema and redacted canonical state - the 60 to 80 percent repeat rate is asserted and dropping user_id collides two subjects]] - caching the verifier stage, which this cookbook does locally with `JsonCache`.
- [[LangChain's Paid Media Agent got 40x cheaper and 13x faster by moving calculations out of the model into code]] - the same move-work-into-code argument that motivates decomposition here.

## Links

- Source: https://docs.typesafe.ai/cookbooks/sde_cascade (the escalation gate is at the `#step-4-the-escalation-gate` anchor)
- Markdown twin used for the verbatim capture: https://docs.typesafe.ai/cookbooks/sde_cascade.md
- Docs index listing all 18 cookbooks: https://docs.typesafe.ai/llms.txt
- `gpt-5.4-mini`: https://developers.openai.com/api/docs/models/gpt-5.4-mini
- `gpt-5.5`: https://developers.openai.com/api/docs/models/gpt-5.5
- Published Jev pricing: https://typesafe.ai/blog/introducing-system-one-models-and-jev
- `jev-1.13` jaggedness page, one minor version ahead of the `jev-1.12` this cookbook pins: https://docs.typesafe.ai/model-jaggedness/jev-1.13
- Dataset: `scrapegraphai/scrapegraphai-100k` at revision `4bb9fba1dff9181c5acdb60a5a26fea62fa54fe9`, row 516
- **No notebook download exists.** The page says `json_cache.json` "ships with the cookbook", but there is no notebook, archive, Colab, or cache-file link anywhere on the rendered page, and the only outbound code link is the org root https://github.com/typesafe-ai, which has no cookbooks repository. `sde_cascade.ipynb`, `cookbooks/json_cache.json` and `cookbooks/sde_cascade/json_cache.json` all return 404, as does the `https://pypi.typesafe.ai/` index root that serves the `cooksafe` package providing `JsonCache` and `make_playground_link`.
- The Step 3 playground permalink in the verbatim text below opens the exact verification state and question set at https://console.typesafe.ai/playground

## Original Content

Captured verbatim from the docs' Markdown twin, `https://docs.typesafe.ai/cookbooks/sde_cascade.md`, on 2026-09-21. 3,056 words, 13 fenced code blocks, unabridged. The `theme={null}` attributes on the fence info strings are the source's own and are **kept** rather than stripped. The first three lines are a documentation-index preamble the Markdown twin prepends to every page. The two `<img>` tags in the source are replaced in place by vault embeds with captions; the five `events.nyu.edu` icon URLs are left exactly as they appear, because they are part of the scraped NYU page being used as input data, not figures of this article.

> [!quote]- Source Material - TypeSafe docs, SDE cascade (complete verbatim page)
> > ## Documentation Index
> > Fetch the complete documentation index at: https://docs.typesafe.ai/llms.txt
> > Use this file to discover all available pages before exploring further.
>
> # SDE cascade
>
> > Uses a 2-stage structured-data-extraction cascade (mini → verify → reasoning) to get most of the quality of a big reasoning model at a fraction of the cost.
>
> * Overview
>   * big reasoning models extract structured data well, but are slow and expensive
>   * small models are cheap, but make mistakes
>   * a *cascade* gets most of the quality at a fraction of the cost
>   * the models we use, and their price (\$ per 1M tokens, input / output; standard rates
>     checked September 15, 2026):
>     * rung 0 (mini): [`gpt-5.4-mini`](https://developers.openai.com/api/docs/models/gpt-5.4-mini)
>       at \$0.75 / \$4.50
>     * rung 1 (reasoning): [`gpt-5.5`](https://developers.openai.com/api/docs/models/gpt-5.5)
>       at \$5.00 / \$30.00 (roughly 7x the mini)
>     * verifier: TypeSafe `jev-1.12` at \$0.042 / \$0.00 (output tokens are free;
>       [published Jev pricing](https://typesafe.ai/blog/introducing-system-one-models-and-jev))
> * Algorithm
>   1. **Extract** with a cheap/small model.
>   2. **Verify** with **TypeSafe** primitives: a per-field yes/no ("Noul question")
>      question
>      * (e.g. "is this value absent from the source?", "was it lifted from unrelated
>        text?"), each returning P(something is wrong).
>   3. **Escalate** to an expensive reasoning model if a verifier signal fires; otherwise
>      keep the cheap answer.
> * This Cookbook
>   * walks one real example end-to-end, then shows the tradeoff across 100 prompts
>   * note: the two extraction rungs use text-mode OpenAI
>   * we do *not* use structured outputs, tool calls, or json mode, because:
>     * a *schema following* mistake is not the mistake we expect an LLM to make (it's
>       easy
>       to make synthetic data for this)
>     * if an LLM does fail to follow the schema, it's almost always very confused, so
>       constrained decoding doesn't fix the underlying issue
>     * we encourage you to try them though!
>
> ## Setup
>
> * install the dependencies (the TypeSafe verifier client is served from TypeSafe's package
>   index):
>
> ```bash theme={null}
> pip install openai datasets jsonschema ipython "typesafe-sdk>=0.5.7" cooksafe --extra-index-url https://pypi.typesafe.ai/
> ```
>
> * then set `OPENAI_API_KEY` and `TYPESAFE_API_KEY` in your environment
>
> ```python theme={null}
> import json
> import os
> from pathlib import Path
>
> import jsonschema
> from cooksafe import JsonCache, make_playground_link
> from datasets import load_dataset
> from IPython.display import Markdown, display
> from openai import OpenAI
> from typesafe_sdk import Noul, NoulCriteria, TypeSafeClient
>
> MINI = "gpt-5.4-mini"  # rung 0: cheap + fast
> REASONING = "gpt-5.5"  # rung 1: strong, run with reasoning_effort="high"
> TS_MODEL = "jev-1.12"  # the TypeSafe verifier model
> FIRE_T = 0.7  # escalate if any per-field P(wrong) exceeds this; also the "<== FIRES" display marker
>
> oai = OpenAI()
>
> ts = TypeSafeClient(api_key=os.environ["TYPESAFE_API_KEY"], timeout=30.0)
> ```
>
> ## Step 1: the data
>
> We choose a huggingface dataset called scrapegraphai
>
> ```python theme={null}
> SCRAPEGRAPHAI_REVISION = "4bb9fba1dff9181c5acdb60a5a26fea62fa54fe9"
> row = load_dataset(
>     "scrapegraphai/scrapegraphai-100k",
>     revision=SCRAPEGRAPHAI_REVISION,
>     split="train",
> )[516]
> schema = json.loads(row["schema"])
> prompt = row["prompt"]
> content = row["content"]
>
> print(
>     f"""
> PROMPT
> ===========
> {prompt}
>
> SCHEMA
> ===========
> {json.dumps(schema, indent=2)}
>
> CONTENT
> ===========
> {content}
> """.strip()
> )
> ```
>
> ```text expandable theme={null}
> PROMPT
> ===========
> Find registration open date fall semester for New York University in New York, NY for the 2024-2025 school year.
>
> SCHEMA
> ===========
> {
>   "properties": {
>     "registration_open_date": {
>       "description": "The date that registration opens for the fall semester. MUST be in the format mm/dd/yyyy. For example, for a college in the 2024-2025 school year, it might be something like 09/05/2024. Return a blank string if you are unsure.",
>       "title": "Registration Open Date",
>       "type": "string"
>     },
>     "description": {
>       "description": "A brief description of the registration open date. For example, 'Registration opens for the fall semester'.",
>       "title": "Description",
>       "type": "string"
>     }
>   },
>   "required": [
>     "registration_open_date",
>     "description"
>   ],
>   "title": "RegistrationOpen",
>   "type": "object"
> }
>
> CONTENT
> ===========
> Skip to content Skip to current page navigation
>
> [ ](https://www.nyu.edu/)
>
> Search Site
>
> [ ](https://www.nyu.edu/)
>
>   * [ Academics](https://www.nyu.edu/academics.html)
>   * [ Admissions](https://www.nyu.edu/admissions.html)
>   * [ Research](https://www.nyu.edu/research.html)
>   * [ University Life](https://www.nyu.edu/life.html)
>   * [ About](https://www.nyu.edu/about.html)
>
>
>
> All NYU
>
> #  Mobile Navigation
>
> [ ](https://www.nyu.edu/)
>
> Search Site
>
>   * [Academics](https://www.nyu.edu/academics.html)
>   * [Admissions](https://www.nyu.edu/admissions.html)
>   * [Research](https://www.nyu.edu/research.html)
>   * [University Life](https://www.nyu.edu/life.html)
>   * [About](https://www.nyu.edu/about.html)
>
>
>
> All NYU
>
> Info for
>
>   * Back to main menu
>   * Info for
>
>     * [Students](https://www.nyu.edu/students.html)
>     * [Faculty](https://www.nyu.edu/faculty.html)
>     * [Alumni](https://www.nyu.edu/alumni.html)
>     * [Employees](https://www.nyu.edu/employees.html)
>     * [Community](https://www.nyu.edu/community.html)
>
>
>
> [Log In](http://home.nyu.edu/)
>
> Info for
>
>   * [Students](https://www.nyu.edu/students.html)
>   * [Faculty](https://www.nyu.edu/faculty.html)
>   * [Alumni](https://www.nyu.edu/alumni.html)
>   * [Employees](https://www.nyu.edu/employees.html)
>   * [Community](https://www.nyu.edu/community.html)
>
>
>
> [Log In](https://home.nyu.edu/)
>
> Search Site Search
>
> #  Events Calendar
>
> Search Events
>
> Apply Reset
>
>   * [About the Events Calendar ](https://www.nyu.edu/employees/resources-and-services/media-and-communications/digital-communications/university-events-calendar.html)
>   * [Events Calendar Tutorial ](https://www.nyu.edu/employees/resources-and-services/media-and-communications/digital-communications/university-events-calendar/tutorials.html)
>   * [Report issue or provide feedback ](https://nyu.service-now.com/sp?id=sc_cat_item&sys_id=7698dd2a98bcf4004c8c03063d84e274)
>
>
>
> Search Filters Calendar
>
> New York University
>
> Equal Opportunity and Non-Discrimination at NYU - New York University is committed to maintaining an environment that encourages and fosters respect for individual values and appropriate conduct among all persons. In all University spaces--physical and digital--programming, activities, and events are carried out in accordance with applicable law as well as University policy, which includes but is not limited to its Non-Discrimination and Anti-Harassment Policy.
>
> Unless otherwise noted, all content copyright New York University. All rights reserved.
>
>   * [Search](https://search.nyu.edu/)
>   * [Campus Map](https://www.nyu.edu/map.html)
>   * [Events](https://events.nyu.edu/)
>   * [Contact Us](https://www.nyu.edu/contact-us.html)
>   * [Give](https://www.nyu.edu/about/giving.html)
>   * [Copyright & Fair Use](https://www.nyu.edu/copyright-and-fair-use.html)
>   * [Privacy](https://www.nyu.edu/privacy.html)
>   * [Accessibility](https://www.nyu.edu/accessibility.html)
>   * [Feedback](https://www.nyu.edu/#feedback.html)
>
>
>
>   * [New York Campus](https://www.nyu.edu/)
>   * [Abu Dhabi Campus](https://nyuad.nyu.edu/)
>   * [Shanghai Campus](https://shanghai.nyu.edu/)
>
>
>
>   * [![](https://events.nyu.edu/live/resource/image/_i/themes/global/images/icons/facebook.rev.1773448757.svg)](https://facebook.com/)
>   * [![](https://events.nyu.edu/live/resource/image/_i/themes/global/images/icons/linkedin.rev.1773448758.svg)](https://linkedin.com/)
>   * [![](https://events.nyu.edu/live/resource/image/_i/themes/global/images/icons/x.rev.1773448757.svg)](https://x.com/)
>   * [![](https://events.nyu.edu/live/resource/image/_i/themes/global/images/icons/instagram.rev.1773448757.svg)](https://instagram.com/)
>   * [![](https://events.nyu.edu/live/resource/image/_i/themes/global/images/icons/youtube.rev.1773448758.svg)](https://youtube.com/)
> ```
>
> * This row is an **NYU events-calendar page** ("Fall 2024 Census Date"):
>   * the schema asks for just two fields: `registration_open_date` and `description`
>   * the prompt scrape captured only calendar nav and boilerplate: **there is no
>     registration date, or description**
>   * note the schema's `description` field even ships an *example* value ("Registration
>     opens for the fall semester") in its own field description
> * so a well-behaved extractor should *decline* to invent the fields the page doesn't
>   contain
> * let's see if the small model does the right thing!
>
> ## Step 2: extract with the mini model (text mode)
>
> * note: `gpt-5.4-mini` is very stochastic on this input -- even at `temperature=0` it
>   invents a different `description` on nearly every run. For a reproducible walkthrough we
>   **hard-code** the one canonical fabrication the rest of this notebook explains (and that
>   the verifier flags at P(wrong) > 0.8). A real pipeline would just take `extract(MINI,
>   prompt, schema, content, temperature=0)` directly.
>
> ```python expandable theme={null}
> EXTRACT_SYSTEM = (
>     "You extract structured data from documents. Return only values supported by the text. "
>     "Follow any value format specified by the schema or its field descriptions."
> )
>
>
> # LLM and TypeSafe calls are cached to ``json_cache.json``, which ships with the cookbook, so
> # re-rendering reproduces the published results with no API spend; delete the file to re-run live.
> json_cache = JsonCache(Path("json_cache.json"))
>
>
> @json_cache
> def extract(
>     model: str,
>     prompt: str,
>     schema: dict,
>     content: str,
>     *,
>     reasoning_effort: str | None = None,
>     temperature: float | None = None,
> ) -> dict:
>     user = (
>         f"{prompt}\n\nReturn ONLY a JSON object matching this JSON Schema:\n"
>         f"{json.dumps(schema, indent=2)}\n\nDocument:\n{content}"
>     )
>     kwargs = {
>         "model": model,
>         "messages": [
>             {"role": "system", "content": EXTRACT_SYSTEM},
>             {"role": "user", "content": user},
>         ],
>     }
>     if reasoning_effort:
>         kwargs["reasoning_effort"] = reasoning_effort
>     if temperature is not None:
>         kwargs["temperature"] = temperature
>     text = oai.chat.completions.create(**kwargs).choices[0].message.content
>     # The prompt asks for ONLY a JSON object, so parse the reply as-is -- no regex fishing a
>     # substring out of a malformed reply. If ``json.loads`` fails, treat it as an empty extraction
>     # (the record-level analog of NaN): every field reads as absent, which the verifier flags and the
>     # gate escalates -- the safe direction. Schema-following errors are rare here (see the overview).
>     try:
>         return json.loads(text)
>     except (ValueError, json.JSONDecodeError):
>         return {}
>
>
> # Hard-coded canonical fabrication (see note above); a real pipeline would use extract(MINI, prompt, schema, content, temperature=0).
> mini_record = {
>     "registration_open_date": "",
>     "description": "Registration opens for the fall semester",
> }
> print("mini extraction:\n", json.dumps(mini_record, indent=2))
>
> # The record is a perfect fit for the JSON Schema -- and still wrong. Schema validation is necessary
> # but not sufficient: it catches structural errors, never semantic ones. That gap is the whole point.
> print("\nschema-valid:", jsonschema.Draft202012Validator(schema).is_valid(mini_record))
> ```
>
> ```
> mini extraction:
>  {
>   "registration_open_date": "",
>   "description": "Registration opens for the fall semester"
> }
>
> schema-valid: True
> ```
>
> * The record is **schema-valid** (the line above prints `True`), yet it's wrong:
>   * `registration_open_date` is left blank, which matches the page: it states no date
>   * but `description` is fabricated: the page never describes a registration date, so
>     mini invents a plausible one. It may parrot the schema's own example, "Registration
>     opens for the fall semester", or narrate "...was not found in the document"
>   * a JSON-Schema check can't see this. A cheap model produces confident,
>     schema-satisfying fabrications of this kind, and catching them is the job of a
>     semantic verifier
>
> ## Step 3: verify with TypeSafe
>
> * the verifier is **TypeSafe**; for each field we build a `Noul` question:
>   * a narrow yes/no, framed so that `true` = something is wrong (escalate)
> * TypeSafe returns a calibrated `noul` = `P(true)` per question, in one system\_one call
> * the question set:
>   * one holistic **`__overall__::judge`** head ("should this record be escalated?"). We
>     compute and display it to contrast a whole-record judgment with the per-field heads,
>     but the gate in Step 4 does **not** use it -- escalation is driven by the per-field
>     battery.
>   * a per-field battery
>     * non-empty fields get the full set of heads
>     * empty fields (null / "" / \[]) get only the `absence_wrong` head
>   * (the full pipeline also has a `spurious` head for whole containers and an overall
>     `difficulty` score; not shown here, to keep this walkthrough to the two gating heads)
> * **The TypeSafe Way: Decomposition**
>   * Notice how everything is *programmatically decomposed*, this is TypeSafe way.
>   * Decomposition maximizes the intelligence of every prompt, and makes the algorithm
>     tunable and interpretable.
>   * *"this is the way" - the page's Mandalorian meme endorsing programmatic decomposition*
>     ![[typesafe-sde-cascade-002.jpg]]
>
> ```python expandable theme={null}
> # metric -> (question, NoulCriteria)
> MAIN_QUESTIONS = {
>     "name_desc_mismatch": (
>         "Does the `extracted_field` fail to match the field at `path` or the `description` in the "
>         "`field_spec`? If the `description` is empty, judge against the `path` alone.",
>         NoulCriteria(
>             true="the `extracted_field` does not match the field name or its `description`",
>             false="the `extracted_field` matches the field name and `description`",
>         ),
>     ),
>     "type_mismatch": (
>         "Does the `extracted_field` violate the `type` declared in the `field_spec`?",
>         NoulCriteria(
>             true="the `extracted_field` violates the declared `type`",
>             false="the `extracted_field` conforms to the declared `type`",
>         ),
>     ),
>     "unreasonable": (
>         "Is the `extracted_field` one that a reasonable person would not have extracted for this "
>         "`field_spec`?",
>         NoulCriteria(
>             true="a reasonable person would not have extracted this value",
>             false="the extraction is reasonable",
>         ),
>     ),
>     "hallucinated": (
>         "Is the `extracted_field` unsupported by, or absent from, the source text?",
>         NoulCriteria(
>             true="the `extracted_field` is a hallucination -- not supported by, or absent "
>             "from, the source text",
>             false="the `extracted_field` is supported by the source text",
>         ),
>     ),
>     "off_target": (
>         "Does the source text fail to genuinely report the thing the `field_spec` describes, so the "
>         "value was pulled from incidental text?",
>         NoulCriteria(
>             true="the source does not genuinely provide this field -- the value was pulled "
>             "from incidental text",
>             false="the source genuinely reports this field",
>         ),
>     ),
>     "incomplete": (
>         "Does the `extracted_field` fail to capture a value the source supports (note whether the "
>         "`field_spec` is `required`)?",
>         NoulCriteria(
>             true="the field is wrongly empty, null, or missing a value the source supports",
>             false="the field captures the value the source supports",
>         ),
>     ),
>     "format_violation": (
>         "Does the `extracted_field` violate the format or constraints implied by the `description`, "
>         "the schema `type`, and the extraction instructions (e.g. date format, units, enum membership)?",
>         NoulCriteria(
>             true="the `extracted_field` violates the implied format or constraints",
>             false="the `extracted_field` satisfies the format and constraints",
>         ),
>     ),
> }
> ABSENCE_QUESTION = (
>     "The `extracted_field` is empty, null, or an empty collection. Does the source text contain the "
>     "information the `field_spec` describes, making the empty result wrong?"
> )
> ABSENCE_CRITERIA = NoulCriteria(
>     true="a value was wrongly omitted", false="returning nothing is correct"
> )
>
> # The pipeline also asks one holistic, whole-record head: "should this be escalated?"
> OVERALL_JUDGE = (
>     "Is this extracted record an incorrect extraction -- some value unsupported by the source or "
>     "not conforming to the schema, required information missing or wrong, or some field hallucinated -- "
>     "so it should be escalated to a smarter model?"
> )
> OVERALL_JUDGE_CRITERIA = NoulCriteria(
>     true="the record is an incorrect extraction",
>     false="the record is a correct extraction",
> )
>
>
> def is_empty(v) -> bool:
>     return v is None or (isinstance(v, (str, list, dict)) and len(v) == 0)
>
>
> def field_spec(name: str) -> dict:
>     """Minimal spec pulled from the schema (unwrapping anyOf/null for optional fields)."""
>     p = schema["properties"][name]
>     branches = p.get("anyOf") or []
>     typ = p.get("type") or next(
>         (b["type"] for b in branches if b.get("type") != "null"), "unknown"
>     )
>     return {
>         "path": name,
>         "type": typ,
>         "description": p.get("description", ""),
>         "required": name in schema.get("required", []),
>     }
>
>
> def build_questions(record: dict) -> dict[str, Noul]:
>     """The verify question set: one holistic ``__overall__::judge`` head plus a per-field battery,
>     keyed ``field::metric`` (mirrors build_verify_prompts)."""
>     questions: dict[str, Noul] = {
>         "__overall__::judge": Noul(
>             instructions=OVERALL_JUDGE, criteria=OVERALL_JUDGE_CRITERIA
>         ),
>     }
>     for name, value in record.items():
>         spec = field_spec(name)
>         if is_empty(value):
>             questions[f"{name}::absence_wrong"] = Noul(
>                 instructions={
>                     "field_spec": spec,
>                     "extracted_field": value,
>                     "main_question": ABSENCE_QUESTION,
>                 },
>                 criteria=ABSENCE_CRITERIA,
>             )
>             continue
>         for metric, (question, criteria) in MAIN_QUESTIONS.items():
>             if metric == "type_mismatch" and spec["type"] == "unknown":
>                 continue
>             questions[f"{name}::{metric}"] = Noul(
>                 instructions={
>                     "field_spec": spec,
>                     "extracted_field": value,
>                     "main_question": question,
>                 },
>                 criteria=criteria,
>             )
>     return questions
>
>
> @json_cache
> def verify(record: dict) -> dict[str, float | str]:
>     """Run the whole Noul battery over a record in one TypeSafe call; return ``{field::metric: P(true)}``."""
>     state = {
>         "system_message": EXTRACT_SYSTEM,
>         "instruction": "Extract the structured record from this document",
>         "source_text": row["content"],
>         "schema": schema,
>         "extraction": record,
>     }
>     questions = build_questions(record)
>     answers = ts.system_one(state=state, questions=questions, model=TS_MODEL).answers
>     return {qid: ans.noul for qid, ans in answers.items()} | {
>         "playground_link": make_playground_link(state, questions)
>     }
> ```
>
> ### Run the whole battery over the mini extraction
>
> ```python theme={null}
> checks = verify(mini_record)
> playground_link = checks.pop("playground_link")
> display(
>     Markdown(
>         f"🔗 [Open this verification in the TypeSafe playground]({playground_link})"
>     )
> )
>
> print(f"{'qid':<40}{'P(wrong)':>9}")
> print("-" * 50)
> for fld, p in sorted(checks.items(), key=lambda c: -c[-1]):
>     flag = "  <== FIRES" if p > FIRE_T else ""
>     print(f"{fld:<40}{p:>9.2f}{flag}")
> ```
>
> ```
> qid                                      P(wrong)
> --------------------------------------------------
> description::hallucinated                    0.95  <== FIRES
> description::off_target                      0.85  <== FIRES
> description::unreasonable                    0.58
> __overall__::judge                           0.56
> description::incomplete                      0.16
> registration_open_date::absence_wrong        0.14
> description::format_violation                0.10
> description::name_desc_mismatch              0.08
> description::type_mismatch                   0.02
> ```
>
> <a href="https://console.typesafe.ai/playground#share/N4IgJg9gxgrgtgUwHYBcAqCAeKQC4AEIwAOiAM4CeZKCcA+omWQIYDmCpBpAmhDPlhQAnZlBT5qQmGJhCEYfGGYpm+AGZCIcRdHjIUZAHT4ASghSyk+CEgA2FfADdmtmAjISYABy8QhNBQAjBxQACwR8GmxjADEIW1sIAHd8ZiQHZ1cItT84ZQkvBCgASzVi+XxgyPCJKHC86yF8YoN1ctsFMHcoIWKvFGKbI1IAGnxSYqRJaQGbTnGQAFFsETFqiOmZOQU5KD8FDS1q4o9IWERUUYWyPiEoBDoolHnSAGUAaz7IiHw91H18B8vigfrAhHJUPgvGwIkhmI5iqxlIMkMRiKj0QBtfAAXQAFKEUCgvGRcAB6MlJKmGdIwQzyGBkgCUaIxSFeCGYd1CgJaHHRrOx+MJxNJFKpSRpFDpDOZrNZ+HwACp8NiAIJQZhdODFKBkYVEknkynU2n0sCM0Ra2i6oyEuC2FnoxUq9VgHVMFH6gmGsUmyVm2Vaj1kL2Ge2OhXK1Wmdyc7kG0XGiVSmUWslyMjxurhlAOp1WaPYgCqSGKjgQQlDKAcABlSghE0bxabpebGbYG7n81HXfg1YE+Cgm36U4H08xBzAUN3IwL52y1Ql8AA5bjF+XogDEioAshBAsVbBEV-DEcibOMF0KfUmWwG27KC6yOVy6ryaJvC66NdadXqR2TVs00tTVtVtWcCxdVU1XdE5QyGQD71TdsyWDeCwwjKCizMLM31CJD-RQ2VM2zUJIN7VVS3LStqzrBtCLHR9007NQEAo50iwHIdGOA1DJyHDi2S-JdbFXdcvwASSQHJ1D8L9oIAIVEd5vnwPJJnU5AYEo6TZJyJoFMVItXgsLpUG9EVmyI8dGWoGBzIMITjKLGJRBgWwa14h8QLJNR3M8ihnOMn9XDgMtvOIicwrLYLoMxRY4C8RIKAQdxItsslaGSiBUvcOKiwAYS0OAYDLLzb2spjfL2OBSvKoKsK-L9MVrCBWHwaSm2NUItHYzLn3RPSfgMozXVMhz9Es30gJ81D7Mcu08znb9VTc2BAoy5jGX8jaa2C0L4AiyrRz4oMYuKA7VUSnK8umu8bO2rKkpStKlp7TjXWKuqypaCgtpqkrfv2pqFxatqOq6k6er6qLGUG9kyI-CJX25L8d3wRYKws-BCpcZAlEMhdUffLGpqvRcfHsWMs2eBd4u46d1kx7HWjx48kEJ3FoeQzLste9wM3cW57jIABaNIwDFrMhARUWyUQMBimYCXObF2r6t1C8pjJJXWBaFx1aBstNVmHXforKs-rFhBWfFzUOcJq6Ert3H8c5rl8DQac-GVsSAdQ-ncreoWblkUXValmW5cFxXlcjo2fpN7WyF1xEDdsRPNdNr0yQt2jrdtqb1fdwmyQsEFehcd6VvisxfH8ZomDcRooU0BEunUNKwECFTuasv0zWj3UEDFpBkkMWqyTILwAH5ijAABeMgoDoU26D5OAADJKDIDel4AdgANgATgADjAMAACZmHPwIoDUAAWAAGZ-H6gM+oGfgBmZ+j+-sAZ9H4ICvgfR+CMvwkx5DEI8NAqxu0dlyL8K4EApF4EIVS1FLZ0QpqyRYABHGALh8AAHkfB+AsA1VInNVw2DFgAEROD0YoOo4Rm1SOINcxZ8Bi1XKg-A6DMFlmwX9JuvwSotACGpDSqBmCTEmB1NIAgkAIk0EgC44gwj5GQHsWQMIPCSzktQWi+BMyFDWAZZonNywLyIWJTIbgDE0OYD4TQXgq40HEZzGYqQ4A2EUcuQoVYhjGGkqkZcWCC41gKKIdwYsxZeFCFQLWYlDF6wzvE9x7URB1QUWMUQAwEQDHcPkmhRccZcgiJqcE5QFBDisakKAewhBKCQPcfASQWg8hcclLWgRjz4FsMwFIzAPBJAQMuUZ+BIlW2ib4TsUAKBjCSKEXUPJJhQFcF0DwgQmYnHwOPcQnYdRSJBM0VoK46GMJXr0Vh2tqEKDVKgYoYsAASXJRlkA0fgAACvEXUQVcHolLMeJg1gwiVk6VmA5EAAj5OXH8GgkI9heAoL0VghI+FoL8EImiszAWiVMYiQkHhSKy3kMYMaqooGETwtyOGcpPqqjxklGAHhdwuIDrKPIXhnZkwsoRcpTkBqUUxMVWRaxiz3SqmddMiKClizZc7AA4jRLlE4pwoDJPrBESBWDO2Kqi9FmKt74DcsUJoUrGw80eoDI1xKUAJ38haxVWZnY-N6M4RZ6rGTuPLKIRqy1sI-iae4UMh5OwVQHrNBlohRbhqPH9Z2MRu69ygO8H1ZItxsXkGm94QlmpMsxCg7FGC3asuladOaT5RUDn4PQ0Ik5ijlq8GywitItQMuDdSxterG3NpZa2ytxoyC9oxXIrtha2TxQAISYkFXbBlnYKyhxFggMkLCYRkg3uXeogtWCJF7rYDdeR2Cp11EMPysTBwQHzXIRwhgACMB8D7f0fo-M+B8ACsB9DBkEcKwJkhFdoIBvfmqe3bMRzoXVNJdNFV3h3XZu9g27ii7toPuw9LgT36I3X8VOnYkDvHkJMQw96n0vrfR+79Z8-0AaAzawjxGlZIEnloRlq0oPzptUKowmVl3rszGunDKGd0QsYNqrDx7kOCwvTrTAZHbYUdfe+z9P66OAcIgpiDoroM8cXfx+DQnEMifXWJvdqcD0HmwzJ89+GN1TBUKwHJimH3PpU9R9T-7NM2smNQNgLmdNFr09GikvG4MruM3cJDp6zNofE5h6z0nYt2cvRQIcMBAjsXI+5qjanaPeYY6Fsk6XpyZfYkF4SAoQBjFICveozB5gkBAFkoJxSyBNdIHIfWkhtZ0AgIUJAdAlCfjwPgZr2zmH9BRC8EAaAagjYiFo8Q3WTjCHuQN5AHhLEQvUC4MSWZGBwOMLuYsrw0CVAiJpXbBk8jiDqrrMAJWKAvdiH4AQmBmAvQQGMSxqg9gJAQOwBpu2r7Pyvo-MWYOr5ftqL1eI+BUpcjGC0dSDrLsSD6mEBRgzijEfwM-E+ZJn5frJNDx+xgzAWCEFYVQ-S0iqUkDj0oiO+CpDkPgMqZBZDsSuKQAYKBjyzbMD19b7CyHIHwPQ5QHAasLBrIUWbTO9WkAAL61fAN0Xo025hjYm1rvoZtZtqkqL0BAahFAG511YCAFvdurd6+wzbVhFtvaaFgL7yUfv4AAOQi7WyIJ3g3tvvZu-tiQGHjFCB94YPnIABdC7G6QehVujdy-5xQRXSfyDCAUWr9XCw5CEItfIeYmIutA4D3153w2Zdx8m9rtPOINcJ9l1wEA-vHcogl6idP8fM9t4WAeAAVkUZ4IAC+kEEKsNPBBmsO7Fyifrg3a+jfb-X1PM3s+d8X5eZ3Iemhh+XId9wcD89y5a5oJKBgMDYDG0QUgdB+uW320-3AuBh8OXYJ1-vWf2-jw8jjz82EBmC9Fm0kg8Gxw8GnwKQqF2H2GoSsWaV2HEBgLEBRB4V4RuEQCcBcBbi528AbikSqF2zDmi1bkOS8VuxxzOVILqFoGYDGCLxgBLwUEmFu3uRDBx3eySDUVYDGHe2wOyHaAUEbQSGkEmBlwUHiUx3OQkF6g8iCAiG6BcCkLUlUC+S5DgXUggC6FsFnjj2YTgWVh-xAMH35xqHgJaTESUQ2T8BQI+3W3QN1w138lsCzFm3tyKAQP2X+3sLH0cJny31V0nxAAX0DyXxr0W3f0nCzDaQeF4P8VMIH1mwANsCAMcykGcKmB-zKAmTADoBniKB-2hDCFm3COrxX0WzjwV3MJz16BVz7wb0Ny33b3mwiEW2qHyAqKDy2zkkPxqDcIO0j2O3wFO3Owx2u0GNyHyAe0vme1ezNXew92+1+3ez8MB2BymIiHJyh3B1h3qwgARyRyEBR3u3Ryy0x0QGxz1Vx3x0J2J1J3J0p3MEsFSEqCGSIwkFz1uJZ1K3ZwiAILkFjz72YNYPmDMNCLQICDoDyI6FmzjxkToEIVP1aIWHaPwAAANoT5BYSRDMSxFsoawxgkAPJbABCmglEiSHAAdjxsjjB6EIB3BmYyD2kngvEVBtirEOD2FdtMS4SCiiioACTmissyAxg8hPhbjdtqTTF3APJxBEi9UDCJ8NcjDKwTC9d+cpA6jVAHEIgkgpklSD0HAtBJFS8+83CPDs85BqcyxbjDlVlfiPBkCx988Ndmjrd384REBhtugGATg7s6hki-8Fg0iMjNgzYOstSQABTCjzESjlBQhZtPS08W8Ujs9ldWAN8bkWjdd28TdAgzcLdUyMDbdmYeiyzBtFAZc3cPtPdjwxg-dK8u899g9+jmYhiI8jtKwY848wTtgISdSoSVhYCCiBThcWzd8bd2ydtBjw8T8o9ES5EhsUTqA0Tk8mTICahsTRyxBcSBSCTnUxIzkgyeQbsRCOEsTSjQgCTQ8dzSybACSuT+SRD4yihMTZ5Oo7cHzN8nzCTr8ll8BP8wBgc2AVzqBmZMSbyCSXAbBedVSFh1Sq5TCdTPCdycTxz8SdBmTKCzzOzLyfSIh3sWgPBMTHykBMS48rS6i+TMK8T8iCSzzmSLz8iDkvsIhDFyK-zKL3SFgKL39aiAzNCUBgyYzajUi+B0i+9gCsiozci3yhTEyyjs8KKaiMz28sycyptZ8FhCzizLdczrdrAfyIhKy2zJdXclj3dPtVjfcd8IiLKpgOyj9hiezo8QSNcByLSCBISNd6KJzt8pzHKZy+i5zsgFyRjKxlzJhkTHFdLNyWKMK9yYTDynBBghlPE+TaiRSighltgQcdy4yhTPy1c1TehjDGtxK0Ls86KUqDzsKER4gZdtyOi8rKkFBMScrqLq5aLkqnDUrsK-hbtICfhdsuhNkOqsTuqJ9QiBLcAyo5BRkbBJxE858M9QzSBwyZLMjQChgFL8j3yoBlLkzVKeL1LNr6i88mjzrs99LygSyeKTKKzgqNtqyrK4gbKGzvdmzRcQrrBZz7yIrj8oqPL+yEBi9Byxs-KFgAqRDJy-q3qwqga9sQb3KYrVz4qNyQAICoK4bGLrAkAltG1xBVAlqbg4R+kIggkKaOkpKFBKDG0KxAixyXLVkyLirzFSrELSBkLNT1r48ar28ybOQKbVrqbaJLwkh6aYVxAmblD6qFAoDcCsger3C+qFaBqMD9lyaVqqa+LSB5qxDXASg2EfLxsNq6jtqNdZK9qciYzObiiYybyUzbr0zLqtKbqjKEqQB7rzdDKdKyzTK5TEbeiXdazrL6y7Lfqq8w6D9OzIr3K+zQSIaWCobfLhz-LFaGL4SgrQ6qzkaBjga3LT9oq+8kS1yfbca6qBqGqCaCDyF-AKhggKTUhAg4jxBDg4AxhSC11IhBAVTQi+aqqBazD0KIhdza6sKCbfD8BjaJC2EMCZDKDudG7iCgL1j26AQu6e6ahWSltBA1brT28a6Z866OhnyPBV6iDm6Qg96+6ngDbNdvaUR39bc1BHguR2Bx9R6NKwypKIyQDsjoyBbHbjrnakzXaX6XD5c-66sfjsyvbA78y9LTcHqA7G8g6Xr86nKayaA6yVivcmyHKkbnLwrUaS6o9k6vLU7wTobM7Ybs7Ar28SG462bi7uzS6hAMa4rUSUHErWrMdEN+7sA9sjw1J2BSTJgJkHA5AiDmYbiOo+SwHcrcyxSxgbhmZ9SOkplW1AcDgr8kCF59BiEnhB7yq+QULqq3Bx6hHyDIBcLYV8BJGWCibqYskO5ib9kBTMCtG8CDTdGySKgu6jHHJTHD7LTerbH97nHtJpHqY5GKFtzvH4bZqPSeL387Dvs18Lbf8raAGdrIywCHbFKEyIGVL281K+8JLMyEHtLMH+Hfa0H-aKLnqvCcHQrw78HI7CHGz7LXq2HyGuzFy4FqHC9aH07IgGGp8mHUmWGBmC6yGUbhnQaeHK7sbGSkqJ78aL6xGTzQQXFqdOKVaW5e7hHr6kn8A8RDkDTwgIUi6sSVGxFMTvKwBMSmRzGkKKqNSR7cmx7arBjLz9ljTqZqSSSyTW6uDbi9T-GWS+6Ln-BozXComAXhC2LNR+gedBHtGznyCEWDAn75qeS6AmrMq0Tmsan-8CmbbdrgGDqOgjqTqoHkHe93a6jPb0noHe8CzmnHquW2nLCFncGPrljbKiH+mOmAbC6E60auGxmK9IbzaYaZmp6c6wAEbY7Fn47XLOGlzy6VzeH1zGnNnBHJ6z7p7dnSWZdOyZjxB3t8N1tJhWgWFelb6oKKLMTd6Nh6CGguqB9PWHlmZoTtbaWoyrn2J9U8HshbWxhgZxTlF4AtI4AssqxVkvAPmyqvnLH+a-mhb5d+rzW1WCSrWaBBGXXOxgnbXW4HWRAnWkWFgaLbGzWxyi2JBkQyA8jBGeTA2a2VyCXZrVcL8XFigAA1AuGwe-RwR9CfIAA" target="_blank" rel="noreferrer" className="text-primary">Open this verification in the TypeSafe playground →</a>
>
> * TypeSafe concentrates the signal on the fields that are actually wrong.
> * Our results are calibrated: high on the field that is wrong, low on the field that is
>   correct, medium on a field that looks off without being clearly wrong
> * This is what a typesafe verifier buys you over a blunt "is this whole thing good?"
>   judge
>
> ## Step 4: the escalation gate
>
> * now we gate on **`any_flag`**: escalate if *any* field flag exceeds `FIRE_T` (0.7, set
>   above and shared with the `<== FIRES` marker in Step 3)
> * this is a `max`-style gate (escalate if *any* field fires), not a mean, so one confident
>   red flag is enough instead of being averaged into silence
>
> ```python theme={null}
> # any_flag is a per-field gate: the holistic __overall__ head is shown above but not part of it
> fired = {
>     qid: p
>     for qid, p in checks.items()
>     if not qid.startswith("__overall__") and p > FIRE_T
> }
> escalate = bool(fired)
>
> print(
>     f"any_flag gate (threshold {FIRE_T}): {'ESCALATE' if escalate else 'ACCEPT cheap result'}"
> )
> for qid, p in sorted(fired.items(), key=lambda c: -c[1]):
>     print(f"  fired: {qid}  (P={p:.2f})")
> ```
>
> ```
> any_flag gate (threshold 0.7): ESCALATE
>   fired: description::hallucinated  (P=0.95)
>   fired: description::off_target  (P=0.85)
> ```
>
> ## Step 5: escalate to the reasoning model
>
> Since a signal fired, we pay for the strong model (`gpt-5.5`, `reasoning_effort="high"`)
>
> ```python theme={null}
> final_record = (
>     extract(REASONING, prompt, schema, content, reasoning_effort="high")
>     if escalate
>     else mini_record
> )
>
> print("mini      :", json.dumps(mini_record))
> print("reasoning :", json.dumps(final_record))
> print("\nfield-level diff (mini -> final):")
> for name in mini_record:
>     if mini_record[name] != final_record.get(name):
>         print(f"  {name}: {mini_record[name]!r}  ->  {final_record.get(name)!r}")
> ```
>
> ```
> mini      : {"registration_open_date": "", "description": "Registration opens for the fall semester"}
> reasoning : {"description": "", "registration_open_date": ""}
>
> field-level diff (mini -> final):
>   description: 'Registration opens for the fall semester'  ->  ''
> ```
>
> * **The improvement**
>   * The reasoning model drops the fabricated `description`, returning `""`
>   * It recognized the page never describes a registration date, and declined to invent one
>   * The cascade turned a confident, schema-valid fabrication into an honest empty field
>   * And it only spent reasoning-model dollars on this one item *because the verifier told
>     it to*
>
> ## Step 6: what this looks like on 100 prompts
>
> * **These are internal TypeSafe results**, produced with the general method above:
>   * the same `extract → verify → escalate` loop, `gpt-5.4-mini → gpt-5.5-reasoning`,
>     `any_flag` gate over the per-field heads, run over 100 scrapegraphai prompts
>   * each item's cheap-rung extraction is scored by TypeSafe; the gate threshold ("cut") is
>     swept 0→1, and every resulting config is plotted in (cost, quality) space
>   * the chart is a historical snapshot; its costs have not been recalculated at the
>     current Jev rate listed above
>
> *Internal TypeSafe results: cost/quality frontier over 100 scrapegraphai prompts. Title "Pareto frontier - color = strategy, marker = #rungs (up-left is better)". X axis mean cost in dollars per extraction, to about $0.048. Y axis "mean llm_judge", 0.675 to 0.850. Black diamonds are the four single models with plus or minus 1 SEM bars in both axes; blue dots are the any_flag cascade at swept gate thresholds; dashed line is the Pareto frontier.*
> ![[typesafe-sde-cascade-001.png]]
>
> * how to read it:
>   * **black diamonds** = the four models run on their own (cost climbs with capability; the
>     strongest, `gpt-5.5-reasoning`, sits top-right at ≈0.81 quality for ≈\$0.10/extraction)
>   * **blue points** = the cascade at many gate thresholds; the dashed line is the **pareto
>     frontier**
>   * the cascade frontier sits **up-and-left of every single model**: sweeping the gate buys
>     you most of the top model's quality at a fraction of its cost
>   * the cheap rung handles the easy items for near-free, and only the flagged items pay for
>     the reasoning model
>
> ## Appendix A: what makes a good verifier signal
>
> * the cascade is only as good as its verifier; what separates a useful signal from a
>   useless one:
>   * **Narrow and grounded.**
>     * one checkable yes/no about one field against the source (e.g. "is this value absent
>       from the source?"), not a vague "is this extraction good?"
>     * vague questions give mushy, uncalibrated scores
>   * **Bad = TRUE, with explicit criteria.**
>     * frame each question so the *escalate* case is the `true` case, and state what
>       `true`/`false` mean
>   * **Per-field, then aggregate with `max`.**
>     * a per-field flag localizes the error and stays sparse and strong
>     * `max` ("any flag fires") ensures one confident red flag escalates, instead of being
>       averaged into silence
>   * **Independent and cheap.**
>     * a dedicated verifier (here, TypeSafe) judging the output catches the extractor's own
>       blind spots
>     * it has to be cheap, or there are no savings left to capture
>   * **Separating / calibrated.**
>     * a good signal is high on real errors and low on correct ones, so a single threshold
>       cleanly splits accept vs escalate
>     * that separation is what pushes the pareto curve up-and-left
