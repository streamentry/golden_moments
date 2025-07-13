import 'package:bloc/bloc.dart';
import 'package:golden_moments/data/services/local_pack_service.dart';
import 'package:golden_moments/data/models/category.dart';
import 'package:golden_moments/game/models/models.dart';
import 'package:golden_moments/home/cubit/home_state.dart';

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
      final dailyPacks = await _loadPacks();

      // Load library packs
      final libraryPacks = await _loadCategory();

      emit(
        state.copyWith(
          status: HomeStatus.loaded,
          userPreferences: preferences,
          dailyPacks: dailyPacks,
          libraryPacks: libraryPacks,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: HomeStatus.error,
          errorMessage: error.toString(),
        ),
      );
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
        // return pack.copyWith(isCompleted: true);
      }
      return pack;
    }).toList();

    // Update library packs
    final updatedLibraryPacks = state.libraryPacks.map((pack) {
      if (pack.id == packId) {
        // return pack.copyWith(isCompleted: true);
      }
      return pack;
    }).toList();

    emit(
      state.copyWith(
        userPreferences: updatedPreferences,
        dailyPacks: updatedDailyPacks,
        libraryPacks: updatedLibraryPacks,
      ),
    );
  }

  /// Refresh daily packs
  // Future<void> refreshDailyPacks() async {
  //   try {
  //     final dailyPacks = await _loadDailyPacks();
  //     emit(state.copyWith(dailyPacks: dailyPacks));
  //   } catch (error) {
  //     emit(
  //       state.copyWith(
  //         status: HomeStatus.error,
  //         errorMessage: 'Failed to refresh daily packs: ${error.toString()}',
  //       ),
  //     );
  //   }
  // }

  // Mock data loading methods (in real app, these would call repositories)

  Future<UserPreferences> _loadUserPreferences() async {
    // Simulate loading delay
    await Future<void>.delayed(const Duration(milliseconds: 500));

    // Return default preferences for now
    return const UserPreferences();
  }

  // Future<List<Pack>> _loadDailyPacks() async {
  //   try {
  //     // Load featured packs from the JSON file for daily packs
  //     final featuredPacks = await LocalPackService.instance.getFeaturedPacks();

  //     // Convert to Category objects and take first 3 for daily rotation
  //     final dailyPacks = featuredPacks
  //         .take(3)
  //         .map((pack) => LocalPackService.instance.convertToGamePack(pack))
  //         .toList();

  //     return dailyPacks;
  //   } catch (e) {
  //     // Fallback to empty list if loading fails
  //     return [];
  //   }
  // }

  Future<List<Pack>> _loadPacks() async {
    return LocalPackService().getPacks();
  }

  Future<List<Category>> _loadCategory() async {
    return LocalPackService().getCategories();
  }
}
