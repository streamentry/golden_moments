import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:golden_moments/data/models/category.dart';
import 'package:golden_moments/data/models/pack.dart';
import 'package:golden_moments/data/services/local_pack_service.dart';
import 'package:golden_moments/game/models/models.dart';
import 'package:golden_moments/home/cubit/home_state.dart';

/// Cubit for managing home screen state and logic
class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState());

  /// Initialize the home screen with data
  Future<void> initialize() async {
    await FirebaseAnalytics.instance.logScreenView(
      screenName: 'Home',
    );

    emit(state.copyWith(status: HomeStatus.loading));

    try {
      // Load packs
      final packs = await _loadPacks();
      // Random seed
      final today = DateTime.now();
      final seed =
          today.year * 10000 +
          today.month * 100 +
          today.day; // Unique seed for the day
      final random = Random(seed);
      packs.shuffle(random);

      // Get daily packs
      final dailyPacks = packs.take(4).toList();

      // Load library packs
      final libraryCategories = await _loadCategory();

      emit(
        state.copyWith(
          status: HomeStatus.loaded,
          dailyPacks: dailyPacks,
          libraryPacks: libraryCategories,
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

  /// Mark a pack as completed
  void markPackCompleted(String packId) {
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
