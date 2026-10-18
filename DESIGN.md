# Golden Moments design contract

## Outcome

A caregiver can start a comfortable shared picture activity without explaining a complex interface. The person participating is an adult, not a test subject.

Reuse `gmBuildTheme` and tokens in `lib/design_system.dart`; preserve the warm identity rather than introducing a separate palette. Audit actual contrast, particularly gold actions. Favor 18-22 logical-pixel body copy, system text scaling, generous spacing and at least 48-by-48 logical-pixel targets. Essential content scrolls instead of being clipped. Bound content comfortably on iPad.

## Interaction

**Start a gentle game** opens four tiles with no setup/download. Pictures remain visible by default. Hidden tiles and larger boards are choices, not higher achievement. Mismatches remain until the next deliberate tap. Use a check and border, not color alone. No failure sounds, streaks, confetti or urgency.

**Your family photos** is an explicit setup action. **Look together** is as valid as matching. Prompts are optional and do not quiz names. Use concrete adult language; no brain age, train harder, or infantilizing praise.

## Acceptance

Check VoiceOver/TalkBack focus, labels, actions, hidden-card privacy, 200% text scaling, rotation, contrast and hit areas on real devices. Personal-photo labels are currently positional; do not claim descriptive accessibility that has not been implemented. Motion is not required by the new flow.

## Store design

Actual UI dominates. One message per frame. Use consented/licensed demonstration pictures, never sensitive user content. Avoid medical symbols, clinical badges and cognitive scores. See `docs/specs/screenshots.md` for sequence and release gates.
