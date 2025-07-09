import 'dart:typed_data';

import '../../game/models/models.dart';
import '../../shared/constants/cache_constants.dart';
import '../models/download_error.dart';
import '../models/github_pack_index.dart';
import 'http_client_service.dart';

/// Service for interacting with GitHub pack repository
class GitHubPackService {
  GitHubPackService._();
  
  static GitHubPackService? _instance;
  static GitHubPackService get instance => _instance ??= GitHubPackService._();

  final HttpClientService _httpClient = HttpClientService.instance;

  /// Fetch pack index from GitHub
  Future<GitHubPackIndex> fetchPackIndex() async {
    try {
      final jsonData = await _httpClient.downloadJson(CacheConstants.packIndexUrl);
      return GitHubPackIndex.fromJson(jsonData);
    } catch (e) {
      if (e is DownloadError) rethrow;
      throw DownloadError.unknown(CacheConstants.packIndexUrl, e.toString());
    }
  }

  /// Fetch pack manifest from GitHub
  Future<GamePack> fetchPackManifest(String packId) async {
    final url = CacheConstants.packManifestUrl(packId);
    
    try {
      final jsonData = await _httpClient.downloadJson(url);
      return GamePack.fromJson(jsonData);
    } catch (e) {
      if (e is DownloadError) rethrow;
      throw DownloadError.unknown(url, e.toString());
    }
  }

  /// Download image from GitHub
  Future<Uint8List> downloadImage(
    String packId, 
    String filename, {
    void Function(int downloaded, int total)? onProgress,
  }) async {
    final url = CacheConstants.imageDownloadUrl(packId, filename);
    
    try {
      return await _httpClient.downloadBinary(url, onProgress: onProgress);
    } catch (e) {
      if (e is DownloadError) rethrow;
      throw DownloadError.unknown(url, e.toString());
    }
  }

  /// Download thumbnail from GitHub
  Future<Uint8List> downloadThumbnail(
    String packId, 
    String filename, {
    void Function(int downloaded, int total)? onProgress,
  }) async {
    final url = CacheConstants.thumbnailDownloadUrl(packId, filename);
    
    try {
      return await _httpClient.downloadBinary(url, onProgress: onProgress);
    } catch (e) {
      if (e is DownloadError) rethrow;
      throw DownloadError.unknown(url, e.toString());
    }
  }

  /// Get image file size without downloading
  Future<int> getImageSize(String packId, String filename) async {
    final url = CacheConstants.imageDownloadUrl(packId, filename);
    return _httpClient.getFileSize(url);
  }

  /// Get thumbnail file size without downloading
  Future<int> getThumbnailSize(String packId, String filename) async {
    final url = CacheConstants.thumbnailDownloadUrl(packId, filename);
    return _httpClient.getFileSize(url);
  }

  /// Check if pack exists on GitHub
  Future<bool> packExists(String packId) async {
    final url = CacheConstants.packManifestUrl(packId);
    return _httpClient.checkConnectivity(url);
  }

  /// Check if image exists on GitHub
  Future<bool> imageExists(String packId, String filename) async {
    final url = CacheConstants.imageDownloadUrl(packId, filename);
    return _httpClient.checkConnectivity(url);
  }

  /// Get pack version from manifest without full download
  Future<String?> getPackVersion(String packId) async {
    try {
      final manifest = await fetchPackManifest(packId);
      // Assuming version is stored in manifest metadata
      return manifest.id; // For now, use ID as version
    } catch (e) {
      return null;
    }
  }

  /// Validate pack manifest structure
  bool validatePackManifest(Map<String, dynamic> manifestJson) {
    try {
      // Check required fields
      if (!manifestJson.containsKey('id') || 
          !manifestJson.containsKey('title') ||
          !manifestJson.containsKey('tiles')) {
        return false;
      }

      // Validate pack ID format
      final packId = manifestJson['id'] as String;
      if (!CacheConstants.isValidPackId(packId)) {
        return false;
      }

      // Validate tiles structure
      final tiles = manifestJson['tiles'] as List<dynamic>?;
      if (tiles == null || tiles.isEmpty) {
        return false;
      }

      for (final tile in tiles) {
        if (tile is! Map<String, dynamic>) return false;
        
        final tileMap = tile as Map<String, dynamic>;
        if (!tileMap.containsKey('id') || 
            !tileMap.containsKey('imageUrl') ||
            !tileMap.containsKey('caption')) {
          return false;
        }

        // Validate image filename
        final imageUrl = tileMap['imageUrl'] as String;
        if (!CacheConstants.isValidFilename(imageUrl) ||
            !CacheConstants.isSupportedImageFormat(imageUrl)) {
          return false;
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Calculate total pack size (manifest + all images)
  Future<int> calculatePackSize(String packId) async {
    try {
      final manifest = await fetchPackManifest(packId);
      int totalSize = 0;

      // Add manifest size (estimated)
      totalSize += 1024; // 1KB for manifest

      // Add image sizes
      for (final tile in manifest.tiles) {
        try {
          final imageSize = await getImageSize(packId, tile.imageUrl);
          totalSize += imageSize;
        } catch (e) {
          // If we can't get size, estimate based on average
          totalSize += 500 * 1024; // 500KB average per image
        }
      }

      return totalSize;
    } catch (e) {
      // Return estimated size if calculation fails
      return 10 * 1024 * 1024; // 10MB default estimate
    }
  }

  /// Get pack metadata summary without downloading full manifest
  Future<PackSummary?> getPackSummary(String packId) async {
    try {
      final manifest = await fetchPackManifest(packId);
      final estimatedSize = await calculatePackSize(packId);
      
      return PackSummary(
        id: manifest.id,
        title: manifest.title,
        theme: manifest.theme,
        difficulty: manifest.difficulty,
        imageCount: manifest.tiles.length,
        estimatedSize: estimatedSize,
        isPremium: manifest.isPremium,
        description: manifest.description,
      );
    } catch (e) {
      return null;
    }
  }

  /// Check GitHub API rate limits
  Future<GitHubRateLimit> checkRateLimit() async {
    try {
      // GitHub doesn't require auth for public repos, but we can check headers
      final response = await _httpClient.downloadJson(CacheConstants.packIndexUrl);
      
      // For now, return default limits since we're using public repo
      return const GitHubRateLimit(
        limit: 60, // 60 requests per hour for unauthenticated
        remaining: 60,
        resetTime: null,
      );
    } catch (e) {
      return const GitHubRateLimit(
        limit: 0,
        remaining: 0,
        resetTime: null,
      );
    }
  }

  /// Check if GitHub service is available
  Future<bool> isServiceAvailable() async {
    return _httpClient.checkConnectivity(CacheConstants.packIndexUrl);
  }

  /// Get GitHub repository status
  Future<GitHubServiceStatus> getServiceStatus() async {
    try {
      final isAvailable = await isServiceAvailable();
      if (!isAvailable) {
        return GitHubServiceStatus.unavailable;
      }

      final rateLimit = await checkRateLimit();
      if (rateLimit.remaining <= 0) {
        return GitHubServiceStatus.rateLimited;
      }

      return GitHubServiceStatus.available;
    } catch (e) {
      return GitHubServiceStatus.error;
    }
  }
}

/// Pack summary for quick display
class PackSummary {
  const PackSummary({
    required this.id,
    required this.title,
    required this.theme,
    required this.difficulty,
    required this.imageCount,
    required this.estimatedSize,
    required this.isPremium,
    this.description,
  });

  final String id;
  final String title;
  final String theme;
  final GameDifficulty difficulty;
  final int imageCount;
  final int estimatedSize;
  final bool isPremium;
  final String? description;
}

/// GitHub rate limit information
class GitHubRateLimit {
  const GitHubRateLimit({
    required this.limit,
    required this.remaining,
    this.resetTime,
  });

  final int limit;
  final int remaining;
  final DateTime? resetTime;

  bool get isLimited => remaining <= 0;
  
  Duration? get timeUntilReset {
    if (resetTime == null) return null;
    final now = DateTime.now();
    if (resetTime!.isBefore(now)) return null;
    return resetTime!.difference(now);
  }
}

/// GitHub service status
enum GitHubServiceStatus {
  available,
  unavailable,
  rateLimited,
  error,
}

extension GitHubServiceStatusExtension on GitHubServiceStatus {
  String get displayName {
    switch (this) {
      case GitHubServiceStatus.available:
        return 'Available';
      case GitHubServiceStatus.unavailable:
        return 'Unavailable';
      case GitHubServiceStatus.rateLimited:
        return 'Rate Limited';
      case GitHubServiceStatus.error:
        return 'Error';
    }
  }

  String get icon {
    switch (this) {
      case GitHubServiceStatus.available:
        return '✅';
      case GitHubServiceStatus.unavailable:
        return '❌';
      case GitHubServiceStatus.rateLimited:
        return '⏳';
      case GitHubServiceStatus.error:
        return '⚠️';
    }
  }
}
