# App Store screenshots: 1.3.0

Six separate iPhone JPEGs at 1320 by 2868 pixels and six iPad JPEGs at 2064 by 2752 pixels. The native PNG captures and the native-picker proof are kept in `originals/`. `manifest.json` records SHA-256 hashes, the source commit and the capture environment. These marketing files are not declared in the app bundle.

## Current captures

The current captures come from main at `fce00d7` (after build 6: PRs #70, #71 and #72), on the iPhone 17 Pro Max and iPad Pro 13-inch (M5) simulators running iOS 26.5. The status bar is set to 9:41 with `xcrun simctl status_bar`. The debug banner is hidden for capture only; a release build never shows it.

- **iPhone:** the app was driven by hand on the simulator and each screen saved with `xcrun simctl io screenshot`. The generated teacup and flowers were chosen through the real native photo picker (`originals/iphone/native-picker.png`).
- **iPad:** `scripts/capture_store_screens.sh` ran `integration_test/store_screens_test.dart`. The test drives the real app to each frame and pauses while the script saves the screen. The two demo photos went through the app's own normalize-and-store import steps, because a test cannot operate the system picker. `originals/ipad/native-picker.png` is the build 6 picker proof.

## Composition

`scripts/compose_store_screens.py` places each unchanged capture inside the approved build 6 frame: the generated paper backdrop, headline, supporting text and device bezel. The capture is clipped to the bezel's rounded screen. The frame geometry was checked by re-composing the build 6 captures, which reproduced the published frames to within JPEG noise. Built-in image generation created only the backdrop and two demo photos; see `PROMPTS.md`. No private photos or identifiable people are used.

## What each frame shows

1. The four-tile starter.
2. Matching with the two imported demo photos.
3. A found pair, with no timer or score.
4. Looking at a demo photo together.
5. The comfort sheet with its equal-width 4/6/8/12 choices.
6. The included picture library, with tile counts and Play on each pack.

All 12 were visually inspected after composition, including the bezel corners. The car pack now shows a car on its cover and is named *Cars and Trucks* (it was *Classic Cars* with a light-bulb cover).

## Limits

Native capture is simulator evidence. It does not establish physical-device accessibility, previous-release data migration, airplane-mode behavior, caregiver comprehension or redistribution rights for inherited app artwork. Those gates remain open, and public release is manual. Before submission, recapture from the final signed build if the UI has changed since `fce00d7`.
