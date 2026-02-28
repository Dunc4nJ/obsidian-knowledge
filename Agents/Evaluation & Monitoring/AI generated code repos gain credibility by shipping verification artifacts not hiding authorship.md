---
created: 2026-02-25
description: AI-written code repos should ship extreme verification — tests, fuzzing, conformance harnesses, formal proofs — rather than hiding AI authorship
type: learning
source: Discord discussion in #chief-rust-monkey, 2026-02-24
---
# AI generated code repos gain credibility by shipping verification artifacts not hiding authorship

The strategy for making AI-generated repos immune to "it's just AI slop" criticism isn't to hide the authorship — it's to **drown critics in proof**.

## Four levels of verification

1. **Extreme test coverage (95%+)** — Property-based tests, edge cases, error paths. Agents will happily generate 500 test cases where a human would stop at 50.
2. **Fuzz testing for parsers** — If code parses anything (JSON, configs, protocols, user input), throw random/malformed data at it. Agents can generate the harnesses. Millions of inputs with zero crashes is a credibility signal.
3. **Conformance harnesses for ports** — When reimplementing a library across languages, build a harness that runs both implementations against the same inputs and diffs outputs. Proves behavioral equivalence mechanically.
4. **Formal proofs in Lean** — For hardest logic (crypto, consensus, data structures), write mathematical proofs of correctness. The nuclear option — proven correct in Lean means nobody can call it slop.

## The meta-insight

The boring mechanical work of verification is free with agents. The winning repos will have verification code that's **3x the size of the implementation**. That's the moat — not hiding who (or what) wrote it.

Related: [[agent-first engineering replaces coding with environment design scaffolding and feedback loops]]
