import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/cache_index.dart';
import '../models/cache_stats.dart';
import '../models/download_queue.dart';
import '../models/pack_cache.dart';
import '../storage/cache_file_paths.dart';
import '../storage/json_file_manager.dart';

/// JSON-based cache service for managing pack and image cache
class JsonCacheService {
  factory JsonCacheService() => _instance;
  JsonCacheService._internal();
  static final JsonCacheService _instance = JsonCacheService._internal();

  JsonFileManager? _fileManager;
  String? _cacheDirectory;

  /// Initialize the cache service
  Future<void> initialize() async {
    if (_fileManager != null) return;

    final appDir = await getApplicationDocumentsDirectory();
    _cacheDirectory = '${appDir.path}/golden_moments_cache';
    _fileManager = JsonFileManager(cacheDirectory: _cacheDirectory!);

    await _fileManager!.initializeCacheStructure();
  }

  /// Get the file manager instance
  JsonFileManager get fileManager {
    if (_fileManager == null) {
      throw StateError(
        'JsonCacheService not initialized. Call initialize() first.',
      );
    }
    return _fileManager!;
  }

  /// Load cache index
  Future<CacheIndex> loadCacheIndex() async {
    final cacheIndex = await fileManager.loadJsonFile(
      CacheFilePaths.cacheIndex,
      CacheIndex.fromJson,
    );
    return cacheIndex ?? CacheIndex.empty();
  }

  /// Save cache index
  Future<void> saveCacheIndex(CacheIndex index) async {
    await fileManager.saveJsonFile(
      CacheFilePaths.cacheIndex,
      index,
      (data) => data.toJson(),
    );
  }

  /// Load cache statistics
  Future<CacheStats> loadCacheStats() async {
    final stats = await fileManager.loadJsonFile(
      CacheFilePaths.cacheStats,
      CacheStats.fromJson,
    );
    return stats ?? CacheStats.defaultStats();
  }

  /// Save cache statistics
  Future<void> saveCacheStats(CacheStats stats) async {
    await fileManager.saveJsonFile(
      CacheFilePaths.cacheStats,
      stats,
      (data) => data.toJson(),
    );
  }

  /// Load download queue
  Future<DownloadQueue> loadDownloadQueue() async {
    final queue = await fileManager.loadJsonFile(
      CacheFilePaths.downloadQueue,
      DownloadQueue.fromJson,
    );
    return queue ?? DownloadQueue.empty();
  }

  /// Save download queue
  Future<void> saveDownloadQueue(DownloadQueue queue) async {
    await fileManager.saveJsonFile(
      CacheFilePaths.downloadQueue,
      queue,
      (data) => data.toJson(),
    );
  }

  /// Load pack cache
  Future<PackCache?> loadPackCache(String packId) async {
    final packCache = await fileManager.loadJsonFile(
      CacheFilePaths.packCacheFile(packId),
      PackCache.fromJson,
    );
    return packCache;
  }

  /// Save pack cache
  Future<void> savePackCache(PackCache packCache) async {
    await fileManager.saveJsonFile(
      CacheFilePaths.packCacheFile(packCache.id),
      packCache,
      (data) => data.toJson(),
    );
  }

  /// Delete pack cache
  Future<void> deletePackCache(String packId) async {
    await fileManager.deleteFile(CacheFilePaths.packCacheFile(packId));
  }

  /// Check if pack is cached
  Future<bool> isPackCached(String packId) async {
    return fileManager.fileExists(CacheFilePaths.packCacheFile(packId));
  }

  /// Check if pack is expired
  Future<bool> isPackExpired(String packId) async {
    final packCache = await loadPackCache(packId);
    return packCache?.isExpired ?? true;
  }

  /// Get all cached pack IDs
  Future<List<String>> getCachedPackIds() async {
    final packFiles = await fileManager.listFiles(
      CacheFilePaths.packsDirectory,
    );
    return packFiles
        .where((file) => file.endsWith('.json'))
        .map((file) => file.substring(0, file.length - 5)) // Remove .json
        .toList();
  }

  /// Clean expired cache entries
  Future<void> cleanExpiredCache() async {
    final cacheIndex = await loadCacheIndex();
    final expiredPacks = cacheIndex.getExpiredPacks();

    for (final pack in expiredPacks) {
      await _deletePackCompletely(pack.id);
    }

    // Update cache index
    final updatedIndex = expiredPacks.fold(
      cacheIndex,
      (index, pack) => index.removePack(pack.id),
    );

    await saveCacheIndex(updatedIndex.copyWith(lastCleanup: DateTime.now()));

    // Update cache stats
    await _updateCacheStats();
  }

  /// Clear all cache
  Future<void> clearCache() async {
    // Delete all pack caches
    final cachedPackIds = await getCachedPackIds();
    for (final packId in cachedPackIds) {
      await _deletePackCompletely(packId);
    }

    // Reset cache files
    await saveCacheIndex(CacheIndex.empty());
    await saveCacheStats(CacheStats.defaultStats());
    await saveDownloadQueue(DownloadQueue.empty());
  }

  /// Get total cache size in bytes
  Future<int> getCacheSize() async {
    return fileManager.getDirectorySize('');
  }

  /// Get cache statistics with current data
  Future<CacheStats> getCurrentCacheStats() async {
    final stats = await loadCacheStats();
    final totalSize = await getCacheSize();
    final cachedPackIds = await getCachedPackIds();

    // Count total images
    int totalImages = 0;
    for (final packId in cachedPackIds) {
      final packCache = await loadPackCache(packId);
      if (packCache != null) {
        totalImages += packCache.images.length;
      }
    }

    return stats.copyWith(
      totalCacheSize: totalSize,
      totalPacks: cachedPackIds.length,
      totalImages: totalImages,
    );
  }

  /// Delete pack completely (cache file and images)
  Future<void> _deletePackCompletely(String packId) async {
    // Delete pack cache file
    await deletePackCache(packId);

    // Delete pack images directory
    final imagesDir = CacheFilePaths.packImagesDirectory(packId);
    final imagesDirPath = fileManager.getCachePath(imagesDir);
    final directory = Directory(imagesDirPath);

    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }

  /// Update cache statistics
  Future<void> _updateCacheStats() async {
    final currentStats = await getCurrentCacheStats();
    await saveCacheStats(currentStats);
  }

  /// Validate cache integrity
  Future<List<String>> validateCacheIntegrity() async {
    final issues = <String>[];

    // Validate main cache files
    final cacheFiles = [
      CacheFilePaths.cacheIndex,
      CacheFilePaths.cacheStats,
      CacheFilePaths.downloadQueue,
    ];

    for (final file in cacheFiles) {
      if (!await fileManager.validateJsonFile(file)) {
        issues.add('Invalid JSON in $file');
      }
    }

    // Validate pack cache files
    final cachedPackIds = await getCachedPackIds();
    for (final packId in cachedPackIds) {
      final packFile = CacheFilePaths.packCacheFile(packId);
      if (!await fileManager.validateJsonFile(packFile)) {
        issues.add('Invalid JSON in pack cache: $packId');
      }
    }

    return issues;
  }

  /// Repair corrupted cache files
  Future<void> repairCache() async {
    final issues = await validateCacheIntegrity();

    for (final issue in issues) {
      if (issue.contains('cache_index.json')) {
        await saveCacheIndex(CacheIndex.empty());
      } else if (issue.contains('cache_stats.json')) {
        await saveCacheStats(CacheStats.defaultStats());
      } else if (issue.contains('download_queue.json')) {
        await saveDownloadQueue(DownloadQueue.empty());
      } else if (issue.contains('pack cache:')) {
        final packId = issue.split(':').last.trim();
        await deletePackCache(packId);
      }
    }
  }

  /// Get cache directory path
  String get cacheDirectoryPath => _cacheDirectory ?? '';
}
