import 'dart:async';

import 'package:flutter/material.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/todays_activity/data/todays_activity.dart';
import 'package:golden_moments/l10n/l10n.dart';

/// Home's answer to "what could we do today?": one existing activity, a
/// Begin button and a quiet way to pick the other one instead.
///
/// It shows no count, streak, date or missed day, and nothing changes when a
/// day is skipped. Begin is outlined: Home keeps its one filled button.
class TodaysActivityCard extends StatefulWidget {
  const new({
    required this.onBegin,
    this.store = const TodaysActivityStore(),
    this.clock = DateTime.now,
    super.key,
  });

  final void Function(TodaysActivity activity) onBegin;
  final TodaysActivityStore store;
  final DateTime Function() clock;

  @override
  State<TodaysActivityCard> createState() => _TodaysActivityCardState();
}

class _TodaysActivityCardState extends State<TodaysActivityCard> {
  late TodaysActivity _activity = TodaysActivity.forDay(widget.clock());
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final saved = await widget.store.load(widget.clock());
    if (mounted) setState(() => _activity = saved);
  }

  Future<void> _another() async {
    setState(() => _busy = true);
    final next = await widget.store.chooseAnother(widget.clock());
    if (!mounted) return;
    setState(() {
      _activity = next;
      _busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = context.l10n;
    final (name, hint, icon) = switch (_activity) {
      TodaysActivity.dailyMoment => (
        l10n.wellbeingHomeDailyMoment,
        l10n.todaysActivityDailyMomentHint,
        Icons.today_outlined,
      ),
      TodaysActivity.lookTogether => (
        l10n.commonLookTogether,
        l10n.todaysActivityLookTogetherHint,
        Icons.chat_bubble_outline,
      ),
    };
    return Semantics(
      container: true,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: scheme.surface,
          shape: gmTileShape(scheme),
        ),
        child: Padding(
          padding: const EdgeInsets.all(gmSpaceMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(
                  l10n.todaysActivityHeading,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: gmSpaceSm),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExcludeSemantics(
                    child: Icon(icon, size: 32, color: scheme.primary),
                  ),
                  const SizedBox(width: gmSpaceSm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: theme.textTheme.headlineSmall),
                        const SizedBox(height: gmSpaceXs),
                        Text(hint, style: theme.textTheme.bodyLarge),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: gmSpaceMd),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(gmTargetPrimary),
                ),
                onPressed: () => widget.onBegin(_activity),
                child: Text(
                  l10n.todaysActivityBegin,
                  semanticsLabel: '${l10n.todaysActivityBegin}: $name',
                ),
              ),
              const SizedBox(height: gmSpaceXs),
              TextButton(
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(gmTargetMin),
                ),
                onPressed: _busy ? null : _another,
                child: Text(l10n.todaysActivityAnother),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
