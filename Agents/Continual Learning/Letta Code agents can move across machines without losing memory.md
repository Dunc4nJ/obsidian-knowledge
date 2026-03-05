---
created: 2026-03-05
description: Letta introduces remote environments that let a single stateful coding agent execute on any registered machine (laptop, VM, sandbox) while preserving full memory and conversation history via WebSocket.
source: https://x.com/Letta_AI/status/2029348848913793333
type: reference
---

## Key Takeaways

Letta's remote environments solve a real pain point in agentic coding: the coupling of agent state to a single machine. Because [[Letta Code is a memory-first coding agent|Letta Code agents are stateful by design]], separating the interaction surface (chat.letta.com) from the execution environment is a natural extension. The agent's memory, conversation history, and context repositories persist server-side, so switching from a laptop to a cloud VM mid-conversation doesn't lose anything.

The architecture uses WebSocket connections between the agent and registered environments, which means any machine running `letta server` becomes a potential execution target. This is conceptually similar to the problem described in [[agents need a database because stateless reasoning cores require stateful storage]] — Letta's answer is that the agent's state lives in their hosted platform, not on the execution machine. The execution machine is just a disposable compute surface.

The human-in-the-loop approval flow carries over WebSocket too, with four permission tiers from full approval to "yolo mode." This matters for remote execution where you might be approving tool calls on your phone for an agent running on a cloud VM — the trust boundary needs to be explicit. The pattern mirrors what other harnesses are doing with [[seven runtime failures emerge when demo agents meet production distributed systems|production agent infrastructure]], where governance and multi-tenancy become first-class concerns.

## External Resources

- [Letta Code npm package](https://www.npmjs.com/package/@letta-ai/letta-code) — the CLI/server package for registering remote environments
- [chat.letta.com](https://chat.letta.com/) — web interface for interacting with Letta agents across environments
- [Context Repositories blog post](https://www.letta.com/blog/context-repositories) — Letta's approach to persistent context management

## Original Content

> @Letta_AI — 2026-03-05
>
> **Agents with memory that work across machines**
>
> We're introducing remote environments, a way to separate where you interact with a Letta agent from where it executes. Using remote environments, you can interact with Letta agents that run locally on registered machines through [chat.letta.com](http://chat.letta.com/). For example, you can message agents running on your laptop from your phone.
>
> Letta Code agents are stateful, so agents can move across execution environments without losing their memory and context (e.g. conversation history, [context repositories](https://www.letta.com/blog/context-repositories), etc.)
>
> *Architecture: a single agent connects to multiple execution environments via WebSocket*
> ![[letta_ai-793333-001.jpg]]
>
> **Remote execution for agents**
>
> Any machine (whether it's your local MacBook or a cloud sandbox) can be used as a remote execution environment. To register a machine, install Letta Code and start the Letta Code server:
>
> ```bash
> # install Letta Code
> npm i -g @letta-ai/letta-code
>
> # start the WebSocket server
> letta server
> ```
>
> This will start a WebSocket server locally, and you can name your environment for easy discovery:
>
> *Terminal running `letta remote` showing a registered MacBook environment awaiting instructions*
> ![[letta_ai-793333-002.jpg]]
>
> On [chat.letta.com](http://chat.letta.com/), you can select which remote environment your agent uses when you message your agent.
>
> **Agents that can move across machines**
>
> With remote environments in Letta Code, a single agent can work across:
>
> - Your laptop
> - An ephemeral sandbox
> - A remote VM (e.g. Railway, GCP)
>
> Regardless of where your agent runs, it still has the same persistent memory. Agents can even move across environments in the same conversation.
>
> **Permission modes when working remotely**
>
> Remote Environments carry the full human-in-the-loop approval flow over WebSocket. When the agent invokes a tool that requires approval, the approval request is surfaced in chat.letta.com. The user can approve, deny, or edit the tool arguments before execution proceeds.
>
> You can configure the same permission modes with remote execution as you can with the Letta Code CLI:
>
> - Default: Standard approval checks for sensitive operations
> - Accept Edits: Auto-approve file edits, prompt for everything else
> - Plan: Agent plans but doesn't execute
> - Bypass Permissions: Full autonomy, no approval prompts ("yolo-mode")
>
> **Next steps**
>
> You can register your machine as a remote environment running the WebSocket server using the latest Letta Code package:
>
> ```bash
> npm install -g @letta-ai/letta-code
> ```
>
> Then, just visit chat.letta.com.
>
> Engagement: 115 likes | 9 retweets | 1 reply
> [Original post](https://x.com/Letta_AI/status/2029348848913793333)
