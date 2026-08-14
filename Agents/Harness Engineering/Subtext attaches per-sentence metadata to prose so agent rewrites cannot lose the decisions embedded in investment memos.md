---
created: 2026-08-14
description: Hamel Husain's summary of Bryan Bischof and Adam Conway's (Theory Ventures) session — Subtext, "footnotes for agents": a lightweight format attaching per-sentence metadata (author clarifications, open questions) to prose, so agent rewrites of investment memos don't lose the decisions embedded in the text. The sentence stays untouched; the intent travels with it. Humans benefit too — a demo chat interface surfaces each message's linked ticket and call transcript beside the text.
source: https://hamel.dev/notes/llm/ai-product-engineering/context-subtext.html
author: Hamel Husain (summarizing Bryan Bischof & Adam Conway, Theory Ventures)
type: article
tags: [harness-engineering, context-engineering, writing, metadata, agent-steering, subtext, ai-product-engineering, hamel]
---

## Key Takeaways

- **The problem: agent rewrites silently destroy embedded decisions.** Theory Ventures' investment memos carry load-bearing sentences — a phrasing chosen for a reason, an open question deliberately left open. When an agent rewrites the prose, that intent has nowhere to live, so it gets averaged away. Subtext's fix: **attach metadata to each sentence** — author clarifications and open questions stored alongside, sentence text untouched — "footnotes for agents so they don't drift from the source material." It's the document-level version of the vault's context-anchoring theme: [[Joseph Viviano frames agentic research workflows as a continuum of markdown files at different mutation rates from paper.tex to notes.md|prose at different mutation rates]] needs its slow-changing intent pinned where agents can't rewrite it, and [[context files beat MCP schemas for internal agents because they encode how your team actually uses each tool|context lives best next to what it governs]].

- **The pattern generalizes past memos — and humans get the same benefit.** Any AI-assisted writing where decisions hide in phrasing (specs, legal drafts, policy docs) has the drift problem. The demo's human side: a chat interface where every message surfaces the sender's linked ticket and call transcript beside the text — provenance-on-hover instead of context-hunting. Open source as Claude skills (TheoryVentures/subtext-skills).

## External Resources

- Original note: [Steer AI Writing With Footnotes for Agents — Hamel Husain](https://hamel.dev/notes/llm/ai-product-engineering/context-subtext.html) ([AI Product Engineering series](https://hamel.dev/notes/llm/ai-product-engineering/))
- [Bryan Bischof & Adam Conway's talk](https://maven.com/p/ee1f95) · [subtext-skills repo](https://github.com/TheoryVentures/subtext-skills) · [slides (Figma)](https://www.figma.com/deck/OrFaZEXXLmJDokKpdkuzeJ/Subtext?node-id=16-104) · [Theory Ventures](https://theory.ventures/)

## Original Content

> [!quote]- Full note — "Steer AI Writing With Footnotes for Agents" (Hamel Husain; session by Bryan Bischof & Adam Conway)
> _This note covers Bryan Bischof and Adam Conway’s session in the [AI Product Engineering series](../../../notes/llm/ai-product-engineering/index.html)._
>
> Bryan Bischof and Adam Conway are AI engineers at [Theory Ventures](https://theory.ventures/). The firm’s investors write detailed investment memos, and each memo contains important decisions. When an agent rewrites the prose, these decisions are at risk of getting lost.
>
> [Subtext](https://github.com/TheoryVentures/subtext-skills) is their fix. It is a lightweight format that attaches metadata to each sentence. The sentence text stays untouched while the author’s clarifications and open questions are stored as metadata. It functions as footnotes for agents so they don’t drift from the source material.
>
> ![[hamel-subtext-001.jpg]]
>
> The [Subtext skills repo](https://github.com/TheoryVentures/subtext-skills) on GitHub.
>
> Humans benefit too. Adam’s demo shows a prototype chat interface where every message surfaces the sender’s linked ticket and call transcript beside the text, so the reader does not have to hunt down the context.
>
> Watch Bryan and Adam’s talk [here](https://maven.com/p/ee1f95). Their [slides](https://www.figma.com/deck/OrFaZEXXLmJDokKpdkuzeJ/Subtext?node-id=16-104) and [source repo](https://github.com/TheoryVentures/subtext-skills) are also public.
