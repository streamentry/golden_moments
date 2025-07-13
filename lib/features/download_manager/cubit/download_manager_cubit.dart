import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:golden_moments/data/models/download_progress.dart';
import 'package:golden_moments/data/models/download_queue.dart';
import 'package:golden_moments/data/services/download_manager.dart';
import 'package:golden_moments/features/download_manager/cubit/download_manager_state.dart';

/// Cubit for managing download manager state
class DownloadManagerCubit extends Cubit<DownloadManagerState> {
  DownloadManagerCubit() : super(const DownloadManagerState());

  final DownloadManager _downloadManager = DownloadManager();
  final Map<String, StreamSubscription<DownloadProgress>>
  _downloadSubscriptions = {};

  /// Initialize download manager
  Future<void> initialize() async {
    emit(state.copyWith(status: DownloadManagerStatus.isPending));

    try {
      // Simply try to load download state with retry
      await _loadDownloadStateWithRetry();

      emit(state.copyWith(status: DownloadManagerStatus.isCompleted));
    } catch (e) {
      print('❌ Failed to initialize download manager cubit: $e');
      emit(
        state.copyWith(
          status: DownloadManagerStatus.isError,
          errorMessage: 'Failed to initialize download manager: $e',
        ),
      );
    }
  }

  /// Load download state with retry mechanism
  Future<void> _loadDownloadStateWithRetry() async {
    int attempts = 0;
    const maxAttempts = 10;

    while (attempts < maxAttempts) {
      try {
        await _loadDownloadState();
        return; // Success
      } catch (e) {
        if (e.toString().contains('JsonCacheService not initialized')) {
          print('⏳ Services not ready, retrying... attempt ${attempts + 1}');
          await Future<void>.delayed(const Duration(milliseconds: 200));
          attempts++;
        } else {
          // Different error, rethrow
          rethrow;
        }
      }
    }

    throw Exception(
      'Services failed to initialize after $maxAttempts attempts',
    );
  }

  /// Start downloading a game pack
  Future<void> downloadPack(String packId) async {
    print('🔄 Starting download for pack: $packId');

    try {
      await _downloadManager.downloadPack(packId);
      print('✅ Download manager called successfully for pack: $packId');

      // Load state to get new downloads
      await _loadDownloadState();
      print(
        '📊 State loaded. Active: ${state.activeDownloads.length}, Queued: ${state.queuedDownloads.length}',
      );

      // Subscribe to progress for all new downloads for this pack
      for (final download in state.activeDownloads.where(
        (d) => d.packId == packId,
      )) {
        print('📡 Subscribing to active download: ${download.downloadId}');
        subscribeToDownloadProgress(download.downloadId);
      }
      for (final download in state.queuedDownloads.where(
        (d) => d.packId == packId,
      )) {
        print('📡 Subscribing to queued download: ${download.downloadId}');
        subscribeToDownloadProgress(download.downloadId);
      }
    } catch (e) {
      print('❌ Failed to start pack download: $e');
      emit(
        state.copyWith(
          status: DownloadManagerStatus.isError,
          errorMessage: 'Failed to start pack download: $e',
        ),
      );
    }
  }

  /// Subscribe to download progress for a specific download
  void subscribeToDownloadProgress(String downloadId) {
    // Cancel existing subscription if any
    _downloadSubscriptions[downloadId]?.cancel();

    // Subscribe to progress updates
    _downloadSubscriptions[downloadId] = _downloadManager
        .getDownloadProgress(downloadId)
        .listen(
          (progress) => _handleProgressUpdate(progress),
          onError: (Object error) {
            emit(
              state.copyWith(
                status: DownloadManagerStatus.isError,
                errorMessage: 'Download progress error: $error',
              ),
            );
          },
        );
  }

  /// Handle progress update from download manager
  void _handleProgressUpdate(DownloadProgress progress) {
    // Update the appropriate list based on status
    switch (progress.status) {
      case DownloadProgressStatus.downloading:
        _updateActiveDownloads(progress);
        break;
      case DownloadProgressStatus.paused:
        _moveToPaused(progress);
        break;
      case DownloadProgressStatus.completed:
        _moveToCompleted(progress);
        break;
      case DownloadProgressStatus.failed:
      case DownloadProgressStatus.cancelled:
        _removeFromActive(progress);
        break;
    }
  }

  /// Update active downloads list
  void _updateActiveDownloads(DownloadProgress progress) {
    final activeDownloads = List<DownloadProgress>.from(state.activeDownloads);
    final existingIndex = activeDownloads.indexWhere(
      (d) => d.downloadId == progress.downloadId,
    );

    if (existingIndex >= 0) {
      activeDownloads[existingIndex] = progress;
    } else {
      activeDownloads.add(progress);
    }

    emit(state.copyWith(activeDownloads: activeDownloads));
  }

  /// Move download to paused/queued list
  void _moveToPaused(DownloadProgress progress) {
    final activeDownloads = List<DownloadProgress>.from(state.activeDownloads);
    final queuedDownloads = List<DownloadProgress>.from(state.queuedDownloads);

    // Remove from active
    activeDownloads.removeWhere((d) => d.downloadId == progress.downloadId);

    // Add to queued (paused downloads go to queued list)
    final existingIndex = queuedDownloads.indexWhere(
      (d) => d.downloadId == progress.downloadId,
    );

    if (existingIndex >= 0) {
      queuedDownloads[existingIndex] = progress;
    } else {
      queuedDownloads.add(progress);
    }

    emit(
      state.copyWith(
        activeDownloads: activeDownloads,
        queuedDownloads: queuedDownloads,
      ),
    );
  }

  /// Move download to completed list
  void _moveToCompleted(DownloadProgress progress) {
    final activeDownloads = List<DownloadProgress>.from(state.activeDownloads);
    final completedDownloads = List<DownloadProgress>.from(
      state.completedDownloads,
    );

    // Remove from active
    activeDownloads.removeWhere((d) => d.downloadId == progress.downloadId);

    // Add to completed
    completedDownloads.add(progress);

    emit(
      state.copyWith(
        activeDownloads: activeDownloads,
        completedDownloads: completedDownloads,
      ),
    );
  }

  /// Remove from active downloads
  void _removeFromActive(DownloadProgress progress) {
    final activeDownloads = List<DownloadProgress>.from(state.activeDownloads);
    activeDownloads.removeWhere((d) => d.downloadId == progress.downloadId);

    emit(state.copyWith(activeDownloads: activeDownloads));
  }

  /// Refresh downloads
  Future<void> refreshDownloads() async {
    await _loadDownloadState();
  }

  /// Pause all active downloads
  Future<void> pauseAllDownloads() async {
    try {
      for (final download in state.activeDownloads) {
        await _downloadManager.pauseDownload(download.downloadId);
      }
      await _loadDownloadState();
    } catch (e) {
      emit(
        state.copyWith(
          status: DownloadManagerStatus.isError,
          errorMessage: 'Failed to pause downloads: $e',
        ),
      );
    }
  }

  /// Resume all paused downloads
  Future<void> resumeAllDownloads() async {
    try {
      for (final download in state.queuedDownloads) {
        await _downloadManager.resumeDownload(download.downloadId);
      }
      await _loadDownloadState();
    } catch (e) {
      emit(
        state.copyWith(
          status: DownloadManagerStatus.isError,
          errorMessage: 'Failed to resume downloads: $e',
        ),
      );
    }
  }

  /// Cancel specific download
  Future<void> cancelDownload(String downloadId) async {
    try {
      await _downloadManager.cancelDownload(downloadId);

      // Cancel subscription
      _downloadSubscriptions[downloadId]?.cancel();
      _downloadSubscriptions.remove(downloadId);

      await _loadDownloadState();
    } catch (e) {
      emit(
        state.copyWith(
          status: DownloadManagerStatus.isError,
          errorMessage: 'Failed to cancel download: $e',
        ),
      );
    }
  }

  /// Pause specific download
  Future<void> pauseDownload(String downloadId) async {
    try {
      await _downloadManager.pauseDownload(downloadId);
      await _loadDownloadState();
    } catch (e) {
      emit(
        state.copyWith(
          status: DownloadManagerStatus.isError,
          errorMessage: 'Failed to pause download: $e',
        ),
      );
    }
  }

  /// Resume specific download
  Future<void> resumeDownload(String downloadId) async {
    try {
      await _downloadManager.resumeDownload(downloadId);
      await _loadDownloadState();
    } catch (e) {
      emit(
        state.copyWith(
          status: DownloadManagerStatus.isError,
          errorMessage: 'Failed to resume download: $e',
        ),
      );
    }
  }

  /// Retry specific download
  Future<void> retryDownload(String downloadId) async {
    try {
      await _downloadManager.retryDownload(downloadId);

      // Subscribe to progress updates for the retried download
      subscribeToDownloadProgress(downloadId);

      await _loadDownloadState();
    } catch (e) {
      emit(
        state.copyWith(
          status: DownloadManagerStatus.isError,
          errorMessage: 'Failed to retry download: $e',
        ),
      );
    }
  }

  /// Clear completed downloads from list
  void clearCompletedDownloads() {
    emit(state.copyWith(completedDownloads: []));
  }

  /// Load current download state
  Future<void> _loadDownloadState() async {
    print('📊 Loading download state...');

    try {
      final queue = await _downloadManager.getDownloadQueue();
      print(
        '📋 Queue loaded: ${queue.activeDownloads.length} active, ${queue.queuedDownloads.length} queued, ${queue.completedDownloads.length} completed',
      );

      // Convert DownloadItems to DownloadProgress objects
      final activeDownloads = queue.activeDownloads
          .map((item) => _downloadItemToProgress(item))
          .toList();
      final queuedDownloads = queue.queuedDownloads
          .map((item) => _downloadItemToProgress(item))
          .toList();

      print(
        '🔄 Converted to progress: ${activeDownloads.length} active, ${queuedDownloads.length} queued',
      );

      // Set up progress subscriptions for active downloads
      for (final download in activeDownloads) {
        print('📡 Setting up subscription for: ${download.downloadId}');
        subscribeToDownloadProgress(download.downloadId);
      }

      emit(
        state.copyWith(
          activeDownloads: activeDownloads,
          queuedDownloads: queuedDownloads,
          completedDownloads:
              state.completedDownloads, // Keep completed downloads
        ),
      );

      print('✅ State updated successfully');
    } catch (e) {
      print('❌ Failed to load download state: $e');
      emit(
        state.copyWith(
          status: DownloadManagerStatus.isError,
          errorMessage: 'Failed to load download state: $e',
        ),
      );
    }
  }

  /// Convert DownloadItem to DownloadProgress
  DownloadProgress _downloadItemToProgress(DownloadItem item) {
    final status = _downloadStatusToProgressStatus(item.status);

    return DownloadProgress(
      downloadId: item.id,
      packId: item.packId,
      imageId: item.imageId,
      status: status,
      bytesDownloaded: (item.progress * 100)
          .toInt(), // Approximate based on progress
      totalBytes: 100, // Default, will be updated by actual download progress
      startTime: item.startedAt ?? item.queuedAt,
      endTime: item.completedAt,
    );
  }

  /// Convert DownloadStatus to DownloadProgressStatus
  DownloadProgressStatus _downloadStatusToProgressStatus(
    DownloadStatus status,
  ) {
    switch (status) {
      case DownloadStatus.queued:
        return DownloadProgressStatus
            .downloading; // Treat queued as downloading for UI
      case DownloadStatus.downloading:
        return DownloadProgressStatus.downloading;
      case DownloadStatus.completed:
        return DownloadProgressStatus.completed;
      case DownloadStatus.failed:
        return DownloadProgressStatus.failed;
      case DownloadStatus.cancelled:
        return DownloadProgressStatus.cancelled;
    }
  }

  @override
  Future<void> close() {
    // Cancel all download subscriptions
    for (final subscription in _downloadSubscriptions.values) {
      subscription.cancel();
    }
    _downloadSubscriptions.clear();

    return super.close();
  }
}
