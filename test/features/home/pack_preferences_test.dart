import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/data/models/pack.dart';
import 'package:golden_moments/features/gentle_activities/data/gentle_preferences.dart';
import 'package:golden_moments/features/home/cubit/home_cubit.dart';
import 'package:golden_moments/features/home/cubit/home_state.dart';
import 'package:golden_moments/features/home/data/interest_preferences.dart';
import 'package:golden_moments/features/home/data/pack_preferences.dart';
import 'package:golden_moments/features/home/data/pack_selection.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pack_fixtures.dart';

List<String> _ids(Iterable<Pack> packs) => [for (final pack in packs) pack.id];

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('PackPreferences record', () {
    test('toggles return new copies and leave the original alone', () {
      const empty = PackPreferences();
      final favorite = empty.withFavorite('farm', favorite: true);
      final hidden = favorite.withHidden('farm', hide: true);
      expect(empty.favorites, isEmpty);
      expect(favorite.isFavorite('farm'), isTrue);
      expect(favorite.isHidden('farm'), isFalse);
      // Hiding keeps the favorite mark, so Show again restores it.
      expect(hidden.isFavorite('farm'), isTrue);
      expect(hidden.isHidden('farm'), isTrue);
      expect(hidden.withHidden('farm', hide: false), favorite);
      expect(
        () => hidden.favorites.add('x'),
        throwsUnsupportedError,
        reason: 'the record is immutable',
      );
    });

    test('other versions and malformed data mean no choices', () {
      for (final bad in <Object?>[
        null,
        'text',
        <Object?>[],
        {
          'favorites': <String>['farm'],
        },
        {
          'v': '1',
          'favorites': <String>['farm'],
        },
        {
          'v': 0,
          'favorites': <String>['farm'],
        },
        {
          'v': 2,
          'favorites': <String>['farm'],
        },
      ]) {
        expect(
          PackPreferences.fromJson(bad),
          const PackPreferences(),
          reason: '$bad',
        );
      }
    });

    test('reads each field on its own and drops bad entries', () {
      final prefs = PackPreferences.fromJson({
        'v': 1,
        'favorites': 'farm',
        'hidden': ['cars', 7, '', null, 'x' * 65, '../etc', 'safari'],
      });
      expect(prefs.favorites, isEmpty);
      expect(prefs.hidden, {'cars', 'safari'});
    });

    test('keeps at most maxIds entries', () {
      final prefs = PackPreferences.fromJson({
        'v': 1,
        'hidden': [for (var i = 0; i < 500; i++) 'pack$i'],
      });
      expect(prefs.hidden, hasLength(PackPreferences.maxIds));
    });
  });

  group('PackPreferencesStore', () {
    const store = PackPreferencesStore();

    test('round-trips as a versioned record', () async {
      expect(await store.load(), const PackPreferences());
      final value = const PackPreferences()
          .withFavorite('farm', favorite: true)
          .withHidden('cars', hide: true);
      expect(await store.save(value), isTrue);
      expect(await const PackPreferencesStore().load(), value);

      final raw = (await SharedPreferences.getInstance()).getString(
        PackPreferences.storageKey,
      );
      expect(jsonDecode(raw!), {
        'v': PackPreferences.schemaVersion,
        'favorites': ['farm'],
        'hidden': ['cars'],
      });
    });

    test('corrupt or other-version data loads as no choices', () async {
      for (final bad in [
        '{not json',
        '[]',
        'null',
        jsonEncode({
          'v': 99,
          'hidden': ['farm'],
        }),
      ]) {
        SharedPreferences.setMockInitialValues({
          PackPreferences.storageKey: bad,
        });
        expect(await store.load(), const PackPreferences(), reason: bad);
      }
    });

    test('reset removes pack choices only', () async {
      SharedPreferences.setMockInitialValues({
        InterestStore.storageKey: jsonEncode({
          'v': 1,
          'topics': ['food'],
        }),
        GentlePreferences.storageKey: jsonEncode(
          const GentlePreferences(pairs: 3).toJson(),
        ),
        'gm.unrelated': 'keep me',
      });
      await store.save(const PackPreferences().withHidden('farm', hide: true));
      expect(await store.reset(), isTrue);
      expect(await store.load(), const PackPreferences());
      expect(await const InterestStore().load(), {'food'});
      expect((await const GentlePreferencesStore().load()).pairs, 3);
      expect(
        (await SharedPreferences.getInstance()).getString('gm.unrelated'),
        'keep me',
      );
    });
  });

  group('pack selection', () {
    final prefs = const PackPreferences()
        .withFavorite('safari', favorite: true)
        .withFavorite('cars', favorite: true)
        .withHidden('cars', hide: true)
        .withHidden('mountains', hide: true)
        .withHidden('gone', hide: true)
        .withFavorite('gone', favorite: true);

    test('hiding wins over favorite everywhere but the hidden list', () {
      expect(_ids(favoritePacks(fixturePacks, prefs)), ['safari']);
      expect(_ids(hiddenPacks(fixturePacks, prefs)), ['mountains', 'cars']);
      expect(_ids(suggestablePacks(fixturePacks, prefs)), [
        'farm',
        'desserts',
        'lakes',
      ]);
      expect(_ids(browsablePacks(fixturePacks, prefs)), [
        'safari',
        'farm',
        'desserts',
        'lakes',
      ]);
    });

    test('ids that are not in the catalog are ignored', () {
      expect(hiddenPacks(fixturePacks, prefs), hasLength(2));
      expect(eligiblePackCounts(fixturePacks, prefs), {
        'animals': 2,
        'food': 1,
        'nature': 1,
      });
    });

    test('suggestions are stable and move only with an offset', () {
      const none = PackPreferences();
      final first = suggestedPacks(fixturePacks, none);
      expect(_ids(first), ['farm', 'mountains', 'cars', 'safari']);
      expect(suggestedPacks(fixturePacks, none), first);
      expect(_ids(suggestedPacks(fixturePacks, none, offset: 4)), [
        'desserts',
        'lakes',
        'farm',
        'mountains',
      ]);
      expect(suggestedPacks(fixturePacks, prefs), hasLength(3));
    });

    test('everything hidden leaves nothing to suggest', () {
      var all = const PackPreferences();
      for (final pack in fixturePacks) {
        all = all.withHidden(pack.id, hide: true);
      }
      expect(suggestedPacks(fixturePacks, all), isEmpty);
      expect(eligiblePackCounts(fixturePacks, all), isEmpty);
      expect(hiddenPacks(fixturePacks, all), hasLength(fixturePacks.length));
    });
  });

  group('HomeCubit choices', () {
    Future<HomeCubit> loaded({
      PackPreferencesStore store = const PackPreferencesStore(),
    }) async {
      final cubit = HomeCubit(
        preferencesStore: store,
        loadCatalog: loadFixtureCatalog,
      );
      addTearDown(cubit.close);
      await cubit.initialize();
      return cubit;
    }

    test('loads saved choices with the catalog', () async {
      await const PackPreferencesStore().save(
        const PackPreferences().withHidden('farm', hide: true),
      );
      final cubit = await loaded();
      expect(cubit.state.status, HomeStatus.loaded);
      expect(cubit.state.preferencesReady, isTrue);
      expect(_ids(cubit.state.hiddenPacks), ['farm']);
      expect(_ids(cubit.state.suggestedPacks), isNot(contains('farm')));
    });

    test('favorite, hide and show again are saved', () async {
      final cubit = await loaded();
      await cubit.setFavorite('lakes', favorite: true);
      await cubit.hidePack('farm');
      expect(_ids(cubit.state.favoritePacks), ['lakes']);
      expect(
        await const PackPreferencesStore().load(),
        cubit.state.packPreferences,
      );

      await cubit.showPack('farm');
      await cubit.setFavorite('lakes', favorite: false);
      expect(
        await const PackPreferencesStore().load(),
        const PackPreferences(),
      );
    });

    test('unknown pack ids are ignored', () async {
      final cubit = await loaded();
      await cubit.hidePack('not-a-pack');
      await cubit.setFavorite('not-a-pack', favorite: true);
      expect(cubit.state.packPreferences, const PackPreferences());
      expect(
        (await SharedPreferences.getInstance()).getString(
          PackPreferences.storageKey,
        ),
        isNull,
      );
    });

    test('a failed save keeps the choice for now and says so', () async {
      final cubit = await loaded(store: const FailingPackStore());
      await cubit.hidePack('farm');
      expect(cubit.state.packPreferences.isHidden('farm'), isTrue);
      expect(cubit.state.preferencesSaveFailed, isTrue);
    });

    test(
      'slow saved choices never block the catalog or get overwritten',
      () async {
        final store = GatedPackStore(
          const PackPreferences().withHidden('cars', hide: true),
        );
        final cubit = HomeCubit(
          preferencesStore: store,
          loadCatalog: loadFixtureCatalog,
        );
        addTearDown(cubit.close);
        final done = cubit.initialize();
        await Future<void>.delayed(
          HomeCubit.preferencesGrace + const Duration(milliseconds: 50),
        );
        expect(cubit.state.status, HomeStatus.loaded);
        expect(cubit.state.preferencesReady, isFalse);
        await cubit.hidePack('farm');
        expect(store.saved, isEmpty);

        store.release();
        await done;
        expect(cubit.state.preferencesReady, isTrue);
        expect(_ids(cubit.state.hiddenPacks), ['cars']);
      },
    );

    test(
      'other suggestions only on request, and only when there are more',
      () async {
        final cubit = await loaded();
        final before = cubit.state.suggestedPacks;
        cubit.showOtherSuggestions();
        expect(cubit.state.suggestedPacks, isNot(before));
        expect(_ids(cubit.state.suggestedPacks).first, 'desserts');

        for (final id in ['farm', 'mountains', 'cars']) {
          await cubit.hidePack(id);
        }
        expect(cubit.state.hasOtherSuggestions, isFalse);
        final settled = cubit.state.suggestionOffset;
        cubit.showOtherSuggestions();
        expect(cubit.state.suggestionOffset, settled);
      },
    );

    test('a failed catalog shows the error state', () async {
      final cubit = HomeCubit(loadCatalog: () async => throw StateError('x'));
      addTearDown(cubit.close);
      await cubit.initialize();
      expect(cubit.state.status, HomeStatus.error);
    });
  });
}
