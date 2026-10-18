import 'package:flutter/foundation.dart';

/// Google Play listing for the Android package.
const playStoreUrl =
    'https://play.google.com/store/apps/details'
    '?id=com.mindfulness.golden_moments';

/// App Store listing. Set this once the iOS app is published; until then
/// Apple devices are told how to find the app instead of getting a wrong link.
const String? appStoreUrl = null;

/// The share message for the device the app is running on, so nobody on an
/// iPhone or Mac is sent to Google Play.
String appShareText({TargetPlatform? platform, String? appStoreLink}) {
  final target = platform ?? defaultTargetPlatform;
  final appleLink = appStoreLink ?? appStoreUrl;
  const intro = 'A gentle picture game we enjoy together: Golden Moments.';
  switch (target) {
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
      return appleLink == null
          ? '$intro Search for "Golden Moments" in the App Store.'
          : '$intro\n$appleLink';
    case TargetPlatform.android:
    case TargetPlatform.fuchsia:
    case TargetPlatform.linux:
    case TargetPlatform.windows:
      return '$intro\n$playStoreUrl';
  }
}
