import 'package:flutter/material.dart';
import 'package:golden_moments/data/models/pack.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/game/cubit/tile_state.dart';
import 'package:golden_moments/features/game/presentation/widgets/memory_tile.dart';

/// Game board widget that displays the memory tiles in a grid
class GameBoard extends StatelessWidget {
  const GameBoard({
    required this.packId,
    required this.tiles,
    required this.difficulty,
    required this.onTileTap,
    super.key,
  });

  final String packId;
  final List<GameTile> tiles;
  final GameDifficulty difficulty;
  final void Function(String tileId) onTileTap;

  @override
  Widget build(BuildContext parentContext) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Tiles never shrink below gmTileMin; denser packs scroll instead.
        final fitting =
            ((constraints.maxWidth + gmTileGap) / (gmTileMin + gmTileGap))
                .floor();
        final crossAxisCount = fitting.clamp(
          2,
          _getCrossAxisCount(difficulty),
        );
        final aspectRatio = _getAspectRatio(difficulty);

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: aspectRatio,
            crossAxisSpacing: gmTileGap,
            mainAxisSpacing: gmTileGap,
          ),
          itemCount: tiles.length,
          itemBuilder: (context, index) {
            final tile = tiles[index];
            return MemoryTile(
              packId: packId,
              tile: tile,
              onTap: () => onTileTap(tile.id),
            );
          },
        );
      },
    );
  }

  /// Get the number of columns based on difficulty
  int _getCrossAxisCount(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.easy:
        return 3; // 3x4 grid
      case GameDifficulty.medium:
        return 4; // 4x4 grid
      case GameDifficulty.hard:
        return 4; // 4x6 grid
      case GameDifficulty.brainy:
        return 5; // 5x6 grid
    }
  }

  /// Get the aspect ratio for tiles based on difficulty
  double _getAspectRatio(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.easy:
        return 1; // Slightly taller than wide
      case GameDifficulty.medium:
        return 1; // Square
      case GameDifficulty.hard:
        return 1; // Square
      case GameDifficulty.brainy:
        return 1; // Square
    }
  }
}
