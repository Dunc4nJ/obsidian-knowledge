---
created: 2026-09-08
description: Archil founder Hunter Leath -- the AWS PM who in 2023 wrote the EFS/S3 strategy that shipped as S3 Files -- argues the product's 3 GiB/s per-client throughput ceiling is a direct consequence of choosing NFS, which resolves DNS once at mount and pins all metadata and data traffic to a single server IP, where Lustre and Archil instead split coordination from bulk transfer and scale both out.
source: https://x.com/jhleath/status/2042613823522377933
type: framework
---

## Key Takeaways

- The disclosure reframes the whole series: Leath says he was the AWS product manager who in 2023 wrote the strategy for uniting EFS and S3, and that "aws eventually launched my recommendation this week as s3 files." He is critiquing the shipped version of his own proposal from outside the company. That makes the architectural read unusually well-informed and the competitive framing unusually pointed — both at once.

- S3's apparent infinite throughput comes from having nothing to coordinate. `GetObject`/`PutObject`/`ListObjects` touch one key, need no synchronization, and each becomes a separate HTTP request over a separate TCP stream — so DNS round-robin and load balancers spread them across arbitrarily many frontends, and capacity grows by adding backend storage servers. The real bottleneck is the namespace cluster, which is what surfaces as S3's documented **5.5K IOPS per partition**. File systems cannot copy this: an atomic cross-directory rename must synchronize the old parent, the new parent, and the file itself, so reads are tightly coupled to metadata. This is the coordination tax that also pushes agent-facing file systems toward [[MongoDB's VFS for LangChain Deep Agents redefines grep as server-side hybrid search, splitting file bytes in S3 from a searchable chunk plane in Atlas|server-side query planes]] and [[SMFS makes grep itself a vector query so agents get RAG without learning a new tool|search-shaped syscalls]] instead of chatty POSIX — and it is why systems that want S3's scaling properties, like [[Cursor's Continuity replaces GitHub Spokes three-phase commit with an S3 write-ahead log as the source of truth for Git hosting|Cursor's S3 write-ahead log]] and [[Lakebase puts Postgres on open object storage as a third database generation - O(1) branching, sub-500ms compute start, and 7x space amplification as the price|Lakebase]], adopt object semantics rather than file semantics at the bottom of the stack.

- Lustre's fix is to separate the coordination plane from the bulk-data plane: the client first asks metadata servers where a file's parts live, then connects **directly** to storage servers for the bytes. Throughput grows by adding storage servers; IOPS grows by partitioning the metadata service. The split is the same one the agent-side virtual file systems keep rediscovering — [[a virtual filesystem over Chroma replaces sandboxes for agent doc exploration at 100ms instead of 46 seconds|ChromaFs]] and [[Leonie reimplements Mintlify ChromaFs as a virtual filesystem over Elasticsearch in an open-source POC|its Elasticsearch reimplementation]] put the index on the server and stream only matching bytes back. The catch is delivery, not design — the Lustre client was ejected from the mainline Linux kernel for complexity, so it ships as an out-of-tree kernel module against a Linux VFS interface that changes release to release. Leath's implicit point is that AWS picked NFS for distribution, not for performance, and the same distribution-versus-capability tension shows up wherever agent infrastructure must ship a client, as in [[Local-first agent sandboxes converge on libkrun not Firecracker because macOS has no KVM so Hypervisor framework is the only path - ghumare64 iii-sandbox deep dive|the libkrun-versus-Firecracker split on macOS]].

- The specific ceiling: an NFS mount resolves DNS **once at startup** and then sends every request — metadata and data alike — to a single IP. That yields a hard per-client cap of **3 GiB/s** on S3 Files, a number worth carrying into any agent-runtime design that assumes a shared mount can feed many concurrent sandboxes off one host, as [[Firecracker microVMs became the convergent agent runtime because containers were never a security boundary|dense microVM fleets]] and [[AgentFS]] do. AWS's own docs list aggregate read "up to terabytes per second," aggregate write 1-5 GiB/s, 250,000 read IOPS and 50,000 write IOPS per file system, "No limit" read/write IOPS per bucket, and 3 GiB/s maximum per-client read. Leath's aggregate-vs-per-client distinction is the load-bearing one: a single GPU host cannot saturate its NIC from S3 Files, which rules it out for model-training data loading. S3 Files does proxy large-file requests straight to S3 to dodge file-system bottlenecks, so this bites hardest on many-clients-one-host and small-file workloads.

- The escape hatches are asymmetric. AWS could adopt pNFS (NFS 4.2), which lets clients talk directly to storage hosts Lustre-style — but Leath is unsure it delivers equivalent metadata scale-out. Archil instead owns both client and server, which buys Lustre-style scale-out for data *and* metadata plus the freedom to ship protocol features without a standards body. That is the same own-the-whole-stack bet as [[Bash is the SQL for file systems and Archil proves it with serverless execution that sends instructions not data|Archil's serverless execution]] and the [[Archil's AFS-style checkout leases close the S3 Files latency gap that NFS metadata round-trips make permanent|AFS-style checkout protocol]] from the previous post, and it carries the usual proprietary-protocol cost: no kernel NFS client, no ecosystem fallback.

**Vendor caveat.** Leath sells Archil directly against S3 Files, and the cover chart (Archil "10 GB/s+" vs EFS 3 GiB/s per-client random read) is a vendor benchmark. The AWS documentation screenshot he cites is independently checkable and the NFS single-IP mechanism is standard behavior; the Archil number is not. The third post covers [[S3 Files charges Glacier-tier retrieval prices on SSD storage, breaking the cost-latency curve its own ex-EFS PM designed|pricing]].

## External Resources

- [on s3 files scalability](https://x.com/jhleath/status/2042613823522377933) — the source X Article, 10 Apr 2026
- [Amazon S3 Files performance specifications](https://docs.aws.amazon.com/AmazonS3/latest/userguide/) — the AWS User Guide page screenshotted in the article, source of the 3 GiB/s per-client and 250K/50K IOPS figures
- [Lustre](https://www.lustre.org/) — the open-source parallel file system whose metadata/storage split is the architectural comparison point
- [FSx for Lustre](https://aws.amazon.com/fsx/lustre/) — AWS's managed Lustre offering
- [pNFS (NFS 4.2)](https://datatracker.ietf.org/doc/html/rfc8435) — the parallel-NFS extension Leath names as AWS's potential fix
- [Archil](https://archil.com) — Leath's company, building a proprietary client+server protocol to get line-rate throughput

## Original Content

> [!quote]- Hunter Leath (@jhleath), X Article "on s3 files scalability" — 10 Apr 2026 — 74 likes, 1 retweet, 0 replies
>
> **Article: on s3 files scalability**
>
> *Cover benchmark: per-client throughput, single-instance random read — Archil 10 GB/s+ vs EFS (S3 Files) 3 GB/s*
> ![[jhleath-377933-001.jpg]]
>
> yesterday, i did a post on the latency characteristics of the s3 files product and why, for fundamental reasons, it will always appear to be an order of magnitude slower than using products like NVMe or EBS for workloads with small files or lots of metadata. today i want to talk about scalability.
>
> as a quick reminder, i'm Hunter, the founder of @archildata, and in 2023 I was the product manager at AWS responsible for coming up with a strategy for how we bring EFS file systems and S3 buckets together into one product. aws eventually launched my recommendation this week as s3 files.
>
> the flip side of latency (how long something takes to complete) is throughput (how many "things" can you do per unit time). when people talk about s3 being "super fast", they are not talking about latency (each operation takes a long time) but instead talking about throughput (it appears that you can just send requests at s3 ad infinitum without worrying about hitting limits).
>
> before talking about s3 files, let's highlight two systems that seem to have unlimited throughput: s3 itself (GetObject/PutObject), and the Lustre file system.
>
> the two underlying reasons for this are quite simple: first, s3 object operations (PutObject, GetObject, and ListObjects) are extremely simple for the s3 service to parallelize because they don't require any coordination to execute. second, each request (potentially) ends up as a separate HTTP request, resulting in a separate TCP stream.
>
> let's look at an [extremely simplified] diagram of the s3 service itself.
>
> *an [extremely simplified] diagram of the s3 service*
> ![[jhleath-377933-002.png]]
>
> for now, let's assume that each request to S3 creates a new TCP connection. each time you send a GetObject or PutObject to the s3 service, it's a new HTTP request. this means that you can do all of the usual load balancing tricks to spread those requests out across lots of frontend servers (lots of entries for the DNS record, actual load balancers, etc).
>
> you'll also notice that GetObject and PutObject only need to operate on the *individual* S3 object key that you send in. if you call GetObject for "/foo" and PutObject for "/bar" there's no synchronization that has to happen. in fact, if you simultaneously call PutObject for "/bar" from multiple places, you *also* don't really need to synchronize, you just have to make sure that one of them "wins".
>
> this means that each request can proceed to: (a) looking up the location of the data from the namespace cluster [on reads], (b) interacting with the raw storage servers, and (c) editing the location of the data in the namespace cluster [on writes]. because each object can be written to a new set of storage hosts, s3 can efficiently grow the throughput of the service by adding more backend storage servers (in addition to adding more frontend servers as needed)
>
> [aside: an astute reader will notice that the "bottleneck" here is how many operations you can do on the namespace cluster, which is what drives the 5.5K IOPS/s per partition (aka namespace cluster) that you see as an s3 limit]
>
> as a result, it's super simple to saturate the throughput of the instance that's calling s3. just make more requests. if you hit the 5.5K IOPS limit, then just use bigger objects. objects are simple for clouds to build, simple to use, we all love them.
>
> unfortunately, we're talking about file systems now. file systems have a nasty set of coordination properties that we have to enforce. for example, clients have the ability to do atomic renames across directories (i.e. i can rename "foo/hello.txt" to "bar/other.txt" in a single operation). this requires TONS of synchronization on: the original parent directory (make sure the file hasn't been deleted, the new parent directory (make sure nobody else has created a conflicting file), and the file itself (make sure nothing else has simultaneously moved it). this means that reading data is tightly coupled to the metadata of the file system itself.
>
> as a result, the industry developed a series of high-performance file systems known as "parallel file systems" which are used heavily in academic HPC clusters (think sequencing the human genome) and, more recently in AI model training. the most popular parallel file system is the open-source Lustre file system (which Amazon offers as FSx for Lustre, with the other clouds quickly following suit). how does Lustre get around this?
>
> *an [extremely simplified] diagram of the Lustre file system*
> ![[jhleath-377933-003.png]]
>
> you should immediately notice two things about this diagram: (1) it looks *pretty* similar to the s3 service if you ignore the frontend servers and (2) as a result, we don't really have any load balancing.
>
> s3 is (speculated?) to be based on hard-drives, as a result, the storage is slow (30ms-100ms to first byte). this means that sending bytes through an additional middle layer (1-2ms) is super cheap for s3, and they can have niceties like load balancing and a frontend. file systems are (often) built on top of SSD storage to try to lower latencies as much as possible (as we discussed yesterday). this means that they are very fast (1-2ms to first byte) but also cannot accept additional 1ms hops.
>
> what they've actually done is separate out the parts that need coordination and synchronization (sent to the metadata servers) from the bulk data transfer (which comes from direct connections to the storage server). you'll note that the client needs to be smarter than the s3 client (the s3 client only needs to send an HTTP request to the s3 frontend server, and s3 will take care of fetching and handing you the data from where it lives) whereas the Lustre client needs to have logic to first connect to the metadata service, ask it to locate the parts of the file that it needs to read, then have the ability to connect directly to those storage servers to transfer the raw bytes.
>
> this provides some nice scalability properties. you can grow the throughput of the system by adding more storage servers -- and the metadata server can intelligently route new file creation to the storage servers that have the most throughput capacity. growing iops capacity requires clustering and partitioning the metadata service, which many managed Lustre offerings now support.
>
> this is great! and it's one of the reasons why Lustre is so widely adopted these days. there's just ... this one ... thing. the Lustre file system client was kicked out of the mainline Linux kernel for being too complex for kernel devs to work with. this means that if you want to use Lustre, you need to manually download a kernel module. because the Linux file system internal interface (for some reason) changes release-to-release, you better hope that you get the correct version of the Lustre client and that your kernel isn't too new.
>
> so if you're amazon, what's the better solution here for building efs (now s3 files), use NFS! it's universally adopted, has support in the linux kernel, and developers are super familiar with it. great, let's look at that architecture for the supported NFS 4.1 (w/o pNFS):
>
> *an [extremely simplified] diagram of the EFS / S3 Files architecture*
> ![[jhleath-377933-004.png]]
>
> oh, hrm. this one looks different. for one reason, EFS's architecture isn't public like the other two, so we have to infer a bit from how NFS works. but we can see that for big files the S3 files implementation *will* proxy requests directly to S3 in order to avoid any file system bottlenecks, which is great!
>
> the problem comes from NFS itself. NFS mounts will resolve DNS once on startup and then send all requests to a single IP address. this means that all metadata operations and all data operation have to go to a single machine on the other side of the wire.
>
> this, unfortunately, isn't scaleable and provides a hard limit on the amount of throughput than an individual client can drive through s3 files: 3 GiB/s.
>
> *The AWS S3 Files performance specifications table: aggregate read up to terabytes per second, aggregate write 1-5 GiB/s, "No limit" read and write IOPS per bucket, 250,000 read IOPS and 50,000 write IOPS per file system, 3 GiB/s maximum per-client read throughput*
> ![[jhleath-377933-005.jpg]]
>
> [aside: gotta give the s3 files folks credit for going for the gold with the "no limit" on the IOPS per s3 bucket rows, that's pretty funny to me and something i'll add to my docs]
>
> this means that S3 Files can't be used to saturate the NIC of larger instances, notably those with GPUs, which makes it not super useful for high-scale applications like model training which need to ensure that they're always pushing enough data into the GPU to keep up.
>
> can amazon fix this? potentially, pNFS is a new feature in NFS added in 4.2 that allows the NFS client to operate closer to how the Lustre file system works (talking directly to storage hosts), but it's not totally clear to me whether it provides the same level of metadata scale-out.
>
> this fundamental limitation is the second reason why we decided to write our own protocol at @archildata. in addition to the reasons we talked about yesterday with allowing us to build a file system product that has the latency characteristics of EBS, it also allows us to do the same scale-out trick that the Lustre file system uses (for both data and metadata) to achieve line-rate throughput for model training workloads.
>
> owning both the client and the server allows us to iterate on new file system features faster than waiting for a standards body (like Lustre or NFS) to catch up to what the world needs.
>
> of course, i expect that many people who are running small applications will be fine with the scalability of s3 files, but we're not solving for "most people" at Archil. we're trying to build the storage layer that will become the default for all applications over the next 5 years.
>
> — [x.com/jhleath/status/2042613823522377933](https://x.com/jhleath/status/2042613823522377933), Fri Apr 10 14:41:00 +0000 2026
