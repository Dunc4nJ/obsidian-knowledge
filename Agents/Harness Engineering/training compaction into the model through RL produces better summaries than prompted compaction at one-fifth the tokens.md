---
created: 2026-03-18
description: Cursor trains Composer to self-summarize through reinforcement learning with compaction-in-the-loop, producing summaries that are 5x more token-efficient than prompted baselines while reducing compaction error by 50%, enabling 170+ turn coding sessions.
source: https://cursor.com/blog/self-summarization
type: learning
---

# Training compaction into the model through RL produces better summaries than prompted compaction at one-fifth the tokens

## Key Takeaways

This is a significant evolution in the compaction story. Most of the vault's existing notes on compaction treat it as a harness-level concern — something the scaffolding does *to* the model's context when it gets too long. Cursor's approach inverts this: make compaction a *trained behavior* of the model itself, so the model learns what information matters through reward signal rather than through prompted instructions.

The mechanism is elegant: during RL training, when the model hits a token-length trigger, it pauses to summarize its own context before continuing. The final reward applies to all tokens in the chain — both the agent actions and the self-summaries. Good summaries that preserve critical information get upweighted; lossy summaries that cause downstream failures get downweighted. The model learns contextually what to keep and what to discard.

The results are striking. Compared to a "highly tuned prompt-based compaction baseline" with thousand-token prompts and 5,000+ token outputs, Composer's trained self-summarization uses a near-trivial prompt ("Please summarize the conversation"), produces ~1,000 token summaries, and still reduces compaction error by 50%. This directly challenges the assumption in [[autonomous context compression lets agents choose when to compact rather than hitting fixed token limits]] that the key innovation is *when* to compact — Cursor's finding suggests *how* the model compacts (trained vs prompted) matters even more.

The practical implications for [[structured compaction and CLAUDE.md hierarchy prevent context drift in million-token agent sessions|long-running agent sessions]] are substantial. The Doom-for-MIPS case study shows Composer working 170 turns, self-summarizing 100,000+ tokens down to ~1,000, and still solving a problem that "several powerful models are unable to get correct." That's a concrete demonstration that trained compaction preserves task-relevant information far better than the prompted approaches most harnesses currently use.

This also connects to the broader harness engineering thesis in [[the harness is everything and agent performance comes from environment design not model capability]] — but with an interesting twist. Cursor's approach blurs the line between "model capability" and "harness design" by training the harness behavior (compaction) directly into the model weights. The model becomes its own harness for the compaction step.

One open question: this approach requires training the model specifically for a particular harness configuration (the compaction trigger point, the summary format, the conversation state structure). It's not clear how well this transfers to different agent harnesses or whether each harness needs its own fine-tuned compaction behavior.

## External Resources

- [CursorBench](https://cursor.com/blog/cursorbench) — Cursor's internal benchmark suite for evaluating coding agents
- [Terminal-Bench 2.0: make-doom-for-mips](https://www.tbench.ai/benchmarks/terminal-bench-2/make-doom-for-mips) — the 170-turn challenge problem Composer solved
- [Latent space compaction research (arXiv:2602.16284)](https://arxiv.org/abs/2602.16284) — alternative approach compacting in latent space rather than text
- [Latent space compaction research (arXiv:2506.06266)](https://arxiv.org/abs/2506.06266) — another latent-space approach

## Original Content

> [!quote]- Source Material
>
> *Cursor Blog — Training Composer for longer horizons*
>
> We train Composer for long-horizon tasks through a reinforcement learning process called self-summarization. By making self-summarization part of Composer's training, we can get training signal from trajectories much longer than the model's max context window. This translates into Composer being able to learn to work on challenging coding tasks requiring hundreds of actions.
>
> ## The limits of compaction techniques
>
> In [CursorBench](https://cursor.com/blog/cursorbench), our internal benchmark suite, we observe that better performance on challenging real-world coding tasks is directly correlated with more thinking and codebase exploration. As users work with agents to take on harder and more ambitious tasks, we expect the returns on thinking and exploration to increase further.
>
> A primary challenge, though, is that agent trajectories are expanding faster than the context length of models. Many agent harnesses attempt to get around this by using compaction as an intermediate step in the agent's workflow. When an agent hits its context limit, the harness transforms the context to a shorter length and continues the agent's generation where it left off.
>
> In practice, compaction is typically handled by the harness in one of two ways: either in text space through a prompted summarization model, or through a sliding context window where the model drops older context. Researchers have also begun to explore compaction methods in [latent](https://arxiv.org/abs/2602.16284) [space](https://arxiv.org/abs/2506.06266), where the model remembers context as vectors rather than text, although currently these approaches are much slower than text-based methods.
>
> These approaches to compaction share the downside that they can cause the model to forget critical information from the context, reducing its efficacy as it advances through long-running tasks.
>
> ## Self-summarization as a trained behavior
>
> *The self-summarization compaction-in-the-loop training process:*
> ![[cursor-self-summarization-001.png]]
>
> Composer is a specialized model designed for agentic coding and trained through reinforcement learning in the Cursor agent harness. This enables it to be trained with compaction-in-the-loop, improving its ability to determine the most critical information to summarize and preserve.
>
> As Composer works through a task, it approaches a fixed context-length trigger, where it pauses to summarize its own context before continuing. More precisely, the self-summarization process works like this:
>
> 1. Composer generates from a prompt until a fixed token-length trigger is reached.
> 2. We insert a synthetic query asking the model to summarize the current context.
> 3. The model is given scratch space to think about the best summary and then generates a condensed context.
> 4. Composer loops back to step 1 with the condensed context, which includes the summary plus conversation state (plan state, remaining tasks, number of prior summarizations, etc).
>
> To enable Composer to do this well at inference time, we incorporate the same summarization procedure into training. Each training rollout can involve multiple generations chained together by summaries, rather than a single prompt–response pair. This means the self-summaries themselves are part of what gets rewarded.
>
> From a technical perspective, this does not require significant changes to training. We use the final reward for all tokens produced by the model in the chain. This upweights both the agent responses in good trajectories, and also the self-summarizations that made them work. At the same time, poor summaries that lost critical information are downweighted. As Composer trains, it learns to use this self-summary process to build longer context. For hard examples, it often self-summarizes multiple times.
>
> ## Token-efficient compaction
>
> To test self-summarization, we compare it with a highly tuned prompt-based compaction baseline. We study the problem on a set of hard software engineering tasks while varying the compaction trigger.
>
> In the baseline compaction approach, the summarization prompt is thousands of tokens and includes nearly a dozen carefully worded sections describing the content that should be preserved in summary. The output compacted context is also on average more than 5,000 tokens and contains many structured sections describing critical information from the context.
>
> In contrast, since Composer is trained to self-summarize, it requires a very short prompt which contains not much more content than, "Please summarize the conversation". The summaries it outputs are on average only around 1,000 tokens since it learns contextually to decide on the high-value information to retain.
>
> We test Composer in two context-constrained test environments to measure the impact of self-summary, one with an 80k token trigger and another with a 40k trigger (meaning more frequent summaries). In both scenarios, self-summary produces significantly better results on CursorBench with much more token-efficient compactions. Self-summary consistently reduces the error from compaction by 50%, even compared to the targeted baseline approach, while using one-fifth of the tokens and reusing the KV cache (the stored intermediate computations from prior tokens).
>
> *CursorBench performance comparison — self-summarization vs prompted compaction:*
> ![[cursor-self-summarization-002.png]]
>
> ## Solving hard problems
>
> The larger promise of compaction is to allow models to one-shot hard problems that require long reasoning chains. In our current training of Composer 2, we often see this happen. As a case study, we consider a problem from Terminal-Bench 2.0 known as [**make-doom-for-mips**](https://www.tbench.ai/benchmarks/terminal-bench-2/make-doom-for-mips). The problem is as concise as it is challenging:
>
> > I have provided /app/doomgeneric/, the source code to doom. I've also wrote a special doomgeneric_img.c that I want you to use which will write each drawn frame to /tmp/frame.bmp. I've finally provided vm.js that will expect a file called doomgeneric_mips and will run it. Please figure out the rest…
>
> While easy enough to describe, this problem is challenging enough that several powerful models are unable to get it correct in the official reported numbers.
>
> When testing an early research checkpoint of Composer, we found that it was able to solve this problem correctly. The solution required engineering and testing a significant amount of code, as well as exploring some alternative implementations. Here's an image rendered in the course of solving the problem:
>
> *Doom rendered on MIPS — the result of Composer's 170-turn solution:*
> ![[cursor-self-summarization-003.png]]
>
> All in all, Composer worked for 170 turns to find an exact solution, along the way creating self-summaries in a compact, human-readable and structured form. It self-summarized more than 100,000 tokens down to the 1,000 it believed would most help it solve the problem.
>
> ## Toward a long-horizon future
>
> By folding compaction into the training loop, Composer learns an explicit mechanism for efficiently carrying critical information forward, and becomes more capable at challenging tasks. Our work on self-summarization is a step toward our broader goal of training Composer over even longer, more complex processes such as multi-agent coordination. We continue to see better model training as improving the scope and intelligence of these agentic systems.
>
> We'll also be sharing more about the next version of Composer shortly.

[Original source](https://cursor.com/blog/self-summarization)
