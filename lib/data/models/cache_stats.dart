import 'package:equatable/equatable.dart';

/// Cache statistics and settings
class CacheStats extends Equatable {
  const CacheStats({
    required this.totalCacheSize,
    required this.maxCacheSize,
    required this.totalPacks,
    required this.totalImages,
    required this.lastCleanup,
    required this.settings,
    required this.statistics,
  });

  final int totalCacheSize;
  final int maxCacheSize;
  final int totalPacks;
  final int totalImages;
  final DateTime lastCleanup;
  final CacheSettings settings;
  final CacheStatistics statistics;

  factory CacheStats.defaultStats() {
    return CacheStats(
      totalCacheSize: 0,
      maxCacheSize: 500 * 1024 * 1024, // 500MB
      totalPacks: 0,
      totalImages: 0,
      lastCleanup: DateTime.now(),
      settings: CacheSettings.defaultSettings(),
      statistics: CacheStatistics.empty(),
    );
  }

  factory CacheStats.fromJson(Map<String, dynamic> json) {
    return CacheStats(
      totalCacheSize: json['totalCacheSize'] as int? ?? 0,
      maxCacheSize: json['maxCacheSize'] as int? ?? 500 * 1024 * 1024,
      totalPacks: json['totalPacks'] as int? ?? 0,
      totalImages: json['totalImages'] as int? ?? 0,
      lastCleanup: DateTime.parse(
        json['lastCleanup'] as String? ?? DateTime.now().toIso8601String(),
      ),
      settings: CacheSettings.fromJson(
        json['settings'] as Map<String, dynamic>? ?? {},
      ),
      statistics: CacheStatistics.fromJson(
        json['statistics'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalCacheSize': totalCacheSize,
      'maxCacheSize': maxCacheSize,
      'totalPacks': totalPacks,
      'totalImages': totalImages,
      'lastCleanup': lastCleanup.toIso8601String(),
      'settings': settings.toJson(),
      'statistics': statistics.toJson(),
    };
  }

  CacheStats copyWith({
    int? totalCacheSize,
    int? maxCacheSize,
    int? totalPacks,
    int? totalImages,
    DateTime? lastCleanup,
    CacheSettings? settings,
    CacheStatistics? statistics,
  }) {
    return CacheStats(
      totalCacheSize: totalCacheSize ?? this.totalCacheSize,
      maxCacheSize: maxCacheSize ?? this.maxCacheSize,
      totalPacks: totalPacks ?? this.totalPacks,
      totalImages: totalImages ?? this.totalImages,
      lastCleanup: lastCleanup ?? this.lastCleanup,
      settings: settings ?? this.settings,
      statistics: statistics ?? this.statistics,
    );
  }

  /// Get cache usage percentage (0.0 to 1.0)
  double get cacheUsagePercentage {
    if (maxCacheSize == 0) return 0.0;
    return totalCacheSize / maxCacheSize;
  }

  /// Check if cache is near full (>80%)
  bool get isNearFull => cacheUsagePercentage > 0.8;

  /// Get available cache space in bytes
  int get availableSpace => maxCacheSize - totalCacheSize;

  @override
  List<Object?> get props => [
        totalCacheSize,
        maxCacheSize,
        totalPacks,
        totalImages,
        lastCleanup,
        settings,
        statistics,
      ];
}

/// Cache settings configuration
class CacheSettings extends Equatable {
  const CacheSettings({
    required this.maxCacheSizeMB,
    required this.cacheExpiryDays,
    required this.autoCleanup,
    required this.wifiOnlyDownloads,
    required this.maxConcurrentDownloads,
    required this.downloadRetryAttempts,
  });

  final int maxCacheSizeMB;
  final int cacheExpiryDays;
  final bool autoCleanup;
  final bool wifiOnlyDownloads;
  final int maxConcurrentDownloads;
  final int downloadRetryAttempts;

  factory CacheSettings.defaultSettings() {
    return const CacheSettings(
      maxCacheSizeMB: 500,
      cacheExpiryDays: 60,
      autoCleanup: true,
      wifiOnlyDownloads: true,
      maxConcurrentDownloads: 3,
      downloadRetryAttempts: 3,
    );
  }

  factory CacheSettings.fromJson(Map<String, dynamic> json) {
    return CacheSettings(
      maxCacheSizeMB: json['maxCacheSizeMB'] as int? ?? 500,
      cacheExpiryDays: json['cacheExpiryDays'] as int? ?? 60,
      autoCleanup: json['autoCleanup'] as bool? ?? true,
      wifiOnlyDownloads: json['wifiOnlyDownloads'] as bool? ?? true,
      maxConcurrentDownloads: json['maxConcurrentDownloads'] as int? ?? 3,
      downloadRetryAttempts: json['downloadRetryAttempts'] as int? ?? 3,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maxCacheSizeMB': maxCacheSizeMB,
      'cacheExpiryDays': cacheExpiryDays,
      'autoCleanup': autoCleanup,
      'wifiOnlyDownloads': wifiOnlyDownloads,
      'maxConcurrentDownloads': maxConcurrentDownloads,
      'downloadRetryAttempts': downloadRetryAttempts,
    };
  }

  CacheSettings copyWith({
    int? maxCacheSizeMB,
    int? cacheExpiryDays,
    bool? autoCleanup,
    bool? wifiOnlyDownloads,
    int? maxConcurrentDownloads,
    int? downloadRetryAttempts,
  }) {
    return CacheSettings(
      maxCacheSizeMB: maxCacheSizeMB ?? this.maxCacheSizeMB,
      cacheExpiryDays: cacheExpiryDays ?? this.cacheExpiryDays,
      autoCleanup: autoCleanup ?? this.autoCleanup,
      wifiOnlyDownloads: wifiOnlyDownloads ?? this.wifiOnlyDownloads,
      maxConcurrentDownloads: 
          maxConcurrentDownloads ?? this.maxConcurrentDownloads,
      downloadRetryAttempts: 
          downloadRetryAttempts ?? this.downloadRetryAttempts,
    );
  }

  /// Get max cache size in bytes
  int get maxCacheSizeBytes => maxCacheSizeMB * 1024 * 1024;

  /// Get cache expiry duration
  Duration get cacheExpiryDuration => Duration(days: cacheExpiryDays);

  @override
  List<Object?> get props => [
        maxCacheSizeMB,
        cacheExpiryDays,
        autoCleanup,
        wifiOnlyDownloads,
        maxConcurrentDownloads,
        downloadRetryAttempts,
      ];
}

/// Cache usage statistics
class CacheStatistics extends Equatable {
  const CacheStatistics({
    required this.totalDownloads,
    required this.failedDownloads,
    required this.cacheHitRate,
    required this.averageDownloadTime,
    required this.totalBandwidthSaved,
    required this.lastUpdated,
  });

  final int totalDownloads;
  final int failedDownloads;
  final double cacheHitRate;
  final double averageDownloadTime;
  final int totalBandwidthSaved;
  final DateTime lastUpdated;

  factory CacheStatistics.empty() {
    return CacheStatistics(
      totalDownloads: 0,
      failedDownloads: 0,
      cacheHitRate: 0.0,
      averageDownloadTime: 0.0,
      totalBandwidthSaved: 0,
      lastUpdated: DateTime.now(),
    );
  }

  factory CacheStatistics.fromJson(Map<String, dynamic> json) {
    return CacheStatistics(
      totalDownloads: json['totalDownloads'] as int? ?? 0,
      failedDownloads: json['failedDownloads'] as int? ?? 0,
      cacheHitRate: (json['cacheHitRate'] as num?)?.toDouble() ?? 0.0,
      averageDownloadTime: 
          (json['averageDownloadTime'] as num?)?.toDouble() ?? 0.0,
      totalBandwidthSaved: json['totalBandwidthSaved'] as int? ?? 0,
      lastUpdated: DateTime.parse(
        json['lastUpdated'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalDownloads': totalDownloads,
      'failedDownloads': failedDownloads,
      'cacheHitRate': cacheHitRate,
      'averageDownloadTime': averageDownloadTime,
      'totalBandwidthSaved': totalBandwidthSaved,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  CacheStatistics copyWith({
    int? totalDownloads,
    int? failedDownloads,
    double? cacheHitRate,
    double? averageDownloadTime,
    int? totalBandwidthSaved,
    DateTime? lastUpdated,
  }) {
    return CacheStatistics(
      totalDownloads: totalDownloads ?? this.totalDownloads,
      failedDownloads: failedDownloads ?? this.failedDownloads,
      cacheHitRate: cacheHitRate ?? this.cacheHitRate,
      averageDownloadTime: averageDownloadTime ?? this.averageDownloadTime,
      totalBandwidthSaved: totalBandwidthSaved ?? this.totalBandwidthSaved,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Get success rate (0.0 to 1.0)
  double get successRate {
    if (totalDownloads == 0) return 1.0;
    return (totalDownloads - failedDownloads) / totalDownloads;
  }

  @override
  List<Object?> get props => [
        totalDownloads,
        failedDownloads,
        cacheHitRate,
        averageDownloadTime,
        totalBandwidthSaved,
        lastUpdated,
      ];
}
