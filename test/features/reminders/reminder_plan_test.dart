import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/features/gentle_activities/models/activity_picture.dart';
import 'package:golden_moments/features/reminders/data/reminder_plan.dart';
import 'package:golden_moments/features/reminders/data/reminder_settings.dart';
import 'package:golden_moments/features/todays_activity/data/todays_activity.dart';
import 'package:golden_moments/features/wellbeing/data/daily_moment_pictures.dart';
import 'package:golden_moments/l10n/l10n.dart';

import '../../helpers/l10n_helpers.dart';

const _everyDay = ReminderSettings(enabled: true);

void main() {
  final now = DateTime(2026, 11, 7, 9, 30); // a Saturday morning

  group('reminderDates', () {
    test('never today: the app is open', () {
      final dates = reminderDates(_everyDay, now);
      expect(dates.first, DateTime(2026, 11, 8, 10));
      expect(dates.where((d) => d.day == 7 && d.month == 11), isEmpty);
    });

    test('daily for two weeks, then once a week, then nothing', () {
      final dates = reminderDates(_everyDay, now);
      final cutoff = DateTime(now.year, now.month, now.day + 15);
      final daily = dates.where((d) => d.isBefore(cutoff));
      expect(daily, hasLength(reminderDailyDays));
      final later = dates.skip(reminderDailyDays).toList();
      expect(later, isNotEmpty);
      for (var i = 1; i < later.length; i++) {
        expect(later[i].difference(later[i - 1]).inHours, greaterThan(6 * 24));
      }
      expect(dates.last.isBefore(now.add(const Duration(days: 43))), isTrue);
      // Well under iOS's 64 pending notifications.
      expect(dates.length, lessThan(30));
    });

    test('keeps to the chosen days and time', () {
      const settings = ReminderSettings(
        enabled: true,
        weekdays: {DateTime.tuesday, DateTime.thursday},
        hour: 16,
        minute: 45,
      );
      for (final d in reminderDates(settings, now)) {
        expect(settings.weekdays, contains(d.weekday));
        expect((d.hour, d.minute), (16, 45));
      }
    });

    test('keeps the wall-clock hour across a clock change', () {
      // US daylight saving ended 2026-11-01; plan from just before it.
      final dates = reminderDates(_everyDay, DateTime(2026, 10, 29, 8));
      expect(dates.every((d) => d.hour == 10 && d.minute == 0), isTrue);
      // One per calendar day, none skipped or doubled at the change.
      final days = dates.take(14).map((d) => DateTime(d.year, d.month, d.day));
      expect(days.toSet(), hasLength(14));
    });
  });

  group('reminderFor', () {
    final l10n = englishL10n;

    DateTime dayOf(TodaysActivity activity, int hour) {
      var day = DateTime(2026, 11, 8, hour);
      while (TodaysActivity.forDay(day) != activity) {
        day = day.add(const Duration(days: 1));
      }
      return day;
    }

    test('names the activity Home suggests that day, for the time of day', () {
      final morning = reminderFor(dayOf(TodaysActivity.lookTogether, 9), l10n);
      expect(morning.title, 'This morning: Look together');
      final afternoon = reminderFor(
        dayOf(TodaysActivity.dailyMoment, 14),
        l10n,
      );
      expect(afternoon.title, 'This afternoon: Daily moment');
      final evening = reminderFor(dayOf(TodaysActivity.lookTogether, 19), l10n);
      expect(evening.title, 'This evening: Look together');
    });

    test('a Daily moment names the three pictures that day shows', () {
      final at = dayOf(TodaysActivity.dailyMoment, 10);
      final names = dailyMomentPictures(
        at,
        ActivityPicture.samples,
      ).map((p) => p.label);
      expect(names, hasLength(3));
      expect(
        reminderFor(at, l10n).body,
        'Three pictures are ready: ${names.join(', ')}. '
        'A few minutes together, and you can stop at any time.',
      );
    });

    test('Look together days vary their words', () {
      final bodies = {
        for (var i = 0; i < 8; i++)
          reminderFor(
            dayOf(TodaysActivity.lookTogether, 9).add(Duration(days: 2 * i)),
            l10n,
          ).body,
      };
      expect(bodies, hasLength(2));
    });

    test('never counts, scolds or promises', () {
      for (final r in planReminders(_everyDay, now, l10n)) {
        final text = '${r.title} ${r.body}'.toLowerCase();
        for (final word in [
          'streak',
          'missed',
          'miss you',
          "haven't",
          'days in a row',
          'brain',
          'memory',
          'improve',
          'score',
          '!',
        ]) {
          expect(text, isNot(contains(word)), reason: '${r.at}: $text');
        }
      }
    });

    test('speaks the app language, picture names included', () {
      final german = lookupAppLocalizations(const Locale('de'));
      final r = reminderFor(dayOf(TodaysActivity.dailyMoment, 10), german);
      expect(r.title, contains(german.wellbeingHomeDailyMoment));
      final first = dailyMomentPictures(
        r.at,
        ActivityPicture.samples,
      ).first.localizedLabel(german);
      expect(r.body, contains(first));
    });
  });
}
