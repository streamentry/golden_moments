import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/features/todays_activity/data/todays_activity.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('TodaysActivity.forDay', () {
    test('is the same all day long', () {
      final morning = TodaysActivity.forDay(DateTime(2026, 11, 7, 6));
      final night = TodaysActivity.forDay(DateTime(2026, 11, 7, 23, 59));
      expect(night, morning);
    });

    test('changes from one day to the next, in a steady order', () {
      final day = DateTime(2026, 11, 7);
      final seen = [
        for (var i = 0; i < TodaysActivity.values.length * 2; i++)
          TodaysActivity.forDay(day.add(Duration(days: i))),
      ];
      // Every activity comes round, and consecutive days differ.
      expect(seen.toSet(), TodaysActivity.values.toSet());
      for (var i = 1; i < seen.length; i++) {
        expect(seen[i], isNot(seen[i - 1]));
      }
    });

    test('ignores daylight-saving hours (calendar day only)', () {
      // US clocks change on 2026-11-01; the next calendar day still advances.
      final before = TodaysActivity.forDay(DateTime(2026, 10, 31, 12));
      final after = TodaysActivity.forDay(DateTime(2026, 11, 1, 12));
      expect(after, isNot(before));
    });
  });

  group('TodaysActivityStore', () {
    final today = DateTime(2026, 11, 7, 9);

    test('suggests the day default when nothing is saved', () async {
      const store = TodaysActivityStore();
      expect(await store.load(today), TodaysActivity.forDay(today));
    });

    test('remembers another choice for the rest of the day', () async {
      const store = TodaysActivityStore();
      final first = await store.load(today);
      final other = await store.chooseAnother(today);
      expect(other, isNot(first));
      expect(await store.load(today.add(const Duration(hours: 10))), other);
    });

    test('a choice from yesterday does not carry over', () async {
      const store = TodaysActivityStore();
      final yesterday = today.subtract(const Duration(days: 1));
      await store.chooseAnother(yesterday);
      expect(await store.load(today), TodaysActivity.forDay(today));
    });

    test('a damaged saved value falls back to the day default', () async {
      SharedPreferences.setMockInitialValues({
        'todays_activity.day': '2026-11-07',
        'todays_activity.id': 'not-an-activity',
      });
      const store = TodaysActivityStore();
      expect(await store.load(today), TodaysActivity.forDay(today));
    });

    test('choosing another cycles through every activity', () async {
      const store = TodaysActivityStore();
      final seen = {await store.load(today)};
      for (var i = 0; i < TodaysActivity.values.length - 1; i++) {
        seen.add(await store.chooseAnother(today));
      }
      expect(seen, TodaysActivity.values.toSet());
      // And then comes back round to the first.
      expect(await store.chooseAnother(today), TodaysActivity.forDay(today));
    });
  });
}
