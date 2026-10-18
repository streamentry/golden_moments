import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/shared/utils/share_util.dart';

void main() {
  test('Android shares the Google Play listing', () {
    expect(
      appShareText(platform: TargetPlatform.android),
      contains(playStoreUrl),
    );
  });

  test('Apple devices are never sent to Google Play', () {
    for (final platform in [TargetPlatform.iOS, TargetPlatform.macOS]) {
      final text = appShareText(platform: platform);
      expect(text, isNot(contains('play.google.com')));
      expect(text, contains('App Store'));
    }
  });

  test('Apple devices get the App Store link once it exists', () {
    const link = 'https://apps.apple.com/app/id0000000000';
    expect(
      appShareText(platform: TargetPlatform.iOS, appStoreLink: link),
      contains(link),
    );
  });
}
