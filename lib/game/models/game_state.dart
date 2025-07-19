import 'package:equatable/equatable.dart';
import 'package:golden_moments/game/models/game_pack.dart';
import 'package:golden_moments/game/models/game_tile.dart';

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
  const GameState({
    required this.currentPack,
    required this.tiles,
    this.status = GameStatus.initial,
    this.moves = 0,
    this.matchedPairs = 0,
    this.selectedTiles = const [],
    this.startTime,
    this.endTime,
    this.showingMismatch = false,
    this.errorMessage,
    this.loadResult,
  });

  /// The game pack currently being played
  final GamePack currentPack;

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

  /// Whether we're currently showing a mismatch (brief pause)
  final bool showingMismatch;

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
    GamePack? currentPack,
    List<GameTile>? tiles,
    GameStatus? status,
    int? moves,
    int? matchedPairs,
    List<GameTile>? selectedTiles,
    DateTime? startTime,
    DateTime? endTime,
    bool? showingMismatch,
    String? errorMessage,
    dynamic loadResult,
  }) {
    return GameState(
      currentPack: currentPack ?? this.currentPack,
      tiles: tiles ?? this.tiles,
      status: status ?? this.status,
      moves: moves ?? this.moves,
      matchedPairs: matchedPairs ?? this.matchedPairs,
      selectedTiles: selectedTiles ?? this.selectedTiles,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      showingMismatch: showingMismatch ?? this.showingMismatch,
      errorMessage: errorMessage ?? this.errorMessage,
      loadResult: loadResult ?? this.loadResult,
    );
  }

  @override
  List<Object?> get props => [
    currentPack,
    tiles,
    status,
    moves,
    matchedPairs,
    selectedTiles,
    startTime,
    endTime,
    showingMismatch,
    errorMessage,
    loadResult,
  ];
}
