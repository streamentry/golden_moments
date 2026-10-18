# Start, continuity and companion setup

Feature phase/state: [catalog](feature-catalog.json). Principles: [research S1-S4](research.md). All numerical targets are proposed usability criteria, not existing measured performance.

## GM-001

**Start an enjoyable activity immediately.** As an independent user or a pair, I can play without answering setup questions.

Acceptance:
- A fresh install opens a readable home with one dominant Start action. No login, diagnostic questions, notification request, import requirement, purchase sheet or mandatory tutorial interrupts it.
- One deliberate tap from home opens the four-tile visible-picture starter using included assets. First launch works offline after installation; installation itself still needs delivery from the store.
- Core matching content precedes optional settings. At supported small-screen sizes, the user can reach the board and exit without hunting through a settings panel; large text reflows rather than shrinks.
- Existing users retain their content and saved preferences. Never overwrite those preferences to make onboarding tests pass.

Test: fresh-state widget and device journey; blocked network; existing-data upgrade; five-second home comprehension followed by unaided task observation.

## GM-002

**Stable navigation and a clear stop.** As a participant, I can leave without finishing or understanding a gesture.

Acceptance:
- Consistently named Home/Back and Done for now controls have visible text or an unambiguous accessible label. Essential exit stays reachable while scrolling or using the software keyboard.
- No nested navigation traps, timed completion screen, or automatic transition to a harder activity. System back and standard exit behavior continue to work.
- During an unfinished activity, Done exits without guilt or a rating request. Start again is separate and requests confirmation before discarding meaningful progress; Cancel keeps the exact board.
- Finishing offers Play again and Done with comparable clarity. No countdown, confetti or claim that a completed board indicates improved cognition.

Test: route stack, hardware/system back, switch navigation, large text, repeated taps and cancel/confirm state preservation.

## GM-003

**Remember comfort, not ability.** As a user, I can choose readable text, visible cards, board size and quiet sound once.

Acceptance:
- Settings use concrete preferences, not labels such as dementia stage, beginner brain, or advanced age. They are optional and adjustable by the participant.
- Persist an explicit, versioned local preference set. Honor system text/motion/accessibility settings and do not silently override a larger accessibility preference.
- New profiles/default state use four visible tiles and quiet operation. Chosen challenge persists; success, speed or mistakes never increase it automatically.
- Reset affects preferences only, requires confirmation, and cannot delete photos or packs. Invalid old settings fall back field by field with owned data preserved.

Test: restart and migration fixtures, malformed optional fields, reduced motion, and independent/shared use on one device.

## GM-004

**Resume safely after interruptions.** As a user, I do not lose a moment because the app was backgrounded or I opened settings.

Acceptance:
- Versioned session state includes activity type, stable content IDs, order/seed, selections and relevant settings, not a cognitive score or camera-library path.
- Resume is a visible choice, never an unexpected launch into an old family image. Start fresh remains available without deleting the stored photo collection.
- Backgrounding, rotation and a settings round-trip preserve state. A cold restart offers resume only if referenced content and schema are valid.
- Missing/deleted photos or incompatible session data produce a clear option to start fresh; never recreate deleted copies or reset the main collection. Writes follow the failure-safe storage contract.

Test: process termination between saves, rotation, content deletion, old session schema and rapid reopen. Record the last durable state rather than claiming exact recovery from every power loss.

## GM-005

**Help exactly where needed.** As a user, I can understand the next action without reading a manual.

Acceptance:
- The matching screen gives one short instruction and a repeatable example on request. Help can be dismissed at any point without resetting play.
- Errors explain what happened and a safe next step. Cancellation is neutral, not failure. No endless loading state or generic technical exception is shown.
- Use plain adult language. Distinguish viewing from testing; the guide says it is fine to look, change activities or stop.
- Privacy/setup explanations live outside the core play path and remain accessible offline.

Test: comprehension with intended users; error-state widgets; screen-reader reading order; offline help links that do not unexpectedly launch a browser.

## GM-037

**Same-device companion setup.** As a family member, I can help choose photos and comfort settings, then hand over a uncluttered activity.

Acceptance:
- A clearly labeled setup route composes existing settings and photo controls. It does not create a second account, remote dashboard or diagnostic profile.
- An optional Play view hides setup clutter, not the participant's exit or ability to request help. No hidden long-press, arithmetic test, biometric gate or trapping gesture is required for ordinary use.
- Demonstrate the actual selected activity before handoff. Return to setup is explicit and retains current preferences.
- This is a usability mode, not role-based security. Explain device access and privacy honestly; do not claim a caregiver has exclusive access without an approved authentication design.

Test: helper prepares a session, participant plays/stops, helper changes one setting, with no data loss or accidental account/permission prompt.

## GM-038

**Optional local reminders - deferred.** Only investigate after users request a routine cue and observed reuse supports it.

Acceptance if separately approved:
- Opt in from settings; explain the schedule before requesting OS permission. Refusal leaves all activities available.
- Notifications use neutral text without diagnosis, names, family photos or guilt. No streaks, urgency, missed-day badges or repeated prompts after refusal.
- Schedule locally; support quiet hours, time-zone changes and one-action disable. No push server, silent health monitoring, or claim to prevent sundowning.
- Test disabled notifications, daylight-saving changes, duplicate scheduling and uninstall/reinstall. Permission review remains a release gate.
