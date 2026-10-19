# Local-photo architecture

## Decision and flow

Keep Flutter and explicit photo selection on iOS/Android; no new backend. One collection in `ApplicationSupport/family_photos_v1` is sufficient initially.

System picker -> bounded decode/resize -> fresh PNG pixels -> hash-named local file -> atomic JSON manifest -> matching/shared viewing. OS download of iCloud-only originals and OS backup are separate behaviors, not app-managed family sync.

## Storage

Manifest: `{ "version": 1, "photos": ["<sha256>"] }`. IDs are lowercase 64-character hashes; copies are `<id>.png`. No external paths, names, URLs, EXIF, GPS, diagnoses or face identities are indexed. Deduplication compares normalized content, not faces.

Bounds: 24 photos, 20 MiB source-file check, at most 40 million decoded pixels, within 1024x1024 output preserving aspect ratio, and 2 MiB maximum normalized copy. Oversized or undecodable inputs fail without changing the original collection. These are engineering limits, not camera compatibility promises.

Mutations are serialized, across every store instance on the same folder. Validate a batch before modifying the manifest. Every file (copy, manifest, annotations sidecar) is written to a `.tmp` staging file, flushed and renamed into place; failure preserves the old file and removes what the failed step wrote. Write copies before replacing the index atomically; failure preserves the old index. Deletion removes indexed references before owned copies. Each load removes staging files and, when a readable manifest exists, hash-named copies it does not list. Without a manifest, copies whose content matches their name are adopted (shown, and recorded by the next change), never removed. Only a genuine "no such file" means a manifest or copy is absent; a file or folder that cannot be inspected or read is an error, never an empty collection. Changes start from the manifest as written, so a copy that is unreadable for a moment keeps its reference and its file, and photo details are pruned only for photos the manifest no longer lists. A details sidecar from a newer app version is never shown, moved or replaced (saving reports failure); a damaged one is moved aside only after the new details are staged, and put back if they cannot be renamed in. Remove-all also cleans hash-named orphan PNGs, not unrelated files. Symbolic links are never followed: a linked folder or manifest is refused, a linked copy is treated as missing, and links are unlinked without touching their targets. Corrupt manifests are surfaced, not overwritten. Only at the person's request ("Show the photos that can be checked", after a confirmation), a manifest whose content is damaged is renamed aside as `collection.damaged-<time>.json`, never deleted. The copies whose content matches their names are then adopted as above, with their details. A copy whose content does not match its name is not adopted, and it is tidied away by the next change; the confirmation says so, and that the originals in the photo library are unchanged. A manifest whose version is any number above 1 (a newer app wrote it), a link, or anything other than a plain file is never moved, and a newer one asks the person to update the app. A failure to read the manifest is reported as an error to retry, never treated as damage. Remove-all also removes lists kept aside, since they name only photos that are gone. When the collection cannot open, the problem and its way forward come first on the screen. A known narrow case: with more than 24 verified copies on disk after a failed cleanup, the oldest 24 are adopted, which may include a photo the person had removed. Injected failures at each boundary are covered by tests; real disk-full, process-kill and failed-cleanup behavior still need device QA.

## Permissions and lifecycle

`image_picker` was initially pinned at 1.1.2 and now resolves `^1.2.4` (2026-10-18 upgrade; 1.2.3 fixes `pickMultiImage(limit: 1)`, which this app already avoids by using `pickImage` for a single slot). Real-device HEIC and Android lost-data validation of 1.2.4 has not been run. Revalidate and resolve its platform dependencies against the SDK in `.fvmrc` and `pubspec.yaml`. Set `requestFullMetadata: false` and re-encode pixels. iOS permission text explains selection; no camera or microphone functionality is introduced.

Android lost selections are recovered through the plugin with confirmation before import. Test HEIC and iCloud-only originals on hardware. Cancellation is not an error. Removing an original after import must not remove the app copy.

## Platform entry and migration

`lib/app/view/platform_home.dart` conditionally selects native versus browser entry. iOS/Android receive GentleHomePage; browser/desktop retain MainNavigation. Native IO/photo-picker imports are excluded from the browser entry graph.

Mobile bootstrap loads local settings without Firebase, HTTP or downloads. The explicit mobile library action opens the bundled catalog immediately. Browser and desktop also start without Firebase or pack downloads. All catalog image fields resolve to bundled assets; legacy downloaded files remain untouched. Responsive layout, completion counting, dependencies, and visual flows from PR #43 are retained.

Bundle IDs, pack/image IDs, field names, preferences and existing download locations remain unchanged. Catalog image values now identify packaged assets. Tests and release gates must verify existing installations; preserving source paths alone is not migration proof.

## Privacy and no-sync boundary

Firebase was removed (analytics, crash reporting and core, with their native configuration). Audit linked SDKs, native initializers and traffic in a native build before asserting no tracking/no collection; the stale iOS `Podfile.lock` and SwiftPM `Package.resolved` still pin Firebase until regenerated on a Mac. PR #47 also removed browser Firebase/CDN startup. Browser and native privacy evidence must still be recorded separately.

Photos are snapshots, not watched originals. Device backup may contain copies. No CloudKit sharing, family sync, live-link service or automatic revocation. Deck-file exchange remains deferred.

## Proposed extensions, not current behavior

[Senior-first photo requirements](senior-first/personal-photos.md) specify optional descriptions, favorites, and conditional albums/file exchange. [Reliability requirements](senior-first/reliability-privacy.md) specify migration and failure acceptance. These do not alter the current manifest or quotas. Any future sidecar/schema migration needs a separate implementation and preservation tests. File sharing requires archive limits, traversal/decompression protection and recipient preview before approval.

References: [image_picker](https://pub.dev/packages/image_picker/versions/1.2.4).
