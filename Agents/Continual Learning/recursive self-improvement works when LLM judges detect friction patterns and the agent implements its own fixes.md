---
created: 2026-02-23
description: Factory's Signals system uses LLM-as-judge analysis on sessions to surface friction and delight patterns, then closes the loop by filing tickets that the agent itself picks up and fixes — achieving recursive self-improvement without humans reading conversations.
source: https://factory.ai/news/factory-signals
type: framework
---

## Key Takeaways

The core architectural insight is using LLMs as judges rather than analysts. Signals never surfaces raw conversation content to humans — it extracts abstract patterns and categorized signals that describe what happened without revealing what was said. This is a meaningful advance over the blunt metrics-vs-privacy tradeoff most teams face, and it connects to the broader pattern of [[progressive disclosure filters force agent selectivity over what enters context|progressive disclosure]] where abstraction layers control what information reaches which audience.

Friction detection evolves its own taxonomy through semantic clustering. Early versions had no concept of "context churn" or "branch switches" as categories — the embedding pipeline clustered sessions that didn't fit existing types, and the LLM proposed new dimensions. This self-evolving schema is the same pattern that makes [[skill graphs outperform single skill files by letting agents traverse linked domain knowledge on demand|skill graphs]] powerful: the structure itself grows from observed reality rather than being designed upfront.

The most counterintuitive finding is that error recovery matters more than error prevention. Sessions that hit errors but recovered gracefully scored higher on delight than error-free sessions. Users build more trust from resilience than perfection. This has direct implications for how we design [[file-based personal OS gives AI agents persistent identity and judgment across sessions|agent operating systems]] — logging and recovering from failures may be more valuable than preventing them.

Context churn emerged as the leading indicator of frustration — when users repeatedly add and remove the same file from context, something fundamental is wrong. This surfaces minutes before obvious signals like tone escalation. The rephrasing cascade finding is equally actionable: three rephrases predict a forty percent chance of another, and five rephrases correlate with significant drops in session completion. Both patterns are detectable without reading content, only counting structural events.

The closed loop from detection to fix is the ambitious part. Signals files Linear tickets automatically when patterns cross thresholds. Factory's own agent (Droid) picks up those tickets, implements fixes, and reviews its own PRs. A human still approves the merge, but the path from "users are frustrated by X" to "here's a fix" requires no manual triage, assignment, or pattern recognition. This is [[agent-first engineering replaces coding with environment design scaffolding and feedback loops|agent-first engineering]] applied to the agent's own development process.

The facet decomposition approach — extracting structured metadata like languages, intent, tool call counts, and session outcomes — enables aggregate analysis across thousands of sessions without anyone reading transcripts. This addresses the same [[context tax compounds through cache misses bloated tools and unbudgeted output tokens|context tax]] problem from a different angle: instead of reducing what the agent reads, it reduces what humans need to read while preserving analytical power.

## External Resources

- [Factory.ai](https://factory.ai) — AI coding agent platform (Droid) with autonomous software engineering capabilities
- [Signals](https://factory.ai/news/factory-signals) — Factory's LLM-as-judge session analysis system for recursive self-improvement

## Original Content

*Signals session analysis visualization showing friction and delight patterns*
![[factory-signals-001.png]]

> [!quote]- Source Material
> **Signals: Toward a Self-Improving Agent** — Factory Research, January 23, 2026
>
> How we built a closed-loop system for recursive self-improvement—where the agent detects its own failures and implements fixes automatically.
>
> Traditional product analytics tell you what happened. Session duration, tool calls executed, completion rates. But they rarely tell you how it felt. A user might complete a task successfully in twenty minutes, but did they spend eighteen of those minutes fighting the tool?
>
> We built Signals to answer that question. Signals uses LLMs as judges to analyze Factory sessions at scale, identifying moments of friction and delight that metrics alone would miss. More importantly, it does this without anyone ever reading user conversations. And when friction crosses a threshold, Droid fixes itself. This is recursive self-improvement: the agent analyzing its own behavior and evolving autonomously.
>
> **The Problem with Metrics**
>
> Consider a session where a developer asks Droid to refactor a module. The metrics look fine: forty-five tool calls, twelve-minute session, task completed. But buried in that session is a three-minute loop where the user rephrased the same request five times, growing increasingly frustrated, before the agent finally understood what they wanted.
>
> Traditional analytics would score this session as a success. A human reviewer would call it a near-disaster. We needed a system that could think more like the human, without actually requiring humans to read through thousands of daily sessions.
>
> **How Signals Works**
>
> Signals processes sessions using LLM and embedding-based analysis. The model never surfaces raw conversation content to human analysts. Instead, it extracts abstract patterns and categorized signals that tell us what happened without revealing what was said.
>
> Every session gets decomposed into structured metadata. We call these facets: the programming languages involved, the primary intent, how many tool calls were confirmed, whether the session ended in success or abandonment, what frameworks were referenced. These facets enable aggregate analysis across thousands of sessions without anyone reading the underlying conversations.
>
> The facet schema itself evolves over time through semantic clustering. As Signals processes batches of sessions, it generates embeddings for each session's abstracted summary and clusters similar sessions together. The LLM then analyzes these clusters to identify new facet categories worth tracking. When a cluster emerges that doesn't map cleanly to existing facets, Signals proposes a new dimension.
>
> Early versions of Signals had no concept of "branch switches" as a facet. The clustering revealed a group of sessions that shared similar patterns but didn't fit existing categories. When the LLM examined what these sessions had in common, it identified that git branch changes correlated with session complexity and surfaced it as a new dimension worth tracking.
>
> **Friction Detection**
>
> The friction analyzer scans for patterns that indicate user struggle: error events, repeated rephrasing, escalation in tone, tool calls rejected by the user, and more. Each friction moment gets a severity rating and abstracted citations that describe what happened without exposing user quotes, code, or PII. A citation might read "user expressed frustration after third failed tool call" rather than quoting the user's actual words.
>
> Like facets, friction categories evolve through the same embedding and clustering process. Signals generates embeddings for friction descriptions and clusters them to find recurring patterns that don't fit existing categories. When a new cluster emerges across enough sessions, it proposes a new friction type.
>
> The "context churn" category didn't exist in our original design. Signals' clustering surfaced a group of friction moments that shared semantic similarity but didn't match any existing type. When the LLM examined the cluster, it identified the common thread: users repeatedly modifying their context window in ways that correlated with eventual abandonment. That pattern became a first-class friction category.
>
> **Delight Identification**
>
> Signals doesn't just find problems. It finds moments where Factory genuinely impressed users. Positive exclamations, first-attempt successes on complex tasks, explicit mentions of time saved, rapid approval flows followed by appreciation. These moments matter for understanding what to do more of, not just what to fix.
>
> Delight categories evolve through the same mechanism. The system recently surfaced "learning moments" as a new delight type after discovering that sessions where Droid explained its reasoning generated disproportionately positive signals compared to sessions that just executed without explanation.
>
> **The Pipeline**
>
> Signals runs as a daily batch process designed for scale and cost efficiency. Sessions from the past twenty-four hours get fetched from BigQuery, filtered to those with at least thirty agentic steps to ensure meaningful interactions, and sent to OpenAI's batch API.
>
> We analyze thousands of sessions daily, dynamically adjusted based on a token budget. Batching lets us take advantage of lower API costs, and the twenty-four hour processing window works well since we're looking for patterns, not real-time alerts.
>
> Results flow to BigQuery for historical analysis and to Slack for daily reports. The BigQuery tables let us query friction patterns over time, correlating them with releases and feature changes. The Slack reports give the team a daily pulse on how users experienced the product.
>
> **Correlating with System Behavior**
>
> Signals becomes even more powerful when correlated with our internal logging and release data. We pipe error logs from our observability system into Signals' analysis. When a session shows friction, Signals can cross-reference with backend errors that occurred during the same time window. This surfaces patterns like "users experience repeated rephrasing friction when the context assembly service throws timeout errors" without anyone manually investigating individual sessions.
>
> Daily Slack reports now include correlation with our release notes. When a new CLI version ships, Signals automatically tracks whether friction patterns change in subsequent sessions. We've caught regressions this way. A release that changed how file context was assembled correlated with a spike in context churn friction the following day.
>
> We can also track improvements. When we shipped a change to how Droid handles ambiguous requests, the "repeated rephrasing" friction rate dropped by thirty percent within forty-eight hours.
>
> **Closing the Loop**
>
> Signals implements what AI researchers call recursive self-improvement—systems that autonomously enhance their own capabilities. When patterns cross a threshold, it files Linear tickets automatically. Droid picks up those tickets, implements fixes, and reviews its own PRs.
>
> It's not fully automated yet. A human still approves the PR before merge. But the path from "users are frustrated by X" to "here's a fix for X" now happens without anyone manually triaging, assigning, or even noticing the pattern.
>
> **Privacy Without Blindness**
>
> Traditional approaches force a choice: either read user sessions to understand problems, or stay blind to preserve privacy. Signals resolves this through multiple layers of abstraction. The LLM extracts patterns while omitting specific user content. Individual results flow into aggregate statistics that only become meaningful at scale. And patterns only surface when they appear across enough distinct sessions to prevent identifying individual users.
>
> **What We've Learned**
>
> After running Signals for several months, patterns have emerged that we couldn't have found through traditional metrics.
>
> Context churn turned out to be the leading indicator of eventual frustration. When users repeatedly add and remove the same file from context, something fundamental is wrong. This pattern often appears minutes before more obvious friction signals like escalation in tone.
>
> Rephrasing cascades predict abandonment with surprising accuracy. If a user rephrases three times, there's roughly a forty percent chance they'll rephrase again. If they hit five rephrases, session completion rates drop significantly.
>
> Error recovery matters more than error prevention. Sessions that hit errors but recovered gracefully actually scored higher on delight than sessions with no errors at all. Users seem to appreciate resilience over perfection.
>
> On the delight side, the most common positive signal is efficiency. The phrase "would have taken me hours" appears in abstracted form across hundreds of delight citations.
>
> **What's Next**
>
> Signals is the foundation for something more ambitious: a self-evolving agent capable of true recursive self-improvement. Today, the loop runs daily. Tomorrow, it runs in real-time, surfacing friction indicators during active sessions so the agent can course-correct before frustration builds.
>
> Beyond reactive fixes, we're building toward proactive evolution. Signals doesn't just identify what's broken, it identifies what's missing. When clusters reveal users repeatedly asking for capabilities that don't exist, that's signal for what to build next.
>
> The end state is an agent that learns from every interaction, improves continuously, and evolves its own capabilities over time. Signals is how we get there.
>
> [Original article](https://factory.ai/news/factory-signals)
