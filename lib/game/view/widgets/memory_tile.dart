import 'dart:io';

import 'package:flutter/material.dart';
import 'package:golden_moments/data/services/json_cache_service.dart';
import 'package:golden_moments/data/storage/cache_file_paths.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/game/cubit/tile_state.dart';

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
    final fileName = '${tile.image.id}.jpg';
    final imagePath = CacheFilePaths.imageFile(packId, fileName);
    final fullPath = JsonCacheService().fileManager.getCachePath(imagePath);
    final image = FileImage(File(fullPath));

    return GmMemoryTile(
      revealed: tile.isRevealed || tile.isMatched,
      image: image,
      onTap: onTap,
    );
  }
}
