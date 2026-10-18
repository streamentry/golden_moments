# Flutter development for Golden Moments

Read for Dart, UI, persistence, plugin, or native changes. This guide adapts
[official guidance](sources.md) to the existing app; it does not mandate a rewrite.
The product and photo specifications remain authoritative for feature scope.

## Toolchain and dependencies

Use `.fvmrc`, `pubspec.yaml`, `pubspec.lock`, and the actual CI workflows together.
The inspected baseline on 2026-10-18 pins Flutter 3.47.7; read the current files
rather than copying that version into new scripts. Use Flutter's bundled Dart.
Do not run a broad upgrade or change minimum platform versions for convenience.

For a necessary package change, verify the exact API in official documentation
and the resolved package, supported platforms, minimum OS/toolchain, permissions,
license, maintenance, transitive SDKs, and data collection. Resolve the lockfile
with the pinned SDK and review generated native changes. Never invent lockfile
hashes or manually patch generated registrants. A higher version is not itself
an improvement. [F1, F2, F7 in the source register](sources.md).

## Architecture without migration churn

Keep the feature-first layout and current Bloc/Cubit, Provider, and local-state
patterns where they already fit. Flutter's architecture guidance is about clear
responsibilities, not requiring a switch to MVVM, Riverpod, or a new router.

| Responsibility | Repository application |
| --- | --- |
| Widgets | Layout, rendering, accessible actions, short UI-local state |
| Controller/Cubit | Feature transitions and orchestration when complexity needs it |
| Models | Validated data and matching rules independent of widget rendering |
| Store/service | Files, picker, downloads, and other platform effects |

Keep business rules and persistence out of `build`. Inject stores/pickers and
other effects at boundaries so tests can substitute them. Prefer immutable
snapshots across layers; encapsulate mutation already used by the board model.
A repository abstraction or domain layer is justified by real reuse/complexity,
not by a folder checklist. Avoid speculative abstractions and duplicate state.
Apply these improvements to touched code, not an unrelated full migration. [F1].

## Async work and lifecycle

Check the correct `mounted` property after an async gap before using context,
navigating, opening a dialog, or calling `setState`. A mounted check does not
cancel an operation: prevent duplicate submissions and stale-result overwrites.
Await work deliberately; give intentional background futures an error handler.
Dispose subscriptions, controllers, streams, codecs, buffers, and images owned
by the component. Do not launch I/O inside `build` or swallow a failed write as
success. Translate expected failures into a useful retry/cancel state without
printing private input. [F2, F3].

## Selected-photo storage

Extend [the existing contract](../specs/offline-photos.md), not a second storage
system. Defaults remain one local collection, explicit selection, bounded copies,
and no backend. Test cancellation separately from failure.

Preserve these properties when changing import or deletion:

- Validate byte and decoded-pixel limits before expensive processing. Downsample
  and re-encode; stripping metadata requires checking the resulting file, not
  simply renaming an extension. Bound total work and memory as well as file size.
- Serialize writes, reject traversal and unexpected IDs, and validate that paths
  stay inside owned storage. Avoid following unexpected links outside that root.
- Keep the manifest and images consistent through partial failures and restarts.
  Test fault points; a temporary-file rename alone is not a complete transaction.
- Preserve originals and existing good content. Do not silently overwrite a
  malformed manifest. Delete only owned copies and make destructive UI explicit.
- Test duplicates, missing files, unsupported/corrupt images, capacity, low space,
  concurrent actions, interruption, and recovery after a failed batch.

The system picker may fetch an iCloud-only original. That is different from the
app uploading/syncing photos. Device backups may include local data. Keep these
limits honest in UI and store copy. On Android, handle picker process-death
recovery; on iOS test permissions, cancellation, orientation, and real HEIC
inputs. A simulator-only HEIC result is insufficient. [F7].

## Adult, accessible, calm UI

Reuse [DESIGN.md](../../DESIGN.md) and `lib/design_system.dart`. Improve shared
tokens/components when needed instead of accumulating screen-specific colors.
Test rather than assume the existing theme has sufficient contrast.

Use at least 48 logical-pixel interactive targets as this repo's target; prefer
larger principal actions. Check normal text at 4.5:1 contrast, visible focus,
non-color-only state, and usable layout at 200% text scale. Use constraints,
`SafeArea`, scrolling, and adaptive layout; do not disable scaling to hide overflow.
Test narrow phones, iPad, rotation, reduced motion, and portrait/landscape. [F4].

Expose labels, roles, selected/disabled states, and logical focus order. Hidden
cards must not reveal their contents to a screen reader; generic numbered photo
labels are a documented limitation, not descriptive accessibility. VoiceOver
and TalkBack deserve actual sessions. Avoid duplicate nested semantics, automatic
focus jumps, flashing success, forced recall, and unexpected audio. [F4].

For new user-facing strings use the existing ARB/localization system. Do not
claim a translated experience because only legacy screens have translations.
Do not add an automated photo-captioning API to solve labels without approval.

## Tests and evidence

| Change | Minimum relevant evidence, in addition to applicable root checks |
| --- | --- |
| Board logic | Invalid input, pair invariants, mismatch transitions, repeated taps, completion, visible/hidden modes |
| Persistence/import | Temporary storage fixtures, serialized mutations, fault/restart cases, normalization bounds |
| UI | Widget interaction and semantics, scaling/rotation, real rendered inspection |
| Native picker/permissions | Real native flow, cancel/deny/retry, Android recovery, iOS HEIC/iCloud cases |
| Shared startup/library | First-install offline starter and existing-pack upgrade regression |
| Browser/shared rendering | Release web build and existing browser smoke checks |

Use unit tests for rules, widget tests for interaction, and native integration
checks for cross-layer behavior. Seed randomness when needed; fake only external
boundaries, not the logic under test. Add focused tests before broad regression.
Run Flutter's `androidTapTargetGuideline`, `iOSTapTargetGuideline`,
`labeledTapTargetGuideline`, and `textContrastGuideline` where applicable. [F4, F5].

Flutter `integration_test` cannot drive native permission dialogs by itself.
Use an approved native-capable harness or documented manual testing. Do not add
Patrol or another testing dependency automatically. A mocked picker tests Dart
handling, not operating-system integration. [F5].

```sh
# Focused development loop, then the full root validation contract.
flutter test test/features/gentle_activities --reporter expanded
# For changes affecting web; follow docs/visual-testing.md for smoke setup.
flutter build web --release
```

For iOS, use [device setup](../run-ios-device.md),
[simulator setup](../run-ios-simulator.md), and the
[release checklist](../release/1.3.0.md). Never invent signing values or call an
unsigned simulator build a validated App Store archive. Preserve flavor identity.
Capture genuine UI from the tested build; synthetic fixtures are fine when
clearly labeled and no private family material is included in published evidence.

## Performance and network boundaries

Measure in profile mode on a representative device before optimizing; debug
speed is not release performance. Watch decoded image memory, bounded queues,
repeated imports, long sessions, and avoid rebuilding/decode work unnecessarily.
Use lazy builders and appropriately sized images. Move demonstrated CPU-heavy
work to a supported isolate only when measurement and API support justify it;
`dart:ui`/plugin work cannot all be moved wholesale. [F6].

Preserve the conditional mobile/browser entry and keep `dart:io` and native-only
plugins behind the appropriate boundary. Starter success must not depend on
Firebase, catalog HTTP, or optional audio. Audit the native dependency graph and
actual network behavior before claiming no tracking; disabling one Dart init
call does not prove all SDK collection is off.

## Done means evidence exists

Record commit/build, toolchain, device/OS, command or manual steps, result, and
artifact location. Keep unperformed gates pending in
[release status](../specs/release-status.json). A browser screenshot, passing
storage tests, and a merged PR cannot establish native readiness or legal safety.
