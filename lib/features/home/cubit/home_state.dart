import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show ValueGetter;
import 'package:golden_moments/data/models/category.dart';
import 'package:golden_moments/data/models/pack.dart';
import 'package:golden_moments/features/home/data/pack_preferences.dart';
import 'package:golden_moments/features/home/data/pack_selection.dart'
    as selection;

/// Status of the home screen
enum HomeStatus { initial, loading, loaded, error }

/// State for the home screen
class HomeState extends Equatable {
  const new({
    this.status = HomeStatus.initial,
    this.packs = const [],
    this.libraryPacks = const [],
    this.packPreferences = const PackPreferences(),
    this.suggestionOffset = 0,
    this.preferencesReady = false,
    this.preferencesUnreadable = false,
    this.lastHiddenPackId,
    this.preferencesSaveFailed = false,
    this.errorMessage,
  });

  /// Current status of the home screen
  final HomeStatus status;

  /// Every included pack, in catalog order.
  final List<Pack> packs;

  /// All available categories in the library
  final List<Category> libraryPacks;

  /// The person's favorites and "Not for me" choices.
  final PackPreferences packPreferences;

  /// Moves only when the person asks for other suggestions.
  final int suggestionOffset;

  /// True once reading the saved choices has finished. Until then no pack is
  /// shown at all (only topics), so a pack marked Not for me can never
  /// appear, even briefly, and nothing can overwrite the choices.
  final bool preferencesReady;

  /// True when a saved record exists but could not be read (damaged, from a
  /// newer version, or storage failed). It is never written over, so
  /// Favorite and Not for me stay off. Which packs it hid cannot be known,
  /// so the catalog is shown in full with a note saying so.
  final bool preferencesUnreadable;

  /// The pack most recently marked Not for me, for the lasting note that
  /// says where to find it. Cleared when that pack is shown again.
  final String? lastHiddenPackId;

  /// Whether Favorite and Not for me may be offered and saved.
  bool get choicesEnabled => preferencesReady && !preferencesUnreadable;

  /// True when the last favorite or hide choice could not be saved.
  final bool preferencesSaveFailed;

  /// Error message if status is error
  final String? errorMessage;

  /// Suggested packs: never hidden, never a favorite, stable order.
  List<Pack> get suggestedPacks => selection.suggestedPacks(
    packs,
    packPreferences,
    offset: suggestionOffset,
  );

  /// True when there are more packs to suggest than are shown at once.
  bool get hasOtherSuggestions =>
      selection.suggestablePacks(packs, packPreferences).length >
      selection.suggestionCount;

  /// Favorites that are not hidden.
  List<Pack> get favoritePacks =>
      selection.favoritePacks(packs, packPreferences);

  /// The pack named by [lastHiddenPackId], while it is still hidden.
  Pack? get lastHiddenPack {
    final id = lastHiddenPackId;
    if (id == null || !packPreferences.isHidden(id)) return null;
    for (final pack in packs) {
      if (pack.id == id) return pack;
    }
    return null;
  }

  /// Packs marked "Not for me".
  List<Pack> get hiddenPacks => selection.hiddenPacks(packs, packPreferences);

  /// Non-hidden packs per category id.
  Map<String, int> get eligiblePackCounts =>
      selection.eligiblePackCounts(packs, packPreferences);

  /// Packs to browse in one category: hidden left out, favorites first.
  List<Pack> browsablePacksIn(String categoryId) => selection.browsablePacks([
    for (final pack in packs)
      if (pack.category == categoryId) pack,
  ], packPreferences);

  /// Hidden packs in one category.
  List<Pack> hiddenPacksIn(String categoryId) => [
    for (final pack in hiddenPacks)
      if (pack.category == categoryId) pack,
  ];

  /// Creates a copy of this state with updated properties
  HomeState copyWith({
    HomeStatus? status,
    List<Pack>? packs,
    List<Category>? libraryPacks,
    PackPreferences? packPreferences,
    int? suggestionOffset,
    bool? preferencesReady,
    bool? preferencesUnreadable,
    ValueGetter<String?>? lastHiddenPackId,
    bool? preferencesSaveFailed,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      packs: packs ?? this.packs,
      libraryPacks: libraryPacks ?? this.libraryPacks,
      packPreferences: packPreferences ?? this.packPreferences,
      suggestionOffset: suggestionOffset ?? this.suggestionOffset,
      preferencesReady: preferencesReady ?? this.preferencesReady,
      preferencesUnreadable:
          preferencesUnreadable ?? this.preferencesUnreadable,
      lastHiddenPackId: lastHiddenPackId == null
          ? this.lastHiddenPackId
          : lastHiddenPackId(),
      preferencesSaveFailed:
          preferencesSaveFailed ?? this.preferencesSaveFailed,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    packs,
    libraryPacks,
    packPreferences,
    suggestionOffset,
    preferencesReady,
    preferencesUnreadable,
    lastHiddenPackId,
    preferencesSaveFailed,
    errorMessage,
  ];
}
