# Senior-first product specification

Decision date: 2026-10-18. This is a specification and prioritization proposal, not a record of shipped features or permission to release. Baseline: `2aecea2b53e6c3e67a21a4213a5dd2e1753d1334`, including the fully bundled catalog in PR #47.

## The choice we want to earn

Become the preferred **simple, personal picture-activity app** for older adults and the people spending time with them. We are not attempting to become an all-purpose senior-health platform, nor claiming market leadership. More game modes are not the primary measure of progress.

The experience should answer: **Can I start something enjoyable, at a comfortable level, without setup, pressure, or help I did not ask for?**

There are two use contexts, not two diagnoses:

| Context | User's job | Design consequence |
| --- | --- | --- |
| Independent play | Choose an enjoyable activity and use it without assistance | Adult language; optional challenge; no assumption of cognitive impairment |
| Shared or supported play | Spend comfortable time together without teaching a complicated app | Visible pictures, a small starting board, non-quizzing prompts, easy exit |

The US acquisition audience remains caregivers searching for dementia activities. That does not mean every older user has dementia, every participant needs a caregiver, or the app suits every person. No age, diagnosis, disease-stage or cognition questionnaire is needed.

## Five reasons to choose Golden Moments

1. **Starts immediately:** installed core activities and the included catalog work without a network.
2. **Fits the person:** readable, reachable controls and remembered comfort preferences, never automatic difficulty escalation.
3. **Feels personal:** selected photos, optional descriptions, and chosen interests; no face recognition or forced recall.
4. **Is trustworthy:** original photos stay untouched; clear deletion and backup behavior; no manipulative prompts or medical promises.
5. **Is worth returning to:** familiar favorites plus a little optional variety, not streaks, guilt or endless engagement.

These are product hypotheses and acceptance goals. See [research](research.md) for supporting principles and competitors; evidence does not establish clinical effects or unique market position.

## How to use the specifications

[Feature catalog](feature-catalog.json) owns feature IDs, proposed phase, baseline state and dependencies. The linked functional documents own acceptance behavior. [Roadmap](roadmap.md) owns sequencing. [Validation](validation.md) owns measurement and test evidence. [Baseline](baseline.md) records what was inspected.

| Area | Specification |
| --- | --- |
| Start, settings, help, continuity and local handoff | [Navigation](navigation.md) |
| Matching, shared viewing and optional new activities | [Activities](activities.md) |
| Vision, motor input, assistive technology and layouts | [Accessibility](accessibility.md) |
| Imports, descriptions, favorites and conditional sharing | [Personal photos](personal-photos.md) |
| Included library, interests, content rights and repeat use | [Content](content.md) |
| Persistence, privacy, performance and failures | [Reliability and privacy](reliability-privacy.md) |
| ASO, screenshots, support, pricing and languages | [Distribution](distribution.md) |
| Comparative pilot and release acceptance | [Validation](validation.md) |

The existing [release-status record](../release-status.json) remains the release authority. Do not copy planned features into it as passed. Current metadata remains in [the canonical JSON](../../../metadata/app-store.en-US.json); this work does not rename the app again.

## Explicit exclusions

No custom backend, cloud photo sync, account system, social feed, chat, advertising network, AI processing, medical scoring, diagnosis, treatment claims, compulsory daily use, or stage-based difficulty labels. Do not reintroduce runtime downloads for the already bundled catalog.

Multiple albums, photo-deck exchange, paid unlocks and reminders are documented as conditional options, not approved implementation scope. A useful app can win the initial niche without any of them. Voice recording remains deferred and is not conflated with optional on-device reading of text.
