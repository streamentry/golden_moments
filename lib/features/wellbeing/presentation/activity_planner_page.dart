import 'package:flutter/material.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/gentle_activities/models/activity_picture.dart';
import 'package:golden_moments/features/gentle_activities/presentation/gentle_game_page.dart';
import 'package:golden_moments/features/gentle_activities/presentation/photo_together_page.dart';
import 'package:golden_moments/features/wellbeing/data/routines.dart';
import 'package:golden_moments/features/wellbeing/presentation/daily_moment_page.dart';
import 'package:golden_moments/l10n/l10n.dart';
import 'package:golden_moments/shared/widgets/gm_choice_rows.dart';

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
      appBar: AppBar(
        // Wraps and grows with the text size instead of ending in "…".
        toolbarHeight: gmToolbarHeight(context),
        title: GmTitle(l10n.wellbeingHomePlanner),
      ),
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
                // Equal chips in full rows, never a word broken across
                // lines (DESIGN.md › Comfort-level chips).
                GmChoiceRows(
                  choices: [
                    for (final (time, label) in [
                      (PlanTime.morning, l10n.wellbeingPlannerMorning),
                      (PlanTime.afternoon, l10n.wellbeingPlannerAfternoon),
                      (PlanTime.evening, l10n.wellbeingPlannerEvening),
                    ])
                      (
                        label: label,
                        selected: _time == time,
                        onSelected: () => setState(() => _time = time),
                      ),
                  ],
                ),
                const SizedBox(height: gmSpaceLg),
                Text(
                  l10n.wellbeingPlannerWhoLabel,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: gmSpaceSm),
                GmChoiceRows(
                  choices: [
                    for (final (who, label) in [
                      (PlanFor.me, l10n.wellbeingPlannerForMe),
                      (PlanFor.someoneICare, l10n.wellbeingPlannerForCared),
                    ])
                      (
                        label: label,
                        selected: _who == who,
                        onSelected: () => setState(() => _who = who),
                      ),
                  ],
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
