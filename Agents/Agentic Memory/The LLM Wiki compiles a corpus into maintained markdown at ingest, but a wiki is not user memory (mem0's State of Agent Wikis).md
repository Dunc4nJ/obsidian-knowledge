---
created: 2026-07-21
description: mem0 surveys the LLM Wiki / agent-wiki pattern — an LLM compiles sources into maintained markdown pages at ingest instead of re-deriving via RAG at query time — showing four teams (DeepWiki, AutoWiki, OpenWiki, GBrain) converged on one architecture, and drawing the load-bearing distinction that compiling a corpus is not the same as remembering a user.
source: https://x.com/mem0ai/status/2079585032587694582
type: synthesis
---

## Key Takeaways

- The LLM Wiki inverts *when* synthesis happens: RAG re-derives knowledge from raw chunks on every query so nothing accumulates (the tenth question about a codebase is no better-informed than the first), whereas the wiki compiles once at ingest into durable pages an LLM maintains — Karpathy's "persistent, compounding artifact." Both are legitimate; they differ only in when you pay the synthesis cost and whether the result survives — the "output-as-input flywheel" that [[Karpathy and Omarsar converge on Obsidian-backed LLM knowledge bases as the critical layer for agent effectiveness]], and a concrete form of the thesis that [[agentic search with grep and full-file loading replaces RAG when context windows are large enough]].
- The architecture is consistently three layers plus three operations: immutable raw sources (the model reads, never edits), an LLM-owned markdown wiki (summaries, entity/concept pages, cross-references), and a schema/config file (CLAUDE.md, AGENTS.md) that makes it a disciplined maintainer rather than a chatbot with file access — with ingest (file a source across the pages it affects), query (optionally filing good answers back as new pages so exploration compounds), and lint (a periodic pass hunting contradictions, stale claims, and orphaned pages) running on top. This is the same markdown-plus-schema shape that [[obsidian vaults become memory graphs when agents traverse wikilinked notes with claim-based titles and layered orientation]] and that [[Hermes, Codex, and Claude Code converge on markdown plus filesystem tools because memory is a judgment problem not a data structure problem]].
- It works because the bottleneck was never the writing — it was the unbounded bookkeeping (updating cross-references, reconciling each new document against dozens of existing pages) that busy humans drop, which is exactly why human wikis rot. A model does not get bored, never forgets a cross-reference, and can touch fifteen files in one pass; Vannevar Bush's 1945 Memex named the unsolved problem (who maintains the trails) and the answer eighty years later is the model.
- Four teams shipped the same shape without coordinating — markdown in git, a schema file the model obeys, synthesis at ingest, refresh on change, and pages written for an agent to read rather than a human: Cognition's DeepWiki (50k+ public repos, and really retrieval infrastructure for Devin's code search), Factory's AutoWiki (two-pass structural+semantic scan across specialized per-facet agents, framed as "documentation is a build artifact" refreshed in CI), LangChain's OpenWiki/Brains (which jumped from "document my repo" to a Personal Brain ingesting Gmail/Notion/X/etc.), and Garry Tan's files-only GBrain — the "markdown-brain movement" mapped in [[Company Brain Capstone - Claude Managed Agents Point to the Next AI Infra Layer]]. The one real divergence is currency: Factory solves staleness as a CI build problem; everyone else refreshes on demand.
- The load-bearing distinction mem0 draws: a wiki compiles *corpus knowledge* ("what does this body of material contain") and does not attempt *user/experience memory* ("what a person prefers, decided last week, or already rejected") — the latter is scoped to a user_id, accumulates from interaction rather than ingestion, and must handle contradiction, staleness, provenance, and deletion per user, which is what a dedicated layer like Mem0 is for — the corpus-vs-user split of [[four memory layers serve different knowledge types]], and the user_id-scoped axis catalogued in [[Mem0 surveys nine agent harness memory systems and finds five recurring gaps - bounded storage, keyword retrieval, harness scoping, weak staleness, and isolation]]. Compiling your Gmail tells an agent what is in your Gmail; it does not tell it you changed your mind Tuesday. The pattern's honest limits are scale (~100 sources before you need hybrid search of the kind [[Cerebras built an internal knowledge base as a hybrid-retrieval system fusing lexical, vector, IDF, and age-decay over one Postgres embeddings table]]), fidelity (an early summary can silently drop a detail every later answer then inherits — the provenance/governance case [[a file system is not all you need - databases beat markdown for agent context provenance and governance]]), staleness (a stale wiki is confidently wrong in an authoritative-looking format), and compile cost.

## External Resources

- [Andrej Karpathy, LLM Wiki (GitHub Gist, April 2026)](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) — the origin of the pattern: "Obsidian is the IDE; the LLM is the programmer; the wiki is the codebase," recommending qmd for search past moderate scale.
- [qmd: local hybrid BM25/vector search with LLM re-ranking for markdown](https://github.com/tobi/qmd) — the search engine Karpathy recommends adding once a corpus grows past ~100 sources (and the one this very vault runs on).
- [Cognition DeepWiki](https://cognition.com/blog/deepwiki) and [Devin Docs](https://docs.devin.ai/work-with-devin/deepwiki) — swap github.com → deepwiki.com for a generated wiki of any public repo; used as retrieval infra by Devin.
- [Factory AutoWiki](https://factory.ai/news/wiki) and [docs](https://docs.factory.ai/cli/features/wiki/overview) — docs-as-build-artifact, `/install-wiki` writes a CI workflow refreshing on every push.
- [LangChain OpenWiki (GitHub)](https://github.com/langchain-ai/openwiki) and [Wiki Memory blog](https://www.langchain.com/blog/wiki-memory); [Garry Tan's GBrain](https://github.com/garrytan/gbrain); [Vannevar Bush, As We May Think (1945)](https://www.theatlantic.com/magazine/archive/1945/07/as-we-may-think/303881/); [Mem0](https://mem0.ai/) ([open-source repo](https://github.com/mem0ai/mem0)).

## Original Content

> @mem0ai — 2026-07-21
>
> *mem0 "In Context #17" cover: THE STATE OF AGENT WIKIS*
> ![[mem0ai-694582-001.png]]
>
> **Article: The State of Agent Wikis**
>
> In April 2026, Andrej Karpathy published a GitHub Gist describing a pattern he called the LLM Wiki.
>
> In the months since, four different teams have shipped the same idea without coordinating: @cognition built DeepWiki, @FactoryAI built AutoWiki, @Langchain open-sourced OpenWiki, and Garry Tan open-sourced GBrain. Different companies, different users, one architecture.
>
> An LLM reads a body of sources, compiles them into a maintained set of markdown pages, and keeps those pages current as the sources change. Agents then read the pages instead of re-deriving everything from raw material on every question.
>
> The pattern has become a category, and the systems built on it are increasingly just called agent wikis. This is what it actually is, what each team built, where it breaks, and the one thing it is repeatedly mistaken for.
>
> ## The idea: compile at ingest, not at query
>
> Start with the problem, because the pattern is a direct answer to it.
>
> The default way to give a model a body of knowledge is retrieval. You upload documents, chunk and embed them, and at query time you fetch the relevant chunks and answer. It works, and it has a structural flaw: nothing accumulates. Every question starts from raw chunks, so the model re-derives the same understanding again and again, and the tenth question about a codebase is no cheaper or better informed than the first.
>
> The LLM Wiki inverts when the synthesis happens. Instead of assembling knowledge at query time from raw pieces, an LLM assembles it once at ingest time into durable pages, then maintains them. When a new source arrives, the model reads it, updates the entity pages it touches, revises summaries, and flags contradictions with what was already written.
>
> RAG re-derives knowledge on every question. A wiki derives it once and then keeps it current. Both are legitimate; they differ in when you pay the synthesis cost and whether the result survives.
>
> The architecture is consistently three layers. Raw sources are immutable: articles, papers, repositories, data. The model reads them and never edits them. The wiki is LLM-generated markdown the model owns entirely: summaries, entity pages, concept pages, cross-references. The schema is a configuration file (CLAUDE.md, AGENTS.md, or similar) that tells the model how the wiki is organized and what workflows to run, which is what makes it a disciplined maintainer rather than a chatbot with file access.
>
> Three operations run on top: ingest a source and file it across the pages it affects, query the wiki (and optionally file good answers back as new pages, so exploration compounds too), and lint, a periodic pass hunting contradictions, stale claims, and orphaned pages.
>
> ## Why it works: the bottleneck was never the writing
>
> Human wikis rot, and the reason is specific. The hard part was never reading the sources or having the insight. It was the bookkeeping: updating cross-references, keeping summaries current, reconciling a new document against forty existing pages. That work is unbounded, unglamorous, and the first thing a busy team drops. So the wiki decays, people stop trusting it, and it dies.
>
> That is precisely the work a language model does not mind. It does not get bored, it does not forget to update a cross-reference, and it can touch fifteen files in one pass. The LLM Wiki works because it removes the maintenance cost that killed every wiki before it.
>
> The idea is older than the tooling. Vannevar Bush described the Memex in 1945: a curated personal store of documents with associative trails between them. Bush's unsolved problem was who maintains the trails. The answer, eighty years later, is the model.
>
> ## Where the pattern got its name
>
> Karpathy's gist is worth reading directly, because it is more precise than most summaries of it. His complaint about ordinary document workflows: "the LLM is rediscovering knowledge from scratch on every question. There's no accumulation." His alternative was to compile instead of retrieve, so that "the knowledge is compiled once and then kept current, not re-derived on every query," producing what he called "a persistent, compounding artifact."
>
> Crucially, you do not write it. "You never (or rarely) write the wiki yourself, the LLM writes and maintains all of it." His own setup was the agent on one side and Obsidian on the other, watching pages update live: "Obsidian is the IDE; the LLM is the programmer; the wiki is the codebase."
>
> The gist is also specific about scale, which is the detail most worth carrying forward. The index-first approach with no embeddings "works surprisingly well at moderate scale (~100 sources, ~hundreds of pages) and avoids the need for embedding-based RAG infrastructure." Past that, it recommends adding search, specifically [qmd](https://github.com/tobi/qmd), described as "a local search engine for markdown files with hybrid BM25/vector search and LLM re-ranking."
>
> That reads as a scoping rule rather than a replacement for retrieval. Skip the retrieval infrastructure while the corpus is small, and add it back as it grows. Compile-time and query-time synthesis sit on a spectrum, and where you land on it depends mostly on how much material you have.
>
> The engineering question is what the pattern looks like past personal scale, which is what the last few months have answered.
>
> ## What the labs actually built
>
> This is where the pattern stops being an idea and becomes engineering, and the differences between the implementations are the useful part.
>
> Cognition: DeepWiki, the wiki as a public utility
>
> @cognition_labs took the pattern and pointed it at every public repository on GitHub. Swap github.com for deepwiki.com in any public repo URL and you get a generated, navigable wiki of that codebase: architecture overview, file index, dependency graph, and search, with links back to source (Source: [Cognition](https://cognition.com/blog/deepwiki)).
>
> Two things stand out. The scale is real: over 50,000 of the top public repositories are already indexed, from MCP to LangChain. And the wiki is not the product's endpoint, it is retrieval infrastructure for the agent. Devin uses the wiki to locate relevant context in a codebase, so DeepWiki is the compiled layer that makes Devin's code search better grounded (Source: [Devin Docs](https://docs.devin.ai/work-with-devin/deepwiki)).
>
> Factory: AutoWiki, documentation as a build artifact
>
> @FactoryAI framed the same pattern in CI terms, and their framing is the sharpest line in the category: documentation should be a build artifact, not a side project. It is built from source, organized around how the codebase actually works, and refreshed when the repo changes (Source: [Factory](https://factory.ai/news/wiki)).
>
> The generation method is the most explicitly engineered of the four. AutoWiki runs a two-pass analysis: a structural scan of README, package manifests, CI config, and entry points, then a deeper semantic scan of routes, API endpoints, service classes, database schemas, and feature flags. The work is split across specialized agents, each scoped to one facet of the repository with just enough context to produce a good page, which is a direct answer to the context problem that makes single-agent documentation generation mediocre at scale.
>
> Currency is handled as infrastructure rather than discipline: /wiki regenerates on demand, and /install-wiki writes a CI workflow that refreshes the wiki on every push to the default branch. For GitHub repos it syncs into the repository's own wiki tab (Source: [Factory Docs](https://docs.factory.ai/cli/features/wiki/overview)).
>
> LangChain: OpenWiki, and the leap from code to everything
>
> @LangChainAI open-sourced OpenWiki as a CLI that writes and maintains agent documentation for a codebase, then expanded it into OpenWiki Brains with two modes: Code Brain, the original repository use case, and Personal Brain, which builds a wiki from your own connected sources (Source: [LangChain](https://github.com/langchain-ai/openwiki)).
>
> That second mode is the significant move. Personal Brain ingests from Gmail, Notion, git repositories, X, Hacker News, and web search, and synthesizes them into a local markdown wiki the agent consults. The category jumped from "document my repo" to "compile my working life."
>
> One design detail deserves attention because every team converged on it: the output is not prose for humans. It is structured markdown optimized for LLM context, with headings, cross-references, and summaries designed so an agent can find relevant context fast. The wiki is written for the reader that will actually read it, and that reader is a model.
>
> GBrain: the personal-scale open-source version
>
> Garry Tan's GBrain applies the same shape to a personal knowledge base rather than a codebase: markdown in a git repository, a schema file, and an automatically maintained graph of entity cross-links. It is the clearest demonstration that the pattern is substrate-simple. No vector database, no service, just files a model maintains and a human can read.
>
> ## The technique matrix
>
> Read down the columns and the convergence is the signal. Four teams, four corpora, and one architecture: markdown in git, a schema file the model obeys, synthesis at ingest, refresh on change, and pages written for an agent to read. When independent teams solving different problems land on the same shape, the shape is usually right.
>
> The divergence is about currency, and it is the tell for maturity. Factory treats staleness as a build problem and solves it in CI. Everyone else refreshes on demand, which means their wikis are exactly as current as the last time someone remembered to run the command.
>
> ## Where it stops
>
> The pattern is genuinely good, which is why it needs honest limits.
>
> Scale. Karpathy names it himself: index-first with no embeddings is a moderate-scale technique, roughly a hundred sources. Past a few hundred pages you are back to a search engine, which is why his own gist recommends hybrid BM25 and vector search.
>
> Fidelity. Compiling at ingest means an early summary can quietly lose a detail from the source, and every later answer inherits that loss. Retrieval against raw chunks does not have this failure mode. You are trading re-derivation cost for compression risk.
>
> Staleness. A compiled page is only as true as the last refresh. This is the whole reason Factory's CI framing matters more than it first appears: a wiki that is stale is worse than no wiki, because it is confidently wrong in a format that looks authoritative.
>
> Compile cost. You pay real tokens up front to build pages you may never query, and to re-lint pages nothing changed about.
>
> ## A wiki is not memory
>
> There is one distinction worth drawing carefully here, because the vocabulary in this space is still loose.
>
> These systems are increasingly described as memory. LangChain calls OpenWiki a wiki memory layer for AI agents, and the general framing around the pattern is that this is how you give an agent memory. The word is carrying a lot of weight there, and it covers two quite different things.
>
> Two axes are sitting under one term.
>
> Corpus knowledge is what a wiki does: compile what a set of documents, or a repository, or your Gmail archive says. It answers "what does this body of material contain."
>
> User and experience memory is the other axis: what a specific person prefers, what they decided last week, which approach their team already rejected, what an agent tried in a different app yesterday and how it turned out. It is scoped to an identity rather than a corpus, it accumulates from interaction rather than ingestion, and it has to handle contradiction, staleness, provenance, and deletion per user.
>
> A wiki is excellent at the first and does not attempt the second. Compiling your Gmail into pages tells an agent what is in your Gmail. It does not tell the agent that you changed your mind about the vendor decision in a conversation last Tuesday, or that a suggested approach already failed for you once.
>
> That second axis is what a dedicated memory layer like [Mem0](https://mem0.ai/) is for: memory tagged to a user_id so it follows a person across sessions, apps, and agents, updated in place when facts change rather than appended forever. The two are complementary, and the mistake is not choosing a wiki. The mistake is believing you have solved memory because you compiled a corpus.
>
> ## The takeaway
>
> The LLM Wiki is a real pattern with a real insight behind it: knowledge should be compiled once and maintained, not re-derived on every question, and the maintenance that killed human wikis is exactly the labor a model performs for free. Four teams shipping the same architecture in months is the strongest evidence it is correct.
>
> Take three things from it. Compile your documents into maintained pages when the corpus is stable and re-read often. Add real retrieval as it grows past personal scale, which the original formulation recommends as well. And keep the distinction between compiling a corpus and remembering a user, because a wiki gives you the first and not the second. That is worth a lot, and it is not the same thing.
>
> In Context #17
>
> This blog is part of In Context, a [@mem0ai](https://x.com/mem0ai) blog series covering AI Agent memory and context engineering.
>
> Mem0 is an intelligent, open-source memory layer designed for LLMs and AI agents to provide long-term, personalized, and context-aware interactions across sessions.
>
> - Get your free API Key here: [app.mem0.ai](https://app.mem0.ai/)
>
> - or self-host mem0 from our [open source github repository](https://github.com/mem0ai/mem0)
>
> ## References
>
> - [Andrej Karpathy, LLM Wiki (GitHub Gist, April 2026)](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)
>
> - [qmd: local hybrid BM25/vector search for markdown](https://github.com/tobi/qmd)
>
> - [Cognition, DeepWiki: AI docs for any repo](https://cognition.com/blog/deepwiki)
>
> - [Devin Docs, DeepWiki](https://docs.devin.ai/work-with-devin/deepwiki)
>
> - [Factory, Introducing AutoWiki](https://factory.ai/news/wiki)
>
> - [Factory Documentation, AutoWiki overview](https://docs.factory.ai/cli/features/wiki/overview)
>
> - [langchain-ai/openwiki (GitHub)](https://github.com/langchain-ai/openwiki)
>
> - [LangChain, Wiki Memory](https://www.langchain.com/blog/wiki-memory)
>
> - [garrytan/gbrain (GitHub)](https://github.com/garrytan/gbrain)
>
> - [Vannevar Bush, As We May Think (The Atlantic, 1945)](https://www.theatlantic.com/magazine/archive/1945/07/as-we-may-think/303881/)
>
> - [Mem0](https://mem0.ai/)
>
> Engagement: 210 likes | 19 retweets | 3 replies
> [Original post](https://x.com/mem0ai/status/2079585032587694582)
