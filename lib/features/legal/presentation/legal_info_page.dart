import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/l10n/l10n.dart';
import 'package:golden_moments/shared/widgets/gm_copyable_text.dart';
import 'package:url_launcher/url_launcher.dart';

// The website that publishes the legal pages (site/ in this repository).
const _site = 'https://dementiaactivities.games/';
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

    final l10n = context.l10n;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.legalOpenFailed),
        action: SnackBarAction(
          label: l10n.legalCopyLink,
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
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: gmToolbarHeight(context),
        title: GmTitle(l10n.legalTitle),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: gmContentMaxWidth),
            child: ListView(
              padding: const EdgeInsets.all(gmSpaceLg),
              children: [
                Text(l10n.legalHeading, style: theme.textTheme.headlineSmall),
                const SizedBox(height: gmSpaceMd),
                Text(l10n.legalNoAccount, style: theme.textTheme.bodyLarge),
                const SizedBox(height: gmSpaceMd),
                Text(
                  l10n.legalBuiltInPictures,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: gmSpaceXl),
                _link(
                  context,
                  label: l10n.legalPrivacyPolicyLink,
                  description: l10n.legalPrivacyPolicyDescription,
                  url: _appPrivacyUrl,
                  icon: Icons.privacy_tip_outlined,
                ),
                _link(
                  context,
                  label: l10n.legalPrivacyChoicesLink,
                  description: l10n.legalPrivacyChoicesDescription,
                  url: _privacyChoicesUrl,
                  icon: Icons.delete_outline,
                ),
                _link(
                  context,
                  label: l10n.legalTermsLink,
                  description: l10n.legalTermsDescription,
                  url: _termsUrl,
                  icon: Icons.description_outlined,
                ),
                _link(
                  context,
                  label: l10n.legalSafetyLink,
                  description: l10n.legalSafetyDescription,
                  url: _safetyUrl,
                  icon: Icons.info_outline,
                ),
                _link(
                  context,
                  label: l10n.legalSupportLink,
                  description: l10n.legalSupportDescription,
                  url: _supportUrl,
                  icon: Icons.help_outline,
                ),
                const SizedBox(height: gmSpaceSm),
                Text(l10n.legalPublisher, style: theme.textTheme.bodyMedium),
                const SizedBox(height: gmSpaceSm),
                const GmCopyableText('apple@locuno.com'),
                const SizedBox(height: gmSpaceLg),
                TextButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: Text(l10n.commonDoneForNow),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
