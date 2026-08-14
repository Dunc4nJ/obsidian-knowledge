---
created: 2026-08-14
description: Hamel Husain's summary of Adam Azzam's (Modal) session — "don't build agents, build environments." Coding agents need isolated sandboxes once you run them in parallel or collaborate; CI/CD is a poor fit (slow start, short-lived, and agent code is unreviewed — it can crash hosts or leak credentials). Ramp bakes machine images on a 30-minute schedule so an agent grabs a ready machine and is working after git pull in under a second; and separate agents from their tools so a crashing tool (OOM on a big CSV) doesn't kill a long trajectory.
source: https://hamel.dev/notes/llm/ai-product-engineering/systems-agent-sandboxes.html
author: Hamel Husain (summarizing Adam Azzam's session, Modal)
type: article
tags: [harness-engineering, sandbox, agent-infrastructure, isolation, modal, ramp, ai-product-engineering, hamel]
---

## Key Takeaways

- **Sandboxes become necessary exactly when velocity does: parallel agents, collaboration, unreviewed code.** Locally-run agents hide the need; the moment you run many in parallel, the blast radius argument takes over — agent code is unreviewed, and a bad change can crash the machine or expose credentials in the environment. **CI/CD is the wrong substrate**: slow to start, short-lived by design, while an agent may work for hours or days and *edit the dependencies of its own environment*. Same conclusion as [[Stripe's Kai is a coding agent for non-engineers - one engineer shipped it on Deep Agents in a week and federated skills carried it to 83 percent weekly adoption|Stripe's sandbox-as-a-tool]] and the vault's [[sandboxed CI is the missing infrastructure for agent evals at scale|sandboxed-CI-for-evals]] argument, from the infrastructure side.

- **Ramp's pattern: bake the machine image every 30 minutes, so agent startup is `git pull` and go — under a second.** Slow startup is the bottleneck at volume; pre-baking everything (dependencies installed, environment ready) turns cold-start into image-grab. That's the difference between agents as batch jobs and agents as on-demand workers.

- **Separate the agent from its tools — a crashing tool must not kill the trajectory.** A tool that loads a huge CSV and OOMs shouldn't take down hours of agent work; process isolation between the reasoning loop and its tools is the harness-level version of [[Deep Agents interpreter middleware gives agents a programmable middle lane between serial tool loops and full sandboxes through explicit host-runtime bridges|explicit host-runtime bridges]]. Modal's Sandbox API makes the pattern a six-line hello-world (create app → create sandbox → exec → read → terminate), fast enough that remote "feels local."

## External Resources

- Original note: [Don't Build Agents, Build Environments — Hamel Husain](https://hamel.dev/notes/llm/ai-product-engineering/systems-agent-sandboxes.html) ([AI Product Engineering series](https://hamel.dev/notes/llm/ai-product-engineering/))
- [Adam Azzam's talk](https://maven.com/p/0684ab) · [Modal sandbox guide](https://modal.com/docs/guide/sandboxes) · [Ramp](https://ramp.com/)

## Original Content

> [!quote]- Full note — "Don't Build Agents, Build Environments" (Hamel Husain; session by Adam Azzam, Modal)
> _This note covers Adam Azzam’s session in the [AI Product Engineering series](../../../notes/llm/ai-product-engineering/index.html)._
>
> If you run coding agents locally, the need for a sandbox may not be obvious yet. It starts to matter once your coding velocity picks up, you run many agents in parallel, or you start collaborating with others. A sandbox isolates the code each agent runs and keeps the blast radius small when something breaks.
>
> ![[hamel-sandboxes-001.png]]
>
> CI/CD (the tool many people try first) is a poor fit. It’s slow to start and short-lived, while an agent may work on a task for hours or days and edit the dependencies of its own environment. The agent’s code is also unreviewed, so a bad change can crash the machine or expose the credentials in the environment.
>
> Slow startup becomes a bottleneck once you run agents at volume. [Ramp](https://ramp.com/) solves this by baking its machine image on a 30-minute schedule with everything installed. When an agent starts, it grabs a ready machine, runs `git pull`, and is working in under a second.
>
> Another design principle is to separate the agent from the tools it calls. If a tool crashes, you don’t want it to take down the agent. For example, a tool that loads a large CSV and runs out of memory shouldn’t kill a long-running agent trajectory.
>
> Adam currently works at [Modal](https://modal.com), which is my favorite cloud infrastructure. It’s unique in that it’s so fast that it feels local, even though code is running remotely. The hello world example for creating a sandbox in Modal is:
>
> ```
> import modal
>
> app = modal.App.lookup("sandbox-hello-world", create_if_missing=True)
> sb = modal.Sandbox.create(app=app)
> process = sb.exec("echo", "hello")
> print(process.stdout.read())
> sb.terminate()
> ```
>
> Watch the full session [here](https://maven.com/p/0684ab). Also, read the [Modal sandbox guide](https://modal.com/docs/guide/sandboxes).
