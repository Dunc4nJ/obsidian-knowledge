---
created: 2026-08-14
description: Hamel Husain's summary of Lucas Machado Rocha's session — a case study of evals for Nova Escola's lesson-planning assistant (Brazilian edu nonprofit, ~1M monthly users, 200k teachers). Two named mistakes: writing the rubric before error analysis (labeling data for criteria that never failed) and building an eval for a problem a one-line prompt fix solved. Annotators agreed less often than chance until pedagogical experts rewrote the rubric; the team now catches regressions with daily evals over 2% of production traffic.
source: https://hamel.dev/notes/llm/ai-product-engineering/evals-production.html
author: Hamel Husain (summarizing Lucas Machado Rocha's session)
type: article
tags: [eval, case-study, production, annotation, rubric, education, regression-testing, ai-product-engineering, hamel]
---

## Key Takeaways

- **Two named mistakes worth their weight: rubric-before-error-analysis, and eval-before-cheap-fix.** Lucas's team (1) wrote the rubric before reading traces — most criteria never appeared as real failures, so they labeled data nobody needed; and (2) built an eval for a bug (two learning goals emitted instead of one) that a prompt change simply eliminated — not every failure mode deserves an automated evaluator. Both are the field-tested versions of [[agent eval readiness starts with error analysis and simple end-to-end tests not sophisticated infrastructure|error-analysis-first eval readiness]].

- **The annotator-agreement tripwire: two annotators agreed *less often than chance* — the rubric, not the annotators, was broken.** "The team had not defined what good looked like clearly enough," so they rewrote the rubric with pedagogical experts and relabeled. This is [[benchmarks are measurement instruments not question collections - regulargio's first-principles guide to claims, graders, coverage, and uncertainty|positionality made concrete]]: *somebody* must decide what counts as good, and for lesson plans that somebody is a domain expert, not an engineer. Measure agreement early — it is the cheapest broken-rubric detector.

- **Production pattern: automate after error analysis, then run daily evals on 2% of traffic.** Failure modes came from human error analysis; only then did eval skills automate the follow-on work (writing LLM judges, validating them against human labels — the [[anthropic recommends combining deterministic graders model judges and human review for agent evals|judge-validated-against-humans]] discipline). The regression net is a daily eval suite over a 2% sample of production traffic — a concrete, affordable template for [[a working offline eval turns vibes into repeatable measurement in 10 steps|keeping measurement running]] after launch.

## External Resources

- Original note: [Case Study: Putting Evals Into Production — Hamel Husain](https://hamel.dev/notes/llm/ai-product-engineering/evals-production.html) ([AI Product Engineering series](https://hamel.dev/notes/llm/ai-product-engineering/))
- [Lucas's end-to-end walkthrough](https://youtu.be/mF4CaijvJos) · [Nova Escola](https://novaescola.org.br/) · Hamel's FAQ: [when to automate an evaluator](https://hamel.dev/blog/posts/evals-faq/should-i-build-automated-evaluators-for-every-failure-mode-i-find.html) · [eval skills](https://hamel.dev/blog/posts/evals-skills/)

## Original Content

> [!quote]- Full note — "Case Study: Putting Evals Into Production" (Hamel Husain; session by Lucas Machado Rocha)
> _This note covers Lucas Machado Rocha’s session in the [AI Product Engineering series](../../../notes/llm/ai-product-engineering/index.html)._
>
> Lucas used evals to optimize a lesson planner for [Nova Escola](https://novaescola.org.br/), a Brazilian nonprofit education platform with \~1M monthly users and 200,000 teachers. His talk covers the full process. Two mistakes his team made:
>
> 1. He wrote a rubric before doing error analysis. Since most of his criteria never appeared as failures, his team spent time labeling data they did not need.
> 2. He built an eval for a problem that needed a simple fix. The assistant sometimes emitted two learning goals when it should emit one. His team changed the prompt and the problem stopped. We discuss this tradeoff in [the FAQ on when to automate an evaluator](../../../blog/posts/evals-faq/should-i-build-automated-evaluators-for-every-failure-mode-i-find.html).
>
> The labeling process exposed another problem. Lucas used two annotators, and they agreed less often than chance. The team had not defined what good looked like clearly enough, so they rewrote the rubric with their pedagogical experts and relabeled the data.
>
> ![[hamel-nova-escola-001.jpg]]
>
> Lucas’s eval spreadsheet.
>
> After his team identified the failure modes through error analysis, Lucas used the [eval skills](../../../blog/posts/evals-skills/index.html) to automate parts of the work that followed, including writing judges and validating them against human labels.
>
> Lucas’s [end-to-end example](https://youtu.be/mF4CaijvJos) shows his entire process. He catches regressions early by running a suite of evals daily against 2% of production traffic.
