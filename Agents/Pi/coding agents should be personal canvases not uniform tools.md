---
created: 2026-03-16
description: A Pi coding agent user built 10 custom themes, a music player, an animated companion, a knowledge graph, and more — arguing that coding agents should be personal canvases shaped by individual taste, not uniform terminals everyone uses identically.
source: https://x.com/marv1nnnnn1/status/2033215133410013385
---

# coding agents should be personal canvases not uniform tools

## Key Takeaways

Pi's real extension system and theming engine enable a level of personalization that most coding agents lack entirely. While [[the harness layer is the next hundred billion dollar AI infrastructure market not the model|the harness layer is where value lives]], this post argues the harness should also be *personal* — not just technically capable but aesthetically and functionally shaped by the individual user. The author built 10 custom themes, a music player, an animated companion called Navi, a knowledge graph, a project board, and an LLM council — all as Pi extensions.

The music player extension is architecturally interesting: it exposes real-time audio analysis (energy, beat, transients, spectral flux) as a data stream that other extensions can consume. This composability — extensions reading from other extensions — is what makes Pi's extension model generative rather than just configurable. The Navi companion reacts to music data, creating a particle visualization that pulses with the beat.

The LLM council extension (inspired by Karpathy's llm-council) has different models independently analyze a problem before a chairman synthesizes. This mirrors [[separating cognitive blueprints from runtime engines enables portable auditable agent systems|the pattern of separating cognitive roles]] in multi-agent orchestration, but brought down to a single-user terminal workflow.

The philosophy that "software is becoming cheap to build" and the right response is personal software rather than more generic tools connects to the broader trend of [[repo-local skills and AGENTS.md turn recurring engineering work into repeatable agent workflows|agents becoming personalized through local configuration]]. Pi's approach goes further — it's not just config files but a full extension ecosystem with community packages (pi-extmgr, pi-agentic-compaction, pi-rewind, pi-web-providers).

The [[pi-agent-rust Findings (Deep Dive)|pi agent deep dive]] in the vault covers the technical architecture; this note captures the user-side experience of what that architecture enables when someone actually commits to personalizing their agent environment.

## External Resources

- [Pi mono repo](https://github.com/badlogic/pi-mono/tree/main/packages/coding-agent/examples/extensions) — default extensions and examples
- [Karpathy's LLM Council](https://github.com/karpathy/llm-council) — inspiration for the multi-model council extension
- [shittycodingagent.ai/packages](https://shittycodingagent.ai/packages) — Pi community package registry
- [RSS feeds gist](https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b) — feed sources used by Navi
- [Kaku terminal](https://github.com/nicbstme) — terminal by @HiTw93 mentioned in the post

## Original Content

> [!quote]- Source Material
>
> **@marv1nnnnn1** — Sun Mar 15 2026 — 174 likes, 7 retweets, 9 replies
> [Original tweet](https://x.com/marv1nnnnn1/status/2033215133410013385)
>
> ## Build Something Just for Yourself: #2 Why not make your coding agent personal?
>
> Everyone is using Codex and Claude Code now. Open your Twitter feed and every other screenshot looks identical — the same terminal, the same monospace font, the same pale text on dark background, the same tool call outputs scrolling by. It's like we all moved into the same apartment and nobody bothered to hang anything on the walls.
>
> And we're spending a lot of time in that apartment. 8 hours, 10 hours, sometimes more — entire working days inside a black rectangle, talking to an AI that reads your code and writes it back. The terminal isn't something you pass through anymore. It's where you live. So why does everyone's look exactly the same?
>
> In the last post I talked about how the fastest way to build something meaningful might be to start by building for yourself. This time I applied that to the place I work. I've been using a terminal agent called pi, built by @badlogicgames . It does what the others do — but it has something most of them don't: a real extension system and a full theming engine. So I started customizing. And now it look this like:
>
> *Pi terminal with custom theming applied*
> ![[marv1nnnnn1-013385-001.jpg]]
>
> *Additional customized Pi interface view*
> ![[marv1nnnnn1-013385-002.jpg]]
>
> The first thing I did was color. I wrote 10 custom themes from scratch. Not "dark mode with blue accents" — actual palettes with intent behind them. The one I use most is called *terayama*, after Shuji Terayama, the avant-garde Japanese playwright. Deep theatrical blacks, warm parchment text. I am also using  the terminal Kaku from @HiTw93 which is visually stunning.
>
> *Custom theme examples*
> ![[marv1nnnnn1-013385-003.jpg]]
>
> Then I added music. I wrote an extension that turns pi into a music player — YouTube, Mixcloud, Bandcamp, NTS Radio, all playable from inside the terminal. Search, queue, play, pause, seek. `Alt+P` to pause, `Alt+[` and `Alt+]` to seek. Under the hood it's mpv and yt-dlp, but the interesting part is what happens on top: the extension exposes real-time audio analysis — energy, beat, transients, spectral flux — as a data stream that other parts of the system can read.
>
> *Music player extension in Pi*
> ![[marv1nnnnn1-013385-004.jpg]]
>
> Which is where Navi comes in. Navi is a small animated entity that lives below the editor. It has moods — idle, thinking, happy, excited, sleeping. It pulls headlines from random Wikipedia articles, Hacker News top list, and RSS feeds (credits to https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b). And its particle field reacts to the music data. The particles pulse with the beat. It's a tiny VJ show running in your terminal while you work. Navi levels up based on how many tokens you burn.
>
> *Navi animated companion with particle visualization*
> ![[marv1nnnnn1-013385-005.png]]
>
> Beyond the big ones, here's everything else I wrote:
>
> - A knowledge graph that extracts entities from URLs and builds a searchable second brain.
>
> *Knowledge graph visualization*
> ![[marv1nnnnn1-013385-006.jpg]]
>
> - A project board the AI can read so I don't have to re-explain context.
>
> *Project board extension*
> ![[marv1nnnnn1-013385-007.jpg]]
>
> - Background tasks with automatic log capture. Session branching — version control for conversations.
>
> - An LLM council where different models independently analyze a problem and a chairman writes the synthesis. (inspired by @karpathy 's https://github.com/karpathy/llm-council)
>
> *LLM council extension*
> ![[marv1nnnnn1-013385-008.jpg]]
>
> Pi also comes with a set of default extensions that I've kept and tweaked — cost tracking, token usage, protected paths, an interactive shell, context management. You could find them from https://github.com/badlogic/pi-mono/tree/main/packages/coding-agent/examples/extensions and the best thing is you could just tweak on them and make it whatever you want.
>
> And none of this would exist without the community packages I installed:
>
> - pi-extmgr — extension manager that makes installing and updating all of this painless
>
> - pi-agentic-compaction — smart context compaction so long sessions don't blow up
>
> - pi-rewind — rewind and branch session history
>
> - pi-web-providers — web search from inside the agent
>
> - @sherif-fanous/pi-rtk — runtime toolkit
>
> *Community packages / Pi ecosystem*
> ![[marv1nnnnn1-013385-009.jpg]]
>
> I genuinely love pi. I often check https://shittycodingagent.ai/packages to see if there's anything interesting. In a landscape where every coding agent feels like a slightly different skin over the same four API calls, pi got something right: it's an agent that trusts you to make it yours. Open source in the way open source is supposed to work — not just "the code is on GitHub," but actually designed so that anyone can extend, reshape, and personalize it.
>
> Software is becoming cheap to build. That's the reality of 2026. And I think the right response isn't to keep building the same generic tools for everyone — it's to let people create their own. Personal software. Software shaped by one person's taste, habits, and weird preferences. Pi makes that possible for the coding agent itself. It took something that was becoming boring and uniform and turned it into a canvas.
