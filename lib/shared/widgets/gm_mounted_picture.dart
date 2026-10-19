import 'package:flutter/material.dart';
import 'package:golden_moments/design_system.dart';

/// A picture mounted like a print in a family album (DESIGN.md ›
/// Personality): inset in its linen card by a slim mat, with softly rounded
/// corners. The asset is decoded at the size it is shown, never at the
/// file's full size. Decorative: the card's words are what a screen reader
/// reads.
class GmMountedPicture extends StatelessWidget {
  const new({required this.asset, this.aspectRatio = 1, this.width, super.key});

  final String asset;

  /// Width over height of the picture.
  final double aspectRatio;

  /// A fixed width; when null the picture fills the width it is given.
  final double? width;

  @override
  Widget build(BuildContext context) {
    final ratio = MediaQuery.devicePixelRatioOf(context);
    final scheme = Theme.of(context).colorScheme;
    Widget picture(double shownWidth) => Image.asset(
      asset,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      cacheWidth: (shownWidth * ratio).round(),
      excludeFromSemantics: true,
      errorBuilder: (context, error, stackTrace) =>
          Icon(Icons.photo_outlined, size: 40, color: scheme.onSurfaceVariant),
    );
    final fixed = width;
    return Padding(
      padding: const EdgeInsets.all(gmSpaceSm),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(gmRadiusMd),
        child: ColoredBox(
          color: gmSurf200,
          child: fixed != null
              ? SizedBox(
                  width: fixed,
                  height: fixed / aspectRatio,
                  child: picture(fixed),
                )
              : AspectRatio(
                  aspectRatio: aspectRatio,
                  child: LayoutBuilder(
                    builder: (context, box) => picture(box.maxWidth),
                  ),
                ),
        ),
      ),
    );
  }
}
