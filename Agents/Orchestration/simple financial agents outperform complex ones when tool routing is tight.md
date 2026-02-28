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

*Dexter financial agent CLI processing a multi-part NVIDIA earnings query*
![[virattt-003400-001.jpg]]

## Original Content

> [!quote]- Source Material

> ---
> title: "virat on X: \"How to Build a Financial Agent\" / X"
> description: "It's 4:01pm in NYC and NVIDIA just reported its earnings after market close."
> url: "https://x.com/virattt/status/2024602489929003400"
> ---
>
> # virat on X: "How to Build a Financial Agent" / X
>
> It's 4:01pm in NYC and NVIDIA just reported its earnings after market close.
>
> I open a bunch of tabs to compare earnings to analyst estimates, read the 10-K for management's forward guidance, check recent Form 4 filings for insider activity leading up to the report, and scan financial news sites for analyst reactions and how Mr. Market is reacting.
>
> I'm sure there's a more sophisticated way to do all this, but this is my way. On a good day, it's ~30 minutes of work.
>
> Two months ago, I open-sourced an agent called Dexter to do this faster. Today, Dexter does all of the above in ~30 seconds and is better at it than I am.
>
> [
>
> ](https://x.com/virattt/article/2024602489929003400/media/2024217786361274368)
>
> Simple is beautiful. Dexter's system is just five pieces: (1) an LLM that thinks and picks tools, (2) tools that do work, (3) external APIs for live data, (4) a scratchpad that keeps state, and (5) an eval layer to test everything offline
>
> Here's what I type into Dexter:
>
> "NVIDIA just reported FY 2025 earnings. Compare reported earnings to analyst estimates from the last few days. Show insider trading activity for the quarter leading up to the report. Pull management's forward guidance from the most recent 10-K (Item 7, MD&A). What are analysts saying about the results and how did the market react?"
>
> Our NVIDIA query arrives as a user prompt. Dexter also receives a system prompt, which contains descriptions of every available tool and guidelines on how to use each tool.
>
> In the system prompt, all Dexter sees is:
>
> -   Three subagents: financial search, financial metrics, and a SEC filings reader. Each contains its own inner LLM that routes to specialized sub-tools. More on this below.
>
> -   Two direct tools: web browsing and file browsing.
>
>
> Notice how small Dexter's "decision space" is. It only sees 5 tools. This is an intentional design decision I made after a few weeks of trial and error.
>
> The first version of Dexter exposed every endpoint directly, roughly 22 in total. The LLM could see "get income statements", "get insider trades", "get analyst estimates", and a dozen others. Sometimes it worked pretty well.
>
> Until it didn't.
>
> The model would call the right endpoint for one ticker but forget to call it again for another. It would pull financial ratios when it needed income statements. It would pass the wrong date format because it was juggling too many parameter schemas at once. For complex queries requiring multiple research steps, the problems got even worse.
>
> Why did this happen? Dexter's decision space was too large.
>
> Going back to our NVIDIA query for a second: When Dexter reads our query, its LLM recognizes four distinct requests: earnings vs. estimates, insider trades, 10-K forward guidance, and market reaction. Now, instead of doing all of the fetching and computations on its own, Dexter hands this work off to its subagents.
>
> [
>
> ](https://x.com/virattt/article/2024602489929003400/media/2024186726424436737)
>
> A subagent is a "meta tool" that has its own LLM and agentic loop. When the outer LLM calls the financial search subagent with "NVIDIA earnings vs. analyst estimates and insider activity in the last quarter," it hands off the question to a smaller, specialized agent. That inner LLM sees our financial endpoints - income statements, analyst estimates, insider trades, etc. - and picks the right ones. Unlike Dexter's main LLM, this subagent is focused. It has one job: access financial data.
>
> For our NVIDIA earnings query, the financial search subagent selects analyst estimates for NVDA and insider trades for NVDA, setting date filters for the past few days. For speed, it executes these API calls in parallel.
>
> The filings reader subagent works differently. Instead of running tools in parallel, it chains two LLM calls in sequence. The first identifies which filing to grab (ticker, filing type, date range). The second extracts the sections we need. Different subagent, different architecture, same pattern: specialized agent, focused job.
>
> [
>
> ](https://x.com/virattt/article/2024602489929003400/media/2024217856024436736)
>
> Main takeaway: subagents let us encapsulate specific types of work, like fetching financial data or reading SEC filings. Subagents can be customized to be experts at the task(s) they are destined to work on. Some may have agentic loops, while others are simpler and call LLMs sequentially. The beauty is that we can build as many as we want. The outer LLM just routes tasks to the subagents and off they go.
>
> The most important design decision in this layer: structured data goes straight to the LLM with no summarization step in between. There is no middleware cleaning up the response or extracting key fields. The model sees the raw API output and does the work itself.
>
> This matters because it keeps the system simple and the model honest. Analyst estimates arrive as arrays with fields like estimated EPS, actual EPS, and report period. Insider trades come back with transaction type, shares, price per share, and filing date. When the model later writes "insider sales totaled 50,000 shares at an average price of $142," it is reading from live data, not generating from memory.
>
> For financial data, Dexter uses the Financial Datasets API (disclaimer: I am the founder of FD). For web search, it cascades through a few providers (Exa, Perplexity, Tavily) and falls back to a local browser if none are configured. For reading a specific web page, there's a lightweight HTTP fetch tool that converts HTML to clean markdown, with a full Playwright-based browser as a fallback for JavaScript-heavy pages.
>
> To save on costs, we added caching. The logic is simple: cache what's immutable, skip what isn't. SEC filings are legally immutable, so no reason to fetch them twice. Last quarter's income statement is also immutable. Today's price snapshot is not. The cache lives in .dexter/cache/ as human-readable JSON files, which makes debugging painless.
>
> As Dexter works on our task, it is calling subagents + tools and accumulating context. All of this context lands in one place: the scratchpad.
>
> The scratchpad is an append-only JSON file on disk. It is the single source of truth for everything Dexter has learned while working on our query.
>
> [
>
> ](https://x.com/virattt/article/2024602489929003400/media/2024186886609084416)
>
> Why a file and not just a variable in memory? Two reasons:
>
> 1.  Debugging. Early versions stored tool results in memory only. Dexter would give a strange answer, I'd want to inspect what it actually saw, and the data was gone. With JSONL on disk, every tool result is persisted forever. I can open the file after a run, read it line by line, and see exactly what happened.
>
> 2.  Resilience. Dexter makes network calls that can fail, and a CLI process can crash or get killed mid-run. If tool results only live in memory, a crash means starting from zero. With the scratchpad on disk, the work survives the process. It also means I can inspect partial runs: if Dexter timed out on iteration 6, I can still see what it gathered through iteration 5.
>
>
> After working on our NVIDIA query, the scratchpad now holds five results: latest financial earnings, analyst estimates, insider trades, Item 7 of the 10-K, and web search results. Roughly 15,000 tokens. Nowhere near the context limit.
>
> But imagine a bigger query: "analyze risk factors across NVIDIA's last three 10-Ks and compare how they changed." Three full risk factor sections could push past 50,000 tokens of filing text alone. This is where I hit my first real scaling wall. Without any guardrails, Dexter would stuff its entire history into the prompt, blow through the context window, and error out.
>
> The fix is context compaction: after each round of subagent and tool calls, Dexter estimates total token count. If it exceeds a threshold (e.g. 100,000), it drops the oldest tool results from the active prompt, keeping only the 5 most recent. The JSONL file on disk is never touched. Compaction is in-memory only. Dexter keeps working with a smaller window, and the full history is still there for when we need it.
>
> During the loop, the LLM is an explorer: it decides what to look for next. When it stops requesting tools, it is done working and ready to answer. When this happens, we switch to a completely separate LLM call for the final answer. This second call receives the original query plus every tool result from the scratchpad, including results that were cleared during context compaction.
>
> Why a separate call?
>
> I tried having the same LLM that does exploration also write the answer. The problem was subtle: the model would anchor on whatever it had just fetched. If the last tool call returned insider trades, the answer would lead with insider trades and bury the earnings comparison, even though earnings was the first thing I asked about.
>
> Splitting the two roles fixed this. The explorer gathers. The answer generator writes. The answer generator sees everything the explorer found and structures the response around my original question, not around whatever happened to come back last.
>
> For our NVIDIA query, the final answer includes an earnings comparison (reported vs. consensus), insider trading activity, forward-looking statements from Item 7, and a synthesis of analyst reactions. All with source URLs.
>
> [
>
> ](https://x.com/virattt/article/2024602489929003400/media/2024186990741127169)
>
> None of the above matters if the answers are wrong.
>
> This is the part I see many people skip when they are building a financial agent. To be fair, I almost skipped it myself. For the first few weeks I "evaluated" Dexter by asking it questions and reading the output. If it looked right, I moved on. Then one day I changed two words in a tool description, and Dexter started confusing quarterly and annual revenue figures. I didn't notice for three days. And that was the last time I vibed through evals.
>
> Dexter now runs evaluations offline using a dataset of financial questions paired with expected answers. Each question gets a fresh agent instance. The agent runs, produces an answer, and a separate LLM-as-judge scores it on a 0-to-1 scale. Results are logged to LangSmith for tracking over time.
>
> [
>
> ](https://x.com/virattt/article/2024602489929003400/media/2024187059590643712)
>
> Image: Eval Data
>
> The rubrics check specific facts: the right numbers, the right year, the right filing section. But they also check for contradictions, cases where the answer conflicts with known data. This catches a class of error I find genuinely problematic: Dexter called the right tool but misread the data, or a subagent picked the wrong sub-tool and Dexter's main LLM hallucinated from incomplete results. The answer reads right. The agent sounds confident. But the numbers are wrong. Without evals, these slip through.
>
> I run evals before every change to the system prompt, tool descriptions, or routing logic. You will change the system prompt dozens of times building an agent. I have. You need evals. Otherwise, you are guessing whether each change helped or hurt.
>
> My main learning from building agents over the past 3 years is to keep things simple. The hardest part of building Dexter has been deciding what Dexter should not do.
>
> What used to be 30 minutes of juggling tabs, misreading filings, and fighting pop-ups on janky financial news sites is now a 30-second task. Five tool calls, a scratchpad, and a clean final answer with sources. A simple, but powerful agentic system.
>
> If there is one thing you take from this article, I hope it’s this: prefer simple architectures and let the model do the work.
>
> Dexter code is here: