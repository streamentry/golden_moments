# Content that earns repeat use

Feature phase/state: [catalog](feature-catalog.json). Personal interests matter more than assuming every older adult likes the same decade. [Research S1, S10 and S11](research.md) supports interest-based design and shows that content variety/personalization already exist in competing products.

## GM-023

**The complete included catalog, available immediately.**

Acceptance:
- Preserve all eight currently bundled packs, stable IDs and the 121-asset mapping. New content does not convert existing included content back into a runtime download.
- Every included thumbnail, preview and activity picture resolves locally. No font, image or renderer CDN is required for the installed/core experience on its supported platform.
- Catalog cards open the actual activity, not a download or cache-management screen. Do not silently substitute a blank image or claim an asset loaded because JSON parsed.
- Preserve old installations and historical stored files; unused download infrastructure is not deleted without a scoped migration review.

Test: enumerate the entire catalog, validate file references, load every pack, block external requests, clear previous app/cache data and repeat. Native fresh-install validation remains separate from a hosted browser test.

## GM-024

**Choose interests without another onboarding chore.**

Acceptance:
- Optional filters use familiar topics such as animals, gardens, food, travel and everyday objects, based on licensed available content. No mandatory birth year, cultural identity or diagnosis field.
- Choices can change at any time and are kept locally. Contemporary interests are valid; do not force vintage imagery or assume someone's life history from age.
- A small result set and one clear next action replace a dense storefront. Text search is optional, not required to find content.
- Respect favorites and hidden images. If a filter has no eligible content, explain and offer a broader category; never silently undo a user's exclusions.

Test: zero/one/many results, changed interests, large text, offline search, hidden content, and a user who has no interest in nostalgic packs.

## GM-025

**Rights, clarity and cultural quality for every asset.**

Acceptance:
- Maintain an asset provenance register: stable asset ID, source/author, license or permission, attribution requirement, permitted redistribution and modification, review date, and any release restrictions. Bundling is not proof of redistribution rights.
- Audit shipped legacy assets and fonts as well as new ones. Unresolved rights block the affected release/content until removed or replaced; do not infer that an old repository commit grants permission.
- Content review checks recognizability at tile size, contrast, confusing near-duplicates, crop/orientation, description accuracy and potentially distressing imagery. Avoid hidden advertising, medical badges and unlicensed song lyrics.
- Use adult, diverse and respectful scenes. No universal claim that a picture is happy or calming; user Hide/Skip remains available.
- Captions, prompts and translations receive editorial review. Distinguish original description from quoted source text, and never fabricate testimonials or endorsement.

Test: manifest/provenance completeness, image decoding, required attribution display, human tile-size review, and two similar images that would create an ambiguous pair.

## GM-026

**A reason to return without pressure.**

Acceptance:
- A familiar replay/favorites entry uses explicit local choices. No streak, leaderboard, daily quota, engagement score or negative message after time away.
- Optional variety is drawn from already included and eligible content. Call it a suggestion, not new content every day; no backend or remote recommendation engine.
- Do not auto-launch, autoplay or reshuffle a familiar session. The participant chooses whether to try a different picture or keep a favorite.
- Provide a lightweight way to say Not for me and undo it. A returning user can start their preferred activity without repeating import or setup.

Test: offline date/time changes, all suggestions hidden, no history, revisiting after a long absence and settings preservation. Evaluate actual voluntary reuse rather than total minutes spent in the app.
