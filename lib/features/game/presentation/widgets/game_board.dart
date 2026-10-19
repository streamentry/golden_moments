import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/game/cubit/tile_state.dart';
import 'package:golden_moments/features/game/presentation/widgets/memory_tile.dart';

/// The picture-pack board: square tiles as large as the space allows, never
/// below [gmTileMin] (DESIGN.md › Layout › Tile grid).
class GameBoard extends StatelessWidget {
  const new({
    required this.tiles,
    required this.onTileTap,
    this.selectedTileIds = const {},
    this.waitingForNextTap = false,
    this.heightBudget,
    super.key,
  });

  final List<GameTile> tiles;
  final void Function(String tileId) onTileTap;

  /// Tiles chosen in the current turn.
  final Set<String> selectedTileIds;

  /// A mismatch or hint is face up; any unmatched tile's tap turns it over.
  final bool waitingForNextTap;

  /// Height to fit the board into when the board itself sits in a scroll
  /// view (unbounded height).
  final double? heightBudget;

  /// Columns and tile side for [count] square tiles in [size].
  ///
  /// Picks the largest tile that lets the whole board fit, so nothing has to
  /// be remembered while scrolling. When no layout fits at [gmTileMin], the
  /// tiles stay at that minimum in as many columns as the width allows, so
  /// the board scrolls as little as possible.
  static ({int columns, double tile}) fit({
    required int count,
    required Size size,
  }) {
    double byWidth(int columns) =>
        (size.width - gmTileGap * (columns - 1)) / columns;
    final most = math.max(2, count);
    var best = (columns: 2, tile: 0.0);
    for (var columns = 2; columns <= most; columns++) {
      final rows = (count / columns).ceil();
      final byHeight = size.height.isFinite
          ? (size.height - gmTileGap * (rows - 1)) / rows
          : double.infinity;
      final tile = math.min(byWidth(columns), byHeight);
      if (tile > best.tile) best = (columns: columns, tile: tile);
    }
    // Whole logical pixels, so rounding can never push the last tile of a
    // row onto the next one.
    if (best.tile >= gmTileMin) {
      return (columns: best.columns, tile: best.tile.floorToDouble());
    }
    var columns = most;
    while (columns > 2 && byWidth(columns) < gmTileMin) {
      columns--;
    }
    // The fewest rows that width allows, with the tiles spread evenly over
    // them (12 tiles as 6 + 6, not 9 + 3).
    final rows = (count / columns).ceil();
    columns = math.max(2, (count / rows).ceil());
    return (columns: columns, tile: gmTileMin);
  }

  bool _canTap(GameTile tile) {
    if (tile.isMatched) return false;
    return !tile.isRevealed || waitingForNextTap;
  }

  @override
  Widget build(BuildContext parentContext) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bounded = constraints.hasBoundedHeight;
        final height = bounded
            ? constraints.maxHeight
            : heightBudget ?? constraints.maxWidth;
        final count = tiles.length;
        final (:columns, :tile) = fit(
          count: count,
          size: Size(constraints.maxWidth, height),
        );
        final rows = (count / columns).ceil();
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
