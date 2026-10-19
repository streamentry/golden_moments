import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_harness.dart';
import '../support/board.dart';
import '../support/screens.dart';

/// Journey 1 (also run at 200% text): fresh install, one dominant start,
/// four visible tiles, a mismatch that waits, both pairs matched, Play again
/// and Done for now. No clock, score or move count at any point.
Future<void> firstGentleGame(
  WidgetTester tester, {
  double textScale = 1,
}) async {
  final tag = textScale == 1 ? '' : '-text-${(textScale * 100).round()}';
  await launchApp(tester, textScale: textScale);

  // Home offers exactly one filled, dominant action.
  await waitFor(tester, startGentleGame);
  final filled = find.byWidgetPredicate((widget) => widget is FilledButton);
  expect(filled, findsOneWidget);
  expect(buttonWithLabel<FilledButton>(startGentleGame), findsOneWidget);
  expectHittable(tester, startGentleGame);
  expectNoPressureCues(tester);
  await checkpoint(tester, 'j1-home$tag');

  await tapOn(tester, startGentleGame);
  await waitFor(tester, boardTiles);
  var board = readBoard(tester);
  expect(board, hasLength(4));
  expect(board.where((tile) => tile.hidden), isEmpty);
  expect(resumePrompt, findsNothing);
  // One instruction; at very large text it moves below the board.
  expect(find.textContaining('Tap two pictures that match.'), findsOneWidget);
  expectHittable(tester, doneForNow);
  expectHittable(tester, find.text('Start again'));
  expectNoPressureCues(tester);
  await checkpoint(tester, 'j1-board$tag');

  // A mismatch stays in view until the next deliberate tap.
  final first = board.first;
  final other = board.firstWhere((tile) => tile.name != first.name);
  await tapTile(tester, first.position);
  await tapTile(tester, other.position);
  bool bothSelected() => readBoard(tester)
      .where(
        (t) => t.position == first.position || t.position == other.position,
      )
      .every((t) => t.selected);
  expect(bothSelected(), isTrue);
  expect(
    find.text('Take your time. Tap a picture to continue.'),
    findsOneWidget,
  );
  await letTimePass(tester, const Duration(seconds: 2));
  expect(bothSelected(), isTrue, reason: 'nothing flips back on its own');
  expectNoPressureCues(tester);

  await matchAllVisiblePairs(tester);
  await waitFor(tester, gentleAllTogether);
  // The closing words are in view above the buttons, even at 200% text.
  expectHittable(tester, find.text('Play again or take a break.'));
  expect(buttonWithLabel<FilledButton>(playAgain), findsOneWidget);
  expect(buttonWithLabel<OutlinedButton>(doneForNow), findsOneWidget);
  expectHittable(tester, playAgain);
  expectHittable(tester, doneForNow);
  expectNoPressureCues(tester);
  await checkpoint(tester, 'j1-finished$tag');

  await tapOn(tester, playAgain);
  await waitForAbsent(tester, gentleAllTogether);
  board = readBoard(tester);
  expect(board, hasLength(4));
  expect(board.where((t) => t.hidden || t.matched || t.selected), isEmpty);
  expectNoPressureCues(tester);

  await tapOn(tester, doneForNow);
  await waitFor(tester, startGentleGame);
  expect(boardTiles, findsNothing);
}
