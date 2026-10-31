import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/data/services/local_pack_service.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/l10n/l10n.dart';
import 'package:golden_moments/shared/widgets/category_card.dart';
import 'package:golden_moments/shared/widgets/pack_card.dart';

Widget _app(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  theme: gmBuildTheme(),
  home: Scaffold(
    body: SingleChildScrollView(
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    ),
  ),
);

/// The picture's frame inside its card, as a print mounted in an album
/// (DESIGN.md › Signature details): a print-white mat with a hairline sits
/// `sm` inside the card, and the picture sits `mat` inside it behind a
/// rounded clip, with corners stepping down 16 → 8 → 4.
void _expectMounted(WidgetTester tester, Finder card) {
  final cardRect = tester.getRect(card);
  final image = find.descendant(of: card, matching: find.byType(Image));
  final rect = tester.getRect(image);
  final mat = find.ancestor(
    of: image,
    matching: find.byWidgetPredicate(
      (w) =>
          w is DecoratedBox &&
          w.decoration is ShapeDecoration &&
          (w.decoration as ShapeDecoration).color == gmSurfRaised,
    ),
  );
  expect(mat, findsOneWidget);
  final matRect = tester.getRect(mat);
  expect(matRect.left - cardRect.left, greaterThanOrEqualTo(gmSpaceSm));
  expect(matRect.top - cardRect.top, greaterThanOrEqualTo(gmSpaceSm));
  expect(rect.left - matRect.left, greaterThanOrEqualTo(gmMatInset));
  expect(rect.top - matRect.top, greaterThanOrEqualTo(gmMatInset));
  final shape =
      (tester.widget<DecoratedBox>(mat).decoration as ShapeDecoration).shape
          as RoundedRectangleBorder;
  expect(shape.borderRadius, BorderRadius.circular(gmRadiusMd));
  expect(shape.side.width, 1);
  final clip = tester.widget<ClipRRect>(
    find.ancestor(of: image, matching: find.byType(ClipRRect)).first,
  );
  expect(clip.borderRadius, BorderRadius.circular(gmRadiusSm));
  // Decoded at the size it is shown, not at the file's full size.
  expect(tester.widget<Image>(image).image, isA<ResizeImage>());
}

void main() {
  testWidgets('a pack card mounts its cover like a print and leads with a '
      'larger title', (tester) async {
    final pack = (await tester.runAsync(
      () => LocalPackService().getPackById('animals_farm'),
    ))!;
    await tester.pumpWidget(_app(PackCard(pack: pack)));
    await tester.pumpAndSettle();
    _expectMounted(tester, find.byType(Card));
    final title = tester.widget<Text>(find.text(pack.title));
    expect(title.style?.fontSize, 24);
  });

  testWidgets('choices sit in a footer under a hairline, only when offered', (
    tester,
  ) async {
    final pack = (await tester.runAsync(
      () => LocalPackService().getPackById('animals_farm'),
    ))!;
    await tester.pumpWidget(_app(PackCard(pack: pack)));
    await tester.pumpAndSettle();
    expect(find.byType(Divider), findsNothing);

    await tester.pumpWidget(
      _app(PackCard(pack: pack, onFavoriteChanged: (_) {}, onNotForMe: () {})),
    );
    await tester.pumpAndSettle();
    final divider = tester.getRect(find.byType(Divider));
    expect(
      divider.top,
      greaterThan(tester.getRect(find.text(pack.title)).bottom),
    );
    expect(
      divider.bottom,
      lessThanOrEqualTo(tester.getRect(find.text('Add to favorites')).top),
    );
  });

  testWidgets('a topic card mounts its picture the same way', (tester) async {
    final categories = (await tester.runAsync(
      () => LocalPackService().getCategories(),
    ))!;
    final animals = categories.firstWhere((c) => c.id == 'animals');
    await tester.pumpWidget(_app(CategoryCard(category: animals)));
    await tester.pumpAndSettle();
    _expectMounted(tester, find.byType(Card));
  });
}
