import 'package:flutter/material.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/wellbeing/presentation/activity_planner_page.dart';
import 'package:golden_moments/l10n/l10n.dart';

/// Habits worth talking about: the changeable risk factors the 2024 Lancet
/// Commission links with dementia, in plain words, for any adult who wants to
/// look after their health as they age.
///
/// It never says a habit prevents dementia. Every line says "linked with",
/// and the page states that nothing has been proven to prevent it. There is
/// nothing to tick off, count, score or track, no age is asked, and nothing
/// leaves the phone. The source is named as text; the app does not open it.
class HabitsPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final habits = [
      (l10n.habitsHearingVisionTitle, l10n.habitsHearingVisionBody),
      (l10n.habitsHeartTitle, l10n.habitsHeartBody),
      (l10n.habitsMoveTitle, l10n.habitsMoveBody),
      (l10n.habitsConnectTitle, l10n.habitsConnectBody),
      (l10n.habitsSmokeTitle, l10n.habitsSmokeBody),
      (l10n.habitsHeadTitle, l10n.habitsHeadBody),
    ];

    return Scaffold(
      appBar: AppBar(
        // Wraps and grows with the text size instead of ending in "…".
        toolbarHeight: gmToolbarHeight(context),
        title: GmTitle(l10n.habitsTitle),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: gmContentMaxWidth),
            child: ListView(
              padding: const EdgeInsets.all(gmSpaceLg),
              children: [
                Text(l10n.habitsIntro, style: theme.textTheme.bodyLarge),
                const SizedBox(height: gmSpaceLg),
                for (final (title, body) in habits) ...[
                  _HabitCard(title: title, body: body),
                  const SizedBox(height: gmTileGap),
                ],
                const SizedBox(height: gmSpaceMd),
                Text(l10n.habitsDoctorNote, style: theme.textTheme.bodyLarge),
                const SizedBox(height: gmSpaceLg),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(gmTargetPrimary),
                  ),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ActivityPlannerPage(),
                    ),
                  ),
                  icon: const Icon(Icons.event_note_outlined),
                  label: Text(l10n.wellbeingHomePlanner),
                ),
                const SizedBox(height: gmSpaceXl),
                Text(
                  l10n.habitsSourcesTitle,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: gmSpaceSm),
                // Selectable so the address can be copied; the app never
                // opens it, so nothing leaves the phone from here.
                SelectableText(
                  l10n.habitsSources,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: gmSpaceLg),
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

/// One habit: a heading and a hedged sentence. Plain text, no icon that
/// could read as a checklist, and nothing to tap.
class _HabitCard extends StatelessWidget {
  const new({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(gmSpaceMd),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(gmRadiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: gmSpaceXs),
          Text(body, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}
