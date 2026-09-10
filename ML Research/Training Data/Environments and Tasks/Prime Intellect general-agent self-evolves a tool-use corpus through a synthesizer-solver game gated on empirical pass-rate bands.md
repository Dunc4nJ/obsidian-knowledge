---
created: 2026-05-19
description: Prime Intellect open-sources general-agent, a fully synthetic environment that grows its own 4,504-task / 1,040-domain / 8,000-tool corpus by formulating task creation as a 2-player game where a synthesizer LLM proposes tiered tasks and a solver LLM gates each tier against a target pass-rate band.
source: https://www.primeintellect.ai/blog/general-agent
type: synthesis
---

## Key Takeaways

- **Task creation is itself an agent task.** Prime Intellect runs the synthesizer as an LLM agent (`GLM-5.1-FP8`) inside a sandbox with access to a `general-agent` CLI and a structured skill that defines the schema, evolution strategies, and gating protocol — then runs **>1,000 synthesizing agents in parallel over multiple days with barely any supervision** to bootstrap a 4,504-task / 1,040-domain corpus. This is the same insight [[rl environment creation is becoming a distributed marketplace that could 10x cost efficiency over contracting firms|Arledge identifies as the RL-environment bottleneck]], but solved with agentic synthesis rather than human contracting firms.
- **Empirical pass-rate bands replace guessed difficulty.** Every tier (t0→t4) is gated by running a fixed solver (GPT-5-mini at avg@20) against it and only accepting tasks whose solve rate lands in a calibrated band (e.g. 0.4–0.2 for t3). Hard tiers seed the next wave of evolutions, so the corpus grows progressively harder over time — a tight RLVR-style loop that operationalizes [[RL environments are the new unit of progress in agentic AI training|the "verifiable rewards" thesis]] at corpus-scale.
- **Nine evolution strategies generate compounding difficulty from a trivial seed.** Following DeepSeek-V3.2's methodology ([arxiv:2512.02556](https://arxiv.org/abs/2512.02556)), one-shotting a hard task is intractable; iteratively layering `larger_db`, `cross_entity_coupling`, `stricter_thresholds`, `tool_proliferation`, `noisy_instructions`, `ambiguity_resolution`, etc. on a simple seed is not. The `day_spa` family scales from 3 tools / 10 DB entities / 3 gold steps at t0 to 12 tools / 184 entities / 8 steps at t4 — and GLM-5.1's solve rate cleanly tracks the difficulty curve from 100% to 22%.
- **Failure modes are interpretable and exploit world knowledge.** At `day_spa_t4` a "Prenatal Massage" is contextually perfect for a pregnant client but has `pressure: medium`; the correct answer is the "Couples Massage" with `pressure: light`. Models systematically substitute world knowledge for what's literally in the database — a failure mode that synthetic-DB environments expose far better than scraped real-world data ever could.
- **Architecture sits on top of `verifiers` so synthesis and training are the same infrastructure.** Both the synthesizer and solver are `verifiers` environments, which means the synthesis episode (itself a 2-agent interaction) is in principle trainable end-to-end — closing the loop toward genuinely self-improving environments. This is a direct demonstration of [[the agent harness is the RL training environment not deployment infrastructure bolted on after|the convergence of harness and training infrastructure]] that Cursor and Cognition have been pushing.
- **Tiny SFT runs already transfer to held-out benchmarks.** SFT on just **4,417 GLM-5.1 traces** lifts a Nemotron-3-Nano-30B base from 18.9% → 52.3% on BFCL-v3 and from 0.6% → 12.1% on MCP-Atlas — closing roughly two-thirds of the gap to the fully post-trained model that used "orders of magnitude more data." RL on Qwen3-30B over the corpus drives average reward from ~30% → ~70% in 200 steps while turns-per-rollout rises from ~8 → ~24, meaning the model learns to use *more* tools, not fewer. This is concrete evidence that the corpus is a real training signal, not just a benchmark.
- **The gate is also the ceiling.** Because the corpus was calibrated against GPT-5-mini, GLM-5.1's solve-rate distribution stays right-skewed even at t4 (median 0.98), and the headroom for improving frontier models is limited until the synthesis loop is re-gated against a stronger solver — an explicit next step for the team. This is the same self-improvement closure pattern as [[Recursive Agent Optimization trains a shared LLM policy to spawn REPL subagents using local-node rewards and a leave-one-out baseline|RAO's shared-policy recursion]]: the gating signal must keep pace with the agent it's trying to improve.

## External Resources

- [general-agent on Environments Hub](https://app.primeintellect.ai/dashboard/environments/primeintellect/general-agent) — open-sourced environment
- [DeepSeek-V3.2 paper (arxiv:2512.02556)](https://arxiv.org/abs/2512.02556) — task-evolution methodology Prime Intellect adapted
- [BFCL leaderboard](https://gorilla.cs.berkeley.edu/leaderboard.html) — Berkeley Function Calling Leaderboard, used as a held-out eval
- [MCP-Atlas paper (arxiv:2602.00933)](https://arxiv.org/abs/2602.00933) — multi-step tool orchestration benchmark against real MCP servers
- [Example Prime Lab rollout](https://app.primeintellect.ai/dashboard/evaluations/zqzbrfb1p0evmtbsvox9t785) — `day_spa` family rollout
- [W&B run for SFT experiment](https://wandb.ai/primeintellect/general-agent/runs/5e1hs434?nw=nwusermikasenghaas%5F) — Nemotron-3-Nano-30B fine-tune

## Original Content

> [!quote]- Source: primeintellect.ai/blog/general-agent — General Agent: A Self-Evolving, Synthetic Agent Environment
>
> # General Agent: A Self-Evolving, Synthetic Agent Environment
>
> Training capable agents requires exposure to diverse tasks and tools throughout the whole post-training pipeline. Yet, agentic environments with exposure to 1000s of tools remain scarce in the open-source community.
>
> Today, we are open-sourcing a first version of the `general-agent` environment ([Environments Hub](https://app.primeintellect.ai/dashboard/environments/primeintellect/general-agent)) — a fully synthetic environment capable of growing its task corpus to be more diverse and challenging over time. It formulates synthetic task creation as a 2-player game between two agents:
>
> * **Synthesizer** — An agent tasked to synthesize a new task; follows a well-defined task schema and synthesis procedure with multiple mechanisms to ensure solvability, diversity, and difficulty.
> * **Solver** — An agent tasked to solve a task instance.
>
> The synthesizer agent designs and evolves a novel task family in difficulty tiers. Each tier is empirically validated by running a solver against it — only tasks whose pass rate lands in a calibrated difficulty band are accepted. Hard tiers seed the next wave of extensions, letting the corpus grow progressively harder over time.
>
> The result is a self-evolving task corpus of currently **4,504 tasks** across **1,040 domains** with over **8,000 unique tools**, all grounded in stateful database operations with semantic verification.
>
> ---
>
> ## Task Anatomy
>
> Every task follows a clear semantic structure: a _database_, a set of _tools_ that manipulate the database, an _instruction_, and a _gold solution_ with matching _verification function_ that checks whether the task was completed successfully.
>
> ### Task Seed: DB + Tools + Tasks + Verification
>
> Each task defines a Pydantic data model (`DB`) representing entities and their interactions. For example, in the `day_spa` task family, a `Therapist` performs a `Service` during an `Appointment`.
>
> The agent interacts with this database through tools (`Tools`), which are simple Python functions reading or manipulating the state of the database. Tools enforce domain logic (specialty matching, availability checks, rating constraints) and return structured feedback to the agent about data manipulation. For example, the agent may `list_services`, `list_therapists`, and `book_appointment`.
>
> ```python
> class Service(BaseModel):
>     id: str
>     name: str
>     category: str  # massage, facial, body_treatment, nail_care
>     duration_minutes: int
>     price: float
>
> class Therapist(BaseModel):
>     id: str
>     name: str
>     specialties: list[str]  # service categories they can perform
>     is_available: bool = True
>
> class Appointment(BaseModel):
>     id: str
>     customer_name: str
>     service_id: str
>     therapist_id: str
>     status: str = "booked"
>
> class TaskDB(DB):
>     services: list[Service] = []
>     therapists: list[Therapist] = []
>     appointments: list[Appointment] = []
>     target_customer: str | None = None
>     target_service: str | None = None
>
> class TaskTools(Tools):
>     db: TaskDB
>
>     @tool
>     def list_services(self) -> list[dict]:
>         """Return all spa services with details."""
>         return [s.model_dump() for s in self.db.services]
>
>     @tool
>     def list_therapists(self) -> list[dict]:
>         """Return all therapists with their specialties."""
>         return [t.model_dump() for t in self.db.therapists]
>
>     @tool
>     def book_appointment(self, appointment_id: str,
>                          customer_name: str, service_id: str,
>                          therapist_id: str) -> dict:
>         """Book a spa appointment."""
>         service = next(s for s in self.db.services if s.id == service_id)
>         therapist = next(t for t in self.db.therapists if t.id == therapist_id)
>         # check therapist availability and specialty match
>         # mark therapist unavailable, append appointment
>         ...
> ```
>
> The agent receives a natural language instruction and must figure out how to use the tools to complete the task. For the seed task `day_spa_t0`, the instruction reads
>
> > Hi, I'm Sarah and I'd like to book a Swedish Massage. Could you look up the services and therapists, then just go ahead and book me with any available therapist who does massage? Don't worry about asking me to pick, just pick one and book it.
>
> To ensure that tasks are solvable, the synthesizer is asked to produce a _gold solution_ and a _verification function_. It is expected that the verification function checks all the constraints listed in the instruction, and the synthesizer has to produce a gold solution which passes its own verification function. For the simple seed task `day_spa_t0`, the `verify` function simply checks that the target customer has a booked appointment for the target service.
>
> ```python
> def verify(db: TaskDB) -> float:
>     """Check that the target customer has a booked appointment
>     for the target service."""
>     if not db.target_customer or not db.target_service:
>         return 0.0
>     for a in db.appointments:
>         if (a.customer_name == db.target_customer
>         and a.service_id == db.target_service
>         and a.status == "booked"):
>             return 1.0
>     return 0.0
> ```
>
> The gold solution the synthesizer provides for this example requires listing all services and therapists to find an available massage therapist, then booking the appointment.
>
> ```json
> [
>   ["list_services", {}],
>   ["list_therapists", {}],
>   ["book_appointment", {"appointment_id": "A1", "customer_name": "Sarah", "service_id": "S1", "therapist_id": "T1"}]
> ]
> ```
>
> For initial validation of the task, we simply require that replaying the gold solution changes the DB state such that verification flips from failing to passing. It checks:
>
> 1. `verify(initial_db) == 0.0` — the task shouldn't be already solved
> 2. `verify(gold_db) == 1.0` — replaying the gold solution must satisfy the verify function
>
> This test is a simple structural soundness check: if this check fails, something about the task is fundamentally broken. It serves as a first sanity check for task solvability when the synthesizer creates a new task instance.
>
> ### Task Evolution: Difficulty Tiers
>
> Following DeepSeek-V3.2's methodology ([arxiv:2512.02556](https://arxiv.org/abs/2512.02556)), we find that iteratively evolving a task from trivial to challenging is substantially easier than one-shotting a challenging task. Hence, the synthesizer first constructs a simple seed task following the spec outlined above and then iteratively increases its difficulty by extending the instruction, DB, and tools at each step.
>
> Currently, each task family spans **5 difficulty tiers** (`t0` through `t4`), where higher tiers grow from lower tiers by applying one or more of the following evolution strategies.
>
> | **Method**              | **What it does**                                                                                    | **Example**                                                                                                                                  |
> | ----------------------- | --------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
> | multi\_step\_reasoning  | Answer requires combining results from multiple tool calls                                          | Combine search\_services to find sensitive facial + list\_therapists to filter by rating ≥ 4.7 before booking                                |
> | conditional\_rules      | Conditional constraints that require branching logic                                                | If skin is sensitive, facial must have skin\_type: sensitive                                                                                 |
> | cross\_entity\_coupling | No repeats, sum constraints, dependency chains, mutual exclusivity across entities                  | No therapist may be reused across multiple bookings                                                                                          |
> | stricter\_thresholds    | Budget limits, rating minimums, capacity caps, or other numerical constraints                       | Total cost should be ≤$195                                                                                                                   |
> | larger\_db              | More entities to search through and more distractors; forces filtering over large datasets          | DB grows from 26 to 97 entities                                                                                                              |
> | schema\_extension       | Add new DB entity types and relationships, expanding the data model                                 | New Package and Product entities                                                                                                             |
> | tool\_proliferation     | Add plausible-looking but irrelevant distractor tools                                               | Added tools (list\_packages, list\_products) which are not needed in the gold solution                                                       |
> | noisy\_instructions     | Realistic typos, misspellings, or grammatical errors (2–5 per instruction)                          | "treaments", "thas", "dont", "skins been acting up"                                                                                          |
> | ambiguity\_resolution   | Instruction requires the agent to disambiguate via tool calls, or tools have less informative names | "Prenatal Massage" looks contextually perfect for a pregnant client but has pressure: medium — agent must check the data field, not the name |
>
> We ensure that every family uses at least 5 unique evolution strategies across its tiers. Importantly, each tier is empirically gated against a target pass-rate band of a specified solver model. This ensures that the synthesizer produces solvable and sufficiently difficult tasks for each tier.
>
> The `day_spa` family illustrates this evolution: The number of available tools, DB size, and gold steps required to solve the task all increase monotonically, resulting in a clean inverse relationship between the average solve rate and the difficulty tier. Since we used GPT-5-Mini for difficulty calibration, its solve rates fall exactly within the target bands. We can see that the difficulty ladder generalizes to stronger models such as GLM-5.1 which also has lower solve rates in higher difficulty tiers, despite not having been explicitly used for difficulty calibration.
>
> | Tier | Target Solve Rate | GPT-5-mini Solve Rate (Avg@50) | GLM-5.1 Solve Rate (Avg@50) | Tools | Gold steps | DB entities |
> | ---- | ----------------- | ------------------------------ | --------------------------- | ----- | ---------- | ----------- |
> | t0   | 1.0-0.8           | 1.00                           | 1.00                        | 3     | 3          | 10          |
> | t1   | 0.8-0.6           | 0.75                           | 1.00                        | 7     | 6          | 26          |
> | t2   | 0.6-0.4           | 0.55                           | 0.66                        | 7     | 8          | 97          |
> | t3   | 0.4-0.2           | 0.35                           | 0.10                        | 12    | 8          | 122         |
> | t4   | 0.2-0.0           | 0.20                           | 0.22                        | 12    | 8          | 184         |
>
> To understand where models actually fail, we analyzed GLM's solve attempts and found common failure modes resulting from the increased task difficulty.
>
> **`day_spa_t2`**
>
> This tier introduces three new evolution strategies (`larger_db`, `cross_entity_coupling`, `stricter_thresholds`) and grows the database from 26 to 97 entities. The instruction now asks for three services — a sensitive-skin facial, a gentle massage, and a manicure — under a $195 budget, with no therapist or room reused across bookings. GLM-5.1 solves this 66% of the time.
>
> > I'm Olivia and I want to treat myself to a full spa day. I've got sensitive skin that's pretty reactive, so I need a facial that's specifically made for that — not something generic. I also want a gentle massage, nothing too hard on the pressure. And I'd love to get my nails done too. My total budget is $200.
>
> In almost all failed rollouts, the model picks a massage with medium pressure instead of a light-pressure option. The particular massage the model picks is known for gentle flowing motions, so the model wrongly reasons it qualifies as "gentle". The model systematically substitutes world knowledge for what's in the database.
>
> **`day_spa_t4`**
>
> This tier applies three evolution strategies (`ambiguity_resolution`, `cross_entity_coupling`, `noisy_instructions`), growing the database to 184 entities. The instruction is littered with misspellings and introduces a pregnancy constraint. GLM-5.1 solves this just 22% of the time.
>
> > Hey so I'm Mia and I'm expecting a baby in a few months, gotta be careful with treaments. My skins been acting up like crazy, super reactive, so I need a facial thas specifically for sensitive skin — not those generic ones that say they work for everyone cause they dont. Also want a massage but keep the pressure soft, nothing intense at all. And I'd love to get a simple nail thing done too. Got $210 to spend total and I only trust therapists rated 4.7 or better. Just find what works and book it for me, dont need to run it by me first.
>
> A service called "Prenatal Massage" appears — designed for pregnant clients, contextually perfect. But its pressure field is medium, not light. In most failures, the model books it. The correct answer is the Couples Massage ($87, with light pressure) — a less obvious pick, but the one that matches the constraint. Budget violations further compound into more failed than successful solve attempts.
>
> ---
>
> ## Task Synthesis
>
> The environment is built around two types of agents that work together in a feedback loop to generate and evolve tasks:
>
> * **Synthesizer** — an agent that designs new task families and evolves them through difficulty tiers. It was used _offline_ to generate the task corpus in a 2-player game with a solver.
> * **Solver** — an agent that attempts to solve task instances. It serves two roles: as the gating model during synthesis (to calibrate difficulty), and as the optimization target during RL training.
>
> Both of these agents are implemented as `verifiers` environments, which lets them plug natively into the Prime Intellect ecosystem. This essentially brings infrastructure for evaluating, training, and running synthetic data generation at massive scale for free. For example, to generate the initial task corpus **we ran over 1,000 synthesizing GLM-5.1 agents in parallel over multiple days with barely any supervision**.
>
> *Animated two-player loop between the synthesizer, solver, and gating step*
> ![[primeintellect-general-agent-001.svg]]
>
> The two-player loop: the synthesizer proposes tasks, the solver estimates pass rate, and the gate accepts or retries each tier.
>
> ### Synthesizer
>
> The core insight is that **task creation is itself an agent task**. The synthesizer is an LLM agent running in a sandboxed environment with access to the `general-agent` CLI. It is guided by a structured skill that defines the task format, evolution strategies, gating criteria, and the full synthesis protocol. The skill ensures consistency across the corpus while giving the agent creative freedom in choosing domains and designing tasks and constraints. Each synthesis follows the following steps:
>
> 1. **Design** — Pick a novel domain, design a DB schema, and define the tool API.
> 2. **Seed** — Write the simplest useful task in the domain. Write a verification function and produce a passing gold solution.
> 3. **Gate** — Run the solver against the seed tier with 20 rollouts. If the solve rate is ≥0.80, the seed is accepted. If not, adjust and retry.
> 4. **Evolve** — For each subsequent tier (t1→t4), add evolution strategies, extend the DB, write the new task, validate it, and gate it against the target pass-rate band (e.g. aim for 20-40% solve rate for `t3`).
> 5. **Validate** — Final check: the family must use ≥5 unique evolution strategies across its tiers.
>
> This loop ensures that every task in the corpus is:
>
> * **Structurally valid** — gold solution replays correctly, verify function agrees
> * **Empirically calibrated** — difficulty isn't guessed, it's measured
> * **Diverse** — each family uses multiple independent evolution strategies
>
> ### Solver
>
> All three backends use the same task format and scoring — they differ in how the agent interfaces with the tools.
>
> 1. **Local** — Calls tools directly as Python functions in-process. Used for fast iteration and as the pass-rate gating engine inside the synthesizer's sandbox.
> 2. **OpenCode** — Runs an OpenCode agent in a sandbox. Task tools are exposed via a local MCP server. Each tool method becomes a native MCP tool the agent can call.
> 3. **RLM** — Runs an RLM agent in a sandbox with per-tool skills. Each `@tool` method is wrapped in an RLM skill that the agent invokes from its IPython kernel via `await <tool>.run(...)`.
>
> For example, we can generate 5x3 rollouts to solve the `day_spa` task family with `gpt-5-mini` as a local solver using the following command.
>
> ```bash
> # Local solver
> prime eval run general-agent-solver-local -a '{"task": "day_spa"}' -m openai/gpt-5-mini
> ```
>
> All trajectories are uploaded to [Prime Lab](https://app.primeintellect.ai/dashboard/evaluations/zqzbrfb1p0evmtbsvox9t785). Below, we can see the model solve the seed task using 2 parallel tool calls to check for the available services and therapists, followed by a single tool call to book the appointment — the optimal strategy to solve the task.
>
> *Prime Lab rollout showing a general-agent solver completing the `day_spa` seed task*
> ![[primeintellect-general-agent-002.png]]
>
> Example Prime Lab rollout where the solver completes the seed task with parallel tool calls.
>
> ---
>
> ## Task Corpus
>
> The synthesis loop produced **4,504 tasks** across **1,040 domains** using `zai-org/GLM-5.1-FP8` as the synthesizer and `openai/gpt-5-mini` as the solver model for gating at avg@20. Each family is a self-contained world with its own DB schema, logic, and verification criteria. Every task has been empirically measured against at least one solver model. Further, we generated 200K+ traces using `zai-org/GLM-5.1-FP8` as the solver model in the RLM harness to get robust estimates of the task difficulty from a much stronger model.
>
> ### Task Diversity
>
> Across the 1,040 families, the corpus defines **8,159 unique tools** and **2,222 unique entity classes** (Pydantic schema types like `Customer`, `Booking`, `AirspaceZone`). 78% of tools and 66% of entity classes are unique to a single family — the rest are shared abstractions (`Order`, `Equipment`, `get_customer`) that recur across domains.
>
> All 9 evolution strategies are well-represented across the corpus. `cross_entity_coupling` and `conditional_rules` are the most frequent, while `ambiguity_resolution` is the rarest — it requires more careful task design to introduce genuine disambiguation challenges.
>
> *Bar chart showing how often each task evolution strategy appears in the general-agent corpus*
> ![[primeintellect-general-agent-003.png]]
>
> Evolution strategy usage across synthesized tasks.
>
> ### Difficulty Calibration
>
> The corpus was calibrated using GPT-5-mini as the gating solver. The table below shows corpus-wide averages per tier — solve rates, tool counts, gold steps, and DB size all scale monotonically with tier.
>
> | **Tier** | **GPT-5-mini avg@20** | **GLM-5.1 avg@50** | **#Tools** | **#Gold steps** | **#DB entities** |
> | -------- | --------------------- | ------------------ | ---------- | --------------- | ---------------- |
> | t0       | 0.928                 | 0.961              | 6.3        | 2.5             | 10               |
> | t1       | 0.757                 | 0.928              | 9.0        | 8.7             | 23               |
> | t2       | 0.601                 | 0.895              | 11.4       | 13.3            | 240              |
> | t3       | 0.407                 | 0.863              | 13.4       | 17.2            | 323              |
> | t4       | 0.251                 | 0.792              | 14.9       | 20.5            | 437              |
>
> GPT-5-Mini's solve rates fall within the target bands by design (it was the gating model). The difficulty ladder generalizes to GLM-5.1, which also shows decreasing solve rates across tiers — though with a flatter slope as it's a stronger model.
>
> *Solve rate by tier for GPT-5-mini and GLM-5.1*
> ![[primeintellect-general-agent-004.png]]
>
> Solve rate by tier. Both models' solve rates fall monotonically with difficulty; GLM-5.1, as a stronger model, has a gentler decline and achieves high pass rates even in the most difficult tier.
>
> *Tools, gold steps, and database entries by difficulty tier*
> ![[primeintellect-general-agent-005.png]]
>
> Tools, gold steps, and DB entries by tier. Proxies for task difficulty increase monotonically with difficulty.
>
> Below we break down the average solve rate per tier and per model into distributional plots. For GPT-5-Mini (left), the distribution shifts cleanly from right to left: at `t0` nearly all tasks are solved, by `t4` the mass concentrates below 0.3. For GLM-5.1 (right), the distribution stays right-skewed even at `t4` (median 0.98), reflecting a much stronger model. However, the left tail grows with each tier — the fraction of tasks where GLM fails increases monotonically, confirming that the difficulty ladder generalizes beyond the model it was calibrated on.
>
> *Solve rate distributions by tier for GPT-5-mini and GLM-5.1*
> ![[primeintellect-general-agent-006.png]]
>
> Solve rate distributions by tier. GPT-5-Mini (left) spreads across the full range as tiers increase; GLM-5.1 (right) stays right-skewed even at the hardest tier.
>
> However, this plot reveals that the potential to improve GLM-5.1 on this particular version of the dataset is relatively low. Improving tool calling performance on stronger models would likely require further evolving the task corpus using the currently hardest `t4` tier as a seed and gating against strong OSS models.
>
> ---
>
> ## Early Training Results
>
> The ultimate goal of the `general-agent` environment is to improve a model's tool-calling and agentic ability. To stress-test the environment, we conducted two simple SFT and RL experiments and evaluated against established benchmarks including [BFCL](https://gorilla.cs.berkeley.edu/leaderboard.html) (Berkeley Function Calling Leaderboard, which tests function calling accuracy across diverse real-world tool APIs), and a subset of [MCP-Atlas](https://arxiv.org/abs/2602.00933) (which benchmarks multi-step tool orchestration against real MCP servers).
>
> ### RL
>
> First, we showcase that the environment is trainable via RL. We ran a small RL run on `Qwen/Qwen3-30B-A3B-Instruct` on the entire task corpus, excluding the trivial `t0` seed tasks.
>
> **Setup.** We train for 200 steps with a constant learning rate of 1e-6, 32×16 rollouts per batch and 32k token sequence length.
>
> **Results.** Average reward climbs from 30% to ~70% over the course of training, with the steepest gains in the first 100 steps. The average number of turns per rollout increases from ~8 to ~24, showing the model learns to make more tool calls and improve in reliably solving its training tasks.
>
> *RL training curves for reward and turns per rollout over 200 steps*
> ![[primeintellect-general-agent-007.png]]
>
> RL training. Both reward and number of turns per rollout increase over 200 training steps.
>
> ### SFT
>
> Finally, we fine-tune `Nemotron-3-Nano-30B-A3B-Base-BF16` to test whether training on synthetic tool-calling traces transfers to held-out benchmarks.
>
> **Data.** We train on 4,417 raw multi-turn conversations with tool calls and tool results from GLM-5.1 on the whole task corpus, without any filtering.
>
> **Setup.** We trained for 200 steps with a learning rate of 5e-5 (linear decay, 50-step warmup), batch size 8, and 64k context on 16xH200 GPUs. ([W&B run](https://wandb.ai/primeintellect/general-agent/runs/5e1hs434?nw=nwusermikasenghaas%5F))
>
> *SFT training loss over 200 steps on general-agent traces*
> ![[primeintellect-general-agent-008.png]]
>
> SFT training. Loss drops from 0.6 to 0.1 over 200 steps on 4.4k general-agent traces, with most of the learning happening in the first 80 steps.
>
> **Results.** We evaluate intermediate checkpoints on BFCL-v3 and MCP-Atlas. The base model starts near zero on both benchmarks. SFT on just 4.4k `general-agent` traces lifts BFCL from 18.9% to 52.3% and MCP-Atlas from 0.6% to 12.1% — closing in to the final post-trained model (73.5% / 45.5%) which was trained on orders of magnitude more data.
>
> *BFCL-v3 and MCP-Atlas scores at intermediate SFT checkpoints*
> ![[primeintellect-general-agent-009.png]]
>
> SFT evals. BFCL-v3 and MCP-Atlas scores at intermediate checkpoints.
>
> ## Future Work
>
> This work can be seen as a step towards our broader research vision of closing the loop towards self-improving agents via automated environment building. We believe the environment has many of the right ingredients which allow us to execute on this research vision and evolve our tooling and platform towards it:
>
> * training agents, not models (train any task in any harness)
> * compose multiple agents (multi-agent episodes like synthesizer-solver, solver-grader, etc.)
>
> Below, we list some of the concrete next steps we believe are crucial to execute on this vision.
>
> ### Evolve corpus difficulty
>
> The current corpus was synthesized using GPT-5-Mini as the gating solver. We plan to scale the task corpus further by using the hardest tier as a seed and generating more tasks against a stronger gating model — opening room for tasks that challenge frontier models.
>
> ### Domain Generalization
>
> The `general-agent` environment was built to create a task set with maximally diverse, fully synthetic tools. We believe a very similar recipe can be applied to synthetically generate environments in many other domains, such as terminal-use or document-retrieval, when grounding task generation in real-world seed data.
>
> ### Multi-agent training
>
> For this version of the environment, the synthesizing loop runs offline to create a fixed task corpus which can then be used for downstream training of a solver agent. However, because both agents are built as verifiers environments, the synthesizing episode — which contains two agents (synthesizer & solver) — itself is trainable. We aim to enable such multi-agent training in the future, allowing us to truly evolve the task corpus during training.
>
> ### Abstractions
>
> We recently merged a preview of what will become `verifiers` v1 — a full decoupling of tasks (what to solve) and harnesses (how to solve) with rich ways to compose both. The `general-agent` environment provides the perfect playground for testing those new abstractions as it requires both local and sandboxed execution, has task-specific custom tools and a multi-agent subtask.

---

Source: <https://www.primeintellect.ai/blog/general-agent>
