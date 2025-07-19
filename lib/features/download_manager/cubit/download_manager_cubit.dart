import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:golden_moments/data/models/download_progress.dart';
import 'package:golden_moments/data/services/download_manager.dart';

/// Cubit for managing download manager state
class DownloadManagerCubit extends Cubit<DownloadManagerState> {
  DownloadManagerCubit() : super(const DownloadManagerState());

  final DownloadManager _downloadManager = DownloadManager.instance;
  StreamSubscription<DownloadProgress>? _progressSubscription;

  /// Initialize download manager
  Future<void> initialize() async {
    emit(state.copyWith(status: DownloadManagerStatus.loading));

    try {
      // Subscribe to download progress updates
      // _progressSubscription = _downloadManager.progressStream.listen(
      //   _onDownloadProgressUpdate,
      //   onError: (error) {
      //     emit(
      //       state.copyWith(
      //         status: DownloadManagerStatus.error,
      //         errorMessage: 'Download monitoring failed: $error',
      //       ),
      //     );
      //   },
      // );

      // Load current download state
      await _loadDownloadState();

      emit(state.copyWith(status: DownloadManagerStatus.loaded));
    } catch (e) {
      emit(
        state.copyWith(
          status: DownloadManagerStatus.error,
          errorMessage: 'Failed to initialize download manager: $e',
        ),
      );
    }
  }

  /// Refresh downloads
  Future<void> refreshDownloads() async {
    await _loadDownloadState();
  }

  /// Pause all active downloads
  Future<void> pauseAllDownloads() async {
    try {
      for (final download in state.activeDownloads) {
        // await _downloadManager.pauseDownload(download.downloadId);
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: DownloadManagerStatus.error,
          errorMessage: 'Failed to pause downloads: $e',
        ),
      );
    }
  }

  /// Resume all paused downloads
  Future<void> resumeAllDownloads() async {
    try {
      for (final download in state.activeDownloads) {
        if (download.status == DownloadProgressStatus.failed) {
          // await _downloadManager.resumeDownload(download.downloadId);
        }
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: DownloadManagerStatus.error,
          errorMessage: 'Failed to resume downloads: $e',
        ),
      );
    }
  }

  /// Cancel specific download
  Future<void> cancelDownload(String downloadId) async {
    try {
      await _downloadManager.cancelDownload(downloadId);
      await _loadDownloadState();
    } catch (e) {
      emit(
        state.copyWith(
          status: DownloadManagerStatus.error,
          errorMessage: 'Failed to cancel download: $e',
        ),
      );
    }
  }

  /// Pause specific download
  Future<void> pauseDownload(String downloadId) async {
    try {
      // await _downloadManager.pauseDownload(downloadId);
    } catch (e) {
      emit(
        state.copyWith(
          status: DownloadManagerStatus.error,
          errorMessage: 'Failed to pause download: $e',
        ),
      );
    }
  }

  /// Resume specific download
  Future<void> resumeDownload(String downloadId) async {
    try {
      // await _downloadManager.resumeDownload(downloadId);
    } catch (e) {
      emit(
        state.copyWith(
          status: DownloadManagerStatus.error,
          errorMessage: 'Failed to resume download: $e',
        ),
      );
    }
  }

  /// Clear completed downloads from list
  void clearCompletedDownloads() {
    emit(state.copyWith(completedDownloads: []));
  }

  /// Handle download progress updates
  void _onDownloadProgressUpdate(DownloadProgress progress) {
    final updatedState = _updateDownloadInState(progress);
    emit(updatedState);
  }

  /// Update download progress in state
  DownloadManagerState _updateDownloadInState(DownloadProgress progress) {
    // Remove from all lists first
    final activeDownloads = List<DownloadProgress>.from(state.activeDownloads)
      ..removeWhere((d) => d.downloadId == progress.downloadId);
    final queuedDownloads = List<DownloadProgress>.from(state.queuedDownloads)
      ..removeWhere((d) => d.downloadId == progress.downloadId);
    final completedDownloads = List<DownloadProgress>.from(
      state.completedDownloads,
    )..removeWhere((d) => d.downloadId == progress.downloadId);

    // Add to appropriate list based on status
    switch (progress.status) {
      case DownloadProgressStatus.downloading:
        activeDownloads.add(progress);
      case DownloadProgressStatus.completed:
        completedDownloads.add(progress);
      case DownloadProgressStatus.failed:
        activeDownloads.add(
          progress,
        ); // Failed downloads stay in active for retry
      case DownloadProgressStatus.cancelled:
        // Don't add cancelled downloads to any list
        break;
    }

    return state.copyWith(
      activeDownloads: activeDownloads,
      queuedDownloads: queuedDownloads,
      completedDownloads: completedDownloads,
    );
  }

  /// Load current download state
  Future<void> _loadDownloadState() async {
    // This would typically load from the download manager's current state
    // For now, we'll use empty lists and rely on progress stream updates

    // In a real implementation, you might:
    // final queue = await _downloadManager.getDownloadQueue();
    // final activeDownloads = queue.activeDownloads.map((item) =>
    //   DownloadProgress.fromDownloadItem(item)).toList();
    // final queuedDownloads = queue.queuedDownloads.map((item) =>
    //   DownloadProgress.fromDownloadItem(item)).toList();

    emit(
      state.copyWith(
        activeDownloads: [],
        queuedDownloads: [],
        completedDownloads:
            state.completedDownloads, // Keep completed downloads
      ),
    );
  }

  @override
  Future<void> close() {
    _progressSubscription?.cancel();
    return super.close();
  }
}

/// Download manager state
class DownloadManagerState extends Equatable {
  const DownloadManagerState({
    this.status = DownloadManagerStatus.initial,
    this.activeDownloads = const [],
    this.queuedDownloads = const [],
    this.completedDownloads = const [],
    this.errorMessage = '',
  });

  final DownloadManagerStatus status;
  final List<DownloadProgress> activeDownloads;
  final List<DownloadProgress> queuedDownloads;
  final List<DownloadProgress> completedDownloads;
  final String errorMessage;

  /// Check if there are any downloads
  bool get hasAnyDownloads =>
      activeDownloads.isNotEmpty ||
      queuedDownloads.isNotEmpty ||
      completedDownloads.isNotEmpty;

  /// Check if there are active downloads
  bool get hasActiveDownloads => activeDownloads.isNotEmpty;

  /// Check if there are completed downloads
  bool get hasCompletedDownloads => completedDownloads.isNotEmpty;

  /// Get total download count
  int get totalDownloads =>
      activeDownloads.length +
      queuedDownloads.length +
      completedDownloads.length;

  DownloadManagerState copyWith({
    DownloadManagerStatus? status,
    List<DownloadProgress>? activeDownloads,
    List<DownloadProgress>? queuedDownloads,
    List<DownloadProgress>? completedDownloads,
    String? errorMessage,
  }) {
    return DownloadManagerState(
      status: status ?? this.status,
      activeDownloads: activeDownloads ?? this.activeDownloads,
      queuedDownloads: queuedDownloads ?? this.queuedDownloads,
      completedDownloads: completedDownloads ?? this.completedDownloads,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    activeDownloads,
    queuedDownloads,
    completedDownloads,
    errorMessage,
  ];
}

/// Download manager status enumeration
enum DownloadManagerStatus {
  initial,
  loading,
  loaded,
  error,
}
