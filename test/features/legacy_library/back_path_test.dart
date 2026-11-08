import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/data/services/local_pack_service.dart';
import 'package:golden_moments/features/category/presentation/screens/category_page.dart';
import 'package:golden_moments/features/game/presentation/screens/game_page.dart';
import 'package:golden_moments/features/pack/presentation/screens/pack_page.dart';

import 'legacy_helpers.dart';

/// Every screen the participant can open from the library must offer a
/// visible Back control that returns to the screen below (DESIGN.md: keep
/// Back visible; Alzheimer's Society checklist 2.1 and 2.2, clear navigation).
/// A screen that hides Back would be a dead end, so this guards that path.
void main() {
  group('Back path from the picture library', () {
    testWidgets('category list has a Back control that returns', (
      tester,
    ) async {
      final categories = (await tester.runAsync(
        () => LocalPackService().getCategories(),
      ))!;
      await openPage(tester, CategoryPage(categories: categories));
      await _expectBackReturns(tester);
    });

    testWidgets('pack page has a Back control that returns', (tester) async {
      await tester.runAsync(() => LocalPackService().getPacksIndex());
      await openPage(
        tester,
        const PackPage(categoryId: 'animals', categoryName: 'Animals'),
      );
      await _expectBackReturns(tester);
    });

    testWidgets('a picture game has a Back control that returns', (
      tester,
    ) async {
      final pack = await bundledPack(tester, 'nature_mountains');
      await openPage(tester, GamePage(gamePack: pack));
      await _expectBackReturns(tester);
    });
  });
}

/// Exactly one Back control is shown, it is large enough to tap, and
/// tapping it returns to the [Launcher] screen below.
Future<void> _expectBackReturns(WidgetTester tester) async {
  final back = find.byTooltip('Back');
  expect(back, findsOneWidget);
  expect(
    tester.getSize(back).shortestSide,
    greaterThanOrEqualTo(48),
    reason: 'the Back control is a tap target of at least 48 px',
  );
  await tester.tap(back);
  await tester.pumpAndSettle();
  expect(find.text('Open'), findsOneWidget);
}
