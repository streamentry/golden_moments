import 'package:equatable/equatable.dart';
import 'package:golden_moments/data/models/download_progress.dart';

/// Download manager status enumeration
enum DownloadManagerStatus {
  isInitial,
  isPending,
  isCompleted,
  isError,
}

/// Download manager state
class DownloadManagerState extends Equatable {
  const DownloadManagerState({
    this.status = DownloadManagerStatus.isInitial,
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
