---
created: 2026-07-30
description: Glean co-founder Tony Gentilcore argues the industry's turn to indexing validates a principle Glean has held since 2019 — but indexing alone isn't the system. A good enterprise index must be unified & permission-aware (not per-app silos), have breadth (coverage gaps are silent) and depth (preserve entities/permissions/structure, not text blobs), and use specialized indexes (semantic/lexical/structured) per data type; and it's only one part of a "system of context" = Indexes + Graphs + Memory + Data Connectors + Tools.
source: https://x.com/tonygentilcore/status/2082480969026793647
author: "@tonygentilcore (Tony Gentilcore, Glean co-founder)"
type: article
tags: [data-agent, enterprise-search, indexing, retrieval, rag, context-engineering, knowledge-graph, agent-memory, permissions, glean]
---

## Key Takeaways

- **Indexing is necessary but not sufficient — the unit that matters is a *unified, permission-aware* index, not per-app silos.** Gentilcore reads the industry's turn to indexing as validating Glean's founding principle: access to company systems isn't enough; data must be organized, permissioned, and made relevant *before* a model can use it. "We index your data" hides huge variance — a per-application index (or limited per-source embeddings) improves retrieval within a source but leaves the model to recognize that the same customer across CRM, support tickets, call notes, and planning docs is one entity, and to reconcile results each system ranked separately. Glean normalizes content and signals across apps so relevance is prepared before the query, not reconstructed every time — the same entity-reconciliation bottleneck [[Anthropic's self-service analytics stack achieves 95% accuracy by treating the bottleneck as context and entity mapping not SQL generation|Anthropic frames as entity mapping, not SQL generation]].

- **Breadth and depth — and the silent-failure warning.** *Breadth*: does the index reach where the work happens? An index covering the wiki and support queue but not the CRM answers process questions correctly and customer questions incompletely — and the real risk is that "coverage gaps are silent. They don't produce an error message. They produce confident answers with pieces missing." *Depth*: preserve what makes each source useful — a Salesforce opportunity stays an opportunity with its fields, owner, status, permissions, and relationships intact, not flattened into a text blob. That "don't flatten structured sources into text" stance is exactly [[context agents should navigate heterogeneous sources natively instead of flattening everything into vector search]], and depth also drives ranking: authorship, views, edits, freshness, and relationships tell the system which document the company *trusts* — something semantic similarity alone cannot — while mirrored permissions still gate who sees what.

- **Different work needs different, specialized indexes — not one general-purpose vector store.** A policy doc, code repo, customer record, employee profile, and calendar event are each a distinct retrieval problem: semantic retrieval for paraphrase, *lexical/exact-match* for names, identifiers, filenames, and error messages, structured retrieval that preserves fields and relationships, and different signals again for finding an expert vs. a document. So Glean runs specialized indexes for company data, code, experts, profiles, tools, and calendars. This is the practical answer to why [[single-vector dense models have a fundamental dimension-bound ceiling on retrieval combinations|one dense vector index hits a hard ceiling]], and why hybrid/lexical retrieval stays first-class — cf. [[Cerebras built an internal knowledge base as a hybrid-retrieval system fusing lexical, vector, IDF, and age-decay over one Postgres embeddings table|hybrid lexical+vector fusion]] and the discovery-via-[[the hard problem in text-to-SQL is discovery not generation and hybrid search over existing metadata solves it|hybrid search over metadata]] lesson.

- **Token efficiency starts *before* the model reasons — a bigger context window doesn't fix weak retrieval.** By the time a question reaches the model, the system should already have found and prepared the right context, so tokens go to reasoning instead of re-sorting weak or redundant results. Glean trains custom semantic + lexical indexes on the company corpus (acronyms, product/team names, industry terms) so retrieval lands the right context on the first pass rather than making the model resolve ambiguity itself. Crucially, "a larger context window alone doesn't solve that problem — more unsorted information gives the model more to sift through, not a better understanding of what matters" — the [[chroma-context-rot|context-rot]] argument, which compounds as agents take on longer tasks where weak context at one step distorts everything after.

- **The index is a foundation, not the system: Glean's "system of context" = Indexes + Graphs + Memory + Connectors + Tools.** Retrieval is one job; an agent still must understand how information fits together, how work gets done, which tools to use, and whether the result is good. Five components reinforce each other rather than being bolted around an index: **Indexes** find relevant info (specialized + semantic/lexical/structured); **Graphs** — the Enterprise Graph over people, teams, customers, projects, content, apps, and processes, plus personal graphs — explain how it fits together; **Memory** carries learning forward across sessions (enterprise + personal), the [[learning machines turn agents from stateless tools into systems that compound knowledge across users and sessions|stateless-tool → compounding-system]] shift; **Data connectors** pick the right path per source (index vs. structured query vs. live federation); **Tools** act via native and [[code execution with MCP cuts tool token overhead 98 percent by presenting servers as filesystem APIs instead of upfront definitions|MCP-based]] actions. This "context beats raw model capability" layering is the enterprise-search analog of [[OpenAI internal data agent succeeds through six layers of context not model capability alone]], [[data agents are useless without a context layer that captures business definitions and tribal knowledge]], [[LangChain's agent-first data stack scales self-service analytics 40x by making context explicit across dbt models, a semantic layer, workspace guides, and endorsements|LangChain's five-surface context stack]], and the discipline of [[how-top-ai-companies-handle-context-engineering|enterprise context engineering]] — and the closing buyer test is not whether a vendor "has an index," but whether it has built the whole system of context.

## External Resources

- Original article: [Enterprise context starts with indexing, but it doesn't end there — @tonygentilcore](https://x.com/tonygentilcore/status/2082480969026793647)
- [Glean](https://www.glean.com/) — enterprise "work AI" / system of context (indexes, Enterprise Graph, memory, connectors, tools); building on this foundation since 2019.

## Original Content

> [!quote]- Full X Article — "Enterprise context starts with indexing, but it doesn't end there" (@tonygentilcore / Tony Gentilcore, Glean, 2026-07-29)
> Article: Enterprise context starts with indexing, but it doesn’t end there
>
> More enterprise AI vendors are turning to indexing to improve accuracy, latency, and token efficiency. That’s genuinely good news. It validates a principle @Glean has built around since our founding: giving AI access to company systems isn’t enough. Enterprise data has to be organized, permissioned, and made relevant before a model can use it well.
>
> Indexing is one of the most effective ways to get enterprise context into AI. Our customers have had the benefit of Glean’s indexing since 2019, across all their applications, and the benefits have only gotten stronger as AI takes on longer, more complex work. Of increasing importance is the role indexing plays in reducing token consumption by simplifying the retrieval of relevant context.
>
> But indexing alone isn’t the whole system. It’s one component in Glean’s system of context. Indexing makes enterprise information discoverable and relevant. Graphs map relationships so relevance reflects how the company actually works. Memory carries learning across sessions and tasks. Data connectors bring in or retrieve information through indexing, structured queries, or live federation depending on the source. Tools let AI act on that context.
>
> ## Not every index connects the enterprise
>
> “We index your data” can describe very different systems. It might mean generating limited embeddings for documents from a handful of applications or even maintaining a separate index for each source. The best indexing crosses all your enterprise applications creating a unified, permission-aware foundation that preserves entities, identities, activity, and relationships. They all get called indexes. They do not give AI the same view of the enterprise.
>
> A per-application index can improve retrieval within that source. But enterprise work rarely stays in one system. A customer may show up in the CRM, support tickets, call notes, and planning documents. If those sources remain isolated, the model still has to recognize that they refer to the same customer and reconcile results ranked separately by each system.
>
> Glean normalizes content and signals across connected applications so search and agents start from a consistent, permission-aware foundation. Relevance is prepared before the query, not reconstructed from disconnected results every time.
>
> ## An enterprise index needs breadth and depth
>
> Many vendors claim to connect to a range of key enterprise systems but counting connectors tells only part of the story. What matters is both where an index reaches and what it preserves once it gets there.
>
> Breadth: Does the index reach where the work happens?
>
> Context is only as useful as the sources it includes. An index that reaches the company wiki and support queue but stops short of the CRM may answer process questions correctly and customer questions incompletely. A greater risk that inaccuracy is that the answer may still seem complete, leading to avoidable errors. No AI system can account for a decision, relationship, or exception it never had the opportunity to find.
>
> Coverage gaps are silent. They don’t produce an error message. They produce confident answers with pieces missing.
>
> Depth: Does the index preserve what makes each source useful?
>
> A connector can retrieve text while losing the structure around it. A record may arrive without its owner, status, permissions, or relationships. A document may lose the activity and freshness signals that show whether people still rely on it.
>
> Glean indexes full text but also indexes metadata, structured entities, identities, permissions, and activity signals. A Salesforce opportunity remains an opportunity, with its fields and relationships intact, rather than becoming stored as a blob to describe those fields. Source permissions are mirrored, and updates, permission changes, and deletions are reflected as the underlying systems change.
>
> That depth also shapes ranking. Semantic similarity can show that two documents discuss the same subject. It can’t tell the system which one the company trusts. Authorship, views, edits, comments, freshness, and relationships help determine what is actually relevant, while permissions still protect sensitive data and control what each person can see.
>
> ## Different work needs different indexes
>
> Enterprise information doesn’t all look or behave the same way. A policy document, code repository, customer record, employee profile, and calendar event each present a different retrieval problem. Solving these retrieval problems quickly and efficiently becomes increasingly important as AI takes on larger, more important, and more complex tasks.
>
> Semantic retrieval helps when someone describes an idea differently from the source. Lexical retrieval is better when the exact words matter, like a name, identifier, filename, or error message. Structured records need to preserve their fields and relationships instead of being flattened into text. Finding the right expert or tool relies on different signals than the ones for finding a document.
>
> That’s why Glean doesn’t rely on one general-purpose index. It uses specialized indexes for company data, code, experts, profiles, tools, and calendars. These indexes make retrieval faster and easier, reducing the effort AI needs useful, accurate, trusted responses.
>
> ## A better index improves token efficiency and yield
>
> When source information is properly indexed, models need to do less work. Importantly, token efficiency starts before the model begins reasoning. By the time a question reaches the model, the system should already have done much of the work of finding and preparing the right context. Glean builds custom semantic and lexical indexes trained on your company's corpus, learning acronyms, product names, team names, industry terms, so retrieval finds the right context on the first pass, instead of the model having to sort through and resolve ambiguity itself.
>
> Token efficiency isn’t about chasing the lowest possible token count for the sake of it. It’s to spend tokens on reasoning instead of repeatedly sorting through weak or redundant results. A larger context window alone doesn’t solve that problem. More unsorted information gives the model more to sift through, not a better understanding of what matters.
>
> This becomes more important as agents take on longer tasks. Weak context at one step can distort everything that follows. A stronger retrieval foundation makes quality and latency more predictable and leaves more of the model’s attention for reasoning, planning, and action.
>
> In practice, better token efficiency means more of the model’s effort goes toward the task and less toward sorting through context.
>
> ## The index is the foundation for enterprise AI
>
> *Glean's "Indexed Search": a query is answered by an AI model over the Enterprise Graph (people, teams, customers, products, content, processes), which unifies and permission-scopes an index built across all connected enterprise apps:*
> ![[tonygentilcore-793647-001.png]]
>
> A strong index helps AI find the right information. But retrieval is only one part of the job. An agent still has to understand how that information fits together, how work gets done, which tools to use, and whether the result is actually good.
>
> Indexing is one part of an effective system of context
>
> That is what Glean’s system of context is built to do. Indexes, graphs, memory, data connectors, and tools each solve a different part of the context problem.
>
> - Indexes find relevant information. Glean uses specialized indexes for company data, code, experts, profiles, tools, and calendars, along with semantic, lexical, and structured retrieval suited to different kinds of information and questions.
>
> - Graphs explain how the information fits together. The Enterprise Graph connects the people, teams, customers, projects, content, applications, and processes behind the work. Personal graphs add context about how an individual works, including their tasks, preferences, projects, and patterns of activity.
>
> - Memory carries useful context forward. Enterprise memory helps agents apply what has been learned across longer-running work, while personal memory helps adapt responses and tasks to an individual over time.
>
> - Data connectors use the right path for each source. Some information is best indexed. Structured systems may be queried directly. Other sources call for federated or real-time retrieval. Glean supports each approach rather than forcing every system through the same retrieval method.
>
> - Tools let AI take action. Native and MCP-based actions allow agents to update records, send communications, and perform tasks in connected applications.
>
> These are not five independent features assembled around an index. They reinforce one another. Richer signals from connectors and tools gives the graph more entities, relationships, and relevance signals to work with. Together, the Enterprise Graph and personal graphs add context about how the company operates and how each person works within it. Memory carries that context forward, and tools turn it into action.
>
> A shallow index limits everything built on it. But even the best index can’t do the whole job.
>
> That’s the difference between adding an index and building a system of context. An index helps AI find information. Glean’s system of context helps it understand the company, act on what it knows, and learn from the work.
>
> ## What enterprises should ask next
>
> More vendors investing in indexing is a welcome shift. But an index announcement is only a starting point. Enterprises should look under the hood of the index, then beyond it.
>
> How does the index work? Does it unify information across applications or keep each source separate? Does it preserve entities, fields, identities, permissions, freshness, and activity? Does it use retrieval methods suited to different kinds of work? And how much ranking, filtering, and context preparation happens before the model starts consuming tokens?
>
> What has the vendor built beyond it? Can the system connect information through enterprise relationships, understand the person and process behind the task, carry learning forward, choose and use the right tools, and determine whether the work was completed successfully and within company policy?
>
> How does the vendor keep indexed data secure? Can the index reflect the permissions in the source systems? How does the vendor provide protection against sensitive data that may not be correctly permissioned in an organization?
>
> @Glean has been building on this foundation since 2019. The standard is not whether a vendor has an index. It’s whether it has built the system of context AI needs to understand the enterprise and finish real work.

