---
created: 2025-07-04
description: Andrej Karpathy describes his full architecture for LLM-maintained personal knowledge bases — raw data ingested into markdown, incrementally compiled into a wiki by the LLM, indexed and queried via CLI tools, all viewed in Obsidian. At ~100 articles / ~400K words, structured markdown with auto-maintained indexes beats fancy RAG.
source: https://x.com/karpathy/status/2039805659525644595
---

# Karpathy's LLM knowledge base architecture compiles raw sources into agent-maintained Obsidian wikis that beat RAG at small scale

## Key Takeaways

The most striking architectural choice is the **compilation step**: raw sources (articles, papers, repos, datasets, images) go into a `raw/` directory, then the LLM incrementally "compiles" them into a structured wiki — summaries, backlinks, concept articles, cross-links. The LLM writes and maintains all wiki content; the human rarely touches it directly. This inverts the typical Obsidian workflow where humans write and agents assist. In Karpathy's model, the agent *is* the author and the human is the reader/querier. This is a fundamentally different relationship to [[Omarsar and Karpathy converge on Obsidian-backed LLM knowledge bases as the critical layer for agent effectiveness|what Omar describes]] — Omar curates what goes in but writes the notes himself; Karpathy delegates the entire writing layer to the LLM.

The RAG finding is significant: "I thought I had to reach for fancy RAG, but the LLM has been pretty good about auto-maintaining index files and brief summaries of all the documents." At ~100 articles and ~400K words, the LLM navigates structured markdown via index files without needing vector embeddings or retrieval pipelines. This suggests a crossover point — below some threshold of knowledge base size, well-structured markdown with LLM-maintained indexes outperforms RAG. Above it, you'd need semantic search (which is where [[four memory layers serve different knowledge types|qmd and layered memory]] come in). Our vault at 500+ notes is likely past that threshold, but the principle holds: structure first, embeddings second.

Karpathy's **linting** concept maps directly to [[agent harness components can be derived from first principles by working backwards from desired agent behavior|first-principles harness design]]: running LLM "health checks" over the wiki to find inconsistent data, impute missing data via web searches, suggest new article candidates, and find interesting connections. This is essentially what Athena's daily upkeep job does — metadata hygiene, link weaving, dedup detection. The difference is Karpathy frames it as continuous wiki enhancement rather than maintenance, which is a more generative framing.

The **output-as-input flywheel** is underappreciated: Karpathy renders query outputs as markdown files, slideshows (Marp), or matplotlib images, then "files" them back into the wiki. Every exploration adds to the knowledge base. This creates a compounding effect — [[harness engineering improved a coding agent 13 points by changing only system prompts tools and middleware|the knowledge layer improves with use]], not just with explicit ingestion. Our vault partially does this (session digests, learning notes from work), but we could be more systematic about feeding query outputs back as first-class notes.

The **further explorations** hint at the endgame: synthetic data generation + fine-tuning so the LLM "knows" the data in its weights instead of just context windows. This is the same trajectory [[Open models now match closed frontier models on core agent harness tasks at a fraction of the cost|the open models threshold post]] describes — harness engineering → trace collection → fine-tuning. Karpathy's personal wiki becomes training data for a personalized model. At scale, this collapses the retrieval problem entirely.

His tool architecture is notable for its simplicity: Obsidian Web Clipper for ingestion, a vibe-coded search engine served as both a web UI and a CLI tool for agents, and Obsidian as a pure viewer. No frameworks, no orchestration layers, no vector databases. The search engine is "small and naive" but works because the structured markdown does the heavy lifting. This validates the [[context files beat MCP schemas for internal agents because they encode how your team actually uses each tool|context-files-over-infrastructure]] philosophy.

The six-layer architecture is worth naming explicitly:
1. **Ingest** — raw sources collected into `raw/`
2. **Compile** — LLM builds structured wiki from raw (summaries, backlinks, concept articles)
3. **Index** — auto-maintained by the LLM; enables navigation without RAG
4. **Query** — CLI search tool hands off to LLM for complex questions against the wiki
5. **Output** — rendered as markdown/slides/images, filed back into wiki
6. **Lint** — periodic health checks for consistency, completeness, connections

## External Resources

- [Original tweet](https://x.com/karpathy/status/2039805659525644595) — 39,560 likes, 4,401 retweets
- [Obsidian Web Clipper](https://obsidian.md/clipper) — browser extension Karpathy uses for ingestion
- [Marp](https://marp.app/) — markdown presentation framework used for slide output
- [Omar's response thread](https://x.com/omarsar0/status/2039844072748204246) — parallel architecture using qmd for indexing

## Original Content

> [!quote]- Karpathy's Full Tweet
>
> **@karpathy** (Andrej Karpathy) — Apr 2, 2026 — 39,560 likes, 4,401 retweets
>
> **LLM Knowledge Bases**
>
> Something I'm finding very useful recently: using LLMs to build personal knowledge bases for various topics of research interest. In this way, a large fraction of my recent token throughput is going less into manipulating code, and more into manipulating knowledge (stored as markdown and images). The latest LLMs are quite good at it. So:
>
> **Data ingest:**
> I index source documents (articles, papers, repos, datasets, images, etc.) into a raw/ directory, then I use an LLM to incrementally "compile" a wiki, which is just a collection of .md files in a directory structure. The wiki includes summaries of all the data in raw/, backlinks, and then it categorizes data into concepts, writes articles for them, and links them all. To convert web articles into .md files I like to use the Obsidian Web Clipper extension, and then I also use a hotkey to download all the related images to local so that my LLM can easily reference them.
>
> **IDE:**
> I use Obsidian as the IDE "frontend" where I can view the raw data, the compiled wiki, and the derived visualizations. Important to note that the LLM writes and maintains all of the data of the wiki, I rarely touch it directly. I've played with a few Obsidian plugins to render and view data in other ways (e.g. Marp for slides).
>
> **Q&A:**
> Where things get interesting is that once your wiki is big enough (e.g. mine on some recent research is ~100 articles and ~400K words), you can ask your LLM agent all kinds of complex questions against the wiki, and it will go off, research the answers, etc. I thought I had to reach for fancy RAG, but the LLM has been pretty good about auto-maintaining index files and brief summaries of all the documents and it reads all the important related data fairly easily at this ~small scale.
>
> **Output:**
> Instead of getting answers in text/terminal, I like to have it render markdown files for me, or slide shows (Marp format), or matplotlib images, all of which I then view again in Obsidian. You can imagine many other visual output formats depending on the query. Often, I end up "filing" the outputs back into the wiki to enhance it for further queries. So my own explorations and queries always "add up" in the knowledge base.
>
> **Linting:**
> I've run some LLM "health checks" over the wiki to e.g. find inconsistent data, impute missing data (with web searchers), find interesting connections for new article candidates, etc., to incrementally clean up the wiki and enhance its overall data integrity. The LLMs are quite good at suggesting further questions to ask and look into.
>
> **Extra tools:**
> I find myself developing additional tools to process the data, e.g. I vibe coded a small and naive search engine over the wiki, which I both use directly (in a web ui), but more often I want to hand it off to an LLM via CLI as a tool for larger queries.
>
> **Further explorations:**
> As the repo grows, the natural desire is to also think about synthetic data generation + finetuning to have your LLM "know" the data in its weights instead of just context windows.
>
> **TLDR:** raw data from a given number of sources is collected, then compiled by an LLM into a .md wiki, then operated on by various CLIs by the LLM to do Q&A and to incrementally enhance the wiki, and all of it viewable in Obsidian. You rarely ever write or edit the wiki manually, it's the domain of the LLM. I think there is room here for an incredible new product instead of a hacky collection of scripts.

[Source](https://x.com/karpathy/status/2039805659525644595)
