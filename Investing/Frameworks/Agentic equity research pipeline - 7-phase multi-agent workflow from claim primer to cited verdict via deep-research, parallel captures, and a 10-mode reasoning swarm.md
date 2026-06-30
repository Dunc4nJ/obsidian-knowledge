---
created: 2026-06-30
description: A reusable 7-phase multi-agent methodology for evaluating a single equity's asymmetric upside — claim grounding, adversarial deep-research, parallel source capture into a closed evidence base, claim-by-claim synthesis, a 10-mode (claude+codex) reasoning swarm, and an adversarially-verified gap-fill rerun. Documented from the MaxLinear (MXL) execution.
source: internal
type: framework
---

# Agentic equity research pipeline — 7-phase multi-agent workflow from claim primer to cited verdict

A methodology for taking a stock + a pile of bull/bear claims and producing a **grounded, unbiased, fully-cited verdict on asymmetric upside** — every factual assertion traceable to a captured primary source. Built and executed end-to-end on [[MaxLinear (MXL)]] (the worked example referenced throughout). Reusable for any single-name thesis evaluation.

The governing principle: **separate what is true from what is claimed, and separate the business from the stock.** Bull/bear threads are advocacy, not evidence. The pipeline mechanically fact-checks each claim against primary sources, captures those sources into a closed evidence base, then reasons over *only* that evidence base — so the final verdict cannot smuggle in folklore.

## When to use this

- A single ticker you want to evaluate rigorously, especially when a circulating narrative (X threads, paid Substack, sell-side) is doing the price-setting and you suspect distortion.
- You have access to: the `invest` CLI + an Obsidian vault structured per [[CLAUDE]], the `/url-to-obsidian` capture skill, the `/deep-research` workflow, the `/modes-of-reasoning-project-analysis` skill, and NTM for the reasoning swarm.
- You want the output to be a durable, linked knowledge artifact (not a throwaway chat), with audit trail.

## The 7 phases

### Phase 0 — Infrastructure & task graph
- Register the session (agent-mail `macro_start_session`) for identity + coordination.
- Survey vault state: confirm the **canonical working clone** (a recurring trap — there were two MXL clones; the fresher one won; see [[CLAUDE]] and the canonical-clone rule). Confirm the ticker's sector home (MXL lives in `Chips/`, not `Photonics/` — placed by primary investment thesis, not product taxonomy).
- Build the full task list with **dependencies** up front (grounding → briefing → deep-research → captures → sync → synthesis → swarm → verdict → commit). This makes the multi-phase shape legible and lets later phases block on earlier ones.

### Phase 1 — Current-state grounding + briefing note
- A handful of targeted web searches to establish the present situation: market cap, the re-rating, the latest reported quarter + guidance, the products, where the name sits in its value chain, recent price action and *why*.
- Write an **orientation briefing note** (`type: analysis`, `source: internal`): what the company is, the five-pillar bull case **marked explicitly as opinion/unverified**, open questions carried forward. Point-in-time data (price, market cap, consensus) stays inline as plain URLs; durable sources get wiki-linked after capture. This note is scaffolding, not the verdict.

### Phase 2 — Adversarial claim evaluation (`/deep-research`)
- Decompose the primer's claims into a single structured question and run the **deep-research workflow** (fan-out searches → fetch → extract falsifiable claims → 3-vote adversarial verification → synthesize). On MXL this was ~106 agents.
- Output per claim: verdict (**confirmed / partially confirmed / unverified / contradicted**), the primary-source evidence with URL, and *what the bull framing omits*.
- Critically, it also surfaces **what it could NOT verify** — gaps become explicit, not silently treated as confirmed. (On MXL, 6 of 10 claim areas came back unverified on the first pass and were flagged for a later gap-fill.)
- It emits the **grouped primary-source URL list** that feeds the capture phase.

### Phase 3 — Parallel source capture into a closed evidence base
This is the heart of the "every claim traces to a verbatim primary source" guarantee.
- Dispatch **forked subagents in parallel**, one per source (or small batch), each invoking `/url-to-obsidian` and obeying [[CLAUDE]]'s placement/frontmatter/media/wiki-link rules.
- Each worker brief specifies: (a) destination folder per the placement matrix (ticker-specific → the ticker folder; multi-ticker industry → `<Sector>/Research/`); (b) **skip git + `invest sync`** (the parent batches these); (c) the canonical clone path explicitly; (d) the **verification-critical points to extract verbatim** — including instructing workers to confirm *absences* (e.g. "grep the release; state explicitly that no node is named", "confirm the word 'energy' appears zero times"). Absence-of-evidence, surfaced deliberately, is itself a finding.
- **Model assignment**: worker subagents run on `opus`, reserving the premium main-loop model for orchestration and synthesis (a standing user directive — see the related feedback memory).
- **Primary sources only**: company PRs, SEC filings (10-K/10-Q/8-K/Form 4), earnings transcripts, named-analyst notes, conference papers, substantive bear theses, trade-press reporting. NOT point-in-time aggregator pages (price targets, short interest, ownership %) — those stay inline.
- On MXL this ran 14 workers → 21 notes in pass 1; the gap-fill rerun added 6 workers → 13 notes + 1 addendum.

### Phase 4 — Sync & integrity
- Parent runs `invest sync` once (regenerates managed MOC sections from folder reality), creates any missing wiki-link target folders (`invest add-ticker`), and mechanically verifies **no orphan images** (every `_media/` file embedded in ≥1 note).

### Phase 5 — Claim-by-claim synthesis note
- A single `type: analysis` note that walks every primer claim with its verdict, **wiki-linking each claim to the captured source that settles it**. Bull primers cited as opinion; the bear case included for balance; discrepancies (e.g. the "$210M" that conflated software licenses; the "4nm/3nm GAA" node folklore) called out explicitly.
- This note becomes the **read-this-first** entry point and the grounding for the reasoning swarm.

### Phase 6 — Multi-mode reasoning swarm (`/modes-of-reasoning-project-analysis` via NTM)
The decision question ("asymmetric upside in 6–12 months?") is answered by **10 agents, each applying one distinct reasoning mode**, spanning ≥3 taxonomy axes to avoid an echo chamber. On MXL: a **mix of claude and codex** agents (5 + 5) —
- *Claude*: Game-Theoretic (H1), Decision-Analysis (G1), Scenario-Simulation (F7), Sensemaking/Narrative (I5), Calibration/Debiasing (L2).
- *Codex*: Reference-Class (B10), Bayesian (B3), Fermi (B11), Robust/Worst-Case (L3), Adversarial/Falsificationist (H2).

Mechanics that matter:
- A **CONTEXT_PACK** file pins the closed evidence base (absolute paths to every captured note), the established facts, the **known limitations** (selection bias, vendor self-report, missing valuation inputs), and the output contract. Every agent reads it first; every claim must cite a note filename + verbatim quote. No new web research — gaps get labeled, never filled with assumption.
- Opposing pairs are deliberate (Worst-Case ↔ Decision-Analysis; Falsificationist ↔ Bayesian) and one **meta-mode (L2 Calibration)** audits the evidence tiers the others rely on.
- A monitoring cron nudges stuck panes; early-stop at 8+ substantive outputs.
- **Phase 5.5 ground-truth check**: spot-check the top findings' quotes against the actual vault notes before synthesizing (catches an agent inventing a quote).
- **Synthesis by triangulation, not concatenation**: 3+ modes agreeing via *different* methodologies → Kernel; 2 → Supported; 1 → Hypothesis; disagreement → documented + resolved by diagnosing *why* (different evidence / values / axes). On MXL this produced 7 kernel findings and a verdict note.

### Phase 7 — Gap-fill rerun (the iteration loop)
The swarm's `Open Questions` and the meta-mode's flagged gaps drive a second pass — this is where the methodology earns "fund-grade":
- A **custom gap-fill Workflow**: one researcher per gap area (consensus/positioning/FY-prior-10-K/insiders/foundry-node/design-wins/peer-benchmark/bear-half/architecture-adoption/supply-chain), each load-bearing finding **adversarially re-verified through independent sources** before acceptance (refute-by-default). On MXL: 30 agents across 10 gaps.
- Capture-worthy results → another round of Opus `/url-to-obsidian` workers; point-in-time data stays inline.
- Write a **gap-fill addendum note** stating what each gap revealed and **which mode posteriors/corrections moved**, plus an update callout on the original verdict. Then sync + single commit.

## What makes the output trustworthy (the invariants)

1. **Closed evidence base.** The verdict reasons over captured notes only. Anything not captured is an explicit Open Question, never an assumption.
2. **Absence is a finding.** Workers are instructed to confirm and state what a source does *not* say (no node disclosed; "30% energy" appears nowhere; SemiAnalysis mentions the name zero times). This is where most narrative distortion hides.
3. **Evidence tiers.** Audited filing > company PR > transcript > analyst paraphrase > unsourced folklore. The meta-mode grades every load-bearing claim by tier and refuses to let a weak-tier "moat" carry a strong-tier conclusion.
4. **Separate the business from the stock.** "Is it inflecting?" (often filing-grade yes) is a different question from "is the *stock* asymmetric at $X?" (needs valuation/positioning inputs the bull base usually lacks).
5. **Selection-bias correction.** Deliberately collect the bear half; a vault that only captured bull-cited sources will confirm the bull case by construction.
6. **Provenance everywhere.** Every claim → source note + verbatim quote → report section. Full mode outputs preserved in the workspace.

## The orchestration patterns (transferable)

- **Pipeline > barrier.** In the gap-fill workflow, each gap flows straight into its own verification as it completes (no global barrier) — fast gaps verify while slow ones still sweep.
- **Adversarial verification with refute-by-default.** Don't ask "is this true?"; spawn an independent skeptic told to refute, default to `isReal=false` if it can't be independently corroborated.
- **Forked parallel captures, batched commit.** Workers never touch git/sync; the parent runs `invest sync` once and commits once — avoids write races and keeps history clean.
- **Closed-world context pack.** For any reasoning-over-evidence step, pin the admissible evidence explicitly and forbid new research mid-reason, so conclusions are auditable and reproducible.
- **Mode diversity over depth.** Ten cheap, *differently-biased* passes beat one deep pass — but only if they span axes and one mode audits the instrument.

## Worked-example outcome (MXL, June 2026)

Verdict: **business inflection real and filing-grade; clean asymmetric upside NOT established at ~$69.** What existed was a conditional, time-gated *window trade* (extended pluggable-DSP window, endpoint CPO at Feynman ~2028) on a real 800G-incumbent ramp — but with the 1.6T engine dated to 2027, MXL last-to-volume among four suppliers, and (the gap-fill's decisive find) **consensus already pricing the ramp with a mean PT at/below spot**. Posture: staged, falsifier-gated entry, Q2-print as the decision node — not a full-size buy. The methodology's value wasn't the verdict per se but that **every load-bearing claim survived adversarial verification or was explicitly labeled unverified** — and the gap-fill caught a materially missed tail (the Silicon Motion arbitration) that the first pass walked past.

See: [[MXL bull case evaluated claim-by-claim 2026-06 - extended pluggable window real but MXL-specific moats unsourced, 1.6T supplier count is 4 not 3, analog optionality genuine]], [[MXL asymmetric upside verdict 2026-06 - 10-mode swarm finds real inflection but no clean asymmetry at 69, window rent time-gated to late-2026 Rushmore binary, stage entry on Q2 print]], [[MXL gap-fill 2026-06-11 - Street already prices the ramp with consensus PT at spot, node ceiling 4nm per FY25 10-K, Silicon Motion arbitration tail uncovered, short-covering not retail drove the move]].

## Related frameworks

- [[SJ Investments asymmetric investing framework screens for compressed valuations with uncapped upside]] — the *what* (the asymmetry screen this pipeline operationalizes the *how* for).
- [[SJ Investments macro-to-bottleneck funnel identifies 10x investments through sector scarcity analysis]] — upstream sector-selection that feeds single-name evaluation.
