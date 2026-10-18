import 'dart:async';

import 'package:flutter/material.dart';
import 'package:golden_moments/app/view/main_navigation.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/gentle_activities/data/gentle_preferences.dart';
import 'package:golden_moments/features/gentle_activities/models/activity_picture.dart';
import 'package:golden_moments/features/gentle_activities/presentation/gentle_comfort_sheet.dart';
import 'package:golden_moments/features/gentle_activities/presentation/gentle_game_page.dart';
import 'package:golden_moments/features/gentle_activities/presentation/photo_collection_page.dart';
import 'package:golden_moments/features/gentle_activities/presentation/photo_together_page.dart';
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
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Enjoy it together',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Follow the person's interests. Keep pictures visible, "
                  'use fewer tiles, or simply look together. There is no '
                  'need to remember names or finish a game. Stop or change '
                  'the activity if it is uncomfortable.',
                ),
                const SizedBox(height: 16),
                const Text(
                  'Golden Moments offers recreation and shared '
                  'conversation. It does not diagnose, treat, prevent, or '
                  "measure dementia or Alzheimer's disease.",
                ),
                const SizedBox(height: 16),
                const Text(
                  'Family-photo copies are stored on this device and may be'
                  ' included in device backups. The app does not upload '
                  'these copies or sync them between relatives. The picture'
                  ' library is included in the app and works without '
                  'internet.',
                ),
                const SizedBox(height: gmSpaceLg),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Golden Moments'),
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
            child: ListView(
              padding: const EdgeInsets.all(gmSpaceLg),
              children: [
                Text(
                  'Simple activities to enjoy together',
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: gmSpaceMd),
                Text(
                  'Start with four large tiles. No timers, scores, or rush.',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: gmSpaceXl),
                FilledButton.icon(
                  style: FilledButton.styleFrom(minimumSize: heroSize),
                  onPressed: () => _open(
                    const GentleGamePage(pictures: ActivityPicture.samples),
                  ),
                  icon: const Icon(Icons.grid_view),
                  label: const Text('Start a gentle game'),
                ),
                const SizedBox(height: gmSpaceMd),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(minimumSize: heroSize),
                  onPressed: () => _open(const PhotoCollectionPage()),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Your family photos'),
                ),
                const SizedBox(height: gmSpaceMd),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(minimumSize: heroSize),
                  onPressed: () => _open(
                    const PhotoTogetherPage(pictures: ActivityPicture.samples),
                  ),
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Look together'),
                ),
                const SizedBox(height: gmSpaceXl),
                Text(
                  'The starter illustrations work without Wi-Fi. Selected '
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
