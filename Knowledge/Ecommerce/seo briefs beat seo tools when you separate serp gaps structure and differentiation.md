---
created: 2026-02-05
description: A reusable LLM prompt can replace paid SEO-brief tooling by breaking the brief into SERP analysis, intent, structure, keyword planning, and a differentiation plan that goes beyond copying top results.
source: https://x.com/aiwithjainam/status/2018991436222591434
type: framework
---

# SEO briefs beat SEO tools when you separate SERP gaps structure and differentiation

## Key takeaways

- The thread’s claim is that a single **structured prompt** can replace an SEO-brief tool subscription by forcing a comprehensive brief workflow (SERP scan → intent → outline → keyword plan → differentiation → on-page checklist).

- The most defensible edge is **differentiation**, not mimicry. Copying the top 10 is table-stakes; the prompt explicitly asks “what’s missing?” and “what will make this better?” which is where ranking upside comes from.

- The prompt is essentially a **brief generator**: it outputs the writer’s constraints (format, sections, word counts), SEO requirements (title/meta/schema), and success targets (ranking/traffic/conversions).

- This fits the general idea in [[content systems beat content calendars when assets are modular tagged and agent-operable]]: treat content creation as a **repeatable system** with checklists and modular steps, not ad hoc writing.

## Reusable prompt (from source)

> [!quote]- Tweet: Jainam Parmar — “Claude prompt that killed my $800/mo Ahrefs subscription”
> 
> (Original: https://x.com/aiwithjainam/status/2018991436222591434)
> 
> PROMPT_START
> 
> @aiwithjainam (Jainam Parmar):
> My team warned me not to share this publicly.
> 
> But I'm going to share this Claude prompt that killed my $800/mo Ahrefs subscription.
> 
> It creates SEO briefs better than any tool I've tested.
> 
> 39 out of 47 pieces now rank in top 10.
> 
> Here's the exact prompt:
> 
> ---
> 
> "Create comprehensive SEO content brief:
> 
> TARGET KEYWORD: [Your keyword]
> SEARCH INTENT: [Informational/Transactional/Navigational/Commercial]
> TARGET AUDIENCE: [Who's searching this]
> 
> PHASE 1 - SERP ANALYSIS:
> 
> Analyze current top 10 ranking pages:
> - What format dominates? (Listicle/Guide/Comparison/Tool/Video)
> - Average word count of top rankers
> - Common headings/sections across top results
> - What type of sites rank? (Brands/Affiliates/Publishers/SaaS)
> - Content freshness (how recent are top results?)
> - What's missing in current results? (gaps to exploit)
> 
> PHASE 2 - SEARCH INTENT DEEP-DIVE:
> 
> What is the searcher actually trying to do?
> - Learn something? (Then explain clearly)
> - Buy something? (Then compare options)
> - Solve a problem? (Then give step-by-step solution)
> - Find a tool? (Then provide recommendations)
> 
> What questions are they asking?
> - Check "People Also Ask" section
> - Related searches at bottom of SERP
> - What questions appear in top-ranking content?
> 
> PHASE 3 - CONTENT STRUCTURE:
> 
> Recommended H1: [SEO-optimized title that matches intent]
> 
> Outline with H2s and H3s:
> For each section:
> - Heading (include semantic keywords)
> - Key points to cover (what must be included)
> - Recommended word count for section
> - Internal linking opportunities
> - External sources to reference
> 
> Introduction requirements:
> - Address search intent in first 100 words
> - Include target keyword naturally
> - Hook that makes them want to keep reading
> - Promise of what they'll learn/achieve
> 
> Conclusion requirements:
> - Summarize key takeaways
> - Call-to-action (next steps)
> - Related topics to explore
> 
> PHASE 4 - KEYWORD OPTIMIZATION:
> 
> Primary keyword: [Target keyword]
> - Target density: [Recommended %]
> - Placement: Title, first 100 words, at least 2 H2s, conclusion
> 
> LSI/Semantic keywords to include:
> - [List 15-20 related terms that top rankers use]
> - Natural integration points for each
> 
> Long-tail variations to target:
> - [List 5-10 question-based variations]
> 
> PHASE 5 - CONTENT DIFFERENTIATION:
> 
> What will make THIS content better than current top 10?
> - Unique angle or framework
> - Original data or research
> - Better examples or case studies
> - More comprehensive coverage
> - Better formatting or visuals
> - Expert quotes or insights
> - Interactive elements
> 
> PHASE 6 - ON-PAGE SEO CHECKLIST:
> 
> Meta title (55-60 characters):
> - Include target keyword
> - Compelling click-driver
> - [Provide 3 options]
> 
> Meta description (150-160 characters):
> - Include target keyword and benefit
> - Call-to-action
> - [Provide 3 options]
> 
> URL slug: [SEO-friendly URL]
> 
> Image requirements:
> - Number of images needed
> - Alt text strategy
> - Featured image concept
> 
> Schema markup recommendations:
> - Article schema
> - FAQ schema (if applicable)
> - HowTo schema (if applicable)
> 
> PHASE 7 - CONTENT REQUIREMENTS:
> 
> Target word count: [Based on SERP analysis]
> Reading level: [8th-9th grade for accessibility]
> Tone: [Match brand + user intent]
> Expertise signals to include: [Stats, studies, expert quotes]
> 
> Internal links (5-10):
> - Related articles to link to
> - Anchor text suggestions
> 
> External links (3-5):
> - Authority sources to reference
> - Studies or data to cite
> 
> PHASE 8 - SUCCESS METRICS:
> 
> Define success for this piece:
> - Target ranking position (realistic based on domain authority)
> - Expected monthly traffic
> - Conversion goals (if applicable)
> - Engagement metrics (time on page, scroll depth)
> 
> Competitive analysis:
> - Weakest competitor in top 10 (your first target to outrank)
> - Content gaps they have that we'll fill
> 
> Timeline to ranking:
> - Expected time to top 20
> - Expected time to top 10
> - Expected time to top 3
> 
> Update: Use only current data. Check SERP features (featured snippets, People Also Ask, videos). Prioritize E-E-A-T signals."
> 
> ---
> 
> I used this to rank for "AI productivity tools" (90K monthly searches).
> 
> From position 47 → position 3 in 6 weeks.
> 
> The "Content Differentiation" section is why it works. Everyone can copy top 10. Not everyone can beat them.
> 
> SEO agencies charge $200-500 per content brief.
> 
> This does it in 3 minutes.
> 
> I've created 47 briefs with this. 83% of content ranks top 10 within 90 days.
> 
> Works best with: ChatGPT (for SERP analysis), Claude (for content structure), Perplexity (for gap analysis).
> 
> Copy this. Rank for your money keywords. Tag me when you hit page 1.
> PHOTO: https://pbs.twimg.com/media/HATmAutbIAEwg0u.jpg
> date: Wed Feb 04 10:14:04 +0000 2026
> url: https://x.com/aiwithjainam/status/2018991436222591434
> likes: 719  retweets: 51  replies: 34
> PROMPT_END
