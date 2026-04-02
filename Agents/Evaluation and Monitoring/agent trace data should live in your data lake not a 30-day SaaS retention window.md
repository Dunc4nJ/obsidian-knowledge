---
created: 2026-04-02
description: AI observability data — traces, evals, annotations — should flow into open formats in your own data lake rather than a SaaS platform with short retention, because agent conversations are durable business assets not disposable infrastructure metrics.
source: https://x.com/aparnadhinak/status/2039724128266334257
type: framework
---

## Key Takeaways

The central argument is that AI trace data is categorically different from infrastructure metrics and should not be treated the same way. Traditional observability platforms retain data for 15-30 days then delete it — designed for CPU utilization and stack traces with short useful lifespans. But [[agents fail without trace architecture because reasoning evaporates when the context window closes|agent traces are reasoning records]] — a conversation from six months ago might reveal a failure pattern you only recognize today, and high-performing session traces are training signal for your next agent iteration.

The proposed architecture has traces, evaluations, and annotations all living in open formats (Parquet/Iceberg) in your own data lake, with the observability platform syncing to the lake at minute-level intervals rather than owning the data. This is the opposite of the export model where you periodically dump from SaaS to your warehouse — exports create drift by design because the copy diverges from where annotations and evals run.

A key design principle: evals should augment trace data in place, not live alongside it in a separate system. When a domain expert marks a false positive or edits a label, that correction lands directly on the trace. This produces a "business context graph" — the queryable record of every AI decision, every assessment, and every human correction. This connects to [[the agent improvement loop is traces enriched with evals and human feedback converted into validated fixes|the agent improvement loop]] where enriched traces become the substrate for systematic fixes.

The article distinguishes two data categories every production AI system generates: **conversations** (agent-customer, agent-agent, reasoning chains) and **evaluations** (quality judgments at session or turn level). Both are first-class data, not debugging exhaust.

## External Resources

- [How context graphs turn agent traces into durable business assets](https://arize.com/blog/how-context-graphs-turn-agent-traces-into-durable-business-assets/) — Arize blog on trace durability

## Original Content

> **@aparnadhinak** (Aparna Dhinakaran) — Thu Apr 2, 2026 · 97 likes · 9 retweets · 4 replies
>
> Article: Data Architectures For Tracing Harnesses & Agents

> [!quote]- Source Material

Every AI system in production generates two categories of data: conversations, the interactions between agents and customers, between agents and other agents, the reasoning chains that drove every decision, and evaluations, quality judgments on those conversations at the session level, the turn level, or both.

This data is not debugging exhaust. It is the record of what your AI said to your customers, why it said it, and whether it was any good. Most companies treat it as disposable. That is a mistake.

#### The Monolithic Data Trap

Most observability works like this: you send your data to a SaaS platform. The platform retains it for 15 to 30 days. Then it deletes it. Your data lives in the provider's infrastructure, in a proprietary format, queryable only through their interface.

This model was designed for infrastructure metrics, CPU utilization and stack traces, data with a short useful lifespan. AI data is fundamentally different. A conversation from six months ago might reveal a failure pattern you only recognize today. The reasoning traces from your best-performing agent sessions are a training signal for your next iteration of your agents or employees. You should be able to query it through your own agents, build eval dashboards on it, build analysis, and custom pipelines. Sending this to a 30-day retention window is like writing your institutional knowledge on a whiteboard and erasing it every month.

#### What the Data Layer Should Actually Look Like

Your AI data is yours, and it should live where the rest of your business data lives.

- Standard formats in your data lake. Traces, evaluations, annotations, all in open formats like Parquet and Iceberg.

- Evals live on the data, not alongside it. Evaluations are assessments of your traces. They should augment the data directly, so you can slice results by customer segment, agent version, time window, at scale, with the tools you already use.

- No divergent copies. Continuous exports create drift by design. The moment you export, the copy diverges from the system where annotations and evals run. The data layer should be the single source of truth. Not a replica.

Annotations augment in place. When a domain expert marks a false positive or edits a label, that correction lands on the trace data. Not in a sidecar system.

*AI Common Datafabric vs Monolithic Traditional Observability — open-format lake with minute-level syncs vs daily periodic export*
![[aparnadhinak-334257-002.png]]

#### The Business Context

Automated agents handle customer interactions, support tickets, financial analysis, code generation. Employees use AI harnesses to augment their own work, drafting, researching, building. Every one of those sessions produces structured traces. Combined, the totality of agent conversations and harness usage becomes a queryable record of organizational intelligence.

We wrote earlier this year about how [agent traces are becoming durable business assets](https://arize.com/blog/how-context-graphs-turn-agent-traces-into-durable-business-assets/). The data layer is the infrastructure that makes this real. Traces flow through OpenTelemetry-based instrumentation. Within minutes, the data lands in your lake in standard formats. Evals run against it in place. Annotations enrich it. Experiments reference it.

No exports. No syncs. No divergence.

*Business context graph: customers and employees interact through networks of agents, producing structured traces*
![[aparnadhinak-334257-003.png]]

When traces, evaluations, and annotations all live in a unified, open-format layer, what emerges is a business context graph, the queryable record of every decision your AI made, every assessment of those decisions, and every human correction applied to them. It is the dataset that makes the difference between "we think the agents are working" and actually knowing.

> [!quote]- End Source Material

[Original post](https://x.com/aparnadhinak/status/2039724128266334257)
