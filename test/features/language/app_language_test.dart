import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/app/app.dart';
import 'package:golden_moments/features/language/presentation/language_page.dart';
import 'package:golden_moments/l10n/app_language.dart';
import 'package:golden_moments/l10n/l10n.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _mongolian = Locale('mn');
const _portuguesePortugal = Locale('pt', 'PT');

void main() {
  group('AppLanguageStore', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('nothing saved means follow the device', () async {
      expect(
        await const AppLanguageStore().load(AppLocalizations.supportedLocales),
        isNull,
      );
    });

    test('a choice is saved as its language tag and read back', () async {
      const store = AppLanguageStore();
      await store.save(_portuguesePortugal);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(AppLanguageStore.key), 'pt-PT');
      expect(
        await store.load(AppLocalizations.supportedLocales),
        _portuguesePortugal,
      );
    });

    test('choosing the device language removes the saved choice', () async {
      const store = AppLanguageStore();
      await store.save(_mongolian);
      await store.save(null);
      expect(await store.load(AppLocalizations.supportedLocales), isNull);
    });

    test('a saved tag the app does not offer is ignored', () async {
      SharedPreferences.setMockInitialValues({AppLanguageStore.key: 'xx-YY'});
      expect(
        await const AppLanguageStore().load(AppLocalizations.supportedLocales),
        isNull,
      );
    });
  });

  group('AppLanguage', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('choosing a language notifies listeners and remembers it', () async {
      final language = AppLanguage();
      var notified = 0;
      language.addListener(() => notified++);

      await language.choose(_mongolian);
      expect(language.locale, _mongolian);
      expect(notified, 1);
      expect(
        await const AppLanguageStore().load(AppLocalizations.supportedLocales),
        _mongolian,
      );

      await language.choose(null);
      expect(language.locale, isNull);
      expect(notified, 2);
    });

    test('choosing the current language again changes nothing', () async {
      final language = AppLanguage(initial: _mongolian);
      var notified = 0;
      language.addListener(() => notified++);
      await language.choose(_mongolian);
      expect(notified, 0);
    });
  });

  group('LanguagePage', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test(
      'lists the offered languages in their own names, base files left out',
      () {
        final choices = LanguagePage.pickable(
          AppLocalizations.supportedLocales,
        );
        expect(choices.map((l) => l.toLanguageTag()), isNot(contains('pt')));
        expect(choices.map((l) => l.toLanguageTag()), isNot(contains('zh')));
        expect(choices, contains(_mongolian));
        expect(choices, contains(_portuguesePortugal));
        expect(choices.first.toLanguageTag(), 'en');
      },
    );

    testWidgets('a choice changes the app and is kept', (tester) async {
      final language = AppLanguage();
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: language,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const LanguagePage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final l10n = AppLocalizations.of(
        tester.element(find.byType(LanguagePage)),
      );

      expect(find.bySemanticsLabel(l10n.languageDevice), findsOneWidget);
      expect(language.locale, isNull);

      final mongolian = find.text('Монгол хэл');
      await tester.scrollUntilVisible(
        mongolian,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(mongolian);
      await tester.pumpAndSettle();
      expect(language.locale, _mongolian);
      expect(
        await const AppLanguageStore().load(AppLocalizations.supportedLocales),
        _mongolian,
      );
    });

    testWidgets('the first option undoes a saved choice', (tester) async {
      final language = AppLanguage(initial: _mongolian);
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: language,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const LanguagePage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('language-device')));
      await tester.pumpAndSettle();
      expect(language.locale, isNull);
      expect(
        await const AppLanguageStore().load(AppLocalizations.supportedLocales),
        isNull,
      );
    });
  });

  testWidgets('the app starts in the language the person chose', (
    tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: AppLanguage(initial: _mongolian),
        child: const App(),
      ),
    );
    await tester.pump();
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.locale, _mongolian);
  });
}
