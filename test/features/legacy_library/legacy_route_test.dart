import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/data/models/category.dart';
import 'package:golden_moments/data/models/sound_setting.dart';
import 'package:golden_moments/data/services/local_pack_service.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/category/presentation/screens/category_page.dart';
import 'package:golden_moments/features/game/cubit/game_state.dart';
import 'package:golden_moments/features/game/presentation/screens/game_page.dart';
import 'package:golden_moments/features/game/presentation/widgets/game_header.dart';
import 'package:golden_moments/features/pack/presentation/screens/pack_page.dart';
import 'package:golden_moments/shared/widgets/category_card.dart';
import 'package:golden_moments/shared/widgets/pressable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'legacy_helpers.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('quiet by default (GM-003/GM-015)', () {
    test(
      'a fresh install has music and sounds off and stores nothing',
      () async {
        final settings = SoundSettings();
        expect(settings.isMusicOn, isFalse);
        expect(settings.isSoundOn, isFalse);
        await settings.load();
        expect(settings.isMusicOn, isFalse);
        expect(settings.isSoundOn, isFalse);
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getKeys(), isEmpty);
      },
    );

    for (final saved in [true, false]) {
      test('an earlier explicit choice ($saved) is kept as it is', () async {
        SharedPreferences.setMockInitialValues({
          SoundSettings.musicKey: saved,
          SoundSettings.soundKey: saved,
        });
        final settings = SoundSettings();
        await settings.load();
        expect(settings.isMusicOn, saved);
        expect(settings.isSoundOn, saved);
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool(SoundSettings.musicKey), saved);
        expect(prefs.getBool(SoundSettings.soundKey), saved);
      });
    }

    test('turning one on saves only that choice', () async {
      final settings = SoundSettings();
      await settings.load();
      settings.toggleSound();
      await Future<void>.delayed(Duration.zero);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(SoundSettings.soundKey), isTrue);
      expect(prefs.containsKey(SoundSettings.musicKey), isFalse);
      expect(settings.isMusicOn, isFalse);
    });
  });

  group('reduced motion (GM-015)', () {
    testWidgets('pressable surfaces drop the ripple when motion is reduced', (
      tester,
    ) async {
      for (final reduce in [true, false]) {
        await tester.pumpWidget(
          legacyApp(
            Pressable(onPressed: () {}, child: const Text('Press')),
            reduceMotion: reduce,
          ),
        );
        final ink = tester.widget<InkWell>(find.byType(InkWell));
        expect(
          ink.splashFactory,
          reduce ? same(NoSplash.splashFactory) : isNull,
          reason: 'reduceMotion: $reduce',
        );
      }
    });

    testWidgets('a category card opens at once, with no artificial delay', (
      tester,
    ) async {
      var opened = 0;
      await tester.pumpWidget(
        legacyApp(
          Scaffold(
            body: CategoryCard(
              category: const Category(
                id: 'nature',
                name: 'Nature',
                description: 'Hills and rivers',
                iconUrl: 'assets/missing.png',
                packCount: 1,
              ),
              onTap: () => opened++,
            ),
          ),
          reduceMotion: true,
        ),
      );
      await tester.tap(find.text('Nature'));
      // No pump: the tap itself navigates, and no timer is left pending.
      expect(opened, 1);
    });

    testWidgets('a category card is one button for a screen reader', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        legacyApp(
          Scaffold(
            body: CategoryCard(
              category: const Category(
                id: 'nature',
                name: 'Nature',
                description: 'Hills and rivers',
                iconUrl: 'assets/missing.png',
                packCount: 1,
              ),
              onTap: () {},
            ),
          ),
        ),
      );
      final buttons = find.semantics.byPredicate(
        (node) =>
            node.flagsCollection.isButton && node.label.contains('Nature'),
      );
      expect(buttons, findsOne);
      handle.dispose();
    });

    testWidgets('a tile turns over instantly on the board', (tester) async {
      final pack = await bundledPack(tester, 'nature_mountains');
      final handle = tester.ensureSemantics();
      await openPage(tester, GamePage(gamePack: pack), reduceMotion: true);
      await tester.tap(boardTile(1));
      // Two frames with no time passing: the picture is fully shown and its
      // back face is gone, so nothing turned or slid.
      await tester.pump();
      await tester.pump();
      expect(find.byKey(const ValueKey('front')), findsOneWidget);
      expect(find.byKey(const ValueKey('back')), findsNWidgets(11));
      handle.dispose();
    });
  });

  group('hidden tiles keep their secrets (GM-014)', () {
    testWidgets('hidden tiles expose only their position', (tester) async {
      final pack = await bundledPack(tester, 'nature_mountains');
      final secrets = RegExp(
        [
          for (final image in pack.images) ...[
            RegExp.escape(image.caption),
            RegExp.escape(image.id),
            RegExp.escape(image.url),
          ],
          'assets/',
          r'\.jpe?g',
          'pair_',
        ].join('|'),
      );
      final handle = tester.ensureSemantics();
      await openPage(tester, GamePage(gamePack: pack));

      expect(boardTiles, findsNWidgets(12));
      for (var i = 1; i <= 12; i++) {
        expect(
          tester.getSemantics(boardTile(i)),
          isSemantics(
            label: 'Hidden picture, tile $i',
            value: '',
            isButton: true,
            hasEnabledState: true,
            isEnabled: true,
            hasTapAction: true,
          ),
        );
      }
      expect(find.bySemanticsLabel(secrets), findsNothing);

      // Choosing a tile reveals only that tile, by its picture's name.
      final cubit = gameCubit(tester);
      final first = cubit.state.tiles[0];
      await tapTile(tester, 0);
      expect(
        tester.getSemantics(boardTile(1)),
        isSemantics(
          label: '${first.image.caption}, tile 1',
          value: 'Selected',
          isButton: true,
        ),
      );
      expect(
        find.bySemanticsLabel(RegExp(r'^Hidden picture, tile \d+$')),
        findsNWidgets(11),
      );

      // A mismatch stays face up; the next tap turns it over and the names
      // leave the tree again, even while the flip is still animating.
      final stranger = strangerOf(cubit, 0);
      await tapTile(tester, stranger);
      expect(cubit.state.showingMismatch, isTrue);
      // "Tap a picture to continue" includes the face-up pair itself.
      expect(
        tester.getSemantics(boardTile(1)),
        isSemantics(value: 'Selected', isEnabled: true, hasTapAction: true),
      );
      final third = List.generate(
        12,
        (i) => i,
      ).firstWhere((i) => i != 0 && i != stranger);
      await tester.tap(boardTile(third + 1));
      await tester.pump(const Duration(milliseconds: 16));
      expect(tester.getSemantics(boardTile(1)).label, 'Hidden picture, tile 1');
      expect(
        tester.getSemantics(boardTile(stranger + 1)).label,
        'Hidden picture, tile ${stranger + 1}',
      );
      await tester.pumpAndSettle();
      handle.dispose();
    });

    testWidgets('matched tiles are announced as Matched and cannot be chosen', (
      tester,
    ) async {
      final pack = await bundledPack(tester, 'nature_mountains');
      final handle = tester.ensureSemantics();
      await openPage(tester, GamePage(gamePack: pack));
      final cubit = gameCubit(tester);
      final partner = partnerOf(cubit, 0);
      await tapTile(tester, 0);
      await tapTile(tester, partner);
      for (final index in [0, partner]) {
        expect(
          tester.getSemantics(boardTile(index + 1)),
          isSemantics(
            label:
                '${cubit.state.tiles[index].image.caption}, tile ${index + 1}',
            value: 'Matched',
            isButton: true,
            hasEnabledState: true,
            isEnabled: false,
          ),
        );
      }
      handle.dispose();
    });
  });

  group('a visible way out (GM-002)', () {
    testWidgets('the game has Done for now on screen and it simply leaves', (
      tester,
    ) async {
      final pack = await bundledPack(tester, 'nature_mountains');
      await openPage(tester, GamePage(gamePack: pack));
      final done = find.widgetWithText(OutlinedButton, 'Done for now');
      expect(done, findsOneWidget);
      expect(
        tester.getSize(done).height,
        greaterThanOrEqualTo(gmTargetPrimary),
      );
      await tester.tap(done);
      await tester.pumpAndSettle();
      expect(find.text('Open'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('Start again asks first, and Keep this board keeps it', (
      tester,
    ) async {
      final pack = await bundledPack(tester, 'nature_mountains');
      final handle = tester.ensureSemantics();
      await openPage(tester, GamePage(gamePack: pack));
      final cubit = gameCubit(tester);
      await tapTile(tester, 0);
      await tapTile(tester, partnerOf(cubit, 0));
      final board = cubit.state.tiles;

      await tester.tap(find.widgetWithText(OutlinedButton, 'Start again'));
      await tester.pumpAndSettle();
      expect(find.text('Start again?'), findsOneWidget);
      await tester.tap(find.text('Keep this board'));
      await tester.pumpAndSettle();
      expect(cubit.state.tiles, board);
      expect(cubit.state.matchedPairs, 1);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Start again'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Start again'));
      await tester.pumpAndSettle();
      expect(cubit.state.matchedPairs, 0);
      handle.dispose();
    });

    testWidgets('one turned-over picture is not progress: Start again needs '
        'no question', (tester) async {
      final pack = await bundledPack(tester, 'nature_mountains');
      final handle = tester.ensureSemantics();
      await openPage(tester, GamePage(gamePack: pack));
      final cubit = gameCubit(tester);
      await tapTile(tester, 0);
      expect(cubit.state.selectedTiles, hasLength(1));

      await tester.tap(find.widgetWithText(OutlinedButton, 'Start again'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(cubit.state.selectedTiles, isEmpty);
      expect(cubit.state.tiles.where((tile) => tile.isRevealed), isEmpty);
      handle.dispose();
    });

    testWidgets('closing Options with system Back returns to a live board', (
      tester,
    ) async {
      final pack = await bundledPack(tester, 'nature_mountains');
      await openPage(tester, GamePage(gamePack: pack));
      await tester.tap(find.byTooltip('Sound and options'));
      await tester.pumpAndSettle();
      expect(find.text('Options'), findsOneWidget);
      // Quiet by default, shown as switches that are off.
      final switches = tester.widgetList<SwitchListTile>(
        find.byType(SwitchListTile),
      );
      expect(switches.map((s) => s.value), [false, false]);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Options'), findsNothing);
      expect(gameCubit(tester).state.status, GameStatus.playing);
    });

    testWidgets('finishing offers Play again and another pack, never a rating '
        'or a score', (tester) async {
      final pack = await bundledPack(tester, 'nature_mountains');
      final handle = tester.ensureSemantics();
      await openPage(tester, GamePage(gamePack: pack));
      final cubit = gameCubit(tester);
      // A mismatch first, so the internal move count is not zero.
      await tapTile(tester, 0);
      await tapTile(tester, strangerOf(cubit, 0));
      for (var i = 0; i < cubit.state.tiles.length; i++) {
        if (cubit.state.tiles[i].isMatched) continue;
        await tapTile(tester, i);
        await tapTile(tester, partnerOf(cubit, i));
      }
      expect(cubit.state.status, GameStatus.completed);
      expect(cubit.state.moves, greaterThan(12));
      expect(find.text('All pairs together'), findsOneWidget);
      // As on the gentle board, Play again is the one primary action.
      expect(find.widgetWithText(FilledButton, 'Play again'), findsOneWidget);
      expect(
        find.widgetWithText(OutlinedButton, 'Choose another pack'),
        findsOneWidget,
      );
      expect(find.textContaining(scoreLike, findRichText: true), findsNothing);
      expect(find.bySemanticsLabel(scoreLike), findsNothing);
      handle.dispose();
    });

    testWidgets('category and pack pages keep a labelled Back', (tester) async {
      final categories = (await tester.runAsync(
        () => LocalPackService().getCategories(),
      ))!;
      await openPage(tester, CategoryPage(categories: categories));
      expect(find.byTooltip('Back'), findsOneWidget);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Open'), findsOneWidget);

      await openPage(
        tester,
        const PackPage(categoryId: 'nature', categoryName: 'Nature'),
      );
      expect(find.byTooltip('Back'), findsOneWidget);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Open'), findsOneWidget);
    });
  });

  group('a match is announced once, in the header (GM-014)', () {
    Finder status(String text) => find.bySemanticsLabel(text);

    testWidgets('a match is a polite live status; hidden tiles stay hidden', (
      tester,
    ) async {
      final pack = await bundledPack(tester, 'nature_mountains');
      final handle = tester.ensureSemantics();
      await openPage(tester, GamePage(gamePack: pack));
      final cubit = gameCubit(tester);

      // Nothing has happened yet: the instruction is not a live region.
      expect(
        tester.getSemantics(status(GameHeader.instruction)),
        isSemantics(isLiveRegion: false),
      );

      final partner = partnerOf(cubit, 0);
      await tapTile(tester, 0);
      await tapTile(tester, partner);
      expect(
        tester.getSemantics(status('These two match.')),
        isSemantics(label: 'These two match.', isLiveRegion: true),
      );
      // No per-tile announcement, and no praise anywhere.
      expect(status('These two match.'), findsOneWidget);
      expect(
        find.textContaining(
          RegExp('great|well done|congrat|amazing|!', caseSensitive: false),
        ),
        findsNothing,
      );
      // The other ten tiles still expose only their position, and no other
      // picture's name is in the tree.
      expect(
        find.bySemanticsLabel(RegExp(r'^Hidden picture, tile \d+$')),
        findsNWidgets(10),
      );
      final matchedCaption = cubit.state.tiles[0].image.caption;
      final others = [
        for (final image in pack.images)
          if (image.caption != matchedCaption) RegExp.escape(image.caption),
      ];
      expect(
        find.bySemanticsLabel(RegExp('(${others.join('|')})')),
        findsNothing,
      );

      // The next tap ends the news; the instruction returns quietly.
      final next = List.generate(
        12,
        (i) => i,
      ).firstWhere((i) => i != 0 && i != partner);
      await tapTile(tester, next);
      expect(status('These two match.'), findsNothing);
      expect(
        tester.getSemantics(status(GameHeader.instruction)),
        isSemantics(isLiveRegion: false),
      );
      handle.dispose();
    });
  });

  testWidgets('no move count, clock or score is shown during play (GM-015)', (
    tester,
  ) async {
    final pack = await bundledPack(tester, 'nature_mountains');
    final handle = tester.ensureSemantics();
    await openPage(tester, GamePage(gamePack: pack));
    final cubit = gameCubit(tester);
    await tapTile(tester, 0);
    await tapTile(tester, strangerOf(cubit, 0));
    await tapTile(tester, 0);
    await tapTile(tester, partnerOf(cubit, 0));
    expect(cubit.state.moves, 4);
    expect(find.textContaining(scoreLike, findRichText: true), findsNothing);
    expect(find.bySemanticsLabel(scoreLike), findsNothing);
    expect(find.textContaining('4'), findsNothing);
    handle.dispose();
  });
}
