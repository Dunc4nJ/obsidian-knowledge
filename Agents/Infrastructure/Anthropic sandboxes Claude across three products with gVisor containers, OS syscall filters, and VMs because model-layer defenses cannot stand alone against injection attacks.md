---
created: 2026-05-27
description: Anthropic Engineering Blog details how claude.ai, Claude Code, and Claude Cowork enforce environmental containment (gVisor, Seatbelt/bubblewrap, local VMs) as the primary defense layer, because a 24/25 prompt-injection test showed secrets exfiltrate at the model layer and are only caught at the environment boundary.
source: https://x.com/AnthropicAI/status/2059351260243919269
type: framework
---

## Key Takeaways

- **Environmental containment is the primary defense; model-layer is probabilistic and cannot stand alone.** Anthropic's own test showed Claude exfiltrating secrets 24 of 25 times under prompt injection — caught only at the environment layer. This is the central admission of the post and the key architectural principle: the model is only one component of the risk surface and cannot be relied upon to prevent adversarial extraction. System prompts, classifiers, and training modifications are probabilistic tools; sandboxes, VMs, and syscall filters are deterministic ones. [[production AI agents require five security dimensions from model access to runtime observability]] frames this across five dimensions, but Anthropic's data quantifies the gap: 24/25 failure rate at the model layer.

- **Three products, three isolation tiers matched to user expertise — blast radius drives the design.** The post introduces a "blast radius" frame and maps each product to the right isolation tier:
  - **claude.ai** → gVisor containers on isolated infrastructure, ephemeral session-scoped filesystems. Minimal capability but minimal blast radius. No user filesystem access.
  - **Claude Code** → OS-level sandboxing via Seatbelt (macOS) and bubblewrap (Linux). Per-action approval originally required, but 93% of prompts were approved → approval fatigue → prompts reduced 84% via syscall filtering. Runs locally so isolation is OS-enforced, not VM-enforced.
  - **Claude Cowork** → Full local VM for non-technical users who cannot evaluate bash commands. The agent loop moved *outside* the VM for reliability while the execution environment stays isolated. Careful credential management since non-technical users cannot audit what runs.
  This tiering matches [[isolating the entire agent in a sandbox is more secure than isolating just the tool]] — isolation level should reflect the trust surface, not just the capability level.

- **Three threat categories demand different defenses across three layers.** The framework:
  - *Threats*: user misuse (intentional or careless directives) | model misbehavior (unintended harmful actions) | external attacks (prompt injection, conventional runtime attacks)
  - *Defense layers*: environment (sandboxes, VMs, filesystem limits, egress controls) | model (system prompts, classifiers, training) | external content access (tool permissions, data source controls)
  Model-layer defenses can be bypassed — the injection test proves it. Environment-layer defenses are enforced by the kernel or hypervisor and are not subject to model reasoning errors.

- **Pre-trust execution is the most commonly missed attack surface.** Several failures originated not from a running agent acting maliciously, but from config files and setup scripts parsing external content before the user had consented to any trust relationship. A file touched before a trust dialog is shown can contain instructions that execute with implicit permission. This is a class of attack that model-layer defenses cannot address: the agent isn't making a decision, the bootstrapping infrastructure is. [[Opencomputer reframes harness-vs-sandbox debate as git branches for VMs via hibernation egress proxies and checkpoints]] surfaces the same issue under the credential-injection lens — egress must be locked *before* the agent loop starts.

- **Allowlist exploitation converts approved domains into attack vectors.** An agent legitimately permitted to call a model provider API can POST arbitrary payloads to that endpoint. An allowlist that grants access to GitHub can be exploited to stage unauthorized file uploads. Anthropic's post names this explicitly: the approved domains themselves become the attack surface. This is why [[LangSmith Auth Proxy keeps credentials outside agent runtimes by intercepting sandbox egress at the network layer]] argues that "which destinations are allowed" and "what authentication is applied" must be separate controls, both enforced at the network layer.

- **Custom security components are the weakest link — use established infrastructure primitives.** Anthropic's key principle: "the software you build yourself is often the weakest layer." Hypervisors and syscall filters (gVisor, Seatbelt, bubblewrap, Firecracker) have accumulated adversarial attention across thousands of deployments; a proprietary proxy or allowlist has not. This inverts the usual build-vs-buy calculus for security: the more adversarially hardened a primitive is, the more trust it deserves. [[Firecracker microVMs became the convergent agent runtime because containers were never a security boundary]] makes the same argument — containers were operationally convenient but never designed for adversarial multi-tenant isolation.

- **Dynamic, capability-correlated permissions are the unsolved frontier.** Approval fatigue at 93% drove Anthropic to reduce prompts by 84% via OS sandboxing — but this trades user oversight for usability. The post surfaces the open problem: how do you grant an agent more permissions as its task progresses, without either exhausting users with approvals or granting too much upfront? @jahanzaibai named it precisely: "dynamic permission tightening as tasks complete is what most agent frameworks don't even try to solve yet." @aabyzov flipped the frame: "knowing what an agent did inside the sandbox beats constraining what it could do" — audit trails as the true answer to capability-scaled permission systems.

- **VM isolation creates an EDR blind spot that defenders must explicitly plan for.** Moving execution into a VM prevents endpoint detection software (EDR) from monitoring agent activity — the hypervisor boundary is opaque to host-side tooling. This is a direct tradeoff: stronger isolation in exchange for weaker observability. [[Local-first agent sandboxes converge on libkrun not Firecracker because macOS has no KVM so Hypervisor framework is the only path - ghumare64 iii-sandbox deep dive]] notes a parallel tradeoff — isolation at the VMM level comes with observability costs that must be compensated at the host layer.

## Blog Post Diagrams

![[anthropicai-919269-001.png]]
![[anthropicai-919269-002.png]]
![[anthropicai-919269-003.png]]
![[anthropicai-919269-004.png]]

## External Resources

- [How we contain Claude across products](https://www.anthropic.com/engineering/how-we-contain-claude) — Anthropic Engineering Blog, May 2026
- [gVisor](https://gvisor.dev/) — user-space kernel used for claude.ai container isolation
- [Bubblewrap](https://github.com/containers/bubblewrap) — unprivileged sandbox for Linux (used in Claude Code)
- [Seatbelt](https://developer.apple.com/documentation/security/app_sandbox) — macOS sandbox profile used in Claude Code
- [PolicyLayer](https://x.com/PolicyLayer/status/2059368925997977841) — "For MCP fleets, that layer is a policy gate on every tool call" — built tooling on this insight

## Original Content

> [!quote]- Source Tweet — @AnthropicAI, Tue May 26 19:09:35 UTC 2026
> New on the Engineering Blog: The access and permissions we grant agents should evolve with their capabilities. In our own products, we set these parameters through sandboxing, which limits the scope of any potentially destructive actions.
>
> Read more: https://www.anthropic.com/engineering/how-we-contain-claude

> [!quote]- Anthropic Engineering Blog: "How we contain Claude across products" (May 2026)
>
> ### Overview
>
> This post examines containment strategies for Claude across three platforms: claude.ai, Claude Code, and Claude Cowork. The authors explain how they balance agent capabilities against potential damage ("blast radius").
>
> ### Three Risk Categories and Defense Components
>
> Three risk types:
> - **User misuse**: Intentional or careless harmful directives
> - **Model misbehavior**: Unintended harmful actions by the agent
> - **External attacks**: Prompt injection and conventional runtime attacks
>
> Defense occurs across three layers:
> 1. **Environment**: Sandboxes, VMs, filesystem boundaries, egress controls
> 2. **Model layer**: System prompts, classifiers, training modifications
> 3. **External content access**: Tool permissions and data source controls
>
> ### Containment Patterns
>
> **claude.ai (Ephemeral Container)**
> Uses gVisor containers on isolated infrastructure with ephemeral, session-based filesystems. Minimal blast radius but limited capabilities — no persistent workspace or user filesystem access.
>
> **Claude Code (Human-in-the-Loop Sandbox)**
> Runs locally with filesystem and shell access. Originally required per-action approval, causing fatigue (users approved ~93% of prompts). Now uses OS-level sandboxing (Seatbelt/bubblewrap) reducing permission prompts by 84%. Key vulnerabilities included code executing before trust dialogs and susceptibility to phished prompts containing exfiltration instructions.
>
> **Claude Cowork (Local VM)**
> Runs in a virtual machine for non-technical users who cannot evaluate bash commands. Uses full isolation with careful credential management. The agent loop moved outside the VM for reliability while maintaining security guarantees.
>
> ### Critical Lessons from Failures
>
> Several missed risks identified:
>
> - **Pre-trust execution**: Configuration files parsed before user consent created entry points
> - **User-as-vector injection**: Direct prompt injection bypasses model-layer defenses
> - **Allowlist exploitation**: Approved domains became attack surfaces (e.g., legitimate API access used for unauthorized file uploads)
> - **EDR visibility loss**: VM isolation prevents endpoint detection software from monitoring activity
>
> ### Key Principles
>
> - Environmental containment should be primary; model-layer defenses are probabilistic
> - Isolation strength should match user expertise level
> - Custom security components are weaker than established infrastructure primitives
>
> The authors note that "the software you build yourself is often the weakest" layer, contrasting hypervisors and syscall filters (hardened by adversarial attention) against proprietary proxies and allowlists that failed.

> [!quote]- Selected Reply Thread (verbatim)
>
> **@roeytechai (Roey | AI & Tech)** — Tue May 26 19:20:18 UTC 2026
> Sandboxing is a solid technical bandage but it still assumes the model won't find clever ways around the walls as it gets smarter.
> Anthropic's approach of tying permissions directly to evolving capabilities is honest progress on the safety side.
>
> ---
>
> **@hirefortuna (Hire Fortuna)** — Tue May 26 19:40:16 UTC 2026
> This is exactly right, and it's the principle most people deploying agents miss entirely. Capability without containment is the actual risk — the answer isn't a better-behaved model, it's sandboxing that hard-limits what an agent can do regardless of what it decides. AI proposes, a deterministic boundary disposes. Building real products on agents means the guardrails are architecture, not afterthoughts. 🔒
>
> ---
>
> **@zazmic_inc (Yann Kronberg)** — Tue May 26 20:04:47 UTC 2026
> Agent safety gets weird because the model can behave and the system can still fail. The moment agents can click, fetch, send and change things the model is only one part of the risk.
> Permissions and environment rules usually end up doing a lot of the real protection.
>
> ---
>
> **@PolicyLayer (PolicyLayer)** — Tue May 26 20:19:47 UTC 2026
> The key admission: model-layer defences "can't stand alone."
> Your own test showed Claude exfiltrating secrets 24 of 25 times under injection — caught only at the environment layer.
> For MCP fleets, that layer is a policy gate on every tool call.
> We built it: [PolicyLayer link]
>
> ---
>
> **@Surreal_Intel (surreal intelligence)** — Tue May 26 20:12:35 UTC 2026
> Useful framing. The important thing is not just what agents can do, but when they become entitled to do more. Capability growth without permission discipline is how sandboxes turn into offices.
>
> ---
>
> **@jahanzaibai (Jahanzaib Ahmed)** — Tue May 26 20:48:05 UTC 2026
> Sandboxing handles the worst case. I think it's the dynamic permission tightening as tasks complete that most agent frameworks don't even try to solve yet.
>
> ---
>
> **@aabyzov (Anton Abyzov)** — Wed May 27 00:20:25 UTC 2026
> Capability-scaled permissions is the right frame. Harder problem is the audit trail. Knowing what an agent did inside the sandbox beats constraining what it could do.
>
> ---
>
> **@spanlens (spanlens)** — Wed May 27 09:29:04 UTC 2026
> Sandboxing handles the blast radius, but the harder problem is making the sandbox's shape legible to the agent itself. Without it you get two failure modes: over-cautious permission asks for trivial actions, or blocked destructive attempts followed by confused recovery loops.
>
> ---
>
> **@daptonai (Dapton AI)** — Wed May 27 08:33:24 UTC 2026
> Giving an agent full permissions on day one because you trust the model is the same logic as giving a new hire admin access because they interviewed well.
> Capability has to be earned incrementally. Not assumed upfront.
> The teams that get this right are the ones building agents that are still running six months later. The ones that skip it are the ones with the incident report.
>
> ---
>
> **@toolhalla (Toolhalla.ai)** — Wed May 27 16:50:08 UTC 2026
> Sandboxing is becoming the core product surface for agents, not a detail. Tool access is only safe when permissions, filesystem scope, network scope, and audit trails are obvious to the user.
>
> ---
>
> **@RaafatMS1 (IRewaQI)** — Wed May 27 11:35:22 UTC 2026
> Tested this last week — sandboxing felt like friction until we realized the friction was the feature. One unscoped agent nearly rewrote a config file it had no business touching. Granular permissions aren't overhead; they're the only reason I trust agents in real workflows.
>
> ---
>
> **@SignalHouseSMS (Signal House)** — Wed May 27 15:16:46 UTC 2026
> agent sandboxing for code is the right model. now do it for messaging. an agent that sends sms should have a scoped a2p campaign, a rate limit it cannot exceed, and an audit log that survives the agent itself. the permissions surface for outbound comms is the next obvious extension.
>
> ---
>
> **@tiagobuilds (Tiago Rama)** — Wed May 27 10:47:11 UTC 2026
> Permissions become the product once agents can act.
> The scary part is not bad answers, it is bad actions.

> [!quote]- Reply images
> ![[anthropicai-919269-005.jpg]]
> ![[anthropicai-919269-006.jpg]]
> ![[anthropicai-919269-007.jpg]]
