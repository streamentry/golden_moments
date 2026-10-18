# Network and privacy boundary audit (GM-028)

Date: 2026-10-18. Scope: source and manifests at the commit that adds this file. **This is a static review, not a runtime traffic capture and not the native-build audit.** The `privacy_and_sdk_audit` release gate stays `pending`. Behavior of a built binary can differ from source, so no claim below extends to what an installed app transmits.

Machine-checked guard: [`tests/test_network_boundary.py`](../../tests/test_network_boundary.py) runs in the existing Python CI job. A failure means a network-capable path changed and needs a privacy decision plus an update here.

## What the source shows

| Question | Finding | Evidence |
| --- | --- | --- |
| Does startup initialize Firebase or any backend? | No. `bootstrap.dart` loads local sound settings and runs the app; nothing in `lib/` calls `initializeApp`. | `test_firebase_is_never_initialized_by_the_app` |
| Do the gentle activities, photo import, annotations, sessions or preferences contain network code? | No network packages, raw sockets or Firebase references in `lib/features/gentle_activities/`, `bootstrap.dart`, `main.dart` or the native home selector. | `test_local_photo_features_and_startup_have_no_network_code` |
| Is there any network code in the Dart source? | No. The legacy remote-pack downloader (HTTP client, image cache, download manager, downloads page, connectivity probe and offline indicator, about 6,900 lines that no screen could reach) was removed at the maintainer's instruction. No Dart file imports an HTTP, image-network or Firebase package, and none opens a connection. Older installs' stored files are not touched. | `test_no_dart_code_imports_a_network_or_firebase_package`, `test_no_dart_code_opens_a_connection`, `test_the_remote_pack_downloader_stays_removed` |
| Hard-coded URLs | All user-initiated: the Play Store link in share text; the help, privacy and terms addresses shown as copyable text on the Help page (never opened by the app); and the public website base for the privacy, terms, safety and support pages, which `LegalInfoPage` opens in the external browser (`url_launcher`) only after a tap. Viewing either page makes no request. | `test_hard_coded_urls_are_known_user_initiated_links` |
| Analytics and crash reporting | Collection is disabled in the Android manifest (`firebase_analytics_collection_deactivated`, `firebase_crashlytics_collection_enabled=false`) and iOS `Info.plist` (`FIREBASE_ANALYTICS_COLLECTION_DEACTIVATED`, `FirebaseCrashlyticsCollectionEnabled=false`). | `test_android_manifest_...`, `test_ios_plist_...` |
| Sensitive permissions | iOS declares only `NSPhotoLibraryUsageDescription` (the picker); no tracking, camera, microphone, location or contacts keys. The Android main manifest requests none of camera, microphone, location, contacts, media-read or notification permissions. | same tests |

## What this does not establish

1. **Firebase is kept, but collection stays off.** By the maintainer's decision the Firebase packages stay (possible later engagement measurement), although no Dart code uses them. `firebase_core`, `firebase_analytics` and `firebase_crashlytics` are dependencies and `google-services.json` / `GoogleService-Info.plist` are present. Android's `FirebaseInitProvider` can initialize the default app at process start without any Dart call, and library manifests may add `INTERNET`/network-state permissions to the **merged** release manifest. The main manifest declares no `INTERNET` permission, but the merged result has not been inspected. Disabled collection flags are not proof of zero traffic.
2. **No runtime capture.** A clean install with network observation (airplane mode and a recording proxy), backgrounding, the picker flow and every explicit external action (share sheet, legal links) has not been run. Unexplained transmission is a release blocker.
3. **OS and store transports** (photo retrieval, device backup of app data, store delivery, share destinations) are outside the app's control. The in-app guide mentions device backups and that the app does not upload copies; it does not describe the other transports, which the privacy policy must cover.
4. **iOS App Privacy answers and any required privacy manifest** have not been checked against the linked SDKs.
5. **Web catalog** (`MainNavigation` on web) is a separate surface and is not covered by mobile claims.

## Remaining actions

- Build release Android/iOS and inspect the merged Android manifest and iOS privacy manifests; record the result here.
- Capture traffic on a clean install on a physical device; record device, OS, build, conditions and the observed hosts (expected: none from the app).
- Firebase stays linked with collection disabled. Enabling any collection needs its own privacy decision first (policy and App Privacy answers, a consent design suited to older adults and caregivers, no streaks or pressure metrics). Removing the packages later would need native regression review. Seven unused packages (`http`, `cached_network_image`, `disk_space_plus`, `path`, `percent_indicator`, `pool`, `web`) were removed with the downloader; build iOS and Android once to confirm the native projects regenerate cleanly.
- Update the privacy policy and App Privacy form only after the above matches.
