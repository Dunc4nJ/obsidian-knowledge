---
created: 2025-07-25
description: AutoHarness uses Gemini 2.5 Flash to automatically generate code harnesses that prevent illegal actions in game environments, using iterative refinement with Thompson sampling tree search. The synthesized harnesses let Flash outperform Pro and GPT-5.2-High.
source: https://arxiv.org/abs/2603.03329
type: paper
authors: Xinghua Lou, Miguel Lázaro-Gredilla, Antoine Dedieu, Carter Wendelken, Wolfgang Lehrach, Kevin P. Murphy
institutions: Google DeepMind
---

# AutoHarness lets LLMs synthesize their own code harness to eliminate illegal actions and outperform larger models

LLM agents frequently fail not from bad strategy but from **illegal actions** — in Kaggle GameArena chess, 78% of Gemini 2.5 Flash losses were illegal moves. Hand-coded harnesses fix this but are brittle and labor-intensive. AutoHarness has the LLM generate its own harness code instead.

## Core idea: code as harness

The LLM writes a code harness that wraps itself — at minimum a rejection sampler with a learned `is_legal_action()` function, at maximum a full **code-as-policy** that replaces LLM inference entirely.

The harness is found via **tree search over programs** guided by Thompson sampling:
- The LLM acts as a mutation operator, proposing refinements based on execution feedback
- Search balances exploration (distinct logic structures) vs exploitation (refining partial solutions)
- Only a small number of refinement rounds needed

## Key results

- **145 TextArena games**: harness prevents all illegal moves for both 1-player and 2-player games
- **Flash + harness > Pro**: smaller Gemini 2.5 Flash with auto-synthesized harness outperforms larger Gemini 2.5 Pro
- **Code-as-policy**: on 16 single-player TextArena games, the pure code policy (no LLM at inference time) beats both Gemini 2.5 Pro and GPT-5.2-High in average reward
- Cost-effective: eliminates need for LLM calls at decision time in the code-as-policy setting

## Harness spectrum

| Mode | LLM at inference? | What's learned |
|------|-------------------|----------------|
| Rejection sampling | Yes | `is_legal_action()` conditioning function |
| Flexible harness | Yes | Full control loop with validation |
| Code-as-policy | No | Entire policy in code — no LLM needed |

## Connection to Meta-Harness

This is a companion approach to [[meta-harness optimizes LLM system harnesses through automated search over code and execution traces|Meta-Harness]] (Lee et al.). Both treat the harness as a searchable artifact. Key differences:
- AutoHarness focuses on **action validity** (preventing illegal moves) in game environments
- Meta-Harness focuses on **context management** (what to store/retrieve/present) across diverse LLM tasks
- AutoHarness uses Thompson sampling tree search; Meta-Harness uses filesystem-backed agentic proposal

Both demonstrate that **optimizing the code around the model** can matter more than scaling the model itself.

---

*Full extraction: [[autoharness-full-extraction]]*
