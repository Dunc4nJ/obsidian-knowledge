---
created: 2026-08-14
description: Hamel Husain's summary of Shreya Shankar's session on the Error Discovery skill — do error analysis on your logs before writing any eval rubric (writing the rubric first is the classic mistake), and use the skill to remove the friction: it updates a failure-mode taxonomy as you annotate, retro-checks earlier records for each new pattern, and uses active learning to choose the next examples based on what you've already labeled.
source: https://hamel.dev/notes/llm/ai-product-engineering/evals-error-analysis.html
author: Hamel Husain (summarizing Shreya Shankar's session)
type: article
tags: [eval, error-analysis, active-learning, annotation, taxonomy, ai-product-engineering, hamel]
---

## Key Takeaways

- **Error analysis before rubrics — always.** The common mistake is writing an eval rubric up front before looking at any data; the failure modes you imagine are not the ones your logs contain. Error analysis (reading and annotating traces) is the most human-intensive part of evals, which is exactly why teams skip it — the same skip that [[automating AI skill improvement fails without manual comprehension of outputs|breaks automated improvement loops]] and that [[agent eval readiness starts with error analysis and simple end-to-end tests not sophisticated infrastructure]] warns against. It is also "read your data" from [[benchmarks are measurement instruments not question collections - regulargio's first-principles guide to claims, graders, coverage, and uncertainty|benchmarking science]], applied to your own production traces.

- **The Error Discovery skill automates the bookkeeping, not the judgment.** As you annotate in a local review app, an AI agent maintains the failure-mode taxonomy: each new pattern is added and *earlier records are retro-checked* against it (so the taxonomy stays consistent as it grows), and **active learning** picks the next examples to review based on what you've already labeled — maximizing information per human annotation. The human stays the judge; the agent handles taxonomy hygiene and sample selection. Open-source as a Claude skill.

## External Resources

- Original note: [Automating Error Analysis — Hamel Husain](https://hamel.dev/notes/llm/ai-product-engineering/evals-error-analysis.html) ([AI Product Engineering series](https://hamel.dev/notes/llm/ai-product-engineering/))
- [Shreya Shankar's talk (walkthrough)](https://youtu.be/tqUDjc1HzO4) · [error-discovery-skill repo](https://github.com/shreyashankar/error-discovery-skill) · [Hamel's error-analysis FAQ](https://hamel.dev/blog/posts/evals-faq/why-is-error-analysis-so-important-in-llm-evals-and-how-is-it-performed.html) · [Active learning](https://en.wikipedia.org/wiki/Active_learning_(machine_learning))

## Original Content

> [!quote]- Full note — "Automating Error Analysis" (Hamel Husain; session by Shreya Shankar)
> _This note covers Shreya Shankar’s session in the [AI Product Engineering series](../../../notes/llm/ai-product-engineering/index.html)._
>
> Before creating any evals its important to perform data analysis of your logs so you know which errors occur. A common mistake is writing a rubric up front before looking at any data.
>
> This process is called [error analysis](../../../blog/posts/evals-faq/why-is-error-analysis-so-important-in-llm-evals-and-how-is-it-performed.html). It is the most human-intensive part of evals because it requires you to read and annotate traces.
>
> The [Error Discovery skill](https://github.com/shreyashankar/error-discovery-skill) removes much of this friction. It updates a failure-mode taxonomy as you annotate and checks earlier records for each new pattern. It uses [active learning](https://en.wikipedia.org/wiki/Active%5Flearning%5F%28machine%5Flearning%29) to choose the next examples based on what you have already labeled.
>
> ![[hamel-error-discovery-001.png]]
>
> The Error Discovery skill workflow. A human reviewer annotates in a local review app while an AI agent updates the failure-mode taxonomy and picks the next samples to look at.
>
> [Here](https://youtu.be/tqUDjc1HzO4) is a link to the talk, which is a walkthrough of how to use [the skill](https://github.com/shreyashankar/error-discovery-skill) properly.
