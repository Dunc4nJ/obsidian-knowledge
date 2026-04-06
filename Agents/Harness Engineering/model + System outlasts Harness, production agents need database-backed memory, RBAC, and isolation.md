---
created: 2026-04-06
description: Ashpreet Bedi argues that AI products are real systems—requiring databases, access control, and operations—not filesystem-only harness.
source: https://x.com/ashpreetbedi/status/2040841492860735634
type: learning
---

# Model + System outlasts Harness: production agents need database-backed memory, RBAC, and isolation

## Key Takeaways

Ashpreet Bedi’s thread reframes agent building as a **systems engineering** problem, arguing that “harness engineering” is a useful but incomplete lens compared with the full product challenge of serving agents at scale. This directly sharpens the conversation in [[agent harness is the product not the model]] by pushing the discussion toward **Model + System** as the operative architecture for production, not just model wiring.

He highlights that real products require durability and governance layers that filesystem-centric patterns can’t provide cleanly, especially around shared state and access boundaries: multi-tenancy, RBAC, approval controls, auditability, and cost/risk isolation. That makes [[agent harness components can be derived from first principles by working backwards from desired agent behavior]] stronger when paired with the argument that the hard constraints are operational, not merely interaction-level.

One recurring critique is that filesystem memory and virtualized abstractions can become workaround complexity when a proper **database-backed** approach gives built-in querying, concurrency safety, permissions, and consistency. In that sense, the thread aligns with [[Databricks coSTAR closes the agent testing gap with coupled judge-alignment and agent-refinement loops]] at the process level: reliability comes from system foundations, not just clever prompting or wrappers.

The thread also challenges whether harnessing patterns generalize beyond coding-agent terminals. That caution is useful against over-indexing on [[langchain-filesystem-context|Filesystems give agents a single interface for storing, retrieving, and updating unlimited context]] without pretending the interface itself is the only missing layer. The practical implication is that “harness” should be treated as a component inside a broader system architecture.

A useful middle path emerges in the replies: some practitioners describe harness as “parts around the LLM,” and that can be fair, as long as the term doesn’t hide production-critical concerns. That framing sits well with [[AGENTS.md is a cross-agent convention for injecting repo-level context via proximity-based file discovery]], which is valuable but only when integrated into guarded, multi-user infrastructure.

## External Resources

- https://x.com/ashpreetbedi/status/2040841492860735634 — root post that argues system-level engineering (databases, RBAC, and isolation) is central to real agent products
- https://x.com/nareshshah139/status/2040860683731144895 — counterpoint emphasizing practical coding-agent implementations like sandboxing and filesystem+index hybrid approaches
- https://x.com/kevinnguyendn/status/2040953196273922483 — engineering response arguing filesystem systems can be made robust with queues, indexing, and sync layers, though still a full system problem

## Original Content

>
> @ashpreetbedi (Ashpreet Bedi):
> Maybe I'm missing something, but "harness engineering" might be doing more harm than good.
>
> I've read a couple of posts on harness engineering, filesystem memory, subagent architecture. All real, all important. I've learned a lot from them.
>
> But I keep coming back to this: the framing of Agent = Model + Harness undersells the actual engineering involved. And as far as I can tell, none of the major agent products work this way.
>
> Claude, ChatGPT, Devin. These are all systems. They handle authentication, multi-tenancy, deployment, observability, cost controls, state management across sessions and users, RBAC, resource isolation. The "harness" is a subset of the engineering involved in building these products.
>
> A better framing might be Agent = Model + System. This makes sense because you can't serve a raw API call to users. You need the system around it to turn the model into a product. You could argue Agent = Model + Harness + System, and that's fair. But at that point the harness is just a component of the system. Treat it as one.
>
> My concern is that when we center the conversation on harness engineering, we train developers to think about the 30% that touches the model and ignore the 70% that makes the thing actually work in the real world. 
>
> When we look at the problem through the lens of the 30%, we end up with things like virtualized file systems which are solving problems that shouldn't exist in the first place.
>
> At best, the harness wraps the model. The system is the product. And there's a reason the consensus is that model progress will eventually swallow the harness. Because the harness is a thin layer. The system is not. The system is the product, and that's what developers should be focusing on.
>
> Another reason to take harness engineering with a grain of salt: it's shaped by coding agents. Coding agents are a very specific form factor which itself is evolving rapidly. Single user. Running in a terminal. Local filesystem. The patterns that emerge from this form factor are useful for this form factor. And I worry that generalizing them to broader agentic systems is damaging to the ecosystem as a whole.
>
> Here's what I mean. And notice a pattern: many of these are solutions to problems that shouldn't exist in the first place if you start with the right system design.
>
> 1. Filesystems for memory and storage
> Harness engineering recommends patterns like AGENTS.md files for memory. This works when one developer is running one agent on their laptop. It falls apart the moment you need a real product. There's a reason databases exist. Files don't support concurrent access. They don't support querying. They don't support access control. A filesystem as your memory layer is a single-user solution presented as architecture.
>
> And now I'm seeing people build "virtualized file systems" that wrap databases into filesystem-like structures to patch over these limitations. At that point, just expose the database. You get SQL as a first-class interface, proper access control, and durable storage without the abstraction gymnastics. And you know what, LLMs are even better at SQL than they are at cat and bash.
>
> 2. No multi-tenancy or RBAC
> How do 50 engineers on a team share an agent securely? How do you control which users can trigger which actions? That's multi-tenancy, authorization, and access control. No filesystem pattern solves this. You need real RBAC.
>
> 3. No resource isolation
> How do you stop one tenant's runaway agent from burning through your entire token budget? That's resource isolation. It lives at the system level. A harness has no concept of it. I hear people recommending sandboxes scoped to individual users and it makes 0 sense to me because your costs will eat you alive.
>
> Btw these problems aren't new. They're the same problems we've been solving in software engineering for decades.
>
> The instinct to create new terminology comes from a good place. "Harness engineering", "Scaffolding”, "Context engineering". People want to name the new discipline. But every time we mint a new term for a subset of systems engineering, I think we make it harder for developers to recognize that the patterns they need already exist and we shouldn't re-invent the wheel.
>
> All problems that harness engineering solves, you can solve with systems engineering. Maybe I'm wrong about this, but I'm just seeing harness engineering create more issues than it solves (virtualized file systems???)
>
> If we want developers to successfully build agentic products, we should encourage them to think in systems. The solutions already exist. We should use them.
>
> Again, maybe I'm missing something. I'll keep an open mind as I learn more. And maybe the answer is simply that harness engineering applies to coding agents and not to broader agentic products, which makes perfect sense.
>
> TLDR: Agent = Model + Harness undersells the real problem. Harness engineering is shaped by coding agents (single user, terminal, local filesystem) and ignores the 70% that makes agents work in production: multi-tenancy, RBAC, approval flows, audit logs, resource isolation, durable storage.
>
> These are systems engineering problems.
> date: Sun Apr 05 17:18:23 +0000 2026
> url: https://x.com/ashpreetbedi/status/2040841492860735634
> ──────────────────────────────────────────────────
>
> @CChirchi (Chahid Chirchi):
> @ashpreetbedi yeah, sometimes the basics get lost in all the hype...
> date: Sun Apr 05 18:27:42 +0000 2026
> url: https://x.com/CChirchi/status/2040858938510397647
> ──────────────────────────────────────────────────
>
> @nareshshah139 (Naresh R Shah):
> Coding Agents are all you need. CodeAct/RLMs massively outperform other methods for most meaningful tasks.
>
> Presentations/Excel work/Complex financial modeling/Automated Trading/Automated CV tasks - all perform better with these approaches.
>
> Sandboxes per individual work - if you can keep costs down for the sandbox. OpenAI gives a 0.03$ per sandbox session (which can last 10+ mins). Several sandbox providers also charge similarly for an API based sandbox tool. (Modal comes to mind)
>
> SQL semantics need schema defined beforehand. File systems do not.
>
> WorkOS style IAM systems allow you to do fine grained access control on shared filesystems (and this is used at OpenAI/Anthropic)
> date: Sun Apr 05 18:34:39 +0000 2026
> url: https://x.com/nareshshah139/status/2040860683731144895
> ──────────────────────────────────────────────────
>
> @wdavidturner (🧩 Dave):
> @ashpreetbedi System is where multiple agents live and where they interface w your business. 
>
> The agent is still the model plus harness which includes memory, tools, etc.
> date: Sun Apr 05 19:04:59 +0000 2026
> url: https://x.com/wdavidturner/status/2040868317313875990
> ──────────────────────────────────────────────────
>
> @salik (Salik Shah ✨🚀):
> @ashpreetbedi Yes, this needed to be said. I am building a CLI for my platform, and to me, it is not different from building a full system.
> date: Sun Apr 05 19:12:57 +0000 2026
> url: https://x.com/salik/status/2040870325358075932
> ──────────────────────────────────────────────────
>
> @sull (sull):
> @ashpreetbedi This needed to be said 🙌
> https://t.co/sWqmgpXAtM
> >  QT @sull:
> > @kami_saia @bygregorr @himanshustwts sqlite even better ;)
> >  https://x.com/sull/status/2039032130689261633
> date: Sun Apr 05 21:08:58 +0000 2026
> url: https://x.com/sull/status/2040899520418975752
> ──────────────────────────────────────────────────
>
> @mayonkeyy (Mayank):
> @ashpreetbedi Well worth the read. Good stuff
> date: Sun Apr 05 21:36:28 +0000 2026
> url: https://x.com/mayonkeyy/status/2040906440383348793
> ──────────────────────────────────────────────────
>
> @rickwong888 (Rick Wong):
> @ashpreetbedi The scope of the harness needs to be clarified when using the term. 
>
> I use it similar to you where it refers to hooking intelligence throughout your systems. 
>
> Some use harness to describe parts around the llm and deemphasize the system part.
> date: Sun Apr 05 21:36:51 +0000 2026
> url: https://x.com/rickwong888/status/2040906537313673714
> ──────────────────────────────────────────────────
>
> @ashpreetbedi (Ashpreet Bedi):
> @mayonkeyy ty sir!
> date: Sun Apr 05 21:37:59 +0000 2026
> url: https://x.com/ashpreetbedi/status/2040906821049720890
> ──────────────────────────────────────────────────
>
> @ctrl_alt_focus (Control Alt):
> @ashpreetbedi nicely written 
>
> although for me TLDR is FOMO
> i mean kind of that there's lots of (existing/new/wannabe) influencers creating FOMO
>
> but am glad to see someone explain it the way you do, in detail 😄
> date: Sun Apr 05 22:09:32 +0000 2026
> url: https://x.com/ctrl_alt_focus/status/2040914762305880265
> ──────────────────────────────────────────────────
>
> @draganfill (Dragan Filipović):
> @ashpreetbedi Markdown as direct input makes sense, but agent can use any software to read from reliable source and transform to plain text. 
> We are stuck with md files like there was no any software before AI.
> date: Sun Apr 05 22:41:48 +0000 2026
> url: https://x.com/draganfill/status/2040922884017693118
> ──────────────────────────────────────────────────
>
> @dataphagus (Lgvdp):
> While i see the point, i think the post tackles a nonexistent issue in a way. I dont think any dev believes current models are the same as the ones we had last year, or that the future models wont improve per se. And I also do not think the model will swallow the harness (basically because a harness is trully every single aditional information the model has that does not come from it's training, give or take). If we want models to interact with the environment we will need harnesses for them.
>
> But besides this, which is more my opinion than a ground truth, most developers can't have an impact on the models, but they can certainly try and use them in ways where they get better results, and that's by tweaking the harness. Honnestly, i think it's also making people think a lot and understand model<>environment interaction, which is not trivial. I dont see any reason why it'd be doing more harm than good not gonna lie.
>
> Complexity is certainly a complex matter (forgive the redundancy), and harnesses are the way that currently enable us to handle it "for our models", plus it's super fun!
> date: Sun Apr 05 22:56:03 +0000 2026
> url: https://x.com/dataphagus/status/2040926470491574470
> ──────────────────────────────────────────────────
>
> @johnennis (John Ennis):
> Totally agree
>
> The only thing that has really changed is that the range of inputs and outputs is now much broader
>
> Even the non-deterministic nature of LLMs is not some new thing, there is already a rich literature of systems engineering in stochastic environments
>
> Even waterpark designers have to deal with nondeterministic outcomes
> date: Sun Apr 05 23:36:01 +0000 2026
> url: https://x.com/johnennis/status/2040936529061982506
> ──────────────────────────────────────────────────
>
> @kevinnguyendn (andy nguyen):
> Good post, a lot of this resonates. Want to add a data point from the other side though.
>
> We build a filesystem-based memory system for agents (ByteRover). The "files can't do X" arguments come up a lot, and they're true for naive file access. But we've found you can engineer around most of them without reaching for a database.
>
> Concurrent access → per-project task queues with sequential execution, atomic temp+rename on every write, backup+rollback on merge failures. Not Postgres, but ACID-like for the patterns we actually hit.
>
> Querying → in-memory BM25 index with compound scoring, not grep. 80%+ of queries resolve under 200ms without an LLM call.
>
> Sync → built a layer with branch support and 3-way merge with conflict resolution. That's effectively the "database" on top of files.
>
> We actually migrated away from SQLite early on. Native dependency issues, and the files were opaque to both humans and agents. When your primary consumer is an LLM that reasons about text, markdown turns out to be the more natural interface than SQL.
>
> That said,  your broader point stands. The harness framing is limiting. What we build isn't a harness, it's a system with a daemon, task queues, sync infra, audit logging, and a retrieval engine. Calling all of that "harness engineering" does undersell the real work. The systems engineering patterns absolutely apply, we just chose a different storage primitive.
> date: Mon Apr 06 00:42:15 +0000 2026
> url: https://x.com/kevinnguyendn/status/2040953196273922483
> ──────────────────────────────────────────────────
>
> @Yshayy (Yshay):
> We can’t really separate harness engineering from system engineering at production systems, but these are going to be shaped differently to support the emerging capabilities of LLMs and/or agents.
>
> Writing and executing code by LLMs can be used to solve problems not related to software challenges (as seen with ChatGPT Code Interpreter and RLMs). File-system based knowledge organisation can beat other data retrieval and curation techniques, especially for unstructured data. Executing code/CLI can beat structured JSON tool calls (CodeAct, CodeMode, PTC, RLM), and skills + CLI can beat discovery (some parts of MCP). None of it is specific to the domain of coding. Also, none of these techniques is exclusive and the modelling can be separated from implementation - just-bash emulates a terminal without a container, agentfs emulates a file-system on top of SQLite, Cloudflare uses isolates and virtual actors for their agents environments/sandboxes.
>
> The world and systems we used to model assumed software is static and stupid. This is no longer true. Building the building blocks and designing our system around “intelligent” system with constantly evolving discovery and reasoning capabilities is something new and to do it properly (scale, security, reliability, UX) requires using our existing CS and system engineering knowledge and patterns and sometimes exploring or even inventing new ones
> date: Mon Apr 06 00:59:02 +0000 2026
> url: https://x.com/Yshayy/status/2040957420667584857
> ──────────────────────────────────────────────────
>
> @khalilbenali (Khalil Benalioulhaj):
> I think one of the challenges and part of the reason these new terms come up is that it’s not just developers trying to establish what works with these models. You’ve got people like me that have very little idea of systems engineering even looks like, let alone the best practices, from a developer standpoint. I would be curious what you think the “system” in your equation agent = model + system. 
>
> I’m trying to solve this for myself with files in obsidian. I’m doing my best. I think I’ve made good progress. I’ve tried to approach it with a systems mindset the way I think of business systems, pulling from lean manufacturing and theory of constraints. But I would love to learn from the developer side what I don’t know.
> date: Mon Apr 06 01:13:14 +0000 2026
> url: https://x.com/khalilbenali/status/2040960991945457986
> ──────────────────────────────────────────────────
>
> @myles_franklin (Myles Franklin):
> @ashpreetbedi these are problems that will be solved by anthropic and openAI in 6 months
> date: Mon Apr 06 01:34:07 +0000 2026
> url: https://x.com/myles_franklin/status/2040966248478191851
> ──────────────────────────────────────────────────
>
> @Jzfitch1 (Zack Fitch):
> @ashpreetbedi Exoshell is a better word.  It grants capabilities. It determines possibility, it doesn’t just restrict it.
> date: Mon Apr 06 01:35:08 +0000 2026
> url: https://x.com/Jzfitch1/status/2040966503831609493
> ──────────────────────────────────────────────────
>
> @SomeCynic (Some Cynic):
> @ashpreetbedi I agree that for production-grade products, the system as a whole is much larger than the harness concept one might see being described, and indeed a lot of it is the traditional engineering we are already familiar with.
> Now, regarding virtual file systems...
> date: Mon Apr 06 02:33:36 +0000 2026
> url: https://x.com/SomeCynic/status/2040981219555356941
> ──────────────────────────────────────────────────
>
> @entropycoder (EntropyCoder (Dunc)):
> @ashpreetbedi Always appreciate the insights Ashpreet. Reminds me of much of this blog https://t.co/zHf9TgvmHh
> date: Mon Apr 06 03:28:45 +0000 2026
> url: https://x.com/entropycoder/status/2040995095734878260
> ──────────────────────────────────────────────────
>
> @entropycoder (EntropyCoder (Dunc)):
> @ashpreetbedi With so much of the “filesystem” is all you need ethos. Which I do tend to agree with. I think the right mental model here borrowing from @Vtrivedy10, “everything is a file system if you squint hard enough” (really like that one).
> date: Mon Apr 06 03:30:10 +0000 2026
> url: https://x.com/entropycoder/status/2040995454301675588
> ──────────────────────────────────────────────────

[Source URL](https://x.com/ashpreetbedi/status/2040841492860735634)
