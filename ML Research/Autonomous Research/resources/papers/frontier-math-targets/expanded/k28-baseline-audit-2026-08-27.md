# Exact replay of the published K28 upper-bound construction

Date: 2026-08-27  
Purpose: reconstruct the known `7233 <= cr_bar(K28) <= 7234` baseline before any new search

## Source chain

Ábrego, Fernández-Merchant, Leaños, and Salazar's 2008 paper gives, in Table 3,

\[
\widetilde{\operatorname{cr}}(K_{28})\ge 7233,
\qquad
\overline{\operatorname{cr}}(K_{28})\le 7234.
\]

Because every rectilinear drawing is a pseudolinear drawing,

\[
7233\le \widetilde{\operatorname{cr}}(K_{28})
\le \overline{\operatorname{cr}}(K_{28})
\le 7234.
\]

The paper attributes the geometric upper-bound constructions to Oswin Aichholzer's rectilinear crossing-number page. The archived live page at

<http://www.ist.tugraz.at/staff/aichholzer/research/rp/triangulations/crossing/>

lists `n=28`, lower bound `7233`, best known crossing count `7234`, and links `data/best028.asc` as its minimizing example.

Downloaded artifacts:

- Page snapshot: `aichholzer-rectilinear-page-2026-08-27.html`
- Page SHA-256: `3d47a3d113a8fcd7ce9555b4bd4a6574160a2b42f3415dcba9f7950143ed5013`
- Point set: `k28-best028.asc`
- Point-set SHA-256: `666d74d36b125e18e439167918bc150f1e82bbb3db5c99ab568021b7c9bfa6fa`

The point artifact contains 28 integer-coordinate pairs.

## Independent exact replay

`verify_k28_best028.py` uses only Python integer arithmetic. It checks:

1. the file header and uniqueness of all 28 points;
2. every one of the `C(28,3)=3,276` triples has nonzero orientation, hence the set is in general position;
3. for each of the `C(28,4)=20,475` four-point subsets, all three perfect matchings are tested for a proper segment crossing;
4. the total number of crossing pairs is 7,234.

Run:

```text
python3 expanded/verify_k28_best028.py
```

Observed output:

```text
artifact=.../expanded/k28-best028.asc
sha256=666d74d36b125e18e439167918bc150f1e82bbb3db5c99ab568021b7c9bfa6fa
points=28
triples_checked=3276
general_position=true
quadruples_checked=20475
crossings=7234
verified=true
```

For four points in general position, exactly one pair of disjoint straight segments crosses if and only if the four points are in convex position. Thus the loop counts exactly the edge crossings in the complete straight-line drawing; adjacent edges are never considered, and a straight-line drawing in general position has no ambiguous collinear overlap.

## What this establishes—and what it does not

This independently replays the known upper-bound witness:

\[
\overline{\operatorname{cr}}(K_{28})\le7234.
\]

Combined with the published pseudolinear lower bound, it reconstructs the one-bit interval `7233..7234` without relying only on OEIS or MathWorld.

It does **not** decide the open problem. A solution still requires either:

- a realizable 28-point construction with 7,233 crossings; or
- a proof that every realizable 28-point order type has at least 7,234 crossings.

The verifier is intentionally small, but it is not yet a formally verified or independently implemented checker. A second implementation/reviewer should replay it before campaign launch.
