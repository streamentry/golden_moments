/*
───────────────────────────────────────────────────────────────────────────────
 Golden Moments – Complete Design System & Implementation Guideline (Flutter)
───────────────────────────────────────────────────────────────────────────────
 WHY A SINGLE FILE?  
 ▸ The early code base is small; one “source of truth” avoids drift while the
   team prototypes. Once the app grows, you can split this file following the
   structure suggested in FilledStacks’ Box UI example [[1]] and atomic design
   layers discussed by Rastogi [[2]].  
 ▸ Every constant, style and widget here is **prefix-scoped (gm…)** so it
   cannot clash with 3rd-party libs.

 HOW TO USE  
 ```dart
 import 'package:golden_moments/design_system.dart';
ThemeData theme = gmBuildTheme(brightness: Brightness.light);
class Home extends StatelessWidget { @override Widget build(BuildContext ctx) => Scaffold( backgroundColor: gmSurf50, body: Center( child: GmPrimaryButton( onTap: () => print('Memories!'), label: 'Start Daily Pack', ), ), ); }
javascript


──────────────────────────────────────────────────────────────────────────────*/
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:golden_moments/data/services/sound_service.dart';
import 'package:golden_moments/shared/widgets/pressable.dart';

///////////////////////////////////////////////////////////////////////////////
/// 1. COLOR TOKENS – “Golden Core”
///////////////////////////////////////////////////////////////////////////////
// Surfaces & text neutrals
const gmSurf50 = Color(0xFFFDF9F0); // default page bg (parchment)
const gmSurf100 = Color(0xFFF5EDE0); // cards, tiles back
const gmCharcoal900 = Color(0xFF222222); // primary text light mode
const gmCharcoal50 = Color(0xFFFDF9F0); // text in dark mode

// Gold ramp  (used only as accent / fills, NEVER body text)
const gmGold300 = Color(0xFFFFE08A);
const gmGold600 = Color(0xFFC99200);
const gmGold700 = Color(0xFFB07E00);

// Status colors for download indicators
const gmGreen600 = Color(0xFF4CAF50);
const gmOrange600 = Color(0xFFFF9800);

// Functional accents
const gmSapphire500 = Color(0xFF16688C); // secondary CTAs / focus ring
const gmEmerald500 = Color(0xFF2E7D32); // success / matched
const gmBrick500 = Color(0xFFB03127); // error / mismatch

///////////////////////////////////////////////////////////////////////////////
/// 2. TYPOGRAPHY
///////////////////////////////////////////////////////////////////////////////
const _gmFontFamily = 'NotoSans'; // Add in pubspec under fonts:

// Base scale (sp)
const double _gmFontScale = 1; // allow override for testing

TextTheme _gmTextTheme(Color onSurface) => TextTheme(
  displayLarge: TextStyle(
    // 32 sp bold – big headings
    fontSize: 32 * _gmFontScale,
    fontWeight: FontWeight.w700,
    color: onSurface,
    fontFamily: _gmFontFamily,
  ),
  titleLarge: TextStyle(
    // 24 sp semi-bold – section titles
    fontSize: 24 * _gmFontScale,
    fontWeight: FontWeight.w600,
    color: onSurface,
    fontFamily: _gmFontFamily,
  ),
  bodyLarge: TextStyle(
    // 20 sp regular – body
    fontSize: 20 * _gmFontScale,
    fontWeight: FontWeight.w400,
    height: 1.35,
    color: onSurface,
    fontFamily: _gmFontFamily,
  ),
  bodyMedium: TextStyle(
    // 18 sp – captions on tiles
    fontSize: 18 * _gmFontScale,
    fontWeight: FontWeight.w400,
    color: onSurface,
    fontFamily: _gmFontFamily,
  ),
);

///////////////////////////////////////////////////////////////////////////////
/// 3. SHAPES, SPACING, ELEVATION
///////////////////////////////////////////////////////////////////////////////
const double gmRadiusMd = 8;
const double gmRadiusLg = 16;

const double gmSpaceXs = 4;
const double gmSpaceSm = 8;
const double gmSpaceMd = 16;
const double gmSpaceLg = 24;

const double gmElevationCard = 2;
const double gmElevationModal = 8;

///////////////////////////////////////////////////////////////////////////////
/// 4. THEME BUILDERS  (light & dark)
///////////////////////////////////////////////////////////////////////////////
ThemeData gmBuildTheme({required Brightness brightness}) {
  final dark = brightness == Brightness.dark;

  final onSurface = dark ? gmSurf50 : gmCharcoal900;
  final background = dark ? gmCharcoal900 : gmSurf50;
  final surface = dark ? gmCharcoal900 : gmSurf100;
  final onPrimary = dark ? gmCharcoal900 : Colors.white;

  final scheme = ColorScheme(
    brightness: brightness,
    primary: dark ? gmGold700 : gmGold600,
    onPrimary: onPrimary,
    secondary: gmSapphire500,
    onSecondary: Colors.white,
    error: gmBrick500,
    onError: Colors.white,

    surface: surface,
    onSurface: onSurface,
  );

  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    textTheme: _gmTextTheme(onSurface),
    visualDensity: VisualDensity.standard,
    scaffoldBackgroundColor: background,
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      elevation: 0,
      iconTheme: IconThemeData(color: onSurface),
      titleTextStyle: _gmTextTheme(onSurface).titleLarge,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: scheme.inverseSurface,
      contentTextStyle: TextStyle(
        color: scheme.onInverseSurface,
        fontFamily: _gmFontFamily,
        fontSize: 18,
      ),
    ),
  );
}

///////////////////////////////////////////////////////////////////////////////
/// 5. ATOMS / MOLECULES
///////////////////////////////////////////////////////////////////////////////

/// PRIMARY CTA BUTTON  –  large touch target, gold fill
class GmPrimaryButton extends StatelessWidget {
  const GmPrimaryButton({
    required this.label,
    super.key,
    this.onTap,
    this.busy = false,
    this.disabled = false,
  });
  final String label;
  final VoidCallback? onTap;
  final bool busy;
  final bool disabled;

  @override
  Widget build(BuildContext parentContext) {
    final scheme = Theme.of(parentContext).colorScheme;
    final isDisabled = disabled || busy || onTap == null;
    final bg = isDisabled
        ? scheme.primary.withValues(alpha: 0.38)
        : scheme.primary;
    return Semantics(
      button: true,
      enabled: !isDisabled,
      child: SizedBox(
        height: 56,
        width: double.infinity,
        child: Material(
          color: bg,
          borderRadius: BorderRadius.circular(gmRadiusMd),
          child: Pressable(
            borderRadius: BorderRadius.circular(gmRadiusMd),
            onPressed: isDisabled ? null : onTap,
            child: Center(
              child: busy
                  ? SizedBox.square(
                      dimension: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation(scheme.onPrimary),
                      ),
                    )
                  : Text(
                      label,
                      style: Theme.of(
                        parentContext,
                      ).textTheme.titleLarge!.copyWith(color: scheme.onPrimary),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// OUTLINE BUTTON  –  secondary CTA
class GmOutlineButton extends StatelessWidget {
  const GmOutlineButton({required this.label, super.key, this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext parentContext) {
    final scheme = Theme.of(parentContext).colorScheme;
    return Semantics(
      button: true,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          side: BorderSide(color: scheme.secondary, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(gmRadiusMd),
          ),
        ),
        onPressed: () {
          SoundService().playTap();
          onTap?.call();
        },
        child: Text(
          label,
          style: Theme.of(
            parentContext,
          ).textTheme.titleLarge!.copyWith(color: scheme.secondary),
        ),
      ),
    );
  }
}

/// MEMORY TILE  (face-down / revealed)
class GmMemoryTile extends StatelessWidget {
  const GmMemoryTile({
    required this.revealed,
    required this.image,
    this.onTap,
    super.key,
  });
  final bool revealed;
  final ImageProvider image;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext parentContext) {
    final border = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(gmRadiusMd),
    );
    return Material(
      color: Theme.of(parentContext).colorScheme.surface,
      elevation: gmElevationCard,
      shape: border,
      child: Pressable(
        customBorder: border,
        onPressed: revealed ? null : onTap,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (c, a) =>
              RotationYTransition(turns: a, child: c), // custom below
          child: revealed
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(gmRadiusMd),
                  child: Image(
                    image: image,
                    fit: BoxFit.cover,
                  ),
                )
              : Center(
                  key: const ValueKey('back'),
                  child: Icon(
                    Icons.help_outline,
                    size: 42,
                    color: Theme.of(parentContext).colorScheme.primary,
                  ),
                ),
        ),
      ),
    );
  }
}

// Flip helper
class RotationYTransition extends AnimatedWidget {
  const RotationYTransition({
    required Animation<double> turns,
    required this.child,
    super.key,
  }) : super(listenable: turns);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final val = (listenable as Animation<double>).value;
    final transform = Matrix4.identity()
      ..setEntry(3, 2, 0.001) // Perspective
      ..rotateY(val * 3.1416); // 0 → 180°

    return Transform(
      transform: transform,
      alignment: Alignment.center,
      child: val <= 0.5
          ? child
          : Transform(
              transform: Matrix4.rotationY(3.1416),
              alignment: Alignment.center,
              child: child,
            ),
    );
  }
}

///////////////////////////////////////////////////////////////////////////////
/// 6. CONFETTI OVERLAY  –  respects reduced-motion setting
///////////////////////////////////////////////////////////////////////////////
class GmConfettiOverlay extends StatefulWidget {
  const GmConfettiOverlay({required this.show, super.key});
  final bool show;
  @override
  State<GmConfettiOverlay> createState() => _GmConfettiOverlayState();
}

class _GmConfettiOverlayState extends State<GmConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;
  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    if (widget.show && !MediaQuery.of(context).disableAnimations) {
      _ctl.forward();
    }
  }

  @override
  void didUpdateWidget(covariant GmConfettiOverlay old) {
    super.didUpdateWidget(old);
    if (widget.show && !MediaQuery.of(context).disableAnimations) {
      _ctl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Hide completely when show is false
    if (!widget.show) {
      return const SizedBox.shrink();
    }

    final size = MediaQuery.sizeOf(context);
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _ctl,
        builder: (_, __) {
          final t = _ctl.value;
          return Opacity(
            opacity: 1 - t,
            child: CustomPaint(
              size: size,
              painter: _ConfettiPainter(progress: t),
            ),
          );
        },
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.progress});
  final double progress;
  static const List<Color> _colors = [gmGold300, gmGold600, gmGold700];
  @override
  void paint(Canvas c, Size s) {
    final paint = Paint();
    for (var i = 0; i < 30; i++) {
      paint.color = _colors[i % _colors.length].withValues(
        alpha: 0.8 * (1 - progress),
      );
      final dx = (i * 53) % s.width;
      final dy = s.height * progress + (i * 37) % 120;
      c.drawCircle(Offset(dx, dy), 4, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) =>
      old.progress != progress;
}

///////////////////////////////////////////////////////////////////////////////
/// 7. ACCESSIBILITY SHORTCUTS
///////////////////////////////////////////////////////////////////////////////
extension GmAccessible on BuildContext {
  bool get isLargeText => MediaQuery.textScalerOf(this).scale(1) > 1.2;
}

///////////////////////////////////////////////////////////////////////////////
/// 8. SAMPLE SCAFFOLD (delete when integrated)
///////////////////////////////////////////////////////////////////////////////
/* 
class DesignSystemShowcase extends StatelessWidget {
 const DesignSystemShowcase({super.key});

 @override
 Widget build(BuildContext context) {
   return Theme(
     data: gmBuildTheme(brightness: Brightness.light),
     child: Scaffold(
       body: Padding(
         padding: const EdgeInsets.all(gmSpaceLg),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.stretch,
           children: [
             Text('Golden Moments', style: Theme.of(context).textTheme.displayLarge),
             const SizedBox(height: gmSpaceLg),
             GmPrimaryButton(label: 'Primary CTA', onTap: () {}),
             const SizedBox(height: gmSpaceMd),
             GmOutlineButton(label: 'Outline CTA', onTap: () {}),
             const SizedBox(height: gmSpaceLg),
             SizedBox(
               height: 120,
               child: GmMemoryTile(
                 revealed: false,
                 image: const AssetImage('assets/sample.webp'),
                 onTap: () {},
               ),
             ),
           ],
         ),
       ),
     ),
   );
 }
}
*/
