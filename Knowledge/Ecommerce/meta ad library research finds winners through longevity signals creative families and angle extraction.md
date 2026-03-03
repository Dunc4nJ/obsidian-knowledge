---
created: 2026-02-02
description: A structured playbook for using Meta Ad Library as a competitive research tool, with SOPs for spotting likely winners via longevity and variant signals, extracting promise-pain-proof-hook-offer-objection patterns, and feeding findings into a content-to-ads loop
source: Meta Ads Library Playbook (with Table Clay examples).pdf
type: framework
---

## Key Takeaways

The Meta Ad Library is a transparency tool that shows only currently active ads in the US — there is no historical archive outside the EU (where ads persist for 12 months after last impression). This means competitive research is inherently time-sensitive: if you don't capture creative assets locally when they're live, they vanish permanently once the campaign pauses. The playbook enforces a "screenshot immediately, never bookmark Library URLs" discipline that connects to the asset management infrastructure in [[content systems beat content calendars when assets are modular tagged and agent-operable]], where every captured asset gets tagged with format, funnel stage, angle, and proof type for retrieval.

Since the Ad Library exposes no performance metrics (clicks, conversions, spend) outside the EU, the playbook relies on proxy signals to identify likely winners: longevity (ads running weeks or months suggest they're hitting KPIs), creative families (multiple variants of the same angle indicate active A/B testing and investment), offer persistence (the same discount or bundle deal appearing across many ads), and format breadth (the same concept adapted to video, static, carousel, and multiple placements). These are heuristics, not guarantees — long-running ads can also be low-budget retargeting or forgotten campaigns. The playbook pairs each signal with an explicit failure mode and validation test, which mirrors the claim-safety discipline in [[advertising angles are testable hypotheses not copywriting]] where every assertion maps to a proof type.

The angle extraction framework decomposes every captured ad into six elements: Promise (the benefit), Pain (what the audience wants to escape), Hook (the first 1-3 seconds or line), Proof (testimonial, demo, stat, authority), Offer (discount, bundle, guarantee), and Objection (the doubt addressed in the creative). This maps cleanly onto the Concept Card structure in the [[content systems beat content calendars when assets are modular tagged and agent-operable|content strategy reference]] where each concept encodes angle + proof strategy + format. The playbook includes worked examples for Table Clay's Mini Pottery Wheel (Kid Creativity, Mindful Stress Relief, Unique Gift angles) and Ceramic Travel Mug (Perfect Coffee, Artisan Style, Gift angles), each with all six elements filled out — providing concrete templates that connect directly to the 18 angles developed in the [[mini wheel content strategy converts when proof beats match the five persona objections|Mini Wheel research artifact]].

The operational workflow is a weekly SOP: 60-90 minutes scanning 2-3 competitors, immediate capture to a structured log (Brand, Ad ID, Date, Angle, Hook, Offer, Proof, Format), building separate Angle and Proof backlogs from the log, then picking 1-3 top angles to test each week. This feeds the organic-to-paid loop described in [[advertising works when a content farm feeds modular assets into an agent-driven assembly line]], where organic content generates proof moments and hooks that graduate to paid campaigns when they show traction, and winning paid angles become evergreen organic series.

The "low count" label (ads with fewer than 100 impressions) is a newer Ad Library feature that distinguishes active tests from scaled campaigns. Filtering these out focuses research on creatives that have survived initial testing — a useful signal when building competitor intelligence. The playbook also covers the Ad Library API for automating weekly competitor scrapes and alerting on new creative launches, which is the programmatic extension of the manual SOP.

A cross-brand convergence signal — multiple unrelated brands independently running ads with the same hook or angle — is treated as stronger evidence than any single brand's longevity. When two competitors both discover "DIY gift for parents" independently, the angle is likely validated by real market demand. This connects to the broader [[meta ads strategy]] principle that creative variety is the primary targeting lever under Meta's Andromeda algorithm: discovering proven angles through competitive research de-risks the creative variety you feed into your own campaigns.

## External Resources

- [Meta Ad Library](https://www.facebook.com/ads/library/) — official active ad transparency tool
- [Meta Ad Library API](https://www.facebook.com/ads/library/api/) — programmatic access for automated competitor monitoring
- [Swipekit: Definitive Guide to Facebook Ad Library](https://swipekit.app/articles/facebook-ads-library) — practical walkthrough of filters, saving assets, and organizing research
- [Midsummer Agency: How to Use Meta Ads Library](https://midsummer.agency/blog/meta-ads-library/) — competitor analysis workflow with creative family identification
- [Sachit Sharma: Ad Longevity Not Always a Profitability Indicator](https://www.linkedin.com/posts/sachit-sharma-deepsolv_does-a-long-running-facebook-ad-automaticallyactivity-7413881978380517377-Y15u) — nuances of using ad longevity as a winner signal
- [Conor Crummey: Meta Ads Library Labels Low-Count Ads](https://www.linkedin.com/posts/conor-crummey-825b871b0_meta-ads-library-just-got-a-lot-more-interestingactivity-7417225729031200768-q-jU) — new low-count label for filtering test creatives
- [Marketing Week / Ritson: Brand-Building Ads Boost Short-Term Sales](https://www.marketingweek.com/ritson-brand-building-boost-short-term-sales/) — brand vs performance advertising evidence
- [Francesca Tabor: Running Viral DTC Ads — Stake's Strategy](https://www.francescatabor.com/articles/2025/8/1/playbook-running-viral-dtc-ads-on-x-twitter-lessons-from-stakes-strategy) — high-volume trend-driven content strategy for DTC
- [SocialMediaTransparency.org: US vs EU Ad Library Transparency](https://www.socialmediatransparency.org/blog/advertising-library-transparency-comparing-the-us-and-the-eu) — comparison of data retention and transparency rules
- [Google: Digital Video for Sales and Long-Term Growth](https://business.google.com/us/think/search-and-video/brand-building-performance-marketing-digital-video/) — brand + performance hybrid evidence

## Original Content

> [!quote]- Source Material
> **Meta Ads Library Playbook (with Table Clay examples)**
>
> Meta Ads Library is a powerful (and free) competitive-research tool, but it has quirks. This playbook walks through how it works, how to spot likely winning ads, and how to turn those insights into Table Clay's creative/content strategy. We cover practical SOPs, templates, and routines. Every recommendation is tagged FACT / LIKELY / OPINION with evidence, failure modes, and tests to validate.
>
> **A. How Meta Ad Library Works (and Misreads to Avoid)**
> - Ad Library = active ads only (US): Meta's Ad Library (US) shows only ads currently running on Facebook/Instagram. (EU-targeted ads run in the last year are archived for 12 months, political ads 7 years.) FACT: Only active non-political ads appear (outside EU). Reason: It's designed for transparency of live ads. Failure: If you filter "active only," finished but effective ads vanish. Test: Try filtering "inactive" -- in the US it usually yields nothing (because non-EU history isn't stored).
> - Delay and expiration: Any ad appears in the Library within ~24 hours of its first impression (Meta docs). Links to specific ads expire once the ad stops -- you'll get 404 if the campaign paused. Reason: Once an ad ends (or account pauses it), it's removed from public view. Failure: Bookmarking ad URLs doesn't work long-term. Fix: Always screenshot or save media locally, don't rely on Library links.
> - What you see: For each ad you get the image/video and all copy (headline, text, CTA). You can see the publisher page name, start date, and placement (FB vs IG). You do not see performance data (no clicks, conversions, or spend except for EU/DSA data). FACT: The API returns creative content, page info, dates, platform. Misread: Treating Library "views" as metrics is impossible -- it shows content only. Validate: Trust only the ad creative and copy text; ignore missing metrics.
> - Active status filter: By default "Active" is on, showing only currently running ads. You can toggle to "All" or "Inactive," but outside EU you'll find almost nothing inactive. OPINION: In practice, use "Active" filter only; treating older ads as winners is only possible if EU-targeted. Failure: Thinking an inactive listing means it ran globally -- often it was just EU or a glitch.
> - Geography and category: Always set the correct Country filter for your market (e.g. US). Set "Ad Category" to All Ads to include commercial campaigns (not just politics). This focuses on relevant brand ads. Failure: Mistakenly browsing "Issues or Politics" yields irrelevant results. Test: Ensure Country matches your market and category is "All Ads."
> - Other filters: You can filter by language, platform (FB, IG, etc.) and media type (image vs video). Use these to narrow scope. For example, filter to English if needed. TIP: A clever "language hack" is to switch language to another (e.g. Spanish) to see global brands' unlaunched hooks.
> - Data retention: FACT: In EU/UK, Meta archives ads for 1 year after last showing; in the US (non-politics) there is no guaranteed retention beyond active. Failure: If you search a US brand later, their old ads are gone. Test: If a competitor's ad vanished quickly after stopping, you'll not find it again (unless they target EU).
>
> **B. "Winning Ad" Proxies (Signals of a Likely Winner)**
> We can't see conversion data, so we look for signals or heuristics that suggest an ad is working. These are LIKELY but not guarantees. Always cross-check with context.
> - Longevity: Likely: Ads running for weeks/months often indicate winners. Reason: Brands quickly kill losing ads, so long-running creatives usually hit target KPIs. Failure mode: Long run could mean low $/day test, retargeting ad, or simply forgotten. As Sachit Sharma notes, long-running ads can be misleading (e.g. $5/day tests, wrong optimization, or ads left live to confuse competitors). Validate: Check for "fresh engagement" -- if comments/likes keep coming, that's stronger proof. Also look if new variations of the same angle are still launching.
> - Creative families and variants: FACT: Brands often duplicate a winning ad into "families" of similar creatives. If you see multiple ads for the same product with only minor tweaks (hook phrasing, image, placement), it means they're A/B testing. The version(s) kept longest likely perform best. Failure: An ad with no variants might simply be a one-off experiment. Validate: Note how many similar ads share the same angle. A deep creative system (multiple textures of one theme) is a good sign of investment.
> - Consistency of message: LIKELY: A consistent angle or offer repeated across ads implies it works. For example, if a brand's ads all promise stress relief through pottery, they probably found that messaging resonating. If the core benefit/offer remains the same (e.g. "25% off starter kit" appears in many ads), it's likely converting. Failure: Sometimes brands stick to a theme even if it's underperforming; always pair with actual results. Validate: Look at ad text and visuals -- does the promise/pain and offer repeat verbatim? If yes, test a similar pitch yourself.
> - Offer persistence: LIKELY: If a discount or bundle deal stays unchanged in many ads, it likely drives conversions. For example, a repeated "Free shipping + bonus clay pack" offer across a campaign is a clue. Failure: It could just be a standard margin cushion. Validate: Compare to seasonal promotions -- if offer never disappears even on non-holidays, it's probably a steady performer.
> - Breadth of testing (formats and placements): LIKELY: Brands confident in an angle will test it in multiple formats (video, static, carousel) or placements (Feed, Stories, Reels). Reason: They're probing where it resonates most. Failure: Conversely, if they only run one format and never repurpose it, perhaps they haven't really scaled. Validate: If you see the same creative in both an IG Reel and a Facebook banner, assume they're scaling that angle.
> - Cross-brand signals: LIKELY: Watch for convergence -- if multiple brands in ceramics (or analogous niches) run ads with similar hooks (e.g. "DIY gift for parents"), that angle is trending. Reason: Independent discovery of the same idea means it's likely tested. Failure: Could also be herd mentality. Validate: If two unrelated brands use the same promise, test it cautiously in your style; but ensure it fits Table Clay's unique tone.
> - Account health: OPINION: Healthy ad accounts have coherent brand pages (good profile, reviews, steady posting) and a steady ad cadence. If a page has a hundred ads one month then zero next, or ads with bad grammar, it may be lower-quality. Note the new "low count" flag: Meta now labels ads with fewer than 100 impressions as "low count." As one marketer observes, that flag quickly shows "which creatives are stuck in testing and whether the account is cleanly structured." A page with many "low count" tests suggests they're iterating fast (good), whereas an account with few active ads but many low-count tests may be disorganized. Failure: A polished look doesn't guarantee conversion -- just a higher probability of trust.
> - Ad Library scorecard (refinement): LIKELY: You can use a quick scoring heuristic: rate ads on longevity, diversity of variants, clarity of hook, strength of offer, and social proof. High-scoring ads (e.g. 10/15 or above) are "safe bets" to adapt. Reason: It codifies the above signals. Failure: It's still guesswork -- treat as guidance, not gospel. Validate: Use the scorecard on known winners (from your own data, if possible) to calibrate the rubric.
>
> **C. Building a Smart Competitor Set**
> - In-League vs. Out-of-League: OPINION: Focus first on "in-league" competitors -- brands of similar size/channel to Table Clay (other DTC pottery/ceramics kits and mugs). They share budgets and audience. Also scan a few "out-of-league" players (e.g. large craft retailers or big home decor brands) for ideas, but don't slavishly copy their high-gloss production (scale back to DTC level).
> - Adjacent / "Job-to-be-done" competitors: LIKELY: Include brands solving the same customer needs in different ways. For example, a travel mug competes not just with coffee-brand mugs but also with premium thermos or reusable water bottles. Table Clay's pottery wheel might compete with "kids STEM kits" or "adult DIY art kits" for the gift / creativity angle. As one guide notes, "indirect competitors often reveal creative ideas and emotional hooks that can inspire your own campaigns without directly copying your niche." Failure: Don't drift too far -- tangents are for inspiration only.
> - Brand positioning filter: FACT: Use Mark Ritson's branding insight: avoid letting Table Clay become a commodity. If every competitor is pitching "low price," you might position on premium craftsmanship. (He notes brand advertising achieves both sales and long-term growth, while pure sales ads do not.) When choosing competitors, pick some who compete on brand (story, quality) vs those who go hard on discounts, to see different strategies.
> - Regional/Seasonal: Include any big seasonal or geography-specific players. E.g. if Table Clay ever sells in Europe, track EU-based ads (they'll be archived longer). Seasonal gift brands (Holiday-themed ads) can indicate upcoming trends.
>
> **D. Meta Ads Library Workflow (Daily/Weekly SOP)**
> 1. Set filters: Go to Meta Ads Library. Set Country=US (or your market) and Category=All Ads. Keep "Active Only" toggled on (default). Optionally filter Platform (e.g. Instagram) or Media type if researching format strategies.
> 2. Search by brand or keyword: Enter a competitor brand name or product keyword. You can also try layered searches (e.g. "pottery wheel AND kids") to discover unexpected players. TIP: Switching the language filter can reveal international tests of big brands (they often pilot hooks abroad).
> 3. Quick scan and capture: Open each ad result that looks relevant. Immediately save key details: screenshot the creative (or use an extension tool) and copy the primary text. Save these to your ad-log (see Templates below). For each ad, record: brand, date found, Angle/Theme (a short tag of the ad's main idea), Hook snippet (first line or scene), Offer/Price (if any), Proof (testimonials, stats, awards shown), format (video/static) and placement.
> 4. Label whether it's "New" or "Seen": If you've captured this ad before, skip; otherwise log it. This avoids redundant work. Pro tip: scrapekit-like tools flag new ads by ID.
> 5. Scan for creative families: While browsing one brand's results, note patterns: e.g. a series of ads all promising "creative fun for kids" or all showing gift-wrap. That's a creative family. Tag those ads with the same Angle label in your log. Check if some variants are much newer (fresh angles) vs old (tried-and-true).
> 6. Use "Low Count" clue: The library UI now labels ads with fewer than 100 views as "low count." These are clearly tests, not final campaigns. In your scan, ignore low-count variants except for noting new angles. Focus on the non-low-count ads as your likely winners.
> 7. Screenshot and organize: Always download or screenshot the creative -- don't rely on the Library link (which will break when ad stops). Name files systematically (e.g. Brand_Angle_Date.png). Store them in a shared folder (Google Drive/Notion) categorized by week or competitor.
> 8. Tag quickly with minimal taxonomy: Use just a few key tags or a short phrase per column. For example, Angle = "Kid Creativity," Hook = "Watch Mia spin...," Offer = "20% off starter kit," Proof = "Customer review quote." The goal is speed.
> 9. Build angle and proof backlogs: After capturing ads, skim your log and pull out the distinct angles (promises) and proofs into separate lists. For example, angle "DIY skill-building toy" may appear multiple times. Maintain an Angle Backlog (one line per unique angle/hook) and a Proof Backlog (testimonials, awards, stats etc. you saw). This directly feeds your content ideas.
> 10. Prioritize what to test: Pick 1-3 top angles from your backlog each week. Choose ones with strong signals (long-running, repeated, aligned to Table Clay's brand). Write a brief creative plan for each: e.g. "Test angle 'Stress relief' (pain: daily stress at work) with a video hooking on a tired office worker kneading clay -- offer free shipping." Avoid paralysis: if an angle doesn't immediately resonate as distinct, skip it.
> 11. Weekly review: Schedule a ~60min session (e.g. Monday) to update and cull. Search 3-5 competitor brands again and add any new ads to the log (use copy-paste if you keep weekly sheets). Update any angles/offers that have changed (e.g. a new discount code). Review last week's log: delete duplicates, refine tags, and bump promising angles to the top of the backlog. Share key findings in a quick one-pager for the team.
> 12. Stay on schedule: Avoid rabbit holes. Limit each scan to 1h or 3 competitors max. If you see a swath of similar ads, move on to another brand. Use the "scorecard" rubric (or similar gut check) to stop digging on an angle after collecting enough examples. The goal is actionable ideas, not perfection.
>
> **E. Angle Extraction (Promise, Pain, Proof, Hook, Offer, Objection)**
> For each saved ad, break down its creative into these elements. Write them in plain terms. Example templates for Table Clay's products:
>
> Mini Pottery Wheel Starter Bundle:
> - Angle #1: Kid Creativity and Screen-Free Fun
>   - Promise: Let kids unleash creativity, not screen time.
>   - Pain: Bored kids glued to tablets.
>   - Hook: (Video/text opens on a frustrated child: "Another rainy day at home..." or text like "Tired of your child staring at screens?")
>   - Proof: "Over 5,000 families tried it" / kid smiles holding a mug they made.
>   - Offer: "Starter Bundle" (wheel + tools + clay) often with free shipping or 10% off.
>   - Objection: "Messy play?" (Video shows easy-clean clay and protective mat.)
> - Angle #2: Mindful Stress Relief for Adults
>   - Promise: Transform stress into creativity.
>   - Pain: Daily grind, burnout after work.
>   - Hook: (First shot: a harried adult at desk; text: "Feeling stressed? Watch this.")
>   - Proof: Montage of calm pottery shaping, tagline "Meditation in motion" (or review: "I've never felt this relaxed!").
>   - Offer: "30-day money-back guarantee" + bundle discount.
>   - Objection: "I'm not artistic." (Countered by "If you can draw a circle, you can pottery" tagline.)
> - Angle #3: Unique Gift and Family Bonding
>   - Promise: Memorable DIY gift for family/friends.
>   - Pain: Generic gifts lack personal touch.
>   - Hook: (Scene: unwrapping a pottery wheel; child hugging parent: "Best gift ever!")
>   - Proof: Text overlay "As featured on Today Show" or "Instant family favorite" + user photo.
>   - Offer: "Holiday Special: Gift bundle + gift wrap" / Buy 2 get 1 free promotion.
>   - Objection: "Too late for Xmas?" (Show Express Shipping, or "Order by Dec 20th for X-mas delivery.")
>
> Ceramic Travel Mug:
> - Angle #1: Perfect On-the-Go Coffee
>   - Promise: Keeps coffee hot for hours, no spills.
>   - Pain: Burnt lips or cold coffee in morning commute.
>   - Hook: (Quick clip of mug in coffee shop van, text: "Cold coffee... never again.")
>   - Proof: Customer review screenshot: "KEEPS IT HOT ALL DAY!" or demo pouring vs no leaks.
>   - Offer: "Free lid with each mug" + 15% off first order.
>   - Objection: "Plastic taste?" (Feature: 100% ceramic lining, BPA-free.)
> - Angle #2: Artisan Style Meets Function
>   - Promise: A handmade mug as unique as you are.
>   - Pain: Boring generic designs, not eco-friendly.
>   - Hook: (Show artist glazing a mug: "Your coffee deserves better.")
>   - Proof: Stamp or certificate "Handcrafted in [Studio Name]" + aesthetic close-ups.
>   - Offer: "Limited edition color + 20% bundle discount."
>   - Objection: "Pricey?" (Emphasize durability and heirloom quality, compare $/cup to disposable.)
> - Angle #3: Perfect Gift for Coffee Lovers
>   - Promise: The only mug they'll ever need.
>   - Pain: Running out of mugs or using paper cups.
>   - Hook: (Video: someone smashing a cheap mug, then lifting durable Table Clay mug with grin.)
>   - Proof: Social proof: "Over 10,000 mugs sold on Amazon (4.8 stars)".
>   - Offer: "Buy 2 get 1 free (great for gifts)".
>   - Objection: "What about holidays?" (Seasonal variant: "Holiday edition colors available").
>
> Use these examples as templates: extract each element for any ad you log. Tag the angle in your backlog (e.g. "Kids creativity", "Mindfulness", "Gift-wrapping"). The more concrete the promise/pain pair and the hook, the stronger your creative idea will be.
>
> **F. Connecting Ads to Table Clay's Content Strategy**
> Treat your organic content and paid ads as parts of one system:
> - Organic content as proof and hooks: Regularly film and post authentic "proof moments" that can become ad hooks. For example: beginners making their first pot, satisfying ASMR clay sessions, kids giggling at their creation, unboxings, studio BTS, etc. These become short videos (Reels/TikTok) with trending audio. They provide proof (real reactions, testimonials) and visual hooks (mesmerizing clay shots, smiles) that you can repurpose into ads.
> - Paid ads as angle tester: Use paid campaigns to stress-test those organic hooks/angles on a broader audience. For each new organic video (e.g. "mom gifts daughter wheel"), test with a small ad spend to gauge CTR/engagement. High performers then graduate to full campaigns. The ads you find in the Library give inspiration for these angles; your own creative can be more authentic (real customers) but framed similarly.
> - Winners to organic pillars: Once an ad angle proves winning, make it an evergreen piece of content. For example, if "Mindful adult hobby" works, create a regular video series ("Pottery Tuesdays: stress relief edition"). Re-post variations on social media as un-sold content and ads. As Mark Ritson advises, this hybrid of brand story (organic) and sale pitch (ads) builds the brand long-term while driving sales.
> - Weekly content tips: Each week, film a content batch focusing on likely angles and proof: e.g. one video of "kid using wheel," one of "adult winding down," one of "packing an order," one of "customer review quote on screen," one of "Christmas gift reveal." Keep a simple content farm mindset: publish frequently and nimbly. Use trending formats (Reels, TikTok) and repurpose the best into ads.
> - Organic to paid loop: Use Instagram/TikTok as a testing ground for hooks. If a reel goes viral (lots of likes/views), consider turning it into a paid ad variant. Conversely, run ads with user-generated content (UGC): amplify real testimonials from organic posts, showing "This pot my daughter made, thank you Table Clay." This tightens the loop of proof.
>
> **G. Meta Ads Library API (non-technical overview)**
> Meta's Ad Library API lets you automate what we do manually above (no coding steps here, just concepts):
> - What it enables: You can programmatically query the Ad Library for all active ads of a brand or keyword. For EU/UK-targeted ads (last year) or social-issue ads, it can pull creative, dates, and even spend/impression ranges and demographics. In practice, a DTC brand could use it to weekly scrape competitors' new ads and alert you to fresh angles.
> - Data to store: Via the API (or reports), store each ad's page name/ID, ad ID, creative text, creative media reference, start/end dates, and placement. In EU data: also impressions, spending band, audience demographics and payer info. (E.g. store "10-50K impressions" if available.) Essentially, you'd mirror your manual log in a database.
> - How Table Clay uses it: Set up an automatic weekly job: for each key competitor (and Table Clay's own page), fetch all currently running ads via API. Compare to last week's data: if a new creative appeared or an old one stopped, flag it. Generate an email/Slack alert ("Brand X launched a new angle: Promise '...', Offer '...'"). The weekly report can list each competitor's active ads with timestamps, so you see changes over time. This turns ad monitoring into a low-effort continual process.
> - Example: Query ads for "PotteryHub" brand. The API returns 5 active ads: you store their texts and media URLs. Next week, one changed text -- your system flags that changed hook. Meanwhile, you see competitors Y and Z running the same new graphic -- confirming a cross-brand angle.
>
> **H. "Do This Tomorrow" Routine**
> 1. Scan (60-90 min): Block an hour and pick 2-3 competitors. Follow the workflow above: set filters, search each brand, screenshot new ads. Aim for ~10 ads total. Tag them quickly (angle/hook). Don't go deeper than the first page of results each.
> 2. Tag and Log: Immediately add any fresh ads to your Ad Log (see template). If you already have a backlog, update it. If time's up, stop. Even a short weekly scan beats no scan.
> 3. Weekly Planning (30 min): Once a week (e.g. Friday), review the log. Remove duplicates, refine tags, and brainstorm 2-3 ad briefs from top findings. For example, pick the single most convincing new angle and draft a variant idea for Table Clay. Sketch a CTA/offer and note any media needed (e.g. "record video of child making pot and offer free shipping").
> 4. Logging System: Use a simple Notion or Google Sheet. Columns might include: Brand | Ad ID/URL | Date | Angle | Hook copy | Offer | Proof snippet | Notes. This keeps research visible.
> 5. Avoid rabbit holes: Stick to plan. If a brand shows endless variations, don't chase all -- grab a representative sample. Set timers. Prioritize breadth over depth: better to cover 3 brands shallowly than 1 brand obsessively. Remember, the library is a hunting tool, not a wading pool.
> 6. Share insights: After each scan, copy key screenshots/text into a shared doc or one-pager. E.g. "ApplePotters -- angle 'Holiday DIY fun', proof: celeb mention, offer: Black Friday -30%." This crystallizes ideas for the team and prevents data from vanishing in folders.
>
> **I. Templates**
> Ad Capture Log (for Notion/Sheets): Only include essential columns to tag and filter. Example columns: Brand | Page | Ad ID/Link | Date found | Angle/Theme | Hook (first line) | Offer | Proof/Notes | Format/Placements
>
> Angle Backlog: A simple list or table of unique angles gathered:
> - Angle: Brief description (promise + target).
> - Example Row: "Kids' Creativity/Screen-Free Play" -- promise: fun art activity; mention any proof ("4.9 stars, 5k reviews") in notes.
>
> Proof Backlog: A list of strong evidence points:
> - Proof: e.g. Testimonial, stat, award.
> - Example: "Mindfulness Claim: We saw competitor quote 'Feels like therapy' and cited a NIH study on art reducing stress."
>
> Weekly Creative-Intel One-Pager (example outline): Summarize 2-3 top competitors.
> - Brand A (KidsPotteryCo): Top Angle: Giftable family activity (ad shows mom/dad with kids). Hook: "Make memories, not mess." Offer: 15% off bundle, free gift wrap (persistent). Proof: "Featured on ABC News," kid testimonial. Takeaway: Test family-bonding angle + gift wrap visual.
> - Brand B (SipCeramics): Top Angle: Premium coffee experience (focus on insulation). Hook: "Your morning just got hotter." Offer: 20% off first order. Proof: "10,000 mugs sold," seal of quality icon. Takeaway: Try emphasizing craftsmanship/quality + time-lapse heating demo.
> - Learnings: Two competitors emphasize "screen-free fun," one pushes "wellness/therapy." All highlight a discount code. Several use "gift" hooks around holidays. Action: Prototype ad for Table Clay using a kid-user testimonial with holiday gift messaging.
>
> **Top 10 Mistakes People Make with Ad Library**
> 1. Equating longevity with guaranteed wins. (A long-running ad is usually a good signal but not a guarantee -- it might just be an on-low-budget retargeter or misoptimized.)
> 2. Missing filters (country/category): Failing to set the right country or leaving the category on "Issues" can return irrelevant ads. Always double-check filters.
> 3. Ignoring inactive data: Assuming inactive tabs or "inactive" results show historical ads -- mostly false. In the US, when an ad ends it disappears.
> 4. Not saving assets: Copying ad URLs (which expire) instead of saving creative is a trap. Always screenshot/download assets immediately.
> 5. Overtrusting impressions: Believing that more variants = bigger budget. The library shows no spend/imps (outside EU), so don't infer scale from number of ads alone.
> 6. Copying big-brand style: Stealing a Fortune 500 brand's ad design without adapting it. Big budgets show slick visuals; as an SME, focus on the idea/hook, not pixel-perfection.
> 7. Neglecting brand fit: Imitating angles that conflict with your brand positioning. For Table Clay, drop anything that undermines our handmade brand story.
> 8. Forgetting low-count cues: Ignoring "low count" labels -- rookie mistake. These often show noisy tests, not winners.
> 9. Not organizing research: Logging nothing or too much. Scanning ads and doing nothing with them wastes time. Use structured logs, not hundreds of random screenshots.
> 10. Chasing frills over substance: Focusing on flashy creative elements ("cool transitions") instead of the core angle/hook. The Library is about ideas, not editing tricks. Always ask "what's the message?" first.
>
> **Top 10 Things Beginners Miss**
> 1. Active vs historical: Many beginners think they can see old campaigns -- but non-EU ads vanish once stopped. They miss that "active" is basically "live now."
> 2. Creative families: They look at one ad and move on, instead of grouping variants. Missing the whole family means missing the testing strategy.
> 3. Low-count filter: Not noticing the "low count" label, and thus overcounting how many truly scaled ads a competitor has.
> 4. Offer persistence: Overlooking that repeated offers/disclaimers across ads indicate winners. (If every ad says "free shipping," that's a clue.)
> 5. Link vs asset: Thinking copying the Library link is enough -- not realizing links expire.
> 6. Meta labeling quirks: Not noticing additional labels like "Irregular activity" or "Paid partnership" flags which hint at influencer/partner campaigns.
> 7. Story ads appearance: It's debated, but many miss that story-format ads can appear in the Library feed -- you just need to scroll or look in hidden tabs (some users find them, others don't). Always double-check feed orientation.
> 8. Filters stack: Neglecting that filters can combine: e.g. setting language + country + media narrows results greatly.
> 9. Translating findings: Finding an angle in Ads Library but failing to adapt language to your audience (e.g., competitor uses UK English idiom).
> 10. No analysis plan: Diving into Ads Library without a plan (who/what to research, how to log). Leads to data overload.
>
> **If You Only Do 3 Things, Do These**
> 1. Scan and Save: Pick 3 competitors, search them in Ads Library (correct country/cat), and capture the creatives and copy of any long-running or eye-catching ads. Store them now -- this builds your best assets for ideas. (This one habit quickly seeds a backlog of proven hooks.)
> 2. Extract Angles: For each saved ad, identify the core angle (benefit) and hook. Write down "Promise/Pain" in your Angle Backlog. Even without perfect data, this pins down what to test in your own style. (Without this step, you just have random ads -- the insight is in the message.)
> 3. Align and Test: Take the top 1-2 angles you found that fit Table Clay's brand, and run quick ad tests. For example, if you discovered a "Kid Creativity" angle, film your own child demo and test it. Use simple tracking (e.g. link clicks) to see if it resonates. (Evidence: industry vets say rapid iteration on a few hypotheses outperforms researching endlessly.)
>
> By focusing on these, you ensure your research directly feeds campaigns, rather than getting lost in analysis.
>
> [Source: Meta Ads Library Playbook (with Table Clay examples).pdf]
