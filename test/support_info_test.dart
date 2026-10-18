import 'dart:convert';
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

  test('supportUrl is the support_url in the canonical store metadata', () {
    final metadata = jsonDecode(
      File('metadata/app-store.en-US.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    expect(supportUrl, metadata['support_url']);
    expect(Uri.parse(supportUrl).scheme, 'https');
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

    test('invisible characters are not sent, so the preview is complete', () {
      final text = feedbackMessage(
        'a\u200Bb\u202Ec\u2066d\uFEFFe',
        platform: TargetPlatform.iOS,
      );
      final note = text.split('\n\n').first;
      expect(note, 'a b c d e');
      for (final unit in note.runes) {
        expect(
          unit > 0x1F &&
              !(unit >= 0x200B && unit <= 0x200F) &&
              !(unit >= 0x202A && unit <= 0x202E) &&
              !(unit >= 0x2066 && unit <= 0x2069) &&
              unit != 0xFEFF,
          isTrue,
        );
      }
    });

    test('markup stays inert text', () {
      expect(
        feedbackMessage('<b>hi</b>', platform: TargetPlatform.iOS),
        startsWith('<b>hi</b>'),
      );
    });
  });
}
