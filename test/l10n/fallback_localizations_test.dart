import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/l10n/fallback_localizations.dart';

/// App languages Flutter's Material and Cupertino widgets have no text for.
const _withoutWidgetText = ['ha', 'yo', 'ig', 'jv', 'su', 'om', 'so', 'sd'];

Widget _app(String code) => MaterialApp(
  locale: Locale(code),
  supportedLocales: [const Locale('en'), Locale(code)],
  localizationsDelegates: const [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    ...fallbackLocalizationsDelegates,
  ],
  home: Scaffold(
    appBar: AppBar(title: const Text('x')),
    body: Builder(
      builder: (context) => Tooltip(
        message: MaterialLocalizations.of(context).okButtonLabel,
        child: const Icon(Icons.add),
      ),
    ),
    floatingActionButton: const FloatingActionButton(
      onPressed: null,
      child: Icon(Icons.add),
    ),
  ),
);

void main() {
  group('Material widgets in languages Flutter has no text for', () {
    for (final code in _withoutWidgetText) {
      testWidgets('$code builds and shows English widget text', (tester) async {
        await tester.pumpWidget(_app(code));
        expect(tester.takeException(), isNull);
        final context = tester.element(find.byType(Scaffold));
        expect(MaterialLocalizations.of(context).okButtonLabel, 'OK');
        expect(CupertinoLocalizations.of(context).alertDialogLabel, 'Alert');
      });
    }
  });

  group('languages Flutter does support keep their own widget text', () {
    testWidgets('Bengali is not replaced by the fallback', (tester) async {
      await tester.pumpWidget(_app('bn'));
      expect(tester.takeException(), isNull);
      final context = tester.element(find.byType(Scaffold));
      expect(MaterialLocalizations.of(context).okButtonLabel, isNot('OK'));
    });

    testWidgets('English is unchanged', (tester) async {
      await tester.pumpWidget(_app('en'));
      expect(tester.takeException(), isNull);
    });
  });

  test(
    'the fallback only claims languages the real delegates do not cover',
    () {
      const material = FallbackMaterialLocalizationsDelegate();
      expect(material.isSupported(const Locale('ha')), isTrue);
      expect(material.isSupported(const Locale('bn')), isFalse);
      expect(material.isSupported(const Locale('en')), isFalse);
      const cupertino = FallbackCupertinoLocalizationsDelegate();
      expect(cupertino.isSupported(const Locale('ha')), isTrue);
      expect(cupertino.isSupported(const Locale('ar')), isFalse);
    },
  );
}
