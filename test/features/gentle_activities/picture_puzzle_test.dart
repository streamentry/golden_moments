import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/gentle_activities/models/activity_picture.dart';
import 'package:golden_moments/features/gentle_activities/models/puzzle_board.dart';
import 'package:golden_moments/features/gentle_activities/presentation/picture_puzzle_page.dart';
import 'package:golden_moments/shared/utils/experiments.dart';

const _one = [
  ActivityPicture(id: 'flower', label: 'Flower', icon: Icons.local_florist),
];

Widget _app({double textScale = 1, int seed = 7, int size = 2}) => MaterialApp(
  theme: gmBuildTheme(),
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context)
        .copyWith(textScaler: TextScaler.linear(textScale)),
    child: child!,
  ),
  home: PicturePuzzlePage(pictures: _one, size: size, random: Random(seed)),
);

final Finder _pieces = find.bySemanticsLabel(RegExp(r'^Piece \d+ of \d+$'));
Finder _spot(int slot, int n) =>
    find.bySemanticsLabel(RegExp('^Spot ${slot ~/ n + 1}, ${slot % n + 1},'));

/// The page draws its picture index first, then the tray order.
PuzzleBoard _mirror(int seed, int size) {
  final random = Random(seed)..nextInt(_one.length);
  return PuzzleBoard(size, random: random);
}

void main() {
  testWidgets('the experiment is off unless a build opts in', (tester) async {
    expect(experimentsEnabled, isFalse);
  });

  testWidgets('board first with a visible exit, whole picture in view', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_app());
    expect(find.text('The whole picture'), findsOneWidget);
    expect(_pieces, findsNWidgets(4));
    expect(find.text('Done for now'), findsOneWidget);
    expect(find.text('Start again'), findsOneWidget);
    // No clock, count, score, streak or move counter anywhere.
    expect(
      find.textContaining(
        RegExp(r'score|streak|moves|timer|\d+ of \d+', caseSensitive: false),
      ),
      findsNothing,
    );
    handle.dispose();
  });

  testWidgets('tap-to-place completes the puzzle; finishing is calm', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_app());
    final mirror = _mirror(7, 2);
    for (var slot = 0; slot < 4; slot++) {
      final index = mirror.tray.indexOf(slot);
      await tester.tap(_pieces.at(index));
      await tester.pump();
      await tester.tap(_spot(slot, 2));
      await tester.pump();
      mirror
        ..select(slot)
        ..tapSlot(slot);
    }
    expect(find.text('The picture is together.'), findsOneWidget);
    expect(_pieces, findsNothing);
    expect(find.text('Play again'), findsOneWidget);
    expect(find.text('Done for now'), findsOneWidget);
    expect(find.text('Start again'), findsNothing);
    handle.dispose();
  });

  testWidgets('a wrong placement is not flagged and can be taken back', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_app());
    final mirror = _mirror(7, 2);
    // Put some piece in a slot it does not belong to.
    final wrong = mirror.tray.firstWhere((p) => p != 0);
    await tester.tap(_pieces.at(mirror.tray.indexOf(wrong)));
    await tester.pump();
    expect(
      tester.getSemantics(_pieces.at(mirror.tray.indexOf(wrong))).value,
      'Selected',
    );
    await tester.tap(_spot(0, 2));
    await tester.pump();
    expect(_pieces, findsNWidgets(3));
    expect(find.text('There is no time limit.'), findsOneWidget);
    expect(
      find.textContaining(
        RegExp('wrong|incorrect|try again|mistake', caseSensitive: false),
      ),
      findsNothing,
    );
    // Tapping the placed piece takes it back.
    await tester.tap(_spot(0, 2));
    await tester.pump();
    expect(_pieces, findsNWidgets(4));
    handle.dispose();
  });

  testWidgets('Start again begins a new puzzle without asking', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_app());
    await tester.tap(_pieces.first);
    await tester.pump();
    await tester.tap(_spot(0, 2));
    await tester.pump();
    expect(_pieces, findsNWidgets(3));
    await tester.tap(find.text('Start again'));
    await tester.pump();
    expect(_pieces, findsNWidgets(4));
    handle.dispose();
  });

  for (final scenario in {
    'phone, 200% text': (const Size(390, 844), 2.0),
    'small phone, 200% text': (const Size(320, 568), 2.0),
    'landscape phone': (const Size(844, 390), 1.0),
    'iPad portrait': (const Size(820, 1180), 1.0),
  }.entries) {
    testWidgets('holds on ${scenario.key} with targets of at least 64', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.binding.setSurfaceSize(scenario.value.$1);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(_app(textScale: scenario.value.$2));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(_pieces, findsNWidgets(4));
      for (var i = 0; i < 4; i++) {
        expect(
          tester.getSize(_pieces.at(i)).shortestSide,
          greaterThanOrEqualTo(gmTileMin),
        );
      }
      // The exit is always on screen.
      final done = tester.getRect(find.text('Done for now'));
      expect(done.bottom, lessThanOrEqualTo(scenario.value.$1.height));
      handle.dispose();
    });
  }

  testWidgets('a 3 by 3 puzzle is also playable', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.binding.setSurfaceSize(const Size(390, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_app(size: 3));
    expect(_pieces, findsNWidgets(9));
    expect(tester.takeException(), isNull);
    handle.dispose();
  });
}
