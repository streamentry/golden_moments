import 'package:equatable/equatable.dart';
import 'package:golden_moments/data/models/image.dart';
import 'package:golden_moments/game/models/game_tile.dart';

/// Difficulty levels for the memory game
enum GameDifficulty {
  easy(gridSize: 3, pairCount: 4, displayName: 'Easy'),
  medium(gridSize: 4, pairCount: 8, displayName: 'Medium'),
  hard(gridSize: 5, pairCount: 12, displayName: 'Hard'),
  brainy(gridSize: 6, pairCount: 12, displayName: 'Brainy');

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
class Pack extends Equatable {
  const Pack({
    required this.id,
    required this.title,
    required this.theme,
    required this.version,
    required this.difficulty,
    required this.thumbnailUrl,
    required this.images,
    this.isCompleted = false,
    this.isPremium = false,
    this.description,
  });

  /// Creates a GamePack from JSON data
  factory Pack.fromJson(Map<String, dynamic> json) {
    return Pack(
      id: json['id'] as String,
      title: json['title'] as String,
      theme: json['theme'] as String,
      difficulty: GameDifficulty.values.firstWhere(
        (d) => d.name == (json['difficulty'] as String),
        orElse: () => GameDifficulty.medium,
      ),
      version: json['version'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      images: (json['images'] as List<dynamic>? ?? [])
          .map((tile) => Image.fromJson(tile as Map<String, dynamic>))
          .toList(),
      isCompleted: json['isCompleted'] as bool? ?? false,
      isPremium: json['isPremium'] as bool? ?? false,
      description: json['description'] as String?,
    );
  }

  /// Unique identifier for this pack
  final String id;

  /// Display title for the pack
  final String title;

  /// Optional description of the pack
  final String? description;

  /// Theme category (e.g., "1960s Cars", "Classic Movies")
  final String theme;

  /// Version
  final String version;

  /// Thumbnail url
  final String thumbnailUrl;

  /// Difficulty level of this pack
  final GameDifficulty difficulty;

  /// Whether the user has completed this pack
  final bool isCompleted;

  /// Whether this pack requires premium subscription
  final bool isPremium;

  /// List image of this pack
  final List<Image> images;

  /// Converts this GamePack to JSON data
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'theme': theme,
      'version': version,
      'thumbnailUrl': thumbnailUrl,
      'images': images,
      'difficulty': difficulty.name,
      'isCompleted': isCompleted,
      'isPremium': isPremium,
      if (description != null) 'description': description,
    };
  }

  /// Creates a copy of this pack with updated properties
  Pack copyWith({
    String? id,
    String? title,
    String? theme,
    String? version,
    String? thumbnailUrl,
    List<Image>? images,
    GameDifficulty? difficulty,
    bool? isCompleted,
    bool? isPremium,
    String? description,
  }) {
    return Pack(
      id: id ?? this.id,
      title: title ?? this.title,
      theme: theme ?? this.theme,
      version: version ?? this.version,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      images: images ?? this.images,
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
    version,
    thumbnailUrl,
    images,
    difficulty,
    isCompleted,
    isPremium,
    description,
  ];
}
