import 'dart:async';

import 'package:flutter/material.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/reminders/data/reminder_settings.dart';
import 'package:golden_moments/shared/native/gm_native.dart';

/// Optional, caregiver-chosen reminders (GM-038, approved 2026-10-30). Off
/// by default; the system permission question appears only after "Turn on
/// reminder" is tapped. Reminders are scheduled on this device and never
/// count days, streaks or missed sessions.
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
  static const Map<int, (String, String)> _dayNames = {
    DateTime.monday: ('Mon', 'Monday'),
    DateTime.tuesday: ('Tue', 'Tuesday'),
    DateTime.wednesday: ('Wed', 'Wednesday'),
    DateTime.thursday: ('Thu', 'Thursday'),
    DateTime.friday: ('Fri', 'Friday'),
    DateTime.saturday: ('Sat', 'Saturday'),
    DateTime.sunday: ('Sun', 'Sunday'),
  };

  ReminderSettings? _settings;
  String? _status;
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

  Future<bool> _schedule(ReminderSettings s) => widget.native.scheduleReminders(
    weekdays: s.weekdays,
    hour: s.hour,
    minute: s.minute,
    title: ReminderSettings.title,
    body: ReminderSettings.body,
  );

  /// Saves [next]; when the reminder is on, reschedules it first so the
  /// saved choice always matches what the device will show.
  Future<void> _apply(ReminderSettings next, {String? done}) async {
    setState(() => _busy = true);
    var status = done;
    var saved = next;
    try {
      if (next.enabled && !await _schedule(next)) {
        status = 'The reminder could not be set. Nothing was changed.';
        saved = _settings!;
      } else {
        await widget.store.save(next);
      }
    } on Object {
      status = 'The reminder could not be saved. Please try again.';
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
        _status =
            'Notifications are off for Golden Moments. You can allow them '
            'in the Settings app, under Notifications, and try again.';
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
    await _apply(_settings!.copyWith(enabled: false), done: 'Reminder is off.');
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

  String _summary(ReminderSettings s) {
    final days = s.weekdays.length == 7
        ? 'Every day'
        : ([...s.weekdays]..sort()).map((d) => _dayNames[d]!.$2).join(', ');
    final time = MaterialLocalizations.of(context)
        .formatTimeOfDay(TimeOfDay(hour: s.hour, minute: s.minute));
    return '$days at $time';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
        title: const GmTitle('Gentle reminder'),
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
                        'A quiet note on this device at a time you choose, '
                        'as a nudge to share some pictures. It never counts '
                        'days or mentions a missed one. You can turn it off '
                        'at any time.',
                        style: theme.textTheme.bodyLarge,
                      ),
                      heading('Days'),
                      Wrap(
                        spacing: gmSpaceSm,
                        runSpacing: gmSpaceSm,
                        children: [
                          for (final MapEntry(key: day, value: names)
                              in _dayNames.entries)
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
                      heading('Time'),
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
                            'Reminder is on: ${_summary(s)}.',
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                        const SizedBox(height: gmSpaceMd),
                        OutlinedButton.icon(
                          onPressed: _busy ? null : _turnOff,
                          icon: const Icon(Icons.notifications_off_outlined),
                          label: const Text('Turn off reminder'),
                        ),
                      ] else
                        FilledButton.icon(
                          onPressed: _busy ? null : _turnOn,
                          icon: const Icon(Icons.notifications_none),
                          label: const Text('Turn on reminder'),
                        ),
                      if (_status != null) ...[
                        const SizedBox(height: gmSpaceMd),
                        Semantics(
                          liveRegion: true,
                          child: Text(
                            _status!,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                      ],
                      const SizedBox(height: gmSpaceMd),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Done for now'),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
