import 'package:flutter/widgets.dart';
import 'package:golden_moments/l10n/gen/app_localizations.dart';

export 'package:golden_moments/l10n/gen/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// The language every untranslated text falls back to.
const fallbackLocale = Locale('en');

const _traditionalChineseRegions = {'TW', 'HK', 'MO'};

/// Picks the app language from the device's preferred languages, in order.
///
/// Flutter's default matching is close, but three cases need care:
/// - Chinese without a script (older Android sends `zh_TW`) must not land on
///   Simplified Chinese, and any other Chinese must not land on the empty
///   base `zh` file.
/// - Any Portuguese uses the Brazilian translation, the one that is kept.
/// - A language the app does not offer falls through to the next preferred
///   language, then to English, never to the first ARB alphabetically.
Locale resolveAppLocale(List<Locale>? preferred, Iterable<Locale> supported) {
  for (final locale in preferred ?? const <Locale>[]) {
    final match = _match(locale, supported);
    if (match != null) return match;
  }
  return fallbackLocale;
}

Locale? _match(Locale locale, Iterable<Locale> supported) {
  bool offers(Locale l) => supported.contains(l);
  switch (locale.languageCode) {
    case 'zh':
      final traditional =
          locale.scriptCode == 'Hant' ||
          (locale.scriptCode == null &&
              _traditionalChineseRegions.contains(locale.countryCode));
      final chosen = Locale.fromSubtags(
        languageCode: 'zh',
        scriptCode: traditional ? 'Hant' : 'Hans',
      );
      return offers(chosen) ? chosen : null;
    case 'pt':
      const brazil = Locale('pt', 'BR');
      return offers(brazil) ? brazil : null;
  }
  final plain = Locale(locale.languageCode);
  return offers(plain) ? plain : null;
}
