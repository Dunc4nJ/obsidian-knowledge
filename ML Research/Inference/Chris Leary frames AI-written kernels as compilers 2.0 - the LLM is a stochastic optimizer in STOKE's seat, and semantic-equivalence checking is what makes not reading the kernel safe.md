---
created: 2026-09-07
description: Chris Leary (started XLA, 2+ years on OpenAI's hardware team) answers the question the HotChips Jalapeno MLA talk left open - how can AI write a kernel nobody reads line by line? His frame is "compilers 2.0": an LLM is a stochastic optimizer, the smart-but-slow replacement for the dumb-but-fast random tweaking in STOKE (Stochastic Superoptimization, ASPLOS 2013), and it slots into the position XLA's hand-written lowering emitter used to hold. Classical optimizing compilers are local dataflow transforms run to fixed point with phase-ordered pipelines (the scheduler / register-allocator composite being the notorious casualty); an LLM is not constrained that way, which puts kernel work in the program-synthesis regime rather than the optimizing-compiler one. The load-bearing claim is soundness: what licenses not reading the kernel is a semantic-equivalence check against the numpy specification, which Leary asserts is possible and in use but defers to a future post. The one demonstrated result is the HotChips slide - DeepSeek MLA from 0.31% to 88.94% of roofline in ~41 hours, GPT-OSS blocks 1.5-1.8x over expert-written implementations. Captured with all three figures and the author's follow-up replies.
source: https://x.com/cdleary/status/2094878051238887834
author: Chris Leary
type: framework
tags: [gpu-kernels, compilers, superoptimization, program-synthesis, formal-verification, equivalence-checking, openai, xla, mla, stoke, hotchips, roofline, ai-generated-code, inference]
---

## Key Takeaways

- **The reframe is precise, and it is the whole value of the piece: an LLM is a stochastic optimizer, occupying the exact seat STOKE gave to random mutation.** Leary's chain runs superoptimization (what is the most optimal program with these semantics?) is a search problem, enumerating programs in objective order is intractable, so STOKE proposed a random walk over program edits with Markov Chain Monte Carlo / Metropolis-Hastings, and then the swap: "Monte Carlo tweaking is typically dumb (you randomly pick a tweak), but also fast. LLMs are very smart (many reasoning tokens), but comparatively slow. What if, instead of the dumb/fast Monte Carlo tweaking, we had LLMs figure out the directions in which to take the programs?" He is explicit about the price paid: "unlike in the STOKE paper, we cannot guarantee that as time goes to infinity we can see the optimal program" — you trade an asymptotic guarantee for "significant human-like traction per unit time." That is the same trade the vault's search-over-programs cluster keeps making empirically: [[autokernel applies the autoresearch loop to GPU kernel optimization reaching 187 TFLOPS from 18 autonomously|autokernel's edit-benchmark-keep/revert loop over Triton replacements]] is this walk with a one-line acceptance rule, [[CORAL multi-agent co-evolution beats OpenEvolve by 20% on Anthropic's kernel engineering task|CORAL's co-evolutionary population]] is it with a proper variation operator, and [[CEDAR runs LLM-driven MCTS with a Judge as fitness function and an Editor as variation operator to design complex systems from natural-language goals|CEDAR's MCTS with an Editor as variation operator and a Judge as fitness function]] is the cleanest statement anywhere in the vault that the LLM's job in these systems is *proposal*, not evaluation. [[Sara puts an LLM agent at the center of the Bayesian optimization loop - agentic BO keeps the probabilistic surrogate while letting the agent reconfigure the search mid-run|Sara does the same substitution inside Bayesian optimization]] — keep the classical loop, replace the proposal distribution with a model. Leary's contribution is naming the seat rather than the system.

- **The argument for why an LLM can beat the compiler is a specific, checkable claim about how compilers are built — not a claim about intelligence.** "In technical jargon, they are based on the idea of a local dataflow transform that is run to fixed point. We also phase order the considerations; i.e. we build compiler pipelines to consider A and then B, but not the composite AB problem. Schedulers and register allocators are a notorious example of this, many PhDs have been attempted on the composite scheduler-register-allocator... but they have been challenging to make work in practice." Everything "optimizin' Ollie" does that the compiler cannot — outlining, custom ABIs, transforms that enable vectorization, balancing several NP-complete problems with bespoke heuristics — is a move outside that local-transform-to-fixed-point box. The consequence Leary draws is the sharp one: this is **program synthesis**, not optimizing compilation. "Classic optimizing compilers won't see 'oh, you wrote a bubble sort' and, by understanding the contract, switch it to a quick-sort, but both Ollie and the AI are able to do that." The vault's nearest structural sibling is [[Bridgewater's PAT treats agentic codegen as a compiler problem, turning 50 years of written-down investment logic into a deterministic AI analyst with a benchmark-gated Teach loop|Bridgewater's PAT]], which runs the same metaphor in the opposite direction — natural-language plan as source, deterministic Python as the compiled artifact — and [[every representation is an IR - the append-only semantic ledger is memory and vectors, graphs, and context windows are views compiled from it|the append-only ledger note's "every representation is an IR"]] generalizes the intermediate-representation move past compilers entirely.

- **The soundness argument is the load-bearing part of the essay, and it is asserted rather than shown.** Leary states the question correctly — "how we check that the program we get out of the AI is indeed equivalent to the higher level description / numpy. That checking mechanism establishes the soundness of the AI stochastic optimization process" — then defers: "I expect a future blog post may go into more detail on this, but for now, suffice it to say that testing for semantic equivalence is possible and we do it." Note the word *testing*. The HotChips slide, which is the only evidence in the piece, shows "functional kernel / **executable tests**" going in and "optimized kernel **validated e2e on chip**" coming out — that is differential testing against a reference, not an equivalence proof, and its coverage is exactly the coverage of the test suite. The strongest reply in the thread makes the point better than the article does (@TonyJZhou): "a stochastic optimizer is only safe if the equivalence checker is sound, and then the checker becomes the compiler. humans reading kernels line by line was never the point; the guarantee was." That is [[Phoebe Yao argues verifier engineering is the moat in RL post-training because verifiability bounds learnability|verifier engineering as the binding constraint]] restated for compilation, and it is why [[AI generated code repos gain credibility by shipping verification artifacts not hiding authorship|shipping the verification artifacts — tests, fuzzing, conformance harnesses, proofs — is what buys the credibility]], not the disclosure of authorship. The clean contrast case already in this folder is [[Step 03 - Speculative decoding core (guess-then-verify, why it's lossless)|speculative decoding's guess-then-verify]]: propose-and-check is provably lossless there precisely because the verifier is exact and cheap. Kernel equivalence has neither property yet, which is the gap Leary is promising to close later. [[prover-verifier games train legible chain-of-thought by iteratively pitting adversarial provers against small verifiers|Prover-verifier games]] and [[self-play theorem provers double proof rates by generating their own conjectures|self-play theorem provers]] are the vault's two treatments of what a real checker looks like when you build one on purpose.

- **The one measured result is the slide, and it is genuinely strong: 0.31% to 88.94% of roofline in about 41 hours, with 1.5-1.8x on already-expert-written GPT-OSS blocks.** The trajectory is legible — FP8 attention matmuls (31.69%), attention rescaling with tiled lookahead (59.24%), value-matmul scheduling (77.14%), key-tile prefetch plus coalesced scale access (88.94%) — and every one of those is a move a strong human kernel engineer would also make, which is the point: the AI is not doing something alien, it is doing the tedious combinatorics of *which ones, in what order, at what tile size*. Leary's framing of the residual is the honest one: "there is a decent achievable percentage still left just due to the many varieties of combinations / permutations that may need to be explored. These are often intractably tedious for a human performance engineer." That number sits well beside [[agentic kernel development ships to production by profiling the whole model first - 42.3 percent latency cut on Qwen-Image|the 42.3% Qwen-Image latency cut that came from restructuring the execution graph before touching any kernel]] — and beside its honest asymmetry, where mature LLM kernels yielded only ~5.5%. Read the axis carefully, in the spirit of [[Perplexity serves embeddings by treating them as a CPU-overhead problem - whole-model CUDA graphs and LazyTensors cut p50 from 4.60ms to 1.53ms while throughput stays at parity with vLLM|reading the charts rather than the framing]]: 0.31% is a *functional-only* baseline, i.e. correct-but-unoptimized numpy-shaped code, not a tuned starting point, so the headline multiple is not a like-for-like comparison against a human expert. The 1.5-1.8x over existing expert implementations is. Roofline as the denominator is defined in [[Modal's GPU Glossary is a browsable reference that maps the GPU stack from device hardware through the CUDA software layers to performance concepts in ~80 linked terms|Modal's glossary]] and derived for decode in [[Step 01 - Decode is memory-bandwidth-bound (the roofline)|the first-principles course]]; MLA itself, the kernel in question, is traced in [[From GPT-2 to Kimi K3 - a visual worklog on how attention architecture evolved to fix the KV cache with linear attention, DeltaNet, gating, and hybrid retrieval|the attention-architecture worklog]].

- **The scope limit is real, Leary concedes it in the replies, and it is the sentence to carry forward: this works because accelerator kernels are the easy case.** "Accelerator programs are particularly amenable to strong, complete contracts that we can verify 'are exactly what the AI optimized program does', as they are quite mathematical and data flow oriented in their broad context... The contracts avoid the need to understand what the kernel does line by line." @filpizlo pushed exactly here — "you can't extrapolate much from optimizing a kernel to optimizing general purpose programs" — and Leary agreed in substance, downgrading the claim to "stuff is trending this way, here's an example" rather than "the world is entirely changed overnight," and noting he "still spend[s] my days on the symbolic part of compilation tech." So the transferable rule is not *stop reading AI code*; it is *you may stop reading AI code exactly as far as your contract reaches*, which is the same boundary [[domain-specific agents beat general-purpose ones by owning verification in boring industries|domain-specific agents win on by owning verification]] and the same one [[tight constraints make autonomous agents more useful than open-ended freedom|tight constraints make autonomous agents useful within]]. [[CUDA game kernels beat JAX RL environments 7x because PyTorch dispatch overhead dominates tiny networks not simulation|The CUDA RL-environment rewrite]] is the shape of problem this generalizes to — narrow, hot, and cheaply checkable against a reference — and @FabioRiccardi33's reply names the practical constraint the slide quietly encodes, that you need the real hardware target to measure against, which is also the co-design premise of [[NVIDIA's hardware-friendly LLM design guide - near-square tile-aligned dimensions, width over depth, NVFP4, and wide expert parallelism|NVIDIA's guide]].

- **What is argued versus what is demonstrated, stated plainly — because the piece is a practitioner essay, not a paper.** *Demonstrated:* one slide, one kernel family, one internal system, no ablations, no equivalence-checker description, no failure rate, no cost. *Argued:* the STOKE lineage, the program-synthesis framing, the phase-ordering critique, and the "assembly layer is moving up" analogy ("When you type in normal C++ and compile it at -O3 you don't expect to understand the assembly that comes out"). The analogy is the part most worth resisting: `-O3` is trusted because the transformation rules are individually justified and the compiler is used by millions, not because nobody reads the output — an unexamined stochastic proposal inherits none of that. The vault's standing warning applies directly: [[automating AI skill improvement fails without manual comprehension of outputs|automating improvement without manually reading outputs optimizes against the wrong criteria]], and [[autoresearch agents exploit unconstrained metrics and need multi-objective gates with regular human steering|autoresearch agents exploit any unconstrained metric they are given]] — "make this kernel faster" is precisely such a metric unless the equivalence check is airtight, which is why [[invariance-based stress tests detect proxy gaming by separating exploitable sensitivity from genuine improvement|invariance-based stress testing]] is the right posture toward a speedup you did not read. The most useful extension in the thread comes from @jhh1992, who reports running the same pattern one level up in serving with AMMO — GSM8K accuracy as the contract, end-to-end request latency as the objective — which is the honest generalization: the pattern travels as far as you can write a contract, and no further. For the hand-written craft this is automating, the folder has [[Ahmad Osman's kernel curriculum - you don't run a model you run kernels, and here are eight mini-projects from RMSNorm in Triton to a custom op profiled inside vLLM|Osman's eight-step curriculum]] and [[MLC's Modern GPU Programming for MLSys is a Blackwell-era book that builds from the GPU execution model through TMA, tensor cores, and TMEM to a SOTA GEMM and Flash Attention 4 in the TIRx Python DSL|MLC's Blackwell-era book]].

## External Resources

- Source: [Compilers 2.0: AI as stochastic optimizer](https://x.com/cdleary/status/2094878051238887834) — Chris Leary (@cdleary), X Article, 1 Sep 2026 (1,095 likes / 119 RTs / 35 replies)
- [STOKE: Stochastic Superoptimization](https://theory.stanford.edu/~aiken/publications/papers/asplos13.pdf) — Schkufza, Sharma & Aiken, ASPLOS 2013; the MCMC/Metropolis-Hastings random walk over program edits that Leary's LLM replaces
- [Full-employment theorem](https://en.wikipedia.org/wiki/Full-employment_theorem) — Wikipedia; the "no perfect optimizing compiler exists" result Leary opens the optimality section with
- [MLGO](https://llvm.org/docs/MLGO.html) — LLVM's machine-learning-guided optimization framework, cited by Leary in-thread as the existing effort to "eat the heuristics because they are well contained"
- [AMMO](https://amazon-science.github.io/ammo/blog/) · [amazon-science/ammo](https://github.com/amazon-science/ammo) — @jhh1992's reply: the same assert-equivalence-then-hill-climb pattern applied to vLLM serving, with GSM8K accuracy as the contract and E2E latency as the objective
- [Language as Software](https://plugyawn.com/language-as-software/) — @plugyawn's reply, prompting Leary's aside on "when do we start sending programs to one another in english"
- [Superoptimization: organizational management by agents](https://www.generalintelligencecompany.com/writing/superoptimization-organizational-management-by-agents) — @ndrewpignanelli's reply, the same superoptimization frame applied outside compilers

## Original Content

> [!quote]- The full article, all three figures, and the author's follow-up replies (Chris Leary, @cdleary, 1 Sep 2026 · 1,095 likes / 119 RTs / 35 replies)
>
> **Article: Compilers 2.0: AI as stochastic optimizer**
>
> There has been a lot of discussion following the presentation of the Jalapeño MLA kernel at HotChips and subsequent commentary by SemiAnalysis. As OpenAI’s hardware team, we just barely touched on this little gold nugget: the fact that AI is writing our kernels, and that, when it does, we don’t really need to understand what the kernel does line by line. We glaringly left out: how is such a thing possible? What is the right way to think about this, versus a more traditional method of code generation? Is the optimized kernel as sound as the unoptimized one?
>
> For my background, I’ve worked on compilers for accelerators for well over a decade. I started XLA, which is an excellent compiler infrastructure with a stellar cross-company team and effort working on it. For the past 2+ years at OpenAI I’ve been trying to reconceptualize how compilers should work in the age of AI. New compiler formulations will draw on existing strengths, but it is impossible to deny that there is a powerful new tool to leverage in the toolkit.
>
> This will be a bit of a journey, but I hope to illuminate how AI is being used for the automation of computer program improvement; i.e. optimizing compilation. I do think, by way of AI, we may experience something we think of as “compilers 2.0”. AI is less fundamentally constrained in what it can propose, and what it proposes is a result of the model’s training and context, this leads me to classify it as a “stochastic optimizer” – this can pose challenges but, as we will see, is also a source of great strengths…
>
> A great deal of academic research and industry application is already headed in this direction, and rapidly uncovering the potential for AI’s involvement in the optimizing compiler realm, but we are at a point where it warrants a broad strokes explanation.
>
> ## Background
>
> Compilers take in programs and spit out translated or improved versions of those programs.
>
> Programs, on both the input and output side, have semantics that tell us what the programs mean, what they could possibly do, and how to reason about those things it could do.
>
> Those of us who work on compilers think of them much like pure functions – they take in a data structure and spit out a data structure that should have corresponding semantics.
>
> Sometimes our compilers focus on “lowering” or “translating”. For example, they may take in C and spit out x86-64 assembly, which we would often consider to be “lower level”. But often they are doing more than just translation as a sub-portion of that process…
>
> Our compilers, in practice, focus on “optimizing”. They may take in a data structure that represents the program – in our parlance an “Intermediate Representation” (IR) – and they try to produce a better version of that program. Sometimes “better” means it takes fewer cycles to run, sometimes it means it’ll have less unnecessary code, sometimes it means specializing for things that we can prove “must be true” about the program (partial evaluation).
>
> Now, briefly, consider that LLMs were originally created to translate human text from one language to another. Clearly translation is in their wheelhouse. And we can see through our use of LLMs on day to day tasks that they can also write new solutions and improve existing solutions. Many of us coders also have experience asking an LLM “optimize this snippet of code” and they remarkably can. (However, we need to know that they optimized the code correctly, which we will get to!) This is simply to highlight that LLMs have the capabilities that we look for in an optimizing compiler.
>
> ## Optimization and Optimality
>
> Optimizing compilers are, unsurprisingly, trying to increase optimality of the program they’re working on, by some objective (usually execution time). That is so difficult to do in the general case, for an arbitrary program, that there is a theorem called the [full employment theorem for compiler engineers](https://en.wikipedia.org/wiki/Full-employment_theorem). (I only found this out after I chose to be a compiler engineer, but it still brought me comfort!)
>
> “Superoptimizers” are an amazing little sub-field of optimizing compilers. Imagine there is a given program, and we can say what it does via semantics. What is the most optimal program that has those same semantics? That’s what superoptimizers attempt to tackle, and it’s effectively a search problem…
>
> Imagine I’m trying to find the shortest program that had those same semantics, and I had a way to ask if a candidate program had the same semantics. I could, hypothetically, enumerate every program in objective order, and pick the smallest one that had the same semantics.
>
> However, enumerating every program in objective order sounds pretty intractable. One of my favorite academic papers, made in 2013 titled “[STOKE](https://theory.stanford.edu/~aiken/publications/papers/asplos13.pdf)” (Stochastic Superoptimization), asked: “well, what if we just randomly tweak programs over and over, do we then eventually observe the best program?” They proposed that via a random walk (and with our OG machine learning friend Markov Chain Monte Carlo / Metropolis-Hastings), eventually you’d see that optimal program.
>
> Monte Carlo tweaking is typically dumb (you randomly pick a tweak), but also fast. LLMs are very smart (many reasoning tokens), but comparatively slow.
>
> What if, instead of the dumb/fast Monte Carlo tweaking, we had LLMs figure out the directions in which to take the programs? We’d have a stochastic optimizer that was very intelligent, walking our program through the optimized program space.
>
> ## Intuitions for Optimization
>
> Let’s take a step back. Consider the person you know that best personifies “optimizes the heck out of snippets of code”. For short let’s call them “optimizin’ Ollie”. Ollie probably has a gut intuition for what kinds of code tweaks could bear fruit. Ollie probably tries some things to see if they work, and if they don’t work out, rolls it back and tries something else. But they have some intuition for what kinds of things are possible, and how they might be able to beat the compiler.
>
> These intuitions that Ollie has are often beyond what compilers do. Although modern optimizing compilers are quite impressive in their results, they are based on fairly simple rules and heuristics. In technical jargon, they are based on the idea of a local dataflow transform that is run to fixed point. We also phase order the considerations; i.e. we build compiler pipelines to consider A and then B, but not the composite AB problem. Schedulers and register allocators are a notorious example of this, many PhDs have been attempted on the composite scheduler-register-allocator (to get the benefits of collapsing the phase ordering), but they have been challenging to make work in practice.
>
> This is why Ollie’s expertise is valuable. Often Ollie knows how to balance several NP-complete problems with heuristics that are bespoke to the situation. So there is more bespoke context awareness and sensitivity. Ollie is also able to employ techniques that optimizing compilers may not apply profitably, especially in combination, things like outlining or crafting custom ABIs or transforms to enable vectorization, or the other slew of things that make us grumble “I wish the compiler had a way to just do this…”
>
> Now consider that AI, through whatever reasoning facilities it has, may be able to act as a mini Ollie. It may not have the matched intuition in terms of what will come to fruition, but it has an inkling of what can be profitable, and it can take many, many shots on goal.
>
> With this approach, unlike in the STOKE paper, we cannot guarantee that as time goes to infinity we can see the optimal program, but because the AI has “more human like” reasoning facilities, it can actually get significant human-like traction per unit time.
>
> ## Tying it Back: MLA Kernel
>
> Let me start by saying: I don’t know what low level code the AI spat out for our Jalapeño MLA kernel, but I do know how to type in the numpy for MLA.
>
> In the XLA compiler I previously worked on, we would fuse those numpy operations together into clumps, and then use a metaprogram called an “emitter” to lower it down to loops, instructions, and lower-level primitives.
>
> *XLA's classic path: an MLA fusion node of dot / add / multiply / select ops, lowered by a hand-written "lowering emitter" meta-program into loops and instructions in a control flow graph.*
>
> ![[cdleary-887834-001.jpg]]
>
> When the XLA compiler / emitter program did that, I didn’t need to care what assembly came out the back. For our stochastic optimizer, AI conceptually takes the place of the emitter meta-program – it both lowers down and optimizes, and we can ask it to optimize further and further towards roofline.
>
> *The same diagram with the emitter swapped out: the "AI stochastic emitter/optimizer" occupies the meta-program's slot, both lowering and optimizing toward the same control flow graph.*
>
> ![[cdleary-887834-002.jpg]]
>
> I hope this makes it clear where the AI slots in and how it is analogous to a component in an existing optimizing compiler system. It’s also helpful to think: what layer we consider to be “assembly code” is now moving up. When you type in normal C++ and compile it at -O3 (the highest typical optimization level) you don’t expect to understand the assembly that comes out, even if you understood the C++ you had typed in. We’re doing the analogous thing here, but with a higher-level and more mathematical input specification.
>
> Now, a key question is how we check that the program we get out of the AI is indeed equivalent to the higher level description / numpy. That checking mechanism establishes the soundness of the AI stochastic optimization process. I expect a future blog post may go into more detail on this, but for now, suffice it to say that testing for semantic equivalence is possible and we do it. Accelerator programs are particularly amenable to strong, complete contracts that we can verify “are exactly what the AI optimized program does”, as they are quite mathematical and data flow oriented in their broad context.
>
> Note that many relevant techniques in this area were pioneered by efforts in the sub-field of program synthesis. Whereas optimizing compilers say, “here is a program with semantics, make it better but with equivalent semantics!”, program synthesis says, “I believe there exists a program with these semantics, please try to find the best one you can”. Program synthesis is a harder problem than optimizing compilation, but it is also less fundamentally constrained. It is effectively what humans like Ollie do when they do better than the optimizing compiler, and it is something that AI can now help us to automate. The AI can draw “inspiration” from the original program, but it need not just perform minor local transforms on it. Classic optimizing compilers won’t see “oh, you wrote a bubble sort” and, by understanding the contract, switch it to a quick-sort, but both Ollie and the AI are able to do that. This is what puts us more in the program synthesis regime with stochastic optimization than classical optimizing-compiler regime.
>
> This all comes together in the fact that you can start with something that is “not very far from the numpy”, wait 48 hours, and have an optimized kernel with the same semantics, as we showed in our HotChips talk:
>
> *The HotChips slide. DeepSeek MLA climbs from 0.31% of roofline (functional only) to 88.94% in roughly 41 hours, through FP8 attention matmuls (31.69%), attention rescaling with tiled lookahead (59.24%), value-matmul scheduling (77.14%), and key-tile prefetch plus coalesced scale access. The loop is three boxes: functional kernel / executable tests, an internal harness/model with chip or simulator, and an optimized kernel validated e2e on chip. GPT-OSS blocks come out 1.5-1.8x faster than the existing expert-written implementation on attention and MoE.*
>
> ![[cdleary-887834-003.jpg]]
>
> As the slide also notes, on our machine we’re often able to observe the AI climbing performance past our human experts even on the kernels we felt were fairly well tuned. Often there is a decent achievable percentage still left just due to the many varieties of combinations / permutations that may need to be explored. These are often intractably tedious for a human performance engineer.
>
> ## Recap & Conclusion
>
> A compiler, at the end of the day, is just a function. We give our program to that function, and we get back a better version of our program. The program we get out and the program we put in we expect to have the same semantics.
>
> Traditional optimizing compilers make programs better via dataflow rules and heuristics. These are fully understandable in their provenance, but also can be more limited in what moves they can make.
>
> By contrast AI, as a stochastic optimizer, just has to “think hard” and spit something out. Its moves are not as fundamentally limited, making them more analogous to our human expert optimizer. We do need ways to check that the programs that it spits out are sound and implement the same semantics we put in, and we do have those in place. And this kind of AI optimization is particularly well suited to mathematical operations which have very strong contracts. The contracts avoid the need to understand what the kernel does line by line.
>
> That’s how we got the AI generated MLA kernel!
>
> ---
>
> ### Author follow-ups and high-signal replies
>
> **@filpizlo (Filip Jerzy Pizlo), 2 Sep 2026** — replying to @cdleary @matt_dz
>
> That's pretty cool
>
> But you can't extrapolate much from optimizing a kernel to optimizing general purpose programs
>
> **@cdleary, 2 Sep 2026** — in reply
>
> just mean to say "stuff is trending this way, here's an example" than "the world is entirely changed overnight"
>
> of course people can also just ask LLMs to yeet stuff at the source code level, it's the common case for what people do, just less rigorous/controlled
>
> there have definitely been folks focused on eating the heuristics because they are well contained e.g. mlgo https://llvm.org/docs/MLGO.html
>
> i think you also see the surge in languages with strong formalisms leaning (🤨) on this kind of thing
>
> **@HmOhFour (HM04), 2 Sep 2026** — quoting the soundness paragraph
>
> "Now, a key question is how we check that the program we get out of the AI is indeed equivalent to the higher level description / numpy. That checking mechanism establishes the soundness of the AI stochastic optimization process. I expect a future blog post may go into more detail on this, but for now, suffice it to say that testing for semantic equivalence is possible and we do it.
>
> your princess is in another castle
>
> **@cdleary, 2 Sep 2026** — in reply
>
> luckily i've got this talking mushroom and dinosaur that i use as a horse to keep me company until then
>
> **@TonyJZhou (Tony), 2 Sep 2026**
>
> a stochastic optimizer is only safe if the equivalence checker is sound, and then the checker becomes the compiler. humans reading kernels line by line was never the point; the guarantee was. same epistemics as trusting a verifier, just cheaper.
>
> **@jhh1992 (Jin Huang), 2 Sep 2026**
>
> We found that same principle still holds one level up, at serving.
>
> Assert equivalence, then let the agent hill-climb a metric. For our autonomous vLLM optimizer, AMMO, that was model benchmark accuracy as the contract (i.e. GSM8K) and E2E request latency as the objective instead of equal tensors & kernel execution time.
>
> You don't have to read what the agent wrote, as long as benchmark accuracy stays put and the server actually got faster.
>
> https://amazon-science.github.io/ammo/blog/ · https://github.com/amazon-science/ammo
>
> **@mkanat (Max Kanat-Alexander), 2 Sep 2026**
>
> Yeah, just experienced this myself in a limited way yesterday. Building a compiler with various transpiled lowerings. Was playing with the C representation and it is _much_, _much_ easier to just give the AI some parameters and have it do a set of experiments with some semantic bounds than to attempt to figure out the optimal structure myself.
>
> That said, I also think there's an opportunity here for compilers themselves. I don't currently see a world where the most logical way to build _all_ software is to have the AI write the machine instructions, particularly if there are iterative loops involved. I do see a world where AI is the primary optimizer for major production implementations, though.
>
> One limitation I've experienced already is that it does help quite a bit to have the actual hardware target to test against. Not sure how well that will work for shipped client software.
>
> **@FabioRiccardi33 (Fabio Riccardi), 2 Sep 2026**
>
> I have grown skeptical of optimizing compilers. To work properly they need an accurate cost model of the entire system, and modern systems are very hard to model.
>
> I rather prefer a predictable compiler coupled with good measurements and human or AI heuristics in the loop.
>
> **@dylan522p (Dylan Patel), 2 Sep 2026** — unanswered, but the right question
>
> Do these optimization passes often fall into local minimas?
> Does it require a lot of human in the loop to jolt them out?
> Or are all the major things already human in the loop like hey do fp8 attention, hey do attention rescaling with tile look ahead, hey do key tile prefetch?
>
> **@franklynd (franklyn), 2 Sep 2026** — also unanswered
>
> Great read, looking forward to follow ups on ensurive equivalence. I don't know much about ML kernels, I was wondering if they're amenable to using something like z3 to search for equivalence between the two representations.
>
> **@cdleary, 3 Sep 2026** — in reply to @fleetingbits, who asked whether to merge programmatic compilers with LLMs or go "llms all the way down"
>
> thanks for the kind words!
>
> i still spend my days on the symbolic part of compilation tech fwiw, lots of complementary opportunities
>
> **@cdleary, 3 Sep 2026** — in reply to @siliconcodesign, on why other chip-design teams have not adopted this
>
> honestly hard to comment on others' adoption patterns
>
> one thing i cited in the hotchips talk was that the hw team at openai has a unique mix of (a) believing things are possible (b) relentless focus on execution & how things'll actually get done
>
> combo can be surprisingly rare!
>
> **@cdleary, 2 Sep 2026** — in reply to @plugyawn's "Language as Software"
>
> Nice! Related q I've heard people ask is "when do we start sending programs to one another in english", where the nondeterminism of "what it hardens itself into" is a potential strength, as users can guide context & prefs. Challenges too in the correctness of the hardening, ofc.

---

Source: [Compilers 2.0: AI as stochastic optimizer](https://x.com/cdleary/status/2094878051238887834) — Chris Leary (@cdleary), 1 September 2026
