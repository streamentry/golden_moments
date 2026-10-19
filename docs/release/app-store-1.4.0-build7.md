# iOS 1.4.0 build 7 release record

## Source and checks

Candidate tree on main: `7738d7f8b4407297086a30ec13f75acace976ddf` (PR #86).
The archive was built from PR head `5f825eece2d6ea9822b1c763f79325c77f4dfe48`;
that tree matches the merged main tree. It includes the synchronized local
CocoaPods lock and embed phase. The temporary signing override was scoped to
the Runner Release configuration and restored after archiving.

- Flutter 3.47.7 / Dart 3.13.5; Xcode 27.1; minimum iOS 15.
- `flutter analyze --fatal-infos --fatal-warnings`: passed, no issues.
- `flutter test --coverage`: 430 tests passed.
- `python3 -m unittest discover -s tests -p 'test_*.py' -v`: 63 tests passed.
  Three ignored `.DS_Store` files were moved aside temporarily for the asset
  provenance check and restored unchanged.
- `python3 scripts/release_metadata.py --check`: passed.
- All seven hosted checks for PR #86 passed.
- Xcode archive and App Store export succeeded. `codesign --verify --deep
  --strict` passed. The bundle is `com.mindfulness.goldenmoments`, version
  1.4.0, build 7, Team 7MBXZKYSY4. Info.plist says
  `ITSAppUsesNonExemptEncryption=false`. The app and plugin privacy manifests
  are present in the archived app.

The exported IPA is 33,343,308 bytes; SHA-256:
`0bf8a55fbd9f92ac998f0a017df23afc1860b62c46a1e60fe4c9006dfcdecbeb`.
Apple validation passed without errors. App Store Connect build
`b8fc04e4-e8e8-4205-8008-ef0d11f103e7` processed as **VALID** with encryption
exemption set to false.

## Store metadata and review

App Store Connect version `909ef499-6635-48c9-b726-665f1536299e` is version
1.4.0 with en-US localization only. Name, subtitle, description, keywords,
promotional text, release notes, support and marketing URLs, app privacy URL,
and review instructions were saved and read back. Review instructions say that
no account is needed and describe the family-photo album-print flow.

All six iPhone and six iPad screenshots are **COMPLETE**. Apple’s checksums match
the committed JPEGs. They were captured from the real app with generated demo
photos; no personal family photos were used. The 12 frames were visually
reviewed, including the updated pack-library and album-print experience.

Submission `0261a5a0-fd3f-434c-82cf-d01f5440dd01` is **WAITING_FOR_REVIEW** with
build 7 attached. Version release type is **AFTER_APPROVAL**, so Apple approval
will trigger automatic release. This is not Apple approval or storefront
availability.

## Remaining release evidence

The release status remains fail-closed for physical-device picker and upgrade
cases, screen-reader/accessibility walkthroughs, caregiver comprehension,
runtime traffic/privacy review, legal review and inherited image/font rights.
The signed archive’s manifests are static evidence, not a runtime network audit.
These gates remain pending and are not represented as passed by this submission.


## Store state readback

At 2026-10-19 19:20 UTC, App Store Connect reported build 7 `VALID`, the version
and review submission as `WAITING_FOR_REVIEW`, and release type `AFTER_APPROVAL`.
Version 1.3.0 had reached `READY_FOR_SALE`. The en-US listing fields and all 12
screenshot files were read back; each Apple screenshot checksum matches its local
file. A sanitized receipt is in `output/release/release-1.4.0-build7-submission.json`
and the protected `backups/golden-moments-ios-20261018/release-build7/` bundle.
No signing or API key was copied to that backup.
