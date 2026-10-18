import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/home/cubit/home_cubit.dart';
import 'package:golden_moments/features/home/data/interest_preferences.dart';
import 'package:golden_moments/features/home/data/pack_preferences.dart';
import 'package:golden_moments/features/home/presentation/screens/home_page.dart';
import 'package:golden_moments/features/pack/presentation/screens/pack_page.dart';
import 'package:golden_moments/shared/widgets/category_card.dart';
import 'package:golden_moments/shared/widgets/pack_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pack_fixtures.dart';

HomeCubit _cubit({PackPreferencesStore store = const PackPreferencesStore()}) =>
    HomeCubit(preferencesStore: store, loadCatalog: loadFixtureCatalog);

Future<HomeCubit> _pumpHome(
  WidgetTester tester, {
  double textScale = 1,
  PackPreferencesStore store = const PackPreferencesStore(),
}) async {
  final cubit = _cubit(store: store);
  addTearDown(cubit.close);
  await tester.pumpWidget(
    MaterialApp(
      theme: gmBuildTheme(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: BlocProvider.value(value: cubit, child: const HomeView()),
    ),
  );
  await cubit.initialize();
  await tester.pumpAndSettle();
  return cubit;
}

Finder _key(String key) => find.byKey(ValueKey(key));
Finder _chip(String name) => find.widgetWithText(FilterChip, name);
Finder _topicCard(String name) =>
    find.descendant(of: find.byType(CategoryCard), matching: find.text(name));

Future<void> _tapKey(WidgetTester tester, String key) async {
  await tester.ensureVisible(_key(key));
  await tester.pumpAndSettle();
  await tester.tap(_key(key));
  await tester.pumpAndSettle();
}

Future<void> _tapFinder(WidgetTester tester, Finder target) async {
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('suggestions are labelled honestly and start nothing', (
    tester,
  ) async {
    await _pumpHome(tester);
    expect(find.text('Suggested packs'), findsOneWidget);
    expect(find.text('Daily'), findsNothing);
    expect(find.textContaining('today'), findsNothing);
    expect(find.textContaining('every day'), findsNothing);
    expect(find.textContaining('tomorrow'), findsNothing);
    // Still home: nothing was launched.
    expect(find.byType(HomeView), findsOneWidget);
    expect(_key('suggested-farm'), findsOneWidget);
    expect(find.text('Your favorites'), findsNothing);
    expect(find.textContaining('Hidden packs'), findsNothing);
  });

  testWidgets('Favorite is a labelled toggle that moves the pack first and '
      'is remembered', (tester) async {
    await _pumpHome(tester);
    final toggle = _key('favorite-farm');
    expect(
      find.descendant(of: toggle, matching: find.byIcon(Icons.star_border)),
      findsOneWidget,
    );
    expect(
      find.descendant(of: toggle, matching: find.text('Add to favorites')),
      findsOneWidget,
    );
    expect(
      tester.getSemantics(toggle),
      isSemantics(
        label: 'Add to favorites, Farm Animals',
        isButton: true,
        hasToggledState: true,
        isToggled: false,
        hasTapAction: true,
      ),
    );

    await _tapKey(tester, 'favorite-farm');
    expect(find.text('Your favorites'), findsOneWidget);
    expect(_key('favorite-card-farm'), findsOneWidget);
    expect(_key('suggested-farm'), findsNothing);
    final filled = _key('favorite-farm');
    expect(
      find.descendant(of: filled, matching: find.byIcon(Icons.star)),
      findsOneWidget,
    );
    // The words change too, so the state is never shown by fill alone.
    expect(
      find.descendant(of: filled, matching: find.text('In favorites')),
      findsOneWidget,
    );
    expect(
      tester.getSemantics(filled),
      isSemantics(
        label: 'In favorites, Farm Animals',
        isButton: true,
        hasToggledState: true,
        isToggled: true,
        hasTapAction: true,
      ),
    );
    // Favorites come before suggestions on the page.
    expect(
      tester.getTopLeft(find.text('Your favorites')).dy,
      lessThan(tester.getTopLeft(find.text('Suggested packs')).dy),
    );

    // Restart: still a favorite.
    await tester.pumpWidget(const SizedBox());
    await _pumpHome(tester);
    expect(_key('favorite-card-farm'), findsOneWidget);

    await _tapKey(tester, 'favorite-farm');
    expect(find.text('Your favorites'), findsNothing);
    expect(await savedChoices(), const PackPreferences());
  });

  testWidgets('Not for me hides a pack with a lasting Show again', (
    tester,
  ) async {
    await _pumpHome(tester);
    await _tapKey(tester, 'not-for-me-farm');

    expect(_key('suggested-farm'), findsNothing);
    expect(find.byType(SnackBar), findsNothing);
    expect(find.text('Hidden packs (1)'), findsOneWidget);
    expect(_key('hidden-farm'), findsOneWidget);
    // The next pack fills in; the rest keep their order.
    expect(_key('suggested-desserts'), findsOneWidget);

    // A lasting note says where it went, is announced politely, and takes
    // keyboard focus from the button that disappeared.
    final notice = _key('hidden-notice-farm');
    expect(notice, findsOneWidget);
    expect(find.textContaining('Farm Animals is hidden'), findsOneWidget);
    expect(tester.getSemantics(notice), isSemantics(isLiveRegion: true));
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'hidden-notice');
    await tester.pump(const Duration(minutes: 5));
    expect(notice, findsOneWidget);

    // Still there after time passes and after a restart.
    await tester.pump(const Duration(minutes: 5));
    await tester.pumpWidget(const SizedBox());
    await _pumpHome(tester);
    expect(find.text('Hidden packs (1)'), findsOneWidget);
    expect(_key('suggested-farm'), findsNothing);

    await _tapKey(tester, 'show-again-farm');
    expect(find.textContaining('Hidden packs'), findsNothing);
    expect(_key('suggested-farm'), findsOneWidget);
    expect(await savedChoices(), const PackPreferences());
  });

  testWidgets('the note after Not for me can show the pack again', (
    tester,
  ) async {
    await _pumpHome(tester);
    await _tapKey(tester, 'not-for-me-farm');
    await _tapKey(tester, 'undo-hide-farm');
    expect(_key('hidden-notice-farm'), findsNothing);
    expect(_key('suggested-farm'), findsOneWidget);
    expect(await savedChoices(), const PackPreferences());
  });

  testWidgets('card actions keep at least 8 between targets', (tester) async {
    for (final width in [800.0, 320.0]) {
      await tester.binding.setSurfaceSize(Size(width, 900));
      await _pumpHome(tester, textScale: width < 400 ? 2 : 1);
      final favorite = tester.getRect(_key('favorite-farm'));
      final hide = tester.getRect(_key('not-for-me-farm'));
      final sideBySide = (hide.top - favorite.top).abs() < 1;
      final gap = sideBySide
          ? hide.left - favorite.right
          : hide.top - favorite.bottom;
      expect(gap, greaterThanOrEqualTo(gmSpaceSm), reason: 'width $width');
      final card = tester.getRect(_key('suggested-farm'));
      final play = tester.getRect(
        find.descendant(
          of: _key('suggested-farm'),
          matching: find.text('Play'),
        ),
      );
      expect(card.contains(play.center), isTrue);
      expect(
        favorite.top - play.bottom,
        greaterThanOrEqualTo(gmSpaceSm),
        reason: 'gap above the actions at width $width',
      );
      await tester.pumpWidget(const SizedBox());
    }
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('a saved record that cannot be read is kept, never replaced', (
    tester,
  ) async {
    const newer = '{"v":2,"hidden":["farm"],"later":true}';
    SharedPreferences.setMockInitialValues({PackPreferences.storageKey: newer});
    await _pumpHome(tester);
    expect(find.textContaining('could not be read'), findsOneWidget);
    expect(find.text('Add to favorites'), findsNothing);
    expect(find.text('Not for me'), findsNothing);
    // The library still opens.
    expect(_key('suggested-farm'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(PackPreferences.storageKey), newer);
  });

  testWidgets('a hidden favorite is only in Hidden packs until shown again', (
    tester,
  ) async {
    await _pumpHome(tester);
    await _tapKey(tester, 'favorite-safari');
    expect(_key('favorite-card-safari'), findsOneWidget);
    await _tapKey(tester, 'not-for-me-safari');

    expect(find.text('Your favorites'), findsNothing);
    expect(_key('suggested-safari'), findsNothing);
    expect(
      find.descendant(
        of: _key('hidden-safari'),
        matching: find.text('In favorites'),
      ),
      findsOneWidget,
    );

    await _tapKey(tester, 'show-again-safari');
    expect(_key('favorite-card-safari'), findsOneWidget);
  });

  testWidgets('a topic whose packs are all hidden explains and offers every '
      'topic without unhiding', (tester) async {
    await _pumpHome(tester);
    await _tapKey(tester, 'not-for-me-cars');
    await _tapFinder(tester, _chip('Vintage'));

    expect(find.text('Nothing to show for these topics'), findsOneWidget);
    final showAll = find.widgetWithText(OutlinedButton, 'Show all topics');
    expect(showAll, findsOneWidget);

    await tester.ensureVisible(showAll);
    await tester.pumpAndSettle();
    await tester.tap(showAll);
    await tester.pumpAndSettle();

    expect(find.text('Nothing to show for these topics'), findsNothing);
    expect(await const InterestStore().load(), isEmpty);
    expect(find.text('Hidden packs (1)'), findsOneWidget);
    expect((await savedChoices()).isHidden('cars'), isTrue);
  });

  testWidgets('a topic page leaves hidden packs out and can show them again', (
    tester,
  ) async {
    await _pumpHome(tester);
    await _tapFinder(tester, _topicCard('Nature'));
    expect(find.byType(PackPage), findsOneWidget);
    expect(_key('pack-mountains'), findsOneWidget);
    expect(_key('pack-lakes'), findsOneWidget);

    await _tapKey(tester, 'not-for-me-lakes');
    expect(_key('pack-lakes'), findsNothing);
    expect(find.text('Hidden packs (1)'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    // The home screen shares the same choice at once.
    expect(find.text('Hidden packs (1)'), findsOneWidget);
    expect(_key('hidden-lakes'), findsOneWidget);
  });

  testWidgets('a topic page with every pack hidden says so', (tester) async {
    await const PackPreferencesStore().save(
      const PackPreferences().withHidden('cars', hide: true),
    );
    final cubit = _cubit();
    addTearDown(cubit.close);
    await tester.pumpWidget(
      MaterialApp(
        theme: gmBuildTheme(),
        home: PackPage(
          categoryId: 'vintage',
          categoryName: 'Vintage',
          library: cubit,
        ),
      ),
    );
    await cubit.initialize();
    await tester.pumpAndSettle();
    expect(find.textContaining('Every pack in this topic'), findsOneWidget);
    await _tapKey(tester, 'show-again-cars');
    expect(_key('pack-cars'), findsOneWidget);
  });

  testWidgets('no pack is shown until the saved choices are known', (
    tester,
  ) async {
    final store = GatedPackStore(
      const PackPreferences().withHidden('farm', hide: true),
    );
    final cubit = _cubit(store: store);
    addTearDown(cubit.close);
    await tester.pumpWidget(
      MaterialApp(
        theme: gmBuildTheme(),
        home: BlocProvider.value(value: cubit, child: const HomeView()),
      ),
    );
    final done = cubit.initialize();
    await tester.pump(HomeCubit.preferencesGrace);
    await tester.pumpAndSettle();
    // Topics only: the hidden "farm" pack can never flash up.
    expect(find.byType(PackCard), findsNothing);
    expect(find.textContaining('Getting your saved favorites'), findsOneWidget);
    expect(_chip('Animals'), findsOneWidget);

    // A topic page waits too.
    await tester.ensureVisible(_topicCard('Animals'));
    await tester.pumpAndSettle();
    await tester.tap(_topicCard('Animals'));
    // The spinner keeps animating, so step time instead of settling.
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(PackPage), findsOneWidget);
    expect(find.byType(PackCard), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    store.release();
    await done;
    await tester.pumpAndSettle();
    expect(_key('pack-safari'), findsOneWidget);
    expect(_key('pack-farm'), findsNothing);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(_key('suggested-farm'), findsNothing);
    expect(_key('favorite-mountains'), findsOneWidget);
    expect(find.text('Hidden packs (1)'), findsOneWidget);
  });

  testWidgets('a choice that cannot be saved says so calmly', (tester) async {
    await _pumpHome(tester, store: const FailingPackStore());
    await _tapKey(tester, 'not-for-me-farm');
    expect(find.textContaining('could not be saved'), findsOneWidget);
    expect(find.text('Hidden packs (1)'), findsOneWidget);
  });

  testWidgets('Suggest other packs moves only when asked', (tester) async {
    await _pumpHome(tester);
    expect(_key('suggested-desserts'), findsNothing);
    await _tapFinder(tester, find.text('Suggest other packs'));
    expect(_key('suggested-desserts'), findsOneWidget);
    expect(_key('suggested-lakes'), findsOneWidget);
  });

  testWidgets('favorite, hide and show again work at 200% text on a small '
      'phone', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await _pumpHome(tester, textScale: 2);
    expect(tester.takeException(), isNull);

    final favorite = _key('favorite-farm');
    await tester.ensureVisible(favorite);
    await tester.pumpAndSettle();
    expect(tester.getSize(favorite).height, greaterThanOrEqualTo(gmTargetMin));
    expect(tester.getSize(favorite).width, greaterThanOrEqualTo(gmTargetMin));
    await tester.tap(favorite);
    await tester.pumpAndSettle();
    expect(find.text('Your favorites'), findsOneWidget);

    await _tapKey(tester, 'not-for-me-mountains');
    expect(find.text('Hidden packs (1)'), findsOneWidget);
    final showAgain = _key('show-again-mountains');
    await tester.ensureVisible(showAgain);
    await tester.pumpAndSettle();
    expect(tester.getSize(showAgain).height, greaterThanOrEqualTo(gmTargetMin));
    await tester.tap(showAgain);
    await tester.pumpAndSettle();
    expect(find.textContaining('Hidden packs'), findsNothing);

    // Empty-topic explanation also fits.
    await _tapKey(tester, 'not-for-me-cars');
    await _tapFinder(tester, _chip('Vintage'));
    expect(find.text('Nothing to show for these topics'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pack cards keep a readable text floor', (tester) async {
    await _pumpHome(tester);
    for (final element
        in find
            .descendant(
              of: _key('suggested-farm'),
              matching: find.byType(RichText),
            )
            .evaluate()) {
      final text = (element.renderObject! as RenderParagraph).text;
      final size = text.style?.fontSize;
      if (size != null) expect(size, greaterThanOrEqualTo(16));
    }
  });
}
