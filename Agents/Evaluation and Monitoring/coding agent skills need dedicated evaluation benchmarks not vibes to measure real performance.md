---
created: 2026-03-06
description: LangChain built an evaluation benchmark for their LangSmith and LangChain coding agent skills, finding that vibes-based assessment fails because performance varies widely across tasks and the action space is too large for intuitive prediction.
source: https://x.com/LangChain/status/2029618086374944771
type: learning
---

## Key Takeaways

LangChain's core argument echoes a pattern already established in the vault: [[agent skills need eval harnesses not vibe checks to ship reliably]]. The huge action space of coding agents makes variance across tasks unpredictable, so gut-feel assessments systematically mislead. Building a dedicated benchmark for their LangSmith and LangChain skills is exactly the kind of eval harness that separates shipped skills from demos.

This connects directly to the broader principle that [[deep agent evals need bespoke per-datapoint test logic not uniform evaluators]] — a single uniform metric cannot capture whether a coding skill actually works across diverse tasks. LangChain's approach of publishing both their findings and the benchmark itself for external use aligns with the credibility pattern in [[AI generated code repos gain credibility by shipping verification artifacts not hiding authorship]].

The benchmark being open for others to use suggests LangChain sees evaluation infrastructure as a competitive moat worth sharing — building community trust while establishing their eval methodology as a standard. This is relevant to [[agent production monitoring requires observing inputs and outputs not just system metrics]], since a benchmark at development time complements production observability.

*Evaluation benchmark results for LangSmith and LangChain skills*
![[langchain-944771-001.jpg]]

## External Resources

- [LangChain blog post on skill evaluation findings](https://t.co/n6jmubfTT7) — detailed writeup of their evaluation methodology and results
- [LangChain skill evaluation benchmark](https://t.co/4Ue2rUfVl7) — the open benchmark for evaluating LangSmith and LangChain coding agent skills

## Original Content

> @LangChain — 2026-03-05
>
> How to evaluate skills?
>
> Lots of companies are building skills for coding agents. But how do you know if your skill is actually working?
>
> It's tempting to go by vibes, but performance varies a lot across tasks — and coding agents have a huge action space, which makes that variance even harder to predict.
>
> We built an evaluation benchmark for our newly released LangSmith and LangChain skills.
>
> Learn about our findings here: https://t.co/n6jmubfTT7
> Check out the benchmark for yourself: https://t.co/4Ue2rUfVl7
>
> ![[langchain-944771-001.jpg]]
>
> Engagement: 111 likes | 21 retweets | 9 replies
> [Original post](https://x.com/LangChain/status/2029618086374944771)
