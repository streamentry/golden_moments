# Device and release acceptance (GM-040)

How to turn the implemented behavior into evidence. Everything below needs a physical device, a native build or a person; the automated suites cannot stand in for it. Until a row is recorded with evidence, its feature stays `implemented_unverified` or `partial` in [release-status.json](../specs/release-status.json), and `python3 scripts/release_metadata.py --release` keeps failing. Implementation, testing, merge, device verification and publication are separate states; a pass on one build does not carry to another.

Use synthetic or licensed demo photos only. Never test with a real person's private collection, and never put real photos in screenshots or evidence files.

## Record every run

One record per scenario: feature ID, commit and build, platform/device/OS, preconditions, steps, expected, actual, evidence location (screenshot or screen recording path, never containing private photos), reviewer, date. Add passing records to `release-status.json` under the feature (`device_evidence`: a list of those records) or the matching gate's `evidence`, then change the status. A feature may be `verified` only with `device_evidence`; `tests/test_senior_status.py` enforces that.

Build the candidate (see [1.3.0.md](1.3.0.md) for signing) and note `git rev-parse HEAD`:

```sh
flutter build apk --release        # Android
flutter build ios --release        # iOS, then archive in Xcode
```

## A. Fresh install, offline (GM-001, 002, 006, 007, 023)

Install on a clean device, switch on airplane mode, then launch.
1. Home shows one dominant start action. No login, permission request, tutorial or purchase sheet appears. **Expect:** none of those.
2. Tap Start a gentle game. **Expect:** four large visible pictures, one instruction, Done for now always on screen, no clock, count or score.
3. Match a pair, mismatch a pair. **Expect:** the mismatch stays visible until the next tap; nothing flips on its own.
4. Finish a board. **Expect:** Play again and Done for now equally clear; no confetti or praise banner.
5. Open the library from Home. **Expect:** every pack opens and plays with no download step.

## B. Stop and resume (GM-004)

1. Start a board, make one move, press Done for now. Relaunch. **Expect:** a prompt offers Carry on or Start fresh; nothing resumes by itself.
2. Carry on restores the same arrangement. Repeat and choose Start fresh. **Expect:** a new board and no later prompt.
3. Make a move, force-quit the app, relaunch. **Expect:** the same prompt.
4. At the prompt press the system back button or gesture. **Expect:** the prompt closes, a fresh board shows, and the saved board is still offered next time.
5. Rotate mid-game and background for a minute. **Expect:** the board is unchanged.

## C. Comfort settings (GM-003, 037)

1. From Home open Comfort settings (tune icon). Choose 8 tiles and hidden pictures. Start a game. **Expect:** 8 tiles, hidden backs, and no settings on the board (the board screen shows the tiles, Done for now and Start again).
2. Force-quit and relaunch. **Expect:** choices kept. Reset. **Expect:** confirmation, then four visible tiles; photos and packs untouched.
3. Change the phone's text size. **Expect:** the app follows it (see F).

## D. Photos (GM-018, 019, 020, 026, 027, 030)

Use Your family photos. After every step the originals in the phone's photo library must be unchanged.
1. Cancel the picker. **Expect:** no error, nothing added.
2. Choose three photos. Add a caption and a description to one, mark two as favorites, hide one. **Expect:** favorites first, the word Hidden on the hidden one; Play with favorites appears with two favorites; hidden photos never appear in a game or Look together.
3. Turn captions on in Look together. **Expect:** captions only then. In hidden-picture mode a screen reader never reads a caption.
4. Relaunch. **Expect:** photos, captions, favorites and hidden state kept.
5. Remove a copy. **Expect:** confirmation; the original is untouched; its caption is gone.
6. Cases to try: duplicate photo, HEIC photo, a photo that exists only in iCloud (may need network to select), choosing more than the 24 limit, very large photo, nearly full storage, revoking photo access, deleting the original after import. **Expect:** a readable message each time and the existing collection intact.
7. Android only: with the picker open, kill the app from the task switcher, relaunch. **Expect:** a confirmation offering to finish adding, never a silent import.

## E. Upgrade (GM-027, 023)

Install the previous release, play, download or note existing packs and any family photos, then install this build over it. **Expect:** packs, photos and preferences preserved; no reset; no crash. Repeat with an existing family-photo collection created by the previous build.

## F. Accessibility (GM-012 to 017)

With VoiceOver (iOS) and TalkBack (Android), complete start, play, stop, resume, add photo, set a caption, hide, remove, comfort settings, help.
- Every control has a clear label and state; focus order follows the task; dialogs announce their purpose.
- Hidden tiles read only "Hidden picture, tile N", never a name, caption or answer. A chosen tile reads its name; matched tiles read Matched.
- Text size at 100%, 150%, 200% and the largest system size on a small phone and an iPad: nothing clipped, the board comes first, Done for now stays reachable, no ellipsis on essential actions.
- Reduce Motion on: no flipping animation. Increase Contrast and grayscale: state is still clear without color.
- Rotate and use split view on iPad. Use Voice Control and Switch Control to start, play, stop and cancel. Try Guided Access and Assistive Access if the device supports them and note exactly which configurations work.
- One-handed and stylus use; try rapid repeated taps on Add and Remove. **Expect:** no duplicate imports or deletions.

## G. Privacy and network (GM-028)

See [network-privacy-audit.md](network-privacy-audit.md). On a clean install with a recording proxy or network inspector (and again in airplane mode): launch, play, add and remove photos, open Help, background and foreground. **Expect:** no requests from the app. Record the hosts seen, if any; any unexplained one blocks release. Then inspect the merged Android release manifest (`android/app/build/intermediates/merged_manifests/release/`) and the iOS privacy manifests, and record permissions and initializers. Compare with the privacy policy and App Privacy answers.

## H. Performance (GM-029)

On the oldest supported physical devices, in a release or profile build: 20 cold launches (`sh scripts/measure_startup.sh <device-id> 20`, then `python3 scripts/startup_stats.py build/startup-runs/*.json`; time to first frame is a proxy, so also time tap-to-interactive-home by hand or screen recording and record median and 95th percentile); frame times while matching, browsing and importing; a 24-photo collection; 20 minutes of use watching memory and heat. Record device, build mode and conditions. Do not publish a number you did not measure.

## I. Help and support (GM-031, 034)

Open Help and privacy from the Home guide, offline. Write a note and report a problem: the preview must match exactly what the share sheet receives; cancelling sends nothing. Verify with no mail app and with no network. Confirm the three pages shown (`supportUrl`, `privacyPolicyUrl`, `termsUrl`) are live and copy cleanly, and that `supportEmail` is a monitored mailbox. The app never opens any of them.

## J. Content and rights (GM-025)

A person reviews every shipped asset against [asset-provenance.json](../specs/asset-provenance.json): author, license or permission, attribution, redistribution and modification terms, review date. Also review tile-size recognizability, near-duplicate pairs, and distressing imagery. Mark a group `reviewed` only after that; `--release` fails while any group is unreviewed.

## K. Screenshots and comprehension (GM-032, 033, 039)

Capture the six frames per [screenshots.md](../specs/screenshots.md) from the tested build on iPhone and iPad separately, using demo images, and record build/device/steps with each file. For the R2 pilot build the experiment with `flutter build apk --dart-define=GM_EXPERIMENTS=true` (never for a store build): in Your family photos, Try a picture puzzle (experiment) opens the tap-to-place puzzle; hidden photos must never appear in it. Note whether participants choose it voluntarily; that evidence, not this prototype, decides GM-009 versus GM-010.

Run the five-caregiver comprehension test and the usability sequence in [validation.md](../specs/senior-first/validation.md); record denominators and missing responses.

## Traceability

Every catalog feature and how it is verified. Statuses live in `release-status.json`; this table says where evidence comes from.

| Feature | Verified by |
| --- | --- |
| GM-001 GM-002 GM-006 GM-007 GM-023 | Section A (device); automated widget tests exist |
| GM-003 GM-037 | Section C (device) |
| GM-004 | Section B (device) |
| GM-005 GM-008 | Sections A, D and K (device and people) |
| GM-012 GM-013 GM-014 GM-015 GM-016 GM-017 | Section F (device) |
| GM-018 GM-019 GM-020 GM-026 GM-027 GM-030 | Sections D and E (device) |
| GM-024 | Section A step 5 and a person trying topic choices (device) |
| GM-025 | Section J (human review) |
| GM-028 | Section G (device and network capture) |
| GM-029 | Section H (device) |
| GM-031 GM-034 | Section I (device) |
| GM-032 GM-033 GM-039 | Section K (people, store configuration) |
| GM-040 | This document and the records it asks for |
| GM-009 | Unshipped prototype behind `GM_EXPERIMENTS`; pilot evidence (Section K) must choose it before it ships |
| GM-010 GM-011 GM-036 | Not started: R2 evidence gate (pilot results) must choose and approve first |
| GM-021 GM-022 GM-035 GM-038 | Deferred: R3, needs explicit approval and its own review |
