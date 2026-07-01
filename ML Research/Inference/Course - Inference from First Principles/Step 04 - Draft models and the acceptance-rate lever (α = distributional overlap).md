---
created: 2026-07-01
description: Step 4 of the inference course — the acceptance rate α is the single lever that governs speculative-decoding speedup, and it equals the distributional overlap between draft and target, α = 1 − TV(p,q) = Σ min(p,q). Defines total variation distance, the maximal-coupling optimality bound, the information-theoretic (bits/surprisal) view where each bit of draft overconfidence halves acceptance, and KL divergence via Pinsker as the trainable surrogate for TV — the reason distillation builds good draft models.
type: note
topic: speculative-decoding
---

# Step 4 — Draft models & the acceptance-rate lever (α = distributional overlap)

> [!abstract] The big idea
> Step 3 proved speculation is lossless, so the draft is a pure **speed** knob. This note names the knob: the **acceptance rate $\alpha$** — the fraction of guessed tokens that survive verification. And $\alpha$ isn't mysterious: it equals the **overlap** between the draft's and target's distributions, $\alpha = 1 - \mathrm{TV}(p,q) = \sum_x \min(p(x),q(x))$. That's the *best any correct scheme can do* (it's a maximal coupling). You can't optimize $\mathrm{TV}$ directly while training, so you minimize **KL divergence** instead — which bounds $\mathrm{TV}$ via Pinsker — and that is precisely why good draft models are **distilled** from the target. In bits: every bit of draft *overconfidence* halves a token's acceptance probability.

Index: [[00 - Course Index]] · Folder: [[moc - Inference]] · Prev: [[Step 03 - Speculative decoding core (guess-then-verify, why it's lossless)]]

---

## 1. The lever: what α is

Define the **acceptance rate** $\alpha$ as the probability that a single drafted token survives the accept test of Step 3:

$$\alpha \;=\; P\big(\text{a drafted token is accepted}\big)$$

Everything about speedup rides on this one number. Intuitively:

```
   α → 1   draft ≈ target   almost every guess kept   → big speedup
   α → 0   draft ≠ target   almost every guess tossed  → no speedup (you paid for guesses you threw away)
```

Symbols (same as Step 3): $p(x)$ = target probability of token $x$; $q(x)$ = draft probability of token $x$; the guess is sampled from $q$ and accepted with probability $\min(1, p/q)$.

---

## 2. Deriving α = 1 − TV (the whole point of the note)

The drafted token $X$ is **sampled from $q$**, then accepted with probability $\min(1, p(X)/q(X))$. So the acceptance rate is that acceptance probability *averaged over what the draft tends to propose*:

$$
\begin{aligned}
\alpha
&= \mathbb{E}_{X\sim q}\!\left[\ \min\!\left(1,\ \frac{p(X)}{q(X)}\right)\right]
&&\text{(average the accept prob. over draft samples)}\\[4pt]
&= \sum_x q(x)\,\min\!\left(1,\ \frac{p(x)}{q(x)}\right)
&&\text{(write the expectation as a sum over the vocab)}\\[4pt]
&= \sum_x \min\big(q(x),\ p(x)\big)
&&\text{(push } q(x) \text{ inside: } q\cdot\min(1,\tfrac pq)=\min(q,p))\\[4pt]
&= 1 - \mathrm{TV}(p,q)
&&\text{(the identity below)}
\end{aligned}
$$

Symbol glossary for the derivation:

- $\mathbb{E}_{X\sim q}[\,\cdot\,]$ — **expectation** (probability-weighted average) taken over token $X$ drawn from the draft distribution $q$.
- $\sum_x$ — sum over every token $x$ in the vocabulary.
- $\min(q(x),p(x))$ — the **shared height** of the two distributions at token $x$ (the part they agree on).

The last line uses the identity $\min(a,b) = \tfrac12\big(a+b-|a-b|\big)$:

$$
\sum_x \min(p,q) = \tfrac12\Big(\underbrace{\textstyle\sum_x p}_{=\,1} + \underbrace{\textstyle\sum_x q}_{=\,1} - \sum_x |p-q|\Big) = 1 - \tfrac12\sum_x|p(x)-q(x)| = 1 - \mathrm{TV}(p,q)
$$

So, cleanly:

$$\boxed{\;\alpha \;=\; \sum_x \min(p(x),q(x)) \;=\; 1 - \mathrm{TV}(p,q)\;}$$

**The acceptance rate is one minus the total variation distance between draft and target.** Nothing semantic — pure distributional overlap.

---

## 3. What is TV, exactly?

**Total variation distance** has two equivalent definitions:

$$\mathrm{TV}(p,q) \;=\; \tfrac12\sum_x \big|p(x)-q(x)\big| \;=\; \max_{A}\ \big|P(A)-Q(A)\big|$$

Piece by piece:

- $\tfrac12\sum_x |p(x)-q(x)|$ — **half the total absolute disagreement**. $|p(x)-q(x)|$ is how much the two models differ at token $x$; sum it over the vocab; halve it.
- $\max_A |P(A)-Q(A)|$ — the **worst-case event gap**: over *every* possible set of tokens $A$, the largest difference in probability the two models assign to $A$. If $\mathrm{TV}=0.3$, there's some event they disagree on by 30 percentage points, and none worse.

**Why the $\tfrac12$?** Probability is conserved: every unit of mass the draft puts in the *wrong* place is missing from the *right* place. $\sum|p-q|$ counts each misplacement twice (once as a surplus, once as a deficit), so you halve it to get "the amount of mass you'd physically move to turn $q$ into $p$." Range: $\mathrm{TV}=0$ (identical) up to $\mathrm{TV}=1$ (disjoint — no overlap at all).

```
   TV as "mass to move":

   q:  A █████   B ███    C █     D █          (draft)
   p:  A ████    B █      C ███   D ██         (target)

       └ q has SURPLUS here ┘   └ q has DEFICIT here ┘
          A:+.1  B:+.2            C:−.2  D:−.1
          (draft over-supplied)   (draft under-supplied)

   surplus total = .3   ==   deficit total = .3   =  TV = 0.3
   → to turn q into p, move 0.30 of mass from {A,B} over to {C,D}.
```

That moved 0.30 is exactly the mass the **residual** $\max(0,p-q)$ resamples in Step 3, and exactly $1-\alpha$.

---

## 4. α = overlap, TV = the non-overlap (one picture)

Lay the two distributions on the same axis. The **shared area** is $\alpha$; the **non-shared area** is $\mathrm{TV}$:

```
   token :   A          B         C          D
   q(x)  : |#####|    |###|     |#|        |#|          draft
   p(x)  : |####·|    |#··|     |###|      |##|         target

   min    :  ####      #         #          #      → Σ = α  = 0.70   (accepted guesses)
   q>p    :     #       ##       ·          ·      → Σ = TV = 0.30   (rejected...
   p>q    :     ·       ·        ##         #      → Σ = TV = 0.30   ...& refilled by residual)
```

- The **`min` row** (shared height) sums to $\alpha = 0.70$: guesses that sail through.
- The **`q>p` row** (draft's surplus on A, B) sums to $\mathrm{TV}=0.30$: guesses that get rejected.
- The **`p>q` row** (draft's deficit on C, D) also sums to $\mathrm{TV}=0.30$: the exact gap the residual fills.

Surplus $=$ deficit $=\mathrm{TV}$ is not a coincidence — it's the conservation-of-mass fact from Section 3. **Raising $\alpha$ literally means growing the shared area** by reshaping $q$ to sit under $p$.

---

## 5. The information-theory view: bits, surprisal, and KL

> [!important] Units matter — read this first
> **TV is a probability** (unitless, in $[0,1]$) — it's the thing that *exactly* sets $\alpha$. **KL divergence is measured in bits** (with $\log_2$) or **nats** (with $\ln$) — it's the thing you can actually *train against*. Pinsker's inequality is the bridge between them. Keep the two straight and this section is easy.

### 5a. Surprisal — information in bits

The **surprisal** (self-information) of token $x$ under a model $m$ is

$$I_m(x) = -\log_2 m(x)\quad\text{bits.}$$

- $m(x)$ — the model's probability for $x$. $I_m(x)$ — how many **bits** it takes to encode $x$ under an optimal code for $m$. Rare token → small $m(x)$ → **large** surprisal (many bits). Certain token ($m(x)=1$) → 0 bits.

### 5b. The accept ratio *is* a bit-difference

Rewrite the likelihood ratio from Step 3 using surprisals:

$$\frac{p(x)}{q(x)} = 2^{\log_2 p(x) - \log_2 q(x)} = 2^{\,I_q(x) - I_p(x)} = 2^{-\big(I_p(x)-I_q(x)\big)}$$

Let $\Delta = I_p(x) - I_q(x)$ = **the extra bits of surprise the target assigns** the token, relative to the draft. Then:

```
   Δ ≤ 0  (target LESS surprised, p ≥ q):   ratio ≥ 1   → ALWAYS accept
   Δ > 0  (target MORE surprised, p < q):   accept prob = 2^(−Δ)
                                            each extra BIT halves acceptance:
                                              Δ = 1 bit → accept ½
                                              Δ = 2 bit → accept ¼
                                              Δ = 3 bit → accept ⅛
```

So rejection is **exponential in the draft's overconfidence, measured in bits**. The draft loses a token exactly when it "spent too few surprise-bits" on something the target finds unlikely.

### 5c. KL divergence — the draft's average wasted bits

$$D_{\mathrm{KL}}(p\,\|\,q) = \sum_x p(x)\,\log_2\frac{p(x)}{q(x)} \quad\text{bits}$$

- $\log_2\frac{p(x)}{q(x)}$ — the per-token bit-difference from 5b, but averaged **under $p$** (the true distribution).
- The whole sum = the **expected number of extra bits per token** you waste if you compress $p$-distributed data using a code built for $q$. The draft is a cheap "codebook" for the target; $D_{\mathrm{KL}}(p\|q)$ is how wasteful it is. $D_{\mathrm{KL}}=0$ iff $q=p$.

### 5d. Pinsker — KL bounds TV, so minimizing KL raises α

Pinsker's inequality (stated with KL in **nats**, i.e. $\ln$):

$$\mathrm{TV}(p,q) \;\le\; \sqrt{\tfrac12\, D_{\mathrm{KL}}(p\,\|\,q)}\qquad(\text{KL in nats})$$

Combine with $\alpha = 1-\mathrm{TV}$:

$$\boxed{\;\alpha \;=\; 1-\mathrm{TV}(p,q)\;\ge\; 1-\sqrt{\tfrac12\,D_{\mathrm{KL}}(p\,\|\,q)}\;}$$

**Pushing the KL divergence down raises a guaranteed floor under the acceptance rate.** That is the theoretical license for training draft models by **knowledge distillation**: distillation *is* minimizing a KL (cross-entropy) to the target, and by Pinsker that tightens the coupling and buys longer accepted runs.

```
   the lever, end to end:

   distillation            Pinsker                 identity            Step 5
   train q ≈ p    ──▶   TV ≤ √(½·KL)     ──▶     α = 1 − TV    ──▶     speedup
   (minimize KL,        (KL upper-bounds          (overlap =           tokens/round
    in bits/nats)        the distance)             accept rate)        rises with α
```

> [!note] TV is the *true* target; KL is the *trainable surrogate*
> The quantity that exactly determines $\alpha$ is $\mathrm{TV}$ — but TV's absolute value $|p-q|$ has no gradient love and is awkward to optimize. KL (cross-entropy) is smooth and is what training already minimizes, and Pinsker guarantees that lowering it can only help. (Work like *DistillSpec* studies which divergence — forward KL, reverse KL, TVD, JSD — distills the best draft *for acceptance specifically*, precisely because KL is a proxy for the TV we actually care about.)

---

## 6. Worked example — same {A, B, C, D}, now with the numbers

Reuse the position from Step 3: $q=[.5,.3,.1,.1]$, $p=[.4,.1,.3,.2]$ over $\{A,B,C,D\}$.

**Overlap → α and TV:**

| token | $q$ | $p$ | $\min(p,q)$ | $\lvert p-q\rvert$ |
|---|---|---|---|---|
| A | 0.50 | 0.40 | 0.40 | 0.10 |
| B | 0.30 | 0.10 | 0.10 | 0.20 |
| C | 0.10 | 0.30 | 0.10 | 0.20 |
| D | 0.10 | 0.20 | 0.10 | 0.10 |
| **Σ** | 1.00 | 1.00 | **0.70 = α** | **0.60** |

$$\alpha = \textstyle\sum\min(p,q) = 0.70,\qquad \mathrm{TV} = \tfrac12(0.60) = 0.30,\qquad \alpha = 1-\mathrm{TV}\ \checkmark$$

**KL in bits** ($\sum p\log_2\frac pq$):

| token | $p$ | $q$ | $p/q$ | $\log_2(p/q)$ | $p\log_2(p/q)$ |
|---|---|---|---|---|---|
| A | 0.40 | 0.50 | 0.80 | $-0.322$ | $-0.129$ |
| B | 0.10 | 0.30 | 0.333 | $-1.585$ | $-0.158$ |
| C | 0.30 | 0.10 | 3.00 | $+1.585$ | $+0.475$ |
| D | 0.20 | 0.10 | 2.00 | $+1.000$ | $+0.200$ |
| **Σ** | | | | | $\mathbf{0.388}$ bits |

So $D_{\mathrm{KL}}(p\|q) \approx 0.388$ bits $= 0.269$ nats. **Pinsker check:** $\sqrt{\tfrac12\cdot 0.269} = \sqrt{0.134} = 0.367 \ge \mathrm{TV}=0.30$ ✓ — the bound holds (and is loose, as Pinsker usually is). The guaranteed floor is $\alpha \ge 1-0.367 = 0.633$; the true $\alpha=0.70$ clears it.

**Bits at token B** (the one the draft over-favored): target surprise $I_p(B) = -\log_2 0.10 = 3.32$ bits; draft surprise $I_q(B) = -\log_2 0.30 = 1.74$ bits. Overconfidence $\Delta = 3.32 - 1.74 = 1.585$ bits → accept probability $2^{-1.585} = 0.333 = p(B)/q(B)$ ✓. One-and-a-half bits of overconfidence → kept only a third of the time.

---

## 7. The optimality note — α = 1 − TV is the ceiling

Could a cleverer verification scheme accept *more* often without corrupting the output? **No.** Ask for any joint sampling (a **coupling**) of $p$ and $q$ that (a) outputs an exact sample from $p$ and (b) reuses the draft's proposal as often as possible. A classical result caps the agreement probability:

$$P(\text{draft proposal reused}) \;\le\; \sum_x \min(p(x),q(x)) \;=\; 1-\mathrm{TV}(p,q)$$

This is the **maximal coupling** bound, and Step 3's accept-then-residual rule *achieves it exactly*. So speculative decoding isn't merely *a* correct scheme — it's the **information-theoretically optimal** one. $\mathrm{TV}$ is a hard wall: no lossless method beats acceptance rate $1-\mathrm{TV}$.

---

## 8. So what makes a *good* draft model?

Everything above says: **maximize overlap with the target** (minimize TV, via minimizing KL). Practical levers:

- **Share the tokenizer/vocabulary** with the target — otherwise $p$ and $q$ aren't even distributions over the same $x$, and the ratio $p/q$ is meaningless.
- **Distill from the target** — train $q$ on the target's outputs / logits (minimize KL). Directly raises the $\alpha$ floor via Pinsker.
- **Condition the draft on the target's own computation** — feed the draft the target's *last hidden state* so its guesses inherit the target's context. This is the EAGLE / MTP idea (Step 6): a tiny head on top of the target's features gets very high overlap for almost no cost.
- **Bigger / smarter draft → higher $\alpha$, but more cost.** A draft that's too large slows every round even when it guesses well. That tension — $\alpha$ up vs. draft cost up — is exactly the **economics** of Step 5.

> [!warning] α is per-token; runs are what pay off
> A single accepted token isn't the prize — a *run* of them is. Because a round stops at the **first** rejection, the expected accepted **length** grows super-linearly as $\alpha\to 1$ (roughly $\propto \tfrac{1}{1-\alpha}$). A draft at $\alpha=0.9$ doesn't give you 1.3× the tokens of an $\alpha=0.7$ draft — it gives you far more, because it strings together long unbroken accepted prefixes. Step 5 makes this precise.

---

## Key formulas

$$\alpha = \sum_x \min(p(x),q(x)) = 1 - \mathrm{TV}(p,q)$$

$$\mathrm{TV}(p,q) = \tfrac12\sum_x|p(x)-q(x)| = \max_A|P(A)-Q(A)| \in [0,1]$$

$$I_m(x) = -\log_2 m(x)\ \text{(bits)},\qquad \frac{p(x)}{q(x)} = 2^{-(I_p-I_q)},\qquad \text{accept prob} = 2^{-\Delta}\ \ (\Delta = I_p-I_q > 0)$$

$$D_{\mathrm{KL}}(p\|q) = \sum_x p(x)\log_2\frac{p(x)}{q(x)}\ \text{(bits)},\qquad \mathrm{TV}\le\sqrt{\tfrac12 D_{\mathrm{KL}}}\ \text{(nats)}\ \Rightarrow\ \alpha \ge 1-\sqrt{\tfrac12 D_{\mathrm{KL}}}$$

## Things to understand (checklist)

- [ ] $\alpha$ = probability a single guess is accepted — the **one lever** for speculative speedup.
- [ ] $\alpha = \sum\min(p,q) = 1-\mathrm{TV}(p,q)$: acceptance rate **equals distributional overlap**.
- [ ] $\mathrm{TV} = \tfrac12\sum|p-q|$ = worst-case event gap = "mass you'd move to turn $q$ into $p$"; the $\tfrac12$ is because surplus = deficit.
- [ ] $\alpha = 1-\mathrm{TV}$ is the **maximal-coupling ceiling** — no lossless scheme accepts more often.
- [ ] Bits view: surprisal $-\log_2 m(x)$; accept prob $=2^{-\Delta}$, so **each bit of draft overconfidence halves acceptance**.
- [ ] KL (bits/nats) = draft's average wasted encoding bits; **Pinsker** ($\mathrm{TV}\le\sqrt{\tfrac12 D_{\mathrm{KL}}}$) makes KL a bound on TV.
- [ ] Therefore **distillation** (minimize KL) is the trainable route to high $\alpha$; TV is the true target, KL the surrogate.
- [ ] Good draft = same tokenizer, distilled from target, ideally conditioned on the target's hidden state (EAGLE/MTP, Step 6).

## The analogy

Two weather forecasters for the same town: the **official bureau** ($p$) and a **cheap phone app** ($q$). Each morning you keep the app's forecast only if the bureau finds that outcome at least as likely as the app claimed. How often you get to reuse the app's forecast is just **how much the two forecasters' probability distributions overlap** — nothing else. A random app (huge divergence) is useless; an app *trained to imitate the bureau* (small KL, hence small TV) agrees almost always, so you rarely have to phone the bureau. And there's a ceiling: you can never reuse the app more often than the two forecasts genuinely overlap ($1-\mathrm{TV}$) — that's a law, not an engineering limit.

## Where this leads

$\alpha$ is the lever; now turn it into money. Step 5 plugs $\alpha$ and the lookahead $\gamma$ into the **cost formula** — expected tokens per round $\approx \frac{1-\alpha^{\gamma+1}}{1-\alpha}$ — exposing the **net-negative zone** (where a slow or low-$\alpha$ draft makes you *slower*) and the hard **ceilings** on speedup. Then Steps 6–10 (EAGLE/MTP, DFlash, DSpark) are all engineering assaults on those ceilings: make the draft nearly free, make it parallel, and make $\gamma$ a calibrated, load-aware knob. → Step 05 — The economics of speculation.
