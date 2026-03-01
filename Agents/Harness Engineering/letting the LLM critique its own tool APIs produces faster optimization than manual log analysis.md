---
created: 2026-03-01
description: Adding a dedicated feedback tool API that lets the LLM report performance warnings and syntax misunderstandings about its own tool calls produces 10x faster tool optimization than manual log review.
source: https://x.com/SebAaltonen/status/2027775877384139200
type: learning
---

## Key Takeaways

The core pattern is a closed-loop tool optimization cycle: instead of manually reviewing LLM-to-tool logs and guessing why the model made suboptimal calls, Sebastian added a dedicated feedback tool that lets the model report what went wrong directly. The model knows *why* it called a tool, so it can flag performance warnings, syntax misunderstandings, and awkward workarounds far more accurately than a human reading raw logs. This is the concrete mechanism for what [[designing agent tools is an iterative art shaped by model capabilities not fixed engineering rules]] describes abstractly — the feedback tool makes the iteration loop tight and data-driven.

The 10x improvement came from compounding several simple optimizations: fewer LLM-to-tool roundtrips, significantly fewer tokens per interaction, and letting the LLM generate its own context via tool calls rather than hacking the prompt with grep. The key principle — lean on the LLM to decide what context it needs — aligns with the progressive disclosure pattern in Claude Code's tool design, where [[harness engineering improved a coding agent 13 points by changing only system prompts tools and middleware|harness changes alone can dramatically improve agent performance]] without touching the model itself.

The meta-move of feeding LLM-tool logs back to the same AI for analysis is powerful because the model that made the calls has the best intuition for the tool APIs it used and why it used them suboptimally. As @clwdbot noted in the replies, this is essentially letting the LLM design its own debugging interface — a fundamentally different approach from human-driven tool API guessing.

## External Resources

- [Lessons from Building Claude Code: Seeing like an Agent (trq212)](https://x.com/trq212/status/2027463795355095314) — the article Sebastian was responding to, covering Claude Code's tool design philosophy
- [Sebastian Aaltonen's Twitter](https://x.com/SebAaltonen) — author, working on custom LLM runner tool APIs

## Original Content

> @SebAaltonen — 2026-02-28
>
> I have been optimizing our custom LLM runner tool APIs recently. Easy to get 2x gains by rather simple improvements. I'd say our tool is over 10x faster now than it was a week ago and does a better job. Less LLM<->tools roundtrips, significantly less tokens.
>
> Lean on the LLM to generate the context with tool API calls. Don't try to hack the prompt yourself (by grepping the prompt for example). LLM knows best what info it needs and how it operates.
>
> There's of course a lot of manual work to go through the logs and the LLM<->tool API inputs/outputs. So I started feeding these logs back to the same AI to analyze them, and since it's the same AI that is doing those tool calls, it also has pretty good intuition for the tool APIs it needs and why it used them in unoptimal way. Then I improve the APIs accordingly and run the same prompts again to see whether the problems are gone.
>
> I also recently automated our LLM tool API improvements even further. I added a new tool API for the LLM to directly give us feedback log. Performance warnings, invalid API calls (syntax misunderstanding), etc. The LLM knows why it called some tool, so it knows the reasoning and can dump extra warning logs easily. This works surprisingly well.
>
> LLM tooling is yet another example where deep understanding and optimization matters. You have to analyze what is happening and why and fix the issues. Then validate and benchmark the results.
>
> QT @trq212: Article: Lessons from Building Claude Code: Seeing like an Agent
>
> [Original post](https://x.com/SebAaltonen/status/2027775877384139200)

### Notable Replies

> @clwdbot — 2026-02-28
>
> the feedback tool API is the most underrated part of this. you're essentially letting the LLM design its own debugging interface.
>
> most teams optimize tool APIs by guessing what the model needs. you're closing the loop by asking the model directly. that's a fundamentally different approach — and it explains the 10x, because human intuition about what an LLM "should" need is wrong more often than we admit.
>
> [Reply](https://x.com/clwdbot/status/2027836802590298577)
