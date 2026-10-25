# iOS 1.4.1 build 8 release record

**State (2026-10-25):** build 8 is uploaded, processed as `VALID` and attached
to App Store Connect version 1.4.1. The maintainer submitted it for review:
submission `978c3498-fdc1-4076-9485-3271be222960`, submitted Oct 25, 2026 at
7:02 PM (App Store Connect local time), read back as **Waiting for Review**
with 1.4.1 (8) as its only item. 1.4.0 stays Ready for Distribution until
1.4.1 is approved and released automatically. This is not Apple approval or
storefront availability.

## Why this release

The legal and help pages moved from `streamentry.github.io/golden-moments-web/`
to `https://dementiaactivities.games/` (PR #91, deployed and checked with
`pnpm check:live`). 1.4.1 changes the in-app links (Help page copyable URLs and
the Privacy, terms and support page) and carries the new store URLs. No feature
or data-handling change.

## Source and checks

Built from PR #93 head `a497af1` (later commits on the PR change only
`metadata/` and this record). The temporary signing override (team
`7MBXZKYSY4`, manual signing, profile `Golden Moments App Store 2026-10-18`)
was scoped to the Runner Release configuration and reverted after archiving.

- Flutter 3.47.7; Xcode 27.1; minimum iOS 15.
- `dart format --set-exit-if-changed lib test`, `flutter analyze --fatal-infos
  --fatal-warnings`: passed.
- `flutter test --coverage`: 430 passed. Python checks: 64 passed.
  `python3 scripts/release_metadata.py --check`: passed.

**Build fix found while archiving.** The first archive linked only
`Flutter.framework`: Flutter 3.47.7 turns Swift Package Manager on by default,
and with this project's custom Podfile every plugin (image picker,
url_launcher, share_plus, audioplayers, shared_preferences) was dropped. That
IPA was never uploaded. `pubspec.yaml` now sets
`flutter: config: enable-swift-package-manager: false`; the rebuilt app links
the same six plugin frameworks as build 7 and `Podfile.lock` is unchanged.

## Artifact

- `codesign --verify --deep --strict`: passed. Signed by `iPhone Distribution:
  CLOUDJET SOLUTIONS PTE. LTD. (7MBXZKYSY4)`; every embedded framework is
  distribution-signed. Bundle `com.mindfulness.goldenmoments`, 1.4.1 (8),
  `ITSAppUsesNonExemptEncryption=false`, privacy manifests present.
- The Dart snapshot contains the new domain and no `golden-moments-web` URL.
- IPA 33,093,757 bytes; SHA-256
  `55daa33d57cf55ecab56720d8ef2f039efa16b068385674ef2d4ecab4014eb96`.
  Local copies: `output/release/ipa-1.4.1-8/` and
  `output/release/Golden-Moments-1.4.1-8.xcarchive` (not committed).
- `altool --validate-app`: no errors. Uploaded with the team's App Manager API
  key; delivery `be493385-967b-424e-a9f2-0aba5c013f3a`; processing `VALID`.

## Store metadata

Version 1.4.1 has the canonical promotional text and the 1.4.1 release notes
from `metadata/app-store.en-US.json`, support URL `/help/`, marketing URL `/`,
and (shared app information) privacy policy `/app-privacy/` and privacy choices
`/privacy-choices/`. Release type: automatic after approval, to all users,
keeping existing ratings. Screenshots and review notes carry over from 1.4.0.

## Remaining release evidence

Unchanged from 1.4.0: physical-device picker and upgrade cases, screen-reader
walkthroughs, caregiver comprehension, runtime traffic and privacy review, legal
review and inherited image and font rights remain pending. Not run for this
build: a device or simulator launch of the signed app, and opening each new
link on a device.
