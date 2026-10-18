/// Common interface for JSON storage backends used by the cache layer.
abstract class JsonStore {
  Future<T?> loadJsonFile<T>(
    String relativePath,
    T Function(Map<String, dynamic>) fromJson,
  );

  Future<void> saveJsonFile<T>(
    String relativePath,
    T data,
    Map<String, dynamic> Function(T) toJson,
  );

  Future<bool> fileExists(String relativePath);
  Future<void> deleteFile(String relativePath);
  Future<void> createDirectory(String relativePath);
  Future<List<String>> listFiles(String relativePath);
  Future<int> getFileSize(String relativePath);
  Future<int> getDirectorySize(String relativePath);
  Future<void> cleanupTempFiles();
  Future<bool> validateJsonFile(String relativePath);
  Future<void> initializeCacheStructure();
  String getCachePath(String relativePath);
}
