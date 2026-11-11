import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/app/view/pack_game_native.dart';
import 'package:golden_moments/data/models/pack.dart';
import 'package:golden_moments/features/game/game.dart';
import 'package:golden_moments/features/gentle_activities/presentation/gentle_game_page.dart';
import 'package:golden_moments/l10n/pack_text.dart';
import 'package:golden_moments/shared/widgets/pack_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../legacy_library/legacy_helpers.dart';

Finder get _tiles => find.bySemanticsLabel(RegExp(r', tile \d+$'));
Finder get _hiddenTiles =>
    find.bySemanticsLabel(RegExp(r'^Hidden picture, tile \d+$'));

/// A pack card on its own page, as the library shows it.
class _CardPage extends StatelessWidget {
  const new(this.pack);

  final Pack pack;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SingleChildScrollView(child: PackCard(pack: pack)),
  );
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(() => debugPackGamesOnGentleBoard = null);

  testWidgets('on mobile a pack opens on the gentle board, pictures in view', (
    tester,
  ) async {
    debugPackGamesOnGentleBoard = true;
    final handle = tester.ensureSemantics();
    await setSurface(tester, const Size(390, 844));
    final pack = await bundledPack(tester, 'animals_farm');
    await openPage(tester, _CardPage(pack));

    await tester.tap(find.text('Farm Animals'));
    await tester.pumpAndSettle();

    final page = tester.widget<GentleGamePage>(find.byType(GentleGamePage));
    expect(page.sessionKey, 'pack-animals_farm');
    expect(page.pictures, hasLength(pack.images.length));
    // Named for the pack, with the same defaults as every gentle board:
    // four visible pictures, comfort settings, and no hidden tiles, pair
    // counter or hint ladder (product story G2).
    expect(find.text('Farm Animals'), findsOneWidget);
    expect(_tiles, findsNWidgets(4));
    expect(_hiddenTiles, findsNothing);
    expect(find.text('Comfort settings'), findsOneWidget);
    expect(find.text('Done for now'), findsOneWidget);
    expect(find.textContaining(RegExp(r'\d+ of \d+ pairs')), findsNothing);
    expect(find.text('Show a matching pair'), findsNothing);
    expect(find.byType(GamePage), findsNothing);
    handle.dispose();
  });

  testWidgets('elsewhere a pack keeps the picture-pack game', (tester) async {
    debugPackGamesOnGentleBoard = false;
    await setSurface(tester, const Size(390, 844));
    final pack = await bundledPack(tester, 'animals_farm');
    await openPage(tester, _CardPage(pack));

    await tester.tap(find.text('Farm Animals'));
    await tester.pumpAndSettle();

    expect(find.byType(GamePage), findsOneWidget);
    expect(find.byType(GentleGamePage), findsNothing);
  });

  testWidgets('pack pictures keep their photos and translated names', (
    tester,
  ) async {
    final pack = await bundledPack(tester, 'animals_farm');
    final pictures = packPictures(pack, PackText.english);
    expect(pictures, hasLength(pack.images.length));
    for (final (i, picture) in pictures.indexed) {
      final image = pack.images[i];
      expect(picture.asset, image.url);
      expect(picture.path, isNull);
      expect(picture.id, 'animals_farm/${image.id}');
      expect(picture.label, image.caption);
    }
    // Ids are unique, so a saved board restores the right pictures.
    expect({for (final p in pictures) p.id}, hasLength(pictures.length));
  });
}
