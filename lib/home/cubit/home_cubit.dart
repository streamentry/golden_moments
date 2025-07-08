import 'package:bloc/bloc.dart';
import 'package:memory_lane/game/models/models.dart';
import 'package:memory_lane/home/cubit/home_state.dart';

/// Cubit for managing home screen state and logic
class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState());

  /// Initialize the home screen with data
  Future<void> initialize() async {
    emit(state.copyWith(status: HomeStatus.loading));
    
    try {
      // Load user preferences (in real app, this would come from storage)
      final preferences = await _loadUserPreferences();
      
      // Load daily packs
      final dailyPacks = await _loadDailyPacks();
      
      // Load library packs
      final libraryPacks = await _loadLibraryPacks();
      
      emit(state.copyWith(
        status: HomeStatus.loaded,
        userPreferences: preferences,
        dailyPacks: dailyPacks,
        libraryPacks: libraryPacks,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: HomeStatus.error,
        errorMessage: error.toString(),
      ));
    }
  }

  /// Update user preferences
  void updatePreferences(UserPreferences preferences) {
    emit(state.copyWith(userPreferences: preferences));
    // In real app, save to storage here
  }

  /// Mark a pack as completed
  void markPackCompleted(String packId) {
    final updatedCompletedPacks = [
      ...state.userPreferences.completedPacks,
      if (!state.userPreferences.completedPacks.contains(packId)) packId,
    ];
    
    final updatedPreferences = state.userPreferences.copyWith(
      completedPacks: updatedCompletedPacks,
    );
    
    // Update daily packs
    final updatedDailyPacks = state.dailyPacks.map((pack) {
      if (pack.id == packId) {
        return pack.copyWith(isCompleted: true);
      }
      return pack;
    }).toList();
    
    // Update library packs
    final updatedLibraryPacks = state.libraryPacks.map((pack) {
      if (pack.id == packId) {
        return pack.copyWith(isCompleted: true);
      }
      return pack;
    }).toList();
    
    emit(state.copyWith(
      userPreferences: updatedPreferences,
      dailyPacks: updatedDailyPacks,
      libraryPacks: updatedLibraryPacks,
    ));
  }

  /// Refresh daily packs
  Future<void> refreshDailyPacks() async {
    try {
      final dailyPacks = await _loadDailyPacks();
      emit(state.copyWith(dailyPacks: dailyPacks));
    } catch (error) {
      emit(state.copyWith(
        status: HomeStatus.error,
        errorMessage: 'Failed to refresh daily packs: ${error.toString()}',
      ));
    }
  }

  // Mock data loading methods (in real app, these would call repositories)
  
  Future<UserPreferences> _loadUserPreferences() async {
    // Simulate loading delay
    await Future<void>.delayed(const Duration(milliseconds: 500));

    // Return default preferences for now
    return const UserPreferences();
  }

  Future<List<GamePack>> _loadDailyPacks() async {
    // Simulate loading delay
    await Future<void>.delayed(const Duration(milliseconds: 800));
    
    // Mock daily packs
    return [
      _createMockPack(
        id: 'daily_classic_cars',
        title: 'Classic Cars of the 60s',
        theme: '1960s Cars',
        difficulty: GameDifficulty.easy,
      ),
      _createMockPack(
        id: 'daily_vintage_toys',
        title: 'Childhood Toys',
        theme: 'Retro Toys',
        difficulty: GameDifficulty.medium,
      ),
      _createMockPack(
        id: 'daily_old_movies',
        title: 'Golden Age Cinema',
        theme: 'Classic Movies',
        difficulty: GameDifficulty.easy,
      ),
    ];
  }

  Future<List<GamePack>> _loadLibraryPacks() async {
    // Simulate loading delay
    await Future<void>.delayed(const Duration(milliseconds: 600));
    
    // Mock library packs
    return [
      _createMockPack(
        id: 'lib_household_items',
        title: 'Vintage Kitchen',
        theme: 'Vintage Household Items',
        difficulty: GameDifficulty.easy,
      ),
      _createMockPack(
        id: 'lib_tv_shows',
        title: 'Classic TV Shows',
        theme: 'Old TV Shows',
        difficulty: GameDifficulty.medium,
        isPremium: true,
      ),
      _createMockPack(
        id: 'lib_fashion',
        title: '1950s Fashion',
        theme: 'Vintage Fashion',
        difficulty: GameDifficulty.brainy,
        isPremium: true,
      ),
    ];
  }

  GamePack _createMockPack({
    required String id,
    required String title,
    required String theme,
    required GameDifficulty difficulty,
    bool isPremium = false,
  }) {
    // Create mock tiles for the pack
    final tiles = <GameTile>[];
    for (int i = 0; i < difficulty.pairCount; i++) {
      final pairId = 'pair_$i';
      tiles.addAll([
        GameTile(
          id: '${id}_tile_${i}_a',
          imageUrl: 'assets/images/$theme/item_$i.jpg',
          caption: 'Mock item $i',
          pairId: pairId,
        ),
        GameTile(
          id: '${id}_tile_${i}_b',
          imageUrl: 'assets/images/$theme/item_$i.jpg',
          caption: 'Mock item $i',
          pairId: pairId,
        ),
      ]);
    }

    return GamePack(
      id: id,
      title: title,
      theme: theme,
      tiles: tiles,
      difficulty: difficulty,
      isPremium: isPremium,
      description: 'A nostalgic journey through $theme',
    );
  }
}
