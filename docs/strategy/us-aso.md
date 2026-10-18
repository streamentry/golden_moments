# US ASO strategy

Decision: 2026-10-18. This is a testable launch strategy, not a proven ranking or 10,000-install forecast.

## Objective and audience

Target 10,000 cumulative first-time US installs over 12 months, not 10,000 MAU or payers. Distinguish paid acquisition, organic search, browse and referrals in reporting. The buyer/searcher is a caregiver or family member seeking something manageable to do together; the participant is an adult with individual interests and capabilities.

Positioning: **a simple shared activity, not a memory test**. Product constraints: no new backend, no account, bounded local photos, English-first, no clinical promises.

## Chosen metadata

- Name: `Dementia Games: Golden Moments` (30 characters).
- Subtitle: `Alzheimer's Photo Activities` (28 characters).
- First screenshot: `Simple Dementia Activities` / `Gentle photo games to enjoy together.`
- Canonical source and all copy: `metadata/app-store.en-US.json`.

The purpose leads the unfamiliar brand for human readability, not because Apple guarantees extra ranking weight for leading words. The subtitle adds context rather than repeating games. Home-screen label remains Golden Moments; changing store copy does not justify changing bundle identifiers.

## Keyword priorities

| Priority | Queries | Intent / caution |
| --- | --- | --- |
| P0 | dementia activities; dementia games; activities for dementia | Caregiver activity discovery; demand unmeasured |
| P0 | alzheimers activities; alzheimers games | Relevant alternative audience wording; spelling/token handling needs testing |
| P1 | reminiscence activities; photo memory game; family photo games | Closely related workflows; demand unmeasured |
| P2 | memory games for seniors; senior matching games | Broader and potentially more competitive |
| Exclude | dementia diagnosis; treatment; prevention; cognitive test; disease subtypes | Product does not answer these needs |

Do not invent search volume, difficulty or installs. Use `keyword-research.csv` to record US storefront, language, date, source, popularity metric, relevant top results and evidence. A popularity index is not absolute searches. Record missing values as missing, not zero.

The user supplied Google Keyword Planner figures including dementia 246,000/month, reminiscence therapy 2,400 and dementia caregiver 1,300, with US/English/Google settings and BDT bid currency. These are user-supplied web-search estimates, not audited App Store data. Google advertising competition is neither SEO nor ASO difficulty. Do not sum close-variant rows or convert web searches into app installs.

## Reach model

10,000/12 is roughly 833 first-time installs per month, or 27.4/day averaged across a year. A launch ramp means later months need more than the average. Model search impressions x observed install rate; do not require a product-page visit because installs may happen directly from search results. Do not treat Apple's opt-in analytics coverage as a complete census. Record denominators and source definitions before comparing weeks.

Apple search reporting may include Apple Ads traffic; do not label every search-source install organic. Separate paid reporting where possible and document attribution uncertainty. Rank estimates and review counts are not download evidence.

## Competition and strongest objection

Existing examples to inspect: Memory Lane Games (familiar quizzes/activities) and Memory Bond (family-photo and voice personalization). Their live listings must be rechecked before making comparisons. Personal photos, offline access and caregiver positioning are not unique by themselves. Maintain a review-based gap log instead of asserting a blue ocean.

Our hypothesis is lower setup effort: open, choose a manageable activity, enjoy together. The app must demonstrate this in real usability tests. If users merely want printable activities or already use a preferred photo viewer, metadata optimization will not create product demand.

## Launch and experiments

1. Verify product/privacy/safety gates and resolve all claims before acquisition.
2. Collect Apple Ads search popularity or permitted ASO-tool observations for 10-15 related queries. Do not start a paid campaign without a separately approved budget.
3. Show the first three screenshots to five caregivers for five seconds. Proposed comprehension gate: four identify shared photo activities, none infer treatment. This is usability feedback, not statistical proof.
4. Capture the actual passing iPhone/iPad build. Publish metadata manually after review; do not advertise unshipped functions.
5. Keep metadata, price and remaining screenshots stable while testing first headline: Simple Dementia Activities versus Enjoy Time Together. Apple Product Page Optimization tests eligible creative, not app-name/subtitle variants. Run across complete weekly cycles and use reported uncertainty.
6. Review first-time US installs, exposure, conversion and complaints. Assess reuse through consented pilot diaries/interviews while there is no custom telemetry.

A 20-family pilot can test repeated use; an optional decision threshold is at least eight families independently returning within seven days. This is an explicitly chosen product threshold, not an industry benchmark or clinical assessment. If reuse fails, investigate setup and activity fit before adding sync.

## Stop, continue and monetization

Stop release for medical misunderstanding, destructive imports, unexpected data transmission or misleading screenshots. If discoverability is weak but observed reuse is good, reconsider distribution. If both are weak, do not add backend complexity to rescue the idea.

Start without implementing a paywall in this change. A later one-time unlock can be tested for additional collections/features; the previously discussed $6.99 is only a hypothesis. Do not charge a subscription without recurring value or place restore/purchase burdens in the activity flow.

References: [Apple search](https://developer.apple.com/app-store/search/), [product pages](https://developer.apple.com/app-store/product-page/), [PPO](https://developer.apple.com/help/app-store-connect/create-product-page-optimization-tests/overview-of-product-page-optimization), [Apple review](https://developer.apple.com/app-store/review/guidelines/). These support platform practices, not demand forecasts or legal immunity.

## October 18 release handoff

Retain the chosen 30-character name and caregiver positioning. Correct the offline description to match all eight bundled packs. Use `metadata/google-play.en-US.json` for the Play draft (30-character name, 80-character short description, 4,000-character description). US-English drafts do not replace translations that have not been reviewed. Both stores link to the same GitHub Pages marketing, help, privacy and terms pages.

Rechecked official platform sources on October 18, 2026: [Apple product page](https://developer.apple.com/app-store/product-page/), [Apple metadata](https://developer.apple.com/help/app-store-connect/reference/app-information/app-information/), [Google listing limits](https://support.google.com/googleplay/android-developer/answer/9859152), [Google metadata policy](https://support.google.com/googleplay/android-developer/answer/9898842). Keep descriptive audience context and no ranking, pricing, clinical or cognitive-benefit promises.

The Android upload-key reset was submitted and remains pending at the latest store verification. The previous signed iOS IPA was built from 2aecea2 and is superseded as a release candidate by latest main; build and verify the new head before uploading. Public website copy continues to label 1.3.0 personal-photo functionality as upcoming until store release readback confirms availability.
