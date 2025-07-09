import 'dart:math';
import 'package:bloc/bloc.dart';
import 'package:memory_lane/game/models/models.dart';
import 'package:memory_lane/game/services/game_pack_loader.dart';
import 'package:memory_lane/shared/constants/app_constants.dart';

/// Cubit for managing game state and logic
class GameCubit extends Cubit<GameState> {
  GameCubit() : super(const GameState(
    currentPack: GamePack(
      id: 'empty',
      title: 'Empty',
      theme: 'Empty',
      tiles: [],
      difficulty: GameDifficulty.easy,
    ),
    tiles: [],
  ));

  final GamePackLoader _packLoader = GamePackLoader.instance;

  /// Load and start a new game with offline-first approach
  Future<void> loadAndStartGame(String packId) async {
    emit(state.copyWith(status: GameStatus.loading));

    try {
      final result = await _packLoader.loadGamePack(packId);

      if (result.isSuccess && result.gamePack != null) {
        startGame(result.gamePack!);

        // Emit additional metadata about the load
        if (result.isFromCache) {
          // Pack loaded from cache - fully offline
        } else if (result.requiresDownload) {
          // Pack requires download - show download UI
          emit(state.copyWith(
            status: GameStatus.requiresDownload,
            loadResult: result,
          ));
          return;
        }
      } else {
        emit(state.copyWith(
          status: GameStatus.failed,
          errorMessage: result.error ?? 'Failed to load pack',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: GameStatus.failed,
        errorMessage: 'Error loading pack: $e',
      ));
    }
  }

  /// Start a new game with the given pack
  void startGame(GamePack pack) {
    final shuffledTiles = _shuffleTiles(pack.tiles);

    emit(GameState(
      currentPack: pack,
      tiles: shuffledTiles,
      status: GameStatus.playing,
      moves: 0,
      matchedPairs: 0,
      selectedTiles: [],
      startTime: DateTime.now(),
    ));
  }

  /// Handle tile tap
  void onTileTap(String tileId) {
    if (state.status != GameStatus.playing) return;
    if (state.showingMismatch) return;
    
    final tileIndex = state.tiles.indexWhere((tile) => tile.id == tileId);
    if (tileIndex == -1) return;
    
    final tile = state.tiles[tileIndex];
    
    // Don't allow tapping already matched or revealed tiles
    if (tile.isMatched || tile.isRevealed) return;
    
    // Don't allow more than 2 tiles to be selected
    if (state.selectedTiles.length >= AppConstants.maxSelectedTiles) return;
    
    // Reveal the tile
    final updatedTiles = List<GameTile>.from(state.tiles);
    updatedTiles[tileIndex] = tile.copyWith(isRevealed: true);
    
    final updatedSelectedTiles = [...state.selectedTiles, tile.copyWith(isRevealed: true)];
    
    emit(state.copyWith(
      tiles: updatedTiles,
      selectedTiles: updatedSelectedTiles,
      moves: state.moves + 1,
    ));
    
    // Check for match if we have 2 tiles selected
    if (updatedSelectedTiles.length == AppConstants.maxSelectedTiles) {
      _checkForMatch();
    }
  }

  /// Check if the selected tiles match
  void _checkForMatch() {
    if (state.selectedTiles.length != AppConstants.maxSelectedTiles) return;
    
    final tile1 = state.selectedTiles[0];
    final tile2 = state.selectedTiles[1];
    
    final isMatch = tile1.pairId == tile2.pairId && tile1.id != tile2.id;
    
    if (isMatch) {
      _handleMatch();
    } else {
      _handleMismatch();
    }
  }

  /// Handle successful match
  void _handleMatch() {
    final updatedTiles = state.tiles.map((tile) {
      if (state.selectedTiles.any((selected) => selected.id == tile.id)) {
        return tile.copyWith(isMatched: true, isRevealed: true);
      }
      return tile;
    }).toList();
    
    final newMatchedPairs = state.matchedPairs + 1;
    final isGameCompleted = newMatchedPairs == state.currentPack.difficulty.pairCount;
    
    emit(state.copyWith(
      tiles: updatedTiles,
      selectedTiles: [],
      matchedPairs: newMatchedPairs,
      status: isGameCompleted ? GameStatus.completed : GameStatus.playing,
      endTime: isGameCompleted ? DateTime.now() : null,
    ));
    
    if (isGameCompleted) {
      _handleGameCompletion();
    }
  }

  /// Handle mismatch (hide tiles after delay)
  void _handleMismatch() {
    // Show mismatch state briefly
    emit(state.copyWith(showingMismatch: true));
    
    // After delay, hide the tiles
    Future<void>.delayed(AppConstants.mismatchDisplayDuration, () {
      if (state.showingMismatch) {
        final updatedTiles = state.tiles.map((tile) {
          if (state.selectedTiles.any((selected) => selected.id == tile.id)) {
            return tile.copyWith(isRevealed: false);
          }
          return tile;
        }).toList();
        
        emit(state.copyWith(
          tiles: updatedTiles,
          selectedTiles: [],
          showingMismatch: false,
        ));
      }
    });
  }

  /// Handle game completion
  void _handleGameCompletion() {
    // Add celebration delay
    Future<void>.delayed(AppConstants.packCompletionDelay, () {
      // Game completion logic can be extended here
      // For now, just ensure the state is properly set
    });
  }

  /// Pause the game
  void pauseGame() {
    if (state.status == GameStatus.playing) {
      emit(state.copyWith(status: GameStatus.paused));
    }
  }

  /// Resume the game
  void resumeGame() {
    if (state.status == GameStatus.paused) {
      emit(state.copyWith(status: GameStatus.playing));
    }
  }

  /// Reset the game
  void resetGame() {
    startGame(state.currentPack);
  }

  /// Shuffle tiles for game start
  List<GameTile> _shuffleTiles(List<GameTile> tiles) {
    final shuffledTiles = List<GameTile>.from(tiles);
    
    // Reset all tile states
    for (int i = 0; i < shuffledTiles.length; i++) {
      shuffledTiles[i] = shuffledTiles[i].copyWith(
        isMatched: false,
        isRevealed: false,
      );
    }
    
    // Shuffle the list
    final random = Random();
    for (int i = shuffledTiles.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final temp = shuffledTiles[i];
      shuffledTiles[i] = shuffledTiles[j];
      shuffledTiles[j] = temp;
    }
    
    return shuffledTiles;
  }

  /// Get hint (reveal a pair briefly)
  void showHint() {
    if (state.status != GameStatus.playing) return;
    if (state.selectedTiles.isNotEmpty) return;
    
    // Find an unmatched pair
    final unmatchedTiles = state.tiles.where((tile) => !tile.isMatched).toList();
    if (unmatchedTiles.length < 2) return;
    
    // Group by pair ID
    final pairGroups = <String, List<GameTile>>{};
    for (final tile in unmatchedTiles) {
      if (tile.pairId != null) {
        pairGroups[tile.pairId!] = pairGroups[tile.pairId!] ?? [];
        pairGroups[tile.pairId!]!.add(tile);
      }
    }
    
    // Find a complete pair
    final completePairs = pairGroups.entries
        .where((entry) => entry.value.length == 2)
        .toList();
    
    if (completePairs.isEmpty) return;
    
    // Pick a random pair to hint
    final random = Random();
    final hintPair = completePairs[random.nextInt(completePairs.length)].value;
    
    // Briefly reveal the pair
    final updatedTiles = state.tiles.map((tile) {
      if (hintPair.any((hintTile) => hintTile.id == tile.id)) {
        return tile.copyWith(isRevealed: true);
      }
      return tile;
    }).toList();
    
    emit(state.copyWith(tiles: updatedTiles));
    
    // Hide the hint after a short delay
    Future<void>.delayed(const Duration(milliseconds: 1000), () {
      final revertedTiles = state.tiles.map((tile) {
        if (hintPair.any((hintTile) => hintTile.id == tile.id) && !tile.isMatched) {
          return tile.copyWith(isRevealed: false);
        }
        return tile;
      }).toList();
      
      emit(state.copyWith(tiles: revertedTiles));
    });
  }
}
