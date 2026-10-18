import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/shared/utils/support_info.dart';

void main() {
  test('appVersion matches pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final version = RegExp(
      r'^version:\s*(\S+)',
      multiLine: true,
    ).firstMatch(pubspec)!.group(1);
    expect(appVersion, version);
  });

  group('diagnostic summary', () {
    test('is only app version, platform family and one problem code', () {
      for (final kind in ProblemKind.values) {
        final text = diagnosticSummary(kind, platform: TargetPlatform.iOS);
        expect(text.split('\n'), [
          'Golden Moments $appVersion',
          'Platform: iOS',
          'Problem: ${kind.code}',
        ]);
      }
    });

    test('codes are a fixed, plain, distinct list', () {
      final codes = ProblemKind.values.map((k) => k.code).toList();
      expect(codes.toSet().length, codes.length);
      for (final code in codes) {
        expect(code, matches(RegExp(r'^[a-z-]+$')));
      }
    });

    test('nothing personal can enter the summary', () {
      // The only inputs are the enum and the platform; seeded personal
      // strings from elsewhere in the app have no way in.
      final seeds = [
        '/data/user/0/app/family_photos_v1/${'a' * 64}.png',
        'Grandma Rose',
        'Lake day caption',
      ];
      for (final kind in ProblemKind.values) {
        final text = diagnosticSummary(kind);
        for (final seed in seeds) {
          expect(text, isNot(contains(seed)));
        }
        expect(text, isNot(matches(RegExp('[a-f0-9]{16,}'))));
      }
    });
  });

  group('feedback message', () {
    test('keeps the note and adds only version and platform', () {
      expect(
        feedbackMessage(
          'Large text works well.',
          platform: TargetPlatform.android,
        ),
        'Large text works well.\n\n— Golden Moments $appVersion, Android',
      );
    });

    test('tidies control characters and runs of blank space', () {
      final text = feedbackMessage(
        '  Hello\u0007   there \n\n\n\nbye  ',
        platform: TargetPlatform.iOS,
      );
      expect(text, startsWith('Hello there \n\nbye\n\n'));
      expect(text, isNot(contains('\u0007')));
    });

    test('is capped at the maximum length', () {
      final text = feedbackMessage('x' * 5000, platform: TargetPlatform.iOS);
      expect(text.split('\n\n').first.length, maxNoteLength);
    });

    test('markup stays inert text', () {
      expect(
        feedbackMessage('<b>hi</b>', platform: TargetPlatform.iOS),
        startsWith('<b>hi</b>'),
      );
    });
  });
}
