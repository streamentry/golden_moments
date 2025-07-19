import 'package:equatable/equatable.dart';
import 'package:golden_moments/game/models/models.dart';

/// Status of the home screen
enum HomeStatus {
  initial,
  loading,
  loaded,
  error,
}

/// State for the home screen
class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.dailyPacks = const [],
    this.libraryPacks = const [],
    this.userPreferences = const UserPreferences(),
    this.errorMessage,
  });

  /// Current status of the home screen
  final HomeStatus status;

  /// Daily featured game packs
  final List<GamePack> dailyPacks;

  /// All available game packs in library
  final List<GamePack> libraryPacks;

  /// User preferences and settings
  final UserPreferences userPreferences;

  /// Error message if status is error
  final String? errorMessage;

  /// Creates a copy of this state with updated properties
  HomeState copyWith({
    HomeStatus? status,
    List<GamePack>? dailyPacks,
    List<GamePack>? libraryPacks,
    UserPreferences? userPreferences,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      dailyPacks: dailyPacks ?? this.dailyPacks,
      libraryPacks: libraryPacks ?? this.libraryPacks,
      userPreferences: userPreferences ?? this.userPreferences,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    dailyPacks,
    libraryPacks,
    userPreferences,
    errorMessage,
  ];
}
