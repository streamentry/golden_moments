import 'package:golden_moments/data/models/pack.dart';
import 'package:golden_moments/features/home/data/pack_preferences.dart';

// How favorites and "Not for me" shape what the library shows (GM-020,
// GM-024, GM-026).
//
// Hiding wins. A pack marked "Not for me" is left out of suggestions, the
// favorites group and the topic lists, even if it is also a favorite; it is
// listed only under "Hidden packs", where "Show again" brings it back. The
// favorite mark is kept while hidden, so a shown-again favorite returns to
// the favorites group. Nothing is ever unhidden automatically, and ids that
// are not in the included catalog are ignored.
//
// Every list keeps the catalog order. Nothing is ranked by use, and nothing
// reshuffles by date: suggestions change only when the person hides, shows
// or favorites a pack, or asks for other suggestions.

/// How many packs the home screen suggests at once.
const int suggestionCount = 4;

/// Favorite packs that are not hidden, in catalog order.
List<Pack> favoritePacks(List<Pack> packs, PackPreferences prefs) =>
    List.unmodifiable([
      for (final pack in packs)
        if (prefs.isFavorite(pack.id) && !prefs.isHidden(pack.id)) pack,
    ]);

/// Packs marked "Not for me", in catalog order.
List<Pack> hiddenPacks(List<Pack> packs, PackPreferences prefs) =>
    List.unmodifiable([
      for (final pack in packs)
        if (prefs.isHidden(pack.id)) pack,
    ]);

/// Packs to browse: hidden ones left out, favorites first, otherwise in
/// catalog order.
List<Pack> browsablePacks(List<Pack> packs, PackPreferences prefs) {
  final visible = [
    for (final pack in packs)
      if (!prefs.isHidden(pack.id)) pack,
  ];
  return List.unmodifiable([
    ...visible.where((pack) => prefs.isFavorite(pack.id)),
    ...visible.where((pack) => !prefs.isFavorite(pack.id)),
  ]);
}

/// Packs that could be suggested: not hidden and not already a favorite
/// (favorites have their own group), in catalog order.
List<Pack> suggestablePacks(List<Pack> packs, PackPreferences prefs) =>
    List.unmodifiable([
      for (final pack in packs)
        if (!prefs.isHidden(pack.id) && !prefs.isFavorite(pack.id)) pack,
    ]);

/// Up to [count] suggestions starting at [offset] in [suggestablePacks],
/// wrapping around. The same inputs always give the same suggestions.
List<Pack> suggestedPacks(
  List<Pack> packs,
  PackPreferences prefs, {
  int offset = 0,
  int count = suggestionCount,
}) {
  final pool = suggestablePacks(packs, prefs);
  if (pool.isEmpty || count <= 0) return const [];
  if (pool.length <= count) return pool;
  final start = offset % pool.length;
  return List.unmodifiable([
    for (var i = 0; i < count; i++) pool[(start + i) % pool.length],
  ]);
}

/// Number of packs that are not hidden, by category id.
Map<String, int> eligiblePackCounts(List<Pack> packs, PackPreferences prefs) {
  final counts = <String, int>{};
  for (final pack in packs) {
    if (prefs.isHidden(pack.id)) continue;
    counts[pack.category] = (counts[pack.category] ?? 0) + 1;
  }
  return Map.unmodifiable(counts);
}
