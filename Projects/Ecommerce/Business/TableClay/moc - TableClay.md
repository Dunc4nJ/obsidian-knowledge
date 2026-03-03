---
created: 2026-01-31
description: Handmade ceramics/pottery ecommerce store built on Medusa v2 + Next.js 15
source: internal
type: moc
---

# TableClay

## Status

- **Active work**: Live at tableclay.com — active development
- **Blockers**: None
- **Last updated**: 2026-01-31

## Key Decisions

- Medusa v2 headless commerce for backend flexibility and customization
- Next.js 15 (React 19) storefront with App Router on Vercel
- Railway for backend hosting (PostgreSQL + Redis)
- Stripe for payments, Omnisend for email marketing
- S3 for media storage
- Yarn 3 (Berry) monorepo structure

## Navigation

### Core Notes

- [[mini wheel content strategy converts when proof beats match the five persona objections]] — Product-specific content strategy research: 5 personas, 6 JTBD, 18 angles, UGC briefs, and shared building blocks for the Mini Pottery Wheel Starter Bundle
- [[meta ad library research finds winners through longevity signals creative families and angle extraction]] — Ad Library research playbook with Table Clay worked examples
- [[copy strategy converts when a messaging hierarchy voice chart and channel matrix anchor every asset to one promise]] — messaging hierarchy and voice framework with Table Clay case study
- [[ads become searchable and remixable when structured as concept-module-asset-variant objects with enum tags]] — Table Clay ad structure and tagging spec: four-entity object model with enum tags for all product lines
- [[advertising works when a content farm feeds modular assets into an agent-driven assembly line]] — seven-agent production pipeline operationalizing the content system for Table Clay campaigns
- [[advertising angles are testable hypotheses not copywriting]] — systematic framework for angle ideation, scoring, and creative translation with Table Clay examples
- [[shadcn component libraries let you ship ecommerce sites faster]] — component kits for fast storefront iteration

### Product Research Dossiers

- [[custom pet mug wins at the intersection of pet humanization personalized gifts and artisan ceramics]] — Deep research dossier: competitive teardown, VoC analysis, 13-objection kill sheet, 10 ad angles, pricing/bundling
- [[ceramic travel cup owns the handmade-plus-accessible gap in a 17 billion dollar market]] — Deep research dossier: 12-competitor analysis, taste science positioning, 14-objection kill sheet, 10 ad angles
- [[mini pottery wheel starter bundle captures the craft therapy and screen-free education convergence]] — Deep research dossier: 7-category market map, 10-competitor teardown, 15-objection kill sheet, 15 ad angles

### Operations

- [[stripe best practices audit for TableClay]] — Stripe integration audit: deprecated methods, API version pinning, PaymentElement migration

### Learnings

(none yet)

## Parent

- [[moc - Business]] > [[moc - Ecommerce]]

## Open Questions

- Marketing strategy priorities (UGC, influencer, paid ads)?
- Catalog expansion plans?
- Integration points with [[moc - BananaBank]] for automated content

Code: `/data/projects/tableclay`
Store: https://tableclay.com
