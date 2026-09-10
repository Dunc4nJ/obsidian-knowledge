---
created: 2026-09-11
description: Viv distils four data-generation and RL-environment trends from the DeepSeek-V4.1-Flash and Kimi K3 reports; checked against the DeepSeek report verbatim in this vault, two of the four are documented almost literally, the difficulty ladder and the knowledge graph are not DeepSeek's at all, and Viv's own follow-up reply concedes both screenshots are Kimi.
source: https://x.com/vtrivedy10/status/2098081434015535254
original_title: "How we do Data Generation + RL Environment creation are the most interesting sections from recent Open Models releases"
type: tweet
---

## Key Takeaways

**Epistemic status up front.** This is a 216-word practitioner summary of two model reports, with no data of its own, no section numbers, and no link to the Kimi report it is actually screenshotting. Its value here is as a framing device — four named axes along which frontier data pipelines can be compared — not as evidence. The vault holds the DeepSeek primary source at full length in [[DeepSeek-V4.1-Flash cuts global KV cache to 890 bytes per token - a quarter of V4-Flash and 437x below V1 - by stacking cross-layer CSA2 reuse, FP4 caching, and a causal encoder-decoder]], whose Original Content callout carries §4.1, §5.1.1, §5.1.2, §5.1.3 and §5.1.4 verbatim, so every one of Viv's four trends can be checked rather than relayed. Two hold up, two do not.

**Trend 1, "Model Council + Trace Mining", is documented — but DeepSeek has one inspector, not a council.** §5.1.1's coding pipeline is almost a literal match for the second half: "multiple distinct agents attempt the task, and an independent quality-inspection agent reviews the environment together with the solving agents' trajectories, checking for environment issues, factual errors, mismatches between evaluation points and task descriptions, and hackability risks. If the inspection does not pass, a repair agent fixes all identified errors." Trace mining is explicit too — "Whenever a task is used in a new RL run, the resulting trajectories provide fresh evidence for quality re-auditing." Two things Viv adds that the report does not say: the solvers are "multiple distinct agents," not agents of *different intelligence levels*, and there is exactly one independent inspector, so "council" is the wrong shape. A genuine council of debating judges calibrated against a human golden set is [[Decagon's failure-informed data flywheel promotes a failure hypothesis into a sampling dimension only when a classifier and a measured accuracy gap validate it]]'s mechanism, not DeepSeek's — Viv has grafted Decagon's architecture onto DeepSeek's inspector. The trace-mining half is the better-attested claim generally: [[Databricks traces every MCP call and finds seven tool bugs burning 1.2 million dollars a year because agents retry silently instead of failing loudly]] mines production traces for tool defects, [[HALO uses an RLM to mine harness-shaped failures from agent execution traces and lift benchmarks 10-16 percentage points]] and [[Self-Harness lets a fixed LLM rewrite its own agent harness from clustered failure traces, lifting Terminal-Bench held-out pass rates up to 21 points]] both cluster failure traces into repairs, and [[traces and evals form the core of continuous harness learning in agent systems]] is Viv's own earlier statement of the same loop.

**Trend 2, progressively increasing difficulty, is where Viv extrapolates hardest.** DeepSeek does treat difficulty as a first-class controllable: it is one of the two dimensions each `(problem, environment, verification system)` triplet is scored on, those scores are "used as reward signals" to train the model to construct better tasks, the repair agent "adjusts evaluation points that are too easy or too difficult," and the pipeline's stated output is data "controllable in length and difficulty." But *controllable* is not *progressive*. There is no curriculum, no tier ladder, no pass-rate target anywhere in §5.1.1 — and none of Viv's four specific levers (bigger data, information split across sources requiring search, multi-modal requirements, cross-domain reasoning) appear in the DeepSeek report at all. Every one of them is visible in the Kimi Figure 9 pipeline Viv screenshotted. The pass-rate-banded ladder Viv is reaching for is [[Prime Intellect general-agent self-evolves a tool-use corpus through a synthesizer-solver game gated on empirical pass-rate bands]], where a solver LLM gates each difficulty tier against a target pass-rate band, and the curriculum-with-adversary version is Viv's own [[auto-research as a multi-agent GAN with curriculum learning prevents reward hacking]]. A reader reply nails the gap better than the post does: difficulty knobs "can also flatten the signal, since a task the policy never solves teaches about as little as one it always solves, so difficulty has to follow measured success rate."

**Trend 3 splits cleanly: the knowledge graph is Kimi's, the world structure DeepSeek actually builds is a mocked tool surface.** DeepSeek's report contains no knowledge graph and no event architecture. Its answer to "beyond one-shot generation" is interface reconstruction from observed traffic — from the interfaces seen in returned employee and partner interaction data it builds "a large set of mocked tools that reproduce the interfaces and behaviors of real-world tools and systems, including their input formats, output structures, API schemas, and behavioral constraints," then replays real failures against them. That is durable world structure, but it is a mock of a real world rather than a generated one. The knowledge graph is Kimi §4.2.2 alone — "a self-evolving, hierarchically organized knowledge graph that agents continuously expand through web-scale exploration" — which is a stronger claim than Viv's phrasing and is visible only in the image, never named as Kimi in the post body. "Event based architectures" appears in neither the DeepSeek report nor either screenshot; it is unsourced. Graph-as-substrate arguments the vault does hold: [[MotherDuck's Simon Spati splits semantic layer from context layer by what compiles to SQL, and argues sophistication is a cost not a default]] on ontology as the layer agents reason over, and [[Paradegma treats the experiment-DAG as the atomic unit of science giving agents an MCP organization layer beneath all autoresearch frameworks]] on a DAG as the atomic generated artifact.

**Trend 4, per-domain data agents with domain-specific verifiers, is the best-supported of the four — except the "skills" clause.** §5.1.1 is structurally organized around it: "dedicated training environment production pipelines for two core scenarios: general agents and coding agents," with genuinely different verifier logic (fail-to-pass and pass-to-pass evaluation points for code; mocked-tool replay for general agents), and the coding pipeline is "carried out collaboratively by multiple specialized agents" — feasibility, setup, solvers, quality inspection, repair, five named roles. Viv's "computer use vs SWE" is close in spirit and wrong in letter: DeepSeek's split is general-agent vs coding-agent, and computer use appears only in §4.1 as pretraining trajectory data. The "tips encoded in skills" half has no basis in the DeepSeek report, which never mentions skills; Kimi §4.2.1 lists "skills" as one composable module of its white-box harness alongside tool interfaces, system prompts, context management, memories and subagents — a harness component the environment instantiates, not a store of verifier tips. Skills as accumulated failure-derived procedure is real, but the vault's evidence for it is [[EvoSkill discovers reusable agent skills through iterative failure analysis outperforming static prompts and transferring zero-shot]] and [[skills are living folders not markdown files and building them is the new developer setup]], not either model report.

**The Kimi attribution is the post's best-evidenced half and its least legible one.** Viv credits "DeepSeek & Kimi" while quote-tweeting only DeepSeek, and the correction arrives in a self-reply fifteen minutes later: "above screenshots are Kimi tech report, same thing in DeepSeek!" So the two images that look like they are illustrating the quoted DeepSeek announcement are in fact Kimi K3 §4.2 and §4.2.2 — the visual evidence backs the *unlinked* half. The vault cannot corroborate that half independently: [[Harvey's Tenet post-trains Kimi K3 with GSPO in rubric-graded legal environments, doubling LAB hold-out completions while co-optimizing cost via reward shaping]] and [[agentic RL training converges on outcome rewards inside production harnesses across Kimi Cursor and Chroma]] both concern K3 as a *base* for downstream RL, not the K3 report's own data-synthesis sections, so the Kimi screenshots here are currently the only primary evidence in the vault for Kimi's knowledge-graph task synthesis. "Same thing in DeepSeek" is exactly the assertion the checks above find to be two-for-four.

**The closing line is the durable part, and it is a restatement of the folder's thesis rather than a finding.** "Every team will benefit from having data research teams that turn every interaction from their agent into a usable artifact for hill climbing" is [[Daniel Ching's On Data I argues the post-training datapoint has become an executable environment not a corpus row]] compressed to a sentence, with the verification burden of [[Daniel Ching's On Data II makes environment quality a verification problem - prompt-verifier bijectivity, realism, and ex post trace analysis]] left implicit — and DeepSeek's own summary line puts it more sharply than Viv does: "the marginal return of engineering the data and environment pipeline substantially exceeds that of algorithmic novelty in post-training." The organizational claim is the interesting residue, and it is the one thing here neither report actually says. It sits alongside [[RL environments are the new unit of progress in agentic AI training]], [[Sergio Paniego traces RL environments from OpenAI Universe to OpenEnv - the idea barely changed while five missing pieces arrived separately]], [[rl environment creation is becoming a distributed marketplace that could 10x cost efficiency over contracting firms]] on who does this work, and [[Mercor's SkyRL recipe post-trains a 397B on 1928 expert tasks for 70 percent relative Pass@1 - and spends Steps 1-3 de-risking before any real compute]] on what it costs to do properly.

**Note on the author.** Viv is one of this vault's most-captured writers, with ten notes almost entirely in harness engineering and evaluation — [[LangChain's Better-Harness uses eval-driven hill-climbing for agent harness improvement]], [[agent harness components can be derived from first principles by working backwards from desired agent behavior]], [[LangChain's Eval Engineering Skill builds Harbor-format evals from repo context and agent traces by interviewing the user]]. This post is a departure into training-data territory, and the tell is that the vocabulary comes with them: "hill-climbable environments" is harness-optimization language applied to a corpus, and the four trends are read as harness properties (councils, difficulty knobs, world structure, per-domain agents) rather than as dataset properties. That framing is a genuine contribution; the attribution discipline is not.

## External Resources

- [DeepSeek-V4.1-Flash announcement thread](https://x.com/deepseek_ai/status/2097930608790167907) — the quote-tweeted 6-post launch thread; 552B MoE, Causal Encoder-Decoder, 8B active on input / 16B on output, KV cache at 1/4 HBM and 1/8 SSD of the previous generation
- [DeepSeek-V4.1-Flash paper](https://github.com/deepseek-ai/DeepSeek-V4.1-Flash) — the report whose §4.1 and §5.1.1-§5.1.4 are the primary source for the checks above; captured in full in this vault
- [Viv's follow-up reply](https://x.com/Vtrivedy10/status/2098085200282407207) — "above screenshots are Kimi tech report, same thing in DeepSeek!", with a third screenshot of DeepSeek §5.1.1

## Original Content

> [!quote]- Source Material

> **@Vtrivedy10 (Viv)** — Sep 10, 2026 | 120 likes · 6 retweets · 6 replies
>
> How we do Data Generation + RL Environment creation are the most interesting sections from recent Open Models releases (DeepSeek & Kimi)
>
> some secret sauce as everyone transforms their data into hill-climbable environments
>
> + some trends:
> 1. Model Council + Trace Mining: different intelligence LLMs run on a Task, uncover errors and repair Tasks
>
> 2. Strategies for progressively increasing difficulty: more/bigger data, split information across data sources requiring search, multi-modal requirements, cross-domain reasoning
>
> 3.Building world structure beyond one-shot generation: Knowledge graphs and event based architectures allow  more complicated worlds to emerge naturally
>
> 4. Teams have extensive Data Agents per domain with specific verifier logic specific + tips encoded in skills.  Ex: computer use vs SWE
>
> every team will benefit from having data research teams that turn every interaction from their agent into a usable artifact for hill climbing
>
> your data is the gold that’ll make your agents better

*Kimi K3 report §4.2 and §4.2.1 — the highlighted claim is that the RL framework "relies heavily on rich, diverse, and robustly verifiable environments," answered with "a series of specialized white-box environments and task synthesis paradigms." §4.2.1 defines the Unified White-Box RL Environment: because a single fixed harness makes the model overfit to one tool schema, system prompt, context-management mechanism or interaction protocol, the harness is represented as configurable composable modules — tool interfaces, system prompts, context management strategies, skills, memories, subagents — which can be configured to instantiate Kimi Code, Claude Code, Codex, OpenClaw and Hermes, or entirely new harnesses, and are varied dynamically during RL training. This is the screenshot behind Viv's trend 4 "tips encoded in skills."*
![[vtrivedy10-535254-001.jpg]]

*Kimi K3 report §4.2.2, Knowledge-Graph-Guided Task Synthesis, with Figure 9. The text: task quality and diversity are determined by source materials, so Kimi builds "a self-evolving, hierarchically organized knowledge graph that agents continuously expand through web-scale exploration across knowledge-intensive and coding domains." The figure shows the full pipeline — a hub-and-spoke graph over CS/AI, Coding, Biomedicine, Humanities, Math, Physics and Chemistry expanding into finer concept nodes; related nodes sampled jointly into a Keyword Set (the worked example is "RoPE" + "GPU kernel"); that keyword set driving Material Retrieval of public internet sources (academic articles, blog posts, code repos); and finally Task Synthesis selecting one task type per instance (Coding, Knowledge, Vision, and more). This single image is the entire basis for Viv's trend 3, and it is Kimi's, not DeepSeek's — the multi-domain sampling and Vision task type are also where trend 2's "cross-domain reasoning" and "multi-modal requirements" come from.*
![[vtrivedy10-535254-002.jpg]]

> QT **@deepseek_ai (DeepSeek)** — Sep 10, 2026 | 24,427 likes · 2,720 retweets · 794 replies
>
> 🚀 Introducing DeepSeek-V4.1-Flash: smarter, faster, more efficient.
>
> 🔹 Introducing the smallest model in our new architecture family, with native visual understanding.
> 🔹 Designed for greater capability, faster inference, higher throughput, and scaling to larger models.
>
> 1/6
>
> PHOTO: https://pbs.twimg.com/media/HR1UyHiaAAAtpqw.jpg
>
> https://x.com/deepseek_ai/status/2097930608790167907

*(The quoted post's own attached image is the V4.1-Flash launch card; it belongs to the DeepSeek capture rather than this one and is not re-downloaded here — the report's figures are embedded in [[DeepSeek-V4.1-Flash cuts global KV cache to 890 bytes per token - a quarter of V4-Flash and 437x below V1 - by stacking cross-layer CSA2 reuse, FP4 caching, and a causal encoder-decoder]].)*

### Author reply

> **@Vtrivedy10 (Viv)** — Sep 10, 2026, 15 minutes later
>
> above screenshots are Kimi tech report, same thing in DeepSeek! https://t.co/izApgNsuiq

*The third screenshot, attached to the reply above. It is page 25 of the DeepSeek-V4.1-Flash report — §5.1.1 Large-Scale Agent Task Synthesis, first two paragraphs: tasks as "the fundamental fuel for agent learning," the observation that the model "is already beginning to exhibit the ability to construct its own training tasks, though this capability remains far from perfect," and the formalization of each task as a triplet (problem, environment, verification system) scored on difficulty and correctness, with those two scores "used as reward signals" to iteratively train the model to construct better tasks. The page cuts off mid-sentence at the trace-mining clause — "Whenever a task is used in a new RL run," — which is the sentence Viv's trend 1 depends on and which continues, in the full report, "the resulting trajectories provide fresh evidence for quality re-auditing."*
![[vtrivedy10-535254-003.jpg]]

### Substantive reader reply

> **@kartikb753 (kartik bhardwaj)** — Sep 10, 2026
>
> Hill climbable is doing the heavy lifting there. Those difficulty knobs can also flatten the signal, since a task the policy never solves teaches about as little as one it always solves, so difficulty has to follow measured success rate.

[Original post](https://x.com/vtrivedy10/status/2098081434015535254)
