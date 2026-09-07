---
created: 2026-09-08
description: Archil's Hunter Leath explains why Cloudflare R2's free egress throttles at scale (a 100 Gbps port costs a flat ~$32K/mo and caps at ~32 PB, so an egress-heavy customer runs at -16,000% margin) and argues Archil's free sandboxes are structurally different -- file systems strand most of the CPU on dense SSD instances, so 30 minutes of sandbox time per $1 (5 GB) of storage is bundled capacity the customer already paid for, with paid overflow instead of throttling.
source: https://x.com/jhleath/status/2064390797890642294
type: framework
---

## Key Takeaways

- The transferable idea is a test for whether a "free" tier is safe to build on: **is the free thing a fixed cost the vendor must buy more of, or a byproduct they already own?** Cloudflare R2's free egress is the first kind -- ports are bought in fixed 100 or 400 Gbps units at a flat monthly fee, so an incremental egress-heavy customer forces a new port purchase and the vendor's only outs are throttling or refusal. Archil's free sandboxes are claimed to be the second kind. The test generalizes past storage: it is the same question to ask of any bundled-inference or bundled-compute offer, including the GPU-packing economics in [[Superlinked's SIE inference engine serves many small models on shared GPUs, fixing the one-model-per-GPU waste of vLLM and TEI]] and the fixed-cost free tier in [[camelAI self-hosts DeepSeek V4 Flash on 4x RTX PRO 6000 Blackwell for a fixed-cost free tier, with KV cache as the real bottleneck]].

- **The port arithmetic is the load-bearing part, and it checks out.** 100 Gbps = 12.5 GB/s; at 100% utilization over a 30.4-day month that is ~32 PB. A made-up all-in port cost of $32,000/mo therefore implies $1/TB, and AWS's model $2/TB after a ~70% utilization adjustment and infrastructure margin. The hypothetical customer stores 1 GB ($0.02/mo) and drives 32 PB of egress: AWS books $64,000 of egress revenue against $32,000 of cost for exactly the +50% margin the diagram shows, while Cloudflare books $0.02 against $32,000. Note the diagram's own supporting math says "36000 seconds in an hour" -- it should be 3,600, and the correct figure is what produces the ~32 PB result, so this is a slide typo rather than a broken argument. The **-16,000%** label is the one number that does not reconcile: $0.02 revenue against $32,000 cost is roughly -160,000,000% on a revenue basis or -99.99% on a cost basis, not -16,000%.

- **The stranded-resource claim is the actual product argument and it is the least verifiable part.** Archil rents dense SSD storage instances from hyperscalers -- the same class PlanetScale Metal runs on -- which the hyperscalers purpose-built for databases, and databases need heavy CPU for SQL, query plans, and aggregation. File systems "just read and write bytes from disk," so most of that CPU sits idle. Archil's storage price was set before serverless execution existed, so a customer's per-GB slice already includes CPU Archil would otherwise throw away, and the free pool grows with cluster scale. Every claim here is internal: no utilization percentage, no instance type, no cost figure. The direction is plausible -- it is the same "compute is already next to the bytes" argument as [[Bash is the SQL for file systems and Archil proves it with serverless execution that sends instructions not data]], and the storage-side mirror of the object-storage cost engineering in [[SmithDB makes LangSmith 12x faster by treating agent observability as an LSM problem on object storage]] -- but nothing in it is externally checkable. Contrast [[Lakebase puts Postgres on open object storage as a third database generation - O(1) branching, sub-500ms compute start, and 7x space amplification as the price|Lakebase, which names the price of its own trick (7x space amplification)]]; naming the cost is what makes an economics claim auditable.

- **The one externally checkable Archil number is the ratio: 30 minutes of sandbox time per month per $1 of storage spend, where $1 buys 5 GB.** That implies a $0.20/GB-month list price and a 6 minutes-of-CPU-per-GB-per-month allowance, both testable against Archil's published pricing. Leath's own qualifier is that this covers "the vast majority of customers" who never approach 30 minutes of *active* CPU per 5 GB -- which is a statement about workload shape, not a guarantee, and it is exactly the shape that heavy [[Bash is the SQL for file systems and Archil proves it with serverless execution that sends instructions not data|serverless execution]] usage would break -- or that [[Archil makes the agent turn the unit of filesystem atomicity with copy-on-write checkpoints and branches|checkpoint-per-turn branching]] would, once every agent turn triggers work inside the file system rather than outside it.

- **The stated failure mode is the tell that separates this from R2, if it holds.** When the free CPU pool runs out, Archil says it will sell you more rather than throttle you or turn you away, "because we have a path to charging you on that additional compute used." That is the AWS incentive-alignment argument Leath spends half the article building -- charge every dimension so no customer shape is unprofitable -- applied to himself. Whether the overflow price is competitive is unstated, and it is the number that decides whether "free" is a discount or a lock-in ramp. Compare the pure price-competition posture of the sandbox vendors in [[sandboxing AI agents can be 100x faster with dynamic workers]] and [[Firecracker microVMs became the convergent agent runtime because containers were never a security boundary|the microVM runtime race]] against [[Archil argues the winner of Vercel for agents will be a composable storage primitive not a faster sandbox|Leath's own market taxonomy]], where he argues sandbox compute is not where the value sits -- giving it away is consistent with believing that, and it is the commercial form of the argument in [[a virtual filesystem over Chroma replaces sandboxes for agent doc exploration at 100ms instead of 46 seconds]] that the sandbox was never the necessary unit.

- Read as vendor marketing, this is unusually honest marketing: it explains the mechanism, names the condition under which the free tier ends, and does the competitor's math in public rather than asserting a headline price. The reply from Sachin Raja compresses it correctly -- "the entire essence of serverless... providers pay for [fixed resource], charge you per-use, and achieve high utilization so they can amortize costs and pass on the savings." What is missing is the number that would let a buyer verify any of it: Archil's actual CPU utilization on those boxes. It is also the pricing counterpart to [[AI infra has collapsed into five identical products and Archil's Hunter Leath argues the winner will be a different shape entirely|Leath's own read of a converging infra market]] -- when five vendors sell the same product, bundling is how you stop competing on the line item everyone else prices. Treat the Cloudflare/AWS section as reusable analysis and the Archil section as a claim to re-check against a bill, the same discipline [[Databricks traces every MCP call and finds seven tool bugs burning 1.2 million dollars a year because agents retry silently instead of failing loudly]] applies to agent spend.

## External Resources

- [Cloudflare R2](https://developers.cloudflare.com/r2/) — the zero-egress-fee object store whose pricing model the first half of the article dissects
- [PlanetScale Metal](https://planetscale.com/metal) — cited as running on the same dense SSD storage instances Archil rents, but with a CPU-hungry database workload rather than a file system
- [Archil](https://archil.com) — the author's company; the serverless execution and sandbox allowance described here
- [Sachin Raja's reply](https://x.com/s4chinraja/status/2064421265142870087) — the one-line generalization of the argument to serverless economics broadly

## Original Content

> [!quote]- Full article: "Are Archil's sandboxes as free as Cloudflare egress?" (Hunter Leath / @jhleath, 9 Jun 2026)
> Hunter Leath (@jhleath) — Tue Jun 09, 2026
> Article: "Are Archil's sandboxes as free as Cloudflare egress?"
> 43 likes | 2 retweets | 1 reply
>
> One thing that customers are most surprised by when they move to Archil is that their sandbox costs usually go to $0 by moving to Serverless execution. This is great for them, but also a little confusing, so I wanted to spend some time explaining how we're able to accomplish this feat of giving away sandboxes for free.
>
> To start, it's important to note that operating a cloud service is distinctly different than just building great software (though, that's a component, of course). You also have to have a team with a mastery of operations (how to respond and manage incidents), and a deep understanding of how to financially align incentives between you and your customers.
>
> To explain this, I want to start out by looking at the cost model of Cloudflare's R2 service.
>
> **Free as in R2 Egress**
>
> Most people know that Cloudflare's R2 service is a lower-cost object storage alternative to Amazon S3 that doesn't charge for egress fees. Some people know that the "free egress" is only true until you hit a certain amount of scale, and then Cloudflare is either going to start charging you for egress or throttle your egress.
>
> Compare this to Amazon S3 where egress is considered to be highway robbery, but they will happily support your ability to drive hundreds of gigabytes of throughput out to the internet at a given notice.
>
> Why are these two models different? Consider how egress traffic works from a cloud-provider point of view (and, forgive me, because the specifics of this process aren't my domain of expertise, but the rough shape should be correct).
>
> When you purchase space in a data center (not a hyperscaler), you get the opportunity to rent specific transfer ports to the internet. These transfer ports are rated to some amount of bandwidth (think 100 or 400 gigabit), and not charged by byte transferred. Then, you would pay the data center (or network provider, again idk) some monthly maintenance fee to keep the port online for you and shuttle the traffic back and forth.
>
> *A 100 Gigabit egress port is 12.5 GB/s; multiplied out over an average month the port can transfer ~32 PB of traffic. (The diagram's "36000 seconds in an hour" should read 3,600 -- the ~32 PB result follows from the correct figure.)*
> ![[jhleath-642294-001.png]]
>
> Even though the port is charged on a per-byte transferred point of view, there is a maximum amount of traffic that any given port can transfer in a month. For a port that is rated for 100 Gbps (12.5 GB/s), it can only transfer 32 PB at 100% utilization over the course of the month.
>
> If you got charged $32,000 (made up, but assume this is an all-in cost of maintenance, electricity, peering contracts, etc) monthly for access to this port, then you would in fact be paying an effective per-byte transferred cost of $1 per terabyte out to the internet.
>
> If you were AWS and you were selling this to your customers, you would add in some other adjustments to the cost (such as the average utilization of the month, say like 70%, and an infrastructure margin) to come out with the final price that customers pay. In our model world, for simplicity, let's say that Amazon charges people $2/TB for egress.
>
> Now, let's consider the two different models side-by-side. Let's assume that both providers have maxed out their bandwidth already -- they don't have any ability, without purchasing a new port, to serve any additional traffic to the internet from their storage services (contrived, I know). Now, a new customer comes to both Cloudflare R2 and Amazon S3 and says:
>
> I have 1 GB of data that I want to store in your object storage system, and I need to transfer it out so many times over the month that I will rack up 32 PB of egress over the course of the month. Obviously, this customer prefers to use Cloudflare R2 because they won't be charged egress on this data (only $0.02 for storage!). However, because Cloudflare is already at-capacity for egress traffic, they would need to provision an entire additional port for this customer, an additional $32K/mo cost for the business to serve this customer. What happens?
>
> *Cloudflare Model -- new storage revenue $0.02/mo, new egress revenue $0.00/mo, new costs $32,000/mo, customer margin -16,000%. AWS Model -- new storage revenue $0.02/mo, new egress revenue $64,000/mo, new costs $32,000/mo, customer margin +50%.*
> ![[jhleath-642294-002.jpg]]
>
> Well, Cloudflare just tells this customer to go somewhere else -- or they throttle the customer when they eventually drive too much egress to their bucket. The Cloudflare business isn't incentivized to take on a new customer at a -16,000% gross margin. On the other hand, AWS is totally happy to serve this customer because they profitably purchase the additional egress port to serve customer traffic at a healthy +50% gross margin.
>
> This is why AWS is so intent on charging for every dimension of the product that they sell. It isn't because they are trying to penny-pinch, it's because they want to properly align incentives between the business and customers to support all of the different shapes of workloads that customers might bring to them.
>
> **Free as in Archil Sandboxes**
>
> Now, surely, we've learned that you cannot give parts of your product away for free without causing a big problem for incentives. Therefore, Archil sandboxes being free must be some kind of a problem for the long-term health of the business.
>
> It turns out that this is not the case, because Archil's Serverless execution product isn't free like Cloudflare egress, it's bundled with your storage.
>
> Again, let's consider what's happening from the Archil point of view here. We rent, from the hyperscalers, what they call "dense SSD storage instances". These instances have the regular things that you would expect -- CPU, RAM -- but also a ton of SSD storage locally attached to them. These are the same instances that run products like PlanetScale Metal.
>
> However, a database like what PlanetScale Metal runs has a very different shape than a file system. Databases notably need to use a lot of CPU in addition to the storage that they hold, to run SQL, execute query plans, aggregate results. These dense SSD instances are actually purpose-built by the hyperscalers to serve database workloads (note how many more database vendors there are than file system vendors).
>
> File systems, on the other hand, are not CPU intensive. They just read and write bytes from disk, and shuttle them back to users (who do the aggregation themselves). As a result, file systems that run on these servers often have lots of extra CPU that they aren't using as part of the storage service.
>
> *The same dense SSD storage instance running a database versus a file system: the database saturates CPU and RAM alongside storage, while the file system leaves most of its CPU and RAM unused (red area indicates utilization).*
> ![[jhleath-642294-003.jpg]]
>
> In the cloud world, we call this an "orphaned" or "stranded" resource. We have all of this CPU available and nothing to do with it!
>
> For Archil, serverless execution gives us an answer for how to deal with it. You see, when we came up with the cost model for Archil, we didn't yet know about how we would build and market Serverless execution, so when you buy 1 GB of storage from us, you're actually buying 1 GB of the storage server amortized over the month. This means that the "slice" of the box that you're paying for actually included some amount of this free CPU resource that we would otherwise be throwing away.
>
> *The customer's slice of the Archil storage box per GB stored cuts vertically through both bars -- it includes CPU as well as storage.*
> ![[jhleath-642294-004.jpg]]
>
> As our storage clusters continue to scale, the absolute amount of available CPU "for free" just continues to grow.
>
> There are two ways that we could handle this as a company.
>
> First, we could just accept this as a margin boost -- we have free CPU, awesome! And continue to sell our storage and compute products without taking that fact into considerion.
>
> Or, we could do the thing that's best for our customers and actually *give them* the resources that they are paying for, even if it wasn't what we originally expected.
>
> You can imagine which path we ended up taking. As a result, we give people 30m of sandbox usage each month for *every* $1 in storage spend (5 GB) that is on the platform.
>
> Now, unlike the Cloudflare egress problem, this isn't free forever, it's just free as your resource usage continues to scale. If we're out of capacity for the free CPUs and you need to launch additional sandboxes, we'll happily allow it -- because we have a path to charging you on that additional compute used. We don't throttle you, or tell you to go away. This is aligning incentives between our customers and how we procure hardware to give people the best of both worlds.
>
> But, for the vast majority of customers, who don't have 30m of "active" CPU time each month for every 5 GB of data their agents use, they end up with sandboxes that are completely free of charge. Pretty cool.
>
> [Original post](https://x.com/jhleath/status/2064390797890642294)

### Replies

> [!quote]- Thread replies
> **@s4chinraja (Sachin Raja)** — Tue Jun 09, 2026
> @jhleath This argument is the entire essence of serverless I feel, providers pay for [fixed resource], charge you per-use, and achieve high utilization so they can amortize costs and pass on the savings.
> [Link](https://x.com/s4chinraja/status/2064421265142870087)
