import 'package:flutter/material.dart';

/// Extra line height for scripts whose letters need more room than Latin ones.
///
/// Urdu is set in Nastaliq on iOS and Android: letters slope down to the left
/// and tall tails and dots reach into the next line, so at the app's normal
/// line height the lines of a headline run into each other (seen in the iOS
/// simulator). The other scripts the app offers were checked there at the
/// normal height and read well, so only Urdu is listed.
const _lineHeightFactors = <String, double>{'ur': 1.45};

/// Multiplier for every text style's line height in [locale], 1 for most.
double lineHeightFactorFor(Locale locale) =>
    _lineHeightFactors[locale.languageCode] ?? 1;

/// [base] with line heights scaled for [locale]; [base] itself where no change
/// is needed. Font sizes never change, so the 16 floor in DESIGN.md holds.
ThemeData themeForLocale(ThemeData base, Locale locale) {
  final factor = lineHeightFactorFor(locale);
  if (factor == 1) return base;
  return base.copyWith(textTheme: base.textTheme.apply(heightFactor: factor));
}

/// `MaterialApp.builder` that applies [themeForLocale] for the app language.
Widget localizedThemeBuilder(BuildContext context, Widget? child) => Theme(
  data: themeForLocale(Theme.of(context), Localizations.localeOf(context)),
  child: child ?? const SizedBox.shrink(),
);
