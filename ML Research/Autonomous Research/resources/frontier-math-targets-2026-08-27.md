# Frontier Mathematics Targets for an AI Research Campaign

**Research date:** 2026-08-27  
**Status:** target-selection dossier; not yet a claim of novelty or solvability  
**Calibration:** Anthropic's zeta-zero result and the dimension-qualified Jacobian counterexample  
**Primary objective:** find a mathematically important, precisely stated, independently checkable target whose solution or sharp improvement would attract serious attention, preferably with direct relevance to machine learning, model training, algorithms, or quantitative research.

> **Round 3 adversarial revision:** This file preserves the initial candidate dossier and is no longer the canonical ranking. Six same-family T1 review passes corrected target statements, challenged certificate-size bias, audited the three leading pilots, added `HC4` and a quant reconnaissance lane, and separated expected value from headline ceiling. The current rankings, evidence cards, negative findings, verifier replay, and source locators are in [frontier-math-evidence-ledger-2026-08-27.md](frontier-math-evidence-ledger-2026-08-27.md). Do not quote the Round 1 ordering below without this revision notice.

## Executive verdict

The initial review selected the **exact ReLU depth frontier for max functions and continuous piecewise-linear functions**. Round 3 keeps it as the strongest ML attention flagship, but no longer treats any one ranking as coherent. The best verifier-first pilot is **rectilinear K28**; the best theorem-shaped ML pilot is **weighted-regression `R(3,4)`**; the strongest attention-first pair is **terminal ReLU depth** and **field-pinned 3×3 tensor rank**; and the newly exposed **four-variable Hessian conjecture** is the closest Jacobian-lineage moonshot, albeit in an exceptionally crowded lane.

This is a ranking of **research-campaign conviction**, not a claim that the first problem is intrinsically more important than every problem below it. Conviction combines five things:

1. the attention ceiling if the strongest target is solved;
2. whether the exact claim is live as of 2026-08-27;
3. whether both construction and obstruction routes exist;
4. whether an output can be checked exactly and independently;
5. whether failure on the terminal target can still yield a publishable theorem, certificate, algorithm, or counterexample.

### Round 1 ranked shortlist — superseded by the evidence ledger

| Rank | Target | North-star result | Direct relevance | Exact-checkability | Useful partial-result floor | Overall conviction |
|---:|---|---|---|---|---|---|
| 1 | Exact depth of ReLU representations of `max_n` / CPWL functions | Prove all `max_n` use two hidden layers, or exhibit the first function that provably requires three | ML foundations | Very high for constructions; medium for universal lower bounds | Very high | **Highest** |
| 2 | Field-pinned bilinear rank of 3×3 matrix multiplication | Construct rank 22 over a named field (an upper-bound improvement only), or prove rank 23 is optimal there | Algebraic complexity; indirect compute relevance | Extremely high for constructions and finite certificates | High | **Very high** |
| 3 | Exact diagonal Ramsey number `R(5,5)` | Determine which of 43, 44, 45, or 46 is the exact value | Finite combinatorics; search/verification methods | Extremely high for lower-bound witnesses; high for certified upper bounds | High | **Very high north-star fit** |
| 4 | Transformer attention rank–depth lower bound | Prove or refute that no fixed-size, fixed-weight rank-r<d transformer solves the paper's target uniformly for every sequence length N | Transformer architecture | Medium–high once architecture and error model are pinned | High | **Very high** |
| 5 | Five-dimensional kissing number | Prove `tau_5 = 40`, or construct 41 mutually kissing spheres | Geometry, coding/representation geometry | Very high for a construction; high for rationalized SDP certificates | Medium–high | **High** |
| 6 | Fixed-dimensional softmax-attention time exponent | Match the `n^(2-1/d)` upper bound, or beat it, for fixed dimension and pinned accuracy/entry bounds | Attention runtime | High for algorithms; medium for conditional lower bounds | High | **High** |
| 7 | Explicit deterministic RIP beyond the square-root bottleneck | Give a near-random-quality explicit RIP family, or a major exponent improvement | Compressed sensing, sketching, sparse ML, quant signals | Medium | High if staged correctly | **High-risk, high-ceiling** |
| 8 | Adaptive backtest validity under dependent heavy-tailed returns | Minimax-tight reusable inference for adaptively selected Sharpe/factor queries | Quant research and adaptive ML evaluation | High after the statistical contract is fixed | Very high | **High applied conviction** |
| 9 | Implicit bias of practical mini-batch AdamW | Exact limit/variational characterization—or counterexample—for realistic AdamW in a pinned nonlinear model | Model training | Medium–high | Very high | **High technical conviction** |
| 10 | Robust factor covariance with contamination and dependence | Efficient minimax estimator plus matching portfolio-risk lower bound | Portfolio construction, risk, robust ML | Medium–high | High | **Medium–high** |
| 11 | Statistical stability and complexity of multi-period martingale optimal transport | Sharp rates/lower bounds for high-dimensional market marginals and path-dependent payoffs | Model-free pricing/risk | Medium | Medium | **Medium** |
| 12 | Memory–recompute–communication lower bounds for a full training DAG | Tight multi-level lower bound and matching schedule for Transformer/MoE training | Training systems | High once the machine model is pinned | Medium–high | **Medium** |
| 13 | Online portfolio regret with nonlinear impact and partial feedback | Matching minimax dynamic-regret theorem in a realistic impact model | Execution and allocation | Medium–high | High | **Medium, crowded** |

The top seven are the closest to the two north stars. Targets 8–13 could be highly valuable and publishable, but their public story is less likely to resemble “AI advances a famous mathematical frontier” unless the theorem is unusually sharp or surprising.

## What the two north stars actually teach us

The wrong lesson is “select the most famous unsolved conjecture.” The useful lesson is to select a **famous hub with an exact frontier one step away**.

### North star 1: the Riemann-zeta campaign

[Anthropic's account](https://www.anthropic.com/research/riemann-zeta) reports an improvement in the proved proportion of nontrivial zeta zeros on the critical line from 41.6% to 67.2%. It explicitly does **not** claim the Riemann hypothesis, and says the methods are not expected to prove it. The result nonetheless has a powerful one-sentence story because the improved constant is exact, it sits directly adjacent to perhaps the best-known open problem in mathematics, and it can be checked through conventional mathematical review and formalization.

Operationally, the account also matters: the campaign spent its early effort falsifying hundreds of ideas, searched and read a bounded literature corpus, ran symbolic and numerical checks, used independent reproof, involved human experts, and formalized the final argument. The attention came from a decisive certified improvement, not from the volume of generated conjectures.

### North star 2: the Jacobian counterexample

The public story was “AI solves the Jacobian conjecture,” but the mathematically correct statement is narrower and more instructive. The [Archive of Formal Proofs entry](https://isa-afp.org/entries/Jacobian_Counterexample.html) verifies an explicit polynomial map in dimension three whose Jacobian determinant is constant and nonzero while three rational points have the same image; scaling yields determinant one, and the construction extends to dimensions at least three. It does **not** settle the two-dimensional case. A separate [Lean verification deposit](https://zenodo.org/records/21514514) supplies an additional exact-checking route. [Fortune's coverage](https://fortune.com/2026/07/21/ai-solves-jacobian-conjecture-levant-alpoge-claude-fable-5/) is useful evidence for the attention ceiling, not the technical basis for the claim.

The transferable pattern is therefore:

- a recognizable mathematical object;
- a crisp statement that fits in one paragraph;
- an explicit witness or short chain of lemmas;
- exact evaluation at rational/integer inputs or a machine-checkable proof object;
- a strict cousin map saying what was and was not settled;
- independent verification in a second implementation or proof assistant;
- a result that remains important after every qualifier is stated.

That pattern strongly favors small exact representation problems, small tensor-rank problems, finite configurations, and sharply formulated lower bounds. It disfavors vague “understand optimization,” “solve the Riemann hypothesis,” or “find a profitable strategy” campaigns.

## How the epistemic-humility skill changes the campaign

The skill is not a creativity prompt. It is a claim-control and verification architecture. Applied here, it imposes the following discipline.

### Before attempting a proof

- Freeze the exact mathematical object, ambient field, asymptotic regime, precision model, error metric, and allowed resources.
- Record the target claim, its nearest stronger and weaker cousins, and explicit falsifiers.
- Run a live novelty audit. The August 2026 landscape is moving too quickly to rely on even month-old summaries.
- Separate discovery evidence from proof evidence. Numerical search can locate a witness; it cannot promote an approximate pattern to a theorem.
- Build both a **prove/build** track and a **break/obstruct** track. A target that supports only hopeful construction is poorly shaped.

### Before claiming a result

- Require exact arithmetic or certified interval bounds for decisive finite computations.
- Re-run the checker from a clean environment and retain the certificate, logs, code version, and dependency/toolchain pins.
- Ask an independent reviewer to rederive the statement and test the nearest counterclaims.
- If formalized, audit for holes, admitted axioms, statement mismatch, and environmental assumptions. “Lean accepts it” does not by itself establish novelty or that the formal theorem matches the public claim.
- Use the narrowest defensible language: “improves,” “constructs,” “rules out under assumptions,” or “settles the specified case.”

For quant-facing targets there is an additional separation: a statistical-validity theorem is not evidence of a tradable signal. Any later empirical campaign needs a frozen universe, point-in-time data, a cost model, multiplicity accounting, a lockbox, and regime/falsifier reporting.

## Detailed candidate dossiers

## 1. Exact ReLU depth for maxima and CPWL functions

### Live frontier

[Shallower ReLU Network Representations via Exact Linear Algebra](https://arxiv.org/abs/2607.21651) proves that `max_n`, the maximum of `n` real inputs, has an exact ReLU representation with two hidden layers for every `n <= 10`. Its `max_10` construction uses a structured first layer and yields a recursive depth upper bound for larger `n`. Via a generalized hinging-hyperplane representation, the paper also obtains two-hidden-layer representations for every continuous piecewise-linear (CPWL) function on `R^d` for `d <= 9`.

This is not merely another neural-network approximation question: it is an exact representation frontier over real inputs, and the current progress was produced through symmetry reduction and rational linear algebra. That gives us a native machine-discovery and exact-certificate loop.

### Exact campaign target

The launch target is:

> Determine whether `max_11` is exactly representable by a finite ReLU network with two hidden layers, with unrestricted real weights.

The north-star target is:

> Either prove that every `max_n`—and consequently the relevant class of CPWL functions—admits a two-hidden-layer representation, or exhibit and prove the first exact obstruction requiring at least three hidden layers.

The unrestricted-real-weights clause matters. Failure of a particular symmetric, pairwise-max, bounded-width, rational, or prescribed-support ansatz is not a universal depth lower bound.

### Win ladder

- **Meaningful first result:** an exact rational two-hidden-layer certificate for `max_11`, or a theorem ruling out a broad explicitly defined ansatz.
- **Field-leading result:** extend the exact frontier substantially, discover a scalable family, or derive a new normal form that converts unrestricted lower bounds into a finite algebraic obstruction.
- **North-star result:** resolve two hidden layers for every `max_n`, or give the first unconditional CPWL/ReLU function requiring three hidden layers in the relevant unrestricted model.

### Why it could attract attention

The strongest result would overturn or crystallize a basic belief about neural-network depth. The story is short: “Is depth intrinsically necessary even to compute a maximum exactly?” It connects a familiar primitive, an active STOC/ML frontier, exact algebra, and the representational foundations of ReLU networks.

### Verification shape

A positive construction can be checked by exact rational linear algebra and a finite fan/cancellation identity. A negative result needs a structural theorem or algebraic/geometric obstruction; this is harder, but independent symbolic checking and eventual Lean/Isabelle formalization are realistic. The paper's method gives immediate reproducible infrastructure and a valuable partial-result floor.

### Principal risk and no-claim boundary

`max_11` may succumb to the same template as `max_10`, making it a respectable extension rather than a headline result. Conversely, an automated UNSAT result inside a restricted ansatz must not be advertised as a general lower bound. The campaign earns north-star status only by discovering a scalable principle or a genuinely unrestricted obstruction.

## 2. Exact bilinear rank of 3×3 matrix multiplication

### Live frontier

The classic 23-multiplication algorithm leaves a small, famous gap for bilinear multiplication of two arbitrary 3×3 matrices. [Automated Lower Bounds for Bilinear Complexity over Finite Fields](https://arxiv.org/abs/2603.07280) recently raised the lower bound over `F_2` from 19 to 20 and emits machine-checkable certificates. [55 Additions Suffice for 3x3 Matrix Multiplication at Rank 23](https://arxiv.org/abs/2607.28676) gives a 23-product, 55-addition straight-line program valid over every associative ring, along with exact checks of all 729 Brent identities over the integers.

The field and model are crucial. A commutative-only multiplication scheme, a border-rank degeneration, or a numerical approximate decomposition is not automatically a rank-22 bilinear algorithm over arbitrary noncommutative rings.

### Exact campaign target

Choose one of the following, declared in advance:

> Construct a rank-22 decomposition of the 3×3 matrix-multiplication tensor over `Q` (or another explicitly named field), verified by all 729 Brent equations.

or

> Prove that its bilinear rank is at least 23 over `Q` or `C`, using an independently checkable certificate or a proof whose computational components are certified.

### Win ladder

- **Meaningful first result:** improve a lower bound over another finite field; lift the general-field lower bound; prove nonexistence in a large symmetry class; or reduce additions at rank 23.
- **Field-leading result:** a general-field rank lower bound of 20 or more, or a highly structured rank-22 candidate that survives exact reconstruction and all local tests.
- **North-star result:** a rank-22 decomposition is a major upper-bound record, but exact rank 22 additionally requires a matching lower bound over the same field. Exact rank 23 requires a lower bound matching the classical upper bound.

### Why it could attract attention

This is arguably the cleanest headline in the list: “The exact number of scalar multiplications needed for 3×3 matrix multiplication.” It lies at the intersection of algebraic complexity, tensor decomposition, compiler kernels, and the operation at the core of model training. DeepMind's [AlphaTensor work](https://www.nature.com/articles/s41586-022-05172-4) and [AlphaEvolve](https://deepmind.google/blog/alphaevolve-a-gemini-powered-coding-agent-for-designing-advanced-algorithms/) have already made automated matrix-multiplication discovery legible to a broad audience.

### Verification shape

A construction is ideal: a small coefficient table plus exact verification of a fixed set of polynomial identities. A finite-field lower bound can also be certificate-backed. A characteristic-zero lower bound is much less likely to reduce to a compact search certificate and may demand substantial algebraic geometry or representation theory.

### Principal risk and no-claim boundary

The search space is ferocious and newly crowded. A floating-point tensor decomposition with tiny residual is not a construction until exact reconstruction succeeds. A rank result over `F_2` does not automatically imply the same result over `Q`, and an improvement in additions at rank 23 does not resolve bilinear rank.

## 3. Attention rank versus depth in Transformers

### Live frontier

[Quality over Quantity in Attention Layers](https://proceedings.iclr.cc/paper_files/paper/2025/hash/9c537882044c8b5352c363e840872ddb-Abstract-Conference.html) gives a natural nearest-neighbor target computable by one full-rank attention head, while a single low-rank layer requires exponentially many heads even for short sequences. For short sequences, additional layers can compensate. Its exact Conjecture 6 says that no **fixed-size, fixed-weight** rank-r<d multi-layer transformer approximates the target **for all sequence lengths N**. It does not rule out a different low-rank model, with size depending on N, for each fixed long N.

The area is active rather than dormant. [Two (narrow) heads are better than (an arbitrarily wide) one](https://proceedings.iclr.cc/paper_files/paper/2026/hash/221ec998e345bf4a128bf6c48e1aadee-Abstract-Conference.html) proves a dimension- and precision-independent one-head impossibility for endpoint selection on graphs with cycles while two heads solve it. [The Effect of Attention Head Count on Transformer Approximation](https://proceedings.iclr.cc/paper_files/paper/2026/hash/7d72a514fc6948515af3ee69c1059776-Abstract-Conference.html) develops further head-count lower bounds.

### Exact campaign target

After copying the paper's architecture, domain, precision, approximation norm, head-rank definition, sequence-length scaling, and allowed feed-forward blocks exactly:

> Prove that no fixed-size, fixed-weight rank-r<d multi-layer transformer approximates the paper's target uniformly for all N, with every architectural and approximation assumption copied exactly; or give one fixed low-rank transformer family satisfying those quantifiers and refuting the conjecture.

A depth-two or depth-three result is useful only if it is explicitly related back to the fixed-size, uniform-in-N conjecture. A fixed-N construction is a cousin result, not automatically progress on Conjecture 6.

### Win ladder

- **Meaningful first result:** settle depth two or three, or eliminate a broad class of low-rank simulation strategies.
- **Field-leading result:** a quantitatively tight depth/rank/head tradeoff with precision-independent constants.
- **North-star result:** prove or refute the arbitrary-depth conjecture in the stated model.

### Why it could attract attention

It answers a real architecture question: can depth compensate for narrow attention projections? A decisive theorem would bear directly on head dimension, head count, long-context retrieval, and what architectural resources are genuinely substitutable.

### Verification shape

The proof will likely be analytic/information-theoretic rather than a tiny witness, but small finite cases can support exhaustive falsification. A constructive refutation could be exactly simulated on rational inputs; a lower bound needs a carefully audited architecture contract so that an omitted residual path, MLP, positional encoding, or precision assumption does not invalidate the public claim.

### Principal risk and no-claim boundary

Transformer lower bounds are unusually sensitive to the model definition. Settling a simplified attention-only architecture is not automatically a theorem about production Transformers. This candidate belongs near the top because the conjecture is explicit and current, but its verification surface is larger than candidates 1 and 2.

## 4. The exact diagonal Ramsey number R(5,5)

### Live frontier

`R(5,5)` is the smallest `N` such that every graph on `N` vertices contains either a five-vertex clique or a five-vertex independent set. The April 2026 revision of the authoritative dynamic survey [Small Ramsey Numbers](https://www.combinatorics.org/ojs/index.php/eljc/article/viewFile/DS1/pdf) gives the live gap `43 <= R(5,5) <= 46` and reports strong evidence for the conjectured value 43. The lower bound has stood since Exoo's 1989 construction. The recent upper-bound paper [`R(5,5) <= 46`](https://arxiv.org/abs/2409.15709), now published in 2026, combines linear programming with a large computer case check independently implemented by both authors.

This is an unusually good two-sided AI target. A better lower bound is a concrete graph; a better upper bound is a finite nonexistence theorem that can in principle be expressed through exhaustive generation or a SAT certificate. Reinforcement learning has already produced new lower bounds for other small Ramsey numbers in [Reinforcement learning for graph theory, II](https://arxiv.org/abs/2403.20055), although not for this diagonal case.

### Exact campaign target

> Determine `R(5,5)` exactly, or move either endpoint of the certified interval `43 <= R(5,5) <= 46`.

The construction ladder is explicit: a graph on 43, 44, or 45 vertices with neither a 5-clique nor a 5-independent set proves a lower bound of 44, 45, or 46 respectively. The obstruction ladder proves that no such graph exists at 45, 44, or 43 vertices.

### Win ladder

- **Meaningful first result:** a genuinely new structural restriction on a hypothetical 43-vertex Ramsey graph, or a reusable certified search reduction that removes a major fraction of the current cases.
- **Field-leading result:** improve either bound by one. An explicit 43-vertex witness would break a lower bound unchanged since 1989; `R(5,5) <= 45` would improve the newest upper bound.
- **North-star result:** prove `R(5,5)` equals 43, 44, 45, or 46.

### Why it could attract attention

Ramsey numbers are among the most famous finite unknown integers in mathematics, and the statement is accessible through the “friends or strangers” formulation. Even a one-step certified bound improvement would be notable; the exact value would be an unmistakable north-star result. Its direct connection to quant or model training is weak, but its search, symmetry reduction, graph-generation, SAT, and proof-certificate machinery transfers directly to automated theorem discovery.

### Verification shape

A lower-bound graph is nearly ideal: publish its adjacency matrix and independently enumerate every 5-subset to verify it is neither a clique nor an independent set. An upper bound is harder but can be packaged as a deterministic generation log, isomorph-rejection audit, or SAT instance with a checkable LRAT/DRAT-style proof. Independent implementations and completeness checks are mandatory because missing a single isomorphism class invalidates the theorem.

### Principal risk and no-claim boundary

The survey's evidence favors `R(5,5) = 43`, which would make construction search on 43 vertices futile and force the much harder universal nonexistence proof. Local minima, failed extension searches, or exhaustion of a hand-chosen graph family do not improve the upper bound. Any proof conditional on the completeness of an external graph catalog must either certify that catalog or state the dependency explicitly.

## 5. The five-dimensional kissing number

### Live frontier

The kissing number `tau_d` is the largest number of unit spheres that can simultaneously touch a central unit sphere in `d` dimensions. Henry Cohn's maintained [kissing-number table](https://cohn.mit.edu/kissing-numbers/) lists the current five-dimensional bounds as 40–44 and the six-dimensional bounds as 72–77. [Variations on five-dimensional sphere packings](https://arxiv.org/abs/2412.00937) studies several geometrically distinct 40-point configurations described as conjecturally optimal; it does not improve the record.

### Exact campaign target

> Either construct 41 unit vectors in `R^5` whose pairwise inner products are at most `1/2`, or prove that every such spherical code has at most 40 vectors.

The first route refutes the believed value; the second proves `tau_5 = 40`.

### Win ladder

- **Meaningful first result:** improve the upper bound from 44; classify a large family of 40-point optima; or obtain a stronger exact stability theorem near 40.
- **Field-leading result:** upper bound 41 or 42, or an explicit 41-point configuration.
- **North-star result:** close the gap and determine `tau_5` exactly.

### Why it could attract attention

This is a classic problem that requires almost no jargon to explain. A solution would be unambiguously mathematical and visually communicable. The direct link to model training is weaker than for the top three, but spherical codes underpin coding, vector quantization, codebooks, and representation geometry.

### Verification shape

A construction can be certified by an exact Gram matrix with positive-semidefiniteness, rank at most five, unit diagonal, and off-diagonal entries at most one-half. An upper bound may emerge from linear/semidefinite programming, but the final result needs rational or interval-certified dual data and a proof that the relaxation applies.

### Principal risk and no-claim boundary

Numerically plausible Gram matrices often fail exact PSD/rank/inequality checks after reconstruction. An SDP value slightly below 41 is not a proof without rigorous error control. The terminal problem is also likely harder than the ReLU launch rung.

## 6. The exact time exponent of fixed-dimensional softmax attention

### Live frontier

[Fast Attention Requires Bounded Entries](https://arxiv.org/abs/2302.13214) established a sharp transition around entry bound `B = Theta(sqrt(log n))` when dimension is `O(log n)`: almost-linear approximation below the threshold and SETH-based absence of truly subquadratic algorithms at the threshold. [Subquadratic Algorithms and Hardness for Attention with Any Temperature](https://arxiv.org/abs/2505.14840) gives, for constant dimension `d`, an algorithm of roughly `n^(2-1/d)` (up to logarithmic and parameter factors), while its hardness regimes do not simply close the fixed-constant-`d` exponent gap.

### Exact campaign target

Pin the exact version of approximate attention, additive or relative error, temperature/entry bound, bit complexity, and constant dimension `d`. Then:

> Either design an `n^(2-1/d-epsilon)` algorithm for some fixed `d` and `epsilon > 0`, or prove under a named fine-grained assumption that no such algorithm exists.

### Win ladder

- **Meaningful first result:** settle one small fixed dimension, strengthen the reduction to a larger parameter range, or improve logarithmic/error dependence.
- **Field-leading result:** a matching conditional exponent for every fixed `d` in a natural high-temperature/large-entry regime.
- **North-star result:** close the fixed-dimensional exponent frontier or discover an unexpected truly subquadratic algorithm outside the known phase diagram.

### Why it could attract attention

Quadratic attention cost is one of the best-known bottlenecks in model training and inference. A sharp theorem saying exactly when geometry permits faster softmax attention would interest both fine-grained complexity and ML systems researchers.

### Verification shape

Algorithms can be benchmarked and proved symbolically; reductions can be independently audited with parameter-checking scripts. This is less compact than a finite witness, but more falsifiable than broad neural-runtime conjectures.

### Principal risk and no-claim boundary

A conditional lower bound must name its assumption and parameter regime in every summary. A lower bound for explicit attention-matrix materialization is not a lower bound for implicit approximate attention. Exact forward/backward I/O lower bounds are already a crowded and substantially closed subfrontier, so this campaign should target the unresolved arithmetic exponent instead.

## 7. Explicit deterministic RIP beyond the square-root bottleneck

### Live frontier

Random matrices achieve near-optimal restricted isometry with about `m = O(s log(N/s))` rows, whereas explicit deterministic constructions remain far weaker in important regimes. [Explicit RIP Matrices: Breaking the Square-Root Bottleneck](https://arxiv.org/abs/1008.4535) obtained a limited improvement using additive combinatorics. [Explicit construction of RIP matrices is Ramsey-hard](https://arxiv.org/abs/1805.11238) and its [later update](https://arxiv.org/abs/2108.01794) connect sufficiently strong explicit RIP constructions to hard explicit Ramsey-graph phenomena.

### Exact campaign target

The legendary target is a polynomial-time explicit matrix family with near-random row count and useful sparsity. A more responsible first campaign is:

> Improve a named exponent in the best explicit RIP construction for a precisely fixed coherence/sparsity/row regime, or prove a stronger barrier for a broad named construction family.

### Win ladder

- **Meaningful first result:** a nontrivial new family, a certified improvement in one regime, or a no-go theorem for a popular algebraic template.
- **Field-leading result:** a clean exponent improvement beyond the known bottleneck over a broad parameter range.
- **North-star result:** a deterministic construction approaching random-matrix performance.

### Why it could attract attention

This is a long-standing explicit-versus-random problem with direct relevance to compressed sensing, sparse recovery, sketching, streaming algorithms, and high-dimensional signal research. A near-optimal construction would be a landmark.

### Verification shape

Finite instances can be checked exactly, but the theorem must control all sparse subsets asymptotically. The most promising machine role is to discover algebraic constructions, identities, or proof lemmas—not to brute-force the full RIP property at useful scale.

### Principal risk and no-claim boundary

This may encode problems as hard as other famous explicit constructions. Good finite matrices do not establish an asymptotic family. It ranks below the first five because the terminal result is extraordinarily difficult and the certificate is less compact, despite the enormous ceiling.

## 8. Adaptive validity for backtests on dependent heavy-tailed returns

### Live frontier

This is a **synthesized research gap**, not yet a certified named conjecture. The ingredients are individually active. [Adaptive Data Analysis with Correlated Observations](https://proceedings.mlr.press/v162/kontorovich22a.html) extends parts of adaptive-data-analysis theory beyond IID samples and emphasizes how much less is understood under dependence. [Tight Bounds for Answering Adaptively Chosen Concentrated Queries](https://arxiv.org/abs/2507.13700) proves that some degradation under correlation is inherent in the concentrated-query formulation, under the paper's stated natural conditions on the algorithm. IID work includes [adaptive estimation](https://proceedings.mlr.press/v65/feldman17a.html) and [valid confidence intervals for adaptive analysis](https://proceedings.mlr.press/v108/rogers20a.html).

### Exact campaign target

After fixing a return process class—such as geometrically beta-mixing sequences with finite `2+delta` moments—and a query class:

> Construct a finite-sample confidence sequence or reusable-holdout procedure for `k` adaptively chosen Sharpe-ratio or factor-premium queries, robust to heavy tails and dependence, and prove a matching minimax lower bound up to constants or logarithms.

The ratio nature of Sharpe statistics, temporal dependence, heavy tails, and analyst adaptivity must all appear in the theorem rather than being handled informally.

### Win ladder

- **Meaningful first result:** a sharp result for adaptive mean queries under mixing and heavy tails, or a valid self-normalized bound for one adaptive ratio statistic.
- **Field-leading result:** a computationally usable reusable-holdout/confidence-sequence method with near-matching lower bounds.
- **North-star result:** a minimax theory that changes how adaptive strategy and factor research is validated.

### Why it could attract attention

Backtest overfitting is a central quant problem, and adaptive evaluation is central to ML benchmarking. A theorem with realistic return assumptions could become foundational infrastructure for research governance. Its mainstream-math story is weaker than a kissing number or exact rank, but its practical importance may be greater.

### Verification shape

The proof should be paired with adversarial simulations that seek to violate coverage, and with exact definitions for analyst interaction, stopping, multiplicity, and dependence. Any empirical demonstration remains secondary to uniform coverage proofs.

### Principal risk and no-claim boundary

Open-status confidence is medium until a full literature audit shows that the exact combination is absent. A valid confidence theorem does not produce alpha, prove market efficiency, or certify a trading strategy. Later empirical use requires point-in-time data, costs, a lockbox, and a separate economic claim ladder.

## 9. Implicit bias of practical mini-batch AdamW

### Live frontier

[Implicit Bias of AdamW: l-infinity-Norm Constrained Optimization](https://proceedings.mlr.press/v235/xie24e.html) characterizes convergent full-batch AdamW iterates through KKT conditions for an `l_infinity`-constrained loss problem. Recent work shows the landscape is subtler outside that setting: [Implicit Bias of Per-sample Adam on Separable Data: Departure from the Full-batch Regime](https://arxiv.org/abs/2510.26303) finds different behavior for per-sample Adam, while [The Effect of Mini-Batch Noise on the Implicit Bias of Adam](https://arxiv.org/abs/2602.01642) studies stochastic effects. Other 2026 work extends analyses to homogeneous networks and heavy-tailed noise.

### Exact campaign target

Choose a minimal but nonlinear model—preferably a two-layer homogeneous ReLU network or a diagonal deep-linear network—and freeze the optimizer completely:

> Characterize the limit direction or variational bias of mini-batch AdamW with nonzero epsilon, decoupled weight decay, a specified beta schedule, batch sampling, and learning-rate schedule; or give an explicit counterexample to the natural full-batch extrapolation.

### Win ladder

- **Meaningful first result:** a two-dimensional or diagonal model showing a new bias phase or disproving an accepted heuristic.
- **Field-leading result:** a necessary-and-sufficient convergence/bias theorem for a practical parameter regime.
- **North-star result:** a unifying variational characterization that explains when AdamW selects `l_2`, `l_infinity`, another geometry, or no fixed geometry.

### Why it could attract attention

AdamW is ubiquitous in model training, and its implicit regularization remains poorly summarized by existing full-batch theory. A surprising explicit counterexample could travel farther than a technically broader but incremental convergence theorem.

### Verification shape

Small symbolic recurrences, exact counterexamples, and independently reproduced numerical phase diagrams make this a strong AI-research target. The theorem must keep `epsilon`, bias correction, weight-decay placement, minibatching, and scheduling visible; silently setting any of them to zero can change the problem.

### Principal risk and no-claim boundary

The field is moving quickly, and “practical AdamW” is not one algorithm. A result for separable linear logistic regression must not be generalized to deep nonlinear training. This is an excellent paper target, but probably not a Fortune-level story unless it overturns a widely held explanation.

## 10. Robust low-rank factor covariance under heavy tails, contamination, and dependence

### Live frontier

[Robust Estimation of Covariance Matrices: Adversarial Contamination and Beyond](https://arxiv.org/abs/2203.02880) develops a low-rank-adaptive covariance estimator under either adversarial corruption or IID finite-fourth-moment heavy tails. [Heavy-tailed Estimation is Easier than Adversarial Contamination](https://proceedings.mlr.press/v291/cherapanamjeri25a.html) clarifies transfers and separations between the two robustness models. Robust covariance itself is crowded; the opportunity is the exact intersection of structure, dependence, contamination, computation, and downstream portfolio risk.

### Exact campaign target

> Give a polynomial-time estimator for a low-rank-plus-sparse factor covariance matrix from temporally dependent returns with finite fourth moments and `epsilon` contamination, and prove a matching lower bound for covariance error and/or out-of-sample portfolio variance.

### Win ladder

- **Meaningful first result:** one missing pairwise combination, such as factor structure plus mixing and heavy tails, with a sharp rate.
- **Field-leading result:** a computationally efficient estimator matching the information-theoretic rate across all named dimensions.
- **North-star result:** a unified minimax theorem plus portfolio-risk guarantee and a lower bound showing every term is necessary.

### Why it could attract attention

It is directly useful for portfolio risk and robust representation learning. The strongest version could bridge statistics and finance, but the public narrative is less iconic than the top seven.

### Verification shape

Proof obligations decompose well into concentration, identifiability, optimization, and lower-bound modules. Simulations can find missing rate terms, but cannot establish minimaxity.

### Principal risk and no-claim boundary

Because many nearby cases are solved, novelty can evaporate through a paper with slightly different assumptions. A covariance-error theorem is not automatically a portfolio-performance theorem; the decision functional and constraints must be analyzed explicitly.

## 11. Statistical stability and complexity for martingale optimal transport

### Live frontier

Recent work such as [Dual Attainment in Multi-Period Multi-Asset Martingale Optimal Transport and Its Computation](https://arxiv.org/abs/2602.02996) advances duality, attainment, and computation under broad conditions, so generic “prove dual attainment” is no longer a good target. [Computation of Robust Option Prices via Structured Multi-Marginal Martingale Optimal Transport](https://arxiv.org/abs/2406.09959) illustrates the algorithmic progress.

### Exact campaign target

> Establish sharp nonasymptotic statistical rates—and where possible matching lower bounds—for estimating multi-period, multi-asset martingale-transport bounds from empirical marginals for a pinned class of path-dependent payoffs, together with a tractable algorithm attaining the rate.

### Win ladder

- **Meaningful first result:** a dimension-explicit stability modulus for a useful payoff class.
- **Field-leading result:** matching upper and lower sample-complexity rates with a practical solver.
- **North-star result:** a general theory delineating when robust price bounds are statistically estimable versus cursed by dimension.

### Why it could attract attention

This would address whether model-free derivative bounds can be learned reliably from finite market data. It has high mathematical and quant prestige, but a narrower public audience.

### Verification shape

Dual certificates, exact small-instance linear programs, and adversarial lower-bound constructions provide multiple independent checks. Data experiments should illustrate—not substitute for—the theorem.

### Principal risk and no-claim boundary

The proposed gap requires a deeper novelty audit by payoff, metric, number of periods, and dimension. A stability result under compact bounded support should not be summarized as applying to heavy-tailed market data.

## 12. Tight memory–recompute–communication bounds for full training graphs

### Live frontier

Activation checkpointing has mature practical methods. The [PyTorch overview](https://pytorch.org/blog/activation-checkpointing-techniques/) describes the memory–compute tradeoff; [Reducing Activation Recomputation in Large Transformer Models](https://arxiv.org/abs/2205.05198) develops selective recomputation; and [MODeL](https://proceedings.mlr.press/v202/steiner23a/steiner23a.pdf) uses integer programming for general dataflow graphs. The remaining opportunity is not “invent checkpointing,” but a tight theorem for a realistic multi-level training model.

### Exact campaign target

> For a precisely specified Transformer or mixture-of-experts training DAG with device memory, host memory, interconnect bandwidth, recomputation cost, and parallelism constraints, prove a lower bound on step time or communication and give a schedule matching it within a constant factor.

### Win ladder

- **Meaningful first result:** optimality for one nontrivial repeated block or a fixed two-level memory hierarchy.
- **Field-leading result:** a constant-factor algorithm/lower-bound pair for a broad structured DAG family.
- **North-star result:** the first tight, realistic end-to-end law for memory, recomputation, and communication in large-model training.

### Why it could attract attention

The result could directly reduce training cost and clarify when offload, checkpointing, or recomputation is optimal. It is likely to attract systems attention more than general mathematical attention.

### Verification shape

Schedules can be replayed and lower-bound instances generated exactly. The main danger is an underspecified machine model whose “optimality” disappears on real hardware.

### Principal risk and no-claim boundary

Many variants are already solved algorithmically or operationally. A theorem for a chain is not a theorem for full Transformer training; an asymptotic communication lower bound may omit latency, overlap, kernel occupancy, and memory fragmentation.

## 13. Online portfolio regret with nonlinear market impact and partial feedback

### Live frontier

Universal portfolios with transaction costs and online convex optimization with switching costs are established areas. Examples include [Online Convex Optimization with Switching Costs and Delayed Feedback](https://proceedings.mlr.press/v75/chen18b.html) and [Online Learning for Portfolio Selection with Transaction Costs](https://proceedings.mlr.press/v108/uziel20a.html). A viable target must therefore specify a genuinely unresolved combination rather than rediscovering proportional-cost regret.

### Exact campaign target

> Derive a minimax-optimal dynamic-regret bound for portfolio allocation with a pinned nonlinear temporary/permanent impact model, a variation-bounded comparator, constraints, and bandit or delayed feedback; provide a matching lower bound and an implementable algorithm.

### Win ladder

- **Meaningful first result:** close one exponent gap in a fixed impact/feedback model.
- **Field-leading result:** matching dynamic-regret upper and lower bounds with dimension, variation, and cost dependence all explicit.
- **North-star result:** a robust theorem that unifies impact, nonstationarity, and partial information without unrealistic bounded-gradient shortcuts.

### Why it could attract attention

This is directly connected to execution and adaptive allocation. It is unlikely to command broad mathematical attention unless the method resolves a recognized OCO question beyond finance.

### Verification shape

Regret proofs and adversarial constructions are exactly checkable. Empirical profitability remains a separate claim and would require point-in-time data, realistic execution costs, and a sealed out-of-sample evaluation.

### Principal risk and no-claim boundary

The area is crowded and model variants proliferate. A theorem can become vacuous under a comparator budget or impact constant chosen after the fact. This is why it ranks below the more canonical exact frontiers.

## Recently moved or misleading targets to avoid

The live-status audit materially changed the shortlist. The breadth of [OpenAI's ten August 2026 advances](https://openai.com/index/ten-advances-in-mathematics/)—including codes, arithmetic-circuit lower bounds, closest vector, Ramsey theory, and extremal combinatorics—also shows that “open last year” is no longer a sufficient novelty check. Each selected target needs a same-week cousin scan before serious compute is committed.

### Hadamard order 668: no longer a live target

Older lists identified order 668 as the smallest unresolved Hadamard order. Even a [July 24 account](https://byclaude.net/seventy-four-is-more-than-fifty-five) explicitly said its restricted-symmetry argument did not solve the full case. That status is now stale: [Epoch AI's FrontierMath status page](https://epoch.ai/frontiermath/open-problems/hadamard) reports that a later construction encodes matrices for every previously unknown admissible order through 2000, including 668, and provisionally marks the problem AI-solved. Independent validation and attribution could still alter the status, but it is plainly not a sensible new campaign target.

### Grothendieck's constant: moved in August 2026

[New Lower and Upper Bounds for Grothendieck's Constant](https://arxiv.org/abs/2608.11158) reports both a stronger lower bound and an upper-bound improvement. The topic remains important, but starting a generic improvement campaign immediately behind a fresh human–AI advance would be a crowding error.

### The matrix-multiplication exponent: moved again

[A New Bound on the Matrix Multiplication Exponent](https://arxiv.org/abs/2608.16884) reports `omega < 2.371177`, improving the previous `2.371339`. This does not diminish matrix multiplication as a target; it favors the small exact 3×3 rank problem over racing a highly active asymptotic optimization frontier.

### Exact attention I/O complexity: substantially occupied

[The I/O Complexity of Attention, or How Optimal is FlashAttention?](https://proceedings.mlr.press/v235/saha24a.html) establishes tight regimes for forward attention, with subsequent work treating backward passes and variants. A new campaign must identify a real uncovered machine model; “prove FlashAttention is optimal” is too stale and broad.

### “The Jacobian conjecture” without a dimension qualifier

The verified counterexample settles the stated real case in dimensions at least three, not the two-dimensional cousin. Any target or public claim must name the field, regularity/polynomial class, and dimension.

### The Riemann hypothesis itself

It remains the ultimate famous hub, but “solve RH” is a poor initial research contract: too broad, weakly staged, and difficult to falsify at the campaign level. Anthropic's success came from a precise adjacent constant with a visible theorem ladder.

## Recommended campaign portfolio

> **Archival Round 1 portfolio:** retained for provenance. The canonical Round 2 portfolio is in the evidence ledger and adds rectilinear K28, Costas-32, APN-8, weighted regression data selection, and current COLT 2026 targets.

If we want the highest probability of both a serious result and a north-star ceiling, I would run the following portfolio rather than bet everything on one binary outcome.

### Campaign A — primary: ReLU exact depth

- **Week-0 object:** reproduce every `max_n`, `n <= 10`, exact certificate and checker from the July paper.
- **First search target:** `max_11`, with unrestricted-support searches separated from restricted ansätze.
- **Theory target:** characterize the cancellation space or derive a normal form that scales with `n`.
- **Kill criterion:** if three independent search parameterizations produce no new structural information and the obstruction track cannot escape the chosen ansatz, stop calling `max_11` the target and publish only reusable machinery if it is genuinely new.
- **Ceiling:** all `max_n` shallow, or first unconditional depth-three obstruction.

### Campaign B — high-risk parallel track: 3×3 bilinear rank

- **Week-0 object:** reproduce rank-23 integer certificates and the finite-field lower-bound verifier.
- **Construction track:** symmetry-aware rank-22 search, approximate-to-exact reconstruction, modular screens over several primes, then all 729 identities.
- **Obstruction track:** orbit-reduced lower bounds over finite fields and transfer/lifting questions toward characteristic zero.
- **Kill criterion:** no promotion of numerical near-solutions; terminate a search family when exact residual reconstruction and modular tests repeatedly fail.
- **Ceiling:** exact rank 22 or 23.

### Campaign C — theorem track: attention rank versus depth

- **Week-0 object:** write an executable architecture specification and reproduce the paper's short-sequence separation.
- **First theorem target:** depth two, followed by depth three.
- **Counterexample track:** program synthesis for low-rank multi-layer constructions on escalating finite domains, followed by symbolic generalization.
- **Kill criterion:** if the claim changes under innocuous choices of MLP/residual/positional encoding, narrow it before further work.
- **Ceiling:** arbitrary-depth proof or explicit refutation.

### Campaign D — finite-problem reconnaissance: R(5,5)

- **Week-0 object:** reproduce the 42-vertex lower-bound witness checks and the public components of the `R(5,5) <= 46` computation.
- **Construction track:** symmetry-aware graph search on 43 vertices, with every candidate checked by a minimal independent verifier.
- **Obstruction track:** derive degree/subgraph restrictions, encode surviving extension or gluing cases in SAT, and demand proof-producing UNSAT rather than solver exit codes.
- **Kill criterion:** stop construction-heavy allocation if diverse searches merely reconfirm the known energy landscape without a new invariant, restriction, or witness.
- **Ceiling:** determine the exact value in `{43,44,45,46}`.

This mix has complementary failure modes: exact rational construction, finite algebraic and combinatorial search/certificates, and analytic lower-bound theory.

## What I would select first

I would start with **ReLU exact depth**, while maintaining a small reconnaissance branch on **3×3 matrix rank**.

The reason is not that `max_11` alone would match the two north stars. It probably would not. The reason is that `max_11` is an unusually good **entry point into a north-star-scale terminal question**:

- it is fresh enough that the frontier is not ossified;
- the existing proof pipeline is computational and exact;
- positive results have compact rational certificates;
- negative results force genuinely new structural mathematics;
- every increase in `n`, improved depth law, ansatz classification, or normal-form theorem can be useful;
- the strongest outcome would answer a foundational question about whether depth is ever intrinsically necessary for exact CPWL representation.

By contrast, 3×3 rank has the stronger immediate headline but a worse expected path to a nontrivial result. The correct ambitious strategy is therefore not to lower the ceiling; it is to choose a route with a high partial-result floor while keeping the terminal claim enormous.

## Proposed paper-extraction shortlist

The paper-research workflow requires a human gate before downloading and extracting full PDFs. The numbered shortlist below is the smallest corpus I would approve for Phase 1 of the chosen campaign. No PDFs have yet been bulk-downloaded or treated as fully read.

1. [Shallower ReLU Network Representations via Exact Linear Algebra](https://arxiv.org/abs/2607.21651) — current exact frontier and reproducible rational-linear-algebra method.
2. The STOC 2026 predecessor cited by paper 1 — prior `max_5` result and earlier recursive depth bound; needed for the cousin and method map.
3. Wang and Sun's generalized hinging-hyperplane representation — needed to audit the transfer from maxima to arbitrary CPWL functions.
4. [Automated Lower Bounds for Bilinear Complexity over Finite Fields](https://arxiv.org/abs/2603.07280) — certificate framework and current `F_2` lower bound.
5. [55 Additions Suffice for 3x3 Matrix Multiplication at Rank 23](https://arxiv.org/abs/2607.28676) — exact rank-23 witness and verification code.
6. Laderman's original rank-23 algorithm and a reliable modern survey of 3×3 tensor-rank bounds — historical/model baseline.
7. [Quality over Quantity in Attention Layers](https://proceedings.iclr.cc/paper_files/paper/2025/hash/9c537882044c8b5352c363e840872ddb-Abstract-Conference.html) — explicit arbitrary-depth conjecture.
8. [Two (narrow) heads are better than (an arbitrarily wide) one](https://proceedings.iclr.cc/paper_files/paper/2026/hash/221ec998e345bf4a128bf6c48e1aadee-Abstract-Conference.html) — current architecture lower-bound techniques.
9. [The Effect of Attention Head Count on Transformer Approximation](https://proceedings.iclr.cc/paper_files/paper/2026/hash/7d72a514fc6948515af3ee69c1059776-Abstract-Conference.html) — current head-count/parameter lower bounds.
10. [`R(5,5) <= 46`](https://arxiv.org/abs/2409.15709) — current upper-bound method and its independently implemented computation.
11. [Small Ramsey Numbers, 2026 dynamic survey](https://www.combinatorics.org/ojs/index.php/eljc/article/viewFile/DS1/pdf) — authoritative live bounds, historical constructions, and nearest cousins.
12. [Variations on five-dimensional sphere packings](https://arxiv.org/abs/2412.00937) plus its references on the 40–44 bound — finite-configuration alternative.

The next action is to approve **all twelve** or specify numbers. After approval, extraction should produce claim–evidence tables, theorem statements, assumptions, open-problem quotations, certificate/code locations, and a nearest-neighbor novelty matrix—not just prose summaries.

## Search methodology and epistemic status

### Sources used

- Primary papers and official conference proceedings were used for technical claims.
- Maintained expert tables and formal-proof archives were used for live status and exact verification.
- Anthropic/OpenAI/DeepMind research pages were used for first-party campaign details.
- Fortune and similar coverage were used only to estimate public attention, never as the mathematical authority.
- Paper search covered arXiv, OpenAlex, and Hugging Face paper metadata. Semantic Scholar was intermittently rate-limited.
- Perplexity was used for discovery and query expansion; every important technical claim retained here was checked against a primary or first-party source.

### Confidence labels

- **High confidence live named frontiers:** ReLU `max_n` depth, 3×3 bilinear rank, `R(5,5)`, attention rank–depth conjecture, five-dimensional kissing number, fixed-dimensional attention exponent, deterministic RIP.
- **Medium confidence synthesized gaps requiring a deeper Phase-2 novelty audit:** adaptive backtest validity, integrated robust factor covariance, martingale-transport statistical rates, full-DAG training lower bounds, nonlinear-impact dynamic regret.
- **High confidence recently moved/excluded:** Hadamard order 668 (provisional construction status), Grothendieck-bound improvement, matrix exponent record, generic attention I/O optimality.

### Important limitations

1. This is a target-selection study, not a complete literature review of all thirteen areas.
2. “Open as of 2026-08-27” means no resolution was found in the searched primary databases and current authoritative status sources. It is not an omniscience claim.
3. Publication impact and public attention are forecasts, not facts. The ranking deliberately rewards robust mathematical significance after qualification.
4. Solvability probabilities are not numerically estimated; fake precision would be misleading. The ordering reflects relative campaign fit.
5. Before proof work begins, the selected target still needs a formal Phase P0/P1 ledger: exact statement, assumptions, cousins, falsifiers, evidence matrix, and promotion gates.

## Decision point

The substantive choice is between four styles of ambition:

- **Best balanced campaign:** ReLU exact depth.
- **Cleanest potential headline:** exact 3×3 matrix-multiplication rank.
- **Most iconic finite problem:** exact `R(5,5)`.
- **Most direct Transformer theorem:** attention rank versus depth.

My highest-conviction recommendation is to make ReLU depth the primary campaign, keep 3×3 rank as the algebraic moonshot, use `R(5,5)` as the finite-certificate reconnaissance track, and use the transformer conjecture as the analytic lower-bound track. That preserves the scale of the two north stars without confusing ambition with an unstructured attempt at an all-or-nothing famous conjecture.
