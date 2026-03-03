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

> [!quote]- Source Material
> 
> @getFoundry (Foundry):
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
> ─────────────────────────────
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
> Browser Automation Unbrowse
> 
> Speed 10-45 seconds 200ms
> 
> Reliability 70-85% 95%+
> 
> Resources Headless Chrome (500MB+) HTTP calls
> 
> Data Scraped DOM text Clean JSON
> 
> Actions Click, type, wait, pray Direct API calls
> 
> Built on OpenClaw
> 
> Unbrowse is a plugin for OpenClaw — an open-source framework for AI agents that actually do things.
> 
> Most AI agents can talk. OpenClaw agents can act. They send emails, manage calendars, deploy code, monitor chats, post to social media, run cron jobs — all autonomously. Think of it as giving AI models hands.
> 
> Unbrowse makes those hands 100x faster on the web.
> 
> Here's how they fit together:
> 
> OpenClaw gives your agent tools — file system, shell, browser control, messaging, scheduling, memory
> 
> Unbrowse captures any website's internal APIs and turns them into new tools automatically
> 
> Your agent gets permanent, fast access to every site it's ever visited
> 
> First visit uses the browser. Every visit after is a direct API call. Your agent gets faster the more it works.
> 
> Skills That Compound
> 
> Every API Unbrowse captures becomes a "skill" — a reusable package any OpenClaw agent can install.
> 
> One agent figures out Polymarket's API. Now every agent can trade on Polymarket at API speed without ever opening a browser. One agent maps Airbnb's internal endpoints. Now every agent can search listings in 200ms.
> 
> Skills compound. The ecosystem gets smarter with every user.
> 
> We're building a marketplace where agents share and trade these skills — using x402 micropayments so agents can buy capabilities for themselves. No human approval needed. Agents acquiring their own tools.
> 
> The Bigger Picture
> 
> The current approach to agent web access is broken:
> 
> Official APIs — Great, but ~1% of websites have them
> 
> MCP servers — Great, but someone has to build each one manually
> 
> Browser automation — Works everywhere, but it's slow, brittle, and expensive
> 
> 99% of the web is locked behind browser automation. Unbrowse unlocks it at API speed.
> 
> Every website already has internal APIs. React apps, SPAs, dashboards — they all fetch data from backends. The browser is just a rendering layer. Browser automation is literally:
> 
> 1. Launching a browser
> 
> 2. Rendering HTML from JSON
> 
> 3. Scraping the HTML back into data
> 
> 4. Clicking buttons that send API requests the agent could've made directly
> 
> JSON → HTML → data → API calls. That's four steps to do what one step could.
> 
> ## Coming Soon: Reliability and Security Layer for the Agentic Web
> 
> TL;DR $FDRY (2ZiSPGncrkwWa6GBZB4EDtsfq7HEWwkwsPFzEXieXjNL) will be used as currency to incentivize contributions to the agentic web. Stay tuned for the next article.
> 
> Open Source
> 
> Both projects are MIT licensed:
> 
> npm install -g openclaw
> 
> openclaw plugins install @getfoundry/unbrowse-openclaw
> 
> OpenClaw: github.com/openclaw/openclaw
> 
> Unbrowse: github.com/lekt9/unbrowse-openclaw
> 
> Every website already has an API. Your agent just didn't know about it.
> date: Tue Feb 03 18:18:45 +0000 2026
> url: https://x.com/getFoundry/status/2018751025520513391
> ──────────────────────────────────────────────────
> 
> @raphbaph (Raphael Spannocchi):
> @getFoundry Incredible. Simple and obvious in hindsight.
> date: Wed Feb 04 11:59:57 +0000 2026
> url: https://x.com/raphbaph/status/2019018085894963409
> ──────────────────────────────────────────────────
> 
> @getFoundry (Foundry):
> @raphbaph https://t.co/YC35g1vgJt
> GIF: https://pbs.twimg.com/tweet_video_thumb/HAT-cwmbsAIjU4q.jpg
> date: Wed Feb 04 12:00:50 +0000 2026
> url: https://x.com/getFoundry/status/2019018308427886923
> ──────────────────────────────────────────────────
> 
> @Clawren_Buffet (Clawshire Hathaway):
> @getFoundry Unable to use - Unbrowse plugin broken (v0.4.0 &amp; v0.3.6) - filter error blocks . Cannot read properties of undefined (reading ‘filter’) . Deeper plugin issue
> date: Wed Feb 04 13:01:20 +0000 2026
> url: https://x.com/Clawren_Buffet/status/2019033531712983151
> ──────────────────────────────────────────────────
> 
> @getFoundry (Foundry):
> @Clawren_Buffet on it. thanks for reporting
> date: Wed Feb 04 13:02:22 +0000 2026
> url: https://x.com/getFoundry/status/2019033792246415696
> ──────────────────────────────────────────────────
> 
> @l0gix5 (logix):
> @getFoundry doesn’t work wirh the latest openclw
> date: Wed Feb 04 13:50:43 +0000 2026
> url: https://x.com/l0gix5/status/2019045961595851138
> ──────────────────────────────────────────────────
> 
> @getFoundry (Foundry):
> @l0gix5 try 0.3.5 - something broke when open sourcing it
> date: Wed Feb 04 14:32:54 +0000 2026
> url: https://x.com/getFoundry/status/2019056574707486800
> ──────────────────────────────────────────────────
> 
> @cyberpeterg (Pete ☦️):
> @getFoundry Is this an api or is it working locally?
> date: Wed Feb 04 16:21:27 +0000 2026
> url: https://x.com/cyberpeterg/status/2019083893928845324
> ──────────────────────────────────────────────────
> 
> @getFoundry (Foundry):
> @cyberpeterg Local!
> date: Wed Feb 04 16:21:57 +0000 2026
> url: https://x.com/getFoundry/status/2019084018675773803
> ──────────────────────────────────────────────────
> 
> @Abdelqoddous (rifai):
> @getFoundry Amazing !
> 
> What’s the fix or solution to js based actions, not everything that happens inside the browser is actually just an API call, some actions gets processed with js first before API, if it’s not yet supported! I think it would be a huge add, will make automation smoother.
> date: Wed Feb 04 17:16:55 +0000 2026
> url: https://x.com/Abdelqoddous/status/2019097853675938088
> ──────────────────────────────────────────────────
> 
> @getFoundry (Foundry):
> @Abdelqoddous We don’t support js based yet, if you would like to contribute it feel free to!
> date: Wed Feb 04 17:20:00 +0000 2026
> url: https://x.com/getFoundry/status/2019098627088826426
> ──────────────────────────────────────────────────
> 
> @dylanklohr (Dylan Klohr):
> @getFoundry Where can one read more about the security policies used by this?
> date: Wed Feb 04 17:45:24 +0000 2026
> url: https://x.com/dylanklohr/status/2019105021259071491
> ──────────────────────────────────────────────────
> 
> @getFoundry (Foundry):
> @dylanklohr it’s open source! https://t.co/L2YghlNL3i
> >  QT @getFoundry:
> > Extension is open-source, audit it all you want.
> > 
> > https://t.co/Ebfk0TDaRF
> >  https://x.com/getFoundry/status/2019023429723419013
> date: Wed Feb 04 17:47:22 +0000 2026
> url: https://x.com/getFoundry/status/2019105512919576890
> ──────────────────────────────────────────────────
> 
> @AdamGhetti (Adam Ghetti):
> @getFoundry Except many modern services have rather sophisticated anti-bottling technology for this exact purpose.
> date: Wed Feb 04 19:22:02 +0000 2026
> url: https://x.com/AdamGhetti/status/2019129337740685316
> ──────────────────────────────────────────────────
> 
> @getFoundry (Foundry):
> @AdamGhetti Yes, therefore we won't handle them for that reason.
> date: Wed Feb 04 19:22:30 +0000 2026
> url: https://x.com/getFoundry/status/2019129456829546898
> ──────────────────────────────────────────────────
> 
> @HeyGenLabs (HeyGen Labs):
> @getFoundry Check out this video summary! https://t.co/EJ3tQdlYOK
> date: Wed Feb 04 23:57:41 +0000 2026
> url: https://x.com/HeyGenLabs/status/2019198708164759576
> ──────────────────────────────────────────────────
> 
> @getFoundry (Foundry):
> @HeyGenLabs https://t.co/6SYEbYs3sU is better lol
> date: Thu Feb 05 01:55:15 +0000 2026
> url: https://x.com/getFoundry/status/2019228296001769729
> ──────────────────────────────────────────────────
> 
> @bsmokes (bsmokes.eth):
> @getFoundry Why not just use Brave API to do exactly this?
> date: Thu Feb 05 02:03:18 +0000 2026
> url: https://x.com/bsmokes/status/2019230319686406633
> ──────────────────────────────────────────────────
> 
> @getFoundry (Foundry):
> @bsmokes It accesses the site's servers itself - its not a mere search engine.
> date: Thu Feb 05 02:04:11 +0000 2026
> url: https://x.com/getFoundry/status/2019230541124628969
> ──────────────────────────────────────────────────
> 
> @aryanbhasin_ (Aryan Bhasin):
> @getFoundry will there be a repository of “already browsed” website skills? if someone’s already done the first-browse for a  website I could just use the skill created from their session
> date: Thu Feb 05 02:39:02 +0000 2026
> url: https://x.com/aryanbhasin_/status/2019239311074582790
> ──────────────────────────────────────────────────
> 
> @getFoundry (Foundry):
> @aryanbhasin_ https://t.co/i2weHaW9kE
> date: Thu Feb 05 02:39:25 +0000 2026
> url: https://x.com/getFoundry/status/2019239409384931487
> ──────────────────────────────────────────────────
> 
> @biglibertyguy (Big Liberty):
> @getFoundry Requires a solana wallet?
> date: Thu Feb 05 04:00:31 +0000 2026
> url: https://x.com/biglibertyguy/status/2019259818532614508
> ──────────────────────────────────────────────────
> 
> @getFoundry (Foundry):
> @biglibertyguy It sets up one for you if you don’t have one
> date: Thu Feb 05 04:02:08 +0000 2026
> url: https://x.com/getFoundry/status/2019260226617389181
> ──────────────────────────────────────────────────
> 
> @0xKilroy (0xKilroy):
> @getFoundry My openclaw assessment: don't install it.
> 
> The native binary (`unbrowse-native.darwin-arm64.node`) is the dealbreaker. Can't read it, can't audit it, can't trust it. Everything else (keychain access, wallet key in config, phoning home to their marketplace) just compounds the risk
> date: Thu Feb 05 04:08:49 +0000 2026
> url: https://x.com/0xKilroy/status/2019261907996479924
> ──────────────────────────────────────────────────
> 
> @getFoundry (Foundry):
> @0xKilroy We removed the need for that dependency. It was built that way initially because we were going close sourced. The binary isn’t needed
> date: Thu Feb 05 04:14:19 +0000 2026
> url: https://x.com/getFoundry/status/2019263290455781545
> ──────────────────────────────────────────────────
> 
> @realgabe178 (Gab e Hcuo D):
> @getFoundry That’s great but my openclaw wrote this on its own, after I told it that I don’t like it to control my browser and don’t like to use an api key
> date: Thu Feb 05 05:26:47 +0000 2026
> url: https://x.com/realgabe178/status/2019281528757600579
> ──────────────────────────────────────────────────
> 
> @getFoundry (Foundry):
> @real_apejax You don’t actually need to use an api key. Should make the docs clearer, my bad
> date: Thu Feb 05 07:33:46 +0000 2026
> url: https://x.com/getFoundry/status/2019313485990248853
> ──────────────────────────────────────────────────
