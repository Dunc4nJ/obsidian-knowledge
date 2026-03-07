# Prime Intellect duckdb-qa — RL Reward Shaping for SQL Tool Use

**Source:** <https://app.primeintellect.ai/dashboard/environments/diicell/duckdb-qa>
**Author:** diicell | **Version:** 0.1.2 | **Framework:** [verifiers](https://github.com/eddiebergman/verifiers) (`vf`)
**Dataset:** [diicell/duckdb-qa-v3](https://huggingface.co/datasets/diicell/duckdb-qa-v3) — 578 QA pairs across 4 DuckDB schemas (IMDB, COVID, HackerNews, UK property)
**Tags:** #llm #rl #reward-shaping #tool-use #sql #verifiers #prime-intellect

---

## What It Is

A Prime Intellect evaluation environment that trains/evaluates LLMs as data analyst assistants. The model must answer natural language questions by writing and executing SQL queries against a DuckDB database using 4 tools: `list_tables`, `list_columns`, `sample_rows`, `run_select_query`.

The interesting part isn't the SQL task — it's the **reward function design** for multi-turn tool use.

---

## Reward Architecture

Single composite reward function (`sql_composite_reward`) with three layers:

### 1. Base Components (normalized by total weight 7.0)

| Component | Weight | What it measures |
|-----------|--------|-----------------|
| `soft_exec` | 5.0 | Continuous execution accuracy — sharpened F1^1.5, value F1, column Jaccard. Not binary pass/fail. |
| `syntax` | 1.0 | 1.0 if query executes without error, 0.0 otherwise |
| `schema` | 0.5 | Jaccard similarity of schema items (tables/columns) between predicted and gold SQL |
| `format` | 0.5 | 1.0 if all 3 XML tags present (`sql_query`, `query_result`, `response`), 0.0 otherwise |

### 2. Multipliers (applied to entire base reward)

| Multiplier | Range | Logic |
|------------|-------|-------|
| `tool_use` | 0.15–1.0 | 1.0 if `run_select_query` was called, **0.15 otherwise** — harsh penalty for not using tools |
| `reasoning` | 0.4–1.0 | Based on reasoning text length between tool calls (100+ chars = 1.0, 0 chars = 0.4) |

### 3. Behavioral Bonuses (additive, post-multiplier)

| Bonus | Value | Trigger |
|-------|-------|---------|
| `exploration` | +0.08 | Called `sample_rows` before `run_select_query` |
| `self_correction` | +0.05 | Made 2+ query attempts |
| `error_recovery` | +0.08 | Failed query → reasoning → successful query |
| `completion` | +0.03 | Last tool call was `run_select_query` |

**Final reward** = `min(1.0, base × tool_multiplier × reasoning_multiplier + bonuses)`

---

## Key Design Patterns

### Soft Execution Accuracy (not binary)
Instead of exact match, uses continuous scoring:
- Row F1 and Value F1 computed separately
- Takes the best of the two, sharpens with F1^1.5 (rewards near-perfect more)
- Exact match bonus (+0.20) and near-match bonus (+0.15 for F1 ≥ 0.95)
- Value F1 floor: if values are mostly right but structure differs, floors the score (e.g., value_f1 ≥ 0.95 → min score 0.80)

### LLM Judge Fallback
GPT-4.1-mini fires when value F1 and row F1 disagree — catches cases where the model got the right answer in a different structure (pivoted, different aliases, etc.). Triggers when `value_f1 ≥ 0.3 and row_f1 < 0.5` or `value_f1 > row_f1 + 0.15`. If judge says "yes", boosts `soft_exec` to 0.95.

### Process Reward Over Outcome
The multipliers and bonuses explicitly reward *how* the model solves, not just *what* it produces:
- Explore before querying
- Reason between tool calls
- Recover from errors gracefully
- Actually use the tools (don't just hallucinate SQL)

### Robust Tool Call Detection
Dual detection: checks `tool_calls` in message structure first, falls back to inferring from tool response content patterns (`'rowCount'` vs `'hint'`). Handles cases where tool_calls keys get stripped during processing.

---

## Verifiers Framework (`vf`)

The environment uses the `verifiers` library:
- `vf.XMLParser` — parses structured XML output fields
- `vf.Rubric` — composable reward functions with weights
- `vf.ToolEnv` — multi-turn tool-use environment with dataset, system prompt, tools, and rubric

```python
rubric = vf.Rubric(parser=sql_parser)
rubric.add_reward_func(sql_composite_reward, weight=1.0)

vf_env = vf.ToolEnv(
    dataset=dataset,
    eval_dataset=eval_dataset,
    system_prompt=system_prompt,
    parser=sql_parser,
    rubric=rubric,
    tools=tools,
    max_turns=max_turns,
)
```

**Quickstart:** `prime eval run duckdb-qa -m gpt-4.1-mini -n 20 -r 3 -t 1024 -T 0.7`

---

## Transferable Insights

1. **Don't just reward correctness** — reward the process (exploration, reasoning, recovery). This shapes models that are reliable tool users, not just lucky guessers.
2. **Soft scoring > binary** — continuous F1 with sharpening gives gradient signal even for partial matches.
3. **Multipliers for must-have behaviors** — 0.15x for skipping tool use is a strong signal without zeroing the reward entirely.
4. **LLM judge as fallback** — cheap model (GPT-4.1-mini) resolves ambiguous structural differences that programmatic matching can't handle.
5. **Behavioral bonuses are small but meaningful** — 0.03–0.08 range. Enough to break ties and shape behavior without dominating the signal.

---

*Captured: 2026-03-04. Source code saved to CRM workspace `duckdb-qa/`.*
