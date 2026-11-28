import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/features/gentle_activities/models/activity_picture.dart';
import 'package:golden_moments/features/reminders/data/nudges.dart';
import 'package:golden_moments/features/reminders/data/reminder_plan.dart';
import 'package:golden_moments/features/reminders/data/reminder_settings.dart';
import 'package:golden_moments/features/todays_activity/data/todays_activity.dart';
import 'package:golden_moments/l10n/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/l10n_helpers.dart';

const List<ActivityPicture> _pictures = ActivityPicture.samples;

/// One line a day for [days] days, as a daily note would get it.
List<(DateTime, Nudge)> _run(
  NudgeInputs inputs,
  DayPart part, {
  DateTime? from,
  int days = 400,
  bool forHome = false,
}) {
  final picker = NudgePicker(inputs: inputs, part: part, forHome: forHome);
  final start = from ?? DateTime(2026, 11, 1, 10);
  return [
    for (var d = 0; d < days; d++)
      (
        DateTime(start.year, start.month, start.day + d, start.hour),
        picker.lineFor(
          DateTime(start.year, start.month, start.day + d, start.hour),
          pictures: _pictures,
        ),
      ),
  ];
}

final List<(NudgeInputs, DayPart)> _cases = [
  for (final seed in [0, 7, 123456])
    for (final photos in [false, true])
      for (final part in DayPart.values)
        (NudgeInputs(seed: seed, hasOwnPhotos: photos), part),
];

void main() {
  test('the catalog has the 50 lines of docs/retention/nudges.md', () {
    expect(nudgeCatalog, hasLength(50));
    expect(nudgeCatalog.map((n) => n.id).toSet(), hasLength(50));
  });

  test('every line reads calmly and fills its slots in every language', () {
    final at = DateTime(2026, 11, 8, 10);
    for (final locale in AppLocalizations.supportedLocales) {
      final l10n = lookupAppLocalizations(locale);
      for (final line in nudgeCatalog) {
        final text = nudgeText(line, at, l10n);
        final where = '$locale ${line.id}: $text';
        expect(text.trim(), isNotEmpty, reason: where);
        expect(text, isNot(contains('{')), reason: where);
        expect(text, isNot(contains('!')), reason: where);
        expect(text, isNot(contains('¡')), reason: where);
      }
    }
  });

  test('English lines never count, scold, test recall or promise', () {
    final at = DateTime(2026, 11, 8, 10);
    for (final line in nudgeCatalog) {
      final text = nudgeText(line, at, englishL10n).toLowerCase();
      for (final word in [
        'streak',
        'missed',
        'miss you',
        'remember',
        'memory',
        'brain',
        'score',
        'improve',
        'days in a row',
        'hurry up',
        'last chance',
      ]) {
        expect(text, isNot(contains(word)), reason: '${line.id}: $text');
      }
    }
  });

  test('no line comes back within three weeks', () {
    for (final (inputs, part) in _cases) {
      final seen = <String, DateTime>{};
      for (final (day, line) in _run(inputs, part)) {
        final text = nudgeText(line, day, englishL10n);
        final before = seen[text];
        if (before != null) {
          expect(
            day.difference(before).inDays,
            greaterThanOrEqualTo(nudgeNoRepeatDays),
            reason: '${line.id} seed ${inputs.seed} $part on $day',
          );
        }
        seen[text] = day;
      }
    }
  });

  test('a skip line comes at most once a week; Home never shows one', () {
    for (final (inputs, part) in _cases) {
      final days = _run(inputs, part);
      for (var i = 0; i + 7 <= days.length; i++) {
        final skips = days
            .sublist(i, i + 7)
            .where((d) => d.$2.group == NudgeGroup.skip);
        expect(skips.length, lessThanOrEqualTo(1));
      }
      expect(
        _run(inputs, part, forHome: true).map((d) => d.$2.group),
        isNot(
          anyElement(
            isIn([NudgeGroup.skip, NudgeGroup.quiet, NudgeGroup.last]),
          ),
        ),
      );
    }
  });

  test('each line shows only when it is true', () {
    final timed = {
      DayPart.morning: NudgeGroup.morning,
      DayPart.afternoon: NudgeGroup.afternoon,
      DayPart.evening: NudgeGroup.evening,
    };
    for (final (inputs, part) in _cases) {
      for (final (day, line) in _run(inputs, part)) {
        final why = '${line.id} on $day';
        switch (line.group) {
          case NudgeGroup.today:
            expect(
              TodaysActivity.forDay(day),
              TodaysActivity.dailyMoment,
              reason: why,
            );
          case NudgeGroup.ownPhotos:
            expect(inputs.hasOwnPhotos, isTrue, reason: why);
          case NudgeGroup.weekday:
            final allowed = switch (line.id) {
              'W1' => [DateTime.saturday],
              'W2' || 'W3' => [DateTime.sunday],
              _ => [DateTime.monday],
            };
            expect(allowed, contains(day.weekday), reason: why);
          case NudgeGroup.morning || NudgeGroup.afternoon || NudgeGroup.evening:
            expect(line.group, timed[part], reason: why);
          case NudgeGroup.quiet || NudgeGroup.last:
            fail('$why: only for planned slots');
          case _:
        }
      }
    }
  });

  test('a date keeps its line however often reminders are planned', () {
    const inputs = NudgeInputs(seed: 99, hasOwnPhotos: true);
    final full = _run(inputs, DayPart.morning, days: 60);
    final later = NudgePicker(inputs: inputs, part: DayPart.morning);
    for (final (day, line) in full.skip(30)) {
      expect(later.lineFor(day, pictures: _pictures).id, line.id);
    }
    // Asking the same date twice gives the same answer.
    final (day, line) = full[40];
    expect(later.lineFor(day, pictures: _pictures).id, line.id);
  });

  test('different devices see different orders', () {
    List<String> ids(int seed) => [
      for (final (_, l) in _run(
        NudgeInputs(seed: seed),
        DayPart.morning,
        days: 30,
      ))
        l.id,
    ];
    expect(ids(1), isNot(ids(2)));
  });

  test('planned notes end with the last line and slow down quietly', () {
    final now = DateTime(2026, 11, 7, 9, 30);
    const settings = ReminderSettings(enabled: true);
    final plan = planReminders(settings, now, englishL10n);
    final last = nudgeCatalog.where((n) => n.group == NudgeGroup.last);
    final quiet = nudgeCatalog.where((n) => n.group == NudgeGroup.quiet);
    String words(Nudge n, DateTime at) => nudgeText(n, at, englishL10n);
    expect(last.map((n) => words(n, plan.last.at)), contains(plan.last.body));
    for (final r in plan.take(reminderDailyDays)) {
      expect(quiet.map((n) => words(n, r.at)), isNot(contains(r.body)));
      expect(last.map((n) => words(n, r.at)), isNot(contains(r.body)));
    }
    final weekly = plan.skip(reminderDailyDays).toList()..removeLast();
    expect(weekly, isNotEmpty);
    for (final r in weekly) {
      expect(quiet.map((n) => words(n, r.at)), contains(r.body));
    }
    expect(plan.map((r) => r.body).toSet(), hasLength(plan.length));
  });

  test('the device seed is made once and kept', () async {
    SharedPreferences.setMockInitialValues({});
    final first = await const NudgeInputsStore().load();
    final second = await const NudgeInputsStore().load();
    expect(second.seed, first.seed);
    expect(first.hasOwnPhotos, isFalse);
  });

  test('own photos count from two; a failing count changes nothing', () async {
    SharedPreferences.setMockInitialValues({'nudge_seed': 5});
    Future<int> one() async => 1;
    Future<int> two() async => 2;
    Future<int> broken() async => throw StateError('unreadable');
    await NudgeInputsStore(countOwnPhotos: one).refreshOwnPhotos();
    expect((await const NudgeInputsStore().load()).hasOwnPhotos, isFalse);
    await NudgeInputsStore(countOwnPhotos: two).refreshOwnPhotos();
    final inputs = await const NudgeInputsStore().load();
    expect(inputs.hasOwnPhotos, isTrue);
    expect(inputs.seed, 5);
    await NudgeInputsStore(countOwnPhotos: broken).refreshOwnPhotos();
    expect((await const NudgeInputsStore().load()).hasOwnPhotos, isTrue);
  });

  test('Home shows a line for the day', () {
    final line = homeNudge(
      DateTime(2026, 11, 8, 15),
      englishL10n,
      const NudgeInputs(seed: 3),
    );
    expect(line, isNotEmpty);
    expect(line, isNot(contains('{')));
  });
}
