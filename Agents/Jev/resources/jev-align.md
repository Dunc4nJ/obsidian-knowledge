---
created: 2026-09-19
source: https://github.com/sutro-sh/jev-align
description: Sutro's CLI that adapts TypeSafe's Jev to your judgement by running GEPA over the text of the question and its criteria — an active-learning loop that mutates prompt components, never the model and never the 0.5 decision threshold.
type: resource
tags: [jev, jev-align, gepa, calibration, prompt-optimization, sutro, cli]
status: unread
---

## What it is

`jev-align` is an experimental Python CLI from [Sutro](https://sutro.sh/) that builds what it calls AI Functions on top of [TypeSafe's Jev](https://docs.typesafe.ai/introduction). You point it at a CSV, Parquet, or JSONL file and a question; it evaluates the rows with Jev, finds the ones Jev is least sure about, asks you to label those by hand, and then runs [[GEPA prompt optimizer beats reinforcement learning with 35x fewer rollouts by reflecting on natural-language execution traces|GEPA]] to rewrite the task definition so Jev's answers match yours. The result is saved to disk and can be loaded back into an application as a callable.

Apache-2.0, version 0.1.2, published to PyPI, created 2026-09-19 and at 61 stars and 7 forks the same day. It supports four task shapes matching Jev's output types: Binary, Multiclass, Multilabel, and Score. Jev can be reached directly through TypeSafe, through Vercel AI Gateway, or through Cloudflare Workers AI. The README closes with "Sutro is not affiliated with TypeSafe AI, the makers of Jev."

## Why it's interesting

This is the first third-party answer to a question the [[TypeSafe's Jev trades string generation for parallel-sampled typed decisions with calibrated probabilities at $0.042 per MTok - the 193x and 444x claims come from four self-built workflow evals|TypeSafe launch]] left open: how do you adapt a model you cannot fine-tune, that does not generate text, and that emits probabilities over a schema you declared up front? Every familiar lever is gone. There are no weights to touch, no output tokens to constrain, no chain of thought to steer, no decoder to sample differently. What remains is the wording of the question and the wording of the criteria — and that is exactly, and only, what `jev-align` optimizes.

The design insight is that Jev's typed contract turns prompt optimization into an unusually well-posed problem. Because the output is a fixed schema rather than free text, the metric is a plain classification metric with no judge model and no parsing, and the search space is a small dictionary of named text fields whose keys are locked. GEPA's usual job of optimizing a multi-module language program collapses to mutating three to eleven strings against F1. It is the cheapest possible target for a reflective optimizer.

The honest caveat, and the reason to read the code rather than the launch post: the word "align" here means fit, not calibration. Nothing in this tool measures or improves the quality of Jev's probabilities.

## How it works

**Input format.** Any CSV, Parquet, or JSONL file. You choose which columns feed the model, or concatenate all of them. The default pool is the first 1,000 rows, or the whole file if smaller. Each row becomes a `Story` whose `state()` is just `dict(self.fields)` — the selected columns, nothing else. No examples, no instructions, and no labels are ever injected into the state, so the Jev call sees only the row.

**Acquisition.** `select_batch` in `acquisition.py` ranks unlabeled rows by ambiguity and takes the top `batch_size - exploration_count`, plus a random audit sample. Ambiguity for a binary task is defined as

```python
def ambiguity(probability: float) -> float:
    return 1.0 - 2.0 * abs(probability - 0.5)
```

so a probability of 0.5 scores 1.0 and a probability of 0.0 or 1.0 scores 0.0. For Choice and Score tasks it is `1.0 - confidence`; for Multilabel it is the maximum ambiguity across the label probabilities. The default round is five annotations, four ambiguous plus one random. The Advanced menu offers 5, 10, 15, or 20.

**What GEPA mutates.** The candidate is the persisted `TaskSpec` itself, flattened by `as_gepa()` into a dictionary of named text components. For a binary task that is exactly three strings:

```python
class BinaryTaskSpec(BaseModel):
    instructions: str
    true_criteria: str
    false_criteria: str
```

Multiclass flattens to `instructions` plus one `criterion::<class>` per class; Score to `instructions` plus `level::0` through `level::N`; Multilabel to `instructions` plus a `label::<name>::true` and `label::<name>::false` per label. `from_gepa` rejects any candidate whose key set is not exactly the expected set, so the optimizer cannot add, drop, or rename a class, a level, or a label. Score components are additionally capped at 1,200 characters for instructions and 600 per level, and are rejected if they contain the marker text of another component.

That is the entire tunable surface. **The decision threshold is not tuned.** `_binary_label` in `optimizer.py` is a hardcoded cut at one half:

```python
def _binary_label(prediction: Prediction) -> bool:
    if prediction.probability is None:
        raise ValueError("binary evaluation received a Choice prediction")
    return prediction.probability >= 0.5
```

`_multilabel_labels` applies the same fixed `>= 0.5` per label. No few-shot examples are added to the prompt, the state schema is explicitly frozen by GEPA's `background` string, and the reflection instructions tell the optimizer not to "memorize story-specific wording."

**The metric.** `F1BatchEvaluator.__call__` in `optimizer.py` is the scorer. It groups the proposal-by-example pairs by candidate, evaluates each distinct candidate against its rows in one batched Jev call, and returns a **batch-global F1** for every row in the group:

| Task | Score returned |
| --- | --- |
| Binary | true-class F1 from `binary_metrics` |
| Multiclass | `macro_f1` from `multiclass_metrics` |
| Multilabel | `micro_f1` from `multilabel_metrics` |
| Score | `fit_score` from `score_metrics`, defined as `max(0.0, 1.0 - mae / (level_count - 1))` |

There is no log-loss, no Brier score, and no expected calibration error anywhere in `metrics.py`. The probabilities Jev returns are used for two things only: choosing which rows to show you, and decorating the reflection payload.

**The reflection payload.** Alongside the scalar score, each row returns a dictionary that is what GEPA reflects on — the row's state, the expected and predicted label, the raw probability or confidence, an `error_type` of `false_positive`, `false_negative`, `misclassified`, `label_mismatch`, or `score_error`, the batch confusion matrix, false-positive and false-negative label sets, and this:

```python
"human_rationale": example.get("rationale") or "No rationale supplied.",
```

The optional sentence you type when labeling a hard row goes straight to the reflection model as boundary guidance. This is the genuinely novel part. The GEPA paper's "actionable side information" is normally scraped from execution traces; here it is a human explaining their own decision boundary in prose, which is the one signal a typed probabilistic classifier cannot produce for itself.

**The GEPA loop.** `optimize_candidate` calls `gepa.optimize_anything` with Pareto candidate selection over a cartesian frontier, strict-improvement acceptance, `PxNSampling(p=2, n=2)`, and `AllImprovements()` selection. The reflection batch is chosen by a custom `ClassAwareBatchSampler` that fixes one recent, label-diverse batch of up to five rows for the whole run. `module_selector` is `round_robin` for Multilabel and Score, so a rubric-wide reflection is not pasted into every component, and `all` otherwise. The metric budget defaults to 300 calls per round. Two details are worth quoting because they are where the implementation diverges from the paper:

```python
# Each returned row carries a batch-global F1 score. Per-example
# caching would reuse that score in a differently composed batch,
# corrupting macro-F1 once the labeled set grows beyond five rows.
cache_evaluation=False,
```

GEPA's Pareto frontier is designed over *per-instance* scores, so that a candidate which wins on even one hard example survives. Here every row in a batch carries the same aggregate F1, so the frontier is effectively over batch-level performance, and per-example caching has to be disabled to keep that aggregate honest. The optimizer also sets `skip_perfect_score=True` with `perfect_score=1.0` and a `ScoreThresholdStopper(1.0)`, which stops the engine outright once a candidate scores a perfect F1 on the labeled batch — a real possibility with five rows, and the same saturation failure mode described in [[dspy-agent-skills shows GEPA only improves when there is failure signal - 1.2B models gain 25 points where 8B+ no-op]].

**Validation.** `optimize_anything` is called with `valset=examples` — the same list passed as `dataset`. Training and validation are the same rows. A 20% held-out split exists but is off by default, and `holdout_fraction` is validated to be exactly `0.0` or `0.2`. When enabled it adds 20% extra annotations per round, is filtered out of GEPA's examples by `evaluation_split == "holdout"`, and is scored separately into `previous_holdout_metrics` and `proposed_holdout_metrics`. AGENTS.md is blunt about the default case: "The score uses accumulated labels and is not a held-out generalization estimate."

**What a round reports.** The before-and-after task metric on the labeled set, an `ambiguity_summary` over the fixed 1,000-row pool before and after, the same over a replay of the training rows and over any captured production rows, the holdout metrics if enabled, and a diff of the proposed definition. The ambiguity summary is count, mean, median, and the number of rows at or above 0.5 and 0.8 ambiguity. This is the "certainty change" the README advertises. It measures how decisive the model became, not how well its probabilities track reality.

**Human gate.** You accept, reject, rewind, or quit. `b` steps back a label, `/back` leaves the rationale prompt, and `b` on the first item of a later round rewinds the previous optimization round after confirmation, archiving the invalidated state under `rewinds/`. The README's rule: "Every label comes from you. A higher training score never accepts a proposal automatically."

**Output artifact.** A run directory under `.jev-align/runs/<run-id>` holding `state.json` (the accepted `TaskSpec`, the backend provider and model, column selection, seed, budgets, holdout IDs, and full accept/reject history), `labels.jsonl`, prediction caches, per-round reports, and the raw GEPA result JSON. It is consumed synchronously:

```python
from jev_align import AIFunction

is_aviation = AIFunction.load(
    ".jev-align/runs/<run-id>",
    capture=True,
)

prediction = is_aviation(
    title="Airport expansion",
    text="A new runway opens next year.",
)
```

`AIFunction.load` reads the accepted candidate only; pending proposals are never loaded. The return is a provider-neutral `Prediction` exposing `probability`, or `choice` and `confidence`, or `label_probabilities`, or `score` and `confidence`. Note that the runtime hands back the raw probability and applies no threshold — the 0.5 cut exists only inside the optimizer's scoring.

**Continual learning.** With `capture=True` the function records live calls to JSONL in the background, by default those with ambiguity at or above 0.8 (probabilities from 0.4 through 0.6 for binary) plus a random 5% audit. Capture adds no model call. On resume the CLI offers to import them for labeling, deduplicated, with the original pool and holdout excluded. The model's own recorded prediction is never treated as truth.

**CLI usage**, verbatim:

```shell
uv tool install jev-align
export TYPESAFE_API_KEY="..." # Or use Vercel or Cloudflare below
export OPENAI_API_KEY="..." # or ANTHROPIC_API_KEY / GEMINI_API_KEY
jeva
```

```shell
jeva optimize posts.csv \
  --question "Is the post related to aviation?" \
  --column title \
  --column text \
  --pool-size 1000
```

```shell
jeva functions
jeva optimize --resume .jev-align/runs/<run-id>
```

**Cost and runtime.** The README and AGENTS.md publish no dollar figures and no wall-clock times. The only budget number is GEPA's default of 300 metric calls per round. Deriving the rest from `session.py`: each round also runs a full-pool evaluation of the proposed candidate — 1,000 Jev calls by default, cached per candidate — plus two evaluations of the labeled set, plus two more if holdout is on. So roughly 1,300 Jev calls and a few dozen reflection-model calls per round, at concurrency 16. At Jev's advertised $0.042 per MTok the Jev side is close to free, which is precisely why the loop is affordable.

## Key links

- [GitHub](https://github.com/sutro-sh/jev-align)
- [Launch post by Seth Kimmel](https://x.com/sethkimmel3/status/2101357768640987302)
- [Sutro](https://sutro.sh/) — the company publishing it
- [TypeSafe docs](https://docs.typesafe.ai) — the Jev API being tuned
- [GEPA](https://gepa-ai.github.io/gepa/) — the optimizer, pinned as `gepa[full]>=0.1.4,<0.2`
- [AGENTS.md](https://github.com/sutro-sh/jev-align/blob/main/AGENTS.md) — the real operating manual, longer and more candid than the README
- [LiteLLM providers](https://docs.litellm.ai/docs/providers) — how the reflection model is addressed
- [PyPI](https://pypi.org/project/jev-align/)

No images. The README's only media is a bare GitHub user-attachments link to a terminal screencast; there is no architecture diagram and no before/after chart to preserve.

## Notes

**"Align" means fit, not calibrate, and the distinction matters here more than usual.** [[pg-jev|Jev's]] headline property is calibrated probabilities. This tool never measures that property and never improves it. It optimizes F1 at a fixed 0.5 cut, which is a decision-quality metric that is invariant to any monotone rescaling of the probabilities. A candidate that makes Jev wildly overconfident but flips three borderline rows the right way scores strictly better. The probabilities are consumed only as an ambiguity signal for active learning and as context for the reflection model.

**It is the tool that would produce the number [[jevlike]] never publishes — and it does not publish it either.** The jevlike note observes that its evaluator computes ten-bin expected calibration error and then reports it nowhere. `jev-align` is the natural place for such a number to appear, since it is the calibration step in the workflow sense, and it holds labeled data and model probabilities side by side in `evaluate_labeled_candidate`. It computes no calibration metric at all. Across both repos, the load-bearing claim of the System One framing remains unmeasured in public.

**Training score and validation score are the same score.** `valset=examples` with `dataset=examples`. Holdout is off by default and capped at 20%. With the default of five labels per round, early rounds are fitting three strings to a handful of examples chosen precisely because the model found them hardest, which is close to a worst case for overfitting. The product design compensates socially rather than statistically: the human sees a diff and must accept it, and AGENTS.md warns agents not to treat a higher score as approval. That is a real mitigation, but it is a mitigation by human veto, not by measurement.

**How many labels before it overfits is unanswered and probably unanswerable as configured.** With no held-out set by default and a stopper that fires at perfect training F1, there is no signal that would distinguish "the definition now captures your criteria" from "the definition now describes these twelve rows." Anyone running this seriously should turn on `--holdout` from round one and treat the held-out metric, not the training F1, as the accept/reject input. The same discipline the [[BARGAIN routes classification to a small model via a confidence threshold calibrated on 500 oracle labels, cutting costs up to 86 percent more than competing cascades|BARGAIN]] work applies to threshold selection — spend a fixed labeling budget, measure on data you did not tune against — applies here, and BARGAIN's complementary lever, tuning the confidence threshold itself, is the one knob `jev-align` leaves untouched.

**The reflection model is the expensive half, and it is inverted from the usual economics.** GEPA's reflection runs on OpenAI, Anthropic, Gemini, or any LiteLLM endpoint, and it is the component doing the actual writing. Jev is the cheap thing being tuned; a frontier model is the expensive thing tuning it. Per round that is roughly 1,300 Jev calls at $0.042 per MTok against a few dozen frontier reflection calls on payloads containing full row states and confusion matrices — so the reflection side almost certainly dominates the bill. That the repo documents local vLLM and Qwen3-8B as reflection backends suggests the authors know this.

**Portability across Jev versions is recorded but not protected.** `BackendConfig` persists `provider` and `model`, defaulting to `jev-1.13.0`, and `AIFunction.load` reconstructs the backend from that saved value, so a run always knows which model it was tuned against. Nothing revalidates when TypeSafe ships a new version. Criteria wording tuned against one model's decision boundary is exactly the kind of artifact that silently degrades under a model update, and the tool provides no drift check — only the capture loop, which will surface the damage eventually as newly ambiguous production rows.

**The GEPA integration is a real adaptation, not a wrapper.** Three choices show someone read the paper: disabling per-example caching because batch-global F1 cannot be reused across differently composed batches, round-robin module selection so a whole-rubric reflection is not pasted into every Score level, and locking the component key set so the optimizer cannot quietly change the task. The cost is that the Pareto frontier no longer operates over per-instance scores the way [[GEPA prompt optimizer beats reinforcement learning with 35x fewer rollouts by reflecting on natural-language execution traces|the paper]] describes, since every row in a batch carries an identical aggregate. Whether batch-level Pareto retains the paper's sample efficiency is untested here.

**Where it sits in the vault.** This is [[DSPy is a framework for programming—not prompting—language models through typed signatures and metric-driven optimizers|DSPy's]] separation of task definition from prompt wording applied to a model that has no prompt in the usual sense — the signature is Jev's typed schema, the optimizer is GEPA, and the only free text left is the criteria. [[Quarq Labs frames GEPA and RLM as complementary context layers - GEPA optimizes static prompts before inference while RLM decomposes context at runtime|Quarq Labs' framing]] of GEPA as the static pre-inference layer fits exactly: there is no runtime context to decompose when the model consumes one row and emits one probability. See [[moc - Jev]] for the rest of this thread.
