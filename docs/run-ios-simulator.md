## Run on iOS Simulator (macOS)

This project supports iOS Simulator on Apple Silicon and Intel Macs.

### Prerequisites
- Xcode 15+ (you have Xcode 16.4)
- Flutter stable (you have 3.32.5)
- CocoaPods 1.16.2+ recommended (1.16.1 works, but update if you hit pod issues)

### One-time setup
1) Install CocoaPods or update it

```sh
sudo gem install cocoapods
```

2) Fetch Flutter deps and install Pods

```sh
flutter pub get
cd ios && pod install --repo-update && cd -
```

### Start a simulator
```sh
open -a Simulator
```

Select a device in the Simulator app, or boot one via CLI:

```sh
xcrun simctl list devices
xcrun simctl boot "iPhone 16 Plus"
```

### Run the app
```sh
flutter devices       # verify the simulator is detected
flutter run -d <SIMULATOR-UDID> --target lib/main.dart
```

Tip: Use `q` to quit, `r` for hot reload, `R` for hot restart.

### Troubleshooting
- Could not find the built application bundle: run `flutter clean && flutter pub get`, then rerun.
- Pod errors: run `cd ios && pod repo update && pod install`.
- iOS build settings: ensure `PRODUCT_BUNDLE_IDENTIFIER` and `DEVELOPMENT_TEAM` exist in `ios/Runner.xcodeproj`.

Known warnings you can ignore locally:
- CocoaPods 1.16.1 vs 1.16.2 recommendation.

### Notes
- This app uses a JSON cache on device. If you see startup errors about cache JSON, try clearing cache from the app UI or uninstall/reinstall the app on the simulator.


