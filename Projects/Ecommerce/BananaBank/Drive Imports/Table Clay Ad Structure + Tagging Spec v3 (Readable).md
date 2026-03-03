---
title: Table Clay Ad Structure + Tagging Spec v3 (Readable)
created: 2026-02-05
description: Comprehensive spec for Table Clay ad structure — object model (Concept → Modules → Asset → Variants), tag dictionary, video templates, and workflows for building or reverse-engineering ads
source: gdrive/Banana Bank
date_imported: 2026-02-05
source_type: gdrive_file
source_folder: Banana Bank
local_attachment: "Attachments/BananaBank/Table_Clay_Ad_Structure_Tagging_Spec_v3_READABLE.pdf"
type: reference
---

## Context

This is a Drive import for [[moc - BananaBank]] and is the longer-form version of the object model described in [[ads become searchable and remixable when structured as concept-module-asset-variant objects with enum tags]].

Related schema: [[Table Clay Tag Dictionary v2 (JSON)]].

## File
- PDF: [[Attachments/BananaBank/Table_Clay_Ad_Structure_Tagging_Spec_v3_READABLE.pdf]]

## Full extracted text (pdftotext)

```text
Table Clay

Advertisement Structure + Tagging
System
Readable spec for founder + dev + creative operator
This document defines how Table Clay stores, tags, assembles, and iterates ads as
structured objects (not just loose video files). It covers all product lines: Mini Pottery
Wheel, Ceramic Travel Mug, and Aesthetic/Cute Mugs. The goal: make ads searchable,
remixable, and automation-ready.

What your dev should take from this:
• A clear object model: Concept -> Modules -> Asset -> Variants.
• A tag system that behaves like a database schema (enums + examples), not vibes.
• Standard video types (templates) + required module stacks for each.
• Two workflows: (A) reverse-engineer an existing ad, (B) build from scratch.
Version: v3 (readability pass) | Date: 2026-02-04

1

Contents
• 1. Vocabulary and hierarchy (what exists in the system)
• 2. The object model (what the database stores)
• 3. Tagging system: purpose + rules
• 4. Tag dictionary (with examples by product line)
• 5. Video types + templates (what to produce)
• 6. Processes: Ad example -> new ad, and From scratch -> new ad
• 7. Full example records (Mini Wheel, Travel Mug, Aesthetic Mugs)

2

1. Vocabulary and hierarchy
These definitions are the backbone. If everyone uses them the same way, tags become
consistent and automation works.

Hierarchy (top to bottom):
• Campaign: budget + optimization goal (platform wrapper).
• Ad set: audience + placement strategy (prospecting, retargeting, etc.).
• Ad: the creative decision unit (Angle x Format x Variant).
• Asset: the actual output files + ad copy fields.
• Modules: reusable building blocks (hook clip, demo clip, review overlay, end card).

Core terms (must be consistent):
• Angle: a persuasion lens / testable hypothesis (therapy, mess-controlled, leakproof
commute, morning ritual).
• Hook: first 1-3 seconds that earns attention and frames interpretation.
• Concept: Angle + proof strategy + content type (the blueprint).
• Variant: same concept, one controlled change (hook swap, proof swap, pacing,
caption, thumbnail).
If you only remember one thing: the system optimizes concepts, not individual videos.
Videos are executions/variants of a concept.

3

2. Object model (what the database stores)
Your creative system should store finished assets and the ingredients used to build them.

Entities
• ConceptCard: the blueprint (angle, persona, objections, required proof beats, allowed
formats, hook reservoir).
• ProofCard: one claim + the proof source (demo clip, spec, review, screenshot,
guarantee).
• ModuleClip: atomic block (hook, demo, unboxing, cleanup, lifestyle, review overlay,
end card) with crops and transcript.
• Asset: rendered output (video/static/carousel) + copy fields + module references +
tags + performance metadata.
• VariantSet: a family of Assets that share a ConceptCard and differ by controlled
variables.

Why this matters
• Query: show ads that address mess with a demo proof in 9x16 for parents.
• Generate variants mechanically (hook swap + proof swap) without rewriting
everything.
• Learn at the concept/tag level (angle + proof type) instead of guessing from raw video
files.

Minimum fields per Asset (practical)
• Stable ID (asset_id), version, status
• Product line + SKU/variant (if relevant)
• Format + ratio + placement targets
• Funnel intent/stage
• Angle + persona + objection targets
• Hook style + proof types
• Module stack (recipe used) + production notes (tools/models used)
• Performance fields (optional early): spend, impressions, thumbstop, hold, CTR, CPC,
CPA, ROAS

4

3. Tagging system: purpose + rules
Tags are not decoration. Tags are database keys that let you: (1) retrieve assets fast, (2)
generate variants safely, and (3) aggregate learnings.

What tags should let you answer
• What angle is working for each product line?
• Which objections are being resolved (and how)?
• Which proof types drive better early signals (thumbstop, CTR, ATC)?
• Which creative types should we produce more of next week?

Rules
• Use enums whenever possible (predefined values). Avoid free-text fragmentation.
• Keep tags orthogonal: each tag answers one question (angle vs hook style vs proof
type).
• Always tag the why (angle/objection/proof), not just the what (format/ratio).
• When unsure: choose the most central intent of the ad.

Filename convention (parseable)
Use a filename that encodes the highest-importance tags. The system should parse
filename -> tags and tags -> filename.
Template
[Brand]_[ProductLine]_[Format]_[FunnelStage]_[Concept]_[Angle]_[ProofType]_
[HookKey]_[V#]_[Ratio]
Examples (one per product line)
TableClay_mini_wheel_video_tof_pottery_therapy_demo_asmr_calm_V3_9x16
TableClay_travel_mug_video_tof_leakproof_test_demo_spillproof_V1_9x16
TableClay_aesthetic_mugs_carousel_mof_morning_ritual_social_proof_cozy_V2_4
x5

5

4. Tag dictionary (with examples)
Canonical tags your system should store. For key persuasion tags we include example
value libraries by product line.

Identity + placement
asset_id (type: string)
Stable ID (UUID or slug).

product_line (type: string)
High-level product group.
Allowed values: mini_wheel, travel_mug, aesthetic_mugs

product_sku (type: string)
Optional SKU or variant label.

format (type: string)
Allowed values: video, static, carousel

ratio (type: string)
Allowed values: 9x16, 4x5, 1x1

placement (type: array)
Where it is intended to run.

6

Strategy (funnel + persuasion)
funnel_intent (type: string)
Intent stages used in the Table Clay content framework.
Allowed values: discover, validate, decide, commit

funnel_stage (type: string)
Optional shorthand stage label.
Allowed values: tof, mof, bof, rt

angle (type: string)
Angle name (testable persuasion hypothesis).
Examples by product line:
mini_wheel: pottery_therapy, screen_free_family, beginner_confidence, mess_managed,
giftable_date_night
travel_mug: leakproof_commute, keeps_hot, fits_cupholder, handmade_aesthetic, giftable_everyday
aesthetic_mugs: morning_ritual, cozy_home, desk_companion, cute_gift, collectible_drops

persona (type: string)
Primary audience persona.
Allowed values: apartment_adult, beginner_maker, parent, gift_seeker, coffee_commuter,
aesthetic_home
Examples by product line:
mini_wheel: adult_hobbyist, apartment_dweller, parent, gift_seeker
travel_mug: commuter, office_worker, student, gift_seeker, coffee_person
aesthetic_mugs: home_decor, coffee_person, gift_seeker, collector

intent_context (type: string)
User situation / job-to-be-done context.
Allowed values: stress_reset, screen_free_time, coffee_ritual, commute, gift, home_decor

objection_targets (type: array)
Common objection targets by product line:
mini_wheel: space, mess, learning_curve, is_it_real_clay, time
travel_mug: leaks, heat_retention, lid_quality, fragile, cupholder_fit
aesthetic_mugs: breakage, size, dishwasher_safe, price, shipping

7

Creative (hook + proof + offer)
hook_style (type: string)
Allowed values: pattern_interrupt, pov_confession, question, asmr, before_after, myth_bust,
fast_demo, aesthetic_loop
Hook style examples:
asmr, pattern_interrupt, pov_confession, question, before_after, challenge

proof_types (type: array)
Which proof categories are present.
Common proof types by product line:
mini_wheel: demo, outcome, objection_kill, social_proof, specs
travel_mug: test, demo, comparison, social_proof, specs
aesthetic_mugs: social_proof, lifestyle, ugc, specs, risk_reversal

offer_type (type: string)
How the offer is framed (if at all).
Allowed values: none, bundle, free_shipping, limited_drop, giftable, discount

creative_type (type: string)
Creative family/type.
Allowed values: paid_ugc, native_demo, product_cinematic, static_graphic, carousel_micro_lp,
long_form

8

Assembly + production
module_stack (type: array)
Ordered modules used to assemble the asset.

production (type: object)

9

Lifecycle
status (type: string)
Allowed values: draft, qa_failed, approved, live, winner, stale, retired

version (type: string)
Example: v1, v2, v3 or semver.

10

5. Video types + templates (what to produce)
Repeatable formats. Each type has a default module recipe so production and variant
generation stay consistent.

UGC voiceover (no face required)
• Hook (1-2s) -> hands/product demo (6-10s) -> proof beat (3-6s) -> CTA/end card (2-3s)
• Use when: you want speed + authenticity, and the product can be shown clearly.
• Works for: mini_wheel (hands centering clay), travel_mug (spill test), mugs (morning
pour).

Native demo / POV (creator style)
• Hook (confession/question) -> quick demo -> outcome -> objection kill -> CTA
• Use when: you need a relatable scenario (commute, messy kids, noisy brain).

Product cinematic (aesthetic B-roll)
• Hook (visual beauty) -> feature close-ups -> lifestyle moment -> proof overlay -> CTA
• Use when: the product is visually strong (glaze, steam, handmade texture).

Carousel as micro landing page
• Card1: Hook/claim -> Card2: proof/demo -> Card3: social proof -> Card4: offer/CTA
• Use when: you need clarity and structure. Great for mid-funnel validation.

Static (single claim + proof)
• Hero photo -> 1 clear claim -> 1 proof element -> CTA
• Use when: you need fast iteration on copy/proof without video production.

Retarget cutdown (6-10s)
• Take top-performing video -> keep strongest hook + 1 proof beat + CTA
• Use when: warm audiences need a reminder, not a full education.

11

6. Processes (how ads are created)
Two routes: (A) translate an existing ad example, (B) build from scratch via angle-first
planning.

A) Ad example -> new Table Clay ad
• Ingest: save the example and tag it (format, hook style, angle guess, proof type,
objection addressed).
• Extract structure: map beats (Hook -> Demo -> Proof -> Outcome -> CTA).
• Translate: keep structure, swap Table Clay visuals + proof cards (only claims you can
prove).
• Variant plan: controlled swaps (e.g., 3 hooks x 2 proofs x 2 CTAs).
• Render: export ratios (9x16, 4x5, 1x1) and store with tags + filename schema.
• Launch + learn: attribute results back to angle/proof/hook tags.

B) From scratch -> new ad (angle-first)
• Select angle (per product line) + persona + intent context.
• Define proof stack: pick 2-3 proof types required to make the claim believable.
• Create hook reservoir: 10-20 hook lines or hook visuals for the angle.
• Choose a video template: UGC voiceover, native POV, cinematic, carousel, static.
• Assemble module stack and generate variants.
• QA: confirm each claim has attached proof (review/demo/spec).

12

7. Full example records (copy-paste patterns)
Sample Asset records with tags + module stacks. Use as fixtures for testing.

Mini Wheel - Pottery Therapy (UGC voiceover)
Filename: TableClay_mini_wheel_video_tof_pottery_therapy_demo_asmr_calm_V3_9x16
Tags (record):
{
"product_line": "mini_wheel",
"format": "video",
"ratio": "9x16",
"funnel_intent": "discover",
"funnel_stage": "tof",
"angle": "pottery_therapy",
"persona": [
"adult_hobbyist",
"apartment_dweller"
],
"intent_context": "brain_loud_after_work",
"objection_targets": [
"space",
"learning_curve"
],
"hook_style": "asmr",
"proof_types": [
"demo",
"outcome",
"social_proof"
],
"creative_type": "ugc_voiceover",
"offer_type": "starter_bundle",
"module_stack": [
"hook_asmr_spin",
"demo_center_clay",
"outcome_finished_piece",
"proof_reviews_overlay",
"cta_endcard"
]
}
Script/structure:

Hook: 'When my brain gets loud, I do this.' -> hands centering clay -> show tiny piece ->
overlay reviews -> CTA.

Mini Wheel - Screen-Free Family (Native POV)
Filename: TableClay_mini_wheel_video_tof_screen_free_family_demo_parent_relief_V1_9x16

13

Tags (record):
{
"product_line": "mini_wheel",
"format": "video",
"ratio": "9x16",
"funnel_intent": "discover",
"funnel_stage": "tof",
"angle": "screen_free_family",
"persona": [
"parent"
],
"intent_context": "after_school_activity",
"objection_targets": [
"mess",
"learning_curve"
],
"hook_style": "pov_confession",
"proof_types": [
"demo",
"objection_kill",
"outcome"
],
"creative_type": "native_pov",
"offer_type": "gift_or_activity",
"module_stack": [
"hook_parent_confession",
"demo_kid_focus",
"cleanup_easy_wipe",
"outcome_proud_child",
"cta_endcard"
]
}
Script/structure:

Hook: 'Need a screen-free activity that actually holds attention?' -> kid making ->
wipe-down proof -> result -> CTA.

Travel Mug - Leakproof Commute Test (Demo/Test)
Filename: TableClay_travel_mug_video_tof_leakproof_test_demo_spillproof_V1_9x16
Tags (record):
{
"product_line": "travel_mug",
"format": "video",
"ratio": "9x16",
"funnel_intent": "discover",
"funnel_stage": "tof",
"angle": "leakproof_commute",
"persona": [
14

"commuter",
"office_worker"
],
"intent_context": "bag_throw_test",
"objection_targets": [
"leaks",
"lid_quality",
"fragile"
],
"hook_style": "challenge",
"proof_types": [
"test",
"demo",
"specs"
],
"creative_type": "native_demo",
"offer_type": "single_product",
"module_stack": [
"hook_spill_challenge",
"test_shake_in_bag",
"demo_open_no_leak",
"spec_overlay_materials",
"cta_endcard"
]
}
Script/structure:

Hook: 'If this leaks, I'm done.' -> shake test in bag -> open, no leak -> spec overlay -> CTA.

Travel Mug - Keeps Hot (Proof overlay)
Filename: TableClay_travel_mug_video_mof_keeps_hot_test_specs_heat_V2_4x5
Tags (record):
{
"product_line": "travel_mug",
"format": "video",
"ratio": "4x5",
"funnel_intent": "validate",
"funnel_stage": "mof",
"angle": "keeps_hot",
"persona": [
"coffee_person",
"student"
],
"intent_context": "long_study_session",
"objection_targets": [
"heat_retention",
"price"

15

],
"hook_style": "question",
"proof_types": [
"test",
"specs",
"social_proof"
],
"creative_type": "ugc_voiceover",
"offer_type": "single_product",
"module_stack": [
"hook_hot_longer",
"test_temp_readout",
"spec_overlay",
"proof_review_quote",
"cta_endcard"
]
}
Script/structure:

Hook: 'How long does it actually stay hot?' -> temp readout -> specs -> 1 review quote ->
CTA.

Aesthetic Mugs - Morning Ritual Carousel
Filename: TableClay_aesthetic_mugs_carousel_mof_morning_ritual_social_proof_cozy_V2_4x5
Tags (record):
{
"product_line": "aesthetic_mugs",
"format": "carousel",
"ratio": "4x5",
"funnel_intent": "validate",
"funnel_stage": "mof",
"angle": "morning_ritual",
"persona": [
"home_decor",
"coffee_person"
],
"intent_context": "cozy_morning",
"objection_targets": [
"price",
"shipping"
],
"hook_style": "visual",
"proof_types": [
"lifestyle",
"social_proof",
"risk_reversal"
],
16

"creative_type": "carousel_micro_lp",
"offer_type": "limited_drop",
"module_stack": [
"card1_hero_mug_pour",
"card2_handmade_closeup",
"card3_reviews_grid",
"card4_shipping_returns_cta"
]
}
Script/structure:

Carousel: hook image -> handmade texture closeup -> reviews -> shipping/returns + CTA.

Aesthetic Mugs - Giftable Cute Mug (Static)
Filename: TableClay_aesthetic_mugs_static_bof_cute_gift_social_proof_gift_V1_1x1
Tags (record):
{
"product_line": "aesthetic_mugs",
"format": "static",
"ratio": "1x1",
"funnel_intent": "decide",
"funnel_stage": "bof",
"angle": "cute_gift",
"persona": [
"gift_seeker"
],
"intent_context": "birthday_or_valentines",
"objection_targets": [
"breakage",
"shipping"
],
"hook_style": "visual",
"proof_types": [
"social_proof",
"risk_reversal"
],
"creative_type": "static_graphic",
"offer_type": "giftable",
"module_stack": [
"hero_photo",
"badge_reviews",
"shipping_protection_line",
"cta_button_mock"
]
}
Script/structure:

17

Static: hero mug + 'Gift-ready' + reviews badge + shipping protection line + CTA.

18


```
