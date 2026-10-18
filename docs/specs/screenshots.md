# US screenshot specification

Canonical text and feature requirements: `metadata/app-store.en-US.json`. Final image paths remain unset until real captures exist. The previous ASO HTML brief is not a store screenshot.

| Order | Headline | Supporting text | Proof |
| --- | --- | --- | --- |
| 1 | Simple Dementia Activities | Gentle photo games to enjoy together. | Real gentle activity; four tiles; no clinical framing |
| 2 | Play With Your Family Photos | Choose photos already on your device. | Real import and game using consented/licensed demo images |
| 3 | No Timers. No Rush. | Enjoy each gentle game at your own pace. | Gentle mode, not a legacy screen with performance indicators |
| 4 | Big Tiles. Easy Taps. | A clear layout for simple play. | Readable actual controls |
| 5 | Choose Your Comfort Level | Adjust the number of tiles. | Actual supported 4/6/8/12 choices |
| 6 | Ready Without Wi-Fi | Starter games and imported photos work offline. | Airplane-mode verification, not remote downloads |

## Rules

UI dominates; one message per frame. Do not use invented interfaces, medical badges, review quotes, unimplemented sync, or identifiable private images without consent. Keep original captures for evidence. Capture iPhone and iPad separately using Apple's current required sizes. Check readability at search-result scale.

## Workflow

1. Build the exact candidate and record its commit.
2. Use a clean test installation and appropriate demo content.
3. Capture with `sh scripts/capture_ios_screenshot.sh <01-06> <iphone|ipad> <simulator-id>` or device-native tooling. The helper captures only the existing screen; it does not navigate or render mock UI.
4. Add restrained text without hiding functionality. Keep originals.
5. Set final file paths in metadata and device/build evidence in release status; run `--release`.

Source implementation alone does not prove native import works. Do not submit frame 2 until native picker verification passes. No final screenshots are supplied in this code change.

## Test

Hold other assets, metadata and price fixed. Compare headline Simple Dementia Activities against Enjoy Time Together. Apple PPO supports eligible creative assets, not title/subtitle testing. Use full weekly cycles and confidence reports; low samples may remain inconclusive.

References: [product page](https://developer.apple.com/app-store/product-page/), [screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications), [PPO](https://developer.apple.com/help/app-store-connect/create-product-page-optimization-tests/overview-of-product-page-optimization).
