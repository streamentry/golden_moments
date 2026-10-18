import 'package:flutter/material.dart';
import 'package:golden_moments/app/view/main_navigation.dart';
import 'package:golden_moments/data/models/sound_setting.dart';
import 'package:golden_moments/data/services/download_manager.dart';
import 'package:golden_moments/data/services/http_client_service.dart';
import 'package:golden_moments/data/services/json_cache_service.dart';
import 'package:golden_moments/data/services/sound_service.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/gentle_activities/models/activity_picture.dart';
import 'package:golden_moments/features/gentle_activities/presentation/gentle_game_page.dart';
import 'package:golden_moments/features/gentle_activities/presentation/photo_collection_page.dart';
import 'package:golden_moments/features/gentle_activities/presentation/photo_together_page.dart';
import 'package:provider/provider.dart';

/// Local activities remain usable even when the optional pack service is down.
class GentleHomePage extends StatefulWidget {
  const GentleHomePage({super.key});

  @override
  State<GentleHomePage> createState() => _GentleHomePageState();
}

class _GentleHomePageState extends State<GentleHomePage> {
  bool _openingLibrary = false;

  void _open(Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  Future<void> _openLibrary() async {
    if (_openingLibrary) return;
    setState(() => _openingLibrary = true);
    final sound = context.read<SoundSettings>();
    try {
      await JsonCacheService().initialize();
      await DownloadManager().initialize();
      HttpClientService().initialize();
      await SoundService().initialize(sound);
      if (mounted) _open(const MainNavigation());
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'The picture library is unavailable. Your local activities still work.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _openingLibrary = false);
    }
  }

  void _showGuide() {
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
                "Follow the person's interests. Keep pictures visible, use fewer tiles, or simply look together. There is no need to remember names or finish a game. Stop or change the activity if it is uncomfortable.",
              ),
              const SizedBox(height: 16),
              const Text(
                "Golden Moments offers recreation and shared conversation. It does not diagnose, treat, prevent, or measure dementia or Alzheimer's disease.",
              ),
              const SizedBox(height: 16),
              const Text(
                'Family-photo copies are stored on this device and may be included in device backups. The app does not upload these copies or sync them between relatives. The optional picture library needs internet for downloads.',
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
                  onPressed: _openingLibrary ? null : _openLibrary,
                  icon: const Icon(Icons.collections_bookmark_outlined),
                  label: Text(
                    _openingLibrary
                        ? 'Opening library...'
                        : 'Explore the picture-pack library',
                  ),
                ),
                Text(
                  'Optional downloads. Existing packs remain available.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
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
