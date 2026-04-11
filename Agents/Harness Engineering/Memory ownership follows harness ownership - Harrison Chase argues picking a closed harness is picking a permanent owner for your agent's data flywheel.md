---
created: 2026-04-11
description: Harrison Chase's strategic manifesto arguing that memory is inseparable from the agent harness, so picking a closed harness silently transfers ownership of your proprietary interaction dataset to a model provider — the thesis that underwrites LangChain's Deep Agents Deploy launch one day earlier.
source: https://x.com/hwchase17/status/2042978500567609738
type: framework
---

## Key Takeaways

- **Memory isn't a plugin, it's the harness — and that makes harness choice irrevocable.** Chase anchors the piece on Sarah Wooders' line ("asking to plug memory into an agent harness is like asking to plug driving into a car") and then enumerates exactly what memory-management responsibilities already live inside the harness: loading `AGENTS.md`/`CLAUDE.md`, deciding what survives compaction, exposing filesystem state, presenting skill metadata, letting the agent modify its own system instructions. Every one of those is a memory decision you cannot extract from the harness without rebuilding it. This reframes harness selection as a one-way door: once memory accumulates, you've accepted whatever the harness decided about storage, compaction, and retrieval permanently. It's the same coupling thesis as [[agent harnesses are the product not the model]], but Chase's version sharpens it — the harness isn't just the lever, the harness *is* the accumulated state.

- **The three-tier lock-in taxonomy gives you a checklist for evaluating any harness.** Mildly bad: stateful APIs like OpenAI's Responses API and Anthropic's server-side compaction — you can tune through them but can't resume a thread after switching models. Bad: closed harnesses like the Claude Agent SDK (which wraps Claude Code's unreleased 512k-line source) — the harness-memory interaction is opaque and whatever artifacts it produces are non-transferable. Worst: closed harnesses with server-side long-term memory, where you don't own the memory at all. Chase names [[Anthropic Managed Agents virtualizes agent components into OS-style interfaces that decouple the brain from the hands|Claude Managed Agents]] as the endpoint of that trend, and the kicker is that even fully open-source Codex emits encrypted compaction summaries that are unusable outside the OpenAI ecosystem. Open-source alone isn't enough — the test is whether *memory artifacts* are portable, not whether the code is.

- **Memory is the actual moat because statelessness is the reason model switching has been easy so far.** Chase's economic argument is that LLM providers have had almost no lock-in to date precisely because they're stateless — you can rewrite a prompt and move from OpenAI to Anthropic in an afternoon. The moment state enters the system, switching cost explodes because the state *is* the product's differentiation. "Without memory, your agents are easily replicable by anyone who has access to the same tools" — which is Chase's version of the vendor-moat argument that runs through [[the harness layer is the next hundred billion dollar AI infrastructure market not the model]]. Model providers are racing memory behind APIs not because it's convenient for developers but because it's the only lock-in layer left after commoditized weights.

- **The Fleet email-agent anecdote is the strongest part of the piece because it shows how cheap it is to lose everything.** Chase's internal email assistant, built on LangSmith Fleet, accumulated personalization over months — tone, preferences, patterns — until it was accidentally deleted. Rebuilding it from the same template was "so much worse" because every interaction the agent had learned from was gone. This is the operational version of the theoretical argument: if you don't own the memory substrate, a platform outage, a subscription lapse, or a routine migration resets your data flywheel to zero. Production agents that accumulate user-specific memory (email assistants, SDR/sales agents, code-review agents, customer support bots) are especially exposed — and customer-facing agents are the worst because the memory you lose isn't even yours, it's your customers' accumulated context with you.

- **This thesis is the strategic underpinning of [[LangChain Deep Agents Deploy offers open harness to avoid Claude Managed Agents memory lock-in|LangChain's Deep Agents Deploy product launch]] published 24 hours earlier.** The two pieces are paired: the Deep Agents Deploy post is the product (CLI, LangSmith deployment, 30+ endpoints, pluggable DBs, Claude Managed Agents feature comparison), and this post is the manifesto that explains why the product has to exist. Read together, they form LangChain's complete open-harness argument — read separately, the product launch reads as marketing and this piece reads as industry commentary. Chase's prescription is specifically to use Deep Agents (open source, model-agnostic, AGENTS.md/skills standards, pluggable Mongo/Postgres/Redis memory, self-hostable via LangSmith Deployment), and the position parallels Letta's memory-first architecture in [[memory-first agents should dispatch stateless subagents for focused task execution]] and the harness-as-RL-training-environment argument in [[the agent harness is the RL training environment not deployment infrastructure bolted on after]] — all three are versions of the same claim that state ownership is the hinge decision, and [[model + System outlasts Harness, production agents need database-backed memory, RBAC, and isolation|Ashpreet Bedi's database-backed-memory argument]] is the strongest counter, claiming multi-tenant RBAC-enforced databases defuse the lock-in without needing an open harness.

## External Resources

- [Sarah Wooders: "Memory isn't a plugin (it's the harness)"](https://x.com/sarahwooders/status/2040121230473457921) — the post Chase builds the entire argument on; Wooders is CTO of Letta
- [Deep Agents Deploy (blog launch)](https://blog.langchain.com/deep-agents-deploy-an-open-alternative-to-claude-managed-agents/) — the companion product launch this thesis underwrites, captured separately in [[LangChain Deep Agents Deploy offers open harness to avoid Claude Managed Agents memory lock-in]]
- [The Anatomy of an Agent Harness](https://blog.langchain.com/the-anatomy-of-an-agent-harness/) — LangChain's earlier post defining the discipline of harness engineering
- [Deep Agents Overview](https://docs.langchain.com/oss/python/deepagents/overview) — the open-source, model-agnostic harness LangChain is prescribing
- [LangChain (GitHub)](https://github.com/langchain-ai/langchain) — the original RAG chains framework from the ChatGPT era
- [LangGraph (GitHub)](https://github.com/langchain-ai/langgraph) — the intermediate complex-flow framework that predates harnesses
- [Claude Code](https://code.claude.com/docs/en/overview) — example of the closed harness tier (512k lines of leaked source)
- [Pi (GitHub)](https://github.com/badlogic/pi-mono) — the harness that powers OpenClaw
- [OpenClaw docs](https://docs.openclaw.ai/) — open harness built on Pi
- [OpenCode](https://opencode.ai/) — another open agent harness in the landscape
- [Codex](https://openai.com/codex/) — cited as the cautionary example: open-source but emits encrypted compaction summaries
- [Letta Code](https://www.letta.com/blog/letta-code) — memory-first harness, Letta's approach to the same problem
- [Claude Managed Agents](https://platform.claude.com/docs/en/managed-agents/overview) — Chase's named tier-3 worst-case example
- [Claude Code source leak (Reddit)](https://www.reddit.com/r/technology/comments/1scyuod/anthropic_leaked_512k_lines_of_claude_codebut/) — the 512k-lines evidence that harnesses aren't going away even for frontier-model makers
- [MongoDB LangGraph integration](https://www.mongodb.com/docs/atlas/ai-integrations/langgraph/) — one of the pluggable memory backends Deep Agents uses
- [LangSmith Deployment](https://docs.langchain.com/langsmith/deployment) — the self-hostable deployment target where memory actually lives in Chase's prescription
- [AGENTS.md](https://agents.md/) — open standard for agent instructions
- [Agent Skills](https://agentskills.io/home) — open standard for agent specialized knowledge

## Original Content

> @hwchase17 (Harrison Chase) — 2026-04-11
>
> **Article: Your harness, your memory**
>
> Agent harnesses are becoming the dominant way to build agents, and they are not going anywhere. These harnesses are intimately tied to agent memory. If you used a closed harness - especially if it's behind a proprietary API - you are choosing to yield control of your agent's memory to a third party. Memory is incredibly important to creating good and sticky agentic experiences. This creates incredible lock in. Memory - and therefor harnesses - should be open, so that you own your own memory
>
> **Agent Harnesses are how you build agents, and they're not going anywhere**
>
> The "best" way to build agentic systems has changed dramatically over the past three years. When ChatGPT came out, all you could do were simple RAG chains ([LangChain](https://github.com/langchain-ai/langchain)). Then the models got a little better, and could create more complex flows ([LangGraph](https://github.com/langchain-ai/langgraph)). Then they got a lot better, and that gave rise to a new type of scaffolding - [agent harnesses](https://blog.langchain.com/the-anatomy-of-an-agent-harness/).
>
> *Figure: The LangChain "anatomy of an agent harness" diagram — Model at center, with Control (compaction, orchestration, ralph loops), Action (calls bash, tools, MCPs), Persist (filesystem, git, progress files), and Observe & Verify (browser screenshots, test results, logs) as the four first-class responsibilities that sit around the model.*
> ![[hwchase17-609738-001.jpg]]
>
> *Figure: The full harness anatomy with Agent and HARNESS outer labels and an explicit Context Injection arrow (prompts, memory, skills, conversation) coming into the model from the top. Chase's point is that context/memory injection is as fundamental to the harness as tools and persistence — it is not an add-on.*
> ![[hwchase17-609738-002.png]]
>
> Examples of agent harnesses include [Claude Code](https://code.claude.com/docs/en/overview), [Deep Agents](https://github.com/langchain-ai/deepagents), [Pi](https://github.com/badlogic/pi-mono) (powers [OpenClaw](https://docs.openclaw.ai/)), [OpenCode](https://opencode.ai/), [Codex](https://openai.com/codex/), [Letta Code](https://www.letta.com/blog/letta-code), and many more.
>
> 💡 Agent harnesses are not going away.
>
> There is sometimes sentiment that models will absorb more and more of the scaffolding. This is not true. What has happened (and will continue to happen) is that a lot of the scaffolding needed in 2023 is no longer needed. But this has been replaced by other types of scaffolding. An agent, by definition, is an LLM interacting with tools and other sources of data. There will always be a system around the LLM to facilitate that type of interaction. Need evidence? When Claude Code's source code was leaked, there was [512k lines of code](https://www.reddit.com/r/technology/comments/1scyuod/anthropic_leaked_512k_lines_of_claude_codebut/). That code is the harness. Even the makers of the best model in the world are investing heavily in harnesses.
>
> When things like web search are built into OpenAI and Anthropic's APIs - they are not "part of the model". Rather, they are part of a lightweight harness that sits behind their APIs and orchestrates the model with those web search APIs (via nothing other than tool calling).
>
> **Harnesses are tied to memory**
>
> Sarah Wooders wrote a [great blog](https://x.com/sarahwooders/status/2040121230473457921) on why "memory isn't a plugin (it's the harness)", and I couldn't agree with it more.
>
> [Embedded Tweet: https://x.com/i/status/2040121230473457921]
>
> *Figure: The whimsical "memory as a plug-in" illustration — a person with the top of their head hinged open, a dashed line connecting to a brain with a plug on it. Chase and Wooders use this as the naive view they reject: you cannot treat memory as an external peripheral you attach to an already-built harness.*
> ![[hwchase17-609738-003.jpg]]
>
> There is sometimes sentiment that memory is a standalone service, separate from any particular harness. At this point in time, that is not true.
>
> A large responsibility of the harness is to interact with context. As Sarah puts it:
>
> > Asking to plug memory into an agent harness is like asking to plug driving into a car. Managing context, and therefore memory, is a core capability and responsibility of the agent harness.
>
> Memory is just a form of context. Short term memory (messages in the conversation, large tool call results) are handled by the harness. Long term memory (cross session memory) needs to be updated and read by the harness. Sarah lists out many other ways the harness is tied to memory:
>
> > How is the [AGENTS.md](http://agents.md/) or [CLAUDE.md](http://claude.md/) file loaded into context?
> > How is skill metadata shown to the agents? (in the system prompt? in system messages?)
> > Can the agent modify its own system instructions?
> > What survives compaction, and what's lost?
> > Are interactions stored and made queryable?
> > How is memory metadata presented to the agent?
> > How is the current working directory represented? How much filesystem information is exposed?
>
> Right now, memory as a concept is in it's infancy. It's so early for memory. Transparently, we see that long term memory is often not part of the MVP. First you need to get an agent working generally, then you can worry about personalization. This means that we (as an industry) are still figuring out memory. This means there are not well known or common abstractions for memory. If memory does become more known, and as we discover best practices, it is possible that separate memory systems start to make sense. But not at this point in time. Right now, as Sarah said, "ultimately, how the harness manages context and state in general is the foundation for agent memory."
>
> **If you don't own your harness, you don't own your memory**
>
> The harness is intimately tied to memory.
>
> 💡 If you use a closed harness, especially if its behind an API, you don't own your memory.
>
> This manifests itself in several ways.
>
> *Figure: Baseline "open" architecture — the harness on the left holds Short term memory, Long term memory, Tools, and Prompt; the model provider API on the right holds only the LLM. State lives entirely on the developer's side, which is what makes model-switching cheap today.*
> ![[hwchase17-609738-004.jpg]]
>
> **Mildly bad:** If you use a stateful API (like OpenAI's Responses API, or Anthropic's server side compaction), you are storing state on their server. If you want to swap models and resume previous threads - that is no longer doable.
>
> *Figure: Tier 1 — Mildly bad. Short term memory has migrated into the Model Provider API; Long term memory, Tools, and Prompt still live in the developer's harness. Thread state is now trapped on the provider's server, so you cannot resume a conversation after switching models.*
> ![[hwchase17-609738-005.jpg]]
>
> **Bad:** If you use a closed harness (like Claude Agent SDK, which uses Claude Code under the hood, which is not open source), this harness interacts with memory in a way that is unknown to you. Maybe it creates some artifacts client side - but what is the shape of those, and how should a harness use those? That is unknown, and therefor non-transferrable from one harness to another.
>
> *Figure: Tier 2 — Bad. A "Black Box Harness" (filled blue region) now owns Long term memory and the harness-memory interaction is opaque; Prompt and Tools have been pushed outside the black box; Short term memory still sits inside the Model Provider API. The developer cannot see how memory is being stored or what transformation happens at compaction.*
> ![[hwchase17-609738-006.jpg]]
>
> 💡 But worst is something else - when the whole harness, including long term memory is behind an API.
>
> In this situation, you have zero ownership or visibility into memory, including long term memory. You do not know the harness (which means you don't know how to use the memory). But even worse - you don't even own the memory! Maybe some parts are exposed via API, maybe no parts are - you have no control over that.
>
> *Figure: Tier 3 — Worst. The Harness itself has moved entirely inside the Model Provider API, enclosing both Long term memory and Short term memory. Only Tools and Prompt remain on the developer's side. This is the configuration Chase names Claude Managed Agents as exemplifying — the memory the agent accumulates is literally owned by the model provider and exposed only through whatever API surface they choose.*
> ![[hwchase17-609738-007.jpg]]
>
> When people say that the "models will absorb more and more of the harness" - this is what they really mean. They mean that these memory related parts will go behind the APIs that model providers offer.
>
> 💡 This is incredibly alarming - it means that memory will become locked into a single platform, a single model.
>
> Model providers are incredibly incentivized to do this. And they are starting to. Anthropic launched [Claude Managed Agents](https://platform.claude.com/docs/en/managed-agents/overview). This puts literally everything behind an API, locked into their platform.
>
> Even if the whole harness isn't behind the API, model providers are incentivized to move more and more behind APIs - and are already doing so. For example: even though Codex is an open source, it generates an encrypted compaction summary (that is not usable outside of the OpenAI ecosystem).
>
> Why are they doing this? Because memory is important, and it creates lock in that they don't get from just the model.
>
> **Memory is important, and it creates lock in**
>
> Although memory is early, it is clear to everyone that it is important. It is what allows agents to get better as users interact with them, and allows you build up a data flywheel. It is what allows your agent to be personalized to each of your users, and build up an agentic experience that molds to their desires and usage patterns.
>
> 💡 Without memory, your agents are easily replicable by anyone who has access to the same tools.
>
> With memory, you build up a proprietary dataset - a dataset of user interactions and preferences. This proprietary dataset allows you to provide a differentiated and increasingly intelligent experience.
>
> It's been relatively easy to switch model providers to date. They have similar, if not identical, APIs. Sure, you have to change prompts a little bit, but that's not that hard.
>
> But this is all because they are stateless.
>
> As soon as there is any state associated, its much harder to switch. Because this memory matters. And if you switch, you lose access to it.
>
> Let me tell a story. I have an email assistant internally. It's built on top of a template in [Fleet](https://www.langchain.com/langsmith/fleet), our no-code platform for building Enterprise ready OpenClaws. This platform has memory built in, so as I interacted with my email assistant over the past few months it built up memory. A few weeks ago, my agent got deleted by accident. I was pissed! I tried to create an agent from the same template - but the experience was so much worse. I had to reteach it all my preferences, my tone, everything.
>
> The plus side of my email agent deleted - it made me realize how powerful and sticky memory could be.
>
> **Open Memory, Open Harnesses**
>
> Memory needs to be opened, owned by whomever is developing the agentic experience. It allows you to build up a proprietary dataset that you actually control.
>
> Memory (and therefor harnesses) should be separate from model providers. You should want optionality to try out whatever models are best for your use case. Model providers are incentivized to create lock in via memory.
>
> This is why we are building [Deep Agents](https://docs.langchain.com/oss/python/deepagents/overview). Deep Agents:
>
> - Is open source
> - Is model agnostic
> - Uses open standards like [agents.md](http://agents.md/) and [skills](https://agentskills.io/home)
> - Has plugins to [Mongo](https://www.mongodb.com/docs/atlas/ai-integrations/langgraph/), Postgres, Redis and others for storing memories
> - Is deployable: (1) via [LangSmith Deployment](https://docs.langchain.com/langsmith/deployment) (self hostable, can be deployed on any cloud, can bring your own database to serve as a memory store); (2) behind any standard web hosting framework
>
> In order to own your memory, you need to be using an Open Harness
>
> Try out [Deep Agents](https://docs.langchain.com/oss/python/deepagents/overview) today.
>
> Thank you to a few people for review and thoughts:
>
> - [Sydney Runkle](https://x.com/sydneyrunkle), who is doing a lot of great Deep Agents and memory work
> - [Viv Trivedy](https://x.com/Vtrivedy10), who is a leading voice on agent harnesses
> - [Nuno Campos](https://x.com/nfcampos), who has some great writing on context engineering for finance agents
> - [Sarah Wooders](https://x.com/sarahwooders), who is CTO of Letta, a company that has consistently been at the forefront of stateful agents
>
> Engagement: 271 likes | 27 retweets | 11 replies
> [Original post](https://x.com/hwchase17/status/2042978500567609738)
