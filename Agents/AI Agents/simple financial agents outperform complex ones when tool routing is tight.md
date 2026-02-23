---
created: 2026-02-19
description: Dexter, an open-source financial research agent, shows that reducing an agent's decision space via subagent encapsulation and keeping architectures simple produces faster, more reliable financial analysis than monolithic tool exposure.
source: https://x.com/virattt/status/2024602489929003400
type: learning
---

## Key Takeaways

The central insight is that **smaller decision spaces produce better agent behavior**. The first version of Dexter exposed all 22 API endpoints directly to the LLM. It would call the right endpoint for one ticker but forget it for another, or pass wrong parameter formats. Reducing the visible tool count to 5 (three subagents + web browse + file browse) fixed the routing failures — a principle worth applying to how [[plutus|Plutus]] structures its own tool access.

**Subagents as "meta tools"** encapsulate specialized work. Each subagent has its own inner LLM and sees only its domain-specific endpoints. The financial search subagent handles income statements, analyst estimates, insider trades. The filings reader chains two sequential LLM calls (identify filing → extract sections). Different subagents can have different internal architectures — some parallel, some sequential — while the outer LLM just routes. This maps to the [[orchestration architecture determines multi-agent investment quality|multi-agent orchestration patterns]] from the Agno investment committee, but at a more granular tool-routing level.

**The scratchpad pattern** (append-only JSONL on disk) solves both debugging and resilience. Every tool result is persisted. Crashes don't lose work. Partial runs are inspectable. When context grows too large, **context compaction** drops oldest results from the active prompt while keeping the full JSONL intact — the final answer generation step gets everything back. This is essentially the same insight behind the [[plutus-plan|Plutus plan]]'s SQLite-backed data persistence.

**Separate exploration from synthesis.** Having the same LLM both gather data and write the final answer causes anchoring bias — the answer emphasizes whatever was fetched last. Splitting into an explorer loop (decides what to look for) and a separate final-answer call (sees everything, structures around original query) eliminates this. Relevant for any analytical agent doing multi-step research.

**Structured data goes raw to the LLM** — no middleware cleaning or summarization. The model sees actual API JSON and does interpretation itself. This keeps the system simple and the model "honest" — when it cites numbers, they come from real data, not a summarization step that could lose precision.

**Evals are non-negotiable.** Virat changed two words in a tool description and Dexter started confusing quarterly vs. annual revenue. He didn't notice for three days. Now every system prompt or tool description change triggers offline eval: fresh agent instance, financial questions with expected answers, LLM-as-judge scoring 0-1, tracked in LangSmith.

**Caching strategy:** cache immutable data (SEC filings, historical financials), skip volatile data (current prices). Cache lives as human-readable JSON in `.dexter/cache/`.

## External Resources

- [Dexter repo](https://github.com/virattt/dexter) — open-source financial research agent (TypeScript)
- [Financial Datasets API](https://x.com/findatasets) — financial data provider used by Dexter (founded by the author)
- [LangSmith](https://smith.langchain.com/) — eval tracking platform referenced for offline evaluation

## Original Content

> [!quote]- Full article by @virattt (Virat Singh, Feb 19, 2026) — 708 likes, 83 RTs, 2.2K bookmarks
> 
> **How to Build a Financial Agent**
> 
> It's 4:01pm in NYC and NVIDIA just reported its earnings after market close. I open a bunch of tabs to compare earnings to analyst estimates, read the 10-K for management's forward guidance, check recent Form 4 filings for insider activity, and scan financial news sites for analyst reactions and how Mr. Market is reacting. On a good day, it's ~30 minutes of work. Two months ago, I open-sourced an agent called Dexter to do this faster. Today, Dexter does all of the above in ~30 seconds.
> 
> The system is five pieces: (1) an LLM that thinks and picks tools, (2) tools that do work, (3) external APIs for live data, (4) a scratchpad that keeps state, and (5) an eval layer to test everything offline.
> 
> Key architecture decisions: subagents as meta-tools to reduce decision space (22 endpoints → 5 visible tools), append-only JSONL scratchpad for debugging/resilience, separate LLM calls for exploration vs. final synthesis, raw structured data to the model with no middleware summarization, context compaction for long runs, and offline evals before every change.
> 
> Source: https://x.com/virattt/status/2024602489929003400
