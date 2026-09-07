---
created: 2026-09-08
description: Archil's Hunter Leath sorts the "Vercel for agents" contenders into three bets -- compute (sandbox vendors), networking (exe.dev), and storage (Archil) -- and argues storage wins because agents split into an addressable agent loop and cheap disposable sandboxes that need simultaneous shared access to a composable file namespace assembled from systems of record; Vercel CEO Guillermo Rauch replied "Vercel is Vercel for Agents."
source: https://x.com/jhleath/status/2062948931886334020
type: synthesis
---

## Key Takeaways

- The useful contribution is a taxonomy of what the contenders are actually betting on, not a product pitch. Sandbox companies bet the bottleneck is **compute** (spin servers up fast enough and flexibly enough); exe.dev bets it is **networking** (make servers trivially addressable and self-cloning); Archil bets it is **storage**. Leath's dismissal of the compute bet is the sharpest line in the piece -- spinning up a server quickly "doesn't *help*... you've just replicated what people were doing prior to Vercel for websites." That is a direct challenge to the runtime-convergence thesis in [[Firecracker microVMs became the convergent agent runtime because containers were never a security boundary]] and to the isolate-speed race in [[Cloudflare Dynamic Workers sandbox AI-generated code in V8 isolates 100x faster than containers]]: both optimize a variable Leath claims is no longer the binding constraint.

- The structural argument for storage rests on a two-part decomposition that most of this vault's harness notes assume implicitly: an agent is a **trusted agent loop** (connects LLM to tools, must be URI-addressable so webhooks can trigger it) plus **untrusted sandboxes** (cheap, spun up in quantity, manipulate context). Both halves touch the same dataset simultaneously -- the loop calls ReadFile while a sandbox runs `sed -i` -- and a Kubernetes ProvisionedVolume cannot be shared that way. Shared multi-machine access is the definition of file storage, so the primitive falls out of the topology rather than from vendor preference. It is the same trust boundary [[Anthropic Managed Agents virtualizes agent components into OS-style interfaces that decouple the brain from the hands]] draws, read for its storage consequence instead of its security one, and the same one that forces [[LangSmith Auth Proxy keeps credentials outside agent runtimes by intercepting sandbox egress at the network layer|credential brokering out to the network edge]] once the untrusted half is assumed hostile.

- The second requirement is **breadth**, and this is where the piece stops describing a file system and starts describing a context layer: one agent composes org skills (per-user-enabled markdown), reference data (Notion, Salesforce), agent-owned memory, and shared memory in git or Postgres. Leath wants those composed as mount-like units with separate access controls and mutation strategies, ideally reading from the systems of record directly so no second source of truth exists. That is the no-ETL position [[Seema Amble (a16z) - software defensibility migrates from UI habit moats to data action and network moats as systems of record go headless|Amble's headless-systems-of-record framework]] predicts vendors will fight over, the same land grab [[a16z argues AI systems of intelligence will eat the CRM by turning go-to-market databases into infrastructure consumed at the API layer|a16z's systems-of-intelligence thesis]] describes from the application side, and the file-shaped counterpart to [[context files beat MCP schemas for internal agents because they encode how your team actually uses each tool]] and to the universal-interface claim in [[Everything is Context - Agentic File System Abstraction for Context Engineering]].

- The network-effects argument is the weakest link and worth flagging as such. Leath's analogy: React won because components let developers modularize UX, compounding across the industry; agent building has no such effect because everyone ETLs into their own sandbox platform and rebuilds state-sharing from scratch. A composable storage system would let the industry share open-source "recipes" for representing each system of record in the way LLMs read best, and because agents build agents, pre-training on those shared patterns compounds -- hence his aside that no-code will not win this market. The analogy is doing a lot of work: React's network effect came from a component *interface* standard, not from a storage vendor, and nothing here explains why the recipes would standardize on Archil rather than on a protocol nobody owns. The counter-case is that the winners specialize rather than standardize -- [[domain-specific agents beat general-purpose ones by owning verification in boring industries]] argues the durable value sits in vertical verification, which no shared storage recipe supplies.

- Two things make this more than positioning. First, the reply from **Guillermo Rauch (@rauchg), Vercel's CEO** -- "Vercel is Vercel for Agents," to which Leath answered "big if true" -- given Leath's own aside that it is "funny... Vercel themselves haven't seemed to release anything yet to recognize this." Second, the concrete forward-looking commitment: Archil is working directly with several sandbox providers and expects to reposition itself "as a framework" for programmatically defining and interacting with agent context. That is a vendor announcing a move up the stack from storage to context framework, which is precisely the crowded category his own [[AI infra has collapsed into five identical products and Archil's Hunter Leath argues the winner will be a different shape entirely|five-identical-products taxonomy]] warned about.

- The mechanism this piece leaves unspecified is the one his transactions article supplies: what "shared simultaneously across the loop and N sandboxes" means when two sandboxes write the same file. [[Archil makes the agent turn the unit of filesystem atomicity with copy-on-write checkpoints and branches|Checkpoints, branching, and serverless-execution-as-transaction]] are the answer, and the two articles should be read as one argument -- the shape claim here, the concurrency semantics there. The competing answer keeps that state in the runtime rather than the storage layer, as in [[Opencomputer reframes harness-vs-sandbox debate as git branches for VMs via hibernation egress proxies and checkpoints]]. Without them this is [[every app that avoids a database ends up rebuilding one badly|another system that avoids a database and rebuilds one badly]].

## External Resources

- [Utpal Nadiger's post](https://x.com/utpalnadiger/status/2062702881019744474) — the quoted post that prompted the article: every sandbox vendor, agent framework (mastra, langchain, flue), and lab has shipped a take and "nothing feels right yet"; wants "the create-next-app for agents"
- [Lindy Drope's original post](https://x.com/Lindyydrope) — the root claim Nadiger quoted: "billion-dollar company is the Vercel for internal agents... an employee writes a Claude Code agent, hits deploy, and gets hosting plus a Convex database in one click"
- [exe.dev (@ssh_exe_dev)](https://x.com/ssh_exe_dev) — the networking bet: SSH-addressable servers that spin up copies of themselves; per Leath, used mostly for the agent-loop half of the stack
- [Archil (@archildata)](https://x.com/archildata) — the author's company, betting on storage
- [@asciidotdev](https://x.com/asciidotdev) — sandbox vendor cited in replies, positioning on price (claims 5x-25x cheaper) on the theory that sandboxes commoditize

## Original Content

> [!quote]- Full article: "Who will build Vercel for agents?" (Hunter Leath / @jhleath, 5 Jun 2026)
> Hunter Leath (@jhleath) — Fri Jun 05, 2026
> Article: "Who will build Vercel for agents?"
> 116 likes | 2 retweets | 11 replies
>
> This isn't surprising to you, but I believe there's a reason why none of the "vercel for agents" companies have won yet: none of these technologies have innovated in how to manage stateful applications.
>
> *The quoted post the article responds to: Utpal Nadiger on the crowded field, quote-tweeting Lindy Drope's "billion-dollar company is the Vercel for internal agents"*
> ![[jhleath-334020-001.jpg]]
>
> [tweet: https://x.com/utpalnadiger/status/2062702881019744474]
>
> Fundamentally, AI agents are *a very different shape* than what we used to deploy in the cloud.
>
> Previously, a "cloud application" would be an API wrapped around a database and S3. It would only need to access its own data, and the *server* didn't need to contain any state at all, so they were super simple to spin up/replace -- the "kubernetes" model of deployment.
>
> If you look out at the "agent deployment" options, everyone is sort of competing on what the *thing* is that will allow them to satisfy this new shape of application.
>
> The sandbox companies believe that the fundamental problem is compute. If you can spin up compute fast enough and flexibly enough, then you can serve agents. I don't find this very inspiring, but it also doesn't *help*. Spinning up a server quickly is helpful, but it's not enough for making agents simple -- you've just replicated what people were doing prior to Vercel for websites.
>
> [side note: it's funny to me that Vercel themselves haven't seemed to release anything yet to recognize this, but it's early days]
>
> I think the next most-inspired option is a company that believes that *networking* is the fundamental thing that needs to change in order to serve agents well. This is the category where I put @ssh_exe_dev. They're betting on the fact that having servers that are super easy to address (ssh exe.dev) and spin up copies of themselves is the fundamental primitive required to serve agents well.
>
> This seems to mostly be working, for select parts of the agent stack. We most commonly see people want to use exe.dev for the "agent loop" portion of the problem (where do you run the harness), but it doesn't necessarily solve the ability for that agent loop to call untrusted code or manipulate their context window.
>
> Instead, I [of course] believe that the real DX advancement that needs to happen to solve for incredibly simple agent deployment and management is *storage*.
>
> The reason for this is simple: agents are stateful in a way that no previous application was, so you need to figure out how to handle state differently than "configure a Kubernetes ProvisionedVolume if you want".
>
> Agents are actually made up of two different parts: the agent loop (the "trusted" code which contains the pieces that connect the LLM to the tools) and the sandbox (the "untrusted" code that runs to manipulate context). The agent loop needs to be addressable via a URI (for example, in order to set up a webhook that triggers the agent) and the sandbox needs to be cheap to spin up in large quantities.
>
> These two separate pieces need access to the same underlying data set -- simultaneously. (For example, the agent loop may call ReadFile, while the sandbox may call "sed -i <whatever>"). The agent loop may want to spin up more than one sandbox to manipulate the context.
>
> This requires that the underlying storage service can be *shared* across multiple machines -- in other words, file storage.
>
> Interestingly enough, the other reason why the old "ProvisionedVolume" model isn't the right one for agents comes to the second property that we spoke about. Not only are agents stateful, but they also (uniquely) need access to a great *breadth* of data instead of a singular data store that the application might own.
>
> A simple agent might combine: an organization's skills (markdown files, potentially enabled on a per-user basis), access to reference data (for example, Notion or Salesforce), agent-owned memory (markdown files that the agent can manipulate itself), and shared-memory (usually versioned using something like git or stored in a database like Postgres or SQLite).
>
> This means that the file-storage that the agent is using for its data needs to be *composable* across several different sources, with different access controls, permissions, and mutation strategies.
>
> Ideally, some of these composable units are actually reading from the systems of record directly so that the organization building agents doesn't have to maintain a second source of truth.
>
> This isn't a problem that you can solve with compute, no matter how fast it spins up or how many different operating systems you support.
>
> This is a problem that you solve with a new storage primitive.
>
> One of the reasons that we know this is the case is that infrastructure tools win when they have network effects that compound to push the industry farther.
>
> React and the Javascript frameworks won the web because it was simple for developers to modularize (with components) front-end UX with other developers, creating a compounding effect that made the entire web better than what we had before.
>
> There is no such effect today in agent-building. Everyone is ETL'ing their data into individual sandbox platforms and rebuilding how their agents communicate with sandboxes, share state, and interact with the LLM.
>
> If we had a composable storage system which allow synchronization from original sources, the industry could share and iterate (together) on open-source recipes to represent the data from these systems of record in the most efficient way for different LLMs to access.
>
> If these stateful applications are composable and open-sourced, it's simpler for agents to build *other agents* because the amount of pre-training on the patterns and code sharing increase as the industry adopts the standard. It seems obvious to me that agents building agents are the reason that "no-code" will not be the way to win this market.
>
> I, of course, believe that the technology that @archildata has built will underpin this next phase of the agent revolution. We're working directly with several sandbox providers now to push the industry in this direction, but this actually isn't enough.
>
> I expect that in the coming months we're going to start thinking very hard about how we start to represent Archil, as a framework, that can be used to programmatically define and interact with the context that agents need.
>
> If you're interested in collaborating on what could be the biggest opportunity of this moment, we're hiring right now -- please reach out.
>
> If you're building agents and you have opinions on what this looks like, please reach out -- we love to collaborate directly with developers and get more data on how the future should be shaped.
>
> Until then, just know that a better world is possible, and it's coming.
>
> [Original post](https://x.com/jhleath/status/2062948931886334020)

### The quoted post

> [!quote]- Utpal Nadiger (@utpalnadiger), 4 Jun 2026
> It's an open secret that everyone is trying to build and be this rn, but nobody has seen breakaway success.
>
> All sandbox vendors have their take (with the cookbooks et al)
>
> Agent frameworks like mastra, langchain and most recently flue have shipped their respective takes.
>
> The labs built managed agents and launched their take.
>
> It may be just me, but nothing feels "right" yet.
>
> But I feel OP is right.
>
> What everyone thinks about when one thinks "hey, I want to build an agent" is what will win
>
> The create-next-app for agents.
>
> > QT @Lindyydrope:
> > billion-dollar company is the Vercel for internal agents.
> >
> > an employee writes a Claude Code agent, hits deploy, and gets hosting plus a Convex database in one click.
>
> [Original post](https://x.com/utpalnadiger/status/2062702881019744474)

### Replies

> [!quote]- Thread replies
> **@rauchg (Guillermo Rauch, CEO of Vercel)** — Fri Jun 05, 2026
> @jhleath Vercel is Vercel for Agents
> [Link](https://x.com/rauchg/status/2062966710051676465)
>
> **@jhleath (Hunter Leath)** — Fri Jun 05, 2026
> @rauchg big if true
> [Link](https://x.com/jhleath/status/2062966990839706049)
>
> **@utpalnadiger (Utpal Nadiger)** — Fri Jun 05, 2026
> @jhleath thanks for the quote! and yes, we're all trying haha.
> [Link](https://x.com/utpalnadiger/status/2062969183017804019)
>
> **@dylnslck (Dylan Slack)** — Fri Jun 05, 2026
> @jhleath trying (planning on leveraging archil heavily btw)
> [Link](https://x.com/dylnslck/status/2062972894230249643)
>
> **@jhleath (Hunter Leath)** — Fri Jun 05, 2026
> @dylnslck amazing!! Let us know how we can make it better
> [Link](https://x.com/jhleath/status/2062973044197605875)
>
> **@AniC_dev (Anicet)** — Fri Jun 05, 2026
> @jhleath what's for sure is that it will become a commodity and if they make big margins ngmi
>
> that's why at @asciidotdev we decided to stay lean and build a sandbox product that's 5x to 25x cheaper than everyone else
> [Link](https://x.com/AniC_dev/status/2062978690409967678)
>
> **@kleptobyte (Kleptobyte)** — Fri Jun 05, 2026
> @jhleath Big agree on state emphasis. Storage matters less imo though.
>
> Agent behavior (abstractly), informed by context. Raises Q, where context come from?
>
> Storage sure yea I guess but there's A LOT that can happen between data at rest and compiled context being used
> [Link](https://x.com/kleptobyte/status/2063042765257167093)
>
> **@timjang3 (Tim Jang)** — Sat Jun 06, 2026
> @jhleath Can i use archil to run agents locally on my mac and then move the same workspace to a cloud sandbox?
> [Link](https://x.com/timjang3/status/2063154429101248861)
>
> **@arag_agrawal (Arag Agrawal)** — Mon Jun 08, 2026
> @jhleath i think its more about getting composability right
>
> storage + compute -> storage attachable to compute
> storage + deployment -> automated caching
> db + version control -> automated orm setup
>
> @ivanburazin wrote about this
> [Link](https://x.com/arag_agrawal/status/2063867424802558119)
>
> **@pavitrabhalla (Pavitra Bhalla)** — Fri Jun 05, 2026
> @jhleath Let's chat
> [Link](https://x.com/pavitrabhalla/status/2062950987585990995)
>
> **@ivandotcodes (Ivan)** — Sat Jun 06, 2026
> @jhleath @encoredotdev did
> [Link](https://x.com/ivandotcodes/status/2063166945487155452)
