---
created: 2026-09-08
description: Archil's Hunter Leath gives buyers a single diligence question for the wave of neo-clouds and sandbox providers selling "persistent disks" — what does the provider do when the application calls fsync() — and splits the market into a safe model that replicates across hosts before acknowledging and an unsafe one that acknowledges on local NVMe and flushes to durable storage asynchronously.
source: https://x.com/jhleath/status/2067978038437179597
type: framework
---

## Key Takeaways

- **One question separates safe persistent disks from marketing: what happens on `fsync()`?** Leath's diligence test is that narrow, and it works because `fsync` is where the file system's durability contract actually lives. Object storage set the industry's intuition — PutObject returns, the data is safe, at "11 9s" of durability — and file systems do not work that way. Create-file, set-attributes and write-data all complete in memory; only `fsync` promises anything. (This is why the Eject button exists on a Mac SD card or a Windows USB drive: it calls `fsync`.) If a provider cannot tell you whether an `fsync` acknowledgement means the data is on multiple hosts, the honest reading is that it isn't.

- **The two models, with the vendors named.** *Safe*: on `fsync`, the storage service redundantly stores across multiple hosts before acknowledging — Leath's list is Archil, S3/GCS on PutObject, EBS/Hyperdisk, [[Amazon S3 Files ends the object-file split for AI agents|EFS/S3 Files]], and raw-NVMe services like PlanetScale Metal where Vitess plays the storage-service role. Host count and per-host data volume vary so each service can tune cost, throughput amplification and durability ("5 9s vs. 11 9s"), but the shape is fixed, and his flat claim is that "it's not possible to keep data stored safely on a single SSD." *Unsafe*: acknowledge `fsync` as soon as the write hits local disk and let an on-host service push asynchronously to S3 or Ceph. That wins write-throughput benchmarks — database write speed *is* fsync throughput — and leaves a window where a server death erases an acknowledged write.

- **The harm is specifically that the acknowledgement already escaped into the world.** Leath's framing is worth keeping: "There is a deep evil in data loss because once the storage layer tells the application that the data is safely stored, any number of application-level and meatspace-level actions could occur expecting the data to be there on the next read." His escalation — a user account that says saved then can't log in, an airline ticket confirmed then lost, a record of medicine administered to a patient — is the argument for why "we might lose the last few seconds" is not a bounded loss. He names MongoDB as the historical example of trading fsync discipline for benchmark numbers, which is pointed given that [[MongoDB's VFS for LangChain Deep Agents redefines grep as server-side hybrid search, splitting file bytes in S3 from a searchable chunk plane in Atlas|MongoDB now sells agent-facing storage]].

- **Two footnotes that are load-bearing.** The "11 9s" figure is *per object*, so as you approach 100 billion objects you should be reasoning about your own protection rather than delegating it to Amazon — a scale most agent-storage pitches quietly assume away. And server death rates are often *higher* at hyperscalers than in other data centers, because AWS and GCP won't replace part of a server (a failed network card, say) and hand you back the intact disk. Together these undercut the "the cloud handles durability" default that the whole neo-cloud category is priced against — and they raise the stakes for [[agents need a database because stateless reasoning cores require stateful storage|every argument that agents need real stateful storage]], including his own [[serverless hosting is the MCP of the hosting world and Archil, exe.dev and Fly.io Sprites bet agents debug better on one box|proposal to stuff your code, database and logs into one file system]]. That proposal is only sound if the file system underneath is running the safe model.

- **This is the durability half of the same thesis his other articles argue from the performance side.** [[Archil argues local storage is a special case of remote storage - full residency plus writes acknowledged before they are durable|His "local storage is a special case of remote storage" piece]] defines local disk precisely as full residency *plus* writes acknowledged before they are durable — this article is the consequence of the second half of that definition, spelled out for buyers. It also sits directly under [[Archil argues every cloud workload is the same compute-SSD-S3 shape, so a POSIX write-ahead log on S3 can be the last one anyone builds|the POSIX-write-ahead-log-on-S3 argument]], since a WAL is how you get safe-model semantics without paying multi-host latency on every small write — the same move [[Cursor's Continuity replaces GitHub Spokes three-phase commit with an S3 write-ahead log as the source of truth for Git hosting|Cursor made with Continuity]] and the reason [[Lakebase puts Postgres on open object storage as a third database generation - O(1) branching, sub-500ms compute start, and 7x space amplification as the price|Lakebase can put Postgres on object storage at all]]. The durability question also cuts against his own [[Archil's million-sandboxes-per-second blueprint buys 10ms placement with deliberately stale capacity data and moves container images off the cold-start path|million-sandboxes blueprint]], where customer container images live on Archil disks and the control plane deliberately runs on stale state.

- **Read it as competitive positioning aimed at a specific set of rivals, because that is what it is.** The article never names an unsafe provider, but the target set — "neo-clouds", "compute platforms", "sandbox providers" claiming persistent disks — is exactly the market Archil competes in, and the closing line is "If they don't replicate it to multiple machines, like Archil does." Archil appears first in the safe list, unaudited. The technical content is correct and checkable; the framing is a question designed so that only some vendors have a good answer. That said, the test is genuinely useful against the vault's sandbox cluster: [[Opencomputer reframes harness-vs-sandbox debate as git branches for VMs via hibernation egress proxies and checkpoints|Opencomputer's checkpoint/hibernation model]], [[Firecracker microVMs became the convergent agent runtime because containers were never a security boundary|Firecracker snapshot/restore]], and [[Archil argues today's agent sandboxes are a better EC2 not serverless, and the end-state is a query language over the file system|every sandbox that promises the disk survives a pause]] are all making a durability claim that this question interrogates. Aakash Shah's reply is the compressed version: "the word 'persistent' on a neocloud disk is doing the same work 'fat free' does on a candy bar."

## External Resources

- [Dan Luu, "Files are hard" (Deconstruct 2019)](https://www.deconstructconf.com/2019/dan-luu-files) — the atomicity-of-file-systems talk Leath defers to rather than re-deriving
- [PlanetScale Metal](https://planetscale.com/metal) — cited as a raw-NVMe service that still fits the safe model, with Vitess acting as the storage service
- Archil (@archildata) — Leath's company; listed first among the safe-model providers and the subject of the closing pitch
- [Aakash Shah's reply](https://x.com/aakashdotio/status/2068177717976055856) — "the word 'persistent' on a neocloud disk is doing the same work 'fat free' does on a candy bar"

## Original Content

> [!quote]- Full text of "Be careful which \"persistent\" disks you trust" by Hunter Leath (@jhleath), Jun 19 2026
> Hunter Leath (@jhleath) — Jun 19, 2026
> Article: "Be careful which \"persistent\" disks you trust"
> 56 likes | 5 retweets | 1 reply
>
> It feels like there are hundreds of new infrastructure companies popping up every day, and because these companies all recognize that the next set of workloads (namely, AI agents) are stateful workloads most of these companies are marketing explicitly about being able to "persist disk state" so that you don't have to worry about whether or not your data will be around if the compute stops while you're not using it.
>
> However, not all "persistent disks" are created equal. Let's talk about how data is stored safely, what kinds of things your infrastructure provider could be doing, and what questions you should be asking to safely run persistent workloads in the cloud.
>
> Isn't all data safe?
>
> Like most things related to data storage, S3 and object storage have ruined the conversation by making it so easy to use storage that people have forgotten how things outside of that ecosystem work. One of the ways that object storage won the data storage world is around durability or "when data is safe after storing it".
>
> Object storage had the innovative idea that once a call to PutObject returns successfully, it would be safely stored in the backend storage system -- for many, with "11 9s" of durability.
>
> *The object-storage contract: the application calls PutObject, and by the time it receives the response the data is also stored safely*
> ![[jhleath-179597-001.png]]
>
> [side note: It's not immediately obvious to people that the "11 9s" number is per-object. This means that as you approach 100 billion objects stored, you might want to start thinking about how you're protecting that data as opposed to just letting Amazon handle it for you.]
>
> This isn't exciting, right? Like, on my laptop if I call "cp", "mv", "git clone" -- the data is safely stored on my hard drive once those calls complete, right?
>
> Like with many unintuitive things in file systems, it turns out that this is not the case.
>
> You see, object storage is designed for handling raw throughput, so they want you to optimize for sending and receiving large objects, as a result, it's not a performance problem to always make the data durable when you put the entirety of these large objects. This is not, however, what file systems are optimized for.
>
> File systems are optimized for lots and lots of small writes which could be: file creation, metadata updates, file data changes. If we were to persist each of these to the disk when they happen, it would cause a tremendous performance bottleneck as we both need to (a) wait for the disk to do this work and (b) bottleneck on the disks ability to execute raw operations per second.
>
> Instead, the file system has a different mechanism -- fsync -- that allows the application to tell the operating system that *actually* it's now time to put the stuff that I just wrote onto the disk. That looks like this.
>
> *The file-system contract is different: create file, set attributes and write data all happen in memory, and "only at this point" — the fsync — "is everything guaranteed to be saved"*
> ![[jhleath-179597-002.jpg]]
>
> Now, for many, many reasons (including the operating system trying to push stuff to the disk asynchronously), this turns out to mostly be okay and data loss is super rare -- even on personal machines that tend to turn on and off randomly. Notably, this is [of course], why you need to "Eject" an SD card on your Mac, or a USB drive on your Windows computer. That button calls fsync() so that any in-flight writes are stored safely. If you don't do this, then you might lose the last few seconds of recent writes, but... do we care?
>
> Why should I care if I have data loss?
>
> [There's lots of writing on the atomicity of file systems](https://www.deconstructconf.com/2019/dan-luu-files), so let's focus on a simpler problem -- databases. Every major open-source production database system (SQLite, Postgres, and MySQL) work by storing their data on top of a file system. You can actually think of databases as an API that allows you to more easily and safely work with the file system.
>
> Notably, they are the one class of application which rigorously and correctly works to call fsync(). This is because they want to ensure a simple property: if you mutate a table (say, insert a row), when the call returns success, it should be impossible (absent drive failure) to lose the data associated with that write. This looks something like this:
>
> *How a correct database uses that contract: edit database files, fsync, and only then return success to the user for the INSERT*
> ![[jhleath-179597-003.jpg]]
>
> Even though the operating system is only editing the database files in-memory, the database won't respond to you until the fsync is actually complete. Why is this important? Well, let's imagine that we build a faster database that doesn't call fsync to make the data safe during each mutation. Let's, hypothetically, call that database MongoDB.
>
> *The "faster" database that returns success before the fsync: INSERT, return success, system crash, and the subsequent SELECT finds nothing*
> ![[jhleath-179597-004.jpg]]
>
> This is going to be way faster on benchmarks (insertions are just in-memory operations), but on any system crash, we might lose the most recent few seconds of data. Now, in some cases, this could be benign (it's fine if we lose analytics data), but in most cases it's NOT benign specifically BECAUSE we already told the application that the write was successful.
>
> Imagine that you're creating a new user account by inserting it into your database, your database says that it's saved, and then when the user goes to log in -- it doesn't work! Worse, what if it's an airline ticket that the Airline told you was successfully purchased, but then it turns out that they lost the ticket! Worse still, what if it's a record of medicine that's been administered to a patient?
>
> There is a deep evil in data loss because once the storage layer (the database, in this) tells the application that the data is safely stored, any number of application-level and meatspace-level actions could occur expecting the data to be there on the next read.
>
> How does this affect 2026?
>
> The challenge that we see today is that suddenly so many different "neo-clouds", "compute platforms", "sandbox providers", and more are popping up to try to serve this new class of highly-stateful workloads. Each one of these companies is (correctly) making different trade-offs to serve a slightly different set of workloads better. This could be differences in networking, the way that you access the machine, the places where the machines run.
>
> Notably, most of these providers claim that they are all the first people to build stateful compute services, by persisting the disks that you use on their services, but they aren't all forthright about how they persist this data. Depending on how they do it, it could be completely safe, or it could be a really, really bad time for your users. Worse, you usually won't know about hitting these problems until something goes wrong and you've lost data, when there's nothing to do about it.
>
> There are basically two models here, and it completely depends on what the provider does the application calls fsync. First, the "safe model":
>
> *The safe model: the application issues an fsync and the storage service redundantly stores the data across multiple servers before acknowledging*
> ![[jhleath-179597-005.png]]
>
> The safe model is how all major storage services are architected today: Archil, S3/GCS (on PutObject), EBS/Hyperdisk, and EFS/S3 Files. When the application requests that data be stored safely (by calling fsync), the storage service (either running on the machine like EBS/Hyperdisk or off machine like EFS/Archil) is going to redundantly store that data across multiple hosts, so that no individual host failure can result in data loss. This is also how services that operate on "raw NVME" like Planetscale Metal work, with the "stroage service" in this case being Vitess.
>
> Now, the specific number of hosts that they store on, and the amount of data on each host may vary so that each service can tune its costs, throughput amplification, and durability "5 9s vs. 11 9s", but the basic model is the same. It's not possible to keep data stored safely on a single SSD safely.
>
> Of course, this incurs a performance penalty and a cost penalty, so if you're a provider trying to win on benchmarks (like MongoDB was), you might look to implement a system that looks more like the following:
>
> *The unsafe asynchronous model: the fsync lands on local NVMe ("damn, that's fast") and an on-host storage service async-reads it out to a durable system later — leaving a window where the only copy is on one machine*
> ![[jhleath-179597-006.png]]
>
> You could hypothetically just acknowledge fsync calls as soon as the changes hit the local disk, and have an on-host service kind of asynchronously push the data to a more stable storage system like S3, or a clustered storage system like Ceph.
>
> This causes your benchmarks to speed up for sure, especially when you're running database workloads where write-speed is defined by fsync throughput. But it's not safe. Why not?
>
> For those few seconds before it's pushed to the real storage service, data is only stored on the single host NVMe. This means that your database could have acknowledged a write to a user, the user could have done something, and a server death could erase that database write.
>
> Now, in this architecture, there are different levels of "safety". If they actually require that the write hit the disk before acknowledgement, then a server restart might not be enough to lose data (assuming that they recover and flush the local disk when the server comes back online), you would have to have the server die.
>
> But, folks who've worked on cloud services for long enough know that servers die all of the time. And, if you assume that users are continuously writing data to their disks, then there's always something for the server to lose when it inevitably dies.
>
> [side note: Often, server death rates are actually higher in hyperscalers than other data centers because AWS and GCP are unwilling to replace just part of the server (e.g. if the network card fails) and you the intact disk back. Just one of the pleasures of running a storage service.]
>
> Where does this leave us?
>
> If you're relying on a providers persistent disks in order to keep your workloads alive, ask them what they do when the application calls fsync(). If they don't replicate it to multiple machines, like Archil does, then it's probably not a safe place to run workloads with critical data, and definitely not a safe place to run databases.

### Reply thread

> [!quote]- Replies on the thread
> **@aakashdotio (Aakash Shah)** — Jun 20, 2026
> @jhleath the word "persistent" on a neocloud disk is doing the same work "fat free" does on a candy bar.

Original: https://x.com/jhleath/status/2067978038437179597
