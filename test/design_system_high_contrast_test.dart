import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/design_system.dart';

double _luminance(Color c) {
  double channel(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
}

double _contrast(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  group('Higher contrast theme', () {
    final scheme = gmBuildTheme(highContrast: true).colorScheme;

    test(
      'text, secondary text and edges reach the high-contrast thresholds',
      () {
        expect(_contrast(scheme.onSurface, scheme.surface), greaterThan(7));
        expect(
          _contrast(scheme.onSurfaceVariant, scheme.surface),
          greaterThan(7),
        );
        expect(_contrast(scheme.outline, scheme.surface), greaterThan(3));
      },
    );

    test('the paper is white and the page background matches the tokens', () {
      expect(
        gmBuildTheme(highContrast: true).scaffoldBackgroundColor,
        gmHighContrastSurface,
      );
    });

    test('the default theme is unchanged', () {
      final normal = gmBuildTheme().colorScheme;
      expect(normal.onSurfaceVariant, gmWalnut600);
      expect(normal.outline, gmDriftwood500);
      expect(gmBuildTheme().scaffoldBackgroundColor, gmSurf50);
    });
  });
}
