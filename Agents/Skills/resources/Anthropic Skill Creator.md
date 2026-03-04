---
created: 2026-03-04
source: https://github.com/anthropics/skills/tree/main/skills/skill-creator
description: Anthropic's official meta-skill for creating, evaluating, and iterating on Claude Code skills — includes eval harness, variance analysis, and description optimization
type: resource
tags: [skills, claude-code, evaluation, agent-skills]
status: unread
---

## What it is

Anthropic's official "skill-creator" — a meta-skill for Claude Code that guides the process of creating new skills, running evaluations against them, and iteratively improving them. Part of the [anthropics/skills](https://github.com/anthropics/skills) repo.

## Why it's interesting

This is Anthropic's own methodology for skill authoring, distilled into a skill. It encodes a full eval-driven development loop: draft a skill → write test prompts → run Claude with the skill → evaluate results (qualitative + quantitative) → rewrite → repeat. It also includes a description optimizer for improving skill triggering accuracy, and a variance analysis system for benchmarking skill performance across multiple runs.

The skill writing guidance is particularly valuable — it codifies patterns like progressive disclosure (metadata → SKILL.md body → bundled resources), the 500-line SKILL.md limit, domain organization by variant, and making descriptions "pushy" to combat Claude's tendency to undertrigger skills.

## How it works

**Workflow:**
1. Capture intent — what the skill does, when it triggers, expected output format
2. Interview and research — edge cases, input/output formats, dependencies
3. Write SKILL.md — frontmatter (name, description), markdown instructions, bundled resources
4. Create 2-3 test prompts → save to `evals/evals.json`
5. Run Claude with the skill on test prompts
6. Draft quantitative assertions while runs execute
7. Review results (qualitative + metrics) with user
8. Rewrite skill based on feedback
9. Repeat until satisfied, then expand test set
10. Run description optimizer for triggering accuracy

**Skill anatomy:**
```
skill-name/
├── SKILL.md (required)
│   ├── YAML frontmatter (name, description required)
│   └── Markdown instructions
└── Bundled Resources (optional)
    ├── scripts/    - Executable code
    ├── references/ - Docs loaded into context as needed
    └── assets/     - Files used in output (templates, icons)
```

**Progressive disclosure (three-level loading):**
1. Metadata (name + description) — always in context (~100 words)
2. SKILL.md body — loaded when skill triggers (<500 lines ideal)
3. Bundled resources — loaded as needed (unlimited)

**Key writing patterns:**
- Imperative form for instructions
- Explain *why* things matter rather than heavy-handed MUSTs
- Use theory of mind; keep skills general, not narrow to specific examples
- Make descriptions "pushy" to combat undertriggering
- Include examples with Input/Output format

## Key links

- [GitHub (skill-creator)](https://github.com/anthropics/skills/tree/main/skills/skill-creator)
- [GitHub (anthropics/skills repo)](https://github.com/anthropics/skills)
- [Agent Skills blog post](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)

## Notes

- The eval system uses `evals/evals.json` for test cases with assertions, plus an `eval-viewer/generate_review.py` script for reviewing results.
- Description optimization is a separate script that improves triggering accuracy — important because Claude tends to undertrigger skills.
- Compare with our own [[create-global-skill]] workflow which follows similar patterns but is adapted for our multi-agent OpenClaw setup.
