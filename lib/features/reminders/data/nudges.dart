import 'dart:async';
import 'dart:math';

import 'package:golden_moments/features/gentle_activities/models/activity_picture.dart';
import 'package:golden_moments/features/todays_activity/data/todays_activity.dart';
import 'package:golden_moments/features/wellbeing/data/daily_moment_pictures.dart';
import 'package:golden_moments/l10n/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The letter groups of `docs/retention/nudges.md`.
enum NudgeGroup {
  /// Names the day's pictures (Daily moment days only).
  today,

  /// A question two people ask each other about what they like.
  question,

  /// Chosen time before noon.
  morning,

  /// Chosen time from noon to 5 pm.
  afternoon,

  /// Chosen time after 5 pm.
  evening,

  /// A line for a day of the week.
  weekday,

  /// The family has added their own photos.
  ownPhotos,

  /// Makes the visit feel small.
  small,

  /// Leave to skip.
  skip,

  /// After two weeks without the app.
  quiet,

  /// The last note before reminders stop.
  last,
}

/// Which note in a planned batch a line is for.
enum NudgeSlot {
  /// A note in the first two weeks.
  daily,

  /// A weekly note after two weeks without the app.
  quiet,

  /// The last note before reminders stop.
  last,
}

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

/// One line: its id (as in the doc), group and words.
class Nudge {
  const new _(this.id, this.group, this._text);

  final String id;
  final NudgeGroup group;
  final String Function(AppLocalizations l10n, NudgeFill fill) _text;

  String text(AppLocalizations l10n, NudgeFill fill) => _text(l10n, fill);
}

/// What a line may name: the day's three pictures and the first of them,
/// both already shown in the app.
typedef NudgeFill = ({String pictures, String picture});

/// Every line, in doc order.
final List<Nudge> nudgeCatalog = [
  Nudge._('T1', NudgeGroup.today, (l, f) => l.nudgeT1(f.pictures)),
  Nudge._('T2', NudgeGroup.today, (l, f) => l.nudgeT2(f.pictures)),
  Nudge._('T3', NudgeGroup.today, (l, f) => l.nudgeT3(f.pictures)),
  Nudge._('T4', NudgeGroup.today, (l, f) => l.nudgeT4(f.picture)),
  Nudge._('T5', NudgeGroup.today, (l, f) => l.nudgeT5(f.picture)),
  Nudge._('T6', NudgeGroup.today, (l, f) => l.nudgeT6(f.picture)),
  Nudge._('Q1', NudgeGroup.question, (l, _) => l.nudgeQ1),
  Nudge._('Q2', NudgeGroup.question, (l, _) => l.nudgeQ2),
  Nudge._('Q3', NudgeGroup.question, (l, _) => l.nudgeQ3),
  Nudge._('Q4', NudgeGroup.question, (l, _) => l.nudgeQ4),
  Nudge._('Q5', NudgeGroup.question, (l, _) => l.nudgeQ5),
  Nudge._('Q6', NudgeGroup.question, (l, _) => l.nudgeQ6),
  Nudge._('Q7', NudgeGroup.question, (l, _) => l.nudgeQ7),
  Nudge._('Q8', NudgeGroup.question, (l, _) => l.nudgeQ8),
  Nudge._('Q9', NudgeGroup.question, (l, _) => l.nudgeQ9),
  Nudge._('Q10', NudgeGroup.question, (l, _) => l.nudgeQ10),
  Nudge._('M1', NudgeGroup.morning, (l, _) => l.nudgeM1),
  Nudge._('M2', NudgeGroup.morning, (l, _) => l.nudgeM2),
  Nudge._('M3', NudgeGroup.morning, (l, _) => l.nudgeM3),
  Nudge._('M4', NudgeGroup.morning, (l, _) => l.nudgeM4),
  Nudge._('N1', NudgeGroup.afternoon, (l, _) => l.nudgeN1),
  Nudge._('N2', NudgeGroup.afternoon, (l, _) => l.nudgeN2),
  Nudge._('N3', NudgeGroup.afternoon, (l, _) => l.nudgeN3),
  Nudge._('N4', NudgeGroup.afternoon, (l, _) => l.nudgeN4),
  Nudge._('V1', NudgeGroup.evening, (l, _) => l.nudgeV1),
  Nudge._('V2', NudgeGroup.evening, (l, _) => l.nudgeV2),
  Nudge._('V3', NudgeGroup.evening, (l, _) => l.nudgeV3),
  Nudge._('V4', NudgeGroup.evening, (l, _) => l.nudgeV4),
  Nudge._('W1', NudgeGroup.weekday, (l, _) => l.nudgeW1),
  Nudge._('W2', NudgeGroup.weekday, (l, _) => l.nudgeW2),
  Nudge._('W3', NudgeGroup.weekday, (l, _) => l.nudgeW3),
  Nudge._('W4', NudgeGroup.weekday, (l, _) => l.nudgeW4),
  Nudge._('P1', NudgeGroup.ownPhotos, (l, _) => l.nudgeP1),
  Nudge._('P2', NudgeGroup.ownPhotos, (l, _) => l.nudgeP2),
  Nudge._(
    'P3',
    NudgeGroup.ownPhotos,
    (l, _) => l.nudgeP3(l.commonYourFamilyPhotos),
  ),
  Nudge._('P4', NudgeGroup.ownPhotos, (l, _) => l.nudgeP4),
  Nudge._('S1', NudgeGroup.small, (l, _) => l.nudgeS1),
  Nudge._('S2', NudgeGroup.small, (l, _) => l.nudgeS2),
  Nudge._('S3', NudgeGroup.small, (l, _) => l.nudgeS3),
  Nudge._('S4', NudgeGroup.small, (l, _) => l.nudgeS4),
  Nudge._('S5', NudgeGroup.small, (l, _) => l.nudgeS5),
  Nudge._('K1', NudgeGroup.skip, (l, _) => l.nudgeK1),
  Nudge._('K2', NudgeGroup.skip, (l, _) => l.nudgeK2),
  Nudge._('K3', NudgeGroup.skip, (l, _) => l.nudgeK3),
  Nudge._('K4', NudgeGroup.skip, (l, _) => l.nudgeK4),
  Nudge._('R1', NudgeGroup.quiet, (l, _) => l.nudgeR1),
  Nudge._('R2', NudgeGroup.quiet, (l, _) => l.nudgeR2),
  Nudge._('R3', NudgeGroup.quiet, (l, _) => l.nudgeR3),
  Nudge._('L1', NudgeGroup.last, (l, _) => l.nudgeL1),
  Nudge._('L2', NudgeGroup.last, (l, _) => l.nudgeL2),
];

List<Nudge> _group(NudgeGroup g) =>
    nudgeCatalog.where((n) => n.group == g).toList();

Nudge _byId(String id) => nudgeCatalog.firstWhere((n) => n.id == id);

/// No line comes back inside this many days.
const nudgeNoRepeatDays = 21;

/// Days are counted from here, so every date has a fixed number.
final _epoch = DateTime.utc(2024);

int _dayNumber(DateTime d) =>
    DateTime.utc(d.year, d.month, d.day).difference(_epoch).inDays;

DateTime _dateOf(int n) => _epoch.add(Duration(days: n));

/// What the device knows that changes which lines are true. Nothing here
/// describes a person: a random number and whether own photos exist.
class NudgeInputs {
  const new({this.seed = 0, this.hasOwnPhotos = false});

  /// Saved once per device so two homes see different orders.
  final int seed;

  /// At least two family photos are in the app.
  final bool hasOwnPhotos;
}

/// Picks the line for each day. Deterministic for the same inputs, so the
/// line a date gets does not change when reminders are planned again.
///
/// It walks every day from a fixed start, remembering when each line was
/// last used, so a line never returns within [nudgeNoRepeatDays] days:
/// - every 7th day is a skip line (four of them, so each returns after 28);
/// - every 3rd day may be a line for that day: today's pictures on a Daily
///   moment day, the weekday line, or own photos, whichever has not been
///   used recently;
/// - otherwise the next line of a seeded order that alternates questions
///   with the time-of-day and small lines.
class NudgePicker {
  new({required this.inputs, required DayPart part, this.forHome = false})
    : _general = _generalOrder(inputs.seed, part);

  final NudgeInputs inputs;

  /// Home has no skip days: a line there sits next to a Begin button.
  final bool forHome;
  final List<Nudge> _general;

  final Map<String, int> _lastUsed = {};
  final Map<int, Nudge> _byDay = {};
  int _next = 0;
  int _day = -1;
  NudgeGroup? _previous;

  /// Questions at even places, the other general lines between them.
  static List<Nudge> _generalOrder(int seed, DayPart part) {
    final random = Random(seed);
    final questions = _group(NudgeGroup.question)..shuffle(random);
    final timed = switch (part) {
      DayPart.morning => NudgeGroup.morning,
      DayPart.afternoon => NudgeGroup.afternoon,
      DayPart.evening => NudgeGroup.evening,
    };
    final others = [..._group(timed), ..._group(NudgeGroup.small)]
      ..shuffle(random);
    return [
      for (var i = 0; i < max(questions.length, others.length); i++) ...[
        if (i < questions.length) questions[i],
        if (i < others.length) others[i],
      ],
    ];
  }

  bool _fresh(Nudge n, int day) {
    final used = _lastUsed[n.id];
    return used == null || day - used >= nudgeNoRepeatDays;
  }

  List<Nudge> _special(int day, List<ActivityPicture> pictures) {
    final date = _dateOf(day);
    final weekday = switch (date.weekday) {
      DateTime.saturday => ['W1'],
      DateTime.sunday => (day ~/ 7).isEven ? ['W2', 'W3'] : ['W3', 'W2'],
      DateTime.monday => ['W4'],
      _ => const <String>[],
    };
    final daily =
        TodaysActivity.forDay(date) == TodaysActivity.dailyMoment &&
        pictures.isNotEmpty;
    final groups = [
      if (daily) _rotate(_group(NudgeGroup.today), day ~/ 3),
      [for (final id in weekday) _byId(id)],
      if (inputs.hasOwnPhotos) _rotate(_group(NudgeGroup.ownPhotos), day ~/ 3),
    ].where((g) => g.isNotEmpty).toList();
    if (groups.isEmpty) return const [];
    // Take turns between the groups that apply, so none crowds the others.
    final first = (day ~/ 3) % groups.length;
    return [
      ...groups.skip(first),
      ...groups.take(first),
    ].expand((g) => g).toList();
  }

  static List<Nudge> _rotate(List<Nudge> list, int by) {
    final k = by % list.length;
    return [...list.skip(k), ...list.take(k)];
  }

  Nudge _choose(int day, List<ActivityPicture> pictures) {
    if (!forHome && day % 7 == 5) {
      final skip = _group(NudgeGroup.skip);
      return skip[(day ~/ 7) % skip.length];
    }
    if (day % 3 == 0) {
      for (final n in _special(day, pictures)) {
        if (_fresh(n, day)) return n;
      }
    }
    final count = _general.length;
    Nudge? fallback;
    for (var i = 0; i < count; i++) {
      final n = _general[(_next + i) % count];
      if (!_fresh(n, day)) continue;
      fallback ??= n;
      if (n.group != _previous) {
        _next = (_next + i + 1) % count;
        return n;
      }
    }
    if (fallback != null) {
      _next = (_general.indexOf(fallback) + 1) % count;
      return fallback;
    }
    // Every general line was used inside the window: take the oldest.
    final oldest = [..._general]
      ..sort((a, b) => _lastUsed[a.id]!.compareTo(_lastUsed[b.id]!));
    return oldest.first;
  }

  /// The line for [date] as a note in [slot]. Every picker starts from the
  /// same fixed day, so a date gets the same line however often reminders
  /// are planned.
  Nudge lineFor(
    DateTime date, {
    List<ActivityPicture> pictures = const [],
    NudgeSlot slot = NudgeSlot.daily,
  }) {
    // A device clock set before the start still gets a line.
    final target = max(0, _dayNumber(date));
    if (_day < 0) _day = 0;
    while (_day <= target) {
      final n = _choose(_day, pictures);
      _lastUsed[n.id] = _day;
      _byDay[_day] = n;
      _previous = n.group;
      _day++;
    }
    final chosen = _byDay[target]!;
    return switch (slot) {
      NudgeSlot.daily => chosen,
      NudgeSlot.quiet => _rotate(_group(NudgeGroup.quiet), target ~/ 7).first,
      NudgeSlot.last => _group(NudgeGroup.last)[target % 2],
    };
  }
}

/// The words of [line] for [at], with the day's picture names filled in.
String nudgeText(
  Nudge line,
  DateTime at,
  AppLocalizations l10n, {
  List<ActivityPicture> pictures = ActivityPicture.samples,
}) {
  final shown = dailyMomentPictures(at, pictures);
  final names = [for (final p in shown) p.localizedLabel(l10n)];
  return line.text(l10n, (
    pictures: names.join(l10n.reminderDayListSeparator),
    picture: names.isEmpty ? '' : names.first,
  ));
}

/// The line Home shows under Today's activity for [now].
String homeNudge(
  DateTime now,
  AppLocalizations l10n,
  NudgeInputs inputs, {
  List<ActivityPicture> pictures = ActivityPicture.samples,
}) {
  final picker = NudgePicker(
    inputs: inputs,
    part: DayPart.of(now.hour),
    forHome: true,
  );
  return nudgeText(
    picker.lineFor(now, pictures: pictures),
    now,
    l10n,
    pictures: pictures,
  );
}

/// Loads [NudgeInputs] on this device. The seed is a random number made on
/// first use and kept in app preferences; it says nothing about anyone.
///
/// Whether own photos exist is read from a saved yes/no, so planning never
/// waits on the photo folder; the count is refreshed in the background and
/// takes effect the next time reminders are planned.
class NudgeInputsStore {
  const new({this.countOwnPhotos});

  static const _seedKey = 'nudge_seed';
  static const _photosKey = 'nudge_own_photos';

  /// How many family photos the app holds.
  final Future<int> Function()? countOwnPhotos;

  Future<NudgeInputs> load() async {
    var seed = 0;
    var photos = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getInt(_seedKey);
      if (saved != null) {
        seed = saved;
      } else {
        seed = Random.secure().nextInt(1 << 31);
        await prefs.setInt(_seedKey, seed);
      }
      photos = prefs.getBool(_photosKey) ?? false;
    } on Object {
      // A fixed order and no photo lines are fine when preferences fail.
    }
    unawaited(refreshOwnPhotos());
    return NudgeInputs(seed: seed, hasOwnPhotos: photos);
  }

  /// Counts the family photos and saves whether there are at least two.
  /// Any failure leaves the saved answer as it was.
  Future<void> refreshOwnPhotos() async {
    final count = countOwnPhotos;
    if (count == null) return;
    try {
      final photos = await count() >= 2;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_photosKey, photos);
    } on Object {
      // Keep the last answer.
    }
  }
}
