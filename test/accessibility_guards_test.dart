import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/gentle_activities/data/gentle_preferences.dart';
import 'package:golden_moments/features/gentle_activities/models/activity_picture.dart';
import 'package:golden_moments/features/gentle_activities/presentation/gentle_game_page.dart';
import 'package:golden_moments/l10n/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

// A valid 1x1 PNG, so the revealed tile has a real image to show.
final Uint8List _png = base64Decode(
  [
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAE',
    'hQGAhKmMIQAAAABJRU5ErkJggg==',
  ].join(),
);

Widget _flipHost({required bool revealed, required bool reduceMotion}) =>
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: gmBuildTheme(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
        child: child!,
      ),
      home: Scaffold(
        body: SizedBox.square(
          dimension: 120,
          child: GmMemoryTile(revealed: revealed, image: MemoryImage(_png)),
        ),
      ),
    );

const _back = ValueKey<String>('back');

final Finder tiles = find.bySemanticsLabel(RegExp(r', tile \d+$'));

void main() {
  group('reduced motion (GM-015)', () {
    testWidgets('tile flip is instant when the system asks for less motion', (
      tester,
    ) async {
      await tester.pumpWidget(_flipHost(revealed: false, reduceMotion: true));
      await tester.pumpWidget(_flipHost(revealed: true, reduceMotion: true));
      await tester.pump(const Duration(milliseconds: 16));
      expect(find.byKey(_back), findsNothing);
      expect(find.byKey(const ValueKey<String>('front')), findsOneWidget);
    });

    testWidgets('without the setting the flip animates (control case)', (
      tester,
    ) async {
      await tester.pumpWidget(_flipHost(revealed: false, reduceMotion: false));
      await tester.pumpWidget(_flipHost(revealed: true, reduceMotion: false));
      await tester.pump(const Duration(milliseconds: 16));
      expect(find.byKey(_back), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.byKey(_back), findsNothing);
    });
  });

  group('hidden cards keep their secrets (GM-014)', () {
    const pictures = [
      ActivityPicture(
        id: 'lake',
        label: 'Lake day',
        caption: 'Lake day',
        description: 'Two people on a wooden dock',
      ),
      ActivityPicture(
        id: 'cake',
        label: 'Birthday',
        caption: 'Birthday',
        description: 'A cake with candles',
      ),
    ];
    testWidgets('captions and descriptions stay out of the semantics tree', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        GentlePreferences.storageKey: jsonEncode(
          const GentlePreferences(keepVisible: false).toJson(),
        ),
      });
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: gmBuildTheme(),
          home: const GentleGamePage(pictures: pictures),
        ),
      );
      await tester.pumpAndSettle();

      expect(tiles, findsNWidgets(4));
      for (var i = 0; i < 4; i++) {
        expect(
          tester.getSemantics(tiles.at(i)).label,
          'Hidden picture, tile ${i + 1}',
        );
      }
      expect(find.bySemanticsLabel(RegExp('Lake day|Birthday')), findsNothing);
      expect(find.bySemanticsLabel(RegExp('dock|candles')), findsNothing);

      // Choosing a tile reveals only that tile, and only while it is chosen.
      await tester.tap(tiles.first);
      await tester.pump();
      final revealed = tester.getSemantics(tiles.first);
      expect(revealed.label, matches(RegExp(r'^(Lake day|Birthday), tile 1$')));
      expect(revealed.value, 'Selected');
      expect(
        find.bySemanticsLabel(RegExp('Hidden picture, tile [234]')),
        findsNWidgets(3),
      );
      // Descriptions are never part of the game, only of viewing.
      expect(find.bySemanticsLabel(RegExp('dock|candles')), findsNothing);
      handle.dispose();
    });
  });
}
