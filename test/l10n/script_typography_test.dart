import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/l10n/fallback_localizations.dart';
import 'package:golden_moments/l10n/script_typography.dart';

void main() {
  group('line height for tall scripts', () {
    test('Urdu gets more room, because Nastaliq letters run diagonally', () {
      expect(lineHeightFactorFor(const Locale('ur')), greaterThan(1));
    });

    test('scripts that read well at the normal height keep it', () {
      for (final code in ['en', 'ar', 'fa', 'bn', 'ta', 'te', 'hi', 'ja']) {
        expect(lineHeightFactorFor(Locale(code)), 1, reason: code);
      }
    });

    test('the theme is untouched where no change is needed', () {
      final base = gmBuildTheme();
      expect(identical(themeForLocale(base, const Locale('en')), base), isTrue);
    });

    test('every text role grows by the same factor in Urdu', () {
      final base = gmBuildTheme();
      final urdu = themeForLocale(base, const Locale('ur'));
      final factor = lineHeightFactorFor(const Locale('ur'));
      final roles = {
        'displayLarge': (
          base.textTheme.displayLarge,
          urdu.textTheme.displayLarge,
        ),
        'headlineMedium': (
          base.textTheme.headlineMedium,
          urdu.textTheme.headlineMedium,
        ),
        'titleLarge': (base.textTheme.titleLarge, urdu.textTheme.titleLarge),
        'bodyLarge': (base.textTheme.bodyLarge, urdu.textTheme.bodyLarge),
        'labelLarge': (base.textTheme.labelLarge, urdu.textTheme.labelLarge),
      };
      for (final MapEntry(key: name, value: pair) in roles.entries) {
        final (before, after) = pair;
        expect(before!.height, isNotNull, reason: '$name has a line height');
        expect(
          after!.height,
          closeTo(before.height! * factor, 0.001),
          reason: name,
        );
        expect(after.fontSize, before.fontSize, reason: '$name keeps its size');
      }
    });
  });

  testWidgets('the app builder works under a right-to-left locale', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: gmBuildTheme(),
        locale: const Locale('ur'),
        supportedLocales: const [Locale('en'), Locale('ur')],
        // The app's own delegates: Urdu has Material text but no Cupertino
        // text, which the fallback supplies.
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          ...fallbackLocalizationsDelegates,
        ],
        builder: localizedThemeBuilder,
        home: Builder(
          builder: (context) =>
              Text('x', style: Theme.of(context).textTheme.bodyLarge),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    final text = tester.widget<Text>(find.text('x'));
    final base = gmBuildTheme().textTheme.bodyLarge!.height!;
    expect(
      text.style!.height,
      closeTo(base * lineHeightFactorFor(const Locale('ur')), 0.001),
    );
  });
}
