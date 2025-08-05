# Fix Flutter SIGABRT Crash Issue

## Task Overview
Resolve the Flutter crash with "Thread 1: signal SIGABRT" when running `flutter run --target lib/main.dart`.

## Root Cause Analysis
- ✅ Identified missing iOS Firebase configuration file (`GoogleService-Info.plist`)
- ✅ Android has `google-services.json` but iOS is missing its equivalent
- ✅ App crashes during `Firebase.initializeApp()` call in bootstrap.dart
- ✅ Added Firebase error handling in bootstrap.dart
- ✅ Added GoogleService-Info.plist to iOS project
- ✅ Web testing revealed sound service auto-play issue
- ✅ Sound service tries to play music on app lifecycle changes without user interaction

## Implementation Plan

### Phase 1: Firebase Configuration Fix
- [ ] Add GoogleService-Info.plist to iOS Runner directory
- [ ] Update iOS project configuration to include Firebase
- [ ] Verify Firebase initialization works on iOS

### Phase 2: Error Handling Improvements
- [ ] Add try-catch blocks around Firebase initialization
- [ ] Implement graceful fallback if Firebase fails to initialize
- [ ] Add better error logging for debugging

### Phase 3: Testing & Validation
- [ ] Test app launch on iOS device/simulator
- [ ] Verify all Firebase features work correctly
- [ ] Test sound service initialization
- [ ] Validate download manager functionality

### Phase 4: Documentation
- [ ] Update README with Firebase setup instructions
- [ ] Document troubleshooting steps for similar issues
- [ ] Add development setup guide

## Expected Outcomes
- App launches successfully without crashes
- Firebase services work correctly on both platforms
- Better error handling and debugging capabilities
- Clear documentation for future developers

## Technical Notes
- Firebase initialization happens in `lib/bootstrap.dart`
- Sound service and download manager depend on successful app initialization
- Current iOS configuration is incomplete
