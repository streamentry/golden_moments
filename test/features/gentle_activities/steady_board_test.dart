import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/gentle_activities/models/activity_picture.dart';
import 'package:golden_moments/features/gentle_activities/presentation/gentle_game_page.dart';
import 'package:golden_moments/l10n/gen/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

final Finder _tiles = find.bySemanticsLabel(RegExp(r', tile \d+$'));

Finder _shown(String text) => find.text(text);

String _name(WidgetTester tester, int i) =>
    tester.getSemantics(_tiles.at(i)).label.split(',').first;

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('the board never moves when the text above or below changes', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    // A phone width where the messages wrap to different line counts.
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: gmBuildTheme(),
        home: const GentleGamePage(pictures: ActivityPicture.samples),
      ),
    );
    await tester.pumpAndSettle();
    expect(_shown('There is no time limit.'), findsOneWidget);
    final start = tester.getTopLeft(_tiles.first);

    // A mismatch: the status changes to the longer "take your time" line.
    final first = _name(tester, 0);
    final other = [
      for (var i = 1; i < 4; i++)
        if (_name(tester, i) != first) i,
    ].first;
    await tester.tap(_tiles.at(0));
    await tester.pump();
    await tester.tap(_tiles.at(other));
    await tester.pumpAndSettle();
    expect(
      _shown('Take your time. Tap a picture to continue.'),
      findsOneWidget,
    );
    expect(tester.getTopLeft(_tiles.first), start);

    // Finishing changes the heading above and the status below.
    final names = [for (var i = 0; i < 4; i++) _name(tester, i)];
    for (final name in names.toSet()) {
      final pair = [
        for (var i = 0; i < 4; i++)
          if (names[i] == name) i,
      ];
      await tester.tap(_tiles.at(pair[0]));
      await tester.pump();
      await tester.tap(_tiles.at(pair[1]));
      await tester.pumpAndSettle();
    }
    expect(_shown('All pairs together.'), findsOneWidget);
    expect(tester.getTopLeft(_tiles.first), start);
    // Room is measured, not built: the earlier message is gone entirely.
    expect(find.text('There is no time limit.'), findsNothing);
    handle.dispose();
  });
}
