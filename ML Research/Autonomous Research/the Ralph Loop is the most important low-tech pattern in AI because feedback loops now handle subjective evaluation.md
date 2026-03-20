---
created: 2026-03-20
description: John Ennis argues that the Ralph Loop (try, evaluate, feed back, repeat) is the foundational pattern of AI-native work because generative AI expanded evaluation to subjective and multimodal judgments, enabling unsupervised loops on nearly any kind of work.
source: https://x.com/johnennis/status/2034300044212351114
type: framework
---

## Key Takeaways

The Ralph Loop — try, evaluate, feed back, repeat — originated from Geoffrey Huntley's Factorio sessions where his son pointed out the obvious automation opportunity. The pattern went viral because it captured something fundamental: non-deterministic AI converges when you keep iterating, and a "dumb, stubborn loop beats over-engineered sophistication." This is exactly the same insight behind [[autoresearch lets an AI agent run ML experiments autonomously overnight|Karpathy's autoresearch]], which ran 700 experiments and found 20 real improvements through pure iteration.

The key unlock isn't the loop itself (feedback loops are ancient) but that generative AI expanded what computers can evaluate. Before LLMs, automated evaluation was limited to numbers, strings, and file comparisons. Now AI can judge persuasiveness, visual hierarchy, tone, and user confusion — meaning the loop can run on almost any work, not just code. This directly connects to why [[agent-first engineering replaces coding with environment design scaffolding and feedback loops|harness engineering]] focuses on environment design over code: the evaluation step is the bottleneck, and AI just removed it.

Ennis introduces the "human sandwich" model: humans specify problems on the front end and review output on the back end, while AI runs loops in the middle — often overnight. This reframes productive work hours as bookends around autonomous execution. The pattern matches what [[autoresearch agents exploit unconstrained metrics and need multi-objective gates with regular human steering|practitioners have found]]: the human's irreplaceable role is choosing what to optimize and catching when the loop is optimizing the wrong thing.

Managers adapt to AI faster than individual contributors because delegation is already an iterative feedback loop. People without management experience treat AI like a vending machine (accept/reject) rather than engaging in multi-round refinement. This has implications for how organizations should train AI adoption — teaching delegation skills rather than prompt engineering.

The loop needs infrastructure to run unsupervised: a survival guide, execution log, kickoff prompt, and test gates. Without these, agents lose context, drift, or confidently do wrong work for hours. This is the same [[agent-harness components can be derived from first principles by working backwards from desired agent behavior|harness engineering pattern]] — the documents aren't overhead, they're minimum viable infrastructure for autonomous operation.

## External Resources

- [The Shoemaker's Elves](https://x.com/johnennis/status/2025904571311141215) — First article in the series, making the case for off-hours as a productive resource
- [The Survival Guide](https://x.com/johnennis/status/2028960113646604794) — Second article, providing the system for keeping agents on track during long unsupervised runs
- [autoresearch by Andrej Karpathy](https://github.com/karpathy/autoresearch) — The Ralph Loop applied to ML research: agent modifies training scripts, runs experiments, keeps improvements

## Original Content

> @johnennis — 2026-03-18
>
> **Article: Water the Tree**
>
> In Norse mythology, three women called the Norns sit at the base of the world tree. Every day a serpent gnaws at the roots. Every day the Norns pour water over them so the tree keeps growing. The tree doesn't survive because of any single watering. It survives because the loop never stops.
>
> That turns out to be the most important idea in AI.
>
> Most people treat AI like a one-time fix. You type a prompt, you get an answer, and the answer is either right or wrong. If it is wrong, the tool is broken.
>
> This is binary thinking. It's the main reason most people are disappointed by AI.
>
> AI doesn't return correct or incorrect answers. It returns first drafts. Sometimes the first draft is excellent. Sometimes it is rough. But judging AI on its first attempt is like judging a tree by its first day of growth. You are measuring the wrong thing.
>
> The people who get extraordinary results from AI aren't the ones writing better prompts. They are the ones running better loops.
>
> ## The Loop Has a Name
>
> In early 2025, an Australian developer named Geoffrey Huntley was playing Factorio with his young son while running repetitive AI coding tasks on a second screen. His son watched him copy output, paste it back in, check the result, and do it again. Eventually the kid pointed out that his dad seemed to be doing the same thing over and over by hand, and asked why he didn't just put it in a loop.
>
> So he did. The simplest possible version: a bash one-liner that feeds a prompt to an AI agent, checks the result, and feeds it back, forever. He called it the Ralph Loop, partly after Ralph Wiggum from The Simpsons, the character who is relentlessly persistent despite constant failure, and partly because the implications of what he had just built made him want to ralph.
>
> The technique went viral. By 2026 it was being called the most important low-tech pattern in AI-native engineering. People used it to build entire programming languages overnight for a few hundred dollars in API costs. The core insight was almost embarrassingly simple: a dumb, stubborn loop beats over-engineered sophistication because AI is non-deterministic. Any single attempt might fail. But if you keep trying, checking, and feeding back, the process converges.
>
> The Ralph Loop has four steps. Define what you want. Let the AI try. Evaluate what it produced. Feed the evaluation back and let it try again.
>
> That's it. Try, check, feed back, repeat. Water the tree.
>
> The first attempt might be 60% of what you need. After feedback, the second attempt is 80%. By the third or fourth pass, you are at 95% and closing in on done. The total time spent is a fraction of what it would take to do the work yourself from scratch, and the quality is often higher because the AI explored options you wouldn't have considered.
>
> ## Why This Matters Now
>
> Most people in the developer community think of the Ralph Loop as a coding technique. It's much more general than that, and most people haven't yet understood why.
>
> Feedback loops aren't new. Automated testing has existed for decades. What changed is the range of what a computer can now take as input and produce as output. Before generative AI, a program could evaluate numbers, check strings, and compare files. The loop could only run on things a computer could judge, which meant it needed humans in the evaluation step for anything subjective or complex.
>
> Generative AI blew the doors off that constraint. The range of possible inputs and outputs within computer programs has expanded to include text, images, video, audio, and even value judgments. An AI can now read a document and tell you whether it is persuasive. It can watch a video and tell you whether the user looked confused. It can listen to audio and assess tone. It can look at a design and judge whether the visual hierarchy is clear.
>
> This is the big unlock. The Ralph Loop isn't new because the loop is new. It's new because the evaluation step can now handle things that used to require a human sitting in the chair. That means the loop can run on almost any kind of work, not just code. And that means it can run while you sleep.
>
> ## Why Managers Are Better at This Than Everyone Else
>
> There is an interesting pattern. People with management experience tend to pick up AI faster than people who have only worked as individual contributors.
>
> The reason is simple. Managers already know how to delegate iteratively. They give someone a task, review the output, provide feedback, and send them back to revise. They do this all day, every day. It's the core skill of management.
>
> When those same people sit down with an AI, they naturally fall into the same rhythm. They give a task, check the result, say what is wrong, and let the AI try again. They don't expect perfection on the first pass because they have never expected perfection on the first pass from anyone.
>
> People without that experience tend to treat AI like a vending machine. Put in a request, get a result, accept or reject. When the result isn't quite right, they conclude the machine is broken rather than engaging with it.
>
> The future of work isn't about becoming a better prompter. It's about becoming a better manager. Everyone's job is moving in that direction whether they realize it or not.
>
> ## The Human Sandwich
>
> Here is where the Ralph Loop leads once you take it seriously.
>
> The shape of productive work is changing. It used to be that a human did most of the work in the middle, the actual building, writing, analyzing, coding. That middle is shifting to AI. What remains on either side is where humans add the most value.
>
> On the front end, the human decides what is worth working on and specifies the problem fully. What are we trying to accomplish? What does success look like? What are the constraints? This is the hardest part of any project and it is entirely human. No AI can tell you what matters. That's your job.
>
> On the back end, the human reviews the output. The AI got it 90 or 95% right. The human catches the remaining issues, provides the final judgment, signs off. This is the part that requires taste, context, and accountability.
>
> In the middle, the AI runs Ralph Loops. It tries, evaluates, adjusts, and tries again, cycling through iterations until the work converges on something good. And because the AI doesn't need you watching over its shoulder for this part, most of the middle happens outside of business hours.
>
> This is the fundamental shift. The majority of productive work will happen while you are asleep, eating dinner, or spending time with your family. Your working hours become the bread of the sandwich: morning for specifying problems and reviewing last night's output, afternoon for setting up the next run.
>
> ## The Loop Needs a Harness
>
> A single Ralph Loop in a chat window is useful. But the real power comes when you let the loop run for hours without supervision.
>
> This creates a problem. AI agents lose context. They hit memory limits and restart. They drift. They forget what they were doing and start over, or worse, they confidently do the wrong thing for six hours while you sleep.
>
> The fix isn't a smarter agent. The fix is a better harness.
>
> In previous articles in this series, I described the specific infrastructure that makes long-running loops work: a Survival Guide that tells the agent what it is doing, what it must not do, and what to work on next. An Execution Log where the agent records its progress so it can recover after a restart. A kickoff prompt that grants autonomy and sets clear boundaries. Test gates that tell the agent whether its work is actually correct before it moves on.
>
> These documents aren't overhead. They are the minimum viable infrastructure for the Ralph Loop to run unsupervised. Without them, the loop breaks down after the first context reset. With them, an agent can run productive Ralph Loops all night long, producing batches of real work that are waiting for your review in the morning.
>
> ## The Pattern Shows Up Everywhere
>
> The pattern isn't limited to coding. Everything AI does well turns out to follow this structure. But notice what the loop doesn't do. It doesn't decide what problem to work on. It doesn't know which metric matters. It doesn't have taste. Those stay with you.
>
> Andrej Karpathy released a project called autoresearch in early March 2026. It's the Ralph Loop applied to machine learning research. An AI agent takes a training script, a single GPU, and a fixed five-minute compute budget per experiment. It reads the code, forms a hypothesis, modifies the training script, runs the experiment, checks whether the validation metric improved, keeps or discards the change, commits to git, and loops. A two-day run produced around 700 experiments and discovered roughly 20 real improvements that Karpathy said outperformed his months of manual tuning. When those improvements were applied to a larger model, they yielded an 11% speedup.
>
> Shopify's CEO ran autoresearch overnight on internal models and got a 19% performance gain from 37 experiments. He didn't write code. He wrote instructions.
>
> The human's role in autoresearch is the sandwich. You write a document called program.md that tells the agent what to fix, what to leave alone, what metric to optimize, and what to try. Then you go to sleep. In the morning, you review the results and decide which findings to promote to larger-scale runs. Karpathy described what happened: the role of the human moves from experimenter to experimental designer. The work still gets done. The human just operates on both ends of it instead of in the middle.
>
> Google's Gemini models open up another dimension of the loop. Gemini processes images, video, and audio natively, not as an add-on but as part of how the model thinks. This means you can build Ralph Loops where the evaluation step involves watching video, analyzing images, or listening to audio, things that until recently required a human in the loop.
>
> Here is a concrete example. I was building an app and needed to test the user experience across different personas. I set up target personas with specific goals, then used Playwright and browser automation to let Gemini act as each persona. Gemini would open the app, try to accomplish the persona's goals, and vocalize what it was thinking at each step. The session was recorded on video with a timestamped transcript of Gemini's reasoning.
>
> When the session was done, I fed the video and transcript into Gemini for evaluation. What worked? What confused the user? Where did they get stuck? That feedback went to a coding agent who changed the app. Then the loop ran again with a new simulated interview on the updated app.
>
> Over many rounds, the app got substantially better. Each loop caught real UX problems that would have taken weeks of human user testing to surface. And because the evaluation was multimodal, the AI caught things that pure text analysis would miss: layout confusion, unclear visual hierarchy, moments where the user hesitated because the interface didn't make the next step obvious.
>
> The Ralph Loop turned a process that normally requires recruiting participants, scheduling sessions, and manually analyzing recordings into something that runs overnight and produces actionable results by morning.
>
> ## The Job That Remains
>
> There is a question underneath all of this that people are starting to ask. If the AI does the work in the middle, what's left for humans?
>
> The answer is: the parts that matter most.
>
> The Ralph Loop is powerful but it isn't self-directing. It can't decide what problem is worth solving. It can't tell you whether the metric it is optimizing is the right metric. It can't look at a finished product and say whether it actually matters to anyone. Those judgments require context, priorities, taste, and values. They are yours and they aren't going anywhere.
>
> This is the part of the myth that matters most. The Norns aren't the water. They aren't the roots. They are the ones who look at the tree, judge what it needs, and decide where to pour. The tree does the growing. The Norns do the knowing.
>
> The same split is happening now. The people who will thrive are the ones who can do two things well. First, specify problems with enough clarity and precision that a Ralph Loop can run productively against them. Second, evaluate output with enough taste and judgment to know when the loop has converged on something good versus something that merely looks finished.
>
> These aren't technical skills. They are thinking skills. And they are the skills that will define the future of professional work.
>
> ## What to Do Now
>
> Start small. The next time you use an AI and the first result isn't quite right, don't give up on it. Tell it what is wrong. Be specific. Let it try again. Do this three or four times and notice how much better the output gets compared to the first attempt.
>
> Then start thinking bigger. What tasks in your work would benefit from dozens of iterations instead of three or four? What would you do with the results of 100 experiments run overnight? What problems would you solve if the evaluation step could include video and images, not just text?
>
> Build the habit of the loop first. Build the harness second. Then let it run while you sleep.
>
> The serpent never stops gnawing. The Norns never stop pouring.
>
> The work will be there in the morning.
>
> This is part of a series on the future of AI work. The first article, [The Shoemaker's Elves](https://x.com/johnennis/status/2025904571311141215), made the case for treating your off-hours as a productive resource. The second, [The Survival Guide](https://x.com/johnennis/status/2028960113646604794), provided the system for keeping agents on track during long unsupervised runs. This article introduces the core pattern that makes it all work.
>
> *Water the Tree — article header*
> ![[johnennis-351114-001.jpg]]
>
> Engagement: 36 likes | 1 retweets | 2 replies
> [Original post](https://x.com/johnennis/status/2034300044212351114)
