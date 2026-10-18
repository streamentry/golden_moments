import 'dart:async';

/*
───────────────────────────────────────────────────────────────────────────────
 Golden Moments – design system implementation (Flutter)
───────────────────────────────────────────────────────────────────────────────
 DESIGN.md at the repository root is the contract: its YAML tokens are
 normative and this file implements them. Change both together.

 ▸ Every constant, style and widget here is **prefix-scoped (gm…)** so it
   cannot clash with 3rd-party libs.
 ▸ Screens should use stock Material widgets and `Theme.of(context)` roles;
   component styling lives in `gmBuildTheme`, not in individual screens.
 ▸ Sizes are logical pixels at 100% text size and scale with the system
   text setting, which must never be clamped.

*/

import 'package:flutter/material.dart';
import 'package:golden_moments/data/services/sound_service.dart';
import 'package:golden_moments/shared/widgets/pressable.dart';

///////////////////////////////////////////////////////////////////////////////
/// 1. COLOR TOKENS – “Golden Hour” (DESIGN.md › Colors)
///////////////////////////////////////////////////////////////////////////////
// Surfaces & text neutrals
const gmSurf50 = Color(0xFFFDF9F0); // background: parchment page
const gmSurf100 = Color(0xFFF5EDE0); // surface: linen tiles and cards
const gmSurf200 = Color(0xFFEADFCB); // surface-sunken: hidden-tile backs
const gmCharcoal900 = Color(0xFF222222); // on-surface: ink, primary text
const gmWalnut600 = Color(0xFF5C5346); // on-surface-variant: secondary text
const gmDriftwood500 = Color(0xFF7D7366); // outline: resting borders (≥3:1)

// Gold ramp. Only Antique Gold (800) may carry text or outlines; the bright
// golds measure below 3:1 on parchment and stay decorative.
const gmGold300 = Color(0xFFFFE08A); // primary-container: selection fills
const gmGold600 = Color(0xFFC99200); // accent: ornament only, never text
const gmGold800 = Color(0xFF7A5600); // primary: actions (6.7:1 with white)

// Status colors (always paired with an icon and a word)
const gmGreen600 = Color(0xFF256B29); // success: ready / downloaded
const gmOrange600 = Color(0xFF8C4A00); // warning: needs attention

// Functional accents
const gmSapphire500 = Color(0xFF16688C); // secondary: informational accents
const Color gmEmerald500 = gmGreen600; // success
const gmBrick500 = Color(0xFFB03127); // error: real failures only

///////////////////////////////////////////////////////////////////////////////
/// 2. TYPOGRAPHY (DESIGN.md › Typography)
///////////////////////////////////////////////////////////////////////////////
// Roboto is bundled (400/500/700) so text renders identically offline on
// every platform; it still scales with the system text size. Every style
// names the family so component styles never fall back to another font.
// Nothing is smaller than 16.
const gmFontFamily = 'Roboto';

TextTheme _gmTextTheme(Color onSurface) {
  TextStyle style(double size, FontWeight weight, double height) => TextStyle(
    fontFamily: gmFontFamily,
    fontSize: size,
    fontWeight: weight,
    height: height,
    color: onSurface,
    letterSpacing: 0,
  );

  return TextTheme(
    displayLarge: style(32, FontWeight.w700, 1.2), // headline-display
    displayMedium: style(32, FontWeight.w700, 1.2),
    displaySmall: style(30, FontWeight.w700, 1.2),
    headlineLarge: style(30, FontWeight.w700, 1.2), // headline-lg
    headlineMedium: style(28, FontWeight.w700, 1.25), // headline-md
    headlineSmall: style(24, FontWeight.w700, 1.3), // headline-sm
    titleLarge: style(24, FontWeight.w700, 1.3), // title-lg
    titleMedium: style(20, FontWeight.w700, 1.35), // title-md
    titleSmall: style(18, FontWeight.w700, 1.35), // title-sm
    bodyLarge: style(20, FontWeight.w400, 1.4), // body-lg: default reading
    bodyMedium: style(18, FontWeight.w400, 1.4), // body-md
    bodySmall: style(16, FontWeight.w400, 1.4), // body-sm: the floor
    labelLarge: style(20, FontWeight.w700, 1.2), // label-lg: buttons
    labelMedium: style(18, FontWeight.w700, 1.2), // label-md: chips, nav
    labelSmall: style(16, FontWeight.w700, 1.2), // label-sm: badges
  );
}

///////////////////////////////////////////////////////////////////////////////
/// 3. SHAPES, SPACING, SIZES, ELEVATION (DESIGN.md › Layout, Shapes)
///////////////////////////////////////////////////////////////////////////////
const double gmRadiusMd = 8; // chips, badges, snackbars
const double gmRadiusLg = 16; // tiles, cards
const double gmRadiusXl = 28; // sheets, dialogs

const double gmSpaceXs = 4;
const double gmSpaceSm = 8;
const double gmTileGap = 12;
const double gmSpaceMd = 16;
const double gmSpaceLg = 24; // screen gutter
const double gmSpaceXl = 32; // section break

const double gmTargetMin = 48; // every control
const double gmTargetPrimary = 56; // buttons
const double gmTargetHero = 64; // the one main action on Home
const double gmTileMin = 64; // picture tiles never shrink below this
const double gmContentMaxWidth = 720; // single centered column

const double gmElevationCard = 2;
const double gmElevationModal = 8;

const double gmBorderResting = 1;
const double gmBorderSelected = 4;

///////////////////////////////////////////////////////////////////////////////
/// 4. THEME BUILDER  (light only: the app has no dark mode)
///////////////////////////////////////////////////////////////////////////////
ThemeData gmBuildTheme() {
  const onSurface = gmCharcoal900;
  const background = gmSurf50;
  const surface = gmSurf100;

  const scheme = ColorScheme(
    brightness: Brightness.light,
    primary: gmGold800,
    onPrimary: Colors.white,
    primaryContainer: gmGold300,
    onPrimaryContainer: gmCharcoal900,
    secondary: gmSapphire500,
    onSecondary: Colors.white,
    tertiary: gmSapphire500,
    onTertiary: Colors.white,
    error: gmBrick500,
    onError: Colors.white,
    surface: surface,
    onSurface: onSurface,
    onSurfaceVariant: gmWalnut600,
    surfaceContainerLowest: background,
    surfaceContainerLow: background,
    surfaceContainer: surface,
    surfaceContainerHigh: background,
    surfaceContainerHighest: gmSurf200,
    outline: gmDriftwood500,
    outlineVariant: gmSurf200,
    inverseSurface: onSurface,
    onInverseSurface: background,
  );

  final text = _gmTextTheme(onSurface);
  const pill = StadiumBorder();
  const buttonPadding = EdgeInsets.symmetric(
    horizontal: gmSpaceLg,
    vertical: gmSpaceSm,
  );

  return ThemeData(
    colorScheme: scheme,
    fontFamily: gmFontFamily,
    useMaterial3: true,
    textTheme: text,
    visualDensity: VisualDensity.standard,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    scaffoldBackgroundColor: background,
    dividerColor: scheme.outlineVariant,
    iconTheme: const IconThemeData(color: onSurface, size: 28),
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: gmTargetHero,
      iconTheme: const IconThemeData(color: onSurface, size: 28),
      actionsIconTheme: const IconThemeData(color: onSurface, size: 28),
      titleTextStyle: text.titleLarge,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(gmTargetMin * 2, gmTargetPrimary),
        padding: buttonPadding,
        textStyle: text.labelLarge,
        iconSize: 28,
        shape: pill,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(gmTargetMin * 2, gmTargetPrimary),
        padding: buttonPadding,
        textStyle: text.labelLarge,
        iconSize: 28,
        shape: pill,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style:
          OutlinedButton.styleFrom(
            minimumSize: const Size(gmTargetMin * 2, gmTargetPrimary),
            padding: buttonPadding,
            textStyle: text.labelLarge,
            iconSize: 28,
            foregroundColor: scheme.primary,
            shape: pill,
          ).copyWith(
            // A disabled button must not keep the gold "tap me" outline.
            side: WidgetStateProperty.resolveWith(
              (states) => BorderSide(
                width: 2,
                color: states.contains(WidgetState.disabled)
                    ? scheme.onSurface.withValues(alpha: 0.24)
                    : scheme.primary,
              ),
            ),
          ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(gmTargetMin, gmTargetPrimary),
        padding: const EdgeInsets.symmetric(horizontal: gmSpaceMd),
        textStyle: text.labelLarge,
        iconSize: 28,
        foregroundColor: scheme.primary,
        shape: pill,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        minimumSize: const Size.square(gmTargetMin),
        iconSize: 28,
      ),
    ),
    chipTheme: ChipThemeData(
      labelStyle: text.labelMedium,
      backgroundColor: background,
      selectedColor: scheme.primaryContainer,
      checkmarkColor: scheme.onPrimaryContainer,
      side: BorderSide(color: scheme.outline),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(gmRadiusMd),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: gmSpaceSm,
        vertical: gmSpaceSm,
      ),
    ),
    switchTheme: SwitchThemeData(
      trackOutlineColor: WidgetStatePropertyAll(scheme.outline),
    ),
    listTileTheme: ListTileThemeData(
      minVerticalPadding: gmSpaceSm,
      titleTextStyle: text.bodyLarge,
      subtitleTextStyle: text.bodyMedium?.copyWith(
        color: scheme.onSurfaceVariant,
      ),
      iconColor: onSurface,
    ),
    cardTheme: CardThemeData(
      color: surface,
      surfaceTintColor: Colors.transparent,
      elevation: gmElevationCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(gmRadiusLg),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: background,
      surfaceTintColor: Colors.transparent,
      elevation: gmElevationModal,
      titleTextStyle: text.headlineSmall,
      contentTextStyle: text.bodyLarge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(gmRadiusXl),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: background,
      surfaceTintColor: Colors.transparent,
      modalBackgroundColor: background,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(gmRadiusXl)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: scheme.inverseSurface,
      contentTextStyle: text.bodyMedium?.copyWith(
        color: scheme.onInverseSurface,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(gmRadiusMd),
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: scheme.primary,
      linearTrackColor: gmSurf200,
      circularTrackColor: gmSurf200,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: background,
      indicatorColor: scheme.primaryContainer,
      labelTextStyle: WidgetStatePropertyAll(text.labelMedium),
    ),
    tooltipTheme: TooltipThemeData(
      textStyle: text.bodyMedium?.copyWith(color: scheme.onInverseSurface),
      decoration: BoxDecoration(
        color: scheme.inverseSurface,
        borderRadius: BorderRadius.circular(gmRadiusMd),
      ),
    ),
  );
}

///////////////////////////////////////////////////////////////////////////////
/// 5. ATOMS / MOLECULES
///////////////////////////////////////////////////////////////////////////////

/// PRIMARY CTA BUTTON  –  large touch target, antique-gold fill
class GmPrimaryButton extends StatelessWidget {
  const new({
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
        ? scheme.onSurface.withValues(alpha: 0.12)
        : scheme.primary;
    final fg = isDisabled
        ? scheme.onSurface.withValues(alpha: 0.6)
        : scheme.onPrimary;
    return Semantics(
      button: true,
      enabled: !isDisabled,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: gmTargetPrimary,
          minWidth: double.infinity,
        ),
        child: Material(
          color: bg,
          shape: const StadiumBorder(),
          child: Pressable(
            customBorder: const StadiumBorder(),
            onPressed: isDisabled ? null : onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: gmSpaceLg,
                vertical: gmSpaceSm,
              ),
              child: Center(
                child: busy
                    ? SizedBox.square(
                        dimension: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation(fg),
                        ),
                      )
                    : Text(
                        label,
                        textAlign: TextAlign.center,
                        style: Theme.of(parentContext).textTheme.labelLarge!
                            .copyWith(color: fg),
                      ),
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
  const new({required this.label, super.key, this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext parentContext) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          unawaited(SoundService().playTap());
          onTap?.call();
        },
        child: Text(label, textAlign: TextAlign.center),
      ),
    );
  }
}

/// Gold check badge that marks a matched tile by shape, not color alone.
class GmMatchBadge extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.primary,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Icon(Icons.check, size: 28, color: scheme.onPrimary),
      ),
    );
  }
}

/// Tile outline for the resting, selected and matched states.
RoundedRectangleBorder gmTileShape(
  ColorScheme scheme, {
  bool emphasized = false,
}) => RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(gmRadiusLg),
  side: BorderSide(
    width: emphasized ? gmBorderSelected : gmBorderResting,
    color: emphasized ? scheme.primary : scheme.outline,
  ),
);

/// Columns for a square-tile board: the largest tiles that let the whole
/// board fit on screen, so nothing has to be remembered while scrolling.
/// Tiles never drop below [gmTileMin]; only then does the board scroll.
int gmBoardColumns({
  required int tileCount,
  required int maxColumns,
  required Size size,
}) {
  double tileFor(int columns) =>
      (size.width - (columns - 1) * gmTileGap) / columns;
  final upper = maxColumns < 2 ? 2 : maxColumns;
  for (var columns = 2; columns <= upper; columns++) {
    final tile = tileFor(columns);
    if (tile < gmTileMin) break;
    final rows = (tileCount / columns).ceil();
    if (!size.height.isFinite ||
        rows * tile + (rows - 1) * gmTileGap <= size.height) {
      return columns;
    }
  }
  var columns = upper;
  while (columns > 2 && tileFor(columns) < gmTileMin) {
    columns--;
  }
  return columns;
}

/// MEMORY TILE  (face-down / revealed / selected / matched) for the
/// picture-pack library. Selected and matched tiles get the 4px Antique Gold
/// border, so state is never shown by color alone. [onTap] is null when the
/// tile cannot be chosen; the caller decides, because a face-up mismatch is
/// tappable (its tap starts the next turn).
class GmMemoryTile extends StatelessWidget {
  const new({
    required this.revealed,
    required this.image,
    this.matched = false,
    this.selected = false,
    this.onTap,
    super.key,
  });
  final bool revealed;
  final bool matched;
  final bool selected;
  final ImageProvider image;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext parentContext) {
    final scheme = Theme.of(parentContext).colorScheme;
    final border = gmTileShape(scheme, emphasized: matched || selected);
    final reduceMotion = MediaQuery.disableAnimationsOf(parentContext);
    return Material(
      color: revealed ? scheme.surface : gmSurf200,
      shape: border,
      clipBehavior: Clip.antiAlias,
      child: Pressable(
        customBorder: border,
        onPressed: matched ? null : onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedSwitcher(
              duration: reduceMotion
                  ? Duration.zero
                  : const Duration(milliseconds: 250),
              switchInCurve: Curves.easeOut,
              transitionBuilder: (c, a) =>
                  RotationYTransition(turns: a, child: c),
              child: revealed
                  ? Padding(
                      key: const ValueKey('front'),
                      padding: const EdgeInsets.all(gmSpaceSm),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(gmRadiusMd),
                        child: Image(image: image, fit: BoxFit.cover),
                      ),
                    )
                  : Center(
                      key: const ValueKey('back'),
                      child: Icon(
                        Icons.photo_outlined,
                        size: 48,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
            ),
            if (matched)
              const Positioned(
                top: gmSpaceSm,
                right: gmSpaceSm,
                child: GmMatchBadge(),
              ),
          ],
        ),
      ),
    );
  }
}

// Flip helper
class RotationYTransition extends AnimatedWidget {
  const new({required Animation<double> turns, required this.child, super.key})
    : super(listenable: turns);

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
/// 6. ACCESSIBILITY SHORTCUTS
///////////////////////////////////////////////////////////////////////////////
extension GmAccessible on BuildContext {
  bool get isLargeText => MediaQuery.textScalerOf(this).scale(1) > 1.2;
}

///////////////////////////////////////////////////////////////////////////////
/// See DESIGN.md › Components for usage.
