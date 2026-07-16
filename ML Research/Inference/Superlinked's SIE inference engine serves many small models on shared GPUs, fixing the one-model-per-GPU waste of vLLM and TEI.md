---
created: 2026-07-17
description: Avi Chawla argues that switching to small task-specific models only cuts inference cost if they share GPUs, which vLLM and TEI structurally prevent by serving one model per card — and Superlinked's open-source SIE engine fixes it by running every model shape behind one API with compute-cost batching, LRU load/evict, and a built-in production layer.
source: https://x.com/_avichawla/status/2077653695123378321
type: framework
---

## Key Takeaways

- Small task-specific models only cut cost if they *share* GPUs, because providers bill whole-card wall-clock time, not FLOPs — so replacing one large model with four small ones on four cards just relocates the over-provisioning; the saving appears only when they pack onto one card (4 models → 1 card ≈ 75% off the same work). This is the serving-side corollary to Karpathy's "cognitive core" bet that a ~1B-param distilled model is enough for the thinking part, and to the broader shift that [[Open models now match closed frontier models on core agent harness tasks at a fraction of the cost]].
- Standard serving tools structurally block GPU sharing: vLLM and TEI are one-model-per-server, and vLLM's `--gpu-memory-utilization` (default 0.9) statically pre-allocates a fraction of the card at startup, blind to any other instance on it — so N models on one card means hand-computing N peak-sized memory slices, and a single model spiking on a long document takes the whole card (OCR, embedding, reranking included) down with it. The irony is that vLLM is genuinely good at packing *many concurrent requests to one model* onto a GPU ([[Amit Shekhar explains how vLLM packs more LLM users onto one GPU through PagedAttention and continuous batching]]) — it just has no notion of packing *many different models* onto one, and the whole-card economics of that idle capacity are what [[vLLM throughput benchmarking on H100 — tensor-parallel sizing, speculative decoding, and FP8 KV-cache economics]] quantifies.
- Fragmentation across tools re-creates the exact waste you were escaping: no single server does OCR, vision, embedding, reranking, extraction, and generation, so a pipeline becomes vLLM + TEI + a FastAPI OCR wrapper = four servers, four APIs, four deployments, each grabbing a whole card and unaware the others exist, with no shared queue to say the live search matters more than background indexing.
- The three escape routes each trade one problem for another: managed APIs (OpenAI/Cohere) scale cost linearly, can't host your fine-tuned model, and leak your data off-environment; serverless GPUs fix idle time but cold-start seconds kill a mid-search reranker (and keeping instances warm means paying for idle again); self-hosting on rented GPUs is the right answer for cost and control but drops you back onto the one-model-per-card tools.
- Superlinked's open-source SIE is the proposed fix: one cluster in your own cloud serving 85+ preconfigured models behind four calls (encode / score / extract / generate), packing mixed-length requests by compute cost via a gateway-filled shared queue (pad only to each batch's longest item, not a global max — inverting the usual route-then-batch order), evicting least-recently-used models like a browser cache (the multi-model analogue of the reserved-but-idle memory problem [[paged attention applies OS virtual memory paging to KV cache and unlocks 2-4x LLM serving throughput]] solved within one model), and shipping the production layer — routing, autoscale-to-zero, GPU pools, dashboards, Terraform — of the kind [[Red Hat frames prefill-decode disaggregation, KV-cache tiering, and speculative decoding as the three llm-d deployment levers for distributed AI inference]], with the padding-elimination batching that sits among the [[Ashutosh Maheshwari's sub-second LLM study list catalogs sixteen inference optimizations from KV-caching and speculative decoding to tensor parallelism and memory offloading]]. The hard part it solves — one batched engine that holds BERT/Qwen/ColBERT/reranker shapes that handle positions, attention, and outputs differently — is why this didn't already exist as a package.

## External Resources

- [Superlinked Inference Engine (github.com/superlinked/sie)](https://github.com/superlinked/sie) — the open-source multi-model serving engine; `pip install "sie-server[local]"` runs the CPU path on a laptop, generation runs on SGLang (GPU). Integrates with Chroma, Qdrant, Weaviate, and LanceDB.
- Task-specific models the article cites as already excellent but lacking a unified server: docling and PaddleOCR (documents), SigLIP and Florence (vision), GLiNER (extraction), plus cross-encoder rerankers and sentence-transformer embedders.

## Original Content

> @_avichawla (Avi Chawla) — 2026-07-16
>
> *Before: 4 servers, 4 GPUs (vLLM, TEI, FastAPI, OCR wrapper) → replaced by SIE: one server, one GPU serving encode/score/extract/generate*
> ![[avichawla-378321-001.png]]
>
> **Article: Why serious AI projects can't rely on vLLM anymore in 2026**
>
> Inference bills climb with every new agent and every extra call. So in production, teams prefer to load the repetitive steps onto small task-specific models to bring the cost back down.
>
> Karpathy recently made the same bet at the level of the model itself, arguing that a "cognitive core" of roughly a billion parameters, distilled from a larger model, is enough for the thinking part of the work.
>
> The move is correct, but using SLMs alone doesn't imply savings since those models still have to be served. And serving them without wasting the GPU underneath is a separate problem to be solved.
>
> Today, let's understand why that is the case, what serving many small models well actually takes, and how the [SIE open-source inference engine](https://github.com/superlinked/sie) solves it end-to-end.
>
> Let's begin!
>
> ---
>
> # Workflow of a traditional AI pipeline
>
> A production AI system is usually a stack of individual tasks, and each task is handled by the model that happens to be best at it.
>
> For instance, a single request might:
>
> - parse a document or an image into clean text
>
> - embed that text into vectors for retrieval
>
> - rerank the retrieved results by relevance
>
> - extract the specific fields, entities, or labels that matter
>
> - and check the output against a safety policy before sending it to user
>
> Until recently, the default instinct was to use the largest general-purpose model you could and make it do as much of this as possible, paying frontier rates for every call.
>
> That reflex is now reversing toward using small models fine-tuned for each task, which can run the same step at a fraction of the cost since most tasks don't always need frontier reasoning.
>
> But the catch teams usually miss is that a cheaper model does not imply a cheaper system.
>
> This is because the cost of a model isn't only what it charges per call. It's also the hardware you keep running to answer that call.
>
> A pipeline that replaced one large model with multiple small ones now has multiple models to serve, each occupying a GPU of its own.
>
> ---
>
> # Why don't we fit multiple models on one GPU?
>
> The obvious objection is that we should just put them all on one card.
>
> This will help because no GPU provider bills for the work you do on them. They do not meter FLOPs.
>
> What you rent is a whole GPU for a span of wall-clock time, and the meter runs whether the card is busy or sitting idle.
>
> So every GPU you hold adds another term to the full bill:
>
> Four models on four cards means four terms in that sum. If one card can carry all four models' traffic, three of those terms disappear. Nothing about the work has changed, and yet the bill drops by 75%.
>
> The objection holds up on the memory front too. A small embedding model, a cross-encoder reranker, and an entity extractor together take a few gigabytes.
>
> An L4 has 24GB, so they can fit with room to spare, and nothing in the hardware stops you.
>
> The reason almost nobody does it is that every layer of the stack, from the serving framework down to the driver, was built around one model owning one GPU.
>
> vLLM and TEI are two common servers.
>
> - TEI is Hugging Face's embedding and reranking server and takes a model-id at launch.
>
> - vLLM's engine is built around one model as well.
>
> So putting four models on one card requires running four separate server processes on it. Nothing in either tool coordinates those processes, and you must own that job.
>
> In fact, each process claims its memory upfront and cannot see its neighbours.
>
> vLLM's --gpu-memory-utilization defaults to 0.9. The setting pre-allocates that fraction of the card at startup rather than adjusting it as per demand.
>
> vLLM's own documentation says this is a per-instance limit that ignores any other vLLM instance on the same GPU, and that running two means setting the value to 0.5 for each of them, by hand.
>
> So the memory split is a constant you compute yourself, before any traffic arrives.
>
> It must cover each model's peak, because activation memory grows with batch size and sequence length.
>
> Four worst-case slices pinned onto one card is the same over-provisioning you were trying to escape, and now they have been moved inside a single GPU.
>
> Even if you size them optimally and two models spike together later, they will take the whole card down.
>
> For instance, if the extraction model hits an unusually long document and asks for more memory than its slice allows, it does not just fail on its own. Instead, it takes OCR, embedding, and reranking with it.
>
> This explains why one model per GPU has not been a hardware requirement but a path of least resistance through a stack where every tool was built to serve one model well, and none of them was built to share.
>
> Sharing needs a different kind of server. One server that holds all four models, instead of four servers holding one each.
>
> - It owns the card's memory, so nothing has to be split by hand.
>
> - It sees every request, so it can decide what runs first.
>
> - And it loads a model when a request needs it, then drops it when memory runs short, so a model nobody is calling is not sitting on memory it does not need.
>
> You do not get that by running four servers side by side. This requires an entirely different stack.
>
> ---
>
> # The three ways teams try to avoid this
>
> At this point, one common reaction teams follow is to not to run GPUs the naive way. There are three common escape routes, and each one trades the problem for a different one.
>
> The first is a managed API. Invoke OpenAI or Cohere to avoid thinking about GPUs at all.
>
> - It is a good way to start, but catches fast when you have got scale.
>
> - The bill increases in a straight line with usage while the work stays routine.
>
> - You also run whatever the provider hosts, so the model you fine-tuned for your own task usually cannot go there, and your prompts and documents leave your environment on every call.
>
> The second is serverless GPUs, where you deploy your own model and pay only while it runs.
>
> - This fixes the idle-time problem on paper.
>
> - The problem is the cold start. A model that has scaled to zero has to pull gigabytes of weights into memory before it can answer, which adds seconds to the first request, and a reranker in the middle of a search cannot spend seconds waking up.
>
> - You avoid that by keeping instances warm, and now you are paying for idle GPUs again, which is the exact thing we came here to escape.
>
> The third is the one that is actually right for cost and for control. You self-host the models on GPUs you rent, in your own environment, where the data stays inside your walls, and the bill is a flat hourly rate rather than a per-token meter.
>
> - This is the path most serious teams end up on.
>
> - So you self-host, which requires you to reach for the standard serving tools. And that is where the infrastructure problem gets specific. Let's understand more problems about them below.
>
> ---
>
> # Problems with standard serving tools in a multi-model pipeline
>
> The tools devs use here were built for a different job than the one you have, and it shows up in two ways.
>
> Start with the fact that each tool serves one shape of model.
>
> - vLLM is built to serve LLMs.
>
> - TEI is built to serve embedding and reranking models.
>
> - Neither one does OCR, vision, or document parsing.
>
> This is not a gap in the models themselves. The models for every one of these tasks already exist and are excellent, like docling and PaddleOCR for documents, SigLIP and Florence for vision, GLiNER for extraction.
>
> What does not exist is a single server that runs all of them.
>
> So when the agent needs to parse a document and embed it and rerank and check a policy, you need vLLM for one part, TEI for another, and some FastAPI wrapper somebody wrote for the rest.
>
> This gives you four servers + four APIs + four deployments, all behind one agent.
>
> Now, notice what this setup does to the GPU by going back to the reason each server holds a whole card.
>
> vLLM will occupy 90% of the GPU at startup. TEI will grab its part. The OCR wrapper also needs something.
>
> Each was written on the assumption that it owns the card, and none of them will give memory back to the others, because none of them knows the others exist.
>
> There is no shared queue across them and no way to say that the live search matters more than the background indexing job. We already walked through what that looks like on one card, and it does not get better when the processes come from four different tools instead of four copies of one.
>
> You moved to small models to save money.
>
> But the discussion so far proves that the savings will only show up if you can put several of them on one GPU.
>
> The standard tools cannot make that happen since they force one model per server, and one server per card, which puts you right back on one GPU per model.
>
> The fragmentation in tooling re-creates the exact waste we were trying to avoid.
>
> ---
>
> # What should the serving stack for small models look like
>
> Let's step back from the tools and understand the things we need the ideal tooling to do.
>
> - It should run every kind of model an agent needs, embeddings, reranking, OCR, vision, extraction, and generation, behind one API. That is the only way to get off four servers and onto one.
>
> - It should fill the GPU instead of padding it. And that turns out to require more than a good scheduler, because to pack requests of different lengths into one pass without wasting compute, the engine has to control the batching and the attention path for every architecture it serves.
>
> - It should load and evict models as traffic moves, keeping the busy ones loaded and letting the idle ones move out, so that a model nobody is calling is not holding memory the way a cold serverless worker or a padded vLLM instance does.
>
> - It should ship the production layer with routing, autoscaling, monitoring, and GPU pools. This is important since a bare runtime like vLLM is only the engine. On its own, it cannot spread load across replicas, add or remove GPUs as traffic changes, or place models across a mixed fleet of cheap and large GPU cards. Today, devs need to write all of that themselves, which explains why self-hosting is more work than it sounds.
>
> - And adding a new model should be a config change, not a redeployment.
>
> All this is hard with months of engineering since different model families do not run the same way underneath.
>
> - A BERT and a Qwen handle positions and attention differently.
>
> - A ColBERT returns a vector for every token.
>
> - A reranker returns a single score and no vector at all.
>
> Building one engine that can hold all of those shapes, and pack any of them into a full batch, is critical work, and it is the reason this did not already exist as an open-source package.
>
> ---
>
> # Open-source solution: Superlinked Inference Engine
>
> The solution to all of this is actually implemented in the open-source [Superlinked Inference Engine (SIE)](https://github.com/superlinked/sie):
>
> It runs as one cluster inside your own cloud, and it's built for exactly the kind of pipeline we have been describing, i.e., several small models of different kinds running back to back on shared GPUs.
>
> It runs every kind of model through one API with four calls, so document parsing, vision, content-safety checks, and open-model generation all run on the same server:
>
> - encode turns text or images into vectors
>
> - score reranks a query against a set of documents (returns a number)
>
> - extract pulls structured fields, entities, or markdown out of a raw document (return span of text)
>
> - and generate runs an open LLM on a prompt (returns text and token usage)
>
> - TEI can hand back vectors and relevance scores, but one TEI process serves exactly one model, so embedding plus reranking already means two separate deployments. And TEI does not cover extraction, OCR, vision, or generation, so each of those still needs a server of its own.
>
> - A single SIE cluster can serve all four shapes in one server.
>
> It packs those requests without wasting space.
>
> - Even inside a full batch, there is a second kind of waste. Requests come in different lengths, and the simple way to run them together is to pad the short ones out to match the longest, then process the padding as if it were real.
>
> - SIE batches by compute cost instead of item count. It groups requests of similar length and pads only to the longest item in that batch, never to a global maximum, so almost none of the card's time goes to padding.
>
> - One key difference is where the batch gets formed. Standard stacks route each request to a worker first, and every worker batches only the slice of traffic it happens to receive, so queues run unevenly, and mixed sizes pack poorly.
>
> - SIE inverts this order. The gateway publishes all work into one shared queue, and each worker pulls from that pool and forms a full batch before touching the GPU.
>
> It loads and evicts models based on traffic:
>
> - A model loads into GPU memory the first time a request needs it, and the least recently used one is dropped when memory runs short, the same idea as a browser cache.
>
> - This is also the concrete answer to the reserved-but-idle problem. Several public vLLM issues report that models reserve about 80% percent of a card's memory on load, while utilization during embedding stays under forty percent.
>
> - Optimized load-and-eviction strategies let you run several models in the whole pipeline.
>
> It comes with the production layer already built.
>
> - A gateway sits in front and routes each request to a worker, and when there is a burst, it accepts the request and holds it while more workers start up.
>
> - The workers scale up under load and back down to zero when traffic drops, so you are not paying for idle GPUs.
>
> - It spreads work across whatever cards you give it and comes with the dashboards to watch it and the Terraform to deploy it on AWS or GCP, so the same setup runs on your laptop and on a full cluster.
>
> - It can also run fully offline, with the model weights downloaded ahead of time, for environments where data cannot leave.
>
> Every model is tuned and ready-to-use.
>
> - With vLLM or Triton, each model has to be tuned by hand, meaning the batch size, memory fraction, precision, maximum sequence length, and attention implementation all set for that specific architecture on that specific GPU.
>
> - In SIE, every one of the 85+ models in the catalog carries a config file with those values already filled in, so you reference a model by name, and the engine loads it with settings known to work in production.
>
> - Adding or swapping just requires pointing to a different config rather than starting the tuning over.
>
> ---
>
> # Implementation
>
> Below, let's look at the pipeline that involves three calls to one server.
>
> We'll build a small retrieval pipeline that embeds some text, reranks it, pulls named entity fields out of the context, and then generates the final answer, all through a single SIE server.
>
> This will involve four different model architectures, all hitting one endpoint. The first three calls run on CPU, so you can follow along on a laptop.
>
> The generation step is the one exception, since it runs on SGLang underneath, which needs a GPU.
>
> Start by installing and starting the server. The local extra pulls the CPU runtime, and serve command starts the server on port 8080.
>
> ```bash
> pip install "sie-server[local]"
> sie-server serve
> ```
>
> It is ready when the health check answers.
>
> ```bash
> curl http://localhost:8080/readyz     # ok
> ```
>
> Now, instantiate the client and point it at the running server:
>
> ```python
> from sie_sdk import SIEClient
> from sie_sdk.types import Item
>
> client = SIEClient("http://localhost:8080")
>
> query = "Who issued the invoice and what is the amount due?"
> passages = [
>     "Invoice INV-4471 was issued by Northwind Logistics on 14 March 2026.",
>     "The total amount due is $18,240, payable within 30 days.",
>     "The cafeteria menu changes every Monday and Thursday.",
> ]
> ```
>
> Every call in the rest of the pipeline goes through this one object and this one endpoint, no matter which model it hits.
>
> First we invoke the encode() method.
>
> This turns each passage into a dense vector using an embedding model.
>
> ```python
> docs = client.encode(
>     "sentence-transformers/all-MiniLM-L6-v2",
>     [Item(text=p) for p in passages],
> )
>
> print(docs[0]["dense"].shape)
> # (384,)
> ```
>
> Passing a list gives you back a list of results, one per passage, and each carries its vector under the dense key.
>
> Next, we invoke the score() method that uses a cross-encoder to read the query against each passage together and returns a relevance score for each one, a different kind of output than the vectors above:
>
> ```python
> from pprint import pprint
>
> scores = client.score(
>     "cross-encoder/ms-marco-MiniLM-L-6-v2",
>     Item(text=query),
>     [Item(id=str(i), text=p) for i, p in enumerate(passages)],
> )
> pprint(scores["scores"])
> # [{'item_id': '0', 'rank': 0, 'score': 3.009},
> #  {'item_id': '1', 'rank': 1, 'score': -1.061},
> #  {'item_id': '2', 'rank': 2, 'score': -11.425}]
> ```
>
> The scores are cross-encoder logits, so the absolute numbers do not mean much on their own. Instead, the order is important. The invoice line scores above the payment terms, and the cafeteria has the lowest score, as expected.
>
> The results come back already ranked, so the top passage is the best match:
>
> ```python
> best_id = scores["scores"][0]["item_id"]
>
> best = passages[int(best_id)]
> # 'Invoice INV-4471 was issued by Northwind Logistics on 14 March 2026.'
> ```
>
> Finally, we invoke the extract() which runs an extraction model to generate the fields we ask for, returning each as a labelled span with a confidence score.
>
> ```python
> result = client.extract(
>     "urchade/gliner_multi-v2.1",
>     Item(text=best),
>     labels=["organization", "date", "amount"],
> )
>
> print(result["entities"])
> [
>   {
>     'text': 'Northwind Logistics', 'label': 'organization', 
>     'score': 0.979, 'start': 31, 'end': 50, 'bbox': None
>   },
>   {
>     'text': '14 March 2026', 'label': 'date',
>     'score': 0.951, 'start': 54, 'end': 67, 'bbox': None
>   }
> ]
> ```
>
> This is a third architecture that has a different output shape, but is invoked via the same client and the same server.
>
> Finally, we invoke the generate() to compose the answer from the top-ranked context. This call needs the GPU build of the server, since generation runs on SGLang, which has no CPU path. Everything else about the call is identical.
>
> ```python
> context = " ".join(
>     passages[int(s["item_id"])] for s in scores["scores"][:2]
> )
>
> answer = client.generate(
>     "Qwen/Qwen3-0.6B",
>     f"Answer in one sentence using only this context.\n\n"
>     f"Context: {context}\n\nQuestion: {query}",
>     max_new_tokens=64,
> )
>
> print(answer["text"])
> # 'The invoice was issued by Northwind Logistics, and the amount due is $18,240.'
>
> print(answer["usage"])
> # {'prompt_tokens': 61, 'completion_tokens': 17, 'total_tokens': 78}
> ```
>
> This is a fourth output shape, free text with token usage, produced by a generative model, and it comes back through the same client as the vectors, the scores, and the spans.
>
> ---
>
> That is the whole pipeline involving four model families with four different output types, running under one server and client, with nothing to deploy beyond the single process started at the top.
>
> Each model is pulled from Hugging Face on its first call and stays active for the next request.
>
> ---
>
> Using small, specialized models for the narrow tasks is the right approach, and it is not really controversial. They are accurate enough on the task they are trained for, and they keep your data in your own environment.
>
> But switching to small models does not make inference cheaper by itself. It moves the cost from a per-token bill to the GPUs you rent, and if you put each model on its own GPU, most of that hardware sits idle, and you are paying for it.
>
> The saving only appears when the models share GPUs, and that requires a single engine that can run all of them, because the moment you serve each model with a different tool, each one takes a GPU of its own again.
>
> [SIE](http://github.com/superlinked/sie) (open-source) already implements that, and it lets you run the different models an agent needs on one shared cluster, keeps the GPUs busy instead of idle, and includes the routing and autoscaling you would otherwise have to build.
>
> It also plugs into the retrieval stack you already run, with integrations for Chroma, Qdrant, Weaviate, and LanceDB.
>
> You can find the repo here: [github.com/superlinked/sie](https://github.com/superlinked/sie)
>
> (don't forget to star it ⭐️)
>
> 👉 Over to you, how many separate models does a single request in your stack call, and how many of them are holding a dedicated GPU right now?
>
> ---
>
> That's a wrap!
>
> If you enjoyed this tutorial:
>
> Find me →  @_avichawla
>
> Every day, I share tutorials and insights on DS, ML, LLMs, and RAGs.
>
> Engagement: 59 likes | 10 retweets | 3 replies
> [Original post](https://x.com/_avichawla/status/2077653695123378321)
