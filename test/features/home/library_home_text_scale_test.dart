import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/data/models/packs_index.dart';
import 'package:golden_moments/data/services/local_pack_service.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/home/cubit/home_cubit.dart';
import 'package:golden_moments/features/home/presentation/screens/home_page.dart';
import 'package:golden_moments/shared/widgets/pack_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The real included catalog, so long titles and themes are exercised.
Future<PacksIndex> _catalog(WidgetTester tester) async =>
    (await tester.runAsync(() => LocalPackService().getPacksIndex()))!;

Future<void> _reveal(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  expect(finder.hitTestable(), findsOneWidget);
}

void main() {
  setUp(() => WidgetController.hitTestWarningShouldBeFatal = true);
  tearDown(() => WidgetController.hitTestWarningShouldBeFatal = false);
  setUp(() => SharedPreferences.setMockInitialValues({}));

  const sizes = [
    Size(320, 568),
    Size(390, 844),
    Size(844, 390),
    Size(1024, 1366),
  ];

  for (final size in sizes) {
    final name = '${size.width.toInt()}x${size.height.toInt()}';
    testWidgets('library home holds at 200% text on $name', (tester) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final index = await _catalog(tester);
      final cubit = HomeCubit(loadCatalog: () async => index);
      addTearDown(cubit.close);

      await tester.pumpWidget(
        MaterialApp(
          theme: gmBuildTheme(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: BlocProvider.value(value: cubit, child: const HomeView()),
        ),
      );
      await cubit.initialize();
      await tester.pumpAndSettle();
      // A RenderFlex overflow is reported as an exception and fails here.
      expect(tester.takeException(), isNull);

      final suggested = cubit.state.suggestedPacks;
      expect(suggested, isNotEmpty);
      for (final pack in suggested) {
        final card = find.byKey(ValueKey('suggested-${pack.id}'));
        await _reveal(
          tester,
          find.descendant(of: card, matching: find.text('Play')),
        );
        await _reveal(tester, find.byKey(ValueKey('favorite-${pack.id}')));
        await _reveal(tester, find.byKey(ValueKey('not-for-me-${pack.id}')));
      }

      // Favorite and hide still lay out cleanly at this size.
      final first = suggested.first.id;
      await _reveal(tester, find.byKey(ValueKey('favorite-$first')));
      await tester.tap(find.byKey(ValueKey('favorite-$first')));
      await tester.pumpAndSettle();
      expect(find.byKey(ValueKey('favorite-card-$first')), findsOneWidget);
      final second = cubit.state.suggestedPacks.first.id;
      await _reveal(tester, find.byKey(ValueKey('not-for-me-$second')));
      await tester.tap(find.byKey(ValueKey('not-for-me-$second')));
      await tester.pumpAndSettle();
      expect(find.byKey(ValueKey('suggested-$second')), findsNothing);
      await _reveal(tester, find.byKey(ValueKey('show-again-$second')));
      expect(find.byType(PackCard), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  }
}
