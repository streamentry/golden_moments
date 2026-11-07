import 'package:golden_moments/features/gentle_activities/models/activity_picture.dart';
import 'package:golden_moments/features/reminders/data/reminder_settings.dart';
import 'package:golden_moments/features/todays_activity/data/todays_activity.dart';
import 'package:golden_moments/features/wellbeing/data/daily_moment_pictures.dart';
import 'package:golden_moments/l10n/l10n.dart';

/// One reminder on one date, at the chosen local wall-clock time.
typedef PlannedReminder = ({DateTime at, String title, String body});

/// Reminders follow the chosen days for this many days after the app was
/// last opened...
const reminderDailyDays = 14;

/// ...then come at most once a week, and none are planned past this.
const reminderHorizonDays = 42;

/// Morning before noon, afternoon until 5 pm, evening after.
enum DayPart {
  morning,
  afternoon,
  evening;

  static DayPart of(int hour) => hour < 12
      ? morning
      : hour < 17
      ? afternoon
      : evening;
}

int _calendarDays(DateTime from, DateTime to) => DateTime.utc(
  to.year,
  to.month,
  to.day,
).difference(DateTime.utc(from.year, from.month, from.day)).inDays;

/// The dates and times to remind, planned when the app is opened at [now].
///
/// - Never today: the app is open, so there is nothing to remind about.
/// - The chosen weekdays at the chosen time for [reminderDailyDays] days,
///   then at most one a week, and nothing after [reminderHorizonDays]. If no
///   one opens the app, reminders slow down and then stop by themselves;
///   opening it plans them afresh.
/// - Times are local wall-clock times (year, month, day, hour, minute), so a
///   reminder keeps its hour across daylight saving and time-zone changes.
List<DateTime> reminderDates(ReminderSettings settings, DateTime now) {
  final dates = <DateTime>[];
  for (var d = 1; d <= reminderHorizonDays; d++) {
    final at = DateTime(
      now.year,
      now.month,
      now.day + d,
      settings.hour,
      settings.minute,
    );
    if (!settings.weekdays.contains(at.weekday)) continue;
    final weekly = d > reminderDailyDays;
    if (weekly && dates.isNotEmpty && _calendarDays(dates.last, at) < 7) {
      continue;
    }
    dates.add(at);
  }
  return dates;
}

/// The words for a reminder at [at]: the day's activity (the same one Home
/// suggests for that date), framed for the time of day. A Daily moment day
/// names the three pictures it will show. Nothing counts days, mentions a
/// missed one or promises a benefit.
PlannedReminder reminderFor(
  DateTime at,
  AppLocalizations l10n, {
  List<ActivityPicture> pictures = ActivityPicture.samples,
}) {
  final activity = TodaysActivity.forDay(at);
  final part = DayPart.of(at.hour);
  final name = switch (activity) {
    TodaysActivity.dailyMoment => l10n.wellbeingHomeDailyMoment,
    TodaysActivity.lookTogether => l10n.commonLookTogether,
  };
  final title = switch (part) {
    DayPart.morning => l10n.reminderTitleMorning(name),
    DayPart.afternoon => l10n.reminderTitleAfternoon(name),
    DayPart.evening => l10n.reminderTitleEvening(name),
  };
  final dailyPictures = dailyMomentPictures(at, pictures);
  final String body;
  if (activity == TodaysActivity.dailyMoment && dailyPictures.isNotEmpty) {
    body = l10n.reminderBodyDailyMoment(
      dailyPictures
          .map((p) => p.localizedLabel(l10n))
          .join(l10n.reminderDayListSeparator),
    );
  } else {
    final options = switch (part) {
      DayPart.morning => [l10n.reminderBodyMorning1, l10n.reminderBodyMorning2],
      DayPart.afternoon => [
        l10n.reminderBodyAfternoon1,
        l10n.reminderBodyAfternoon2,
      ],
      DayPart.evening => [l10n.reminderBodyEvening1, l10n.reminderBodyEvening2],
    };
    body = options[_calendarDays(DateTime(2024), at) ~/ 2 % options.length];
  }
  return (at: at, title: title, body: body);
}

/// Every reminder to schedule when the app is opened at [now].
List<PlannedReminder> planReminders(
  ReminderSettings settings,
  DateTime now,
  AppLocalizations l10n, {
  List<ActivityPicture> pictures = ActivityPicture.samples,
}) => [
  for (final at in reminderDates(settings, now))
    reminderFor(at, l10n, pictures: pictures),
];
