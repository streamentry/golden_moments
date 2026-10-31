import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/data/models/category.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/home/data/interest_preferences.dart';
import 'package:golden_moments/features/home/presentation/widgets/library_section.dart';
import 'package:golden_moments/l10n/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _icon = 'assets/images/catalog/24c28cf9fd7d826b4863ed6a.jpg';
const _categories = [
  Category(
    id: 'animals',
    name: 'Animals',
    description: 'Friendly animals',
    iconUrl: _icon,
    packCount: 2,
  ),
  Category(
    id: 'nature',
    name: 'Nature',
    description: 'Outdoors',
    iconUrl: _icon,
    packCount: 1,
  ),
  Category(
    id: 'food',
    name: 'Food',
    description: 'Everyday food',
    iconUrl: _icon,
    packCount: 1,
  ),
  Category(
    id: 'vintage',
    name: 'Vintage',
    description: 'Old favourites',
    iconUrl: _icon,
    packCount: 1,
  ),
];

Widget _app({double textScale = 1}) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  theme: gmBuildTheme(),
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context)
        .copyWith(textScaler: TextScaler.linear(textScale)),
    child: child!,
  ),
  home: Scaffold(
    body: SingleChildScrollView(
      child: LibrarySection(categories: _categories, onCategoryTap: (_) {}),
    ),
  ),
);

Finder _chip(String name) => find.widgetWithText(FilterChip, name);
Finder _card(String name) =>
    find.descendant(of: find.byType(Card), matching: find.text(name));

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('categoriesForInterests', () {
    test('no choice shows everything, in the original order', () {
      expect(categoriesForInterests(_categories, {}), _categories);
    });

    test('a choice shows only those topics', () {
      expect(
        categoriesForInterests(_categories, {
          'food',
          'animals',
        }).map((c) => c.id),
        ['animals', 'food'],
      );
    });

    test('a stale choice can never hide the library', () {
      expect(categoriesForInterests(_categories, {'gone'}), _categories);
      expect(
        categoriesForInterests(_categories, {
          'gone',
          'nature',
        }).map((c) => c.id),
        ['nature'],
      );
    });
  });

  group('InterestStore', () {
    const store = InterestStore();

    test('round-trips, and clearing removes the record', () async {
      expect(await store.load(), isEmpty);
      expect(await store.save({'nature', 'animals'}), isTrue);
      expect(await const InterestStore().load(), {'nature', 'animals'});
      await store.save({});
      expect(
        (await SharedPreferences.getInstance()).getString(
          InterestStore.storageKey,
        ),
        isNull,
      );
    });

    test('malformed or other-version data means no choice', () async {
      for (final bad in [
        '{not json',
        '[]',
        jsonEncode({
          'v': 2,
          'topics': ['food'],
        }),
        jsonEncode({'v': 1, 'topics': 'food'}),
      ]) {
        SharedPreferences.setMockInitialValues({InterestStore.storageKey: bad});
        expect(await store.load(), isEmpty, reason: bad);
      }
    });

    test('bad entries are dropped, good ones kept', () async {
      SharedPreferences.setMockInitialValues({
        InterestStore.storageKey: jsonEncode({
          'v': 1,
          'topics': ['food', 7, '', 'x' * 100, null],
        }),
      });
      expect(await store.load(), {'food'});
    });
  });

  group('library topics', () {
    testWidgets('nothing is chosen or forced by default', (tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();
      for (final name in ['Animals', 'Nature', 'Food', 'Vintage']) {
        expect(tester.widget<FilterChip>(_chip(name)).selected, isFalse);
      }
      expect(find.text('Show all topics'), findsNothing);
      // The old overview still shows the first three, no bias to vintage.
      expect(_card('Animals'), findsOneWidget);
      expect(_card('Vintage'), findsNothing);
    });

    testWidgets('choosing topics narrows the list, and it is remembered', (
      tester,
    ) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();
      await tester.tap(_chip('Vintage'));
      await tester.pumpAndSettle();
      expect(_card('Vintage'), findsOneWidget);
      expect(_card('Animals'), findsNothing);
      await tester.tap(_chip('Food'));
      await tester.pumpAndSettle();
      expect(_card('Food'), findsOneWidget);
      expect(_card('Vintage'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();
      expect(tester.widget<FilterChip>(_chip('Food')).selected, isTrue);
      expect(_card('Animals'), findsNothing);
    });

    testWidgets('Show all topics clears the choice for good', (tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();
      await tester.tap(_chip('Nature'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Show all topics'));
      await tester.pumpAndSettle();
      expect(find.text('Show all topics'), findsNothing);
      expect(_card('Animals'), findsOneWidget);
      expect(await const InterestStore().load(), isEmpty);
    });

    testWidgets('a saved choice that no longer exists shows everything', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        InterestStore.storageKey: jsonEncode({
          'v': 1,
          'topics': ['gone'],
        }),
      });
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();
      expect(_card('Animals'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('stale topics are dropped from the saved choice', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        InterestStore.storageKey: jsonEncode({
          'v': 1,
          'topics': ['gone', 'food'],
        }),
      });
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();
      expect(tester.widget<FilterChip>(_chip('Food')).selected, isTrue);
      expect(await const InterestStore().load(), {'food'});

      SharedPreferences.setMockInitialValues({
        InterestStore.storageKey: jsonEncode({
          'v': 1,
          'topics': ['gone'],
        }),
      });
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();
      expect(find.text('Show all topics'), findsNothing);
      expect(await const InterestStore().load(), isEmpty);
    });

    testWidgets('a tap before the saved choice loads is not overwritten', (
      tester,
    ) async {
      final store = _SlowInterestStore({'animals'});
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: gmBuildTheme(),
          home: Scaffold(
            body: SingleChildScrollView(
              child: LibrarySection(
                categories: _categories,
                onCategoryTap: (_) {},
                interestStore: store,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.tap(_chip('Food'));
      await tester.pump();
      store.release();
      await tester.pumpAndSettle();
      expect(tester.widget<FilterChip>(_chip('Food')).selected, isTrue);
      expect(tester.widget<FilterChip>(_chip('Animals')).selected, isFalse);
      expect(store.saved.last, {'food'});
    });

    testWidgets('selection is shown with a check, not colour alone', (
      tester,
    ) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();
      await tester.tap(_chip('Food'));
      await tester.pumpAndSettle();
      final chip = tester.widget<FilterChip>(_chip('Food'));
      expect(chip.selected, isTrue);
      // The check mark is drawn for selected chips, so state is never colour
      // alone; the word stays the same.
      expect(chip.showCheckmark, isTrue);
    });

    testWidgets('topics wrap and stay usable at 200% text', (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 3000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(_app(textScale: 2));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(_chip('Food'));
      await tester.pumpAndSettle();
      expect(_card('Food'), findsOneWidget);
      expect(tester.getSize(_chip('Food')).height, greaterThanOrEqualTo(48));
    });
  });
}

/// A store whose load waits, to model a tap that beats the saved choice.
class _SlowInterestStore extends InterestStore {
  new(this._stored);
  final Set<String> _stored;
  final _gate = Completer<void>();
  final List<Set<String>> saved = [];

  void release() => _gate.complete();

  @override
  Future<Set<String>> load() async {
    await _gate.future;
    return _stored;
  }

  @override
  Future<bool> save(Set<String> topics) async {
    saved.add({...topics});
    return true;
  }
}
