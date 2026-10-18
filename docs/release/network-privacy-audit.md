# Network and privacy boundary audit (GM-028)

Date: 2026-10-18. Scope: source and manifests at the commit that adds this file. **This is a static review, not a runtime traffic capture and not the native-build audit.** The `privacy_and_sdk_audit` release gate stays `pending`. Behavior of a built binary can differ from source, so no claim below extends to what an installed app transmits.

Machine-checked guard: [`tests/test_network_boundary.py`](../../tests/test_network_boundary.py) runs in the existing Python CI job. A failure means a network-capable path changed and needs a privacy decision plus an update here.

## What the source shows

| Question | Finding | Evidence |
| --- | --- | --- |
| Does startup initialize Firebase or any backend? | No. `bootstrap.dart` loads local sound settings and runs the app; nothing in `lib/` calls `initializeApp`. | `test_firebase_is_never_initialized_by_the_app` |
| Do the gentle activities, photo import, annotations, sessions or preferences contain network code? | No network packages, raw sockets or Firebase references in `lib/features/gentle_activities/`, `bootstrap.dart`, `main.dart` or the native home selector. | `test_local_photo_features_and_startup_have_no_network_code` |
| Where is network-capable code? | A legacy remote-catalog downloader (`HttpClientService`, `LongTermImageCache`, `DownloadManager*`, `DownloadedPacksCubit`, a connectivity probe that resolves `google.com`, and an offline indicator). | `test_network_packages_are_imported_only_by_the_legacy_island`, `test_raw_network_io_is_confined_to_the_legacy_island` |
| Can a screen reach that code? | By static search, no: the downloader page, cubit, cached-image widget, connectivity service and offline indicator are referenced only from each other, and nothing outside them starts a download. `NavigationCubit` constructs the `DownloadManager` singleton and reads its status; construction makes no request. Static search cannot prove the absence of a dynamic path. | `test_no_screen_references_the_legacy_network_classes`, `test_downloads_are_only_started_inside_the_legacy_island` |
| Hard-coded URLs | Two: a placeholder pack-catalog location on `raw.githubusercontent.com` (inside the unreachable legacy code) and the Play Store link used in user-initiated share text. | `test_hard_coded_urls_are_the_two_known_ones` |
| Analytics and crash reporting | Collection is disabled in the Android manifest (`firebase_analytics_collection_deactivated`, `firebase_crashlytics_collection_enabled=false`) and iOS `Info.plist` (`FIREBASE_ANALYTICS_COLLECTION_DEACTIVATED`, `FirebaseCrashlyticsCollectionEnabled=false`). | `test_android_manifest_...`, `test_ios_plist_...` |
| Sensitive permissions | iOS declares only `NSPhotoLibraryUsageDescription` (the picker); no tracking, camera, microphone, location or contacts keys. The Android main manifest requests none of camera, microphone, location, contacts, media-read or notification permissions. | same tests |

## What this does not establish

1. **Firebase is still linked.** `firebase_core`, `firebase_analytics` and `firebase_crashlytics` are dependencies and `google-services.json` / `GoogleService-Info.plist` are present. Android's `FirebaseInitProvider` can initialize the default app at process start without any Dart call, and library manifests may add `INTERNET`/network-state permissions to the **merged** release manifest. The main manifest declares no `INTERNET` permission, but the merged result has not been inspected. Disabled collection flags are not proof of zero traffic.
2. **No runtime capture.** A clean install with network observation (airplane mode and a recording proxy), backgrounding, the picker flow and every explicit external action (share sheet) has not been run. Unexplained transmission is a release blocker.
3. **OS and store transports** (photo retrieval, device backup of app data, store delivery, share destinations) are outside the app's control. The in-app guide mentions device backups and that the app does not upload copies; it does not describe the other transports, which the privacy policy must cover.
4. **iOS App Privacy answers and any required privacy manifest** have not been checked against the linked SDKs.
5. **Web catalog** (`MainNavigation` on web) is a separate surface and is not covered by mobile claims.

## Remaining actions

- Build release Android/iOS and inspect the merged Android manifest and iOS privacy manifests; record the result here.
- Capture traffic on a clean install on a physical device; record device, OS, build, conditions and the observed hosts (expected: none from the app).
- Decide separately whether to remove the dead legacy downloader and the Firebase dependencies. Removal needs native regression review, not only deleting imports, and is not done here.
- Update the privacy policy and App Privacy form only after the above matches.
