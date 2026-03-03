---
created: 2026-03-03
description: OpenTelemetry's GenAI semantic conventions are converging as the industry standard for LLM/agent tracing, with both open-source and proprietary tools adopting OTel as the wire format.
source: Research compilation from OTel docs, blogs, and tool surveys (2025)
---
# OTel GenAI semantic conventions are becoming the standard wire format for LLM agent observability

The [[OpenTelemetry]] GenAI Semantic Conventions (status: "Development", not yet Stable) define spans, events, and metrics for LLM calls, agent operations, and tool invocations. As of mid-2025, they cover agent-specific operations (`create_agent`, `execute_tool`, `invoke_agent`) and even [[MCP]] tool server tracing.

The key insight is **convergence**: proprietary platforms like [[LangSmith]] now accept OTLP traces, and [[Datadog]] natively supports GenAI semantic conventions. Picking OTel-compatible tools now avoids vendor lock-in regardless of backend choice.

**Top OTel-native open-source tools:**
- **[[Langfuse]]** (~19k⭐, MIT) — best all-around: tracing, evals, prompt management, 50+ integrations, self-hostable
- **[[Arize Phoenix]]** (~8k⭐) — OTel-native with strong eval/RAG debugging
- **[[OpenLLMetry]]** (Traceloop, ~5k⭐) — the plumbing layer whose semantic conventions became the OTel standard

**OTel's killer advantage over proprietary tracing**: tool call child spans automatically pick up existing HTTP/DB/queue instrumentations — full-stack correlation for free.

## Sources
- [OTel GenAI Semantic Conventions](https://opentelemetry.io/docs/specs/semconv/gen-ai/)
- [OTel Agent Span Conventions](https://opentelemetry.io/docs/specs/semconv/gen-ai/gen-ai-agent-spans/)
- [OTel Blog: AI Agent Observability (March 2025)](https://opentelemetry.io/blog/2025/ai-agent-observability/)
