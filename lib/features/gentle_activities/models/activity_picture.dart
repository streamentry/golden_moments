import 'package:flutter/material.dart';
import 'package:golden_moments/l10n/l10n.dart';

/// A bundled illustration or a normalized, local family-photo copy.
class ActivityPicture {
  const new({
    required this.id,
    required this.label,
    this.icon,
    this.path,
    this.caption = '',
    this.description = '',
  });
  final String id;

  /// Plain name for assistive technology: the caption when there is one.
  final String label;
  final IconData? icon;
  final String? path;

  /// Optional text the person wrote; shown only where viewing asks for it.
  final String caption;

  /// Optional longer description read by screen readers while the picture is
  /// visible. Never used for hidden tiles.
  final String description;

  /// [label] in the reader's language. Starter illustrations (no [path])
  /// have translated names; a family photo keeps its own caption or the
  /// numbered name its page gave it.
  String localizedLabel(AppLocalizations l10n) {
    if (path != null) return label;
    return switch (id) {
      'flower' => l10n.samplePictureFlower,
      'cup' => l10n.samplePictureCup,
      'sun' => l10n.samplePictureSun,
      'home' => l10n.samplePictureHome,
      'tree' => l10n.samplePictureTree,
      'pet' => l10n.samplePicturePawPrint,
      _ => label,
    };
  }

  static const samples = [
    ActivityPicture(id: 'flower', label: 'Flower', icon: Icons.local_florist),
    ActivityPicture(id: 'cup', label: 'Cup', icon: Icons.local_cafe),
    ActivityPicture(id: 'sun', label: 'Sun', icon: Icons.wb_sunny),
    ActivityPicture(id: 'home', label: 'Home', icon: Icons.home),
    ActivityPicture(id: 'tree', label: 'Tree', icon: Icons.park),
    ActivityPicture(id: 'pet', label: 'Paw print', icon: Icons.pets),
  ];
}
