import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/features/gentle_activities/data/family_photo_store.dart';
import 'package:golden_moments/features/gentle_activities/data/photo_importer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:integration_test/integration_test.dart';

import 'support/app_harness.dart';
import 'support/board.dart';
import 'support/screens.dart';

/// Where the host script and this test meet, set by
/// `scripts/capture_store_screens.sh`. Empty (the default) skips the test, so
/// `flutter test integration_test` never waits for a host.
const String captureDirectory = String.fromEnvironment('GM_CAPTURE_DIR');

/// Drives the real app to each App Store frame in
/// `docs/specs/screenshots.md` and pauses there while the host captures the
/// simulator screen with `xcrun simctl io screenshot`: nothing is drawn or
/// edited here. The two demo photos go through the import's own normalize
/// and store steps; the system picker itself cannot be driven from a test.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App Store frames', (tester) async {
    // A release build shows no debug banner; neither should a capture.
    WidgetsApp.debugAllowBannerOverride = false;
    await resetAppStorage();
    try {
      await launchApp(tester);

      // 1. The four-tile starter, pairs on the diagonals so it reads as a
      // game still to play.
      await tapOn(tester, startGentleGame);
      await waitFor(tester, boardTiles);
      await _pairsOnDiagonals(tester);
      await _hostCapture(tester, '01');

      // 3. A found pair: a check, no clock or score.
      final board = readBoard(tester);
      await tapTile(tester, board[0].position);
      await tapTile(tester, board[3].position);
      await _hostCapture(tester, '03');

      // 5. The comfort sheet over the activity.
      await tapOn(tester, comfortSettingsButton);
      await waitFor(tester, find.text('Back to the pictures'));
      await _hostCapture(tester, '05');
      await tapOn(tester, find.text('Back to the pictures'));
      await tapOn(tester, doneForNow);
      await waitFor(tester, startGentleGame);

      // 2. A game with family photos.
      final importer = PhotoImporter();
      final photos = [
        for (final name in ['demo-teacup.png', 'demo-flowers.png'])
          await importer.normalize(XFile('$captureDirectory/$name')),
      ];
      await FamilyPhotoStore(await familyPhotoDirectory()).add(photos);
      await tapOn(tester, find.text('Your family photos'));
      final play = find.text('Play with these photos');
      await waitFor(tester, play);
      await tapOn(tester, play);
      await waitFor(tester, boardTiles);
      await _pairsOnDiagonals(tester);
      await _hostCapture(tester, '02');
      await tapOn(tester, doneForNow);

      // 4. Looking at a family photo together.
      await tapOn(tester, find.text('Look at photos together'));
      await waitFor(tester, find.text('Picture 1 of 2'));
      await _hostCapture(tester, '04');
      await tapOn(tester, doneForNow);
      await tapOn(tester, find.byTooltip('Back'));

      // 6. The included picture library.
      await tapOn(tester, find.text('Explore the picture-pack library'));
      await waitFor(tester, find.text('Suggested packs'));
      await _hostCapture(tester, '06');
    } finally {
      WidgetsApp.debugAllowBannerOverride = true;
      await resetAppStorage();
    }
  }, skip: captureDirectory.isEmpty);
}

/// Starts again (no question while nothing is found) until each pair sits
/// on a diagonal of the four-tile board.
Future<void> _pairsOnDiagonals(WidgetTester tester) async {
  final startAgain = buttonWithLabel<OutlinedButton>(find.text('Start again'));
  for (var i = 0; i < 40; i++) {
    final board = readBoard(tester);
    if (board[0].name == board[3].name) return;
    await tapOn(tester, startAgain);
    await waitFor(tester, boardTiles);
  }
  fail('No board with pairs on the diagonals after 40 tries.');
}

/// Leaves the screen as it is until the host has captured it: writes
/// `<frame>.ready`, then waits for the host's `<frame>.done`.
Future<void> _hostCapture(WidgetTester tester, String frame) async {
  // Pictures from files decode in real time; give them a moment to appear.
  await letTimePass(tester, const Duration(seconds: 2));
  await settle(tester);
  final done = File('$captureDirectory/$frame.done');
  if (done.existsSync()) done.deleteSync();
  File('$captureDirectory/$frame.ready').writeAsStringSync(frame);
  await waitUntil(
    tester,
    done.existsSync,
    description: 'the host capture of frame $frame',
    timeout: const Duration(seconds: 90),
  );
}
