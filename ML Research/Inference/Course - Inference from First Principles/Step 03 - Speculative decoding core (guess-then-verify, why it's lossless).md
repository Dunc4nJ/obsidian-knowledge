---
created: 2026-07-01
description: Step 3 of the inference course — speculative decoding's guess-then-verify loop. A cheap draft model proposes γ tokens; the big target model verifies all of them in ONE parallel forward pass; a per-token rejection-sampling rule keeps the longest correct prefix and patches the first miss. Why the emitted tokens are provably drawn from the target's exact distribution (lossless), with a full worked example over a 4-token vocabulary.
type: note
topic: speculative-decoding
---

# Step 3 — Speculative decoding core (guess-then-verify; why it's lossless)

> [!abstract] The big idea
> Decode is memory-bandwidth-bound (Step 1): at batch 1 the big model drags *all* its weights out of HBM and the tensor cores sit ~99.7% idle. Verifying **several** guessed tokens costs almost the same as generating **one**. So let a small, fast **draft** model guess the next few tokens, then let the big **target** model check them **all at once** in a single forward pass. A per-token coin-flip (rejection sampling) keeps the longest correct prefix and repairs the first mistake. The kicker: the tokens that come out are drawn from the **exact same distribution** as the target alone — speculation changes *speed*, never *correctness*.

Index: [[00 - Course Index]] · Folder: [[moc - Inference]] · Prev: [[Step 01 - Decode is memory-bandwidth-bound (the roofline)]]

---

## 1. Two models, one goal

Speculative decoding runs **two** models side by side:

| role | symbol | size / speed | job |
|---|---|---|---|
| **target** ("big") | $p$ | large, slow | the model we actually want to sample from — the ground truth |
| **draft** ("small") | $q$ | 10–50× smaller, fast | *proposes* guesses for the next few tokens |

Notation used throughout:

- $p(x)$ — the **target** model's probability for token $x$ at a given position (a full next-token distribution over the whole vocabulary).
- $q(x)$ — the **draft** model's probability for the same token $x$ at the same position.
- $x_i$ — the $i$-th token the draft *guessed* this round.
- $\gamma$ (gamma) — the **lookahead** / block size: how many tokens the draft guesses before we verify (e.g. $\gamma = 4$).
- $r \sim \mathrm{Uniform}(0,1)$ — a fresh uniform random number in $[0,1]$ (the "accept coin"), drawn once per drafted token.

> [!info] Why this can possibly be free (recap of Step 1)
> A decode step's wall-time is $t_\text{token} = \max(t_\text{mem}, t_\text{cmp})$, and at batch 1, $t_\text{mem}$ wins by ~295×. Pushing extra tokens through the **same one-time weight read** is nearly free until the compute roofline (~batch 300). Batching filled that free compute across *many requests* (throughput). Speculation fills it along the *sequence axis* — the guessed future of **one** request (latency).

---

## 2. One round of the loop

Each round has two moves: the draft **guesses sequentially** (cheap, it's tiny), then the target **verifies in parallel** (one weight sweep, all positions at once).

```
  ROUND (γ = 3 guesses)

  (a) DRAFT guesses, one at a time  (cheap: q is tiny)
        prompt ─▶ x1 ─▶ x2 ─▶ x3
                  q      q      q          3 small forward passes

  (b) TARGET verifies ALL positions in ONE big forward pass
      ┌──────────────────────────────────────────────────────┐
      │  read the 140 GB of weights ONCE (the 41.8 ms sweep)   │
      │  → get p(·) at EVERY position simultaneously:          │
      │        p(· | prompt)          for slot of x1           │
      │        p(· | prompt, x1)      for slot of x2           │
      │        p(· | prompt, x1, x2)  for slot of x3           │
      │        p(· | prompt, x1..x3)  ← the free "bonus" slot   │
      └──────────────────────────────────────────────────────┘

  (c) WALK left→right, accept/reject each guess (Section 3)
        x1  accept ✓
        x2  accept ✓
        x3  REJECT ✗ ──✂── discard everything after the cut
        → resample a replacement x3' from the residual (Section 4)
```

The whole point: step (b) is **one** memory-bound weight sweep — the same ~41.8 ms it costs to make a *single* token normally — yet it scores **all γ guesses at once** because attention lets the target read every position in parallel. The draft's γ little passes are cheap because $q$ is tiny (its own weight sweep is 10–50× shorter).

---

## 3. The accept / reject rule

Walk the guesses left to right. For each drafted token $x_i$ (which the draft *sampled from $q$*), draw a fresh coin $r$ and:

$$\text{accept } x_i \quad\Longleftrightarrow\quad r \le \min\!\left(1,\ \frac{p(x_i)}{q(x_i)}\right), \qquad r \sim \mathrm{Uniform}(0,1)$$

Reading the pieces:

- $\dfrac{p(x_i)}{q(x_i)}$ — the **likelihood ratio**: how much *more* (or less) the target wants this token than the draft did.
- $\min(1,\ \cdot)$ — caps the ratio at 1, because a probability can't exceed 1. So the acceptance probability is $\min\!\big(1,\ p(x_i)/q(x_i)\big)$.
- $r \le (\cdot)$ — the coin: accept if the uniform draw falls under the acceptance probability.

Two regimes:

```
  p(xi) ≥ q(xi):  ratio ≥ 1  → min(1, ratio) = 1   → ALWAYS accept
                  "target likes it at least as much as the draft did — keep it."

  p(xi) < q(xi):  ratio < 1  → accept w.p. p/q     → SOMETIMES accept
                  "draft over-proposed it; keep it only p/q of the time."
```

The rule never asks "is this a *good* word?" It only compares two numbers the two models already produced. That statistical humility is exactly what makes it lossless (Section 6).

---

## 4. On rejection — resample from the residual, discard the tail

At the **first** rejected position $i$, do two things:

**(1) Discard the tail.** Throw away $x_i$ *and* every later guess $x_{i+1}, x_{i+2}, \dots$ Those later guesses were generated by the draft **conditioned on $x_i$** — a token we just rejected — so their context is now wrong and they're meaningless. (Their target distributions from the parallel pass are discarded too.)

**(2) Resample a replacement** for position $i$ from the **residual distribution**:

$$p'(x) \;=\; \frac{\max\!\big(0,\ p(x) - q(x)\big)}{\displaystyle\sum_{x'} \max\!\big(0,\ p(x') - q(x')\big)} \;=\; \frac{\max\!\big(0,\ p(x)-q(x)\big)}{Z}$$

Defining every piece:

- $\max(0,\ p(x)-q(x))$ — the **unmet target demand** for token $x$: the probability mass the target wants *beyond* what the draft supplied. It is $0$ for tokens the draft already over-supplied (where $q \ge p$), and positive only where the target wants *more* than the draft gave.
- $Z = \sum_{x'} \max(0,\ p(x')-q(x'))$ — the **normalizer**, the total unmet demand summed over the vocabulary. This makes $p'$ a valid distribution. (We'll see in Step 4 that $Z$ equals the total variation distance $\mathrm{TV}(p,q)$ — the same number as $1-\alpha$.)

Intuition: the accept phase already gave the "over-supplied" tokens their fair shot. The residual samples **only from the tokens the draft under-represented** — it fills exactly the gap the accept phase left behind.

---

## 5. If every guess is accepted — a free bonus token

If all $\gamma$ guesses pass, you're not done squeezing value out of that one weight sweep. The target pass already computed $p(\cdot \mid \text{prompt}, x_1, \dots, x_\gamma)$ at the **bonus slot** (position $\gamma+1$). Just sample one token straight from it:

$$x_{\gamma+1} \sim p(\cdot \mid \text{prompt}, x_1, \dots, x_\gamma)$$

So a round yields **$\gamma+1$ tokens** in the best case (all accepted + bonus), and as few as **1 token** in the worst case (position 1 rejected → one resampled token). More on this range in Section 7.

---

## 6. Worked example — a full round over vocabulary {A, B, C, D}

Let the model's whole vocabulary be four tokens $\{A, B, C, D\}$. Suppose the draft speculates $\gamma = 4$ tokens, and the accept coins play out like this:

```
  pos │ p(xi)/q(xi) │ coin r  │ test r ≤ min(1, p/q) │ result
  ────┼─────────────┼─────────┼──────────────────────┼─────────
   1  │   1.40      │  0.32   │  0.32 ≤ 1.00   ✓      │ ACCEPT
   2  │   0.90      │  0.55   │  0.55 ≤ 0.90   ✓      │ ACCEPT
   3  │   0.33      │  0.61   │  0.61 ≤ 0.33   ✗      │ REJECT ──✂──
   4  │    —        │   —     │  (never reached)      │ discarded
  ────┴─────────────┴─────────┴──────────────────────┴─────────
  → keep x1, x2 ; replace x3 with a resample ; drop x4
  → this round produced 3 tokens from ONE target pass.
```

Now zoom into **position 3**, where the real machinery lives. At that slot the two models say:

| token | draft $q(x)$ | target $p(x)$ |
|---|---|---|
| A | 0.50 | 0.40 |
| B | 0.30 | 0.10 |
| C | 0.10 | 0.30 |
| D | 0.10 | 0.20 |

The draft **sampled B** (its 2nd-favorite, $q(B)=0.30$).

**Accept test:** $\dfrac{p(B)}{q(B)} = \dfrac{0.10}{0.30} = 0.333$. Coin $r = 0.61 > 0.333$ → **reject**. (The draft was overconfident about B: the target only wants it a third as much.)

**Resample from the residual** $p'(x) \propto \max(0,\ p(x)-q(x))$:

| token | $p(x)-q(x)$ | $\max(0,\cdot)$ | normalized $p'(x)$ |
|---|---|---|---|
| A | $-0.10$ | 0 | 0 |
| B | $-0.20$ | 0 | 0 |
| C | $+0.20$ | 0.20 | $0.20/0.30 = \mathbf{0.667}$ |
| D | $+0.10$ | 0.10 | $0.10/0.30 = \mathbf{0.333}$ |

The normalizer is $Z = 0.20 + 0.10 = 0.30$. Notice **which** tokens survive: **C and D — exactly the ones the target wanted *more* of than the draft supplied** (positive $p-q$). A and B, which the draft *over*-supplied, get zero — they already had their chance in the accept phase. Say the residual draws **C**; the round emits $[\,x_1, x_2, C\,]$.

---

## 7. Why it's lossless — the one-line proof

Claim: **the token finally emitted at a position is distributed exactly as $p$**, no matter that a fast, dumb draft was involved. Compute the total probability the procedure emits any token $x$. There are two disjoint ways $x$ can be the output:

$$
P(\text{emit } x) \;=\;
\underbrace{q(x)\cdot\min\!\left(1, \tfrac{p(x)}{q(x)}\right)}_{\text{(1) draft proposed } x \text{ and it passed}}
\;+\;
\underbrace{P(\text{rejection})\cdot p'(x)}_{\text{(2) something was rejected, residual gave } x}
$$

Simplify each term:

- Term (1): $q(x)\cdot\min\!\big(1, p(x)/q(x)\big) = \min\big(q(x),\ p(x)\big)$ — pull $q(x)$ inside the $\min$.
- Term (2): $P(\text{rejection}) = Z$ (the total unmet demand), and $p'(x) = \max(0,p(x)-q(x))/Z$, so the product is just $\max(0,\ p(x)-q(x))$ — the $Z$'s cancel.

$$P(\text{emit } x) \;=\; \min\big(p(x),\,q(x)\big) \;+\; \max\big(0,\ p(x)-q(x)\big)$$

Case-check this identity:

$$
\begin{aligned}
p(x) \ge q(x):&\quad \min = q,\ \ \max(0,p-q) = p-q \ \Rightarrow\ q + (p-q) = p \ \checkmark\\
p(x) < q(x):&\quad \min = p,\ \ \max(0,p-q) = 0 \ \ \Rightarrow\ p + 0 = p \ \checkmark
\end{aligned}
$$

Either way it collapses to $p(x)$. **The output is exactly the target's distribution.** ∎

Verify on the position-3 numbers — the two paths add up per token to reconstruct $p$:

| token | $q$ | $p$ | accept path $\min(p,q)$ | resample path $\max(0,p-q)$ | sum |
|---|---|---|---|---|---|
| A | 0.50 | 0.40 | 0.40 | 0 | **0.40** |
| B | 0.30 | 0.10 | 0.10 | 0 | **0.10** |
| C | 0.10 | 0.30 | 0.10 | 0.20 | **0.30** |
| D | 0.10 | 0.20 | 0.10 | 0.10 | **0.20** |
| **Σ** | 1.00 | 1.00 | **0.70** (accept rate) | **0.30** (reject/residual) | **1.00** |

Read the columns: the **accept-path column sums to 0.70** (that's the acceptance rate — Step 4 calls it $\alpha$), the **resample-path column sums to 0.30** (the leftover mass $Z$), and **row-by-row they rebuild $p$ exactly**. Token C, for instance, can appear either because the draft proposed it and it passed *or* because some guess got rejected and the residual produced it — and those two routes sum to precisely $p(C)=0.30$.

> [!success] What "lossless" buys you
> You can pick the draft $q$ **however you like** — any model, any size, even a bad one — and the output is *still* a perfect sample from the target $p$. A worse draft only means more rejections (slower), never wrong tokens. This is why the draft is a pure, risk-free **speed** knob. (How much speed? That's the acceptance rate $\alpha$ — Step 4.)

---

## 8. Tokens per round: between 1 and γ+1

```
  best case  (all γ accepted, + bonus):     γ + 1 tokens from 1 target pass
  typical                                 : some prefix accepted, then a resample
  worst case (position 1 rejected)        : 1 token from 1 target pass

  ┌ γ=4 example ───────────────────────────────────────────────┐
  │ accept accept accept accept  + bonus   → 5 tokens  (jackpot) │
  │ accept accept REJECT ✂                 → 3 tokens            │
  │ REJECT ✂                                → 1 token  (no gain) │
  └─────────────────────────────────────────────────────────────┘
```

Every round costs **one** target weight-sweep. If the average round emits, say, 2.5 tokens, you've done ~2.5× the work per expensive pass — that's the latency win. The *expected* tokens-per-round is a function of the acceptance rate and $\gamma$; deriving it (and the cost/ceilings) is Step 5.

---

## Key formulas

$$\text{accept } x_i \iff r \le \min\!\left(1,\ \frac{p(x_i)}{q(x_i)}\right),\qquad r\sim\mathrm{Uniform}(0,1)$$

$$p'(x) = \frac{\max(0,\ p(x)-q(x))}{Z},\qquad Z=\sum_{x'}\max(0,\ p(x')-q(x'))$$

$$P(\text{emit }x) = \min(p(x),q(x)) + \max(0,\ p(x)-q(x)) = p(x)\quad\forall x \quad(\text{lossless})$$

$$\text{tokens per round} \in \{1,\dots,\gamma+1\},\qquad \text{cost} = \text{one target forward pass}$$

## Things to understand (checklist)

- [ ] Two models: **target $p$** (big, the truth) and **draft $q$** (small, guesser). We always sample the guess from $q$.
- [ ] One round = draft guesses $\gamma$ tokens **sequentially** (cheap), target verifies **all of them in one parallel pass** (the free compute from Step 1).
- [ ] Accept $x_i$ with probability $\min(1, p(x_i)/q(x_i))$: **always** if $p\ge q$, else with probability $p/q$.
- [ ] On the **first** rejection: discard that token and everything after it (their context is now wrong), and resample from the residual $\max(0,p-q)$.
- [ ] All accepted → grab a **free bonus token** from the already-computed slot $\gamma+1$.
- [ ] Losslessness: $\min(p,q)+\max(0,p-q)=p$, so the emitted token is an exact sample from $p$ — the draft can be *anything*.
- [ ] A round yields **1 to $\gamma+1$** tokens for the price of **one** target weight-sweep.

## The analogy

A **senior editor** ($p$, slow, expensive) and a **fast junior** ($q$, quick, cheap). The junior scribbles the next few words of a sentence in seconds. The editor then reads the *whole* draft phrase in a single glance (one expensive read) and, word by word, keeps each as long as it's at least as likely as the editor would have written it — accepting cheaply-agreed words outright and coin-flipping on the ones the junior over-favored. At the first word the editor wouldn't have chosen, they cross out the rest and write the correct word themselves (the residual). Because the editor has the final say on every kept word, **the finished sentence is exactly what the editor alone would have produced** — just written far faster because the easy stretches were pre-filled.

## Where this leads

Losslessness makes the draft a pure speed dial. The obvious next question: **how far does the dial turn?** That's set entirely by the **acceptance rate $\alpha$** — the fraction of guesses that survive — and $\alpha$ turns out to equal the **distributional overlap** between draft and target, $\alpha = 1 - \mathrm{TV}(p,q)$. Building a good draft model *is* the game of maximizing that overlap. → [[Step 04 - Draft models and the acceptance-rate lever (α = distributional overlap)]]
