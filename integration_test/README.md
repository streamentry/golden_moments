# End-to-end journeys

These tests drive the real app on a device or simulator: the production
`bootstrap` and `App`, the device's real preferences and app storage, the
bundled pictures and catalog, and no network. They find things by the words
on screen and what a screen reader announces, the way a person would.

Run from the repository root with the pinned Flutter (see `.fvmrc`). On the
Golden Moments iPad simulator:

```sh
xcrun simctl boot 2ADBF7D0-5049-4796-885A-74350E4FB0A0
flutter test integration_test -d 2ADBF7D0-5049-4796-885A-74350E4FB0A0
```

Any booted iOS simulator or Android emulator works: pass its id to `-d`
(`flutter devices` lists them). Each journey clears the app's preferences
and family-photo copies before and after it runs, so do not run the suite
on a device whose app data you want to keep.

| Journey | Covers |
| --- | --- |
| J1 | Fresh install, one dominant start, four visible tiles, a mismatch that waits, finish, Play again, Done for now, no clock or score |
| J2 | Done for now with a tile chosen, Carry on, Start fresh after a relaunch, no prompt after a finished board |
| J3 | Comfort settings from Home: 8 hidden tiles that announce only their position, kept after a relaunch, then reset |
| J4 | Look together with the included pictures: Next, Previous, prompt, hide for this visit |
| J5 | Family photos: a generated collection written into app storage as an earlier install would leave it, then caption, favorite, play, captions, hide, remove, with the files on disk checked |
| J6 | Picture-pack library: favorites, Not for me and Show again, a topic, a pack played to the end, Play again, back to Home |
| J7 | J1 and J4 again at 200% text: no overflow, Start and Done for now reachable |
| J8 | Help, privacy and support from Home with no network: the guide, every help section, a note previewed exactly and cancelled (nothing sent), the named privacy and terms links, and a way back from each page |
| J9 | Confirmations at 100% and 200% text: Keep this board and Keep my settings are the primary actions, keeping keeps the found pair and the tile count, and Start again clears only when chosen |

Notes:

- Only generated pictures are used; never add real photos here.
- The system photo picker and permission dialogs are outside what
  `integration_test` can drive; they remain manual device checks
  (`docs/release/device-acceptance.md`).
- Screenshots of key steps are saved only when you name a folder. On a
  simulator, which shares the Mac's file system, use an absolute path outside
  the app, because `flutter test` uninstalls the app when it finishes:

  ```sh
  flutter test integration_test -d 2ADBF7D0-5049-4796-885A-74350E4FB0A0 \
    --dart-define=GM_E2E_SCREENSHOT_DIR="$PWD/build/e2e_screenshots"
  ```

  Pictures from an earlier run are replaced. Screenshots only ever show
  generated pictures.
