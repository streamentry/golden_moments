import 'package:equatable/equatable.dart';
import 'package:golden_moments/data/models/pack_cache.dart';

/// GitHub pack index containing all available packs
class PacksCacheIndex extends Equatable {
  const new({
    required this.version,
    required this.lastUpdated,
    required this.packs,
  });

  factory fromJson(Map<String, dynamic> json) {
    return PacksCacheIndex(
      version: json['version'] as String? ?? '1.0.0',
      lastUpdated: DateTime.parse(
        json['lastUpdated'] as String? ?? DateTime.now().toIso8601String(),
      ),
      packs: (json['packs'] as List<dynamic>? ?? [])
          .map((pack) => PackCache.fromJson(pack as Map<String, dynamic>))
          .toList(),
    );
  }

  final String version;
  final DateTime lastUpdated;
  final List<PackCache> packs;

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'lastUpdated': lastUpdated.toIso8601String(),
      'packs': packs.map((pack) => pack.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [version, lastUpdated, packs];
}
