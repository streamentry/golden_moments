import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/game/presentation/screens/game_page.dart';
import 'package:golden_moments/features/game/presentation/widgets/game_board.dart';
import 'package:golden_moments/features/game/presentation/widgets/game_exit_bar.dart';
import 'package:golden_moments/features/game/presentation/widgets/game_play_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/shipped_fonts.dart';
import 'legacy_helpers.dart';

void main() {
  // The shipped fonts, so widths are real rather than the test font's.
  setUpAll(loadShippedFonts);
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('board fit picks the largest tiles that fit', () {
    test('a short, wide space uses more columns for bigger tiles', () {
      final fit = GameBoard.fit(count: 12, size: const Size(672, 206));
      expect(fit.columns, 6);
      expect(fit.tile, 97);
    });

    test('a tall phone column keeps three columns', () {
      final fit = GameBoard.fit(count: 12, size: const Size(342, 600));
      expect(fit.columns, 3);
      expect(fit.tile, 106);
    });

    test('a board that cannot fit spreads its tiles evenly over the rows', () {
      // 12 tiles at the minimum size: 9 columns would leave 9 + 3; the same
      // two rows hold 6 + 6.
      final fit = GameBoard.fit(count: 12, size: const Size(700, 100));
      expect(fit.tile, gmTileMin);
      expect(fit.columns, 6);
    });

    test('a board that cannot fit stays at the minimum and scrolls least', () {
      final fit = GameBoard.fit(count: 40, size: const Size(272, 100));
      expect(fit.tile, gmTileMin);
      expect(fit.columns, 3);
    });
  });

  testWidgets('landscape phone at 200% text: a slim exit bar and the largest '
      'board that fits', (tester) async {
    const screen = Size(844, 390);
    await setSurface(tester, screen);
    final pack = await bundledPack(tester, 'nature_mountains');
    final handle = tester.ensureSemantics();
    await openPage(tester, GamePage(gamePack: pack), textScale: 2);
    expect(tester.takeException(), isNull);

    // Both buttons fit on one line each, so they sit side by side.
    final done = tester.getRect(
      find.widgetWithText(OutlinedButton, 'Done for now'),
    );
    final again = tester.getRect(
      find.widgetWithText(OutlinedButton, 'Start again'),
    );
    expect(done.top, again.top);
    final bar = tester.getRect(find.byType(GameExitBar));
    expect(bar.height, lessThanOrEqualTo(screen.height * 0.4));

    // The board gets the whole space above the bar, minus the page padding,
    // and every tile is on screen without scrolling.
    final body = tester.getRect(find.byType(GamePlayView));
    final width = body.width.clamp(0, gmContentMaxWidth) - gmSpaceLg * 2;
    final expected = GameBoard.fit(
      count: pack.difficulty.totalTiles,
      size: Size(width, body.height - gmSpaceMd * 2),
    );
    expect(expected.tile, greaterThan(gmTileMin));
    expect(boardTiles, findsNWidgets(pack.difficulty.totalTiles));
    for (final tile in boardTiles.evaluate()) {
      final rect = tester.getRect(find.byWidget(tile.widget));
      expect(rect.width, expected.tile);
      expect(rect.top, greaterThanOrEqualTo(body.top));
      expect(rect.bottom, lessThanOrEqualTo(bar.top));
    }
    handle.dispose();
  });
}
