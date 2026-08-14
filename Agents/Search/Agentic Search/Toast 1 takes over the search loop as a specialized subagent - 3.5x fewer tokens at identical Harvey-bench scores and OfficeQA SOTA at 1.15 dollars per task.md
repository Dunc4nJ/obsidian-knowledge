---
created: 2026-08-14
description: Mixedbread launches Toast 1, a specialized search agent that fully takes over the search loop (decompose → gather → inspect → curate) as a standalone model or a subagent, matching or outperforming Claude Opus 5 / GPT-5.6 Sol at up to 10x cheaper and 12x faster. OfficeQA Pro V2 SOTA: GPT-5.6 Sol + Toast 1 in Codex hits 70% at ~$1.15/task (previous best: Fable 5 on Databricks Genie, 60% at ~$4). On Harvey's Law Firm Knowledge bench, swapping in Mixedbread Search then Toast 1 cut tokens 80.6M → 47M → 23M at identical scores. ~$0.016-0.023/query, 8s median latency, backend-agnostic.
source: https://www.mixedbread.com/blog/toast-1
author: Mixedbread Team
type: article
published: 2026-08-13
tags: [agentic-search, search-agent, subagent, retrieval, token-efficiency, evidence-curation, mixedbread, toast]
---

## Key Takeaways

- **The thesis: specialize the search loop, spend the frontier model only on reasoning.** Toast 1 fully takes over search — given a query it decomposes into subqueries, gathers evidence, inspects sources, and *curates* the relevant context before returning it — as a standalone retrieval agent or a subagent the frontier model delegates to. As metered intelligence gets pricier, "high-quality, token-efficient evidence packages" leave the generalist's context and compute for reasoning and answering. This is the productization of the vault's specialized-search-agent thread — [[Context-1 proves agentic search can be 20B-scale and retrieval-dominant without frontier models|Context-1]] (which Mixedbread explicitly cites as sibling work alongside SID-1) and [[Harness-1 offloads search bookkeeping into a stateful harness so a 20B RL policy beats frontier searchers on curated recall|Harness-1]] — and the economics of [[agents are the perfect slow searchers because LLM inference cost dominates per-query retrieval latency|agents-as-slow-searchers]] inverted into a product: make the searcher small and fast.

- **OfficeQA Pro V2 SOTA — and the previous champion was a data-agent platform.** GPT-5.6 Sol with Toast 1 as a Codex subagent reaches **70% answer correctness at ~$1.15/task** — the highest score among systems Databricks evaluated — vs the previous best, Claude Fable 5 on [[Databricks Genie pushes data agents past coding-agent baselines via specialized knowledge search, parallel thinking, and multi-LLM design|Databricks Genie]], at **60% / ~$4/task**, and GPT-5.6 Sol in Codex *without* Toast 1 at just **33%**. Same frontier model, +37pp from the search subagent alone — the evidence-gathering economics, not the reasoner, was the binding constraint.

*The cost-quality Pareto on OfficeQA Pro V2 — Codex + Toast 1 sits above and left of every Databricks-evaluated system:*
![[mixedbread-toast1-001.png]]

- **The Harvey result is the cleanest token-economics ablation in the vault: 80.6M → 47M → 23M tokens at an identical score.** On 33 tasks from Harvey LAB's Law Firm Knowledge benchmark (the eval infrastructure behind [[LangChain and Harvey show DeepSeek batch verifiers reduce legal agent evaluation costs by three orders of magnitude at acceptable accuracy|Harvey's legal-agent evals]]), answer quality stayed constant across retrieval stacks — but replacing filesystem search with Mixedbread Search cut tokens 80.6M → 47M, and adding Toast 1 as the search subagent cut them to 23M and *halved the agent's turns* (21.7 → 11.2). **3.5x fewer tokens, >60% cost reduction, same score** — search quality converts directly into frontier-context headroom, the same currency as [[BrowseComp-Plus isolates the search-agent ceiling - GPT-4.1 scores 14.6 percent finding documents with BM25 vs 93.5 percent when handed them|BrowseComp-Plus's retriever-is-the-ceiling finding]] and [[Dr-DCI caches BM25 hits into a bounded grep-able workspace, making fast corpus retrieval a harness-engineering differentiator for inference providers|Dr-DCI's harness bet]].

*3.5x fewer tokens with the same performance — vanilla agent vs +Mixedbread Search vs +Toast 1 subagent on the Harvey benchmark:*
![[mixedbread-toast1-002.png]]

- **Standalone, it's frontier-class retrieval at commodity prices — via model/harness/retrieval co-design.** On deep-search benchmarks Toast 1 stands "in the same league as GPT-5.6 Sol," comfortably above Kimi K3 and GLM-5.2, at **~$0.016-0.023/query with 8s median latency** (highest-quality fusion config: ~$0.05-0.07, 11s) — **7-11x cheaper** than similarly-performing frontier retrieval agents that took 20s-4min. It extends the co-design lineage of [[mixedbread search v3 nearly closes the oracle gap on agentic retrieval benchmarks using late-interaction multimodal encoding|Mixedbread's search v3]]: model, agent harness, and retrieval primitives designed together — though it's **backend-agnostic**, tested to remain competitive over your existing indexes without migration.

*BrowseComp-Plus quality vs cost — Toast 1 (RRF x3) at the top-left of the frontier:*
![[mixedbread-toast1-003.png]]

- **Integration is deliberately low-friction — and priced to undercut.** Chat Completions API + a "golden harness" repo; `npx skills add mixedbread-ai/skills` for coding agents; an OpenCode subagent integration; or one flag (`agentic: true`) on existing Mixedbread store searches. Launch pricing: $0.30/M input, $0.04/M cached input (cache writes free), $0.80/M output. Vendor-benchmark caveat applies as always — the OfficeQA numbers are "as reported by Databricks" for competitors but Mixedbread's own runs for Toast 1, and Toast 1 performs best on Mixedbread's own search backend.

## External Resources

- Original post: [Introducing Toast 1 — Mixedbread (2026-08-13)](https://www.mixedbread.com/blog/toast-1)
- [Toast harness (golden harness repo)](https://github.com/mixedbread-ai/toast-harness) · [Chat Completions docs](https://mixedbread.com/docs/agent/chat-completions) · [OpenCode integration](https://mixedbread.com/docs/agent/integrations/opencode) · [pricing](https://mixedbread.com/pricing#pricing-rates)
- Benchmarks: [OfficeQA Pro V2 (Databricks)](https://www.databricks.com/blog/introducing-officeqa-pro-v2-new-benchmark-enterprise-grounded-reasoning) · [Harvey LAB Law Firm Knowledge](https://www.harvey.ai/blog/legal-agent-bench-law-firm-knowledge)
- Sibling specialized search agents (cited in the post): [SID-1](https://www.sid.ai/research/sid-1) · [Chroma Context-1](https://www.trychroma.com/research/context-1)
- [Dwarkesh podcast search demo](https://dwarkesh-search-demo.vercel.app)

## Original Content

> [!quote]- Full post — "Introducing Toast 1" (Mixedbread, 2026-08-13)
> **Toast 1**, our first specialised search agent, is available today. It provides frontier search quality, matching or outperforming Claude Opus 5 and GPT-5.6 Sol while being up to 10× cheaper and 12× faster. It performs best with Mixedbread Search, but it can work with any search backend.
>
> Today, frontier models are now able to perform real knowledge work. They can reason, analyse, and find information in complex document collections. But they are also the most expensive models in the stack. As intelligence is increasingly metered, the need for specialised agents able to match their capabilities at a fraction of the cost is greater than ever.
>
> Toast 1 can run as a standalone specialized retrieval agent, or as one of many subagents your frontier model already knows how to rely on. It fully takes over the search loop: given an initial query, it decomposes it into subqueries, gathers evidence, inspects sources, and curates the relevant context before returning it. This lets your agent spend its context and compute on the task that requires a generalist, frontier-level model: reasoning, acting, and producing the final answers.
>
> *(interactive trace figure — see original post)*
>
> ## Pareto Optimal Search
>
> This specialisation of agentic labor results in considerably cheaper search, but also in better end-to-end results on many realistic tasks. We found that Toast 1 establishes a new Pareto frontier across agentic workloads across cost per task and speed per task.
>
> ### Financial Analysis: OfficeQA Pro V2
>
> OfficeQA Pro V2, [released by Databricks](https://www.databricks.com/blog/introducing-officeqa-pro-v2-new-benchmark-enterprise-grounded-reasoning), evaluates answer correctness across 90 questions in realistic, complex enterprise financial situations.
>
> GPT‑5.6 Sol with Toast 1 made available as a sub-agent within Codex reaches 70% answer correctness at approximately \$1.15 per task: that is the highest score among the systems evaluated by Databricks in the OfficeQA v2 release, establishing new state-of-the-art performance in both quality and efficiency.
>
> ![[mixedbread-toast1-001.png]]
>
> By comparison, the previous best performer, Claude Fable 5 on Databricks Genie, reaches 60% correctness at approximately \$4 per task, while GPT-5.6 Sol within Codex without Toast 1 only reaches 33% correctness.
>
> This improvement stems from reformulating the economics of evidence gathering. Toast 1's specialization allows it to produce high-quality, token-efficient evidence packages, leaving ample resources for the reasoning process to reach the final answer.
>
> ### Legal Agentic Benchmark - Firm Knowledge
>
> [Harvey LAB's Law Firm Knowledge benchmark](https://www.harvey.ai/blog/legal-agent-bench-law-firm-knowledge) seeks to evaluate how well an agent can search and use institutional legal knowledge at large, realistic scales.
>
> Legal work, by nature, is context-heavy. You cannot outargue someone with access to better, more relevant precedents and details. But it is also noisy: many situations are similar but vary by simple details, making it tricky to collect high quality evidence packages without numerous false positives.
>
> On a randomly selected subset of 33 tasks,[^1] we found that GPT-5.6 Sol's answer quality remained constant across search methods.
>
> ![[mixedbread-toast1-002.png]]
>
> [^1]: We evaluated a randomly selected subset of 33 tasks to make repeated comparative runs tractable. Every configuration used the same tasks and evaluation setup; only the retrieval stack changed.
>
> However, increasing search quality drastically increased token efficiency: replacing the vanilla agent's filesystem search with Mixedbread Search cut token usage from 80.6M to 47M at an identical task score. Subsequently adding Toast 1 as its dedicated search subagent reduced it further to 23M, and allowed it to finish in half the turns required by vanilla agent.
>
> The introduction of a Mixedbread Search-powered Toast 1 preserved answer quality, while consuming 3.5× fewer tokens, leading to a cost reduction of over 60%. Toast 1 frees up the context window of frontier models to let them spend their tokens on reaching the right answer.
>
> ## Demo: Dig Deep Into Dwarkesh's Podcast
>
> Benchmarks and numbers can only tell one part of the story. To truly understand how Toast 1 works, there is no better way than watching it search in action. At Mixedbread, we really enjoy [Dwarkesh's podcast](https://www.dwarkesh.com/), and thought being able to search deep into its transcripts would be fun.
>
> You can try it yourself [here](https://dwarkesh-search-demo.vercel.app).
>
> ## Frontier Class Retrieval
>
> Although it is a capable subagent for complex tasks, Toast 1 is also a capable standalone model, trained specifically for deep search. It represents the next step of our co-design approach behind our embedding models and Silo: the model, agent harness, and retrieval primitives are designed to work together.[^2]
>
> ![[mixedbread-toast1-003.png]]
>
> [^2]: Toast 1 is part of a growing body of work on specialised search agents, alongside [SID-1](https://www.sid.ai/research/sid-1) and Chroma's [Context-1](https://www.trychroma.com/research/context-1). While each takes a different approach, they share the goal of bringing frontier-level retrieval to production at lower cost and latency.
>
> On a variety of deep search benchmarks, it reaches frontier model performance, standing in the same league as GPT-5.6 Sol and comfortably outperforming models such as Kimi K3 or GLM-5.2.
>
> It remains lightweight in doing so. A standard Toast 1 run costs approximately $0.016 - $0.023 per query and has an eight-second median latency. Our highest-quality fusion configuration costs approximately $0.05 - $0.07 per query and has an eleven-second median latency. In practice, among the systems in our evaluation that reached similar performance, Toast 1 was 7–11× cheaper and considerably faster: Frontier-model retrieval agents took between 20 seconds and four minutes on the same evaluation.
>
> ## Availability and Pricing
>
> Toast 1 is available immediately through the Mixedbread API at the [discounted launch pricing](https://mixedbread.com/pricing#pricing-rates):
> - $0.30 per million input tokens
> - $0.04 per million cached input tokens (cache writes are free)
> - $0.80 per million output tokens
>
> Mixedbread search invoked by Toast 1 is [priced at a special rate](https://mixedbread.com/pricing#toast-1-search-rate).
>
> ### With Your Existing Retrieval Stack
>
> Toast 1 was co-designed with Mixedbread Search's primitives and will be at its strongest performance with it. But we put special care in ensuring that it remains backend agnostic: it can run over your existing retrieval indexes, and does not require migrating your existing backend. We conducted thorough testing to ensure that Toast 1 remains competitive with the performance of frontier models in similar conditions at a fraction of the cost and latency, no matter the provided index.
>
> You can use Toast 1 with our [Chat Completions API](https://mixedbread.com/docs/agent/chat-completions) and add it as a retrieval tool to your existing agentic workflows in just a few minutes. Here is a [golden harness you can use directly](https://github.com/mixedbread-ai/toast-harness).
>
> ### With Coding Agents
>
> Let your coding agents handle the integration with `npx skills add mixedbread-ai/skills`. Or use Toast 1 directly as a subagent with our [OpenCode integration](https://mixedbread.com/docs/agent/integrations/opencode).
>
> ### With Your Mixedbread Stores
>
> **Python:**
> ```python
> from mixedbread import Mixedbread
>
>     client = Mixedbread()
>
>     results = client.stores.search(
>         store_identifiers=["legal-documents"],
>         query="does the MSA allow assignment on a change of control?",
>         search_options={
>             "agentic": True,  # enable Toast 1
>         },
>     )
> ```
>
> **TypeScript:**
> ```typescript
> import { Mixedbread } from "@mixedbread/sdk";
>
>     const client = new Mixedbread();
>
>     const results = await client.stores.search({
>       store_identifiers: ["legal-documents"],
>       query: "does the MSA allow assignment on a change of control?",
>       search_options: {
>         agentic: true, // enable Toast 1
>       },
>     });
> ```
>
> [Get an API key](https://platform.mixedbread.com/platform?next=api-keys) with $5 in included credits to try it out.
