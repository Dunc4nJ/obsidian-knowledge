---
created: 2026-03-02
description: Cursor demonstrates that adding semantic search to their coding agent's toolset yields 12.5% higher accuracy, better code retention, and fewer dissatisfied user requests, especially on large codebases.
source: https://cursor.com/blog/semsearch
authors: Stefan Heule, Emily Jia, Naman Jain
published: 2025-11-06
type: reference
---

# Cursor's semantic search improves agent accuracy by 12.5 percent

## Key Takeaways

Cursor built a custom embedding model and indexing pipeline to give their coding agent semantic search alongside grep — and the results make a strong case that [[searching more and thinking less improves agentic efficiency and generalization|search tooling is a primary lever for agent performance]]. Their "Cursor Context Bench" evaluation shows a consistent 12.5% accuracy improvement across every frontier model tested, which directly supports the thesis that [[harness engineering improved a coding agent 13 points by changing only system prompts tools and middleware|harness engineering — not model swaps — drives real gains]].

The A/B test results are particularly interesting: code retention improves by 0.3% overall but jumps to 2.6% on large codebases (1,000+ files). This aligns with intuition — semantic search matters most when grep alone can't efficiently surface the right context across a sprawling codebase. The finding that removing semantic search increases dissatisfied follow-up requests by 2.2% quantifies the cost of poor context retrieval in terms of user experience.

Their training approach — using agent session traces to generate LLM-ranked training data for the embedding model — is a neat feedback loop. Rather than generic code similarity, the model learns what *should have been retrieved* based on what the agent actually needed. This is a concrete example of [[designing agent tools is an iterative art shaped by model capabilities not fixed engineering rules|iteratively designing tools based on observed agent behavior]]. The conclusion explicitly frames this as "agent harness" optimization: "We're continuing to test and evaluate all tools we give to the agent harness as models improve" — directly relevant to [[putting yourself in the agents shoes is the unifying framework for agentic system design|thinking from the agent's perspective]].

Worth noting this complements the [[cursor-dynamic-context-discovery|Cursor dynamic context discovery]] reference — semantic search is one piece of their broader context retrieval strategy.

## External Resources

- [Cursor Blog - Semantic Search](https://cursor.com/blog/semsearch) — original post
- [Cursor Enterprise](https://cursor.com/enterprise) — enterprise offering mentioned in the post

## Original Content

> [!quote]- Source Material
>
> When coding agents receive a prompt, returning the right answer requires building an understanding of the codebase by reading files and searching for relevant information.
>
> One tool Cursor's agent uses is semantic search, which retrieves segments of code matching natural language queries, such as "where do we handle authentication?", in addition to the regex-based searching provided by a tool like grep.
>
> To support semantic search, we've trained our own embedding model and built indexing pipelines for fast retrieval. While you could rely exclusively on grep and similar command-line tools for search, we've found that semantic search significantly improves agent performance, especially over large codebases:
>
> * Achieving on average 12.5% higher accuracy in answering questions (6.5%–23.5% depending on the model).
> * Producing code changes that are more likely to be retained in codebases.
> * Requiring fewer iterations for users to arrive at a correct solution.
> * Increasing accuracy across all models we tested, including all frontier coding models.
>
> ### Offline evals
>
> We maintain an evaluation dataset, Cursor Context Bench, focused on retrieving information in codebases with known correct answers. This evaluation is run over all of the most-used models in Cursor, including our own Composer.
>
> The comparison looks at performance with two sets of available tools: one that includes semantic search and one that does not. In every configuration, semantic search significantly improves outcomes.
>
> *Offline eval results: semantic search vs. no semantic search across models*
> ![[cursor-semsearch-001.png]]
>
> ### Online A/B tests
>
> We also wanted to understand the impact on the end-user experience. We ran an A/B test where both groups used the same model, but one group's agent had access to semantic search while the other relied solely on traditional search tools like grep. We looked at two metrics:
>
> * **Code Retention**: Code written by effective agents is more likely to remain in user codebases. We see agent code retention increases by 0.3% when semantic search is available. This effect increases to 2.6% on large codebases with 1,000 files or more.
> * **Dissatisfied User Requests**: Code written by effective agents requires no follow-ups or corrections. We observed a 2.2% increase in dissatisfied follow-up user requests when semantic search was not available.
>
> The effect size is lower here since the A/B test is on all agent queries and not all requests require search.
>
> *Online A/B test results: code retention and dissatisfied requests*
> ![[cursor-semsearch-002.png]]
>
> ### Custom retrieval models
>
> One piece that enables these results is our custom embedding model. Our approach uses agent sessions as training data: when an agent works through a task, it performs multiple searches and opens files before finding the right code. By analyzing these traces, we can see in retrospect what should have been retrieved earlier in the conversation.
>
> We provide these traces to an LLM, which ranks what content would have been most helpful at each step. We then train our embedding model to align its similarity scores with these LLM-generated rankings. This creates a feedback loop where the model can learn from how agents actually work through coding tasks, rather than relying on generic code similarity.
>
> ### Conclusion
>
> Semantic search is currently necessary to achieve the best results, especially in large codebases.
>
> Our agent makes heavy use of grep as well as semantic search, and the combination of these two leads to the best outcomes. We're continuing to test and evaluate all tools we give to the agent harness as models improve.

[Source: Cursor Blog — Improving agent with semantic search](https://cursor.com/blog/semsearch)
