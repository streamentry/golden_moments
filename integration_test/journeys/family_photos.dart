import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_harness.dart';
import '../support/board.dart';
import '../support/family_photos.dart';
import '../support/screens.dart';

final Finder _busy = find.byType(LinearProgressIndicator);
Finder _options(String label) => find.bySemanticsLabel('Options for $label');

/// Waits for the collection screen to show [count] photos and finish work.
Future<void> _collectionShows(WidgetTester tester, int count) async {
  // The page keeps its scroll position; the count sits near the top.
  await reveal(tester, find.text('$count of 24 photos'));
  await waitFor(tester, find.text('$count of 24 photos'));
  await waitForAbsent(tester, _busy);
}

/// Every picture on screen drawn from the app's own copies, by id.
Set<String> _shownCopies(WidgetTester tester) => {
  for (final image in tester.widgetList<Image>(find.byType(Image)))
    if (switch (image.image) {
          ResizeImage(imageProvider: final FileImage provider) => provider.file,
          final FileImage provider => provider.file,
          _ => null,
        }
        case final file?)
      file.uri.pathSegments.last.replaceAll('.png', ''),
};

/// Journey 5: an installed collection (seeded straight into the app's real
/// storage, no system picker) is shown, given a caption and a favorite,
/// played, looked at with captions, partly hidden and partly removed, and
/// the files and manifest on disk match every step.
Future<void> familyPhotosInstalledCollection(WidgetTester tester) async {
  final images = [for (var i = 1; i <= 3; i++) generatedPng(i)];
  final ids = await seedInstalledCollection(images);
  await launchApp(tester);
  await tapOn(tester, find.text('Your family photos'));
  await _collectionShows(tester, 3);
  for (var i = 1; i <= 3; i++) {
    expect(_options('Family photo $i'), findsOneWidget);
  }
  expect(_shownCopies(tester), ids.toSet());
  expect(find.text('Photo unavailable'), findsNothing);
  await snap(tester, 'j5-installed-collection');

  // A caption and a favorite for the first photo.
  await tapOn(tester, _options('Family photo 1'));
  final caption = find.widgetWithText(TextField, 'Caption (optional)');
  await waitFor(tester, caption);
  await tester.enterText(caption, 'Garden bench');
  FocusManager.instance.primaryFocus?.unfocus();
  await settle(tester);
  await tapOn(tester, find.text('Favorite'));
  await tapOn(tester, find.text('Save'));
  await waitFor(tester, _options('Garden bench'));
  await waitForAbsent(tester, _busy);
  expect(find.text('Favorite'), findsOneWidget, reason: 'a word, not colour');
  var stored = await readStoredCollection();
  expect(stored.annotations[ids[0]], {
    'caption': 'Garden bench',
    'favorite': true,
  });

  // Play with these photos uses the stored copies.
  await tapOn(tester, find.text('Play with these photos'));
  await waitUntil(
    tester,
    () => boardTiles.evaluate().length == 4,
    description: 'a four-tile family board',
  );
  final names = {for (final tile in readBoard(tester)) tile.name};
  expect(
    names.difference({'Garden bench', 'Family photo 2', 'Family photo 3'}),
    isEmpty,
  );
  expect(ids.toSet().containsAll(_shownCopies(tester)), isTrue);
  expect(_shownCopies(tester), isNotEmpty);
  expect(find.text('Photo unavailable'), findsNothing);
  expectNoPressureCues(tester);
  await snap(tester, 'j5-family-board');
  await matchAllVisiblePairs(tester);
  await waitFor(tester, gentleAllTogether);
  await tapOn(tester, doneForNow);
  await _collectionShows(tester, 3);

  // Look at photos together: captions only when asked, then hide one.
  await tapOn(tester, find.text('Look at photos together'));
  await waitFor(tester, find.text('Picture 1 of 3'));
  expect(find.bySemanticsLabel('Garden bench'), findsOneWidget);
  expect(find.text('Garden bench'), findsNothing);
  await tapOn(tester, find.text('Show captions'));
  await waitFor(tester, find.text('Garden bench'));
  await snap(tester, 'j5-look-together-caption');
  await tapOn(tester, find.text('Next'));
  await waitFor(tester, find.text('Picture 2 of 3'));
  expect(find.bySemanticsLabel('Family photo 2'), findsOneWidget);
  await tapOn(tester, find.text('Hide this picture'));
  await waitFor(
    tester,
    find.text('Hidden. You can show it again in Your family photos.'),
  );
  expect(find.text('Picture 2 of 2'), findsOneWidget);
  expect(find.bySemanticsLabel('Family photo 2'), findsNothing);
  stored = await readStoredCollection();
  expect(stored.annotations[ids[1]], {'hidden': true});
  await tapOn(tester, doneForNow);
  await _collectionShows(tester, 3);
  expect(find.text('Hidden'), findsOneWidget);

  // Remove one copy, with a confirmation that names what happens.
  await tapOn(tester, _options('Family photo 3'));
  await tapOn(tester, find.text('Remove this copy'));
  await waitFor(tester, find.text('Remove this photo copy?'));
  await snap(tester, 'j5-remove-confirmation');
  await tapOn(tester, find.text('Remove copy'));
  await _collectionShows(tester, 2);
  expect(_options('Family photo 3'), findsNothing);
  // One shown photo is left, so there is no game, and the reason says so.
  expect(find.text('Play with these photos'), findsNothing);
  expect(
    find.text('Show at least two photos to make a matching game. 1 hidden.'),
    findsOneWidget,
  );
  await snap(tester, 'j5-after-remove');

  stored = await readStoredCollection();
  expect(stored.manifest, [ids[0], ids[1]]);
  expect(stored.copies, {ids[0], ids[1]});
  expect(stored.annotations.keys, unorderedEquals([ids[0], ids[1]]));
  expect(stored.annotations[ids[0]], {
    'caption': 'Garden bench',
    'favorite': true,
  });
  expect(stored.annotations[ids[1]], {'hidden': true});
  for (final id in [ids[0], ids[1]]) {
    expect(photoId(await readCopy(id)), id, reason: 'copy left unchanged');
  }
}
