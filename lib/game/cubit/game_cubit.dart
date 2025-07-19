import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:golden_moments/data/models/image.dart';
import 'package:golden_moments/data/models/pack.dart';
import 'package:golden_moments/data/services/local_pack_service.dart';
import 'package:golden_moments/game/cubit/game_state.dart';
import 'package:golden_moments/game/cubit/tile_state.dart';
import 'package:golden_moments/shared/constants/app_constants.dart';

/// Cubit for managing game state and logic
class GameCubit extends Cubit<GameState> {
  GameCubit()
    : super(
        const GameState(
          currentPack: Pack(
            id: 'empty',
            title: 'Empty',
            theme: 'Empty',
            category: 'Empty',
            version: '1.0.0',
            thumbnailUrl: 'Empty',
            images: [],
            difficulty: GameDifficulty.easy,
          ),
          tiles: [],
        ),
      );

  final LocalPackService _localPackService = LocalPackService();

  /// Load and start a new game with offline-first approach
  Future<void> loadAndStartGame(String packId) async {
    emit(state.copyWith(status: GameStatus.loading));
    try {
      final pack = await _localPackService.getPackById(packId);
      startNewGame(pack);
    } on Exception {
      emit(state.copyWith(status: GameStatus.failed));
    }
  }

  /// Start a new game with the given pack
  void startNewGame(Pack pack) {
    final shuffledTiles = _shuffleTiles(pack.images, pack.difficulty);

    emit(
      GameState(
        currentPack: pack,
        tiles: shuffledTiles,
        status: GameStatus.playing,
        startTime: DateTime.now(),
      ),
    );
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

    final updatedSelectedTiles = [
      ...state.selectedTiles,
      tile.copyWith(isRevealed: true),
    ];

    emit(
      state.copyWith(
        tiles: updatedTiles,
        selectedTiles: updatedSelectedTiles,
        moves: state.moves + 1,
      ),
    );

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
    final isGameCompleted =
        newMatchedPairs == state.currentPack.difficulty.pairCount;

    emit(
      state.copyWith(
        tiles: updatedTiles,
        selectedTiles: [],
        matchedPairs: newMatchedPairs,
        status: isGameCompleted ? GameStatus.completed : GameStatus.playing,
        endTime: isGameCompleted ? DateTime.now() : null,
      ),
    );

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

        emit(
          state.copyWith(
            tiles: updatedTiles,
            selectedTiles: [],
            showingMismatch: false,
          ),
        );
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
    startNewGame(state.currentPack);
  }

  /// Shuffle tiles for game start
  List<GameTile> _shuffleTiles(List<Image> images, GameDifficulty difficulty) {
    // Convert images to game tiles
    final tiles = <GameTile>[];

    // Create pairs of tiles from images
    for (var i = 0; i < difficulty.pairCount; i++) {
      final image = images[i % images.length];
      final pairId = 'pair_${i % images.length}';
      // Add first tile of the pair
      tiles
        ..add(
          GameTile(
            id: '${image.id}_${i ~/ images.length * 2 + 1}',
            image: image,
            pairId: pairId,
          ),
        )
        // Add second tile of the pair
        ..add(
          GameTile(
            id: '${image.id}_${i ~/ images.length * 2 + 2}',
            image: image,
            pairId: pairId,
          ),
        );
    }

    // Shuffle the list
    final random = Random();
    for (var i = tiles.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final temp = tiles[i];
      tiles[i] = tiles[j];
      tiles[j] = temp;
    }

    return tiles;
  }

  /// Get hint (reveal a pair briefly)
  void showHint() {
    if (state.status != GameStatus.playing) return;
    if (state.selectedTiles.isNotEmpty) return;

    // Find an unmatched pair
    final unmatchedTiles = state.tiles
        .where((tile) => !tile.isMatched)
        .toList();
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
        if (hintPair.any((hintTile) => hintTile.id == tile.id) &&
            !tile.isMatched) {
          return tile.copyWith(isRevealed: false);
        }
        return tile;
      }).toList();

      emit(state.copyWith(tiles: revertedTiles));
    });
  }
}
