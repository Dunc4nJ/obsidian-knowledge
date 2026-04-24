---
created: 2026-04-24
description: Browser-Use's Gregor Zunic argues every click()/type()/scroll() helper is itself a wrapper the RL'd model has to fight around, and replaces them with a 600-line harness of raw CDP plus a SKILL.md the agent edits at runtime.
source: https://x.com/gregpr07/status/2047358189327520166
type: framework
---

## Key Takeaways

- Browser-Use extends the "delete the framework" thesis from [[agent harnesses are the product not the model]] one layer further: even the thin tool wrappers (`click()`, `type()`, `scroll()`) you write over CDP are abstractions the model has to fight around. RL-tuned frontier models were trained on millions of tokens of `Page.navigate`, `DOM.querySelector`, and `Runtime.evaluate` — giving them those primitives directly beats anything you would invent on top.
- The replacement is a harness of ~600 lines across four files: `run.py` (13), `helpers.py` (192), `daemon.py` (220), and `SKILL.md`. The agent (Claude Code / Codex) writes Python that imports helpers that speak CDP to Chrome. Everything above Chrome is rewriteable at runtime, which makes this closer to [[skills are living folders not markdown files and building them is the new developer setup]] than to a traditional framework.
- Crashes, target detaches, renderer OOMs, Chrome stalls — the things Browser-Use previously built watchdog services for — dissolve when you give the LLM direct CDP access plus Read/Edit/Write. It has "read ten thousand threads about Chrome crashes" and reattaches, retries, and reroutes on its own. The takeaway generalizes: production-grade resilience in the agent loop can come from exposing error text, not from handler code, once the model is strong enough.
- The self-heal loop is the real demo: when `upload_file()` was missing, the agent greped `helpers.py`, added it using raw `DOM.setFileInputFiles`, and completed the task — the authors found out by reading the git diff. It's the same muscle coding agents already have for fixing a missing import, applied to harness code, and is the practical cash-out of [[agent skills should self-improve through observed failures not stay as static prompt files]] and [[LLMs can synthesize their own code harness via tree search eliminating illegal actions and outperforming larger models]].
- Zunic explicitly disavows the conclusion of Browser-Use's prior "Closer to the Metal" post — "agents shouldn't have to know the nuances of CDP Targets" turned out to be wrong; the complexity was something to let the model see, not hide. That inversion is a sharper version of [[designing agent tools is an iterative art shaped by model capabilities not fixed engineering rules]]: every abstraction has a model-capability half-life, and at frontier-model level the right answer collapses to SKILL.md + protocol.

## External Resources

- [browser-use/browser-harness](https://github.com/browser-use/browser-harness) — The ~600-line reference harness; prompt `Set up https://github.com/browser-use/browser-harness for me.` into Claude Code or Codex to try it.
- [The Bitter Lesson of Agent Frameworks](https://browser-use.com/posts/bitter-lesson-agent-frameworks) — Zunic's earlier post arguing don't wrap the LLM at all; maximal action space, then restrict.
- [Closer to the Metal: Leaving Playwright for CDP](https://browser-use.com/posts/playwright-to-cdp) — The post whose conclusion ("agents shouldn't have to know CDP Targets") this article retracts.
- [Chrome DevTools Protocol](https://chromedevtools.github.io/devtools-protocol/) — The raw wire protocol (`Page.navigate`, `DOM.querySelector`, `Runtime.evaluate`, `Input.dispatchMouseEvent`) the harness exposes to the model.

## Original Content

> [!quote]- Source Material
> **The Bitter Lesson of Agent Harnesses** — Gregor Zunic (@gregpr07, founder @browser_use) — 2026-04-23
>
> Don't wrap the LLM. Don't wrap its tools either.
>
> All you need is a *SKILL.md* and some Python helpers. The LLM has complete freedom. If something's missing, it writes it.
>
> ### The learning
>
> A few months ago we wrote [The Bitter Lesson of Agent Frameworks](https://browser-use.com/posts/bitter-lesson-agent-frameworks). The argument: don't wrap the LLM in abstractions. Maximal action space, then restrict.
>
> We were still wrapping its tools.
>
> Every *click(), type(), scroll()* helper is an abstraction you decided the model needs. Every one of them is a constraint the RL'd model has to fight around.
>
> ### Why raw CDP
>
> When we built the first version of Browser Use, we shipped thousands of lines of element extractors, DOM indexers, click wrappers.
>
> LLMs know CDP. They were trained on millions of tokens of *Page.navigate, DOM.querySelector, Runtime.evaluate*.
>
> *Framework vs Browser Harness: a frozen author-time wrapper stack (agent → message manager → 20 fixed tools → playwright → CDP → chrome) collapses into a runtime-shaped harness (agent → raw python → 4 primitives it can edit → CDP → chrome).*
> ![[gregpr07-520166-001.jpg]]
>
> CDP is the lowest level Chrome exposes. Give it directly to the model:
>
> - **Cross-origin iframes.** Attach to the target directly, no frame abstraction to fight.
> - **Shadow DOM.** Walk shadowRoot.querySelectorAll like the model has seen ten thousand times.
> - **Anti-bot injection.** It's Chrome talking to itself.
>
> ### What we got wrong
>
> A few months ago on this blog we wrote [Closer to the Metal: Leaving Playwright for CDP](https://browser-use.com/posts/playwright-to-cdp). The conclusion of that post: *"Our agents shouldn't have to know the nuances of CDP Targets in order to Get Stuff Done."*
>
> Turns out we were wrong.
>
> That post listed ten ways a Chrome tab can crash. We built watchdog services to catch each one - tab crashes, target detach, renderer OOM, zygote death, GPU process crash. Each got a handler. Each handler had to be kept in sync with Chrome's internals.
>
> Give the LLM direct CDP access and the ability to edit its own harness, and it handles all of that itself. Pages dying, targets wrongly attached, Chrome stalling - the agent reads the error, reattaches to a fresh target, retries. It doesn't need a watchdog. It's read ten thousand threads about Chrome crashes. It already knows what to do.
>
> The "complexities of CDP" we were trying to hide weren't something to hide. They were something to let the model see.
>
> ### Four files
>
> That's the whole harness:
>
> - run.py (13 lines) - runs plain Python with helpers preloaded
> - helpers.py (192 lines) - thin wrappers around CDP, and the agent edits them
> - daemon.py (220 lines) - keeps the CDP websocket alive
> - SKILL.md - tells the agent how to use the above
>
> ~600 lines total.
>
> *Harness topology: agent (Claude Code / Codex) writes python into run.py, which execs with helpers preloaded; helpers.py talks to daemon.py over a unix socket, daemon.py holds the CDP websocket open to Chrome.*
> ![[gregpr07-520166-002.jpg]]
>
> The agent writes Python. The Python imports helpers. The helpers speak CDP. Chrome does what it's told. Everything above Chrome is rewriteable.
>
> ### The self-heal loop
>
> Here's what happens when a tool is missing.
>
> *Self-heal timeline: agent wants to upload a file → helpers.py missing upload_file() → agent edits the harness and writes it (helpers.py grows 192 → 199 lines, `+ upload_file()`) → file uploaded.*
> ![[gregpr07-520166-003.jpg]]
>
> When a helper is missing, the agent does what any Claude Code user would do: greps [helpers.py](https://github.com/browser-use/browser-harness), adds the function, reruns.
>
> We didn't tell it to do this. We gave it Claude Code's normal Read/Edit/Write plus CDP access. Coding agents already know how to fix a missing import.
>
> **The key: the agent isn't writing new code from first principles. It's writing the one function that was missing, the same way it'd fix a missing import on any codebase.**
>
> ### Magical moments
>
> **Upload.** We forgot to add upload_file(). Mid-task, the agent hit a file input, grepped helpers.py, saw nothing, wrote the function using raw DOM.setFileInputFiles, and uploaded the file. We found out when we read the git diff.
>
> **Chunked upload.** After writing upload_file, the agent tried to upload a 12MB file. CDP websocket payloads cap around 10MB. It hit the limit, read the error, switched to a chunked upload pattern.
>
> **Gusto to calendar.** Task: put every employee's birthday in our shared calendar. Required navigating Gusto's employee tab, extracting dates from the DOM, then creating Google Calendar events.
>
> **Azure admin roles.** Azure's admin portal is a pile of blades inside iframes. Raw CDP, via coordinate-level Input.dispatchMouseEvent, passes through at the compositor level.
>
> ### Try it
>
> Setup prompt for Claude Code or Codex:
>
> ```markdown
> Set up https://github.com/browser-use/browser-harness for me.
> ```
>
> First person to find a task it fails on (not captcha/2FA) gets a Mac Mini. Seriously. I've been trying to break it for a week and can't.
>
> Repo: [github.com/browser-use/browser-harness](https://github.com/browser-use/browser-harness)
>
> **The bitter lesson of agent harnesses: your helpers are abstractions too. Delete them. Let the agent write what it needs.**
>
> Engagement: 682 likes · 1,432 bookmarks · 51 retweets · 18 replies · 13 quotes · 85,900 views
> [Original post](https://x.com/gregpr07/status/2047358189327520166)
