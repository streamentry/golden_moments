import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:golden_moments/data/models/download_error.dart';
import 'package:golden_moments/data/models/download_progress.dart';
import 'package:golden_moments/data/models/download_queue.dart';
import 'package:golden_moments/data/services/http_client_service.dart';
import 'package:golden_moments/data/services/json_cache_service.dart';
import 'package:golden_moments/data/storage/cache_file_paths.dart';

/// Handles individual image download operations
class ImageDownloader {
  ImageDownloader({
    HttpClientService? httpClient,
    JsonCacheService? cacheService,
  }) : _httpClient = httpClient ?? HttpClientService(),
       _cacheService = cacheService ?? JsonCacheService();

  final HttpClientService _httpClient;
  final JsonCacheService _cacheService;

  /// Download a single image with progress tracking
  Future<void> downloadImage({
    required DownloadItem item,
    required Function(DownloadProgress) onProgress,
  }) async {
    final downloadId = item.id;
    final packId = item.packId;
    final imageId = item.imageId;
    final imageUrl = item.imageUrl;

    // Extract filename from URL for local storage
    final filename = '$imageId.jpg'; // Use consistent filename

    // Download with progress tracking
    final startTime = DateTime.now();

    // Emit initial progress
    final initialProgress = DownloadProgress.started(
      downloadId: downloadId,
      packId: packId,
      imageId: imageId,
      totalBytes: 0, // Will be updated during download
    );

    onProgress(initialProgress);

    try {
      // Download image data using HTTP client
      final imageData = await _httpClient.downloadBinary(
        imageUrl,
        onProgress: (int downloaded, int total) {
          // Calculate speed and ETA
          final elapsed = DateTime.now().difference(startTime);
          final speed = _httpClient.calculateDownloadSpeed(downloaded, elapsed);
          final eta = _httpClient.calculateETA(total - downloaded, speed);

          // Emit progress update with updated total bytes
          final progress = DownloadProgress.started(
            downloadId: downloadId,
            packId: packId,
            imageId: imageId,
            totalBytes: total,
          ).updateProgress(
            bytesDownloaded: downloaded,
            speed: speed,
            eta: eta,
          );
          
          onProgress(progress);
        },
      );

      // Save image to cache (skip on web for now)
      await _saveImageToCache(
        packId: packId,
        filename: filename,
        imageData: imageData,
      );

      // Emit completion progress
      onProgress(initialProgress.complete());
    } on Exception catch (e) {
      // Create and emit error progress
      final downloadError = _createDownloadError(e, imageUrl);
      
      final errorProgress = DownloadProgress.failed(
        downloadId: downloadId,
        packId: packId,
        imageId: imageId,
        bytesDownloaded: 0,
        totalBytes: 0,
        startTime: startTime,
        error: downloadError,
      );
      
      onProgress(errorProgress);
      rethrow;
    }
  }

  /// Save image data to cache
  Future<void> _saveImageToCache({
    required String packId,
    required String filename,
    required List<int> imageData,
  }) async {
    // Skip file saving on web platform
    if (kIsWeb) {
      debugPrint('File saving skipped on web platform');
      return;
    }

    try {
      final imagePath = CacheFilePaths.imageFile(packId, filename);
      final fullPath = _cacheService.fileManager.getCachePath(imagePath);
      final imageFile = File(fullPath);

      // Ensure directory exists
      await imageFile.parent.create(recursive: true);

      // Write image data
      await imageFile.writeAsBytes(imageData);
    } on Exception catch (e) {
      debugPrint('Could not save image file: $e');
      // Don't rethrow as this is not critical for web platform
    }
  }

  /// Create appropriate download error from exception
  DownloadError _createDownloadError(Exception error, String url) {
    if (error is DownloadError) {
      return error;
    }

    // Handle common HTTP errors
    final errorMessage = error.toString();
    
    if (errorMessage.contains('TimeoutException') ||
        errorMessage.contains('timeout')) {
      return DownloadError.timeout(url, errorMessage);
    }
    
    if (errorMessage.contains('SocketException') ||
        errorMessage.contains('NetworkException')) {
      return DownloadError.networkError(url, errorMessage);
    }
    
    if (errorMessage.contains('404')) {
      return DownloadError.httpError(url, 404, errorMessage);
    }
    
    if (errorMessage.contains('500')) {
      return DownloadError.httpError(url, 500, errorMessage);
    }

    // Default to unknown error
    return DownloadError.unknown(url, errorMessage);
  }

  /// Validate image data integrity
  bool validateImageData(List<int> imageData) {
    if (imageData.isEmpty) return false;
    
    // Basic validation - check for common image file headers
    if (imageData.length < 4) return false;
    
    // Check for JPEG header (0xFF, 0xD8)
    if (imageData[0] == 0xFF && imageData[1] == 0xD8) return true;
    
    // Check for PNG header (0x89, 0x50, 0x4E, 0x47)
    if (imageData.length >= 8 &&
        imageData[0] == 0x89 &&
        imageData[1] == 0x50 &&
        imageData[2] == 0x4E &&
        imageData[3] == 0x47) {
      return true;
    }
    
    // Check for GIF header (0x47, 0x49, 0x46)
    if (imageData[0] == 0x47 &&
        imageData[1] == 0x49 &&
        imageData[2] == 0x46) {
      return true;
    }
    
    // Check for WebP header (RIFF....WEBP)
    if (imageData.length >= 12 &&
        imageData[0] == 0x52 && // R
        imageData[1] == 0x49 && // I
        imageData[2] == 0x46 && // F
        imageData[3] == 0x46 && // F
        imageData[8] == 0x57 && // W
        imageData[9] == 0x45 && // E
        imageData[10] == 0x42 && // B
        imageData[11] == 0x50) {
      return true; // P
    }
    
    return false;
  }

  /// Get estimated download time for an image
  Duration estimateDownloadTime({
    required int imageSizeBytes,
    required double networkSpeedBytesPerSecond,
  }) {
    if (networkSpeedBytesPerSecond <= 0) {
      return const Duration(seconds: 30); // Default estimate
    }
    
    final estimatedSeconds = (imageSizeBytes / networkSpeedBytesPerSecond).ceil();
    return Duration(seconds: estimatedSeconds);
  }

  /// Check if image exists in cache
  Future<bool> isImageCached(String packId, String imageId) async {
    if (kIsWeb) return false; // No file caching on web
    
    try {
      final filename = '$imageId.jpg';
      final imagePath = CacheFilePaths.imageFile(packId, filename);
      final fullPath = _cacheService.fileManager.getCachePath(imagePath);
      final imageFile = File(fullPath);
      
      return imageFile.existsSync();
    } on Exception {
      return false;
    }
  }

  /// Get cached image file path
  String? getCachedImagePath(String packId, String imageId) {
    if (kIsWeb) return null; // No file paths on web
    
    try {
      final filename = '$imageId.jpg';
      final imagePath = CacheFilePaths.imageFile(packId, filename);
      return _cacheService.fileManager.getCachePath(imagePath);
    } on Exception {
      return null;
    }
  }

  /// Delete cached image
  Future<bool> deleteCachedImage(String packId, String imageId) async {
    if (kIsWeb) return true; // Nothing to delete on web
    
    try {
      final imagePath = getCachedImagePath(packId, imageId);
      if (imagePath == null) return false;
      
      final imageFile = File(imagePath);
      if (imageFile.existsSync()) {
        await imageFile.delete();
        return true;
      }
      return false;
    } on Exception {
      return false;
    }
  }

  /// Get cached image size in bytes
  Future<int> getCachedImageSize(String packId, String imageId) async {
    if (kIsWeb) return 0; // Unknown on web
    
    try {
      final imagePath = getCachedImagePath(packId, imageId);
      if (imagePath == null) return 0;
      
      final imageFile = File(imagePath);
      if (imageFile.existsSync()) {
        return imageFile.lengthSync();
      }
      return 0;
    } on Exception {
      return 0;
    }
  }
}
