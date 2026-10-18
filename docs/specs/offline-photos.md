# Local-photo architecture

## Decision and flow

Keep Flutter and explicit photo selection; no new backend. One collection in `ApplicationSupport/family_photos_v1` is sufficient initially.

System picker -> bounded decode/resize -> fresh PNG pixels -> hash-named local file -> atomic JSON manifest -> matching/shared viewing. OS download of an iCloud-only original and OS backup are separate behaviors, not app-managed family sync.

## Storage

Manifest: `{ "version": 1, "photos": ["<sha256>"] }`. IDs are lowercase 64-character hashes; copies are `<id>.png`. No external paths, names, URLs, EXIF, GPS, diagnoses or face identities are indexed. Deduplication compares normalized content, not faces.

Bounds: 24 photos, 20 MiB source-file check, at most 40 million decoded pixels, within 1024x1024 output preserving aspect ratio, and 2 MiB maximum normalized copy. These are engineering limits, not camera compatibility promises.

Mutations are serialized. Validate a batch before modifying the manifest. Write copies before replacing the index atomically; failures preserve the old index. Deletions remove indexed references before owned copies. Remove-all also cleans hash-named orphan PNGs, not unrelated files. Corrupt manifests are surfaced, not overwritten. Disk-full, interruptions and failed cleanup need device QA.

## Permissions/lifecycle

`image_picker` 1.1.2 is pinned for the existing SDK baseline. Set `requestFullMetadata: false` and re-encode pixels. The iOS permission text explains selection; no camera or microphone functionality is introduced.

Android lost selections are recovered using the plugin and require confirmation before import. Test HEIC and iCloud-only originals on actual iOS hardware. Cancellation is not an error. Removing an original after successful import must not remove the app copy.

## Startup/migration/privacy

Bootstrap loads local settings without Firebase, audio, HTTP or download initialization. The optional library action initializes existing services. Bundle IDs, preferences, pack schema and download locations stay unchanged.

Firebase dependencies remain but native Analytics is deactivated and automatic Crashlytics reporting is disabled. Audit native initializers, persisted settings, linked SDKs and actual traffic on an upgrade install before claiming no tracking/no collection. Package configuration is not a privacy certification.

Selected images are snapshots; originals are not watched. Device backup may contain copies. There is no CloudKit sharing, CKShare, live-link service or automatic revocation. Deck-file exchange is deferred until bounded archive validation, traversal/zip-bomb protections and consent are specified.

References: [image_picker](https://pub.dev/packages/image_picker/versions/1.1.2), [Analytics controls](https://firebase.google.com/docs/analytics/configure-data-collection), [Crashlytics controls](https://firebase.google.com/docs/crashlytics/customize-crash-reports).
