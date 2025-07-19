import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:golden_moments/data/models/github_pack_index.dart';
import 'package:golden_moments/data/services/local_pack_service.dart';
import 'package:golden_moments/game/models/models.dart';

/// Cubit for managing pack discovery state
class PackDiscoveryCubit extends Cubit<PackDiscoveryState> {
  PackDiscoveryCubit() : super(const PackDiscoveryState());

  final LocalPackService _packService = LocalPackService.instance;

  /// Initialize pack discovery
  Future<void> initialize() async {
    emit(state.copyWith(status: PackDiscoveryStatus.loading));

    try {
      // Load pack index from local JSON
      final packIndex = await _packService.loadPackIndex();

      // Extract categories
      final categories = _extractCategories(packIndex.packs);

      emit(
        state.copyWith(
          status: PackDiscoveryStatus.loaded,
          allPacks: packIndex.packs,
          filteredPacks: packIndex.packs,
          featuredPacks: packIndex.getFeaturedPacks(),
          categories: categories,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PackDiscoveryStatus.error,
          errorMessage: 'Failed to load packs: $e',
        ),
      );
    }
  }

  /// Refresh packs from GitHub
  Future<void> refreshPacks() async {
    await initialize();
  }

  /// Search packs by query
  void searchPacks(String query) {
    final filteredPacks = query.isEmpty
        ? state.allPacks
        : state.allPacks.where((pack) => pack.matchesQuery(query)).toList();

    emit(
      state.copyWith(
        searchQuery: query,
        filteredPacks: filteredPacks,
      ),
    );
  }

  /// Select category filter
  void selectCategory(String? category) {
    final filteredPacks = category == null
        ? state.allPacks
        : state.allPacks.where((pack) => pack.category == category).toList();

    emit(
      state.copyWith(
        selectedCategory: category,
        filteredPacks: filteredPacks,
        searchQuery: '', // Clear search when selecting category
      ),
    );
  }

  /// Apply filters
  void applyFilters(PackDiscoveryFilters filters) {
    var filteredPacks = state.allPacks.where((pack) {
      // Difficulty filter
      if (filters.difficulties.isNotEmpty &&
          !filters.difficulties.contains(pack.difficulty)) {
        return false;
      }

      // Premium filter
      if (filters.showFreeOnly && pack.isPremium) {
        return false;
      }
      if (filters.showPremiumOnly && !pack.isPremium) {
        return false;
      }

      // Category filter
      if (filters.categories.isNotEmpty &&
          !filters.categories.contains(pack.category)) {
        return false;
      }

      return true;
    }).toList();

    // Apply search query if present
    if (state.searchQuery.isNotEmpty) {
      filteredPacks = filteredPacks
          .where((pack) => pack.matchesQuery(state.searchQuery))
          .toList();
    }

    emit(
      state.copyWith(
        filters: filters,
        filteredPacks: filteredPacks,
      ),
    );
  }

  /// Clear all filters
  void clearFilters() {
    emit(
      state.copyWith(
        filters: const PackDiscoveryFilters(),
        selectedCategory: null,
        searchQuery: '',
        filteredPacks: state.allPacks,
      ),
    );
  }

  /// Extract unique categories from packs
  List<String> _extractCategories(List<GitHubPackInfo> packs) {
    final categories = packs.map((pack) => pack.category).toSet().toList();
    categories.sort();
    return categories;
  }
}

/// Pack discovery state
class PackDiscoveryState extends Equatable {
  const PackDiscoveryState({
    this.status = PackDiscoveryStatus.initial,
    this.allPacks = const [],
    this.filteredPacks = const [],
    this.featuredPacks = const [],
    this.categories = const [],
    this.searchQuery = '',
    this.selectedCategory,
    this.filters = const PackDiscoveryFilters(),
    this.errorMessage = '',
  });

  final PackDiscoveryStatus status;
  final List<GitHubPackInfo> allPacks;
  final List<GitHubPackInfo> filteredPacks;
  final List<GitHubPackInfo> featuredPacks;
  final List<String> categories;
  final String searchQuery;
  final String? selectedCategory;
  final PackDiscoveryFilters filters;
  final String errorMessage;

  PackDiscoveryState copyWith({
    PackDiscoveryStatus? status,
    List<GitHubPackInfo>? allPacks,
    List<GitHubPackInfo>? filteredPacks,
    List<GitHubPackInfo>? featuredPacks,
    List<String>? categories,
    String? searchQuery,
    String? selectedCategory,
    PackDiscoveryFilters? filters,
    String? errorMessage,
  }) {
    return PackDiscoveryState(
      status: status ?? this.status,
      allPacks: allPacks ?? this.allPacks,
      filteredPacks: filteredPacks ?? this.filteredPacks,
      featuredPacks: featuredPacks ?? this.featuredPacks,
      categories: categories ?? this.categories,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      filters: filters ?? this.filters,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    allPacks,
    filteredPacks,
    featuredPacks,
    categories,
    searchQuery,
    selectedCategory,
    filters,
    errorMessage,
  ];
}

/// Pack discovery status enumeration
enum PackDiscoveryStatus {
  initial,
  loading,
  loaded,
  error,
}

/// Pack discovery filters
class PackDiscoveryFilters extends Equatable {
  const PackDiscoveryFilters({
    this.difficulties = const [],
    this.categories = const [],
    this.showFreeOnly = false,
    this.showPremiumOnly = false,
    this.showNewOnly = false,
    this.showUpdatedOnly = false,
  });

  final List<GameDifficulty> difficulties;
  final List<String> categories;
  final bool showFreeOnly;
  final bool showPremiumOnly;
  final bool showNewOnly;
  final bool showUpdatedOnly;

  PackDiscoveryFilters copyWith({
    List<GameDifficulty>? difficulties,
    List<String>? categories,
    bool? showFreeOnly,
    bool? showPremiumOnly,
    bool? showNewOnly,
    bool? showUpdatedOnly,
  }) {
    return PackDiscoveryFilters(
      difficulties: difficulties ?? this.difficulties,
      categories: categories ?? this.categories,
      showFreeOnly: showFreeOnly ?? this.showFreeOnly,
      showPremiumOnly: showPremiumOnly ?? this.showPremiumOnly,
      showNewOnly: showNewOnly ?? this.showNewOnly,
      showUpdatedOnly: showUpdatedOnly ?? this.showUpdatedOnly,
    );
  }

  /// Check if any filters are active
  bool get hasActiveFilters {
    return difficulties.isNotEmpty ||
        categories.isNotEmpty ||
        showFreeOnly ||
        showPremiumOnly ||
        showNewOnly ||
        showUpdatedOnly;
  }

  @override
  List<Object?> get props => [
    difficulties,
    categories,
    showFreeOnly,
    showPremiumOnly,
    showNewOnly,
    showUpdatedOnly,
  ];
}
