---
created: 2026-03-28
description: A vectorless RAG system uses hierarchical document indexing and LLM-guided tree traversal to find answers, eliminating the need for embeddings or vector databases entirely.
source: https://x.com/thevixhal/status/2037236399691489797
type: framework
---

## Key Takeaways

The core idea is strikingly simple: parse a document into a hierarchical tree of sections, summarize each node bottom-up, then at query time have an LLM navigate the tree top-down by comparing the query against child summaries at each level. This mirrors how humans use a table of contents — the same intuition behind [[context agents should navigate heterogeneous sources natively instead of flattening everything into vector search]], but applied within a single document rather than across sources.

This approach eliminates the entire embedding pipeline — no vector database, no chunking strategy, no similarity thresholds. The index is a plain JSON file. The tradeoff is clear: each query requires multiple LLM calls (one per tree level) instead of a single vector lookup, so latency scales with tree depth rather than being constant. For small-to-medium documents this is fine; for large corpora it could become expensive. The [[agentic search agents replace vector databases for long-term memory achieving 99 percent on LongMemEval]] result suggests this class of reasoning-based retrieval consistently outperforms similarity search.

The implementation uses a two-pass parsing strategy: first split into top-level sections, then recursively split any section longer than 300 words into subsections. This is essentially building a document outline via LLM, which means retrieval quality depends heavily on how well the LLM segments the text — a failure mode the author acknowledges. The post-order summarization (leaves first, then parents from children's summaries) ensures each level captures increasingly abstract representations, similar to how [[agentic search with grep and full-file loading replaces RAG when context windows are large enough]] argues that structure-aware navigation beats flat retrieval.

The "PageIndex" pattern sits in a growing family of vectorless retrieval approaches. Where ColBERT uses multi-vector late interaction and agentic grep uses filesystem traversal, this method uses LLM reasoning as the retrieval mechanism itself. The full implementation is available as a working repository with clean separation of concerns (node, parser, indexer, retriever, storage).

## External Resources

- [pageindex-rag GitHub repository](https://github.com/vixhal-baraiya/pageindex-rag) — Complete implementation of the vectorless RAG system described in the thread

## Original Content

> @TheVixhal — 2026-03-26
>
> Article: Building Vectorless RAG System (No Embeddings, No Vector DB)
>
> In this article we are going to build a Vectorless, Reasoning-Based RAG System using hierarchical page indexing, where a document is turned into a tree and an LLM reasons through that tree to find the answer. No embeddings. No similarity search.
>
> This is very similar to how we search for information in real life. When you want to find something in a textbook, you do not read every page from the beginning. You open the table of contents, find the right chapter, look at the sections inside it, and go directly to the one you need.
>
> PageIndex works the same way. You give it a document, it builds a tree from that document where each branch is a section and each leaf is the actual text, and then when you ask it a question, an LLM navigates that tree level by level to find the right answer.
>
> Complete Code: [https://github.com/vixhal-baraiya/pageindex-rag](https://github.com/vixhal-baraiya/pageindex-rag)
>
> (Don't forget to star the repository if you found this helpful.)
>
> ---
>
> **The Plan**
>
> Here is the full plan before we write a single line of code.
>
> Step 1: Parse the document into a hierarchical tree.
>
> We send the document to the LLM and ask it to split the text into top-level sections. Then for each section that is long enough to be split further, we send it to the LLM again and get subsections. This gives us a multi-level tree. Short sections stay as leaves. Long sections become inner nodes with children.
>
> Step 2: Summarize each node bottom-up.
>
> We walk the tree from leaves to root. Each leaf node gets a short LLM-generated summary of its raw text. Each inner node gets a summary built from its children's summaries. The root ends up with a summary of the whole document.
>
> Step 3: Save the index.
>
> We serialize the tree to a JSON file. This is the index. We build it once and reuse it.
>
> Step 4: Retrieve by walking the tree.
>
> At query time, we start at the root. We show the LLM the summaries of all children and ask which one to go into. We move to that child. We repeat this until we reach a leaf. The leaf's raw text is our retrieved context.
>
> Step 5: Generate the answer.
>
> We pass the retrieved context and the question to the LLM and get our answer.
>
> ---
>
> **Architecture**
>
> Let's look at how data flows through the system.
>
> *Index Time (runs once)*
> ![[thevixhal-489797-001.jpg]]
>
> *Query Time (runs per question)*
> ![[thevixhal-489797-002.jpg]]
>
> ---
>
> Now that we know what we are building and how all the pieces fit together, let's write the code.
>
> **Step 1: Set Up the Project**
>
> ```
> pageindex-rag/
>     pageindex/
>         __init__.py
>         node.py
>         parser.py
>         indexer.py
>         retriever.py
>         storage.py
>     main.py
>     document.md
> ```
>
> Create it:
>
> ```bash
> mkdir pageindex-rag
> cd pageindex-rag
> mkdir pageindex
> touch pageindex/__init__.py
> ```
>
> ---
>
> **Step 2: Define the Node (pageindex/node.py)**
>
> Every section of the document becomes a PageNode. It stores a title, raw text, a summary we generate later, and its children.
>
> ```python
> from dataclasses import dataclass, field
> from typing import Optional
>
>
> @dataclass
> class PageNode:
>     title: str
>     content: str        # raw text, populated at leaves
>     summary: str        # generated by LLM, populated by indexer
>     depth: int          # 0 = root, 1 = section, 2 = subsection
>     children: list = field(default_factory=list)
>     parent: Optional["PageNode"] = None
>
>     def is_leaf(self) -> bool:
>         return len(self.children) == 0
> ```
>
> ---
>
> **Step 3: Parse the Document (pageindex/parser.py)**
>
> We build the tree in two passes. First, we ask the LLM to split the whole document into top-level sections. Then, for any section long enough to be worth splitting further (more than 300 words), we send it back to the LLM and get subsections. Short sections stay as leaves. Long ones become inner nodes with children.
>
> _segment is the helper that does one level of splitting. parse_document calls it twice: once for the whole document, and once per long section.
>
> ```python
> import json
> import openai
> from .node import PageNode
>
> client = openai.OpenAI()
>
> SUBSECTION_THRESHOLD = 300  # words
>
>
> def _segment(text: str) -> list:
>     prompt = f"""Split the following text into logical sections.
> Return a JSON object with a "sections" key. Each item has:
> - "title": short title (5 words or less)
> - "content": the text belonging to this section
>
> Text:
> {text[:8000]}"""
>
>     response = client.chat.completions.create(
>         model="gpt-5.4",
>         messages=[{"role": "user", "content": prompt}],
>         max_completion_tokens=3000,
>         response_format={"type": "json_object"},
>     )
>     parsed = json.loads(response.choices[0].message.content)
>     return parsed.get("sections", [])
>
>
> def parse_document(text: str) -> PageNode:
>     root = PageNode(title="root", content="", summary="", depth=0)
>
>     for item in _segment(text):
>         title = item.get("title", "Section")
>         content = item.get("content", "")
>
>         node = PageNode(title=title, content="", summary="", depth=1)
>         node.parent = root
>
>         word_count = len(content.split())
>         if word_count > SUBSECTION_THRESHOLD:
>             subsections = _segment(content)
>             if len(subsections) > 1:
>                 for sub in subsections:
>                     child = PageNode(
>                         title=sub.get("title", "Subsection"),
>                         content=sub.get("content", ""),
>                         summary="",
>                         depth=2,
>                     )
>                     child.parent = node
>                     node.children.append(child)
>             else:
>                 node.content = content
>         else:
>             node.content = content
>
>         root.children.append(node)
>
>     return root
> ```
>
> After this, short sections are leaves with content. Long sections are inner nodes with subsection children. All summary fields are empty at this point. The indexer fills those in next.
>
> ---
>
> **Step 4: Build Summaries (pageindex/indexer.py)**
>
> We traverse the tree post-order (children before parent). Each leaf summarizes its own content. Each inner node (like root, or any section that had subsections) gets a summary built from its children's summaries. Post-order guarantees every child has a summary before its parent needs it.
>
> ```python
> import openai
> from .node import PageNode
>
> client = openai.OpenAI()
>
>
> def _summarize(text: str, section_name: str = "") -> str:
>     hint = f"This is the section titled: {section_name}.\n" if section_name else ""
>     prompt = f"""{hint}Summarize the following in 2-3 sentences. Be specific and factual. Do not add anything not in the text.
>
> {text[:3000]}"""
>     response = client.chat.completions.create(
>         model="gpt-5.4-mini",
>         messages=[{"role": "user", "content": prompt}],
>         max_completion_tokens=150,
>     )
>     return response.choices[0].message.content.strip()
>
>
> def build_summaries(node: PageNode):
>     # post-order: children first
>     for child in node.children:
>         build_summaries(child)
>
>     if node.is_leaf():
>         if node.content.strip():
>             node.summary = _summarize(node.content, node.title)
>         else:
>             node.summary = "(empty section)"
>     else:
>         # build parent summary from children's summaries
>         children_text = "\n\n".join(
>             f"[{c.title}]: {c.summary}" for c in node.children
>         )
>         node.summary = _summarize(children_text, node.title)
> ```
>
> After build_summaries(root), every node in the tree has a meaningful summary.
>
> ---
>
> **Step 5: Save and Load the Index (pageindex/storage.py)**
>
> We serialize the tree to JSON so we only build it once.
>
> ```python
> import json
> from .node import PageNode
>
>
> def save(node: PageNode, path: str):
>     def to_dict(n: PageNode) -> dict:
>         return {
>             "title": n.title,
>             "content": n.content,
>             "summary": n.summary,
>             "depth": n.depth,
>             "children": [to_dict(c) for c in n.children],
>         }
>     with open(path, "w") as f:
>         json.dump(to_dict(node), f, indent=2)
>
>
> def load(path: str) -> PageNode:
>     def from_dict(d: dict) -> PageNode:
>         node = PageNode(
>             title=d["title"],
>             content=d["content"],
>             summary=d["summary"],
>             depth=d["depth"],
>         )
>         for child_dict in d["children"]:
>             child = from_dict(child_dict)
>             child.parent = node
>             node.children.append(child)
>         return node
>     with open(path) as f:
>         return from_dict(json.load(f))
> ```
>
> ---
>
> **Step 6: Retrieve by Tree Search (pageindex/retriever.py)**
>
> Starting at root, the LLM reads the children's summaries and picks the best branch. If that child is an inner node (it had subsections), we repeat at that level. We keep going until we hit a leaf. The while loop handles any depth.
>
> ```python
> import openai
> from .node import PageNode
>
> client = openai.OpenAI()
>
>
> def _pick_child(query: str, node: PageNode) -> PageNode:
>     options = "\n".join(
>         f"{i + 1}. [{c.title}]: {c.summary}"
>         for i, c in enumerate(node.children)
>     )
>     prompt = f"""You are navigating a document tree to find the answer to a question.
>
> Current section: "{node.title}"
> Question: {query}
>
> Children of this section:
> {options}
>
> Which child section most likely contains the answer? Reply with only the number."""
>
>     response = client.chat.completions.create(
>         model="gpt-5.4-mini",
>         messages=[{"role": "user", "content": prompt}],
>         max_completion_tokens=5,
>     )
>     try:
>         index = int(response.choices[0].message.content.strip()) - 1
>         return node.children[index]
>     except (ValueError, IndexError):
>         return node.children[0]
>
>
> def retrieve(query: str, root: PageNode) -> str:
>     node = root
>     while not node.is_leaf():
>         if not node.children:
>             break
>         node = _pick_child(query, node)
>     return node.content
> ```
>
> ---
>
> **Step 7: Tie It Together (main.py)**
>
> ```python
> import os
> from pageindex.parser import parse_document
> from pageindex.indexer import build_summaries
> from pageindex.retriever import retrieve
> from pageindex import storage
> import openai
>
> client = openai.OpenAI()
> INDEX_PATH = "index.json"
>
>
> def build_index(doc_path: str):
>     print("Parsing document...")
>     text = open(doc_path).read()
>     tree = parse_document(text)
>
>     print("Building summaries (this makes LLM calls)...")
>     build_summaries(tree)
>
>     print(f"Saving index to {INDEX_PATH}")
>     storage.save(tree, INDEX_PATH)
>     return tree
>
>
> def ask(query: str) -> str:
>     if not os.path.exists(INDEX_PATH):
>         raise FileNotFoundError("Index not found. Run build_index() first.")
>
>     tree = storage.load(INDEX_PATH)
>     context = retrieve(query, tree)
>
>     response = client.chat.completions.create(
>         model="gpt-5.4",
>         messages=[{
>             "role": "user",
>             "content": f"Answer using only the context below.\n\nContext:\n{context}\n\nQuestion: {query}"
>         }],
>         max_completion_tokens=500,
>     )
>     return response.choices[0].message.content.strip()
>
>
> if __name__ == "__main__":
>     # First time: build the index
>     build_index("document.md")
>
>     # Then query it
>     print(ask("Your Question"))
> ```
>
> ---
>
> **What the Index Looks Like**
>
> After running build_index, open index.json and you will see something like this:
>
> ```json
> {
>   "title": "root",
>   "summary": "Document covers returns, shipping options, and account setup.",
>   "content": "",
>   "depth": 0,
>   "children": [
>     {
>       "title": "Returns and Refunds",
>       "summary": "Refunds are processed within 14 days of receiving the returned item.",
>       "content": "We accept returns within 30 days...",
>       "depth": 1,
>       "children": []
>     },
>     {
>       "title": "Shipping Options",
>       "summary": "Covers domestic (3-5 days) and international shipping (7-14 days).",
>       "content": "",
>       "depth": 1,
>       "children": [
>         {
>           "title": "Domestic Shipping",
>           "summary": "Standard delivery takes 3-5 business days via USPS.",
>           "content": "We ship domestically via USPS...",
>           "depth": 2,
>           "children": []
>         },
>         {
>           "title": "International Shipping",
>           "summary": "International orders ship via DHL and arrive in 7-14 days.",
>           "content": "International shipping is available to 50+ countries...",
>           "depth": 2,
>           "children": []
>         }
>       ]
>     },
>     {
>       "title": "Account Setup",
>       "summary": "Instructions for creating and verifying a new account.",
>       "content": "To create an account, visit...",
>       "depth": 1,
>       "children": []
>     }
>   ]
> }
> ```
>
> Short sections stay as depth-1 leaves. Long sections (like "Shipping Options") became inner nodes with subsection children at depth 2. Retrieval navigates level by level until it hits a leaf.
>
> ---
>
> **Common Issues**
>
> The LLM keeps picking wrong branches. Your summaries are too vague. Try a stronger model in _summarize or add more detail to the prompt.
>
> LLM segmentation cuts a section in a bad place. When parse_document runs on a long document, it sometimes splits mid-thought. Fix this by increasing max_tokens in the segmentation call, or break the document into ~3000-word chunks before sending each one.
>
> Leaf content is very long. If a leaf has more than ~1500 tokens of content, lower SUBSECTION_THRESHOLD so more sections get split into subsections.
>
> ---
>
> Complete Code: https://github.com/vixhal-baraiya/pageindex-rag
>
> Don't forget to star the repository if you found this helpful.
>
> Keep building. Keep learning.
>
> *Architecture diagram — third image*
> ![[thevixhal-489797-003.jpg]]
>
> Engagement: 1644 likes | 238 retweets | 47 replies
> [Original post](https://x.com/TheVixhal/status/2037236399691489797)
