---
tags:
  - agentic-systems
  - production-ai
  - observability
  - self-maintaining
  - monitoring
  - datadog
source: https://x.com/RampLabs/status/2036165188899012655
author: "@RampLabs"
date: 2026-03-23
---

## Summary

Ramp built a self-maintaining agentic system for their Ramp Sheets product. Key insights:

- **1 monitor per 75 lines of code** — scaled from 10 hand-written monitors to 1,000+ AI-generated ones
- **Monitor-driven maintenance loop**: On PR merge, an agent generates Datadog monitors. When a monitor fires, another agent reproduces the issue in a sandbox, pushes a fix, and notifies Slack
- **Triage step filters noise**: agents assess alerts — real issues get fixed, noisy monitors get tuned or deleted. Duplicate state stored on the monitor itself
- **Sandboxed reproduction is key**: agents run against live code in full dev environments, not just static analysis
- **Model choice matters**: GPT-5 series for debugging, Opus 4.6 for triage/filtering noisy alerts
- **Caught 40 real bugs in first week**, each within minutes of user trigger
- **No code merged without engineer review** — human in the loop for all fixes
- Built on **Ramp Inspect**, their internal background coding agent with sandboxed dev environments

Key lessons: detect everything but notify selectively; delegate scoping/triage to the agent; keep your existing hand-written instrumentation as a safety net.

## Full Post

📰 **How we made Ramp Sheets self-maintaining**

We built an agentic system to maintain [Ramp Sheets](https://labs.ramp.com/sheets). It continuously monitors production, triages alerts, and proposes fixes without human intervention - although no code is merged without engineer review. The system runs on a thousand AI-generated monitors, one for every 75 lines of code.

We built this because:

- Agents are cheap to run, infinitely patient, and easy to parallelize. These properties make exhaustive monitoring feasible at production scale.

- Teams hate owning observability, ourselves included. Offloading this grunt work to an agent lets us [ship faster](https://agents.ramp.com/cards).

- Strong observability and QA mean fewer bugs, less downtime, and a better experience for Ramp customers.

### Ramp Inspect

We chose to build our maintenance system using [Ramp Inspect](https://builders.ramp.com/post/why-we-built-our-background-agent), our internal background coding agent. Each Inspect session spins up a full sandboxed dev environment, allowing the agent to make real API requests, run tests, and reproduce bugs end-to-end against live code. This interactivity is critical, as subtle failure modes are rarely apparent from static code review.

### Scheduled auditing

Our first attempt at self-maintenance took the form of a scheduled agentic review. Every night, we automatically spun up an agent to run a QA pass on Ramp Sheets, instructed to:

- Sanity-test core features
- Stress-test recently merged PRs
- Probe existing functionality for latent bugs

This design worked well, and surfaced several real production bugs every day. Further, we designed the workflow to be a system of action: If the agent found a real issue, it would put up a PR to address the root cause. More than once, an engineer shipped a feature with a bug they hadn't noticed; by morning, the agent had caught the regression and pushed a fix.

However, the nightly agent had serious limitations. With no specific mission, the agent always progressed down the same paths in its QA workflow, reading the same files, investigating the same features, running the same tests. While this pattern proved effective at finding high-radius issues, it could not catch narrow, situational bugs.

Although Ramp Sheets is extensively instrumented on Datadog, our unfocused QA agent struggled to extract nuanced insights from the telemetry. Current frontier models are very capable at a wide range of software engineering tasks, but they cannot synthesize a large codebase with a large observability surface and determine what needs attention. Prioritization at production scale requires a level of intelligence surpassing that of any model available today.

### Monitor-driven maintenance

For our next iteration, we used Datadog monitors to direct the agent at specific production issues. These monitors watch metrics and log patterns, firing alerts on error rate spikes, latency regressions, or other deviations from expected behavior. The system works in two steps:

- On PR merge, an agent reads the diff and generates monitors instrumenting the new code.
- When a monitor fires, a [Datadog webhook](https://docs.datadoghq.com/integrations/webhooks/) kicks off a new agent with the alert context. The agent reproduces the issue in its sandbox, pushes a fix, and notifies us on Slack.

This pattern allows us to detect and respond to incidents with remarkable speed and granularity. In its first week, the system caught 40 real bugs, each within minutes of a user triggering the issue. In one instance, a user uploaded a spreadsheet with a unique type of embedded image that our existing logic could not handle; the resulting exception set off a monitor and moments later, the agent had alerted us with a fix ready. In another case, an internal user Slacked us about a broken feature - but our system had already flagged the exact issue before his message even landed.

### Filtering the noise

The major weakness in this approach was noise. Auto-generated monitors have bad thresholds. Routine user activity triggered a cascade of alerts, most of them false positives. Further, monitors fired repeatedly for the same issue, flooding Slack with duplicate notifications.

To filter the noise, we added a triage step. On every alert, the agent first assesses the scope of the problem:

- If it's a real issue, the agent pushes a fix and posts to Slack.
- If it's noise, the agent tunes or deletes the monitor.

To guard against duplicate alerts, we store state on the monitor itself. When an agent pushes a fix, it appends the PR link to the monitor description. Subsequent agents see the link and stand down.

### The upshot

In a few weeks, we scaled Ramp Sheets from ten hand-written monitors to over a thousand, one for every 75 lines of code. Our manual monitors were broad-strokes: alert when the frontend crashes, or when an API call times out. The AI-generated ones are far more granular, acting like a tight mesh over the exact shape of the code; whenever that shape drifts from the expected, we are notified.

### What we learned

**Detect everything, notify selectively.** The system should watch every signal, but each alert that reaches a human should mean something. Teams ignore noisy monitors, and they'll ignore noisy agents too.

**Delegate to the agent.** Let it scope out the problem, judge impact, make changes, and filter out noise. It's very good at this, and will get better as models improve.

**Sandboxed reproduction improves results.** In our system, the agent reproduces the failure against live code and only pushes a fix once that reproduction test passes. This pattern ensures that the issue is real, and that the agent's proposed fix works in practice.

**Model choice matters.** Although the GPT-5 model series are very thorough debuggers, we found Opus 4.6 was a more accurate triage evaluator, and specifically better at filtering out noisy alerts.

**Tight observability breeds customer empathy.** When every slow load or bad output fires a notification, the team feels the product the same way users do. We caught bugs we never would have prioritized on our own.

**Keep your existing stack.** Auto-generated monitors are powerful but opaque, and not yet reliable enough to be your only line of defense. When things go seriously wrong, you still want instrumentation you wrote and trust. As models improve, that will change.
