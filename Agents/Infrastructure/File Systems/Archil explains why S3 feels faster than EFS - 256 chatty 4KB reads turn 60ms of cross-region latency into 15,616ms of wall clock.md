---
created: 2026-09-08
description: Archil's Hunter Leath resolves the paradox of developers insisting S3 is faster than EFS -- per-operation latency favors the file system (1ms TTFB vs 40ms), but Linux has no semantic knowledge of intent, so a 1MB file read in random 4KB chunks becomes 256 round trips; add 60ms of cross-region network latency and the file system goes 30x slower (15,616ms) while S3 goes only 2x (113ms), which is the physics argument behind Archil's Serverless Execution.
source: https://x.com/jhleath/status/2047362676926615871
type: framework
---

## Key Takeaways

- **The paradox is real and the resolution is protocol chattiness, not raw speed.** Leath's hypothetical in-region numbers put a 4KB read at 1ms network + 40ms time-to-first-byte + 0.05ms transfer for S3 (80 MB/s connection) against 1ms + 1ms + 0.008ms for EFS/S3 Files (500 MB/s). EFS wins every individual operation by roughly 20x. But because Linux does not know the application intends to read the whole file, a 1MB file read in random 4KB chunks becomes 256 separate operations: **512ms for EFS against 54ms for S3**, where the S3 application just buffered the object in RAM. The file system loses by 10x on the same workload it wins per-operation.

- **Cross-region latency is where the effect becomes violent, and these are the numbers to remember.** At 60ms us-east-1 to us-west-2 (his source: cloudping.co), S3 goes from 54ms to **113ms -- 2x slower**. The file system goes from 512ms to **15,616ms -- 30x slower**, because it pays that 60ms 256 times. This is the strongest, most transferable fact in the whole four-article set: chattiness multiplies network latency by the operation count, so protocol design dominates hardware for any workload that crosses a region boundary. It generalizes well past storage, to [[MongoDB's VFS for LangChain Deep Agents redefines grep as server-side hybrid search, splitting file bytes in S3 from a searchable chunk plane in Atlas|any VFS that turns one logical agent operation into many remote calls]] and to [[Leonie reimplements Mintlify ChromaFs as a virtual filesystem over Elasticsearch in an open-source POC|open-source VFS reimplementations that put a search backend behind POSIX]] -- the design question in both is how many remote round trips one `ls` or `grep` costs.

- **Serverless Execution's claimed cross-region total is 416ms: 60ms network, 100ms container start, 256ms execution -- "20% faster?" than the 512ms in-region EFS baseline.** Note the question mark is Leath's own. The mechanism is sound (pay network latency once, on the instruction, instead of once per operation), but the comparison is a hypothetical against a hypothetical, and 100ms of container start is a real floor that makes this a bad trade for small or latency-sensitive operations. Every number in this article is explicitly labeled hypothetical and not to scale; treat the ratios as the claim and the absolute values as illustration. It is also the quantitative case for [[Archil argues the file system is the sandbox because a server's identity is its data, not its compute|the article that launched Serverless Execution on architectural grounds]], written nine days later.

- **The Tigris contrast explains a structural business asymmetry, and it is the most honest paragraph in the piece.** Ovais Tariq's Tigris Metal can rack storage in centralized data centers and let customers like Railway connect from elsewhere; Archil must be physically in the customer's data center, "a big cost on our business." The reason is precisely the 30x above -- an object store's low request count tolerates distance, a file system's high request count does not. Leath shipped `archil utils speed-test` so customers can measure their own network latency, which is a genuinely good response to a genuinely bad constraint.

- **The root cause is stated crisply and cuts against the vault's file-system optimism: "Linux doesn't have the semantic information to understand what your application is trying to accomplish."** S3 forces you to architect around storage and thereby eliminate duplicate requests; POSIX lets you stay ignorant and pay for it. That is a real argument that the file system's ergonomic advantage -- the thing [[Everything is Context - Agentic File System Abstraction for Context Engineering|"Everything is Context"]] and [[a virtual filesystem over Chroma replaces sandboxes for agent doc exploration at 100ms instead of 46 seconds|ChromaFS]] are built on -- is bought with a performance liability. It also complicates the "near-constant time regardless of where the requests are coming from" claim in [[Agents share environments not data - Archil hands off the whole disk instead of S3 pointers for multi-agent context transfer|"Agents share environments, not data"]], which holds only for the exec path.

- **The self-serving structure is worth naming: the article establishes a law of physics that only the author's newest product escapes.** The physics is correct and the mechanism is the same instructions-not-data move as [[Bash is the SQL for file systems and Archil proves it with serverless execution that sends instructions not data|"Bash is the SQL for file systems"]] and the same colocation logic behind [[Lakebase puts Postgres on open object storage as a third database generation - O(1) branching, sub-500ms compute start, and 7x space amplification as the price|Lakebase putting Postgres on object storage]] and [[code execution with MCP cuts tool token overhead 98 percent by presenting servers as filesystem APIs instead of upfront definitions|code execution replacing chatty MCP tool calls]]. Leath's own answer to a question in the replies also punctures the article's framing: Serverless Execution does *not* yet run on the storage node, only "close enough."

- **Everything here is speculation about AWS internals, flagged as such.** S3 as hard-drive-backed, EFS/S3 Files as SSD-backed, the >10x cost delta, S3's heavier per-connection throttling -- Leath brackets each with "[speculated]". He is an ex-AWS storage engineer, which makes the speculation informed and still speculation. Pair with [[Amazon S3 Files ends the object-file split for AI agents]] for what AWS itself has said on the record, and with [[Cursor's Continuity replaces GitHub Spokes three-phase commit with an S3 write-ahead log as the source of truth for Git hosting|Cursor building a Git host on an S3 write-ahead log]] for a production system that took the batch-into-fewer-large-operations side of this trade deliberately. The follow-up, [[Archil argues local storage is a special case of remote storage - full residency plus writes acknowledged before they are durable|"Should storage be local or remote?"]], answers the obvious next question: if network distance is this punishing, why not keep the disk local.

## External Resources

- [cloudping.co](https://www.cloudping.co/) — the inter-region latency table Leath's 60ms us-east-1 to us-west-2 figure comes from
- `archil utils speed-test` — Archil CLI command shipped so customers can measure their own network latency to the service
- [Tigris](https://www.tigrisdata.com/) — Ovais Tariq's ([@ovaistariq](https://x.com/ovaistariq)) object storage company; Tigris Metal is the centralized-datacenter contrast case
- [Railway](https://railway.com/) — cited as a Tigris customer connecting to centralized storage servers rather than colocated ones
- [Archil Serverless Execution](https://x.com/jhleath/status/2044050779577954481) — the launch this article retroactively justifies on latency grounds

## Original Content

> [!quote]- Full X Article — Hunter Leath, "Is S3 faster than a file system?" (23 Apr 2026)
> Hunter Leath (@jhleath) — Thu Apr 23, 2026
> Article: "Is S3 faster than a file system?"
> 333 likes | 20 retweets | 5 replies
>
> Article: Is S3 faster than a file system?
>
> One of the most interesting things that used to happen to me when I was working at AWS was hearing from customers who told me that they "preferred to use S3 because it was faster than EFS". This was really funny to me because it's untrue, but it's also the experience of so many developers. Why is this.
>
> It's first important to define what we mean when we talk about "speed" of storage solutions. Storage solutions define their speed in two different axes: latency and throughput. "Latency" is the time that it takes for an individual operation to complete, and "throughput" is the number of operations (measured in either count or bytes transferred) that can complete on a system within a given second.
>
> Users, however, measure speed a different, much simpler, way. They run <SOMETHING> (this will differ per user) and measure the wall-clock time of that thing to actually complete.
>
> This is the truth of all products, you can work night and day on features and benchmarks, but your customers *do not care*. They just want the thing that they are trying to build to work well.
>
> Last week, we talked about how S3 is [speculated] to be hard-drive based storage and EFS (now, S3 Files) is [speculated] to be SSD-based storage. As a result, the *cost* of EFS is much higher (>10x), but the raw latency to access data on EFS is much faster.
>
> Now, I'm a storage engineer, so for me "speed" immediately translates to latency. Let's look at a latency diagram (and I'm sorry, but these will not be to scale today):
>
> *One 4KB read, within the AWS region. S3 on an 80 MB/s connection: 1ms network + 40ms time-to-first-byte + 0.05ms transfer. EFS / S3 Files on 500 MB/s: 1ms + 1ms + 0.008ms.*
> ![[jhleath-615871-001.jpg]]
>
> [aside: An interesting, but unimportant twist is that S3 throttles individual connections much more heavily than EFS does, so not only is it faster time-to-first-byte, but it's also faster transfer. Also consider this diagram simplified since, of course, there could be overlap.]
>
> It's important to note that there are several components of latency that we should be thinking about that come together to make the final number. There is network latency (how far away your client is from the service), there is "time to first byte" (how long it takes the service to find and locate the data that you want to read, and then "transfer latency" (how long it takes the networking equipment to literally transfer the requested bytes to the user).
>
> If you look at this, it seems obvious that users should think of EFS as the "faster" service, right? The latency is SO MUCH lower.
>
> I've thought deeply about this paradox for many years. It didn't click until recently when I was having a discussion with @ovaistariq about how they handle global performance with Tigris Metal. We, at Archil, need to make sure that our service is available *in the same data centers* where our customers are running to get good performance, which is a big cost on our business. When I asked how he thought about managing this, he told me something surprising -- this wasn't a problem for them.
>
> Tigris has the ability to rack-and-stack their own storage servers in centralized data centers around the world, and then let customers like Railway connect to centralized servers -- rather than needing to place them in the Railway data centers. This is a HUGE advantage. Let's talk about why this is possible.
>
> Our graph above is for a 4 KB read from a file, but what happens if we run a different kind of workload?
>
> [This is a bit tortured, so excuse me.] Let's say that rather than reading a 4KB file, we want to read a 1 MB file in 4KB chunks in some random order. Now, this turns into two different things in the S3 world and the file system world.
>
> In the S3 world, you *probably* just store the entire 1MB file in RAM. This is because you, the application author, knows that you're going to read the entire file. In the file system world, each 4 KB read needs to go to the file system to be served because Linux does *not* know that you are going to read the whole file. Rather than one operation, this is 256 operations.
>
> [aside: NFS and other protocols side-step this problem at small data sizes with "readahead" where they ask the server for a lot more bytes than requested by the user, so we're ignoring that here.]
>
> *Same region, 1MB file read in random 4KB chunks. S3 pays its 40ms TTFB once and transfers 12.5ms: 54ms total. EFS pays 1ms + 1ms + 0ms, 256 times over: 512ms total.*
> ![[jhleath-615871-002.jpg]]
>
> Woah! Suddenly, even though each individual file system operation is *much* faster than S3, you start to see how the "wall clock time" experienced by the user makes it look like a *slower* service.
>
> The root cause here, as with all things, is the protocol. Linux doesn't have the semantic information to understand what your application is trying to accomplish from a high-level goal, so it translates it into the smallest pieces. Whereas when you use S3, you *architect* your application around the storage, and specifically design it to eliminate duplicate requests.
>
> Now, here's the really weird part. Let's say that you're doing this computation in different geographic regions globally (or in AWS and a sandbox provider), but your data is sticking in the AWS region it was created in. This is going to increase the *network* latency of getting to the service. Or you're doing local development.
>
> The cross-US latency of a network request from us-east-1 to us-west-2 is about 60ms from https://www.cloudping.co/. How does that affect things?
>
> *The same 1MB random-chunk read from a laptop or across US regions. S3: 60ms + 40ms + 12.5ms = 113ms total, 2x slower. EFS / S3 Files pays the 60ms on all 256 operations: 15,616ms total, 30x slower.*
> ![[jhleath-615871-003.jpg]]
>
> Obviously, you don't want your application talking cross-region because it's going to increase the latency -- by more than 2x for people using S3! This isn't good, but look at the file system.
>
> Because the file system has *so many requests* for each higher-level operation, we actually see a much more significant slowdown -- 30x the expected latency!
>
> This is why the *network latency* between your server and the file system is *absolutely critical* for getting the performance that vendors expect. It's also why we shipped `archil utils speed-test` in our CLI so that our customers can measure it for themselves. Latency has an exponentially degrading effect on these customers!
>
> This is why Archil needs to be in the same data center as the customer, but object storage services do not.
>
> Getting around this "law of physics" problem is one of the motivating factors behind our recent launch, Serverless execution -- which lets users send bash commands to our service to be executed on the same servers running the Archil disks.
>
> If the program that we were running (read 4 KB chunks randomly from a 1 MB file) can be run on a Linux machine, then we can run it through Serverless execution instead. Let's see how that looks on the cross-region latency graph:
>
> *Archil Serverless Execution added as a third row: 60ms network paid once, 100ms to start the container, 256ms execution -- 416ms total, annotated "20% faster?" against the 512ms in-region EFS baseline.*
> ![[jhleath-615871-004.jpg]]
>
> Rather than incurring the network latency for *every* operation, we only have it once -- as part of connecting to the server to send the instruction to run our program. Then, we start the container *inside of the Archil service* and run the program *locally* cutting down the network latency (for the program) to near-0.
>
> This, oddly enough, lets the entire thing run (cross-region) faster than if you'd run the original program in the same AWS region as your EFS file system.
>
> This is an unintuitive result that we are super excited about!
>
> We have customers coming in every day who are trying to use Archil from locations where we don't have servers: their laptops, other regions, and other clouds -- because we make it simple. These people are usually (surprised) by the performance they get, primarily as a result of the network latency that they're experiencing.
>
> We hope that Serverless execution is a better way to let anyone, around the world, connect to the same file system without having to think about things like latency.
>
> The answer to the question at the top of the article is, of course, it depends. It's pretty simple to *accidentally* see file system performance that's slower than object storage, and it's our job at Archil to remove those footguns one by one, so that file systems can become a first class developer primitive for the AI age.

## Notable Replies

- **Richard Artoul ([@richardartoul](https://x.com/richardartoul/status/2047439880708325757))** asks the question the article's diagram implies but never states: "Does it actually run on the nodes hosting the customers filesystem, or is it just an arbitrary container on arbitrary node in your network that's close enough to your storage nodes?" Leath: **"it's the latter for now, but we will obviously work to bring them closer (same node) over time. the nice part about colocation is that, of course, the marginal cost of compute on our storage nodes is close to 0."** This qualifies the article's "run the program *locally* cutting down the network latency (for the program) to near-0" -- as shipped, it is same-network, not same-node.
- **Matthew O'Keefe ([@matthewokeefe1](https://x.com/matthewokeefe1/status/2047634930314711454))** places the argument in HPC lineage: building parallel file systems, "the big disconnect was the users expecting single node POSIX behavior when running parallel operations across a network from hundreds of servers. Smart users accepted they needed middleware... to buffer and coalesce lots of file operations in a few larger operations. But you're approach can be hidden from the user, which is much more powerful." The chattiness problem is decades old; the claimed novelty is making the coalescing invisible.
- **skullbloc ([@skullbloc](https://x.com/skullbloc/status/2047471702389453229))**: "it makes sense even though it's unintuitive at first... technical characteristics impact the actual human experience in such strange ways."

[Original article on X](https://x.com/jhleath/status/2047362676926615871)
