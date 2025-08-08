import 'package:flutter/foundation.dart';
import 'package:golden_moments/data/models/download_progress.dart';

/// Tracks and manages download progress for packs and individual images
class ProgressTracker extends ChangeNotifier {
  ProgressTracker();

  final Map<String, PackDownloadProgress> _packsProgress = {};

  /// Get download progress for a specific pack
  double getPackDownloadProgress(String packId) {
    if (_packsProgress.containsKey(packId)) {
      return _packsProgress[packId]!.progressByImage;
    }
    return 0;
  }

  /// Get detailed progress information for a pack
  PackDownloadProgress? getPackProgressDetails(String packId) {
    return _packsProgress[packId];
  }

  /// Initialize pack progress tracking
  void initializePackProgress(PackDownloadProgress packProgress) {
    _packsProgress[packProgress.packId] = packProgress;
    notifyListeners();
  }

  /// Update progress for a specific image within a pack
  void updateImageProgress(DownloadProgress imageProgress) {
    final packId = imageProgress.packId;
    if (!_packsProgress.containsKey(packId)) {
      return;
    }

    final packProgress = _packsProgress[packId]!;
    final imageProgresses = packProgress.imageProgresses;

    // Find and update the specific image progress
    final index = imageProgresses.indexWhere(
      (progress) => progress.imageId == imageProgress.imageId,
    );

    if (index != -1) {
      imageProgresses[index] = imageProgress;
      notifyListeners();
    }
  }

  /// Get progress for a specific image
  DownloadProgress? getImageProgress(String packId, String imageId) {
    final packProgress = _packsProgress[packId];
    if (packProgress == null) return null;

    try {
      return packProgress.imageProgresses.firstWhere(
        (progress) => progress.imageId == imageId,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get all image progresses for a pack
  List<DownloadProgress> getImageProgresses(String packId) {
    return _packsProgress[packId]?.imageProgresses ?? [];
  }

  /// Check if pack download is completed
  bool isPackDownloadCompleted(String packId) {
    final packProgress = _packsProgress[packId];
    if (packProgress == null) return false;

    return packProgress.imageProgresses.every(
      (progress) => progress.status == DownloadProgressStatus.completed,
    );
  }

  /// Get number of completed images in a pack
  int getCompletedImageCount(String packId) {
    final packProgress = _packsProgress[packId];
    if (packProgress == null) return 0;

    return packProgress.imageProgresses
        .where(
          (progress) => progress.status == DownloadProgressStatus.completed,
        )
        .length;
  }

  /// Get total number of images in a pack
  int getTotalImageCount(String packId) {
    return _packsProgress[packId]?.imageProgresses.length ?? 0;
  }

  /// Get download speed for a pack (average of all active downloads)
  double getPackDownloadSpeed(String packId) {
    final packProgress = _packsProgress[packId];
    if (packProgress == null) return 0;

    final activeDownloads = packProgress.imageProgresses
        .where(
          (progress) => progress.status == DownloadProgressStatus.downloading,
        )
        .toList();

    if (activeDownloads.isEmpty) return 0;

    final totalSpeed = activeDownloads
        .map((progress) => progress.downloadSpeed)
        .fold(0, (sum, speed) => sum + speed);

    return totalSpeed / activeDownloads.length;
  }

  /// Get estimated time remaining for pack download
  Duration? getPackETA(String packId) {
    final packProgress = _packsProgress[packId];
    if (packProgress == null) return null;

    final activeDownloads = packProgress.imageProgresses
        .where(
          (progress) => progress.status == DownloadProgressStatus.downloading,
        )
        .toList();

    if (activeDownloads.isEmpty) return null;

    // Calculate average ETA from active downloads
    final etas = activeDownloads
        .map((progress) => progress.eta)
        .where((eta) => eta != null)
        .cast<Duration>()
        .toList();

    if (etas.isEmpty) return null;

    final totalSeconds = etas
        .map((eta) => eta.inSeconds)
        .fold(0, (sum, seconds) => sum + seconds);

    return Duration(seconds: (totalSeconds / etas.length).round());
  }

  /// Remove progress tracking for a pack
  void removePackProgress(String packId) {
    _packsProgress.remove(packId);
    notifyListeners();
  }

  /// Clear all progress data
  void clearAllProgress() {
    _packsProgress.clear();
    notifyListeners();
  }

  /// Get overall download statistics
  DownloadStatistics getOverallStatistics() {
    final totalPacks = _packsProgress.length;
    final completedPacks = _packsProgress.values
        .where((progress) => isPackDownloadCompleted(progress.packId))
        .length;

    final totalImages = _packsProgress.values
        .map((progress) => progress.imageProgresses.length)
        .fold(0, (sum, count) => sum + count);

    final completedImages = _packsProgress.values
        .map((progress) => getCompletedImageCount(progress.packId))
        .fold(0, (sum, count) => sum + count);

    final totalSpeed = _packsProgress.keys
        .map(getPackDownloadSpeed)
        .fold(0, (sum, speed) => sum + speed);

    return DownloadStatistics(
      totalPacks: totalPacks,
      completedPacks: completedPacks,
      totalImages: totalImages,
      completedImages: completedImages,
      totalDownloadSpeed: totalSpeed,
    );
  }
}

/// Overall download statistics
class DownloadStatistics {
  const DownloadStatistics({
    required this.totalPacks,
    required this.completedPacks,
    required this.totalImages,
    required this.completedImages,
    required this.totalDownloadSpeed,
  });

  final int totalPacks;
  final int completedPacks;
  final int totalImages;
  final int completedImages;
  final double totalDownloadSpeed;

  double get packProgress => totalPacks > 0 ? completedPacks / totalPacks : 0.0;
  double get imageProgress =>
      totalImages > 0 ? completedImages / totalImages : 0.0;
}
