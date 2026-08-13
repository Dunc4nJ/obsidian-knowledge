---
created: 2026-08-13
description: Giovanni's (@regulargio) first-principles primer on benchmarking science, Part I of III — benchmarks as measurement instruments not question collections ("the thermometer is not the temperature"), the claim template "System S can complete task family X for population Y under conditions Z," the task→grader→metric→score anatomy, coverage vs difficulty, read-your-data as the highest-return practice, weighting decisions hiding in every average, standard error and reference points, and save-the-rows (aggregate late, keep task-level evidence).
source: https://x.com/regulargio/status/2087644734269649034
author: "@regulargio (giovanni)"
type: article
tags: [eval, benchmarking, measurement, statistics, llm-as-judge, coverage, sampling, confidence-intervals, methodology]
---

## Key Takeaways

- **A benchmark is a measurement instrument, not a collection of questions — and the score supports a *claim*, not a capability.** There is no `software_engineering_score` inside a model; the loop is *thing we care about → observable tasks → behavior → grading → score → conclusion*, and "the thermometer is not the temperature." Every step away from the direct observation adds assumptions: "resolved 47% of these repository issues" ≈ observable; "good at software engineering" requires representativeness; "generally intelligent" requires leaps. The working template: **"System S can complete task family X for population Y under conditions Z"** — formally, the probability a task drawn from the population-you-care-about is completed. The whole science is when the benchmark estimate (right side) is useful evidence about that population quantity (left side). Five design questions: what are we learning, what system, what work do tasks represent, what decision does the result inform, and *what should the score not be used to claim*.

*The series roadmap — Part I: foundations; Part II: failure modes (contamination, unreliable graders, leaderboard gaming); Part III: frontier evals (arenas, production, agent trajectories):*
![[regulargio-649034-001.png]]

- **Anatomy: task → dataset → grader → metric — and the grader is part of the instrument, not reality.** A task is one unit of work (a JSON math prompt, or a full SWE-Bench-style repo+issue+terminal environment, which imports confounders with the added realism); a dataset is *chosen* — a sample of a much larger space, never "the world"; the grader (exact-match, tests, human, LLM judge, or final-environment-state inspection) **can itself fail** — accepting bad work records false success, rejecting valid work records false failure (why [[anthropic recommends combining deterministic graders model judges and human review for agent evals|grader triangulation]] and [[deep agent evals need bespoke per-datapoint test logic not uniform evaluators|bespoke per-datapoint test logic]] matter); the metric aggregates. Benchmark = (T, S, G, M); an evaluation is one experiment with it; a leaderboard is many evaluations side by side.

*The "task" at agent scale — SWE-bench's issue + codebase → generated PR → unit-test grading:*
![[regulargio-649034-002.png]]

- **Coverage ≠ difficulty, and misrepresenting your distribution is the original benchmark sin.** If users are 70% small bug fixes but your benchmark is 80% hard multi-file refactors, you built a great *frontier-separating* benchmark and a bad *predictor of user experience* — different distributions, know which one you sampled. Legitimate reasons to diverge exist (safety oversamples rare failures; frontier suites select hard problems because normal ones saturated — SimpleQA → SimpleQA Verified); "I don't care what's your reason as long as you have a reason and are aware." What's illegitimate is making one choice and interpreting the score as the other — "claiming your agent is good at math because it solves AIME problems is poor science." This is the distribution-mismatch trap behind bench-maxxing, and the reason [[targeted evals shape agent behavior more effectively than large benchmark suites]].

*Coverage made visible — real user coding queries vs LiveCodeBench/competition problems vs SWE-Bench Verified, as clusters in embedding space:*
![[regulargio-649034-003.png]]

- **"Read your data" is the highest-return practice in evals — before sampling strategies, before confidence intervals, before announcing A beats B.** Look at random/easy/hard tasks, model disagreements, duplicates, weird formatting, suspicious references; read the *metadata* (who wrote it, when, scraped or expert-authored, model-generated?) — benchmark errors and recycled data survive for years in heavily-used datasets. And interrogate the sample itself: for "good workplace communication," *whose* workplace, which language, who wrote the reference answers? ("Positionality/axiology" = *somebody made choices about what counts as good*.) This is the same manual-comprehension-first stance as [[automating AI skill improvement fails without manual comprehension of outputs]] and step one of [[agent eval readiness starts with error analysis and simple end-to-end tests not sophisticated infrastructure]].

- **Numbers: every average hides a weighting decision; every score needs uncertainty and a reference point; and save the rows.** 900 Python + 100 JavaScript tasks means an unweighted average already decided Python matters 9x (maybe right, maybe your scraper) — micro vs macro averaging changes the answer on identical outputs, so slice by meaningful hypotheses (Simpson's paradox lurks in aggregates). A score is a finite-sample estimate: 74% on 20 tasks ≠ 74% on 2,000 (standard error ≈ √(p(1−p)/N)); "Model B improved by 1%" is unanswerable without the interval — *ask how many observations produced any number you see*. 74% is uninterpretable without a reference (random = 70% deflates it; experts = 76% inflates it; label noise may cap the ceiling at 85%; "superhuman" over five tired annotators is not the singularity). Finally: **aggregate late, save the raw evidence early** — task-level rows (output, passed, latency, tokens, cost, and full trajectories for agents) are what let you explain *why* A beat B, exactly the discipline behind [[Terminal-Bench leaderboard requires five full runs with raw logs to enforce reproducibility over cherry-picked results|five-runs-with-raw-logs leaderboards]], [[data-eng-bench shows a data-native harness beats generic coding agents on dbt tasks at up to 3.9x lower cost with equal or better quality|Pass@1/Pass^3 reporting]], and [[a working offline eval turns vibes into repeatable measurement in 10 steps|working offline evals]]. A useful result is the full sentence: system config + task population + protocol + grader + CI + slices + baselines + intended use — "Model A: 74%" alone is almost content-free.

*The Simpson's-paradox warning, in Simpsons form — the aggregate trend can invert the story inside every slice:*
![[regulargio-649034-006.png]]

## External Resources

- Original article: [The science of benchmarking: from Zero to Hero, Part I — @regulargio](https://x.com/regulargio/status/2087644734269649034) (Parts II & III forthcoming: failure modes — contamination, unreliable graders, leaderboard gaming; frontier — arenas, production evals, agent trajectories, adaptive testing)
- Referenced: [SWE-Bench (arXiv 2310.06770)](https://arxiv.org/abs/2310.06770) · [SimpleQA](https://openai.com/index/introducing-simpleqa/) / [SimpleQA Verified (arXiv 2509.07968)](https://arxiv.org/abs/2509.07968) · [MS COCO (arXiv 1405.0312)](https://arxiv.org/abs/1405.0312) · [Simpson's paradox](https://en.wikipedia.org/wiki/Simpson%27s_paradox) · [Confidence intervals](https://en.wikipedia.org/wiki/Confidence_interval) · [Confounding](https://en.wikipedia.org/wiki/Confounding)

## Original Content

> [!quote]- Full X Article — "The science of benchmarking: from Zero to Hero [Part I]" (@regulargio / giovanni, 2026-08-12)
> Article: The science of benchmarking: from Zero to Hero [Part I]
>
> Evals are suddenly everywhere: company strategy, political decisions, advertising.
>
> Yet there is surprisingly little material explaining the science behind them. This three-part series is my attempt to explain benchmarking from first principles.
>
> We will start with the basics:
>
> - Why benchmark? What question is an evaluation supposed to answer?
>
> - What should we benchmark? Which tasks, users, environments, and capabilities should the data represent?
>
> - How should we benchmark? How do metrics, sampling, uncertainty, and statistics turn into a score?
>
> In Part II, we will go deeper into the ways benchmarks fail. We will look at stronger statistics, noisy data, unreliable graders, contamination, repeated trials, leaderboard gaming, and the tricks that we can use to have pretty score for the investors.
>
> In Part III, we will move to the frontier: live and dynamic benchmarks, arenas, production evals, agent trajectories, adaptive testing, and the open problems teams at places like Arena, Braintrust, and Intelligence.ai are trying to solve.
>
> ## Why do we Benchmark?
>
> The short answer is that most of the things we care about are not directly observable.
>
> Suppose I want to know whether a model is good at software engineering. There is no software_engineering_score inside the model that I can print out and say “72% good at debugging.” What I can do is give the system some work, observe what it does, decide whether the work was completed successfully, and use those observations as evidence.
>
> Very roughly:
>
> thing we care about → tasks we can observe → system behavior → grading → score → conclusion
>
> A benchmark is an attempt to make that loop quick, reliable, and useful.
>
> Some follow up questions you may ask are: If I say I want to measure “reasoning,” which tasks should count as reasoning? If the model gets the final answer right for the wrong reason, should that count? If another model gets the answer wrong because of a formatting mistake, should that count against its reasoning ability?
>
> This is why I find it useful to think of benchmarks as measurement instruments rather than as collections of questions.
>
> The thermometer is not the temperature. It is an instrument that produces an observation which, under the right assumptions, tells us something about temperature. Likewise, a benchmark score does not equal intelligence, reasoning, coding ability, safety, or any other capability. The score is an observation generated by an instrument that, under the right assumptions, tells us something about the underlying construct.
>
> The farther the claim moves from the thing we directly observed, the more assumptions we are making.
>
> Consider three statements:
>
> > This system resolved 47% of these repository issues.
>
> > This system is good at software engineering.
>
> > This system is generally intelligent.
>
> The first is relatively close to what we can observe from a benchmark of certain repository issues (but still quite an underspecified statement). The second requires us to argue that the repository issues are representative of software engineering. The third requires several more leaps.
>
> The first job of an eval is to support a claim.
>
> A useful template is:
>
> > System S can complete task family X for population Y under conditions Z.
>
> Being more precise, suppose X is a family of tasks, Y is the population we care about, and Z specifies the conditions under which the system operates. Then the thing we would ideally like to know is:
>
> In words: if I draw a task from the population of work I care about, what is the probability that system S successfully completes it under conditions Z?
>
> Unfortunately, we cannot usually see the entire population of work we care about. For example, we do not have access to every future software-engineering task, every customer request, or every reasoning problem the model might encounter.
>
> So we build a benchmark. We sample some finite set of tasks and estimate that unknown quantity:
>
> where
>
> It follows that:
>
> The entire science of benchmarking is, in some sense, about understanding when the thing on the right gives us useful evidence about the thing on the left. For example, we create a benchmark on software engineering in the hope that we will predict how good, in production, the model is going to be. A better benchmark is a better predictor for a precise claim.
>
> When building a benchmark we should ask ourselves:
>
> 1. What are we trying to learn?
>
> 2. What system are we evaluating?
>
> 3. What work should the tasks represent?
>
> 4. What decision will the result inform?
>
> 5. What should the score not be used to claim?
>
> So, again, why benchmark?
>
> > Because we need evidence to make decisions about systems we cannot understand by inspection alone.
>
> ## What is a benchmark?
>
> Once we know what question we are asking, we need to turn it into something observable / actionable.
>
> That process has a few pieces:
>
> tasks → system → outputs → grader → metric → score
>
> (T) A task is one unit of work.
>
> For a simple math benchmark, a task might be:
>
> ```json
> {
>     "id": "math_017",
>     "prompt": "What is 17 × 6?",
>     "reference_answer": "102"
> }
> ```
>
> For a coding agent, a task can be much larger: an initial repository, an issue description, access to a terminal, and some conditions defining successful completion, an example is seen [ in the original SWE-Bench paper.](https://arxiv.org/abs/2310.06770)
>
> In this case, we move from “complete this function” to “resolve this issue in a real repository” introducing repository navigation, dependency understanding, editing across files, running tests, and iterating on failures. So we are no longer measuring only whether the model can generate a few correct lines of code. The "task" has a higher level of complexity, usually followed by a higher level of dependencies and [confounders](https://en.wikipedia.org/wiki/Confounding).
>
> (D) A dataset is a collection of those tasks.
>
> Sometimes the dataset is static. Sometimes tasks are generated dynamically. Sometimes there are train, validation, and test splits. But conceptually it is the set of observations we have chosen to make.
>
> The word there is chosen. A dataset is never simply “the world.” It is a sample of some much larger space of possible work. We will come back to this in Part II because sampling turns out to be one of the most important parts of benchmark design.
>
> (G) A grader
>
> After the system does the task, something has to determine what happened.
>
> For a simple exact-answer task a grader can look like:
>
> ```python
> def grade(prediction, reference):
>     return prediction.strip() == reference.strip()
> ```
>
> There are different flavors of this. For a repository task, the grader might run tests. For a writing task, it might be a human evaluator or an LLM judge (ie. an LLM whose asked to grade something). For an agent acting in an environment, the grader may inspect the final state of that environment.
>
> This component goes by several names: grader, evaluator, or verifier.
>
> > The grader is not reality. It is another part of the measurement instrument.
>
> The grader is part of the system and can itself fail. If the grader accepts bad work, the benchmark records false success. If it rejects valid work, the benchmark records false failure. Again, we will spend a lot of time on this in Part II.
>
> (M) A metric
>
> Finally, we need to aggregate outcomes.
> Suppose we evaluate (N) tasks and record:
>
> Then the simplest benchmark score is just the average:
>
> Then, if the model passes 74 out of 100 tasks:
>
> or 74%. Now we can put the pieces together.
>
> What is a benchmark?
>
> Definition:
>
> > A benchmark is a set or generator of tasks (T), together with a protocol for running systems (S), a way of judging outcomes (G), and a metric for summarizing those outcomes (M).
>
> Then an evaluation is one particular experiment using that benchmark:
>
> Benchmark version + system configuration + evaluation protocol + outputs + task-level results = evaluation
>
> And a leaderboard is simply a way of reporting many such evaluations next to one another.
>
> Assuming that all the machinery is implemented correctly (spoiler: it is actually pretty hard) we still have to decide what tasks to put into the benchmark in the first place.
>
> ## What are we benchmarking?
>
> Suppose 70% of what your users ask for is small bug fixes, 20% is code explanation, and 10% is larger refactors.
>
> Now suppose your benchmark contains:
>
> - 10% small bug fixes
>
> - 10% code explanation
>
> - 80% difficult multi-file refactors
>
> You may have built a very hard benchmark. You may even have built a great benchmark for separating frontier coding agents.
>
> But you have not built a representative benchmark of your users. The benchmark and production traffic are now different distributions, so the score is a worse predictor of what users will actually experience.
>
> Let
>
> be the distribution of tasks we actually care about.
>
> And let
>
> be the distribution of tasks in our benchmark.
>
> Ideally, if our goal is to estimate performance in the real world, we want the second to tell us something useful about the first.
>
> In the extremely unrealistic perfect world:
>
> Assume we had 100% accuracy on every single query we input. That, my friends, is AGI.
>
> In practice, they are almost never identical. And this is okay, as long as we remember that the score represents the task we use not the ones we care about. The important thing is to know why they are different.
>
> There are plenty of legitimate reasons for the distributions to differ. Safety evals may deliberately oversample rare failures. Frontier benchmarks may select unusually hard problems because normal ones are saturated. A product team may care about one narrow customer population.
>
> I don't care what's your reason as long as you do have a reason and are aware! What is not legitimate is making one choice and interpreting the score as if we made another. Claiming your agent is good at math because it solves AIME problems is poor science.
>
> Coverage and difficulty are not the same thing
>
> Coverage:
>
> > Does this benchmark represent the space of work I care about?
>
> Difficulty:
>
> > Does this benchmark contain tasks hard enough to distinguish the systems I care about?
>
> Going back in time, [SimpleQA](https://openai.com/index/introducing-simpleqa/) collected a broad set of language-understanding tasks. Once systems started doing well on it, [SimpleQA Verified](https://arxiv.org/abs/2509.07968) intentionally selected harder tasks to better distinguish new systems.
>
> So turns out that a benchmark that is useful for ranking frontier models is not automatically useful for predicting what users experience. Hence, the multiple complaints about "bench-maxxing" science.
>
> Tasks are important and basically the basis of every claim we make; so how do we know what my benchmark actually contains?
>
> Read your data.
>
> I am attaching an example on how to do it here:
>
> *An example of reading your data — a benchmark task up close (a Palmyrene-inscription translation task, with its provenance):*
> ![[regulargio-649034-004.png]]
>
> I know this sounds unsophisticated, but it may be the highest-return thing you can do when working on an eval (or training for that matter).
>
> Before writing a fancy sampling strategy:
>
> read the tasks.
>
> Before computing a confidence interval:
>
> read the tasks.
>
> Before announcing that A beats  B:
>
> please, for the love of God:
>
> read the tasks.
>
> Look at random tasks, very easy ones, very hard ones, model disagreements, duplicates, weird formatting, suspicious references, and anything that simply does not look like the capability you thought you were measuring.
>
> And you should not only read the prompt. Read the metadata.
>
> Where did it come from? Who wrote it? Who labeled it?  What year was it collected? Was it generated by a model? Was it scraped from Reddit? Was it written by domain experts? [...]
>
> I have countless horror stories from benchmark errors and recycled data surviving for years in heavily used datasets.
>
> *Where labels come from — an annotation-tool view of the kind of data that ends up in heavily-used datasets:*
> ![[regulargio-649034-005.png]]
>
> You should look not only at whether individual tasks are correct, but whether the sample itself is right for what you are trying to measure. Who decided what belongs in the benchmark? Suppose we build an eval for “good workplace communication.”
>
> Whose workplace? Which language? Which industry? What level of seniority? What counts as “good”? Who wrote the reference answers?
>
> This is sometimes discussed under terms like positionality or axiology. Please read those words as follows:
>
> > Somebody made choices about what counts as good behavior.
>
> This is also why domain experts matter, and why companies like Mercor make so much money. Experts are usually better positioned to decide both what counts as a correct label and what behavior is actually worth testing in production.
>
> TL;DR:
>
> > Know what you want to measure, and then look at the things you are using to measure it.
>
> We can now finally get to everyone's favorite part.
>
> Numbers.
>
> ## How good is 74%?
>
> Suppose we run our benchmark.
>
> Model A passes 74 out of 100 tasks.
>
> So:
>
> Great.
>
> Model B passes 78.
>
> There are at least two questions hiding inside those numbers:
>
> 1. What exactly got averaged?
>
> 2. How uncertain is the average?
>
> Let's start with the first. Imagine our 100-task benchmark contains:
>
> Most of the benchmark is math, so math dominates the overall score even though the category-level story is different.
>
> This is why you should basically never look at only the aggregate. For further reading on this I suggest learning about [Simpson's Paradox](https://en.wikipedia.org/wiki/Simpson%27s_paradox).
>
> Try to be precise with the type of tasks, and compute slices of the dataset to check where performance comes from.
>
> Some example slices:
>
> task category, source, difficulty, language, customer type, repository, prompt length, required tool, geography, basically any variable that corresponds to a meaningful hypothesis
>
> There is a dangerous version of slicing where you cut the data 900 different ways until you find an exciting result. More in Part II.
>
> > An average tells you what happened on average. Your users generally do not arrive as averages.
>
> Ok so our tasks may be better suited to be tracked in different slices. What about the scores?
>
> In the math example above, if every task counts equally, the score is:
>
> This is essentially a micro average. But maybe we care equally about the three categories.
>
> Then:
>
> Same system. Same tasks. Same outputs.
>
> Thus:
>
> > Every average contains a weighting decision.
>
> Sometimes the weighting is explicit. Sometimes it is hidden in how many examples happened to be collected from each category.
>
> If your benchmark has 900 Python tasks and 100 JavaScript tasks, then an unweighted task average has already decided that Python matters nine times more.
>
> Maybe that is exactly right. Maybe your product is 90% Python.
>
> Or maybe your scraper was just better at finding Python repositories.
>
> ## The importance of statistical certainty
>
> Two benchmarks can both report 74% and mean very different things. If one has 20 tasks and the other has 2,000, I trust the second number much more. Why?
>
> Because the benchmark score is an estimate based on a finite sample. If we sampled a different set of 20 tasks, we could get a very different answer.
>
> For a binary pass/fail benchmark, the simplest approximation to the standard error of the pass rate is:
>
> > Standard error is roughly how much this estimate would move around if we resampled the benchmark.
>
> As N, the number of benchmark tasks, gets larger, uncertainty shrinks.
>
> [One useful interval we tend to get is the the approximate 95% confidence calculated as](https://en.wikipedia.org/wiki/Confidence_interval):
>
> There are better ways to construct intervals, but the basic point is: a score without uncertainty is missing information.
> This becomes especially important when people make claims like:
>
> > Model B improved by 1%.
>
> Is that signal or noise? You can't know without measuring the uncertainty around the estimate. Assuming you have a very wide 95% confidence interval, it would be hard to claim it is signal.
>
> In Part II, we will look at paired tests, bootstrap intervals, repeated trials, statistical power, and why comparing two systems on the exact same examples gives us much more information than comparing two isolated means.
>
> > Rule of Thumb: Whenever you see a benchmark number, ask how many observations produced it.
>
> ## 74% compared to what?
>
> What is the reference point?
>
> Suppose a model gets 74%. That sounds pretty good. Now I tell you random guessing gets 70%. Less impressive. Or maybe human experts get 76%. Much more impressive.
>
> Or perhaps the benchmark contains enough ambiguous or incorrectly labeled examples that 85% is effectively the meaningful ceiling. Now 74% means something else again. A score only becomes interpretable relative to something.
>
> Useful references can include:
>
> - random performance
>
> - a simple heuristic baseline
>
> - an older model
>
> - human performance
>
> - domain-expert performance
>
> - production performance
>
> - a known ceiling
>
> Be careful with the phrase human performance, by the way.
>
> Which humans? Random Mechanical Turk workers? Undergraduates? Professional software engineers? The people who authored the benchmark?
>
> A benchmark claiming “superhuman performance” because a model beat five tired annotators is perhaps not quite the singularity. Reference population matters.
>
> ## Save the rows
>
> This is a small practical thing that becomes extremely important later.
>
> Do not only save:
>
> ```json
> {
>     "model": "Model A",
>     "score": 0.74
> }
> ```
>
> Save the task-level results.
>
> Something closer to:
>
> task_id, category, source, system, output, passed, latency, tokens, cost
>
> Why did A beat B? 0.74 and 0.71 cannot tell you. The task-level rows can.
>
> - where A and B disagree
>
> - whether differences concentrate in one slice
>
> - whether grader errors explain the gap
>
> This becomes even more important for agents, where you may also want the entire trajectory.
>
> > Aggregate late. Save the raw evidence early.
>
> ## It is not just the score
>
> By now, ‘Model A: 74%’ should feel almost content-free by itself. A useful result looks more like:
>
> > Under system configuration (S), Model A successfully completed 74% of the 500 benchmark tasks sampled from population (P_B), under protocol (Z), according to grader (G).
>
> And then we should add:
>
> - confidence interval
>
> - relevant slice scores
>
> - baselines
>
> - important exclusions
>
> - intended use of the result
>
> Something like:
>
> System:
> Model A + prompt v3 + terminal tool
>
> Task population:
> 500 repository-level Python bug-fixing tasks
>
> Protocol:
> One attempt, 30-minute budget
>
> Metric:
> Functional pass rate
>
> Score:
> 74%
>
> 95% interval:
> [...]
>
> Important slices:
> Small fixes: [...]
> Large fixes: [...]
>
> Known exclusions:
> No feature requests
> No non-Python repositories
>
> Claim supported:
>
> - Performance on this task distribution under this protocol
>
> Claims not supported:
>
> - Best coding product
>
> - General software-engineering ability
>
> - Performance on production traffic
>
> ## Can someone else reproduce the number?
>
> Last piece on reproducibility. Suppose I publish:
>
> > Our model gets 82.7% on SuperCoolBench.
>
> Okay. People out there need to be able to recreate the number. We trust you, but not that much.
>
> What would somebody else need to know to recreate that number?
>
> At minimum:
>
> benchmark version, task/data version, model version, system prompt, tools/scaffold, evaluation protocol, metric implementation, sample size, random seed, when relevant, task-level results, evaluation date
>
> [BetterBench](https://arxiv.org/abs/2411.12990) evaluated benchmarks across a much broader lifecycle and found, among other things, that many benchmarks did not make results easy to reproduce or report statistical significance consistently.
>
> Reproducibility is both a data problem and a system problem. A great dataset attached to an undocumented evaluation script is not a great measurement instrument.
>
> Neither is a leaderboard where the model name is visible but nobody knows which prompt, sampling parameters, scaffold, or grader version produced the number. This leads to different people using different conventions, typically the convention that helps the company make the best business statement.
>
> This will become much more important later in the series when we talk about benchmark versions, contamination, grader changes, and living evals.
>
> For now, a decent rule is:
>
> > If changing something could plausibly change the score, record it.
>
> # What did we learn?
>
> > A benchmark compresses a large measurement process into something we can reason about quickly.
>
> When you see:
>
> > Model A: 74%
>
> try to mentally expand it into:
>
> > 74% verified success on a particular sample from a particular task population, under a particular system configuration and protocol, using a particular grader and aggregation rule, with some amount of uncertainty.
>
> The main ideas I want you to leave Part I with are:
>
> > A benchmark is a measurement instrument, not a capability.
>
> > The score belongs to the system and protocol that produced it.
>
> > The benchmark is a sample from some larger task population.
>
> > Every metric contains choices about what gets counted and how it gets weighted.
>
> > Read your data.
>
> > The job of benchmarking is to make the second useful evidence about the first.
>
> So far, however, we made a lot of assumptions.
>
> - We assumed the data is correct.
>
> - We assumed the grader works.
>
> - We assumed the model did not see the benchmark during training.
>
> - We assumed two leaderboard submissions were compared fairly.
>
> - We assumed the difference between 74 and 78 is actually meaningful.
>
> - We assumed the benchmark still measures today what it measured when it was created.
>
> Those are some extremely optimistic assumptions.
>
> In Part II, we are going to break them.
>
> ## Sources
>
> A few papers and resources that shaped the examples and ideas in this piece:
>
> - NeurIPS 2025, [The Science of Benchmarking: What’s Measured, What’s Missed, and What’s Next](https://neurips.cc/virtual/2025/loc/san-diego/109598). Big ispiration and incredible learning material on modern benchmarking practice and evaluation methodology.
>
> - Jimenez et al. (2024), [SWE-bench: Can Language Models Resolve Real-World GitHub Issues?](https://arxiv.org/abs/2310.06770). A useful example of moving from small coding problems toward repository-level tasks grounded in real GitHub issues.
>
> - Wei et al. (2024), [Measuring short-form factuality in large language models](https://arxiv.org/abs/2411.04368). Introduces SimpleQA and is a good example of designing an eval around a narrow, explicit capability: short-form factuality.
>
> - Haas et al. (2025), [SimpleQA Verified: A Reliable Factuality Benchmark to Measure Parametric Knowledge](https://arxiv.org/abs/2509.07968). Revisits SimpleQA by filtering noisy labels, reducing redundancy, balancing topics, and improving the grading setup.
>
> - Humanity’s Last Exam (2025), [arXiv:2501.14249](https://arxiv.org/abs/2501.14249). Used in the article as an example of deliberately difficult frontier evaluation.
>
> - Reuel et al. (2024), [BetterBench: Assessing AI Benchmarks, Uncovering Issues, and Establishing Best Practices](https://arxiv.org/abs/2411.12990). A broader look at benchmark quality across design, implementation, documentation, and maintenance.
>
> - Lin et al. (2014), [Microsoft COCO: Common Objects in Context](https://arxiv.org/abs/1405.0312). One of the dataset examples referenced when discussing data quality and annotation.
>
> For the statistical concepts used throughout, useful starting points are confidence intervals, confounding, and Simpson’s paradox. Simpson’s paradox in particular is a useful reminder that an aggregate score can tell a very different story from the groups underneath it.
>
> I also recommend going directly to benchmark datasets, task-level results, evaluation code, and model cards whenever they are available.
