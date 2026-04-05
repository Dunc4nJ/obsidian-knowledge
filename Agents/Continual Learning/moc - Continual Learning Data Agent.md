---
created: 2025-07-27
description: Navigation hub for the Continual Learning Data Agent project — research papers, architectures, and frameworks for agents that learn and evolve over time.
source: internal
type: moc
---

# Continual Learning Data Agent

Research and frameworks for building AI agents that persistently learn, remember, and improve across sessions.

## Research Papers

- [[self-improving agents independently invent memory systems when given permission to modify themselves]] — mem0 analysis of Meta's HyperAgents: DGM-H agents independently build performance trackers, synthesized insight stores, and causal hypothesis logs by generation 3 when given full self-modification permission

- [[trajectory-informed memory extraction turns agent execution histories into reusable strategy recovery and optimization tips]] — IBM Research framework: four-component pipeline extracting strategy/recovery/optimization tips from agent trajectories via causal attribution, +14.3pp SGC on AppWorld
- [[parametric memory encoding cross-sample reflection patterns into weights produces more diverse and effective self-improvement than retrieval]] — ParamMem: lightweight LoRA module that encodes cross-sample reflection patterns, enabling diverse reflection generation via temperature sampling for self-improving agents
- [[MemSkill - Learning and Evolving Memory Skills for Self-Evolving Agents]] — Learning and Evolving Memory Skills for Self-Evolving Agents
- [[ProcMEM - Learning Reusable Procedural Memory from Experience via Non-Parametric PPO for LLM Agents]] — Learning Reusable Procedural Memory from Experience via Non-Parametric PPO for LLM Agents

## Frameworks

- [[file-based personal OS gives AI agents persistent identity and judgment across sessions]] — file-based operating system using markdown, YAML, and JSONL in Git for persistent agent context, episodic memory, and voice encoding
- [[recursive self-improvement works when LLM judges detect friction patterns and the agent implements its own fixes]] — Factory's Signals system: LLM-as-judge session analysis, self-evolving friction taxonomy via embedding clusters, closed-loop ticket filing and agent self-patching
- [[async RL from real conversations lets agents continuously improve without blocking inference]] — OpenClaw-RL async RL framework turning real conversations into training signals
- [[learning machines turn agents from stateless tools into systems that compound knowledge across users and sessions]] — extensible Learning Stores enabling cross-user knowledge continuity
- [[letta-code-blog]] — Letta Code: memory-first coding agent architecture, top model-agnostic OSS harness on TerminalBench

## Infrastructure

- [[self-serve post-training infrastructure is emerging as the key layer between foundation models and enterprise adoption]] — survey of emerging self-serve post-training tools (Prime Intellect Lab, Tinker, Harbor RL, CGFT) for enterprise RL/fine-tuning loops
- [[traces and evals form the core of continuous harness learning in agent systems]] — thread synthesis on situational/hierarchical memory and trace-driven continuous behavior updates

## Analysis

- [[agent-continual-learning-impl]] — deep implementation comparison of continual learning in letta-code, scout, and serena
  - [[stable agentic RL requires sequence-level clipping and environment-aware advantages to prevent training collapse]]
