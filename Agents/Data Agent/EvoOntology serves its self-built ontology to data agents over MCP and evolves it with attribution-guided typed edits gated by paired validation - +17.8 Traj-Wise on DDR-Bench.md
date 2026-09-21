---
created: 2026-09-21
source: https://arxiv.org/abs/2609.15779
authors: Meiduo Chong, Shaolei Zhang, Ju Fan, Xiaoyong Du (Renmin University of China)
published: 2026-09-14
type: knowledge
tags: [data-agents, ontology, semantic-layer, context-layer, mcp, self-evolving, text-to-sql, heterogeneous-data, agent-data-gap]
description: The first research entry in this folder that builds an ontology agent-side, autonomously, and self-evolving. EvoOntology names the agent-data gap (heterogeneous data lives outside the agent, reachable only through generic tools) and answers it with a versioned ontology served as an MCP server rather than injected into the prompt - a Content Layer of Terms, Mappings, Constraints and Evidence, a Schema Layer that bounds what can be represented, and a Tool Layer of exactly two tools plus a session manifest. A builder agent constructs the initial ontology from the workload by probing the raw sources and committing only what verifies; an evolution agent then mines interaction trajectories for recurrent failure signatures, attributes each to one of Content, Tool or Schema, emits a patch confined to that single level, and publishes it only when it beats its parent by margin tau on a held-out validation split under identical decoding and interaction budgets. Average +17.8 Trajectory-Wise on DDR-Bench across six backbones, +7.4 EX on BIRD, and only +1.9 on InsightBench. Two findings cut against the paper's own framing - the ablation makes Relations the least load-bearing object family at -2.1 while flat Mappings carry -13.4, and Tool-level edits account for 57 percent of the accepted gain, so the serving surface matters more than the ontology's sophistication. Cross-backbone transfer shows the evolved store is tuned per model, which makes it a per-agent artifact rather than shared infrastructure.
---

## Key Takeaways

- **The contribution is a delivery mechanism, not an ontology format, and the paper's own strongest evidence is the comparison that isolates it.** `Baseline + SL` takes the builder agent's ontology and prepends it to the prompt as a static fragment; `EvoOntology` serves the identical content through two MCP tools the agent queries per turn. Same content, different delivery. The static version is *worse than no ontology at all* on four of six backbones on DDR-Bench, including −15.0 Trajectory-Wise on Claude-Sonnet-5, and drops Execution Accuracy on BIRD for every strong backbone (−5.6 on GPT-5.5) while raising Valid Efficiency Score across the board. The authors read that as a static fragment competing with the agent's other instructions and being unprunable per turn. It is the cleanest answer yet to a question the vault's semantic-layer notes keep deferring: injecting a good semantic layer into context can actively hurt, and the fix is to make it queryable. That reframes [[data agents are useless without a context layer that captures business definitions and tribal knowledge|a16z's living context layer]] and [[LangChain's agent-first data stack scales self-service analytics 40x by making context explicit across dbt models, a semantic layer, workspace guides, and endorsements|LangChain's five explicit context surfaces]] as claims about *content* that say nothing about interface, and it puts [[Palantir Ontology gives enterprise agents a decision-centric substrate by surfacing data logic and action as tools governed by one security model|Palantir's ontology-as-tools framing]] on measured ground for the first time in this folder.

- **The ablation quietly vindicates [[MotherDuck's Simon Spati splits semantic layer from context layer by what compiles to SQL, and argues sophistication is a cost not a default|Späti's "sophistication is a cost, not a default"]] even as the paper's title argues the opposite.** Masking each object family from the evolved ontology puts **Mappings at −13.4** and **Evidence at −8.7**, while **Relations — the graph edges, the thing that makes this an ontology rather than a glossary — cost only −2.1**, and Constraints only −3.5. Mappings ground a Term to concrete columns and join paths; Evidence is the probe query that lets the agent check a candidate SQL fragment against the real value distribution. So what carries the result is flat grounding plus executable receipts, which is very close to the flat curated topic tree MotherDuck's own evals found beat a graph. Späti's decision rule was whether the bottleneck is *relating entities* or *picking the right document*; EvoOntology's numbers say that on these three benchmarks it is neither, it is *knowing which column means what and having seen its values*. The graph structure is nearly free to keep and nearly worthless to have.

- **The gate is the mechanism, and its threshold is never disclosed.** An edit is accepted only when the candidate ontology beats its parent by margin `tau` on the same held-out validation set, same backbone, same decoding, same interaction budget, with the candidate differing from the parent at exactly one level. Remove that gate and accept every patch, and DDR-Bench falls **−11.2** points, the largest drop in any ablation, because unfiltered candidates admit regressions the next round cannot undo. Remove the attribution tag and it falls −6.3; remove trace clustering, −4.8; replace the typed patch with a free-form rewrite, only −1.7. The authors' own summary is that the loop is "more selective than iterative," which is the same conclusion [[Self-Harness lets a fixed LLM rewrite its own agent harness from clustered failure traces, lifting Terminal-Bench held-out pass rates up to 21 points|Self-Harness reached for harness edits]] and the same admission-function argument as [[memory is a compiler not a database - Ashwin Gopinath argues admission and action utility functions are the moat, and silence is the evidence they work|memory as a compiler, where the moat is what earns a write]]. Yet the paper never states the value of `tau`, the size of the validation split, or how many candidates were proposed per accepted round. The single load-bearing component is reported only by its absence.

- **The evolved ontology is a per-model artifact, which breaks the shared-infrastructure story this folder has been building.** Every backbone evolves independently from the same initial state, and they diverge: pairwise Jaccard overlap of accepted Term identifiers never exceeds 0.62, and the two Claude models share *less* with each other (0.55) than the two GPT models do (0.61). Serve one backbone's evolved store to another and performance drops by at least 6.6 points versus its own store, with the diagonal winning every column. The paper treats this as evidence that backbone-specific evolution is beneficial; read the other way, it means the artifact is not portable, which is exactly what a semantic layer in [[Snowflake, Databricks and ClickHouse preview AI architecture by turning inference into a database operator, the semantic layer into agent infrastructure, and agents into a new database workload|Josh Rosen's "semantic layer as agent infrastructure"]] has to be, and what Palantir's one-ontology-one-security-model story depends on. The precise split matters: the builder's shared initial ontology delivers **+12.3** of the +20.0 on DDR-Bench and is model-agnostic; the **+7.7** from evolution is the part that does not travel. And the non-portable part is the larger share of the value per edit, because **Tool-level edits account for 57 percent of the accepted gain** while Content contributes 34 percent and Schema 9 percent — and tool descriptions and manifest wording are the most model-specific thing in the system.

- **The inference-time cost result is genuinely good and the construction cost is simply absent.** The manifest raises input tokens per turn from 3.2K to 4.6K, but trajectories shorten from 14.6 turns to 8.4, so total tokens per task *fall* from 52.6K to 42.0K, roughly 20 percent under the no-ontology baseline, while Trajectory-Wise rises 69.5 → 89.5. Cheaper and better at serving time, which is the opposite of the usual context-engineering tradeoff and the direct rebuttal to the context-window objection that sank full-injection semantic layers. What is missing is the other ledger: building requires probe queries across every source, and each evolution round runs the full validation set twice, for parent and candidate, including for every rejected candidate. With five accepted rounds per backbone and an unreported rejection rate, that is many full benchmark passes, and the paper reports none of it. [[Databricks traces every MCP call and finds seven tool bugs burning 1.2 million dollars a year because agents retry silently instead of failing loudly|Databricks' MCP waste audit]] is the reminder that the invisible half of the bill is usually where the money is.

- **The gains concentrate on the one benchmark built for this problem and nearly vanish on the other two, which is worth stating plainly.** DDR-Bench's 10-K scenario yields +17.8 average Trajectory-Wise; BIRD yields +7.4 Execution Accuracy; InsightBench yields +1.9 overall, and three of six backbones move by under a point. The authors explain InsightBench as saturating because Insight is graded against short reference findings. The more deflationary reading is that only DDR-Bench is genuinely multi-source, and even there only one scenario is evaluated, so "three well-adopted benchmarks with heterogeneous modalities" resolves to one document-plus-table research benchmark carrying the headline, one CSV analytics benchmark that barely responds, and one single-database text-to-SQL benchmark. The agent-data gap the paper names is a gap across sources; the evidence for closing it rests mostly on one scenario of a 2026 benchmark. Compare [[DAB benchmark exposes frontier data agents at 38 percent pass at 1 with 85 percent of failures in planning or implementation|DAB's finding that 85 percent of data-agent failures are planning and implementation, not data selection]]: if that holds, an ontology layer is attacking the 15 percent, and DDR-Bench's +26.7 on GPT-5.5 needs explaining in those terms.

## The Agent-Data Gap

The paper's framing device is a mismatch of location. Heterogeneous data — relational databases, semi-structured filings, unstructured documents — "resides outside the agent, while the agent can access it (e.g., column names and file paths) only through generic tools" such as SQL interfaces and file readers. Neither the structure nor the content of those sources is known a priori, so the agent "has to blindly explore the underlying data by repeatedly issuing probing queries, guessing where the requested concepts are located, and inspecting potentially irrelevant content."

That is the same diagnosis as [[the hard problem in text-to-SQL is discovery not generation and hybrid search over existing metadata solves it|Astronomer Kepler's "discovery not generation"]], arrived at independently, and the same one behind [[Anthropic's self-service analytics stack achieves 95% accuracy by treating the bottleneck as context and entity mapping not SQL generation|Anthropic's entity-mapping bottleneck]]. Where the paper diverges is in naming the cost of the standard fixes:

- **Raw querying** — let the agent inspect schemas and issue exploratory queries. Works on small simple sources, "scales poorly to wide and heterogeneous data, where agents can easily become trapped in repetitive and inefficient exploration."
- **Semantic layers** — supply metadata, entities, metrics, domain semantics in the prompt. Two failures: the whole layer does not fit in context for large sources, and existing layers are "typically predefined and maintained manually, making them costly to construct and difficult to adapt to new data sources, tasks, and agents."

There is a third observation in the related-work section that is the real motivation and deserves more prominence than it gets: "Grounding discovered in one trajectory is typically discarded rather than retained for later tasks. EvoOntology instead amortizes schema discovery across the workload." That is a memory argument, not an ontology argument, and it is the same amortization logic as [[memento-skills turns executable skill folders into evolving non-parametric memory that lets frozen LLMs learn continuously from deployment|memento-skills turning executable skill folders into non-parametric memory]]. The paper's own Table 2 concedes the overlap by benchmarking against `ReAct + Memory`, which stores past trajectories as retrievable episodes: memory lifts Trajectory-Wise 69.5 → 75.8, still 13.7 below EvoOntology, "because episodic memory only replays what has been done and does not expose typed, composable structure."

## Architecture

The ontology state at evolution round `t` is `L_t = (S_t, Gamma_t, R_t)`. The separation exists so that the deployed agent can retrieve only the semantics relevant to the current step, and so the evolution agent can update a bounded part of the state.

**Content Layer `S_t`** — a typed semantic graph with four node families and two edge families.

| Element | Kind | Role |
| --- | --- | --- |
| Terms | node | Domain concepts |
| Mappings | node | Ground Terms to fields and linking paths |
| Constraints | node | Govern valid use of a Term |
| Evidence | node | Supports a Term's semantic claims (retained probe records) |
| Semantic Relations | edge | Connect Terms via association, hierarchy, composition, equivalence, or derivation |
| Structural References | edge | Link Terms to Mappings; attach Constraints and Evidence to the objects they govern or support |

This is the same schema-over-instances division as [[Everything Is Connected - knowledge graphs encode entities as directed-labeled triples that support multi-hop traversal and ontology-driven inference|directed-labeled triples governed by an ontology]], with one addition that matters: Evidence is a first-class node type holding an executed probe result, so every committed claim carries a receipt. That is the design decision the ablation later validates, and the reason the authors say they "require every committed entry to be anchored in a probe query and not a natural-language description alone."

**Schema Layer `Gamma_t`** — defines the fields of the four node families, the admissible Semantic Relation types, and the permitted reference patterns. Because it sets the representational boundary rather than the content, "schema updates can therefore extend the ontology's representational capacity without changing its instantiated content."

**Tool Layer `R_t`** — two MCP tools plus a session manifest.

| Interface | Signature | Behavior |
| --- | --- | --- |
| browse | `f_browse(q, k, n)` | Retrieves the top-`n` semantic matches for query `q` and kind `k` |
| resolve | `f_resolve(I, c)` | Returns the requested records and their linked objects |
| manifest | — | Compact source and usage information at session initialization |

The released code names these `browse_semantics` and `resolve_semantics`. The critical sentence is about the manifest: "It is the only ontology content placed in the prompt, while detailed records are retrieved on demand." Two tools sits well inside the range [[MCP Best Practices|MCP best practices]] recommends, and the manifest-then-fetch pattern is the same progressive disclosure as [[code execution with MCP cuts tool token overhead 98 percent by presenting servers as filesystem APIs instead of upfront definitions|presenting MCP servers as filesystem APIs instead of upfront definitions]] and the same collapse to a small query surface as [[Agno Context Providers collapse the multi-source tool surface to 2N tools by hiding each source behind a query and update sub-agent|Agno's two-tools-per-source Context Providers]].

## Builder Agent

The builder constructs the initial ontology "from the training workload and raw sources without observing gold answers." Two stages:

**Workload-guided probing.** Given a training workload `W` and raw sources `D`, the builder proposes candidates `C = propose(W)` from recurrent entities, metrics, operations, and analytical conditions in the workload queries. For each candidate `c`, it issues `probe(c, D)` to identify candidate fields and linking paths and to inspect their types, values, and semantic consistency.

**Evidence-grounded commitment.** Only candidates supported by their probe results are committed:

```
C+ = { c in C | verify(probe(c, D)) = 1 }
S_0 = construct(C+, D; Gamma_0)
```

`verify(.)` checks "the declared type, filter, and value-distribution requirements." Verified candidates are instantiated under `Gamma_0` with their supporting records retained as Evidence. With the default Tool Layer `R_0`, this forms the initial state `L_0 = (S_0, Gamma_0, R_0)`.

Note what the builder reads and what it does not. It reads the *queries* in the training workload, not their answers. That is what keeps the protocol clean, and it is also a real dependency: the ontology is shaped by the workload it was built for, so this is workload adaptation rather than general data modeling. The authors say so directly — "we treat ontology construction and evolution as training-time workload adaptation."

## Self-Evolution Loop

Data grounding alone does not make an ontology suit a particular agent, so historical trajectories are used as behavioral evidence: "Successful executions reveal effective semantic structures and access patterns, while unsuccessful ones expose missing, misleading, or poorly exposed components." Four steps.

**1. Trajectory attribution.** The evolution agent extracts recurrent signatures `Sigma_t = analyze(T_t, L_t)` from historical trajectories and the current state. Each signature summarizes an interaction pattern, the ontology objects involved, and its observed outcomes. The agent then assigns the signature to exactly one level through `alpha: Sigma_t -> {C, T, S}` — Content, Tool, or Schema — and states the expected behavioral effect of an update. An attribution is therefore a hypothesis of the form "this recurring behavior is caused by a deficiency at this level of the ontology," grounded in clustered traces rather than a single failure.

**2. Localized intervention (the typed edit).** For an attributed signature `sigma`, the agent proposes `L'_t = patch(L_t, sigma, alpha(sigma))`. The typing constraint is the important part: **each candidate modifies one level only**.

| Level | Edit operations |
| --- | --- |
| Content | Add, remove, or revise instantiated semantic objects in `S_t` |
| Tool | Modify existing tools, or add and remove tools in `R_t`, according to observed agent behavior |
| Schema | Revise the object model in `Gamma_t` |

Multiple dependent Content objects may be updated together "when they implement the same hypothesis," so the unit is one hypothesis at one level, not literally one object.

**3. Backbone-conditional paired validation.** For backbone `m`, let `phi(L, V; m)` be the score of ontology state `L` on validation set `V`. Candidate and parent are evaluated on the same `V` with identical decoding and interaction budgets. The candidate is retained only when its improvement reaches margin `tau`:

```
L_{t+1} = L'_t   if phi(L'_t, V; m) - phi(L_t, V; m) >= tau
          L_t    otherwise
```

Unpacking each word of the name:

- **Paired** — the same validation set, decoding configuration, and interaction budget are used for both arms. The pair is *parent ontology versus candidate ontology*, differing at exactly one level, not tasks-with-versus-without. The single-level difference is what makes the comparison attributable: it "isolates the attributed hypothesis while limiting regressions on the validation set."
- **Conditional on the backbone** — `phi` is indexed by `m`. "All backbones evolve independently from the same initial state `L_0`, allowing accepted updates to reflect backbone-specific interaction patterns." This is the design choice that makes the evolved ontology a per-model artifact.
- **The acceptance statistic** — a raw score difference on `V`, thresholded at `tau`. There is no significance test, no repeated-run variance estimate, and no stated value for `tau`. The margin is the entire acceptance policy and the paper leaves it as a symbol.

Rejected candidates are not deployed, and "their signatures, interventions, and evaluation outcomes are logged to avoid repeated ineffective updates," so the loop has memory of its own failures.

**Is the gate evaluated on the test tasks? No.** The protocol is a reciprocal two-fold split. Each benchmark is divided into disjoint folds A and B. In the A→B run, 70 percent of A is used for ontology construction, trajectory analysis, and candidate generation, and the remaining 30 percent of A is the paired validation set; the selected ontology is then frozen before testing on B. The folds are swapped and the two scores averaged. The paper is explicit: "The held-out fold is accessed only for final evaluation after the ontology has been frozen, and its answers and evaluator feedback are never used for ontology construction, evolution, or candidate selection." So there is no test-set leakage. The residual concern is statistical rather than procedural: candidate selection runs on 30 percent of one fold of a small benchmark, with an unstated `tau` and an unstated number of proposals per acceptance, which is the classic setup for selecting on validation noise.

**Case study.** A BIRD-style card-legality task shows a Content-level edit end to end. The initial ontology has Terms `Card` (grounded to `Cards.uuid`) and `Legality` (grounded to `legalities.uuid`, `legalities.format`, `legalities.status`) with an association between them, and table schemas retained as Evidence. The agent can find the table but the ontology "does not explain how the values of `legalities.status` should be interpreted," nor that legality is defined relative to a game format. The evolution agent attributes this to the Content Layer, reasoning that browse and resolve can already retrieve the objects and the Schema Layer can already represent the knowledge — "the missing component is a reusable semantic description of the status field and its applicability condition." The patch adds a Term `Legality Status Code` grounded to `legalities.status`, an Evidence object recording the observed distribution of status values, and a Constraint stating that identifying banned cards requires both `legalities.status = 'Banned'` and `legalities.format = target_format`. Existing objects are untouched; no Tool or Schema change. This is the concrete shape of a typed edit, and it is notably small.

## Results

Three benchmarks, chosen for heterogeneous modalities and answer formats, each scored under its own official protocol.

| Benchmark | Task | Metrics reported |
| --- | --- | --- |
| DDR-Bench (Deep Data Research), 10-K scenario | Open-ended data research across heterogeneous sources | Message-Wise (per-turn interpretation), Trajectory-Wise (full-history synthesis) |
| InsightBench | Business analytics — BI flags, each with a CSV dataset and a ground-truth insight | Insight, Summary |
| BIRD, Oracle Knowledge setting | Text-to-SQL over real-world databases | Execution Accuracy (EX) primary, Valid Efficiency Score (VES) secondary |

Six backbones: **GPT-5.5, GPT-5.6-sol, Claude-Sonnet-5, Claude-Opus-4.8, DeepSeek-V4-Flash, Qwen3.5-Flash**. All conditions share the same ReAct scaffold, raw-data tools, decoding configuration, and interaction budget. Every analysis section uses a four-backbone subset (GPT-5.5, GPT-5.6-sol, Claude-Sonnet-5, Claude-Opus-4.8). The abstract and the contributions list say "four LLM backbones" while the experiments and conclusion say six; the tables report six.

Baselines: **Baseline** is ReAct with no ontology layer, so the agent rediscovers schema and vocabulary every task. **Baseline + SL** prepends the builder agent's semantic layer into context as a static prompt fragment. **ReAct + Memory** stores past trajectories as retrievable episodes and injects the top-k.

### Table 1 — DDR-Bench 10-K

Parentheses are gains over the corresponding Baseline row.

| Method | Backbone | Msg-Wise (%) | Traj-Wise (%) | Overall (%) |
| --- | --- | --- | --- | --- |
| Reported ReAct | Claude-Sonnet-4.5 | 77.6 | 60.6 | 69.1 |
| Reported ReAct | DeepSeek-V3.2 | 60.1 | 38.2 | 49.2 |
| Reported ReAct | GLM-4.6 | 60.3 | 36.0 | 48.2 |
| Reported ReAct | GPT-5.2 | 44.9 | 41.1 | 43.0 |
| Reported ReAct | GPT-5-mini | 46.8 | 37.1 | 42.0 |
| Reported ReAct | Kimi-K2 | 51.1 | 30.8 | 40.1 |
| Reported ReAct | GPT-5.1 | 37.1 | 44.3 | 40.7 |
| Reported ReAct | Gemini-3-Flash | 44.8 | 21.2 | 33.0 |
| Baseline | GPT-5.5 | 60.6 | 64.2 | 62.4 |
| Baseline | GPT-5.6-sol | 64.0 | 68.5 | 66.3 |
| Baseline | Claude-Sonnet-5 | 74.3 | 72.5 | 73.4 |
| Baseline | Claude-Opus-4.8 | 74.0 | 73.0 | 73.5 |
| Baseline | DeepSeek-V4-Flash | 26.2 | 30.3 | 28.2 |
| Baseline | Qwen3.5-Flash | 16.4 | 14.3 | 15.4 |
| Baseline + SL | GPT-5.5 | 58.4 (−2.2) | 63.9 (−0.3) | 61.2 (−1.2) |
| Baseline + SL | GPT-5.6-sol | 62.5 (−1.5) | 65.5 (−3.0) | 64.0 (−2.3) |
| Baseline + SL | Claude-Sonnet-5 | 65.6 (−8.7) | 57.5 (−15.0) | 61.5 (−11.9) |
| Baseline + SL | Claude-Opus-4.8 | 65.9 (−8.1) | 71.4 (−1.6) | 68.6 (−4.9) |
| Baseline + SL | DeepSeek-V4-Flash | 28.8 (+2.6) | 31.7 (+1.4) | 30.2 (+2.0) |
| Baseline + SL | Qwen3.5-Flash | 14.8 (−1.6) | 13.3 (−1.0) | 14.1 (−1.3) |
| **EvoOntology** | GPT-5.5 | 74.0 (+13.4) | **90.9 (+26.7)** | 82.5 (+20.1) |
| **EvoOntology** | GPT-5.6-sol | 78.2 (+14.2) | **93.5 (+25.0)** | 85.9 (+19.6) |
| **EvoOntology** | Claude-Sonnet-5 | 78.4 (+4.1) | 81.3 (+8.8) | 79.9 (+6.5) |
| **EvoOntology** | Claude-Opus-4.8 | 78.0 (+4.0) | 92.3 (+19.3) | 85.2 (+11.7) |
| **EvoOntology** | DeepSeek-V4-Flash | 37.5 (+11.4) | 52.3 (+22.0) | 44.9 (+16.7) |
| **EvoOntology** | Qwen3.5-Flash | 21.1 (+4.7) | 19.1 (+4.8) | 20.1 (+4.8) |

Average Trajectory-Wise gain over Baseline: **+17.8**, ranging from +4.8 on Qwen3.5-Flash to +26.7 on GPT-5.5. Note that the two weakest backbones end at 52.3 and 19.1, so the method lifts weak models substantially in relative terms without making them usable.

### Table 2 — versus episodic memory (DDR-Bench, four-backbone average)

| Method | Traj-Wise (%) | Delta |
| --- | --- | --- |
| Baseline (ReAct) | 69.5 | — |
| ReAct + Memory | 75.8 | +6.3 |
| **EvoOntology** | **89.5** | **+20.0** |

### Table 3 — InsightBench

| Method | Backbone | Insight (%) | Summary (%) | Overall (%) |
| --- | --- | --- | --- | --- |
| Pandas Agent | GPT-4o | 54.0 | 40.0 | 47.0 |
| AgentPoirot | GPT-3.5-turbo | 50.0 | 31.0 | 40.5 |
| AgentPoirot | GPT-4-turbo | 56.0 | 35.0 | 45.5 |
| AgentPoirot | Llama-3-70B | 52.0 | 33.0 | 42.5 |
| AgentPoirot | GPT-4o | 60.0 | 44.0 | 52.0 |
| Baseline | GPT-5.5 | 52.9 | 47.6 | 50.3 |
| Baseline | GPT-5.6-sol | 51.6 | 49.4 | 50.5 |
| Baseline | Claude-Sonnet-5 | 53.3 | 51.3 | 52.3 |
| Baseline | Claude-Opus-4.8 | 54.9 | 49.9 | 52.4 |
| Baseline | DeepSeek-V4-Flash | 45.0 | 34.6 | 39.8 |
| Baseline | Qwen3.5-Flash | 37.5 | 26.2 | 31.9 |
| Baseline + SL | GPT-5.5 | 53.4 (+0.5) | 48.6 (+1.0) | 51.0 (+0.8) |
| Baseline + SL | GPT-5.6-sol | 51.3 (−0.3) | 50.8 (+1.4) | 51.1 (+0.6) |
| Baseline + SL | Claude-Sonnet-5 | 53.5 (+0.2) | 48.0 (−3.3) | 50.8 (−1.6) |
| Baseline + SL | Claude-Opus-4.8 | 55.8 (+0.9) | 50.5 (+0.6) | 53.2 (+0.8) |
| Baseline + SL | DeepSeek-V4-Flash | 47.0 (+2.0) | 36.5 (+1.9) | 41.8 (+2.0) |
| Baseline + SL | Qwen3.5-Flash | 39.0 (+1.5) | 25.2 (−1.0) | 32.1 (+0.2) |
| **EvoOntology** | GPT-5.5 | 53.4 (+0.5) | 48.6 (+1.0) | 51.0 (+0.8) |
| **EvoOntology** | GPT-5.6-sol | 53.2 (+1.6) | 50.9 (+1.5) | 52.1 (+1.6) |
| **EvoOntology** | Claude-Sonnet-5 | 54.4 (+1.1) | 51.5 (+0.2) | 53.0 (+0.7) |
| **EvoOntology** | Claude-Opus-4.8 | 55.8 (+0.9) | 50.5 (+0.6) | 53.2 (+0.8) |
| **EvoOntology** | DeepSeek-V4-Flash | 49.2 (+4.2) | 42.6 (+8.0) | 45.9 (+6.1) |
| **EvoOntology** | Qwen3.5-Flash | 39.3 (+1.8) | 27.6 (+1.4) | 33.4 (+1.6) |

Mean Overall gain: **+1.9**, largest on DeepSeek-V4-Flash (+6.1). The authors attribute the small effect to Insight being "graded on short reference-style findings" that saturate "once the answer aligns with the reference." Two rows in the EvoOntology block (GPT-5.5 and Claude-Opus-4.8) are numerically identical to the corresponding Baseline + SL rows; the reported means are consistent with the values as printed, so this reads as a genuine coincidence or an uncorrected table error in the preprint rather than a transcription artifact.

### Table 4 — BIRD under Oracle Knowledge

VES on a 0-100 scale.

| Method | Backbone | EX (%) | VES (%) |
| --- | --- | --- | --- |
| GPT-4 | GPT-4 | 46.4 | — |
| DIN-SQL | GPT-4 | 50.7 | 58.8 |
| DAIL-SQL | GPT-4 | 54.8 | 56.1 |
| TA-SQL | GPT-4 | 56.2 | — |
| MAC-SQL | GPT-4 | 57.6 | 58.8 |
| MCS-SQL | GPT-4 | 63.4 | — |
| CHESS | GPT-4o | 65.0 | 62.8 |
| Baseline | GPT-5.5 | 61.5 | 63.4 |
| Baseline | GPT-5.6-sol | 63.5 | 65.6 |
| Baseline | Claude-Sonnet-5 | 61.9 | 63.7 |
| Baseline | Claude-Opus-4.8 | 67.5 | 69.6 |
| Baseline | DeepSeek-V4-Flash | 33.1 | 36.4 |
| Baseline | Qwen3.5-Flash | 46.5 | 47.9 |
| Baseline + SL | GPT-5.5 | 55.9 (−5.6) | 67.7 (+4.3) |
| Baseline + SL | GPT-5.6-sol | 63.0 (−0.5) | 68.9 (+3.3) |
| Baseline + SL | Claude-Sonnet-5 | 60.8 (−1.1) | 65.8 (+2.1) |
| Baseline + SL | Claude-Opus-4.8 | 66.2 (−1.3) | 75.0 (+5.4) |
| Baseline + SL | DeepSeek-V4-Flash | 36.3 (+3.2) | 37.2 (+0.7) |
| Baseline + SL | Qwen3.5-Flash | 48.0 (+1.5) | 51.9 (+4.0) |
| **EvoOntology** | GPT-5.5 | 68.9 (+7.4) | 71.1 (+7.7) |
| **EvoOntology** | GPT-5.6-sol | 70.7 (+7.2) | 73.0 (+7.4) |
| **EvoOntology** | Claude-Sonnet-5 | 71.8 (+9.9) | 74.1 (+10.4) |
| **EvoOntology** | Claude-Opus-4.8 | **78.3 (+10.8)** | **80.5 (+10.9)** |
| **EvoOntology** | DeepSeek-V4-Flash | 39.4 (+6.4) | 44.1 (+7.6) |
| **EvoOntology** | Qwen3.5-Flash | 49.1 (+2.5) | 55.2 (+7.3) |

Average gains: **+7.4 EX** and **+8.6 VES**. The `Baseline + SL` pattern here is the most diagnostic result in the paper: static injection *lowers* EX on every strong backbone while *raising* VES on all six, which the authors read as "a static semantic layer improves SQL well-formedness but distracts from producing correct queries."

### Stage decomposition — builder versus evolution

Figure 3 separates the builder-constructed ontology from the self-evolution gain. Means across the four-backbone analysis subset:

| Benchmark | Primary metric | Baseline | Initial | Evolved | Baseline→Initial | Initial→Evolved |
| --- | --- | --- | --- | --- | --- | --- |
| DDR-Bench (10-K) | Trajectory-Wise | 69.5 | 81.8 | 89.5 | +12.3 | +7.7 |
| InsightBench | Insight | 53.2 | 54.0 | 54.2 | +0.8 | +0.2 |
| BIRD | Execution Accuracy | 63.6 | 68.7 | 72.4 | +5.1 | +3.7 |

The builder does most of the work everywhere; evolution adds roughly a third to a half as much again on the two benchmarks that move at all.

### Ablations

**Evolution loop steps** (Table 5, DDR-Bench, four-backbone average). Each step is disabled in turn: w/o Diagnose skips failure-trace clustering and proposes from a random sample of recent traces; w/o Attribution drops the level tag and lets the agent commit at any level without stating a hypothesis; w/o Patch replaces the typed hypothesis-conditioned edit with a free-form ontology rewrite; w/o Gate accepts every candidate.

| Variant | Traj-Wise (%) | Delta |
| --- | --- | --- |
| Full loop | 89.5 | — |
| w/o Gate | 78.3 | **−11.2** |
| w/o Attribution | 83.2 | −6.3 |
| w/o Diagnose | 84.7 | −4.8 |
| w/o Patch (free-form) | 87.8 | −1.7 |

**Editable levels** (Table 6, DDR-Bench, four-backbone average). Restricting the loop to one level at a time:

| Variant | Traj-Wise (%) | Delta vs Baseline |
| --- | --- | --- |
| Baseline | 69.5 | — |
| Content-only evolution | 78.2 | +8.7 |
| Tool-only evolution | 82.7 | **+13.2** |
| Schema-only evolution | 73.1 | +3.6 |
| Full three-level evolution | **89.5** | **+20.0** |

Tool-only is the largest single-level gain, and no single level reaches the full +20.0, so the levels are complementary rather than substitutable.

**Content-layer object families** (Table 7, DDR-Bench, four-backbone average). Each removable family is masked from the final evolved ontology. Terms cannot be masked in isolation because every other family references them.

| Variant | Traj-Wise (%) | Delta |
| --- | --- | --- |
| Full EvoOntology | 89.5 | — |
| w/o Mappings | 76.1 | **−13.4** |
| w/o Evidence | 80.8 | −8.7 |
| w/o Constraints | 86.0 | −3.5 |
| w/o Relations | 87.4 | −2.1 |

**Cost** (Table 8, DDR-Bench, four-backbone average):

| Metric | Baseline | Initial | Evolved |
| --- | --- | --- | --- |
| Input tokens / turn (K) | 3.2 | 4.1 | 4.6 |
| Output tokens / turn (K) | 0.4 | 0.4 | 0.4 |
| Turns / task | 14.6 | 11.2 | 8.4 |
| Total tokens / task (K) | 52.6 | 50.4 | **42.0** |
| Traj-Wise (%) | 69.5 | 81.8 | **89.5** |

### Convergence, growth, and attribution distribution

**Iterative evolution** (Figure 4). All four backbones improve monotonically from Initial through the accepted rounds, GPT-5.6-sol reaching 93.5 Trajectory-Wise after five accepted rounds and Claude-Opus-4.8 reaching 92.3 after four. The curves flatten by the last two rounds, "consistent with the failure signatures becoming rarer once the ontology covers the recurrent cross-filing concepts." The authors read this as evidence the gain "is the outcome of a converging refinement and not a single fortunate patch."

**Content growth** (Figure 6, GPT-5.6-sol). Terms rise from 61 in the Initial ontology to 80 after five accepted rounds, with per-round growth of every tracked element falling below 5 percent after round three. Content size flattens together with performance, so the loop does not expand the ontology without bound.

**Attribution distribution** (Figure 7, aggregated over the four-backbone subset). Grouping accepted rounds by attribution tag and aggregating each group's paired-evaluation improvement:

| Level | Share of cumulative gain | Accepted rounds |
| --- | --- | --- |
| Tool | **57%** | 6 |
| Content | 34% | 11 |
| Schema | 9% | 3 |

Content edits are the most frequent and Tool edits carry the largest share of the gain. Tool edits "mainly improve how existing ontology content is exposed through the manifest and MCP tools" — i.e. nearly three-fifths of the accepted improvement comes from rewording the serving surface rather than adding semantics.

**Backbone divergence** (Figure 5). Pairwise Jaccard overlap of accepted Term-identifier sets:

| | GPT-5.5 | GPT-5.6-sol | Claude-Sonnet-5 | Claude-Opus-4.8 |
| --- | --- | --- | --- | --- |
| GPT-5.5 | 1.00 | 0.61 | 0.58 | 0.56 |
| GPT-5.6-sol | 0.61 | 1.00 | 0.60 | 0.62 |
| Claude-Sonnet-5 | 0.58 | 0.60 | 1.00 | 0.55 |
| Claude-Opus-4.8 | 0.56 | 0.62 | 0.55 | 1.00 |

Cross-backbone transfer, each row a store fitted on one backbone and served to every backbone (columns), Trajectory-Wise on DDR-Bench:

| Store fitted on ↓ / served to → | GPT-5.5 | GPT-5.6-sol | Claude-Sonnet-5 | Claude-Opus-4.8 |
| --- | --- | --- | --- | --- |
| GPT-5.5 | **90.9** | 82.4 | 71.8 | 78.9 |
| GPT-5.6-sol | 80.6 | **93.5** | 70.2 | 77.5 |
| Claude-Sonnet-5 | 73.1 | 76.8 | **81.3** | 82.1 |
| Claude-Opus-4.8 | 75.4 | 78.9 | 75.6 | **92.3** |

The diagonal is the highest entry in every column, every off-diagonal drops at least 6.6 points relative to the same-backbone store, and the average column drop ranges from −6.6 (Sonnet-5) to −10.9 (GPT-5.5). Qualitatively, "Claude-Opus-4.8 retains more detailed manifest variants than Claude-Sonnet-5, while GPT-5.5 introduces short SQL fragment libraries under Evidence that do not appear in the Claude-Opus-4.8 ontology." The authors concede that identifier overlap alone cannot establish semantic equivalence.

## Where It Sits in the Vault's Semantic-vs-Context-Layer Dispute

This folder's central argument has been about *what goes in* the intermediate layer and *who maintains it*. EvoOntology is the first research entry here that builds the layer agent-side, autonomously, and keeps changing it, and it answers a question none of the practitioner sources had isolated: how the layer should be *delivered*.

**Against [[MotherDuck's Simon Spati splits semantic layer from context layer by what compiles to SQL, and argues sophistication is a cost not a default|Späti's primer]].** His operational test — a semantic layer compiles to SQL, a context layer holds everything else, an ontology supplies object and link types — cleanly classifies EvoOntology as an ontology: Terms, typed Semantic Relations, and a Schema Layer that declares which relations are legal. On his "sophistication is a cost, not a default" argument, the paper both rebuts and confirms him. It rebuts the strong version, because a typed layer plainly helps here, +20.0 on DDR-Bench over raw exploration. It confirms the reasoning, because the object families that pay are the flat ones: Mappings −13.4 and Evidence −8.7, versus Relations −2.1. Späti's deciding question was whether the bottleneck is relating entities or picking the right document. EvoOntology's answer is a third thing he does not offer: the bottleneck is knowing which physical column implements which concept and having executed a query against it. His MotherDuck Guides result — a flat curated topic tree beating a graph — survives this paper intact. The other place he is vindicated is maintenance: "the hard part in data is never building semantics or the context once, it's how and who keeps it correct and maintained." EvoOntology's entire contribution past the builder is a maintenance mechanism, and it is the part the authors had to gate most carefully.

**Against [[context management replaces the semantic layer for data agents because it adapts from corrections|Jamie Quint's correction-driven context management]].** This is the automated version of his argument, and it is the closest match in the folder. Quint's claim was that context computed on demand and refined by corrections beats an authored semantic layer, because it adapts. EvoOntology replaces the human correction with a trajectory signature and the human's judgment with a paired-validation gate. The finding that should interest anyone running Quint's playbook is the ablation: removing the gate costs −11.2, more than any other component. If corrections are applied without a held-out check that the correction actually helped, the loop admits regressions that later rounds cannot undo. Quint's quirks file has no such gate.

**Against [[data agents are useless without a context layer that captures business definitions and tribal knowledge|a16z's living context layer]] and [[OpenAI internal data agent succeeds through six layers of context not model capability alone|OpenAI's six context layers]].** Both argue for content the agent needs and neither addresses interface. `Baseline + SL` is the warning: the builder's own ontology, injected as a static prompt fragment, was worse than nothing on four of six backbones. Having the right context and shipping it the wrong way is a measurable regression, not a neutral choice.

**Against [[the hard problem in text-to-SQL is discovery not generation and hybrid search over existing metadata solves it|Astronomer Kepler's discovery-not-generation thesis]].** Same diagnosis, different solution shape. Kepler does hybrid retrieval (reciprocal rank fusion) over metadata that already exists in the warehouse; EvoOntology synthesizes the metadata first by probing, then exposes a semantic browse over it. The `f_browse(q, k, n)` signature is a ranked retrieval interface, so the two are compatible: Kepler's answer to *how to search* plus EvoOntology's answer to *what to search over*.

**Against [[Anthropic's self-service analytics stack achieves 95% accuracy by treating the bottleneck as context and entity mapping not SQL generation|Anthropic's entity-mapping stack]].** Anthropic found ablating raw SQL retrieval moved accuracy under a point while pairwise skills drove it from 21 percent to 95 percent — the bottleneck is mapping business language to entities. EvoOntology's Mappings ablation is the same result from the other direction: remove the layer that grounds a Term to columns and join paths and you lose 13.4 points, more than any other single element. Two independent measurements pointing at the same object.

**Against [[Snowflake, Databricks and ClickHouse preview AI architecture by turning inference into a database operator, the semantic layer into agent infrastructure, and agents into a new database workload|Josh Rosen's "semantic layer as agent infrastructure"]] and [[Palantir Ontology gives enterprise agents a decision-centric substrate by surfacing data logic and action as tools governed by one security model|Palantir's ontology-as-tools]].** EvoOntology is the open-research analogue of the Palantir framing — an ontology surfaced to agents as tools — and it is the first measured version. But it also supplies the counterexample to the infrastructure story both notes depend on. Infrastructure is shared; this artifact is not. Cross-backbone transfer costs at least 6.6 points, accepted Term sets overlap at most 0.62, and the authors' own conclusion is that "backbone-specific evolution is beneficial." The portable part is the builder's initial ontology, worth +12.3 of the +20.0; the per-agent part is the evolution delta, worth +7.7, and it is concentrated in Tool-level manifest wording, the most model-specific surface there is. Palantir's one-ontology-one-security-model story cannot be built on a store that has to be refit per backbone, and Rosen's "semantic layer as agent infrastructure" has to mean the authored, shared half.

**Against [[Berkeley's EPIC Data Lab argues near-free intelligence makes agents the dominant data-systems workload, needing data systems for, of, and by agents|the EPIC Data Lab agenda]].** This lands squarely on the "OF agents" axis — the call for structured corrective memory beyond markdown files and knowledge graphs. EvoOntology is a concrete instance: typed, versioned, gated, diffable state that an agent maintains about its environment. It also partially serves "FOR agents," since turns per task drop 14.6 → 8.4, which is the agentic-speculation reduction the agenda asks for.

**Against [[DAB benchmark exposes frontier data agents at 38 percent pass at 1 with 85 percent of failures in planning or implementation|DAB's failure taxonomy]] and [[Hamel's evals-for-data-agents note reads DAB for builders - agents fail on plans not data selection and stick to plans even when data contradicts them|Hamel's builder-side reading of it]].** This is the sharpest open tension. DAB attributes 40 percent of failures to planning and 45 percent to implementation, leaving 15 percent for data selection, and DAB's own semantic-layer condition (PromptQL) added only 7 points over ReAct on Claude-Opus-4.6. If that taxonomy transfers, an ontology layer targets the small slice, and +26.7 on GPT-5.5 needs another explanation. Two candidates: the turn count falling from 14.6 to 8.4 means the ontology is mostly buying *plan stability* by removing the exploration phase where plans drift, which would make this a planning intervention wearing a data-selection costume; or DDR-Bench's 10-K scenario is simply more discovery-bound than DAB's tasks. The paper does not run a failure taxonomy, so this stays open. Worth also holding against [[Google's data-agent study finds semantic metadata (schema.org, FAIR) still beats open-web search for actionable data retrieval|Google's finding that structured semantic metadata beats open-web search for actionable retrieval]], which is the same structured-beats-unstructured result at web scale.

**Against the self-improving-artifact literature elsewhere in the vault.** The loop's shape is now a recognizable pattern. [[Self-Harness lets a fixed LLM rewrite its own agent harness from clustered failure traces, lifting Terminal-Bench held-out pass rates up to 21 points|Self-Harness]] is the same architecture applied to the harness instead of the ontology: cluster verifier-grounded failures, propose bounded edits, promote past a non-regressive held-out gate. [[memento-skills turns executable skill folders into evolving non-parametric memory that lets frozen LLMs learn continuously from deployment|memento-skills]] and [[MemSkill - Learning and Evolving Memory Skills for Self-Evolving Agents|MemSkill]] are the memory-side versions, with MemSkill making the edit operators themselves learnable — which is the obvious next move here, since EvoOntology's three levels and its edit taxonomy are hand-designed. [[memory is a compiler not a database - Ashwin Gopinath argues admission and action utility functions are the moat, and silence is the evidence they work|Gopinath's "memory is a compiler"]] supplies the theory for why the gate dominates the ablation: the admission function is the moat, not the store. And [[Company Brain Part 7 - Claude Made Agent Memory Real but Semantics and Ontology Are Still Missing|Sentra's argument that semantics says what something is and ontology says why it matters from a perspective]] gets an unexpected empirical footnote — EvoOntology's per-backbone divergence means the "perspective" is the model's, not the organization's.

**On serving surface.** Two tools plus a manifest is the whole interface, which respects [[MCP Best Practices|the one-server-one-job and 5-15-tools guidance]], and manifest-then-fetch is the same progressive disclosure as [[code execution with MCP cuts tool token overhead 98 percent by presenting servers as filesystem APIs instead of upfront definitions|code execution with MCP]] and the same shape as [[Agno Context Providers collapse the multi-source tool surface to 2N tools by hiding each source behind a query and update sub-agent|Agno's query-plus-update Context Providers]]. That the Tool Layer accounts for 57 percent of the evolution gain is the strongest evidence in the folder that tool-surface design is an optimizable object and not a one-time authoring decision.

## Related

- Code and plugin: [[EvoOntology]] (resource note)
- Folder hub: [[moc - Data Agent]]
- Adjacent measurement of layer content over layer interface: [[Databricks Genie pushes data agents past coding-agent baselines via specialized knowledge search, parallel thinking, and multi-LLM design]] and [[semantic SQL parsing makes data transformations programmatically validatable which is what data agents need underneath them]]
- The formal vocabulary for the typed-edit surface: [[Everything Is Connected - knowledge graphs encode entities as directed-labeled triples that support multi-hop traversal and ontology-driven inference]]

## Original Content

> [!quote]- Full paper, verbatim (Chong, Zhang, Fan, Du, "EvoOntology: A Self-Evolving Ontology Layer for Data Agents", arXiv 2609.15779, 14 Sep 2026; docling extraction, figures and tables at their original positions)
> ## EvoOntology: A Self-Evolving Ontology Layer for Data Agents
>
> Meiduo Chong 1 , Shaolei Zhang 1 ∗ , Ju Fan 1 , Xiaoyong Du 1
>
> 1 Renmin University of China zhongmeiduo210@ruc.edu.cn, zhangshaolei98@ruc.edu.cn
>
> ## Abstract
>
> Data agents aim to fulfill natural-language instructions over heterogeneous data, including tables, files, and databases. However, data agents face a challenging agent-data gap : heterogeneous data resides outside the agent, while the agent can access it (e.g., column names and file paths) only through generic tools. Existing approaches either let agents directly explore raw data sources or inject manually constructed semantic layers into prompts. However, neither scales well to large heterogeneous data sources nor adapts to different agent behaviors. In this paper, we introduce EvoOntology , a self-evolving ontology layer for data agents. EvoOntology encapsulates the ontology as an MCP server comprising a schema layer, a content layer, and a tool layer, enabling agents to actively query and interact with the ontology at runtime. To this end, we introduce a builder agent for autonomous ontology construction and a self-evolution loop that continuously refines the ontology through attribution-guided typed edits that are accepted only after a backbone-conditional paired evaluation. Experiments on three well-adopted data-agent benchmarks with four LLM backbones demonstrate that EvoOntology consistently outperforms strong baselines and existing semanticlayer approaches, effectively bridging the agent-data gap and enabling more effective interaction with heterogeneous data.
>
> Code -https://github.com/ruc-datalab/EvoOntology
>
> ## Introduction
>
> Data agents over heterogeneous data (Liu et al. 2026; Sahu et al. 2025; Li et al. 2023; Hong et al. 2025; Zhang et al. 2023a) aim to solve natural-language tasks over both structured data (e.g., tables and databases) and unstructured data (e.g., documents and files). To accomplish such tasks, an agent must continuously interact with heterogeneous data sources to gather the information required for producing the final answer. Recent advances in tool use for large language models (LLMs) (Yao et al. 2022; Schick et al. 2023; Qin et al. 2023; Patil et al. 2024) have enabled agents to directly access and manipulate external data sources, providing the foundation for such data interactions.
>
> However, direct interaction with heterogeneous data raises a fundamental question: Can a data agent effectively understand heterogeneous data ? In real-world deployments, data resides outside the agent in the form of relational databases, semi-structured filings, and unstructured documents, while
>
> ∗ Corresponding author: Shaolei Zhang.
>
> *Figure 1: left, a data agent without an ontology layer does blind exploration over tables, CSVs, docs, databases, charts and logs with high semantic uncertainty. Right, the same agent with a self-evolving ontology layer gets grounded data understanding, with the Diagnose - Attribute - Patch - Evaluate - Update loop wrapped around the layer's node types (Terms, Mappings, Evidence, Constraints) and edge types (Semantic Relation, Structural References).*
>
> ![[evoontology-15779-001.png]]
>
> - (a)  Data Agent w/o Ontology Layer
>
> (b) Data Agent with Self-Evolving Ontology Layer
>
> Figure 1: A self-evolving ontology layer helps data agents understand heterogeneous data.
>
> the agent can access the data only through generic tools such as SQL interfaces and file readers. A fundamental challenge is that neither the structure nor the content of these heterogeneous data sources is known a priori. As a result, the agent has to blindly explore the underlying data by repeatedly issuing probing queries, guessing where the requested concepts are located, and inspecting potentially irrelevant content. This mismatch creates a persistent agent-data gap . Bridging this gap requires an intermediate ontology layer that explicitly represents domain concepts, grounds the concepts in the underlying data, and enables agents to interact with data at the semantic level rather than the physical level.
>
> Existing approaches to agent-data interaction can be broadly divided into raw querying and semantic-layer-based interaction . Raw-querying methods (Pourreza and Rafiei 2023; Wang et al. 2025; Talaei et al. 2024) allow agents to directly inspect schemas and issue exploratory queries over the underlying data. While effective for small and relatively simple data sources, they scale poorly to wide and heterogeneous data, where agents can easily become trapped in repetitive and inefficient exploration. Semantic-layer approaches (Hitzler 2021; dbt Labs 2023; Feng et al. 2024; Chang and Fosler-Lussier 2023), in contrast, provide metadata, including schemas, entities, metrics, and other domain semantics, to guide the agent. However, incorporating the entire semantic layer into the agent context is impractical for large data sources due to context-length limitations. Moreover, existing semantic layers are typically predefined and maintained manually, making them costly to construct and difficult to adapt to new data sources, tasks, and agents. These limitations highlight the need for an effective and scalable ontology intermediate layer to bridge the agent-data gap .
>
> In this paper, we advance the intermediate layer between agents and data from static semantic descriptions to an interactive ontology layer that agents can flexibly access through tools. Autonomously constructing such an ontology is inherently challenging because both data sources and agent behaviors are diverse and dynamic, requiring the ontology to adapt to both. To address this challenge, we introduce EvoOntology , a self-evolving ontology layer that continuously adapts to the underlying data and the agents that use it. As illustrated in Figure 1, the ontology consists of three components: a schema layer , which defines object types and reference rules; a content layer , which stores domain knowledge and data mappings; and a tool layer , which exposes executable interfaces for agents to access and manipulate the ontology. These components are encapsulated as a Model Context Protocol (MCP) server, enabling agents to actively query and interact with the ontology rather than passively consuming it as contextual metadata.
>
> Specifically, EvoOntology first employs a builder agent to construct an initial ontology by issuing probe queries over the underlying data sources and grounding each ontology entry in the observed data. EvoOntology then continuously refines the ontology based on agent interaction trajectories. Specifically, it performs attribution analysis to identify deficiencies in the current ontology, proposes targeted refinements to its schema, content, or tools, and accepts each refinement only after it passes a paired evaluation on a held-out validation set. Through this iterative self-evolution process, the ontology continuously adapts to both heterogeneous data and agent behaviors, progressively bridging the agent-data gap .
>
> In summary, our main contributions are as follows:
>
> - Interactive Ontology Layer. We propose the first autonomous interactive ontology layer for data agents and encapsulate it as an MCP server, enabling agents to query and interact with heterogeneous data through tools.
> - Self-Evolving Ontology. We introduce a builder agent for autonomous ontology construction and a self-evolving framework that refines the ontology through attribution analysis, targeted refinement, and paired evaluation.
> - Strong Performance. Extensive experiments on three well-adopted data-agent benchmarks with four LLM backbones demonstrate that EvoOntology consistently and substantially outperforms strong baselines and existing semantic-layer approaches.
>
> ## Related Work
>
> Data Agents on Heterogeneous Data. Deploying LLMs as data agents is an important step toward automated analytics. Existing approaches fall into two families: raw querying and semantic-layer-based interaction . Raw-querying agents equip LLMs with schema-reading, query-executing, and fileinspecting tools, exemplified by text-to-SQL agents that generate queries over relational databases (Li et al. 2023; Yu et al. 2018; Li et al. 2024a), table-QA agents that reason over spreadsheets and web tables (Chen et al. 2020; Pa- supat and Liang 2015), and code-executing analysts that answer business-intelligence questions on CSV files (Sahu et al. 2025; Guo et al. 2024). Pipeline-style variants organize these tool calls through decomposition, retrieval, and verification (Pourreza and Rafiei 2023; Wang et al. 2025; Talaei et al. 2024; Cao et al. 2024; Caferoğlu and Ulusoy 2024; Li et al. 2024b), improving standardized benchmarks while leaving the underlying representation gap untouched. This gap is amplified in heterogeneous settings, where a task may span databases, spreadsheets, and files with different naming conventions, schemas, and granularities. Grounding discovered in one trajectory is typically discarded rather than retained for later tasks. EvoOntology instead amortizes schema discovery across the workload through an ontology layer that preserves such grounding and evolves from agent failures.
>
> Semantic Layers. Ontology and semantic layers have long connected domain concepts with relational data, ranging from OWL ontologies and metric layers (Hitzler 2021; dbt Labs 2023) to LLM-oriented semantic representations and prompt-time metadata (Feng et al. 2024; Chang and Fosler-Lussier 2023). Related work also uses LLMs to induce schema or metric descriptions (Zhang et al. 2023b; Nan et al. 2023) and feedback to refine prompts or retrievers (Zhou et al. 2022; Khattab et al. 2023; Asai et al. 2024). However, existing layers are typically maintained as static prompttime metadata. Whether manually authored or automatically induced, they are usually detached from downstream trajectories showing how agents use them. Full-context injection scales poorly to large data sources, while coarse updates provide little basis for identifying which semantic entry affected a downstream decision. This makes targeted, workload-driven maintenance difficult as tasks and agent behavior evolve. EvoOntology instead exposes the ontology through an MCP server for selective runtime access and refines individual entries through typed, evidence-grounded edits admitted by paired validation.
>
> ## Method
>
> To reduce manual semantic-layer authoring while adapting the layer to agent behavior, we propose EvoOntology , an agent-first builder-and-evolver framework. EvoOntology maintains a versioned ontology state comprising content, schema, and tool layers. A builder agent constructs an evidence-grounded initial state from the training workload and raw sources, while an evolution agent refines it from historical trajectories. The design is agent-first in that the ontology is built around the workload, accessed through the agent's tool interface, and adapted from its execution history.
>
> ## Agent-First Ontology-Layer Architecture
>
> EvoOntology represents the ontology state at evolution round t as L t = ( S t , Γ t , R t ) , comprising a Content Layer S t , a Schema Layer Γ t , and a Tool Layer R t . The three components separate semantic knowledge, its object model, and its runtime exposure. This separation allows the deployed agent to retrieve only the semantics relevant to the current step and allows the evolution agent to update a bounded part of the ontology state.
>
> Figure 2: Overview of EvoOntology. It comprises a typed content graph, its object schema, and a runtime tool interface. The builder constructs an evidence-grounded initial state, while the evolution agent refines it from historical interaction trajectories.
>
> *Figure 2: the full architecture. Left, the data agent's two tool families - Execute SQL and Execute Python for data interaction, browse and resolve for ontology interaction. Middle, the builder agent extracting candidate concepts from workload queries (Cost, Revenue, Profit, Time), grounding them in heterogeneous data, and constructing the Schema, Content and Tool layers around a financial-analysis example. Right, the evolution agent diagnosing a history trajectory, attributing a missing Channel term to Content Level and an FX Convert tool to Tools Level, patching the parent ontology into a candidate, and the accept-or-roll-back gate.*
>
> ![[evoontology-15779-002.png]]
>
> Content Layer. The Content Layer S t is a typed semantic graph with four node families and two edge families. The node families comprise Terms , Mappings , Constraints , and Evidence . Terms represent domain concepts, Mappings ground them to fields and linking paths, Constraints govern their valid use, and Evidence supports their semantic claims. The edge families comprise Semantic Relations and Structural References . Semantic Relations connect Terms through association , hierarchy , composition , equivalence , or derivation . Structural References link Terms to Mappings and attach Constraints and Evidence to the objects they govern or support. Figure 2 illustrates these components through a financial-analysis example.
>
> Schema Layer. The Schema Layer Γ t defines the fields of the four node families, the admissible Semantic Relation types, and the permitted reference patterns. Schema updates can therefore extend the ontology's representational capacity without changing its instantiated content.
>
> Tool Layer. The Tool Layer R t exposes the ontology through two MCP tools and a session manifest. The function f browse ( q, k, n ) retrieves the topn semantic matches for query q and kind k , while f resolve ( I , c ) returns the requested records and their linked objects. The manifest provides compact source and usage information at session initialization. It is the only ontology content placed in the prompt, while detailed records are retrieved on demand.
>
> ## Evidence-Grounded Ontology Initialization
>
> Manually defining domain concepts, field mappings, linking paths, and semantic constraints for each data source requires substantial expert effort. The builder agent constructs an initial ontology from the training workload and raw sources without observing gold answers. The workload identifies se- mantics relevant to the agent, while executable probes verify their grounding in the underlying data.
>
> Workload-Guided Probing. Given a training workload W and raw sources D , the builder proposes C = propose( W ) fromrecurrent entities, metrics, operations, and analytical conditions. For each candidate c ∈ C , it issues probe( c, D ) to identify candidate fields and linking paths and to inspect their types, values, and semantic consistency.
>
> Evidence-Grounded Commitment. Only candidates supported by their probe results are committed to the initial Content Layer:
>
> $$\mathcal { C } ^ { + } & = \{ c \in \mathcal { C } \, | \, \text {verify} ( \text {probe} ( c , \mathcal { D } ) ) = 1 \} \, , \\ \mathcal { S } _ { 0 } & = \text {construct} ( \mathcal { C } ^ { + } , \mathcal { D } ; \Gamma _ { 0 } ) \, .$$
>
> Here, verify( · ) checks the declared type, filter, and valuedistribution requirements. Verified candidates are instantiated under Γ 0 , with their supporting records retained as Evidence. Together with the default Tool Layer R 0 , they form the initial state L 0 = ( S 0 , Γ 0 , R 0 ) .
>
> ## Trajectory-Grounded Ontology Evolution
>
> Data grounding alone does not ensure that an ontology suits a particular agent. EvoOntology therefore uses historical trajectories as behavioral evidence. Successful executions reveal effective semantic structures and access patterns, while unsuccessful ones expose missing, misleading, or poorly exposed components.
>
> Trajectory Attribution. Given historical trajectories T t and the current state L t , the evolution agent extracts recurrent signatures Σ t = analyze( T t , L t ) . Each signature summarizes an interaction pattern, the ontology objects involved, and its observed outcomes. The agent assigns the signature to Content, Tool, or Schema through α : Σ t → { C , T , S } and states the expected behavioral effect of an update.
>
> Localized Intervention. For an attributed signature σ , the agent proposes L ′ t = patch( L t , σ, α ( σ )) . Each candidate modifies one level only. Content interventions add, remove, or revise instantiated semantic objects in S t . Tool interventions modify existing tools or add and remove tools in R t according to observed agent behavior. Schema interventions revise the object model in Γ t . Multiple dependent Content objects may be updated together when they implement the same hypothesis.
>
> Backbone-Conditional Paired Validation. For backbone m , let ϕ ( L , V ; m ) denote the score of ontology state L onvalidation set V . The candidate and its parent are evaluated on the same V with identical decoding and interaction budgets. The candidate is retained only when its improvement reaches margin τ :
>
> $$\mathcal { L } _ { t + 1 } = \begin{cases} \mathcal { L } _ { t } ^ { \prime } , & \phi ( \mathcal { L } _ { t } ^ { \prime } , \mathcal { V } ; m ) - \phi ( \mathcal { L } _ { t } , \mathcal { V } ; m ) \geq \tau , \\ \mathcal { L } _ { t } , & \text {otherwise} . \end{cases} \quad ( 2 ) \quad \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \$$
>
> The single-level difference isolates the attributed hypothesis while limiting regressions on the validation set. Rejected candidates are not deployed, and their signatures, interventions, and evaluation outcomes are logged to avoid repeated ineffective updates. All backbones evolve independently from the same initial state L 0 , allowing accepted updates to reflect backbone-specific interaction patterns.
>
> ## Experiments
>
> ## Benchmarks
>
> We evaluate EvoOntology on three data-agent benchmarks with heterogeneous modalities and answer formats. All evaluations follow each benchmark's official evaluation protocol.
>
> Deep Data Research (DDR-Bench) (Liu et al. 2026) evaluates open-ended data research across heterogeneous sources. We evaluate on the 10-K scenario, and report Message-Wise accuracy on per-turn interpretation, Trajectory-Wise accuracy on full-history synthesis.
>
> InsightBench (Sahu et al. 2025) is a business-analytics benchmark of business-intelligence flags, each paired with a CSVdataset and a ground-truth insight that an analyst should surface. We report the Insight and Summary scores.
>
> BIRD (Li et al. 2023) is a text-to-SQL benchmark on natural-language questions across real-world databases, evaluated under the official Oracle Knowledge setting. Follow-up benchmarks such as Spider (Yu et al. 2018; Lei et al. 2025) extend the setting to multi-schema and enterprise workflows. The primary metric is Execution Accuracy EX and the secondary is Valid Efficiency Score VES.
>
> ## Experimental Setup
>
> Backbones. We evaluate EvoOntology on six LLM backbones: GPT-5.5, GPT-5.6-sol, Claude-Sonnet-5, ClaudeOpus-4.8, DeepSeek-V4-Flash, and Qwen3.5-Flash. For each backbone, all conditions use the same ReAct (Yao et al. 2022) scaffold, raw-data tools, decoding configuration, and interaction budget. Scoring follows each benchmark's standard evaluation protocol (Li et al. 2023; Sahu et al. 2025; Liu et al. 2026).
>
> Baselines. We compare EvoOntology against two baselines under the same ReAct scaffold and backbone. Baseline runs ReAct without any ontology layer, so the agent must rediscover the schema and the domain vocabulary at every task. Baseline + SL prepends the builder-agent's semantic layer into the agent's context as a static prompt fragment (Cao et al. 2024; Caferoğlu and Ulusoy 2024; Li et al. 2024b; Chang and Fosler-Lussier 2023).
>
> Reciprocal Two-Fold Evaluation. We treat ontology construction and evolution as training-time workload adaptation, following held-out optimization protocols in prompt and agent adaptation (Zhou et al. 2022; Yang et al. 2024; Xu, Wen, and Li 2026). Each benchmark is divided into two disjoint folds, A and B . In the A → B run, 70% of A is used for ontology construction, trajectory analysis, and candidate generation, and the remaining 30% for paired validation. The selected ontology is frozen before testing on B . We then reverse the folds and report
>
> $$S c o r = \frac { S c o r e _ { A \rightarrow B } + S c o r e _ { B \rightarrow A } } { 2 } .$$
>
> This reciprocal design follows two-fold split-and-swap evaluation (Dietterich 1998; Wang et al. 2026). All methods use the same fold assignment and deployment configuration. The same adaptation fold is used for ontology construction and updating across all relevant conditions. The held-out fold is accessed only for final evaluation after the ontology has been frozen, and its answers and evaluator feedback are never used for ontology construction, evolution, or candidate selection.
>
> ## Main Results
>
> Capability on Multi-Source Data Research. Table 1 reports DDR-Bench results across six LLM backbones. EvoOntology improves Trajectory-Wise accuracy on all six backbones, with an average gain of +17 . 8 points over Baseline. The improvement ranges from +4 . 8 on Qwen3.5-Flash to +26 . 7 on GPT-5.5, indicating that the ontology remains effective across backbones with substantially different baseline capabilities. In contrast, Baseline + SL , which injects the semantic layer into the context as a static prompt, does not consistently improve over the un-mediated agent and even drops by -15 . 0 points on Claude-Sonnet-5. The gap between Baseline + SL and EvoOntology stems from how the layer is used: a static prompt fragment competes with the agent's other instructions and cannot be pruned per turn, whereas EvoOntology exposes the same content through MCP tools that the agent actively queries, retrieving only the terms and mappings relevant to the current step. We additionally compare against ReAct + Memory (Shinn et al. 2023; Wang et al. 2023; Madaan et al. 2023), which stores past trajectories as retrievable episodes. As shown in Table 2, memory-based persistence lifts Trajectory-Wise from 69 . 5 to 75 . 8 but remains 13 . 7 points below EvoOntology, because episodic memory only replays what has been done and does not expose typed, composable structure.
>
> Capability on Insight Mining. Table 3 reports InsightBench results across six backbones. EvoOntology improves
>
> Table 1: Main results on the DDR-Bench 10-K scenario. Parentheses report the gain over the Baseline result.
>
> | Method                                 | Backbone                        | Msg-Wise (%, ↑ )   | Traj-Wise (%, ↑ )        | Overall (%, ↑ )   |
> |----------------------------------------|---------------------------------|--------------------|--------------------------|-------------------|
> | Reported ReAct                         | Claude-Sonnet-4.5 DeepSeek-V3.2 | 77.6 60.1          | 60.6 38.2 36.0 41.1 37.1 | 69.1 49.2 48.2    |
> | Reported ReAct                         | GLM-4.6                         | 60.3               |                          |                   |
> | Reported ReAct                         | GPT-5.2                         | 44.9               |                          | 43.0              |
> | Reported ReAct                         | GPT-5-mini                      | 46.8               |                          | 42.0              |
> | Reported ReAct                         | Kimi-K2                         | 51.1               | 30.8                     | 40.1              |
> | Reported ReAct                         | GPT-5.1                         | 37.1               | 44.3                     | 40.7              |
> | Reported ReAct                         | Gemini-3-Flash                  | 44.8               | 21.2                     | 33.0              |
> | Baseline (ReAct w/o Ontology)          | GPT-5.5                         | 60.6               | 64.2                     | 62.4              |
> | Baseline (ReAct w/o Ontology)          | GPT-5.6-sol                     | 64.0               | 68.5                     | 66.3              |
> | Baseline (ReAct w/o Ontology)          | Claude-Sonnet-5                 | 74.3               | 72.5                     | 73.4              |
> | Baseline (ReAct w/o Ontology)          | Claude-Opus-4.8                 | 74.0               | 73.0                     | 73.5              |
> | Baseline (ReAct w/o Ontology)          | DeepSeek-V4-Flash               | 26.2               | 30.3                     | 28.2              |
> | Baseline (ReAct w/o Ontology)          | Qwen3.5-Flash                   | 16.4               | 14.3                     | 15.4              |
> | Baseline + SL (ReAct + Semantic Layer) | GPT-5.5                         | 58.4 ( - 2.2)      | 63.9 ( - 0.3)            | 61.2 ( - 1.2)     |
> | Baseline + SL (ReAct + Semantic Layer) | GPT-5.6-sol                     | 62.5 ( - 1.5)      | 65.5 ( - 3.0)            | 64.0 ( - 2.3)     |
> | Baseline + SL (ReAct + Semantic Layer) | Claude-Sonnet-5                 | 65.6 ( - 8.7)      | 57.5 ( - 15.0)           | 61.5 ( - 11.9)    |
> | Baseline + SL (ReAct + Semantic Layer) | Claude-Opus-4.8                 | 65.9 ( - 8.1)      | 71.4 ( - 1.6)            | 68.6 ( - 4.9)     |
> | Baseline + SL (ReAct + Semantic Layer) | DeepSeek-V4-Flash               | 28.8 (+2.6)        | 31.7 (+1.4)              | 30.2 (+2.0)       |
> | Baseline + SL (ReAct + Semantic Layer) | Qwen3.5-Flash                   | 14.8 ( - 1.6)      | 13.3 ( - 1.0)            | 14.1 ( - 1.3)     |
> | EvoOntology                            | GPT-5.5                         | 74.0 (+13.4)       | 90.9 (+26.7)             | 82.5 (+20.1)      |
> | EvoOntology                            | GPT-5.6-sol                     | 78.2 (+14.2)       | 93.5 (+25.0)             | 85.9 (+19.6)      |
> | EvoOntology                            | Claude-Sonnet-5                 | 78.4 (+4.1)        | 81.3 (+8.8)              | 79.9 (+6.5)       |
> | EvoOntology                            | Claude-Opus-4.8                 | 78.0 (+4.0)        | 92.3 (+19.3)             | 85.2 (+11.7)      |
> | EvoOntology                            | DeepSeek-V4-Flash               | 37.5 (+11.4)       | 52.3 (+22.0)             | 44.9 (+16.7)      |
> | EvoOntology                            | Qwen3.5-Flash                   | 21.1 (+4.7)        | 19.1 (+4.8)              | 20.1 (+4.8)       |
>
> Overall performance on every backbone, with a mean gain of 1 . 9 points and the largest improvement on DeepSeek-V4Flash ( +6 . 1 ). The gains are smaller than DDR-Bench because Insight is graded on short reference-style findings and saturates once the answer aligns with the reference. Baseline + SL recovers most of the Insight gain on InsightBench, but drops by -3 . 3 on Claude-Sonnet-5 Summary, whereas EvoOntology improves both Insight and Summary on all four backbones by exposing the same content through queryable tools instead of a static prompt.
>
> Capability on Data Retrieval. Table 4 reports BIRD results across six backbones under Oracle Knowledge. EvoOntology improves both EX and VES for every backbone, with average gains of 7 . 4 and 8 . 6 points. The consistent gains across both metrics indicate that the ontology improves query correctness as well as execution efficiency. Baseline + SL shows a mixed pattern: EX drops by up to -5 . 6 (GPT-5.5) while VES rises across all backbones, indicating that a static semantic layer improves SQL well-formedness but distracts from producing correct queries. Once the same content is exposed through MCP tools that the agent actively queries and refined by the evolution loop, EvoOntology recovers the EXgains and yields a stable per-backbone improvement over both baselines and prior text-to-SQL systems (Pourreza and Rafiei 2023; Wang et al. 2025; Talaei et al. 2024).
>
> Table 2: Comparison against a memory-based persistence baseline on DDR-Bench, averaged across the four backbones. 'ReAct + Memory' stores past trajectories as retrievable episodes and injects the topk into the prompt.
>
> | Method           | Traj-Wise (%, ↑ )   | ∆       |
> |------------------|---------------------|---------|
> | Baseline (ReAct) | 69 . 5              | -       |
> | ReAct + Memory   | 75 . 8              | +6 . 3  |
> | EvoOntology      | 89.5                | +20 . 0 |
>
> Table 3: Main results on InsightBench. Parentheses report the gain over the corresponding Baseline result.
>
> | Method                                 | Backbone          | Insight (%, ↑ )   | Summary (%, ↑ )   | Overall (%, ↑ )   |
> |----------------------------------------|-------------------|-------------------|-------------------|-------------------|
> | Pandas Agent AgentPoirot               | GPT-4o            | 54.0              | 40.0              | 47.0              |
> |                                        | GPT-3.5-turbo     | 50.0              | 31.0              | 40.5              |
> | AgentPoirot                            | GPT-4-turbo       | 56.0              | 35.0              | 45.5              |
> | AgentPoirot                            | Llama-3-70B       | 52.0              | 33.0              | 42.5              |
> | AgentPoirot                            | GPT-4o            | 60.0              | 44.0              | 52.0              |
> | Baseline (ReAct w/o Ontology)          | GPT-5.5           | 52.9              | 47.6              | 50.3              |
> | Baseline (ReAct w/o Ontology)          | GPT-5.6-sol       | 51.6              | 49.4              | 50.5              |
> | Baseline (ReAct w/o Ontology)          | Claude-Sonnet-5   | 53.3              | 51.3              | 52.3              |
> | Baseline (ReAct w/o Ontology)          | Claude-Opus-4.8   | 54.9              | 49.9              | 52.4              |
> | Baseline (ReAct w/o Ontology)          | DeepSeek-V4-Flash | 45.0              | 34.6              | 39.8              |
> | Baseline (ReAct w/o Ontology)          | Qwen3.5-Flash     | 37.5              | 26.2              | 31.9              |
> | Baseline + SL (ReAct + Semantic Layer) | GPT-5.5           | 53.4 (+0.5)       | 48.6 (+1.0)       | 51.0 (+0.8)       |
> | Baseline + SL (ReAct + Semantic Layer) | GPT-5.6-sol       | 51.3 ( - 0.3)     | 50.8 (+1.4)       | 51.1 (+0.6)       |
> | Baseline + SL (ReAct + Semantic Layer) | Claude-Sonnet-5   | 53.5 (+0.2)       | 48.0 ( - 3.3)     | 50.8 ( - 1.6)     |
> | Baseline + SL (ReAct + Semantic Layer) | Claude-Opus-4.8   | 55.8 (+0.9)       | 50.5 (+0.6)       | 53.2 (+0.8)       |
> | Baseline + SL (ReAct + Semantic Layer) | DeepSeek-V4-Flash | 47.0 (+2.0)       | 36.5 (+1.9)       | 41.8 (+2.0)       |
> | Baseline + SL (ReAct + Semantic Layer) | Qwen3.5-Flash     | 39.0 (+1.5)       | 25.2 ( - 1.0)     | 32.1 (+0.2)       |
> | EvoOntology                            | GPT-5.5           | 53.4 (+0.5)       | 48.6 (+1.0)       | 51.0 (+0.8)       |
> | EvoOntology                            | GPT-5.6-sol       | 53.2 (+1.6)       | 50.9 (+1.5)       | 52.1 (+1.6)       |
> | EvoOntology                            | Claude-Sonnet-5   | 54.4 (+1.1)       | 51.5 (+0.2)       | 53.0 (+0.7)       |
> | EvoOntology                            | Claude-Opus-4.8   | 55.8 (+0.9)       | 50.5 (+0.6)       | 53.2 (+0.8)       |
> | EvoOntology                            | DeepSeek-V4-Flash | 49.2 (+4.2)       | 42.6 (+8.0)       | 45.9 (+6.1)       |
> | EvoOntology                            | Qwen3.5-Flash     | 39.3 (+1.8)       | 27.6 (+1.4)       | 33.4 (+1.6)       |
>
> ## Effect of Ontology Layer
>
> To separate the contribution of the builder-constructed ontology from the additional gain brought by self-evolution, we compare three settings: Baseline , Initial , and Evolved . Baseline uses no ontology layer, Initial uses the ontology constructed by the builder agent before evolution, and Evolved uses the final ontology after self-evolution. Figure 3 reports the performance of each backbone under the three settings. To summarize the overall trend, we average the primarymetric scores across the four backbones for each benchmark and setting and compare the resulting means.
>
> The initial ontology establishes a strong improvement over the no-ontology baseline, while self-evolution consistently extends this gain across all three benchmarks. On DDRBench, the mean Trajectory-Wise score increases by 12 . 3 percentage points from Baseline to Initial , followed by a further improvement of 7 . 7 percentage points from Initial to Evolved . On InsightBench, the mean Insight score first
>
> Table 4: Main results on BIRD under Oracle Knowledge. VES is reported on a 0 -100 scale. Parentheses report the gain over the corresponding Baseline result.
>
> | Method                                 | Backbone          | EX (%, ↑ )    | VES (%, ↑ )   |
> |----------------------------------------|-------------------|---------------|---------------|
> | GPT-4                                  | GPT-4             | 46.4          | -             |
> | DIN-SQL                                | GPT-4             | 50.7          | 58.8          |
> | DAIL-SQL                               | GPT-4             | 54.8          | 56.1          |
> | TA-SQL                                 | GPT-4             | 56.2          | -             |
> | MAC-SQL                                | GPT-4             | 57.6          | 58.8          |
> | MCS-SQL                                | GPT-4             | 63.4          | -             |
> | CHESS                                  | GPT-4o            | 65.0          | 62.8          |
> | Baseline (ReAct w/o Ontology)          | GPT-5.5           | 61.5          | 63.4          |
> | Baseline (ReAct w/o Ontology)          | GPT-5.6-sol       | 63.5          | 65.6          |
> |                                        | Claude-Sonnet-5   | 61.9          | 63.7          |
> |                                        | Claude-Opus-4.8   | 67.5          | 69.6          |
> |                                        | DeepSeek-V4-Flash | 33.1          | 36.4          |
> |                                        | Qwen3.5-Flash     | 46.5          | 47.9          |
> | Baseline + SL (ReAct + Semantic Layer) | GPT-5.5           | 55.9 ( - 5.6) | 67.7 (+4.3)   |
> | Baseline + SL (ReAct + Semantic Layer) | GPT-5.6-sol       | 63.0 ( - 0.5) | 68.9 (+3.3)   |
> | Baseline + SL (ReAct + Semantic Layer) | Claude-Sonnet-5   | 60.8 ( - 1.1) | 65.8 (+2.1)   |
> | Baseline + SL (ReAct + Semantic Layer) | Claude-Opus-4.8   | 66.2 ( - 1.3) | 75.0 (+5.4)   |
> | Baseline + SL (ReAct + Semantic Layer) | DeepSeek-V4-Flash | 36.3 (+3.2)   | 37.2 (+0.7)   |
> | Baseline + SL (ReAct + Semantic Layer) | Qwen3.5-Flash     | 48.0 (+1.5)   | 51.9 (+4.0)   |
> | EvoOntology                            | GPT-5.5           | 68.9 (+7.4)   | 71.1 (+7.7)   |
> | EvoOntology                            | GPT-5.6-sol       | 70.7 (+7.2)   | 73.0 (+7.4)   |
> | EvoOntology                            | Claude-Sonnet-5   | 71.8 (+9.9)   | 74.1 (+10.4)  |
> | EvoOntology                            | Claude-Opus-4.8   | 78.3 (+10.8)  | 80.5 (+10.9)  |
> | EvoOntology                            | DeepSeek-V4-Flash | 39.4 (+6.4)   | 44.1 (+7.6)   |
> | EvoOntology                            | Qwen3.5-Flash     | 49.1 (+2.5)   | 55.2 (+7.3)   |
>
> increases by 0 . 8 points and then gains another 0 . 2 points through evolution. On BIRD, the mean EX score improves by 5 . 1 percentage points with the initial ontology and by a further 3 . 7 percentage points after evolution. These results show that the builder-constructed ontology provides an effective starting point, whereas the self-evolution loop is essential for realizing the full performance gain and consistently improves the ontology beyond its initial state.
>
> ## Analyses
>
> To better understand the source and behavior of EvoOntology's advantage, we conduct a series of in-depth analyses. Unless otherwise stated, all analyses in this section are conducted on DDR-Bench across the four backbones (GPT-5.5, GPT-5.6-sol, Claude-Sonnet-5, Claude-Opus-4.8).
>
> ## Effect of Iterative Evolution
>
> To evaluate whether the observed gain accumulates through many small edits and does not collapse into a single round, we plot the deployed agent's primary score across the sequence of accepted evolution rounds on DDR-Bench. Each round corresponds to one candidate that passed the paired gate, and the parent line traces the score of the ontology version that would remain if no more rounds were run. As shown in Figure 4, all four backbones improve monotonically from Initial through the accepted rounds, with GPT-5.6-sol reaching 93 . 5 Traj-Wise after five accepted rounds and Claude-
>
> Figure 3: Primary metric on the three benchmarks under three conditions: Baseline , Initial , and Evolved (EvoOntology).
>
> *Figure 3: Baseline, Initial and Evolved per backbone on all three benchmarks. The DDR-Bench spread is wide, InsightBench is nearly flat, BIRD sits in between.*
>
> ![[evoontology-15779-003.png]]
>
> Figure 4: Primary metric across accepted evolution rounds on the three benchmarks: Traj-Wise on DDR-Bench, Insight on InsightBench, and EX on BIRD.
>
> *Figure 4: primary metric across accepted evolution rounds. All four backbones rise monotonically from Initial and flatten over the last two rounds.*
>
> ![[evoontology-15779-004.png]]
>
> Opus-4.8 reaching 92 . 3 after four. Notably, the trajectories flatten by the last two rounds, which is consistent with the failure signatures becoming rarer once the ontology covers the recurrent cross-filing concepts. The results show that the gains reported in Table 1 are the outcome of a converging refinement and not a single fortunate patch, which validates the design of the four-step evolution loop.
>
> ## Ablation Study on Evolution Loop
>
> The relative contribution of the four steps in the evolution loop (diagnose, attribute, patch, gate) is assessed by disabling each step in turn and comparing the resulting final Evolved score on DDR-Bench, averaged across the four backbones.The disabled variant of each step is: w/o Diagnose skips the failure-trace clustering step and asks the evolution agent to propose an edit from a random sample of recent traces; w/o Attribution drops the level tag and lets the agent commit an edit at any level without stating a hypothesis; w/o Patch stage replaces the typed, hypothesis-conditioned edit with a free-form ontology rewrite that the evolution agent produces directly from the diagnosis; w/o Gate accepts every candidate patch. As shown in Table 5, removing the gate causes the largest drop ( -11 . 2 Traj-Wise), because unfiltered candidates admit regressions that the next round cannot always undo. Removing the attribution step drops by -6 . 3 , because without a level tag the loop tends to make content edits when the failure is a manifest problem, and vice versa. Removing the diagnose step drops by -4 . 8 , and replacing the typed patch with a free-form rewrite drops by -1 . 7 . The results show that the gate and attribution are the two loadbearing pieces, which validates the design of an evolution loop that is more selective than iterative.
>
> Three-Level Evolution. Beyond removing individual steps, we further evaluate whether the three editable levels (Content / Tool / Schema) are jointly required by restricting
>
> Table 5: Ablation on the four steps of the evolution loop, averaged across four backbones.
>
> | Variant               | Traj-Wise (%, ↑ )   | ∆        |
> |-----------------------|---------------------|----------|
> | Full loop             | 89.5                | -        |
> | w/o Gate              | 78 . 3              | - 11 . 2 |
> | w/o Attribution       | 83 . 2              | - 6 . 3  |
> | w/o Diagnose          | 84 . 7              | - 4 . 8  |
> | w/o Patch (free-form) | 87 . 8              | - 1 . 7  |
>
> Table 6: Ablation on the three editable levels of the evolution loop on DDR-Bench, averaged across four backbones.
>
> | Variant                    | Traj-Wise (%, ↑ )   | ∆       |
> |----------------------------|---------------------|---------|
> | Baseline                   | 69 . 5              | -       |
> | Content-only evolution     | 78 . 2              | +8 . 7  |
> | Tool-only evolution        | 82 . 7              | +13 . 2 |
> | Schema-only evolution      | 73 . 1              | +3 . 6  |
> | Full three-level evolution | 89.5                | +20 . 0 |
>
> the evolution loop to a single level at a time and comparing against the full three-level variant on DDR-Bench, averaged across the four backbones. As shown in Table 6, Tool-only evolution recovers the largest single-level gain ( +13 . 2 over Baseline), consistent with the manifest reshaping being the dominant lever surfaced by the attribution analysis in Figure 7. Content-only and Schema-only evolution contribute +8 . 7 and +3 . 6 respectively, but none reaches the +20 . 0 of the full three-level loop. The results indicate that the three levels are complementary and not substitutable, which validates the design of an evolution loop that ranges over all three editable levels.
>
> ## Ablation Study on Ontology Structure
>
> Wemaskeachremovableobjectfamilyfromthefinal Evolved ontology on DDR-Bench and report the average performance across four backbones. As shown in Table 7, masking Mappings causes the largest drop ( -13 . 4 Traj-Wise), which is consistent with the role of Mappings as the only object that grounds a Term to concrete columns and join paths. Masking Evidence drops by -8 . 7 , because without a probe query the agent cannot verify a candidate SQL fragment against the underlying value distribution. Masking Constraints and Relations produces smaller drops ( -3 . 5 and -2 . 1 ), and Terms cannot be masked in isolation as every other family references them. These findings identify Mappings and Evidence as the two load-bearing families, which validates our decision to require every committed entry to be anchored in a probe query and not a natural-language description alone.
>
> ## Divergence across Backbones
>
> Weinvestigate whether different backbones converge to similar ontologies or develop distinct ones by comparing the pairwise Jaccard overlap of their accepted Term-identifier sets on DDR-Bench. As shown in Figure 5a, no pair exceeds 0 . 62 overlap, and the two Claude backbones share less with each other ( 0 . 55 ) than the two GPT backbones
>
> | Variant          | Traj-Wise (%, ↑ )   | ∆        |
> |------------------|---------------------|----------|
> | Full EvoOntology | 89.5                | -        |
> | w/o Mappings     | 76 . 1              | - 13 . 4 |
> | w/o Evidence     | 80 . 8              | - 8 . 7  |
> | w/o Constraints  | 86 . 0              | - 3 . 5  |
> | w/o Relations    | 87 . 4              | - 2 . 1  |
>
> Table 7: Ablation on the five object families of the ontology content layer on DDR-Bench, averaged across four backbones. Terms cannot be masked in isolation and are omitted.
>
> *Figure 5a: pairwise Jaccard overlap of accepted Term identifiers between the four evolved stores. No pair exceeds 0.62, and the two Claude backbones overlap least (0.55).*
>
> ![[evoontology-15779-005.png]]
>
> - (a) Pairwise Jaccard overlap of accepted Term identifiers between the evolved stores of the four backbones.
>
> (b) Cross-backbone transfer of the evolved store: each row is fitted on one backbone and served to every backbone (columns).
>
> *Figure 5b: cross-backbone transfer. Rows are the backbone the store was fitted on, columns the deployment backbone. The diagonal is the highest entry in every column.*
>
> ![[evoontology-15779-006.png]]
>
> Figure 5: Generalization of the evolved ontology store across backbones on DDR-Bench.
>
> do ( 0 . 61 ). The accepted edits also differ across backbones. For example, Claude-Opus-4.8 retains more detailed manifest variants than Claude-Sonnet-5, while GPT-5.5 introduces short SQL fragment libraries under Evidence that do not appear in the Claude-Opus-4.8 ontology. However, identifier overlap alone cannot determine semantic equivalence, since different identifiers may encode similar concepts. We further evaluate cross-backbone transfer by applying each evolved store to all four backbones and measuring Traj-Wise performance on DDR-Bench. As shown in Figure 5b, the diagonal is uniformly the highest entry of its column, and every off-diagonal drops by at least 6 . 6 points relative to the same-backbone store; the average column drop from diagonal to off-diagonal ranges from -6 . 6 (Sonnet-5) to -10 . 9 (GPT-5.5). These results show that different backbones produce different evolved ontology stores from the same initialization. The cross-backbone transfer results further indicate that backbone-specific evolution is beneficial.
>
> ## Conclusion
>
> In this paper, we introduce EvoOntology , an interactive ontology layer that is automatically constructed and self-evolving for data agents. EvoOntology encapsulates the ontology as an MCPserver that the agent actively queries at runtime, and refines it through attribution-guided typed edits admitted only after a backbone-conditional paired evaluation gate. Experiments on benchmarks and six LLM backbones, EvoOntology consistently outperforms both ReAct baselines and traditional semantic-layer baselines, offering an effective solution for helping data agents understand heterogeneous data.
>
> Asai, A.; Wu, Z.; Wang, Y.; Sil, A.; and Hajishirzi, H. 2024. Self-rag: Learning to retrieve, generate, and critique through self-reflection. In International conference on learning representations , volume 2024, 9112-9141.
>
> Caferoğlu, H. A.; and Ulusoy, Ö. 2024. E-SQL: Direct Schema Linking via Question Enrichment in Text-to-SQL. arXiv:2409.16751 .
>
> Cao, Z.; Zheng, Y.; Fan, Z.; Zhang, X.; Chen, W.; and Bai, X. 2024. RSL-SQL: Robust Schema Linking in Text-to-SQL Generation. arXiv:2411.00073 .
>
> Chang, S.; and Fosler-Lussier, E. 2023. How to Prompt LLMs for Text-to-SQL: A Study in Zero-shot, Singledomain, and Cross-domain Settings. arXiv:2305.11853.
>
> Chen, W.; Wang, H.; Chen, J.; Zhang, Y.; Wang, H.; Li, S.; Zhou, X.; and Wang, W. Y. 2020. TabFact: A Large-scale Dataset for Table-based Fact Verification. In 8th International Conference on Learning Representations, ICLR 2020, Addis Ababa, Ethiopia, April 26-30, 2020 . OpenReview.net. dbt Labs. 2023. The Semantic Layer for Modern Data Teams. https://www.getdbt.com/product/semantic-layer. Accessed
>
> 2025-11-01.
>
> Dietterich, T. G. 1998. Approximate statistical tests for comparing supervised classification learning algorithms. Neural computation , 10(7): 1895-1923.
>
> Feng, S.; Shi, W.; Bai, Y.; Balachandran, V.; He, T.; and Tsvetkov, Y. 2024. Knowledge card: Filling LLMs' knowledge gaps with plug-in specialized language models. In International Conference on Learning Representations , volume 2024, 16097-16121.
>
> Guo, S.; Deng, C.; Wen, Y.; Chen, H.; Chang, Y.; and Wang, J. 2024. DS-Agent: Automated Data Science by Empowering Large Language Models with Case-Based Reasoning. In Proceedings of the 41st International Conference on Machine Learning , volume 235 of Proceedings of Machine Learning Research , 16813-16848. PMLR.
>
> Hitzler, P. 2021. A Review of the Semantic Web Field. Communications of the ACM , 64(2): 76-83.
>
> Hong, S.; Lin, Y.; Liu, B.; Liu, B.; Wu, B.; Zhang, C.; Li, D.; Chen, J.; Zhang, J.; Wang, J.; et al. 2025. Data interpreter: An llm agent for data science. In Findings of the Association for Computational Linguistics: ACL 2025 , 19796-19821.
>
> Khattab, O.; Singhvi, A.; Maheshwari, P.; Zhang, Z.; Santhanam, K.; Vardhamanan, S.; Haq, S.; Sharma, A.; Joshi, T. T.; Moazam, H.; Miller, H.; Zaharia, M.; and Potts, C. 2023. DSPy: Compiling Declarative Language Model Calls into Self-Improving Pipelines. arXiv:2310.03714.
>
> Lei, F.; Chen, J.; Ye, Y.; Cao, R.; Shin, D.; Su, H.; Suo, Z.; Gao, H.; Hu, W.; Yin, P.; et al. 2025. Spider 2.0: Evaluating language models on real-world enterprise text-to-sql workflows. In International Conference on Learning Representations , volume 2025, 28691-28735.
>
> Li, H.; Zhang, J.; Liu, H.; Fan, J.; Zhang, X.; Zhu, J.; Wei, R.; Pan, H.; Li, C.; and Chen, H. 2024a. Codes: Towards building open-source language models for text-to-sql. Proceedings of the ACM on Management of Data , 2(3): 1-28.
>
> Li, J.; Hui, B.; Qu, G.; Li, B.; Yang, J.; Li, B.; Wang, B.; Qin, B.; Cao, R.; Geng, R.; et al. 2023. Can llm already serve as a database interface. A big bench for large-scale database grounded text-to-SQLs , 2305.
>
> Li, Z.; Wang, X.; Zhao, J.; Yang, S.; Du, G.; Hu, X.; Zhang, B.; Ye, Y.; Li, Z.; Zhao, R.; and Mao, H. 2024b. PET-SQL: APrompt-Enhanced Two-Round Refinement of Text-to-SQL with Cross-consistency. arXiv:2403.09732 .
>
> Liu, W.; Yu, P.; Orini, M.; Du, Y.; and He, Y. 2026. Hunt Instead of Wait: Evaluating Deep Data Research on Large LanguageModels. Acceptedatthe43rdInternational Conference on Machine Learning (ICML 2026), arXiv:2602.02039.
>
> Madaan, A.; Tandon, N.; Gupta, P.; Hallinan, S.; Gao, L.; Wiegreffe, S.; Alon, U.; Dziri, N.; Prabhumoye, S.; Yang, Y.; et al. 2023. Self-refine: Iterative refinement with selffeedback. Advances in neural information processing systems , 36: 46534-46594.
>
> Nan, L.; Zhao, Y.; Zou, W.; Ri, N.; Tae, J.; Zhang, E.; Cohan, A.; and Radev, D. 2023. Enhancing text-to-SQL capabilities of large language models: A study on prompt design strategies. In Findings of the Association for Computational Linguistics: EMNLP 2023 , 14935-14956.
>
> Pasupat, P.; and Liang, P. 2015. Compositional semantic parsing on semi-structured tables. In Proceedings of the 53rd Annual Meeting of the Association for Computational Linguistics and the 7th International Joint Conference on Natural Language Processing (Volume 1: Long Papers) , 14701480.
>
> Patil, S. G.; Zhang, T.; Wang, X.; and Gonzalez, J. E. 2024. Gorilla: Large language model connected with massive apis. Advances in Neural Information Processing Systems , 37: 126544-126565.
>
> Pourreza, M.; and Rafiei, D. 2023. Din-sql: Decomposed incontext learning of text-to-sql with self-correction. Advances in neural information processing systems , 36: 36339-36348.
>
> Qin, Y.; Liang, S.; Ye, Y.; Zhu, K.; Yan, L.; Lu, Y.; Lin, Y.; Cong, X.; Tang, X.; Qian, B.; et al. 2023. Toolllm: Facilitating large language models to master 16000+ real-world apis. In The twelfth international conference on learning representations .
>
> Sahu, G.; Puri, A.; Rodriguez, J. A.; Abaskohi, A.; Chegini, M.; Drouin, A.; Taslakian, P.; Zantedeschi, V.; Lacoste, A.; Vazquez, D.; Chapados, N.; Pal, C.; Rajeswar, S.; and Laradji, I. 2025. InsightBench: Evaluating Business Analytics Agents Through Multi-Step Insight Generation. In Yue, Y.; Garg, A.; Peng, N.; Sha, F.; and Yu, R., eds., International Conference on Learning Representations , volume 2025, 4683-4715.
>
> Schick, T.; Dwivedi-Yu, J.; Dessì, R.; Raileanu, R.; Lomeli, M.; Hambro, E.; Zettlemoyer, L.; Cancedda, N.; and Scialom, T. 2023. Toolformer: Language models can teach themselves to use tools. Advances in neural information processing systems , 36: 68539-68551.
>
> Shinn, N.; Cassano, F.; Gopinath, A.; Narasimhan, K.; and Yao, S. 2023. Reflexion: Language agents with verbal reinforcement learning. Advances in neural information processing systems , 36: 8634-8652.
>
> Talaei, S.; Pourreza, M.; Chang, Y.-C.; Mirhoseini, A.; and Saberi, A. 2024. CHESS: Contextual Harnessing for Efficient SQL Synthesis. arXiv:2405.16755.
>
> Wang, B.; Ren, C.; Yang, J.; Liang, X.; Bai, J.; Chai, L.; Yan, Z.; Zhang, Q.-W.; Yin, D.; Sun, X.; and Li, Z. 2025. MAC-SQL: A Multi-Agent Collaborative Framework for Text-to-SQL. In Rambow, O.; Wanner, L.; Apidianaki, M.; Al-Khalifa, H.; Eugenio, B. D.; and Schockaert, S., eds., Proceedings of the 31st International Conference on Computational Linguistics , 540-557. Abu Dhabi, UAE: Association for Computational Linguistics.
>
> Wang, G.; Xie, Y.; Jiang, Y.; Mandlekar, A.; Xiao, C.; Zhu, Y.; Fan, L.; and Anandkumar, A. 2023. Voyager: An Open-Ended Embodied Agent with Large Language Models. arXiv:2305.16291 .
>
> Wang, Y.; Chen, Y.; Goyal, A.; and Sundaram, H. 2026. CausalDetox: Causal Head Selection and Intervention for Language Model Detoxification. In Findings of the Association for Computational Linguistics: ACL 2026 , 1189311914.
>
> Xu, T.; Wen, H.; and Li, M. 2026. Adapting the interface, not the model: Runtime harness adaptation for deterministic llm agents. arXiv preprint arXiv:2605.22166 .
>
> Yang, C.; Wang, X.; Lu, Y.; Liu, H.; Le, Q. V.; Zhou, D.; and Chen, X. 2024. Large language models as optimizers. In International Conference on Learning Representations , volume 2024, 12028-12068.
>
> Yao, S.; Zhao, J.; Yu, D.; Shafran, I.; Narasimhan, K. R.; and Cao, Y. 2022. React: Synergizing reasoning and acting in language models. In NeurIPS 2022 Foundation Models for Decision Making Workshop .
>
> Yu, T.; Zhang, R.; Yang, K.; Yasunaga, M.; Wang, D.; Li, Z.; Ma, J.; Li, I.; Yao, Q.; Roman, S.; et al. 2018. Spider: A largescale human-labeled dataset for complex and cross-domain semantic parsing and text-to-sql task. In Proceedings of the 2018 conference on empirical methods in natural language processing , 3911-3921.
>
> Zhang, W.; Shen, Y.; Tan, Z.; Hou, G.; Lu, W.; and Zhuang, Y. 2023a. Data-Copilot: Bridging Billions of Data and Humans with Autonomous Workflow. arXiv:2306.07209 .
>
> Zhang, X.; Yang, Y.; Lasseigne, B.; and Yao, X. 2023b. Schema-Aware Multi-Task Learning for Complex Text-toSQL. arXiv:2305.09994.
>
> Zhou, Y.; Muresanu, A. I.; Han, Z.; Paster, K.; Pitis, S.; Chan, H.; and Ba, J. 2022. Large language models are human-level prompt engineers. In The eleventh international conference on learning representations .
>
> Figure 6: Growth of the Content Layer across accepted evolution rounds on DDR-Bench under GPT-5.6-sol. The curves report the four node families and instantiated Semantic Relations. The right axis reports Trajectory-Wise performance.
>
> *Figure 6: Content Layer growth across accepted rounds under GPT-5.6-sol. Terms rise from 61 to 80, every tracked family flattens after round three, and Trajectory-Wise flattens with them.*
>
> ![[evoontology-15779-007.png]]
>
> ## Content-Layer Growth across Evolution Rounds
>
> To examine whether iterative evolution causes uncontrolled expansion of the ontology content, we track its instantiated elements across the accepted evolution rounds on DDR-Bench, using GPT-5.6-sol as a representative backbone. The tracked elements comprise the four node families, Terms , Mappings , Constraints , and Evidence , together with instantiated Semantic Relations .As shown in Figure 6, most content growth occurs in the first three rounds. The number of Terms increases from 61 in the Initial ontology to 80 after five accepted rounds, while the per-round growth of every tracked element falls below 5% after round three. The content-size curves then flatten together with Trajectory-Wise performance. Content expansion is therefore concentrated in the early rounds, when the evolution loop addresses recurrent semantic gaps, and stabilizes once these gaps have been covered.
>
> ## Cost of the Ontology Layer
>
> The ontology layer introduces a compact manifest into the agent's initial context and retrieves detailed semantic records through MCP tools. We measure its computational cost using the average input and output tokens per turn, the number of turns per task, and the resulting total tokens per task on DDR-Bench.Table 8 shows that the Initial ontology increases average input tokens per turn from 3 . 2 K to 4 . 1 K because of the manifest and retrieved semantics. At the same time, the average trajectory shortens from 14 . 6 to 11 . 2 turns, reducing the total cost from 52 . 6 K to 50 . 4 K tokens per task. The Evolved ontology further reduces the trajectory to 8 . 4 turns and the total cost to 42 . 0 K tokens, which is approximately 20% below the Baseline . Over the same comparison, Trajectory-Wise performance rises from 69 . 5 to 89 . 5 .The ontology layer therefore adds modest per-turn context while reducing repeated schema discovery over the full trajectory. Evolution strengthens this effect by improving how the agent discovers and grounds relevant semantics.
>
> Table 8: Cost of the ontology layer on DDR-Bench, averaged across the four-backbone analysis subset.
>
> | Metric                   |   Baseline |   Initial |   Evolved |
> |--------------------------|------------|-----------|-----------|
> | Input tokens / turn (K)  |        3.2 |       4.1 |       4.6 |
> | Output tokens / turn (K) |        0.4 |       0.4 |       0.4 |
> | Turns / task             |       14.6 |      11.2 |       8.4 |
> | Total tokens / task (K)  |       52.6 |      50.4 |      42   |
> | Traj-Wise (%, ↑ )        |       69.5 |      81.8 |      89.5 |
>
> Figure 7: Distribution of the accepted evolution gain across Content, Tool, and Schema edits on DDR-Bench, aggregated over the four-backbone analysis subset.
>
> *Figure 7: accepted rounds per level (Tool 6, Content 11, Schema 3) against each level's share of total gain (Tool 57 percent, Content 34 percent, Schema 9 percent). Content edits are the most frequent; Tool edits carry the most gain.*
>
> ![[evoontology-15779-008.png]]
>
> ## Attribution across Editable Levels
>
> We next examine how the accepted evolution gain is distributed across the three editable levels. Each accepted round is grouped by its attribution tag, and the paired-evaluation improvement contributed by each group is aggregated across the four backbones. As shown in Figure 7, Tool-level edits account for 57% of the cumulative gain across six accepted rounds. These edits mainly improve how existing ontology content is exposed through the manifest and MCP tools. Content-level edits contribute 34% across eleven accepted rounds by adding or refining Terms , Mappings , Constraints , Evidence , and Semantic Relations identified from interaction trajectories. Schema-level edits contribute the remaining 9% across three accepted rounds by changing the representational structure of the ontology. Content edits are more frequent, while Tool edits contribute the largest share of the accumulated gain. Schema edits are less common but address limitations that cannot be resolved by modifying instantiated content alone. This distribution is consistent with the three levels serving distinct and complementary roles during evolution.
>
> ## Case Study: Evolution of Card-Legality Semantics
>
> Figure 8 presents a representative text-to-SQL case in which the agent must identify cards that are banned in a target game format. The case illustrates how a localized Content-level update extends the ontology without rewriting its existing Tool or Schema layers.
>
> Initial state. The Initial ontology L 0 contains the Terms Card and Legality , together with an association between them. The Card Term is grounded to Cards.uuid , while the Legality Term is grounded to legalities.uuid ,
>
> Figure 8: Evolution of the ontology for a card-legality task. The Initial state contains general Card and Legality semantics but no explicit interpretation of legality status. The accepted patch adds a Legality Status Code Term, its Mapping and Evidence, and a Constraint that relates the status value to the requested format. Red dashed boxes mark the added or refined objects.
>
> *Figure 8: the card-legality case study. Red dashed boxes mark the added Legality Status Code Term, its Mapping to legalities.status, the status-distribution Evidence, and the format-conditional Constraint, with the Tool and Schema layers untouched.*
>
> ![[evoontology-15779-009.png]]
>
> legalities.format , and legalities.status . Schema observations for the two tables are retained as Evidence.Although these objects allow the agent to locate the relevant table, the ontology does not explain how the values of legalities.status should be interpreted. It also does not make explicit that legality status is defined relative to a particular game format. The agent must therefore rediscover these semantics from raw values during execution.
>
> Attributed limitation. The evolution agent attributes this limitation to the Content Layer. The existing browse and resolve tools can already retrieve the relevant objects, and the Schema Layer can represent the required knowledge. The missing component is a reusable semantic description of the status field and its applicability condition.
>
> Localized intervention. The Candidate adds a new Term, Legality Status Code , and grounds it to legalities.status . An Evidence object records the observed distribution of the status values. A Constraint then states that identifying banned cards requires both legalities.status = 'Banned' and legalities.format = target\_format . The existing Card and Legality objects remain unchanged, and the Candidate introduces no Tool- or Schema-level modification.After passing paired validation, the Candidate becomes part of the Evolved ontology L t .
>
> Effect on agent interaction. With the Evolved ontology, browse can surface Legality Status Code for queries involving banned or legal cards. The agent can then use resolve to obtain the physical Mapping, the supporting Evidence, and the format-dependent Constraint. Native SQL execution remains responsible for applying the filter and verifying the returned records.The case shows that evolution can correct a specific semantic gap by adding a small connected set of objects. The ontology retains its existing structure and interface while providing the agent with the missing interpretation required for the task.

## Links

- [Abstract (arXiv 2609.15779)](https://arxiv.org/abs/2609.15779)
- [PDF](https://arxiv.org/pdf/2609.15779)
- [Code (ruc-datalab/EvoOntology)](https://github.com/ruc-datalab/EvoOntology)
