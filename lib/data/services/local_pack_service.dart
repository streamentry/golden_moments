import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:golden_moments/data/models/category.dart';
import 'package:golden_moments/data/models/packs_index.dart';
import 'package:golden_moments/game/models/models.dart';

/// Service for loading pack data from local JSON files
class LocalPackService {
  factory LocalPackService() => _instance;

  LocalPackService._internal();

  static final LocalPackService _instance = LocalPackService._internal();

  PacksIndex? packsIndex;

  /// Load pack index from local JSON file
  Future<PacksIndex> loadPacksIndex() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/packs_index.json',
      );
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      return PacksIndex.fromJson(jsonData);
    } catch (e) {
      throw Exception('Failed to load pack index: $e');
    }
  }

  /// Get Packs Indexs from cache or load from file
  Future<PacksIndex> getPacksIndex() async {
    return packsIndex ?? loadPacksIndex();
  }

  /// Get all available packs
  Future<List<Pack>> getPacks() async {
    return (await getPacksIndex()).packs;
  }

  /// Get all categories
  Future<List<Category>> getCategories() async {
    return (await getPacksIndex()).categories;
  }

  Future<Pack> getPackById(String packId) async {
    return (await getPacks()).firstWhere((pack) => pack.id == packId);
  }

  /// Clear cached data (for testing or refresh)
  void clearCache() {
    packsIndex = null;
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
