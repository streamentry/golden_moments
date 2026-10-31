import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// An optional, caregiver-chosen reminder (GM-038). Off until someone turns
/// it on. It never counts days, streaks or missed sessions. The notification
/// wording lives in the app's translations (reminderNotificationTitle/Body)
/// and is passed in when the reminder is scheduled.
class ReminderSettings extends Equatable {
  const new({
    this.enabled = false,
    this.weekdays = allWeekdays,
    this.hour = 10,
    this.minute = 0,
  });

  /// [DateTime.monday] to [DateTime.sunday].
  static const allWeekdays = {1, 2, 3, 4, 5, 6, 7};

  final bool enabled;
  final Set<int> weekdays;
  final int hour;
  final int minute;

  ReminderSettings copyWith({
    bool? enabled,
    Set<int>? weekdays,
    int? hour,
    int? minute,
  }) => ReminderSettings(
    enabled: enabled ?? this.enabled,
    weekdays: weekdays ?? this.weekdays,
    hour: hour ?? this.hour,
    minute: minute ?? this.minute,
  );

  @override
  List<Object?> get props => [
    enabled,
    [...weekdays]..sort(),
    hour,
    minute,
  ];
}

/// Saves [ReminderSettings] on this device only.
class ReminderSettingsStore {
  const new();

  static const _enabledKey = 'reminder_enabled';
  static const _weekdaysKey = 'reminder_weekdays';
  static const _hourKey = 'reminder_hour';
  static const _minuteKey = 'reminder_minute';

  /// Anything stored out of range falls back to the default for that field,
  /// so a damaged value can never schedule a strange reminder.
  Future<ReminderSettings> load() async {
    const fallback = ReminderSettings();
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt(_hourKey);
    final minute = prefs.getInt(_minuteKey);
    final days = (prefs.getStringList(_weekdaysKey) ?? const [])
        .map(int.tryParse)
        .whereType<int>()
        .where((d) => d >= DateTime.monday && d <= DateTime.sunday)
        .toSet();
    return ReminderSettings(
      enabled: prefs.getBool(_enabledKey) ?? false,
      weekdays: days.isEmpty ? fallback.weekdays : days,
      hour: hour != null && hour >= 0 && hour < 24 ? hour : fallback.hour,
      minute: minute != null && minute >= 0 && minute < 60
          ? minute
          : fallback.minute,
    );
  }

  Future<void> save(ReminderSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, settings.enabled);
    await prefs.setStringList(
      _weekdaysKey,
      ([...settings.weekdays]..sort()).map((d) => '$d').toList(),
    );
    await prefs.setInt(_hourKey, settings.hour);
    await prefs.setInt(_minuteKey, settings.minute);
  }
}
