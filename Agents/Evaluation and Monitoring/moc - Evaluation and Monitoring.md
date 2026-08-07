---
created: 2026-02-28
description: Navigation hub for agent evaluation and monitoring — measuring quality, observability, and production monitoring.
type: moc
---

# Evaluation and Monitoring

Measuring agent quality, observability, regression testing, production monitoring, and drift detection.

## Notes

- [[agent production monitoring requires observing inputs and outputs not just system metrics]]
- [[AI generated code repos gain credibility by shipping verification artifacts not hiding authorship]]
- [[coding agent skills need dedicated evaluation benchmarks not vibes to measure real performance]]
- [[data-eng-bench shows a data-native harness beats generic coding agents on dbt tasks at up to 3.9x lower cost with equal or better quality]] — Snowflake AI Research + Bespoke Labs: an open-source repository-level data-engineering benchmark (103 dbt tasks over one 579-table warehouse; hidden 10-50 assertion verifier suites; strict all-assertions-pass task scoring; Pass@1 *and* Pass^3). Isolates harness from model across CoCo/Claude Code/Codex × Opus 5/Sonnet 5/GPT 5.6 Sol — the data-native CoCo harness matches or beats generic agents on quality at up to 3.9x lower cost via plan-then-execute (front-load exploration, write without look-back, verify once) vs generic explore-and-refine + needless DuckDB cross-validation; harness effect is model-dependent (Sonnet 5 ties on quality, wins only on cost). Best config CoCo+Opus 5 = 73.8% Pass@1 / 64.1% Pass^3; 3 figures
- [[deep agent evals need bespoke per-datapoint test logic not uniform evaluators]]
- [[trajectory eyeballing is the irreplaceable skill for debugging RL-trained agents]]
- [[effective agent evals combine deterministic graders model judges and human review across the full development lifecycle]]
- [[Agno native tracing keeps agent observability data in your own database]]
- [[VictoriaMetrics is becoming the default observability stack for AI agent systems]]
- [[Brainstore turns AI observability into database-native trace architecture for long-horizon agents]]
- [[SmithDB makes LangSmith 12x faster by treating agent observability as an LSM problem on object storage]]
- [[SmithDB's 12x agent observability speedup was built on top of Apache DataFusion and Vortex not instead of them]]
- [[SmithDB builds a byte-budgeted FST inverted index to enable 400ms full-text search over enormous agent traces in object storage]]
- [[Laminar trace viewer reads agent runs as transcripts of LLM-tool loops not backend span trees]]

- [[a working offline eval turns vibes into repeatable measurement in 10 steps]]
- [[targeted evals shape agent behavior more effectively than large benchmark suites]]
- [[agent eval readiness starts with error analysis and simple end-to-end tests not sophisticated infrastructure]]

- [[sandboxed CI is the missing infrastructure for agent evals at scale]]
- [[the agent improvement loop is traces enriched with evals and human feedback converted into validated fixes]]
- [[LangChain's Harrison Chase argues agent observability needs feedback attached to traces to power learning]]

- [[trace learning turns agent execution history into reusable strategies that compound performance over time]]
- [[agent trace data should live in your data lake not a 30-day SaaS retention window]]
- [[every deploy should trigger a monitor-triage-fix loop that dispatches a coding agent to fix regressions before users notice]]
- [[Langfuse Academy primer argues tracing is the foundational primitive every step of the agent improvement loop operates on]]
- [[Langfuse Academy frames eval datasets as production-mirroring test suites where item structure follows from evaluator choice]]
- [[Langfuse Academy argues offline evaluation starts with manual review and automates only the failure modes worth checking repeatedly]]
- [[LangSmith Engine turns production agent traces into issues evaluators and regression examples by separating screening from investigation]]
- [[OpenAI macro evals cookbook turns population-level trace clustering into a ranked inspection queue for multi-agent systems]]
- [[Phoebe Yao argues verifier engineering is the moat in RL post-training because verifiability bounds learnability]]
- [[LangChain and Harvey show DeepSeek batch verifiers reduce legal agent evaluation costs by three orders of magnitude at acceptable accuracy]]
- [[LLM Data Company experiments show explicit rubric criteria let gpt-oss-120b match Opus 4.7 at 100x lower cost and full-rubric grading beats per-criterion across every model]]

## Resources

- [[Langfuse]]
- [[OpenLLMetry]]
- [[resources/Laminar|Laminar]]
