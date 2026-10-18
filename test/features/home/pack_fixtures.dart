import 'dart:async';

import 'package:golden_moments/data/models/category.dart';
import 'package:golden_moments/data/models/pack.dart';
import 'package:golden_moments/data/models/packs_index.dart';
import 'package:golden_moments/features/home/data/pack_preferences.dart';

const fixtureIcon = 'assets/images/catalog/24c28cf9fd7d826b4863ed6a.jpg';

Pack fixturePack(String id, String title, String category) => Pack(
  id: id,
  title: title,
  theme: '$title pictures',
  category: category,
  version: '1',
  difficulty: GameDifficulty.easy,
  thumbnailUrl: fixtureIcon,
  images: const [],
  estimatedSize: '1 MB',
);

/// Six packs in four topics, in catalog order.
final List<Pack> fixturePacks = [
  fixturePack('farm', 'Farm Animals', 'animals'),
  fixturePack('mountains', 'Mountain Views', 'nature'),
  fixturePack('cars', 'Classic Cars', 'vintage'),
  fixturePack('safari', 'Safari Animals', 'animals'),
  fixturePack('desserts', 'Desserts', 'food'),
  fixturePack('lakes', 'Lakes', 'nature'),
];

const fixtureCategories = [
  Category(
    id: 'animals',
    name: 'Animals',
    description: 'Friendly animals',
    iconUrl: fixtureIcon,
    packCount: 2,
  ),
  Category(
    id: 'nature',
    name: 'Nature',
    description: 'Outdoors',
    iconUrl: fixtureIcon,
    packCount: 2,
  ),
  Category(
    id: 'vintage',
    name: 'Vintage',
    description: 'Old favourites',
    iconUrl: fixtureIcon,
    packCount: 1,
  ),
  Category(
    id: 'food',
    name: 'Food',
    description: 'Everyday food',
    iconUrl: fixtureIcon,
    packCount: 1,
  ),
];

Future<PacksIndex> loadFixtureCatalog() async => PacksIndex(
  version: '1',
  lastUpdated: DateTime(2026),
  totalPacks: fixturePacks.length,
  categories: fixtureCategories,
  featuredPacks: const [],
  packs: fixturePacks,
);

/// A store whose load waits until [release], and which records saves.
class GatedPackStore extends PackPreferencesStore {
  new(this._stored);

  final PackPreferences _stored;
  final _gate = Completer<void>();
  final List<PackPreferences> saved = [];

  void release() => _gate.complete();

  @override
  Future<PackPreferences> load() async {
    await _gate.future;
    return _stored;
  }

  @override
  Future<bool> save(PackPreferences value) async {
    saved.add(value);
    return true;
  }
}

/// A store that cannot save.
class FailingPackStore extends PackPreferencesStore {
  const new();

  @override
  Future<PackPreferences> load() async => const PackPreferences();

  @override
  Future<bool> save(PackPreferences value) async => false;
}
