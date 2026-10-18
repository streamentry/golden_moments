import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/app_harness.dart';
import '../support/board.dart';
import '../support/screens.dart';

/// Opens the starter game from Home and waits for its board. The board looks
/// for a saved game once, on opening; [letResumeCheckFinish] gives that check
/// time to finish so the next tap is one that gets saved.
Future<void> _openGame(
  WidgetTester tester, {
  bool letResumeCheckFinish = false,
}) async {
  await tapOn(tester, startGentleGame);
  await waitFor(tester, boardTiles);
  if (letResumeCheckFinish) {
    await letTimePass(tester, const Duration(seconds: 1));
  }
}

/// Journey 2: stop with one tile chosen, Carry on restores the same board,
/// Start fresh after a relaunch gives a new one, and a finished board is
/// never offered again.
Future<void> stopAndResume(WidgetTester tester) async {
  final prefs = await SharedPreferences.getInstance();
  bool saved() => prefs.getString(starterSessionKey) != null;

  await launchApp(tester);
  await _openGame(tester, letResumeCheckFinish: true);
  final before = arrangement(tester);
  await tapTile(tester, 1);
  expect(readBoard(tester).first.selected, isTrue);
  await waitUntil(tester, saved, description: 'the unfinished board saved');
  await tapOn(tester, doneForNow);
  await waitFor(tester, startGentleGame);

  // Reopening asks; nothing resumes by itself.
  await tapOn(tester, startGentleGame);
  await waitFor(tester, resumePrompt);
  expect(carryOn, findsOneWidget);
  expect(startFresh, findsOneWidget);
  await snap(tester, 'j2-resume-prompt');
  await tapOn(tester, carryOn);
  await waitForAbsent(tester, resumePrompt);
  expect(arrangement(tester), before, reason: 'same arrangement restored');
  final restored = readBoard(tester);
  expect(restored.first.selected, isTrue, reason: 'chosen tile still chosen');
  expect(restored.skip(1).where((t) => t.selected || t.matched), isEmpty);
  await snap(tester, 'j2-carried-on');
  await tapOn(tester, doneForNow);
  await waitFor(tester, startGentleGame);

  // A cold relaunch still offers it; Start fresh forgets it.
  await launchApp(tester);
  await tapOn(tester, startGentleGame);
  await waitFor(tester, resumePrompt);
  await tapOn(tester, startFresh);
  await waitForAbsent(tester, resumePrompt);
  final fresh = readBoard(tester);
  expect(fresh, hasLength(4));
  expect(fresh.where((t) => t.selected || t.matched), isEmpty);
  await waitUntil(tester, () => !saved(), description: 'saved board cleared');
  await tapOn(tester, doneForNow);
  await _openGame(tester, letResumeCheckFinish: true);
  expect(resumePrompt, findsNothing, reason: 'Start fresh is final');

  // A finished board leaves nothing to resume, even after a relaunch.
  await tapTile(tester, 1);
  await waitUntil(tester, saved, description: 'the started board saved');
  await matchAllVisiblePairs(tester);
  await waitFor(tester, gentleAllTogether);
  await waitUntil(tester, () => !saved(), description: 'finished board gone');
  await tapOn(tester, doneForNow);
  await waitFor(tester, startGentleGame);
  await launchApp(tester);
  await _openGame(tester, letResumeCheckFinish: true);
  expect(resumePrompt, findsNothing);
  expect(readBoard(tester).where((t) => t.matched || t.selected), isEmpty);
}
