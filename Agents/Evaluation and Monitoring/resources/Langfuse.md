---
created: 2026-03-04
source: https://github.com/langfuse/langfuse
description: Open-source LLM engineering platform for observability, tracing, evals, prompt management, and datasets — now owned by ClickHouse
type: resource
tags: [observability, tracing, evals, llm-ops, open-source]
status: unread
---

## What it is

Langfuse is an open-source (MIT) LLM engineering platform for collaboratively developing, monitoring, evaluating, and debugging AI applications. Self-hostable on ClickHouse, with a managed cloud option (50k free traces/month).

## Why it's interesting

Dominant open-source option in the LLM observability space — 20k+ GitHub stars, 26M+ monthly SDK installs, 2,000+ paying customers. Acquired by ClickHouse in January 2026 as part of their $400M Series D at $15B valuation, signaling that LLM observability is becoming core infrastructure. OTel-native, so it avoids vendor lock-in — traces can flow to any OTel-compatible backend.

## Core features

- **LLM Application Observability**: Distributed tracing for LLM calls, retrieval, embedding, agent actions. Inspect and debug complex logs and user sessions.
- **Prompt Management**: Centralized version control and collaborative iteration on prompts. Server+client caching means no added latency.
- **Evaluations**: LLM-as-a-judge, user feedback collection, manual labeling, custom eval pipelines via APIs/SDKs.
- **Datasets**: Test sets and benchmarks for pre-deployment testing, structured experiments, continuous improvement.
- **LLM Playground**: Test and iterate on prompts/model configs. Jump from a bad trace directly into the playground.
- **Cost & Token Tracking**: Per-trace cost attribution, token usage analytics.
- **Comprehensive API**: OpenAPI spec, Postman collection, typed SDKs for Python and JS/TS.

## Integrations (80+)

LLM providers: OpenAI, Anthropic, Bedrock, Vertex AI, Cohere, Groq, Ollama, LiteLLM (100+ LLMs)
Frameworks: LangChain, LangGraph, LlamaIndex, Haystack, Vercel AI SDK, Mastra, DSPy, Instructor, CrewAI
Ingestion: OpenTelemetry native, plus direct SDK instrumentation

## Deployment options

- **Local**: `docker compose up` (5 minutes)
- **VM**: Docker Compose on a single VM
- **Kubernetes**: Helm chart (preferred for production)
- **Terraform**: AWS, Azure, GCP templates
- **Managed**: [cloud.langfuse.com](https://cloud.langfuse.com)

## Key links

- [GitHub](https://github.com/langfuse/langfuse)
- [Docs](https://langfuse.com/docs)
- [Demo](https://langfuse.com/docs/demo)
- [Self-hosting guide](https://langfuse.com/self-hosting)

## Notes

- **ClickHouse acquisition (Jan 2026)**: Langfuse is now part of ClickHouse Inc. This likely means deeper ClickHouse integration and long-term maintenance backing, but worth watching for license or strategy changes.
- Compare with [[OpenLLMetry]] (lower-level OTel instrumentation layer — Langfuse can ingest OpenLLMetry traces), [[Anthropic Sandbox Runtime]] (different concern: sandboxing vs observability), and commercial alternatives like LangSmith (LangChain-locked) and Braintrust (eval-focused).
- Battle-tested at scale — used by teams running millions of traces/month.
