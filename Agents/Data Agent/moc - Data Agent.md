---
created: 2026-03-07
description: Navigation hub for Data Agent notes — AI agents that query databases, write SQL, and answer data questions.
source: internal
type: moc
---

# Data Agent

AI agents that interact with structured data to answer questions — text-to-SQL, discovery layers, context architectures over warehouses, and RL for SQL tool use.

## Perspective & Vision

- [[Berkeley's EPIC Data Lab argues near-free intelligence makes agents the dominant data-systems workload, needing data systems for, of, and by agents]] — the orienting frame for this folder: as inference cost approaches zero, agents (not humans/BI tools) become the dominant DB workload. A landscape survey + research agenda across three axes — **FOR agents** (agentic speculation: 1000s of SQL queries per request, 80-90% duplicate sub-plans, reuse/satisfice/proactive systems), **OF agents** (the agentic substrate: structured corrective memory beyond markdown files/KGs, concurrent-edit/CRDT/livelock problems, durable execution, agent negotiation), and **BY agents** (synthesizing disposable workload-specific engines — Bespoke OLAP, GenDB, custom KV stores — with verification agents + proof-carrying synthesis to earn trust). Parameswaran, Zaharia, Stoica, Hellerstein et al.

## Market Analysis

- [[data agents are useless without a context layer that captures business definitions and tribal knowledge]] — a16z's Jason Cui on why the modern data stack → agent frenzy → wall pattern demands a living context layer as superset of semantic layers

## Case Studies

- [[Anthropic's self-service analytics stack achieves 95% accuracy by treating the bottleneck as context and entity mapping not SQL generation]] — four-layer agentic stack (data foundations, sources of truth, skills, validation) that routes 95% of business queries through Claude; pairwise skills drive accuracy from 21% to 95%+; ablations showed raw SQL retrieval moves accuracy by <1 point
- [[OpenAI internal data agent succeeds through six layers of context not model capability alone]] — six stacked context layers over 600PB across 70k datasets; architecture over raw model capability
- [[context management replaces the semantic layer for data agents because it adapts from corrections]] — Jamie Quint's practitioner guide; dynamic context + correction-driven "quirks" replaced 4-5 analyst hires
- [[the hard problem in text-to-SQL is discovery not generation and hybrid search over existing metadata solves it]] — Astronomer's Kepler: hybrid search (RRF) + discovery subagent over warehouse metadata
- [[Databricks Genie pushes data agents past coding-agent baselines via specialized knowledge search, parallel thinking, and multi-LLM design]] — three-pronged architecture (specialized search + parallel sampling + per-stage Multi-LLM with GEPA) lifts Genie from 32% to 90%+ over a leading coding agent on internal benchmark

## Infrastructure

- [[dltHub Pro delivers a context graph for data engineering because agent-readable schemas and traces outcompete chat-box overlays when 91% of pipelines are agent-written]] — dltHub Pro launch: agents now write 91% of dlt pipelines (81k/month); execution-path context graphs beat chat-box overlays; Python-first architecture right for humans and agents alike
- [[semantic SQL parsing makes data transformations programmatically validatable which is what data agents need underneath them]] — SQLMesh parses SQL via SQLGlot for compile-time validation, column-level lineage, and cross-engine transpilation; now owned by Fivetran alongside dbt

## Frameworks

- [[RLMs inline intelligence into data pipelines by giving LLMs symbolic access to DataFrames in a persistent REPL]] — DSPy's SandboxSerializable protocol lets RLMs iteratively explore DataFrames in a Pyodide REPL, hitting 87% on DABench with a 15-line generic solver

## Research

- [[multi-task RL on heterogeneous search behaviors produces knowledge agents that generalize across grounded reasoning tasks]] — KARL (Databricks): multi-task off-policy RL yields Pareto-optimal knowledge agents across grounded reasoning tasks
- [[Prime Intellect duckdb-qa - RL reward shaping for SQL tool use]] — RL environment for training LLMs as SQL data analysts; 578 QA pairs across 4 DuckDB schemas
- [[Google's data-agent study finds semantic metadata (schema.org, FAIR) still beats open-web search for actionable data retrieval]] — Chen, Alrashed, Halevy, Noy (Google): near-identical ADK/Gemini-2.5-Pro agents over Google Search (billions of web docs) vs Google Dataset Search (90M schema.org records), scored by an LLM-as-judge pipeline mapped to FAIR (relevance / 6-level accessibility / page-type). Relevance ties (~60%) but the Semantic Agent wins actionability — 71.4% vs 48.7% machine-readable (+46.6%), 88.4% vs 61.0% DATA_REGISTRY (+44.9%), +65.7% overall FAIR-compliant precision — while the Baseline Agent wins coverage (40% more queries) yet fails the "last mile" on prose (20.1%) and portals (8.5%). Conclusion: unstructured retrieval for exploration, structured/semantic ecosystems for reliable execution; proposes a semantic-first-then-fallback hybrid
- [[DAB benchmark exposes frontier data agents at 38 percent pass at 1 with 85 percent of failures in planning or implementation]] — UC Berkeley + Hasura's Data Agent Benchmark: 54 queries across 12 datasets and 4 DBMSes; Gemini-3-Pro tops at 38% pass@1; failure breakdown of 1,147 trajectories puts the bottleneck on planning (40%) and implementation (45%), not data selection (15%); PromptQL semantic layer adds 7pp over ReAct on Claude-Opus-4.6
- [[Bridgewater and Thinking Machines fine-tune Qwen3-235B to replicate expert investor judgment, beating frontier LLMs on financial information-filtering at 13.8x lower cost]] — Bridgewater AIA Labs × Thinking Machines: frontier LLMs stall at ~50% (naive) / high-70s (expert-prompted) on six investor triage tasks; a contested-example verification loop cleans expert labels, and a multi-task RL recipe on Tinker (interleaved batching + CISPO asymmetric clipping + on-policy distillation from a promoted best-val teacher) fine-tunes Qwen3-235B to 84.7% (29.8% fewer errors than the best frontier model) at 13.8x lower cost — the case for "differentiated intelligence"
