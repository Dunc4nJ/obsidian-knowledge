---
created: 2026-03-22
description: Map of Content for adversarial agent optimization research — how GAN-like dynamics, self-play, and co-evolutionary training improve AI agents.
type: moc
---

# Adversarial Agent Optimization

How generator-discriminator dynamics, self-play, and co-evolutionary pressure produce stronger AI agents. These 22 papers span the landscape from foundational self-play architectures through curriculum design, reward model oversight, training stability, and compositional skill learning.

## Reading Order

Start with the core self-play architectures to build intuition for the adversarial dynamic, then follow the curriculum and judge threads in parallel — they address complementary failure modes (what to train on vs. how to evaluate). Stability papers illuminate why these systems can collapse and how to prevent it. Skill composition shows where the field is heading: agents that accumulate reusable knowledge across adversarial training loops.

---

## Core Architecture

The foundational patterns: a single system generates its own training signal through adversarial self-play.

- [[absolute zero achieves SOTA reasoning without any training data]] — One model proposes and solves code tasks via self-play with a Python executor as ground truth. The purest GAN-like loop in this collection.
- [[self-challenging agents generate their own training tasks through code-as-task verification]] — Code verification as the discriminator: agents generate tasks they can verify but can't yet solve.
- [[self-play theorem provers double proof rates by generating their own conjectures]] — SPIRAL: zero-sum games between conjecturer and prover, with role-conditioned advantage estimation to prevent collapse.
- [[zero-sum game self-play transfers reasoning skills to math benchmarks without domain data]] — STP: formal game self-play (Lean 4) transfers to math reasoning benchmarks, showing adversarial training builds general cognitive skills.
- [[codegym converts coding problems into interactive tool-use environments for generalizable agent RL]] — Converts static coding benchmarks into multi-turn tool-use environments, bridging code generation and agent RL.

## Curriculum Calibration

Controlling *what* the agent trains on — keeping tasks at the frontier of capability, neither too easy nor too hard.

- [[PAIRED uses antagonist regret to auto-generate perfectly calibrated training environments]] — The foundational UED paper: a learned adversary generates environments that maximize regret (the gap between protagonist and antagonist performance).
- [[PLR improves RL generalization by prioritizing training levels with high estimated learning potential]] — Drops the learned adversary in favour of curating randomly generated levels by estimated learning potential. Simpler, often better.
- [[ACCEL compounds environment complexity through evolution guided by regret-based curation]] — Combines PLR-style regret curation with evolutionary mutations, achieving POET-level complexity on a single GPU.
- [[AgentFrontier synthesizes training data at the boundary of what LLMs can and cannot do]] — LLM-era curriculum calibration: generate training data at the model's capability boundary using difficulty scoring.
- [[AgentGen creates diverse planning environments with bidirectional task evolution for LLM agent training]] — Bidirectional evolution: environments and tasks co-evolve to stay at the right difficulty for LLM agent training.

## Judge and Oversight

How to build reliable evaluators — and how adversarial pressure breaks them.

- [[process reward models that verify each reasoning step outperform outcome-only scoring]] — PRM800K: the case for step-level reward models, backed by 800K human annotations. Foundation for everything below.
- [[automatic process annotation eliminates the need for human labeling in step-level math verification]] — Math-Shepherd: Monte Carlo completions replace human annotators for step-level labels. 4x cheaper, comparable quality.
- [[reasoning-driven process reward models generate interpretable step evaluations that surpass direct scoring]] — R-PRM: reward models that generate natural-language critiques before scoring, improving both accuracy and interpretability.
- [[prover-verifier games train legible chain-of-thought by iteratively pitting adversarial provers against small verifiers]] — Adversarial game between a prover (generates reasoning) and a small verifier (checks it). Forces legible, checkable chain-of-thought.
- [[reward model ensembles mitigate overoptimization in RLHF by combining conservative objectives with uncertainty weighting]] — When RL optimizes against a single reward model, it exploits flaws. Ensembles with conservative objectives resist this.
- [[invariance-based stress tests detect proxy gaming by separating exploitable sensitivity from genuine improvement]] — Meta-evaluation: how to tell whether your evaluator is actually measuring what you think it is, using invariance-based probes.

## Stability and Self-Play

Training dynamics: convergence, collapse, and maintaining productive adversarial tension.

- [[self-play preference optimization converges without a separate reward model]] — SPPO: self-play as preference optimization. The model plays against its previous iteration, converging to the von Neumann winner without a reward model.
- [[self-play fine-tuning converts weak language models to strong language models]] — SPIN: iterative self-play where the model learns to distinguish its own outputs from human data. Provably converges when the model matches the target distribution.
- [[curiosity-driven red teaming achieves higher coverage by rewarding novelty over pure effectiveness]] — Novelty rewards prevent mode collapse in RL red-teaming, actually improving attack effectiveness alongside diversity.
- [[rainbow teaming generates diverse adversarial prompts through quality-diversity search]] — MAP-Elites evolutionary search for adversarial prompts. Same coverage goal as CRT but from the evolutionary computation tradition.

## Skill Composition

Building persistent, reusable knowledge across training episodes — moving beyond stateless optimization.

- [[voyager builds a persistent skill library that enables open-ended exploration without gradient updates]] — Minecraft agent that accumulates a code skill library via GPT-4 prompting. No gradient updates, pure in-context learning + retrieval.
- [[skillrl distills raw trajectories into a co-evolving hierarchical skill library that outperforms memory-based agents]] — Distills trajectories into abstract skills, then co-evolves the skill library with the policy through RL. 7B model beats GPT-4o.

---

## Cross-Cutting Themes

**The calibration problem recurs everywhere.** PAIRED, PLR, and ACCEL solve it for environments. Absolute Zero and Self-Challenging solve it for task proposals. AgentFrontier and AgentGen solve it for LLM training data. The core insight is universal: train at the boundary of what the agent can and can't do.

**Verification is the bottleneck.** PRM800K shows step-level verification works but is expensive. Math-Shepherd automates it. Prover-Verifier Games make the reasoning itself verifiable. RM Ensembles handle the case where verification is imperfect. The entire judge-and-oversight thread is about making the discriminator side reliable enough to sustain productive adversarial training.

**Diversity pressure prevents collapse.** Mode collapse in GANs has direct analogues in self-play (SPPO/SPIN convergence dynamics), red-teaming (CRT/Rainbow Teaming coverage), and curriculum design (PLR/ACCEL level diversity). Every successful system in this collection includes some mechanism for maintaining diversity.

**Code execution as ground truth.** Absolute Zero, Self-Challenging, CodeGym, and STP all use deterministic program execution as their verification signal. This sidesteps the reward model reliability issues that plague the judge-and-oversight papers, but limits applicability to domains with executable specifications.

---

*See also:* [[moc - AI Agents]] | [[moc - Reinforcement Learning]]
