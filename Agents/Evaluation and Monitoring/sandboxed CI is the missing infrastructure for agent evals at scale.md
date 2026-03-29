---
created: 2026-03-30
description: Agent eval pipelines need sandboxed CI infrastructure with per-task isolation and massive parallelization to handle stochastic results across many models and eval subsets.
source: https://x.com/vtrivedy10/status/2038331304471585187
---

## Key Takeaways

The shift from "writing code" to "verifying code" as the bottleneck means CI infrastructure is suddenly interesting again. When agents generate code, the hard part moves downstream to evaluation — and evaluation at scale requires infrastructure patterns that traditional CI never needed. This resonates with the insight that [[agent eval readiness starts with error analysis and simple end-to-end tests not sophisticated infrastructure]], though Viv's point is that at some scale you genuinely do need the infrastructure.

Running evals across 10+ models (closed-source, open-source, different inference providers) and 100+ eval tasks creates a combinatorial explosion. Each combination needs isolation — a sandbox per task — to avoid cross-contamination and enable parallel execution. This is a different problem from [[deep agent evals need bespoke per-datapoint test logic not uniform evaluators]]: here the challenge isn't eval design but eval execution infrastructure. The flakiness, API timeouts, and infra errors Viv describes are exactly what makes [[agent production monitoring requires observing inputs and outputs not just system metrics]] so critical.

The stochastic nature of agent evals adds another layer: harder evals don't produce deterministic pass/fail, so you need repeated runs to build statistical confidence. This connects to [[targeted evals shape agent behavior more effectively than large benchmark suites]] — you want to run the right subset intensively rather than everything shallowly. Cost optimization (only running affected eval subsets) mirrors how traditional CI optimizes test selection, but the sandbox-per-task pattern is new infrastructure territory.

Viv's stack uses Harbor for environment mocking (file system contents) and LangSmith for tracing — keeping [[Agno native tracing keeps agent observability data in your own database]] style observability as the source of truth for metrics. The thread surfaces Depot CI and Modal as infrastructure players in this space.

## External Resources

- [Modal](https://modal.com) — sandboxed compute platform by Erik Bernhardsson; the quoted tweet's author is Modal's co-founder
- [Depot CI](https://depot.dev) — CI platform mentioned by @kylegalbraith as aligned with sandbox-per-task ideas
- [Harbor](https://github.com/av/harbor) — environment mocking tool used by Viv for file system simulation in evals
- [LangSmith](https://smith.langchain.com) — tracing and observability platform used as source of truth for eval metrics

## Original Content

> **@bernhardsson (Erik Bernhardsson)** — 2026-03-29 (quoted tweet)
>
> CI feels more interesting today than it ever was. Writing code has gotten a lot faster, but this shifts the bottleneck elsewhere. I'm excited about sandboxes as a primitive for massive parallelization of tests.
>
> [Original post](https://x.com/bernhardsson/status/2038286561570140261)

---

> **@Vtrivedy10 (Viv)** — 2026-03-29
>
> for the first time, I'm excited by CI!  it's an interesting efficiency + cost + infra problem with agent evals
>
> to test agent changes at scale, we hook up to Github Actions and often need to spin up a sandbox per task to run the new experiment across N models
>
> for tasks that don't need a sandbox (often simple, non coding evals), we don't provision one but were considering every eval to just run in a sandbox and be defined by a single interface
>
> today we mock out the environment like the file system contents using Harbor and instrument tracing into LangSmith to have a source of truth for metrics and traces we can review
>
> at the scale of 10+ models (closed, OSS, different inference providers) and subsets of over 100 evals, we run into weird infra errors, API timeouts, flakiness that we need to catch and reprovision infra to accurately capture
>
> we want speed by massively parallelizing tests with a sandbox per task and we want to save on costs - only run the subset that we're testing
>
> this idea of parallelizing tests always existed but agents are requiring new infra patterns for us to do this well!
>
> Engagement: 31 likes | 1 retweet | 4 replies
> [Original post](https://x.com/Vtrivedy10/status/2038331304471585187)

---

> **@bblaine_dev (Bobby Blaine)** — 2026-03-29
>
> @Vtrivedy10 Totally! CI for agent evals is becoming crucial as AI tools scale. The sandbox-per-task approach is smart - keeps experiments isolated. Curious how you handle timeout/cancellation for long-running evals?
>
> [Reply](https://x.com/bblaine_dev/status/2038332550750388465)

---

> **@Av1dlive (Avid)** — 2026-03-29
>
> @Vtrivedy10 CI for agent evals is hella underrated
>
> Great take again Viv
>
> [Reply](https://x.com/Av1dlive/status/2038334524954952144)

---

> **@Vtrivedy10 (Viv)** — 2026-03-29
>
> @Av1dlive it's a fun problem, who says CI and devops can't be cool :)
>
> good measurement also gets tricky with harder evals where success rate is stochastic with many models, not always done but need to rerun to get some confidence what's happening
>
> [Reply](https://x.com/Vtrivedy10/status/2038335111289053272)

---

> **@kylegalbraith (Kyle Galbraith)** — 2026-03-29
>
> @Vtrivedy10 You should definitely check out our new Depot CI at @depotdev as this is very close to some of the ideas we have built it on.
>
> [Reply](https://x.com/kylegalbraith/status/2038347666040467512)

---

> **@ivanburazin (Ivan Burazin)** — 2026-03-29
>
> @Vtrivedy10 Lmk if we should chat about this
>
> [Reply](https://x.com/ivanburazin/status/2038362354988024154)

---

> **@Vtrivedy10 (Viv)** — 2026-03-29
>
> @ivanburazin big fan of y'all as you know from prev experiments!  will reach out on Slack as we get stuff cleaned up, hope it's helpful for y'all to see our problem setup at the very least
>
> [Reply](https://x.com/Vtrivedy10/status/2038364409270075667)
