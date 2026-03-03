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

> [!quote]- Source Material

> @ashpreetbedi (Ashpreet Bedi):
> Article: Agents Need a Database
>
> Agents are a stateful control loop around a stateless reasoning core.
>
> The reasoning core doesn't remember the messages it received. It doesn't remember the tool calls it made. It doesn't remember user preferences, multi-step plans, or what happened three turns ago.
>
> If the reasoning core is stateless, state has to live somewhere.
>
> That somewhere is a database.
>
> # What we want to build
>
> We want agents that:
>
> - Continue conversations across sessions
>
> - Remember user preferences, history, and context
>
> - Get better by learning from every interaction
>
> - Can be debugged when they fail
>
> - Give us structured data to evaluate and improve
>
> None of this is possible without persistent state.
>
> Here's the thing: even Claude (my fav) doesn't "remember" anything. When it recalls my name or references a past conversation, it's reading from stored memories injected into its context or searching for them at runtime. The continuity we experience isn't a property of the LLM. It's beautiful engineering powered by a database. Our agents should work the same way.
>
> We can ignore this. Most tutorials do. But then our agents forget everything between requests, can't learn from mistakes, and give us no way to debug failures or improve performance.
>
> Or we can treat state as a foundational primitive and unlock capabilities that stateless wrappers can't touch.
>
> # What owning our database unlocks
>
> - Full context control: Decide what goes into the context window. Read previous messages. Include the last 3 turns, or 10, or just a summary. Context is our moat and we control it.
>
> - Smarter context management: Summarize long conversations. Compress verbose tool outputs. Prune irrelevant history. Enrich with retrieved knowledge. This is what good agent engineering actually is: delivering the right context for the right response.
>
> - Zero vendor dependency: No egress fees. No retention costs. No "we're deprecating this API" emails. Query our own data with SQL. Build a quick dashboard, or plug into any observability tool. Our data. Our choice.
>
> - Evaluation datasets: Pull examples, build few-shot prompts, run multi-turn simulations. Flag low-quality responses for review. All without asking a vendor for an export.
>
> - Self-learning loops: Track which responses users edited. Which tool calls failed. Which sessions ended in frustration. Feed this back into the system automatically.
>
> This is how good software is built. Agents are no different.
>
> # The implementation
>
> ```python
> from agno.agent import Agent
> from agno.db.sqlite import SqliteDb
>
> agent = Agent(
>     db=SqliteDb(db_file="agent.db"),
>     add_history_to_context=True,
>     num_history_runs=3,
> )
> ```
>
> Three lines of code. The agent now persists sessions, includes conversation history, and gives us full control over our data.
>
> Need more control? It's just Python:
>
> ```python
> # Access your data directly
> history = agent.get_chat_history(session_id="session_123")
> messages = agent.get_session_messages(session_id="session_123")
> session = agent.get_session(session_id="session_123")
>
> # Long conversations? Summarize them automatically
> agent = Agent(
>     db=SqliteDb(db_file="agent.db"),
>     enable_session_summaries=True,   # Compress old context
>     store_tool_messages=False,       # Skip the bloat
> )
> ```
>
> No API calls. No export requests. No waiting for a vendor to build the feature you need. Just SQL.
>
> And this isn't SQLite-specific. Swap one import:
>
> ```python
> from agno.db.mongodb import MongoDb
> from agno.db.postgres import PostgresDb
> # ...13+ databases supported
>
> db = PostgresDb(db_url="postgresql://user:pass@localhost:5432/mydb")
> agent = Agent(db=db)
> ```
>
> SQLite for testing. Postgres for production. Our infrastructure. Our data.
>
> # The case against third-party state
>
> The industry has normalized storing our data in someone else's database.
>
> The Responses API gives us a `previous_response_id`. Managed memory services hold our context. It's convenient but there are trade-offs worth considering.
>
> We're paying twice: once for the API call, again for storage and egress. We're dependent on their schema, their export tools, their roadmap. When we need a feature, we file a ticket and wait. When they have an outage, so do we.
>
> And here's the thing: we still need a database. That `response_id`? We're storing it somewhere. The user session? That's in our system. We've just split our state across two places and added a network hop.
>
> The alternative is simple: own our database. Query it directly.
>
> # AI engineering is just... software engineering
>
> We keep discovering that AI engineering is just... software engineering.
>
> Agents need databases for the same reason web apps need databases: stateless compute requires stateful storage. The patterns aren't new. We just forgot how to use them.
>
> ---
>
> Agno is open-source infrastructure for agents. Database support is built in.
>
> - [GitHub](https://github.com/agno-agi/agno)
>
> - [Get started](https://docs.agno.com/introduction)
> date: Mon Jan 26 23:52:43 +0000 2026
> url: https://x.com/ashpreetbedi/status/2015935966268018823
> likes: 644  retweets: 59  replies: 25