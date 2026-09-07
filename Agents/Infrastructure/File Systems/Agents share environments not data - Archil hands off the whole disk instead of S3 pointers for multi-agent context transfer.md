---
created: 2026-09-08
description: Archil's Hunter Leath argues that the 2015-2025 pattern of passing S3 pointers between microservices breaks for agents, because an agent's unit of work is a whole environment -- binaries, documents, cookies, SQLite tables, conversation history -- not a single object, so multi-agent hand-off should share a live multi-attach disk rather than zip and re-upload the data.
source: https://x.com/jhleath/status/2045575156815523999
type: framework
---

## Key Takeaways

- **The historical parallel is the argument: 2017 microservices passed pointers because blobs were too big for the database, and 2026 agents are still doing it even though their unit of work has changed.** Leath's claim is that value now comes from relationships *between* documents plus the tools that read them, so an S3 URL is the wrong handle -- what one agent must hand another is the whole environment. The observation that developers are "desperately trying to zip up entire file systems and upload them to S3, or push all the data into a single SQLite document" is the most concrete symptom in the four-article set.

- **"Environment" is defined broadly enough to be load-bearing: installed binaries, per-user documents, derived linkages between them, and structured SQLite state.** That list is what distinguishes this from ordinary shared storage -- it includes the executables and the accumulated intermediate work, not just the corpus. Compare [[Harvey Spectre makes durable runs the core primitive while workers stay ephemeral and sandboxes enforce explicit boundaries|Harvey Spectre, which makes the durable *run* the primitive]] and keeps workers ephemeral: same instinct about where identity lives, different noun.

- **The mechanism is smaller than the framing suggests -- it is a curried tool factory.** `buildBashTool(disk)` returns an AI SDK tool bound to a disk id; hand a peer agent the disk id and it gets the same bash tool over the same bytes. There is no capability model, no scoping, no conflict resolution for two agents writing the same path, and no ACL story in the article. As a hand-off primitive it is elegant; as a multi-tenant sharing primitive it is unspecified, which matters more the closer you get to [[isolating the entire agent in a sandbox is more secure than isolating just the tool|the isolation questions the sandbox literature asks]].

- **"Data has gravity" is used to argue *against* local disks, which is the inverse of how the phrase usually runs.** If the file system is local, the compute must come to it; abstracting it behind a service that accepts commands makes access near-constant-time from anywhere. Leath resolves the obvious tension with the physics in [[Archil explains why S3 feels faster than EFS - 256 chatty 4KB reads turn 60ms of cross-region latency into 15,616ms of wall clock|his own latency article]] and revisits the local-disk case sympathetically in [[Archil argues local storage is a special case of remote storage - full residency plus writes acknowledged before they are durable|"Should storage be local or remote?"]] -- read all three before accepting "near-constant time regardless of where the requests are coming from," which is true only for the serverless-execution path, not for mounted access.

- **This is the second load-bearing beam under [[Archil argues the file system is the sandbox because a server's identity is its data, not its compute|"the file system is the sandbox"]].** Article one says the disk is the identity of a single agent; this one says the disk is the *interchange format* between agents. Together with [[Bash is the SQL for file systems and Archil proves it with serverless execution that sends instructions not data|"Bash is the SQL for file systems"]] they form a single thesis: storage is the primitive, bash is the query language, and the disk id is the handoff token. It is a coherent position and it is also, transparently, the shape of the product being sold.

- **The unaddressed objection is provenance across the handoff.** A shared mutable disk gives the receiving agent everything, including no record of who wrote what or why -- exactly the failure mode in [[a file system is not all you need - databases beat markdown for agent context provenance and governance]] and [[every app that avoids a database ends up rebuilding one badly]]. Multi-agent systems that need auditable handoffs will end up adding a ledger on top, which is the same conclusion [[agents need a database because stateless reasoning cores require stateful storage]] reaches from the other direction. The vault's orchestration notes on [[every agentic system needs three sub-agent patterns sync async and scheduled|sync/async/scheduled sub-agent patterns]] and [[memory-first agents should dispatch stateless subagents for focused task execution|memory-first dispatch of stateless subagents]] both assume a controlling parent; Leath's peer-to-peer disk handoff has no such coordinator.

## External Resources

- [Archil Console](https://console.archil.com) — spin up a disk; `npx disk create` is the CLI equivalent
- [Archil Serverless Execution](https://x.com/jhleath/status/2044050779577954481) — the launch article this piece builds on, linked inline by Leath
- ["Bash is the SQL for file systems"](https://x.com/jhleath/status/2044426491468079515) — Leath's "similar to a SQL database" link, the egress/instructions-not-data argument
- [Vercel AI SDK](https://ai-sdk.dev) — the `tool()` / `z.object()` shape both code samples use

## Original Content

> [!quote]- Full X Article — Hunter Leath, "Agents share environments, not data" (18 Apr 2026)
> Hunter Leath (@jhleath) — Sat Apr 18, 2026
> Article: "Agents share environments, not data"
> 130 likes | 13 retweets | 9 replies
>
> Article: Agents share environments, not data
>
> Agents today mirror the software development world of the late 2000s before the secrets from Google, Amazon, and Facebook on scaling engineering teams and services became common knowledge. Today, agents are monolithic and the data that they work is (often) small.
>
> Now, let's run a though experiment. Imagine that it's 2017 and your organization has built a system out of microservices that's processing large pieces of data that's coming in from users (>1 GB each). How do you pass this to your microservices?
>
> The data is too big to stuff in a SQL database, so you're almost certainly uploading the data to S3, keeping the URL handy, and putting the URL into your SQL database or sending it through your Kafka cluster.
>
> You're sharing pointers, not data.
>
> *The 2007-to-2017 shift: a database holding data blobs directly becomes a database holding pointers that all dereference to S3.*
> ![[jhleath-523999-001.png]]
>
> This was the backbone of designing systems from 2015 to 2025 and it put S3 at the center of it all. The unit of work was one object. You ingested it, you uploaded it, and you processed it.
>
> Fast-forward to 2026, and now, everything is about building agents. The interesting thing about agents is that they look super similar to what we were doing before.
>
> Imagine that you're an AI startup working in the legal field with a recognizable actor as your spokesperson. Your users are uploading document after document of legal information into your system so that your agents can learn from it.
>
> There's a big difference than the systems of the past, though. We used to operate on the scale of an individual document. Now, these agents create value by discovering the relationships between documents and using specialized tools to extract information from them.
>
> The agent isn't operating on individual pieces of data, it's operating on an entire environment -- it's context -- if you will. Each piece of data isn't useful in isolation, the value only comes in seeing the entire customer's environment together.
>
> Now, today, the way that people are trying to manage this remains almost the same as what we were doing before. I see developers desperately trying to zip up entire file systems and upload them to S3, or push all the data into a single SQLite document.
>
> This works for some people right now, because the scale of the data is small and the agents are monolithic -- single-player. But, it's reasonable to believe that the arc of agents is going to follow the arc of software in the 2010s. Everything is going to get bigger. More data. More teams. More coordination.
>
> How should we think about the "micro-agent" from one team handing off data to the micro-agent from another team?
>
> Well, we need to give the second agent everything. All of the documents, all of the tools, all of the cookies, all of the sqlite files, all of the information on progress that's been made before, everything. Otherwise, we can't expect it to be able to create its own insights.
>
> At Archil, we've been thinking deeply about this as: share the environment, not the data.
>
> It's not feasible to be able to upload all of this data to somewhere in S3 so that it can be downloaded to another agent, configure all the sandboxes it uses, and only then let it start running.
>
> Instead, the environment of the agent is the disk (the file system) that it's using.
>
> The disk contains: the specialized binaries that you install, all of the documents for each user, the ability to easily derive linkages between those documents, and any structured data in the form of SQLite tables associated with the user.
>
> *Leath's proposed 2027 shape: the file system -- binaries, documents, conversation history -- becomes the unit that points at S3, inverting the pointer relationship.*
> ![[jhleath-523999-002.png]]
>
> How do you go about sharing this without spending a ton of time uploading and downloading the disk to S3?
>
> Well, there really wasn't a good solution to this before [Archil's Serverless Execution](https://x.com/jhleath/status/2044050779577954481).
>
> You see, data has gravity. If you store your file system on a local disk, then if you want to access it later, you have to ... do your work on that same local disk. This isn't great for resource usage, or the ability to share the entire environment across teams running different agents.
>
> If you abstract the file system a level out -- as a server that accepts commands to a Linux machine and returns results -- then suddenly that service can respond in near-constant time regardless of where the requests are coming from -- [similar to a SQL database](https://x.com/jhleath/status/2044426491468079515).
>
> How does this work in practice?
>
> You make a bash tool using Archil with code that looks like this:
>
> ```typescript
> const bash = tool({
>   description: "Run a shell command inside the workdir.",
>   inputSchema: z.object({
>     command: z.string(),
>   }),
>   execute: async ({ command }) => {
>     const { stdout, stderr, exitCode } = await disk.exec(command);
>     return `exit ${exitCode}\n${stdout}${stderr ? `\n${stderr}` : ""}`;
>   },
> });
>
> ```
>
> Now, here's the cool part -- what if your agent could just share that tool (with exactly the same files on the disk) directly to any other agent that you're working with? Think of it like a meta-function that looks like this, you give a diskId, and you get out a bash tool -- anywhere in the world.
>
> ```typescript
> const buildBashTool = (disk) => tool({
>   description: "Run a shell command inside the workdir.",
>   inputSchema: z.object({
>     command: z.string(),
>   }),
>   execute: async ({ command }) => {
>     const { stdout, stderr, exitCode } = await disk.exec(command);
>     return `exit ${exitCode}\n${stdout}${stderr ? `\n${stderr}` : ""}`;
>   },
> });
>
> buildBashTool(customerDisk1)
> ```
>
> This is insanely powerful for building specialized agents that can hand-off context between each other in constant-time, no matter where in the world they are located.
>
> *Agent hand-off in three steps: an ingest agent prepares the file system, hands off to a review agent, which accesses the same disk through Archil Serverless Execution.*
> ![[jhleath-523999-003.png]]
>
> We think of this as "agent hand-off". We expect that the next-generation of agents are going to be multi-player, working on larger data sets than we have even considered today, and that the ability to fully hand-off the context from one agent to another is a critical component in how these applications will be built.
>
> If you're interesting in playing with this, you can try out Serverless Execution on Archil today by spinning up a disk at https://console.archil.com or "npx disk create".

## Notable Replies

- **EJ Campbell ([@ejc3](https://x.com/ejc3/status/2045597422018236901))** pushes the thesis one layer further: "Don't you want to go all the way — give agents access state too. It's great you can have your disk available in 100ms, but we should have all processes from the last time the agent ran available too." Leath does not commit: "maybe! what sort of processes are you thinking would want to be long-lived?" Process state, unlike file state, is the thing Archil does not carry — which is exactly the gap [[Opencomputer reframes harness-vs-sandbox debate as git branches for VMs via hibernation egress proxies and checkpoints|Opencomputer's VM hibernation fills]].
- **Leo Tavares ([@LeoTava8](https://x.com/LeoTava8/status/2045602494601150864))**: "We're still stuck in the XML/SOAP era of agent 'interop'—obsessing over the schema of the message. The real shift happens when we focus on shared state and execution boundaries instead of just passing JSON back and forth."
- **Adao Aparecido Ernesto ([@adaoaper](https://x.com/adaoaper/status/2045633961192292746))** describes a parallel line of experiments he calls AIUAR (AI Universal Address Reference) — a "shared, addressable substrate, materialized in a filesystem or any other substrate that can be resolved by an LLM," so agents and software systems "operate within the same operational space, with persistent context, locatable artifacts, reusable logic, and traceable results."

[Original article on X](https://x.com/jhleath/status/2045575156815523999)
