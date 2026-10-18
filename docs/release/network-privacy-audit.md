# Network and privacy boundary audit (GM-028)

Date: 2026-10-18. Scope: source and manifests at the commit that adds this file. **This is a static review, not a runtime traffic capture and not the native-build audit.** The `privacy_and_sdk_audit` release gate stays `pending`. Behavior of a built binary can differ from source, so no claim below extends to what an installed app transmits.

Machine-checked guard: [`tests/test_network_boundary.py`](../../tests/test_network_boundary.py) runs in the existing Python CI job. A failure means a network-capable path changed and needs a privacy decision plus an update here.

## What the source shows

| Question | Finding | Evidence |
| --- | --- | --- |
| Does startup initialize Firebase or any backend? | No. Firebase is removed; `bootstrap.dart` loads local sound settings and runs the app. | `test_firebase_stays_removed_everywhere_it_could_collect` |
| Do the gentle activities, photo import, annotations, sessions or preferences contain network code? | No network packages, raw sockets or Firebase references in `lib/features/gentle_activities/`, `bootstrap.dart`, `main.dart` or the native home selector. | `test_no_dart_code_opens_a_connection` |
| Is there any network code in the Dart source? | No. The legacy remote-pack downloader (HTTP client, image cache, download manager, downloads page, connectivity probe and offline indicator, about 6,900 lines that no screen could reach) was removed at the maintainer's instruction. No Dart file imports an HTTP, image-network or Firebase package, and none opens a connection. Older installs' stored files are not touched. | `test_no_dart_code_imports_a_network_package`, `test_no_dart_code_opens_a_connection`, `test_the_remote_pack_downloader_stays_removed` |
| Hard-coded URLs | Two, both user-initiated: the Play Store link in share text, and the public website base for the privacy, terms, safety and support pages, which `LegalInfoPage` opens in the external browser (`url_launcher`) only after a tap. Viewing that page makes no request. | `test_hard_coded_urls_are_known_user_initiated_links` |
| Analytics and crash reporting | None linked in source: `firebase_core`, `firebase_analytics` and `firebase_crashlytics`, the Google-services Gradle plugin, `google-services.json`, `GoogleService-Info.plist` and the collection flags were removed. | `test_firebase_stays_removed_everywhere_it_could_collect` |
| Sensitive permissions | iOS declares only `NSPhotoLibraryUsageDescription` (the picker); no tracking, camera, microphone, location or contacts keys. The Android main manifest requests none of camera, microphone, location, contacts, media-read or notification permissions. | same tests |

## What this does not establish

1. **Firebase is removed from source and from the iOS build inputs.** The maintainer decided to remove it. On 2026-10-18 `ios/Podfile.lock` and the SwiftPM pins were regenerated on a Mac (Flutter 3.47.7, Xcode 27.1, CocoaPods 1.17.0): no pod remains besides Flutter, and both `Package.resolved` files were deleted because Firebase was the only remote Swift package. A `flutter build ios --release --no-codesign` of that commit embeds only `Flutter.framework` and `objective_c.framework`, its binary contains no `firebase`, Crashlytics, app-measurement or googleapis strings, the bundle identifier is unchanged and `Info.plist` declares only `NSPhotoLibraryUsageDescription`. The lock files are now guard-tested. This is a static build inspection, not a signed archive or traffic capture. Library manifests may still add `INTERNET`/network-state permissions to the **merged** Android manifest from other plugins; the merged result has not been inspected.
2. **No runtime capture.** A clean install with network observation (airplane mode and a recording proxy), backgrounding, the picker flow and every explicit external action (share sheet, legal links) has not been run. Unexplained transmission is a release blocker.
3. **OS and store transports** (photo retrieval, device backup of app data, store delivery, share destinations) are outside the app's control. The in-app guide mentions device backups and that the app does not upload copies; it does not describe the other transports, which the privacy policy must cover.
4. **iOS App Privacy answers and the app's own privacy manifest** have not been checked. The release build carries plugin privacy manifests (Flutter, share_plus, shared_preferences_foundation, url_launcher_ios, image_picker_ios) but no app-level `PrivacyInfo.xcprivacy`; whether one is needed for the app's own required-reason API use must be decided against Apple's current rules before submission.
5. **Web catalog** (`MainNavigation` on web) is a separate surface and is not covered by mobile claims.

## Remaining actions

- Build release Android/iOS and inspect the merged Android manifest and iOS privacy manifests; record the result here.
- Capture traffic on a clean install on a physical device; record device, OS, build, conditions and the observed hosts (expected: none from the app).
- Done for iOS build inputs (see item 1): lock files regenerated and the release build inspected. Still open: the same check on a signed archive. Re-adding any analytics or crash SDK needs its own privacy decision first (policy and App Privacy answers, a consent design suited to older adults and caregivers, no streaks or pressure metrics). Seven unused packages (`http`, `cached_network_image`, `disk_space_plus`, `path`, `percent_indicator`, `pool`, `web`) were removed with the downloader; build iOS and Android once to confirm the native projects regenerate cleanly.
- Update the privacy policy and App Privacy form only after the above matches.
