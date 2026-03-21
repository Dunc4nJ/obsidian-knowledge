---
created: 2026-03-21
description: Vasilije from Cognee argues that continual learning, context engineering, and multi-agent coordination are all memory design problems in disguise, and that memory is the layer where agent systems build durable competitive moats.
source: https://x.com/tricalt/status/2035050668797407656
type: framework
---

## Key Takeaways

The core reframe here is powerful: what the industry calls "continual learning," "context engineering," and "multi-agent orchestration" are all the same underlying problem — memory design. This echoes the vault's existing insight that [[four memory layers serve different knowledge types]], but pushes further by arguing that memory isn't just a subsystem, it's the primary bottleneck. The "Agent = Model + Harness" framing from [[the harness is everything and agent performance comes from environment design not model capability]] gets extended here — the harness itself is increasingly *about* memory.

The section on context engineering as a memory problem is the sharpest insight. Bigger context windows don't solve the problem, they just move it — the system still needs to decide what to keep, compress, and forget. This connects directly to [[autonomous context compression lets agents choose when to compact rather than hitting fixed token limits]] and [[indexed experience memory compresses LLM agent context without discarding evidence by pairing summaries with a dereferenceable archive]]. The Cognee team is essentially saying: compaction without a memory model is just lossy compression with no learning signal.

The multi-agent section maps cleanly onto [[multi-agent memory needs computer architecture style hierarchy and consistency models]] — multiple agents produce partial, contradictory views that need merging, not just dumping into shared state. The difference between "shared space" and "shared brain" is exactly the consistency model argument from that paper.

The essay is also a positioning piece for [[cognee-knowledge-engine-for-ai-agent-memory|Cognee]] — they're claiming the memory layer as the durable moat. Whether that's true depends on whether memory can be commoditized the way models are being commoditized. The [[Semantica and Cognee solve agent memory differently - Semantica adds accountability while Cognee builds the knowledge engine]] comparison is relevant context: Cognee focuses on the knowledge engine side (ingest → graph → search), which is exactly the "structured, updated, reused" layer this essay describes.

The "memory consolidation" framing — deciding what survives from raw experience — is underexplored in the vault. It's distinct from retrieval (finding what you stored) and closer to what biological memory systems do during sleep. This is the gap between accumulation and learning that makes [[progressive disclosure filters force agent selectivity over what enters context]] necessary in the first place.

## External Resources

- [Cognee](https://www.cognee.ai/) — Knowledge engine for AI agent memory, the product behind this essay's perspective
- [@Vtrivedy10's harness framework](https://x.com/Vtrivedy10) — Originator of the "Agent = Model + Harness" formulation referenced in the essay

## Original Content

> @tricalt (Vasilije) — 2026-03-20
>
> Article: Memory as a Harness: Turning Execution Into Learning
>
> "The missing layer that makes agents actually improve over time."
>
> Earlier this month the industry woke up: models can give us intelligence, but they cannot give us the system around that intelligence to turn it into actual work engines that deliver value. That led to coming up with a new term called "Harness Engineering". (yes, one more term for the history😀)
>
> There were many nice definitions floating around, but the cleanest one got introduced by @Vtrivedy10 :
>
> Agent = Model + Harness
>
> The model provides the intelligence, and the harness is everything else. At @cognee_ , we live in the memory part of that harness, and we wanted to share what we see in the market.
>
> Most of the attention around memory has gone into personalization,  which was a natural place to start. But that framing is too narrow for where agent systems are going.
>
> Many of the biggest bottlenecks in these systems can actually be re-interpreted as memory problems, and in this post I will walk through that logic.
>
> ---
>
> ## Continual Learning
>
> Although this term existed long before agentic AI, we still use it when referring to systems that should become better over time. To avoid confusion, it is easier to think about it as self-improvement.
>
> When people hear this, they usually think about heavy research topics: RL, post-training, etc. But in agentic systems, a big part of this problem shows up somewhere else.
>
> Not in the model. In the memory layer.
>
> If you keep storing the interactions your agent has, over time you build a record of:
>
> - failures
>
> - feedback
>
> - patterns in how users behave
>
> But storing interactions is not the same as learning. It only means the experience exists. The real question is what you do with it.
>
> How do you take all of that history and turn it into something the system can actually use?
>
> This is where the problem becomes interesting. It is not just about storing more data. It is about:
>
> - deciding what matters
>
> - deciding what to keep
>
> - deciding how to merge new information with what the system already knows
>
> Because if you just keep everything, you don't get improvement →  you get noise.
>
> So what we call "continual learning" in agentic systems often becomes a memory design problem.
>
> Not:
>
> - how do we update the model
>
> But:
>
> - how does experience get captured, consolidated, and reused
>
> A simple way to think about it, and how most systems initially approached memory, is to split it into layers: what's happening now, and what gets stored over time. That works as a starting point.
>
> You store interactions while the agent is running, and then move the useful parts into something more persistent.
>
> But this is also where things start to break.
>
> Because the real problem is not where you store information. It is what you decide to keep, and how you merge it with what the system already knows.
>
> If you just keep moving things from one layer to another, you don't get improvement, you get accumulation.
>
> And over time, that turns into noise:
>
> - duplicated knowledge
>
> - conflicting signals
>
> - outdated assumptions
>
> So the challenge is not splitting memory into layers. It is deciding what becomes part of the system's knowledge, and how that knowledge evolves.
>
> That's where continual learning, in practice, becomes a memory problem.
>
> At @cognee_, this is the layer we have been focusing pm, making memory not just something you write to, but something that is actively part of the execution loop.
>
> The interface (e.g. .memify()) is just one way of exposing it.
>
> The harder part is everything behind it:
> how knowledge is structured, updated, and reused.
>
> ---
>
> ## Context Engineering
>
> There is this idea that keeps coming back:
>
> "If context windows get large enough, we won't need memory."
>
> But in practice, that's not what we are seeing.
>
> Models still hallucinate. They still don't know what to keep. And bills are still increasing.
>
> Bigger context windows don't solve the problem… they just move it.
>
> In fact, they introduce new issues:
>
> - context poisoning
>
> - context confusion
>
> - context distraction
>
> The context window starts filling up with things that don't really matter, and over time the model begins to repeat patterns instead of actually reasoning. So instead of improving, the system reinforces its own mistakes.
>
> At first glance, this looks like a context problem.
>
> But if you look closer, it's really a memory problem.
>
> Because the system is still missing the ability to decide:
>
> - what should be kept
>
> - what should be compressed
>
> - what should be forgotten
>
> - what should be stored for later
>
> You could argue that this can be solved with compaction:  just summarize the context with an LLM.
>
> But then you run into the same question again: how do you know what to keep?
>
> To answer that, you need:
>
> - an understanding of your system (data, processes, structure)
>
> - awareness of past interactions
>
> - some notion of what actually matters
>
> That  is not something a single LLM call can reliably solve. So in practice, what you end up needing is:
>
> - a way to structure your existing knowledge
>
> - a way to track interactions over time
>
> - a way to decide what should remain immediately available (short-term memory) and what should be stored for reuse (long-term memory)
>
> - a way to compress without losing what matters
>
> All of which sit in the memory layer.
>
> A simple way to think about it: If you knew all future interactions in advance, you would know exactly what to keep and how to summarize.
>
> But you don't. So the system has to learn that over time.
>
> And that is where context engineering starts to overlap with memory design.
>
> ---
>
> ## Multi-Agent setup
>
> Now imagine the same problem, but with multiple agents. Each sub-agent works on a different part of the task, sees different data, and produces different traces:
>
> - outputs
>
> - failures
>
> - intermediate steps
>
> - assumptions
>
> The problem is not generating those traces. The problem is what you do with them.
>
> Some of that information only matters while the agent is still working. Some of it needs to be shared so other agents don't repeat the same work. And only a small part of it should actually become something the system remembers. This is where things get tricky.
>
> Because once you have multiple agents, you no longer have a single stream of experience. You have multiple partial views of the same problem.
>
> Agents might:
>
> - contradict each other
>
> - repeat the same findings
>
> - or produce results at different levels of quality
>
> So the problem becomes: how do you merge all of that without amplifying noise?
>
> Again, this looks like an orchestration problem at first. But it's really a memory problem.
>
> Not:
>
> - how do I store all outputs
>
> But:
>
> - what should survive, and in what form
>
> If you just dump everything into a shared space, you don't get a "shared brain", you get a mess.
>
> What you actually need is a way to:
>
> - filter
>
> - merge
>
> - resolve conflicts
>
> - and decide what becomes part of the system's knowledge
>
> Once that works, something interesting happens.
>
> Agents stop behaving like isolated workers and start contributing to a system that accumulates knowledge over time.
>
> ---
>
> ## Building your moat
>
> If you zoom out, the direction is pretty clear. Models are getting better across the board. Reasoning improves, tool use improves, costs go down.
>
> So the question becomes: what actually differentiates your system?
>
> It is not just the model anymore. It is what your system knows, and how that knowledge evolves over time.
>
> Your data matters, but raw data is not enough.
>
> What matters is:
>
> - how you structure it
>
> - how you connect it
>
> - how you update it
>
> - and how you use it during execution
>
> That's where the moat is. Not in static datasets, but in systems that learn from their own use.
>
> And that brings us back to memory.
>
> Because memory is the layer where:
>
> - interactions become knowledge
>
> - knowledge gets consolidated
>
> - and future behavior changes
>
> At @cognee_ , this is the layer we are focused on, not just storing information, but making it usable, structured, and part of the execution loop.
>
> ---
>
> To sum up:
>
> Agent = Model + Harness
>
> The model provides the intelligence. The harness makes it useful. But as systems evolve, something becomes clear.
>
> The harness is not just about execution anymore. It's about how the system learns.
>
> Because without memory, every execution starts from scratch. And with memory, execution compounds. So the difference is no longer just in how well your system runs. It's in whether it improves. And that's where the memory layer becomes central.
>
> *Article header image*
> ![[tricalt-407656-001.jpg]]
>
> Engagement: 62 likes | 7 retweets | 1 reply
> [Original post](https://x.com/tricalt/status/2035050668797407656)
