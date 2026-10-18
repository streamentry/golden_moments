import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/gentle_activities/models/activity_picture.dart';
import 'package:golden_moments/features/gentle_activities/presentation/gentle_game_page.dart';
import 'package:golden_moments/features/gentle_activities/presentation/gentle_home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _app({double textScale = 1, Widget? home}) => MaterialApp(
  theme: gmBuildTheme(),
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context)
        .copyWith(textScaler: TextScaler.linear(textScale)),
    child: child!,
  ),
  home: home ?? const GentleGamePage(pictures: ActivityPicture.samples),
);

final Finder _tiles = find.bySemanticsLabel(RegExp(r', tile \d+$'));

Future<void> _size(WidgetTester tester, Size size) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('home to board: starter works with no plugin or network', (
    tester,
  ) async {
    await tester.pumpWidget(_app(home: const GentleHomePage()));
    await tester.tap(find.text('Start a gentle game'));
    await tester.pumpAndSettle();
    expect(find.text('Gentle photo match'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('board first: four large tiles and a visible exit, no settings', (
    tester,
  ) async {
    await _size(tester, const Size(360, 640));
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    expect(_tiles, findsNWidgets(4));
    for (final tile in _tiles.evaluate()) {
      final size = tester.getSize(find.byWidget(tile.widget));
      expect(size.shortestSide, greaterThanOrEqualTo(gmTileMin));
    }
    expect(find.text('Done for now'), findsOneWidget);
    expect(find.text('Start again'), findsOneWidget);
    // Settings are on request, not part of the first view.
    expect(find.text('4 tiles'), findsNothing);
    expect(find.text('Keep pictures visible'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Done for now leaves without any confirmation', (tester) async {
    await tester.pumpWidget(_app(home: const GentleHomePage()));
    await tester.tap(find.text('Start a gentle game'));
    await tester.pumpAndSettle();
    await tester.tap(_tiles.first);
    await tester.pump();
    await tester.tap(find.text('Done for now'));
    await tester.pumpAndSettle();
    expect(find.text('Gentle photo match'), findsNothing);
    expect(find.text('Start a gentle game'), findsOneWidget);
  });

  testWidgets(
    'Start again asks first once there is progress; cancel keeps it',
    (tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();
      // Without progress, starting again needs no question.
      await tester.tap(find.text('Start again'));
      await tester.pumpAndSettle();
      expect(find.text('Start again?'), findsNothing);

      await tester.tap(_tiles.first);
      await tester.pump();
      await tester.tap(find.text('Start again'));
      await tester.pumpAndSettle();
      expect(find.text('Start again?'), findsOneWidget);
      await tester.tap(find.text('Keep this board'));
      await tester.pumpAndSettle();
      expect(find.text('Start again?'), findsNothing);
      expect(find.bySemanticsLabel(RegExp('Selected')), findsNothing);
      final selected = tester.getSemantics(_tiles.first);
      expect(selected.value, 'Selected');

      await tester.tap(find.text('Start again'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Start again'));
      await tester.pumpAndSettle();
      expect(tester.getSemantics(_tiles.first).value, isNot('Selected'));
    },
  );

  testWidgets('help opens on request and play carries on afterwards', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await tester.tap(_tiles.first);
    await tester.pump();
    await tester.tap(find.byTooltip('How this works'));
    await tester.pumpAndSettle();
    expect(find.textContaining('no wrong answer'), findsOneWidget);
    await tester.tap(find.text('Back to the pictures'));
    await tester.pumpAndSettle();
    expect(tester.getSemantics(_tiles.first).value, 'Selected');
  });

  testWidgets(
    'settings: choose 8 tiles and hidden pictures, restart keeps them',
    (tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Comfort settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('8 tiles'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Back to the pictures'));
      await tester.pumpAndSettle();
      expect(_tiles, findsNWidgets(8));
      expect(find.bySemanticsLabel(RegExp('Hidden picture')), findsWidgets);

      // A fresh page, as after relaunching the app, remembers the choices.
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();
      expect(_tiles, findsNWidgets(8));
      expect(find.bySemanticsLabel(RegExp('Hidden picture')), findsWidgets);

      // Reset needs a yes and touches comfort choices only.
      await tester.tap(find.byTooltip('Comfort settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reset comfort settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Keep my settings'));
      await tester.pumpAndSettle();
      expect(_tiles, findsNWidgets(8));
      await tester.tap(find.text('Reset comfort settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Reset'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Back to the pictures'));
      await tester.pumpAndSettle();
      expect(_tiles, findsNWidgets(4));
      expect(find.bySemanticsLabel(RegExp('Hidden picture')), findsNothing);
    },
  );

  testWidgets('changing tile count mid-board asks first and can be declined', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await tester.tap(_tiles.first);
    await tester.pump();
    await tester.tap(find.byTooltip('Comfort settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('6 tiles'));
    await tester.pumpAndSettle();
    expect(find.text('Change the number of tiles?'), findsOneWidget);
    await tester.tap(find.text('Keep this board'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Back to the pictures'));
    await tester.pumpAndSettle();
    expect(_tiles, findsNWidgets(4));
    expect(tester.getSemantics(_tiles.first).value, 'Selected');
  });

  for (final scenario in {
    'phone with 200% text': (const Size(390, 844), 2.0),
    'small phone with 200% text': (const Size(320, 568), 2.0),
    'landscape phone': (const Size(844, 390), 1.0),
    'iPad portrait': (const Size(820, 1180), 1.0),
  }.entries) {
    testWidgets('layout holds on ${scenario.key}', (tester) async {
      await _size(tester, scenario.value.$1);
      await tester.pumpWidget(_app(textScale: scenario.value.$2));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(_tiles, findsNWidgets(4));
      for (final tile in _tiles.evaluate()) {
        expect(
          tester.getSize(find.byWidget(tile.widget)).shortestSide,
          greaterThanOrEqualTo(gmTileMin),
        );
      }
      // The exit is always on screen, even when the board scrolls.
      final done = tester.getRect(find.text('Done for now'));
      expect(done.bottom, lessThanOrEqualTo(scenario.value.$1.height));
      expect(done.top, greaterThanOrEqualTo(0));
    });
  }

  testWidgets('finishing offers Play again and Done together', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    // Match by trying tiles pairwise until the board is complete.
    for (var a = 0; a < 4 && find.text('Play again').evaluate().isEmpty; a++) {
      for (
        var b = a + 1;
        b < 4 && find.text('Play again').evaluate().isEmpty;
        b++
      ) {
        await tester.tap(_tiles.at(a));
        await tester.pump();
        await tester.tap(_tiles.at(b));
        await tester.pump();
      }
    }
    expect(find.text('Play again'), findsOneWidget);
    expect(find.text('Done for now'), findsOneWidget);
    expect(find.text('Start again'), findsNothing);
  });
}
