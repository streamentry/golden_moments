import 'package:flutter/material.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/l10n/l10n.dart';

/// Every destination the Home menu can open. The menu closes first and returns
/// one of these; Home then opens the page, so Back always returns to Home.
enum HomeMenuAction {
  exploreLibrary,
  dailyMoment,
  planner,
  progress,
  caregiverToday,
  healthyHabits,
  reminder,
  language,
  comfortSettings,
  guide,
}

/// The one menu for the app: a few plain sections, one row per destination.
/// Each row is a full-width button with an icon and its label, so nothing
/// depends on colour, and the rows grow with the person's text size.
class HomeMenuPage extends StatelessWidget {
  const new({required this.showReminder, super.key});

  /// The gentle reminder is offered only where the platform supports it.
  final bool showReminder;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final sections = <_MenuSection>[
      _MenuSection(l10n.menuSectionActivities, const [
        _MenuItem(
          HomeMenuAction.exploreLibrary,
          Icons.collections_bookmark_outlined,
        ),
      ]),
      _MenuSection(l10n.menuSectionEachDay, const [
        _MenuItem(HomeMenuAction.dailyMoment, Icons.today_outlined),
        _MenuItem(HomeMenuAction.planner, Icons.event_note_outlined),
        _MenuItem(HomeMenuAction.progress, Icons.timeline),
        _MenuItem(
          HomeMenuAction.caregiverToday,
          Icons.volunteer_activism_outlined,
        ),
      ]),
      _MenuSection(l10n.menuSectionHealth, [
        const _MenuItem(
          HomeMenuAction.healthyHabits,
          Icons.health_and_safety_outlined,
        ),
        if (showReminder)
          const _MenuItem(HomeMenuAction.reminder, Icons.notifications_none),
      ]),
      _MenuSection(l10n.menuSectionSettings, const [
        _MenuItem(HomeMenuAction.language, Icons.translate),
        _MenuItem(HomeMenuAction.comfortSettings, Icons.tune),
        _MenuItem(HomeMenuAction.guide, Icons.info_outline),
      ]),
    ];
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: gmToolbarHeight(context),
        title: GmTitle(l10n.menuTitle),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: gmContentMaxWidth),
            // A plain scroll view, not a lazy list: the menu is short and
            // every row must exist to be found and scrolled to.
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(gmSpaceLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final section in sections) ...[
                    _MenuSectionView(section: section),
                    const SizedBox(height: gmSpaceXl),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuSection {
  const new(this.title, this.items);

  final String title;
  final List<Widget> items;
}

class _MenuItem extends StatelessWidget {
  const new(this.action, this.icon);

  final HomeMenuAction action;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      minTileHeight: gmTargetHero,
      contentPadding: const EdgeInsets.symmetric(horizontal: gmSpaceMd),
      leading: Icon(icon, color: scheme.primary, size: 28),
      title: Text(
        _label(context),
        style: Theme.of(context).textTheme.titleMedium,
      ),
      trailing: Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
      onTap: () => Navigator.of(context).pop(action),
    );
  }

  String _label(BuildContext context) {
    final l10n = context.l10n;
    return switch (action) {
      HomeMenuAction.exploreLibrary => l10n.homeExploreLibrary,
      HomeMenuAction.dailyMoment => l10n.wellbeingHomeDailyMoment,
      HomeMenuAction.planner => l10n.wellbeingHomePlanner,
      HomeMenuAction.progress => l10n.wellbeingHomeProgress,
      HomeMenuAction.caregiverToday => l10n.todayTitle,
      HomeMenuAction.healthyHabits => l10n.habitsHomeButton,
      HomeMenuAction.reminder => l10n.commonGentleReminder,
      HomeMenuAction.language => l10n.languageTitle,
      HomeMenuAction.comfortSettings => l10n.commonComfortSettings,
      HomeMenuAction.guide => l10n.homeGuideTooltip,
    };
  }
}

/// A section heading in the serif headline face, over one bordered group of
/// rows. The rows share a single outline and are separated by hairlines.
class _MenuSectionView extends StatelessWidget {
  const new({required this.section});

  final _MenuSection section;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(section.title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: gmSpaceMd),
        // Material, not a decorated box: rows paint their ink on this surface.
        Material(
          color: scheme.surface,
          shape: gmTileShape(scheme),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < section.items.length; i++) ...[
                if (i > 0) Divider(height: 1, color: scheme.outline),
                section.items[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}
