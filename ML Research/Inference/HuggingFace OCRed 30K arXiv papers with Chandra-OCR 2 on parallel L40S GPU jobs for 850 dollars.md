---
created: 2026-04-15
description: Niels Rogge describes how HuggingFace converted 27K arXiv papers lacking HTML versions to Markdown using Chandra-OCR 2 via vLLM on 16 parallel L40S GPU jobs, orchestrated by OpenAI Codex, for approximately $850 in one day.
source: https://huggingface.co/blog/nielsr/ocr-papers-jobs
type: learning
---

# HuggingFace OCRed 30K arXiv papers with Chandra-OCR 2 on parallel L40S GPU jobs for 850 dollars

## Key Takeaways

- Open-source OCR at scale is now cheap: 27K arXiv papers converted to Markdown for ~$850 on 16 parallel L40S GPUs in one day, versus $1,841-$2,762 via Chandra's own API. The [[LightOnOCR-2 outscores proprietary models at table extraction with 1B parameters|same pattern]] of small specialized models beating proprietary services at a fraction of the cost applies here. Model selection was driven by the OlmOCRBench leaderboard — [[Chandra-OCR 2]] topped it at time of writing.

- GPU selection matters more than GPU cost: L40S processes ~60 papers/hour vs A10G's ~32/hour, making L40S cheaper overall ($850 vs $1,350 for 16x parallel) despite higher hourly rates. This echoes the throughput-over-price insight from [[paged attention applies OS virtual memory paging to KV cache and unlocks 2-4x LLM serving throughput|vLLM's PagedAttention]] — faster inference changes the cost calculus.

- HuggingFace Buckets with hf-mount eliminate the upload/download bottleneck for large-scale processing. Writing OCR results to a mounted bucket instead of git-versioned datasets avoids the commit-per-paper problem and makes the processing scripts simpler — agents just write to what looks like a local filesystem.

- A coding agent (Codex) orchestrated the entire pipeline: writing the vLLM processing script, benchmarking GPU options, launching 16 parallel jobs, monitoring progress, and merging results. The human role reduced to prompting and checking in. This is the [[the harness is everything and agent performance comes from environment design not model capability|harness pattern]] applied to infrastructure tasks — point the agent at docs (model card + HF CLI skill) and let it figure out execution.

## External Resources

- [Chandra-OCR 2](https://huggingface.co/datalab-to/chandra-ocr-2) — the OCR model used, OpenRAIL licensed
- [OlmOCRBench](https://huggingface.co/datasets/allenai/olmOCR-bench) — AllenAI's benchmark for OCR model evaluation
- [HuggingFace Jobs](https://huggingface.co/docs/hub/jobs) — serverless GPU compute platform
- [HuggingFace Buckets](https://huggingface.co/docs/hub/storage-buckets) — non-versioned mutable storage powered by Xet
- [hf-mount](https://github.com/huggingface/hf-mount) — mount HF Buckets as local filesystems
- [arxiv-ocr code](https://github.com/NielsRogge/arxiv-ocr) — the processing scripts
- [Result bucket](https://huggingface.co/buckets/nielsr/arxiv-chandra-ocr-full-markdown-20260406) — the output Markdown files
- [HuggingFace Daily Papers](https://hf.co/papers) — paper submission and discovery platform
- [Codex Desktop app](https://developers.openai.com/codex/app) — OpenAI's coding agent used for orchestration

## Original Content

> [!quote]- Source Material
> 
> **How we OCR'ed 30,000 papers using Codex, open OCR models and Jobs**
> *Niels Rogge, Community Article, Published April 7, 2026*
> 
> On the hub, we index [arXiv](https://www.arxiv.org) papers any time someone mentions an arXiv abstract or PDF link in the README of a model, dataset or Space. Besides, any researcher can submit their work to [Daily Papers](https://hf.co/papers) at <https://hf.co/papers/submit>, up to 14 days after the publication date on arXiv.
> 
> *Daily Papers view*
> ![[nielsr-ocr-papers-001.png]]
> 
> This enables researchers to promote their work by claiming papers using their Hugging Face account (simply clicking on your name will feature it on your account), as well as link the corresponding Hugging Face models, datasets and Spaces, Github URL and project page. Moreover, people can upvote and comment on papers in a Reddit-like way. Finally, it is now also possible to tag papers with organizations, enabling one to feature all research papers on a given organization page such as [NVIDIA](https://huggingface.co/nvidia/papers) or [Google](https://huggingface.co/google/papers). The [@HuggingPapers account on X](https://x.com/HuggingPapers/) also frequently shares about the top trending research on the hub.
> 
> Check at your own papers at <https://huggingface.co/settings/papers>!
> 
> ## HuggingChat integration
> 
> Each Hugging Face paper page now features a "chat with paper" functionality powered by [HuggingChat](https://hf.co/chat). Behind the scenes, this uses the HTML web page of the arXiv paper (e.g. <https://arxiv.org/abs/2603.26599> can be viewed using <https://arxiv.org/html/2603.26599>). The HTML gets turned into Markdown, which is then fed to the LLM as context.
> 
> *HuggingChat integration on paper pages*
> ![[nielsr-ocr-papers-002.png]]
> 
> However, as it turned out, about 27,000 papers indexed on Hugging Face do not have a corresponding HTML web page on arXiv, making it not possible to chat with those papers. Hence, the idea was pretty simple: let's use an open Optical Character Recognition (OCR) model to convert those papers to Markdown.
> 
> ## Using a state-of-the-art open OCR model
> 
> As we needed an open OCR model, it might be hard to know which one to use. Luckily, the Hugging Face team is working on a new feature called [Evaluation results](https://huggingface.co/docs/hub/eval-results), which allows to turn Hugging Face datasets into native leaderboards on the hub. Evaluation results are added by opening pull requests on model repositories, which show up on the respective dataset. Find the current leaderboards [here](https://huggingface.co/datasets?benchmark=benchmark:official&sort=trending).
> 
> For now, [OlmOCRBench](https://huggingface.co/datasets/allenai/olmOCR-bench) by AllenAI is the go-to benchmark for OCR. It's a pretty good place to find which open models are best at converting documents into Markdown, interleaved with HTML for the images and tables contained in them.
> 
> *OlmOCRBench leaderboard on the hub*
> ![[nielsr-ocr-papers-003.png]]
> 
> Hence, we simply decided to use the best model at the time of writing, which is [Chandra-OCR 2](https://huggingface.co/datalab-to/chandra-ocr-2) by Datalab. As the model is openly available with an [OpenRAIL license](https://huggingface.co/datalab-to/chandra-ocr-2/blob/main/LICENSE), we can freely use it for commercial purposes using frameworks like Transformers and vLLM.
> 
> ## Using Hugging Face Jobs
> 
> To run models like Chandra at scale to process thousands of papers, it's recommended to leverage vLLM on GPU infrastructure. In our case, we leveraged [Jobs](https://huggingface.co/docs/hub/jobs) as the serverless compute platform to run the model. Jobs supports both CPUs and GPUs, from an Nvidia T4 all the way to a 8x Nvidia H200s, with pay-as-you-go pricing where you only pay for seconds used.
> 
> We could write a script ourselves to run the model using vLLM on Jobs. However, as it's 2026, nowadays we can simply point a coding agent such as Claude Code, Cursor or Codex to a set of URLs and it will figure it out by itself. So that's exactly what we did.
> 
> We simply asked OpenAI's Codex model (via the [Codex Desktop app](https://developers.openai.com/codex/app)) to implement a script which runs Chandra-OCR-2 on the 27,000 arXiv IDs which currently have their Markdown version missing on the hub on Jobs. We point it to Chandra's [model card](https://huggingface.co/datalab-to/chandra-ocr-2/raw/main/README.md) so it knows how to run it with vLLM, and provide it with the [Hugging Face CLI Skill](https://github.com/huggingface/skills/blob/main/skills/hf-cli/SKILL.md) so it knows how to use Hugging Face's serverless GPU infra.
> 
> *Codex and chill. The first prompt sent to Codex*
> ![[nielsr-ocr-papers-004.png]]
> 
> ### Which GPUs to use?
> 
> As Jobs offers [many GPU flavours](https://huggingface.co/docs/hub/jobs-pricing), I first asked Codex to do some comparisons on a small scale (120 papers) to see which GPUs to use and to estimate their costs. It did experiments on an Nvidia A10G-large as well as an Nvidia L40S GPU by launching jobs in parallel. It concluded to use the L40S, as it was able to process papers faster (about 60/hour when parsing at most 30 pages for each paper compared to 32/hour on the A10G).
> 
> Moreover, it recommended to run 16 jobs in parallel, as processing all papers on a single L40S GPU would take multiple weeks. Running 16 parallel jobs would take about 29-30 hours. It estimated the cost to be about $850. Interestingly, 16x A10G-large is cheaper per hour but slower overall, which would ultimately lead to a larger cost of about $1350.
> 
> For comparison, I also asked Codex how much this would cost with Chandra's [own API](https://www.datalab.to/pricing): $1,841.07 for "fast/balanced" mode and $2,761.60 for "high-accuracy" mode.
> 
> *Codex giving GPU recommendations*
> ![[nielsr-ocr-papers-005.png]]
> 
> Hence, Codex spun up the 16 jobs and monitored their performance. No jobs had to be restarted, they all worked from the first try. Some jobs took longer than others, mainly because they contained many papers with more pages to parse.
> 
> ### Mounted buckets
> 
> At first, we would simply let the script write the results to a Hugging Face dataset. However, the Hugging Face team leverages [Buckets](https://huggingface.co/docs/hub/storage-buckets) for storing the Markdown version of each paper. Buckets are not versioned by git, and instead powered by [Xet](https://huggingface.co/docs/hub/en/xet/index) for fast, cheap and mutable storage. As new papers get added every day, this would result in a huge amount of git commits, hence Buckets are more suited here.
> 
> Moreover, the team just launched [hf-mount](https://github.com/huggingface/hf-mount), which enables to mount Hugging Face Buckets (as well as model, dataset or Spaces repos) as local filesystems. This means that we no longer require to write download/upload functionality: the script (or coding agents in general) can just write to the bucket as it it were local.
> 
> Hence I simply prompted Codex to write to a mounted bucket instead of a Hugging Face dataset, which made the scripts even faster.
> 
> ## The results
> 
> During the run, I frequently asked Codex the same thing: "Great. Can you check the progress?". It then got back to me, telling me how many of the 16 parallel jobs had already finished. After about a day, all 16 jobs were finished.
> 
> *Codex babysitting the runs on Jobs*
> ![[nielsr-ocr-papers-006.png]]
> 
> I then asked it to merge the 16 buckets into a single one. Finally, [Mishig](https://huggingface.co/mishig) integrated them into Paper Pages, so now you can chat with any paper on the hub, not just the ones which have an HTML version on arXiv! Try it for instance at <https://huggingface.co/papers/2603.15031>.
> 
> ## Resources
> 
> Find the code [here](https://github.com/NielsRogge/arxiv-ocr) and the resulting bucket [here](https://huggingface.co/buckets/nielsr/arxiv-chandra-ocr-full-markdown-20260406).

Source: https://huggingface.co/blog/nielsr/ocr-papers-jobs
