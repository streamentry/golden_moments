import 'package:equatable/equatable.dart';
import 'package:golden_moments/data/models/pack.dart';

/// Cached pack data with local file paths and metadata
class PackCache extends Equatable {
  const PackCache({
    required this.id,
    required this.version,
    required this.downloadedAt,
    required this.expiresAt,
    required this.manifest,
  });

  /// Create a new pack cache with 60-day expiry
  factory PackCache.create({
    required String id,
    required String version,
    required Pack manifest,
  }) {
    final now = DateTime.now();
    return PackCache(
      id: id,
      version: version,
      downloadedAt: now,
      expiresAt: now.add(const Duration(days: 60)),
      manifest: manifest,
    );
  }

  factory PackCache.fromJson(Map<String, dynamic> json) {
    return PackCache(
      id: json['id'] as String,
      version: json['version'] as String,
      downloadedAt: DateTime.parse(json['downloadedAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      manifest: Pack.fromJson(json['manifest'] as Map<String, dynamic>),
    );
  }

  final String id;
  final String version;
  final DateTime downloadedAt;
  final DateTime expiresAt;
  final Pack manifest;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'version': version,
      'downloadedAt': downloadedAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'manifest': manifest.toJson(),
    };
  }

  PackCache copyWith({
    String? id,
    String? version,
    DateTime? downloadedAt,
    DateTime? expiresAt,
    Pack? manifest,
    int? playCount,
    Duration? totalPlayTime,
    DateTime? lastPlayed,
  }) {
    return PackCache(
      id: id ?? this.id,
      version: version ?? this.version,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      manifest: manifest ?? this.manifest,
    );
  }

  @override
  List<Object?> get props => [id, version, downloadedAt, expiresAt, manifest];
}
