import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Shows the Today's activity card on Home. Build with
/// `--dart-define=GM_TODAYS_ACTIVITY=false` to remove it again without a code
/// change (docs/plan/measurement.md › Reversibility).
const todaysActivityEnabled = bool.fromEnvironment(
  'GM_TODAYS_ACTIVITY',
  defaultValue: true,
);

/// One existing activity suggested for the day on Home.
///
/// The suggestion is a plain calendar rotation, the same for everyone on the
/// same day. It is not personalised and says nothing about the person: no
/// history, score or ability is read. The gentle game is not in the rotation
/// because it is already Home's main button.
enum TodaysActivity {
  dailyMoment('daily_moment'),
  lookTogether('look_together');

  new(this.id);

  /// Stable stored identifier; never rename.
  final String id;

  static TodaysActivity? fromId(String? id) {
    for (final activity in values) {
      if (activity.id == id) return activity;
    }
    return null;
  }

  /// The default for [day]'s calendar date in the device's own time zone.
  /// Only year, month and day are used, so clock changes cannot skip a day.
  static TodaysActivity forDay(DateTime day) {
    final days = DateTime.utc(
      day.year,
      day.month,
      day.day,
    ).difference(DateTime.utc(2024)).inDays;
    return values[days % values.length];
  }

  TodaysActivity get next => values[(index + 1) % values.length];
}

/// Remembers, on this device only, a different choice made for today.
///
/// Nothing is stored until someone chooses another activity. A saved choice
/// from an earlier day, or one that cannot be read, is ignored, so the card
/// always falls back to the day's default. Storage failures never block Home.
class TodaysActivityStore {
  const new();

  static const dayKey = 'todays_activity.day';
  static const idKey = 'todays_activity.id';

  Future<TodaysActivity> load(DateTime now) async {
    final fallback = TodaysActivity.forDay(now);
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getString(dayKey) != _key(now)) return fallback;
      return TodaysActivity.fromId(prefs.getString(idKey)) ?? fallback;
    } on Exception catch (error) {
      debugPrint("Today's activity could not be read: ${error.runtimeType}");
      return fallback;
    }
  }

  /// Moves today's suggestion to the next activity and remembers it for the
  /// rest of the day. Returns the new suggestion even if saving fails.
  Future<TodaysActivity> chooseAnother(DateTime now) async {
    final next = (await load(now)).next;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(dayKey, _key(now));
      await prefs.setString(idKey, next.id);
    } on Exception catch (error) {
      debugPrint("Today's activity could not be saved: ${error.runtimeType}");
    }
    return next;
  }

  static String _key(DateTime day) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${day.year.toString().padLeft(4, '0')}-'
        '${two(day.month)}-${two(day.day)}';
  }
}
