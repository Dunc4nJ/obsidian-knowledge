---
created: 2025-07-25
description: Meta-Harness uses an agentic outer loop to search over harness code (context management, retrieval, prompting) for LLMs, accessing full execution traces and prior candidates through a filesystem. Achieves SOTA on TerminalBench-2 coding, online text classification, and IMO-level math reasoning.
source: https://arxiv.org/abs/2603.28052
type: paper
authors: Yoonho Lee, Roshen Nair, Qizheng Zhang, Kangwook Lee, Omar Khattab, Chelsea Finn
institutions: Stanford, MIT, KRAFTON
---

# Meta-Harness optimizes LLM system harnesses through automated search over code and execution traces

The **harness** — the code that determines what to store, retrieve, and present to an LLM — can produce a 6× performance gap on the same benchmark with the same model weights. Yet harness engineering remains largely manual. Meta-Harness automates this by running an outer search loop:

1. An **agentic proposer** reads a filesystem containing all prior candidates' source code, execution traces, and scores
2. It proposes a new harness (actual code, not just prompt text)
3. The harness is evaluated on tasks
4. All logs are stored and the loop repeats

## Key insight: richer feedback beats compressed feedback

Existing text optimizers (OPRO, TextGrad, DSPy) compress feedback too aggressively — they're memoryless, condition only on scalar scores, or restrict feedback to short templates. Meta-Harness gives the proposer **full access** to all prior experience through a filesystem, which enables it to learn from execution traces and avoid repeating mistakes.

| Method | History | Log content | MTok/iter |
|--------|---------|-------------|-----------|
| OPRO | Window | past (solution, score) pairs | 0.002 |
| TextGrad | Last | textual feedback on current artifact | 0.015 |
| Meta-Harness | All | source code + traces + scores via filesystem | Full |

## Results

- **Online text classification**: +7.7 points over SOTA context management, using 4× fewer context tokens
- **Retrieval-augmented math** (IMO-level): +4.7 points average across 5 held-out models from a single discovered harness
- **Agentic coding** (TerminalBench-2): 37.6% — surpasses all hand-engineered baselines (Goose 35.5, Mini-SWE-Agent 33.7, Claude Code 28.3)

## Why this matters for continuous learning

Meta-Harness is a form of **system-level continuous learning** — rather than updating model weights, it continuously improves the scaffolding code around the model based on accumulated experience. The filesystem-as-memory architecture means no experience is ever discarded, and the proposer can mine old failures for new insights.

This connects to the broader trend of moving adaptation from weights to infrastructure: prompt optimization → harness optimization → full system optimization.

## Links

- Project page: https://yoonholee.com/meta-harness/
- Optimized harness artifact: https://github.com/stanford-iris-lab/meta-harness-tbench2-artifact

---

*Full extraction: [[meta-harness-full-extraction]]*
