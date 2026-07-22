---
created: 2026-07-22
description: LangChain's Eval Engineering Skill lets a coding agent build executable Harbor-format evals by mapping a repository's agent surface plus production traces, interviewing the user to pick directions and simulate risky dependencies, and iterating on verifiers by inspecting both agent and verifier trajectories to catch reward hacking.
source: https://x.com/vtrivedy10/status/2079976006644072796
type: framework
---

## Key Takeaways

- The skill turns eval-building into a coding-agent task: it reads the repo to map the agent surface (prompts, models, tools, skills, hooks, and the data/services behind them) and mines production traces (retrieved via langsmith-cli) for observed tool contracts — arguments, results, errors — then proposes which abilities are worth testing and emits executable evals in Harbor format. That agent-surface enumeration and the test-first posture are the "Build" and "Test" stages of [[Harrison Chase frames agent development as a Build-Test-Deploy-Monitor lifecycle wrapped by iteration and governance]].
- Interviewing beats one-shot generation: rather than one-shotting evals, the skill interviews the user to choose among proposed eval directions and to decide which tools/dependencies run live versus are simulated (e.g., calls that incur cost or write to production get simulated rather than run on every invocation) — which yielded much higher eval acceptance. Skills are the natural interface for encoding how-to-build-a-good-eval domain knowledge that users refine over time — itself an answer to the arguments that [[agent skills need eval harnesses not vibe checks to ship reliably]] and that [[coding agent skills need dedicated evaluation benchmarks not vibes to measure real performance]].
- Verifier design is iterative and adversarial: the first verifier is rarely the final one, and the way to improve it is to run the eval and inspect both sides — the agent trajectory (messages, tool calls, actions) and the verifier trajectory (evidence, reasoning, final score). That reveals reward hacking (overciting irrelevant sources for full credit, claiming an action never taken, exploiting exposed answer material, or satisfying a proxy without completing the task), after which the task, environment, and verifier are revised and rerun — the same proxy-gaming failure that [[invariance-based stress tests detect proxy gaming by separating exploitable sensitivity from genuine improvement]], and a reason [[anthropic recommends combining deterministic graders model judges and human review for agent evals]] rather than trusting a single verifier.
- A Harbor task is three components — an instruction (the starting message), an environment (a Dockerfile specifying tools/data setup), and a verifier (scores completion) — laid out as `evals/<task-id>/` with `task.toml`, `instruction.md`, `environment/`, and `tests/`. Harbor runs the agent in that environment and records trajectory, artifacts, reward, and errors, so one containerized eval can be replayed against different models, prompts, tools, and agent versions in parallel and compared directly.
- The framing is that continual learning is a data-mining problem: mine production traces for recurring requests, errors, failed tool calls, and incorrect state changes, turn those into evals, improve the agent (harness engineering — prompts, tools, or fine-tuning), and rerun — `mine traces → identify a failure → build an eval → improve the agent → rerun`, the same loop as [[the agent improvement loop is traces enriched with evals and human feedback converted into validated fixes]] and the data-mining framing behind [[LangChain and Fireworks fine-tune Qwen as a 100x cheaper trace judge that beats frontier models on unseen perceived-error domains]]. Evals become training data that provide a fixed target for deciding whether a change actually improved the intended capability — the signal [[LangChain's Better-Harness uses eval-driven hill-climbing for agent harness improvement]] hill-climbs against — and reproducible environments mirroring production tools/data/permissions/state/failure modes are what keep that signal representative.

## External Resources

- [Eval Engineering Skill (langchain-ai/langchain-skills)](https://github.com/langchain-ai/langchain-skills/tree/main/config/skills/eval-engineering) — the released skill; install in Codex or Claude Code, open the agent's repo, point it at traces, and prompt.
- [Harbor framework](https://github.com/harbor-framework/harbor) and [Harbor task docs](https://www.harborframework.com/docs/tasks) — the containerized eval format the skill targets (instruction + Dockerfile environment + verifier).
- [langsmith-cli](https://docs.langchain.com/langsmith/langsmith-cli) — retrieves production agent traces used to reproduce real tool behavior in the eval environment.
- [chat-langchain](https://github.com/langchain-ai/chat-langchain) — the documentation Q&A agent the flow was tested on (golden-answer + cited-documents verifier).
- [Improving agents is a data mining problem (LangChain blog)](https://www.langchain.com/blog/improving-agents-is-a-data-mining-problem) — the continual-learning-as-data-mining thesis behind the loop.

## Original Content

> @Vtrivedy10 (Viv) — 2026-07-22
>
> *Automating Eval Engineering loop: (1) map agent definition & behavior from repository + traces → (2) propose eval directions to user → (3) build Harbor tasks → (4) run agent and verifier → (5) revise or accept eval → next eval*
> ![[vtrivedy10-072796-001.png]]
>
> **Article: Towards Automating Eval Engineering**
>
> Today we're releasing our Eval Engineering Skill, a skill that helps coding agents build evals using context from a repository and agent traces.
>
> The skill inspects how an agent is structured, mines patterns from traces if available, and proposes abilities to test.
>
> The skill is designed to interview the user who can give feedback on proposals and iteratively approve each eval.  The end product is a set of executable evals in [Harbor](https://github.com/harbor-framework/harbor) format.
>
> ## Building the Environment & Task
>
> The skill first reads the repository and maps the agent surface including prompts, models, tools, skills, hooks, etc. It also identifies the data and services that back those behaviors such such as API calls.
>
> Users can also point the agent to traces which can be retrieved using tools like the [langsmith-cli](https://docs.langchain.com/langsmith/langsmith-cli).  Traces show how tools behave in practice such as their arguments, results, and errors. These observed contracts help the skill reproduce relevant production behavior in a controlled environment.
>
> Crawling the repo and traces gives the agent knowledge of a which abilities are important for the agent as it proposes eval tasks. We found that interviewing the user, leads to much better eval acceptance than one-shot generation.  The user chooses from the proposed eval directions, and gives guidance on questions such as which tools & dependencies should run live or need to be simulated.  For example, tool calls that incur costs or require writes to production can be simulated instead of being run on every eval invocation.
>
> We tested this flow on our documentation Q&A agent, [chat-langchain](https://github.com/langchain-ai/chat-langchain).  For this agent, the environment required a data corpus exposed through agent search tools modeled on the production agent. The tasks included realistic documentation question pulled from real traces and a verifier that checked the answer using a golden answer string and cited documents.
>
> ## Eval Design is iterative
>
> We found that while agents are sometimes able to one-shot evals, the best evals came from users providing feedback and specifying which capabilities were worth measuring in agents. Coding agents & skills provide a natural interface where domain knowledge on how to build a good eval are encoded and users can iterate over them over time.
>
> For example, we found that when building verifiers, the first verifier was rarely the final one. A useful way to improve it was to run the eval and inspect both sides of the result:
>
> - the agent trajectory, including its messages, tool calls, and actions.
>
> - the verifier trajectory, evidence, reasoning, and final score.
>
> This helped reveal if the task or verifier design was measuring what we cared about or if it could be reward hacked where agents could take shortcuts.  These shortcuts could include overciting irrelevant sources to receive full credit on the eval, claim an action it never took, exploit exposed answer material, or satisfy a proxy without completing the task. Observing the traces for how agents solve problems often reveal the source of these failures. The task, environment, and verifier can then be revised and run again.
>
> ## Evals are in Harbor format
>
> The skill builds evals as [Harbor tasks](https://www.harborframework.com/docs/tasks):
>
> 1. An Instruction: the message given to the agent at start describing the task
>
> 2. An environment: given as a Dockerfile containing the setup for the task such as what tools to install or what data to populate in the filesystem
>
> 3. A verifier that scores whether the agent completed the task correctly.
>
> The skill builds these components together as a Harbor task:
>
> ```markdown
> evals/<task-id>/
> ├── task.toml
> ├── instruction.md
> ├── environment/
> └── tests/
> ```
>
> Harbor runs the agent in the environment and records its trajectory, artifacts, reward, and errors. The same eval can then run against different models, prompts, tools, and agent versions.
>
> ## Why this matters
>
> [Continual learning can be thought of as a continuous data mining problem](https://www.langchain.com/blog/improving-agents-is-a-data-mining-problem) where production data is used to build evals that improve agents over time. Teams mine traces to find recurring user requests, errors, failed tool calls, and incorrect state changes. which become evals so the same behavior can be measured and prevented in the future.
>
> Evals are training data for agents. Teams can fit agent behavior to them through harness engineering such as changing prompts & tools or fine-tuning. The eval provides a fixed target for deciding whether those changes improved the intended capability.
>
> Containerized evals make this process faster. The task and environment remain stable while the agent configuration changes, so builders can swap models, tools, prompts, or complete agent versions and compare results directly. Multiple configurations can run in parallel.
>
> Reproducible environments are critical to that signal. When an eval mirrors the relevant tools, data, permissions, state, and failure modes from production, builders get a stable testbed that is still representative of how the agent operates. They can experiment quickly without relying on changing production systems or writing to production state.
>
> The resulting loop is:
>
> mine traces -> identify a failure -> build an eval -> improve the agent -> rerun
>
> ## Try it today
>
> The Eval Engineering Skill is available in the [langchain-ai/langchain-skills repository.](https://github.com/langchain-ai/langchain-skills/tree/main/config/skills/eval-engineering)
>
> Install the skill in Codex or Claude Code, open the repository containing the agent you want to evaluate, point to agent to a set of traces if available, and start with a simple prompt:
>
> We're looking forward to expanding this skill and building tooling to make it easier to automatically build evals and fit agents to them autonomously.
>
> Engagement: 7 likes | 2 retweets | 0 replies
> [Original post](https://x.com/vtrivedy10/status/2079976006644072796)
