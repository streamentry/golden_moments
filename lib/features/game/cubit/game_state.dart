import 'package:equatable/equatable.dart';
import 'package:golden_moments/data/models/image.dart';
import 'package:golden_moments/data/models/pack.dart';
import 'package:golden_moments/features/game/cubit/tile_state.dart';

/// Current status of the game
enum GameStatus {
  initial,
  loading,
  playing,
  paused,
  completed,
  failed,
  requiresDownload,
}

/// Represents the current state of an active memory game
class GameState extends Equatable {
  const new({
    required this.currentPack,
    required this.images,
    required this.tiles,
    this.status = GameStatus.initial,
    this.moves = 0,
    this.matchedPairs = 0,
    this.selectedTiles = const [],
    this.startTime,
    this.endTime,
    this.showingMismatch = false,
    this.lastTurnMatched = false,
    this.hintTileIds = const [],
    this.errorMessage,
    this.loadResult,
  });

  /// The game pack currently being played
  final Pack currentPack;

  /// Available images of the pack
  final List<Image> images;

  /// Current state of all tiles in the game
  final List<GameTile> tiles;

  /// Current status of the game
  final GameStatus status;

  /// Number of moves (tile flips) made by the player
  final int moves;

  /// Number of pairs successfully matched
  final int matchedPairs;

  /// Currently selected/revealed tiles (max 2)
  final List<GameTile> selectedTiles;

  /// When the game started
  final DateTime? startTime;

  /// When the game ended
  final DateTime? endTime;

  /// Whether a non-matching pair stays visible until the next tap
  final bool showingMismatch;

  /// The latest turn made a pair; cleared by the next tap or hint. Lets the
  /// header announce a match once, without praise.
  final bool lastTurnMatched;

  /// Tiles revealed by a hint; they stay visible until the next tap
  final List<String> hintTileIds;

  /// Error message for failed states
  final String? errorMessage;

  /// Result of pack loading operation
  final dynamic loadResult;

  /// Whether the game is completed
  bool get isCompleted => matchedPairs == currentPack.difficulty.pairCount;

  /// Total time taken to complete the game
  Duration? get completionTime {
    if (startTime != null && endTime != null) {
      return endTime!.difference(startTime!);
    }
    return null;
  }

  /// Creates a copy of this state with updated properties
  GameState copyWith({
    Pack? currentPack,
    List<Image>? images,
    List<GameTile>? tiles,
    GameStatus? status,
    int? moves,
    int? matchedPairs,
    List<GameTile>? selectedTiles,
    DateTime? startTime,
    DateTime? endTime,
    bool? showingMismatch,
    bool? lastTurnMatched,
    List<String>? hintTileIds,
    String? errorMessage,
    dynamic loadResult,
  }) {
    return GameState(
      currentPack: currentPack ?? this.currentPack,
      images: images ?? this.images,
      tiles: tiles ?? this.tiles,
      status: status ?? this.status,
      moves: moves ?? this.moves,
      matchedPairs: matchedPairs ?? this.matchedPairs,
      selectedTiles: selectedTiles ?? this.selectedTiles,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      showingMismatch: showingMismatch ?? this.showingMismatch,
      lastTurnMatched: lastTurnMatched ?? this.lastTurnMatched,
      hintTileIds: hintTileIds ?? this.hintTileIds,
      errorMessage: errorMessage ?? this.errorMessage,
      loadResult: loadResult ?? this.loadResult,
    );
  }

  @override
  List<Object?> get props => [
    currentPack,
    images,
    tiles,
    status,
    moves,
    matchedPairs,
    selectedTiles,
    startTime,
    endTime,
    showingMismatch,
    lastTurnMatched,
    hintTileIds,
    errorMessage,
    loadResult,
  ];
}
