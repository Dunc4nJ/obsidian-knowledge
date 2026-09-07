---
created: 2026-09-08
description: Hunter Leath, who owned EFS's marginal cost model at AWS before founding Archil, argues S3 Files inherits EFS pricing that charges $0.03/GiB-read and $0.06/GiB-write on top of $0.30/GiB-month SSD storage -- putting retrieval at S3 Glacier Instant rates while storage sits at the most expensive point on the curve, and inverting the storage-cost-versus-retrieval-cost relationship every other S3 class obeys.
source: https://x.com/jhleath/status/2043711932168028665
type: framework
---

## Key Takeaways

- The core claim is about curve shape, not absolute price. Across S3's online classes, storage cost and retrieval cost trade off close to linearly: S3 Standard is ~$0.023/GB-month with $0 retrieval, Standard-IA is cheaper to store and ~$0.01/GB to retrieve, Glacier Instant is cheapest to store and ~$0.03/GB to retrieve. Pick a class, pay on one axis or the other. EFS/S3 Files sits at **$0.30/GiB-month storage** *and* **$0.03/GiB retrieval** — the most expensive storage on the chart paired with Glacier-tier retrieval. It is off the curve entirely, which is why Leath says it "breaks the economics that many people have used to think about their applications." The pricing is what decides whether object storage can serve as a primary substrate at all — the same economics that make [[Lakebase puts Postgres on open object storage as a third database generation - O(1) branching, sub-500ms compute start, and 7x space amplification as the price|Postgres on object storage]] and [[Cursor's Continuity replaces GitHub Spokes three-phase commit with an S3 write-ahead log as the source of truth for Git hosting|an S3 write-ahead log as Git's source of truth]] viable in the first place.

- The write side is worse than the read side and rarely quoted: Elastic Throughput bills **$0.03/GiB-read and $0.06/GiB-write**. For a write-heavy workload — agent scratch space, CI artifacts, checkpoint dumps — the transfer bill, not the storage bill, is the number that decides the architecture. Any evaluation of [[Amazon S3 Files ends the object-file split for AI agents|S3 Files]] that models only $/GB-month will underestimate cost by a wide margin. This falls hardest on exactly the agent patterns that write constantly and re-read cheaply: [[Opencomputer reframes harness-vs-sandbox debate as git branches for VMs via hibernation egress proxies and checkpoints|VM checkpoint-and-branch]], [[Firecracker microVMs became the convergent agent runtime because containers were never a security boundary|per-task microVM fleets]], and [[AgentFS]]-style scratch volumes.

- Leath's insider account explains *how* the pricing got there, and it is organizational rather than technical. EFS launched with free retrieval but throughput proportional to stored bytes, so a customer with little data got **~1 MiB/s** and deleting data could take an application down. Provisioned Throughput (up to 1 GB/s) fixed that by decoupling throughput from capacity — "great for revenue and margins," bad UX, since customers rarely know what to provision. Elastic Throughput then restored elasticity but priced transfer at the numbers above. Leath's stated lesson: "at a large company, everyone wants to grow their P&L which makes it super hard to ever drop prices, even if you don't need the prices you're charging." The distortion is a P&L artifact carried forward into a new product.

- Archil's counter-position is $0.20/GB stored and **$0.00 retrieval**, which puts it back on the curve just left of the EFS point — and Leath claims he is "not sure if it's possible to construct a workload which is cheaper on S3 Files than Archil." Note the framing shift versus his earlier reply in the [[Archil's AFS-style checkout leases close the S3 Files latency gap that NFS metadata round-trips make permanent|performance post]], where he said Archil was "33% cheaper on high-performance storage"; here the whole argument rests on zero retrieval charges, so the advantage scales with transfer volume and shrinks toward ~33% for cold, rarely-read data. Zero-retrieval pricing only works if the underlying design does not pay per-byte egress — which is the point of [[Bash is the SQL for file systems and Archil proves it with serverless execution that sends instructions not data|shipping instructions instead of data]], and the same reason [[a virtual filesystem over Chroma replaces sandboxes for agent doc exploration at 100ms instead of 46 seconds|ChromaFs]] and [[MongoDB's VFS for LangChain Deep Agents redefines grep as server-side hybrid search, splitting file bytes in S3 from a searchable chunk plane in Atlas|MongoDB's VFS]] resolve queries server-side rather than shipping corpora to the agent.

- The credibility is genuinely unusual and cuts both ways: Leath joined EFS in 2015, owned its marginal cost model and pricing strategy, and wrote the EFS/S3 unification recommendation that shipped as S3 Files — the same disclosure that anchors his [[S3 Files caps a single client at 3 GiB per second because NFS resolves DNS once while Lustre and Archil scale metadata and data separately|scalability analysis]]. He is describing pricing decisions he helped make, from a company that now undercuts them, and he says as much — "since I don't have a P&L that I'm defending to senior leadership, I had the ability to reset the pricing." His own steelman of AWS is in the piece too: SSDs really do cost more than HDDs, and you are paying a premium for file-system semantics. Whether $0.03/GiB of read is that premium or a legacy margin is the open question, and Leath expects "AWS is going to work to fix this with time."

**Vendor caveat.** These are competitor-drawn charts placing the competitor's own product at the favorable point; the Archil pricing is self-reported and the promised pricing calculator did not exist at publication. The S3 class figures and the EFS transfer rates are public and checkable.

## External Resources

- [on s3 files pricing](https://x.com/jhleath/status/2043711932168028665) — the source X Article, 13 Apr 2026
- [on s3 files performance](https://x.com/jhleath/status/2042238023367336298) — part one of the series, linked from this article
- [on s3 files scalability](https://x.com/jhleath/status/2042613823522377933) — part two, linked from this article
- [Amazon EFS pricing](https://aws.amazon.com/efs/pricing/) — source for the $0.30/GiB-month, $0.03/GiB-read, $0.06/GiB-write figures
- [Amazon S3 pricing](https://aws.amazon.com/s3/pricing/) — the storage-class curve the article charts
- [Archil pricing](https://archil.com/pricing) — Leath's $0.20/GB stored, $0.00 retrieval counter-offer

## Original Content

> [!quote]- Hunter Leath (@jhleath), X Article "on s3 files pricing" — 13 Apr 2026 — 65 likes, 5 retweets, 0 replies
>
> **Article: on s3 files pricing**
>
> *Cover: the completed storage-class chart with EFS / S3 Files circled at $0.30/GB-month storage and $0.03/GB retrieval, far off the curve that runs through S3 Standard, Standard-IA, Glacier Instant, S3 Express and Archil*
> ![[jhleath-028665-001.jpg]]
>
> s3 files is a new AWS product that allows you to mount an s3 bucket as a real file system. today, let's talk about how much it costs to use the s3 files product from AWS. if you're interested in other facets of the product such as [the latency performance](https://x.com/jhleath/status/2042238023367336298) or [the scalability](https://x.com/jhleath/status/2042613823522377933), check out these other posts.
>
> as a reminder, I'm Hunter, previously the PM at AWS responsible for coming up with a product strategy for how to unite EFS and S3 before leaving AWS to [eventually] start @archildata as the simplest, default way to store data for cloud applications. notably for today's article, I was also responsible for the marginal cost model of EFS and thinking through pricing strategies.
>
> EFS is an AWS product that has been live since 2016, offering infinite, scaleable file storage for applications. S3 Files works by putting an EFS file system in front of an S3 bucket and running replication between the two storage systems. EFS has always had a challenging history due to issues with its performance and pricing.
>
> when I joined EFS in 2015, I was shocked that we were selling a product that would cost $3,600 a year to store a TiB when dropbox could do it for me for like $100. the original explanation to me went something like this:
>
> *S3 vs. EFS: storage pricing per GiB per month — S3 $0.023, EFS $0.30 ("13x cheaper — but every read is a round trip"); read latency p50 small file read — EFS ~3ms, S3 ~30ms ("10x faster — but costs 13x more per GiB")*
> ![[jhleath-028665-002.jpg]]
>
> s3 is "slow storage" it costs 10x less than EFS but, as a result, it's also 10x slower
>
> this was something that made sense! you see, i think it's natural for people to understand that there's a direct trade-off between storage price, retrieval cost, and latency. if you store your data in lower-cost storage, you expect it to be slower to access, and you should also expect it to be more expensive to access. take a look at this graph below that shows the three online s3 storage classes.
>
> *S3 storage class tradeoffs: retrieval cost versus storage cost for S3 Standard ($0.023/GB-mo, $0 retrieval), S3 Standard-IA (~$0.0125, ~$0.01) and S3 Glacier Instant (~$0.004, $0.03) — cheaper to store trends costlier to retrieve*
> ![[jhleath-028665-003.jpg]]
>
> there's almost a linear relationship between the retrieval cost that increases as the storage cost decreases! awesome.
>
> back when EFS launched, retrieval costs were free, and the amount of throughput that you could get access to was directly proportional to the amount of storage that you had on the disk. this made sense from a cost point of view (if you take up a bunch of our disks, then you are also [by definition] able to take up a bunch of our throughput capacity). the only problem was... customers hated this. they got like 1 MiB/s by default (lol), and then if they ever deleted a large chunk of data, their applications would go down.
>
> so we did what any good team would do, and we listened to our customers and we launched Provisioned Throughput mode for EFS, where any customer could pay directly for throughput independently of their data size (up to 1 GB/s!!). this was great for revenue and margins (you can guess what every enterprise customer did), but it wasn't great as a user experience. customers often didn't know how much throughput they wanted or needed, and Provisioned Throughput walked away from the ethos of EFS which was to give users what they needed elastically.
>
> as a result, we came up with "Elastic Throughput" mode (now rebranded as... Performance Mode?) and we would just give everyone the maximum speed but then bill based on the amount of data transferred. we did a ton of math to come up with the pricing and we came up with... $0.03 / GiB-read and $0.06 / GiB-write. wait... what? this is even more expensive than S3 Glacier Instant retrieval.
>
> [aside: there's a bitter lesson in here for me that, at a large company, everyone wants to grow their P&L which makes it super hard to ever drop prices, even if you don't need the prices you're charging]
>
> as a result of this decision, our "linear relationship" between storage and access now looks like this
>
> *The same chart rescaled to $0.35/GB-mo: EFS / S3 Files lands at $0.30 storage and $0.03 retrieval, in the far corner alongside a speculative "SSD?" region, with S3 Express at ~$0.11 and near-zero retrieval*
> ![[jhleath-028665-004.jpg]]
>
> this doesn't make any sense! now, in order to access your files via the file system, you're going to pay an ENORMOUS premium (the same premium as if you were using s3 glacier instant retreival).
>
> i'm sure that my friends at AWS would say, "well, yes, of course the underlying cost structure of SSDs supports cheaper retrieval costs than HDDs but you're paying a premium for the capability to access your data as a file system", and sure but that kind of thinking is probably why i wasn't a great big-company PM.
>
> as a result of all of these decisions, EFS and S3 Files basically breaks the economics that many people have used to think about their applications, and ends up being out of reach.
>
> now, when I started @archildata, the intention was to not break this relationship. and (since I don't have a P&L that I'm defending to senior leadership, I had the ability to reset the pricing to better match the underlying costs. that's why we look like this on the graph ($0.20 per GB stored and $0.00 for retrieval).
>
> *The chart with Archil added at $0.20/GB-mo and $0.00 retrieval, sitting on the hyperbolic cost curve through S3 Standard and S3 Express, while EFS / S3 Files is circled in red off the curve and annotated "LOL"*
> ![[jhleath-028665-005.jpg]]
>
> as a result, i'm not sure if it's possible to construct a workload which is cheaper on S3 Files than Archil. lots of folks have been asking about this, and we'll add something to our pricing calculator in the coming weeks to better highlight these differences.
>
> but, the tl;dr is -- we shouldn't break the curve on how people build applications to use storage, and S3 files does. i'm sure that AWS is going to work to fix this with time.
>
> — [x.com/jhleath/status/2043711932168028665](https://x.com/jhleath/status/2043711932168028665), Mon Apr 13 15:24:29 +0000 2026
