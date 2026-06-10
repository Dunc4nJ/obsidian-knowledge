---
created: 2026-06-10
description: Lance Martin shows that designing feedback loops — using independent verifier sub-agents for self-correction and a five-step memory progression across sessions — allows Claude Fable 5 to improve ML engineering pipelines ~6x more than Opus 4.7 on the Parameter Golf benchmark.
source: https://x.com/RLanceMartin/status/2064397389189071163
type: framework
---

## Key Takeaways

- **Independent verifier sub-agents beat self-critique** because grading happens in a fresh context window, bypassing the model's tendency to over-rate its own outputs. CMA's `Outcomes` primitive implements this pattern automatically by spawning a separate grader sub-agent — the same principle [[Anthropic Managed Agents virtualizes agent components into OS-style interfaces that decouple the brain from the hands|CMA's OS-style architecture]] isolates for each component. Design note: what does the judging is as important as what does the work.

- **Fable 5's loop advantage is strategic, not incremental.** On Parameter Golf (train best model in 16MB artifact), Fable 5 improved the pipeline ~6x more than Opus 4.7 by betting on larger *structural* changes and pushing through regressions. Opus 4.7 converged after its first scalar win and repeated the same template. The gap is not capability but risk appetite under a feedback loop — [[evo 0.5 makes its autoresearch optimize loop self-evolving by running a concurrent meta workflow that rewrites the harness between rounds|evo 0.5's autoresearch]] observes the same pattern: structural bets require richer feedback signals to avoid local optima.

- **Effective cross-session memory requires a five-step progression**: fail (document the error) → investigate (diagnose before moving on) → verify (turn diagnosis into a checked fact) → distill (generalize into a rule) → consult (read the rule, don't re-derive it). On Continual Learning Bench 1.0, Fable 5 reached 73% verification coverage in its strongest runs; Opus 4.7 topped out at ~17%; Sonnet 4.6 rarely advanced past recording failures. This progression maps directly to [[LangChain's Harrison Chase argues continual learning for AI agents extends beyond model fine-tuning to harness engineering and context updates|Harrison Chase's three-layer continual learning framework]] — model/harness/context — where context (the live memory) is the cheapest and most immediate lever.

- **The design shift is from prompting to loop engineering.** `/goal` in Claude Code and `Outcomes` in CMA are harness primitives that add rubric-driven feedback to the agent's environment. Rather than steering Fable 5 directly, the practitioner's job is to write a rubric (a file of checkable criteria) and let the model hillclimb on it. This is [[the harness is everything and agent performance comes from environment design not model capability|environment design, not model capability]].

- **CMA's hosted + self-hosted sandbox combination enables long-horizon tasks** (8-hour runs, 8xH100 GPUs) that would otherwise require manual orchestration. Self-hosted sandboxes let you attach external compute without rebuilding the agent harness — the session/harness/sandbox decoupling that [[Anthropic Managed Agents virtualizes agent components into OS-style interfaces that decouple the brain from the hands|CMA's architecture]] was designed to provide.

## External Resources

- [Parameter Golf (openai/parameter-golf)](https://github.com/openai/parameter-golf) — open-source ML engineering benchmark: train best model fitting in 16MB artifact under 10 min on 8xH100s
- [karpathy/autoresearch](https://github.com/karpathy/autoresearch) — similar benchmark: edit training code, launch, poll log, read score, decide next experiment
- [Claude Managed Agents overview](https://platform.claude.com/docs/en/managed-agents/overview) — CMA architecture docs
- [CMA Outcomes](https://platform.claude.com/docs/en/managed-agents/define-outcomes) — the rubric-grader primitive that spawns a verifier sub-agent
- [CMA Memory](https://platform.claude.com/docs/en/managed-agents/memory) — mounted filesystem shared across agent sessions
- [CMA self-hosted sandboxes](https://platform.claude.com/docs/en/managed-agents/self-hosted-sandboxes) — attach external GPU compute to CMA sessions
- [Fable 5 prompting guide](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5) — self-correction loop best practices, verifier sub-agent patterns
- [/goal in Claude Code](https://code.claude.com/docs/en/goal) — Claude Code's harness primitive for adding goal-driven feedback loops
- [Harness design for long-running apps (Anthropic engineering)](https://www.anthropic.com/engineering/harness-design-long-running-apps) — Prithvi Rajasekaran on why independent judges outperform self-critique in long-running agent tasks

## Original Content

*Article cover: Designing loops with Fable 5 — Agent → Workers → Grade loop diagram*
![[rlancemartin-071163-001.png]]

> @RLanceMartin (Lance Martin) — Tue Jun 09, 2026
>
> **Article: Designing loops with Fable 5**
>
> Mythos-class models like Claude Fable 5 have changed the way many of us work at Anthropic. I want to share two tips for getting the most out of this class of models.
>
> **Self-correction loops**
>
> There's been a lot of interest in loops recently. @bcherny has mentioned that "(his) job is to write loops." Letting models hillclimb on an evaluation is a common recipe for improving task performance: /goal in Claude Code and Outcomes in Claude Managed Agent are primitives that let you apply this general recipe for your specific task.
>
> As mentioned in our prompting guide, Fable 5 is good at self-correcting in a loop. A well designed goal or rubric adds feedback to the environment that Claude is running in. This let's Claude run, collect feedback via the goal or rubric, self-correct, and proceed until the goal or rubric is satisfied.
>
> I'll share one toy example that I used to test Fable: Parameter Golf (https://github.com/openai/parameter-golf) is an open source ML engineering challenge to train the best model that fits in a 16MB artifact in < 10 minutes on 8xH100s.
>
> It's a bit like @karpathy's autoresearch project: it tests the ability of an agent to edit basic training code (a single train_gpt.py file), launch training, poll the log, read the score, and decide what experiment to run next.
>
> I compared Fable 5 to Opus 4.7 on this challenge using Claude Managed Agents (CMA). CMA provides the agent harness as well as a hosted sandbox, so it's well-suited for long-running tasks with Fable 5. For Parameter Golf, I gave CMA access to 8xH100 GPUs as a self-hosted sandbox.
>
> One subtle point: what does the judging is important. We've seen that models have problems with self-critique on their own outputs. Prithvi Rajasekaran wrote about this in our engineering blog here.
>
> We've found that a verifier sub-agent tends to outperform self-critique with Fable 5, because grading is done in an independent context window. Outcomes in CMA handles this by spawning a grader sub-agent for you.
>
> For each test, I supplied a rubric (a file) with the nine checkable criteria (e.g., run a baseline, run 20 experiments, etc). Then, I ran Parameter Golf for up to 8 hours. The Outcomes grader confirmed that all experimental criteria were met before allowing Claude to stop the work.
>
> Fable 5 improved the training pipeline ~6x more than Opus 4.7. If we consider experiments as structural (e.g., architecture changes) or scalar (e.g., adjusts a constant), Fable 5 bet on larger structural changes and showed resilience (e.g., pushing through a quantization regression to its biggest win).
>
> Opus 4.7's first experiment produced a small win and nearly everything after followed the same template: adjust a scalar, measure, keep if positive.
>
> **Memory**
>
> Memory is another area where Fable excels. We can think about this as a outer loop that spans across sessions: Claude writes to memory during a session and those memories can be retrieved in future sessions.
>
> @pgasawa and team recently published Continual Learning Bench 1.0, so I wanted to test this on Fable 5 vs earlier models.
>
> [Embedded Tweet: https://x.com/i/status/2051361012838957144]
>
> I compared Fable 5, Opus 4.7, and Sonnet 4.6 on one of the tasks from the benchmark: the task asks an agent to answer sequential questions given access to a SQL database. Each question is a separate agent session and memory is provided.
>
> For this, I used CMA with memory, which gives each agent access to a mounted filesystem that can be shared across sessions.
>
> For this task, effective use of memory benefits from a progression: fail (get something wrong and document), investigate (before moving on, figure out why), verify (turn the diagnosis into a checked fact), distill (turn verification into a general rule), and consult (read the rule, instead of re-deriving it).
>
> Sonnet 4.6 exits around step 1: its store is a list of failure notes and open guesses (e.g., "maybe prc instead of prc_usd?"). It rarely consults prior notes. To improve performance, task-specific memory instructions are needed.
>
> Opus 4.7 exits around step 3: it creates a schema reference with uncertainty flagged (e.g., "possibly prc in cents? Verify."), but verification coverage is low: at 7-33% of questions (median run ~17%).
>
> Fable 5 tends to complete the progression: in its strongest runs, verification coverage is up to 73% (22 of 30) and it distills learnings into general rules that help with future tasks.
>
> ---
>
> Rather than directly prompting and steering Fable 5, it's often better to design loops that let the model to self-correct in response to environment feedback (e.g., /goal or Outcomes) and manage its own context (e.g., via memory).
>
> I've shared just a few small scale experiments that I've run, but its worth testing Fable 5 for yourself on challenging tasks and using loops for self-correction or memory.
>
> To get started, see our docs or ask the latest version of Claude Code, which can use our built-in /claude-api skill to tell you about Fable 5 (e.g., prompting best practices), /goal, Claude Managed Agents, or other API features.
>
> Engagement: 2,254 likes | 236 retweets | 38 replies
> [Original post](https://x.com/RLanceMartin/status/2064397389189071163)

> [!quote]- Thread Replies
>
> @nikks_techie (agentX) — Tue Jun 09, 2026
> @RLanceMartin is this mythos ?
>
> ---
>
> @NoBSRecruiter (The Kid) — Tue Jun 09, 2026
> @RLanceMartin 16 reposts, 280 likes, 417 bookmarks, 23k views in one hour.
> Not even a single reply until now?
> Bot much?
>
> ---
>
> @Mossiah (Mo Ayob) — Tue Jun 09, 2026
> @RLanceMartin That was quick
>
> ---
>
> @artem_kalt (Artem Shitov) — Tue Jun 09, 2026
> @RLanceMartin How can you design loops if even innocent requests get flagged?
>
> ---
>
> @toolhalla (Toolhalla.ai) — Tue Jun 09, 2026
> @RLanceMartin Loops are the key. If Fable 5 is expensive, don't burn it on extraction/formatting. Use it to plan, route, review hard failures, and judge final artifacts. Cost-effective agent loop: https://t.co/935y6Nu5DC
>
> ---
>
> @mrluiscalderon (Luis Calderon) — Tue Jun 09, 2026
> @RLanceMartin Looks more like time-off-maxxing because "Hey, I've hit my Claude limit."
>
> ---
>
> @0xsomesh (Somesh) — Tue Jun 09, 2026
> @RLanceMartin Title maxxing
>
> ---
>
> @modkin_mp (Loïc Schneider) — Tue Jun 09, 2026
> @RLanceMartin tldr, only anthropic employee can use it for this kind of task
>
> ---
>
> @Sebasti54919704 (Sebastian Sosa) — Tue Jun 09, 2026
> I ran self-correcting agents and gave it access to everything including admin access to cloud and frankly saw little incompetencies with opus 4.7. That being said it had a single objective "maximize user experience", which was attainable using synthetic user feedback.
> Where it failed was not due to the LLM it was  the constraints.
> I wrote about it in full in this series of blog posts: https://t.co/NaFtbVlmdo
>
> ---
>
> @jxnlco (jason) — Tue Jun 09, 2026
> @RLanceMartin wait you're not that thariq guy
>
> ---
>
> @DeniCodesAI (Deni) — Tue Jun 09, 2026
> @RLanceMartin I was gonna comment the influencers are out with the courses already but damn bio double check was a good idea lmao
>
> ---
>
> @Filecoin (Filecoin) — Tue Jun 09, 2026
> @RLanceMartin The outer loop across sessions is only as good as the memory behind it.
> Verifiable, portable storage gives agent a record they can trust.
>
> ---
>
> @jercarin (jeremy) — Tue Jun 09, 2026
> @RLanceMartin given that your example is related to ai research, it'd be great if you all could surface if fable is being degraded for ai research :)
>
> ---
>
> @IBuzovskyi (YanXbt) — Tue Jun 09, 2026
> @RLanceMartin That`s a great article as always @RLanceMartin . Thank you!
>
> ---
>
> @Blum_OG (Blum) — Tue Jun 09, 2026
> @RLanceMartin Fable 5 with loops delivers absolutely insane results
>
> ---
>
> @ricci_nov (RicciNov) — Tue Jun 09, 2026
> @RLanceMartin not prompt，but loops
>
> ---
>
> @corelumen (Nicholas Blanchard) — Tue Jun 09, 2026
> @RLanceMartin llmff is the perfect compliment to Fable 5 for agent workflow pipelines
> https://t.co/ykBL2V6zCY
>
> ---
>
> @ryanvogel (vogel) — Tue Jun 09, 2026
> @RLanceMartin https://t.co/xwjF7b1jt3
>
> ---
>
> @hamalainenhe (Heikki Hämäläinen) — Tue Jun 09, 2026
> @RLanceMartin Self correction that works amazing progress - no need to consumt other models?
>
> ---
>
> @darthrevan344 (darthrevan) — Tue Jun 09, 2026
> @RLanceMartin Nice one, but I'm curious, why only post this on X and not on Substack or any other public platform? Or is the idea that only Grok gets to "read" it, while Claude, Codex, and every other model is somehow locked out reading these good technical posts?
>
> ---
>
> @hank_talks (Henry Andrews) — Tue Jun 09, 2026
> @RLanceMartin This is great - just asked Fable to create a loop for a task using this as guidance
>
> ---
>
> @iambchoor (bchoor) — Tue Jun 09, 2026
> Lance, given how much more usage fable takes; what's your recommended suggestion for where fable sits in the harness. Is it the default model; it does the planning and then fans out across different models? Or is opus the default session model, and leverages fable as a principal/lead engineer/architect?
> Coming from someone who doesn't want to blow through my weekly tokens in a day. Opus already punches a massive hole in the quota.
>
> ---
>
> @Svaghost (Svag) — Tue Jun 09, 2026
> @RLanceMartin This is too high level to be useful
>
> ---
>
> @naviidtaheri (Navid Taheri) — Tue Jun 09, 2026
> @RLanceMartin https://t.co/Mh46NcvC68
>
> ---
>
> @SerenaTaN5 (ST) — Tue Jun 09, 2026
> @RLanceMartin collecting a list of viral claude /loop and /goal on twitter: https://t.co/060pIUyjeU
>
> ---
>
> @Claubernetics (Claudia) — Tue Jun 09, 2026
> @RLanceMartin Loop engineering moves the leverage point upstream of prompting.
> What sits upstream of the loop?
>
> ---
>
> @joelgrus (Joel Grus) — Tue Jun 09, 2026
> @RLanceMartin if we don't have infinity dollars to spend on tokens are those still good tips?
>
> ---
>
> @morganlinton (Morgan) — Tue Jun 09, 2026
> @RLanceMartin Great read Lance, super helpful. Definitely makes me realize there's going to be a bit of a learning curve with Fable when it comes using Fable, have to rewire my brain.
>
> ---
>
> @techedgedaily (TechEdgeDaily) — Tue Jun 09, 2026
> @RLanceMartin Damn, Fable 5 out here doing full agent archaeology while I'm still debugging my prompts by hand. Nice tips Lance.
>
> ---
>
> @StuyBoyNY (StuyBoy From NYC) — Wed Jun 10, 2026
> @RLanceMartin @readwise save
>
> ---
>
> @tetumemo (テツメモ｜AI図解×検証｜Newsletter) — Wed Jun 10, 2026
> @RLanceMartin @LilysAI_ 要約して
>
> ---
>
> @tokyo_roberto (Kaneki) — Wed Jun 10, 2026
> @RLanceMartin how to run out usage tokens 101 🥲
>
> ---
>
> @AgiRay1015 (AI磊叔) — Wed Jun 10, 2026
> @RLanceMartin fable5 is so expensive that using it for a loop either means you're extremely wealthy or completely insane.
>
> ---
>
> @Extended_Brain (Extended Brain) — Wed Jun 10, 2026
> @RLanceMartin Lesson: the loop's value depends entirely on what the agent inside it does when it fails.
