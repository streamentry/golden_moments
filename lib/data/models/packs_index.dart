import 'package:equatable/equatable.dart';
import 'package:golden_moments/data/models/category.dart';
import 'package:golden_moments/data/models/pack.dart';

/// GitHub pack index containing all available packs
class PacksIndex extends Equatable {
  const new({
    required this.version,
    required this.lastUpdated,
    required this.totalPacks,
    required this.categories,
    required this.featuredPacks,
    required this.packs,
  });

  factory fromJson(Map<String, dynamic> json) {
    return PacksIndex(
      version: json['version'] as String? ?? '1.0.0',
      lastUpdated: DateTime.parse(
        json['lastUpdated'] as String? ?? DateTime.now().toIso8601String(),
      ),
      totalPacks: json['totalPacks'] as int? ?? 0,
      packs: (json['packs'] as List<dynamic>? ?? [])
          .map((pack) => Pack.fromJson(pack as Map<String, dynamic>))
          .toList(),
      featuredPacks: (json['featuredPacks'] as List<dynamic>? ?? [])
          .cast<String>(),
      categories: (json['categories'] as List<dynamic>? ?? [])
          .map(
            (category) => Category.fromJson(category as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  final String version;
  final DateTime lastUpdated;
  final int totalPacks;
  final List<Category> categories;
  final List<Pack> packs;
  final List<String> featuredPacks;

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'lastUpdated': lastUpdated.toIso8601String(),
      'packs': packs.map((pack) => pack.toJson()).toList(),
      'featuredPacks': featuredPacks,
      'categories': categories.map((category) => category.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
    version,
    lastUpdated,
    packs,
    featuredPacks,
    categories,
  ];
}
