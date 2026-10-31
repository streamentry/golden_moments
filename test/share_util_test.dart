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
      expect(text, contains('apps.apple.com'));
    }
  });

  test('the App Store link is the published listing, without tracking', () {
    expect(appStoreUrl, 'https://apps.apple.com/app/id6749312459');
    expect(appStoreUrl, isNot(contains('?')));
  });
}
