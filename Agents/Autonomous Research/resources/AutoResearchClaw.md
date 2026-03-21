---
created: 2026-03-21
description: "Fully autonomous 23-stage research pipeline that generates conference-ready papers from a single idea — real literature, sandbox experiments, 4-layer citation verification, NeurIPS/ICML LaTeX output."
source: https://github.com/aiming-lab/AutoResearchClaw
type: resource
---

# AutoResearchClaw

**What it is:** An open-source Python framework that autonomously generates academic papers from a single research idea. The 23-stage pipeline handles everything: literature discovery (OpenAlex, Semantic Scholar, arXiv), hypothesis generation via multi-agent debate, hardware-aware experiment execution in sandboxed environments, self-healing code when experiments fail, 4-layer citation verification to eliminate hallucinated references, and LaTeX export targeting NeurIPS/ICML/ICLR conference formats. Output is a compile-ready paper with BibTeX, experiment code, and charts.

**Why it's interesting:** This is the [[autoresearch lets an AI agent run ML experiments autonomously overnight|autoresearch pattern]] taken to its logical extreme — not just running experiments overnight, but handling the entire research lifecycle end-to-end. Key differentiators: the PIVOT/REFINE loop (stage 15 autonomously decides to proceed, tweak parameters, or change direction entirely), MetaClaw integration for cross-run learning (pipeline failures become structured lessons for future runs), and OpenClaw-native integration where you can just say "Research X" and it handles clone/install/config/run. Also supports ACP (Agent Client Protocol) so you can use Claude Code, Codex, Gemini CLI, or any compatible agent as the LLM backend without API keys.

**Links:**
- GitHub: https://github.com/aiming-lab/AutoResearchClaw
- MetaClaw (cross-run learning): https://github.com/aiming-lab/MetaClaw
- Discord: https://discord.gg/u4ksqW5P
- Paper Showcase (8 papers across 8 domains): https://github.com/aiming-lab/AutoResearchClaw/blob/main/docs/showcase/SHOWCASE.md
