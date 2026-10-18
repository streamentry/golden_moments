/// Cache system constants and configuration
class CacheConstants {
  new _();

  // Cache duration and expiry
  static const Duration cacheExpiryDuration = Duration(days: 60);
  static const Duration cleanupInterval = Duration(hours: 24);
  static const Duration downloadTimeout = Duration(minutes: 5);

  // Cache size limits
  static const int defaultMaxCacheSizeMB = 500;
  static const int maxCacheSizeBytes = defaultMaxCacheSizeMB * 1024 * 1024;
  static const int warningThresholdBytes = 419430400; // 80% of 500MB

  // Download configuration
  static const int maxConcurrentDownloads = 3;
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  static const Duration exponentialBackoffBase = Duration(seconds: 1);

  // GitHub repository configuration
  static const String githubBaseUrl =
      'https://raw.githubusercontent.com/user/golden-moments-packs/main/';
  static const String packIndexUrl = '${githubBaseUrl}index.json';

  // Pack manifest URL pattern
  static String packManifestUrl(String packId) =>
      '${githubBaseUrl}packs/$packId/manifest.json';

  // Image download URL pattern
  static String imageDownloadUrl(String packId, String filename) =>
      '${githubBaseUrl}packs/$packId/images/$filename';

  // Thumbnail download URL pattern
  static String thumbnailDownloadUrl(String packId, String filename) =>
      '${githubBaseUrl}packs/$packId/thumbnails/$filename';

  // File validation
  static const List<String> supportedImageFormats = [
    'jpg',
    'jpeg',
    'png',
    'webp',
  ];
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5MB per image
  static const int maxPackSizeBytes = 50 * 1024 * 1024; // 50MB per pack

  // Network configuration
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Map<String, String> defaultHeaders = {
    'User-Agent': 'GoldenMoments/1.0.0',
    'Accept': 'application/json, image/*',
  };

  // Cache file names
  static const String cacheIndexFileName = 'cache_index.json';
  static const String cacheStatsFileName = 'cache_stats.json';
  static const String downloadQueueFileName = 'download_queue.json';

  // Directory names
  static const String packsDirectoryName = 'packs';
  static const String imagesDirectoryName = 'images';
  static const String thumbnailsDirectoryName = 'thumbnails';

  // File extensions
  static const String jsonExtension = '.json';
  static const String backupExtension = '.backup';
  static const String tempExtension = '.tmp';

  // Validation patterns
  static final RegExp packIdPattern = RegExp(r'^[a-z0-9_]+$');
  static final RegExp imageIdPattern = RegExp(r'^[a-z0-9_]+$');
  static final RegExp filenamePattern = RegExp(r'^[a-zA-Z0-9_.-]+$');

  // Error messages
  static const String networkErrorMessage =
      'Unable to connect to the internet. Please check your connection.';
  static const String storageErrorMessage =
      'Not enough storage space available. Please free up some space.';
  static const String corruptionErrorMessage =
      'Cache data is corrupted. It will be automatically repaired.';
  static const String downloadFailedMessage =
      'Download failed. It will be retried automatically.';

  // Success messages
  static const String downloadCompleteMessage =
      'Pack downloaded successfully and ready to play!';
  static const String cacheCleanedMessage = 'Cache cleaned up successfully.';

  // Settings keys for shared preferences
  static const String maxCacheSizeKey = 'max_cache_size_mb';
  static const String wifiOnlyDownloadsKey = 'wifi_only_downloads';
  static const String autoCleanupKey = 'auto_cleanup_enabled';
  static const String lastCleanupKey = 'last_cleanup_timestamp';

  // Performance thresholds
  static const int maxJsonFileSizeBytes = 1024 * 1024; // 1MB for JSON files
  static const int batchProcessingSize = 10; // Process items in batches
  static const Duration uiUpdateInterval = Duration(milliseconds: 500);

  // Checksum validation
  static const String checksumAlgorithm = 'SHA-256';
  static const int checksumLength = 64; // SHA-256 hex string length

  // Image processing
  static const int thumbnailMaxWidth = 200;
  static const int thumbnailMaxHeight = 200;
  static const int imageQuality = 85; // JPEG quality (0-100)

  // Bundled content
  static const List<String> bundledPackIds = [
    'pack_classic_cars_1950s',
    'pack_vintage_toys_1960s',
    'pack_old_movies_1940s',
  ];

  // Analytics and statistics
  static const Duration statisticsUpdateInterval = Duration(hours: 1);
  static const int maxStatisticsHistory = 30; // Keep 30 days of history

  // Development and debugging
  static const bool enableDebugLogging = true;
  static const bool enableCacheValidation = true;
  static const bool enablePerformanceMonitoring = true;

  // Helper methods
  static bool isValidPackId(String packId) => packIdPattern.hasMatch(packId);
  static bool isValidImageId(String imageId) =>
      imageIdPattern.hasMatch(imageId);
  static bool isValidFilename(String filename) =>
      filenamePattern.hasMatch(filename);

  static bool isSupportedImageFormat(String filename) {
    final extension = filename.split('.').last.toLowerCase();
    return supportedImageFormats.contains(extension);
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  static Duration getRetryDelay(int attemptNumber) {
    // Exponential backoff: 1s, 2s, 4s, 8s, etc.
    final delaySeconds =
        exponentialBackoffBase.inSeconds * (1 << attemptNumber);
    return Duration(seconds: delaySeconds.clamp(1, 60)); // Max 60 seconds
  }
}
