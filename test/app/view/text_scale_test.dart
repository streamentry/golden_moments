import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/app/view/app.dart';
import 'package:golden_moments/data/models/sound_setting.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/gentle_activities/data/high_contrast_setting.dart';
import 'package:golden_moments/l10n/app_language.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The text size every screen below the app's navigator is built with.
double _appScale(WidgetTester tester) {
  final screen = tester.element(find.byType(Navigator).first);
  return MediaQuery.textScalerOf(screen).scale(16) / 16;
}

Future<void> _pumpApp(WidgetTester tester, double systemScale) async {
  tester.platformDispatcher.textScaleFactorTestValue = systemScale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SoundSettings()),
        ChangeNotifierProvider(create: (_) => AppLanguage()),
        ChangeNotifierProvider(create: (_) => HighContrastSetting()),
      ],
      child: const App(),
    ),
  );
  await tester.pump();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  // Maintainer decision, 2026-11-11: follow the phone's text size from 100%
  // to 200%. Larger accessibility sizes broke single words on a phone.
  for (final (system, expected) in [
    (3.1, gmTextScaleMax),
    (2.0, 2.0),
    (1.5, 1.5),
    (1.0, 1.0),
    (0.85, gmTextScaleMin),
  ]) {
    testWidgets('a phone text size of ${system * 100}% shows at '
        '${expected * 100}%', (tester) async {
      await _pumpApp(tester, system);
      expect(_appScale(tester), moreOrLessEquals(expected));
    });
  }

  testWidgets('dialogs and sheets get the same range as screens', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 3.1;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    late double inDialog;
    await tester.pumpWidget(
      MaterialApp(
        builder: gmTextScaleBuilder,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (context) {
                inDialog = MediaQuery.textScalerOf(context).scale(1);
                return const AlertDialog(content: Text('Hello'));
              },
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(inDialog, moreOrLessEquals(gmTextScaleMax));
  });
}
