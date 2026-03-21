---
created: 2026-03-21
description: CodeScout is an RL recipe that trains 1.7B-14B parameter models to search codebases using ripgrep and sed, achieving SoTA on SWE-Bench Verified/Pro/Lite and outperforming models 18x their size.
source: https://x.com/aditya_soni_8/status/2035008866438561874
type: learning
---

## Key Takeaways

CodeScout directly validates the thesis that [[coding agents are bottlenecked by search not coding ability|coding agents are bottlenecked by search, not coding ability]] — by training dedicated search models via RL, even 1.7B-parameter models outperform 18x larger general-purpose LLMs on SWE-Bench. The approach is deliberately narrow: no code graphs, no Python-specific AST tools, just a terminal with standard Unix utilities.

The most striking finding is command convergence during RL training. CodeScout-14B settles on just two commands (ripgrep and sed), while CodeScout-4B uses four (adding cat and xargs). This mirrors the pattern described in [[searching more and thinking less improves agentic efficiency and generalization]] — agents that constrain their search strategy rather than expanding it achieve better results. The model discovers the minimal effective toolset through reward optimization rather than having it prescribed.

The RL recipe uses a multi-granularity reward function (F1 scores summed across file, class, and function localization) trained with GSPO on 2-10K issues from SWE-Smith. The warm-up strategy of distilling the 14B model into the 1.7B model via rejection-sampling fine-tuning before RL is a practical technique for making [[RL environments are the new unit of progress in agentic AI training|RL training]] feasible at small scale.

Augmenting OpenHands with CodeScout-14B locations improves both resolution rate and efficiency, demonstrating that specialized search models can serve as a retrieval front-end for general coding agents — a modular architecture where [[stable agentic RL requires sequence-level clipping and environment-aware advantages to prevent training collapse|search and editing are separate, composable capabilities]].

## External Resources

- [CodeScout Paper](https://arxiv.org/abs/2603.17829) — arXiv paper describing the RL recipe, reward function design, and benchmark results
- [CodeScout GitHub](https://github.com/OpenHands/codescout) — source code and training infrastructure
- [CodeScout Models on HuggingFace](https://huggingface.co/collections/OpenHands/codescout) — pre-trained 1.7B, 4B, and 14B models

## Original Content

> @Aditya_Soni_8 (Aditya Soni) — Fri Mar 20 15:01:37 +0000 2026
>
> Can we train code agents to search relevant locations in a codebase only using a terminal?
> Introducing CodeScout: an effective RL recipe for code search 🚀
>
> 🏆 Outperforms 18x larger OSS LLMs
> 🔥 Comparable to proprietary LLMs
> 📈 SoTA on SWE-Bench Verified, Pro, & Lite
> 🧵 [1/N]
>
> *CodeScout overview and benchmark positioning*
> ![[aditya_soni_8-561874-001.jpg]]
>
> url: https://x.com/Aditya_Soni_8/status/2035008866438561874

> @Aditya_Soni_8 (Aditya Soni) — Fri Mar 20 15:01:38 +0000 2026
>
> To fix GitHub issues, code agents must localize relevant context from the repository. Prior agentic methods rely on complex tools (e.g code graphs) that are Python-specific and expensive to deploy/train. CodeScout simply uses a terminal typical of standard coding agents! [2/N]
>
> *Problem setup: localizing relevant code context from repositories*
> ![[aditya_soni_8-561874-002.jpg]]
>
> url: https://x.com/Aditya_Soni_8/status/2035008870741946466

> @Aditya_Soni_8 (Aditya Soni) — Fri Mar 20 15:01:38 +0000 2026
>
> ✨ Our RL recipe:
> Process the gold issue resolution patch to determine ground truth locations at 3 granularities: files, classes, and functions
> Reward function: Sum of F1 scores for all 3 granularities
> Train 1.7B, 4B and 14B LLMs with GSPO on ~2-10K issues from SWE-Smith [3/N]
>
> *RL training recipe with multi-granularity reward function*
> ![[aditya_soni_8-561874-003.jpg]]
>
> url: https://x.com/Aditya_Soni_8/status/2035008874520961516

> @Aditya_Soni_8 (Aditya Soni) — Fri Mar 20 15:01:40 +0000 2026
>
> CodeScout uses standard Unix command-line utilities (like ripgrep, sed) to localize relevant files, classes and functions of code. During RL, we first warm-up the base 1.7B model by distilling CodeScout-14B using rejection-sampling fine-tuning. [4/N]
>
> *Training pipeline and distillation strategy*
> ![[aditya_soni_8-561874-004.jpg]]
>
> url: https://x.com/Aditya_Soni_8/status/2035008879252193500

> @Aditya_Soni_8 (Aditya Soni) — Fri Mar 20 15:01:41 +0000 2026
>
> 🏆 SoTA Results on SWE-Bench Verified, Pro, and Lite: Our models outperform 8-18x larger base and post-trained LLMs, closing the gap with and even outperforming frontier closed-source models. The performance and efficiency gains are consistent across three benchmarks. [5/N]
>
> *SWE-Bench results across Verified, Pro, and Lite*
> ![[aditya_soni_8-561874-005.jpg]]
>
> url: https://x.com/Aditya_Soni_8/status/2035008883937128956

> @Aditya_Soni_8 (Aditya Soni) — Fri Mar 20 15:01:42 +0000 2026
>
> 🤔Do we really need all the Unix terminal commands?
> We observe convergence in the number of utilities used by the model during RL. Surprisingly, CodeScout-14B only needs 2 commands (ripgrep and sed) and CodeScout-4B needs ripgrep, sed, cat, and xargs. [6/N]
>
> *Command convergence during RL training*
> ![[aditya_soni_8-561874-006.jpg]]
>
> url: https://x.com/Aditya_Soni_8/status/2035008888802549790

> @Aditya_Soni_8 (Aditya Soni) — Fri Mar 20 15:01:43 +0000 2026
>
> 📈 Does effective code localization improve coding agent performance?
> Augmenting OpenHands with locations retrieved by CodeScout-14B improves both issue resolution rate and efficiency! [7/N]
>
> *OpenHands augmentation results*
> ![[aditya_soni_8-561874-007.jpg]]
>
> url: https://x.com/Aditya_Soni_8/status/2035008892304773180

> @Aditya_Soni_8 (Aditya Soni) — Fri Mar 20 15:01:43 +0000 2026
>
> 📄: https://arxiv.org/abs/2603.17829
> 💻: https://github.com/OpenHands/codescout
> 🤗: https://huggingface.co/collections/OpenHands/codescout
> Huge thanks to @gneubig, @lintangsutawika & team: @27upon2, @apurvasgandhi, @taha_yssne, @sanidhya903, @LeonLee_ai, @nlpxuhui, @yilinjz, Leander.
> Thanks to @modal & @cmuflame for the GPUs! [8/8]
>
> url: https://x.com/Aditya_Soni_8/status/2035008895454720456

[Original thread](https://x.com/aditya_soni_8/status/2035008866438561874)
