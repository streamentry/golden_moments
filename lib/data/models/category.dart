import 'package:equatable/equatable.dart';

class Category extends Equatable {
  const Category({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.packCount,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconUrl: json['iconUrl'] as String,
      packCount: json['packCount'] as int,
    );
  }

  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final int packCount;

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
  List<Object?> get props => [
    id,
    name,
    description,
    iconUrl,
    packCount,
  ];
}
