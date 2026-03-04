---
created: 2026-03-03
description: A two-call prompt injection (35 lines of Python) reveals that Codex's encrypted compact() API uses nearly identical compaction and handoff prompts to the open-source Codex CLI, raising questions about why the encryption exists at all.
source: https://x.com/Kangwook_Lee/status/2028955292025962534
type: learning
---

# Codex compact API uses the same prompts as open-source but encrypts summaries and is vulnerable to prompt injection that leaks them

## Key Takeaways

Kangwook Lee demonstrates that OpenAI's `responses.compact()` API — the server-side compaction path used by Codex models — can be reverse-engineered with a simple two-step prompt injection. The attack poisons the compaction summary in step 1, then reads the leaked prompts back out in step 2. This is directly relevant to the compaction architecture documented in [[codex-findings]], which details how compaction modes work in the open-source Codex CLI.

The key finding: the encrypted API path uses **nearly identical compaction and handoff prompts** to the publicly visible open-source versions in the Codex CLI repo. The compaction prompt instructs the LLM to produce a "handoff summary," and the handoff prompt frames it as "Another language model started to solve this problem..." — both match what's already in the repo at `codex-rs/core/templates/compact/`. This raises an obvious question about why the encryption exists in the first place, since the prompts aren't secret.

The encryption is Fernet (AES-128-CBC + HMAC-SHA256). It protects the blob's integrity and prevents tampering, but since the compaction LLM processes user-controllable conversation history, injected instructions survive the encrypt/decrypt round-trip. The blob preserves content faithfully — including any injected payloads.

The technique itself is a clean example of **indirect prompt injection via context persistence**: the attacker doesn't need to see the intermediate summary, only to influence what the compactor writes, then read it back through the downstream model. The entire attack is 2 API calls and 35 lines of Python.

The open question Lee raises — why two entirely different compaction paths when the prompts are nearly identical — suggests the encrypted path may carry additional metadata or tool-result-specific handling that this simple experiment doesn't surface.

## External Resources

- <https://github.com/openai/codex/blob/main/codex-rs/core/templates/compact/prompt.md> — Open-source compaction prompt
- <https://github.com/openai/codex/blob/main/codex-rs/core/templates/compact/summary_prefix.md> — Open-source handoff prompt

## Original Content

> [!quote]- Source Material — @Kangwook_Lee on X (March 3, 2026) | 528 likes, 39 retweets
>
> **Kangwook Lee** (@Kangwook_Lee) — March 3, 2026
>
> Article: Investigating how Codex context compaction works
>
> For non-codex models, the open-source Codex CLI compacts context locally: an LLM summarizes the conversation using a [compaction prompt](https://github.com/openai/codex/blob/main/codex-rs/core/templates/compact/prompt.md). When the compacted context is later used, responses.create() receives it with a [handoff prompt](https://github.com/openai/codex/blob/main/codex-rs/core/templates/compact/summary_prefix.md) that frames the summary. Both prompts are visible in the source code.
>
> For codex models, the CLI instead calls the compact() API, which returns an encrypted blob. We don't know if it uses an LLM internally, what prompts it uses, or whether there is a handoff prompt at all.
>
> Below, I show how a simple prompt injection (2 API calls, 35 lines of Python) reveals that the API compaction path does use an LLM to summarize the context, with its own compaction prompt and a handoff prompt prepended to the summary. The prompts are nearly identical to the open-source versions.
>
> *Overview of the compaction flow: compact() encrypts LLM-generated summary, create() decrypts and uses it*
> ![[kangwook_lee-962534-001.jpg]]
>
> ## Step 1 — compact()
>
> I call compact() with a crafted user message. On the server side, a compactor LLM processes our input using its own hidden system prompt (which I have never seen and want to figure out).
>
> The server seems to assemble the compactor's context like this:
>
> *The compactor LLM reads its system prompt + our injected input together*
> ![[kangwook_lee-962534-002.jpg]]
>
> The compactor LLM reads its system prompt + our input together. Because our input contains an injection payload (red text above), the compactor is tricked into including its own system prompt in its output. This plaintext summary exists only on OpenAI's server. We only see the encrypted blob:
>
> *The Fernet-encrypted blob — all we get back from compact()*
> ![[kangwook_lee-962534-003.jpg]]
>
> At this point we have no way to read what's inside the blob. It is AES-encrypted and the key lives on OpenAI's servers. We only hope the compactor obeyed the injection and wrote its prompt into the summary. The only way to find out is Step 2.
>
> ## Step 2 — create()
>
> I pass the encrypted blob + a second user message to responses.create(). The server decrypts the blob and assembles the model's context.
>
> *Combining the encrypted blob with a probe prompt to extract leaked content*
> ![[kangwook_lee-962534-004.jpg]]
>
> I send:
>
> The model seems to see something like this:
>
> *The three components concatenated: handoff prompt + decrypted blob + our probe*
> ![[kangwook_lee-962534-005.jpg]]
>
> If Step 1 worked, the decrypted blob should contain the compaction prompt (leaked by our injection). The server also prepends a handoff prompt to the blob. So if our probe successfully gets the model to repeat what it sees, the output should reveal all three: the system prompt, the handoff prompt, and the compaction prompt.
>
> ## Output
>
> Below is the complete, unedited output from one run of extract_prompts.py. Yellow = system prompt, green = handoff prompt, pink = compaction prompt.
>
> *Complete API output showing the leaked system prompt, handoff prompt, and compaction prompt*
> ![[kangwook_lee-962534-006.jpg]]
>
> How do we know these are the real prompts and not just hallucinated text? The extracted compaction prompt and handoff prompt closely match the known prompts used for non-codex models in the open-source Codex CLI ([prompt.md](https://github.com/openai/codex/blob/main/codex-rs/core/templates/compact/prompt.md), [summary_prefix.md](https://github.com/openai/codex/blob/main/codex-rs/core/templates/compact/summary_prefix.md)), which makes it unlikely that the model invented them from scratch. Results vary across runs.
>
> ## The Guessed Pipeline
>
> Putting it all together, here is our best guess for what compact() does on the server side, based on what the extraction revealed.
>
> *Reconstructed pipeline: compact() and create() with compacted context*
> ![[kangwook_lee-962534-007.jpg]]
>
> ## The Script
>
> *The complete 35-line Python script performing the two-call extraction*
> ![[kangwook_lee-962534-008.jpg]]
>
> ## Open Question
>
> Why does the Codex CLI use two entirely different compaction paths (local LLM for non-codex models, encrypted API for codex models) when the underlying prompts are nearly identical? And why encrypt the summary at all?
>
> Hard to say. Maybe the encrypted blob carries something more than what this simple experiment can reveal, e.g. something specific about how tool results are compacted and restored. But I didn't bother to test further.
>
> Source: https://x.com/Kangwook_Lee/status/2028955292025962534
