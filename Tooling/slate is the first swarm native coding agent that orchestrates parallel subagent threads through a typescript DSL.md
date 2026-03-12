---
created: 2026-03-12
description: RandomLabs releases Slate, a coding agent that uses a TypeScript DSL to orchestrate parallel subagent threads with shared context, achieving long-horizon stability and episodic memory through novel context compression.
source: https://x.com/realmcore_/status/2032146316730778004
type: learning
---

## Key Takeaways

Slate introduces "threads" as a primitive for parallel subagent work — unlike message-passing architectures, threads share context with the main orchestration thread, creating what the authors call a "hive mind" rather than isolated workers. This directly contrasts with the findings in [[planner-worker hierarchies outperform flat coordination for scaling multi-agent coding]], where Cursor found that flat coordination failed at scale. Slate claims to solve the coordination problem not through hierarchy but through shared context compression.

The core insight borrows from RLM (by @a1zhang and @lateinteraction): using a REPL's reference semantics lets the agent decompose work into storable operations, freeing the model to think about the execution graph rather than performing individual operations. Slate extends this to coding by adding stability over long-horizon tasks and handling mutated/changing environments — the two properties RLM lacked. This resonates with [[2 to 5 worker agents per lead is the sweet spot for multi agent orchestration]], where the bottleneck is coordination overhead, not raw capability.

The concept of "knowledge overhang" — the gap between what a model knows how to do and what it actually uses during task execution — is a useful framing. By separating strategic thinking (via TypeScript DSL) from tactical execution (via threads), Slate claims to access this latent knowledge directly. This maps to [[codex custom multi-agent roles unlock repeatable subagent specialization]] where role specialization unlocks capabilities the base model already has.

Slate automatically selects the right model per task (Sonnet for reasoning, Codex for coding, GLM for search), which addresses the multi-model routing problem. The architecture maximizes caching through subthread reuse and uses rolling context compression for sessions lasting up to 2 days.

## External Resources

- [RandomLabs Blog — Slate Technical Report](https://randomlabs.ai/blog/slate) — full technical details on threads, knowledge overhang, and expressivity
- [RLM](https://x.com/a1zhang) — the REPL-based agent framework that inspired Slate's decomposition approach
- [OpenCode](https://github.com/opencode-ai/opencode) — client-server architecture that Slate builds on
- [@michael_chomsky testing screenshot](https://x.com/michael_chomsky/status/2029755120263778347) — early user testing results

## Original Content

> @realmcore_ (akira) — 2026-03-12
>
> Article: We built RLM for coding. And it F*cking rocks. Swarm native agents are here to stay.
>
> Today we are releasing slate.
>
> Slate is the *first* frontier agent in the wild to directly use a code environment for swarm orchestration.
>
> Slate can programmatically orchestrate and solve tasks, running a *massive* amount of what we call threads (subagents).
>
> At @0xrandomlabs, our goal is to identify general mechanisms that can be used for general agents.
>
> The version of Slate we are releasing today is a strong step towards it. (Our technical report is on our blog at randomlabs.ai/blog/slate )
>
> With slate, you can have Sonnet, Opus, GPT 5.4 etc. orchestrate Codex 5.3, GLM 5, sonnet, haiku, etc.
>
> Slate automatically selects the right model for the job. Meaning you're spending as little as you need for completeness while getting the advantages of each model. GLM for example is one of our favorites, and is incredible for agentic search.
>
> Have you ever felt like you wanted to talk with claude but code with codex? Yeah, us too. Slate just does it. No overhead. No weird integration stuff. No wacky skills.
>
> Slate is swarm native. The only agent of its kind that functions like this. It's not a system that uses message passing between subagents. It's more of a hive mind and can synchronize many many parallel threads.
>
> It might *sound* expensive, but due to some novel context engineering, it's actually not that expensive. Architecturally it also maximizes caching.
>
> Pssssst also next week we plan to launch a direct support for Codex @OpenAI @thsottiaux and Claude Code
>
> To get started, go to randomlabs.ai
>
> Screenshot from @michaelchomsky testing it for us early: https://x.com/michael_chomsky/status/2029755120263778347
>
> *Testing screenshot from early user*
> ![[realmcore-778004-001.jpg]]
>
> ## Now, what did we mean by "RLM for coding"?
>
> RLM was built by @a1zhang and @lateinteraction (Huge shoutout! These guys have been in the game forever)
>
> Well basically, RLM functions on two principles. The first is that the reference semantics of a REPL allow the agent to decompose the work into operations that store values *in* the references. The second is that the agent is able to orchestrate operations at a higher level through the python repl it has access to. In other words, it knows the operations it needs to perform and can actually think about the execution graph that it is executing INSTEAD of performing the operations.
>
> Overall the semantics around task decomposition are sound.
>
> Use a REPL to decompose the task into a known set of operations allowing the model to think strategically about the task and not be overwhelmed by context. The models right now have a hard time tracking more complex variables across execution steps, but they will eventually get there.
>
> A very very old precursor to this was the CodeAct paper by @gneubig and team, alongside the voyager paper by @DrJimFan and team
>
> We hilariously came to the same conclusions independent of the RLM team, but nonetheless all three of these teams touched on the core ideas implicitly .
>
> We define two new terms for understanding agents as well:
>
> - Knowledge overhang, the knowledge of how to do tasks that the model doesn't actually use while performing tasks
>
> - Expressivity, the interplay between how expressive an interface is and the model's bias to use that expressiveness
>
> We explore both of these in our technical report that you can find on our blog at randomlabs.ai/blog/slate
>
> Despite having slate internally, I (the author) mistakenly thought RLM wasn't actually similar and intentionally didn't take inspiration. And yet we came to the same conclusions which suggests that the primitives are actually important.
>
> The core difference is that Slate is 1) stable over long horizon implementation tasks, and 2) can handle a mutated/changing environment. This allows it to actually parallelize work that matters to the people we are building for:
>
> Software engineers and engineering teams
>
> One of the best things about how slate works is that it accesses the knowledge the model has about strategy directly and separately from accessing the model's tactical knowledge.
>
> Because it orchestrates the swarm using a typescript DSL, Slate is able to actually think and "program in action space". (Again, we call this knowledge overhang, you can read about it in our technical report)
>
> We do this by introducing a concept called threads.
>
> ## What is a thread?
>
> The general idea of a thread is that rather than isolating subagent context, we genuinely want to share it with the main orchestration thread.
>
> Notably there are a few teams that have come across something similar to the benefits of threads. @cognition, @fundamental, and @ManusAI all operate on the same principles of think at a high level and delegate at a lower level, compressing the lower level context to something that is understandable by the agent doing the strategizing.
>
> We explore the tradeoffs each of these teams makes in our technical report on our blog.
>
> Due to the nature of our threading engine, we are able to maximize caching through subthread reuse.
>
> These subthreads represent work streams that can be added to and composed to form more complex working behaviors.
>
> Because we delegate simple tactical actions to threads, one at a time, it gives us an almost perfect boundary over which we can compress the context. This in turn has led us to an *actually* tractable way to create episodic memory.
>
> Slate has episodic memory that actually makes sense. The system retains only the tool calls that contribute to its success. We also maintain the same rolling compression system from slate V0 that let it run single sessions for as long as 2 days as reported by our customers.
>
> One funny coincidence is that Slate's thread architecture maps directly to @karpathy's LLM OS where each thread has its own "ram" and the main thread can delegate to other threads directly. This work provides a clear primitive for scaling. Conceptually inspired by the BEAM vm, we originally called threads "actors", but found that the model understands threads better.
>
> ![[realmcore-778004-002.jpg]]
>
> Slate currently borrows heavily from @opencode in its application architecture, and would not have been possible in its current form if not for the @opencode team (Shoutout @thdxr especially for being the goat!). Our client server architecture is directly based on the opencode architecture which will enable many *many* cool applications in the future.
>
> It's a miracle that this works at all, but we believe we've solved some of the core limitations of agents.
>
> Now that the compaction and orchestration problems are solved, the next challenge to tackle is long term memory.
>
> ![[realmcore-778004-003.jpg]]
>
> A long list of thank yous to the following people for inspiring our work and showing us what was possible:
>
> @a1zhang and @lateinteraction (Creators of RLM)
> @GeoffreyHuntley (Creator of Ralph, currently working on Latent Patterns)
> Andrej Karpathy @karpathy
> Nico Christie @nicochristie and the whole team @Fundamental (Formerly Altera) - Probably the most inspiring work in agents I've ever seen
> Swyx @swyx - For covering basically the entire space from inception, definitely would've missed something if not for @latentspacepod
> Walden Yan @walden_yan @Cognition - Creators of the space and a team genuinely skilled at context engineering
> Dax @thdxr and team @opencode - The best to ever do it (at least regarding how they approach product)
> Dex Horthy @dexhorthy @HumanLayer - CEO of one of the most forward thinking teams in the space
> Lance Martin @RLanceMartin - Insightful thinking, specifically covered how manus does context engineering
> Jesse Michael Han @MorphLabs - A visionary in the space, creator of gauss
> Kelly Hong, Anton Troynikov @atroyn and Jeff Huber @jeffreyhuber from @Chroma for 1) being day ones and 2) their influential work on context rot
> @spikedoanz for reviewing our work
> @arb8020 for reviewing our work and important conversations about agent functionality
> Rohan Pandey @khoomeik for being one of the best thought partners over the course of our work
> Surya @sdand
> @tokenbender for reviewing the work
>
> ![[realmcore-778004-004.jpg]]
>
> Here's a fun anecdote from our testing. A *less flexible* version of our current architecture previously was able to pass 2/3 tests on the `make-mips-interpreter` task on Terminal Bench 2.0. This is a task that Opus 4.5 and Opus 4.6 solve 1/5 times or less (only solved in a few harnesses).
>
> Again, we really do not believe in benchmaxxing, but we will be producing benchmark scores at some point in the coming weeks. We are currently hiring for a role to help us with this on the research side.
>
> ![[realmcore-778004-005.png]]
>
> ![[realmcore-778004-006.jpg]]
>
> Engagement: 900 likes | 75 retweets | 26 replies
> [Original post](https://x.com/realmcore_/status/2032146316730778004)
