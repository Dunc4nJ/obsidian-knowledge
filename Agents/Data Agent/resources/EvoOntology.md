---
created: 2026-09-21
source: https://github.com/ruc-datalab/EvoOntology
type: resource
tags: [data-agents, ontology, semantic-layer, mcp, self-evolving, text-to-sql, heterogeneous-data]
status: exploring
---

## What it is

Reference implementation of EvoOntology (RUC DataLab, Renmin University of China) — a versioned ontology layer for data agents that is served over MCP rather than injected into the prompt, built autonomously by a builder agent from the workload, and refined by an evolution agent that proposes localized patches and publishes them only when a paired evaluation beats the parent version. Paired with the paper at [[EvoOntology serves its self-built ontology to data agents over MCP and evolves it with attribution-guided typed edits gated by paired validation - +17.8 Traj-Wise on DDR-Bench]].

MIT licensed, Python, created 2026-09-15 (one day after the arXiv v1 posting). 266 stars and 23 forks as of 21 Sep 2026, last push 2026-09-21. Root holds `README.md`, `README.zh-CN.md`, `USAGE.md`, `LICENSE`, `pyproject.toml`, and the `assets`, `benchmarks`, `docs`, `evoontology`, `plugins`, `scripts`, `tests` directories.

Ships as an agent plugin rather than a library: you install it into Claude Code or Codex from a GitHub marketplace, with no clone, virtualenv, or `pip install` step, and the agent then has three slash commands for the build, evolve, and inspect lifecycle.

*The framing diagram: blind exploration over tables, CSVs, docs, databases, charts and logs on the left, versus the ontology layer with its typed node and edge families plus the Diagnose - Attribute - Patch - Evaluate self-evolution loop on the right.*

![[evoontology-repo-001.png]]

## Why it's interesting

It is the rare research artifact that ships the thing it argues for as a working agent plugin, so the paper's central claim — that an ontology should be *queried* through tools rather than *injected* as context — is directly testable on your own data with `/evo-build`. The two MCP tools it exposes, `browse_semantics` and `resolve_semantics`, are a concrete answer to the question the vault's semantic-layer notes keep circling: what is the minimum tool surface an agent needs over a semantic layer.

The other draw is that the repo answers questions the paper leaves open. The paper writes its acceptance rule as a margin `tau` and never gives it a value; the code shows `tau` is zero. The paper's Schema Layer is an abstraction; the explorer shows its five object types, their field counts, and the controlled directionality of every relation type. The paper describes a manifest; the explorer prints one verbatim.

## How it works

*The full builder-and-evolver framework at high resolution: the agent's two tool families, the builder extracting and grounding candidate concepts, and the evolution agent diagnosing, attributing, patching, and gating.*

![[evoontology-repo-002.png]]

**Build.** `/evo-build` (Claude Code) or `$build-ontology` (Codex) runs the builder agent: it derives candidate concepts from the workload queries, verifies each against the raw sources with probe queries, and publishes the survivors as `ontology_v0`. Nothing is committed on a natural-language description alone — a candidate needs probe evidence.

**Use.** The data agent calls `browse_semantics` and `resolve_semantics` on demand during a task. Only a compact session manifest goes into the prompt at session start; detailed records and their linked objects are fetched per turn. Tool interactions and outcomes are recorded as trajectories.

**Evolve.** `/evo-evolve` (or `$evolve-ontology`) runs the evolution agent over that trajectory history: diagnose recurring behavior, attribute it to the Content, Tool, or Schema layer, and emit one localized candidate patch confined to that single layer.

**Evaluate and publish.** Parent and candidate are run on the same data, agent, decoding settings, and interaction budget. A passing candidate is published as `ontology_vN+1`; a failing one is discarded and its result is fed into the next round so the loop does not retry the same dead end. `evoontology/evaluation/evaluation.py` holds the actual gate as an `EvaluationGate` class with two protocols picked by whether ground truth exists. With ground truth the rule is `candidate_avg > parent_avg`, a strict inequality with no margin. Without it, parent and candidate are compared per validation task under **A/B anonymization** by an LLM judge, and the candidate is accepted only if it wins strictly more non-tie tasks *and* records zero critical errors, where a critical error is a wrong conclusion, a contradiction, an unanswered question, or an execution failure. The module owns the aggregation and the anonymization helpers but not the scoring function or the judge call.

**Inspect.** `/evo-visualize` (or `$explore-ontology`) opens the Ontology Layer Explorer, a three-tab read-only view with a version picker, an "Active version" badge, a Compare button, semantic-object search, and English/Chinese toggle. Build and Evolve open it automatically on completion.

### The three layers

*Ontology Content tab: the live content graph for a Formula 1 database, with the legend's object counts on the left and a Term inspector on the right showing Driver Standing Points as `type: metric` with its definition, scope, aliases, mappings, and relations.*

![[evoontology-repo-003.png]]

Content Layer is a typed semantic graph over four node families (Terms, Mappings, Constraints, Evidence) with Semantic Relations between Terms and Structural References attaching Mappings, Constraints, and Evidence to what they ground, govern, or support. Solid edges are Semantic Relations, dotted are Structural References. The example store's counts are worth noting: 19 Terms, 16 Mappings, 7 Constraints, 13 Evidence records, 13 Semantic Relations, and 102 Structural References. The relational edges are outnumbered about eight to one by grounding edges.

*Schema Layer tab: the five object types with field counts, and the five controlled `relation_type` values with their declared directionality.*

![[evoontology-repo-004.png]]

Schema Layer declares Term (8 fields), Mapping (12), Constraint (10), Evidence (6) and Relation (8), plus the admissible relation types. A Term's fields are `id`, `name`, `type`, `definition`, `scope`, `aliases`, `evidence_refs`, `lifecycle_state`. The `relation_type` vocabulary is `association` and `equivalence` (both undirected and symmetric), `hierarchy` (parent to child), `composition` (whole to part), and `derivation` (base concept to derived result).

*Tool Layer tab: the two semantic MCP tools with their parameters, and the session manifest verbatim.*

![[evoontology-repo-005.png]]

Tool Layer is the MCP surface, served by `tool_server.semantic_mcp`. `browse_semantics(query, kind, limit)` finds up to 6 catalog items; `resolve_semantics(mentions, context)` resolves up to 5 concepts to grounded mappings, relations, constraints, and evidence. The manifest names itself a set of "bounded navigation aids," tells the agent to prefer `resolve_semantics` and use `browse_semantics` only for discovery, and closes by conceding the layer may be wrong: "Resolved mappings are guidance, not final answers — always validate against the actual data with your native query tools."

### Data sources and benchmarks

SQLite gets built-in read-only task replay. Other sources go through the host agent's own tools with explicit observation recording, so the ontology's Evidence stays anchored to something that was actually executed.

Three self-contained evaluation environments under `benchmarks/`, each implementing an `EvolutionAdapter` and preserving its native rollout and scoring protocol: `benchmarks/bird/` (text-to-SQL over real databases), `benchmarks/ddr_10k/` (open-ended research over heterogeneous financial filings), `benchmarks/insightbench/` (iterative business analysis). List them with `python -m benchmarks list`; `docs/guide/new-benchmark.md` documents the adapter, data-loader, rollout, configuration, and seed-skill contract for adding a fourth.

Each benchmark directory carries its own `agent/`, `tool_server/`, `data/`, `scripts/`, `requirements.txt`, `config.py`, `evolution_adapter.py`, `trajectory_recorder.py`, `evaluation_worker.py`, `run_agent.py`, and `run_evaluation.py`. The reproduction pair is `configs/baseline.yaml` and `configs/ontology.yaml`, which are identical except for `condition`, the `semantic.enabled` flag, and the extra `semantic` MCP server. Both pin `temperature: 0.0` and `max_turns: 30`, so the paper's "identical decoding and interaction budgets" means greedy decoding under a 30-turn cap.

**Layout.** `evoontology/` is the deterministic core: `ontology`, `runtime`, `trajectory`, `trigger`, `evaluation`, `evolution`, `visualization`, plus `validate.py`, `workflow.py`, `workspace.py`. `plugins/` holds the self-contained Claude Code and Codex plugins with the Build, Evolve, and Visualize skills. `scripts/` syncs core into the plugins. Dependencies in `pyproject.toml`.

## Key links

- [GitHub](https://github.com/ruc-datalab/EvoOntology)
- [Paper (arXiv 2609.15779)](https://arxiv.org/abs/2609.15779)
- [Usage guide](https://github.com/ruc-datalab/EvoOntology/blob/master/USAGE.md) — installation, workspace, lifecycle, configuration, data boundaries
- [Architecture](https://github.com/ruc-datalab/EvoOntology/blob/master/docs/architecture.md) — module boundaries, evolution state machine, evaluation modes
- [Adding a benchmark](https://github.com/ruc-datalab/EvoOntology/blob/master/docs/guide/new-benchmark.md)
- [Claude Code plugin](https://github.com/ruc-datalab/EvoOntology/tree/master/plugins/claude-code)
- [Codex plugin](https://github.com/ruc-datalab/EvoOntology/tree/master/plugins/evoontology-codex)
- [README.zh-CN.md](https://github.com/ruc-datalab/EvoOntology/blob/master/README.zh-CN.md) — Chinese translation

## Notes

Worth actually running, because the claim that motivates the whole design is cheap to check locally: point `/evo-build` at a SQLite database, then compare an agent that has `browse_semantics` against the same agent with the same content pasted into its prompt. That is exactly the paper's `Baseline + SL` comparison, and it is the one that decides whether the MCP framing is doing the work or the content is. The `configs/baseline.yaml` and `configs/ontology.yaml` pair is the ready-made harness for it.

**The `tau` question is settled and the answer is deflationary.** I went looking for the acceptance margin because the gate is the single load-bearing component in the paper's ablation, worth −11.2 when removed, and the paper leaves `tau` as an unvalued symbol. The code uses a strict inequality, so `tau = 0`. The gate therefore blocks regressions but admits any improvement, including noise-level ones, and on DDR-Bench and InsightBench the thing deciding the improvement is an LLM judge rather than a scorer. That reframes the ablation: the gate is worth 11 points because unfiltered patches are actively destructive, not because the threshold is discriminating.

**Still open:** whether the evolution state machine stores one ontology per backbone. The paper's cross-backbone transfer numbers say the evolved store is tuned per model, which means the artifact is not portable between agents the way a dbt semantic layer is. `evoontology/evolution` and `evoontology/workspace.py` are where that would live. It is a governance question for anyone thinking of this as shared infrastructure, in the sense of [[Palantir Ontology gives enterprise agents a decision-centric substrate by surfacing data logic and action as tools governed by one security model]].

The tool surface is two tools, which lands inside the 5-15 range [[MCP Best Practices]] recommends, and the manifest-plus-on-demand-retrieval pattern is the same progressive-disclosure move as [[code execution with MCP cuts tool token overhead 98 percent by presenting servers as filesystem APIs instead of upfront definitions]].

See also [[moc - Data Agent]].
