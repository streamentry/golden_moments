import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/features/gentle_activities/data/gentle_preferences.dart';
import 'package:golden_moments/features/gentle_activities/models/activity_picture.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/app_harness.dart';
import '../support/board.dart';
import '../support/screens.dart';

/// Journey 3: from Home choose 8 tiles and hidden pictures; after a
/// relaunch the game shows 8 hidden tiles that announce only their
/// position; resetting brings back 4 visible tiles.
Future<void> comfortSettingsFromHome(WidgetTester tester) async {
  final prefs = await SharedPreferences.getInstance();
  Map<String, dynamic>? stored() {
    final raw = prefs.getString(GentlePreferences.storageKey);
    return raw == null ? null : jsonDecode(raw) as Map<String, dynamic>;
  }

  await launchApp(tester);
  await tapOn(tester, comfortSettingsButton);
  await waitFor(tester, find.text('Number of tiles'));
  await checkpoint(tester, 'j3-comfort-sheet');
  await tapOn(tester, find.text('8 tiles'));
  await tapOn(tester, find.text('Keep pictures visible'));
  await waitUntil(
    tester,
    () => stored()?['pairs'] == 4 && stored()?['keepVisible'] == false,
    description: '8 hidden tiles saved',
  );
  await tapOn(tester, find.text('Done'));
  await waitForAbsent(tester, find.text('Number of tiles'));

  // The choices survive a relaunch and apply to the next game.
  await launchApp(tester);
  await tapOn(tester, startGentleGame);
  await waitUntil(
    tester,
    () => hiddenTiles.evaluate().length == 8,
    description: '8 hidden tiles',
  );
  final board = readBoard(tester);
  expect(board, hasLength(8));
  expect(board.every((tile) => tile.hidden), isTrue);
  final names = ActivityPicture.samples.map((p) => RegExp.escape(p.label));
  expect(
    find.bySemanticsLabel(RegExp('(${names.join('|')})')),
    findsNothing,
    reason: 'a hidden tile must never name its picture',
  );
  expect(resumePrompt, findsNothing);
  expectHittable(tester, doneForNow);
  await checkpoint(tester, 'j3-eight-hidden');

  // Choosing a tile shows only that picture.
  await tapTile(tester, 1);
  final chosen = readBoard(tester);
  expect(chosen.first.hidden, isFalse);
  expect(chosen.first.selected, isTrue);
  expect(chosen.skip(1).every((tile) => tile.hidden), isTrue);
  await tapOn(tester, doneForNow);
  await waitFor(tester, startGentleGame);

  // Reset from Home, with a confirmation.
  await tapOn(tester, comfortSettingsButton);
  await tapOn(tester, find.text('Reset comfort settings'));
  await waitFor(tester, find.text('Reset comfort settings?'));
  await tapOn(tester, find.text('Reset'));
  await waitForAbsent(tester, find.text('Reset comfort settings?'));
  await waitUntil(tester, () => stored() == null, description: 'reset saved');
  await tapOn(tester, find.text('Done'));
  await waitForAbsent(tester, find.text('Number of tiles'));

  // The unfinished hidden board is still offered; Start fresh uses the
  // reset choices.
  await tapOn(tester, startGentleGame);
  await waitFor(tester, resumePrompt);
  await tapOn(tester, startFresh);
  await waitForAbsent(tester, resumePrompt);
  final reset = readBoard(tester);
  expect(reset, hasLength(4));
  expect(reset.where((tile) => tile.hidden), isEmpty);
  await checkpoint(tester, 'j3-reset-four-visible');
  await tapOn(tester, doneForNow);
}
