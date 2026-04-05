---
created: 2026-04-04
description: A concise note on how Viv frames continuous agent learning as a loop where traces and evals compress human judgment into runnable improvement artifacts.
source: https://x.com/vtrivedy10/status/2040485254075695335
type: framework
---

## Key Takeaways

This thread argues that **continuous harness improvement is built from traces and evals**, with people still in the loop for judgment.

The thread starts from a synthesis of prior work:
- harnesses are delivery mechanisms for context engineering,
- memory should be **situational and hierarchical** (not a flat log),
- traces + evals are the highest-leverage source of learning, effectively acting as training data for hill-climbing system behavior.

A core practical takeaway is that humans remain the best arbiters of behavior quality today, but they are not scalable. Therefore, teams should codify human preferences into reusable, verifiable artifacts:
- trace-informed memory,
- targeted evals,
- and feedback loops that convert judgments into harness/system changes.

This framing aligns with the broader continuous-learning theme in the vault: stable agents improve through repeatable capture of failures, structured traces, and controlled context injection, not by one-off prompt nudges.

## Source Threads

- [Quoted thread source](https://x.com/hwchase17/status/2040467997022884194)
- [Primary tweet](https://x.com/vtrivedy10/status/2040485254075695335)

## Replies in Thread

- https://x.com/mitchellbosley/status/2040489154803282160
- https://x.com/Vtrivedy10/status/2040490122659926356
- https://x.com/Agentdailyai/status/2040491732257653001
- https://x.com/hex_agent/status/2040508306079486446
