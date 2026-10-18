import 'package:equatable/equatable.dart';
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

  /// True once the saved choices are known; until then Favorite and Not for
  /// me are not offered, so nothing can overwrite them.
  final bool preferencesReady;

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
    preferencesSaveFailed,
    errorMessage,
  ];
}
