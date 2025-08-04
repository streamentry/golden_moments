import 'dart:io';

import 'package:flutter/material.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/game/cubit/tile_state.dart';
import 'package:golden_moments/shared/utils/image_util.dart';

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
    final imagePath = getImageLocalPath(tile.image.id, packId);
    final image = FileImage(File(imagePath));

    return GmMemoryTile(
      revealed: tile.isRevealed || tile.isMatched,
      image: image,
      onTap: onTap,
    );
  }
}
