import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_harness.dart';
import '../support/board.dart';
import '../support/screens.dart';

/// Journey 9 (also run at 200% text): in every confirmation, keeping things
/// as they are is the primary action. Start again keeps a board with a found
/// pair unless the person picks Start again in the dialog, and Reset comfort
/// settings keeps them unless Reset is picked.
Future<void> safeConfirmations(
  WidgetTester tester, {
  double textScale = 1,
}) async {
  final tag = textScale == 1 ? '' : '-text-${(textScale * 100).round()}';
  await launchApp(tester, textScale: textScale);
  await tapOn(tester, startGentleGame);
  await waitFor(tester, boardTiles);

  final first = readBoard(tester).first;
  final twin = readBoard(tester)
      .firstWhere((t) => t.name == first.name && t.position != first.position);
  await tapTile(tester, first.position);
  await tapTile(tester, twin.position);
  int found() => readBoard(tester).where((t) => t.matched).length;
  expect(found(), 2);

  final barStartAgain = buttonWithLabel<OutlinedButton>(
    find.text('Start again'),
  );
  final question = find.text('Start again?');
  final keepBoard = find.text('Keep this board');
  final confirmStartAgain = find.descendant(
    of: find.byType(AlertDialog),
    matching: find.text('Start again'),
  );

  await tapOn(tester, barStartAgain);
  await waitFor(tester, question);
  expect(buttonWithLabel<FilledButton>(keepBoard), findsOneWidget);
  expect(buttonWithLabel<TextButton>(confirmStartAgain), findsOneWidget);
  expectHittable(tester, keepBoard);
  expectHittable(tester, confirmStartAgain);
  await snap(tester, 'j9-start-again$tag');
  await tapOn(tester, keepBoard);
  await waitForAbsent(tester, question);
  expect(found(), 2, reason: 'Keep this board keeps the found pair');

  await tapOn(tester, barStartAgain);
  await waitFor(tester, question);
  await tapOn(tester, confirmStartAgain);
  await waitForAbsent(tester, question);
  expect(found(), 0, reason: 'Start again, once chosen, clears the board');

  // Comfort settings: a chosen tile count survives a declined reset.
  await tapOn(tester, comfortSettingsButton);
  await tapOn(tester, find.text('6 tiles'));
  await tapOn(tester, find.text('Reset comfort settings'));
  final keepSettings = find.text('Keep my settings');
  await waitFor(tester, keepSettings);
  expect(buttonWithLabel<FilledButton>(keepSettings), findsOneWidget);
  expect(buttonWithLabel<TextButton>(find.text('Reset')), findsOneWidget);
  expectHittable(tester, keepSettings);
  await snap(tester, 'j9-reset$tag');
  await tapOn(tester, keepSettings);
  await waitForAbsent(tester, keepSettings);
  await tapOn(tester, find.text('Back to the pictures'));
  await waitUntil(
    tester,
    () => readBoard(tester).length == 6,
    description: 'a six-tile board',
  );
  expectNoPressureCues(tester);

  await tapOn(tester, doneForNow);
  await waitFor(tester, startGentleGame);
}
