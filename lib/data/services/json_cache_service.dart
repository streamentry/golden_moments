import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:golden_moments/data/models/cache_index.dart';
import 'package:golden_moments/data/models/cache_stats.dart';
import 'package:golden_moments/data/models/download_queue.dart';
import 'package:golden_moments/data/models/pack_cache.dart';
import 'package:golden_moments/data/storage/cache_file_paths.dart';
import 'package:golden_moments/data/storage/json_file_manager.dart';
import 'package:golden_moments/data/storage/json_store.dart';
import 'package:golden_moments/data/storage/web_json_file_manager.dart';
import 'package:path_provider/path_provider.dart';

/// JSON-based cache service for managing pack and image cache
class JsonCacheService {
  factory() => _instance;
  JsonCacheService._internal();
  static final JsonCacheService _instance = JsonCacheService._internal();

  JsonStore? _fileManager; // Can be JsonFileManager or WebJsonFileManager
  String? _cacheDirectory;

  /// Initialize the cache service
  Future<void> initialize() async {
    if (_fileManager != null) return;

    try {
      final appDir = await getApplicationDocumentsDirectory();
      _cacheDirectory = '${appDir.path}/golden_moments_cache';
      _fileManager = JsonFileManager(cacheDirectory: _cacheDirectory!);

      await _fileManager!.initializeCacheStructure();
    } on Object {
      // On web or platforms where path_provider doesn't work,
      // create a no-op file manager to prevent crashes
      _cacheDirectory = '';
      _fileManager = _createWebCompatibleFileManager();
    }
  }

  /// Create a web-compatible file manager that doesn't perform file operations
  JsonStore _createWebCompatibleFileManager() {
    // Use WebJsonFileManager for web platforms
    if (kIsWeb) {
      return WebJsonFileManager(cacheDirectory: 'golden_moments_cache');
    }
    // Fallback for other platforms
    return JsonFileManager(cacheDirectory: '');
  }

  /// Get the file manager instance
  JsonStore get fileManager {
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

  /// Delete pack completely (cache file and images)
  Future<void> _deletePackCompletely(String packId) async {
    // Delete pack cache file
    await deletePackCache(packId);

    // Delete pack images directory (only on non-web platforms)
    if (!kIsWeb) {
      try {
        final imagesDir = CacheFilePaths.packImagesDirectory(packId);
        final imagesDirPath = fileManager.getCachePath(imagesDir);
        final directory = Directory(imagesDirPath);

        if (directory.existsSync()) {
          await directory.delete(recursive: true);
        }
      } on Object catch (e) {
        // Ignore directory deletion errors on web
        debugPrint('Error deleting pack images directory: $e');
      }
    }
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
