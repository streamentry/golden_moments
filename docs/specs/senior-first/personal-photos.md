# Personally meaningful pictures without a server

Feature phase/state: [catalog](feature-catalog.json). The current [local-photo architecture](../offline-photos.md) owns existing limits and storage format. Future annotations/albums require an additive migration decision; this specification does not change files or authorize uploads.

## GM-018

**Selected-photo import that preserves originals.**

Acceptance:
- Use explicit system-picker selections, not full-library scanning or background album watching. Cancellation is neutral; no camera or microphone is required.
- Retain the current 24-copy collection and documented decode/size limits unless a later measured decision changes them. Validate all inputs and normalize independent copies without EXIF/GPS metadata.
- Preview orientation and avoid unintended cropping. HEIC and originals stored only in iCloud require real-device checks; selecting a cloud-only original may require network even though an imported copy works offline.
- Deduplicate by normalized content, not face identity. Explain limits before selection where possible. A rejected batch cannot erase previously valid photos.
- Recover interrupted Android picker selection with confirmation, not silent import on every startup. A changed permission or removed original cannot destroy an existing app copy.

Test: cancel, partial access, cloud-only photo, HEIC, duplicates, too many items, oversized/invalid bytes, restart, low storage and original deletion.

## GM-019

**Optional captions and accessibility descriptions.**

Acceptance:
- Let a user add a brief local caption and optional descriptive text; neither is required for play. Do not auto-identify people, infer relationships, or ask for diagnosis.
- Descriptions are plain text with explicit length limits and normalization; treat imported text as data, never executable markup or agent instructions. Preserve visible meaning when wrapping text.
- Show captions in viewing only by choice. Never expose hidden-card answers through caption, audio, semantics or export metadata unexpectedly.
- An additive, versioned sidecar maps existing stable photo IDs to annotations. Missing/corrupt optional annotations cannot invalidate the original collection. Deletion cleans the associated annotations.

Test: old collection migration, absent/long/non-Latin text, malformed sidecar, stale ID, hidden-card semantics, repeated edits and rollback.

## GM-020

**Favorites, hide and repeat.**

Acceptance:
- A simple favorite action makes an enjoyed picture or included pack easy to find. No popularity score, public profile or automatic emotional assessment.
- Hide removes an image from suggestions, replay and all automatic selections without deleting its stored copy. Undo is visible and persistent, not a short countdown.
- Delete remains distinct from Hide and removes app-owned references/copies according to the data contract. The original library file is untouched.
- Favorites/hides persist locally and are respected across every activity, resume and later sharing preview. Empty eligible sets fall back to chosen included content without silently unhiding images.

Test: hidden favorite, all items hidden, missing file, reimport, restart, session referencing a hidden picture, and consistent filtering across modes.

## GM-021

**Small local albums - deferred.** One collection is enough until users demonstrate a need for separation.

Acceptance if approved:
- Add bounded named albums without separate family accounts. A proposed initial cap is five albums while retaining the existing global photo-byte/count budget; any larger budget needs measured memory/storage evidence.
- Album deletion does not delete a shared photo still referenced by another album. Show affected copies and confirm irreversible deletion separately.
- Migrate the current collection into a default album without changing stable photo IDs or losing annotations. Keep a recoverable original manifest until migration is verified.
- Manual ordering and titles are optional. No mandatory tagging workflow before play, and no automatic diagnosis/person classifier.

Test: shared references, delete/undo, repeated migration, interruption, quota exhaustion, old-app upgrade and an empty default album.

## GM-022

**Portable photo packs - deferred, not sync.** A relative may eventually share selected copies through the OS share sheet without an app-managed server.

Acceptance if approved:
- A preview shows exactly which photos and optional captions will leave the app. Hidden items are excluded by default. Confirm the user has permission to share; never auto-send or include an entire collection implicitly.
- Define a versioned data-only archive: manifest plus normalized images, with explicit entry-count, compressed/uncompressed size, dimension and total-byte limits. Reject path traversal, absolute paths, symlinks, duplicate entries, nested archives and decompression bombs before committing.
- Recipient imports into a staging area, validates all content and capacity, then commits atomically. Cancellation, malformed archives and insufficient space preserve the existing collection. Do not trust external filenames or HTML.
- Sharing is a copied snapshot: no live updates, remote revocation or family access-control promise. Messaging/iCloud/AirDrop are OS/recipient transports with their own behavior, not proof that no server anywhere is involved.
- No exported diagnosis or activity history. State whether exported packs are unencrypted, advise appropriate transport, and avoid unsupported end-to-end-encryption claims.

Test: adversarial archive fixtures, unknown schema, quota exhaustion, partial transfer, duplicate content, recipient without the app and cancelled share. This requires its own threat model and authorization before implementation.
