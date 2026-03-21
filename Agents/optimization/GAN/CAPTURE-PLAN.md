# Paper Capture Plan — Adversarial Agent Optimization Research

**Created:** 2026-03-21
**Status:** NOT STARTED
**Vault target:** `Knowledge/Agents/optimization/GAN/`
**Media folder:** `Knowledge/Agents/optimization/GAN/_media/`

---

## Overview

Capture ~22 papers (full GPU extraction) + ~6 light sources into the vault, organized into 5 subfolders. Each paper gets a full url-to-obsidian treatment: claim-based title, frontmatter, Key Takeaways with wiki-links, full verbatim Original Content with all figures/equations, and MOC integration.

---

## Subfolder Structure

```
Knowledge/Agents/optimization/GAN/
├── CAPTURE-PLAN.md                          ← this file
├── moc - Adversarial Agent Optimization.md  ← reading-order narrative MOC
├── core-architecture/
├── curriculum-calibration/
├── judge-and-oversight/
├── stability-and-self-play/
└── skill-composition/
```

---

## Phase 1: GPU Batch Extraction

**Goal:** Download all PDFs, run marker-pdf, pull extracted markdown + images back to VPS.
**GPU:** Vast.ai instance (reuse existing or start new)
**Estimated time:** 30-60 min
**Status:** [ ] NOT STARTED

### Steps:
1. [ ] Start Vast.ai GPU instance (`gpu-start`)
2. [ ] SSH in, confirm marker-pdf is installed (install if not)
3. [ ] Download all PDFs via batch script (see PDF list below)
4. [ ] Run marker-pdf on each PDF
5. [ ] Pull all extracted markdown + images back to VPS (`/tmp/gan-papers/`)
6. [ ] Stop GPU instance (`gpu-stop`)

### PDF Download List (22 papers):

#### core-architecture/ (5 papers)

| # | Paper | arXiv ID | URL | Status |
|---|-------|----------|-----|--------|
| 1 | Absolute Zero | 2505.03335 | https://arxiv.org/pdf/2505.03335 | [ ] |
| 2 | Self-Challenging Language Model Agents | 2506.01716 | https://arxiv.org/pdf/2506.01716 | [ ] |
| 3 | SPIRAL | 2506.24119 | https://arxiv.org/pdf/2506.24119 | [ ] |
| 4 | STP (Self-play Theorem Provers) | 2502.00212 | https://arxiv.org/pdf/2502.00212 | [ ] |
| 5 | CodeGym | 2509.17325 | https://arxiv.org/pdf/2509.17325 | [ ] |

#### curriculum-calibration/ (5 papers)

| # | Paper | arXiv ID | URL | Status |
|---|-------|----------|-----|--------|
| 6 | PAIRED | 2012.02096 | https://arxiv.org/pdf/2012.02096 | [ ] |
| 7 | PLR (Prioritized Level Replay) | 2010.03934 | https://arxiv.org/pdf/2010.03934 | [ ] |
| 8 | ACCEL | 2203.01302 | https://arxiv.org/pdf/2203.01302 | [ ] |
| 9 | AgentFrontier (ZPD-guided) | 2510.24695 | https://arxiv.org/pdf/2510.24695 | [ ] |
| 10 | AgentGen (Bi-Evol) | 2408.00764 | https://arxiv.org/pdf/2408.00764 | [ ] |

#### judge-and-oversight/ (6 papers)

| # | Paper | arXiv ID | URL | Status |
|---|-------|----------|-----|--------|
| 11 | PRM800K (Let's Verify Step by Step) | 2305.20050 | https://arxiv.org/pdf/2305.20050 | [ ] |
| 12 | Math-Shepherd | 2312.08935 | https://arxiv.org/pdf/2312.08935 | [ ] |
| 13 | R-PRM | 2503.21295 | https://arxiv.org/pdf/2503.21295 | [ ] |
| 14 | Prover-Verifier Games | 2407.13692 | https://arxiv.org/pdf/2407.13692 | [ ] |
| 15 | RM Ensembles (Reward Model Ensembles) | 2310.02743 | https://arxiv.org/pdf/2310.02743 | [ ] |
| 16 | Evaluator Stress Tests | 2507.05619 | https://arxiv.org/pdf/2507.05619 | [ ] |

#### stability-and-self-play/ (4 papers)

| # | Paper | arXiv ID | URL | Status |
|---|-------|----------|-----|--------|
| 17 | SPPO | 2405.00675 | https://arxiv.org/pdf/2405.00675 | [ ] |
| 18 | SPIN | 2401.01335 | https://arxiv.org/pdf/2401.01335 | [ ] |
| 19 | Curiosity-Driven Red Teaming | N/A | https://openreview.net/pdf?id=4KqkizXgXU | [ ] |
| 20 | Rainbow Teaming | 2402.16822 | https://arxiv.org/pdf/2402.16822 | [ ] |

#### skill-composition/ (2 papers)

| # | Paper | arXiv ID | URL | Status |
|---|-------|----------|-----|--------|
| 21 | Voyager | 2305.16291 | https://arxiv.org/pdf/2305.16291 | [ ] |
| 22 | SkillRL | 2602.08234 | https://arxiv.org/pdf/2602.08234 | [ ] |

---

## Phase 2: Organize Extractions

**Goal:** Sort extracted files into subfolder buckets, verify quality, prepare manifest for sub-agents.
**Status:** [ ] NOT STARTED

### Steps:
1. [ ] Create local staging dirs: `/tmp/gan-papers/{core-architecture,curriculum-calibration,judge-and-oversight,stability-and-self-play,skill-composition}/`
2. [ ] Move each paper's extracted markdown + images into its subfolder
3. [ ] Spot-check 2-3 extractions for quality (equations rendered? figures extracted?)
4. [ ] Create `_media/` folder in vault: `Knowledge/Agents/optimization/GAN/_media/`
5. [ ] Copy all extracted images into `_media/` with consistent slug prefixes (e.g. `absolute-zero-001.png`, `paired-001.png`)
6. [ ] Write manifest file `/tmp/gan-papers/manifest.json` mapping each paper to: subfolder, extracted markdown path, image files, arXiv URL, paper title

---

## Phase 3: Parallel Sub-Agents for Note Creation (5 agents)

**Goal:** Each agent takes one subfolder's papers and creates full vault notes following url-to-obsidian SKILL.md.
**Status:** [ ] NOT STARTED

### Agent assignments:

| Agent | Subfolder | Papers | IDs |
|-------|-----------|--------|-----|
| Agent A | core-architecture/ | 5 papers | #1-5 |
| Agent B | curriculum-calibration/ | 5 papers | #6-10 |
| Agent C | judge-and-oversight/ | 6 papers | #11-16 |
| Agent D | stability-and-self-play/ | 4 papers | #17-20 |
| Agent E | skill-composition/ | 2 papers | #21-22 |

### Each agent's instructions:
1. Read the url-to-obsidian SKILL.md for template/format rules
2. For each assigned paper:
   a. Read the pre-extracted markdown from `/tmp/gan-papers/<subfolder>/<paper>.md`
   b. Analyze content → extract core claim (becomes the note title)
   c. Write Key Takeaways — original analysis, NOT copied text
   d. Run `qmd search` to find related vault notes for wiki-linking
   e. Cross-link to sibling papers in other subfolders (provide full paper list to each agent)
   f. Write the full note using the note template
   g. Embed ALL figures with `![[slug-NNN.ext]]` syntax and italic captions
   h. Include full verbatim Original Content (entire paper text)
   i. Verify original content completeness via `verify-original-content.sh`
   j. Save note to `Knowledge/Agents/optimization/GAN/<subfolder>/`
3. Do NOT git commit — leave that for Phase 4

### Cross-linking reference (provide to all agents):
All agents receive the full list of 22 paper titles + their subfolder locations so they can create `[[wiki links]]` to sibling papers across subfolders.

---

## Phase 4: Sequential Commit + MOC

**Goal:** Review, commit, write MOC, update parent MOCs.
**Status:** [ ] NOT STARTED

### Steps:
1. [ ] Review Agent A output (core-architecture/) → commit to Knowledge submodule
2. [ ] Review Agent B output (curriculum-calibration/) → commit
3. [ ] Review Agent C output (judge-and-oversight/) → commit
4. [ ] Review Agent D output (stability-and-self-play/) → commit
5. [ ] Review Agent E output (skill-composition/) → commit
6. [ ] Write `moc - Adversarial Agent Optimization.md` with:
   - Reading-order narrative linking all papers
   - Section intros for each subfolder explaining the research thread
   - The "5-piece architecture" synthesis from our conversation
7. [ ] Update `Knowledge/Agents/moc - Agents.md` with new optimization/GAN section
8. [ ] Update vault root `moc - Vault.md` if needed
9. [ ] Final commit + push both Knowledge submodule and vault root
10. [ ] Run `qmd update` to reindex

---

## Phase 5: Non-PDF Light Captures

**Goal:** Capture blog posts, GitHub repos, and surveys as resource/light notes.
**Status:** [ ] NOT STARTED

### Light capture list (web_fetch, no GPU needed):

| # | Source | Type | URL | Subfolder | Status |
|---|--------|------|-----|-----------|--------|
| L1 | Lilian Weng — Reward Hacking survey | Blog | https://lilianweng.github.io/posts/2024-11-28-reward-hacking/ | judge-and-oversight/ | [ ] |
| L2 | Anthropic — Recommended Research Directions | Blog | https://alignment.anthropic.com/2025/recommended-directions/ | judge-and-oversight/ | [ ] |
| L3 | Anthropic — Emergent Misalignment from Reward Hacking | Paper | https://arxiv.org/pdf/2511.18397 | judge-and-oversight/ | [ ] |
| L4 | awesome-llm-self-play | GitHub repo | https://github.com/tim-grams/awesome-llm-self-play | stability-and-self-play/ | [ ] |
| L5 | OpenSpiel | GitHub repo | https://github.com/google-deepmind/open_spiel | stability-and-self-play/ | [ ] |
| L6 | PRM Survey | Survey paper | https://arxiv.org/pdf/2510.08049 | judge-and-oversight/ | [ ] |

**Note:** L3 (Anthropic Emergent Misalignment) is a full arXiv paper — could promote to full capture if desired. Currently light because it's motivation, not mechanism.

### Execution:
- Spawn 1 sub-agent to handle all 6 light captures
- Uses web_fetch / markdown.new for blogs, web_fetch for GitHub READMEs
- Creates resource-style notes (shorter Key Takeaways, link-heavy)
- Same subfolder placement, same commit process

---

## On-the-Fence Papers (Decided: NOT capturing, revisit later)

| Paper | Why cut | Reconsider if... |
|-------|---------|-------------------|
| SWEET-RL | Credit assignment — important but least GAN-like | Building multi-turn agent tasks |
| SPC (Self-Play Critic) | Very close to our arch but new/less cited | It gets traction |
| AlphaStar (Nature) | Likely paywalled | Find open-access version |
| BrowseComp-Plus | Web browsing eval, not core | Need held-out benchmark design |
| AgentConductor | Solver topology, orthogonal | Building multi-agent solver teams |
| MARS | Thin vs SPIRAL | Need GRPO specifically |
| TextArena | Just an eval environment | Need LLM game environments |
| PBT Survey | Too broad | Need population-based training deep dive |
| RACED | Superseded by ACCEL | Need unified PAIRED+PLR theory |
| No Regrets (UED) | Incremental over PAIRED/PLR | Need latest UED refinements |

---

## Budget Estimates

| Resource | Estimate |
|----------|----------|
| Vast.ai GPU time | ~30-60 min → $0.50-1.50 |
| Sub-agent API tokens (5 full + 1 light) | ~6 spawns |
| Total papers | 22 full + 6 light = 28 vault notes |
| Estimated wall-clock time | 2-3 hours (GPU extraction + parallel agents) |

---

## Progress Tracker

| Phase | Status | Started | Completed | Notes |
|-------|--------|---------|-----------|-------|
| Phase 1: GPU Extraction | [ ] NOT STARTED | — | — | |
| Phase 2: Organize | [ ] NOT STARTED | — | — | |
| Phase 3: Sub-agents | [ ] NOT STARTED | — | — | |
| Phase 4: Commit + MOC | [ ] NOT STARTED | — | — | |
| Phase 5: Light captures | [ ] NOT STARTED | — | — | |

---

*This plan was designed by CRM + MetaLearner on 2026-03-21 based on research from @Vtrivedy10's auto-research GAN thread.*
