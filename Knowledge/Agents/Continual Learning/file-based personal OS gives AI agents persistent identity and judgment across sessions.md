---
created: 2025-07-27
description: A file-based personal operating system using markdown, YAML, and JSONL in a Git repo gives AI agents persistent context about identity, voice, goals, contacts, and episodic memory without databases or APIs.
source: https://x.com/koylanai/status/2025286163641118915
type: framework
---

# File-based personal OS gives AI agents persistent identity and judgment across sessions

## Key Takeaways

The core problem is not prompting but context: every AI conversation starts with re-explaining who you are, what you're working on, and how you write. The solution is a file-based operating system (Personal Brain OS) — 80+ files in markdown, YAML, and JSONL inside a Git repo that any AI tool can read natively. No database, no vector store, no API keys, no build step. This is the same architectural insight behind [[PARA and atomic facts give AI agents durable structured memory]], but taken further with format-specific design choices and episodic memory.

The architecture uses progressive disclosure across three levels: Level 1 is a lightweight routing file (always loaded) that tells the agent which module is relevant. Level 2 is module-specific instructions (40-100 lines each) loaded only when triggered. Level 3 is actual data (JSONL logs, YAML configs, research docs) loaded only when the task requires them. Maximum two hops to any piece of information. This directly parallels the [[progressive disclosure filters force agent selectivity over what enters context]] pattern and the recursive loading in [[skill graphs outperform single skill files by letting agents traverse linked domain knowledge on demand]].

Format choices are deliberate and functional: JSONL for logs because it's append-only (agents cannot accidentally overwrite historical data — only add lines), stream-friendly (read line by line), and every line is self-contained valid JSON. YAML for configuration because it handles hierarchical data cleanly and supports comments. Markdown for narrative because LLMs read it natively. The append-only constraint on JSONL is called out as the single most important architectural decision — the author lost three months of post engagement data early on when an agent rewrote a JSON file instead of appending.

Episodic memory is the key differentiator from typical "second brain" systems. Beyond facts, the system stores judgment via three append-only logs: `experiences.jsonl` (key moments with emotional weight scores 1-10), `decisions.jsonl` (reasoning, alternatives considered, outcomes tracked), and `failures.jsonl` (root cause and prevention steps). This lets the agent reference how the user actually thinks about tradeoffs rather than generating generic advice. The failures log is described as the most valuable — encoding pattern recognition that took real pain to acquire.

The voice system encodes identity as structured data rather than adjectives. Five attributes rated 1-10 (Formal/Casual, Serious/Playful, Technical/Simple, Reserved/Expressive, Humble/Confident), 50+ banned words across three tiers, banned openings, structural traps, and a hard limit of one em-dash per paragraph. Auto-loading skills inject voice constraints silently on every writing task, while task skills (invoked via slash commands) provide domain-specific workflows with built-in quality gates and multi-pass editing. This is [[four memory layers serve different knowledge types]] applied to creative output.

Cross-module references create a flat-file relational model: `contact_id` in interactions points to contacts, `pillar` in ideas maps to brand definitions. Modules are isolated for loading but connected for reasoning. The pre-meeting workflow chains contacts → interactions (filtered by contact_id) → todos to produce a one-page brief automatically. The personal CRM organizes contacts into four circles (inner/active/network/dormant) with different maintenance cadences and `can_help_with`/`you_can_help_with` fields for introduction matching.

Hard-won lessons: initial JSONL schemas had 15+ fields per entry (agents struggle with sparse data — cut to 8-10 essential fields). The voice guide was 1,200 lines initially and the agent would drift by paragraph four due to lost-in-middle attention degradation — restructured to front-load distinctive patterns in the first 100 lines. Module boundaries are loading decisions — splitting identity and brand into two modules cut token usage for voice-only tasks by 40%.

The framing that captures it best: "Context engineering asks what information does this AI need to make the right decision, and how do I structure that information so the model actually uses it?" The shift from optimizing individual interactions to designing information architecture.

## External Resources

- [Agent Skills for Context Engineering (GitHub)](https://github.com/muratcankoylan/Agent-Skills-for-Context-Engineering) — the open-source framework (8,000+ GitHub stars), cited in academic research alongside Anthropic
- [Muratcan Koylan (@koylanai)](https://x.com/koylanai) — Context Engineer at Sully.ai, designs context engineering systems for healthcare AI

## Original Content

> [!quote]- Full Article by @koylanai (Muratcan Koylan) — Feb 21, 2026
>
> **The File System Is the New Database: How I Built a Personal OS for AI Agents**
>
> Every AI conversation starts the same way. You explain who you are. You explain what you're working on. You paste in your style guide. You re-describe your goals. You give the same context you gave yesterday, and the day before, and the day before that. Then, 40 minutes in, the model forgets your voice and starts writing like a press release.
>
> I got tired of this. So I built a system to fix it.
>
> I call it Personal Brain OS. It's a file-based personal operating system that lives inside a Git repository. Clone it, open it in Cursor or Claude Code, and the AI assistant has everything: my voice, my brand, my goals, my contacts, my content pipeline, my research, my failures. No database, no API keys, no build step. Just 80+ files in markdown, YAML, and JSONL that both humans and language models read natively.
>
> I'm sharing the full architecture, the design decisions, and the mistakes so you can build your own version. Not a copy of mine; yours. The specific modules, the file schemas, the skill definitions will look different for your work. But the patterns transfer. The principles for structuring information for AI agents are universal. Take what fits, ignore what doesn't, and ship something that makes your AI actually useful instead of generically helpful.
>
> Here's how I built it, why the architecture decisions matter, and what I learned the hard way.
>
> ---
>
> **1) THE CORE PROBLEM: CONTEXT, NOT PROMPTS**
>
> Most people think the bottleneck with AI assistants is prompting. Write a better prompt, get a better answer. That's true for single interactions and production agent prompts. It falls apart when you want an AI to operate as you across dozens of tasks over weeks and months.
>
> The Attention Budget: Language models have a finite context window, and not all of it is created equal. This means dumping everything you know into a system prompt isn't just wasteful, it actively degrades performance. Every token you add competes for the model's attention.
>
> Our brains work similarly. When someone briefs you for 15 minutes before a meeting, you remember the first thing they said and the last thing they said. The middle blurs. Language models have the same U-shaped attention curve, except theirs is mathematically measurable. Token position affects recall probability. The newer models are getting better at this, but still, you are distracting the model from focusing on what matters most. Knowing this changes how you design information architecture for AI systems.
>
> Instead of writing one massive system prompt, I split Personal OS into 11 isolated modules. When I ask the AI to write a blog post, it loads my voice guide and brand files. When I ask it to prepare for a meeting, it loads my contact database and interaction history. The model never sees network data during a content task, and never sees content templates during a meeting prep task.
>
> Progressive Disclosure: This is the architectural pattern that makes the whole system work. Instead of loading all 80+ files at once, the system uses three levels. Level 1 is a lightweight routing file that's always loaded. It tells the AI which module is relevant. Level 2 is module-specific instructions that load only when that module is needed. Level 3 is the actual data — JSONL logs, YAML configs, research documents — loaded only when the task requires them.
>
> This mirrors how experts operate. The three levels create a funnel: broad routing, then module context, then specific data. At each step, the model has exactly what it needs and nothing more.
>
> My routing file is SKILL.md that tells the agent "this is a content task, load the brand module" or "this is a network task, load the contacts." The module instruction files (CONTENT.md, OPERATIONS.md, NETWORK.md) are 40-100 lines each, with file inventories, workflow sequences, and an instructions block with behavioural rules for that domain. Data files load last, only when needed. The AI reads contacts line by line from JSONL rather than parsing the entire file. Three levels, with a maximum of two hops to any piece of information.
>
> The Agent Instruction Hierarchy: I built three layers of instructions that scope how the AI behaves at different levels. At the repository level, CLAUDE.md is the onboarding document — every AI tool reads it first and gets the full map of the project. At the brain level, AGENT.md contains seven core rules and a decision table that maps common requests to exact action sequences. At the module level, each directory has its own instruction file with domain-specific behavioral constraints.
>
> This solves the "conflicting instructions" problem that plagues large AI projects. When everything lives in one system prompt, rules contradict each other. A content creation instruction might conflict with a networking instruction. By scoping rules to their domain, you eliminate conflicts and give the agent clear, non-overlapping guidance. The hierarchy also means you can update one module's rules without risking regression in another module's behavior.
>
> ---
>
> **2) THE FILE SYSTEM AS MEMORY**
>
> One of the most counterintuitive decisions I made: no database. No vector store. No retrieval system except Cursor or Claude Code's features. Just files on disk, versioned with Git.
>
> Format-Function Mapping: Every file format in the system was chosen for a specific reason related to how AI agents process information. JSONL for logs because it's append-only by design, stream-friendly (the agent reads line by line without parsing the entire file), and every line is self-contained valid JSON. YAML for configuration because it handles hierarchical data cleanly, supports comments, and is readable by both humans and machines without the noise of JSON brackets. Markdown for narrative because LLMs read it natively, it renders everywhere, and it produces clean diffs in Git.
>
> JSONL's append-only nature prevents a category of bugs where an agent accidentally overwrites historical data. I've seen this happen with JSON files — agent writes the whole file, loses three months of contact history. With JSONL, the agent can only add lines. Deletion is done by marking entries as "status": "archived", which preserves the full history for pattern analysis. YAML's comment support means I can annotate my goals file with context the agent reads but that doesn't pollute the data structure. And Markdown's universal rendering means my voice guide looks the same in Cursor, on GitHub, and in any browser.
>
> My system uses 11 JSONL files (posts, contacts, interactions, bookmarks, ideas, metrics, experiences, decisions, failures, engagement, meetings), 6 YAML files (goals, values, learning, circles, rhythms, heuristics), and 50+ Markdown files (voice guides, research, templates, drafts, todos). Every JSONL file starts with a schema line: {"_schema": "contact", "_version": "1.0", "_description": "..."}. The agent always knows the structure before reading the data.
>
> Episodic Memory: Most "second brain" systems store facts. Mine stores judgment as well. The memory/ module contains three append-only logs: experiences.jsonl (key moments with emotional weight scores from 1-10), decisions.jsonl (key decisions with reasoning, alternatives considered, and outcomes tracked), and failures.jsonl (what went wrong, root cause, and prevention steps).
>
> There's a difference between an AI that has your files and an AI that has your judgment. Facts tell the agent what happened. Episodic memory tells the agent what mattered, what I'd do differently, and how I think about tradeoffs. When the agent encounters a decision similar to one I've logged, it can reference my past reasoning instead of generating generic advice. The failures log is the most valuable — it encodes pattern recognition that took real pain to acquire.
>
> When I was deciding whether to accept Antler Canada's $250K investment or join Sully.ai as Context Engineer, the decision log captured both options, the reasoning for each, and the outcome. If a similar career tradeoff comes up, the agent doesn't give me generic career advice. It references how I actually think about these decisions: "Learning > Impact > Revenue > Growth" is my priority order, and "Can I touch everything? Will I learn at the edge of my capability? Do I respect the founders?" is my company-joining framework.
>
> Cross-Module References: The system uses a flat-file relational model. No database, but structured enough for agents to join data across files. contact_id in interactions.jsonl points to entries in contacts.jsonl. pillar in ideas.jsonl maps to content pillars defined in identity/brand.md. Bookmarks feed content ideas. Post metrics feed weekly reviews. The modules are isolated for loading, but connected for reasoning.
>
> Isolation without connection is just a pile of folders. The cross-references let the agent traverse the knowledge graph when needed. "Prepare for my meeting with Sarah" triggers a lookup chain: find Sarah in contacts, pull her interactions, check pending todos involving her, compile a brief. The agent follows the references across modules without loading the entire system.
>
> ---
>
> **3) THE SKILL SYSTEM: TEACHING AI HOW TO DO YOUR WORK**
>
> Files store knowledge. Skills encode process. I built Agent Skills following the Anthropic Agent Skills standard — structured instructions that tell the AI how to perform specific tasks with quality gates baked in.
>
> Auto-Loading vs. Manual Invocation: Two types of skills solve two different problems. Reference skills (voice-guide, writing-anti-patterns) set user-invocable: false in their YAML frontmatter. The agent reads the description field and injects them automatically whenever the task involves writing. I never invoke them — they activate silently, every time. Task skills (/write-blog, /topic-research, /content-workflow) set disable-model-invocation: true. The agent can't trigger them on its own. I type the slash command, and the skill becomes the agent's complete instruction set for that task.
>
> Auto-loading solves the consistency problem. I don't have to remember to say "use my voice" every time I ask for a draft. The system remembers for me. Manual invocation solves the precision problem. A research task has different quality gates than a blog post. Keeping them separate prevents the agent from conflating two different workflows.
>
> When I type /write-blog context engineering for marketing teams, five things happen automatically: the voice guide loads (how I write), the anti-patterns load (what I never write), the blog template loads (7-section structure with word count targets), the persona folder is checked for audience profiles, and the research folder is checked for existing topic research. One slash command triggers a full context assembly.
>
> The Voice System: My voice is encoded as structured data. The voice profile rates five attributes on a 1-10 scale: Formal/Casual (6), Serious/Playful (4), Technical/Simple (7), Reserved/Expressive (6), Humble/Confident (7). The anti-patterns file contains 50+ banned words across three tiers, banned openings, structural traps (forced rule of three, copula avoidance, excessive hedging), and a hard limit of one em-dash per paragraph.
>
> Most people describe their voice with adjectives: "professional but approachable." That's useless for an AI. A 7 on the Technical/Simple scale tells the model exactly where to land. The banned word list is even more powerful — it's easier to define what you're NOT than what you are.
>
> Templates as Structured Scaffolds: Five content templates define the structure for different content types. The long-form blog template has seven sections (Hook, Core Concept, Framework, Practical Application, Failure Modes, Getting Started, Closing) with word count targets per section totaling 2,000-3,500 words. The research template outputs to knowledge/research/[topic].md with a structured format: Executive Summary, Landscape Map, Core Concepts, Evidence Bank (with statistics, quotes, case studies, and papers each cited with source and date), Failure Modes, Content Opportunities, and a Sources List graded HIGH/MEDIUM/LOW on reliability.
>
> ---
>
> **4) THE OPERATING SYSTEM: HOW I ACTUALLY USE THIS DAILY**
>
> The Content Pipeline: Seven stages: Idea, Research, Outline, Draft, Edit, Publish, Promote. Ideas captured to ideas.jsonl with a scoring system — each idea rated 1-5 on alignment with positioning, unique insight, audience need, timeliness, and effort-versus-impact. Proceed if total score hits 15 or higher.
>
> The Personal CRM: Contacts organized into four circles with different maintenance cadences: inner (weekly), active (bi-weekly), network (monthly), dormant (quarterly reactivation). Each contact record has can_help_with and you_can_help_with fields that enable the introduction matching system.
>
> Automation Chains: Five scripts handle recurring workflows. The Sunday weekly review runs three scripts in sequence: metrics_snapshot.py updates the numbers, stale_contacts.py flags relationships, weekly_review.py generates a summary document with completed-versus-planned, metrics trends, and next week's priorities.
>
> ---
>
> **5) WHAT I GOT WRONG AND WHAT I'D DO DIFFERENTLY**
>
> - Over-engineered the schema first pass. Initial JSONL schemas had 15+ fields per entry. Most were empty. Agents struggle with sparse data. Cut to 8-10 essential fields.
> - The voice guide was too long at first. Version one was 1,200 lines. Agent would drift by paragraph four due to lost-in-middle attention. Restructured to front-load distinctive patterns in the first 100 lines.
> - Module boundaries matter more than you think. Identity and brand in one module meant loading entire bio when only needing banned words. Splitting cut token usage 40%.
> - Append-only is non-negotiable. Lost three months of post engagement data when an agent rewrote posts.jsonl instead of appending.
>
> ---
>
> **6) THE RESULTS AND THE PRINCIPLE BEHIND THEM**
>
> The principle: this is context engineering, not prompt engineering. Prompt engineering asks "how do I phrase this question better?" Context engineering asks "what information does this AI need to make the right decision, and how do I structure that information so the model actually uses it?"
>
> The shift is from optimizing individual interactions to designing information architecture. It's the difference between writing a good email and building a good filing system. One helps you once. The other helps you every time.
>
> The entire system fits in a Git repository. Clone it to any machine, point any AI tool at it, and the operating system is running. Zero dependencies. Full portability. And because it's Git, every change is versioned, every decision is traceable, and nothing is ever truly lost.
>
> Framework: [Agent Skills for Context Engineering](https://github.com/muratcankoylan/Agent-Skills-for-Context-Engineering)
>
> *53 likes · 4 retweets · 3 replies*

[Original thread](https://x.com/koylanai/status/2025286163641118915)
