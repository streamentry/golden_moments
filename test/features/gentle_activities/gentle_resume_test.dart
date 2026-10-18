import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/gentle_activities/data/gentle_session.dart';
import 'package:golden_moments/features/gentle_activities/models/activity_picture.dart';
import 'package:golden_moments/features/gentle_activities/presentation/gentle_game_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _app({String sessionKey = 'starter', double textScale = 1}) =>
    MaterialApp(
      theme: gmBuildTheme(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: GentleGamePage(
        pictures: ActivityPicture.samples,
        sessionKey: sessionKey,
      ),
    );

final Finder _tiles = find.bySemanticsLabel(RegExp(r', tile \d+$'));

List<String> _labels(WidgetTester tester) => [
  for (var i = 0; i < _tiles.evaluate().length; i++)
    tester.getSemantics(_tiles.at(i)).label,
];

Future<void> _relaunch(WidgetTester tester, {String key = 'starter'}) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pumpWidget(_app(sessionKey: key));
  await tester.pumpAndSettle();
}

Future<String?> _saved(String key) async =>
    (await SharedPreferences.getInstance()).getString(
      '${GentleSession.storageKeyPrefix}$key',
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('play, stop, relaunch: Carry on restores the same board', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    final before = _labels(tester);
    await tester.tap(_tiles.first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done for now'));
    await tester.pumpAndSettle();
    expect(await _saved('starter'), isNotNull);

    await _relaunch(tester);
    expect(find.text('Pick up where you left off?'), findsOneWidget);
    // Offered, not forced: nothing is selected until the person chooses.
    expect(tester.getSemantics(_tiles.first).value, isNot('Selected'));
    await tester.tap(find.text('Carry on'));
    await tester.pumpAndSettle();
    expect(_labels(tester), before);
    expect(tester.getSemantics(_tiles.first).value, 'Selected');
    expect(find.text('Pick up where you left off?'), findsNothing);
  });

  testWidgets('Start fresh forgets the saved board', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await tester.tap(_tiles.first);
    await tester.pumpAndSettle();

    await _relaunch(tester);
    await tester.tap(find.text('Start fresh'));
    await tester.pumpAndSettle();
    expect(tester.getSemantics(_tiles.first).value, isNot('Selected'));
    expect(await _saved('starter'), isNull);

    await _relaunch(tester);
    expect(find.text('Pick up where you left off?'), findsNothing);
  });

  testWidgets('a finished board leaves nothing to resume', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
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
    await tester.pumpAndSettle();
    expect(await _saved('starter'), isNull);
  });

  testWidgets('Start again after confirming clears the saved board', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await tester.tap(_tiles.first);
    await tester.pumpAndSettle();
    expect(await _saved('starter'), isNotNull);
    await tester.tap(find.text('Start again'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Start again'));
    await tester.pumpAndSettle();
    expect(await _saved('starter'), isNull);
  });

  testWidgets('declining Start again keeps the saved board too', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await tester.tap(_tiles.first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start again'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keep this board'));
    await tester.pumpAndSettle();
    expect(await _saved('starter'), isNotNull);
  });

  testWidgets('a deleted photo or odd record starts fresh without a prompt', (
    tester,
  ) async {
    // Session refers to a picture that is not in this game any more.
    SharedPreferences.setMockInitialValues({
      '${GentleSession.storageKeyPrefix}starter': jsonEncode(
        const GentleSession(
          cards: ['flower', 'gone', 'flower', 'gone'],
          matched: [],
          selected: [0],
        ).toJson(),
      ),
      'gm.unrelated.family.photos': 'kept',
    });
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    expect(find.text('Pick up where you left off?'), findsNothing);
    expect(_tiles, findsNWidgets(4));
    expect(tester.takeException(), isNull);
    expect(await _saved('starter'), isNull);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('gm.unrelated.family.photos'), 'kept');
  });

  testWidgets('a corrupt record never blocks the board', (tester) async {
    SharedPreferences.setMockInitialValues({
      '${GentleSession.storageKeyPrefix}starter': '{not json',
    });
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    expect(find.text('Pick up where you left off?'), findsNothing);
    expect(_tiles, findsNWidgets(4));
    expect(tester.takeException(), isNull);
  });

  testWidgets('starter and family boards are kept apart', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await tester.tap(_tiles.first);
    await tester.pumpAndSettle();

    await _relaunch(tester, key: 'family');
    expect(find.text('Pick up where you left off?'), findsNothing);
    expect(await _saved('starter'), isNotNull);
  });

  testWidgets('resume dialog and board hold at 200% text on a small phone', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    Widget big() => _app(textScale: 2);
    await tester.pumpWidget(big());
    await tester.pumpAndSettle();
    await tester.tap(_tiles.first);
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(big());
    await tester.pumpAndSettle();
    expect(find.text('Carry on'), findsOneWidget);
    expect(find.text('Start fresh'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Carry on'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
