---
created: 2026-09-21
source: https://github.com/ruc-datalab/EvoOntology
type: resource
tags: [data-agents, ontology, semantic-layer, mcp, self-evolving, text-to-sql, heterogeneous-data]
status: unread
---

## What it is

Reference implementation of EvoOntology (RUC DataLab, Renmin University of China) — a versioned ontology layer for data agents that is served over MCP rather than injected into the prompt, built autonomously by a builder agent from the workload, and refined by an evolution agent that proposes localized patches and publishes them only when a paired evaluation beats the parent version. MIT licensed, ~265 stars, 12 commits on `master`. Paired with the paper at [[EvoOntology serves its self-built ontology to data agents over MCP and evolves it with attribution-guided typed edits gated by paired validation - +17.8 Traj-Wise on DDR-Bench]].

Ships as an agent plugin rather than a library: you install it into Claude Code or Codex from a GitHub marketplace, with no clone, virtualenv, or `pip install` step, and the agent then has three slash commands for the build / evolve / inspect lifecycle.

## Why it's interesting

It is the rare research artifact that ships the thing it argues for as a working agent plugin, so the paper's central claim — that an ontology should be *queried* through tools rather than *injected* as context — is directly testable on your own data with `/evo-build`. The two MCP tools it exposes, `browse_semantics` and `resolve_semantics`, are a concrete answer to the question the vault's semantic-layer notes keep circling: what is the minimum tool surface an agent needs over a semantic layer.

The other draw is the gated-versioning machinery. Every accepted change is a diffable patch between a parent and a candidate ontology version, evaluated under identical decoding and interaction budgets, which makes the ontology inspectable and reversible in a way a hand-maintained dbt semantic model or a Notion context page is not.

## How it works

**Build.** `/evo-build` (Claude Code) or `$build-ontology` (Codex) runs the builder agent: it derives candidate concepts from the workload queries, verifies each against the raw sources with probe queries, and publishes the survivors as `ontology_v0`. Nothing is committed on a natural-language description alone — a candidate needs probe evidence.

**Use.** The data agent calls `browse_semantics` and `resolve_semantics` on demand during a task. Only a compact session manifest goes into the prompt at session start; detailed records and their linked objects are fetched per turn. Tool interactions and outcomes are recorded as trajectories.

**Evolve.** `/evo-evolve` (or `$evolve-ontology`) runs the evolution agent over that trajectory history: diagnose recurring behavior, attribute it to the Content, Tool, or Schema layer, and emit one localized candidate patch confined to that single layer.

**Evaluate and publish.** Parent and candidate are run on the same data, agent, decoding settings, and interaction budget. A passing candidate is published as `ontology_vN+1`; a failing one is discarded and its result is fed into the next round so the loop does not retry the same dead end.

**Inspect.** `/evo-visualize` (or `$explore-ontology`) opens an explorer over the three layers — the Content Layer's grounded Terms, Mappings, Constraints, Evidence and their relationships; the Schema Layer's object types, fields, and legal relationship rules; the Tool Layer's MCP tools and runtime manifest. Build and Evolve open it automatically on completion.

**The three layers.** Content Layer is a typed semantic graph over four node families (Terms, Mappings, Constraints, Evidence) with Semantic Relations between Terms and Structural References attaching Mappings, Constraints, and Evidence to what they ground, govern, or support. Schema Layer declares the fields of those families plus the admissible relation types and reference patterns, so it sets the representational boundary without touching instantiated content. Tool Layer is the MCP surface: two tools plus the manifest.

**Data sources.** SQLite gets built-in read-only task replay. Other sources go through the host agent's own tools with explicit observation recording, so the ontology's Evidence stays anchored to something that was actually executed.

**Benchmarks.** Three self-contained evaluation environments under `benchmarks/`, each implementing an `EvolutionAdapter` and preserving its native rollout and scoring protocol: `benchmarks/bird/` (text-to-SQL over real databases), `benchmarks/ddr_10k/` (open-ended research over heterogeneous financial filings), `benchmarks/insightbench/` (iterative business analysis). List them with `python -m benchmarks list`; `docs/guide/new-benchmark.md` documents the adapter, data-loader, rollout, configuration, and seed-skill contract for adding a fourth.

**Layout.** `evoontology/` is the deterministic core (ontology store, runtime/MCP, trajectories, triggers, evaluation, evolution state, validation, visualization). `plugins/` holds the self-contained Claude Code and Codex plugins with the Build, Evolve, and Visualize skills. `scripts/` syncs core into the plugins. Dependencies in `pyproject.toml`.

## Key links

- [GitHub](https://github.com/ruc-datalab/EvoOntology)
- [Paper (arXiv 2609.15779)](https://arxiv.org/abs/2609.15779)
- [Usage guide](https://github.com/ruc-datalab/EvoOntology/blob/master/USAGE.md) — installation, workspace, lifecycle, configuration, data boundaries
- [Architecture](https://github.com/ruc-datalab/EvoOntology/blob/master/docs/architecture.md) — module boundaries, evolution state machine, evaluation modes
- [Claude Code plugin](https://github.com/ruc-datalab/EvoOntology/tree/master/plugins/claude-code)
- [Codex plugin](https://github.com/ruc-datalab/EvoOntology/tree/master/plugins/evoontology-codex)

## Notes

Worth actually running, because the claim that motivates the whole design is cheap to check locally: point `/evo-build` at a SQLite database, then compare an agent that has `browse_semantics` against the same agent with the same content pasted into its prompt. That is exactly the paper's `Baseline + SL` comparison, and it is the one that decides whether the MCP framing is doing the work or the content is.

Two things to look for in the code. First, the margin `tau` in the paired-validation gate — the paper never states its value, and the gate is the single load-bearing component in the ablation, so whatever `evoontology/validation` uses is the real acceptance policy. Second, whether the evolution state machine stores one ontology per backbone; the paper's cross-backbone transfer numbers say the evolved store is tuned per model, which means the artifact is not portable between agents the way a dbt semantic layer is. That is a governance question for anyone thinking of this as shared infrastructure, in the sense of [[Palantir Ontology gives enterprise agents a decision-centric substrate by surfacing data logic and action as tools governed by one security model]].

The tool surface is two tools, which lands inside the 5-15 range [[MCP Best Practices]] recommends, and the manifest-plus-on-demand-retrieval pattern is the same progressive-disclosure move as [[code execution with MCP cuts tool token overhead 98 percent by presenting servers as filesystem APIs instead of upfront definitions]].

See also [[moc - Data Agent]].
