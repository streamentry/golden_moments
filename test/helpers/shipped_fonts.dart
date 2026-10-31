import 'package:flutter/services.dart';
import 'package:golden_moments/design_system.dart';

/// Loads the two bundled families (DESIGN.md › Typography), so headline and
/// label widths in a test are the shipped ones rather than the square test
/// font's, which makes every word far wider.
Future<void> loadShippedFonts() async {
  final roboto = FontLoader(gmFontFamily);
  for (final weight in ['Regular', 'Medium', 'Bold']) {
    roboto.addFont(rootBundle.load('assets/fonts/Roboto-$weight.ttf'));
  }
  final fraunces = FontLoader(gmDisplayFontFamily)
    ..addFont(rootBundle.load('assets/fonts/Fraunces-Bold.ttf'));
  await Future.wait([roboto.load(), fraunces.load()]);
}
