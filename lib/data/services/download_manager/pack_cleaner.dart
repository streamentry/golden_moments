import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:golden_moments/data/models/pack.dart';
import 'package:golden_moments/data/services/json_cache_service.dart';
import 'package:golden_moments/data/services/local_pack_service.dart';
import 'package:golden_moments/shared/utils/image_util.dart';

/// Handles pack deletion and cleanup operations
class PackCleaner {
  PackCleaner({
    JsonCacheService? cacheService,
    LocalPackService? localPackService,
  }) : _cacheService = cacheService ?? JsonCacheService(),
       _localPackService = localPackService ?? LocalPackService();

  final JsonCacheService _cacheService;
  final LocalPackService _localPackService;

  /// Delete a complete pack and all associated files
  Future<PackCleanupResult> deletePack(String packId) async {
    final result = PackCleanupResult(packId: packId);

    try {
      // Get pack information before deletion
      final pack = await _localPackService.getPackById(packId);
      result.totalImages = pack.images.length;

      // Delete image files (skip on web)
      final imageCleanupResults = await _deletePackImages(pack);
      result.deletedImages = imageCleanupResults.deletedCount;
      result.failedImages = imageCleanupResults.failedCount;
      result.imageErrors.addAll(imageCleanupResults.errors);

      // Delete pack cache
      await _cacheService.deletePackCache(packId);
      result.cacheDeleted = true;

      // Clean up any temporary files
      await _cleanupTemporaryFiles(packId);
      result.tempFilesDeleted = true;

      result.success = true;
      result.message = 'Pack deleted successfully';
    } on Exception catch (e) {
      result.success = false;
      result.message = 'Failed to delete pack: $e';
      result.error = e;
    }

    return result;
  }

  /// Delete all image files for a pack
  Future<ImageCleanupResult> _deletePackImages(Pack pack) async {
    final result = ImageCleanupResult();

    // Skip file deletion on web platform
    if (kIsWeb) {
      debugPrint('File deletion skipped on web platform');
      result.deletedCount = pack.images.length; // Assume success on web
      return result;
    }

    for (final image in pack.images) {
      try {
        final imagePath = getImageLocalPath(image.id, pack.id);
        final imageFile = File(imagePath);

        if (imageFile.existsSync()) {
          await imageFile.delete();
          result.deletedCount++;
        } else {
          // File doesn't exist, consider it already deleted
          result.deletedCount++;
        }
      } on Exception catch (e) {
        result.failedCount++;
        result.errors.add(
          ImageDeletionError(
            imageId: image.id,
            imagePath: getImageLocalPath(image.id, pack.id),
            error: e,
          ),
        );
        result.errors.add(
          ImageDeletionError(
            imageId: image.id,
            imagePath: getImageLocalPath(image.id, pack.id),
            error: e,
          ),
        );
      }
    }

    return result;
  }

  /// Clean up temporary files for a pack
  Future<void> _cleanupTemporaryFiles(String packId) async {
    if (kIsWeb) return; // No temp files on web

    try {
      // Clean up any partial download files
      final tempDir = Directory.systemTemp;
      final packTempDir = Directory(
        '${tempDir.path}/golden_moments_temp/$packId',
      );

      final packTempDir = Directory(
        '${tempDir.path}/golden_moments_temp/$packId',
      );

      if (packTempDir.existsSync()) {
        await packTempDir.delete(recursive: true);
      }
    } on Exception catch (e) {
      debugPrint('Failed to clean temporary files for pack $packId: $e');
      // Don't throw as this is not critical
    }
  }

  /// Delete multiple packs
  Future<BatchCleanupResult> deletePacks(List<String> packIds) async {
    final result = BatchCleanupResult();

    for (final packId in packIds) {
      final packResult = await deletePack(packId);

      if (packResult.success) {
        result.successfulDeletions.add(packResult);
      } else {
        result.failedDeletions.add(packResult);
      }
    }

    result.success = result.failedDeletions.isEmpty;

    return result;
  }

  /// Clean up all cached packs
  Future<CleanupSummary> cleanupAllCachedPacks() async {
    final summary = CleanupSummary();

    try {
      // Get all packs
      final packs = await _localPackService.getPacks();

      // Clean up each pack
      for (final pack in packs) {
        if (await _cacheService.isPackCached(pack.id)) {
          final result = await deletePack(pack.id);

          if (result.success) {
            summary.cleanedPacks.add(pack.id);
            summary.totalImagesDeleted += result.deletedImages;
            summary.totalSpaceFreed += await _estimatePackSize(pack);
          } else {
            summary.failedPacks.add(pack.id);
            summary.errors.add(result.error);
          }
        }
      }

      summary.success = summary.failedPacks.isEmpty;
    } on Exception catch (e) {
      summary.success = false;
      summary.errors.add(e);
    }

    return summary;
  }

  /// Estimate pack size in bytes
  Future<int> _estimatePackSize(Pack pack) async {
    if (kIsWeb) return 0; // Can't determine size on web

    int totalSize = 0;

    for (final image in pack.images) {
      try {
        final imagePath = getImageLocalPath(image.id, pack.id);
        final imageFile = File(imagePath);

        if (imageFile.existsSync()) {
          totalSize += imageFile.lengthSync();
        }
      } on Exception {
        // Ignore errors when calculating size
      }
    }

    return totalSize;
  }

  /// Check which packs can be cleaned up
  Future<List<CleanupCandidate>> getCleanupCandidates() async {
    final candidates = <CleanupCandidate>[];

    try {
      final packs = await _localPackService.getPacks();

      for (final pack in packs) {
        if (await _cacheService.isPackCached(pack.id)) {
          final estimatedSize = await _estimatePackSize(pack);
          final lastAccessed = await _getLastAccessTime(pack.id);

          candidates.add(
            CleanupCandidate(
              packId: pack.id,
              packName: pack.title,
              imageCount: pack.images.length,
              estimatedSize: estimatedSize,
              lastAccessed: lastAccessed,
            ),
          );
        }
      }

      // Sort by last accessed (oldest first)
      candidates.sort((a, b) => a.lastAccessed.compareTo(b.lastAccessed));
    } on Exception catch (e) {
      debugPrint('Failed to get cleanup candidates: $e');
    }

    return candidates;
  }

  /// Get last access time for a pack
  Future<DateTime> _getLastAccessTime(String packId) async {
    try {
      final packCache = await _cacheService.getPackCache(packId);
      return packCache?.lastAccessed ?? DateTime.now();
    } on Exception {
      return DateTime.now();
    }
  }

  /// Verify pack deletion was successful
  Future<bool> verifyPackDeletion(String packId) async {
    // Check if cache is deleted
    if (await _cacheService.isPackCached(packId)) {
      return false;
    }

    // Check if files are deleted (skip on web)
    if (!kIsWeb) {
      try {
        final pack = await _localPackService.getPackById(packId);

        for (final image in pack.images) {
          final imagePath = getImageLocalPath(image.id, packId);
          final imageFile = File(imagePath);

          if (imageFile.existsSync()) {
            return false; // Found a file that should have been deleted
          }
        }
      } on Exception {
        // Pack might not exist anymore, which is fine
      }
    }

    return true;
  }

  /// Get total size of all cached packs
  Future<int> getTotalCachedSize() async {
    if (kIsWeb) return 0;

    int totalSize = 0;

    try {
      final packs = await _localPackService.getPacks();

      for (final pack in packs) {
        if (await _cacheService.isPackCached(pack.id)) {
          totalSize += await _estimatePackSize(pack);
        }
      }
    } on Exception catch (e) {
      debugPrint('Failed to calculate total cached size: $e');
    }

    return totalSize;
  }
}

/// Result of pack cleanup operation
class PackCleanupResult {
  PackCleanupResult({required this.packId});

  final String packId;
  bool success = false;
  String message = '';
  Exception? error;

  int totalImages = 0;
  int deletedImages = 0;
  int failedImages = 0;

  bool cacheDeleted = false;
  bool tempFilesDeleted = false;

  List<ImageDeletionError> imageErrors = [];
}

/// Result of image cleanup operations
class ImageCleanupResult {
  int deletedCount = 0;
  int failedCount = 0;
  List<ImageDeletionError> errors = [];
}

/// Error information for image deletion
class ImageDeletionError {
  ImageDeletionError({
    required this.imageId,
    required this.imagePath,
    required this.error,
  });

  final String imageId;
  final String imagePath;
  final Exception error;
}

/// Result of batch cleanup operations
class BatchCleanupResult {
  bool success = false;
  List<PackCleanupResult> successfulDeletions = [];
  List<PackCleanupResult> failedDeletions = [];
}

/// Summary of cleanup operations
class CleanupSummary {
  bool success = false;
  List<String> cleanedPacks = [];
  List<String> failedPacks = [];
  List<Exception?> errors = [];
  int totalImagesDeleted = 0;
  int totalSpaceFreed = 0; // in bytes
}

/// Information about a pack that can be cleaned up
class CleanupCandidate {
  CleanupCandidate({
    required this.packId,
    required this.packName,
    required this.imageCount,
    required this.estimatedSize,
    required this.lastAccessed,
  });

  final String packId;
  final String packName;
  final int imageCount;
  final int estimatedSize; // in bytes
  final DateTime lastAccessed;

  String get formattedSize {
    if (estimatedSize < 1024) return '${estimatedSize}B';
    if (estimatedSize < 1024 * 1024)
      return '${(estimatedSize / 1024).toStringAsFixed(1)}KB';
    if (estimatedSize < 1024 * 1024 * 1024)
      return '${(estimatedSize / (1024 * 1024)).toStringAsFixed(1)}MB';
    if (estimatedSize < 1024 * 1024)
      return '${(estimatedSize / 1024).toStringAsFixed(1)}KB';
    if (estimatedSize < 1024 * 1024 * 1024)
      return '${(estimatedSize / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(estimatedSize / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  String get daysSinceLastAccess {
    final difference = DateTime.now().difference(lastAccessed);
    return '${difference.inDays} days ago';
  }
}
