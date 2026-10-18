# Build and visual testing

Validated locally on 2026-10-18 with Flutter 3.47.7, Dart 3.13.5,
Playwright 1.62.1, and Chrome 155.0.8059.85 on macOS.

## Reproduce

Install Flutter and Google Chrome. Make the `playwright` Node package available
through local dependencies or `NODE_PATH`. The test uses Playwright directly
because the installed Playwright CLI wrapper could not run in this environment.

```sh
flutter pub get
flutter build web --release
python3 -m http.server 8765 --bind 127.0.0.1 --directory build/web
```

In another terminal, from the repository root:

```sh
node scripts/visual_smoke.cjs
flutter test --no-pub test/game_cubit_test.dart
```

`APP_URL` overrides the test URL. `PLAYWRIGHT_CHANNEL` defaults to `chrome`.
The browser run uses a fresh context and real catalog assets and image downloads.
It requires internet for the initial download. It deliberately disables network
access during the cached-gameplay check. The process exits nonzero on failure.

This session's temporary SDK is `/private/tmp/golden-moments-flutter/bin/flutter`.
Its package cache is `/private/tmp/golden-moments-pub-cache`; set `PUB_CACHE` to
that path when reusing this SDK. Both temporary directories can disappear.
Playwright was supplied by the desktop app's bundled Node dependencies.

## Verified results

- Release web build: passed.
- All 84 catalog game images persisted in browser Cache Storage.
- Nine automated browser checks passed: persistent image downloads, responsive
  home, settings toggle/save, download manager, game startup, tile reveal and
  pause/resume/replay, cached gameplay without network, hint/navigation lifecycle,
  and library category navigation.
- Zero unhandled browser errors in the final run.
- Screenshots at 320x740, 390x844, 768x1024, and 1440x1000, plus settings,
  downloads, gameplay, revealed tile, pause, restart, hint, offline tile, and library.
- Screenshots reviewed manually after animations settled. Narrow pack-card text
  clipping and oversized desktop cards were repaired and recaptured.
- Full Flutter suite: 24 tests passed with randomized ordering seeds 42 and 517,
  including real filesystem image loading, catalog parsing, navigation, widgets,
  matching/replay, and disposal during hint and mismatch delays.
- Repository-wide strict analysis: no issues found. Formatting passed.

Artifacts are written to ignored `output/playwright/`: PNG screenshots, YAML
accessibility snapshots, and `results.json`. Screenshots are visual smoke-test
artifacts; no approved pixel-difference baseline existed for this repository.

## Repairs made while testing

The prior web downloader discarded image bytes but saved completed-pack metadata.
Gameplay then looked for native files and failed with `Game Error`. The browser
now stores image bytes using Cache Storage, validates existing web metadata at
startup, and renders stored bytes. Missing bytes invalidate stale completed-pack
metadata so the normal downloader can refill it. Browser cache availability
requires HTTPS or a trusted local origin; browser storage can be evicted.
See the [Cache API documentation](https://developer.mozilla.org/en-US/docs/Web/API/Cache/put).

Browser connectivity uses the browser's online hint instead of native DNS calls.
It does not prove that any particular image host is reachable; actual download
errors reset pack state and remain retryable. Optional Firebase analytics no
longer interrupts the tested game and category navigation paths. Download slots
are released after failures. Delayed game callbacks stop after the cubit closes.

## Remaining verification limits

Local tests and analysis now pass. The original CI coverage requirement remains
100%; measured local coverage is 18.67% (601/3219 executable lines). This work does
not claim to satisfy that threshold. The existing full-document spell check also
uses English dictionaries on translated store descriptions; its prior run
reported thousands of foreign-language tokens. Neither gate was disabled.

The CI workflow now pins Flutter through `.fvmrc`, grants the PR-title checker
read access to pull requests, and adds an independent release-web/browser job
that uploads screenshots and accessibility snapshots even on failure.

No native iOS/Android build, physical-device run, store release, full-game
completion flow, or offline cold launch was verified. Offline gameplay was
tested within an already loaded app. The configured Android SDK path on this
machine is unavailable, so native compilation needs a working Android SDK.

## Dependency refresh

The lockfile updates compatible runtime and development libraries, including
AudioPlayers 6.8.1, Bloc 9.2.1, cached_network_image 4.0.4, Equatable 2.1.0,
Firebase Core 4.15.0, Analytics 12.6.0, Crashlytics 5.4.0, HTTP 1.6.0,
path_provider 2.1.6, Pool 1.5.3, and shared_preferences 2.5.6. Flutter 3.47.7
and Dart 3.13.5 are the declared toolchain.

Firebase 5.x was deferred because it raises native platform requirements;
share_plus stays on 11.1.0 to preserve the current Android toolchain.
Equatable stays on its 2.x line to preserve equality semantics. Existing analyzer
rules are retained. Sharing now uses `SharePlus.instance.share(ShareParams(...))`.

Migration references: [Firebase Core changelog](https://pub.dev/packages/firebase_core/changelog),
[share_plus changelog](https://pub.dev/packages/share_plus/changelog), and
[cached_network_image changelog](https://pub.dev/packages/cached_network_image/changelog).
