---
created: 2026-09-08
description: Archil founder Hunter Leath publishes the full architecture of a sandbox scheduler built for a million launches per second in constant time — deliberately stale capacity data in Cassandra, power-of-two-choices host selection for a 10ms p50, and disaggregated image storage that removes the container-image download from the cold-start path entirely.
source: https://x.com/jhleath/status/2065408690992148698
type: framework
---

## Key Takeaways

- **The scheduler is fast because it refuses to know the truth.** Leath's core claim is that fully-consistent capacity management is impossible at scale, so every piece of state in the hot path is deliberately stale: hosts report capacity every 15 seconds (~70K requests/second across a 1M-host fleet), the API service refreshes its host list from a 12 MB S3 mapping file on the order of *minutes*, dead-host reaping is a slow background scan, and placement queries only two randomly chosen hosts (~10ms each in Cassandra) before picking the better one. That yields a **10ms scheduling p50** with no lock, no leader, and no serialization point. The tuning knobs are all probabilistic — query more hosts, refresh more often, or sandbag reported capacity — which is a different discipline from the fully-consistent placement most Kubernetes-shaped systems attempt, and the same "accept staleness to buy throughput" trade that [[Cursor's Continuity replaces GitHub Spokes three-phase commit with an S3 write-ahead log as the source of truth for Git hosting|Cursor made when it replaced three-phase commit with an S3 write-ahead log]].

- **Sandbox locality is treated as a bug, not an optimization.** Every platform that caches images on the runtime host makes warm starts fast (0 seconds) and cold starts terrible, which forces image-aware placement, which forces the scheduler to carry more state, which caps throughput. Leath's inversion is to delete locality as a goal so the scheduler can stay stateless — a direct architectural counterpoint to [[don't build agents, build environments - Ramp bakes machine images every 30 minutes so agents go from cold to working in under a second|Ramp's pre-baked machine images]], which buy sub-second starts precisely *by* pinning the environment to the host image. Both reach "fast start"; only one of them scales the scheduler.

- **The cold-start numbers make the case: a 2 GB image at S3's naive 80 MB/s takes nearly 25 seconds to land on a host.** Production container images run 500 MB to 2 GB even though "we all wish that all of our container images were like 10 MB," and most launches never read 100% of the image bytes anyway. Disaggregated online storage removes the download step so all 1M hosts read at the same speed and only fetch the bytes they touch — the same lazy-read logic that gets [[a virtual filesystem over Chroma replaces sandboxes for agent doc exploration at 100ms instead of 46 seconds|ChromaFS from 46-second sandbox creation down to 100ms]] and that [[Amazon S3 Files ends the object-file split for AI agents|S3 Files]] pushes into the object store itself.

- **Put the cold-start figures side by side and this is the slowest tier of a three-tier landscape.** V8 isolates start in single-digit milliseconds ([[Cloudflare Dynamic Workers sandbox AI-generated code in V8 isolates 100x faster than containers|Dynamic Workers, 100x faster than containers]]); [[Firecracker microVMs became the convergent agent runtime because containers were never a security boundary|Firecracker boots a hardware-isolated microVM in ~125ms with <5 MiB overhead at 150 VMs/second per host]]; [[Opencomputer reframes harness-vs-sandbox debate as git branches for VMs via hibernation egress proxies and checkpoints|Opencomputer resumes a hibernated VM in 25ms]]; [[Lakebase puts Postgres on open object storage as a third database generation - O(1) branching, sub-500ms compute start, and 7x space amplification as the price|Lakebase hits sub-500ms compute start from a warm pool]]. Leath's 10ms is *scheduling* latency only — the placement decision, not the boot — and he sidesteps boot entirely by pre-booting every sandbox shape in advance. The honest comparison is that his contribution is to the *placement* axis that none of those notes address, not to the boot axis they all compete on. Three days later he disowns the whole category — [[Archil argues today's agent sandboxes are a better EC2 not serverless, and the end-state is a query language over the file system|"the sandboxes of today are servers, plain and simple"]] — so read this blueprint as the best version of a model its own author says is transitional. And the durability question in [[Archil's fsync test separates safe persistent disks from neo-clouds that acknowledge writes on local NVMe before they are durable|his fsync piece]] applies squarely to the image and capacity storage described here.

- **Read the fix as a sales pitch, because it is one.** Leath is the founder of Archil, and the article's resolution to the cold-start problem is "use @archildata" — he even flags the circular-dependency reason he *can't* use it for the scheduler's own capacity storage, which is a tell that the recommendation is product placement rather than a neutral design choice. The underlying primitive (any high-throughput disaggregated file system with lazy reads) is general; the vendor is not. His argument that Archil disks count as customer-owned storage, so the platform may depend on them for images but not for control-plane state, is a licensing/architecture convenience, not a property of the design. The same self-interest runs through [[Bash is the SQL for file systems and Archil proves it with serverless execution that sends instructions not data|his "bash is the SQL for file systems" piece]].

- **The whole thing is claimed to be under 10K lines of microservices, and the reply thread is the honest review.** Tyler Rockwood: "I feel like I read half a system design interview and half a pitch." Ratrekt Labs draws the agent-infrastructure conclusion — "constant time sandbox spawning is a huge unlock for agent evals at scale. the bottleneck was never the model, it was the infrastructure waiting to boot environments" — which is the same bottleneck [[sandboxed CI is the missing infrastructure for agent evals at scale|sandboxed CI]] and [[Offload parallelizes agent CI test suites across Modal sandboxes removing the integration testing bottleneck|Offload's Modal fan-out]] attack from the eval side. Note what the blueprint omits: no security boundary discussion at all, which is the entire subject of [[isolating the entire agent in a sandbox is more secure than isolating just the tool]] and [[Anthropic sandboxes Claude across three products with gVisor containers, OS syscall filters, and VMs because model-layer defenses cannot stand alone against injection attacks|Anthropic's gVisor/microVM layering]].

## External Resources

- [Archil](https://archil.com) — Leath's company (@archildata); the disaggregated file system the article proposes for container image storage
- [Apache Cassandra](https://cassandra.apache.org) — the O(~1)-lookup, linearly-scaling store Leath uses for capacity data (he names DynamoDB and BigTable as equivalents)
- Fable / Mythos — X's own models, which Leath suggests readers point at the blueprint to generate an implementation
- [Tyler Rockwood's reply](https://x.com/rockwotj/status/2065521059474928011) — "half a system design interview and half a pitch"
- [Ratrekt Labs' reply](https://x.com/RatrektLabs/status/2065661202697703835) — frames constant-time spawning as the unlock for agent evals at scale
- Leath offers, via DM, the code to prepare Docker images into an efficient on-file-system format and to launch them without installing Docker

## Original Content

> [!quote]- Full text of "Launching a million sandboxes per second in constant time" by Hunter Leath (@jhleath), Jun 12 2026
> Hunter Leath (@jhleath) — Jun 12, 2026
> Article: "Launching a million sandboxes per second in constant time"
> 178 likes | 13 retweets | 5 replies
>
> They say that in the future, everyone will have their own sandbox company for 15 minutes. Let's make that simpler, here's exactly how I built our compute platform to handle millions of sandbox launches per second in constant time. I hope that you can plug it into Fable/Mythos and get a product out, so that you too can have your own sandbox company.
>
> How to build for performance
>
> There are two key properties that we're trying to achieve, and they're at odds.
>
> First, throughput. We want to be able to launch millions of sandboxes per second. There are two key insights to achieving this property. First, you need a tremendous amount of capacity in order to absorb these sandbox launches. As a result, you cannot have a system which assumes it knows the full state of the world at any given time. Second, you clearly cannot have any point of the system serialize. Two different sandbox launches need to execute completely independently, lock-free.
>
> Second, latency. Usually, sandbox platforms trend towards using a bunch of different caches local to the machines running the sandboxes in order to achieve startup times. For our purposes, this is a bad idea because it starts to tightly couple the placement of the sandbox to the performance of that sandbox (i.e. if you have a customer and they run one sandbox, you need to run their next sandbox on the same box in order to get good performance). The key problem with this is that it creates a situation in which your scheduler needs more information in order to function, reducing overall performance.
>
> Let's talk about tackling these issues one-by-one.
>
> How to launch a million sandboxes per second
>
> Let's first look into how we would even design a scheduler to handle a million sandboxes per second. We'll scope this part to literally just getting the sandbox to *run* on any host, and then tackle latency in the next section (understanding that sandbox locality is explicitly not a property that we want because it will cause bottlenecks).
>
> There are two important state management primitives that we'll need for zero bottleneck schedules.
>
> First, a database. As you may know, I am partial to Cassandra in all its forms (DynamoDB, BigTable) because I like the property that get O(~1) lookups with IOPs that trivially scale linearly with the size of the cluster that's running Cassandra. The downside here is that we need to be super careful about pre-planning our queries since we won't be able to change them later.
>
> Second, storage. If you're not me, you could use @archildata for this, but since we have to avoid circular dependencies in our service, I'm going to just use S3 directly. This gives us scale for free, but the downside with this one is that any request to S3 can't be in the hot path because a 100ms read is going to be too slow for the sandboxes that we want to launch.
>
> The purpose of the scheduler is to collect information about how many sandboxes are running on each host at any given time so that, at scheduling time, we can pick which location to use for placement quite quickly. This means that we want to be aggregating the capacity of each host well before we do scheduling, so let's introduce a service for that.
>
> *Capacity reporting path: every sandbox runtime server reports health to the Capacity Aggregation Service, which stores capacity data in Cassandra and the host-to-UUID mapping in S3*
> ![[jhleath-148698-001.png]]
>
> Assuming that we are running a cluster of 1 million runtime servers to hold all of these sandboxes, and they report their capacity every 15 seconds, we're looking at close to 70K requests per second. High, but certainly achievable.
>
> We want to store each host's capacity inside of our Cassandra so it's easy to look up later when we want to place something on the host. We want to use a primary key for our Cassandra database that has good uniformity over the search space -- so let's assume that we need to map each host's IP address to some kind of random, unique identifier like a UUID.
>
> We should have our capacity aggregation service own uploading this mapping into something like S3. Assuming that we have 64-bit server identifiers and 32-bit IP addresses, this mapping should be on the order of 12 MB. Again, large, but certainly something that we can do -- and we can split it into different pages if we need to.
>
> We'll have our Capacity Aggregation service also be responsible for new host registration, so we just add a host to the fleet, it starts reporting capacity, and our service add its to Cassandra. As a result, we need one of our "Capacity service" hosts (some kind of leader election will have to happen) to be responsible for periodically scanning Cassandra and putting the mapping of UUID to IP addresses into S3, but because host turnover is slow, this can happen on the order of minutes. Similarly, we don't have to immediately detect dead hosts instantly so long as we have a low probability of selecting them, so let's assume that there's some slow process in this server that scans our Cassandra table to look for servers which haven't sent capacity in a while and removes them.
>
> The great part about centralizing this into a single service is that it can also be responsible for a bunch of other functions we might want, like quiescing a host that's alive so that we can deploy to it without disrupting customer workloads.
>
> Let's look at the actual host selection path:
>
> *Full host selection path: the API service periodically downloads the 12MB mapping file from S3, queries Cassandra for two randomly selected hosts, schedules on the better one, and reports capacity or health failures back to the Capacity service*
> ![[jhleath-148698-002.png]]
>
> People give microservices a bad rap, but it's a super simple way to build something that will scale forever, and this is probably less than 10K lines of code (not that we care about that anymore).
>
> Our API service will be, in the background, periodically (O(minutes)) refreshing the list of hosts from our mapping file stored in S3. This will give us a slightly out-of-date view of which hosts are alive (you will note that "slightly out of date" is a common theme).
>
> When a customer requests a sandbox, we can now select from this list with uniform randomness. We will pick 2 at random (or whatever "best-of-X" you prefer), and then query Cassandra for both of those hosts (let's assume ~10ms) to get their slightly-out-of-date capacity information. We'll select the host with the most capacity and attempt to put the sandbox on that host. If this fails (either for capacity reasons or for health reasons), we will report the failure to the capacity service to take the appropriate action (either update or remove the host). If it fails, we'll try the other host we selected, or pick again.
>
> This gives us a 10ms scheduling p50, and a slightly higher p99 depending on how frequently we pick bad hosts. Depending on your goals as a platform, you can tune the probability of picking a bad host by: selecting more or fewer hosts to query, updating the capacity information more or less frequently, and potentially sandbagging capacity by always reporting values that are lower than the actual host capacity.
>
> There's nothing in this path that has any kind of locking out, so we can now launch one million sandboxes per second in around 10ms. What's next?
>
> How to launch sandboxes in constant time
>
> The next usual challenge here is how we do this in a way that doesn't have terrible cold-start latencies depending on the placement. We just built a placement service that doesn't consider any constraints on the host that we pick, so we need to make sure that we can get the sandbox up in the same amount of time no matter what host it lands on.
>
> Actually booting the sandbox usually isn't a problem because you can get constant time trivially by just always booting them. On the other end of the spectrum, you can do what @archildata does and have every sandbox that the platform could run already prebooted, and lock customers into a few different shapes of choices (which we can signal to the schedule by reporting more complex capacity information in our reports). The reader can decide which way they want go here.
>
> In fact, the usual problem with a sandbox platform is actually the image that the user wants to use on their host. Users aren't very good at building their workloads around the constraints of the system, so as much as we all wish that all of our container images were like 10 MB, it turns out that most container images in production are more on the order of 500 MB to 2 GB.
>
> Now, this poses a problem. The usual way that container platforms are built is that the user will "prepare" or upload their container image into some kind of a registry. This is usually S3-backed storage. When they launch the container on the host, then the host will actually pull down the image to a local cache.
>
> *The conventional design: the user uploads an image into S3-backed registry storage, and each sandbox runtime host pulls it down into a local image cache*
> ![[jhleath-148698-003.png]]
>
> This makes warm startups (scheduling the same container on the same host) quite fast (the image is already there), but it makes cold starts terrible. If you download from S3 naively (80 MB/s) it can take nearly 25 seconds to get a 2 GB image downloaded to the runtime host. This is not great for consistency when a warm startup can do this in 0 seconds.
>
> As a result, many systems end up trying to do image-aware placement to maximize the chances that the user's container lands on a host that has already done this download. This, of course, introduces bottlenecks into the placement process which ends up limiting the speed at which the system can launch containers.
>
> Worse, most container launches don't actually need to read 100% of the image bytes to actually startup, so a lazy-loading approach could significantly improve these cold-start times.
>
> Lucky for us, in 2026, we can use high-speed file storage (like @archildata) to just host the images for us, because they provide online access to the data from all of these hosts without needing a download step. In this world, we put all of the container images that customers want (via a "preparation step") onto a file system that they already own.
>
> Unlike the capacity management (which is an issue for operating the sandbox service) we do get to use Archil for image storage because we think of those images as belonging to each user, which means that they can use the Archil disks that they already have to hold the images.
>
> Because this is disaggregated storage, all 1 million hosts in the service are able to access the data at the same speed and read only the bytes they need. Even though the sandboxes are already booted, we can easily tell Linux to swap into the container namespace from the disaggregated storage system as part of the "launch" process.
>
> *Archil's design: the runtime host keeps no local cache — the user prepares the image into online data storage and the host loads only the bytes it needs*
> ![[jhleath-148698-004.png]]
>
> This means that we now can launch any container, on any host, in the same amount of time, regardless of the image size that the container wants to use.
>
> Let's look at the entire architecture diagram.
>
> *The complete architecture: customer, API service, Cassandra, the S3 mapping file, the Capacity Aggregation Service, sandbox runtime servers, and Archil for image and data storage*
> ![[jhleath-148698-005.png]]
>
> As you probably realize, this isn't actually a complex thing to build. I think that the core reason why "scheduling" gets a bad rap about being difficult is for a lot of random reasons:
>
> - I think that people are used to thinking about using Kubernetes for problems, which isn't singularly designed for the task of placement and scaling containers
>
> - I suspect that many system designs rely on relational databases that are more challenging to scale, out of the box, which run into issues
>
> - I believe that many schedulers being built today (especially given the race to build sandboxes) are likely trying to do fully-consistent capacity management, which isn't possible at high levels of scale
>
> - People don't immediately reach for online shared storage like @archildata, instead opting to try to upload+download things from places like S3 (slow)
>
> If you want any of the code to prepare Docker images into an efficient format to store on Archil (or other file storage) or the code to "launch" that Docker image (w/o installing Docker), then please DM me and I'll shoot it your way.
>
> Anyway, I hope that you go off and build a sandbox company with this blueprint. Obviously, there's lots more that has to happen besides just getting a container running on a host using a Docker image, but I think that everything else should be relatively straightforward for you and Fable.
>
> Please let me know if you feed this to your Claude and something pops out!

### Reply thread

> [!quote]- Replies on the thread
> **@paulgb (Paul Butler)** — Jun 12, 2026
> "They say that in the future, everyone will have their own sandbox company for 15 minutes." who is they 😂
>
> **@jhleath (Hunter Leath)** — Jun 12, 2026
> @paulgb oh @HeyGarrison for sure -- you know how happy he would be if *everyone* had a sandbox company
>
> **@rockwotj (Tyler Rockwood)** — Jun 12, 2026
> @jhleath I feel like I read half a system design interview and half a pitch. Nice work! Was a fun read good enough to be forwarded
>
> **@RatrektLabs (Ratrekt Labs)** — Jun 13, 2026
> @jhleath constant time sandbox spawning is a huge unlock for agent evals at scale. the bottleneck was never the model, it was the infrastructure waiting to boot environments
>
> **@seccingaround (SEC)** — Jun 12, 2026
> @jhleath Fun read, thanks
>
> **@pavitrabhalla (Pavitra Bhalla)** — Jun 12, 2026
> @jhleath We just spoke about this last week. Great write up!

Original: https://x.com/jhleath/status/2065408690992148698
