import 'package:flutter/material.dart';
import 'package:golden_moments/data/services/sound_service.dart';

/// A reusable pressable widget with ripple effect and tap sound
class Pressable extends StatelessWidget {
  const Pressable({
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
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
        onTap: () async {
          await SoundService().playTap();
          onPressed?.call();
        },
        child: child,
      ),
    );
  }
}
