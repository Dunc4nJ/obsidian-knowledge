---
created: 2026-09-08
description: Archil founder Hunter Leath argues that a server's identity was always its data, not its compute, so the next-generation cloud should make the file system the central multi-attach resource and demote compute to ephemeral serverless functions that attach to it -- the launch post for Archil Serverless Execution.
source: https://x.com/jhleath/status/2044050779577954481
type: framework
---

## Key Takeaways

- **The Ship of Theseus framing is the whole argument compressed: swap every component in your machine and it stays "your computer" until the data is wiped.** Leath uses this to claim compute was never the identity of a server, and therefore every cloud that organizes itself around launching and lifecycling compute (EC2, Fly machines, sandbox providers) has picked the wrong central noun. It is a genuinely clean reframe, and it is also the reframe that makes a storage company the center of the diagram -- worth holding both facts at once. This is the first of four articles Leath published in eleven days building the same case: this one asserts the worldview, [[Agents share environments not data - Archil hands off the whole disk instead of S3 pointers for multi-agent context transfer|"Agents share environments, not data"]] extends it to multi-agent hand-off, [[Archil explains why S3 feels faster than EFS - 256 chatty 4KB reads turn 60ms of cross-region latency into 15,616ms of wall clock|"Is S3 faster than a file system?"]] supplies the measured physics, and [[Archil argues local storage is a special case of remote storage - full residency plus writes acknowledged before they are durable|"Should storage be local or remote?"]] concedes the strongest counter-position.

- **"Cattle not pets" gets recast as a symptom rather than a virtue.** The reason clouds force users to treat compute as disposable and ship data to amnesic servers, Leath argues, is that no cloud shipped an easy, infinite, multi-attach state layer. This inverts the usual reading of that maxim, and it lands closest to home for [[Opencomputer reframes harness-vs-sandbox debate as git branches for VMs via hibernation egress proxies and checkpoints|Opencomputer's point that the harness/sandbox debate is really an argument about ephemerality]], not about isolation.

- **Multi-attach is the load-bearing property, not the file API.** Because many compute functions can mount the same disk simultaneously, a map-reduce grep across a bucket becomes a fan-out of one-container-per-file `exec` calls with per-invocation CPU and RAM, billed only while running. That is the same scale-out-inside-the-storage move as [[MongoDB's VFS for LangChain Deep Agents redefines grep as server-side hybrid search, splitting file bytes in S3 from a searchable chunk plane in Atlas|MongoDB's VFS pushing grep server-side]] and [[a virtual filesystem over Chroma replaces sandboxes for agent doc exploration at 100ms instead of 46 seconds|ChromaFS replacing a sandbox with a virtual filesystem]] -- three independent teams converging on "put the compute where the bytes are."

- **The agent-facing claim is narrower than the cloud-architecture claim, and stronger.** Agents need arbitrary bash and POSIX against a workspace; sandbox products give them a machine and leave data movement and lifecycle as homework. Making `disk.exec` a bash tool in the Vercel AI SDK skips both. This is the concrete version of what [[Everything is Context - Agentic File System Abstraction for Context Engineering|"Everything is Context" abstracts]] and what [[code execution with MCP cuts tool token overhead 98 percent by presenting servers as filesystem APIs instead of upfront definitions|code-execution-with-MCP does for tool surfaces]].

- **Nothing here answers the governance objection, and it should be read against it.** [[a file system is not all you need - databases beat markdown for agent context provenance and governance]] argues files collapse under provenance, typed query, and maintenance demands at scale -- an argument that a faster, multi-attach file system does not touch. Leath's companion piece [[Bash is the SQL for file systems and Archil proves it with serverless execution that sends instructions not data|"Bash is the SQL for file systems"]] answers the *query* half of that objection; the provenance half stays open, which is why [[agents need a database because stateless reasoning cores require stateful storage]] remains a live competing position.

- **Read the security silence deliberately.** "Sandbox" in this article means workspace, not isolation boundary. The vault's sandbox literature -- [[Firecracker microVMs became the convergent agent runtime because containers were never a security boundary]], [[Cloudflare Dynamic Workers sandbox AI-generated code in V8 isolates 100x faster than containers]], [[isolating the entire agent in a sandbox is more secure than isolating just the tool]] -- is about untrusted code and blast radius. Archil's per-`exec` container is a billing and parallelism unit whose isolation properties the article never specifies. A title claiming the file system *is* the sandbox invites a comparison the piece does not actually make.

## External Resources

- [Archil](https://archil.com) — Leath's company (YC F24); elastic cloud file systems, the subject of this and its three companion articles
- [Archil Console](https://console.archil.com) — where a disk with Serverless Execution gets created
- `@archildata/client` — the JS client whose new `.exec` function is the launch in this post
- [Vercel AI SDK](https://ai-sdk.dev) — `generateText`/`tool` from `ai`, used in the second code sample to wire `disk.exec` in as an agent bash tool

## Original Content

> [!quote]- Full X Article — Hunter Leath, "The file system is the sandbox" (14 Apr 2026)
> Hunter Leath (@jhleath) — Tue Apr 14, 2026
> Article: "The file system is the sandbox"
> 177 likes | 14 retweets | 7 replies
>
> Article: The file system is the sandbox
>
> Let's start by thinking about the Ship of Theseus, which asks the question "if you replace every plank in a ship, at what point does it become a different ship?". This is kind of hard to answer, but surprisingly, with computers it's simpler.
>
> If you, over the course of a month, replaced every component in your personal computer with an identical component, at what point would it not be "your computer".
>
> The answer here should be obvious, it stops being "your computer" when your data -- your keys, your files, your programs -- are the piece that gets wiped. In fact, if you manage to keep your data across this transition, then it's still your computer.
>
> This simple thought exercise reveals a surprising truth about cloud computing and sandboxes. The compute itself was never the identify of the machine. And yet, every cloud (AWS --> EC2, Fly --> machines, Sandbox providers --> sandboxes) is focused around how to make you think about launching and managing the lifecycle of compute products.
>
> This model meant that the users had to figure out how to use this compute in an ephemeral way, to treat their compute as "cattle not pets", and to figure out how to get their data (the thing that actually matters) to the box itself.
>
> Over the past several months, my friends have struggled to watch me draw the same diagram over and over and over again.
>
> *The diagram Leath keeps redrawing: traditional clouds hang S3, volumes, and secrets off a single central Compute node; Archil inverts it, making the File System the hub with many independent Compute nodes attaching to it.*
> ![[jhleath-954481-001.png]]
>
> The underlying reason why clouds work this way, forcing you to figure out how to get things to amnesic servers, is because they don't have an easy to use, infinite, multi-attach state storage system -- a file system.
>
> Over the past few months, this problem has just been exacerbated with the need for AI agents to launch sandboxes to run arbitrary code, bash, and POSIX commands. These products work great, but they mean that you (the user) need to think through how to get your data into and out of them, how you manage the lifecycle of these machines, and making sure that you fully utilize them to avoid billing surprises.
>
> The people who are building the next generation of agents don't have time to think about these issues. To solve this, we propose a new model, a model that honors the fact that the "identity" of a server is really it's data.
>
> We see the storage -- the file system -- as the central "resource" in the next-generation cloud, not servers. Users can put their data into this file system, using a variety of tools -- including lazily synchronizing it from origin services like S3 -- and then they can run compute on the file system when they want to either extract information from it or edit it in some way.
>
> Because the file system is multi-attach, users can run many of these "compute functions" in parallel, each function getting its own, dedicated CPU and RAM allotment. Because the function only runs to completion, users are only billed for the amount of time that they are actively using the compute.
>
> We call this model Serverless Execution, and we're excited to roll it out to customers over the next few days. Let me give you a peak of how it works.
>
> ```javascript
> import { Archil } from '@archildata/client'
>
> // Create a disk, backed by your s3 bucket
> const disk = await Archil.disks.create({
>   name: 'agent-workspace',
>   mounts: [{ type: 's3', bucketName: 'agent-bucket'}],
> })
>
> const { fileList } = await disk.exec("ls")
>
> const grepPromises = fileList.map(file =>
>  disk.exec("grep ERROR " + file)
> )
>
> const results = Promise.all(grepPromises)
>
>
>
> ```
>
> We're launching a new ".exec" function in our Javascript client that allows users to run arbitrary code on the file system directly, in the Archil cloud.
>
> This example, for instance, allows a user to do a full map-reduce full text search across an entire bucket. Each exec gets it's own container, allowing you to do a full scale-out search that's faster than grep and faster than ripgrep.
>
> This power also allows you to have agents that work directly on the file system. For instance, you might want to use "exec" as a way to provide a bash tool to an agent running locally or in the cloud:
>
> ```javascript
> import { generateText, tool } from 'ai'
> import { z } from 'zod'
> import { Archil } from '@archildata/client'
>
> const disk = await Archil.disks.create({
>   name: 'agent-workspace',
>   mounts: [{ type: 's3', bucketName: 'agent-bucket' }],
> })
>
> const bash = tool({
>   description:
>     'Run a shell command inside the Archil-backed workspace disk and return stdout/stderr.',
>   inputSchema: z.object({
>     command: z.string().describe('Shell command to execute, e.g. ls, cat file.txt, grep ERROR app.log'),
>   }),
>   execute: async ({ command }) => {
>     const result = await disk.exec(command)
>
>     return {
>       stdout: result.stdout ?? '',
>       stderr: result.stderr ?? '',
>       exitCode: result.exitCode ?? 0,
>       fileList: result.fileList ?? undefined,
>     }
>   },
> })
>
> const result = await generateText({
>   model: 'openai/gpt-5.2',
>   prompt: 'List files, then look for ERROR lines.',
>   tools: { bash },
>   maxSteps: 10,
> })
>
> console.log(result.text)
> ```
>
> We think that the possibilities are endless here, and they will allow our users to accelerate how they build the next-generation of agents without needing to think through moving their data or managing sandbox lifecycles.
>
> Serverless execution will be available to Archil users over the next few days, please DM if you want early access.

## Notable Replies

- **Dan Goodman ([@Dan_The_Goodman](https://x.com/Dan_The_Goodman/status/2044074848113307970))** critiques the sample tool description directly: "Run a shell command inside the Archil-backed workspace disk and return stdout/stderr" is a bad prompt, because "Archil" is a vendor name the agent must reason about ("it's just a filesystem"), and stdout/stderr is an implementation detail. His fix is "Run a shell command inside the workdir" — fewer tokens, no lookups, and the model treats it as a plain directory. Leath: "this is a good point and i will pass this along to the implementor, chatgpt."
- **Anatoliy Gatt ([@anatoliygatt](https://x.com/anatoliygatt/status/2044333049626726835))** states the thesis more crisply than the article does: "Every sandbox provider starts with compute and bolts on state. Starting with the file system and bolting on compute is a better primitive for how agents actually work."

[Original article on X](https://x.com/jhleath/status/2044050779577954481)
