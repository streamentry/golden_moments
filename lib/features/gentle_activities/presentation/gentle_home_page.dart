import 'dart:async';

import 'package:flutter/material.dart';
import 'package:golden_moments/app/view/main_navigation.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/gentle_activities/data/gentle_preferences.dart';
import 'package:golden_moments/features/gentle_activities/models/activity_picture.dart';
import 'package:golden_moments/features/gentle_activities/presentation/gentle_comfort_sheet.dart';
import 'package:golden_moments/features/gentle_activities/presentation/gentle_game_page.dart';
import 'package:golden_moments/features/gentle_activities/presentation/help_privacy_page.dart';
import 'package:golden_moments/features/gentle_activities/presentation/photo_collection_page.dart';
import 'package:golden_moments/features/gentle_activities/presentation/photo_together_page.dart';
import 'package:golden_moments/features/legal/presentation/legal_info_page.dart';
import 'package:golden_moments/shared/sharing/share_invitation.dart';

/// Local activities remain usable even when the optional pack service is down.
class GentleHomePage extends StatefulWidget {
  const new({
    this.preferencesStore = const GentlePreferencesStore(),
    super.key,
  });

  /// Where comfort choices are saved; replaceable in tests.
  final GentlePreferencesStore preferencesStore;

  @override
  State<GentleHomePage> createState() => _GentleHomePageState();
}

class _GentleHomePageState extends State<GentleHomePage> {
  void _open(Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  /// A helper (or the person) can set tile count and picture view before
  /// anyone plays: the same choices as in the activity, saved the same way.
  Future<void> _showComfort() async {
    final store = widget.preferencesStore;
    final initial = await store.load();
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => GentleComfortSheet(
        initial: initial,
        maxPairs: ActivityPicture.samples.length,
        closeLabel: 'Done',
        onChanged: (next) async => (prefs: next, saved: await store.save(next)),
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
                  'Enjoy it together',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: gmSpaceMd),
                const Text(
                  "Follow the person's interests. Keep pictures visible, "
                  'use fewer tiles, or simply look together. There is no '
                  'need to remember names or finish a game. Stop or change '
                  'the activity if it is uncomfortable.',
                ),
                const SizedBox(height: gmSpaceMd),
                const Text(
                  'Golden Moments offers recreation and shared '
                  'conversation. It does not diagnose, treat, prevent, or '
                  "measure dementia or Alzheimer's disease.",
                ),
                const SizedBox(height: gmSpaceMd),
                const Text(
                  'Family-photo copies are stored on this device and may be'
                  ' included in device backups. The app does not upload '
                  'these copies or sync them between relatives. The picture'
                  ' library is included in the app and works without '
                  'internet.',
                ),
                const SizedBox(height: gmSpaceLg),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _open(const HelpPrivacyPage());
                  },
                  icon: const Icon(Icons.help_outline),
                  label: const Text('More help and privacy'),
                ),
                const SizedBox(height: gmSpaceSm),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _open(const LegalInfoPage());
                  },
                  icon: const Icon(Icons.privacy_tip_outlined),
                  label: const Text('Privacy, terms and support'),
                ),
                const SizedBox(height: gmSpaceMd),
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
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
    final heading = Text(
      'Simple activities to enjoy together',
      style: theme.textTheme.headlineMedium,
    );
    final start = FilledButton.icon(
      style: FilledButton.styleFrom(minimumSize: heroSize),
      onPressed: () =>
          _open(const GentleGamePage(pictures: ActivityPicture.samples)),
      icon: const Icon(Icons.grid_view),
      label: const Text('Start a gentle game'),
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
      Text(
        'Four large tiles. No timers, scores, or rush.',
        style: theme.textTheme.bodyLarge,
      ),
      if (largeText) ...[const SizedBox(height: gmSpaceLg), heading],
      const SizedBox(height: gmSpaceXl),
      OutlinedButton.icon(
        style: OutlinedButton.styleFrom(minimumSize: heroSize),
        onPressed: () => _open(const PhotoCollectionPage()),
        icon: const Icon(Icons.photo_library_outlined),
        label: const Text('Your family photos'),
      ),
      const SizedBox(height: gmSpaceMd),
      OutlinedButton.icon(
        style: OutlinedButton.styleFrom(minimumSize: heroSize),
        onPressed: () =>
            _open(const PhotoTogetherPage(pictures: ActivityPicture.samples)),
        icon: const Icon(Icons.chat_bubble_outline),
        label: const Text('Look together'),
      ),
      const SizedBox(height: gmSpaceXl),
      Text(
        // A non-breaking hyphen keeps "Wi‑Fi" on one line.
        'The starter illustrations work without Wi\u2011Fi. Selected '
        'family photos work offline after they are copied to this '
        'device.',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      const SizedBox(height: gmSpaceLg),
      TextButton.icon(
        onPressed: () => _open(const MainNavigation()),
        icon: const Icon(Icons.collections_bookmark_outlined),
        label: const Text('Explore the picture-pack library'),
      ),
      Text(
        'All picture packs are included. Ready to play offline.',
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      const SizedBox(height: gmSpaceLg),
      // Always available, never pushed (DESIGN.md › Sharing).
      Center(
        child: ShareWithFamilyButton(
          onPressed: () => unawaited(shareAndRemember()),
        ),
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: gmToolbarHeight(context),
        title: const GmTitle('Golden Moments'),
        actions: [
          IconButton(
            onPressed: _showComfort,
            icon: const Icon(Icons.tune),
            tooltip: 'Comfort settings',
          ),
          IconButton(
            onPressed: _showGuide,
            icon: const Icon(Icons.info_outline),
            tooltip: 'Guide and privacy',
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
                  constraints: BoxConstraints(
                    minHeight: viewport.maxHeight - gmSpaceLg * 2,
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

/// A small, decorative picture of the activity: two matching pairs on large
/// tiles, so a first visit shows what a game looks like before anyone taps.
/// Screen readers skip it; the button and sentence beside it say the same.
class _StarterPreview extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pictures = [
      ActivityPicture.samples[0],
      ActivityPicture.samples[1],
      ActivityPicture.samples[1],
      ActivityPicture.samples[0],
    ];
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
                    child: DecoratedBox(
                      decoration: ShapeDecoration(
                        color: scheme.surface,
                        shape: gmTileShape(scheme),
                      ),
                      child: LayoutBuilder(
                        builder: (context, box) => Icon(
                          pictures[i].icon,
                          size: box.maxWidth * 0.5,
                          color: scheme.primary,
                        ),
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
