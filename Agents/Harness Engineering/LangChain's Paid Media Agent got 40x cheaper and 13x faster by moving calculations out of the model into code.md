---
created: 2026-09-16
description: LangChain's engineering write-up on its internal paid media agent. The one reproducible number is the harness result — moving calculations out of the model into Python and deleting unnecessary model calls took an early weekly-reporting workflow from 3.9M input tokens, $3 and 1,112 seconds to roughly 40x cheaper and 13x faster at 85 seconds. Six lessons follow: model for judgement not computation, one source of truth per metric, tool discovery over upfront loading (38K to 12K first-turn tokens), explicit isolation design, an analysis-to-action path that verifies its own writes, and interface-to-work fit. The business numbers (0 to 20% of pipeline, CPL down 30% while spend rose 60%) are real but not transferable, and this is also a Managed Deep Agents launch post.
source: https://x.com/langchain/status/2099543591139819742
author: LangChain (@LangChain)
type: article
tags: [harness-engineering, langchain, deep-agents, context-engineering, tool-discovery, sandbox, subagents, human-in-the-loop, slack-agents, gtm-engineering, case-study]
---

## Key Takeaways

- **The headline is an engineering number, not a marketing one: moving deterministic work out of the model made a reporting run about 40x cheaper and 13x faster — 1,112 seconds down to 85.** V1 did the naive thing and asked the model to do everything: every campaign row, keyword, pipeline record and landing-page check loaded into context, then the model computed spend, week-over-week deltas, classified campaign performance and wrote the report. On a frozen test set that cost 3.9M input tokens, just over $3, and 18.5 minutes per report — and the results were *harder to trust*, because the model recomputed the underlying numbers every run. Python now fetches data, aligns date windows, computes totals and comparisons, applies fixed rules, and writes a compact result set into the sandbox; the model only connects evidence, explains causes and recommends. Same conclusion as [[interpreter skills package deterministic agent routines as versioned TypeScript modules that the model invokes but cannot rewrite|interpreter skills the model can call but not rewrite]] and [[Shortcut compresses its spreadsheet agent context into an L1-L2-L3 cache hierarchy collapsed under one execute_code tool|Shortcut's execute_code collapse]], and the mirror image of [[Databricks traces every MCP call and finds seven tool bugs burning 1.2 million dollars a year because agents retry silently instead of failing loudly|Databricks tracing $1.2M/year of silent MCP token burn]] — the same economics seen from the failure side. Note where the hard rules live: "don't cut a top pipeline driver after one bad week" is enforced *in code, so the model cannot override it*, which is [[training beats prompting so use runtime guards not instructions|runtime guards over instructions]] applied to a business rule.

- **Lesson 3 is the vault's third independent arrival at tool discovery over upfront loading — and the first from a non-coding workload.** Pipeboard's MCP exposes 200+ ad-platform tools; even the trimmed read-only catalog spent 38,000 tokens loading names, descriptions and arguments *before the agent had read the question*. Collapsing it behind three host-side tools — search (returns up to eight candidates), read one schema, run — brought the first turn to about 12,000 tokens, 4x cheaper than loading every schema at equal judged quality, and the catalog has since nearly tripled with roughly flat context cost. That is the same argument as [[code execution with MCP cuts tool token overhead 98 percent by presenting servers as filesystem APIs instead of upfront definitions|code execution with MCP (98% overhead cut)]] and [[tool search lets Claude Code lazy-load MCP tools when definitions exceed 10 percent of context|Claude Code's tool-search threshold at 10% of context]], reached from marketing analytics rather than coding, and it rhymes with [[context files beat MCP schemas for internal agents because they encode how your team actually uses each tool|context files over MCP schemas for internal agents]]. They kept both paths rather than picking: fixed warehouse tools as a fast lane for recurring questions, plus describe-tables and run-query for everything nobody anticipated. Across 60 live runs the fixed-tool-only version answered routine questions well and *correctly reported deeper ones as unsupported* — a clean demonstration that a prebuilt tool per grouping does not scale to unanticipated questions.

- **The system prompt as a map rather than a container, with context layered by mutation rate.** Their framing is that the context window is the bottleneck, not the model, and that most apparent reasoning failures are context failures — either the model lacks the right information or irrelevant information is competing for attention. So knowledge lives in files at predictable locations and the prompt just says where: five layers ordered by how fast each changes (system prompt for role and navigation → six progressively-disclosed skills → a nineteen-page wiki → 218 live tool calls → deterministic code). The dividing line they found hardest is skills-versus-wiki, resolved by a portability test: "a skill should work at another company, whereas the wiki should not." Compare [[Basis built an agent-native monorepo by separating canonical from non-canonical context across a six-layer instruction architecture|Basis's six-layer canonical/non-canonical split]], [[progressive disclosure filters force agent selectivity over what enters context|progressive disclosure as a selectivity filter]], and [[data agents are useless without a context layer that captures business definitions and tribal knowledge|the context layer that holds business definitions and tribal knowledge]]; the OS-and-computer metaphor is the same move as [[Anthropic Managed Agents virtualizes agent components into OS-style interfaces that decouple the brain from the hands|Anthropic's OS-style component virtualization]], and the equipped-workspace story matches [[Browserbase's bb agent generalizes knowledge work through four building blocks - sandbox, credential-brokering proxy, loadable skills, and Slack|Browserbase's bb (sandbox + skills + Slack)]] and [[Stripe's Kai is a coding agent for non-engineers - one engineer shipped it on Deep Agents in a week and federated skills carried it to 83 percent weekly adoption|Stripe's Kai on Deep Agents]] almost point for point. Baking software and wiki into a sandbox snapshot cut ~10 seconds of startup, the small-scale version of [[don't build agents, build environments - Ramp bakes machine images every 30 minutes so agents go from cold to working in under a second|Ramp's 30-minute image baking]].

- **Two graphs lasted five weeks; the fix was one runtime with a capability profile per entry point.** They built a scheduled report agent (Deep Agent, sandbox, large model, PDFs) and a separate lightweight Slack loop (cheap model, read-only, no sandbox) because the user experiences looked different. Every capability then had to be built twice, features landed at different times, Slack could not process attachments for lack of a sandbox, and it could not answer follow-ups about Monday's PDFs because another graph produced them. The reframe: these are two entry points into the same analysis over the same wiki, skills, tools and source rules — so now one graph is instantiated fresh per request, with scheduled runs seeing a single `task()` tool that delegates per platform and Slack runs seeing a broader read/warehouse/campaign-ops set, all on LangSmith Deployment. This is the hosted shape of [[LangChain Deep Agents runtime builds ten production capabilities on one primitive - durable super-step checkpointing to PostgreSQL|Deep Agents' durable super-step checkpointing]], and a concrete instance of [[LangChain Deep Agents adds per-model harness profiles because each provider's prompting guide demands different tools and middleware|harness profiles as a versionable bundle]] — here profiled by caller rather than by model.

- **Isolation is design work, and subagents give you only one part of it.** Of three architectures tested on live data, separate runs per platform were simplest but worst for the workflow (multiple Slack messages, no cross-channel synthesis); parent-plus-per-platform-subagents won over one big agent because it keeps the parent's context small while each platform gets its own window. Then came the failures a separate context window does not prevent: two subagents writing to the same report location and sharing one "done" flag, so the first to finish could make the second stop without producing a report; and a subagent that could not tell whether its PDF had rendered, kept checking files, burned a pile of tokens, then tried to rebuild the PDF from scratch. The fixes were per-platform report locations and completion state, and cutting subagents to exactly three tools — read context, compute, render — with render success as the terminal condition. That is [[memory-first agents should dispatch stateless subagents for focused task execution|stateless, narrowly-scoped subagents]] arrived at empirically, on a [[Firecracker microVMs became the convergent agent runtime because containers were never a security boundary|microVM]] substrate (32 GB disk, one per thread), and it generalizes the [[LangChain deep agents require persistent memory scoped sandboxes and guardrails to move from prototype to production|scoped-sandbox-plus-guardrails]] requirement.

- **The action path includes the step most designs omit: code re-checks the platform to confirm the change actually landed.** An analyst agent that only analyzes is "ultimately a better dashboard," so the agent proposes keywords, geo-targeting changes and new search campaigns as Block Kit approval cards in the same Slack thread as the analysis that produced them; the server checks Slack user IDs so anyone can ask questions but only designated owners can edit or approve, with unauthorized requests blocked and the proposal left pending; then code applies the approved change **and queries the ad platform to verify it succeeded**. Write-access plus an approval gate is the common pattern ([[LangChain HITL gives agents four typed interrupt decision types so the harness can pause without breaking the loop|typed HITL interrupts]], [[Factory droid exec uses tiered autonomy levels to gate agent permissions from read-only to full system access|tiered autonomy gates]]); the closing verification read is what makes the loop honest, and it is usually missing. The related metric discipline is worth stealing too: rather than normalizing six platforms into one schema, they declared *which system owns which metric* — ad platforms for spend, impressions and clicks, the warehouse for leads, opportunities and pipeline — after finding ~10% of Google spend absent from the warehouse because their join used keywords and video campaigns often have none, while Meta could report that a conversion happened but not reliably whether it was "Contact Sales" or "Sign Up." Tools that would let the agent query the wrong system were removed, and unjoinable data is surfaced with its source, date window and attribution model rather than filled in. Same thesis as [[MotherDuck's Simon Spati splits semantic layer from context layer by what compiles to SQL, and argues sophistication is a cost not a default|Spati's semantic-versus-context split]] and [[LangChain's agent-first data stack scales self-service analytics 40x by making context explicit across dbt models, a semantic layer, workspace guides, and endorsements|LangChain's own agent-first data stack]].

- **Separate the engineering claims from the business claims — and read this as a Managed Deep Agents launch post.** The 40x/13x and the 38K→12K token reductions are engineering results, measured against a frozen test set and reproducible in principle by anyone who reads the [open-sourced repo](https://github.com/langchain-ai/paid-media-agent). The funnel numbers are a different kind of claim: 0 to 20% of marketing pipeline in six months, CPL down 30% from June to August while monthly spend rose about 60% (LinkedIn 40% below January), ~$5K/month saved by dropping an agency. Those depend on LangChain's market, budget, and the fact that they were starting paid media from zero with a small team, and none of them isolate the agent's contribution from simply running five paid channels competently. The CPL-down-while-spend-up combination is the genuinely non-trivial part — efficiency normally degrades as you buy into less-qualified inventory — and **the post asserts it without explaining a mechanism**. The architecture is credible, specific and shipped; the pipeline attribution is not independently verifiable. Read alongside [[Harrison Chase argues companies must own their intelligence by controlling the model-harness-context system its governance and the compounding feedback loop|Harrison Chase's own-your-intelligence argument]], since the harness-and-context ownership thesis is exactly what this post is demonstrating in-house, and [[LangChain's Better-Harness uses eval-driven hill-climbing for agent harness improvement|Better-Harness's eval-driven hill-climbing]] for the measurement discipline it implies. One drafting artifact worth noting: the article says the work "taught us five lessons" and then numbers six, and [[LangChain Deep Agents specifies long-term memory as files routed to a store namespace, making user, agent, and org scope a lambda over runtime identity|the files-as-memory primitive]] behind the wiki is never named as such.

## External Resources

- [langchain-ai/paid-media-agent](https://github.com/langchain-ai/paid-media-agent) — the open-sourced agent: ad-platform tools, paid media skills, a sample wiki, reporting and approval workflows
- [Managed Deep Agents overview](https://docs.langchain.com/langsmith/python/managed-deep-agents-overview) — the hosted product this post is promoting; handles hosting, sandboxes, Slack integration and schedules
- [GTM Engineering Live: How We Built Our Paid Media Agent](https://events.langchain.com/gtm-engineering-live-series/paid-media-agent/) — webinar, 23 September 2026 at 11am Pacific: demo, code walkthrough and design decisions
- [Deep Agents overview](https://docs.langchain.com/oss/python/deepagents/overview) — the harness used as the agent's "operating system" (files, code execution, working memory, planning, subagents)
- [LangSmith Sandboxes](https://docs.langchain.com/langsmith/sandboxes) — the isolated microVM with a 32 GB disk and shell that each run gets by default
- [LangSmith Deployment](https://docs.langchain.com/langsmith/deployment) — hosting, scaling and scheduled runs for the unified graph
- [Pipeboard](https://pipeboard.co/) — the ad-platform MCP server exposing 200+ tools that the three-tool search/read/run catalog wraps
- [Karpathy's LLM wiki gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) — the note their skills-versus-wiki split follows
- [Wiki Memory — LangChain blog](https://www.langchain.com/blog/wiki-memory) — LangChain's own prior write-up on the same pattern

## Original Content

> [!quote]- Full article — "How we built LangChain's Paid Media Agent" (@LangChain, X Article, 14 Sep 2026)
> **How we built LangChain's Paid Media Agent**
> by @LangChain — 14 September 2026 — X Article, ~4,030 words
>
>
> ## Key Takeaways
>
> - Treat agents like knowledge workers. The strongest results came from giving the agent a well-designed workspace with a sandbox, software, business context, and clear operating instructions. The system prompt became a map that helped the agent find what it needed without carrying everything in context.
>
> - Use models for judgment and code for consistency. Calculations, source-of-truth rules, and safeguards were better handled in code. That made the agent faster, cheaper, and more reliable, while the model focused on interpreting results and recommending what to do next.
>
> - Design agents around the full workflow. The agent needed to find the right tools, work within clear permissions, and move from analysis to action. That meant proposing campaign changes, routing them through human approval, and verifying that the changes were applied correctly.
>
> - Use abstractions to focus on the agent’s job. [Managed Deep Agents](https://docs.langchain.com/langsmith/python/managed-deep-agents-overview)  manages hosting, sandboxes, Slack integration, and schedules, so you can focus on the tools, context, and decision rules that make the agent useful.
>
> ---
>
> For LangChain’s first three years, our sales pipeline grew largely organically, driven by open source, content, YouTube, community, and meetups. In January, we wanted to kickstart our paid advertising program to start connecting with prospects we weren’t reaching organically, such as those in new regions and enterprise decision makers.
>
> We wanted to scale from a largely organic growth engine to five paid channels in just six months. This created new challenges for our small marketing team. We had to keep track of new campaigns launching across channels, different creative and targeting experiments, and a growing volume of performance data to understand and act upon.
>
> In order to scale and optimize, we had some technical hurdles to overcome. Each advertising platform has its own data schema, making it difficult to reconcile performance across channels. Campaign parameters also do not map cleanly to the outcomes we ultimately care about, such as sales inquiries, signups, or content downloads. As our product release cadence as a company accelerated and the number of campaigns grew, keeping track of what was running, what was working, and what to try next became increasingly difficult to manage manually.
>
> We set out to build an agent that could help manage that complexity. It would track new product announcements, draft campaigns, add keywords, test variations, and surface proposed experiments to the team for approval. Over time, it would operate as a continuous learning loop: analyze performance, make a change, observe the outcome, capture what it learned, and apply those insights for future campaigns. Our goal was to make the marketing team more productive while continuously improving campaign performance.
>
> In this post, you’ll learn how our paid media agent works, how it supports the marketing team, and what we learned about agent engineering while building it.
>
> > We’ve [open-sourced our Paid Media Agent](https://github.com/langchain-ai/paid-media-agent), so you can use it as a starting point for your own. You can also join[ GTM Engineering Live: How We Built Our Paid Media Agent](https://events.langchain.com/gtm-engineering-live-series/paid-media-agent/) on September 23 at 11am Pacific. In this webinar, we’ll demo the agent, walk through the code and design decisions, and answer questions about applying these patterns to your own agents.
>
> ## Key results
>
> - Paid media went from driving 0 to 20% of our marketing pipeline in six months.
>
> - Cost per qualified lead (CPL) fell 30% from June to August, while monthly spend rose about 60%. On LinkedIn, our largest social channel, CPL was 40% lower than it had been in January.
>
> - We saved about $5K per month by bringing analysis and reporting in-house instead of relying on an agency.
>
> - We also optimized the agent itself by moving calculations into code and removing unnecessary model calls, making an early reporting workflow about 40x cheaper and 13x faster, with runtime dropping from 18 minutes to 85 seconds.
>
> ## What we built
>
> The Paid Media Agent is a long-running agent that lives in Slack. Every Monday, it combines ad-platform data with lead and pipeline from our warehouse. It posts a summary and a branded PDF for each platform explaining what changed, why, and what the team should do next.
>
> The team can tag it in a thread to ask follow-up questions about campaigns, costs, or pipeline. It can also propose new keywords, targeting changes, ad copy, or new search campaigns based on our playbook and encoded judgement.
>
> *The Monday report as it lands in Slack: blended spend, qualified leads and blended CPL, spend-and-leads by week, spend share and a per-platform table across six ad platforms*
> ![[langchain-819742-001.jpg]]
>
> ## How we built it
>
> We built this agent around a simple principle: a coding agent is a knowledge worker.
>
> Knowledge work often involves reading files, transforming information, running analyses, and writing things down. A coding agent also does these tasks with files and a shell.
>
> We treated the agent like a new paid-media analyst. We gave it a computer, the software it needed to do the job, access to our data, and documentation about how our business works.
>
> *One graph built per request: Slack mention, Monday cron and monthly cron all enter the same parent agent, which fans out to one three-tool subagent per platform, writes into a per-thread microVM sandbox, and returns a summary plus five PDFs to the Slack thread*
> ![[langchain-819742-002.jpg]]
>
> ## The Operating System
>
> We used LangChain [Deep Agents](https://docs.langchain.com/oss/python/deepagents/overview) for our agent harness so we didn’t have to build core agent infrastructure from scratch[.](https://docs.langchain.com/oss/python/deepagents/overview) Just like an operating system, Deep Agents manages access to files, code execution, and working memory. It gives the model tools to plan work, delegate tasks to subagents, and manage context as tasks become more complex. This foundation is the agent harness. We layer our paid-media tools, skills, and business knowledge on top.
>
> ## The Computer
>
> Every run has a[ LangSmith Sandbox](https://docs.langchain.com/langsmith/sandboxes) available by default. It’s an isolated microVM with a 32 GB disk and a shell for running commands. The sandbox gives the agent a safe, isolated environment to execute code and work with files without affecting other runs or the underlying system.
>
> We equip it with pandas and DuckDB for analysis, openpyxl for spreadsheets, and WeasyPrint and Jinja2 for generating reports. Alongside that software are its working data and business knowledge, stored in Markdown across six skills and a nineteen-page wiki.
>
> To keep startup fast, we bake the software and business wiki into a snapshot, a saved image that the sandbox starts from. This reduced the average startup time by 10 seconds.
>
> > 💡 Different agents need different computers. Our content generation agent's sandbox looks more like a video editing workstation, with a headless browser, ffmpeg, media tools, and a brand book. A finance agent might need openpyxl for spreadsheets and DuckDB for heavier data processing. The job determines how you design the computer.
>
> ## Providing the right context
>
> Once the agent had a computer, the next challenge was giving it the right context. A human analyst needs to understand their role, the methods they use, the company they work for, what is happening right now, and the rules they need to follow.
>
> The naive approach is to put all of that in the system prompt. However, that would lead to a prompt that is overly long, expensive to carry into every run, and likely to go stale.
>
> A better way to think about the problem is that the context window is often the bottleneck, not the model. Many apparent reasoning failures are actually context failures. Either the model is missing the right information, or too much irrelevant information is competing for its attention.
>
> Instead of treating the prompt as the place where knowledge lives, we treat it as a map. Knowledge lives in structured files with predictable locations, and the agent loads only the context required for the task at hand.
>
> *The agent desktop: AGENTS.md for instructions, index.md for where to find things, skills/ for playbooks and templates, in/ analysis/ tmp/ out/ for work in progress, plus the company wiki and a large_tool_results/ spill area outside the workspace*
> ![[langchain-819742-003.jpg]]
>
> > 💡 The way you design the agent’s workspace deserves as much thought as the tools you give it. We found that the agent could answer questions we had never built explicit workflows for by combining what was already on its desktop. It had a playbook to guide the investigation, campaign data to work with, and libraries to analyze it. Designing that workspace became part of designing the agent itself.
>
> We split context into five layers, and describe each below (ordered by how quickly each one changes):
>
> - System prompt: Defines the agent’s role and navigation. Ours starts with a one-sentence description of the agent’s role, followed by three short sections: how to operate, where numbers come from, and how to present results. Everything else is a pointer for the agent, e.g. the playbook lives here, the wiki there, read the index first. The prompt tells the agent where to find what it needs.
>
> - Skills: Six folders of instructions that are progressively disclosed at runtime. The agent initially sees only the title and description for each.
>
> - Wiki: Nineteen pages explaining how our funnel works, what each campaign is intended to accomplish, which data source owns which number, and what decisions the team has made and why.
>
> - Live tools: Spend, settings, and pipeline change daily, so the agent fetches them at request time. We have 218 such calls. More on how we keep that from bloating context below.
>
> - Deterministic code: We use code for anything that should be consistent and reproducible, including calculations, date windows, account matching, and hard safeguards. For example, a rule preventing the agent from cutting a top pipeline driver after one bad week is enforced in code, so the model cannot override it. The hardest line to draw is between skills and the wiki. A skill explains how to do the work: read the data, run the numbers, write the report, prepare a change, and apply the playbook for interpreting paid-media performance. It contains nothing specific to our campaigns.
>
> *The five context layers drawn as nested rings around the model, ordered by how fast each one changes: who I am (system prompt), what I can do (skills), the world around me (wiki), what is true now (live tools), what must not drift (deterministic code)*
> ![[langchain-819742-004.jpg]]
>
> The wiki is everything specific to LangChain: which campaign is for awareness, which should drive demo requests, what we decided in July, and why.
>
> > 💡 A skill should ‘work at another company’, whereas the wiki should not. In other words, skills capture reusable ways of working, while the wiki contains the company-specific context those skills need to operate.
>
> This follows the pattern from Karpathy's [LLM wiki](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) note and our own [Wiki Memory](https://www.langchain.com/blog/wiki-memory).
>
> ## Unifying the agent architecture
>
> We originally built two agent graphs because the user experiences looked different:
>
> - The weekly report agent was scheduled and artifact-heavy. It used a Deep Agent, sandbox, large model, and PDF generation.
>
> - Slack needed answers in seconds, so it used a lightweight loop on a cheaper model, with Google Ads and warehouse tools, no sandbox, and read-only access.
>
> That split only lasted five weeks. Every new capability had to be implemented twice. Features reached Slack and the report at different times. Slack could not process attachments because it had no sandbox, and it could not answer follow-ups on Monday reports because those PDFs came from another graph.
>
> The mistake was treating them as two products. They are two entry points into the same analysis, backed by the same wiki, skills, tools, and source rules. We instead isolate state and capabilities for each request. Each thread gets its own sandbox and checkpoint, and each run sees only the tools it needs.
>
> Now there is one graph, instantiated fresh for every request:
>
> - Slack mentions and the Monday cron enter with different run modes.
>
> - Scheduled runs see a single tool, task(), which delegates to one subagent per platform.
>
> - Slack gets a broader set of read, warehouse, and campaign-operations tools.
>
> *Before and after the consolidation: two graphs each carrying their own copy of wiki, skills, tools and source rules, versus one graph definition instantiated with a capability profile per entry point — four tools for a Slack run, only task() for a scheduled run*
> ![[langchain-819742-005.jpg]]
>
> It is the same runtime with different capability profiles, hosted on [LangSmith Deployment,](https://docs.langchain.com/langsmith/deployment) which handles hosting, scaling and scheduled runs. And because Slack now shares the same sandboxed architecture, the agent can also open a report PDF and answer follow-up questions in the thread that produced it.
>
> > 💡 The takeaway: Use one runtime with a capability profile for each entry point. The same factory can give different users different skills and permissions.
>
> *The Managed Deep Agents stack: interface, agent harness, context, tools, sandbox and platform, with context and tools marked as the only layers you configure*
> ![[langchain-819742-006.jpg]]
>
> ## Key technical lessons
>
> Putting the agent to work taught us five lessons about getting the numbers right, answering questions we had not anticipated, and turning analysis into action.
>
> ## 1. Use the model for judgement, not computation
>
> Our first version of the weekly analysis asked the model to do everything. We loaded every campaign row, keyword, pipeline record, and landing-page check into context, then asked it to calculate spend, week-over-week changes, classify campaign performance, and write the report.
>
> It worked, but inefficiently. On our frozen test set, a single report processed about 3.9 million input tokens because the model had to read all of that raw data and repeatedly work through calculations itself. That made each run slower and more expensive, taking 1,112 seconds and costing just over $3. It also made the results harder to trust because the model was responsible for recomputing the underlying numbers every time.
>
> We found that code was better suited for deterministic work. Python now fetches the data, aligns date windows, calculates totals and comparisons, applies fixed rules, and writes a compact set of results to the sandbox. The model then focuses on the work that requires judgment: connecting the evidence, explaining likely causes, evaluating campaigns against their goals, and recommending what to do next.
>
> ## 2. Define a source of truth for each metric
>
> We had six platforms with different IDs, conversion definitions, attribution windows, and campaign hierarchies. Trying to normalize everything into one perfect schema would have added complexity without necessarily making the data more trustworthy.
>
> Instead, we defined which system should be trusted for each type of metric. The ad platforms are the source of truth for media activity such as spend, impressions, and clicks. Once someone converts, we rely on our warehouse for downstream outcomes such as leads, opportunities, and pipeline.
>
> We learned why this mattered when some Google video campaigns did not map cleanly into our warehouse. Our warehouse joined campaign data using keywords, but video campaigns do not always have keywords. As a result, about 10% of Google spend was missing from our warehouse even though Google itself had the correct spend data. Meta had the opposite limitation: it could tell us that an ad generated a conversion, but our warehouse was better at telling us what that conversion actually was, such as a “Contact Sales” request versus a “Sign Up.” Those examples reinforced why we should not expect one system to have the best answer for every metric.
>
> We encoded those source-of-truth rules into the agent. They live in the wiki, and we remove tools that would let the agent query the wrong system for a given metric. With the source boundary, conversion mapping, and campaign hierarchy defined, the agent can work across platforms without requiring one perfectly normalized schema.
>
> When data cannot be joined reliably, the agent does not try to fill in the gaps. It preserves those limitations and includes the relevant source, date window, and attribution model in its answers so the team can understand how each number was derived.
>
> > 💡 The takeaway: You do not need one perfect data model before an agent can work across systems. What matters more is defining which source is authoritative for each metric, making those rules explicit, and preserving uncertainty when the underlying data cannot be reconciled cleanly.
>
> ## 3. Let the agent discover tools instead of loading everything upfront
>
> Answering a question like "What pipeline did we get for our ad spend?" requires access to two systems. Ad platforms provide spend and clicks, while our BigQuery warehouse connects campaign activity and website conversions to qualified leads, Salesforce opportunities, and pipeline.
>
> We wanted the agent to work across both without loading hundreds of tool definitions or writing a new tool for every question.
>
> [Pipeboard's MCP](https://pipeboard.co/) exposes more than 200 ad-platform tools. Back in June, even our smaller read-only catalog required 38,000 tokens just to load the available tool names, descriptions, and arguments before the agent had read the user’s question. Most of that context was irrelevant to any individual request.
>
> Our warehouse had a related problem. We had built fixed queries for recurring questions like pipeline by campaign or conversions by ad group. But each new way of grouping the data, such as pipeline by individual sales opportunity, required another dedicated tool.
>
> We solved both problems by giving the agent a small interface for finding what it needs.
>
> Pipeboard's catalog sits behind three tools:
>
> 1. Search: Finds up to eight tools based on the question.
>
> 2. Read: Loads the full schema only for the selected tool.
>
> 3. Run: Executes that tool through our server. Campaign writes use a separate approval-gated path.
>
> *The tool catalog: 218 tools collapse into three host-side operations the agent actually sees — search, read one schema, run*
> ![[langchain-819742-007.jpg]]
>
> For the warehouse, we added two flexible tools:
>
> 1. Describe the available tables and fields.
>
> 2. Run an analytical query.
>
> The agent can inspect the schema and compose the query required for the question instead of depending on a prebuilt tool for every possible grouping.
>
> The catalog brought the first turn down to about 12,000 tokens. In our comparison, it was 4x cheaper than loading every schema while maintaining the same judged quality. The catalog has nearly tripled since then, while its context cost has stayed roughly consistent.
>
> We tested fixed warehouse tools, the query interface, and both together across 60 live runs. Fixed tools worked well for routine questions but correctly reported deeper questions as unsupported. Both versions with the query interface answered all the analytical questions.
>
> We kept both approaches. Fixed tools provide a fast path for common questions, while the query interface handles questions we did not anticipate.
>
> > 💡 The takeaway: Give the agent a way to find and query capabilities on demand instead of putting every tool into context upfront.
>
> ## 4. Design isolation explicitly
>
> Once we moved to a shared runtime, we had another challenge: how could the agent analyze five platforms without putting every platform’s data into one context window?
>
> We tested three architectures on live data:
>
> 1. One isolated run per platform.
>
> 2. One agent handling every platform.
>
> 3. A parent agent delegating to one subagent per platform.
>
> Separate runs were the simplest architecture, but they performed worst for the actual workflow. Each run saw only one platform, so the system produced multiple Slack messages and struggled to synthesize performance across channels.
>
> Both consolidated approaches produced a single output with cross-platform synthesis. We ultimately chose the parent-plus-subagents architecture because it kept the parent’s context small while giving each platform its own context window for platform-specific data and caveats.
>
> But separate context windows did not automatically give us full isolation. We still had to design it.
>
> For example:
>
> - One platform could accidentally suppress another. Two subagents were writing reports to the same location and sharing the same “done” flag. Once the first finished, the second could mistake that state for its own and stop without producing a report. We fixed this by giving each platform its own report location and completion state.
>
> - A subagent could get stuck trying to verify its own work. When one subagent could not determine whether its PDF had rendered, it kept checking files, burned a ton of tokens, and eventually tried to build the PDF from scratch. Subagents now get only three tools: read context, compute, and render. If render succeeds, the job is done.
>
> A subagent gives you a separate context window. The rest of the isolation model is up to you. You still need to define which tools it can use, what files and state it can access, what it must return, and how failures are handled.
>
> ## 5. Give the agent a path from analysis to action
>
> An agent that only analyzes performance is ultimately a better dashboard. We wanted the agent to help the team act on what it found.
>
> It can propose changes directly in Slack, such as adding a keyword, updating geographic targeting, or creating a new search campaign.
>
> Giving the agent the ability to take action also introduced a new requirement: permissions.
>
> Teams outside paid media can use the agent to ask questions about campaign performance and pipeline, but only designated team members can edit or approve campaign changes. The server checks Slack user IDs before accepting either action. Requests from anyone else are blocked, and the proposal remains pending.
>
> Each proposed change appears in a Slack approval card built with Block Kit. Authorized reviewers can compare the current and proposed values, make edits, and approve the final plan. Code then applies the approved change and checks the ad platform to confirm it succeeded.
>
> *The Block Kit approval card for a new Google Search campaign: budget, locations and landing page, two ad groups with keywords and ad copy, an explicit locked-safe-defaults list (campaign created paused), a stated approval boundary, and Approve / Edit / Cancel buttons*
> ![[langchain-819742-008.jpg]]
>
> This gave us a useful separation of responsibilities. The agent can analyze performance and recommend an action, but a human controls whether that action is actually taken.
>
> > 💡 The takeaway: Closing the loop requires more than write access. Give the agent a clear action path with permissions, approvals, and verification built in.
>
> ## 6. Match the interface to the work
>
> Slack worked well as the first interface because the approval card could live in the same thread as the analysis and discussion that led to it. People across teams could ask questions and weigh in, while campaign owners still controlled which changes were actually applied.
>
> That approach works best for relatively focused decisions. As the agent started handling more complex work, such as campaigns with many ad groups and creatives, bulk edits, or plans that needed several rounds of revision, Slack became harder to use as the primary workspace.
>
> We are moving those more complex workflows into a dedicated interface built around the agent, while keeping Slack as a lightweight place to ask questions, review recommendations, and approve changes. More on that in a future post.
>
> ## What we’d take into the next build
>
> We wanted an agent that could handle questions we hadn’t anticipated, produce numbers we could verify, and act on what it found. These are the design principles we would carry into another agent:
>
> - Equip the agent like a hire. Give it a sandbox, useful libraries, access to the right data, and clear documentation. A well-designed workspace lets the agent investigate new questions without requiring a dedicated workflow for each one.
>
> - Separate reusable instructions from company knowledge. Skills explain how to do the work, the wiki explains the business, and live tools provide current information. Keeping those layers separate makes each one easier to update without growing the system prompt.
>
> - Use code for work that should be reproducible. Calculations, comparisons, and hard rules belong in code. The model can then focus on interpreting the results and deciding what they mean.
>
> - Design boundaries explicitly. Subagents still need clear rules around which tools, files, and state they can access, what they should return, and how failures are handled. A separate context window is only one part of isolation.
>
> - Optimize for whether the agent can finish the job. Reducing tokens, cost, and latency matters, but not if it makes the agent less capable. We found it more useful to evaluate those metrics alongside completion rate and answer quality.
>
> - Let real usage show you where integrations need improvement. The questions the agent repeatedly struggles to answer reveal where cleaner joins, better definitions, or dedicated tools are worth building.
>
> ## What’s next
>
> Today, the agent primarily responds to scheduled runs and requests from the team. We want it to become more proactive by continuously monitoring campaign performance, surfacing changes that deserve attention, and proposing new experiments and optimizations for the team to review.
>
> The bigger opportunity is to connect those learnings across GTM. Campaign engagement can inform how sales follows up, while pipeline progression, sales conversations, and deal outcomes can improve our understanding of the ideal customer and influence the next campaign.
>
> Over time, we want our GTM agents to contribute to the same shared knowledge and playbooks so that what one part of the organization learns can improve targeting, messaging, and experimentation across the rest of the funnel.
>
> ## Build on what we learned
>
> Join[ GTM Engineering Live: How We Built Our Paid Media Agent](https://events.langchain.com/gtm-engineering-live-series/paid-media-agent/) on September 23 at 11am Pacific. In this webinar, we’ll demo the agent, walk through the code and design decisions, and answer questions about applying these patterns to your own agents.
>
> You can also bring this paid media agent to your own team. We’ve [open sourced](https://github.com/langchain-ai/paid-media-agent) it, including the ad-platform tools, paid media skills, a sample wiki, reporting, and approval workflows. Connect your accounts, give it your company’s context, and deploy it to Slack in one command with [Managed Deep Agents](https://docs.langchain.com/langsmith/python/managed-deep-agents-overview).
>
> Engagement: 231 likes | 33 retweets | 15 replies
> [Original article](https://x.com/langchain/status/2099543591139819742)
