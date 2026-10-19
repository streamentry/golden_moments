import 'package:flutter_test/flutter_test.dart';

import '../support/app_harness.dart';
import '../support/board.dart';
import '../support/screens.dart';

final Finder _suggested = find.text('Suggested packs');
final Finder _favorites = find.text('Your favorites');
final Finder _packAllTogether = find.text('All pairs together');
const _hiddenNote =
    'Mountain Views is hidden. You can show it again under Hidden packs.';

/// Plays a picture-pack board the way a helper might: ask for a matching
/// pair, then tap the two pictures shown, until every pair is together.
Future<void> _playWithHints(WidgetTester tester) async {
  final hint = find.byTooltip('Show a matching pair');
  while (readBoard(tester).any((tile) => !tile.matched)) {
    await tapOn(tester, hint);
    final shown = readBoard(tester)
        .where((tile) => !tile.hidden && !tile.matched)
        .toList();
    expect(shown, hasLength(2), reason: 'a hint shows one pair');
    await tapOn(tester, shown[0].finder);
    await tapTile(tester, shown[1].position);
    final pair = readBoard(tester).where(
      (t) => t.position == shown[0].position || t.position == shown[1].position,
    );
    expect(pair.every((tile) => tile.matched), isTrue);
    expectNoPressureCues(tester);
  }
}

/// Journey 6: the included picture-pack library. Favorite a suggestion,
/// mark one Not for me and bring it back, open a topic and a pack, play it
/// to the end, play again and back out to Home.
Future<void> picturePackLibrary(WidgetTester tester) async {
  await launchApp(tester);
  await tapOn(tester, find.text('Explore the picture-pack library'));
  await waitFor(tester, _suggested);
  await waitFor(
    tester,
    find.bySemanticsLabel('Add to favorites, Farm Animals'),
  );
  expect(_favorites, findsNothing);
  for (final title in [
    'Farm Animals',
    'Mountain Views',
    'Cars and Trucks',
    'Safari Animals',
  ]) {
    expect(find.text(title), findsOneWidget);
  }
  await checkpoint(tester, 'j6-library');

  // Add to favorites moves the pack into its own group above suggestions.
  await tapOn(tester, find.bySemanticsLabel('Add to favorites, Farm Animals'));
  await waitFor(tester, _favorites);
  await waitFor(tester, find.bySemanticsLabel('In favorites, Farm Animals'));
  expect(find.bySemanticsLabel('Add to favorites, Farm Animals'), findsNothing);
  expect(find.text('Farm Animals'), findsOneWidget);
  final favoritesTop = tester.getTopLeft(_favorites).dy;
  final cardTop = tester.getTopLeft(find.text('Farm Animals')).dy;
  expect(cardTop, greaterThan(favoritesTop));
  expect(cardTop, lessThan(tester.getTopLeft(_suggested).dy));
  await checkpoint(tester, 'j6-favorite');

  // Not for me hides it with a lasting note; Show again restores it.
  await tapOn(tester, find.bySemanticsLabel('Not for me, hide Mountain Views'));
  await waitFor(tester, find.text(_hiddenNote));
  expect(find.text('Hidden packs (1)'), findsOneWidget);
  expect(
    find.bySemanticsLabel('Not for me, hide Mountain Views'),
    findsNothing,
  );
  await letTimePass(tester, const Duration(seconds: 2));
  expect(find.text(_hiddenNote), findsOneWidget, reason: 'never on a timer');
  await checkpoint(tester, 'j6-not-for-me');
  await tapOn(tester, find.bySemanticsLabel('Show Mountain Views again'));
  await waitForAbsent(tester, find.text(_hiddenNote));
  expect(find.text('Hidden packs (1)'), findsNothing);
  await waitFor(
    tester,
    find.bySemanticsLabel('Not for me, hide Mountain Views'),
  );

  // Open a topic, then a pack.
  await tapOn(tester, find.text('Delicious meals and treats'));
  await waitFor(tester, find.text('Street Food Fiesta'));
  await checkpoint(tester, 'j6-topic');
  await tapOn(tester, find.text('Delicious Desserts'));
  await waitUntil(
    tester,
    () => hiddenTiles.evaluate().length == 12,
    description: '12 hidden pack tiles',
  );
  expectHittable(tester, doneForNow);
  expectNoPressureCues(tester);
  await checkpoint(tester, 'j6-pack-board');

  await _playWithHints(tester);
  await waitFor(tester, _packAllTogether);
  expectHittable(tester, playAgain);
  expectNoPressureCues(tester);
  await checkpoint(tester, 'j6-pack-finished');
  await tapOn(tester, playAgain);
  await waitForAbsent(tester, _packAllTogether);
  await waitUntil(
    tester,
    () => hiddenTiles.evaluate().length == 12,
    description: 'a new 12-tile board',
  );

  // Back out: board, topic, library, Home.
  await tapOn(tester, doneForNow);
  await waitFor(tester, find.text('Street Food Fiesta'));
  await tester.pageBack();
  await settle(tester);
  await waitFor(tester, _suggested);
  await tester.pageBack();
  await settle(tester);
  await waitFor(tester, startGentleGame);
}
