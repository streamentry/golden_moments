import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/features/wellbeing/data/moment_history.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _key = 'wellbeing.momentDays.v1';

void main() {
  group('MomentHistoryStore', () {
    const store = MomentHistoryStore();

    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('day keys are zero-padded yyyy-MM-dd in the local calendar', () {
      expect(
        MomentHistoryStore.dayKey(DateTime(2026, 1, 5, 23, 59)),
        '2026-01-05',
      );
      expect(MomentHistoryStore.dayKey(DateTime(2026, 11, 6)), '2026-11-06');
    });

    test('nothing saved reads as an empty, readable history', () async {
      final history = await store.load();
      expect(history.days, isEmpty);
      expect(history.readable, isTrue);
    });

    test(
      'marking a day done keeps each day once, sorted, with no time',
      () async {
        expect(await store.markDone(DateTime(2026, 11, 6, 9)), isTrue);
        expect(await store.markDone(DateTime(2026, 11, 6, 20)), isTrue);
        expect(await store.markDone(DateTime(2026, 11, 2, 12)), isTrue);

        final history = await store.load();
        expect(history.days, {'2026-11-06', '2026-11-02'});
        final saved = (await SharedPreferences.getInstance()).getString(_key)!;
        expect(jsonDecode(saved), {
          'v': 1,
          'days': ['2026-11-02', '2026-11-06'],
        });
      },
    );

    test('clear removes every saved day', () async {
      await store.markDone(DateTime(2026, 11, 6));
      await store.clear();
      expect((await store.load()).days, isEmpty);
    });

    for (final corrupt in [
      'not json at all',
      '{"v":2,"days":["2026-11-06"]}',
      '{"v":1,"days":"2026-11-06"}',
      '{"v":1,"days":[42]}',
      '{"v":1,"days":["06/11/2026"]}',
      '{"v":1}',
    ]) {
      test('an unreadable record ($corrupt) is shown as unreadable and never '
          'overwritten', () async {
        SharedPreferences.setMockInitialValues({_key: corrupt});

        final history = await store.load();
        expect(history.readable, isFalse);
        expect(history.days, isEmpty);

        expect(await store.markDone(DateTime(2026, 11, 6)), isFalse);
        final still = (await SharedPreferences.getInstance()).getString(_key);
        expect(still, corrupt, reason: 'the damaged record must be left as is');
      });
    }

    test('clear can remove an unreadable record on purpose', () async {
      SharedPreferences.setMockInitialValues({_key: 'broken'});
      await store.clear();
      final history = await store.load();
      expect(history.readable, isTrue);
      expect(history.days, isEmpty);
    });
  });
}
