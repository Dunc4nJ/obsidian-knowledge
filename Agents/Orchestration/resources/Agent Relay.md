---
created: 2026-03-01
source: https://github.com/AgentWorkforce/relay
type: resource
tags: [multi-agent, orchestration, communication, claude-code, codex]
status: captured
---

## What it is

Open-source communication layer that lets CLI coding agents (Claude Code, Codex, Gemini, OpenCode) talk to each other via named channels. Spawn agents, put them on channels, and let them coordinate peer-to-peer instead of routing everything through a human.

## Why it's interesting

Shifts multi-agent orchestration from hierarchical subagent trees (parent → child → result) to peer messaging, which enables real-time feedback loops and more emergent solutions. Includes team configuration (`teams.json`), session continuity for ephemeral agents, shadow agents for review, and a hooks system with 7 lifecycle events.

## How it works

**SDK** — `npm install @agent-relay/sdk`. Spawn agents with `relay.claude.spawn()` or `relay.codex.spawn()`, assign them to named channels, and they communicate via `sendMessage`. An observer can watch and interject but doesn't have to be the runtime.

**Team structure** — Define agent roles and staffing in `teams.json` (lead agents, worker agents, reviewers). The sweet spot is 2-5 workers per lead.

**Continuity** — Ephemeral agents save context periodically, get released, then respawn and continue by reading saved state.

## Key links

- [GitHub](https://github.com/AgentWorkforce/relay)
- [Docs](https://docs.agent-relay.com/)
- [npm](https://www.npmjs.com/package/@agent-relay/sdk)
- [Trajectories CLI](https://github.com/AgentWorkforce/trajectories/)
- [Blog: Let Them Cook](https://agent-relay.com/blog/let-them-cook-multi-agent-orchestration)

## Notes

- Extensively covered in [[agents should coordinate via push messaging not through a human copying context between terminals]] and [[2 to 5 worker agents per lead is the sweet spot for multi agent orchestration]].
- Apache-2.0 licensed.
