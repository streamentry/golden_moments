import 'package:flutter/material.dart';
import 'package:golden_moments/data/models/sound_setting.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/legal/presentation/legal_info_page.dart';
import 'package:provider/provider.dart';

/// A reusable settings modal for the app
class SettingModal extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<SoundSettings>(
      builder: (context, settings, _) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            gmSpaceLg,
            gmSpaceSm,
            gmSpaceLg,
            gmSpaceLg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Settings', style: theme.textTheme.headlineSmall),
              const SizedBox(height: gmSpaceMd),
              // The whole row is the target (DESIGN.md › Switch rows).
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: Icon(
                  settings.isMusicOn ? Icons.volume_up : Icons.volume_off,
                ),
                title: const Text('Music'),
                value: settings.isMusicOn,
                onChanged: (val) {
                  settings.toggleMusic();
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: Icon(
                  settings.isSoundOn ? Icons.music_note : Icons.music_off,
                ),
                title: const Text('Sound'),
                value: settings.isSoundOn,
                onChanged: (val) {
                  settings.toggleSound();
                },
              ),
              const SizedBox(height: gmSpaceLg),
              OutlinedButton.icon(
                onPressed: () {
                  final navigator = Navigator.of(context);
                  navigator.pop();
                  navigator.push(
                    MaterialPageRoute<void>(
                      builder: (_) => const LegalInfoPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.privacy_tip_outlined),
                label: const Text('Privacy, terms and support'),
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
      ),
    );
  }
}

/// Helper to show the settings modal as a bottom sheet
Future<void> showSettingModal({required BuildContext context}) {
  return showModalBottomSheet<void>(
    context: context,
    // Shape, color and drag handle come from gmBuildTheme.
    builder: (ctx) => const SettingModal(),
  );
}
