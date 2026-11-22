---
name: paying-demand
description: "Find what to build from money that already flows - apps and businesses with verified revenue, their 1-2 star reviews clustered into what users hate, and a better version that fixes exactly that instead of a clone; mobile apps first (Android from Linux). Use for co budowac, na czym zarobic, pomysl na apke, aplikacja mobilna, find businesses that already make money, app idea, validate demand, negative reviews, clone but better."
metadata:
  priority: "2"
  tags: "#business #thinking #decisions #scraping #mobile"
  requires: "skill:founder skill:scrape-everything ?skill:economist ?py:google_play_scraper ?cmd:curl ?cmd:jq|python3"
  upstream: "video: Jack Roberts, I Asked Claude to Find Me Businesses That Already Make Money (his request 2026-11-19)"
---

# paying-demand

Start where people already pay, never from an idea nobody has paid for. His wish (2026-11-19): make a skill of the
method "find businesses that already make money, then build the better version from their negative reviews" - and
"ja bym sie skupil na aplikacjach mobilnych". So the default target is a mobile app, Android first.

## The method

1. **Money first.** List apps or products that earn now, each with where the number comes from:
   - verified: TrustMRR (Stripe or RevenueCat API key; filter for RevenueCat for mobile), whatsthe.app (mobile
     apps verified through RevenueCat, App Store Connect, Google Play);
   - estimated: top-grossing charts (App Store `https://itunes.apple.com/us/rss/topgrossingapplications/limit=100/genre=GENRE/json`,
     genre 6008 Photo & Video, 6002 Utilities), Appfigures or Sensor Tower estimates;
   - never a revenue screenshot from a post. Every figure is labelled verified or estimate, with source and date.
2. **Pick the category by base rates, dated.** RevenueCat State of Subscription Apps 2026: Photo & Video had the
   most new apps reaching $1k MRR (21.4%); the hardest to enter were Education, Productivity, Travel, Shopping,
   Business; apps launched before 2020 still take 69% of subscription revenue; iOS has 77% of new launches.
   Re-check these each year - they go stale.
3. **Pull the 1-2 star reviews** of the 3-5 top earners in that category, as JSONL (`scrape-everything`, raw kept):
   - Google Play: `google_play_scraper.reviews(app_id, sort=Sort.NEWEST, count=200, filter_score_with=1)`
     (and `2`); returns `(rows, token)`, pass the token back for more;
   - App Store: `https://itunes.apple.com/us/rss/customerreviews/page=N/id=APPID/sortby=mostrecent/json`, pages
     1-10 (500 reviews a country, page 11 answers 400) - take several countries for more.
4. **Cluster the complaints.** Put the JSONL into vecindex (`vi_ingest_text(db, "app.jsonl", ..., VI_JSONL, ...)`
   with `fields="score,app"`, or `db.ingest_text(...)` in Python), then count per theme with hybrid search. Start
   from the usual themes (crashes and freezes, intrusive ads, pricing and billing, cancelling, missing features,
   login, export, slow on mid-range Android) and keep the new ones the reviews show. Rank by complaints x the
   money the app makes.
5. **Design the better version, not a copy.** Each feature answers a named, counted complaint. What he can win on:
   native C that runs well on cheap phones, offline and on-device (vecindex for search), no ads, a fair one-time
   price or an honest free tier.
6. **Judge it**: `founder` for kill criteria, the cheapest experiment and a verdict. Costs: Google Play $25 once,
   Android NDK builds C from Linux; iOS needs a Mac and $99 a year, so it comes second.

## Output

One table, best first: app | revenue (verified/estimate, source, date) | top 3 complaints with counts and one short
quote each | what ours fixes | build cost for him alone | kill criterion. Then the one experiment to run this week
(e.g. a Play Store listing or a landing page before the full app). A finished report is saved where he keeps it
(the project's notes or a doc), not left in chat.

## Rules

- No revenue claim without its source; no category advice without a dated base rate.
- A clone that fixes nothing is not an answer. If the reviews show no fixable complaint, say so and move on.
- Quotes from reviews are short and few; summarise the rest.
- Choose what one person can build and keep running; a server-heavy app (sync, accounts, moderation) costs points.
