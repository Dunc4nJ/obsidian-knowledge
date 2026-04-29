---
created: 2026-04-29
source: https://github.com/lmnr-ai/lmnr
description: Open-source observability platform purpose-built for AI agents — OTel-native tracing with transcript-first viewer, subagent cards, span-cited trace chat, evals, and SQL access. YC S24, Apache-2.0.
type: resource
tags: [observability, tracing, evals, agent-observability, open-source, otel, rust]
status: exploring
---

## What it is

Laminar is an open-source (Apache-2.0) observability platform built specifically for AI agents — not retrofitted from backend APM. OpenTelemetry-native tracing SDK with one-line auto-instrumentation for Vercel AI SDK, Browser Use, Stagehand, LangChain, the Claude Agent SDK, OpenAI/Anthropic/Gemini, and more. Self-hostable via `docker compose up`; managed cloud at laminar.sh. Backend written in Rust with a custom realtime engine and full-text search over span data.

## Why it's interesting

The core thesis: agent traces aren't backend traces, and reading them as flame graphs indexed by latency is the wrong abstraction. Laminar reorganizes runs as a linear **transcript** of the LLM/tool loop with reasoning surfaced inline, **collapses subagent fan-outs into single cards** so a six-subagent run doesn't render as a wall, layers a **timeline strip** that exposes parallelism vs serialization at a glance, and ships a **"Chat with trace"** that answers natural-language questions with clickable span-pill citations. See [[Laminar trace viewer reads agent runs as transcripts of LLM-tool loops not backend span trees]] for the design principles. Auto-extracts root-call and subagent inputs from OTel spans — no `"prompt"` wrapper attribute to remember.

## How it works

- **Tracing.** OpenTelemetry-native; one line of code (`Laminar.initialize(...)`) auto-instruments supported frameworks. `observe()` decorator (Python) / wrapper (TS) for arbitrary functions. gRPC exporter for high-throughput ingestion.
- **Trace viewer.** Transcript view exposes the LLM-tool while-loop with model reasoning inline next to the tool call it produced. Tool calls render with one-line argument previews. Subagent invocations collapse into intent-named cards. Timeline strip above the transcript shows the run as colored bars on a single time axis, bidirectionally synced with the transcript scroll position.
- **Evals.** Unopinionated SDK and CLI for running evals locally or in CI/CD. UI for visualizing results and comparing runs.
- **Signals (AI monitoring).** Define events with natural-language descriptions to track issues, logical errors, and custom agent behavior. Self-hosted requires `GOOGLE_GENERATIVE_AI_API_KEY`.
- **SQL access.** Built-in SQL editor over traces, metrics, and events. Bulk-create datasets from queries. Available via API.
- **Dashboards.** Custom dashboard builder backed by SQL queries.

## Key links

- [GitHub](https://github.com/lmnr-ai/lmnr) — Apache-2.0, ~2.8k stars, ~1,500 commits, 85 releases (latest v0.1.45 on 2026-04-27)
- [laminar.sh](https://laminar.sh) — managed platform
- [Docs](https://laminar.sh/docs)
- [Viewing traces docs](https://laminar.sh/docs/platform/viewing-traces) — timeline strip, transcript sync, drag-to-filter
- [Claude Agent SDK integration](https://laminar.sh/docs/tracing/integrations/claude-agent-sdk)
- [Integrations overview](https://laminar.sh/docs/tracing/integrations/overview)

## Notes

- **Languages on disk:** TypeScript 70%, Rust 25%, MDX/Python ~4%. Frontend is TS, hot-path engine is Rust. This explains the "extremely high performance" claim — full-text search and the realtime engine are in Rust, not Postgres.
- **Compare with [[Langfuse]]:** Langfuse is the dominant general LLM-ops platform (acquired by ClickHouse Jan 2026, ~20k stars) and covers prompt management + datasets + evals + observability. Laminar is narrower and more opinionated about *agent* tracing specifically — the transcript view, subagent cards, and span-pill trace chat are the differentiators. Both are OTel-native, so you can ingest the same traces into either.
- **Self-host quickstart:** `git clone https://github.com/lmnr-ai/lmnr && cd lmnr && docker compose up -d`, UI on `localhost:5667`. For production: `docker-compose-full.yml`.
- **YC S24** — relatively new platform; release cadence is heavy (85 releases at capture).
