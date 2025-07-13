// import 'dart:async';

// import 'package:golden_moments/data/models/packs_index.dart';
// import 'package:golden_moments/data/services/local_pack_service.dart';
// import 'package:golden_moments/data/services/long_term_image_cache.dart';
// import 'package:golden_moments/game/models/models.dart';

// /// Service for loading game packs with local JSON and cached images
// class GamePackLoader {
//   GamePackLoader._();

//   static GamePackLoader? _instance;
//   static GamePackLoader get instance => _instance ??= GamePackLoader._();

//   final LocalPackService _packService = LocalPackService.instance;
//   final LongTermImageCache _imageCache = LongTermImageCache.instance;

//   /// Load a game pack with local JSON and cached images
//   Future<GamePackLoadResult> loadGamePack(String packId) async {
//     try {
//       // 1. Load pack metadata from local JSON
//       final packInfo = await _packService.getPackById(packId);
//       if (packInfo == null) {
//         return GamePackLoadResult.failure(
//           'Pack not found: $packId',
//           GamePackLoadSource.none,
//         );
//       }

//       // 2. Convert to GamePack
//       final gamePack = _packService.convertToGamePack(packInfo);

//       // 3. Preload images into cache (non-blocking)
//       _preloadPackImages(packInfo);

//       return GamePackLoadResult.success(
//         gamePack,
//         GamePackLoadSource.bundled, // Use bundled as it's local
//         metadata: GamePackMetadata(
//           cacheHit: true,
//           loadTime: DateTime.now(),
//           imageCount: packInfo.imageCount,
//           totalSize: packInfo.estimatedSize,
//         ),
//       );
//     } catch (e) {
//       return GamePackLoadResult.failure(
//         'Failed to load pack: $e',
//         GamePackLoadSource.none,
//       );
//     }
//   }

//   /// Get available packs from local JSON
//   Future<List<Pack>> getAvailablePacks() async {
//     try {
//       final packInfos = await _packService.getPacks();
//       return packInfos
//           .map((packInfo) => _packService.convertToGamePack(packInfo))
//           .toList();
//     } catch (e) {
//       return [];
//     }
//   }

//   /// Preload pack images for better performance
//   Future<void> preloadPackImages(Pack pack) async {
//     try {
//       final imageUrls = pack.tiles.map((tile) => tile.imageUrl).toList();
//       await _imageCache.preloadPackImages(imageUrls);
//     } catch (e) {
//       // Handle preload error gracefully
//     }
//   }

//   /// Clear expired cache entries
//   Future<void> cleanupExpiredCache() async {
//     try {
//       await _imageCache.cleanExpiredCache();
//     } catch (e) {
//       // Handle cleanup error gracefully
//     }
//   }
// }

// /// Result of game pack loading operation
// class GamePackLoadResult {
//   const GamePackLoadResult._({
//     required this.isSuccess,
//     this.gamePack,
//     this.error,
//     required this.source,
//     this.metadata,
//   });

//   final bool isSuccess;
//   final Pack? gamePack;
//   final String? error;
//   final GamePackLoadSource source;
//   final GamePackMetadata? metadata;

//   /// Create successful result
//   factory GamePackLoadResult.success(
//     Pack gamePack,
//     GamePackLoadSource source, {
//     GamePackMetadata? metadata,
//   }) {
//     return GamePackLoadResult._(
//       isSuccess: true,
//       gamePack: gamePack,
//       source: source,
//       metadata: metadata,
//     );
//   }

//   /// Create failure result
//   factory GamePackLoadResult.failure(
//     String error,
//     GamePackLoadSource source,
//   ) {
//     return GamePackLoadResult._(
//       isSuccess: false,
//       error: error,
//       source: source,
//     );
//   }

//   /// Check if result is from cache
//   bool get isFromCache => source == GamePackLoadSource.cache;

//   /// Check if result requires download
//   bool get requiresDownload => metadata?.requiresDownload ?? false;

//   /// Check if result is from bundled assets
//   bool get isFromBundled => source == GamePackLoadSource.bundled;
// }

// /// Source of game pack loading
// enum GamePackLoadSource {
//   cache,
//   download,
//   bundled,
//   none,
// }

// /// Metadata about pack loading
// class GamePackMetadata {
//   const GamePackMetadata({
//     required this.cacheHit,
//     required this.loadTime,
//     this.imageCount = 0,
//     this.totalSize = 0,
//     this.requiresDownload = false,
//     this.isBundled = false,
//   });

//   final bool cacheHit;
//   final DateTime loadTime;
//   final int imageCount;
//   final int totalSize;
//   final bool requiresDownload;
//   final bool isBundled;

//   /// Get formatted load time
//   String get formattedLoadTime {
//     final now = DateTime.now();
//     final difference = now.difference(loadTime);
//     return '${difference.inMilliseconds}ms';
//   }

//   /// Get formatted size
//   String get formattedSize {
//     if (totalSize < 1024) return '$totalSize B';
//     if (totalSize < 1024 * 1024) {
//       return '${(totalSize / 1024).toStringAsFixed(1)} KB';
//     }
//     return '${(totalSize / (1024 * 1024)).toStringAsFixed(1)} MB';
//   }
// }
