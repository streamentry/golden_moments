# iOS 1.4.0 build 7 release record

Candidate source: `9ff8c1b72c353df266cb3f39bfe467162581ac5d` plus the
CocoaPods lock and Xcode project integration in PR for this record. Flutter
3.47.7 / Dart 3.13.5; Xcode 27.1; iOS deployment target 15.0.

## Source checks

- `flutter analyze --fatal-infos --fatal-warnings`: passed, no issues.
- `flutter test --coverage`: 430 tests passed.
- Python release and repository checks: 63 tests passed after temporarily
  moving aside and restoring three ignored macOS `.DS_Store` files from the
  screenshot folders. No asset files were deleted.
- `python3 scripts/release_metadata.py --check`: passed.
- Latest main workflows for the candidate commit: both successful.

## App Store draft

App Store Connect version 1.4.0 is already created. It has six iPhone and six
iPad screenshots, all in `COMPLETE` state. Each stored screenshot checksum
matched its committed local JPEG. The canonical en-US description, keywords,
promotional text, support/marketing URLs and release notes were saved and read
back. Review notes describe the album-print feature; no sign-in is required.
Automatic release after approval is selected.

## Native artifact and remaining checks

The signed archive/IPA and Apple processing result will be recorded here after
the archive succeeds. Native picker/device checks, accessibility walkthroughs,
caregiver comprehension and inherited asset-rights review remain separate
pending gates. Do not infer these from a valid archive or store approval.
