---
created: 2026-02-28
description: AMA-Bench is the first benchmark for evaluating agent memory on real agentic trajectories (not chatbot dialogues), revealing that existing memory systems underperform long-context baselines. AMA-Agent introduces a causality graph and tool-augmented retrieval to address this.
source: https://arxiv.org/abs/2602.22769
type: research-paper
full-extraction: "[[resources/AMA-Bench-full-paper.md]]"
---

# AMA-Bench evaluates long-horizon memory for agentic applications using real and synthetic trajectories

**Paper:** Zhao et al. (2026), "AMA-Bench: Evaluating Long-Horizon Memory for Agentic Applications" — UC San Diego + independent research.

## Key Takeaways

As highlighted by [DAIR.AI on X](https://x.com/dair_ai/status/2027776582262395054):

> Agent memory is evaluated on chatbot-style dialogues. But real agents don't chat. They interact with databases, code executors, and web interfaces, generating machine-readable trajectories, not conversational text. The key to better memory is to preserve causal dependencies.

The core findings from the paper:

1. **Existing memory benchmarks don't measure what matters for agents.** Current benchmarks (LoCoMo, LongMemEval, MemoryBench) are dialogue-centric. Real agent trajectories contain machine-generated representations (JSON, SQL, HTML, ASCII tables), causal state transitions, and dense objective information — none of which dialogue benchmarks capture.

2. **Memory systems that beat baselines on dialogue benchmarks underperform simple long-context LLMs on agentic tasks.** Even GPT 5.2 only reaches 72.26% accuracy on AMA-Bench. Memory systems like GraphRAG, MemGPT, HippoRAG2, and Mem0 frequently fall below long-context baselines when tested on real agent trajectories.

3. **The bottleneck is memory design, not model scale.** Scaling from 8B to 32B parameters yields marginal gains (~3.8%), while varying the memory architecture produces score ranges up to 45%. This means the memory system matters far more than the backbone model.

4. **Lossy compression and similarity-based retrieval are the failure modes.** Compression tuned for natural language strips critical state information from agent trajectories. Similarity-based retrieval fails because machine-generated representations don't cluster well by semantic similarity — you need causal and structural retrieval.

## AMA-Bench Design

Two complementary subsets:

- **Real-world subset**: 2,496 expert-curated QA pairs across six agent domains — Web navigation, Text2SQL, Software Engineering, Gaming, Embodied AI, and Open-world QA. Trajectories average 57K tokens of real agent-environment interaction logs.
- **Synthetic subset**: 1,200 QA pairs from programmatic environments (TextWorld, BabyAI) that scale to arbitrary horizon lengths (8K–128K tokens). Full MDP access enables automatic QA generation and needle protocol verification.

Four memory capabilities evaluated:
- **Recall** — identifying temporal and sequential information
- **Causal Inference** — verifying action preconditions and dependency relations
- **State Updating** — tracking explicit observations and hidden state changes
- **State Abstraction** — filtering redundancy while preserving key information

## AMA-Agent

The proposed solution has two mechanisms:

1. **Causality Graph** — parses adjacent turn pairs (observation → action → observation) to extract environment/object states and their causal dependencies. Builds a directed graph of state transitions with undirected association edges, embedded in latent space for retrieval.

2. **Tool-Augmented Retrieval** — goes beyond top-K similarity search. First retrieves K nearest nodes, then self-evaluates sufficiency. If insufficient, invokes either:
   - *Graph node search*: depth-controlled neighborhood traversal for multi-hop causal context
   - *Keyword search*: programmatic analysis via script execution for precise matching and aggregation

**Result**: AMA-Agent achieves 57.22% average accuracy on AMA-Bench, surpassing the strongest baseline (HippoRAG2 at 44.80%) by 11.16%.

## Performance Highlights

| Method | Avg Accuracy |
|--------|-------------|
| GPT 5.2 (long context) | 72.26% |
| AMA-Agent (Qwen3-32B) | 57.22% |
| MemoRAG | 46.06% |
| HippoRAG2 | 44.80% |
| Long Context (Qwen3-32B) | 46.71% |

Strong ranking correlation between synthetic and real-world subsets validates the synthetic environment as a high-fidelity proxy — useful given the cost of real-world trajectory annotation.

## Implications for Agent Design

- [[four memory layers serve different knowledge types|Memory layer design]] needs to account for machine-generated representations, not just natural language
- Causal graph construction from trajectories is a promising direction for [[Obsidian as Agentic Memory|agentic memory systems]]
- Similarity-based retrieval alone is insufficient; agents need structural and programmatic retrieval capabilities
- The gap between dialogue benchmarks and real agentic performance means existing memory system evaluations may be misleading
