---
created: 2026-06-16
description: "Joe Barrow (LightOn) revisits the 2013 Slow Search paper through the lens of agentic retrieval and argues that better-but-slower search beats faster-but-worse search for agents on both wall-clock and cost: every tool call pays cached LLM input cost and intermediate reasoning latency, so reducing tool-call count by improving retrieval quality (multi-stage rankers, LLM rerankers, late interaction) shortens the whole task even though each query is slower. Agents are the perfect slow searchers — infinitely patient and willing to wait for quality the human survey participants in the 2013 study would never accept."
source: "https://x.com/barrowjoseph/status/2065423284343050314"
type: post
---

## Key Takeaways

Barrow's central claim inverts the conventional latency-first framing of search infrastructure: for agentic retrieval, **per-query latency and whole-task time are different optimization targets**, and improving the first usually makes the second worse. Each tool call pays cached LLM input cost plus the generation time for the model's intermediate reasoning, so the dominant component of agentic wall-clock and dollar cost is the LLM, not the retrieval engine. A faster but lower-quality retriever forces the agent into more tool calls, each of which spends more on LLM tokens than the retriever saved. The receipt cited is the [[Reason-ModernColBERT|Reason-ModernColBERT]] result that better retrieval lifts all model sizes on [[BrowseComp-Plus enables reproducible agentic search evaluation with static corpora and verified distractors|BrowseComp-Plus]] — the same retrieval-dominant pattern documented in [[Context-1 proves agentic search can be 20B-scale and retrieval-dominant without frontier models|Context-1]] and [[Agent-ModernColBERT trains late interaction on reasoning traces to reach GPT-5 retrieval accuracy with 149M parameters|Agent-ModernColBERT]].

He places this in the lineage of Teevan et al.'s 2013 **Slow Search** paper, which asked what search would look like with no latency constraint and presciently named "search agents" as one class of consumer that could tolerate background processing while the user did other things. The 2013 user study found that only 25.5% of humans could imagine waiting for the best possible results longer than they actively searched, and 61% could not even envision a search engine that traded speed for quality — which Barrow argues drove the IR community's relentless focus on latency. Agents flip that constraint: they are infinitely patient, so the latency floor that human UX imposed is gone, and slower techniques that were evolutionary dead-ends in human search become viable. The same point Ben Clavié makes in the [bclavie/2062151045346984032 thread](https://x.com/bclavie/status/2062151045346984032) Barrow links to — IR over-rotated on engineering and scalability and under-invested in novel quality techniques.

The Pareto frontier framing is the operational lever. Higher-quality retrieval methods (multi-vector / late interaction, multi-stage rankers with LLM rerankers at the tail) sit further up-and-right on the quality-vs-latency curve, but they require more infrastructure than calling an embedding API. This is where the [[ColBERT MaxSim is a submodular facility location objective and that is why it generalizes|late-interaction submodularity result]] and the [[ColBERT-style semantic search beats grep 70 percent of the time for coding agents while using fewer tokens|ColBERT-vs-grep finding]] become economically actionable rather than just academically interesting — late interaction was already a quality win, and now the cost math also favors it because each better retrieval call saves an LLM-driven downstream call. The contrast he draws is to the [Direct Corpus Interaction (DCI) paper](https://arxiv.org/abs/2605.05242), where giving an agent grep+bash matches retrieval-quality gains but at >2x tool calls and >2x cost. DCI gets you to the same accuracy by spending LLM tokens; better retrieval gets you there by spending compute inside the retriever, which is the cheaper budget.

The throughput-not-latency variant is **hornet.dev**'s bet (run by [[Hornet tunes 100M-doc ANN search and finds instruction prefixes, graph connectivity, and quantization ceilings interact in ways benchmarks miss|@jobergum]]) — engineer the retrieval engine for the regime where agents issue parallel tool calls and subagents fan out, so throughput per machine matters more than P99 latency per query. Barrow agrees this is the right framing as parallel agent calls grow, and it generalizes the "agents aren't latency-sensitive" claim into a workload-shape claim: agents look more like batch consumers than interactive users, and retrieval engines should be co-designed for that workload. He notes in [reply to @quirogaco](https://x.com/barrowjoseph/status/2066539493469950415) that this generalizes beyond search: "there's a lot of retrieval tasks that aren't '10 blue links served instantaneously'" — production agent loops (e.g., matching tasks to incoming email) tolerate minute-scale latency budgets.

The research-agenda implication is the one that ties back to vault threads on bench saturation: if agents make slow-but-better search viable, the IR community should fund out-there slow ideas, including small cross-encoders run over the entire corpus (Daniel Fein's reply) and oblique-query approaches like [Obliq-Bench](https://jbarrow.ai/field_notes/obliq-bench/) — see [[OBLIQ-Bench shows that scalable retrievers fail to surface oblique queries that reasoning LLMs can verify|OBLIQ-Bench]] for the related vault note arguing the same point about benchmark obliqueness exposing retrieval headroom. Barrow's @zby exchange clarifies the scope: agentic search isn't *only* about multi-hop QA decomposition (which predates "agentic" framings — HotPotQA was 2018), but iterative LLM-driven search remains the best current approach to it, and the latency math he describes holds whether the agent is doing multi-hop decomposition or single-hop quality-bound retrieval.

The practical guidance Barrow gives to a reader in his [reply to @Mlbot4](https://x.com/barrowjoseph/status/2065787185924596053) is one sentence: "use a slower, better retrieval method to serve agentic queries. It'll probably reduce tool call usage, which will reduce overall wall clock time and give you better results." That is the actionable form of the thesis, and it inverts the default assumption every team starting agentic search inherits from web-search infrastructure: ship the best embedder you can afford to run, not the fastest one you can host.

## External Resources

- [Searching, Fast and Slow — full post on jbarrow.ai](https://jbarrow.ai/2026-06-12-searching-fast-and-slow/) — fully formatted version with all charts
- [Joe Barrow's notes on the 2013 Slow Search paper](https://jbarrow.ai/field_notes/slow-search/) — the historical anchor for the argument
- [Teevan et al., "Slow Search: Information retrieval without time constraints" (2013, HCIR)](https://www.microsoft.com/en-us/research/publication/slow-search-information-retrieval-without-time-constraints/) — original paper proposing latency-relaxed search and (presciently) search agents
- [Reason-ModernColBERT (LightOnAI, HuggingFace)](https://huggingface.co/lightonai/Reason-ModernColBERT) — better-retrieval-lifts-all-models result on BrowseComp-Plus
- [Direct Corpus Interaction (DCI) paper, arXiv 2605.05242](https://arxiv.org/abs/2605.05242) — Li et al., grep+bash agent retrieval baseline used as the >2x-cost counter-example
- [hornet.dev](https://hornet.dev) / [@HornetDev](https://x.com/HornetDev) — Jo Bergum's throughput-first agent-retrieval engine
- [Ben Clavié mini-essay](https://x.com/bclavie/status/2062151045346984032) — IR community over-invests in engineering vs novel quality techniques
- [Obliq-Bench (Barrow field notes)](https://jbarrow.ai/field_notes/obliq-bench/) — oblique-query benchmark cited as a slow-search research target
- [HotPotQA paper (2018)](https://arxiv.org/abs/1809.09600) — multi-hop QA reference Barrow cites in his exchange with @zby

## Related Vault Notes

- [[Agent-ModernColBERT trains late interaction on reasoning traces to reach GPT-5 retrieval accuracy with 149M parameters|Agent-ModernColBERT]] — direct realization of "better retrieval → fewer LLM calls" on BrowseComp-Plus, 149M params
- [[Context-1 proves agentic search can be 20B-scale and retrieval-dominant without frontier models|Context-1]] — retrieval-dominant 20B agent showing the same retrieval-quality-over-frontier-LLM pattern
- [[Harness-1 offloads search bookkeeping into a stateful harness so a 20B RL policy beats frontier searchers on curated recall|Harness-1]] — successor that pushes the same retrieval-dominant thesis through stateful harness design
- [[BrowseComp-Plus enables reproducible agentic search evaluation with static corpora and verified distractors|BrowseComp-Plus]] — the benchmark Barrow uses to demonstrate retrieval lifting all model sizes
- [[ColBERT-style semantic search beats grep 70 percent of the time for coding agents while using fewer tokens|ColBERT vs grep]] — quality-wins-with-fewer-tokens evidence cited as the early version of the same argument
- [[ColBERT MaxSim is a submodular facility location objective and that is why it generalizes|ColBERT MaxSim as facility location]] — theoretical grounding for why late interaction stays Pareto-optimal at higher latency
- [[Hornet tunes 100M-doc ANN search and finds instruction prefixes, graph connectivity, and quantization ceilings interact in ways benchmarks miss|Hornet ANN tuning]] — Jo Bergum's throughput-first work referenced directly in the post
- [[OBLIQ-Bench shows that scalable retrievers fail to surface oblique queries that reasoning LLMs can verify|OBLIQ-Bench]] — adjacent argument: benchmark saturation hides retrieval headroom that slow methods could capture
- [[on-policy distillation plus conditional log-penalty RL cuts search agent latency 44 percent while boosting accuracy|on-policy distillation cuts search latency]] — alternative lever: train the agent to issue fewer tool calls rather than make each one slower-better
- [[searching more and thinking less improves agentic efficiency and generalization|searching more, thinking less]] — complementary finding on the agent-side of the tool-call vs reasoning-tokens trade-off
- [[Entire's pgr proves definition-first ranking helps coding agents more than faster ripgrep|Entire's pgr]] — code-search instance of "better ranking beats faster grep" for agents

> [!quote]- Original Content — X Article + Thread
>
> **@barrowjoseph (Joe Barrow)** — Jun 12, 2026 13:17 UTC · 168 likes · 15 retweets · 5 replies
> *Source: <https://x.com/barrowjoseph/status/2065423284343050314>*
>
> ## 📰 Searching, Fast and Slow
>
> ### Revisiting "Slow Search" in the age of agentic retrieval.
>
> ![[barrowjoseph-050314-001.jpeg]]
>
> > TL;DR
> > Are you willing to wait even longer for better search results? Maybe not. But an agent is, and that can actually speed up agentic search. Some recent results show that doing so can actually reduce the time taken to finish the whole task [1]. In this post I want to dig into those results, and what I think the implications on search system design are.
>
> As always, [there is a fully formatted version as well](https://jbarrow.ai/2026-06-12-searching-fast-and-slow/).
>
> Agentic retrieval is largely a bet that a model executing more search steps yields a better, more informed answer. You're trading wall clock time for recall. In which case, why not lean in and trade per-query latency for even better results?
>
> There are two competing philosophies for agentic retrieval:
>
> 1. latency doesn't matter in agentic search because the user is already willing to wait, and the models themselves don't care about latency; and
>
> 2. agents are more sensitive to latency and scalability issues, because they will issue far more queries than humans ever could.
>
> I think that (1) is correct if you're focusing specifically on per-query latency, and (2) is right if you're talking about throughput and "whole task time".
>
> This debate is not new – the 2013 "Slow Search" paper poses the questions: what would search look like if we didn't care about latency, and under what circumstances would users accept that? [2] Today's debate has the added twist that the (immediate? intermediate?) search consumers are not humans.
>
> Notably, they even proposed search agents (in 2013!!) as an example of slow search, answering queries "in the background as [searchers] engage in other tasks, search-related or otherwise." ([You can read my full notes on the paper here](https://jbarrow.ai/field_notes/slow-search/); it's a delightful and very prescient paper!)
>
> ### Should Search For Agents Be Fast?
>
> For a lot of search tasks, no! Most agentic search tasks are bottlenecked on retrieval quality more than LLM quality. Consider the case of BrowseComp-Plus. Reason-ModernColBERT from LightOnAI shows that better retrieval is a rising tide that lifts all boats (model sizes):
>
> ![[barrowjoseph-050314-002.png]]
>
> As an alternative, consider the Direct Corpus Interaction (DCI) paper, where they gave an agent access to grep and bash [3]. They show a similar increase in performance, but with more than double the tool calls and double the cost.
>
> ![[barrowjoseph-050314-003.png]]
>
> For agentic retrieval, both time and cost are primarily driven by the LLM itself. Every time you call a tool, you're paying the cached input cost and waiting the generation time for the model's intermediate reasoning.
>
> So you can end up waiting longer if you use lower-latency search. And not only are you waiting longer, you're paying more for the privilege.
>
> ### Test-Time Compute in Retrieval
>
> The goal when trading off latency for quality is to reduce the amount of work it takes [for your agent to satisfy its information need]. But how do you make that trade-off? Reasoning models showed that LLMs can trade latency/compute for a higher-quality answer. Letting the model spend more tokens scales logarithmically with the accuracy of the answer on hard math/coding tasks.
>
> This trade-off also exists in retrieval. There is a Pareto frontier of retrieval quality depending on how much time/compute you're willing to spend per query:
>
> ![[barrowjoseph-050314-004.svg]]
>
> Broadly, you make that trade-off by moving to a better (and often larger) model, and by moving further up and to the right along this graph. If you're rolling your own retrieval it takes more effort to deploy a multivector approach than a single vector approach. Similarly, building a two-stage retriever with an LLM-reranker at the end requires putting the infrastructure in place for LLM inference. These are harder than calling an embedding API. There are companies today who will just handle this for you, if you'd prefer not to roll your own, though!
>
> > Aside: Why does latency trade off so cleanly for quality? It mostly has to do with the retrieval research community. Think of it like an evolutionary process whereby a slower technique can only survive by being higher quality. So most things that have stuck around, like building multi-stage rankers, push you up and to the right along this frontier.
>
> ### Trading Query Latency for Throughput
>
> Trading latency for quality is not the only trade you might consider. For instance, hornet.dev (@HornetDev, run by @jobergum) is betting that retrieval engines designed for agents should be focused on throughput rather than latency.
>
> ![[barrowjoseph-050314-005.png]]
>
> The core bet boils down to "agents issue more queries than humans and aren't as latency sensitive." Makes sense to me, especially as we see more parallel tool calls and subagents.
>
> ### We Should Do More Slow Search Research
>
> One of the interesting results from the Slow Search paper is that most people really aren't willing to wait for better results.
>
> > Only 36 (25.5%) participants could imagine waiting for the best possible results longer than they actively searched. […] The remaining 86 (61.0%) of participants had difficulty envisioning a search engine that would sacrifice speed for quality.
>
> Findings like this have driven a relentless focus on search latency in the IR community over the years. However, agents are the perfect slow searchers; they're infinitely patient, and cheaper/better to run if you can give them better results.
>
> So we as a research community should be thinking about how to satisfy this new customer. Try some out-there but slow ideas! Maybe you can solve [Obliq-Bench](https://jbarrow.ai/field_notes/obliq-bench/)?
>
> If this is a research area that interests you, read this mini-essay from Ben Clavié, where he argues that the IR community focuses too strongly on engineering and scalability and not enough on neat, novel ideas:
>
> <https://x.com/bclavie/status/2062151045346984032>
>
> #### References
>
> 1. Antoine Chaffin. (2025). Reason-ModernColBERT. <https://huggingface.co/lightonai/Reason-ModernColBERT>
>
> 2. Jaime Teevan, Kevyn Collins-Thompson, Ryen W White, Susan T Dumais, Yubin Kim. (2013). Slow search: Information retrieval without time constraints. Proceedings of the Symposium on Human-Computer Interaction and Information Retrieval.
>
> 3. Zhuofeng Li, Haoxiang Zhang, Cong Wei, Pan Lu, Ping Nie, Yi Lu, Yuyang Bai, Shangbin Feng, Hangxiao Zhu, Ming Zhong, others. (2026). Beyond semantic similarity: Rethinking retrieval for agentic search via direct corpus interaction. arXiv preprint arXiv:2605.05242.
>
> ---
>
> ### Thread replies
>
> **@matospiso** — Jun 12, 2026 13:56 UTC
> *<https://x.com/matospiso/status/2065433080853148051>*
>
> > Interesting analysis, but I'm wondering how the increased cost of waiting for slower search results would plug into the equation. What I mean is that while the agents don't really care about waiting, it's only waiting in because there's more work to be done in the search system which means more cost on the provider side which most likely means higher bill for the customer. Is this a separate concern or would you say going the Hornet strategy (higher throughput) would actually address this as well?
>
> **@barrowjoseph (Joe Barrow)** — Jun 12, 2026 14:10 UTC
> *<https://x.com/barrowjoseph/status/2065436640424706053>*
>
> > @matospiso good question — imo llm inference for the agent is and will remain the largest cost, up to and including modern llm rerankers (which are typically smaller models).
>
> ---
>
> **@zby (Zbigniew Lukasiak)** — Jun 13, 2026 07:24 UTC
> *<https://x.com/zby/status/2065696718985842800>*
>
> > "Agentic retrieval is largely a bet that a model executing more search steps yields a better, more informed answer." - this is slightly underselling agentic search - the point about agentic search is that to find the information you often need to make a semantic step that cannot be done be a search engine alone (even a semantic search engine which limits the "semantic" part to very short sequences). For example take a question like "how many people lived in the town where a famous person was born?" To answer it you need to execute two searches, first what was the town, second how many people lived there.
>
> **@barrowjoseph (Joe Barrow)** — Jun 13, 2026 13:22 UTC
> *<https://x.com/barrowjoseph/status/2065786793782341850>*
>
> > @zby Fair, but people have been working on multi-hop QA before we had current "agentic search." E.g., HotPotQA was a 2018 paper.
> >
> > Iterative search with an LLM is one way to solve multi-hop QA (and the current best way, even), but not the only way.
>
> ---
>
> **@Mlbot4 (Gassel)** — Jun 13, 2026 10:59 UTC
> *<https://x.com/Mlbot4/status/2065750802174537764>*
>
> > @barrowjoseph I read it but couldn't get your point. What's the takeaway?
>
> **@barrowjoseph (Joe Barrow)** — Jun 13, 2026 13:23 UTC
> *<https://x.com/barrowjoseph/status/2065787185924596053>*
>
> > @Mlbot4 You should think about using a slower, better retrieval method to serve agentic queries. It'll probably reduce tool call usage, which will reduce overall wall clock time and give you better results.
>
> ---
>
> **@quirogaco (Juan Carlos)** — Jun 15, 2026 15:04 UTC
> *<https://x.com/quirogaco/status/2066537267502448740>*
>
> > @barrowjoseph In many production systems—for example, when matching tasks to an incoming email—a delay of a few minutes between the mailbox and the user's processing queue is acceptable; not everything requires an instant response.
>
> **@barrowjoseph (Joe Barrow)** — Jun 15, 2026 15:13 UTC
> *<https://x.com/barrowjoseph/status/2066539493469950415>*
>
> > @quirogaco Yeah makes sense — definitely agree that there's a lot of retrieval tasks that aren't "10 blue links, served instantaneously"
>
> ---
>
> **@DanielFein7 (Daniel Fein)** — Jun 15, 2026 17:15 UTC
> *<https://x.com/DanielFein7/status/2066570333080158451>*
>
> > @barrowjoseph Totally agree, there are some queries (see Obliq-bench) where it may make sense to run a small cross encoder over all of the documents eventually
