import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:golden_moments/design_system.dart';
import 'package:url_launcher/url_launcher.dart';

// The project path is significant on GitHub Pages. Do not strip it.
const _site = 'https://streamentry.github.io/golden-moments-web/';
const _appPrivacyUrl = '${_site}app-privacy/';
const _privacyChoicesUrl = '${_site}privacy-choices/';
const _termsUrl = '${_site}terms/';
const _safetyUrl = '${_site}safety/';
const _supportUrl = '${_site}support/';

/// Offline-readable privacy summary and opt-in links to public legal pages.
///
/// Viewing this screen makes no network request. URLs only open after a tap.
class LegalInfoPage extends StatelessWidget {
  const new({super.key});

  Future<void> _openExternal(BuildContext context, String url) async {
    var opened = false;
    try {
      opened = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } on Object {
      // A missing browser, offline device, or unsupported platform is okay.
      // Keep the current screen visible and offer a copyable address.
    }
    if (opened || !context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Could not open the page. You can copy the address and try later.',
        ),
        action: SnackBarAction(
          label: 'Copy link',
          onPressed: () =>
              unawaited(Clipboard.setData(ClipboardData(text: url))),
        ),
      ),
    );
  }

  Widget _link(
    BuildContext context, {
    required String label,
    required String description,
    required String url,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: gmSpaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => unawaited(_openExternal(context, url)),
              icon: Icon(icon),
              label: Text(label),
            ),
          ),
          const SizedBox(height: gmSpaceSm),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: gmToolbarHeight(context),
        title: const GmTitle('Privacy and information'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: gmContentMaxWidth),
            child: ListView(
              padding: const EdgeInsets.all(gmSpaceLg),
              children: [
                Text(
                  'Your pictures, your choice',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: gmSpaceMd),
                Text(
                  'There is no Golden Moments account or family-photo '
                  'server. When you choose family photos, the app keeps '
                  'working copies on this device. Device backups may '
                  'include those copies.',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: gmSpaceMd),
                Text(
                  'You can use built-in picture activities without '
                  'choosing any personal photographs.',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: gmSpaceXl),
                _link(
                  context,
                  label: 'Mobile app privacy policy',
                  description:
                      'What stays on your device, external '
                      'services, support email and data retention.',
                  url: _appPrivacyUrl,
                  icon: Icons.privacy_tip_outlined,
                ),
                _link(
                  context,
                  label: 'Privacy choices and deletion',
                  description:
                      'How to remove local copies without '
                      'removing originals, and manage device backups.',
                  url: _privacyChoicesUrl,
                  icon: Icons.delete_outline,
                ),
                _link(
                  context,
                  label: 'Terms and app license',
                  description:
                      "Apple's standard end-user license applies "
                      'unless the App Store lists a different license.',
                  url: _termsUrl,
                  icon: Icons.description_outlined,
                ),
                _link(
                  context,
                  label: 'Safety and intended use',
                  description:
                      'These are recreational picture activities, '
                      'not diagnosis, treatment or cognitive assessment.',
                  url: _safetyUrl,
                  icon: Icons.info_outline,
                ),
                _link(
                  context,
                  label: 'Contact support',
                  description:
                      'Please avoid sending private family '
                      'photographs or medical records to support.',
                  url: _supportUrl,
                  icon: Icons.help_outline,
                ),
                const SizedBox(height: gmSpaceSm),
                Text(
                  'Published by Cloudjet Solutions Pte. Ltd., Singapore.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: gmSpaceSm),
                const SelectableText('apple@locuno.com'),
                const SizedBox(height: gmSpaceLg),
                TextButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Done for now'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
