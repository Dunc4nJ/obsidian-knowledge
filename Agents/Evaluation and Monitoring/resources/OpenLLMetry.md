---
created: 2026-03-04
source: https://github.com/traceloop/openllmetry
description: OpenTelemetry-based auto-instrumentation for LLM providers, vector DBs, and agent frameworks — the plumbing layer for vendor-neutral LLM observability
type: resource
tags: [observability, tracing, opentelemetry, llm-ops, open-source]
status: unread
---

## What it is

OpenLLMetry is a set of OpenTelemetry extensions (Apache 2.0) that auto-instruments LLM providers, vector databases, and agent frameworks. Built by Traceloop, it outputs standard OTel data that plugs into any existing observability backend. Their semantic conventions were adopted as the basis for OTel's official GenAI semantic conventions.

## Why it's interesting

This is the **plumbing layer** of the LLM observability stack. Rather than being a full platform (like [[Langfuse]]), OpenLLMetry provides the instrumentation libraries that emit standard OTel spans/metrics. If you already have Datadog, Grafana, Honeycomb, Jaeger, or any OTel-compatible backend, you can add LLM tracing with two lines of code (`pip install traceloop-sdk` + `Traceloop.init()`). No new dashboards, no new vendor — your LLM traces show up alongside your existing HTTP/DB/infra traces.

The fact that their semantic conventions became the official OTel GenAI spec means this project shaped the industry standard.

## How it works

**Quick start:**
```python
pip install traceloop-sdk

from traceloop.sdk import Traceloop
Traceloop.init()
# That's it — all LLM calls are now traced as OTel spans
```

**What it instruments:**

LLM Providers (17+): OpenAI, Anthropic, Bedrock, Cohere, Gemini, Groq, HuggingFace, IBM Watsonx, Mistral, Ollama, Replicate, SageMaker, Together AI, Vertex AI, Writer, Aleph Alpha

Vector DBs (7): Chroma, LanceDB, Marqo, Milvus, Pinecone, Qdrant, Weaviate

Frameworks (10+): LangChain, LangGraph, LlamaIndex, CrewAI, Haystack, LiteLLM, OpenAI Agents, Agno, AWS Strands, Langflow

Protocols: MCP (Model Context Protocol)

Plus everything OTel already instruments (HTTP, DB, gRPC, etc.) — so tool call child spans automatically pick up existing infrastructure instrumentation.

**Tested destinations (25+):** Traceloop, Axiom, Azure App Insights, Braintrust, Dash0, Datadog, Dynatrace, Google Cloud, Grafana, Highlight, Honeycomb, HyperDX, IBM Instana, KloudMate, Laminar, New Relic, OTel Collector, Oracle Cloud, Scorecard, ServiceNow, SigNoz, Sentry, Splunk, Tencent Cloud

**SDKs:** Python + JS/TS ([OpenLLMetry-JS](https://github.com/traceloop/openllmetry-js))

## Key links

- [GitHub (Python)](https://github.com/traceloop/openllmetry)
- [GitHub (JS/TS)](https://github.com/traceloop/openllmetry-js)
- [Docs](https://traceloop.com/docs/openllmetry/getting-started-python)
- [OTel GenAI SIG discussion](https://github.com/open-telemetry/community/blob/1c71595874e5d125ca92ec3b0e948c4325161c8a/projects/llm-semconv.md)

## Notes

- **OTel-native, not a platform**: OpenLLMetry doesn't provide dashboards or UI — it's instrumentation only. Pair it with Grafana, Jaeger, Datadog, [[Langfuse]], or any OTel backend for visualization.
- **No telemetry collected** since v0.49.2 — the SDK no longer phones home.
- **Killer advantage over proprietary tracing**: Because it's standard OTel, tool call child spans automatically inherit existing HTTP/DB/etc. instrumentations. You get full-stack correlation (LLM call → tool → DB query → HTTP request) in one trace tree for free.
- Compare with OpenLIT (similar OTel-native approach but includes its own UI/dashboard) and Langfuse (full platform that can ingest OpenLLMetry traces).
