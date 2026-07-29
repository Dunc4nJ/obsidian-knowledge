---
created: 2026-07-29
description: 0xfJuan's full playbook for making a product launch trend on X — a mental model of how X's ranking promotes posts circle-by-circle (speed, signal cost, conversation breadth), then a four-stage system to manufacture those signals on purpose: (1) build a Claude-powered swipe file from 50+ niche accounts, (2) a hook of video + a claim-not-description first line + a first-reply comment gate, (3) tiered creators (big/expert/small) posting on a timed schedule for 200+ posts in 4 hours, (4) convert the spike by replying to everything and staying visible.
source: https://x.com/0xfjuan/status/2082138861136736272
author: "@0xfJuan (Juan)"
type: article
tags: [x-growth, marketing, launch, distribution, virality, copywriting, creators, playbook]
---

## Key Takeaways

- **The core mental model — X promotes posts circle-by-circle, and "trending" is a reclassification.** X doesn't show a new post to all your followers; it shows a small sample, watches engagement for a short window, and only promotes it to a bigger circle if that sample engages — repeating outward past your followers into strangers' feeds. Three levers decide advancement: **speed** (50 real interactions in the first 15 min beat 1,000 spread over 3 days, because fast engagement is what an *event* looks like), **signal cost** (a like is free so it counts for almost nothing; replies, reposts, and bookmarks are "expensive" signals the algorithm trusts), and **conversation breadth** (many accounts posting the same subject within hours). "Trending" is the moment breadth crosses a threshold and X stops seeing *a post* and starts seeing *a subject* — pushing the conversation to people who follow nobody involved. All four stages exist to manufacture speed + expensive signals + breadth on purpose.

*Proof of the intro claim — a launch driven to 2.4M views in 24h (note the reposts ≈ replies, the "expensive" signals):*
![[0xfjuan-736272-001.png]]

- **Stage 1 — Research: build a swipe file from proof, not taste.** The recurring failure is copy written around what the founder finds interesting instead of what the market already responds to. Point Claude Code at 50+ accounts that talk to your buyers (direct competitors, adjacent products, every recent category launch), pull their posts via a cheap X-data key (e.g. twitterapi.io), keep only posts that beat *that account's own average views*, and have it write one swipe file ranked by views with a note on *why* each winner worked (first-line construction, claim type, video vs. image, the CTA). The output is proof of what your exact market stops scrolling for. Warning: study patterns, not sentences — then write your own.

- **Stage 2 — Hook: video + claim + comment gate, built as one unit.** The video is 60–90s with the single most impressive thing on screen in the first 5 seconds, understandable sound-off (not a logo or founder intro). The first line matters more than the video and must be a *claim, not a description* — "claims start arguments, descriptions end them" — doing one of three things: announce the old way is finished, plant a flag as the first of something new, or attack what your market resents; push it to the edge of believable (a line people feel they must fact-check is a line they click) and test that a non-tech person can repeat it at dinner. The lead magnet goes in the **first reply, not the main post**, behind a comment gate — its visible job is collecting leads (~90% opt-in when the offer is real), its hidden job is farming comments (an expensive signal) in the exact window the post is being judged.

*Stage 2 in the wild — a claim-not-description first line ("the old way just died"), a sound-off video, and an "RT + comment to get access" gate:*
![[0xfjuan-736272-002.png]]

- **Stage 3 — Manufacture breadth on a schedule.** Line up creators *before* launch day in three tiers with three jobs: **big accounts** (raw reach — hundreds of thousands of strangers), **mid-size niche experts** (trust — their followers are your actual buyers; ten experts convert harder than one giant whose audience doesn't care), and **hundreds of small accounts** (make the subject feel like it's coming from everywhere — the algorithm counts *how many voices* a subject has, not just the loudest). Brief each with the exact post-minute, link, claim, and a few angle options — and insist they write in their own voice (a post that sounds like your marketing department is money lit on fire). Timing is the whole game: big accounts + experts in hour one (the classification window), small accounts in waves across the next three hours, targeting **200+ posts in the first four hours** so the pattern reads as "the platform discovering something," not a campaign.

*Stage 3/4 coordination — live launch updates as creator waves roll out ("6 creators live, we're at 12k… sending micro-creators… second wave soon", then 100k+ in 3h):*
![[0xfjuan-736272-003.png]]

- **Stage 4 — Convert the spike, then don't vanish.** When it tips (strangers post unprompted, unsolicited DMs, screenshots into group chats), most founders celebrate and let millions of impressions evaporate. Instead: the founder replies to *everything* (each reply restarts the conversation under your post = fresh fuel), DMs everyone who shared or quoted the same day while you're still top-of-timeline, delivers the lead magnet fast with a "what are you building?" question (turns a downloader into a conversation), and posts live milestones as plain numbers (signups, views, waitlist) for 48 hours — "for 48 hours you are one story, so post nothing that isn't that story." The durable lesson beyond the spike: buyers rarely buy the day they see you trend — they buy weeks later when their problem shows up, from whoever they've seen the most. **"Trending gets you known but staying visible is what gets you paid."**

## External Resources

- Original article: [How To Get Your Launch Trending On X (Full Guide) — @0xfJuan](https://x.com/0xfjuan/status/2082138861136736272)
- Tools mentioned: [twitterapi.io](https://twitterapi.io/) (cheap X-data access, no approval) · Claude Code (Stage 1 swipe-file automation)

## Original Content

> [!quote]- Full X Article — "How To Get Your Launch Trending On X (Full Guide)" (@0xfJuan / Juan, 2026-07-28)
> Article: How To Get Your Launch Trending On X (Full Guide)
>
> In the last 2 weeks alone I've driven 6m+ impressions to tech companies, and one of them hit 2.4M impressions in its first 24 hours.
>
> None of it was luck. Trending on X is a system with four stages, and this article is the entire thing, written so you can run it without me.
>
> Here's exactly how it works:
>
> (bookmark this now, you'll be coming back to it on launch day)
>
> ---
>
> ## HOW TRENDING ACTUALLY WORKS
>
> When you hit post, X doesn't show your post to your followers. It shows it to a small sample of them, watches what they do for a short window, and uses that reaction to decide whether anyone else ever sees it.
>
> If the sample engages, your post moves to a bigger circle, and if that circle engages it moves again, out past your followers and into the feeds of strangers. Every post you've written that died at 300 views failed that first round.
>
> Three things decide whether you keep advancing:
>
> - Speed. The algorithm cares less about how much engagement you get than how fast it arrives, because fast engagement is what an event looks like. Fifty real interactions in the first 15 minutes carry a post further than a thousand spread over three days
>
> - What the engagement is made of. A like costs nothing, so it counts for almost nothing. A reply means someone stopped scrolling to talk to you, a repost puts their name on your post, and a bookmark means they plan to come back. The algorithm trusts expensive signals over cheap ones
>
> - Whether the conversation outgrows your post. One post doing big numbers is just a good day. But when many accounts post about the same thing inside the same few hours, X stops seeing a post and starts seeing a subject the platform is talking about
>
> That third one is what trending actually is: the moment the algorithm decides you're a subject, and starts putting the conversation in front of people who follow nobody involved.
>
> Hold onto those three, because all four stages exist to manufacture them on purpose.
>
> ---
>
> ## STAGE 1: THE RESEARCH
>
> Every failed launch I've studied made the same mistake: copy written around what the founder finds interesting instead of what their market already responds to. Stage 1 removes the guessing, and it takes one afternoon.
>
> You're going to build a Claude system that studies your niche for you.
>
> First, get access to X data. You don't need the official enterprise API; a service like twitterapi.io gives you a key in minutes, costs a fraction of a cent per tweet, and has no approval process.
>
> Second, build your study list of 50 or more accounts that talk to the same audience you're about to sell to:
>
> - Your direct competitors
>
> - The products next door to yours
>
> - Every company in your category that launched in the last six months
>
> Their audiences already voted on thousands of posts, and those votes are sitting there in public.
>
> Third, open Claude Code and hand it the job. Tell it to pull the recent posts from every account on the list, keep only the ones that beat that account's own average views, and study what the winners have in common: how the first line is built, what kind of claim it opens with, whether video or images carried it, and what it asks the reader to do.
>
> Have it write everything into one swipe file, ranked by views, with a note on each post explaining why it worked.
>
> What you get back is a document most marketing teams never have: proof of what your exact market stops scrolling for, ranked by results. When you write your launch copy, you'll be reshaping hooks that already worked on your buyers instead of inventing lines and praying.
>
> One warning so this stage doesn't get misused: the swipe file is for patterns, not sentences. You're studying why things worked, and then writing your own.
>
> ---
>
> ## STAGE 2: HOOK PEOPLE
>
> Stage 2 is everything a stranger sees in their first ten seconds: the video, the first line above it, and the reason they leave a comment. These three get built together, as one unit.
>
> The video. 60 - 90 seconds, bent around one rule: the most impressive thing your product does has to be on screen within the first five seconds, understandable with the sound off. Not your logo, not a founder introduction. The thing itself.
>
> Your swipe file will show you every format your market has already seen, which tells you what would feel new. The same product shown through a frame nobody in your category has used is what makes someone stop.
>
> The first line. It matters more than the video it sits on. It has to be a claim, not a description, because claims start arguments and descriptions end them.
>
> The strongest claims do one of three things: announce that the old way of doing something is finished, plant a flag as the first of something new, or attack a thing your market already resents. Push it right up to the edge of believable, because a line people feel the need to check is a line people click.
>
> Then test it on someone outside tech. If they can hear your line once and say it back over dinner, it will travel, and if they can't, rewrite it until they can.
>
> The lead magnet. In your first reply, not the main post, offer something genuinely worth having in exchange for a comment: a free playbook, a template, a breakdown, early access. When it's something your buyers actually want, this works close to 90% of the time.
>
> The visible job is collecting leads. The hidden job is bigger: comments are among the most expensive signals the algorithm counts, and a good comment gate produces hundreds of them in the exact window where your post is being judged.
>
> ---
>
> ‼️ IF YOU HAVE A LAUNCH COMING UP DM ME AND I WILL PERSONALLY SEND YOU A LOOM VIDEO BREAKING DOWN WHAT IT SHOULD LOOK‼️
>
> ---
>
> ## STAGE 3: GET ATTENTION
>
> Trending only happens when the conversation grows beyond your post. This stage makes that happen on schedule, and it's the part almost every founder skips.
>
> You need creators lined up before launch day, in three kinds with three different jobs:
>
> - Big accounts bring raw reach, putting your launch in front of hundreds of thousands of strangers at once
>
> - Mid-size experts in your niche bring trust, because their followers are your actual buyers, and ten of them convert harder than one giant account whose audience doesn't care about your category
>
> - Small accounts, hundreds of them, make the conversation feel like it's coming from everywhere. The algorithm is counting how many voices a subject has, not just how loud the loudest one is
>
> Every creator gets briefed before the day: the exact minute to post, the link, the claim, and a few different angles to choose from so forty posts don't come out looking like one press release from random accounts.
>
> Then the most important instruction: write it in your own voice. Their audience follows them for how they sound, and a post that sounds like your marketing department is money lit on fire.
>
> Timing is where this stage earns its name. Your big accounts and experts hit within the first hour, inside the window where the algorithm is deciding what your post is. Your small accounts roll out across the next three hours, wave after wave, so the conversation keeps visibly growing instead of spiking once and dying.
>
> Done right, you should see 200 or more posts land across the first four hours. To the algorithm, that pattern doesn't look like a campaign, it looks like the platform discovering something.
>
> ---
>
> ## STAGE 4: THE CONVERSION
>
> Somewhere in the first several hours, if the first three stages were built properly, the machine tips over: strangers post about you unprompted, DMs arrive from people nobody contacted, and your product gets screenshotted into group chats you'll never see.
>
> Most founders treat this as the finish line and start celebrating, which is how millions of impressions evaporate into nothing. Stage 4 is where trending becomes worth the trouble.
>
> While the fire is burning, the founder replies to everything. Every comment gets a real answer, because every reply restarts the conversation under your post, and every restarted conversation is fresh fuel.
>
> Everyone who shared or quoted you gets a DM the same day, while you're still the most interesting thing on their timeline. Everyone who commented on your lead magnet gets their delivery fast, with one extra line asking what they're building, because that question is what turns a downloader into a conversation.
>
> If you have five people, launch day is one person posting and four people in the DMs
>
> At the same time, keep feeding the timeline:
>
> - Post milestones as plain numbers as they happen: signups, views, waitlist size. Live numbers give people a story to follow
>
> - Reply publicly to the big accounts that show up late
>
> - Cut new pieces from what's already working: clips of the video, screenshots of wild reactions, a founder note on what the day has been like
>
> For 48 hours you are one story, so post nothing that isn't that story.
>
> And when the spike fades, don't vanish. Your buyers mostly don't buy the day they see you trend; they buy weeks later, the day their problem shows up, and they buy from whoever they've seen the most between now and then.
>
> Trending gets you known but staying visible is what gets you paid.
>
> ---
>
> # TLDR
>
> Trending on X is a system with four stages, and every one of them is doable in-house:
>
> - Stage 1, the research: set up a Claude system that pulls the top posts from 50+ accounts in your niche and turns them into a swipe file, so your copy is built on proof instead of guesses
>
> - Stage 2, the hook: a 60 to 90 second video with the magic moment in the first 5 seconds, a first line that makes a claim people have to check, and a comment gate in the first reply that farms the algorithm's favorite signal while it builds your lead list
>
> - Stage 3, the creators and the timing: big accounts and niche experts in hour one, waves of small accounts through hour four, everyone briefed to write in their own voice, 200+ quote posts total
>
> - Stage 4, the conversion: reply to every comment, DM everyone who shared, deliver the lead magnet fast with a question attached, post milestones for 48 hours, and then stay on the timeline every day, because buyers buy from whoever they've seen the most
>
> ---
>
> ## ONE MORE THING
>
> If your company is launching in the next 30 days and you'd rather have this whole system run for you, DM me and tell me what you're building, and if we're a fit I'll show you exactly what your launch would look like completely for FREE.
>
> And if you're running it yourself: bookmark this, build the four stages, and send me your results either way. I wrote this because I want to watch a few founders pull it off, and I mean that.
