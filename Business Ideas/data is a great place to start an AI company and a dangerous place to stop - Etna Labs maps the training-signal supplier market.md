---
created: 2026-08-21
description: Etna Labs' (Patrick Tianyi & Hannah Xu) investment map of the AI training-signal supplier market — Mercor ($500M→$2B run rate in under a year), Handshake, Fleet (~$1M→$63M+ in six months), the first in-depth look at China's research-native data vendors (UniPat, Humanlaya), Sean Cai's Type 1 (recorded) vs Type 2 (performed) data taxonomy with their Type 1.5 extension, four distinct businesses hiding inside "AI data" (human data at scale, RL environments, RLaaS, real-world data rights), and the core thesis: AI data is a flow business — datasets don't compound; expert networks, renewable data rights, verifiers, simulators, and production feedback loops do.
source: https://x.com/hannahhaina/status/2090519081279705359
author: "Patrick Tianyi & Hannah Xu (Etna Labs)"
type: article
tags: [market-analysis, training-data, rl-environments, rlaas, data-rights, china-ai, investment-thesis, mercor, business-ideas]
---

## Key Takeaways

- **The market is compounding at lab speed, priced at a discount that encodes its fragility.** Mercor's reported run rate went ~$500M → $2B in under a year; Handshake $550M → $1B in four months; Fleet ~$1M → $63M+ in six. Several US labs spend at or near **$1B/year on external data** (Anthropic reportedly ~$1B on RL data in 2025 alone), and across every interview "the binding constraint was qualified supply, not money." Yet private markets value data companies below labs and inference platforms — the discount encodes TAM doubt, customer concentration (a handful of labs), and revenue unpredictability: the dominant format rewrites itself every 1-2 years (RLHF → expert SFT → RL environments → now real-world company data), so a dataset built for one release is obsolete by the next. Hence the one-sentence view in the title: **great place to start, dangerous place to stop.**

*Data providers grew at lab speed — at a fraction of the scale; and the US vs China gap in both investment and external training-data spend:*
![[etna-ai-data-003.jpg]]
![[etna-ai-data-001.jpg]]

- **China's edge is research leverage, not cheap labor — the data loop as an organizational unbundling of the model lab.** Researchers leaving Qwen, Kimi, and ByteDance Seed rebuild the whole loop — task design, expert authoring, model-assisted generation, harness engineering, training, evaluation — inside *one accountable team*, where inside a lab a data request crosses product/procurement/vendors/labelers/researchers and "when the model does not improve, no one owns the failure." **UniPat** ("data is approximately the model"): profitable in under a year with software-like margins, the same researcher designs the task, builds the verifier, trains the model, inspects failures, and redesigns the batch — validated coding data selling at 5-10x competing offerings. **Humanlaya**'s sobering lesson: "data without evaluation is inventory" — clean, diverse data doesn't necessarily improve a model, quality is only observable through training, and distillation rarely creates signal beyond the teacher's distribution.

*The AI data stack, US vs China:*
![[etna-ai-data-002.jpg]]

- **The best framework in the piece: Type 1 (recorded) vs Type 2 (performed) data — and why performed data breaks at long horizons.** Adopting Sean Cai's (Standard Data) taxonomy: the internet preserved *outputs*, not *work* — GitHub accidentally recording how programmers work (not just what they produce) is much of why coding became the first domain where models are genuinely useful, and "most industries have no GitHub." Type 2 (commissioned/performed) data fails at long horizons three ways: **the reward must be invented** (every human-designed intermediate reward is a hacking surface, where real work ships with observable outcomes), **the distribution goes artificial** (experts reproduce the work they imagine — missing info, broken tools, interruptions, and rework are cut first and are exactly what agents need), and **humans can no longer author the frontier** (as models pass the median practitioner, task authorship shifts to database internals and distributed systems). Etna's half-step extension, **Type 1.5**: source tasks and failure modes from real work, then use experts to reconstruct intent, shape rewards, and defend against reward hacking — "the valuable asset is recurring access to fresh workflows, plus the synthetic machinery that makes them trainable." The rights may matter more than the data.

- **Four different businesses hide inside "AI data," with four different endgames.** (1) *Human data at scale* (Surge, Mercor, Scale, Handshake — >60% of labs' external budgets): operationally real but margin-capped by expert labor, priced at ~10x run rate assuming near-perfect execution. (2) *RL environments* (Fleet, Mechanize, Datacurve, Patronus): proximity-to-frontier advantage but ~six-month half-life per delivery, standardizing interfaces (Harbor, BrowserGym, OpenEnv), and labs handing vendors specs — Etna "would pass on any company limited to hand-building environments"; the escape is simulation/UED where "the reusable asset is the world generator and evaluation loop, not any single environment" — the maturation of [[rl environment creation is becoming a distributed marketplace that could 10x cost efficiency over contracting firms|the RL-environment contracting industry]] and [[RL environments are the new unit of progress in agentic AI training|environments-as-unit-of-progress]] into an investable (and already-consolidating) category. (3) *RLaaS* (Applied Compute, Trajectory, with Tinker/Prime Intellect commoditizing the training layer): the only category not lab-dependent — but "sells reinforcement learning and delivers systems integration," and Etna's surprise pick is that the long-term winner may be a lab/inference platform bundling the whole stack, with **Thinking Machines positioned exactly there** (cf. [[Bridgewater and Thinking Machines fine-tune Qwen3-235B to replicate expert investor judgment, beating frontier LLMs on financial information-filtering at 13.8x lower cost|the Bridgewater engagement]]). (4) *Real-world data rights* (Protege, San Francisco Data, Sunset buying failed companies' Slack/email/Drive as RL-gym feedstock): sell-many-times economics and exclusive-rights defensibility — underwrite "the durability of access, not the size of the first dataset."

*Four businesses inside "AI data" — structure, what compounds, endgame — and what founding teams own by origin:*
![[etna-ai-data-005.jpg]]
![[etna-ai-data-006.jpg]]

- **The thesis that ties it together: AI data is a flow business — datasets don't compound, four assets do.** Researcher trust, renewable supply with surviving rights, a quality system tested by *training outcomes* (graders/verifiers improving because the supplier sees actual results — [[Phoebe Yao argues verifier engineering is the moat in RL post-training because verifiability bounds learnability|verifier engineering as the moat]]), and migration speed ("kill revenue that is still growing but about to depreciate"). The demand side confirms the vault's adjacent theses: buyers spend increasingly on verifiers and graders because "credentials alone predict little"; Harvey's [[Harvey's Tenet post-trains Kimi K3 with GSPO in rubric-graded legal environments, doubling LAB hold-out completions while co-optimizing cost via reward shaping|Tenet]] is the buyer-side view of exactly this supplier ecosystem (Mercor expert data, Fireworks training); and the endgame — "as more useful data comes from people doing real work, the advantage shifts toward the company that owns the workflow, model, or application" (Trajectory as "the product is the data") — is [[Harrison Chase argues companies must own their intelligence by controlling the model-harness-context system its governance and the compounding feedback loop|own-your-intelligence]] and [[a16z argues AI systems of intelligence will eat the CRM by turning go-to-market databases into infrastructure consumed at the API layer|the systems-of-intelligence thesis]] arrived at from the data-supply side. Exit map: no pure data business IPOs; M&A to labs (Meta/Scale), compute platforms (Baseten/Parsed), or workflow owners (Databricks, ServiceNow, Palantir-as-template). Standing caveat: [[vertical model advantage may not survive the next frontier release]] applies to every specialized-model bet in the piece.

## External Resources

- Original article: [Data Is a Great Place to Start an AI Company, and a Dangerous Place to Stop — @patrick_tianyi & @hannahhaina (Etna Labs), 2026-08-20](https://x.com/hannahhaina/status/2090519081279705359)
- Referenced frameworks & maps: [Sean Cai's Type 1/Type 2 taxonomy (AI Engineer talk)](https://www.youtube.com/watch?v=ZyIoTOAbRfs) · [Deedy Das's supplier ARR map](https://x.com/deedydas/status/2076124392711696455) · [Sapphire's environment-company map](https://sapphireventures.com/blog/reinforcement-learning-environments-ai-agents/) · [Pavlov's List (Chris Barber's RL-environment directory)](https://pavlovslist.com/)
- Companies spotlighted: [UniPat](https://unipat.ai/) ([ExpertEval](https://unipat.ai/blog/ExpertEval), [BabyVision](https://unipat.ai/blog/BabyVision)) · [Humanlaya](https://humanlaya.com/) · Handshake · AfterQuery · Fleet · Patronus · Thinking Machines · Trajectory · Protege · San Francisco Data
- [Etna Labs](https://etnalabs.ai/)

## Original Content

> [!quote]- Full X Article — "Data Is a Great Place to Start an AI Company, and a Dangerous Place to Stop" (Patrick Tianyi & Hannah Xu, Etna Labs, 2026-08-20)
> Article: Data Is a Great Place to Start an AI Company, and a Dangerous Place to Stop
>
> by @patrick_tianyi and @hannahhaina from [etnalabs.ai](https://t.co/bdD0PBAwhg)
>
> Inside the global suppliers capturing frontier labs’ billions, the shift from one-off datasets to trainable workflows, and the first in-depth look at China’s research-native data vendor ecosystem.
>
> Every frontier lab now writes some of its largest checks for something that appears on no org chart: training signal.
>
> The suppliers are compounding at lab speed. Mercor's reported run rate went from ~$500 million to $2 billion in under a year. Handshake reportedly went from $550 million in January to $1 billion by April. Fleet, an RL environment company, went from ~$1 million to $63 million in six months, and has reportedly more than doubled since.
>
> Almost all of this revenue comes from a handful of labs. Contracts arrive in bursts, and what buyers want changes quickly. A dataset built for one model release may be obsolete by the next.
>
> Our one-sentence view: data is a great place to start an AI company, and a dangerous place to stop.
>
> China is where this pattern is clearest. Its most interesting suppliers are former model researchers who compress task design, expert authoring, model-assisted generation, harness engineering, training, and evaluation into one loop. [Unipat](https://unipat.ai/) shows how quickly that structure can generate revenue; [Humanlaya](https://humanlaya.com/) explains why it exists: data work is fragmented and underpriced inside labs. Chinese buyer demand remains concentrated around release schedules, distillation, and benchmark gaps. But leading suppliers are already mixing expert work, human-in-the-loop data, and model-assisted production. Their durability will depend on whether this research loop can follow models into recurring real-world workflows.
>
> Over the past several months, we spoke with founders, researchers, buyers, and operators across the market. We kept coming back to three conclusions:
>
> 1. Demand for training signal will remain a major line item, even though the format labs buy keeps changing.
>
> 2. The most valuable new data increasingly comes from work that happened for a business reason, with the tools, corrections, and outcome attached.
>
> 3. The vendors we expect to last keep something reusable after delivery: a denser expert network, exclusive data rights, better verifiers, a simulator, or a production feedback loop.
>
> ## 01 Our Investment View
>
> We expect the market to grow, but not with today’s supplier ranking intact. The turnover creates room for new companies.
>
> 1. Training signal is a durable input.
> Unless labs such as Flapping Airplanes or SSI achieve a step-change in sample efficiency, Transformer-based models will keep consuming more—and more varied—training signal: SFT, RLHF, expert demonstrations, agentic environments, real-world trajectories. But the total market for signal and the addressable market for vendors are different things. Self-play, synthetic pipelines, internal traces, and in-house harnesses all grow the former while shrinking the latter.
>
> 2. New companies form where models fail.
> Production usage over-samples tasks users already believe the model can handle. Capabilities beyond the current frontier therefore leave little organic data; the signal has to be produced to order. Each time models crossed a new capability threshold over the past three years, labs opened a new procurement category. The latest is real-world company data.
>
> 3. The newest opportunities are real-world data and quality infrastructure.
> Longer-horizon agents make naturally occurring work trajectories more useful because the task distribution is real and the outcome is often observable. Buyers are also spending more on verifiers, graders, and expert reviewer selection as they learn that credentials alone predict little about whether a data point will improve a model.
>
> 4. China's edge is research leverage, not cheap labor.
> Researchers leaving Qwen, Kimi, Seed, and other model teams are rebuilding the data loop outside the lab, combining expert task design, model-assisted generation, harness engineering, training, and evaluation in one accountable team. This structure moves faster than the fragmented workflow inside many labs. China’s buyer demand is still release-driven, often centered on distillation and benchmark gaps. But its leading suppliers are broadening the production mix to include expert-authored tasks, human-in-the-loop pipelines, RL environments, and real workflows. The next test is whether this research leverage becomes recurring access to real workflows, vertical applications, or proprietary models.
>
> 5. Consolidation is coming.
> Every adjacent player is expanding into this market while dozens of small vendors chase the same few buyers. That points to significant M&A within one to two years; Mercor's acquisition of Deeptune is an early example. One lab changing its research agenda can erase a major contract, giving smaller suppliers a reason to sell.
>
> 6. A durable data company must become something else.
> A research-heavy project can produce revenue quickly. The harder part comes next: labor stops scaling, the asset ages, and the customer list remains a handful of labs. The better teams move before that happens—into enterprise customers, their own models, or software built from the quality and simulation systems they first developed for delivery.
>
> ## 02 The Growth, and the Problem
>
> At [Etna Labs](https://etnalabs.ai/), we invest in foundation-model companies while hunting for adjacent markets that can outgrow them. Data is one of the few that has come close. Its growth is a direct readout of competition at the model layer.
>
> Consider the reported growth of the leading suppliers:
>
> - Mercor: from a $500 million reported run rate in H2 2025 to $2 billion by mid-2026.
>
> - Handshake: $550 million in January 2026, $1 billion by April.
>
> - Fleet: ~$1 million in October 2025, $63 million by April 2026, reportedly more than doubled since.
>
> Through Q1 2026, the data leaders grew about as fast as the frontier labs; lab ARR re-accelerated in Q2, so data leaders ended the half slightly behind. Still, almost no other growth-stage category keeps this pace. The closest comparison is inference: Fireworks has publicly reported ARR rising from just over $300 million to more than $1 billion this year.
>
> Yet private markets value data companies below labs and inference platforms. The discount encodes three doubts: TAM, customer concentration, revenue predictability. Every scaled data company now faces the same question: what does this become once "we sell data to frontier labs" is not enough?
>
> ## 03 What Frontier Labs Are Actually Buying
>
> High-quality supply is the constraint
>
> Narrowly defined, several leading US labs spend at or near $1 billion a year on external data; some spend considerably more. Anthropic reportedly allocated roughly [$1 billion to RL data in 2025.](https://www.theinformation.com/articles/anthropic-openai-developing-ai-co-workers?utm_campaign=Editorial&utm_content=Article&utm_medium=organic_social&utm_source=linkedin&rc=zuyu47) The buyer pool extends to neolabs, multimodal companies, and Chinese labs. Count internal data teams and the compute to produce and validate training data, and true data-related spend per lab runs far higher. Across every conversation, the binding constraint was qualified supply, not money.
>
> Buyers are not equally sophisticated
>
> The most research-intensive buyers demand research service and are likelier to require exclusivity; less research-intensive labs buy off the shelf more often. The follow-on dynamic matters more than any ranking: once a leading lab starts buying a category and no exclusivity blocks resale, similar supply reaches chasing labs' procurement lists within months. Labs with thin internal teams go further and buy the whole package: environment, training recipe, rollouts, compute.
>
> The catalog rewrites itself every year
>
> The dominant format changes every one to two years: RLHF to expert SFT to RL environments to, now, real-world company data. Inside those cycles, themes rotate in months. One buyer moved from computer use to coding to auto-research. Meanwhile the middle of the stack is commoditizing: rollouts run on open frameworks like Harbor, and low-quality processing with no research feedback loop loses value first.
>
> Demand will persist; each new category maps to a capability the next model is trying to acquire.
>
> The underwriting questions are not "how big is the contract", but:
>
> - Can the signal update continuously?
>
> - Do the rights permit training, resale, and reuse across customers?
>
> - Does quality judgment improve with every delivery?
>
> - When the boundary moves, does a one-off dataset become an evergreen pipeline?
>
> ## 04 The Enterprise Side Is Earlier, and Structurally Different
>
> Most enterprise evaluation or data purchases sit below $1 million. ROI is hard to quantify, so the budgets are first to be cut. Each deployment needs consulting and customization that resist productization. And enterprises with applied-ML leaders default to build-versus-buy; few trust a small startup with a critical learning loop.
>
> Three buyer groups matter today:
>
> - AI-native applications with lab teams. Companies like Decagon, Sierra, and Ramp buy data, evaluation, and post-training. Ramp's architecture is the pattern to watch: a frontier model for planning, a smaller self-trained model for retrieval. Every such split creates standing demand for task-specific evaluation and training data.
>
> - Regulated industries with expensive experts. Finance, legal, and healthcare are among the few markets where a professional's time covers an embedded FDE team. The highest-value RLaaS contracts concentrate here.
>
> - Operational businesses with clean KPIs. DoorDash can measure delivery-fee optimization directly; it pilots across vendors, acquired the RLaaS company Metis, and keeps exploring internal builds.
>
> Why do enterprises want their own intelligence? Partly defense: the deeper Claude or Codex embeds in operations, the more internal judgment flows through an external system. Partly economics: at fixed performance, a specialized model is materially cheaper and faster. Three forces push the market along: self-service post-training (Tinker, Prime Intellect, CGFT, etc.) cutting customization cost, labs entering enterprise services and educating buyers, and lab competition letting enterprises stay model-agnostic.
>
> ## 05 China's Edge Is Research Leverage, Not Cheap Labor
>
> Our first China thesis overweighted cheap collection and physical-world data. We were wrong about the wedge. The real advantage is researchers leaving Qwen, Kimi, ByteDance Seed, and other model teams to rebuild the data loop outside the lab.
>
> Inside a lab, a data request passes through product, procurement, vendors, labelers, and training researchers; when the model does not improve, no one owns the failure, and data talent is paid below algorithm and infra talent. A spinout puts the entire loop inside one team. This is an organizational unbundling of the model lab, not more labeling capacity.
>
> Unipat: "data is approximately the model"
>
> UniPat’s team, drawn mainly from Qwen and Kimi, has been operating for less than a year and says it has served most major Chinese labs. It is already profitable, with net margins closer to software than to labeling.
>
> Close to half of its revenue now comes from expert-generated or human-in-the-loop data. The team treats human versus synthetic as an engineering choice: if production takes ten manual steps, it automates only those that can be replaced without lowering final quality. [ExpertEval](https://unipat.ai/blog/ExpertEval) uses practicing professionals across finance, law, and medicine; [BabyVision](https://unipat.ai/blog/BabyVision) and SciVision are human-authored; Terminal-Bench-Science combines STEM PhDs with model assistance.
>
> UniPat’s advantage is the closed loop around the data. The same researcher can design the task, build the verifier, train the model, inspect its failures, and redesign the next batch. UniPat says this allows validated coding data to sell for five to ten times competing offerings. Chinese labs still buy around releases and benchmarks; U.S. labs pay more for novel tasks and unsolved failure modes. The company is now applying the same process across coding, cowork, AI4Science, and AI4AI.
>
> Humanlaya: data without evaluation is inventory
>
> Humanlaya supplies data and evaluation to Chinese labs and worked with xbench on OneMillion-Bench. Its lesson is the one Unipat's growth can obscure: clean, diverse data does not necessarily improve a model. Quality is only observable through training, yet reorders and rework are often the supplier's only feedback.
>
> Its deeper diagnosis is train-serve mismatch: Chinese teams optimize against a benchmark and expand outward; Humanlaya would start from the production distribution and use benchmarks as diagnostics. A well-built harness for distilling frontier models can lift a customer's model quickly. Distillation can close the gap to the teacher, but rarely creates signal beyond the teacher’s distribution. The scarcer signal comes from real economic work.
>
> The wedge and the endgame
>
> Chinese demand remains release-driven: distillation and benchmark gains still account for much of the market. What is changing is the supplier. The strongest teams now combine expert authoring, model-assisted generation, environments, training, and evaluation.
>
> Over time, applications will generate the most valuable data themselves. A coding product sees which suggestions users accept, which edits they reverse, and whether the work was completed. An outside vendor sees none of this unless it sits inside the workflow. UniPat is moving downstream into real work; Humanlaya is making a similar bet on enterprise workflows.
>
> We would ask three questions: Can the same team turn task design into measurable model gains? Do customers reorder or share training feedback? And where will recurring proprietary data come from after the current procurement cycle ends?
>
> Selling to labs is the wedge. A durable company follows the model into real work.
>
> ## 06 Why Real-World Data Is the Next Battleground
>
> Real-world data is generated by economic activity rather than produced for training. The useful form records the whole trajectory, intent to artifact: a private codebase with its issues and revisions, a browser session, Slack and ERP activity, a full clinical diagnostic sequence. The asset is the process, not the document.
>
> The clearest framework here comes from [Sean Cai](https://x.com/SeanZCai), founder of Standard Data, who laid it out in his [AI Engineer conference talk:](https://www.youtube.com/watch?v=ZyIoTOAbRfs) a taxonomy of Type 1 and Type 2 data. We adopt his taxonomy below and extend it half a step. He starts with two observations.
>
> Type 2 data is commissioned: experts perform a task designed for training or evaluation. Type 1 data is recorded: it records work that would have happened anyway.
>
> First, the internet preserved outputs, not work. The public internet holds code, reports, and documents: finished artifacts. It rarely holds how someone interpreted an ambiguous request, chose a tool, made a mistake, recovered, and decided the work was done. Software is the great exception: GitHub accidentally recorded how programmers work, not just what they produce, which is much of why coding became the first knowledge-work domain where models are genuinely useful. Most industries have no GitHub. Permissioned access to real work processes is becoming a scarce training asset.
>
> Second, performed data breaks down as tasks get longer. In Sean's taxonomy, Type 2 data is performed: experts follow a spec inside a constructed setting. Expert labeling, RLHF, and RL environments are all versions of it, each generation more realistic. Type 1 data is recorded: observed from naturally occurring work, at the limit a session replay of every click and decision.
>
> For short, verifiable tasks the distinction barely matters, which is why coding and math remain productive Type 2 domains. At longer horizons, performed data fails in three places:
>
> - The reward must be invented. Sparse final rewards force designers to insert intermediate ones, and every human-designed reward is a surface for hacking. Real work ships with observable outcomes: the customer signed or did not, the bug was fixed or not.
>
> - The distribution goes artificial. Experts performing tasks reproduce the work they imagine, not the work itself. Missing information, broken tools, interruptions, and rework are the first details cut from a constructed environment and the exact behaviors an agent needs.
>
> - Humans can no longer author the frontier. As models pass the median practitioner, tasks that ordinary programmers can design get absorbed fast; demand shifts to database internals, Kubernetes, complex distributed systems.
>
> Real-world data is not a free lunch either. Outcomes depend on external variables, and success often cannot be attributed to an action taken hundreds of steps earlier. Experts, graders, and training runs are still needed to turn a raw trajectory into signal. Read the two types as a spectrum: Type 2 takes a model from "cannot do the task" to "can do a simplified version"; Type 1 moves it toward the actual distribution of work. The most practical near-term product, our half-step extension, is Type 1.5: source tasks, failure modes, and process structure from real work, then use experts to reconstruct intent, shape rewards, build layered quality control, and design against reward hacking. Raw trajectories are noisy and difficult to turn into tasks, rewards, and verifiers; static datasets also age quickly. The valuable asset is recurring access to fresh workflows, plus the synthetic machinery that makes them trainable.
>
> Four sourcing models are emerging:
>
> 1. Buy the remains of a company. A failed startup's Slack, email, Drive, and workflow history can be bought as a package and rebuilt into a high-fidelity RL gym; liquidation channels already aggregate the supply.
>
> 2. Buy from application companies that can legally commercialize agent traces, user workflows, and failure modes.
>
> 3. Monetize surplus enterprise post-training data that companies collect but cannot use.
>
> 4. Co-build with a lab, trading revenue share or a joint evaluation for continuing access to real user tasks.
>
> Every path runs through the same gauntlet: consent, rights, exclusivity, privacy, leakage, and whether the buyer can train and resell across customers. The rights may matter more than the data.
>
> ## 07 Four Businesses Hiding Inside "AI Data"
>
> Useful market maps exist: Deedy Das at Menlo organizes [suppliers by estimated ARR](https://x.com/deedydas/status/2076124392711696455/photo/1); Sapphire maps [environment companies by domain](https://sapphireventures.com/blog/reinforcement-learning-environments-ai-agents/?utm_campaign=301750979-Reinforcement%20Learning:%20Learning%20by%20Doing&utm_source=linkedin&utm_medium=social&utm_term=Adam%20linkedin&utm_content=Adam%20linkedin).
>
> Another influential one is [Pavlov's List](https://pavlovslist.com/), [Chris Barber](https://x.com/chrisbarber)'s directory of RL environment startups, which tracks teams, domains, and public samples across the category.
>
> *Pavlov's List—Chris Barber's directory of RL environment startups:*
> ![[etna-ai-data-004.jpg]]
>
> Maps organize the companies. The economics underneath are what differ.
>
> Human Data at Scale
>
> The first tier: Surge, Mercor, Scale (share under pressure), and Handshake, each reportedly past $1 billion in run rate. micro1 and AfterQuery lead the next tier. Together the largest platforms capture over 60% of labs' external budgets, per our interviews.
>
> The bull case for them is operational: research programs need thousands of people in parallel, and labs will not internalize that soon. Skeptics say scale of quantity does not automatically improve quality. But the leaders have real advantages: Mercor's ~five million domain experts expand supply through referrals, and a large network tells you who can judge a niche task, not merely who has the resume.
>
> The bear case is just as legible: concentrated revenue, non-recurring contracts, margins capped by expert labor. All the leaders are pushing into real-world data, enterprise, and adjacent infrastructure; our conversations (including with Boeing) suggest traditional enterprises will take years to become a second engine, slowed by education, security review, workflow customization, and procurement.
>
> Our Investment view. Demand is strong and the leaders are visible, but at ~10x reported run rate the price already assumes near-perfect execution across future cycles. Downside is partially protected by acquirer interest from labs and compute companies. The upside is the harder case: the same buyers that support the floor tend to pay 3x run rate, so returns depend on revenue outrunning severe multiple compression rather than on the multiple holding.
>
> Company Spotlight:
>
> Handshake
>
> > Positioning: The talent network for the AI economy.
>
> > Team: Garrett Lord, Co-founder & CEO; co-founded with Ben Christensen and Scott Ringwelski.
>
> > Fundraising History: ~$434M total. $200M Series F led by Coatue and Valiant Peregrine (2022) at a $3.5B valuation.
>
> > Why we like this company: Handshake turned its network of students, PhDs and professionals into expert supply for frontier-model training and evaluation. It shows how distribution, not annotation software, can become the core data advantage.
>
> AfterQuery
>
> > Positioning: An applied research lab building expert data and RL environments for frontier models.
>
> > Team: Carlos Georgescu and Spencer Mateega, Co-founders. Former Meta and Google engineers with backgrounds spanning Citadel Securities, Silver Lake, Morgan Stanley, UBC and Penn.
>
> > Fundraising History: $30M Series A led by Altos Ventures (April 2026) at a $300M valuation; YC W25.
>
> > Why we like this company: AfterQuery exposes capability gaps through benchmarks, then builds the expert data and environments needed to close them. Its work in finance, spreadsheets and software agents moves it closer to model development than a traditional data vendor.
>
> RL Environments and Evaluations
>
> An RL environment is a driving simulator for agents: a simulated workplace plus a grader. Picture a working replica of Salesforce or SAP loaded with tasks, tools, and an automated check on completion. The lab receives a Docker container, plugs in an agent, and runs thousands of rollouts. The model practices doing work inside software instead of recalling facts.
>
> As tasks stretch from a dozen steps to hundreds, replicating the interface stops being the hard part. Context writing and memory attribution become the bottleneck: what enters long-term context, how it is compressed, when it is retrieved, while the verdict lands hundreds of actions later. Real trajectories expose the problem; they do not solve credit assignments. Long horizons still need trajectory-level critics and finer verifiers.
>
> Fleet leads on [reported revenue](https://x.com/ArfurRock/status/2042048795253395563): a run rate reportedly up ~50x in H1 2026 to $63 million, possibly above $150 million now. We also heard strong customer references for Mechanize (research-first, out of Epoch AI, software and coding), Datacurve (coding and agentic tasks), Matrices (computer-use environments), Patronus (coding, computer-use, and enterprise knowledge-work environments; early work in simulation and digital world models), and Irregular (cybersecurity evaluations and environments).
>
> Environment companies get one advantage human-data platforms do not: proximity to the frontier. They operate as forward-deployed research arms, see where models fail before the market does, and a small research-heavy team can carry attractive margins. Most call themselves research labs and plan to convert customer access into their own model or vertical application.
>
> The structural problems start with the familiar ones, concentrated buyers and intense competition, plus a few of the category's own. An environment is often a one-time delivery with a ~six-month half-life; the same customer rarely buys the same environment twice. Delivery is throttled by skilled human labor. Sophisticated labs are building internal harnesses and handing vendors a spec to implement in a container. Harbor, BrowserGym, and OpenEnv are standardizing interfaces. Buyers increasingly want raw traces. Programmatic generation threatens the manual work.
>
> Our investment view. We would pass on any company limited to hand-building environments; public markets will not pay a software multiple for it. The leaders know this and are moving three ways: grader and verifier infrastructure, models and applications for specific workflows, and adjacent agent infrastructure like sandboxes. Leading players are betting on simulation to mass-produce environments; if it works, the labor constraint loosens. Simulation may evolve beyond generating more hand-authored tasks. Patronus is exploring agentic world modeling and unsupervised environment design (UED), where environments adapt around a model’s current learning frontier. If this works, the reusable asset is the world generator and evaluation loop, not any single environment.
>
> Company Spotlight:
>
> Fleet AI
>
> > Positioning: We Build Worlds for Models.
>
> > Team: Nicolai Ouporov, Founder & CEO. Former founding engineer at Respell; previously researched embodied-AI and robotics simulation at Stanford and Columbia.
>
> > Fundraising History: Backed by Sequoia Capital, Menlo Ventures, Bain Capital Ventures, and SV Angel; financing details have not been publicly disclosed.
>
> > Why we like this company: Fleet combines benchmarks, training recipes, and high-fidelity environments in one post-training loop. Its upside lies in turning bespoke RL gyms into reusable simulation and oversight infrastructure across knowledge work
>
> Patronus AI
>
> > Positioning: Simulating the World’s Intelligence.
>
> > Team: Anand Kannappan, Co-founder & CEO. Ex Applied ML at Meta Reality Labs; UChicago. Rebecca Qian, Co-founder & CTO. Ex Meta AI (FAIR).
>
> > Fundraising History: $70M total. $50M Series B led by Greenfield Partners (June 2026), with Notable Capital, Lightspeed, Datadog, and Samsung; $17M Series A led by Notable Capital (2024); seed backed by Lightspeed (2023).
>
> > Why we like this company: Patronus started in evals and is best known for some of the earliest open-source benchmarks and evaluation methods. It is now extending that work into coding, computer-use, and enterprise knowledge-work environments, including digital world models.
>
> RLaaS and Enterprise Learning Loops
>
> Applied Compute currently leads the category: founded by ex-OpenAI researchers, reported valuation from ~$500 million to $1.3 billion in three months. The next group (Veris, The LLM Data Company, Plato, Theta) remains consulting-heavy; Trajectory takes a self-service approach with customers like Harvey and Clay, though it remains at an earlier scale. Tinker, Prime Intellect, and CGFT are rapidly commoditizing the training layer; Prime Intellect's compute-plus-talent pairing is the credible path from tooling to the full stack.
>
> Three things make RLaaS attractive.
>
> First, it is the only category here that does not depend entirely on labs. The bargaining positions are reversed: labs can train models but do not own customer workflows; enterprises own the workflows but lack the training infrastructure. Some suppliers serve both sides of the market, transforming an enterprise’s data and later selling a permitted version to a lab. The model can work economically, but it carries substantial trust and data-rights risk.
>
> Second, the production-agent learning loop draws from a budget separate from any lab’s training budget. A live agent needs evaluation, monitoring, feedback, and repair, and the surrounding system supports recurring revenue even when weights never change.
>
> Third, data efficiency is improving. Applied Compute and Mercor describe cases where under 1,000 high-quality examples produced impressive gains. Lower data requirements cut delivery cost and make smaller contracts economically viable.
>
> Delivery is where the thesis weakens. Much of the category sells reinforcement learning and delivers systems integration; every project is custom, and the tenth customer deploys no faster than the first. Some customers use a supplier to learn the process, then build internally. Self-service tools erode differentiation. And reselling customer data creates a latent trust risk across the category.
>
> Our investment view. The most surprising long-term winner may not be a standalone RLaaS company at all. A model lab or inference platform could bundle fine-tuning, post-training compute, and production inference into one enterprise product. Thinking Machines Lab is positioned for exactly this: frontier talent, open-model ambitions, Tinker as the RLaaS product; an aggressive move into rented compute and inference completes the offering. Fireworks, Baseten, and Together could buy their way into the high end. Among standalones there is no clear winner; on our references, Trajectory and Prime Intellect stand out for infrastructure and talent.
>
> Company Spotlight:
>
> Thinking Machines Lab
>
> > Positioning: Making frontier AI more understandable, customizable and collaborative.
>
> > Team: Mira Murati, Founder & CEO, ex OpenAI CTO. John Schulman, Co-founder & Chief Scientist, OpenAI co-founder and ex Anthropic.
>
> > Fundraising History: $2B seed led by a16z (July 2025) at a $12B post-money valuation, with NVIDIA, AMD, Cisco and Accel.
>
> > Why we like this company: Thinking Machines is building around customization rather than a closed, one-size-fits-all model. Tinker and Inkling make it an important test of whether post-training becomes a primary axis of frontier-model competition.
>
> Trajectory
>
> > Positioning: The platform for continual learning.
>
> > Team: Ronak Malde, Co-founder & CEO; Michael Elabd, Co-founder & CTO; Arjun Karanam, Co-founder. Former researchers from Google DeepMind, Apple, OpenAI and Meta.
>
> > Fundraising History:  $55M total. Most recently, a reported $40M round led by Sequoia (August 2026) at a $300M valuation, following a $15M seed led by Conviction two months earlier.
>
> > Why we like this company: Trajectory is the clearest expression of “the product is the data.” It turns user edits, retries and outcomes into training signals, allowing an AI product to become harder to copy every time it is used.
>
> Real-World Data Rights and Pipelines
>
> The newest wave already has a division of labor: liquidation and acquisition specialists (Sunset and peers) buying rights from failed companies and negotiating extraction from operating ones; vertical pipelines locking up raw supply, cleaning it, and selling it compliant; asset-light brokers reselling upstream supply for a commission.
>
> Against hand-built environments, the economics can be better on three axes. The same supply can be sold more than once: non-exclusive agreements let one processed source serve many buyers. Margins can land between human data and environments: sourcing, rights, and QC are real work but need not scale with expert hours. And early supply agreements can create defensibility: exclusive rights convert first-mover advantage into a standing constraint on competitors.
>
> Our investment view. We're excited about this category, though demand emerged only six months ago. Standards for data rights and formats are still evolving, and the scaled human-data platforms are investing aggressively into the same category. Early demand is encouraging, but we would underwrite the durability of access, not the size of the first dataset.
>
> Company Spotlight:
>
> Protege
>
> > Positioning: The real-world data layer for AI development.
>
> > Team: Bobby Samuels, Co-founder & CEO; Travis May, Co-founder & Chairman, former CEO of Datavant and LiveRamp; Engy Ziedan, CSO; Richard Ho, CTO.
>
> > Fundraising History: $65M total. $30M Series A extension led by a16z (January 2026); $25M Series A led by Footwork (2025).
>
> > Why we like this company: Protege focuses on the data the open internet cannot supply: proprietary, rights-cleared healthcare, audio, media and motion-capture data. Its advantage lies in the network and infrastructure required to make sensitive datasets usable by AI companies.
>
> San Francisco Data
>
> > Positioning: The marketplace for proprietary AI data.
>
> > Team: Brandon Guo, Co-founder & CEO. Former Strategic Projects Lead for Code at Mercor. Faiz Siddiqi, Co-founder & CTO. Former MTS on Mercor’s Code team.
>
> > Why we like this company: San Francisco Data treats enterprise exhaust—codebases, internal messages, and operational records—as a licensable asset class. The company not only brokers datasets unavailable elsewhere, but also multiplies the value of enterprise data through augmentation techniques grounded in post-training research.
>
> ## 08 What Kind of Team Can Survive the Category Cycle?
>
> AI data is a flow business, not a stock business. The category keeps changing, and a dataset does not compound the way a codebase or a network does. Four assets do compound:
>
> 1. Researcher trust. Buyers return to teams that can discuss model failures directly, without routing every request through sales.
>
> 2. Renewable supply. An ongoing source of expert work or real-world trajectories, with rights that survive demand shifts.
>
> 3. A quality system tested by training outcomes. Graders, verifiers, and reviewer selection that improve because the supplier sees actual training results, not because a checklist passed.
>
> 4. Migration speed. Detect the new theme, decide which current revenue is about to depreciate, and scale the next product before the market has a name.
>
> The leaders’ origins still shape their strengths. Surge put ML, platform integrity, and data operations in the founding team; research and ops that grew up together cannot be bolted on later. Mechanize, out of Epoch AI, brings native judgment about capability boundaries and task design; its ceiling is turning research taste into reliable production. Patronus, out of Meta Reality Labs and FAIR, knows why a grader is wrong; it must prove it can scale production and distribution. Mercor and Handshake began with talent networks and are buying the technical depth they lack (Deeptune bought by Mercor; Cleanlab and Taro by Handshake).
>
> The strongest CEOs share five traits. They discuss quality directly with researchers. They will kill revenue that is still growing but about to depreciate. They know what to build (research judgment, data rights, trust) versus buy (generic software, compute, baseline ops). They make research and operations share ownership of model improvement and customer satisfaction. And they maintain neutrality across competing labs: a multi-lab supplier lives on data rights, information barriers, and customer trust, and weakness in any of the three directly shrinks its addressable market.
>
> We underwrite two variables together: position in the current category, and speed of migration to the next. The CEOs of Surge, Mercor, and micro1 fit the pattern: they move before the new market has a settled name.
>
> Beyond that, every data company needs a house view on what improves a model and how to measure it. The rest depends on the starting point: marketplace operations and quality-ranking for human data; sourcing, rights, and domain QC for real-world data; task design and verifier engineering for environments; RL judgment and distributed systems for continual learning; workflow translation and procurement survival for enterprise FDE.
>
> ## 09 The Endgame: TAM Expansion and M&A
>
> Market structure will be uneven. Human data consolidates around three or four platforms. Real-world data might stay fragmented by industry and source, with finance, healthcare, and agentic coding each supporting one or two unicorn-scale companies. RL environments could consolidate quickly if programmatic simulation works. RLaaS stays fragmented because FDE delivery resists standardization; only a few become systems of record.
>
> Silicon Valley does not view a pure data business as an attractive IPO candidate, and scale alone does not solve customer concentration or contract durability. Any company reaching public markets will carry real enterprise revenue and a product beyond data delivery. For everyone else, M&A is the natural exit, with three buyer groups:
>
> - Frontier labs. Meta's investment in Scale AI shows why a lab wants control over critical supply, talent, and infrastructure; others may buy exclusive rights, evaluation systems, or domain expertise.
>
> - NVIDIA, neoclouds, and inference platforms. Compute customers also need data, evaluation, post-training, and deployment; owning those layers lifts utilization and locks in the relationship. Baseten's December 2025 acquisition of Parsed is the early precedent.
>
> - Owners of production data and enterprise workflows. Datadog, Snowflake, Databricks, ServiceNow, and Salesforce sit next to production data and systems of record, with every reason to acquire continual-learning, evaluation, and simulation capabilities. Palantir is the public-market template: forward-deployed work compounds when it repeatedly becomes product.
>
> ## 10 Conclusion: Data Is a Flow Business
>
> Frontier models will keep needing more training signal. The harder investment question is who keeps the value when the required signal changes.
>
> Mercor, Handshake, and Fleet show how quickly a supplier can grow when a new capability creates an urgent shortage. They also show why the first contract is not the moat: each shortage eventually passes.
>
> A dataset loses value once the model learns the capability, the lab brings the workflow in-house, or an open framework standardizes the work. What remains can still be valuable: the expert network, renewable data rights, verifiers, simulators, or a live feedback loop from production.
>
> The Chinese suppliers in this article make the transition especially visible. Their research teams can fill gaps that labs struggle to handle internally and sell the result into higher-priced US demand. That is a strong entry point, but it does not answer who owns the next generation of signal. As more useful data comes from people doing real work, the advantage shifts toward the company that owns the workflow, model, or application.
>
> For us, migration speed belongs in the underwriting alongside revenue and customer concentration. A supplier may be winning the current category and still be late to the next one.
>
> ## Acknowledgements
>
> We are grateful to [Brandon Guo](https://x.com/brandonguo), [Chris Barber](https://x.com/chrisbarber), and [Anand Kannappan](https://x.com/anandnk24) for reading an earlier draft and challenging parts of our framing. We also thank [UniPat](https://x.com/UniPat_AI) and [Humanlaya](https://x.com/Humanlayadata), for sharing firsthand perspectives on how AI data is built, evaluated, and purchased in China. Their input sharpened this piece; the conclusions and any errors are ours.
