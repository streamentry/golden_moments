# US screenshot specification

Canonical text and feature requirements: `metadata/app-store.en-US.json`. Final build 6 iPhone and iPad files, originals and hashes are in `assets/screenshots/en-US/`; canonical metadata records all 12 final paths.

| Order | Headline | Supporting text | Proof |
| --- | --- | --- | --- |
| 1 | Simple Dementia Activities | Gentle photo games to enjoy together. | Real gentle activity; four tiles; no clinical framing |
| 2 | Play With Your Family Photos | Choose photos already on your device. | Real import and game using consented/licensed demo images |
| 3 | No Timers. No Rush. | Enjoy each gentle game at your own pace. | Gentle mode, not a legacy screen with performance indicators |
| 4 | Big Pictures. Easy Taps. | A clear layout for simple play. | Real shared photo viewer with synthetic demonstration content |
| 5 | Choose Your Comfort Level | Adjust the number of tiles. | The actual Comfort settings sheet (tune icon on Home or in the activity) showing the 4/6/8/12 choices; the board itself no longer shows these controls |
| 6 | Eight Included Picture Packs | Open the picture library and choose a pack. | Actual included library; this screenshot makes no airplane-mode verification claim |

## Rules

UI dominates; one message per frame. Do not use invented interfaces, medical badges, review quotes, unimplemented sync, or identifiable private images without consent. Keep original captures for evidence. Capture iPhone and iPad separately using Apple's current required sizes. Check readability at search-result scale.

## Workflow

1. Build the exact candidate and record its commit.
2. Use a clean test installation and appropriate demo content.
3. Capture with `sh scripts/capture_store_screens.sh <iphone|ipad> <simulator-id>`. It runs `integration_test/store_screens_test.dart`, which drives the real app to each frame and pauses while the script saves the simulator screen. Alternatively, use `sh scripts/capture_ios_screenshot.sh <01-06> <iphone|ipad> <simulator-id>` on a screen you reached by hand, which is needed to show the real photo picker. Neither tool renders mock UI.
4. Place the captures in the approved frames with `python3 scripts/compose_store_screens.py <iphone|ipad>`; it changes only the screen inside the bezel. Keep originals.
5. Set final file paths in metadata and device/build evidence in release status; run `--release`.

Source implementation alone does not prove native import works. Do not submit frame 2 until native picker verification passes. The build 6 native picker and actual imported-photo activity passed on both iOS 18.5 simulator sizes; physical-device and failure-path QA remain pending. See [capture evidence](../../assets/screenshots/en-US/README.md).

## Test

Hold other assets, metadata and price fixed. Compare headline Simple Dementia Activities against Enjoy Time Together. Apple PPO supports eligible creative assets, not title/subtitle testing. Use full weekly cycles and confidence reports; low samples may remain inconclusive.

References: [product page](https://developer.apple.com/app-store/product-page/), [screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications), [PPO](https://developer.apple.com/help/app-store-connect/create-product-page-optimization-tests/overview-of-product-page-optimization).
