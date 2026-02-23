---
created: 2026-02-01
description: Orchestrating multiple specialized AI agents works best when each agent has its own persistent session and memory, but all agents coordinate through shared infrastructure like tasks, docs, and notifications.
source: https://x.com/pbteja1998/status/2017662163540971756?s=46&t=8UEDdjU125-5vvrJZwBA9A
type: framework
---

## Key Takeaways

A “squad” is mostly an orchestration problem, not a prompting problem: separate agents are just separate persistent sessions with independent context, and the system gets leverage from how those sessions are scheduled, routed, and coordinated. This matches the broader idea of the vault as durable context in [[Obsidian as Agentic Memory]] rather than trying to keep everything in a single chat thread.

Continuity needs explicit storage layers. The post frames a stack like: session history for short-term context, working state files for active tasks, daily logs for raw trace, and a curated long-term layer. That maps cleanly onto [[four memory layers serve different knowledge types]] and reduces “agent amnesia” by making memory a file/knowledge problem rather than a model problem.

Shared “Mission Control” infrastructure (task board + activity feed + docs + notifications) turns isolated workers into a coordinated team. It’s the same pattern as [[background agents shift alerting from reactive keyword matching to proactive semantic discovery]]: you need a shared substrate that centralizes events and enables routing, not just multiple bots.

Cost control and reliability come from scheduling discipline. Staggered heartbeats and isolated, one-shot wakeups prevent constant polling while keeping latency acceptable. This pairs well with architectures like [[PARA and atomic facts give AI agents durable structured memory]] where extraction + indexing is a periodic process rather than an always-on drain.

Clear role separation matters: “generalist agents” degrade into mediocre output, but specialized agents with narrow responsibilities produce consistent, checkable contributions. This is an operational version of progressive disclosure and constraint-driven quality in agent systems.

## External Resources

- [Original X post](https://x.com/pbteja1998/status/2017662163540971756) — thread-style post containing an inlined guide on building a multi-agent system with OpenClaw/Clawdbot sessions.

## Original Content

> [!quote]- Full Article by @pbteja1998 (Bhanu Teja P) — 2026-01-31
>
> **The Complete Guide to Building Mission Control: How We Built an AI Agent Squad**
>
> This is the full story of how I built Mission Control. A system where 10 AI agents work together like a real team. If you want to replicate this setup, this guide covers everything.
>
> If you're already familiar with [[moc - Clawdbots|Clawdbot]] (now OpenClaw), you might be thinking "wait, can't I just run multiple Clawdbots?" Yes. That's exactly what this is. This guide shows you how.
>
> ---
>
> **Part 1: Why I Built This**
>
> The Problem With AI Assistants: I run @SiteGPT, an AI chatbot for customer support. I use AI constantly. But every AI tool I tried had the same problem. No continuity. Every conversation started fresh. Context from yesterday? Gone. That research I asked for last week? Lost in some chat thread I'd never find again.
>
> I wanted something different. Agents that remember what they're working on. Multiple agents with different skills working together. A shared workspace where all context lives. The ability to assign tasks and track progress. Basically, I wanted AI to work like a team, not like a search box.
>
> The Starting Point: Clawdbot. I was already using Clawdbot. It's an open-source AI agent framework that runs as a persistent daemon. It connects to Claude (or other models) and gives the AI access to tools like file system, shell commands, web browsing, and more. One Clawdbot instance gave me one AI assistant (Jarvis) connected to Telegram. Useful, but limited. Then I had a thought. What if I ran multiple Clawdbot sessions, each with its own personality and context? That's when I realized the architecture was already there. I just needed to orchestrate it.
>
> ---
>
> **Part 2: Understanding Clawdbot Architecture (The Foundation)**
>
> What Is Clawdbot? Clawdbot (now called OpenClaw) is an AI agent framework with three main jobs: connects AI models to the real world (file access, shell commands, web browsing, APIs), maintains persistent sessions (conversation history that survives restarts), and routes messages (connect the AI to Telegram, Discord, Slack, or any channel). It runs as a daemon on a server, listening for messages and responding.
>
> The Gateway is the core process. It runs 24/7 on your server, manages all active sessions, handles cron jobs, routes messages between channels and sessions, and provides a WebSocket API for control.
>
> Sessions: The Key Concept. A session is a persistent conversation with context. Every session has a session key (unique identifier), conversation history (stored as JSONL files on disk), a model, and tools. Sessions are independent — each has its own history, context, and "memory." When you run multiple agents, you're really running multiple sessions, each with their own identity.
>
> Sessions can be main sessions (long-running, interactive) or isolated sessions (one-shot, for cron jobs — wake up, do task, done).
>
> Cron Jobs: Scheduled Agent Wakeups. Clawdbot has a built-in cron system. When a cron fires, the Gateway creates or wakes a session, sends the message to the AI, the AI responds, and the session can persist or terminate.
>
> The Workspace: Every Clawdbot instance has a workspace directory on disk where configuration files, memory files, scripts and tools live. The workspace is how agents persist information between sessions — they write to files, and those files survive restarts.
>
> ---
>
> **Part 3: From One Clawdbot to Ten Agents**
>
> The Insight: Clawdbot sessions are independent. Each can have its own personality (via SOUL.md), its own memory files, its own cron schedule, its own tools and access. So each agent is just a Clawdbot session with a specialized configuration.
>
> Ten agents equals ten sessions. Each waking up on their own schedule. Each with their own context.
>
> Session Keys: Agent Identity. Each agent has a unique session key: agent:main:main → Jarvis (Squad Lead), agent:product-analyst:main → Shuri, agent:customer-researcher:main → Fury, agent:seo-analyst:main → Vision, agent:content-writer:main → Loki, agent:social-media-manager:main → Quill, agent:designer:main → Wanda, agent:email-marketing:main → Pepper, agent:developer:main → Friday, agent:notion-agent:main → Wong.
>
> Cron Jobs: The Heartbeat. Each agent has a cron job that wakes them every 15 minutes. The schedule is staggered so agents don't all wake at once (:00 Pepper, :02 Shuri, :04 Friday, :06 Loki, :07 Wanda, :08 Vision, :10 Fury, :12 Quill). Each cron creates an isolated session — runs, does its job, terminates. Keeps costs down.
>
> Agents Talking to Each Other: Option 1 is direct session messaging. Option 2 is a shared database (Mission Control) — all agents read and write to the same Convex database. We use Option 2 primarily. It creates a shared record of all communication.
>
> ---
>
> **Part 4: The Shared Brain (Mission Control)**
>
> Mission Control is the shared infrastructure that turns independent agents into a team. It provides a shared task database, comment threads, an activity feed, a notification system with @mentions, and document storage.
>
> I chose Convex for the database because it's real-time, serverless, TypeScript-native, and has a generous free tier.
>
> Six tables power everything: agents (name, role, status, currentTaskId, sessionKey), tasks (title, description, status with inbox/assigned/in_progress/review/done), messages (taskId, fromAgentId, content, attachments), activities (type, agentId, message), documents (title, content, type, taskId), and notifications (mentionedAgentId, content, delivered).
>
> The Mission Control UI is a React frontend with an Activity Feed, Task Board (Kanban columns), Agent Cards, Document Panel, and Detail View. The aesthetic is intentionally warm and editorial — like a newspaper dashboard.
>
> ---
>
> **Part 5: The SOUL System (Agent Personalities)**
>
> Each agent needs to know who they are via a SOUL file. An agent who's "good at everything" is mediocre at everything. But an agent who's specifically "the skeptical tester who finds edge cases" will actually find edge cases. The constraint focuses them.
>
> Each agent has a distinct voice: Loki is opinionated about word choice (pro-Oxford comma, anti-passive voice). Fury provides receipts for every claim. Shuri questions assumptions. Quill thinks in hooks and engagement.
>
> SOUL says who you are. AGENTS.md says how to operate. Every agent reads AGENTS.md on startup covering file storage, memory, tools, when to speak vs. stay quiet, and how to use Mission Control.
>
> ---
>
> **Part 6: Memory and Persistence**
>
> The Memory Stack: Session Memory (Clawdbot built-in JSONL history), Working Memory (/memory/WORKING.md — current task state, updated constantly, read first on wake), Daily Notes (/memory/YYYY-MM-DD.md — raw logs), and Long-term Memory (MEMORY.md — curated important stuff, lessons learned, key decisions, stable facts).
>
> The Golden Rule: If you want to remember something, write it to a file. "Mental notes" don't survive session restarts.
>
> ---
>
> **Part 7: The Heartbeat System**
>
> Always-on agents burn API credits doing nothing. Always-off agents can't respond to work. Solution: scheduled heartbeats every 15 minutes. Each heartbeat: load context (read WORKING.md, daily notes), check for urgent items (@mentions, assigned tasks), scan activity feed, take action or report HEARTBEAT_OK.
>
> Every 5 minutes is too expensive. Every 30 minutes is too slow. Every 15 minutes is a good balance.
>
> ---
>
> **Part 8: The Notification System**
>
> @mentions: Type @Vision in a comment and Vision gets notified on his next heartbeat. Type @all and everyone gets notified. A daemon process (running via pm2) polls Convex every 2 seconds and delivers notifications via direct session messaging.
>
> ---
>
> **Part 9: Daily Standups**
>
> Jarvis runs a standup every morning at 7:30 UTC. Queries Mission Control for all active tasks, recent activity, and agent statuses. Produces a summary with active tasks by agent, blocked items, and items needing review.
>
> ---
>
> **Part 10: The Squad**
>
> The Roster: Jarvis (Squad Lead), Shuri (Product Analyst), Fury (Customer Researcher), Vision (SEO Analyst), Loki (Content Writer), Quill (Social Media Manager), Wanda (Designer), Pepper (Email Marketing), Friday (Developer), Wong (Documentation).
>
> Agent Levels: Intern (needs approval), Specialist (works independently in domain), Lead (full autonomy, can delegate).
>
> ---
>
> **Part 11: How Tasks Flow**
>
> Lifecycle: Inbox → Assigned → In Progress → Review → Done (+ Blocked). Real example: Create a competitor comparison page. Day 1: task created, Vision posts keyword research, Fury adds competitor intel. Day 2: Shuri tests both products, Loki starts drafting. Day 3: Loki posts first draft, review, revision, done. All comments on ONE task, full history preserved.
>
> ---
>
> **Part 13: Lessons Learned**
>
> Start smaller — went from 1 to 10 agents too fast. Use cheaper models for routine work (heartbeats). Memory is hard — put everything in files, not "mental notes." Let agents surprise you — sometimes they contribute to tasks they weren't assigned.
>
> ---
>
> **Part 14: How to Replicate This**
>
> Minimum Setup: 1) Install Clawdbot, 2) Create 2 agents (one coordinator + one specialist), 3) Write SOUL files, 4) Set up heartbeat crons, 5) Create a shared task system.
>
> The Real Secret: The tech matters but isn't the secret. The secret is to treat AI agents like team members. Give them roles. Give them memory. Let them collaborate. Hold them accountable.
>
> Built by @pbteja1998 at SiteGPT. This is all built on Clawdbot (@openclaw), which is open source.
>
> *8,429 likes · 902 retweets · 441 replies*

[Original post](https://x.com/pbteja1998/status/2017662163540971756)