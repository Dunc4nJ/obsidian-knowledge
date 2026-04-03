---
created: 2026-04-02
description: A production self-healing pipeline that detects post-deploy regressions via Poisson statistical testing against a 7-day error baseline, triages causality with a Deep Agent, and kicks off Open SWE to open fix PRs automatically.
source: https://x.com/vishsuresh_/status/2039748786290037038
type: learning
---

## Key Takeaways

The self-healing loop is: deploy → monitor (60 min) → triage → fix → PR. Two paths: build failures go directly to Open SWE with error logs + git diff, while server-side regressions go through statistical detection first. The key insight is that production systems carry a background error rate — you can't just count errors post-deploy, you need to separate signal from noise.

Error normalization creates signatures by replacing UUIDs, timestamps, and numeric IDs with tokens, then truncating to 200 chars. This groups logically identical errors despite surface differences. A 7-day baseline establishes expected error rates per signature, and a Poisson test (p < 0.05) flags signatures where post-deploy counts significantly exceed the predicted rate. New signatures not present in the baseline get flagged if they recur.

The triage agent is critical gating — rather than feeding errors directly to a coding agent (which is "tempted to make changes"), it classifies changed files as runtime vs test/docs/CI. Non-runtime changes get dismissed immediately, preventing [[agent production monitoring requires observing inputs and outputs not just system metrics|false positive causal chains]]. For runtime changes, the agent must establish a concrete link between a specific diff line and the observed error, returning a structured verdict with decision, confidence, and reasoning.

The system is most valuable for silent failures: wrong defaults, config mismatches, and cascading regressions where fixing one bug unmasks the next on the subsequent deploy. Future improvements include vector-space error clustering (instead of regex normalization), wider lookback windows for latent bugs, and severity-based fix-forward vs rollback decisions. [[ramp built a self-maintaining agentic system with one monitor per 75 lines of code|Ramp's approach]] of generating monitors proactively on PR merge is noted as a complementary pattern.

## External Resources

- [LangChain GTM Agent](https://x.com/LangChain/status/2031055593360990358) — the agent this pipeline deploys
- [Deep Agents](https://docs.langchain.com/oss/python/deepagents/overview) — LangChain framework used for the triage agent
- [Open SWE](https://x.com/LangChain/status/2033959303766512006) — open-source async coding agent for automated fixes
- [LangSmith Deployments](https://www.langchain.com/langsmith/deployment) — deployment platform
- [Ramp's self-maintaining system](https://x.com/RampLabs/status/2036165188899012655) — proactive monitor generation on PR merge

## Original Content

> **@vishsuresh\_** (Vishnu Suresh) — Thu Apr 2, 2026 · 169 likes · 23 retweets · 5 replies
>
> Article: How My Agents Self-Heal in Production

> [!quote]- Source Material

I built a self-healing deployment pipeline for our [GTM Agent](https://x.com/LangChain/status/2031055593360990358). After every deploy, it detects regressions, triages whether the change caused them, and kicks off an agent to open a PR with a fix.

With coding agents, the hard part of shipping isn't getting code out. It's everything after: figuring out if your last deploy broke something, investigating what caused the issue, and fixing it before users notice. I wanted to deploy, move on, and trust that if something regressed, the system would catch it and close the loop itself.

#### How the Self-Healing Flow Works

The GTM Agent is built on [Deep Agents](https://docs.langchain.com/oss/python/deepagents/overview) and deploys through [LangSmith Deployments](https://www.langchain.com/langsmith/deployment). We already had an internal coding agent called [Open SWE](https://x.com/LangChain/status/2033959303766512006), an open-source async coding agent that can research a codebase, write fixes, and open PRs. The missing piece was automated regression detection and triage to connect production errors back to Open SWE.

Right after a deployment to production, a self-healing GitHub Action triggers, capturing the build and server logs. The flow has two paths: (1) catching build failures immediately and (2) detecting server-side regressions over a window. If either path finds a real issue, Open SWE gets kicked off to fix it and open a PR.

*Self-healing flow: push to main → build check → poll error logs (60 min) → normalize + Poisson test vs 7-day baseline → triage agent → Open SWE*
![[vishsuresh-037038-002.jpg]]

#### Catching Docker Build Failures

First, I check the build logs to make sure the Docker images build properly. If the image fails to build, the pipeline automatically pipes the error logs from the CLI, fetches the git diff from the last commit to main, and hands it off to Open SWE, no human involved. Build failures are almost always caused by the most recent change, so a narrow diff gives Open SWE enough context to act on.

#### Monitoring for Post-Deploy Errors

Server-side issues are trickier than build failures. A production system carries a background error rate—network timeouts, third-party API issues, transient failures, etc. In an ideal world you'd track and fix every single one, but when trying to answer "did my last deploy break something," you need to separate the errors your change caused from the noise that was already there. That's what this step does.

First, I collect a baseline of all error logs from the past 7 days. These get normalized into error signatures, regex replaces UUIDs, timestamps, and long numeric strings, then truncates to 200 characters, so logically identical errors get bucketed together even when the specifics differ.

*Error normalization: raw error logs with unique IDs and timestamps are sanitized into grouped signatures with occurrence counts*
![[vishsuresh-037038-003.jpg]]

Next, I poll for errors from the current revision over a 60-minute window after deployment, normalizing the same way. Once that window closes, I have error counts from two very different time scales, a week of baseline data and an hour of post-deployment data. While I could naively compare these two numbers to detect if our latest change caused an error, I wanted to take a more principled approach (and brush up on my probability distributions🙃).

#### Gating with a Poisson Test

A Poisson distribution models how many times an event occurs in a fixed interval, given a known average rate (λ) and the assumption that events are independent:

Baseline production errors fit a Poisson model reasonably well. Using the 7-day baseline, I estimate the expected error rate per hour for each error signature, then scale it to the 60-minute post-deployment window. If the observed count significantly exceeds what the distribution predicts (p < 0.05), I flag it as a potential regression. For error signatures that are completely new (not present in the baseline at all), I flag them if they occur repeatedly in the monitoring window.

*Poisson test visualization: 7-day baseline expected rate normalized to 1hr vs observed 60-min post-deploy window, regression detected when observed exceeds threshold*
![[vishsuresh-037038-004.jpg]]

But server errors aren't always independent. Correlated failures from traffic spikes or API outages can violate the independence assumption, and a statistical test alone can't distinguish "this error spiked because of our code change" from "this error spiked because a third-party API went down." That's where the triage agent comes in.

#### The Triage Agent

Rather than feeding errors directly into Open SWE (which is tempted to make changes), I add another gating mechanism. The diffs from the last commit and the specific error get passed into a triage agent (built on Deep Agents).

First, the triage agent classifies every changed file as runtime, prompt/config, test, docs, CI, etc. If a change only touches non-runtime files, it's extremely unlikely the deployment caused the error. This prevents false positives where the agent might hallucinate a causal chain from a test file to a production bug.

For runtime changes, the agent must establish a concrete causal link between a specific line in the diff and the observed error.

The agent returns a structured verdict with its decision, confidence, reasoning, and the error signatures it attributes to the change. This narrowing means Open SWE receives a focused investigation prompt rather than a dump of every error that spiked.

*Triage agent flow: classify changed files → dismiss test/docs/CI-only changes → require causal link for runtime changes → trigger Open SWE*
![[vishsuresh-037038-005.jpg]]

#### Closing the Loop with Open SWE

Once the triage agent green-lights an investigation, Open SWE takes over, works through the bug, and opens a PR. I get notified when it's ready for review, so the entire flow from error detection to proposed fix happens without any manual intervention.

So far, it's been most useful for catching bugs that don't crash loudly: silent failures that return wrong defaults, configuration mismatches between code and deployment, and cascading regressions where fixing one bug unmasks the next on the subsequent deploy.

#### Future Improvements

**Wider Look back Window**

The triage agent currently looks at the difference between the current and previous version. Bugs introduced in earlier versions that only surface later won't get auto-attributed. Widening the look back is an obvious fix, but the more diffs you feed into the triage agent, the noisier the signal gets and the harder it is to pinpoint a causal link. I haven't landed on the right balance yet.

**Smarter Error Grouping**

The current approach uses fuzzy matching by sanitizing IDs and timestamps from error messages. It took some time to get right, and there are probably still cases where related errors don't get grouped together due to limitations in the sanitization logic.

One idea I've been considering is embedding error messages into a vector space and clustering them, rather than relying on regex normalization. Errors that mean the same thing would naturally land near each other regardless of surface-level differences, and I could detect regressions by monitoring for new clusters forming or existing clusters growing after a deploy. The challenge is tuning distance thresholds for what constitutes a meaningful cluster shift versus normal variance.

Another option is using a smaller model (likely open source) to classify and group errors, then pass those structured clusters directly to Open SWE as part of the investigation prompt, giving it a much richer picture of what's failing and how the full error looks.

All of these approaches improve grouping after errors happen. Ramp took an interesting approach that works the other way around, defining what to watch for before errors happen. To make their [Sheets product self-maintaining](https://x.com/RampLabs/status/2036165188899012655), on every PR merge an LLM reads the diff and generates monitors tailored to the changed code, each with explicit thresholds for error rate spikes, latency regressions, etc. When a monitor fires, a webhook delivers the alert context directly to an agent for triage. Defining a targeted monitor upfront produces a much clearer signal, making it easier for a downstream agent to diagnose the issue.

**Fix-Forward vs Looking Back**

Right now the system always fixes forward, Open SWE works on a PR while the broken deployment stays live. A smarter approach would be deciding between the two based on severity, error rate, and triage confidence. A high-severity spike with a low-confidence causal chain might warrant an immediate rollback, while a well-attributed bug with a clear fix path is better handled by pushing a patch forward.

#### The Loop as Default

The pattern is simple: deploy, monitor, triage, and fix—automatically in a loop. I built this for a single agent deployment, but it generalizes to any service that deploys code. Every deployment has the same problem. Something breaks, someone has to notice, someone has to fix it. The more of that loop you automate, the more engineering time shifts from reacting to building. Systems get more resilient because the feedback loop between breaking and fixing approaches zero.

> [!quote]- End Source Material

[Original post](https://x.com/vishsuresh_/status/2039748786290037038)
