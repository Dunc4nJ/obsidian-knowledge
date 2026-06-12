---
created: 2026-06-12
description: Peter Wang explains how Shortcut — the spreadsheet agent deployed in 3 of the 4 largest multistrategy hedge funds — wins on accuracy by treating its context as a faithful compression of the task distribution. The system prompt, tools, and skills together form an L1-L2-L3 cache hierarchy reachable from a single execute_code tool; bread-and-butter cell read/write live in L1, gotcha-aware English specs (pivot tables, charts, conditional formatting) sit in L2 fetched via console.log, and the entire 70k-line raw Office.js/SpreadJS API sits in L3 minable by a ~100-line grep skill.
source: https://x.com/BrainsAndTennis/status/2065190286519906657
type: framework
---

## Key Takeaways

- **A good vertical agent is a faithful compression of its task distribution.** Once the model is fixed, accuracy is purely a function of context quality, and the user's request mix is long-tailed — bread-and-butter operations dominate every session, a handful of crucial-but-occasional capabilities show up a few times, and a rare long tail still has to work. The objective is sharper than "have everything available": *minimize context spent per task, averaged over the distribution*. Bloated context buries the signal; missing context forces guessing — both cost accuracy, and accuracy is what's being sold (a 99% task is worth ~10x a 95% task). This is the same problem [[hermes-agent-prioritizes-prompt-caching-stability-by-keeping-hot-memory-tiny-and-pushing-everything-else-to-tool-based-retrieval|Hermes solves for agent memory]] by keeping a tiny hot tier and pushing everything else to retrieval, and it generalizes the [[the harness is everything and agent performance comes from environment design not model capability|"harness is everything"]] thesis to context budgeting specifically.

- **Build the context as an L1 / L2 / L3 cache hierarchy.** L1 is always-resident in the system prompt (the 80% case — read/write cell ranges and the `execute_code` contract, on the order of a few hundred lines). L2 is curated English specs reachable in one discovery step (pivot tables, charts, data validation, conditional formatting — the 15%, ~50 lines of pointers in the prompt, specs themselves loaded via `console.log(general.getPivotTableInfo())`). L3 is the complete raw API surface (~70k lines of Office.js or SpreadJS dumped to disk) plus a ~100-line skill teaching the agent the 3-6 greps it needs to find any signature. Each tier trades information compression against discovery cost; the craft is placing each capability where total cost across the distribution is minimized. This mirrors CPU cache design and reads as a structured version of the [[Context tax compounds through cache misses bloated tools and unbudgeted output tokens|context-tax cache-miss framing]].

- **All three tiers are reached through a single `execute_code` tool — not 30 specialized tools.** Shortcut has no `read_range`, `write_range`, or `make_chart` tool. The agent writes TypeScript; the code calls Shortcut's functions; the functions touch the sheet. Model accuracy degrades as tool count grows (more schema in the prompt, more overlapping responsibilities, more ways to pick the wrong one), so the substrate question is settled before the hierarchy question. Codex and Claude Code ship ~30 tools, Pi ships 7 — when popular agents disagree 4x on tool count there is no agreed-on principle, and Shortcut's choice is the same bet [[Cloudflare Dynamic Workers sandbox AI-generated code in V8 isolates 100x faster than containers|Cloudflare's Code Mode SDK]] makes when it wraps an MCP server's entire surface with one `code()` tool (cutting token usage 81%). One tool collapses every decision into "write code" and lets L1/L2/L3 differ only in *how hard it was to find the function* — not in tool affordance.

- **L1's craft is feature-engineered wrappers that compress information losslessly *and* report consequences.** A `getCellRange("Sheet1!A1:D200")` doesn't dump 200 rows — it does three things at once: (1) **formula aliasing** — normalize each formula to R1C1 form so `=A2*B2` and `=A3*B3` both become `=RC[-2]*RC[-1]`, count patterns, and any pattern appearing >10 times collapses to a `F1`-style alias plus one legend line; (2) **free row/column context** — scan leftward for row labels and upward for the header row (voted by which nearby row has the most text cells) so a `C5:E20` read carries `Region | Q1 | Q2` and `North America | …` without the agent asking; (3) **style compression** — group cells by identical style, collapse each group to its connected range, print one line per group with range, count, and a compact description. Six hundred formulas become one legend line; four hundred styled cells become two lines; the table is delivered losslessly in a fraction of the tokens.

- **Writing cells returns a structured, grouped, sampled, triaged diff.** After `execute_code` runs, the agent gets a `--- CELL DIFF SUMMARY ---` artifact: changed cells grouped by sheet and row with column counts, only a deterministic sample of rows/cells per section is printed with `… and N more rows` tallies, and a separate **"Cells that need review"** section pulls out anything suspicious — `#REF!`, untagged hardcoded numbers, hardcoded numbers buried in formulas, implausibly large percentages — with the worst offenders flagged `MUST FIX`. Two hundred writes become a handful, and a stray `#REF!` in row 57 that would vanish in a green wall is surfaced at the top. The feedback loop isn't "here's what changed," it's "here's what changed, and here's the part you probably got wrong" — a built-in linter on the agent's own edits, the same integrated-feedback principle [[the harness is everything and agent performance comes from environment design not model capability|harness design over raw bash tools]] argues for.

- **L2 specs are hand-written prose, not type signatures.** Each curated capability — pivot tables, charts, conditional formatting, data validation — is a few hundred lines of English teaching the canonical recipe in the right order, including the gotchas the raw API will never surface (e.g. for pivots: you *must* `suspendLayout()` / `resumeLayout()` around a batch of changes or the table rebuilds on every call; a value field's aggregation has to be passed as the raw integer `8` for sum because the friendly enum doesn't exist at runtime). Zero token cost until needed — one `console.log(general.getPivotTableInfo())` is the entire discovery miss. This is the same pattern OpenAI and Anthropic codified as platform features: [[OpenAI tool search dynamically loads deferred tools into context preserving cache while cutting token cost and latency|deferred tools that lazy-load schemas on demand]] — but Shortcut implements it inside one tool so it isn't locked to any vendor's loader.

- **L3 is the raw 70k-line API tome plus a ~100-line skill that teaches grep recipes.** The complete Office.js (Excel plugin) or SpreadJS (web) surface is dumped to disk, completely unusable as prompt context. The skill says: here's the structure, here's how each method and type entry is shaped, here's the grep recipe for each kind of question (`grep -n '"charts.add"' api-reference.json -A 5` to find a method, `grep -n '"pivots\.' api-reference.json | head` to list a namespace, `grep -n '"isEnum": true' api-reference.json -B2 -A10` to enumerate enums). With it the agent goes from "tens of thousands of lines I can't read" to "the 3-6 greps that surface exactly the signature I need." The system prompt makes the escape hatch explicit ("NEVER guess — read the docs in FULL"), so a long-tail request like "set the chart's secondary axis to log scale and recolor just the third series" never dead-ends. The agent is never stuck. This is the [[the bitter lesson of agent harnesses is your helpers are abstractions too - Browser-Use ships a 600-line CDP and SKILL.md harness|600-line CDP + SKILL.md]] pattern applied to a private API tome.

- **The prompt budget mirrors the frequency curve.** A few hundred lines on L1 (always-resident, fought hardest to keep tight). ~50 lines on L2 (a curated allowlist of "blessed" methods plus pointers to `getXInfo(...)` specs — not the specs themselves). ~5 lines on L3 (the skill's name and description, plus scattered references). The 70k-line raw reference never touches the prompt. Most of the budget on the 80% case, a little signposting for the 15%, almost nothing on the long tail — the cache-hierarchy framing's prediction shows up directly in the system prompt's shape.

- **The hierarchy moves with model strength but never disappears.** As models improve, yesterday's L3 becomes tomorrow's L2 and yesterday's L2 collapses into L1 — the agent's responsibility expands outward, tiers slide down a level. But the hierarchy itself survives because context is always scarce relative to everything that could go in it, and noise will always cost accuracy. Bigger context windows tempt people to paste more in; the better instinct is the one CPUs settled on decades ago: summaries in cache, details on demand, the raw substrate as last resort. This is the same drift [[Cursor strips guardrails and adds dynamic context as models improve, inverting the harness's job|Cursor exploits by stripping guardrails as models improve]] — the harness shape changes, the harness doesn't go away.

## Why this matters

This is the first public, end-to-end walkthrough of how Shortcut — the agent already deployed inside 3 of the 4 largest multistrategy hedge funds, where being wrong is expensive and nobody grades on a curve — actually builds its context. Most agent-building literature stops at the while-loop. Peter's framing makes three contributions that transfer cleanly to any vertical domain:

1. **A budgeting principle, not a recipe.** "Faithful compression of the task distribution" gives a single optimization objective for context engineering — minimize tokens-per-task averaged over the user's mix — that subsumes the usual prompt-vs-tool, schema-vs-prose, and curation-vs-completeness debates. The L1/L2/L3 placement question becomes computable in principle (which tier gives the lowest expected cost for this capability given how often it's used and how much it costs at each tier).
2. **A substrate choice that closes the tool-count debate.** Single `execute_code` plus tiered API surface dominates the multi-tool architecture on every axis Shortcut measured — fewer tokens in the prompt, no overlapping-tool confusion, full expressive power of a programming language for composition, and L1/L2/L3 reachable from one place. The same pattern is independently converging at Cloudflare (Code Mode SDK) and inside Anthropic's deferred-tools / OpenAI's `tool_search` features.
3. **A worked example of L1 craftsmanship.** The `getCellRange` compression (formula aliasing + free header context + style grouping) and the `setCell` diff (sampled, grouped, triaged with `MUST FIX` flags) are concrete templates anyone can copy for their own L1 wrappers: brutal token efficiency, structural feedback, anomaly triage at the source. The lesson — *spend disproportionate effort on L1 because the agent pays that cost on every task* — is the practical inversion of "premature optimization."

The framing also makes Shortcut's prior public work legible as a coherent program: [[predict-RLM uses GEPA to recursively optimize agent skills reaching SpreadsheetBench top-5 as open source|predict-RLM]] and [[Predict-RLM with RLM-GEPA achieves new AppWorld SOTA by optimizing the skill instead of the harness|RLM-GEPA]] are the optimizer that searches *over* the L1/L2 specs once the hierarchy is in place; [[RLM subagents need structured outputs not free-text to avoid losing the plot at fan-in - fast-rlm validates every FINAL|fast-rlm]] enforces structure at fan-in for the same reason the L1 read function returns structured compression instead of free-text dumps. The thesis underneath is consistent across all three releases: the model is fixed, the win is engineering the surface it sees.

## External Resources

- [Building a Good Vertical Agent (X article by Peter Wang)](https://x.com/BrainsAndTennis/status/2065190286519906657) — the source post, an X long-form article
- [Shortcut](https://www.tryshortcut.ai/) — the spreadsheet agent Peter has spent a year building
- [Claude deferred tools reference](https://platform.claude.com/docs/en/agents-and-tools/tool-use/tool-reference) — vendor-side analog of L2 lazy-loading; Peter cites this explicitly as "the same idea"
- [Office.js Excel API](https://learn.microsoft.com/en-us/javascript/api/excel) — the L3 substrate for the Excel plugin variant of Shortcut
- [SpreadJS API](https://www.grapecity.com/spreadjs/docs/v17/online/Sheets.html) — the L3 substrate for the web variant of Shortcut

## Original Content

> @BrainsAndTennis (Peter Wang) — Thu Jun 11, 2026 21:51 UTC
>
> 📰 Building a Good Vertical Agent
>
> How do you build an agent that actually performs in a domain — one customers pick because it's better?
>
> The basics have been standardized over the past year: an agent is a while-loop around a model that calls tools until the task is done. Give it a filesystem, give it a shell, and let it do most things through that. You can write it in an afternoon, and most people have. Everyone can build an agent — it really isn't that hard, and, as I'll spell out, it isn't that deep either. What separates a good one from a toy isn't cleverness; it's a real understanding of your domain and the patience to do some tedious, careful work in the few places that matter.
>
> I've spent almost a year now building the Shortcut agent, which is widely considered the most accurate spreadsheet agent around — it's deployed inside three of the largest four multistrategy hedge funds, where being wrong is expensive and nobody grades on a curve. We don't have Microsoft's or Anthropic's distribution. What we have is that the agent is right more often, and in this domain that has been the single most compelling reason customers pick us. So agent performance is the question I think about all day.
>
> And here's the gap I keep running into: plenty is written about building agents, but few about building good ones. Look at how much the field varies on something as basic as tool count — Codex and Claude Code ship ~30 tools each; Pi ships 7. When popular agents disagree 4x on the most basic design question, it's a tell: there's no agreed-on principle. So I'm sharing mine, from a year of building one, to demystify the process for anyone writing their own.
>
> Here it is: a good agent is a faithful compression of its task distribution. The rest of this is just what that means, and what it forces you to build.
>
> ## Context as a layered cache
>
> Assume you don't own the environment and you didn't train the model. Then three things are yours to design — the system prompt, the tools, and the artifacts (skills, curated docs, references) — and they're all the same thing: the agent's context.
>
> So the game is simple to state. With the model fixed, accuracy is a function of context quality: bloated context buries the signal, missing context forces guessing, and both cost you accuracy. And accuracy is what you're selling — the relationship isn't linear, a task that scores 99% is worth 10x more than one that scores 95%.
>
> But your users don't bring you a uniform distribution of problems to solve. They bring you a long tail:
>
> ```markdown
>   how often
>      |
>      | ████
>      | ████
>      | ████
>      | ████
>      | ████
>      | ████
>      | ████
>      | ████
>      | ████
>      | ████ ▓▓▓▓
>      | ████ ▓▓▓▓ ░░░░ ░░░░ ░░░░ ░░░░ ░░░░ ░░░░ ░░░░
>      +----------------------------------------------------> task variety
>
>    ████  bread-and-butter        the bulk of every session
>    ▓▓▓▓  crucial-but-occasional  a handful of times a session
>    ░░░░  the long tail           each one rare — but there are many,
>                                  and each still has to work
> ```
>
> The agent has to handle all of it. But it cannot hold the union of everything in context at once — that's the bloated-prompt failure mode. So the real objective is sharper than "have everything available": minimize the context spent per task, averaged over the task distribution.
>
> This is exactly the problem a CPU faces. A program might touch gigabytes of data, but the storage right next to the processor is tiny — so computers stack memory in tiers: a small, instant cache (L1), bigger-and-slower ones below it (L2, L3), then main memory and disk. It works because access is long-tailed too: keep the hot set in the fast tier, reach down to the slow tiers only for the rare stuff. A "cache miss" is when what you need isn't in the fast tier and you pay to fetch it from a slower one — exactly the cost you're avoiding on the common path.
>
> Agents should have the same structure. Build your context as L1 / L2 / L3.
>
> ```markdown
>        +---------------------------------------------+
>   L1   |  ALWAYS RESIDENT - tiny, instant.           |
>        |  The 80%. Lives in the system prompt.       |
>        +---------------------------------------------+
>                   |  miss -> one cheap call
>                   v
>        +---------------------------------------------+
>   L2   |  ON DEMAND - curated English specs.         |
>        |  The next ~15%. One discovery step to load. |
>        +---------------------------------------------+
>                   |  miss -> read the skill, then search
>                   v
>        +---------------------------------------------+
>   L3   |  ESCAPE HATCH - the raw API tome.           |
>        |  The long tail. 3-6 grep calls to mine.     |
>        +---------------------------------------------+
> ```
>
> Almost every optimization trades compression of information against speed of discovery. Put something in L1 and it's instant, but it costs prompt tokens on every single task whether it's used or not. Push it to L3 and it costs nothing until needed — but then it costs several tool calls to find. Your job is to place each capability at the tier that minimizes total cost across the distribution. That's the whole craft. Let me make it concrete with the domain I know best.
>
> ## Aside: one tool, not thirty
>
> Before the hierarchy, the substrate. Every spreadsheet capability I'm about to describe — every read, every write, every curated lookup — is code executed under a single tool.
>
> ```typescript
> async function execute() {
>   const data = await sheet.getCellRange("Sheet1!A1:D200");
>   // ...read, compute, write...
> }
> ```
>
> The agent writes code; the code calls our functions; the functions touch the sheet. There is no read_range tool, no write_range tool, no make_chart tool. There is one tool, and the API lives inside the code.
>
> Why? Because model accuracy degrades as you add tools. That's been consistent in our own experiments. Every tool you add is more schema in the prompt, more surface to confuse, more ways to pick the wrong one, especially if the tools occupy overlapping responsibilities. A single execute_code tool collapses all of that into one decision — write code — and lets the model compose capabilities with the full expressive power of a programming language or DSL instead of stitching together rigid tool calls (more on this in a future post).
>
> This matters for the hierarchy because it means all three cache tiers are reachable from the same place: the model is always writing code, and L1/L2/L3 are just which functions it knows it can call, and how much work it had to do to find them.
>
> ## L1 — the bread and butter: reading and writing cells
>
> This is the 80%. If reading and writing cell ranges isn't excellent, nothing else matters. So this is where we've spent absurd, disproportionate effort. Look at what a single getCellRange actually does.
>
> Reading a range is an act of compression
>
> Reading a 200-row revenue table:
>
> ```markdown
> Common formulas are abbreviated like F1, F2, etc.
>
> A2:North | B2:1200 | C2:9.99 | D2:11988(F1)
> A3:South | B3:840  | C3:9.99 | D3:8391.6(F1)
> A4:West  | B4:1500 | C4:9.99 | D4:14985(F1)
> ... (196 more rows, each one line) ...
>
> =F1 -> =RC[-2]*RC[-1]
>
> --- Style patterns ---
> D2:D201: 200 cells (numbers)
>   → numberFormat:#,##0.00, font.color:#1A7F37
> A2:A201: 200 cells (text)
>   → font.bold:true
>
> --- Context from cells above ---
> A1:Region | B1:Units | C1:Price | D1:Revenue
> ```
>
> Three things are happening.
>
> First, formula aliasing. A 500-row column of =A2*B2, =A3*B3, … is 500 near-identical formulas. We normalize each formula to R1C1 form — so =A2*B2 and =A3*B3 both become =RC[-2]*RC[-1] — count the patterns, and any pattern that appears more than ten times collapses to a short alias like F1. The model sees F1 repeated plus one legend line, instead of 500 formulas. Big token savings, zero information loss.
>
> Second, free row and column context. When you read C5:E20, what do those bare numbers mean? We scan leftward for the row labels and upward for the header row (picking the header by voting on which nearby row has the most text cells) and attach them, so the model gets Region | Q1 | Q2 and North America | … for free and never has to guess what a grid of numbers represents.
>
> Third, style compression. Formatting is information too — a bold red cell with a 0.00% number format is telling you something — but listing the full style of every cell would swamp the values. So we group cells by identical style, collapse each group to its connected range, and print one line per group: the range, the cell count, and a compact description.
>
> Six hundred formulas became one legend line. Four hundred styled cells became two lines. And the header row the model never explicitly asked for is right there at the bottom. That's the whole table, losslessly, in a fraction of the tokens a raw dump would cost. Every one of these is the compression-vs-discovery tradeoff, won decisively for the common case.
>
> Writing cells: tell the model what it actually changed, and what looks wrong
>
> Writing is harder than it looks, because a single execute_code call can change hundreds of cells, and the agent needs to know what happened without re-reading the whole sheet. So after the code runs, we hand back a structured diff of every cell that changed — and, just as importantly, we compress and triage it.
>
> The code:
>
> ```typescript
> async function execute() {
>   const rows = await sheet.getCellRange("Sheet1!A2:C201");
>   for (let i = 0; i < rows.length; i++) {
>     const r = i + 2;
>     await sheet.setCell(`D${r}`, `=B${r}*C${r}`);
>   }
> }
> ```
>
> The diff that comes back:
>
> ```markdown
> --- CELL DIFF SUMMARY ---
> (Formatted display values shown. ∅ = undefined/empty.)
>
>   Changed without issues: 199 total cells
>     Sheet1!Row 2 (D): 1 cells
>       → D2: ∅ -> 11,988 [=B2*C2]
>     Sheet1!Row 3 (D): 1 cells
>       → D3: ∅ -> 8,391.6 [=B3*C3]
>     ... (sampled rows) ...
>     Sheet1!Row 201 (D): 1 cells
>       → D201: ∅ -> 4,995 [=B201*C201]
>     ... and 189 more rows
>
>   Cells that need review:
>     MUST FIX: INVALID_FORMULA: 1 total cells
>       Sheet1!Row 57 (D): 1 cells
>         → D57: ∅ -> #REF! [=B57*C57]
> ```
>
> Two kinds of compression are doing the work here.
>
> First, the diff is grouped and sampled, not dumped. Changed cells are grouped by sheet and row, each row shown as a column range with a count (Row 2 (D): 1 cells), and only a deterministic sample of cells per row and rows per section is printed, with "… and N more" tallies for the rest. Two hundred writes become a handful, and the agent still knows the totals.
>
> Second, the diff is categorized. Clean writes land under "Changed without issues." Anything that looks suspicious — an invalid formula like #REF!, an untagged hardcoded number, a hardcoded number buried inside a formula, an implausibly large percentage — gets pulled into a "Cells that need review" section, and the worst offenders are flagged MUST FIX. That #REF! in row 57 would be trivial to miss in a wall of two hundred green diffs; here it's surfaced at the top with a label. The feedback loop isn't "here's what changed," it's "here's what changed, and here's the part you probably got wrong" — a built-in linter on the agent's own edits.
>
> L1 in one line: the operations on the steep part of the curve get feature-engineered, token-compressed, consequence-reporting wrappers that live in the prompt forever. They're expensive to build, and you build them anyway, because the agent pays the cost on every task.
>
> ## L2 — curated English, on demand
>
> You cannot put everything in L1. Conditional formatting, pivot tables, charts, data validation, copy/move semantics — each is important, each shows up a few times a session, and each has enough surface that documenting it in the system prompt would bloat every task that doesn't use it. Classic L2.
>
> So we wrote curated capability specs in English, fetched on demand, exactly like skill mds. The model calls, from inside its code:
>
> ```typescript
> console.log(general.getConditionalFormattingInfo());
> console.log(general.getPivotTableInfo());
> console.log(general.getChartInfo());
> console.log(general.getDataValidationInfo());
> console.log(general.getAPIInfo("addSpanAt"));   // any single function, by name
> ```
>
> These aren't dumps of type signatures. They're hand-written prose — a few hundred lines each — that describe the canonical way to accomplish the task, including the knowledge the raw API will never give you. Take the pivot-table spec. It doesn't just list methods; it teaches the whole recipe, in the right order:
>
> ```typescript
> const pt = sheet.originalSheet.pivotTables.add("SalesPivot", "SalesData", 0, 0, ...);
> pt.suspendLayout();
> pt.add("Region",  "Region",        rowField);
> pt.add("Quarter", "Quarter",       columnField);
> pt.add("Amount",  "Sum of Amount", valueField, 8);   // 8 = sum
> pt.resumeLayout();
> ```
>
> and it bakes in the things you would otherwise learn only by failing repeatedly: that you must suspendLayout()/resumeLayout() around a batch of changes or the table rebuilds on every call; that a value field's aggregation has to be passed as a raw integer (8 for sum) because the friendly enum doesn't exist at runtime. None of that is a quirky footgun — it's the actual shape of doing pivots correctly, written down once by someone who already paid for it.
>
> The key property: this costs zero tokens until the task needs it. A task that never touches pivots never pays for the pivot docs. One console.log is the entire discovery cost — a single cache miss, served fast.
>
> The same idea, for executable tools
>
> L2 isn't only for docs. We apply the identical pattern to deferred tools — web_search, web_crawl, create_website, etc. Their schemas don't sit in the prompt. Instead there's a meta-tool wall:
>
> ```typescript
> get_tool_info("web_search")   → returns the schema, marks it "fetched"
> execute_tool("web_search", …) → REFUSES unless you fetched it first
> ```
>
> The set of fetched tools is, literally, a session-scoped cache. The model loads a schema once, and from then on it's resident. Same compression-vs-discovery tradeoff, same resolution: keep the prompt small, pay a one-step miss when you actually need the capability. This is the same idea as [deferred tools](https://platform.claude.com/docs/en/agents-and-tools/tool-use/tool-reference) on Claude but we're not locked to one vendor's tool-loading feature to get the behavior.
>
> ## L3 — the raw tome, and the skill that maps it
>
> Then there's the long tail: the one obscure thing we never wrapped and never wrote a spec for. You can't anticipate it — by definition. But the agent still has to be able to get there, or it hits a wall and fails the task. Concretely, this is where requests like these end up:
>
> - "Add a sparkline to each row summarizing its trend" — sparklines are a real but rarely-touched API surface.
>
> - "Set the chart's secondary axis to log scale and recolor just the third series" — a chart property three levels deep that no curated spec bothered to cover.
>
> - "Insert a hyperlink from this cell to that named range, and group these shapes" — drawing/shape/hyperlink corners nobody asked about until now.
>
> So L3 is the complete raw API — the entire Office.js surface (Excel plugin) or the entire SpreadJS surface (Shortcut web), dumped to disk. It's a machine-generated reference that is 70k lines long. It contains everything. It's also completely unusable as prompt context — you'd never paste it in.
>
> The trick: you give it a skill — a short map that teaches it how to mine the tome with bash:
>
> ```bash
> # from the advanced-api SKILL.md — the recommended workflow
> grep -n '"charts.add"' api-reference.json -A 5 # find a method
> grep -n '"pivots\.' api-reference.json | head # list a namespace
> grep -n '"ChartConfig"' api-reference.json -A 10 # resolve a type
> grep -n '"isEnum": true' api-reference.json -B2 -A10 # enumerate enums
> ```
>
> The skill is ~100 lines. It says: here's the structure, here's how each method and type entry is shaped, here's the grep recipe for each kind of question. With it, the agent goes from "tens of thousands of lines I can't read" to "the 3-6 greps that surface exactly the signature I need." That's the L3 access cost — real, but bounded, and only paid by the rare task that reaches this deep.
>
> And the system prompt makes the escape hatch explicit, so the model knows the path exists and when to take it:
>
> > API HIERARCHY — There are 2 levels of API capability. Wrapped API: convenience functions; some listed directly, others via getAPIInfo(...). NEVER guess — read the docs in FULL. Raw API: use when the wrapped API doesn't cover your need… If the wrapped API can't do it, use the raw API — don't compromise.
>
> That last clause is the whole point of L3. The agent should never be stuck. It can miss in L1, drop to L2, and if even the curated spec is silent, descend into the raw tome and still come out with the answer in a sane number of calls.
>
> ## How the prompt budget actually splits
>
> It's worth looking at where the tokens go, because the hierarchy shows up directly in the system prompt's shape.
>
> The bulk of the prompt is L1 — on the order of a few hundred lines. Core read/write operations, the execute_code contract, the key types and the handful of methods the agent uses on essentially every task, plus the execution and safety guidelines. This is the part that's resident on every single call, so it's also the part we fight hardest to keep tight.
>
> L2 is a thin slice on top — roughly 50 lines. It isn't the specs themselves; it's a curated allowlist of the "blessed" methods and the pointers that tell the agent the getXInfo(...) specs exist and when to reach for them. The specs' actual content stays out of the prompt until a console.log pulls it in.
>
> L3 is essentially 5 lines, the name and description of the skill.md, and other references scattered elsewhere. The raw reference — 70k lines — lives entirely on disk and never touches the prompt. All that's resident is the short skill file and the one line in the API-hierarchy section pointing at it.
>
> So the budget mirrors the frequency curve: most of the prompt is spent on the 80% case, a little on signposting the 15%, and almost nothing on the long tail — which is exactly the allocation the cache-hierarchy framing predicts.
>
> ## The recipe, ported to your domain
>
> Spreadsheets are just my example. The structure transfers to any domain. The compression in those system prompts and curated specs is really an encoding of the distribution of your users and the tasks they do — and you, in your domain, understand that distribution better than anyone. So your job is three questions:
>
> 1. What do you wrap into L1? The bread-and-butter operations on the steep part of the frequency curve. Make them brutally token-efficient and fast, and make them report consequences. Spend disproportionate effort here — the agent pays this cost on every task.
>
> 2. What do you defer to L2? The important-but-occasional capabilities. Write them as curated, English, gotcha-aware specs reachable in one discovery step. Encode the canonical recipe and the constraints, not just the signatures.
>
> 3. What is your escape hatch (L3)? The raw, complete substrate — plus a skill that teaches the agent to mine it. It doesn't have to be ergonomic. It has to be reachable, complete, and findable in a bounded number of steps. The agent must be able to — and will — eventually find the right information.
>
> Get those three placements right and you've built an agent that is fast on the common case, capable on the occasional one, and never truly stuck on the rare one — all while keeping context small enough that the model stays sharp.
>
> ## The hierarchy doesn't disappear — it moves
>
> One closing observation. What counts as L1 is not fixed; it drifts with model strength.
>
> Early, weak models needed tiny, single-purpose tools and everything spelled out. Today's models can absorb a larger L2 spec in one shot and reason over more raw L3 detail without choking. So as models improve, yesterday's L3 becomes tomorrow's L2, and yesterday's L2 collapses into L1. The agent's responsibility expands outward; the tiers slide down a level.
>
> But the hierarchy itself never goes away — because context will always be scarce relative to everything you could put in it, and noise will always cost you accuracy. There is no model so large that "put the right thing in front of it at the right time" stops mattering.
>
> Bigger context windows tempt people to paste in more. The better instinct is the one CPUs settled on decades ago: summaries in cache, details on demand, the raw substrate as the last resort. Build your agent's context like a memory hierarchy, and accuracy follows.
>
> 🔗 https://x.com/BrainsAndTennis/status/2065190286519906657

### Author replies in-thread

Peter Wang replied to several of the responders. Verbatim:

> @BrainsAndTennis → @__sebasgar__ (Sebas) — Thu Jun 11, 2026 22:59 UTC:
> thanks sebas! hope alls well

> @BrainsAndTennis → @nicbstme (Nico) — Fri Jun 12, 2026 00:03 UTC:
> i got inspired by you 6 months later

> @BrainsAndTennis → @alokbishoyi97 (Alok Bishoyi) — Fri Jun 12, 2026 01:55 UTC:
> thank you, appreciate it

> @BrainsAndTennis → @MengxueBi (Mengxue) — Fri Jun 12, 2026 01:56 UTC:
> the best way forward

> @BrainsAndTennis → @enzo_gte (enzo) — Fri Jun 12, 2026 01:56 UTC:
> thank you sir

### Notable third-party replies

> @Manuel_Cortes_R (Manuel Cortes) — Thu Jun 11, 2026 21:58 UTC:
> all goes back to computer architectures, my professors would be proud

> @phamrich_ (Richard Pham) — Thu Jun 11, 2026 22:23 UTC:
> Dr. Wang giving up our secrets for free that's crazy

> @lifeof_jer (JER) — Fri Jun 12, 2026 03:16 UTC:
> Awesome share! Thank you for sharing. Loved the L3 skills implementation. Genius.

> @siege53175 (Siege) — Fri Jun 12, 2026 04:13 UTC:
> Impressed how far the vertical agent idea evolved
