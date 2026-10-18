import 'package:flutter/material.dart';

/// A bundled illustration or a normalized, local family-photo copy.
class ActivityPicture {
  const ActivityPicture({
    required this.id,
    required this.label,
    this.icon,
    this.path,
  });
  final String id;
  final String label;
  final IconData? icon;
  final String? path;

  static const samples = [
    ActivityPicture(id: 'flower', label: 'Flower', icon: Icons.local_florist),
    ActivityPicture(id: 'cup', label: 'Cup', icon: Icons.local_cafe),
    ActivityPicture(id: 'sun', label: 'Sun', icon: Icons.wb_sunny),
    ActivityPicture(id: 'home', label: 'Home', icon: Icons.home),
    ActivityPicture(id: 'tree', label: 'Tree', icon: Icons.park),
    ActivityPicture(id: 'pet', label: 'Paw print', icon: Icons.pets),
  ];
}
