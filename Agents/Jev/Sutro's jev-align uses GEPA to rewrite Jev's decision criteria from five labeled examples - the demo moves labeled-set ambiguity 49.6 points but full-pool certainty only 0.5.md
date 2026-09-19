---
created: 2026-09-19
description: Sutro's jev-align is an open-source CLI that runs GEPA over a Jev classifier's true/false criteria text, using five human labels drawn by uncertainty sampling per round - the launch demo's own results screen shows the labeled replay set losing 49.6 points of ambiguity while the 1,000-row pool gains 0.5 points of certainty.
source: https://x.com/sethkimmel3/status/2101357768640987302
author: Seth Kimmel (Sutro)
type: knowledge
tags: [jev, jev-align, gepa, calibration, prompt-optimization, sutro, system-one-models]
---

## Key Takeaways

- **jev-align does not touch Jev's weights or its probability calibration. It rewrites three strings.** The on-screen diff at 1:34 makes the mechanism unambiguous: the artifact GEPA mutates is a small JSON object with exactly three keys, `instructions`, `true_criteria`, and `false_criteria`. Before optimization `instructions` reads "Is the hacker news post related to AI?"; after, it is a 60-word paragraph spelling out that physical and web-crawling robots count and that "technology, prediction, risk assessment, or science generally" does not. This is prompt optimization against a decision boundary, not recalibration of the model's output probabilities. The distinction matters because [[TypeSafe's Jev trades string generation for parallel-sampled typed decisions with calibrated probabilities at $0.042 per MTok - the 193x and 444x claims come from four self-built workflow evals|Jev's headline pitch is calibrated probabilities]], and jev-align is moving a different quantity: which side of the line a given post falls on, given a fixed probability head.

- **GEPA works here because the reflection model reads the labeler's free-text rationale, not because it reads a score.** The task looked hard to square with [[GEPA prompt optimizer beats reinforcement learning with 35x fewer rollouts by reflecting on natural-language execution traces|GEPA's reflective loop]] given that Jev emits a probability and no trace. The demo resolves it: the human is the trace generator. Each labeling prompt reads "Rationale (optional, encouraged)" and Seth types fragments like "crawling robots are true", "physical robots -> true", "prison reform has AI assoc". Those strings are the natural-language feedback GEPA reflects on, and they surface almost verbatim in the rewritten criteria. The reflection model is a separate LLM, defaulting to GPT-5.6 Luna. This is the same "static prompt before inference" role [[Quarq Labs frames GEPA and RLM as complementary context layers - GEPA optimizes static prompts before inference while RLM decomposes context at runtime|Quarq Labs assigns to GEPA]], applied to a model that never generates a token.

- **The demo's own numbers separate a large effect on what you labeled from a tiny one on everything else.** The results screen reports both. On the five labeled examples, mean ambiguity falls 84.4% to 34.8%, a 49.6-point drop, and the count scoring above 0.8 ambiguity falls from 4 to 1. On the fixed 1,000-row pool, certainty moves from 87.1% to 87.7%, a gain of 0.5 points, and highly ambiguous rows fall from 12 to 9. GEPA halts with "stopped early: perfect training score", having spent 50 of a 300-call budget. A perfect training score over five labels is what [[dspy-agent-skills shows GEPA only improves when there is failure signal - 1.2B models gain 25 points where 8B+ no-op|the saturation behavior]] predicts: with no remaining failure signal in the minibatch, the optimizer stops. Whether the rewritten criteria generalize is not measured anywhere in the demo, because there is no held-out labeled set to measure against.

- **Uncertainty sampling plus a random audit sample is the label-efficiency trick, and it is a known one.** Each round surfaces five rows: uncertainty samples drawn near the decision boundary (98.0% uncertain, model true probability 49.0%) plus at least one "Random audit sample" (42.0% uncertain, probability 21.0%) to catch drift the boundary-focused sampler would miss. This is active learning, the same annotation-ordering move [[the Error Discovery skill builds a failure-mode taxonomy while you annotate, using active learning to pick the next traces|the Error Discovery skill]] uses for failure taxonomies. The label budget is the sharp contrast with prior work: [[BARGAIN routes classification to a small model via a confidence threshold calibrated on 500 oracle labels, cutting costs up to 86 percent more than competing cascades|BARGAIN calibrates its threshold on 500 oracle labels]] and gets a distribution-free statistical guarantee for it. jev-align asks for five per round and offers no guarantee, trading rigor for a loop you can run in two minutes.

- **The skeptical read is that "calibration" here is a borrowed word doing double duty.** [[jevlike|The jevlike note]] already flagged that Jev's open-source clone computes expected calibration error in its evaluator and publishes no calibration figure. jev-align does not close that gap; it sidesteps it. Nothing in the tool measures whether a Jev output of 0.7 corresponds to 70% empirical accuracy. What it measures is pool certainty, the mean distance of outputs from 0.5, which rises whenever the model is pushed toward confident answers regardless of whether those answers are right. A reply from @shadowaguy names the adjacent problem: GEPA needs a human to define "good", so you encode your judgment before the model learns anything. Seth's framing of jev-align as "last mile optimization or fine-tuning for Jev" is fair on the first half and loose on the second, since no fine-tuning occurs.

## Video Walkthrough

Two minutes nine seconds, screen recording of a terminal with a webcam inset. The narration is thin; the terminal carries the real content. Frame timestamps below.

**The entrypoint is `jeva`, not `jev-align`.** The package is `jev-align` (installed via uv or pip per the narration) but the binary on PATH is `jeva`, visible in both the shell prompt and the window title `~/.local/bin/jeva`. The splash screen bills the tool as "An experiment from sutro.sh" and offers two options: optimize a new AI Function, or show existing ones.

*0:30 - the `jeva` splash and the two-option root menu, with the repo and README links Sutro ships in the banner*
![[sethkimmel3-987302-001.png]]

**Setup is a single wizard pass with four choices.** Jev provider is "TypeSafe AI (direct)". Three example datasets ship in-tree (`hn-stories.csv`, `support-tickets.csv`, `agent-traces.csv`) alongside an "Enter another path" option. The Hacker News file holds 8,018 rows and the default is to use the first 1,000. The task is declared as Question plus Task type plus Columns: "Is the hacker news post related to AI?", Binary (True/False), over `title, text, url`. The GEPA reflection model defaults to GPT-5.6 Luna and is swappable. Each run gets a timestamped directory under `.jev-align/runs/`, here `20260919-162626-844526-is-the-hacker-news-post-related-to-ai`.

*0:48 - the setup wizard, with Round 1 already scoring the pool against typesafe/jev-1.13.0 at the bottom*
![[sethkimmel3-987302-002.png]]

Round 1 scores all 1,000 rows against `typesafe/jev-1.13.0`. The progress bar reads `155/1000 0:00:08` at 0:40 and `950/1000 0:00:01` at 0:48. Read as a countdown, a full pass over 1,000 rows takes roughly ten seconds. That reading is inferred from the two frames, not stated by the narrator.

**Labeling is five rows per round, each with an optional free-text rationale.** Rows are tagged either "Uncertainty sample" or "Random audit sample" and annotated with both an uncertainty percentage and the model's true probability. The pairing is instructive: 98.0% uncertain corresponds to probability 49.0%, and 42.0% uncertain to probability 21.0%, so "uncertainty" is a rescaled distance from 0.5 rather than an independent quantity. Seth's rationales are terse fragments, three to five words. A `/back` command re-does the previous label.

*0:58 - the labeling loop, showing uncertainty and audit samples with the model's true probability beside each*
![[sethkimmel3-987302-003.png]]

**The results screen is where the claim gets tested.** GEPA runs, then reports three tables and a diff.

| Measure | Before | After | Change |
|---|---|---|---|
| Full pool, mean ambiguity | 12.9% | 12.3% | −0.5% |
| Full pool, median ambiguity | 6.0% | 6.0% | +0.0% |
| Full pool, rows ≥0.5 ambiguous | 41 | 39 | −2 |
| Full pool, rows ≥0.8 ambiguous | 12 | 9 | −3 |
| Labeled replay set, mean | 84.4% | 34.8% | −49.6% |
| Labeled replay set, median | 94.0% | 28.0% | −66.0% |
| Pool certainty | 87.1% | 87.7% | +0.5% |

GEPA's halt line reads "GEPA stopped early: perfect training score · 50/300 metric calls". The proposed criteria are then presented as a unified diff and the user accepts, rejects, or quits.

*1:34 - the results tables, the early-stop line, and the AI Function diff showing the three rewritten strings*
![[sethkimmel3-987302-004.png]]

Round 2 opens with 995 of the 1,000 rows still unlabeled, confirming five labels consumed per round, and the loop repeats. A `b` key rewinds to the previous round's labeling.

**State persists across runs as an inventory of AI Functions.** The second menu option lists 24 saved functions, each showing type, source file, rows and labels, accepted optimization count, latest fit, pool certainty, and status. Statuses observed: "Latest proposal accepted", "Decision pending", "Not optimized yet", "Latest proposal rejected". The "Latest fit 1.000 (training labels)" field states plainly that the perfect score is measured on the training labels. All 24 entries in the visible list are runs of the same Hacker News question, so the demo environment is iterations of one task rather than a portfolio of different ones.

*2:02 - the saved AI Function inventory, where "Latest fit 1.000 (training labels)" names what the perfect score is measured on*
![[sethkimmel3-987302-005.png]]

The closing beat: once calibrated, you "decorate future production Jev calls using jev-align", and the tool keeps collecting ambiguous production cases to learn from later.

## Richard Artoul's Framing

Richard Artoul, founder of Archil and the author behind this vault's [[Archil argues local storage is a special case of remote storage - full residency plus writes acknowledged before they are durable|storage-architecture notes]], quote-tweeted the launch ten minutes later and drew 159 likes, comparable to Seth's own 257.

His summary is accurate on mechanism and adds one claim Seth never makes: that Jev is "trained only on synthetic data". That assertion is Artoul's, not Sutro's and not TypeSafe's, and it is not sourced in either the post or the video. TypeSafe has not published Jev's training data. Treat it as an outside observer's belief, not a documented fact.

Artoul's phrasing is otherwise the tightest description of the mechanism anyone in the thread produced: tune an off-the-shelf model "to your exact decision criteria simply by manipulating the prompt and labeling a few examples". Note that he says prompt, not weights, which is exactly right and more precise than Seth's "fine-tuning for Jev" analogy.

## Replies

Sixteen replies at fetch time. Twelve carried substance and are discussed below; four were skipped as pure reaction (@hmartenjoyer's "👀👀", @mitansh_j07 restating the pitch, @Appyg99's "Nice!", and Seth's one-line thanks in response). All sixteen are preserved verbatim in Original Content.

**Nobody from TypeSafe replied.** No @typesafeai account and no Diogo Almeida in the thread. The only TypeSafe-adjacent signal is Seth tagging @LakshyAAAgrawal alongside @hmartenjoyer in a bare reply. Lakshya Agrawal is GEPA's first author, so Seth is pulling in the optimizer's author, not the model's.

**The closest thing to the hard question came from @tpritha03, twice.** "What does a bad example look like in the CLI, a wrong tool pick or a wrong score?" and, later, "What does one bad label look like when you put it in?" That is the right question and it went unanswered in-thread. The video answers it: a label is a True/False choice plus an optional sentence of reasoning, and neither a tool pick nor a score. Nobody asked directly how GEPA applies to a model that emits probabilities rather than text.

**The sharpest pushback was @shadowaguy's.** "Calibration is the polite word for it. The real friction is that GEPA requires human judgment to define 'good.' You are asking the user to encode their bias before the model learns to think." Unanswered by Seth. It is half right: encoding your own decision criteria is the stated purpose rather than a flaw, but the word "calibration" is doing work the tool does not do.

**@EGafni pointed at a parallel system and got the most technically useful reply in the thread.** Seth: "Similar idea - the difference is mostly just bootstrapping from unlabeled vs. coming with labels. The core machinery clearly works in either case!" That places jev-align's contribution precisely: the GEPA-over-criteria machinery is not novel, and the wedge is starting from an unlabeled pool and spending human attention only where the model is uncertain.

**@Shashikant86 reported building the same thing independently**, native GEPA optimization inside SuperQode's SystemOne harness, which suggests GEPA-over-criteria is converging as the standard way to align a System One Model rather than being a Sutro-specific idea.

**@Sahra03352270 asked the deployment question**: is this fast enough to run on the fly for one-off judgments, with a handful of labels on the spot. Unanswered. The video's numbers suggest the scoring pass is fast (seconds for 1,000 rows) but the GEPA step plus five human labels is the bottleneck, so a genuinely on-the-fly variant would need a much smaller pool.

**@ItsCuthulhu linked a separate comparison** of roughly 30 Jev alternatives, claiming none match on speed, accuracy and size. **@Kantorcodes** asked to list jev-align in an awesome-ai-plugins catalog and Seth agreed. **@progress_bureau** offered the aphoristic version: "A model taught your good and bad is worth more to you than a bigger one that never met you."

## Related

The repo itself is captured separately as [[jev-align]]. Jev's own launch analysis is [[TypeSafe's Jev trades string generation for parallel-sampled typed decisions with calibrated probabilities at $0.042 per MTok - the 193x and 444x claims come from four self-built workflow evals]], and the wider map is [[moc - Jev]]. Two community artifacts sit either side of this one: [[jevlike]] reproduces Jev's input/output shape and exposes the missing calibration number, while [[pg-jev]] pushes Jev into a SQL `WHERE` clause, which is exactly the surface jev-align's rewritten criteria would decorate.

On the optimizer: [[GEPA prompt optimizer beats reinforcement learning with 35x fewer rollouts by reflecting on natural-language execution traces]] is the source paper, [[dspy-agent-skills shows GEPA only improves when there is failure signal - 1.2B models gain 25 points where 8B+ no-op]] explains the early stop, [[DSPy is a framework for programming—not prompting—language models through typed signatures and metric-driven optimizers]] is the framework GEPA ships in, and [[Quarq Labs frames GEPA and RLM as complementary context layers - GEPA optimizes static prompts before inference while RLM decomposes context at runtime]] places it in the context stack.

On the method: [[BARGAIN routes classification to a small model via a confidence threshold calibrated on 500 oracle labels, cutting costs up to 86 percent more than competing cascades]] is the statistically rigorous version of the same calibration problem, [[the Error Discovery skill builds a failure-mode taxonomy while you annotate, using active learning to pick the next traces]] is the same active-learning annotation loop pointed at failure modes, and [[Databricks coSTAR closes the agent testing gap with coupled judge-alignment and agent-refinement loops]] is the judge-alignment framing Seth invokes when he says "if you're building something like judges".

## Original Content

> [!quote]- Original Content
> ### Seth Kimmel's post
>
> **@sethkimmel3 (Seth Kimmel)** — Sat Sep 19 17:08:28 +0000 2026 — 257 likes, 28 retweets, 16 replies
> https://x.com/sethkimmel3/status/2101357768640987302
>
> > Jev is cool, but like any foundation model it needs to be calibrated to your decision criteria.
> >
> > We launched jev-align: an open-source CLI to quickly teach Jev what good and bad looks like using GEPA.
> >
> > Try it out! https://t.co/UpvJs53RKm https://t.co/Ou4zA8BLZe
>
> Attached: video, 2:09. Poster frame: https://pbs.twimg.com/amplify_video_thumb/2101357265253212160/img/yMWnsAPk5D4HinBv.jpg
> Link targets: https://github.com/sutro-sh/jev-align and https://x.com/sethkimmel3/status/2101357768640987302/video/1
>
> ---
>
> ### Video transcript (2:09, X auto-captions, 306 words)
>
> Transcribed from X's own English caption track via yt-dlp, not Whisper. The captions are phonetic and mangle several proper nouns: "JEVAline" and "JEVA" are `jev-align` and its `jeva` binary, "JEPA" is GEPA, "UVR pip" is "uv or pip", and "Javelin" at the close is `jev-align`. Reproduced exactly as the caption track has it.
>
> > If you've worked with JEV or other foundation models for zero-shot classification especially if you're building something like judges you've probably noticed that they often don't make the same subjective decisions you would and they still need to be calibrated So we launched JEVAline a super simple CLI that quickly aligns JEV to your judgment You can kind of think of it like last mile optimization or fine-tuning for JEV So just install JEVAline via UVR pip then run JEVA It'll find unlabeled datasets in the directory you're working in CSV, JSONL, and Parquet will all work In this case I'll just use an included hacker news dataset and have JEV decide if posts are related to AI After it processes the first thousand examples it'll surface the most ambiguous cases and some extra randomly sampled ones for auditing I'll give my answers and rationale so it can learn So this will automatically run JEPA which is an automated prompt optimizer and it'll use your feedback to teach JEV how to make decisions like you do We'll see how the ambiguity changes and the new criteria discovers once it's done running So in this case JEPA actually stopped early it got a perfect training score and it discovered a bunch of criteria about how we make decisions on this So I'll pass this into the next iteration and we'll continue learning until we feel that it's calibrated Once you're happy with progress you can decorate future production JEV calls using JEV align It will continue to store ambiguous cases so you can continue learning from new production examples You can also go back into your existing inventory of AI functions to continue teaching them showing the latest optimized prompt or criteria or running it on a new dataset Excited to see what you build with Javelin
>
> ---
>
> ### On-screen text transcribed from the video
>
> Splash and root menu (0:30):
>
> ```
> sethkimmel@Seths-MacBook-Pro-3 jev-align % jeva
>
>                          JEV-ALIGN
>                          jev-align
>
>              An experiment from sutro.sh
>      GitHub   https://github.com/sutro-sh/jev-align
>      README   https://github.com/sutro-sh/jev-align#readme
>
> What would you like to do?
>  > Optimize a new AI Function
>    Show existing AI Functions
> ```
>
> Setup wizard (0:48):
>
> ```
> Create a new AI Function
> Jev provider: TypeSafe AI (direct)
> Choose dataset
>  > Example · Hacker News posts (included)
>    Example · Support tickets (included)
>    Example · Agent traces (included)
>    src/jev_align/sample_data/support-tickets.csv
>    src/jev_align/sample_data/agent-traces.csv
>    src/jev_align/sample_data/hn-stories.csv
>    Enter another path…
> Dataset rows
>  > Use the first 1,000 rows (default)
>    Use all 8,018 rows
>    Select the first N rows
>
> Example setup
>   Example    Hacker News posts
>   Question   Is the hacker news post related to AI?
>   Task       Binary (True/False)
>   Columns    title, text, url
>
> GEPA reflection model
>  > Use GPT-5.6 Luna (default)
>    Choose a different model
> Create this AI Function
>  > Create
>    Advanced
> Run created at /Users/sethkimmel/Desktop/Skysight/Code/jev-align/.jev-align/runs/20260919-162626-844526-is-the-hacker-news-p…
>
> Round 1: 1,000 inputs in the full original pool (1,000 unlabeled), using typesafe/jev-1.13.0…
> TypeSafe JEV · current AI Function  ————————————  950/1000 0:00:01
> ```
>
> Labeling loop (0:58 and 1:12):
>
> ```
> Highly ambiguous (≥80%)   12
> Label 1/5 · Uncertainty sample · 98.0% uncertain · Model true probability 49.0%
>   title  The Twitter Robot and the Eco-System of Robots It Supports
>   text   (empty)
>   url    http://www.digitaldoughnut.com/blog/blog/the-twitter-robot-and-the-eco-system-of-robots-it-supports
> Label
>  > True
>    False
> Rationale (optional, encouraged; /back changes label): crawling robots are true
>
> Label 2/5 · Uncertainty sample · 98.0% uncertain · Model true probability 51.0%
>   title  HitchBOT — A robot exploring the world
>   url    http://m.hitchbot.me/
> Label
>  > True
>    False
> Rationale (optional, encouraged; /back changes label): physical robots -> true
>
> Label 3/5 · Uncertainty sample · 92.0% uncertain · Model true probability 54.0%
>   title  Should Prison Sentences Be Based on Crimes That Haven't Been Committed Yet?
>   url    http://fivethirtyeight.com/features/prison-reform-risk-assessment/
> Label
>    True
>  > False
> Rationale (optional, encouraged; /back changes label): prison reform is not AI
>
> Label 4/5 · Uncertainty sample · 92.0% uncertain · Model true probability 54.0%
>   title  HitchBot: 'Ready for the USA'
>   url    http://www.washingtonpost.com/posttv/business/technology/journey-of-hitchbot-the-hitchhiking-robot-comes-to-tragic-end-in-philadelphia/2015/08/03/1873629a-39e8-11e5-8993-0b783c1d6d37_video.html
> Label
>  > True
>    False
> Rationale (optional, encouraged; /back changes label): robot
>
> Label 5/5 · Random audit sample · 42.0% uncertain · Model true probability 21.0%
>   title  Up in the Air
>   url    http://www.damninteresting.com/up-in-the-air/
> Label
>    True
>  > False
> Rationale (optional, encouraged; /back changes label): Not clearly related
>
> Running GEPA optimization...
> GEPA Optimization:   2%|
> ```
>
> Results screen (1:34):
>
> ```
> [full-pool ambiguity]
> Metric          Current   Proposed   Change
> mean              12.9%      12.3%    -0.5%
> median             6.0%       6.0%    +0.0%
> at_least_0_5         41         39       -2
> at_least_0_8         12          9       -3
>
>                Labeled replay-set ambiguity
> Metric          Current   Proposed   Change
> count                 5          5       +0
> mean              84.4%      34.8%   -49.6%
> median            94.0%      28.0%   -66.0%
> at_least_0_5          4          1       -3
> at_least_0_8          4          1       -3
>
>            Certainty by iteration (fixed 1000-row pool)
> Iteration      Result
> Before 1       [████████████░░░] 87.1% certain
> 1 (proposed)   [████████████░░░] 87.7% certain   +0.5%
>
> GEPA stopped early: perfect training score · 50/300 metric calls
>
> ───────────────────────── AI Function diff ─────────────────────────
> --- current
> +++ proposed
> @@ -1,5 +1,5 @@
>  {
> -  "false_criteria": "AI is absent, merely incidental, or not a meaningful subject of the post.",
> -  "instructions": "Is the hacker news post related to AI?",
> -  "true_criteria": "The post is substantively about artificial intelligence, machine learning, AI models, AI systems, or their development, use, or impact."
> +  "false_criteria": "AI, autonomous systems, or robotics is a meaningful subject of the post. This includes physical robots, software or web-crawling robots, and discussion of their behavior, operation, development, use, or societal impact. Mere incidental mentions, unrelated technology, or topics with no meaningful AI or robotics focus do not qualify.",
> +  "instructions": "Is the Hacker News post related to artificial intelligence in a broad sense? Label true when the post substantially concerns AI, machine learning, robotics, robots (including physical or crawling robots), autonomous or intelligent machines, or systems that perform tasks associated with intelligence. Label false when it is not clearly about these topics, even if it concerns technology, prediction, risk assessment, or science generally.",
> +  "true_criteria": "The post is substantively about artificial intelligence, machine learning, AI models, AI systems, or robots—including physical, software, and web-crawling robots—or about the development, use, behavior, or impact of any of these; incidental or merely metaphorical references do not qualify."
>  }
>
> AI Function decision
>  > Accept
>    Reject
>    Quit
> ```
>
> Round 2 header and the saved-function inventory (1:44 and 2:02):
>
> ```
> Round 2: 1,000 inputs in the full original pool (995 unlabeled), using typesafe/jev-1.13.0…
>                Current fixed-pool uncertainty
> Measure                        Value
> Certainty                      [████████████░░░] 87.7% certain
> Mean uncertainty               12.3%
> Moderately ambiguous (≥50%)    39
> Highly ambiguous (≥80%)        9
> Label 1/5 · Uncertainty sample · 100.0% uncertain · Model true probability 50.0%
>   title  Search and Rescue for Sale
>   url    http://www.wired.com/2015/08/search-and-rescue-for-sale/
> Press b to rewind to round 1 labeling.
>
> ---
>
> Show existing AI Functions
> AI Functions  1/24  (↑/↓ scroll, Enter open, q quit)
> ───────────────── Is the hacker news post related to AI? ─────────────────
>   Type            Binary (True/False)
>   Source          hn-stories.csv
>   Data            1,000 rows · 5 labeled
>   Progress        1 accepted optimization(s)
>   Latest fit      1.000 (training labels)
>   Pool certainty  87.7%
>   Status          Latest proposal accepted
> ──────── 20260919-162626-844526-is-the-hacker-news-post-related-to-ai ────────
>   Data            1,000 rows · 5 labeled
>   Progress        0 accepted optimization(s)
>   Pool certainty  87.1%
>   Status          Decision pending
> ──────── 20260919-161511-865927-is-the-hacker-news-post-related-to-ai ────────
>   Data            1,000 rows · 0 labeled
>   Progress        0 accepted optimization(s)
>   Status          Not optimized yet
> ──────── 20260919-161356-993998-is-the-hacker-news-post-related-to-ai ────────
>   Data            1,000 rows · 5 labeled
>   Progress        0 accepted optimization(s)
>   Pool certainty  87.1%
>   Status          Latest proposal rejected
> ──────── 20260919-052454-760248-is-the-hacker-news-post-related-to-ai ────────
> ↓ 20 older
> ```
>
> ---
>
> ### Richard Artoul's quote tweet
>
> **@richardartoul (Richard Artoul)** — Sat Sep 19 17:18:50 +0000 2026 — 159 likes, 9 retweets, 0 replies
> https://x.com/richardartoul/status/2101360378047287645
>
> > cool demo on how to use GEPA to take an off the shelf model like Jev (trained only on synthetic data) and tune it to your exact decision criteria simply by manipulating the prompt and labeling a few examples
> >
> > you should follow Seth, he's way ahead of the curve on AI functions
> >
> > QT @sethkimmel3: Jev is cool, but like any foundation model it needs to be calibrated to your decision criteria.
> > We launched jev-align: an open-source CLI to quickly teach Jev what good and bad looks like using GEPA.
> > https://x.com/sethkimmel3/status/2101357768640987302
>
> ---
>
> ### Replies to Seth's post (all 16, in thread order)
>
> **@progress_bureau (ProgressBureau)** — Sat Sep 19 17:10:27 +0000 2026
> https://x.com/progress_bureau/status/2101358268668907805
>
> > @sethkimmel3 A model taught your good and bad is worth more to you than a bigger one that never met you.
>
> **@sethkimmel3 (Seth Kimmel)** — Sat Sep 19 17:18:01 +0000 2026
> https://x.com/sethkimmel3/status/2101360174959370245
>
> > @hmartenjoyer @LakshyAAAgrawal
>
> **@hmartenjoyer (Dae)** — Sat Sep 19 17:19:45 +0000 2026
> https://x.com/hmartenjoyer/status/2101360608520335664
>
> > @sethkimmel3 👀👀
>
> **@mitansh_j07 (Mitansh)** — Sat Sep 19 17:21:28 +0000 2026
> https://x.com/mitansh_j07/status/2101361043997946014
>
> > @sethkimmel3 jev-align as an open-source cli is a clean idea
> > teaching the model good vs bad with gepa sounds useful
>
> **@EGafni (Erik Spock Gafni)** — Sat Sep 19 17:42:10 +0000 2026
> https://x.com/EGafni/status/2101366252350693785
>
> > @sethkimmel3 check out our autoresearch cookbook!
>
> **@sethkimmel3 (Seth Kimmel)** — Sat Sep 19 17:48:40 +0000 2026
> https://x.com/sethkimmel3/status/2101367887210709268
>
> > @EGafni Similar idea - the difference is mostly just bootstrapping from unlabeled vs. coming with labels. The core machinery clearly works in either case!
>
> **@Kantorcodes (Kantorcodes | ℏol/acc)** — Sat Sep 19 18:25:39 +0000 2026
> https://x.com/Kantorcodes/status/2101377193423077639
>
> > @sethkimmel3 jev-align looks like a strong fit for our awesome-ai-plugins catalog as a developer workflow tool around Jev and GEPA. Would you be open to adding it yourself? If yes, I can point you to the exact section and entry shape.
>
> **@tpritha03 (Tanisha Pritha)** — Sat Sep 19 19:12:06 +0000 2026
> https://x.com/tpritha03/status/2101388882852159728
>
> > @sethkimmel3 jev-align teaches Jev good and bad with GEPA. What does a bad example look like in the CLI, a wrong tool pick or a wrong score?
>
> **@sethkimmel3 (Seth Kimmel)** — Sat Sep 19 19:18:15 +0000 2026
> https://x.com/sethkimmel3/status/2101390430315389434
>
> > @Kantorcodes sure - happy to add it!
>
> **@ItsCuthulhu (Cuth)** — Sat Sep 19 19:33:06 +0000 2026
> https://x.com/ItsCuthulhu/status/2101394168882893032
>
> > @sethkimmel3 https://t.co/BKOUZN5Des
> >
> > QT @ItsCuthulhu: Which Jev alternative is best?
> > __
> > Right now, I'm comparing 30 Jev alternatives to the real deal... So far, none have come close when it comes to speed, accuracy and size.
> > PHOTO: https://pbs.twimg.com/media/HSmc_M6XoAAb7YF.jpg
> > PHOTO: https://pbs.twimg.com/media/HSmdCLLW8AA1bo7.jpg
> > https://x.com/ItsCuthulhu/status/2101387385871470637
>
> **@Appyg99 (Apoorva Govind)** — Sat Sep 19 19:38:41 +0000 2026
> https://x.com/Appyg99/status/2101395572691472542
>
> > @sethkimmel3 Nice! Was looking for something like this
>
> **@sethkimmel3 (Seth Kimmel)** — Sat Sep 19 19:53:08 +0000 2026
> https://x.com/sethkimmel3/status/2101399210746888668
>
> > @Appyg99 Cool! Would love feedback when you try it :)
>
> **@Shashikant86 (Shashi)** — Sat Sep 19 19:55:41 +0000 2026
> https://x.com/Shashikant86/status/2101399850600276075
>
> > @sethkimmel3 You beat me to this, I am in the middle of  the launch native GEPA optimization in SuperQode's SystemOne harness. jev-align looks cool and lots to learn from it.
>
> **@shadowaguy (ShadowAguy)** — Sat Sep 19 20:10:49 +0000 2026
> https://x.com/shadowaguy/status/2101403658974032149
>
> > @sethkimmel3 Calibration is the polite word for it. The real friction is that GEPA requires human judgment to define 'good.' You are asking the user to encode their bias before the model learns to think.
>
> **@tpritha03 (Tanisha Pritha)** — Sat Sep 19 20:41:02 +0000 2026
> https://x.com/tpritha03/status/2101411265797382568
>
> > @sethkimmel3 A CLI to teach Jev good and bad. That is more useful than another chat box. What does one bad label look like when you put it in?
>
> **@Sahra03352270 (Sahra)** — Sat Sep 19 20:51:21 +0000 2026
> https://x.com/Sahra03352270/status/2101413862683668710
>
> > @sethkimmel3 interesting.. u think this is fast enough to be done on-the-fly?
> >
> > for those sorta 1 off efforts. like.. "is this description good [in the context of this  specific website we are building]
> >
> > would it be useful to do just a handful of labels on the spot to improve accuracy?

## Links

- [Seth Kimmel's launch post](https://x.com/sethkimmel3/status/2101357768640987302) — the primary source, with the 2:09 demo video attached
- [The attached video](https://x.com/sethkimmel3/status/2101357768640987302/video/1) — direct video URL
- [Richard Artoul's quote tweet](https://x.com/richardartoul/status/2101360378047287645) — the framing QT
- [sutro-sh/jev-align](https://github.com/sutro-sh/jev-align) — the open-source CLI, billed in its own splash screen as "An experiment from sutro.sh"
- [sutro.sh](https://sutro.sh/) — Sutro, Seth Kimmel's company
- [GEPA](https://github.com/gepa-ai/gepa) — the reflective prompt optimizer jev-align wraps
