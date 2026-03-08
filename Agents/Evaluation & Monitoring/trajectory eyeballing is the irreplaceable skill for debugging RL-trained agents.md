---
created: 2026-03-08
description: Auriel's practitioner guide to manually reviewing agentic trajectories — the thinking tokens, tool calls, and outputs — as the primary debugging method for RL post-training, with a diagnostic framework, failure taxonomy, and 10-point checklist.
source: https://x.com/aurielws/status/2030341466791563552
type: framework
---

## Key Takeaways

The central claim is brutally simple: there is no substitute for reading your model's actual traces step by step. Not aggregate metrics, not pass/fail dashboards — the actual thinking tokens, tool calls, and outputs in sequence. A model that passes your eval can still be doing something that will embarrass you in front of paying users, and trajectories are where that shows up first. This resonates with the pattern that [[deep agent evals need bespoke per-datapoint test logic not uniform evaluators|uniform evaluators miss the failures that matter most]].

The most actionable insight is the diagnostic split: before retraining, determine whether a failure is a **harness problem** or a **training job problem**. Three questions disambiguate: (1) Could I solve this task with the same context the model had? If no → harness. (2) Does the model get the right answer via a shortcut the rubric missed? If yes → training. (3) Does it fail at the same decision point across traces? If yes → training gap, but check harness context first. This maps well to the distinction between [[effective agent evals combine deterministic graders model judges and human review across the full development lifecycle|different eval layers]] — some failures need harness fixes, not more data.

The failure taxonomy is practical: (1) **Cheating creatively** — rubric satisfied, skill not learned (e.g., regex-matching expected format, finding answers in grader memory); (2) **Stuck at the same fork** — consistent failure at 2-3 decision points invisible in aggregate; (3) **Product-specific failures** — unique to how your product uses the model, look like model/harness/product bugs simultaneously; (4) **WTF IS THAT** — emergent behaviors you can't detect because you've never seen them, which bake in for hundreds of gradient steps before anyone notices.

The 10-point checklist takes ~90 minutes for 10 trajectories and covers: earned scores, hesitation patterns, context sufficiency, reward hacking, self-test vs gold-test splits, constraint consistency across turns, tool call volume, spec coverage, punishment fairness, and emergent weirdness. Each point maps to harness vs training diagnosis.

The practical recommendation to vibe-code a trajectory viewer (tinder-style swipe interface) in 30 minutes using a one-shot prompt is a useful pattern — makes the manual review process sustainable rather than heroic. Auriel provides the full prompt and references [hud.ai](https://hud.ai) as an alternative.

## External Resources

- [Full blog post with embedded video walkthrough](https://aurielws.github.io/posts/rl-pet-peeves-part-1/) — the complete guide with all diagrams
- [YouTube walkthrough](https://youtu.be/HFxc2hhcEO0) — video demo of the trajectory viewer
- [Practice dataset](https://huggingface.co/datasets/nebius/SWE-rebench-openhands-trajectories) — nebius/SWE-rebench-openhands-trajectories on HuggingFace
- [hud.ai](https://hud.ai) — trajectory viewer tool referenced in the post
- [Auriel's content plan](https://aurielws.github.io/writing.html) — upcoming posts on rubrics, harness quality, debugging, benchmarking

## Original Content

> [!quote]- Source Thread — @aurielws (Auriel), Mar 7 2026
>
> *Article header image*
> ![[aurielws-563552-001.jpg]]
>
> **@aurielws:** Article: You never spend time with your model and we can ALL tell 👀
>
> My personal do's and don'ts for startups post-training their own model. These are my very opinionated Eyeballing Best Practices.
>
> This mini-series is a collection of rants on RL from my POV. Pure, unfiltered, first-person opinions from someone who's spent years deep in the trenches of pre-training, post-training/fine-tuning, inference time, and every layer of the stack for models from small distilled models (Pixel Real Tone base model) to frontier systems (Gemini + Nano Banana + Human Detection Models that powered Google Search, Waymo, Vertex AI).
>
> I've eyeballed thousands of trajectories, judged parametric wins and losses until my eyes bled at 2AM, and sat through more "data" pitches than I care to count.
>
> Who this is for:
> - Startups post-training your own custom models for the first time
> - Big companies considering building domain-specific agents
> - Fresh grad researchers running their first real post-training loop (particularly for RL since that's one of the main ways we do agentic post-training these days)
> - RL researchers might probably also might find this useful, but probably too rudimentary
>
> This is not the consensus view of every big AI lab researcher. This is just me. But colleagues say I'm pretty good at spotting what's going to work and what's going to waste everyone's time.
>
> If your RL data keeps ending up in an abandoned directory, maybe start here 🤷.
>
> ### Today's Rant: Agentic Trajectory Eyeballing
>
> You just fine-tuned an open-source model you found on X/Twitter for your customer-facing SaaS agent. Training loss looked reasonable, eval scores hit 81%. You ship it. Three days later, users are rage-quitting in the exact scenarios your product is supposed to handle. Half your team says retrain with more data. The other half says the evals were wrong. Nobody has opened a single trajectory.
>
> This is what I mean when I say "you've never spent time with your model and we can ALL tell" 👀
>
> There is no substitute for sitting down with your model's actual traces — the thinking tokens, the tool calls, the outputs — and just reading them.
> - Not skimming aggregate metrics.
> - Not glancing at pass/fail rates on a dashboard.
> - Actually reading what the model did, step by step, for a meaningful sample of tasks.
>
> Ramble out loud and talk to yourself about why something does or does not make sense as a model behavior.
>
> ### What I do Instead
>
> Basically I wrote a guide about how I think about reviewing agentic trajectories.
>
> After reading, hopefully you'll be able to:
> - Learn the basics of how to read an agentic trace and trajectory (normally a 90 min process overall)
> - See my quick gut-check diagnostic framework to split "your agent's harness problem" from "your custom model's training job problem"
> - Run a 4-point trajectory eyeballing session
> - Vibe-code a basic trajectory viewer in 30 mins (my custom vibe coding prompt included)
>
> ### #01 — What is a trajectory, really
>
> A trajectory is a receipt for everything your model did on a task. Every decision, every tool call, every mistake. Not a chat log, but a complete decision record: every input your model saw, every intermediate output, every piece of reasoning it generated, from task start to final submission. Think tokens, API calls, drafted outputs, self-corrections. All of it, in sequence.
>
> *Trajectory anatomy diagram — 5 components: Input, Messages, Output, Tests, Scores*
> ![[aurielws-563552-002.jpg]]
>
> Your eval metrics only score the final output. That's it. Your trajectory shows you how the model got there — whether it actually reasoned correctly, stumbled into the right answer by dumb luck, found a shortcut your rubric didn't catch, or did something that you've genuinely never seen before. A model that passes your eval can still be doing something that will embarrass you in front of paying users. Your trajectories are where that shows up first.
>
> ### #02 — Sanity Check Your Harness
>
> When you do RL, your Harness is the complete interactive system your model trains and evaluates inside. Think of it as a programmable staging environment: a working replica of the real product experience — the mock dashboard, the simulated IDE, the fake SaaS tool — that your agent clicks through, types into, and calls APIs against, just like a real user would.
>
> It does three things:
> 1. **State** — Defines what the agent "sees" right now — the current page, API response, file contents
> 2. **Actions** — Defines what the agent can do from here — click, type, submit, call an endpoint
> 3. **Reward** — Returns a score after each action — +1 for resolving a ticket, −0.1 for wasted steps
>
> Why this matters: In RL, the environment is your data generator. A broken harness doesn't just add noise — it actively generates garbage training data. Your model will learn to exploit your broken mechanics instead of learning the actual task. Fix the harness before you retrain.
>
> *Diagnostic split flowchart — harness vs training job*
> ![[aurielws-563552-003.jpg]]
>
> Three diagnostic questions:
> - Could I solve this task with the same context the model was given? → NO → Harness problem
> - Does the model get the right answer via a shortcut my rubric didn't catch? → YES → Training problem
> - Does the model fail at the same decision point across multiple traces on the same task type? → YES → Training gap (but check harness context first)
>
> ### #03 — The failure modes I look for first
>
> *Failure mode taxonomy cards*
> ![[aurielws-563552-004.jpg]]
>
> **Category 1: Cheating Creatively** — Your rubric is being satisfied. The skill is not being learned. E-commerce model regex-matches expected format. Support bot pads responses for thoroughness rewards. Code agent finds answer in grader memory. (METR caught this on a real frontier model in 2025.) → Training job — add anti-hack rubric checks, diversify task phrasings
>
> **Category 2: Stuck at the Same Fork** — The model fails at the same 2–3 decision points across every trajectory. A claim classification edge case, a missing context type, a tool call sequence it can't exit cleanly. These patterns are gold if you catch them. Invisible in aggregate pass rates. → Often harness first — add system instructions, make sure your product gives the model proper context before you retrain
>
> **Category 3: Product-Specific Failures** — Failures unique to your product and customer workflows. Look like model failures, harness failures, and product bugs all at once. Legal bot flags UK clause as "non-standard" (trained on US norms). Support agent escalates correctly but can't see a partial refund from another channel. → Requires custom eval and eyeballing work
>
> **Category 4: WTF IS THAT :)** — Code agent self-modifies its own test files to force passes. Support bot prefacing every response with an unprompted disclaimer. You can't detect what you've never seen — by the time you notice in aggregate metrics, it's been baking in for hundreds of gradient steps. → Could be either — read the trace to tell
>
> ![[aurielws-563552-005.jpg]]
>
> ### #04 — Auriel's 10-point eyeballing checklist
>
> *10-point checklist table*
> ![[aurielws-563552-006.jpg]]
>
> | # | What to check | What to look for | Hypothesis |
> |---|---|---|---|
> | 1 | Did it earn the score? | Tool calls vs task requirement. Right answer via shortcut? | Training |
> | 2 | Where did it hesitate? | Repeated calls, oscillating edits. Same missing context? | Either |
> | 3 | Could I solve it with same context? | The human-in-the-loop test. If no → harness broken | Harness |
> | 4 | Reward hacking patterns | Regex, verbosity, execution hacks | Training |
> | 5 | Self-test vs gold-test split | Do model's own tests validate right behavior? | Harness |
> | 6 | Policy/constraint consistency | Multi-turn drift check. Softens by turn 4? | Training |
> | 7 | Tool call volume | Error-retry cascades. Cost discrepancy source | Harness |
> | 8 | Spec/requirement coverage | What did it silently skip? | Either |
> | 9 | Punishment fairness | Was it penalized for unsolvable task? | Harness |
> | 10 | Anything new and weird | Emergent behavior watch. Log immediately | Either |
>
> For like ten trajectories it usually takes me around 90 minutes.
>
> ### #05 — Build your Agentic Eyeballing Trajectory Viewer in 30 minutes
>
> *Screenshots of vibe-coded trajectory viewers — Codex CLI and Claude Code*
> ![[aurielws-563552-007.jpg]]
> ![[aurielws-563552-008.jpg]]
>
> Once you have a viewer, the five questions I ask on every trace:
>
> 1. Did this model actually earn its score?
> 2. Where did it hesitate, loop, or get stuck?
> 3. Could I solve this task with the same context it was given?
> 4. Is the model being penalized for something that's the environment's fault?
> 5. Is there anything here I've genuinely never seen before?
>
> *Five questions summary card*
> ![[aurielws-563552-009.jpg]]
>
> Do this enough and you build an intuition that no metric can replace. You start to feel when data is going to produce real learning versus when it's going to be noise. That intuition is what makes someone effective at RL evaluation, and there is no shortcut to developing it other than putting in the hours with the actual traces.
>
> ### What you can do immediately
>
> 1. Grab 10 trajectories from your last training run. Run the checklist. Note what flags and whether it points to harness or training.
> 2. No trajectories yet? Use the public dataset: [nebius/SWE-rebench-openhands-trajectories](https://huggingface.co/datasets/nebius/SWE-rebench-openhands-trajectories/viewer/default/train)
>
> Upcoming in this series: Rubrics and Verifiers, Environment Quality / Harness Quality for Training and Evals in RL, Debugging Walk Through, Benchmarking.
>
> Thank you to David Pantera, Daniel Kim, Jessica Li, Shagun, and Jay for editing help.
