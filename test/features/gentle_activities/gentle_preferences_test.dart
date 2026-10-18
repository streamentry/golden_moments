import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/features/gentle_activities/data/gentle_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const store = GentlePreferencesStore();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('fresh install defaults to four visible tiles', () async {
    final prefs = await store.load();
    expect(prefs.pairs, 2);
    expect(prefs.keepVisible, isTrue);
  });

  test('choices survive a restart as a versioned record', () async {
    expect(
      await store.save(const GentlePreferences(pairs: 4, keepVisible: false)),
      isTrue,
    );
    final raw = (await SharedPreferences.getInstance()).getString(
      GentlePreferences.storageKey,
    );
    expect(
      jsonDecode(raw!),
      containsPair('v', GentlePreferences.schemaVersion),
    );
    final restored = await const GentlePreferencesStore().load();
    expect(restored, const GentlePreferences(pairs: 4, keepVisible: false));
  });

  test('an invalid field falls back alone and keeps the valid one', () {
    final prefs = GentlePreferences.fromJson(const {
      'v': 1,
      'pairs': 99,
      'keepVisible': false,
    });
    expect(prefs.pairs, GentlePreferences.defaultPairs);
    expect(prefs.keepVisible, isFalse);
    final other = GentlePreferences.fromJson(const {
      'v': 1,
      'pairs': 6,
      'keepVisible': 'yes',
    });
    expect(other.pairs, 6);
    expect(other.keepVisible, isTrue);
  });

  test(
    'malformed, missing-version and newer-version data use defaults',
    () async {
      for (final bad in <Object?>[
        null,
        3,
        'x',
        [],
        {'pairs': 4},
        {'v': 2},
      ]) {
        expect(GentlePreferences.fromJson(bad), const GentlePreferences());
      }
      SharedPreferences.setMockInitialValues({
        GentlePreferences.storageKey: '{not json',
      });
      expect(await store.load(), const GentlePreferences());
    },
  );

  test('reset removes comfort choices only', () async {
    SharedPreferences.setMockInitialValues({
      GentlePreferences.storageKey: jsonEncode(
        const GentlePreferences(pairs: 6).toJson(),
      ),
      'unrelated.family.photos.index': 'kept',
    });
    expect(await store.reset(), isTrue);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(GentlePreferences.storageKey), isNull);
    expect(prefs.getString('unrelated.family.photos.index'), 'kept');
    expect(await store.load(), const GentlePreferences());
  });
}
