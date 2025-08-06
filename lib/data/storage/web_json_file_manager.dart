import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'base_json_file_manager.dart';

/// Web-compatible JSON file manager using SharedPreferences for storage
class WebJsonFileManager extends BaseJsonFileManager {
  WebJsonFileManager({required this.cacheDirectory});

  @override
  final String cacheDirectory;

  /// Load JSON file with type safety and error handling
  @override
  Future<T?> loadJsonFile<T>(
    String relativePath,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getStorageKey(relativePath);
      final content = prefs.getString(key);

      if (content == null || content.trim().isEmpty) {
        return null;
      }

      final jsonData = jsonDecode(content) as Map<String, dynamic>;
      return fromJson(jsonData);
    } on Exception catch (e) {
      // Log error and return null
      print('Error loading JSON file $relativePath: $e');
      return null;
    }
  }

  /// Save JSON file with backup
  @override
  Future<void> saveJsonFile<T>(
    String relativePath,
    T data,
    Map<String, dynamic> Function(T) toJson,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getStorageKey(relativePath);

      final jsonData = toJson(data);
      final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);

      await prefs.setString(key, jsonString);
    } catch (e) {
      print('Error saving JSON file $relativePath: $e');
      rethrow;
    }
  }

  /// Check if file exists
  @override
  Future<bool> fileExists(String relativePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getStorageKey(relativePath);
      return prefs.containsKey(key);
    } catch (e) {
      return false;
    }
  }

  /// Delete file safely
  @override
  Future<void> deleteFile(String relativePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getStorageKey(relativePath);
      await prefs.remove(key);
    } on Exception catch (e) {
      print('Error deleting file $relativePath: $e');
    }
  }

  /// Create directory (no-op on web)
  @override
  Future<void> createDirectory(String relativePath) async {
    // No-op on web - SharedPreferences doesn't need directory structure
  }

  /// List files in directory
  @override
  Future<List<String>> listFiles(String relativePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final prefix = _getStorageKey(relativePath);

      final keys = prefs
          .getKeys()
          .where((key) => key.startsWith('$prefix/'))
          .map((key) => key.substring(prefix.length + 1))
          .where((name) => !name.contains('/')) // Only direct children
          .toList();

      return keys;
    } on Exception catch (e) {
      print('Error listing files in $relativePath: $e');
      return [];
    }
  }

  /// Get file size in bytes (approximation on web)
  @override
  Future<int> getFileSize(String relativePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getStorageKey(relativePath);
      final content = prefs.getString(key);

      return content?.length ?? 0;
    } on Exception catch (e) {
      print('Error getting file size for $relativePath: $e');
      return 0;
    }
  }

  /// Get directory size in bytes (approximation on web)
  @override
  Future<int> getDirectorySize(String relativePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final prefix = _getStorageKey(relativePath);

      var totalSize = 0;
      for (final key in prefs.getKeys()) {
        if (key.startsWith(prefix)) {
          final content = prefs.getString(key);
          totalSize += content?.length ?? 0;
        }
      }

      return totalSize;
    } on Exception catch (e) {
      print('Error calculating directory size for $relativePath: $e');
      return 0;
    }
  }

  /// Clean up temporary files (no-op on web)
  @override
  Future<void> cleanupTempFiles() async {
    // No-op on web - no temp files in SharedPreferences
  }

  /// Validate JSON file integrity
  @override
  Future<bool> validateJsonFile(String relativePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getStorageKey(relativePath);
      final content = prefs.getString(key);

      if (content == null) {
        return false;
      }

      jsonDecode(content); // This will throw if invalid JSON
      return true;
    } on Exception {
      return false;
    }
  }

  /// Initialize cache directory structure (no-op on web)
  @override
  Future<void> initializeCacheStructure() async {
    // No-op on web - SharedPreferences doesn't need directory structure
  }

  /// Get cache directory path (returns logical path on web)
  @override
  String getCachePath(String relativePath) {
    return '$cacheDirectory/$relativePath';
  }

  /// Generate storage key for SharedPreferences
  String _getStorageKey(String relativePath) {
    return 'cache_$cacheDirectory/$relativePath';
  }
}
