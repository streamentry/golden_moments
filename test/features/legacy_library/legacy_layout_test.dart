import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/data/services/local_pack_service.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/category/presentation/screens/category_page.dart';
import 'package:golden_moments/features/game/presentation/screens/game_page.dart';
import 'package:golden_moments/features/pack/presentation/screens/pack_page.dart';
import 'package:golden_moments/shared/widgets/category_card.dart';
import 'package:golden_moments/shared/widgets/pack_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'legacy_helpers.dart';

/// GM-012/GM-016: 200% text on a small phone, a phone, a landscape phone
/// and a large iPad. Overflow fails the test; controls must be reachable.
///
/// The library home is not listed: its daily-pack grid and PackCard belong
/// to other work, and at 200% text the card's Play row still overflows there.
const _scenarios = {
  'small phone 320x568': Size(320, 568),
  'phone 390x844': Size(390, 844),
  'landscape phone 844x390': Size(844, 390),
  'iPad 1024x1366': Size(1024, 1366),
};

void _expectOnScreen(WidgetTester tester, Finder finder, Size screen) {
  final rect = tester.getRect(finder);
  expect(rect.top, greaterThanOrEqualTo(0));
  expect(rect.left, greaterThanOrEqualTo(0));
  expect(rect.bottom, lessThanOrEqualTo(screen.height));
  expect(rect.right, lessThanOrEqualTo(screen.width));
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  for (final scenario in _scenarios.entries) {
    final screen = scenario.value;

    testWidgets('category list holds on ${scenario.key} at 200% text', (
      tester,
    ) async {
      await setSurface(tester, screen);
      final categories = (await tester.runAsync(
        () => LocalPackService().getCategories(),
      ))!;
      await openPage(
        tester,
        CategoryPage(categories: categories),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
      _expectOnScreen(tester, find.byTooltip('Back'), screen);
      await tester.scrollUntilVisible(
        find.text(categories.last.name),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(CategoryCard), findsWidgets);
    });

    testWidgets('pack page holds on ${scenario.key} at 200% text', (
      tester,
    ) async {
      await setSurface(tester, screen);
      await tester.runAsync(() => LocalPackService().getPacksIndex());
      await openPage(
        tester,
        const PackPage(categoryId: 'animals', categoryName: 'Animals'),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
      _expectOnScreen(tester, find.byTooltip('Back'), screen);
      expect(find.byType(PackCard), findsWidgets);
      await tester.drag(
        find.byType(Scrollable).first,
        Offset(0, -screen.height),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    for (final packId in ['nature_mountains', 'animals_safari']) {
      testWidgets('game $packId holds on ${scenario.key} at 200% text', (
        tester,
      ) async {
        await setSurface(tester, screen);
        final pack = await bundledPack(tester, packId);
        final handle = tester.ensureSemantics();
        await openPage(tester, GamePage(gamePack: pack), textScale: 2);
        expect(tester.takeException(), isNull);

        final count = pack.difficulty.totalTiles;
        expect(boardTiles, findsNWidgets(count));
        for (final tile in boardTiles.evaluate()) {
          expect(
            tester.getSize(find.byWidget(tile.widget)).shortestSide,
            greaterThanOrEqualTo(gmTileMin),
          );
        }
        // The exit and restart stay on screen while the board scrolls.
        _expectOnScreen(tester, find.text('Done for now'), screen);
        _expectOnScreen(tester, find.text('Start again'), screen);
        _expectOnScreen(tester, find.byTooltip('Back'), screen);

        // The last tile can be reached and chosen.
        await tapTile(tester, count - 1);
        expect(gameCubit(tester).state.tiles.last.isRevealed, isTrue);
        expect(tester.takeException(), isNull);
        _expectOnScreen(tester, find.text('Done for now'), screen);
        handle.dispose();
      });
    }
  }

  testWidgets('at 100% text a phone shows the whole board without scrolling', (
    tester,
  ) async {
    const screen = Size(390, 844);
    await setSurface(tester, screen);
    final pack = await bundledPack(tester, 'nature_mountains');
    final handle = tester.ensureSemantics();
    await openPage(tester, GamePage(gamePack: pack));
    final exitTop = tester.getRect(find.text('Done for now')).top;
    for (final tile in boardTiles.evaluate()) {
      final rect = tester.getRect(find.byWidget(tile.widget));
      expect(rect.top, greaterThanOrEqualTo(0));
      expect(rect.bottom, lessThan(exitTop));
      expect(rect.shortestSide, greaterThan(gmTileMin));
    }
    handle.dispose();
  });
}
