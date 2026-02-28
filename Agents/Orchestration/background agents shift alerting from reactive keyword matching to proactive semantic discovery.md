---
created: 2026-01-31
description: Fintool's alerting architecture separates high-volume trigger filtering from LLM-based semantic analysis, enabling agents that discover opportunities proactively rather than matching keywords reactively
source: https://x.com/JesseProvo/status/2016280574684758507
type: framework
---

## Key Takeaways

Traditional alerting fails because it conflates two distinct problems: filtering documents at scale and interpreting whether a match is genuinely relevant. Fintool's architecture separates these cleanly — cheap trigger mechanisms (event-driven document matching, scheduled cron) handle high-volume filtering, while LLM execution handles semantic interpretation only for documents that pass the filter. This means the AI cost scales with matches, not with the total document volume.

The conversational alert creation pattern is a strong example of agent skills in practice — the kind of compound workflow that [[four memory layers serve different knowledge types|ms (skill memory)]] is designed to capture and make reusable. Rather than exposing configuration forms, users describe what they want in natural language and the agent follows a structured workflow: search to discover where relevant information appears, report findings, ask clarifying questions, present a plan, then create the alert. The skill encodes domain principles like "keywords match text not meaning" and "err on coverage over precision" — guidance the AI applies without the user needing to learn it.

The two trigger mechanisms cover complementary ground. Publication alerts are event-driven (SQS queue fires a Lambda when a document finishes processing), evaluating new documents against all active alerts in real-time. Scheduled alerts use iCal VEVENTs for expressive time-based triggers, with optional pre-check scripts that gate execution on quantitative conditions ("only if market is down 2%+"). Both terminate in the same Temporal workflow for reliable LLM-based analysis.

The self-configuring alert pattern is where this gets interesting. Because the agent can read and write files, alerts can maintain their own state — tracking which companies they have already covered, updating their own schedule based on discovered dates, and evolving their criteria over time. The earnings preview example illustrates this: schedule runs 7 days before each confirmed earnings date, write the preview, update the schedule to target the next date, set follow-up checks for unannounced dates.

The progression from reactive to proactive represents the real frontier. Reactive alerts monitor things you already know about. Thesis monitoring evaluates new information against your existing investment thesis. Proactive discovery surfaces companies you should be looking at but haven't explicitly asked about — learned from your actual behavior (investment memos, Excel models, email threads) rather than stated preferences. The dynamic screen files that update themselves as companies enter and exit criteria are a compelling pattern for any domain where continuous monitoring matters.

Fintool is moving alerts from opaque database records toward markdown files with YAML frontmatter stored in the user's filesystem — the same pattern as thesis files. This mirrors the filesystem-first principle in [[Obsidian as Agentic Memory]] where everything meaningful persists to plain text files that agents can read, write, and reason about rather than API-mediated abstractions.

The self-configuring alert pattern — markdown files with YAML frontmatter that the AI reads, writes, and reasons about — mirrors the vault architecture described in [[Obsidian as Agentic Memory]]. The conversational alert creation workflow uses the same [[ContextEngineering|progressive disclosure]] principle: discover where information appears before configuring what to monitor. The progression from reactive alerts to proactive discovery parallels how [[four memory layers serve different knowledge types|the four memory layers]] escalate from raw capture (CASS) to pattern extraction (CM/ms) to understanding (vault). The multi-layer context approach (cheap triggers first, expensive LLM analysis second) echoes the tiered retrieval pattern in [[OpenAI internal data agent succeeds through six layers of context not model capability alone|OpenAI's data agent]], where schema metadata filters before full RAG retrieval fires.

## External Resources

- [Anthropic: Equipping Agents with Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills) — Anthropic's engineering post on agent skills as organized instruction folders
- [OpenAI: Codex Skills](https://developers.openai.com/codex/skills/) — OpenAI's agent skills specification for task-specific agent capabilities
- [Fintool filesystem paradigm thread](https://x.com/nicbstme/status/2015174818497437834) — the markdown-as-configuration pattern Fintool is adopting for alerts and thesis files

## Original Content

> @JesseProvo — 2026-01-27
>
> Alerting systems are one of the most natural applications for AI agents. The pattern is simple: monitor for conditions, evaluate when they're met, take action. But traditional alerts are brittle. They match keywords without understanding meaning. They fire on schedules without considering context. They require manual configuration for every trigger.
>
> Agents change this. An agent can understand what you actually care about, discover where that information appears, and interpret whether a match is genuinely relevant. It can maintain state across runs, update its own configuration, and learn from your behavior.
>
> At Fintool, we've built an alerting system grounded in these principles. Our domain is financial research: SEC filings, earnings calls, press releases, market data. An investment analyst covering 50 companies might need to monitor all of these across their entire portfolio. Traditional alerting offers two inadequate options: subscribe to everything and suffer notification fatigue, or miss critical information.
>
> We set out to build something better.
>
> # The Relevance Problem
>
> The fundamental challenge with financial alerts is that relevance varies by profession and context. A portfolio manager cares about different signals than a credit analyst. A merger arbitrageur needs different triggers than a dividend investor. What constitutes "material" information depends entirely on the user's investment thesis.
>
> Consider a simple request: "Alert me when a company announces layoffs." This seems straightforward until you realize:
>
> - Layoffs might be disclosed in an 8-K, mentioned in an earnings call, announced in a press release, or buried in a 10-Q footnote
>
> - The word "layoffs" might not appear. Companies use "workforce reduction," "restructuring," "right-sizing," or "headcount optimization"
>
> - Not all layoff mentions are announcements. A CEO might say "we have no plans for layoffs" or reference layoffs from years ago
>
> - Materiality varies: 100 layoffs at a 500-person company is significant; 100 at a 50,000-person company is noise
>
> Traditional keyword alerts fail spectacularly here. They either miss relevant documents (false negatives) or flood users with irrelevant matches (false positives). Neither outcome serves the user.
>
> Our insight was to separate triggering from analysis. Cast a wide net with triggers, erring heavily on the side of inclusion. Then let AI handle the semantic interpretation: Is this actually a layoff announcement? Is it material? What are the details?
>
> # Creating Alerts Through Conversation
>
> One of our most powerful features is the ability for users to create alerts through natural conversation. Rather than filling out forms or learning a configuration syntax, users describe what they want and our AI handles the rest.
>
> This approach is built on what both Anthropic and OpenAI call Agent Skills (see [Anthropic](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills), [OpenAI](https://developers.openai.com/codex/skills/))—organized folders of instructions, scripts, and resources that agents can discover and load dynamically to perform specific tasks. A skill encodes not just the mechanical steps to accomplish something, but the domain knowledge that makes those steps effective.
>
> Our alerts skill teaches the LLM how to configure monitoring that actually works for financial professionals. When a user says "set up an alert for when any biotech in my portfolio mentions Phase 3 trial results," the AI follows a structured workflow:
>
> 1. Search recent documents to discover which document types typically contain Phase 3 mentions
>
> 2. Report findings: "I found Phase 3 discussions in 8-Ks, earnings calls, and press releases over the past year"
>
> 3. Ask clarifying questions when requirements are ambiguous
>
> 4. Present a plan with explicit trigger conditions and proposed action
>
> 5. Create the alert only after the user confirms
>
> That third step (asking questions) is crucial. Real user requests are often underspecified:
>
> - "Alert me about earnings" could mean releases, calls, surprises, or guidance changes
>
> - "My watchlist" is ambiguous when a user has three watchlists
>
> - "Important news" means different things to different people
>
> Rather than guessing, the AI asks, presenting 2-4 concrete options rather than open-ended questions. This interactive refinement prevents misconfigured alerts and guides users toward well-formed configurations.
>
> ## Principles Encoded in the Skill
>
> The alerts skill includes not just the workflow, but the principles that make alerts effective. These emerged from watching real users struggle with traditional alerting systems.
>
> Discovery first, configuration after. Don't assume you know which document types matter. Search broadly and let the data inform your choices. A user asking about "dividend announcements" might not realize these appear in 8-Ks, earnings calls, AND press releases—the skill teaches the AI to discover this before configuring the alert.
>
> Keywords match text, not meaning. This is a crucial distinction. Keywords filter documents that contain certain words, but they can't interpret whether those words indicate the thing the user cares about. Use topic nouns ("layoffs," "restructuring," "headcount") rather than action verbs ("announced," "cut," "reduced"). The action verbs are too generic and create false positives. The AI prompt handles semantic interpretation.
>
> Err on the side of coverage. Missing an event is far worse than a false positive. Different document types release at different times. A company might announce layoffs in a press release weeks before it appears in a 10-Q. Monitoring only one document type means missing the early signal. The AI is guided to find ALL document types where the user's topic could appear, not just the most common sources. The prompt filters irrelevant matches; the trigger should never be the limiting factor.
>
> These principles are encoded in the skill as guidance for the AI, not rules the user needs to learn.
>
> ## The Sandbox API
>
> When the AI needs to create, update, or list alerts, it executes Python scripts within a sandboxed environment. The skill includes scripts like `create_publication_alert.py` and `create_scheduled_alert.py` that call our backend API with the configured parameters. This gives the AI full CRU operations (list, view, update, pause, resume) through a consistent interface.
>
> This architecture is transitional. We're moving toward representing alerts as markdown files with YAML front matter, stored in the user's filesystem. An alert becomes a file like `/alerts/nvda-thesis-monitor.md` with structured metadata (triggers, schedule, last run) in the front matter and the prompt as the document body. This aligns alerts with the thesis files described later: both become first-class files that the AI can read, write, and reason about, rather than opaque database records accessed through API calls. Read more about the filesystem paradigm we are adopting at Fintool [here](https://x.com/nicbstme/status/2015174818497437834).
>
> # Under the Hood: Two Trigger Mechanisms
>
> When the AI creates an alert, it's configuring one of two trigger mechanisms that run in our backend.
>
> ## Publication Alerts
>
> Publication alerts fire when documents arrive. The architecture is event-driven: when a document finishes processing (SEC filing, earnings transcript, or press release), a message lands in an SQS queue. A Lambda function (`process_publication`) wakes up, pulls the message, and evaluates that document against every active publication alert in the system.
>
> The matching logic evaluates four filter dimensions, all AND'd together:
>
> - Document type: Is the publication's type (8-K, 10-Q, earnings-call-transcript, etc.) in the alert's configured list?
>
> - Ticker: Is the company in the alert's universe? Can be a direct list, a ticker file (`/public/indices/sp500.txt`), or a watchlist ID that resolves to the user's portfolio
>
> - Keywords: Query Elasticsearch against indexed chunks—catches keywords anywhere in the full text, handles phrase matching, scales efficiently via inverted index
>
> - Watchlist membership: Resolves dynamically at match time, so adding a ticker to a watchlist immediately includes it in relevant alerts
>
> When a document matches an alert, we fire the AI workflow with the document context. The Lambda also marks the publication/alert pair as processed, ensuring we don't re-fire if the document gets reindexed.
>
> ## Scheduled Alerts
>
> Scheduled alerts run on time-based triggers. A CloudWatch Events rule invokes a Lambda (`check_cron_alerts`) every 10 minutes, querying for alerts where `next_run_at` is in the past.
>
> Schedules are stored as iCal VEVENTs, giving us surprising expressiveness: "every weekday at 8:30 AM ET," "first Monday of each month," or one-time alerts using DTSTART without a recurrence rule.
>
> For alerts with a pre-check script, we evaluate in an E2B sandbox before firing. The alert only proceeds if stdout is exactly "true". This enables conditional scheduling: "every hour, but only if the market is open" or "daily, but only if my portfolio is down more than 2%."
>
> Creating alerts through chat enables even more expressive behaviors. Consider a user who wants an earnings preview one week before each earnings call for companies in their watchlist. This is tricky because earnings call dates aren't predetermined far in advance. A static schedule can't handle this. But because the AI can read and write files, the user can describe exactly what they want:
>
> > "Write me earnings previews for my Tech Holdings watchlist. Store the prompt template and state in `/earnings-preview.md`. Schedule this alert to run 7 days before the earliest confirmed earnings date in the watchlist. After writing a preview, update the schedule to target the next earliest date. For companies without confirmed earnings dates, set a follow-up alert to check after their earnings call and reschedule once dates are announced."
>
> The alert minimizes unnecessary runs by scheduling itself for specific dates rather than polling daily. It maintains its own prompt template in the markdown file, so subsequent runs use consistent analysis. The system self-configures: writing previews, updating schedules, and handling the uncertainty of unannounced earnings dates.
>
> ## Unified Execution
>
> Both alert types terminate in the same execution layer: a Temporal workflow that receives context and a user-defined prompt, runs analysis using our full chat infrastructure, and emails results.
>
> The prompt is entirely user-defined. We don't try to anticipate every possible alert type. A simple prompt: "Summarize the key points." A sophisticated one:
>
> > Analyze this 8-K for workforce reduction announcements. Extract: employees affected, departments impacted, timeline, cost savings. Only email if material (>100 employees or >5% of workforce). If the filing mentions layoffs but doesn't announce new ones, do not email.
>
> The execution layer runs through our full chat infrastructure, so alerts have access to document search, financial data, and all the context a human analyst would use. Temporal handles reliability—tracking errors, retrying failures, and maintaining history.
>
> # The Complexity Spectrum
>
> User requirements span a wide range. Our system handles all of them:
>
> - Document and scheduled filters: "Alert if AAPL drops below $200" or "When any S&P 500 company files an 8-K mentioning layoffs, summarize it." Scheduled alerts run bash scripts in a sandbox; document alerts match against tickers, document types, and keywords.
>
> - Thesis monitoring: "Monitor my NVDA thesis, alert me if anything suggests AI training demand is cooling." The prompt evaluates each document against an investment thesis, requiring semantic understanding and judgment about evidence.
>
> - Proactive screening: "Surface any company that matches my investment style." Continuously monitors the entire market, maintains dynamic screens, and pushes opportunities the user hasn't explicitly asked about.
>
> The first category scales elegantly. Document alerts are just database queries and Elasticsearch lookups against an inverted index. Scheduled alerts are just cron: a schedule fires, a script runs, and we only invoke the LLM if the condition passes. No AI is involved in the filtering itself. We can support thousands of these alerts with minimal compute.
>
> Thesis monitoring adds LLM analysis but only when a document matches the trigger. The filtering is still cheap; the AI evaluates documents that already passed the filter.
>
> The third category is our frontier.
>
> # The Frontier: Proactive Opportunity Discovery
>
> The first two categories work today. A user can set up document filters, scheduled scripts, and thesis monitoring alerts that evaluate filings against their investment thesis.
>
> The frontier is something more ambitious: proactive opportunity discovery. Instead of monitoring companies you already cover, the system surfaces companies you should be looking at based on your investment style.
>
> Consider an investor who focuses on small-cap industrial companies with improving margins and insider buying. Today, they'd need to manually run screens, check results, and hope they don't miss something. What we're building is a system that continuously monitors the entire market and pushes opportunities that match their style:
>
> - "CFO just bought $2M of stock in a $400M market cap industrial company. Margins expanded 300bps last quarter. This fits your pattern."
>
> - "An 8-K was just filed showing a board member resignation at a company matching your distressed-to-turnaround criteria."
>
> - "Three companies in your target sector just reported earnings beats with guidance raises."
>
> ## Onboarding: Learning How Users Think
>
> Today, we have an onboarding skill that walks users through a conversational setup: showing them what Fintool can access, helping them create watchlists for their portfolio and coverage universe, asking about their investment style (sectors, market cap, long/short orientation, holding period), and offering to connect cloud services like OneNote, OneDrive, or Notion. This creates a `UserMemories.md` file capturing their preferences.
>
> But we want to go deeper. The key to proactive discovery is understanding how each user actually makes investment decisions: not just their stated preferences, but their revealed behavior. During onboarding, users connect their filesystem—Google Drive, Dropbox, local folders containing their research. With permission, we explore these artifacts to build a picture of their investment style:
>
> Investment memos: What thesis structure do they use? What assumptions do they call out? How do they frame risk?
>
> Excel models: What metrics do they track? What are their key drivers? What scenarios do they model?
>
> Email threads: What questions do they ask on expert calls? What signals trigger action?
>
> Notes and annotations: What do they highlight in filings? What patterns emerge in their research process?
>
> From this exploration, we identify:
>
> 1. Companies they're covering: Extracted from model files, memo headers, and research folders
>
> 2. Investment style: Growth vs. value, fundamental vs. technical, time horizon, risk tolerance
>
> 3. Thesis structure: How they articulate core beliefs, key assumptions, and signals to watch
>
> 4. Decision triggers: What historically caused them to add, trim, or exit positions
>
> We then confirm our understanding with the user: "It looks like you're covering 12 semiconductor companies with a focus on AI infrastructure buildout. Your theses tend to emphasize demand signals from hyperscalers and capacity utilization trends. Does this sound right?"
>
> ## Dynamic Screens
>
> Once we understand the user's style, we automatically generate and maintain screens that run continuously in the background.
>
> A screen file captures the user's criteria in a format the AI can execute:
>
> ```
> # Small-Cap Industrial Turnarounds
> Last updated: 2025-01-26
> ## Criteria
> - Market cap: $200M - $2B
> - Sector: Industrials
> - Margin trajectory: Expanding (2+ consecutive quarters)
> - Insider activity: Net buying in past 90 days
> - Catalyst: Recent management change, activist involvement, or strategic review
> ## Current Matches
> - EXAMPLE1: Margins +280bps, CFO bought $1.2M last month
> - EXAMPLE2: New CEO from competitor, announced cost review
> ## Recently Removed
> - EXAMPLE3: Market cap exceeded $2B after rally
> ```
>
> The system continuously evaluates new filings, transcripts, and insider transactions against these criteria. When a company enters or exits the screen, the file updates and the user gets notified. When a company already on the screen has a material development, the user hears about it.
>
> The screens are living documents. As the user takes action (or doesn't) on surfaced opportunities, we learn what actually triggers their interest and refine the criteria. A user who consistently ignores companies under $500M market cap gets screens that adjust accordingly.
>
> The result: a user connects their filesystem, confirms our understanding of their style, and walks away with opportunity discovery running automatically. No manual screening. No daily checks. The system learned how they invest and now surfaces what matches.
>
> # Practical Considerations
>
> Building a production alerts system involves solving practical problems beyond the core logic:
>
> - Idempotence: Track processed document/alert pairs to prevent re-firing when documents get reindexed.
>
> - Timeliness verification: Prompts instruct the AI to verify information is genuinely new. Companies often repeat old news in new filings.
>
> - Point-in-time snapshots: "S&P 500 companies" resolves to a concrete ticker list at creation time. We tell users this is a snapshot; index rebalances won't auto-update the alert.
>
> # What Makes This State-of-the-Art
>
> Most financial alerting systems fall into three categories:
>
> - Keyword matching: Boolean queries like "AAPL AND dividend." These have high false-positive rates and miss synonyms, context, and negations ("no dividend change" still matches).
>
> - Pre-packaged event types: Fixed categories like "earnings releases" or "insider transactions." Works for common cases, but can't handle "management commentary about supply chain issues."
>
> - Manual monitoring: Checking filings daily, setting calendar reminders, building tracking spreadsheets. Works, but doesn't scale.
>
> Our system combines precise triggering with semantic analysis. The trigger layer handles high-volume filtering (documents, tickers, keywords). The execution layer handles interpretation (meaning, materiality, what to tell the user).
>
> This separation lets us err on coverage while maintaining precision. Because the prompt is user-defined, the system adapts to each user's needs without us anticipating every use case. And because the AI can read and write files, alerts can be self-configuring: tracking their own state, updating schedules based on conditions, and evolving over time (like the earnings preview example that checks for upcoming calls and tracks which companies it has already covered).
>
> The skill system makes it accessible. Users describe what they want in natural language.
>
> # Looking Forward
>
> We're building toward a future where every investor has a tireless analyst monitoring their portfolio, surfacing only what's genuinely important. The pieces are coming together:
>
> - A skill system that makes alert creation conversational and accessible
>
> - Event-driven triggers that catch documents as they arrive
>
> - Scheduled triggers that can run arbitrary analysis on any cadence
>
> - Pre-check scripts that gate alerts on quantitative conditions
>
> - LLM-based filters that gate alerts on semantic conditions
>
> - Stateful monitoring that synthesizes across observations
>
> The goal isn't to replace human judgment—it's to ensure humans are judging the right things. When an investment thesis is invalidated, the investor should know immediately, not discover it in hindsight while wondering what they missed.
>
> Engagement: 83 likes | 5 retweets | 3 replies
> [Original post](https://x.com/JesseProvo/status/2016280574684758507)

