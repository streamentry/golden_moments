import 'package:flutter/material.dart';
import 'package:golden_moments/data/models/sound_setting.dart';
import 'package:golden_moments/data/services/sound_service.dart';
import 'package:golden_moments/design_system.dart';
import 'package:provider/provider.dart';

/// A reusable settings modal for the app
class SettingModal extends StatelessWidget {
  const SettingModal({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final soundService = SoundService();

    return Consumer<SoundSettings>(
      builder: (context, settings, _) => Padding(
        padding: const EdgeInsets.all(gmSpaceLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: gmSpaceMd),
            Row(
              children: [
                Icon(
                  settings.isMusicOn ? Icons.volume_up : Icons.volume_off,
                ),
                const SizedBox(width: gmSpaceSm),
                const Text('Music'),
                const Spacer(),
                Switch(
                  value: soundService.musicEnabled,
                  onChanged: (val) {
                    soundService.musicEnabled = val;
                    settings.setMusic(val);
                  },
                ),
              ],
            ),
            const SizedBox(height: gmSpaceSm),
            Row(
              children: [
                Icon(
                  settings.isSoundOn ? Icons.music_note : Icons.music_off,
                ),
                const SizedBox(width: gmSpaceSm),
                const Text('Sound'),
                const Spacer(),
                Switch(
                  value: soundService.soundEnabled,
                  onChanged: (val) {
                    soundService.soundEnabled = val;
                    settings.setSound(val);
                  },
                ),
              ],
            ),
            const SizedBox(height: gmSpaceLg),
            Align(
              alignment: Alignment.centerRight,
              child: GmPrimaryButton(
                label: 'Save',
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper to show the settings modal as a bottom sheet
dynamic showSettingModal({
  required BuildContext context,
}) {
  return showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(gmRadiusLg)),
    ),
    builder: (ctx) => const SettingModal(),
  );
}
