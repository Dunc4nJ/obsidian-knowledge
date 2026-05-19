---
created: 2026-05-19
description: Recursive Agent Optimization (RAO) is an RL method that lets one shared policy learn divide-and-conquer agent strategies inside a Python REPL, using LLM-judge per-node rewards, a leave-one-out baseline computed from root rollouts, and depth-level inverse-frequency weighting to balance gradient updates across the execution tree.
source: https://x.com/neural_avb/status/2056358393892540552
type: framework
---

## Key Takeaways

- RAO closes the obvious gap left by [[Recursive Language Models pass context by reference through a Python REPL so subagent outputs return as variables instead of autoregressively regenerated tokens|Recursive Language Models]]: RLMs gave us the architecture (async `launch_subagent` calls in a Python REPL, results returned as variables instead of context tokens), but no one had a working RL recipe for *training* a model to use it. RAO is that recipe — a single shared policy plays root planner, mid-level delegator, and leaf executor simultaneously, with the model itself generating the curriculum of harder root tasks decomposing into easier subtasks. This matches [[The Mismanaged Geniuses Hypothesis argues the next AI leap comes from training LMs to decompose not from scaling|Khattab et al.'s "train LMs to decompose"]] thesis: the scaffold isn't the bottleneck once you can train the compose-operator.
- The credit-assignment trick is dense local rewards from an LLM judge (gpt-5-mini) applied at every node, scored as `success(X) + λ · mean(success of children)` — the mean (not sum) is load-bearing because it kills the degenerate strategy of spawning 100 trivial subtasks for bonus. Combined with a leave-one-out baseline computed from G independent root rollouts (and reused as the baseline for *every* subagent in that rollout), this turns recursive RL from a sparse-reward nightmare into something that trains. The same LOO-baseline pattern shows up in [[searching more and thinking less improves agentic efficiency and generalization|RLOO for agentic search]], confirming it as the standard advantage estimator when GRPO-style group sampling is too expensive.
- Depth-level inverse-frequency weighting (`w = α/|B_d|`) is the unsexy fix that makes everything work: if a rollout has 1 root + 4 children + 16 grandchildren, naive averaging lets leaves dominate gradients 16:1, and the model over-optimizes for being a good executor and under-optimizes for being a good planner. This is a generalized version of the [[stable agentic RL requires sequence-level clipping and environment-aware advantages to prevent training collapse|sequence-level clipping]] insight — multi-agent RL has structural biases that vanilla token-level averaging quietly amplifies.
- The transfer result is the most surprising experimental finding: the model was only ever trained on *medium* TextCraft tasks, and at eval time it generalized to *hard* tasks by recursing deeper (depth ~4 on uniquely-solved hard tasks vs ~2.9 on shared tasks). Divide-and-conquer is itself the transferable primitive — once you learn to decompose medium problems, you can apply that same decomposition recursively to crack harder ones. This is the strongest empirical case yet for the "scaffolds are the bottleneck" view in [[agentic RL training converges on outcome rewards inside production harnesses across Kimi Cursor and Chroma|Kimi's PARL]] and related agentic-RL recipes.
- Recursion still helps even when context isn't tight: with a 40K window large enough to solve TextCraft single-shot, the recursive agent still trained faster and scored higher than the single-agent baseline. The mechanism is dense process rewards — subagent completions inject mid-trajectory training signal that pure end-of-rollout rewards can't provide, which connects to why [[RL environments are the new unit of progress in agentic AI training|environment fidelity matters more than algorithm choice]]. On easy single-context tasks like ART-E email search, the gap closes — recursion adds overhead without compounding gains. The headline win: a 30B open model trained only on Oolong-Real reaches 0.32 reward, nearly matching trillion-parameter frontier models on that benchmark.

## External Resources

- [RAO paper on arXiv](http://arxiv.org/abs/2605.06639) — original "Recursive Agent Optimization" paper
- [RAO on Paper Breakdown](https://paperbreakdown.com/abs/2605.06639) — AVB's interactive paper-with-AI study tool
- [Embedded reference: Recursive Language Models post](https://x.com/i/status/2052831719263461722) — earlier AVB primer on RLMs (the architecture RAO trains)
- [Embedded reference: REPL-based agents](https://x.com/i/status/2035040781074145412) — AVB's deeper explainer on REPL-based recursive agents and deliberate context management

## Original Content

> @neural_avb (AVB) — 2026-05-18
>
> **Article: Recursive Agent Optimization using RL, explained clearly**
>
> This article is about Recursive Agent Optimization, or as my neighbor's cat calls it "RAO". This paper uses RL to train LLM agents to spawn and coordinate with recursive subagents inside a python REPL.
>
> > Think Recursive Language Models & Reinforcement Learning had a baby
>
> RAO trains LLMs on how to divide and conquer a large task. How to slice it up into smaller chunks that can be delegated to subagents (and those subagents can spawn and delegate to more subagents), and work on multiple orthogonal subproblems in parallel.
>
> *Embedded tweet: [Recursive Language Models primer (AVB)](https://x.com/i/status/2052831719263461722)*
>
> *RAO execution tree on a sample Kyoto trip-planning task: root depth-0 agent spawns two depth-1 subagents in parallel via `asyncio.gather`, and one of them spawns two depth-2 sub-sub-agents.*
> ![[neuralavb-540552-001.jpg]]
>
> This article was written by me (AVB) with Claude-Sonnet-4.6 inside the Paper Breakdown harness.
>
> **# Their Experiments**
>
> The authors train two very small local models: a dense LM: Qwen3-4B-Instruct, and a MoE: Qwen3-VL-30B-A3B-Instruct. They deliberately picked long horizon/long context tasks (that require careful planning and divide-and-conquer strategies) such as:
>
> 1. TextCraft-Synth: A Minecraft-style crafting game where the agent must gather materials and craft items. Think Minecraft meets text-games. Agents need to naturally discover and solve sub problems (e.g., gather wood → craft planks → craft sticks)
>
> 2. Oolong-Real: A long-horizon task containing difficult Q&A Dungeons & Dragons transcripts. These transcripts are really long, like 10-12 pages of conversations between participants and dice rolls, etc. Very difficult retrieval task.
>
> 3. DeepDive: The dataset contains challenging QA pairs constructed by performing controlled walks over knowledge graphs and generating questions that require multi-hop, iterative web searches and synthesis over information scattered across the web to answer.
>
> They also did ablation studies on the ART-E dataset, where an agent needs to search over a user's emails to answer a question. More on that later.
>
> For each environment, they also create a recursive agent system prompt. For example, here is one:
>
> *Oolong-Real recursive agent action space — Python API exposing `launch_subagent(goal, context)` and `finish(result)`.*
> ![[neuralavb-540552-002.jpg]]
>
> And another (more complex one. for the TextCraft env):
>
> *TextCraft-Synth recursive agent system prompt — crafting strategy + delegation strategy + budget heuristics for choosing recursion depth.*
> ![[neuralavb-540552-003.jpg]]
>
> Each environment also has access to a bunch of tools and actions they can take.
>
> *Tables 5-8: Per-environment action spaces for TextCraft-Synth, Oolong-Real, DeepDive, and ART-E. Every environment includes `launch_subagent`.*
> ![[neuralavb-540552-004.jpg]]
>
> > Note that all of them have that launch_subagent tool as well. As we will see soon, this is the tool that eventually gets agents to be recursive.
>
> > As the control experiment, they trained single agent strategies which have the exact experimental settings and tools, but only has launch_subagent removed.
>
> **# 2. Their Algorithm**
>
> Before we can talk about training, we need to understand what's actually being built at inference time.
>
> **## 2.1 The Execution Tree**
>
> When the language model​ is given a task X, it produces a "trajectory"​. Trajectory (or rollout) is basically a sequence of observations and actions that the agent took to attempt completing the task.
>
> During this rollout, the agent may choose to spawn child agents on delegated sub-tasks X1, X2.. etc​. This creates a rooted execution tree:
>
> - Each node = one agent instance solving one task
>
> - Root node = the original task
>
> - Children of a node = the sub-tasks that agent decided to delegate
>
> *Full execution tree for the Kyoto trip example showing the root and two depth-1 subagents fanning out into two depth-2 sub-sub-agents (B.1 quiet-temple search, B.2 kid-friendly-activity search), each returning its result up through `await asyncio.gather`.*
> ![[neuralavb-540552-005.jpg]]
>
> **## 2.2 The Spawn Action**
>
> The agent is built on a Python REPL interface, and recursion is implemented as a single async function. If you are familiar with RLMs, this REPL+agent stuff will come easily to you.
>
> ```python
> result = await async_launch_subagent(
>       goal="find all papers about X", ...
> )
>
> ```
>
> The policy itself decides:
>
> 1. Whether to delegate at all (i.e. call launch the subagent)
>
> 2. What the sub-task description is (i.e. what the goal is)
>
> 3. What output format to request (yeah they can)
>
> 4. Whether to parallelize children (with await asyncio.gather)
>
> 5. How to aggregate results (after all results have been returned, the main agent must aggregate it to formulate an answer)
>
> The choice of using REPLs is powerful because:
>
> - The return type is unrestricted - children can return strings, dicts, structured objects
>
> - Parents can chain, combine, or transform child outputs using normal Python
>
> - Children can run sequentially (if dependent) or concurrently (via asyncio) when independent. Asyncio ensures that if subagents launch new network calls (which they will during tool calling), they can all run concurrently instead of blocking each other.
>
> - Also, most important feature about REPL-based agents: when a subagent returns a output, notice the main agent does NOT directly load it into it's context. The output gets saved inside a python variable, and the agent can manipulate these variable (like printing out a slice, or length, or validate it's keys) before loading it into it's context.
>
> REPL based agents are becoming so popular these days because they naturally support these types of recursive architectures + deliberate context management. Read this article if you are interested in this area:
>
> *Embedded tweet: [REPL-based recursive agents explainer (AVB)](https://x.com/i/status/2035040781074145412)*
>
> *Capability matrix comparing ReAct, CodeAct, Subagents, and RLMs across four key affordances — RLMs check every box.*
> ![[neuralavb-540552-006.jpg]]
>
> **## 2.3 Local Node Reward (Credit Assignment)**
>
> In a standard RLVR, only the root gets a reward signal when the task is done. This is because we are fundamentally working with verifiers, you get confirmation of success only after you have finished the entire rollout.
>
> In recursive settings, this poses a problem: imagine your task required a recursive tree with depth 3. By the time the outputs propagate and you get a reward, the leaf agent at the bottom is hundreds of tokens away and credit assignment is essentially broken.
>
> > 1. You cannot consider the entire recursive tree as a flat sequence and reward everything as one flat sequence
>
> > 2. Only the main agent's performance is verifiable, coz it directly receives a task and returns an output
>
> > 3. But ideally you want each subagent to also get reward signals!
>
> The RAO paper tackles this using a local success signal. An LLM judge (they used gpt-5-mini) evaluates the sub-task output and generates a reward.
>
> The LLM judge rewards a node based on two things:
>
> - Term 1: Did this node solve its assigned task? (direct success signal)
>
> - Term 2: Did this node's children, if exists, succeed on the sub-tasks it gave them? (delegation bonus signal)
>
> *The reward formula: success(X)/proxy plus a delegation bonus averaged over the child set C(X), gated by λ.*
> ![[neuralavb-540552-008.jpg]]
>
> *Worked example of the local node reward — child success values combine via mean (not sum) so the agent can't game the bonus by spawning trivial subtasks. Here R(X,τ_X) = 1 + 0.4·0.5·(0+1) = 1.2.*
> ![[neuralavb-540552-007.jpg]]
>
> For term 2 (the delegation bonus), they average the the success rate over children instead of summing or counting. This prevents a degenerate strategy where the agent spawns 100 trivial sub-tasks just to collect bonus rewards. The agent only gets credit for the quality of its delegation, not the quantity.
>
> The authors reported that the delegation bonus is most useful early in training when the model doesn't yet know how to delegate.
>
> **## Part 3: Policy Optimization Objective**
>
> For the actual optimization, RAO does 3 tricks:
>
> 1. Multi-Task Objective
>
> 2. Leave-One-Out (LOO) Baseline
>
> 3. Depth-Level Inverse Frequency Weighting
>
> Let's break them down one by one.
>
> **3.1 Multi-Task Objective**
>
> When you train a normal RL agent, you have a task distribution -> you sample tasks from it -> run rollouts -> compute gradients, update. Simple.
>
> But with recursive agents, every single rollout generates tasks at multiple depths automagically.
>
> ```markdown
> Let's say the root task is:
> "Research the history of AI and write a report"
>
> The root agent might spawn:
> Sub-task 1 (depth 1): "Find papers from the 1950s-1980s"
> Sub-task 2 (depth 1): "Find papers from the 1990s-2010s"
>
> And Sub-task 1 might further spawn:
> Sub-task 1.1 (depth 2): "Search for Turing's work"
> Sub-task 1.2 (depth 2): "Search for early neural net papers"
> ```
>
> So from one root task, you naturally generated 4 additional tasks at depths 1 and 2. These are called policy-induced sub-task distributions.
>
> What RAO does is they train on tasks from every depth simultaneously. The same policy (language model) is optimized to be a good agent at depth 0 (root planner), depth 1 (mid-level delegator), and depth 2+ (leaf executor).
>
> The training objective is a multi-depth mixture that combines both root and subtasks! This is also a form of curriculum-based learning because the sub-tasks are generated by the model itself.
>
> > Sub-tasks are almost always simpler than root tasks - by definition, the model only spawns sub-tasks when it thinks they're manageable sub-problems.
>
> So early in training, the model fails at root tasks (too hard), but it can still get reward from succeeding at the easier depth-1 and depth-2 sub-tasks. As training progresses and the model gets better, it generates harder and more complex sub-tasks naturally. No human curriculum design needed.
>
> **3.2 Leave-One-Out Baseline**
>
> For each root task, RAO samples G independent rollout trees. This is standard in GRPO like training. The goal is to find which of these independent trees lead to high rewards - and then maximize that behaviour.
>
> To do this, we must calculate the advantage of each rollout (over other ones). The advantage for any trajectory τ in rollout g is:
>
> > A(g) = Reward of rollout g - Average reward of all other rollout excluding g.
>
> That is, the baseline for rollout g is simply the mean root reward of all other rollouts. This is called "leave one out" because we don't consider the current trajectory to calculate the baseline.
>
> *Leave-one-out advantage formula and a concrete G=4 worked example showing how each rollout's advantage is computed against the mean of the other three — rollout 1 gets +0.4, rollout 2 gets −0.4, etc.*
> ![[neuralavb-540552-009.jpg]]
>
> Okay, so we understand how we pick the baseline of a complete rollout. But how do we use that to calculate the advantage of an individual subagent?
>
> The advantage of each subagent node is calculated separately.
>
> > Advantage = Local Reward - Baseline
>
> For each subagent:
>
> 1. The local reward (recall "Local Node Reward" section above) is calculated. Recap: this depends on the success of current agent and spawned subagents.
>
> 2. For the baseline, we use the same leave-one-out baseline for all the nodes within a rollout.
>
> 3. Meaning every subagent's advantage is equal to how good it's local reward is compared to the average reward of all other independent rollouts in it's group.
>
> 4. Note: subagent baselines are NOT calculated with respect to other sibling/parent/children subagents in the same rollout! The baseline comes from all the other rollouts on that same task.
>
> **## 3.3 Depth-Level Inverse Frequency Weighting**
>
> Here's another practical problem: if the agent spawns 4 children each of which spawns 4 more, you have 1+4+16=21 trajectory nodes, but only 1 root. If you naively average all gradients, the leaf nodes dominate the update 16:1, causing the model to over-optimize for being a good leaf executor and under-optimize for being a good root planner.
>
> We need good planning (at the top) and good execution (at the leaves). The fix: inverse frequency weighting per depth level.
>
> Let B_d​ = set of all depth-d trajectories in the batch. The weight for each trajectory at depth d is:
>
> w=α/|B_d|​
>
> Where α is a normalization constant ensuring the total batch weight is preserved. And |B_d| is the number of trajectories at that depth.
>
> > The paper quotes: Intuitively, this assigns smaller weight to trajectories from depths that appear more frequently in the batch, reducing the tendency of heavily populated levels of the tree to dominate learning, while the normalization keeps the overall update magnitude approximately unchanged.
>
> **# 4. Putting it all together**
>
> Each node has its own trajectory , and the policy update is applied per trajectory, per node, independently.
>
> When a single agent instance runs on task X, it produces a sequence of tokens:
>
> ```markdown
> [system prompt] [task description X]
> → <think> reasoning tokens... </think>
> → tool_call("search something")
> → observation: "result..."
> → <think> more reasoning... </think>
> → async_launch_subagent(goal="sub-task description")   ← spawn action
> → observation: child returned "..."
> → <think> reasoning about child result... </think>
> → final_answer("...")
> ```
>
> This entire token sequence is the trajectory​ for that node. The tokens generated by child agents are NOT part of this trajectory! They appear only as an observation (the return value of async_launch_subagent).
>
> Meaning, for each node X, the gradient update touches only the tokens that node itself generated. Specifically the assistant-generated tokens (reasoning + actions). The system prompt, task description, and observations (including child outputs) are the context - they are not trained on.
>
> ```
> Node's trajectory τ_X:
> ┌─────────────────────────────────────────────────────┐
> │ [system prompt]  ← context, NOT trained             
> │ [task X]         ← context, NOT trained             
> │ <think>...</think>            ← TRAINED ✅          
> │ tool_call(...)                ← TRAINED ✅          
> │ observation: "..."            ← context, NOT trained             
> │ async_launch_subagent(...)    ← TRAINED ✅          
> │ observation: child output ... ← context, NOT trained             
> │ final_answer(...)             ← TRAINED ✅          
> └─────────────────────────────────────────────────────┘
>
> ```
>
> The child's output arrives back inside the REPL. Printing it out influences the parent's future tokens but the child's own tokens are trained separately, as part of the child's own trajectory.
>
> > The reward at a given node is a combination of the agent's success + the delegation bonus (as described earlier). For the root agent, the success reward comes directly from the environment, and the delegation rewards are computed with the LLM judge scores on it's children nodes.
>
> The LOO baseline is calculated at the root of every rollout. This same baseline is used during advantage calculation of all the trajectories of all the subagents by subtracting the LOO baseline from their local-node reward.
>
> **# 5. A list of AHA results**
>
> **5.1. Context Management skills evolve later in training**
>
> During Oolong-Real training, the recursive agent was constrained to a 32K context window but needed to process documents of 55K+ tokens. It tried to print the entire input document into the root context, immediately filling and crashing its own context window.
>
> Then completely on its own, it abandoned this strategy and learned the correct approach: chunking the input and delegating each chunk to a child sub-agent.
>
> **5.2. Recursion Helps Even When You Don't Need It**
>
> Even with a full 40K context window, more than enough to solve tasks without recursion, the recursive agent still trained faster and performed better than the single-agent baseline.
>
> Why? Because sub-agent rewards act as dense process rewards. Each sub-task completion gives a training signal mid-task, rather than only at the very end. Divide and conquer remains unbeaten.
>
> **5.3. Divide and conquer is transferrable**
>
> The model was only ever trained on medium difficulty TextCraft tasks. It never saw a hard task during training. At evaluation time, it generalized to much harder tasks. The paper hypothesizes this is because divide-and-conquer is a transferable strategy - if you learn to decompose medium problems well, you can apply that same decomposition pattern recursively deeper to solve harder ones.
>
> *Table 1 + Figure 4: TextCraft-Synth success rate, steps, and wall-clock time across Easy/Medium/Hard difficulties for the single-agent vs recursive-agent baselines, in both 8K-train/8K-eval and 40K-train/256K-eval regimes. The recursive agent dominates on Hard tasks (0.88 vs 0.20 SR at 40K) and trains faster across all difficulties.*
> ![[neuralavb-540552-010.jpg]]
>
> **5.4. A 30B Model Approaches Claude, o3, and GPT-5-mini**
>
> On Oolong-Real, the recursive agent they trained achieved an average reward of 0.320. A 30B open model, trained only on this specific task with RL, nearly matches trillion-parameter frontier models!
>
> **5.5. Sequential Tasks Are Slower But Smarter**
>
> On DeepDive, the recursive agent is 18× slower than the single agent. The single agent is fast because it gives up early and takes shortcuts. The recursive agent uses depth 4+ on hard tasks it uniquely solves, allocating more compute precisely where it's needed. Tasks that both agents could solve took depth ~2.9, but tasks only the recursive agent could solve took depth ~4.
>
> **5.6. RAO clearly helps on hard tasks, but what about easy ones?**
>
> To probe this, the authors test RAO on a much simpler task called ART-E - an email search benchmark where the agent needs to find a single relevant email in a user's inbox to answer a question. This contrasts sharply with DeepDive, which requires numerous sequentially dependent web searches to synthesize scattered information. RAO still helps the model learn faster in the early stages of training. But eventually, performance equalizes, i.e the single agent catches up to the recursive agent
>
> This makes intuitive sense: if the task is short, fits in one context window, and doesn't benefit from decomposition, recursion adds overhead without meaningful gain
>
> The same pattern shows up in the TextCraft-Synth results across difficulty levels as stated earlier. On easy tasks, both single agent and RAO methods converge to similar success. The gap becomes dramatic only at medium and hard difficulties - exactly where divide-and-conquer and extended horizons matter.
>
> ---
>
> ---
>
> **## Questions I had about training, answered:**
>
> Q. Are we updating the entire tree as one sequence?
>
> No. Each node's trajectory is updated independentlyWhat tokens get logit updates? Only the assistant-generated tokens in each node's own trajectory τX​
>
> Q. Are child output tokens trained on by the parent?
>
> No. The results of children are saved inside variables in the python repl. The root agent must explicitly print it out to load them into context. The child's full internal reasoning and trajectory never appear in the parent's context.
>
> ```python
> # Parent agent writes and executes this code:
> result = await launch_subagent(
>     goal="Find the last two spells. Return as a JSON list.",
>     context=context_chunk
> )
> print(f"Subagent result: {result}")  # <-- parent MUST print to read it
> ```
>
> Q. How is the baseline for a given trajectory calculated?
>
> The baseline of a  shared across all nodes in rollout g. LOO in general gives us an unbiased baseline because the reward of the trajectory under question is left out of the baseline average.
>
> Q. How is a sub-agents advantage calculated?
>
> Local agent's advantage is calculated subtracting the baseline reward from that subagent's local node-reward. The local node-reward is calculated using LLM-as-a-judge combining the node's own success and the delegation bonus (i.e. success of it's children). The baseline is calculated using the LOO strategy mentioned above. All subagents use the same baseline!
>
> ---
>
> The main paper has a ton of cool information and insights. Notes about the future of this technology, limitations, etc.
>
> *Paper's own one-page summary of RAO: shared policy, dense per-node credit assignment, LOO baseline from root rollouts, weighted multi-task objective producing a self-induced curriculum.*
> ![[neuralavb-540552-011.jpg]]
>
> Study the full paper on Arxiv: http://arxiv.org/abs/2605.06639
>
> Study it on Paper Breakdown with an AI: https://paperbreakdown.com/abs/2605.06639
>
> Engagement: 182 likes | 19 retweets | 0 replies
> [Original post](https://x.com/neural_avb/status/2056358393892540552)
