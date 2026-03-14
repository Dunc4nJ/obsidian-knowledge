---
created: 2026-03-12
description: PagedAttention borrows OS virtual memory paging to manage LLM KV caches in small non-contiguous blocks, eliminating fragmentation and enabling shared prefixes that yield 2-4x throughput gains
source: https://x.com/_avichawla/status/2031624056072712547
type: learning
---

## Key Takeaways

The core insight is that LLM inference bottlenecks are not about raw GPU compute but about how KV cache memory is allocated. Traditional systems pre-allocate large contiguous blocks per request assuming worst-case sequence length, then waste 70-80% of that reservation when actual outputs are shorter. This is the same fragmentation problem that OS designers solved decades ago with virtual memory paging, and [[prompt design is the single biggest lever for synthetic pretraining data|synthetic data pipelines that serve many requests]] face exactly this throughput ceiling when running inference at scale.

PagedAttention breaks the KV cache into small fixed-size blocks (typically 16 tokens each) scattered anywhere in GPU memory, tracked via a block table that maps logical positions to physical locations. This is a direct analog of OS page tables. The killer feature is shared prefixes: when hundreds of requests share the same system prompt, their block tables point to the same physical blocks instead of duplicating them. Only divergent tokens get new allocations. This connects to [[agent harness is the real product|context engineering for agents]] where vLLM prefix caching is used to avoid recomputing shared context across agentic tool-call loops.

The throughput gains are substantial: the original paper measured 2-4x improvement over existing systems at the same latency. vLLM, built around PagedAttention, has become the default production inference engine alongside TensorRT-LLM and SGLang which adopted similar paging mechanisms. A notable caveat from the thread discussion: paged attention adds roughly 20-26% overhead per attention kernel call due to non-contiguous memory reads, but the system-level gain from fitting far more concurrent requests dwarfs that per-kernel cost.

## External Resources

- [vLLM](https://github.com/vllm-project/vllm) — Production inference engine implementing PagedAttention as its core algorithm
- [LLMOps Crash Course](https://www.dailydoseofds.com/llmops-crash-course-part-1/) — Practical course on deploying LLM systems referenced in the thread

## Original Content

> @_avichawla (Avi Chawla) — 2026-03-11
>
> Paged Attention in LLMs, clearly explained!
>
> When you're serving LLMs at scale, memory becomes your bottleneck before compute does.
>
> The problem isn't a lack of GPU memory; it's how inefficiently we use it.
>
> Let's understand why this happens and how Paged Attention solves it elegantly!
>
> **KV Cache**
>
> During LLM inference, the model stores the key and value vectors of all previously generated tokens in memory. This is the KV cache.
>
> Simply put, instead of recomputing attention over all previous tokens every time a new token is generated, the model just looks up the cached values and computes attention with them.
>
> This is crucial for efficiency. Without it, generating a 1000-token response would require recomputing attention for all previous tokens at each step. That's O(n^2) operations instead of O(n) and the speed difference is evident below:
>
> *KV cache speed comparison: with vs without caching*
> ![[avichawla-712547-001.jpg]]
>
> But there's a problem.
>
> **The memory inefficiency problem**
>
> Traditional KV cache implementations pre-allocate large, contiguous memory blocks for each request.
>
> Here's why this is wasteful:
>
> Imagine serving 100 concurrent users. You don't know how long each response will be, so you pre-allocate space for the maximum possible length, say, 2048 tokens per request. But the average response turns out to be only 200 tokens.
>
> You've just reserved 10x the memory you actually need.
>
> And it gets worse. Each request gets its own isolated block. So even if 80 of those 100 users share the same system prompt, you're storing 80 duplicate copies of the same KV cache entries. None of that memory can be shared or reclaimed.
>
> *Memory fragmentation in traditional KV cache allocation*
> ![[avichawla-712547-002.jpg]]
>
> As a result, you're often using only 20-30% of your allocated GPU memory effectively. The rest is reserved but unused, and because it's scattered across fragmented contiguous blocks, you can't even fit new requests into the gaps.
>
> This is the core inefficiency that kills throughput.
>
> **Paged Attention**
>
> Paged Attention solves this by borrowing the concept of virtual paging memory from operating systems.
>
> If you've studied OS fundamentals, you know that programs don't get one big contiguous chunk of RAM. Instead, the OS breaks memory into small, fixed-size pages, scatters them anywhere in physical memory, and uses a page table to map each program's virtual addresses to physical locations.
>
> Paged Attention does the same thing for the KV cache. Here's how:
>
> *How PagedAttention maps logical blocks to physical GPU memory*
> ![[avichawla-712547-003.jpg]]
>
> Block-level allocation: Instead of reserving one large contiguous block per request, the KV cache is divided into small, fixed-size blocks (typically 16 tokens each). These blocks can live anywhere in GPU memory and don't necessarily need to be next to each other.
>
> *Block table mapping from logical to physical blocks*
> ![[avichawla-712547-004.jpg]]
>
> Block table (page table): Each request maintains a block table which is a simple mapping from logical block index to physical block location in GPU memory. When the model needs the KV cache for token 33, it looks up which physical block holds it, fetches it, and computes attention. The LLM doesn't care where the block is physically sitting.
>
> Shared prefixes: Here's where it gets really clever. Multiple requests that share the same system prompt don't need separate copies of the KV cache for that shared prefix. Their block tables simply point to the same physical blocks. Only when their responses diverge do new blocks get allocated for each request individually.
>
> *Shared prefix blocks across multiple requests*
> ![[avichawla-712547-005.jpg]]
>
> In a production setting, where every request typically shares a system prompt, the memory savings via shared prefix become massive.
>
> **Impact**
>
> In the original Paged Attention paper, the authors measured that existing systems only utilized 20-38% of the allocated KV cache memory effectively. The rest was wasted due to fragmentation and over-reservation.
>
> Paged Attention can achieve:
>
> - 2-4x higher throughput compared to state-of-the-art systems at the same level of latency
> - Near-zero memory waste, as it only allocates memory for what's actually used
> - Better batching leads to more concurrent requests on the same GPU hardware
>
> *Throughput comparison: PagedAttention vs traditional systems*
> ![[avichawla-712547-006.jpg]]
>
> This is why vLLM, which implements Paged Attention as its core algorithm, has become the go-to inference engine for production deployments. Other frameworks like TensorRT-LLM and SGLang have also adopted similar paging mechanisms for faster inference.
>
> This optimization becomes even more crucial when running inference servers at scale, especially with variable request patterns, shared prompts, and cost-per-request constraints.
>
> Over to you: What other OS concepts do you think could be applied to optimize LLM inference?
>
> [Original post](https://x.com/_avichawla/status/2031624056072712547)

**Notable replies:**

> @akshay_pachaar — Good writeup. Here's an interesting fact about paged attention: It isn't free at the kernel level. As expected, the non-contiguous memory reads add roughly 20-26% overhead per attention kernel call. But the system-wide gain (2-4x throughput) overshadows that because you can now fit way more requests in the same GPU memory.

> @gurtej__gill_ — PagedAttention is the vLLM secret sauce. Virtual memory for KV caches is how we hit 10x throughput without adding a single A100. Genius!!!

> @theLewisLu — "Paged Attention" is one of those unsexy tricks that actually makes LLMs usable: managing KV cache like virtual memory so long-context doesn't instantly torch GPU VRAM.

> @CodeForGhost — Is the ollama using this method? If not how we can do this for ollama?

> @rroeserr — Scatter/gather on expensive memory is going to get replaced at some point.

> @aginaut — Better models are nice. Better memory economics print margins.
