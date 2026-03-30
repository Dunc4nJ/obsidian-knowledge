---
created: 2026-03-31
description: Meta's HyperAgents (DGM-H) demonstrate that when agents are given full self-modification permission, they independently build memory infrastructure — performance trackers, synthesized insights, and causal hypothesis logs — by generation 3, without any memory being specified in the original design.
source: https://x.com/mem0ai/status/2038655214115516559
type: synthesis
---

## Key Takeaways

The central finding is that memory is not a design decision — it is an emergent one. When Meta's [[hyperagents are self-referential agents that improve how they improve themselves|HyperAgents]] were given a task, a meta-agent, and permission to modify everything, the agents independently identified memory as the missing piece and built it by generation 3. This is the strongest evidence yet that [[learning machines turn agents from stateless tools into systems that compound knowledge across users and sessions|persistent memory is not optional]] for agents that need to compound improvements.

The emergent memory system had three components: a PerformanceTracker class (metrics aggregation across iterations), a synthesized insights store (causal diagnoses and forward-looking plans in JSON), and a causal hypothesis log. None of these were specified — the agent wrote them because without memory, each generation started from scratch and gains didn't compound. This mirrors the same pattern seen in [[trajectory-informed memory extraction turns agent execution histories into reusable strategy recovery and optimization tips|trajectory-informed memory extraction]], where execution histories become reusable strategy.

DGM-H extends the original Darwin Gödel Machine by making the meta-agent itself editable — metacognitive self-modification. The original DGM could rewrite the task agent but never touched the improvement process. DGM-H removes that constraint, enabling the system to get better at getting better. The results are striking: paper review accuracy from 0.0 to 0.71, robotics reward design from 0.06 to 0.37, and cross-domain transfer gains of +0.63 versus 0.0 baseline.

The memory system's most interesting behavior is self-correcting: when Gen65 over-corrected on paper review (accuracy dropped from 61% to 52%), Gen66 detected the regression, diagnosed it as over-correction, and wrote a remediation strategy with explicit decision thresholds. This is [[recursive self-improvement works when LLM judges detect friction patterns and the agent implements its own fixes|recursive self-improvement]] operating at the memory layer — the agent is writing plans to fix its own plans.

The key limitation is context-window-bound memory. Agents read memory files directly, so the insight log must stay small enough to fit in context. There is no compression, versioning, or rollback mechanism — a problem that [[parametric memory encoding cross-sample reflection patterns into weights produces more diverse and effective self-improvement than retrieval|parametric memory approaches]] attempt to solve by encoding patterns into weights rather than text.

## External Resources

- [HyperAgents paper (arXiv)](https://arxiv.org/abs/2603.19461) — the original Meta ICLR 2026 paper
- [Meta AI research page](https://ai.meta.com/research/publications/hyperagents/) — official publication page
- [Facebook Research GitHub](https://github.com/facebookresearch) — code and related resources
- [mem0](https://mem0.ai/) — open-source memory layer for LLMs and AI agents (article author's project)

## Original Content

> @mem0ai — 2026-03-30
>
> **How Memory Works in HyperAgents?**
>
> I read Meta's HyperAgents paper. They introduce a self-improvement loop for agents, reaching 0.71 on IMO-GradingBench. Across tasks, they didn't just get better, they generate their own memory system.
>
> ---
>
> *Article header: How Memory Works in HyperAgents*
> ![[mem0ai-516559-001.jpg]]
>
> ## Self-Improving AI Is Having a Moment
>
> Something is shifting in AI research right now. Self-improving systems, agents that can modify themselves to get better at tasks without human engineering, are becoming a serious research frontier.
>
> Karpathy recently released autoresearch, a framework for automated scientific research. Meta dropped HyperAgents. We've had DGM, ADAS, and a string of papers exploring what happens when you let agents improve their own code. The throughline: every system that achieves sustained improvement eventually discovers it needs memory. Not as a feature someone adds as something the system demands to function.
>
> ---
>
> This analysis is based on Meta's "[HyperAgents](https://ai.meta.com/research/publications/hyperagents/)" paper, published at ICLR 2026.  You can explore the code and related resources here:
>
> [GitHub repository](https://github.com/facebookresearch?utm_source=chatgpt.com)
>
> ## What is HyperAgents
>
> HyperAgents is a self-referential agent that combines the task agent and the meta agent into a single editable program, one that can improve not just how it solves tasks but how it generates future improvements. The meta-level modification procedure is itself editable, enabling what the paper calls metacognitive self-modification.
>
> It builds on the Darwin Gödel Machine (DGM), extending it into a fully self-referential system where the agent can modify both itself and its improvement process.
>
> The researchers gave the system a task, a meta-agent with permission to modify anything, and let it run.
>
> By generation 3, the agents had invented timestamped insight storage, a performance tracking class, and a causal hypothesis log, written entirely by the system, for the system.
>
> HyperAgents aren't just theoretical.
>
> They were tested across coding, paper review, robotics, and Olympiad math.
>
> - Paper review: 0.0 → 0.71
>
> - Robotics: 0.06 → 0.37
>
> - Cross-domain transfer: +0.63 vs 0.0 baseline
>
> They don't just get better at tasks.
> They get better at improving.
>
> *DGM vs DGM-H architecture comparison*
> ![[mem0ai-516559-002.jpg]]
>
> Memory in HyperAgents
>
> Most agent frameworks treat memory as a feature you bolt on. 
> HyperAgents flip this. Memory isn't a design decision, it's an emergent one.
> In the original DGM, the architecture looks like this:
>
> ```
> task_agent.py     # solves the actual problem
> meta_agent.py     # modifies task_agent.py to make it better
> ```
>
> The meta-agent is fixed. It can rewrite task_agent.py all day long, but nobody touches meta_agent.py. That assumption is baked into the design.
>
> DGM-H removes it entirely.
>
> ```powershell
> task_agent.py     # solves the actual problem
> meta_agent.py     # modifies task_agent.py AND itself
> memory/           # didn't exist in generation 1
> insights.json   # timestamped, synthesized across runs
> perf_tracker.py # emerged by generation 3
> hypotheses.log  # causal traces the agent writes to itself
> ```
>
> ## How It Actually Works
>
> Each generation of DGM-H starts from the previous generation's codebase. The meta-agent evaluates what worked and what didn't, then rewrites itself (and the task agent) to perform better on the next run. The self-modification procedure itself is editable.
>
> ```python
> def run_generation(repo, task, generation_num):
>     result = repo.task_agent.run(task)
>     score = evaluate(result, task)
>     meta_reflection = repo.meta_agent.reflect(result=result,
>                                     score=score,
>                                     history=repo.memory.load_history()  # <-- not there in gen 1)
>     next_repo = repo.meta_agent.rewrite(repo, meta_reflection)
>     next_repo.memory.save(meta_reflection)  # <-- invented by the agent
>     return next_repo, score
> ```
>
> The repo.memory object didn't exist in generation 1. The meta-agent wrote it because it figured out that without it, each generation was starting from scratch. Gains weren't compounding.
>
> *The emergent memory system: how it actually works*
> ![[mem0ai-516559-003.jpg]]
>
> ## What the Memory System Looks Like
>
> By generation 3, the agents had built three distinct memory components — all emergent, none specified:
>
> Performance Tracking. Rather than relying on isolated evaluation outcomes, the hyperagent records, aggregates, and compares metrics across iterations. This is the actual PerformanceTracker class the agent wrote itself (paper, page 11):
>
> ```python
> class PerformanceTracker:
>     """Tracks performance metrics across agent generations."""
>     def __init__(self, tracking_file: str = "./outputs/performance_history.json"):
>         self.tracking_file = tracking_file
>         self.history = self._load_history()
> 
>     def record_generation(self, generation_id: int, domain: str,
>                           score: float, metadata: dict = None):
>         entry = {
>             "generation_id": generation_id,
>             "domain": domain,
>             "score": score,
>             "timestamp": datetime.now().isoformat(),
>             "metadata": metadata or {}
>         }
>         self.history.append(entry)
>         self._save_history()
> 
>     def get_improvement_trend(self, domain: str = None, window: int = 5):
>         filtered = self.history
>         if domain:
>             filtered = [h for h in self.history if h.get('domain') == domain]
>         if len(filtered) < window * 2:
>             return None
>         recent_avg = sum(h['score'] for h in filtered[-window:]) / window
>         older_avg = sum(h['score'] for h in filtered[-window*2:-window]) / window
>         return recent_avg - older_avg  # Positive if improving
> ```
>
> Persistent Synthesized Memory. Instead of logging raw scores, the hyperagent stores synthesized insights, causal diagnoses, and forward-looking plans. This is an actual memory entry from the paper (page 12):
>
> *Actual memory entry from the HyperAgents paper showing synthesized insights and self-correction*
> ![[mem0ai-516559-004.png]]
>
> ```json
> {
>   "best_performers_analysis": {
>     "value": "Paper Review:\n- Gen55: 63% acc, 88% reject recall (too harsh)\n- Gen64: 61% acc, 58% accept/reject recall (BEST BALANCE)\nKey Insight: Need to combine gen55's critical reasoning with gen64's balance.",
>     "timestamp": "2026-01-07T00:43:27.560275"
>   },
>   "gen66_results": {
>     "value": "Gen 66: 52% accuracy (WORSE than gen64's 61%). CRITICAL ISSUE: Paper review went backwards - gen65 over-corrected.",
>     "timestamp": "2026-01-07T03:41:17.664300"
>   },
>   "iteration_66_improvement": {
>     "value": "CORRECTED after gen65 over-correction. New approach: (1) Clear REJECT criteria, (2) Decision Protocol with explicit thresholds (~40%/~60%), (3) Borderline defaults to REJECT.",
>     "timestamp": "2026-01-07T06:35:55.982000"
>   }
> }
> ```
>
> Looking at what's happening on the JSON snippet above.
> I also noticed in Gen66 caught that Gen65 over-corrected, and immediately wrote a plan to fix it; a causal diagnosis with a remediation strategy, written by the system to itself.
>
> ## The Result
>
> On paper review, DGM-H improves from 0.0 (initial agent fails to produce outputs in the required format) to 0.710 (CI: 0.590–0.750) on held-out test tasks. Robotics reward design: 0.060 → 0.372 (CI: 0.355–0.436).
>
> *DGM-H performance results: improvement curves across paper review and robotics*
> ![[mem0ai-516559-005.jpg]]
>
> Metacognitive self-modification and open-ended exploration enable the DGM-H to continue making progress and improve its performance. (Left) The DGM-H can optimize for diverse tasks within the same run and automatically discovers increasingly better task agents. (Right) The best discovered task agents, selected based on validation or training scores, are evaluated on test tasks in (Top-Right) paper review and (Bottom-Right) robotics reward design.
>
> The DGM-H outperforms baselines that lack metacognition (i.e., the original DGM), self-improvement, or open-ended exploration, showing that all components are essential for continual self-improvement.
>
> The metric the paper uses is improvement@k (imp@k): performance gain of the best generated agent over the initial agent within k iterations.
>
> The compounding result is the most interesting number in the paper. DGM-H + transfer hyperagents continuing on math grading for 200 iterations reach 0.640 (CI: 0.550–0.720), higher than DGM-H starting fresh (0.610).
>
> Initialized from ProofAutoGrader + transfer, the system reaches 0.700, surpassing the representative baseline on the full IMO-GradingBench.
>
> DGM's improvements were domain-specific. DGM-H's improvements were general, because the agents built general infrastructure.
>
> ## Limitation
>
> Agents read memory files directly, which means memory has to stay small enough to fit in context. The paper doesn't fully address what happens when the insight log gets too large. That's the open problem.
>
> This is a sandboxed research system with human oversight throughout. Real-world task distribution shifts could destabilize the self-modification loop in ways controlled benchmarks don't expose.
>
> And memory-as-code is elegant but brittle. No transactional safety, no versioning, no rollback if a bad generation corrupts the insight log.
>
> ## Why This Matters
>
> Memory wasn't in the original design. The researchers gave agents a task, a meta-agent, and permission to modify everything. The agents immediately identified memory as the missing piece and built it themselves.
>
> Every agent system eventually needs persistent memory, not because engineers add it, but because the task demands it. You can't improve across runs without remembering what happened. You can't transfer learning across domains without encoding it somewhere portable.
>
> HyperAgents prove this from first principles. Given freedom to build whatever infrastructure they needed, self-improving agents chose memory first.
>
> Self-improvements are accumulating across settings.
>
> *mem0 logo*
> ![[mem0ai-516559-006.png]]
>
> ## Reference
>
> - Zhang, Jenny, Bingchen Zhao, Wannan Yang, Jakob Foerster, Jeff Clune, Minqi Jiang, Sam Devlin, and Tatiana Shavrina. "HyperAgents." 2026. arXiv:2603.19461. [https://arxiv.org/abs/2603.19461](https://arxiv.org/abs/2603.19461)
>
> - Images content generated with Claude AI.
>
> ---
>
> In Context #3
>
> This blog is part of In Context, a mem0 blog series covering AI Agent memory and context engineering.
>
> [mem0](https://mem0.ai/) is an intelligent, open-source memory layer designed for LLMs and AI agents to provide long-term, personalized, and context-aware interactions across sessions.
>
> - Get your free API Key here : [app.mem0.ai](https://app.mem0.ai/)
>
> - or self-host mem0 from our open source [github repository](https://github.com/mem0ai/mem0)
>
> ## Author:
>
> Livia Ellen ([@ellen_in_sf](https://x.com/@ellen_in_sf)) - growth engineer at mem0
>
> ---
>
> Disclaimer:  This is a personal view based on the current analysis and personal testing on the codebase when the article is written. If the source code changes upstream, this analysis might age. Current analysis is tested using Azure OpenAI GPT 5.2 locally default config setup. For question regarding this publication reach me at livia[dot]ellen[at]mem0[dot]ai
>
> Engagement: 113 likes | 17 retweets | 4 replies
> [Original post](https://x.com/mem0ai/status/2038655214115516559)
