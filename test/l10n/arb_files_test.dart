import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/l10n/l10n.dart';

/// The 20 app languages (GM-036). `pt` and `zh` are the base files Flutter's
/// generator requires next to `pt_BR`, `zh_Hans` and `zh_Hant`.
const _appLocales = {
  'en', 'es', 'pt_BR', 'fr', 'de', 'it', 'nl', 'pl', 'ru', 'uk', 'tr', //
  'ar', 'hi', 'ja', 'ko', 'zh_Hans', 'zh_Hant', 'vi', 'id', 'th',
  'bn',
  'fa',
  'ha',
  'ur',
  'mr',
  'te',
  'ta',
  'gu',
  'pa',
  'fil',
  'ro',
  'ms',
  'sw',
  'kn',
  'ml',
  'ne',
  'az',
  'am',
};
const _baseFallbacks = {'pt', 'zh'};

final _arbDir = Directory('lib/l10n/arb');

Map<String, dynamic> _read(File file) =>
    jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

Map<String, dynamic> get _english => _read(File('${_arbDir.path}/app_en.arb'));

Iterable<String> _messageKeys(Map<String, dynamic> arb) =>
    arb.keys.where((k) => !k.startsWith('@'));

/// Placeholder names used in an ICU message, including inside plurals.
Set<String> _placeholdersIn(String message) =>
    RegExp(r'\{(\w+)[,}]').allMatches(message).map((m) => m.group(1)!).toSet();

String _localeOf(File file) =>
    RegExp(r'app_(.+)\.arb$').firstMatch(file.path)!.group(1)!;

String _tag(Locale l) => [
  l.languageCode,
  if (l.scriptCode != null) l.scriptCode,
  if (l.countryCode != null) l.countryCode,
].join('_');

void main() {
  final files =
      _arbDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.arb'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  test('there is one ARB file per app language and nothing else', () {
    expect(files.map(_localeOf).toSet(), {..._appLocales, ..._baseFallbacks});
  });

  test('the app offers exactly those languages', () {
    expect(AppLocalizations.supportedLocales.map(_tag).toSet(), {
      ..._appLocales,
      ..._baseFallbacks,
    });
  });

  for (final file in files) {
    test('${file.path} parses and names its own locale', () {
      final arb = _read(file);
      expect(arb['@@locale'], _localeOf(file));
    });
  }

  test('every English text has a description for translators', () {
    final arb = _english;
    final missing = [
      for (final key in _messageKeys(arb))
        if (arb['@$key'] is! Map ||
            ((arb['@$key'] as Map)['description'] as String? ?? '')
                .trim()
                .isEmpty)
          key,
    ];
    expect(missing, isEmpty);
    expect(_messageKeys(arb).length, greaterThan(300));
  });

  test('every placeholder in an English text is declared', () {
    final arb = _english;
    for (final key in _messageKeys(arb)) {
      final used = _placeholdersIn(arb[key] as String);
      final declared =
          ((arb['@$key'] as Map)['placeholders'] as Map?)?.keys.toSet() ??
          const <String>{};
      expect(used, declared, reason: key);
    }
  });

  test('translations only use English keys and the same placeholders', () {
    final english = _english;
    for (final file in files) {
      final arb = _read(file);
      for (final key in _messageKeys(arb)) {
        expect(english, contains(key), reason: '${file.path}: $key');
        expect(
          _placeholdersIn(arb[key] as String),
          _placeholdersIn(english[key] as String),
          reason: '${file.path}: $key',
        );
      }
    }
  });

  // The same words test/ux_polish_test.dart keeps out of Dart code.
  test('no text calls the activity a memory test or nostalgic', () {
    final banned = RegExp(
      'memory games?|nostalgic|brain|cognitive score',
      caseSensitive: false,
    );
    for (final file in files) {
      final arb = _read(file);
      for (final key in _messageKeys(arb)) {
        expect(
          banned.hasMatch(arb[key] as String),
          isFalse,
          reason: '${file.path}: $key',
        );
      }
    }
  });

  group('language choice', () {
    const supported = AppLocalizations.supportedLocales;
    Locale pick(List<Locale> preferred) =>
        resolveAppLocale(preferred, supported);

    test('an offered language is used', () {
      expect(pick([const Locale('ar', 'EG')]), const Locale('ar'));
      expect(pick([const Locale('de', 'AT')]), const Locale('de'));
    });

    test('Chinese follows the script, or the region when none is sent', () {
      const hant = Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant');
      const hans = Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans');
      expect(
        pick([
          const Locale.fromSubtags(
            languageCode: 'zh',
            scriptCode: 'Hant',
            countryCode: 'TW',
          ),
        ]),
        hant,
      );
      expect(pick([const Locale('zh', 'HK')]), hant);
      expect(pick([const Locale('zh', 'CN')]), hans);
      expect(pick([const Locale('zh')]), hans);
    });

    test('all Portuguese uses the Brazilian translation', () {
      expect(pick([const Locale('pt', 'PT')]), const Locale('pt', 'BR'));
      expect(pick([const Locale('pt')]), const Locale('pt', 'BR'));
    });

    test('an unoffered language falls through, then to English', () {
      expect(
        pick([const Locale('ca'), const Locale('es')]),
        const Locale('es'),
      );
      expect(pick([const Locale('sv')]), const Locale('en'));
      expect(pick([]), const Locale('en'));
    });
  });

  test('a language with no translated text shows the English text', () async {
    // app_pt.arb is the generator's empty base file for pt_BR.
    final base = await AppLocalizations.delegate.load(const Locale('pt'));
    final english = lookupAppLocalizations(fallbackLocale);
    expect(base.homeStartGentleGame, english.homeStartGentleGame);
    expect(base.localeName, 'pt');
  });
}
