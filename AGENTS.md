# Maintainer and agent instructions

Read `README.md`, `WORKBOARD.md`, and `docs/specs/product.md` before changing scope. Canonical US copy: `metadata/app-store.en-US.json`. Generated exports must not drift.

## Invariants

- Preserve bundle identifiers, signing, saved packs, and package identity. The store title is not the launcher label.
- Starter activities must work on a fresh offline install. No account, custom backend, AI API, automatic photo-library scan or photo upload in this release.
- Import explicit selections only. Store bounded normalized copies; never overwrite originals. Confine deletion to app-owned files and serialize mutations.
- No diagnosis, cognitive scores, treatment/prevention claims, invented testimonials, disease-stage promises or implied clinical validation.
- Gentle mode has no clock, score, forced recall, penalty or automatic mismatch timer. Keep visible-picture mode and an easy exit.
- Do not add telemetry or permissions without a privacy decision and native-build audit. Existing dependencies are not proof of no tracking.
- Screenshots and claims describe the submitted build. Distinguish implementation, verification and publication in `docs/specs/release-status.json`.

## Engineering

Reuse `lib/design_system.dart`. Check mounted state after async work. Preserve accessibility actions and hidden-tile privacy. Support text scaling, scrolling, rotation and iPad. Do not suppress old tests to make new work look green.

Run Flutter analysis/full tests, focused feature tests, Python metadata tests, and metadata `--check`. Resolve `pubspec.lock` after dependency changes. Record device checks only when performed. Follow `docs/release/1.3.0.md` before publishing; a disclaimer is not legal clearance.
