# Maintainer and agent instructions

Read `README.md`, `WORKBOARD.md`, and `docs/specs/product.md` before changing scope. Read `DESIGN.md` before changing any UI, copy, motion, sound or store art. Canonical US copy: `metadata/app-store.en-US.json`. Generated exports must not drift.

## Invariants

- Preserve bundle identifiers, signing, saved packs, and package identity. The store title is not the launcher label.
- Starter activities must work on a fresh offline install. No account, custom backend, AI API, automatic photo-library scan or photo upload in this release.
- Import explicit selections only. Store bounded normalized copies; never overwrite originals. Confine deletion to app-owned files and serialize mutations.
- No diagnosis, cognitive scores, treatment/prevention claims, invented testimonials, disease-stage promises or implied clinical validation.
- Gentle mode has no clock, score, forced recall, penalty or automatic mismatch timer. Keep visible-picture mode and an easy exit. No screen anywhere shows a stopwatch, move count, streak, confetti, countdown or auto-closing dialog.
- Do not add telemetry or permissions without a privacy decision and native-build audit. Existing dependencies are not proof of no tracking.
- Screenshots and claims describe the submitted build. Distinguish implementation, verification and publication in `docs/specs/release-status.json`.

## Design system

`DESIGN.md` (open [DESIGN.md format](https://github.com/google-labs-code/design.md)) is the design contract; its YAML tokens are normative and `lib/design_system.dart` implements them through `gm…` constants and `gmBuildTheme`.

- Use stock Material widgets with `Theme.of(context)` roles and `gm…` tokens. Do not hard-code `Color(0x…)`, `Colors.*`, `fontSize:` or radius literals in screens; add or change a token in `DESIGN.md` and `lib/design_system.dart` together.
- Text is never below 16 at 100% scale, never ALL CAPS and never clamped. Buttons are ≥56 high, every control ≥48×48 and picture tiles ≥96. Bright gold (`accent`/`gmGold600`) is never text or the only outline.
- Color is never the only signal: pair it with a border, icon or word. Difficulty is never colored like a status.
- One filled (primary) button per screen. Keep "Done for now" or Back visible.
- Follow the voice rules in `DESIGN.md`: plain adult language, no brain, score or clinical vocabulary, no emoji praise.
- Validate with `npx @google/design.md lint DESIGN.md` (0 errors, 0 warnings) and `flutter test test/design_system_test.dart`, which checks token drift, WCAG contrast, the text floor, tap targets and 200% text.

## Engineering

Check mounted state after async work. Preserve accessibility actions and hidden-tile privacy. Support text scaling, scrolling, rotation and iPad. Do not suppress old tests to make new work look green.

Run Flutter analysis/full tests, focused feature tests, Python metadata tests, and metadata `--check`. Resolve `pubspec.lock` after dependency changes. Record device checks only when performed. Follow `docs/release/1.3.0.md` before publishing; a disclaimer is not legal clearance.
