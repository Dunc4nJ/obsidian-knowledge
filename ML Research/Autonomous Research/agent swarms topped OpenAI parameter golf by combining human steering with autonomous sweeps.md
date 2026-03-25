---
created: 2026-03-25
description: rLLM deployed 129 autoresearch agent runs on their Hive platform to top OpenAI's Parameter Golf leaderboard twice, with only two hours of human steering providing direction while the swarm handled parameter sweeps and ablations
source: https://x.com/rllm_project/status/2036580784870678855
type: framework
---

## Key Takeaways

The core pattern is human-directed autonomous sweeps: humans set strategic direction (try int5 quantization, adopt this PR, stack orthogonal techniques) while [[autoresearch lets an AI agent run ML experiments autonomously overnight|autoresearch]] agents handle the mechanical parameter exploration. Of 129 agent runs, most random exploration was wasted — the value came from two interactive steering sessions totaling about two hours. This directly validates what [[autoresearch agents exploit unconstrained metrics and need multi-objective gates with regular human steering]] found: agents without direction drift into shallow exploration with diminishing returns.

The Hive platform extends single-agent autoresearch into [[distributed research swarms close the feedback loop that single-agent autoresearch leaves open|distributed research swarms]] where agents share a leaderboard, post insights to a feed, and build on each other's work. The competitive optimization setting (16MB model, 600s training on 8xH100) created exactly the kind of [[tight constraints make autonomous agents more useful than open-ended freedom|tight constraints]] that make agents most useful — every architectural decision is a quantifiable tradeoff.

Two distinct strategies produced two leaderboard-topping submissions. "Go deep" found that int5 quantization for MLP weights (exploiting ReLU² sparsity) freed 1.86MB of artifact budget, which the agent autonomously discovered was best spent on scaling BigramHash embeddings from 4096 to 10240 rows — a non-obvious allocation the humans hadn't predicted. "Go wide" stacked four orthogonal techniques (GPTQ-lite, EMA, extended warmdown, later QAT onset) atop a community architecture, each composing cleanly because they operate on independent parts of the pipeline.

The agent swarm also proved valuable for reproducing and validating community PRs — it confirmed PR #162 was real while discovering PRs #144 and #102 were fake (just baseline code). This kind of systematic verification would have consumed significant human attention. The pattern mirrors what [[autoresearch loops cheat when guardrails are loose but converge on real findings when tightly scoped]] documents: agents are reliable within well-defined verification boundaries.

Failed approaches are equally instructive: shared MLP layers saved 2MB but cost 0.03 BPB (catastrophic), int4 quantization hit a steep quality cliff, fancier embedding schemes couldn't beat simply more rows, and true 6-bit packing saved nothing because zstd was already exploiting unused high bits. The int5 sweet spot was genuinely a sweet spot, not a point on a smooth curve.

## External Resources

- [Hive Platform](https://hive.rllm-project.com) — rLLM's open-source platform for collaborative agent evolution on shared artifacts
- [Hive GitHub](https://github.com/rllm-org/hive) — source code for the Hive platform
- [Parameter Golf Challenge](https://github.com/openai/parameter-golf) — OpenAI's competitive optimization challenge: best language model in 16MB
- [autoresearch](https://github.com/karpathy/autoresearch) — Karpathy's autonomous ML experiment agent used as the base agent in the swarm
- [PR #180 — First #1 submission](https://github.com/openai/parameter-golf/pull/180) — int5 MLP + BigramHash scaling, val_bpb 1.1428
- [PR #414 — Second #1 submission](https://github.com/openai/parameter-golf/pull/414) — GPTQ-lite + EMA stack, val_bpb 1.1228

## Original Content

> @rllm_project — 2026-03-24
>
> Article: How We Topped OpenAI's Parameter Golf Challenge, Twice
>
> TLDR: We deploy a swarm of @karpathy's autoresearch agents on Hive -- our platform for collaborative agent evolution, for @OpenAI's Parameter Golf challenge. With 129 agent runs over 3 days, we produce two #1 submissions, and take about 2 hours of human attention. Here's how we did it:
>
> ---
>
> **The Challenge**
>
> Parameter Golf is a competitive optimization challenge: train the best language model that fits in 16MB, in at most 10 minutes on 8×H100 GPUs. Your artifact — code plus compressed model checkpoint — must be under 16,000,000 bytes. The metric is val_bpb (bits-per-byte on FineWeb validation). Lower is better. The baseline starts around 1.22.
>
> The constraints make every decision a tradeoff. More layers means bigger checkpoints. Better quantization means training instability. Bigger batch size means fewer optimization steps in the time budget. You can only modify one file: train_gpt.py, capped at 1,500 lines.
>
> Constraints:
> - Artifact ≤ 16 megabytes
> - Training ≤ 600 seconds (8×H100)
> - train_gpt.py ≤ 1,500 lines
>
> Our Best Result: 1.1228 val_bpb, 15.55 MB · 1,402 lines · 11 layers · int6+zstd-22
>
> We used Hive, our open-source platform where AI agents collaboratively evolve shared artifacts. Each agent gets an isolated fork of the task repo, runs experiments, and submits improvements to a shared leaderboard. Agents share insights via a feed and can build on each other's work. Our agent (random-seed) ran autoresearch in a loop: read the code, make a change, train, evaluate, submit if improved. Over the challenge, the swarm executed 129 runs, recording 52 improvements. But most of the value came from two interactive sessions where we steered the agent directly — maybe 2 hours of our time total.
>
> ---
>
> **The Strategy: Go Deep, then Wide**
>
> We hit #1 on the leaderboard twice, with two different approaches. Looking back, they map cleanly to two strategies.
>
> The first #1 (PR #180) came from going deep. We noticed that every competitive solution used int6 quantization and treated it as a fixed cost. We asked: what if we could make that cost cheaper? If we could save bytes on quantization, those bytes could be reinvested into model capacity. We didn't know exactly how we'd reinvest them yet — but we knew the savings would be universal, applicable to any architecture.
>
> The second #1 (PR #414) came from going wide. By then we had a thorough understanding of which techniques worked and why. When we saw a community PR with a strong 11-layer architecture, we adopted it immediately. And when we saw GPTQ-lite — a smarter quantization approach — we recognized it would compose cleanly with everything else. We stacked four independent techniques on top of someone else's architecture, and each one worked exactly as expected.
>
> The common thread: neither submission was random exploration. The first was a deliberate bet on a universal bottleneck. The second was informed combination of well-understood techniques. The agent swarm handled the mechanical work — parameter sweeps, ablations, training runs — but the direction came from understanding what mattered.
>
> **Go Deep — First #1: Int5 MLP + Big Hash Table (1.1428)**
>
> The observation: Everyone in the competition was using int6 quantization for all weights. Int6 uses 6 of 8 bits per byte; with zstd-22 compression, those 2 unused bits help, but the compression ratio is only about 1.51×. We noticed that MLP weights are more tolerant of quantization noise than attention weights (ReLU² sparsity helps), and asked: what if we dropped MLP precision to int5?
>
> Int5 leaves 3 zero high bits per byte. Zstd loves this: 1.88× compression ratio vs int6's 1.51×. For a 10-layer model, this saves about 1.86 MB. That's enormous in a 16MB budget.
>
> This turned out to be exactly the kind of deep, generalizable improvement we were betting on. After PR #180 landed, int5-MLP became widely adopted across the competition — PRs #76, #458, #349, #466, #302, #295, and others all built on the int5-MLP/int6-attn split. PR #469 even pushed it further with all-int5 on a larger model (d=576, 27M params), validating the "train larger, quantize harder" principle. The technique became part of the community's consensus baseline stack.
>
> The tradeoff: Int5 MLP costs about +0.008 BPB in model quality. That's real. But 1.86 MB of freed space is enough to fit an entire extra transformer layer — and an extra layer gives back about -0.01 BPB. Net: -0.002 BPB for free.
>
> We steered the agent to explore this direction: try int5 for MLP weights, keep int6 for attention, and see if the loss is tolerable. It was.
>
> The agent finds the best use of freed space: Once int5 MLP was working, we had ~1.8 MB of free artifact budget. We suggested the agent try a wider MLP or larger hidden dimension. But the agent ran the experiments and found that the most effective use of the extra bytes was more rows in the BigramHash embedding table — scaling from 4,096 to 10,240 buckets. We hadn't predicted this.
>
> Timeline:
> - Baseline: 9L, int6 everything, bigram=4096 → val_bpb = 1.1485
> - Human steers: try int5 MLP → 9L, int5 MLP / int6 attn → val_bpb = 1.1566 · Worse — but 1.86 MB freed.
> - Reinvest in 10th layer → 10L, int5 MLP / int6 attn → val_bpb = 1.1480 · Better than 9L baseline. Under budget.
> - Agent tunes HP → WD=0.04, SWA/50, SWA_start_frac=0.4 → val_bpb = 1.1446
> - Agent discovers bigram scaling → BigramHash 4096 → 10240 → val_bpb = 1.1426 · Spending freed bytes on richer embeddings.
> - PR #180 submitted → val_bpb = 1.1428 (3-seed mean) — #1 on the leaderboard · 15.52 MB · 24.7M params · 6,694 steps in 600s
>
> **Go Wide — Second #1: GPTQ-lite + EMA (1.1228)**
>
> After the first #1, the community kept moving. PR #374 introduced a strong 11-layer architecture with U-Net skip connections, XSA on the last 4 layers, Partial RoPE, learned LN Scale, and VE128. It reached val_bpb=1.1244. We didn't try to out-architect them. We adopted it.
>
> The key insight was GPTQ-lite. Standard int6 quantization uses naive min/max clipping. GPTQ-lite tries 5 different clip percentiles per row and picks the one with minimum reconstruction error. It's strictly better quantization at the cost of a slower export step. The moment we saw this, we knew it would work on top of PR #374. GPTQ-lite operates entirely at export time — it doesn't touch training, architecture, or the optimizer. It's completely independent of everything else in the pipeline.
>
> The agent swarm then found three additional improvements through autonomous exploration: EMA averaging (decay=0.997), extended warmdown (3500 steps), and later QAT onset (15% instead of 10%).
>
> Total: -0.0015 BPB over the PR #374 base. val_bpb = 1.1228 (best seed). #1 again.
>
> ---
>
> **What Works and What Doesn't**
>
> Let us be honest about the agent swarm. It ran 129 experiments. Most of them were wasted. Left to its own devices, the agent does random config changes — try a different learning rate, swap an activation function, tweak a hash table size. Each one is individually reasonable. Few of them move the needle.
>
> Where the agent shines: The agent becomes valuable when you give it a good direction and let it explore within that direction.
>
> After we established that int5 MLP was viable, we let the agent figure out where to spend the freed bytes. We suggested wider MLP or larger hidden dim. The agent tried those, found they didn't help as much, and discovered on its own that scaling the BigramHash table to 10,240 rows was the best allocation. These are the kinds of parameter sweeps that would have taken us hours of manual effort, and the agent did them overnight.
>
> The agent was also excellent at reproducing community PRs. We pointed it at PRs #144, #102, and #162. It reproduced each one, discovered that #144 and #102 were fake (submitted code was just the baseline), and confirmed that #162 was real. This saved us from wasting time on dead ends and gave us confidence in the foundation we were building on.
>
> Without the agent, we wouldn't have achieved this — the parameter sweeps alone would have consumed far more attention than we were willing to spend. But without the steering, the agent would have spent 129 runs doing random exploration with nothing to show for it. The agent saved our attention. We gave it direction.
>
> What didn't work:
>
> For every technique that landed, several didn't:
>
> - Shared / Reused MLP Layers — Sharing FFN weights across transformer layers saves ~2MB. But it costs 0.03 BPB — catastrophic. We tried per-layer adapters (IA3, LoRA, diagonal scaling, conditional bias) to recover quality. None of them came close.
>
> - More Aggressive Quantization (int4) — If int5 worked for MLP, why not int4? Because the quality cliff is steep. Int4 MLP degraded val_bpb by more than an extra layer could recover. The int5 sweet spot was genuinely a sweet spot, not a point on a smooth curve.
>
> - Fancier Embedding Tables — We tried trigram hash, multi-gram hash (uni+bi+trigram from the same table with learned mixing), adaptive bigram (learned gate between bigram and unigram), and various embedding dimensions. None of them beat simply having more rows in a standard BigramHash table.
>
> - True 6-bit Packing — Actual bit-level packing of int6 weights should save 25% raw. But zstd was already exploiting the unused high bits. Compressed savings: nearly zero. A clever idea that the compression algorithm had already thought of.
>
> ---
>
> **Conclusion**
>
> The steering we provided was tactical: try int5, adopt this PR, stack these techniques. None of it required uniquely human insight — a better agent with more context about the competitive landscape could have figured it out. As models improve, the bar for useful human input keeps rising.
>
> What excites us is that even with today's agents, the combination already works. A swarm that can run 129 experiments overnight, reproduce community PRs, and sweep parameter spaces — paired with a human who occasionally points it in a good direction — was enough to top the leaderboard twice. That ratio of human effort to outcome is only going to get better.
>
> The challenge is still open at openai/parameter-golf. If you want to try the agent swarm approach yourself, join us on Hive.
>
> Engagement: 151 likes | 18 retweets | 5 replies
> [Original post](https://x.com/rllm_project/status/2036580784870678855)
