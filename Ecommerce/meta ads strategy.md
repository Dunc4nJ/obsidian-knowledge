---
created: 2026-02-02
description: Comprehensive Meta ads playbook covering campaign architecture, creative strategy, audience targeting, measurement, and 2026 platform shifts
source: Table Clay Meta Ads Strategy.pdf
type: framework
---

# Meta Ads Strategy

## Key Takeaways

Campaign structure should consolidate around broad CBO prospecting as the primary engine. Rather than fragmenting budget across narrow interest or lookalike audiences, Meta's Andromeda algorithm now uses the creative itself as the targeting signal — making [[advertising angles are testable hypotheses not copywriting|ad angle diversity]] more important than audience segmentation. A "swimlanes" approach (prospecting, engaged, existing) with proper exclusions prevents the algorithm from over-spending on low-funnel repeat buyers at the expense of net-new acquisition.

Creative is the new targeting lever. Static images still drive 60-70% of conversions, but the system rewards format variety: carousels, short video, UGC-style clips, text-only cards, and memes — the kind of sustainable variety that [[content systems beat content calendars when assets are modular tagged and agent-operable]] enables through shared building blocks. Each variant should differ meaningfully (not just headline swaps on the same image) since Meta may treat near-duplicates as a single creative. Dynamic/flexible creative lets Meta mix-and-match headlines, copy, and visuals automatically. Refreshing creative every 2-4 weeks (weekly at higher budgets) prevents fatigue. For video assets, [[ai longform ai videos look real when the starting frame and audio are high quality|starting frame and audio quality]] are the bottleneck for perceived production value.

The learning phase demands patience and incremental changes. New creatives need a 7-14 day test window with a minimum spend floor of roughly 1x target CPA before judging performance. Budget scaling should be gradual (10-20% weekly increases) rather than aggressive doublings. Changing one variable at a time preserves algorithmic stability.

Measurement fundamentals shifted in January 2026 when Meta removed 7-day and 28-day view-through attribution windows. Reported conversions can drop 30-40% from this change alone, so benchmarks need resetting against the new 7-day click / 1-day view standard. Pixel plus Conversions API (CAPI) together is the baseline for accurate tracking — relying on pixel alone misses server-side events and iOS-limited users. New breakdowns (Business AI Breakdown, Conversion Count Breakdown) now distinguish AI-driven vs manual conversions and new vs repeat buyers.

Advantage+ and generative AI are reshaping the production pipeline described in [[advertising works when a content farm feeds modular assets into an agent-driven assembly line]]. Meta's AI can auto-generate creative variations and even convert statics to short video. Early signals suggest AI-generated assets can approach human-made performance. The platform trajectory points toward a model where providing a product URL and budget yields a fully AI-created campaign, reducing the creative bottleneck for small advertisers building with tools like [[shadcn component libraries let you ship ecommerce sites faster|component-based storefronts]].

Placement should default to All Placements (Advantage+). Restricting to specific surfaces (only Feed, only Reels) increases cost. Meta auto-crops and resizes assets for each format, so the priority is providing high-quality source files at the right specs: 1080x1080 minimum for square/4:5, 1080x1920 for vertical stories/reels, MP4 H.264 for video.

## External Resources

- [Social Media Examiner: Facebook Ad Algorithm Changes for 2026](https://www.socialmediaexaminer.com/facebook-ad-algorithm-changes-for-2026-what-marketers-need-to-know/) — practitioner analysis of Andromeda algorithm and campaign structure
- [Lebesgue: Broad or Lookalike Audience Targeting](https://lebesgue.io/facebook-ads/broad-targeting-beats-lookalikes-the-future-of-facebook-audience-targeting) — data on broad vs lookalike audience ROAS
- [Dataslayer: Meta Ads Attribution Window Changes 2026](https://www.dataslayer.ai/blog/meta-ads-attribution-window-removed-january-2026) — breakdown of Jan 2026 attribution removal impact
- [Benly: Advantage+ 2026 Updates](https://benly.ai/learn/meta-ads/advantage-plus-updates-2026) — new AI creative generation features
- [Shopify: Facebook Ad Sizes and Specs 2026](https://www.shopify.com/blog/facebook-ad-sizes) — current ad format specifications
- [HackMD: Meta Events Manager Guide](https://hackmd.io/@agrowthagency/rJ-4LYD7be) — CAPI setup and event tracking

> [!quote]- Source Material
>
> Table Clay Meta Ads Strategy
> Existing Creative System (from provided docs)
> - Angles & Hooks: An angle is defined as a strategic lens or testable hypothesis (audience, context, objection) through which the product is positioned. A hook is the attention-grabbing first 1-3 seconds of an ad (e.g. a surprising stat, quick demo, or emotional question). Each concept combines an angle + proof approach + format. An asset is one implementation of a concept (ad creative with visuals, copy, CTA). Variants are controlled variations of a concept (e.g. same angle but different image, hook, or proof element).
> - Proof Strategy: Each angle is paired with a proof or evidence approach (demo, testimonial, stats, expert endorsement) to overcome objections. Moments of proof (e.g. "see it working," "user testimony," "data" shots) are planned to build trust.
> - Content Taxonomy: Uses the "Total Content Library" taxonomy of Organic / Paid / Shared building blocks. Organizes content into pillars (e.g. "skill progress," "mess-free fun," "creative gift") and sub-themes.
>
> Campaign Architecture
> - Broad CBO Prospecting: Meta favors broad targeting with Campaign Budget Optimization/Advantage+. New creatives grouped by launch date compete under one budget.
> - Graduated Scaling & Swimlanes: Winning ads graduate into a dedicated scale campaign. Separate campaigns run retargeting and retention. "Swimlanes" structure (new, engaged, existing) controls budget mix.
> - Manual vs Advantage+: Many mid-size advertisers test hybrid approaches. Industry moving toward simpler, consolidated structures.
>
> Learning Phase & Iteration
> - Stability Before Change: Significant edits reset the learning phase. Follow a 1-2 week test period after launching new creatives.
> - Incremental Budgeting: Set minimum spend per ad set equal to ~1x target CPA for 7-10 days. Remove minimum after trial so CBO can reallocate organically.
> - Budget Increases & Edits: Scale gradually (+10-20% weekly). Change one variable at a time.
>
> Creative Strategy on Meta
> - Creative as Targeting: Under Andromeda, creative content is the signal that finds the right audience. Static images still drive ~60-70% of conversions. Also test short videos, carousels, GIFs, Reels, text-only cards, and memes.
> - Variety & Frequency: Rotate creatives every 2-4 weeks. Each variant should differ clearly. Use dynamic/flexible ads for auto-iteration.
> - Placement Adaptation: Use All Placements by default. Meta auto-crops/resizes for each format.
> - Specs: 1080x1080px minimum for square/4:5, 1080x1920px for vertical. Video MP4 H.264/AAC. Keep text minimal.
>
> Audience Strategy
> - Prospecting: Lean into broad audiences first. Exclude existing purchasers and engaged segments.
> - Retargeting: Continue retargeting engaged users (video viewers, cart adders, site visitors). Tailor creative differently.
> - Exclusions: Always exclude bottom-funnel from top-funnel spend. Monitor Audience Breakdown report.
>
> Measurement & Attribution
> - Event Tracking: Pixel + CAPI combined. Configure 8 standard events in priority order. Send event_id for dedup.
> - Attribution: Meta default is 7-day click/1-day view. Jan 2026 removed all 7d/28d view-through attribution.
> - New Metrics: Business AI Breakdown, Conversion Count Breakdown for new vs repeat buyers.
>
> Trend Radar
> - Jan 2026: Attribution window removal, deprecated targeting options paused, ~30-40% reported conversion drop.
> - Generative AI: Advantage+ Creative auto-generates variations. Meta hints at Generative Ad Model (GEM).
> - Privacy: EU Digital Markets Act rolling out personalized vs less-personalized ads choice.
>
> [Source: Table Clay Meta Ads Strategy.pdf](/data/projects/bananabank/Docs/Table Clay Meta Ads Strategy.pdf)

For the competitive research workflow that feeds this strategy, see [[meta ad library research finds winners through longevity signals creative families and angle extraction]].
