import 'package:flutter/material.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/gentle_activities/models/activity_picture.dart';
import 'package:golden_moments/features/gentle_activities/presentation/gentle_game_page.dart';
import 'package:golden_moments/features/gentle_activities/presentation/photo_together_page.dart';
import 'package:golden_moments/features/wellbeing/data/routines.dart';
import 'package:golden_moments/features/wellbeing/presentation/daily_moment_page.dart';
import 'package:golden_moments/l10n/l10n.dart';

/// Suggested routines for the day, for oneself or for someone one cares for.
/// Choosing a time and a person only changes the suggestions; nothing is saved
/// and nothing is scored.
class ActivityPlannerPage extends StatefulWidget {
  const new({super.key});

  @override
  State<ActivityPlannerPage> createState() => _ActivityPlannerPageState();
}

class _ActivityPlannerPageState extends State<ActivityPlannerPage> {
  PlanTime _time = PlanTime.morning;
  PlanFor _who = PlanFor.me;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final steps = routineFor(_time, _who);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.wellbeingHomePlanner)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: gmContentMaxWidth),
            child: ListView(
              padding: const EdgeInsets.all(gmSpaceLg),
              children: [
                Text(
                  l10n.wellbeingPlannerIntro,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: gmSpaceLg),
                Text(
                  l10n.wellbeingPlannerTime,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: gmSpaceSm),
                SegmentedButton<PlanTime>(
                  style: SegmentedButton.styleFrom(
                    minimumSize: const Size(gmTargetMin, gmTargetMin),
                  ),
                  segments: [
                    ButtonSegment(
                      value: PlanTime.morning,
                      label: Text(l10n.wellbeingPlannerMorning),
                    ),
                    ButtonSegment(
                      value: PlanTime.afternoon,
                      label: Text(l10n.wellbeingPlannerAfternoon),
                    ),
                    ButtonSegment(
                      value: PlanTime.evening,
                      label: Text(l10n.wellbeingPlannerEvening),
                    ),
                  ],
                  selected: {_time},
                  onSelectionChanged: (selection) =>
                      setState(() => _time = selection.single),
                ),
                const SizedBox(height: gmSpaceLg),
                Text(
                  l10n.wellbeingPlannerWhoLabel,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: gmSpaceSm),
                SegmentedButton<PlanFor>(
                  style: SegmentedButton.styleFrom(
                    minimumSize: const Size(gmTargetMin, gmTargetMin),
                  ),
                  segments: [
                    ButtonSegment(
                      value: PlanFor.me,
                      label: Text(l10n.wellbeingPlannerForMe),
                    ),
                    ButtonSegment(
                      value: PlanFor.someoneICare,
                      label: Text(l10n.wellbeingPlannerForCared),
                    ),
                  ],
                  selected: {_who},
                  onSelectionChanged: (selection) =>
                      setState(() => _who = selection.single),
                ),
                const SizedBox(height: gmSpaceXl),
                Text(
                  l10n.wellbeingPlannerRoutine,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: gmSpaceSm),
                for (final item in steps) ...[
                  _StepTile(item: item),
                  const SizedBox(height: gmTileGap),
                ],
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

/// One suggested step. A step that opens a page is a button; a plain
/// suggestion is text with an icon, so it does not look tappable.
class _StepTile extends StatelessWidget {
  const new({required this.item});

  final RoutineItem item;

  String _label(AppLocalizations l10n) => switch (item) {
    RoutineItem.dailyMoment => l10n.wellbeingItemDailyMoment,
    RoutineItem.matchingGame => l10n.wellbeingItemMatchingGame,
    RoutineItem.lookTogether => l10n.wellbeingItemLookTogether,
    RoutineItem.drinkWater => l10n.wellbeingItemDrinkWater,
    RoutineItem.stepOutside => l10n.wellbeingItemStepOutside,
    RoutineItem.teaTogether => l10n.wellbeingItemTeaTogether,
    RoutineItem.callSomeone => l10n.wellbeingItemCallSomeone,
    RoutineItem.dimLights => l10n.wellbeingItemDimLights,
    RoutineItem.planTogether => l10n.wellbeingItemPlanTogether,
    RoutineItem.keepQuiet => l10n.wellbeingItemKeepQuiet,
  };

  Widget _destination() => switch (item) {
    RoutineItem.dailyMoment => const DailyMomentPage(
      pictures: ActivityPicture.samples,
    ),
    RoutineItem.matchingGame => const GentleGamePage(
      pictures: ActivityPicture.samples,
    ),
    _ => const PhotoTogetherPage(pictures: ActivityPicture.samples),
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final label = _label(l10n);
    if (!item.opens) {
      return Container(
        constraints: const BoxConstraints(minHeight: gmTargetPrimary),
        padding: const EdgeInsets.all(gmSpaceMd),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(gmRadiusLg),
        ),
        child: Row(
          children: [
            Icon(
              Icons.lightbulb_outline,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: gmSpaceMd),
            Expanded(child: Text(label, style: theme.textTheme.bodyLarge)),
          ],
        ),
      );
    }
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(gmTargetPrimary),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(
          horizontal: gmSpaceMd,
          vertical: gmSpaceSm,
        ),
      ),
      onPressed: () =>
          Navigator.of(context)
              .push(MaterialPageRoute<void>(builder: (_) => _destination())),
      child: Row(
        children: [
          Expanded(child: Text(label, style: theme.textTheme.bodyLarge)),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}
