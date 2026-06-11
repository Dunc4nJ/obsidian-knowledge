---
created: 2026-06-11
description: A ~10k word survey of modern deep learning architecture — image/video/audio encoders, VLMs, VLAs, video generation, world models, and biological foundation models — written in the path-dependent "every paper reacts to the prior one" style of A Short History of Nearly Everything.
source: https://x.com/bqbrady/status/2064055370809778371
type: learning
---

## Key Takeaways

- **Modern multimodality is a half-CLIP plus a tiny projector, not end-to-end pixels.** Benedict frames the VLM architecture as a path-dependent compromise: pixel-token approaches blow out the context window; pre-rendered text descriptions over-compress. CLIP's dual-encoder trick let practitioners cut the model in half, project the latent image into the LLM embedding space via a small MLP, then move to SigLIP-2 as the current ViT default (used in Qwen 3.5). This is the same "compress, but preserve nuance" tension that surfaces again in audio (mel-spectrogram → 80ms / 8-token AuT chunks) and in compressed video frame buffers. Complement with the multimodal-systems portion of [[technmak's AI-ML Engineer Interview Guide for 2026 Part 1 spans classical ML, multimodal systems, and preference optimization across six domains]].
- **VLAs broke the tokenized-action mold by adopting diffusion / flow-matching action heads and N-step trajectory horizons.** Robot coordinates are spatially interdependent, so committing to one dimension autoregressively at a time is structurally wrong; a diffusion head denoising all axes at once is the natural fix. Predicting 10–20 frames forward then smoothing across rollouts solves the second problem — that stateless single-frame inference produces jerky motion and compounding errors — and gives the model room to recover when the camera updates. PI's MEM hierarchy and MemoryVLA both add a slow outer "subtask + memory string" loop on top of this fast inner controller, which is the only way Benedict has seen long-horizon coherence work in practice. This sharpens the robotics layer of [[Crux Capital's Gaetano maps Physical AI as a ten-layer supply chain from training to deployment claiming it rivals the optics super-cycle in investment magnitude]].
- **Mixture of Transformers is the structural answer to the omni-model "modality crowding" problem, not just an MoE rebrand.** Meta's MoT (late 2024) and NVIDIA Cosmos 3 split the body into N parallel weight stacks — one per modality, or one per inference paradigm — that share global self-attention but route deterministically (no learned gate). Cosmos 3's specific innovation is using this to pair an *autoregressive* reasoner tower with a *diffusion* generator tower, both initialized from Qwen3-VL, sharing attention layers and a 3D multimodal rotary positional embedding so action at time T attends cleanly to video frame at T. Reasoning runs first; generator then denoises video, audio, and actions in parallel while attending to (but never overwriting) reasoner tokens. Same MoE family as the routing in [[LLM optimization interview prep maps Flash Attention, ZeRO, speculative decoding, and MoE across training and inference]] but the unit of expertise is a whole transformer stack, not a per-token FFN.
- **World models invert the video-model type signature: F(prev frame, action) → next frame, with hard causal + realtime constraints.** Unlike Sora-class video generators that attend bidirectionally over long temporal chunks, world models must predict one (or a few) frames causally fast enough to be steered by a policy. This forces tradeoffs: pixel-space DiT + flow matching keeps the loss honest but expensive; the LeCun / JEPA latent-space approach is cheaper and ignores irrelevant detail at the cost of representation-collapse risk that's only recently been tamed. The payoff is using the world model as either a Dreamer-style RL simulator, an MCTS-style planner that searches trajectories, or an auxiliary loss that forces dynamics into a text-conditioned action transformer. This is the bridge that connects modern video generation back to robotics policy training.
- **Realtime interaction models trade unified intelligence for natural duplex turn-taking.** The four-model VAD + ASR + LLM + TTS pipeline is brittle because turns are discrete and pipelining latency is high. Moshi's fix is twofold: native 80ms audio tokens (8 discrete codes per chunk, mixing semantic and acoustic) and a duplex clock with parallel input + output + inner-monologue text streams (17 tokens per turn). Async tool calling extends the same idea into a background "oracle stream" the model treats as ground truth — letting a small fast model stall convincingly while a slower, smarter background model thinks. Thinking Machines' interaction models generalize this further with native (video, audio, text) → (audio, text), minimal pre-trained components, and computer-use handled by the background tower. Benedict's bet: interaction model on top, intelligent VLM behind, talking over text.
- **AlphaFold's EvoFormer is a co-evolution loop, not a one-shot prediction — and AF3's PairFormer + diffusion structure head is what unlocked DNA / RNA / small-molecule generalization.** AF2's recipe is to fetch the MSA (column-aligned similar proteins), then bounce 48 times between the MSA stack and the LxL pair-distance representation (which carries hard geometric invariants: symmetry, triangle inequality). The structure module emits coordinates, those get reprojected back into pair representations, and the outer loop repeats 3x. AF3 swaps EvoFormer for PairFormer (operates on a broader vocabulary including nucleotides and atom-level small molecules with bond matrices) and replaces the structure module with a diffusion head, so the model can both reason over multi-molecule complexes and stochastically sample plausible conformations. The same VQ-VAE-as-tokenizer trick used by image and audio encoders shows up in ESM 3 to discretize residue neighborhoods into 4096 structure tokens.

## External Resources

- [bqbrady on X (@bqbrady)](https://x.com/bqbrady) — Benedict's X profile
- [Benedict's blog: Notes on Foundation Models (canonical version)](https://www.benedict.dev/foundation-models) — the cleanly-formatted source for this article
- [A Short History of Nearly Everything (Bill Bryson)](https://en.wikipedia.org/wiki/A_Short_History_of_Nearly_Everything) — the inspiration for the "path-dependent science writing" style Benedict is mimicking
- [3Blue1Brown's transformer playlist](https://www.youtube.com/watch?v=wjZofJX0v4M) — Benedict's recommended LLM primer
- [CLIP (Radford et al., 2021)](https://arxiv.org/abs/2103.00020) — original dual-encoder image/text contrastive model
- [SigLIP-2 (2025)](https://arxiv.org/abs/2502.14786) — current SOTA vision encoder used in Qwen 3.5
- [ViT — An Image is Worth 16x16 Words](https://arxiv.org/abs/2010.11929) — the patch-based vision transformer
- [VAE](https://arxiv.org/abs/1312.6114) and [VQ-VAE](https://arxiv.org/abs/1711.00937) — the encoder/decoder + discretization stack reused across image, audio, and protein models
- [Stable Diffusion (Rombach et al.)](https://arxiv.org/abs/2112.10752) and [U-Net](https://arxiv.org/abs/1505.04597) — the original convolutional diffusion lineage
- [Diffusion Transformer (DiT)](https://arxiv.org/abs/2212.09748) — replaces U-Net with a patch-attention transformer + diffusion head
- [Flow Matching](https://arxiv.org/abs/2210.02747) and [Rectified Flow](https://arxiv.org/abs/2209.03003) — more efficient generalization of diffusion
- [DDPM (Ho et al., 2020)](https://arxiv.org/abs/2006.11239) — the original denoising diffusion paper
- [Whisper](https://openai.com/index/whisper/) — open ASR model whose mel-spectrogram + encoder design seeded modern audio encoders
- [Moshi](https://arxiv.org/abs/2410.00037) — duplex speech-to-speech architecture with 80ms / 8-token audio chunks and an inner monologue text stream
- [Mixture of Transformers (Meta, 2024)](https://arxiv.org/abs/2411.04996) — parallel modality-specific weight stacks sharing one global self-attention
- [RT-2 (Google DeepMind)](https://deepmind.google/blog/rt-2-new-model-translates-vision-and-language-into-action/) — seminal VLA, action-as-token in same vocabulary as text
- [Cosmos 3 (NVIDIA)](https://www.nvidia.com/en-us/ai/cosmos/) — reasoner + generator MoT towers for physical AI
- [Thinking Machines interaction models](https://thinkingmachines.ai/blog/interaction-models/) — minimal-preprocessing realtime (video, audio, text) → (audio, text)
- [Pi.website hi-robot](https://www.pi.website/research/hirobot) and [human-to-robot transfer](https://www.pi.website/research/human_to_robot) — Physical Intelligence's hierarchical VLA + egocentric-data results
- [MemoryVLA](https://arxiv.org/abs/2508.19236) — open-source VLA with compressed memory snapshots
- [MEM from Physical Intelligence](https://arxiv.org/abs/2603.03596) — two-layer goal/memory + low-level trajectory architecture
- [Dreamer](https://arxiv.org/abs/2301.04104) — canonical model-based RL using a learned world model for rollouts
- [JEPA](https://arxiv.org/abs/2506.09985) — LeCun's latent-space prediction approach to world modeling
- [Sora](https://openai.com/index/video-generation-models-as-world-simulators/) — OpenAI's text-to-video flagship
- [GPT Image 2](https://openai.com/index/introducing-chatgpt-images-2-0/) — OpenAI's frontier text/image generator
- [Gemma 4 12B](https://blog.google/innovation-and-ai/technology/developers-tools/introducing-gemma-4-12b/) — Google's open multimodal model with unusually minimal encoders
- [Evo 2 (Arc Institute)](https://arcinstitute.org/news/evo2) — 1M-context DNA foundation model using convolution + attention hybrid
- [ESM (Meta / EvolutionaryScale)](https://github.com/facebookresearch/esm) and [ESM 3 (Science 2025)](https://www.science.org/doi/10.1126/science.ads0018) — BERT-style protein masking models
- [BERT](https://arxiv.org/abs/1810.04805) — the bidirectional encoder lineage that ESM extends
- [AlphaFold 2 (Nature 2021)](https://www.nature.com/articles/s41586-021-03819-2) and [AlphaFold 3 (Nature 2024)](https://www.nature.com/articles/s41586-024-07487-w) — protein structure prediction, then DNA / RNA / small molecule generalization
- [Virtual Cell Models (CZI)](https://virtualcellmodels.cziscience.com/) and [Arc Virtual Cell Initiative](https://arcinstitute.org/virtual-cell-initiative) and [CZ single-cell biology programs](https://chanzuckerberg.com/science/programs-resources/single-cell-biology/) — the next biological foundation-model frontier
- [Axios on the Chan-Zuckerberg / EvolutionaryScale acquisition (Nov 2025)](https://www.axios.com/2025/11/06/zuckerberg-chan-biohub-ai-disease) — context for the ESM team move
- [MCTS](https://en.wikipedia.org/wiki/Monte_Carlo_tree_search) and [Fast Fourier Transform](https://en.wikipedia.org/wiki/Fast_Fourier_transform) — supporting concepts the article references

## Curator's Note on the Verbatim Text Below

The X article rendering returned via `bird thread` contains one structural artifact around the boundary between "Image Encoders" and "Video Encoders": a paragraph fragment ("...self-supervised image The Image Harness") gets interrupted by a duplicated block of the later "Image Harness" and "Video Generation Models" sections, then resumes mid-sentence ("text model called CLIP..."). This is a scraping anomaly, not Benedict's writing. The clean canonical version lives at [benedict.dev/foundation-models](https://www.benedict.dev/foundation-models). The verbatim X output is preserved below for archival fidelity.

## Original Content

> [!quote]- Source Material — @bqbrady (benedict) · Mon Jun 08 18:42:03 +0000 2026 · 334 likes · 31 retweets · 9 replies
> Article title: **Notes on Foundation Models**
>
> 📰 Notes on Foundation Models
>
> I prefer to learn about cutting edge technology at a really specific level of abstraction: I do not want to read pages of math and pore over hundreds of research papers, but I also want to understand the intuition behind why one vision encoder might be better or worse than another vision encoder. For this reason, I find that most frontier machine learning research is not really targeted at me.
>
> I recently read [A Short History of Nearly Everything](https://en.wikipedia.org/wiki/A_Short_History_of_Nearly_Everything). The book is beautiful in the way that the author attempts to motivate every scientific discovery and place it into history and into conversation with the other discoveries of the time. Science is not done in a vacuum, and every paper you read is reacting to what came before. Off the back of reading that book, I was inspired to write something that looks at the path dependency of modern deep learning research in order to understand the most important open questions.
>
> This almost 10k word document is my attempt to survey the field of modern deep learning, understand what is similar between various fields and what is different, and motivate them at a level of abstraction that will be memorable for me. Given the amount of terrain I am covering, any expert in a given field will surely be able to point to something that is oversimplified or slightly wrong. But perhaps this is as useful to some folks who aren't on the research frontier as it was to me writing it. This post is mostly concerned with architecture decisions, although any practitioner will tell you the process of training a frontier model is so much more complicated than just getting the architecture correct.
>
> At the end of the article I've included a glossary for concepts and papers that I reference throughout the post. With that I'll start at the bottom and work my way up the complexity ladder.
>
> # Basic LLMs
>
> I will skip over basic LLMs and the transformer architecture. Nothing I can write here will hold a candle to the numerous excellent explainers written about language models. My favorite is probably [these 3Blue1Brown videos](https://www.youtube.com/watch?v=wjZofJX0v4M).
>
> # VLMs & Omni Models
>
> The key difference with Vision-Language Models is that they can process multimodal inputs as well as text. This is the architecture of most commonly used models like Claude or GPT.
>
> To do this, we need a way to translate the input into the same embedding space that we are using for text and then we need to add training data to the mix so that the model can learn how to reason about the new modality. The three mediums that we care the most about understanding when building a virtual coworker or coding assistant are images, video, and audio. Of the three, images are the most researched and best understood. In fact, I think many of the frontier models including Opus 4.8 may only have image support and no native audio or video encoders (they can still parse other file types with tools).
>
> ## Image Encoders
>
> Naively, you might imagine two ideas for consuming an image with an LLM.
>
> 1. Encode every pixel of the image as a token and treat it like an LLM with pixels in and pixels out.
>
> 2. Use an off the shelf image <-> text transcoder and turn the image into text tokens before feeding these text tokens into the LLM.
>
> Both of these have different problems. The pixel approach is not compressed enough. Early LLMs had 32k–128k context windows meaning a single high resolution image could fill this entire context multiple times over. The learning would be sparse and inefficient. The second approach has too much compression. Even a detailed text encoder is pre-committing to a representation of the image and would make it hard for the model to answer nuanced questions that weren't anticipated ahead of time and encoded into the text representation.
>
> What we really need is something in between: to build a latent representation of an image that can be translated into the same subspace as the text but that preserves a rich and dense representation of the image. Luckily, in early 2021, OpenAI was making progress on a self-supervised image The Image Harness
>
> From there, these models can be extended with a series of hacky harness ideas to achieve higher levels of control. Reminder that these original image models are all text → image. But there are other types of models like image to image editing and infill models that take an image with a patch cut out and fill in the missing patches. Using a series of models like this plus some generic copy-paste and editing tools that we could create using python, the models can start to think and iterate to do more complex tasks like "render a hat on this person's head" or "change the color of this object". There are also more ideas like using the thinking step to rewrite the prompt more accurately or even provide a sketch of a complex image before doing the actual generation. At the absolute frontier of image generation, we transcend beyond pure forward pass model architecture decisions.
>
> Video Generation Models
>
> This brings us to text → video models. Most of the complexity with scaling the image techniques to video comes from two things, generation speed and object consistency. A 10 second video should be hundreds of images, and so this is untenable to generate autoregressively. Additionally, we need some way to attend to the previous image or better the entire history so that we can maintain characters across the render. The dominant approach is DiT with a flow matching head that generates 3D blocks instead of 2D patches. Intuitively, the best way to think about video is as 3D images. So we can take a 16x16 patch of an image and generate it across 4 frames at a time ensuring that the visual is at least consistent for a short period of time. This idea seems to have come into the consciousness around the time of [Sora](https://openai.com/index/video-generation-models-as-world-simulators/). text model called [CLIP](https://arxiv.org/abs/2103.00020) that had some useful properties. CLIP was a dual encoder that took an image and a detailed caption and used two transformers, translating both the image and the caption into the same subspace. This allows a user to take either an image or a block of text, convert it into a shared subspace, and then match it against the other modality.
>
> Instead of completing the full image → text translation, we can instead cut this model in half and only use the portion that translates the image to the latent space. Then we train a separate model called a projector (a small MLP) to project the latent image into the same embedding subspace that is used for text inputs into the transformer. Over time, Google improved on CLIP with SigLIP. [SigLIP-2](https://arxiv.org/abs/2502.14786) is now state of the art and is used in leading models like [Qwen 3.5](https://huggingface.co/collections/Qwen/qwen35). This is called a [ViT](https://arxiv.org/abs/2010.11929) or vision transformer.
>
> One curious thing about the ViT is how the image is partitioned before it is encoded. Counterintuitively, it seems to work quite well to just divide up the image into a series of non-overlapping sub-images. For example, we could take an image, split it up into a 16x16 grid and encode each section. Frequently the projector will compress this further, maybe turning this into 128 tokens instead of 256 or something like that (the key paper here is [An Image is Worth 16x16 Words](https://arxiv.org/abs/2010.11929)).
>
> I would have guessed that this would be something more like a convolutional sweep over the image so that semantic meaning that spanned two patches could be analyzed directly. In general it is impressive that these models can understand text on a screenshot with this type of brute force algorithm, although there is a general trend with all foundation models that given enough data, shocking understanding emerges at scale.
>
> Adding vision training data to an LLM is kind of complicated and multi-step. There are two concerns: one is stability and the other is compute efficiency. The recipe for open-source models looks something like this: take the pre-trained checkpoint for SigLIP and use an existing base model target LLM. First warm up the projector that has to be trained from scratch. Maybe fine-tune the encoder on some data that is more applicable to the domain you care about (it also needs to be trained to understand a broader swath of resolutions). Then collect some multimodal tasks and let it train end-to-end, with the learning rate low on the vision encoder that has a strong prior already.
>
> ## Video Encoders
>
> The next step is to extend this to video input. The naive strategy would be to take every frame, run it through the ViT, add some sort of temporal embedding, and then push it into the main model, treating a video as just a series of images. But this is ridiculously inefficient and breaks down as the videos extend beyond a couple of seconds. The key observation is that frame to frame, often very little will change. So a few strategies have developed to improve the token efficiency:
>
> - Sample every N frames and hope to catch the developments.
>
> - Smart sample by detecting frame jumps that have a lot changing.
>
> - Sample every N frames and then encode only the diffs between full frame samples with fewer tokens.
>
> This is an active area of research and is becoming increasingly important as focus shifts toward building better world models (as we will discuss in a later section).
>
> ## Audio Encoders
>
> Audio is by far the most confusing and hardest to understand for me. Audio follows a generally similar high-level structure to images, but there is a lot less of a consensus in the literature about the optimal implementation since native audio understanding in LLMs is much less common.
>
> The first audio encoders borrowed ideas from [Whisper](https://openai.com/index/whisper/), which is an open-source automated speech recognition model from OpenAI that they released in 2022. Raw audio is just a list of amplitudes. To make this easier to process you slide a small window across it (Whisper uses a 25ms window with a 10ms hop) and run a [Fast Fourier Transform](https://en.wikipedia.org/wiki/Fast_Fourier_transform) on each window to convert the audio into a mel-spectrogram, which is kind of like an image that tells you the energy concentration at each frequency. This is pushed into an audio encoder (Qwen calls it an AuT) and then runs through a small projector to align it to the embedding space of the base LLM.
>
> Similar to SigLIP, the audio encoder is initially trained independent of the full LLM. Qwen does this by training an encoder decoder model that takes a chunk of audio, converts it to text, and then converts it back to audio, using only the encoder half for the final Omni model input data. You might suspect that the data mix for this is audio and the audio transcripts, since voice understanding is by far the most important subset of audio data. However if the model only learns to transcribe, it defeats the purpose of native audio support and you might as well use two pipelined models. To make this truly useful you also want to learn to understand the pitch, emotion, and other subtle features of the audio. Also not all audio will be human voice, so you might want to have the model understand music or mechanical sounds. To learn this you can add audio understanding data to the mix, which is a description of how the audio sounds instead of a direct transcript.
>
> ## Training and Shared Representations
>
> You can imagine how at the end of the day, training multimodal models ends up being more of a data problem than an architecture problem. You need extensive multimedia-caption labels for all the domains you care about, and then full end-to-end examples of multimodal inputs and desired outputs. I suspect computer use data ends up being a great fit here. Agentic tasks on a computer are tractable with an LLM, easy to grade, and take image inputs, allowing the models to learn visual reasoning. I also wonder if computer screenshots might just be an entirely different distribution from traditional images of the world and require either a separate encoder or at least a separate data stack. While they are both technically 2D pixel based grids, it is hard to imagine two data inputs further apart than a picture of a sunset is from a screenshot of a web browser.
>
> In an ideal world, training across all these modalities should allow the model to learn not just about the digital internet, but also real dynamics of physics from the audio and video input through this shared pipeline. In reality, transfer learning and generalization are still not well understood outside the labs and the extent to which the models develop shared understanding across modalities is up for debate.
>
> Another question worth asking is whether all these modalities need native model support or if they can be ingested through tool calling. For example, the model does not have a custom encoder trained for reading PDFs. Instead, it uses a tool to extract whatever information is relevant from the PDF and processes it through the text or image pipeline. You could imagine a model getting cheap video understanding by processing select frames through the image pipeline sequentially or writing a python script to extract information from an audio file.
>
> This entire stack doesn't even touch on outputting non-text tokens, something that is the focus of newer omni models like the Gemini series. I'll touch on multimodal generation later on in this piece, as these all-to-all models are quite new. It is also worth mentioning that there are reports of multimodal capabilities crowding each other out and causing certain types of regressions. You would hope that learning about capabilities in text and then building a shared representation of the same phenomenon in image space would enhance the model's understanding. But if these representations end up somewhat disjoint, it can lead to some negative effects as we try to pack the model's parameters with the maximum amount of information.
>
> Note: As I was writing this, Google released [Gemma 4 12B](https://blog.google/innovation-and-ai/technology/developers-tools/introducing-gemma-4-12b/) and published the architecture. This model has extremely stripped down encoders relative to what I'm describing. Despite people saying that it is easier to learn over these compressed latents, it seems possible that if you get the data mix exactly right, it is slightly superior to train everything end-to-end from scratch. This is also a trend we see with Thinking Machines interaction models later on.
>
> ## Mixture of Transformers
>
> I mentioned above that multimodal capabilities can crowd each other out, where adding image data hurts text performance and vice versa. So far the field has mostly tried to live with this through data balancing tricks. But in late 2024, Meta proposed a more direct fix called [mixture of transformers](https://arxiv.org/abs/2411.04996) (MoT). The idea is to split the body of the transformer into N parallel weight stacks, one per modality, but have them all run through one global self-attention. A video token flows through the video weights for its own feed forward and attention projection layers, but the attention operation itself spans every token, so it can still attend to text tokens that are flowing through their own text weights. Imagine zipping multiple transformers together where the self-attention mixes all the tokens but every other layer is duplicated per modality. The naming is a bit of a stretch from classical MoE since there is no token level routing; every modality just deterministically uses its dedicated stack.
>
> We'll see this idea show up again in the VLAs section, applied to the harder problem of mixing autoregressive understanding with diffusion based generation.
>
> ## Realtime and Interaction Models
>
> As LLMs spread throughout the economy, a series of use cases have started to emerge where latency is the bottleneck. In these domains, you might give up some intelligence of having a multi-trillion parameter unified language model in order to make the turn based interaction much more natural feeling.
>
> ## Realtime Audio Models
>
> The first generation of realtime models was audio focused, since audio is the clearest domain where latency is a problem. The original way to build audio models was to use a combination of four models: a turn detection model to detect when the person starts and ends speaking (VAD), a speech to text model (ASR), a fast (small) LLM, and a text to speech model (TTS). This approximates a stunted conversation and is used by most conversational chat bots currently in production. One benefit of this approach is that the LLM in the middle that does most of the processing is well supported and benchmarked. If you are performing sensitive customer support tasks, it helps to have a model that is highly intelligent and can reliably perform complex tasks on behalf of the user.
>
> The downsides of this approach are pretty obvious. The scaffolding is brittle and the "turns" are discrete, which makes the conversations awkward. Also the pipelining makes the latency quite bad. Some companies try to solve this by doing speculative generation, starting to process responses before the user has finished talking, and other tricks of this sort. There are two major ideas to fix these problems.
>
> The first one we have already partially discussed: the model needs native audio input and output. A natural way to do this is using the intermediate mel-spectrogram like we discussed above. However, instead of projecting this latent structure directly into text space, we can trade a bit of fidelity for simplicity by encoding a batch of 80 milliseconds of audio into 8 discrete tokens, some representing semantic content and some representing acoustic details like pitch. Since these models will need to predict discrete tokens at the end, this simplifies the model quite a bit making it easier to train and faster to inference. This approach works great for audio models that focus on speech, but it doesn't really generalize to more continuous audio like music. However, for most voice assistants, the discrete representation path for audio is sufficient.
>
> Once the input audio is decoded and inferenced through the transformer, we need to decode the output into speech the user can understand. This happens in two steps in open-source models like [Moshi](https://arxiv.org/abs/2410.00037), one of the leading architectures for open-source speech to speech. First, the temporal autoregressive model generates a single token for a batch of 80 ms of audio. Then a second model called a "depth model" is trained to convert the single token into 8 discrete audio tokens that generate the sound. These tokens are generated by residual vector quantization (RVQ) which is a process that reminds me in a geometric sense of gradient boosting. I'm not really sure why this is two discrete models; it seems wrong to me, but perhaps it makes training easier and more stable.
>
> The second improvement is moving from single channel to multichannel (duplex). Again I'll use the Moshi model as an example. Moshi has two concurrent streams, one for audio output from the model and the other one for audio input from the user. Instead of having successive turns on a single stream, this model has a clock where it ingests and generates 80 millisecond blocks of audio. The model is constantly running, and can generate or ingest empty blocks of audio. This means that the conversational flow is learned and interrupting becomes much more natural. Moshi also uses one more trick here where they generate 17 tokens per turn instead of 16: 8 for the model output audio, 8 for the user input audio (supplied live at inference) and 1 for a text stream that helps the model reason. This is called an inner monologue and helps performance by propagating forward some hidden state through time. Often predicting multiple modalities simultaneously helps with training stability and hill climbing.
>
> ## Async Tool Calling
>
> Another constraint of realtime models is that they have a tight generation budget which prevents them from doing extensive reasoning, using tools, and generally from scaling to large sizes without extensive engineering effort. One solution to this problem is asynchronous tool calling. The idea here is that the model outputs both an audio stream and a text stream. The text stream can make a tool call or kick out to a background agent. The background agent then processes this request on its own time and inserts the response into an "oracle stream" that the model learns to treat as a source of truth.
>
> In a traditional LLM a tool call is blocking, but with this system a tool call can run freely in the background. One clever idea is the background model can return progressive results with varying levels of confidence, increasing the verbosity of the communication stream. Then the voice model can use the initial information in conversation before getting a final answer to keep the user satisfied. You could also imagine the model learning how to word responses or stall while waiting for tool calls that take longer.
>
> ## Interaction Models
>
> Recently, Thinking Machines released a generalization of this idea that they call [interaction models](https://thinkingmachines.ai/blog/interaction-models/). This system has a few differences worth remarking on. The first one is that it has a native channel for video input. So the model takes (video, audio, text) and outputs (audio, text). It can also do computer use although I think this is done with the background model and not the main interaction model. The second is that they simplified the encoders substantially from other models that I have described above, opting to do minimal preprocessing and avoid pre-trained components. At a high level this seems more elegant although the details are sparse on how this works or how computationally efficient it is. This seems to be a trend among the leading closed labs working on multimodality. Perhaps with enough sophistication, the encoder can be trimmed down to be less opinionated.
>
> Overall, I have become quite excited by the idea of a latency sensitive interaction model sitting on top of powerful VLM systems. In a perfect world, all these models would be combined into one and the powerful AI could choose when to do a smaller forward pass or delegate to a background process. But in reality this seems far away, and using an interaction model that interacts through text with slower, more intelligent systems seems quite elegant.
>
> # VLAs
>
> Once the models have vision, a natural next question is whether they can take action in the real world. One naive model of this would be to add some tool call to the LLM to allow it to take an action, like inputting the position and orientation of a robotic arm. In practice, this is not so far from how Vision Language Action models work. The seminal paper here is [RT-2](https://deepmind.google/blog/rt-2-new-model-translates-vision-and-language-into-action/) from Google DeepMind, which discretized robot actions into tokens in the same vocabulary as text and co-fine-tuned a VLM on a mix of web data and robot demonstrations, so the same model could output natural language, action tokens, or chain-of-thought reasoning followed by actions. Most modern VLAs have moved away from this token-based approach in favor of an Action Head, a vector that directly encodes where to move the robot (normally the delta between the current position and the target position). Most standard VLAs today output no text. They are trained end-to-end on robotic examples and output actions. They take in task descriptions and frames from a camera fed through the ViT described in the section above and output sequences to complete the tasks.
>
> ## The History of Optimizing VLAs
>
> The naive implementation of this concept has a few flaws. One is that language models are autoregressive but the coordinates for a robotic movement are kind of interdependent spatially, and so intuitively it is weird to have to commit to one dimension first and then the next one, getting locked in each time. It would be nice to kind of generate them all at the same time. The solution to this is to use a diffusion model (or when attached to an LLM, a diffusion head). I'll dig into diffusion models in a later section, but essentially they make a guess at an output and then iteratively refine and denoise it over a few steps. Recently, a lot of diffusion models have shifted to flow matching, a new strategy that essentially makes the diffusion gradient step more efficient.
>
> The next flaw is the speed of the output. The models are small but they still take time to inference, and you need the cycle to complete before you can feed the next image frame back in to make another prediction. There is also a second issue with this which is that the model is roughly stateless and so the motion that comes off of this can be jerky as it has no sense of continuing a trajectory. This is somewhat untenable for a production robotics system that needs to operate in realtime. So the next optimization is to predict out 10–20 frames into the future. This gives the model more flexibility on re-evaluation speed and avoids compounding single-step errors. Also the trajectories can be combined cleverly to smooth out the motion. Physical Intelligence also released an idea for using RL to improve trajectory accuracy on fine motor skill tasks.
>
> When trained with high quality teleoperation data, this seems to work reasonably well for simple manipulation tasks, even ones that are a bit out of sample. Also these models use pre-trained language backbones so they have a robust understanding of language already. This means the task requests can be relational or nuanced and they can still be completed. However, these models struggle with fine-grained motor control and long-term coherence. I spent some time training VLA variants on contrived video game world tasks. I found that it was relatively straightforward to get the model interacting with objects in the view of the camera. However, they have no mechanism to do multi-step planning or learn complex search behavior. Perhaps this is a skill that falls out with enough scale, in the way that language models only predict the next token but were able to learn how to complete multi-hour tasks. But I suspect that there is some additional architecture tweak needed or these models will not be able to generalize to all robotics tasks.
>
> ## Long-Term Coherence
>
> In this vein, there are a few ideas for how to build more long-term coherence into VLAs. The most obvious one is to treat the VLA as a subtask completion engine and have a higher level model orchestrate the subtasks. Some variation of this idea can be seen [here](https://www.pi.website/research/hirobot). If the parent model is smart enough to generate subtasks and verify task completion it probably doesn't even need too much more tuning, and it can treat the VLA as a tool with a reasonably general and forgiving function signature. This setup isn't really optimized to be trained end-to-end and so a few more techniques developed to build a more sophisticated memory harness.
>
> The most well known one is the [MEM release from PI](https://arxiv.org/abs/2603.03596), where they have a two-layered system. The top layer is a model that takes the goal, the current memory string, and the camera state and outputs a new memory string and a subtask. The overwritten memory string allows the model to maintain some understanding of where it is mechanically in the lifecycle of the task. Then the lower level model picks up the subtask and the camera perception state and plays forward a sequence of actions before repeating.
>
> On the lower layer, they use video compression to improve short-term memory. The idea of compressed video encoding will be familiar from the section above about omni models. VLAs have very tight latency requirements and so the last N frames have to be compressed extremely aggressively, but they were able to develop a scheme that does this successfully by reserving a smaller portion of the token budget for the current image and then substantially compressing the further back images and combine it all together. Between these two ideas, VLAs can improve long- and short-term memory.
>
> There are other ideas that are more fully open-sourced like [MemoryVLA](https://arxiv.org/abs/2508.19236). MemoryVLA snapshots some latent state generated by the model and feeds back in a sequence of memory snapshots across both text and images every tick. It is then automatically compressed as the history grows while attempting to preserve the most important frames and average together the most similar frames.
>
> ## Cross-Embodiment Transfer
>
> Robotics models are unique in that they are sensitive to the embodiment they are running on. When we talk about foundation models for robotics, the dream is to train a model so general that it can be transferred to any robot with no fine-tuning, whether it be a drone, a humanoid, or a car. A priori, the way I would expect to make progress on this objective is to have the model learn a generalized model of the world independent of robots, and then train it on enough diverse robot setups so that it can interpolate and maneuver any robot, even out of training sample. From a type signature perspective, there are a few different ideas for how to train VLAs to support more types of robots natively.
>
> The approach from PI is to just force the action vector to be length 32, even though most of the robots don't need it. When it is unused, you mask out the extra slots. Then, the hope is during inference, the model will understand both the action space and the context from the cameras well enough to predict movement for the specific embodiment given diverse enough training data. There are some other ideas around specific tokens to signal the robot type, or training different heads for each robot, but this is more brittle when fully out of sample.
>
> There is some evidence of cross-embodiment transfer with VLAs trained at large enough scale. One way to measure this is to take a reasonably strong base model and add an out-of-sample task demonstrated on only a few of the robot setups. Ideally, if the shared representation is strong enough, you should see the benchmarks climb across all robots, even the ones not in the demonstration.
>
> In practice we see something even stronger. PI found that just adding [human egocentric data](https://www.pi.website/research/human_to_robot) to their training mix improved performance across all the robot embodiments. This is quite important because egocentric human data is generally considered to be cheaper to collect than teleoperation data.
>
> There are some early signs of VLAs generalizing across embodiments but we are not at the point where you can take a frontier model and run it on a new robot you built in your garage with no fine-tuning.
>
> ## Mixture of Transformers
>
> Looking back at the architecture of modern VLAs, there is something architecturally awkward about pairing a pre-trained autoregressive language backbone with a diffusion action head. The reasoning side of the model wants to be autoregressive over latent tokens while the action generation side wants to be a diffusion process. These really feel like two different models trying to share one body, and this is the modality crowding issue from the omni models section in a more extreme form. One emerging idea to mitigate this issue is Mixture of Transformers, with NVIDIA's recently launched [Cosmos 3](https://www.nvidia.com/en-us/ai/cosmos/) as the most promising implementation.
>
> Cosmos 3 splits the body into two towers, a reasoner and a generator. The reasoner is an autoregressive VLM that processes text, images, and video. The generator is a diffusion model that outputs video, audio, and actions. Both towers share their attention layers but have their own feed forward weights. They also share a 3D multimodal rotary positional embedding, so video frames, audio samples, and action tokens can be aligned on a single temporal axis, allowing the action at time T to cleanly attend to the video frame at time T. They initialize both towers from the same pre-trained Qwen3-VL checkpoint and let them diverge during training.
>
> The inference flow is sequential at the tower level but parallel within each tower. In pure reasoning mode, only the reasoner is active, producing tokens autoregressively like a normal VLM. In generation mode, the reasoner produces its understanding tokens first, then the generator denoises all the video, audio, and action tokens in parallel across some number of denoising steps, attending to the reasoner tokens but never updating them. So the flow is reasoning before generation, but within the generation step the output tokens are updated in parallel. This is the elegance of MoT applied here: each side gets to use the right inference paradigm rather than being shoehorned into the other.
>
> Overall, VLAs seem to be flexible enough to perform dexterous manipulation tasks with sufficient data and can be workshopped to handle longer horizons. There are a lot of promising research directions building off VLM style models; however, there is a growing complaint that they do not learn a transferable model of the world as a first-class objective. As a result, many of the top teams have moved toward building video backbone based world models, which were designed to improve on some of the shortcomings around generalization and out-of-distribution tasks.
>
> # Image and Video Generation
>
> Before we get into action-conditioned world models, we need to understand generic image and video generation. World models are built on video backbones instead of language backbones, which require visual data techniques descended from image and video generation models.
>
> ## Early Image Models
>
> Image models are quite simple at a high level. To train them you need a series of highly detailed (image, caption) pairs. The captions are way overly detailed to the point where you can recreate all the individual aspects of the picture from the caption without leaving anything ambiguous. The original image models were trained with [diffusion](https://arxiv.org/abs/2006.11239). Diffusion uses a denoising step based technique where they inject noise into an image and have the model try to denoise it using the prompt as an input, until it recovers the original image. Once they have learned to do this, at inference time you can input an arbitrary prompt and a full noise image and the model can conjure up a new image like magic.
>
> [Flow matching](https://arxiv.org/abs/2210.02747) is a slightly more efficient and elegant generalization of diffusion where you learn a velocity field that transports samples from the noise distribution to the data distribution. The widely-used [rectified flow](https://arxiv.org/abs/2209.03003) variant pushes these paths to be approximately straight, which needs fewer integration steps than the curved trajectories diffusion implies, so you get comparable quality in far fewer sampling steps.
>
> Digging down below the diffusion process, there is a lot more embedded complexity in image models around how autoregressive they are, what they attend to, and more. The original image models like [stable diffusion](https://arxiv.org/abs/2112.10752) used a [U-Net](https://arxiv.org/abs/1505.04597) architecture that was based on convolutions. A large breakthrough in the field was the [diffusion transformer (DiT)](https://arxiv.org/abs/2212.09748). The diffusion transformer breaks the image up into a series of patches and allows the model to attend to all of them through a standard transformer architecture. It uses a diffusion head instead of an autoregressive head to iterate around 20 steps, generating a direction vector to denoise each patch simultaneously. As with everything else, this can be replaced with flow matching. This model is bookended on either side with [VAEs](https://arxiv.org/abs/1312.6114) to encode/decode, and there is some custom mechanic to attend to the prompt and the timestep as well.
>
> ## Autoregressive Image Models
>
> As autoregressive language models rose in prominence, the next question was whether or not images can be generated autoregressively. The naive strategy looks something like this: use a discrete patch tokenizer like [VQ-VAE](https://arxiv.org/abs/1711.00937) (a modification of a VAE that snaps the embedding to a known vocabulary), and generate each patch of the target image one by one using the discrete tokenizer. I guess this approach struggles because the vocabulary is too coarse. It seems nearly impossible to me to make a high fidelity image using 16x16 patches that have to be selected from one of 100k discrete tokens. This is where a diffusion or flow matching head comes in handy. The full multimodal generative models like gpt-4o seem to have a hybrid architecture where they can route to text tokens or they can route to a diffusion head to create an image patch by patch. The diffusion head reads off the same transformer backbone but then does the multiple pass denoising step to generate a continuous patch that is appended to the image. It is easy to see why these models are so slow and take annoyingly long to render but can achieve much higher levels of accuracy.
>
> ## The Image Harness
>
> From there, these models can be extended with a series of hacky harness ideas to achieve higher levels of control. Reminder that these original image models are all text → image. But there are other types of models like image to image editing and infill models that take an image with a patch cut out and fill in the missing patches. Using a series of models like this plus some generic copy-paste and editing tools that we could create using python, the models can start to think and iterate to do more complex tasks like "render a hat on this person's head" or "change the color of this object". There are also more ideas like using the thinking step to rewrite the prompt more accurately or even provide a sketch of a complex image before doing the actual generation. At the absolute frontier of image generation, we transcend beyond pure forward pass model architecture decisions.
>
> ## Video Generation Models
>
> This brings us to text → video models. Most of the complexity with scaling the image techniques to video comes from two things, generation speed and object consistency. A 10 second video should be hundreds of images, and so this is untenable to generate autoregressively. Additionally, we need some way to attend to the previous image or better the entire history so that we can maintain characters across the render. The dominant approach is DiT with a flow matching head that generates 3D blocks instead of 2D patches. Intuitively, the best way to think about video is as 3D images. So we can take a 16x16 patch of an image and generate it across 4 frames at a time ensuring that the visual is at least consistent for a short period of time. This idea seems to have come into the consciousness around the time of [Sora](https://openai.com/index/video-generation-models-as-world-simulators/).
>
> There are also a lot of ideas around how to attend to more history. You can try to compress the video history in ways that we discussed above with encoders, keeping a tight frame buffer for recent frames and then sparsifying. You can generate low res videos and upsample them. You can allow the model to learn latents to keep in memory. This area of research seems wide open. Also, to make videos entertaining they should also have synced audio, which is an improvement we have started to see more recently.
>
> A unique class of video models is frame conditioned video models. If you think about Sora or Runway, they need to input characters into the videos that have been carefully crafted. This changes the type signature a bit as each generating frame has more to attend to. Overall, it is worth keeping in mind what the type signatures of these models are as we move to the next section.
>
> - Image models: F(Text) → Image or F(Text, Image) → Image
>
> - Video Models: F(Text) → Video or F(Text, List[Image]) → Video
>
> # World Models
>
> All of this builds up to world models, the current hot thing in the world of robotics. World models build off the lineage of video models with an important tweak to the function signature: they condition on an action taken.
>
> - World Models: F(Previous Frame, Action) → Current Frame
>
> There are, of course, other slight tweaks on this. Some world models condition on many more historical frames and some condition on text as well. But in my mind, the core idea of world models is that instead of generating a block of realistic contiguous video, they autoregressively allow you to explore a world by taking action and observing new info.
>
> ## Defining the Problem
>
> In practice, this forces a few differences with traditional video models. The first one is that we must predict causally in one direction out a short distance in the future (one or a few frames). When generating 60 seconds of video at once, the model can attend forward and backward or use diffusion over longer temporal chunks. With world models we must generate the next state only given the previous states and then allow the actor to take another action conditional on this new state.
>
> The second constraint is that this must be very fast. When we use a model like [GPT Image 2](https://openai.com/index/introducing-chatgpt-images-2-0/) it may take 15 seconds to generate a frame. This is an obvious non-starter for world models which must be much closer to realtime to be usable. Finally, we can be slightly less picky about beautiful pixel quality so long as the model focuses in acutely on the objects that are important to the task at hand. This is slightly hard to get perfect since a priori it may be hard to know what will be important. But if done well this can massively reduce the complexity of the problem.
>
> Once we have a quality world model, it is easy to see how this would be useful for robotic systems. First, we could train robotic policies end-to-end in these sophisticated simulators that mirror a robot in the real world with a camera attached. Second, a system using a world model could forecast out certain actions a short distance into the future allowing it to search over a variety of trajectories. Third, you could just use the world model objective as an auxiliary loss to stabilize training and ensure you learn world dynamics, while having the main action model be a text conditioned transformer that takes actions.
>
> ## Latent Space vs. Pixel Space
>
> There are two competing schools of thought in the world models space about the right way to do this prediction, although maybe the dichotomy is slightly overstated. The first idea is familiar from the video section. We can use a VAE or some custom encoder to build a representation of the recent frames, then use a DiT style transformer with flow matching to predict the next frame and decode it back into pixel space. This is generally considered the pixel to pixel approach, where the training objective is correctly reconstructing the full image pixel for pixel conditioned on the action. There is a ton of nuance in this approach with how we attend to the previous history and compress this efficiently, and also how we go about attending to the action.
>
> The second idea comes out of the Yann LeCun school of thought, where we train a ViT to encode all the video frames into a new latent space and then we build a small transformer that takes a frame and an action already in the latent space and predicts the next frame. The loss function here stays entirely out of pixel space, and so the argument is that the model will not learn dynamics that are deemed to be unimportant, therefore ending up much more data efficient and elegant. The classic failure mode for this type of model is that the model can collapse, because the loss depends on the ViT which might be trained at the same time. There have been elegant solutions developed over the past few years that seem to mostly mitigate this collapse.
>
> ## Inductive Bias
>
> There is a common debate in machine learning around how much structural prior we should force into the model given what we know to be true about the world. On one end of the spectrum we have language models, which have very weak priors. They do not force the model into correct sentence structure or anything like that; the model learns almost everything from scratch from the data (with the exception of the tokenizer). On the other end of the spectrum are biological models that we will discuss in the next section, where the architecture enforces strong priors around geometry and other aspects of protein structure instead of trying to have the model learn all of this from scratch.
>
> In many ways, it would seem natural for world models and video models to enforce real world physics, including gravity and friction and such. However, in practice this does not seem to be the dominant strategy, and realistic physics ends up falling out of sufficient amounts of training data. In some ways [JEPA](https://arxiv.org/abs/2506.09985) is an inductive bias, but not really about the 3D world, more so about the training objective.
>
> Another spot where this comes into play is with sensors. Most models rely heavily on video feedback to make decisions, but there are many more ways to get highly structured data from a robot. The first one is gripper tactile sensors. One scary part of deploying robotics is that a gripper might not understand how much pressure should be applied to pick up a given object, causing it to either slip or get crushed. A potential solution to this problem is to add the gripper feedback into the world model training, although this substantially raises the requirements on the data pipeline.
>
> You might also want to add lidar or better 3D spatial awareness into these models. I won't go into this much here, but there is a wide array of sensors beyond cameras, and there is a lot of nuance in defining the observation space.
>
> ## Training and Action Inference
>
> These models are often trained in multiple stages like language models. A common technique is to train a model with no action conditioning to just learn physics and real world dynamics first. At the end you can add in the action conditioning with custom well labeled robotics task data, augmented YouTube data, or even human egocentric data. The final step is fine-tuning the model to the exact deployed instance that it will run on, but supposedly this transfers pretty well from egocentric body cam data.
>
> Now if you recall back to the VLA section, most robotics tasks are specified in text and these world models don't say much about that yet. There are a few ways to go from a world model to an actually useful robotics system. The first idea is to just use it to generate a ton of synthetic off-policy data for training another model. Even better, you could run the policy in a rollout with the world model and do sophisticated reinforcement learning (the canonical model here is called [Dreamer](https://arxiv.org/abs/2301.04104)). Another idea is to use these models for planning. This reminds me a lot of chess models that do search over a bunch of possible options at runtime. A well-known technique here is called [MCTS](https://en.wikipedia.org/wiki/Monte_Carlo_tree_search) where a learned policy guides an extremely efficient forward search over a series of plausible paths (the analogy here is to tactical lines in chess) and then you pick the best idea. One thing to note here is this demands a quite efficient forward step on the world model since you may have to do hundreds of inference steps of simulation for every movement in the real world.
>
> A possibly underrated auxiliary prediction objective for world models might be error estimates. When a policy is responsible for moving around a physical robotic system, it can be much safer if the system is able to calibrate its certainty, allowing the policy to enforce additional safeguards.
>
> # Biological Foundation Models
>
> There are a few varieties of biological foundation models with the most famous by far being AlphaFold. They are actually quite easy to understand at a high level. There are currently two main targets that the field is focused on predicting, protein sequences and DNA sequences (they are closely related since an amino acid is made up of three letters in a DNA sequence). Given these sequences, we can divide them up into a few different prediction targets. The levels of abstraction are sequence, structure, and function.
>
> ## DNA Sequence Models
>
> Even though AlphaFold was the first breakthrough model in this field, I think it makes the most sense to learn about this starting with the sequence prediction models. The lowest level model is [Evo2](https://arcinstitute.org/news/evo2), which was released by the Arc Institute last year. Evo2 is kind of like a modified transformer with only 4 tokens (A, C, G, T). Unlike language models, it needs an extremely long context window by default to understand eukaryotic life which has sequence dependencies that can span hundreds of thousands of positions in the sequence. The first version of Evo had a context length of 130k and was only trained on simpler life. Evo 2 bumped this up to 1M.
>
> Because of this constraint, Evo is not a traditional transformer. Instead of fully relying on attention, it uses a series of short, medium, and long convolutional filters and gates interspersed with attention. This gives it some long context understanding without paying the full quadratic cost we would associate with an LLM that had a 1M context window. The exact mechanics of the sliding convolution are a bit nuanced and it is somewhat unclear to me why regular attention cannot be used given we have built LLMs now with 1M context. Similar to safety research with LLMs, the Evo models exclude virus data to make it harder to use these models to create dangerous pathogens.
>
> ## Protein Sequence and Structure Models
>
> A close family of sequence prediction models is masking models. Since DNA sequences are extremely long and complex, autoregressive prediction is the more important target for DNA. But for protein sequences, the masking target is more useful and is what gives us downstream insight into the structure and function. The most widely used protein masking model is [ESM](https://github.com/facebookresearch/esm) from Meta ([ESM 3](https://www.science.org/doi/10.1126/science.ads0018) was built by a Meta spinout called EvolutionaryScale which was [acquired by Chan Zuckerberg Biohub](https://www.axios.com/2025/11/06/zuckerberg-chan-biohub-ai-disease) in late 2025). The ESM 2 model is basically just [BERT](https://arxiv.org/abs/1810.04805). However, even though the model is doing a bidirectional prediction of the amino acid, they found that the attention relationships between the various positions actually embedded the 3D structure of the protein with a surprising degree of accuracy. If an attention head learns to link two tokens, it is because they are close to each other in 3D space once the protein is folded. This insight was used by Meta to build ESMFold in 2022 which rivals AlphaFold 2 (it is slightly less accurate but much faster).
>
> ESM 3 extends this model to predict sequence, structure, and function directly. Similar to what we saw with tokenizers and encoders in the previous sections, ESM 3 uses a VQ-VAE to encode the position into 4096 discrete tokens that describe the neighborhood an amino acid ends up in. Each position can also have up to 8 functions such as "ATP binding" or "catalytic site". There are over 200,000 of these tags in the tokenizer. The ESM 3 model is also a bidirectional transformer that sums up all the input vectors and outputs the 10 residual vectors (sequence, structure, and the 8 function tags). There is a clever modification to this model where the first layer embeds some geometric structure by attending to relative coordinates. I haven't dug into exactly how this works.
>
> This brings us to the most well known biological foundation model, AlphaFold, which is built to explicitly predict protein structure from the sequence. I'll skip AlphaFold 1, released in 2018, which was simpler and less impressive and jump to [AlphaFold 2](https://www.nature.com/articles/s41586-021-03819-2), released in 2021 (it debuted at CASP14 in 2020), the work that won the Nobel Prize and essentially solved protein folding. The first step in this model is quite weird: you take the sequence and look up the similar proteins in a database. This stack of similar proteins is called an MSA. The goal with this is to predict a pair representation of the target protein. This is an LxL matrix (where L is the length of the protein) that encodes the pairwise distance between the relative amino acids. One important note about the pair representation is that it has some embedded invariants. For example, (i, j) has to equal (j, i) and the triangle inequality has to hold.
>
> From here, the embedded MSA matrix and the empty pair representation are passed into a module called the EvoFormer that uses a clever co-evolution process to iteratively refine the pair representation. Essentially, the MSA matrix self attends over the pairs and columns and comes up with a guess for the target. Then the target uses its geometric invariants to correct any errors that have been made and passes them back as an update to the MSA matrix. This process repeats back and forth 48 times. At the end of this we only have relative positions but we need exact geometry. So the pair representation is used as an input into a structure model that uses a geometric attention mechanism (similar to what we described above with ESM-3) to generate candidate locations and angles for the protein shape. These coordinates are then converted back into pair representations and re-inputted into the EvoFormer for another round of refinement. All in all, AlphaFold does the outer loop 3 times, each of which consists of a 48 step EvoFormer co-evolution.
>
> [AlphaFold 3](https://www.nature.com/articles/s41586-024-07487-w) extends this for more complex structures on two different dimensions. First, it extends the vocabulary beyond amino acid sequences to also include DNA/RNA sequences and small molecules. DNA and RNA are tokenized at the nucleotide level and small molecules are input using string representations but decomposed into atom level representations with a token bond matrix for granularity and standardization. Second, it can model multiple structures at the same time, giving some insight into interactions. The model is also two stages: the EvoFormer is replaced with something called a PairFormer and the structure model is replaced with a more modern diffusion model.
>
> There are more models that compete in adjacent spaces to these. Chai-1 was built as an open-source alternative to AlphaFold 3. There are plenty of attempts to do generative protein sequencing and interpretability on DNA sequences as well. Currently, one of the hot frontiers is [full cell models](https://virtualcellmodels.cziscience.com/). Teams at [Chan Zuckerberg](https://chanzuckerberg.com/science/programs-resources/single-cell-biology/), DeepMind, and [Arc](https://arcinstitute.org/virtual-cell-initiative) are all working on modeling the full lifecycle of the cell to understand the impact of perturbations while obeying all the natural laws of physics.
>
> # Honorable Mentions
>
> Some model types that I did not get around to but may revisit: Music Foundation Models, Mathematical Foundation Models, and Video Game Models.
>
> # Glossary
>
> ## Terminology / Acronyms
>
> - Encoder/Decoder: An encoder turns raw input like pixels or audio into vectors a model can work with; a decoder runs that backwards to produce output.
>
> - Projector: A tiny neural net that translates vectors from one embedding space into another so they line up.
>
> - Tokenizer: Whatever chops your input into the discrete chunks the model actually processes.
>
> - Autoregressive: Generating one token at a time, each one conditioned on the ones already generated.
>
> - [ViT](https://arxiv.org/abs/2010.11929): An encoder-only transformer architecture that chunks an image into patches and turns them into embeddings, usually plugged in as the vision encoder of a VLM.
>
> - AuT: The audio encoder module inside an omni model, same idea as a ViT but applied to chunks of audio.
>
> - [DiT](https://arxiv.org/abs/2212.09748): A transformer used as the image-generation head inside a multimodal model, where the output step is iterative denoising instead of next-token prediction.
>
> - [VAE](https://arxiv.org/abs/1312.6114): An encoder-decoder pair where the latent in the middle is sampleable, so unlike a ViT it can both compress data and generate new samples by decoding random latents.
>
> - [VQ-VAE](https://arxiv.org/abs/1711.00937): A VAE where the latent snaps to one of a fixed vocabulary of vectors, so it can act as a tokenizer module for a downstream transformer.
>
> - FFT: A math trick that converts a waveform into the set of frequencies that make it up.
>
> - ASR: Speech in, text out.
>
> - TTS: Text in, speech out.
>
> - Mel-Spectrogram: A picture of audio with time on one axis and frequency on the other, brightness for loudness.
>
> - [BERT](https://arxiv.org/abs/1810.04805): A transformer trained by masking random tokens and predicting them, so attention runs in both directions.
>
> - MSA: A column-aligned stack of related protein sequences across species, useful for seeing which positions evolve together.
>
> - EvoFormer: AlphaFold 2's iterative refiner that bounces between the sequence stack and a pairwise distance matrix.
>
> - PairFormer: The AlphaFold 3 successor to EvoFormer, generalized past just proteins.
>
> - MoE: A transformer where each layer has many small "expert" subnetworks and a router picks a few to activate per token, giving you the capacity of a huge model while only paying compute for a slice of it.
>
> - [Mixture of Transformers](https://arxiv.org/abs/2411.04996): A multimodal variant of MoE where the experts are whole transformer stacks split by modality, so text, image, and audio each get their own dedicated weights while still mixing through one global self-attention.

> [!quote]- Author self-reply (@bqbrady, Mon Jun 08 18:44:22 +0000 2026)
> This article is a cleaned up version of notes I have taken on foundation model architectures over the course of many weeks. It is also available here https://www.benedict.dev/foundation-models
