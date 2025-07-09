/// Cache file paths and directory structure constants
class CacheFilePaths {
  CacheFilePaths._();

  // Main cache files
  static const String cacheIndex = 'cache_index.json';
  static const String cacheStats = 'cache_stats.json';
  static const String downloadQueue = 'download_queue.json';

  // Directories
  static const String packsDirectory = 'packs';
  static const String imagesDirectory = 'images';
  static const String thumbnailsDirectory = 'thumbnails';

  // Pack-specific paths
  static String packCacheFile(String packId) => 'packs/$packId.json';
  static String packImagesDirectory(String packId) => 'images/$packId';
  static String packThumbnailsDirectory(String packId) => 
      'images/$packId/$thumbnailsDirectory';

  // Image file paths
  static String imageFile(String packId, String filename) => 
      'images/$packId/$filename';
  static String thumbnailFile(String packId, String filename) => 
      'images/$packId/$thumbnailsDirectory/$filename';

  // Backup file paths
  static String backupFile(String originalPath) => '$originalPath.backup';
  static String tempFile(String originalPath) => '$originalPath.tmp';

  // Validation helpers
  static bool isPackCacheFile(String path) => 
      path.startsWith(packsDirectory) && path.endsWith('.json');
  
  static bool isImageFile(String path) => 
      path.startsWith(imagesDirectory) && !path.contains(thumbnailsDirectory);
  
  static bool isThumbnailFile(String path) => 
      path.startsWith(imagesDirectory) && path.contains(thumbnailsDirectory);

  // Extract pack ID from file paths
  static String? extractPackIdFromPath(String path) {
    if (path.startsWith('packs/') && path.endsWith('.json')) {
      final filename = path.substring(6); // Remove 'packs/'
      return filename.substring(0, filename.length - 5); // Remove '.json'
    }
    
    if (path.startsWith('images/')) {
      final parts = path.split('/');
      if (parts.length >= 2) {
        return parts[1]; // Second part is pack ID
      }
    }
    
    return null;
  }

  // Get all cache file patterns for cleanup
  static List<String> getAllCachePatterns() {
    return [
      cacheIndex,
      cacheStats,
      downloadQueue,
      '$packsDirectory/*.json',
      '$imagesDirectory/*',
    ];
  }
}
