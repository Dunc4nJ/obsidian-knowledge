---
created: 2026-02-04
description: If an agent captures a site’s real network endpoints once, it can switch from slow brittle UI clicking to direct authenticated API calls for most future actions.
source: https://x.com/getFoundry/status/2018751025520513391
type: framework
---

## Key Takeaways

Most “agent web use” is doing work twice: the site fetches clean JSON, the browser renders it into HTML, and the agent scrapes it back into text. Replacing UI automation with direct calls to the same underlying endpoints is a structural speedup, not a micro-optimization, because it removes the render/DOM/search/wait loop that makes browser control feel sluggish and flaky.

“Unbrowse” is the general pattern: use the browser once to observe traffic, then generate a reusable client/skill so future runs are plain HTTP. This is the same compounding dynamic that shows up in [[ralph loops prevents context pollution in long running ai builds]]: invest in a file-backed artifact (here: an API skill) so repeated work gets cheaper and more reliable over time.

Reliability improves because the failure surface shrinks. Instead of depending on CSS selectors, timing, and DOM state, the agent depends on stable backend contracts (endpoints, auth headers, parameters). This complements multi-session systems like [[multi-agent squads work when independent sessions share a mission control system]] because “hands” become less resource-intensive and easier to parallelize when actions are simple requests instead of full browsers.

A captured-API approach also changes what “tooling” means: you stop thinking in terms of “open page → click button” and start thinking in terms of “resource → endpoint → schema”. That aligns with the broader idea that agents need multiple memory/knowledge layers ([[four memory layers serve different knowledge types]]): the API map is durable declarative knowledge, while the one-time capture session is ephemeral execution.

This is not a universal replacement: some sites gate critical actions behind client-side flows, anti-bot measures, or fragile auth. But when the website already uses an internal API for the action, learning that API is often the highest-leverage way to make an agent feel instant. The same principle of separating cheap filtering from expensive execution appears in [[background agents shift alerting from reactive keyword matching to proactive semantic discovery|Fintool's alerting architecture]], where trigger mechanisms handle high-volume matching and LLMs handle semantic interpretation only for filtered results.

## External Resources

- [OpenClaw](https://github.com/openclaw/openclaw) — open-source framework for agents with “hands” (tools like shell, browser control, messaging, scheduling, and memory).
- [Unbrowse for OpenClaw](https://github.com/lekt9/unbrowse-openclaw) — captures browser network traffic and turns discovered endpoints into a callable skill/client for API-speed actions.

## Original Content

> @getFoundry — 2026-02-03
>
> Article: Unbrowse: 100x Faster Than Browser Automation
>
> Your @openclaw agent is browsing the web like a human. That's the problem
>
> Every time your agent needs to do something on a website — check prices, place a trade, submit a form — it launches Chrome, waits for JavaScript to render, finds elements in the DOM, clicks buttons, and scrapes text off the screen.
>
> This takes 10-45 seconds per action. It fails 15-30% of the time. And it requires a full headless browser eating 500MB+ of RAM.
>
> Meanwhile, every single one of those actions was just an API call wearing a button costume.
>
> The 100x Gap
>
> Here's what happens when your agent checks Polymarket odds:
>
> Browser automation:
>
> Launch Chrome 5s
>
> Load the page 3s
>
> Wait for JavaScript 2s
>
> Find the element 1s
>
> Read the text 1s
>
> ─────────────────────────
>
> Total 12s
>
> When that page loaded, it called GET /api/markets/election — a single request that returned everything as clean JSON in 200ms.
>
> Your agent spent 12 seconds doing what took the website 200 milliseconds.
>
> Now scale that. A workflow with 10 web actions: 2+ minutes of browser automation vs 2 seconds of direct API calls. That's not a small optimization. That's the difference between an agent that feels broken and one that feels instant.
>
> It's Not Just Reading
>
> This isn't only about getting data faster. Every action on the web is an API call.
>
> Click "Place Trade"? That's a POST request. Submit a form on LinkedIn? POST. Send a message on Slack? POST. Book a flight? POST.
>
> The browser is just a GUI on top of API calls. Your agent doesn't need the GUI.
>
> Browser automation (place a trade):
>
> Navigate to market 5s
>
> Find the input 2s
>
> Type the amount 1s
>
> Click "Place Trade" 1s
>
> Wait for confirmation 3s
>
> ────────────────────────────
>
> Total 12s
>
> Failure rate: ~20%
>
> Unbrowse:
>
> Done.
>
> POST /api/trades 200ms
>
> Read data. Submit forms. Place trades. Post content. Book flights. All at API speed.
>
> How Unbrowse Works
>
> Unbrowse watches what websites do, not what they show.
>
> 1. Capture — Browse a site once. Unbrowse intercepts all network traffic via Chrome DevTools Protocol. Every XHR, fetch, WebSocket, auth header, and cookie is recorded.
>
> 2. Extract — Captured traffic is analyzed to identify real API endpoints. Auth methods are detected automatically — Bearer tokens, cookies, API keys. Parameters are inferred. Endpoints are clustered by resource.
>
> 3. Generate — A complete API skill is produced: documented endpoints, TypeScript client, auth config. Your agent can now call these APIs directly.
>
> One browse session. Permanent API access. No browser needed again.
>
> The Numbers
>
> Browser Automation vs Unbrowse
>
> Speed 10-45 seconds vs 200ms
>
> Reliability 70-85% vs 95%+
>
> Resources Headless Chrome (500MB+) vs HTTP calls
>
> Data Scraped DOM text vs Clean JSON
>
> Actions Click, type, wait, pray vs Direct API calls
>
> Built on OpenClaw
>
> Unbrowse is a plugin for OpenClaw — an open-source framework for AI agents that actually do things.
>
> Open Source
>
> OpenClaw: https://github.com/openclaw/openclaw
>
> Unbrowse: https://github.com/lekt9/unbrowse-openclaw
>
> Every website already has an API. Your agent just didn't know about it.
>
> Engagement: 400 likes | 24 retweets | 14 replies
> [Original post](https://x.com/getFoundry/status/2018751025520513391)
