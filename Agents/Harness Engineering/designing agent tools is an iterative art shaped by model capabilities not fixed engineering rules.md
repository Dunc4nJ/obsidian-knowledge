---
created: 2026-02-27
description: Lessons from Anthropic's Claude Code team on designing agent tool interfaces — progressive disclosure, elicitation via AskUserQuestion, evolving from Todos to Tasks as models improve, and why tool design is art not science.
source: https://x.com/trq212/status/2027463795355095314
type: knowledge
---

# Designing agent tools is an iterative art shaped by model capabilities, not fixed engineering rules

Thariq (Anthropic, Claude Code team) lays out hard-won lessons from building Claude Code's tool system. The core insight: tool design must be shaped to the model's actual abilities, and those abilities change as models improve — so your tools must evolve too.

## Tool design as capability matching

The analogy: solving a hard math problem. Paper works but limits you to manual calculation. A calculator is better but you need to know the advanced functions. A computer is the most powerful but requires knowing how to code. You give the agent tools shaped to what it can actually do, and you discover what it can do by reading its outputs.

## AskUserQuestion: finding the sweet spot for elicitation

Three attempts to improve Claude's ability to ask clarifying questions:

1. **ExitPlanTool parameter** — added a questions array alongside the plan. Failed because asking for a plan and questions about the plan simultaneously confused the model. What if answers contradicted the plan?
2. **Modified markdown output** — free-form structured output. Claude was okay at it but not reliable — it would append extra sentences, omit options, use different formats.
3. **AskUserQuestion tool** — a dedicated tool callable at any point (especially during planning). Shows a modal, blocks the agent loop until the user answers. Structured output, composable, clear UI surface.

![[claude-code-askuserquestion-sweet-spot.png]]
*The sweet spot between no structure (messy free-form) and too rigid (questions baked into plan tool).*

The key finding: even a well-designed tool doesn't work if the model doesn't understand how to call it. AskUserQuestion worked because Claude naturally understood it.

## From Todos to Tasks: tools must evolve with model capabilities

Early Claude Code used a TodoWrite tool — a linear checklist with system reminders every 5 turns. As models improved, this became constraining: reminders made Claude think it had to stick to the list rather than adapt. Opus 4.5 got much better at subagents, but a shared linear todo list couldn't support multi-agent coordination.

The replacement: **Tasks** — with dependencies, cross-subagent updates, the ability to alter and delete. Todos were about keeping one model on track; Tasks are about helping agents communicate.

![[claude-code-todos-to-tasks.png]]
*Evolution from single-agent linear todos to multi-agent task graphs with dependencies.*

> As model capabilities increase, the tools that your models once needed might now be constraining them. It's important to constantly revisit previous assumptions.

## Progressive disclosure over tool proliferation

Claude Code has ~20 tools. The bar to add a new one is high because each tool adds cognitive load for the model.

When Claude needed to answer questions about itself (MCP setup, slash commands), putting docs in the system prompt would cause context rot. Instead:
- First try: give Claude a link to docs it could load. Worked but Claude loaded too many results.
- Solution: a **Guide subagent** with specialized doc-search instructions. New functionality added to the action space without adding a tool.

The broader pattern: Claude went from not being able to build its own context, to nested search across several layers of files to find exact context. Agent Skills formalized this as progressive disclosure — agents incrementally discover relevant context through exploration rather than having everything front-loaded.

## Search interface evolution

Early Claude Code used RAG (vector database) for context. While powerful, it required indexing/setup, was fragile across environments, and gave Claude context instead of letting it find context itself. Replacing RAG with a Grep tool let Claude search and build context on its own — a pattern that scales as models get smarter.

## Key takeaway

> Experiment often, read your outputs, try new things. See like an agent.

There are no rigid rules. Tool design depends on the model, the goal, and the environment. The practice is: observe what the model actually does, then reshape the tools to match.

## Links

- [Original thread](https://x.com/trq212/status/2027463795355095314) by [@trq212](https://x.com/trq212) (Thariq, Anthropic)
- Related: [[harness engineering improved a coding agent 13 points by changing only system prompts tools and middleware]]
