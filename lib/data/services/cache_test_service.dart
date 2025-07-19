import 'package:golden_moments/data/models/cache_index.dart';
import 'package:golden_moments/data/models/cache_stats.dart';
import 'package:golden_moments/data/models/download_queue.dart';
import 'package:golden_moments/data/models/pack_cache.dart';
import 'package:golden_moments/data/services/download_manager.dart';
import 'package:golden_moments/data/services/github_pack_service.dart';
import 'package:golden_moments/data/services/http_client_service.dart';
import 'package:golden_moments/data/services/json_cache_service.dart';
import 'package:golden_moments/game/models/models.dart';

/// Test service to verify JSON cache functionality
class CacheTestService {
  static Future<void> testCacheSystem() async {
    try {
      print('🧪 Testing JSON Cache System...');

      // Initialize cache service
      await JsonCacheService.instance.initialize();
      print('✅ Cache service initialized');

      // Test cache index
      await _testCacheIndex();
      print('✅ Cache index test passed');

      // Test cache stats
      await _testCacheStats();
      print('✅ Cache stats test passed');

      // Test download queue
      await _testDownloadQueue();
      print('✅ Download queue test passed');

      // Test pack cache
      await _testPackCache();
      print('✅ Pack cache test passed');

      // Test download system
      await _testDownloadSystem();
      print('✅ Download system test passed');

      print('🎉 All cache tests passed successfully!');
    } catch (e) {
      print('❌ Cache test failed: $e');
      rethrow;
    }
  }

  static Future<void> _testCacheIndex() async {
    final service = JsonCacheService.instance;

    // Create test cache index
    final testPack = CachedPackInfo(
      id: 'test_pack_1',
      version: '1.0.0',
      title: 'Test Pack',
      status: CacheStatus.downloaded,
      downloadedAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(days: 60)),
      imageCount: 10,
      downloadedImages: 10,
      totalSize: 1024 * 1024, // 1MB
      localManifestPath: 'packs/test_pack_1.json',
    );

    final cacheIndex = CacheIndex.empty().addPack(testPack);

    // Save and load
    await service.saveCacheIndex(cacheIndex);
    final loadedIndex = await service.loadCacheIndex();

    // Verify
    assert(loadedIndex.packs.length == 1);
    assert(loadedIndex.packs['test_pack_1']?.title == 'Test Pack');
  }

  static Future<void> _testCacheStats() async {
    final service = JsonCacheService.instance;

    // Create test cache stats
    final stats = CacheStats.defaultStats().copyWith(
      totalCacheSize: 1024 * 1024,
      totalPacks: 5,
      totalImages: 50,
    );

    // Save and load
    await service.saveCacheStats(stats);
    final loadedStats = await service.loadCacheStats();

    // Verify
    assert(loadedStats.totalCacheSize == 1024 * 1024);
    assert(loadedStats.totalPacks == 5);
    assert(loadedStats.totalImages == 50);
  }

  static Future<void> _testDownloadQueue() async {
    final service = JsonCacheService.instance;

    // Create test download item
    final downloadItem = DownloadItem(
      id: 'download_test_1',
      packId: 'test_pack_1',
      imageId: 'test_image_1',
      type: DownloadType.image,
      status: DownloadStatus.queued,
      priority: 1,
      retryCount: 0,
      queuedAt: DateTime.now(),
    );

    final queue = DownloadQueue.empty().addDownload(downloadItem);

    // Save and load
    await service.saveDownloadQueue(queue);
    final loadedQueue = await service.loadDownloadQueue();

    // Verify
    assert(loadedQueue.queuedDownloads.length == 1);
    assert(loadedQueue.queuedDownloads.first.id == 'download_test_1');
  }

  static Future<void> _testPackCache() async {
    final service = JsonCacheService.instance;

    // Create test game pack
    final gamePack = GamePack(
      id: 'test_pack_1',
      title: 'Test Pack',
      theme: 'Testing',
      tiles: [
        const GameTile(
          id: 'tile_1',
          imageUrl: 'test_image_1.jpg',
          caption: 'Test Image 1',
        ),
        const GameTile(
          id: 'tile_2',
          imageUrl: 'test_image_2.jpg',
          caption: 'Test Image 2',
        ),
      ],
      difficulty: GameDifficulty.easy,
    );

    // Create test cached image
    final cachedImage = CachedImage.create(
      id: 'test_image_1',
      filename: 'test_image_1.jpg',
      caption: 'Test Image 1',
      altText: 'A test image for testing',
      localPath: 'images/test_pack_1/test_image_1.jpg',
      downloadUrl: 'https://example.com/test_image_1.jpg',
      size: 512 * 1024, // 512KB
      dimensions: '800x600',
      format: 'JPEG',
      checksum: 'abc123def456',
    );

    // Create pack cache
    final packCache = PackCache.create(
      id: 'test_pack_1',
      version: '1.0.0',
      manifest: gamePack,
      images: [cachedImage],
    );

    // Save and load
    await service.savePackCache(packCache);
    final loadedPackCache = await service.loadPackCache('test_pack_1');

    // Verify
    assert(loadedPackCache != null);
    assert(loadedPackCache!.id == 'test_pack_1');
    assert(loadedPackCache!.manifest.title == 'Test Pack');
    assert(loadedPackCache!.images.length == 1);
    assert(loadedPackCache!.images.first.filename == 'test_image_1.jpg');
  }

  static Future<void> _testDownloadSystem() async {
    // Initialize services
    HttpClientService.instance.initialize();
    DownloadManager.instance.initialize();

    // Test HTTP client connectivity check
    final hasInternet = await HttpClientService.instance
        .hasInternetConnection();
    print(
      '📡 Internet connection: ${hasInternet ? "Available" : "Not available"}',
    );

    // Test GitHub service availability
    final serviceStatus = await GitHubPackService.instance.getServiceStatus();
    print('🐙 GitHub service status: ${serviceStatus.displayName}');

    // Test download queue operations
    final downloadManager = DownloadManager.instance;
    final activeCount = await downloadManager.getActiveDownloadsCount();
    final queuedCount = await downloadManager.getQueuedDownloadsCount();

    print('⬇️ Active downloads: $activeCount');
    print('📋 Queued downloads: $queuedCount');

    // Cleanup
    DownloadManager.instance.dispose();
    HttpClientService.instance.dispose();
  }
}
