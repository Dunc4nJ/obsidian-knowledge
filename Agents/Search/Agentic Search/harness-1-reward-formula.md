---
title: "Harness-1 — The RL Reward Formula"
type: reference
source: "https://arxiv.org/abs/2606.02373"
parent: "[[Harness-1 offloads search bookkeeping into a stateful harness so a 20B RL policy beats frontier searchers on curated recall]]"
tags: [agentic-search, rl, reward-shaping, credit-assignment, harness-engineering]
---

# Harness-1 — The RL Reward Formula

The single terminal scalar that supervises the whole RL stage. The policy makes ~40 decisions, the harness scores the episode **once** at `end_search`, and that one number is broadcast back onto every action. This note takes the formula apart term by term — what each measures, what failure mode it targets, and a worked SEC example with real numbers. Code lives in `reference-repos/harness-1/harness/ultra_core.py:compute_reward` (≈1464–1649). Sibling note: [[harness-1-search-infra]].

## The formula

```
  R  =  0.7·F_β  +  0.3·ρτ  +  1.0·𝟙[ρA>0]  +  (0.8·ρA + 0.4·ρτA)  −  0.35·(ρτA−ρA)₊  −  turn_pen  +  tool_div
        ───────     ──────     ───────────     ─────────────────      ──────────────     ────────     ────────
        ① set       ② found    ③ found ANY      ④ promote the          ⑤ FUMBLE penalty   ⑥ be        ⑦ use
        quality     anywhere   answer doc?      answer docs            "had it, dropped"  efficient   varied tools

  short-circuits:   empty curated set → R = −0.2      format error → R = −0.5      floor:  R ≥ 0.001
```

It looks busy. The key to *understanding* (not memorizing) it: read it as a **nested curriculum**, where each term asks a strictly harder question than the last.

```
   ② did you FIND relevant docs at all?        ......... discovery        (easiest bar)
   ① did you SELECT the right ones into C?      ......... selection
   ③ did you find AT LEAST ONE answer doc?      ......... the must-haves exist
   ④ did you PROMOTE the answer docs into C?     ......... commit to the must-haves
   ⑤ did you find an answer doc but DROP it?     ......... punish the specific fumble (hardest signal)
   ⑥⑦ …and do it efficiently, with varied tools
```

## The four document sets (everything is built from these)

```
   R  =  all RELEVANT docs            (the gold "supporting" set — everything that should be found)
   A  =  the ANSWER docs   ⊂ R        (the must-haves that actually ANSWER the query, not just support it)
   ────────────────────────────────
   C  =  CURATED set                  (what the policy committed to — its final output, ≤30 docs)
   P  =  POOL                         (every doc the policy ENCOUNTERED anywhere in the episode)
```

Two distinctions do all the work in the formula:

```
   DISCOVERY  vs  SELECTION              SUPPORTING  vs  ANSWER
   P (found)      C (chose)              R (all relevant)   A (the must-haves)

   "Did you stumble on it?"              "Is it nice-to-have, or do-or-die?"
   "Did you put it in the answer?"
```

Almost every term is one cell of this 2×2 grid.

## The recalls (each is just: how much of the target did you capture ÷ the target)

```
   precision p   =  |C ∩ R| / |C|     of what you curated, how much was relevant?
   Recall    r   =  |C ∩ R| / |R|     of all relevant, how many did you CURATE?       (feeds F_β)
   ρτ            =  |P ∩ R| / |R|     of all relevant, how many did you FIND anywhere?  (trajectory recall)
   ρA            =  |C ∩ A| / |A|     of the answer docs, how many did you CURATE?       (final-answer recall)
   ρτA           =  |P ∩ A| / |A|     of the answer docs, how many did you FIND anywhere? (traj-FA recall)
```

Mnemonic: **C** = "did you keep it", **P** = "did you see it"; **R** = "all relevant", **A** = "the answer".

## ① 0.7·F_β — set quality (the main event)

`F_β` with β = 2, computed on the curated set C against the gold set R:

```
   F₂  =  5·p·r / (4·p + r)            general:  F_β = (1+β²)·p·r / (β²·p + r),  here β²=4
```

A plain F₁ treats precision and recall as equally important. But a **search agent's job is to not miss evidence.** β = 2 makes **recall count 4× as much as precision** (the β² = 4 multiplying p in the denominator deweights precision).

> **Why recall-heavy?** A doc you never surface is gone forever — the downstream answer-writer can't use what isn't there. A junk doc that sneaks into the (≤30-capped) curated set is cheap noise the reader can skim past. So the reward leans hard toward *catch everything* over *stay clean*. At weight 0.7 this term dominates the whole reward.

## ② 0.3·ρτ — trajectory recall (discovery credit)

ρτ = |P∩R|/|R| — of all relevant docs, how many you *encountered anywhere*, even if you never curated them.

> **Why?** Pure smoothing of the gradient. Without it, an agent that *found* everything but fumbled the curation scores the same as one that found *nothing* — a flat, dead signal. This term gives partial credit for discovery, so the policy gets feedback like "you're searching in the right place" before it has even learned to curate well.

## ③ 1.0·𝟙[ρA>0] — the binary answer bonus (make-or-break)

𝟙[·] is the indicator: a flat **+1.0** if you curated *at least one* answer doc (ρA > 0), else 0.

> **Why a big flat chunk?** The answer docs A are the handful that *actually answer the query*. Getting even one into C is the cliff-edge between "useful result" and "useless result." +1.0 is the single largest lever in the formula — a strong attractor that says "whatever else happens, grab an answer doc." (Code has a dense fallback `1.0·ρA` when `FINAL_ANSWER_BINARY` is off; the deployed run uses the binary form.)

## ④ (0.8·ρA + 0.4·ρτA) — dense answer shaping

Beyond the binary cliff, smooth reward for *how many* answer docs: 0.8× the fraction you curated + 0.4× the fraction you merely encountered.

> **Why both binary AND dense?** ③ says "get one"; ④ says "now get *all* of them, and finding them anywhere helps too — but curating counts double (0.8 vs 0.4)." Together they turn a step function into a ramp, a gradient that keeps pulling toward full answer coverage.

## ⑤ −0.35·(ρτA − ρA)₊ — the answer-FUMBLE penalty (the cleverest term)

(·)₊ = max(0, ·). The quantity ρτA − ρA = (answer docs you *encountered*) − (answer docs you *curated*).

```
   ρτA − ρA  >  0   ⟺   "you HAD an answer doc in your pool and DIDN'T promote it to curated"
```

> **Why?** This targets one specific, costly failure: **fumbling at the goal line** — you literally held the smoking-gun document and left it out of the basket. Notice it's behaviorally surgical: the `(·)₊` ("positive part") means it *only* fires when discovery exceeds selection. It scolds you for dropping a ball you were already holding; it never penalizes you for failing to find a doc in the first place (that's ②'s job). This single term is what teaches the `verify → curate` promotion discipline that SFT only seeded.

## ⑥ − turn_penalty — efficiency

A small penalty that ramps **linearly** from 0 (at `TURN_PENALTY_MIN_TURNS`) up to `TURN_PENALTY_MAX` (at `MAX_TURNS`):

```
   turn > MIN_TURNS  →  turn_penalty = TURN_PENALTY_MAX · (turn − MIN_TURNS)/(MAX_TURNS − MIN_TURNS)
```

> **Why?** Discourage dawdling — stop once you have enough. **Honesty note:** the deployed `launch_rl.sh` sets `TURN_PENALTY_MAX=0.0`, so this term is **disabled in the real run** (the `if … TURN_PENALTY_MAX > 0` guard zeroes it). See the discrepancy table.

## ⑦ + tool_diversity — exploration

A bonus for using a variety of tools (ramps to the cap at `TOOL_DIVERSITY_TARGET` distinct tools), plus an undocumented shortfall penalty:

```
   bonus    = w_div · min(n_unique_tools / ν₀, 1.0)
   penalty  = SHORTFALL · max(0, ν₀ − n_unique_tools)      (deployed: 0.08 per missing tool)
```

> **Why?** Prevent **mode collapse** — the degenerate policy that just spams `search_corpus` and never reads, verifies, or curates. It keeps the whole toolbox in play.

## The guardrails (special cases)

```
   empty curated set  →  R = −0.2     short-circuit (NO_CURATE_PENALTY): "you basketed nothing → automatic fail"
   format error       →  R = −0.5     "malformed output → bigger fail"  (protects the Harmony wire format)
   any valid episode  →  R ≥ 0.001    floor (MIN_FORMAT_REWARD): never let a well-formed attempt hit exactly 0
                                       — a hard 0 kills the gradient; keep a faint pulse alive
```

## Worked example: the SEC CFO query (real numbers)

Setup — a query about a CFO transition:

```
   Gold:   R = 5 relevant docs;   A = 2 answer docs   (the two filings that literally name the new CFO)
   Run:    pool P found ALL 5 relevant (so it saw BOTH answer docs)
           curated C = 4 docs  =  3 relevant (incl. 1 of the 2 answer docs)  +  1 junk doc
```

Recalls:

```
   p   = |C∩R|/|C| = 3/4 = 0.75        r = |C∩R|/|R| = 3/5 = 0.60
   F₂  = 5·0.75·0.60 / (4·0.75 + 0.60) = 2.25 / 3.60 = 0.625
   ρτ  = |P∩R|/|R| = 5/5 = 1.00         (found everything relevant — great discovery)
   ρA  = |C∩A|/|A| = 1/2 = 0.50         (curated only ONE of the two answer docs)
   ρτA = |P∩A|/|A| = 2/2 = 1.00         (but it FOUND both answer docs!)
```

Term-by-term tally:

```
   ① set quality        0.7 · F₂            = 0.7 · 0.625        = +0.4375
   ② trajectory recall  0.3 · ρτ            = 0.3 · 1.00         = +0.3000
   ③ found-answer bonus  1.0 · 𝟙[ρA>0]      = 1.0 · 1  (0.5>0)   = +1.0000
   ④ answer shaping     0.8·ρA + 0.4·ρτA    = 0.40 + 0.40        = +0.8000
   ⑤ FUMBLE penalty   −0.35 · (ρτA − ρA)₊   = −0.35 · (1.0−0.5)  = −0.1750
   ⑥ turn penalty       (disabled, =0)                            =  0
   ⑦ tool diversity     (target met → ≈0 here)                    ≈  0
                                                          ─────────────────
                                                        R  ≈  +2.36
```

**Read term ⑤ here — it's the lesson.** The agent had **both** answer docs in hand (ρτA = 1.0) but promoted only **one** (ρA = 0.5):

```
   ρτA = 1.0   ← FOUND both answer docs (they were in the pool, in its hands)
   ρA  = 0.5   ← only PROMOTED one of them into curated
   (ρτA − ρA)₊ = 0.5   →   −0.35 · 0.5 = −0.175    "you had it and dropped it"
```

That −0.175 *is* the reward teaching curation discipline directly, rather than waiting for the blind terminal broadcast to eventually correlate its way there.

## Why this shape: shaping vs. the credit-assignment problem

The terminal reward is **sparse in *time*** — one payout, at `end_search`, broadcast identically onto all ~40 actions:

```
   a₀    a₁    a₂   ...  a₃₈   a₃₉=end_search
   │     │     │         │     │
   └─────┴─────┴────…────┴─────┘
                   │
              R = 2.36   ← ONE scalar, stamped on EVERY action equally
```

So the brilliant search on turn 3 and the wasteful redundant search on turn 17 receive the *identical* credit. The reward knows the episode was good — **not which moves made it good**. RL recovers signal only **statistically**: a genuinely good action rides in better-than-average episodes *more often*, so over ~82K–235K rollouts the noise cancels and the net-positive drift survives. That is why RL needs so many rollouts and why variance reduction (baselines, the group) is life-or-death.

The designers can't fix the *timing* (episode quality genuinely isn't known until the end), so they make the reward **dense in *outcome* space** — packing the single scalar with diagnostic detail (terms ②④⑤) so that when it *is* broadcast, it carries a rich verdict ("you found everything but fumbled an answer doc") instead of a flat good/bad. That is **reward shaping**, and it is the design answer to the sparse-terminal-signal problem.

## The exact code assembly

`compute_reward` (`harness/ultra_core.py`):

```
   beta_sq      = RECALL_BETA²                                            # = 4
   f_beta       = (1+beta_sq)·p·r / (beta_sq·p + r)                       # :1556
   fa_bonus     = FINAL_ANSWER_BONUS  (binary)  OR  ·final_answer_recall  # :1565
   fa_dense     = 0.8·ρA + 0.4·ρτA                                        # :1571
   fa_miss_pen  = 0.35·max(0, ρτA − ρA)                                   # :1575

   combined  = 0.7·f_beta + 0.3·trajectory_recall + fa_bonus + fa_dense   # :1578
   combined -= fa_miss_pen                                                # :1584
   combined -= gap_penalty            (GAP_PENALTY_WEIGHT default 0)       # :1588  ← legacy/dead
   combined -= turn_penalty           (linear ramp; disabled in deploy)   # :1598
   combined += curate_rate_bonus      (CURATE_RATE default 0)             # :1605  ← legacy/dead
   combined += tool_diversity_bonus                                       # :1610
   combined -= tool_diversity_penalty (shortfall · missing tools)         # :1615
   final_reward = max(MIN_FORMAT_REWARD, combined)                        # :1617  ← the 0.001 floor
```

Note two **legacy/dead** terms (`gap_penalty`, `curate_rate_bonus`) kept for backward compatibility with weights defaulted to 0 — they don't appear in the paper formula and contribute nothing in the deployed run.

## Constants: paper vs. module-default vs. deployed

The reward **structure and core weights match the paper exactly**. The discrepancies are all in the secondary shaping terms (turn penalty, tool diversity) and the training caps.

| Code variable | Paper (Table 5) | `ultra_core.py` default | Deployed `launch_rl.sh` |
|---|---|---|---|
| `OUTCOME_WEIGHT` (set quality, ①) | 0.7 | 0.7 | 0.7 |
| `TRAJECTORY_RECALL_WEIGHT` (②) | 0.3 | 0.3 | 0.3 |
| `RECALL_BETA` (β in F_β) | 2.0 | 2.0 | 2.0 |
| `FINAL_ANSWER_BONUS` (③) | 1.0 | 1.0 | 1.0 |
| `FINAL_ANSWER_RECALL_WEIGHT` (④, ρA) | 0.8 | 0.8 | 0.8 |
| `TRAJECTORY_FA_RECALL_WEIGHT` (④, ρτA) | 0.4 | 0.4 | 0.4 |
| `FA_MISS_PENALTY_WEIGHT` (⑤) | 0.35 | 0.35 | 0.35 |
| `NO_CURATE_PENALTY` (empty set) | −0.2 | −0.2 | −0.2 |
| `MIN_FORMAT_REWARD` (floor) | 1e-3 | 1e-3 | 1e-3 |
| `TURN_PENALTY_MAX` (⑥) | **0.02** | **0.15** | **0.0 (disabled)** |
| `TURN_PENALTY_MIN_TURNS` | **20** | **24** | 24 |
| `TOOL_DIVERSITY_BONUS` (⑦, w_div) | **0.15** | **0.0 (off)** | **0.5** |
| `TOOL_DIVERSITY_TARGET` (ν₀) | **6** | **3** | 6 |
| `TOOL_DIVERSITY_SHORTFALL_PENALTY` | *(not in paper)* | — | **0.08 / missing tool** |
| `MAX_TURNS` (episode cap) | **40** | **35** | **128** |
| `KL_PENALTY_COEF` (anchor to SFT) | **0.0** | 0.0 | **0.005** |

> **Takeaway:** the *reward signal a trajectory receives* is faithful to the paper — the 7-term skeleton and its primary weights are identical. The gaps are (a) the turn penalty being disabled rather than 0.02, (b) tool-diversity being ~3× stronger with an undocumented shortfall penalty, and (c) the training-scale knobs (`MAX_TURNS`, `KL_PENALTY_COEF`). The module **defaults are mostly OFF/weaker** — the launch script is what turns the paper's configuration on. See [[harness1-paper-vs-code]] for the full discrepancy ledger.
