import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/gentle_activities/data/gentle_preferences.dart';
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

  for (final scenario in {
    'small phone': (const Size(320, 568), 1.0),
    'phone at 200% text': (const Size(390, 844), 2.0),
    'small phone at 200% text': (const Size(320, 568), 2.0),
    'landscape phone': (const Size(844, 390), 1.0),
  }.entries) {
    testWidgets('fresh install on ${scenario.key}: one Start, one tap to play '
        '(GM-001)', (tester) async {
      final (size, textScale) = scenario.value;
      await _size(tester, size);
      await tester.pumpWidget(
        _app(home: const GentleHomePage(), textScale: textScale),
      );
      await tester.pumpAndSettle();

      // One dominant action, visible without scrolling or setup questions.
      expect(find.byType(FilledButton), findsOneWidget);
      final start = find.widgetWithText(FilledButton, 'Start a gentle game');
      expect(start.hitTestable(), findsOneWidget);
      expect(tester.getRect(start).bottom, lessThanOrEqualTo(size.height));
      expect(find.byType(Dialog), findsNothing);
      expect(find.byType(BottomSheet), findsNothing);

      await tester.tap(start);
      await tester.pumpAndSettle();
      expect(_tiles, findsNWidgets(4));
      expect(find.bySemanticsLabel(RegExp('Hidden picture')), findsNothing);
      expect(find.byType(Dialog), findsNothing);
      expect(find.text('Done for now'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('an existing comfort choice is kept, never reset (GM-001)', (
    tester,
  ) async {
    final saved = jsonEncode(
      const GentlePreferences(pairs: 3, keepVisible: false).toJson(),
    );
    SharedPreferences.setMockInitialValues({
      GentlePreferences.storageKey: saved,
    });
    await _size(tester, const Size(480, 1400));
    await tester.pumpWidget(_app(home: const GentleHomePage()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start a gentle game'));
    await tester.pumpAndSettle();
    expect(_tiles, findsNWidgets(6));
    expect(find.bySemanticsLabel(RegExp('Hidden picture')), findsNWidgets(6));
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(GentlePreferences.storageKey), saved);
  });

  testWidgets('comfort settings set from Home carry into the game (GM-037)', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(480, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_app(home: const GentleHomePage()));
    await tester.pumpAndSettle();
    // The helper prepares the experience before anyone plays.
    await tester.tap(find.byTooltip('Comfort settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('8 tiles'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start a gentle game'));
    await tester.pumpAndSettle();
    expect(_tiles, findsNWidgets(8));
    expect(find.bySemanticsLabel(RegExp('Hidden picture')), findsWidgets);
    // The participant sees only the board and the exit.
    expect(find.text('8 tiles'), findsNothing);
    expect(find.text('Done for now'), findsOneWidget);

    // Reset from Home returns to the starting choices without confusion.
    await tester.tap(find.text('Done for now'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Comfort settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reset comfort settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Reset'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start a gentle game'));
    await tester.pumpAndSettle();
    expect(_tiles, findsNWidgets(4));
  });

  testWidgets('rotating mid-turn keeps the board and the choice (GM-016)', (
    tester,
  ) async {
    await _size(tester, const Size(390, 844));
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    List<String> labels() => [
      for (final e in _tiles.evaluate())
        tester.getSemantics(find.byWidget(e.widget)).label,
    ];
    final before = labels();
    await tester.tap(_tiles.first);
    await tester.pumpAndSettle();
    expect(tester.getSemantics(_tiles.first).value, 'Selected');

    // Landscape, then back: same pictures in the same places, still chosen.
    await tester.binding.setSurfaceSize(const Size(844, 390));
    await tester.pumpAndSettle();
    expect(labels(), before);
    expect(tester.getSemantics(_tiles.first).value, 'Selected');
    expect(find.text('Done for now').hitTestable(), findsOneWidget);
    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpAndSettle();
    expect(labels(), before);
    expect(tester.getSemantics(_tiles.first).value, 'Selected');
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
      await tester.tap(find.widgetWithText(TextButton, 'Start again'));
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
      await tester.tap(find.widgetWithText(TextButton, 'Reset'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Back to the pictures'));
      await tester.pumpAndSettle();
      expect(_tiles, findsNWidgets(4));
      expect(find.bySemanticsLabel(RegExp('Hidden picture')), findsNothing);
    },
  );

  testWidgets('two quick choices in the comfort sheet both count', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Comfort settings'));
    await tester.pumpAndSettle();
    // No frame between the two taps: the second must build on the first.
    await tester.tap(find.text('6 tiles'));
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    final saved = await const GentlePreferencesStore().load();
    expect(saved.pairs, 3);
    expect(saved.keepVisible, isFalse);
    await tester.tap(find.text('Back to the pictures'));
    await tester.pumpAndSettle();
    expect(_tiles, findsNWidgets(6));
  });

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
