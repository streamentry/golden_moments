import 'package:equatable/equatable.dart';
import 'package:golden_moments/data/models/download_error.dart';

/// Download progress tracking for individual downloads
class DownloadProgress extends Equatable {
  const DownloadProgress({
    required this.downloadId,
    required this.packId,
    required this.status,
    required this.bytesDownloaded,
    required this.totalBytes,
    required this.startTime,
    this.imageId,
    this.endTime,
    this.error,
    this.speed,
    this.eta,
  });

  /// Create cancelled progress
  factory DownloadProgress.cancelled({
    required String downloadId,
    required String packId,
    required int bytesDownloaded,
    required int totalBytes,
    required DateTime startTime,
    String? imageId,
  }) {
    return DownloadProgress(
      downloadId: downloadId,
      packId: packId,
      imageId: imageId,
      status: DownloadProgressStatus.cancelled,
      bytesDownloaded: bytesDownloaded,
      totalBytes: totalBytes,
      startTime: startTime,
      endTime: DateTime.now(),
    );
  }

  /// Create paused progress
  factory DownloadProgress.paused({
    required String downloadId,
    required String packId,
    required int bytesDownloaded,
    required int totalBytes,
    required DateTime startTime,
    String? imageId,
  }) {
    return DownloadProgress(
      downloadId: downloadId,
      packId: packId,
      imageId: imageId,
      status: DownloadProgressStatus.paused,
      bytesDownloaded: bytesDownloaded,
      totalBytes: totalBytes,
      startTime: startTime,
    );
  }

  /// Create failed progress
  factory DownloadProgress.failed({
    required String downloadId,
    required String packId,
    required int bytesDownloaded,
    required int totalBytes,
    required DateTime startTime,
    required DownloadError error,
    String? imageId,
  }) {
    return DownloadProgress(
      downloadId: downloadId,
      packId: packId,
      imageId: imageId,
      status: DownloadProgressStatus.failed,
      bytesDownloaded: bytesDownloaded,
      totalBytes: totalBytes,
      startTime: startTime,
      endTime: DateTime.now(),
      error: error,
    );
  } // estimated time remaining

  /// Create initial progress
  factory DownloadProgress.started({
    required String downloadId,
    required String packId,
    required int totalBytes,
    String? imageId,
  }) {
    return DownloadProgress(
      downloadId: downloadId,
      packId: packId,
      imageId: imageId,
      status: DownloadProgressStatus.downloading,
      bytesDownloaded: 0,
      totalBytes: totalBytes,
      startTime: DateTime.now(),
    );
  }

  /// Create completed progress
  factory DownloadProgress.completed({
    required String downloadId,
    required String packId,
    required int totalBytes,
    required DateTime startTime,
    String? imageId,
  }) {
    return DownloadProgress(
      downloadId: downloadId,
      packId: packId,
      imageId: imageId,
      status: DownloadProgressStatus.completed,
      bytesDownloaded: totalBytes,
      totalBytes: totalBytes,
      startTime: startTime,
      endTime: DateTime.now(),
    );
  }

  final String downloadId;
  final String packId;
  final String? imageId;
  final DownloadProgressStatus status;
  final int bytesDownloaded;
  final int totalBytes;
  final DateTime startTime;
  final DateTime? endTime;
  final DownloadError? error;
  final double? speed; // bytes per second
  final Duration? eta;

  /// Update progress with new bytes downloaded
  DownloadProgress updateProgress({
    required int bytesDownloaded,
    double? speed,
    Duration? eta,
  }) {
    return DownloadProgress(
      downloadId: downloadId,
      packId: packId,
      imageId: imageId,
      status: status,
      bytesDownloaded: bytesDownloaded,
      totalBytes: totalBytes,
      startTime: startTime,
      endTime: endTime,
      error: error,
      speed: speed,
      eta: eta,
    );
  }

  /// Mark as completed
  DownloadProgress complete() {
    return DownloadProgress(
      downloadId: downloadId,
      packId: packId,
      imageId: imageId,
      status: DownloadProgressStatus.completed,
      bytesDownloaded: totalBytes,
      totalBytes: totalBytes,
      startTime: startTime,
      endTime: DateTime.now(),
      error: error,
      speed: speed,
      eta: Duration.zero,
    );
  }

  /// Mark as failed
  DownloadProgress fail(DownloadError error) {
    return DownloadProgress(
      downloadId: downloadId,
      packId: packId,
      imageId: imageId,
      status: DownloadProgressStatus.failed,
      bytesDownloaded: bytesDownloaded,
      totalBytes: totalBytes,
      startTime: startTime,
      endTime: DateTime.now(),
      error: error,
      speed: speed,
    );
  }

  /// Mark as cancelled
  DownloadProgress cancel() {
    return DownloadProgress(
      downloadId: downloadId,
      packId: packId,
      imageId: imageId,
      status: DownloadProgressStatus.cancelled,
      bytesDownloaded: bytesDownloaded,
      totalBytes: totalBytes,
      startTime: startTime,
      endTime: DateTime.now(),
      error: error,
      speed: speed,
    );
  }

  /// Get progress percentage (0.0 to 1.0)
  double get progressPercentage {
    if (totalBytes == 0) return 0;
    return (bytesDownloaded / totalBytes).clamp(0.0, 1.0);
  }

  /// Get progress percentage as integer (0 to 100)
  int get progressPercent => (progressPercentage * 100).round();

  /// Get elapsed time
  Duration get elapsedTime {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  /// Check if download is active
  bool get isActive => status == DownloadProgressStatus.downloading;

  /// Check if download is completed
  bool get isCompleted => status == DownloadProgressStatus.completed;

  /// Check if download failed
  bool get isFailed => status == DownloadProgressStatus.failed;

  /// Check if download was cancelled
  bool get isCancelled => status == DownloadProgressStatus.cancelled;

  /// Check if download is finished (completed, failed, or cancelled)
  bool get isFinished =>
      status == DownloadProgressStatus.completed ||
      status == DownloadProgressStatus.failed ||
      status == DownloadProgressStatus.cancelled;

  /// Get remaining bytes
  int get remainingBytes => (totalBytes - bytesDownloaded).clamp(0, totalBytes);

  /// Format bytes for display
  String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Get formatted progress text
  String get progressText {
    return '${formatBytes(bytesDownloaded)} / ${formatBytes(totalBytes)}';
  }

  /// Get formatted speed text
  String get speedText {
    if (speed == null || speed! <= 0) return '';

    if (speed! < 1024) {
      return '${speed!.toStringAsFixed(0)} B/s';
    } else if (speed! < 1024 * 1024) {
      return '${(speed! / 1024).toStringAsFixed(1)} KB/s';
    } else {
      return '${(speed! / (1024 * 1024)).toStringAsFixed(1)} MB/s';
    }
  }

  /// Get formatted ETA text
  String get etaText {
    if (eta == null || eta!.inSeconds <= 0) return '';

    if (eta!.inHours > 0) {
      return '${eta!.inHours}h ${eta!.inMinutes % 60}m';
    } else if (eta!.inMinutes > 0) {
      return '${eta!.inMinutes}m ${eta!.inSeconds % 60}s';
    } else {
      return '${eta!.inSeconds}s';
    }
  }

  /// Get status display text
  String get statusText {
    switch (status) {
      case DownloadProgressStatus.downloading:
        return 'Downloading...';
      case DownloadProgressStatus.completed:
        return 'Completed';
      case DownloadProgressStatus.failed:
        return 'Failed';
      case DownloadProgressStatus.cancelled:
        return 'Cancelled';
      case DownloadProgressStatus.paused:
        return 'Paused';
    }
  }

  /// Get status icon
  String get statusIcon {
    switch (status) {
      case DownloadProgressStatus.downloading:
        return '⬇️';
      case DownloadProgressStatus.completed:
        return '✅';
      case DownloadProgressStatus.failed:
        return '❌';
      case DownloadProgressStatus.cancelled:
        return '⏹️';
      case DownloadProgressStatus.paused:
        return '⏸️';
    }
  }

  @override
  List<Object?> get props => [
    downloadId,
    packId,
    imageId,
    status,
    bytesDownloaded,
    totalBytes,
    startTime,
    endTime,
    error,
    speed,
    eta,
  ];
}

/// Download progress status enumeration
enum DownloadProgressStatus {
  downloading,
  paused,
  completed,
  failed,
  cancelled,
}

/// Pack download progress aggregating multiple image downloads
class PackDownloadProgress extends Equatable {
  const PackDownloadProgress({
    required this.packId,
    required this.imageProgresses,
    required this.startTime,
    this.endTime,
  });

  final String packId;
  final List<DownloadProgress> imageProgresses;
  final DateTime startTime;
  final DateTime? endTime;

  /// Get overall progress percentage (0.0 to 1.0)
  double get overallProgress {
    if (imageProgresses.isEmpty) return 0;

    final totalBytes = imageProgresses.fold<int>(
      0,
      (sum, progress) => sum + progress.totalBytes,
    );

    if (totalBytes == 0) return 0;

    final downloadedBytes = imageProgresses.fold<int>(
      0,
      (sum, progress) => sum + progress.bytesDownloaded,
    );

    return (downloadedBytes / totalBytes).clamp(0.0, 1.0);
  }

  /// Get completed images count
  int get completedImages => imageProgresses.where((p) => p.isCompleted).length;

  /// Get total images count
  int get totalImages => imageProgresses.length;

  /// Check if pack download is completed
  bool get isCompleted =>
      imageProgresses.isNotEmpty && imageProgresses.every((p) => p.isCompleted);

  /// Check if pack download has any failures
  bool get hasFailed => imageProgresses.any((p) => p.isFailed);

  /// Check if pack download is active
  bool get isActive => imageProgresses.any((p) => p.isActive);

  /// Get average download speed
  double get averageSpeed {
    final activeProgresses = imageProgresses.where((p) => p.speed != null);
    if (activeProgresses.isEmpty) return 0;

    final totalSpeed = activeProgresses.fold<double>(
      0,
      (sum, progress) => sum + (progress.speed ?? 0.0),
    );

    return totalSpeed / activeProgresses.length;
  }

  /// Get estimated time remaining
  Duration get estimatedTimeRemaining {
    if (averageSpeed <= 0) return Duration.zero;

    final remainingBytes = imageProgresses.fold<int>(
      0,
      (sum, progress) => sum + progress.remainingBytes,
    );

    if (remainingBytes <= 0) return Duration.zero;

    final secondsRemaining = remainingBytes / averageSpeed;
    return Duration(seconds: secondsRemaining.round());
  }

  /// Get progress text for display
  String get progressText {
    return '$completedImages / $totalImages images';
  }

  /// Get progress base on image
  double get progressByImage {
    return (completedImages / totalImages).clamp(0.00, 1.00);
  }

  @override
  List<Object?> get props => [
    packId,
    imageProgresses,
    startTime,
    endTime,
  ];
}
