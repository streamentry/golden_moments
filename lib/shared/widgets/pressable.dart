import 'dart:async';

import 'package:flutter/material.dart';
import 'package:golden_moments/data/services/sound_service.dart';

/// A reusable pressable surface with a ripple and an optional tap sound.
///
/// The sound follows [SoundService] settings (off unless chosen) and is never
/// the only feedback: the highlight and the resulting screen change are.
class Pressable extends StatelessWidget {
  const new({
    required this.child,
    this.onPressed,
    this.borderRadius,
    this.splashColor,
    this.highlightColor,
    this.hoverColor,
    this.focusColor,
    this.radius,
    this.enableFeedback = true,
    this.customBorder,
    this.mouseCursor,
    this.onLongPress,
    this.onDoubleTap,
    this.onHover,
    this.onFocusChange,
    this.canRequestFocus = true,
    this.autofocus = false,
    super.key,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final BorderRadius? borderRadius;
  final Color? splashColor;
  final Color? highlightColor;
  final Color? hoverColor;
  final Color? focusColor;
  final double? radius;
  final bool enableFeedback;
  final ShapeBorder? customBorder;
  final MouseCursor? mouseCursor;
  final VoidCallback? onLongPress;
  final VoidCallback? onDoubleTap;
  final ValueChanged<bool>? onHover;
  final ValueChanged<bool>? onFocusChange;
  final bool canRequestFocus;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    // Reduce Motion: no spreading ripple; the press highlight still shows.
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        splashFactory: reduceMotion ? NoSplash.splashFactory : null,
        borderRadius: borderRadius,
        splashColor: splashColor,
        highlightColor: highlightColor,
        hoverColor: hoverColor,
        focusColor: focusColor,
        radius: radius,
        enableFeedback: enableFeedback,
        customBorder: customBorder,
        mouseCursor: mouseCursor,
        onLongPress: onLongPress,
        onDoubleTap: onDoubleTap,
        onHover: onHover,
        onFocusChange: onFocusChange,
        canRequestFocus: canRequestFocus,
        autofocus: autofocus,
        onTap: onPressed == null
            ? null
            : () {
                unawaited(SoundService().playTap());
                onPressed?.call();
              },
        child: child,
      ),
    );
  }
}
