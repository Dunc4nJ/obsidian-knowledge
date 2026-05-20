---
created: 2026-05-20
description: Langfuse Academy's evals primer argues offline evaluation should start with manual review to build intuition for failure modes, then automate only the checks worth running repeatedly using code, LLM judges, or hybrid evaluators graded on precise binary criteria.
source: https://x.com/lotte_verheyden/status/2056754091817361670
type: framework
---

# Langfuse Academy argues offline evaluation starts with manual review and automates only the failure modes worth checking repeatedly

Lotte Verheyden's third Langfuse Academy installment positions offline evaluation as the bridge between an experiment and shipping a change. The piece treats manual review as the irreplaceable foundation — the work that surfaces which failure modes are even worth automating — and gives code-based, LLM-as-judge, and reference-based vs. reference-free evaluators each a job description tied to what they can and cannot see.

## Key Takeaways

- **Manual review is the cold-start mechanism for every evaluator stack, not an optional pre-step** — Verheyden's argument is that reading outputs is what builds the intuition for *what* to automate later; teams that skip straight to automated evaluators "often end up measuring things that don't matter." This mirrors the [[the agent improvement loop is traces enriched with evals and human feedback converted into validated fixes|three-source improvement loop]] where human labels are also the ground truth for calibrating any LLM judge. Manual evaluation is never one-and-done either — it has to keep running to catch new failure modes and recalibrate automated judges as the system drifts.

- **The decision to write an evaluator is the decision that a failure mode generalizes** — a one-time prompt fix doesn't deserve an evaluator; a repeatable, testable failure pattern does. This reframes evaluation infrastructure as a commitment that says "I expect to see this class of bug again," which is the same boundary [[targeted evals shape agent behavior more effectively than large benchmark suites|targeted evals]] draw between behavior-shaping checks and generic benchmarks.

- **The three evaluator types map onto what each one can actually see** — code-based for properties verifiable by deterministic logic (JSON schema, regex matches, SQL executes), LLM-as-judge for properties that require *understanding* language (relevance, tone, summary fidelity), with the explicit warning that judges share blind spots with the application's LLM when the same model family is used for both. The piece insists none of these are interchangeable — each quality you care about gets its own evaluator.

- **Reference-free evaluators are the only ones that can go live in production** — reference-based evaluators always need a golden answer, so they're trapped in the offline loop; reference-free ones (whether code or LLM) can grade unseen production traffic, which is how the offline→online evaluation gradient gets built. This is the architectural reason production monitoring can include eval scores at all rather than just system metrics, extending the case from [[agent production monitoring requires observing inputs and outputs not just system metrics]].

- **Binary scores beat graded scales because they force you to define the boundary** — Verheyden's practical recommendation is pass/fail over 1-5 ratings, because a graded scale leaves "what does a 3 mean vs. a 4" undefined and produces noisy, low-agreement signal. The deeper move here is that defining a binary criterion is itself the work of clarifying what you actually care about — and a vague evaluator gives vague results no matter how sophisticated the underlying model is.

## External Resources

- [Langfuse Academy](https://langfuse.com/academy) — full AI engineering lifecycle curriculum
- [The AI Engineering Loop](https://langfuse.com/academy/ai-engineering-loop) — entry point that frames the entire series
- [Three kinds of evaluation](https://langfuse.com/academy/evaluate#three-kinds-of-evaluation) — manual, code, LLM-as-judge in one comparison
- [Tracing](https://langfuse.com/academy/tracing), [Datasets](https://langfuse.com/academy/datasets), [Experiments](https://langfuse.com/academy/experiments), [Monitoring](https://langfuse.com/academy/monitoring) — companion articles in the Academy series
- Sibling notes in this series: [[Langfuse Academy primer argues tracing is the foundational primitive every step of the agent improvement loop operates on]], [[Langfuse Academy frames eval datasets as production-mirroring test suites where item structure follows from evaluator choice]]

## Original Content

> [!quote]- Source Material: X @lotte_verheyden, May 19 2026 — 395 likes, 35 retweets, 5 replies
>
> **@lotte_verheyden (Lotte):**
>
> *Cover image — eval as the bifurcation point: a single trajectory entering a watching eye, branching into a green checkmark path and a red x path.*
> ![[lotteverheyden-361670-001.jpg]]
>
> **Article: Evals, explained**
>
> This is one piece of a series we're publishing as part of the [Langfuse Academy](https://langfuse.com/academy), where we walk through the full AI engineering lifecycle. If you're new to the series,[The AI Engineering Loop](https://langfuse.com/academy/ai-engineering-loop) is the best place to start.
>
> ## A short recap of the AI Engineering Loop
>
> The AI Engineering Loop is how teams continuously improve AI systems. It connects what's happening in production (tracing, monitoring) to structured iteration during development (datasets, experiments, evaluation). Each shipped improvement produces new data, and teams loop through this process continuously.
>
> You can read more on this [here](https://langfuse.com/academy/ai-engineering-loop).
>
> *The AI Engineering Loop — Evaluate is the final offline stage before deploy feeds back into Trace.*
> ![[lotteverheyden-361670-002.jpg]]
>
> # How evaluation fits into the loop
>
> Offline evaluation is the step in the loop between running an experiment and shipping a change. You have a dataset, you have run your application against it, and now you need to judge whether the outputs are good.
>
> ## How evaluation typically evolves
>
> Most of the time, you start by manually reviewing outputs to build intuition for what good and bad look like in your application. From there, you identify specific failure modes worth checking for. Once you can define them precisely, you automate with dedicated evaluators.
>
> *The three-step evaluation maturity arc: manual review → identify failure modes → automate.*
> ![[lotteverheyden-361670-003.png]]
>
> The rest of this page covers the different kinds of evaluation in detail. In practice, you'll likely end up combining all of them. But the path to a well-functioning automated evaluation setup almost always starts from manual review.
>
> Manual evaluation is not a one-and-done step. Good production setups incorporate continuous review by human experts to catch new failure modes and keep automated evaluators calibrated.
>
> # Evaluation methods
>
> There are three main ways to evaluate: manually, with code, or with an LLM. Each is suited to different kinds of quality checks.
>
> ## Manual evaluation
>
> Manual evaluation is the process of manually looking at outputs and scoring it/writing down your thoughts on its quality.
>
> This is an important process, reading outputs builds an understanding of what your application actually does, where it struggles, and what "good" looks like for your specific use case. That understanding is what tells you which automated evaluators to build and how to define their criteria later on. Teams that skip this step and jump straight to automated evaluation often end up measuring things that don't matter.
>
> Manual evaluation also produces human labels that serve as ground truth for validating automated evaluators later.
>
> ## Code-based evaluation
>
> Code-based evaluators check properties that can be verified with deterministic logic. They are fast, cheap, and produce the same result every time.
>
> Some example checks where code-based evaluators are a natural fit:
>
> - The output is valid JSON or follows a required schema
>
> - The output contains (or does not contain) specific keywords or patterns
>
> - The output stays within a length limit
>
> - The generated SQL executes without errors
>
> Their limitation is that they cannot assess meaning. A code-based evaluator can check that an output contains the word "refund," but it cannot check whether the output correctly explains the refund policy.
>
> ## LLM-as-a-judge
>
> An LLM-as-a-judge evaluator uses a language model to score outputs. It is required to overcome the core issue that quality of AI Applications/Agents depends on grading the quality of a text output.
>
> This is the right method for qualities that require understanding language: whether a response is relevant to the question, whether the tone matches the intended audience, whether a summary captures the key points of the source material, etc.
>
> LLM judges are imperfect and easy to get wrong. This means:
>
> - A model does not automatically grade things as a human expert would as they do not have the context of the expert
>
> - They need calibration against human preferences to verify they are measuring what you think they are measuring
>
> - They can share blind spots with your application's LLM, especially when the same model family is used for both
>
> These limitations aren't reasons to avoid LLM judges. An LLM judge that has been calibrated against human labels and is backed by code-based checks is a reliable evaluator.
>
> # Reference-based vs reference-free evaluators
>
> Both code-based and LLM-as-a-judge evaluators can be either reference-based or reference-free. A reference-based evaluator compares the output against a predefined expected output, like a correct answer or a golden response. A reference-free evaluator assesses the output on its own, without needing a ground truth to compare against.
>
> The advantage of reference-free evaluators is that they can be applied to unseen production data, while reference-based evaluators always need a pre-defined reference response.
>
> *The 2×2 matrix Verheyden uses to place every evaluator: reference-based vs. reference-free × code-based vs. LLM-as-judge/manual.*
> ![[lotteverheyden-361670-004.png]]
>
> # In practice
>
> ## When to set up evaluators
>
> As mentioned above, you always start by manually reviewing. Once you have done that, the question then becomes: should you set up an automated evaluator for what you found?
>
> Ask yourself whether the issue is a one-time fix or a generalization problem. If a simple prompt change resolves it, just make the change, there's no need for an evaluator. But if you can clearly identify a failure mode that you want to test for repeatedly across different inputs, that's when setting up an evaluator makes sense.
>
> ## What should you evaluate?
>
> Generic qualities like "helpfulness" or "quality" are tempting starting points, but they rarely produce useful signal. An evaluator that checks a vague criterion will give vague results. The more precisely you can define what "good" or "bad" looks like for your application, the more useful your evaluators will be.
>
> One practical recommendation: prefer binary scores (pass/fail) over graded scales (1-5) when designing evaluators. Binary scores force a clear definition of what separates acceptable from unacceptable. Graded scales introduce ambiguity about what a 3 means versus a 4, which makes scores harder to interpret and less consistent across evaluators and over time.
>
> ## Combining evaluation methods
>
> Each quality you care about gets its own evaluator.
>
> Most mature evaluation setups use [all three evaluation methods](https://langfuse.com/academy/evaluate#three-kinds-of-evaluation). Together, they give you a view on overall quality of your application.
>
> # Where to start
>
> Start with manual review, then automate only the checks you need to run repeatedly.
>
> 1. [Review outputs manually](https://langfuse.com/academy/evaluate#how-evaluation-typically-evolves) to build intuition for what good and bad look like in your application.
>
> 2. Write down the specific failure modes you want to catch and define them as clearly as possible.
>
> 3. Set up an automated evaluator only when you need to test that failure mode repeatedly across many inputs or over time.
>
> # What comes next
>
> If the results are good enough, you can ship the change. Once it is live, the loop starts again: the updated system produces new [traces](https://langfuse.com/academy/tracing), new [monitoring](https://langfuse.com/academy/monitoring) signals, and new opportunities to improve.
>
> Some evaluators should also move beyond offline experiments. Reference-free evaluators, user feedback signals, and other production-safe checks can be applied to live traffic to confirm that quality in production matches what you saw before deployment.
>
> If production behavior matches expectations, you can keep scaling with more confidence. If it does not, capture those cases in traces, turn them into [dataset](https://langfuse.com/academy/datasets) items, and run the next round of [experiments](https://langfuse.com/academy/experiments). That is how you close the loop.
>
> *Posted Tue May 19 15:09:22 +0000 2026 — [original](https://x.com/lotte_verheyden/status/2056754091817361670)*

### Replies (selected)

> **@Blum_OG (Blum)** — May 19 2026:
> @lotte_verheyden most folks sleep on this and they're missing out - it's a important piece of the AI workflow

> **@DesiRichDev (Dev K)** — May 19 2026:
> @lotte_verheyden skip the manual step and you are automating the wrong thing at scale
> same mistake shows up in every agent build that goes wrong
>
> automate only what you can already judge manually
> everything else is just fast noise

> **@lotte_verheyden (Lotte)** — May 19 2026 *(author self-reply)*:
> @DesiRichDev Exactly

> **@JagReehal (Jag Singh Reehal)** — May 19 2026:
> @lotte_verheyden Nice. Here's my slides from my talk https://t.co/2wo9vI18Ng. Langfuse is brilliant

> **@sisyphus0906 (西西弗斯的AI笔记)** — May 20 2026:
> @lotte_verheyden Cool ai evals May evolves 5 round more exactly

> **@rgvrmdya (RG)** — May 20 2026:
> @lotte_verheyden Great read. Thanks for sharing

---

*Source: [Lotte Verheyden on X](https://x.com/lotte_verheyden/status/2056754091817361670) · Tue May 19 2026 · 395 likes / 35 RTs / 5 replies*
