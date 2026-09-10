---
created: 2026-09-11
type: thread
source: https://x.com/stochasticchasm/status/2098098053781807215
description: stochasm's live section-by-section reaction thread reading the DeepSeek-V4.1-Flash tech report (57 tweets, 55 screenshots, 17:15 to 23:07 UTC on 10 Sep 2026) — an expert independent read of the same document the vault holds in full. Its load-bearing contribution is a precise mechanism correction on the Causal Encoder-Decoder: it is neither cross-attention nor multi-layer encoder access, just self-attention whose global KV cache arrives pre-filled as a per-layer linear projection of the final encoder hidden states, and the delta against YOCO is that YOCO projects once and shares one identical KV cache across every upper-layer, while CED projects uniquely per decoder layer and only for the global branch of CSA2, leaving each layer's SWA branch computed from its own hidden state. He also corrects the public discourse (DeepSeek does cite YoCo), reads the design as architectural convergence with HySparse, NSA and V4's own CSA/HCA, calls pure CSA2 an improvement on V4's two unexplained compression frequencies, and observes that inference efficiency has become the sole purpose of architectural modification. Separately flags open questions the paper does not answer — why the first two of twenty layers are SWA-only, whether modality-specific experts should be encouraged or suppressed, why convolutions were dropped for Muon when Muon handles them via flattening, and how the L_norm reference length in the reasoning-effort penalty is obtained.
topic: [kv-cache, sparse-attention, inference, attention-architecture, encoder-decoder, fp4-quantization, muon, engram, agentic-rl, reasoning-effort]
---

## Key Takeaways

This is a reaction thread by a knowledgeable reader working through the report section by section, so the three layers below are kept apart deliberately. The vault already holds the primary source in full — [[DeepSeek-V4.1-Flash cuts global KV cache to 890 bytes per token - a quarter of V4-Flash and 437x below V1 - by stacking cross-layer CSA2 reuse, FP4 caching, and a causal encoder-decoder]] — and this note's value is the expert read layered on top of it, not a second copy of the paper's claims. Together with [[Viv reads four data-generation trends out of DeepSeek V4.1 and Kimi K3 - solve-inspect-repair and per-domain pipelines are in DeepSeek's report, the knowledge graph is Kimi's alone]] these form a three-node cluster on the same release: the report is the source, Viv's note is the **data** summary, and this thread is the **architecture and inference-efficiency** review.

### (a) What the paper itself says — verified against the primary-source note

- **The mechanism claims stochasm reacts to are all in the report, and two of his specific factual claims check out.** CED is explicitly "inspired by YoCo (Sun et al., 2024)" in §2.2 — so his discourse correction is correct, and the widespread complaint that DeepSeek failed to acknowledge YOCO is simply wrong. §2.2's Equation 1 states the mechanism he describes: for `l > L/2` the KV entries are `C_l = H_{L/2} W_l^{KV}`, `Z_l = H_{L/2} W_l^Z` — layer-dependent projection weights, i.e. per-layer, from the *final* encoder hidden state only. The **no-dense-attention-warmup** claim is the paper's own sentence, not his inference: "Sparse attention is trained from scratch at a sequence length of 64K, without any dense attention warmup stages." His **Engram-largest-to-date** framing rests on the paper's 196B Engram parameters (§2.1, §2.4.2) against the 51B n-gram parameters he screenshots for Qwen-3.8-Flash-Next; 196B is what the primary note records, so the comparison holds as stated, though "largest to date" is his own survey of the field rather than anything the report asserts.
- **The report backs his reading of the FP4 cache as a storage decision rather than a compute one.** §2.4.4: QAT is extended from the indexer to the *main* KV cache, "where FP4 reduces storage rather than accelerates matrix multiplication," with values dequantized before attention so no native FP4 matmul is needed — E2M1 with one E4M3 scale per 16 channels, following NVFP4 but omitting its second-level global scale because the cache's observed magnitude bound (~10, against the format's 2688 of headroom) makes the scale free. His "no wonder it performs better than other models at fp4 kv cache" is exactly this: the model was *trained* into the format. That contrasts with the post-hoc quantization path in [[Philip Kiely details how Baseten built the world's fastest GLM-5.2 API by stacking NVFP4 quantization, KV-aware routing, prefill-decode disaggregation, and MTP speculation]] and the format-level guidance in [[NVIDIA's hardware-friendly LLM design guide - near-square tile-aligned dimensions, width over depth, NVFP4, and wide expert parallelism]].
- **Post-training's zero-algorithmic-novelty claim is the paper's, and his reading of what follows from it is consistent with it.** §5 states plainly that post-training "introduces no algorithmic innovation" and that "all substantive changes lie instead in the data pipeline." His observation that there are still **no critics and no value modeling** is a factual absence in the report — the recipe is SFT → RL → OPD with group-relative advantages — and his causal account (a strong existing recipe plus batch-invariant kernels and low-precision inference already deliver stable RL, so data is what deserves attention) is the same conclusion the report reaches from the other direction. Same shape as the outcome-reward-in-real-harnesses convergence in [[agentic RL training converges on outcome rewards inside production harnesses across Kimi Cursor and Chroma]].

### (b) What stochasm adds, or explains better than the paper's own prose

- **CED is not cross-attention, and it is not multi-layer encoder access — the single most useful correction in the thread.** He came in assuming, from the launch blog, that "the decoder would be able to attend to the KVs of the encoder section at multiple layers," and found the opposite: "instead it's just a periodic read of the final encoder states… of course, this isn't cross attention, the self-attention just has prefilled KVs." Cross-attention would mean attending *only* to encoder KVs; here the decoder attends to encoder hidden states **in the context of its own sequence up to that point**, because the projected entries sit in the layer's ordinary self-attention KV cache alongside everything the decoder has generated. He reads this as a deliberate and good choice over true cross-attention (which he assumes was ablated), and separately grumbles that "causal encoder-decoder" is a confusing name since nothing in the first half decodes latents to anything — "it's not really a decoder-decoder because you're not using the first half to decode latents to anything."
- **The precise YOCO delta, stated more cleanly than either paper states it.** In YOCO the first half of the model is normal; you then take the hidden states, "project them to K/Vs once more, and then use that identical KV cache for every layer in the second half of the model" — one projection, one cache, shared network-wide across the upper half. In CED it is "basically the same thing, applied **only to the global branch of the CSA2 layers, and uniquely for each layer**." So in the decoder, every CSA2 layer has two branches: a **local SWA branch computed from that layer's own hidden states**, and a **global branch whose KV cache is a linear projection of the encoder hidden states** with that layer's own weights. And the operational consequence he draws out, which the report leaves implicit: "they don't do this during prefill, since you can just get the relevant KVs for decode with a quick linear proj." He also situates CED against **MoDA** as an "allow-KVs-from-earlier-layers type of approach" — a lineage neither report states. YOCO, HySparse, NSA, MoDA and Muon appear nowhere else in the vault, so these comparisons live only in prose here; the closest vault neighbour on how attention architecture keeps rewriting the KV cache is [[From GPT-2 to Kimi K3 - a visual worklog on how attention architecture evolved to fix the KV cache with linear attention, DeltaNet, gating, and hybrid retrieval]].
- **Architectural convergence is the thread's real thesis, and it is an outside view the paper cannot offer about itself.** "Seems similar in design philosophy to hysparse, nsa, and deepseek's own csa/hca from v4. combining a local sliding window branch with a sparse branch for retrieval seems like it's solidifying as a broad view of things." He returns to it twice more — the CSA2 layer diagram gives "hysparse + indexshare type of thing here. sharing global kv + unique swa seems like a decent tradeoff of getting tiny kv cache but still getting each layer to see new states," and the Hierarchical Sparse Indexer gets "very heavy hysparse vibes, just had to mention it again." He also reads **pure CSA2 as an improvement over V4's alternating CSA/HCA**: "it always felt weird that they had two frequencies of compression without any real explanation as to why. i'm sure there's a case to be made for multiple compression frequencies, but different designs felt odd." This is the taxonomy-level view the DeepSeek-versus-the-field notes each only see a slice of — the compaction-side approaches in [[Baseten's STILL perceiver amortizes KV cache compaction into one forward pass, compressing 8x at 85%+ factual retention]] and [[Ramp Labs Latent Briefing compacts KV caches for efficient cross-agent memory sharing]] attack the same cost from outside the architecture, and [[paged attention applies OS virtual memory paging to KV cache and unlocks 2-4x LLM serving throughput]] attacks it from the allocator.
- **The design-philosophy line worth quoting: "it's somewhat interesting that inference efficiency is now the sole purpose of architectural modifications, in a sense."** Paired with the practitioner reading of the same section — "very very inference-informed design. cheap prefill, small KV cache, probably very friendly for PD disagg i'd imagine, seems like you'd get good utilization with larger batch prefill here." That is a serving-topology inference the paper does not make about itself, and it lands directly on the deployment levers in [[Red Hat frames prefill-decode disaggregation, KV-cache tiering, and speculative decoding as the three llm-d deployment levers for distributed AI inference]]. His read of SWA Bounded Replay is likewise a serving argument rather than an architectural one: "for a single request of course you have to use the kv cache in hbm/ram to fulfill the request, but between requests, if it takes up a ton of space, why not just re-prefill those bits. it's a negligible amount of flops at like 500K context anyway" — which is precisely the trade [[camelAI self-hosts DeepSeek V4 Flash on 4x RTX PRO 6000 Blackwell for a fixed-cost free tier, with KV cache as the real bottleneck]] was forced into by hand with a sticky router, now made cheap in the architecture.
- **A taxonomy gap he names and the paper does not: there is no name for index-reuse-without-KV-reuse.** Reacting to the Full/Reindex/Reuse figure — "random part of me wishes the names were more intuitive, like what would you call a mode that re-uses indices but not KV like glm 5.2 here?" The report has this case in its related work (IndexCache reuses Top-K indices but saves no main-KV storage) but never gives it a mode name, because CSA2 does not use it. Worth keeping because it identifies the axis along which the *next* design will differ.
- **Two smaller observations that are sharp enough to keep.** DeepSeek is **breaking the `v<N>` = new pretrain convention** — "they were one of the ones who were still neatly dividing releases like this" — while committing hard to the new architecture. And including **DeepSeek V1 in the KV-cache bar chart is "hilarious"**: V1's 389,120 bytes/token against V4.1-Flash's 890 is what produces the 437× headline, so the paper's most quotable number depends on a three-year-old anchor. Fair thing to smile at without disputing any of the intermediate steps.

### (c) What he speculates about, or asks and does not answer — treat as open questions, not findings

- **Why are the first two layers of twenty SWA-only?** "Two layers out of 20 doesn't seem like it's saving a ton on prefill flops but i guess the less global the cheaper it is. feels like there's a story here, or that it's something like first-k-dense for MoEs." The report states the configuration and gives no motivation. His first-k-dense analogy is a guess.
- **Should modality-specific experts be encouraged or suppressed?** He finds the modality-specific auxiliary-loss-free load balancing "an interesting development" given that modality-specific experts already emerge on their own in modern models, then asks the real question and leaves it open: "do you want to let modality specific experts emerge? do you want to disincentivize them for more embedding space overlap between modalities? i'm sure someone has done work on this that i'm just not aware of yet." He also pushes back on the report's premise: "i'm not seeing why modality-specific imbalance is necessarily harmful unless it's like really really skewed and you're effectively stuck with a smaller model."
- **Why were convolutions removed for Muon compatibility?** DeepSeek-ViT replaces the patch-embedding convolution with a linear projection "to ensure compatibility with the Muon optimizer" — but he notes "keller's original post did mention that muon works with convs (via flattening)," and can only guess: "maybe they tried this and didn't see it performing well."
- **Was DSpark used during pre-training?** Asked early — "does this mean they used dspark during pre-training? i guess we'll see the answer later in the paper" — and the report answers it downthread in a way he does not circle back to: DSpark is trained in a dedicated stage *after* pre-training on a frozen backbone, then kept training alongside the backbone during post-training without gradient flow into it. He does register the related finding with visible regret: "they killed MTP which is kinda sad. guess the performance uplift wasn't worth it at the end of the day?" — which is the change that retires the MTP-1 baseline the production gains in [[DSpark (DeepSeek paper) couples a semi-autoregressive drafter with a hardware-aware confidence scheduler to raise accepted length 16-31% offline and shift DeepSeek-V4's serving Pareto frontier]] and [[elie breaks down DeepSeek's DSpark, a semi-parallel speculative decoder that fuses DFlash's parallel head with an Eagle-style Markov step for +50% throughput and up to 80% lower latency in DeepSeek-V4 production]] were measured against, and reframes the frontier argument in [[Hao AI Lab argues DSpark and JetSpec split the speculative-decoding throughput-latency frontier by adding causality to cheap parallel drafting]].
- **How much will kernel reduction order matter for FP4 KV performance?** "Inference engineers are going to have a fun time with this one. i wonder how much kernel reduction order etc will affect perf here." An open implementation question, not a paper claim.
- **What the no-warmup result unlocks downstream is his inference, and should be read as such.** The absence of a dense warmup is the paper's; the chain he builds on it is not: "long-context pretraining here is probably enabled by the lower prefill flops, but this probably enables things like agentic traces much earlier in training as well. midtraining kinda being absorbed." That last clause is a real prediction about training-stage structure and cuts against the staged view in [[mid-training builds the reasoning foundation that RL amplifies not replaces]]; nothing in the report says the mid-training stage is being absorbed.
- **Why is the Hierarchical Sparse Indexer introduced only at post-training?** "Unsure why this was introduced at post-training, probably because of longer sequences if i had to guess, though 64k is decently long at pretrain still." He does supply the clearest one-line summary of what it does: "basically blockwise scoring -> tokenwise scoring with shared block indices and not shared token indices within the blocks."
- **Where does `L_norm` come from?** On the reasoning-effort length penalty: the reference length "seems to be similar to k3's calibrated per-problem reference length, though they don't say how they get this reference length at all." He likes the scheme — comparing it to OpenAI's juice value for fine-grained control, and noting approvingly that "each group is sampled at one effort level, and each task at multiple effort levels" — but the report does leave `L_norm`'s construction unspecified.
- **Cross-lab comparisons he draws from memory, unverified here.** That checkpoint merging across scaffolds is "a second datapoint on top of MAI-thinking-1 as to how models are continuing RL beyond collapse" — and that the merging itself is "absurd." That millions of *concurrent* DSec sandboxes dwarfs Kimi K3's ~50M sandboxes *cumulatively* over a full run (he screenshots K3's 51,219,741 sandboxes across 1,505,678 images to check himself). That colocated async RL is "becoming more popular with k3 doing the same thing." And that the frozen-then-unfrozen vision encoder is "a big difference from k3 on vision encoders." Each is his own recall of other labs' reports, not something this paper establishes; the multi-agent close — "there's a ton of forms a multi agent harness could look like, and the optimal one is still very much undecided" — is the same undecided-harness-space problem as [[the agent harness is the RL training environment not deployment infrastructure bolted on after]].
- **Engram detail he flags as genuinely novel, with a guess attached.** "Table sizes chosen to be distinct primes - don't recall this being important before"; "4-grams are also not something i think we've seen in other models that used these"; and on FP8 tables, "all in fp8? so fp8 lookup tables, i'm guessing this is inference" — the guess is wrong-footed by the report, which puts both the embedding tables and the key/value projections in FP8 as a *training* configuration. Engram-as-shipped-architecture is the framing that reverses the argument in [[Sentra matches Engram's studied 27B on Harvey's LAB benchmark with zero weight changes, arguing a materialized view is a stored answer and a weight has no address]], where Engram is the weights-side position being argued against.

## Coverage and provenance

- **57 tweets**, all by @stochasticchasm, from **17:15:31 UTC to 23:07:49 UTC on 10 September 2026**. The final tweet opens "to end it off," so the thread is complete as captured — this is not a mid-thread snapshot. The team-lead brief described ~24 tweets and a last post at 20:32 UTC; `bird thread` on the root URL truncates at 31 tweets, and the full 57 only come back when the thread is fetched from its tail (`bird thread` on status `2098186711578943775`). Anyone extending this capture should fetch from the tail, not the root.
- Two visible breaks: a brunch break announced at 18:46 and resumed at 20:05 (79 minutes), and a quieter ~30-minute gap between 21:06 and 21:38.
- **Replies contain nothing substantive.** The root tweet's 8 replies are all anticipation and social chatter — "patiently waiting for this one," "hello, boy who woke up at 10 am," a `@threadreaderapp unroll` request, and one off-topic promotional quote-tweet. stochasm engages with none of them, and no reply on the technical downthread tweets returned anything at all. Nothing worth preserving, so nothing is included below.

## External Resources

- [DeepSeek-V4.1-Flash tech report (PDF)](https://huggingface.co/deepseek-ai/DeepSeek-V4.1-Flash/resolve/main/DeepSeek_V41_Tech_Report.pdf) — the document being read, held verbatim in the primary-source note
- [You Only Cache Once: Decoder-Decoder Architectures for Language Models (arXiv 2405.05254)](https://arxiv.org/abs/2405.05254) — Sun, Dong, Zhu et al. (Microsoft Research / Tsinghua); the YOCO paper CED is built on and cites, screenshotted twice in the thread
- [Keller Jordan, "Muon: An optimizer for hidden layers in neural networks"](https://kellerjordan.github.io/posts/muon/) — the original Muon post whose convolution guidance ("Muon can be used for 4D convolutional parameters by flattening their last three dimensions") stochasm cites against DeepSeek's stated reason for dropping the ViT patch-embedding conv
- [Attention Is All You Need (arXiv 1706.03762)](https://arxiv.org/abs/1706.03762) — the original Transformer figure he invokes when noting CED "somewhat follows the original transformer"
- [Kimi K3 tech report](https://github.com/MoonshotAI/Kimi-K3) — the comparison document he screenshots for sandbox counts and colocated async RL

## Original Content

Full thread, verbatim, in thread order. Every tweet's timestamp and status URL is preserved. All 55 screenshots are embedded at the tweet they were posted with, captioned by what they actually show. Five of them duplicate figures already captured in the primary-source note as `dsv41flash-NNN.png`; the captions say so rather than presenting them as new.

> [!quote]- stochasm (@stochasticchasm) — reaction thread reading the DeepSeek-V4.1-Flash tech report, 57 tweets, 10 Sep 2026 17:15–23:07 UTC
>
> **1.** `17:15:31 UTC` · [status](https://x.com/stochasticchasm/status/2098098053781807215) · 248 likes, 17 RTs, 8 replies
>
> good morning (reaction thread)
>
> *Title page of the report: "DeepSeek-V4.1-Flash: Pushing the Limits of KV Cache Compression", DeepSeek-AI, with the abstract's opening on long-horizon agents making workloads input-heavy and prefill plus large KV caches as the primary deployment bottleneck*
> ![[stochasticchasm-807215-001.jpg]]
>
> ---
>
> **2.** `17:18:39 UTC` · [status](https://x.com/stochasticchasm/status/2098098843971952829)
>
> big headline of course is the causal encoder-decoder. honestly a bit of a confusing name, though i kinda think it's accurate. it's not really a decoder-decoder because you're not using the first half to decode latents to anything. even though it's causal
>
> *Abstract passage he is reacting to, highlighted: the CED architecture activates 16B parameters per token during decode but only 8B during prefill*
> ![[stochasticchasm-807215-002.jpg]]
>
> ---
>
> **3.** `17:20:38 UTC` · [status](https://x.com/stochasticchasm/status/2098099340942434629)
>
> i've already seen a gazillion comparisons to YOCO, which does feel very similar. and they call it a decoder-decoder there, so maybe we should just stick with decoder-decoder? not that this is important either way.
>
> *Title page of the YOCO paper — "You Only Cache Once: Decoder-Decoder Architectures for Language Models", Sun, Dong, Zhu, Huang, Wang, Ma, Zhang, Wang, Wei (Microsoft Research / Tsinghua)*
> ![[stochasticchasm-807215-003.jpg]]
>
> *YOCO Figure 1: the self-decoder / cross-decoder split with a single shared KV cache, and its reported inference gains at 512K context — 6.4x GPU memory, 9.6x throughput, 30.3x prefilling latency against a Transformer*
> ![[stochasticchasm-807215-004.jpg]]
>
> ---
>
> **4.** `17:20:59 UTC` · [status](https://x.com/stochasticchasm/status/2098099428238455018)
>
> will probably get back to comparing to yoco once i land on that part of the tech report
>
> ---
>
> **5.** `17:22:49 UTC` · [status](https://x.com/stochasticchasm/status/2098099890245275876)
>
> before we get into the meat of the tech report, i think it's pretty crazy how high the benchmarks of this thing are. and going 4x smaller on the kv cache compared to dsv4-flash is also insane.
>
> *Report Figure 1 — (a) agentic-benchmark bars against Kimi-K3, GLM-5.3, Opus5 and GPT5.6-Sol, and (b) the generational KV-cache waterfall: V1 389,120 → V3.2 48,068 → V4-Flash 3,514 → V4.1-Flash 890 bytes per token. Same figure as `dsv41flash-001.png` in the primary-source note*
> ![[stochasticchasm-807215-005.jpg]]
>
> ---
>
> **6.** `17:27:20 UTC` · [status](https://x.com/stochasticchasm/status/2098101027748925540)
>
> i'm surprised that they're breaking the v<N> = new pretrain convention, they were one of the ones who were still neatly dividing releases like this. though the commitment to this new architecture is really cool to see. it's neat how this seems like a simplification of v4 and they claim it trained much more stably as well
>
> ---
>
> **7.** `17:28:27 UTC` · [status](https://x.com/stochasticchasm/status/2098101307194380545)
>
> as a side note it's hilarious to include deepseek v1 in the kv cache bar chart
>
> ---
>
> **8.** `17:32:29 UTC` · [status](https://x.com/stochasticchasm/status/2098102323268767832)
>
> seems similar in design philosophy to hysparse, nsa, and deepseek's own csa/hca from v4. combining a local sliding window branch with a sparse branch for retrieval seems like it's solidifying as a broad view of things
>
> *Introduction passage, highlighted: DeepSeek-V4 combines a full-context global attention branch with local SWA; the global branch maintains main KV plus indexer K while SWA's storage is bounded independently of sequence length, so global KV dominates the runtime footprint at long context*
> ![[stochasticchasm-807215-006.jpg]]
>
> ---
>
> **9.** `17:35:12 UTC` · [status](https://x.com/stochasticchasm/status/2098103008420831430)
>
> very very inference-informed design. cheap prefill, small KV cache, probably very friendly for PD disagg i'd imagine, seems like you'd get good utilization with larger batch prefill here
>
> *The CED summary sentence, highlighted: decoder global KV is projected from the final encoder hidden states, enabling 8B activated parameters at prefill and 16B at decode — "particularly cost-effective for input-heavy agentic scenarios"*
> ![[stochasticchasm-807215-007.jpg]]
>
> ---
>
> **10.** `17:35:45 UTC` · [status](https://x.com/stochasticchasm/status/2098103145629102139)
>
> it's somewhat interesting that inference efficiency is now the sole purpose of architectural modifications, in a sense
>
> ---
>
> **11.** `17:37:20 UTC` · [status](https://x.com/stochasticchasm/status/2098103543542747586)
>
> i'm a fan of "pure CSA2" over the alternating CSA/HCA setup from v4, it always felt weird that they had two frequencies of compression without any real explanation as to why. i'm sure there's a case to be made for multiple compression frequencies, but different designs felt odd
>
> *The passage stating the change, highlighted: unlike DeepSeek-V4's CSA–HCA hybrid, V4.1-Flash uses pure CSA2, with FP4 global KV caches during training at only marginal performance degradation*
> ![[stochasticchasm-807215-008.jpg]]
>
> ---
>
> **12.** `17:39:58 UTC` · [status](https://x.com/stochasticchasm/status/2098104207756976410)
>
> FP4 KV cache with no degradation + compressing KVs via CSA, it's no wonder that it barely uses any KV cache. inference engineers are going to have a fun time with this one. i wonder how much kernel reduction order etc will affect perf here. cool that it's just straight up fp4
>
> ---
>
> **13.** `17:41:58 UTC` · [status](https://x.com/stochasticchasm/status/2098104710830202960)
>
> i think this makes sense. for a single request of course you have to use the kv cache in hbm/ram to fulfill the request, but between requests, if it takes up a ton of space, why not just re-prefill those bits. it's a negligible amount of flops at like 500K context anyway
>
> *SWA Bounded Replay introduced: exact reconstruction needs the most recent `L × n_win` tokens replayed, so instead only the last `n_win` are replayed — "a new storage–computation trade-off, allowing us to avoid persisting SWA KV cache to SSD while incurring a small amount of prefill recomputation," bringing the persistent footprint to ~1/8 of V4-Flash*
> ![[stochasticchasm-807215-009.png]]
>
> ---
>
> **14.** `17:46:35 UTC` · [status](https://x.com/stochasticchasm/status/2098105871725474219)
>
> engram finally made it in the model, plus an mHC simplification. both very expected additions. mega-mhc sounds fun, will need to look into that. does this mean they used dspark during pre-training? i guess we'll see the answer later in the paper
>
> *The component-inventory paragraph: Single-Pass mHC with a Mega-mHC deployment kernel that halves activation memory traffic against the original four-kernel implementation, plus Engram conditional memory and DSpark speculative decoding — and Figure 2's result that a 256-fold context extension from 4K to 1M raises Decode FLOPs by only 1/4*
> ![[stochasticchasm-807215-010.png]]
>
> ---
>
> **15.** `17:49:50 UTC` · [status](https://x.com/stochasticchasm/status/2098106688373231886)
>
> whenever a sparse attn version doesn't need a dense attention warmup, feels like a good sign. long-context pretraining here is probably enabled by the lower prefill flops, but this probably enables things like agentic traces much earlier in training as well. midtraining kinda being absorbed
>
> *The pre-training summary, with the load-bearing clause highlighted: 45T multimodal tokens, "sparse attention is trained from scratch at a sequence length of 64K, without any dense attention warmup stages" — plus base-model parity with V4-Pro-Base at 1/3 the total and 1/4 the activated parameters*
> ![[stochasticchasm-807215-011.jpg]]
>
> ---
>
> **16.** `17:52:29 UTC` · [status](https://x.com/stochasticchasm/status/2098107358450999796)
>
> makes sense. they already had a strong recipe + all the batch invariant kernels + low precision inference etc for stable RL, so data is what deserves attention at this stage. no critics yet though i feel like it's only a matter of time until they pull out some value modeling
>
> *The post-training claim of zero algorithmic novelty: SFT → RL → OPD "without any modification beyond well-established practice used in DeepSeek-V4 development," with "all substantive changes lie instead in the data pipeline" highlighted*
> ![[stochasticchasm-807215-012.png]]
>
> ---
>
> **17.** `17:59:13 UTC` · [status](https://x.com/stochasticchasm/status/2098109053268562107)
>
> alright onto the fun part. CED. when i read the initial blog i sort of assumed that the decoder would be able to attend to the KVs of the encoder section at multiple layers, but it doesn't seem that way at all. instead it's just a periodic read of the final encoder states. i guess this makes sense, those would be the richest and this also somewhat follows the original transformer. of course, this isn't cross attention, the self-attention just has prefilled KVs
>
> *Report Figure 3, the overall architecture: 20-layer causal encoder (2 SWA layers, then 3 groups of CSA2(2, Full) + 5× CSA2(2, Reuse)) feeding encoder hidden states across to a 20-layer decoder (CSA2(1, Full) + 3× Reuse, then 4 groups of CSA2(1, Reindex) + 3× Reuse), with the CED arrow, the Hierarchical Sparse Indexer's candidate pool, Engram at the embedding, and DSpark on the output. Same figure as `dsv41flash-003.png` in the primary-source note*
> ![[stochasticchasm-807215-013.jpg]]
>
> *Figure 1 of "Attention Is All You Need" — the original encoder-decoder Transformer, posted to make the point that CED's read of final encoder states "somewhat follows the original transformer"*
> ![[stochasticchasm-807215-014.jpg]]
>
> ---
>
> **18.** `18:02:17 UTC` · [status](https://x.com/stochasticchasm/status/2098109824945021088)
>
> cross attention would be only attending to the KVs of the encoder - which i'm sure they probably tried as one of the ablations, but its interesting that the decoder can attend to the encoder hidden states in context of its own sequence until that point directly. seems like a good choice. this also reminds me of something like MoDA - since it's sort of an allow-KVs-from-earlier-layers type of approach
>
> *Figure 1 of the MoDA paper (mixture-of-depths attention): the per-layer diagram plus a visibility matrix showing queries attending to depth memories — KV pairs at the same query position from preceding layers. The "allow-KVs-from-earlier-layers" lineage he places CED in*
> ![[stochasticchasm-807215-015.jpg]]
>
> ---
>
> **19.** `18:08:30 UTC` · [status](https://x.com/stochasticchasm/status/2098111388690649407)
>
> i wonder why the first two layers are SWA only. two layers out of 20 doesn't seem like it's saving a ton on prefill flops but i guess the less global the cheaper it is. feels like there's a story here, or that it's something like first-k-dense for MoEs
>
> *§2.1's architecture summary with the clause he is asking about highlighted: every layer has both global attention and SWA "except for the first two layers, which use SWA only"*
> ![[stochasticchasm-807215-016.jpg]]
>
> ---
>
> **20.** `18:11:23 UTC` · [status](https://x.com/stochasticchasm/status/2098112112531063137)
>
> gigantic engram size. most scaled up we've seen to date, qwen-3.8-flash-next had 51B n-gram params. granted the model itself is larger here
>
> *The same §2.1 paragraph, now with "196B Engram parameters" highlighted alongside the 552B backbone and the 8B-prefill/16B-decode activation split*
> ![[stochasticchasm-807215-017.jpg]]
>
> *A tight crop of the Qwen-3.8-Flash-Next description he is comparing against — legible fragments read "…t, a sparse mixture-… r token, and additional 51B …ator. On fourteen pre-training…", the evidence for his 51B n-gram-parameter figure. Lowest-quality screenshot in the thread; the number is readable, the surrounding sentence is not*
> ![[stochasticchasm-807215-018.png]]
>
> ---
>
> **21.** `18:16:36 UTC` · [status](https://x.com/stochasticchasm/status/2098113428145733686)
>
> hysparse + indexshare type of thing here. sharing global kv + unique swa seems like a decent tradeoff of getting tiny kv cache but still getting each layer to see new states
>
> *The two-sentence statement of the layer-dimension trade, highlighted: CED lets most prompt tokens bypass full decoder computation "while retaining layer-local sliding-window attention," and "CSA2 shares global KV across layers to reduce cache storage and reuses sparse selections to reduce indexing work"*
> ![[stochasticchasm-807215-019.jpg]]
>
> ---
>
> **22.** `18:23:15 UTC` · [status](https://x.com/stochasticchasm/status/2098115098036609061)
>
> man i mentally read this as "load-bearing"
> modality specific experts have been a thing for a while, with modern models having it sort of emerge during training. so i think a load balancing term that aims to balance both text and image tokens is an interesting development
>
> *The sentence with "load balancing" highlighted — DeepSeekMoE's shared and fine-grained routed experts retained, modality-specific load balancing introduced for image and text tokens, Single-Pass mHC revising residual-stream mixing for kernel fusion, Engram adding sparsely accessed conditional memory, and the MTP module omitted during backbone pre-training in favour of DSpark*
> ![[stochasticchasm-807215-020.jpg]]
>
> ---
>
> **23.** `18:23:56 UTC` · [status](https://x.com/stochasticchasm/status/2098115272481832968)
>
> do you want to let modality specific experts emerge? do you want to disincentivize them for more embedding space overlap between modalities? i'm sure someone has done work on this that i'm just not aware of yet
>
> ---
>
> **24.** `18:26:57 UTC` · [status](https://x.com/stochasticchasm/status/2098116030627455450)
>
> nothing crazy on how multimodal is introduced. just let the backbone handle most of it and give it visual tokens. 3x3 pixel unshuffle is more aggressive than others' 2x2 that we've seen
>
> *§2.1.1 Multimodal Architecture in full: vision encoder → 3×3 pixel-unshuffle rearranging each local neighbourhood along the channel dimension → MLP projector to the backbone's hidden dimension → visual embeddings inserted at image-token positions and processed jointly with text*
> ![[stochasticchasm-807215-021.png]]
>
> ---
>
> **25.** `18:37:11 UTC` · [status](https://x.com/stochasticchasm/status/2098118604768362801)
>
> all very sensible choices here i think. removing convs for muon is an interesting motivation for the choice, given keller's original post did mention that muon works with convs (via flattening). maybe they tried this and didn't see it performing well
>
> *The DeepSeek-ViT paragraph: trained from scratch on ViT with 2D-RoPE for arbitrary resolutions, RMSNorm and SwiGLU, and "we replace the patch embedding layer's convolution with a linear projection to ensure compatibility with the Muon optimizer" — plus 3×3 pixel-unshuffle for 9× fewer visual tokens at up to ~1344×1344*
> ![[stochasticchasm-807215-022.jpg]]
>
> *Keller Jordan's original Muon post, with "conv" highlighted in the sentence that contradicts the stated motivation: "Muon can be used for 4D convolutional parameters by flattening their last three dimensions"*
> ![[stochasticchasm-807215-023.jpg]]
>
> ---
>
> **26.** `18:43:10 UTC` · [status](https://x.com/stochasticchasm/status/2098120110326378516)
>
> i'm not seeing why modality-specific imbalance is necessarily harmful unless it's like really really skewed and you're effectively stuck with a smaller model.
>
> *The multimodal auxiliary-loss-free load balancing paragraph, with the premise he is questioning highlighted: "Balancing their aggregate load may therefore obscure modality-specific imbalance." The mechanism is separate expert-wise correction biases for text and image tokens, each token routed using its own modality's biases while original routing scores still weight the outputs*
> ![[stochasticchasm-807215-024.jpg]]
>
> ---
>
> **27.** `18:46:17 UTC` · [status](https://x.com/stochasticchasm/status/2098120896926085310)
>
> gonna take a brunch break and get back to it
>
> ---
>
> **28.** `20:05:47 UTC` · [status](https://x.com/stochasticchasm/status/2098140902367916481)
>
> alright, CED time. they mention YoCo directly, not sure why i've seen so many comments saying that they didn't acknowledge it
>
> *§2.2 Causal Encoder-Decoder in full — the section that settles the citation question ("inspired by YoCo (Sun et al., 2024)") and gives Equation 1: for layers `l > L/2` the KV entries are projected from `H_{L/2}` with layer-dependent weights, `C_l = H_{L/2} W_l^KV`, `Z_l = H_{L/2} W_l^Z`, so prefill computes only the bottom half*
> ![[stochasticchasm-807215-025.jpg]]
>
> ---
>
> **29.** `20:12:23 UTC` · [status](https://x.com/stochasticchasm/status/2098142564323151935)
>
> i guess it should be YOCO and not YoCo? lol. anyway, going back to YOCO, it's a very simple design. the first half of the model is normal, and then you take the hidden states, project them to K/Vs once more, and then use that identical KV cache for every layer in the second half of the model
>
> *YOCO Figure 2, the mechanism he is describing: an L/2-layer self-decoder with efficient self-attention generates one global KV cache, which an L/2-layer cross-decoder then consumes by cross-attention — one cache, shared across every upper layer*
> ![[stochasticchasm-807215-026.jpg]]
>
> ---
>
> **30.** `20:22:57 UTC` · [status](https://x.com/stochasticchasm/status/2098145224732364973)
>
> in deepseek's CED, it's basically the same thing, applied only to the global branch of the CSA2 layers, and uniquely for each layer.
> so in the decoder every CSA2 layer has a global branch and a local swa branch where the swa branch is computed from current layer hidden states, and the global branch's kv cache is just a linear proj of the encoder hidden states. and they don't do this during prefill, since you can just get the relevant KVs for decode with a quick linear proj
>
> ---
>
> **31.** `20:32:08 UTC` · [status](https://x.com/stochasticchasm/status/2098147535529607541)
>
> i think this classification is a little funny, but a nice way to talk about this, the modes being named is easier than mentioning what they share every time. random part of me wishes the names were more intuitive, like what would you call a mode that re-uses indices but not KV like glm 5.2 here?
>
> *Report Figure 4, the three CSA2 operating modes side by side — Full computes its own main KV, indexer K and Top-K indices (green); Reindex takes main KV and indexer K from a preceding layer (yellow) but rescores with its own indexer Q; Reuse takes both main KV and Top-K indices (red) and just does sparse attention. All three still compute main Q and SWA KV locally. Same figure as `dsv41flash-004.png` in the primary-source note*
> ![[stochasticchasm-807215-027.jpg]]
>
> ---
>
> **32.** `20:36:21 UTC` · [status](https://x.com/stochasticchasm/status/2098148596311036349)
>
> this part is kinda nice. you get perf benefits while still being flexible. it's basically blockwise scoring -> tokenwise scoring with shared block indices and not shared token indices within the blocks. unsure why this was introduced at post-training, probably because of longer sequences if i had to guess, though 64k is decently long at pretrain still
>
> *The Hierarchical Sparse Indexer's training-aware clause, highlighted: "The mechanism is training-aware and introduced in post-training" — the candidate restriction applies identically at training and inference so deeper indexers are optimized under the same search domain they use at inference*
> ![[stochasticchasm-807215-028.png]]
>
> *Report Figure 5, the Hierarchical Sparse Indexer: the decoder's first Full-mode layer scores all causally visible positions, picks its own Top-512, and builds a shared candidate pool from the selected blocks; later Reindex-mode layers score only the candidate positions and pick their own Top-512 within it. Same figure as `dsv41flash-005.png` in the primary-source note*
> ![[stochasticchasm-807215-029.jpg]]
>
> ---
>
> **33.** `20:40:22 UTC` · [status](https://x.com/stochasticchasm/status/2098149605246648793)
>
> very heavy hysparse vibes, just had to mention it again
>
> *The prose behind Figure 5: the Full-mode layer assigns each block the maximum index score among its positions, selects the highest-scoring blocks, and collects their positions into a pool larger than the final Top-K — "selecting 2,048 blocks with 8 positions each yields 16,384 candidate positions." Reindex layers score only the pool; Reuse layers do no new indexing. "The candidate pool is shared across indexing layers, while their final selections can differ"*
> ![[stochasticchasm-807215-030.png]]
>
> ---
>
> **34.** `20:43:01 UTC` · [status](https://x.com/stochasticchasm/status/2098150272015204695)
>
> yeah i guess you can overlap it to make this more efficient. fair enough why not
>
> *Single-Pass mHC, Equation 6: shifting the input-mixing coefficients by one block so "every block consumes the mixing coefficients produced by the previous one" — input mixing uses `A_{l-1}` instead of `A_l`, so each tile of `X_l` can be used immediately for both input mixing and coefficient prediction without waiting for the full reduction*
> ![[stochasticchasm-807215-031.jpg]]
>
> ---
>
> **35.** `20:52:03 UTC` · [status](https://x.com/stochasticchasm/status/2098152546569449860)
>
> some interesting details in the engram section:
> - table sizes chosen to be distinct primes - don't recall this being important before
> - 4-grams are also not something i think we've seen in other models that used these
> - all in fp8? so fp8 lookup tables, i'm guessing this is inference
>
> *§2.4.2's Engram configuration, highlighted: 196B parameters split evenly across two modules, N-gram orders {2,3,4}, 8 hash heads, total embedding dimension 2048 per order — each head indexing ~16M entries "with table sizes chosen to be distinct primes," embedding tables and key/value projections both in FP8, modules placed at layers 1 and 14 to balance memory across pipeline stages*
> ![[stochasticchasm-807215-032.jpg]]
>
> ---
>
> **36.** `20:52:37 UTC` · [status](https://x.com/stochasticchasm/status/2098152686952894767)
>
> they killed MTP which is kinda sad. guess the performance uplift wasn't worth it at the end of the day?
>
> *The DSpark training-schedule paragraph, with the MTP contrast highlighted: unlike V3's MTP module trained jointly with the backbone throughout pre-training, DSpark is introduced in a dedicated post-pre-training stage on a frozen backbone, then trained alongside the backbone during post-training without propagating gradients into it — keeping it aligned with the evolving policy so it accelerates RL and OPD rollout generation as well as online serving*
> ![[stochasticchasm-807215-033.jpg]]
>
> ---
>
> **37.** `20:59:44 UTC` · [status](https://x.com/stochasticchasm/status/2098154481750020375)
>
> ah this explains it. QAT for the kv cache as well. no wonder it performs better than other models at fp4 kv cache
>
> *§2.4.4 FP4 Main KV Cache, with the key move highlighted: V4 already used QAT for FP4 indexer queries and keys; V4.1 extends QAT to the main KV cache, "where FP4 reduces storage rather than accelerates matrix multiplication." Dequantizing before attention allows a more accurate format without native FP4 matmul support*
> ![[stochasticchasm-807215-034.jpg]]
>
> ---
>
> **38.** `21:02:49 UTC` · [status](https://x.com/stochasticchasm/status/2098155257629167828)
>
> i found this breakdown very interesting
>
> *The numerical justification for dropping NVFP4's second-level global scale: E2M1 with one E4M3 scale per 16 channels supports magnitudes to 448 × 6 = 2688, while after RMS normalization the 512-channel KV latent's L2 norm is at most ~√512 ≈ 22.6 (RoPE preserves the norm) and the maximum magnitude observed in training is around 10 — so omitting the global scale costs no measurable accuracy and simplifies the cache layout*
> ![[stochasticchasm-807215-035.jpg]]
>
> ---
>
> **39.** `21:04:54 UTC` · [status](https://x.com/stochasticchasm/status/2098155780088484326)
>
> another head wise muon shift. safe to say it's becoming the default
>
> *Opening of §2.5 Optimization with "head-wise Muon" highlighted — Query weights split by head before the Muon update*
> ![[stochasticchasm-807215-036.png]]
>
> ---
>
> **40.** `21:06:21 UTC` · [status](https://x.com/stochasticchasm/status/2098156146272202859)
>
> ah this is so sick. no adam at all. and also especially relevant with the gigantic engram table
>
> *The optimizer substitution, highlighted: applying Adam to the new Engram parameters would blow up optimizer-state memory, so the Engram embedding tables, token embedding and prediction head are instead optimized by a momentum-based update followed by Sinkhorn balancing — extending SinkGD's linear-layer technique to these large matrices, needing only a momentum buffer, and empirically outperforming Adam*
> ![[stochasticchasm-807215-037.jpg]]
>
> ---
>
> **41.** `21:38:21 UTC` · [status](https://x.com/stochasticchasm/status/2098164196068483488)
>
> nevermind they do still have some adam optimized parameters. but no input/output is super cool
>
> *The Basic Configurations paragraph that corrects him, highlighted: AdamW is retained for normalization-layer weights and other non-matrix parameters including biases and scaling factors; Muon covers backbone linear weights, Engram projections and the vision-language projector, head-wise for Query and Key*
> ![[stochasticchasm-807215-038.jpg]]
>
> ---
>
> **42.** `21:38:40 UTC` · [status](https://x.com/stochasticchasm/status/2098164275999363114)
>
> no wd on lm head
>
> *The weight-decay details, highlighted: normalization-layer weights are subject to weight decay while biases and scaling factors are not, and "the Sinkhorn-balanced update also uses Nesterov momentum but does not apply weight decay" — which, since the prediction head is Sinkhorn-balanced, is the no-weight-decay-on-lm-head point*
> ![[stochasticchasm-807215-039.jpg]]
>
> ---
>
> **43.** `21:41:44 UTC` · [status](https://x.com/stochasticchasm/status/2098165051421335744)
>
> also cool to see the adam-rms-matching for the sinkhorn update too
>
> *The Sinkhorn-balanced update spelled out (Equation 7): same workflow as Muon with Sinkhorn balancing replacing Newton–Schulz orthogonalization, approximately equalizing row-wise and column-wise RMS of the update matrix — rows are token indices or n-gram identities, columns hidden features. The highlighted clause is the Adam-matching he flags: "we adjust the effective learning rate as η̃_t = γη_t to match the update magnitude of Adam," with γ = 0.18, close to Moonlight's 0.2*
> ![[stochasticchasm-807215-040.jpg]]
>
> ---
>
> **44.** `21:42:29 UTC` · [status](https://x.com/stochasticchasm/status/2098165237400953054)
>
> must have missed this earlier, but this is a big difference from k3 on vision encoders
>
> *§3.1.1's contrastive-learning overlap, highlighted: "The vision encoder is first optimized with a contrastive objective before being fine-tuned with a generative next-token prediction loss" — and because text-feature gradients depend only on gathered visual features and vice versa, each all-gather overlaps with the forward or backward pass instead of stalling the pipeline*
> ![[stochasticchasm-807215-041.jpg]]
>
> ---
>
> **45.** `22:14:35 UTC` · [status](https://x.com/stochasticchasm/status/2098173314913141244)
>
> i like this. never had to deal with image processing bottlenecks so far, so this is something i was wondering about for long sequences. for inference as well as training
>
> *Long-Sequence Multimodal Training Optimization: balanced image sharding across CP ranks with each image loaded exactly once, and the loading-hidden-behind-compute criterion `ρ < (B_IO/B_GPU)·C` in which sequence length cancels, so only per-token quantities matter — storage throughput bottlenecks small ablation models, while production-scale models stay compute-bound. Plus incremental image transfer to the inference engine with CPU-side decode/preprocess outputs cached on a distributed filesystem for reuse across rollouts*
> ![[stochasticchasm-807215-042.png]]
>
> ---
>
> **46.** `22:15:19 UTC` · [status](https://x.com/stochasticchasm/status/2098173499835846804)
>
> what a fun name. it's kinda like ac where they just recompute during training
>
> *"Shadow indexers", highlighted: because CSA2's shared parameters may sit on different pipeline stages, a lightweight executable replica is placed on each participating stage while a single logical owner retains responsibility for optimization and checkpointing*
> ![[stochasticchasm-807215-043.jpg]]
>
> ---
>
> **47.** `22:19:48 UTC` · [status](https://x.com/stochasticchasm/status/2098174628070109471)
>
> yeah i guess this is unavoidable since the receptive field kinda is n_win*L but man that's crazy
>
> *The report's candid admission about SWA Bounded Replay, highlighted: replaying the last `n_win` tokens under the same SWA truncation and using the resulting decoder SWA KV only for decoding, "by design, the reconstructed decoder SWA KV is not mathematically equivalent to that from a full decoder forward pass" — with negligible measured impact on response quality, and the same replay simulated during post-training for train-aware adaptation*
> ![[stochasticchasm-807215-044.jpg]]
>
> ---
>
> **48.** `22:26:20 UTC` · [status](https://x.com/stochasticchasm/status/2098176271536779535)
>
> this is kinda vague. i wonder how you get "interactions" between corpora - surely this is just synthetic data
>
> *§4.1 Data Construction, with the vague phrase highlighted: going beyond sample-level quality to "the holistic interactions among diverse corpora that offer unique information gains," a scaling ladder over parameters and data to guide large runs, and model-generated content with limited information gain — weak-model outputs, low-quality machine translation — filtered out as "implicit duplication"*
> ![[stochasticchasm-807215-045.jpg]]
>
> ---
>
> **49.** `22:29:19 UTC` · [status](https://x.com/stochasticchasm/status/2098177024665993563)
>
> wow smolvlm mentioned
>
> *The multimodal data pipeline's final filter, highlighted: after heuristic and statistical filtering, dedup and quality models, and image-aware re-filtering of the interleaved sequences, "we employ SmolVLM (Marafioti et al., 2025) to conduct strict quality scoring on the image-text content"*
> ![[stochasticchasm-807215-046.jpg]]
>
> ---
>
> **50.** `22:32:48 UTC` · [status](https://x.com/stochasticchasm/status/2098177898909925864)
>
> no instabilities, so i guess they solved whatever the issue was during v4 training. that's a good sign for this arch. also very interesting that they continue with WSD, and also extend context length for ~10T tokens. training at 1M tokens for that long is kinda wild
>
> *The full pre-training hyperparameter paragraph, highlighted: 45T multimodal tokens "with no instability", batch size fixed at 100.6M tokens, LR warmed up over 2000 steps then held at 2.6e-4 to 28T tokens, cosine-decayed to 2.6e-5 between 28T and 40T and held there to 45T, trained from scratch with sparse attention at 64K and extended to 1M at 34T tokens — the ~10T-token 1M-context tail he calls wild*
> ![[stochasticchasm-807215-047.jpg]]
>
> ---
>
> **51.** `22:38:41 UTC` · [status](https://x.com/stochasticchasm/status/2098179380195516918)
>
> this gives us a second datapoint on top of MAI-thinking-1 as to how models are continuing RL beyond collapse. though this is absurd, merging checkpoints across different scaffolds? harnesses presumably?
>
> *The checkpoint-merging paragraph, highlighted: "To extend effective RL compute beyond a single training run, we use model merging to reinitialize successive RL runs" — merging checkpoints from runs across different scaffolds or configurations to combine improvements from different optimization paths, visible as the disconnected curve segments in Figures 7 and 8, yielding gains in both task performance and token efficiency*
> ![[stochasticchasm-807215-048.jpg]]
>
> ---
>
> **52.** `22:40:08 UTC` · [status](https://x.com/stochasticchasm/status/2098179747973107855)
>
> jesus. i think k3 mentioned ~50M sandboxes over the full run, but millions of *concurrent* sandboxes is a lot
>
> *The DSec motivation paragraph, with the scale claim highlighted: the platform's initial design covered heterogeneous execution environments, scalable image distribution, multiple isolation backends, high-density resource management, trajectory logging and preemption-safe resumption — and "V4.1 training further increased demand to millions of concurrent sandbox instances"*
> ![[stochasticchasm-807215-049.jpg]]
>
> ---
>
> **53.** `22:41:42 UTC` · [status](https://x.com/stochasticchasm/status/2098180139159060494)
>
> yep, here's the corresponding section of the k3 report
>
> *The comparison passage from the **Kimi K3** tech report (not DeepSeek's), fact-checking his own recollection: a custom ublk driver, storage-layer sharing and P2P transport for sub-second launch, copy-on-write memory and page-cache optimizations for up to 6.5× memory overcommit — and the number he was reaching for, "throughout Kimi K3's training and evaluation, a total of 51,219,741 sandboxes across 1,505,678 images were created." Cumulative, against DeepSeek's concurrent*
> ![[stochasticchasm-807215-050.png]]
>
> ---
>
> **54.** `22:56:28 UTC` · [status](https://x.com/stochasticchasm/status/2098183858755919901)
>
> love reading novel reasoning effort control schemes. this seems similar to openai's juice value, which imo is nice because you can get much more fine-grained control. really interesting setup with grpo here too, in that each group is sampled at one effort level, and each task at multiple effort levels. the reference length "L_norm" seems to be similar to k3's calibrated per-problem reference length, though they don't say how they get this reference length at all
>
> *§5.1.4 Controllable Reasoning Effort in RL, complete with equations 8-10: the `Reasoning Effort: {effort} (range 1-100…)` system-prompt line, `M_b` responses sampled per effort level, responses sharing `(x, b)` forming a subgroup within which rewards are mean-centered so effort levels are never compared against each other, and the length penalty `r_len = -min{C_max, k(b)·ℓ/L_norm}` whose coefficient decays exponentially as `k(b) = k_0·exp(-(b - b_min)/τ)` — the `L_norm` whose construction he notes is never explained*
> ![[stochasticchasm-807215-051.jpg]]
>
> ---
>
> **55.** `23:00:03 UTC` · [status](https://x.com/stochasticchasm/status/2098184756563431718)
>
> i assumed they were already doing this. i guess batch invariant + sync explains the batch invariant focus in v4. imagine how much more throughput they got now
>
> *§5.2 Asynchronous Post-training Infrastructure, with "asynchronous generation of samples" highlighted — extended to mitigate the RL rollout phase's long-tail problem by holding concurrency high; asynchronous training is now enabled for nearly all RL and OPD tasks*
> ![[stochasticchasm-807215-052.jpg]]
>
> ---
>
> **56.** `23:03:53 UTC` · [status](https://x.com/stochasticchasm/status/2098185722561966230)
>
> i guess this makes sense. but also really funny to see colocated async RL becoming more popular with k3 doing the same thing
>
> *§5.2.1 Overall Workflow, highlighted: "We colocate rollout and training on the same physical devices and time-share their execution, eliminating the need to manually tune resource allocation between the two phases," with each task specifying an upper bound on in-flight samples*
> ![[stochasticchasm-807215-053.jpg]]
>
> *The matching passage from the **Kimi K3** report he pairs it with: co-located RL training to keep each 1M-context experiment within a few hundred GPUs, plus partial rollouts to cut tail latency from ultra-long trajectories — with the caveat that long-context rollouts add DRAM demand for KV-cache retention that competes with training-side state*
> ![[stochasticchasm-807215-054.jpg]]
>
> ---
>
> **57.** `23:07:49 UTC` · [status](https://x.com/stochasticchasm/status/2098186711578943775)
>
> to end it off, i think the multi agent eval is really interesting. there's a ton of forms a multi agent harness could look like, and the optimal one is still very much undecided. training for it seems straightforwardly beneficial though and can scale better than single agent. great to see it.
>
> *Report Figure 10, the closing exhibit: multi-agent versus single-agent test-time compute scaling against per-rollout wall-clock deadline — ProgramBench Almost@1 reaching 30.04% multi-agent against 20.39% single-agent at 8h, FrontierSWE v2 Mean@5 reaching 32.90% against 28.20% at 20h. Same figure as `dsv41flash-010.png` in the primary-source note*
> ![[stochasticchasm-807215-055.jpg]]

Original thread: <https://x.com/stochasticchasm/status/2098098053781807215>
