# Golden Moments

Gentle picture matching and shared photo activities. Flutter, local-first, no account, no custom photo backend.

**US App Store candidate:** `Dementia Games: Golden Moments`  
**Subtitle:** `Alzheimer's Photo Activities`  
**On-device name:** `Golden Moments`  
**Candidate version:** `1.3.0+5`. This is not a claim of App Store publication.

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
| What should happen next? | [Workboard](WORKBOARD.md) |

## This upgrade

The default home opens local activities without initializing Firebase or downloading packs. Gentle matching starts with four tiles, keeps pictures visible by default, and has no clock, score, penalty or automatic mismatch timer. Families can select up to 24 photos, store normalized copies locally, match them, or view them with optional conversation prompts.

The existing picture-pack library remains behind an explicit action. New library downloads still require internet. Firebase packages remain in the dependency graph with Analytics deactivated and automatic Crashlytics reporting disabled; native-build privacy auditing remains mandatory.

Code completion is not device verification. See [release-status.json](docs/specs/release-status.json). Sync, photo-deck exchange, voice recording, payments and medical functionality are not part of this upgrade.

## Development

Dart constraint: `^3.8.0`. Focused upgrade CI uses Flutter `3.32.8`; the existing full CI is retained. The photo picker is pinned at `1.1.2` for the existing SDK baseline. Resolve and commit dependency lockfile changes after running the toolchain. The new feature targets iOS and Android; web/desktop compatibility is not claimed.

```sh
flutter pub get
flutter run --target lib/main.dart
flutter analyze
flutter test --coverage
python -m unittest discover -s tests -v
python scripts/release_metadata.py --check
```

Existing development/staging/production configurations and signing identifiers are preserved. See [device setup](docs/run-ios-device.md) and [simulator setup](docs/run-ios-simulator.md).

Edit `metadata/app-store.en-US.json`, then run `python scripts/release_metadata.py --write` and commit the generated `metadata/en-US/*.txt` exports. `--check` detects drift, length and prohibited-claim errors. `--release` requires QA evidence and genuine screenshot files and is expected to fail while gates are pending. These scripts never upload to App Store Connect.

[Pack management](docs/packs.md), [sample pack](docs/example-pack.json), and [pack validation](scripts/validate_packs.py) remain relevant to the optional library. `TEST_SUMMARY.md` is historical, not evidence for this release.

## Localization and product boundary

The new flow and store copy are English-first. Legacy locale files remain, but they do not mean the new screens are translated. Review all other storefront descriptions before reusing them; use `lib/l10n/arb/` and `flutter gen-l10n` for subsequent localization.

Golden Moments offers recreation and shared conversation. It does not diagnose, measure, treat, prevent or claim to slow dementia or Alzheimer's disease. Do not imply suitability for every person or disease stage.
