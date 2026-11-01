import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Flutter's own Material and Cupertino widgets (back buttons, dialog and
/// tooltip text) ship text for about 115 languages. The app also offers
/// languages outside that list, such as Hausa. Without help, any Material
/// widget under such a language fails to build.
///
/// These delegates claim only the languages the real ones do not, and serve
/// Flutter's English widget text for them. The app's own text still comes from
/// `AppLocalizations` in the chosen language; only Flutter's built-in widget
/// labels are English there.
const fallbackLocalizationsDelegates = <LocalizationsDelegate<dynamic>>[
  FallbackMaterialLocalizationsDelegate(),
  FallbackCupertinoLocalizationsDelegate(),
];

/// English [MaterialLocalizations] for languages Flutter has no text for.
class FallbackMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const new();

  @override
  bool isSupported(Locale locale) =>
      !GlobalMaterialLocalizations.delegate.isSupported(locale);

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      GlobalMaterialLocalizations.delegate.load(const Locale('en'));

  @override
  bool shouldReload(FallbackMaterialLocalizationsDelegate old) => false;
}

/// English [CupertinoLocalizations] for languages Flutter has no text for.
class FallbackCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const new();

  @override
  bool isSupported(Locale locale) =>
      !GlobalCupertinoLocalizations.delegate.isSupported(locale);

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      GlobalCupertinoLocalizations.delegate.load(const Locale('en'));

  @override
  bool shouldReload(FallbackCupertinoLocalizationsDelegate old) => false;
}
