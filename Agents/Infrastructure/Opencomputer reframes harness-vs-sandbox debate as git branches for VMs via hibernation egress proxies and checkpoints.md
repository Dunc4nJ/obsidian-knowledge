---
created: 2026-05-05
description: Utpal Nadiger argues that egress-proxy credential tokenization, 25ms VM hibernation, and checkpoint-fork durability ("git branches for VMs") collapse Mendral's case for running the agent harness outside the sandbox — but the rebuttal sidesteps the multi-user shared-state problem.
source: https://x.com/utpalnadiger/status/2051300006490153146
type: framework
---

## Key Takeaways

- **Cattle-vs-pets is a false binary; checkpoints plus hibernation create a third option — "git branches for VMs".** When the entire VM (process tree, memory, file handles, the loop itself) freezes in ~25ms and forks from any of ten checkpoints per sandbox, losing a host stops being losing a session. This is the same primitive every production database has used for forty years applied to the agent execution environment, and it's the strongest conceptual contribution of the piece — a category-different abstraction that reframes the debate rather than just rebutting it. Sits next to [[Harvey Spectre makes durable runs the core primitive while workers stay ephemeral and sandboxes enforce explicit boundaries]], which makes the *run record* the durable object instead of the VM.
- **Egress-proxy credential tokenization is a 15-year-old solved primitive that decouples credential security from harness location.** Fly's Tokenizer, mitmproxy, AWS IMDS, and HashiCorp Vault all implement the same pattern: the sandbox holds an opaque handle, the proxy substitutes the real secret at the network boundary, and the upstream service sees a properly authenticated request. Framing "credentials stay outside the sandbox" as an architectural property of harness location is sleight-of-hand — the actual property is "credentials never at rest in execution context", which a proxy gives you regardless of where the loop sits. Same pattern as [[Browserbase's bb agent generalizes knowledge work through four building blocks - sandbox, credential-brokering proxy, loadable skills, and Slack]].
- **Hibernation that drops the entire VM to disk in 25ms invalidates Mendral's "you can't suspend the thing the loop is running on" cost argument.** If the loop, tools, and workspace all freeze together — billed only for snapshot storage, not compute — and elasticity scales the live VM between 1GB/1vCPU and 16GB/4vCPU based on observed pressure, then idle billing collapses regardless of whether the harness is inside or outside. The harness "rides the resize" through cargo builds and CI waits. This is closer to V8-isolate-style ephemeral primitives like [[Cloudflare Dynamic Workers sandbox AI-generated code in V8 isolates 100x faster than containers]] than to traditional container sandboxes.
- **Where the rebuttal dodges: the multi-user shared-state problem.** Mendral's strongest section was about dozens of engineers in one organization sharing skills and memories with last-writer-wins consistency, parallel sessions on the same incident, and the resulting distributed-filesystem problem. Utpal's response is single-session-shaped — forks help with parallel exploration of *one* session, not with cross-session memory consistency across a team. Persistent per-session sandboxes still leave you with that problem; the bash leak (an agent can `grep -r '/skills/'` and bypass any virtualization layer) makes it worse. This is the genuinely hard problem [[LangChain Deep Agents runtime builds ten production capabilities on one primitive - durable super-step checkpointing to PostgreSQL]] addresses by moving memory into Postgres with path-dispatch routing.
- **The real fault line is runtime-level durability versus VM-level durability.** Mendral bets on Inngest checkpointed super-steps (the loop is a function, each turn is a step, durability lives in the workflow engine); Opencomputer bets on VM-level hibernation plus filesystem checkpoints (the sandbox *is* the unit of durability). Both work for single-user; both compose with backend-side durability for things the sandbox doesn't own (LLM calls, cross-session events, webhook intents). Calling Inngest "infrastructure they had to build because the loop lives on the backend" is ungenerous — Inngest is off-the-shelf and Mendral composed it. The honest framing is: *this is two infrastructure startups making different bets on which durability primitive to load-bear, not a settled architectural debate.*

## External Resources

- [The Agent Harness Belongs Outside the Sandbox (Andrea Luzzardi, Mendral)](https://www.mendral.com/blog/agent-harness-belongs-outside-sandbox) — the original article being rebutted; outlines two architectures (harness inside vs outside sandbox), Mendral's choice of the outside model, and their solutions for durable execution (Inngest), sandbox lifecycle (Blaxel 25ms resume), and virtualized filesystem with path-dispatch routing
- [Fly Tokenizer](https://github.com/superfly/tokenizer) — open-source HTTP proxy that swaps opaque handles for real secrets at the egress boundary; cited as the canonical "credentials never at rest in sandbox" implementation
- [mitmproxy](https://www.mitmproxy.org/) — open-source interactive HTTPS proxy usable as a credential-substitution layer for sandboxed agents
- [Opencomputer](http://opencomputer.dev/) — Utpal's company; sells the persistent-sandbox-with-hibernation primitive that the whole rebuttal rests on
- [Opencomputer Elasticity docs](https://docs.opencomputer.dev/sandboxes/elasticity) — 1GB/1vCPU to 16GB/4vCPU autoscaling with 1-minute scale-up cooldown and 15-minute scale-down hysteresis; in-VM scaling API at link-local 169.254.169.254 for self-scaling agents
- [Opencomputer Checkpoints docs](https://docs.opencomputer.dev/sandboxes/checkpoints) — filesystem and installed-state snapshots, up to 10 per sandbox, forkable for parallel exploration or post-failure recovery
- [Original X post](https://x.com/utpalnadiger/status/2051300006490153146) — the rebuttal in full

## Original Content

*Header art: hand-drawn illustration of the article title with a fork-from-checkpoint diagram suggesting a third path beyond cattle and pets*
![[utpalnadiger-153146-001.jpg]]

> [!quote]- Source Material
> **@utpalnadiger (Utpal Nadiger) — 2026-05-04**
>
> Article: Stop Treating Agent Sandboxes as Cattle
>
> This article is in direct response to "[The agent Harness belongs outside the sandbox](https://www.mendral.com/blog/agent-harness-belongs-outside-sandbox)" by Andrea Luzzardi. The premise of this article is that, well, you can (and in most cases should) run the agent harness inside the sandbox.
>
> This article has 3 specific rebuttals to what is in that blog by Andrea and what I think is fundamentally flawed in the arguments mentioned there. Lastly, to the author - Mendral looks incredible, more power to you!
>
> ## Now for the rebuttals!
>
> 1. "Running the harness outside the sandbox gets you things the inside model can't. Your credentials stay out of the sandbox. The loop holds the LLM API keys, the user tokens, the database access. The sandbox holds only the environment the agent needs to do its work. There's nothing in there for the agent to escape to, so there's no permission model to enforce and no credential leak to contain."
>
> We think that this is a solved problem & has been for years.
>
> What you essentially want is credentials never at rest in the sandbox. A network egress proxy gives you that (there are ones that are open source like fly's [tokenizer](https://github.com/superfly/tokenizer) or [mitmproxy](https://www.mitmproxy.org/)):
>
> - The sandbox holds a handle (an opaque token, a placeholder, a short lived metadata service response). No real credential material.
>
> - Outbound traffic routes through the proxy. The proxy substitutes the real token at the boundary.
>
> - The upstream service sees a properly authenticated request. The sandbox NEVER sees the real secret.
>
> This is what Fly's Tokenizer does. It's what AWS IMDS does for EC2 and Lambda with short lived role credentials. It's also the pattern Hashicorp Vault popularized fifteen years ago. It's the default for human developers and CI systems already, and it transfers cleanly to agent sandboxes.
>
> *Egress proxy pattern: sandbox sends request plus opaque handle; proxy swaps the handle for the real secret pulled from a secret store; upstream API sees an authenticated request — credentials never at rest in the sandbox*
> ![[utpalnadiger-153146-002.jpg]]
>
> 2. "A lot of what an agent does doesn't need a sandbox at all: thinking, calling APIs, summarizing, waiting for CI. Some sessions never touch a sandbox. With the harness outside, you provision one only when the agent needs to run a command, and suspend it whenever it's idle. When the harness lives inside the sandbox you can't do any of this, because you can't suspend the thing the loop is running on."
>
> Precisely right on the cost concern, idle compute shouldn't bill. But this isn't an argument for running the harness outside the sandbox,  but about hibernation and elasticity, both of which are properties of the sandbox primitive & doesn't concern the location of the harness.
>
> "You can't suspend the thing the loop is running on" is only true if your sandbox can't hibernate the whole VM. [Opencomputer](http://opencomputer.dev/) can:
>
> - Hibernation drops idle sandboxes to disk. The entire VM ie. process tree, in-memory state, file handles, the loop itself is frozen and resumable in ~25ms. While hibernated, you're billing for snapshot storage and not compute. So stuff like CI waits, LLM round-trips, multi-minute "thinking" stretches all happen while the sandbox is essentially "off".
>
> - [Elasticity](https://docs.opencomputer.dev/sandboxes/elasticity) scales the live VM between 1GB/1vCPU and 16GB/4vCPU based on observed memory pressure, with a 1 min cooldown on scale up and 15 min of low utilization data required to scale down. Idle agent reasoning runs at the bottom tier. A cargo build or npm install triggers a scale-up; it drops back when the work is done. The harness lives inside throughout, and it just rides the resize!
>
> - For workloads that know their own shape better than the autoscaler can infer, there's an in-VM scaling API at 169.254.169.254 so the agent can scale itself up before a known heavy step and back down after. We think this is especially valuable in an era where agents are becoming more ambitious and have more autonomy.
>
> *Lifecycle timeline showing the harness staying resident through hibernation (snapshot-only billing during thinking and CI waits), automatic scale-up to 16GB/4vCPU during cargo builds, and self-scaling via the link-local 169.254.169.254 API*
> ![[utpalnadiger-153146-003.jpg]]
>
> 3. "Sandboxes become cattle. If one dies mid-session, the loop provisions a new one and keeps going. When the harness runs inside, the sandbox is the session, and losing it loses the session."
>
> The is also a real concern, no one wants to lose a multi hour session because a host went down ofc.
>
> But this ALSO isn't an argument about where the harness runs. It's an argument about whether your sandbox primitive has "durability" built into it.
>
> "Cattle vs pets" offers two options and asks you to pick one.
>
> There's a third, and we think of it as git branches for VMs. With Opencomputer.dev:
>
> - Hibernation freezes the entire VM (process tree, in-memory state, file handles, the loop itself) and resumes it in ~25ms. Rolling deploys, scale events, restarts that are planned etc. all survivable. The loop kinda doesn't notice anything happened.
>
> - For unexpected stuff, [Checkpoints](https://docs.opencomputer.dev/sandboxes/checkpoints) snapshot filesystem and installed state at any point in the session, and you can have up to 10 of them per sandbox. If a sandbox dies hard (host failure, kernel panic) you fork a fresh sandbox from the most recent checkpoint and resume. The harness re-reads on disk state ie. conversation history, planning state, todo list, the same way Claude Code does after you close your laptop and open it back up.
>
> - Also forks aren't just for recovery. You can branch from any checkpoint to explore alternative paths in parallel: three migration strategies, two debugging hypotheses, two different refactors, without paying to bootstrap each one from scratch. The original keeps running.
>
> *Git-branches-for-VMs: a single trunk session forks twice from earlier checkpoints to explore alternative paths in parallel while the original continues; a host failure on the trunk (red X) is recovered by forking from the latest checkpoint*
> ![[utpalnadiger-153146-004.png]]
>
> All this to say that losing a sandbox isn't losing the session.
>
> It's restoring from a snapshot, the same coordination primitive every production database has used for the last forty years!
>
> The original article spends a whole section on durable execution: agent loops are long running, have to survive deploys, and Mendral solved it with Inngest checkpointing each turn as a step.
>
> That's durable execution infrastructure they had to build because the loop lives on the backend. With the agent running inside a computer + checkpoints, the sandbox is the unit of durability ie. the entire compute environment, which means it isn't a function call. Inngest is a great tool, but the problem it's solving here doesn't exist if the sandbox is the host.
>
> Andrea's article isn't really 'the harness belongs outside the sandbox.' It's 'the harness belongs outside an ephemeral sandbox.'  The thesis is sort of tautological once you state the assumption. Persistent sandboxes (ala computers with a https proxy) don't have these problems. So, yeah, the agent harness probably belongs outside a "sandbox" but inside a "computer".
>
> And fwiw, between right and easy, developers will always pick easy. We're on a mission to make them the same path.
>
> Engagement: 14 likes | 3 retweets | 0 replies
> [Original post](https://x.com/utpalnadiger/status/2051300006490153146)
