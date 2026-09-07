---
created: 2026-09-08
description: Archil founder Hunter Leath walks the AI Engineer World's Fair expo floor and finds that hundreds of sponsor booths reduce to five products -- agent orchestration, context layers, observability, governance, and data-for-labs -- and argues that because every company is converging on the same "slack + firecracker + context + governance + observability" formula, the eventual winner will be a shape nobody at the conference was selling.
source: https://x.com/jhleath/status/2072323804920185327
type: synthesis
---

## Key Takeaways

- **The entire AI infrastructure category reduces to five pitches, and Leath can name all of them from one walk of the expo floor**: orchestrate coding agents ("don't worry it's also multiplayer"), be the context layer that connects agents to systems of record, do agent observability ("now the agent is the oncall"), audit agents and prevent bad behaviour, and sell data to the labs. This is a founder's taxonomy of his own market, not an analyst's, and its value is that it is exhaustive rather than exhaustive-sounding. The vault holds a best-in-class exemplar of at least three of the five -- [[Glean argues enterprise indexing is necessary but not sufficient - the real unit is a unified permission-aware index inside a system of context of indexes, graphs, memory, connectors, and tools|Glean for the context layer]], [[agent trace data should live in your data lake not a 30-day SaaS retention window|trace-lake observability]], [[LangChain deep agents require persistent memory scoped sandboxes and guardrails to move from prototype to production|guardrails-and-sandbox governance]] -- which is itself evidence for the taxonomy holding. Read against [[Seema Amble (a16z) - software defensibility migrates from UI habit moats to data action and network moats as systems of record go headless|Seema Amble's defensibility framework]], categories 2 and 4 are precisely the moats a16z argues *deepen* under agents (connectivity, compliance) -- which explains why so many booths crowded into them, and why crowding does not equal durability.

- **"There is only one workload to win: agents" is the mechanism behind the collapse.** Where infrastructure companies used to differentiate by workload (streaming vs OLAP vs CDN), a single workload now absorbs the whole category, so differentiation has to happen inside one narrow surface. Leath compresses the consensus architecture into a formula -- `slack + firecracker + context + governance + observability = enterprise value` -- which is a fair summary of what the vault's own infra notes describe separately: [[Firecracker microVMs became the convergent agent runtime because containers were never a security boundary|Firecracker as the convergent runtime]], [[Anthropic sandboxes Claude across three products with gVisor containers, OS syscall filters, and VMs because model-layer defenses cannot stand alone against injection attacks|layered sandbox governance]], and [[elite engineering orgs are building internal coding agents that spread beyond engineering through Slack visibility|Slack as the distribution surface]]. The formula being *correct* is exactly the problem.

- **Booth size inversely tracks company health, which is a usable signal rather than a joke.** Leath observes that Modal and Baseten -- the largest and most successful infrastructure companies present -- had the smallest booths, while the largest booths belonged to companies "trying to convince attendees and investors that they were definitely critical to 'ai'", and that Vercel, who "maybe just built *the* agent framework", did not attend at all. Spend on category-membership signalling is a proxy for not having the category locked; the corollary is that expo-floor prominence is a bad input to any build-vs-buy or vendor-durability judgement.

- **Leath's own product is inside the trap he is describing, and he says so.** Asked what he builds -- a file system, for people building agents, to connect their agents to where the data lives -- he gets back "oh, there's like four of those here." The [[Bash is the SQL for file systems and Archil proves it with serverless execution that sends instructions not data|Archil thesis]] is genuinely differentiated at the architecture level (send instructions, not bytes), and it is still indistinguishable from four adjacent pitches at the booth level. That gap between real technical differentiation and unsellable positioning is the piece's actual subject, and his answer six weeks later is to teach the mechanism instead of pitching the category -- [[Remote file systems are 100x slower because every operation pays a network round trip and Archil fixes it by handing file ownership to the local kernel|"Understanding file storage"]] was his most-read piece by a wide margin. It generalises: [[Amazon S3 Files ends the object-file split for AI agents|S3 Files]] and [[a virtual filesystem over Chroma replaces sandboxes for agent doc exploration at 100ms instead of 46 seconds|ChromaFS]] are three different architectures that a buyer hears as one sentence.

- **The prescription is deliberately unspecified, and the honest read is that it is a bet rather than a finding.** Garrison's framing -- the right form factor will be "radically different than how infrastructure companies look today" and "obvious in hindsight" -- is unfalsifiable as stated, and Leath concedes it "doesn't give a lot of insight into what it really will be." The operational content is the negative claim: the questions the industry argues about (active vs provisioned CPU pricing for sandboxes, argued in detail in [[Opencomputer reframes harness-vs-sandbox debate as git branches for VMs via hibernation egress proxies and checkpoints|the Opencomputer/Mendral exchange]]; graph vs markdown vs vector memory, argued in [[a file system is not all you need - databases beat markdown for agent context provenance and governance]]; VNC vs per-second vs GPU-accelerated browser use) are ones "buyers don't" care about. That aligns with [[Applied AI doesn't work because the time was never in the work - Varick maps Hammer's 1990 re-engineering critique onto enterprise agents and sorts every step into deterministic, agentic, or human|Varick's re-engineering critique]] and with [[boring domain-specific AI businesses survive bubbles because measurable ROI and regulation moats beat general-purpose wrappers|the case for boring domain-specific businesses]]: value accrues where a buyer can name the outcome, not where a vendor can name the primitive.

- **Treat the Google analogy as rhetoric, not evidence.** "How did google win... did they build the best directory?" is survivorship-shaped reasoning -- Google did in fact win a crowded field partly by being better at the prevailing task (ranking), not only by changing shape. The piece is a founder's market take written three days after a conference, with a sample size of one expo floor; its taxonomy is the durable part, its prediction is not. Contrast the sourced market-structure work in [[data is a great place to start an AI company and a dangerous place to stop - Etna Labs maps the training-signal supplier market|Etna Labs' training-signal supplier map]], which reaches similar conclusions about category crowding from actual supplier economics.

## External Resources

- [Archil](https://archil.com) — Leath's company (YC F24), an elastic cloud file system for agents; see [[Bash is the SQL for file systems and Archil proves it with serverless execution that sends instructions not data]]
- [AI Engineer World's Fair](https://www.ai.engineer/) — the conference (@aiDotEngineer), Moscone Center, San Francisco; the "poaster" session is its satirical take on academic poster sessions
- [@QuinnyPig](https://x.com/QuinnyPig) — Corey Quinn, fellow poaster, presenting on AWS naming
- [@GeoffreyHuntley](https://x.com/GeoffreyHuntley) — fellow poaster
- [@HeyGarrison](https://x.com/HeyGarrison) — source of the "radically different / obvious in hindsight" form-factor argument
- Companies named as counter-examples of quiet success: [Modal](https://modal.com), [Baseten](https://baseten.co), [Vercel](https://vercel.com), [Fly.io](https://fly.io)

## Original Content

> [!quote]- Full article: "ai infra" is a dystopian wasteland — Hunter Leath (@jhleath), 1 Jul 2026
> Hunter Leath (@jhleath) — Wed Jul 01, 2026
> Article: "ai infra" is a dystopian wasteland
> 130 likes | 8 retweets | 15 replies | 97 bookmarks | 7 quotes | 17,401 views
> [Original on X](https://x.com/jhleath/status/2072323804920185327)
>
> yesterday, i had the great fortune of being invited to be a "poaster" at the @aiDotEngineer world's fair, so I packed up my bags and walked the nearly 5 blocks over to the moscone center to participate.
>
> what i found there has truly horrified me beyond all comprehension.
>
> the poaster session is sort of a sarcastic take on the poster sessions of regular academic conferences, where, instead of research, we would be standing in front of our hot takes and fighting with the crowd.
>
> next to me were such greats as @QuinnyPig, who was off at a table talking about how poorly AWS names things, and @GeoffreyHuntley who was standing in front a sign of southpark characters rubbing their nipples with the nipples tastefully replaced with @AnthropicAI logos. art.
>
> as for me? just a simple sign that said "file systems -- sorry about that"
>
> this turned out to be the normal part of the conference.
>
> conferences seem kind of silly to me, so i don't often attend. i relished the opportunity to wander around and pretend to be a buyer in order to exchange my time for low-quality shirts.
>
> at this conference, however, it seemed that if you took the time to sort the hundreds(?) of sponsors with booths, you basically only had five products fall out
>
> 1. we're building a way to orchestrate coding agents, don't worry it's also multiplayer
>
> 2. we're the context layer that connects agents to systems of record (thank you to the booth that gave me a coconut)
>
> 3. we do observability and agents need that too slash "now the agent is the oncall"
>
> 4. we audit the agents and prevent them from doing bad things
>
> 5. something something we're just here to sell data to the ai labs
>
> there was also the "we're a huge company, but we're DEFINITELY on top of AI" vibes that we got from the big booths -- major shout out to @Oracle for having someone standing in the middle of the room pitching Oracle databases for AI in 2026.
>
> is this really where we are as an industry? i felt like i had lost my mind. it was almost as if i were at a conference, hosted by @Lovable, in which they invited everyone who ever built a chat-to-app platform, had them all set up booths, and pitch each other.
>
> at one booth, i was talking to someone who handed me a paper where one side was their "pre-AI product" (data stuff) and the other side was their "post-AI product" (data stuff, but now it's a "context layer that connects agents to where the data lives").
>
> they asked what i build: a file system. "who uses it?" oh, people building agents. "for what?" to connect their agents to where the data lives.
>
> "oh, there's like four of those here." nah, as much as they pitch it, @Box is not a file system. or maybe it is. nothing matters anymore.
>
> at another booth, i was spotted by someone who follows me on twitter. "i love what you and the team are doing, i've been following along for a while" this is always a good interaction.
>
> unfortunately, the industry is in the wacky zone, so there's only way for it to end. "you know, we're building a file system too," he whispered to me. cool. meanwhile, *my* file system is just a black hole of engineering effort. good luck, as i wave at him walking away.
>
> all of these companies, for some unknown reason, have a silly animal mascot that's completely unrelated to their branding. "him? oh yeah that's Tweaky the Twilio owl. why do we have an owl? oh because voice AI is a haunting reminder of the fragility of the human economy, like the owls nighttime calls. take one."
>
> interestingly, booth size didn't seem to correlate with company success. there were the usual suspects who just had too much money -- @OpenAI had like rebuilt their office in the center of the expo hall and was giving away boba.
>
> but it seemed like many of the larger booths were just companies trying to convince attendees and investors that they were definitely critical to "ai".
>
> the largest and most successful infrastructure companies (think @modal @baseten) seemed to have the smallest booths, not trying to impress anyone with their spend.
>
> @vercel? the people who maybe just built *the* agent framework? not even there. probably too busy eating doner in NYC and working hard to *finally* beat @flydotio at launching docker containers.
>
> it feels like the entire infrastructure industry has collapsed in on itself.
>
> there is only one workload to win: agents.
>
> there is only one way to go about it: slack + firecracker + context + governance + observability = enterprise value.
>
> i was lamenting this yesterday to @HeyGarrison, who basically told me that he thinks that it's likely the case that nobody has actually figured out the right form factor, but when they do, it will be both:
>
> - radically different than how infrastructure companies look today
>
> - obvious in hindsight
>
> this feels correct to me, but doesn't give a lot of insight into what it really will be.
>
> i left the conference thinking one thing: it's clear that you can't win by doing the same things as everyone else. so, how do you figure out how to build the car when the world is throwing hundreds of millions of dollars into building the fastest horse?
>
> - will the sandbox company that wins have active cpu pricing or provisioned pricing?
>
> - will the memory layer that wins be graph based? markdown? vectors?
>
> - is browser use going to be over VNC? priced per second? gpu accelerated?
>
> who cares. buyers don't.
>
> we're [obviously] going to have to reflect on the 90s. how did the winners from the web bubble actually win? how did google win and become the dominant company for DECADES when search engines were such a crowded field? did they do the same thing as everyone else? did they build the best directory?
>
> no, they just built the thing that people actually wanted, even if it was a different shape than the prevailing wisdom. maybe the winner wasn't in one of the five booths i kept walking by.

### Notable reply

> **@KintaCollective (Hugo Pinheiro)** — [Jul 2, 2026](https://x.com/KintaCollective/status/2072583558145655127)
>
> 1 to 4 are the exact same things they built during the kubernetes/platform engineering bubble, now they moved on to AI and are redoing the same thing 🤣, I have yet to see a company build for the average person. I doubt they will ever warm up to using ai in the cloud.
