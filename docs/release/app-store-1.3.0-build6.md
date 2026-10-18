# iOS 1.3.0 build 6 review evidence

Recorded 2026-10-19. Base `c3fcd03`, plus the photo annotation-save busy-state fix
and support-version/build-number updates in this PR. Capture-only Xcode test and
signing overrides are excluded from source changes. Bundle identity is preserved.

## Reproducible source checks

Using pinned Flutter3.47.7 / Dart3.13.5:

- `flutter analyze --fatal-infos --fatal-warnings`: no issues.
- `flutter test --coverage`: 189 passed; the full suite includes the save regression.
- Focused gentle photo tests: 16 passed.
- `python3 -m unittest discover -s tests -p 'test_*.py' -v`: 56 passed.
- `python3 scripts/release_metadata.py --check`: canonical/export agreement passed.
- The missing-screenshot regression uses an explicit missing-path fixture now that
  the real metadata contains final paths; its assertions remain intact.
- Independent read-only review of the save fix: no findings. Independent static
  review of all 12 screenshots and revised claims: no blocking findings; neither
  reviewer claimed separate native execution or legal clearance.

The fix marks annotation writes busy and disables conflicting photo controls
until I/O completes, with a mounted-guarded finally. This prevents another edit
from beginning with stale annotations. It does not change the photo access boundary.

## Native candidate and captures

The signed IPA is 31,734,441 bytes; SHA-256:
`2b54c302e15b71a721feece758727160385a681f61c7cf631cab30a8a67e6519`.
Apple validation and upload succeeded. App Store Connect build
`0456db2d-1a84-4253-a744-fae96b13489f` is VALID, version1.3.0 build6, minimumiOS15.
No Firebase/GoogleService-Info files are present in the archive. This is static
archive evidence, not a traffic-capture audit. Apple's90076 warning notes the
previous team prefix differs; previous-version physical-device migration remains
untested. Source has no Keychain/auth storage feature to migrate.

Separate iPhone16ProMax and iPadPro13-inch(M4), iOS18.5 simulators ran the exact
candidate runtime. Installed debug kernel hashes and build6 were checked against
the frozen build. XCTest sessions passed after native picker selection of two
synthetic photos, a four-tile imported-photo game, shared viewing, comfort sheet,
starter pair matching and library navigation. No personal photos were accessed.
The iPad session was repeated with settled navigation to remove a transition
artifact. This is simulator evidence, not physical-device or screen-reader QA.

The 12 final JPEGs are1320x2868(iPhone) and2064x2752(iPad), RGB with no alpha.
Original PNGs, native-picker proof, file hashes, generation prompts and composition
notes: [capture register](../../assets/screenshots/en-US/README.md).
The app UI is genuine; built-in image generation supplied only decorative paper
and two fictional photos. The existing Classic Cars light-bulb thumbnail mismatch
is retained in the library capture and remains a separate catalog-quality issue.

## Store state and remaining gates

Version ID `b134cf66-ccdd-43a7-b8c9-325ac81237e6` uses build6. All12 screenshots
completed processing; final ordering and MD5 values match local JPEGs. Name,
subtitle, descriptions, notes and links match canonical metadata. The app privacy
URL is the live `/app-privacy/` page. US-English fallback was explicitly selected:
17 obsolete draft locales were removed after protected backup, leaving the
published1.0's18 locales untouched. Public release type is MANUAL.

The owner explicitly requested submission for App Review. This does not mark the
broader release checklist passed. `scripts/release_metadata.py --release` still
fails for unverified capabilities, Android recovery, airplane-mode tests, migration,
physical-device accessibility, caregiver comprehension, medical/intended-use review,
complete privacy/store configuration and inherited asset-rights sign-offs.
No validator or gate was weakened. Complete those checks before manual public
release; approval by Apple is a separate outcome.

Android upload is separate and has not been submitted by this iOS screenshot task.

## Confirmed review submission

Apple API readback at2026-10-18T17:44:55Z: submission and version both
`WAITING_FOR_REVIEW`, attached build6, release type`MANUAL`. Submission ID
`5fca1044-73d9-4a09-b611-104733ab5306`. Sanitized receipts are in
`docs/release/evidence/`. This confirms review queue entry, not approval or publication.
