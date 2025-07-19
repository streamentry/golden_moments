import 'package:equatable/equatable.dart';
import 'package:golden_moments/data/models/category.dart';
import 'package:golden_moments/data/models/pack.dart';

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
    this.errorMessage,
  });

  /// Current status of the home screen
  final HomeStatus status;

  /// Daily featured game packs
  final List<Pack> dailyPacks;

  /// All available game packs in library
  final List<Category> libraryPacks;

  /// Error message if status is error
  final String? errorMessage;

  /// Creates a copy of this state with updated properties
  HomeState copyWith({
    HomeStatus? status,
    List<Pack>? dailyPacks,
    List<Category>? libraryPacks,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      dailyPacks: dailyPacks ?? this.dailyPacks,
      libraryPacks: libraryPacks ?? this.libraryPacks,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    dailyPacks,
    libraryPacks,
    errorMessage,
  ];
}
