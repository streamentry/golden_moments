import 'package:disk_space_plus/disk_space_plus.dart';
import 'package:flutter/foundation.dart';

/// Handles storage space checking and management
class StorageChecker {
  StorageChecker();

  static const int _minimumFreeSpaceMB = 200; // 200MB minimum free space
  static const int _bytesPerMB = 1024 * 1024;

  /// Check if there's enough free space for a download
  Future<bool> hasEnoughSpace(int downloadSizeInBytes) async {
    // On web, always return true to prevent blocking downloads
    if (kIsWeb) {
      return true;
    }

    try {
      final diskSpacePlus = DiskSpacePlus();
      final freeDiskSpaceMB = await diskSpacePlus.getFreeDiskSpace ?? 0;
      final freeDiskSpaceBytes = freeDiskSpaceMB * _bytesPerMB;

      // Check if we have enough space for download + minimum buffer
      final requiredSpace =
          downloadSizeInBytes + (_minimumFreeSpaceMB * _bytesPerMB);

      return freeDiskSpaceBytes >= requiredSpace;
    } on Exception {
      // On platforms where disk space check isn't available,
      // assume there's enough space to prevent blocking downloads
      return true;
    }
  }

  /// Get available disk space in bytes
  Future<int> getAvailableSpace() async {
    if (kIsWeb) {
      return -1; // Unknown on web
    }

    try {
      final diskSpacePlus = DiskSpacePlus();
      final freeDiskSpaceMB = await diskSpacePlus.getFreeDiskSpace ?? 0;
      return (freeDiskSpaceMB * _bytesPerMB).toInt();
    } on Exception {
      return -1; // Unable to determine
    }
  }

  /// Get available disk space in MB
  Future<double> getAvailableSpaceMB() async {
    if (kIsWeb) {
      return -1; // Unknown on web
    }

    try {
      final diskSpacePlus = DiskSpacePlus();
      return await diskSpacePlus.getFreeDiskSpace ?? -1;
    } on Exception {
      return -1; // Unable to determine
    }
  }

  /// Check if storage is critically low (less than minimum buffer)
  Future<bool> isStorageCriticallyLow() async {
    if (kIsWeb) {
      return false;
    }

    try {
      final availableSpaceMB = await getAvailableSpaceMB();
      return availableSpaceMB >= 0 && availableSpaceMB < _minimumFreeSpaceMB;
    } on Exception {
      return false;
    }
  }

  /// Get storage usage level (0.0 to 1.0, where 1.0 is full)
  Future<double> getStorageUsageLevel() async {
    if (kIsWeb) {
      return 0.0; // Unknown on web
    }

    try {
      final diskSpacePlus = DiskSpacePlus();
      final freeSpaceMB = await diskSpacePlus.getFreeDiskSpace ?? 0;
      final totalSpaceMB = await diskSpacePlus.getTotalDiskSpace ?? 0;

      if (totalSpaceMB <= 0) return 0.0;

      final usedSpaceMB = totalSpaceMB - freeSpaceMB;
      return usedSpaceMB / totalSpaceMB;
    } on Exception {
      return 0.0;
    }
  }

  /// Get formatted storage information
  Future<StorageInfo> getStorageInfo() async {
    if (kIsWeb) {
      return const StorageInfo(
        totalSpace: 'Unknown',
        freeSpace: 'Unknown',
        usedSpace: 'Unknown',
        usagePercentage: 0,
        isLowSpace: false,
      );
    }

    try {
      final diskSpacePlus = DiskSpacePlus();
      final freeSpaceMB = await diskSpacePlus.getFreeDiskSpace ?? 0;
      final totalSpaceMB = await diskSpacePlus.getTotalDiskSpace ?? 0;
      final usedSpaceMB = totalSpaceMB - freeSpaceMB;

      final usagePercentage = totalSpaceMB > 0
          ? usedSpaceMB / totalSpaceMB
          : 0.0;
      final isLowSpace =
          freeSpaceMB < _minimumFreeSpaceMB * 2; // Warning threshold

      return StorageInfo(
        totalSpace: _formatBytes((totalSpaceMB * _bytesPerMB).toInt()),
        freeSpace: _formatBytes((freeSpaceMB * _bytesPerMB).toInt()),
        usedSpace: _formatBytes((usedSpaceMB * _bytesPerMB).toInt()),
        usagePercentage: usagePercentage,
        isLowSpace: isLowSpace,
      );
    } on Exception {
      return const StorageInfo(
        totalSpace: 'Error',
        freeSpace: 'Error',
        usedSpace: 'Error',
        usagePercentage: 0,
        isLowSpace: false,
      );
    }
  }

  /// Format bytes into human readable format
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  /// Calculate how much space a download will require including buffer
  int calculateRequiredSpace(int downloadSizeInBytes) {
    return downloadSizeInBytes + (_minimumFreeSpaceMB * _bytesPerMB);
  }

  /// Check if we can fit multiple downloads
  Future<bool> canFitMultipleDownloads(List<int> downloadSizes) async {
    if (kIsWeb) return true;

    final totalDownloadSize = downloadSizes.fold(0, (sum, size) => sum + size);
    return hasEnoughSpace(totalDownloadSize);
  }

  /// Get recommendation for storage cleanup
  Future<StorageRecommendation> getStorageRecommendation() async {
    final storageInfo = await getStorageInfo();

    if (storageInfo.usagePercentage > 0.9) {
      return StorageRecommendation.critical;
    } else if (storageInfo.usagePercentage > 0.8) {
      return StorageRecommendation.warning;
    } else if (storageInfo.isLowSpace) {
      return StorageRecommendation.low;
    } else {
      return StorageRecommendation.ok;
    }
  }
}

/// Storage information data class
class StorageInfo {
  const StorageInfo({
    required this.totalSpace,
    required this.freeSpace,
    required this.usedSpace,
    required this.usagePercentage,
    required this.isLowSpace,
  });

  final String totalSpace;
  final String freeSpace;
  final String usedSpace;
  final double usagePercentage;
  final bool isLowSpace;

  String get usagePercentageFormatted =>
      '${(usagePercentage * 100).toStringAsFixed(1)}%';
}

/// Storage recommendation levels
enum StorageRecommendation {
  ok, // Storage is fine
  low, // Storage is getting low but manageable
  warning, // Storage is low, should clean up
  critical, // Storage is critically low, must clean up
}

extension StorageRecommendationExtension on StorageRecommendation {
  String get message {
    switch (this) {
      case StorageRecommendation.ok:
        return 'Storage space is sufficient';
      case StorageRecommendation.low:
        return 'Storage space is getting low';
      case StorageRecommendation.warning:
        return 'Storage space is low. Consider freeing up space';
      case StorageRecommendation.critical:
        return 'Storage space is critically low. Please free up space immediately';
    }
  }

  String get icon {
    switch (this) {
      case StorageRecommendation.ok:
        return '✅';
      case StorageRecommendation.low:
        return '⚠️';
      case StorageRecommendation.warning:
        return '🔶';
      case StorageRecommendation.critical:
        return '🔴';
    }
  }
}
