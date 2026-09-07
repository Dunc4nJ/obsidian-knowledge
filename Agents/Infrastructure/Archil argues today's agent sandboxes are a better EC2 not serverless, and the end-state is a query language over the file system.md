---
created: 2026-09-08
description: Archil's Hunter Leath defines serverless as a three-part test (no OS management, on-demand capacity, stateless reusable function), scores today's agent sandboxes at one out of three, and argues the real end-state is not a faster VM but a query language over the agent's file system where no sandbox resource is ever created.
source: https://x.com/jhleath/status/2066541977227935829
type: framework
---

## Key Takeaways

- **The three-part serverless test, and sandboxes score one out of three.** Leath's definition: (1) the user never manages the OS or security patches, (2) the service doesn't merely auto-scale — it serves demand on-demand by launching capacity or calling straight into code, and (3) the user only writes business logic against what is effectively a deterministic function reusable across inputs. Sandboxes pass the first, fail the second (developers manually pause and resume to dodge charges), and fail the third (they are bespoke per-user environments, and Leath cites developers whose sandbox the model itself killed, requiring manual remediation). His verdict: "The sandboxes of today are servers, plain and simple" — millisecond spin-up makes them "a better EC2," not serverless. Suspend/resume doesn't rescue them either, since EC2 has had StopInstance/StartInstance for a decade and nobody calls EC2 serverless.

- **The cost/latency double bind is the actual bug, and it is economic, not technical.** Startup latency pushes developers to pre-warm sandboxes as early as possible; billing starts the instant the sandbox does, which punishes exactly that. So developers hand-build classifiers that guess whether a command needs a real sandbox or can be routed to plain bash — which Leath names as textbook "undifferentiated heavy lifting." This is the same waste that [[a virtual filesystem over Chroma replaces sandboxes for agent doc exploration at 100ms instead of 46 seconds|ChromaFS quantified from the other end]] (46-second sandbox creation collapsed to 100ms by not provisioning one at all) and the reason [[don't build agents, build environments - Ramp bakes machine images every 30 minutes so agents go from cold to working in under a second|Ramp pre-bakes machine images every 30 minutes]] to get startup under a second. Every one of those is a workaround for a resource that shouldn't have been a resource.

- **Cloudflare gets a partial credit and one pointed objection: `mkdir()`.** Leath concedes Cloudflare Sandboxes come close — on-demand creation, active-CPU billing (Workers Paid: $5/month including 25 GiB-hours memory, 375 vCPU-minutes and 200 GB-hours disk, then $0.0000025 per GiB-second, $0.000020 per vCPU-second, $0.00000007 per GB-second), and sleep after a few minutes of inactivity. He withholds full marks because the *platform*, not the user, should eat the idle-timeout window. His real objection is the `sandbox.mkdir('/workspace/project/src')` call in the docs: nobody ever created one Lambda function or one Vercel deployment per customer, so a per-user filesystem inside the sandbox drags you back into managing servers one at a time. See [[Cloudflare Dynamic Workers sandbox AI-generated code in V8 isolates 100x faster than containers|Cloudflare's own isolate-based argument]] for the case Leath is grading against.

- **"The sandbox is a tool, not a place" — state belongs in the file system, not the runtime.** Leath is on record that state is what makes agents different, and he still argues state must live *outside* the sandbox, in the file system, with the sandbox as a stateless tool that manipulates it. The proposed end-state: sandboxes become a query language like SQL, nothing runs between queries, nothing is ever created, and you pay only for executing queries against the agent's context. This is the direct sequel to [[Bash is the SQL for file systems and Archil proves it with serverless execution that sends instructions not data|his own "bash is the SQL for file systems" argument]] — that piece established the query language, this one applies it to the sandbox. The stateless-compute-over-external-state shape also matches [[Browser Use stitches stateless Lambdas into multi-hour browser agents via S3 checkpoints and SQS continuations|Browser Use's stateless Lambdas checkpointing to S3]] and [[Harvey Spectre makes durable runs the core primitive while workers stay ephemeral and sandboxes enforce explicit boundaries|Harvey Spectre's durable runs over ephemeral workers]], both of which reached the same conclusion by different routes.

- **Cross-note comparison: every fast sandbox in the vault is still selling a resource.** [[Firecracker microVMs became the convergent agent runtime because containers were never a security boundary|Firecracker's ~125ms boot at 150 VMs/second]], [[Opencomputer reframes harness-vs-sandbox debate as git branches for VMs via hibernation egress proxies and checkpoints|Opencomputer's 25ms hibernation resume]], [[Lakebase puts Postgres on open object storage as a third database generation - O(1) branching, sub-500ms compute start, and 7x space amplification as the price|Lakebase's sub-500ms compute start]], and [[Archil's million-sandboxes-per-second blueprint buys 10ms placement with deliberately stale capacity data and moves container images off the cold-start path|Leath's own 10ms placement]] all optimize the same axis — how fast can I hand you a machine. Leath's argument here is that the axis is wrong: as long as a machine exists, someone is paying for it to idle, and the developer is still deciding when to create and kill it. Note the tension with his previous article, which is a blueprint for a very fast version of exactly the model he calls "a better EC2" three days later.

- **Treat the conclusion as a roadmap pitch, because he says so.** The article closes on "we're working towards building this truly serverless computer at @archildata" plus a hiring link, and the aside that this API is "one AWS feature launch away from being undifferentiated from the Hyperscalers" doubles as a warning to the sandbox startups he is competing with. The framework is genuinely useful independent of the vendor; the claim that Archil has "built the world's most powerful file system" is marketing. Tip ten Brink's reply names the unresolved cost of the abstraction: how does an application developer do any vertically-integrated optimization once the computer is abstracted this far away — a concern that also applies to [[Amazon S3 Files ends the object-file split for AI agents|S3 Files]] and every other push to make the file system smarter.

## External Resources

- Cloudflare Sandbox SDK docs (`@cloudflare/sandbox`) — the `getSandbox` / `mkdir` API and the Workers Paid active-usage pricing table Leath screenshots and grades
- [Archil careers](https://jobs.ashbyhq.com/archil) — the hiring link the article closes on
- [@ankrgyl (Ankur Goyal, Braintrust CEO)](https://x.com/ankrgyl) — his "sandboxes are the convergence of servers and serverless" post prompted the piece
- [@acoyfellow (Jordan Coeyman, Cloudflare)](https://x.com/acoyfellow) — pointed out Cloudflare Sandboxes already do active-usage billing
- [@HeyGarrison](https://x.com/HeyGarrison) — credited for pushing sandbox spin-up latency down; also the running joke about everyone owning a sandbox company
- [@dhh](https://x.com/dhh) — invoked for the colo-versus-cloud unit-cost argument
- Neon and Aurora DSQL consoles — used as the visual test of which database actually counts as serverless ("I don't think it's Neon")

## Original Content

> [!quote]- Full text of "Where are the serverless sandboxes?" by Hunter Leath (@jhleath), Jun 15 2026
> Hunter Leath (@jhleath) — Jun 15, 2026
> Article: "Where are the serverless sandboxes?"
> 73 likes | 5 retweets | 6 replies
>
> Yesterday, @ankrgyl, the CEO of Braintrust, remarked that it felt like sandboxes were the convergence of servers and serverless. He should be correct here, it is the case that sandboxes kind of feel like "serverless servers". The problem is that nobody has built an interesting, serverless version of the sandbox. Why is that, and what would it look like?
>
> *The exchange that started it: Ankur Goyal (@ankrgyl, Braintrust CEO) — "sandboxes are the convergence of servers and serverless" — and Leath's reply, "it would be cool to see any of them deliver on this need though"*
> ![[jhleath-935829-001.jpg]]
>
> What does it mean to be serverless?
>
> Today, it seems like every infrastructure that you buy is serverless -- databases, storage, website hosting , inference-- and lots of people have lots of opinions about whether or not "serverless" is a good thing, or even what it means. Let's define it by starting with my favorite thing -- "what was the world like before AWS".
>
> *Three eras compared: colocation (months to provision, hardware + software, autoscaling "LOL"), VPS/EC2 (seconds, app code + OS, autoscaling in minutes), and serverless/Lambda (milliseconds, business logic only, demand-driven)*
> ![[jhleath-935829-002.png]]
>
> Before cloud computing was the only way to deploy applications, we had actual data centers and colocations. In this world (with varying levels of white-glove service from your DC), your company would rack+stack computers that you select and get network access to them. You would provision the machine, install the OS, and set up your application to run. If you needed storage, then Oracle would be happy to sell you a Box that could run a database for your computers to connect to. If you needed more capacity because your business was growing, you would need to obtain budget from your department, open a ticket to IT, buy the server, drive over to install it, and then get it all set up. This could take a long time, and wasn't something that could be done in time if your product went viral on Slashdot. If one of the hard drives or the memory in your server went bad, guess who was on the hook for buying a replacement and repairing the server?
>
> This was pretty bad, and companies like Amazon started to realize that there was a lot of "undifferentiated heavy lifting" in this process. If every company was rack+stacking servers (requiring time and expertise from each company), wouldn't it be more efficient for one mega company to do all of the rack+stacking and have everyone else rent from them? Thus, we got cloud computing.
>
> With EC2, you could now launch additional capacity in seconds instead of in months. You were still responsible for making sure your operating system was up to date, but AWS would handle replacing hard drives and procuring actual servers. Because of the large number of servers that AWS had, they could even provide a huge amount of diversity at the click of a button (need lots of ram? needs lots of CPU? they have you covered).
>
> EC2 instances launched so quickly and there was so much capacity that an entirely new idea was born: auto-scaling. Now, if your product went viral on Hacker News, AWS could actually monitor the servers for you and automatically launch more (in just minutes!) to ensure that your application stayed alive during a period of high-traffic.
>
> Now, as @dhh knows the best, the unit-cost of these virtual servers is actually higher than installing the servers yourself in a colo. If you bought one server and placed it in a colo and used it 100% of the time, it would be cheaper on a per-hour basis than doing the same thing on EC2. We paid that higher unit price because most applications have pretty spikey traffic. You could save a lot of money by spinning servers and up down rather than purchasing servers for the maximum amount of traffic you ever expected, and we became familiar with graphs like these:
>
> *The economics of spiky traffic: flat provisioned colo cost sits above the demand curve at all times, while on-demand EC2 cost steps up and down to track it*
> ![[jhleath-935829-003.png]]
>
> This was good for a time, but people started to realize that there was still that "undifferentiated heavy lifting" creeping in. It turned out that while we needed EC2/VPS for some kinds of "legacy" applications (that Oracle database still needed a Box to run on), most applications being written during this time were actually just... websites. The web was exploding! Why was it that everyone who wanted to deploy a website needed to spin up a server, install an OS (and do security patches!), configure load-balancers, and more.
>
> Even with auto-scaling kicking happening in O(minutes), that's still minutes of virality on Twitter where your application is just down. That's not acceptable, so the industry moved into the next form: "serverless" compute.
>
> The thinking from AWS was, "what if we just did all of this on behalf of our customers?" If that's the case, then the developer only needs to worry about the "business logic" of their application -- what their business actually uses to drive revenue.
>
> *What the cloud absorbs: in the EC2 world the customer owns SSL, load balancer, app code and OS; in the serverless world only the Lambda function stays customer-owned*
> ![[jhleath-935829-004.jpg]]
>
> The nifty thing here is that the infrastructure is already running on AWS's side, so rather than waiting O(seconds) to launch a server, they could start a function in O(hundreds of milliseconds). This was fast enough to unlock a new idea beyond auto-scaling: what if we only ran your code while customers were requesting it? If nobody was accessing your website, you would pay $0, and if you got requests, AWS would automatically provision -- on-demand -- enough compute to serve those requests.
>
> Now, Lambda has been moderately successful, but I think it sort of missed the prime because it was too generic. Developers were struggling to invent ways to get around all of the weird quirks of Lambda -- a 15-minute max runtime, originally a very small amount of onboard storage, etc. The company which really began to be known as the kings of the serverless era specialized on what they ran: Vercel.
>
> Rather than spinning up general-purpose compute, Vercel started by hosting exactly one kind of thing -- Javascript frontends. As a result, they didn't need to wait O(hundreds of milliseconds) to "start" capacity for users, it was just a function call away. Users didn't need long backend runtimes because these were literally just web apps, and users didn't need onboard storage because a whole new crop of "serverless" stateful services popped up to make building in this way easy.
>
> This meant that "serverless" compute, like Lambda functions or Vercel deployments, appeared as nearly perfect "pure functions" which would take an input event + state of the world and produce a deterministic output across those inputs. Once it was set up, it could be used over and over again.
>
> And, just like with EC2, there was again a per-unit price-hike. People correctly pointed out at the time that Vercel was just a "wrapper on AWS which is higher-priced". This is true, but again, customers were paying for more than they got with AWS directly. They now didn't have to worry about their application ever having downtime because capacity was infinite and always available.
>
> Therefore, when I think of what "serverless" means, it comes down to the following things for me:
>
> - User does not need to manage the operating system or security updates on the node
>
> - The service doesn't "auto-scale" it automatically serves traffic for end-users on-demand by launching capacity or calling into code directly
>
> - The user only needs to worry about their business logic -- the serverless system is nearly a deterministic function that can be applied over and over again to the same inputs to get the same outputs
>
> *Serverless as a pure function: an input event fans into a Lambda function or Vercel deployment and produces an output — "the serverless compute is a one-time creation that can be applied over and over again to many inputs"*
> ![[jhleath-935829-005.png]]
>
> Now, this leads to some sort of odd conclusions from the current state of the world. For example, which database do you consider to be "serverless"?
>
> *The awkward comparison: Neon's console exposes compute size (.25 to 2 CU), a scale-to-zero timeout, and a history window as user-managed settings, while Aurora DSQL's create-cluster flow asks only for a name and tags*
> ![[jhleath-935829-006.jpg]]
>
> I don't think it's Neon.
>
> Where does this leave us with sandboxes?
>
> Now, we know that the end-state of the industry is that everyone will have their own sandbox company, so let's first start by looking at usual sandboxes, and then look at Cloudflare's (since they tend to march to the beat of their own drum). Usually, sandbox usage looks something like this:
>
> *The standard sandbox API, annotated with where the money goes: create ("charges start accruing immediately"), exec, pause ("don't worry we can pause it and save money"), resume ("later on the user comes back, and so do our charges"), stop*
> ![[jhleath-935829-007.jpg]]
>
> You have some kind of agent that wants to run code that could destroy the system, so rather than run it on the current system, you spin up a sandbox to run that code. The user does this, it's great, but eventually they become inactive on your platform, so you pause the sandbox to save on costs. When they come back, you call resume, and things are great until you eventually kill the sandbox. Awesome! Is this serverless?
>
> If your definition of serverless is "I can easily interact with it from Javascript," then maybe. But I don't think so. There are a couple of really interesting issues with the standard API.
>
> First, despite @HeyGarrison's best efforts, spinning up a sandbox still takes some time, which means that developers don't like to expose that latency directly to their end users. So, they want to spin these things up as early in the process as possible. BUT, charges start accruing as soon as the sandbox starts, which ... means that it's wasteful to spin up a sandbox before the user needs it. What if they never issue a command that needs to run code (maybe I could just use just-bash)? What if they walk away for a few minutes before sending their next message?
>
> I know lots of developers that are basically trying to home-build functions which guess whether or not a command needs a real sandbox so they can route it to either just-bash or spin up a sandbox. This is what "undifferentiated heavy lifting" looks like.
>
> The sandboxes of today are servers, plain and simple. Let's look at our checklist.
>
> - Does the platform take care of managing the operating system? Yes, so that's a check.
>
> - Are they automatically spun up and down in response to demand? No, users need to manage their sandboxes carefully as actual resources to avoid charges and latency penalties.
>
> - Are they treated like a function that you set up once and can use over and over again? No, they are bespoke environments. In fact, I've heard from developers who struggle because sometimes the AI model kills the sandbox and it needs manual remediation.
>
> The ability to spin them up and down within milliseconds just makes them a "better EC2", but if the end-game of infrastructure is to move to purpose-built serverless solutions, these sandboxes are not them.
>
> [aside: This also means that this API is sort of one AWS feature launch away from being undifferentiated from the Hyperscalers -- they just need to get EC2 instance launch times fast. Now, I worked at AWS for a long time, so I know how things can cross from "easy" to "impossible" on a dime, yet...]
>
> What about suspend/resume? Isn't that serverless?
>
> Nope. In fact, EC2 has had the ability to pause and resume (StopInstance and StartInstance) for a decade, and nobody seems to believe that "EC2 is serverless".
>
> What about Cloudflare or Vercel? Does pricing on Active CPU help get you closer?
>
> In my thread with Ankur, Jordan (@acoyfellow) from Cloudflare (correctly) pointed out that Cloudflare Sandboxes already supported much of what I was looking for in a "serverless sandbox".
>
> *Jordan Coeyman (@acoyfellow) of Cloudflare: "Cloudflare Sandbox SDK already does this (active usage billing)"*
> ![[jhleath-935829-008.jpg]]
>
> This is true, to an extent. Let's look at the API and docs.
>
> *Cloudflare's Sandbox docs and pricing side by side: getSandbox(env.Sandbox, 'user-123') followed by sandbox.mkdir('/workspace/project/src'), against the Workers Paid plan's $5/month with 25 GiB-hours memory, 375 vCPU-minutes and 200 GB-hours disk included, then $0.0000025 per GiB-second, $0.000020 per vCPU-second and $0.00000007 per GB-second — with "charges start when a request is sent to the container... Charges stop after the container instance goes to sleep" highlighted*
> ![[jhleath-935829-009.jpg]]
>
> I like a lot about what I see here. I think that their docs do a good job of making it clear that you should have a shit ton of these things because creating them doesn't mean that you need to pay for them (see the call to "getSandbox" which is, obviously, per-user).
>
> They will spin up your sandbox on-demand (check) in a Cloudflare Container, and then spin it down after a few minutes of inactivity (this is a partial check, I think that the "fluid compute" idea of directing repeated requests to a running container is fine, but I think the platform should pay for the timeout time instead of the user for it to really count).
>
> There's really just one thing that kind of bothers me about their docs, and it will surprise you: the call to mkdir().
>
> The sandbox is a tool, not a place.
>
> There is something about that "mkdir" call that betrays how Cloudflare thinks about their sandboxes compared to how we thought about Lambda or Vercel deployments.
>
> Did you actually create one Lambda function per-customer in the serverless era? Did you create one Vercel deployment per-customer? Did you upload customer-specific files to either one of these?
>
> Of course not, because that's kind of ridiculous and would quickly become a management nightmare. The Lambda function and the Vercel deployment were, for better or worse, "stateless" over an outside set of context that the application needed access to (in most cases, an S3 bucket or a database).
>
> Even though you know that I'm a huge proponent of the fact that state is the thing that's different about AI agents, I don't think it belongs in the sandbox layer itself, or you end back up in a world in which you're managing servers, one-by-one.
>
> Instead, the sandbox should still be a stateless tool over some kind of external state, but it's a different kind of external state than before. The external state of today is, of course, a file system, and the sandbox should be a tool used to manipulate that file system. Sometimes this is read-only, sometimes this is writes to the file system.
>
> In either case, I don't think that the agent harness of tomorrow will actually want a computer to do its work on. The serverless end-state of sandboxes is that they become a query language, much like SQL, that allows the agent to access the totality of software ever created in a serverless way.
>
> In this world, there is no resource that's ever created. You're not charge for what's "running" because nothing is running. You're only charged for executing these "queries" against the context of the agent. You don't need to worry about uploading and managing files in a "sandbox" because there is no "sandbox", there is only the customer's context. And, the customer's context should support running an unlimited amount of compute on top of it as the workloads that agents run become larger and more demanding.
>
> *The proposed end state, drawn against the Lambda/Vercel pattern above it: a query or network request hits a serverless sandbox (Archil compute) which acts on user context (the Archil file system) — no resource is created and nothing is running between queries*
> ![[jhleath-935829-010.png]]
>
> This "sandbox" query language will run on top of the file system, and provide a way for the harness to create and manage long-running, network addressable services (like databases) so that the agent can literally build a distributed, serverless computer in a piece-by-piece way that allows it to most easily manipulate its context.
>
> This looks a lot more like how serverless is supposed to look, based on past patterns.
>
> Why hasn't anyone built this yet?
>
> Like most things, it's hard. Selling provisioned services (like you request 2 vCPU and I charge you slightly more than it costs me) is a way simpler proposition, and it doesn't even require category creation.
>
> It's not super clear how you even go about breaking down the computer in an abstract way into a serverless state machine that continues to expose the full expressiveness of what's possible today. I do know, however, that if you do this, you will save agent builders a tremendous amount of headache because they won't need to worry about: when to launch sandboxes, if they're paying for idle resources, or even which sandbox the user data is saved in.
>
> The sandbox will just be the tool that the model uses to manipulate context. As you may have guessed, we're working towards building this truly serverless computer at @archildata. We've built the world's most powerful file system, and we've exposed way to use Linux commands to provide models the ability to query the context on that file system. It's already saving builders a tremendous amount of time from worrying about sandbox resources, but there's still a tremendous amount to do.
>
> [If you're interested in learning about what's coming next, we're hiring](https://jobs.ashbyhq.com/archil). Hope to hear from you soon.

### Reply thread

> [!quote]- Replies on the thread
> **@tiptenbrink (Tip ten Brink)** — Jun 15, 2026
> @jhleath "Like most things, it's hard". Sounds very hard indeed, great vision! I do wonder how in this world as an application developer you can ever do any "vertically integrated" optimization anymore, when it's all so abstracted away.
>
> **@Dan_The_Goodman (Dan Goodman 𝐶)** — Jun 15, 2026
> @jhleath the lack of bottom padding in your boxes is driving me NUTS
>
> **@YossiEliaz (Yossi Eliaz)** — Jun 16, 2026
> @jhleath Great read. Sharing similar vision
>
> **@Road_Kill11 (Rahul Karajgikar)** — Jun 17, 2026
> @jhleath great read! makes a lot of sense, been thinking about this a lot lately
>
> **@aitization (aitization 𝕏)** — Jun 16, 2026
> @jhleath you kinda look like Dario 🤷🏻‍♂️

Original: https://x.com/jhleath/status/2066541977227935829
