---
created: 2026-09-11
description: Map of Content for Training Data — notes whose subject is the production of training data itself: corpus synthesis, environment and task construction, and the verification machinery that makes either usable.
type: moc
tags: [moc, training-data, synthetic-data, rl-environments, data-curation]
---

# Training Data

The unit of progress in post-training is increasingly **the dataset, not the checkpoint**. These notes are about building that artifact — as distinct from the algorithms and training recipes that consume it, which stay in `ML Research/Reinforcement Learning/` (GSPO, GRPO, policy optimization, and the post-training runs whose subject is a measured result rather than a constructed dataset).

The boundary this folder deliberately does *not* draw is between "corpus" and "environment": [[Daniel Ching's On Data I argues the post-training datapoint has become an executable environment not a corpus row]] argues they are the same thing at different maturities, so both sit here under one roof.

## Cross-Cutting

Notes that span both corpus synthesis and environment construction — frontier-lab data pipelines where the two are one system, and cross-lab comparisons of how the artifact gets made.
- [[Viv reads four data-generation trends out of DeepSeek V4.1 and Kimi K3 - solve-inspect-repair and per-domain pipelines are in DeepSeek's report, the knowledge graph is Kimi's alone]] — Viv distils four data-generation and RL-environment trends from the DeepSeek-V4.1-Flash and Kimi K3 reports; checked against the DeepSeek report verbatim in this vault, the multi-agent solve-inspect-repair loop and the per-domain pipeline split are documented almost literally, while the progressive-difficulty ladder and the knowledge graph belong to Kimi or to nobody.

## Corpus Synthesis

How training corpora get made: synthetic generation, rephrasing, curation, dedup, and the generator/student scaling questions underneath them.
- [[Joel Niklaus says FinePhrase's 1B generator ceiling is an artifact of the 1.7B ablation student - scale the student to 6.2B and 12B generators pull ahead]] — Joel Niklaus, who led HuggingFace's Synthetic Data Playbook, tells Yacine Mahdid that FinePhrase's headline finding — generators past 1B buy nothing — is an artifact of measuring on a 1.7B ablation student; sweeping the student from 0.5B to 6.2B restores the advantage of larger generators, while div…
- [[prompt design is the single biggest lever for synthetic pretraining data]] — HuggingFace's FinePhrase team ran 90 experiments generating over 1 trillion tokens to find that prompt design (FAQ, Math, Table, Tutorial formats) is the single biggest lever for synthetic pretraining data, and a 1B model suffices — bigger models buy nothing.
- [[scaling embedding models requires LLM-labeled deduplication to fix the fake negative problem]] — "Training state-of-the-art embedding models requires scaling to exact softmax with LLM-based deduplication of fake negatives, which compounds as dataset size grows."

## Environments and Tasks

How executable environments and RL task suites get built, verified, and scaled — the artifact the post-training loop actually optimizes.
- [[CUDA game kernels beat JAX RL environments 7x because PyTorch dispatch overhead dominates tiny networks not simulation]] — Elliot Arledge reimplemented Craftax-Classic as 1063 lines of CUDA, hitting 8M SPS at 65k environments on a single 3090, revealing that PyTorch op dispatch overhead for tiny MLPs — not environment simulation — was the actual training bottleneck.
- [[Daniel Ching's On Data I argues the post-training datapoint has become an executable environment not a corpus row]] — Part one of Daniel Ching's three-part series written after four months in the data market at Datacurve during the DeepSWE release - pretraining and post-training need structurally different data, so re-feeding a web-scale corpus into post-training wastes compute; the atomic post-training datapoint i…
- [[Daniel Ching's On Data II makes environment quality a verification problem - prompt-verifier bijectivity, realism, and ex post trace analysis]] — Part two of Daniel Ching's series written after four months at Datacurve during the DeepSWE release - novelty alone gives any environment minimal training value, but real construction starts from having seen enough model behaviour to recognise a consistent failure mode; he gives five ex ante task-de…
- [[Decagon's failure-informed data flywheel promotes a failure hypothesis into a sampling dimension only when a classifier and a measured accuracy gap validate it]] — Cyrus (Decagon) lays out a continuous post-training loop whose optimization target is the dataset rather than the checkpoint - a council of debating LLM judges calibrated against a human golden set produces labels, failures are mined from the exact checkpoint under evaluation and clustered into hypo…
- [[Prime Intellect general-agent self-evolves a tool-use corpus through a synthesizer-solver game gated on empirical pass-rate bands]] — Prime Intellect open-sources general-agent, a fully synthetic environment that grows its own 4,504-task / 1,040-domain / 8,000-tool corpus by formulating task creation as a 2-player game where a synthesizer LLM proposes tiered tasks and a solver LLM gates each tier against a target pass-rate band.
- [[RL environments are the new unit of progress in agentic AI training]] — As AI becomes agentic, RL progress shifts from algorithm innovation to environment design — environments define what "better" means, while frameworks like NeMo Gym and Unsloth handle the optimization.
- [[Sergio Paniego traces RL environments from OpenAI Universe to OpenEnv - the idea barely changed while five missing pieces arrived separately]] — Sergio Paniego's history-of-ideas piece for Hugging Face's Training Agents series argues that OpenAI Universe (2016) already described what frontier labs now call computer use, that the Gym reset()/step() contract outlived every environment built on it, and that RL environments work today not becaus…
- [[rl environment creation is becoming a distributed marketplace that could 10x cost efficiency over contracting firms]] — The hidden industry of building RL training environments for frontier labs is ripe for disruption by distributed bounty platforms with automated LLM-adversarial verification, offering 6-10x cost improvements over contracting firms.
