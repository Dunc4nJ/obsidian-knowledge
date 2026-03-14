---
created: 2026-03-14
description: Training priors consistently override prompt instructions, so effective agent harnesses use runtime error guards that trigger the model's deeply trained error-fix loop rather than fighting its learned behaviors.
source: https://x.com/gregpr07/status/2032539581359546757
type: learning
---

## Key Takeaways

The central insight from Browser Use's tens of thousands of agent sessions is that prompting is a suggestion while training is gravity. When a system prompt contradicts patterns the model absorbed during training — stateless Python calls, sequential HTTP loops, raw API calls over integrated tools — the model follows its training every time. This is a concrete validation of what the [[harness engineering improved a coding agent 13 points by changing only system prompts tools and middleware|Amp harness engineering report]] found: the harness matters enormously, but the *type* of harness intervention matters even more than its presence.

The actionable framework is to replace preventive instructions with reactive runtime guards. Instead of telling an agent "don't use sequential loops," you let it write the loop, catch it with an AST check at runtime, and return a clear error message. This works because every coding model has seen millions of error-then-fix cycles during training — you're channeling the training distribution rather than fighting it. This principle aligns with [[agent harness components can be derived from first principles by working backwards from desired agent behavior|deriving harness components from first principles]]: the best harness designs work *with* the model's natural behavior patterns.

The most provocative claim is that unexpected agent behavior should be triaged as "catch or enable" rather than uniformly blocked. When an agent inspects a dead browser runtime and writes code to restart it, or builds an HTML file and tries to open it via file:// to visually verify its output, these are signs of autonomous problem-solving that a rigid harness would suppress. This "maximum freedom in a sandbox" philosophy — observe first, then build the harness around observed behavior — inverts the typical approach of [[designing agent tools is an iterative art shaped by model capabilities not fixed engineering rules|designing agent tools]] where you predict needs upfront.

The practical implication for [[agents need a harness not a framework because durable event-driven infrastructure already solves retry routing and state|harness-over-framework]] builders: a few robust runtime guards plus model intelligence beats elaborate prompt engineering or complex heuristic systems. Simplicity wins because the model is smart enough to replan when given a clear error signal.

## External Resources

- [Browser Use](https://browser-use.com) — open-source browser automation agent framework by Gregor Zunic's team, the source of these observations

## Original Content

> @gregpr07 (Gregor Zunic) — 2026-03-13
>
> **Give your Agent Maximum Freedom**
>
> Training beats prompting. Every time.
>
> We gave our agent a Python tool and a browser. The browser crashed. The agent inspected the runtime object, found the dead browser instance, and wrote Python code to restart it. Nobody told it to do that. Nobody would have thought to enable it.
>
> This is what happens when you stop predicting what the model will do and start observing what it actually does.
>
> **Training beats prompting. Every time.**
>
> We've run tens of thousands of agent sessions. The single most important thing we learned: when your prompt says one thing and the model's training says another, training wins.
>
> Python persistence. We made each Python call stateless. Told the model in the system prompt. It still references variables from previous calls. Every time. Because every Python REPL it saw during training had persistent state.
>
> Sequential loops. System prompt says: use Promise.all for parallel fetching. The agent runs requests.get() in a for-loop over 249 countries anyway. Because that's what 99% of Python code looks like.
>
> Slack via Python. The agent has a Slack integration tool in its tool list. Ignores it. Writes raw requests.post() instead. Because that's what Stack Overflow taught it.
>
> Prompting is a suggestion. Training is gravity.
>
> *Training priors override prompt instructions*
> ![[gregpr07-546757-001.jpg]]
>
> **So what actually works?**
>
> If you can't prompt your way out of training priors, what do you do?
>
> You use the one thing that IS deeply trained: error → fix.
>
> We told the agent "don't use sequential loops" in the prompt. Ignored. We added a runtime AST check that catches loop-based fetching and returns an error: "Sequential network calls in loop detected. Use Promise.all for parallel fetching." The agent rewrites the code with parallel fetching. Instantly. Every time.
>
> Why does this work? Because every coding model has seen millions of error→fix loops during training. You're not fighting the training distribution anymore. You're using it.
>
> The principle: don't prevent behavior through instructions. Let the model try, catch it at runtime, and return a clear error. It already knows what to do with errors.
>
> *Runtime error guards leverage trained error-fix behavior*
> ![[gregpr07-546757-002.jpg]]
>
> **Freedom reveals intent**
>
> But here's the twist: not every unexpected behavior should be caught. Some of it is the model telling you what it needs.
>
> file:// URLs. The agent builds a file on disk, then tries to open it via file:///workspace/output.html in the browser. Gets blocked. Tries 10 workarounds. This looks like a bug. But the agent is trying to verify its own output visually. That's actually smart. The right response isn't to block it harder -- it's to make it safe.
>
> Browser self-heal. The agent inspects a dead runtime object and tries to restart it. That's not a failure mode. That's autonomous recovery. Enable it.
>
> Raw API calls over integrations. The agent writes requests.post() instead of using the Slack tool. It's reaching for what it knows. Maybe your tool's interface isn't as clear as the raw API it saw during training.
>
> The method: give maximum freedom in a sandbox. Observe what the model reaches for. Then decide: catch or enable. Build the harness around observed behavior, not assumed behavior.
>
> *Observe behavior first, then decide catch or enable*
> ![[gregpr07-546757-003.jpg]]
>
> **The less you assume, the more it works**
>
> One of the biggest learnings from building Browser Use: simplicity is very important. The model is smart enough to replan.
>
> A few robust runtime guards plus model intelligence will always beat elaborate prompt engineering or complex heuristic systems. Don't assume what the model will do. Watch what it does. Then give it a proper harness.
>
> Engagement: 77 likes | 9 retweets | 4 replies
> [Original post](https://x.com/gregpr07/status/2032539581359546757)
