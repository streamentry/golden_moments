import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The language the person picked in the app, kept on this phone.
///
/// Null means "follow this device", which is the default on first open: the
/// app then uses the device's own language list (see resolveAppLocale). The
/// choice is saved as a language tag, such as `mn` or `pt-PT`. A saved value
/// that is not a language the app offers is ignored, never shown.
class AppLanguageStore {
  const new();

  static const key = 'app.language.v1';

  Future<Locale?> load(Iterable<Locale> supported) async {
    final prefs = await SharedPreferences.getInstance();
    final tag = prefs.getString(key);
    if (tag == null) return null;
    for (final locale in supported) {
      if (locale.toLanguageTag() == tag) return locale;
    }
    return null;
  }

  /// Saves [locale], or removes the choice to follow the device when null.
  Future<void> save(Locale? locale) async {
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(key);
    } else {
      await prefs.setString(key, locale.toLanguageTag());
    }
  }
}

/// The current language choice, shared by the app and the language picker.
class AppLanguage extends ChangeNotifier {
  new({this.store = const AppLanguageStore(), Locale? initial})
    : _locale = initial;

  final AppLanguageStore store;
  Locale? _locale;

  /// The chosen language, or null to follow the device.
  Locale? get locale => _locale;

  /// Changes the language everywhere at once and remembers the choice.
  Future<void> choose(Locale? locale) async {
    if (locale == _locale) return;
    _locale = locale;
    notifyListeners();
    await store.save(locale);
  }
}
