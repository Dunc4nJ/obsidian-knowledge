---
created: 2026-09-05
description: Vas (CEO, Varick Agents) argues enterprises are applying AI to unchanged processes and getting faster bad processes. The spine is Michael Hammer's 1990 HBR critique of IT — "companies tend to use technology to mechanize old ways of doing business" — plus his insurance application that took 22 days elapsed against 17 minutes of actual work, so doubling every step's speed saves 8.5 minutes because the time was always in queues and handoffs. Marshals the UK Department for Business and Trade's Copilot trial (1,000 licenses, 1.14 actions per user per day, PowerPoint faster at half the quality, no robust evidence of productivity gain, 72% satisfied) and the >$1T capex versus $37B enterprise-usage gap. Argues against consolidating systems first (TSB, Zimmer Biomet) because agents tolerate inconsistency where deterministic integrations could not — standardize the process definition and owner instead. Method is department-level mapping via both process mining and operator interviews, then sorting every step into deterministic software, an agent, or a human-in-the-loop with evidence pre-assembled, turning a 25-step process into 3 agents and 2 checkpoints; baseline KPIs first, sequence by most handoffs rather than most volume. Back third is an explicit consultancy pitch with self-reported results.
source: https://x.com/vasuman/status/2095999742031675738
author: Vas (Varick Agents)
type: framework
tags: [enterprise-ai, ai-adoption, process-reengineering, coordination-costs, human-in-the-loop, agent-design, ai-consulting, roi, change-management, model-agnostic, varick]
---

## Key Takeaways

- **The whole argument is one piece of arithmetic, and it is borrowed from 1990.** Michael Hammer's insurance application took **22 days in process against 17 minutes of actual work**; make every individual step twice as fast and you have saved eight and a half minutes. "The savings were not in working on the application. They were in the queues and handoffs, in the waiting periods for other teams, and the second round of reviews." The author reproduces it from a client's own system logs — opening a new client case took 25 minutes of real work and 2 days to 2 weeks of elapsed time. This is the operational half of [[Varick Agents - AI's biggest winners are low-margin businesses where sub-1 percent cost cuts drive 25 percent profit gains|the same firm's economic thesis]], which argues the money is in attacking hidden coordination costs at low-margin firms where a sub-1% cost cut yields a >25% profit gain — this article is the method for finding those costs. The Hammer quote he leads with is genuinely arresting because it needs no updating: "Heavy investments in information technology have delivered disappointing results, largely because companies tend to use technology to mechanize old ways of doing business. They leave the existing processes intact and use computers simply to speed them up." Swap *information technology* for *AI* and it publishes tomorrow. Hammer's phrase for it — "stop paving the cow paths" — is 36 years old.

- **The strongest evidence in the piece is not the author's, and it is the satisfaction-versus-productivity gap.** The UK Department for Business and Trade published its Microsoft 365 Copilot trial: 1,000 licenses over 3 months, an average of **1.14 Copilot actions per user per day**; PowerPoint decks produced in 11 minutes instead of 18 but **at half the quality score**; Excel analysis completed *more slowly* and worse; email savings "extremely small"; and the department's own verbatim conclusion, "We did not find robust evidence to suggest that time savings are leading to improved productivity." Meanwhile **72% of users said they were satisfied or very satisfied**. That gap is the finding — people like the tool and produce exactly what they produced before, which Ethan Mollick compresses as "AI use that boosts individual performance does not naturally translate to improving organizational performance." Sits alongside the spend asymmetry: over $1T in AI capex (Microsoft, Alphabet, Amazon and Meta alone at $410B in 2025) against **$37B of enterprise spend on actually using it**, roughly 11 to 1.

- **The three-bucket sort is the transferable method, and its gate for the agentic bucket is unusually concrete.** Every process step is **Deterministic** (plain software — "cheap, auditable, deterministic (never hallucinates), and fast"), **Agentic** (requires *thousands of past examples of humans making that judgment with the outcome recorded*, low enough risk, and ideally a yes/no, a route-to-this-team, a flag, or a match), or **Human-in-the-loop** (too risky or too little history — but the agent still assembles every piece of evidence at the moment of decision, turning 40 minutes of hunting through emails and invoice records into a 30-second call). The line worth keeping is **"judge the difficulty of the action, not the difficulty of the thinking"** — a 5-page document a human must read in full to verify is a bad agent target however hard the reasoning was. Sorted this way, a 25-step process becomes 3 agents with deterministic code around them and 2 human checkpoints. Note what the agentic gate really is: a *data-availability* test, not a capability test — the same precondition [[model-market fit is the prerequisite layer beneath product-market fit for AI startups|model-market fit]] identifies beneath product-market fit, and the reason [[domain-specific agents beat general-purpose ones by owning verification in boring industries|domain-specific agents win by owning verification in boring industries]]: those are precisely the places with thousands of recorded human judgments to learn the boundary from.

- **Two sequencing rules cut against the default, and both follow from the arithmetic.** First, **do not consolidate systems first**: TSB spent £318M on a core banking migration, ate roughly £200M more in incident costs, was fined £48.65M, and broke banking for 5.2 million customers; Zimmer Biomet filed a $172M claim against Deloitte in September 2025 after a botched consolidation left it unable to ship product or invoice customers. The argument for why this is now optional is the interesting bit — "deterministic integrations used to break the moment that 2 systems disagreed about what a vendor record was. However, agents tolerate this inconsistency, so an orchestration layer that sits across the systems you already have IS the solution to disparate systems." What you *do* have to standardize is the **single process definition and a single owner**, otherwise nine acquisitions means building and maintaining the same agent nine ways forever. Second, **sequence by the workflow with the most handoffs, explicitly not the most volume** — which is the direct operational consequence of the time living in coordination rather than work.

- **The discovery method insists on two procedures, and he is blunt that either one alone fails.** Start at the **department level**, not a single workflow — "you spend 8 weeks perfecting something that turns out to be gated by a sister process upstream, and end up with net 0 ROI." Then map seven things per workflow, of which the sharp ones are: what **share of volume leaves the happy path** and what it costs; which system of record **wins when two disagree**; how it differs by region, entity, and *which acquisition it came in through*; and **touch time versus elapsed time at every single step**. Getting there needs *both* process mining against the systems of record ("the reality that does not match documentation") *and* operator interviews, because "the reality of your organization lives in the heads of 10-20 people who have been doing this exact work for your exact company for years." Doing only one "is the biggest reason why AI discovery fails," and he specifically names 'AI interviews' and sending engineers to conduct them as shortcuts that don't work — half the job being the relationship with the operators who must adopt the thing.

- **The organizational diagnosis is better than the usual version of it, and it explains the inertia without calling anyone stupid.** "Whoever signs an AI contract today may own tooling and vendor selection, but they certainly do not own the process. Nobody in that chain is empowered to walk into finance and say that their 14 step process should actually only be 5 steps. So nobody does it." Redesigning across four departments requires someone who can tell all four the process is changing, which is a handful of people at the top — while the operators must simultaneously *want* it, including wanting to divulge information they may think can replace them. And the incentive is inverted: "the status quo is 'safe' for most people, who get no promotion if AI works, yet get fired if it doesn't." He also concedes the historical failure rate honestly — Hammer and Champy's own 1993 estimate that **50-70% of re-engineering attempts failed**, and Hammer's later admission that he had been "insufficiently appreciative of the human dimension" — then argues what differs now is that the work being eliminated is coordination (chasing, waiting, escalating, triaging) rather than whole jobs.

- **Read the second half as marketing, because it is.** The results section — month-end close 18-22 days down to 7-9, AP exceptions 600-800/month down to under 50, deals idle 23 days down to 6, payroll corrections down 90%, "over $100M" in total value — is self-reported and unaudited, with no denominators: how many deployments, over what period, measured against what baseline, and with what selection of which engagements get reported. The vendor critique similarly defines a category that only the author fills ("all three, in the same room"), and the swipe at OpenAI's DeployCo and Anthropic's Ode forcing you to "marry their models for life" arrives directly before the pitch. The historical material and the UK trial are checkable and carry the note; the deployment numbers are not — though the insistence on baselining KPIs before building is the right instinct, and matches why [[boring domain-specific AI businesses survive bubbles because measurable ROI and regulation moats beat general-purpose wrappers|measurable per-outcome ROI is the durable moat]]. The one forward-looking claim worth separating from the sales copy is **model-agnostic harnesses** — his point that swapping an endpoint is not the cost, and that rerunning eval suites and re-determining thinking levels per model call is the painstaking part the labs will not help with, is a real and under-priced form of lock-in.

## External Resources

- Source: [Applied AI Doesn't Work](https://x.com/vasuman/status/2095999742031675738) — Vas (@vasuman), CEO of [Varick Agents](https://www.varickagents.com/), X Article, 4 Sep 2026
- Michael Hammer, ["Reengineering Work: Don't Automate, Obliterate"](https://hbr.org/1990/07/reengineering-work-dont-automate-obliterate) — Harvard Business Review, July 1990; the source of the quote and of "stop paving the cow paths"
- [UK Department for Business and Trade M365 Copilot trial](https://www.gov.uk/government/publications/microsoft-365-copilot-experiment-summary-findings) — 1,000 licenses, 3 months, the 1.14-actions-per-day and no-robust-productivity-evidence findings
- Ethan Mollick (Wharton) — "AI use that boosts individual performance does not naturally translate to improving organizational performance"
- Cases cited: TSB core banking migration (£318M + ~£200M incident costs + £48.65M FCA/PRA fine, Dec 2022, 5.2M customers) · Zimmer Biomet's $172M claim against Deloitte (Sept 2025)
- Companion note from the same firm: [[Varick Agents - AI's biggest winners are low-margin businesses where sub-1 percent cost cuts drive 25 percent profit gains]]

## Original Content

> [!quote]- Full X Article (Vas / @vasuman, "Applied AI Doesn't Work", 4 Sep 2026)
> Article: Applied AI Doesn't Work
>
> The world has spent a fortune on AI. For most enterprises, nothing changed. I've spoken to over 300 CEOs, CIOs and CFOs at the largest companies on Earth. I learned most companies apply AI onto their garbage processes, and the end result is just making garbage faster. Whether it's buying thousands of Claude Code licenses, committing $50M in annual token spend, or running AI training sessions over Zoom, I've seen first-hand how inefficient AI adoption has been. It doesn't have to be this way.
>
> We've already gone down this path, multiple times in fact, and we ought to learn from history when it comes to AI adoption. My hope is that by the end of this article, AI leaders around the world stop with their archaic and naive methodology of AI application, and instead follow the tried and true process illustrated below.
>
> # Part 1: History and its Parallels
>
> In 1990, a former MIT computer science professor by the name of Michael Hammer wrote an article for the Harvard Business Review. He had already spent years inside companies that spent enormous amounts of money on computers yet achieved very little ROI, and he was among the first to uncover why.
>
> > "Heavy investments in information technology have delivered disappointing results, largely because companies tend to use technology to mechanize old ways of doing business. They leave the existing processes intact and use computers simply to speed them up."
>
> That's a real quote. Are you kidding me? If you swapped out 'information technology' for 'AI', you could publish that tomorrow and be on the front page of Business Insider. In the same piece he wrote that it is time to stop paving the cow paths. It's been 36 years since, and guess what we're still doing?
>
> Note: To pave the cow paths means to automate, formalize, or lock in an existing inefficient process instead of redesigning it for how things should work. Saved you the trip to Claude, you're welcome.
>
> Meanwhile, over $1T was spent in capex, building out AI (Microsoft, Alphabet, Amazon, and Meta alone spent $410B in 2025; eye-watering, I know), yet only $37B was spent by enterprises on actually using it.
>
> *$410B of 2025 capex from Microsoft, Alphabet, Amazon and Meta against $37B of enterprise spend on actually using generative AI — about 11 to 1, same year.*
> ![[varick-applied-ai-001.jpg]] What that means in practice: The UK's Department for Business and Trade ran a Microsoft 365 Copilot trial and published the results. 1,000 licenses were rolled out over 3 months, and there was only an average of 1.14 Copilot actions per user per day. PowerPoint slides came out 7 minutes faster (18 minutes down to 11), but at half the quality score. Excel analysis was actually completed more slowly (and also worse quality). Email time savings were, and I quote, "extremely small." Their own conclusion, verbatim: "We did not find robust evidence to suggest that time savings are leading to improved productivity." And yet 72% of users said they were satisfied or very satisfied.
>
> Long story short: the people liked it, yet they were producing exactly what they were before. Ethan Mollick (Wharton Associate Professor and AI Researcher) put it best: "AI use that boosts individual performance does not naturally translate to improving organizational performance." This article will expand on why that is, and offer solutions that we've seen work for us in practice.
>
> For context, I'm Vas, the CEO of @varickagents. We work with extremely large companies (between $500M and $100B in revenue, 1k to 100k employees), helping them adopt AI, from general strategy, to process re-engineering, to building, deploying, and managing their agents. This article is based on learnings we've derived: what separates AI pilots that fail (no measurable ROI) from those that succeed (80%+ of the work is handled entirely by an agent, saving time and money).
>
> The reason this keeps happening isn't sheer stupidity. Some of it is that, of course, but most of it is inertia and design. Whoever signs an AI contract today may own tooling and vendor selection, but they certainly do not own the process. Nobody in that chain is empowered to walk into finance, for example, and say that their 14 step process should actually only be 5 steps. So nobody does it. Instead, you 'apply AI' on what you currently have, and you end up with faster sh*t.
>
> AI isn't supposed to be 'applied'. That doesn't work. You 'apply' a coat of paint. Too many people are thinking about AI like a fresh coat of paint, and paint doesn't fix what's underneath. Nobody ever said 'applied cloud' or 'applied digital'. No, instead they said Digital Transformation, Cloud Modernization, because everyone understood that those were transformations, and that the technology was only a part of them. AI takes the same shape.
>
> Back to Hammer: his best number is from an insurance company he studied. An application took 22 days to move through the business. Of those 22 days, the total time anybody spent working on it was 17 minutes. Suppose, today, your AI guy drops the best model in the world onto that process and it makes every individual step twice as fast. He's now saved 8 and a half minutes. He chalks that up as 50% time savings, gets his promotion and bonus, and rides off into the sunset. It's 8 minutes.
>
> *One insurance application: 17 minutes of actual work inside 22 days in process. Make every step twice as fast and it is still 22 days — 8 and a half minutes saved. "The time was never in the work."*
> ![[varick-applied-ai-002.jpg]]
>
> The savings were not in working on the application. They were in the queues and handoffs, in the waiting periods for other teams, and the second round of reviews. Spending your energy speeding up the 17 minutes is worse than doing nothing; you just spent your budget, and proved to your board that 'AI doesn't work'. You might think this is a relic of the 90s, but it's not. We worked with a company that went through this exact problem, from its own system logs. Opening up a new client case took 25 minutes of real work. The elapsed time, from the case being entered to it going active, ran anywhere from 2 days to 2 weeks. The work can be minutes while the process can still be weeks.
>
> When I say most AI programs are making sh*t faster I mean that literally. The process is sh*t. AI is making it faster. To which I've heard: "well we're a massive company, so clearly we're doing something right, and we don't need to change." Adapt or die is alive and well today, more so than ever, and this is the one place AI differs from digital and cloud. Used properly, AI gives a competitor leverage over you that those never did. Whether it's to undercut you on cost, scale infinitely without processing headcount, or outreach the entire world before you can put together a lead list, they will crush you. Best case you continue growing, and now your headcount scales exponentially. 3 analysts become 6 but the 6 now need a manager, and given it's 2 teams, they need a handoff that didn't exist before, and now that handoff needs a status meeting and a PM, etc etc. This is why headcount charts bend upwards, while revenue-per-employee doesn't.
>
> *Three analysts on one team become six across two teams, plus a manager, plus a PM, plus a handoff that did not exist before. Headcount 3 to 8, output 2x, revenue per employee down.*
> ![[varick-applied-ai-003.jpg]] Adapt or die, but don't pretend AI isn't happening. Your competitors are stopping at nothing to figure this out.
>
> # Part 2: What to do Today
>
> Your data is a mess and your systems don't talk to each other, so maybe your first instinct is to fix this before touching anything else. You just need one ERP, one CRM, one data platform, then AI on top. That sounds great in theory, but IT specialists understand that it is never this simple. Take a look at what this actually costs, in both money and time.
>
> TSB spent £318M on a core banking migration, ate roughly £200M more in incident costs, was fined £48.65M by the FCA and PRA in December 2022, and broke banking for 5.2 million customers. Zimmer Biomet, an $8B manufacturer, filed a $172M claim against Deloitte in September 2025, after a botched 'migration and consolidation' left them unable to perform basic functions, like ship their product, invoice their customers, or produce functional sales reporting. And those are just the two examples that made the news; incidents like these are far more common than you may think.
>
> What you should focus on settling is process, instead. Say you've bought 9 companies over the last 20 years, meaning you now have the same process that runs 9 different ways across your 9 subsidiaries. If you want to 'apply' AI across your company, you'll have to build the same agent 9 different ways, and then be forced to maintain all 9 sets of agents, in perpetuity. To avoid this purgatory, you need to first define the single process that runs globally, which you roll out across your entire entity, before you even think of applying AI on top of that.
>
> Conversely, you don't NEED one ERP. Deterministic integrations used to break the moment that 2 systems disagreed about what a vendor record was. However, agents tolerate this inconsistency, so an orchestration layer that sits across the systems you already have IS the solution to disparate systems. Your systems don't just need to talk to each other, they need to be happily married, tolerating each other's faults.
>
> ## Start mapping
>
> To redesign your business you need to first understand it. You don't get to this level of understanding by picking a single workflow, where you spend 8 weeks perfecting something that turns out to be gated by a sister process upstream, and end up with net 0 ROI.
>
> At the same time, however, you can't just ingest the entire business at once, you simply must start somewhere. Start at the department level. It's not going to be perfect - finance touches sales every time revenue recognition depends on how something was sold. HR touches IT and Ops on every new hire. But at least this way, you identify 'bundles' of workflows that feed into the same department (for example, Finance contains AP, AR, FP&A, Billing, Banking, Reconciliations, etc), and you can begin mapping out the following 7 details:
>
> 1. The 'happy path': what is this workflow responsible for, and what happens in the most ideal scenario. For most companies, this is about the only thing that's truly documented to a T.
>
> 2. The exceptions. This is where most of your time goes. Don't just describe what happens, go in and calculate what share of volume leaves the happy path, where it goes, who gets pulled in, what the cycle time is for these exceptions to be handled, and what the cost of an error is here.
>
> 3. What's upstream and downstream of this workflow? How does this process interact with those, when things are late or go wrong in each?
>
> 4. What are all of the systems of record involved, and which one wins when 2 of them disagree?
>
> 5. How does this differ by region, by entity, by subsidiary, by which acquisition it came in through?
>
> 6. What is the touch time vs the elapsed time, and how does the gap vary at every single step?
>
> 7. What is every single person in the function's AI-ability, and what degree of ownership should they have over a future-state AI system? (Calculating this is subjective and varies heavily).
>
> There are two procedures required to extract the above information:
>
> - Process mining against the systems of record to farm actions, timestamps, throughput, edits, and the reality that does not match documentation.
>
> - Interviews, because the above will give you data but conversations with operators will tell you exactly where the pain is. The reality of your organization lives in the heads of 10-20 people who have been doing this exact work for your exact company for years, and at the end of the day your AI needs to be adopted by these people in order for it to work effectively.
>
> Doing only one of these steps leaves you with an incomplete picture, and is the biggest reason why AI discovery fails. I've seen Applied AI firms try to take shortcuts with 'AI Interviews', or by sending engineers to do the interviews. This doesn't work. Half the job is developing a strong relationship with the operators, and knowing what questions to ask them, so that you leave with a good understanding of what to build and how to deploy it.
>
> ## Agents that work aren't just LLM calls
>
> Process redesign is a sorting exercise that requires software and AI experience. Every step falls into one of 3 buckets:
>
> Deterministic. If X then Y, with no judgment involved. For example, if the invoice is under a certain dollar amount threshold and it matches the PO & goods receipt, then you pay it. If the disclosure names a competitor, then route it to the conflicts team. These actions are best as plain, good old software. You don't need a fancy LLM call if you can do it instead with regular code, which is cheap, auditable, deterministic (never hallucinates), and fast.
>
> Agentic. If you have thousands of past examples of humans making a judgment call with the outcome recorded, and this step is low enough risk (for example, deal desk approvals, or GL coding), you should absolutely use an LLM for judgment. Especially if the output is a yes/no, a route-to-this-team, a flag/don't flag, or a match/don't match, ship this with an agent and measure every output. On the other hand, if the output required is 5 pages of a document that a human has to read in full to verify anyways, then you're better off hybridizing the approach. Here, you need to judge the difficulty of the action, not the difficulty of the thinking.
>
> Human-in-the-Loop. For steps that are too risky, or don't have enough historical context, you're better off keeping the human in the loop, because the cost of an agent getting an action wrong is far too high. Instead, put every relevant piece of evidence in front of that human at the moment they decide. For example, an agent will detect a mismatch between an invoice and a purchase order, and then present the human with 3 options: approve anyways, reject plainly, or provide feedback and route to someone else. The agent just saved your human 40 minutes of hunting through emails, invoice records, and more, so that instead, they can make a decision in 30 seconds. But the final action is still gated by that human.
>
> Once you've sorted every step into one of the 3 buckets above, you can turn something like a 25 step process into a cluster of 3 agents, with deterministic steps before and after, and finally 2 points of human-in-the-loop action to unblock.
>
> *The same 25 steps, sorted: 9 run as plain software, 14 carried by three agents, 2 left to a person. "Nobody works faster. Most of the steps stop needing anybody."*
> ![[varick-applied-ai-004.jpg]] This process re-engineering work, in conjunction with the agents themselves, is where all of the ROI lives.
>
> After this, you baseline KPIs before building anything. Your goal is to calculate the numbers behind the process you're solving for, including where and how those numbers are measured today. If you can't do that, this project is destined to fail. You need to be able to look back 12 months from now and say: we used to be at X, and now we are at 3X, or 10X, or 100X, thanks to the agents that we built. Only then can you say this project was truly a success.
>
> Finally, you prioritize and sequence your build. First, tackle the workflow with the most handoffs, as this is likely the lowest hanging fruit where you can see the clearest results. The key distinction is that this is not necessarily the same workflow with the most volume.
>
> ## What does this look like in practice?
>
> We re-engineered a global business reconciling 300+ bank accounts every month. 2/3 of them were handled by an offshore team, and the rest split across 2 other regions in 3 different formats, but entirely in Excel. There were 12,000+ open reconciliation items, and 4 days at the start of every month were spent obtaining statements. Their reconciliation process took almost the entire month, every month.
>
> Their workflow before we re-engineered was as follows (and before you make fun of them, recognize you definitely have processes like this, if not worse, at your own company):
>
> *Before and after on the same 300 bank accounts: 12 steps spanning most of a month collapse to three — statements arrive on a feed (software), rules match and an agent builds every exception (agent), a person works the queue. "Matching was never the problem."*
> ![[varick-applied-ai-005.jpg]]
>
> 1. Chase and collect statements from each bank, in whatever format they provide
>
> 2. Normalize them into the regional workbook
>
> 3. Pull the ledger extract
>
> 4. Match line by line
>
> 5. Flag what doesn't match
>
> 6. Email a local controller for context on the flagged items
>
> 7. Wait for their reply
>
> 8. Chase the reply if unanswered
>
> 9. Finally get the reply, then post the adjustment
>
> 10. Roll the region into the consolidated file
>
> 11. Do that entire 1-10 step process again for each of the 2 other regions, each in its own format.
>
> 12. Close.
>
> If you make each of those steps faster, the matching gets faster. The issue is, matching was never the problem. The 4 days of waiting for statements, and the email to the controller in another timezone, and the reply still taking 3 days, are. By making matching faster, you would shave hours off a process that is measured in weeks.
>
> We instead redesigned their process to be 3 steps.
>
> 1. Statements arrive on a feed, conveyor belt style, instead of being chased. This has absolutely nothing to do with AI.
>
> 2. Everything that can be matched based on rules will be matched automatically, and if not, an agent will assemble the case end-to-end: with the item itself, historical categorizations, evidence gathered from various systems of record, and a proposed next step.
>
> 3. Finally, a human works through their queue of exceptions, with the evidence prepared for their review, instead of them having to manually sift through data scattered across ERPs and spreadsheets.
>
> Chasing, emailing, waiting, re-keying, and regional roll-ups were eliminated entirely. This is the difference between an agent system that saves minutes and hours, and an agent system that saves weeks.
>
> # Part 3: Why isn't this more common?
>
> You were lied to
>
> The AI pitch you received was misleading from the start. AI adopted as a point solution is not something that you derive value from. You cannot do this from just IT, and you cannot do this from an 'innovation function' with a $1M budget and 0 authority. Redesigning a process that spans 4 departments requires somebody who can tell all 4 departments that the process is changing. There are only a handful of people in a company that can really do this; it has to come from the top.
>
> But another degree of complexity: the people actually doing the work today, e.g. the head of accounts payable, and the operators and analysts across finance, also need to be included. They have to want the new AI system, because they have to adopt it and push it tomorrow. They have to want to divulge information that they think can potentially replace them, even if that is not the case a majority of the time.
>
> And most importantly, adopting AI is seen as risky. The status quo is 'safe' for most people, who get no promotion if AI works, yet get fired if it doesn't, even if sticking to the status quo means letting the company die a slow death over time.
>
> ## Re-engineering is quite hard
>
> Hammer and Champy's own estimate in 1993 was that as many as 50% to 70% of the organizations that attempted process re-engineering did not achieve the results they intended. (Clearly not much has changed since the 90s). Hammer himself said later that he had been "insufficiently appreciative of the human dimension." What he meant was that 'removing a handoff', at that time, meant firing the person responsible for that handoff (that was their entire job), and then asking everyone else to change their work, while the 'software' of the time didn't support such a change. Which means that after the consultants came and went, the org structure and process quickly went back to its original state: one riddled with inefficiencies and errors.
>
> Today, however, two things are fundamentally different. First, AI-native tooling offers an unprecedented fluid software state: one that can adapt to the changes around it. An agent sitting in your system of record can run handoffs that used to rely on people, simultaneously handling discrepancies around it from deterministic software, and is also immune to variance common in humans. Second, the work that you are eliminating first is almost entirely coordination, that is: chasing, waiting, escalating, triaging, etc. After these process improvements, and a real AI transformation, all that remains is high-judgment, high-leverage work, which your best people should be spending all of their time doing anyways.
>
> ## A brave new world
>
> Traditional consultancies are decent at process work, I'll give them that. Indeed, if you want an elaborate illustration of a 15-step process that spans 10 countries and 3 entities, your run-of-the-mill consulting firm will produce the most beautiful slide you have ever seen, for $300,000. What this consulting firm cannot do is the latter, more important half, which is knowing what a model can and cannot be trusted with, what an agent that runs 40,000 times in a month costs, which model (Fable 5.1, vs Gemini 3.8 Flash) to use for which style of task (GL Coding vs Deal Desk Routing), how to design an eval suite optimally for a particular process, and which of the 3 buckets above (Deterministic, Agentic, HITL) a given step in a process truly belongs in. And thus, if you go this route, your redesign is created by consultants who are guessing, as opposed to experienced AI-native strategists and FDEs, and 6 months later you wonder why your pilot crash-landed.
>
> AI labs and companies, on the flip side, have the opposite problem. They can build an agent (most of the time, at least), but they've never sat down with both finance and operations to break down a workflow where both departments disagree about ownership and who is upstream of whom, so instead they'll slap AI onto a broken process and call it automated, instead of gutting and redesigning that process like it should have been months ago. Furthermore, the biggest 'applied AI' labs like OpenAI (DeployCo) and Anthropic (Ode) will force you to marry their models for life. Betting your entire company's intelligence stack on a single provider is suicide. Tomorrow, as they rate limit, quantize, price-hike, and retire the model you're running on, you're left with the mess, and the bill. You may think it's as simple as swapping an endpoint from Claude to GLM or Gemini or DeepSeek, but it isn't. Rerunning evals and redetermining which level of thinking to use per model call is a painstaking process, and the labs will not help you do this.
>
> What you need instead is the best of both worlds combined:
>
> *Their scorecard for who can actually do this — has run the function / ships into the ERP / knows what the model can do — across a consultancy, an AI shop, a typical FDE, and "what you need." A dash means mediocre.*
> ![[varick-applied-ai-006.jpg]]
>  people who have actually run a finance, operations, sales, or HR function, combined with the engineering talent to ship production-grade software into ERPs like Microsoft Dynamics or CRMs like Salesforce, combined with AI engineers who can build model-agnostic company-harnesses with built-in enterprise-level governance and eval-suites. Some refer to these people as 'Forward Deployed Engineers', but the truth is most FDEs today are mediocre engineers, and mediocre consultants, with absolutely no AI ability, and you end up with basically nothing being done well.
>
> ## What does this look like when you do it right?
>
> There are 4 levers that matter when you're transforming a company with AI: cost (ideally reduced), revenue (ideally increased), time (ideally faster), and risk (ideally lower). Across our deployments, roughly half of them at public companies, here are examples of what actually moved, lever by lever:
>
> - Time. We brought the month-end close process down from 18-22 days to 7-9 days. Supply chain disruptions are now triaged in under 6 hours, as opposed to several days.
>
> - Revenue. Deals used to sit idle for an average of 23 days; now the average is 6 days, and rep admin time dropped from 38% of the week to 14%. This time went straight back into selling.
>
> - Cost. AP exception handling went from 600-800 invoices per month to under 50. In a marketing org, 8-12% of the media budget was recovered from pacing errors that used to surface only at month end, saving millions per quarter.
>
> - Risk. Payroll corrections fell 90%, because the reconciliation across systems now ran before payroll instead of after. 80% of employee support queries were answered from the company's own policy documents, while edge cases still escalated to a human in HR.
>
> In total, the value delivered across this set of deployments was over $100M. The best part is that this number was co-created with our clients; it's not just us saying it, it was measured.
>
> ## What does a real AI Transformation Company look like?
>
> Everything described above is how we do things at Varick, and it's the only approach that has worked for the companies we've rolled AI out for. These are incredibly large enterprises, with thousands of people, dozens of systems of record, and infinite complexities, yet the playbook is the same, and it works every time.
>
> Our pod of Strategists and Engineers come in at the department level to first map how the work actually happens, not just accept how it's documented, through a combination of process mining and interviews, calculation of elapsed time vs touch time, mapping of the exceptions, upstream effects, and downstream effects, and understanding of who owns what. Instead of months, we complete this process in just a few weeks, at which point you receive your redesigned process, the value to be captured, custom baselined KPIs, and the priority ranking order in which the agents would get built. Next, we would begin building the agents, which come equipped with enterprise-level governance, auditability, eval-suites, and monitoring out-of-the-box.
>
> We work with companies doing over $500M in revenue, tackling their toughest workflows, across product, finance, sales, procurement, operations, HR, and more. If you want to see what this looks like against one of your own processes, [book a call](https://cal.com/team/varick-agents/discovery-call) on our website, and come prepared to talk about your least favorite workflows, and what makes them so complex. And if you found this content helpful, [subscribe to our newsletter](https://www.varickagents.com/newsletter), where we put out weekly write-ups on the latest in 'Applied' AI, and everything we've learned by doing.
>
> ## TLDR
>
> - Most of the AI spend in the enterprise today is being applied on top of the exact same processes that were already there, which means all you are really doing is making a bad process run faster. Michael Hammer said this about IT back in 1990, and the UK government basically proved it again in 2025 with 1,000 Copilot licenses: 1.14 actions per user per day, no productivity gain that they could find, and 72% of the users were satisfied anyways.
>
> - The time was never in the work itself, it was in the queues and the handoffs. Hammer's insurance application sat for 22 days in process, with 17 minutes of actual work in it. Even if you make the work twice as fast, you have saved 8 minutes.
>
> - Consolidating your systems first (one ERP, one CRM, one data platform) is a well documented way to lose 2 years and 9 figures before you see a single dollar of value. What you actually need is one definition of the process and one owner, because agents can tolerate systems that disagree with each other, and deterministic integrations never could.
>
> - Start at the department level, mine the systems of record and interview the operators, and then sort every single step into one of the 3 buckets: deterministic software, an agent, or a human in the loop with the evidence prepared for them. Done properly, a 25 step process becomes 3 agents with 2 human checkpoints.
>
> - When we did it this way, month-end close went from 18-22 days down to 7-9, AP exceptions went from 600-800 a month down to under 50, payroll corrections fell 90%, and the total across our deployments came out to over $100M, measured together with the clients.
>
> - None of this works unless it comes from the top, the operators actually want it, and whoever you hire has process people, software engineers, and AI engineers all in the same room, and almost nobody has all three.
