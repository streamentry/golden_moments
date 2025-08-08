import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Long-term image caching service with 1-year expiry
class LongTermImageCache {
  LongTermImageCache._();

  static LongTermImageCache? _instance;
  static LongTermImageCache get instance =>
      _instance ??= LongTermImageCache._();

  static const Duration _cacheExpiry = Duration(days: 365); // 1 year
  static const String _cacheDirectoryName = 'image_cache';
  static const String _metadataFileName = 'cache_metadata.json';

  Directory? _cacheDirectory;
  Map<String, CacheMetadata> _metadata = {};
  bool _initialized = false;

  /// Initialize the cache system
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      final appDir = await getApplicationDocumentsDirectory();
      _cacheDirectory = Directory(path.join(appDir.path, _cacheDirectoryName));

      if (!await _cacheDirectory!.exists()) {
        await _cacheDirectory!.create(recursive: true);
      }

      await _loadMetadata();
      await _cleanExpiredCache();

      _initialized = true;
    } catch (e) {
      throw Exception('Failed to initialize image cache: $e');
    }
  }

  /// Get cached image file or download if not cached
  Future<File?> getCachedImage(String imageUrl) async {
    await initialize();

    final cacheKey = _generateCacheKey(imageUrl);
    final cachedFile = File(path.join(_cacheDirectory!.path, '$cacheKey.jpg'));

    // Check if image is cached and not expired
    if (await cachedFile.exists()) {
      final metadata = _metadata[cacheKey];
      if (metadata != null && !metadata.isExpired) {
        // Update last accessed time
        metadata.lastAccessed = DateTime.now();
        await _saveMetadata();
        return cachedFile;
      }
    }

    // Download and cache the image
    return _downloadAndCacheImage(imageUrl, cachedFile, cacheKey);
  }

  /// Download and cache an image
  Future<File?> _downloadAndCacheImage(
    String imageUrl,
    File cacheFile,
    String cacheKey,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse(imageUrl),
            headers: {
              'User-Agent': 'Golden Moments Memory Game/1.0',
            },
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        await cacheFile.writeAsBytes(response.bodyBytes);

        // Update metadata
        _metadata[cacheKey] = CacheMetadata(
          url: imageUrl,
          cacheKey: cacheKey,
          cachedAt: DateTime.now(),
          lastAccessed: DateTime.now(),
          fileSize: response.bodyBytes.length,
          fileName: '$cacheKey.jpg',
        );

        await _saveMetadata();
        return cacheFile;
      }
    } catch (e) {
      // Handle download error gracefully
      print('Failed to download image $imageUrl: $e');
    }

    return null;
  }

  /// Check if image is cached and valid
  Future<bool> isImageCached(String imageUrl) async {
    await initialize();

    final cacheKey = _generateCacheKey(imageUrl);
    final cachedFile = File(path.join(_cacheDirectory!.path, '$cacheKey.jpg'));

    if (!await cachedFile.exists()) return false;

    final metadata = _metadata[cacheKey];
    return metadata != null && !metadata.isExpired;
  }

  /// Get cache statistics
  Future<CacheStatistics> getCacheStatistics() async {
    await initialize();

    var totalFiles = 0;
    var totalSize = 0;
    var expiredFiles = 0;
    DateTime? oldestFile;
    DateTime? newestFile;

    for (final metadata in _metadata.values) {
      totalFiles++;
      totalSize += metadata.fileSize;

      if (metadata.isExpired) {
        expiredFiles++;
      }

      if (oldestFile == null || metadata.cachedAt.isBefore(oldestFile)) {
        oldestFile = metadata.cachedAt;
      }

      if (newestFile == null || metadata.cachedAt.isAfter(newestFile)) {
        newestFile = metadata.cachedAt;
      }
    }

    return CacheStatistics(
      totalFiles: totalFiles,
      totalSizeBytes: totalSize,
      expiredFiles: expiredFiles,
      oldestCacheDate: oldestFile,
      newestCacheDate: newestFile,
      cacheHitRate: _calculateCacheHitRate(),
    );
  }

  /// Clean expired cache entries
  Future<void> _cleanExpiredCache() async {
    final expiredKeys = <String>[];

    for (final entry in _metadata.entries) {
      if (entry.value.isExpired) {
        expiredKeys.add(entry.key);

        // Delete the cached file
        final file = File(path.join(_cacheDirectory!.path, '${entry.key}.jpg'));
        if (await file.exists()) {
          await file.delete();
        }
      }
    }

    // Remove expired entries from metadata
    for (final key in expiredKeys) {
      _metadata.remove(key);
    }

    if (expiredKeys.isNotEmpty) {
      await _saveMetadata();
    }
  }

  /// Manually clean all expired cache
  Future<int> cleanExpiredCache() async {
    await initialize();

    final initialCount = _metadata.length;
    await _cleanExpiredCache();
    final finalCount = _metadata.length;

    return initialCount - finalCount;
  }

  /// Clear all cache
  Future<void> clearAllCache() async {
    await initialize();

    // Delete all cached files
    if (await _cacheDirectory!.exists()) {
      await _cacheDirectory!.delete(recursive: true);
      await _cacheDirectory!.create(recursive: true);
    }

    // Clear metadata
    _metadata.clear();
    await _saveMetadata();
  }

  /// Preload images for a pack
  Future<void> preloadPackImages(List<String> imageUrls) async {
    await initialize();

    final futures = imageUrls.map(getCachedImage);
    await Future.wait(futures);
  }

  /// Generate cache key from URL
  String _generateCacheKey(String url) {
    final bytes = utf8.encode(url);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Load metadata from disk
  Future<void> _loadMetadata() async {
    final metadataFile = File(
      path.join(_cacheDirectory!.path, _metadataFileName),
    );

    if (await metadataFile.exists()) {
      try {
        final jsonString = await metadataFile.readAsString();
        final jsonData = json.decode(jsonString) as Map<String, dynamic>;

        _metadata = jsonData.map(
          (key, value) => MapEntry(
            key,
            CacheMetadata.fromJson(value as Map<String, dynamic>),
          ),
        );
      } catch (e) {
        // If metadata is corrupted, start fresh
        _metadata = {};
      }
    }
  }

  /// Save metadata to disk
  Future<void> _saveMetadata() async {
    final metadataFile = File(
      path.join(_cacheDirectory!.path, _metadataFileName),
    );

    final jsonData = _metadata.map(
      (key, value) => MapEntry(key, value.toJson()),
    );
    final jsonString = json.encode(jsonData);

    await metadataFile.writeAsString(jsonString);
  }

  /// Calculate cache hit rate (placeholder)
  double _calculateCacheHitRate() {
    // This would track actual cache hits vs misses
    // For now, return a placeholder
    return 0.85; // 85% hit rate
  }

  /// Get cache directory path
  String? get cacheDirectoryPath => _cacheDirectory?.path;

  /// Check if cache is initialized
  bool get isInitialized => _initialized;
}

/// Cache metadata for individual images
class CacheMetadata {
  CacheMetadata({
    required this.url,
    required this.cacheKey,
    required this.cachedAt,
    required this.lastAccessed,
    required this.fileSize,
    required this.fileName,
  });

  /// Create from JSON
  factory CacheMetadata.fromJson(Map<String, dynamic> json) {
    return CacheMetadata(
      url: json['url'] as String,
      cacheKey: json['cacheKey'] as String,
      cachedAt: DateTime.parse(json['cachedAt'] as String),
      lastAccessed: DateTime.parse(json['lastAccessed'] as String),
      fileSize: json['fileSize'] as int,
      fileName: json['fileName'] as String,
    );
  }

  final String url;
  final String cacheKey;
  final DateTime cachedAt;
  DateTime lastAccessed;
  final int fileSize;
  final String fileName;

  /// Check if cache entry is expired
  bool get isExpired {
    final now = DateTime.now();
    return now.difference(cachedAt) > LongTermImageCache._cacheExpiry;
  }

  /// Get age of cache entry
  Duration get age => DateTime.now().difference(cachedAt);

  /// Get formatted file size
  String get formattedFileSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'cacheKey': cacheKey,
      'cachedAt': cachedAt.toIso8601String(),
      'lastAccessed': lastAccessed.toIso8601String(),
      'fileSize': fileSize,
      'fileName': fileName,
    };
  }
}

/// Cache statistics
class CacheStatistics {
  const CacheStatistics({
    required this.totalFiles,
    required this.totalSizeBytes,
    required this.expiredFiles,
    required this.cacheHitRate,
    this.oldestCacheDate,
    this.newestCacheDate,
  });

  final int totalFiles;
  final int totalSizeBytes;
  final int expiredFiles;
  final DateTime? oldestCacheDate;
  final DateTime? newestCacheDate;
  final double cacheHitRate;

  /// Get formatted total size
  String get formattedTotalSize {
    if (totalSizeBytes < 1024 * 1024) {
      return '${(totalSizeBytes / 1024).toStringAsFixed(1)} KB';
    } else if (totalSizeBytes < 1024 * 1024 * 1024) {
      return '${(totalSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(totalSizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// Get cache hit rate as percentage
  String get formattedCacheHitRate =>
      '${(cacheHitRate * 100).toStringAsFixed(1)}%';

  /// Get cache health status
  String get healthStatus {
    if (cacheHitRate > 0.8) return 'Excellent';
    if (cacheHitRate > 0.6) return 'Good';
    if (cacheHitRate > 0.4) return 'Fair';
    return 'Poor';
  }
}
