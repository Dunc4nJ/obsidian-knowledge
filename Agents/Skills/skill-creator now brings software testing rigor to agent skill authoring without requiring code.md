---
created: 2026-03-03
description: Anthropic's skill-creator updates add evals, benchmarks, multi-agent parallel testing, A/B comparisons, and description optimization to the agent skill authoring workflow — no coding required.
source: https://claude.com/blog/improving-skill-creator-test-measure-and-refine-agent-skills
type: learning
---

# Skill-creator now brings software testing rigor to agent skill authoring without requiring code

## Key Takeaways

Anthropic distinguishes two kinds of skills: **capability uplift** (teaching Claude techniques the base model can't do consistently) and **encoded preference** (sequencing existing capabilities per your team's process). This taxonomy matters because they need testing for different reasons — capability uplift skills may become unnecessary as models improve (evals tell you when), while encoded preference skills need fidelity checks against your actual workflow. This maps well to our own skill ecosystem, where skills like [[create-global-skill]] encode specific authoring patterns that could eventually become default model behavior.

The new **eval framework** lets skill authors define test prompts, describe what good looks like, and get pass/fail results — essentially unit tests for skills. The PDF skill case study is concrete: non-fillable form filling was broken, evals isolated the failure, and the fix anchored text positioning to extracted coordinates. This is the kind of regression-catching that matters as models change under you.

**Benchmark mode** runs standardized assessments tracking pass rate, elapsed time, and token usage — metrics you can plug into CI. The **multi-agent support** spins up independent agents for parallel eval execution with clean contexts (no cross-contamination between test runs). **Comparator agents** do blind A/B comparisons between skill versions.

The **description optimization** feature is particularly interesting for anyone managing a growing skill library. As skill count grows, description precision becomes critical for triggering accuracy. Skill-creator now analyzes descriptions against sample prompts and suggests edits to reduce both false positives and false negatives — they saw improved triggering on 5/6 public document-creation skills.

The forward-looking thesis is that evals may eventually *become* the skill — a natural-language description of "what" the skill should do replaces the detailed "how" instructions, with the model figuring out implementation. This echoes the broader trend toward specification-over-implementation in agent tooling.

## External Resources

- <https://github.com/anthropics/claude-plugins-official/tree/main/plugins/skill-creator> — Skill-creator plugin for Claude Code
- <https://github.com/anthropics/skills/tree/main/skills/skill-creator> — Skill-creator source in Anthropic's skills repo
- <https://claude.com/blog/skills> — Original Agent Skills launch blog post (October 2025)

## Original Content

> [!quote]- Source Material — Anthropic Blog: Improving skill-creator (March 3, 2026)
>
> # Improving skill-creator: Test, measure, and refine Agent Skills
>
> *Skill authors can now verify that their skills work, catch regressions, and improve descriptions.*
>
> Category: Claude Code, Product announcements
> Date: March 3, 2026
> Reading time: 5 min
>
> Skill-creator now helps you write evals, run benchmarks, and keep your skills working as models evolve. These updates are available now in Claude.ai and Cowork, as a [plugin for Claude Code](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/skill-creator), and [within our repo](https://github.com/anthropics/skills/tree/main/skills/skill-creator).
>
> Since [launching Agent Skills](https://claude.com/blog/skills) last October, we've noticed that most authors are subject matter experts, not engineers. They know their workflows but don't have the tools to tell whether a skill still works with a new model, triggers when it should, or if it actually improved after an edit.
>
> Today we're announcing skill-creator enhancements that help authors build with more confidence. We are bringing some of the rigor of software development (testing, benchmarking, iterative improvement) to skill authoring without requiring anyone to write code.
>
> ## Two kinds of skills
>
> Skills generally fall into two categories:
>
> **Capability uplift** skills help Claude do something the base model either can't do or can't do consistently. Our [document creation skills](https://github.com/anthropics/skills/tree/main/skills) are good examples. They encode techniques and patterns that produce better output than prompting alone.
>
> **Encoded preference** skills document workflows where Claude can already do each piece, but the skill sequences them according to your team's process. Examples: a skill that walks through NDA review against set criteria, or one that drafts weekly updates with data from various MCPs.
>
> This distinction matters because these two types of skills may need testing for different reasons:
>
> - Capability uplift skills may become less necessary as models improve. Evals tell you when that's happened.
> - Encoded preference skills are more durable, but only as valuable as their fidelity to your actual workflow. Evals verify that fidelity.
>
> Either way, testing turns a skill that _seems_ to work into one you _know_ works.
>
> ## Using evals to test and improve skills
>
> Skill-creator now helps you write evals, which are tests that check Claude does what you expect for a given prompt. If you've written software tests, this will feel familiar: define some test prompts (plus files if needed), describe what good looks like, and skill-creator tells you whether the skill holds up.
>
> Our PDF skill, for instance, previously struggled with non-fillable forms. Claude had to place text at exact coordinates with no defined fields to guide it. Evals isolated the failure, and we shipped a fix that anchors positioning to extracted text coordinates.
>
> *PDF skill eval results showing pass/fail across test cases*
> ![[skillcreator-pdf-evals.png]]
>
> Evals help in many ways, but two important uses are to catch quality regressions and understand model progress.
>
> First, **catching regressions in quality.** As models and the infrastructure around them evolve, a skill that worked well last month might behave differently today. Running evals against a new model gives you an early signal when something shifts before it impacts your team's work.
>
> Second, **knowing when general model capabilities have outgrown your skill.** This applies mainly to capability uplift skills. If the base model starts passing your evals _without_ the skill loaded, that's a signal the skill's techniques may have been incorporated into the model's default behavior. The skill isn't broken; it's just no longer necessary.
>
> We've also added a **benchmark mode** that runs a standardized assessment using your evals. This is something you can run after model updates or as you iterate on the skill itself. It tracks eval pass rate, elapsed time, and token usage.
>
> *Benchmark mode tracking pass rate, time, and token usage*
> ![[skillcreator-benchmark-mode.png]]
>
> Your evals and results stay with you. Store them locally, integrate them with a dashboard, or plug them into a CI system.
>
> ## Faster, more consistent evaluation with multi-agent support
>
> Running evals sequentially can be slow, and accumulating context can bleed between test runs. Skill-creator now spins up independent agents to run evals in parallel with **multi-agent support** — each in a clean context with its own token and timing metrics. Faster results, no cross-contamination.
>
> We've also added **comparator agents** for A/B comparisons: two skill versions, or skill vs. no skill. They judge outputs without knowing which is which, so you can tell whether a change actually helped.
>
> *A/B comparison between skill versions using comparator agents*
> ![[skillcreator-ab-testing.png]]
>
> ## Getting skills to trigger at the right time
>
> Evals measure output quality, but that only matters if your skill triggers when it should. As your skill count grows, description precision becomes critical: too broad and you get false triggers, too narrow and it never fires. Skill-creator now helps you tune descriptions for more reliable triggering — it analyzes your current description against sample prompts and suggests edits that cut both false positives and false negatives.
>
> We ran it across our document-creation skills and saw improved triggering on 5 out of 6 public skills.
>
> *Description optimization results across public document-creation skills*
> ![[skillcreator-description-optimization.png]]
>
> ## Looking ahead
>
> As models improve, the line between "skill" and "specification" may blur. Today, a SKILL.md file is essentially an implementation plan, providing detailed instructions telling Claude _how_ to do something. Over time, a natural-language description of _what_ the skill should do may be enough, with the model figuring out the rest.
>
> The eval framework we're releasing today is a step in that direction. Evals already describe the "what." Eventually, that description may be the skill itself.
>
> ## Getting Started
>
> All skill-creator updates are available now on Claude.ai and Cowork. Ask Claude to use the skill-creator to get started.
>
> Claude Code users can install the [plugin](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/skill-creator) or download from our [repo](https://github.com/anthropics/skills/tree/main/skills/skill-creator).
>
> Source: https://claude.com/blog/improving-skill-creator-test-measure-and-refine-agent-skills
