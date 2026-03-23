---
tags:
  - self-improving-ai
  - hyperagents
  - darwin-godel-machine
  - meta-learning
  - open-ended-search
source: https://x.com/jennyzhangzt/status/2036099937713455405
paper: https://arxiv.org/abs/2603.19461
code: https://github.com/facebookresearch/Hyperagents
author: Jenny Zhang (@jennyzhangzt)
date: 2026-03-23
---

## Summary

Hyperagents are **self-referential agents that modify both their task-solving behavior and the process that generates future improvements** — enabling metacognitive self-modification: learning not just to perform better, but to improve at improving.

Key insights:
- The Darwin Gödel Machine (DGM) showed open-ended self-improvement is possible, but relies on alignment between the evaluation task and self-modification task (works for coding, breaks elsewhere)
- **DGM-Hyperagents (DGM-H)** extends DGM by making both the task agent and meta agent into a single editable program — the self-improvement mechanism itself can evolve
- Across coding, paper review, robotics reward design, and Olympiad math grading, DGM-H continuously improves and outperforms baselines including the original DGM
- The system autonomously innovates **persistent memory** — storing synthesized insights, causal hypotheses, and forward-looking plans that accumulate across iterations
- Meta-level improvements **transfer across domains and compound across runs** — initializing from a transferred hyperagent leads to faster progress and higher final performance

---

## Thread

### Introducing Hyperagents

Introducing Hyperagents: an AI system that not only improves at solving tasks, but also improves how it improves itself.

The Darwin Gödel Machine (DGM) demonstrated that open-ended self-improvement is possible by iteratively generating and evaluating improved agents, yet it relies on a key assumption: that improvements in task performance (e.g., coding ability) translate into improvements in the self-improvement process itself. This alignment holds in coding, where both evaluation and modification are expressed in the same domain, but breaks down more generally. As a result, prior systems remain constrained by fixed, handcrafted meta-level procedures that do not themselves evolve.

We introduce Hyperagents – self-referential agents that can modify both their task-solving behavior and the process that generates future improvements. This enables what we call metacognitive self-modification: learning not just to perform better, but to improve at improving.

We instantiate this framework as DGM-Hyperagents (DGM-H), an extension of the DGM in which both task-solving behavior and the self-improvement procedure are editable and subject to evolution. Across diverse domains (coding, paper review, robotics reward design, and Olympiad-level math solution grading), hyperagents enable continuous performance improvements over time and outperform baselines without self-improvement or open-ended exploration, as well as prior self-improving systems (including DGM). DGM-H also improves the process by which new agents are generated (e.g. persistent memory, performance tracking), and these meta-level improvements transfer across domains and accumulate across runs.

![[jennyzhangzt-455405-001.jpg]]

### The Paper

Paper: [Hyperagents (arXiv)](https://arxiv.org/abs/2603.19461)

Hyperagents suggest a path toward self-accelerating systems that not only search for better solutions, but continually improve their ability to self-improve.

### From DGM to Hyperagents

To understand hyperagents, it helps to start with a prior self-improving AI system, the Darwin Gödel Machine (DGM). In the DGM, a coding agent repeatedly generates modified versions of itself, evaluates them on coding tasks, and stores successful variants in an archive of stepping stones for future improvement.

However, the DGM improves at improving primarily within coding tasks only. It relies on a key assumption: the evaluation task and the self-modification task must be aligned. In coding, this works well. Improving the agent's coding ability also improves its ability to analyze its own code and generate better modifications. But outside coding, this alignment often breaks. For example, improving an agent's ability to write poetry would not necessarily improve its ability to modify its own code.

We address this limitation with hyperagents. A hyperagent integrates the task agent and the meta agent into a single self-referential, editable program. Because the meta-level modification procedure is itself modifiable, the system does not require alignment between the evaluation task and the self-modification task.

We instantiate this idea by extending the Darwin Gödel Machine to create DGM-Hyperagents (DGM-H). The DGM-H retains the open-ended exploration process of the DGM while allowing the self-improvement mechanism itself to evolve, enabling metacognitive self-modification across diverse domains.

![[jennyzhangzt-455405-002.jpg]]

### Results

Our experiments show that the DGM-H can continuously self-improve across diverse domains, with generalizable improvements in both task performance and self-improvement ability.

On coding, the DGM-H achieves gains comparable to the DGM, despite not being handcrafted for coding. Beyond coding, the DGM-H substantially improves performance on paper review and robotics reward design, with gains transferring to held-out test tasks and significantly outperforming prior self-improving algorithms, which struggle outside coding unless customized.

The left figure here shows a tree diagram of the open-ended evolutionary search process of hyperagents. The right figure shows performance progress over iterations, and a summary of key innovations of the DGM-H on paper review.

![[jennyzhangzt-455405-003.jpg]]

### Persistent Memory

The DGM-H learns how to improve, yielding general and transferable self-improvement capability.

One example is the autonomous innovation of persistent memory, which enables learning to accumulate across iterations. Instead of merely logging numerical scores, the hyperagent stores synthesized insights, causal hypotheses, and forward-looking plans (e.g., identifying which generations performed best, diagnosing overcorrections, and proposing how to combine successful strategies). This memory is actively consulted during subsequent self-modification steps, allowing later generations to build on earlier discoveries and avoid repeating past mistakes.

![[jennyzhangzt-455405-004.jpg]]

### Compounding Self-Improvements

We also observe evidence of compounding self-improvements. Self-improvements discovered in one run can be transferred to a new setting and continue accumulating. The figure shows that initializing from a transferred hyperagent from another experiment leads to faster progress and higher final performance.

![[jennyzhangzt-455405-005.jpg]]

### Links & Collaborators

- Paper: [arXiv](https://arxiv.org/abs/2603.19461)
- Code: [GitHub](https://github.com/facebookresearch/Hyperagents)
- Collaborators: Bingchen Zhao, Wannan Yang, Jakob Foerster, Jeff Clune, Minqi Jiang, Sam Devlin, Tatiana Shavrina
- Affiliation: Meta AI (internship)
