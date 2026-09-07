---
created: 2026-09-08
description: Hunter Leath's primer on file storage -- block devices as fixed-length arrays of 4KB blocks with no transactional semantics, the file system as the metadata layer over them, POSIX and fsync, why S3 is not a file system, and why shared file storage costs a network round trip per operation instead of a 1us context switch -- ending with Archil's fix - the server hands exclusive write ownership of subtrees to individual clients so the local Linux kernel serves reads and writes without touching the server.
source: https://x.com/jhleath/status/2089401964568469558
type: framework
---

## Key Takeaways

- **The taxonomy is the most useful 60 seconds of the piece, and it is a correction most agent-infrastructure writing needs.** A real file system is XFS or ZFS locally, NFS or Lustre remotely. Not file systems: S3 object storage, Box or Dropbox, and "a homegrown solution on top of a database like SQLite or Postgres". The distinguishing property is not remoteness or durability but the POSIX operation set -- directories, offsets, renames, partial overwrites, attributes -- which is what "the vast majority of software ever written (including all modern databases)" is written against. This directly sharpens the debate in [[a file system is not all you need - databases beat markdown for agent context provenance and governance]]: the two sides are not arguing about the same object. It also explains why [[Hermes, Codex, and Claude Code converge on markdown plus filesystem tools because memory is a judgment problem not a data structure problem|harnesses converging on "markdown plus filesystem tools"]] are relying on POSIX semantics they rarely name, and why swapping in an object store underneath quietly breaks them.

- **A block device is a fixed-length array of 4KB buckets with a three-function interface and no transactional semantics, which is why single-writer is structurally required rather than a design choice.** `getLength() --> blockCount`, `readBlock(blockId) --> (data, error)`, `writeBlock(blockId, data) --> error`. There are no conditional updates, so concurrent writers from multiple locations are unsafe -- a constraint "usually trivially satisfied by the fact that a block device is directly-attached to a single computer at a time". Everything above (file systems, and the servers in front of them) exists to add metadata management and, eventually, multi-writer concurrency control on top of that bare interface. This is the substrate assumption underneath [[Bash is the SQL for file systems and Archil proves it with serverless execution that sends instructions not data|Leath's earlier argument that bash is the file system's SQL]] -- the reason a file system can host embedded compute at all is that it already owns the metadata layer a raw block device does not have.

- **`fsync` is the hinge of the whole essay: without it, file operations are pure in-memory work at ~1us, and the entire remote-storage penalty is the difference between that and a network round trip.** "It turns out that [for performance reasons] you basically ~never want to actually talk to the disk." This is why `git clone` and `npm install` -- which never call fsync -- are in-memory operations, while SQLite, which fsyncs after every INSERT, actually measures the storage hardware. Remote file systems must contact the server *for every operation* so it can reject conflicting writes, turning 1us into "hundreds of microseconds to milliseconds" plus possibly a replicated block write. His diagram prices this at 1us local vs 1us + 500us + 100us remote. That is the mechanism behind the folklore that `git clone` on NFS is unusable.

- **The S3 workaround is the industry's actual architecture and it does not scale, and Leath names a consequence most agent teams feel without diagnosing:** work on a local block device, then "spend time packaging it up and shipping it up to something like S3 for longer-term storage." Upload and download time grow with data size, and "this is one of the core reasons why sandbox boot-up time will take longer depending on how large your image is -- they're just stored in S3 and need to be fully downloaded before your sandbox can start up." Every lazy-loading image format and local disk cache is papering over this. It is the same wall [[Browser Use stitches stateless Lambdas into multi-hour browser agents via S3 checkpoints and SQS continuations|Browser Use hits with S3 checkpoints]] and that [[Firecracker microVMs became the convergent agent runtime because containers were never a security boundary|Firecracker-based sandbox fleets]] work around with snapshotting.

- **Archil's mechanism, stated precisely: the server detects which files and folders each client is working on and delegates ownership so the local Linux kernel serves those reads and writes without hitting the server; on contention, ownership moves back to the server for conflict detection.** The empirical premise is that "most workloads don't actually require conflicting writes to the exact same file" -- in multi-client workloads clients usually touch different files or directories. Leath claims this is what makes Archil "up to 100x faster than other file storage solutions", enough to use as primary storage for `git clone` and `npm install`. Note the claim is a speedup over other *shared* file storage, not over local disk. The same substrate-swap-under-POSIX move shows up in [[Leonie reimplements Mintlify ChromaFs as a virtual filesystem over Elasticsearch in an open-source POC|ChromaFs-over-Elasticsearch]] and in the broader pattern of [[databases are becoming the runtime layer for AI agents as application logic collapses into the data layer|pushing runtime into the data layer]]; what differs is whether the win comes from co-locating compute, changing the index, or -- as here -- moving the *authority* rather than the data.

- **The replies extract the detail the article elides, and Leath's answers are the technically load-bearing part.** Asked by Noah Watkins whether this is an exclusive lease on part of the hierarchy (as in CephFS), Leath: "it's an exclusive *write* lock, readers can still use that portion of the tree, but they won't see data which hasn't been fsynced yet" — so the consistency model is fsync-visibility, not read-your-writes across clients. And: the server keeps "a covering partition across the file system to delegate the subtrees to each client", which "needs to be revocable if the client goes away and/or another client needs to share write access". Ahmet Alp Balkan's objection that the article is hand-wavy on this is fair as written; the answer is a revocable write lease, a known distributed-FS primitive rather than a novel one. Contrast [[Cursor's Continuity replaces GitHub Spokes three-phase commit with an S3 write-ahead log as the source of truth for Git hosting|Cursor's Continuity]], which reaches durability-with-speed by making S3 a write-ahead log rather than by delegating leases, and [[Lakebase puts Postgres on open object storage as a third database generation - O(1) branching, sub-500ms compute start, and 7x space amplification as the price|Lakebase]], which pays space amplification for the same class of win.

- **The framing claim -- that the file system is "*the* way that AI is going to interact with data in this new era" -- is a vendor's premise, and it is the one part of the piece to hold loosely.** Leath's diagnosis of *why* the file system is misunderstood is credible and self-implicating ("the industry hasn't spent the time making the file system developer-friendly during the 2010s"), but the vault holds live disagreement: [[Amazon S3 Files ends the object-file split for AI agents|S3 Files]] argues the object/file split closes from the object side, [[MongoDB's VFS for LangChain Deep Agents redefines grep as server-side hybrid search, splitting file bytes in S3 from a searchable chunk plane in Atlas|MongoDB's VFS]] and [[a virtual filesystem over Chroma replaces sandboxes for agent doc exploration at 100ms instead of 46 seconds|ChromaFS]] keep the POSIX surface but move the substrate under it, and [[agents need a database because stateless reasoning cores require stateful storage]] argues the primitive should be a database at all. The mechanics in this primer are correct regardless of which premise wins. Read it alongside the same author's [[AI infra has collapsed into five identical products and Archil's Hunter Leath argues the winner will be a different shape entirely|complaint that every AI-infra booth sells the same five products]]: this piece is his answer to it -- differentiate on a mechanism buyers can feel (`git clone` works) rather than on a category label.

## External Resources

- [Archil](https://archil.com) — Leath's company (@archildata); elastic cloud file system with local-ownership delegation
- [Archil docs](https://docs.archil.com/) — the "sharing disks" section, which Leath cites in-thread as the written-up version of the lease/ownership mechanism
- [@spin_lock_init (Noah Watkins)](https://x.com/spin_lock_init/status/2089564131242447324) — asks whether this is a CephFS-style exclusive lease; prompts Leath's clarification
- [@ahmetb (ahmet alp balkan)](https://x.com/ahmetb/status/2089566534150856789) — "this part is hand-wavy": how is detection done without a locking mechanism, and what does ownership transfer look like?
- [@ZebinWilson](https://x.com/ZebinWilson/status/2089591033407655958) — asks about network delay causing late lock visibility (unanswered in-thread)

## Original Content

> [!quote]- Full article: "Understanding file storage" — Hunter Leath (@jhleath), 17 Aug 2026
> Hunter Leath (@jhleath) — Mon Aug 17, 2026
> Article: Understanding file storage
> 538 likes | 57 retweets | 11 replies | 964 bookmarks | 5 quotes | 71,242 views
> [Original on X](https://x.com/jhleath/status/2089401964568469558)
>
> It's now clear that the file system (or databases stored on file systems, like SQLite or Postgres) is *the* way that AI is going to interact with data in this new era. However, the "file system" is still a super misunderstood technology -- in my opinion, because the industry hasn't spent the time making the file system developer-friendly during the 2010s.
>
> Because of this, when people say "file system", they could mean a real file system like:
>
> - XFS or ZFS running on a local machine
>
> - NFS or Lustre running on a remote machin
>
> Or they could mean something that's usually not a file system, like:
>
> - S3 object storage (not a file system)
>
> - Box or Dropbox (not a file system)
>
> - Or a homegrown solution on top of a database like SQLite or Postgres (not a file system)
>
> Let's talk about what a file system is, and let's start by looking at the one that's inside of your laptop.
>
> **Block storage**
>
> Your laptop, your phone, and sometimes your server have direct-attached storage devices -- these days usually an SSD, but it could also be a spinning hard disk. These are known as "block storage devices" because you can think of them as a literal array of fixed-size buckets of data, usually 4KB wide.
>
> For example, this is what a 32 KB block storage device with 8 blocks of 4 KB each, totalling 32 KB of usable storage.
>
> *A 32 KB SSD block device drawn as a flat array of eight 4 KB blocks, numbered 0-7*
> ![[jhleath-469558-001.png]]
>
> The interface that your operating system has to interact with these devices is *really* simple (obviously eschewing many many things):
>
> - getLength() --> blockCount
>
> - readBlock(blockId) --> (data, error)
>
> - writeBlock(blockId, data) --> error
>
> There are two interesting properties of this: first, the block devices has a *fixed* length which is known ahead of time. There is no way to make an infinite block device (though there is a way to make a block device with an unimaginably large number of blocks, which may be somewhat of the same thing).
>
> Second is that there is no transactional semantics at all, you cannot perform conditional updates to the blocks -- meaning that it's not safe to have concurrent writers access the same block device from multiple locations. You need to ensure that there is only ever a single writer to the device, which is usually trivially satisfied by the fact that a block device is directly-attached to a single computer at a time (like your laptop).
>
> Now, why don't we all write to the block device directly? It turns out to be super annoying to keep track of all of the metadata required to do this properly.
>
> For example, what if you have data that is larger than 4 KB? You need it to span multiple blocks.
>
> What if you delete data? You will end up with a hole in your array that you need to track so that you can fill it later.
>
> How do you even find the data that you've stored? You probably need some way to keep track of *which* blocks hold the relevant data for your application.
>
> For all of these reasons, we introduced an abstraction layer: the file system.
>
> **Enter the file system**
>
> Unlike the raw block device, the file system has a lot of nice properties for organizing and storing data. A file system lays out data into files (which hold actual data bytes) and directories (which hold pointers to files or other directories). The file system starts at a known place: the "root", and from that root, you're able to navigate and find all of the files on the block device that you've stored.
>
> Some nice properties fall out of this: it's possible to enforce different security properties by having different permissions on certain directories/files and applications can organize their data in application-specific directories.
>
> The file system that you're used to interacting with usually looks something like this (vastly simplified and may look familiar from OS class):
>
> *Root directory (ID 0) holding /bin, /usr, /var; /usr points to a user directory (ID 2) holding file1.txt; the text file inode (ID 5) holds an array of offset ranges (0-4KB, 4KB-8KB) pointing at data blocks -- each of these objects living in its own block on the 32 KB device*
> ![[jhleath-469558-002.jpg]]
>
> Each directory in your file system is actually an array of "directory entries" which contain file names and pointers to where on the disk the child item is stored. These pointers could be other directories or files, allowing you to create many levels of organization. Finally, files contain an array of pointers (so that the file can become arbitrarily large) to where on the disk the *actual data* lives.
>
> As you might imagine, the API that you use to interact with a file system is actually *much larger* than what you get with a block device and it has functions like:
>
> - make directory / remove directory
>
> - create file / link file / unlink file
>
> - get file attributes / set file attributes
>
> - read from file at offset / write to file at offset
>
> - rename file or directory
>
> This is usually what we talk about when we talk about the POSIX API for file systems. These functions are standardized across Linux-like operating systems, and the vast majority of software ever written (including all modern databases) store data using this API. One interesting note about this API is that there's no fixed length. Unlike a block device, you do not need to have a predetermined size for the amount of data on the file system since it's sort of irrelevant to actually using the files.
>
> [Side note on S3: The key insight of key-value stores if that you *don't actually need to organize your data*. There's no such thing as directories in S3, there is a literal string key (which can include slashes) and that points to a piece of data. As a result, it's not really possible to use S3 as a file system because some operations -- like renames and partial overwrites -- are very expensive.]
>
> The file system code is actually *implemented* inside of the Linux kernel itself, and because file systems (like databases) are the story of tradeoffs, there are *many* different file systems that you can use. As a result, the Linux kernel implements a "virtual file system" (VFS) which exposes the API and allows it to route to many different underlying implementations. If you're using XFS and calling "read file", you might end up with a call graph that looks like this:
>
> *"read file" from your application into the Linux kernel (~1us) hitting VFS then the xfs driver, which fetches blocks 2 and 3 off the SSD (~10-100us)*
> ![[jhleath-469558-003.jpg]]
>
> Now, this is all well and good for data that fits on your local disk and for applications which don't need redundancy, but the obvious question becomes disaggregation. What if you need to store really large amounts of data, what if you need higher aggregate scale than a local disk, what if you want multiple writers?
>
> **Shared file storage**
>
> The obvious next step is to basically put this file system behind a server. The server can become the single point where you can decide which client is able to do what in terms of permissions and sequencing.
>
> *Two client machines, each with an application talking to its own Linux kernel, both routed to a remote server on a storage machine that owns the XFS driver and the block device*
> ![[jhleath-469558-004.png]]
>
> Now, if two clients simultaneously try to create "file1.txt" in the same directory, the server can do concurrency control to make sure one of the clients fails. This means that we can support multiple writers! We can also imagine more esoteric file systems (with multiple servers) which allow you to scale out throughput and operations-per-second above and beyond what a single server can do!
>
> The problem: you've invented NFS and suddenly your application is running 100x slower than when you were using a single-writer block device. Why is that?
>
> **Why does remote file storage suck**
>
> There's a sneaky secret in the world of file systems, it turns out that [for performance reasons] you basically ~never want to actually talk to the disk.
>
> As a result, the POSIX file system specification has an interesting additional operation: fsync and syncfs. Until you call one of these functions, the data that you've written can be lost because it hasn't actually been written to a disk anywhere -- it's just in-memory.
>
> This is what makes database workloads so different than other kind of interactive file system operations. If you run "git clone" or "npm install", these things never call fsync, so you're actually performing a fully in-memory operation. If you run sqlite, every INSERT is followed by an "fsync", so you're actually measuring the performance of the underlying storage hardware.
>
> This makes the remote vs. local performance very very different:
>
> *Writes to block storage with no fsync: application to Linux kernel, 1us, done. Writes to file storage with no fsync: application to kernel (1us), kernel to remote server (500us), server to block device (100us) -- "note that this is *without* redundancy, and some file systems do not actually write without fsync"*
> ![[jhleath-469558-005.png]]
>
> An in-memory operation to the kernel takes around 1us for the context switch, and this is all you do every time you create a new file or folder. If you are writing to a remote file system, this incurs a network roundtrip (hundreds of microseconds to milliseconds), and [depending on your file systems' durability properties] potentially a write to a [maybe replicated] block storage device.
>
> This is required for *every operation* in order for the server to correctly reject conflicting writes from different clients. It's why if you try to run "git clone" on an NFS device, you see a tremendous performance reduction compared to running it locally.
>
> So, the ability to have shared storage for application redundancy is super important, how do we [as an industry] work around the fact that shared file storage is so bad?
>
> The answer here is simply: S3. The standard architecture that we seem to have landed on is to use a local block device for all of your working space and, then, when you're done with your work, spend time packaging it up and shipping it up to something like S3 for longer-term storage.
>
> *Stage 1: do your work ("git clone") against the local kernel at 1us. Stage 2: zip it up and call PutObject into object storage (S3)*
> ![[jhleath-469558-006.png]]
>
> This has some desirable properties. For example, for many workloads, you don't actually care to persist the intermediate states and you just want to have the end result or nothing. This workflow makes this super easy.
>
> However, it's not scaleable at all. As your data sizes grow, the time it takes to upload your finished work to S3 grows and grows. If you need to later download that data from S3 to get started again, this time also grows. This is one of the core reasons why sandbox boot-up time will take longer depending on how large your image is -- they're just stored in S3 and need to be fully downloaded before your sandbox can start up!
>
> There are lots of ways that people try to paper over this: special file formats that can be partially read to start up faster, local on-disk caches, etc -- but we believe that the underlying problem is just that shared file storage doesn't need to be so poorly performing.
>
> Let's go back and look at the underlying problem:
>
> *The article re-displays the local-vs-remote write path diagram here: 1us to the kernel locally, versus 1us + 500us + 100us once a remote server is in the path*
> ![[jhleath-469558-005.png]]
>
> The issue is that the naive approach requires that the remote file system do a lot more work than the local file system for each operation. But, what if that wasn't really required?
>
> The purpose of going to the server is to avoid a situation in which two different clients can simultaneously perform conflicting operations. What if the server had a different way to enforce this behavior?
>
> We found that most workloads don't actually require conflicting writes to the exact same file. In fact, in multi-client workloads, the clients are usually operating on different files or different directories. So, what @archildata does is that it detects what files and folders each client is working on, and allows the local Linux kernel to serve reads+writes for those files without hitting the server. If a client wants to operate on the same file or folder, the "ownership" of that piece of data moves back to the server so that the server can do conflict-detection for you.
>
> *Client A (mounted at /mnt/archil/clientA) is highlighted as owning its subtree, serving reads and writes entirely inside its own Linux kernel; client B (/mnt/archil/clientB) does the same. Caption: "With Archil, reads and writes are served locally, and only hit the server when conflicts are detected."*
> ![[jhleath-469558-007.jpg]]
>
> This is the core property that makes Archil up to 100x faster than other file storage solutions, making it possible to use it for primary storage where you need to run things like "git clone" or "npm install".
>
> Our core belief is that file storage is the simplest, best way to support all applications and that there just hasn't been a performant-enough file system for developers for these workloads to flow into. Our unique ability to let files and folders transition into local ownership (matching the semantics of local storage) is one [but not the only!] of the ways that we make the product have great performance -- setting it up to be the bedrock of all data-intensive workloads in the lcoud.

### Thread: how the ownership handoff actually works

> **@spin_lock_init (Noah Watkins)** — [Aug 18, 2026](https://x.com/spin_lock_init/status/2089564131242447324)
>
> nice write-up
>
> > it detects what files and folders each client is working on, and allows the local Linux kernel to serve reads+writes for those files without hitting the server.
>
> do I understand correctly that you're effectively taking out an exclusive lock/lease on some part of the hierarchy for exclusive use by a single host? I'm sure this isn't uncommon, but I'm most familiar with it from cephfs.

> **@jhleath (Hunter Leath)** — [Aug 18, 2026](https://x.com/jhleath/status/2089569381038866642)
>
> it's an exclusive *write* lock, readers can still use that portion of the tree, but they won't see data which hasn't been fsynced yet!

> **@jhleath (Hunter Leath)** — [Aug 18, 2026](https://x.com/jhleath/status/2089569913648398471)
>
> it is, in effect, a write lock/lease! the server is able to keep track of which files each client is attempting to use and create sort of a covering partition across the file system to delegate the subtrees to each client so they can operate without server intervention
>
> this is, in effect, just another server-side operation — but it needs to be revocable if the client goes away and/or another client needs to share write access to the data
>
> we wrote a little about this in "sharing disks" on https://docs.archil.com/

> **@ahmetb (ahmet alp balkan)** — [Aug 18, 2026](https://x.com/ahmetb/status/2089566534150856789)
>
> great article but this part is hand-wavy
>
> >> it detects what files and folders each client is working on, and allows the local Linux kernel to serve reads+writes for those files without hitting the server. If a client wants to operate on the same file or folder, the "ownership" of that piece of data moves back to the server so that the server can do conflict-detection for you.
>
> how does it detect w/o a locking mechanism? what does that ownership look like? how does it move to server?

> **@ZebinWilson (Zebin)** — [Aug 18, 2026](https://x.com/ZebinWilson/status/2089591033407655958)
>
> So like a local cached filesystem, which keeps a lock-release mechanism.
>
> For the lock-release I guess you only keep nearby locks (compared to where the current user is browsing)
>
> A bit curious on network delay which can cause lock to show up late? Is that a possibility?
