import 'package:equatable/equatable.dart';
import 'package:memory_lane/game/models/game_tile.dart';

/// Difficulty levels for the memory game
enum GameDifficulty {
  easy(gridSize: 3, pairCount: 6, displayName: 'Easy'),
  medium(gridSize: 4, pairCount: 8, displayName: 'Medium'),
  brainy(gridSize: 6, pairCount: 18, displayName: 'Brainy');

  const GameDifficulty({
    required this.gridSize,
    required this.pairCount,
    required this.displayName,
  });

  /// Grid size (e.g., 3 means 3x4 grid for easy mode)
  final int gridSize;

  /// Number of pairs in this difficulty
  final int pairCount;

  /// Human-readable name for the difficulty
  final String displayName;

  /// Total number of tiles (pairs * 2)
  int get totalTiles => pairCount * 2;
}

/// Represents a themed collection of memory game tiles
class GamePack extends Equatable {
  const GamePack({
    required this.id,
    required this.title,
    required this.theme,
    required this.tiles,
    required this.difficulty,
    this.isCompleted = false,
    this.isPremium = false,
    this.description,
  });

  /// Unique identifier for this pack
  final String id;

  /// Display title for the pack
  final String title;

  /// Theme category (e.g., "1960s Cars", "Classic Movies")
  final String theme;

  /// List of tiles in this pack
  final List<GameTile> tiles;

  /// Difficulty level of this pack
  final GameDifficulty difficulty;

  /// Whether the user has completed this pack
  final bool isCompleted;

  /// Whether this pack requires premium subscription
  final bool isPremium;

  /// Optional description of the pack
  final String? description;

  /// Creates a copy of this pack with updated properties
  GamePack copyWith({
    String? id,
    String? title,
    String? theme,
    List<GameTile>? tiles,
    GameDifficulty? difficulty,
    bool? isCompleted,
    bool? isPremium,
    String? description,
  }) {
    return GamePack(
      id: id ?? this.id,
      title: title ?? this.title,
      theme: theme ?? this.theme,
      tiles: tiles ?? this.tiles,
      difficulty: difficulty ?? this.difficulty,
      isCompleted: isCompleted ?? this.isCompleted,
      isPremium: isPremium ?? this.isPremium,
      description: description ?? this.description,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        theme,
        tiles,
        difficulty,
        isCompleted,
        isPremium,
        description,
      ];
}
