import 'package:flutter/material.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/game/cubit/tile_state.dart';

/// Individual memory tile widget using the design system
class MemoryTile extends StatelessWidget {
  const MemoryTile({
    required this.packId,
    required this.tile,
    required this.onTap,
    super.key,
  });

  final String packId;
  final GameTile tile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext parentContext) {
    final revealed = tile.isRevealed || tile.isMatched;
    Widget buildTile(ImageProvider provider) => Semantics(
      label: tile.isMatched
          ? 'Matched: ${tile.image.caption}'
          : revealed
          ? tile.image.caption
          : 'Hidden tile',
      button: true,
      enabled: !revealed,
      child: GmMemoryTile(
        revealed: tile.isRevealed || tile.isMatched,
        image: provider,
        onTap: onTap,
      ),
    );

    return buildTile(AssetImage(tile.image.url));
  }
}
