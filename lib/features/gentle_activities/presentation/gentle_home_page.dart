import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:golden_moments/app/view/main_navigation.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/gentle_activities/data/gentle_preferences.dart';
import 'package:golden_moments/features/gentle_activities/data/high_contrast_setting.dart';
import 'package:golden_moments/features/gentle_activities/models/activity_picture.dart';
import 'package:golden_moments/features/gentle_activities/presentation/gentle_comfort_sheet.dart';
import 'package:golden_moments/features/gentle_activities/presentation/gentle_game_page.dart';
import 'package:golden_moments/features/gentle_activities/presentation/help_privacy_page.dart';
import 'package:golden_moments/features/gentle_activities/presentation/home_menu_page.dart';
import 'package:golden_moments/features/gentle_activities/presentation/photo_collection_page.dart';
import 'package:golden_moments/features/gentle_activities/presentation/photo_together_page.dart';
import 'package:golden_moments/features/gentle_activities/presentation/picture_view.dart';
import 'package:golden_moments/features/habits/presentation/habits_page.dart';
import 'package:golden_moments/features/language/presentation/language_page.dart';
import 'package:golden_moments/features/legal/presentation/legal_info_page.dart';
import 'package:golden_moments/features/reminders/presentation/reminder_page.dart';
import 'package:golden_moments/features/today/presentation/today_page.dart';
import 'package:golden_moments/features/todays_activity/data/todays_activity.dart';
import 'package:golden_moments/features/todays_activity/presentation/todays_activity_card.dart';
import 'package:golden_moments/features/wellbeing/presentation/activity_planner_page.dart';
import 'package:golden_moments/features/wellbeing/presentation/daily_moment_page.dart';
import 'package:golden_moments/features/wellbeing/presentation/progress_page.dart';
import 'package:golden_moments/l10n/l10n.dart';
import 'package:golden_moments/shared/native/gm_native.dart';
import 'package:golden_moments/shared/rating/review_request.dart';
import 'package:golden_moments/shared/sharing/share_invitation.dart';
import 'package:provider/provider.dart';

/// Local activities remain usable even when the optional pack service is down.
class GentleHomePage extends StatefulWidget {
  const new({
    this.preferencesStore = const GentlePreferencesStore(),
    this.native = const GmNative(),
    super.key,
  });

  /// Where comfort choices are saved; replaceable in tests.
  final GentlePreferencesStore preferencesStore;

  /// Reminders are offered only where the platform supports them (iOS).
  final GmNative native;

  @override
  State<GentleHomePage> createState() => _GentleHomePageState();
}

class _GentleHomePageState extends State<GentleHomePage> {
  void _open(Widget page) {
    unawaited(
      Navigator.of(context)
          .push(MaterialPageRoute<void>(builder: (_) => page))
          // Back on Home after a finished game is the one voluntary pause
          // where the system rating prompt may appear (DESIGN.md › Ratings).
          .then((_) => mounted ? askForReviewOnReturnHome() : null),
    );
  }

  void _openTodaysActivity(TodaysActivity activity) => _open(switch (activity) {
    TodaysActivity.dailyMoment => const DailyMomentPage(
      pictures: ActivityPicture.samples,
    ),
    TodaysActivity.lookTogether => const PhotoTogetherPage(
      pictures: ActivityPicture.samples,
    ),
  });

  /// The menu closes with the person's choice; Home then opens that page, so
  /// Back from it lands on Home rather than on the menu.
  Future<void> _openMenu() async {
    final action = await Navigator.of(context).push<HomeMenuAction>(
      MaterialPageRoute(
        builder: (_) => HomeMenuPage(showReminder: widget.native.isSupported),
      ),
    );
    if (!mounted || action == null) return;
    switch (action) {
      case HomeMenuAction.exploreLibrary:
        _open(const MainNavigation());
      case HomeMenuAction.dailyMoment:
        _open(const DailyMomentPage(pictures: ActivityPicture.samples));
      case HomeMenuAction.planner:
        _open(const ActivityPlannerPage());
      case HomeMenuAction.progress:
        _open(const ProgressPage());
      case HomeMenuAction.caregiverToday:
        _open(const TodayPage());
      case HomeMenuAction.healthyHabits:
        _open(const HabitsPage());
      case HomeMenuAction.reminder:
        _open(ReminderPage(native: widget.native));
      case HomeMenuAction.language:
        _open(const LanguagePage());
      case HomeMenuAction.comfortSettings:
        unawaited(_showComfort());
      case HomeMenuAction.guide:
        _showGuide();
    }
  }

  /// A helper (or the person) can set tile count and picture view before
  /// anyone plays: the same choices as in the activity, saved the same way.
  Future<void> _showComfort() async {
    final store = widget.preferencesStore;
    // Read before the first await, so the app-wide setting is updated safely.
    final contrastSetting = context.read<HighContrastSetting?>();
    final initial = await store.load();
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => GentleComfortSheet(
        initial: initial,
        maxPairs: ActivityPicture.samples.length,
        closeLabel: context.l10n.commonDone,
        onChanged: (next) async {
          final saved = await store.save(next);
          if (mounted) {
            contrastSetting?.set(enabled: next.highContrast);
          }
          return (prefs: next, saved: saved);
        },
        onReset: () async {
          await store.reset();
          return const GentlePreferences();
        },
      ),
    );
  }

  void _showGuide() {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (context) => SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              gmSpaceLg,
              0,
              gmSpaceLg,
              gmSpaceLg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.homeGuideTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: gmSpaceMd),
                Text(context.l10n.homeGuideInterests),
                const SizedBox(height: gmSpaceMd),
                Text(context.l10n.homeGuideNotMedical),
                const SizedBox(height: gmSpaceMd),
                Text(context.l10n.homeGuidePhotoCopies),
                const SizedBox(height: gmSpaceLg),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _open(const HelpPrivacyPage());
                  },
                  icon: const Icon(Icons.help_outline),
                  label: Text(context.l10n.homeGuideMoreHelp),
                ),
                const SizedBox(height: gmSpaceSm),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _open(const LegalInfoPage());
                  },
                  icon: const Icon(Icons.privacy_tip_outlined),
                  label: Text(context.l10n.commonPrivacyTermsSupport),
                ),
                const SizedBox(height: gmSpaceMd),
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(context.l10n.commonClose),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const heroSize = Size.fromHeight(gmTargetHero);
    final largeText = MediaQuery.textScalerOf(context).scale(16) / 16 > 1.5;
    final l10n = context.l10n;
    final heading = Text(
      l10n.homeHeading,
      style: theme.textTheme.headlineMedium,
    );
    final start = FilledButton.icon(
      style: FilledButton.styleFrom(minimumSize: heroSize),
      onPressed: () =>
          _open(const GentleGamePage(pictures: ActivityPicture.samples)),
      icon: const Icon(Icons.grid_view),
      label: Text(l10n.homeStartGentleGame),
    );
    final children = <Widget>[
      // The one dominant action stays in the first view (GM-001):
      // directly under the heading, and above it at large text. A
      // small picture of the activity sits between them.
      if (!largeText) ...[
        heading,
        const SizedBox(height: gmSpaceLg),
        const _StarterPreview(),
        const SizedBox(height: gmSpaceLg),
      ],
      start,
      const SizedBox(height: gmSpaceSm),
      Text(l10n.homeStartGentleGameHint, style: theme.textTheme.bodyLarge),
      if (largeText) ...[const SizedBox(height: gmSpaceLg), heading],
      if (todaysActivityEnabled) ...[
        const SizedBox(height: gmSpaceXl),
        TodaysActivityCard(onBegin: _openTodaysActivity),
      ],
      const SizedBox(height: gmSpaceXl),
      OutlinedButton.icon(
        style: OutlinedButton.styleFrom(minimumSize: heroSize),
        onPressed: () => _open(const PhotoCollectionPage()),
        icon: const Icon(Icons.photo_library_outlined),
        label: Text(l10n.commonYourFamilyPhotos),
      ),
      const SizedBox(height: gmSpaceMd),
      OutlinedButton.icon(
        style: OutlinedButton.styleFrom(minimumSize: heroSize),
        onPressed: () =>
            _open(const PhotoTogetherPage(pictures: ActivityPicture.samples)),
        icon: const Icon(Icons.chat_bubble_outline),
        label: Text(l10n.commonLookTogether),
      ),
      const SizedBox(height: gmSpaceXl),
      Text(
        // The ARB text keeps a non-breaking hyphen in "Wi‑Fi".
        l10n.homeOfflineNote,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      const SizedBox(height: gmSpaceLg),
      // Always available, never pushed (DESIGN.md › Sharing). Everything else
      // lives in the menu.
      Center(
        child: ShareWithFamilyButton(
          onPressed: () => unawaited(shareAndRemember(context.l10n)),
        ),
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: gmToolbarHeight(context),
        title: GmTitle(l10n.appTitle),
        actions: [
          // A labelled button, not an icon: the menu holds everything else.
          TextButton.icon(
            onPressed: _openMenu,
            icon: const Icon(Icons.menu),
            label: Text(l10n.menuTitle),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: gmContentMaxWidth),
            // On tall screens (iPad) the content sits in the middle rather
            // than clinging to the top; on small ones it simply scrolls.
            child: LayoutBuilder(
              builder: (context, viewport) => SingleChildScrollView(
                padding: const EdgeInsets.all(gmSpaceLg),
                child: ConstrainedBox(
                  // Never negative: a keyboard over the page (Home stays laid
                  // out under the photo pages) can leave less than the padding.
                  constraints: BoxConstraints(
                    minHeight: max(0, viewport.maxHeight - gmSpaceLg * 2),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: children,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A small, decorative picture of the activity: two matching pairs of the
/// shared drawings on large tiles, so a first visit shows what a game looks
/// like before anyone taps. Screen readers skip it; the button and sentence
/// beside it say the same.
class _StarterPreview extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = gmTileShape(scheme);
    final byId = {for (final p in ActivityPicture.samples) p.id: p};
    final first = byId['teacup'] ?? ActivityPicture.samples[0];
    final second = byId['sunflower'] ?? ActivityPicture.samples[1];
    final pictures = [first, second, second, first];
    return ExcludeSemantics(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Row(
            children: [
              for (var i = 0; i < pictures.length; i++) ...[
                if (i > 0) const SizedBox(width: gmTileGap),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Material(
                      color: scheme.surface,
                      shape: shape,
                      clipBehavior: Clip.antiAlias,
                      child: PictureView(
                        picture: pictures[i],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
