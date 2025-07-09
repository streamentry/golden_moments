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
 import 'package:memory_lane/design_system.dart';
ThemeData theme = gmBuildTheme(brightness: Brightness.light);
class Home extends StatelessWidget { @override Widget build(BuildContext ctx) => Scaffold( backgroundColor: gmSurf50, body: Center( child: GmPrimaryButton( onTap: () => print('Memories!'), label: 'Start Daily Pack', ), ), ); }
javascript


──────────────────────────────────────────────────────────────────────────────*/
import 'package:flutter/material.dart';

///////////////////////////////////////////////////////////////////////////////
/// 1. COLOR TOKENS – “Golden Core”
///////////////////////////////////////////////////////////////////////////////
// Surfaces & text neutrals
const gmSurf50       = Color(0xFFFDF9F0);   // default page bg (parchment)
const gmSurf100      = Color(0xFFF5EDE0);   // cards, tiles back
const gmCharcoal900  = Color(0xFF222222);   // primary text light mode
const gmCharcoal50   = Color(0xFFFDF9F0);   // text in dark mode

// Gold ramp  (used only as accent / fills, NEVER body text)
const gmGold300      = Color(0xFFFFE08A);
const gmGold600      = Color(0xFFC99200);
const gmGold700      = Color(0xFFB07E00);

// Status colors for download indicators
const gmGreen600     = Color(0xFF4CAF50);
const gmOrange600    = Color(0xFFFF9800);

// Functional accents
const gmSapphire500  = Color(0xFF16688C);   // secondary CTAs / focus ring
const gmEmerald500   = Color(0xFF2E7D32);   // success / matched
const gmBrick500     = Color(0xFFB03127);   // error / mismatch

///////////////////////////////////////////////////////////////////////////////
/// 2. TYPOGRAPHY
///////////////////////////////////////////////////////////////////////////////
const _gmFontFamily = 'NotoSans'; // Add in pubspec under fonts:

// Base scale (sp)
const double _gmFontScale = 1.0;      // allow override for testing

TextTheme _gmTextTheme(Color onSurface) => TextTheme(
 displayLarge   : TextStyle(           // 32 sp bold – big headings
   fontSize: 32 * _gmFontScale,
   fontWeight: FontWeight.w700,
   color: onSurface,
   fontFamily: _gmFontFamily,
 ),
 titleLarge     : TextStyle(           // 24 sp semi-bold – section titles
   fontSize: 24 * _gmFontScale,
   fontWeight: FontWeight.w600,
   color: onSurface,
   fontFamily: _gmFontFamily,
 ),
 bodyLarge      : TextStyle(           // 20 sp regular – body
   fontSize: 20 * _gmFontScale,
   fontWeight: FontWeight.w400,
   height: 1.35,
   color: onSurface,
   fontFamily: _gmFontFamily,
 ),
 bodyMedium     : TextStyle(           // 18 sp – captions on tiles
   fontSize: 18 * _gmFontScale,
   fontWeight: FontWeight.w400,
   color: onSurface,
   fontFamily: _gmFontFamily,
 ),
);

///////////////////////////////////////////////////////////////////////////////
/// 3. SHAPES, SPACING, ELEVATION
///////////////////////////////////////////////////////////////////////////////
const double gmRadiusMd  = 8.0;
const double gmRadiusLg  = 16.0;

const double gmSpaceXs = 4.0;
const double gmSpaceSm = 8.0;
const double gmSpaceMd = 16.0;
const double gmSpaceLg = 24.0;

const double gmElevationCard = 2.0;
const double gmElevationModal = 8.0;

///////////////////////////////////////////////////////////////////////////////
/// 4. THEME BUILDERS  (light & dark)
///////////////////////////////////////////////////////////////////////////////
ThemeData gmBuildTheme({required Brightness brightness}) {
 final bool dark = brightness == Brightness.dark;

 final Color onSurface   = dark ? gmSurf50      : gmCharcoal900;
 final Color background  = dark ? gmCharcoal900 : gmSurf50;
 final Color surface     = dark ? gmCharcoal900 : gmSurf100;
 final Color onPrimary   = dark ? gmCharcoal900 : Colors.white;

 final scheme = ColorScheme(
   brightness   : brightness,
   primary      : dark ? gmGold700 : gmGold600,
   onPrimary    : onPrimary,
   secondary    : gmSapphire500,
   onSecondary  : Colors.white,
   error        : gmBrick500,
   onError      : Colors.white,

   surface      : surface,
   onSurface    : onSurface,
 );

 return ThemeData(
   colorScheme    : scheme,
   useMaterial3   : true,
   textTheme      : _gmTextTheme(onSurface),
   visualDensity  : VisualDensity.standard,
   scaffoldBackgroundColor: background,
   appBarTheme    : AppBarTheme(
     backgroundColor: background,
     elevation: 0,
     iconTheme: IconThemeData(color: onSurface),
     titleTextStyle:
         _gmTextTheme(onSurface).titleLarge,
   ),
   snackBarTheme  : SnackBarThemeData(
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
 final String label;
 final VoidCallback? onTap;
 final bool busy, disabled;
 const GmPrimaryButton({
   Key? key,
   required this.label,
   this.onTap,
   this.busy = false,
   this.disabled = false,
 }) : super(key: key);

 @override
 Widget build(BuildContext context) {
   final scheme = Theme.of(context).colorScheme;
   final bool isDisabled = disabled || busy || onTap == null;
   final Color bg = isDisabled
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
         child: InkWell(
           borderRadius: BorderRadius.circular(gmRadiusMd),
           onTap: isDisabled ? null : onTap,
           child: Center(
             child: busy
                 ? SizedBox.square(
                     dimension: 24,
                     child: CircularProgressIndicator(
                       strokeWidth: 3,
                       valueColor:
                           AlwaysStoppedAnimation(scheme.onPrimary),
                     ),
                   )
                 : Text(
                     label,
                     style: Theme.of(context)
                         .textTheme
                         .titleLarge!
                         .copyWith(color: scheme.onPrimary),
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
 final String label;
 final VoidCallback? onTap;
 const GmOutlineButton({Key? key, required this.label, this.onTap})
     : super(key: key);

 @override
 Widget build(BuildContext context) {
   final scheme = Theme.of(context).colorScheme;
   return Semantics(
     button: true,
     child: OutlinedButton(
       style: OutlinedButton.styleFrom(
         minimumSize: const Size.fromHeight(56),
         side: BorderSide(color: scheme.secondary, width: 2),
         shape: RoundedRectangleBorder(
             borderRadius: BorderRadius.circular(gmRadiusMd)),
       ),
       onPressed: onTap,
       child: Text(
         label,
         style: Theme.of(context)
             .textTheme
             .titleLarge!
             .copyWith(color: scheme.secondary),
       ),
     ),
   );
 }
}

/// MEMORY TILE  (face-down / revealed)
class GmMemoryTile extends StatelessWidget {
 final bool revealed;
 final ImageProvider image;
 final VoidCallback? onTap;
 const GmMemoryTile({
   Key? key,
   required this.revealed,
   required this.image,
   this.onTap,
 }) : super(key: key);

 @override
 Widget build(BuildContext context) {
   final border = RoundedRectangleBorder(
       borderRadius: BorderRadius.circular(gmRadiusMd));
   return Material(
     color: Theme.of(context).colorScheme.surface,
     elevation: gmElevationCard,
     shape: border,
     child: InkWell(
       customBorder: border,
       onTap: revealed ? null : onTap,
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
                 child: Icon(Icons.help_outline,
                     size: 42,
                     color: Theme.of(context).colorScheme.primary),
               ),
       ),
     ),
   );
 }
}

// Flip helper
class RotationYTransition extends AnimatedWidget {
 const RotationYTransition(
     {Key? key, required Animation<double> turns, required this.child})
     : super(key: key, listenable: turns);
 final Widget child;
 @override
 Widget build(BuildContext context) {
   final double val = (listenable as Animation<double>).value;
   final Matrix4 transform =
       Matrix4.rotationY(val * 3.1416); // 0 → 180°
   return Transform(
     transform: transform,
     alignment: Alignment.center,
     child: child,
   );
 }
}

///////////////////////////////////////////////////////////////////////////////
/// 6. CONFETTI OVERLAY  –  respects reduced-motion setting
///////////////////////////////////////////////////////////////////////////////
class GmConfettiOverlay extends StatefulWidget {
 final bool show;
 const GmConfettiOverlay({Key? key, required this.show}) : super(key: key);
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
   if (widget.show && !MediaQuery.of(context).disableAnimations) _ctl.forward();
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
   final size = MediaQuery.sizeOf(context);
   return IgnorePointer(
     ignoring: true,
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
 final double progress;
 _ConfettiPainter({required this.progress});
 static const _colors = [gmGold300, gmGold600, gmGold700];
 @override
 void paint(Canvas c, Size s) {
   final paint = Paint();
   for (int i = 0; i < 30; i++) {
     paint.color = _colors[i % _colors.length]
         .withValues(alpha: 0.8 * (1 - progress));
     final dx = (i * 53) % s.width;
     final dy = s.height * progress + (i * 37) % 120;
     c.drawCircle(Offset(dx.toDouble(), dy.toDouble()), 4, paint);
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
