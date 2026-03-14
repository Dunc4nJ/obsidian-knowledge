---
created: 2026-03-13
description: autoresearch-gen wraps Karpathy's autoresearch in an LLM-powered scaffolding layer that generates program.md, training code, and a Streamlit dashboard from a one-line make command.
source: https://x.com/ellen_in_sf/status/2032526928352260441
type: learning
---

## Key Takeaways

The biggest friction with [[autoresearch lets an AI agent run ML experiments autonomously overnight|autoresearch]] is not the concept but the setup: you still have to write program.md, structure your experiment directory, prepare training code, and configure tracking. autoresearch-gen eliminates that by having an LLM generate all the boilerplate from three inputs (context, dataset, goal). This is the same pattern we see across agent tooling — the meta-move of using AI to scaffold the AI workflow itself.

The Streamlit dashboard with Plotly is a practical upgrade over the default autoresearch output. Instead of reading terminal logs or spinning up Jupyter notebooks, you get experiment stats, keep/reject rates, and an architecture diagram (Excalidraw) from `make dashboard`. Ellen's test run hit 30 experiments with a 41% keep rate and ~26% val_bpb improvement on TinyStories exploring attention-free architectures — decent results from a lunchtime run.

The most interesting observation is about **context drift in long-running agent loops**: after many iterations the model starts forgetting variables and experiment details. This connects directly to [[distributed research swarms close the feedback loop that single-agent autoresearch leaves open|the need for multi-agent research swarms]] and the state management problem Karpathy himself hit when an OAuth outage wiped his labs. Long-running autonomous research needs checkpointing, state persistence, and failover — the same problems we deal with in [[autokernel applies the autoresearch loop to GPU kernel optimization reaching 187 TFLOPS from 18 autonomously|autokernel]] and any serious agent orchestration.

Ellen works at mem0.ai (memory layer for AI agents), which makes her perspective on stateful agent loops particularly relevant — she is literally building infrastructure for the problem she identified.

## External Resources

- [autoresearch-gen](https://github.com/liviaellen/autoresearch-gen) — LLM-powered scaffolding for Karpathy's autoresearch, generates boilerplate + Streamlit dashboard
- [autoresearch](https://github.com/karpathy/autoresearch) — Karpathy's original autonomous ML experiment loop
- [mem0.ai](https://mem0.ai) — Memory layer for AI agents (Ellen's employer)

## Original Content

> @ellen_in_sf — 2026-03-13
>
> Article: Karpathy's autoresearch Quickstart
>
> Earlier this week Andrej Karpathy released autoresearch.
> So I tried something: running AI research with a single command :
>
> ```bash
> make gen CONTEXT="explore attention-free LLM"
> DATA=TinyStories 
> GOALS="lowest val_bpb"
> ```
>
> ---
>
> I will share how you can run [autoresearch](https://github.com/karpathy/autoresearch) in one command and track the experiment in a dashboard.
>
> autoresearch went viral on X, it's still trending in my page after 3 days.
>
> *Terminal showing the make gen command*
> ![[ellen_in_sf-260441-001.jpg]]
>
> ## Why This Is Interesting
>
> At a high level:
>
> 1. You define a program.md describing how to train a model.
>
> 2. The agent writes training code, runs experiments, evaluates results, and iterates.
>
> Instead of manually running experiments, the research loop becomes automated.
>
> Below is a snippet of my agent running the experiment loop for about two hours.
>
> *Agent running the experiment loop*
> ![[ellen_in_sf-260441-002.jpg]]
>
> Quoting Andrej Karpathy:
>
> > Frontier AI research used to be done by "meat computers", humans coordinating through meetings.
> That era is fading. 
> Research is moving toward autonomous swarms of AI agents running across compute clusters.
>
> The implications are big.
>
> Last night I started an experiment and then went painting with friends for two hours. While I was away, the agent kept running experiments.
>
> It made me realize how much waiting time in ML research could disappear.
>
> Agents don't replace researchers, but they can remove a lot of the waiting.
>
> ## The Problem
>
> When looking at the [autoresearch](https://github.com/karpathy/autoresearch) repo, the idea is straightforward, but the setup still requires:
>
> - writing program.md
>
> - structuring experiments
>
> - preparing training code
>
> - tracking results
>
> So I had a simple thought: why not use an LLM to scaffold these docs?
>
> *autoresearch-gen scaffolding process*
> ![[ellen_in_sf-260441-003.png]]
>
> You can clone the repo and try it yourself : [Github - autoresearch-gen](https://github.com/liviaellen/autoresearch-gen)
>
> In summary, autoresearch-gen:
>
> - generates autoresearch boilerplate
>
> - runs analysis on your experiments
>
> - generates Excalidraw diagrams showing how the system works
>
> - tracks experiment and code changes through agent commits
>
> To start, you only need to tell the LLM what you want to do, what data you want to use, and the goal of the experiment.
>
> ## Running Autoresearch in One Command
>
> ```bash
> make gen EXP=experiments/attention-free \
> CONTEXT="Exploring attention-free LLM architectures \
> on M5 Max 48GB (RWKV / SSM / linear attention)" \ 
> DATA="roneneldan/TinyStories" \
> GOALS="Lowest val_bpb without softmax attention"
> ```
>
> The LLM you choose will generate the structured autoresearch code.
>
> Most research visualizations require matplotlib in Jupyter notebooks. For newcomers this means switching tools and writing analysis code.
>
> So I built a simple Streamlit dashboard with Plotly that generates experiment stats and provides basic experiment tracking by calling this command.
>
> ```bash
> make dashboard
> ```
>
> *Streamlit dashboard showing experiment tracking*
> ![[ellen_in_sf-260441-004.jpg]]
>
> You can run the simple dashboard using the sample data included for testing in the github repository.
>
> For one quick test I ran during lunch:
>
> - 30 experiments
>
> - 41% keep rate
>
> - ~26% improvement on the TinyStories dataset
>
> *Experiment results summary*
> ![[ellen_in_sf-260441-005.jpg]]
>
> The goal was exploring attention-free LLM architectures and reducing val_bpb.
>
> Results will vary depending on the input and configuration, so feel free to experiment with different ideas.
>
> The dashboard also allows you to analyze more analytics, understands how effective the experiments are, and generate an excalidraw architecture diagram to showcase the process using make diagram command, or by clicking regenerate diagram on the streamlit dashboard.
>
> *Excalidraw architecture diagram*
> ![[ellen_in_sf-260441-006.jpg]]
>
> The goal of this project is simple: make AI research easier to start for people who are just getting into it.
>
> ## Challenges
>
> While working on this project, I noticed another issue: after multiple iterations, the model can start forgetting parts of the context.
>
> Important variables or experiment details can get lost over time, which means we need a more robust way to store state and properly harness the experiment loop.
>
> This also connects to something Andrej Karpathy mentioned recently, his autoresearch labs were wiped out during an OAuth outage.
>
> Situations like this show that long-running research agents need better state management, recovery, and failover.
>
> *Karpathy's tweet about OAuth outage wiping autoresearch labs*
> ![[ellen_in_sf-260441-007.jpg]]
>
> In other words, to fully harness autoresearch systems, we likely need a more stateful and resilient setup.
>
> I'll explore this more in a future article, my claude code has been running experiments for 18 hours.
>
> *Author info and links*
> ![[ellen_in_sf-260441-008.jpg]]
>
> Repository: [autoresearch-gen](https://github.com/liviaellen/autoresearch-gen) — Code is open source, feel free to fork and have fun
>
> About Author: Ellen is a Growth Engineer at mem0.ai, building the memory layer for AI agents. 6 years as an ML Engineer across the Middle East and Asia. Ran AR studio filterqu (5B impressions, 10M users). Writes for Towards Data Science.
>
> Engagement: 92 likes | 10 retweets | 5 replies
> [Original post](https://x.com/ellen_in_sf/status/2032526928352260441)
