---
created: 2026-04-26
description: Stephen Chin (Neo4j) argues the most reliable graph RAG pattern is vector search to locate entry-point nodes followed by graph traversal to pull related nodes as grounded LLM context, beating both raw LLM answers and pure vector RAG on hallucination-prone questions.
source: https://x.com/rohit4verse/status/2048095156793205000
type: video-transcript
authors:
  - Stephen Chin (Neo4j)
  - AI Engineer
duration: "15:27"
transcript_method: subtitles
---

## Key Takeaways

- **Similarity is not relevance.** Baseline vector RAG returns embeddings near the query, but nearness in vector space is not the same as actually answering the question — it routinely returns incomplete sets that miss the related entities the user really needed. Knowledge graphs encode relationships explicitly, so they fix the gap that pure vector retrieval leaves open. This sits next to [[hierarchical tree navigation can replace vector embeddings for RAG retrieval]] as a critique of flat-vector-search-as-default.
- **The recommended graph RAG pattern is vector-then-graph, not text-to-Cypher.** Chin explicitly warns that letting an LLM generate Cypher (the Neo4j query language) is unreliable — generation quality drops on real questions. The pattern that works: embed the question, do a vector search to land on entry-point nodes (e.g., `emphysema`), then traverse the graph to pull related diagnoses, conditions, and other linked nodes as context for the LLM. Vector handles language translation; graph handles relationships. This complements [[MCTS-RAG enables 7B models to match GPT-4o on knowledge-intensive reasoning by interleaving Monte Carlo tree search with adaptive retrieval]] as a way to ground reasoning without scaling the model.
- **Embeddings live as node properties — chunks and nodes are the same object.** When you import unstructured data into Neo4j, an LLM extracts a node structure from the text, then text embeddings are attached as properties on those nodes. There is no separate vector store; the graph IS the index. This is the architectural inverse of "vector DB plus graph DB stitched together," and it explains why Cognee, Zep, and Memz all chose Neo4j as their backend — graph-native storage matches how LLMs want to retrieve linked information.
- **Position-in-context matters more than context size.** Even with million-token windows, evals consistently show LLMs ignore most of the buffer and weight what's near the top. Pre- and post-filtering of vector results to bubble the most relevant nodes to the top of the prompt is therefore one of the highest-leverage moves in graph RAG — not just an optimization but a correctness lever. Connects to the same lost-in-the-middle pathology motivating [[indexed experience memory compresses LLM agent context without discarding evidence by pairing summaries with a dereferenceable archive]].
- **Production proof: CLA replaced their internal SaaS stack with graph RAG over the wiki and HR docs** — 250k employee questions in year one, 2,000 daily queries, 85% adoption. The signal is not the numbers but the substitution: graph RAG can be the system of record for internal knowledge work, not a research demo.

## External Resources

- [Microsoft GraphRAG paper](https://arxiv.org/abs/2404.16130) — referenced as foundational research on graph data science / community algorithms feeding LLM context
- [Neo4j Certified Developer program](https://graphacademy.neo4j.com/) — the Graph Academy track Chin recommends as a baseline for graph + RAG learning
- [Neo4j NODES conference](https://neo4j.com/nodes/) — annual free conference, three time zones, 24 hours of content
- LangChain, LlamaIndex, Haystack — Neo4j ships first-class integrations with all three; Chin's stance is "use whichever framework you want, we integrate with everything"
- Cognee, Zep, Memz — agent memory vendors mentioned in the talk, all running on Neo4j as the graph backend (some pluggable to other graph DBs)

## Original Content

> [!quote]- Video Transcript
> **Title**: Agentic GraphRAG: AI's Logical Edge — Stephen Chin, Neo4j
> **Channel**: AI Engineer
> **Date**: 2025-07-21
> **Duration**: 15:27
> **Source**: https://x.com/rohit4verse/status/2048095156793205000 (embeds https://www.youtube.com/watch?v=AvVoJBxgSQk)
> **Transcript method**: YouTube auto-subtitles
>
> [Music] My name is Steven Chin. I run the developer relations team at Neo Forj. Um, actually I just started writing a um a new book on graph rag with O'Reilly. So that was my weekend was writing chapters. um first chapter done.
>
> So I think I think we'll actually put like the pre-release version of it up soon. Um and what I am going to talk about for the next 10 minutes is aentic graph rag and a little bit about how you can accomplish this. Okay, so um first of all, who who here is familiar with graph databases? >> Okay, that's really good. Okay, you are you are well above and ahead of the curve.
>
> Um how many folks have have given um graph rag a try to to build systems using graphs? >> Okay, so one guy in the back, he's the expert. If you have any questions, ask him. And just to set the context, I'm like like why is um we we need we basically have a problem with a lot of agentric systems where they're not meeting use cases as was you know Gartner's prediction of doom and utter failure. um and they have a lot of hallucinations in them.
>
> And so um this is an example. I'm not I'm going to kind of breeze through this a little bit, but I basically asked the open3 reasoning API to solve like a a question about biases, reasoning, and math. And the the basic problem is it it doesn't do a good job if you don't give it enough deep information sources of answering things correctly. And um the question is like how many girls you can fit in a classroom? So like it's a tech computer science bias.
>
> It's a little bit about like math and reasoning because I ask it about a grid. It it it inaccurately anchors. Um these are the grid sizes which you could choose on the number of girls you can fit. It inaccurately anchors on some article about a um um non-attacking kings problem. Assumes the squares it's a square like grid.
>
> So like the audience, you guys always win against the reasoning AI even though it takes 40 seconds to to noodle on this and it it further. So I ask like um are the are the girls and boys going to go to home economics or to um um whatchamacallit to to sports and again it this is both a bias and also I misled it by giving information about the ratio of girls and boys and it comes up with an answer calculating that all the girls will go to cooking class which is which is horrible. I mean I I'm the chef at home and I I love cooking. Um so I think that these these are the biases. Now, this is kind of funny because we can reason about the situation and it's like as a problem that we can think about, but imagine if this was like in life sciences about drug discovery or if you're if you're solving a supply chain issue.
>
> So, the fact the LM has has gone and inserted biases, it's done incorrect reasoning along the way. This means you're going to get the wrong business results and it's very hard to figure this out. So basically the problem is the the LM is good at extrapolating information like like doing language tasks, figuring out things and it it gives the impression of intelligence where there's there's no real intelligence. There's no real kind of human reasoning behind it. And so we we overcribe things it can do and there's a bunch of things it can't do well.
>
> Now those those are things that knowledge graphs are actually really good at. So one way we can solve this problem is by throwing more computers at it, more agents, right? And um agentic systems are good at improving the quality of results because you have LLMs talking to each other and reasoning with each other about the problem. So like you know basically agents who observe, they think and they take actions. So you have different types of agents which are doing different things in the workflow.
>
> Um an agentic runtime might look something like this where you you're building out and you have a um orchestration layer which is is working on the agents. You have some geni models hooked up. You have some tools um and then these all collaborate to give you better results than one LM to give you can give you together. Now the challenge with this is that it's a very monolithic architecture. It's hard to maintain.
>
> It's hard to swap out the tools and it also kind of puts you in a situation where you can't secure the system. You can't do a bunch of things. So a good way to solve this is using MCP. You kind of use MCP as your tools where your agents are talking to them. Um with MCP now you have your servers and you have your data sources which are now talking to each other.
>
> Um you have your client and server. So now you can give it um you know files or database records. you can give it a graph database as the system of record and we built a bunch of tools at Neo Forj on top of MCP. So we built um a cipher tool which cipher is the query language for graph databases. Um so what basically it'll it'll use it'll when you ask the MCP server it gives capabilities to generate cipher queries off of prompts or questions or the things you want to pass it.
>
> We have a memory module. So this gives you some agent memory you can use to plug into agentic systems and then we also have um MCP on top of our cloud APIs if you want to provision databases or do different things on top of it. And I think this is a pattern you'll see with a lot of people who are the vendors or building things is now you can plug these tools into your agent architecture and you can use them together with your your graph. Typically like agents are represented in some sort of graph. This is a picture of a lang graph agent and you can layer memory on top of it.
>
> So these are all folks who just spoke in our panel. So Zep, Cognney, Memz, we're all talking about their approach to agents. Um actually they all run on top of Neo Forj. Um so they use Neo Forj as the core graph database as and some of them are pluggable. So you can choose your graph database of choice, but they're a really good way of giving memory to your agents, which is graph-based and matches the way LM want to store, communicate, and retrieve information.
>
> And um also um one of our other speakers on the graph track showed his architecture for doing video search and summarization. And if you notice um they they do a bunch of this already, right? So they they do short-term memory, they have um a whole bunch of lookup information, and they give you a choice of they they have both a graph rag pipeline and a vector pipeline. So I I highlighted the graph rag in in red. And the reason they're doing this is because when you use graph rag, you get some advantages in terms of the results coming back and typically a lower rate of hallucinations.
>
> This would be are like direct LMS are kind of you know they give you very generic responses to a healthcare question. Um baseline rag you get better results back but it's it's incomplete because it's doing um basically it's doing vector similarity. So similarity is not relevance. It it doesn't mean it actually understands the problem. Um this would be a system which does graph rag and the the typical pattern that would get you this is um first do your search in a in a vector search.
>
> You could use a vector database. We also support vector search on top of neoraj and it gives you back results and that's a good way of translating the question into like vectors and then you have mappings from the vector embeddings to your graph and you you pull back the nodes which are relevant. So in this case like you're asking about a um emphyma you'd get back the the node for emphyma you'd pull back all the related nodes and diagnosis and conditions and you see it's just it lists them all right so it's a very effective way to get really good responses back when you're dealing with something where you you kind of have this mix of structured and unstructured data. Here's a quick architecture of how you could put this together using you know you're using traversal and vector similarity. um you take in the question, you do the query against either vectors or knowledge graphs.
>
> Um graph data science or graph analytics are helpful as well to do community algorithms and groupings and things like this. Um some of this is in the Microsoft graph rag paper and other research which is going on in this area and um you feed that back as context to the LM to improve the quality of the answers. Um some of the patterns I've talked about quickly. So text to cipher is what our MCP server does. It's it can be good but sometimes it can be really bad because the generation of cipher by LLMs is not as good as you need it for some cases.
>
> Um the one I was talking about is as um which one was it? Um basically vector search with graph context, right? So you do a vector search and then you use that to pull back related nodes in graph context. That's a really good pattern to start with. And um you can also do pre and post filtering of vector results to bubble things which are more relevant to the top of the context.
>
> Um certain systems this is quite good as well because all you want to do is make sure the LM gets things higher up in the buffer for context windows. Even if LMS now have larger context windows basically what what the eval show is they ignore most of it and they look at the stuff at the top. Okay. So a quick example of a company which is doing this. So CLA basically replaced all of their SAS systems with the great graph rag project.
>
> Um they're one of our customers. Um they took an enterprise wiki's HR systems internal documentation. 250k employee questions after the first year. 2,000 daily queries process and 85% employee adoption. So like a really good adoption of this technology.
>
> Um and I'll give you a couple resources and I think we're at time. Is that about right crew? you have five minutes. >> Oh, okay. >> Oh, I see there's five minutes between sessions.
>
> I was I was rushing to do this even quicker. Okay, so we have time for questions, which is great. Um, so one resource I'd recommend is the um Neo Forj certified developer program. Um, so with the number of hands in the room here for folks who said they know graphs, I'm pretty sure you could all pass the Neo Forj certified exam if you just took it today. and we basically will will mail you a Neo forj certified t-shirt.
>
> You get a little LinkedIn badge to put on your profile and it's a nice way to just show the world that like you actually know this stuff like you know graph technology you know stuff. We'll probably add in additional certifications for like you know graph rag and other stuff in the future but the base certified developer class is a good way just to get base knowledge in this and we do have classes in graph academy on building chat bots using LMS using all this stuff as well. Um second resource is our nodes conference. So the Neo Forj nodes conference is an annual conference. It runs in three different time zones 24 hours all free content, free sessions, you know, come come out and join and check out some of this content.
>
> Okay, I'll let people finish who want to do the QR code. And thank you very much for coming. And we have a few minutes for questions. Okay, so what we'll do is anyone who has questions, just raise your hand, shout it out. If anyone wants to leave the room, feel free to do that as well.
>
> I don't want to keep you trapped in here. Okay. So, in the back >> to be clear, you embed that do a semantic search and grab is that the correct basic >> Yeah. Yeah. Okay.
>
> So, the question is like what the pattern is for for doing this type of search and that that's exactly right. So, so basically what you're doing is you're you're using the LM for what it's good at, which is language translation. So the user can enter whatever convoluted question they want, which would never translate to a beautiful cipher query. And then you you first tell the LM, well, do a vector search on that, like find vector similarity in this. And then because you've generated like the graph and the embeddings to point to each other now you can go to the graph and you can say well this these these embeddings all point to this node in the graph.
>
> So it's probably about in the in the case emphyma. Now I want to pull back the nodes which are either like you could use cosine similarity or you could use um um community grouping algorithms or different algorithms to figure out what's relevant and then pass that as context. >> So in a simple architecture the What >> the chunks you embed and your nodes are the same. >> Yeah. So, so like what we typically do and this is what'll happen if you um import unstructured data into Neo forj.
>
> Well, we we we can create a node structure out of it using LMS and then you hang your embeddings your text embeddings off as properties off of the nodes. >> Who does that? Who does that? >> Um so we have a couple plugins for this. We have a Neo Forj Python library which that has will do a lot of this.
>
> Uh we also have an integration with Langchain. >> So you can use lang chain or um llama index >> or haststack. >> You can pick your own whatever. >> Yeah. So whatever framework you want to do, you can choose and we pretty much have integrations with all of them to to help with the um >> associations.
>
> >> Yeah, the associations. >> Okay. And there were a bunch of hands, but I don't know who's first, so >> you you can go. that you have server memory. Does it handle the logic and so on or exposes all the other framework?
>
> >> Okay. So, so the question is about like how the MCP agent for memory works. Um, so that that is a great question, but >> I actually don't know the answer. It's a it's an open source MTP server. Now, Now if if you want the answer um the session which I'm giving with Michael Hunger and Jesus um in I don't know in a bit um Michael's team built all the MCP servers so he he actually will know the answer and yeah it's it's today I think it's right after this or shortly after this and Michael will go on for hours if you ask him that.
>
> So that's a a great question. Okay and we're at time you get the last question. >> Yeah. So I want to ask about your opinion between lang chain and lang graph frameworks. Are they like complimentary or they're like >> what's your perspective on that?
>
> >> Um okay so the question is like like lang chain versus lang graph. I thought I thought lang graph was like the agent thing that the lang chain folks built. No >> did did you did you use any of that? Like I'm also new to that. Yeah.
>
> So we we have a bunch of experiments and prototypes with um Langraph for for doing agents and things. Um we have integrations with Langchain. >> We also integrate with all the other memory vendors. I mean like I I would say from our perspective, use the tool that's best for you and we'll integrate with everything. >> Yeah.
>
> Okay. Thanks for coming. [Music]
>
> [Original tweet](https://x.com/rohit4verse/status/2048095156793205000) — [Original video](https://www.youtube.com/watch?v=AvVoJBxgSQk)
