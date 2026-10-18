# Evidence and product decisions

Sources checked 2026-10-18. Primary sources support design principles and observed product positioning, not a forecast of market leadership. Requirements and numerical acceptance targets elsewhere in this package are our proposed engineering/product decisions unless explicitly attributed.

## S1

**Alzheimer's Association: Activities**  
https://www.alz.org/help-support/caregiving/daily-care/activities

The guidance emphasizes personal interests, current abilities, enjoyment, manageable steps, and changing or stopping an activity when it is uncomfortable. Adopt choice, supported startup and nonjudgmental exits. Do not infer that this app treats symptoms or that activities suit everyone. The association is not endorsing Golden Moments.

## S2

**W3C: Help users understand controls and purpose**  
https://www.w3.org/WAI/WCAG2/supplemental/objectives/o1-understandable/

Adopt familiar controls, visible labels and stable placement. This is supplemental cognitive-accessibility guidance, not a clinical protocol or an automatic WCAG certification.

## S3

**W3C: Clear and understandable content**  
https://www.w3.org/WAI/WCAG2/supplemental/objectives/o3-clear-content/

Adopt concrete wording, short instructions and visually separated content. Avoid clinical jargon in the play flow. Adult simplicity is not childishness.

## S4

**W3C: Avoid and recover from mistakes**  
https://www.w3.org/WAI/WCAG2/supplemental/objectives/o4-minimize-mistakes/

Adopt stable controls, reversible settings, explicit destructive actions and preservation of unfinished work. An app should not create time pressure while someone reads or chooses.

## S5

**W3C WCAG 2.2: Contrast and input alternatives**  
https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html  
https://www.w3.org/TR/WCAG22/

Normal text contrast uses a 4.5:1 minimum; qualifying large text uses 3:1. Our design target is stricter for essential body text. WCAG is a web standard used here as a design reference alongside platform testing. Flutter logical pixels, iOS points and CSS pixels must not be presented as interchangeable certification units. Provide a non-drag alternative to moving puzzle pieces.

## S6

**Flutter accessibility and testing**  
https://docs.flutter.dev/ui/accessibility  
https://docs.flutter.dev/ui/accessibility/accessibility-testing

Adopt semantic-label, target-size and contrast checks plus actual VoiceOver/TalkBack testing. Automated widget checks cannot certify a complete native experience. Use the repository's pinned SDK rather than changing versions to match a documentation page.

## S7

**Apple Assistive Access user guide**  
https://support.apple.com/guide/assistive-access-iphone/welcome/ios

Assistive Access is an operating-system accessibility environment, not a proprietary Golden Moments mode. Test coexistence and document limits before claiming support. Do not block ordinary system exit controls or make a caregiver-only prison interface.

## S8

**Apple App Review Guidelines**  
https://developer.apple.com/app-store/review/guidelines/

Apply accurate metadata, complete functionality, data security and respectful purchase/review behavior. Medical claims receive additional scrutiny. A disclaimer is not a compliance safe harbor. Use Apple's review prompt mechanism, without incentives or filtering invitations to happy users.

## S9

**Apple App Store search**  
https://developer.apple.com/app-store/search/

Relevant metadata and user behavior matter to discovery. Promotional text is not a search-ranking lever. Do not turn Google search volume, review counts, or popularity indices into invented organic-install forecasts.

## S10

**Memory Lane Games: US App Store listing**  
https://apps.apple.com/us/app/memory-lane-games/id1517193093

The listing advertises a large curated topic library, familiar quizzes, caregiver resources and offline play after download. These establish a strong alternative for topic variety and caregiver positioning. Clinical statements in the listing are vendor claims, not evidence transferred to Golden Moments. No download/revenue estimate is inferred from the listing.

## S11

**Memory Bond: US App Store listing and developer site**  
https://apps.apple.com/us/app/memory-bond/id6759059833  
https://memorybond.live/

The listing describes six activities, personal photos and voice recordings, including face/name recognition. The developer site describes local use without accounts. Therefore personalization and offline operation are not unique. Pricing language conflicts: the retrieved listing describes a one-time unlock while the website describes an annual subscription. Do not quote one as verified current pricing without checking the actual purchase screen.

## Strategic implications

Our proposed advantage is not more game titles or clinical authority. It is less setup, better demonstrated accessibility, participant control, and personally relevant pictures in a dependable offline experience. The ordinary device photo viewer and a printed picture activity are serious substitutes; include them in comparison testing rather than comparing only with weaker apps.

The strongest counterargument is that users already get enough value from a photo album, while established activity apps offer more content. Falsify our advantage with observed task completion and voluntary preference. A prettier interface or additional features alone is insufficient.

## Evidence still missing

Native-build verification, observed caregiver/independent-user sessions, content-rights completeness, US App Store demand, purchase conversion, retained use, support burden and head-to-head preference. Record unavailable observations as unknown, not zero. Do not describe the roadmap as clinically validated, market-leading, or guaranteed to achieve 10,000 installs.
