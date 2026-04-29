---
created: 2026-04-29
description: Laminar's trace viewer reorganizes agent runs as a linear transcript of the LLM-tool loop with reasoning inline, collapsed subagent cards, a parallelism-revealing timeline strip, and span-cited chat — matching how engineers actually read agent traces rather than how OTel happens to store the spans.
source: https://x.com/skull8888888888/status/2049063932841664908
type: framework
---

## Key Takeaways

- **Span trees are wrong as a *reading* interface even when they're right as storage.** An agent run is a conversation with side effects (plan → tool → react → spawn → synthesize → plan), and reading that as a flame graph indexed by latency is most of why two-thousand-span traces feel useless. The fix is a transcript view: surface the LLM/tool while-loop in order with the model's reasoning placed next to the tool call it produced, so "why did it call this tool here" is answered without three attribute clicks. This generalizes the gap [[agents fail without trace architecture because reasoning evaporates when the context window closes]] flags between span storage and trace consumption — once reasoning is load-bearing, it belongs on the spine of the trace, not buried inside an attribute. Same skim-and-dig insight [[Slate's terminal UX solves multi-agent observability by separating orchestration search and execution into visible parallel threads]] reaches from the orchestrator side.
- **Subagent fan-outs need collapse-into-card UI to scale past ~5; flat trees become unreadable at depth 3+.** A six-subagent run rendered as a tree is a wall of equally-indented spans with the thing you actually want lost in the middle. Collapsing each invocation's subtree into a single card titled by invocation intent turns fan-out into a triage surface: scan the cards, click the suspicious one, read its inner loop the same way you read the outer one, close it, orchestrator's scroll position holds. This is the only layout that scales when production agents fan out to ten subagents per run, and it's the move most agent observability tooling currently misses.
- **LLM trace chat is only useful with clickable span citations — without them you can't tell when the model hallucinated about the trace.** "Which subagent was slowest", "did the agent retry a tool call", "at what turn did the plan change" are the operational questions scanning won't answer; an LLM that cites the exact spans it's reasoning over (as inline pills you can click into) lets you verify every load-bearing claim and correct the model when it's wrong. Without span pills, this is just pasting a trace into ChatGPT and trusting the answer.

Supporting moves that follow from the same frame: a parallelism-revealing timeline strip (so `Promise.all` fan-outs stack at the same x and serialization bugs stair-step), one-line tool-call previews ("Read events.csv", "Grep `def .*`") that make 200-call runs skimmable, and auto-extracted inputs to the root call and every subagent — the [[OTel GenAI semantic conventions are becoming the standard wire format for LLM agent observability]] payoff: once the wire format is conventional, the viewer does the structural work for you, no wrapper-span tax. See [[resources/Laminar]] for the open-source implementation that ships all of this.

## External Resources

- [Laminar](https://laminar.sh) — open-source agent observability platform built around the transcript view
- [lmnr-ai/lmnr on GitHub](https://github.com/lmnr-ai/lmnr) — self-hostable repo (~2.8k stars at capture)
- [Viewing traces docs](https://laminar.sh/docs/platform/viewing-traces) — timeline strip behavior, sync between strip and transcript, drag-to-filter, Cmd+scroll zoom
- [Claude Agent SDK integration](https://laminar.sh/docs/tracing/integrations/claude-agent-sdk) — one-line instrumentation for the SDK
- [Integrations overview](https://laminar.sh/docs/tracing/integrations/overview) — full list of supported frameworks

## Original Content

> @skull8888888888 (Robert) — 2026-04-28
>
> **Agent traces aren't backend traces. Stop reading them like they are.**
>
> Everyone in AI agent Twitter tells you to look at your traces. Nobody really tells you how.
>
> The default answer is "open the span tree." That works for backend traces, where requests are linear and you mostly care about latency, error rate, and payloads. An agent run is a conversation with side effects: plan, call a tool, react, spawn a subagent, synthesize, plan again. The content is mostly text: model reasoning, subagent prompts, tool outputs. Reading that as a flame graph indexed by latency is most of the reason people sit down with a two-thousand-span trace and feel like they're getting nothing out of it.
>
> So we built [Laminar](https://laminar.sh) trace viewer around how you actually read agent traces, instead of around how the spans happen to be stored.
>
> *Cover: trace view with timeline strip, transcript, and "Chat with trace" pane open*
> ![[skull-841664-001.jpg]]
>
> ## Transcript view
>
> At the core, an agent is a simple while loop: LLM call, tool call, LLM call, tool call, until a final answer. Complexity shows up when a tool call spawns another agent, but the spine of any trace is that loop, in order.
>
> That sequence is what we mean by transcript. The view exposes the loop directly, with the model's reasoning surfaced right next to the tool call it produced. When you're debugging an agent, the question is almost always "why did it call this tool here," and the answer lives in the model's thinking on the LLM turn that came just before. In a span tree view, that thinking is buried inside an attribute on the LLM span. By the time you've clicked through a few spans to reconstruct what the agent was thinking across turns, you've lost track of where you were in the trace. In the transcript, the thought sits right above the tool call, and you read the loop straight through.
>
> Every tool call also gets a one-line preview rendered next to it from its arguments. "Read /sandbox/scratch/cas_demo/data/events.csv." "Edit fizzbuzz.py." "Grep `def .*`." On a 200-tool-call trace you can skim the loop like a log file.
>
> *Transcript loop on a code-review run: model thoughts inline with their tool calls, with read/grep one-liners*
> ![[skull-841664-002.png]]
>
> The tree view is still in the dropdown and still the right thing sometimes, mostly when you're debugging span nesting itself: a custom `observe` wrapping a server-side turn, a custom MCP tool with its own child spans, a specific attribute on a middleware span. For everything else, the loop and the reasoning that drives it are what you're actually trying to read, and that's what the transcript is for.
>
> A timeline strip sits above all of this, and it gives you the shape of the run before you've read anything.
>
> It renders the whole run as colored bars on a single time axis. Summing three subagents' wall times tells you nothing about whether they ran in parallel or one after another, and a tree view can't show you parallelism without a lot of branch expansion and arithmetic. The timeline shows it directly: a `Promise.all`-style fan-out of subagents starts as three bars at the same x-coordinate, while a serialization bug stair-steps. The longest bar on the page is your tall pole, and clicking it jumps you to the span. Erroring spans are color-coded, so you can see which ones failed without reading anything and click straight to them. A long gap between a tool returning and the next LLM turn is usually a framework hop you didn't expect: a retry, a queue, middleware.
>
> The strip is synced with the transcript in both directions. As you scroll, a gray rectangle on the timeline tracks the spans currently in your viewport, so you always know where you are in the run. Drag on the timeline to filter the transcript to a range. Cmd+scroll zooms on the cursor. The [viewing traces](https://laminar.sh/docs/platform/viewing-traces) docs have the rest.
>
> ## Subagents are cards
>
> Once a tool call spawns another agent, the trace gets considerably busier. A six-subagent run rendered as a tree is a wall: orchestrator's LLM turn, then the first subagent's turn, its tool call, a retry, the second subagent's turn, and on. Everything indented at roughly the same depth, everything the same color, with the thing you actually want somewhere in the middle.
>
> Laminar recognizes each subagent invocation, collapses its entire subtree into one card, and pulls the card's name from the invocation's intent. Six fan-outs render as six cards. You scan the cards, click into the one that looks wrong, read its inner loop the same way you read the outer one, close it, and keep going. Nothing else in the trace moves while you're inside a card, and the orchestrator's scroll position holds.
>
> *A subagent (Data Auditor) collapsed to a single card inside the orchestrator's transcript*
> ![[skull-841664-003.png]]
>
> *Same card expanded — its inner LLM-and-tool loop reads exactly like the outer one*
> ![[skull-841664-005.png]]
>
> Once your agents fan out to ten subagents per run, which is normal in real codebases, this is the only layout that scales to skim-and-dig reading.
>
> ## Inputs to every agent and subagent are surfaced for free
>
> The other thing that matters about transcript view is that you don't have to do anything to make it useful.
>
> Laminar parses the span tree and pulls out the input to the root call and the input to each subagent automatically. There's no extra attribute to set, no wrapper span you forgot to add, no `"prompt"` field you meant to record and didn't. You send OpenTelemetry spans from the [Claude Agent SDK](https://laminar.sh/docs/tracing/integrations/claude-agent-sdk) (or any other framework we cover) and the transcript already knows what the human asked the orchestrator and what the orchestrator asked each subagent. In a tree view that input is buried inside an attribute on the invoking LLM call, three expansions deep. In the transcript it's the first line of the subagent's card.
>
> That sounds minor until you come back to a trace a week later and try to remember where you stuffed the prompt.
>
> ## Chat with trace
>
> That gets you through most traces. When you have a specific question that scanning won't answer, click the Chat button in the trace view header and a pane slides in on the right. It auto-summarizes the run, then waits for a question in plain English.
>
> > Which subagent was slowest and why?
>
> The response reads the actual trace and cites specific spans as inline pills. The orange `Agent` and `anthropic.messages` chips in the screenshot are clickable; click `anthropic.messages` and you land on the exact LLM call that dominated the subagent run. When the answer is structured, like a comparison across subagents, it renders a table.
>
> *Chat answers "which subagent was slowest" with a clickable Agent span pill*
> ![[skull-841664-006.png]]
>
> *Cost-and-outcome question — every span citation is clickable*
> ![[skull-841664-007.jpg]]
>
> Span citation is what separates this from pasting a trace into ChatGPT. Every load-bearing claim the trace agent makes is anchored to a span you can click into, so when it gets something wrong you can see immediately that it's wrong, and the spans you'd need to correct it with are right there.
>
> The questions that have saved us the most time:
>
> - "Summarize this run." Usually tells you whether it succeeded, failed, or partially succeeded without you reading a single span.
>
> - "Which subagent was slowest and why?" Tall pole, plus the reason it was tall.
>
> - "Did the agent ever retry a tool call? If so, why?" Catches silent retry storms a tree view buries three levels deep.
>
> - "At what turn did the plan change?" The most useful question for debugging an agent that did the wrong thing. The answer is a span pill you can click.
>
> ## Try it
>
> [Laminar](https://laminar.sh) is open source and easily self-hostable: https://github.com/lmnr-ai/lmnr. Integration is 1 line of code and you can start sending traces within 1 minute. Here're the docs for the [Claude Agent SDK integration](https://laminar.sh/docs/tracing/integrations/claude-agent-sdk), and you can explore all integrations [here](https://laminar.sh/docs/tracing/integrations/overview).
>
> Engagement: 21 likes | 5 retweets | 0 replies
> [Original post](https://x.com/skull8888888888/status/2049063932841664908)
