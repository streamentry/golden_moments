import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:golden_moments/data/models/image.dart';
import 'package:golden_moments/data/models/pack.dart';
import 'package:golden_moments/data/services/local_pack_service.dart';
import 'package:golden_moments/features/game/cubit/game_state.dart';
import 'package:golden_moments/features/game/cubit/tile_state.dart';
import 'package:golden_moments/shared/constants/app_constants.dart';

/// Cubit for managing game state and logic
class GameCubit extends Cubit<GameState> {
  new()
    : super(
        const GameState(
          currentPack: Pack(
            id: 'empty',
            title: 'Empty',
            theme: 'Empty',
            category: 'Empty',
            version: '1.0.0',
            thumbnailUrl: 'Empty',
            estimatedSize: '0 MB',
            images: [],
            difficulty: GameDifficulty.easy,
          ),
          images: [],
          tiles: [],
        ),
      );

  final LocalPackService _localPackService = LocalPackService();

  /// Load and start a new game with offline-first approach
  Future<void> loadAndStartGame(String packId) async {
    emit(state.copyWith(status: GameStatus.loading));
    try {
      final pack = await _localPackService.getPackById(packId);

      // The catalog and every picture ship together. Check local assets only;
      // a missing package asset is a build error, never a download prompt.
      final images = <Image>[];
      for (final image in pack.images) {
        await rootBundle.load(image.url);
        if (isClosed) return;
        images.add(image);
      }
      if (images.length < pack.difficulty.minImages) {
        emit(state.copyWith(status: GameStatus.failed));
        return;
      }
      emit(state.copyWith(images: images));

      startNewGame(pack);
    } on Object {
      if (isClosed) return;
      emit(state.copyWith(status: GameStatus.failed));
    }
  }

  /// Start a new game with the given pack
  void startNewGame(Pack pack) {
    final shuffledTiles = _shuffleTiles(state.images, pack.difficulty);

    emit(
      GameState(
        currentPack: pack,
        images: state.images,
        tiles: shuffledTiles,
        status: GameStatus.playing,
        startTime: DateTime.now(),
      ),
    );
  }

  /// Handle tile tap
  void onTileTap(String tileId) {
    if (state.status != GameStatus.playing) return;
    // A mismatch or hint stays visible until this deliberate tap; nothing
    // is hidden on a timer (DESIGN.md › Interaction & Game Feel).
    _hideMismatchAndHint();

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
        lastTurnMatched: false,
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
        lastTurnMatched: true,
        status: isGameCompleted ? GameStatus.completed : GameStatus.playing,
        endTime: isGameCompleted ? DateTime.now() : null,
      ),
    );
  }

  /// A non-matching pair stays face up until the player's next tap.
  void _handleMismatch() {
    emit(state.copyWith(showingMismatch: true));
  }

  /// Turns a shown mismatch or hint face down again before the next turn.
  void _hideMismatchAndHint() {
    if (!state.showingMismatch && state.hintTileIds.isEmpty) return;
    final hide = {
      if (state.showingMismatch) ...state.selectedTiles.map((tile) => tile.id),
      ...state.hintTileIds,
    };
    emit(
      state.copyWith(
        tiles: state.tiles
            .map(
              (tile) => hide.contains(tile.id) && !tile.isMatched
                  ? tile.copyWith(isRevealed: false)
                  : tile,
            )
            .toList(),
        selectedTiles: state.showingMismatch ? [] : state.selectedTiles,
        showingMismatch: false,
        hintTileIds: [],
      ),
    );
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

  /// Hint: show one matching pair until the player's next tap.
  void showHint() {
    if (state.status != GameStatus.playing) return;
    if (state.selectedTiles.isNotEmpty || state.showingMismatch) return;
    if (state.hintTileIds.isNotEmpty) return;

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

    final random = Random();
    final hintIds = completePairs[random.nextInt(completePairs.length)].value
        .map((tile) => tile.id)
        .toList();

    emit(
      state.copyWith(
        tiles: state.tiles
            .map(
              (tile) => hintIds.contains(tile.id)
                  ? tile.copyWith(isRevealed: true)
                  : tile,
            )
            .toList(),
        hintTileIds: hintIds,
        lastTurnMatched: false,
      ),
    );
  }
}
