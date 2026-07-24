---
created: 2026-07-24
description: Sam Z Liu (Stash AI) maps the context-management gold rush — why startups and incumbents from vastly different starting points are all converging on the same org-level company brain, the taxonomy of players, the design patterns emerging across them, and the missing pieces (evals, continual learning, blast radius, a killer use-case) still blocking mass adoption.
source: https://x.com/samzliu/status/2080210797465379147
type: synthesis
---

## Key Takeaways

- Context management is framed as one of only ~four big AI opportunities left (alongside research labs, RL environments, and infrastructure), and it checks every high-growth box: Jevon's paradox (cheap code and text will explode the volume of data that Slack/Notion/GitHub were never designed to hold), a self-improvement narrative sellable to executives ("build your context layer now or never catch up"), data-sovereignty tailwinds (companies fear frontier labs training on their internal data), SaaS-style switching-cost moats (Nadella's "reverse information paradox"), and model-capability saturation — the belief that intelligence is largely solved so context is the bottleneck, and crucially that this sits outside the labs' main strike zone, so "Anthropic won't kill your company." The context-is-the-bottleneck premise is the market-map version of [[most agent bottlenecks are actually memory problems not model or orchestration problems]], and the moat argument is [[Memory ownership follows harness ownership - Harrison Chase argues picking a closed harness is picking a permanent owner for your agent's data flywheel]].
- "All roads lead to Rome": products starting from very different places converge on the same company brain, partly because agents collapse products into a singularity (a coding agent is fundamentally not that different from a marketing or email agent). Liu's taxonomy of the fuzzy field spans personal knowledge bases (GBrain/Obsidian — where people start, and where they fail scaling to a team), per-agent memory layers (Letta/Honcho/Engram, split on token-space vs weight-space), observability (Braintrust/Raindrop), agent dev tools (Entire/Mintlify), data-moat builders (Applied Compute/Prime Intellect), incumbents reinventing themselves (Notion/ClickUp/Glean/Airbyte/PromptQL), AI-employee PLG plays (Viktor/Lindy), vertical AI-native service firms, and native company brains (Stash/Sentra/Hyperspell/Supermemory) — mostly not direct competitors, since they target different customers, use-cases, and stack layers. This is the same convergence [[Company Brain Capstone - Claude Managed Agents Point to the Next AI Infra Layer]] calls the org-level context layer, and the "LLM wiki" corner of it is exactly [[The LLM Wiki compiles a corpus into maintained markdown at ingest, but a wiki is not user memory (mem0's State of Agent Wikis)]].
- The design patterns are converging even where the companies aren't: multiplayer collaboration with version control (agents fork and modify each other's work, and not every thousand-line PR is wanted), accumulating skills as a "reasoning cache" so one agent's token spend benefits the whole org, hybrid retrieval (no single method wins — combine vector search, knowledge graphs, agentic search, and keyword), sleep-time / "dreaming" custodian agents kept separate from the working agent to index, de-dup, and update the store, and read-only external connections (Slack, email, calendar, CRM) that inherit each source's sharing scopes to keep permissioning simple. Liu notes most practitioners at his company-brain event believe none of the current paradigms will stick. The hybrid-retrieval and ingestion patterns are exactly what [[Cerebras built an internal knowledge base as a hybrid-retrieval system fusing lexical, vector, IDF, and age-decay over one Postgres embeddings table]], and the sleep-time custodian is the offline-consolidation move of [[Auto-Dreamer learns offline region rewriting to shrink language-agent memory 12x while improving task success]].
- The honest part is what's missing for mass adoption: a clean ontology blending structured and unstructured data (and text- vs weight-stored memory, each with different permissions, shapes, and update cadences); ingestion everywhere (the tipping-point problem — a brain is only useful past a data threshold, and security reviews plus integration work make sales cycles long); access controls and data-leakage guardrails; good evals (is a company brain real productivity or a "productivity nerd's dream," and how do you run long-horizon memory rollouts affordably?); stability over long timeframes, which he equates directly with solving continual learning so a new skill or source doesn't dilute or "slopify" existing ones (context rot is real); and "blast radius" — bounding retrieved information by scope, because pure retrieval is not sufficient and memory needs reasoning about which pieces matter. That missing list maps almost one-to-one onto the five gaps in [[Mem0 surveys nine agent harness memory systems and finds five recurring gaps - bounded storage, keyword retrieval, harness scoping, weak staleness, and isolation]], and the context-rot / retrieval-isn't-enough crux is the formal result of [[The Price of Meaning prescribes coupling semantic retrieval with exact episodic grounding as the only escape from interference]].
- The unsolved crux is the killer use-case: for all the hype, the clear business case and ROI are still being developed and the metrics haven't caught up to the vision. The working hypotheses so far are retrieve scattered information (Glean's original use-case), automate boring repetitive workflows, cost and latency savings (memory/context layers have cut token costs ~60-90%), and better agent performance (completing tasks agents otherwise couldn't).

## External Resources

- [Stash AI](https://x.com/joinstashAI) — the author's company (a native "company brain" startup); the post is a founder's market map of the space.
- Companies named across the taxonomy: [GBrain](https://github.com/garrytan/gbrain), Letta, Honcho, EngramLab, Braintrust, Raindrop, Entire, Mintlify, Applied Compute, Prime Intellect, Notion, ClickUp, Airbyte, Glean, PromptQL, Viktor, Lindy, Sentra, Hyperspell, Supermemory, Composio, Pinecone, Exa, Hydra.
- Referenced writing: [Satya Nadella's "reverse information paradox"](https://x.com/satyanadella/article/2076323181154230284), [Alex Zhang on the harness / "right context"](https://alexzhang13.github.io/blog/2026/harness/), [Chroma's Context Rot research](https://www.trychroma.com/research/context-rot), [Plastic Labs' "Memory as Reasoning"](https://plasticlabs.ai/blog/posts/Memory-as-Reasoning), [Pinecone's AskData (~60-90% token cost reduction)](https://www.pinecone.io/blog/inside-askdata/), and the [New Scientist piece on AI discovering new math](https://www.newscientist.com/article/2580374-ais-solution-to-87-year-old-riddle-takes-mathematicians-by-surprise/).

## Original Content

> @samzliu (Sam Z Liu) — 2026-07-23
>
> *Collage of context-management marketing copy from across the space — "Memory that reasons," "Give agents context," "Your Company's Brain," Sentra, Notion, PromptQL, a $45M Series B announcement*
> ![[samzliu-379147-001.png]]
>
> **Article: The context gold rush: Why everyone is building the same thing.**
>
> You either die building product or live long enough to do context management. Whether you call it a context graph, company brain, or LLM wiki, it seems that many start-ups and larger companies alike are building the same thing: a place to store data and context for tomorrow's agentic workforce. This is one of the four main ideas apparently left in AI: research lab, RL environment, infrastructure, or context management.
>
> From an ecosystem perspective, a context management product checks all the boxes for a high growth start-up or internal innovation team:
>
> - Jevon's paradox (timing) - Lowering the cost (time, friction, labour) of producing code and writing will cause an explosion of text-based data that our current tools (e.g. Slack, Notion, Github, etc.) are not designed to handle. We are still on the early part of that curve as agent adoption penetrates the wider economy.
>
> - Self-improvement (vision) - There's an enticing vision of an autonomous self improving system where agents become better and better over time without human intervention. Capturing and managing context is a big part of what we believe will enable that capability. Moreover, it's a narrative that's sellable to executives: you better develop your own context layer now before your competitors do so or you'll never catch-up.
>
> - Data sovereignty (tailwinds) - Companies and governments are becoming increasingly worried about the frontier labs training on their internal data. An external, trusted party to store and manage that data will become increasingly important.
>
> - Context moat (business model) - The previous generation of SaaS was build on moats and the monopoly power. A lot of what drove this was high switching costs: once you become embedded into a company, it's extremely hard for them to switch off. Managing a company's context seems to have all the similar properties of yesteryear's glory days. Moreover,  for some types of business models (e.g. Harvey), you can develop your own context moat by servicing customers. This is Nadella's [reverse information paradox](https://x.com/satyanadella/article/2076323181154230284).
>
> - Model capability saturation (tech edge and competition) - There's this growing belief that models can do anything we want them to as long as they have the [right context](https://alexzhang13.github.io/blog/2026/harness/). As frontier models have started to [discover new math](https://www.newscientist.com/article/2580374-ais-solution-to-87-year-old-riddle-takes-mathematicians-by-surprise/), there's a sense that we have saturated the intelligence needed for most tasks. The bottleneck, then, is context. This suggests that context is one of the few big areas of opportunity left that will not become commoditized by better models. Moreover, this also seems largely out of the main strike zone for the labs, making it a compelling focus area lest Anthropic kill your company.
>
> All Roads Lead to Rome
>
> It's clear that something like a company brain is needed. But what's striking is how similar products can seem, even if they started from vastly difference places. Part of this is agents collapsing product into a singularity: a coding agent is fundamentally not that different from a marketing agent or email agent. And so it goes across the stack. But another big part of it is that the space is still early with lots of players trying to lay claim to a fuzzy field.
>
> – Personal knowledge base — Github repo, [Gbrain](https://github.com/garrytan/gbrain), Claude Code + @obsdmd. This is a folder of markdown files that serve as skills and memory for your agents. Where people start when experimenting. They fail when trying to expand to an entire team.
>
> – Agent memory — @Letta_AI. @honchodotdev. @EngramLab. These are per-agent memory layers that scale vertically in time. The companies tend to be research focused on a goal of building super long horizon agents. There's a split between companies that believe in token spaces vs weight space.
>
> – Observability tools — @braintrust, @raindrop_ai. They capture the traces your external, production agents emit. The outputs here tend to be dashboards and evals rather than an accumulating data store for future agents. Not directly playing here but they are a natural place where the data accumulates.
>
> – Agent Dev tools — @EntireHQ, @mintlify. They provide a similar service to observability tools except these are for your internal coding agents. The outputs here are a set of docs so that your coding agents produce less slops and run for longer.
>
> - Data moat builders — @appliedcompute. @PrimeIntellect. They sell enterprises on a vision of custom models and context layer that are hyper-specific to their workflows. Part research lab, part AI context consulting firm, part GPU provider, the strategy here is to own the customer relationship E2E and be a one-stop shop.
>
> – Companies Reinventing Themselves — @NotionHQ, @clickup, @AirbyteHQ, @Glean, @PromptQL. These are companies that were established in related areas which joined in on the context gold rush.
>
> - AI Employee — @viktor__com, @getlindy. Starting at the level of individual users, they are presumably that they are well positioned to capture context and build up a PLG notion that maps context across entire orgs. While [Claude Tag](https://x.com/ashwingop/status/2069814177624121469) was criticized as a trojan horse for doing this very thing, these smaller companies will face less resistance.
>
> - Vertical AI-Native Service Companies — Too many to count. By building custom E2E workflows, they too build up an accumulating context layer. By going vertical, the strategy is to solve their customer's pain points better than any horizontal player.
>
> - Company Brain — @joinstashAI (full disclosure - this is us!), @sentra_app, @hyperspell, @supermemory. All relatively early start-ups, these companies were started to natively solve the org-level context layer problem. The bet is that directly focusing on this problem from day 1 rather than laterally moving into it from the side will enable this category to win out.
>
> And this doesn't even count the frontier labs which are doing similar work across their FDE & product teams or the related players such as @hydra_db, @pinecone (expanding vertically up from infrastructure),  @ExaAILabs (seem to be moving from web search to enterprise search), agent orchestration companies that are building memory into their product, agent workflow companies, or integration companies like @composio that connect to existing context and sources of truth. These all could laterally move into context management if there's an opportunity. For instance, an open question is as models get smarter, are integrations all you need?
>
> There is likely space for many of these companies to thrive. Despite the similar marketing copy, they are probably not competitors: going after different customers with different use-cases at different parts of the stack. Context management is a problem that anyone using agents in the future will need to solve. And if the hype is to believed, that "anyone" will become "everyone" shortly enough. We will likely see a stratification as the temperature around context management dies down and it moves from a buzz word to a disciplined business. But it is a strange new world where a company selling to a 4 person design agency has the same essential product as a company selling cutting edge research to billion dollar tech companies.
>
> The current patterns
>
> Even across these very different starting points, a few patterns are becoming clear:
>
> – Multiplayer and version control — Ensure that team members and their agents can collaborate. Version control is already critical for single player agents since not every multi-thousand line PR your coding agent puts up is desired. It's even more critical for multi-player as different team members modify and fork each other's work.
>
> – Accumulating skills  — An agent's token spend should not only benefit the direct task at hand but also the entire organization. The context layer becomes this "reasoning cache" which makes future agents perform better. Overtime, more and more workflows can be automated in this way.
>
> – Hybrid retrieval layer — No single retrieval method wins. Combine vector search, knowledge graphs, and agentic search with keyword search for best results.
>
> – Dreaming and sleep-time Compute — Separate out the agent that is doing the work (e.g. Claude Code session, workflow agent) from the agent that is a custodian over the knowledge base. The sleep-time agent indexes, de-dups, and updates.
>
> – External connections — Pull from as many external sources as possible (e.g. Granola, email, calendar, slack, CRM, etc.). Treat these as raw data sources that your sleep-time agents read but don't edit over. To keep data isolation and permissioning simple, inherent the sharing scopes of these external connections.
>
> An important note is that the current implementation of these patterns will become out of date as the industry evolves. We [hosted a company brain and memory](https://x.com/samzliu/status/2077482285960733068?s=20) event a few weeks ago and found that most people believe the current paradigms will not stick around.
>
> What's missing
>
> We are still very early however and missing several key components to mass adoption:
>
> – Combining structured and unstructured data — A clean ontology or mental model between all the different data types. Should the data be structured as database tables or file systems? How to deal with unstructured data such as Slack channels? What happens if some of the memory becomes stored in weights rather than pure text? Each type of data has different permission models, shapes, and update cadences. While humans can blend these seamlessly for different contexts (sorry overloaded term!), agents need a bit more guidance.
>
> – Data ingestion everywhere — Company brains only become useful once you reach a tipping point of information that is inside of them. Otherwise, it's typically more efficient to go to each source directly. This requires ingesting data in all different formats from PDFs to database tables and integrating with all the tools at an organization. This makes sales cycles long due to security reviews and hefty integration FDE work.
>
> – Data access and controls — Making sure the right people access the right information and the wrong people cannot access it. This is tricky to get right because each architecture has its own trade offs. Do you provision each agent a user? What information is shared between teams vs private? Can you build effective guard rails to prevent data leakage?
>
> – Good evals — Does a company brain actually help your team become more productive? Or is it just a productivity nerd's dream? What makes one implementation measurably better from another? And since memory is inherently a long-horizon problem, rollouts on evals will becoming increasingly expensive and hard to do.
>
> – Stability over long timeframes — Put it another way, we need to solve continual learning. We need to trust adding another skill or data source won't dilute the performance of the existing ones or that the knowledge bases will not slopify over time. [Context rot](https://www.trychroma.com/research/context-rot) is still a very real problem with LLMs today.
>
> - Blast radius — Our internal name for how retrieved information is bounded by scope (time, context, prioritization). It's becoming clear that pure [retrieval is not sufficient](https://plasticlabs.ai/blog/posts/Memory-as-Reasoning) for good memory and we will need to develop better ways to instill common sense about which pieces of information matter more.
>
> - Killer use-case — This is the big one. For all the hype around context graphs and company brains, the clear business case and ROI for these products are still being developed. The metrics have not caught up to the technology and vision. A few emerging hypotheses that are working okay so far:
>
> - Retrieve information - this is the original Glean killer-use case. Find information across scattered datasets and sources of truth.
>
> - Automate workflows - have agents do the repetitive, boring tasks. And have them do more and more of them as time goes on.
>
> - Cost and latency savings - memory and context layers have been shown to [decrease token costs by ~60-90%](https://www.pinecone.io/blog/inside-askdata/)
>
> - Better agent performance - have your agents complete tasks they would not have been able to otherwise.
>
> These are the questions we're spending our time solving. If you're building or thinking about your own brain, we'd love to chat!
>
> Engagement: 181 likes | 11 retweets | 8 replies
> [Original post](https://x.com/samzliu/status/2080210797465379147)
