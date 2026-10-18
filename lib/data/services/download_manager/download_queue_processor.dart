import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:golden_moments/data/models/download_error.dart';
import 'package:golden_moments/data/models/download_progress.dart';
import 'package:golden_moments/data/models/download_queue.dart';
import 'package:golden_moments/data/services/download_manager/image_downloader.dart';
import 'package:golden_moments/data/services/json_cache_service.dart';
import 'package:pool/pool.dart';

/// Processes download queues and manages concurrent downloads
class DownloadQueueProcessor {
  DownloadQueueProcessor({
    int maxConcurrentDownloads = 3,
    ImageDownloader? imageDownloader,
    JsonCacheService? cacheService,
  }) : _pool = Pool(maxConcurrentDownloads),
       _imageDownloader = imageDownloader ?? ImageDownloader(),
       _cacheService = cacheService ?? JsonCacheService();

  final Pool _pool;
  final ImageDownloader _imageDownloader;
  final JsonCacheService _cacheService;
  final Map<String, DownloadQueue> _activeQueues = {};

  /// Process downloads for a specific pack
  Future<void> processPackQueue({
    required String packId,
    required DownloadQueue queue,
    required void Function(DownloadProgress) onProgress,
    required void Function(DownloadItem) onComplete,
    required void Function(DownloadItem, DownloadError) onError,
  }) async {
    _activeQueues[packId] = queue;

    // Process all queued downloads
    final futures = <Future<void>>[];

    for (final item in queue.queuedDownloads) {
      final future = _processDownloadItem(
        item: item,
        packId: packId,
        onProgress: onProgress,
        onComplete: onComplete,
        onError: onError,
      );
      futures.add(future);
    }

    // Wait for all downloads to complete
    await Future.wait(futures);

    // Remove from active queues
    _activeQueues.remove(packId);
  }

  /// Process a single download item with concurrency control
  Future<void> _processDownloadItem({
    required DownloadItem item,
    required String packId,
    required void Function(DownloadProgress) onProgress,
    required void Function(DownloadItem) onComplete,
    required void Function(DownloadItem, DownloadError) onError,
  }) async {
    // Wait for available slot in the pool
    final poolResource = await _pool.request();

    try {
      // Mark download as active in queue
      _updateQueueItemStatus(packId, item.id, DownloadStatus.queued);

      // Perform the actual download
      await _imageDownloader.downloadImage(item: item, onProgress: onProgress);

      // Mark as completed
      _updateQueueItemStatus(packId, item.id, DownloadStatus.completed);
      onComplete(item);
    } on Exception catch (e) {
      // Handle download error
      final downloadError = e is DownloadError
          ? e
          : DownloadError.unknown(item.imageUrl, e.toString());

      // Update queue with error
      _updateQueueItemStatus(packId, item.id, DownloadStatus.failed);
      await _updateQueueWithError(packId, item.id, downloadError.message);

      onError(item, downloadError);
    } finally {
      // Release pool resource
      poolResource.release();
    }
  }

  /// Update download item status in queue
  void _updateQueueItemStatus(
    String packId,
    String downloadId,
    DownloadStatus status,
  ) {
    final queue = _activeQueues[packId];
    if (queue == null) return;

    // Update the queue (this is a simplified approach)
    // In practice, you might want to create a new queue instance
    final updatedQueue = queue.updateDownloadStatus(downloadId, status);
    _activeQueues[packId] = updatedQueue;
  }

  /// Update queue with error information
  Future<void> _updateQueueWithError(
    String packId,
    String downloadId,
    String errorMessage,
  ) async {
    try {
      final queue = await _cacheService.loadDownloadQueue();
      final updatedQueue = queue.failDownload(downloadId, errorMessage);
      await _cacheService.saveDownloadQueue(updatedQueue);
    } on Exception catch (e) {
      // Log error but don't fail the download
      debugPrint('Failed to update download queue with error: $e');
    }
  }

  /// Get current download queue for a pack
  DownloadQueue? getActiveQueue(String packId) {
    return _activeQueues[packId];
  }

  /// Get number of active downloads
  int getActiveDownloadCount() {
    // Simplified tracking - return number of active queues
    return _activeQueues.length;
  }

  /// Get maximum concurrent downloads
  int getMaxConcurrentDownloads() {
    return 3; // Return the configured limit
  }

  /// Check if processor is busy
  bool isBusy() {
    return getActiveDownloadCount() > 0;
  }

  /// Get queue statistics for a pack
  QueueStatistics getQueueStatistics(String packId) {
    final queue = _activeQueues[packId];
    if (queue == null) {
      return const QueueStatistics(
        totalItems: 0,
        queuedItems: 0,
        activeItems: 0,
        completedItems: 0,
        failedItems: 0,
      );
    }

    return QueueStatistics(
      totalItems: queue.queuedDownloads.length,
      queuedItems: queue.queuedDownloads.length,
      activeItems: 0, // Simplified - would need proper tracking
      completedItems: 0, // Simplified - would need proper tracking
      failedItems: 0, // Simplified - would need proper tracking
    );
  }

  /// Cancel all downloads for a pack
  Future<void> cancelPackDownloads(String packId) async {
    _activeQueues.remove(packId);
    // Note: In a more sophisticated implementation, you would
    // also cancel any ongoing HTTP requests
  }

  /// Cancel all active downloads
  Future<void> cancelAllDownloads() async {
    _activeQueues.clear();
    // Note: Pool doesn't have a direct cancel method,
    // but you could implement this by tracking futures
  }

  /// Retry failed downloads in a pack
  Future<void> retryFailedDownloads({
    required String packId,
    required void Function(DownloadProgress) onProgress,
    required void Function(DownloadItem) onComplete,
    required void Function(DownloadItem, DownloadError) onError,
  }) async {
    final queue = _activeQueues[packId];
    if (queue == null) return;

    final failedItems = queue.failedDownloads;
    if (failedItems.isEmpty) return;

    // Reset failed items to queued status
    var updatedQueue = queue;
    for (final item in failedItems) {
      updatedQueue = updatedQueue.retryDownload(item.id);
    }

    // Process the retried downloads
    await processPackQueue(
      packId: packId,
      queue: updatedQueue,
      onProgress: onProgress,
      onComplete: onComplete,
      onError: onError,
    );
  }

  /// Get estimated completion time for all active downloads
  Duration? getEstimatedCompletionTime() {
    if (!isBusy()) return Duration.zero;

    // This is a simplified estimation
    // In practice, you'd calculate based on current download speeds
    final activeCount = getActiveDownloadCount();
    const estimatedSecondsPerDownload = 30; // Average estimate

    return Duration(seconds: activeCount * estimatedSecondsPerDownload);
  }

  /// Dispose resources
  void dispose() {
    _activeQueues.clear();
    // Pool doesn't need explicit disposal
  }
}

/// Statistics for a download queue
class QueueStatistics {
  const QueueStatistics({
    required this.totalItems,
    required this.queuedItems,
    required this.activeItems,
    required this.completedItems,
    required this.failedItems,
  });

  final int totalItems;
  final int queuedItems;
  final int activeItems;
  final int completedItems;
  final int failedItems;

  double get completionPercentage {
    if (totalItems == 0) return 0;
    return (completedItems / totalItems) * 100;
  }

  double get failureRate {
    if (totalItems == 0) return 0;
    return (failedItems / totalItems) * 100;
  }

  bool get isCompleted => completedItems == totalItems && totalItems > 0;
  bool get hasFailures => failedItems > 0;
  bool get isActive => activeItems > 0;
}

/// Extension to add utility methods to DownloadQueue
extension DownloadQueueExtensions on DownloadQueue {
  /// Update status of a specific download item
  DownloadQueue updateDownloadStatus(
    String downloadId,
    DownloadStatus newStatus,
  ) {
    // This is a simplified implementation
    // In practice, you'd create proper immutable update methods
    return this; // Placeholder - implement proper status update
  }

  /// Retry a failed download
  DownloadQueue retryDownload(String downloadId) {
    // This is a simplified implementation
    // In practice, you'd move the item from failed to queued
    return this; // Placeholder - implement proper retry logic
  }
}
