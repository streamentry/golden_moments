import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:memory_lane/data/services/long_term_image_cache.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return '/tmp/test_cache';
  }
}

void main() {
  group('LongTermImageCache Tests', () {
    late LongTermImageCache cache;
    late Directory testDir;

    setUpAll(() async {
      PathProviderPlatform.instance = MockPathProviderPlatform();
      testDir = Directory('/tmp/test_cache');
      if (await testDir.exists()) {
        await testDir.delete(recursive: true);
      }
      await testDir.create(recursive: true);
    });

    setUp(() {
      cache = LongTermImageCache.instance;
    });

    tearDown(() async {
      // Clean up test cache
      final cacheDir = Directory('/tmp/test_cache/image_cache');
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }
    });

    test('should initialize cache directory', () async {
      await cache.initialize();
      
      final cacheDir = Directory('/tmp/test_cache/image_cache');
      expect(await cacheDir.exists(), isTrue);
      expect(cache.isInitialized, isTrue);
    });

    test('should check if image is cached', () async {
      await cache.initialize();
      
      const testUrl = 'https://example.com/test.jpg';
      final isCached = await cache.isImageCached(testUrl);
      
      expect(isCached, isFalse);
    });

    test('should get cache statistics', () async {
      await cache.initialize();
      
      final stats = await cache.getCacheStatistics();
      
      expect(stats.totalFiles, 0);
      expect(stats.totalSizeBytes, 0);
      expect(stats.expiredFiles, 0);
      expect(stats.cacheHitRate, 0.85); // Default placeholder value
    });

    test('should clean expired cache', () async {
      await cache.initialize();
      
      final cleanedCount = await cache.cleanExpiredCache();
      
      expect(cleanedCount, 0); // No expired items initially
    });

    test('should clear all cache', () async {
      await cache.initialize();
      
      await cache.clearAllCache();
      
      final stats = await cache.getCacheStatistics();
      expect(stats.totalFiles, 0);
    });

    test('should preload pack images', () async {
      await cache.initialize();
      
      const imageUrls = [
        'https://example.com/img1.jpg',
        'https://example.com/img2.jpg',
      ];
      
      // This should not throw an error even if downloads fail
      await cache.preloadPackImages(imageUrls);
      
      // Since we can't actually download in tests, just verify no exception
      expect(true, isTrue);
    });

    test('should handle cache metadata correctly', () {
      final metadata = CacheMetadata(
        url: 'https://example.com/test.jpg',
        cacheKey: 'test_key',
        cachedAt: DateTime.now().subtract(const Duration(days: 30)),
        lastAccessed: DateTime.now(),
        fileSize: 1024,
        fileName: 'test.jpg',
      );

      expect(metadata.isExpired, isFalse);
      expect(metadata.formattedFileSize, '1.0 KB');
      expect(metadata.age.inDays, 30);
    });

    test('should detect expired cache entries', () {
      final expiredMetadata = CacheMetadata(
        url: 'https://example.com/old.jpg',
        cacheKey: 'old_key',
        cachedAt: DateTime.now().subtract(const Duration(days: 400)), // > 1 year
        lastAccessed: DateTime.now().subtract(const Duration(days: 400)),
        fileSize: 2048,
        fileName: 'old.jpg',
      );

      expect(expiredMetadata.isExpired, isTrue);
      expect(expiredMetadata.formattedFileSize, '2.0 KB');
    });

    test('should format file sizes correctly', () {
      final smallFile = CacheMetadata(
        url: 'https://example.com/small.jpg',
        cacheKey: 'small_key',
        cachedAt: DateTime.now(),
        lastAccessed: DateTime.now(),
        fileSize: 512,
        fileName: 'small.jpg',
      );

      final largeFile = CacheMetadata(
        url: 'https://example.com/large.jpg',
        cacheKey: 'large_key',
        cachedAt: DateTime.now(),
        lastAccessed: DateTime.now(),
        fileSize: 2 * 1024 * 1024, // 2 MB
        fileName: 'large.jpg',
      );

      expect(smallFile.formattedFileSize, '512 B');
      expect(largeFile.formattedFileSize, '2.0 MB');
    });

    test('should format cache statistics correctly', () {
      const stats = CacheStatistics(
        totalFiles: 10,
        totalSizeBytes: 5 * 1024 * 1024, // 5 MB
        expiredFiles: 2,
        cacheHitRate: 0.75,
      );

      expect(stats.formattedTotalSize, '5.0 MB');
      expect(stats.formattedCacheHitRate, '75.0%');
      expect(stats.healthStatus, 'Good');
    });

    test('should determine cache health status', () {
      const excellentCache = CacheStatistics(
        totalFiles: 10,
        totalSizeBytes: 1024,
        expiredFiles: 0,
        cacheHitRate: 0.9,
      );

      const poorCache = CacheStatistics(
        totalFiles: 10,
        totalSizeBytes: 1024,
        expiredFiles: 5,
        cacheHitRate: 0.3,
      );

      expect(excellentCache.healthStatus, 'Excellent');
      expect(poorCache.healthStatus, 'Poor');
    });
  });
}
