# Golden Moments

Gentle picture matching and shared photo activities. Flutter, local-first on iOS/Android, no account or custom photo backend.

**US App Store candidate:** `Dementia Games: Golden Moments`  
**Subtitle:** `Alzheimer's Photo Activities`  
**On-device name:** `Golden Moments`  
**Candidate version:** `1.3.0+5` (not yet an App Store release).

## Start here

| Question | Source of truth |
| --- | --- |
| What are we building and for whom? | [Product specification](docs/specs/product.md) |
| What is implemented versus verified? | [Feature and release status](docs/specs/README.md) |
| How do photos work without a server? | [Architecture and privacy](docs/specs/offline-photos.md) |
| What are the name, subtitle and keywords? | [Canonical metadata](metadata/app-store.en-US.json) |
| How will ASO be validated? | [US strategy](docs/strategy/us-aso.md) |
| What screenshots should be captured? | [Screenshot specification](docs/specs/screenshots.md) |
| What blocks publication? | [Release checklist](docs/release/1.3.0.md) |
| How should every screen look, sound and read? | [Design system](DESIGN.md) |
| What should happen next? | [Workboard](WORKBOARD.md) |

## This upgrade

On iOS/Android, the new home opens local activities without initializing Firebase or downloading packs. Gentle matching starts with four tiles, keeps pictures visible by default, and has no clock, score, penalty or automatic mismatch timer. Select up to 24 photos, store normalized local copies, match them, or view them with optional conversation prompts.

The existing picture-pack library remains behind an explicit mobile action. New downloads still need internet. Browser/desktop startup and the independently stabilized web catalog are preserved through a conditional platform entry. Family-photo storage is not a new browser capability.

Firebase packages remain in the dependency graph. Mobile Analytics is deactivated and automatic Crashlytics reporting disabled in native configuration; native-build privacy auditing is still required. Do not apply mobile offline/privacy claims to the unchanged browser catalog.

Code completion is not verification. See [release-status.json](docs/specs/release-status.json). Sync, photo-deck exchange, recordings, payments and medical functionality are excluded from this upgrade.

## Development

Use the current `.fvmrc` baseline: Flutter `3.47.7`, Dart `3.13.5`. Dependencies, browser fixes and full/visual workflows from PR #43 are preserved, not downgraded. The new photo picker is initially pinned at `1.1.2`; resolve and review the changed lockfile and platform requirements before merging.

```sh
flutter pub get
flutter run --target lib/main.dart
flutter analyze
flutter test --coverage
python -m unittest discover -s tests -v
python scripts/release_metadata.py --check
```

See [build and visual testing](docs/visual-testing.md), [iOS device setup](docs/run-ios-device.md), and [simulator setup](docs/run-ios-simulator.md). Existing signing and flavor configuration remain unchanged.

Edit `metadata/app-store.en-US.json`, run `python scripts/release_metadata.py --write`, and commit the generated text exports. `--check` detects drift and copy errors. `--release` requires recorded QA and real screenshot files; it intentionally fails while gates are pending. Scripts never publish to App Store Connect.

[Pack management](docs/packs.md), [sample packs](docs/example-pack.json), and [pack validation](scripts/validate_packs.py) remain relevant. `TEST_SUMMARY.md` and the older visual validation describe historical commits, not a passed test run for this upgrade.

## Localization and intended use

The new mobile flow and copy are English-first. Existing translated legacy screens do not make new screens translated. Other store descriptions remain historical and require localization/claims review before reuse.

Golden Moments offers recreation and shared conversation. It does not diagnose, measure, treat, prevent or claim to slow dementia or Alzheimer's disease. Do not imply suitability for every person or stage.
