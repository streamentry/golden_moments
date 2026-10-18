# iOS App Store Publishing Guide - Golden Moments

This guide covers the complete process of publishing the "Golden Moments" Flutter app to the iOS App Store from scratch, as well as how to update existing versions.

## Quick Start for Clean iOS Build

If you're experiencing build or archive issues, the fastest solution is to recreate the iOS project from scratch:

```bash
# Clean rebuild script - recreates iOS project with proper configuration
./scripts/recreate_ios_project.sh
```

This script:
- ✅ Removes complex flavor configurations that cause build issues
- ✅ Creates a clean, standard Flutter iOS project
- ✅ Sets iOS 15.0 target (kept from the Firebase era; revisit only with a native build)
- ✅ Fixes all Swift plugin import issues automatically
- ✅ Eliminates framework linking errors
- ✅ Tests the build to ensure it works

**Result**: A clean iOS project ready for archiving and App Store submission.

---

## Prerequisites

### Development Environment
- **macOS** (required for iOS development)
- **Xcode** (latest stable version from Mac App Store)
- **Flutter SDK** (currently using Flutter 3.8.0+)
- **Command Line Tools** for Xcode
- **CocoaPods** (for iOS dependency management)

### Apple Developer Requirements
- **Apple Developer Account** ($99/year)
  - Individual or Organization account
  - Access to App Store Connect
- **iOS Development Certificate**
- **App Store Distribution Certificate**
- **Provisioning Profiles**

## Initial Setup (First Time Publishing)

### 1. Apple Developer Account Setup

1. **Enroll in Apple Developer Program**
   ```
   Visit: https://developer.apple.com/programs/
   Choose: iOS Developer Program ($99/year)
   Complete enrollment process
   ```

2. **Access App Store Connect**
   ```
   Visit: https://appstoreconnect.apple.com/
   Sign in with your Apple Developer account
   ```

### 2. App Store Connect Configuration

1. **Create New App**
   - Go to "My Apps" → "+" → "New App"
   - Platform: iOS
   - Name: "Golden Moments"
   - Primary Language: English (US)
   - Bundle ID: Use `com.mindfulness.goldenmoments` (update from current underscore version)
   - SKU: Unique identifier (e.g., `golden-moments-001`)

2. **App Information**
   - **Category**: Games > Puzzle
   - **Content Rights**: Check if you have rights to use content
   - **Age Rating**: Complete questionnaire (likely 4+ for this app)
   - **App Review Information**: Contact details for Apple review team

### 3. Xcode Project Configuration

1. **Open iOS Project**
   ```bash
   cd /Volumes/SSD/memory_lane/memory_lane
   open ios/Runner.xcworkspace
   ```

2. **Configure Project Settings**
   - Select "Runner" project in navigator
   - Go to "Signing & Capabilities" tab
   - **Team**: Select your Apple Developer team
   - **Bundle Identifier**: Update to `com.mindfulness.goldenmoments` (remove underscores)
   - **Deployment Info**: 
     - iOS Deployment Target: 15.0 (kept from the Firebase era)
     - Device Orientation: Portrait, Landscape Left, Landscape Right

3. **Update Bundle Identifier**
   ```bash
   # IMPORTANT: Update bundle identifier to remove underscores (not allowed by Apple)
   # 
   # Current (needs update): com.mindfulness.golden_moments
   # New (Apple compliant): com.mindfulness.goldenmoments
   # 
   # Update in Xcode project settings:
   # Production: com.mindfulness.goldenmoments
   
   # 
   # Ensure App Store Connect uses: com.mindfulness.goldenmoments
   ```

   **Steps to update bundle identifier in Xcode:**
   1. Open `ios/Runner.xcworkspace` in Xcode
   2. Select "Runner" project → "Runner" target
   3. Go to "Signing & Capabilities" tab
   4. Update "Bundle Identifier" field for all configurations
   5. Repeat for "Runner-Debug", "Runner-Release", "Runner-Staging" if they exist

### 4. App Metadata and Assets

1. **App Icon**
   - Ensure `assets/icons/app_icon.png` is 1024x1024px
   - Run: `flutter pub run flutter_launcher_icons:main`
   - Verify icons are generated in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

2. **Launch Screen**
   - Configure in `ios/Runner/Base.lproj/LaunchScreen.storyboard`
   - Or use flutter_native_splash (already configured in pubspec.yaml)

3. **App Store Screenshots**
   - Required sizes:
     - iPhone 6.7": 1290x2796px (3 screenshots minimum)
     - iPhone 6.5": 1242x2688px
     - iPhone 5.5": 1242x2208px
     - iPad Pro 12.9": 2048x2732px (if supporting iPad)
   - Take screenshots using iOS Simulator or real devices

## Building and Submitting

### 1. Prepare Release Build

1. **Update Version Numbers**
   ```yaml
   # In pubspec.yaml
   version: 1.1.1+3  # Format: major.minor.patch+build_number
   ```

2. **Build Release Archive**
   ```bash
   # Use the clean rebuild script for reliable builds
   ./scripts/recreate_ios_project.sh
   
   # Or manually:
   flutter clean
   flutter pub get
   flutter build ios --release --no-codesign
   ```

3. **Open Xcode and Archive**
   ```bash
   open ios/Runner.xcworkspace
   ```
   - In Xcode:
     - Select "Any iOS Device" as target
     - Product → Archive
     - Wait for archive to complete

### 2. Upload to App Store Connect

1. **In Xcode Organizer**
   - Window → Organizer
   - Select your archive
   - Click "Distribute App"
   - Choose "App Store Connect"
   - Select "Upload"
   - Choose signing options (automatic recommended)
   - Review and upload

2. **Alternative: Using Application Loader**
   ```bash
   # Export IPA first, then upload via Application Loader
   # or use xcrun altool (command line)
   ```

### 3. Complete App Store Connect Submission

1. **App Information**
   - App Name: "Golden Moments"
   - Subtitle: "Tile-Matching Memory Game"
   - Description: Write compelling description highlighting features for seniors
   - Keywords: "memory game,puzzle,seniors,nostalgia,matching,brain training"
   - Support URL: Your website/support page
   - Privacy Policy URL: Required

2. **Pricing and Availability**
   - Price: Free (or set price)
   - Availability: All countries or select specific regions
   - Release: Manual or automatic after approval

3. **App Review Information**
   - Contact Information
   - Demo Account (if app requires login)
   - Notes: Any special instructions for reviewers

4. **Version Information**
   - What's New: Describe new features/fixes
   - Build: Select the uploaded build
   - Routing App Coverage: Not applicable
   - Sign-In Required: No (assuming no login required)

### 4. Submit for Review

1. **Review Submission Checklist**
   - [ ] All required metadata filled
   - [ ] Screenshots uploaded for all device sizes
   - [ ] App icon uploaded (1024x1024px)
   - [ ] Privacy policy linked
   - [ ] Age rating completed
   - [ ] Build selected and validated

2. **Submit**
   - Click "Submit for Review"
   - App status changes to "Waiting for Review"
   - Review typically takes 24-48 hours

## Updating Existing App

### 1. Prepare New Version

1. **Update Version Numbers**
   ```yaml
   # In pubspec.yaml - increment version
   version: 1.2.0+4  # New version, increment build number
   ```

2. **Update CHANGELOG.md**
   ```markdown
   ## [1.2.0] - 2025-07-30
   ### Added
   - New flower pack categories
   - Enhanced memory game mechanics
   
   ### Fixed
   - Performance improvements
   - Bug fixes for iOS 17
   ```

### 2. Build and Upload New Version

1. **Follow same build process**
   ```bash
   flutter clean
   flutter pub get
   flutter build ios --release --no-codesign -t lib/main.dart 
   ```

2. **Archive and Upload**
   - Same process as initial submission
   - Use Xcode Organizer to upload new build

### 3. Create New Version in App Store Connect

1. **Add New Version**
   - Go to your app in App Store Connect
   - Click "+" next to "iOS App"
   - Enter new version number (e.g., 1.2.0)

2. **Update Version Information**
   - "What's New in This Version": Describe changes/improvements
   - Select new build
   - Update screenshots if UI changed
   - Review other metadata for changes

3. **Submit Update**
   - Submit for review following same process
   - Updates typically have faster review times

## App Store Review Guidelines

### Common Issues to Avoid

1. **Metadata Issues**
   - Ensure app name consistency
   - Accurate app description
   - Proper keyword usage (no keyword stuffing)

2. **Technical Issues**
   - App crashes on launch
   - Missing required features
   - Poor performance on older devices

3. **Content Issues**
   - Inappropriate content for age rating
   - Copyright violations in images/sounds
   - Missing privacy policy

### Testing Before Submission

1. **Device Testing**
   ```bash
   # Test on multiple iOS versions and devices
   # Minimum: iPhone 8, iPhone 12/13, iPad (if supported)
   ```

2. **Accessibility Testing**
   - Large text support (important for senior users)
   - VoiceOver compatibility
   - Color contrast compliance

3. **Performance Testing**
   - Memory usage
   - Battery consumption
   - Network connectivity handling

## Post-Approval Process

### 1. Release Management

1. **Manual Release**
   - Control exact release timing
   - Coordinate with marketing efforts

2. **Automatic Release**
   - App goes live immediately after approval
   - Good for urgent bug fixes

### 2. Monitoring

1. **App Store Connect Analytics**
   - Downloads and revenue
   - Crash reports
   - User reviews and ratings

2. **In-app analytics** are not integrated (Firebase was removed); engagement is measured by consented diaries and interviews

## Troubleshooting Common Issues

### Build Issues

1. **Code Signing Errors**
   ```bash
   # Clear derived data
   rm -rf ~/Library/Developer/Xcode/DerivedData/
   
   # Regenerate profiles in Xcode
   # Xcode → Preferences → Accounts → Download Manual Profiles
   ```

2. **Pod Install Issues**
   ```bash
   cd ios
   pod deintegrate
   pod cache clean --all
   pod install
   ```

3. **If Build Issues Persist**
   
   **Use the Clean Rebuild Script:**
   ```bash
   # This recreates the iOS project from scratch with proper configuration
   ./scripts/recreate_ios_project.sh
   ```
   
   This script:
   - Removes the old iOS project completely
   - Recreates it using Flutter's standard approach
   - Sets iOS 15.0 target (kept from the Firebase era)
   - Installs all dependencies cleanly
   - Tests the build to ensure it works
   
   This approach eliminates complex configuration issues and gives you a clean, working iOS project.

### Submission Issues

1. **Binary Rejected**
   - Check email for specific rejection reasons
   - Address issues and resubmit
   - Common: metadata mismatch, technical issues

2. **App Review Rejection**
   - Review Apple's feedback carefully
   - Make required changes
   - Respond to reviewer if clarification needed

## Useful Commands

```bash
# Check Flutter doctor for iOS setup
flutter doctor -v

# Build for iOS release
flutter build ios --release

# Clean build artifacts
flutter clean

# Update pods
cd ios && pod repo update && pod install

# Check iOS deployment targets
grep -r "IPHONEOS_DEPLOYMENT_TARGET" ios/

# Generate app icons
flutter pub run flutter_launcher_icons:main

# Generate splash screens
flutter pub run flutter_native_splash:create
```

## Resources

- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Flutter iOS Deployment Guide](https://docs.flutter.dev/deployment/ios)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)

## Support Contacts

- **Apple Developer Support**: developer.apple.com/contact/
- **App Store Review Board**: For appeal process
- **Flutter Community**: flutter.dev/community

---

**Note**: Keep this document updated as Apple's policies and Flutter's iOS deployment process evolve. Always refer to the latest Apple Developer documentation for the most current requirements.
