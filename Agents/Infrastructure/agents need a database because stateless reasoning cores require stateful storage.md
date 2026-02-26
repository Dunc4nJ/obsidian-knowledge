---
created: 2026-02-25
description: Agents are a stateful control loop around a stateless reasoning core — state must live in a database you own. Owning the database unlocks context control, self-learning loops, evaluation datasets, and zero vendor dependency.
source: https://x.com/ashpreetbedi/status/2015935966268018823
type: framework
---

# Agents need a database because stateless reasoning cores require stateful storage

LLMs don't remember anything. When Claude recalls your name or references a past conversation, it's reading from stored memories injected into its context. The continuity we experience isn't a property of the LLM — it's engineering powered by a database. Agents need databases for the same reason web apps do: stateless compute requires stateful storage. The patterns aren't new; we just forgot how to use them.

## Key Takeaways

Owning the database unlocks capabilities that stateless wrappers can't touch. Full context control means deciding what goes into the context window — last 3 turns, or 10, or a summary. Smarter context management means summarizing long conversations, compressing verbose tool outputs, pruning irrelevant history, enriching with retrieved knowledge. This is what good agent engineering actually is: delivering the right context for the right response. This directly supports the context engineering principles in [[over 40 percent of agentic AI projects fail due to poor architecture not model limitations]] — specifically the 10:1 compression ratio target.

The case against third-party state is straightforward. Storing agent state in vendor APIs (like `previous_response_id`) means paying twice (API call + storage/egress), depending on their schema and roadmap, and splitting state across two places with an added network hop. You still need a database for the user session and response IDs anyway. The alternative: own the database, query it with SQL, build dashboards, plug into any observability tool.

Self-learning loops become possible with owned state. Track which responses users edited, which tool calls failed, which sessions ended in frustration. Feed this back automatically. Pull examples for few-shot prompts, run multi-turn simulations, flag low-quality responses for review — all without asking a vendor for an export.

Persistence is also the foundation for the [[seven runtime failures emerge when demo agents meet production distributed systems|seven sins of agentic software]] — specifically sin #3 (ignoring persistence). Without checkpoints, replays, and resume semantics, every run starts from zero.

## External Resources

- [Agno (open-source agent infrastructure)](https://github.com/agno-agi/agno) — database support built in, 13+ databases supported
- [Agno docs](https://docs.agno.com/introduction)

## Original Content

> [!quote]- Full article from @ashpreetbedi (Jan 26, 2026 — 644 likes, 59 RTs)
>
> **Agents Need a Database**
>
> Agents are a stateful control loop around a stateless reasoning core. The reasoning core doesn't remember messages, tool calls, user preferences, or multi-step plans. State has to live somewhere — that somewhere is a database.
>
> **What owning the database unlocks:** full context control, smarter context management, zero vendor dependency, evaluation datasets, self-learning loops.
>
> **The case against third-party state:** paying twice, split state across two places, dependent on vendor schema/roadmap/uptime. You still need a database anyway.
>
> AI engineering is just... software engineering. Agents need databases for the same reason web apps do.
>
> Source: [Original tweet](https://x.com/ashpreetbedi/status/2015935966268018823)
