import 'package:equatable/equatable.dart';

import '../../game/models/models.dart';

/// GitHub pack index containing all available packs
class GitHubPackIndex extends Equatable {
  const GitHubPackIndex({
    required this.version,
    required this.lastUpdated,
    required this.totalPacks,
    required this.packs,
    this.featuredPacks = const [],
    this.categories = const [],
  });

  final String version;
  final DateTime lastUpdated;
  final int totalPacks;
  final List<GitHubPackInfo> packs;
  final List<String> featuredPacks;
  final List<PackCategory> categories;

  factory GitHubPackIndex.fromJson(Map<String, dynamic> json) {
    return GitHubPackIndex(
      version: json['version'] as String? ?? '1.0.0',
      lastUpdated: DateTime.parse(
        json['lastUpdated'] as String? ?? DateTime.now().toIso8601String(),
      ),
      totalPacks: json['totalPacks'] as int? ?? 0,
      packs: (json['packs'] as List<dynamic>? ?? [])
          .map((pack) => GitHubPackInfo.fromJson(pack as Map<String, dynamic>))
          .toList(),
      featuredPacks: (json['featuredPacks'] as List<dynamic>? ?? [])
          .cast<String>(),
      categories: (json['categories'] as List<dynamic>? ?? [])
          .map((category) => PackCategory.fromJson(category as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'lastUpdated': lastUpdated.toIso8601String(),
      'packs': packs.map((pack) => pack.toJson()).toList(),
      'featuredPacks': featuredPacks,
      'categories': categories,
    };
  }

  /// Get pack by ID
  GitHubPackInfo? getPackById(String packId) {
    try {
      return packs.firstWhere((pack) => pack.id == packId);
    } catch (e) {
      return null;
    }
  }

  /// Get packs by category
  List<GitHubPackInfo> getPacksByCategory(String category) {
    return packs.where((pack) => pack.category == category).toList();
  }

  /// Get packs by difficulty
  List<GitHubPackInfo> getPacksByDifficulty(GameDifficulty difficulty) {
    return packs.where((pack) => pack.difficulty == difficulty).toList();
  }

  /// Get featured packs
  List<GitHubPackInfo> getFeaturedPacks() {
    return packs.where((pack) => featuredPacks.contains(pack.id)).toList();
  }

  /// Get premium packs
  List<GitHubPackInfo> getPremiumPacks() {
    return packs.where((pack) => pack.isPremium).toList();
  }

  /// Get free packs
  List<GitHubPackInfo> getFreePacks() {
    return packs.where((pack) => !pack.isPremium).toList();
  }

  /// Search packs by title or description
  List<GitHubPackInfo> searchPacks(String query) {
    final lowercaseQuery = query.toLowerCase();
    return packs.where((pack) {
      return pack.title.toLowerCase().contains(lowercaseQuery) ||
             (pack.description?.toLowerCase().contains(lowercaseQuery) ?? false) ||
             pack.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  /// Get total number of images across all packs
  int get totalImages => packs.fold(0, (sum, pack) => sum + pack.imageCount);

  /// Get total estimated size across all packs
  int get totalEstimatedSize => packs.fold(0, (sum, pack) => sum + pack.estimatedSize);

  @override
  List<Object?> get props => [version, lastUpdated, packs, featuredPacks, categories];
}

/// Information about a pack available on GitHub
class GitHubPackInfo extends Equatable {
  const GitHubPackInfo({
    required this.id,
    required this.version,
    required this.title,
    required this.description,
    required this.theme,
    required this.difficulty,
    required this.category,
    required this.tags,
    required this.isPremium,
    required this.isFeatured,
    required this.imageCount,
    required this.estimatedSize,
    required this.createdAt,
    required this.updatedAt,
    this.thumbnailUrl,
    this.previewImages = const [],
    this.images = const [],
  });

  final String id;
  final String version;
  final String title;
  final String? description;
  final String theme;
  final GameDifficulty difficulty;
  final String category;
  final List<String> tags;
  final bool isPremium;
  final bool isFeatured;
  final int imageCount;
  final int estimatedSize;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? thumbnailUrl;
  final List<String> previewImages;
  final List<Map<String, dynamic>> images;

  factory GitHubPackInfo.fromJson(Map<String, dynamic> json) {
    return GitHubPackInfo(
      id: json['id'] as String,
      version: json['version'] as String? ?? '1.0.0',
      title: json['title'] as String,
      description: json['description'] as String?,
      theme: json['theme'] as String,
      difficulty: GameDifficulty.values.firstWhere(
        (d) => d.name == (json['difficulty'] as String),
        orElse: () => GameDifficulty.medium,
      ),
      category: json['category'] as String? ?? 'General',
      tags: (json['tags'] as List<dynamic>? ?? []).cast<String>(),
      isPremium: json['isPremium'] as bool? ?? false,
      isFeatured: json['isFeatured'] as bool? ?? false,
      imageCount: json['imageCount'] as int,
      estimatedSize: json['estimatedSize'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      thumbnailUrl: json['thumbnailUrl'] as String?,
      previewImages: (json['previewImages'] as List<dynamic>? ?? []).cast<String>(),
      images: (json['images'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'version': version,
      'title': title,
      if (description != null) 'description': description,
      'theme': theme,
      'difficulty': difficulty.name,
      'category': category,
      'tags': tags,
      'isPremium': isPremium,
      'isFeatured': isFeatured,
      'imageCount': imageCount,
      'estimatedSize': estimatedSize,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
      'previewImages': previewImages,
      'images': images,
    };
  }

  /// Get formatted file size
  String get formattedSize {
    if (estimatedSize < 1024) return '$estimatedSize B';
    if (estimatedSize < 1024 * 1024) {
      return '${(estimatedSize / 1024).toStringAsFixed(1)} KB';
    }
    if (estimatedSize < 1024 * 1024 * 1024) {
      return '${(estimatedSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(estimatedSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Get difficulty display name
  String get difficultyDisplayName {
    switch (difficulty) {
      case GameDifficulty.easy:
        return 'Easy';
      case GameDifficulty.medium:
        return 'Medium';
      case GameDifficulty.hard:
        return 'Hard';
      case GameDifficulty.brainy:
        return 'Brainy';
    }
  }

  /// Get difficulty color
  String get difficultyColor {
    switch (difficulty) {
      case GameDifficulty.easy:
        return '#4CAF50'; // Green
      case GameDifficulty.medium:
        return '#FF9800'; // Orange
      case GameDifficulty.hard:
        return '#F44336'; // Red
      case GameDifficulty.brainy:
        return '#9C27B0'; // Purple
    }
  }

  /// Check if pack is new (created within last 7 days)
  bool get isNew {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return createdAt.isAfter(weekAgo);
  }

  /// Check if pack was recently updated (updated within last 7 days)
  bool get isRecentlyUpdated {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return updatedAt.isAfter(weekAgo) && updatedAt.isAfter(createdAt);
  }

  /// Get pack age in days
  int get ageInDays {
    final now = DateTime.now();
    return now.difference(createdAt).inDays;
  }

  /// Get days since last update
  int get daysSinceUpdate {
    final now = DateTime.now();
    return now.difference(updatedAt).inDays;
  }

  /// Check if pack matches search query
  bool matchesQuery(String query) {
    final lowercaseQuery = query.toLowerCase();
    return title.toLowerCase().contains(lowercaseQuery) ||
           (description?.toLowerCase().contains(lowercaseQuery) ?? false) ||
           theme.toLowerCase().contains(lowercaseQuery) ||
           category.toLowerCase().contains(lowercaseQuery) ||
           tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
  }

  /// Get pack rating based on various factors (placeholder)
  double get rating {
    // This would be calculated based on user ratings, downloads, etc.
    // For now, return a placeholder based on pack characteristics
    double rating = 4.0;
    
    // Newer packs might have slightly lower ratings
    if (isNew) rating -= 0.2;
    
    // Premium packs might have higher ratings
    if (isPremium) rating += 0.3;
    
    // More images might indicate higher quality
    if (imageCount > 20) rating += 0.2;
    
    return rating.clamp(1.0, 5.0);
  }

  /// Get estimated download time based on average connection speed
  Duration getEstimatedDownloadTime({double speedBytesPerSecond = 1024 * 1024}) {
    if (speedBytesPerSecond <= 0) return Duration.zero;
    final seconds = estimatedSize / speedBytesPerSecond;
    return Duration(seconds: seconds.round());
  }

  @override
  List<Object?> get props => [
        id,
        version,
        title,
        description,
        theme,
        difficulty,
        category,
        tags,
        isPremium,
        isFeatured,
        imageCount,
        estimatedSize,
        createdAt,
        updatedAt,
        thumbnailUrl,
        previewImages,
        images,
      ];
}

/// Pack category information
class PackCategory extends Equatable {
  const PackCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.packCount,
  });

  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final int packCount;

  factory PackCategory.fromJson(Map<String, dynamic> json) {
    return PackCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconUrl: json['iconUrl'] as String,
      packCount: json['packCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
      'packCount': packCount,
    };
  }

  @override
  List<Object?> get props => [id, name, description, iconUrl, packCount];
}
