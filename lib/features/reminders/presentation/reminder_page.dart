import 'dart:async';

import 'package:flutter/material.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/reminders/data/reminder_settings.dart';
import 'package:golden_moments/l10n/l10n.dart';
import 'package:golden_moments/shared/native/gm_native.dart';

/// Optional, caregiver-chosen reminders (GM-038, approved 2026-10-30). Off
/// by default; the system permission question appears only after "Turn on
/// reminder" is tapped. Reminders are scheduled on this device and never
/// count days, streaks or missed sessions.
///
/// The notification text is taken from the app's language when the reminder
/// is scheduled, so it stays in that language until it is next changed here.
class ReminderPage extends StatefulWidget {
  const new({
    this.native = const GmNative(),
    this.store = const ReminderSettingsStore(),
    super.key,
  });

  final GmNative native;
  final ReminderSettingsStore store;

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  /// Short chip text and the full name read aloud, Monday first.
  static Map<int, (String, String)> _dayNames(AppLocalizations l10n) => {
    DateTime.monday: (l10n.reminderDayMondayShort, l10n.reminderDayMonday),
    DateTime.tuesday: (l10n.reminderDayTuesdayShort, l10n.reminderDayTuesday),
    DateTime.wednesday: (
      l10n.reminderDayWednesdayShort,
      l10n.reminderDayWednesday,
    ),
    DateTime.thursday: (
      l10n.reminderDayThursdayShort,
      l10n.reminderDayThursday,
    ),
    DateTime.friday: (l10n.reminderDayFridayShort, l10n.reminderDayFriday),
    DateTime.saturday: (
      l10n.reminderDaySaturdayShort,
      l10n.reminderDaySaturday,
    ),
    DateTime.sunday: (l10n.reminderDaySundayShort, l10n.reminderDaySunday),
  };

  ReminderSettings? _settings;
  _Status? _status;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    ReminderSettings loaded;
    try {
      loaded = await widget.store.load();
    } on Object {
      loaded = const ReminderSettings();
    }
    if (mounted) setState(() => _settings = loaded);
  }

  Future<bool> _schedule(ReminderSettings s, AppLocalizations l10n) =>
      widget.native.scheduleReminders(
        weekdays: s.weekdays,
        hour: s.hour,
        minute: s.minute,
        title: l10n.reminderNotificationTitle,
        body: l10n.reminderNotificationBody,
      );

  /// Saves [next]; when the reminder is on, reschedules it first so the
  /// saved choice always matches what the device will show.
  Future<void> _apply(ReminderSettings next, {_Status? done}) async {
    // Read before any await so the scheduled text matches the screen.
    final l10n = context.l10n;
    setState(() => _busy = true);
    var status = done;
    var saved = next;
    try {
      if (next.enabled && !await _schedule(next, l10n)) {
        status = _Status.couldNotSet;
        saved = _settings!;
      } else {
        await widget.store.save(next);
      }
    } on Object {
      status = _Status.couldNotSave;
      saved = _settings!;
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      _settings = saved;
      _status = status;
    });
  }

  Future<void> _turnOn() async {
    setState(() => _busy = true);
    var permission = await widget.native.reminderPermission();
    if (permission == ReminderPermission.notDetermined) {
      permission = await widget.native.requestReminderPermission();
    }
    if (!mounted) return;
    if (permission != ReminderPermission.granted) {
      setState(() {
        _busy = false;
        _status = _Status.notificationsOff;
      });
      return;
    }
    // The summary that appears is the announcement.
    await _apply(_settings!.copyWith(enabled: true));
  }

  Future<void> _turnOff() async {
    setState(() => _busy = true);
    await widget.native.cancelReminders();
    if (!mounted) return;
    await _apply(_settings!.copyWith(enabled: false), done: _Status.off);
  }

  void _toggleDay(int day) {
    final days = {..._settings!.weekdays};
    if (!days.remove(day)) days.add(day);
    // At least one day stays chosen; turning the reminder off is separate.
    if (days.isEmpty) return;
    unawaited(_apply(_settings!.copyWith(weekdays: days)));
  }

  Future<void> _chooseTime() async {
    final s = _settings!;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: s.hour, minute: s.minute),
      initialEntryMode: TimePickerEntryMode.input,
    );
    if (picked == null || !mounted) return;
    await _apply(s.copyWith(hour: picked.hour, minute: picked.minute));
  }

  String _summary(ReminderSettings s, AppLocalizations l10n) {
    final names = _dayNames(l10n);
    final days = s.weekdays.length == 7
        ? l10n.reminderEveryDay
        : ([...s.weekdays]..sort())
              .map((d) => names[d]!.$2)
              .join(l10n.reminderDayListSeparator);
    final time = MaterialLocalizations.of(context)
        .formatTimeOfDay(TimeOfDay(hour: s.hour, minute: s.minute));
    return l10n.reminderSummary(days, time);
  }

  String _statusText(_Status status, AppLocalizations l10n) => switch (status) {
    _Status.couldNotSet => l10n.reminderCouldNotSet,
    _Status.couldNotSave => l10n.reminderCouldNotSave,
    _Status.notificationsOff => l10n.reminderNotificationsOff,
    _Status.off => l10n.reminderIsOff,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final s = _settings;
    Widget heading(String text) => Padding(
      padding: const EdgeInsets.only(top: gmSpaceLg, bottom: gmSpaceSm),
      child: Semantics(
        header: true,
        child: Text(text, style: theme.textTheme.titleMedium),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: gmToolbarHeight(context),
        title: GmTitle(l10n.commonGentleReminder),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: gmContentMaxWidth),
            child: s == null
                ? const SizedBox.shrink()
                : ListView(
                    padding: const EdgeInsets.all(gmSpaceLg),
                    children: [
                      Text(
                        l10n.reminderIntro,
                        style: theme.textTheme.bodyLarge,
                      ),
                      heading(l10n.reminderDays),
                      Wrap(
                        spacing: gmSpaceSm,
                        runSpacing: gmSpaceSm,
                        children: [
                          for (final MapEntry(key: day, value: names)
                              in _dayNames(l10n).entries)
                            Semantics(
                              label: names.$2,
                              excludeSemantics: true,
                              selected: s.weekdays.contains(day),
                              button: true,
                              child: FilterChip(
                                label: Text(names.$1),
                                selected: s.weekdays.contains(day),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.padded,
                                onSelected: _busy
                                    ? null
                                    : (_) => _toggleDay(day),
                              ),
                            ),
                        ],
                      ),
                      heading(l10n.reminderTime),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: OutlinedButton.icon(
                          onPressed: _busy ? null : _chooseTime,
                          icon: const Icon(Icons.schedule),
                          label: Text(
                            MaterialLocalizations.of(context).formatTimeOfDay(
                              TimeOfDay(hour: s.hour, minute: s.minute),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: gmSpaceXl),
                      if (s.enabled) ...[
                        Semantics(
                          liveRegion: true,
                          child: Text(
                            l10n.reminderIsOn(_summary(s, l10n)),
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                        const SizedBox(height: gmSpaceMd),
                        OutlinedButton.icon(
                          onPressed: _busy ? null : _turnOff,
                          icon: const Icon(Icons.notifications_off_outlined),
                          label: Text(l10n.reminderTurnOff),
                        ),
                      ] else
                        FilledButton.icon(
                          onPressed: _busy ? null : _turnOn,
                          icon: const Icon(Icons.notifications_none),
                          label: Text(l10n.reminderTurnOn),
                        ),
                      if (_status != null) ...[
                        const SizedBox(height: gmSpaceMd),
                        Semantics(
                          liveRegion: true,
                          child: Text(
                            _statusText(_status!, l10n),
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                      ],
                      const SizedBox(height: gmSpaceMd),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(l10n.commonDoneForNow),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// What the status line under the buttons reports, turned into words in the
/// app's language only when it is shown.
enum _Status { couldNotSet, couldNotSave, notificationsOff, off }
