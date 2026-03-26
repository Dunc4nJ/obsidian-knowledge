---
created: 2026-03-26
description: dev-browser is a CLI tool by Sawyer Hood that gives AI agents browser control by letting them write real Playwright code that runs inside a sandboxed QuickJS VM with a persistent daemon for fast startup.
source: https://x.com/sawyerhood/status/2036842374933180660
type: tool
---

## Key Takeaways

The key design decision is "bitter lesson pilled" — instead of inventing a new syntax or abstraction for browser automation, dev-browser lets agents write standard Playwright code. Agents already know Playwright from their training data, so there's zero new API surface to learn. This aligns with the principle in [[CLIs are the agent-native interface because legacy tooling is already machine-readable]] — meet agents where their knowledge already is.

Two architectural improvements over the original version address the main pain points: a proper daemon process eliminates cold-start latency (the original spawned Playwright from scratch each time), and all scripts run inside a sandboxed QuickJS WASM VM. The sandbox is the critical safety layer — agents write real Playwright code with full page access (goto, click, fill, evaluate, screenshot, `snapshotForAI()`) but cannot access the host filesystem or run arbitrary Node. As the author puts it: "your agent writes real playwright code but can't `fs.rm()` because it had a bad day."

A notable feature: dev-browser can connect to your real running Chrome instance, giving agents access to your existing cookies and login sessions. This solves the auth-gated page problem that plagues most browser automation tools, which relates to the observation in [[capturing internal APIs can replace most agent browser automation]] — though dev-browser takes the opposite approach by making browser automation itself reliable enough to use directly.

The project has 4k+ GitHub stars and positions itself against the crowded browser-agent CLI space (including Vercel's agent-browser) primarily on speed and the code-first approach. Community feedback confirms the latency difference is significant for real-time agent workflows.

## External Resources

- [GitHub: SawyerHood/dev-browser](https://github.com/SawyerHood/dev-browser) — source repo (4k+ stars)
- [Agent Skills listing](https://agentskills.so/skills/sawyerhood-dev-browser-dev-browser) — skill registry entry

## Original Content

> [!quote]- Source Thread (@sawyerhood, March 25 2026)

> **@sawyerhood (Sawyer Hood)** — [Tweet 1](https://x.com/sawyerhood/status/2036842374933180660)
> 
> Introducing the new dev-browser cli.
> 
> The fastest way for an agent to use a browser is to let it write code.
> 
> Just `npm i -g dev-browser` and tell your agent to "use dev-browser"
> 
> ---
> 
> **@sawyerhood (Sawyer Hood)** — [Tweet 2](https://x.com/sawyerhood/status/2036842376405373289)
> 
> there are like 100s browser agent clis (even Garry Tan has one) why use this one?
> 
> dev-browser is incredibly bitter-lesson pilled. Rather than inventing a new syntax for browser automation, just use the one they already know: Playwright.
> 
> *Playwright code example showing dev-browser API surface*
> ![[sawyerhood-180660-001.jpg]]
> 
> ---
> 
> **@sawyerhood (Sawyer Hood)** — [Tweet 3](https://x.com/sawyerhood/status/2036842378431205454)
> 
> the original dev-browser was just a markdown file and a few scripts that called playwright directly. simple, but slow startup and you had to let your agent run arbitrary node scripts. since its release there has been a lot of innovation in the browser skill space (from things like agent-browser)
> 
> the new cli addresses the two biggest points of feedback from the original: a proper daemon for fast startup and all playwright scripts run inside a sandboxed quickjs vm. your agent writes real playwright code but can't `fs.rm()` because it had a bad day.
> 
> ---
> 
> **@sawyerhood (Sawyer Hood)** — [Tweet 4](https://x.com/sawyerhood/status/2036842379785945228)
> 
> fittingly we just hit 4k stars on github! Check it out today!
> 
> https://github.com/SawyerHood/dev-browser
> 
> ---
> 
> ### Replies
> 
> **@kyuxloll (kyux):** REALLY awesome work brother! Can I send a donation to the github? I LOVE this man.
> 
> **@sawyerhood:** @kyuxloll no need my dude. just let me know any issues you run into
> 
> **@__morse (Tommy D. Rossi):** did you try playwriter?
> 
> **@codeanand (Anand Narayan):** Is there a way dev-browser can use my existing google chrome profile.. so that it can use my login cookies
> 
> **@LLMJunky (am.will):** sawyer you're a legend bro. i think you forgot to mention something absolutely critical here. this isn't using a playwright dev environment that doesn't store your sessions, passwords, etc reliably. this is the real browser. and its fast. that alone makes it special.
> 
> **@thomasmustier (Thomas Mustier):** that is FAST. sure you get this all the time but - how do you compare this vs agent-browser from vercel?
> 
> **@sawyerhood:** @thomasmustier here is a video of agent-browser doing the same task for comparison
> 
> **@estebs (Esteban):** How does it communicate with the browser? Does it need a Chrome extension?
> 
> **@sawyerhood:** @estebs it can connect directly to your running chrome if you ask your agent to! It will give you instructions
> 
> **@nummanali (Numman Ali):** The legend is back
> 
> **@sawyerhood:** @nummanali i didn't know i was gone lol
> 
> **@bygregorr (Gregor):** The real bottleneck isn't browser speed, it's agents hallucinating what's actually on the page. Does dev-browser give the agent a reliable DOM snapshot, or is it still guessing?
> 
> **@nanocorp11 (Selim Kırcı):** any plan to have it for poor windows slaves:)
> 
> **@sawyerhood:** @nanocorp11 yes! i need to boot up my windows machine
> 
> **@gagansaluja08 (Gagan | Claude + AWS):** code-first browser control is the right call for agents - the screenshot/coordinate loop is brittle and slow. writing js against the dom is what a developer would actually do. curious how it handles auth flows and csp-heavy sites
> 
> **@shubhtrips (Shubhankar Tripathy):** About a week ago this was released - would love your comments on this as well @sawyerhood
> 
> **@herohalldon (Hero Halldon):** been using CDP websockets to automate chrome for a week straight now. uploaded 3 tiktok videos, sent 97 emails, and replied to this tweet. all from the same node script. we are truly cooked.
> 
> **@YuriiSolwees (Yurii):** Letting an agent write code to use a browser is the definition of the orchestration era. But speed is useless without reliability. We need the Logic Layer to audit that generated code on the fly so the agent doesn't just hallucinate its way into a loop.
> 
> **@prodhi_code (Prodhi):** Been building a similar wrapper around Camoufox (anti-fingerprint Firefox) for agent browser control. The QuickJS WASM sandbox and snapshotForAI() are two things I'm clearly missing. Curious how the dev-browser handles sites with bot detection?
> 
> **@sawyerhood:** @__morse i did not! i had not realized that you went full cli as well!
> 
> **@truechatdata (Chat Data):** This is a smart direction. Code driven browser control tends to scale better once agents need repeatable flows, diffs, and real debugging instead of brittle click by click state. Curious how you handle traces and recovery when a page shifts mid run.
> 
> **@RatrektLabs (Ratrekt Labs):** the latency difference alone makes it worth it for real-time agent workflows
> 
> **@maciejewskii0 (Michal Maciejewski):** does this handle auth-gated pages or does the agent just stare at a login screen
> 
> **@zoessterling (Zoe Sterling):** giving the agent write access to its own browser is the sort of thing you do on a friday afternoon and don't mention in standup

[Source](https://x.com/sawyerhood/status/2036842374933180660)
