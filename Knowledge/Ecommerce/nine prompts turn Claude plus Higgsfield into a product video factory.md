---
created: 2025-07-17
description: Nine Claude Opus + Higgsfield prompts that cover the full product video pipeline from angle generation through retargeting sequences.
source: https://x.com/Whizz_ai/status/2023307199502774287
type: framework
---

A thread by @Whizz_ai lays out 9 structured prompts that pair Claude (for strategy, scripting, and iteration) with Higgsfield (for AI video generation, face swap, and lipsync) to produce product videos at scale. The claim is 50 videos in 4 hours — replacing what a $10K/day agency does.

## Key Takeaways

- The system covers the full creative pipeline: angle ideation, ad optimization, UGC generation, product demos, lifestyle content, comparison reviews, urgency/drop campaigns, influencer-style content, and retargeting sequences. This mirrors the [[advertising works when a content farm feeds modular assets into an agent-driven assembly line|modular content farm]] approach — each prompt is a discrete module in a larger system.
- Prompt 1 (Angle Generator) uses 5 classic direct-response frameworks (PAS, BAB, Story-Demo-Proof, Objection Destroyer, Urgency-Scarcity-Action) which aligns with the idea that [[advertising angles are testable hypotheses not copywriting|angles are testable hypotheses]], not just creative exercises.
- Prompts 2-3 leverage Higgsfield's Click-to-Ad (product URL → video) and Face Swap features to create UGC-style content at scale — essentially automating what UGC agencies charge $200-500 per video for.
- The retargeting sequencer (Prompt 9) maps a 5-video funnel to cart abandonment timing (0-1hr, 1 day, 2 days, 3 days, 5 days), each with different messaging psychology and Higgsfield model assignments. This is a [[content systems beat content calendars when assets are modular tagged and agent-operable|content system]] approach applied to paid media.
- Community skepticism is notable: multiple replies asked for actual output examples, questioned Higgsfield quality, and called it a sponsored post. No sample videos were shown. Treat as a prompt framework to test, not a proven workflow.

## The 9 Prompts

### Prompt 1: The Product Angle Generator

```
You are a Direct Response Copywriter for DTC brands.

Create 10 video angles for [PRODUCT]:

ANGLE FRAMEWORKS:
1. PROBLEM-AGITATION-SOLUTION
   - Problem: [PAIN POINT]
   - Agitation: [CONSEQUENCES OF NOT SOLVING]
   - Solution: [PRODUCT AS HERO]

2. BEFORE-AFTER-BRIDGE
   - Before: [STRUGGLE STATE]
   - After: [DESIRED STATE]
   - Bridge: [HOW PRODUCT GETS THEM THERE]

3. STORY-DEMONSTRATION-PROOF
   - Story: [RELATABLE SCENARIO]
   - Demonstration: [PRODUCT IN ACTION]
   - Proof: [RESULTS/TESTIMONIALS]

4. OBJECTION-DESTROYER
   - Objection: [COMMON CONCERN]
   - Reframe: [NEW PERSPECTIVE]
   - Proof: [EVIDENCE]

5. URGENCY-SCARCITY-ACTION
   - Urgency: [TIME LIMIT]
   - Scarcity: [QUANTITY LIMIT]
   - Action: [CTA]

For each angle:
- Hook (first 3 seconds)
- Script (30-60 seconds)
- Visual concept (for Higgsfield generation)
- CTA (specific action)

Generate 10 complete angles with conversion psychology.
```

### Prompt 2: The Click-to-Ad Optimizer

```
You are a TikTok Shop Specialist using Higgsfield Click to Ad.

Optimize product link to video ad conversion:

PRODUCT URL: [LINK]
TARGET CPA: [$X]
TARGET ROAS: [X]

HIGGSFIELD CLICK TO AD WORKFLOW:
1. Input product URL
2. AI analyzes: Images, description, price, reviews
3. Generates: 3 video variations
4. Test and scale winners

CLAUDE ENHANCEMENT:

Pre-analysis (before Higgsfield):
- Extract: Top 3 benefits from reviews
- Identify: Target demographic pain points
- Create: 5 unique hooks based on psychology
- Write: 3 script variations per hook

Post-generation (after Higgsfield):
- Analyze: Which variation performed best
- Iterate: Generate 10 more based on winner
- Scale: Increase budget on winning creative

AD VARIATION STRUCTURE:

Variation A: EMOTIONAL
- Focus: Transformation/Feeling
- Music: Upbeat/inspirational
- Visual: Lifestyle/aspirational

Variation B: FUNCTIONAL
- Focus: Features/How it works
- Music: Clear/explanatory
- Visual: Product demo/close-ups

Variation C: SOCIAL PROOF
- Focus: Reviews/UGC
- Music: Trending sound
- Visual: Real people using product

Generate complete brief for 15 video variations (5 per angle).
```

### Prompt 3: The UGC Face Swap Factory

```
You are a UGC Creator using Higgsfield Face Swap.

Create "authentic" user-generated content at scale:

CONCEPT: Your face on real customers using [PRODUCT]

HIGGSFIELD WORKFLOW:
1. Source video: Real customer unboxing/using product
2. Face swap: Your face onto customer
3. Lipsync: Add your voice/testimonial
4. Result: "Authentic" UGC from "real customer"

BATCH CREATION (20 videos):

Video Types:
1. UNBOXING (5 videos)
   - Opening package excitement
   - First impressions
   - Product reveal

2. REVIEW/TESTIMONIAL (5 videos)
   - Using product for [TIME]
   - Honest opinion (balanced)
   - Recommendation

3. TUTORIAL/HOW-TO (5 videos)
   - Setting up product
   - Best practices
   - Tips and tricks

4. TRANSFORMATION (5 videos)
   - Before state
   - Using product
   - After results

FACE SWAP BEST PRACTICES:
- Use consistent source photo (lighting, angle)
- Match skin tone in post if needed
- Keep original body language (authentic)
- Add subtle imperfections (realism)

Generate 20 video concepts with face swap technical specs.
```

### Prompt 4: The Product Demo Storyboarder

```
You are a Product Videographer creating demos for [PRODUCT].

Storyboard 10 product demonstration videos:

DEMO STRUCTURE (30-60 seconds):

1. HOOK (0-3 sec)
   - Visual: Product in use/result
   - Audio: "This [PRODUCT] just [IMPRESSIVE RESULT]"

2. PROBLEM SETUP (3-8 sec)
   - Visual: Struggle without product
   - Audio: "I used to [PAIN POINT]"

3. SOLUTION INTRO (8-12 sec)
   - Visual: Product reveal
   - Audio: "Then I found [PRODUCT]"

4. DEMO/FEATURES (12-25 sec)
   - Visual: Product in action
   - Audio: "It [KEY FEATURE 1], [KEY FEATURE 2], and [KEY FEATURE 3]"

5. RESULTS/PROOF (25-30 sec)
   - Visual: Transformation/metrics
   - Audio: "Now I [BENEFIT] in [TIME]"

6. CTA (30-35 sec)
   - Visual: Product + price/offer
   - Audio: "Link in bio, limited stock"

HIGGSFIELD GENERATION SPECS:
- Model: [KLING 3.0 for realism / VEO 3.1 for speed]
- Aspect ratio: 9:16
- Duration: 35 seconds
- Camera: [CLOSE-UPS/MACRO for detail]

Generate 10 complete storyboards with Higgsfield prompts.
```

### Prompt 5: The Lifestyle Aspirational Creator

```
You are a Lifestyle Brand Director.

Create aspirational product videos:

CONCEPT: [PRODUCT] as part of [DESIRABLE LIFESTYLE]

HIGGSFIELD CINEMA STUDIO SHOTS:

1. THE MORNING ROUTINE
   - Scene: Sunrise, beautiful home
   - Product: Seamlessly integrated
   - Mood: Calm, premium, intentional
   - Camera: Slow pan, golden hour

2. THE SOCIAL MOMENT
   - Scene: Friends gathering, laughter
   - Product: Enhancing the experience
   - Mood: Joy, connection, belonging
   - Camera: Dynamic, movement, energy

3. THE SUCCESS MOMENT
   - Scene: Achievement, celebration
   - Product: Part of the win
   - Mood: Triumph, confidence, status
   - Camera: Epic, elevated, cinematic

4. THE TRANSFORMATION
   - Scene: Before → After journey
   - Product: The catalyst
   - Mood: Hope, progress, empowerment
   - Camera: Reveal, contrast, satisfaction

ASPIRATIONAL PSYCHOLOGY:
- Target identity: [WHO THEY WANT TO BE]
- Current identity: [WHO THEY ARE]
- Gap: [PRODUCT BRIDGES THE GAP]

Generate 10 lifestyle concepts with Higgsfield Cinema Studio specs.
```

### Prompt 6: The Comparison/Review Engine

```
You are a Product Review Creator.

Create comparison videos that convert:

FORMAT: "[PRODUCT] vs [COMPETITOR] - Honest Review"

HIGGSFIELD GENERATION APPROACH:
- Split screen or alternating scenes
- Your face on both reviewers (Face Swap)
- Consistent testing methodology

COMPARISON CRITERIA (score 1-10):
1. Price/Value
2. Quality/Durability
3. Ease of Use
4. Features
5. Customer Support
6. Overall Recommendation

VIDEO STRUCTURE:
- Hook: "I tested [PRODUCT] and [COMPETITOR] for [TIME]"
- Setup: Testing methodology explanation
- Category 1: [CRITERIA] - Side by side
- Category 2: [CRITERIA] - Side by side
- [Continue for all criteria...]
- Winner announcement
- CTA: "Link for winner in bio, code for discount"

HIGGSFIELD WORKFLOW:
1. Generate test footage (product in use)
2. Face swap reviewer onto both
3. Lipsync review commentary
4. Edit together with graphics

Generate 5 comparison video concepts.
```

### Prompt 7: The Limited Drop/Urgency Creator

```
You are a Drop Culture Marketing Specialist.

Create urgency-driven product videos:

URGENCY PSYCHOLOGY:
- Scarcity: Only X available
- Time: Limited window
- Social proof: Selling out fast
- FOMO: Others are buying

HIGGSFIELD VIDEO CONCEPTS:

1. THE DROP ANNOUNCEMENT
   - Visual: Product reveal, countdown
   - Audio: "Dropping [DATE] at [TIME]"
   - Mood: Hype, exclusive, anticipation

2. THE STOCK WARNING
   - Visual: Inventory counting down
   - Audio: "Only [NUMBER] left, [NUMBER] sold in last hour"
   - Mood: Urgent, act now

3. THE SOCIAL PROOF FLOOD
   - Visual: Screenshots of orders/comments
   - Audio: "Look at everyone grabbing theirs"
   - Mood: Bandwagon, validation

4. THE FINAL CALL
   - Visual: Last chance messaging
   - Audio: "Closing in [HOURS], last opportunity"
   - Mood: Finality, regret minimization

5. THE SOLD OUT/VIP LIST
   - Visual: Sold out stamp, waitlist
   - Audio: "Gone! Join VIP for early access next drop"
   - Mood: Exclusivity, future opportunity

HIGGSFIELD FEATURES:
- Fast generation with Veo 3.1 or Minimax Hailuo 02
- Text overlays for countdowns
- Quick iteration for time-sensitive drops

Generate 10 urgency video scripts with Higgsfield specs.
```

### Prompt 8: The Influencer Collaboration Simulator

```
You are an Influencer Marketing Manager.

Create "collaboration" videos without real influencers:

CONCEPT: Face swap your product into influencer-style content

HIGGSFIELD FACE SWAP APPLICATIONS:

1. NICHE INFLUENCER STYLE
   - Target: [BEAUTY/FITNESS/TECH/LIFESTYLE] creator
   - Aesthetic: [SPECIFIC CREATOR STYLE]
   - Content: Product integration in their format
   - Your face: On "influencer" demonstrating

2. CELEBRITY INSPIRED
   - Target: [CELEBRITY] aesthetic
   - Aesthetic: Their signature look/vibe
   - Content: "If [CELEBRITY] used [PRODUCT]"
   - Disclaimer: Parody/fan content (legal safety)

3. EXPERT AUTHORITY
   - Target: [INDUSTRY EXPERT] persona
   - Aesthetic: Professional, credible, trustworthy
   - Content: Expert review/recommendation
   - Authority: "As a [EXPERT], I recommend..."

ETHICAL GUIDELINES:
- Clearly disclose AI-generated content
- Avoid impersonating real living people
- Focus on aesthetic/style, not identity theft
- Add "AI-generated" disclaimer

Generate 15 "collaboration" concepts with face swap technical approach.
```

### Prompt 9: The Retargeting Video Sequencer

```
You are a Performance Marketer creating retargeting sequences.

Build video funnel for abandoned carts:

HIGGSFIELD VIDEO SEQUENCE (5 videos):

VIDEO 1: REMINDER (0-1 hour after abandon)
- Hook: "Forgot something?"
- Content: Product they viewed
- CTA: "Complete your order"
- Model: Quick generation (Veo 3.1)

VIDEO 2: SOCIAL PROOF (1 day after)
- Hook: "Join 10,000+ happy customers"
- Content: Reviews/testimonials
- CTA: "See why they love it"
- Model: Face swap UGC (Kling 2.6)

VIDEO 3: OBJECTION HANDLER (2 days after)
- Hook: "Still thinking it over?"
- Content: Address common concern (price/quality/fit)
- CTA: "Here's why it's worth it"
- Model: Lipsync explanation (Lipsync Studio)

VIDEO 4: URGENCY (3 days after)
- Hook: "Your cart expires soon"
- Content: Scarcity/limited time
- CTA: "Save your cart now"
- Model: Fast generation (Minimax Hailuo 02)

VIDEO 5: LAST CHANCE + ALTERNATIVE (5 days after)
- Hook: "Last call + special offer"
- Content: Discount or alternative product
- CTA: "Last chance or try this instead"
- Model: Cinema Studio (premium feel)

TRACKING SETUP:
- Pixel fires for each video view
- Conversion attribution by video
- ROAS calculation per sequence

Generate complete 5-video sequence with Higgsfield model assignments.
```

## External Resources

- [Higgsfield](https://higgsfield.ai) — AI video generation platform (Click-to-Ad, Face Swap, Lipsync Studio, Cinema Studio)
- Higgsfield model options mentioned: Kling 3.0 (realism), Veo 3.1 (speed), Kling 2.6, Minimax Hailuo 02

## Original Content

> [!quote]- Full Thread by @Whizz_ai (Feb 16, 2026)
> **@Whizz_ai** — BREAKING: AI can now create product videos like $10K/day TikTok ad agencies (for free). Here are 9 insane Claude Opus 4.6 + Higgsfield prompts that generate 50 product videos in 4 hours.
>
> 957 likes · 84 retweets · 39 replies
>
> [Full thread →](https://x.com/Whizz_ai/status/2023307199502774287)
