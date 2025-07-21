import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:golden_moments/data/models/download_error.dart';
import 'package:golden_moments/data/models/download_progress.dart';
import 'package:golden_moments/data/models/download_queue.dart';
import 'package:golden_moments/data/models/pack_cache.dart';
import 'package:golden_moments/data/services/http_client_service.dart';
import 'package:golden_moments/data/services/json_cache_service.dart';
import 'package:golden_moments/data/services/local_pack_service.dart';
import 'package:golden_moments/data/storage/cache_file_paths.dart';
import 'package:golden_moments/shared/constants/cache_constants.dart';
import 'package:golden_moments/shared/utils/string_util.dart';

/// Download manager for processing pack and image downloads
class DownloadManager {
  factory DownloadManager() => _instance;
  DownloadManager._internal();
  static final DownloadManager _instance = DownloadManager._internal();

  final JsonCacheService _cacheService = JsonCacheService();
  final LocalPackService _localPackService = LocalPackService();
  final HttpClientService _httpClient = HttpClientService();

  final Map<String, StreamController<DownloadProgress>> _progressControllers =
      {};
  final Map<String, bool> _cancelledDownloads = {};

  Timer? _queueProcessor;
  bool _isProcessing = false;

  /// Initialize download manager
  void initialize() {
    _startQueueProcessor();
  }

  /// Dispose download manager
  void dispose() {
    _queueProcessor?.cancel();
    for (final controller in _progressControllers.values) {
      controller.close();
    }
    _progressControllers.clear();
  }

  /// Download a complete pack
  Future<void> downloadPack(String packId) async {
    try {
      // Get pack from local service (packs_index.json)
      final pack = await _localPackService.getPackById(packId);

      // Create pack cache entry from local pack
      final packCache = PackCache.create(
        id: packId,
        version: pack.version,
        manifest: pack,
      );

      // Save initial pack cache
      await _cacheService.savePackCache(packCache);

      // Queue image downloads
      for (final image in pack.images) {
        await _queueImageDownload(packId, image.id, image.url);
      }
    } catch (e) {
      throw e is DownloadError
          ? e
          : DownloadError.unknown(packId, e.toString());
    }
  }

  /// Queue an image download
  Future<void> _queueImageDownload(
    String packId,
    String imageId,
    String filename,
  ) async {
    final downloadId = generateDownloadId(packId, imageId);

    final downloadItem = DownloadItem(
      id: downloadId,
      packId: packId,
      imageId: imageId,
      type: DownloadType.image,
      status: DownloadStatus.queued,
      priority: 1,
      retryCount: 0,
      queuedAt: DateTime.now(),
    );

    // Add to download queue
    final queue = await _cacheService.loadDownloadQueue();

    final updatedQueue = queue.addDownload(downloadItem);

    await _cacheService.saveDownloadQueue(updatedQueue);
  }

  /// Get download progress stream
  Stream<DownloadProgress> getDownloadProgress(String downloadId) {
    if (!_progressControllers.containsKey(downloadId)) {
      _progressControllers[downloadId] =
          StreamController<DownloadProgress>.broadcast();
    }
    return _progressControllers[downloadId]!.stream;
  }

  /// Cancel download
  Future<void> cancelDownload(String downloadId) async {
    _cancelledDownloads[downloadId] = true;

    // Update queue status
    final queue = await _cacheService.loadDownloadQueue();
    final updatedQueue = queue.cancelDownload(downloadId);
    await _cacheService.saveDownloadQueue(updatedQueue);

    // Emit cancelled progress
    _emitProgress(
      DownloadProgress.cancelled(
        downloadId: downloadId,
        packId: downloadId.split('_').first,
        imageId: downloadId.split('_').skip(1).join('_'),
        bytesDownloaded: 0,
        totalBytes: 0,
        startTime: DateTime.now(),
      ),
    );
  }

  /// Pause download
  Future<void> pauseDownload(String downloadId) async {
    _cancelledDownloads[downloadId] = true;

    // Update queue status
    final queue = await _cacheService.loadDownloadQueue();
    final updatedQueue = queue.pauseDownload(downloadId);
    await _cacheService.saveDownloadQueue(updatedQueue);

    // Emit paused progress
    _emitProgress(
      DownloadProgress.paused(
        downloadId: downloadId,
        packId: downloadId.split('_').first,
        imageId: downloadId.split('_').skip(1).join('_'),
        bytesDownloaded: 0,
        totalBytes: 0,
        startTime: DateTime.now(),
      ),
    );
  }

  /// Resume download
  Future<void> resumeDownload(String downloadId) async {
    _cancelledDownloads.remove(downloadId);

    // Update queue status
    final queue = await _cacheService.loadDownloadQueue();
    final updatedQueue = queue.resumeDownload(downloadId);
    await _cacheService.saveDownloadQueue(updatedQueue);

    // The queue processor will pick up the resumed download
  }

  /// Retry a failed download
  Future<void> retryDownload(String downloadId) async {
    _cancelledDownloads.remove(downloadId);

    // Update queue status
    final queue = await _cacheService.loadDownloadQueue();
    final updatedQueue = queue.retryDownload(downloadId);
    await _cacheService.saveDownloadQueue(updatedQueue);

    // The queue processor will pick up the retried download
  }

  /// Get current download queue
  Future<DownloadQueue> getDownloadQueue() async {
    return _cacheService.loadDownloadQueue();
  }

  /// Start queue processor
  void _startQueueProcessor() {
    _queueProcessor = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isProcessing) {
        _processQueue();
      }
    });
  }

  /// Process download queue
  Future<void> _processQueue() async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final queue = await _cacheService.loadDownloadQueue();
      final activeCount = queue.activeDownloads.length;

      // Start new downloads if under limit
      if (activeCount < CacheConstants.maxConcurrentDownloads &&
          queue.queuedDownloads.isNotEmpty) {
        final nextDownload = queue.queuedDownloads.first;
        await _startDownload(nextDownload);
      }
    } finally {
      _isProcessing = false;
    }
  }

  /// Start individual download
  Future<void> _startDownload(DownloadItem item) async {
    final downloadId = item.id;

    // Check if cancelled
    if (_cancelledDownloads[downloadId] == true) {
      return;
    }

    // Update queue to mark as active
    final queue = await _cacheService.loadDownloadQueue();
    final updatedQueue = queue.startDownload(downloadId);
    await _cacheService.saveDownloadQueue(updatedQueue);

    try {
      if (item.type == DownloadType.image) {
        await _downloadImage(item);
      }
    } on Exception catch (e) {
      await _handleDownloadError(item, e);
    }
  }

  /// Download individual image
  Future<void> _downloadImage(DownloadItem item) async {
    final downloadId = item.id;
    final packId = item.packId;
    final imageId = item.imageId!;

    // Get image URL from pack cache
    final packCache = await _cacheService.loadPackCache(packId);
    if (packCache == null) {
      throw DownloadError.unknown(downloadId, 'Pack cache not found');
    }

    final tile = packCache.manifest.images.firstWhere((t) => t.id == imageId);
    final imageUrl = tile.url;

    // Extract filename from URL for local storage
    final filename = '$imageId.jpg'; // Use consistent filename

    // Download with progress tracking
    final startTime = DateTime.now();

    // Emit initial progress (we'll get total bytes during download)
    final initialProgress = DownloadProgress.started(
      downloadId: downloadId,
      packId: packId,
      imageId: imageId,
      totalBytes: 0, // Will be updated during download
    );
    _emitProgress(initialProgress);

    // Download image data using HTTP client
    final imageData = await _httpClient.downloadBinary(
      imageUrl,
      onProgress: (int downloaded, int total) {
        // Calculate speed and ETA
        final elapsed = DateTime.now().difference(startTime);
        final speed = _httpClient.calculateDownloadSpeed(downloaded, elapsed);
        final eta = _httpClient.calculateETA(total - downloaded, speed);

        // Emit progress update with updated total bytes
        final progress =
            DownloadProgress.started(
              downloadId: downloadId,
              packId: packId,
              imageId: imageId,
              totalBytes: total,
            ).updateProgress(
              bytesDownloaded: downloaded,
              speed: speed,
              eta: eta,
            );
        _emitProgress(progress);
      },
    );

    // Save image to cache
    final imagePath = CacheFilePaths.imageFile(packId, filename);
    final fullPath = _cacheService.fileManager.getCachePath(imagePath);
    final imageFile = File(fullPath);

    // Ensure directory exists
    await imageFile.parent.create(recursive: true);

    // Write image data
    await imageFile.writeAsBytes(imageData);

    // Verify checksum if available
    final checksum = sha256.convert(imageData).toString();

    // Update pack cache with downloaded image
    final cachedImage = CachedImage.create(
      id: imageId,
      filename: filename,
      caption: tile.caption,
      altText: tile.caption,
      localPath: imagePath,
      downloadUrl: imageUrl,
      size: imageData.length,
      dimensions: '400x400', // TODO: Get actual dimensions
      format: filename.split('.').last.toUpperCase(),
      checksum: checksum,
    );

    final updatedPackCache = packCache.addImage(cachedImage);
    await _cacheService.savePackCache(updatedPackCache);

    // Mark download as completed
    await _completeDownload(item);

    // Emit completion progress
    _emitProgress(initialProgress.complete());
  }

  /// Complete download
  Future<void> _completeDownload(DownloadItem item) async {
    final queue = await _cacheService.loadDownloadQueue();
    final updatedQueue = queue.completeDownload(item.id);
    await _cacheService.saveDownloadQueue(updatedQueue);
  }

  /// Handle download error
  Future<void> _handleDownloadError(DownloadItem item, dynamic error) async {
    final downloadError = error is DownloadError
        ? error
        : DownloadError.unknown(item.id, error.toString());

    // Update queue with failure
    final queue = await _cacheService.loadDownloadQueue();
    final updatedQueue = queue.failDownload(item.id, downloadError.message);
    await _cacheService.saveDownloadQueue(updatedQueue);

    // Emit error progress
    _emitProgress(
      DownloadProgress.failed(
        downloadId: item.id,
        packId: item.packId,
        imageId: item.imageId,
        bytesDownloaded: 0,
        totalBytes: 0,
        startTime: DateTime.now(),
        error: downloadError,
      ),
    );
  }

  /// Emit progress update
  void _emitProgress(DownloadProgress progress) {
    final controller = _progressControllers[progress.downloadId];
    if (controller != null && !controller.isClosed) {
      controller.add(progress);
    }
  }

  /// Get active downloads count
  Future<int> getActiveDownloadsCount() async {
    final queue = await _cacheService.loadDownloadQueue();
    return queue.activeDownloads.length;
  }

  /// Get queued downloads count
  Future<int> getQueuedDownloadsCount() async {
    final queue = await _cacheService.loadDownloadQueue();
    return queue.queuedDownloads.length;
  }

  /// Check if pack is currently downloading
  Future<bool> isPackDownloading(String packId) async {
    final queue = await _cacheService.loadDownloadQueue();
    return queue.activeDownloads.any((item) => item.packId == packId) ||
        queue.queuedDownloads.any((item) => item.packId == packId);
  }
}
