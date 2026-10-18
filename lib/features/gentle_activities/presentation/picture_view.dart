import 'dart:io';

import 'package:flutter/material.dart';
import 'package:golden_moments/features/gentle_activities/models/activity_picture.dart';

class PictureView extends StatelessWidget {
  const PictureView({required this.picture, super.key});
  final ActivityPicture picture;

  @override
  Widget build(BuildContext context) {
    if (picture.path != null) {
      return Image.file(
        File(picture.path!),
        fit: BoxFit.contain,
        cacheWidth: 768,
        excludeFromSemantics: true,
        errorBuilder: (_, _, _) =>
            const Center(child: Text('Photo unavailable')),
      );
    }
    return Center(
      child: Icon(
        picture.icon ?? Icons.photo,
        size: 72,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
