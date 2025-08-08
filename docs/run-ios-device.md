## Run on iPhone (real device)

Two options:

- Debug (hot reload): requires Developer Mode enabled on your iPhone (iOS 16+)
- Release (no hot reload): works without Developer Mode

### Prerequisites
- Xcode installed and command line tools selected
- Apple ID added to Xcode (Preferences → Accounts)
- Device trusted (plug via USB once and Trust this Computer)
- CocoaPods installed (`sudo gem install cocoapods`)
- ios-deploy installed (`brew install ios-deploy`)

### Project signing
This project already has:
- DEVELOPMENT_TEAM = `UHZE77G3Z7`
- PRODUCT_BUNDLE_IDENTIFIER = `com.mindfulness.goldenmoments`

If you need to change these, update them in `ios/Runner.xcodeproj` → target Runner → Signing & Capabilities.

### Option A — Debug (requires Developer Mode)
1) Enable Developer Mode on device
   - iPhone: Settings → Privacy & Security → Developer Mode → On → Restart
2) Verify Flutter sees the device
```sh
flutter devices
```
3) Run in debug
```sh
flutter run -d <DEVICE_ID> --target lib/main.dart
```

Notes:
- If you see memory protection/JIT errors (RX/RW memory), Developer Mode is not enabled.
- Unlock the device; allow any prompts to trust and allow Xcode automation.

### Option B — Release (no Developer Mode required)
1) Build and install to device
```sh
flutter run -d <DEVICE_ID> --release --target lib/main.dart
```
Or split steps:
```sh
flutter build ios --release
ios-deploy --bundle build/ios/iphoneos/Runner.app --id <DEVICE_ID>
```

### Troubleshooting
- App aborts at startup with Dart VM memory protection error:
  - Use Release mode OR enable Developer Mode (see above).
- Installation hangs/permission prompts:
  - macOS: System Settings → Privacy & Security → Automation → allow Terminal to control Xcode.
- Code signing failures:
  - Open `ios/Runner.xcworkspace` in Xcode → Signing & Capabilities → ensure a valid team is selected and provisioning profile is created automatically.
- Device not detected:
  - Use USB first to pair; ensure Lock Screen is unlocked; try `flutter devices` again.


