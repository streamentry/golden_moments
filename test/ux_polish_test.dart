import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/data/services/local_pack_service.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/game/presentation/screens/game_page.dart';
import 'package:golden_moments/features/gentle_activities/models/activity_picture.dart';
import 'package:golden_moments/features/gentle_activities/presentation/gentle_game_page.dart';
import 'package:golden_moments/features/gentle_activities/presentation/gentle_home_page.dart';
import 'package:golden_moments/shared/widgets/pack_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _app(Widget home, {double textScale = 1}) => MaterialApp(
  theme: gmBuildTheme(),
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context)
        .copyWith(textScaler: TextScaler.linear(textScale)),
    child: child!,
  ),
  home: home,
);

Future<void> _size(WidgetTester tester, Size size) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Future<void> _finishBoard(WidgetTester tester) async {
  final tiles = find.bySemanticsLabel(RegExp(r', tile \d+$'));
  final byPicture = <String, List<int>>{};
  for (var i = 0; i < tiles.evaluate().length; i++) {
    final label = tester.getSemantics(tiles.at(i)).label.split(', tile').first;
    byPicture.putIfAbsent(label, () => []).add(i + 1);
  }
  for (final pair in byPicture.values) {
    for (final position in pair) {
      await tester.tap(find.bySemanticsLabel(RegExp(', tile $position\$')));
      await tester.pumpAndSettle();
    }
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('app-bar titles wrap at 200% text instead of being cut off', (
    tester,
  ) async {
    await _size(tester, const Size(390, 844));
    await tester.pumpWidget(
      _app(
        const GentleGamePage(pictures: ActivityPicture.samples),
        textScale: 2,
      ),
    );
    await tester.pumpAndSettle();
    final title = tester.renderObject<RenderParagraph>(
      find.descendant(
        of: find.text('Gentle photo match'),
        matching: find.byType(RichText),
      ),
    );
    expect(title.didExceedMaxLines, isFalse);
    expect(title.text.toPlainText(), 'Gentle photo match');
    expect(tester.takeException(), isNull);
  });

  testWidgets('a finished board names the moment and puts Play again first', (
    tester,
  ) async {
    await _size(tester, const Size(320, 640));
    await tester.pumpWidget(
      _app(const GentleGamePage(pictures: ActivityPicture.samples)),
    );
    await tester.pumpAndSettle();
    await _finishBoard(tester);
    expect(find.text('All pairs together.'), findsOneWidget);
    expect(find.text('Tap two pictures that match.'), findsNothing);
    expect(find.text('Play again or take a break.'), findsOneWidget);
    final again = tester.getRect(find.text('Play again'));
    final done = tester.getRect(find.text('Done for now'));
    // Side by side only if both fit; stacked, the primary action leads.
    if ((again.top - done.top).abs() > 1) {
      expect(again.top, lessThan(done.top));
    }
    for (final label in ['Play again', 'Done for now']) {
      final paragraph = tester.renderObject<RenderParagraph>(
        find.descendant(of: find.text(label), matching: find.byType(RichText)),
      );
      expect(paragraph.size.height, lessThan(70), reason: '$label wrapped');
    }
  });

  testWidgets('GmButtonPair keeps labels whole and orders a stacked pair', (
    tester,
  ) async {
    Widget pair(double width) => _app(
      Scaffold(
        body: Center(
          child: SizedBox(
            width: width,
            child: GmButtonPair(
              first: OutlinedButton(
                onPressed: () {},
                child: const Text('Done for now'),
              ),
              second: FilledButton(
                onPressed: () {},
                child: const Text('Play again'),
              ),
              labels: ('Done for now', 'Play again'),
              secondOnTop: true,
            ),
          ),
        ),
      ),
    );
    await tester.pumpWidget(pair(2000));
    expect(
      tester.getTopLeft(find.text('Play again')).dy,
      tester.getTopLeft(find.text('Done for now')).dy,
    );
    await tester.pumpWidget(pair(260));
    await tester.pump();
    expect(
      tester.getTopLeft(find.text('Play again')).dy,
      lessThan(tester.getTopLeft(find.text('Done for now')).dy),
    );
  });

  testWidgets('home shows a picture of the activity that readers skip', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await _size(tester, const Size(390, 844));
    await tester.pumpWidget(_app(const GentleHomePage()));
    await tester.pumpAndSettle();
    final preview = find.descendant(
      of: find.byType(ExcludeSemantics),
      matching: find.byIcon(Icons.local_cafe),
    );
    expect(preview, findsNWidgets(2));
    // Still exactly one filled action, visible without scrolling.
    expect(find.byType(FilledButton), findsOneWidget);
    expect(
      find.widgetWithText(FilledButton, 'Start a gentle game').hitTestable(),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('pack cards give a tile count, never a difficulty word', (
    tester,
  ) async {
    final pack = (await tester.runAsync(
      () => LocalPackService().getPackById('animals_farm'),
    ))!;
    await tester.pumpWidget(
      _app(
        Scaffold(
          body: SingleChildScrollView(child: PackCard(pack: pack)),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('${pack.difficulty.totalTiles} tiles'), findsOneWidget);
    for (final word in ['Easy', 'Medium', 'Hard', 'Largest']) {
      expect(find.text(word), findsNothing);
    }
  });

  testWidgets('hidden picture-pack tiles show a card back, not a missing '
      'photo', (tester) async {
    final pack = (await tester.runAsync(
      () => LocalPackService().getPackById('nature_mountains'),
    ))!;
    await _size(tester, const Size(390, 1200));
    await tester.pumpWidget(_app(GamePage(gamePack: pack)));
    for (var i = 0; i < 20; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pumpAndSettle();
    expect(find.byType(GmTileBack), findsNWidgets(pack.difficulty.totalTiles));
    expect(find.byIcon(Icons.photo_outlined), findsNothing);
  });

  test('no screen calls the activity a memory test or nostalgic', () {
    final banned = RegExp(
      'memory games?|nostalgic|brain|cognitive score',
      caseSensitive: false,
    );
    final offenders = <String>[];
    for (final file in Directory('lib').listSync(recursive: true)) {
      if (file is! File || !file.path.endsWith('.dart')) continue;
      if (file.path.contains('/l10n/gen/')) continue;
      for (final match in RegExp(
        r"'([^'\n]*)'",
      ).allMatches(file.readAsStringSync())) {
        if (banned.hasMatch(match.group(1)!)) {
          offenders.add('${file.path}: ${match.group(1)}');
        }
      }
    }
    expect(offenders, isEmpty);
  });
}
