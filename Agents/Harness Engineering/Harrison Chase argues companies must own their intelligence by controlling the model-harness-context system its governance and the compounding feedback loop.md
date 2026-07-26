---
created: 2026-07-26
description: Harrison Chase's (LangChain) flagship manifesto on "owning your intelligence" — generic model access is undifferentiated, so lasting advantage comes from controlling the agent system (model + harness + context), owning its economics/quality/risk, and compounding a traces→feedback→evals learning loop over time. Ends with a 10-question ownership checklist.
source: https://x.com/hwchase17/status/2081002647814094888
author: "@hwchase17 (Harrison Chase)"
type: article
tags: [harness-engineering, model-neutrality, context-engineering, agent-memory, evals, observability, continual-learning, langchain]
---

## Key Takeaways

- **The thesis: own the layer where advantage compounds, not every layer.** Chase argues every company will soon use AI either to run critical operations or as the product they sell — and in both cases generic intelligence is not enough, because "everyone else can call the same API." Off-the-shelf models know what a "deductible" means but not how to handle *this* claim, in *this* jurisdiction, under *this* policy; the product is the *system around* the model (workflows, retrieved context, tools, evals, memory, feedback loop). Ownership doesn't mean building every layer from scratch — it means controlling the parts that determine how intelligence behaves and whether it compounds. This is the LangChain-founder capstone of the vault's recurring claim that [[the harness is the product because model capability is commoditizing while accumulated context is not]] and [[agent harnesses are the product not the model]].

- **Controlling the agent system means owning all three layers: model, harness, context.** The *model* layer is owned via optionality — open-weights for sovereignty/portability, and the ability to switch providers as quality/cost/latency/privacy shift (defensive: avoids lock-in; offensive: adopt the best model the day it ships), the practical case being that [[Open models now match closed frontier models on core agent harness tasks at a fraction of the cost]]. The *harness* is the orchestration logic (routing, tool use, workflow steps, skills) where company-specific behavior lives — a closed harness means accepting someone else's assumptions, per [[the harness is everything and agent performance comes from environment design not model capability]]. The *context* layer (documents, policies, skills, user prefs, org knowledge, memory) is what makes generic intelligence specific — see [[how-top-ai-companies-handle-context-engineering]] — and critically, [[Memory ownership follows harness ownership - Harrison Chase argues picking a closed harness is picking a permanent owner for your agent's data flywheel|if you don't own context and memory you don't own the intelligence the system accumulates]].

- **Once AI does real work, manage it like an operating system: economics, quality, risk.** Cost matters because intelligence is only valuable if it's cheap relative to the return (the [Uber "burned its 2026 AI budget in four months"](https://www.forbes.com/sites/janakirammsv/2026/05/17/uber-burns-its-2026-ai-budget-in-four-months-on-claude-code/) cautionary tale), so per-user/org/agent cost lock-down is a scaling prerequisite. Quality must be *measured, not assumed* — every model swap, prompt change, or new tool needs an eval to know if it improved or regressed, echoing [[LangChain's Better-Harness uses eval-driven hill-climbing for agent harness improvement]]. Boundaries define where agents act independently vs. need approval ([[Factory droid exec uses tiered autonomy levels to gate agent permissions from read-only to full system access|tiered-autonomy permission gating]]), and observability makes the system auditable — you must see what the agent saw, did, and why, which is exactly [[LangChain's Harrison Chase argues agent observability needs feedback attached to traces to power learning|why observability needs feedback attached to traces]].

- **The real payoff is compounding: the 100th interaction should beat the 1st.** The learning loop starts with *traces* (what the agent saw, called, got stuck on, produced), gains meaning from *feedback* (accepted / rejected / inefficient / risky / wrong), and turns that into improvements to prompts, harness, and tools — with an eval added per change to lock in the gain and prevent regressions. This is the same mechanism as [[the agent improvement loop is traces enriched with evals and human feedback converted into validated fixes]]. The learnings must be *portable and owned* — model-to-model, system-to-system — reframing continual learning as [[LangChain's Harrison Chase argues continual learning for AI agents extends beyond model fine-tuning to harness engineering and context updates|harness engineering and context updates, not just model fine-tuning]]. What matters is not how the agent does the first time, but how much better it is the 100th.

- **The strategic choice + a 10-question ownership checklist.** Buy the parts that are hard, generic, and undifferentiated; own the layer where advantage compounds — the agent system, its governance, and the feedback loop. This slots into Chase's broader [[Harrison Chase frames agent development as a Build-Test-Deploy-Monitor lifecycle wrapped by iteration and governance|Build-Test-Deploy-Monitor lifecycle]]. The checklist operationalizes ownership: can you instantly switch to a new SOTA model? self-host a deprecated one? know and control exactly what enters the LLM at every step? run identically across cloud/on-device? monitor+control spend per user? produce a full trace for any action? trust that model swaps won't regress (evals)? guarantee the 100th use beats the 1st? port learnings to an entirely different system? control *how* the agent learns?

*The full thesis on one page — the owned intelligence system (model + harness + context) ringed by governance, quality/cost, feedback loop, and portability:*
![[hwchase17-094888-001.png]]

## External Resources

- Original article: [What does it mean to "own your intelligence"? — @hwchase17](https://x.com/hwchase17/status/2081002647814094888)
- LangChain blog references cited in the piece: [Model neutrality](https://www.langchain.com/blog/model-neutrality) · [Context engineering for agents](https://www.langchain.com/blog/context-engineering-for-agents) · [How to give your agent memory](https://www.langchain.com/blog/how-to-give-your-agent-memory) · [Your harness, your memory](https://www.langchain.com/blog/your-harness-your-memory) · [Building governed agents (cost control & compliance)](https://www.langchain.com/blog/building-governed-agents-a-framework-for-cost-control-and-compliance) · [On agent frameworks and agent observability](https://www.langchain.com/blog/on-agent-frameworks-and-agent-observability) · [In software the code documents the app, in AI the traces do](https://www.langchain.com/blog/in-software-the-code-documents-the-app-in-ai-the-traces-do) · [Improving agents is a data-mining problem](https://www.langchain.com/blog/improving-agents-is-a-data-mining-problem)
- LangChain docs: [model optionality / switching providers](https://docs.langchain.com/oss/python/langchain/models) · [evaluation concepts](https://docs.langchain.com/langsmith/evaluation-concepts)
- Referenced example: [Uber burns its 2026 AI budget in four months on Claude Code (Forbes)](https://www.forbes.com/sites/janakirammsv/2026/05/17/uber-burns-its-2026-ai-budget-in-four-months-on-claude-code/) · [Jensen Huang on open-weight models](https://x.com/JensenHuang/status/2080643682408321103)

## Original Content

> [!quote]- Full X Article — "What does it mean to 'own your intelligence'?" (@hwchase17 / Harrison Chase, LangChain, 2026-07-25)
> Article: What does it mean to "own your intelligence"?
>
> Over the next five years, every company will use AI in one of two ways: to run critical parts of their business, or as part of the product they sell to customers. In both cases, generic intelligence will not be enough.
>
> To have real impact, companies need to own their intelligence. Ownership does not mean building every layer from scratch. It means controlling the parts that determine how intelligence behaves, how it’s managed, and whether it compounds over time.
>
> # Off-the-shelf intelligence does not know your business
>
> Off-the-shelf AI is useful because it is general. It can answer common questions and reason across a broad set of topics. This makes it helpful to get started. But to assume that generic intelligence can run operations inside a company would be a gross simplification.
>
> Companies have MANY specifics in the way they operate. The deeper you embed AI into your company, the more these specifics matter. If you are hoping to use AI as a core part of operating your company, these specifics matter a lot.
>
> As a concrete example, let’s consider a large insurer using AI to help process claims. A generic model can read a policy document, summarize a claim, and explain common coverage concepts. But to actually do the work to handle a claim depends on the insurer’s own policy language, state-by-state regulatory requirements, fraud signals, historical claim patterns, escalation rules, customer tiering, and risk tolerance. These specifics will not be in a generic models weights. A generic model knows the meaning of the word “deductible”. But it does not know how to handle a specific type of claim, for this customer, in this jurisdiction, under this policy, with this evidence.
>
> The same logic applies when AI is the product itself. If you are a vertical AI startup building an [AI support agent](https://www.youtube.com/watch?v=uCKhOmth2ms), legal assistant, or [coding agent](https://www.youtube.com/watch?v=HbUznYhKFOc) - the base model is not your product. Everyone else can call the same API. Your product is the system around the model: the workflows it handles, the context it retrieves, the tools it can use, the evals that define quality, the memory it builds, and the feedback loop that improves it with every customer interaction.
>
> In both cases, the advantage is not generic intelligence. It is intelligence adapted to a specific business.
>
> Any company can use AI. But this generic intelligence will not be enough to drive meaningful ROI or build a differentiated product. Companies built around AI will own their intelligence.
>
> # What it means to own your intelligence
>
> Owning your intelligence does not mean building every layer of the AI stack yourself. It means controlling the critical parts - the parts that determine how intelligence behaves, what it learns from, how much it costs, and whether it improves over time.
>
> A useful analogy here: the supply chain. A retailer does not need to manufacture every truck, ship, or warehouse robot it uses. But it does need to own the system that determines what gets sourced, how inventory moves, how demand is forecast, and how the customer experience is delivered.
>
> AI works the same way. You can buy models, compute, and infrastructure. But you need to own the system that turns those inputs into intelligence specific to your business.
>
> There are three parts to this: controlling the agent system; owning the economics, quality and risk; and compounding the intelligence over time.
>
> ## Controlling the agent system
>
> *The three ownable layers — context, harness, model — feeding business-specific agent work over a control plane of observability, evals, cost controls, risk boundaries, and audit trails:*
> ![[hwchase17-094888-002.png]]
>
> An agent is the bridge between raw intelligence and work. The model provides the intelligence. The harness determines how that intelligence is applied. Context tells the system what matters in a specific situation.
>
> The first layer is the [model](https://www.langchain.com/blog/model-neutrality). Owning the model can mean [using open-weight models](https://x.com/JensenHuang/status/2080643682408321103?s=20) when sovereignty, portability, or deployment control matters. It can also mean preserving model optionality: the ability to [switch across providers](https://docs.langchain.com/oss/python/langchain/models) as quality, cost, latency, and privacy requirements change. Optionality is defensive because it avoids lock-in. It is offensive because it lets you adopt the best model as soon as it appears.
>
> The second layer is the harness: the orchestration logic that turns model outputs into actions. The harness controls everything [around how context is used](https://www.langchain.com/blog/context-engineering-for-agents): routing, tool use, workflow steps, skills, and more. This is where much of the company-specific behavior lives. If the harness is closed, you are accepting someone else’s assumptions about how your agent should work.
>
> The third layer is the context itself. Context is what makes generic intelligence specific: documents, policies, tools, skills, user preferences, organization-level knowledge, and memory. Memory is especially important because it is [how the system becomes more useful](https://www.langchain.com/blog/how-to-give-your-agent-memory) over time. [If you do not own context and memory](https://www.langchain.com/blog/your-harness-your-memory), you do not own the intelligence your system accumulates.
>
> To own the agent system, you need control over all three: the model, the harness, and the context.
>
> ## Own the economics, quality, and risk
>
> Once AI is doing real work, companies need to manage it like any other operating system. That means controlling the cost of the work, [measuring its quality](https://docs.langchain.com/langsmith/evaluation-concepts), defining where the system can act, and knowing what happened when it does.
>
> Cost matters because intelligence is only valuable if it is cheap relative to the return it generates. As AI adoption has increased rapidly, so have costs - see [Uber’s cautionary tale](https://www.forbes.com/sites/janakirammsv/2026/05/17/uber-burns-its-2026-ai-budget-in-four-months-on-claude-code/) as an example. [Being able to lock down costs](https://www.langchain.com/blog/building-governed-agents-a-framework-for-cost-control-and-compliance) - on a user, orgs, or agent level - is crucial to being able to scale AI reliably.
>
> Quality needs to be measured, not assumed. If you upgrade a model, change a prompt, add a tool, or adjust a workflow, you need to know whether the system got better or regressed. If you are unable to measure this, you are unable to improve your agent systematically, which means you are unable to truly control and own it.
>
> Boundaries define where AI can act independently and where it needs supervision. Companies need to control what data agents can access, what tools they can use, which actions require approval, and when they should escalate. Owning your intelligence means controlling what it can do.
>
> Observability [makes the system accountable](https://www.langchain.com/blog/on-agent-frameworks-and-agent-observability). If an agent takes an action, the business needs to see what it saw, what it did, what tools it called, and why. This is important for both being able to improve the system but also being able to audit and trust the system.
>
> ## Compound your intelligence
>
> *The compounding-intelligence flywheel: user interaction → trace → feedback → evals → system improvement → better future use, around an owned learning loop that is portable across models and measurable through evals:*
> ![[hwchase17-094888-003.png]]
>
> The best AI systems get better with use. The 100th interaction should be more valuable than the 1st because the system has learned more about your users, workflows, policies, failures, and preferences. You need to own both what the system has learned, as well as the learning process itself.
>
> What does it mean for a system to learn?
>
> That learning loop starts with traces. [Traces show what the agent actually did](https://www.langchain.com/blog/in-software-the-code-documents-the-app-in-ai-the-traces-do): what context it saw, what tools it called, where it got stuck, and what it produced. Feedback gives those traces meaning: whether the behavior was useful, accepted, rejected, inefficient, risky, or wrong. Together, [traces and feedback become the raw material for improvement](https://www.langchain.com/blog/improving-agents-is-a-data-mining-problem).
>
> Those traces and their associated feedback can be used to improve the system - by changing the prompts, harness, tools. But just as important as those changes are the evals associated with those changes. For every change, you should be adding an eval to capture that change, and make sure that future changes don’t cause regressions.
>
> At a bare minimum, these learnings need to be owned by you. They need to be portable from from model to model, from system to system. Even more - you should own this entire loop yourself. Again - it doesn’t really matter how well the agent does the first time someone uses. It matters how much better it is the 100th time they use it. If that’s what matters, then you need to own the loop that drives that.
>
> ## A checklist for owning your intelligence
>
> Do you truly own your intelligence? Here’s a set of questions you should be asking yourself to determine that:
>
> - [ ]  If a brand new model provider launched a SOTA model tomorrow, could you easily switch to it?
>
> - [ ]  If the model provider you are using deprecates a model - could you host it yourself to avoid any disruption?
>
> - [ ]  Do you know - and can control - how the orchestration logic works, such that you can know and control exactly what goes into the LLM at every step?
>
> - [ ]  Can you run your agent in the exact same way in one cloud vs another vs on device?
>
> - [ ]  Can you monitor and control AI spend on per user basis?
>
> - [ ]  If someone asks why an agent did something, can you show them a full trace of all the steps they did (and any internal logic for why they did that?)
>
> - [ ]  Do you have evals in place to be confident that swapping models won’t introduce regressions?
>
> - [ ]  When a user uses your agent for the 100th time, will it know more about them and be a better experience than when they used it for the 1st time?
>
> - [ ]  When your agent learns - can you port those learnings to a different system entirely?
>
> - [ ]  Can you control how your agent learns?
>
> ## The strategic choice
>
> Companies do not need to build every layer of the AI stack. They should buy the parts that are hard, generic, and undifferentiated.
>
> But they need to own the layer where advantage compounds: the agent system, the governance around the work it does, and the feedback loop that makes it better with use.
>
> Any company can adopt AI. The companies that create lasting value with AI will be the ones that own their intelligence.

