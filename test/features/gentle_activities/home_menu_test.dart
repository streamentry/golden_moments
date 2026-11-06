import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/gentle_activities/presentation/gentle_home_page.dart';
import 'package:golden_moments/features/gentle_activities/presentation/home_menu_page.dart';
import 'package:golden_moments/l10n/gen/app_localizations.dart';
import 'package:golden_moments/shared/native/gm_native.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _ios = GmNative(supportedOverride: true);

Widget _app({required Widget home, double textScale = 1}) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  theme: gmBuildTheme(),
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context)
        .copyWith(textScaler: TextScaler.linear(textScale)),
    child: child!,
  ),
  home: home,
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('the menu groups every destination under four headings', (
    tester,
  ) async {
    await tester.pumpWidget(_app(home: const GentleHomePage(native: _ios)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Menu'));
    await tester.pumpAndSettle();

    for (final heading in [
      'More activities',
      'Each day',
      'Health and reminders',
      'Settings and help',
    ]) {
      expect(find.text(heading), findsOneWidget);
    }
    for (final row in [
      'Explore the picture-pack library',
      'Daily moment',
      'Plan my day',
      'My progress',
      'What is hardest today?',
      'Healthy habits',
      'Gentle reminder',
      'Language',
      'Comfort settings',
      'Guide and privacy',
    ]) {
      expect(find.widgetWithText(ListTile, row), findsOneWidget);
    }
    // One filled action per screen: the menu has none.
    expect(find.byType(FilledButton), findsNothing);
  });

  testWidgets('at 200% text every row stays readable and the menu scrolls', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      _app(textScale: 2, home: const HomeMenuPage(showReminder: true)),
    );
    await tester.pumpAndSettle();

    // No overflow error was thrown, and the last row can be reached.
    final last = find.widgetWithText(ListTile, 'Guide and privacy');
    await tester.scrollUntilVisible(
      last,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(last);
    expect(tester.takeException(), isNull);
    expect(last, findsOneWidget);
  });

  testWidgets('the menu hides the reminder where it is not supported', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(home: const HomeMenuPage(showReminder: false)),
    );
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ListTile, 'Gentle reminder'), findsNothing);
    expect(find.widgetWithText(ListTile, 'Healthy habits'), findsOneWidget);
  });

  testWidgets('choosing a row closes the menu and returns its action', (
    tester,
  ) async {
    HomeMenuAction? chosen;
    await tester.pumpWidget(
      _app(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              chosen = await Navigator.of(context).push<HomeMenuAction>(
                MaterialPageRoute(
                  builder: (_) => const HomeMenuPage(showReminder: false),
                ),
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    final row = find.widgetWithText(ListTile, 'Comfort settings');
    await tester.scrollUntilVisible(
      row,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(row);
    await tester.tap(row);
    await tester.pumpAndSettle();
    expect(chosen, HomeMenuAction.comfortSettings);
    expect(find.byType(HomeMenuPage), findsNothing);
  });
}
