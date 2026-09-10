---
created: 2026-03-26
description: Elliot Arledge reimplemented Craftax-Classic as 1063 lines of CUDA, hitting 8M SPS at 65k environments on a single 3090, revealing that PyTorch op dispatch overhead for tiny MLPs — not environment simulation — was the actual training bottleneck.
source: https://x.com/elliotarledge/status/2037085231141044548
type: learning
---

## Key Takeaways

The headline result — 7x faster PPO training than JAX Craftax on the same GPU — is striking, but the deeper insight is where the time actually went. Profiling showed the environment CUDA kernel consumed only 39% of wall time at 21% memory bandwidth utilization. The PPO update consumed 49% — for a 64-unit MLP. PyTorch was launching hundreds of tiny CUDA kernels per minibatch (categorical sampling, log_softmax, gather, clamp, backward pass) for a network doing almost no actual compute. The environment was never the bottleneck. This connects to [[RL environments are the new unit of progress in agentic AI training]] but adds the crucial nuance that environment speed only matters once you've eliminated framework overhead.

The CUDA implementation packs Craftax-Classic's full game logic — Perlin noise worldgen, crafting, combat, mob pathfinding, intrinsics decay, observation construction — into 1063 lines. State is 2.3 KB per environment using 4-bit packed maps (64x64 in 2048 bytes instead of 4096), so 65k environments fit in 150 MB of VRAM. One CUDA thread per environment, curandPhilox RNG baked into each EnvState.

The most impactful kernel-level optimization was splitting step and autoreset kernels. Perlin noise worldgen is ~10x more expensive than a normal game step. When inlined in the step kernel, every warp with a thread that hit done=true stalls while that thread regenerates an entire world. Splitting means only done environments pay the worldgen cost.

On the PyTorch side, the key optimizations were: Gumbel-max sampling (replacing torch.distributions.Categorical's dozen internal kernels with three fused ops), 16 rollout steps instead of 64 to keep buffers in L2 cache, 1 PPO epoch instead of 4 since minibatches are already massive, and eager mode over torch.compile (compile's graph capture overhead actually makes things slower for a 3-layer MLP doing three matmuls).

The author validates Joseph Suarez's thesis (PufferLib) that C environments plus CPU vectorization is the pragmatic choice for most RL. PufferLib trains PPO at 4M steps/sec on a single RTX 5090 with plain C environments. But for batch sizes of 65k+ on a single GPU with zero CPU-GPU transfers, CUDA kernels unlock a different regime. These are complementary tools on the complexity-throughput tradeoff, not competitors.

## External Resources

- [GitHub: Infatoshi/craftax.cu](https://github.com/Infatoshi/craftax.cu) — 1k lines of CUDA, train 10M steps in 12 seconds on a 3090
- [PufferLib](https://github.com/PufferAI/PufferLib) — Joseph Suarez's C-based RL environment library, 4M SPS on RTX 5090
- [Craftax (JAX)](https://github.com/MichaelTMatthews/Craftax) — original JAX implementation by Matthews et al. (ICML 2024 Spotlight)

## Original Content

> [!quote]- Source Tweet (@elliotarledge, March 26 2026)

> Article: How to Write & Optimize Sims in CUDA
> 
> Joseph Suarez has been on a one-man crusade to make RL fast. His library PufferLib trains PPO at 4 million steps per second on a single RTX 5090. His C environments hit 100M+ simulation SPS per core. Breakout solves in 20 seconds. His whole stack is PyTorch, Python, and C. No JAX, no Rust.
> 
> His thesis is that the entire RL infrastructure stack is broken by 1000x, and a few thousand lines of well-written code can replace bloated frameworks. He won the RLC Outstanding Paper award for PufferLib 2.0, and his take on JAX environments is blunt: Craftax required "3k+ lines of very well written JAX code, solving logic puzzle after logic puzzle just to get the thing to run vectorized." His counter-proposal is to write the environment in C, use PufferLib's CPU vectorization, and scale to thousands of environments. Simple, debuggable, fast.
> 
> I wanted to test the opposite extreme. What if instead of C on CPU, you write the entire game in CUDA and keep everything on GPU? No CPU-GPU copies. No Python in the hot path. Just one kernel per step.
> 
> Craftax-Classic is a procedurally generated survival game used as an RL benchmark. The agent spawns on a 64x64 tile map with resources, mobs, and crafting. 17 actions, mob AI, Perlin noise worldgen, 22 achievements to unlock. Non-trivial game logic -- not a toy physics sim. Originally written in JAX by Matthews et al. (ICML 2024 Spotlight) for fully-GPU training with jax.lax.scan.
> 
> craftax.cu (1,063 lines of CUDA)
> 
> craftax.cuh has a struct at 2.3 KB per env w/ a 4 bit packed map (64x64 map in 2048 instead of 4069). craftax.cu is the all the game logic. It has perlin noise worldgen + crafting mechs + combat + mob pathfinding + intrinsics decay + observation construction. craftax_ext.cu is the c++ extension with craftaxenv class which is really just reset() and step().
> 
> One CUDA thread per environment. curandPhilox RNG baked into each EnvState. Split step and autoreset kernels so Perlin noise worldgen doesn't stall warps when only a few environments hit done=true.
> 
> Env only throughput:
> 
> The CUDA kernel scales nearly linearly with batch size. JAX Craftax OOMs beyond 4k environments on the same RTX 3090 while ours keeps climbing to 8M SPS at 65k environments. State is 2.3 KB per env, so 65k environments is only 150 MB of VRAM.
> 
> PPO training steps/sec
> 
> Where does the time go?
> 
> Profiling the starting configuration revealed that the PPO update consumed 49% of wall time. For a 64-unit MLP. That's PyTorch launching hundreds of tiny CUDA kernels per minibatch -- categorical sampling, log_softmax, gather, clamp, backward pass -- for a network that does almost no actual compute. The env kernel was only 39% of time and running at 21% of memory bandwidth.
> 
> The environment was never the bottleneck. PyTorch op dispatch overhead for tiny networks was.
> 
> The Optimizations:
> 
> - Scale to 65k envs since thats literally what gpus are designed to do
> 
> - 16 rollout steps instead of 64 to keep rollout buffers inside the small 3090 l2 cache. will vary for other gpus
> 
> - 1 PPO epoch instead of 4 as our minibatches are massive from the sheer number of envs
> 
> - Gumbel-max sampling: Replace torch.distributions.Categorical (which internally allocates, normalizes, samples, then computes log_prob in separate kernels) with a single fused operation: add Gumbel noise to logits, argmax, gather from log_softmax. Three ops instead of a dozen.
> 
> - eager > torch.compile since we are dealing with tiny 3-layer mlp
> 
> Through this random little optimization side quest, I learned:
> 
> The env kernel was never the bottleneck. I expected to spend all my time optimizing CUDA -- shared memory for obs construction, tighter state packing, warp-level tricks. None of that mattered. The kernel ran at 21% of memory bandwidth utilization and still wasn't the limiting factor. PyTorch overhead for tiny networks dominated everything.
> 
> Split your step and reset kernels. This was the one kernel-level optimization that made a real difference. Perlin noise worldgen (sin, cos, 4 noise layers, 4096 grid cells) is roughly 10x more expensive than a normal game step. When you inline generate_world() in the step kernel, every warp with a thread that hit done=true stalls while that thread regenerates an entire world. Splitting into step_only_kernel + autoreset_obs_kernel means only the done environments pay the worldgen cost.
> 
> torch.compile is not free. For large models with long forward passes, compile is a clear win. For a 64-unit MLP doing three matmuls, the compile graph capture and CUDA graph replay overhead actually makes things slower. Eager PyTorch with manual kernel fusion (gumbel sampling, manual log_softmax+gather) was faster.
> 
> Yes...Suarez Was Right
> 
> Suarez is right that C environments plus CPU vectorization is the pragmatic choice for most RL workloads. His environments are simple to write, simple to debug, and fast enough. PufferLib's ocean suite proves that you can write a complex game in 450 lines of C, train it in seconds, and move on.
> 
> But for environments where you want to push batch sizes to 65k+ and keep everything on a single GPU with zero memory copies, CUDA kernels unlock a different regime. The entire training loop -- environment, inference, GAE, PPO update -- runs without a single CPU-GPU transfer. That's where the 7x comes from.
> 
> These aren't competing approaches. They're different tools for different points on the complexity-throughput tradeoff. Most of the time, C is the right answer. Sometimes, CUDA is.
> 
> Code: [github.com/Infatoshi/craftax.cu](https://github.com/Infatoshi/craftax.cu)
> 
> 1k lines of CUDA. Install w/ `uv sync`. Train 10M steps in 12 seconds on a 3090.

[Source](https://x.com/elliotarledge/status/2037085231141044548)
