---
created: 2026-03-02
description: Cognition's 18-month performance review of Devin reveals it excels as an infinitely parallelizable junior engineer for clear-scoped tasks but struggles with ambiguity, iteration, and soft skills — the harness and task scoping matter more than raw model capability.
source: https://cognition.ai/blog/devin-annual-performance-review-2025
type: reference
---

# Devin's 2025 Performance Review: Learnings From 18 Months of Agents At Work

## Key Takeaways

Cognition's performance review of Devin after 18 months in production is one of the most honest public assessments of a coding agent's real-world capabilities. The core finding reinforces the thesis that [[agent-harness-is-the-real-product|the harness is the real product]]: Devin's success depends entirely on how well humans scope work, write playbooks, and structure the execution environment — not on the model getting smarter.

Devin's sweet spot is **clear-scoped, verifiable tasks at infinite parallelism** — security vulnerability fixes (20x faster than humans), framework migrations (10-14x faster), and test generation (coverage jumps from 50-60% to 80-90%). This maps directly to what [[harness engineering improved a coding agent 13 points by changing only system prompts tools and middleware|harness engineering research shows]]: structured task definitions and verification loops are the multiplier, not raw intelligence. The 67% PR merge rate (up from 34%) likely reflects harness improvements as much as model improvements.

The weaknesses section is equally revealing for [[putting yourself in the agents shoes is the unifying framework for agentic system design|agent system design]]. Devin fails at ambiguous requirements, mid-task scope changes, and iterative collaboration — exactly the areas where harness engineering hasn't yet found good solutions. The admission that "engineers working with Devin have to adjust to learning how to manage Devin effectively" is essentially saying the human becomes part of the harness.

The "senior intelligence on demand" pattern (DeepWiki documentation, AskDevin for planning) shows an interesting second modality: using the agent's codebase understanding for read-only knowledge work rather than code generation. Only [[designing agent tools is an iterative art shaped by model capabilities not fixed engineering rules|20% of engineering time is coding]] — the rest is planning, reviewing, and understanding, which is where senior-level comprehension matters more than junior-level execution.

## External Resources

- [DeepWiki](https://deepwiki.com/) — Cognition's tool for generating comprehensive codebase documentation
- [AskDevin](https://docs.devin.ai/work-with-devin/ask-devin) — Chat interface for codebase understanding and planning
- [Devin testing/refactoring docs](https://docs.devin.ai/use-cases/testing-refactoring) — Use case guide for test generation
- [Microsoft developer productivity study](https://www.microsoft.com/en-us/research/wp-content/uploads/2024/11/Time-Warp-Developer-Productivity-Study.pdf) — Source for the "20% of time is coding" stat
- [Eight Sleep + Devin case study](https://cognition.ai/blog/how-eight-sleep-uses-devin-as-a-data-analyst) — 3x data feature output with Devin as data analyst

## Original Content

> [!quote]- Source Material
> 
> *Hero image: Devin performance review banner*
> ![[cognition-devin-perf-001.png]]
> 
> November 14, 2025
> 
> # Devin's 2025 Performance Review: Learnings From 18 Months of Agents At Work
> 
> by The Cognition Team
> 
> Eighteen months after launch, Devin's gone from tackling small projects, to working in engineering teams at thousands of companies, including Goldman Sachs, Santander, and Nubank.
> 
> Devin's now merged **hundreds of thousands of PRs**.
> 
> At this point, Devin's well past due for a performance review - just like any human engineer.
> 
> ## How we evaluated Devin
> 
> We first tried to calibrate Devin against a traditional engineering competency matrix, but this was difficult. While human engineers tend to cluster around a level, Devin is senior-level at codebase understanding but junior at execution. It has infinite capacity but struggles at soft skills.
> 
> Instead we summarized Devin's strengths and weaknesses in real-world environments, with examples and metrics from customers. We hope this will be helpful to anyone who's interested in real-world agent deployment.
> 
> ## Strength pattern #1: Junior execution at infinite scale
> 
> Devin excels at **tasks with clear, upfront requirements and verifiable outcomes that would take a junior engineer 4-8 hrs of work.**
> 
> Unlike a human, though, it is infinitely parallelizable and never sleeps. This makes it well-suited to critical but less creative work like migrating and modernizing repos, fixing vulnerabilities surfaced by static analysis tools like SonarQube and Veracode, writing unit tests, and completing small tickets. This frees up human engineers for higher-impact projects.
> 
> Over the past year, Devin has become a faster and better junior engineer - it's **4x faster at problem solving** and **2x more efficient in resource consumption**, and **67% of its PRs are now merged vs 34% last year**.
> 
> *Devin performance improvements: problem solving speed, resource efficiency, and PR merge rate*
> ![[cognition-devin-perf-002.png]]
> 
> ### Security vulnerability resolution
> 
> Devin is great at resolving vulnerabilities flagged by static analysis tools (e.g. SonarQube, Veracode).
> 
> A few standout examples: One large organization **saved 5-10% of total developer time** by using Devin for security fixes. Another saw 20x efficiency gain: **human developers average 30 minutes per vulnerability, Devin, 1.5 minutes.**
> 
> ### Language and framework upgrades, migrations, and modernization
> 
> Customers use Devin for modernization and migrations, like SAS → PySpark, COBOL, Angular → React, .NET Framework → .NET Core, or switching off proprietary frameworks.
> 
> Once it gets instructions on how to update each repo, a fleet of Devins can execute on every repo in parallel. This results in massive savings. A few examples from this year:
> 
> - A large bank was migrating hundreds of thousands of proprietary ETL framework files. Devin completed each file's migration in **3-4 hours vs 30-40 for human engineers (10x improvement).**
> - When Oracle sunsetted legacy support for one Java version, Devin was able to migrate each repo in **14x less time than a human engineer.**
> 
> *Migration efficiency: Devin vs human engineers*
> ![[cognition-devin-perf-003.png]]
> 
> Using agents decrease the cost of modernization, so organizations can spend more time building new features than maintaining legacy code.
> 
> ### Test generation
> 
> Devin can do the first pass of [writing tests](https://docs.devin.ai/use-cases/testing-refactoring), with humans checking logic. Humans will write a unit testing playbook for Devin that spans a few hundred repos at a time. Then a fleet of Devins will go off and write the tests. After, code owners will check to see if all logic has been tested.
> 
> Companies' test coverage typically rises from **50-60% to 80-90%** when using Devin.
> 
> ### Brownfield feature development
> 
> When existing code provides clear patterns, Devin can replicate and modify: adding API endpoints, creating frontend components, extending functionality. **Devin pushed about ⅓ of the commits on our web app.**
> 
> ### PR review
> 
> Devin can execute first-pass reviews and catch obvious issues. Human review is still necessary, because code quality is not straightforwardly verifiable.
> 
> ### Data analysis & QA work
> 
> *Devin performing data analysis and QA tasks*
> ![[cognition-devin-perf-004.png]]
> 
> Devin is unexpectedly good at data analysis and quality assurance. Companies can "@" Devin in Slack and ask questions like "_can you pull yesterday's sales by channel?"_, _"can you check why this number looks off?"_, or ask it to create dashboards.
> 
> One customer, EightSleep, ships **[3x as many](https://cognition.ai/blog/how-eight-sleep-uses-devin-as-a-data-analyst) data features and investigations with Devin**. We constantly do use this internally (we even used Devin to pull metrics for this report.)
> 
> Another skill Devin has picked up is quality engineering. When Litera gave every engineering manager a "team of Devins" acting as QE testers, SREs, and DevOps specialists, test coverage increased by 40% and regression cycles got 93% faster.
> 
> ## Strength pattern #2: Senior intelligence on demand
> 
> **Only [20%](https://www.microsoft.com/en-us/research/wp-content/uploads/2024/11/Time-Warp-Developer-Productivity-Study.pdf) of engineering time is spent coding;** much more goes into other work, like planning and reviewing.
> 
> Devin's gotten massively better over the past year at understanding large codebases (one driver of its doubled PR merge rate). This means it can **quickly document large codebases, and assist humans with planning.**
> 
> This capability looks more like having a tenured senior engineer on-demand to answer any questions. Engineers can onboard faster, and chat with Devin to understand their codebase and plan projects.
> 
> ### Documentation
> 
> When onboarding to a codebase, Devin generates comprehensive, always-updating documentation with system diagrams ([DeepWiki](https://deepwiki.com/)). It can do this on large repos - customers have used DeepWiki to **generate docs for 5M lines of COBOL or 500GB repos.**
> 
> *DeepWiki documentation generation interface*
> ![[cognition-devin-perf-005.png]]
> 
> A bank could re-allocate several engineering teams from a big documentation project to new feature development, since **Devin generated documentation across 400,000+ repositories**.
> 
> ### Planning
> 
> When engineers are planning work, they will look at the documentation and chat with Devin ([AskDevin](https://docs.devin.ai/work-with-devin/ask-devin)) to understand the system. Devin can explain with architecture diagrams, map dependencies, and flag any breaking changes, and recommend what should be tackled by humans vs AI.
> 
> One engineer told us that he could **generate draft architecture in 15 minutes** for others to react to.
> 
> ## Devin's areas for improvement
> 
> ### Independent execution on ambiguous requirements
> 
> **Like most junior engineers, Devin does best with clear requirements.** Devin can't independently tackle an ambiguous coding project end-to-end like a senior engineer could, using its own judgement. For example, in visual design, Devin needs specifics like component structure, color codes, and spacing values.
> 
> When outcomes aren't straightforwardly verifiable, additional human review is necessary. Humans check unit testing logic after Devin takes the first pass, and check its code reviews.
> 
> ### Scope changes and iterative collaboration
> 
> Devin handles clear upfront scoping well, but not mid-task requirement changes. It usually performs worse when you keep telling it more after it starts the task. This differs from human juniors: you can coach a human through iterative problem-solving.
> 
> This puts more of a responsibility on the engineer to scope work well up-front. Engineers working with Devin have to adjust to learning how to "manage" Devin effectively.
> 
> ### Soft skills and interpersonal work
> 
> While it's great at collaborating in Slack, Teams, and Jira, it cannot manage reports or stakeholders or deal with teammates' emotions. It definitely won't be organizing lunch-and-learns or patiently mentoring a direct report any time soon! It is, however, infinitely friendly, patient, and responsive.
> 
> ## What's next
> 
> *Cognition team / future vision*
> ![[cognition-devin-perf-006.png]]
> 
> In 2026, we'll continue to work on making Devin better at understanding real-world codebases and using that context to collaborate with engineers on end-to-end SWE work. We're also investing in UX so Devin is easier to direct in everyday development.
> 
> If you're interested in hiring Devin, you can [talk to sales](https://cognition.ai/contact). Or, try running [DeepWiki](https://deepwiki.com/) on one of your codebases to check out Devin's codebase understanding.

[Source: Cognition Blog](https://cognition.ai/blog/devin-annual-performance-review-2025)
