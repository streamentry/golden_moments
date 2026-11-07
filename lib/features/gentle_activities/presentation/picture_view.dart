import 'dart:io';

import 'package:flutter/material.dart';
import 'package:golden_moments/features/gentle_activities/models/activity_picture.dart';
import 'package:golden_moments/l10n/l10n.dart';

class PictureView extends StatelessWidget {
  const new({required this.picture, this.fit = BoxFit.contain, super.key});
  final ActivityPicture picture;

  /// How a photo fills its space: whole by default (Look together), or
  /// [BoxFit.cover] where it sits in a tile and is cropped to the tile's
  /// shape, never letterboxed (DESIGN.md › Shapes).
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (picture.path != null) {
      return Image.file(
        File(picture.path!),
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        cacheWidth: 768,
        excludeFromSemantics: true,
        errorBuilder: (_, _, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.image_not_supported_outlined,
                size: 40,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              Text(
                context.l10n.pictureViewUnavailable,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    final asset = picture.asset;
    if (asset != null) {
      // A drawing fills its space like a printed card: the background is
      // part of the picture, so cropping a little to a tile's shape is fine.
      return Image.asset(
        asset,
        fit: fit == BoxFit.contain ? BoxFit.contain : BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        excludeFromSemantics: true,
        errorBuilder: (_, _, _) => _iconView(context),
      );
    }
    return _iconView(context);
  }

  /// A plain icon, for test pictures and as the drawing's safe fallback.
  Widget _iconView(BuildContext context) {
    // Icons grow with the tile so they stay easy to see on tablets as well
    // as phones.
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = constraints.biggest.shortestSide;
        return Center(
          child: Icon(
            picture.icon ?? Icons.photo,
            size: side.isFinite ? (side * 0.5).clamp(48, 160) : 72,
            color: Theme.of(context).colorScheme.primary,
          ),
        );
      },
    );
  }
}
