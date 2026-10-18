import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:golden_moments/data/models/pack.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/game/cubit/tile_state.dart';
import 'package:golden_moments/features/game/presentation/widgets/memory_tile.dart';

/// The picture-pack board: square tiles as large as the space allows, never
/// below [gmTileMin] (DESIGN.md › Layout › Tile grid).
class GameBoard extends StatelessWidget {
  const new({
    required this.tiles,
    required this.difficulty,
    required this.onTileTap,
    this.selectedTileIds = const {},
    this.waitingForNextTap = false,
    this.heightBudget,
    super.key,
  });

  final List<GameTile> tiles;
  final GameDifficulty difficulty;
  final void Function(String tileId) onTileTap;

  /// Tiles chosen in the current turn.
  final Set<String> selectedTileIds;

  /// A mismatch or hint is face up; any unmatched tile's tap turns it over.
  final bool waitingForNextTap;

  /// Height to fit the board into when the board itself sits in a scroll
  /// view (unbounded height).
  final double? heightBudget;

  bool _canTap(GameTile tile) {
    if (tile.isMatched) return false;
    return !tile.isRevealed || waitingForNextTap;
  }

  @override
  Widget build(BuildContext parentContext) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final bounded = constraints.hasBoundedHeight;
        final height = bounded
            ? constraints.maxHeight
            : heightBudget ?? constraints.maxWidth;
        final count = tiles.length;
        // Wide, short screens may use more columns so the whole board still
        // fits; tiles stay at least gmTileMin either way.
        final columns = gmBoardColumns(
          tileCount: count,
          maxColumns: math.max(
            difficulty.gridSize,
            (width / (gmTileMin + gmTileGap)).floor(),
          ),
          size: Size(width, height),
        );
        final rows = (count / columns).ceil();
        final tile = math.max(
          gmTileMin,
          math.min(
            (width - gmTileGap * (columns - 1)) / columns,
            (height - gmTileGap * (rows - 1)) / rows,
          ),
        );
        final grid = Center(
          child: SizedBox(
            width: columns * tile + gmTileGap * (columns - 1),
            child: Wrap(
              spacing: gmTileGap,
              runSpacing: gmTileGap,
              children: [
                for (var index = 0; index < count; index++)
                  SizedBox.square(
                    dimension: tile,
                    child: MemoryTile(
                      tile: tiles[index],
                      position: index + 1,
                      selected: selectedTileIds.contains(tiles[index].id),
                      onTap: _canTap(tiles[index])
                          ? () => onTileTap(tiles[index].id)
                          : null,
                    ),
                  ),
              ],
            ),
          ),
        );
        final boardHeight = rows * tile + gmTileGap * (rows - 1);
        // Only a board that cannot fit at the minimum tile size scrolls.
        if (bounded && boardHeight > constraints.maxHeight) {
          return SingleChildScrollView(child: grid);
        }
        return grid;
      },
    );
  }
}
