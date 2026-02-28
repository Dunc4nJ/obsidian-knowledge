---
created: 2025-02-28
description: A framework for intelligent AI delegation that goes beyond simple task decomposition to incorporate authority transfer, accountability, trust mechanisms, and adaptive monitoring across human-AI and AI-AI delegation networks.
source: https://arxiv.org/abs/2602.11865
type: paper
authors:
  - Nenad Tomašev
  - Matija Franklin
  - Simon Osindero
arxiv: "2602.11865"
---

## Abstract

AI agents are able to tackle increasingly complex tasks. To achieve more ambitious goals, AI agents need to be able to meaningfully decompose problems into manageable sub-components, and safely delegate their completion across to other AI agents and humans alike. Yet, existing task decomposition and delegation methods rely on simple heuristics, and are not able to dynamically adapt to environmental changes and robustly handle unexpected failures. The paper proposes an adaptive framework for *intelligent AI delegation* — a sequence of decisions involving task allocation that also incorporates transfer of authority, responsibility, accountability, clear specifications regarding roles and boundaries, clarity of intent, and mechanisms for establishing trust between parties.

## Key Takeaways

The paper's central argument is that delegation is fundamentally more than task decomposition. Current multi-agent frameworks treat delegation as "split work into sub-tasks and assign them," but real delegation involves authority transfer, accountability chains, and trust establishment — exactly the dynamics that make [[over 40 percent of agentic AI projects fail due to poor architecture not model limitations|production agent systems brittle]]. The framework defines 11 task characteristics (complexity, criticality, uncertainty, duration, cost, resource requirements, constraints, verifiability, reversibility, contextuality, subjectivity) that should inform delegation decisions — a far richer model than the simple "can this agent do this task?" heuristic most orchestrators use.

The principal-agent problem maps directly onto AI delegation. When an orchestrator delegates to a sub-agent, the sub-agent may have misaligned incentives (reward hacking, specification gaming) or simply lack the context to fulfill intent. The paper notes that sycophancy and instruction-following bias create an "authority gradient" problem: delegatee agents may be reluctant to challenge, modify, or reject requests — even when the request is inappropriate for their capabilities. This connects to lessons from [[anthropic-multi-agent-research|Anthropic's multi-agent research]] on how agent coordination failures cascade.

*The intelligent delegation flowchart — from objective through structural evaluation, delegatee identification, proposal selection, to smart contract formalization*
![[tomasev-11865-fig-001.jpeg]]

The concept of "span of control" from organizational theory is directly applicable to AI oversight. How many AI agents can a human reliably oversee? How many worker agents can an orchestrator effectively manage? The paper argues this is goal-dependent and domain-dependent, with more critical tasks requiring tighter oversight at higher cost. This maps well to the tiered monitoring approaches some of our own agent workflows use — [[file-based personal OS gives AI agents persistent identity and judgment across sessions|persistent agent identity]] helps here by giving agents enough context to self-monitor.

The adaptive response cycle handles environmental changes and failures through a structured pipeline: environmental monitoring → issue detection → root cause diagnosis → response scenario evaluation → reversibility/urgency/scope checks → escalation decision.

*The adaptive response cycle — external and internal triggers feed into monitoring, evaluation, and execution phases*
![[tomasev-11865-fig-002.jpeg]]

Trust is formalized through a multi-dimensional model covering competence, benevolence, integrity, predictability, and transparency — each measurable through delegation history. The paper proposes that delegation contracts should be formalized (akin to smart contracts) specifying monitoring terms, privacy boundaries, autonomy levels, and verification requirements. This is a more rigorous version of what current agent frameworks do implicitly through system prompts and tool permissions.

The paper explicitly addresses AI-to-human delegation as an emerging pattern — not just humans delegating to AI. Algorithmic management in ride-hailing and logistics already demonstrates AI-to-human delegation at scale, often with negative welfare outcomes. As AI agents become more capable, they'll increasingly need to delegate back to humans for tasks requiring judgment, creativity, or physical action.

## External Resources

- [Google DeepMind](https://deepmind.google/) — authors' affiliation
- [Principal-Agent Problem literature](https://en.wikipedia.org/wiki/Principal%E2%80%93agent_problem) — foundational concept the framework builds on

## Original Content

> [!quote]- Full Paper Text
> The complete paper text extracted via marker-pdf is available in the source PDF. Key sections cover: Foundations of Intelligent Delegation (definitions, aspects, human organizational parallels), the Intelligent Delegation Framework (task decomposition, delegatee identification, proposal selection, negotiation, monitoring, adaptive response), Trust in Delegation (multi-dimensional trust model, trust evolution), and Safety Considerations (alignment risks, authority gradients, monitoring challenges).
>
> [Source: 2602.11865](https://arxiv.org/pdf/2602.11865)
