import 'package:flutter/material.dart';
import 'package:golden_moments/features/gentle_activities/data/picture_library.g.dart';
import 'package:golden_moments/l10n/l10n.dart';

/// A bundled drawing ([asset]), a normalized local family-photo copy
/// ([path]), or, in tests, a plain [icon].
///
/// The drawings are the website's picture library, exported by
/// `site/scripts/export-pictures.mjs`, so the app and the site show the same
/// pictures under the same names.
class ActivityPicture {
  const new({
    required this.id,
    required this.label,
    this.icon,
    this.asset,
    this.path,
    this.caption = '',
    this.description = '',
  });
  final String id;

  /// Plain name for assistive technology: the caption when there is one.
  final String label;
  final IconData? icon;

  /// A drawing bundled with the app (see [pictureLibrary]).
  final String? asset;

  /// A family photo's local copy.
  final String? path;

  /// Optional text the person wrote; shown only where viewing asks for it.
  final String caption;

  /// Optional longer description read by screen readers while the picture is
  /// visible. Never used for hidden tiles.
  final String description;

  /// [label] in the reader's language. A drawing takes its name from the
  /// shared picture names (falling back to the base language, then to
  /// English); a family photo keeps its own caption or the numbered name its
  /// page gave it.
  String localizedLabel(AppLocalizations l10n) {
    if (path != null || asset == null) return label;
    final locale = l10n.localeName;
    final base = locale.split('_').first;
    return pictureNames[locale]?[id] ?? pictureNames[base]?[id] ?? label;
  }

  /// Every bundled drawing, shared with the website.
  static const List<ActivityPicture> samples = pictureLibrary;

  /// Ids of the six icons that came before the drawings, mapped to the
  /// drawing that replaced each, so a board saved by an earlier version
  /// still resumes.
  static const Map<String, String> legacyIds = {
    'flower': 'sunflower',
    'cup': 'teacup',
    'home': 'house',
    'pet': 'dog',
  };
}
