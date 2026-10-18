# Discovery, honest conversion and sustainable ownership

Feature phase/state: [catalog](feature-catalog.json). Product ambition does not justify medical claims, review manipulation or a guaranteed ranking. Keep the existing [US ASO strategy](../../strategy/us-aso.md) and [canonical metadata](../../../metadata/app-store.en-US.json) authoritative. Sources: [S8-S11](research.md).

## GM-032

**One accurate search proposition.**

Acceptance:
- Retain the agreed US candidate name/subtitle unless actual search/comprehension evidence supports a separate change. Keep the on-device label Golden Moments and preserve package/bundle identity.
- Focus on caregiver activity/game intent, while the in-app experience treats older adults as adults. Do not add diagnostic, prevention, disease-subtype or therapy keywords for volume alone.
- Update the canonical JSON, regenerate exports and validate limits/duplicates/claims. Never edit just an exported subtitle or treat a document as a live App Store update.
- Research records storefront, language, date, source, observed metric and limitations. Unknown demand is unknown; Google estimates, advertising competition and rating totals are not App Store install data.
- Report first-time US installs separately from active users/payers. Distinguish search, browse, referrals and paid traffic; search-source reporting can include Apple Ads. Install-from-search need not include a product-page visit.

Test: metadata checks, source-to-export comparison, App Store configuration review and a documented demand worksheet. No campaign spending or submission is authorized by this specification.

## GM-033

**Screenshots that prove the experience.**

Acceptance:
- Use the current six-frame [screenshot specification](../screenshots.md). Show actual start/play/photos/accessibility behavior from the tested submitted build, with one readable message per frame.
- The first image makes the activity clear; the next images establish personalization and low-pressure use. Do not show a four-tile prototype or custom family photos before those exact capabilities work in the captured build.
- Capture iPhone and iPad independently. No invented clinical badges, fake reviews, misleading pricing, stock-photo montage instead of product, or implication that new unapproved games are available.
- Use licensed or consented demo images, never a real user's sensitive collection. Record build/commit, device, dimensions, capture steps and asset rights with each image.
- Test one creative variable at a time. A small low-traffic sample can be inconclusive; do not declare a winner because a few more installs appeared.

Test: screenshot-to-build walkthrough, five-caregiver comprehension test, actual rendering at search-result size, and metadata release checks. Image files remain pending until genuinely captured.

## GM-034

**Respectful feedback and reviews.**

Acceptance:
- Provide an explicit feedback/support route. An in-app rating request, if added, uses the platform API and appears at a suitable voluntary pause, never mid-activity or on first launch.
- No review incentive, forced rating, family guilt, fake testimonial or positive-only pre-screen. A satisfaction question must not decide who may see the public rating request.
- Dismissal does not impede any feature or trigger repeated requests. Do not promise the system prompt will always appear.
- Treat participant stopping as a normal choice, not a failed engagement event or reason to nag a caregiver.

Test: first launch, interrupted session, repeated pause, dismissed prompt, negative feedback and offline behavior. Existing release/privacy gates still apply to any new SDK.

## GM-035

**A fair one-time unlock - deferred.** Monetization needs real willingness-to-pay evidence and explicit approval; no paywall is introduced by these docs.

Acceptance if approved:
- Keep a genuinely useful, accessible offline core. Never charge for larger text, safe exit, basic privacy, existing owned content or removal of an artificial handicap.
- Present localized store-supplied pricing, exactly what unlocks, Restore Purchases and clear cancellation before any transaction. Do not hardcode currency or treat device-local booleans as proof of purchase.
- Use the appropriate store purchase flow and test pending/cancelled/refunded/restored transactions, offline owned use and reinstall. Family Sharing eligibility must be checked, not promised by default.
- Purchase/help configuration is outside the participant's activity flow. No countdown discount, automatically renewing subscription or surprise trial.
- A payment SDK, entitlement design, support/refund plan and any verification service require separate review. A no-custom-backend implementation must still meet store correctness requirements.

Test: sandbox purchase lifecycle on supported stores before public copy. The earlier $6.99 suggestion remains a hypothesis, not an approved price or observed demand.

## GM-036

**Complete localization, not translated store promises.**

Acceptance:
- US English remains the initial verified scope. Select another language only after distribution or user evidence; do not interpret existing legacy translations as complete new-flow localization.
- Inventory visible strings, semantics, captions, errors, permission text, help and store assets. Reuse the app's localization mechanism; no hardcoded new strings across production views.
- Human review checks adult tone, cultural fit, readable layout and no added medical claim. Unsupported-language content has an explicit fallback, not mixed-language essential controls.
- Exercise pluralization, long strings, text direction where applicable, locale-sensitive number/price display and locally available spoken voices. Content licenses may differ by territory.

Test: full journey in each claimed language, large text, pseudolocalization and native permission screens. Do not advertise a locale until its essential flows and content pass.
