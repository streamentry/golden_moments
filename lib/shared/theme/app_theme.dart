import 'package:flutter/material.dart';
import 'package:golden_moments/game/models/models.dart';

/// Senior-friendly theme configuration for Memory Lane
class AppTheme {
  AppTheme._();

  // Base font sizes (will be multiplied by FontSize multiplier)
  static const double _baseFontSizeSmall = 14;
  static const double _baseFontSizeMedium = 16;
  static const double _baseFontSizeLarge = 18;
  static const double _baseFontSizeXLarge = 20;

  // Minimum touch target size for accessibility
  static const double minTouchTargetSize = 48;

  // Color palette - high contrast and color-blind safe
  static const Color primaryColor = Color(0xFF2E7D32); // Dark green
  static const Color primaryLightColor = Color(0xFF60AD5E); // Light green
  static const Color primaryDarkColor = Color(0xFF005005); // Very dark green

  static const Color secondaryColor = Color(0xFF1976D2); // Blue
  static const Color secondaryLightColor = Color(0xFF63A4FF); // Light blue
  static const Color secondaryDarkColor = Color(0xFF004BA0); // Dark blue

  static const Color accentColor = Color(0xFFFF8F00); // Orange
  static const Color errorColor = Color(0xFFD32F2F); // Red
  static const Color successColor = Color(0xFF388E3C); // Green
  static const Color warningColor = Color(0xFFF57C00); // Amber

  // Background colors
  static const Color backgroundColor = Color(0xFFF5F5F5); // Light gray
  static const Color surfaceColor = Color(0xFFFFFFFF); // White
  static const Color cardColor = Color(0xFFFAFAFA); // Very light gray

  // Text colors
  static const Color textPrimaryColor = Color(0xFF212121); // Dark gray
  static const Color textSecondaryColor = Color(0xFF757575); // Medium gray
  static const Color textOnPrimaryColor = Color(0xFFFFFFFF); // White

  // High contrast colors
  static const Color highContrastBackground = Color(0xFF000000); // Black
  static const Color highContrastSurface = Color(0xFF1A1A1A); // Very dark gray
  static const Color highContrastText = Color(0xFFFFFFFF); // White
  static const Color highContrastPrimary = Color(0xFFFFD700); // Gold

  /// Creates the main theme for the app
  static ThemeData getTheme({
    FontSize fontSize = FontSize.large,
    bool highContrastMode = false,
  }) {
    final colorScheme = highContrastMode
        ? _getHighContrastColorScheme()
        : _getStandardColorScheme();

    final textTheme = _getTextTheme(fontSize, highContrastMode);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,

      // Button themes with large touch targets
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(minTouchTargetSize * 2, minTouchTargetSize),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: textTheme.titleMedium,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(minTouchTargetSize * 2, minTouchTargetSize),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: textTheme.titleMedium,
        ),
      ),

      // Card theme will be handled by individual Card widgets

      // App bar theme
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 2,
        titleTextStyle: textTheme.headlineSmall?.copyWith(
          color: colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),

      // Icon theme
      iconTheme: IconThemeData(
        size: 32 * fontSize.multiplier,
        color: colorScheme.onSurface,
      ),

      // Divider theme
      dividerTheme: DividerThemeData(
        thickness: 2,
        color: colorScheme.outline,
      ),
    );
  }

  static ColorScheme _getStandardColorScheme() {
    return const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      onSecondary: textOnPrimaryColor,
      onSurface: textPrimaryColor,
      error: errorColor,
    );
  }

  static ColorScheme _getHighContrastColorScheme() {
    return const ColorScheme.dark(
      primary: highContrastPrimary,
      secondary: highContrastText,
      surface: highContrastSurface,
      error: errorColor,
      onError: highContrastText,
    );
  }

  static TextTheme _getTextTheme(FontSize fontSize, bool highContrastMode) {
    final baseColor = highContrastMode ? highContrastText : textPrimaryColor;
    final multiplier = fontSize.multiplier;

    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 32 * multiplier,
        fontWeight: FontWeight.bold,
        color: baseColor,
        height: 1.2,
      ),
      displayMedium: TextStyle(
        fontSize: 28 * multiplier,
        fontWeight: FontWeight.bold,
        color: baseColor,
        height: 1.2,
      ),
      displaySmall: TextStyle(
        fontSize: 24 * multiplier,
        fontWeight: FontWeight.bold,
        color: baseColor,
        height: 1.2,
      ),
      headlineLarge: TextStyle(
        fontSize: 22 * multiplier,
        fontWeight: FontWeight.w600,
        color: baseColor,
        height: 1.3,
      ),
      headlineMedium: TextStyle(
        fontSize: 20 * multiplier,
        fontWeight: FontWeight.w600,
        color: baseColor,
        height: 1.3,
      ),
      headlineSmall: TextStyle(
        fontSize: 18 * multiplier,
        fontWeight: FontWeight.w600,
        color: baseColor,
        height: 1.3,
      ),
      titleLarge: TextStyle(
        fontSize: 16 * multiplier,
        fontWeight: FontWeight.w500,
        color: baseColor,
        height: 1.4,
      ),
      titleMedium: TextStyle(
        fontSize: 14 * multiplier,
        fontWeight: FontWeight.w500,
        color: baseColor,
        height: 1.4,
      ),
      titleSmall: TextStyle(
        fontSize: 12 * multiplier,
        fontWeight: FontWeight.w500,
        color: baseColor,
        height: 1.4,
      ),
      bodyLarge: TextStyle(
        fontSize: 16 * multiplier,
        fontWeight: FontWeight.normal,
        color: baseColor,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14 * multiplier,
        fontWeight: FontWeight.normal,
        color: baseColor,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontSize: 12 * multiplier,
        fontWeight: FontWeight.normal,
        color: baseColor,
        height: 1.5,
      ),
      labelLarge: TextStyle(
        fontSize: 14 * multiplier,
        fontWeight: FontWeight.w500,
        color: baseColor,
        height: 1.4,
      ),
      labelMedium: TextStyle(
        fontSize: 12 * multiplier,
        fontWeight: FontWeight.w500,
        color: baseColor,
        height: 1.4,
      ),
      labelSmall: TextStyle(
        fontSize: 10 * multiplier,
        fontWeight: FontWeight.w500,
        color: baseColor,
        height: 1.4,
      ),
    );
  }
}
