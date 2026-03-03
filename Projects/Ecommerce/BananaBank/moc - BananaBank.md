---
created: 2026-01-31
description: Automated content creation system — ads, Instagram posts, and marketing collateral for ecommerce brands
source: internal
type: moc
---

# BananaBank

## Status

- **Active work**: Planning phase — not yet implemented
- **Blockers**: None
- **Last updated**: 2026-01-31

## Key Decisions

(none yet — project in planning)

## Navigation

### Core Notes

- [[advertising angles are testable hypotheses not copywriting]] — foundational framework for angle ideation, scoring, and translation into paid assets
- [[content systems beat content calendars when assets are modular tagged and agent-operable]] — three-pillar content architecture with modular tagged assets and agent roles
- [[advertising works when a content farm feeds modular assets into an agent-driven assembly line]] — seven-agent production pipeline operationalizing the content system
- [[copy strategy converts when a messaging hierarchy voice chart and channel matrix anchor every asset to one promise]] — messaging hierarchy and voice framework constraining all copy output
- [[meta ads strategy]] — campaign architecture, creative strategy, and measurement for Meta platform
- [[recursive skill loops improve marketing outputs by generating scoring diagnosing and iterating until thresholds are met]] — generate→evaluate→improve loops with explicit scoring criteria for consistent creative output
- [[meta ad library research finds winners through longevity signals creative families and angle extraction]] — competitive research playbook with Table Clay worked examples
- [[ads become searchable and remixable when structured as concept-module-asset-variant objects with enum tags]] — four-entity object model with enum tags for querying and mechanical variant generation
- [[agentic image generation loop]] — generate→annotate→refine workflows for producing visual assets in agent pipelines

### Architecture & Protocol

- [[PROTOCOL]] — shared protocol governing agent/worker interaction with brand data (implements [[skill architecture beats skill writing when memory contracts and learning loops connect the system|boringmarketer's skill architecture]])
- [[skill-architecture-integration-plan]] — full plan mapping the 5 skill architecture patterns to BananaBank's multi-agent pipeline

### Brand Context (per-brand, see Protocol for structure)

- TableClay: `Projects/Ecommerce/Business/TableClay/Brand/` — [[voice-profile]], [[positioning]], [[audience]], [[product-catalog]], [[creative-kit]], [[learnings-log]], [[assets-registry]], [[context-manifest.yaml]]

### Learnings

(none yet)

### Drive Imports

- [[Table Clay Ad Structure + Tagging Spec v3 (Readable)]] — PDF spec (object model + tag dictionary + templates)
- [[Table Clay Tag Dictionary v2 (JSON)]] — JSON schema for tag vocabulary

## Parent

- [[moc - Ecommerce]]

## Open Questions

- Content generation pipeline: which AI models/tools for ad creative, copy, and imagery?
- Target platforms: Instagram, Facebook, TikTok, Google Ads — which first?
- How to integrate with [[moc - TableClay]] product catalog for automated ad generation?
- Content approval workflow: fully automated vs. human-in-the-loop review?
- Brand voice/style consistency enforcement across generated content
