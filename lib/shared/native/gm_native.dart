import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Whether notifications may be shown, as the system reports it.
enum ReminderPermission { granted, denied, notDetermined }

/// The few system features Golden Moments uses through its own iOS code
/// (`ios/Runner/AppDelegate.swift`): Apple's rating prompt and local,
/// on-device reminders. Nothing here uses the network or collects data.
///
/// Other platforms report [isSupported] as false and every call is a no-op,
/// so screens can hide what a platform does not offer.
class GmNative {
  const new({
    this.channel = const MethodChannel('golden_moments/native'),
    this.supportedOverride,
  });

  final MethodChannel channel;

  /// Replaces the platform check, for tests.
  final bool? supportedOverride;

  bool get isSupported =>
      supportedOverride ??
      (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS);

  /// Asks the system to show its rating prompt. The system decides whether
  /// it appears (Apple shows it at most three times a year), so this never
  /// reports an outcome. Failures are ignored: rating is never required.
  Future<void> requestReview() async {
    if (!isSupported) return;
    try {
      await channel.invokeMethod<void>('requestReview');
    } on Object {
      // Never let an optional prompt interrupt the app.
    }
  }

  Future<ReminderPermission> reminderPermission() =>
      _permission('reminderPermission');

  /// Shows the system permission question if it has not been answered.
  Future<ReminderPermission> requestReminderPermission() =>
      _permission('requestReminderPermission');

  Future<ReminderPermission> _permission(String method) async {
    if (!isSupported) return ReminderPermission.denied;
    try {
      final status = await channel.invokeMethod<String>(method);
      return switch (status) {
        'granted' => ReminderPermission.granted,
        'notDetermined' => ReminderPermission.notDetermined,
        _ => ReminderPermission.denied,
      };
    } on Object {
      return ReminderPermission.denied;
    }
  }

  /// Replaces every scheduled reminder with one-off reminders at these local
  /// wall-clock times, each with its own words. Returns false when they
  /// could not all be scheduled.
  Future<bool> scheduleDatedReminders(
    List<({DateTime at, String title, String body})> reminders,
  ) async {
    if (!isSupported) return false;
    try {
      return await channel.invokeMethod<bool>('scheduleDatedReminders', {
            'reminders': [
              for (final r in reminders)
                {
                  'year': r.at.year,
                  'month': r.at.month,
                  'day': r.at.day,
                  'hour': r.at.hour,
                  'minute': r.at.minute,
                  'title': r.title,
                  'body': r.body,
                },
            ],
          }) ??
          false;
    } on Object {
      return false;
    }
  }

  /// True once after a reminder was tapped (also when the tap started the
  /// app), so the app can open that day's activity.
  Future<bool> takeReminderTap() async {
    if (!isSupported) return false;
    try {
      return await channel.invokeMethod<bool>('takeReminderTap') ?? false;
    } on Object {
      return false;
    }
  }

  /// Calls [onTap] when a reminder is tapped while the app is running.
  void listenForReminderTaps(VoidCallback onTap) {
    if (!isSupported) return;
    channel.setMethodCallHandler((call) async {
      if (call.method == 'reminderTapped') onTap();
    });
  }

  Future<void> cancelReminders() async {
    if (!isSupported) return;
    try {
      await channel.invokeMethod<void>('cancelReminders');
    } on Object {
      // Nothing scheduled is the safe outcome either way.
    }
  }
}
