# Codemagic Troubleshooting Guide

This guide helps resolve common issues when setting up and running Codemagic CI/CD for the Golden Moments Flutter project.

## 🚨 Common Build Failures

### 1. Flutter SDK Issues

#### Problem: Flutter version mismatch
```
Error: The current Flutter SDK version is 3.7.0
Your project requires Flutter 3.8.0 or higher
```

#### Solution:
1. Update `FLUTTER_VERSION` in `codemagic.yaml`:
```yaml
environment:
  vars:
    FLUTTER_VERSION: 3.8.0  # Match your project requirements
```

2. Or use the latest stable:
```yaml
environment:
  flutter: stable
```

### 2. Dependency Issues

#### Problem: Package resolution failures
```
Error: Could not resolve dependencies
```

#### Solution:
1. Ensure `pubspec.yaml` is properly formatted
2. Check for conflicting dependencies
3. Add a clean step to your workflow:
```yaml
scripts:
  - name: Clean and get dependencies
    script: |
      flutter clean
      flutter packages pub get
```

### 3. Android Build Issues

#### Problem: Gradle build failures
```
Error: Could not determine java version from '11.0.2'
```

#### Solution:
Update Java version in `codemagic.yaml`:
```yaml
environment:
  java: 17  # or 11, depending on your needs
```

#### Problem: Signing configuration not found
```
Error: No signing config for flavor 'production'
```

#### Solution:
1. Verify keystore is uploaded to Codemagic
2. Check environment variable names match your `build.gradle`:
```gradle
signingConfigs {
    release {
        storeFile file(System.getenv("CM_KEYSTORE_PATH"))
        keyAlias System.getenv("CM_KEY_ALIAS")
        keyPassword System.getenv("CM_KEY_PASSWORD")
        storePassword System.getenv("CM_KEYSTORE_PASSWORD")
    }
}
```

### 4. iOS Build Issues

#### Problem: Code signing failures
```
Error: No profiles for 'com.mindfulness.golden_moments' were found
```

#### Solution:
1. Verify bundle identifier matches exactly
2. Check certificate and provisioning profile validity
3. Use automatic signing in Codemagic dashboard

#### Problem: Xcode version compatibility
```
Error: iOS deployment target '11.0' is deprecated
```

#### Solution:
Update `ios/Flutter/AppFrameworkInfo.plist`:
```xml
<key>MinimumOSVersion</key>
<string>12.0</string>
```

## 🔧 Configuration Issues

### 1. Environment Variables

#### Problem: Variables not loading
```
Error: Environment variable 'FIREBASE_TOKEN' not found
```

#### Solution:
1. Check variable name spelling in Codemagic dashboard
2. Ensure variables are set in the correct group (global vs app-specific)
3. Verify variable visibility (secure vs non-secure)

### 2. Firebase Configuration

#### Problem: Firebase setup errors
```
Error: firebase_core plugin not configured
```

#### Solution:
1. Ensure `google-services.json` is in `android/app/`
2. Verify Firebase project configuration
3. Check if Firebase CLI token is valid:
```bash
firebase login:ci
```

### 3. Store Publishing Issues

#### Problem: Google Play upload failures
```
Error: Package name does not match
```

#### Solution:
1. Verify application ID in `build.gradle` matches Play Console
2. Check service account permissions
3. Ensure proper track configuration:
```yaml
google_play:
  track: internal  # or alpha, beta, production
  submit_as_draft: true
```

## 🔍 Debugging Strategies

### 1. Enable Verbose Logging

Add debug information to your scripts:
```yaml
scripts:
  - name: Debug Environment
    script: |
      echo "Flutter version: $(flutter --version)"
      echo "Dart version: $(dart --version)"
      echo "Java version: $JAVA_HOME"
      echo "Android SDK: $ANDROID_SDK_ROOT"
      flutter doctor -v
```

### 2. Artifact Investigation

Check build outputs:
```yaml
artifacts:
  - build/**/outputs/**/*.apk
  - build/**/outputs/**/mapping.txt
  - build/ios/ipa/*.ipa
  - /tmp/xcodebuild_logs/*.log
  - flutter_drive.log
  - $HOME/Library/Developer/Xcode/DerivedData/**/Build/Intermediates.noindex/XCBuildData/build.db
```

### 3. Local Reproduction

Test locally before pushing:
```bash
# Clean build
flutter clean

# Get dependencies
flutter packages pub get

# Analyze code
flutter analyze --fatal-infos

# Run tests
flutter test

# Build for specific flavor
flutter build apk --release --flavor production
flutter build ios --release --no-codesign --flavor production
```

## 📱 Platform-Specific Issues

### Android

#### Proguard/R8 Issues
```
Error: Missing classes during minification
```

Solution - Update `android/app/proguard-rules.pro`:
```pro
# Keep Firebase classes
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Keep your custom classes
-keep class com.mindfulness.golden_moments.** { *; }
```

#### NDK Issues
```
Error: NDK not found
```

Solution - Add NDK configuration:
```yaml
environment:
  vars:
    ANDROID_NDK_ROOT: $ANDROID_SDK_ROOT/ndk/25.1.8937393
```

### iOS

#### Provisioning Profile Issues
```
Error: Profile doesn't include the platform
```

Solution:
1. Regenerate provisioning profiles
2. Ensure all required devices are included
3. Check certificate expiration

#### Info.plist Issues
```
Error: Invalid Info.plist file
```

Solution - Validate Info.plist structure:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Your configuration -->
</dict>
</plist>
```

## 🕐 Performance Issues

### Slow Builds

1. **Optimize dependencies**: Remove unused packages
2. **Use caching**: Enable appropriate caching strategies
3. **Parallel builds**: Configure gradle for parallel execution
4. **Instance type**: Use faster instance types for critical builds

### Build Timeouts

Increase timeout in `codemagic.yaml`:
```yaml
workflows:
  production:
    max_build_duration: 120  # Increase to 2 hours
```

## 🆘 Getting Help

### 1. Check Codemagic Status
Visit [status.codemagic.io](https://status.codemagic.io) for service status

### 2. Documentation Resources
- [Codemagic Docs](https://docs.codemagic.io)
- [Flutter Troubleshooting](https://docs.flutter.dev/testing/debugging)
- [Android Build Issues](https://developer.android.com/studio/troubleshoot)

### 3. Community Support
- [Codemagic Slack](https://codemagicio.slack.com)
- [Flutter Discord](https://discord.gg/flutter)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/codemagic)

### 4. Contact Support
- Email: support@codemagic.io
- In-app chat: Available in Codemagic dashboard
- Priority support: Available for paid plans

## 📋 Pre-flight Checklist

Before triggering a build, verify:

- [ ] All required environment variables are set
- [ ] Code signing certificates are valid and not expired
- [ ] Dependencies are up to date and compatible
- [ ] Local build passes successfully
- [ ] Tests are passing
- [ ] Configuration files are properly formatted
- [ ] Required permissions are granted for publishing
- [ ] Firebase/Store configurations are correct

## 🔄 Recovery Procedures

### Failed Build Recovery
1. Check build logs for specific error messages
2. Verify configuration against working builds
3. Test changes locally before re-triggering
4. Consider reverting to last known good configuration

### Emergency Rollback
1. Use Git to revert problematic commits
2. Trigger new build from stable branch
3. Monitor build completion and artifact generation
4. Verify deployed version functionality

---

Remember: Most build issues are configuration-related. Double-check your setup against this guide and the official Codemagic documentation.
