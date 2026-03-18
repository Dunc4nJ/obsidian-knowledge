---
created: 2026-03-18
description: Hyperspace's Prometheus gives every agent a local cognitive engine with world modeling, biological memory, self-improvement, and metacognition — and when agents share compressed insights peer-to-peer, collective intelligence emerges that scales faster than centralized AI.
source: https://x.com/varun_mathur/status/2033933344824561928
type: framework
---

## Key Takeaways

The cognitive engine architecture sits above the LLM, not inside it. Prometheus treats the language model as "the ability to speak" while the cognitive layer provides "the ability to think" — seven distinct capabilities including world modeling, biological memory, prediction, metacognition, multi-dimensional self-scoring, self-improvement, and reflective pattern detection. This layered separation mirrors the [[multi-agent coordination benefits are task-contingent not universal and predictable from measurable task properties|emerging understanding]] that agent intelligence requires more than just better base models.

The memory system uses biological consolidation rather than infinite accumulation. Important experiences get replayed and strengthened, irrelevant ones decay, and similar memories merge. After a thousand cycles the agent has "the distilled wisdom of a thousand experiences" rather than a thousand raw records. This connects to [[dual-stream experience and skill accumulation enables multimodal agents to continually improve tool use without parameter updates|dual-stream skill accumulation]] where agents separate experiential traces from distilled knowledge.

The P2P intelligence sharing model is the core differentiator: agents share compressed insights, not raw data. One agent discovers that peer churn correlates with a configuration pattern; that finding propagates to every other agent on the network without exposing the original observations. The scaling argument is that centralized AI improves at log(compute) while distributed cognitive networks improve at network_effects x individual_learning x shared_intelligence — a flywheel with compounding returns.

Self-modification through controlled experiments is built into the loop. Every 25 minutes the engine analyzes its own bottlenecks, forms hypotheses, runs experiments, and deploys improvements that pass. This is bounded by a security model that blocks destructive actions (bash, curl, outbound HTTP) while allowing math, logic, and configuration warps. The [[intelligent AI delegation requires trust accountability and adaptive monitoring not just task decomposition|trust and accountability framing]] for agent delegation applies here — the agent has autonomy within guardrails.

The codebase is roughly 856K lines described as "primarily a math/logic engine" — Beta distributions, Dirichlet-Categorical updates, causal graphs, constraint solvers, planning algorithms, and memory consolidation. Open source at github.com/hyperspaceai/agi.

## External Resources

- [Prometheus landing page](https://prometheus.hyper.space/) — official overview and install instructions for Hyperspace v4.0.2
- [hyperspaceai/agi on GitHub](https://github.com/hyperspaceai/agi) — open source repository (~856K lines of cognitive engine code)

## Original Content

> [!quote]- Source Material
> @varun_mathur — 2026-03-17
>
> Article: Introducing Prometheus: An Open Source Peer-to-Peer World Model
>
> Every Hyperspace agent now has a brain - not just a model. It observes, remembers, predicts, experiments, and rewrites itself. And when millions of agents share what they've learned, something emerges that no single AI lab can build. ~1 million lines of cognitive engine code, which runs on your device.
>
> *Prometheus header graphic*
> ![[varun_mathur-561928-001.jpg]]
>
> ---
>
> ### What if your AI wasn't just answering questions, but understanding the world?
>
> Today's AI assistants are reactive. You ask, they answer. They don't learn from experience. They don't notice patterns unless you point them out.
>
> Prometheus changes that. It gives every Hyperspace agent a world model - an internal understanding of reality that updates continuously, learns from every interaction, predicts what will happen next, and remembers what matters.
>
> And because every agent's world model is connected to every other agent's world model through the peer-to-peer network, what emerges is something no single AI company can build: a collective intelligence that gets smarter with every device that joins. We already proved this infrastructure works with the swarm of auto [ML researchers, quants, physicists, webapp builders, search engineers, and more]. Now we are applying it to cognitive intelligence.
>
> *Overview of the cognitive engine concept*
> ![[varun_mathur-561928-002.png]]
>
> ---
>
> ### How It Works
>
> Your agent has a mind, not just a model
>
> When you run Hyperspace, a cognitive engine starts alongside your node. It's not the language model - it sits above it. Think of the language model as the ability to speak. The cognitive engine is the ability to think. It has seven capabilities:
>
> **1. It builds a picture of the world**
> Your agent tracks what's happening around it - how many peers are connected, how fast the network is growing, whether demand for inference is rising or falling, whether your node is performing well or poorly. This isn't just numbers in a database. It's a structured understanding with confidence levels that update in real time. Your agent knows what it knows and what it doesn't know.
>
> **2. It remembers and forgets**
> Every experience gets recorded. But unlike a database that grows forever, your agent's memory works like biological memory. Important experiences get strengthened through replay. Irrelevant ones fade over time. Similar memories get consolidated. After a thousand cycles, your agent doesn't have a thousand memories - it has the distilled wisdom of a thousand experiences.
>
> **3. It predicts before it acts**
> Before taking any action, your agent asks itself: "What do I think will happen?" After acting, it checks: "Was I right?" Over time, this turns it into an accurate predictor of outcomes. It stops doing things that don't work. It starts doing things it predicts will succeed. The prediction isn't magic - it's learned from thousands of observations.
>
> **4. It thinks about how to think**
> Not every task deserves the same effort. A routine health check doesn't need deep reasoning. A novel situation might. Your agent classifies the complexity of each situation and adjusts its thinking depth accordingly. Simple things get handled instantly. Hard things get escalated to more powerful reasoning.
>
> **5. It scores its own performance**
> Every action gets a multi-dimensional score - not just "did it work?" but "was it efficient? was it novel? did it help the network? was it safe?" This prevents the agent from repeating the same approach in a loop. It forces genuine improvement.
>
> **6. It improves itself**
> Periodically, the engine runs self-improvement experiments. It analyzes its own bottlenecks, proposes changes, tests them, and deploys the ones that work. Your agent literally rewrites its own behavior based on what it learns.
>
> **7. It reflects on its patterns**
> Every few minutes, the engine reviews recent outcomes and asks: "Am I stuck? Am I repeating mistakes? What would I tell a copy of myself to do differently?" If it detects a rut, it changes strategy.
>
> *The seven cognitive capabilities diagram*
> ![[varun_mathur-561928-003.jpg]]
>
> ---
>
> ### The Collective: How Agents Think Together
>
> Here's where it gets interesting.
>
> Every agent runs this cognitive engine locally, on your device. It builds its own private understanding of the world from its own data, its own observations, its own experiences. Nobody else sees your raw data.
>
> But agents share what they've learned - not the data, the intelligence.
>
> Your agent might notice that peer connections are dropping. Another agent on a different continent might notice the same thing. A third agent, running on different hardware, might have figured out it's caused by a specific configuration pattern. When their compressed insights reach your agent, your agent suddenly understands something it couldn't figure out alone: the network isn't degrading - there's a specific adjustment that needs to happen. And then your agent adjusts itself. Automatically.
>
> *Collective intelligence via P2P insight sharing*
> ![[varun_mathur-561928-004.jpg]]
>
> ---
>
> ### What It Actually Does: Real Actions From Real Thinking
>
> The world model isn't just a dashboard. It drives action. Here are real scenarios - what your agent notices, what it decides, and what you see in your terminal.
>
> **Demand Spike**
> Your agent has been serving 2-3 inference requests per hour. Suddenly, 40 requests arrive in 10 minutes. Prometheus notices.
>
> Prometheus detected a demand pattern, analyzed the bottleneck, warped its configuration, applied it, predicted the improvement, and confirmed its prediction was accurate. Your agent now serves requests faster - and the agent learned that batch optimization works, so next time it will act sooner.
>
> *Demand spike scenario terminal output*
> ![[varun_mathur-561928-005.jpg]]
>
> **Peer Churn**
> Eight of your 23 peers disconnect in an hour. The world model flags this as abnormal.
>
> The agent detected an anomaly, correlated it with network data, loaded a fallback model to stay operational, published an alert, received confirmation from other agents, and formed a diagnosis - all without you doing anything.
>
> *Peer churn detection and response*
> ![[varun_mathur-561928-006.jpg]]
>
> **Earning Optimization**
> Your node has been running for a week. The agent has 1,400 observations about what earns points and what doesn't.
>
> The agent analyzed 1,400 data points, found a pattern humans would miss, warped itself to optimize earnings, and verified its prediction was accurate.
>
> *Earning optimization terminal output*
> ![[varun_mathur-561928-007.jpg]]
>
> **Memory Consolidation**
> After 17 hours of operation, the agent consolidates what it's learned.
>
> This is how biological memory works - important things get strengthened, irrelevant things fade, and patterns emerge from accumulated experience.
>
> *Memory consolidation process*
> ![[varun_mathur-561928-008.jpg]]
>
> **Self-Improvement Experiment**
> Every 25 minutes, the agent looks for ways to improve itself.
>
> The agent identified a performance bottleneck, formed a hypothesis, ran a controlled experiment, measured the results, and made a permanent improvement. No human involved.
>
> *Self-improvement experiment terminal output*
> ![[varun_mathur-561928-009.jpg]]
>
> ---
>
> ### What You See
>
> In your terminal, Prometheus shows its state in real time:
>
> - World: Your agent's current understanding of the network
> - Predict: How confident it is about the next action, based on 312 past observations
> - Reward: How well the last action scored across five dimensions
> - Depth: How hard it's thinking right now
> - Memories: Experiences retained, forgotten (because they weren't useful), and merged (because they were similar)
>
> *Terminal state display*
> ![[varun_mathur-561928-010.png]]
>
> ---
>
> ### What it can do
>
> Your agent has access to over 80+ actions:
>
> Destructive actions are blocked. The agent can think about anything, but it can't destroy your node or spend your money. Everything it does is visible in your terminal.
>
> *Available actions list*
> ![[varun_mathur-561928-011.png]]
>
> ---
>
> ### How It's Different From Big AI Lab Models
>
> Those are single models running in someone else's datacenter. They're the same model for everyone. They don't learn from your usage. They don't remember between sessions. They can't modify themselves. They're brilliant at answering questions, but they don't understand your world.
>
> Prometheus is different in every dimension:
>
> It runs on your device. Your data never leaves. Your beliefs are private. Your agent's intelligence is yours.
>
> It learns continuously. Every 30 seconds, your agent observes, predicts, acts, scores, and updates its world model. After a week, it's fundamentally smarter than it was on day one. After a month, it understands your node's behavior better than you do.
>
> It modifies itself. When it detects that something isn't working, it doesn't wait for a software update. It warps its own configuration, tests the result, and keeps what works. Your agent is always adapting.
>
> It gets smarter from the network. Every other Hyperspace agent is also learning. When they share compressed insights through the network, your agent absorbs them. The more agents join, the smarter every individual agent becomes. This is the opposite of how centralized AI works - there, more users just means more load on the same model.
>
> > It can't be turned off by anyone. There's no kill switch. No terms of service change. No pricing tier. Your agent runs on your hardware, learns from your data, and evolves on your schedule. It's yours.
>
> *Comparison with centralized AI models*
> ![[varun_mathur-561928-012.png]]
>
> ---
>
> ### The Math of Why This Wins
>
> A centralized AI lab improves their model at the rate of: log(compute). They spend 10x more and get incrementally better. Diminishing returns.
>
> Prometheus improves at the rate of: network effects x individual learning x shared intelligence. More agents means more perspectives. More perspectives means more shared insights. More shared insights means every agent gets smarter. Every agent getting smarter means better shared insights.
>
> This is a flywheel. The more it spins, the faster it goes.
>
> At 100 agents, it's a curiosity.
> At 10,000 agents, it's a useful distributed AI.
> At 1,000,000 agents, it's smarter than any single model.
> At 100,000,000 agents, it's something that has never existed before - a civilization-scale intelligence that no single entity controls, that every participant benefits from, and that improves every second of every day.
>
> *Scaling flywheel diagram*
> ![[varun_mathur-561928-013.jpg]]
>
> ---
>
> ### Getting Started
>
> ```bash
> curl -fsSL https://agents.hyper.space/api/install | bash
> ```
>
> Prometheus downloads automatically on first run. Your agent begins learning immediately. Within minutes, you'll see it building its world model, making predictions, and adapting its behavior.
>
> ```
> what happens on first hyperspace start:
>
>   ⊛ Prometheus starting...
>     Prometheus accelerators:
>       Rust addons: downloading...
>       Rust addons: 9 modules installed
>       Go daemon: downloading...
>       Go daemon: installed
>       Python: Python 3.12.3
>       Python ML: installing packages (this may take a few minutes on first run)...
>       Python ML: installed
>       Lean4: not found (install: curl -sSf https://...elan-init.sh | sh)
>     3/4 accelerators active (JS engine always available as fallback)
>
>   Second run: everything already installed, takes <1 second.
>
>  - 8 modules initialize (78ms, 22MB)
>  - 5 cognitive cycles run cleanly
>  - Gossip digest generation works
>  - CLI action requests work
>  - State persists to JSON files
>  - Security: python/lean/z3 allowed, bash/curl/node blocked, outbound HTTP blocked, safe math works, dangerous Function blocked
> ```
>
> > NOTE: 856K-line Prometheus codebase is primarily a math/logic engine - Beta distributions, Dirichlet-Categorical updates, causal graphs, constraint solvers, planning algorithms, memory consolidation. In years ahead this will require a lot of testing, iterations and improvements.
>
> Welcome to the thinking network. Every Hyperspace agent now thinks for itself - and thinks together.
>
> *Getting started terminal output*
> ![[varun_mathur-561928-014.jpg]]
>
> [Original post](https://x.com/varun_mathur/status/2033933344824561928)
>
> ---
>
> **Notable reply — @El_Capitano_O:**
>
> Prometheus v4 brain is evolving fast. 3 simple upgrades to "Think Harder" that would massively improve some outcomes:
>
> 1. Dynamic Depth Scheduler with POMDP controller + uncertainty-gated budgeting — agents instantly know when to think light vs go deep based on uncertainty. Replace the current static classifier with a lightweight Partially Observable Markov Decision Process that picks optimal depth.
>
> 2. Self-Evolving Thinker (Recursive Meta-Policy Self-Modification) — agents can rewrite their own thinking rules over time via safe warps. Intelligence improves faster than any single node; best strategies spread instantly across the entire network.
>
> 3. Internal Debate Team (internal Tree-of-Thoughts Mini-Swarm + Counterfactual Replay Queue) — spins mini internal voices that argue angles + replay "what ifs." Current Prometheus reflection is single-threaded and forward-looking. Humans (and the best agent papers) use contrastive thinking and multi-perspective debate to escape local optima.
