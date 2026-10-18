# Accessibility is a release property

Feature phase/state: [catalog](feature-catalog.json). Extend [the safety contract](../safety-accessibility.md). [DESIGN](../../../DESIGN.md), updated by PR #48, is normative for tokens and visual rules; these specifications add acceptance tests, not competing styling. Sources: [S2-S7](research.md). This is not an assertion of compliance or universal suitability.

## GM-012

**Readable type and honest reflow.**

Acceptance:
- Reuse the bundled font and theme roles from DESIGN; never hardcode a smaller style in a screen. Preserve its 16 logical-unit text floor and 18/20 body styles. System scaling stays enabled and unclamped.
- At 100%, 150% and 200% test scales, essential instructions, controls and errors remain readable and reachable. Also test the largest supported system setting, which may exceed 200%.
- Labels wrap, controls grow or content scrolls, and keyboards do not obscure confirmation or exit. No ellipsis on essential actions or smaller type to fit a fixed card.
- Keep the board before optional settings. At extreme scaling, one clear scrolling path is better than tiny tiles or conflicting nested scrolling.
- Use adult sentence case, not all-caps instructional copy or decorative emoji praise.

Test: parameterized widget sizes/scales, native display zoom, longest English labels and later translations. Record overflow and observed readability separately.

## GM-013

**Forgiving motor interaction.**

Acceptance:
- Preserve DESIGN's minimums: every control at least 48 by 48 logical units, buttons at least 56 high, hero actions 64 high, and picture tiles at least 64 with the largest practical size. These are project values; do not claim a CSS/physical-pixel certification from them.
- Separate neighboring controls. Distinguish destructive actions from play and retain one primary filled action per screen. Do not force smaller targets to retain a dense layout.
- Provide single-tap alternatives to swipe, drag, pinch and long-press functions. No precise timing or two-handed interaction is required for essential tasks.
- Repeated taps, long contacts and interrupted pointers cannot duplicate imports/deletions or double-advance a route. Do not globally delay input in a way that breaks assistive technology.

Test: target guideline checks, stylus/one-handed use, switch input, pointer cancellation and rapid taps. Include varied dexterity instead of substituting a developer's successful tap.

## GM-014

**Meaningful screen-reader experience.**

Acceptance:
- Every essential control has a clear label, role and state. Focus order follows the task; dialogs announce their purpose and return focus to the initiating control.
- Revealed images use reviewed descriptions where available. Optional user descriptions improve on positional labels without inventing identities or relationships.
- Hidden cards never reveal names, captions or answers through semantics or narration. Selected/matched states are announced without repeated live-region noise or surprise focus changes.
- One tile has one coherent action target. Disabled/matched states remain understandable; no invisible required control.
- Test the entire start/play/stop/import/remove journey with VoiceOver and TalkBack. Widget semantics alone are insufficient.

Test: automated trees plus physical-device observation, missing/long/duplicate descriptions, and visibility changes.

## GM-015

**Contrast, quiet defaults and reduced motion.**

Acceptance:
- Preserve PR #48's corrected primary gold/theme roles and automated contrast tests. Measure changed pairings: at least 4.5:1 ordinary text and 3:1 only for qualifying large text; aim for 7:1 essential body copy where feasible. Important control boundaries target 3:1 and also use shape/text.
- Bright accent gold is not body text or the only outline. Use DESIGN tokens; a feature does not get an independent palette. Every shipped theme needs measured checks; do not enable an unverified dark theme.
- Honor reduced motion, increased contrast and relevant system settings. No flash, parallax, confetti, forced animation, moving controls or auto-closing dialogs anywhere in the app.
- Quiet by default in the new flow. Sound/haptics are optional and never the only feedback. No punishment sound, stopwatch, move counter, streak or countdown returns through a legacy route.

Test: measured token pairings, grayscale, bright/dim viewing, reduced motion and audio interruption on supported devices. Brand consistency never excuses a contrast failure.

## GM-016

**Small phone, tablet and rotation.**

Acceptance:
- Use available width/height, safe areas and text size rather than device-name checks. Verify narrow phone portrait, landscape, large iPad and supported multitasking sizes.
- Rotation/resize preserves the session. Controls remain reachable; image aspect ratio is preserved without cropping important content silently.
- Keep tablet content bounded by DESIGN and maximize usable picture size within those constraints. More screen space does not automatically mean more cards or greater difficulty.
- Mobile claims need mobile evidence; preserve the separately tested browser/desktop catalog. Verify board-fitting behavior in both legacy and gentle routes.

Test: live rotation/resize, keyboard open, split screen, extreme text size and route restoration. Capture actual iPhone/iPad layouts separately.

## GM-017

**Coexist with system accessibility tools.**

Acceptance:
- Validate Voice Control and switch navigation for essential selection/cancellation flows; favor standard control semantics over gesture-only surfaces.
- Evaluate iOS Assistive Access and Guided Access on supported configurations. Claim support only for recorded OS/device/flow combinations.
- Do not implement a fake system mode, interfere with system exits/volume, or imply an app setup switch establishes device ownership or secure caregiver roles.
- Document unsupported configurations and the simplest equivalent interaction. Missing voice support or permission must not block text/tap play.

Test: manual device matrix in GM-040. A single simulator run does not justify a universal-accessibility claim.
