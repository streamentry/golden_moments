import 'package:equatable/equatable.dart';

/// Main cache index that tracks all cached packs and their status
class CacheIndex extends Equatable {
  const CacheIndex({
    required this.version,
    required this.lastUpdated,
    required this.lastCleanup,
    required this.packs,
  });

  final String version;
  final DateTime lastUpdated;
  final DateTime lastCleanup;
  final Map<String, CachedPackInfo> packs;

  factory CacheIndex.empty() {
    return CacheIndex(
      version: '1.0.0',
      lastUpdated: DateTime.now(),
      lastCleanup: DateTime.now(),
      packs: {},
    );
  }

  factory CacheIndex.fromJson(Map<String, dynamic> json) {
    final packsMap = <String, CachedPackInfo>{};
    final packsJson = json['packs'] as Map<String, dynamic>? ?? {};
    
    for (final entry in packsJson.entries) {
      packsMap[entry.key] = CachedPackInfo.fromJson(
        entry.value as Map<String, dynamic>,
      );
    }

    return CacheIndex(
      version: json['version'] as String? ?? '1.0.0',
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      lastCleanup: DateTime.parse(json['lastCleanup'] as String),
      packs: packsMap,
    );
  }

  Map<String, dynamic> toJson() {
    final packsJson = <String, dynamic>{};
    for (final entry in packs.entries) {
      packsJson[entry.key] = entry.value.toJson();
    }

    return {
      'version': version,
      'lastUpdated': lastUpdated.toIso8601String(),
      'lastCleanup': lastCleanup.toIso8601String(),
      'packs': packsJson,
    };
  }

  CacheIndex copyWith({
    String? version,
    DateTime? lastUpdated,
    DateTime? lastCleanup,
    Map<String, CachedPackInfo>? packs,
  }) {
    return CacheIndex(
      version: version ?? this.version,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      lastCleanup: lastCleanup ?? this.lastCleanup,
      packs: packs ?? this.packs,
    );
  }

  /// Add or update a pack in the cache index
  CacheIndex addPack(CachedPackInfo packInfo) {
    final updatedPacks = Map<String, CachedPackInfo>.from(packs);
    updatedPacks[packInfo.id] = packInfo;
    
    return copyWith(
      packs: updatedPacks,
      lastUpdated: DateTime.now(),
    );
  }

  /// Remove a pack from the cache index
  CacheIndex removePack(String packId) {
    final updatedPacks = Map<String, CachedPackInfo>.from(packs);
    updatedPacks.remove(packId);
    
    return copyWith(
      packs: updatedPacks,
      lastUpdated: DateTime.now(),
    );
  }

  /// Get expired packs that need cleanup
  List<CachedPackInfo> getExpiredPacks() {
    final now = DateTime.now();
    return packs.values
        .where((pack) => pack.expiresAt.isBefore(now))
        .toList();
  }

  /// Get total cache size in bytes
  int getTotalCacheSize() {
    return packs.values
        .fold(0, (sum, pack) => sum + pack.totalSize);
  }

  @override
  List<Object?> get props => [version, lastUpdated, lastCleanup, packs];
}

/// Information about a cached pack
class CachedPackInfo extends Equatable {
  const CachedPackInfo({
    required this.id,
    required this.version,
    required this.title,
    required this.status,
    required this.downloadedAt,
    required this.expiresAt,
    required this.imageCount,
    required this.downloadedImages,
    required this.totalSize,
    required this.localManifestPath,
  });

  final String id;
  final String version;
  final String title;
  final CacheStatus status;
  final DateTime downloadedAt;
  final DateTime expiresAt;
  final int imageCount;
  final int downloadedImages;
  final int totalSize;
  final String localManifestPath;

  factory CachedPackInfo.fromJson(Map<String, dynamic> json) {
    return CachedPackInfo(
      id: json['id'] as String,
      version: json['version'] as String,
      title: json['title'] as String,
      status: CacheStatus.fromString(json['status'] as String),
      downloadedAt: DateTime.parse(json['downloadedAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      imageCount: json['imageCount'] as int,
      downloadedImages: json['downloadedImages'] as int,
      totalSize: json['totalSize'] as int,
      localManifestPath: json['localManifestPath'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'version': version,
      'title': title,
      'status': status.toString(),
      'downloadedAt': downloadedAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'imageCount': imageCount,
      'downloadedImages': downloadedImages,
      'totalSize': totalSize,
      'localManifestPath': localManifestPath,
    };
  }

  CachedPackInfo copyWith({
    String? id,
    String? version,
    String? title,
    CacheStatus? status,
    DateTime? downloadedAt,
    DateTime? expiresAt,
    int? imageCount,
    int? downloadedImages,
    int? totalSize,
    String? localManifestPath,
  }) {
    return CachedPackInfo(
      id: id ?? this.id,
      version: version ?? this.version,
      title: title ?? this.title,
      status: status ?? this.status,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      imageCount: imageCount ?? this.imageCount,
      downloadedImages: downloadedImages ?? this.downloadedImages,
      totalSize: totalSize ?? this.totalSize,
      localManifestPath: localManifestPath ?? this.localManifestPath,
    );
  }

  /// Check if this pack is expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Check if download is complete
  bool get isDownloadComplete => downloadedImages >= imageCount;

  /// Get download progress (0.0 to 1.0)
  double get downloadProgress {
    if (imageCount == 0) return 1.0;
    return downloadedImages / imageCount;
  }

  @override
  List<Object?> get props => [
        id,
        version,
        title,
        status,
        downloadedAt,
        expiresAt,
        imageCount,
        downloadedImages,
        totalSize,
        localManifestPath,
      ];
}

/// Cache status enumeration
enum CacheStatus {
  available,
  downloading,
  downloaded,
  expired,
  failed;

  static CacheStatus fromString(String value) {
    return CacheStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => CacheStatus.available,
    );
  }

  @override
  String toString() => name;
}
