---
created: 2026-03-02
description: Harrison Chase defines context engineering as building dynamic systems to provide the right information and tools in the right format such that the LLM can plausibly accomplish the task — framing it as the most important skill for AI engineers to develop.
source: https://blog.langchain.com/the-rise-of-context-engineering/
type: framework
---

## Key Takeaways

The definition Harrison Chase converges on — "building dynamic systems to provide the right information and tools in the right format such that the LLM can plausibly accomplish the task" — has become the canonical framing for the field. It synthesizes Tobi Lutke, Ankur Goyal, and Walden Yan's perspectives. The key insight is the word "dynamic" — this isn't prompt engineering (static optimization of phrasing) but systems engineering (building pipelines that construct the right prompt at runtime).

The failure mode taxonomy is clear: LLMs fail either because the model isn't good enough, or because it wasn't given the right context. As models improve, the second failure mode dominates. "Models are not mind readers" — missing context and poor formatting cause more agent failures than model capability limits. This aligns with [[anthropic-effective-context-engineering|Anthropic's attention budget]] work showing that growing context depletes attention, and [[cursor-dynamic-context-discovery|Cursor's finding]] that better models benefit more from pulling their own context.

The post positions context engineering as a superset of prompt engineering — even with perfect context, how you assemble it in the prompt still matters. But the shift in emphasis from "clever phrasing" to "right information at the right time" reflects the maturation of the field from single-turn chatbot optimization to multi-step agent orchestration.

## External Resources

- [Dex Horthy - 12 Factor Agents](https://github.com/humanlayer/12-factor-agents) — Principles for agent design emphasizing context ownership
- [Karpathy's context engineering tweet](https://x.com/karpathy/status/1937902205765607626) — "Delicate art and science of filling the context window"
- [Communication is all you need](https://blog.langchain.com/communication-is-all-you-need/) — Harrison Chase's earlier post on LLM communication challenges

## Original Content

> [!quote]- Source Material
> **The rise of "context engineering"**
> LangChain Blog — June 2025
>
> Context engineering is building dynamic systems to provide the right information and tools in the right format such that the LLM can plausibly accomplish the task.
>
> Most of the time when an agent is not performing reliably the underlying cause is that the appropriate context, instructions and tools have not been communicated to the model.
>
> LLM applications are evolving from single prompts to more complex, dynamic agentic systems. As such, context engineering is becoming the most important skill an AI engineer can develop.
>
> **What is context engineering?**
> - Context engineering is a system (complex agents get context from many sources)
> - This system is dynamic (logic for constructing the final prompt must be dynamic)
> - You need the right information (LLMs cannot read minds — garbage in, garbage out)
> - You need the right tools (empowering the LLM with the right tools is as important as information)
> - The format matters (a short descriptive error message goes further than a large JSON blob)
> - Can it plausibly accomplish the task? (Separating failure modes: wrong context vs model limitation)
>
> **Why is context engineering important?**
> When agentic systems mess up, it's largely because an LLM messes up for two reasons: (1) the model just isn't good enough, or (2) it was not passed appropriate context. More often than not, especially as models get better, mistakes are caused by the second reason.
>
> **How is context engineering different from prompt engineering?**
> Prompt engineering is a subset of context engineering. The difference is that you are not architecting your prompt to work well with a single set of input data, but rather to take a set of dynamic data and format it properly.
>
> [Original post](https://blog.langchain.com/the-rise-of-context-engineering/)
