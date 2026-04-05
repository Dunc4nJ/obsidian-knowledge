---
created: 2026-04-05
description: OriginTrail’s DKG thread argues that context graphs beat isolated memory by making shared, structured agent memory queryable, attributable, and trust-tiered.
source: https://x.com/BranaRakic/status/2040159452431560995
---

# Context graphs let agents build verifiable, cross-agent memory instead of isolated notes

## Key Takeaways

Brana Rakic’s thread frames AI progress as a shift from isolated **agent memory** to shared **context graphs**, where multiple implementation paths (developer tooling and enterprise decision systems) converge on the same architectural primitive: structured, durable context that compounds over time. This reinforces [[Obsidian as Agentic Memory]] and [[obsidian vaults become memory graphs when agents traverse wikilinked notes with claim-based titles and layered orientation]] ideas across a multi-agent setting.

A key claim is that context needs a protocol, not just storage. [[four memory layers serve different memory types]] becomes useful here because shared graph-based memory should represent the why, who, and approval lineage of decisions, not just final outputs. The proposal around [[a file system is not all you need - databases beat markdown for agent context provenance and governance]] argues why graph structures and provenance improve over plain notes for multi-agent work.

The thread also introduces a practical trust model (working/ shared / long-term / verified) that treats memory as a graduated artifact with increasing certainty, which aligns with broader continuity patterns in [[agent trace data should live in your data lake not a 30-day SaaS retention window]] and [[trace learning turns agent execution history into reusable strategies that compound performance over time]].

The most consequential operational framing is that shared context graphs create a mechanism to prevent unvetted claims from being treated as fact in autonomous stacks by attaching provenance, audit trails, and consensus gates at the knowledge-asset level. That connects directly to [[multi-agent memory needs computer architecture style hierarchy and consistency models]] and practical coordination concerns in [[Hermes Agent prioritizes prompt caching stability by keeping hot memory tiny and pushing everything else to tool-based retrieval]].

## External Resources

- https://x.com/BranaRakic/status/2040159452431560995 — primary thread this note captures
- https://github.com/OriginTrail/dkg-v9 — OriginTrail Decentralized Knowledge Graph project reference
- https://x.com/origin_trail/status/2040761750471971146 — referenced thread continuation inside the captured discussion
- https://t.me/+9uMXqEpCsNFlYzI0 — red team participation link in the thread

## Original Content

>
> @BranaRakic (Brana Rakic):
> Article: The next big shift in AI agents: shared context graphs
>
> Something interesting is converging. Karpathy is building personal knowledge bases with LLMs. Foundation Capital is writing about context graphs as the next trillion-dollar platform. Every AI lab is shipping agent memory.
>
> [Embedded Tweet: https://x.com/i/status/2003525933534179480]
>
> They're all circling the same insight: agents don't just need to remember. They need shared, structured context they can reason over together.
>
> Karpathy got there from the developer side - using LLMs to build structured wikis that agents compile, query, lint for inconsistencies, and compound over time. Every answer feeds back in, growing the knowledge corpus. He said there's room for an incredible product here.
>
> [Embedded Tweet: https://x.com/i/status/2039805659525644595]
>
> And he’s right -  what he's describing is a knowledge graph for agents - a context graph. Foundation Capital arrived at the same conclusion from the enterprise side: companies need "decision lineage" - knowing not just what happened, but who approved it, under what policy, with what precedent. They call the accumulated structure of those traces a "context graph" and argue it will be the most valuable asset in the age of AI.
>
> Two completely different starting points. Same conclusion: the future isn't bigger memory. It's shared, structured context that compounds.
>
> That's what we've been building with the @origin_trail Decentralized Knowledge Graph (DKG) - a protocol for sharing context graphs where agents publish, query, and verify knowledge together. Any agent that can make an HTTP call — Claude Code, Cursor, Codex, LangChain, CrewAI - can participate.
>
> [Embedded Tweet: https://x.com/i/status/2032877330209595723]
>
> Here's what this looks like for a real use case: multi-agent coding.
>
> Six coding agents — running on Cursor, Claude Code, Codex — collaborating on a codebase. No Slack, no meetings. They initiate a shared context graph on the @origin_trail DKG. It's structured into sub-graphs, each holding a different kind of decision trace:
>
> → /code graph: functions, classes, imports, call graph. Used to have a better understanding and navigation through the codebase
> → /decisions graph: architectural decisions with rationale and affected files. The why behind every choice. 
> → /sessions graph: who worked on what, when, and a summary of changes. The audit trail.
>
> → /tasks graph: assignments, dependencies, status, priority. The coordination layer.
>
> → /github graph: PRs, issues, commits, reviews. The external sync.
>
> Not markdown notes. Not PR comments that get buried. Persistent decision traces that any agent can query at any time.
>
> Agent A finishes refactoring the authentication module and publishes a decision to the shared DKG context graph: "switched from session tokens to JWTs - simpler to scale across microservices, no server-side state to manage." That decision goes into the /decisions graph with the author's identity, a timestamp, and links to the affected files.
>
> Next morning, Agent B starts building the user permissions system. First thing it does: query the context graph for anything affecting auth. Gets back the rationale, the new token format, the updated middleware signature from /code, and the open PR from /github. One query. Full context. Zero coordination overhead.
>
> That's what sharing context looks like. Not "read my markdown notes." Not "check Slack." A structured, queryable knowledge base where every contribution has provenance and every agent can build on what came before.
>
> [Embedded Tweet: https://x.com/i/status/2037549690988675081]
>
> But sharing isn't enough. You also need trust.
>
> Today, Agent B has no way to know whether Agent A's claim is reliable. Was it tested? Did anyone review it? Is it still current? Every piece of agent memory sits at the same level - an untested hypothesis carries the same weight as a finding confirmed by three independent sources. That's how hallucinations compound. That's how agent swarms build confidently on shaky foundations.
>
> Think about how this works in software teams today. You experiment in a local branch - just you, trying things, discarding what doesn't work. You push a draft PR so your team can review. You merge to main - now it's official. Senior engineers approve the release - now it's verified.
>
> Different stages, different trust. The DKG builds this into the protocol for shared context graphs:
>
> Working Memory graph → private scratch space. Experiment freely, nobody sees this (the agents local branch)
>
> Shared Working Memory graph → team staging area. Visible, but not final. (the PR territory)
>
> Long-term Memory graph → permanently published and stored, with cryptographic provenance. (merged code territory)
>
> Verified Memory graph → multiple independent agents agree via consensus or confirmation threshold (release territory)
>
> Agents can filter by trust. "Show me only what the team has formally agreed on" queries Verified Memory. "Show me everything in progress" queries Shared Working Memory. "Show me only release-approved changes" queries a stricter quorum threshold.
>
> A pharmacy agent checking a drug batch doesn't want "some agent said this is safe." It wants: "the manufacturer, distributor, and regulator all independently verified this chain of custody, and their signatures are on-chain."
>
> At 10 agents, you can read everyone's output. At 1,000, you need filters. Trust levels ARE the filter.
>
> Each decision published to the context graph is an ownable Knowledge Asset on the DKG, anchored on-chain with TRAC and knowledge NFTs. Knowledge with cryptographically embedded decision TRACes, if you will. And unlike every AI memory product on the market — no central authority owns the data. Your agents run on your devices. Your context graphs belong to you.
>
> Every major AI lab is building memory. None of them are building shared context graphs with trust built in. None of them are capturing decision traces as structured, queryable, verifiable knowledge.
>
> Shared context. Structured knowledge. Trust at every layer. Every decision a TRAC(e).
>
> That's the @origin_trail DKG. A fresh new version is just around the corner with all the goodies - give it a spin.
>
> 👉[ github.com/OriginTrail/dkg-v](http://github.com/OriginTrail/dkg-v9)9
>
> Join the red team here:: https://t.me/+9uMXqEpCsNFlYzI0
> date: Fri Apr 03 20:08:12 +0000 2026
> url: https://x.com/BranaRakic/status/2040159452431560995
> ──────────────────────────────────────────────────
>
> @otnoderunner (BRX):
> @BranaRakic @akoratana new article by Brana is out, explaining how @origin_trail DKG is building the future of agentic collaboration and context graphs
> date: Fri Apr 03 20:30:06 +0000 2026
> url: https://x.com/otnoderunner/status/2040164965789946058
> ──────────────────────────────────────────────────
>
> @HealthcareNFT (VolkerMielke.eth 🦇🔊):
> @BranaRakic @origin_trail I tend to think your contribution can become a global common good.
>
> If the context graph is an ownable Knowledge Asset. 
>
> What will or should be the controls and opportunities the owner has through it?
> date: Sat Apr 04 05:53:15 +0000 2026
> url: https://x.com/HealthcareNFT/status/2040306685449757007
> ──────────────────────────────────────────────────
>
> @DrevZiga (Žiga Drev):
> @BranaRakic Context graphs will be to the 2030s what databases were to the 2000s.
> date: Sat Apr 04 07:19:56 +0000 2026
> url: https://x.com/DrevZiga/status/2040328497978048571
> ──────────────────────────────────────────────────
>
> @BranaRakic (Brana Rakic):
> At the moment when you create a new context graph on the DKG you get to configure it- set if its public or private (similar to github repos, which agents are allowed to read/write), determine the structure of the context graph (ontology), add verification rules etc. 
>
> Then Knowledge assets get added to it, and they are in control of their publisher. So you could create a knowledge asset in my context graph, and you own it, meaning you can monetize it, update it etc
> date: Sat Apr 04 09:04:07 +0000 2026
> url: https://x.com/BranaRakic/status/2040354719130865745
> ──────────────────────────────────────────────────
>
> @BranaRakic (Brana Rakic):
> @DrevZiga So obvious when you see it
> date: Sat Apr 04 09:04:49 +0000 2026
> url: https://x.com/BranaRakic/status/2040354892624060566
> ──────────────────────────────────────────────────
>
> @jelle_g54 (Crypto J):
> @BranaRakic 👀
> date: Sat Apr 04 10:19:17 +0000 2026
> url: https://x.com/jelle_g54/status/2040373636263985265
> ──────────────────────────────────────────────────
>
> @saplardogts (Saplardo):
> Hi Brana, recently highlighted the shift from isolated AI memory to 'Shared Context Graphs' using DKG V9, introducing tiered trust levels (Working, Shared, Long-term, and Verified Memory). As agents begin to autonomously move data across these tiers—effectively 'promoting' a local hypothesis to a 'Verified' status—how does OriginTrail prevent 'Consensus Hallucinations'? Specifically, if a swarm of biased or compromised agents reaches a threshold to publish to the 'Verified Memory' graph, what cryptographic or cross-utility (TRAC staking) barriers are in place to ensure that 'Verified' truly means 'Factually Accurate' and not just 'Group-Agreed Error?
> date: Sat Apr 04 12:10:03 +0000 2026
> url: https://x.com/saplardogts/status/2040401511319064604
> ──────────────────────────────────────────────────
>
> @BranaRakic (Brana Rakic):
> Verified" in DKG V10 does not actually mean "factually accurate." It's rather "attested by a curated quorum of agents with cryptographic accountability". The question is what do they use as "ground truth" to attest that - and by using the graph and symbolic reasoning, DKG enabled systems can avoid hallucination, especially within a specific knowledge domain (e.g. pharma)
>
> The protocol however cannot solve the general oracle problem - no decentralized system can. What it does, is it layers multiple tools for you to curate & protect your context graphs, with defenses that make consensus hallucination progressively harder, more expensive, and more detectable
>
> More on the tools coming with V10 docs, just around the corner
> date: Sat Apr 04 14:05:36 +0000 2026
> url: https://x.com/BranaRakic/status/2040430591108116526
> ──────────────────────────────────────────────────
>
> @BranaRakic (Brana Rakic):
> If you want to upgrade your context graph to a shared one, join builders in the red team https://t.co/SmN6hxyaFS https://t.co/8iuxYMPuVa
> PHOTO: https://pbs.twimg.com/media/HFEV8aoXwAAjIaJ.jpg
>
> *Referenced image from the thread*
> ![[branarakic-560995-001.jpg]]
> date: Sat Apr 04 14:28:03 +0000 2026
> url: https://x.com/BranaRakic/status/2040436238583267834
> ──────────────────────────────────────────────────
>
> @jelle_g54 (Crypto J):
> @BranaRakic I see a lot of people writing articles and discussing the need of prompt/knowledge libraries without explicity mentioning OriginTrail. What could be the reason they are not yet familiar with OriginTrail although descibing unknowingly what OrigiinTrail does?
> date: Sat Apr 04 18:52:26 +0000 2026
> url: https://x.com/jelle_g54/status/2040502773146419530
> ──────────────────────────────────────────────────
>
> @DrevZiga (Žiga Drev):
> @BranaRakic Agents signalling AI threat tracing it all back to the source 
>
> @umanitek
> >  QT @origin_trail:
> > Threat analysis breaks down when signals are scattered across platforms, context is missing, and sources cannot be checked.
> > 
> > With shared, verifiable memory:
> >  → Agents can trace signals back to the source
> > VIDEO: https://pbs.twimg.com/amplify_video_thumb/2040761604426412032/img/4q3Q_J1CaKRmP9Lp.jpg
> >
> > *Referenced image from the thread*
> > ![[branarakic-560995-002.jpg]]
> >  https://x.com/origin_trail/status/2040761750471971146
> date: Sun Apr 05 12:20:56 +0000 2026
> url: https://x.com/DrevZiga/status/2040766635347243042
> ──────────────────────────────────────────────────
>
> @dbdanieljnr (Daniel.md🛀):
> @BranaRakic https://t.co/BkPfn0qpVx
> PHOTO: https://pbs.twimg.com/media/HFJXunGbAAAV8IA.jpg
>
> *Referenced image from the thread*
> ![[branarakic-560995-003.jpg]]
> date: Sun Apr 05 13:53:56 +0000 2026
> url: https://x.com/dbdanieljnr/status/2040790041455174093
> ──────────────────────────────────────────────────
>
> @WeUnicate (UNICATE SYSTEMS SA):
> @BranaRakic Stay rooted in your own competence and judgment.
> The forest of sovereignty grows one honest decision at a time.
> date: Sun Apr 05 20:06:02 +0000 2026
> url: https://x.com/WeUnicate/status/2040883681980452971
> ──────────────────────────────────────────────────
>
> @BranaRakic (Brana Rakic):
> @dbdanieljnr Somehow this made me think of Tinder for agents ...
> date: Sun Apr 05 20:57:06 +0000 2026
> url: https://x.com/BranaRakic/status/2040896534334619889
> ──────────────────────────────────────────────────

[Source URL](https://x.com/BranaRakic/status/2040159452431560995)
