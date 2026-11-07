import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/gentle_activities/models/activity_picture.dart';
import 'package:golden_moments/features/gentle_activities/presentation/gentle_game_page.dart';
import 'package:golden_moments/l10n/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

// DESIGN.md: every icon has a word. The help and comfort actions on the
// gentle board are named in words, fit the screen width, and still open
// their sheets. On a short screen or at large text the row scrolls into view.

Widget _app({required double textScale}) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  theme: gmBuildTheme(),
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context)
        .copyWith(textScaler: TextScaler.linear(textScale)),
    child: child!,
  ),
  home: const GentleGamePage(pictures: ActivityPicture.samples),
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  for (final scenario in {
    'phone': (const Size(390, 844), 1.0),
    'small phone at 200% text': (const Size(320, 568), 2.0),
  }.entries) {
    testWidgets('help and comfort show words on ${scenario.key}', (
      tester,
    ) async {
      final (size, textScale) = scenario.value;
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(_app(textScale: textScale));
      await tester.pumpAndSettle();

      final help = find.widgetWithText(OutlinedButton, 'How this works');
      final comfort = find.widgetWithText(OutlinedButton, 'Comfort settings');
      expect(help, findsOneWidget);
      expect(comfort, findsOneWidget);
      expect(find.byType(IconButton), findsNothing);
      await tester.ensureVisible(comfort);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('the help button still opens the explanation', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_app(textScale: 1));
    await tester.pumpAndSettle();
    final help = find.widgetWithText(OutlinedButton, 'How this works');
    await tester.ensureVisible(help);
    await tester.tap(help);
    await tester.pumpAndSettle();
    expect(find.textContaining('no wrong answer'), findsOneWidget);
  });
}
