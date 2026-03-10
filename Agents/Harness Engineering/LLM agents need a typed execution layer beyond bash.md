---
created: 2026-03-09
description: Bash accidentally became the first LLM execution layer by letting agents progressively discover and chain tools, but agents need a typed, portable environment (TypeScript) with proper permission gating, approval rules, and proxy capabilities to replace the ad-hoc CLI wrapper pattern.
source: https://x.com/RhysSullivan/status/2030903539871154193
type: learning
---

## Key Takeaways

Bash wasn't just another tool added to LLM agents — it was the accidental introduction of the first execution layer. Before bash, agents made direct tool calls that flooded context with irrelevant information. Bash let agents progressively discover tools, chain commands, and grep output when it was too long. The insight that [[harness engineering improved a coding agent 13 points by changing only system prompts tools and middleware|fewer tools produce better agent performance]] is exactly what made bash so effective: one meta-tool that unlocks everything else.

But bash falls apart at the problems that matter for production agent systems: sharing authenticated state across agents (Cursor, OpenCode, OpenClaw), tiered approval rules for destructive vs read-only actions, wildcard permission patterns, and multi-account service access. These are all [[agent harness is the real product|harness-level concerns]] that bash was never designed to handle. The explosion of CLI wrappers around REST APIs (DataDog's Pup, Google Workspace CLI, Polymarket CLI) is a symptom — they're all essentially the same pattern of wrapping an API spec, which suggests a missing abstraction layer.

The proposed solution — a TypeScript execution environment — addresses this by providing typed inputs/outputs for approval rule matching, proxy capabilities for auth sharing, portability across teams and agents, and the npm ecosystem for composability. The [[factory droid exec uses tiered autonomy levels to gate agent permissions from read-only to full system access|tiered autonomy pattern]] already seen in Factory Droid and similar systems would be much cleaner to implement in a typed environment than in bash scripts. Rhys Sullivan's open-source implementation is [Executor](https://github.com/RhysSullivan/executor), which runs entirely locally and integrates with existing tools.

The broader pattern: we're seeing the labs already moving toward this. 2026 is shaping up to be about execution layers, not bash — a natural evolution from the [[Claude Code's single-threaded master loop delivers controllable autonomy through radical simplicity|single-threaded agent loops]] of today toward richer, typed runtime environments.

## External Resources

- [Executor](https://github.com/RhysSullivan/executor) — Open-source TypeScript code execution environment for LLMs by Rhys Sullivan
- [Pup (DataDog CLI)](https://github.com/DataDog/pup) — Example of the CLI-wrapper-around-REST-API pattern
- [Google Workspace CLI](https://developers.google.com/workspace) — Another instance of the same pattern

## Original Content

> @RhysSullivan — 2026-03-09
>
> **The Execution Layer**
>
> LLMs are in desperate need of an execution layer made for them to run tool calls in.
>
> A year ago LLMs were making direct calls to tools, we found that it flooded their context with irrelevant information to them and found incredibly poor performance.
>
> Then we discovered with coding agents that the less tools you give them, the better they perform, and so now every agent got a bash tool.
>
> Here's the thing though, bash wasn't just a tool it was the introduction of the first execution layer. The LLM was now able to progressively discover tools, chain commands, grep their output when it was too long. It was the first execution layer that slipped in just as a regular tool.
>
> Bash is imperfect however, think about the following problems we have with agents today:
>
> - You want to share your signed in state between agents (Cursor, OpenCode, OpenClaw)
> - You want to share approval methods
> - You want some agents to have access to some tools
> - You have to be signed in to 2 accounts at the same time for a service
> - You need to know all possible operations that can be performed by your installed tools
> - Any read only actions I want to auto run, but require approval of destructive ones
> - You want to apply wildcard approval rules to functions
> - You need to know whether an action is destructive or not
> - For teams, you want to be able to enable your sales team to call Salesforce but not your engineers
>
> Attempting to represent this in bash with CLIs is insane. The lack of standard around what actions are destructive and which aren't, attempting to elicit input from the user, knowing everything that's available, doing wildcard approvals
>
> You've seen companies do this today already making CLI clients for their APIs, like Pup from DataDog, Google Workspace CLI, Polymarket CLI
>
> Go open up the source for them, what you'll see is the same thing for all of them - they're all essentially wrappers around a REST API spec
>
> You may think to yourself, well the solution here is to make a CLI that lets you call any API! But that's thinking too small, you're not building something that will enable every person in the world to interact with services and that's not bash.
>
> So what can we do? Well we need a typed environment with input / outputs, the ability to proxy calls, along with it being cheap to run and portable - TypeScript is right there.
>
> By creating a TypeScript environment for the LLMs to call tools through, you create a portable environment that can be shared with teams, is super lightweight to run, has a strong ecosystem around it, and strongly typed so you can get really creative with approval rules.
>
> There's limitless potential here, some rough ideas:
>
> - Embedding these proxy objects in generative UI
> - A 'use workflow' style system to allow the agent to receive webhooks or schedule crons
> - Global stubs to allow mocking or dry runs
> - Giving them access to virtual filesystems, KV stores, sqlite that spin up for a workspace or session
> - Supporting the npm ecosystem so your agent can do things like call the AI SDK
> - Wildcard approvals based on inputs to functions
> - Sharing 'snippets' of code
>
> By building the right execution layer, you're able to solve this perfectly rather attempting to adapt something that was never meant for this. We're already seeing the labs implement forms of this - 2026 is not the year of bash, it's the year of the execution layer.
>
> If you want to try it today, check out Executor an open source code execution environment for LLMs. Runs entirely locally and works with all your existing tools https://github.com/RhysSullivan/executor
>
> Also, before you say "but the agents are good at bash!" remember that Claude wrote your entire application, I think he can handle a few scripts to call services
>
> *Author profile image*
> ![[rhyssullivan-154193-001.jpg]]
>
> Engagement: 714 likes | 46 retweets | 55 replies
> [Original post](https://x.com/RhysSullivan/status/2030903539871154193)
