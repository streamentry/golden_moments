import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:golden_moments/data/models/github_pack_index.dart';
import 'package:golden_moments/game/models/models.dart';

/// Service for loading pack data from local JSON files
class LocalPackService {
  LocalPackService._();

  static LocalPackService? _instance;
  static LocalPackService get instance => _instance ??= LocalPackService._();

  GitHubPackIndex? _cachedIndex;

  /// Load pack index from local JSON file
  Future<GitHubPackIndex> loadPackIndex() async {
    if (_cachedIndex != null) {
      return _cachedIndex!;
    }

    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/packs_index.json',
      );
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;

      _cachedIndex = GitHubPackIndex.fromJson(jsonData);
      return _cachedIndex!;
    } catch (e) {
      throw Exception('Failed to load pack index: $e');
    }
  }

  /// Get all available packs
  Future<List<GitHubPackInfo>> getAllPacks() async {
    final index = await loadPackIndex();
    return index.packs;
  }

  /// Get pack by ID
  Future<GitHubPackInfo?> getPackById(String packId) async {
    final packs = await getAllPacks();
    try {
      return packs.firstWhere((pack) => pack.id == packId);
    } catch (e) {
      return null;
    }
  }

  /// Get packs by category
  Future<List<GitHubPackInfo>> getPacksByCategory(String category) async {
    final packs = await getAllPacks();
    return packs.where((pack) => pack.category == category).toList();
  }

  /// Get featured packs
  Future<List<GitHubPackInfo>> getFeaturedPacks() async {
    final packs = await getAllPacks();
    return packs.where((pack) => pack.isFeatured).toList();
  }

  /// Search packs by query
  Future<List<GitHubPackInfo>> searchPacks(String query) async {
    if (query.isEmpty) {
      return getAllPacks();
    }

    final packs = await getAllPacks();
    final lowerQuery = query.toLowerCase();

    return packs.where((pack) {
      return pack.title.toLowerCase().contains(lowerQuery) ||
          (pack.description?.toLowerCase().contains(lowerQuery) ?? false) ||
          pack.theme.toLowerCase().contains(lowerQuery) ||
          pack.category.toLowerCase().contains(lowerQuery) ||
          pack.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  /// Get all categories
  Future<List<PackCategory>> getCategories() async {
    final index = await loadPackIndex();
    return index.categories;
  }

  /// Convert GitHubPackInfo to GamePack
  GamePack convertToGamePack(GitHubPackInfo packInfo) {
    return GamePack(
      id: packInfo.id,
      title: packInfo.title,
      theme: packInfo.theme,
      difficulty: packInfo.difficulty,
      description: packInfo.description,
      tiles: packInfo.images
          .map(
            (image) => GameTile(
              id: image['id'] as String,
              imageUrl: image['url'] as String,
              caption: image['caption'] as String,
            ),
          )
          .toList(),
    );
  }

  /// Get GamePack by ID
  Future<GamePack?> getGamePackById(String packId) async {
    final packInfo = await getPackById(packId);
    if (packInfo == null) return null;

    return convertToGamePack(packInfo);
  }

  /// Get pack statistics
  Future<PackStatistics> getPackStatistics() async {
    final packs = await getAllPacks();
    final categories = await getCategories();

    return PackStatistics(
      totalPacks: packs.length,
      totalCategories: categories.length,
      featuredPacks: packs.where((pack) => pack.isFeatured).length,
      premiumPacks: packs.where((pack) => pack.isPremium).length,
      packsByDifficulty: {
        GameDifficulty.easy: packs
            .where((pack) => pack.difficulty == GameDifficulty.easy)
            .length,
        GameDifficulty.medium: packs
            .where((pack) => pack.difficulty == GameDifficulty.medium)
            .length,
        GameDifficulty.hard: packs
            .where((pack) => pack.difficulty == GameDifficulty.hard)
            .length,
        GameDifficulty.brainy: packs
            .where((pack) => pack.difficulty == GameDifficulty.brainy)
            .length,
      },
      packsByCategory: Map.fromEntries(
        categories.map(
          (category) => MapEntry(
            category.name,
            packs.where((pack) => pack.category == category.id).length,
          ),
        ),
      ),
    );
  }

  /// Filter packs by criteria
  Future<List<GitHubPackInfo>> filterPacks({
    String? category,
    GameDifficulty? difficulty,
    bool? isPremium,
    bool? isFeatured,
    List<String>? tags,
  }) async {
    var packs = await getAllPacks();

    if (category != null) {
      packs = packs.where((pack) => pack.category == category).toList();
    }

    if (difficulty != null) {
      packs = packs.where((pack) => pack.difficulty == difficulty).toList();
    }

    if (isPremium != null) {
      packs = packs.where((pack) => pack.isPremium == isPremium).toList();
    }

    if (isFeatured != null) {
      packs = packs.where((pack) => pack.isFeatured == isFeatured).toList();
    }

    if (tags != null && tags.isNotEmpty) {
      packs = packs
          .where((pack) => tags.any((tag) => pack.tags.contains(tag)))
          .toList();
    }

    return packs;
  }

  /// Get random packs
  Future<List<GitHubPackInfo>> getRandomPacks(int count) async {
    final packs = await getAllPacks();
    final shuffled = List<GitHubPackInfo>.from(packs)..shuffle();
    return shuffled.take(count).toList();
  }

  /// Clear cached data (for testing or refresh)
  void clearCache() {
    _cachedIndex = null;
  }

  /// Check if service is available (always true for local service)
  Future<bool> isServiceAvailable() async {
    try {
      await loadPackIndex();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get service status
  Future<ServiceStatus> getServiceStatus() async {
    try {
      final index = await loadPackIndex();
      return ServiceStatus(
        isAvailable: true,
        lastUpdated: index.lastUpdated,
        totalPacks: index.packs.length,
        version: index.version,
        source: 'Local JSON',
      );
    } catch (e) {
      return ServiceStatus(
        isAvailable: false,
        lastUpdated: DateTime.now(),
        totalPacks: 0,
        version: 'Unknown',
        source: 'Local JSON',
        error: e.toString(),
      );
    }
  }
}

/// Pack statistics data class
class PackStatistics {
  const PackStatistics({
    required this.totalPacks,
    required this.totalCategories,
    required this.featuredPacks,
    required this.premiumPacks,
    required this.packsByDifficulty,
    required this.packsByCategory,
  });

  final int totalPacks;
  final int totalCategories;
  final int featuredPacks;
  final int premiumPacks;
  final Map<GameDifficulty, int> packsByDifficulty;
  final Map<String, int> packsByCategory;
}

/// Service status data class
class ServiceStatus {
  const ServiceStatus({
    required this.isAvailable,
    required this.lastUpdated,
    required this.totalPacks,
    required this.version,
    required this.source,
    this.error,
  });

  final bool isAvailable;
  final DateTime lastUpdated;
  final int totalPacks;
  final String version;
  final String source;
  final String? error;

  /// Get formatted status message
  String get statusMessage {
    if (!isAvailable) {
      return 'Service unavailable: ${error ?? 'Unknown error'}';
    }
    return 'Service available: $totalPacks packs loaded from $source';
  }

  /// Get formatted last updated time
  String get formattedLastUpdated {
    final now = DateTime.now();
    final difference = now.difference(lastUpdated);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}
