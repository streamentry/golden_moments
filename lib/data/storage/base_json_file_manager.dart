/// Abstract base class for JSON file management operations
///
/// Defines the contract that both platform-specific and web-compatible
/// file managers must implement to ensure consistent API across platforms.
abstract class BaseJsonFileManager {
  /// The cache directory path used by this file manager
  String get cacheDirectory;

  /// Load JSON file with type safety and error handling
  ///
  /// Returns null if file doesn't exist or cannot be parsed.
  /// Uses [fromJson] to convert the parsed JSON map to type [T].
  Future<T?> loadJsonFile<T>(
    String relativePath,
    T Function(Map<String, dynamic>) fromJson,
  );

  /// Save JSON file with platform-specific backup and safety mechanisms
  ///
  /// Uses [toJson] to convert the data to a JSON map before saving.
  /// Implementations should handle atomic writes and backup creation as appropriate.
  Future<void> saveJsonFile<T>(
    String relativePath,
    T data,
    Map<String, dynamic> Function(T) toJson,
  );

  /// Check if file exists at the given relative path
  Future<bool> fileExists(String relativePath);

  /// Delete file safely with cleanup of associated backup files
  Future<void> deleteFile(String relativePath);

  /// Create directory at the given relative path
  ///
  /// Should create parent directories recursively as needed.
  /// May be a no-op on platforms that don't support directory structure.
  Future<void> createDirectory(String relativePath);

  /// List files in directory at the given relative path
  ///
  /// Returns empty list if directory doesn't exist or on error.
  /// Should return only direct children, not recursive listing.
  Future<List<String>> listFiles(String relativePath);

  /// Get file size in bytes
  ///
  /// Returns 0 if file doesn't exist or on error.
  /// On web platforms, this may return an approximation.
  Future<int> getFileSize(String relativePath);

  /// Get directory size in bytes (recursive)
  ///
  /// Returns 0 if directory doesn't exist or on error.
  /// On web platforms, this may return an approximation.
  Future<int> getDirectorySize(String relativePath);

  /// Clean up temporary files from previous operations
  ///
  /// May be a no-op on platforms that don't create temporary files.
  Future<void> cleanupTempFiles();

  /// Validate JSON file integrity
  ///
  /// Returns true if file exists and contains valid JSON.
  Future<bool> validateJsonFile(String relativePath);

  /// Initialize cache directory structure
  ///
  /// Sets up the basic directory structure needed for caching.
  /// Should create necessary subdirectories and perform initial cleanup.
  Future<void> initializeCacheStructure();

  /// Get full cache path for a relative path
  ///
  /// Returns the absolute or platform-appropriate path for the given relative path.
  String getCachePath(String relativePath);
}
