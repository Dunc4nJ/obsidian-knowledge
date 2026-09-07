---
created: 2026-09-08
description: Archil's Hunter Leath argues serverless hosting is "the MCP of the hosting world" — a sprawl of non-standard tools that degrades agent accuracy the same way MCP schemas did — and that the industry will swing back to single-box deployment because Claude debugs a Vercel/Neon/Datadog stack far worse than it debugs a $5 VPS where code, database and logs are all local.
source: https://x.com/jhleath/status/2066905912238023154
type: framework
---

## Key Takeaways

- **The load-bearing analogy: serverless hosting is to deployment what MCP was to tools.** Leath's argument is that the industry already ran this experiment. Agents got worse as the number of non-standard tools they had to learn grew, so the fix was to hand them a lowest-common-denominator interface — bash and the file system — that can represent any problem without per-tool learning. A Vercel + Neon + Datadog deployment is the same failure mode one layer down: to debug a 500, the agent must first learn your architecture, then cross-correlate three vendors' non-standard telemetry to decide whether the database is overloaded, the code is broken, or the CPU is pegged. This is the deployment-layer restatement of [[code execution with MCP cuts tool token overhead 98 percent by presenting servers as filesystem APIs instead of upfront definitions|MCP-as-filesystem-API]] and [[Everything is Context - Agentic File System Abstraction for Context Engineering|the "everything is context" framing]], and Leath explicitly invokes the bitter lesson — the same move [[The bitter lesson of agent harnesses is your helpers are abstractions too - Browser-Use ships a 600-line CDP + SKILL.md harness|Browser-Use made by collapsing its harness to 600 lines of CDP plus a SKILL.md]].

- **The claim is about *colocated context*, not about servers being cheap.** On a single box, SSH plus Claude gives the agent the code, the database, the logs and the CPU usage in one place, using the same Linux tooling the labs RL'd the models on ("coding... is ultimately the same skill as using a Linux machine"). Leath cites @levelsio as already working this way. His forward claim: most applications will move to a deployment strategy where everything *appears* to be running locally, because that is what maximizes agent performance over the computer-as-context. Read as a design rule, it inverts the usual advice — the more managed services your app depends on, the less AI-ready it is once triage and repair become a closed loop.

- **The distribution argument is what makes this more than nostalgia.** AI raises the volume of software written while lowering the average load per piece, because more software becomes personal. So the mass of new applications lands to the right of the line where a single box suffices — while the core infrastructure underneath needs *more* scale than ever. That split is what lets Leath argue for the VPS without arguing against horizontal scaling, and it is the same "the load is not evenly distributed" insight that justifies [[a virtual filesystem over Chroma replaces sandboxes for agent doc exploration at 100ms instead of 46 seconds|skipping the sandbox entirely for lightweight agent work]].

- **He names his competitors and draws the fork honestly.** exe.dev (@ssh_exe_dev) and Fly.io Sprites modernize the virtual server: a consistently addressable box, a disk that persists, network services you own, SSH in and call Claude. Archil takes the other branch — many ephemeral, geo-distributed, replicated computes all pointing at one file system — aiming to keep serverless high-availability while giving the agent colocated context. The distinction matters because it is the same disagreement as [[Archil argues today's agent sandboxes are a better EC2 not serverless, and the end-state is a query language over the file system|his previous piece]]: everyone agrees context must be in one place, and they disagree about whether that place is a machine or a file system.

- **Cross-note tension: this article is the counterargument to most of the vault's sandbox cluster.** [[Firecracker microVMs became the convergent agent runtime because containers were never a security boundary|Firecracker's ~125ms boot at 150 VMs/second]], [[Opencomputer reframes harness-vs-sandbox debate as git branches for VMs via hibernation egress proxies and checkpoints|Opencomputer's 25ms hibernation resume]] and [[don't build agents, build environments - Ramp bakes machine images every 30 minutes so agents go from cold to working in under a second|Ramp's sub-second pre-baked images]] all optimize how fast you can create a *fresh* environment; Leath argues the winning environment is the one that was never torn down, because its accumulated state is the context. Note also what he does not address: a persistent SSH-able box with the production database on it is precisely the arrangement [[isolating the entire agent in a sandbox is more secure than isolating just the tool|the sandbox-isolation argument]] and [[Anthropic sandboxes Claude across three products with gVisor containers, OS syscall filters, and VMs because model-layer defenses cannot stand alone against injection attacks|Anthropic's layered gVisor/microVM defense]] exist to prevent. "Agent debugging is easier" and "the blast radius is the whole system" are the same property.

- **Self-serving disclosure, stated but not neutral.** Leath answers his own rhetorical question — "But I know this is secretly about file systems, right?" — with "Yes, of course," and the closing section is a positioning statement for Archil against two named competitors. The MCP analogy is genuinely portable; the conclusion that the answer is an "infinite, high-performance file system" is his product. The counterfactual he offers ("had we as an industry invested more into building amazing storage solutions") is unfalsifiable, and it happens to describe what he sells. Compare his adjacent notes on the same thesis: [[Archil argues the file system is the sandbox because a server's identity is its data, not its compute]] and [[Bash is the SQL for file systems and Archil proves it with serverless execution that sends instructions not data]].

## External Resources

- [Archil](https://archil.com) — Leath's company (@archildata); ephemeral compute pointed at one shared file system
- [exe.dev](https://exe.dev) — @ssh_exe_dev; a modernized always-addressable virtual server with a persistent disk
- [Fly.io Sprites](https://fly.io) — @flydotio's take on the same "virtual server for the agent era" idea
- [@levelsio](https://x.com/levelsio) — cited as the existing proof point: single-box VPS deployment plus SSH-and-call-Claude debugging
- [Andrew Qu's reply](https://x.com/andrewqu/status/2066906850797437165) — "You're on a streak of banger X articles," and Leath's answer about waking up and dumping 1,000 words on the world

## Original Content

> [!quote]- Full text of "Agents were built for the $5 VPS" by Hunter Leath (@jhleath), Jun 16 2026
> Hunter Leath (@jhleath) — Jun 16, 2026
> Article: "Agents were built for the $5 VPS"
> 67 likes | 4 retweets | 2 replies
>
> Today's application and sites are being hosted on tons of serverless platforms, but it's about to become clear that this is the "MCP" of the hosting world. Just like we moved from "MCP" to file systems, the world will move from serverless platforms back to the "virtual server" as the de-facto hosting strategy in the agent era. Let's talk about why.
>
> How things used to be
>
> Before all of this "javascript" happened, you used to deploy websites and software the old-fashioned way, by installing everything onto a server. LAMP was the name of the game, the best stack to use was Linux (for your OS), Apache (for your webserver), MySQL (for your database), and PHP (for your actual content).
>
> *Deployment yesterday versus today: PHP files over FTP plus a MySQL backup/restore into one VPS with observability on-box, against Javascript stuff plus a fake local database deploying to CloudCorp, which connects out to DatabaseCorp and ships logs to ObservabilityCorp*
> ![[jhleath-023154-001.png]]
>
> The nifty part about these olden times (or the now times if you're @levelsio) is that everything was really easy. If you wanted to test your application locally, well, you had the files, you could install the same webserver, you could run MySQL, and just see the same results. If you wanted to deploy to the cloud, you would just ... copy your stuff up to the box -- files could use ftp and your database might need to be backed up and restored.
>
> There was just one box, one place where everything in your cloud lived (okay, maybe you still had a managed database), but you could easily SSH into that box and poke around at ... the server logs, the CPU usage, the request count. There was no external observability stack, the tools that you used to debug regular Linux processes just worked in this world.
>
> Then comes scale
>
> As time went on, and the great Web 2.0 applications needed to handle more and more traffic, people realized that putting everything on a single-box was a recipe for not being able to grow your site traffic.
>
> - If your database is on one box, how do you grow it past the storage size of that box?
>
> - If your web server is on one box, how do you allow it to serve an unbounded number of requests per second?
>
> - If your code is on one box, how do you make it so that's low-latency for people all around the world to access?
>
> - If you only have one box, what do you do if that box has downtime or needs to be replaced?
>
> The answer to these problems was, of course, horizontal scaleability. What if these things weren't on a single box, and they were instead fully-managed, highly-available services. They could even be geo-distributed for latency reasons! The region? Earth.
>
> This was really, really hard to build, and the companies that desperately needed this kind of scale (Facebook, Amazon, Google) spend tremendous amount of resources making them possible. The people who worked at these companies left, realized that building for high-scale was the right thing, and slowly diffused these technologies to developers by making them easier and easier to use -- which leads us to the crop of "neo-clouds" that we have today.
>
> There is just one problem with this story. It used to be the case that you could just SSH into your server and understand the full state of the world. Is it working? Is my database down? Am I burning too much CPU? Why did that request get a 500 error? These were easy to answer on one server, but nearly impossible to answer if your code was running across thousands of anonymous servers that you don't have access to across the globe.
>
> And so, for the industry's second act, we needed to invent a bunch of new observability tooling which would be able to aggregate data across all of these hosts and provide value to the developers who were trying to understand their systems.
>
> Thus, we end up in state where a website could be deployed on Vercel, using a database from Neon, and sending logs and telemtry to a third system like Datadog.
>
> Enter the agent
>
> Now, in 2026, the world has changed tremendously again. We have all of this amazing tooling that lets us create and build software faster than ever before.
>
> This means that far more people will be creating software than before, and there will be a LOT more of it. Interestingly though, the "load" that this software needs to support will not be evenly distributed. As more and more software becomes "personal", the average piece of software will actually have lower performance requirements than at any time in the past (this, obviously, excludes the core infrastructure that this vast new quantity of software runs on, which will need to support much higher scale than before).
>
> *The distribution shift: plotted against 1/requests-per-second, AI advancements widen and fatten the long tail of viable software, and Leath's red line marks the point past which "everything to the right can run on a single box"*
> ![[jhleath-023154-002.jpg]]
>
> These AI tools are really good at using Linux machines because the labs have spent a tremendous amount of effort RL'ing these models into being good at coding (which is ultimately the same skill as using a Linux machine).
>
> If you look at an agent harness like Claude code today, how does it actually debug a problem with your website deployed on the Vercel, Neon, Datadog stack? Well, it needs to learn the context of the architecture -- figuring out what services your application is using. Then, for the problem, it might need to cross-correlate a bunch of data from these non-standard tools in order to determine whether your database is overloaded and needs more compute, whether there's a code issue, or whether there's some kind of CPU overloading happening.
>
> This starts to look a lot like the problems we were seeing with MCP earlier in the year. The more non-standard tools that the agent needs to use in order to determine the context of the problem, the lower the accuracy and performance. This is why the industry shifted towards giving the agent a standardized set of tools, like bash and the file system, which could represent any kind of problem without the agent needing to learn how to use them.
>
> Now consider how you would debug a problem with Claude code if you were @levelsio and just deploying everything to a single-box VPS. You just ... SSH to the box, call Claude, and it has all of the context necessary locally (from the code [present on the box], to the database [present on the box], to the logs [present on the box], to the CPU usage [present on the box) to make a determination. In fact, I think that he actually says that this is exactly how he's using AI today.
>
> This is way simpler, uses lowest-common denominator tooling (the bitter lesson of infrastructure), and is going to lead to the agent becoming higher performance for these types of problems.
>
> As a result, I think that, moving forward, the vast majority of applications are actually going to move to a deployment strategy in which everything appears to be running locally on the current machine, because this is what gives Claude the highest performance to operate on the computer-as-context.
>
> The more services that your application depends on and uses, the more worried you should be about your application being AI-ready as the software lifecycle becomes a closed-circle, with AI triaging and fixing most of the issues.
>
> But I know this is secretly about file systems, right?
>
> Yes, of course. I think that, had we (as an industry) invested more into building amazing storage solutions, we could have avoided some of the pitfalls of creating thousands of different point-solutions that customers need to cobble together to build a working application. If you are able to share the same context (via an infinite, high-performance file system) of your... database, logs, and code, even if the application is actually running on thousands of machines spread across the globe, then we would have had an industry better prepared for tools that work better when context is co-located on the same system.
>
> This is where I see three companies, us at @archildata, @ssh_exe_dev, and the @flydotio Sprites building interesting solutions towards.
>
> *Two shapes of the same bet: neo-virtual servers (exe.dev, fly.io Sprite) put a consistently addressable box on top of a persistent disk holding code, database and logs, while Archil points many ephemeral computes at one consistently addressable file system holding the same three things*
> ![[jhleath-023154-003.png]]
>
> exe.dev and sprites are working to bring the "virtual server" into the 21st century. You can login and get a box that can host network services, like databases and websites, and treat it as your own -- it's always addressable, the disk stays around, and it otherwise just "looks" like a virtual server. You can run all of your services here, or SSH in and call Claude to debug the system.
>
> @archildata is taking a similar, but different approach. We are envisioning a world in which users have lots of ephemeral compute (which could be, geo-distributed, replicated for redundancy, etc) that all points to the same file system. I think that while exe.dev and Sprites may get us to a place where every developer can have their own server, Archil is going to get us to a place where we can replicate the benefits of serverless (high-availability) with the best outcome for agents (context is all close together and easily accessible).
>
> You can stuff your code, database, and logs directly into an Archil file system and have them work (even if they're on multiple hosts), or you can spin up an ephemeral session with Claude to poke around all of these services to better understand how they're working.
>
> Regardless of what ends up being the right shape of what a virtual server becomes, it's clear that agents will perform better when everything is in one place.
>
> *The performance claim stated plainly: Claude pointed at one VPS holding code, DB and logs "is going to outperform" Claude fanning out to serverless hosting, a serverless database and serverless observability*
> ![[jhleath-023154-004.png]]

### Reply thread

> [!quote]- Replies on the thread
> **@andrewqu (Andrew Qu)** — Jun 16, 2026
> @jhleath You're on a streak of banger X articles
>
> **@jhleath (Hunter Leath)** — Jun 16, 2026
> @andrewqu lol i appreciate you, i figure if there's one thing i can do, it's to just wake up and dump 1,000 words on the unsuspecting world

Original: https://x.com/jhleath/status/2066905912238023154
