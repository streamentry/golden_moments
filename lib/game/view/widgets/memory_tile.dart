import 'package:flutter/material.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/game/models/models.dart';

/// Individual memory tile widget using the design system
class MemoryTile extends StatelessWidget {
  const MemoryTile({
    super.key,
    required this.tile,
    required this.onTap,
  });

  final GameTile tile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Create a placeholder image for now - in a real app this would be
    // loaded from assets
    const image = AssetImage('assets/images/placeholder.png');

    return GmMemoryTile(
      revealed: tile.isRevealed || tile.isMatched,
      image: image,
      onTap: onTap,
    );
  }
}
