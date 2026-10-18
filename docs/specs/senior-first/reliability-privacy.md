# Reliability, privacy and lifecycle

Feature phase/state: [catalog](feature-catalog.json). Current file boundaries are in [offline photos](../offline-photos.md). These requirements constrain future implementation; they do not claim the existing binary has passed a privacy/security audit.

## GM-027

**Preserve owned data through change.**

Acceptance:
- Keep bundle/package identities, pack IDs and current storage paths compatible. Add versioned preferences/annotation/session schemas rather than silently reinterpreting existing manifests.
- Validate IDs and reject external paths; use serialized, failure-safe mutations, temporary/staging files and atomic index replacement where supported. Do not follow a symlink outside the owned directory.
- Corrupt required data produces recovery choices, not an automatic reset. Recovery previews what can be retained; do not overwrite the only original manifest before a verified migration completes.
- Distinguish Hide, remove-from-album, delete-app-copy and remove-all. Deletion clears owned references, annotations and eligible orphan copies while preserving originals and unrelated files.
- Explain OS backup behavior. An in-app delete does not remotely erase a previous device backup or a file a relative already received. No secure-erasure or vault-grade-encryption promise without proof.

Test: migration fixtures, process interruption at each mutation boundary, concurrent operations, disk-full failures, symlink/path traversal, orphan cleanup, corrupt/old schema, and restart after deletion.

## GM-028

**An auditable no-backend/no-photo-upload boundary.**

Acceptance:
- Installed starter/catalog/local-copy use makes no app-controlled network request. No account, AI processing, photo upload, hidden diagnostics endpoint or new advertising/analytics SDK.
- Audit linked packages, native initializers, manifests, persisted collection settings and runtime traffic. Firebase dependencies being present or inactive do not alone prove what a binary transmits.
- Distinguish app traffic from OS photo retrieval, device backups, store delivery and explicitly initiated support/purchase transport. Do not claim that iCloud-only originals are available offline before import.
- Local descriptions and preferences are not diagnoses. Do not collect or derive disease stage, cognition, medication or health outcomes from taps.
- A privacy policy and App Privacy answers must match observed behavior. Removing or changing existing SDKs needs dependency/native regression review, not just deleting imports.

Test: clean install with traffic observation, blocked network, upgraded persisted settings, cancelled picker, app background/foreground, and every explicit external action. Unexplained transmission is a release blocker.

## GM-029

**Responsive on ordinary supported devices.**

Acceptance:
- Choose and record the oldest supported physical iPhone/iPad/Android baseline from actual deployment targets. Do not silently raise minimum OS/hardware to meet a performance goal.
- Proposed starting budget: cold launch to an interactive home within 3 seconds at the 95th percentile across at least 20 measured runs on that baseline. Record distribution, build mode and conditions; revise only with evidence and approval, never advertise an unmeasured number.
- Profile UI/raster time during matching, browsing and normalized-photo import against the device refresh interval. A debug build or one fast desktop run is not performance evidence.
- Bound decode dimensions, in-memory images and concurrent work. Dispose codecs/subscriptions; move genuinely expensive work away from the UI execution path where appropriate. Show cancellable progress for imports rather than blocking navigation indefinitely.
- Track bundle/asset and memory changes against the previous build. A proposed >10% regression requires explanation and acceptance; this is a review trigger, not an existing benchmark.

Test: release/profile build, low-memory device, maximum collection, repeated session entry/exit, large image batch, and 20-minute use without progressive memory growth or excessive heat.

## GM-030

**Graceful failure, never a blank dead end.**

Acceptance:
- Enumerate empty collection, missing file, invalid image, low storage, denied access, interrupted picker, incompatible data and unsupported platform states. Each has readable explanation, Cancel/Back and a safe next action.
- Import fails without invalidating existing valid copies. Disk failure is not reported as a successful save. A repaired optional preference never deletes primary user data.
- Retry is deliberate and bounded; no infinite spinner, automatic repeated prompt or network retry loop in an offline activity.
- Resume and content errors may offer included activities but never silently restore a hidden/deleted picture. Failure logs contain no personal photo names, raw paths, EXIF or diagnosis.

Test: injected failures at service boundaries plus native permissions/storage cases. Record the exact behavior rather than only asserting that an exception was caught.

## GM-031

**Useful support without collecting family memories.**

Acceptance:
- An offline Help/Privacy screen includes usable contact information and short troubleshooting steps. A mail/browser action is explicit, outside gameplay, and cancellable.
- An optional diagnostic summary includes app/build/platform and a sanitized error code only, reviewed by the user before sharing. No automatic attachments, photo contents, hashes, filenames, captions, device identifiers or full logs.
- No-mail-app and offline cases show a copyable support address and local guidance. Opening support cannot clear session or collection data.
- Support and rating requests are separate. Users can report problems without being asked whether they like the app or being redirected away from a public review.

Test: no mail client, cancelled share, offline support, long error text, and seeded sensitive strings that must not enter the export.
