import 'package:flutter/material.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/game/cubit/tile_state.dart';
import 'package:golden_moments/l10n/l10n.dart';

/// One picture tile on the picture-pack board.
///
/// The tile is a single button for screen readers (GM-014). A hidden tile is
/// announced only by its position ("Hidden picture, tile 3"); its picture
/// name, asset and pair stay out of the semantics tree until it is shown.
class MemoryTile extends StatelessWidget {
  const new({
    required this.tile,
    required this.position,
    required this.onTap,
    this.selected = false,
    super.key,
  });

  final GameTile tile;

  /// 1-based place on the board, used in the spoken label.
  final int position;

  /// Whether this is one of the pictures chosen in the current turn.
  final bool selected;

  /// Null when the tile cannot be chosen right now (for example, matched).
  final VoidCallback? onTap;

  /// Spoken label: positional while hidden, the picture's name once shown.
  static String labelFor(GameTile tile, int position, AppLocalizations l10n) {
    if (!tile.isRevealed && !tile.isMatched) {
      return l10n.gameTileHidden(position);
    }
    final caption = tile.image.caption.trim();
    return caption.isEmpty
        ? l10n.gameTilePicture(position)
        : l10n.gameTileNamed(caption, position);
  }

  @override
  Widget build(BuildContext parentContext) {
    final l10n = parentContext.l10n;
    final revealed = tile.isRevealed || tile.isMatched;
    return Semantics(
      container: true,
      button: true,
      enabled: onTap != null,
      onTap: onTap,
      label: labelFor(tile, position, l10n),
      value: tile.isMatched
          ? l10n.commonMatched
          : selected
          ? l10n.commonSelected
          : '',
      // Everything inside is visual only, so nothing hidden can leak.
      child: ExcludeSemantics(
        child: GmMemoryTile(
          revealed: revealed,
          matched: tile.isMatched,
          selected: selected,
          image: AssetImage(tile.image.url),
          onTap: onTap,
        ),
      ),
    );
  }
}
