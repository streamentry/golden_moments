# Build and visual testing

Current bundled-catalog validation: 2026-10-18, Flutter 3.47.7 / Dart 3.13.5,
Playwright 1.62.1, Chrome 155.0.8059.85 on macOS.

## Run

```sh
flutter pub get
flutter analyze
flutter test --coverage
python3 -m unittest discover -s tests -v
python3 scripts/release_metadata.py --check
python3 scripts/validate_packs.py --check-urls
flutter build web --release --no-web-resources-cdn
python3 -m http.server 8765 --bind 127.0.0.1 --directory build/web
```

In another terminal from the repository root:

```sh
node scripts/visual_smoke.cjs
```

The `playwright` Node package must be available through local dependencies or
`NODE_PATH`; Google Chrome is the default channel. `APP_URL` overrides the local
URL and `PLAYWRIGHT_CHANNEL` overrides the browser channel. CI installs Chromium
and uploads the results as `web-visual-evidence`.

The desktop app's bundled Node modules supplied Playwright for local runs.
The temporary SDK is `/private/tmp/golden-moments-flutter/bin/flutter`, with
`PUB_CACHE=/private/tmp/golden-moments-pub-cache`; these temporary paths may expire.

## Local results

49 Flutter tests passed, including all pre-existing tests and the new local
catalog/mobile-library checks. All 12 Python tests, metadata validation, catalog
validation, formatting, and strict analysis passed. Native/device gates remain
pending. Hosted results are recorded on the PR before merge.

## Bundled-catalog proof

- The image inventory contains 121 files / 3,914,100 bytes. Provenance and hashes
  are checked without network by `tests/test_bundled_catalog.py`.
- Flutter decodes every image and starts all eight packs directly from assets
  without storage, HTTP, or download initialization. Prior tests are retained.
- The browser starts with an empty profile and blocks every request outside the
  local application origin before its first navigation. It asserts zero external
  requests throughout the run, including full-game completion and Play Again.
- Ten browser checks cover all packaged image responses, responsive home,
  settings, absence of download controls, immediate game startup, tile reveal,
  pause/resume/replay, local image rendering, hint/disposal, category navigation,
  and full-game completion. Some checks cover multiple related actions.
- Screenshots are captured at 320, 390, 768, and 1440 logical pixels wide, plus
  settings, game, reveal, pause, restart, hint, category, completion and replay.
  Animation settling is included before capture. Screenshots are reviewed
  manually; no approved pixel-difference baseline is claimed.
- The browser renderer and Roboto font ship locally too. No Firebase/CDN
  initialization or pack-download task runs at startup.

`output/playwright/` contains ignored PNGs, accessibility YAML, and `results.json`,
including `externalRequests`. This tests an installed build served locally;
requests to its own origin read packaged files. It does not claim a web PWA
will cold-launch offline without its server, or that a native device was tested.

## Limits and gates

Native iOS/Android compilation, picker behavior, real-device accessibility,
upgrade installations, privacy auditing and store submission remain separate
release gates in `docs/specs/release-status.json`. Family photos remain explicit
local imports; these private copies are not redistributed as catalog assets.

The existing 100% coverage gate and full-document spelling gate are retained.
Their historical failures were explicitly accepted for PR #43; this change does
not lower or disable them. Record each new PR's actual CI outcome before merge.

See [the catalog guide](packs.md) for maintenance. Normal builds and tests do not
run the maintainer-only network importer `scripts/bundle_catalog.py`.
