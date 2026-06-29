---
created: 2026-06-29
description: "@h100envy walks through 'loop engineering' applied to RAG tuning: instead of hand-turning chunk size, embeddings, and rerankers, you build a loop that searches the configuration space by coordinate descent, measures recall@k on an eval it cannot lie to, and stops when it hits a target — defended by a held-out split against overfitting and budget brakes against runaway cost. Ships full Python."
source: https://x.com/h100envy/status/2070852290878009586
type: framework
---

## Key Takeaways

The thesis is a discipline, not a trick: **RAG tuning is the canonical task to hand to an automated loop, because it has a check you cannot argue with.** Recall@k on an eval set is a number — above threshold or not, like a green test — so the loop always knows whether it hit the goal without a human in the read-back. Tuning is also a *search over a configuration space*, and search is exactly where a loop beats a person: it doesn't tire, doesn't lose track of which combination gave what, and methodically remembers what it already tried. A human gets confused after the tenth run; the loop does not. This is the same loop-engineering rule that powers [[Claude Managed Agents loop design with verifier sub-agents and cross-session memory lets Fable 5 outperform Opus 4.7 by 6x on Parameter Golf|verifier-driven agent loops]] and [[autoresearch can auto-improve any agent skill by testing and scoring in a loop|test-and-score skill self-improvement]] — only here the verdict is recall, not a passing test.

The non-obvious engineering is **everything that keeps the loop honest**: a held-out eval split so it can't overfit the specific questions (reward hacking with a numeric metric), a noise threshold so it doesn't chase a 0.87→0.90 flutter on 30 questions, and a *pre-flight* budget brake so an expensive config never gets run after the money is already spent. The loop's worth is the reproducible process it leaves behind — a `jsonl` log of which knob gave what, plus a held-out gap that tells you whether to trust the result — not just the tuned config.

A subtle point worth holding onto: the entire pipeline this loop optimizes (chunk → embed → hybrid → rerank) is precisely the apparatus that [[agentic search with grep and full-file loading replaces RAG when context windows are large enough|grep-and-full-file agentic search argues you can often delete]]. This note takes the opposite-but-complementary stance: *if* you are running classic RAG, stop tuning it by hand. The two coexist — one says "tune the pipeline automatically," the other says "consider whether you need the pipeline at all."

## Why RAG tuning fits a loop perfectly

The governing rule of loop engineering: **a loop only makes sense if there is an automatic check that delivers a verdict without you.** RAG tuning passes this filter cleanly because recall@k is a ready-made metric — it doesn't need inventing the way a "is this summary good?" check would. That readiness is rare and is what makes this the textbook example.

You need three things in hand *before* the loop exists; the loop tunes an existing RAG, it does not build one:

1. A working pipeline with changeable parameters — chunk size, overlap, embedding model, candidate count `k`, reranker on/off.
2. An eval set — 30–50 questions, each with a known correct source chunk. **This is the check; without it there is no loop.**
3. A function that runs the eval and returns recall@k — the loop's oracle.

```python
# eval.py — the loop's oracle, returns recall@k for a config
def evaluate(config, eval_set):
    pipeline = build_rag(config)        # build RAG with these parameters
    hits = 0
    for case in eval_set:
        retrieved = pipeline.retrieve(case["question"], k=config["k"])
        retrieved_ids = {c["id"] for c in retrieved}
        if case["gold_chunk_id"] in retrieved_ids:
            hits += 1
    return hits / len(eval_set)
```

## Step 1 — Define the search space

The loop turns knobs within bounds, not an infinite space. The example space is already large — 4×3×3×3×3×2 = **648 combinations** — which is exactly why the loop must search *smartly* rather than sweep everything.

```python
# search_space.py — what the loop searches
SEARCH_SPACE = {
    "chunk_size":   [400, 600, 800, 1200],
    "chunk_overlap":[0, 100, 200],
    "embedding":    ["text-embedding-3-small", "bge-large", "e5-large"],
    "k":            [5, 10, 20],
    "reranker":     [None, "bge-reranker", "cohere-rerank"],
    "hybrid":       [False, True],   # vectors only or vectors + BM25
}
```

These are the same retrieval knobs that the [[on-policy distillation plus conditional log-penalty RL cuts search agent latency 44 percent while boosting accuracy|on-policy distillation work swept and found the reranker matters most]] — a useful prior for where coordinate descent will earn its biggest jumps. The `hybrid` flag (vectors + BM25) and the `embedding`/retrieval-method axis are the same design surface debated in [[hierarchical tree navigation can replace vector embeddings for RAG retrieval|tree-navigation-vs-embeddings for RAG retrieval]].

## Step 2 — A check you cannot lie to

Recall on the eval is a good check, but it has two traps to close before launch:

- **Trap 1: overfitting to the eval.** If the loop optimizes until eval-recall rises, it can find a combination that's accidentally good on exactly these 40 questions but not in production — numeric reward hacking. **Defense:** split the eval; the loop optimizes on `train`, you validate the final config on a `holdout` it never saw.
- **Trap 2: measurement noise.** On 30 questions, 0.87 vs 0.90 may be noise, and the loop will chase it. **Defense:** count an improvement as real only if it clears a threshold (≈0.02).

```python
import random

def split_eval(eval_set, holdout_frac=0.3, seed=42):
    random.Random(seed).shuffle(eval_set)
    n = int(len(eval_set) * (1 - holdout_frac))
    return eval_set[:n], eval_set[n:]   # train for the loop, holdout for you

train_set, holdout_set = split_eval(eval_set)
```

## Step 3 — The loop, with a smart search

A full 648-combination sweep is expensive and dumb. The loop uses **coordinate descent**: fix all knobs, search the values of one, take the best, move to the next. That finds a good config in *dozens* of runs instead of hundreds. The goal is checked on every run, so the moment it crosses `target_recall` it exits without spending the remaining budget; `max_evals` is the fuse against an unlucky space.

```python
import json

def tune_rag(search_space, train_set, target_recall=0.9, max_evals=40):
    # start from a sensible default
    config = {
        "chunk_size": 600, "chunk_overlap": 100,
        "embedding": "text-embedding-3-small", "k": 10,
        "reranker": None, "hybrid": False,
    }
    best_recall = evaluate(config, train_set)
    evals_used = 1
    log = []

    # coordinate descent: one knob at a time
    for param, values in search_space.items():
        if evals_used >= max_evals:
            break
        best_value = config[param]
        for value in values:
            if value == config[param]:
                continue
            if evals_used >= max_evals:
                break
            trial = dict(config, **{param: value})
            recall = evaluate(trial, train_set)
            evals_used += 1
            log.append({"config": trial, "recall": recall, "eval": evals_used})

            # improvement significant only if above the noise threshold
            if recall > best_recall + 0.02:
                best_recall = recall
                best_value = value

            # GOAL check: hit it, exit without spending more runs
            if best_recall >= target_recall:
                config[param] = best_value
                save_log(log)
                return config, best_recall, evals_used

        config[param] = best_value   # lock in the best for this knob

    save_log(log)
    return config, best_recall, evals_used

def save_log(log):
    with open("tune_log.jsonl", "w") as f:
        for row in log:
            f.write(json.dumps(row) + "\n")
```

## Step 4 — Brakes, because runs cost money

Each eval runs the whole RAG over dozens of questions — query embeddings, possibly a reranker, possibly an LLM call. A loop without brakes can quietly burn the budget, especially on expensive corners of the space (large `k` + `cohere-rerank` on every question). The budget brake is checked **before** a run: if the next eval would breach the limit, the loop stops *in advance*. "This is the difference between an asset and a surprise bill."

```python
def tune_rag_safe(search_space, train_set, target_recall=0.9,
                  max_evals=40, max_budget_usd=15):
    config = default_config()
    best_recall = evaluate(config, train_set)
    spent = estimate_cost(config, len(train_set))
    evals_used = 1
    log = []

    for param, values in search_space.items():
        best_value = config[param]
        for value in values:
            if value == config[param]:
                continue
            # BUDGET brake: the next run would exceed the limit, stop
            trial = dict(config, **{param: value})
            trial_cost = estimate_cost(trial, len(train_set))
            if spent + trial_cost > max_budget_usd:
                print(f"Budget ${max_budget_usd} spent. Stop at {evals_used} runs.")
                save_log(log)
                return config, best_recall, evals_used
            # RUN-COUNT brake
            if evals_used >= max_evals:
                save_log(log)
                return config, best_recall, evals_used

            recall = evaluate(trial, train_set)
            spent += trial_cost
            evals_used += 1
            log.append({"config": trial, "recall": recall,
                        "spent": round(spent, 2), "eval": evals_used})

            if recall > best_recall + 0.02:
                best_recall = recall
                best_value = value
            if best_recall >= target_recall:
                config[param] = best_value
                save_log(log)
                return config, best_recall, evals_used

        config[param] = best_value

    save_log(log)
    return config, best_recall, evals_used

def estimate_cost(config, n_questions):
    # rough estimate: query embedding + optional reranker per question
    cost = n_questions * 0.00002   # query embedding
    if config["reranker"] == "cohere-rerank":
        cost += n_questions * config["k"] * 0.000001
    return cost
```

## Step 5 — Launch and check on held-out

Run the loop on `train`, then **always** validate the found config on the `holdout` the loop never optimized. The gap is the alarm: 0.92 on train but 0.79 on held-out means the loop found a combination that pleased 28 training questions, not a better RAG.

```python
if __name__ == "__main__":
    train_set, holdout_set = split_eval(eval_set)

    # the loop tunes on train
    config, train_recall, n = tune_rag_safe(
        SEARCH_SPACE, train_set, target_recall=0.9, max_evals=40
    )
    print(f"Found in {n} runs. Recall on train: {train_recall:.2f}")
    print(f"Config: {config}")

    # CRITICAL: check on held-out, which the loop did not optimize
    holdout_recall = evaluate(config, holdout_set)
    print(f"Recall on held-out: {holdout_recall:.2f}")

    gap = train_recall - holdout_recall
    if gap > 0.1:
        print("WARNING: large train/holdout gap. "
              "The loop overfit the eval, the config cannot be trusted.")
    else:
        print("Gap is small, the config generalizes. Ship it.")
```

## How this loop dies (failure modes → cures)

| Death | Cause | Cure |
|---|---|---|
| **Chasing noise** — twitches on random recall fluctuations, never converges | improvement threshold too small, or eval set too small | 0.02 threshold; ≥40 questions in the eval |
| **Overfitting the eval** — train recall rises, production no better | optimized for the specific questions | held-out check; the train/holdout gap is the signal |
| **Budget runaway** — searches expensive configs and burns money | no budget brake, or expensive combos in the space | `max_budget_usd` checked *before* each run |
| **Endless sweep** — goal unreachable in the given space | `target_recall` above the ceiling the space allows | `max_evals` fuse; widen the space or lower the goal |

## What you get

Not just a tuned RAG, but a **reproducible process**: a `jsonl` log showing which knob gave what, a held-out check telling you whether to trust it, and a whole tuning that repeats with one command when the data or model changes. The author's closing imperative: *"Take your RAG, your eval set, and wrap the tuning in such a loop. Build it once, and never turn the chunking knob by hand again."*

This is loop engineering applied to a real task — "not 'an agent magically tuned RAG,' but an engineering loop: a measurable check you cannot lie to, defense against overfitting, budget brakes, a log to review." The same discipline as loop engineering in general; the check here just happens to be recall.

## Connections

- **Loop-engineering pattern, other domains.** [[Claude Managed Agents loop design with verifier sub-agents and cross-session memory lets Fable 5 outperform Opus 4.7 by 6x on Parameter Golf|Lance Martin's verifier-subagent loops]] and [[autoresearch can auto-improve any agent skill by testing and scoring in a loop|autoresearch's test-and-score skill loop]] are the same shape — automate the boring, checkable, repeated turn of a knob.
- **The knobs themselves.** [[on-policy distillation plus conditional log-penalty RL cuts search agent latency 44 percent while boosting accuracy|Sweeping embeddings/retrieval/rerankers showed the reranker matters most]] — a prior for where coordinate descent pays off; [[hierarchical tree navigation can replace vector embeddings for RAG retrieval|tree navigation vs. vector embeddings]] sits on the retrieval-method axis.
- **Whether to tune at all.** [[agentic search with grep and full-file loading replaces RAG when context windows are large enough|Grep + full-file loading argues the chunk→embed→rerank pipeline is often unnecessary]] — the complementary "maybe delete it" view to this note's "automate tuning it."
- **Recall as the agentic-retrieval metric.** [[InfoDeepSeek Benchmarking Agentic Information Seeking for Retrieval-Augmented Generation|InfoDeepSeek]] benchmarks agentic information-seeking for RAG, where recall-style metrics are the verdict.

---

*Source: [Loop Engineering: A Loop That Tunes RAG to a Target Recall by Itself](https://x.com/h100envy/status/2070852290878009586) — X Article by [@h100envy](https://x.com/h100envy), Jun 27 2026. Captured as a single long-form Article (no media; the thread's other tweets are third-party replies, not author self-replies). One substantive reply — @MoezZhioua asked how to set budget-brake granularity for expensive rerankers while keeping the loop "cheap and deterministic" — left unanswered by the author at capture time.*
