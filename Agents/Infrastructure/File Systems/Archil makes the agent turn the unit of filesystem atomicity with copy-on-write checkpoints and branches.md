---
created: 2026-09-08
description: Archil's Hunter Leath argues the real reason S3 won was its unit of atomicity -- the whole object -- and that agents need a unit bigger still (the turn), which Archil ships as copy-on-write checkpoints and branches, with serverless execution calls reframed as database transactions that merge or abort on conflict.
source: https://x.com/jhleath/status/2050267447522177215
type: framework
---

## Key Takeaways

- The framing move is to treat "unit of atomicity" as the hidden product decision in every storage system. S3's is the object: PutObject either succeeds and is readable (strong read-after-write) or it never happened. A POSIX file system's is nothing that small -- thousands of tiny writes, attribute sets, and creations stream through with `fsync` as the only write barrier, so readers can legitimately observe empty files, half-written files, and files missing from their directory. This is the same durability-boundary question [[Cursor's Continuity replaces GitHub Spokes three-phase commit with an S3 write-ahead log as the source of truth for Git hosting|Cursor answered with a write-ahead log]], and Leath answers it with snapshots instead -- WAL gives you a replayable commit point, checkpoints give you a restorable one.

- Leath's claim is that S3's file-sized atomicity was correct for map-reduce (one file in, one file out) and is now too small, because an agent's work spans many files across many systems in a single turn. The unit of atomicity for agents is a task, a goal, or a turn: all of the turn's side effects become visible to other agents, or none do. That reframes agent state as a transactional workspace rather than a bag of files, which is the same conclusion [[every app that avoids a database ends up rebuilding one badly]] reaches from the opposite direction.

- The concrete ship is checkpoints and branching as first-class Archil primitives (beta docs live, GA "next week" from 1 May 2026). Checkpoint before and after a turn to get free rollback; branch to let agents explore several approaches without racing over one copy of the data. Because they are copy-on-write they are "nearly free," which is the same economics [[Lakebase puts Postgres on open object storage as a third database generation - O(1) branching, sub-500ms compute start, and 7x space amplification as the price|Lakebase claims for O(1) Postgres branching]] -- and worth the same scrutiny, since Lakebase's public number for that trick is 7x space amplification. Leath quantifies nothing here.

- The rejected alternatives are the interesting part. Git-based "file systems" like Cloudflare Artifacts get commit-level atomicity for free, and Leath concedes the point -- an agent can roll unrelated changes into one commit that others get whole or not at all. His objection is scaling: git is to bulk data what SQLite was to application data, a structure people stuff terabytes into that was never built for it. That is a direct counter to the checkpoint-as-git-branch model in [[Opencomputer reframes harness-vs-sandbox debate as git branches for VMs via hibernation egress proxies and checkpoints]], and it applies equally to harness-level checkpointing like [[LangChain Deep Agents runtime builds ten production capabilities on one primitive - durable super-step checkpointing to PostgreSQL|Deep Agents' super-step checkpoints to Postgres]], which pays a database to hold what a file system could hold natively.

- Checkpoints alone do not finish the job, because NetApp-style snapshots diverge and never rejoin -- what git gives you and snapshots do not is merge. Leath's answer is to let the file system keep drifting toward a database: each [[Bash is the SQL for file systems and Archil proves it with serverless execution that sends instructions not data|serverless execution call]] becomes a transaction over the file system, accepted into main or rejected on concurrent conflict. That is optimistic concurrency control with bash as the transaction body, and it is only expressible because Archil pulled compute inside the storage abstraction -- the same "smarter file system, not a replacement database" line running through [[Amazon S3 Files ends the object-file split for AI agents]], [[MongoDB's VFS for LangChain Deep Agents redefines grep as server-side hybrid search, splitting file bytes in S3 from a searchable chunk plane in Atlas]], and [[a virtual filesystem over Chroma replaces sandboxes for agent doc exploration at 100ms instead of 46 seconds]].

- Read as a strategy document, this is a vendor arguing that the storage layer -- not the harness -- should own agent transactionality. The competing bet is that the runtime owns it: microVM snapshots in [[Firecracker microVMs became the convergent agent runtime because containers were never a security boundary]], harness-level durability in [[seven runtime failures emerge when demo agents meet production distributed systems]]. Whoever owns the checkpoint owns the rollback story, and that is a defensible position rather than a neutral technical observation.

## External Resources

- [Dan Luu, "Files are hard" (Deconstruct Conf)](https://www.deconstructconf.com/2019/dan-luu-files) — the talk on file system failure modes that Archil makes required annual viewing for engineers
- [Archil branches and checkpoints (beta docs)](https://docs.archil.com/concepts/branches-and-checkpoints) — the feature this article announces
- ["Bash is the SQL for file systems"](https://x.com/jhleath/status/2044426491468079515) — Leath's prior article on Archil serverless execution, the foundation this one builds transactions on. (The in-article link points at an editor URL, `https://x.com/compose/articles/edit/2044420745905000448`, which only resolves for the author.)
- [Archil engineering roles](https://jobs.ashbyhq.com/archil) — hiring link closing the article
- [@danluu](https://x.com/danluu) — author of the referenced talk
- [Cloudflare Artifacts](https://developers.cloudflare.com/) — cited as an example of a git-based "file system" for agents

## Original Content

> [!quote]- Full article: "Building file system transactions for agents" (Hunter Leath / @jhleath, 1 May 2026)
> Hunter Leath (@jhleath) — Fri May 01, 2026
> Article: "Building file system transactions for agents"
> 48 likes | 1 retweet | 2 replies
>
> There are a lot of reasons why object storage solutions like S3 became so popular for cloud application development in the past 20 years with "low-cost" and "ubiquity" being two. I think there's a bigger reason that we don't talk about quite enough: the unit of atomicity.
>
> What do I mean?
>
> There's a simple property about S3 that's totally elusive for file systems. When you call PutObject, you know that the object is stored (and readable, thanks to strong read-after-write consistency) if the call returns successfully. If it fails, then you know that it's not there.
>
> This is absolutely not the case with file systems. File systems are designed for applications to send thousands of tiny operations -- writes, attribute modifications, and file creations. If each one of those operations were "atomic" and written to disk, the file system would crawl to a halt.
>
> Instead, file systems are designed to implement a write barrier: fsync. Once your application calls "fsync", then you know that everything you executed before that operation has been durably committed to disk and is visible upon restart.
>
> *S3 semantics vs file semantics: one PutObject before the object is readable, versus create-file / set-attributes / write / fsync -- "but what happens if you read here?"*
> ![[jhleath-177215-001.jpg]]
>
> If you've been around systems long enough, this should beg an obvious question. If these operations are discrete, then what happens if a viewer observes these intermediate states? What happens if you crash in the middle of performing them? What happens if fsync *doesn't* return successfully? Do we get the same semantics of S3, where our file isn't visible to others?
>
> Unfortunately, not quite. File systems make it possible that any of these intermediate states are viewable: empty files, partially written files, files not appearing in their directory at all.
>
> In fact, if you want a taste of just *how* complex this can get, I would recommend watching @danluu's [talk from Deconstruct Conf 2020](https://www.deconstructconf.com/2019/dan-luu-files) (it's required annual viewing for engineers at Archil).
>
> For example, TextEdit -- yes the simple text editor that comes with MacOS -- performs the following 5-step process each time you save edits to an already-existing file:
>
> *TextEdit saving hello.txt on macOS: hard-link to .bak, create .tmp_hello_<random>, repeatedly write to the temp file (multiple non-atomic writes), rename temp to hello.txt, delete the .bak*
> ![[jhleath-177215-002.png]]
>
> This complexity is why writing file based applications are so hard, and partially why in-process databases like SQLite appeared on the scene. It's easier to write to the file system in a more developer-friendly way if you outsource the actual writing to something that already comes with it's own write-ahead log.
>
> This is insanity, and it's starting to break down in the age of agents.
>
> What's the model that developers really need in order to build agents?
>
> S3's unit of atomicity is larger than the file system's. Rather than little metadata commands and individual writes, it's at the level of the file. Surprisingly, this still isn't enough for what's coming next. The unit being a file made sense when we were doing map-reduce on big-data, and each unit of work was to transform exactly one file into one output.
>
> Agents work in a workspace. They have context that spans multiple systems, and the work that they do -- writing code, calling APIs -- spans multiple files. Therefore, the unit of atomicity needs to be *bigger* than what you get with S3.
>
> The unit of atomicity for agents is a task, a goal, or a turn. You want *all* of the work that the agent did in that turn to be either: completely committed to disk such that other agents can see the side-effects of that change, or not at all.
>
> This isn't something that's currently supported in any of the major cloud platforms in a developer-friendly way, and it's one of the many reasons why we're starting to see git-based "file-systems" like Cloudflare Artifacts pop onto the scene. It's easy to see how Git can be used to get these kind of semantics. For example, an agent can roll a bunch of unrelated changes to the file system into a single commit, and then other users of that repository either get the entire commit (if it makes it to the main branch) or nothing.
>
> This makes git work similar to how developers used to use SQLite.
>
> *One git commit wrapping three unrelated file operations -- edit file 1, create file 2, rename file 3 -- as a single atomic unit*
> ![[jhleath-177215-003.png]]
>
> Unfortunately, like SQLite, it's not a scaleable solution to the generalized data problem. In both cases, we're trying to stuff, potentially terabytes of data, into a data structure that wasn't built for it.
>
> This is one of the reasons why we're adding checkpoints and branching as a first-class citizen in Archil, starting next week ([beta docs are available here](https://docs.archil.com/concepts/branches-and-checkpoints)).
>
> We think that checkpoints are the first solution to providing these semantics to agent builders -- that scales to the agents that need to work with terabytes and petabytes of data. By checkpointing the file system before and after a turn, it gives developers the ability to easily roll-back to before a turn if anything went wrong. With branching, agents get the opportunity to explore multiple different ways to accomplish a task, without worrying about overwriting the single copy of data that exists.
>
> *Pre-turn and post-turn Archil checkpoints bracketing the turn's file operations as the unit of atomicity, with the post-turn checkpoint forking a branch off the main branch*
> ![[jhleath-177215-004.jpg]]
>
> We think this solves for a tremendous amount of pain that agent builders have today, and because they're copy-on-write, they're nearly free to use.
>
> Notably, this helps to solve the "atomicity issue" associated with file systems. If your operations, including fsync, completed successfully -- no matter how many files you touched, you have the ability to create a new checkpoint. If the checkpoint isn't created, you can resume your work from the previous checkpoint -- ignoring the potential partial writes that could normally occur on a file system. This requires an entirely new architecture for snapshots that's designed for speed and quantity, unlike existing storage providers.
>
> However, we don't think that this is enough to fully solve for all of the problems that builders are thinking about today. What's left? Merging.
>
> Checkpoints are a traditional storage concept used in file systems from NetApp on to help manage data, but the intention is that these branches always diverge and never come back together.
>
> One of the other appeals of a git-based storage product is that you get this ability to "merge" your work back into a linear history.
>
> We think this requires that the file system, as a primitive, continues to evolve to look a little bit like something else... a database. The good news is that we've already innovated on this front with Archil by starting to allow users to give information about how to use their data with Serverless execution -- [that turns bash into the SQL of file systems](https://x.com/compose/articles/edit/2044420745905000448).
>
> If we continue to pull this thread more, we can actually continue to think of each call to Serverless execution as a different database transaction on top of the file system primitive, and use these "transactions" to provide a way to either accept their changes into the main file system or not depending on concurrent conflicts.
>
> *The file system linear timeline drawn as the database linear timeline: serverless exec calls map onto SQL transactions, each "can only be committed back if no conflicting edits occurred"*
> ![[jhleath-177215-005.png]]
>
> This is only possible with Archil because we've increased the abstraction layer to include the compute that you are using to interact with the file system.
>
> We think that starting to think about bash tool executions as database transactions that occur over your context will become the predominate way that agents think about interacting with file systems. It not only provides the semantics that developers are expecting after working with tools like S3, but it's also the only *scaleable* way to work with this data.
>
> We expect that the data storage landscape is going to change tremendously over the next several years, and we're excited to be building the only primitive designed to scale for these next set of applications. You'll be able to try checkpoints and branching on Archil file systems starting next week.
>
> If the problems associated with defining the storage infrastructure and interfaces for the next generation of applications is exciting, [we're always hiring more great engineers](https://jobs.ashbyhq.com/archil).
>
> [Original post](https://x.com/jhleath/status/2050267447522177215)

### Replies

> [!quote]- Thread replies
> **@dbmikus (Dylan Mikus)** — Fri May 01, 2026
> @jhleath Can you load two filesystem branches into the same serverless execution run and then process the merge there?
> [Link](https://x.com/dbmikus/status/2050316118049403224)
>
> **@jhleath (Hunter Leath)** — Fri May 01, 2026
> @dbmikus Interesting idea, and yes -- that would totally be doable if the number of files that you're inspecting is small!
> [Link](https://x.com/jhleath/status/2050317995877220550)
>
> **@tweeshan (oliver.mannion)** — Fri May 01, 2026
> @jhleath So kinda like btrfs (but with merging too)?
> [Link](https://x.com/tweeshan/status/2050344879910445506)
