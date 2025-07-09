import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

/// Safe JSON file operations with atomic writes and corruption recovery
class JsonFileManager {
  JsonFileManager({required this.cacheDirectory});

  final String cacheDirectory;

  /// Load JSON file with type safety and error handling
  Future<T?> loadJsonFile<T>(
    String relativePath,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final filePath = path.join(cacheDirectory, relativePath);
      final file = File(filePath);

      if (!await file.exists()) {
        return null;
      }

      final content = await file.readAsString();
      if (content.trim().isEmpty) {
        return null;
      }

      final jsonData = jsonDecode(content) as Map<String, dynamic>;
      return fromJson(jsonData);
    } catch (e) {
      // Try to recover from backup
      final backupData = await _tryLoadBackup<T>(relativePath, fromJson);
      if (backupData != null) {
        // Restore from backup - we'll handle this in the service layer
        return backupData;
      }
      
      // Log error and return null
      print('Error loading JSON file $relativePath: $e');
      return null;
    }
  }

  /// Save JSON file with atomic write and backup
  Future<void> saveJsonFile<T>(
    String relativePath,
    T data,
    Map<String, dynamic> Function(T) toJson,
  ) async {
    try {
      final filePath = path.join(cacheDirectory, relativePath);
      final file = File(filePath);
      
      // Ensure directory exists
      await file.parent.create(recursive: true);
      
      // Create backup if file exists
      if (await file.exists()) {
        await _createBackup(filePath);
      }
      
      // Atomic write using temporary file
      final tempPath = '$filePath.tmp';
      final tempFile = File(tempPath);
      
      final jsonData = toJson(data);
      final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);
      
      await tempFile.writeAsString(jsonString);
      
      // Atomic rename
      await tempFile.rename(filePath);
      
    } catch (e) {
      print('Error saving JSON file $relativePath: $e');
      rethrow;
    }
  }

  /// Check if file exists
  Future<bool> fileExists(String relativePath) async {
    final filePath = path.join(cacheDirectory, relativePath);
    return File(filePath).exists();
  }

  /// Delete file safely
  Future<void> deleteFile(String relativePath) async {
    try {
      final filePath = path.join(cacheDirectory, relativePath);
      final file = File(filePath);
      
      if (await file.exists()) {
        await file.delete();
      }
      
      // Also delete backup if it exists
      final backupPath = '$filePath.backup';
      final backupFile = File(backupPath);
      if (await backupFile.exists()) {
        await backupFile.delete();
      }
    } catch (e) {
      print('Error deleting file $relativePath: $e');
    }
  }

  /// Create directory
  Future<void> createDirectory(String relativePath) async {
    final dirPath = path.join(cacheDirectory, relativePath);
    final directory = Directory(dirPath);
    await directory.create(recursive: true);
  }

  /// List files in directory
  Future<List<String>> listFiles(String relativePath) async {
    try {
      final dirPath = path.join(cacheDirectory, relativePath);
      final directory = Directory(dirPath);
      
      if (!await directory.exists()) {
        return [];
      }
      
      final files = await directory.list().toList();
      return files
          .where((entity) => entity is File)
          .map((file) => path.basename(file.path))
          .toList();
    } catch (e) {
      print('Error listing files in $relativePath: $e');
      return [];
    }
  }

  /// Get file size in bytes
  Future<int> getFileSize(String relativePath) async {
    try {
      final filePath = path.join(cacheDirectory, relativePath);
      final file = File(filePath);
      
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      print('Error getting file size for $relativePath: $e');
      return 0;
    }
  }

  /// Get directory size in bytes
  Future<int> getDirectorySize(String relativePath) async {
    try {
      final dirPath = path.join(cacheDirectory, relativePath);
      final directory = Directory(dirPath);
      
      if (!await directory.exists()) {
        return 0;
      }
      
      int totalSize = 0;
      await for (final entity in directory.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      
      return totalSize;
    } catch (e) {
      print('Error calculating directory size for $relativePath: $e');
      return 0;
    }
  }

  /// Clean up temporary files
  Future<void> cleanupTempFiles() async {
    try {
      final directory = Directory(cacheDirectory);
      
      if (!await directory.exists()) {
        return;
      }
      
      await for (final entity in directory.list(recursive: true)) {
        if (entity is File && entity.path.endsWith('.tmp')) {
          try {
            await entity.delete();
          } catch (e) {
            print('Error deleting temp file ${entity.path}: $e');
          }
        }
      }
    } catch (e) {
      print('Error cleaning up temp files: $e');
    }
  }

  /// Validate JSON file integrity
  Future<bool> validateJsonFile(String relativePath) async {
    try {
      final filePath = path.join(cacheDirectory, relativePath);
      final file = File(filePath);
      
      if (!await file.exists()) {
        return false;
      }
      
      final content = await file.readAsString();
      jsonDecode(content); // This will throw if invalid JSON
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Create backup of existing file
  Future<void> _createBackup(String filePath) async {
    try {
      final file = File(filePath);
      final backupPath = '$filePath.backup';
      await file.copy(backupPath);
    } catch (e) {
      print('Error creating backup for $filePath: $e');
    }
  }

  /// Try to load from backup file
  Future<T?> _tryLoadBackup<T>(
    String relativePath,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final filePath = path.join(cacheDirectory, relativePath);
      final backupPath = '$filePath.backup';
      final backupFile = File(backupPath);
      
      if (!await backupFile.exists()) {
        return null;
      }
      
      final content = await backupFile.readAsString();
      final jsonData = jsonDecode(content) as Map<String, dynamic>;
      return fromJson(jsonData);
    } catch (e) {
      print('Error loading backup for $relativePath: $e');
      return null;
    }
  }

  /// Initialize cache directory structure
  Future<void> initializeCacheStructure() async {
    try {
      // Create main cache directory
      await createDirectory('');
      
      // Create subdirectories
      await createDirectory('packs');
      await createDirectory('images');
      
      // Clean up any temporary files from previous sessions
      await cleanupTempFiles();
    } catch (e) {
      print('Error initializing cache structure: $e');
      rethrow;
    }
  }

  /// Get cache directory path
  String getCachePath(String relativePath) {
    return path.join(cacheDirectory, relativePath);
  }
}
