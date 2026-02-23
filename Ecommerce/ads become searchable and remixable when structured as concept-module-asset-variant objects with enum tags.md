---
created: 2026-02-07
description: Table Clay's ad system treats ads as structured database objects with a four-level hierarchy and enum-based tags, enabling querying, mechanical variant generation, and concept-level learning
source: Table_Clay_Ad_Structure_Tagging_Spec_v3_READABLE.pdf
type: framework
---

## Key Takeaways

The central design principle is that the system optimizes *concepts*, not individual videos. Videos are executions (variants) of a concept. This reframes creative production from making one-off assets to operating a structured pipeline where every output is a queryable, remixable node in a graph. This builds directly on the idea that [[advertising works when a content farm feeds modular assets into an agent-driven assembly line]] — the spec is what makes that assembly line actually work.

The object model follows a four-entity architecture: ConceptCard (the blueprint with angle, persona, objections, proof beats, hook reservoir), ProofCard (one claim paired with its evidence source), ModuleClip (atomic reusable blocks like hooks, demos, review overlays, end cards), and Asset (the rendered output with all tags and performance metadata). A VariantSet groups Assets that share a ConceptCard and differ by one controlled variable. This hierarchy means you can ask questions like "show me all ads targeting the mess objection with demo proof in 9x16 for parents" — a capability that flat file systems never offer.

The tagging system enforces enum values over free text, which prevents the fragmentation that kills searchability at scale. Tags are organized orthogonally: each answers one question (angle vs hook style vs proof type vs funnel stage). The critical rule is to always tag the *why* (angle, objection, proof) not just the *what* (format, ratio). This aligns with [[advertising angles are testable hypotheses not copywriting]] — angles are the testable unit, and tags make that testing systematic rather than intuitive.

The spec defines six repeatable video templates (UGC voiceover, native demo/POV, product cinematic, carousel micro-LP, static, retarget cutdown), each with a default module recipe. This standardization means variant generation becomes mechanical: swap hooks, swap proof beats, swap CTAs, and you get a combinatorial explosion of testable creatives without reinventing structure each time. The approach maps directly to the modular asset philosophy in [[content systems beat content calendars when assets are modular tagged and agent-operable]].

Two production workflows are defined: (A) reverse-engineer an existing ad by extracting its beat structure and translating with Table Clay's proof cards, and (B) build from scratch starting with angle selection, then proof stack, hook reservoir, template choice, and variant assembly. Both workflows feed learnings back to the tag level so performance data accumulates at the concept/angle/proof layer rather than at the individual video level. This feedback loop connects to the extraction patterns in [[meta ad library research finds winners through longevity signals creative families and angle extraction]].

The filename convention (`[Brand]_[ProductLine]_[Format]_[FunnelStage]_[Concept]_[Angle]_[ProofType]_[HookKey]_[V#]_[Ratio]`) serves as a parseable encoding of the most important tags, enabling bidirectional translation between filenames and database records. This makes file systems themselves queryable even before a proper database exists.

The tag dictionary covers three product lines (Mini Pottery Wheel, Ceramic Travel Mug, Aesthetic/Cute Mugs) with per-line examples for angles, personas, intent contexts, objection targets, hook styles, proof types, offer types, and creative types — making it a ready-to-implement schema for the [[moc - BananaBank|BananaBank]] ad system.

## External Resources

- [[Table Clay Ad Structure + Tagging Spec v3 (Readable)]] — the raw Drive Import with full extracted text
- [[Table Clay Tag Dictionary v2 (JSON)]] — companion JSON schema defining the complete tag vocabulary

> [!quote]- Source Material
>
> Table Clay
>
> Advertisement Structure + Tagging System
> Readable spec for founder + dev + creative operator
>
> This document defines how Table Clay stores, tags, assembles, and iterates ads as structured objects (not just loose video files). It covers all product lines: Mini Pottery Wheel, Ceramic Travel Mug, and Aesthetic/Cute Mugs. The goal: make ads searchable, remixable, and automation-ready.
>
> **Object Model Entities:**
> - ConceptCard: blueprint (angle, persona, objections, proof beats, formats, hook reservoir)
> - ProofCard: one claim + proof source (demo, spec, review, screenshot, guarantee)
> - ModuleClip: atomic block (hook, demo, unboxing, cleanup, lifestyle, review overlay, end card)
> - Asset: rendered output + copy fields + module references + tags + performance metadata
> - VariantSet: family of Assets sharing a ConceptCard, differing by controlled variables
>
> **Tag Categories:** identity/placement (product_line, format, ratio), strategy (funnel_intent, angle, persona, intent_context, objection_targets), creative (hook_style, proof_types, offer_type, creative_type), assembly (module_stack, production), lifecycle (status, version)
>
> **Video Templates:** UGC voiceover, Native demo/POV, Product cinematic, Carousel micro-LP, Static, Retarget cutdown
>
> **Workflows:** (A) Reverse-engineer existing ad → translate with Table Clay proof cards, (B) Angle-first from scratch → proof stack → hook reservoir → template → variants
>
> **Example Records:** 6 full asset records with complete tag sets and module stacks across all 3 product lines
>
> [Source: Table_Clay_Ad_Structure_Tagging_Spec_v3_READABLE.pdf](/data/projects/bananabank/Docs/Table_Clay_Ad_Structure_Tagging_Spec_v3_READABLE.pdf)
