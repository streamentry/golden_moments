import 'package:flutter/material.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/l10n/app_language.dart';
import 'package:golden_moments/l10n/l10n.dart';
import 'package:golden_moments/l10n/language_names.dart';
import 'package:provider/provider.dart';

/// Chooses the app's language. The first choice follows this device; any
/// other choice stays until the person picks again. Every language is named
/// in its own words, so it can be found even when the current language is
/// not one the person reads.
class LanguagePage extends StatelessWidget {
  const new({super.key});

  /// The languages a person can pick, in the site's menu order. The base
  /// Portuguese and Chinese files exist only for the generator and are left
  /// out.
  static List<Locale> pickable(Iterable<Locale> supported) {
    bool baseOnly(Locale l) =>
        (l.languageCode == 'pt' || l.languageCode == 'zh') &&
        l.countryCode == null &&
        l.scriptCode == null;
    final offered = supported.where((l) => !baseOnly(l)).toList();
    return [
      for (final tag in nativeLanguageNames.keys)
        for (final locale in offered)
          if (locale.toLanguageTag() == tag) locale,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final language = context.watch<AppLanguage>();
    final choices = pickable(AppLocalizations.supportedLocales);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.languageTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: gmContentMaxWidth),
            child: ListView(
              padding: const EdgeInsets.all(gmSpaceLg),
              children: [
                Text(l10n.languageIntro, style: theme.textTheme.bodyLarge),
                const SizedBox(height: gmSpaceLg),
                _LanguageChoice(
                  key: const ValueKey('language-device'),
                  label: l10n.languageDevice,
                  selected: language.locale == null,
                  onTap: () => language.choose(null),
                ),
                for (final locale in choices) ...[
                  const SizedBox(height: gmTileGap),
                  _LanguageChoice(
                    label:
                        nativeLanguageNames[locale.toLanguageTag()] ??
                        locale.toLanguageTag(),
                    selected: language.locale == locale,
                    onTap: () => language.choose(locale),
                  ),
                ],
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

/// One language. The selected one shows a check mark and says so to screen
/// readers, so the choice is not carried by colour alone.
class _LanguageChoice extends StatelessWidget {
  const new({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      selected: selected,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(gmTargetPrimary),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(
            horizontal: gmSpaceMd,
            vertical: gmSpaceSm,
          ),
        ),
        // Tapping the current choice is harmless, so it stays enabled.
        onPressed: onTap,
        child: Row(
          children: [
            Expanded(child: Text(label, style: theme.textTheme.bodyLarge)),
            if (selected) Icon(Icons.check, color: theme.colorScheme.onSurface),
          ],
        ),
      ),
    );
  }
}
