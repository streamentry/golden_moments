import 'package:flutter/foundation.dart';
import 'package:golden_moments/l10n/l10n.dart';

/// Google Play listing for the Android package.
const playStoreUrl =
    'https://play.google.com/store/apps/details'
    '?id=com.mindfulness.golden_moments';

/// App Store id of the published listing, "Dementia Games: Golden Moments"
/// (checked on apps.apple.com on 2026-10-30).
const appStoreId = '6749312459';

/// App Store listing, without tracking parameters.
const appStoreUrl = 'https://apps.apple.com/app/id$appStoreId';

/// The share message for the device the app is running on, so nobody on an
/// iPhone or Mac is sent to Google Play. The sentence is in the app's
/// language; the link is the same everywhere.
String appShareText(AppLocalizations l10n, {TargetPlatform? platform}) {
  final target = platform ?? defaultTargetPlatform;
  final intro = l10n.shareMessage;
  switch (target) {
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
      return '$intro\n$appStoreUrl';
    case TargetPlatform.android:
    case TargetPlatform.fuchsia:
    case TargetPlatform.linux:
    case TargetPlatform.windows:
      return '$intro\n$playStoreUrl';
  }
}
