import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:golden_moments/data/models/download_error.dart';
import 'package:golden_moments/data/models/download_progress.dart';
import 'package:golden_moments/data/models/download_queue.dart';
import 'package:golden_moments/data/models/pack.dart';
import 'package:golden_moments/data/models/pack_cache.dart';
import 'package:golden_moments/data/services/download_manager/download_queue_processor.dart';
import 'package:golden_moments/data/services/download_manager/image_downloader.dart';
import 'package:golden_moments/data/services/download_manager/pack_cleaner.dart';
import 'package:golden_moments/data/services/download_manager/pack_status_manager.dart';
import 'package:golden_moments/data/services/download_manager/progress_tracker.dart';
import 'package:golden_moments/data/services/download_manager/storage_checker.dart';
import 'package:golden_moments/data/services/json_cache_service.dart';
import 'package:golden_moments/data/services/local_pack_service.dart';
import 'package:golden_moments/shared/utils/string_util.dart';

/// Modular download manager that orchestrates all download operations
///
/// This is the main entry point for all download-related operations.
/// It coordinates between different specialized modules to provide
/// a clean and maintainable download system.
class DownloadManagerV2 extends ChangeNotifier {
  factory() => _instance;
  new _internal() {
    // Initialize modules
    _statusManager = PackStatusManager();
    _progressTracker = ProgressTracker();
    _storageChecker = StorageChecker();
    _imageDownloader = ImageDownloader();
    _queueProcessor = DownloadQueueProcessor(imageDownloader: _imageDownloader);
    _packCleaner = PackCleaner();
    _cacheService = JsonCacheService();
    _localPackService = LocalPackService();

    // Listen to status changes and forward them
    _statusManager.onStatusChanged.listen((statusChange) {
      notifyListeners();
    });

    // Listen to progress changes and forward them
    _progressTracker.addListener(notifyListeners);
  }

  static final DownloadManagerV2 _instance = DownloadManagerV2._internal();

  // Core modules
  late final PackStatusManager _statusManager;
  late final ProgressTracker _progressTracker;
  late final StorageChecker _storageChecker;
  late final ImageDownloader _imageDownloader;
  late final DownloadQueueProcessor _queueProcessor;
  late final PackCleaner _packCleaner;
  late final JsonCacheService _cacheService;
  late final LocalPackService _localPackService;

  // Public API - Status Management

  /// Stream of pack status changes
  Stream<MapEntry<String, PackStatus>> get onStatusChanged =>
      _statusManager.onStatusChanged;

  /// Get status of a specific pack
  PackStatus getPackStatus(String packId) =>
      _statusManager.getPackStatus(packId);

  /// Get status of all packs
  Map<String, PackStatus> getPacksStatus() => _statusManager.getPacksStatus();

  /// Check if a pack is downloaded
  bool isDownloaded(String packId) => _statusManager.isDownloaded(packId);

  // Public API - Progress Management

  /// Get download progress for a specific pack
  double getPackDownloadProgress(String packId) =>
      _progressTracker.getPackDownloadProgress(packId);

  /// Get detailed progress information for a pack
  PackDownloadProgress? getPackProgressDetails(String packId) =>
      _progressTracker.getPackProgressDetails(packId);

  /// Get overall download statistics
  DownloadStatistics getOverallStatistics() =>
      _progressTracker.getOverallStatistics();

  // Public API - Storage Management

  /// Check if there's enough space for a download
  Future<bool> hasEnoughSpace(int downloadSizeInBytes) =>
      _storageChecker.hasEnoughSpace(downloadSizeInBytes);

  /// Get storage information
  Future<StorageInfo> getStorageInfo() => _storageChecker.getStorageInfo();

  /// Get storage recommendation
  Future<StorageRecommendation> getStorageRecommendation() =>
      _storageChecker.getStorageRecommendation();

  // Public API - Download Operations

  /// Initialize the download manager
  Future<void> initialize() async {
    final packs = await _localPackService.getPacks();
    final packStatuses = <String, PackStatus>{};

    for (final pack in packs) {
      if (await _cacheService.isPackCached(pack.id)) {
        packStatuses[pack.id] = PackStatus.completed;
      } else {
        packStatuses[pack.id] = PackStatus.notStarted;
      }
    }

    _statusManager.initializePackStatuses(packStatuses);
    notifyListeners();
  }

  /// Download all initial packs
  Future<void> downloadInitialPacks() async {
    final packs = await _localPackService.getPacks();
    final downloadFutures = <Future<void>>[];

    for (final pack in packs) {
      if (!await _cacheService.isPackCached(pack.id)) {
        downloadFutures.add(downloadPack(pack.id));
      }
    }

    // Don't await all - let them run concurrently
    downloadFutures.forEach(unawaited);
  }

  /// Download a complete pack
  Future<void> downloadPack(String packId) async {
    try {
      // Update status
      _statusManager.markAsDownloading(packId);

      // Get pack information
      final pack = await _localPackService.getPackById(packId);

      // Check storage space
      final packSizeBytes = parseSizeToBytes(pack.estimatedSize);
      final hasSpace = await _storageChecker.hasEnoughSpace(packSizeBytes);

      if (!hasSpace) {
        throw DownloadError.storageSpace(
          'pack:$packId',
          'Insufficient storage space for pack ${pack.title}',
        );
      }

      // Create download queue
      final downloadQueue = _createDownloadQueue(pack);

      // Initialize progress tracking
      final packProgress = _createPackProgress(pack);
      _progressTracker.initializePackProgress(packProgress);

      // Process downloads
      await _queueProcessor.processPackQueue(
        packId: packId,
        queue: downloadQueue,
        onProgress: (progress) =>
            _progressTracker.updateImageProgress(progress),
        onComplete: _handleDownloadComplete,
        onError: _handleDownloadError,
      );

      // Save pack cache
      final packCache = PackCache.create(
        id: packId,
        version: pack.version,
        manifest: pack,
      );
      await _cacheService.savePackCache(packCache);

      // Update final status
      _statusManager.markAsCompleted(packId);
    } on Exception catch (e) {
      _statusManager.markAsFailed(packId);

      final downloadError = e is DownloadError
          ? e
          : DownloadError.unknown('pack:$packId', e.toString());

      throw downloadError;
    }
  }

  /// Create download queue for a pack
  DownloadQueue _createDownloadQueue(Pack pack) {
    var queue = DownloadQueue.empty();

    for (final image in pack.images) {
      final downloadId = generateDownloadId(pack.id, image.id);

      final item = DownloadItem(
        id: downloadId,
        packId: pack.id,
        imageId: image.id,
        imageUrl: image.url,
        type: DownloadType.image,
        status: DownloadStatus.queued,
        priority: 1,
        retryCount: 0,
        queuedAt: DateTime.now(),
      );

      queue = queue.addDownload(item);
    }

    return queue;
  }

  /// Create pack progress tracking
  PackDownloadProgress _createPackProgress(Pack pack) {
    final imageProgresses = <DownloadProgress>[];

    for (final image in pack.images) {
      final downloadId = generateDownloadId(pack.id, image.id);

      imageProgresses.add(
        DownloadProgress.started(
          downloadId: downloadId,
          packId: pack.id,
          imageId: image.id,
          totalBytes: 0, // Will be updated during download
        ),
      );
    }

    return PackDownloadProgress(
      packId: pack.id,
      imageProgresses: imageProgresses,
      startTime: DateTime.now(),
    );
  }

  /// Handle successful download completion
  void _handleDownloadComplete(DownloadItem item) {
    // Download completion is already handled by progress updates
    // This could be used for additional logging or analytics
  }

  /// Handle download errors
  void _handleDownloadError(DownloadItem item, DownloadError error) {
    // Error handling is managed by progress updates
    // This could be used for additional error reporting
    debugPrint('Download error for ${item.imageId}: ${error.message}');
  }

  // Public API - Cleanup Operations

  /// Delete a pack and all its files
  Future<void> deletePack(String packId) async {
    final result = await _packCleaner.deletePack(packId);

    if (result.success) {
      _statusManager.resetPackStatus(packId);
      _progressTracker.removePackProgress(packId);
    } else {
      throw Exception('Failed to delete pack: ${result.message}');
    }
  }

  /// Get cleanup candidates
  Future<List<CleanupCandidate>> getCleanupCandidates() =>
      _packCleaner.getCleanupCandidates();

  /// Clean up all cached packs
  Future<CleanupSummary> cleanupAllCachedPacks() =>
      _packCleaner.cleanupAllCachedPacks();

  /// Get total cached size
  Future<int> getTotalCachedSize() => _packCleaner.getTotalCachedSize();

  // Public API - Queue Management

  /// Get download queue statistics
  QueueStatistics getQueueStatistics(String packId) =>
      _queueProcessor.getQueueStatistics(packId);

  /// Get number of active downloads
  int getActiveDownloadCount() => _queueProcessor.getActiveDownloadCount();

  /// Check if download manager is busy
  bool isBusy() => _queueProcessor.isBusy();

  /// Cancel pack downloads
  Future<void> cancelPackDownloads(String packId) async {
    await _queueProcessor.cancelPackDownloads(packId);
    _statusManager.resetPackStatus(packId);
  }

  /// Retry failed downloads
  Future<void> retryFailedDownloads(String packId) async {
    await _queueProcessor.retryFailedDownloads(
      packId: packId,
      onProgress: (progress) => _progressTracker.updateImageProgress(progress),
      onComplete: _handleDownloadComplete,
      onError: _handleDownloadError,
    );
  }

  // Backward compatibility method (deprecated)
  @Deprecated('Use hasEnoughSpace instead')
  Future<bool> checkFreeSpaceBeforeDownload(int downloadFileSizeInBytes) =>
      _storageChecker.hasEnoughSpace(downloadFileSizeInBytes);

  /// Get current download queue (for backward compatibility)
  Future<DownloadQueue> getDownloadQueue() => _cacheService.loadDownloadQueue();

  @override
  void dispose() {
    _statusManager.dispose();
    _progressTracker.dispose();
    _queueProcessor.dispose();
    super.dispose();
  }
}
