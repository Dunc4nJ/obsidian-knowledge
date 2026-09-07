---
created: 2026-09-08
description: Archil founder Hunter Leath argues S3 Files (EFS) will always be an order of magnitude slower than EBS for interactive workloads because NFS forces every mutating metadata operation to round-trip to the server, and that Archil escapes this by replacing NFS with an AFS-style protocol where clients check out exclusive write access to file system subtrees and regain local write-back semantics.
source: https://x.com/jhleath/status/2042238023367336298
type: framework
---

## Key Takeaways

- The performance ceiling on [[Amazon S3 Files ends the object-file split for AI agents|S3 Files]] is protocol-level, not engineering-level. On a local disk or an EBS volume, "creating a file" writes nothing — the kernel buffers the metadata change in memory until an application calls `fsync`. Under NFS, if two clients might both create `hello.txt`, only the server can arbitrate, so every mutating metadata operation must round-trip. Leath's conclusion is that no amount of latency-shaving by the EFS team changes the asymptote: file systems built on NFS stay an order of magnitude behind block storage on interactive, metadata-heavy work. This is the same coordination tax that pushes agent file systems toward [[a virtual filesystem over Chroma replaces sandboxes for agent doc exploration at 100ms instead of 46 seconds|server-side indexes]] and [[MongoDB's VFS for LangChain Deep Agents redefines grep as server-side hybrid search, splitting file bytes in S3 from a searchable chunk plane in Atlas|server-side grep]] rather than chatty per-file protocols.

- Archil's answer is Andrew File System-style checkout, not faster NFS. Clients "checkout" and "checkin" parts of the tree to claim exclusive write access; while a client holds that lease it can use the same write-back durability semantics as EBS or NVMe, buffering in memory until asked to flush. The point is not a faster round-trip but the elimination of the round-trip for the duration of the lease, which is why Leath says the speedups came "without spending much time at all doing performance optimization work." It is the same architectural instinct behind [[Bash is the SQL for file systems and Archil proves it with serverless execution that sends instructions not data|Archil's serverless execution]] — move the decision to where the data is instead of paying network cost per operation.

- The cover benchmark is the concrete claim: a monorepo `git clone` in 19s on Archil versus 2m 14s on S3 Files (EFS), roughly 7x. Git clone is the ideal case for this argument — thousands of small file creations, almost pure metadata — so it is both the most honest illustration of the mechanism and the most flattering possible benchmark. Treat it as a shaped demo, not a general speedup factor.

- Leath's own reply concedes the nuance that the article omits: a *durable* write round-trip to EFS/S3 Files is 1-2ms, and Archil is "probably a little worse at 3-4ms." In-memory work over FUSE is 1-4us. So Archil is slower than EFS per durable operation; the entire win comes from checkout letting most operations avoid durability round-trips at all. Any evaluation that measures forced-`fsync` throughput will not reproduce the headline numbers.

- The strategic frame matters more than the benchmark: Leath says beating EFS was never the goal — "to become the default way that users store data in the cloud, you have to unseat EBS." Most managed data products (PlanetScale non-Metal, Supabase, non-Aurora RDS) are wrappers around an EBS volume, and teams only migrate to EFS when they need horizontal scale-out or HA. Archil is aiming at the substrate those products sit on, which is a far larger surface than the file-storage category and puts it adjacent to [[Lakebase puts Postgres on open object storage as a third database generation - O(1) branching, sub-500ms compute start, and 7x space amplification as the price|Postgres-on-object-storage]] and [[Cursor's Continuity replaces GitHub Spokes three-phase commit with an S3 write-ahead log as the source of truth for Git hosting|S3-as-source-of-truth]] designs.

**Read this as competitive positioning, not neutral analysis.** Leath founded Archil, which sells directly against S3 Files; he also hired engineers off the AWS product he is critiquing. The mechanism he describes (NFS metadata round-trips) is real and well-documented, but the benchmarks are vendor-run and workload-chosen. The follow-ups in this series cover [[S3 Files caps a single client at 3 GiB per second because NFS resolves DNS once while Lustre and Archil scale metadata and data separately|scalability]] and [[S3 Files charges Glacier-tier retrieval prices on SSD storage, breaking the cost-latency curve its own ex-EFS PM designed|pricing]].

## External Resources

- [on s3 files performance](https://x.com/jhleath/status/2042238023367336298) — the source X Article, 9 Apr 2026
- [Archil](https://archil.com) — Leath's storage product; the AFS-style protocol described here is its core differentiator
- [Andrew File System](https://en.wikipedia.org/wiki/Andrew_File_System) — the 1980s CMU file system whose callback/checkout model Archil's protocol is styled after
- [Amazon EFS / S3 Files](https://aws.amazon.com/efs/) — the product under analysis
- [Amazon EBS](https://aws.amazon.com/ebs/) — the block-storage baseline Leath measures against

## Original Content

> [!quote]- Hunter Leath (@jhleath), X Article "on s3 files performance" — 9 Apr 2026 — 243 likes, 18 retweets, 15 replies
>
> **Article: on s3 files performance**
>
> ok differentiation time. i've always explained to people that efs (s3 files) didn't reach its full potential for three reasons: performance, price, and a weird competition with s3 for primary storage.
>
> aws has taken the competition with s3 off the table (which is awesome), but today let's talk about perf.
>
> efs is a big business these days, but it's not as big as aws's biggest SSD business: the elastic block store (ebs).
>
> ebs is the drive that you get when you launch an EC2 host. it lets you detach the drive from one host (keep the data if the instance is terminated), it lets you size up the disk size (but not down), and it gives you a *durable* device that you can use to run regular software on and not worry about data loss.
>
> as a result, most database products (until @samlambert started pushing Metal) including PlanetScale (non-metal), Supabase, RDS [non-aurora], and some other AWS file products are *just* wrappers around EBS volumes running database and file system software on top. lots of other infra companies are building their own "EBS on top of S3" to expand this primitive.
>
> why doesn't every piece of software in AWS just use EBS? availability and scale.
>
> ebs drives are like the disks that are attached to your laptop. they don't have any logic inside of them to allow multiple machines to coordinate on the same set of data.
>
> this means that if you want to have truly zero-downtime deployments, you can't put your data on an EBS volume because the data will be unavailable while the (single) instance attached to it needs to restart.
>
> usually, this is how we would see people start to migrate to a file system product like efs. file systems are smart, you tell them about what files you're creating and using, and they can use that information to allow multiple clients to connect to the same data set safely. as a result, people would migrate from ebs to efs when they needed to: (a) horizontally scale their existing applications to multiple machines or (b) add high-availability.
>
> the problem? when someone migrated to efs, their application would explode. not literally, but the performance would get *really bad*.
>
> *Cover benchmark: cloning a monorepo, git clone wall-clock time — Archil 19s vs S3 Files (EFS) 2m 14s*
> ![[jhleath-336298-001.jpg]]
>
> this is a fundamental difference in how file systems and block storage works. when you "create a file" on your laptop, or in AWS with an NVMe or EBS volume, there is **no data written to disk**. the kernel just notes this in-memory until an application requests a disk-write using fsync.
>
> when you use a file system like EFS (or any NFS-based file system), that's not the case. if user A and user B are both connected to drive and both want to create "hello.txt", the only place where we can decide *which* user is able to create the file is the server.
>
> as a result, metadata operations in NFS need to round-trip to the server for every mutating operation. this makes it unusable for many kinds of applications, and it also means that despite the EFS/S3files team employing tons of great engineers who are working diligently to reduce per-operation latencies, it will always be an order of magnitude slower than EBS for most interactive workloads.
>
> i think this is a terrible proposition. file storage offers so much *more* than block storage: usage-based pricing, understanding semantically what the user is trying to do, and offering offline access. there is no reason why we need to accept that they are just *so much slower* than regular block storage.
>
> at archil, we didn't. we worked to get around this by building our own protocol (replacing NFS) in the style of the Andrew File System (AFS). our protocol allows clients to "checkout" and "checkin" different parts of the file system to indicate that they want exclusive write-access to it.
>
> when a client has exclusive write access to part of a file system, it's able to use the same durability semantics that a file system has when using EBS or NVMe (don't write to disk unless asked) and close the performance gap.
>
> in effect, this means that we've seen remarkable speedups over EFS/s3files without spending much time at all doing performance optimization work.
>
> it's also why we were able to hire people who were working on this product. beating s3 files (efs) was never our end goal, becoming the default way that users store data in the cloud was. and to do that, you have to unseat ebs.
>
> — [x.com/jhleath/status/2042238023367336298](https://x.com/jhleath/status/2042238023367336298), Thu Apr 09 13:47:42 +0000 2026

### Substantive replies

> **@mattrickard (Matt Rickard)** — Apr 9
> @jhleath curious -- what orders of magnitude are we talking here? how much does a subtree lock save you? for maybe a typical agent workflow
>
> raw ebs
> afs
> efs/nfs
> cephfs

> **@jhleath (Hunter Leath)** — Apr 9, replying to the above
> well, thing of it like this -- a durable write round-trip to EFS / S3 Files is going to be in the ballpark of 1-2ms. we're probably a little worse at 3-4ms.
>
> if you do this work in-memory instead of going across the network it should be closer to 1-4us (over FUSE, which is itself slower than a kernel file system)

> **@jhleath (Hunter Leath)** — Apr 9, on pricing (previewing the third article)
> @jonbeckman planning a bigger post on pricing tomorrow, but the tl;dr is that we should be *much* lower cost. we don't have per-transfer pricing like S3 files, and we're also 33% cheaper on high-performance storage.

> **@siddontang (siddontang)** — Apr 10
> @jhleath I'd push back a bit on the database part. (Disclosure: I'm one of the authors of TiDB.) Even when databases run on EBS, most HA designs I know don't rely on the filesystem layer, they rely on replication protocols like Paxos, Raft, or sometimes async replication.

> **@QuinnyPig (Corey Quinn)** — Apr 9
> @jhleath Not to be that guy, but TECHNICALLY io1 and io2 EBS volumes support multi-attach.
>
> You won't enjoy it. But the possibility is there.

> **@ejc3 (EJ Campbell)** — Apr 10
> @jhleath Why doesn't AWS offer checkouts?
>
> With s3 file, they are already offering variable latency with their reads off of s3 into cache, so it's not like they support consistent read performance anymore.
>
> So your arch seems strictly better.

> **@dannyighsu (Danny Hsu)** — Apr 9
> @jhleath Love it - every time we've encountered this problem (starting in '25 when sandboxes were not really a thing yet) we'd have this debate w stakeholders about how EBS doesn't meet agent reqs and vanilla EFS/S3 latency is a nonstarter.

> **@barrowjoseph (Joe Barrow)** — Apr 9
> @jhleath Similar story to S3 Vectors. Worse than existing offerings in terms of perf and limitations.
>
> This wasn't clear to me when it came out but the deal seemed to get worse the more I worked with it.
