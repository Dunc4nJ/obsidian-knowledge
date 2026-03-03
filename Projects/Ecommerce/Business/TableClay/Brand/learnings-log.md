---
created: 2025-07-17
owner: all
write_policy: append-only
last_updated: 2026-02-27
description: Append-only log of creative outcomes, campaign results, and operational learnings for TableClay.
source: internal
type: brand-context
---

# Learnings Log — TableClay

> This file implements the **Learning Loops** pattern from [[skill architecture beats skill writing when memory contracts and learning loops connect the system]]. Append-only — any agent or pipeline worker can add entries. Never edit or truncate existing entries.

## Format

Each entry follows this structure:
```
## YYYY-MM-DD | Category | Short Title
- Stage: (which pipeline stage / activity)
- Result: a (shipped as-is) / b (minor edits) / c (rewrote significantly)
- Outcome: (what happened — metrics if available)
- Lesson: (what to do differently / repeat)
- Tags: (relevant enum tags from tag dictionary)
```

---

<!-- Append new entries below this line -->

## 2026-02-27 | Research | Mini Pottery Wheel Kit — Product Research Dossier Complete
- Stage: product-research
- Result: a (full 9-file dossier produced)
- Outcome: Full research dossier with 30+ sources, 25+ verbatim quotes, 10 competitors, 15 objections, 4 personas, 15 ad angles
- Lesson: The $70–120 price range for complete wheel+kit bundles is completely empty — major white space. No competitor combines a branded wheel + clay + tools + guides. The #1 objection is mess concern, not price. Therapeutic/wellness positioning outperforms hobby positioning in this category. DTC clay-only kits (Sculpd, Pott'd) prove the demand but lack a wheel; Amazon wheels prove the hardware demand but lack branding/experience. TableClay can own the intersection.
- Tags: product-research, competitive-analysis, voc-mining, positioning

## 2026-02-27 | Research | Cloud Mug — Product Research Dossier Built
- Stage: product-research
- Result: a (full 9-file dossier produced)
- Outcome: Completed Cloud Mug dossier (market, competitors, VoC, objections, personas, messaging, pricing) with 30+ source references and pricing/bundling playbook.
- Lesson: Category has a clear white-space: handcrafted cloud-form mugs at accessible premium pricing (~$32–40) between mass-market Amazon cloud mugs and premium boutique options. The biggest conversion levers are size transparency (avoid 6–7oz surprise), value proof through ritual transformation, and strict packaging-trust messaging.
- Tags: product-research, competitive-intelligence, pricing-strategy, ad-strategy
