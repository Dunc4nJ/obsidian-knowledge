---
created: 2026-05-14
description: a16z partners Steph Zhang, Gio Ahern, and Alex Immerman argue that the next decade of GTM enterprise value will accrue not to the CRM but to the AI orchestration layer above it — the system of intelligence that reads and writes the database while pulling signals from dozens of other tools, the way the social newsfeed turned the friend graph into one input among many.
source: https://x.com/steph_zhang/status/2054925688097128603
type: framework
---

## Key Takeaways

- **The newsfeed-vs-friend-graph analogy is the load-bearing argument.** Facebook's friend graph never went away, but value migrated to the algorithmic feed that consumed the graph as one input among many; a16z claims the CRM is undergoing the same demotion — Salesforce and HubSpot still own the database, but the AI orchestration layer above them becomes the user's destination, the locus of switching costs, and the place "all of the next decade's enterprise value of GTM software will end up." This is the strongest framing yet for why [[boring domain-specific AI businesses survive bubbles because measurable ROI and regulation moats beat general-purpose wrappers]] is not the whole picture — there's also a category-level opportunity to be the new gravity well, not just a vertical wrapper.

- **AI inverts the gravity model from data accumulation to orchestration.** In the software era gravity came from "every valuable piece of sales context had to live in one place because the human could only look in one place at a time." That constraint dies once an agent can pull from CRM, calendar, inbox, call recording, Slack, enrichment API, billing, and product telemetry simultaneously — so switching costs shift from "all our data is in Salesforce" to "all our workflows, reasoning, and accumulated institutional context live in our AI layer." The lock-in argument that protected SoR incumbents for 20 years now points at the layer above them.

- **The counterintuitive empirical hook: CRM usage rose, not fell, after AI adoption.** a16z's GTM survey shows daily CRM use *increased* (39% increased, 49% stayed same, only 13% decreased) because background agents are writing structured call notes back into the system, making the data richer and giving reps fresh reason to consult it. This is the same dynamic [[company-brain-part-1-why-most-companies-have-data-but-no-memory]] describes — the database becomes more valuable precisely as it gets demoted to infrastructure, because the intelligence layer above it depends on faithful, current records.

- **The labor-budget argument is the answer to "won't this just shrink sales headcount?"** 39% of sales leaders expect headcount to *increase* and another 37% expect it to stay flat (only 23% expect decrease) — the ROI from agents is high enough that the total pie grows. Software has historically been 5-10% of GTM spend with payroll the rest; AI is the first thing that lets software meaningfully eat into that wedge while quotas and attainment also rise. This is the macro counterargument to the "AI replaces workers" framing — at least in GTM, it expands the labor budget rather than displacing it. Related: [[domain-specific agents beat general-purpose ones by owning verification in boring industries]].

- **"What it needs is structured data it can read and write with low friction" — the death sentence for opinionated CRM UI.** Drag-and-drop pipeline views and Kanban deal stages are "legacy furniture, a bit like the lovingly created UI of your Facebook profile; once paramount, now an afterthought." The thesis predicts that the workflow-as-UI moat collapses because agents don't need workflows — they need APIs. This generalizes far beyond CRM: every system whose value was "we built the right opinionated workflow on top of the data" is exposed to the same demotion. See [[context-files-beat-mcp-schemas-for-internal-agents-because-they-encode-how-your-team-actually-uses-each-tool]] for the agent-side mirror — context, not workflow UI, is now the moat.

## External Resources

- [Full article — From "System of Record" to "System of Intelligence"](https://www.a16z.news/p/from-system-of-record-to-system-of) — the long-form a16z newsletter version this X Article mirrors
- [Salesforce Headless 360 announcement](https://www.salesforce.com/news/stories/salesforce-headless-360-announcement/) — cited as evidence SoR incumbents recognize the threat and are shipping API-first offerings
- [Alex Rampell — "hostages, not customers"](https://a16z.com/the-greenfield-strategy-ai-native-startup-bingo/) — the canonical a16z framing for how database lock-in converts users into hostages
- ["First prize is a Cadillac. Second prize is a set of steak knives."](https://www.instagram.com/reel/DVE0iYDDYf6/?igsh=NTc4MTIwNjQ2YQ==) — Glengarry Glen Ross reel invoked to underline the winner-take-most dynamic in CRM
- [The AI job apocalypse is a complete fiction](https://www.a16z.news/p/the-ai-job-apocalypse-is-a-complete) — a16z's companion piece arguing AI expands rather than shrinks the GTM labor budget
- [Is Software Losing Its Head?](https://www.a16z.news/p/is-software-losing-its-head) — Seema Amble's companion piece from the day before, framing the same head/body separation across software broadly
- [Embedded tweet — context on AppExchange/Marketplace rent economics](https://x.com/i/status/2048425969887953277) — quoted inline in the article

## Original Content

> @steph_zhang — 2026-05-14
>
> *Article cover image*
> ![[stephzhang-128603-001.jpg]]
>
> **Article: From "System of Record" to "System of Intelligence"**
>
> Here's one way you can think about system of record stickiness:
>
> For a long time, the valuable part of social media businesses was the friend graph. When you opened Facebook back in the day, the thing you interacted with was people's profiles, and the data graph across the profiles was a powerful, durable asset. It was hard to foresee what could disrupt such an obvious network effect.
>
> Then the news feed came along. The news feed gave us a new place to go: "Here's what happened today; here's where you catch up and take action, all in one place." This started out as a complementary layer to the friend graph, but in time, the graph became "just one of many inputs" to the feed serving you relevant content. While it never went away, it's no longer the important layer - the feed algorithm is, and all kinds of things feed into it. Your social profile, posts and likes are primarily consumed "at the internal API layer", so to speak; the newsfeed is its consumer.
>
> We think this is starting to happen to one of the supposedly "least disruptable" parts of the enterprise: the CRM. The CRM isn't going to go away, just like the friend graph never went away—but it's turning into just an input; one of many inputs, into the systems of intelligence which we use to get work done.
>
> At firms across the country, the typical account executive now opens his laptop in the morning and finds, waiting for him, a small collection of software agents he had no part in programming — a research agent that combs 10-Ks and recent earnings calls before his first meeting of the day; a dialer that coaches him on objections in the moment; an orchestration layer that listens to his calls and writes structured notes back into the CRM without his lifting a finger. None of this, by itself, is earthshaking. But taken together, you recognize what this is: this is the newsfeed. It's the valuable thing now.
>
> There's no doubt: owning the system of record has been the winning play for go-to-market software for twenty years. It's sticky, valuable, and hard to leave. And we can't imagine the SoR incumbents going away anytime soon: Salesforce and HubSpot still sit on some of the most valuable datasets in the industry, they've realized that it matters, and they're quickly coming up with [API-first offerings](https://www.salesforce.com/news/stories/salesforce-headless-360-announcement/) that bring AI features in their own walls.
>
> But we think we've seen this movie before. In the next decade, you want to own the system of intelligence that pulls from the system of record, becomes the user's one-stop shop for gaining context and taking action, and turns the SoR into something that's primarily consumed at the API layer. The reasoning layer that sits above the database, and that increasingly treats the database as infrastructure, is where a new generation of companies is being built, and it's where the majority of the next decade's enterprise value of GTM software will end up.
>
> **Why the database won**
>
> Over the last thirty years, software companies have produced an unbelievable number of products to help companies manage themselves. A thousand companies were founded to help salespeople sell; but almost all the value ended up accumulating in just two names: Salesforce, today valued at around $140 billion, and HubSpot, valued around $9 billion. As the line goes, ["First prize is a Cadillac. Second prize is a set of steak knives."](https://www.instagram.com/reel/DVE0iYDDYf6/?igsh=NTc4MTIwNjQ2YQ==)
>
> *Public GTM technology companies by market cap, May 2026 — Salesforce $140B dwarfs HubSpot $9B, Klaviyo $4B, Braze $2B, ZoomInfo $1B*
> ![[stephzhang-128603-003.jpg]]
>
> The reason, everyone in the industry has long understood, is simple: Salesforce and HubSpot own the database. And the database is where all the value resides. Every call note, every pricing precedent, every contact, every stray observation about why a deal had stalled is entered into the system, and the cost of leaving it behind becomes enormous. Once that database has accumulated a few years of operational context, switching costs become, as our colleague Alex Rampell has put it, high enough that users are ["hostages, not customers."](https://a16z.com/the-greenfield-strategy-ai-native-startup-bingo/) Every app in the Salesforce AppExchange and every tool in the HubSpot Marketplace is, in effect, paying rent for the right to plug into someone else's database.
>
> Then, Salesforce and HubSpot do what every dominant platform owner in every era does: they expand outward. They add features like marketing, service, analytics, and commerce: each new module built on the same data spine, and each further raising the cost of any decision to leave.
>
> [Embedded Tweet: https://x.com/i/status/2048425969887953277]
>
> One of the more counterintuitive findings from our GTM survey is that CRM usage has actually risen since AI tools began to be adopted at scale. The agents that listen to calls and write structured notes back into the system are, for the moment, giving reps fresh reason to consult it, because the data sitting there has become dramatically richer than it used to be.
>
> *a16z GTM Survey (April 2026): daily CRM usage has increased for 39% of respondents (18% significantly, 21% slightly), stayed about the same for 49%, and decreased for only 13%*
> ![[stephzhang-128603-004.jpg]]
>
> **Orchestration is the new gravity well**
>
> AI agents, acting on behalf of sales reps and alongside them, are taking over a steadily widening share of the GTM workflow. Sometimes the rep instructs the agent directly: research this account, draft this outbound sequence, qualify these inbound leads, update this deal record after the call. Sometimes the agent works in the background, listening to a meeting recording and writing the structured fields back into the CRM on its own.
>
> *a16z GTM Survey — where work happens today, by workflow: AI tools dominate account research and meeting prep; traditional tools still dominate pipeline forecasting and CRM hygiene*
> ![[stephzhang-128603-002.jpg]]
>
> And the agent doesn't need a drag-and-drop pipeline view. What it needs is structured data it can read and write with low friction. The CRM, from the agent's perspective, is a database. A very large and carefully curated database, hosted by a trusted vendor, with excellent integrations and a decade of accumulated customer trust; but a database, nonetheless. The opinionated workflows on top become, progressively, legacy furniture - a bit like the lovingly created UI of your Facebook profile; once paramount, now an afterthought.
>
> In the software era, the gravity in enterprise software came from data accumulation: that is, from the fact that every valuable piece of sales context had to live in one place because the human operating on that context could only look in one place at a time. But in the AI era, gravity will come from orchestration. An AI agent doesn't find it difficult to pull dozens of signals simultaneously from the CRM, the calendar, the shared inbox, the call recording, Slack, the enrichment API, the billing system, and the product telemetry. Nor does it find it difficult to synthesize information across all of them before actually taking any actions.
>
> Switching costs shift accordingly. "All of our customer data is in Salesforce" becomes "all of our workflows, our reasoning, our accumulated institutional context live in our AI layer." The CRM used to tax every app that wanted access to its data; now the system of intelligence has become the hub, and the CRM is one of the many systems of record that it orchestrates across.
>
> At the technical core of the new stack sit the foundation models. But a foundation model is not, by itself, a GTM application, any more than Oracle's database engine was a CRM. Between the model and the customer sits an enormous amount of unglamorous and domain-specific work: orchestrating context across dozens of connected systems, encoding the actual logic of how sales and marketing teams operate, handling permissions and compliance, integrating with the chaotic reality of a Fortune 500 IT environment. That work is the new GTM application layer. It is where the new GTM companies are being built.
>
> Go-to-market has, for decades, been a category in which software was the junior partner to labor. Historically, software made up between 5 and 10 percent of total GTM spending in a typical enterprise; the rest is payroll. Salesforce dominates the software slice, but the software slice has always been a thin wedge of the pie. What AI opens up, for the first time, is the prospect that software companies can meaningfully reduce costs while opening up new high ROI use cases.
>
> The natural question is whether this comes at the expense of sales headcount. So far, it has not, or at least not in a straightforward way. While roles within the GTM team may shift, we're seeing teams spend even more on people. The ROIs on these agents are strong enough that the [total pie grows rather than the labor budget shrinking](https://www.a16z.news/p/the-ai-job-apocalypse-is-a-complete). Reps using these tools are hitting attainment and quota at noticeably higher rates than those without them; the return on every GTM dollar is rising, rather than merely holding steady.
>
> *Expected sales headcount change over the next 2 years: 39% expect increase, 37% expect flat, only 23% expect decrease*
> ![[stephzhang-128603-005.jpg]]
>
> **The next wave**
>
> There are two observations worth making about the AI-native GTM startups that have emerged over the last few years. The first is that they are clustering, for now, around a few relatively narrow and high-frequency workflows: in all of these workflows, inputs are structured and outputs are measurable.
>
> And while some of them are doing an existing job in a new way, many of them are inventing new jobs entirely: they are doing things that nobody was quite doing before.
>
> Consider, for a moment, the position of a VP of Sales at a typical enterprise software firm a few years hence. She no longer begins her day by opening Salesforce to a static account list and deciding where to focus. She begins it in a prioritized feed generated by her system of intelligence: which of her accounts had material news overnight, which prospects in the territory are suddenly in market, which deals in the pipeline have gone quiet in ways that ought to be investigated. The daily prioritization decision — which used to consume real cognitive effort from every rep and every sales leader in America — has been quietly offloaded to the intelligence layer. Her reps spend more of their time actually selling.
>
> And, when they sell, they arrive better prepared. Prep that used to happen case by case, if it happened at all, now happens every time as a matter of course. The rep who would never have read the 10-K is walking in with a briefing drafted for him; the new hire six weeks into the job is, by certain measures, better equipped than the ten-year veteran at the desk next to her.
>
> More importantly, the VP of Sales has an honest picture of what her team is doing. At the moment that picture is whatever gets logged into the CRM, which is often incomplete and occasionally fictional. With call transcripts, email threads, and calendar data flowing in automatically, analyzed continuously, she can see, at any given moment, who is running disciplined discovery and who is skipping steps, which accounts are getting coverage and which have been quietly neglected. A system of intelligence that has ingested every interaction across a sales team can surface patterns no human manager, however committed, could see unaided.
>
> The longer-run implications push further still, and begin to open up categories of job that did not really exist before. Every company bleeds institutional knowledge when its reps turn over — context on accounts, the history of what worked for whom, the texture of relationships built up over years. A system of intelligence that has been quietly ingesting that context for the duration of a rep's tenure can, when she leaves, hand the whole of it over to her successor. Institutional memory becomes something a company can actually ship.
>
> None of this, it should be said, is bad news for the CRM. Salesforce still owns its database; HubSpot still owns its database; the customer data continues to live where it has always lived, for the reasons it has always lived there. But the locus of value is migrating upward, into the layer that reads and writes to the database and does the actual thinking. The pie is getting larger in the process, not smaller. Just as the feed increased the TAM of social media to "everything of interest", the agent revolution expands what software can plausibly charge for, and does it without gutting the labor budget that funds most GTM work today.
>
> A new generation of companies is being built on top of this emerging layer. The next decade of go-to-market software will be written there.
>
> ---
>
> Thank you to @GioAhern and @aleximm for authoring this piece with me.
>
> Full article in the a16z Newsletter: https://www.a16z.news/p/from-system-of-record-to-system-of
>
> This is a companion to the piece from @seema_amble yesterday: [Is Software Losing Its Head?](https://www.a16z.news/p/is-software-losing-its-head)
>
> Engagement: 102 likes | 6 retweets | 11 replies
> [Original post](https://x.com/steph_zhang/status/2054925688097128603)
