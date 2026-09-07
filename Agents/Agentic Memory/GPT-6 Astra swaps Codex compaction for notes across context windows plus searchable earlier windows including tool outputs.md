---
created: 2026-09-07
description: GPT-6 Astra replaces repeated summarization in Codex with notes carried across context windows plus keyword-searchable earlier windows covering both messages and tool outputs, shipping experimental behind a config.toml flag with no evaluation of its own
source: https://openai.com/index/gpt-6-astra/
type: learning
---

# GPT-6 Astra swaps Codex compaction for notes across context windows plus searchable earlier windows including tool outputs

## Key Takeaways

- **Compaction is lossy and one-way; notes-plus-retrievable-history is a different data structure, not a better summarizer.** OpenAI's own framing is the admission: "Each compaction can leave out details about why a fix failed or how a component behaves." Once a summary replaces the transcript, the discarded detail is unrecoverable — a bad admission decision is permanent. Astra instead "can keep notes across context windows, preserving accumulated details without repeatedly compressing them into a single summary," and leaves earlier windows searchable so it can recover requirements or test results "even if that information wasn't captured in its notes." That second clause is the whole architecture: the note layer is allowed to be wrong because the archive is still addressable, which is exactly the summary-plus-dereferenceable-archive split argued in [[indexed experience memory compresses LLM agent context without discarding evidence by pairing summaries with a dereferenceable archive]] and the episodic-grounding escape hatch in [[The Price of Meaning prescribes coupling semantic retrieval with exact episodic grounding as the only escape from interference]]. That compaction discards recoverable signal is not new — [[structured summarization preserves more agent context than opaque compression]] measured it directly — but Astra's answer is to stop relying on the summary being right rather than to write a better one, and the note layer itself is the markdown-scratchpad convergence described in [[Hermes, Codex, and Claude Code converge on markdown plus filesystem tools because memory is a judgment problem not a data structure problem]].
- **The searchable half covers tool outputs, and that is the sharper claim than the notes.** Notes are what the model *chose* to remember; tool-call history is what actually happened, and reply-guy @chams_builds put the gap well — "those two disagree more often than you'd expect." Making prior tool outputs addressable is the same move as [[Entire's Agentic Search returns the session, transcript and prompt behind every commit - 81 of 90 on why-questions at half the tokens, and the Git-only agent confabulated a coherent wrong story 10 times out of 10]], where retrievable execution history beat an agent reconstructing the story from artifacts — and where the failure mode of *not* having it was fluent confabulation rather than a visible error. It also inverts the [[Hermes Agent prioritizes prompt caching stability by keeping hot memory tiny and pushing everything else to tool-based retrieval]] tradeoff at the harness layer instead of the prompt layer, and it makes the session itself a retrieval corpus — the direction [[agentic search agents replace vector databases for long-term memory achieving 99 percent on LongMemEval]] and [[coding agents are bottlenecked by search not coding ability]] both point at, where search quality rather than storage becomes the binding constraint.
- **Announced, not measured — and shipping behind a flag.** This is a launch page: every other capability claim on it comes with a benchmark table, and the compaction mechanism comes with none. It is "experimental," enabled in `config.toml`, and "will become the default for Astra in the coming weeks." The nearest number, the Long Context table (OpenAI MRCR v2 8-needle, 100.0% at 256K–512K and 96.3% at 512K–1M vs 91.5%/73.8% for GPT-5.6 Sol), measures needle retrieval *within* one window — it says nothing about whether notes survive across windows or whether the cross-window index returns the right span. Treat the mechanism as a design commitment with no published evaluation, distinct from the benchmarked claims around it.
- **The replies name the failure mode better than the launch page does.** @XiiBORG: searchable tool history "can resurrect dead ends. A command is not useful memory without its exit status, working directory and the later correction. Otherwise long-context recovery turns into very confident archaeology." @preyforge adds that "faithful memory can preserve a wrong assumption just as efficiently." Both are the staleness gap [[Mem0 surveys nine agent harness memory systems and finds five recurring gaps - bounded storage, keyword retrieval, harness scoping, weak staleness, and isolation]] flags across nine harnesses: an append-only index of everything the agent did has no built-in notion of which of those things was later revoked. Provenance-and-revocation is the missing primitive [[every representation is an IR - the append-only semantic ledger is memory and vectors, graphs, and context windows are views compiled from it]] argues for, and the reason [[most agent bottlenecks are actually memory problems not model or orchestration problems]] keeps being the right diagnosis.
- **Codex is converging on what other harnesses already ship, with the model trained for it.** Cursor already exposes chat history as files after summarization so the agent can search past conversations — see [[context tax compounds through cache misses bloated tools and unbudgeted output tokens]] — and Claude Code runs a cost-ordered compaction hierarchy per [[Claude Code's source reveals agent systems need infrastructure as a fourth layer beyond weights context and harness]], while [[autonomous context compression lets agents choose when to compact rather than hitting fixed token limits]] and [[structured compaction and CLAUDE.md hierarchy prevent context drift in million-token agent sessions]] cover the summarize-better branch that Astra is stepping off. McAteer's own follow-up is the differentiator worth holding onto: "the new model has been trained to navigate it" — co-designing the model with the retrieval affordance is the part a third-party harness cannot copy, which is the [[agent harnesses are the product not the model]] thesis running in reverse — the same direction [[Cursor strips guardrails and adds dynamic context as models improve, inverting the harness's job]] traces. Worth noting the security surface this enlarges: [[codex compact API uses the same prompts as open-source but encrypts summaries and is vulnerable to prompt injection that leaks them]] found the *summary* path injectable, and a searchable archive of every prior message and tool output is a strictly larger thing to leak.
- **Everything else on the page is a benchmark sweep with cost framing attached.** Terminal-Bench 4.0 57.9% (vs 37.3% Sol, 55.8% Fable 5.1), Terminal-Bench Science 0.1 64.6%, ARC-AGI-3 99.9% (vs 7.8% Sol), FrontierMath Tier 4 97.6%, ExploitBench 100.0%, SRE-Bench 88.0% single-attempt, plus two claimed zero-days found during evaluation and a Critical cybersecurity threshold under the Preparedness Framework. Note the counter-signals OpenAI publishes anyway: Humanity's Last Exam 57.2% *behind* all three Claude models, Artificial Analysis Intelligence Index 61.2 behind Fable 5.1's 65.7, and written reasoning that got *harder* to monitor than Sol's. API pricing is $10/M input, $50/M output.

## External Resources

- [GPT-6 Astra launch page](https://openai.com/index/gpt-6-astra/) — the primary source; benchmark tables and the compaction paragraph
- [Dan McAteer's tweet](https://x.com/daniel_mac8/status/2095937045550297131) — the reading that surfaced the compaction change (438 likes, 28 replies)
- [Codex config reference](https://learn.chatgpt.com/docs/config-file/config-reference) — where the experimental compaction feature is enabled
- [The path to Astra (safety update)](https://openai.com/index/path-to-astra/) — Preparedness Framework Critical threshold for cybersecurity
- [GPT-6 Astra system card](https://deploymentsafety.openai.com/gpt-6-astra) — alignment, monitorability, and cyber-safeguard detail
- [Ten advances in mathematics](https://openai.com/index/ten-advances-in-mathematics/) — the open-problem work referenced in the intro
- [The Defender's Window](https://openai.com/index/the-defenders-window/) — OpenAI's framing of offensive/defensive cyber asymmetry
- [Short prime gaps proof (PDF)](https://cdn.openai.com/pdf/51126fac-1b68-4128-9666-c908bcc16033/short_gaps.pdf) and [large prime gaps proof (PDF)](https://cdn.openai.com/pdf/51126fac-1b68-4128-9666-c908bcc16033/long_gaps.pdf) — the two new results, with abridged chains of thought
- [SRE-Bench paper](https://arxiv.org/abs/2608.11469v1) — the contamination-free reverse-engineering benchmark cited for the 88.0% figure

## Original Content

### Source 1 — OpenAI, "GPT-6 Astra: A new generation of intelligence" (openai.com/index/gpt-6-astra/)

> [!quote]- Launch page, verbatim
> # GPT-6 Astra: A new generation of intelligence
>
> ## A new generation of intelligence
>
> We’re introducing GPT‑6 Astra, the world’s most intelligent and aligned model.
>
> GPT‑6 Astra brings together years of research and big bets across pre-training, reinforcement learning, and alignment. Astra is state-of-the-art on computer use, browsing, software engineering, cybersecurity, science, and professional work. Astra saturates FrontierMath Tier 4 with a 98% score, having already helped [solve long-standing open problems⁠](https://openai.com/index/ten-advances-in-mathematics/) in mathematics. Astra also saturates ARC-AGI-3 with a 99.9% score and ExploitBench with a 100% score. It also sets a new frontier on computer and browser use, handling the most demanding professional work with unmatched speed, accuracy, and judgment.
>
> GPT‑6 Astra is rolling out today to a limited set of organizations and over the coming days will become available to all ChatGPT Plus, Pro, Business, and Enterprise users, as well as through the OpenAI API, Microsoft Azure, and AWS Bedrock.
>
> Terminal-Bench Science 0.1ARC-AGI-3FrontierMath Tier 4 (v2)Terminal-Bench 4.0AutomationBench
>
> **Terminal-Bench Science 0.1 tests whether agents can complete scientific research workflows using code and terminal tools, including analyzing data, running simulations, and fitting models. GPT‑6 Astra reaches a new high among the models compared at 64.6%, versus 52.6% for Claude Fable 5.1, at approximately 31% lower estimated API cost. At a lower-cost setting, Astra scores 61.1%, versus GPT‑5.6 Sol’s best result of 22.4%, at approximately 27% lower estimated API cost.**
>
> > “On ARC-AGI-3, Astra surpassed our human action-efficiency baseline on 96% of levels, effectively reaching human parity on the benchmark. Not only is this the best model we’ve ever tested, but it also represents a meaningful step change in frontier-model performance - not only in its ability to navigate and solve novel environments, but also in how efficiently it learns to do so.”
>
> *Greg Kamradt, ARC Prize Foundation*
>
> Astra is our most aligned model, with substantial improvements in understanding user intent and model behavior—you can delegate tasks with greater confidence in Astra’s judgment. As one way that we test this, we built a new evaluation informed by the Hugging Face incident that evaluates whether a model facing a difficult or impossible task will go beyond its intended scope. Compared to GPT‑5.6 Sol, which without production safeguards went beyond the authorized target 48% of the time, GPT‑6 Astra did this in 0% of cases.
>
> **
>
> ## The world’s best computer use model
>
> GPT‑6 Astra marks a new frontier in the speed, accuracy, and safety of computer use. It can take care of tedious tasks like filling out online forms, updating customer records in a CRM, and organizing your calendar. It can conduct online research and draft summaries in your email or in your document editor. It can analyze scientific data, generate plots, create a website, and run frontend QA checks to make sure all the features on that site work. It can help you autonomously install and test software, and troubleshoot problems you see on screen. These improvements are also reflected in our state-of-the-art evaluation results.
>
> Agents’ Last ExamScreenSpot-ProOSWorld
>
> **Agents’ Last Exam tests agents on complex professional tasks in real software, from financial modeling to engineering and media production. GPT‑6 Astra reaches a new high in the comparison shown, scoring 59.3%, compared with 55.5% for Claude Opus 5 and 53.6% for GPT‑5.6 Sol. At these highest-scoring settings, Astra also uses approximately 65% fewer output tokens than Opus 5.**
>
> These improvements also result in significant efficiency gains in real knowledge-work tasks. In latency simulations on OSWorld 2.0, Astra achieves higher computer-use performance in about 47% less time per task than GPT‑5.6 Sol, scoring 72.6% at roughly 40 minutes per task, compared with 65.7% at roughly 75 minutes. [3](#citation-bottom-3)
>
> GPT‑6 Astra’s computer-use capabilities can be seen in outputs across domains, including game development, electrical engineering, and everyday knowledge work:
>
> Circuit boardExcel competitionGame developmentFilling in a Form 1040Frontend quality assurancePower BICar transmissionFormatting a legal document
>
> **This is a 15-second condensed playback of GPT‑6 Astra performing printed circuit board (PCB) layout in KiCad, turning an electronic schematic into a manufacturable PCB by placing components and routing copper connections. Integral to every electronic device today, PCB layout is a manual task and common source of latency in the electronics design process. Accelerating it means freeing engineers to invent, optimize, and test their next idea at a significantly higher cadence.**
>
> Alongside Astra, we are also updating the Codex harness to significantly improve the speed of computer use. Combined with Astra’s efficiency, this translates to a 1.9x faster task completion compared to the current GPT‑5.6 Sol experience, on the Mind2Web benchmark. The model’s improvements on speed mean it can take on many time-consuming life tasks for you, faster than you can. [4](#citation-bottom-4)
>
> Pediatrician searchApartment huntingDMV appointmentLow-carb snacksKindergarten analysis
>
> ##### **GPT‑6 Astra:** 2 min 54 sec
>
> > “We’re integrating GPT‑6 Astra into Devin’s harness on launch day, where it delivers state-of-the-art performance on our internal testing benchmark. Its excellent computer use, writing, and codebase understanding improved testing right out of the box: videos are noticeably easier to follow, and reports are clearer and more concise”
>
> *Silas Alberti, SVP Research, Cognition*
>
> ## A step change in professional work
>
> GPT‑6 Astra pairs advances in computer use with targeted training for professional environments, to help tackle complex work tasks. It combines the intelligence required for complex problems with the ability to carry out multistep workflows and produce polished documents, spreadsheets, and presentations.
>
> BenchCADBrowseCompOpenScore String QuartetsDesign Tasks (Internal)Data Science Tasks (Internal)
>
> **BenchCAD tests whether models can reconstruct 3D objects from multi-view renders by generating CAD code. With tools, GPT‑6 Astra reaches a new high in the comparison shown, achieving a 95.9% geometric-overlap score, versus 83.3% for GPT‑5.6 Sol and 84.3% reported for Claude Fable 5.1.*[5](#citation-bottom-5)* Estimated API cost is approximately 43% lower than Sol and 86% lower than Fable 5.1 in the configurations shown.**
>
> GPT‑6 Astra is our best model for adhering to existing templates and producing slides that are well laid out and succinctly convey key points with a structured narrative. It creates clear, well-structured documents, presentations, spreadsheets, and analyses that follow your templates and match your writing and visual style. Astra is also trained to specifically pull only the context that matters into outputs, instead of repeating information unnecessary for the work at hand. All this means it can output more immediately usable artifacts that match your business context and standards.
>
> Gaia presentationSpreadsheetDocument styling
>
> Reference file
>
> GPT‑6 Astra output
>
> *GPT‑6 Astra creates a slideshow about GPT‑Gaia, a fictional model, using just a few slides from OpenAI’s presentation template, capturing the correct tone and layout throughout. This means you can expect slide decks that are correctly formatted for your business standards.*
>
> GPT‑6 Astra also brings stronger visual judgment to the websites, games, applications, and renderings it builds. With [Sites⁠(opens in a new window)](https://learn.chatgpt.com/docs/sites?surface=app) in ChatGPT, Astra can create, host, and share websites, web apps, and games directly from a prompt.
>
> > “Astra gives us a significant advantage in both capability and efficiency. It successfully executes our most complex creative workflows while using up to 20% fewer tokens than other models we've tested. Most importantly, for our customers, it means higher quality output.”
>
> *Alex Mashrabov, CEO and Co-founder, Higgsfield AI*
>
> Unreal Engine walkthroughBlender modelStills
>
> **GPT‑6 Astra models a house in Blender and turns it into a walkable scene in Unreal Engine 5, helping designers and clients explore the layout and experience the space before it’s built.**
>
> Kart Racer GameSpaceship
>
> **The model can bring games to life through vivid graphics, engaging gameplay and accurate motion, allowing non-technical people to create and play custom games that go beyond rudimentary elements in minutes. Credit: Pietro Schirano.**
>
> When instructions leave room for interpretation, GPT‑6 Astra is better than previous models at making the right call. It uses context to fill in routine gaps and asks focused questions when the answer could change the outcome. In Codex, it can ask asynchronously while continuing work that doesn’t depend on your reply. If you don’t respond, it proceeds with sensible assumptions where appropriate, but waits for your input on consequential decisions.
>
> The examples below show how Astra collaborates on everyday tasks where missing information can materially change the answer.
>
> Career websiteCollege searchGrocery list
>
> *Side-by-side: GPT-5.6 Sol versus GPT-6 Astra helping create a personal career website — Astra asks a focused clarifying question where the answer would change the outcome.*
> ![[gpt6-astra-002.png]]
>
> Astra is also better at staying oriented as a task evolves. Earlier models sometimes treated steering messages as a new goal, losing track of the original request or earlier constraints. Astra incorporates new requirements, changes course when asked, and answers side questions without dropping the broader task.
>
> > “Astra is a significant quality improvement over GPT‑5.6 Sol across complex legal tasks. In our early testing, Astra stood out by approaching legal work the way a discerning lawyer does: it distinguishes documents from established records, surfaces unsupported assumptions, and converts gaps into concrete drafting positions.”
>
> *Niko Grupen, Head of Applied Research, Harvey*
>
> ## Coding
>
> GPT‑6 Astra is the best model for software engineering to date.
>
> > “GPT‑6 Astra delivers state-of-the-art performance on our internal coding benchmarks and shows a clear step forward in trading intuition evaluations compared with GPT‑5.6 Sol. When used for agentic coding, GPT‑6 Astra communicates in a way that’s easier for developers to follow and produces code that requires less iteration to reach production quality.”
>
> *John Crepezzi, AI Assistants, Jane Street*
>
> > “We tested Astra across low, medium, and high effort on one of our first-generation evals, and it came out significantly ahead of GPT 5.6 Sol. Higher effort buys more iterations on a fresh build, more verification through browser testing, and a lean toward code execution over apply-patch. Understanding how a model spends its effort is how we give millions of builders a faster, more reliable path from idea to working app.”
>
> *Fabian Hedin, CTO & Co-founder, Lovable*
>
> 1 of 2
>
> > “GPT‑6 Astra delivers state-of-the-art performance on our internal coding benchmarks and shows a clear step forward in trading intuition evaluations compared with GPT‑5.6 Sol. When used for agentic coding, GPT‑6 Astra communicates in a way that’s easier for developers to follow and produces code that requires less iteration to reach production quality.”
>
> *John Crepezzi, AI Assistants, Jane Street*
>
> > “We tested Astra across low, medium, and high effort on one of our first-generation evals, and it came out significantly ahead of GPT 5.6 Sol. Higher effort buys more iterations on a fresh build, more verification through browser testing, and a lean toward code execution over apply-patch. Understanding how a model spends its effort is how we give millions of builders a faster, more reliable path from idea to working app.”
>
> *Fabian Hedin, CTO & Co-founder, Lovable*
>
> - Jane Street
> - Lovable
>
> Terminal-Bench 4.0FrontierCode 1.1 ExtendedDeepSWEArtificial Analysis Coding AgentDatabase Migration Tasks (Internal)
>
> **Terminal-Bench 4.0 tests agents on complex terminal-based tasks, including software engineering, system configuration, and data analysis. GPT‑6 Astra reaches a new high at 57.9%, compared with 37.3% for GPT‑5.6 Sol*[2](#citation-bottom-2:2)* and 55.8% for Claude Fable 5.1, at approximately 9% and 63% lower estimated API cost per task, respectively.**
>
> With Astra, we’re introducing a new way for Codex to preserve and retrieve context when the context window fills. Historically, models have used compaction to summarize work during long sessions, such as when debugging complex issues or tackling large refactors. Each compaction can leave out details about why a fix failed or how a component behaves. In Codex, Astra can keep notes across context windows, preserving accumulated details without repeatedly compressing them into a single summary. Earlier context windows remain searchable, so Astra can find requirements or test results from previous messages and tool outputs—even if that information wasn’t captured in its notes. You can enable this experimental feature in your [Codex config.toml,⁠(opens in a new window)](https://learn.chatgpt.com/docs/config-file/config-reference) and it will become the default for Astra in the coming weeks.
>
> ## Advancing scientific discovery
>
> > “The story is: end of one era, start of another.”
>
> *Greg Burnham, EpochAI*
>
> GPT‑6 Astra is a major advance for scientific discovery, mathematics, and health. Today, we’re sharing two further results on the gaps between prime numbers. [9](#citation-bottom-9), [10](#citation-bottom-10)
>
> Astra also sets new records across a suite of math and science evaluations.
>
> GPQA DiamondHealthBench ProfessionalLifeSciBenchGeneBench ProMedChemBench
>
> **GPQA Diamond tests graduate-level scientific reasoning in biology, chemistry, and physics. GPT‑6 Astra reaches a new high in the comparison shown at 96.0%. At a lower-cost setting, it also exceeds GPT‑5.6 Sol’s best score—94.9% versus 94.6%—at approximately 37% lower estimated API cost.**
>
> Astra can help with the practical work behind scientific discovery. By combining scientific reasoning with computer use, it can work directly in specialized software to inspect data and explore results, helping researchers assess the evidence and decide what to investigate next.
>
> Sequencing qualityCell-tracking workflow
>
> **GPT‑6 Astra navigates scientific software to inspect sequencing quality and visualize genetic variation, helping researchers assess their data and identify where to focus further analysis.**
>
> ## Cybersecurity
>
> As we discussed in our [safety update⁠](https://openai.com/index/path-to-astra/), Astra is a significant jump in cyber capabilities and meets the [Critical threshold](https://openai.com/index/path-to-astra/) in cybersecurity under our [Preparedness Framework](https://openai.com/index/updating-our-preparedness-framework/). Its ability to identify and develop zero-day exploits can help defenders find and patch weaknesses, but it also creates a need for stronger safeguards. To understand how far these capabilities extend, we ran Astra on internal and third-party expert evaluations.
>
> We first tested the model without production safeguards on ExploitBench and ExploitGym, which evaluate whether models can turn known software vulnerabilities into working exploits. On ExploitBench, Astra achieved a perfect score of 100%, compared with 78.5% for GPT‑5.6 Sol, our previous frontier cyber-capable model. On ExploitGym, Astra reached a 42.4% success rate, compared with 30.3% for GPT‑5.6 Sol, while using substantially fewer output tokens. [13](#citation-bottom-13)
>
> ExploitBenchExploitGymExploitBench (June–August 2026)SRE-Bench
>
> **
>
> Given concerns that exposure to historical software vulnerabilities may have affected benchmark results, we also evaluated Astra on two novel benchmarks. For one, we built an internal “ExploitBench (June–August 2026)” evaluation to test exploit development using vulnerabilities from the previous three months. [14](#citation-bottom-14) Astra achieved substantially higher arbitrary code-execution rates than GPT‑5.6 Sol on this dataset while using far fewer output tokens. During the evaluation, Astra even discovered and used two previously unknown zero-day vulnerabilities. We are disclosing both vulnerabilities to their maintainers.
>
> We also tested Astra on SRE-Bench [15](#citation-bottom-15), a benchmark that measures whether models can reverse engineer software binaries to understand its core logic without access to raw source code. Astra solved 88.0% of tasks in a single attempt and 99.2% within four attempts, compared with 55.9% and 68.7% for GPT‑5.6 Sol, respectively.
>
> Beyond benchmarks, expert-led assessments found that Astra, when run without production safeguards, could use previously unknown vulnerabilities to achieve arbitrary code execution in hardened browsers and create privilege-escalation exploits for hardened operating-systems.
>
> As we discussed in [The Defender’s Window](https://openai.com/index/the-defenders-window/), frontier cyber capabilities can help defenders find weaknesses faster, but they also make those weaknesses easier to exploit, raising the urgency for defenders to adapt. With the version of Astra launching today, defenders can use it to complete tasks such as secure code review and patching.
>
> However, Astra will refuse to comply with more advanced cybersecurity tasks such as creating proof-of-concept exploits for vulnerabilities. Through [OpenAI Daybreak⁠](https://openai.com/daybreak/), we plan to expand access and roll out less restrictive safeguards in the coming weeks. This will enable more defensive workflows, including vulnerability and proof-of-concept validation, malware analysis, and detection engineering.
>
> We have also strengthened our protections against potential cyber misuse, building upon our safeguards stack for GPT‑5.6 Sol. These include stronger model robustness to better withstand potential jailbreaks and more context for our monitoring systems. We have continued rigorous internal and external testing, including automated evaluations with our [internal red-teaming attackers](https://openai.com/index/unlocking-self-improvement-gpt-red/). More details about our cyber safeguards and testing are available in the Astra [system card⁠(opens in a new window)](https://deploymentsafety.openai.com/gpt-6-astra) and our [blog](https://openai.com/index/path-to-astra/).
>
> ## Aligning and deploying GPT‑6 Astra responsibly
>
> Astra is our most aligned model. Astra excels at exercising care, respecting task boundaries, and communicating transparently. This work is the latest product of our long-running research program focused on training models that remain aligned with human intent from start to finish.
>
> In sensitive environments, Astra proceeds with care commensurate with its risk. In an evaluation of computer use tasks adversarially selected to elicit misbehavior, Astra was more successful at avoiding unintended consequences. Running with additional security measures offered by default yielded even stronger performance.
>
> *Astra causes fewer misaligned outcomes than any other frontier models tested. For a fair comparison, we used a generic computer-using-agent harness (based on the native computer use tools available in both the [ OpenAI Responses API⁠(opens in a new window)](https://developers.openai.com/api/docs/guides/tools-computer-use) and [ Anthropic Messages API⁠(opens in a new window)](https://platform.claude.com/docs/en/agents-and-tools/tool-use/computer-use-tool)) and without additional protections that are normally deployed to Codex and ChatGPT Work users (auto-review, confirmation policy). [16](#citation-bottom-16)*
>
> Astra is also more likely to operate within the boundaries set by the user and implied by its environment. In an internal evaluation, Astra never attempted to circumvent a Codex Auto-Review denial. This held even when Auto-review was deliberately configured to be evadable and the task was impossible to complete otherwise. This respect for the environment restrictions is consistent with the results of our impossible cyber task evaluation that we shared in the intro of this post and other findings documented in our [system card⁠(opens in a new window)](https://deploymentsafety.openai.com/gpt-6-astra).
>
> Circumventing auto-reviewExploitGym honeypot
>
> **This evaluation tests how models respond to auto-review denials in knowledge-work tasks. Exploiting a poor user configuration to bypass auto-review counts as failure. Astra never attempted to circumvent auto-review.**
>
> Astra additionally sets new marks in transparent user communication. In one evaluation, Astra is three times less likely than GPT‑5.6 Sol to make inaccurate representations about its capabilities and affordances.
>
> **In our capability-hallucination evaluation, Astra shows a substantial improvement over GPT‑5.6 Sol, making fewer misleading claims about its capabilities.**
>
> Our evaluations found Astra’s written reasoning harder to monitor than GPT‑5.6 Sol’s, based on tests that explicitly asked it to evade monitoring. We attribute this to Astra’s greater control over written reasoning on simpler tasks and ability to solve problems with fewer written steps. Astra still appears to struggle to conceal the reasoning needed for complex tasks, but we take the decline seriously. Improving monitorability remains a research priority, and the accompanying [system card⁠(opens in a new window)](https://deploymentsafety.openai.com/gpt-6-astra) details our findings and ongoing work.
>
> Alignment training is core to our approach to deployment. As an additional layer of defenses, we also build system safeguards like Codex [Auto-review⁠(opens in a new window)](https://alignment.openai.com/auto-review/) and monitoring agents’ reasoning and actions to help detect and contain unsafe behavior. As described in our [safety update⁠](https://openai.com/index/path-to-astra/), we are also deploying misalignment monitoring in production for Astra-class models in order to have visibility into misalignment, and help contain its worst instances. These safeguards resemble our monitoring for internal deployments and involve a system of classifiers which check the model’s reasoning and actions for unauthorized behavior and automatically stop potentially unauthorized activity.
>
> Given the significant increase in Astra’s cybersecurity capabilities, we are being especially careful to make this deployment safe and secure. Extra safety checks can sometimes slow, pause, or stop legitimate work, including defensive cybersecurity. If a task is paused in ChatGPT or Codex, you may be asked to review the action before continuing. In the API, the task will stop. These checks can sometimes interrupt legitimate work, and we are continuing to iterate on this system to reduce unnecessary interruptions. Misalignment monitoring cannot replace alignment: our goal is to build models that reliably stay within their authorized scope, so these protections do not need to intervene.
>
> ## Availability
>
> GPT‑6 Astra is rolling out today to a limited set of organizations and over the coming days will become available to all ChatGPT Plus, Pro, Business, and Enterprise users, as well as through the OpenAI API, Microsoft Azure, and AWS Bedrock. Astra usage is included within the existing subscription allowances—users and businesses will also be able to purchase credits for additional usage. Users on the Pro, Business, and Enterprise plans will also get access to GPT‑6 Astra Pro. Enterprise administrators can enable Astra for their workspace; access is off by default at launch.
>
> Astra supports Zero Data Retention for eligible API customers, and as we shared last month, we're testing [Private Safety Processing](https://openai.com/index/offering-zero-data-retention-for-frontier-models/) to strengthen safety monitoring while preserving customer privacy.
>
> For developers, GPT‑6 Astra will be available in the OpenAI API as `gpt-6-astra` and through Microsoft Azure and Amazon Bedrock.
>
> OpenAI API Standard pricing is $10 per million input tokens and $50 per million output tokens. Separate rates apply to cache reads and writes. Fast mode is available for GPT‑6 Astra in the API and delivers up to 2x the speed of Standard processing at 2x the Standard price.
>
> ### Computer Use
>
> | **Computer Use** | **GPT‑6 Astra** | **GPT‑5.6 Sol [2](#citation-bottom-2:3)** | **Claude Fable 5.1** | **Claude Fable 5** | **Claude Opus 5** | **Gemini 3.8 Flash** |
> | --- | --- | --- | --- | --- | --- | --- |
> | Agents' Last Exam | 59.3% | 53.6% | - | 48.7% | 55.5% | - |
> | OSWorld 2.0 (v2026.08.08, offline set, partial score) | 72.6% | 65.7% | - | - | 70.2% [3](#citation-bottom-3:2) | - |
> | ScreenSpot-Pro (no tools) | 92.7% | 76.9% | - | 87.3% [17](#citation-bottom-17) | - | - |
>
> ### Professional
>
> | **Professional** | **GPT‑6 Astra** | **GPT‑5.6 Sol** | **Claude Fable 5.1** | **Claude Fable 5** | **Claude Opus 5** | **Gemini 3.8 Flash** |
> | --- | --- | --- | --- | --- | --- | --- |
> | AutomationBench | 41.4% | 18.1% | 31.4% | 17.4% | 26.9% | - |
> | BenchCAD | 95.9% | 83.3% | 84.3% [5](#citation-bottom-5:2) | 67.5% [5](#citation-bottom-5:3) | 82.1% [5](#citation-bottom-5:4) | - |
> | BrowseComp | 91.5% | 90.4% | - | 87.4% | 90.8% | - |
> | OpenScore String Quartets (1 - OMR-NED) | 0.84 | 0.19 | - | - | - | - |
> | Internal Design Tasks | 50.0% | 47.4% | - | 35.8% | - | - |
> | Internal Data Science Tasks | 40.9% | 30.5% | - | 34.7% | - | - |
> | Artificial Analysis Intelligence Index v4.1.1 | 61.2 | 60.9 | 65.7 | 62.1 | 63.1 | 58.7 |
>
> ### Coding
>
> | **Coding** | **GPT‑6 Astra** | **GPT‑5.6 Sol** | **Claude Fable 5.1** | **Claude Fable 5** | **Claude Opus 5** | **Gemini 3.8 Flash** |
> | --- | --- | --- | --- | --- | --- | --- |
> | Terminal-Bench 4.0 | 57.9% | 37.3% | 55.8% | 44.5% | 52.6% | 19.1% |
> | DeepSWE v1.1 | 74.1% | 72.7% | 67.4% | 69.9% | 73.7% | 73.8% |
> | FrontierCode 1.1 Extended (score) | 64.5% [8](#citation-bottom-8:2) | 60.6% | 63.6% | 64.9% | 63.6% | 56.3% |
> | FrontierCode 1.1 Main (score) | 53.3% [8](#citation-bottom-8:3) | 47.5% | 50.9% | 53.5% | 53.4% | 43.6% |
> | Internal Database Migration Tasks | 63.9% | 42.7% | 57.8% | 50.3% | - | - |
> | Artificial Analysis Coding Agent Index v1.4 | 67.0 | 65.1 | - | 67.2 | 68.1 | 61.2 |
>
> ### Academic
>
> | **Academic** | **GPT‑6 Astra** | **GPT‑5.6 Sol** | **Claude Fable 5.1** | **Claude Fable 5** | **Claude Opus 5** | **Gemini 3.8 Flash** |
> | --- | --- | --- | --- | --- | --- | --- |
> | Terminal-Bench Science 0.1 | 64.6% | 22.4% | 52.6% | 21.4% | 30.0% | - |
> | FrontierMath Tier 4 (v2) | 97.6% | 83.0% | 87.8% | 90.2% | 73.2% | - |
> | GPQA Diamond | 96.0% | 94.6% | 93.7% | 92.6% | 93.7% | 95.3% |
> | Humanity's Last Exam (w/ tools) | 57.2% | - | 65.0% | 63.8% | 63.6% | - |
>
> ### Science and Health
>
> | **Science and Health** | **GPT‑6 Astra** | **GPT‑5.6 Sol** | **Claude Fable 5.1** | **Claude Fable 5** | **Claude Opus 5** | **Gemini 3.8 Flash** |
> | --- | --- | --- | --- | --- | --- | --- |
> | GeneBench Pro | 37.1% | 32.3% | - | - | - | - |
> | MedChemBench (Internal) | 49.3% | 47.4% | - | - | - | - |
> | LifeSciBench | 60.3% | 59.9% | - | - | - | - |
> | HealthBench Professional (length-adjusted) | 63.4% | 60.5% | 58.1% [11](#citation-bottom-11:2) | 60.9% [11](#citation-bottom-11:3) | 56.4% [11](#citation-bottom-11:4) | 52.1% |
>
> ### Cybersecurity
>
> | **Cybersecurity** | **GPT‑6 Astra** | **GPT‑5.6 Sol** | **Claude Fable 5.1** | **Claude Fable 5** | **Claude Opus 5** | **Gemini 3.8 Flash** |
> | --- | --- | --- | --- | --- | --- | --- |
> | ExploitBench | 100.0% | 78.5% | - | - | 70% | - |
> | ExploitGym | 42.4% [13](#citation-bottom-13:2) | 30.3% [13](#citation-bottom-13:3) | 30.4% [17](#citation-bottom-17:2) | 28.4% [17](#citation-bottom-17:3) | 22.0% | - |
> | ExploitBench (June-Aug 2026) | 39.0% | 5.5% | - | - | - | - |
> | SRE-Bench | 88.0% | 55.9% | - | - | 12.5% | - |
> | SEC-Bench Pro | 85.4% | 79.1% | - | - | - | - |
>
> ### Alignment
>
> | **Alignment** | **GPT‑6 Astra** | **GPT‑5.6 Sol** | **Claude Fable 5.1** | **Claude Fable 5** | **Claude Opus 5** | **Gemini 3.8 Flash** |
> | --- | --- | --- | --- | --- | --- | --- |
> | Internal computer use safety benchmark (lower is better) | 2.4% | 22.0% | 9.5% | 18.3% | 11.5% | - |
> | Internal computer use safety benchmark, w/ AutoReview (lower is better) | 1.8% | 4.3% | - | - | - | - |
> | Internal circumvention benchmark (lower is better) | 0.00% | 0.29% | - | - | - | - |
> | ExploitGym honeypot (lower is better) | 0.0% | 48.2% | - | - | - | - |
> | Impossible ExploitGym | 100.0% | - | - | - | - | - |
> | Internal hallucination benchmark (lower is better) | 4.2% | 12.2% | - | - | - | - |
>
> ### Long Context
>
> | **Long Context** | **GPT‑6 Astra** | **GPT‑5.6 Sol** | **Claude Fable 5.1** | **Claude Fable 5** | **Claude Opus 5** | **Gemini 3.8 Flash** |
> | --- | --- | --- | --- | --- | --- | --- |
> | OpenAI MRCR v2 8-needle 256K-512K | 100.0% | 91.5% | - | - | - | - |
> | OpenAI MRCR v2 8-needle 512K-1M | 96.3% | 73.8% | - | - | - | - |
>
> ### Abstract reasoning
>
> | **Abstract reasoning** | **GPT‑6 Astra** | **GPT‑5.6 Sol** | **Claude Fable 5.1** | **Claude Fable 5** | **Claude Opus 5** | **Gemini 3.8 Flash** |
> | --- | --- | --- | --- | --- | --- | --- |
> | ARC-AGI-3 | 99.9% [1](#citation-bottom-1) | 7.8% | - | - | 30.2% | - |
> | ARC-AGI-2 | 95.0% | 92.5% | 90.0% | 89.2% | 90.4% | - |
> | ARC-AGI-1 | 98.5% | 97.5% | 97.5% | 98.5% | 97.5% | - |
>
> Evaluation scores are the maximum at any effort. GPT evaluations were run in our research environment or via our API, which may provide slightly different output from production ChatGPT due to differences in the system prompts, tools available, etc.
>
> ## FOOTNOTES
>
> 1. 1
>
>    On ARC-AGI-3, GPT-6 Astra was run with [our responses API harness⁠](https://openai.com/index/how-two-settings-tripled-our-arc-agi-3-scores/), which changes two settings to better match real-world performance. The changes do not specifically target ARC-AGI-3. [Scroll to citation 1 reference](#citation-top-1)
> 2. 2
>
>    GPT-5.6 Sol refers to the version available in our API, ChatGPT Codex, and ChatGPT Work. [The version in ChatGPT Chat is slightly different.⁠](https://openai.com/index/improving-gpt-5-6-sol-in-chatgpt/) [Scroll to citation 2 reference](#citation-top-2) [Scroll to reference 2 for footnote 2](#citation-top-2:2) [Scroll to reference 3 for footnote 2](#citation-top-2:3)
> 3. 3
>
>    OSWorld V2-Offline is a subset of the original OSWorld V2 that works without internet access. Claude model performance on OSWorld-V2 Offline was reproduced by the authors** on** [**the official leaderboard**⁠(opens in a new window)](https://osworld-v2.xlang.ai/)**.** On OSWorld 2.0, the scores for Claude use the official settings, and not the modified tasks and modified grading from the Fable 5.1 System Card. [Scroll to citation 3 reference](#citation-top-3) [Scroll to reference 2 for footnote 3](#citation-top-3:2)
> 4. 4
>
>    Model times are the reported elapsed times for the corresponding demonstration runs. The displayed clips are edited excerpts. [Scroll to citation 4 reference](#citation-top-4)
> 5. 5
>
>    On BenchCAD, Claude's scores reflect 3 modifications to the eval, detailed in the [Fable 5.1 System Card⁠(opens in a new window)](https://www-cdn.anthropic.com/0339e6a7c5c7b87f5c07798616dc32c215d14235/Claude%20Fable%205.1%20&%20Claude%20Mythos%205.1%20System%20Card.pdf). [Scroll to citation 5 reference](#citation-top-5) [Scroll to reference 2 for footnote 5](#citation-top-5:2) [Scroll to reference 3 for footnote 5](#citation-top-5:3) [Scroll to reference 4 for footnote 5](#citation-top-5:4)
> 6. 6
>
>    Guang Yang, Victoria Ebert, Nazif Tamer, Brian Siyuan Zheng, Luiza Pozzobon, and Noah A. Smith. “ [LEGATO: Large-scale End-to-end Generalizable Approach to Typeset OMR⁠(opens in a new window)](https://arxiv.org/abs/2506.19065).” arXiv:2506.19065, 2025. [Scroll to citation 6 reference](#citation-top-6)
> 7. 7
>
>    Mark R. H. Gotham, Maureen Redbond, Bruno Bower, and Peter Jonas. “ [The OpenScore String Quartet Corpus⁠(opens in a new window)](https://doi.org/10.1145/3625135.3625155).” Proceedings of the 10th International Conference on Digital Libraries for Musicology, pp. 49–57. ACM, 2023. [Scroll to citation 7 reference](#citation-top-7)
> 8. 8
>
>    On FrontierCode, GPT-6 Astra was run with a developer  message similar to a [section of its developer message in Codex⁠(opens in a new window)](https://developers.openai.com/api/docs/guides/latest-model#prompting-best-practices): "Avoid creating excessive test files. Create a new test file only when required by repository conventions or when no existing file is a suitable home. Avoid unrelated cleanup and unnecessary complexity. Reuse suitable existing utilities. Read relevant repository instructions and inspect nearby code, tests, documentation, and CI. Follow established conventions. The goal is clean, mergeable code." The prompt was not optimized for the eval. [Scroll to citation 8 reference](#citation-top-8) [Scroll to reference 2 for footnote 8](#citation-top-8:2) [Scroll to reference 3 for footnote 8](#citation-top-8:3)
> 9. 9
>
>    The first concerns how close together prime numbers can occur, however far along the number line you go. For more than a decade, the best known result established that infinitely many pairs of primes are at most 246 apart. [Julia Stadlmann⁠(opens in a new window)](https://math.illinois.edu/directory/profile/stadl) recently improved that bound to 240. Astra helped establish a stronger bound of 186, showing that infinitely many pairs occur within this smaller distance. Short prime gaps: [Proof⁠(opens in a new window)](https://cdn.openai.com/pdf/51126fac-1b68-4128-9666-c908bcc16033/short_gaps.pdf) and [supporting research⁠(opens in a new window)](https://cdn.openai.com/pdf/51126fac-1b68-4128-9666-c908bcc16033/short_gaps_abridged_cot.pdf). [Scroll to citation 9 reference](#citation-top-9)
> 10. 10
>
>     The second concerns unusually large gaps between primes. Astra improved a term in a bound on these gaps that had remained unchanged for more than 80 years. We’re sharing the proofs and abridged chain of thought and verification materials for both results. Large prime gaps: [Proof⁠(opens in a new window)](https://cdn.openai.com/pdf/51126fac-1b68-4128-9666-c908bcc16033/long_gaps.pdf) and [supporting research⁠(opens in a new window)](https://cdn.openai.com/pdf/51126fac-1b68-4128-9666-c908bcc16033/long_gaps_abridged_cot.pdf). [Scroll to citation 10 reference](#citation-top-10)
> 11. 11
>
>     We independently evaluated all Claude models following the intended HealthBench Professional procedure, using GPT‑5.4 grading and length-adjusted, unclipped scores. For Fable 5.1, we used Opus 5 fallback for provider refusals. [Scroll to citation 11 reference](#citation-top-11) [Scroll to reference 2 for footnote 11](#citation-top-11:2) [Scroll to reference 3 for footnote 11](#citation-top-11:3) [Scroll to reference 4 for footnote 11](#citation-top-11:4)
> 12. 12
>
>     Claude Fable 5 and 5.1 are not included in LifeSciBench Gold v1, GeneBench Pro v13, and MedChemBench because they refuse the majority of questions in these evaluations. [Scroll to citation 12 reference](#citation-top-12) [Scroll to reference 2 for footnote 12](#citation-top-12:2) [Scroll to reference 3 for footnote 12](#citation-top-12:3)
> 13. 13
>
>     On ExploitGym, we tested Astra and Sol without the 6-hour time limit, to better assess their full cyber capabilities. They are fast enough that it has little impact. [Scroll to citation 13 reference](#citation-top-13) [Scroll to reference 2 for footnote 13](#citation-top-13:2) [Scroll to reference 3 for footnote 13](#citation-top-13:3)
> 14. 14
>
>     ExploitBench (June–August 2026) contains 20 high-severity V8 vulnerabilities across 13 stable Chrome releases. The benchmark tests whether agents can achieve arbitrary code execution in V8 and official Chrome releases for Linux by exploiting each specified vulnerability. Some included vulnerabilities may not permit arbitrary code execution under the evaluation’s constraints, so a 100% success rate may not be achievable. Note: the 5.5% score of GPT-5.6 Sol is an artifact of the 300-turn limit in the benchmark, which is not a limit that real customers using max would have. The model at similar settings achieved an 11.5% score when hitting fewer limits. [Scroll to citation 14 reference](#citation-top-14)
> 15. 15
>
>     Jeremy Spence et al. “ [The Next Challenge for Agentic Cybersecurity: A Realistic, Contamination-Free Reverse Engineering Benchmark⁠(opens in a new window)](https://arxiv.org/abs/2608.11469v1).” arXiv:2608.11469v1, 2026. [Scroll to citation 15 reference](#citation-top-15)
> 16. 16
>
>     *When we test across third-party models, we use a simpler research setup. Codex has a more complex production configuration, which can result in different raw-model error rates. Provider-side safeguards and computer-tool implementations still differ. Users do not experience the no-confirmation scenario in Codex, as it's an internal research configuration.*[Scroll to citation 16 reference](#citation-top-16)
> 17. 17
>
>     For ScreenSpot-Pro and ExploitGym, the Fable scores we report come from Mythos, which is Fable with fewer safeguards. [Scroll to citation 17 reference](#citation-top-17) [Scroll to reference 2 for footnote 17](#citation-top-17:2) [Scroll to reference 3 for footnote 17](#citation-top-17:3)
>

### Source 2 — Dan McAteer (@daniel_mac8) on X, 4 September 2026

**@daniel_mac8 (Dan McAteer)** — 4 September 2026, 18:08 UTC — 438 likes, 17 retweets, 28 replies
[https://x.com/daniel_mac8/status/2095937045550297131](https://x.com/daniel_mac8/status/2095937045550297131)

> GPT-6 Astra's new compaction mechanism in Codex.
>
> tldr;
>
> 1. Can save notes across context windows.
>
> 2. Earlier context windows are searchable including messages AND tool calls.
>
> Must have GPT-6 Astra behaving less like an amnesiac and make the context window feel massive.

*The screenshot attached to the tweet: the launch page's compaction paragraph, with "In Codex, Astra can keep notes across context windows, preserving accumulated details without repeatedly compressing them into a single summary" highlighted.*
![[gpt6-astra-001.jpg]]

> **@daniel_mac8** (self-reply):
> Source: https://t.co/BwNAxmIRr2

#### Substantive replies

> **@staydown124 (Paul · SpellWright)**:
> Cross-window note search including tool calls is the real unlock. Is that live in Codex today or preview-only?

> **@MatthewSchrager (Matthew Schrager)**:
> I actually kind of figured this was how it always worked. Seems like a fairly obvious way to do it - similar to how a person would pick up work after sleeping on it.
>
> **@daniel_mac8**: It does seem intuitive.

> **@heypearlai (Pearl AI)**:
> this is probably the biggest upgrade for long Codex sessions, searchable tool calls means the model can recover details that a summary would’ve lost

> **@EdwinAI_Systems (Edwin | AI Systems)**:
> The searchable tool calls are the part that matters. Notes alone still feel like sticky pads. Being able to query what the agent did 3 windows ago is how long-horizon coding stops collapsing.

> **@XiiBORG (Bruno)**:
> The catch is that searchable tool history can resurrect dead ends. A command is not useful memory without its exit status, working directory and the later correction. Otherwise long-context recovery turns into very confident archaeology.

> **@matijagrcic (Matija Grcic)** (quoting himself):
> correct, here's more info.
>
> > Codex no longer has to squeeze hours of work into an increasingly lossy summary so long sessions feel continuous instead of repeatedly starting from a blurred memory.
> >
> > refs: https://t.co/6kQZR7uznA
> > — https://x.com/matijagrcic/status/2095801235492196553

> **@chams_builds (Chaminda)**:
> The searchable tool calls matter more than the notes. Notes are what it decided to remember; tool call history is what actually happened, and those two disagree more often than you'd expect.

> **@catmanyau (catman)**:
> searchable tool calls matter more than saved notes here—can GPT-6 Astra recover why a command failed, or just retrieve the command itself?

> **@ScottSandler4 (Scott Sandler)**:
> searchable tool-call history across compact windows is the feature I actually want. does it hold up once the thread gets long?

> **@_MustafaOkur_ (Mustafa Okur)**:
> Some of this stuff is conceptually so simple, surprised they never got round to implementing notes between compaction sessions before! Maybe harder to implement.
>
> **@daniel_mac8**: Also have to consider that the new model has been trained to navigate it.

> **@preyforge (Preyforge)**:
> I like durable notes, but I still verify restored context against live output; faithful memory can preserve a wrong assumption just as efficiently.

> **@SFourdrinier (Stephane)**:
> Finally! I’ve been suggesting doing this for a long long time part of a harness. This has always sounded like such an easy great win. Like add a tool which can also search the previous context in super smart ways.

> **@AnthonyMaio (Anthony Maio)**:
> Already doing this with AGENTS.MD & https://t.co/KsEWYD1NTh. Ambient memory captures my context, and Codex writes notes to Pieces via MCP. Agents reference both, so I can start fresh sessions anytime without dropping history.

---

Original sources: [openai.com/index/gpt-6-astra](https://openai.com/index/gpt-6-astra/) and [x.com/daniel_mac8/status/2095937045550297131](https://x.com/daniel_mac8/status/2095937045550297131)
