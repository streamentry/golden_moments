import 'dart:async';

import 'package:flutter/material.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/wellbeing/data/moment_history.dart';
import 'package:golden_moments/l10n/l10n.dart';

/// My progress: the days a Daily moment was finished, newest first, kept on
/// this phone. It shows dates only. There is no count, score, streak or list
/// of missed days, and clearing the list asks first.
class ProgressPage extends StatefulWidget {
  const new({
    this.store = const MomentHistoryStore(),
    this.clock = DateTime.now,
    super.key,
  });

  final MomentHistoryStore store;
  final DateTime Function() clock;

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  MomentHistory? _history;
  bool _clearedNow = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final history = await widget.store.load();
    if (!mounted) return;
    setState(() => _history = history);
  }

  Future<void> _confirmClear() async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.wellbeingProgressClearTitle),
        content: Text(l10n.wellbeingProgressClearBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.wellbeingProgressClear),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await widget.store.clear();
    if (!mounted) return;
    setState(() {
      _history = const MomentHistory.empty();
      _clearedNow = true;
    });
  }

  /// Newest first. Keys that are not real dates are skipped, never shown.
  List<DateTime> _days(Set<String> keys) {
    final days = <DateTime>[];
    for (final key in keys) {
      final parts = key.split('-');
      if (parts.length != 3) continue;
      final y = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      final d = int.tryParse(parts[2]);
      if (y == null || m == null || d == null) continue;
      final day = DateTime(y, m, d);
      if (day.year == y && day.month == m && day.day == d) days.add(day);
    }
    days.sort((a, b) => b.compareTo(a));
    return days;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final history = _history;
    final materials = MaterialLocalizations.of(context);

    final body = switch (history) {
      null => const Center(child: CircularProgressIndicator()),
      MomentHistory(readable: false) => Text(
        l10n.wellbeingProgressUnreadable,
        style: theme.textTheme.bodyLarge,
      ),
      _ when _days(history.days).isEmpty => Text(
        _clearedNow
            ? l10n.wellbeingProgressCleared
            : l10n.wellbeingProgressEmpty,
        style: theme.textTheme.bodyLarge,
      ),
      _ => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final day in _days(history.days))
            Container(
              margin: const EdgeInsets.only(bottom: gmTileGap),
              constraints: const BoxConstraints(minHeight: gmTargetPrimary),
              padding: const EdgeInsets.symmetric(
                horizontal: gmSpaceMd,
                vertical: gmSpaceSm,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(gmRadiusLg),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: gmSpaceMd),
                  Expanded(
                    child: Text(
                      materials.formatFullDate(day),
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    };

    return Scaffold(
      appBar: AppBar(title: Text(l10n.wellbeingHomeProgress)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: gmContentMaxWidth),
            child: ListView(
              padding: const EdgeInsets.all(gmSpaceLg),
              children: [
                Text(
                  l10n.wellbeingProgressIntro,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: gmSpaceLg),
                body,
                const SizedBox(height: gmSpaceLg),
                // Also shown for an unreadable record, so the person can
                // clear it on purpose.
                if (history != null &&
                    (history.days.isNotEmpty || !history.readable))
                  Align(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        minimumSize: const Size(gmTargetMin, gmTargetMin),
                      ),
                      onPressed: _confirmClear,
                      child: Text(l10n.wellbeingProgressClear),
                    ),
                  ),
                const SizedBox(height: gmSpaceMd),
                Align(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      minimumSize: const Size(gmTargetMin, gmTargetMin),
                    ),
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: Text(l10n.commonBack),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
