---
created: 2026-09-03
description: Databricks traced every MCP tool call across its internal agent fleet with Unity Gateway's OTel spans, pointed Genie One at the resulting trace table, and asked in plain English which errors recur, how many turns agents take to recover, and what each costs. Seven small MCP-server bugs were burning an estimated $499K/year in tokens and ~12,000 engineering hours/year of agent wait time — about $1.2M/year — because agents never fail loudly; they retry, guess, and work around the problem while the task still completes and the cost shows up as ordinary usage growth. One .split() on the wrong type cost $87K/year and took 12 turns to recover from; 49.6% of all drive_file_get calls failed. Includes a table correlating error-message quality with recovery cost (misleading errors are worse than cryptic ones on both axes), and inverts the reflexive lesson: MCP signatures are deliberately under-specified to save context tokens, so the model's guesses are reasonable and the server should coerce, default and absorb rather than crash. Find, quantify and fix took about an hour.
source: https://www.databricks.com/blog/how-we-eliminated-1-million-year-wasted-ai-agent-spend-one-hour
author: Alkis Polyzotis
type: article
tags: [data-agents, mcp, tool-design, harness-engineering, agent-observability, otel, cost-management, token-waste, databricks, genie, error-messages, traces]
---

## Key Takeaways

- **The failure mode is the finding: agents don't fail, they absorb — and that is precisely why this cost is invisible.** "When tools misbehave, the calling agent rarely fails loudly. Instead, it retries, guesses, and eventually works around the problem, quietly burning tokens and developer time the whole way." From the outside the task still completes, so the only signal is "a 10% bump in token spend that can be easily misinterpreted as usage growth." Seven small MCP-server bugs across the internal fleet came to **$499K/year in wasted tokens plus ~12,000 engineering hours/year of agent wait time**. The worst single item is the one to remember: **49.6% of all `drive_file_get` calls failed**, and nobody noticed, because the agent routed around it every time. As the closing line puts it, this is "the kind that hides inside 'usage growth' and never pages anyone."

- **The error-message-quality table is the most directly actionable artifact in the post, and its ordering is counter-intuitive.** Recovery cost tracks message quality almost linearly — self-documenting ("find_text and replace_text required") 14% repeat rate and 4.6 turns to recover; somewhat informative ("Missing required parameters: org, repo") ~30% and 4 turns; cryptic traceback ("'list' object has no attribute 'split'") 30.5% and **12.1 turns**; misleading ("unexpected keyword argument 'analysis_prompt'") 50% and **13.1 turns**. The ordering matters: **a misleading error is worse than a silent one on both axes**, because it sends the agent somewhere confidently wrong. Concretely, one `.split()` call on the wrong type cost an estimated $87K/year and 4,850 hours of agent wait time — 535 failures a day, 12 turns to recover each time — purely because the traceback "tells the agent nothing about what it did wrong."

- **The real lesson inverts the reflexive one, and it is the claim worth arguing with.** MCP tool signatures are under-specified *on purpose* — "partly for generality, and partly to save context tokens, since every parameter description costs tokens the model pays for on every call." So when a signature is vague about `fields`, the model fills the gap with a reasonable guess, and a JSON array is a reasonable guess for "a list of fields." Hence: "**The bug was not that the model called the tool incorrectly. It was that the server accepted only one of several reasonable interpretations and crashed on the rest.**" The design principle — "tools for agents should adapt to the way LLMs naturally call them," coercing the list into a string, defaulting the omitted parameter, absorbing the unexpected argument, because "an under-specified signature is a promise of flexibility, and the tool should honor that promise on the receiving end." Worth noting the vault's *other* answers to the identical token pressure point the opposite way: [[code execution with MCP cuts tool token overhead 98 percent by presenting servers as filesystem APIs instead of upfront definitions|presenting servers as filesystem APIs cuts tool-definition overhead 98%]] and [[tool search lets Claude Code lazy-load MCP tools when definitions exceed 10 percent of context|lazy-loading definitions past a context threshold]] both remove the schema from context so the agent can read the real interface, rather than keeping the vague schema and hardening the server behind it. Databricks hardens the receiver; those harden the description channel. Both are responses to "every parameter description costs tokens on every call," and a fleet probably wants both — see also [[context files beat MCP schemas for internal agents because they encode how your team actually uses each tool|context files encoding how your team actually uses each tool]] and [[MCP Best Practices|the MCP design guidance]].

- **The method is a data agent pointed at a trace table, and the data agent's contribution is not the SQL.** Unity Gateway already sits on the path of every call and automatically emits an OpenTelemetry span per MCP invocation — tool name, arguments, error, token counts, latency, and a session ID tying calls together — landing in one table with "no new instrumentation required," which is the [[learning - OTel GenAI semantic conventions are becoming the standard wire format for LLM agent observability|OTel-as-wire-format bet]] paying off. Genie One then answered the three questions in plain English: which tool errors recur most, how many turns to recover, what each costs in tokens and wall-clock. "Most of our hour went to reading those answers rather than writing queries." The screenshot is the interesting part — asked to estimate token cost per error, Genie One **defines the unit of analysis itself**, measuring "the LLM requests that occur between each error and the next successful tool call in the same session (the 'recovery window')." Operationalizing a vague question into a measurable window is the analyst move, not the SQL, and it is a more convincing demo of [[Databricks Genie pushes data agents past coding-agent baselines via specialized knowledge search, parallel thinking, and multi-LLM design|Genie]] than a benchmark.

- **This is the same result as Mercor's, arrived at independently and optimizing for something different — which is what makes the pattern credible.** [[Mercor's SkyRL recipe post-trains a 397B on 1928 expert tasks for 70 percent relative Pass@1 - and spends Steps 1-3 de-risking before any real compute|Mercor read traces before spending training compute and found harness fixes worth +5.95 points with zero training]] — "roughly what one epoch of training would have bought" — including a PowerPoint MCP tool that returned `None` on every call even when it succeeded. Databricks read traces looking for cost and found $1.2M/year. Two teams, opposite objectives (accuracy vs. spend), same method and the same class of bug: **broken tools that never announce themselves because the agent compensates**. Together with [[HALO uses an RLM to mine harness-shaped failures from agent execution traces and lift benchmarks 10-16 percentage points|HALO mining harness-shaped failures from traces for 10–16 points]] and [[Self-Harness lets a fixed LLM rewrite its own agent harness from clustered failure traces, lifting Terminal-Bench held-out pass rates up to 21 points|Self-Harness clustering failure traces to rewrite the harness for up to 21 points]], trace-mining is now a repeatable technique with four independent numbers behind it. The line that generalizes: "**The scarce, expensive step was never writing the fix. It was knowing what to fix.**"

- **Caveats: this is a vendor post and the headline number is the softest part of it.** Everything is "estimated" and annualized from a **single 24-hour window**, and the $1.2M splits into ~$499K of real token spend plus ~$700K of imputed value for 12,023 hours of *agent wait time* converted to "lost productivity" at an unstated rate — a defensible framing, but not money that was previously leaving the building. The fix is also the product: Unity Gateway is GA, the unified trace table is Beta, and the post closes by telling you to go trace your calls and ask Genie One. None of that undermines the mechanism, which costs nothing to check against your own traces, and the per-bug token figures are the part to trust. Two code snippets referenced in the article prose — the server's `.split()` handling and the JSON array the model sent — do not exist in the page source, so they could not be captured; the surrounding text states their content exactly.

## External Resources

- Source: [How we eliminated $1 million a year of wasted AI agent spend in one hour](https://www.databricks.com/blog/how-we-eliminated-1-million-year-wasted-ai-agent-spend-one-hour) — Alkis Polyzotis, Databricks Blog, 1 Sep 2026
- Prior post in the series: [Managing AI coding costs at scale](https://www.databricks.com/blog/managing-ai-coding-costs-scale) — the argument that cost management means optimizing tool use, not just model selection
- [Unity Gateway unified trace table](https://docs.databricks.com/aws/en/ai-gateway/unified-trace-table) (Beta) — the OTel span table behind the analysis · [Genie One](https://www.databricks.com/product/genie/one)

## Original Content

> [!quote]- Full blog post (Alkis Polyzotis, "How we eliminated $1 million a year of wasted AI agent spend in one hour", Databricks, 1 Sep 2026)
> Summary
>
> • Broken MCP tool calls silently cost real money. Across our agent fleet, seven small MCP-server bugs burned \~$499K/year in tokens and 12,000 eng-hours/year ($1.2M lost) because agents quietly retry instead of surfacing failures.  
> • Observe, then fix. Unity Gateway traces every MCP tool call, while Genie One lets teams surface the biggest sources of wasted AI spent using natural language. Our coding agents shipped the fixes in one hour from start to finish.  
> • Design tools for how LLMs actually use them. Models make guesses on ambiguous inputs, so tools should handle variations gracefully rather than crash on unexpected inputs.
>
> Databricks engineers rely heavily on AI agents to streamline and accelerate their work. In turn, these agents require access not only to different Foundation Models but also to MCP servers with tools that enable access to relevant artifacts (e.g., system logs, usage tables, support tickets, wikis). In a [previous blog](https://www.databricks.com/blog/managing-ai-coding-costs-scale), we shared that managing AI costs at scale requires optimizing not only model selection but also how agents use tools. In this post, we describe how we looked for cost savings in our agents' use of tools, the challenges we hit along the way, and how OTel tracing in Unity Gateway cut the path from analysis to $1.2M/year in savings to a single hour.
>
> Enabling our developers to build their agents was a huge unlock on productivity, but as usage ramped up, we also faced increasing costs. We started investigating several optimizations, and one suspicion that we had was the hidden cost of failing tool calls. Specifically, when tools misbehave, the calling agent rarely fails loudly. Instead, it retries, guesses, and eventually works around the problem, quietly burning tokens and developer time the whole way. This type of waste is dangerous: from the outside, the task still completes, and an aggregate cost dashboard may show a 10% bump in token spend that can be easily misinterpreted as usage growth. 
>
> We investigated this suspicion in our agent fleet using Unity Gateway's [tracing](https://docs.databricks.com/aws/en/ai-gateway/unified-trace-table) and [Genie One](https://www.databricks.com/product/genie/one). We found seven small bugs in our tool servers that were costing an estimated **$499K/year in wasted tokens** and about 12,000 engineering hours per year in agent wait time. Overall, this is an estimated **$1.2M/year** in lost productivity. 
>
> Finding all seven bugs, quantifying them, and fixing them took about an hour. This post describes the process we followed and what it taught us about building tools for agents.
>
> ## How to monitor AI agent and MCP activity
>
> When we first deployed AI agents widely at Databricks for coding and internal workflows, it was impossible to manage or even fully understand costs because we lacked visibility into the agents’ tool calls and overall activity. To solve this, we leveraged Unity Gateway, which automatically emits an OpenTelemetry trace for all MCP tool invocations, including the tool name, arguments, error (if any), token counts, latency, and a session ID that ties calls together. Those traces land in a single table that records exactly what our agents did over any time window. No new instrumentation was required, and the gateway already sits on the path of every call, so the data was readily available.
>
> *Unity Gateway's Traces tab: one OTel span per call, LLM and MCP side by side, with service, state, principal and execution time.*
> ![[databricks-mcp-waste-001.png]]
>
> This makes AI agent cost management more actionable, where instead of seeing only aggregate token spend, we can attribute wasted spend to specific tools, errors, and agent sessions.
>
> Now that the data is available, the next step is exploration:
>
> * Which tool errors recur the most?
> * When an agent hits one, how many turns does it take to recover?
> * What does each error cost in tokens and wall-clock wait time?
>
> Normally, the expensive part of this kind of analysis is the SQL and the schema spelunking. But with Genie One, we just pointed it at the trace table, **asked these exact questions in plain English**, and got answers back in minutes. Most of our hour went to reading those answers rather than writing queries.
>
> *The Genie One session itself: asked in plain English to estimate token cost per error, it defines a "recovery window" between each error and the next successful tool call, then returns a per-bug table of error occurrences and average LLM requests to recover.*
> ![[databricks-mcp-waste-002.png]]
>
> ## What the traces revealed: How MCP tool failures drive up AI agent costs
>
> Genie One turned a vague suspicion ("agents seem to thrash on Jira calls") into a ranked, quantified bug list in minutes. Here is an example from a single 24-hour window, showing bugs in our Jira and Google Drive/Docs tool servers:
>
> | Bug                                          | Errors/day | Annual token cost | Annual wait time | Repeat rate |
> | -------------------------------------------- | ---------- | ----------------- | ---------------- | ----------- |
> | Jira: KeyError: 'fields' (get)               | 137        | $250K             | 2,500 h          | \~30%       |
> | Jira: 'list' object has no attribute 'split' | 535        | $87K              | 4,850 h          | 30.5%       |
> | Jira: KeyError: 'fields' (search)            | 32         | $58K              | 580 h            | \~30%       |
> | GDrive: Invalid field selection              | 417        | $46K              | 2,740 h          | 54.5%       |
> | Jira: unexpected analysis\_prompt kwarg      | 121        | $42K              | 840 h            | 50.0%       |
> | GDocs: find\_text required                   | 137        | $15K              | 440 h            | 14.3%       |
> | Jira: quote\_from\_bytes() expected bytes    | 30         | $1.2K             | 73 h             | 66.7%       |
> | **Total**                                    | **1,409**  | **$499K**         | **12,023 h**     | n/a         |
>
> Take the highest-volume bug, 535 failures a day, as an example. The Jira issues.search tool takes a fields parameter, and the server did this:
>
> *[Editor's note: two code snippets appear here and after the next paragraph in the rendered article — the server's `.split(",")` handling, and the JSON array the model passed. Neither is present in the page source, so they could not be captured verbatim. The surrounding prose states their content exactly.]*
>
> It expected a comma-separated string like "key,summary,status". But an array is the semantically natural JSON type for "a list of fields," and that is what the model inferred from its background knowledge of JSON conventions and from adjacent tool calls in the same session. So it passed the structured value that a reasonable caller would:
>
> A list has no .split(), so the server raised 'list' object has no attribute 'split', a raw Python traceback that tells the agent nothing about what it did wrong. So the agent guessed again. Sometimes it retried the same list and failed the same way; sometimes it re-read the schema or fell back to trial and error. On average, it took **12 turns** to recover, and 30% of sessions hit the error more than once. One .split() call was costing an estimated $87K/year in tokens and 4,850 hours of agent wait time.
>
> The Google Drive Invalid field selection error was even more striking in volume: **49.6% of all** drive\_file\_get **calls failed**, because the model kept passing valid-looking Drive API field names (id, name, mimeType) that the tool's endpoint did not accept.
>
> ## The real lesson: How to design MCP tools for AI agents and LLMs
>
> The obvious takeaway is "write better error messages," and the data backs it up. Recovery cost tracks error-message quality almost perfectly:
>
> | Error message quality | Example                                          | Repeat rate | Avg turns to recover |
> | --------------------- | ------------------------------------------------ | ----------- | -------------------- |
> | Self-documenting      | "find\_text and replace\_text required"          | 14%         | 4.6                  |
> | Somewhat informative  | "Missing required parameters: org, repo"         | \~30%       | 4                    |
> | Cryptic traceback     | "'list' object has no attribute 'split'"         | 30.5%       | 12.1                 |
> | Misleading            | "unexpected keyword argument 'analysis\_prompt'" | 50%         | 13.1                 |
>
> But "good error messages help" is old news. The more interesting question is _why_ the model called these tools "wrong" in the first place. In most of these cases, it didn't.
>
> MCP tool signatures are often deliberately under-specified. We keep them loose on purpose: partly for generality, and partly to save context tokens, since every parameter description costs tokens the model pays for on every call. The consequence is that when a signature is vague about fields, the model fills the gap with a reasonable guess, and a JSON array is a reasonable guess for a list of fields. The bug was not that the model called the tool incorrectly. It was that the server accepted only one of several reasonable interpretations and crashed on the rest.
>
> So the design principle is the reverse of the reflexive one: **tools for agents should adapt to the way LLMs naturally call them,** e.g., coerce the list into a string, default the omitted parameter, absorb the unexpected argument, and so on. An under-specified signature is a promise of flexibility, and the tool should honor that promise on the receiving end rather than crash on the first input that doesn't match the one shape its author had in mind.
>
> ## The easy part: How we reduced wasted AI agent spend in one hour
>
> The fixes themselves were simple and are not the interesting part of this story. Once Genie One had handed us a ranked list of which errors to fix and what the model was actually sending, applying the fixes across the tool servers was a quick pass with a coding agent. The whole loop (find, quantify, fix) took about an hour.
>
> The scarce, expensive step was never writing the fix. It was knowing what to fix. Tracing plus Genie One turned that step from a research project into a question you can ask out loud.
>
> ## Closing the loop: How to continuously monitor and reduce AI agent costs
>
> As more real work shifts onto agents, silent tool failures become a first-class cost center, the kind that hides inside "usage growth" and never pages anyone. The loop for catching them is cheap and repeatable: Unity Gateway makes agent behavior observable, and Genie One makes that behavior queryable without SQL.
>
> Together, this gives teams a repeatable way to monitor AI agents, diagnose MCP tool failures, and reduce wasted AI spend. If you run agents against your own tools, do the same. Trace the calls and ask Genie One what keeps going wrong.
>
> ## Get started with Unity Gateway trace analysis with Genie One
>
> Unity Gateway is Generally Available, and you can now monitor all AI activity using the unified trace table, which is now in Beta. See [our docs](https://docs.databricks.com/aws/en/ai-gateway/unified-trace-table) on how to get started. 
