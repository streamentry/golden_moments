import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:golden_moments/data/services/json_cache_service.dart';
import 'package:golden_moments/data/storage/cache_file_paths.dart';

Future<bool> isImageValid(String path) async {
  final file = File(path);
  if (!file.existsSync() || file.lengthSync() == 0) {
    return false;
  }
  try {
    final bytes = await file.readAsBytes();
    await ui.instantiateImageCodec(bytes);
    return true;
  } on Object catch (e) {
    debugPrint('Invalid image: $e');
    return false;
  }
}

String getImageLocalPath(String imageId, String packId) {
  final fileName = '$imageId.jpg';
  final imagePath = CacheFilePaths.imageFile(packId, fileName);
  final fullPath = JsonCacheService().fileManager.getCachePath(imagePath);
  return fullPath;
}
