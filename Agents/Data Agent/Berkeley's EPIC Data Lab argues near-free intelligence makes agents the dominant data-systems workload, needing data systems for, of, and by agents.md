---
created: 2026-07-08
description: A Berkeley EPIC Data Lab position paper arguing that as inference cost approaches zero, agents become the dominant data-systems workload, opening three research agendas — data systems FOR agents (agentic speculation), OF agents (agentic substrate and structured memory), and BY agents (synthesizing custom systems from scratch).
source: https://bair.berkeley.edu/blog/2026/07/07/intelligence-is-free-now-what/
type: synthesis
topic: data-agents
---

## Key Takeaways

- **The forcing function is price, not capability: inference has fallen 9x–900x per year (median ~50x), GPT-4-class from ~$30 to <$1 per million tokens, and "good enough for most knowledge work" intelligence is already here.** The consequence Aditya Parameswaran, Matei Zaharia, Ion Stoica, Joe Hellerstein and their EPIC Data Lab / DSF co-authors draw is that *agents*, not humans or BI tools, become the dominant workload for data systems — with swarms spun up per end-user request — which reframes the whole research agenda into three axes: systems *for*, *of*, and *by* agents.
- **FOR agents — "agentic speculation" is a new workload class that data systems should exploit rather than merely serve.** A single high-level request (root-cause, cohort/churn analysis) fans out into thousands of SQL queries, but on a text-to-SQL benchmark only 10–20% of sub-plans are distinct — 80–90% is duplicate work, yet the redundancy raises task success. So an agent-first system should reuse results across overlapping sub-plans (decades-old [[the hard problem in text-to-SQL is discovery not generation and hybrid search over existing metadata solves it|multi-query optimization and shared scans]]), *satisfice* with approximate answers (AQP) and streamed intermediate results, expose batch/higher-level primitives (DBT-style Jinja macros) instead of one-SQL-at-a-time, and turn *proactive* — steering agents, returning latency estimates before executing, pre-building views into context — because an agent accepts textual feedback, not just a strict SQL result. This is the systems-side complement to [[DAB benchmark exposes frontier data agents at 38 percent pass at 1 with 85 percent of failures in planning or implementation|the DAB benchmark]] finding that agent failures are planning/implementation, not data selection.
- **OF agents — "files are all you need" breaks at swarm scale; the fix is structured, corrective memory plus a coordination substrate.** Markdown-file memory (grep + embedding retrieval) — [[Hermes, Codex, and Claude Code converge on markdown plus filesystem tools because memory is a judgment problem not a data structure problem|the current harness consensus]] — and knowledge graphs both lack *structured* search, so at scale you can't retrieve only the pertinent, corrective slice. Berkeley's [structured memory](https://arxiv.org/abs/2602.13521) organizes memory across facets (tables, columns, operation type, open-ended NL instruction), each set to `*` (universal) or a value list, so a date-time rule or a "prefer `product_cleaned` over `product`" correction fires only when it matches — an application-specific schema agents help define, echoing [[PARA and atomic facts give AI agents durable structured memory|faceted/atomic memory stores]] and the structured counterpart to context-layer arguments like [[context management replaces the semantic layer for data agents because it adapts from corrections|correction-driven context]] and [[data agents are useless without a context layer that captures business definitions and tribal knowledge|the living context layer]]. Beyond memory, the substrate must handle concurrent edits from thousands of agents ([[real-time data sync is unsolved because reactivity requires coupling database and UI|CRDT/operational-transform conflict resolution with no clean consensus winner]]; MVCC/copy-on-write may not suffice; most speculative transactions must roll back; avoid "livelock" of endless compensating actions), durable execution (Temporal), and agent-to-agent negotiation/consensus (e.g., four dev agents converging on a shared schema).
- **BY agents — free intelligence makes data systems disposable: synthesize a workload-specific engine in minutes for a few dollars, then regenerate when the workload shifts.** Bespoke OLAP, GenDB, and custom key-value stores are synthesized from scratch; spec-first IDEs (Kiro) elevate specifications to first-class citizens. The hard part is *trust*: imperfect specs invite reward-hacking, so mitigations are auxiliary verification agents that generate corner-case tests (expanding the spec) and proof-carrying synthesis (generate system + correctness proof together) — plus subtractive design from mature systems (strip Postgres), composable verified components, and blending the traditional parser/optimizer/storage interfaces.
- **The long arc is co-evolution: the agent/data-system boundary blurs.** Agents may design the systems they themselves run on and recursively self-improve both interfaces and internals; the data system becomes a single source of truth for raw data, memory, and coordination state at once; and the system itself absorbs agentic components, shifting from passive query executor to proactive, self-optimizing architecture.

## External Resources

- [Agentic speculation](https://arxiv.org/abs/2509.00997) — the paper naming the high-volume, heterogeneous agent-query workload data systems must now serve.
- [Structured memory](https://arxiv.org/abs/2602.13521) — the EPIC Data Lab memory paper: corrective memory organized across matchable attributes with `*` wildcards.
- [Bespoke OLAP](https://arxiv.org/abs/2603.02001) and [GenDB](https://arxiv.org/abs/2603.02081) — agentic pipelines that synthesize complete workload-specific analytical engines in minutes to hours.
- [Custom key-value stores from scratch](https://arxiv.org/abs/2605.24096) — the authors' synthesis work whose pipeline diagram (planner/coder + critic/auditor) illustrates catching reward hacking; companion [proof-carrying synthesis early success](https://arxiv.org/abs/2605.23109).
- [Proactive data systems](https://arxiv.org/abs/2502.13016) — argument for systems that steer agents rather than passively execute queries.
- [MAST multi-agent traces](https://sky.cs.berkeley.edu/project/mast/) and evolutionary frameworks ([SkyDiscover](https://github.com/skydiscover-ai/skydiscover), [arXiv:2506.13131](https://arxiv.org/abs/2506.13131)) — mining single/multi-agent traces to make future agents more efficient.
- Memory/coordination tooling referenced: [mem0](https://mem0.ai/), [Letta](https://www.letta.com/), [Zep](https://www.getzep.com/), [LangMem](https://langchain-ai.github.io/langmem/), [Temporal for AI](https://temporal.io/solutions/ai), [Turso AgentFS copy-on-write](https://docs.turso.tech/agentfs/introduction), [Neon multiversioning](https://neon.com/docs/get-started/why-neon), [Kiro spec-first IDE](https://kiro.dev/).
- [Inference price trends (Epoch AI)](https://epochai.org/data-insights/llm-inference-price-trends) — the 9x–900x/yr decline underpinning the "free intelligence" premise.

## Original Content

> [!quote]- Source Material — "Intelligence is Free, Now What? Data Systems for, of, and by Agents" (BAIR Blog, Jul 7 2026)
>
> By Aditya G. Parameswaran, Shubham Agarwal, Kerem Akillioglu, Shreya Shankar, Sepanta Zeighami, Rishabh Iyer, Matei Zaharia, Alvin Cheung, Natacha Crooks, Joseph Gonzalez, Joseph Hellerstein, and Ion Stoica — Jul 7, 2026
>
> _... government of the people, by the people, for the people ..._
> — Abraham Lincoln, Gettysburg Address (1863)
>
> The cost of AI is dropping rapidly. GPT-4-class capabilities cost roughly $30 per million tokens in early 2023; today the same runs under $1, and [some providers are pushing costs below $0.10](https://zuplo.com/learning-center/the-10x-cheaper-ai-era-api-pricing-strategy-obsolete). Across benchmarks, [inference prices have fallen between 9x and 900x per year](https://epochai.org/data-insights/llm-inference-price-trends), with a median decline near 50x. Even [frontier models are getting dramatically cheaper](https://tokenmix.ai/blog/ai-pricing-trends-history) each generation, with open-source models following closely behind. And crucially, even if "Nobel-Prize-winning genius-level" intelligence isn't here yet, the intelligence that suffices for the vast majority of knowledge work is here today, and getting cheaper by the month. **At this rate, we are soon entering the era of virtually free intelligence**—the kind that is more than enough for everyday knowledge work.
>
> *A cartoon database character and an AI robot agent holding hands*
> ![[bair-freeintel-001.png]]
>
> Disclosure: This post is a perspective led by [Aditya G. Parameswaran](https://people.eecs.berkeley.edu/~adityagp/)—an Associate Professor of EECS and co-director of the EPIC Data Lab at UC Berkeley—together with his collaborators. It is part landscape survey and part perspective, and several of the research directions discussed below (including agentic speculation, structured memory, and synthesizing custom data systems from scratch) draw on the authors' own ongoing work.
>
> So, what does this new era of near-free intelligence mean for data systems? We believe three new challenges—and opportunities—stem from near-zero inference costs:
>
> **Data Systems _For_ Agents.** Agents will soon become the dominant workload for data systems—with swarms of agents spun up in response to each end-user request. Given differences in characteristics between agents and humans—or applications acting on their behalf—_how should we redesign data systems for such agentic users?_
>
> **Data Systems _Of_ Agents.** As agents start taking on the bulk of knowledge work, a new substrate is needed for thousands of agents to manage state over long-running tasks, coordinate and reach consensus, and deal with failures. _What do data systems that reliably and efficiently run and manage agent swarms look like?_
>
> **Data Systems _By_ Agents.** Agents are rapidly becoming capable of synthesizing entire data systems in one go—meaning we can rebuild custom systems for each new workload. Verifying that such systems match intended behavior is a challenge. _What does it take to let agents synthesize data systems we can actually trust?_
>
> *Data Systems For, Of, and By Agents*
> ![[bair-freeintel-002.png]]
>
> Next, we will discuss each in more detail, followed by discussing the intertwined future of data systems and agents, especially as the three challenges intersect.
>
> ## Data Systems For Agents
>
> An agent querying a database doesn't behave like a person or a BI tool. It performs what we call [_agentic speculation_](https://arxiv.org/abs/2509.00997): a high-volume, heterogeneous stream of work spanning schema introspection, columnar exploration, partial and then full query formulation. With multiple agents each exploring portions of the hypothesis space, each user request could amount to 1000s of individual SQL queries. Now, users can issue 'high-level' data tasks, e.g., root-cause analysis—e.g., 'why did coffee sales in Berkeley drop this year'—or exploratory cohort analysis—e.g., 'which user segments are most likely to churn next quarter'—each involving a combinatorial space of potential joins, aggregations, and filter combinations.
>
> *Data Systems Redesigned to More Effectively Support Agentic Speculation*
> ![[bair-freeintel-003.png]]
>
> The requests from these agents have various opportunities for optimization. For instance, on a text-to-SQL benchmark with multiple agents attempting each task, only 10-20% of the sub-plans are distinct. Thus, 80-90% of sub-queries perform duplicate work. The same experiments show task success rates significantly increasing with more agentic attempts—so the redundancy is actually helpful. But from the data system perspective it's wasted work.
>
> An agent-first data system can exploit such properties to help agents make progress faster. It can reuse results across overlapping sub-plans, drawing on ideas from decades-old literature on [multi-query optimization](https://dl.acm.org/doi/10.1145/42201.42203) and [shared scans](https://www.vldb.org/conf/2007/papers/research/p723-zukowski.pdf). Or the data system can try to _satisfice_, returning approximate answers that are good enough for agents to make progress, leveraging work from [the](https://dl.acm.org/doi/10.1145/253260.253291) [AQP](https://dl.acm.org/doi/10.1145/2465351.2465355) [literature](https://dl.acm.org/doi/10.1561/1900000004)—or streaming the results of the final or intermediate operators to help agents decide if seeing the rest is necessary or helpful.
>
> Another opportunity here is to rethink the query interface entirely: instead of agents issuing a single SQL query at a time, they could instead issue a batch of queries, each with its own approximation requirements. Since enumerating an exponential search space (as in the root cause or cohort analysis examples above) isn't a good use of agentic reasoning ability, perhaps data systems should support higher-level primitives rather than requiring agents to list each SQL query explicitly. One idea here is to draw on [DBT-style Jinja macros](https://docs.getdbt.com/docs/build/jinja-macros) to provide looping-based primitives for agents to interact with data systems.
>
> *A Caffeinated Army of Agents Ready to Tirelessly Complete Your Data Tasks*
> ![[bair-freeintel-004.png]]
>
> A final opportunity here is to stop thinking of data systems as passive executors of queries; data systems could be [proactive](https://arxiv.org/abs/2502.13016), as they possess more grounding in data and system characteristics that agents may lack a priori—they could steer agents in different directions, provide results for related queries, and also provide performance-level feedback (e.g., instead of executing an expensive query, the system could first provide the agent a latency estimate). The reason we can do this now as opposed to the past is that an agent can accept any form of textual feedback and isn't expecting a strict SQL query result. In fact, the data system could also prepare both materialized and virtual views for an agent in advance, provided to the agent as part of context, as this may be cheaper or more effective than having an agent author or use them.
>
> ## Data Systems Of Agents
>
> Previously, we focused on how agents interact with data systems. Now, we consider everything else agents need to keep working: where they live, how they remember, how they coordinate with each other, and how they deal with failures of each other. This _agentic substrate_ is separate from the inference stack powering raw intelligence. However, the inference stack itself is being abstracted away through APIs (e.g., from OpenAI or Anthropic), or, for open-weight models, through [serving](https://github.com/vllm-project/vllm) [frameworks](https://github.com/sgl-project/sglang) that hide low-level details. So far, the agentic substrate has been managed through harnesses like [Claude Code](https://www.anthropic.com/claude-code) and [Codex](https://github.com/openai/codex), coupled with various mechanisms to [store](https://mem0.ai/) and [retrieve](https://www.letta.com/) memory.
>
> First, on the memory front, the current wisdom is that [files](https://www.amplifypartners.com/blog-posts/file-systems-for-agents) [are all you need](https://lsvp.com/stories/filesystemsforagents/); agents write to unstructured markdown (MD) files, which can then be searched using grep, or via embedding-based retrieval. In fact, many argue that the solution to continual learning is having agents consume a lot (e.g., an entire codebase, slack, company wikis, …) and then write their learnings into MD files, which are then retrieved selectively on demand. Indeed, file systems, bash scripting, and MD files are and will still be important for agents. However, at scale, when agents are doing the vast majority of knowledge work, this approach will no longer be effective.
>
> Given limited context windows, retrieving all MD file fragments that may be relevant and stuffing it into the context will break down at some point. Even if context windows continue to grow, there are latency benefits to not put all information into context — and in many cases, e.g., when knowledge work involves interacting with large databases or code bases, it will be infeasible to serialize all relevant data into context.
>
> *Data Systems As A Substrate for Multi-Agent Swarms*
> ![[bair-freeintel-005.png]]
>
> One could use a [knowledge](https://mem0.ai/) [graph](https://www.getzep.com/) [representation](https://langchain-ai.github.io/langmem/), but knowledge graphs suffer from the same limitations as unstructured MD-based memory due to their lack of structured search. What one needs is to be able to retrieve only memory that is pertinent to the task, across multiple attributes (or facets) of interest. For example, an agent debugging a flaky test should be able to pull only the memories tagged with the relevant module, language, framework, and failure mode—rather retrieving based on keywords or embedding similarity. A separate issue is what to actually retrieve; raw agent traces with mistakes are not very useful as they will induce agents to repeat the same mistake—instead, we want the retrieved memory to be corrective.
>
> We recently explored a related notion of [_structured memory_](https://arxiv.org/abs/2602.13521), where we organize memory across various attributes, each of which could be set as `*` to indicate universal applicability, or set as a list of values to be matched. For a data agent, the dimensions could include the columns and tables, type of operation, and finally, open-ended natural-language corrective instructions. So, we could include memory that only applies to a given type of operation (e.g., 'when performing date-time operations, use fiscal year as opposed to calendar year conventions'), or a given table (e.g., 'column product\_cleaned is preferred over column product when querying on product name'). One open question is defining an _application-specific structured memory_—or what others have called [world models for memory](https://www.linkedin.com/feed/update/urn:li:activity:7467499112523804672/). We believe this is akin to defining a schema for each application—and perhaps agents themselves can help us define and refine it over time.
>
> *One Possible Way To Store and Retrieve Structured Knowledge ([From Here](https://arxiv.org/abs/2602.13521))*
> ![[bair-freeintel-006.png]]
>
> Structured memory will be useful also for [evolutionary](https://github.com/skydiscover-ai/skydiscover) [frameworks](https://arxiv.org/abs/2506.13131) to effectively manage search spaces. Indeed, storing, structuring, and mining large volumes of single and [multi-agent traces](https://sky.cs.berkeley.edu/project/mast/) can help future agents become much more efficient—potentially enabling effective recursive self-improvement through structured memory-based mechanisms.
>
> Another challenge is to support concurrent edits to shared memory, and concurrent edits in general, when there are many agents performing transformations. While there have been some useful attempts at [supporting](https://dl.acm.org/doi/10.1145/3702634.3702955) [multiversioning](https://neon.com/docs/get-started/why-neon) and [copy-on-write semantics](https://docs.turso.tech/agentfs/introduction), it isn't clear that such techniques will suffice when thousands of agents are attempting to edit shared state at the same time. For instance, when agents are trying various potential transactions in response to a user request, the effects of the vast majority of these transactions need to be rolled back—with only the one 'correct' transaction's result persisting. Work on supporting exactly-once semantics is relevant here, as are underlying techniques based on CRDTs and operational transformation. For updates to fuzzy mechanisms such as memory, we may be able to sacrifice on consistency for perfect correctness in the interest of latency. While agents can reason about semantics to compensate or roll back their actions to eventually finalize most tasks, the primary challenge lies in the degree to which they step on each other's toes during the process. An important failure mode to be avoided is a form of "livelock," where incessant compensating actions prevent any meaningful progress.
>
> Beyond shared state, other concerns emerge when trying to support an army of agents, including what to do when agents fail, how agents should communicate with each other (directly or through intermediate shared state), and how we should deal with straggler agents. There have been some developments in supporting durable multi-agent execution, such as [Temporal](https://temporal.io/solutions/ai), but it remains to be seen if such solutions will apply at scale across thousands of agents. On the topic of communication, we need mechanisms to enable agents to negotiate with each other. Imagine four developer agents attempting to reach consensus on a shared schema, with distinct but overlapping objectives. In a human setting, this would involve iterative discussion and compromise; for agentic swarms, we must define the mechanisms that allow them to converge on a design that reflects the underlying goals of their respective principals. Or if agents are all requiring access to a limited resource, again communication will be necessary. It remains to be seen if this is best done via centralized coordination, or if a decentralized approach is necessary.
>
> ## Data Systems By Agents
>
> Finally, if intelligence is effectively free, then we can employ this intelligence to synthesize new data systems from scratch. Indeed, in many settings, general-purpose data systems may be overkill, as they have to support every schema, query, and hardware target. Given a workload, recent work, including [Bespoke OLAP](https://arxiv.org/abs/2603.02001) and [GenDB](https://arxiv.org/abs/2603.02081), has shown that one can use an agentic pipeline to synthesize a complete, workload-specific analytical engine—in minutes to a few hours, at a cost of a few dollars. The engines are disposable: when the workload shifts, one can simply regenerate them. Analogously, our work has shown that one can synthesize custom [key-value stores](https://arxiv.org/abs/2605.24096) from scratch, targeted to the workload. In fact, modern IDEs, such as [Kiro](https://kiro.dev/), elevate specifications for systems development to be a first-class citizen.
>
> *Agents Can Synthesize Custom Data Systems From Scratch*
> ![[bair-freeintel-007.png]]
>
> The main issue, however, is that specifications are typically imperfect, and don't cover all corner cases. Present-day agents will exploit the missing specifications to reward-hack their way to a high performance metric. In our custom key-value store work, we found that one way to alleviate this is to have auxiliary verification agents trying to generate test cases that catch the exploitation of corner cases, essentially expanding the specification. Yet another approach is to both generate a system and a proof for its correctness together, for which we have found some [early success](https://arxiv.org/abs/2605.23109), but more needs to be done to solidify the approach. Further, it remains to be seen what is the best way to solicit human-written specifications for a system—can this be done in an iterative, human-in-the-loop manner, as opposed to a one-shot, incomplete one. Indeed, human-written specifications are incomplete even for manually authored software, so one would expect that future agents that are more aligned will increasingly exercise better judgement when making design decisions.
>
> *One Possible Data System Synthesis Pipeline ([From Here](https://arxiv.org/abs/2605.24096))*
> ![[bair-freeintel-008.png]]
>
> Other questions here involve testing whether starting from a mature system (e.g., Postgres) and removing components/functionality can lead to higher performance or more user trust. Separately, is there an opportunity to make the design composable, comprising various verified components that are mixed and matched given a workload? For example, perhaps the workload hasn't changed enough for the storage layer to be updated, but perhaps the query optimizer requires changes. A perhaps more viable proposition involves employing agents coupled with proof systems to target critical parts of the code associated with formal proofs, rather than doing so for the entire system.
>
> A final opportunity here is to move away from the traditional data systems stack with clearly-defined interfaces (e.g., parser, query optimizer, storage manager, …) — that were each largely the prerogative of a single human team to manage. Instead, agents can find new ways to "blend" these components together, perhaps identifying new optimization opportunities as a result. Agents can also fill in missing gaps in functionality to make existing systems much more feature-complete, or reach feature-parity with other competing systems—or analogously, continuously refining open-source systems in response to feature requests or issues (perhaps filed by other agents!) Doing so in a way that prioritizes correctness, long-term maintenance, and human interpretability will be a challenge.
>
> ## Looking Further Ahead
>
> In the era of near-free intelligence, data systems matter more than ever. As agents take on the bulk of knowledge work, the workload for data systems will change, the substrate they need to run on will have to be built, and increasingly, they will participate in designing data systems themselves. Each of these shifts opens up a new, exciting research agenda.
>
> *Co-Evolution of Data Systems and Agents*
> ![[bair-freeintel-009.png]]
>
> Looking further out, the boundaries between agents and data systems will likely start to blur. For instance, agents may design the data systems they themselves run on, defining both the interfaces as well as the system components underneath. Both the interfaces and internals can be evolved over time by agents in a form of recursive self-improvement. There is also an opportunity to rethink data systems as a holistic source of truth for the entirety of relevant state: including raw data, memory, and coordination state, further erasing the distinctions between the data that is being queried by agents and data generated as a result of agentic activity. Finally, data systems may themselves incorporate agentic components, fundamentally evolving from passive computation engines into intelligent, proactive, self-optimizing architectures. It is hard to predict what the future may hold. We're in for a wild ride!
>
> ## Acknowledgments
>
> The perspective and ongoing work described in this post are the product of joint research and many discussions with wonderful collaborators at the [EPIC Data Lab](https://epic.berkeley.edu/), [Data Systems & Foundations](https://dsf.berkeley.edu/) group, and the broader Berkeley AI-Systems community. Thank you all!
>
> BibTex for this post:
>
> ```
> @misc{intelligence-is-free-blog,
>   title={Intelligence is Free, Now What? Data Systems for, of, and by Agents},
>   author={Aditya G. Parameswaran and Shubham Agarwal and Kerem Akillioglu and Shreya Shankar
>           and Sepanta Zeighami and Rishabh Iyer and Matei Zaharia and Alvin Cheung
>           and Natacha Crooks and Joseph Gonzalez and Joseph Hellerstein and Ion Stoica},
>   howpublished={\url{https://bair.berkeley.edu/blog/2026/07/07/intelligence-is-free-now-what/}},
>   year={2026}
> }
> ```
>
> [Original post](https://bair.berkeley.edu/blog/2026/07/07/intelligence-is-free-now-what/)
