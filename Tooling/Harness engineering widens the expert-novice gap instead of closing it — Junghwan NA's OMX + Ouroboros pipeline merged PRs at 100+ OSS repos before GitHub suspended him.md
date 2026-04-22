---
created: 2026-04-23
description: A 13-stage tmux + OMX + Ouroboros pipeline pushed 500+ commits across 100+ OSS repos in 72 hours, merging PRs at major projects before GitHub flagged velocity as spam — the harness amplified expert judgment rather than substituting for it, and revealed attestation (CLA, merge approvals) as the new scarce resource.
source: https://x.com/junghwanna8355/status/2046224197672984824
type: synthesis
---

## Key Takeaways

- **A harness amplifies whatever judgment you bring into it, so it widens the expert-novice gap rather than closing it.** The gap between "expert + harness" and "novice + harness" is wider than the gap between "novice + harness" and "no harness at all" — because merge decisions, cultural fit, and load-bearing judgment are exactly where an expert's context compounds and an agent's does not. This reframes the "AI levels the playing field" narrative and extends the [[agent harnesses are the product not the model]] thesis into a claim about operator skill: the harness concentrates the payoff on taste and domain context, not on generic prompt-wrangling.

- **The two gates that did 80% of the work were local reproduction (stage 5) and merge-pattern matching (stage 8), not draft quality.** Filtering to bugs that actually reproduce in a fork separates real contributions from "looks like a bug?" hypotheses, and imitating the shape of the repo's last 10 merged PRs beats reading CONTRIBUTING.md cover-to-cover because the social shape of an accepted PR is etched more clearly in merge history than in docs. The mechanics echo [[The Mismanaged Geniuses Hypothesis argues the next AI leap comes from training LMs to decompose not from scaling]] — the scaffold's value is in *where* it gates, not how capable the drafter is.

- **The OSS contribution supply curve has collapsed; what remains scarce is attestation.** Bug fixes, refactors, draft patches now scale to one-operator-one-weekend across entirely different codebases. CLA signatures, contributor agreements, license declarations, merge permissions, and review approvals look like bottlenecks but are actually the devices that make the rest of the system trustworthy — serious harness engineering wraps around these points with care rather than punching through them.

- **State must live outside the session or the pipeline is a conversation, not a pipeline.** OMX as execution substrate plus Ouroboros/MCP state management plus GitHub issues/PRs-in-fork as checkbox source-of-truth means any agent on any restart can read the issue and resume exactly where the last one stopped — identical in spirit to [[Claude Code's source reveals agent systems need infrastructure as a fourth layer beyond weights context and harness]]'s claim that infrastructure is the fourth agent-system layer beyond weights, context, and harness.

- **Platforms read velocity before shape, which is a policy signal regardless of individual PR quality.** A pipeline that is clever at 3 repos becomes abusive at 100 even when individual outputs are identical — the harness cleared the quality bar at the maintainer layer (PRs merged directly by major-project maintainers) but failed the velocity threshold at the abuse-detection layer, and that gap is a durable constraint on how fast an automation can land contributions at platform scale.

## External Resources

- [OMX (oh-my-codex)](https://github.com/Yeachan-Heo/oh-my-codex) — execution substrate that survives session compaction, restarts, and context churn; model routing delegated here
- [Ouroboros (Q00/ouroboros)](https://github.com/Q00/ouroboros) — MCP-based state management and interview-at-every-decision-point framework used as the stage gate
- [JunghwanNa8355 on X](https://x.com/JunghwanNa8355) — author's profile (tokscale.ai leaderboard: 22K+ commits / 60B+ tokens in 2026)

## Original Content

*Article header image — the account suspension notice and pipeline telemetry*
![[junghwanna8355-984824-001.jpg]]

> [!quote]- Source Material
> **Junghwan NA** (@JunghwanNa8355) · Article · 3:47 PM · Apr 20, 2026
> 7 replies · 20 reposts · 115 likes · 287 bookmarks · 45.5K views
>
> # How I got banned from GitHub due to my harness pipeline
>
> In 72 hours, I pushed 500+ commits across 100+ public open-source repositories.
>
> And GitHub suspended my account.
>
> I accept the outcome as a matter of course. I'm writing this down because the suspension itself, I think, is part of the result — and the pipeline that produced it is worth leaving a record of.
>
> ---
>
> ## What happened
>
> From April 16–18, I ran — end to end — a harness engineering pipeline I'd been designing for months.
>
> Output across 72 hours:
> - 100+ public repositories touched
> - 500+ commits written
> - 130+ PR branches pushed
> - PRs merged directly by maintainers of major projects
>
> Targets included google/adk-python, kubernetes/kubernetes, huggingface/transformers, ollama/ollama, vllm, awslabs/gluonts, dagster-io/dagster, roboflow/supervision, Nixtla/statsforecast, langfuse, Arize, spaCy, sktime, marimo, mlfoundations/open_clip, ray, zenml and so on.
>
> Some of them were reviewed and merged directly by the maintainers themselves.
>
> Then — poof — my account was gone.
>
> ---
>
> ## [How I pulled this off]
>
> A 13-stage pipeline running on tmux + OMX ([https://github.com/Yeachan-Heo/oh-my-codex](https://github.com/Yeachan-Heo/oh-my-codex), as a collaborator), with an Ouroboros interview ([https://github.com/Q00/ouroboros](https://github.com/Q00/ouroboros), as a maintainer) inserted at every decision point so the agent itself decided how to branch. My role was to set up an efficient harness environment and personally handle the gates where a human has to put their name on the line.
>
> The design choices that actually mattered:
> - **Execution substrate: OMX.** Not a workflow tool — a substrate that survives session compaction, restarts, and context churn. A pipeline that lives inside a single chat session isn't a pipeline; it's a conversation.
> - **State via MCP, independent of session compaction.** I used the state-management gate from Q00 / Ouroboros (I was a core member of that repo). Sessions compact, agents restart, context windows churn — the state doesn't care.
> - **GitHub issue/PR (in fork) as source of truth.** Each stage's progress lived as a checkbox on the issue body. Any agent, any session, any restart reads the issue and resumes exactly where the last one left off. (The same philosophy behind "collie" which I'll make it as a opensource later.)
> - **Model routing delegated to OMX.** I deliberately didn't optimize for per-call efficiency. Objective: finish end-to-end, not minimize per-stage spend.
> - **Token economics were not the constraint. Output was.**
>
> Every point where a human puts their name on the line — CLA signature, contributor agreement, license declaration, Issue/PR approval — I stepped through manually. No shortcuts on attestation.
>
> ---
>
> ## The 13 stages
>
> Agents handled 1–10 and 13. I handled 11 and 12.
>
> 1. From each repo's last 20 merged PRs and the last 5 release-tag diffs, extract only fix / security candidates.
> 2. Read recent merges + CONTRIBUTING; drop anything that conflicts with the project's direction.
> 3. Run an Q00/Ouroboros interview on each remaining candidate — the agent decides whether to branch.
> 4. Cross-check against open/resolved issues and PRs. Dedupe.
> 5. Reproduce locally in a fork. If it doesn't reproduce, drop it on the spot.
> 6. Re-examine anything load-bearing (intentional by project philosophy) and exclude.
> 7. Scope and appropriateness check against recent merge patterns.
> 8. Match the repo's last 10 merges to shape the writing.
> 9. Draft the issue/PR.
> 10. Few-shot polish using my own previously merged PRs.
> 11. Viability re-review. Human enters here.
> 12. CLA flow: automation runs to the checkbox screen. I click sign myself.
> 13. After bot/review feedback, decide follow-up: next PR, comment, or close.
>
> ---
>
> ## The two gates that did 80% of the work
>
> **Stage #5 — local reproduction.**
> If you ask why most AI-generated PRs are treated as noise, the answer is right there. They don't reproduce. "Looks like a bug?" is a hypothesis, not a bug report. When only candidates that actually survive a fork test are submitted, the merge rate goes up overwhelmingly.
>
> **Stage #8 — merge-pattern matching.**
> Reading the last 10 merged PRs was far more accurate than reading CONTRIBUTING cover to cover. The social shape of an accepted PR is etched more clearly in merge history than in docs.
>
> Everything else is scaffolding around these two.
>
> ---
>
> ## You don't need my stack. You need the method.
>
> The thing I want to get across: **the pipeline is the amplifier. The method is the substance.**
>
> You can run every one of the 13 stages manually — a browser, a terminal, a markdown file of interview questions instead of Ouroboros, your notes instead of MCP state. Same merge rate. Just slower.
>
> That's not a consolation prize. That's the point. The method itself is how you make an honest open-source contribution. The harness just lets you do it on 100 repos in a weekend instead of one.
>
> ---
>
> ## Why I got suspended — and what I think it means
>
> 100 repos in 72 hours is, regardless of the quality of any individual PR, hard to distinguish from spam at the abuse-detection layer. Speed itself is a semantic signal. Maintainers not flagging me didn't mean the platform allowed it — this run confirmed that.
>
> Even with good-faith intent, this was a risk I knowingly took on. Accepting the suspension as-is is, I think, the right reading.
>
> The genuinely interesting part is what the existence of this pipeline implies about maintenance labor.
>
> Bug fixes, refactors, draft patches scale now. One operator, one weekend, real problems surfaced across entirely different codebases. The supply curve is not what it used to be.
>
> The scarce resource that remains is **attestation** — CLA signatures, merge permissions, review approvals. These look like bottlenecks, but they're actually the devices that make the rest of the system trustworthy. Serious harness engineering doesn't punch through these points. It wraps around them with care.
>
> ---
>
> ## The uncomfortable part
>
> The harness automates the parts that don't need judgment. The human stays in the loop at every point that does. Both halves are necessary — neither half is decorative.
>
> Full automation of high-quality open-source contribution does not exist. Not because models can't draft — they can. Because merge decisions, cultural fit, load-bearing judgment, and attestation are exactly the places where an expert's context compounds and an agent's does not.
>
> A harness amplifies whatever judgment you bring into it. Which means the gap between expert with harness and novice with harness is wider than the gap between novice with harness and no harness at all. Humans move up toward design and direction. The harness handles the rest. That's the shape.
>
> ---
>
> ## Scale reveals platform policy
>
> A pipeline that was clever at 3 repos becomes abusive at 100 — even when the individual outputs are identical.
>
> Platforms react to speed, not average quality.
>
> One of the most surprising findings: the harness itself was more effective than the Mythos model Claude marketed. In 20–30%+ of repos, the output came back as "this commit, if posted publicly, is a severe security risk — please send it by email separately." Enough that I deliberately excluded them from the pipeline.
>
> ---
>
> ## Closing
>
> 500+ commits. 100+ repos. Most merged. Account suspended. These aren't separate outcomes — they're different faces of the same one.
>
> Maintainers of major projects merged my PRs, and the platform, being a platform, reacted to volume. I think that's honest.
>
> Harness engineering that actually runs produces outputs the system can't help but take a stance on. That's what it means for something to actually be getting made.
>
> If you're building something like this, DMs are open.
>
> ---
>
> ## Note on the 500-commit number
>
> One clarification, because the raw numbers invite a spam reading:
>
> Per repo, only 1–2 PRs were actually opened. The 500+ commits aren't 500+ distinct attempts. They're the trail left by review-driven iteration on ~130 PR branches:
> - Initial commits for the reproduction and the fix
> - Follow-up commits responding to bot feedback (linters, CI, sign-off bots, coverage checks)
> - Follow-up commits responding to maintainer review comments
> - Rebases and cleanup before merge
> - Post-merge follow-ups where needed
>
> In other words, the commit count is a reflection of the PR lifecycle running correctly — not of spraying half-baked patches at repos. Each repo got one or two carefully scoped PRs, each of which then went through the normal review-iterate-merge loop the way any serious contribution does.
>
> That distinction matters: "100 repos × 1–2 PRs each, iterated to completion" is a very different shape from "100 repos × 5 drive-by PRs each." The first is contribution at scale. The second is spam. The pipeline was explicitly designed to produce the first and refuse the second — and the commit distribution reflects that.
>
> The platform's abuse layer, of course, reads velocity before it reads shape. Which is exactly the lesson from the suspension.
>
> [Original post](https://x.com/junghwanna8355/status/2046224197672984824)
