import 'package:golden_moments/features/reminders/data/reminder_plan.dart';
import 'package:golden_moments/features/reminders/data/reminder_settings.dart';
import 'package:golden_moments/l10n/l10n.dart';
import 'package:golden_moments/shared/native/gm_native.dart';

/// Plans the reminders afresh whenever the app is opened (see
/// [planReminders]): in the app's current language, with nothing for today,
/// and slowing down then stopping if the app goes unused. It never asks for
/// permission; only the reminder screen does that.
class ReminderScheduler {
  const new({
    this.native = const GmNative(),
    this.store = const ReminderSettingsStore(),
    this.clock = DateTime.now,
  });

  final GmNative native;
  final ReminderSettingsStore store;
  final DateTime Function() clock;

  /// Schedules [settings] (or the saved settings) from now. Returns whether
  /// reminders are scheduled; any failure leaves the app as it was.
  Future<bool> refresh(
    AppLocalizations l10n, {
    ReminderSettings? settings,
  }) async {
    if (!native.isSupported) return false;
    final ReminderSettings current;
    try {
      current = settings ?? await store.load();
    } on Object {
      return false;
    }
    if (!current.enabled) return false;
    if (await native.reminderPermission() != ReminderPermission.granted) {
      return false;
    }
    return await native.scheduleDatedReminders(
      planReminders(current, clock(), l10n),
    );
  }
}
