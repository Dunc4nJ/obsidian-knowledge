---
created: 2026-09-08
description: Hunter Leath (Archil) argues that human line-by-line PR review was always a weak bug filter -- at Amazon, PRs with hundreds of comments shipped bugs at the same rate as unreviewed ones -- and that the only way to survive agent-accelerated code volume is to replace reading diffs with automatically-collected per-PR evidence artifacts (perf evals, e2e attestations, deterministic simulation runs, design screencaps) plus deployment machinery safe enough to roll out unreviewed code without harming customers.
source: https://x.com/jhleath/status/2074145621435625788
type: framework
---

## Key Takeaways

- **The load-bearing claim is empirical, not futurist: at Amazon, Leath watched heavily-reviewed and barely-reviewed code ship bugs at indistinguishable rates.** "I would also watch people spend weeks looking at a PR. Leave hundreds of comments, and finally mark it as 'safe'. Guess what happened to that code? The same thing." If review effort does not correlate with defect escape, then review is not primarily a correctness mechanism, and the agent-volume argument only makes an already-poor filter untenable. Note this is one engineer's recollection at one company, offered without measurement -- the vault's own [[AI generated code repos gain credibility by shipping verification artifacts not hiding authorship|verification-artifacts note]] reaches the same prescription from the credibility side rather than the defect-rate side.

- **The reframe is a single question, and it is the reusable part of the essay:** assume looking at the code doesn't matter -- *for any given PR, what artifacts would you need to see in order to convince yourself that the code worked correctly?* Leath's own list is a performance evaluation, a screenshot or Loom of the new design, an attestation that integration and e2e tests passed, "a deep, deterministic simulation test that shows that the code works across hundreds of thousands of faults in the underlying system", or someone promising they clicked through the flow. The engineering task then shifts from reviewing to *automating the collection of those artifacts*, which is infrastructure work with a clear finish line — and is exactly what [[Offload parallelizes agent CI test suites across Modal sandboxes removing the integration testing bottleneck|Offload]] and [[sandboxed CI is the missing infrastructure for agent evals at scale|sandboxed CI]] make affordable at agent-generated PR volume.

- **The deterministic-simulation bullet is doing more work than its one line suggests.** "Hundreds of thousands of faults in the underlying system" is the FoundationDB/TigerBeetle class of testing, and it is the only item on Leath's list that produces evidence strong enough to substitute for reading a diff in mission-critical infrastructure — which is the case he explicitly scopes himself to (no downtime, no perf regressions, no correctness problems). The others are attestations of coverage, not proofs of behaviour, and the same stratification shows up in agent evaluation: [[anthropic recommends combining deterministic graders model judges and human review for agent evals|Anthropic's grader hierarchy]] puts deterministic checks above model judges for exactly this reason, and [[a working offline eval turns vibes into repeatable measurement in 10 steps|turning vibes into repeatable measurement]] is the same discipline applied to a different artifact. [[Chris Leary frames AI-written kernels as compilers 2.0 - the LLM is a stochastic optimizer in STOKE's seat, and semantic-equivalence checking is what makes not reading the kernel safe|Chris Leary makes the strong-form version of this argument for kernels]]: it is the *verifier*, not the artifact count, that makes not reading the code safe.

- **The second half is the more actionable half, and it moves the safety budget from review time to deploy time.** Leath's Amazon heuristic -- "it was a better use of time to make deployments safer and slower than it was to spend more time doing PRs" -- comes with a concrete bar: in some components, a change that caused data corruption could be rolled to production with zero customer impact. The five diagnostic questions (auto-stop or rollback on rising 500s; percentage rollouts; deployments that watch CPU/RAM and halt on anomaly; feature-flag gating; canaries continuously running customer workloads) are each phrased as "Do you? Should you?", which makes them usable directly as a team audit. This is the pre-condition [[every deploy should trigger a monitor-triage-fix loop that dispatches a coding agent to fix regressions before users notice|the monitor-triage-fix loop]] assumes, and it needs [[agent production monitoring requires observing inputs and outputs not just system metrics|input/output-level monitoring]] rather than host metrics alone to catch semantic regressions.

- **"Merging code without reviewing it isn't going to be too dangerous for everybody. But, if it's too dangerous for you, you're going to fall behind" is the essay's actual thesis** -- danger tolerance is a property of your deployment system, not of your discipline, so the competitive response is to invest in the system rather than to review harder. That is the same conclusion [[intelligent AI delegation requires trust accountability and adaptive monitoring not just task decomposition|the delegation literature]] reaches from the trust side: what you can safely hand off is bounded by the monitoring and reversal machinery behind it, not by how carefully you inspect the handoff. It is also the practitioner-side counterpart to [[AI infra has collapsed into five identical products and Archil's Hunter Leath argues the winner will be a different shape entirely|Leath's complaint about the infra market]] -- the same author, three days later, arguing that the observability and governance products everyone is selling are the ones buyers actually need to build into their own deploy path. The framing device (the same sentence closing 2023, 2024, 2025, 2026 -- unit tests, Copilot tab-complete, Cursor chat, Claude Code Max plus Fable) is rhetoric, and the "by the next World Cup" timeline is unfalsifiable, but the structural argument survives without them. Compare [[coding agents are bottlenecked by search not coding ability]]: both locate the 2026 bottleneck downstream of generation, in the surrounding system rather than in the model.

- **The strongest objection is in the replies and Leath does not address it.** Tip ten Brink: "code is about more than correctness. It's also about not changing the codebase for the worse so that future changes don't take ever more effort. I agree PRs never solved correctness, but I do think (hope) they made a dent in keeping things maintainable." No artifact on Leath's list measures architectural erosion, and none plausibly could -- which means the artifact regime is a substitute for the correctness function of review and a *silent removal* of its design-review function. Automated review agents are the partial answer here, but [[Factory droid-code-review reveals how prompt-driven agents map LLM outputs to GitHub-native review primitives through position-based inline commenting and stateful deduplication|Factory's droid-code-review]] shows the current state of the art is inline comment generation, not maintainability judgement.

## External Resources

- [Archil](https://archil.com) — Leath's company; the "mission-critical infrastructure for your customers" he scopes the argument to. See [[Bash is the SQL for file systems and Archil proves it with serverless execution that sends instructions not data]] and [[Amazon S3 Files ends the object-file split for AI agents]] for what that infrastructure is.
- [@nk_developer1](https://x.com/nk_developer1/status/2074153981408903462) — reply reporting that code review was "the last blocker" for an NVIDIA team, and that testing artifacts plus CI/CD are the path to a lighter review process
- [@tiptenbrink](https://x.com/tiptenbrink/status/2074169047873122685) — the maintainability counterargument

## Original Content

> [!quote]- Full article: "The slowest you'll ever move" — Hunter Leath (@jhleath), 6 Jul 2026
> Hunter Leath (@jhleath) — Mon Jul 06, 2026
> Article: The slowest you'll ever move
> 18 likes | 0 retweets | 2 replies | 7 bookmarks | 1 quote | 1,637 views
> [Original on X](https://x.com/jhleath/status/2074145621435625788)
>
> It's 2023. You're sitting at your computer at your Big Tech job writing unit tests. You hate writing unit tests. You don't know it yet, but this is the slowest that you'll ever move while programming.
>
> It's 2024. Your company got access to Github Copilot -- nifty. Now, you can tab-complete entire functions if you write the comments in just the right way. Will this ever replace you, a thinker? No, but it's great for boilerplate. You don't know it yet, but this is the slowest that you'll ever move while programming.
>
> It's 2025. You now have access to a cool new IDE called Cursor. Rather than tab-completing the code into completion, there's a chat box on the right. You can have a conversation about what you want to do. Now, entire modules, entire unit test suites, and small pieces of functionality just magically appear done. Still not good for critical stuff, but that's okay, lots of your job isn't critical stuff. You don't know it yet, but this is the slowest that you'll ever move while programming.
>
> It's 2026. You have a Claude Code Max plan, and [finally] access to Fable for your job. Nothing stands in your way, you can plow through entire products over the weekend. Except... your coworkers have a bunch of slop PRs that they want you to review. Ugh. You hate reviewing code, so you put it off until your boss tells you that you REALLY need to get Bill's functionality merged. Fine, you look through it. You don't know it yet, but this is the slowest that you'll ever move while programming.
>
> Depending on how close to San Francisco you are, the future is either already here or very close at hand. By the next World Cup, software development will look very different than it does today.
>
> Moving slower than you do today -- taking the time to hand-craft your code, pouring through PRs line-by-line -- will only spell death for you and your company. Because, if you don't move faster, your competitors will figure out how to.
>
> So, let's take that for granted. In 2027, you're going to need to move faster than you do today.
>
> You aren't going to be able to write code by hand because it's too slow. You aren't going to be able to write PRs because there's going to be too many.
>
> You need to reframe this problem in your head.
>
> Merging code without reviewing it isn't going to be too dangerous for everybody. But, if it's too dangerous for you, you're going to fall behind.
>
> This begs an obvious question: if you, like me, work on mission-critical infrastructure for your customers, you can't accept downtime, you can't accept performance regressions, and you definitely cannot accept correctness problems. How do you make it safe to move faster and reduce the review burden?
>
> ---
>
> It's no secret on my team that I've always hated PRs. Even before AI. At Amazon, I would watch people ship code without looking closely -- get it to production -- and see that it had bugs. When we found those bugs, we would fix them and try again.
>
> But, guess what? I would also watch people spend weeks looking at a PR. Leave hundreds of comments, and finally mark it as "safe". Guess what happened to that code?
>
> The same thing. We would deploy it to production, it would have bugs, and we would ship them.
>
> So, what were the code reviewers really doing? Was it actually worthwhile for them to spend hundreds of hours with a piece of code, only to miss bugs in it anyway?
>
> They are, after all, only human.
>
> ---
>
> Over the past 6 months, I've started to reframe PR acceptance through a different lens.
>
> Let's assume for a moment that looking at the actual code doesn't matter (I know that many people have strong opinions here, but let's just accept this and pull the thread for a moment).
>
> If that's the case, then [for any given PR], what artifacts would you need to see in order to convince yourself that the code worked correctly?
>
> Is it:
>
> - A performance evaluation
>
> - A screenshot/loom of the new design
>
> - Some kind of attestation that integration tests / e2e tests worked
>
> - A deep, deterministic simulation test that shows that the code works across hundreds of thousands of faults in the underlying system?
>
> - Someone promising that they clicked through the flow and got all the right states?
>
> Rather than spending time looking through the code (since you'll probably miss bugs anyway), you should spend time figuring out how to automate collecting these artifacts.
>
> Then, the next time that you get a slop-PR from a colleague that comes with these artifacts, you can probably start to merge some of them without needing to pour through every line of code.
>
> ---
>
> "But Hunter," I hear you shouting from the locked basement door. "What if we ship something that does have a bug?"
>
> Well, what do you do if you have a bug today?
>
> I think the other very overlooked part of the software lifecycle is the deployment process. At Amazon, I used to say that it was a better use of time to make deployments safer and slower than it was to spend more time doing PRs.
>
> We did such a good job on this, that if you introduced changes which resulted in data corruption (in some components), you could safely roll those to production without any customers being impacted.
>
> What does that look like for your system?
>
> Do you automatically stop or roll back deployments if the number of 500 errors increases? Should you?
>
> Do you have the ability to roll out changes to a small percentage of customers before they hit all customers? Should you?
>
> Do you have deployments that  continuously assess monitor state (CPU, RAM, w/e) and stop or rollback if they show an anomoly? Should you?
>
> Are you building new features gated behind feature flags that you can slowly roll out to your customer base? Should you?
>
> Do you have canaries on your system which continuously attempt customer workloads in order to assess whether or not the system is healthy? Should you?
>
> ---
>
> In truth, you're going to need a combination of things to make it through the next few years.
>
> Everyone knows that you're going to need more, stronger tests.
>
> But, are you making the moves today to automatically gather artifacts on each PR that would more convince you that the code was correct without looking at it?
>
> Are your deployments becoming safer, so that you can safely roll out bad code [that you didn't look at], without causing harm to your customers?
>
> After all, you might not know it yet, but this is the slowest that you'll ever move while programming.

### Notable replies

> **@nk_developer1 (Nikhil Kanamarla)** — [Jul 6, 2026](https://x.com/nk_developer1/status/2074153981408903462)
>
> Nice article, the code review process was the last blocker for my old Nvidia team. Focusing on ensuring testing artifacts are available when putting up the PR and having a good CI/CD pipeline seems like a good step forward. Therefore the review process can become lighter?

> **@tiptenbrink (Tip ten Brink)** — [Jul 6, 2026](https://x.com/tiptenbrink/status/2074169047873122685)
>
> I feel this misses that code is about more than correctness. It's also about not changing the codebase for the worse so that future changes don't take ever more effort. I agree PRs never solved correctness, but I do think (hope) they made a dent in keeping things maintainable.
