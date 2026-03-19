# codex-autoresearch-harness wraps Codex CLI in a bash loop for A/B model testing

**Source:** <https://github.com/SarahXC/codex-autoresearch-harness>
**Author:** SarahXC
**Type:** Bash harness / tooling

## What It Is

A bash harness that makes OpenAI Codex CLI run Karpathy's [[autoresearch lets an AI agent run ML experiments autonomously overnight|autoresearch]] experiments in a continuous loop. Includes an **A/B testing framework** to compare different models head-to-head (e.g. GPT-5.4 vs GPT-5.3-Codex Spark).

## Key Insight: The Loop Problem

Codex CLI's `codex exec` runs once and exits — no `/loop` equivalent like Claude Code. The solution is dead simple: **wrap `codex exec` in a `while true` bash loop**. Each iteration the agent reads git history + `results.tsv` to understand prior attempts, runs one experiment, and exits. The bash loop restarts it with fresh context.

## Architecture

```
bash while loop (run_experiment.sh)
  └── codex exec (iteration N)
        1. Read program.md + results.tsv
        2. Propose change to train.py
        3. git commit
        4. uv run train.py (5 min training)
        5. Evaluate val_bpb
        6. Keep commit or git reset --hard HEAD~1
        7. Log to results.tsv → exit
  └── Loop back → iteration N+1
```

**State persistence between iterations:**
- **Git history** — accepted changes stay as commits; rejected changes are reverted
- **results.tsv** — full experiment log (on disk, not committed)
- **program.md** — instructions the agent reads every iteration

## Key Takeaways

### A/B Model Testing Framework
- `launch_ab.sh` runs model A for N hours, then model B for N hours sequentially (single GPU constraint)
- `compare_results.sh` prints side-by-side comparison
- Both models start from the same commit for fair comparison
- Custom model pairs: `./launch_ab.sh 6 <model_a> <model_b> <tag_a> <tag_b>`

### Results: GPT-5.4 vs Spark (6h each, H100)

| Model | Iterations | Experiments | Best val_bpb | Improvement | Accept Rate |
|-------|-----------|-------------|-------------|-------------|-------------|
| GPT-5.4 | 54 | 53 | 1.008364 | **-2.46%** | 40% (21/53) |
| Spark | 57 | 57 | 1.030148 | -0.95% | 16% (9/57) |

**GPT-5.4 dominated** — made a bold architectural move mid-run (reduced depth from 8→7 layers, halved batch size to trade model size for more gradient updates per 5-min window). That single insight was worth more than all 57 Spark experiments combined. Then systematically hill-climbed LR/warmdown to push further.

**Spark was cautious** — stuck to hyperparameter tuning (warmdown ratios, momentum ramps) without attempting structural changes.

### One Experiment Per Call > Multi-Experiment Loops
- Context windows fill up after a few iterations of training output
- Agent tends to stop and ask if it should continue
- Error recovery is cleaner when each iteration is independent
- Fresh context per call prevents accumulated confusion

### Pitfalls Documented
1. **Codex CLI ignores `OPENAI_API_KEY` env var** — must also run `codex login --with-api-key`
2. **CUDA blocked by Codex sandbox** — `--full-auto` Linux namespaces block `/dev/nvidia*` devices; must use `--dangerously-bypass-approvals-and-sandbox` on dedicated VMs
3. **uv cache permission denied** in sandbox — another reason to bypass sandbox on dedicated VMs
4. **Single GPU = sequential only** — can't run two models simultaneously; need 2 VMs for true parallel
5. **Non-interactive shell doesn't source .bashrc** — scripts check for API key explicitly

### Infra Requirements
- 1× H100 80GB (or A100 80GB, slower)
- Ubuntu 22.04, CUDA 12.2+, 100GB+ disk
- Node.js 22, uv, tmux
- Recommended provider: Shadeform (also Lambda, RunPod, Vast.ai)

## Repo Structure

```
codex-autoresearch-harness/
├── run_experiment.sh      # Core loop: one model for N hours
├── launch_ab.sh           # A/B orchestrator: model A then B
├── compare_results.sh     # Post-run side-by-side analysis
└── setup_vm.sh            # One-shot VM setup
```

## Relevance

- **Pattern is generalizable** — the bash-loop-around-`codex exec` pattern works for any autonomous agent workflow where the CLI doesn't support native looping
- **A/B framework is reusable** — swap in any two models and compare performance on any autoresearch-style task
- **Validates that bold architectural moves beat cautious hyperparameter tuning** in time-boxed autonomous research

---

**Related:**
- [[autoresearch lets an AI agent run ML experiments autonomously overnight]]
- [[autoresearch-gen scaffolds the entire autoresearch setup into a single command]]
- [[autoresearch loops cheat when guardrails are loose but converge on real findings when tightly scoped]]
