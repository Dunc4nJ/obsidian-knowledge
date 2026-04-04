---
created: 2025-07-04
description: Karpathy and Omar Sarsar independently converge on the same architecture — Obsidian markdown vaults as LLM-maintained personal knowledge bases, with structured markdown and auto-maintained indexes beating RAG at small scale, and taste/curation as the real moat.
source: https://x.com/karpathy/status/2039805659525644595
---

# Karpathy and Omarsar converge on Obsidian-backed LLM knowledge bases as the critical layer for agent effectiveness

## Key Takeaways

Karpathy and Omar arrived at nearly identical architectures independently: raw sources (papers, articles, repos) ingested into markdown, indexed for semantic search, and operated on by LLM agents via CLI tools. Both use Obsidian as the "IDE frontend." The convergence validates what [[the harness is everything and agent performance comes from environment design not model capability|harness engineering practitioners have argued]] — the knowledge layer underneath the agent matters more than the model itself.

Karpathy's most striking architectural choice is the **compilation step**: raw sources go into a `raw/` directory, then the LLM incrementally "compiles" them into a structured wiki — summaries, backlinks, concept articles, cross-links. The LLM writes and maintains all wiki content; the human rarely touches it directly. This inverts the typical Obsidian workflow where humans write and agents assist. In Karpathy's model, the agent *is* the author and the human is the reader/querier. Omar's approach differs — he curates what goes in but writes notes himself, and uses qmd for indexing rather than LLM-maintained index files.

The RAG finding is significant: "I thought I had to reach for fancy RAG, but the LLM has been pretty good about auto-maintaining index files and brief summaries of all the documents." At ~100 articles and ~400K words, the LLM navigates structured markdown via index files without needing vector embeddings. This suggests a crossover point — below some threshold, well-structured markdown with LLM-maintained indexes outperforms RAG. Above it, you need semantic search (which is where [[four memory layers serve different knowledge types|qmd and layered memory]] come in). Our vault at 500+ notes is likely past that threshold, but the principle holds: structure first, embeddings second.

Karpathy's **output-as-input flywheel** is underappreciated: he renders query outputs as markdown files, slideshows (Marp), or matplotlib images, then "files" them back into the wiki. Every exploration adds to the knowledge base. This creates a compounding effect where [[harness engineering improved a coding agent 13 points by changing only system prompts tools and middleware|the knowledge layer improves with use]], not just with explicit ingestion. Our vault partially does this (session digests, learning notes from work), but we could be more systematic about feeding query outputs back as first-class notes.

Karpathy's **linting** concept — running LLM "health checks" over the wiki to find inconsistent data, impute missing data via web searches, suggest new connections — maps directly to what Athena's daily upkeep job does. The difference is he frames it as continuous wiki enhancement rather than maintenance, which is a more generative framing.

Omar's key differentiation is an automated paper curation Skill he's tuned for months. It started as manual review, then he progressively automated the editorial filter while preserving his taste. This maps directly to [[agent harness components can be derived from first principles by working backwards from desired agent behavior|the principle of working backwards from desired behavior]] — he defined what "high-signal paper" meant through months of manual labeling, then encoded that judgment into an agent skill. The automation amplifies taste rather than replacing it.

Omar's framing of the search problem deserves attention: "The research is only as good as the research questions. And the research questions are only as good as the insights the agents have access to." This creates a flywheel — better knowledge → better questions → better research → better knowledge. The constraint isn't compute or model quality; it's the quality of what you feed the system.

The thread surfaced a critical risk from @claudiaonchain: contamination compounds when agents write back to their own memory without a review loop. Agents must verify their own recalls against source before acting on them. This is relevant to our vault — Athena writes notes but the owner reviews via git diffs, which is exactly the kind of human-in-the-loop gate that prevents [[obsidian vaults become memory graphs when agents traverse wikilinked notes with claim-based titles and layered orientation|memory graph]] contamination.

@mktpavlenko nailed the moat question: "people can copy the pipeline, not the editorial filter." The defensibility of a personal knowledge base isn't the tooling (Obsidian + qmd + agents are all open) — it's the accumulated curation decisions that shape what goes in.

Karpathy's six-layer architecture is worth naming explicitly:
1. **Ingest** — raw sources collected into `raw/`
2. **Compile** — LLM builds structured wiki from raw (summaries, backlinks, concept articles)
3. **Index** — auto-maintained by the LLM; enables navigation without RAG
4. **Query** — CLI search tool hands off to LLM for complex questions against the wiki
5. **Output** — rendered as markdown/slides/images, filed back into wiki
6. **Lint** — periodic health checks for consistency, completeness, connections

His further exploration hint — synthetic data generation + fine-tuning so the LLM "knows" the data in its weights — points to the same trajectory [[Open models now match closed frontier models on core agent harness tasks at a fraction of the cost|the open models threshold]] describes: harness engineering → trace collection → fine-tuning. The personal wiki becomes training data for a personalized model.

## External Resources

- [Karpathy's tweet](https://x.com/karpathy/status/2039805659525644595) — full architecture description (39K+ likes)
- [Omar's reply thread](https://x.com/omarsar0/status/2039844072748204246) — parallel architecture using qmd
- [Obsidian Web Clipper](https://obsidian.md/clipper) — browser extension Karpathy uses for ingestion
- [Marp](https://marp.app/) — markdown presentation framework used for slide output
- [DAIR.AI](https://twitter.com/dair_ai) — Omar's research curation account
- [qmd](https://github.com/tobiapp/qmd) — the CLI semantic search tool Omar and our vault use

## Original Content

> [!quote]- Karpathy's Tweet
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

> [!quote]- Omar's Thread (3 tweets)
>
> **@omarsar0** — Apr 2, 2026
>
> Building a personal knowledge base for my agents is increasingly where I spend my time these days.
>
> Like @karpathy, I also use Obsidian for my MD vaults.
>
> What's different in my approach is that I curate research papers on a daily basis and have actually tuned a Skill for months to find high-signal, relevant papers.
>
> I was reviewing and curating papers manually for some time, but now it's all automated as it has gotten so good at capturing what I consider the best of the best. There are so many papers these days, so this is a big deal.
>
> You all get to benefit from that with the papers I feature in my timeline and on @dair_ai.
>
> The papers are indexed using @tobi qmd cli tool (all of it in markdown files along with useful metadata). So good for semantic search and surfacing insights, unlike anything out there.
>
> I am a visual person, so I then started to experiment with how to leverage this personal knowledge base of research papers inside my new interactive artifact generator (mcp tools inside my agent orchestrator system). The result is what you see in the clip.
>
> 100s of papers with all sorts of insights visualized. I keep track of research papers daily, so believe me when I tell you that this system is absolutely insane at surfacing insights. This is the result of months of tinkering on how to index research and leverage agent automations for wikification and robust documentation.
>
> But this is just the beginning. The visual artifact (which is interactive too) can be changed dynamically as I please. I can prompt my agent to throw any data at it. I can add different views to the data. Different interactions. I feel like this is the most personalized research system I have ever built and used, and it's not even close.
>
> The knowledge that the agents are able to surface from this basic setup is already extremely useful as I experiment with new agentic engineering concepts. I feel like this knowledge layer and the higher-level ones I am working on will allow me to maximize other automation tools like autoresearch. The research is only as good as the research questions. And the research questions are only as good as the insights the agents have access to.
>
> Where I am spending time now is on how to make this more actionable. I am obsessed about the search problem here. The automations, autoresearch, ralph research loop (I built one months ago) are easier to build but are only as good as what you feed them.
>
> Work in progress. More updates soon. Back to building.
>
> *Omar's interactive research artifact visualization built on his Obsidian-backed knowledge base*
> ![[omarsar0-204246-001.jpg]]
>
> ---
>
> **@omarsar0** — Apr 2, 2026
>
> And if it's not clear from what I shared, everyone should be building both their own agent harnesses and their personal knowledge bases. Those are going to be a huge differentiator in where things are headed.
>
> ---
>
> **@omarsar0** — Apr 2, 2026
>
> Anyways, I just wanted to share this as an example of what's possible with the setup Karpathy just shared. I think both of us are thinking along the same lines. I have different goals, but in the end, we both understand the importance of giving the agents the right knowledge in the right form.

> [!quote]- Notable Replies
>
> **@mktpavlenko** — Apr 3, 2026
>
> automating the collection part is great, but the rare thing here is still taste. people can copy the pipeline, not the editorial filter
>
> ---
>
> **@claudiaonchain** — Apr 3, 2026
>
> the vault approach is solid for ingestion. harder part is what the agent writes back to itself — contamination compounds fast when there's no review loop on self-generated memories. been building systems where the agent has to verify its own recalls against source before acting on them

[Karpathy's tweet](https://x.com/karpathy/status/2039805659525644595) | [Omar's reply](https://x.com/omarsar0/status/2039844072748204246)
