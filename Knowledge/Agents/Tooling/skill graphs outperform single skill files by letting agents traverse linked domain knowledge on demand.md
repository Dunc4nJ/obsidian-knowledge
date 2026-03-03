---
created: 2025-07-27
description: Skill graphs are networks of wikilinked markdown skill files that let agents progressively discover and traverse deep domain knowledge instead of cramming everything into one file.
source: https://x.com/arscontexta/status/2023957499183829467
type: framework
---

# Skill graphs outperform single skill files by letting agents traverse linked domain knowledge on demand

## Key Takeaways

The core argument is that single skill files hit a ceiling: they work for simple tasks (summarizing, code review) but cannot represent deep domains like therapy, trading, or legal compliance. Skill graphs solve this by turning skills into a network of small, composable markdown files connected with wikilinks, where each node is one complete thought, technique, or claim. This is the same structural insight behind [[Obsidian as Agentic Memory]] — a folder of markdown files with wikilinks is already a knowledge graph an LLM can traverse.

The key mechanism is progressive disclosure applied recursively: index → descriptions → links → sections → full content. Most agent decisions happen before reading a single full file. Each node carries YAML frontmatter with a description the agent can scan without opening the file, and wikilinks are woven into prose so they carry semantic meaning rather than being bare references. This directly extends the [[progressive disclosure filters force agent selectivity over what enters context]] pattern of curating what context gets injected and when.

The primitives are surprisingly simple — wikilinks as prose, YAML frontmatter with descriptions, and MOCs (maps of content) to organize clusters when the graph grows. These are identical to the patterns in [[skill workflows]], but applied recursively: skills link to skills which link to skills, going as deep as the domain requires.

The practical examples are compelling: a trading skill graph (risk management → market psychology → position sizing → technical analysis, all cross-linked), a legal skill graph (contract patterns → compliance → jurisdiction → precedent chains), a company skill graph (org structure → product knowledge → processes → onboarding). None fit in one file; all work as graphs.

The index file is not a lookup table but an attention-directing entry point. It contains synthesized claims, topic MOCs, cross-domain links, and explicit gaps ("explorations needed"). The agent reads the index, understands the landscape, and follows only the links relevant to the current conversation. This matches the [[four memory layers serve different knowledge types]] insight that different knowledge structures serve different retrieval needs.

The arscontexta plugin is a concrete implementation: ~250 connected markdown files that teach an agent how to build knowledge bases (which are themselves skill graphs). It demonstrates the recursive nature — a skill graph about building skill graphs. The `/learn` and `/reduce` commands provide the workflow for populating the graph.

The framing that "skills are context engineering — curated knowledge injected where it matters" and "skill graphs are the next step" is the sharpest summary. Instead of one injection, the agent navigates a knowledge structure, pulling in exactly what the current situation requires. This is the difference between instruction-following and domain understanding.

## External Resources

- [arscontexta Claude Code plugin](https://x.com/arscontexta) — ~249-file skill graph for building knowledge systems, installable as a Claude Code plugin
- arscontexta research preset — sets up markdown folder structure, then populate with `/learn` and `/reduce`

## Original Content

> [!quote]- Full Thread by @arscontexta (Heinrich) — Feb 18, 2026
>
> **Skill Graphs > SKILL.md**
>
> people underestimate the power of structured knowledge. it enables entirely new kinds of applications
>
> right now people write skills that capture one aspect of something. a skill for summarizing, a skill for code review and so on. (often) one file with one capability
>
> thats fine for simple tasks but real depth requires something else
>
> imagine a therapy skill that provides relevant information about cognitive behavioral patterns, attachment theory, active listening techniques, emotional regulation frameworks and so on
>
> a single skill file cant hold that
>
> ---
>
> **skill graphs**
>
> a skill graph is a network of skill files connected with wikilinks
>
> instead of one big file you have many small composable pieces that reference each other. each file is one complete thought, technique or skill and wikilinks between them create a traversable graph
>
> a skill graph applies the same skill discovery pattern recursively inside the graph itself
>
> every node has a yaml description the agent can scan without reading the whole file
>
> every wiki link carries meaning because its woven into prose so the agent follows relevant paths and skips what doesnt matter
>
> progressive disclosure:
>
> > index → descriptions → links → sections → full content
>
> most decisions happen before reading a single full file
>
> ---
>
> **the primitives**
>
> you already have everything you need
>
> - wikilinks that read as prose in sentences, so they carry meaning not just references
> - yaml frontmatter with descriptions so the agent can scan without reading full files
> - MOCs (maps of content) that organize clusters of related skills into navigable sub-topics
>
> skill links to other skills which link to other skills and the graph goes as deep as the domain requires
>
> ---
>
> **arscontexta plugin**
>
> arscontexta is a skill graph that teaches your agent how to build skill graphs
>
> (okay actually its about building knowledge bases but thats the same thing...)
>
> ~250 connected markdown files that teach an agent how to build a massive knowledge base aka skill graph for you
>
> one skill file couldnt do that
>
> but things change if you build a graph of interconnected research claims (/skills) about cognitive science, zettelkasten, graph theory, agent architecture where each piece links to others, each one composable and the whole thing is traversable
>
> ---
>
> **what this enables**
>
> think about it:
>
> - a trading skill graph: risk management, market psychology, position sizing, technical analysis, each piece linked to related concepts so context flows between them
> - a legal skill graph: contract patterns, compliance requirements, jurisdiction specifics, precedent chains, all traversable from one entry point
> - a company skill graph: org structure, product knowledge, processes, onboarding context, culture, competitive landscape
>
> none of these fit in one file but all of them work as graphs
>
> ---
>
> **how to build one**
>
> the easy way: install the arscontexta claude code plugin, pick the research preset and point it at any topic
>
> it sets up the markdown folder structure for you and then you fill it with /learn and /reduce
>
> the manual way its simpler than you think
>
> a skill graph doesnt need to live in your .claude/skills/ folder. the key is an index file that tells the agent what exists and how to traverse it
>
> heres what an index looks like for a knowledge work skill graph:
>
> ```
> # knowledge-work
>
> Agents need tools for thought too. Just as Zettelkasten, evergreen notes, and memory palaces gave humans external structures to think with, agent-operated knowledge systems give agents external structures to think with.
>
> ## Synthesis
>
> Developed arguments about how the pieces fit together:
>
> - [[the system is the argument]] — philosophy with proof of work; every note, link, and MOC demonstrates the methodology it describes
> - [[coherent architecture emerges from wiki links spreading activation and small-world topology]] — the foundational triangle that answers what structure looks like, why it works, how agents navigate it, and when to reassess
> ...
>
> ## Topic MOCs
>
> The domain breaks into seven interconnected areas:
>
> - [[graph-structure]] — how wiki links, topology, and linking patterns create traversable knowledge graphs
> - [[agent-cognition]] — how agents think through external structures: traversal, sessions, attention limits
>   - [[agent-cognition-hooks]] — hook enforcement, composition, and cognitive science of automated quality
>   - [[agent-cognition-platforms]] — platform capability tiers, abstraction layers, context file architecture
> - [[discovery-retrieval]] — how descriptions, progressive disclosure, and search enable finding and loading content
> - [[processing-workflow]] — how throughput, sessions, and handoffs move work through the system
> ...
>
> ## Cross-Domain Claims
>
> - [[forced engagement produces weak connections]] — the social analog of accretion over productivity: forcing engagement for activity's sake produces shallow connections, just as accumulation without synthesis produces shallow knowledge graphs
>
> ## Explorations Needed
>
> - Missing: comparison between human and agent traversal patterns. do agents need different architectures?
> - Scaling limits: at what system size does human curation fail?
> ```
>
> the index isnt a lookup table its an entry point that points attention. the agent reads it, understands the landscape and follows the links that matter for the current conversation
>
> each linked file is a standalone methodology claim (= skill). heres what one node looks like:
>
> see how the wikilinks inside the prose tell the agent when and why to follow them
>
> an map of contents (MOCs) organize sub-topics when the graph gets larger.
>
> ---
>
> **the evolution**
>
> skills are context engineering, basically curated knowledge injected where it matters
>
> skill graphs are the next step
>
> instead of one injection the agent navigates a knowledge structure, pulling in exactly what the current situation requires
>
> this is the difference between an agent that follows instructions and an agent that understands a domain
>
> arscontexta is a claude code plugin that does this for building knowledge systems. 249 files of structured knowledge the agent traverses to derive a local knowledge system that really fits your workflow
>
> go use it and build skill graphs for everything else
>
> heinrich
>
> *4,802 likes · 461 retweets · 105 replies*

[Original thread](https://x.com/arscontexta/status/2023957499183829467)
